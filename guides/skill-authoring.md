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
| `description` | Yes | Shown in skill list. Include trigger conditions — Claude reads this to decide when to activate. |
| `allowed-tools` | No | Scopes what tools the skill can use. Omit to inherit session permissions. |
| `version` | No | Semver for tracking |
| `tags` | No | Freeform categorization |

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
