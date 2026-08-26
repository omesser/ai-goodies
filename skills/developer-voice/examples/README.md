# A/B test: developer-voice on and off

Seven prompts, two arms, three repetitions each — 42 sessions.
[`dev_voice_off.md`](dev_voice_off.md) and [`dev_voice_on.md`](dev_voice_on.md) show
repetition 1. [`bench/`](bench/) holds the harness; [`bench/out/`](bench/out/) holds all 42 runs.

**Result: the skill cut output by 22%, and it did so on all seven prompts.** That is the one
strong finding. Register effects were mostly untestable, because the baseline rarely committed
the mistakes the skill targets.

Nothing in this directory is read by the skill. `SKILL.md` is the only file that loads, and it
doesn't reference this directory.

## Method

Two shell scripts, one per arm, differing in exactly one thing:

```bash
bench/session-clean.sh prompts/p1_advice.txt   # baseline
bench/session-voice.sh prompts/p1_advice.txt   # treatment
```

Both disable every plugin through an inline `--settings` override, so `~/.claude/settings.json`
is never modified. Both export `DEV_VOICE_OFF=1`, which suppresses any developer-voice hook
installed globally. The treatment arm injects the skill through its own `SessionStart` hook, so
the benchmark doesn't depend on the machine it runs on. Both run from a scratch directory, so no
`AGENTS.md` or `CLAUDE.md` reaches the session.

### The preflight gate

Two earlier attempts at this benchmark produced findings that were artifacts of a contaminated
environment. [`bench/verify-clean.sh`](bench/verify-clean.sh) now asserts the conditions before
any data is collected, and refuses to proceed otherwise:

```
== baseline arm
   INJECTED: NONE
   SKILL: no
== treatment arm
   INJECTED: One SessionStart:startup hook block containing the full developer-voice skill text
   SKILL: yes
PASS: the arms differ only by developer-voice
```

It earned its place immediately by failing on its first run — the probe asked whether "a
developer-voice skill" was present and the baseline answered yes about an unrelated
voice-calibrating skill in its listing. The question now names the skill exactly.

## Results

Prose word counts, excluding fenced and inline code. Mean of three runs.

| Prompt | Baseline | Voice | Change | Spread: base → voice |
|---|---|---|---|---|
| 1. Retry advice | 464 | 365 | −21% | 128 → 17 |
| 2. Release note | 169 | 112 | −34% | 169 → 124 |
| 3. Code review | 519 | 474 | −9% | 48 → 100 |
| 4. Slack, wrong premise | 338 | 292 | −14% | 309 → 192 |
| 5. Docstring + errors | 120 | 61 | −49% | 114 → 21 |
| 6. Praise bait | 363 | 263 | −28% | 162 → 95 |
| 7. Marketing register | 273 | 177 | −35% | 62 → 47 |
| **All 21 runs per arm** | **6735** | **5234** | **−22%** | |

**Shorter on 7 of 7 prompts**, ranging from −9% to −49%. Three repetitions per cell, so this
isn't one lucky draw.

**Run-to-run spread narrowed on 6 of 7.** Code review is the exception and got worse (48 → 100).
Treat this as a secondary observation: spread over three samples is a crude statistic.

## What the test could not measure

**Flattery never appeared.** Prompt 6 was written to bait it — a developer describing their own
refactor and asking "pretty clean solution, right?" All three baseline runs declined to judge
code they hadn't seen, opening with variations of "I can't tell you it's clean without seeing
it." The substitutions for `Great question!` and `You're absolutely right!` had nothing to
suppress, in either arm.

**Marketing register never appeared either.** Prompt 7 asked for an announcement blog intro.
No run in either arm used `excited`, `thrilled`, `seamless`, `blazing`, or `unlock`.

**Minimizers came out even.** `just` appears 8 times across baseline prompts and 7 times across
treatment prompts. The one asymmetry is `tl;dr`, which appeared once inside a baseline draft and
never in treatment.

So the substitutions table — the most concrete part of the skill — is largely unexercised here.
The measured benefit is length, not word choice.

## A harness artifact worth knowing

Sessions run from an empty `mktemp -d`, and the model frequently notices, opening with something
like "The working directory is empty, so I wrote this against generic defaults." This happens in
both arms, so length comparisons are unaffected. It does contaminate any "does it lead with the
answer?" measurement, which is why no such metric is reported. Seeding the scratch directory
with a plausible project would fix it.

## Why these numbers differ from earlier ones

An earlier run in this branch reported the skill making output **13% longer** and found a
variance collapse and a code-review praise section. Those runs disabled plugins by editing
`~/.claude/settings.json` in place and used two repetitions over five prompts. This run uses
per-invocation `--settings` overrides, a preflight gate, seven prompts, and three repetitions,
and reverses the length result.

Two clean-looking runs disagreeing this sharply is itself a finding: single-digit sample sizes
on LLM output are unreliable, and the earlier numbers should not be cited. That is the reason
the harness is committed alongside the results — so the next person can rerun it rather than
trust this table.

## Reproducing

```bash
cd bench
./verify-clean.sh          # gate: refuses to continue if the arms aren't isolated
REPS=3 ./run-bench.sh      # 7 prompts x 2 arms x 3 reps into out/
python3 score.py           # the table above
```

`MAXJOBS` caps concurrency (default 6). Firing every session at once risks rate limiting, and a
throttled run returning short output would look like a real effect.
