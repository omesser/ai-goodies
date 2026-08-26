#!/usr/bin/env bash
# Shared configuration for the developer-voice benchmark.
#
# Design notes, because two earlier attempts at this benchmark were invalidated
# by things leaking into both arms:
#
#  1. Every plugin is disabled through an inline `--settings` override. The
#     user's ~/.claude/settings.json is never modified. An earlier version
#     toggled that file in place and corrupted it.
#  2. DEV_VOICE_OFF=1 is exported for BOTH arms, which suppresses any
#     developer-voice SessionStart hook the user has installed globally. The
#     treatment arm injects the skill through its own hook instead, so the
#     benchmark does not depend on the user's machine setup.
#  3. Claude runs from a scratch directory, so no AGENTS.md or CLAUDE.md from
#     this repo reaches the session.
#
# The only difference between the two arms is the injected SessionStart hook.

set -euo pipefail

SKILL_MD="${SKILL_MD:-$HOME/.claude/skills/developer-voice/SKILL.md}"

# Plugins that inject instructions into every session. context-mode is the one
# that matters most: it injects "Return only: file path + 1-line description",
# a direct constraint on output length.
DISABLED_PLUGINS='[
  "ponytail@ponytail",
  "context-mode@context-mode",
  "superpowers@claude-plugins-official",
  "last30days@last30days-skill"
]'

# build_settings <0|1> — emit the --settings JSON. 1 adds the skill-injecting hook.
build_settings() {
  python3 -c '
import json, sys
plugins = json.loads(sys.argv[1])
skill, with_skill = sys.argv[2], sys.argv[3] == "1"
s = {"enabledPlugins": {p: False for p in plugins}}
if with_skill:
    s["hooks"] = {"SessionStart": [{
        "matcher": "startup",
        "hooks": [{"type": "command", "command": "cat " + json.dumps(skill), "timeout": 5}],
    }]}
print(json.dumps(s))
' "$DISABLED_PLUGINS" "$SKILL_MD" "$1"
}

# run_session <0|1> <prompt> — one fresh session, answer on stdout.
run_session() {
  local with_skill="$1" prompt="$2" workdir
  workdir="$(mktemp -d)"
  (
    cd "$workdir"
    DEV_VOICE_OFF=1 claude --settings "$(build_settings "$with_skill")" -p "$prompt" </dev/null
  )
  # claude writes session state into the cwd, so rmdir is not enough.
  case "$workdir" in /*/*) rm -rf "$workdir" ;; esac
}

[ -f "$SKILL_MD" ] || { echo "SKILL.md not found at $SKILL_MD" >&2; exit 1; }
