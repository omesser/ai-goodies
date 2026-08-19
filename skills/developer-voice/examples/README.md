# A/B test: developer-voice on and off

Side-by-side output from five prompts, with and without the skill loaded.
[`dev_voice_off.md`](dev_voice_off.md) is the baseline, [`dev_voice_on.md`](dev_voice_on.md)
is the treatment. Nothing here is read by the skill — `SKILL.md` is the only file that loads,
and it doesn't reference this directory.

## Method

Each run was a fresh `claude -p` session started from a directory with no `AGENTS.md`, so no
conversation history or repo instructions carried over.

| Arm | Command | In context |
|---|---|---|
| Baseline | `DEV_VOICE_OFF=1 claude -p "<prompt>"` | Neither |
| Treatment | `claude -p "<prompt>"` | `developer-voice` only |

`DEV_VOICE_OFF` is read by a guard in the `SessionStart` hook, so the baseline never receives
the rules. Telling an agent to ignore rules already in its context is not a baseline.

**Ponytail was disabled in both arms.** A first attempt left it enabled and produced a
near-null result: ponytail already enforces lead-with-the-answer and no padding, so it was
doing most of the work being measured. Any A/B against a voice skill has to account for the
other personas in the session.

Prompts 1–2 ran once per arm. Prompts 3–5 ran twice per arm, to see how much of the difference
survives run-to-run noise.

## Results

Word counts exclude fenced and inline code. Prompts 3–5 show the mean of two runs.

| Prompt | Surface | Baseline | Voice | Spread: baseline → voice |
|---|---|---|---|---|
| 1. Retry advice | Chat | 470 | 474 | — (single run) |
| 2. Release note | Prose artifact | 180 | 156 | — (single run) |
| 3. Code review | Review comments | 524 | 523 | **119 → 10** |
| 4. Slack message | Artifact on a wrong premise | 206 | 372 | **106 → 30** |
| 5. Docstring + errors | Code documentation | 76 | 66 | **35 → 13** |

### The clearest effect is consistency, not brevity

Across all three repeated prompts, the treatment's run-to-run spread collapsed — 4× to 12×
tighter than baseline. On the code review the two treatment runs landed 10 words apart while
the two baseline runs differed by 119.

That is the effect a skill is supposed to have. The point of writing the rules down is that
the same input takes the same path twice, and the numbers show that happening.

### A rule firing reliably

The skill tells the agent to say what it liked in a review comment, taken from
[Google's eng-practices](https://google.github.io/eng-practices/review/reviewer/comments.html).

| Run | Closing section |
|---|---|
| Baseline rep 1 | `Blocking`, `Non-blocking`, `Suggested shape` |
| Baseline rep 2 | `Blockers`, `Should fix`, `Nits`, `Rough shape after the fixes` |
| Voice rep 1 | `Blocking`, `Non-blocking`, **`What works well`** |
| Voice rep 2 | `Blockers`, `Correctness`, `Worth considering`, **`What's good`** |

Present in 2 of 2 treatment runs, absent from 2 of 2 baseline runs.

### Register inside the deliverable

Prompt 4 asked for a Slack message. Both arms pushed back on the premise first — neither
flattered, so the anti-sycophancy rules had nothing to catch. The difference shows up in the
artifact:

| | Baseline draft | Voice draft |
|---|---|---|
| Opening | `:wave: Heads up` / `📣` | A sentence-case heading |
| Structure | `TL;DR` block | Named what the team gives up, plus a rollback plan |

`TL;DR` is on the skill's substitution list. Both baseline runs used it; neither treatment run
did.

## What this does not show

**The skill does not reliably shorten output.** Two prompts got shorter, one was flat, and two
got longer — prompt 4 by 80%. Length follows the question. Treat "makes output shorter" as
unsupported.

**Sycophancy never appeared in the baseline.** No run opened with flattery, so the
substitutions table for `Great question!` and friends went untested here. Either the model
doesn't need that rule on prompts like these, or these prompts don't provoke it.

**Two runs is thin.** The variance finding is the most interesting result and rests on two
samples per condition. It deserves more runs before anyone leans on the number.

One metric was computed and dropped: average sentence length. Table rows in the treatment
inflate the sentence count and make the figure meaningless.

## Reproducing

```bash
DEV_VOICE_OFF=1 claude -p "<prompt>"   # baseline
claude -p "<prompt>"                   # treatment
```

Run each as the first message of a fresh session. Two turns of one session share context, so
the second answer imitates the first regardless of the hook. Disable other persona plugins in
both arms. See [`../README.md`](../README.md) for the hook and its guard.
