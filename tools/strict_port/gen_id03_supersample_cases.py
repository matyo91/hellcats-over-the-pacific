#!/usr/bin/env python3
"""Generate comparison cases for begin_instrument_supersample, the spinning disc indicator and the
ring with status indicators (ID03 0x1538 / 0x35e / 0x514) by running the ORIGINAL bytes.

The set-up is gen_id03_boxes_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID02.bin behind its
slots, NewPtr handing out the bits and the port record) with SetClip, DisposeRgn, SetOrigin, GetClip
and PaintOval as logging stand-ins too; new_offscreen_bw_port runs for real on both sides. Each case records the
original's entry stack pointer ("a7"). test_id03_supersample.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_supersample_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_boxes_cases as boxes  # noqa: E402
import gen_id03_helpers_cases as helpers  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_supersample_cases.json")
A5, LOGS, DATA = helpers.A5, helpers.LOGS, helpers.DATA
N_BEFORE = len(boxes.STUBS)
STUBS = boxes.STUBS + [["trap", 0xA879, [4], True, 0], ["trap", 0xA8D9, [4], True, 0], ["trap", 0xA878, [2, 2], True, 0],
                      ["trap", 0xA87A, [4], True, 0], ["trap", 0xA8B8, [4], True, 0, {0: 2}]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
ROUTINES = {"begin_instrument_supersample": 0x1538, "draw_spinning_disc_indicator": 0x35E,
            "draw_ring_with_status_indicators": 0x514}
L, W, case = helpers.L, helpers.W, helpers.case
OUTS = DATA + 0x400


def common() -> list[list[int]]:
    w = [x for x in boxes.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_BEFORE)]
    return w + [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]


def build() -> list[dict]:
    out = []
    ptrs = [OUTS + 4 * k for k in range(9)]
    for label, mode, size, a, b, scale in (("1-bit", 1, 900, 40, 7, 640), ("1-bit, b kept", 1, 600, 3, 22, 1000),
                                           ("8-bit", 8, 900, 40, 7, 640), ("4-bit, odd scale", 4, 755, -5, 30, 0x12345)):
        writes = [[OUTS, 2, size], [OUTS + 4, 2, a], [OUTS + 8, 2, b], [A5 - 0x137A, 2, mode], [A5 - 0x149E, 4, scale]]
        out.append(case(f"supersample {label}", "begin_instrument_supersample", [L(p) for p in ptrs], ptrs, writes))
    for phase in range(5):
        out.append(case(f"spinning disc, phase {phase}", "draw_spinning_disc_indicator", [W(150), W(-60)], [150, -60],
                        [[A5 - 0x2114, 2, 300], [A5 - 0x2112, 2, phase]]))
    out.append(case("spinning disc, too small", "draw_spinning_disc_indicator", [W(0), W(0)], [0, 0],
                    [[A5 - 0x2114, 2, 20], [A5 - 0x2112, 2, 1]]))
    for flags in (0, 0x1F, 0x5, 0x12, 0xE0):
        out.append(case(f"ring, flags {flags:#x}", "draw_ring_with_status_indicators", [W(900), W(25), W(-200), W(400), W(flags)],
                        [900, 25, -200, 400, flags], [[A5 - 0x2114, 2, 300], [A5 - 0x2112, 2, 3]]))
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
