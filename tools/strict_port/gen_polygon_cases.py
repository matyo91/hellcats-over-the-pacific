#!/usr/bin/env python3
"""Generate comparison cases for point_in_polygon_xy, project_face_vertices_yz and
point_over_face_xz by running the ORIGINAL bytes. Same method as gen_plume_cases.py; the
returned D0 is compared. The routines are called by name in the port (no dispatch table).
test_polygon.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_polygon_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/polygon_cases.json")
POINT_IN_XY = 0x12FB2            # runtime addresses (file - 0x20)
PROJECT_YZ = 0x13248
OVER_FACE_XZ = 0x132A8
METHODS = {POINT_IN_XY: "point_in_polygon_xy", PROJECT_YZ: "project_face_vertices_yz", OVER_FACE_XZ: "point_over_face_xz"}
VERTS = 0x24000                  # 12-byte vertices (words +2 / +6 / +10 for the polygon tests)
INDEX = 0x24200
MODEL = 0x24300                  # +0x44 vertex longs
MODEL_VERTS = 0x24400
FACE = 0x24500
OUT = 0x24600
REC = 0x24700                    # point_over_face_xz record: +0 object, +4 model, +0xc / +0xe shifts
OBJ = 0x24800


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(VERTS, VERTS + 0x100), (INDEX, INDEX + 0x40), (MODEL, MODEL + 0x80),
                       (MODEL_VERTS, MODEL_VERTS + 0x100), (FACE, FACE + 0x20), (OUT, OUT + 0x100),
                       (REC, REC + 0x10), (OBJ, OBJ + 0x40)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    return w


def polygon(points: list[tuple[int, int]], order: list[int]) -> list[tuple[int, int, int]]:
    """Vertices with words +2 = a, +6 = b (and +10 = junk); the index list in `order`."""
    w = []
    for i, (a, b) in enumerate(points):
        w += [(VERTS + 12 * i + 2, 2, a & 0xFFFF), (VERTS + 12 * i + 6, 2, b & 0xFFFF), (VERTS + 12 * i + 10, 2, 0x7777)]
    for k, i in enumerate(order):
        w.append((INDEX + 2 * k, 2, i))
    return w


SQUARE = [(-100, -100), (100, -100), (100, 100), (-100, 100)]
CONCAVE = [(-200, -200), (200, -200), (200, 200), (0, 0), (-200, 200)]


def model_face(verts: list[tuple[int, int, int]], order: list[int]) -> list[tuple[int, int, int]]:
    w = [(MODEL + 0x44, 4, MODEL_VERTS), (FACE + 0x14, 2, len(order)), (FACE + 0x18, 4, INDEX)]
    for i, (x, y, z) in enumerate(verts):
        w += [(MODEL_VERTS + 12 * i, 4, x & 0xFFFFFFFF), (MODEL_VERTS + 12 * i + 4, 4, y & 0xFFFFFFFF),
              (MODEL_VERTS + 12 * i + 8, 4, z & 0xFFFFFFFF)]
    for k, i in enumerate(order):
        w.append((INDEX + 2 * k, 2, i))
    return w


PAD = [(-4000, 50, -6000), (4000, 60, -6000), (4000, 70, 6000), (-4000, 80, 6000)]


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]]) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": base() + [list(e) for e in extra]}


CASES = [
    case("xy: centre of a square", POINT_IN_XY, [0, 0, VERTS, 4, INDEX], polygon(SQUARE, [0, 1, 2, 3])),
    case("xy: outside a square", POINT_IN_XY, [150, 0, VERTS, 4, INDEX], polygon(SQUARE, [0, 1, 2, 3])),
    case("xy: on the lower edge (half-open)", POINT_IN_XY, [0, -100, VERTS, 4, INDEX], polygon(SQUARE, [0, 1, 2, 3])),
    case("xy: on the upper edge", POINT_IN_XY, [0, 100, VERTS, 4, INDEX], polygon(SQUARE, [0, 1, 2, 3])),
    case("xy: in the notch of a concave pentagon", POINT_IN_XY, [0, 100, VERTS, 5, INDEX], polygon(CONCAVE, [0, 1, 2, 3, 4])),
    case("xy: inside a concave pentagon", POINT_IN_XY, [-100, 100, VERTS, 5, INDEX], polygon(CONCAVE, [0, 1, 2, 3, 4])),
    case("xy: slanted edge, interpolated crossing", POINT_IN_XY, [30, 40, VERTS, 3, INDEX], polygon([(-50, -50), (120, 10), (0, 90)], [0, 1, 2])),
    case("xy: point (0, 0) off a slanted triangle", POINT_IN_XY, [0, 0, VERTS, 3, INDEX], polygon([(10, -50), (120, 10), (20, 90)], [0, 1, 2])),
    case("xy: index list out of order", POINT_IN_XY, [0, 0, VERTS, 4, INDEX], polygon(SQUARE, [3, 2, 1, 0])),
    case("project yz: shift 0, origins", PROJECT_YZ, [MODEL, 0, FACE, 10, 0xFFFFFFF6, OUT], model_face(PAD, [0, 1, 2, 3])),
    case("project yz: shift 3, word origins wrap", PROJECT_YZ, [MODEL, 3, FACE, 0x12340005, 0xFFFF0007, OUT], model_face(PAD, [2, 0, 3, 1])),
    case("over face xz: object over the pad", OVER_FACE_XZ, [REC, FACE],
         model_face(PAD, [0, 1, 2, 3]) + [(REC, 4, OBJ), (REC + 4, 4, MODEL), (OBJ + 0x18, 4, 500), (OBJ + 0x20, 4, 0xFFFFFF00)]),
    case("over face xz: object beside the pad", OVER_FACE_XZ, [REC, FACE],
         model_face(PAD, [0, 1, 2, 3]) + [(REC, 4, OBJ), (REC + 4, 4, MODEL), (OBJ + 0x18, 4, 9000)]),
    case("over face xz: position shift -2, vertex shift 1", OVER_FACE_XZ, [REC, FACE],
         model_face(PAD, [0, 1, 2, 3]) + [(REC, 4, OBJ), (REC + 4, 4, MODEL), (REC + 0xC, 2, 0xFFFE), (REC + 0xE, 2, 1),
                                          (OBJ + 0x18, 4, 15000), (OBJ + 0x20, 4, 2000)]),
    case("over face xz: position shift +1", OVER_FACE_XZ, [REC, FACE],
         model_face(PAD, [0, 1, 2, 3]) + [(REC, 4, OBJ), (REC + 4, 4, MODEL), (REC + 0xC, 2, 1), (OBJ + 0x18, 4, 1900), (OBJ + 0x20, 4, 2900)]),
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
        entry = {"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if c["routine"] != PROJECT_YZ:
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
