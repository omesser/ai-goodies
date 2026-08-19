# Voice OFF (baseline)

`DEV_VOICE_OFF=1 claude -p`, ponytail disabled. No developer-voice in context.

Verbatim output. See [README.md](README.md) for method and analysis.

**This is the baseline — the register the skill exists to replace. Don't imitate it.**

---

## Prompt 1

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

## Prompt 2

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
