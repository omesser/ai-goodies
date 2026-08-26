#!/usr/bin/env bash
# Treatment arm: no plugins, developer-voice injected by a SessionStart hook.
# Usage: ./session-voice.sh <prompt-file> | ./session-voice.sh <<< "prompt"
set -euo pipefail
cd "$(dirname "$0")" && . ./_env.sh
run_session 1 "$( [ $# -gt 0 ] && cat "$1" || cat )"
