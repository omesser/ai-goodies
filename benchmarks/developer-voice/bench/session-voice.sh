#!/usr/bin/env bash
# Treatment arm: no plugins, developer-voice injected by a SessionStart hook.
# Usage: ./session-voice.sh <prompt-file>   or   ./session-voice.sh <<< "prompt"
set -euo pipefail
cd "$(dirname "$0")" && . ./_env.sh

if [ $# -gt 0 ]; then
  prompt="$(cat "$1")"
else
  prompt="$(cat)"
fi
run_session 1 "$prompt"
