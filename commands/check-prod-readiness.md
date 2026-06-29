# Check Production Readiness

Run through this checklist before merging changes intended for production.

## Config checks (`orion_prod.yaml`)

- [ ] No URI / link values are hardcoded. if any are constructed make sure they are secure (no http, ssh, ftp or a non secure protocol)
- [ ] File paths are relative. Raise a flag for any hardcoded absolute paths.
- [ ] No Windows paths

## Code checks

- [ ] No dangerous calls to external www links, no calls anyone's private IP or box URL
- [ ] No hardcoded local paths (`D:\`, `C:\tmp`, etc.) in production-path code

## Quality gates

```bash
nox -s tests   # must pass with 100% coverage
nox -s lint    # must pass with zero Ruff errors
```

- [ ] `nox -s tests` passes
- [ ] `nox -s lint` passes
- [ ] `pyproject.toml` updated if new dependencies were added
- [ ] Pre-commit hooks pass (`pre-commit run --all-files`)
