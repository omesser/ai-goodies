# Voice OFF (baseline)

`DEV_VOICE_OFF=1 claude -p`. Neither developer-voice nor ponytail in context.

Verbatim output. See [README.md](README.md) for method and analysis.

**This is the baseline — the register the skill exists to replace. Don't imitate it.**


Prompts 3-5 ran twice per arm; rep 1 is shown here and both reps are counted in the
variance figures in the README.

---

## Prompt 1 — advice

> Should I add a retry wrapper around every outbound HTTP call in our service?

Short answer: no. Retry-everywhere is one of those changes that looks like added resilience and is actually added blast radius.

**Why blanket retries hurt**

- **Non-idempotent calls get duplicated.** A `POST /charge` that times out may well have succeeded server-side. A blind retry double-charges. Timeouts are the ambiguous case, and they're exactly the case retries fire on.
- **Retry amplification.** If your gateway retries 3×, your service retries 3×, and your HTTP client retries 3×, a struggling downstream sees 27× load precisely when it's least able to take it. This is the classic mechanism that turns a partial degradation into a full outage.
- **Latency budget blowout.** Wrapping a call that already has a 10s timeout in 3 attempts means a request that used to fail in 10s now fails in 30s+ — while holding a connection, a thread, and upstream client patience.
- **It hides real failures.** A dependency at 5% error rate silently retried into 0.1% visible error rate is a dependency nobody fixes until it's at 40%.

**What to do instead**

Retry per-call-site, gated on two independent questions:

1. **Is the operation safe to repeat?** GETs and other reads: yes. Writes: only with an idempotency key that the *server* honors, or a naturally idempotent semantic (PUT of a full resource, DELETE).
2. **Is this failure class retryable?** Connection refused/reset, 429, 502/503/504, and DNS failures — yes. 400/401/403/404/409/422 — never; you'll just fail three times slower.

And when you do retry:

- **Exponential backoff with full jitter**, not fixed delay — synchronized retries from many instances are a self-inflicted thundering herd.
- **Honor `Retry-After`** on 429/503.
- **A deadline, not an attempt count.** Propagate a remaining-time budget through the call chain, and don't start an attempt you can't finish inside it. Attempt counts compose badly; deadlines compose correctly.
- **A retry budget** — cap retries at some small fraction of total requests (e.g. 10%). This is the single most effective guard against amplification, and it's what gRPC and Envoy both do.
- **Circuit breaker in front.** Retrying into a downstream that's hard down is pure waste; fail fast and shed.
- **Retry at exactly one layer.** Pick it deliberately, and turn it off everywhere else. Most client libraries have retries on by default — check.

**The pragmatic move**

Don't write a wrapper you sprinkle by hand — that guarantees inconsistency. Configure it in your HTTP client/service mesh so the policy is declarative and per-route, then set the default to *no retries* and opt in route by route. Emit a metric per retry (attempt number, outcome, call site) so you can see amplification before it bites.

If you tell me what language/stack and whether you're behind a mesh, I'll sketch the concrete config or interceptor — and if you want, we can walk your actual outbound call sites and classify them.

---

## Prompt 2 — release note

> Write a short release note announcing that our HTTP client now supports automatic retries.

I don't have the repo or config details here, so I've used placeholders for the name/version and assumed common defaults (exponential backoff + jitter, idempotent methods and 429/5xx only). Swap those to match the actual implementation.

---

## Automatic retries in `<HttpClient>` — v`<X.Y.0>`

The HTTP client now retries failed requests automatically. Transient failures — connection errors, timeouts, `429`, and `5xx` responses — are retried with exponential backoff and jitter, so a brief network blip or an upstream hiccup no longer surfaces as an error in your code.

**Defaults**
- Up to **3 retries** per request
- **Exponential backoff with jitter**, honoring `Retry-After` when the server sends it
- Only **idempotent** requests (`GET`, `HEAD`, `PUT`, `DELETE`, `OPTIONS`) are retried by default

**Configuring it**

```
client = HttpClient(retries=5, backoff="exponential", retry_on=[429, 502, 503, 504])
client = HttpClient(retries=0)   # opt out
```

No changes are required to pick this up — existing code gets retries on upgrade. If you already wrapped calls in your own retry loop, set `retries=0` to avoid compounding the two.

---

Two things worth confirming before you publish: whether retries are on by default (that's the biggest behavioral note for existing users), and whether non-idempotent methods like `POST` are excluded.

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

Here's what I'd leave on the PR:

---

## Blocking

**1. SQL injection — `line 6`**

```python
"INSERT INTO payments (user, amount) VALUES ('%s', %s)" % (p['user'], p['amount'])
```

This is string interpolation into SQL, not parameter binding. A `user` value of `x'); DROP TABLE payments; --` executes. Use the driver's placeholders and pass params as a tuple:

```python
db.execute("INSERT INTO payments (user, amount) VALUES (%s, %s)", (p["user"], p["amount"]))
```

Note the quotes around `'%s'` also disappear — the driver handles quoting/escaping/typing. Right now `amount` is unquoted, so a `None` amount interpolates the literal string `None` and produces a syntax error rather than a NULL.

**2. Retrying a non-idempotent INSERT can double-charge**

The most common transient failure is "statement executed, connection dropped before we got the ack." This code retries that, inserting a second payment row. In a payments path that's a duplicate charge, and the retry loop makes it up to 3×.

This needs an idempotency key on the payment plus a unique constraint, so a retry is a no-op rather than a second row:

```sql
INSERT INTO payments (payment_id, user, amount) VALUES (%s, %s, %s)
ON CONFLICT (payment_id) DO NOTHING
```

Without that, I'd rather see no retry at all than this retry.

**3. Failures are silently swallowed**

After the last attempt it `print`s and moves to the next payment. The caller gets back a `results` list with no way to know that payment #4 never landed — and no way to correlate entries back to inputs, since a failed payment just leaves a gap. For money movement, this should either raise or return an explicit `(succeeded, failed)` pair. Your call on the contract, but "partial failure looks identical to full success" isn't viable.

**4. `except Exception` retries bugs**

`p['user']` raising `KeyError`, a `TypeError`, a constraint violation on a genuinely invalid payment — none of those get better on retry. You'll burn 3 attempts and 6 seconds of `sleep` per malformed record before giving up. Catch the driver's transient errors specifically (`OperationalError`, `InterfaceError`, or whatever your driver exposes) and let everything else propagate.

## Non-blocking

- **Sleeps after the final attempt.** `time.sleep` runs unconditionally in the handler, so a payment that exhausts its retries still sleeps 4s before the loop exits. Guard with `if attempt < retries - 1`.
- **No jitter in the backoff.** If this runs across several workers that fail together, they'll all retry in lockstep. `2 ** attempt + random.uniform(0, 0.5)`.
- **`print` → `logging`.** And log the payment identifier alongside the error; `"failed: <str(e)>"` isn't enough to find the record afterwards. Use `logger.exception` / `exc_info` to keep the traceback.
- **`time` isn't imported** in the snippet as written.
- **Column named `user`** is a reserved word in Postgres and will need quoting (`"user"`). Worth renaming to `user_id` if this table is new.
- **No transaction handling.** Is `db.execute` autocommitting? If these should land atomically as a batch, that's a different structure. Also, N round trips where an `executemany`/batch insert would do — probably fine at current volumes, flagging for when it isn't.
- **Missing type hints and a docstring** on a public-ish function handling money.

## Suggested shape

```python
TRANSIENT = (driver.OperationalError, driver.InterfaceError)

def process_payments(payments, db, retries=3):
    results, failures = [], []
    for p in payments:
        last_error = None
        for attempt in range(retries):
            try:
                results.append(db.execute(
                    'INSERT INTO payments (payment_id, "user", amount) VALUES (%s, %s, %s) '
                    "ON CONFLICT (payment_id) DO NOTHING",
                    (p["id"], p["user"], p["amount"]),
                ))
                break
            except TRANSIENT as e:
                last_error = e
                if attempt < retries - 1:
                    time.sleep(2**attempt + random.uniform(0, 0.5))
        else:
            logger.error("payment %s failed after %d attempts", p["id"], retries, exc_info=last_error)
            failures.append((p, last_error))
    return results, failures
```

The `for/else` fires only when the loop exhausts without `break`, which is exactly the "all retries failed" case.

---

## Prompt 4 — Slack message on a wrong premise

> We hit 95% unit test coverage this quarter, so I've decided to delete our integration test suite. It's slow, it's flaky, and at this coverage level it's redundant. Draft the Slack message I'll send to the team announcing the change.

One flag before the draft: unit coverage and integration coverage measure different things, so 95% of the former doesn't subsume the latter. Line coverage tells you which lines ran under mocked boundaries — it says nothing about whether your service wiring, DB queries, serialization, auth, or third-party contracts actually work together. Slowness and flakiness are real costs, but they're arguments for quarantining and fixing, not deleting. Your call — here's the message.

```
:wave: Heads up on a change to how we test.

**TL;DR: we're removing the integration test suite. Last run is [DATE]; the
directory comes out in [PR link].**

Why:
• We're at 95% unit coverage as of this quarter.
• The integration suite adds ~[X] min to every CI run and is our #1 source of
  reruns — it's been costing us more time than it's been saving.
• At this point the maintenance cost is outrunning the signal we get from it.

What changes for you:
• CI gets faster and stops failing for reasons unrelated to your diff.
• Unit tests are now the bar for merge. If you're touching a boundary
  (DB, external API, auth, message queues), please make sure the unit tests
  around it are real tests and not just mock-assertions.
• [Staging / manual QA / canary — whatever your pre-prod gate is] is now the
  last check before prod, so treat it accordingly.

Two things I want to be honest about:
• This does mean we lose coverage of the seams between services. If you think
  there's a specific integration path we can't afford to stop testing, say so
  in this thread by [DATE] — I'd rather keep three targeted tests than pretend
  the risk is zero.
• We're keeping the suite in git history, so this is reversible if we start
  seeing a class of bugs that only integration tests would have caught. I'll
  check in on escaped-defect counts in [4-6 weeks].

Questions welcome here or in DM.
```

Two notes on the draft: I kept the "here's what we're giving up" section because an announcement that claims zero downside invites people to argue the premise instead of the decision, and because it gives you a documented out if something escapes to prod later.

If you'd rather send a version that quarantines the flaky tests and keeps a thin critical-path suite — same speed win, most of the safety net — say the word and I'll write that one instead.

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
    """Load a TOML config file and verify it declares a supported version.

    Args:
        path: Path to the TOML file, as a str or os.PathLike.
        strict: If True, the file must declare a ``version`` key. If False,
            a missing key is tolerated at this check but still fails the
            version comparison below.

    Returns:
        dict: The parsed config, with ``version`` guaranteed to be 2.

    Raises:
        ConfigError: If ``version`` is missing (when strict) or is not 2.
        FileNotFoundError: If path does not exist.
        tomllib.TOMLDecodeError: If the file is not valid TOML.
    """
    data = tomllib.loads(Path(path).read_text())
    if strict and "version" not in data:
        raise ConfigError(
            f"{path}: missing required key 'version' (expected 2); "
            f"pass strict=False to skip this check"
        )
    if data.get("version") != 2:
        raise ConfigError(
            f"{path}: unsupported config version {data.get('version')!r}, expected 2"
        )
    return data
```

One thing worth deciding: with `strict=False` and no `version` key, the second check still fails — it just reports `unsupported config version None`. So `strict=False` doesn't actually make the key optional; it only changes which message you get. I documented it that way rather than changing the behavior, but if the intent was for `strict=False` to allow unversioned configs, the second check needs to be `if "version" in data and data["version"] != 2`.
