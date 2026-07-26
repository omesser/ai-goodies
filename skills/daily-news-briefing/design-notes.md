# Design notes

Why the constraints in `SKILL.md` are shaped the way they are, and how to change them safely.

## What each constraint is holding back

Naive versions of this briefing ("scan the news and summarize") reliably produce headline-restating and mushy investment advice. Each constraint targets one failure:

| Constraint | Failure it prevents |
|---|---|
| Explicit search strategy (step 1) | Summarizing whatever surfaced first instead of seeking expert commentary |
| The "so what" test (step 2) | Headline-restating — events listed without consequences |
| Priced-in judgment (step 3) | Market recaps that produce no leads; this is the depth that feeds ideas |
| Mispricing kill rule (step 4) | "Consider defense stocks" filler — an unnamed mispricing is not an idea |
| "Quiet day" permission (step 5) | Space-filling on slow days, which is where most generic output comes from |

Remove any of these and the corresponding failure returns within a few runs.

## Adapting

Coverage regions (step 2) and the instrument universe (step 4) are the intended knobs — swap them for your own interests. The structure is the transferable part.

## Tightening

If ideas still come back vague after a few days, upgrade the one-liner in step 4 to a full trade card — add a **catalyst** (a dated event that proves or disproves the thesis) and an **invalidation level** (the price at which the thesis is wrong) — and cut the max from 5 ideas to 3.

## Running it unattended

This was originally a paste-in prompt for a scheduled automation on a platform with native X search (Grok tasks / xAI automations). As a skill it schedules the same way: point a scheduled agent at `/daily-news-briefing`. Social coverage then depends on whatever search the host agent has — the `last30days` skill if installed, web search otherwise.
