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
pytest tests/algo_dlr/test_reference_processor.py::TestSteadyStateAmpacity::test_ampacity_positive  # Single test
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

**algo-dlr** provides Dynamic Line Rating (DLR) computation — IEEE 738-2012 and CIGRE TB 601 thermal heat-balance processors with a benchmarking and comparison framework. Distributed privately via AWS CodeArtifact.

### Processor pattern

Every processor is instantiated with a `ConductorParams` stored as `self.conductor`. Core interface:

```python
from algo_dlr import get_available_processors
from algo_dlr.benchmarks.data.conductors import DRAKE

processor_classes = get_available_processors()
processor = processor_classes["ieee738"](DRAKE)

ampacity = processor.steady_state_ampacity(weather, max_temp)    # A
temp     = processor.steady_state_temperature(weather, current)  # °C
```

DataFrame API — columns match constants in `dlr_processor.py` (`COL_WIND_SPEED`, `COL_ATTACK_ANGLE`, `COL_AMBIENT_TEMP`, `COL_SOLAR_IRRADIANCE`, `COL_LINE_CURRENT`, `COL_TIMESTAMP`, `COL_ALTITUDE`):

```python
temps   = processor.calc_conductor_temperatures(df, is_transient=True,
              transient_time_step=60.0)        # np.ndarray, °C
ratings = processor.calc_line_ratings(df, max_conductor_temp=80.0)  # np.ndarray, A
```

Transient capability: `supports_transient` property (True if processor implements `_dTdt`). Built-in processors `ieee738` and `cigre601` both support transient via Euler integration.

### Self-registration pattern

Each processor module calls `DLRProcessorRegistry.register(ProcessorClass, available=_AVAILABLE)` at import time. `_register_all()` (called in `__init__.py`) imports all processor modules to trigger registration.

Processors guard optional deps with `try/except ImportError` → `_AVAILABLE` flag; unavailable processors raise `ImportError` in `__init__`. `DLRProcessorRegistry.available()` returns only the available ones.

### Always-available processors

- `ieee738` — IEEE 738-2012 heat balance (no optional deps)
- `cigre601` — CIGRE TB 601 heat balance (no optional deps)

### Optional processors (install extras)

| Name | Extra | Library |
|------|-------|---------|
| `pylinerating_ieee738`, `pylinerating_cigre601` | `pylinerating` | `pip install pylinerating` |
| `linerate_ieee738`, `linerate_cigre601` | `linerate` | `pip install linerate` |
| `thermohl_ieee738`, `thermohl_cigre207` | `thermohl` | `pip install thermohl` |
| `pandapower` | `pandapower` | `pip install pandapower>=3.4` |
| `pypsa` | `pypsa` | `pip install pypsa>=1.1` |

Install all: `pip install "algo-dlr[dynamic-ratings]"`

### Package layout

```
src/algo_dlr/
├── __init__.py              # get_available_processors(); calls _register_all()
├── objects.py               # ConductorParams, WeatherParams, TimeSeries, DLRStandard
├── dlr_processor.py         # DLRProcessor ABC + COL_* constants
├── dlr_processor_registry.py# DLRProcessorRegistry singleton
├── processors/
│   ├── reference_ieee.py    # ieee738 — always available
│   ├── reference_cigre.py   # cigre601 — always available
│   ├── pylinerating.py      # optional
│   ├── linerate.py          # optional
│   ├── thermohl.py          # optional
│   ├── pandapower.py        # optional
│   └── pypsa.py             # optional
└── benchmarks/
    ├── benchmark_line_ratings.py   # accuracy + performance for steady-state ratings
    ├── benchmark_conductor_temp.py # steady-state, transient, and transient perf
    ├── data/
    │   ├── conductors.py    # DRAKE, CARDINAL, TERN, DRAKE_CIGRE_EXAMPLE_B
    │   ├── fixtures.py      # Fixture dataclass; CIGRE_TB601_EXAMPLE_B, IEEE738_APPENDIX, ...
    │   └── weather.py       # generate() synthetic hourly weather dataset
    └── report/
        ├── tables.py        # DataFrame → markdown/HTML/CSV tables
        ├── plots.py         # matplotlib plots (optional dep)
        └── summary.py       # generate_markdown() full benchmark report
```

### Key design rules

- Processors never import their optional library at module level — always guard with `try/except ImportError` and `_AVAILABLE`.
- `linerate` adapter targets v3.x API. If you see AttributeErrors, check `pip show linerate`.
- `pandapower` and `pypsa` processors use `reference_ieee.py` for the thermal calc and only use their libraries for grid-level validation.
- Benchmarks (`benchmark_line_ratings.run`, `benchmark_conductor_temp.run_steady_state`) accept `dict[str, type[DLRProcessor]]` of classes; they instantiate per-fixture internally.
- CI tests use only `ieee738` and `cigre601` processors (always available, no optional deps).

### Tooling

- **uv** for dependency management (required globally)
- **nox** for task automation (required globally)
- **ruff** linting with `select = ["ALL"]`; `F401` (unused imports) is **explicitly ignored — never remove unused imports**
- **setuptools_scm** for automatic versioning from git tags
