#!/usr/bin/env python3
"""Generate comparison cases for sort_group_parts_by_distance by running the ORIGINAL bytes.

A group object has seeded random part centres (its last model vertices), a part face index
list after its face table and colour records after that. Cases run unlit and lit (host +0xaa:
the distance bands change, the part faces are recoloured and their palette slots rewritten in
direct palette mode when still owned, else dropped), without a group list, and with group lists
whose entries sit before, between and after the parts (so every merge exit runs), with
deferred_free_flag freeing word-0 entries on a real heap. The object list renderer test exercises
the call from render_visible_objects. test_sort_parts.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_sort_parts_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import Setup  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/sort_parts_cases.json")
ROUTINE = 0x1441A                                  # runtime address (file 0x1443a)
WORLD, OBJ, VERTS, FACES, GROUPS, OWNERS = 0x27000, 0x27100, 0x27200, 0x27400, 0x27800, 0x27900
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)
N_FACES = 6


def case(name: str, seed: int, parts: int = 5, lit: int = 0, groups: list[tuple[int, int, int]] | None = None,
         deferred: int = 0, owned: tuple[int, ...] = (), scale: int = 1) -> dict:
    rnd = random.Random(seed)
    s = Setup()
    for addr in list(range(WORLD, 0x27C00, 4)):
        s.w(addr, 4, 0)
    nverts = 3 + parts
    for addr, size, v in [(0x1B5A0, 4, WORLD), (WORLD + 0xAA, 2, lit), (WORLD + 0xB4, 2, 0), (0x1D85A, 2, 1),
                          (0x1DA7C, 4, OWNERS), (0x1C1BE, 2, 10), (0x1C1BC, 2, deferred),
                          (0x1D838, 4, 4000), (0x1D834, 4, 777), (0x1D830, 4, -2500),
                          (OBJ + 0x34, 2, scale), (OBJ + 0x36, 2, nverts), (OBJ + 0x38, 2, parts), (OBJ + 0x3A, 2, N_FACES),
                          (OBJ + 0x44, 4, VERTS), (OBJ + 0x48, 4, FACES), (0x1B18C, 4, -0x7FFFFFFF)]:
        s.w(addr, size, v)
    for k in range(16):
        s.w(0x1B190 + 4 * k, 4, 0x800 * k)
    for i in range(nverts):
        for c in range(3):
            s.w(VERTS + 12 * i + 4 * c, 4, rnd.randint(-6000, 6000))
    lst = FACES + 32 * N_FACES
    order = list(range(parts))
    rnd.shuffle(order)
    for k, p in enumerate(order):
        s.w(lst + 2 * k, 2, p)
    colours = lst + 2 * parts
    for p in range(parts):
        for c in range(3):
            s.w(colours + 6 * p + c, 1, rnd.randint(0, 255))
        s.w(colours + 6 * p + 4, 2, rnd.choice([0, 3, 9]))
        face = FACES + 32 * p
        s.w(face + 0xF, 1, 7 + p)
        s.w(face + 2, 2, 0xEEEE)
        if p in owned:
            s.w(OWNERS + 4 * (7 + p), 4, face)
    if groups is not None:
        s.w(OBJ + 0x2C, 4, GROUPS)
        s.w(GROUPS, 2, len(groups))
        for k, (count, gx, gz) in enumerate(groups):
            e = s.alloc(0x20)
            for off in range(0, 0x20, 4):
                s.w(e + off, 4, 0)
            s.w(e, 2, count)
            s.w(e + 4, 4, gx)
            s.w(e + 8, 4, gz)
            s.w(GROUPS + 4 + 4 * k, 4, e)
    return {"name": name, "args": [OBJ], "writes": s.writes()}


CASES = [
    case("unlit, no groups: parts numbered far to near", 1),
    case("lit: bands, colours and owned slots", 2, lit=1, owned=(0, 2, 4)),
    case("lit, nothing owned: slots dropped", 3, lit=1),
    case("groups before, between and after the parts", 4, groups=[(2, 8000, 0), (1, 1000, 500), (3, -100, 50)]),
    case("all groups farther than every part (early exit)", 5, groups=[(1, 40000, 0), (2, 30000, 9000)]),
    case("all groups nearer than every part", 6, groups=[(1, 10, 0), (4, 0, 20)]),
    case("deferred free: word-0 entries freed", 7, groups=[(0, 5000, 0), (2, 3000, 0), (0, 10, 10)], deferred=1),
    case("deferred free: every entry freed", 8, groups=[(0, 5000, 0)], deferred=1),
    case("one part, lit, scale 3", 9, parts=1, lit=1, owned=(0,), scale=3),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(ROUTINE, c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {}, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": ROUTINE, "method": "sort_group_parts_by_distance", "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
