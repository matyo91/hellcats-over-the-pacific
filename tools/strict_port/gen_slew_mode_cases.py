#!/usr/bin/env python3
"""Generate comparison cases for player_slew_mode by running the ORIGINAL bytes.

The controller turns by its input words, steers its speed with the slew keys (every key and axis
transition, key 5, the low-speed sign quirk), is kept above ground, fires gun bursts and steps its
gear. spawn_ordnance_oriented is stubbed on both sides and records its arguments; the attitude
matrix and the vector transform run for real. test_slew_mode.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_slew_mode_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import ARGS_ORDNANCE, SPAWN_ORDNANCE_ORIENTED, compact, record_args  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/slew_mode_cases.json")
ROUTINE = 0xF7F0                                    # runtime address (file 0xf810)
CTL, OBJ, DEF = 0x28000, 0x29000, 0x29400
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def case(name: str, **f: int) -> dict:
    w = [(a, 4, 0) for a in list(range(CTL, CTL + 0x700, 4)) + list(range(OBJ, OBJ + 0x100, 4))
         + list(range(DEF, DEF + 0x80, 4)) + list(range(ARGS_ORDNANCE, ARGS_ORDNANCE + 0x40, 4))]
    w += [(CTL, 4, OBJ), (CTL + 4, 4, DEF), (DEF + 0x44, 2, f.get("def44", 0x0123)),
          (OBJ + 0x18, 4, 5000), (OBJ + 0x1C, 4, f.get("y", 3000)), (OBJ + 0x20, 4, -7000),
          (CTL + 0x20, 2, f.get("yaw", 0x0800)), (CTL + 0x22, 2, f.get("pitch", 0x3F00)), (CTL + 0x24, 2, 0x1111),
          (CTL + 0x662, 2, f.get("turn_x", 0)), (CTL + 0x666, 2, f.get("turn_y", 0)),
          (CTL + 0x62A, 4, f.get("speed", 0)), (CTL + 0x668, 1, f.get("key", 0)), (CTL + 0x678, 1, f.get("axis", 0)),
          (CTL + 0x626, 2, f.get("w626", 0x0456)), (CTL + 0x676, 1, f.get("gun", 0)), (CTL + 0x679, 1, f.get("gear", 0)),
          (CTL + 0x685, 1, f.get("b685", 0)), (CTL + 0x67A, 1, 0x40), (CTL + 0xC, 4, f.get("vy", 0))]
    return {"name": name, "routine": ROUTINE, "args": [CTL], "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in w]}


CASES = [
    case("idle: no key, no axis"),
    case("turn inputs, negative odd halves toward zero", turn_x=-7, turn_y=0x2001, yaw=0x3FFE),
    case("key 5 stops", key=5, axis=2, speed=40000),
    case("unused key 3", key=3, axis=1, speed=5000),
]
for key in (4, 6, 2, 8, 1, 7):
    case_axis = {4: 1, 6: 1, 2: 2, 8: 2, 1: 3, 7: 3}[key]
    other = case_axis % 3 + 1
    CASES += [
        case(f"key {key} from rest", key=key),
        case(f"key {key} on its axis, small speed", key=key, axis=case_axis, speed=1500),
        case(f"key {key} on its axis, fast", key=key, axis=case_axis, speed=-64000),
        case(f"key {key} switching axis", key=key, axis=other, speed=-23456),
    ]
CASES += [
    case("low positive speed flips to -1000", axis=1, speed=500),
    case("low negative speed flips to +1000", axis=3, speed=-999),
    case("zero speed on an axis", axis=2, speed=0),
    case("ground clamp", y=0x20, axis=3, speed=-90000, pitch=0),
    case("ground clamp at the edge", y=0x3F, vy=0),
    case("gun burst fired", gun=1, w626=0x0010, def44=0x0400),
    case("gun cycle 2 wraps", gun=2),
    case("gun cycle 3 counts on", gun=3),
    case("gear lowering", gear=10),
    case("gear at 0x2c", gear=0x2C),
    case("gear at 0x2d stays", gear=0x2D),
    case("gear held by +0x685 bit 5", gear=10, b685=0x20),
    case("negative gear", gear=-3, b685=0x20),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    emu.stubs[SPAWN_ORDNANCE_ORIENTED] = lambda e: record_args(e, ARGS_ORDNANCE, 9)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK),
           "stubs": {"spawn_ordnance_oriented": ARGS_ORDNANCE}, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "player_slew_mode", "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
