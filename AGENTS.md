# AGENTS.md

This repo is a curated collection of reference AI/agentic-engineering artifacts — skills, templates, guides, and settings — meant to be read, copied, and adapted into other repos. See [`README.md`](README.md) for the full map of what lives where.

Treat everything here as a **library of reference material**, not a running application. There is nothing to build or deploy; the value is in keeping the artifacts clean, accurate, and well-catalogued.

## Operating rules

1. **Don't modify existing artifacts without explicit approval.** Skills, templates, guides, and settings are curated. Do not edit, refactor, "clean up," or rewrite an existing file unless the user explicitly asks for that specific change. When you spot problems, report them and wait — don't fix proactively.

2. **Keep `README.md` in sync.** Any change that adds, removes, renames, or relocates a skill (or template / guide) MUST update the matching table in [`README.md`](README.md) in the same change. The README is the catalog; a drifting catalog is a bug.

3. **Review skills before adding them.** When importing or creating a skill, check it first and surface issues before it lands:
   - Frontmatter is valid: `name` matches the directory, `description` states clear trigger conditions.
   - No leftover meta/planning notes (e.g. "proposed changes", "further refinements") shipped inside the skill body.
   - No dead or placeholder links.
   - For data-driven skills, confirm a real data source, tool, or script exists. If it doesn't, flag the hallucination risk explicitly — a skill that invents its inputs is a defect.

4. **Preserve provenance.** Skills imported from a marketplace (e.g. grok/ClawHub) keep their provenance files (`_meta.json`, `skill-card.md`) as-is, and their origin is noted in the README.

5. **Run pre-commit after every change and fix all violations before you're done.** After editing any file, run `pre-commit run --all-files` and resolve every reported issue (re-run until it passes clean). A task is not complete while hooks are failing. Don't disable, skip (`--no-verify`), or add blanket ignores to get past a hook — fix the underlying issue.

6. **Git: never commit or push without explicit approval.**

7. **Stay minimal and proportional.** Make the smallest change that satisfies the request. Ask before broad or destructive edits.

## GitHub Actions lockfile

`.github/workflows/actions.lock` pins every action the workflows use to a commit; `uses:` lines keep readable tags. The `verify-lockfile` workflow checks it on every PR, and the pre-commit hook checks coverage offline when `gh` and the extension are installed. The check is its own workflow because it has to report when another workflow cannot start; the hook is skippable and checks coverage only, so it is not the gate.

- Install the extension once: `gh extension install github/gh-actions-lock`.
- After adding a workflow or changing any `uses:`, run `gh actions-lock` and commit the lockfile with the change. A workflow the lockfile doesn't cover fails to start.
- Review a lockfile diff like a dependency bump: check each changed `ref` and `commit` against the action's release.
- On a `ref-moved` warning, a tag or branch now points at a different commit. Find out why before you accept it; `gh actions-lock --relock` advances floating refs such as `v4`.
- Never run `--accept-moved` in automation, and never edit the lockfile by hand.

## Conventions

- Writing skills: [`guides/skill-authoring.md`](guides/skill-authoring.md)
- Writing AGENTS.md / CLAUDE.md: [`guides/agents-md-guide.md`](guides/agents-md-guide.md)
