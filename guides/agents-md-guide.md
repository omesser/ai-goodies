# How to write a good AGENTS.md / CLAUDE.md

`AGENTS.md` and `CLAUDE.md` are read by Claude at the start of every session in a repo. They set the operating context — what this codebase is, how to work in it, and what behavior to default to.

## CLAUDE.md vs AGENTS.md

| | CLAUDE.md | AGENTS.md |
|--|-----------|-----------|
| Read by | Claude Code (Anthropic) | Codex, Cursor, and other agent tools + Claude Code |
| Convention | Anthropic standard | Emerging open standard |
| Typical use | Put `@AGENTS.md` here and keep real content in AGENTS.md for cross-tool portability |

Many repos now use both: `CLAUDE.md` contains just `@AGENTS.md`, and `AGENTS.md` has the real content. See [`templates/AGENTS-general.md`](../templates/AGENTS-general.md).

## What belongs in AGENTS.md

**Good content:**
- Organization/project context (what is this, what does it do)
- Key entry points (what files matter, how to run things)
- Architecture decisions the agent should know to not violate them
- Git policy (never commit without approval, never push to main, etc.)
- When to spawn subagents vs summarize
- Escalation rules (stop and ask vs proceed)
- Behavior defaults (prefer reading code, do the minimum asked, etc.)

**Leave out:**
- Things already in code (the agent can read the code)
- Things already in git history (the agent can run `git log`)
- Comprehensive architecture diagrams (link to docs instead)
- Full API references (link to them)

## Patterns from this repo

### General behavior guide (any repo)

See [`templates/AGENTS-general.md`](../templates/AGENTS-general.md) — covers:
- Organization context
- Behavior defaults
- When to spawn subagents
- Escalation rules
- Review bar for this type of work

### Convention routing table (docs-heavy projects)

See [`templates/AGENTS-fullstack-project.md`](../templates/AGENTS-fullstack-project.md) — the routing table pattern:

```markdown
| If you're working on... | Read at least |
|-------------------------|---------------|
| A backend controller    | `api-design.md`, `error-handling.md` |
| A React component       | `libraries.md` |
```

This keeps AGENTS.md small while directing the agent to the right doc for the task.

### Minimal single-link

See [`templates/AGENTS-minimal.md`](../templates/AGENTS-minimal.md) — for projects with a single conventions doc.

## What belongs in CLAUDE.md (project-specific)

CLAUDE.md can supplement AGENTS.md with project-specific commands, architecture invariants, and tooling rules. See `templates/CLAUDE-*.md` for examples:

- **Commands section**: how to run tests, lint, build, dev server
- **Architecture section**: patterns the agent must not break (e.g. "never add `from __future__ import annotations` to predictor files")
- **Git policy**: project-specific commit/push rules
- **Tooling**: which tools are required, how they're configured
