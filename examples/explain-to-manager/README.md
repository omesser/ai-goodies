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
| 1 | [The third slip](01-third-slip-estimate-miss.md) | Reset | 8 estimate miss + 1 iceberg | Non-technical VP Product who already told the CEO the date | The interview refuses "85% done" and gets 92% of transaction volume instead; "bet your weekend" moves Oct 24 → Nov 7; the find that reshapes the brief is that the VP thinks the team is *in testing* |
| 2 | [The four accounts that can't launch](02-blocked-vendor-exec-email.md) | Reset | 1 iceberg (scale) + 4 dependency drag | Skip-level COO who forwards everything | ★-compressed interview under a one-hour deadline; a tiered launch anchored on the completing date, not the louder one; a vendor delay stated as elapsed time with no blame |
| 3 | [Three weeks to test the restore](03-proposal-untested-restore.md) | Proposal | 9 insurance ask | Technical EM, cost-skeptic, behind on roadmap | Proposal interview (P1–P4); denominators for time as well as money; the analogy dropped out loud for a technical audience; a priced alternative kept separate from a judgment call |
| 4 | [The monitoring line the CFO circled](04-defense-observability-bill.md) | Defense | 10 invisible work | CFO, via a director who presents | One slide answers both accusations by treating them as the same gap; the engineer asks to drop the January cut and the skill renegotiates it into an actorless fact rather than overriding them |
| 5 | [A demo signed an LOI](05-demo-to-pilot-spin-refusal.md) | Reset | 3 demo vs. product + 5 quality bar | Non-technical VP Sales, LOI riding on the date | The skill splits the spin request — grants "don't lead with it", refuses "leave it out" — and the refusal surfaces the supervised pilot that saves the promised date |

## Coverage

All three shapes. Seven of the ten gap types: 1, 3, 4, 5, 8, 9, and 10. Uncovered are 2 (last-mile
integration) and 6 (AI reality check), both of which have worked examples in the playbook, and 7
(moving target).

Behaviors exercised:

- **Phase 0 intake** — compressed to ★ under time pressure (2), full (1, 3, 4, 5).
- **Interview pushback** — on a percentage (1), on "not all customers" (2), on an unverified
  alternative (3), on a request to drop an inconvenient fact (4).
- **The ≥80% date elicitation** — moves the date in 1, and separates two products in 5.
- **Audience calibration** — all four rows of the Phase 0 table appear across the five.
- **Refusals** — the skill declines part of the request three times: burying an accuracy number and
  writing a customer-facing paragraph the engineer can't source (5), and dropping the fact that
  explains a past outage (4). In each, refusing produced a stronger brief.

## What these runs found wrong with the skill

Open findings against the skill as it currently stands. Each is recorded in its own session file
too.

| Finding | Seen in | Detail |
|---|---|---|
| ★-compression can't fill the Phase 4 checklist | 2 | Phase 0 says compress to ★ when the conversation is imminent; Phase 1 says stop only when every checklist item is answerable. For the reset shape, "what is blocking, and since when" and "what do you need from the manager" are both un-starred — so the vendor block, half the email's ask, surfaced only on a return trip. Nothing says which instruction wins. |
| The ~120-word exec cap is still not reachable | 2 | This run landed at 136 words and the cut order returned nothing: there was no analogy, the upward line was already folded into the first sentence, and the next-update line is protected because she forwards the brief. Two dates, two asks, a rejected alternative, and a denominator don't compress below ~135 without dropping a checklist item. |
| Phase 4 assumes a single ask | 2 | It says "an explicit ask," singular. Two asks — a decision and an escalation — got ordered by the agent's judgment. |
| "I don't know" routing has no document/verbal split | 2 | The rule routes an unknown to the manager, but not away from a document the CEO will read. Asking verbally in the sync while keeping the email forwardable was improvised. |
| The proxy presenter is uncovered | 4 | Every Phase 4 deliverable assumes the engineer is in the room: hard-questions prep is written for them to answer, and the do-not-say list is lines *they* might blurt. Here a non-technical director presents and fields the questions, so both had to be retargeted. |
| A skeleton that needs six slots has nowhere to go | 4 | Headline + 5 bullets is tight for a defense answering two accusations; two bullets run three sentences each. The cut order rescued it only because the upward line was legitimately waivable. |
| Tiered-delivery anchoring assumes one product | 5 | "The anchor is the date that completes the work" fits two scopes of one product. Here the Nov 14 supervised pilot and the later unsupervised system are different products, and the literal reading anchors the wrong one. |
| Hard word caps push required content into prep notes | 1, 3 | At 150 words the one-week fallback survives as a nine-word clause with no reasoning, reading as a discount rather than a considered option. In 1 the real risk in the partial-ship option lives only in hard-questions prep, read only if the manager asks. |
| "Don't help spin" has no trigger point | 5 | It sits under **What NOT to do** with no guidance on when to raise it. Refusing at intake, before the interview established the number or its provenance, was judgment rather than process. |
| No reset-shape pattern for "nothing was evaluated" | 1 | The ★ ruled-out-routes question fires, but the playbook's matching answer pattern is proposal-shape only. The reset phrasing was written from scratch. |
