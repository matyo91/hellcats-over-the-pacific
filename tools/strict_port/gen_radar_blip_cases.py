#!/usr/bin/env python3
"""Generate comparison cases for the radar blip routines (erase / draw for 8-bit, 4-bit and 1-bit
screens, including the depth-8 draw entry 0x17810 inside erase_radar_blip_depth8) by running the
ORIGINAL bytes on a fake frame and saved panel (the binary image's own bytes, the same on both
sides). The 1-bit host rectangle call (+0x276) is logged. test_radar_blips.gd replays the cases.

Usage: python3 tools/strict_port/gen_radar_blip_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/radar_blip_cases.json")
ERASE8, DRAW8, ERASE4, DRAW4, ERASE_BW, DRAW_BW = 0x17760, 0x177F0, 0x17848, 0x17928, 0x17A14, 0x17A40
METHODS = {ERASE8: "erase_radar_blip_depth8", DRAW8: "draw_radar_blip_depth8", ERASE4: "erase_radar_blip_depth4",
           DRAW4: "draw_radar_blip_depth4", ERASE_BW: "erase_radar_blip_bw", DRAW_BW: "draw_radar_blip_bw"}
RECT = 0x3F400
CALL_LOGS = [[RECT, 0x3F500, 4]]
WORLD = 0x23000
FRAME = 0x28000                  # frame buffer (row bytes 64)
PANEL = 0x2C000                  # saved panel copy (row bytes 48) at host +0xdc - panel_back_offset


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in range(WORLD, WORLD + 0x300, 4)]
    for addr, size, value in [(0x1B5A0, 4, WORLD), (WORLD + 6, 4, FRAME), (WORLD + 0x10, 2, 64), (WORLD + 0xDC, 4, PANEL + 0x100),
                              (0x1BD7C, 4, 0x100), (WORLD + 0xE0, 2, 48), (WORLD + 0x1E6, 2, 0x12A7), (WORLD + 0x276, 4, RECT),
                              (0x3F4FC, 4, 0), (0x3F500, 4, 0)]:
        w.append([addr, size, value])
    return w


def case(name: str, routine: int, x: int, y: int) -> dict:
    return {"name": name, "routine": routine, "args": [x & 0xFFFFFFFF, y & 0xFFFFFFFF], "writes": base()}


CASES = [
    case("erase 8-bit blip", ERASE8, 20, 10),
    case("draw 8-bit blip", DRAW8, 20, 10),
    case("erase 4-bit blip, even pixel", ERASE4, 20, 10),
    case("erase 4-bit blip, odd pixel", ERASE4, 21, 10),
    case("draw 4-bit blip, even pixel", DRAW4, 30, 20),
    case("draw 4-bit blip, odd pixel", DRAW4, 31, 20),
    case("draw 4-bit blip, negative odd x", DRAW4, -3, 20),
    case("erase 1-bit blip (host rectangle)", ERASE_BW, 7, 9),
    case("draw 1-bit blip (host rectangle)", DRAW_BW, -2, 300),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
