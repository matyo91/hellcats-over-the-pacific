#!/usr/bin/env python3
"""Generate the ordnance (definition key 0xc) comparison cases by running the ORIGINAL bytes.

Same method as gen_ai_state_cases.py: each case seeds the overlay RNG with the original
overlay_rng_init(1), applies its writes, runs ordnance_tick (0x12a2a, runtime 0x12a0a) or
ordnance_collision (0x12f52, runtime 0x12f32) in the m68k_emu interpreter and records every byte
changed outside the stack. Effects and trails need a live object pool, so
spawn_mission_pool_object (file 0x5116) is stubbed on both sides: it records its arguments at
ARGS_POOL and returns 0. test_ordnance.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_ordnance_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/ordnance_cases.json")
MEMORY_SIZE = 0x40000
STACK_TOP = 0x3F000
STACK_GUARD = (STACK_TOP - 0x800, STACK_TOP + 0x40)
OVERLAY_RNG_INIT = 0x114EA
ORDNANCE_TICK = 0x12A0A          # runtime addresses (file - 0x20)
ORDNANCE_COLLISION = 0x12F32
SPAWN_MISSION_POOL_OBJECT = 0x50F6
ARGS_POOL = 0x3F300
WORLD = 0x23000                  # host world
CTL = 0x24000                    # ordnance controller (0x620 bytes)
OBJ = 0x24800                    # ordnance object
OTHER = 0x24900                  # object hit (collision cases)
OTHER_CTL = 0x24A00
OTHER_DEF = 0x24B00
FACILITY = 0x24C00               # an enemy (0x12) or friendly (0x13) facility near the impact
FACILITY_CTL = 0x24D00
FACILITY_REC = 0x24E00
DEFAULT_FACE = 0x24F00           # the default ground face (0x1bda8): its byte +0x16 is the surface code
FRAME = 1000


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(WORLD, WORLD + 0x400), (CTL, CTL + 0x620), (OBJ, OBJ + 0x80), (OTHER, OTHER + 0x80),
                       (OTHER_CTL, OTHER_CTL + 0x40), (OTHER_DEF, OTHER_DEF + 0x20), (FACILITY, FACILITY + 0x80),
                       (FACILITY_CTL, FACILITY_CTL + 0x40), (FACILITY_REC, FACILITY_REC + 0x20), (DEFAULT_FACE, DEFAULT_FACE + 0x20)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (0x1B870, 2, 0), (0x1B838, 4, FRAME), (0x1B734, 4, 0), (0x1C1E0, 4, 0),
        (0x1D858, 2, 1), (0x1BDA8, 4, DEFAULT_FACE), (0x1B848, 2, 0), (0x1B84A, 2, 0), (0x260EC, 2, 0),
        (CTL, 4, OBJ), (OBJ + 8, 4, CTL), (CTL + 0x610, 2, 0x2000), (CTL + 0x20, 2, 0x3E00), (CTL + 0x22, 2, 0x0400),
        (OBJ + 0x18, 4, 1000), (OBJ + 0x1C, 4, 3000), (OBJ + 0x20, 4, 2000), (OBJ + 0x40, 4, FRAME - 5),
    ]:
        w.append([addr, size, value])
    return w


def case(name: str, extra: list[tuple[int, int, int]], routine: int = ORDNANCE_TICK, args: list[int] | None = None) -> dict:
    return {"name": name, "routine": routine, "args": args or [CTL], "writes": base() + [list(e) for e in extra]}


def facility(type_word: int) -> list[tuple[int, int, int]]:
    """A runway ('p') default ground surface and one facility of the given type nearby."""
    return [(DEFAULT_FACE + 0x16, 1, 0x70), (0x1B734, 4, 1), (0x1B5A4, 4, FACILITY), (FACILITY + 8, 4, FACILITY_CTL),
            (FACILITY_CTL + 4, 4, FACILITY_REC), (FACILITY_REC, 2, type_word), (FACILITY + 0xC, 4, 100000),
            (FACILITY + 0x18, 4, 1500), (FACILITY + 0x20, 4, 2500)]


def landed(previous: bool = False) -> list[tuple[int, int, int]]:
    """Impact flag 0x400 in +0x61c (and in +0x61e when previous)."""
    return [(CTL + 0x61C, 2, 0x400)] + ([(CTL + 0x61E, 2, 0x400)] if previous else [])


def ring(index: int, x: int, y: int, z: int, flags: int, att: tuple[int, int, int] = (0x100, 0x200, 0x300)) -> list[tuple[int, int, int]]:
    e = CTL + 0x32 + index * 0x14
    return [(CTL + 0x60E, 2, index), (e, 4, x), (e + 4, 4, y), (e + 8, 4, z),
            (e + 0xC, 2, att[0]), (e + 0xE, 2, att[1]), (e + 0x10, 2, att[2]), (e + 0x12, 2, flags)]


CASES = [
    case("falling: level drop, gravity and speed", []),
    case("falling: steep and banked, heading folds", [(CTL + 0x20, 2, 0x3000), (CTL + 0x22, 2, 0x3F00), (CTL + 0x24, 2, 0x200), (CTL + 0x610, 2, 0x5000)]),
    case("falling: ring index wraps at 75", [(CTL + 0x60E, 2, 74)]),
    case("reaching the sea (ground 0): impact flag only", [(OBJ + 0x1C, 4, 40), (CTL + 0x2E, 4, 0), (CTL + 0x2C, 1, 0x10)]),
    case("reaching land on surface 0x70: direct hit", [(OBJ + 0x1C, 4, 140), (CTL + 0x2E, 4, 100), (CTL + 0x2C, 1, 0x70)]),
    case("reaching land on surface 0x40: no direct hit", [(OBJ + 0x1C, 4, 140), (CTL + 0x2E, 4, 100), (CTL + 0x2C, 1, 0x40)]),
    case("impact frame: direct hit at sea, splash", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 0)]),
    case("impact frame: direct hit on land, blast (credited, no facility)", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 100), (CTL + 0x614, 2, 1)]),
    case("impact frame: no direct hit (spawn_destruction_effect)", landed()),
    case("impact frame: credited hit on 'p', no facility", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 100), (CTL + 0x614, 2, 1), (DEFAULT_FACE + 0x16, 1, 0x70)]),
    case("impact frame: credited hit near an enemy facility on 'p'", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 100), (CTL + 0x614, 2, 1)] + facility(0x12)),
    case("impact frame: credited hit near a friendly facility", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 100), (CTL + 0x614, 2, 1)] + facility(0x13)),
    case("impact: enemy facility, mission mode 3 near the target", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 100), (CTL + 0x614, 2, 1), (WORLD + 0x90, 2, 3),
         (OBJ + 0x18, 4, (-0x3BCD3 + 1000) & 0xFFFFFFFF), (OBJ + 0x20, 4, 0x2B246A), (FACILITY + 0x18, 4, (-0x3BCD3) & 0xFFFFFFFF), (FACILITY + 0x20, 4, 0x2B246A)] + facility(0x12)[:7]),
    case("impact: enemy facility, mission mode 4 near the target", landed() + [(CTL + 0x616, 2, 1), (CTL + 0x2E, 4, 100), (CTL + 0x614, 2, 1), (WORLD + 0x90, 2, 4), (0x1B870, 2, 0),
         (OBJ + 0x18, 4, (-0xF29A61 + 500) & 0xFFFFFFFF), (OBJ + 0x20, 4, 0xB2584F), (FACILITY + 0x18, 4, (-0xF29A61) & 0xFFFFFFFF), (FACILITY + 0x20, 4, 0xB2584F)] + facility(0x12)[:7]),
    case("waiting for the blast frame", landed(True) + [(CTL + 0x618, 4, FRAME + 3)]),
    case("blast frame: apply_blast_damage", landed(True) + [(CTL + 0x618, 4, FRAME), (CTL + 0x614, 2, 1), (CTL + 0x616, 2, 1)]),
    case("burning flag change attaches a trail", [(CTL + 0x61C, 2, 0x40)]),
    case("replay before the start frame: nothing", [(0x1B870, 2, 2), (OBJ + 0x40, 4, FRAME + 1)] + ring(3, 5, 6, 7, 0)),
    case("replay 1: object snapped to the ring", [(0x1B870, 2, 1)] + ring(3, 1500, 2900, 2500, 0x40)),
    case("replay at the start frame: flags without 0x40", [(0x1B870, 2, 2), (OBJ + 0x40, 4, FRAME)] + ring(3, 1500, 2900, 2500, 0x440)),
    case("replay 2: velocity leads to the ring", [(0x1B870, 2, 2)] + ring(3, 1500, 2900, 2500, 0)),
    case("collision with a ship: direct hit", [(OTHER + 8, 4, OTHER_CTL), (OTHER_CTL + 4, 4, OTHER_DEF), (OTHER_DEF, 2, 0x17)], ORDNANCE_COLLISION, [OBJ, OTHER]),
    case("collision with an aircraft: impact only", [(OTHER + 8, 4, OTHER_CTL), (OTHER_CTL + 4, 4, OTHER_DEF), (OTHER_DEF, 2, 2)], ORDNANCE_COLLISION, [OBJ, OTHER]),
    case("collision with scenery (no controller)", [], ORDNANCE_COLLISION, [OBJ, OTHER]),
    case("collision during a replay: ignored", [(0x1B870, 2, 1)], ORDNANCE_COLLISION, [OBJ, OTHER]),
]


def record_args(emu: Emulator, out: int, count: int) -> int:
    """The spawn stub: append its long arguments to the log at out (long call count, then count
    longs per call) and return 0 (no object)."""
    calls = emu.read(out, 4)
    for i in range(count):
        emu.write(out + 4 + 4 * (calls * count + i), 4, emu.read(emu.a[7] + 4 * i, 4))
    emu.write(out, 4, calls + 1)
    return 0


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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "args": c["args"], "zero": zero,
                             "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
