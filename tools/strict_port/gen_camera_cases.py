#!/usr/bin/env python3
"""Generate comparison cases for copy_player_pose_to_camera, place_camera_behind_object and
turn_camera_toward_point by running the ORIGINAL bytes. test_camera.gd replays the cases.

Usage: python3 tools/strict_port/gen_camera_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/camera_cases.json")
COPY_POSE, BEHIND, TURN = 0x737A, 0x8880, 0x8A9E          # runtime addresses (file - 0x20)
METHODS = {COPY_POSE: "copy_player_pose_to_camera", BEHIND: "place_camera_behind_object", TURN: "turn_camera_toward_point"}
CTL, OBJ, REC = 0x24000, 0x24800, 0x24900


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(CTL, CTL + 0x700, 4)) + list(range(OBJ, OBJ + 0x80, 4)) + list(range(REC, REC + 0x80, 4))]
    for addr, size, value in [(0x1B738, 4, CTL), (CTL, 4, OBJ), (CTL + 4, 4, REC),
                              (0x1D838, 4, 100000), (0x1D834, 4, 5000), (0x1D830, 4, (-40000) & 0xFFFFFFFF),
                              (0x24D1A, 2, 0x0200), (0x24D18, 2, 0x3F00), (0x1D80C, 2, 0x1234), (0x1D808, 4, 0x5678)]:
        w.append([addr, size, value])
    return w


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": base() + [list(e) for e in extra]}


CASES = [
    case("copy pose: angles negated, angle4 from the type record", COPY_POSE, [],
         [(OBJ + 0x18, 4, 1234), (OBJ + 0x1C, 4, 5678), (OBJ + 0x20, 4, 0xFFFFF000), (CTL + 0x20, 2, 0x0100),
          (CTL + 0x22, 2, 0x3000), (CTL + 0x24, 2, 0), (REC + 0x44, 2, 0x0050), (CTL + 0x626, 2, 0x0120)]),
    case("behind: away from the point", BEHIND, [OBJ, 0, 0, 0, 3],
         [(OBJ + 0x18, 4, 20000), (OBJ + 0x1C, 4, 3000), (OBJ + 0x20, 4, (-15000) & 0xFFFFFFFF)]),
    case("behind: on the point (zero length)", BEHIND, [OBJ, 700, 800, 900, 0],
         [(OBJ + 0x18, 4, 700), (OBJ + 0x1C, 4, 800), (OBJ + 0x20, 4, 900)]),
    case("behind: clamped to height 0xfa", BEHIND, [OBJ, 0, 9000, 0, 2],
         [(OBJ + 0x18, 4, 100), (OBJ + 0x1C, 4, 50), (OBJ + 0x20, 4, 100)]),
    case("turn: small change, a quarter of the way", TURN, [100500, 5100, (-38000) & 0xFFFFFFFF], [(0x24D1A, 2, 0x3F80), (0x24D18, 2, 0x0050)]),
    case("turn: large heading change snaps", TURN, [60000, 5000, (-60000) & 0xFFFFFFFF]),
    case("turn: large pitch change snaps", TURN, [100100, 90000, (-39900) & 0xFFFFFFFF]),
    case("turn: wrap across 0", TURN, [99000, 4900, (-35000) & 0xFFFFFFFF], [(0x24D18, 2, 0x3FF0), (0x24D1A, 2, 0x0001)]),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
