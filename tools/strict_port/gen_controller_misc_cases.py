#!/usr/bin/env python3
"""Generate comparison cases for small controller routines by running the ORIGINAL bytes.

Covers the destroy hooks of the plume / ground fire / shadow records, effect_pre_render_hook with
face_object_to_camera, follow_camera_offset, create_singleton_type10_controller,
impact_one_time_in_16 and fill_pose_history_angles / _flags. Same method as
gen_ordnance_cases.py; cases marked with_d0 also record the returned D0, and cases with a
"method" are called by name in the port (no dispatch table reaches them).
test_controller_misc.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_controller_misc_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/controller_misc_cases.json")
DESTROY_PLUME = 0x116C8          # runtime addresses (file - 0x20)
DESTROY_GROUND_FIRE = 0x1711C
DESTROY_SHADOW = 0x18922
EFFECT_PRE_RENDER = 0x1278A
FACE_CAMERA = 0x12718
FOLLOW_CAMERA = 0x19B10
CREATE_TYPE10 = 0x12F72
IMPACT_1_IN_16 = 0x1688E
FILL_ANGLES = 0xDF78
FILL_FLAGS = 0xDFB2
CTL = 0x24000
OBJ = 0x24800
OWNER = 0x24900
OTHER = 0x24A00                  # an ordnance object hit by impact_one_time_in_16
OTHER_CTL = 0x24B00
HEAP_SENTINEL, HEAP_ROVER, HEAP_BLOCK = 0x20C58, 0x20C60, 0x2C000


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(CTL, CTL + 0x620), (OBJ, OBJ + 0x80), (OWNER, OWNER + 0x80), (OTHER, OTHER + 0x80),
                       (OTHER_CTL, OTHER_CTL + 0x620), (HEAP_BLOCK, HEAP_BLOCK + 0x800)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    for addr, size, value in [
        (0x1B870, 2, 0), (CTL, 4, OBJ), (OBJ + 8, 4, CTL), (OTHER + 8, 4, OTHER_CTL), (OWNER + 3, 1, 5),
        (OBJ + 0x18, 4, 1000), (OBJ + 0x1C, 4, 2000), (OBJ + 0x20, 4, 3000),
        (0x1D838, 4, 50000), (0x1D834, 4, 4000), (0x1D830, 4, (-20000) & 0xFFFFFFFF),
        (0x1D80E, 2, 0x1234), (0x1D810, 2, 0xFF00), (0x20B40, 4, 0),
        (HEAP_SENTINEL, 4, 0), (HEAP_SENTINEL + 4, 4, HEAP_BLOCK), (HEAP_ROVER, 4, HEAP_SENTINEL),
        (HEAP_BLOCK, 4, 0x100), (HEAP_BLOCK + 4, 4, HEAP_SENTINEL),
    ]:
        w.append([addr, size, value])
    return w


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]] = (), with_d0: bool = False,
         method: str | None = None) -> dict:
    c = {"name": name, "routine": routine, "args": args, "with_d0": with_d0,
         "writes": base() + [list(e) for e in extra]}
    if method:
        c["method"] = method
    return c


CASES = [
    case("destroy plume: owner loses a reference", DESTROY_PLUME, [CTL], [(CTL + 0x3C, 4, OWNER)]),
    case("destroy plume: no owner", DESTROY_PLUME, [CTL]),
    case("destroy ground fire: owner loses a reference", DESTROY_GROUND_FIRE, [CTL], [(CTL + 0x50, 4, OWNER)]),
    case("destroy ground fire: reference wraps below 0", DESTROY_GROUND_FIRE, [CTL], [(CTL + 0x50, 4, OWNER), (OWNER + 3, 1, 0)]),
    case("destroy shadow: owner loses a reference", DESTROY_SHADOW, [CTL], [(CTL + 0x32, 4, OWNER)]),
    case("destroy shadow: no owner", DESTROY_SHADOW, [CTL]),
    case("pre-render kind 0: nothing", EFFECT_PRE_RENDER, [CTL], [(CTL + 0x32, 1, 0)]),
    case("pre-render kind 1: nothing", EFFECT_PRE_RENDER, [CTL], [(CTL + 0x32, 1, 1)]),
    case("pre-render kind 2: faces the camera", EFFECT_PRE_RENDER, [CTL], [(CTL + 0x32, 1, 2)]),
    case("pre-render kind 3: nothing", EFFECT_PRE_RENDER, [CTL], [(CTL + 0x32, 1, 3)]),
    case("face_object_to_camera directly (returns 0)", FACE_CAMERA, [CTL], [(0x1D80E, 2, 0x8001), (0x1D810, 2, 0x0000)], True),
    case("follow camera: camera above the floor", FOLLOW_CAMERA, [CTL], [(CTL + 0x32, 4, 300), (CTL + 0x36, 4, 12000), (CTL + 0x3A, 4, (-700) & 0xFFFFFFFF)]),
    case("follow camera: camera below the floor, no climb", FOLLOW_CAMERA, [CTL], [(CTL + 0x32, 4, 300), (CTL + 0x36, 4, 15000), (CTL + 0x3A, 4, 700)]),
    case("follow camera: exactly at floor - 10000", FOLLOW_CAMERA, [CTL], [(CTL + 0x36, 4, 14000)]),
    case("create type10 singleton (heap, published)", CREATE_TYPE10, [OBJ, 0x10], [(OBJ + 4, 4, 0x40)], True),
    case("impact 1 in 16: no hit (returns the rng)", IMPACT_1_IN_16, [OBJ, OTHER], [], True),
    case("impact 1 in 16: hit (rng cursor 0x2603c)", IMPACT_1_IN_16, [OBJ, OTHER], [(0x26008, 4, 0x2603C)], True),
    case("impact 1 in 16: hit on a ship during a replay (ignored)", IMPACT_1_IN_16, [OBJ, OTHER], [(0x26008, 4, 0x2603C), (0x1B870, 2, 1)], True),
    case("fill pose history angles", FILL_ANGLES, [CTL + 0x32, 0x11112222, 0x3333, 0xFFFF8001], [], False, "fill_pose_history_angles"),
    case("fill pose history flags", FILL_FLAGS, [CTL + 0x32, 0xABCD0440], [], False, "fill_pose_history_flags"),
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
        if c["with_d0"]:
            entry["d0"] = d0
        if "method" in c:
            entry["method"] = c["method"]
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
