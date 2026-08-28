# Example 1 — The third slip

| | |
|---|---|
| **Shape** | Reset |
| **Gap type** | 8 (estimate miss), secondary 1 (iceberg) |
| **Audience** | Non-technical VP Product who has already committed the date to the CEO |
| **Format** | 1:1 talking points plus a written follow-up built to be forwarded |
| **Time pressure** | 1:1 at 9am tomorrow — enough room for a full four-round interview |

## Scenario

A backend engineer at a Series-B payments company owns a transaction reconciliation engine. The
engine was scoped in June with a four-week estimate, moved to Aug 15, then to Sept 30. Sept 30 is
now on a board slide and the VP Product has told the CEO it lands end of quarter. It will not. The
engineer has a 1:1 at 9am tomorrow and opens the session with a percentage.

---

## The session

**Engineer:**
> I need help with a conversation tomorrow. The reconciliation engine isn't going to make Sept 30
> and this is the third time I've moved this date. My VP is not technical and he already told the
> CEO it's done end of quarter. I'm about 85% done but the last bit is ugly.

**Skill — Phase 0, intake:**
> Most of the intake is already in what you said, so I'm not going to re-ask it. Reset shape,
> non-technical VP Product, 9am tomorrow, and the date is public upward. Two things I still need:
>
> - Format — I'd default to 1:1 talking points plus a short written follow-up he can forward.
>   Does that match how he works?
> - When you say he's not technical: does he know what reconciliation *is*, in business terms, or
>   does the brief have to explain the product too?
>
> One flag before we go further. I'm going to refuse the 85%. A percentage is the thing that got
> you here — it's how "four weeks" became Aug 15 became Sept 30. Everything I write will come from
> an enumerated list of what works and what doesn't.

**Engineer:**
> Talking points plus something written is right — he will forward whatever I send him, that's
> guaranteed. He understands reconciliation fine as a concept: matching what the payment providers
> say they paid us against what our ledger says. He has no idea what's inside it.

**Skill — Phase 1, round 1 (dimensions A and B):**
> 1. What works end-to-end today — what could you show him tomorrow morning, on real data, with no
>    hand-holding?
> 2. What is actually left? Enumerate it. No percentage.
> 3. Where did Sept 30 come from originally, and how public is it now — has he committed it to the
>    CEO, a customer, a board slide?
> 4. What does he believe the *state* is right now, not the date — if someone asked him today, what
>    would he say the team is doing?

**Engineer:**
> 1. It reconciles Stripe, Adyen and our internal ledger. It has been running nightly against real
>    production data for two weeks. Zero unexplained discrepancies in that window. I could show him
>    last night's run.
> 2. PayPal. Wire transfers. And the ops review screen for anything that doesn't auto-match.
> 3. It came from me. I said four weeks in June. Then Aug 15. Then Sept 30. Sept 30 went on a board
>    slide about three weeks ago.
> 4. He thinks we're in testing. He thinks the build is done and we're shaking out bugs.

**Skill:**
> That last answer is the real problem, more than the date. He believes the remaining work is
> verification of finished work. It isn't — two of five sources aren't built. If he walks into the
> 1:1 with "in testing" in his head, every number you give him sounds like padding.
>
> Also worth naming now: the two weeks of clean nightly runs on real production data is the
> strongest thing you have, and it's currently invisible to him. That goes first in the brief.

**Skill — Phase 1, round 2 (dimensions C and D):**
> 1. What did you discover that you did not know when Sept 30 was set — specifically, and when did
>    you learn it?
> 2. Was the June estimate ever realistic, or was it under-scoped from day one? I need the honest
>    answer, because the brief is different depending on which it is.
> 3. Third reset. Were warnings given before the earlier two, and is this one landing cold?
> 4. Was AI or any tooling ever part of the expectation that this would go fast?

**Engineer:**
> 1. Every other source gives us a stable per-transaction ID to match on. PayPal's settlement file
>    generates a new ID every time the report is run, so there is nothing stable to hold onto — we
>    have to match on amount plus timestamp plus merchant reference and then resolve the collisions.
>    Wire transfers are worse: the reference field is free text a human typed. I found this out on
>    Aug 20, when the first real PayPal settlement file arrived. Before that I only had their
>    sandbox, and the sandbox *does* have stable IDs.
> 2. It was never realistic. I scoped it assuming all five sources behave like Stripe. That's on me.
> 3. I warned him properly before the second slip. This one is semi-cold. I said "PayPal is being
>    annoying" in a standup once. That's it.
> 4. No. Nobody ever said that. It has never come up on this project.

**Skill:**
> Question 4 was a miss — I asked it because it's on my checklist, not because anything you said
> pointed at it. Dropping it.
>
> The rest changes the diagnosis. Two things are true at once and the brief has to hold both: your
> June estimate was wrong for a reason you own, *and* the specific thing that broke it was not
> knowable in June, because the vendor's test environment behaves differently from their production
> files. If you lead with the second one it reads as an excuse. If you lead with the first and then
> state the second as a finding, it reads as a scout report. That's the order I'll write it in.

**Skill — Phase 1, round 3 (dimension E):**
> 1. First instinct: what date?
> 2. Now the real one. What date would you bet your weekend on — where if it slipped, you'd be
>    genuinely surprised rather than quietly unsurprised?
> 3. Is there a real drop-dead date behind this, as opposed to the aspirational one?
> 4. What do you actually need from him tomorrow?

**Engineer:**
> 1. Oct 24.
> 2. Nov 7. Oct 24 is the one where nothing goes wrong.
> 3. Yes. Northwind's contract renewal is Nov 15 and reconciliation is written into the renewal
>    terms.
> 4. A decision on whether we ship part of it, and I need him to tell the CEO now instead of on
>    Sept 29.

**Skill:**
> Oct 24 is gone. Nov 7 is the date, and it goes in every deliverable — this is the third reset, so
> the new number has to be the conservative one or it buys nothing.
>
> Nov 7 to Nov 15 is eight days of margin against a contract renewal. That's tight and he needs to
> see the margin rather than discover it. It also makes the case for telling the CEO this week
> instead of Sept 29 without you having to argue for it.

**Skill — Phase 1, round 4 (the partial-ship option and the gaps):**
> 1. Stripe, Adyen and the ledger — what share of volume is that, and would shipping those three on
>    Oct 1 genuinely help ops, or is it a consolation prize?
> 2. Can ops actually use those three without the review screen?
> 3. Does adding a person move Nov 7?
> 4. Two facts I need before I can use them: has the CEO repeated Sept 30 since the board slide,
>    and what is the Northwind renewal worth?

**Engineer:**
> 1. Stripe and Adyen are 92% of transaction volume. And yes, it would genuinely help — ops does
>    month-end close by hand today.
> 2. Nothing has failed to match in two weeks, so today there would be nothing for that screen to
>    show. If something did come up I'd have to pull it by hand. I don't know how often that would
>    happen once it's running on everything.
> 3. No. The PayPal matching logic is in one person's head and onboarding someone costs two weeks.
>    The work is sequential.
> 4. I don't know on either. I have no idea if the CEO has said it again, and I don't know what
>    Northwind pays.

**Skill:**
> Handling those two unknowns separately, because they get different treatment.
>
> The Northwind number is out. I'm not putting a contract value in a brief when you don't know it,
> and you don't need it — "reconciliation is in the renewal terms, and the renewal is Nov 15" does
> the entire job.
>
> Whether the CEO has repeated Sept 30 is worth ten minutes of your evening. If it's been said
> again, the "tell him this week" ask stops being a suggestion. If you can't find out, ask the VP
> directly in the 1:1 rather than assuming — it's a question he can answer instantly and it makes
> the ask his idea.
>
> One more, then I'll draft.

**Skill:**
> 1. Ops has never used this. Is Oct 1 a release to ops, or a demo to ops?
> 2. Can PayPal and wires be split, so there's a middle option between Oct 1 and Nov 7?
> 3. What will be demonstrably true at a midpoint, and on what date?

**Engineer:**
> 1. Release. They'd use it for the October close.
> 2. PayPal comes before wires either way. But I'm not putting a date on a PayPal-only release
>    until I've run the collision matching against a full month of real settlement files.
> 3. Same answer, and I don't want to hand him a fourth date I haven't earned. What I can tell you
>    is the next real proof point is PayPal reconciled against a full month of live settlement data.
>    I don't know what day that lands.

**Skill:**
> Then the checkpoint is an event, not a date, and I'll write it that way: he sees the PayPal result
> the day it runs, and he gets a Friday line every week regardless. That's weaker than a dated
> milestone and I'd rather have it be weaker and true. The Friday cadence carries the trust here.
>
> Enough to write.

**Skill — Phase 2, diagnosis:**
> Dominant gap: **estimate miss (8)**. You set the expectation yourself, three times, and the fix is
> one clean sentence of ownership plus a corrected number that is visibly built differently.
>
> Secondary: **iceberg (1)** — the remaining 8% of volume is where all the difficulty is
> concentrated, which is exactly the shape a non-technical manager finds least intuitive. It gets
> one sentence, no more.
>
> No analogy. For an estimate miss a metaphor reads as cushioning, and after three slips cushioning
> is the last thing that helps you.

---

## Deliverables

### 1. Headline

> Reconciliation covers 92% of transaction volume from Oct 1; the last 8% lands Nov 7. Third date —
> here's why this one is built differently.

### 2. 1:1 talking points (6 lines)

> 1. The engine reconciles Stripe, Adyen and our ledger against real production data every night,
>    and has for two weeks with zero unexplained discrepancies. That's 92% of transaction volume.
> 2. It will not be all five sources on Sept 30. My date for the full thing is Nov 7.
> 3. This is the third date I've given you, so let me name the pattern: I scoped this in June
>    assuming all five sources behave like Stripe. Four do. PayPal doesn't, and I could only find
>    that out on Aug 20 when the first real settlement file arrived.
> 4. The decision I need from you: release the 92% to ops on Oct 1, or hold everything until Nov 7.
>    I'd release.
> 5. The one ask: the CEO should hear Nov 7 this week, not on Sept 29.
> 6. Nov 7 leaves eight days before the Northwind renewal on Nov 15, which is the date that actually
>    matters.

### 3. Written follow-up (247 words)

> **Subject: Reconciliation — 92% of volume ready Oct 1, full coverage Nov 7**
>
> [Name] — this morning, in writing.
>
> **Where it stands:** the engine reconciles Stripe, Adyen and our internal ledger. It has run
> nightly against real production data for two weeks with zero unexplained discrepancies. Those
> three are 92% of transaction volume.
>
> **What changed:** I scoped this in June assuming all five sources behave the same way. Four do —
> each payment carries a stable reference we can match on. PayPal's settlement file issues a new
> reference every time the file is generated, so there is no stable identity to match against; each
> payment has to be identified by amount, time and merchant reference, and the ones that look
> identical have to be untangled. Wire transfers arrive with a reference someone typed by hand. I
> confirmed this on Aug 20, when the first real PayPal file arrived — their test environment does
> issue stable references.
>
> **On the date:** my June estimate was wrong, and this is the third date I've given you. Nov 7 is
> built from work completed rather than work imagined. It leaves eight days before the Northwind
> renewal on Nov 15.
>
> **Decision for you:** release the 92% to ops for the October close, or hold everything to Nov 7.
> Ops closes the month by hand today, so I'd release.
>
> **One ask:** the CEO should hear Nov 7 this week, not on Sept 29.
>
> Next update Friday, same day if anything moves Nov 7.

### 4. The forwardable line

> "Reconciliation goes live for 92% of our transaction volume on Oct 1, with the remaining payment
> methods complete Nov 7 — eight days ahead of the Northwind renewal."

### 5. Hard-questions prep

**"I already told the CEO it's done this quarter. What am I supposed to say?"**
> "Use this: reconciliation goes live for 92% of volume Oct 1, the rest Nov 7, ahead of the Northwind
> renewal. And I'd rather he hears it from you this week than notice it on Sept 29. Has he repeated
> the date since the board slide?"

**"Why am I only hearing this now?"**
> "I confirmed it Aug 20 and I said 'PayPal is being annoying' in one standup, which was not enough
> and I know it. What changes: you get a written line from me every Friday, and same-day if the date
> moves. Nothing about this lands on you cold again."

**"Can we put more people on it?"**
> "Not on this part. The matching logic for PayPal is in one person's head and anyone new costs two
> weeks of ramp-up before they contribute, and the work runs in sequence anyway. The version of more
> people that would help is taking something else off my plate, not adding someone to this."

**"Can you give me anything by Sept 30?"**
> "Effectively yes — Oct 1, ops gets Stripe, Adyen and the ledger for the October close. That is 92%
> of volume and it replaces work they do by hand today. I'd rather you hear Oct 1 and have it be
> true than hear Sept 30 for a fourth time."

**"How sure are you about Nov 7?"**
> "About 80%. Oct 24 is the version where nothing goes wrong, and I'm not giving you that one. What
> would move Nov 7 is the wire transfers, where the reference is free text a person typed. You'll
> hear from me every Friday either way."

**"So what have you been doing since June?"**
> "The engine is built and it's reconciling 92% of our volume against production data every night
> with nothing unexplained. What I mis-sized is the two sources that don't identify their
> transactions the way the others do. Here's the corrected plan."

### 6. Personal do-not-say list

| Don't say | Say instead |
|---|---|
| "I'm about 85% done." | "Three of five sources reconcile production data nightly — 92% of volume. The two left are the hard two." |
| "The last bit is ugly." | "The remaining sources don't give us a stable reference to match on. That's the work, and it's why it's slow." |
| "PayPal is being annoying." | "PayPal's file doesn't carry a stable transaction reference. That's a real difference from the other four." |
| "I should have caught this in June, I'm sorry." | "My June estimate assumed all five sources behave alike. That's the miss, and Nov 7 is built differently." |
| "It should be fine by early November." | "Nov 7, at about 80%. Wire references are what would move it, and you'll hear from me Friday either way." |

### 7. Friday update skeleton

> **Reconciliation — Friday line**
> Oct 1 release: on track / at risk because X.
> PayPal: full-month settlement run done / not yet — result attached the day it runs.
> Wires: not started / in progress / matching.
> Nov 7: unchanged / moved, and why.

---

## What this run shows

- **The opening message had the wrong problem in it.** The engineer led with the date. The interview
  surfaced that the VP believes the team is "in testing" — that two of five sources aren't built is
  news, not a schedule adjustment. That answer reordered the whole brief.
- **The percentage refusal worked, and it worked early.** Refusing "85%" in Phase 0 forced an
  enumerated answer in round 1, which is where 92%-of-volume came from — the single number the brief
  is built on. It was never in the engineer's framing.
- **"Bet your weekend" moved the date 14 days**, Oct 24 to Nov 7, and the engineer's own gloss ("Oct
  24 is the one where nothing goes wrong") is better evidence than the date itself. On a third reset
  this is the difference between a brief that helps and a fourth conversation.
- **The skill has no instruction for handling "I don't know."** The engineer didn't know whether the
  CEO had repeated the date, or what Northwind pays. Phase 4 says don't invent, but nothing tells you
  what to do instead. Improvised: drop one as unnecessary, convert the other into a pre-meeting
  verification task with a fallback of asking the manager directly. That routing should be in the
  skill, not left to the model.
- **The AI question in dimension C fired on a project with no AI angle** and burned a slot in a batch
  of four. It's written as an unconditional bullet; it should be gated on the expectation actually
  involving tooling speedup.
- **Phase 4 asks for "checkpoint dates" and got an event instead.** The engineer refused to give a
  midpoint date, correctly. The skill accepted "you'll see the PayPal result the day it runs" plus a
  Friday cadence, but that substitution isn't sanctioned anywhere in the skill — and the checklist's
  "exactly one primary anchor" is also awkward here, since a partial-ship brief has two dates (Oct 1
  and Nov 7) and the skill doesn't say which one is the anchor.
- **Nothing in the skill tells you how to word a third reset.** Dimension D says a third reset "needs
  a fundamentally more conservative new date and an explicit acknowledgment of the pattern," but no
  phrasing pattern exists for that acknowledgment, and the hard-question bank has no "this is the
  third time" entry. Talking point 3 and the "so what have you been doing since June" answer were
  written from scratch.
