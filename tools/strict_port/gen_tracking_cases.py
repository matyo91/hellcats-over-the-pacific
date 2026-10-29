#!/usr/bin/env python3
"""Generate comparison cases for update_tracking_camera by running the ORIGINAL bytes: the glide,
a follow ending, tracking a designated aircraft (behind the player or behind the aircraft by the
forward-point test), the hold countdown, a player shot, replay state 3 and every end-of-replay
result. test_tracking_camera.gd replays the cases.

Usage: python3 tools/strict_port/gen_tracking_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/tracking_cases.json")
TRACK = 0x8C10                                       # runtime address of file 0x8c30
WORLD = 0x23000
PCTL, POBJ = 0x24000, 0x24800                         # player
TCTL, TOBJ = 0x25000, 0x25800                         # followed aircraft
SCTL, SOBJ = 0x25900, 0x25A00                         # a player shot
CCTL, COBJ = 0x25B00, 0x25C00                         # parachute (for the bail-out end)
FRAME = 1000


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(PCTL, PCTL + 0x700, 4)) + list(range(POBJ, POBJ + 0x80, 4))
         + list(range(TCTL, TCTL + 0x80, 4)) + list(range(TOBJ, TOBJ + 0x80, 4)) + list(range(SCTL, SCTL + 0x40, 4))
         + list(range(SOBJ, SOBJ + 0x80, 4)) + list(range(CCTL, CCTL + 0x700, 4)) + list(range(COBJ, COBJ + 0x80, 4))]
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (0x1B738, 4, PCTL), (PCTL, 4, POBJ), (POBJ + 8, 4, PCTL), (TCTL, 4, TOBJ), (SCTL, 4, SOBJ),
        (0x1B838, 4, FRAME), (0x1B870, 2, 1), (0x1B86E, 2, 60), (0x1B880, 4, 0), (0x1B884, 4, 0), (0x1B888, 4, 0),
        (0x24D1C, 4, 0), (0x1B87C, 4, 0), (0x1B87A, 2, 0), (0x1B734, 4, 0), (0x1C1E0, 4, 0), (0x1D858, 2, 8),
        (POBJ + 0x18, 4, 50000), (POBJ + 0x1C, 4, 3000), (POBJ + 0x20, 4, 20000), (PCTL + 0x22, 2, 0x0400),
        (TOBJ + 0x18, 4, 56000), (TOBJ + 0x1C, 4, 3500), (TOBJ + 0x20, 4, 26000), (TCTL + 0x22, 2, 0x0600), (TCTL + 0x20, 2, 0x3F00),
        (0x1D838, 4, 40000), (0x1D834, 4, 4000), (0x1D830, 4, 10000), (0x1D81C, 4, 30), (0x1D818, 4, (-5) & 0xFFFFFFFF), (0x1D814, 4, 40),
        (0x24D28, 4, 47000), (0x24D24, 4, 3600), (0x24D20, 4, 16000), (0x24D1A, 2, 0x0100), (0x24D18, 2, 0x0200),
        (SOBJ + 0x18, 4, 60000), (SOBJ + 0x1C, 4, 2500), (SOBJ + 0x20, 4, 30000), (SOBJ + 0x40, 4, FRAME - 5),
        (CCTL, 4, COBJ), (COBJ + 8, 4, CCTL), (COBJ + 0x1C, 4, 5000), (COBJ + 0x18, 4, 50500),
    ]:
        w.append([addr, size, value])
    return w


def case(name: str, extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": TRACK, "args": [], "writes": base() + [list(e) for e in extra]}


CASES = [
    case("glide toward the goal"),
    case("follow just ended: steps re-aimed", [(0x1B884, 4, TCTL)]),
    case("new hold on the designated aircraft, turned away: behind the player", [(0x1B888, 4, TCTL), (TCTL + 0x22, 2, 0x2400)]),
    case("designated aircraft heading close: forward-point test", [(0x1B888, 4, TCTL)]),
    case("designated aircraft heading close, pointed at the player", [(0x1B888, 4, TCTL), (TCTL + 0x22, 2, 0x2000), (PCTL + 0x22, 2, 0x1E00)]),
    case("hold running on another aircraft: counts down", [(0x1B888, 4, PCTL), (0x1B884, 4, TCTL), (0x24D1C, 4, 7)]),
    case("designated aircraft too far: glide", [(0x1B888, 4, TCTL), (TOBJ + 0x18, 4, 400000)]),
    case("player shot past its start: look at it", [(0x1B880, 4, SCTL)]),
    case("player shot not started yet", [(0x1B880, 4, SCTL), (SOBJ + 0x40, 4, FRAME + 3)]),
    case("replay state 3: no glide", [(0x1B870, 2, 3)]),
    case("frames reach 0x1e: state 3", [(0x1B86E, 2, 0x1F)]),
    case("end, not crashed: -1", [(0x1B86E, 2, 1)]),
    case("end, crashed without a parachute: 1", [(0x1B86E, 2, 1), (PCTL + 0x684, 1, 4)]),
    case("end, crashed with a parachute: bail-out outcome", [(0x1B86E, 2, 1), (PCTL + 0x684, 1, 4), (0x1B87C, 4, CCTL)]),
    case("end in host mode 2: no result", [(0x1B86E, 2, 1), (WORLD + 0x98, 2, 2)]),
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
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in CASES:
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "update_tracking_camera", "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes, "d0": d0})
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
