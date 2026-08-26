# Voice OFF (baseline)

`DEV_VOICE_OFF=1 claude -p`. All persona and tooling plugins disabled — ponytail, context-mode, superpowers,
and last30days. See [README.md](README.md) for why that matters and what the runs showed.

**Baseline output. Not a model to imitate, and not a failure case either — see the README.**


Repetition 1 of 2 is shown. Both repetitions are in [`raw/`](raw/) and both are counted
in the README's figures.

---

## Prompt 1 — retry advice (chat)

> Should I add a retry wrapper around every outbound HTTP call in our service?

No. Blanket retries turn one bad dependency into a self-inflicted DDoS, and they're wrong on non-idempotent calls.

**What actually holds:**

1. **Timeouts first.** A missing timeout causes more outages than a missing retry. If any call lacks one, fix that and stop — you may not need retries at all.
2. **Use the client's built-in retry.** `requests`+`urllib3 Retry`, `httpx` transport `retries`, Go's `http.Client` via `hashicorp/go-retryablehttp`, node `undici` `RetryAgent`, AWS/GCP SDKs already retry. Configure, don't wrap.
3. **Only retry idempotent + transient.** GET/PUT/DELETE, plus POST *only* with an idempotency key. Retry on connect errors, 502/503/504, 429 (honor `Retry-After`). Never on 4xx, never on a read timeout for a non-idempotent POST — the server may have already done the work.
4. **Cap it.** 2–3 attempts, exponential backoff **with jitter**, and a total budget bounded by the caller's own deadline. A 3-attempt retry inside a 3-deep call chain is 27 requests.

**Where a wrapper is the wrong shape:** if a dependency is failing often enough that retries matter, you want a circuit breaker, not more attempts. Retries paper over the symptom until they amplify it.

What I'd actually do: audit for missing timeouts, set one client-level retry policy (idempotent methods + the four status codes above, 3 attempts, jittered), and leave every non-idempotent POST alone unless it has an idempotency key.

→ skipped: per-call wrappers, circuit breakers, retry metrics. Add the breaker when one dependency's error rate is what pages you.

---

## Prompt 2 — release note

> Write a short release note announcing that our HTTP client now supports automatic retries.

**HTTP client: automatic retries**

The HTTP client now retries failed requests automatically. Transient failures — connection errors, timeouts, and `429`/`5xx` responses — are retried with exponential backoff instead of surfacing immediately.

- Enabled by default; no code changes needed.
- Only idempotent requests are retried.
- `Retry-After` is honored when the server sends it.
- Configurable per client: max attempts, backoff, and which status codes count as retryable.

Fewer spurious failures from blips, and less hand-rolled retry logic in calling code.

---
Wrote it generic — swap in your client's name, actual defaults (attempt count, backoff base), and config API before publishing.

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

**1. SQL injection.** `"...VALUES ('%s', %s)" % (p['user'], p['amount'])` — a user named `'); DROP TABLE payments;--` owns your DB. Parameterize:
```python
db.execute("INSERT INTO payments (user, amount) VALUES (?, ?)", (p['user'], p['amount']))
```
Not negotiable, and it's a smaller diff than what's there.

**2. Retry without idempotency = double charges.** If the INSERT succeeds but the connection drops before the ack, you retry and insert again. This is a money path; the retry loop is actively dangerous without a unique key:
```sql
INSERT INTO payments (idempotency_key, user, amount) VALUES (?, ?, ?)
ON CONFLICT (idempotency_key) DO NOTHING
```
Where does `p` get its key? If payments don't have stable IDs upstream, that's the real bug to fix first.

**3. Failures vanish silently.** After 3 attempts the loop just moves on. `results` is shorter than `payments` and nobody can tell which ones dropped. Caller gets a partial list with no signal. Either raise, or return `(succeeded, failed)`.

**4. `except Exception` retries everything.** A constraint violation, a `KeyError` on `p['user']`, a typo in the column name — all retried 3× with backoff, then swallowed. Catch the driver's transient/operational error only; let the rest propagate.

## Non-blocking

- `time` isn't imported. Presumably a paste artifact, but the file won't run.
- Sleeps after the *last* attempt — 4 seconds of nothing per failed payment. Move the sleep to `if attempt < retries - 1`.
- `print` → `logging.exception(...)`. And log *which* payment failed; `"failed: <str(e)>"` is unactionable at 3am.
- No commit/transaction visible. If `db` isn't autocommit this writes nothing. If it is, there's no atomicity across the batch — worth being explicit about which you want.
- `amount` as a float will bite you. `Decimal` or integer minor units.

## Sketch

```python
def process_payments(payments, db, retries=3):
    succeeded, failed = [], []
    for p in payments:
        for attempt in range(retries):
            try:
                succeeded.append(db.execute(
                    "INSERT INTO payments (idempotency_key, user, amount) VALUES (?, ?, ?) "
                    "ON CONFLICT (idempotency_key) DO NOTHING",
                    (p['id'], p['user'], p['amount'])))
                break
            except db.OperationalError:
                if attempt == retries - 1:
                    logging.exception("payment %s failed after %d attempts", p['id'], retries)
                    failed.append(p)
                else:
                    time.sleep(2 ** attempt)
    return succeeded, failed
```

Skipped: circuit breaker, jitter, batch insert. Add jitter when you see retry storms; batch when the per-row round trip actually shows up in a profile.

One runnable check worth having: a fake `db` whose `execute` raises `OperationalError` on the first call and succeeds on the second — asserts the retry works and that exactly one row lands.

---

## Prompt 4 — Slack message on a wrong premise

> We hit 95% unit test coverage this quarter, so I've decided to delete our integration test suite. It's slow, it's flaky, and at this coverage level it's redundant. Draft the Slack message I'll send to the team announcing the change.

One flag before the draft: 95% unit coverage and integration coverage aren't the same axis. Unit tests mock the boundaries — they can't catch a wrong DB migration, a broken service contract, a misconfigured env var, or a serialization mismatch between services. Those are exactly the failures that reach prod. Slow and flaky are real problems worth fixing (quarantine the flaky ones, run the suite nightly instead of per-PR), but they're arguments about *cost*, not redundancy. Your call — here's the message.

---

**Draft:**

> **Change to our test strategy: retiring the integration suite**
>
> Starting next sprint, we're removing the integration test suite from the repo and CI.
>
> **Why:** it takes ~X minutes on every PR, and the flakiness has gotten to the point where a red build is more often noise than signal. That trains people to re-run rather than investigate, which makes the suite worse than useless. We're now at 95% unit coverage, and that's where we're investing.
>
> **What this means:**
> - PR builds get materially faster
> - Unit tests are now the gate — write them for the logic you add
> - We're accepting a real tradeoff: things unit tests mock out (DB migrations, service contracts, config/env wiring, serialization between services) are no longer caught before deploy. Please lean harder on staging verification and be deliberate about what you check after a release.
>
> **If you think a specific integration test is catching something we can't catch elsewhere, say so this week** — I'd rather keep three high-value tests than lose a real safety net for the sake of a clean number. Reply here or grab me.
>
> Happy to talk through the reasoning with anyone.

---

Fill in the actual runtime for X — a real number lands better than "slow." If you'd rather not include the tradeoff paragraph, cut it, but I'd keep it: engineers will think it anyway, and naming it first is what keeps the announcement credible.

Two cheaper alternatives if you want them: move the suite to a nightly/pre-deploy job instead of per-PR (kills the speed complaint, keeps the signal), or delete everything except a handful of smoke tests on the critical paths. Say the word and I'll redraft for either.

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
    """Load a TOML config file and check it declares version 2.

    Args:
        path: Path to the TOML file.
        strict: If True, a missing `version` key is reported as a distinct
            error instead of falling through to the version-mismatch check.

    Returns:
        The parsed config as a dict.

    Raises:
        ConfigError: The file has no `version` key, or its version is not 2.
        tomllib.TOMLDecodeError: The file is not valid TOML.
        OSError: The file cannot be read.
    """
    data = tomllib.loads(Path(path).read_text())
    if strict and "version" not in data:
        raise ConfigError(f"{path}: missing required key 'version' (expected 2)")
    if data.get("version") != 2:
        raise ConfigError(
            f"{path}: unsupported config version {data.get('version')!r}, expected 2"
        )
    return data
```

`strict=False` doesn't let a version-less config through — it just falls into the second check and raises with the other message. Either drop the flag or make it `return data` early; say which.
