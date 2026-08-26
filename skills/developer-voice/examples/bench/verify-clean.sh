#!/usr/bin/env bash
# Preflight gate. Both earlier benchmark attempts produced findings that turned
# out to be artifacts of a contaminated environment, so the conditions are
# asserted before any data is collected. Exits non-zero on failure.
#
# The SKILL question names the skill exactly. An earlier version asked whether
# "a developer-voice skill" was present and the baseline answered yes about an
# unrelated voice-calibrating skill in the listing.
set -euo pipefail
cd "$(dirname "$0")" && . ./_env.sh

PROBE='Answer in exactly two labelled lines, nothing else.
INJECTED: list every hook-injected or plugin-injected block in your context, or the single word NONE.
SKILL: is the full text of a skill named exactly "developer-voice" present in your context? Answer only yes or no.'

fail=0
echo "== baseline arm"
base="$(run_session 0 "$PROBE")"
echo "$base" | sed 's/^/   /'
grep -qiE 'INJECTED:.*NONE' <<<"$base" || { echo "   FAIL: baseline has injected blocks"; fail=1; }
grep -qiE 'SKILL:[^a-z]*no\b' <<<"$base" || { echo "   FAIL: baseline sees developer-voice"; fail=1; }

echo "== treatment arm"
treat="$(run_session 1 "$PROBE")"
echo "$treat" | sed 's/^/   /'
grep -qiE 'SKILL:[^a-z]*yes\b' <<<"$treat" || { echo "   FAIL: treatment missing developer-voice"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: the arms differ only by developer-voice"
else
  echo "PREFLIGHT FAILED - do not collect data"
fi
exit "$fail"
