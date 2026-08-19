# A/B test: developer-voice on and off

Side-by-side output from the same prompts, with and without the skill loaded.
[`dev_voice_off.md`](dev_voice_off.md) is the baseline, [`dev_voice_on.md`](dev_voice_on.md)
is the treatment. Nothing here is read by the skill — `SKILL.md` is the only file that loads.

## Method

Each arm ran as `claude -p` in a fresh session, from a directory with no `AGENTS.md`, so no
conversation history or repo instructions carried over.

| Arm | Command | In context |
|---|---|---|
| Baseline | `DEV_VOICE_OFF=1 claude -p "<prompt>"` | Neither |
| Treatment | `claude -p "<prompt>"` | `developer-voice` only |

`DEV_VOICE_OFF` is read by the guard in the `SessionStart` hook, so the baseline never receives
the rules at all. Telling the agent to ignore rules already in its context would not be a
baseline — the rules still influence it.

**The ponytail plugin was disabled for both arms.** A first run left it enabled and produced a
near-null result: ponytail already enforces lead-with-the-answer and no padding, so it was
doing most of the work being measured. Any A/B against a voice skill has to account for the
other personas in the session.

Both arms were probed first to confirm what each had loaded.

## What changed

Measured over both prompts:

| Signal | Baseline | Voice |
|---|---|---|
| Opening, prompt 1 | `Short answer: no.` | `No.` |
| Opening, prompt 2 | A caveat about missing repo details | The release note itself |
| Banned phrases | 4 hits — `Short answer`, `just`, `blast radius`, `thundering herd` | 0 |
| Code font spans, prompt 1 | 2 | 19 |
| Word count, prompt 1 | 470 | 474 |
| Word count, prompt 2 | 180 | 156 |

Three effects are visible in the transcripts:

1. **The answer moves to the front.** On prompt 2 the baseline opens with two sentences of
   caveat before the deliverable. The treatment opens with the release note and moves the
   caveat to the end, where it doesn't block the reader.
2. **Metaphors disappear.** `blast radius` and `thundering herd` in the baseline become literal
   descriptions of the failure mode.
3. **Values get code font.** Status codes, methods, and option names are marked up in the
   treatment and mostly bare in the baseline. This is the formatting rule doing visible work.

## What did not change

**Length, mostly.** Prompt 1 came out within 4 words across arms. The skill restructured that
answer — prose bullets became a decision table — without shortening it. Prompt 2 dropped 13%.

Treat "developer-voice makes output shorter" as unsupported by this test. It changes register
and structure. Length follows the question.

## Reproducing

```bash
DEV_VOICE_OFF=1 claude -p "<prompt>"   # baseline
claude -p "<prompt>"                   # treatment
```

Run each as the first message of a fresh session. Two turns of one session share context, so
the second answer imitates the first regardless of the hook. See
[`../README.md`](../README.md) for the hook and its guard.
