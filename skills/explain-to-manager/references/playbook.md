# Playbook: translation dictionary, analogies, hard questions, worked examples

Companion to [SKILL.md](../SKILL.md). Use during Phase 3 (translation) and Phase 4 (deliverables).

## Translation dictionary

Engineer-speak on the left never appears in a deliverable. Adapt the right side to the specifics gathered in the interview — these are patterns, not paste-ready strings.

| Engineer says | The brief says |
|---------------|----------------|
| "The POC works but it's not productionized" | "We've proven the approach works. Making it dependable enough to put in front of customers is the remaining work — that's the N weeks in the plan." |
| "We have tech debt to deal with first" | "Earlier shortcuts, taken to move fast, now have to be fixed before we can safely build on top of them." |
| "The integration is flaky" | "Our connection to X fails intermittently. Customers would see random errors, so we're making it detect and recover on its own." |
| "It works on staging" | "It works in our test environment. The remaining step is proving it holds up with real data and real traffic." |
| "There are a lot of edge cases" | "It handles the common cases. What's left is the rare-but-real situations customers will hit — bad files, mid-process cancellations, huge inputs." |
| "It doesn't scale" | "It works for 10 users; at 1,000 it slows to a crawl. Launch-day load is ~N, so this must be fixed before release." |
| "We're blocked on the platform team / a vendor" | "Our part is ready. We're waiting on X from Y, promised for <date>. If it slips past <date>, an escalation from you would help — here's the one-line version." |
| "We need to refactor before adding this" | "The foundation this sits on wasn't built for it. Reinforcing it costs a week now; skipping that roughly doubles the cost of everything we build after." |
| "AI wrote most of it but I have to review everything" | "AI genuinely sped up the drafting — roughly Nx on that part. Checking it, fixing what it got confidently wrong, and wiring it into our systems is human work, and for this task that was always the bigger share." |
| "The model hallucinates" | "The AI sometimes produces confident, wrong answers. In our domain a wrong answer costs <business consequence>, so every output needs a verification layer — that layer is the work." |
| "CI is red / the build is broken" | "Our automated safety checks are catching a real problem. Shipping before they pass means shipping the problem to customers." |
| "The requirements changed" | "What we're building today is bigger than what we scoped: <concrete delta>. The new date matches the current scope; if we return to the original scope, the original date holds." |
| "I underestimated it" | "My two-week estimate was wrong — I mis-sized <specific part>. Corrected, it's N weeks, and this time the estimate comes from work completed, not work imagined." |
| "It's only a few hundred bucks" | "$X/month — under Y% of our <relevant> bill." Precision reads as control; "only" reads as dismissing the manager's job. |
| "We have no audit trail / no visibility into X" | "If X changes today, we can't say who, when, or why — and that answer can't be added retroactively." |

## Analogy bank

One per brief, matched to gap type. Skip the analogy entirely if the plain statement is already clear — an unnecessary analogy reads as talking down.

| Gap type | Analogy |
|----------|---------|
| Iceberg | "The house has walls and a roof — it photographs great. Move-in ready means plumbing, wiring, and inspection, and that was always most of the build." |
| Last-mile integration | "We bought a great appliance; it works on the showroom floor. Our kitchen's plumbing and wiring weren't built for it — the installation is the project." |
| Demo vs. product | "What you saw was the concept car. It really drives — on a closed track, with a professional driver. The production car has to survive every customer, every day." |
| Dependency drag | "The house is done; we're waiting on the city inspector. We can't paint our way to a permit — but a call from you might move our place in line." |
| Quality bar | "The kitchen can plate the dish, but it wouldn't pass a health inspection. Serving it anyway doesn't make us fast — it makes us the restaurant people warn each other about." |
| AI reality check | "AI is a power tool, not a finished carpenter. The sawing got 10x faster; measuring, fitting, and making sure the house doesn't fall down is still the craftsman — and that was always most of the job." |
| Moving target | "We were asked for a garage and we're now building a two-car garage with a workshop. Happy to build it — it just isn't priced or scheduled like a garage anymore." |
| Estimate miss | Usually no analogy. A clean "my estimate was wrong, here's the corrected one and why it's trustworthy" outperforms any metaphor. |
| Insurance ask | "It's a smoke detector: cheap, boring, and impossible to install after the fire. The expensive version of this conversation is the one we'd have mid-incident." |
| Invisible work | "It's the building's maintenance crew: the proof it's working is that you never think about it. The month we skip it is the month everyone does." |

## Hard-question answer patterns

Build the Phase 4 prep from these skeletons, filled with interview specifics.

**"Why am I only hearing about this now?"**
Pattern: when it was discovered → why it wasn't visible earlier → what changes so it's visible sooner next time.
> "We confirmed it Tuesday, when the first end-to-end test hit real data — that test couldn't run earlier because <reason>. Going forward you'll get a weekly risk line from me, so nothing lands on you cold again."
Never: "I didn't want to worry you." That sentence converts one late feature into a trust problem.

**"Can't we just add more people?"**
Pattern: acknowledge the instinct → where adding helps → where it slows things down → the concrete version of the offer.
> "For <parallelizable part>, yes — one more person saves about a week. The core problem is sequential: a new person costs us two weeks of ramp-up before they contribute. If you can free up <specific person who has context>, that's the version of 'more people' that actually moves the date."

**"I thought AI was supposed to make this 10x faster?"**
Pattern: validate where it did help (quantified) → name what it can't absorb → tie to the plan.
> "It did — writing the first version took days instead of weeks, and that saving is already in this plan. What AI doesn't shrink is verifying the output is correct and wiring it into our systems, and for this task that was always the bigger share. The plan you're looking at is *with* AI; without it, we'd be talking months."

**"What can you give me by <earlier date>?"**
Pattern: never bare "nothing"; offer the scope-cut menu.
> "Not the full thing credibly. By <date> I can give you <reduced scope> — that covers <the business need it still serves>. The rest lands <date>. Want me to write up the trade-off so you can choose?"

**"How sure are you about the new date?"**
Pattern: stated confidence → the one risk that moves it → when that risk resolves → cadence.
> "About 80%. The one thing that moves it is <risk>, and I'll know by <day>. You'll hear from me every Friday either way — and immediately if that risk fires."

**"Why now, if nothing happened?"** (proposal shape)
Pattern: after-the-fact is the expensive time → the protection/evidence can't be backfilled → the small version already hurt.
> "Because this only covers events from the day it's turned on — we can't retroactively answer questions about last month. And we've already had the slow, partial version of that question; I want the next one to take minutes."

**"Can't we do this cheaper?"** (proposal shape)
Pattern: name what the free/cheaper tiers miss — only after actually verifying. Never claim an evaluation that didn't happen.
> "The free options track <coarser level>; they specifically miss <the thing that's half the point>. I checked the main ones — happy to send the one-paragraph comparison."

**"Does this grow into a big number?"** (proposal shape)
Pattern: pricing model stated honestly → a review checkpoint instead of a fake flat figure → a self-imposed ceiling.
> "It's priced per <unit>, so it scales with activity — that's why I'll report the actual number after month one rather than promise a flat figure. If it trends past <ceiling>, you'll hear from me before it gets there."

**"If we cut this in half, what actually happens?"** (defense shape)
Pattern: a named, specific risk backed by last-lapse evidence — never vague doom → then an informed-cut menu, so the engineer is the one offering options.
> "Half means dropping <specific activity>. The last time that lapsed, we got <concrete event and what it cost us>. If the budget has to shrink, the cut I'd stand behind is <smaller, named trim> — it saves $X, and the risk it accepts is <specific>."

**"So what have you been doing all this time?"**
(Usually frustration, not an audit.) Pattern: one sentence of concrete completed work → pivot straight to plan. Do not unroll an activity log — effort narration reads as defensiveness.
> "The core engine is built and working — that part is done and de-risked. What I mis-sized is <X>. Here's the corrected plan."

## Worked examples

### 1. Feature slip (Iceberg)

**Engineer's raw version:**
> "So the export feature is taking longer than expected. The UI is done but the backend has a lot of edge cases, and honestly the CSV parsing library we picked has weird bugs with big files. Also tests keep failing on CI. Probably another two or three weeks? Hopefully. Sorry."

**After the interview** (surfaced: UI demoed last sprint → source of "it's done"; large-file handling is the real remaining work; 80%-confidence date is 3 weeks; a small-files-only version could ship in 1 week):

> **Export: working for typical files today; full-size support lands March 21. Decision for you below.**
>
> **What's solid:** the export screen you saw is real, and exports work end-to-end for typical files (up to ~10MB).
>
> **What we learned:** testing with real customer data showed the largest accounts export files 50x bigger than our design assumed, and those currently fail. That's the remaining work — making big exports reliable, not building more screens.
>
> **Plan:** full-size support done March 21 (I'm ~80% on that; the one risk is <X>, known by the 10th). Option: ship typical-file export to everyone this Friday and finish large accounts by the 21st.
>
> **Ask:** ship partial Friday, or hold for complete on the 21st? Happy to go either way.
>
> **If it's useful upward:** "Export works and is in final hardening for our largest customers; full rollout March 21."
>
> Next update Friday, or immediately if anything moves the date.

### 2. Tech not integrated (Last-mile)

**Engineer's raw version:**
> "The vendor SDK technically works but their auth doesn't play well with our SSO, their webhooks are flaky, and staging doesn't match prod so I can't even test properly. It's a mess. No idea on a date until they answer our ticket."

**After the interview** (surfaced: SDK proven in isolation; three integration issues, two under our control ~2 weeks; third blocked on vendor ticket, open 6 days; vendor escalation path exists via account manager):

> **The integration works in isolation; connecting it to our systems is the current phase — two of three issues are ours and land in ~2 weeks, one needs vendor help and that's my ask.**
>
> **What's solid:** the vendor's product does what we bought it for — verified end-to-end in a controlled setup.
>
> **Where we are:** connecting it to our login system and our infrastructure surfaced three issues. Two are on our side, fixes underway, done in ~2 weeks. The third requires the vendor; our ticket has been with them 6 days without a real response.
>
> **Ask:** a nudge from you to their account manager would likely move us up their queue — here's a one-liner you can send. That's the difference between 2 and 4+ weeks.
>
> **If it's useful upward:** "The technology is proven; we're in the integration phase, on a two-week track, pending one vendor response we're escalating."
>
> Next update Tuesday, or same-day when the vendor responds.

Note the dependency handling: facts and dates, an escalation the manager can act on, zero vendor-bashing.

### 3. AI didn't 100x the work (AI reality check + iceberg)

**Engineer's raw version:**
> "My manager saw a demo where someone built an app with AI in an afternoon and now thinks our migration should take days. AI helps but it hallucinates column mappings, I have to review every script anyway, and honestly the hard part is that nobody documented the legacy schema. How do I tell him it's still six weeks without sounding like I'm making excuses or bad at AI?"

**After the interview** (surfaced: AI cut script-writing ~70%, already reflected in the 6 weeks; core difficulty is undocumented legacy data meanings — a human-archaeology problem; wrong migration = silent customer-data corruption; checkpoint: 3 of 12 modules migrated and verified by Friday):

> **Migration is on a six-week track — and that's the *with-AI* number. Here's where AI moved the needle and where the real bottleneck is.**
>
> **Where AI delivered:** writing the migration scripts is ~70% faster than it would've been by hand. That saving is already inside the six weeks; without AI this would be a four-month project.
>
> **The actual bottleneck:** the legacy system's data meanings were never documented — before anything can be migrated, a human has to establish what each field actually means, often by finding the person who built it. AI can't recover knowledge that was never written down. And because a wrong guess silently corrupts customer data, every AI-drafted script gets human verification. The demo your comparison came from had neither constraint: greenfield app, no legacy, nothing to corrupt.
>
> **Proof over promises:** 3 of 12 modules migrated and verified by Friday — I'd rather show you a working slice than argue about timelines.
>
> **If it's useful upward:** "We're using AI where it pays — it's already cut this project nearly in half. The remaining timeline is driven by verifying decades of undocumented data, which is exactly what you want us to be careful with."
>
> Nothing needed from you; next update Friday with the first three modules.

**Sample hard-questions prep for this case:**
- *"The demo guy did a whole app in an afternoon."* → "And for greenfield work we get similar speedups — that's real. This project's constraint is undocumented legacy data and a zero-tolerance for corruption; the demo had neither."
- *"Can a better AI tool close the gap?"* → "I've evaluated <what was actually tried, from the interview>. The bottleneck isn't generation quality — it's that the source knowledge doesn't exist in any system. Happy to re-test as tools improve; I don't expect it to move this project's date."
- *"Six weeks is too long. What are my options?"* → Scope-cut menu: "Modules 1–5 cover <core business flow> and can be live in 3 weeks; the long tail is the remaining three."

### 4. Proactive spend ask (Insurance ask)

**Engineer's raw version:**
> "I want to enable object-level audit events on our cloud storage. It's a few hundred a month. Right now if someone asks who changed a file or why data moved to a different storage class, digging through what we have takes hours and might come up empty. Management will just see a new line on the bill."

**After the interview** (surfaced: customer and compliance-relevant data; ~$200–400/mo, a small % of the storage bill; the "cheaper options" answer was a gut call → flagged for verification before sending; ask type: awareness with default-yes):

> **Subject: Small spend heads-up — audit trail for customer data storage (~$300/mo)**
>
> [Name] — flagging a monthly cost I'm adding, with room to veto. No action needed if you're fine with it.
>
> **What:** detailed change-tracking on our customer data storage — **$200–400/month**, a small fraction of our storage bill.
>
> **Why:** today, if a customer file is changed or deleted, or data quietly moves to a slower storage class, we can only partially reconstruct what happened — hours of work, possibly incomplete. That touches customer trust, audit readiness, and the bill itself. Nothing has gone wrong — which is exactly why now is the cheap moment: this trail can't be backfilled after an incident.
>
> **Plan:** enabled by [date]. After the first month I'll send the actual cost and an example of what it caught.
>
> **If it's useful upward:** "We're adding full change-auditing on customer data storage — a few hundred dollars a month, closed proactively before an audit or incident asks for it."

Note the mechanics: cost always ships with its denominator, the decision is pre-made with a veto window (not reopened as a question), and the checkpoint is a month-one cost review instead of a promised flat figure.
