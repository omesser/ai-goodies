#!/usr/bin/env bash
# Prisma security scanner — parallel, auto-detecting, structured for Claude.
#
# Usage: bash scan.sh [options]
#   --changed-only          Only scan files changed vs main (faster on large repos)
#   --only   sec,python     Run only the named scanners (comma or space separated)
#   --skip   trivy,ml       Skip the named scanners
#   --save-reports          Copy each scanner's output to .reports/<name>.txt
#   --fail-on-findings      Exit 1 if any HIGH/CRITICAL finding was recorded
#   --no-color              Strip ANSI codes (auto when stdout is not a TTY)
#   --timeout  N            Per-tool timeout in seconds (default: 120)
#
# Scanners: secrets patterns python iac dockerfile gha kubernetes shell helm
#           js go trivy ml ai
#
# Companion scripts (auto-loaded from same directory):
#   scan-patterns.sh  — grep-based Prisma-specific bad-pattern checks
#   scan-ai.sh        — AI/GenAI artifact and compliance checks

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── defaults ──────────────────────────────────────────────────────────────────

CHANGED_ONLY=0
SAVE_REPORTS=0
FAIL_ON_FINDINGS=0
NO_COLOR=0
TOOL_TIMEOUT=120
ALL_SCANNERS="secrets patterns python iac dockerfile gha kubernetes shell helm js go trivy ml ai"
RUN_SCANNERS="$ALL_SCANNERS"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      RUN_SCANNERS="${2//,/ }"
      shift 2
      ;;
    --skip)
      for s in ${2//,/ }; do
        RUN_SCANNERS=$(echo " $RUN_SCANNERS " | sed "s/ $s / /g" | xargs)
      done
      shift 2
      ;;
    --changed-only)
      CHANGED_ONLY=1
      shift
      ;;
    --save-reports)
      SAVE_REPORTS=1
      shift
      ;;
    --fail-on-findings)
      FAIL_ON_FINDINGS=1
      shift
      ;;
    --no-color)
      NO_COLOR=1
      shift
      ;;
    --timeout)
      TOOL_TIMEOUT="$2"
      shift 2
      ;;
    -h | --help)
      grep '^#' "$0" | grep -A40 'Usage:' | sed 's/^# \?//' | head -20
      exit 0
      ;;
    *)
      echo "Unknown flag: $1 (see --help)" >&2
      exit 1
      ;;
  esac
done

# ── colors — suppressed when not a TTY or --no-color ─────────────────────────

if [[ $NO_COLOR -eq 0 ]] && [[ -t 1 ]]; then
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
# macOS ships gtimeout (coreutils); Linux has timeout; fall back to no timeout
TIMEOUT_CMD="$(command -v gtimeout 2> /dev/null || command -v timeout 2> /dev/null || true)"
export BOLD BLUE YELLOW RED NC TOOL_TIMEOUT SCRIPT_DIR CHANGED_ONLY SAVE_REPORTS TIMEOUT_CMD

# ── temp workspace ────────────────────────────────────────────────────────────

TMPDIR_SCAN=$(mktemp -d)
trap 'rm -rf "$TMPDIR_SCAN"' EXIT

FINDINGS_FILE="$TMPDIR_SCAN/findings.txt"
SKIPPED_FILE="$TMPDIR_SCAN/skipped.txt"
ERRORS_FILE="$TMPDIR_SCAN/errors.txt"
touch "$FINDINGS_FILE" "$SKIPPED_FILE" "$ERRORS_FILE"
export SCAN_FINDINGS="$FINDINGS_FILE"

[[ $SAVE_REPORTS -eq 1 ]] && mkdir -p .reports

# ── helpers ───────────────────────────────────────────────────────────────────

section() { echo -e "\n${BOLD}${BLUE}━━━ $1 ━━━${NC}"; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }
has_cmd() { command -v "$1" &> /dev/null; }

skip() {
  echo "SKIP $1"
  echo "$1" >> "$SKIPPED_FILE"
}

bounded() {
  local label="$1" maxlines="$2"
  shift 2
  if [[ -n "$TIMEOUT_CMD" ]]; then
    "$TIMEOUT_CMD" "$TOOL_TIMEOUT" "$@" 2>&1 | head -"$maxlines"
    local rc=${PIPESTATUS[0]}
    [[ $rc -eq 124 ]] && warn "$label timed out after ${TOOL_TIMEOUT}s — output may be incomplete"
  else
    "$@" 2>&1 | head -"$maxlines"
  fi
  return 0
}

should_run() { [[ " $RUN_SCANNERS " == *" $1 "* ]]; }

# Single-result find, returns first match path or empty
qfind() {
  find . -maxdepth 6 -name "$1" \
    -not -path "./.git/*" -not -path "./.terragrunt-cache/*" \
    -not -path "./node_modules/*" -print -quit 2> /dev/null
}

# ── project detection ─────────────────────────────────────────────────────────

section "Project detection"

HAS_PYTHON=0
HAS_NOX_SEMGREP=0
HAS_TF=0
HAS_TERRAGRUNT=0
HAS_DOCKERFILE=0
HAS_GHA=0
HAS_KUBE=0
HAS_JS=0
HAS_GO=0
HAS_HELM=0
HAS_SHELL=0
HAS_ML=0

[[ -n "$(qfind '*.py')" ]] && HAS_PYTHON=1 && echo "Python"
if [[ $HAS_PYTHON -eq 1 ]] && [[ -f noxfile.py ]]; then
  grep -qE 'semgrep.all|semgrep-all' noxfile.py 2> /dev/null &&
    HAS_NOX_SEMGREP=1 && echo "  → nox semgrep-all"
fi
[[ -n "$(qfind '*.tf')" ]] && HAS_TF=1 && echo "Terraform"
[[ -n "$(qfind 'terragrunt.hcl')" ]] && HAS_TERRAGRUNT=1 && echo "  + Terragrunt"
[[ -n "$(qfind 'Dockerfile*')" ]] && HAS_DOCKERFILE=1 && echo "Dockerfile"
[[ -d ".github/workflows" ]] && HAS_GHA=1 && echo "GitHub Actions"
grep -rql '^kind:' --include='*.yaml' --include='*.yml' . 2> /dev/null |
  grep -qv '.git/' && HAS_KUBE=1 && echo "Kubernetes"
[[ -f package.json ]] && HAS_JS=1 && echo "JavaScript/TypeScript"
[[ -f go.mod ]] && HAS_GO=1 && echo "Go"
[[ -n "$(qfind 'Chart.yaml')" ]] && HAS_HELM=1 && echo "Helm"
[[ -n "$(qfind '*.sh')" ]] && HAS_SHELL=1 && echo "Shell scripts"
{ [[ -n "$(qfind '*.pkl')" ]] || [[ -n "$(qfind '*.pt')" ]] ||
  [[ -n "$(qfind '*.h5')" ]] || [[ -n "$(qfind '*.onnx')" ]]; } &&
  HAS_ML=1 && warn "ML model files found — unsafe serialization risk"

export HAS_PYTHON HAS_NOX_SEMGREP HAS_TF HAS_TERRAGRUNT HAS_DOCKERFILE \
  HAS_GHA HAS_KUBE HAS_JS HAS_GO HAS_HELM HAS_SHELL HAS_ML

# ── changed-only scoping ──────────────────────────────────────────────────────

CHANGED_FILES=""
if [[ $CHANGED_ONLY -eq 1 ]]; then
  section "Scope: changed files"
  CHANGED_FILES=$(git diff --name-only main...HEAD 2> /dev/null ||
    git diff --name-only HEAD~1...HEAD 2> /dev/null || true)
  if [[ -z "$CHANGED_FILES" ]]; then
    warn "Cannot determine changed files — scanning full repo"
    CHANGED_ONLY=0
  else
    echo "$CHANGED_FILES"
    echo "$CHANGED_FILES" | grep -qE '\.py$' || HAS_PYTHON=0
    echo "$CHANGED_FILES" | grep -qE '\.tf$' || HAS_TF=0
    echo "$CHANGED_FILES" | grep -q 'Dockerfile' || HAS_DOCKERFILE=0
    echo "$CHANGED_FILES" | grep -q '.github/workflows' || HAS_GHA=0
    echo "$CHANGED_FILES" | grep -qE '\.sh$' || HAS_SHELL=0
    echo "$CHANGED_FILES" | grep -qE '\.(js|ts|jsx|tsx)$' || HAS_JS=0
    echo "$CHANGED_FILES" | grep -qE '\.go$' || HAS_GO=0
  fi
fi
export CHANGED_FILES

# ── scanner functions ─────────────────────────────────────────────────────────

do_secrets() {
  section "Secrets (TruffleHog)"
  if has_cmd trufflehog; then
    echo "--- verified (high confidence) ---"
    bounded "trufflehog-verified" 200 trufflehog git file://. --only-verified
    echo ""
    echo "--- all detectors (higher coverage; review false positives) ---"
    bounded "trufflehog-all" 500 trufflehog git file://. --no-verification |
      grep -E '^(Found|Detector|Verified|Raw|Reason|Commit|File|Line)' |
      head -200 || true
  elif has_cmd gitleaks; then
    warn "trufflehog not found — falling back to gitleaks"
    bounded "gitleaks" 300 gitleaks detect --source . --no-git
  else
    echo "ERROR:secrets:no secrets scanner installed" >> "$ERRORS_FILE"
    warn "Install: brew install trufflehog"
    warn "Manual fallback: grep -rn 'AKIA\\|sk-\\|ghp_\\|-----BEGIN' ."
  fi
}

do_patterns() {
  local script="$SCRIPT_DIR/scan-patterns.sh"
  if [[ -f "$script" ]]; then
    if [[ $CHANGED_ONLY -eq 1 ]]; then bash "$script" --changed-only; else bash "$script"; fi
  else
    warn "scan-patterns.sh not found in $SCRIPT_DIR — Prisma pattern checks skipped"
    skip "patterns (install: cp scan-patterns.sh alongside scan.sh)"
  fi
}

do_python() {
  section "Python SAST (Semgrep)"
  if has_cmd semgrep; then
    mkdir -p .reports
    if [[ $HAS_NOX_SEMGREP -eq 1 ]] && has_cmd nox; then
      bounded "nox-semgrep" 500 nox -s semgrep-all
    else
      local targets="."
      [[ $CHANGED_ONLY -eq 1 ]] &&
        targets=$(echo "$CHANGED_FILES" | grep '\.py$' | tr '\n' ' ')
      # shellcheck disable=SC2086
      bounded "semgrep" 500 semgrep scan \
        --config=p/python --config=p/ci --config=p/bandit \
        --config=p/secrets --config=p/owasp-top-ten --config=p/security-audit \
        --severity=WARNING --max-target-bytes=2000000 \
        --timeout=120 --timeout-threshold=5 \
        --sarif-output=.reports/semgrep.sarif \
        $targets
    fi
    [[ -f .reports/semgrep.sarif ]] && echo "SARIF → .reports/semgrep.sarif"
  else
    skip "semgrep (pip install semgrep)"
  fi

  section "Python SAST (ruff security rules)"
  if has_cmd ruff; then
    bounded "ruff" 300 ruff check --select S,B .
  else
    skip "ruff (pip install ruff)"
  fi

  section "Python SCA (pip-audit)"
  if has_cmd pip-audit; then
    bounded "pip-audit" 300 pip-audit
  else
    skip "pip-audit (pip install pip-audit)"
  fi
}

do_iac() {
  section "Terraform (Checkov)"
  if has_cmd checkov; then
    local conf_args=""
    if [[ -f ".checkov/production.yaml" ]]; then
      conf_args="--config-file .checkov/production.yaml"
      local n
      n=$(grep -c '^\s*-' .checkov/production.yaml 2> /dev/null || echo '?')
      warn "Production config active — $n checks skipped. Plan-based scan is more accurate (checkov-scan-terragrunt-plans.sh)"
    elif [[ -f ".checkov/non-production.yaml" ]]; then
      conf_args="--config-file .checkov/non-production.yaml"
      local n
      n=$(grep -c '^\s*-' .checkov/non-production.yaml 2> /dev/null || echo '?')
      warn "Non-production config — $n checks skipped"
    fi
    # shellcheck disable=SC2086
    bounded "checkov-tf" 500 sh -c \
      "checkov -d . --framework terraform $conf_args --compact --quiet -o cli"
    [[ $HAS_TERRAGRUNT -eq 1 ]] &&
      warn "Terragrunt: static scan only — run ./scripts/checkov-scan-terragrunt-plans.sh for full accuracy"
  else
    skip "checkov terraform (pip install checkov)"
  fi
}

do_dockerfile() {
  section "Dockerfile (Checkov)"
  if has_cmd checkov; then
    bounded "checkov-df" 300 checkov -d . --framework dockerfile --compact --quiet -o cli
  else
    skip "checkov dockerfile (pip install checkov)"
  fi

  section "Dockerfile (hadolint)"
  if has_cmd hadolint; then
    find . -name "Dockerfile*" -not -path "./.git/*" | while read -r df; do
      echo "--- $df"
      bounded "hadolint" 100 hadolint "$df"
    done
  else
    skip "hadolint (brew install hadolint)"
  fi
}

do_gha() {
  section "GitHub Actions (Checkov)"
  if has_cmd checkov; then
    bounded "checkov-gha" 300 checkov -d . --framework github_actions --compact --quiet -o cli
  else
    skip "checkov github_actions (pip install checkov)"
  fi
}

do_kubernetes() {
  section "Kubernetes (Checkov)"
  if has_cmd checkov; then
    bounded "checkov-k8s" 300 checkov -d . --framework kubernetes --compact --quiet -o cli
  else
    skip "checkov kubernetes (pip install checkov)"
  fi
}

do_shell() {
  section "Shell scripts (shellcheck)"
  if has_cmd shellcheck; then
    local files
    # git ls-files naturally excludes venvs, node_modules, and untracked tool files
    if git rev-parse --git-dir &> /dev/null 2>&1; then
      files=$(git ls-files '*.sh' 2> /dev/null)
    else
      files=$(find . -name "*.sh" \
        -not -path "*/.git/*" -not -path "*/.terragrunt-cache/*" \
        -not -path "*/node_modules/*" -not -path "*/.venv/*" \
        -not -path "*/.venv_*/*" -not -path "*/.tox/*" -not -path "*/.nox/*" \
        2> /dev/null)
    fi
    if [[ -n "$files" ]]; then
      echo "$files" | xargs shellcheck 2>&1 | head -300 || true
    fi
  else
    skip "shellcheck (brew install shellcheck)"
  fi
}

do_helm() {
  section "Helm (helm lint)"
  if has_cmd helm; then
    find . -name "Chart.yaml" -not -path "./.git/*" | while read -r chart; do
      local dir
      dir="$(dirname "$chart")"
      echo "--- $dir"
      bounded "helm-lint" 100 helm lint "$dir"
    done
  else
    skip "helm lint (brew install helm)"
  fi
}

do_js() {
  section "JS/TS SCA (npm audit)"
  if has_cmd npm; then
    bounded "npm-audit" 200 npm audit --audit-level=moderate
  else
    skip "npm audit (npm not installed)"
  fi

  section "JS/TS SAST (Semgrep)"
  if has_cmd semgrep; then
    bounded "semgrep-js" 300 semgrep scan \
      --config=p/javascript --config=p/typescript --config=p/owasp-top-ten \
      --severity=WARNING --max-target-bytes=2000000
  else
    skip "semgrep js/ts (pip install semgrep)"
  fi
}

do_go() {
  section "Go SCA (govulncheck)"
  if has_cmd govulncheck; then
    bounded "govulncheck" 200 govulncheck ./...
  else
    skip "govulncheck (go install golang.org/x/vuln/cmd/govulncheck@latest)"
  fi

  section "Go SAST (Semgrep)"
  if has_cmd semgrep; then
    bounded "semgrep-go" 300 semgrep scan \
      --config=p/golang --config=p/owasp-top-ten \
      --severity=WARNING --max-target-bytes=2000000
  else
    skip "semgrep go (pip install semgrep)"
  fi
}

do_trivy() {
  section "Multi-language SCA + misconfig (trivy)"
  if has_cmd trivy; then
    bounded "trivy" 400 trivy fs . --scanners vuln,secret,misconfig --quiet
  else
    skip "trivy (brew install trivy)"
  fi
}

do_ml() {
  section "ML model files"
  warn "Unsafe serialization risk — review manually or run modelscan:"
  find . \( -name "*.pkl" -o -name "*.pickle" -o -name "*.pt" \
    -o -name "*.h5" -o -name "*.onnx" \) \
    -not -path "./.git/*" 2> /dev/null | head -50
  if has_cmd modelscan; then
    bounded "modelscan" 200 modelscan -p .
  else
    skip "modelscan (pip install modelscan)"
  fi
}

do_ai() {
  local script="$SCRIPT_DIR/scan-ai.sh"
  if [[ -f "$script" ]]; then
    if [[ $CHANGED_ONLY -eq 1 ]]; then bash "$script" --changed-only; else bash "$script"; fi
  else
    warn "scan-ai.sh not found in $SCRIPT_DIR — AI/GenAI compliance checks skipped"
    skip "ai (install: cp scan-ai.sh alongside scan.sh)"
  fi
}

do_sod() {
  section "Segregation of duties"
  if has_cmd gh; then
    gh pr view --json number,author,reviews,reviewRequests 2> /dev/null ||
      warn "Not on a PR branch or gh CLI not configured — verify SoD manually"
  else
    warn "Not on a PR branch or gh CLI not configured — verify SoD manually"
  fi
}

# ── parallel submission and collection ───────────────────────────────────────

echo ""
echo "Starting parallel scan (scanners: $RUN_SCANNERS)"

submit() {
  local name="$1" fn="$2"
  ("$fn") > "$TMPDIR_SCAN/${name}.out" 2>&1 &
  echo $! > "$TMPDIR_SCAN/${name}.pid"
}

collect() {
  local name="$1"
  [[ -f "$TMPDIR_SCAN/${name}.pid" ]] || return 0
  wait "$(cat "$TMPDIR_SCAN/${name}.pid")" 2> /dev/null || true
  cat "$TMPDIR_SCAN/${name}.out"
  if [[ $SAVE_REPORTS -eq 1 ]]; then
    mkdir -p .reports
    cp "$TMPDIR_SCAN/${name}.out" ".reports/${name}.txt" 2> /dev/null || true
  fi
}

# Submit independent scanners in parallel
should_run "secrets" && submit "secrets" do_secrets
should_run "patterns" && submit "patterns" do_patterns
should_run "python" && [[ $HAS_PYTHON -eq 1 ]] && submit "python" do_python
should_run "iac" && [[ $HAS_TF -eq 1 ]] && submit "iac" do_iac
should_run "dockerfile" && [[ $HAS_DOCKERFILE -eq 1 ]] && submit "dockerfile" do_dockerfile
should_run "gha" && [[ $HAS_GHA -eq 1 ]] && submit "gha" do_gha
should_run "kubernetes" && [[ $HAS_KUBE -eq 1 ]] && submit "kubernetes" do_kubernetes
should_run "shell" && [[ $HAS_SHELL -eq 1 ]] && submit "shell" do_shell
should_run "helm" && [[ $HAS_HELM -eq 1 ]] && submit "helm" do_helm
should_run "js" && [[ $HAS_JS -eq 1 ]] && submit "js" do_js
should_run "go" && [[ $HAS_GO -eq 1 ]] && submit "go" do_go
should_run "trivy" && submit "trivy" do_trivy
should_run "ml" && [[ $HAS_ML -eq 1 ]] && submit "ml" do_ml
should_run "ai" && submit "ai" do_ai
submit "sod" do_sod

# Collect in defined order — each collect() blocks until that scanner finishes
for scanner in secrets patterns python iac dockerfile gha kubernetes shell helm js go trivy ml ai sod; do
  collect "$scanner"
done

# ── summary ───────────────────────────────────────────────────────────────────

section "Scan summary"

FINDINGS_COUNT=$(wc -l < "$FINDINGS_FILE" | tr -d ' ')
SKIPPED_COUNT=$(wc -l < "$SKIPPED_FILE" | tr -d ' ')
ERRORS_COUNT=$(wc -l < "$ERRORS_FILE" | tr -d ' ')

echo "Structured findings (HIGH/CRITICAL from pattern and AI checks): $FINDINGS_COUNT"

if [[ $SKIPPED_COUNT -gt 0 ]]; then
  echo ""
  echo "Skipped (tool not installed):"
  sed 's/^/  - /' < "$SKIPPED_FILE"
fi

if [[ $ERRORS_COUNT -gt 0 ]]; then
  echo ""
  echo "Errors:"
  sed 's/^/  - /' < "$ERRORS_FILE"
fi

echo ""
echo "Requires CI or AWS credentials (not run locally):"
[[ $HAS_TERRAGRUNT -eq 1 ]] &&
  echo "  - Terragrunt plan-based checkov (./scripts/checkov-scan-terragrunt-plans.sh)"
echo "  - ECR container image scanning"
echo "  - GitHub Advanced Security SARIF ingestion"
[[ -f .reports/semgrep.sarif ]] && echo "  - SARIF → .reports/semgrep.sarif"
[[ $SAVE_REPORTS -eq 1 ]] && echo "  - Full scanner outputs → .reports/"

echo ""
echo "━━━ end of scan ━━━"

# ── exit code ─────────────────────────────────────────────────────────────────

if [[ $FAIL_ON_FINDINGS -eq 1 ]] && [[ $FINDINGS_COUNT -gt 0 ]]; then
  echo ""
  echo "HIGH/CRITICAL findings (triggered --fail-on-findings):"
  sed 's/^/  /' < "$FINDINGS_FILE"
  exit 1
fi
