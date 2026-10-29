#!/usr/bin/env python3
"""Generate comparison cases for create_fractal_contact_record, fractal_height_at,
handle_terrain_contact, lift_object_onto_terrain and test_terrain_collision by running the
ORIGINAL bytes on a small fractal terrain built in the interpreter (gen_object_list_cases.Setup):
two face centres around one cell, two sloped faces, and an optional part angle for the rotated
variant. A record that should already exist is made by the original creator during setup; the
collision handler of object a logs its calls on both sides. test_terrain.gd replays the cases.

Usage: python3 tools/strict_port/gen_terrain_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402
from gen_object_list_cases import CTLS, MEMORY_SIZE, OBJECTS, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP, Setup  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/terrain_cases.json")
CREATE_FRACTAL, HEIGHT_AT, TERRAIN_CONTACT = 0x1381C, 0x13960, 0x14178     # runtime addresses
TERRAIN_COLLISION, LIFT = 0x13CBC, 0x14810
METHODS = {CREATE_FRACTAL: "create_fractal_contact_record", HEIGHT_AT: "fractal_height_at",
           TERRAIN_CONTACT: "handle_terrain_contact", TERRAIN_COLLISION: "test_terrain_collision",
           LIFT: "lift_object_onto_terrain"}
HANDLER = 0x3F400
CALL_LOGS = [[HANDLER, 0x3F500, 3]]
DEF_A = 0x26C00
A, B = OBJECTS, OBJECTS + 0x80
PARENT, SCENE, PARTS, TEMPLATES = 0x26800, 0x26900, 0x26A00, 0x27000
CHANGED = 0x26F00


def terrain(s: Setup, angle: int = 0, a_pos: tuple[int, int, int] = (1000, 500, 2000)) -> None:
    for addr in range(0x1BDBC, 0x1BDBC + 0x400, 4):
        s.w(addr, 4, 0)
    for start, end in [(PARENT, PARENT + 0x40), (SCENE, SCENE + 0x80), (PARTS, PARTS + 0x40), (TEMPLATES, TEMPLATES + 0x100),
                       (CHANGED, CHANGED + 4)]:
        for addr in range(start, end, 4):
            s.w(addr, 4, 0)
    s.w(0x1B5A0, 4, 0x23000)
    s.w(0x23000 + 0x8C, 4, TEMPLATES)
    s.w(0x1B870, 2, 0)
    # object a (with a controller), object b (the terrain, 6 vertices of which 2 face centres)
    s.w(A + 8, 4, CTLS)
    s.w(CTLS, 4, A)
    for off, v in zip((0x18, 0x1C, 0x20), a_pos):
        s.w(A + off, 4, v)
    s.w(A + 0x14, 4, 0x8000)
    s.w(B + 0x14, 4, 0x10000)
    s.w(B + 0x24, 4, PARENT)
    s.w(B + 1, 1, 2)
    s.w(B + 2, 1, 1)
    s.w(PARENT + 0x28, 4, SCENE)
    s.w(PARENT + 0x30, 4, PARTS)
    s.w(PARTS + 0x18 + 4, 2, angle)
    s.w(SCENE + 0x2E + 2 * 0x18, 4, 0x10)
    s.w(B + 0x36, 2, 6)
    s.w(B + 0x38, 2, 2)
    base = TEMPLATES + 0x10 + 0x22
    for i, (x, y, z) in enumerate([(0, 0, 0)] * 4 + [(26400, 0, 40000), (26400, 0, 60000)]):
        for j, v in enumerate((x, y, z)):
            s.w(base + 12 * i + 4 * j, 4, v & 0xFFFFFFFF)
    verts = s.alloc(12 * 8)
    for i, (x, y, z) in enumerate([(-400, 100, -800), (800, 300, 0), (0, 200, 900), (300, 0, 300), (0, 0, 0), (0, 0, 0),
                                   (-400 + 30, 100 + 200, -800 - 40), (-400 - 20, 100 + 150, -800 + 10)]):
        for j, v in enumerate((x, y, z)):
            s.w(verts + 12 * i + 4 * j, 4, v & 0xFFFFFFFF)
    faces = s.alloc(0x40)
    for f, first in enumerate((1, 2)):
        idx = s.alloc(8)
        s.w(idx, 2, first)
        s.w(faces + 0x20 * f + 0x18, 4, idx)
    s.w(B + 0x44, 4, verts)
    s.w(B + 0x48, 4, faces)


def case(name: str, routine: int, args: list[int], s: Setup, with_d0: bool = False) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": s.writes(), "with_d0": with_d0}


def build() -> list[dict]:
    cases = []
    for name, angle in [("unrotated", 0), ("rotated 0x0800", 0x0800)]:
        s = Setup()
        terrain(s, angle)
        cases.append(case(f"create fractal record: {name}", CREATE_FRACTAL, [A, B], s, True))
    for name, angle, pos in [("new record, unrotated", 0, (1000, 500, 2000)), ("new record, rotated", 0x0800, (1000, 500, 2000)),
                             ("point in the other triangle", 0, (9000, 500, 1000)), ("negative cell", 0, (-50000, 500, -30000))]:
        s = Setup()
        terrain(s, angle, pos)
        cases.append(case(f"terrain contact: {name}", TERRAIN_CONTACT, [A, B], s))
    s = Setup()
    terrain(s)
    s.emu.call(TERRAIN_CONTACT, [A, B], STACK_TOP)
    s.w(A + 0x18, 4, 1300)
    cases.append(case("terrain contact: cached cell (second call)", TERRAIN_CONTACT, [A, B], s))
    s = Setup()
    terrain(s)
    s.w(0x1B870, 2, 1)
    cases.append(case("terrain contact: during a replay (surface byte kept)", TERRAIN_CONTACT, [A, B], s))
    s = Setup()
    terrain(s)
    s.w(B + 6, 1, 2)
    s.w(A + 0x2C, 4, 0x12345)
    cases.append(case("terrain contact: terrain while holding a reference, no record", TERRAIN_CONTACT, [A, B], s))
    s = Setup()
    terrain(s)
    s.w(A + 8, 4, 0)
    cases.append(case("terrain contact: no controller", TERRAIN_CONTACT, [A, B], s))
    s = Setup()
    terrain(s)
    rec = s.emu.call(CREATE_FRACTAL, [A, B], STACK_TOP) & 0xFFFFFFFF
    for name, x, z in [("first cell", 250, 250), ("same cell, other triangle", 1500, 100), ("far cell", -9000, 12000),
                       ("same cell again", 260, 240)]:
        cases.append(case(f"height at {name}", HEIGHT_AT, [rec, x & 0xFFFFFFFF, z & 0xFFFFFFFF, CHANGED], s, True))
        s.emu.call(HEIGHT_AT, [rec, x & 0xFFFFFFFF, z & 0xFFFFFFFF, CHANGED], STACK_TOP)
    for name, pos, extra in [("below the ground: lifted, support point, collision", (1000, -400, 2000), {}),
                             ("above the ground: support point only", (1000, 9000, 2000), {}),
                             ("frozen vertices (+5 bit 4) and settled (+5 bit 3)", (1000, -400, 2000), {"b5": 0x18}),
                             ("out of range", (0x40000, 0, 0), {}),
                             ("rotated terrain", (1000, -400, 2000), {"angle": 0x0800})]:
        s = Setup()
        terrain(s, extra.get("angle", 0), pos)
        lifted_object(s, extra.get("b5", 0))
        cases.append(case(f"terrain collision: {name}", TERRAIN_COLLISION, [A, B], s))
    s = Setup()
    terrain(s, 0, (1000, -400, 2000))
    lifted_object(s, 0)
    s.emu.call(TERRAIN_COLLISION, [A, B], STACK_TOP)
    s.w(A + 0x18, 4, 40000)
    s.w(A + 0x2C, 4, 0)
    cases.append(case("terrain collision: second call further along x", TERRAIN_COLLISION, [A, B], s))
    s = Setup()
    terrain(s, 0, (1000, -400, 2000))
    lifted_object(s, 0)
    rec = s.emu.call(CREATE_FRACTAL, [A, B], STACK_TOP) & 0xFFFFFFFF
    s.w(0x20B48, 4, rec + 0x30)
    s.w(rec + 0x34, 2, 0)
    s.w(rec + 0x20, 2, 1)
    for k, v in enumerate((-2000, 2000, -3000, 3000)):
        s.w(rec + 0x18 + 2 * k, 2, v & 0xFFFF)
    cases.append(case("lift: no usable plane, cell-corner support, triangle 1", LIFT, [rec, 60, 100, A, B], s, True))
    s.w(rec + 0x20, 2, 0)
    cases.append(case("lift: no usable plane, triangle 0, object below", LIFT, [rec, 300, 0xFFFFFF00, A, B], s, True))
    return cases


SMALL_BLOCKS = 0x2E000            # a free list of 32-byte blocks for heap size class 5 (0x10 / 0x1c)


def lifted_object(s: Setup, b5: int) -> None:
    """Object a gets a definition with the logged collision handler, a mesh to lift and two faces.
    The support list and points come from heap size class 5, so its free list (0x20c78) is seeded
    with 32-byte blocks (the class would otherwise need the host's sbrk)."""
    for k in range(24):
        block = SMALL_BLOCKS + 0x20 * k
        s.w(block, 4, block + 0x20 if k < 23 else 0)
        for off in range(4, 0x20, 4):
            s.w(block + off, 4, 0)
    s.w(0x20C78, 4, SMALL_BLOCKS)
    for address, log_base, nargs in CALL_LOGS:
        s.emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    s.w(CTLS + 4, 4, DEF_A)
    s.w(DEF_A, 2, 1)
    s.w(DEF_A + 0x12, 4, HANDLER)
    for log in CALL_LOGS:
        s.w(log[1] - 4, 4, 0)
        s.w(log[1], 4, 0)
    verts = s.alloc(12 * 3)
    for k in range(9):
        s.w(verts + 4 * k, 4, (100 * k - 300) & 0xFFFFFFFF)
    faces = s.alloc(0x40)
    s.w(faces + 0x1C, 4, 500)
    s.w(faces + 0x3C, 4, 700)
    s.w(A + 0x44, 4, verts)
    s.w(A + 0x48, 4, faces)
    s.w(A + 0x36, 2, 1)
    s.w(A + 0x3A, 2, 2)
    s.w(A + 0x34, 2, 1)
    s.w(A + 5, 1, b5)
    s.w(A + 0xC, 4, 50000)
    s.w(B + 0x2C, 4, 0)


CASES = build()


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], c["args"], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        entry = {"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if c["with_d0"]:
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
