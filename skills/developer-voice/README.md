# developer-voice — activation

`SKILL.md` is the single source of truth for the rules. This file only covers how to get them
in front of the agent, and how long they stay there.

The skill is `disable-model-invocation: true`, so the agent never fires it on its own. That's
deliberate: an agent that switches its own register mid-task is unpredictable in exactly the
way a voice skill is supposed to prevent. You decide when the register changes.

Pick an activation mode based on how long you want it to hold.

## Mode 1 — per session, by hand

```
/developer-voice
```

The rules load as a turn in the conversation and stay in context for the rest of the session.
Good enough for a focused session of writing-heavy work.

Two limits worth knowing:

- **Drift.** Instructions injected once lose salience over a long session. The `## Persistence`
  stanza in `SKILL.md` pushes back on this, but it doesn't make the rules load-bearing the way
  a system prompt is.
- **Compaction.** When the context window fills, the turn holding these rules can be summarized
  down or dropped. Re-invoke `/developer-voice` after a compaction if the voice slips.

## Mode 2 — always on, via a SessionStart hook

The reliable way to make it "always on". A `SessionStart` hook prints the rules on every new
session, so they arrive before your first prompt and you never have to remember them.

Add to `~/.claude/settings.json` (see [`settings/settings.global.example.json`](../../settings/settings.global.example.json)
for the surrounding shape):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat ~/.claude/skills/developer-voice/SKILL.md"
          }
        ]
      }
    ]
  }
}
```

Zero duplication — the hook reads the same `SKILL.md`. Costs its tokens on every session,
including sessions with no prose in them, so scope it to the project's `.claude/settings.json`
rather than the global file if only some repos want it.

For a project-scoped copy, point the command at `.claude/skills/developer-voice/SKILL.md`.

## Mode 3 — always on, via project instructions

Copy the rules into `AGENTS.md` or `CLAUDE.md`, which load every session at the top of context
and take precedence over default behavior. The strongest persistence of the three.

The cost is a second copy of the rules to maintain. Prefer Mode 2 unless you want the voice to
apply to every agent that reads the repo's instruction files, not just Claude Code.

## Not the mechanism

Making the skill model-invoked does **not** help persistence — it only changes who can trigger
it. Once triggered, a model-invoked skill has exactly the same drift and compaction behavior as
Mode 1. Persistence comes from re-injection (Mode 2) or from the instruction files (Mode 3).
