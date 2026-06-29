# ai-goodies

Collected AI/agentic engineering artifacts from various codebases — ready to adapt for general-purpose software engineering.

## What's here

| Directory | Contents |
|-----------|----------|
| [`templates/`](templates/) | AGENTS.md and CLAUDE.md starters for different project types |
| [`skills/`](skills/) | Claude Code slash-command skills (`.claude/skills/` or `.agents/skills/`) |
| [`commands/`](commands/) | Example `.claude/commands/` files (project-specific slash commands) |
| [`settings/`](settings/) | `.claude/settings.json` examples (global + local) |
| [`guides/`](guides/) | How-to prose: AGENTS.md, skills, plugins |

## Skills

| Skill | General-purpose? | Notes |
|-------|------------------|-------|
| [`security-review/`](skills/security-review/) | ✅ Yes - in startup/high-tech context | Full scan: Python, Terraform, K8s, JS, Go, Shell, Helm, secrets |
| [`release-notes/`](skills/release-notes/) | ✅ Yes | Git + Jira + GitHub PR enriched release notes |
| [`reviewer-roulette/`](skills/reviewer-roulette/) | ✅ Yes — needs `docs/ownership-map.md` | Pick one reviewer from git history + ownership map |
| [`reindex-docs/`](skills/reindex-docs/) | Partial — uses monorepo build scripts | Pattern is general; script invocation is build-tool-specific |


## Templates

| File | Best for |
|------|----------|
| [`AGENTS-general.md`](templates/AGENTS-general.md) | Top-level agent behavior guide for any repo |
| [`AGENTS-fullstack-project.md`](templates/AGENTS-fullstack-project.md) | Projects with multiple convention docs; routing table pattern |
| [`AGENTS-minimal.md`](templates/AGENTS-minimal.md) | One-liner that links to a conventions doc |
| [`CLAUDE-context-mode-routing.md`](templates/CLAUDE-context-mode-routing.md) | CLAUDE.md for context-mode plugin repos |
| [`CLAUDE-python-package.md`](templates/CLAUDE-python-package.md) | Python library: nox, uv, ruff, setuptools_scm |
| [`CLAUDE-python-ml-pipeline.md`](templates/CLAUDE-python-ml-pipeline.md) | ML inference pipeline: config, predictors, tests, lint |
| [`CLAUDE-fullstack-app.md`](templates/CLAUDE-fullstack-app.md) | CDK + Lambda + PWA; good general workflow preferences section |
| [`CLAUDE-fastapi-react-app.md`](templates/CLAUDE-fastapi-react-app.md) | FastAPI + React + SQLite; RBAC, module system, air-gapped |

## Commands

Commands in `.claude/commands/` become `/command-name` in Claude Code. These examples are ML-pipeline-specific, but the patterns (readiness checklist, step-by-step workflow guide, run-local) transfer to any project.

## Guides

| Guide | Covers |
|-------|--------|
| [`agents-md-guide.md`](guides/agents-md-guide.md) | Writing a good `AGENTS.md` / `CLAUDE.md`; CLAUDE.md vs AGENTS.md |
| [`skill-authoring.md`](guides/skill-authoring.md) | Anatomy of a Claude Code skill and where skills live |
| [`plugins.md`](guides/plugins.md) | Installed plugins and how plugin marketplaces work |

## OSS skills worth installing

These are open-source Claude Code skills — install directly rather than copying.

| Skill | Repo | Install | What it does |
|-------|------|---------|--------------|
| `context-mode` | https://github.com/mksglu/context-mode | `claude plugin install context-mode --from github:mksglu/context-mode` | Routes large-output commands through a sandbox MCP server so raw bytes don't flood context. Includes `ctx_execute`, `ctx_batch_execute`, `ctx_execute_file`, `ctx_fetch_and_index`, `ctx_search` tools and a full set of `/ctx-*` skills. |
| `openhop` | https://github.com/naorsabag/openhop | `claude plugin install openhop --from github:naorsabag/openhop` | Interactive step-by-step data-flow diagram server. Claude pushes YAML flows; you step through them hop by hop. Also in this repo as a copied skill since we had it locally. |
| `ponytail` | https://github.com/DietrichGebert/ponytail | `claude plugin install ponytail --from github:DietrichGebert/ponytail` | Lazy senior dev persona that enforces the YAGNI ladder before building anything. |

## Installed plugins (global settings)

| Plugin | Repo | What it does |
|--------|------|--------------|
| `context-mode` | `mksglu/context-mode` | Sandbox large-output commands; MCP tools |
| `ponytail` | `DietrichGebert/ponytail` | Lazy senior dev persona; enforces YAGNI ladder |
| `openhop` | `naorsabag/openhop` | Interactive data-flow diagram server |

## Quick start: new repo setup

1. Copy `templates/AGENTS-general.md` → `AGENTS.md`, edit org name and stack.
2. Copy `templates/CLAUDE-*.md` that fits your stack → `CLAUDE.md`, strip project-specific sections.
3. Install skills you want into `.claude/skills/<name>/` (or `~/.claude/skills/` for user-global).
4. Copy `settings/settings.local.example.json` → `.claude/settings.local.json`, tune permissions. For global plugins/hooks, see `settings/settings.global.example.json`.
5. Add slash commands to `.claude/commands/` as needed.
