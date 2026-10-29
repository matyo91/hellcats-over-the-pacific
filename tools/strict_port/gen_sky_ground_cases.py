#!/usr/bin/env python3
"""Generate comparison cases for draw_sky_and_ground by running the ORIGINAL bytes.

Each case builds a real heap (gen_object_list_cases.Setup) so the row buffers are freed and
reallocated by the original heap routines when the view geometry changes. The span filler, the
depth-1 host routine (+0x27e) and the cursor hook (+0x2c2) are logging stubs on both sides (the
span filler logs the two buffer pointers it is handed by address). Cases cover depth 8 / 4 with
the panels drawn and undrawn, both horizon orders, the corner codes (0xf all ground, 0 all sky,
mixed), a cached geometry, a flat horizon and depth 1 on even / odd frames. Depth 1 is only
tested with a sloped horizon and mixed corners: otherwise the original hands it unset registers
and frame words. test_sky_ground.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_sky_ground_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import Setup  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/sky_ground_cases.json")
SKY = 0xB496                                      # runtime address (file 0xb4b6)
WORLD, EXTENTS, OLD_NEXT, OLD_ROWS = 0x27000, 0x27400, 0x27600, 0x27800
DEPTH1, FILLER, CURSOR = 0x30000, 0x30100, 0x30200
CALL_LOGS = [[DEPTH1, 0x38004, 9], [FILLER, 0x38404, 5, 0, 1, 1, 1], [CURSOR, 0x38804, 0]]
ROWS = 10


def case(name: str, depth: int = 8, panels: int = 1, edge: tuple[int, int, int, int] = (-40, -30, 50, 20),
         corners: int = 1, cached: bool = False, parity: int = 0, hide: int = 0, rows: int = ROWS) -> dict:
    s = Setup()
    for addr in list(range(WORLD, WORLD + 0x300, 4)) + list(range(EXTENTS, EXTENTS + 0x100, 4)) + list(range(0x38000, 0x38C00, 4)):
        s.w(addr, 4, 0)
    x0, y0, x1, y1 = edge
    for addr, size, value in [
            (0x1B5A0, 4, WORLD), (0x1B826, 2, depth), (0x20AE4, 2, panels), (0x25F48, 2, parity),
            (WORLD + 0x186, 2, 12), (WORLD + 0x188, 2, 5), (WORLD + 0x18A, 2, 5), (WORLD + 0x18C, 2, rows),
            (WORLD + 0x18E, 2, 0x11), (WORLD + 0x190, 2, 0x22), (WORLD + 0x196, 4, EXTENTS),
            (WORLD + 6, 4, 0x100000), (WORLD + 0x10, 2, 0x140), (WORLD + 0xDC, 4, 0x200000), (WORLD + 0xE0, 2, 0xA0),
            (WORLD + 0xE2, 2, 3), (WORLD + 0x27E, 4, DEPTH1), (WORLD + 0x2C2, 4, CURSOR), (0x20AC0, 4, FILLER),
            (0x20B2A, 2, 64), (0x20B2C, 2, 40), (0x1B828, 2, 80), (0x1B82A, 2, 0x80), (0x1DAA0, 2, 0x99),
            (0x1BDA0, 4, x0), (0x1BD9C, 4, y0), (0x1BD98, 4, x1), (0x1BD94, 4, y1), (0x1BD90, 4, corners),
            (0x20AD8, 4, 0), (0x20AD4, 4, 0)]:
        s.w(addr, size, value)
    for r in range(rows):
        s.w(EXTENTS + 4 * r, 2, 5 + r)
        s.w(EXTENTS + 4 * r + 2, 2, 100 - 2 * r)
    if cached:
        for k in range(5):
            s.w(0x25F34 + 4 * k, 4, s.emu.read(WORLD + 0x186 + 4 * k, 4))
        s.w(0x20AD8, 4, OLD_NEXT)
        s.w(0x20AD4, 4, OLD_ROWS)
    else:
        s.w(0x25F34, 4, 0)
    return {"name": name, "routine": SKY, "args": [hide], "writes": s.writes()}


def build() -> list[dict]:
    return [
        case("depth 8, panels drawn, new geometry: buffers allocated, sloped band"),
        case("depth 8, panels undrawn, horizon reversed, lower corners", panels=0, edge=(50, 25, -50, -35), corners=0xC),
        case("depth 4, cached geometry: no reallocation", depth=4, cached=True, corners=3),
        case("depth 8, all ground (corners 0xf)", corners=0xF, cached=True),
        case("depth 8, all sky (corners 0)", corners=0, cached=True, panels=0),
        case("depth 8, flat horizon", edge=(-60, -10, 60, -10), corners=2, cached=True),
        case("depth 8, steep edge past the rows", edge=(-10, -40, 10, 200), corners=4),
        case("depth 8, horizon crossing the row extents", edge=(-100, -40, 100, 40), corners=8, cached=True),
        case("depth 1, panels drawn, even frame, cursor hook", depth=1, hide=1),
        case("depth 1, odd frame: skipped", depth=1, parity=1, cached=True),
        case("depth 1, panels undrawn: nothing", depth=1, panels=0),
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
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "draw_sky_and_ground", "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
