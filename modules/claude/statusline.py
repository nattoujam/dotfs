#!/usr/bin/env python3
"""Claude Code status line.

Line 1: model + current directory
Line 2: context bar + %, then an overlaid 5h/1w rate-limit bar.

The rate-limit bar draws both windows on a single bar: the 1w (seven_day)
usage is the faint fill, the 5h (five_hour) usage is the strong fill drawn
on top. Both start at 0%, so where they overlap the 5h color wins.
"""
import json
import sys
from datetime import datetime

# --- truecolor ANSI helpers -------------------------------------------------
RESET = "\033[0m"


def fg(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"


GREEN = fg(80, 200, 120)
YELLOW = fg(220, 190, 60)
RED = fg(225, 90, 80)
DIM = fg(95, 95, 95)        # empty cells
FIVE_H = fg(255, 176, 0)    # 5h: strong amber
SEVEN_D = fg(120, 90, 25)   # 1w: faint amber
CYAN = fg(110, 200, 220)

BAR_WIDTH = 16


def clamp_pct(v):
    try:
        v = float(v)
    except (TypeError, ValueError):
        return 0.0
    return max(0.0, min(100.0, v))


def cells(pct):
    """How many filled cells for a 0-100 percentage."""
    return int(round(clamp_pct(pct) * BAR_WIDTH / 100.0))


def context_bar(pct):
    pct = clamp_pct(pct)
    filled = cells(pct)
    color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    bar = color + "▬" * filled + DIM + "▬" * (BAR_WIDTH - filled) + RESET
    return f"ctx ▕{bar}▏ {int(pct)}%"


def limit_bar(rate):
    """Overlaid 5h(on top)/1w(under) bar. `rate` is the rate_limits dict."""
    five = rate.get("five_hour") or {}
    seven = rate.get("seven_day") or {}

    has_five = "used_percentage" in five
    has_seven = "used_percentage" in seven

    five_cells = cells(five.get("used_percentage")) if has_five else 0
    seven_cells = cells(seven.get("used_percentage")) if has_seven else 0

    out = []
    for i in range(BAR_WIDTH):
        if i < five_cells:
            out.append(FIVE_H + "▬")     # 5h priority (overlap region)
        elif i < seven_cells:
            out.append(SEVEN_D + "▬")    # 1w only
        else:
            out.append(DIM + "▬")        # empty
    bar = "".join(out) + RESET

    five_txt = f"{int(round(clamp_pct(five['used_percentage'])))}%" if has_five else "--"
    seven_txt = f"{int(round(clamp_pct(seven['used_percentage'])))}%" if has_seven else "--"

    resets_at = five.get("resets_at")
    if isinstance(resets_at, (int, float)):
        reset_txt = datetime.fromtimestamp(resets_at).strftime("%H:%M")
    else:
        reset_txt = "--:--"

    return f"lim ▕{bar}▏ {five_txt}/{seven_txt} ({reset_txt})"


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        data = {}

    model = (data.get("model") or {}).get("display_name") or "?"
    cwd = (data.get("workspace") or {}).get("current_dir") or data.get("cwd") or ""
    dirname = cwd.rstrip("/").rsplit("/", 1)[-1] or cwd or "?"

    ctx = (data.get("context_window") or {}).get("used_percentage")

    print(f"{CYAN}{model}{RESET}  📁 {dirname}")

    line2 = context_bar(ctx)
    rate = data.get("rate_limits")
    if rate:
        line2 += "  " + limit_bar(rate)
    else:
        line2 += f"  lim {DIM}(待機中…){RESET}"
    print(line2)


if __name__ == "__main__":
    main()
