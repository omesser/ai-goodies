"""Compute probability-weighted expected value. Stdlib only.

Usage: python3 ev.py positions.json   (or pipe JSON to stdin)

Input JSON: list of positions:
[{"ticker": "AAPL", "shares": 100, "cost_basis": 175.0, "price": 213.5,
  "stop_loss": 165.0,           # optional: bear return floored at stop
  "scenarios": [
    {"name": "bull", "prob": 0.25, "target": 245.0},
    {"name": "base", "prob": 0.50, "target": 220.0},
    {"name": "bear", "prob": 0.25, "target": 185.0}]}]

Prints per-position and portfolio EV. Probabilities must sum to 1.0 (±0.001).
"""
import json
import sys


def analyze(pos):
    price, shares = pos["price"], pos["shares"]
    total_p = sum(s["prob"] for s in pos["scenarios"])
    assert abs(total_p - 1.0) < 1e-3, f'{pos["ticker"]}: probabilities sum to {total_p}, not 1.0'

    value = price * shares
    scenarios = []
    for s in pos["scenarios"]:
        target = s["target"]
        # stop-loss floors the downside: you exit at the stop, not the target
        stop = pos.get("stop_loss")
        effective = max(target, stop) if stop is not None and target < price else target
        ret = (effective - price) / price
        scenarios.append({**s, "effective_target": effective, "return_pct": round(ret * 100, 1)})

    ev_return = sum(s["prob"] * (s["effective_target"] - price) / price for s in scenarios)
    return {
        "ticker": pos["ticker"],
        "price": price,
        "position_value": round(value, 2),
        "scenarios": scenarios,
        "expected_return_pct": round(ev_return * 100, 2),
        "expected_value_change": round(ev_return * value, 2),
        "expected_value": round(value * (1 + ev_return), 2),
    }


def main(data):
    results = [analyze(p) for p in data]
    total = sum(r["position_value"] for r in results)
    ev_change = sum(r["expected_value_change"] for r in results)
    print(json.dumps({
        "positions": results,
        "portfolio": {
            "total_value": round(total, 2),
            "expected_change": round(ev_change, 2),
            "expected_return_pct": round(ev_change / total * 100, 2) if total else None,
        },
    }, indent=1))


def _self_check():
    r = analyze({"ticker": "T", "shares": 10, "price": 100.0, "stop_loss": 90.0,
                 "scenarios": [{"name": "bull", "prob": 0.3, "target": 120.0},
                               {"name": "base", "prob": 0.5, "target": 100.0},
                               {"name": "bear", "prob": 0.2, "target": 80.0}]})
    # bear floored at stop 90: EV = .3*20% + .5*0% + .2*(-10%) = 4%
    assert r["expected_return_pct"] == 4.0, r
    assert r["expected_value"] == 1040.0, r


if __name__ == "__main__":
    _self_check()
    raw = open(sys.argv[1]).read() if len(sys.argv) > 1 else sys.stdin.read()
    main(json.loads(raw))
