#!/usr/bin/env python3
"""Generate comparison cases for the third ID03 batch (the bevelled frame, the split display box
and the arc scale ticks) by running the ORIGINAL bytes.

The set-up is gen_id03_glyph_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID02.bin behind its
slots, scripted panel-coordinate slots and sine / cosine routines) with the panel colour slots
($45a / $36a / $3a2 / $3e2) and the polygon and rect traps as logging stand-ins. Each case records
the original's entry stack pointer ("a7"). test_id03_panel.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_panel_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_glyph_cases as glyph  # noqa: E402
import gen_id03_helpers_cases as helpers  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_panel_cases.json")
A5, LOGS = helpers.A5, helpers.LOGS
N_BEFORE = len(glyph.STUBS)
STUBS = glyph.STUBS + [["jt", 0x45A, [2, 2, 2], False, 0, {}, [11, 22, 33, 44, 55, 66, 77]],
                       ["jt", 0x3A2, [2], False, 0], ["jt", 0x3E2, [], False, 0, {}, [0x11A00, 0x11A10, 0x11A20]],
                       ["trap", 0xA8CB, [], True, 4, {}, [0x11B00, 0x11B10, 0x11B20, 0x11B30]], ["trap", 0xA8CC, [], True, 0],
                       ["trap", 0xA8CA, [4, 4], True, 0], ["trap", 0xA8CD, [4], True, 0], ["trap", 0xA8C7, [4], True, 0],
                       ["trap", 0xA8A2, [4], True, 0, {0: 2}], ["trap", 0xA8A1, [4], True, 0, {0: 2}]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
ROUTINES = {"draw_bevelled_frame": 0x3F24, "draw_split_display_box": 0x4B32, "draw_arc_scale_ticks": 0x5158}
L, W, case = helpers.L, helpers.W, helpers.case


def common() -> list[list[int]]:
    w = [x for x in glyph.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_BEFORE)]
    return w + [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]


def build() -> list[dict]:
    out = []
    for name, ws in (("frame", (10, 20, 14, 24, 96, 66, 100, 70)), ("thin frame", (0, 0, 1, 1, 9, 9, 10, 10)),
                     ("negative", (-50, -30, -46, -26, 46, 26, 50, 30))):
        out.append(case(f"bevelled {name}", "draw_bevelled_frame", [W(v) for v in ws], list(ws)))
    for w, h, a, b in ((800, 300, 1200, 2400), (61, 33, -100, 0), (0, 0, 5, 5)):
        out.append(case(f"split box {w}x{h} at {a},{b}", "draw_split_display_box", [W(w), W(h), L(0xDEADBEEF), W(a), W(b)],
                        [w, h, 0xDEADBEEF, a, b]))
    for args in ((90, 3, 25, 200, 300, 1), (90, 3, 25, 200, 300, 0), (40, 6, 61, -10, 0, 1), (500, 1, 10, 0, 0, 0)):
        out.append(case(f"arc ticks {args}", "draw_arc_scale_ticks", [W(v) for v in args], list(args)))
    return out


def main() -> None:
    base = common()
    helpers.STUBS, helpers.CALL_LOGS, helpers.ROUTINES = STUBS, CALL_LOGS, ROUTINES
    logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in CALL_LOGS]
    out = {"memory_size": helpers.MEMORY_SIZE, "a5": A5, "stack_top": helpers.STACK_TOP, "stack_guard": list(helpers.STACK_GUARD),
           "common_writes": base, "call_logs": logs, "cases": []}
    for c in build():
        changes, _ = helpers.run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                             "a7": helpers.STACK_TOP - sum(size for size, _ in c["stack"]) - 4})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
