#!/usr/bin/env bash
# AI / GenAI artifact scanner for Company's GenAI Use and Oversight Policy.
#
# Scans for: AI config files (CLAUDE.md, AGENTS.md, .mcp.json, Cursor, Copilot,
# Continue), secrets in AI configs, MCP tool scope, settings permission flags,
# dangerouslyAllowAll, hooks calling external scripts, AI SDK usage, GHA
# workflows referencing AI APIs.
#
# Usage: bash scan-ai.sh [--changed-only]
# Runs standalone or called from scan.sh (which sets SCAN_FINDINGS).

set -uo pipefail

# --changed-only accepted for forward-compat but scan-ai.sh always scans all AI artifacts
FINDINGS_FILE="${SCAN_FINDINGS:-/dev/null}"

# ── helpers ───────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  BOLD='\033[1m'
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'
else
  BOLD=''
  BLUE=''
  YELLOW=''
  RED=''
  NC=''
fi

section() { echo -e "\n${BOLD}${BLUE}━━━ ai: $1 ━━━${NC}"; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }

# Print each line of $1 prefixed with $2 (default two spaces)
indent() {
  local prefix="${2:-  }" line
  while IFS= read -r line; do printf '%s%s\n' "$prefix" "$line"; done <<< "$1"
}

finding() {
  local sev="$1" msg="$2"
  echo -e "${RED}[$sev]${NC} $msg"
  [[ "$sev" == "HIGH" || "$sev" == "CRITICAL" ]] &&
    printf '%s|ai|%s\n' "$sev" "$msg" >> "$FINDINGS_FILE"
}

# Find a single file, quiet (returns first hit or empty)
find1() { find . -name "$1" -not -path "./.git/*" -not -path "./node_modules/*" -print -quit 2> /dev/null; }

# Find all matching, quiet
findall() { find . -name "$1" -not -path "./.git/*" -not -path "./node_modules/*" 2> /dev/null; }

# Grep pattern across a newline-separated file list
grepfiles() {
  local pattern="$1" files="$2"
  [[ -z "$files" ]] && return 0
  while IFS= read -r f; do
    [[ -f "$f" ]] && grep -nHE "$pattern" "$f" 2> /dev/null
  done <<< "$files" | head -20 || true
}

# ── discover AI artifacts ─────────────────────────────────────────────────────

section "AI artifact discovery"

# Claude Code / Anthropic
CLAUDE_MD=$(find1 "CLAUDE.md")
AGENTS_MD=$(find1 "AGENTS.md")
MCP_JSON=$(find1 ".mcp.json")
CLAUDE_SETTINGS=$(findall "settings.json" | grep '\.claude/' | head -5)
SKILL_FILES=$(find . -path "*/.claude/skills/*.md" -not -path "./.git/*" 2> /dev/null | head -20)

# Other AI assistant configs
CURSORRULES=$(find1 ".cursorrules")
CURSOR_SETTINGS=$(find1 ".cursor/settings.json")
COPILOT_INSTRUCTIONS=$(find1 ".github/copilot-instructions.md")
CONTINUE_CONFIG=$(find1 ".continue/config.json")
CLINE_DOCS=$(find . -name "*.md" -path "*/cline_docs/*" -not -path "./.git/*" 2> /dev/null | head -5)
WINDSURF=$(find1 ".windsurf")

# Collect all AI config files for secret scanning
AI_CONFIG_FILES=""
for f in "$CLAUDE_MD" "$AGENTS_MD" "$MCP_JSON" "$CURSORRULES" "$CURSOR_SETTINGS" \
  "$COPILOT_INSTRUCTIONS" "$CONTINUE_CONFIG" "$WINDSURF"; do
  [[ -n "$f" && -f "$f" ]] && AI_CONFIG_FILES+="$f"$'\n'
done
while IFS= read -r f; do [[ -n "$f" && -f "$f" ]] && AI_CONFIG_FILES+="$f"$'\n'; done \
  <<< "${CLAUDE_SETTINGS:-}"
while IFS= read -r f; do [[ -n "$f" && -f "$f" ]] && AI_CONFIG_FILES+="$f"$'\n'; done \
  <<< "${SKILL_FILES:-}"
while IFS= read -r f; do [[ -n "$f" && -f "$f" ]] && AI_CONFIG_FILES+="$f"$'\n'; done \
  <<< "${CLINE_DOCS:-}"

# AI SDK usage in source files
AI_SDK_FILES=$(grep -rl \
  'anthropic\|openai\|langchain\|llama.index\|llamaindex\|transformers\|boto3.*bedrock\|azure.*openai\|google.*generativeai\|cohere\|mistral' \
  --include="*.py" --include="*.ts" --include="*.js" --include="*.go" \
  . 2> /dev/null | grep -v './.git/' | grep -Ev '/\.venv[^/]*/|/\.venv_[^/]*/' | head -20 || true)

# GHA workflows referencing AI APIs or model identifiers
GHA_AI_FILES=$(grep -rl \
  'OPENAI_API_KEY\|ANTHROPIC_API_KEY\|GOOGLE_API_KEY\|COHERE_API_KEY\|claude-\|gpt-\|gemini-\|mistral-' \
  --include="*.yaml" --include="*.yml" \
  .github/workflows/ 2> /dev/null | head -10 || true)

# Print inventory
echo "Claude / Anthropic:"
[[ -n "$CLAUDE_MD" ]] && echo "  $CLAUDE_MD" || echo "  no CLAUDE.md"
[[ -n "$AGENTS_MD" ]] && echo "  $AGENTS_MD" || echo "  no AGENTS.md"
[[ -n "$MCP_JSON" ]] && echo "  $MCP_JSON" || echo "  no .mcp.json"
[[ -n "$CLAUDE_SETTINGS" ]] && indent "$CLAUDE_SETTINGS"
[[ -n "$SKILL_FILES" ]] && indent "$SKILL_FILES" "  skill: "

echo "Other AI assistants:"
[[ -n "$CURSORRULES" ]] && echo "  $CURSORRULES"
[[ -n "$CURSOR_SETTINGS" ]] && echo "  $CURSOR_SETTINGS"
[[ -n "$COPILOT_INSTRUCTIONS" ]] && echo "  $COPILOT_INSTRUCTIONS"
[[ -n "$CONTINUE_CONFIG" ]] && echo "  $CONTINUE_CONFIG"
[[ -n "$WINDSURF" ]] && echo "  $WINDSURF"
[[ -n "$CLINE_DOCS" ]] && indent "$CLINE_DOCS"
{ [[ -z "$CURSORRULES" ]] && [[ -z "$CURSOR_SETTINGS" ]] && [[ -z "$COPILOT_INSTRUCTIONS" ]] &&
  [[ -z "$CONTINUE_CONFIG" ]] && [[ -z "$WINDSURF" ]] && [[ -z "$CLINE_DOCS" ]]; } &&
  echo "  none detected"

echo "AI SDK usage:"
[[ -n "$AI_SDK_FILES" ]] && indent "$AI_SDK_FILES" || echo "  none detected"

echo "GHA workflows referencing AI APIs:"
[[ -n "$GHA_AI_FILES" ]] && indent "$GHA_AI_FILES" || echo "  none"

# Exit early if no AI artifacts at all
if [[ -z "$AI_CONFIG_FILES" && -z "$AI_SDK_FILES" ]]; then
  echo ""
  echo "No AI/agentic artifacts detected."
  exit 0
fi

echo ""
echo "AI artifacts present — running compliance checks"

# ── secrets in AI config files ────────────────────────────────────────────────

section "Secrets in AI config files"

if [[ -z "$AI_CONFIG_FILES" ]]; then
  echo "  no AI config files to scan"
else
  HITS=$(grepfiles \
    '(api[_-]?key|token|secret|password|credential|bearer)\s*[=:]\s*[A-Za-z0-9+/=_\-]{16,}' \
    "$AI_CONFIG_FILES")
  if [[ -n "$HITS" ]]; then
    finding "CRITICAL" "Credential or API key embedded in AI config file — rotate immediately"
    echo "$HITS"
  else
    echo "  clean"
  fi

  # Check for any sk-*, ant-*, ghp_*, xoxb-* patterns that are likely real keys
  HITS=$(grepfiles \
    '(sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9\-_]{30,}|ghp_[A-Za-z0-9]{36,}|xoxb-[0-9\-]{20,}|AIza[A-Za-z0-9_\-]{30,})' \
    "$AI_CONFIG_FILES")
  if [[ -n "$HITS" ]]; then
    finding "CRITICAL" "Looks like a real API key in AI config file — rotate immediately"
    echo "$HITS"
  fi
fi

# ── MCP server scope ──────────────────────────────────────────────────────────

section "MCP server configurations"

if [[ -z "$MCP_JSON" ]]; then
  echo "  no .mcp.json"
else
  echo "--- MCP servers and tools defined ---"
  cat "$MCP_JSON"

  # Flag bash/shell execution tools
  if grep -qE '"(bash|shell|run_command|execute|terminal|cmd)"' "$MCP_JSON" 2> /dev/null; then
    finding "HIGH" "MCP server grants shell execution — verify scope is explicitly documented and necessary"
  fi

  # Flag broad filesystem access
  if grep -qE '"(/(home|root|Users)|~[/"])' "$MCP_JSON" 2> /dev/null; then
    finding "HIGH" "MCP filesystem access scoped to home or root — restrict to specific working paths"
  fi

  # Flag external-facing MCP servers (non-localhost URLs)
  if grep -qE '"url"\s*:\s*"https?://(?!localhost|127\.0\.0\.1)' "$MCP_JSON" 2> /dev/null; then
    warn "External MCP server URL detected — confirm documented business justification and approval:"
    grep -E '"url"\s*:\s*"https?://' "$MCP_JSON" 2> /dev/null | head -5 || true
  fi
fi

# Also check for mcp_config.json or .claude/mcp*.json
OTHER_MCP=$(find . -name "mcp_config.json" -o -name "mcp*.json" -path "*/.claude/*" \
  2> /dev/null | grep -v './.git/' | head -5)
if [[ -n "$OTHER_MCP" ]]; then
  warn "Additional MCP config files found — inspect these:"
  indent "$OTHER_MCP"
fi

# ── Claude settings: permission flags ────────────────────────────────────────

section "Claude settings: permissions and hooks"

if [[ -z "$CLAUDE_SETTINGS" ]]; then
  echo "  no .claude/settings*.json found"
else
  while IFS= read -r settings_file; do
    [[ -z "$settings_file" || ! -f "$settings_file" ]] && continue
    echo "--- $settings_file ---"
    cat "$settings_file"

    # dangerouslyAllowAll or dangerouslyAllowAllTools
    if grep -qE '"dangerously(Allow(All|AllTools)|Bypass)"\s*:\s*true' "$settings_file" 2> /dev/null; then
      finding "HIGH" \
        "$settings_file: dangerouslyAllow* flag is true — all tools unrestricted; disable or document justification"
    fi

    # allowedTools contains broad grants
    if grep -qE '"allowedTools"\s*:\s*\[.*"Bash".*\]' "$settings_file" 2> /dev/null; then
      warn "$settings_file: Bash in allowedTools — confirm shell access is scoped and necessary"
    fi

    # Hooks that exec external scripts (PostToolUse, PreToolUse, etc.)
    if grep -qE '"(PreToolUse|PostToolUse|Stop|Notification)"\s*:\s*\[' "$settings_file" 2> /dev/null; then
      hook_cmds=$(grep -A5 '"(PreToolUse|PostToolUse|Stop|Notification)"' \
        "$settings_file" 2> /dev/null | grep '"command"' | head -5 || true)
      if [[ -n "$hook_cmds" ]]; then
        warn "$settings_file: hooks with external commands — verify they don't exfiltrate data or run untrusted code:"
        echo "$hook_cmds"
      fi
    fi
  done <<< "$CLAUDE_SETTINGS"
fi

# ── skill file injection patterns ─────────────────────────────────────────────

section "Skill files: prompt injection patterns"

if [[ -z "$SKILL_FILES" ]]; then
  echo "  no skill files"
else
  HITS=$(grepfiles \
    'ignore (previous|all|above) instructions|act as if|bypass.*security|you are now|disregard.*guidelines|jailbreak|DAN mode|pretend you' \
    "$SKILL_FILES")
  if [[ -n "$HITS" ]]; then
    finding "HIGH" "Prompt injection pattern in skill file — review intent"
    echo "$HITS"
  fi

  # Shell access in skills
  SHELL_SKILLS=$(while IFS= read -r f; do
    [[ -f "$f" ]] && grep -l 'bash\|shell\|run_command\|subprocess\|os\.system' "$f" 2> /dev/null
  done <<< "$SKILL_FILES" | head -5 || true)
  if [[ -n "$SHELL_SKILLS" ]]; then
    warn "Skills with shell/bash references — confirm each documents why shell access is needed:"
    indent "$SHELL_SKILLS"
  fi

  HITS=$(grepfiles \
    '\{(user_input|request|message|query|prompt)\}' \
    "$SKILL_FILES")
  if [[ -n "$HITS" ]]; then
    warn "User input interpolated into skill prompt — verify sanitization exists upstream:"
    echo "$HITS"
  fi
fi

# ── AI SDK: provider inventory ────────────────────────────────────────────────

section "AI SDK usage: provider inventory"

if [[ -z "$AI_SDK_FILES" ]]; then
  echo "  no AI SDK usage detected"
else
  echo "Files using AI SDKs:"
  indent "$AI_SDK_FILES"
  echo ""
  echo "Providers referenced (check each is on approved AI tools list):"
  # Extract provider names from imports/usage
  while IFS= read -r f; do
    [[ -f "$f" ]] && grep -oE \
      '(anthropic|openai|langchain|llama[_-]?index|llamaindex|transformers|bedrock|azure.*openai|google.*genai|cohere|mistral)' \
      "$f" 2> /dev/null
  done <<< "$AI_SDK_FILES" | sort -u | sed 's/^/  /'
fi

# ── GHA AI workflows ──────────────────────────────────────────────────────────

if [[ -n "$GHA_AI_FILES" ]]; then
  section "GitHub Actions: AI API usage"
  echo "Workflows referencing AI APIs:"
  indent "$GHA_AI_FILES"

  # permissions: write-all with AI access is a high-risk combo
  while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    if grep -qE 'permissions:\s*write-all' "$wf" 2> /dev/null &&
      grep -qE '(OPENAI_API_KEY|ANTHROPIC_API_KEY|claude-|gpt-)' "$wf" 2> /dev/null; then
      finding "HIGH" \
        "$wf: permissions: write-all combined with AI API access — scope permissions to minimum required"
    fi
  done <<< "$GHA_AI_FILES"

  # Check for AI API keys stored as env: vs secrets:
  HITS=$(grepfiles 'env:\s*$' "$GHA_AI_FILES")
  warn "Check that AI API keys are stored in GitHub Secrets (secrets.X), not env: block literals"
fi

# ── human oversight signals ───────────────────────────────────────────────────

section "Human oversight signals (informational)"
warn "The following require manual verification — cannot be determined from code alone:"
cat << 'EOF'
  [ ] All AI-generated code was reviewed by a human before merge (PR description should state this)
  [ ] AI interactions are logged under the corporate account (SOC 2 audit requirement)
  [ ] AI tools are accessed with corporate accounts, not personal accounts
  [ ] No customer PII or production secrets were passed into AI prompts
  [ ] AI not solely responsible for core security functions (auth, encryption, access control)
EOF

echo ""
echo "━━━ end of AI scan ━━━"
