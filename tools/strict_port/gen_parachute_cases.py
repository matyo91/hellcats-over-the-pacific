#!/usr/bin/env python3
"""Generate the parachute controller comparison cases by running the ORIGINAL bytes.

Same method as gen_ordnance_cases.py: each case seeds the overlay RNG with the original
overlay_rng_init(1), applies its writes, runs parachute_tick (0x19938, runtime 0x19918) or
destroy_parachute_controller (0x1951a, runtime 0x194fa) in the m68k_emu interpreter and records
every byte changed outside the stack. The shadow needs a live object pool, so
spawn_mission_pool_object (file 0x5116) is stubbed on both sides (arguments recorded at
ARGS_POOL, returns 0). test_parachute.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_parachute_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/parachute_cases.json")
PARACHUTE_TICK = 0x19918         # runtime addresses (file - 0x20)
DESTROY_PARACHUTE = 0x194FA
WORLD = 0x23000
CTL = 0x24000                    # parachute controller (canopy velocities up to +0x6be)
OBJ = 0x24800
VERTS = 0x24900                  # 13 canopy vertices (12 bytes)
CONTACTS = 0x1BDBC               # contact record table (256 pointers), cleared
FRAME = 1000


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(WORLD, WORLD + 0x400), (CTL, CTL + 0x6C0), (OBJ, OBJ + 0x80), (VERTS, VERTS + 0xA0),
                       (CONTACTS, CONTACTS + 0x400)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (0x1B870, 2, 0), (0x1B838, 4, FRAME), (0x1B87C, 4, 0),
        (CTL, 4, OBJ), (OBJ + 8, 4, CTL), (OBJ + 0x44, 4, VERTS),
        (CTL + 0x614, 2, 0x1800), (CTL + 0x20, 2, 0x3F00), (CTL + 0x22, 2, 0x0800), (CTL + 0x24, 2, 0x0100),
        (CTL + 0x2E, 4, 0), (OBJ + 0x18, 4, 5000), (OBJ + 0x1C, 4, 4000), (OBJ + 0x20, 4, -3000 & 0xFFFFFFFF),
        (OBJ + 0x40, 4, FRAME - 40),
    ]:
        w.append([addr, size, value])
    for v in range(13):
        w += [[VERTS + 12 * v, 4, (v * 37 - 200) & 0xFFFFFFFF], [VERTS + 12 * v + 4, 4, (v * 23 - 150) & 0xFFFFFFFF],
              [VERTS + 12 * v + 8, 4, 0x200 + v * 40]]
    return w


def age(frames: int) -> list[tuple[int, int, int]]:
    return [(CTL + 0x612, 2, (FRAME - frames) & 0xFFFF)]


def canopy() -> list[tuple[int, int, int]]:
    """Canopy vertex velocities (+0x622 / +0x656 / +0x68a), the drag (+0x618) and its rate (+0x61c)."""
    w = [(CTL + 0x618, 4, 300), (CTL + 0x61C, 2, 0xFFD0)]
    for v in range(13):
        w += [(CTL + 0x622 + 4 * v, 4, (v * 300 - 1800) & 0xFFFFFFFF), (CTL + 0x656 + 4 * v, 4, 2000 - v * 150),
              (CTL + 0x68A + 4 * v, 4, (v * 91 - 500) & 0xFFFFFFFF)]
    return w


def low_canopy() -> list[tuple[int, int, int]]:
    """Canopy vertices still standing (z below 0x17f), some within reach of 0x15e."""
    return [(VERTS + 12 * v + 8, 4, 0x40 + v * 25) for v in range(13)]


def case(name: str, extra: list[tuple[int, int, int]], routine: int = PARACHUTE_TICK, args: list[int] | None = None) -> dict:
    return {"name": name, "routine": routine, "args": args or [CTL], "writes": base() + [list(e) for e in extra]}


CASES = [
    case("falling right after the bail-out (age 5)", age(5)),
    case("falling steeply, banked", age(3) + [(CTL + 0x20, 2, 0x3200), (CTL + 0x22, 2, 0x3E80), (CTL + 0x24, 2, 0x3F00)]),
    case("age 16: shadow, canopy opens, drift", age(16) + canopy()),
    case("age 24: canopy still opening, drag slows the fall", age(24) + canopy() + [(OBJ + 0x1C, 4, 9000)]),
    case("age 40 contact-tracked: untracked", age(40) + [(OBJ + 4, 4, 0x10000)]),
    case("age 20 contact-tracked: still opening, stays tracked", age(20) + [(OBJ + 4, 4, 0x10000)] + canopy()[:2]),
    case("reaching the ground: lands", age(40) + [(OBJ + 0x1C, 4, 0x180), (CTL + 0x2E, 4, 0)]),
    case("reaching a deck at 500: lands", age(40) + [(OBJ + 0x1C, 4, 0x2F0), (CTL + 0x2E, 4, 500)]),
    case("landed: canopy collapses toward heading 0x588", age(60) + [(CTL + 0x61E, 2, 1)] + low_canopy()),
    case("landed, shifted shape (shift 2)", age(60) + [(CTL + 0x61E, 2, 1), (OBJ + 0x34, 2, 2)]),
    case("landed, heading far round (fold)", age(60) + [(CTL + 0x61E, 2, 1), (CTL + 0x22, 2, 0x3000)] + low_canopy()),
    case("landed, nothing left standing: cleanup", age(60) + [(CTL + 0x61E, 2, 1)] + [(VERTS + 12 * v + 8, 4, 0x17F) for v in range(13)]),
    case("ring index wraps at 75", age(5) + [(CTL + 0x60E, 2, 74)]),
    case("replay before the start frame", [(0x1B870, 2, 2), (OBJ + 0x40, 4, FRAME + 1), (CTL + 0x60E, 2, 3)]),
    case("replay 1: snapped to the ring", [(0x1B870, 2, 1), (CTL + 0x60E, 2, 3), (CTL + 0x32 + 3 * 0x14, 4, 5100),
                                            (CTL + 0x36 + 3 * 0x14, 4, 3900), (CTL + 0x3E + 3 * 0x14, 2, 0x123)]),
    case("replay 2: velocity leads to the ring", [(0x1B870, 2, 2), (CTL + 0x60E, 2, 3), (CTL + 0x32 + 3 * 0x14, 4, 5100),
                                                  (CTL + 0x36 + 3 * 0x14, 4, 3900), (CTL + 0x3E + 3 * 0x14, 2, 0x123)]),
    case("destroy: the player's parachute is forgotten", [(0x1B87C, 4, CTL)], DESTROY_PARACHUTE),
    case("destroy: another parachute", [(0x1B87C, 4, CTL + 0x1000)], DESTROY_PARACHUTE),
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "args": c["args"], "zero": zero,
                             "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
