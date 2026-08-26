#!/usr/bin/env python3
"""Score the benchmark output in bench/out/.

Prose metrics exclude fenced and inline code, because a prompt that asks for an
artifact puts the deliverable in a fence and it would otherwise dominate the
word count. Banned-term counts are reported separately for prose and for the
full text, since an earlier scoring pass missed `TL;DR` appearing inside a
drafted Slack message rather than in the surrounding prose.
"""

import re
import statistics as st
from collections import defaultdict
from pathlib import Path

OUT = Path(__file__).parent / "out"

# Terms the skill's substitutions table targets, plus generic enthusiasm markers.
BANNED = [
    "great question",
    "good question",
    "absolutely right",
    "you're right",
    "great idea",
    "happy to help",
    "nice work",
    "well done",
    "kudos",
    "please note",
    "it is important to note",
    "at this time",
    "simply",
    " just ",
    "this is easy",
    "obviously",
    "in order to",
    "let's ",
    "tl;dr",
    "ymmv",
    "sanity check",
    "sanity-check",
    "short answer",
    "excited",
    "thrilled",
    "delighted",
    "awesome",
    "seamless",
    "blazing",
    "game-chang",
    "supercharge",
    "unlock",
    "empower",
    "leverage",
]


def split_code(text):
    """Return (full_text, prose_only)."""
    prose = re.sub(r"```.*?\n.*?```", "", text, flags=re.S)
    prose = re.sub(r"`[^`]*`", "", prose)
    return text, prose


def scan(path):
    full, prose = split_code(path.read_text())
    lf, lp = full.lower(), prose.lower()
    return {
        "words": len(prose.split()),
        "bang": prose.count("!"),
        "banned_prose": {b.strip(): lp.count(b) for b in BANNED if lp.count(b)},
        "banned_full": {b.strip(): lf.count(b) for b in BANNED if lf.count(b)},
        "opening": " ".join(prose.split())[:70],
    }


def main():
    runs = defaultdict(list)  # (prompt, arm) -> [scan, ...]
    for f in sorted(OUT.glob("*.txt")):
        arm, rest = f.stem.split("_", 1)
        prompt = rest.rsplit("_r", 1)[0]
        runs[(prompt, arm)].append(scan(f))

    prompts = sorted({p for p, _ in runs})
    totals = {"off": 0, "on": 0}
    print(
        f"{'prompt':22} {'arm':4} {'mean':>6} {'spread':>7} {'!':>3}  banned (prose | in-code only)"
    )
    for p in prompts:
        for arm in ("off", "on"):
            rs = runs.get((p, arm), [])
            if not rs:
                continue
            w = [r["words"] for r in rs]
            totals[arm] += sum(w)
            bp, bf = defaultdict(int), defaultdict(int)
            for r in rs:
                for k, v in r["banned_prose"].items():
                    bp[k] += v
                for k, v in r["banned_full"].items():
                    bf[k] += v
            only_code = {
                k: v - bp.get(k, 0) for k, v in bf.items() if v - bp.get(k, 0) > 0
            }
            print(
                f"{p:22} {arm.upper():4} {st.mean(w):6.0f} {max(w) - min(w):7} "
                f"{sum(r['bang'] for r in rs):3}  {dict(bp) or '-'} | {only_code or '-'}"
            )
        print()

    delta = 100 * (totals["on"] - totals["off"]) / totals["off"]
    print(
        f"TOTAL prose words   OFF={totals['off']}  ON={totals['on']}  ({delta:+.0f}%)"
    )


if __name__ == "__main__":
    main()
