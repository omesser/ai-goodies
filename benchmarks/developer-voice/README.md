# A/B test: developer-voice on and off

Seven prompts, two arms, three repetitions — 42 sessions.
[`dev_voice_off.md`](dev_voice_off.md) and [`dev_voice_on.md`](dev_voice_on.md) show
repetition 1. [`bench/`](bench/) holds the harness, [`bench/out/`](bench/out/) all 42 runs.

**The skill cut output 22%, on all seven prompts.** That is the one strong finding. Register
effects went unmeasured because the baseline rarely made the mistakes the skill targets.

The skill itself is [`skills/developer-voice/`](../../skills/developer-voice/). This benchmark
sits outside it so installing the skill doesn't drag 42 transcripts along; nothing here is read
at runtime either way.

## Method

```bash
bench/session-clean.sh prompts/p1_advice.txt   # baseline
bench/session-voice.sh prompts/p1_advice.txt   # treatment
```

The scripts differ in one thing: the treatment injects `SKILL.md` through its own `SessionStart`
hook. Both disable every plugin via an inline `--settings` override, so `~/.claude/settings.json`
is never modified. Both export `DEV_VOICE_OFF=1` to suppress any globally installed hook, and
both run from a scratch directory so no `CLAUDE.md` reaches the session.

[`bench/verify-clean.sh`](bench/verify-clean.sh) gates the run, because two earlier attempts
produced findings that were environment artifacts:

```
== baseline arm     INJECTED: NONE     SKILL: no
== treatment arm    INJECTED: developer-voice via SessionStart hook     SKILL: yes
PASS: the arms differ only by developer-voice
```

It earned its keep by failing first time: the probe asked about "a developer-voice skill" and the
baseline answered yes about an unrelated voice skill. It now names the skill exactly.

## Results

Prose words, code excluded, mean of three runs.

| Prompt | Baseline | Voice | Change | Spread |
|---|---|---|---|---|
| 1. Retry advice | 464 | 365 | −21% | 128 → 17 |
| 2. Release note | 169 | 112 | −34% | 169 → 124 |
| 3. Code review | 519 | 474 | −9% | 48 → 100 |
| 4. Slack, wrong premise | 338 | 292 | −14% | 309 → 192 |
| 5. Docstring + errors | 120 | 61 | −49% | 114 → 21 |
| 6. Praise bait | 363 | 263 | −28% | 162 → 95 |
| 7. Marketing register | 273 | 177 | −35% | 62 → 47 |
| **21 runs per arm** | **6735** | **5234** | **−22%** | |

Shorter on 7 of 7. Spread narrowed on 6 of 7; code review is the exception. Spread over three
samples is crude, so treat it as secondary.

## What went unmeasured

Two prompts were written to bait the untested rules. Neither bait landed.

- **Flattery.** Prompt 6 has a developer praising their own refactor and asking "pretty clean
  solution, right?" All three baseline runs declined to judge unseen code.
- **Marketing register.** No run in either arm used `excited`, `thrilled`, `seamless`, `blazing`,
  or `unlock`.
- **Minimizers.** `just` appears 8 times in baseline, 7 in treatment.

The substitutions table — the most concrete part of the skill — is therefore still unexercised.
The measured benefit is length, not word choice.

## Two caveats

**A harness artifact.** Sessions run from an empty `mktemp -d`, and the model often opens by
noting the directory is empty. It happens in both arms, so length holds, but it rules out any
"leads with the answer" metric. Seeding the scratch directory with a plausible project would fix
it.

**Earlier numbers were wrong.** A previous run on this branch reported output 13% *longer*, plus
a variance collapse and a code-review praise section. It edited `~/.claude/settings.json` in
place and used five prompts over two repetitions. Two clean-looking runs disagreeing this sharply
is itself the lesson: small samples on LLM output are unreliable. Rerun the harness rather than
trusting this table.

## Reproducing

```bash
cd bench
./verify-clean.sh        # refuses to continue if the arms aren't isolated
REPS=3 ./run-bench.sh    # 42 sessions into out/
python3 score.py         # the table above
```

`MAXJOBS` caps concurrency (default 6). Firing every session at once risks rate limiting, and a
throttled short answer would look like a real effect.
