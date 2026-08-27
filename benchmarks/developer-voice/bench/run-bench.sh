#!/usr/bin/env bash
# Full matrix: every prompt x both arms x REPS repetitions.
# Results land in out/<arm>_<prompt>_r<rep>.txt
#
# MAXJOBS caps concurrency. Firing all 14 sessions of a repetition at once
# risks rate limiting, and a throttled run that returns short output would look
# like a real effect.
set -euo pipefail
cd "$(dirname "$0")" && . ./_env.sh

REPS="${REPS:-3}"
MAXJOBS="${MAXJOBS:-6}"
mkdir -p out && rm -f out/*.txt

throttle() { while [ "$(jobs -rp | wc -l)" -ge "$MAXJOBS" ]; do wait -n; done; }

for rep in $(seq 1 "$REPS"); do
  for p in prompts/p*.txt; do
    n="$(basename "$p" .txt)"
    throttle
    run_session 0 "$(cat "$p")" > "out/off_${n}_r${rep}.txt" &
    throttle
    run_session 1 "$(cat "$p")" > "out/on_${n}_r${rep}.txt" &
  done
  wait
  echo "[rep $rep complete]"
done

empty=0
for f in out/*.txt; do [ -s "$f" ] || {
  echo "EMPTY: $f"
  empty=1
}; done
[ "$empty" -eq 0 ] && echo "all $(find out -name '*.txt' | wc -l | tr -d ' ') runs non-empty"
exit "$empty"
