# security-review skill

Runs live security scans on the current repo, interprets findings, then applies Company's Secure SDLC and Change Management compliance framework to produce a verdict.

## What it runs

| Language / Stack | Tools |
|---|---|
| **Python** | `nox -s semgrep-all` (if noxfile exists) or direct `semgrep` with `p/python p/ci p/bandit p/secrets p/owasp-top-ten p/security-audit`; `ruff --select S,B` |
| **Terraform / IaC** | `checkov` with `.checkov/production.yaml` or `.checkov/non-production.yaml` if present; Terragrunt plan-based scan via `checkov-scan-terragrunt-plans.sh` if AWS creds available |
| **Kubernetes** | `checkov --framework kubernetes` |
| **JavaScript / TypeScript** | `npm audit`; `semgrep p/javascript p/typescript p/owasp-top-ten` |
| **Go** | `govulncheck`; `semgrep p/golang p/owasp-top-ten` |
| **Shell** | `shellcheck` |
| **Helm** | `helm lint` |
| **Secrets (all)** | `trufflehog git --only-verified` |

Tools are auto-detected from repo contents. Missing tools are noted and skipped — the scan continues.

## What it checks (compliance framework)

- Change classification (Low-Risk / Normal/Material / Emergency) per Company's Change Management Policy
- Threat modeling triggers (SDLC §3.2)
- Security Engineering review triggers (Change Management §6.3)
- SDLC gates: peer review, SAST, SCA, secrets, IaC, container scanning
- Secrets and credential hygiene
- Vulnerability SLAs: Critical < 1 week, High < 1 month
- Audit trail completeness for ISO 27001/27034, SOC 2 Type II, NIST SP 800-53

## Scripts

| Script | Purpose |
|---|---|
| `scan.sh` | Orchestrator — parallel execution, flag parsing, project detection, calls companions |
| `scan-patterns.sh` | Company-specific grep patterns: TLS disabled, auth bypass, SQL f-strings, eval/exec, AI/ML risks |
| `scan-ai.sh` | AI/GenAI artifact inventory and GenAI Use Policy compliance checks |

All three scripts must be placed together (same directory) — `scan.sh` discovers companions via `SCRIPT_DIR`.

## Install

Copy the skill directory into your project or user skills directory:

```bash
# project-level
cp -r /path/to/ai-goodies/skills/security-review .claude/skills/

# or user-level (available in all projects)
cp -r /path/to/ai-goodies/skills/security-review ~/.claude/skills/
```

`${CLAUDE_SKILL_DIR}` in `SKILL.md` resolves to the installed directory at runtime, so the skill finds its companion scripts wherever it is installed.

## Usage

```
/security-review
```

```
/security-review PR #42 — new auth middleware
```

Run the scan scripts directly:

```bash
bash scripts/scan.sh                          # full scan, all applicable tools
bash scripts/scan.sh --changed-only           # scope to changed files only
bash scripts/scan.sh --only secrets,python    # specific scanners
bash scripts/scan.sh --skip trivy --save-reports --fail-on-findings
```

The skill auto-detects project type, runs applicable scans in parallel, and outputs a structured report with a clear ✅ / ❌ / ⚠️ verdict.

## Prerequisites

Install the tools relevant to your stack:

```bash
# Python
pip install semgrep
pip install ruff
# or: uv tool install semgrep ruff

# Secrets
brew install trufflehog

# IaC
pip install checkov

# Shell
brew install shellcheck

# Go
go install golang.org/x/vuln/cmd/govulncheck@latest
```

## Policies

Grounded in:
- Secure Development Life Cycle (SDLC) Policy — Full (link redacted)
- Change Management Policy (link redacted)
- Generative AI Use and Oversight Policy for Engineering (link redacted)

All maintained by Company. The links above require authentication; the skill itself is self-contained and needs no access to them at runtime.
