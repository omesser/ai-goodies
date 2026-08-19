# developer-voice — activation

`SKILL.md` is the single source of truth for the rules. This file only covers how to get them
in front of the agent, and how long they stay there.

The skill is `disable-model-invocation: true`, so the agent never fires it on its own. That's
deliberate: an agent that switches its own register mid-task is unpredictable in exactly the
way a voice skill is supposed to prevent. You decide when the register changes.

To see what it actually does to output before installing it, read
[`examples/`](examples/) — the same two prompts answered with the skill off and on, plus the
method and the measured differences.

## Install first

Every mode below needs the skill folder on disk. Mode 2 in particular points a hook at
`SKILL.md` by path, so install before you write the hook.

```bash
npx skills add omesser/ai-goodies --skill developer-voice
```

Or copy `skills/developer-voice/` into `~/.claude/skills/` (user-level) or
`.claude/skills/` (project-level). See [Installing a skill](../../README.md#installing-a-skill)
for the other agents. Note which location you chose — the hook paths in Mode 2 depend on it.

## Mode 1 — per session, by hand

```
/developer-voice
```

The rules load as a turn in the conversation and stay in context for the rest of the session.
Good enough for a focused session of writing-heavy work.

Two limits worth knowing:

- **Drift.** Instructions injected once lose salience over a long session. They aren't
  load-bearing the way a system prompt is.
- **Compaction.** When the context window fills, the turn holding these rules can be
  summarized down or dropped. Re-invoke `/developer-voice` if the voice slips.

Mode 2 fixes both.

## Mode 2 — always on, via hooks (recommended)

A `SessionStart` hook prints the rules on every new session, so they arrive before your first
prompt. Its stdout is injected into the model's context, which is what makes it an activation
lever rather than just a terminal message.

Add to the project's `.claude/settings.json`, or `~/.claude/settings.json` for every repo:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "cat \"$CLAUDE_PROJECT_DIR/.claude/skills/developer-voice/SKILL.md\"",
            "timeout": 5
          }
        ]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat \"$CLAUDE_PROJECT_DIR/.claude/skills/developer-voice/SKILL.md\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

For a user-level install, swap the path for `~/.claude/skills/developer-voice/SKILL.md`.

**The matcher carries the weight.** All four values matter for a voice:

| Matcher | Fires when | Why it's in the list |
|---|---|---|
| `startup` | Fresh `claude` invocation | The base case |
| `resume` | `--resume` / `--continue` | Without it, resumed sessions lose the voice |
| `clear` | `/clear` | `/clear` wipes context, rules included |
| `compact` | After compaction | Re-injects the rules the moment compaction drops them, so Mode 1's drift problem self-heals |

Omitting `matcher` (or `""`) fires on all events, which works but hides the intent. Name them.

`SubagentStart` matters because a subagent writing your PR description has otherwise never
heard of the voice.

Zero duplication — both hooks read the same `SKILL.md`.

Two costs to weigh:

- **Tokens on every session.** `SKILL.md` is roughly 1.2k tokens, spent whether or not that
  session involves prose. That's the argument for the project-scoped `.claude/settings.json`
  over the global file.
- **Hook config is snapshotted at startup.** Editing `settings.json` mid-session changes
  nothing until you restart. Check what's actually loaded with `/hooks`.

Skip `UserPromptSubmit`. It re-injects on every turn, which is the strongest anti-drift
option and the wrong trade here — paying 1.2k tokens per turn to enforce prose style, when
`SessionStart` with `compact` already covers the realistic failure modes.

## Mode 3 — project instruction files (not recommended)

Copying the rules into `AGENTS.md` or `CLAUDE.md` gives the strongest persistence, since those
load every session at the top of context and take precedence over default behavior.

**It costs you a second copy of the rules to maintain**, which is why it isn't the recommended
path. Two copies drift, and the one in `AGENTS.md` is the one that will go stale. Reach for it
only when you need agents other than Claude Code to pick up the voice from the repo's
instruction files, and accept the maintenance burden when you do.

## Not the mechanism

Making the skill model-invoked does **not** help persistence — it only changes who can trigger
it. Once triggered, a model-invoked skill has exactly the same drift and compaction behavior as
Mode 1. Persistence comes from re-injection (Mode 2) or from the instruction files (Mode 3).
