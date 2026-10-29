#!/usr/bin/env python3
"""Generate comparison cases for update_heading_tape, begin_offscreen_drawing and
end_offscreen_drawing by running the ORIGINAL bytes.

Every host routine they reach through host code pointers (port setup / switch / release, rect
fill, copy bits, cursor hook) and copy_rect_depth8 (reached through its code address) are
logging stubs on both sides; the rectangles passed by address are logged by value (copy bits
logs both its source and destination rect). Cases cover undrawn and drawn panels, depth 4 (host
copy, with and without the period overflow split) and depth 8 (marking-byte runs, wrapping at the
period), an unchanged position, a negative position raised by the period, and the cursor hook.
test_heading_tape.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_heading_tape_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/heading_tape_cases.json")
ROUTINES = {0xC18A: "update_heading_tape", 0xC0FE: "begin_offscreen_drawing", 0xC15E: "end_offscreen_drawing"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, MARKS, STRIP = 0x27000, 0x27400, 0x27600
SETUP, SWITCH, RELEASE, FILL, COPYBITS, CURSOR, COPY8 = 0x30000, 0x30100, 0x30200, 0x30300, 0x30400, 0x30500, 0xBF90
CALL_LOGS = [[SETUP, 0x38004, 4, 3, 2], [SWITCH, 0x38404, 1], [RELEASE, 0x38804, 1], [FILL, 0x38C04, 2, 0, 2],
             [COPYBITS, 0x39004, 5, 2, 2, 4, 2], [CURSOR, 0x39804, 0], [COPY8, 0x39C04, 6]]
PERIOD, WIDTH = 40, 16


def case(name: str, routine: str = "update_heading_tape", args: list[int] = (0,), depth: int = 8, panels: int = 0,
         heading: int = 0x1000, cached: int = 0, offset: int = 3, marks: list[int] = (), period: int = PERIOD,
         width: int = WIDTH) -> dict:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(MARKS, MARKS + 0x100, 4))
         + list(range(0x38000, 0x3A000, 4))]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in [
        (0x1B5A0, 4, WORLD), (0x1B826, 2, depth), (0x20AE4, 2, panels), (0x1D80E, 2, heading), (0x25FFE, 2, cached),
        (WORLD + 6, 4, 0x100000), (WORLD + 0x10, 2, 0x280), (WORLD + 0x16, 2, 0x200), (WORLD + 0x18, 2, 0x30),
        (WORLD + 0xDC, 4, 0x200000), (WORLD + 0xE0, 2, 0x140), (WORLD + 0xE2, 2, 0x150),
        (WORLD + 0x19A, 2, 0x160), (WORLD + 0x19C, 2, 0x48), (WORLD + 0x19E, 2, width), (WORLD + 0x1A0, 2, 9),
        (WORLD + 0x1A4, 2, period), (WORLD + 0x1A6, 2, 9), (WORLD + 0x1A8, 2, offset), (WORLD + 0x1AA, 2, 0x8000 | 0x60),
        (WORLD + 0x1B0, 4, STRIP), (WORLD + 0x1B8, 4, MARKS), (WORLD + 0x1BC, 4, 0x123400), (WORLD + 0x25C, 2, 0x77),
        (WORLD + 0x282, 4, SETUP), (WORLD + 0x286, 4, SWITCH), (WORLD + 0x28A, 4, RELEASE), (WORLD + 0x28E, 4, FILL),
        (WORLD + 0x29A, 4, COPYBITS), (WORLD + 0x2C2, 4, CURSOR), (0x38404 - 4, 4, 0xABCD0000)]]
    w += [[MARKS + k, 1, b] for k, b in enumerate(marks)]
    return {"name": name, "routine": BY_NAME[routine], "args": list(args), "writes": w}


def pattern(*on: int) -> list[int]:
    return [1 if k in on else 0 for k in range(PERIOD)]


def build() -> list[dict]:
    return [
        case("depth 4, panels undrawn, cursor hook: clear, copy", depth=4, args=[1]),
        case("depth 4, panels undrawn: copy split at the period", depth=4, heading=-0x3000),
        case("depth 4, panels drawn: direct copy", depth=4, panels=1, heading=0x2345),
        case("depth 4, panels drawn, split", depth=4, panels=1, heading=-0x3800, args=[1]),
        case("depth 4, unchanged, undrawn, cursor hook: clear, then release", depth=4, args=[1], heading=0, cached=35),
        case("depth 4, unchanged, panels drawn: nothing", depth=4, panels=1, heading=0, cached=35),
        case("depth 8, panels undrawn: clear, then the marked runs", heading=0x1000,
             marks=pattern(0, 1, 2, 9, 10, 14, 20, 21, 22, 23, 30, 39)),
        case("depth 8, panels drawn: runs wrap at the period", panels=1, heading=-0x3000, cached=30,
             marks=pattern(0, 1, 5, 6, 7, 26, 27, 28, 36, 37, 38, 39)),
        case("depth 8, nothing marked: no copies", panels=1, heading=0x777),
        case("depth 8, all marked", panels=1, heading=0x2000, marks=[1] * PERIOD),
        case("depth 8, unchanged: nothing", panels=1, heading=0, cached=35),
        case("depth 8, negative position raised twice", panels=1, heading=0x3F00, offset=-70, marks=pattern(*range(0, 40, 3))),
        case("depth 8, wide window over two periods", panels=1, heading=0x100, width=90, marks=pattern(3, 4, 17, 39)),
        case("begin offscreen drawing", "begin_offscreen_drawing", [0x28000, 0x140, 0x200000, 0x150]),
        case("end offscreen drawing", "end_offscreen_drawing", [0x28000, 0x12345678]),
    ]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for entry in CALL_LOGS:
        address, base, nargs = entry[:3]
        extra = entry[3:] + [-1, 0, -1, 0][len(entry) - 3:]
        emu.stubs[address] = lambda e, b=base, n=nargs, x=tuple(extra): log_call(e, b, n, *x)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
