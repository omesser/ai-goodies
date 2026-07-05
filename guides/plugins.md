# Claude Code plugins

Plugins add hooks, MCP servers, and skills that activate globally across all projects.

## Installed plugins (from settings.global.example.json)

### context-mode (`mksglu/context-mode`)

Routes large-output commands through a sandbox so raw bytes don't flood the context window. Installs:
- MCP server with `ctx_execute`, `ctx_batch_execute`, `ctx_execute_file`, `ctx_fetch_and_index`, `ctx_search`, `ctx_index`
- Skills: `context-mode`, `ctx-doctor`, `ctx-search`, `ctx-stats`, `ctx-upgrade`, `ctx-purge`, `ctx-index`, `ctx-insight`
- PreToolUse hook that injects routing guidance into every response

**Install:**
```bash
claude plugin install context-mode --from github:mksglu/context-mode
```

**Key skill:** see the `skills/context-mode/` directory in the `mksglu/context-mode` repo for the full decision tree and anti-patterns.

### ponytail (`DietrichGebert/ponytail`)

Lazy senior dev persona. Enforces the YAGNI ladder before building anything: does it need to exist? stdlib? native feature? existing dep? one line? only then minimum code.

**Install:**
```bash
claude plugin install ponytail --from github:DietrichGebert/ponytail
```

**Levels:** `/ponytail lite`, `/ponytail full`, `/ponytail ultra`

### openhop (`naorsabag/openhop`)

Interactive step-by-step data flow diagrams. Runs a local server; Claude pushes YAML flows to it.

**Install:**
```bash
claude plugin install openhop --from github:naorsabag/openhop
# or: npm install -g openhop
```

**Trigger:** "walk me through X", "diagram how X works", "trace what happens when..."

**Full skill:** `openhop/SKILL.md` in this repo.

## How plugins work

Plugins are installed to `~/.claude/plugins/cache/<plugin-name>/`. They can contain:
- `hooks/` — shell scripts that run on SessionStart, PreToolUse, PostToolUse
- `skills/` — SKILL.md files that become global slash commands
- `mcp/` — MCP server definitions

## Adding a new marketplace

In `~/.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "my-plugin": {
      "source": {
        "source": "github",
        "repo": "owner/repo"
      }
    }
  }
}
```
