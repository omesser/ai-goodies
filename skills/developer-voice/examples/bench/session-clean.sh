#!/usr/bin/env bash
# Baseline arm: no plugins, no developer-voice.
# Usage: ./session-clean.sh <prompt-file> | ./session-clean.sh <<< "prompt"
set -euo pipefail
cd "$(dirname "$0")" && . ./_env.sh
run_session 0 "$( [ $# -gt 0 ] && cat "$1" || cat )"
