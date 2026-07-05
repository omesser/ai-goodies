# FCM — Fleet Configuration Management

## What This Project Is

FCM is an operations tool for managing, monitoring, and operating a fleet of field-deployed DAS (Distributed Acoustic Sensor) edge systems. It accompanies (does NOT replace) an existing CI/CD-based configuration builder that produces YAML config files.

## System Context

- **Sites**: Field-deployed systems, each identified by a site name. Typically 2 PCs + optical unit.
- **Pipeline**: DAS sensor → Interrogator (processing PC) → Storage Server (PC with MongoDB + customer UI server).
- **Config**: A single YAML file per PC, produced by a proprietary config builder in CI/CD. Defines detectors, exports, recordings, data pipes.
- **ML Detectors**: Intrusion, vehicle, digging, etc. over optical fiber.
- **Customers**: Critical infrastructure companies, military contractors.

## What FCM Does

1. **Config Management**: View, validate, compare, safely modify YAML configs with full audit trail.
2. **Monitoring & Diagnostics**: System health (via Telegraf), fiber visualization, spectrograms, event feeds.
3. **Fleet Management**: Central oversight of multiple sites.
4. **Audit**: Access logs (who connected) + action logs (what they did). SQLite-backed, exportable to CSV/YAML.
5. **RBAC**: Role-based access control. Roles: admin, qa, fae, deployment, manufacturing, lab, viewer.

## Architecture Decisions (FINAL)

### Tech Stack
- **Backend**: Python 3.11+, FastAPI, Uvicorn
- **Frontend**: React 18+ with TypeScript, Vite, Tailwind CSS, shadcn/ui
- **Storage**: SQLite (users, audit, config history) — one DB per PC
- **Communication**: REST (HTTPS) + WebSocket (WSS)
- **Auth**: Local users with JWT (Google Auth deferred to future)
- **TLS**: Configurable — enabled for production, disabled for local dev

### Packaging & Deployment
- Standard PyPI package hosted on AWS CodeArtifact
- `pip install pz-fcm` — no compiled binaries
- Setup scripts create venv, install deps, register services
- Windows: NSSM wraps `python -m fcm` as a Windows service
- Linux: systemd unit
- Must work on both Windows and Linux
- Docker images published to ECR via the pz-edge-containers reusable workflow
  (`Dockerfile` + `service.yaml` follow that template). A local `Dockerfile.local`
  + `docker-compose.yaml` lets developers run FCM in a container without
  publishing first. K8s is not in scope.

### Module System
- Every feature is a module with: manifest.yaml, api.py, permissions.py, validation.py, ui/
- Core modules ship with the `pz-fcm` package
- Neighbor team modules are separate PyPI packages on CodeArtifact
- Modules register via Python entry points: `[project.entry-points."fcm.modules"]`
- Server discovers modules at startup via `importlib.metadata.entry_points(group="fcm.modules")`
- Frontend is bundled at build time (not dynamically loaded)

### Access Control (Simplified IAM)
- User → Role → Policy → Actions
- One role per user
- Policies are allow/deny lists with wildcard support (`config.*`, `config.editor.*`)
- Deny wins over allow. Default deny.
- Roles/policies defined in YAML file (`default_policies.yaml`)
- Actions declared by modules in `permissions.py`
- Action naming: `{group}.{module}.{operation}`

### Deployment Modes
- **Local**: Agent + Server + UI on same PC (air-gapped)
- **Site**: Agent on each PC, Server + UI on one PC (LAN)
- **Central**: Agents on PCs, Server + UI at office (VPN)
- Same package, mode determined by `fcm_config.yaml`

### Locking
- Site-level write lock. One operator at a time.
- Lock held at agent level.
- Auto-expires on timeout or disconnect (heartbeat).
- Read-only access does not require lock.

### Config Change Workflow
1. Operator selects parameter to change
2. System validates proposed change
3. System shows impact summary in human-readable form
4. Operator confirms
5. System backs up current config, applies change, restarts affected services, logs action
6. Online sites: push override to CI/CD
7. Air-gapped sites: export diff file to disk-on-key

### SQLite Requirements
- One DB per PC (agent owns its audit trail)
- Admin-queryable via SSH (`sqlite3 fcm.db "SELECT ..."`)
- CLI export/import: `fcm db export --table action_log --format csv/yaml`
- Hard requirement: all persistent data exportable to CSV and YAML

### UI Design Direction
- Dark mode primary. Deep navy/slate (#0f172a), teal accent (#06b6d4), amber warnings, red errors.
- Inter / JetBrains Mono typography. Dense, high-legibility.
- Industrial-grade, clinical, professional. No decorative elements.
- Lucide icons. Minimal animations. High data density.
- Target: 1920×1080 primary, 1366×768 minimum. No mobile.
- All assets bundled — zero external dependencies (air-gapped compatible).

## API Conventions

- Base URL: `/api/v1/{module_group}/{module_name}/{endpoint}`
- Standard JSON envelope: `{ ok, data, error, meta }`
- All mutations require write lock + permission check + audit log
- WebSocket: `/api/v1/ws/{group}/{module}/{stream}?token={jwt}`

## Module Groups

| Group | Modules |
|---|---|
| config | config_viewer, config_editor, config_diff, config_history, config_sync |
| monitoring | health_dashboard, event_feed, log_viewer |
| visualization | fiber_viz, spectrogram_viz |
| fleet | fleet_overview, site_selector |
| admin | audit_log, lock_manager, user_manager |
| manufacturing | calibration |

## RBAC Roles

| Role | Access |
|---|---|
| admin | Everything |
| qa | Config R/W, all monitoring, all viz, fleet |
| fae | Config modify (no rollback), monitoring, viz |
| deployment | Read-only. Validate configs. |
| manufacturing | Calibration + health dashboard |
| lab | Visualization tools, experimental features |
| viewer | Read-only all non-admin modules |

## Key Principles

1. FCM does NOT replace the config builder — it accompanies it.
2. No changes without validation + user confirmation.
3. Full audit trail always.
4. Simple and reliable — field engineers depend on this.
5. Modular — each module is self-contained with own API/UI/permissions.
6. Air-gapped friendly — everything works offline.

## Repo Structure

See docs/ for full architecture documents:
- docs/01_architecture.md
- docs/02_orchestration.md
- docs/03_access_control.md
- docs/04_module_system.md
- docs/05_deployment.md
- docs/06_ui_guidelines.md
- docs/07_fae_user_guide.md
- docs/08_developer_guide.md
- docs/09_use_cases.md
