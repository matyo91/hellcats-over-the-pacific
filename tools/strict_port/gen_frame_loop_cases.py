#!/usr/bin/env python3
"""Generate comparison cases for the frame loop (advance_frame_and_tick_controllers,
run_simulation_tick, reset_distance_base_globals) by running the ORIGINAL bytes. Controller ticks
log their calls on both sides; the effect log holds only end marks, so replaying respawns nothing.
test_frame_loop.gd replays the cases.

Usage: python3 tools/strict_port/gen_frame_loop_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/frame_loop_cases.json")
ADVANCE, SIM_TICK, RESET_REFS = 0x92C4, 0x44C8, 0x6F98          # runtime addresses (file - 0x20)
METHODS = {ADVANCE: "advance_frame_and_tick_controllers", SIM_TICK: "run_simulation_tick",
           RESET_REFS: "reset_distance_base_globals"}
TICK = 0x3F400
CALL_LOGS = [[TICK, 0x3F500, 1]]
WORLD = 0x23000
OBJS = 0x24000                    # objects, 0x80 bytes
CTLS = 0x26000                    # controllers, 0x40 bytes
DEFS = 0x27000                    # definitions, 0x20 bytes
FRAME = 1000


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(PARENT, PARENT + 0x300, 4)) + list(range(OBJS, OBJS + 0x800, 4)) + list(range(CTLS, CTLS + 0x400, 4))
         + list(range(DEFS, DEFS + 0x200, 4)) + list(range(0x1C25C, 0x1C25C + 0x40, 4)) + list(range(0x1D4A4, 0x1D4A4 + 0x20, 4))
         + list(range(0x1B5A4, 0x1B5A4 + 0x20, 4)) + list(range(0x1D0E4, 0x1D0E4 + 0x20, 4)) + list(range(0x1CBE4, 0x1CBE4 + 0x20, 4))
         + list(range(0x1BC64, 0x1BC64 + 28, 4))]
    for addr, size, value in [(0x1B5A0, 4, WORLD), (0x1B838, 4, FRAME), (0x1B870, 2, 0), (0x1C1CC, 4, 0), (0x1C1C8, 4, 0),
                              (0x1C1E0, 4, 0), (0x1B734, 4, 0), (0x1C1DC, 4, 0), (0x1C1D8, 4, 0), (0x260EC, 2, 0),
                              (0x3F4FC, 4, 0), (0x3F500, 4, 0), (0x1B738, 4, 0)]:
        w.append([addr, size, value])
    for i in range(16):
        w.append([0x260EE + 0x18 * i + 0x14, 4, 0x7FFFFFFF])
    return w


PARENT, SCENE, TEMPLATES = 0x27800, 0x27900, 0x27A00


def templates() -> list[tuple[int, int, int]]:
    """A parent / scene entry / template record for the mission-rate step: range word +0xe."""
    return [(WORLD + 0x8C, 4, TEMPLATES), (PARENT + 0x28, 4, SCENE), (SCENE + 0x2E, 4, 0), (TEMPLATES + 0xC, 4, 3000)]


def obj(k: int, kind: int = 2, born: int = FRAME - 50, dead: int = 0, hidden: bool = False, flags: int = 0) -> list[tuple[int, int, int]]:
    o = OBJS + 0x80 * k
    w = [(o, 1, kind), (o + 0x40, 4, born & 0xFFFFFFFF), (o + 0x3C, 4, dead & 0xFFFFFFFF), (o + 4, 4, flags), (o + 0x24, 4, PARENT)]
    if hidden:
        w.append((o + 7, 1, flags & 0xFF | 2))
    return w


def ctl(k: int, slot: int, live: bool = True, tick: bool = True, moving: bool = False) -> list[tuple[int, int, int]]:
    c, o, d = CTLS + 0x40 * k, OBJS + 0x80 * k, DEFS + 0x20 * k
    w = [(0x1C25C + 4 * slot, 4, c), (c, 4, o if live else 0), (c + 4, 4, d), (o + 8, 4, c)]
    if tick:
        w.append((d + 2, 4, TICK))
    if moving:
        w += [(o + 6, 1, 0x20), (c + 8, 4, 5), (c + 0xC, 4, (-6) & 0xFFFFFFFF), (c + 0x10, 4, 7), (o + 0x18, 4, 1000)]
    return w


def case(name: str, routine: int, extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": [], "writes": base() + [list(e) for e in extra]}


REPLAY_OBJECTS = (obj(0, born=FRAME + 5) + obj(1, dead=FRAME - 10) + obj(2, dead=FRAME + 20, born=FRAME + 1, flags=0x40)
                  + obj(3, hidden=True, flags=0x42) + obj(4, kind=3, born=FRAME + 5) + obj(5, born=FRAME + 1, flags=0x40)
                  + [(0x1D4A4 + 4 * k, 4, OBJS + 0x80 * k) for k in range(5)] + [(0x1C1E0, 4, 5)]
                  + [(0x1B5A4, 4, OBJS + 0x80 * 5), (0x1B734, 4, 1)])

CASES = [
    case("advance live: ticks, a dead controller dropped, velocities", ADVANCE,
         ctl(0, 0, moving=True) + ctl(1, 1, live=False) + ctl(2, 2, tick=False) + ctl(3, 3, moving=True) + [(0x1C1CC, 4, 4)]),
    case("advance while replaying: visibility of shapes and pool objects", ADVANCE, REPLAY_OBJECTS + [(0x1B870, 2, 2)] + ctl(6, 0) + [(0x1C1CC, 4, 1)]),
    case("advance at a replay start (state 1): back 0x4a frames, log end", ADVANCE, REPLAY_OBJECTS + [(0x1B870, 2, 1), (0x260EC, 2, 15)]),
    case("advance: count long above its loop word", ADVANCE, ctl(0, 0) + ctl(1, 1, live=False) + [(0x1C1CC, 4, 0x10002)]),
    case("simulation tick: four passes, slots cleared, references reset", SIM_TICK,
         [(WORLD + 0xA8, 2, 3)] + templates() + [(OBJS + 0x80 * k + 0x24, 4, PARENT) for k in range(5)] + [(0x1D4A4, 4, OBJS), (0x1C1E0, 4, 1), (0x1B5A4, 4, OBJS + 0x80), (0x1B734, 4, 1),
                                    (0x1D0E4, 4, OBJS + 0x100), (0x1C1DC, 4, 1), (0x1CBE4, 4, OBJS + 0x180), (0x1C1D8, 4, 1)]
         + ctl(0, 0) + ctl(1, 1) + ctl(2, 2) + ctl(3, 3) + [(DEFS, 2, 5), (DEFS + 0x60, 2, 5), (WORLD + 0xB0, 2, 0),
                                                          (0x1BC64 + 8, 4, OBJS + 0x200), (OBJS + 0x200, 1, 2)]),
    case("simulation tick: outside mission phases, only the slots", SIM_TICK, [(WORLD + 0xA8, 2, 6), (0x1BC64, 4, OBJS + 0x200), (OBJS + 0x200, 1, 2)]),
    case("simulation tick: host +0xac set, slots kept", SIM_TICK, [(WORLD + 0xA8, 2, 1), (WORLD + 0xAC, 2, 1), (0x1BC64, 4, OBJS + 0x200)]),
    case("reset distance references", RESET_REFS),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
