# `explain-to-manager` — worked sessions

Five recorded runs of [`skills/explain-to-manager/`](../../skills/explain-to-manager/): the
scenario, the interview as it actually went, and every deliverable the skill produced.

Each session ran in its own agent, which invoked the skill and then played both roles — the skill
following SKILL.md, and the engineer answering from a fact sheet fixed in advance. The fact sheet is
the only source of numbers, so nothing in a deliverable is invented; where the skill asked something
the sheet didn't cover, the engineer said "I don't know" and the transcript records what the skill
did next. Every company, number, and date is fictional.

These are reading material for anyone deciding whether the skill is worth installing, and regression
material for anyone editing it — if a change makes one of these sessions worse, that's a signal.
They are **not** loaded by the skill at runtime, which is why they live here rather than inside the
skill directory. The skill carries its own compact examples in
[`references/playbook.md`](../../skills/explain-to-manager/references/playbook.md).

| # | Session | Shape | Gap type diagnosed | Audience | What it shows |
|---|---------|-------|--------------------|----------|----------------|
| 1 | [The third slip](01-third-slip-estimate-miss.md) | Reset | 8 estimate miss + 1 iceberg | Non-technical VP Product, date already on a board slide | The interview refuses "85% done" and gets 92% of transaction volume instead; "bet your weekend" moves Oct 24 → Nov 7; the real find is that the VP thinks the team is *in testing* |
| 2 | [Blocked on a vendor](02-blocked-vendor-exec-email.md) | Reset | 1 iceberg (scale) + 4 dependency drag | Skip-level COO who forwards everything | ★-compressed interview under a one-hour deadline; a 126-word exec email against a ~120-word cap; a vendor delay stated as elapsed time with no blame |
| 3 | [The untested restore](03-proposal-untested-restore.md) | Proposal | 9 insurance ask | Technical EM, cost-skeptic, behind on roadmap | Proposal interview (P1–P4); denominators for time as well as money; the analogy dropped out loud because the audience is technical; a priced alternative separated from a judgment call |
| 4 | [The observability bill](04-defense-observability-bill.md) | Defense | 10 invisible work + 9 insurance ask | CFO, via the engineer's director | Last-lapse evidence carries the case; the engineer's biggest fact ($12k/month of compute savings) surfaces as an afterthought; a $3k/month cut menu offered instead of a wall |
| 5 | [Demo to pilot](05-demo-to-pilot-spin-refusal.md) | Reset | 3 demo vs. product + 5 quality bar | Non-technical VP Sales, LOI riding on the date | The skill declines to bury the accuracy number, and the refusal surfaces the supervised pilot that turns out to be the strongest asset the engineer had |

## Coverage

All three shapes. Seven of the ten gap types: 1, 3, 4, 5, 8, 9, 10. Uncovered here are 2
(last-mile integration) and 6 (AI reality check), both of which have worked examples in the
playbook, and 7 (moving target).

Behaviors exercised:

- **Phase 0 intake** — compressed to ★ under time pressure (2), full (1, 3, 4, 5).
- **Interview pushback** — on a percentage (1), on "not all customers" (2), on an unverified
  alternative (3), on a request to drop an inconvenient fact (4).
- **The ≥80% date elicitation** — moves the date in 1 and 5.
- **Audience calibration** — all four rows of the Phase 0 table appear across the five.
- **Refusals** — the skill declines part of the request twice: hiding an accuracy number (5) and
  dropping the fact that explains a past outage (4). In both, refusing produced a stronger brief.

## What the runs found wrong with the skill

Collected from the five sessions. Each is recorded in its own file too. Nothing here is fixed —
these are findings against the skill as it stands.

| Finding | Seen in | Detail |
|---|---|---|
| No route for "I don't know" | 1, 2, 3, 4 | Phase 4 says don't invent, but nothing says what to do with a real gap. Each run improvised: drop it, convert it into a pre-meeting verification task, or hand it to the manager as an action item. That routing belongs in Phase 1. |
| "Exactly one primary anchor" breaks on tiered delivery | 1, 2 | A partial ship has two dates by construction (Oct 1 and Nov 7; Oct 15 and Nov 5). The Phase 4 checklist reads as violated on a correct brief. |
| The ~120-word exec cap fights the Phase 4 checklist | 2 | Two dates, two asks, a denominator, the date-moving risk, a cadence line, and a forwardable sentence do not fit in 120 words. The skill gives no priority order for what to cut first. |
| No guidance when the manager forwards the artifact itself | 2 | The "if it's useful upward" block becomes a message inside the message. The run wrote the first sentence as the upward line instead — a judgment the skill should make explicit. |
| Reset shape has no ★ for alternatives already ruled out | 2, 3 | "Can't we buy our way out of this?" is the first question back, and only the proposal shape's P3 asks for it. Reset's dimension E covers scope cuts, not eliminated technical options. |
| The AI question in dimension C is unconditional | 1 | It fired on a project with no AI angle and burned a slot in a batch of four. It should be gated on the expectation actually involving a tooling speedup. |
| Defense shape has no cadence requirement | 4 | The checklist demands a next-update promise for reset and proposal only. So a defense brief can end with an accepted cut and no scheduled proof that the accepted risk stayed cheap — which is the evidence that protects the rest of the spend at the next review. |
| Nothing catches "the review is asking two questions" | 4 | Phase 0 asks format, audience, timing, and shape, never whether the circled line is the real ask. Here "what does this team do" decided the budget, and the fact that answered it surfaced by luck. |
| Third-reset wording is demanded but not supplied | 1 | Dimension D requires "an explicit acknowledgment of the pattern" and the hard-question bank has no entry for "this is the third time". The run wrote it from scratch. |
| Hard word caps push required content into the prep notes | 3 | At 150 words, the counter-proposal the manager is most likely to make survives only in the hard-questions section, not in the message they actually read. |
