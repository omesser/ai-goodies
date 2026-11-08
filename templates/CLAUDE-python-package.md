# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Setup
```bash
nox -s dev          # Create .venv and install all deps
source .venv/bin/activate
```

#### Running tests without nox (Python 3.11 not in PATH)

nox requires Python 3.11 but the system may only have 3.8.x. Use `uv` to create an
isolated 3.11 environment for a quick iteration loop:

```bash
# One-time setup (creates testenv/ in repo root — gitignored)
uv venv --python 3.11 testenv
uv pip install -e ".[tests,dynamic-ratings]" --python testenv/Scripts/python.exe --no-binary fonttools

# Run tests
testenv/Scripts/python -m pytest tests/ -x -q

# Teardown when done
rm -rf testenv
```

`--no-binary fonttools` is required due to a Windows PE resource error when
installing fonttools as a wheel into a uv-managed venv.

### Tests
```bash
nox -s tests                                                           # All tests with coverage
```

### Lint & Format
```bash
nox                 # Default: runs lint + tests_unit
nox -s lint         # Pre-commit hooks (ruff + codespell + yaml/json checks)
nox -s fmt          # Auto-format with ruff
```

### Build
```bash
nox -s build
```

## Architecture

PLACEHOLDER

### Key design rules

PLACEHOLDER

### Tooling

- **uv** for dependency management (required globally)
- **nox** for task automation (required globally)
- **ruff** linting with `select = ["ALL"]`; `F401` (unused imports) is **explicitly ignored — never remove unused imports**
- **setuptools_scm** for automatic versioning from git tags
