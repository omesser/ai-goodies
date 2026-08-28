# Example 3 — Three weeks to find out whether the backups restore

| | |
|---|---|
| **Shape** | Proposal |
| **Gap type** | 9 (insurance ask) |
| **Audience** | Engineering manager — technical, cost-skeptic, behind on the roadmap |
| **Format** | Slack message, cap 150 words |
| **Ask type** | Direction before investing |

## Scenario

A backend engineer wants three weeks to build and rehearse a restore path for the primary Postgres
instance. Backups exist and have never been restored, so both the recovery time and the backups
themselves are hypotheses. Sprint planning is Monday and that is the decision point. The manager is
technical, watches cost, and is already behind on the roadmap — the engineer expects "does this need
to be now" as the first response.

---

## The session

**Engineer:**
> I want to ask for three weeks to actually test our database restore. We have backups but we've
> never restored one, so we don't know if they work or how long it'd take. My manager is technical
> and is going to say "we're behind on the roadmap, does this need to be now". How do I pitch it?

**Skill — Phase 0, intake:**
> This is a proposal: you're creating a new expectation, not resetting an old one. You've already
> given me the audience — technical, cost-skeptic — so I'll calibrate to that row: one sentence of
> mechanism is allowed, trade-off numbers lead, and **no analogy**. The smoke-detector line the
> playbook offers for this gap type is a good line for a non-technical audience and would read as
> condescension to yours. I'm dropping it deliberately.
>
> Three things I still need:
>
> 1. What's the deliverable — Slack message, email, 1:1 talking points, something for a planning doc?
> 2. When does this conversation happen? That decides how much interview I can afford.
> 3. When you say "pitch it" — are you asking him to approve now, to fund it next quarter, or to
>    tell you whether to start at all?

**Engineer:**
> Slack. He lives there. Sprint planning is Monday and that's where the decision actually gets made,
> so he needs it before then. And the third one — direction before investing. I don't want to start
> this and get told two weeks in that it wasn't worth doing.

**Skill:**
> Good, that's the cleanest of the four ask types to write for, because it gives him something to
> *decide* rather than something to tolerate. Slack caps at 150 words, which will be the binding
> constraint on this. Proposal interview: P1 through P4, plus the checkpoint.

**Skill — Phase 1, round 1 (P1 stakes, P2 cost):**
> Four questions.
>
> 1. What breaks, costs, or embarrasses if this doesn't happen? Not "we'd be at risk" — what
>    specifically is unavailable to you today?
> 2. Has a small version of it already happened? A near-miss beats an argument.
> 3. What does this cost, exactly — money and time both?
> 4. Is the money flat or does it scale with usage?

**Engineer:**
> 1. If the primary goes, I can't tell anyone how long we'd be down. The backup is 900GB and nobody
>    has ever timed a restore of it. And the backup itself is unverified — a backup you've never
>    restored is a hypothesis, not a backup.
> 2. Yes. June 12, a migration locked the main table for 40 minutes during business hours. While it
>    was happening the director asked how fast we'd recover if it went further. I said "I don't
>    know". That's the reason I'm asking for this at all.
> 3. Three weeks of my time, and a standby replica at about $180/month.
> 4. Flat. It's a fixed instance.

**Skill:**
> $180/month is under what? A bare number makes him guess whether it's big, and a technical
> cost-skeptic will do that guessing out loud in the sprint planning channel.

**Engineer:**
> Under 3% of the AWS bill.

**Skill:**
> Then the three weeks needs the same treatment. It's the larger cost of the two and you gave it to
> me naked. He's behind on the roadmap, so time is the currency he's actually counting. What are
> three weeks a percentage of, and is that cost one-time or recurring?

**Engineer:**
> About 4% of the team's quarter. And it's one-time — the three weeks is a build, the $180 is the
> only thing that keeps running.

**Skill:**
> That distinction is doing more work than either number. I'm putting it in the message: the big
> number happens once, the recurring number is small.

**Skill — Phase 1, round 2 (P3 alternatives, P4 ask, checkpoint):**
> "Can't we do this cheaper" is the first question back, always. Four more:
>
> 1. What cheaper or free options exist, and what does each one miss?
> 2. For each of those — did you actually price or test it, or is it your judgment? I need to know
>    which is which, because the brief can't claim an evaluation that didn't happen.
> 3. What is demonstrably true at the end of the three weeks? Something he can see, not "we'd be in
>    better shape".
> 4. What does it cost to keep after that?

**Engineer:**
> 1. Three of them. Do nothing — free, and we keep the unknown. Write a runbook without rehearsing
>    it — about a week, but an unrehearsed runbook is still a hypothesis, and the hypothesis is
>    exactly the problem. Or a managed DR service at around $2k/month.
> 2. The DR service I priced properly — I went and looked. The runbook one is my judgment. I haven't
>    scoped it out; a week is my gut.
> 3. A rehearsed restore of production-sized data with a measured recovery time. An actual number.
> 4. Quarterly re-rehearsal, half a day each, and it fails loudly if it breaks.

**Skill:**
> Thank you for splitting those. The message will carry the $2k as a priced comparison, because it
> is one. The runbook option will not be presented as an evaluation — if he asks, you say it's your
> read and not a costed one. That distinction is the difference between a number he can check and a
> number that damages you when he checks it.
>
> One thing on the runbook, since it's the counter-proposal most likely to come back at you: your
> objection to it is the strongest single sentence in this interview. An unrehearsed runbook is a
> hypothesis, and the hypothesis is the problem. That argument survives even though the week
> estimate is a guess, because it doesn't depend on the week.

**Skill — Phase 1, round 3 (checkpoint, fallback, targets):**
> Four, then I write.
>
> 1. What's your guess for the restore time? I want to know whether you have one, not to put it in
>    the message.
> 2. He'll ask what slips. What's the honest answer?
> 3. Is there a smaller version of this you'd genuinely stand behind — not a version you'd resent?
> 4. Do written recovery targets exist — an RPO or RTO anyone has committed to? And has anyone asked
>    the vendor what a restore of this size typically runs at?

**Engineer:**
> 1. I'd guess under four hours. But the whole point is having a number instead of a guess.
> 2. Three weeks of me, so a named roadmap item moves by three weeks. I'm not going to pretend it's
>    free.
> 3. One week: rehearsed restore plus the measured number. No standby replica, no automation. I'd
>    stand behind that.
> 4. I don't know. Nothing is written down anywhere as far as I know. And I don't know whether
>    anyone has asked the vendor — I haven't.

**Skill:**
> Routing all three of those:
>
> - **The four-hour guess stays out of the message.** You told me the point is replacing a guess
>   with a number, and putting the guess in the ask undercuts the ask — he reads "under four hours"
>   and concludes it's fine. It goes in your prep, as the answer if he asks directly.
> - **The recovery target is his, not yours.** You don't know of a written RPO or RTO. I won't
>   assert there isn't one, and I won't have you assert it either. It becomes a question you're
>   ready to ask him, not a claim in the message.
> - **The vendor number is a task for you before Monday.** Ask what a restore of this size typically
>   runs at. It is not a substitute for measuring your own — a vendor's typical number says nothing
>   about your data, your instance, or your network — but he will ask, and "I haven't asked" is a
>   worse answer than a number plus that caveat.

**Skill — Phase 2, diagnosis:**
> Gap type 9, insurance ask, cleanly. He thinks nothing is broken, so why pay. The reframe is that
> the evidence can't be backfilled: after the outage is the expensive moment to find out the backup
> doesn't restore, and you can't retroactively rehearse. Nothing else is competing for the diagnosis
> here — no iceberg underneath, no AI angle.
>
> June 12 is the whole case. It's the small version that already happened, it has a date, and the
> person who asked the question outranks him. You opened by asking how to handle "does this need to
> be now" — June 12 *is* the answer to that question, and it's the one thing in this interview he
> can't argue with.

**Skill — Phase 4:**
> At 150 words, something goes. The order is analogy first — already dropped for the audience — then
> the separate upward line, since he's the one presenting this at planning and will paste the
> message or its first sentence rather than a line quoted inside it. So the first sentence is
> written to be the forwardable one. The next-update promise stays, folded into the deliverable
> line.

---

## Deliverables

### 1. The headline (17 words)

> Asking for three weeks to prove our Postgres backups restore, and to measure how long recovery
> takes.

### 2. The Slack message — 150 words (`wc -w`, cap 150)

> **Asking for three weeks to prove our Postgres backups restore, and to measure how long recovery
> takes.**
>
> We have backups. We have never restored one, so both the restore time and the backups themselves
> are unverified — 900GB, never timed. On June 12, when the migration locked the main table for 40
> minutes, the director asked how fast we'd recover. I said I don't know. That's the gap.
>
> Cost: three weeks of my time — about 4% of the team's quarter, one-time — plus a standby replica
> at $180/month, under 3% of the AWS bill, flat.
>
> You get a rehearsed restore of production-sized data with a measured recovery time, then a
> half-day re-rehearsal each quarter. You'll have the number the day I do.
>
> I want a direction before I start, not after. Monday: yes, no, or the one-week version — rehearsed
> restore and the measured number, no replica, no automation.

### 3. Hard-questions prep

**"We're behind on the roadmap. Does this need to be now?"**
> "It needs to be before the next incident, and I can't schedule that one. What I can tell you is
> that on June 12 the director asked me how fast we'd recover and I had no answer. If that migration
> had gone further, the same question arrives with the site down."

**"Can't you just write a runbook?"**
> "That's about a week — and that's my read, not something I've costed out. But an unrehearsed
> runbook has the same problem the backups have: it's never been executed, so it's a hypothesis. The
> hypothesis is what I'm trying to remove."

**"What about a managed DR service?"**
> "I priced it — around $2k/month, ongoing. This is $180/month ongoing plus three weeks once. If the
> restore turns out to be much worse than we can live with, that comparison is worth reopening with
> real numbers behind it."

**"What slips?"**
> "Three weeks of me, so one named roadmap item moves three weeks. You pick which. If that's too
> much, the one-week version gets you the rehearsed restore and the measured number — no replica, no
> automation — and I'd stand behind it."

**"How long do you think a restore takes?"**
> "My guess is under four hours. That's a guess, and the guess is the problem — I don't want to be
> defending it during an outage. Three weeks turns it into a number."

**Question to ask him, not answer:**
> "Do we have a recovery time we've actually committed to anywhere? I don't know of one written
> down. If there is one, it changes what I build. If there isn't, that's worth deciding once we know
> what's achievable."

### 4. Personal do-not-say list

| Likely blurt | Say instead |
|---|---|
| "It's only $180." | "$180/month, under 3% of the AWS bill, flat." |
| "I know we're behind, so if it's a bad time…" | "Three weeks moves one roadmap item by three weeks. You pick which." |
| "It's probably fine, I just want to check." | "It's unverified. That's different from fine, and I can't tell you which it is." |
| "It should be under four hours." | "I don't have a number. Getting one is the ask." |
| "Sorry to add to the pile." | (Nothing. Delete the sentence and let the ask stand.) |

### 5. The promised follow-up (offered)

Skeleton for the message that closes this out, so the cadence promise actually gets kept:

> **Restore rehearsal done. Measured recovery time: X hours Y minutes on 900GB.**
>
> The backup restored / did not restore cleanly — [what broke, if anything].
>
> What that means for us: [the recovery number in business terms].
>
> Next rehearsal [date], half a day. It fails loudly if it breaks.

### Before Monday

- Ask the vendor what a restore of this size typically runs at. Not a substitute for the
  measurement — it says nothing about your data or your network — but he will ask.

---

## What this run shows

- **The analogy was dropped, out loud, in Phase 0.** The playbook offers a smoke-detector line for
  gap type 9, and the skill named it and refused it because the audience row for a technical manager
  says an analogy reads as condescension. The refusal happened before the interview, not during
  drafting, which is where the calibration table says it belongs.
- **The denominator rule got applied to time, not just money.** The engineer volunteered "under 3%
  of the AWS bill" for the $180 but handed over "three weeks" bare. The skill pushed for the
  denominator on the larger cost, got 4% of the team's quarter, and then got the one-time-versus-
  recurring split — which ended up carrying more weight in the message than either percentage.
- **The unverified alternative stayed unverified.** The engineer priced the $2k/month DR service and
  guessed at the runbook. The skill split them and kept the split all the way into the deliverables:
  the DR number appears as a priced comparison, the runbook appears only in the prep with "that's my
  read, not something I've costed out" attached. Nothing in the message implies a comparison that
  wasn't run.
- **Three unknowns, three different routes.** The four-hour guess was suppressed on the grounds that
  it undercuts the ask; the missing RPO/RTO was handed back as a question only the manager can
  answer; the vendor's typical restore time became a named task before Monday. The skill declined to
  close any of them itself.
- **The 150-word cap pushed real content into the prep.** "Does this need to be now" is the question
  the engineer opened with, and the answer to it — June 12 — is in the message. But "what slips",
  which is the counter-proposal most likely to come back, survives only as a clause ("the one-week
  version") plus a prep answer. The manager reads a fallback he has no description of.
- **One awkward spot: the fallback is named without being explained.** "The one-week version —
  rehearsed restore and the measured number, no replica, no automation" is nine words of a menu item
  that deserves a sentence. Under the cap it reads as a discount rather than a considered option,
  and the engineer has to supply the reasoning live if the manager takes it.
