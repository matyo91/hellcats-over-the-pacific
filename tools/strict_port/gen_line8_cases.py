#!/usr/bin/env python3
"""Generate comparison cases for draw_line_depth8 and restore_line_depth8 by running the ORIGINAL
bytes. Lines in every octant (shallow and steep, both directions), horizontal, vertical,
diagonal and single-point lines, from odd and even columns, are drawn on a patterned 8-bit
screen with even and odd row bytes; the restore cases copy the same pixels back from a
patterned backup bitmap with its own row bytes. test_line8.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_line8_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/line8_cases.json")
ROUTINES = {0xD39C: "draw_line_depth8", 0xD8FA: "restore_line_depth8"}
SCREEN, BACKUP = 0x28000, 0x2C000
LINES = [((10, 10), (40, 20)), ((40, 20), (10, 10)), ((11, 30), (45, 5)), ((45, 5), (11, 30)),
         ((20, 2), (28, 35)), ((28, 35), (20, 2)), ((33, 3), (21, 36)), ((21, 36), (33, 3)),
         ((5, 15), (50, 15)), ((6, 15), (51, 15)), ((25, 4), (25, 30)), ((26, 30), (26, 4)),
         ((8, 8), (30, 30)), ((31, 8), (9, 30)), ((17, 17), (17, 17)), ((3, 3), (4, 4)), ((2, 9), (3, 30))]


def base() -> list[list[int]]:
    w = [[SCREEN + 4 * k, 4, (0x10203040 + 0x01010101 * k) & 0xFFFFFFFF] for k in range(0x800)]
    w += [[BACKUP + 4 * k, 4, (0x9A000000 + 0x00350771 * k) & 0xFFFFFFFF] for k in range(0x800)]
    return w


def build() -> list[dict]:
    out = []
    for (x0, y0), (x1, y1) in LINES:
        for row in (0x50, 0x51):
            out.append({"name": f"draw ({x0},{y0})-({x1},{y1}) row {row:#x}", "routine": 0xD39C,
                        "args": [x0, y0, x1, y1, 0x3C, SCREEN, row], "writes": base()})
            out.append({"name": f"restore ({x0},{y0})-({x1},{y1}) rows {row:#x} / 0x47", "routine": 0xD8FA,
                        "args": [x0, y0, x1, y1, SCREEN, row, BACKUP, 0x47], "writes": base()})
    out.append({"name": "draw: colour high bits ignored", "routine": 0xD39C, "args": [4, 4, 30, 12, 0x12345681, SCREEN, 0x50],
                "writes": base()})
    return out


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(len(out["cases"]), "cases;", sum(1 for c in out["cases"] if not c["changes"]), "with no change")


if __name__ == "__main__":
    main()
