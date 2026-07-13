# ai-goodies

Collected AI/agentic engineering artifacts from various codebases — ready to adapt for general-purpose software engineering.

## What's here

| Directory | Contents |
|-----------|----------|
| [`templates/`](templates/) | AGENTS.md and CLAUDE.md starters for different project types |
| [`skills/`](skills/) | Claude Code slash-command skills (`.claude/skills/` or `.agents/skills/`) |
| [`settings/`](settings/) | `.claude/settings.json` examples (global + local) |
| [`guides/`](guides/) | How-to prose: AGENTS.md, skills, plugins |

## Installing a skill

Every skill is a self-contained folder under [`skills/`](skills/) following the [Agent Skills](https://agentskills.io) open format — plain markdown, no build step, portable to any agent that supports the standard.

**Cross-agent**, via the [skills.sh](https://www.skills.sh) installer — it detects the agents on your machine (Claude Code, Codex, Cursor, Gemini CLI, 50+ others) and installs into each one's skills directory:

```bash
npx skills add omesser/ai-goodies                             # interactive picker
npx skills add omesser/ai-goodies --skill explain-to-manager  # just one skill
```

**Manually** — copy the folder into your agent's skills directory. The spec doesn't fix a location, so it depends on the agent: for Claude Code it's `~/.claude/skills/` (user-level) or `.claude/skills/` (project-level); `.agents/skills/` is a common agent-agnostic convention:

```bash
git clone https://github.com/omesser/ai-goodies
cp -r ai-goodies/skills/explain-to-manager ~/.claude/skills/
```

Then invoke it in a new session — e.g. `/explain-to-manager` in Claude Code. Skills that need extra setup (e.g. `security-review`'s scanners) document it in their own README.

## Skills

| Skill | General-purpose? | Notes |
|-------|------------------|-------|
| [`security-review/`](skills/security-review/) | ✅ Yes - in startup/high-tech context | Full scan: Python, Terraform, K8s, JS, Go, Shell, Helm, secrets |
| [`release-notes/`](skills/release-notes/) | ✅ Yes | Git + Jira + GitHub PR enriched release notes |
| [`reviewer-roulette/`](skills/reviewer-roulette/) | ✅ Yes — needs `docs/ownership-map.md` | Pick one reviewer from git history + ownership map |
| [`reindex-docs/`](skills/reindex-docs/) | Partial — uses monorepo build scripts | Pattern is general; script invocation is build-tool-specific |
| [`linkedin-post-engine/`](skills/linkedin-post-engine/) | ❌ No — personal content skill (Oded's voice) | Imported from grok/ClawHub; keeps provenance files |
| [`expected-value-calculator/`](skills/expected-value-calculator/) | ✅ Yes | Finance/investing (not a SWE skill), but fully reusable: self-contained live data via `yfinance` + deterministic EV math. Imported from grok/ClawHub |
| [`explain-to-manager/`](skills/explain-to-manager/) | ✅ Yes | Interview-driven manager briefs: status resets ("it's not ready / AI didn't 100x it"), spend proposals, and defenses of invisible work — trust-preserving, with hard-question prep |
| [`check-prod-readiness/`](skills/check-prod-readiness/) | Partial — checklist is general; quality gates assume Python + nox | Pre-merge production-readiness gate: config hygiene, code checks, nox tests/lint, pre-commit |
| [`scrooge-check/`](skills/scrooge-check/) | ✅ Yes | Pre-mortem for risky changes, styled as A Christmas Carol: Ghost of Past finds prior incidents via git history, Ghost of Present audits the diff for real risk smells, Ghost of Future writes a satirical incident report tracing back to them — verdict gates go/no-go |

> Note: some skills are imported from the grok/ClawHub marketplace and retain their `_meta.json` / `skill-card.md` provenance files.


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
| `last30days` | https://github.com/mvanhorn/last30days-skill | `claude plugin install last30days --from github:mvanhorn/last30days-skill` | Researches what people actually said about any topic in the last 30 days across Reddit, X, YouTube, TikTok, Hacker News, Polymarket, GitHub, and the web, scored by real engagement (upvotes, likes, market money). Includes a doctor health check for its sources. |
| `drawio-skill` | https://github.com/Agents365-ai/drawio-skill | `npx skills add Agents365-ai/365-skills -g` (or `git clone https://github.com/Agents365-ai/drawio-skill.git ~/.claude/skills/drawio-skill`) | Turns natural language into editable `.drawio` diagrams (exports PNG/SVG/PDF/JPG) via the draw.io desktop CLI. 7 presets (ERD, UML, sequence, C4, architecture, ML, flowchart), Mermaid→.drawio, codebase/IaC/SQL→diagram, 10k+ official shapes + AI/LLM brand logos, vision self-check + iterative refinement. Needs the draw.io desktop CLI (`brew install --cask drawio`). |

## Skill marketplaces & skill sources

Not individual skills — curated marketplaces, directories, and first-party skill repos worth browsing when you need a new capability.

| Source | Who's behind it | What it is | Why it's worth your time |
|--------|-----------------|------------|--------------------------|
| [anthropics/skills](https://github.com/anthropics/skills) | Anthropic (official) | Official Agent Skills repo, doubles as a plugin marketplace (`/plugin marketplace add anthropics/skills`) | The reference implementation: document skills (docx/xlsx/pptx/pdf), `skill-creator`, and the canonical skill template. Start here. |
| [obra/superpowers](https://github.com/obra/superpowers) | Jesse Vincent (obra) | A full software-development methodology shipped as skills: TDD, planning, debugging, verification | ~121k stars; the most thought-per-skill in the ecosystem. Endorsed in depth by Simon Willison. Works across Claude Code, Codex, Cursor, and more. |
| [trailofbits/skills](https://github.com/trailofbits/skills) | Trail of Bits | Plugin marketplace of 17+ security skills: CodeQL/Semgrep static analysis, variant analysis, differential code review, audit workflows | The gold standard for security skills, from one of the most respected security research firms. |
| [skills.sh](https://www.skills.sh) ([vercel-labs/skills](https://github.com/vercel-labs/skills)) | Vercel | The "npm for skills": `npx skills add <owner>/<repo>` installs into 50+ agents; directory with install-based leaderboard | 410k+ installs; the leaderboard surfaces what people actually use, not just what's starred. Best discovery surface. |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | VoltAgent + community | Curated index of 1000+ skills, anchored on official skills from real dev teams (Anthropic, Vercel, Stripe, Cloudflare, Sentry, Hugging Face, Figma…) | The best-maintained awesome-list; filters first-party, thoughtfully-built skills from the sea of bulk-generated ones. |

### Skill sources - private GitHub accounts

Personally-maintained skill sources — one person's own workflow, published. Higher thought-per-skill than any marketplace; vetted for personal maintenance and activity (as of July 2026).

| Source | Who | What it is | Why it's worth your time |
|--------|-----|------------|--------------------------|
| [mattpocock/skills](https://github.com/mattpocock/skills) | Matt Pocock | "Skills for Real Engineers" — straight from his own `.claude` directory: `tdd`, `grill-me`, `to-prd`, `triage`… | ~158k stars, pushed daily; the category-defining personal skills repo. |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | Addy Osmani (Chrome eng lead) | 24 structured SKILL.md lifecycle skills for Claude Code / Codex / Cursor / Gemini; siblings: [web-quality-skills](https://github.com/addyosmani/web-quality-skills), [adverse](https://github.com/addyosmani/adverse) | ~70k stars, active weekly; reference-quality full-lifecycle pack plus a whole portfolio of focused skill repos. |
| [danielmiessler/Fabric](https://github.com/danielmiessler/Fabric) + [LifeOS](https://github.com/danielmiessler/LifeOS) | Daniel Miessler | Fabric: the original curated AI prompt/pattern framework. LifeOS (ex-PAI): his personal-AI-infrastructure repo with skills + commands | ~43k + ~16k stars, both active this month; the longest-running thoughtful prompt-pattern ecosystem by one person. |
| [wshobson/agents](https://github.com/wshobson/agents) + [commands](https://github.com/wshobson/commands) | Seth Hobson | Multi-harness subagent/plugin marketplace (Claude Code, Codex, Cursor, OpenCode) | ~38k stars, evolved daily; the canonical personally-maintained subagents collection. |
| [steipete/agent-rules](https://github.com/steipete/agent-rules) + [agent-scripts](https://github.com/steipete/agent-scripts) | Peter Steinberger (founder of PSPDFKit) | Directly copyable rules/commands for Claude Code & Cursor, plus the shared scripts behind his agent setups | ~5.7k + ~5.3k stars, pushed continuously; smaller audience, highest thought-per-line. |

Near-misses worth watching: Steve Yegge's [beads/gastown](https://github.com/steveyegge/beads) agent-workflow stack (~25k, more tool than skill source), Hamel Husain's [evals-skills](https://github.com/hamelsmu/evals-skills) (evals authority, small but sharp), and Armin Ronacher's [agent-stuff](https://github.com/mitsuhiko/agent-stuff).

## Installed plugins (global settings)

| Plugin | Repo | What it does |
|--------|------|--------------|
| `context-mode` | `mksglu/context-mode` | Sandbox large-output commands; MCP tools |
| `ponytail` | `DietrichGebert/ponytail` | Lazy senior dev persona; enforces YAGNI ladder |
| `openhop` | `naorsabag/openhop` | Interactive data-flow diagram server |

## Quick start: new repo setup

1. Copy `templates/AGENTS-general.md` → `AGENTS.md`, edit org name and stack.
2. Copy `templates/CLAUDE-*.md` that fits your stack → `CLAUDE.md`, strip project-specific sections.
3. Install the skills you want — see [Installing a skill](#installing-a-skill).
4. Copy `settings/settings.local.example.json` → `.claude/settings.local.json`, tune permissions. For global plugins/hooks, see `settings/settings.global.example.json`.
