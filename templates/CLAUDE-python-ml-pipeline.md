# Orion — Claude Code Context

## Project Overview

`algo-orion` is a DAS (Distributed Acoustic Sensing) ML pipeline for detecting harmonic acoustic events
(e.g., power-tool activity) on Prisma Photonics fiber-optic recordings. The pipeline runs in two modes:

- **Local/debug**: processes `.prp2` or `.segy` recording files from disk, writes outputs to local paths.
- **Production**: streams data via AMQP, outputs heatmaps and alerts to AMQP streams.

Detection stages: STFT → harmonic comb scoring → z-score event detection → AST embeddings → PCA + LR classifier → alerts.

---

## Key Entry Points

| File | Purpose |
|------|---------|
| `src/algo_orion/runner/run_orion_over_pt.py` | Local pipeline runner — trigger a run on disk recordings |
| `src/algo_orion/pipeline/orion.yaml` | Local/debug pipeline config |
| `src/algo_orion/pipeline/orion_prod.yaml` | Production pipeline config |
| `src/algo_orion/pipeline/predictors/` | All predictor classes |
| `src/algo_orion/pipeline/signal/` | Signal processing utilities |
| `src/algo_orion/tests/` | Unit tests |

---

## Recording Data (`pz_core_libs`)

```python
from pz_core_libs.recording import Recording

rec = Recording.open_recording(rec_path)  # rec_path: dir containing .prp2 or .segy files
```

`Recording` exposes:
- `rec.metadata` — start/end timestamps, fiber length, dx/prr (spatial/temporal resolution)
- `rec.data` — raw DAS data matrix (channels × time)

This is the only supported way to open Prisma Photonics recordings.

---

## Pipeline Configs

### `orion.yaml` — Local / Debug

- All 5 predictors active, including `OrionDebugPredictor`
- Outputs to local disk: `D:\PZ_PROCESSED_DATA\orion_hm_0605\*` and `C:\tmp_pt`
- Debug spectrogram dumps to `D:\PZ_PROCESSED_DATA\debug0605`
- `event_baseline_alpha: 0.0` — frozen baseline (no drift)
- Embeddings saved to `D:\PZ_PROCESSED_DATA\embs_0605`

### `orion_prod.yaml` — Production

- 4 predictors — **no `OrionDebugPredictor`**
- All outputs via AMQP:
  - Alerts → `amqp://?stream=Pulse`
  - z_bandpower heatmap → `amqp://?stream=heatmapsZBandpower`
  - Blobs heatmap → `amqp://?stream=heatmapsBlobs`
  - Embeddings → `amqp://?stream=heatmapsOrionEmbs`
- `event_baseline_alpha: 0.05` — slow drift allowed
- `embeddings_save_path: ""` — no local embedding dumps
- Model paths are relative: `models\pca.pkl`, `models\lr.pkl`

**When scope is ambiguous, ask whether the change targets local/debug or production before editing configs.**

---

## Predictors

All predictors must be explicitly imported in `run_orion_over_pt.py` for the local runner.

| Class | File | Config Key | Local | Prod |
|-------|------|-----------|-------|------|
| `OrionOnsetPredictor` | `predictors/onset_predictor.py` | `OrionOnsetPredictorConfig` | yes | yes |
| `OrionDebugPredictor` | `predictors/debug_predictor.py` | `OrionDebugPredictorConfig` | yes | **no** |
| `OrionASTEmbeddingPredictor` | `predictors/ast_emb_predictor.py` | `OrionASTEmbeddingPredictorConfig` | yes | yes |
| `OrionEmbeddingClassifierPredictor` | `predictors/label_predictor.py` | `OrionEmbeddingClassifierPredictorConfig` | yes | yes |
| `OrionAlertPredictor` | `predictors/alert_predictor.py` | `OrionAlertPredictorConfig` | yes | yes |

Base classes from `algo_common.runner.predictor`: `IOPredictor`, `AlertsPredictor`.

Trained models: `src/algo_orion/pipeline/models/pca.pkl`, `lr.pkl`.
AST model: `MIT/ast-finetuned-audioset-10-10-0.4593` (HuggingFace).

---

## Unit Tests

Location: `src/algo_orion/tests/test_orion.py`
Constants: `src/algo_orion/tests/unittest_constants.py` (sample rate 1000 Hz, 45 m spacing, 15 s window)

Run tests:
```bash
nox -s tests
```

- **100% code coverage is required** (enforced by CI).
- **Ask the user** whether to add/update unit tests when implementing new functionality before doing so.

---

## Linting

Tool: **Ruff** — configured entirely in `pyproject.toml` (`[tool.ruff]`).

```bash
nox -s lint      # check + fix
```

Per-file ignore rules are already configured for `pipeline/`, `runner/`, `clusterer/`, `embedder/` —
notably `F401` (unused imports) is suppressed in `runner/` because all predictor imports must be present
even if not directly referenced.

**Comply with lint rules on every change to avoid merge rejects.**
Do not add `# noqa` without a specific rule and reason.

---

## Git Policy

**Never commit without explicit user approval.** Stage files and show the diff/summary, then wait for the user to say "commit" (or similar) before running `git commit`. This applies to all commits including lint fixes, doc updates, and auto-fixes.

---

## Pyrallis Config — Type Annotation Rules

Pyrallis reads `field.type` directly from dataclass fields at runtime and calls `decode(field.type, value)`.
`from __future__ import annotations` makes **all** annotations lazy strings (`field.type == "float"` instead
of `float`), which pyrallis cannot decode — the config entry fails silently or raises a `TypeError`.

**Rules for any file that contains a pyrallis `Config` dataclass** (i.e. any predictor file):

- **Never add `from __future__ import annotations`** to predictor files.
- Use `Optional[X]` and `List[X]` (from `typing`) instead of `X | None` and `list[X]` in Config fields.
- Non-Config annotations (method return types, local variables) can use modern syntax freely.

If you see `TypeError: No valid parsing for value {... 'SomeConfig': {'field': value} ...}` during pipeline
startup, suspect `from __future__ import annotations` in the predictor file that owns that config.

---

## `pyproject.toml` Compliance

- All new dependencies go in `pyproject.toml` under `[project.dependencies]` or `[project.optional-dependencies]`.
- Python 3.10+ compatibility required (no 3.11+ syntax without a `TYPE_CHECKING` guard).
- Package name: `algo-orion`; import name: `algo_orion`.

---

## Dev Setup

```bash
nox -s dev     # create venv and install all deps
nox -s tests   # run tests with coverage
nox -s lint    # run ruff linter
```

GPU support via CUDA — `algo_common[runner]` manages PyTorch dependencies.
Pre-commit hooks: Ruff (v0.6.8), codespell, TOML/YAML formatters.

---

## Running the Local Pipeline

See `/run-local` skill for step-by-step guidance.

Edit `rec_paths` in `run_orion_over_pt.py` to point at valid `.prp2`/`.segy` recording directories,
then run the script directly (not via nox):

```bash
python src/algo_orion/runner/run_orion_over_pt.py
```

Output goes to `C:\tmp_pt` and `D:\PZ_PROCESSED_DATA\orion_hm_0605\*`.
