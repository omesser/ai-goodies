# /// script
# requires-python = ">=3.11"
# dependencies = ["yfinance"]
# ///
"""Fetch live market data for EV analysis. Run: uv run fetch_data.py AAPL NVDA
Prints JSON. Every field independently degrades to null on failure — never a fake value.
"""

import json
import sys
from datetime import datetime, timezone

import yfinance as yf


def near_the_money_options(tk, price):
    """Put/call volume + OI for strikes within ±10% of spot on the nearest expiry.
    Excludes lottery strikes by construction (the ±10% band)."""
    exp = tk.options[0]
    chain = tk.option_chain(exp)
    lo, hi = price * 0.9, price * 1.1
    calls = chain.calls[(chain.calls.strike >= lo) & (chain.calls.strike <= hi)]
    puts = chain.puts[(chain.puts.strike >= lo) & (chain.puts.strike <= hi)]
    call_vol = int(calls.volume.fillna(0).sum())
    put_vol = int(puts.volume.fillna(0).sum())
    return {
        "expiry": exp,
        "call_volume": call_vol,
        "put_volume": put_vol,
        "call_oi": int(calls.openInterest.fillna(0).sum()),
        "put_oi": int(puts.openInterest.fillna(0).sum()),
        "put_call_volume_ratio": round(put_vol / call_vol, 2) if call_vol else None,
    }


def earnings_history(tk):
    """Last 8 quarters of earnings surprises."""
    df = tk.earnings_history
    if df is None or df.empty:
        return None
    df = df.tail(8)
    beats = int((df.epsActual > df.epsEstimate).sum())
    total = int(df.epsActual.notna().sum())
    return {
        "quarters": total,
        "beats": beats,
        "beat_rate": round(beats / total, 2) if total else None,
        "avg_surprise_pct": round(float(df.surprisePercent.mean()) * 100, 1)
        if df.surprisePercent.notna().any()
        else None,
    }


def short_interest(info):
    si = info.get("shortPercentOfFloat")
    return {
        "short_pct_of_float": round(si * 100, 1) if si is not None else None,
        "days_to_cover": info.get("shortRatio"),
    }


def fetch(ticker):
    out = {"ticker": ticker}
    tk = yf.Ticker(ticker)
    try:
        info = tk.info
        out["price"] = info.get("currentPrice") or info.get("regularMarketPrice")
        out["fifty_two_week"] = {
            "low": info.get("fiftyTwoWeekLow"),
            "high": info.get("fiftyTwoWeekHigh"),
        }
        out["beta"] = info.get("beta")
        ts = info.get("earningsTimestamp")
        out["next_earnings"] = (
            datetime.fromtimestamp(ts, tz=timezone.utc).date().isoformat()
            if ts
            else None
        )
    except Exception as e:
        out["price"] = None
        out["error_info"] = str(e)
        return out  # no price -> nothing downstream is meaningful

    for key, fn in [
        ("options", lambda: near_the_money_options(tk, out["price"])),
        ("earnings", lambda: earnings_history(tk)),
        ("short_interest", lambda: short_interest(info)),
    ]:
        try:
            out[key] = fn()
        except Exception as e:
            out[key] = None
            out[f"error_{key}"] = str(e)
    return out


if __name__ == "__main__":
    tickers = sys.argv[1:]
    if not tickers:
        sys.exit("usage: uv run fetch_data.py TICKER [TICKER ...]")
    print(json.dumps([fetch(t.upper()) for t in tickers], indent=1, default=str))
