#!/usr/bin/env bash
# Baseline arm: no plugins, no developer-voice.
# Usage: ./session-clean.sh <prompt-file>   or   ./session-clean.sh <<< "prompt"
set -euo pipefail
cd "$(dirname "$0")" && . ./_env.sh

if [ $# -gt 0 ]; then
  prompt="$(cat "$1")"
else
  prompt="$(cat)"
fi
run_session 0 "$prompt"
