#!/usr/bin/env python3
"""Generate comparison cases for the bullet dot routines by running the ORIGINAL bytes.

Covers plot_dot_depth8 / erase_dots_depth8, plot_dot_depth4 / erase_dots_depth4 and plot_dot_bw
on a small fake screen (host +6 base, +0x10 row bytes). plot_dot_bw fills its polygon through
host +0x7c, which is logged on both sides together with the 4 points it is given (8 longs read
through the polygon pointer). test_dots.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_dot_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/dot_cases.json")
ERASE8, PLOT8, ERASE4, PLOT4, PLOT_BW = 0x15E9E, 0x15F1E, 0x15F98, 0x16108, 0x16210
METHODS = {ERASE8: "erase_dots_depth8", PLOT8: "plot_dot_depth8", ERASE4: "erase_dots_depth4",
           PLOT4: "plot_dot_depth4", PLOT_BW: "plot_dot_bw"}
FILL_POLY = 0x3F400
CALL_LOGS = [[FILL_POLY, 0x3F500, 4, 3, 8]]
WORLD = 0x23000
SCREEN = 0x28000                 # 64 bytes per row; its "pixels" are the binary image's own bytes
ROW = 64
RECORDS = 0x26288
REC = RECORDS + 14 * 2           # the record a plot call fills


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(WORLD, WORLD + 0x100), (RECORDS, RECORDS + 14 * 32)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    w += [[0x3F4FC, 4, 0], [0x3F500, 4, 0]]
    for addr, size, value in [(0x1B5A0, 4, WORLD), (WORLD + 6, 4, SCREEN), (WORLD + 0x10, 2, ROW), (WORLD + 0x7C, 4, FILL_POLY),
                              (0x20B2A, 2, 64), (0x20B2C, 2, 32), (0x1DA88, 2, 0xFFA7), (0x1DA8C, 2, 0), (0x1C1BE, 2, 5)]:
        w.append([addr, size, value])
    return w


def record(i: int, pixel: int, phase: int, size: int, colour: int, saved: tuple[int, int, int, int]) -> list[tuple[int, int, int]]:
    r = RECORDS + 14 * i
    return [(r, 4, pixel), (r + 4, 2, phase), (r + 6, 2, size), (r + 8, 1, colour),
            (r + 9, 1, saved[0]), (r + 10, 1, saved[1]), (r + 11, 1, saved[2]), (r + 12, 1, saved[3])]


def paint(pixel: int, values: tuple[int, int, int, int]) -> list[tuple[int, int, int]]:
    """Screen bytes at the dot: top-left, top-right, bottom-left, bottom-right."""
    return [(pixel, 1, values[0]), (pixel + 1, 1, values[1]), (pixel + ROW, 1, values[2]), (pixel + ROW + 1, 1, values[3])]


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": base() + [list(e) for e in extra]}


P1, P2, P3 = SCREEN + 5 * ROW + 7, SCREEN + 20 * ROW + 30, SCREEN + 40 * ROW + 50
CASES = []
for size in (1, 2, 3, 4):
    CASES.append(case(f"plot 8-bit dot size {size}", PLOT8, [REC, 0xFFFFFFC0 + 10, 0xFFFFFFF0, size]))
CASES += [
    case("plot 8-bit dot at negative screen x", PLOT8, [REC, 0xFFFFFF90, 3, 2]),
    case("erase 8-bit dots: matching and overdrawn pixels", ERASE8, [],
         [(0x1DA8C, 2, 3)] + record(0, P1, 0, 4, 0xA7, (1, 2, 3, 4)) + paint(P1, (0xA7, 0xA7, 0x11, 0xA7))
         + record(1, P2, 0, 2, 0xA7, (5, 6, 7, 8)) + paint(P2, (0xA7, 0xA7, 0xA7, 0xA7))
         + record(2, P3, 0, 1, 0x33, (9, 10, 11, 12)) + paint(P3, (0x34, 0x33, 0x33, 0x33))),
    case("erase 8-bit dots: none", ERASE8, []),
]
for size in (1, 2, 3, 4):
    CASES.append(case(f"plot 4-bit dot, even pixel, size {size}", PLOT4, [REC, 0xFFFFFFC0 + 10, 4, size]))
    CASES.append(case(f"plot 4-bit dot, odd pixel, size {size}", PLOT4, [REC, 0xFFFFFFC0 + 11, 4, size]))
CASES += [
    case("plot 4-bit dot at negative odd x (phase -1)", PLOT4, [REC, 0xFFFFFFBD, 2, 4]),
    case("erase 4-bit dots: phase 0 and phase 1, partly overdrawn", ERASE4, [],
         [(0x1DA8C, 2, 4)] + record(0, P1, 0, 4, 0xA7, (0x12, 0x34, 0x56, 0x78)) + paint(P1, (0xA7, 0x99, 0x7A, 0x99))
         + record(1, P2, 1, 4, 0xA7, (0x12, 0x34, 0x56, 0x78)) + paint(P2, (0x97, 0xA9, 0x37, 0xA3))
         + record(2, P3, 1, 2, 0xA7, (0xFE, 0xDC, 0xBA, 0x98)) + paint(P3, (0x87, 0xA0, 0x07, 0x00))
         + record(3, P1 + 3, 0, 3, 0x5A, (0xFF, 0xEE, 0xDD, 0xCC)) + paint(P1 + 3, (0x5A, 0x00, 0x00, 0x00))),
    case("plot 1-bit dot size 1 (polygon logged)", PLOT_BW, [REC, 100, 60, 1]),
    case("plot 1-bit dot size 4 (polygon logged)", PLOT_BW, [REC, 0xFFFFFFF6, 0xFFFFFFFE, 4]),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs, deref_index, deref_n in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs, di=deref_index, dn=deref_n: log_call(e, b, n, di, dn)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]],
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
