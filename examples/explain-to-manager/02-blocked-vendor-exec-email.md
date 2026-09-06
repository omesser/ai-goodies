# Example 2 — The four accounts that can't launch on the 15th

| | |
|---|---|
| **Shape** | Reset |
| **Gap type** | 1 (iceberg — scale), with 4 (dependency drag) as the secondary that earns its own ask |
| **Audience** | COO — skip-level, non-technical, forwards everything she gets to the CEO |
| **Format** | Email she forwards, capped at ~120 words by the skip-level/exec calibration |
| **Time pressure** | Sync in one hour — Phase 1 compressed to the ★ questions |

## Scenario

A data platform engineer owns a customer-facing analytics dashboard that the COO expects to launch
Oct 15, with a marketing post already written. The dashboard is live and correct, but the largest
beta account arrived with 40 times the data anything was tested against, and its queries take 9
seconds against a 2-second bar. Part of the fix sits behind a vendor setting nobody at the vendor
has answered in 9 days. The engineer has one hour before a sync with the COO.

---

## The session

**Engineer:**
> Our COO is expecting the analytics dashboard to launch Oct 15 and marketing has a post ready.
> It's not going to be all customers on the 15th. I have a sync with her in an hour. She is not
> technical and whatever I write she will forward to the CEO.

**Skill — Phase 0, intake:**
> Your message settles all four intake questions, so I'm not going to spend your hour asking them
> back:
>
> - **Shape:** reset. An existing expectation about existing work is about to change.
> - **Audience:** skip-level, non-technical, and she forwards. That is the strictest calibration in
>   the skill — zero mechanism, hard cap around 120 words, and I write assuming every sentence gets
>   pasted upward verbatim.
> - **Format:** an email. Not talking points — the artifact has to survive being forwarded without
>   you in the room.
> - **Time:** one hour, so I'm compressing the interview to the starred questions and adding only
>   what the final checklist can't do without.
>
> Four questions, then a second round.
>
> 1. What exactly does she believe is happening on Oct 15 — all customers, some, a soft launch?
> 2. What works end-to-end today that you could show her right now with no hand-holding?
> 3. What did you find out that wasn't known when Oct 15 was set?
> 4. How public is Oct 15 already? Has she or the CEO put that date in front of anyone outside the
>    company?

**Engineer:**
> 1. All customers, everyone at once, with the marketing post going out the same day.
> 2. It's been live since Sept 2 — 12 internal users and 3 beta customers using it daily. The
>    numbers are verified against finance to the dollar.
> 3. The largest beta account has about 40 times the data of anything we'd tested before. Its p95
>    query takes 9 seconds. Our bar is 2 seconds.
> 4. I don't know. I don't know what the marketing post actually says, and I don't know whether the
>    CEO has quoted Oct 15 anywhere.

**Skill:**
> Holding both of those unknowns — I'll route them at the end rather than guess, and neither one
> changes the engineering picture.
>
> "40 times the data" is the whole story, so I want the shape of the fix and the shape of the
> alternative you already rejected.
>
> 5. What's the actual fix, and is it engineering or research?
> 6. What date would you bet your weekend on for all customers? Not the date you think she wants.
> 7. What faster route have you already ruled out, and what does it miss? "Can't we buy our way out
>    of this?" is the first thing she'll ask.
> 8. Is anything blocking you right now, and since when?

**Engineer:**
> 5. Pre-computed aggregate tables. 2.5 weeks. It's plain engineering work, not research — I know
>    how to do it.
> 6. Nov 5 for all customers. That's the one I'd bet a weekend on.
> 7. Buying bigger warehouse capacity. It takes the 9 seconds to about 5. Still over the 2-second
>    bar, and it costs real money every month. Pre-computing gets under 2 with no ongoing cost.
> 8. Yes. The aggregation feature I need is behind a flag only the data-warehouse vendor can enable
>    on our tier. Ticket's been open 9 days and all I've gotten is an auto-reply. There's an account
>    exec the COO could ping.

**Skill:**
> That last answer is half the brief, and the compressed interview would have missed it — none of
> the starred questions ask what's blocking. Three more, then I write.
>
> 9. What happens if the big accounts launch on the 15th anyway?
> 10. Is there any customer segment Oct 15 does hold for?
> 11. What do you actually need from her — a decision, the escalation, or both?

**Engineer:**
> 9. A spinner on every page load. And those are the four largest accounts by revenue — the ones
>    most likely to be named in the marketing post as reference customers.
> 10. Yes. Accounts under 10 million rows are already fast. That's about 80% of customers. Oct 15
>     holds for them.
> 11. Both. A decision on tiered versus single launch, and the vendor escalation.

**Skill — Phase 1 close, routing the two unknowns:**
> I have everything the Phase 4 checklist needs. Before I draft, the two "I don't know" answers.
>
> The skill's rule is that I never close a gap myself — I drop it, hand it to the manager, or hand
> you a check to run first. You have an hour, so running down what the marketing post says isn't
> realistic. Both unknowns are hers: she owns the announcement and she is the one who talks to the
> CEO. So they go to her.
>
> But not in the email. She forwards the email to the CEO, and "has the CEO quoted Oct 15 anywhere?"
> reads very differently when the CEO is the one reading it. Ask both in the sync, out loud; the
> email carries only what survives forwarding. That split isn't something the skill tells me to do —
> it follows from the audience calibration, and I'm flagging it as a judgment call rather than a
> rule.

**Skill — Phase 2, gap diagnosis:**
> **Dominant: gap type 1, iceberg.** She believes the dashboard works because the dashboard does
> work — she's seen it, it's been live for a month, the numbers tie to finance. What's invisible to
> her is that "works" was only ever measured against data 40 times smaller than what the biggest
> customer brought.
>
> **Secondary: gap type 4, dependency drag.** The skill says to name the second type only when it
> changes the plan. It changes the plan here: it's the reason there are two asks instead of one. So
> the vendor gets one clause and no blame — elapsed days and a named path forward, nothing about
> them ignoring you.
>
> No analogy. At ~120 words an analogy costs a fifth of the budget, and "40 times the data" is
> already the plainest sentence in the brief.

---

## Deliverables

### 1. Headline (21 words)

> Oct 15 launches on schedule for about 80% of customers; our four largest accounts land Nov 5. Two
> decisions for you.

### 2. The email

> **Subject: Analytics dashboard — Oct 15 for most customers, Nov 5 for the largest four**
>
> [COO],
>
> Oct 15 holds for about 80% of customers. The dashboard has been live since Sept 2 for 3 beta
> customers, with every figure reconciled to finance to the dollar.
>
> The exception is our four largest accounts by revenue. One joined the beta Sept 2 with 40 times
> the data we had ever tested, and its pages take 9 seconds against a 2-second bar. Launching those
> four Oct 15 hands our best reference customers a spinner on every page. Pre-computed tables fix it
> in 2.5 weeks — Nov 5, a date I would bet my weekend on.
>
> Two things from you: approve the tiered launch, and ping our warehouse vendor's account exec — a
> setting only they can enable has sat 9 days without a human reply.
>
> Next update Oct 3, or the day the vendor replies.

**Body word count: 136** (`wc -w`, counting everything after the salutation; two of those tokens are
standalone em dashes, so 134 words of prose). The cap is ~120. See the notes below — the skill's cut
order had nothing left to cut.

**What the cut order removed, in the skill's stated sequence:**

- Analogy — cut first, per the rule. Saved nothing; there wasn't one.
- Separate "if it's useful upward" line — cut, because she forwards this email itself. Its first
  sentence is the upward line.
- Next-update line — kept. The rule only permits cutting it when the manager does *not* forward.

### 3. Hard-questions prep

**"Can't we just buy more capacity?"**
> Tried that math. Bigger warehouse capacity takes the slowest pages from 9 seconds to about 5 —
> still over our 2-second bar, and it's a bill we'd pay every month forever. Pre-computing gets us
> under 2 seconds with no ongoing cost. It's 2.5 weeks of ordinary engineering, not research.

**"Can't we launch everyone on the 15th and fix it after?"**
> We can. The four accounts that would be slow are our four largest by revenue, and they're the ones
> most likely to be named in the post as reference customers. Their people would see a spinner on
> every page load, in the same week we invite press to look.

**"Why am I only hearing this now?"**
> The account with 40 times the data joined the beta Sept 2. No data at that size existed anywhere
> in our system before then. The problem arrived with the customer, and you're hearing it the same
> week it became measurable.

**"How sure are you about Nov 5?"**
> Sure enough to bet a weekend on it. It's 2.5 weeks of work I know how to do. The one thing that
> moves it is the vendor setting — that's why the escalation is half my ask.

**"What exactly do the other 80% get on the 15th?"**
> The full dashboard, fast, with numbers reconciled to finance to the dollar. Same product our beta
> customers have been using since Sept 2. Nothing is held back from them.

### 4. Personal do-not-say list

| You're likely to say | Say instead |
|---|---|
| "It's not going to be all customers on the 15th." | "Oct 15 holds for about 80% of customers. The largest four land Nov 5." |
| "The vendor is ignoring us." | "A setting only the vendor can enable has been open 9 days. Your account exec is the fastest path." |
| "It's a scaling problem." | "One account has 40 times the data we'd ever tested against." |
| "We could probably make it if we throw money at capacity." | "More capacity takes 9 seconds to about 5 — still over the bar, and it's a monthly bill." |
| "Sorry, I should have caught this sooner." | "The account that exposed this joined the beta Sept 2. No data that size existed before then." |

### 5. The promised follow-up (offered)

Skeleton for Oct 3, so the cadence promise in the email actually gets kept:

> **Analytics dashboard — Oct 3 check-in**
>
> - Oct 15 broad launch: on track / at risk because ___
> - Pre-computed tables: ___ of the four accounts under 2 seconds
> - Vendor: replied / still silent — ___ days open
> - Nov 5: still the date / moved to ___ because ___

---

## What this run shows

- **The ★ set alone would have produced the wrong brief.** None of the five starred reset questions
  asks what's blocking, or what the engineer needs from the manager. The vendor flag — half the
  email's ask — surfaced only because the Phase 4 checklist requires an explicit ask and I went back
  for it. The compression rule and the stopping condition ("stop when you can answer every checklist
  item") point in opposite directions, and the checklist has to win.

- **The ~120-word exec cap did not fit this brief.** It landed at 136. The skill's cut order was
  followed and returned nothing: there was no analogy to cut, the separate upward line was already
  folded into the first sentence, and the next-update line is protected because she forwards. Two
  dates, two asks, a rejected alternative, and a denominator do not compress below ~135 without
  dropping a checklist item.

- **The "I don't know" routing rule pointed at the manager, and stopped one step short.** Both
  unknowns are hers to answer, so the rule says hand them to her. It has nothing to say about an
  unknown that is safe to ask verbally and unsafe to ask in a document the CEO will read. I split it
  — unknowns to the sync, email kept forwardable — but that's improvisation, not the skill.

- **The tiered-delivery clause in the checklist worked exactly as written.** "The anchor is the one
  that completes the work; the earlier date is scope" made Nov 5 the anchor without argument, on a
  brief where Oct 15 is the louder date.

- **Naming a second gap type earned its place.** Dependency drag isn't decoration here: it's why the
  email has two asks instead of one. The rule "mention the second only if it changes the plan"
  produced a clean call in one pass.

- **The skill assumes one ask.** Phase 4 says "an explicit ask," singular, and gives no guidance on
  ordering two. I put the decision first and the escalation second because the decision is hers
  alone and the escalation is a favor — a reasonable rule, but mine, not the skill's.
