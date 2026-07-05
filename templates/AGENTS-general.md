# Agent guide — Company

Reference for agents operating on Company codebases or using tools from this repo.

## Organization context

- **Company:** Company name
- **Primary language stack:** check the target repo's CLAUDE.md for specifics.
- **Internal systems:** prefer asking a human before accessing internal APIs you haven't used before.

## Repo layout

```
skills/          # Claude Code slash-command skills (.md prompt files)
plugins/         # Claude Code plugins (hooks, MCP wrappers)
guides/          # Prose how-tos for teams using agents
```

## Working in this repo

- **Adding a skill:** create `skills/<name>/` with `SKILL.md` and `README.md`. `SKILL.md` is the entrypoint — write it as instructions to Claude, not documentation for humans. Add a YAML frontmatter block with `name`, `description`, and `allowed-tools`. Companion scripts go in the same directory and are referenced via `${CLAUDE_SKILL_DIR}` in `SKILL.md`.
- **Adding a plugin:** create `plugins/<name>/` with install instructions in `README.md`.
- **Adding a guide:** drop a `.md` file in `guides/`.

## Review bar

Skills and plugins affect every engineer who installs them. Before merging:
1. Test the skill on at least two real tasks.
2. Check that the skill does not request unnecessary permissions.
3. Confirm the skill's trigger conditions won't fire unexpectedly.

## Behavior defaults

- Prefer reading existing code over guessing conventions.
- When in doubt about scope ("should I also fix X?"), do the minimum asked and call out the adjacent issue in your response.
- Never push to `main` without explicit instruction.
- Never send messages (Slack, email, GitHub comments) without explicit instruction.
- Do not commit API keys, tokens, or internal endpoints — use environment variables.

## When to spawn subagents

- Spawn for parallel independent work (e.g. reviewing multiple files simultaneously).
- Do not spawn just to avoid context length — summarize instead.
- Pass enough context in the subagent prompt that it can operate without the parent conversation.

## Escalation

If a task requires credentials, infra access, or decisions outside the stated scope — stop and ask a human. Do not improvise around missing access.
