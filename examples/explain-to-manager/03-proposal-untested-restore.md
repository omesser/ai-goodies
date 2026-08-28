# Example 3 — Three weeks to find out whether the backups work

| | |
|---|---|
| **Shape** | Proposal |
| **Gap type** | 9 (insurance ask) |
| **Audience** | Direct engineering manager — technical, cost-skeptic, behind on the roadmap |
| **Format** | Slack message, capped at 150 words |
| **Ask type** | Direction before investing — a go/no-go before any work starts |

## Scenario

A backend engineer wants three weeks to build and rehearse a restore path for the primary Postgres
instance. Backups exist and have never been restored, so both their validity and the recovery time
are unknown. The manager is technical, lives in Slack, and is behind on the roadmap. Sprint planning
is Monday, which is the decision point.

---

## The session

**Engineer:**
> I want to ask for three weeks to actually test our database restore. We have backups but we've
> never restored one, so we don't know if they work or how long it'd take. My manager is technical
> and is going to say "we're behind on the roadmap, does this need to be now". How do I pitch it?

**Skill — Phase 0, intake:**
> Four things are already settled by what you said, and one I need to confirm.
>
> - **Shape:** proposal. You're creating a new expectation, not resetting an old one.
> - **Audience:** technical, cost-skeptic. That changes the writing: one sentence of mechanism is
>   fine, **and I'm dropping the analogy**. There's a good one in the bank for this gap type — the
>   smoke detector you can't install after the fire — and to a technical manager who already
>   understands backups it reads as being talked down to. Trade-off numbers lead instead.
> - **Format:** Slack, so a hard cap of 150 words.
> - **Timing:** confirm — is Monday's planning the moment this gets decided?
>
> And the one that shapes the whole ask: do you want approval to start, or a decision *before* you
> invest anything?

**Engineer:**
> Monday is the moment, yes. And it's direction before investing. I don't want to start this and
> then get told two weeks in that it wasn't worth it.

**Skill — Phase 1, round 1 (P1, P2):**
> That makes the ask a clean go/no-go, which is easier to grant than "approve my three weeks."
> Four questions.
>
> 1. What actually breaks or costs if this never happens — in business terms, not database terms?
> 2. Has a small version already happened? A near-miss, or a question someone asked that you
>    couldn't answer?
> 3. What does it cost, exactly, and what is that relative to?
> 4. Is the cost flat or does it scale with usage?

**Engineer:**
> 1. We don't know our recovery time. The backup is 900GB and nobody has ever timed a restore of it.
>    We also don't know whether the backups are valid — a backup you've never restored is a
>    hypothesis, not a backup.
> 2. Yes, and it's the reason I'm asking. On June 12 a migration locked the main table for 40
>    minutes during business hours. While it was happening the director asked how fast we'd recover
>    if it went further, and I said "I don't know."
> 3. Three weeks of my time, plus a standby replica at about $180/month. Three weeks is roughly 4%
>    of the team's quarter. The $180 is under 3% of our AWS bill.
> 4. The replica is flat. The three weeks is one-time.

**Skill:**
> The June 12 exchange is the whole pitch. It's not a hypothetical risk you're asking him to
> imagine; it's a question his boss already asked out loud and got "I don't know" for an answer.
> That goes near the top.
>
> **Round 2 (P3, P4, E):**
>
> 5. What cheaper or free options did you look at, and what does each one miss?
> 6. At the end of three weeks, what is *demonstrably* true that isn't true today?
> 7. What keeps it true after the three weeks?
> 8. If he says "we're behind on the roadmap" — what actually slips, and is there a smaller version
>    you'd stand behind?

**Engineer:**
> 5. Three. Doing nothing is free and keeps the unknown. Writing a runbook without rehearsing it is
>    about a week, but an unrehearsed runbook is still a hypothesis and the hypothesis *is* the
>    problem. A managed DR service is around $2k/month.
> 6. A rehearsed restore of production-sized data with a measured recovery time. I think it's under
>    four hours but the point is having a number instead of a guess.
> 7. Re-rehearse quarterly, half a day each, and it fails loudly if it breaks.
> 8. Three weeks of me, so a named roadmap item moves by three weeks. I'd stand behind a one-week
>    version: rehearsed restore plus the measured number, no standby replica, no automation.

**Skill — pushing on question 5:**
> I need to separate those three, because "can't we do this cheaper?" is always the first question
> back and a technical manager will hear the difference.
>
> The $2k/month — did you actually price that, or is it a number you've absorbed from somewhere?

**Engineer:**
> I priced it properly. That one's real.

**Skill:**
> And the runbook-without-rehearsal option — did you evaluate that, or is it your judgment?

**Engineer:**
> Judgment. I didn't scope it out. I just think it doesn't solve the thing I'm worried about.

**Skill:**
> Then the brief will not say you evaluated it. That distinction matters more than it looks: if he
> asks "did you cost out the runbook option?" and the honest answer is no, one sentence of overclaim
> costs you the credibility the whole ask runs on. I'll write it as judgment, in your voice, with
> the reasoning visible — and it's a strong argument on its own, because "an unrehearsed runbook is
> still untested" is a claim he can check without any evaluation behind it.
>
> Two last gaps.
>
> 9. Are there written RPO/RTO targets you'd be measuring against?
> 10. Has anyone asked the vendor what a restore of this size typically takes?

**Engineer:**
> No targets are written down anywhere, as far as I know. And I don't know whether anyone has asked
> the vendor — I haven't.

**Skill:**
> Both stay out of the brief then, since I won't put a number in your mouth. Flagging them for you
> instead: the vendor question is worth 10 minutes before Monday, because if he asks "can't they
> just tell us?" you want an answer better than "I didn't check." Drafting now.

---

## Deliverables

### 1. Headline (20 words)

> We've never restored a backup, so our recovery time is a guess — three weeks turns it into a
> measured number.

### 2. The Slack message (150 words — at the cap)

> **Three weeks to test our database restore.** We have backups; nobody has restored one, so our
> recovery time is a guess.
>
> **Why now:** on June 12 a migration locked the main table for 40 minutes during business hours.
> The director asked how fast we'd recover. I said "I don't know." That's still true.
>
> **Cost:** three weeks of my time, about 4% of the team's quarter, plus a standby replica at
> $180/month, under 3% of our AWS bill. The managed alternative is ~$2k/month.
>
> **What you get:** a rehearsed restore of 900GB with a measured recovery time, then half a day per
> quarter to keep it true. I'll post the number when I have it.
>
> **Ask:** go/no-go Monday. It moves one named roadmap item by three weeks. I'd also back a one-week
> version: restore and number only, no replica.
>
> **Forwardable:** "We're replacing a guess about our recovery time with a measured one."

### 3. Hard-questions prep

**"We're behind on the roadmap. Does this need to be now?"**
> "It needs a decision now, not necessarily three weeks now. The reason it's on Monday's list is
> that on June 12 the director asked how fast we'd recover and I couldn't answer. If the roadmap
> can't take three weeks, the one-week version gets you the measured number without the replica or
> the automation — I'd stand behind that."

**"Can't we do this cheaper — just write a runbook?"**
> "A runbook is about a week and I'd take it over nothing. But my concern is that the backups have
> never been restored, and a runbook written from documentation doesn't test that. It leaves us with
> the same untested assumption, written down more neatly. To be straight with you: I priced the
> managed DR option properly at ~$2k/month, but I haven't costed out a runbook-only path — that's my
> judgment, not an evaluation."

**"What's the actual risk? Nothing has gone wrong."**
> "Two unknowns, not one. We don't know how long a restore takes, and we don't know whether the
> backups restore at all. Both are answerable in three weeks and neither is answerable during an
> incident. June 12 was the free version of that question."

**"How long do you think a restore takes?"**
> "My guess is under four hours. It's a guess, which is the problem I'm asking to fix — I'd rather
> hand you a measured number in three weeks than a guess today that we plan around."

**"What slips?"**
> "Three weeks of me, so one named roadmap item moves by three weeks. You pick which one — I'm not
> going to choose that for you."

### 4. Personal do-not-say list

| Don't say | Say instead |
|---|---|
| "We should really have done this ages ago." | "On June 12 this became a question someone asked out loud. I'm closing it now." |
| "I evaluated the alternatives." | "I priced the managed option at ~$2k/month. The runbook-only path is my judgment, not a costing." |
| "It's only $180." | "$180/month, under 3% of our AWS bill." |
| "It'd probably be a few hours." | "My guess is under four hours — and a guess is exactly what I'm asking to replace." |
| "If the database dies we're basically finished." | "We can't currently say how long a recovery takes, or whether it succeeds." |

### 5. The follow-up skeleton (post it the day the rehearsal runs)

> **Restore rehearsal — result**
> Restored: yes / no (if no: what failed, and what that tells us).
> Measured recovery time: **\<n\> hours** for 900GB, against a guess of under four.
> What I'd change: \<one line\>.
> Next rehearsal: \<date\>, half a day.

---

## What this run shows

- **The analogy was dropped on purpose, and the skill said why.** Gap type 9 has a strong entry in
  the analogy bank (the smoke detector). Phase 0's technical-audience row overrides it, and the
  skill named the override out loud in intake rather than silently omitting it. That is the right
  behaviour: to a manager who already knows what a backup is, the metaphor reads as condescension.
- **The unverified alternative was contained, not laundered.** The engineer priced the DR service
  and guessed at the runbook. The skill split them in the interview, kept the priced number in the
  Slack message, and moved the judgment call into the hard-questions prep labelled as judgment. No
  deliverable claims an evaluation that didn't happen.
- **The near-miss did most of the work.** June 12 converts an abstract risk into a question the
  director already asked and got "I don't know" for. The skill spent one round finding it and then
  put it in the second sentence.
- **Two unknowns were left visible instead of filled in.** No RPO/RTO targets exist and the vendor
  was never asked about restore times. Neither appears in the brief. That is honest, but it is also
  a hole: a cost-skeptic manager can reasonably ask "measured against what target?" and the engineer
  has no answer. The brief would be stronger if it named the missing target as part of the problem.
- **The 150-word cap cost real content.** The message hit the cap exactly, after three rounds of
  trimming. The casualty was the alternatives section — the runbook option, the one this manager is
  most likely to counter-propose, survives only in the prep notes. A 250-word email would not have
  had to make that trade.
- **The "under four hours" guess was deliberately kept out of the brief.** Publishing it would have
  created the exact false precision the ask exists to eliminate. It lives in the hard-questions prep
  where it can be given as a guess, labelled as one.
