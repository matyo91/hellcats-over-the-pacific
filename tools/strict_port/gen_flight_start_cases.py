#!/usr/bin/env python3
"""Generate comparison cases for refresh_object_colours_for_depth, begin_flight_for_rank and
apply_player_mouse_controls by running the ORIGINAL bytes.

The refresh cases run at depths 1, 4 and 8 over the four mission children, two entity_array_1
objects (one land object) and three pool objects (controller types 2, 3 and none); kind-2 shapes
go through the real recolour_kind2_object (band, then shading, with no faces: shading is tested
with faces elsewhere); the depth-1 pattern targets are non-shape objects with faces, so they
are left alone at the other depths, pattern faces through set_object_faces_bw_pattern, and the
depth-4 case through init_depth4_colour_state on a real heap. The flight-start cases cover ranks
0..2, host word +0xa4, depth 1 and the host-words copy. The mouse cases cover the locked
controls, the mouse path at several pointer positions and the auto-steer path toward the
designated aircraft. test_flight_start.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_flight_start_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/flight_start_cases.json")
ROUTINES = {0x41F0: "refresh_object_colours_for_depth", 0x72F0: "begin_flight_for_rank", 0x921E: "apply_player_mouse_controls"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, PATTERNS, TEMPLATE, TABLE, DESCS, OBJS, FACES, CTLS, DEFS = 0x27000, 0x27300, 0x27600, 0x27680, 0x27700, 0x28000, 0x28800, 0x29000, 0x29400
PLAYER, PLAYER_OBJ, TARGET, TARGET_OBJ = 0x29800, 0x29900, 0x29A00, 0x29B00
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def world(s: Setup, depth: int, multi: int = 0) -> None:
    for a in list(range(WORLD, 0x27800, 4)) + list(range(OBJS, 0x29C00, 4)) + list(range(0x1D96C, 0x1D96C + 0x100, 4)):
        s.w(a, 4, 0)
    for addr, size, v in [(0x1B5A0, 4, WORLD), (0x1B826, 2, depth), (WORLD + 0x88, 4, PATTERNS), (WORLD + 0x8C, 4, DESCS - 0x100),
                          (WORLD + 0xB4, 2, multi), (WORLD + 0x34, 4, PATTERNS + 0x200), (0x1D85A, 2, 1), (WORLD + 0xAA, 2, 0),
                          (TEMPLATE + 0x28, 4, TABLE), (TABLE + 0x2E, 4, 0x100), (0x1B18C, 4, -0x7FFFFFFF), (0x1DA7C, 4, 0)]:
        s.w(addr, size, v)
    for k in range(16):
        s.w(0x1B190 + 4 * k, 4, 0x2000 * k)
    for k in range(0xC8):
        s.w(PATTERNS + 2 * k, 2, (k * 0x1111) & 0xFFFF)
    for n in range(1, 4):
        s.w(WORLD + 0x16 * n + 0x1E, 4, DESCS + 0x40 + 0x10 * n)


def obj(s: Setup, k: int, kind: int = 2, b6: int = 0, ctl_type: int | None = None, faces: int = 0) -> int:
    o, face = OBJS + 0x80 * k, FACES + 0x40 * k
    dist = 0x5000 + 0x900 * k
    for off, size, v in [(0, 1, kind), (6, 1, b6), (0x10, 4, dist), (0x30, 2, dist // 0x2000 + 1), (0x24, 4, TEMPLATE), (0x3A, 2, faces),
                         (0x48, 4, face), (0x44, 4, face + 0x20), (face + 0xF - o, 1, 3)]:
        s.w(o + off, size, v)
    if ctl_type is not None:
        ctl, d = CTLS + 0x20 * k, DEFS + 0x20 * k
        s.w(o + 8, 4, ctl)
        s.w(ctl + 4, 4, d)
        s.w(d, 2, ctl_type)
    return o


def refresh_case(name: str, depth: int) -> dict:
    s = Setup()
    s.w(HEAP_BLOCK, 4, 0x1C00)
    world(s, depth)
    s.w(0x1DA70, 4, 0)
    s.w(0x1DA74, 4, 0)
    s.w(0x1DA78, 4, 0)
    if depth == 8:
        s.w(0x1DA7C, 4, 0x2A000)
        for a in range(0x2A000, 0x2A400, 4):
            s.w(a, 4, 0xFFFFFFFF)
    for addr, k in [(0x1BDB4, 0), (0x1BDAC, 1), (0x1BDB0, 2), (0x1BDA4, 3)]:
        s.w(addr, 4, obj(s, k, kind=2 if k != 2 else 3))
    s.w(0x1C1E0, 4, 2)
    s.w(0x1D4A4, 4, obj(s, 4))
    s.w(0x1D4A8, 4, obj(s, 5, kind=3, b6=0x10, faces=2))
    s.w(0x1B734, 4, 3)
    s.w(0x1B5A4, 4, obj(s, 6, ctl_type=2))
    s.w(0x1B5A8, 4, obj(s, 7, kind=3, ctl_type=3, faces=2))
    s.w(0x1B5AC, 4, obj(s, 8))
    return {"name": name, "routine": BY_NAME["refresh_object_colours_for_depth"], "args": [], "writes": s.writes()}


def flight_case(name: str, rank: int, a4: int, depth1: bool, host_valid: int) -> dict:
    s = Setup()
    s.w(HEAP_BLOCK, 4, 0x1C00)
    world(s, 1 if depth1 else 8)
    for addr, size, v in [(WORLD + 0xA4, 2, a4), (WORLD + 0xE, 2, 1 if depth1 else 8), (0x1B738, 4, PLAYER),
                          (0x1B2B4, 2, 30), (0x1B2B6, 2, 20), (0x1B2B8, 2, 10), (0x24D34, 2, host_valid),
                          (WORLD + 0x33E, 2, 123), (WORLD + 0x340, 2, 45), (0x24D2C, 2, 7), (0x24D2E, 2, 7), (0x1B858, 2, 0x40),
                          (0x1C1E0, 4, 0), (0x1B734, 4, 0)]:
        s.w(addr, size, v)
    for addr, k in [(0x1BDB4, 0), (0x1BDAC, 1), (0x1BDB0, 2), (0x1BDA4, 3)]:
        s.w(addr, 4, obj(s, k, kind=3))
    return {"name": name, "routine": BY_NAME["begin_flight_for_rank"], "args": [rank], "writes": s.writes()}


def mouse_case(name: str, x: int, y: int, locked: int = 0, auto: int = 0, rudder: int = 0) -> dict:
    s = Setup()
    world(s, 8)
    for addr, size, v in [(0x1B738, 4, PLAYER), (PLAYER, 4, PLAYER_OBJ), (PLAYER + 0x685, 1, locked), (0x1B872, 2, auto),
                          (0x1B888, 4, TARGET if auto else 0), (TARGET, 4, TARGET_OBJ), (TARGET_OBJ + 0x18, 4, 5000),
                          (TARGET_OBJ + 0x1C, 4, 800), (TARGET_OBJ + 0x20, 4, -3000), (PLAYER_OBJ + 0x18, 4, 100),
                          (PLAYER_OBJ + 0x1C, 4, 600), (PLAYER_OBJ + 0x20, 4, 200), (WORLD + 0x33E, 2, x), (WORLD + 0x340, 2, y),
                          (0x20B2A, 2, 160), (0x20B2C, 2, 100), (0x1B858, 2, rudder)]:
        s.w(addr, size, v)
    return {"name": name, "routine": BY_NAME["apply_player_mouse_controls"], "args": [], "writes": s.writes()}


def build() -> list[dict]:
    return [
        refresh_case("refresh at depth 8: owner table cleared, shapes recoloured", 8),
        refresh_case("refresh at depth 4: colour state rebuilt", 4),
        refresh_case("refresh at depth 1: patterns", 1),
        flight_case("flight rank 0, AI handler set", 0, 0, False, 0),
        flight_case("flight rank 2, handler kept, host words copied", 2, 1, False, 1),
        flight_case("flight rank 1 at depth 1: objects refreshed", 1, 0, True, 0),
        mouse_case("mouse: centre", 160, 100),
        mouse_case("mouse: top left, rudder", 3, 7, rudder=0x40),
        mouse_case("mouse: bottom right", 319, 199, rudder=-0x40),
        mouse_case("mouse: controls locked", 50, 50, locked=1),
        mouse_case("auto mode: steer toward the designated aircraft", 200, 20, auto=1),
    ]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {}, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
