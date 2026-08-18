# How to write a Claude Code skill

A skill is a markdown file that Claude treats as instructions when you invoke `/skill-name`. Skills live in:
- `.claude/skills/<name>/SKILL.md` — project-level (only active in this repo)
- `~/.claude/skills/<name>/SKILL.md` — user-level (active in all projects)
- `.agents/skills/<name>/SKILL.md` — alternative convention (Cursor-compatible)

## Minimal skill

```markdown
---
name: my-skill
description: One sentence: when should Claude activate this? Include trigger phrases.
allowed-tools: Bash(*), Write(*)
---

# My Skill

Instructions to Claude — write these as you would brief a junior developer.
```

## Frontmatter fields

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | Must match directory name. Used as `/name` command. |
| `description` | Yes | Shown in skill list. Include trigger conditions — Claude reads this to decide when to activate. Goes human-facing when `disable-model-invocation` is set. |
| `allowed-tools` | No | Scopes what tools the skill can use. Omit to inherit session permissions. |
| `disable-model-invocation` | No | `true` makes the skill user-invoked only. See below. |
| `version` | No | Semver for tracking |
| `tags` | No | Freeform categorization |

## Model-invoked vs user-invoked

By default a skill is **model-invoked**: Claude can fire it on its own, other skills can reach
it, and you can still type `/name`. The cost is that its `description` sits in the context
window every turn, so write the description for the model — lead with what triggers it, and
list one trigger per distinct use.

`disable-model-invocation: true` makes it **user-invoked only**. Nothing but you typing `/name`
can start it, and the `description` no longer reaches the model at all — rewrite it as a
one-line human-facing summary and strip the trigger phrasing. Context cost drops to zero, paid
for by you having to remember the skill exists.

Choose model-invoked only when the agent must reach the skill unprompted, or another skill must
reach it. Otherwise prefer user-invoked. Four skills here use it, for two distinct reasons:

- **The user owns the decision.** A voice or persona skill (`developer-voice`) that the agent
  re-triggered on its own would swap register mid-task.
- **The run is expensive or noisy.** `security-review`, `scrooge-check`, and
  `daily-news-briefing` each burn real time or tokens, so an autonomous trigger is a liability.

Invoking a skill is not the same as making it stick. The rules load as one turn, so they lose
salience over a long session and can be summarized away by compaction. When a skill needs to
hold for a whole session, drive it from a `SessionStart` hook instead — see
[`developer-voice/README.md`](../skills/developer-voice/README.md) for the hook shape and the
matchers that keep it alive across `/clear`, resume, and compaction.

## `${CLAUDE_SKILL_DIR}`

This env var resolves to the directory where `SKILL.md` lives. Use it in Bash commands to reference companion scripts:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/scan.sh
```

This works regardless of where the skill is installed (project-level, user-level, etc.).

## Companion scripts

Put scripts in the same directory as `SKILL.md`:

```
skills/my-skill/
├── SKILL.md
├── README.md          # Human-facing docs (install, usage, prereqs)
└── scripts/
    └── do-thing.sh
```

## Writing effective SKILL.md

- Write to Claude, not to humans. This is instructions, not documentation.
- Be explicit about trigger conditions in `description` — Claude decides whether to activate based on it.
- Structure as phases (Phase 0 → 1 → 2 etc.) for multi-step workflows.
- Use checklists for gates that must pass before proceeding.
- Reference companion scripts via `${CLAUDE_SKILL_DIR}`.
- Say what NOT to do, not just what to do.

## Good examples in this repo

- [`security-review/`](../skills/security-review/) — 7-phase workflow with compliance gates, companion scripts, auto-scoping
- [`release-notes/`](../skills/release-notes/) — optional external enrichment, graceful degradation
- [`reviewer-roulette/`](../skills/reviewer-roulette/) — minimal, single-outcome skill (pick one reviewer)
- [`developer-voice/`](../skills/developer-voice/) — user-invoked only; companion README covers hook-based activation
