# Example 4 — The monitoring line the CFO circled

| | |
|---|---|
| **Shape** | Defense |
| **Gap type** | 10 (invisible work) |
| **Audience** | CFO / budget owner, non-technical — reached through the director, who presents; the engineer is not in the room |
| **Format** | A slide's worth of bullets (headline + 5) plus talking points for the questions back |

## Scenario

A platform lead's $8,400/month monitoring bill got circled in a cost review, in a document that also
says the platform team delivered no roadmap items in Q3. Their director presents Thursday and asked
for material. Two questions are actually on the table — "is this too expensive" and "what does this
team even do" — and the engineer answers neither of them in person.

---

## The session

**Engineer:**
> Our CFO circled the $8.4k/month Datadog line in the cost review, and the same doc says the platform
> team "delivered no roadmap items in Q3". My director is presenting Thursday and asked me for
> material. I feel like I'm being asked to justify my team's existence.

**Skill — Phase 0, intake:**
> Most of the intake is already in what you wrote. Let me state what I've settled and ask for the
> two things I can't infer.
>
> - **Shape:** defense. You're not resetting a promise or asking for something new — you're
>   defending existing spend and invisible work under scrutiny.
> - **Timing:** Thursday, so we have room for a proper interview rather than the compressed version.
> - **One thing to name up front:** "justify my team's existence" is the frame I need you to drop
>   before Thursday, not because it's wrong about how it feels but because it produces defensive
>   writing. The brief that works here reports terrain: here is what the money buys, here is what
>   happened the last time we bought less of it, here is the cut I'd stand behind.
>
> Two questions:
>
> 1. Who actually reads this — the CFO directly, or your director reading it out? And how technical
>    is the person the words have to land on?
> 2. What format did your director ask for?

**Engineer:**
> The CFO is the audience but I'm not in the room. My director presents. The CFO is not technical at
> all — budget owner, thinks in dollars. My director isn't going to defend anything they can't say in
> their own words.
>
> Format: a slide's worth of bullets my director puts up, plus talking points for the questions
> coming back at them.

**Skill:**
> That fixes the calibration, and it's the strictest one in the set. Finance / budget owner means:
> **denominator first, risk second, mechanism never.** Every number ships with what it's a fraction
> of, before the number itself gets to matter. Nothing about how monitoring works survives into the
> slide — not sampling, not agents, not instrumentation. If a sentence would make a CFO ask "what's a
> trace", it's rewritten.
>
> And because your director presents rather than forwards, and isn't technical, the talking points
> have to be answerable *by them*, cold, without you in the room. That constrains what I can put in
> them more than usual.
>
> One more thing I noticed: the cost review makes two accusations, not one. "$8.4k is too much" and
> "this team produced nothing in Q3." A brief that only answers the first one loses, because the
> second is what makes the first sound obvious. Do you want both handled?

**Engineer:**
> Yes. Honestly the second one bothers me more.

**Skill — Phase 1, round 1 (P1: what the spend quietly prevents):**
> Then we start with the part that carries the whole brief. Four questions.
>
> 1. What does this spend quietly prevent? Not what the tool does — what would happen differently on
>    a normal Tuesday without it.
> 2. Has it ever actually lapsed? A period where you had less of it than you have now?
> 3. If yes: what happened, and what did it cost in dollars or customers?
> 4. Do you have a number for how fast you find problems today?

**Engineer:**
> 1. Problems get found before customers report them. That's the whole thing.
> 2. Yes. Trace sampling was reduced in January to save money.
> 3. On March 3 the checkout service started failing for a subset of card types. It ran 51 minutes
>    before a customer emailed us. About $40k in refunds and goodwill credits. The account
>    "Brightline" churned two months later and cited that incident. And root cause took three days to
>    find, because the traces from the incident window had already aged out under the reduced
>    retention.
> 4. Median detection is 4 minutes. Without monitoring, detection is a support email.

**Skill:**
> That's the strongest last-lapse evidence I've seen for this shape, and it decides the brief. I want
> to flag one precision point before I use it, because a CFO will find it if I don't.
>
> The three-day root cause is *directly* caused by the January reduction — the records were gone,
> that's a clean causal line. The 51 minutes and the $40k are what a detection gap costs, and your
> 4-minute median is the contrast. I'm going to keep those two facts adjacent but not fuse them into
> "the January cut caused $40,000." Overclaiming one link is how the whole exhibit gets dismissed.

**Engineer:**
> Can we leave January out entirely? It sounds like someone screwed up, and I don't want Thursday to
> turn into a hunt for who approved it. I don't actually know who approved it.

**Skill:**
> I'm not going to write it out, and I want to be direct about why rather than just overriding you.
>
> Without January, the brief is a bare defense of the status quo: "this is valuable, please keep
> paying." That is the weakest possible position in a cost review, and it's exactly the position the
> CFO expects you to take. January is the only thing in your material that converts an opinion into
> evidence. It's also the reason your "don't cut this specific $2,400" is credible rather than
> territorial.
>
> There's also a downside risk in omitting it. If the CFO later learns that monitoring was reduced in
> January and checkout ran 51 minutes blind in March, and your slide didn't mention it, the problem
> stops being the budget.
>
> What I can do is make it un-huntable. The brief says *monitoring was reduced in January to save
> money* — an event, with no actor. No name, no team, no approver, no tool blamed. Your "I don't know
> who approved it" then costs nothing, because the brief never raises the question. If someone in the
> room asks anyway, your director's line is "that's not what this is about — the point is what the
> reduction cost us."
>
> Does that version work for you?

**Engineer:**
> Yeah. That works. Nobody's name on it and I'm not the one raising it.

**Skill — Phase 1, round 2 (P2, P3: cost, denominator, the cheaper version):**
> Four more.
>
> 1. What's the total infrastructure bill this $8.4k sits inside?
> 2. Is the $8.4k flat, or does it scale with usage?
> 3. What does the cheaper version look like — cuts you'd actually stand behind, with the specific
>    risk each one accepts?
> 4. What would you refuse to cut, and what does it cost?

**Engineer:**
> 1. Total infra is about $76k/month, so $8.4k is 11%.
> 2. I'd have to check. I don't have that offhand.
> 3. Two I stand behind. Log retention 30 days down to 7 saves about $1,900/month, and it accepts
>    that a compliance question about anything older than a week takes days of digging instead of
>    minutes. Sampling internal-only services at 10% instead of 100% saves about $1,100/month, and it
>    accepts slower detection on internal tools — not on anything customer-facing.
> 4. Trace retention on customer-facing services, about $2,400/month. That's precisely what saved us
>    three days in March, and precisely what January cut.

**Skill:**
> Two routings before I move on.
>
> **The usage question stays open and becomes yours to close before Thursday.** "Does this grow into
> a bigger number" is a top-three CFO question and I'm not going to let your director improvise an
> answer to it. Find out whether the line is flat or usage-priced. If it's usage-priced, the honest
> answer is a review point rather than a promised flat figure, and I'll write that version instead.
>
> **A second check, and this one is load-bearing.** Is the $76k before or after the Q3 rightsizing
> you're about to put on the slide?

**Engineer:**
> ...I'd have to check that too. I don't know offhand.

**Skill:**
> Then check it, because two headline numbers depend on the answer and they interact in a way the CFO
> can spot.
>
> If $76k is the current, post-rightsizing bill, then 11% is correct. If $76k is the pre-rightsizing
> number, the current bill is closer to $64k and monitoring is 13% of it, not 11% — and the slide
> would be quoting a share of a bill that no longer exists. Either answer is fine to present. Quoting
> the wrong one on a slide about cost discipline is not.
>
> Both checks go on your pre-Thursday list. I'm not closing either of them for you.

**Skill — Phase 1, round 3 (P4, and the second accusation):**
> Last round. Four questions.
>
> 1. What's the ask? "Keep it as is," or a cut menu?
> 2. Is there a cheaper vendor, and what would switching actually cost?
> 3. When does the contract renew?
> 4. The Q3 accusation: what did the team actually produce, in things a CFO counts?

**Engineer:**
> 1. I'd rather walk in offering about $3,000/month of savings than fight for the whole $8,400. If I
>    defend all of it I look like I'm protecting my toys.
> 2. There's a real migration option. Roughly a month of platform time. Contract renewal is the
>    natural moment to evaluate it.
> 3. I don't know the exact renewal date.
> 4. We cut compute spend by $12k/month with a rightsizing project. We ran 14 incidents to
>    resolution. We held 99.98% uptime. None of it is a roadmap item, which is why the doc says we
>    delivered nothing.

**Skill:**
> Your instinct on the ask is right and it's the difference between this landing and not. Offering
> $3,000 of a circled $8,400 makes you the person doing cost discipline rather than the person
> resisting it — and it earns you the standing to say the $2,400 doesn't move.
>
> **The renewal date I'm dropping from your list and handing to the room.** Finance owns the
> contract; the CFO is more likely to know it than you are, and "renewal is the right moment to
> evaluate alternatives" works as a sentence whether or not anyone in the room knows the date. It
> becomes a question your director can ask rather than a hole in your material.
>
> **On Q3 — that $12k/month is the whole answer and I don't think you've noticed how good it is.**
> The team being accused of costing $8,400/month permanently removed $12,000/month from the bill in
> the same quarter. Every month, the platform team's Q3 work pays for the line item under review and
> returns $3,600 on top. That's not a defense of invisible work, it's a net-positive number, and it's
> the only sentence on the slide the CFO will repeat.
>
> One commitment I need from you rather than from me: if the cuts are taken, when do you report back
> on what the accepted risk actually cost? I won't put a date in the brief that you didn't choose.

**Engineer:**
> 90 days. That's long enough to have had a compliance question and a couple of internal incidents.

**Skill — Phase 2, gap diagnosis:**
> **Gap type 10, invisible work** — and unusually, both accusations are the same gap wearing
> different clothes. "Why does monitoring cost $8.4k" and "why did the platform team deliver nothing"
> are one question: the output of this team is *absence*, and absence doesn't show up in a roadmap
> tracker or justify a line item. That's why I'm answering both on one slide instead of splitting it.
>
> The reframe: success here looks like nothing happening. So the slide shows what "nothing" prevented
> — with March as the receipt — and what stopping it would save versus expose.
>
> **No analogy.** The bank has one for invisible work, the maintenance crew you only notice the month
> you skip it. Your March incident *is* that story, with real numbers and a named churned account. An
> analogy next to it would weaken it.

**Skill — Phase 4, deliverables:**
> Cap for a slide is headline + 5 bullets, and this brief has to carry two accusations, an evidence
> exhibit, and a cut menu. Something gets waived.
>
> **I'm cutting the separate upward line.** Normally the brief includes one quotable sentence for the
> manager to forward. Here your director doesn't forward the brief, they present it — the headline
> already is that sentence, said out loud, in the room. Writing a second one wastes a bullet.
>
> Everything else stays: the evidence, the denominators, the cut menu with named risks, the ask, and
> the review point on the cut. Here's the material.

---

## Deliverables

### The headline (23 words)

> Monitoring is 11% of infrastructure spend. In March, 51 minutes of undetected checkout failures
> cost $40,000. We can cut $3,000/month with named trade-offs.

### The slide — 5 bullets

> **1. What the line buys.** Problems reach us before they reach customers. Median time from a
> failure starting to our team knowing: 4 minutes. Without it, the first notification is a customer
> email.
>
> **2. What it cost the last time we spent less on it.** Monitoring was reduced in January to save
> money. On March 3, checkout failed for some card types and ran 51 minutes before a customer emailed
> us — about $40,000 in refunds and goodwill credits, and the Brightline account left two months
> later citing that incident. Finding the cause took three days, because the records covering that
> window had already been discarded under the shorter retention.
>
> **3. What it costs, and what the same team returned.** $8,400/month is 11% of our ~$76,000/month
> infrastructure bill. In Q3 this team permanently removed $12,000/month of compute cost — more,
> every month, than the line under review — ran 14 incidents to resolution, and held 99.98% uptime.
>
> **4. What we can cut Thursday, and what each cut accepts.** Keeping records one week instead of one
> month saves ~$1,900/month, and accepts that a compliance question about anything older than a week
> takes days of digging instead of minutes. Reducing coverage on internal-only tools saves
> ~$1,100/month, and accepts slower detection there — not on anything customers touch. Together
> ~$3,000/month, 36% of the line.
>
> **5. The ask.** Take the ~$3,000/month now. Hold the ~$2,400/month covering customer-facing
> transactions — that is the exact coverage January removed and March needed. Switching vendors is
> real and costs about a month of platform team time; contract renewal is the right moment to
> evaluate it. At 90 days I'll report what the accepted risks actually cost.

### Talking points — the questions back

These are written to be said by the director, cold, without the engineer in the room. No answer
requires technical follow-up.

**"If nothing is broken, why are we paying $8,400 a month?"**
> Because the result of this spend is that you don't hear about things. The month we spent less on
> it, checkout ran 51 minutes blind and cost about $40,000. The team is offering to give back
> $3,000/month of it with the trade-offs written down.

**"Can we just cut it in half?"**
> Half means cutting into the coverage on customer payments. That's the specific thing that was
> reduced in January, and it's why March took three days to diagnose instead of an afternoon. The cut
> the team stands behind is $3,000/month, and each piece of it names what it gives up.

**"Isn't there something cheaper?"**
> There's a real alternative, and moving to it costs about a month of the platform team's time. The
> renewal date is the right moment to price that properly — finance would know when that is better
> than we do.

**"Does this number grow?"**
> [Answer depends on the pre-Thursday check. If usage-priced: "It moves with activity, which is why
> the team will report the actual number at the 90-day review rather than promise you a flat figure."
> If flat: "It's flat at $8,400 under the current contract."]

**"The doc says this team delivered nothing in Q3."**
> They delivered $12,000 a month off the compute bill — permanently, and more every month than the
> line you circled. They also ran 14 incidents to resolution and held 99.98% uptime. None of that is
> a roadmap item, which is why the tracker shows zero.

### Personal do-not-say list

| Likely to say | Say instead |
|---|---|
| "I feel like I'm being asked to justify my team's existence." | "Here's what the money buys and here's what we can give back." |
| "We told you cutting monitoring in January was a mistake." | "Monitoring was reduced in January to save money; here's what that cost in March." |
| "You can't cut this." | "Here's the $3,000 I'd cut, and here's the $2,400 I'd hold and why." |
| "It's only 11% of the bill." | "It's 11% of the bill." ("Only" tells a CFO their question was silly.) |
| "If you cut it, something will break." | "If we cut the customer-facing coverage, we lose the 4-minute detection on payments. That's the March scenario." |

### Pre-Thursday checks (yours, not closed by me)

1. Is the $76k infrastructure figure before or after the Q3 rightsizing? Bullets 3 and the 11% both
   depend on it.
2. Is the $8,400 flat or usage-priced? It fills the blank in talking point four.

### The promised follow-up — 90-day review skeleton

> **Monitoring cuts, 90 days on.**
> - Cuts taken: [which], saving $[actual] against the $3,000 estimate.
> - Compliance or lookup questions where the shorter retention cost us time: [count, and the worst
>   case].
> - Internal incidents where reduced coverage delayed detection: [count, longest delay].
> - Customer-facing detection median, unchanged target: 4 minutes. Actual: [x].
> - Recommendation: hold, restore, or cut further.

---

## What this run shows

- **The blame gate held.** The January reduction appears in the headline's evidence bullet as an
  event with no actor — "monitoring was reduced in January to save money." No person, team, vendor,
  or tool is blamed anywhere in the deliverables, including in the talking points, which are the part
  most likely to drift under pressure. The "who approved it" unknown got dropped rather than
  answered, which removed the temptation entirely.
- **The finance calibration held, and it cost real vocabulary.** Every number ships with its
  denominator before it lands: 11% of $76k, 36% of the line, $12k/month against the same bill. No
  mechanism survived into the slide — "trace sampling" became "coverage on customer-facing
  transactions", "log retention" became "keeping records one week instead of one month". The one
  place mechanism leaked close is bullet 2's "discarded under the shorter retention", which is a
  records-keeping statement rather than an engineering one, but it's the nearest miss in the brief.
- **The skill refused the omission and renegotiated it instead of overriding it.** The engineer asked
  to drop January because it sounded like someone had screwed up; the skill declined, explained that
  it was the only thing converting opinion into evidence, named the downside of the CFO discovering
  it later, and then offered the actorless framing that made the request moot. The engineer accepted
  on those terms rather than being talked past.
- **Unknowns got routed three different ways, correctly.** The renewal date went to the room (finance
  owns the contract). The $76k baseline and the pricing model went back to the engineer as named
  pre-Thursday checks. None were guessed. The $76k catch is the sharpest thing the interview
  produced — the 11% figure and the $12k/month claim are quoted from the same bill, and if that bill
  is the pre-rightsizing one, the slide understates the share while over-quoting the base.
- **The slide cap is genuinely tight for a two-accusation defense.** Headline + 5 bullets is the
  documented cap, and the brief had to carry evidence, denominator, cut menu, ask, and a second
  accusation about team output. Bullets 2 and 4 are each three sentences, which is past comfortable
  slide density — they read as speaker notes projected. The cap rule saved it by letting the upward
  line be waived, but only just, and the skill doesn't say what to do when a shape's skeleton needs
  six bullets.
- **The proxy presenter is a case the skill doesn't cover.** Every Phase 4 deliverable assumes the
  engineer is in the room: the hard-questions prep is written for them to answer, and the do-not-say
  list is lines *they* might blurt. Here a non-technical director presents and takes the questions.
  The talking points had to be rewritten to be sayable by someone who can't field a follow-up, and
  the do-not-say list ended up governing the prep conversation rather than the meeting. That
  adaptation was improvised in this run; SKILL.md gives no guidance for it.
