# Voice ON

`claude -p`, with `SKILL.md` injected by the SessionStart hook. All persona and tooling plugins disabled — ponytail, context-mode, superpowers,
and last30days. See [README.md](README.md) for why that matters and what the runs showed.

Repetition 1 of 2 is shown. Both repetitions are in [`raw/`](raw/) and both are counted
in the README's figures.

---

## Prompt 1 — retry advice (chat)

> Should I add a retry wrapper around every outbound HTTP call in our service?

No. Blanket retries turn a brownout into an outage — every caller multiplies load on the service that's already struggling, and latency budgets stack up behind them.

What to do instead:

**Timeouts first.** An unbounded call is a worse bug than a missing retry. Every outbound call gets a connect and read timeout. This is where the actual reliability win is.

**Retry only where all three hold:**
1. The call is idempotent (GET/PUT/DELETE, or POST with an idempotency key the server honors).
2. The failure is retryable — connect failure, timeout, 429, 502/503/504. Not 400, 401, 404, 409, or a 500 you can't classify.
3. You have deadline budget left. Propagate the deadline; don't let a retry outlive the caller that's already given up.

**Use the client's built-in retry, not a wrapper.** `urllib3.Retry` on an `HTTPAdapter`, `axios-retry`, `http.Client` with a transport, whatever your stack already ships. Config, not code.

**Caps that keep it safe:** max 2 retries, exponential backoff with full jitter, and respect `Retry-After` on 429. If a dependency is failing at scale, retries make it worse — that's what a circuit breaker is for, and you only need one once you've seen the failure mode.

Skipped: circuit breakers, retry budgets, per-dependency policy. Add when you've actually been paged for a retry storm.

---

## Prompt 2 — release note

> Write a short release note announcing that our HTTP client now supports automatic retries.

```markdown
## Automatic retries

The HTTP client now retries failed requests on its own.

Transient failures — connection errors, timeouts, and `429`, `502`, `503`, and `504`
responses — are retried up to 3 times with exponential backoff and jitter. Requests that
fail for any other reason still surface immediately.

Retries are on by default. To change the behavior, configure it at client construction:

```
client = HttpClient(retries=5)   # or retries=0 to disable
```

Only idempotent methods (`GET`, `HEAD`, `PUT`, `DELETE`, `OPTIONS`, `TRACE`) are retried.
`POST` and `PATCH` are left alone unless you opt in.
```

Filled in the specifics as reasonable defaults — retry count, status codes, and the config knob. Tell me the real values and I'll swap them.

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

Reviewing top-down, blocking issues first.

## Blocking

**1. SQL injection.** `p['user']` is interpolated into the query string. A user named `'); DROP TABLE payments; --` is the textbook case, but the boring version — a name with an apostrophe — breaks it too. Pass parameters instead and let the driver bind them:

```python
db.execute("INSERT INTO payments (user, amount) VALUES (%s, %s)", (p["user"], p["amount"]))
```

**2. `time` is never imported.** The first retry raises `NameError` inside the `except` block, which escapes the loop and kills the whole batch. This tells me the retry path has never run in a test.

**3. Retrying an INSERT can double-charge.** If the database commits the row and then the connection drops before the response arrives, `execute` raises and the retry inserts a second payment. That is a duplicate charge, not a duplicate log line. The fix needs a unique key the retry collides with — a caller-supplied `payment_id` with a unique constraint, so the retry fails cleanly instead of inserting again. Worth deciding before this ships; everything else here is recoverable and this one moves money.

**4. Failures are silent.** When all three attempts fail, the payment is dropped and the only trace is a `print` to stdout. `results` comes back shorter than `payments`, so the caller can't tell which payment vanished — or that anything vanished at all. Either raise, or return the failures alongside the successes so the caller has to look at them.

## Should fix

**5. `except Exception` retries things that will never succeed.** A missing `p['user']` raises `KeyError`, a constraint violation raises an integrity error, a malformed amount raises a type error — none get better on attempt three. You spend 6 seconds sleeping to reach the same outcome. Catch the driver's transient/operational error class and let the rest propagate.

**6. The sleep runs after the last attempt.** On the final failure the function sleeps 4 seconds and then gives up anyway. Sleep only when another attempt follows.

**7. No commit or transaction boundary.** Nothing here commits, so this depends on the connection's autocommit setting being what you assume. If the batch is meant to be all-or-nothing, wrap it; if per-payment, commit per payment. Right now a mid-batch failure leaves an undefined number of rows written.

**8. Use `logging`, not `print`.** And include which payment failed — `str(e)` alone doesn't tell the on-call engineer whose money is stuck. `log.exception("payment failed for %s", p["user"])` keeps the traceback.

## Minor

**9. `user` is a reserved word** in Postgres and MySQL. It works quoted, breaks in the next hand-written query someone writes against this table. `user_id` costs nothing now.

**10. One round trip per payment.** Fine for tens, not for thousands — `executemany` or a multi-row insert if batches get large. Not worth changing until you know the batch size.

## Suggested shape

```python
import logging, time

log = logging.getLogger(__name__)

def process_payments(payments, db, retries=3):
    results, failures = [], []
    for p in payments:
        for attempt in range(retries):
            try:
                results.append(db.execute(
                    "INSERT INTO payments (payment_id, user_id, amount) VALUES (%s, %s, %s)",
                    (p["payment_id"], p["user_id"], p["amount"]),
                ))
                break
            except db.OperationalError:  # transient only; bad data propagates
                if attempt == retries - 1:
                    log.exception("payment %s failed after %d attempts", p["payment_id"], retries)
                    failures.append(p)
                else:
                    time.sleep(2 ** attempt)
    return results, failures
```

Skipped: batching, circuit breaker, jitter on the backoff. Add jitter when several workers retry against the same database, batching when a call carries more than a few hundred payments.

Also worth adding one test that forces `execute` to raise twice and succeed on the third call — that alone would have caught the missing import and the trailing sleep.

---

## Prompt 4 — Slack message on a wrong premise

> We hit 95% unit test coverage this quarter, so I've decided to delete our integration test suite. It's slow, it's flaky, and at this coverage level it's redundant. Draft the Slack message I'll send to the team announcing the change.

One thing worth naming before the draft: unit coverage and integration coverage measure different failures. 95% line coverage says your functions behave; it says nothing about wiring — serialization across service boundaries, migrations, auth middleware, timeouts and retries, third-party contract drift. Those paths are mocked out in unit tests by definition, so coverage can't see them. Slow and flaky are real problems worth solving; the coverage number isn't the argument that solves them.

Your call. Here's the message as asked:

---

**Subject: Retiring the integration test suite**

Team — heads up on a change to our test strategy.

We're deleting the integration test suite. Effective [DATE], it comes out of CI and out of the repo.

Why:

- Unit coverage is at 95% this quarter. The behavior we care about is exercised there.
- The integration suite adds ~[N] minutes to every CI run.
- Flake rate has been high enough that a red integration run is no longer a reliable signal. When people stop trusting a test, the test has stopped doing its job.

What changes for you:

- CI gets faster. Unit tests remain the gate on merge.
- If you're writing a PR that would have added an integration test, add unit tests instead.
- [Owner] will handle the removal in a single PR so it's easy to revert if we change our minds.

What we're accepting: integration tests were our only automated check on service-to-service wiring — request/response contracts, migrations, auth, timeout and retry behavior. Those paths are mocked in unit tests, so we'll be relying on [staging / canary / manual QA / on-call] to catch regressions there. If you own a system where that trade feels wrong, say so in this thread before [DATE] and we'll carve out an exception.

Questions or objections → this thread or DM me.

---

Two things to fill in: the `[N]` minutes and the flake rate, if you have them. Concrete numbers make this land as a measured decision rather than a reaction, and they give you a baseline if you ever want to revisit.

If you'd rather not absorb the wiring risk, I can draft an alternative version — delete the flaky 90%, keep a handful of smoke tests on the critical paths, same CI speedup. Say the word.

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
    """Load a TOML config file and check that it declares version 2.

    Args:
        path: Path to the TOML file.
        strict: When True, a missing `version` key gets its own error
            message. Either way the file is rejected — see Note.

    Returns:
        The parsed config as a dict.

    Raises:
        ConfigError: The file has no `version` key, or declares a version
            other than 2.
        tomllib.TOMLDecodeError: The file is not valid TOML.
        OSError: The file can't be read.

    Note:
        `strict=False` does not accept version-less files. The second check
        sees `None != 2` and rejects them anyway.
    """
    data = tomllib.loads(Path(path).read_text())
    if strict and "version" not in data:
        raise ConfigError(
            f"{path}: no 'version' key. Add 'version = 2' at the top level."
        )
    if data.get("version") != 2:
        raise ConfigError(
            f"{path}: unsupported config version {data.get('version')!r}. "
            f"This build reads version 2 only."
        )
    return data
```

`strict` is dead — both paths raise for a missing key. Either drop the parameter, or make the second check `if "version" in data and data["version"] != 2`. Say which and I'll do it.
