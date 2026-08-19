# Voice ON

`claude -p`, ponytail disabled. `SKILL.md` injected by the SessionStart hook.

Verbatim output. See [README.md](README.md) for method and analysis.

---

## Prompt 1

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

## Prompt 2

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
