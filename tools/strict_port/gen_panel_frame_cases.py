#!/usr/bin/env python3
"""Generate comparison cases for draw_panel_frame_lines by running the ORIGINAL bytes.

The four frame lines go through the host line routine (a logging stub on both sides) when the
host draws lines, else straight into a small screen at depth 4 (bytes) or 8 (words); other
depths draw nothing. Cases vary the row bytes (odd and negative, halved toward zero at depth 8),
the line extents (odd widths, empty lines) and the colour. test_panel_frame.gd replays the
cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_panel_frame_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/panel_frame_cases.json")
FRAME_LINES = 0xBA0A                              # runtime address (file 0xba2a)
WORLD, SCREEN, HOST_LINE = 0x27000, 0x28000, 0x30000
CALL_LOGS = [[HOST_LINE, 0x38004, 5]]


def case(name: str, depth: int, host_line: int = 0, row: int = 0x40, colour: int = 0x5A,
         extents: tuple[int, ...] = (2, 9, 1, 5, 0, 12, 3, 10, 6)) -> dict:
    top1, bottom1, top2, bottom2, left1, right1, left2, right2, y = extents
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(SCREEN, SCREEN + 0x2000, 4))
         + list(range(0x38000, 0x38400, 4))]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in [
        (0x1B5A0, 4, WORLD), (0x1B826, 2, depth), (WORLD + 0x9E, 2, host_line), (WORLD + 0x272, 4, HOST_LINE),
        (WORLD + 0x10, 2, row), (WORLD + 0x25C, 2, colour), (WORLD + 0x238, 2, top1), (WORLD + 0x23A, 2, bottom1),
        (WORLD + 0x23C, 2, top2), (WORLD + 0x23E, 2, bottom2), (WORLD + 0x240, 2, 7), (WORLD + 0x242, 2, left1),
        (WORLD + 0x244, 2, right1), (WORLD + 0x246, 2, left2), (WORLD + 0x248, 2, right2), (WORLD + 0x24A, 2, y),
        (WORLD + 0x24C, 4, SCREEN + 0x800), (WORLD + 0x250, 4, SCREEN + 0x810), (WORLD + 0x254, 4, SCREEN + 0x900),
        (WORLD + 0x258, 4, SCREEN + 0x980)]]
    return {"name": name, "routine": FRAME_LINES, "args": [], "writes": w}


CASES = [
    case("host lines, depth 8", 8, host_line=1),
    case("host lines, depth 1: nothing", 1, host_line=1),
    case("host lines, depth 4, other extents", 4, host_line=1, extents=(-5, 30, 0, 0, 7, 8, -2, 40, -1)),
    case("depth 4: byte colour (c << 4) | c", 4),
    case("depth 4: odd widths and colour 0x0f", 4, colour=0x0F, extents=(0, 3, 4, 4, 1, 8, 2, 9, 0)),
    case("depth 4: negative row bytes", 4, row=-0x30),
    case("depth 8: word colour (c << 8) | c", 8),
    case("depth 8: odd row bytes, halved", 8, row=0x41, colour=0x1234),
    case("depth 8: negative odd row bytes", 8, row=-0x41),
    case("depth 8: empty lines", 8, extents=(4, 4, 6, 6, 3, 3, 9, 10, 0)),
    case("depth 2: nothing", 2),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "draw_panel_frame_lines", "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
