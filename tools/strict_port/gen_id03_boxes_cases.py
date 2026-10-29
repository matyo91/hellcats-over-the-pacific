#!/usr/bin/env python3
"""Generate comparison cases for the fourth ID03 batch (the numbered bevel box, the panel's screen
addresses and storing the panel bitmaps as 'HEL2' resources) by running the ORIGINAL bytes.

The set-up is gen_id03_panel_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID02.bin behind its
slots, scripted panel-coordinate slots, panel colour and polygon stand-ins) with the Resource
Manager traps as logging stand-ins (GetResource and ResError answer scripted sequences; a case may
replace the call logs). Each case records the original's entry stack pointer ("a7").
test_id03_boxes.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_boxes_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_helpers_cases as helpers  # noqa: E402
import gen_id03_panel_cases as panel  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_boxes_cases.json")
A5, LOGS, DATA = helpers.A5, helpers.LOGS, helpers.DATA
N_BEFORE = len(panel.STUBS)
STUBS = panel.STUBS + [["trap", 0xA99B, [1], True, 0], ["trap", 0xA9A0, [2, 4], True, 4, {}, [0x11C00, 0, 0x11C40, 0x11C80]],
                       ["trap", 0xA9AD, [4], True, 0], ["trap", 0xA9AB, [4, 2, 4, 4], True, 0], ["trap", 0xA9AF, [], True, 2, {}, [0]],
                       ["trap", 0xA999, [2], True, 0], ["trap", 0xA9AA, [4], True, 0]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
ROUTINES = {"draw_numbered_bevel_box": 0x4110, "compute_panel_screen_addresses": 0x5860, "store_panel_bitmaps_as_resources": 0x5AB6}
L, W, case = helpers.L, helpers.W, helpers.case
SCENERY_H, SCENERY = 0x12A00, 0x12A40


def common() -> list[list[int]]:
    w = [x for x in panel.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_BEFORE)]
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]
    vals = [(A5 - 0x1378, 2, 0x50), (A5 - 0x1382, 4, 0x48000), (A5 - 0x13AE, 2, 2), (A5 - 0x13B2, 4, SCENERY_H), (SCENERY_H, 4, SCENERY),
            (A5 - 0x1002, 2, 9)]
    vals += [(A5 - h, 4, 0x11D00 + 0x10 * k) for k, h in enumerate((0x12B0, 0x11F6, 0x11DC, 0x11D4))]
    vals += [(A5 - 0xE0A + 4 * k, 4, 0x11E00 + 0x10 * k) for k in range(4)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def with_results(changes: dict) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for key, results in changes.items():
        logs[LOG_OF[key]][7:] = [results]
    return logs


def build() -> list[dict]:
    rect = [[DATA + 0x40, 4, (100 << 16) | 200], [DATA + 0x44, 4, (180 << 16) | 420]]
    out = []
    for label, n, mode, scale in (("12 in 8-bit", 12, 8, 640), ("7 in 1-bit", 7, 1, 640), ("305, small scale", 305, 4, 30)):
        c = case(f"numbered box {label}", "draw_numbered_bevel_box", [L(DATA + 0x40), W(n)], [DATA + 0x40, n],
                 rect + [[A5 - 0x137A, 2, mode], [A5 - 0x149E, 4, scale]])
        out.append(c)
    for mode in (1, 4, 8):
        out.append(case(f"panel addresses, depth {mode}", "compute_panel_screen_addresses", [], [], [[A5 - 0x137A, 2, mode]]))
    out.append(case("store panel bitmaps", "store_panel_bitmaps_as_resources", [], []))
    c = case("store panel bitmaps, an error", "store_panel_bitmaps_as_resources", [], [])
    c["call_logs"] = with_results({("trap", 0xA9AF): [0, 0xFF40, 0, 0], ("trap", 0xA9A0): [0, 0, 0, 0]})
    out.append(c)
    return out


def main() -> None:
    base = common()
    helpers.STUBS, helpers.ROUTINES = STUBS, ROUTINES
    out_logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
                for e in CALL_LOGS]
    out = {"memory_size": helpers.MEMORY_SIZE, "a5": A5, "stack_top": helpers.STACK_TOP, "stack_guard": list(helpers.STACK_GUARD),
           "common_writes": base, "call_logs": out_logs, "cases": []}
    for c in build():
        helpers.CALL_LOGS = c.get("call_logs", CALL_LOGS)
        changes, _ = helpers.run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                 "a7": helpers.STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if "call_logs" in c:
            entry["call_logs"] = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5],
                                   {str(i): n for i, n in e[6].items()}] + e[7:] for e in c["call_logs"]]
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
