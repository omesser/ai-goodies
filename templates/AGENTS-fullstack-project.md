# Documentation for AI Agents

## Documentation Priority

- Prefer [docs/conventions.md](docs/conventions.md) for coding rules and review expectations.
- Use [docs/decisions.md](docs/decisions.md) only for historical rationale or documented tradeoffs.

Open only the relevant index first, then only the specific linked files needed for the task.

## Team Conventions

Convention filenames below live under `docs/conventions/` unless a path is shown.

For any code change, always read `50-code-style.md`. If multiple rows apply, read all listed files. If no row fits and
the choice affects project patterns, ask before introducing a new approach.

| If you're working on...                        | Read at least                              |
| ---------------------------------------------- | ------------------------------------------ |
| Planning a new feature                         | `90-software-design.md`                    |
| Any file (rename, new file, commit)            | `50-code-style.md`                         |
| A backend controller or DTO                    | `85-api-design.md`, `40-error-handling.md` |
| A TypeORM entity, migration, or repository     | `30-database.md`                           |
| Application bootstrap / reading env or secrets | `20-configuration.md`                      |
| A React component, hook, or styling change     | `10-libraries.md`, `40-error-handling.md`  |
| A test file                                    | `60-testing.md`                            |
| Map / GIS code (ArcGIS, turf, DoF, fiber)      | `10-libraries.md`, `80-domain.md`          |
| Opening a PR or leaving review comments        | `70-processes.md`                          |

## Skills

Local skills live under [.agents/skills](.agents/skills):

- [`release-notes/`](.agents/skills/release-notes/SKILL.md) — generate release notes between two versions.
- [`reviewer-roulette/`](.agents/skills/reviewer-roulette/SKILL.md) — select a reviewer for a branch or PR.
- [`reindex-docs/`](.agents/skills/reindex-docs/SKILL.md) — regenerate the generated `docs/*.md` index files
  from the folder-local `docs/*/index.json` files.
