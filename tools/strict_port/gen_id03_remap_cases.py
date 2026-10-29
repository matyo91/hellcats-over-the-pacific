#!/usr/bin/env python3
"""Generate comparison cases for remap_cached_panel_colours (ID03 0x6c1c) by running the ORIGINAL
bytes.

The set-up is gen_id03_gauges_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID01 and ID02 behind
their slots, the panel colour slot $45a answering a scripted sequence) with JT $482 a logging
stand-in and a cached scenery record, a panel port and two small bitmaps (the panel's and the gyro
card's) seeded. Each case records the original's entry stack pointer ("a7"): the inverse map lives
in its frame. test_id03_remap.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_remap_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_gauges_cases as gauges  # noqa: E402
import gen_id03_helpers_cases as helpers  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_remap_cases.json")
A5, LOGS = helpers.A5, helpers.LOGS
N_BEFORE = len(gauges.STUBS)
STUBS = gauges.STUBS + [["jt", 0x482, [], False, 0]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
ROUTINES = {"remap_cached_panel_colours": 0x6C1C, "remap_panel_colours_identity": 0x71A2}
L, case = helpers.L, helpers.case
SCENERY_H, SCENERY, PANEL, PANEL_H, PANEL_BITS, GYRO_H, GYRO_BITS = 0x12A00, 0x12A40, 0x11600, 0x13A00, 0x13A40, 0x13B00, 0x13B40
MAP, TABLE = 0x13C00, 0x13E00


def common() -> list[list[int]]:
    w = [x for x in gauges.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_BEFORE)]
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]
    w += [[a, 4, 0] for a in range(0x13A00, 0x14000, 4)]
    rec = SCENERY + 0x160 * 2
    vals = [(A5 - 0x13AE, 2, 2), (A5 - 0x13B2, 4, SCENERY_H), (SCENERY_H, 4, SCENERY), (rec, 2, 4), (rec + 2, 2, 0x50), (rec + 4, 2, 0x60),
            (rec + 6, 2, 0x200), (rec + 8, 2, 0x10), (rec + 0xA, 2, 0x8006), (A5 - 0x137A, 2, 4), (A5 - 0x137E, 2, 0x50),
            (A5 - 0x137C, 2, 0x60), (A5 - 0x1372, 2, 0x200), (A5 - 0x1370, 2, 0x10), (A5 - 0x1496, 4, PANEL),
            (PANEL + 0x10, 4, (2 << 16) | 4), (PANEL + 0x14, 4, (5 << 16) | 14), (A5 - 0x12B0, 4, PANEL_H), (PANEL_H, 4, PANEL_BITS),
            (A5 - 0x11DC, 4, GYRO_H), (GYRO_H, 4, GYRO_BITS), (A5 - 0x11DE, 2, 0x8004), (A5 - 0x11E2, 2, 2), (A5 - 0x11E4, 2, 6),
            (A5 - 0x1354, 4, TABLE)]
    vals += [(PANEL_BITS + k, 1, (k * 37 + 5) & 0xFF) for k in range(0x30)] + [(GYRO_BITS + k, 1, (k * 53 + 9) & 0xFF) for k in range(0x10)]
    vals += [(MAP + 2 * k, 2, (k * 7) % 300 - 20) for k in range(0x100)] + [(TABLE + 2 * k, 2, (k * 11 + 3) & 0xFFF) for k in range(0x100)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def build() -> list[dict]:
    rec = SCENERY + 0x160 * 2
    args = [L(MAP), L(TABLE)]
    return [case("4-bit panel", "remap_cached_panel_colours", args, [MAP, TABLE]),
            case("8-bit panel", "remap_cached_panel_colours", args, [MAP, TABLE], [[rec, 2, 8], [A5 - 0x137A, 2, 8]]),
            case("2-bit panel (tail only)", "remap_cached_panel_colours", args, [MAP, TABLE], [[rec, 2, 2], [A5 - 0x137A, 2, 2]]),
            case("1-bit panel", "remap_cached_panel_colours", args, [MAP, TABLE], [[rec, 2, 1], [A5 - 0x137A, 2, 1]]),
            case("other geometry", "remap_cached_panel_colours", args, [MAP, TABLE], [[A5 - 0x1372, 2, 0x280]]),
            case("no scenery", "remap_cached_panel_colours", args, [MAP, TABLE], [[A5 - 0x13AE, 2, -1]]),
            case("identity, 4-bit", "remap_panel_colours_identity", [], []),
            case("identity, 8-bit", "remap_panel_colours_identity", [], [], [[rec, 2, 8], [A5 - 0x137A, 2, 8]])]


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
