# A/B test: developer-voice on and off

Five prompts, two arms, two repetitions each — 20 sessions.
[`dev_voice_off.md`](dev_voice_off.md) and [`dev_voice_on.md`](dev_voice_on.md) hold
repetition 1; [`raw/`](raw/) holds all 20 runs and the prompt files.

Nothing here is read by the skill. `SKILL.md` is the only file that loads, and it doesn't
reference this directory.

**Headline: the measured effect is small and mostly inconsistent.** One signal reproduced.
Read [What this test retracts](#what-this-test-retracts) before citing any earlier numbers.

## Method

Each run was a fresh `claude -p` session started from a directory with no `AGENTS.md`.

| Arm | Command | In context |
|---|---|---|
| Baseline | `DEV_VOICE_OFF=1 claude -p "<prompt>"` | Nothing |
| Treatment | `claude -p "<prompt>"` | `developer-voice` only |

`DEV_VOICE_OFF` is read by a guard in the `SessionStart` hook, so the baseline never receives
the rules. Telling an agent to ignore rules already in its context is not a baseline.

### Every plugin was disabled

`ponytail`, `context-mode`, `superpowers`, and `last30days` were all turned off for the whole
benchmark, then restored. This matters more than it sounds.

Two earlier attempts were invalidated by plugins injecting instructions into **both** arms:

- **Ponytail** enforces lead-with-the-answer and no padding — most of what was being measured.
- **context-mode** injects `Write artifacts to files. Return only: file path + 1-line
  description.` into every session, a direct constraint on output length.
- **Superpowers** injects its process block.

A session was probed before the benchmark to confirm no hook-injected block and no
length-constraining sentence remained.

## Results

Word counts exclude fenced and inline code. Two runs per cell.

| Prompt | Baseline (r1/r2, mean) | Voice (r1/r2, mean) | Direction |
|---|---|---|---|
| 1. Retry advice | 234 / 201 → **218** | 211 / 198 → **204** | −6% |
| 2. Release note | 101 / 120 → **110** | 33 / 77 → **55** | −50% |
| 3. Code review | 287 / 297 → **292** | 491 / 480 → **486** | **+66%** |
| 4. Slack message | 380 / 377 → **378** | 381 / 380 → **380** | ±0% |
| 5. Docstring + errors | 30 / 16 → **23** | 26 / 41 → **34** | +48% |
| **All 10 runs per arm** | **2043** | **2318** | **+13%** |

### What reproduced

**Fewer minimizers.** The word `just` appears 5 times across 4 baseline prompts and once in
one treatment prompt. It's the only substitution from the table that showed up often enough in
the baseline to measure, and the skill suppressed it.

**Sentence-case headings, weakly.** One baseline run titled the release note
`HTTP Client — Automatic Retries`; both treatment runs used sentence case. One instance out of
two is not much evidence.

### What did not

**Length.** Two prompts got shorter, one was flat, two got longer, and the total across all
runs was 13% *longer* with the skill on. There is no brevity effect here.

**Consistency.** Run-to-run spread went 33→13, 19→44, 10→11, 3→1, 14→15. Two improved, two
were flat, one got worse. No effect.

**Sycophancy.** No baseline run opened with flattery, so those substitutions had nothing to
suppress. Either the model doesn't need the rule on prompts like these, or these prompts don't
provoke it.

## What this test retracts

An earlier version of this file, and the commit that added it, reported two findings from runs
where `context-mode` and `superpowers` were still active. **Neither survives a clean
environment:**

| Earlier claim | Clean result |
|---|---|
| Run-to-run spread collapses 4–12× with the skill on | Mixed. Two better, two flat, one worse. |
| The skill adds a "what you liked" section to code reviews (2/2 vs 0/2) | Neither treatment run produced one. |

Both were artifacts of the plugin-contaminated environment, not effects of the skill. The
"say what you liked" instruction from eng-practices is in `SKILL.md` and did not fire in either
clean run — that's a gap in the skill, not a win for it.

## Honest read

On these five prompts, with no other instructions in play, `developer-voice` produced a small
reduction in minimizer words and no reliable change in length, structure, or consistency.

Two readings are available and this test doesn't separate them. The baseline may already write
close to the target register, leaving the skill little to correct. Or five prompts and two
repetitions may be too small to detect a real effect. Anyone extending this should add prompts
that provoke the failure modes the substitutions table targets — flattery, hedging, marketing
register — rather than the neutral technical prompts used here.

The skill is cheap and its rules are defensible on their own terms. This test does not show it
earning its keep on measurable output.

## Reproducing

```bash
DEV_VOICE_OFF=1 claude -p "<prompt>"   # baseline
claude -p "<prompt>"                   # treatment
```

Disable every persona and tooling plugin in both arms first, and probe a session to confirm
nothing injects output constraints. Run each prompt as the first message of a fresh session:
two turns of one session share context, so the second answer imitates the first regardless of
the hook. See [`../README.md`](../README.md) for the hook and its guard.
