# Example 2 — The launch that holds for 80% of customers

| | |
|---|---|
| **Shape** | Reset |
| **Gap type** | Iceberg (hidden complexity — scale), with dependency drag as a live secondary |
| **Audience** | COO — skip-level, non-technical, forwards everything to the CEO |
| **Format** | Email she can forward, unedited |
| **Time pressure** | Sync in one hour — Phase 1 compressed to the ★ questions |

## Scenario

A data platform engineer owns a customer-facing analytics dashboard. The COO expects a full
launch on Oct 15 and marketing has a post queued. The dashboard is genuinely live and correct,
but the largest beta account carries 40x the data anything was ever tested against, and its
pages take 9 seconds against a 2-second bar. Part of the fix is gated on a vendor flag. The
engineer has one hour and needs an email the COO can forward to the CEO verbatim.

## The session

**Engineer:**

> Our COO is expecting the analytics dashboard to launch Oct 15 and marketing has a post ready.
> It's not going to be all customers on the 15th. I have a sync with her in an hour. She is not
> technical and whatever I write she will forward to the CEO.

**Skill — Phase 0, intake (no questions needed; all four answers were in the opening):**

Recorded from what the engineer already said, rather than asked back:

- **Format:** an email, written to be forwarded — not talking points.
- **Audience:** skip-level, non-technical, and a relay to the CEO. That selects the hardest
  calibration in the table: ~120-word cap, zero mechanism, every sentence written on the
  assumption it will be pasted upward with no edits.
- **Timing:** one hour. Phase 1 compresses to the ★ questions only.
- **Shape:** Reset. An existing expectation (Oct 15, all customers) will not hold as stated.

**Skill — Phase 1, round 1 (★ questions from A, B, C):**

1. What exactly does the COO believe today — "Oct 15, all customers, dashboard fully live"? And
   has she already committed that date to anyone outside the company?
2. What works end-to-end right now that you could show her without hand-holding?
3. What specifically do you now know that nobody knew when Oct 15 was set?

**Engineer:**

1. She believes Oct 15 is the full launch and marketing has a post ready to go with it. I don't
   know what the post actually says, and I don't know whether the CEO has quoted Oct 15 anywhere.
2. The dashboard has been live since Sept 2 — 12 internal users and 3 beta customers on it. The
   numbers reconcile against finance to the dollar. That part I'd demo to anyone.
3. The largest beta account has roughly 40x the data of anything we'd previously tested against.
   Its p95 query is 9 seconds. Our bar is 2 seconds.

**Skill — Phase 1, round 2 (pushing on "it's not going to be all customers" — the opening's
vaguest phrase — plus ★ E):**

You opened with "not all customers." That's the sentence that will get you the question you
least want. Which customers, as a share, and what is the actual boundary?

And two more: what is the fix, and what date would you bet your weekend on for everyone?

**Engineer:**

Accounts under 10 million rows are already fast today — that is about 80% of customers, and
Oct 15 holds for them fine. The fix for the rest is pre-computed aggregate tables. That's 2.5
weeks of plain engineering work, not research. Weekend-bet date for all customers is Nov 5.

But there's a second thing. The aggregation feature I need is behind a flag only our
data-warehouse vendor can turn on for our tier. Ticket's been open 9 days and all I've gotten is
an auto-reply. There is an account exec the COO could ping.

**Skill — Phase 1, round 3 (consequence, alternatives, and the ask — still ★-adjacent, three
questions because the email needs a decision in it):**

1. Concretely, what does the COO's customer see if those big accounts go live on the 15th anyway?
2. Was there a cheaper or faster alternative you ruled out? She will ask "can't we just buy our
   way out of this."
3. What do you actually need from her in this sync — a decision, an escalation, or both?

**Engineer:**

1. A spinner on every page load. And those are the four largest accounts by revenue — the ones
   most likely to get quoted as reference customers in the marketing post.
2. Yes. Buying bigger warehouse capacity takes 9 seconds down to about 5. Still over the
   2-second bar, and it costs real money every month. Pre-computing gets us under 2 with no
   ongoing cost.
3. Both. A decision on tiered vs. single launch, and the vendor escalation.

**Skill — Phase 1, one loose end:**

Why did this surface now and not in August?

**Engineer:**

The 40x account joined beta on Sept 2. Before that, no data of that size existed anywhere for us
to test against.

**Skill — Phase 1, close:**

That closes it. Every Phase 4 checklist item is answerable from the above. Two things stay
open and I will not fill them in: what the marketing post says, and whether the CEO has quoted
Oct 15 publicly. Those are hers to check, and the brief will say so rather than assume either way.

**Skill — Phase 2, gap diagnosis:**

**Dominant: #1 Iceberg.** The COO's belief is grounded in something real — the dashboard is
live, it has users, the numbers are right. The visible part is genuinely done. The remaining
work is scale, which is the invisible majority the gap type names, and it was always going to
be the majority for the biggest accounts.

**Secondary: #4 Dependency drag** — and it earns a mention, because it changes the plan. The
Nov 5 date has exactly one external risk, the vendor flag, and the COO is the person who can
act on it. The skill says mention a second gap type only when it changes the plan. It does here:
it is one of the two asks.

**Analogy: none.** Skip-level, 120 words, and "the pages take 9 seconds against a 2-second bar"
is already plain. An analogy inside a 120-word exec email spends words the decision needs, and
to a COO it reads as talking down.

**Skill — Phase 3, translation decisions (recorded because two of them were judgment calls):**

- "p95 query time" → "pages take 9 seconds." p95 is mechanism; the COO cannot act on a
  percentile.
- "Pre-computed aggregate tables" → deleted entirely. She is not choosing the technique, and
  naming it invites a question the email has no room to answer.
- "The vendor is sitting on our ticket" → "has held a required ticket 9 days." Fact, elapsed
  time, no blame. Rule 6.
- Every number ships with a denominator: 80% *of customers*, 10 million rows *as the boundary*,
  9 seconds *against a 2-second bar*, four accounts *largest by revenue*.
- **Judgment call 1 — the upward line.** The skill wants a quotable sentence for the manager to
  forward. This email *is* the forward. A separate "if it's useful upward" block would be a
  message-within-a-message and would cost ~15 of 120 words. Instead the first sentence was
  written as the upward line, and the engineer is told that outside the email.
- **Judgment call 2 — two anchors.** The Phase 4 checklist wants exactly one primary date. A
  tiered launch has two by construction. Both were kept; the subject line carries both so the
  CEO gets the shape from the preview pane alone.

**Skill — Phase 4:** deliverables below.

## Deliverables

### 1. The headline (≤25 words)

> Analytics dashboard launches Oct 15 for about 80% of customers; the four largest accounts
> need until Nov 5, and one vendor nudge from you protects that date.

24 words.

### 2. The email

**Word count: 126 words in the body** (122 excluding the "[COO] —" salutation and the two list
numerals), against the skill's ~120 cap for skip-level/exec output. Subject line not counted.

> **Subject: Analytics dashboard — Oct 15 for ~80% of customers, Nov 5 for the largest four**
>
> [COO] —
>
> Oct 15 holds for about 80% of customers — every account under 10 million rows is fast today,
> verified against finance to the dollar.
>
> Our four largest accounts by revenue need until Nov 5. One joined beta Sept 2 with 40x our
> tested data volume; its pages take 9 seconds against a 2-second bar. Launching them Oct 15
> puts a spinner on every page load for the accounts marketing is most likely to quote.
>
> Two things from you:
>
> 1. Tiered launch Oct 15, or hold everyone to Nov 5?
> 2. Our warehouse vendor has held a required ticket 9 days; a note to our account exec is the
>    one thing that moves Nov 5.
>
> Next update Friday, or same day if the vendor moves.

**Note to the engineer, not part of the email:** the first sentence is your upward line. If the
CEO reads nothing else, that sentence is the one you want him to have. Do not add a separate
"here's what to tell the CEO" section — she is forwarding this whole thing.

**Also not part of the email, say it out loud in the sync:** you don't know what the marketing
post says, and you don't know whether Oct 15 has been quoted externally. Both are hers to check
before she answers question 1. Don't guess at either in writing.

### 3. Hard-questions prep

**"Can't we just launch everyone on the 15th?"**
> We can. Those four accounts get a spinner on every page load, and they're the largest by
> revenue and the most likely names in the post. That's the trade — it's a business call, not a
> technical one, which is why it's your decision and not mine.

**"Can't we buy our way out of it?"**
> I checked. Bigger warehouse capacity takes 9 seconds to about 5 — still over our 2-second
> bar, and it's a real monthly cost forever. Pre-computing gets us under 2 with no ongoing
> cost. Paying more doesn't buy the date.

**"Why am I hearing this two weeks out?"**
> The account that exposed it joined beta on Sept 2. Before that, no data at that size existed
> for us to test against — we weren't ignoring it, we couldn't see it. You'll get a Friday line
> from me through launch so nothing else lands late.

**"How confident are you in Nov 5?"**
> The 2.5 weeks of work is ordinary engineering, not research — I'd bet my weekend on it. The
> single variable is the vendor flag. That's why it's ask number two.

**"What can I announce on the 15th?"**
> A launch, honestly. About 80% of customers get the dashboard, fast, with numbers that
> reconcile to the dollar. What I can't tell you is whether the post names the four accounts
> that aren't in that wave — that's worth checking before it goes out.

### 4. Personal do-not-say list

| Likely to blurt | Say instead |
|---|---|
| "It's not going to be all customers on the 15th." (your own opening line — it leads with the hole and invites "so which ones?") | "Oct 15 holds for about 80% of customers. The four largest need until Nov 5." |
| "The vendor's been ignoring us for nine days." | "Our ticket has been open 9 days. A note to our account exec is the fastest unblock." |
| "It's slow for the big accounts." | "9 seconds against our 2-second bar." |
| "It turned out to be way more data than we expected." | "An account with 40x our tested volume joined beta Sept 2. That's what we now know." |
| "Hopefully we can still get everyone in on the 15th." | Nothing. Don't offer a date you won't bet a weekend on. Nov 5 is the date. |

### 5. The promised Friday follow-up (skeleton)

> **Subject: Dashboard — Friday update**
>
> Oct 15 wave: [on track / changed, and why].
> Nov 5 wave: aggregate work [N of 3 stages done].
> Vendor flag: [enabled on <date> / still open, <N> days, escalation status].
> Nothing needed from you this week. / One thing: [ask].

Fill it in and send it even on the weeks where nothing moved. The empty ones are what make the
non-empty ones believed.

## What this run shows

- **The interview earned the email.** The engineer's opening contained one number: Oct 15. The
  email contains eight, and every one came from a ★ question. The single most valuable answer —
  "about 80% of customers are already fast" — arrived only because the skill pushed back on the
  vague phrase "not all customers" instead of writing around it.
- **The ~120-word exec cap is genuinely tight against the checklist.** Two dates, two asks, a
  denominator, the risk that moves the date, a cadence, and a forwardable opening do not fit
  comfortably. The output landed at 126 and something had to be cut: the standalone "if it's
  useful upward" block. That was arguably the right cut here — the email *is* the forward — but
  the skill offers no guidance for the case where the manager forwards the artifact itself, and
  a less careful run would either blow the cap or drop the cadence line instead.
- **The "exactly one primary anchor" check does not survive a tiered launch.** Oct 15 and Nov 5
  are both primary, and collapsing to one would misrepresent the situation. The skill's Phase 4
  checklist needs a tiered/partial-launch case, or the check reads as violated on a correct brief.
- **The reset shape has no ★ for alternatives ruled out.** "Can't we just buy bigger hardware?"
  is the first question any COO asks, and the answer (9s → ~5s, still over bar, ongoing cost)
  was the strongest item in the hard-questions prep. It surfaced only because round 3 went
  looking for it. The proposal shape has P3 for exactly this; the reset shape's dimension E
  ("options with trade-offs") points at scope cuts, not at technical alternatives already
  eliminated.
- **Phase 4 has no slot for what the engineer doesn't know.** Two material unknowns — the
  contents of the marketing post, and whether Oct 15 has been quoted externally — bear directly
  on the decision being asked for. They ended up in an improvised "not part of the email" note.
  A standing deliverable item ("what the manager must check that you can't") would have caught
  them by construction rather than by luck.
- **Compressing to ★ dropped dimension D entirely** (is this the first reset? were early
  warnings given?). Nobody asked, so the brief cannot know whether this lands cold or as the
  third slip — which would change the tone materially. Under one-hour pressure that may be an
  acceptable loss, but the skill compresses silently; it should say which dimension it is
  giving up.
