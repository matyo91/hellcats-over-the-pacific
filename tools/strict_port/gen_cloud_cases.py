#!/usr/bin/env python3
"""Generate comparison cases for spawn_cloud_layer and spawn_camera_relative_object by running the
ORIGINAL bytes. The pool spawn is stubbed on both sides and logs every call's arguments, so all ten
cloud placements are compared; one case gives spawn_camera_relative_object a real controller to
fill (by name, with a stub returning 0 the fill is skipped). test_clouds.gd replays the cases.

Usage: python3 tools/strict_port/gen_cloud_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import (  # noqa: E402
    ARGS_POOL, MEMORY_SIZE, OVERLAY_RNG_INIT, SPAWN_MISSION_POOL_OBJECT, STACK_GUARD, STACK_TOP, record_args)

FIXTURE = Path("godot/tests/strict_port/fixtures/cloud_cases.json")
CLOUDS, SPAWN_REL = 0x63EC, 0x19A82                       # runtime addresses (file - 0x20)
METHODS = {CLOUDS: "spawn_cloud_layer", SPAWN_REL: "spawn_camera_relative_object"}
WORLD = 0x23000
OBJS, CTLS, DEFS = 0x24000, 0x25000, 0x29000


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(OBJS, OBJS + 0x400, 4)) + list(range(CTLS, CTLS + 0x200, 4))
         + list(range(DEFS, DEFS + 0x100, 4)) + list(range(0x1D4A4, 0x1D4A4 + 0x20, 4)) + list(range(ARGS_POOL, ARGS_POOL + 0x200, 4))]
    for addr, size, value in [(0x1B5A0, 4, WORLD), (0x1D838, 4, 100000), (0x1D834, 4, 4000), (0x1D830, 4, (-40000) & 0xFFFFFFFF),
                              (0x1C1E0, 4, 0)] + [(0x26784 + 4 * k, 4, 0x27000 + 0x100 * k) for k in range(5)]:
        w.append([addr, size, value])
    return w


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": base() + [list(e) for e in extra]}


CASES = [case(f"cloud layer, rng cursor {c:#x}", CLOUDS, [], [(WORLD + 0xAE, 2, 1), (0x26008, 4, c)]) for c in (0x2600C, 0x26040, 0x26090)]
CASES += [
    case("no clouds: type 0x1d objects retire", CLOUDS, [],
         [(0x1C1E0, 4, 3)] + [(0x1D4A4 + 4 * k, 4, OBJS + 0x80 * k) for k in range(3)]
         + [(OBJS + 8, 4, CTLS), (CTLS + 4, 4, DEFS), (DEFS, 2, 0x1D), (OBJS + 0x88, 4, CTLS + 0x40), (CTLS + 0x44, 4, DEFS + 0x20),
            (DEFS + 0x20, 2, 5), (OBJS, 1, 2), (OBJS + 0x80, 1, 2), (OBJS + 0x100, 1, 2)]),
    case("camera-relative spawn, class 3 (stubbed: nothing spawned)", SPAWN_REL, [3, 0xFFFFF000, 50000, 2000, 0x11112222, 0x3333, 0xFFFF8001]),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    emu.stubs[SPAWN_MISSION_POOL_OBJECT] = lambda e: record_args(e, ARGS_POOL, 8)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD),
           "stubs": {"spawn_mission_pool_object": ARGS_POOL}, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
