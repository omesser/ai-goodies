# Example 1 — The third slip

| | |
|---|---|
| **Shape** | Reset |
| **Gap type** | 8 (estimate miss), with 1 (iceberg) as the secondary that changes the plan |
| **Audience** | Non-technical VP Product who has already told the CEO the date, and who forwards everything |
| **Format** | 1:1 talking points plus a written follow-up built to survive being forwarded |
| **Time pressure** | 1:1 at 9am tomorrow — room for a full four-round interview |

## Scenario

A backend engineer at a Series-B payments company owns a transaction reconciliation engine. It was
scoped in June off the engineer's own four-week estimate, moved to Aug 15, then to Sept 30. Sept 30
is now on a board slide, and the VP Product has told the CEO it lands end of quarter. It will not.
The engineer has a 1:1 at 9am tomorrow and opens with a completion percentage.

---

## The session

**Engineer:**
> I need help with a conversation tomorrow. The reconciliation engine isn't going to make Sept 30
> and this is the third time I've moved this date. My VP is not technical and he already told the
> CEO it's done end of quarter. I'm about 85% done but the last bit is ugly.

**Skill — Phase 0, intake:**
> Most of intake is already in what you said, so I won't re-ask it: reset shape, non-technical VP
> Product, conversation tomorrow, and the date is already public upward. Three things I still need:
>
> 1. Format. My default is 1:1 talking points plus a short written follow-up. Does that match how
>    he works?
> 2. What time tomorrow — that sets how much interview I can afford.
> 3. When you say non-technical: does he know what reconciliation does in business terms, or does
>    the brief have to explain the product as well as the delay?
>
> And one flag now, so it doesn't surprise you later: I'm going to refuse the 85%. A percentage is
> the instrument that produced this situation — it's how "four weeks" became Aug 15 became Sept 30.
> Nothing I write will contain one. We'll replace it with an enumerated list of what works and what
> doesn't.

**Engineer:**
> 9am. Talking points plus something written is right — he forwards everything, so whatever I send
> him will end up in someone else's inbox. On how non-technical he is, I don't know. I've never
> watched him explain reconciliation to anyone. I don't know how deep it goes.

**Skill:**
> Then I'll assume zero mechanism and write so it reads correctly either way: no internal terms, and
> the one place where the product has to be explained gets explained in a clause, not a paragraph.
> That costs nothing if he already knows. I'm not sending you off to find out — it's 9am tomorrow
> and that answer wouldn't change the draft.
>
> Four questions, round one, all about what he believes right now.
>
> 1. What exactly does he believe today — is it just the date, or does he also believe something
>    about the state of the work?
> 2. Where did Sept 30 come from — your estimate, a demo, someone else's promise?
> 3. How public is it? You said he told the CEO. Anywhere else?
> 4. Is there a real drop-dead date behind the aspirational one, or is Sept 30 the only date in
>    play?

**Engineer:**
> 1. He believes it ships Sept 30 and that we're in testing. He thinks the build is finished and
>    we're shaking out bugs.
> 2. Mine. I said four weeks in June. Then Aug 15. Then Sept 30. This is the third reset.
> 3. It's on a board slide from three weeks ago.
> 4. Yes. The Northwind contract renews Nov 15 and reconciliation is written into the renewal terms.

**Skill — Phase 1, round 1 debrief:**
> Stop on the first one, because it's bigger than the date. He thinks you're in testing. Testing
> means the thing exists and is being polished. If two of five payment sources aren't built, "we're
> in testing" is false, and every plan he's made downstream of it — including what he told the CEO —
> is built on it. Correcting that belief is now part of the job, and it has to happen in the same
> breath as the new date or he'll hear the date and keep the wrong picture.
>
> The board slide raises the stakes but doesn't change the content. Northwind on Nov 15 is the
> anchor that actually matters, and I'll come back to it once I have a date from you.
>
> Round two. This is where I take the 85% apart.
>
> 1. What works end-to-end today — what could you demo right now, with no hand-holding?
> 2. What is honestly left? Enumerated, not as a fraction.
> 3. What specifically did you discover that you didn't know when you set Sept 30, and when?
> 4. Was the June estimate ever realistic?

**Engineer:**
> 1. Stripe, Adyen and our internal ledger reconcile against each other. It's been running nightly
>    against real production data for two weeks. Zero unexplained discrepancies. Ops hasn't touched
>    it yet.
> 2. PayPal. Wire transfers. And the ops review screen for anything that doesn't auto-match.
> 3. Every other provider gives a stable per-transaction ID to match on. PayPal's settlement file
>    generates a new ID every time the report is run, so there's nothing stable — matching has to be
>    amount plus timestamp plus merchant reference, then resolve the collisions. Wires are worse:
>    the reference field is free text a human typed. I found this Aug 20, when the first real PayPal
>    settlement file arrived. Before that I only had the sandbox, and the sandbox does have stable
>    IDs.
> 4. No. It was under-scoped from day one. I assumed all five sources behave like Stripe. That's on
>    me.

**Skill — Phase 1, round 2 debrief:**
> That's the whole brief, and none of it was in your opening message. "The last bit is ugly" is
> three unbuilt things and one genuinely hard matching problem. Two weeks of nightly production runs
> with zero unexplained discrepancies is the strongest fact you have and you led with a percentage
> instead.
>
> The sandbox detail matters more than you're treating it. "I didn't know" sounds like carelessness.
> "The test version PayPal gives you has stable IDs and the live one doesn't" is a fact about the
> world that a reasonable person could not have found before the first real file arrived. Both are
> true. Only one of them is useful, and it isn't an excuse — it's the reason your new date is built
> on better information than the last two.
>
> Round three.
>
> 1. Were early warnings given, or is this landing cold?
> 2. Those three working sources — what share of transaction volume do they cover?
> 3. Can ops actually use those three without the review screen, or is the screen the thing that
>    makes them usable?
> 4. What's the credible date for the complete engine? Not the date you think he wants.

**Engineer:**
> 1. I warned properly before the second slip. This one is semi-cold — I said "PayPal is being
>    annoying" in a standup once.
> 2. Stripe and Adyen together are 92% of transaction volume.
> 3. They can use them. Nothing has failed to match in two weeks, so there'd be nothing for the
>    screen to show. If something did come up I'd pull it by hand. I don't know how often that
>    happens at full scale.
> 4. Oct 24.

**Skill — Phase 1, the date pushback:**
> Two follow-ups before I accept Oct 24.
>
> First: would you bet your weekend on Oct 24? If it slips, you're working the weekend of the 25th
> to make it true.

**Engineer:**
> No. Oct 24 is the one where nothing goes wrong. Nov 7 is the one I'd bet on.

**Skill:**
> Nov 7 is the date in the brief, and Oct 24 doesn't appear as a promise anywhere. It does appear
> once — as the optimistic date you're deliberately not giving him. Saying the padding out loud is
> what makes a fourth date credible after three misses.
>
> Nov 7 also lands eight days before Northwind renews on Nov 15. That's worth saying explicitly,
> because his first fear on hearing "November" will be the contract.
>
> Second follow-up, and it's the one he'll ask first. Round four:
>
> 1. Does more people help?
> 2. Is there a faster route — anything to buy, any product that does this? What have you actually
>    evaluated, as opposed to assumed?
> 3. What do you need from him — a decision, air cover, an escalation, or nothing?
> 4. What will be demonstrably true at the next checkpoint?

**Engineer:**
> 1. No. The PayPal matching logic is in one person's head, onboarding costs two weeks, and the work
>    is sequential anyway.
> 2. There's nothing to buy. This is bespoke matching logic against one provider's file format. And
>    to be accurate: I haven't evaluated anything else. That's a judgment, not a comparison.
> 3. A decision on whether we ship partial. And I need him to tell the CEO now, not on Sept 29.
> 4. Ops does month-end close by hand today. If the three live sources ship Oct 1, they stop doing
>    that for 92% of volume.

**Skill:**
> The distinction you drew on the second one is exactly right and it stays in the brief in your
> words: nothing evaluated, and you say so rather than implying a comparison. A manager who later
> discovers a claimed evaluation didn't happen loses more trust than one who hears "I haven't
> looked."
>
> Two last questions, then I write.
>
> 1. Has the CEO repeated Sept 30 to anyone since the board slide?
> 2. What is the Northwind renewal worth?

**Engineer:**
> I don't know, on both.

**Skill — routing the unknowns:**
> Neither gets guessed and neither gets dropped, because both belong to him rather than to you.
>
> - Whether the CEO has repeated the date is the thing that determines how fast he has to move. It's
>   his information, so it becomes a question you ask him in the room, right after the ask. It does
>   not go in the written follow-up — that document gets forwarded, and you don't want a sentence in
>   it implying the CEO has been saying something wrong in public.
> - The Northwind number is also his. It decides whether an eight-day buffer is comfortable or
>   terrifying, and you can't make that call for him. Same treatment: asked out loud, absent
>   from the written version.
>
> Nothing in either deliverable will assert anything about either one.

**Skill — Phase 2, diagnosis:**
> Dominant gap type: **8, estimate miss.** You said four weeks; the number was wrong because the
> scope was wrong; that gets owned in exactly one sentence and then the brief moves to the corrected
> number and why it's more trustworthy than the last three. The playbook is explicit that estimate
> miss takes no analogy — a metaphor here reads as cushioning.
>
> Secondary: **1, iceberg**, and it earns its place because it changes the plan rather than just the
> framing. The visible part — three sources reconciling nightly — is what he's been shown. The
> invisible part is that two providers don't hand out stable identifiers, and that's most of the
> remaining work.
>
> There's a third thing that isn't a gap type at all: he believes you're in testing. That's a
> factual correction, and it goes in the brief as one line rather than as a theme.

**Skill — Phase 3, translation notes:**
> Four decisions before drafting, so you can veto any of them.
>
> - **The number that ships is 92% of transaction volume**, never a completion percentage. It has a
>   denominator built in, and it converts "partial" from a compromise into a quantity.
> - **No blame, including on PayPal.** "PayPal's file doesn't carry a stable identifier" is a fact.
>   "PayPal is being annoying" is a complaint, and it's also what you already said in standup, which
>   is why nobody heard it as a risk.
> - **The upward line stays.** The cut order says to drop it when the manager forwards the brief
>   itself, and he does. I'm keeping it anyway, because your ask is specifically that he tell the
>   CEO — that's a sentence he has to say out loud, not forward. It's the one place where the
>   rule and the situation disagree, and the situation wins.
> - **The third-reset acknowledgment lives in the spoken version**, in full. The written one carries
>   one clean ownership sentence. That isn't softening: the VP is the person who needs to hear the
>   pattern named, and he's the one hearing it. Nobody downstream of a forward needs your third
>   apology, and a forwarded document that leads with a pattern of misses invites a conversation
>   about you instead of about the plan.

---

## Deliverables

### 1. Headline (23 words)

> Reconciliation won't be complete Sept 30. Three of five sources are production-ready now; the full
> engine is Nov 7. One decision for you.

### 2. 1:1 talking points (6 lines)

1. Reconciliation will not be complete on Sept 30. Three of the five payment sources are
   production-ready today; the complete engine is Nov 7.
2. What's solid: Stripe, Adyen and our internal ledger have reconciled against each other every
   night for two weeks on real production data, with zero unexplained discrepancies. Those three are
   92% of transaction volume.
3. One correction before the rest: we're not in testing. PayPal, wire transfers, and the review
   screen ops uses for anything that doesn't match automatically are not built yet.
4. Why: PayPal's live settlement file gives every transaction a new identifier each time the report
   runs, so there's nothing stable to match on — we found that Aug 20, when the first real file
   arrived; the test version PayPal provides does have stable identifiers. Wire references are free
   text typed by a person. My June estimate assumed all five sources behaved like Stripe. It was
   wrong, and this is the third date I've moved.
5. Nov 7 is the date I'd bet my weekend on. Oct 24 is the one where nothing goes wrong, and I'm not
   giving you that one. Northwind renews Nov 15, so Nov 7 leaves eight days.
6. Decision for you: ship the three live sources Oct 1 so ops stops closing the month by hand for
   92% of volume, and finish the rest by Nov 7 — or hold everything to Nov 7. I'd take the first.
   And I'd like the CEO to hear this from you this week, not on Sept 29.

**Two questions to ask him in the room** (not in the written version): has the CEO repeated Sept 30
to anyone since the board slide? And what is the Northwind renewal worth — that decides whether
eight days of margin is comfortable.

### 3. Written follow-up (email, 250 words — the first draft ran 290 and was trimmed to the cap)

> **Subject: Reconciliation — Sept 30 update and one decision for you**
>
> [Name] — ahead of our 9am, in writing so you can forward it.
>
> **Where it stands:** reconciliation will not be complete on Sept 30. Three of the five payment
> sources — Stripe, Adyen and our internal ledger — are production-ready now and cover 92% of
> transaction volume. They have reconciled real production data every night for two weeks with zero
> unexplained discrepancies. The complete engine is Nov 7.
>
> **One correction:** we are not in a testing phase. PayPal, wire transfers, and the screen ops uses
> to review anything that doesn't match automatically are still to be built.
>
> **What we found:** PayPal's live settlement file assigns each transaction a new identifier every
> time the report is generated, so there is no stable value to match on. Their test version does,
> and the first live file reached us Aug 20. Wire references are free text typed by a person. My
> June estimate assumed all five sources behaved like Stripe; it was wrong.
>
> **Plan:** Nov 7 for the complete engine — the conservative date, not the optimistic one. Northwind
> renews Nov 15, so this lands eight days ahead.
>
> **Your decision:** release the three live sources Oct 1, so ops stops closing the month by hand,
> and complete the rest by Nov 7 — or hold everything until Nov 7. I recommend the first.
>
> **If it's useful upward:** "Reconciliation covers 92% of transaction volume from Oct 1; the last
> two payment sources land Nov 7, ahead of the Northwind renewal."
>
> Next update Friday, same-day if anything moves Nov 7.

### 4. Hard-questions prep

**"Why am I only hearing this now?"**
> "I confirmed it Aug 20, when the first live PayPal file arrived — before that I only had their
> test environment, which behaves differently. I mentioned PayPal was giving us trouble in a
> standup, and that clearly wasn't enough for you to plan around. From here you get a written risk
> line from me every Friday, so nothing lands on you cold again."

**"This is the third time. Why should I believe Nov 7?"**
> "Fair. The first two dates came from work I hadn't done yet. This one is built on three sources
> that are finished and running nightly, and on a problem I've now fully characterized rather than
> guessed at. It's also the conservative version — my optimistic date is Oct 24 and I'm not giving
> you that one. If Nov 7 moves, you'll hear it the week I know."

**"Can't we put more people on it?"**
> "It wouldn't move Nov 7. The matching logic is in one person's head, someone new costs about two
> weeks of ramp-up before they contribute, and the remaining work is sequential — the review screen
> can't be built until the matching it displays exists."

**"Can't we buy something that does this?"**
> "There's nothing to buy that I know of — this is matching logic written against one provider's
> file format. To be straight with you: I haven't run an evaluation. That's my judgment, not a
> comparison. If you want me to spend a day proving it, say so and I will."

**"If we ship Oct 1 without the review screen, what breaks?"**
> "The review screen exists to show ops anything the system couldn't match on its own. In two weeks
> of nightly production runs there hasn't been a single one, so there'd be nothing to show. If one
> appears, I'll handle it by hand. What I can't tell you is how often that happens at full volume —
> nobody's run it at full volume yet. That's the honest risk in the Oct 1 option, and it's a risk
> ops absorbs for a month, not a customer-facing one."

### 5. Personal do-not-say list

| You're likely to say | Say instead |
|---|---|
| "I'm about 85% done." | "Three of five sources are production-ready; two aren't built yet." |
| "The last bit is ugly." | "The remaining work is PayPal and wire transfers, where there's no stable identifier to match on." |
| "PayPal is being annoying." | "PayPal's settlement file doesn't carry a stable identifier. Our matching has to work around that." |
| "I should have caught this in June, I'm really sorry, I know this keeps happening." | One sentence, then stop: "My June estimate assumed all five sources behaved like Stripe. It was wrong." |
| "I'll try to pull it in — hopefully sooner." | "Nov 7 is the date I'd bet my weekend on. If it comes in earlier, you'll hear that on a Friday." |

### 6. The promised follow-up (Friday skeleton)

> **Reconciliation — week of [date]**
>
> - Nov 7: holds / moved (if moved, the new date and the reason, same week I know it).
> - Done this week: [the specific thing, named — not "progress on PayPal"].
> - The one risk that could move Nov 7 this week: [risk], resolves by [day].
> - Oct 1 partial ship: on track / shipped / anything ops has hit.

First one goes out this Friday whether or not anything changed. A Friday with nothing to report is
the point — it's what makes the Friday with something to report believable.

---

## Phase 4 checklist, as verified

- **Readable aloud to a CEO** — no internal terms survive. "Settlement file" and "reconcile" are the
  customer's own vocabulary in a payments company.
- **One primary anchor** — Nov 7. Oct 1 is scope, not a competing date, and the brief says so.
- **Discovery, not excuse** — the sandbox/live difference is stated as a fact about PayPal's system,
  next to a sentence owning the estimate.
- **Explicit ask** — partial ship or hold, plus tell the CEO this week.
- **Upward line present, cadence committed** — Friday, and same-day if Nov 7 moves.
- **No blame** — PayPal is described, never characterized.
- **Every number traced** — 92%, two weeks, zero discrepancies, Aug 20, Oct 24, Nov 7, Nov 15 all
  came from the interview. Two unknowns were routed to the VP as spoken questions, and neither
  appears as an assertion.

**Iteration pass, read as the VP:** the first paragraph triggers alarm, then the 92% and the Nov 15
margin convert it into something he can act on — which is the right order. One adjustment was made
after this read: an earlier draft of the email carried "this is the third date I've moved" in the
ownership paragraph. Read as the VP forwarding it to the CEO, that sentence redirects the
conversation from the plan to the engineer. It stays in the spoken version, where the person who
needs to hear it is the person hearing it.

---

## What this run shows

- **The opening message contained none of the brief.** "85% done" and "the last bit is ugly" became:
  three sources reconciling nightly on production data for two weeks with zero unexplained
  discrepancies, covering 92% of transaction volume, and two unbuilt sources plus an unbuilt screen.
  The interview is where the entire deliverable came from.
- **The largest find was not the date.** The VP believes the team is *in testing*. The engineer
  mentioned it as background in answer to the first question of round one; correcting it became a
  dedicated line in both deliverables, because every plan the VP has made downstream depends on it.
- **"Bet your weekend" moved Oct 24 to Nov 7** — and the discarded date then earned a role of its
  own, named out loud as the optimistic version being withheld. On a third reset, that admission is
  what makes the fourth date credible.
- **The "I haven't evaluated anything" answer was preserved rather than smoothed.** The skill's ★
  ruled-out-routes question got an honest non-answer, and the brief reports the non-answer. The
  playbook's "can't we do this cheaper" pattern is written for the proposal shape, though, and the
  reset-shape phrasing here was written from scratch.
- **The cut order and the situation disagreed once.** The skill says to drop the separate upward
  line when the manager forwards the brief itself — and this VP forwards everything. But the ask
  *is* an upward-communication ask: he has to tell the CEO out loud. Keeping the line was the
  agent's call, not the skill's; the rule has no exception for "the ask is that they carry the
  message."
- **Nothing in the skill decides what to keep out of a document that gets forwarded.** The
  third-reset acknowledgment is required by dimension D and by the hard-question bank, and it's
  right for the room. In a document that will be pasted upward verbatim, the same sentence changes
  the subject from the plan to the engineer. The split — full in the spoken version, one ownership
  sentence in the written one — was improvised during the iteration pass and is a judgment the skill
  currently leaves to the agent.
- **One unknown had nowhere clean to go.** How often ops would hit an unmatched item at full
  volume is the actual risk in the Oct 1 option, and the engineer genuinely doesn't know. The
  talking-points cap has no room for it, so it survives only in the hard-questions prep — material
  the manager reads only if he asks the right question.
