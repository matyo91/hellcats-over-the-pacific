#!/usr/bin/env python3
"""Generate comparison cases for the smoke plume shapes by running the ORIGINAL bytes.

Covers plume_pre_render (runtime 0x11a70) with shape_free_plume and shape_trailing_plume. Same
method as gen_controller_misc_cases.py; the returned D0 of the shape routines (0) is compared.
test_plume.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_plume_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/plume_cases.json")
PRE_RENDER = 0x11A70             # runtime addresses (file - 0x20)
FREE = 0x11776
TRAILING = 0x11920
METHODS = {PRE_RENDER: "plume_pre_render", FREE: "shape_free_plume", TRAILING: "shape_trailing_plume"}
CTL = 0x24000
OBJ = 0x24200
VERTS = 0x24300                  # 8 vertices (12 bytes)
FRAME = 1000


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(CTL, CTL + 0xC0), (OBJ, OBJ + 0x80), (VERTS, VERTS + 0x60)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    for addr, size, value in [(CTL, 4, OBJ), (OBJ + 0x44, 4, VERTS), (0x1B838, 4, FRAME), (0x1D80E, 2, 0x0E00),
                              (OBJ + 0x40, 4, FRAME - 100), (CTL + 0x34, 2, 600), (CTL + 0x38, 4, FRAME - 1)]:
        w.append([addr, size, value])
    for v in range(8):
        w += [[VERTS + 12 * v, 4, 0x1111 * (v + 1)], [VERTS + 12 * v + 4, 4, 0x77], [VERTS + 12 * v + 8, 4, 0x2222 * (v + 1)]]
    for i in range(8):
        w += [[CTL + 0x40 + 12 * i, 4, (5000 + 300 * i) & 0xFFFFFFFF], [CTL + 0x44 + 12 * i, 4, (2000 - 40 * i) & 0xFFFFFFFF],
              [CTL + 0x48 + 12 * i, 4, (-7000 + 90 * i) & 0xFFFFFFFF]]
    return w


def case(name: str, routine: int, extra: list[tuple[int, int, int]] = (), with_d0: bool = False) -> dict:
    return {"name": name, "routine": routine, "args": [CTL], "with_d0": with_d0, "writes": base() + [list(e) for e in extra]}


CASES = [
    case("free plume: old, random heights", PRE_RENDER),
    case("free plume: faces the camera, lays out a width of 900", PRE_RENDER, [(CTL + 0x32, 2, 1), (CTL + 0x36, 2, 900)]),
    case("free plume: negative odd width -301", PRE_RENDER, [(CTL + 0x36, 2, (-301) & 0xFFFF)]),
    case("free plume: young (age 12) scales the heights", PRE_RENDER, [(OBJ + 0x40, 4, FRAME - 12)]),
    case("free plume: appears later (age -20, abs)", PRE_RENDER, [(OBJ + 0x40, 4, FRAME + 20)]),
    case("free plume: age 44 is scaled", PRE_RENDER, [(OBJ + 0x40, 4, FRAME - 44)]),
    case("free plume: age 45 is not scaled", PRE_RENDER, [(OBJ + 0x40, 4, FRAME - 45)]),
    case("free plume: negative height", PRE_RENDER, [(CTL + 0x34, 2, (-333) & 0xFFFF), (OBJ + 0x40, 4, FRAME - 7)]),
    case("free plume: already shaped this frame", PRE_RENDER, [(CTL + 0x38, 4, FRAME), (CTL + 0x36, 2, 64)]),
    case("free plume: age wraps the word (65536 + 10)", PRE_RENDER, [(OBJ + 0x40, 4, FRAME - 0x1000A)]),
    case("trailing plume: newest point 0", PRE_RENDER, [(CTL + 0x3C, 4, 0x25000), (CTL + 0xA0, 2, 0)]),
    case("trailing plume: newest point 6 (wraps)", PRE_RENDER, [(CTL + 0x3C, 4, 0x25000), (CTL + 0xA0, 2, 6)]),
    case("trailing plume: other rng (cursor 0x26050)", PRE_RENDER, [(CTL + 0x3C, 4, 0x25000), (CTL + 0xA0, 2, 3), (0x26008, 4, 0x26050)]),
    case("shape_free_plume directly (returns 0)", FREE, [(CTL + 0x36, 2, 40)], True),
    case("shape_trailing_plume directly (returns 0)", TRAILING, [(CTL + 0xA0, 2, 7)], True),
]


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], c["args"], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "cases": []}
    for c in CASES:
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        entry = {"name": c["name"], "routine": c["routine"], "args": c["args"], "zero": zero, "writes": writes,
                 "changes": changes}
        if c["routine"] != PRE_RENDER:
            entry["method"] = METHODS[c["routine"]]
        if c["with_d0"]:
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
