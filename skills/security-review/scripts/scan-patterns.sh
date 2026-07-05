#!/usr/bin/env bash
# Security pattern scanner — zero external tool dependencies.
#
# Detects dangerous patterns that generic SAST tools miss:
#   TLS/SSL disabled · auth bypasses · debug flags · SQL via f-strings ·
#   broad exception silencing · sensitive data in logs · dangerous eval/exec ·
#   hardcoded internal endpoints · AI/ML-specific risky patterns
#
# Usage: bash scan-patterns.sh [--changed-only]
# Runs standalone or called from scan.sh (which sets SCAN_FINDINGS).

set -uo pipefail

CHANGED_ONLY=0
[[ "${1:-}" == "--changed-only" ]] && CHANGED_ONLY=1
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

section() { echo -e "\n${BOLD}${BLUE}━━━ patterns: $1 ━━━${NC}"; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }

finding() {
  local sev="$1" msg="$2"
  echo -e "${RED}[$sev]${NC} $msg"
  # Only HIGH/CRITICAL contribute to --fail-on-findings exit code
  [[ "$sev" == "HIGH" || "$sev" == "CRITICAL" ]] &&
    printf '%s|patterns|%s\n' "$sev" "$msg" >> "$FINDINGS_FILE"
}

# Newline-separated paths matching ext regex, scoped to changed files or full repo
scope() {
  local ext_re="$1"
  if [[ $CHANGED_ONLY -eq 1 ]]; then
    { git diff --name-only main...HEAD 2> /dev/null ||
      git diff --name-only HEAD~1...HEAD 2> /dev/null; } |
      grep -E "$ext_re" || true
  else
    find . -not -path "*/.git/*" -not -path "*/node_modules/*" \
      -not -path "*/.terragrunt-cache/*" -not -path "*/.venv/*" \
      -not -path "*/.venv_*/*" -not -path "*/.tox/*" -not -path "*/.nox/*" |
      grep -E "$ext_re" 2> /dev/null || true
  fi
}

# Safe grep over a newline-separated file list; no xargs word-splitting
grepfiles() {
  local pattern="$1" files="$2"
  [[ -z "$files" ]] && return 0
  while IFS= read -r f; do
    [[ -f "$f" ]] && grep -nHE "$pattern" "$f" 2> /dev/null
  done <<< "$files" | head -30 || true
}

# Full check: scope → grep → optionally exclude → report
check() {
  local sev="$1" msg="$2" ext_re="$3" pattern="$4" exclude="${5:-}"
  local files
  files=$(scope "$ext_re")
  [[ -z "$files" ]] && return 0 # no relevant files — skip silently
  local hits
  hits=$(grepfiles "$pattern" "$files")
  # Strip comment-only lines
  hits=$(echo "$hits" | grep -vE '^\s*(#|//|--)\s*[A-Za-z]' || true)
  [[ -n "$exclude" ]] && hits=$(echo "$hits" | grep -vE "$exclude" 2> /dev/null || true)
  hits=$(echo "$hits" | grep -v '^\s*$' || true)
  if [[ -n "$hits" ]]; then
    finding "$sev" "$msg"
    echo "$hits"
  else
    echo "  clean"
  fi
}

# ── 1. TLS/SSL verification disabled ─────────────────────────────────────────

section "TLS/SSL verification disabled"
check "HIGH" \
  "TLS/SSL cert verification disabled — silent MITM vulnerability" \
  '\.(py|go|ts|js|mjs)$' \
  'verify\s*=\s*False|InsecureSkipVerify\s*:\s*true|ssl\._create_unverified_context|NODE_TLS_REJECT_UNAUTHORIZED\s*[=:]\s*["\x27]?0["\x27]?|rejectUnauthorized\s*:\s*false|CURLOPT_SSL_VERIFYPEER\s*,\s*(0|false)'

# ── 2. auth / authorization bypassed ─────────────────────────────────────────

section "Auth / authorization bypassed"
check "HIGH" \
  "Auth enforcement disabled — confirm this cannot reach production" \
  '\.(py|go|ts|js|yaml|yml)$' \
  'auth_required\s*=\s*False|require_auth\s*=\s*False|skip_auth\s*=\s*True|bypass_auth|authentication_disabled|authorization_disabled|NO_AUTH\s*=\s*["\x27]?true["\x27]?|DISABLE_AUTH\s*=\s*1' \
  'test|spec|mock|fixture|example'

# ── 3. debug flags committed ──────────────────────────────────────────────────

section "Debug flags committed"
check "MEDIUM" \
  "Debug flag enabled — confirm not present in production config" \
  '\.(py|ts|js|yaml|yml|env)$' \
  '^\s*DEBUG\s*[=:]\s*(True|1|true|"true")|FLASK_DEBUG\s*[=:]\s*1|DJANGO_DEBUG\s*[=:]\s*True|APP_DEBUG\s*[=:]\s*(true|1)' \
  '\.env\.(example|sample|template)|test|spec'

# ── 4. SQL injection via string formatting ────────────────────────────────────

section "SQL injection via string formatting"
warn "Parameterized queries using (%s, (value,)) are safe — verify context before filing an issue"
check "HIGH" \
  "SQL built with f-string or % formatting — use parameterized queries" \
  '\.py$' \
  "f['\"].*\b(SELECT|INSERT|UPDATE|DELETE|DROP|TRUNCATE)\b|cursor\.execute\s*\(\s*f['\"]|cursor\.execute\s*\(\s*['\"].*%[^(]\s|\.execute\s*\(.*\.format\s*\("

# ── 5. broad exception silencing ──────────────────────────────────────────────

section "Broad exception silencing"
check "MEDIUM" \
  "Exception silenced with pass — hides errors, degrades observability and debugging" \
  '\.py$' \
  '^\s*except\s*:\s*(pass\s*)?$|^\s*except\s*(Exception|BaseException)\s*:\s*pass\s*$|^\s*except\s*(Exception|BaseException)\s+as\s+\w+\s*:\s*pass\s*$'

# ── 6. sensitive data in log statements ───────────────────────────────────────

section "Sensitive data in log statements"
check "HIGH" \
  "Possible sensitive value logged — verify real secrets don't reach log sinks" \
  '\.(py|ts|js|go)$' \
  '(log|logger|logging|print|console\.(log|warn|error|info))\s*[\.(].*\b(password|passwd|secret|token|api[_-]?key|private[_-]?key|credential|auth[_-]?header|bearer|ssn|credit[_-]?card)\b'

# ── 7. dangerous eval / exec / shell invocation ────────────────────────────────

section "Dangerous eval / exec / shell invocation"

PY_FILES=$(scope '\.py$')
if [[ -n "$PY_FILES" ]]; then
  echo "Python:"
  HITS=$(grepfiles \
    'eval\s*\(|^[^#]*exec\s*\(|os\.system\s*\(|subprocess\.(call|run|Popen)\s*\([^)]*shell\s*=\s*True' \
    "$PY_FILES" | grep -v 'shell=False' | head -20 || true)
  if [[ -n "$HITS" ]]; then
    finding "HIGH" "eval/exec or subprocess with shell=True — verify input is not user-controlled"
    echo "$HITS"
  else
    echo "  clean"
  fi
fi

SH_FILES=$(scope '\.sh$')
if [[ -n "$SH_FILES" ]]; then
  echo "Shell:"
  HITS=$(grepfiles 'eval\s*\$\(|eval\s*"[^"]*\$\{|eval\s*"[^"]*\$[A-Za-z]' "$SH_FILES" | head -20 || true)
  if [[ -n "$HITS" ]]; then
    finding "HIGH" "eval with variable expansion in shell — shell injection risk"
    echo "$HITS"
  else
    echo "  clean"
  fi
fi

# ── 8. hardcoded internal endpoints / IPs ────────────────────────────────────

section "Hardcoded internal endpoints / IPs"
warn "Many false positives expected in test fixtures and dev configs — review context"
check "MEDIUM" \
  "Hardcoded private IP or internal endpoint — use env vars or service discovery" \
  '\.(py|go|ts|js|yaml|yml|tf|json)$' \
  'https?://(localhost|127\.0\.0\.1|10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3})|\.local:[0-9]{4,5}' \
  'test|spec|example|mock|#|//'

# ── 9. AI / ML dangerous patterns ────────────────────────────────────────────

section "AI/ML dangerous patterns"

PY_FILES=$(scope '\.py$')
if [[ -z "$PY_FILES" ]]; then
  echo "  no Python files — skipping"
else
  AI_CLEAN=1

  # LangChain unsafe pickle deserialization → arbitrary code execution
  HITS=$(grepfiles 'allow_dangerous_deserialization\s*=\s*True' "$PY_FILES" | head -10 || true)
  if [[ -n "$HITS" ]]; then
    finding "HIGH" "LangChain allow_dangerous_deserialization=True — loads arbitrary pickles, enables RCE"
    echo "$HITS"
    AI_CLEAN=0
  fi

  # HuggingFace model loading → executes arbitrary Python from model repo
  HITS=$(grepfiles 'trust_remote_code\s*=\s*True' "$PY_FILES" | head -10 || true)
  if [[ -n "$HITS" ]]; then
    finding "HIGH" "HuggingFace trust_remote_code=True — executes arbitrary Python from the model repo"
    echo "$HITS"
    AI_CLEAN=0
  fi

  # User-controlled data interpolated into system prompt
  HITS=$(grepfiles \
    '(system|system_prompt|system_message)\s*[=:]\s*f["\x27].*\{(user|request|input|query|message|prompt)\b' \
    "$PY_FILES" | head -10 || true)
  if [[ -n "$HITS" ]]; then
    finding "HIGH" "User-controlled input interpolated into system prompt — prompt injection risk"
    echo "$HITS"
    AI_CLEAN=0
  fi

  # Deprecated / insecure model versions pinned
  HITS=$(grepfiles \
    '"gpt-3\.5-turbo"[^-]|"gpt-4-0[0-9]{3}-preview"|"claude-1\.|"claude-instant|"text-davinci' \
    "$PY_FILES" | head -10 || true)
  if [[ -n "$HITS" ]]; then
    warn "Potentially deprecated model version pinned — confirm it still receives security updates:"
    echo "$HITS"
  fi

  # AI output used without apparent downstream validation (informational)
  HITS=$(grepfiles '\.choices\[0\]\.message\.content|response\.content\b|result\[.content.\]' \
    "$PY_FILES" | head -15 || true)
  if [[ -n "$HITS" ]]; then
    warn "AI output extracted — verify downstream validation before use in security-sensitive paths:"
    echo "$HITS"
  fi

  [[ $AI_CLEAN -eq 1 ]] && echo "  clean"
fi

echo ""
echo "━━━ end of pattern scan ━━━"
