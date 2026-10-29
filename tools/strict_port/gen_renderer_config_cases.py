#!/usr/bin/env python3
"""Generate comparison cases for configure_renderer_for_display by running the ORIGINAL bytes.

The host geometry (rows, width, origin) and display (depth word +0xe, multi-screen flag +0xb4)
vary: switching to depth 8, 4 or 1 installs that depth's renderer hooks and rebuilds the colour
state on a real heap (gen_object_list_cases.Setup), an unchanged configuration only refreshes the
geometry, and odd / negative sizes exercise the rounding. The mission is already built
(mission_child0 set), so init_mission_object_tables (tested on its own) is not re-run;
mission_child4's faces 1..4 carry the depth-1 flag. update_view_clip_bounds runs as ported.
test_renderer_config.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_renderer_config_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import HEAP_BLOCK, Setup  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/renderer_config_cases.json")
ROUTINE = 0x6FD6                                    # runtime address (file 0x6ff6)
WORLD, COLOURS, CHILD4, FACES = 0x27000, 0x27400, 0x27600, 0x27700
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def case(name: str, depth: int, old_depth: int, rows: int = 200, width: int = 320, multi: int = 0, old_multi: int = 0) -> dict:
    s = Setup()
    s.w(HEAP_BLOCK, 4, 0x1C00)
    for a in range(WORLD, 0x27900, 4):
        s.w(a, 4, 0)
    for addr, size, v in [(0x1B5A0, 4, WORLD), (WORLD + 0x18, 2, rows), (WORLD + 0x16, 2, width), (WORLD + 0x12, 2, 7),
                          (WORLD + 0x14, 2, 9), (WORLD + 0xE, 2, depth), (WORLD + 0xB4, 2, multi), (WORLD + 0x34, 4, COLOURS),
                          (WORLD + 0x38, 2, 1), (WORLD + 0x276, 4, 0x33333), (COLOURS + 0x1A0, 2, 0x4141), (COLOURS + 0x10, 2, 0x0E0E),
                          (0x1B826, 2, old_depth), (0x1B824, 2, old_multi), (0x1BDB4, 4, 0x27800), (0x1BDA4, 4, CHILD4),
                          (CHILD4 + 0x48, 4, FACES), (0x1D858, 2, 2), (0x1DA70, 4, 0), (0x1DA74, 4, 0), (0x1DA78, 4, 0),
                          (0x1DA7C, 4, 0), (0x1B778, 4, 0), (0x1B77C, 4, 0), (0x1B780, 4, 0)]:
        s.w(addr, size, v)
    for k in range(5):
        s.w(FACES + 0x20 * k + 0x13, 1, 0x55 if k % 2 else 0xAA)
    for n in range(1, 4):
        s.w(WORLD + 0x16 * n + 0x1E, 4, COLOURS + 0x100 + 0x10 * n)
    return {"name": name, "routine": ROUTINE, "args": [], "writes": s.writes()}


CASES = [
    case("switch to depth 8", 8, 4),
    case("switch to depth 4, multi-screen", 4, 8, multi=1),
    case("switch to depth 1", 1, 8),
    case("multi-screen flag changed at depth 8", 8, 8, multi=1, old_multi=0),
    case("unchanged: geometry only", 8, 8),
    case("odd sizes", 8, 4, rows=201, width=321),
    case("negative width / rows (rounding toward zero)", 4, 4, rows=-7, width=-9),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], [], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {}, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "configure_renderer_for_display", "args": [],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
