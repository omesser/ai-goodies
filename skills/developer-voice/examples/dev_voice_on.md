# Voice ON

`claude -p`, ponytail disabled. `SKILL.md` injected by the SessionStart hook.

Verbatim output. See [README.md](README.md) for method and analysis.

Prompts 3-5 ran twice per arm; rep 1 is shown here and both reps are counted in the
variance figures in the README.

---

## Prompt 1 — advice

> Should I add a retry wrapper around every outbound HTTP call in our service?

No. Retry the calls that are safe to retry, and make that a per-call decision at the client boundary rather than a blanket wrapper.

## Why a blanket wrapper hurts

**Non-idempotent writes get duplicated.** A `POST /charges` that times out may have succeeded. A retry charges twice. Retrying that call safely requires an idempotency key the server honors — which is a contract change, not a wrapper.

**Retries multiply through layers.** If your gateway retries 3× and calls a service that also retries 3×, one user request becomes 9 backend calls. Under partial failure, that's the load pattern that turns a slow dependency into a dead one.

**Retrying the wrong failures wastes latency.** A `400`, `401`, `403`, `404`, or `422` will fail again identically. The user waits through the backoff for nothing.

**Retries hide the signal.** If a dependency is failing 20% of calls and retries paper over it, your dashboards look fine until it fails 100%.

## What to do instead

Decide per dependency, and encode the decision where the client is constructed:

| Condition | Retry? |
|---|---|
| Connection refused, DNS failure, TLS handshake failure | Yes — the request never landed |
| `429`, `503` with `Retry-After` | Yes — honor the header |
| `500`, `502`, `504` on a read (`GET`, `HEAD`) | Yes |
| `500`, `502`, `504` on a write | Only with a server-honored idempotency key |
| Read timeout on a write | Only with an idempotency key |
| Any `4xx` other than `429` | No |

Then bound the retries:

- **Backoff with full jitter.** Fixed or unjittered backoff synchronizes clients into waves.
- **A total deadline, not a retry count.** Propagate the caller's remaining budget and stop retrying when it's spent. Three retries against a 10-second timeout is a 40-second call nobody is waiting for anymore.
- **A retry budget.** Cap retries at a small fraction of total requests (~10%) across the client, so a broad outage can't triple your outbound load. This is the piece most implementations skip, and it's the one that prevents retry storms.
- **A circuit breaker per dependency.** When a dependency is down, fail fast instead of retrying every call into it.
- **Retry at one layer only.** Pick the layer closest to the dependency and make the outer layers pass failures through.

## Where a wrapper is fine

If you mean "every outbound call goes through one HTTP client that has a *configurable* retry policy, defaulting to off" — do that. A single client with per-dependency config gives you consistent metrics, timeouts, and breakers. The problem is the default being "retry everything," not the shared code path.

Two things would sharpen this: whether your writes have idempotency keys, and whether anything upstream of your service already retries. If you point me at the repo I'll tell you which calls are actually safe to retry today.

---

## Prompt 2 — release note

> Write a short release note announcing that our HTTP client now supports automatic retries.

## HTTP client: automatic retries

The HTTP client now retries failed requests for you.

Transient failures — connection errors, timeouts, and `429`, `502`, `503`, and `504` responses — are retried automatically with exponential backoff and jitter. Requests that fail for reasons a retry won't fix, like `400` or `404`, return right away.

Retries are on by default. To change the limit or turn them off:

```
client = HttpClient(max_retries=5)   # default: 3
client = HttpClient(max_retries=0)   # disable
```

Only idempotent methods (`GET`, `HEAD`, `PUT`, `DELETE`) are retried by default. If a `POST` endpoint is safe to repeat, opt in per request.

No changes are needed to existing code. If your callers already wrap requests in their own retry loop, remove that layer to avoid multiplying the attempt count.

---

Two things I filled in without knowing your setup: the retried status codes and the config API. Tell me the real option names and defaults and I'll correct them — or point me at the client and I'll read them off the code.

---

## Prompt 3 — code review

> Review this function and give me the code review comments you'd leave on the PR.
>
> def process_payments(payments, db, retries=3):
>     results = []
>     for p in payments:
>         for attempt in range(retries):
>             try:
>                 r = db.execute("INSERT INTO payments (user, amount) VALUES ('%s', %s)" % (p['user'], p['amount']))
>                 results.append(r)
>                 break
>             except Exception as e:
>                 if attempt == retries - 1:
>                     print("failed: " + str(e))
>                 time.sleep(2 ** attempt)
>     return results

## Blocking

**SQL injection (line 6).** The query is built with `%` string formatting, so `p['user']` goes straight into the SQL text. A user value of `x', 0); DROP TABLE payments; --` executes as SQL. Use the driver's parameter binding instead:

```python
db.execute("INSERT INTO payments (user, amount) VALUES (?, ?)", (p['user'], p['amount']))
```

Placeholder style depends on the driver (`?` for sqlite3, `%s` for psycopg2/MySQLdb), but the point is the same: pass values as a separate argument, never interpolate them.

**Retrying an INSERT can double-charge.** If the insert commits and the connection drops before the response comes back, the retry inserts a second row for the same payment. Money moves twice. This needs an idempotency key — a unique constraint on a client-supplied payment ID, with the duplicate-key error treated as success rather than as a retryable failure.

**Failures are swallowed (lines 10-11).** After the last attempt, the code prints and moves on. The caller receives a `results` list with no way to tell which payments landed and which didn't, and `len(results) != len(payments)` is the only hint. For payments, the caller has to know exactly what failed. Consider returning both successes and failures, or raising once at the end with the failed batch attached.

**`except Exception` retries things that can never succeed.** A constraint violation, a malformed amount, or a `KeyError` from `p['user']` gets retried three times with backoff, then vanishes into a `print`. Catch the driver's transient error types (connection, deadlock, timeout) and let everything else propagate immediately.

## Non-blocking

**`time` is never imported.** Line 13 raises `NameError` the first time any insert fails, which is probably why this path hasn't been noticed — it only runs on the error branch. Worth a test that exercises a failing insert.

**The backoff sleeps after the final attempt (line 13).** The last iteration sleeps `2 ** (retries - 1)` seconds and then exits the loop anyway. With `retries=3` that's 7 seconds of sleep per failing payment, 4 of which buy nothing. Moving the sleep before the retry, or skipping it on the last attempt, fixes it.

**`print` for errors.** Use the module logger so these land in whatever aggregation the rest of the service uses, and log every failed attempt rather than only the last one — intermediate failures are the signal that the database is degrading.

**No jitter in the backoff.** If a batch of workers hits a struggling database, they all retry at 1s, 2s, and 4s together. Adding randomness to the delay spreads the load.

**`retries=3` means three total attempts, not three retries.** Minor, but callers will read it the other way. `max_attempts` says what it does.

**Amount type.** If `p['amount']` is a float, rounding errors accumulate across a batch. Decimal or integer minor units (cents) is the safer representation for money.

**Serial execution.** Each payment waits for the previous one's round trip, and failures add seconds of sleep on top. If batches get large, a single multi-row insert inside one transaction — or a bounded concurrent pool — will matter.

## What works well

Per-payment retry with exponential backoff is the right shape for transient database errors, and scoping the retry to the individual payment rather than the whole batch means one bad row doesn't force a full replay. The fixes above are about making that structure safe, not replacing it.

---

## Prompt 4 — Slack message on a wrong premise

> We hit 95% unit test coverage this quarter, so I've decided to delete our integration test suite. It's slow, it's flaky, and at this coverage level it's redundant. Draft the Slack message I'll send to the team announcing the change.

One thing worth naming before the draft: unit coverage and integration coverage aren't substitutes, so 95% doesn't make the suite redundant. Line coverage measures which lines ran under mocks — it says nothing about whether services agree on a contract, whether migrations apply, or whether config is wired right in a real environment. Those failures are invisible to unit tests by construction. Slow and flaky are real problems, and they're worth solving on their own terms.

Your call, though. Here's the announcement, written to hold up when the team pushes back:

---

**Retiring the integration test suite**

Starting next sprint, we're removing the integration test suite from CI and the repo.

Why: it takes ~X minutes per run, fails for unrelated reasons often enough that people re-run it by reflex, and a test nobody trusts isn't protecting us. Meanwhile unit coverage is at 95%, so most logic-level regressions get caught in seconds instead of minutes.

What we're accepting in exchange: unit tests mock their dependencies, so we lose our automated check on the parts between components — service contracts, DB migrations, config and environment wiring, auth flows end to end. Those bugs will now reach staging before we see them. If you're changing an interface between services or touching migrations, test it by hand and say so in your PR.

What happens next:
1. I'll open a PR removing the suite from CI on <date>. Speak up before then if you rely on a specific test.
2. The code stays in git history — we can restore any test we miss.
3. We'll watch staging and production incidents for the next two months. If integration-shaped bugs start getting through, we bring back a targeted suite rather than the whole thing.

Questions or objections, this thread or DM me.

---

Two things to fill in: the actual runtime and the PR date. And if you want a version that trims the suite to a handful of high-value paths instead of deleting all of it, say the word — it's a smaller message and a much easier sell to whoever asks "what caught the last integration bug we shipped?"

---

## Prompt 5 — docstring and error messages

> Write the docstring and fill in the error messages for this function.
>
> def load_config(path, *, strict=True):
>     data = tomllib.loads(Path(path).read_text())
>     if strict and "version" not in data:
>         raise ConfigError(...)
>     if data.get("version") != 2:
>         raise ConfigError(...)
>     return data

```python
def load_config(path, *, strict=True):
    """Load a TOML config file and check its schema version.

    Args:
        path: Path to the TOML file. Accepts anything `Path()` takes.
        strict: When True, reject a config that omits `version`.

    Returns:
        The parsed config as a dict.

    Raises:
        ConfigError: The file omits `version` under strict mode, or declares a
            version other than 2.
        tomllib.TOMLDecodeError: The file is not valid TOML.
        OSError: The file is missing or unreadable.
    """
    data = tomllib.loads(Path(path).read_text())
    if strict and "version" not in data:
        raise ConfigError(
            f"{path} has no 'version' key. Add 'version = 2' at the top level, "
            f"or pass strict=False to skip this check."
        )
    if data.get("version") != 2:
        raise ConfigError(
            f"{path} declares version {data.get('version')!r}, but this loader "
            f"only reads version 2. Migrate the file to version 2."
        )
    return data
```

One thing to flag: `strict=False` doesn't do what the name suggests. It skips the missing-key check, but the next check still fails on `None != 2`, so a config without `version` is rejected either way — only the message changes. If `strict=False` is meant to accept a version-less config, the second check needs a guard:

```python
    if "version" in data and data["version"] != 2:
```

I left the behavior as written and wrote the messages to match it. Tell me which reading you want and I'll adjust.
