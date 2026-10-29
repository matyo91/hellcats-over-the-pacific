#!/usr/bin/env python3
"""Generate comparison cases for the shadow, turret and bullet pre-render hooks by running the
ORIGINAL bytes (definition record +0xe hooks 0x18a14 / 0x19374 / 0x15e42). Same method as
gen_plume_cases.py; the returned D0 (0 or 4) is compared. test_pre_render.gd replays the cases.

Usage: python3 tools/strict_port/gen_pre_render_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/pre_render_cases.json")
SHADOW, TURRET, BULLET = 0x18A14, 0x19374, 0x15E42
WORLD = 0x23000
CTL = 0x24000                    # the hook's controller
OBJ = 0x24100                    # its object
OWNER = 0x24200                  # shadow owner object
OWNER_CTL = 0x24300
OWNER_DEF = 0x24400
PARENT = 0x24500                 # shadow object's parent (+0x28 scene entries)
SCENE = 0x24600
TEMPLATES = 0x25000              # host +0x8c base; the scene entry offset leads to the vertices
VERTS = 0x24800
FACE = 0x24900
INDEX = 0x24A00
MATRIX_VERTS = 0x24B00


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(WORLD, WORLD + 0x100), (CTL, CTL + 0x80), (OBJ, OBJ + 0x80), (OWNER, OWNER + 0x40),
                       (OWNER_CTL, OWNER_CTL + 0x40), (OWNER_DEF, OWNER_DEF + 0x10), (PARENT, PARENT + 0x40),
                       (SCENE, SCENE + 0x80), (TEMPLATES, TEMPLATES + 0x200), (VERTS, VERTS + 0x80),
                       (FACE, FACE + 0x20), (INDEX, INDEX + 0x20), (MATRIX_VERTS, MATRIX_VERTS + 0x20)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    w += [[0x1B5A0, 4, WORLD], [WORLD + 0x8C, 4, TEMPLATES], [CTL, 4, OBJ], [0x265D0, 2, 0]]
    return w


def shadow(type_word: int, bank: int, shift: int = 0, dead: bool = False) -> list[tuple[int, int, int]]:
    w = [(CTL + 0x32, 4, OWNER), (OWNER + 8, 4, OWNER_CTL), (OWNER_CTL + 4, 4, OWNER_DEF), (OWNER_DEF, 2, type_word),
         (OWNER_CTL + 0x24, 2, bank & 0xFFFF), (OBJ + 0x24, 4, PARENT), (PARENT + 0x28, 4, SCENE), (OBJ + 1, 1, 2),
         (SCENE + 0x2E + 2 * 0x18, 4, 0x40), (OBJ + 0x44, 4, VERTS), (OBJ + 0x48, 4, FACE), (OBJ + 0x34, 2, shift),
         (FACE + 0x14, 2, 5), (FACE + 0x18, 4, INDEX)]
    if dead:
        w.append((OWNER + 7, 1, 2))
    for i, vi in enumerate([0, 3, 1, 4, 2]):
        w.append((INDEX + 2 * i, 2, vi))
    for vi, x in enumerate([30, -120, 900, -2000, 50]):
        w.append((TEMPLATES + 0x40 + 0x22 + 12 * vi, 4, x & 0xFFFFFFFF))
        w.append((VERTS + 12 * vi, 4, 0x5555))
    return w


def case(name: str, routine: int, extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": [CTL], "writes": base() + [list(e) for e in extra]}


CASES = [
    case("shadow: dead owner -> 4", SHADOW, shadow(1, 0, dead=True)),
    case("shadow: ship owner (type 0x17) unchanged", SHADOW, shadow(0x17, 0)),
    case("shadow: aircraft level (cos 1)", SHADOW, shadow(1, 0)),
    case("shadow: aircraft banked 0x0c00", SHADOW, shadow(2, 0x0C00)),
    case("shadow: aircraft on its side (cos ~ 0, clamped)", SHADOW, shadow(4, 0x1000)),
    case("shadow: inverted (negative cos, abs)", SHADOW, shadow(3, 0x2600)),
    case("shadow: shifted shape (shift 2)", SHADOW, shadow(1, 0x0800, 2)),
    case("turret: aimed and idle shows its aim", TURRET, [(CTL + 0x36, 4, 1), (CTL + 0x4E, 2, 0x5123)]),
    case("turret: firing keeps its heading", TURRET, [(CTL + 0x36, 4, 1), (CTL + 0x46, 2, 3), (CTL + 0x4E, 2, 0x5123)]),
    case("turret: not aimed", TURRET, [(CTL + 0x4E, 2, 0x5123)]),
    case("bullet: listed, phase 0 -> 8", BULLET, [(0x265D0, 2, 3)]),
    case("bullet: phase 2 turns its vertices first", BULLET,
         [(CTL + 0x3A, 2, 2), (OBJ + 0x44, 4, MATRIX_VERTS), (CTL + 0x40, 2, 0x1000), (CTL + 0x48, 2, 0x1000), (CTL + 0x50, 2, 0x1000),
          (CTL + 0x42, 2, 0x0800), (MATRIX_VERTS + 2, 2, 100), (MATRIX_VERTS + 6, 2, 0xFFCE), (MATRIX_VERTS + 0xA, 2, 7),
          (MATRIX_VERTS + 0xE, 2, 40), (MATRIX_VERTS + 0x12, 2, 50), (MATRIX_VERTS + 0x16, 2, 0xFFFA)]),
    case("bullet: phase 9 only listed", BULLET, [(CTL + 0x3A, 2, 9), (0x265D0, 2, 29)]),
    case("bullet: list full (30)", BULLET, [(0x265D0, 2, 30)]),
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "args": c["args"], "zero": zero,
                             "writes": writes, "changes": changes, "d0": d0})
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
