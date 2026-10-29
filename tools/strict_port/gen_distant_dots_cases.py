#!/usr/bin/env python3
"""Generate comparison cases for draw_distant_object_dots by running the ORIGINAL bytes.

Queued dot objects (single points and two-point trails, controller byte +0x3b bit 1) sit at
several depths in front of an identity camera, some off screen or behind; the erase and plot
routines (depth_routine_da84 / _da80) are logging stubs (the plot logs its dot record by value).
Faces mostly have no palette slot; one case runs a colour tally, one assigns a colour through
assign_face_colour at depth 1 (host luma table). test_distant_dots.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_distant_dots_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/distant_dots_cases.json")
ROUTINE = 0x1629A                                   # runtime address (file 0x162ba)
WORLD, OBJS, LUMA = 0x27000, 0x28000, 0x27400
ERASE, PLOT = 0x30000, 0x30100
CALL_LOGS = [[ERASE, 0x38004, 0], [PLOT, 0x38404, 4, 0, 3]]
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def case(name: str, objs: list[dict], host_line: int = 0, tally: int = 0, depth: int = 8) -> dict:
    w = [(a, 4, 0) for a in list(range(WORLD, WORLD + 0x600, 4)) + list(range(OBJS, OBJS + 0x1000, 4))
         + list(range(0x38000, 0x38800, 4)) + list(range(0x26288, 0x26288 + 0x200, 4)) + list(range(0x265D0, 0x26650, 4))]
    w += [(0x1B5A0, 4, WORLD), (WORLD + 0x9E, 2, host_line), (WORLD + 0x88, 4, LUMA), (0x1DA84, 4, ERASE), (0x1DA80, 4, PLOT),
          (0x1D838, 4, 0), (0x1D834, 4, 0), (0x1D830, 4, 0), (0x20B28, 2, 256), (0x20B26, 2, 200), (0x20AEE, 2, -160),
          (0x20AEC, 2, 160), (0x20AEA, 2, -100), (0x20AE8, 2, 100), (0x1DA8A, 2, tally), (0x1DA88, 2, 0x5A5A),
          (0x1B826, 2, depth), (0x265D0, 2, len(objs)), (0x1DA8C, 2, 9)]
    w += [(0x1D744 + 2 * k, 2, v) for k, v in enumerate([0x1000, 0, 0, 0, 0x1000, 0, 0, 0, 0x1000])]
    w += [(LUMA + 2 * k, 2, 0x100 + k) for k in range(0x100)]
    for i, o in enumerate(objs):
        obj, ctl, face, verts = OBJS + 0x100 * i, OBJS + 0x100 * i + 0x60, OBJS + 0x100 * i + 0xA0, OBJS + 0x100 * i + 0xC0
        x, y, z = o["pos"]
        w += [(0x265D2 + 4 * i, 4, obj), (obj + 8, 4, ctl), (obj + 0x48, 4, face), (obj + 0x44, 4, verts),
              (obj + 0x32, 2, o.get("shift", 0)), (obj + 0x34, 2, o.get("shift34", 0)), (obj + 0x18, 4, x), (obj + 0x1C, 4, y),
              (obj + 0x20, 4, z), (ctl + 0x3B, 1, 2 if o.get("trail") else 0), (face + 0xF, 1, o.get("slot", 0xFF)),
              (face + 6, 2, o.get("colour", 0x1234)), (face + 0xC, 1, 0x40), (face + 0xD, 1, 0x80), (face + 0xE, 1, 0xC0)]
        for k, (vx, vy, vz) in enumerate(o.get("verts", [(0, 0, 0)] * 3)):
            w += [(verts + 12 * k, 4, vx), (verts + 12 * k + 4, 4, vy), (verts + 12 * k + 8, 4, vz)]
    return {"name": name, "routine": ROUTINE, "args": [], "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in w]}


DOTS = [{"pos": (100, 50, 3000)}, {"pos": (-400, 20, 7000)}, {"pos": (800, -300, 9000)}, {"pos": (2000, 0, 20000)},
        {"pos": (0, 0, 2)}, {"pos": (9000, 0, 1000)}, {"pos": (10, 10, 4000), "shift": 2}]
TRAILS = [{"pos": (1000, 0, 6000), "trail": True, "verts": [(0, 0, 0), (200, 50, 300), (-100, 0, 9000)]},
          {"pos": (-500, 100, 4000), "trail": True, "shift": 1, "shift34": 3, "verts": [(10, 0, 0), (0, 10, 50), (5, 5, 5)]},
          {"pos": (300, -50, 12000), "trail": True, "shift": 3, "shift34": 0, "verts": [(0, 0, 0), (80, 0, 80), (0, 0, 0)]}]
CASES = [
    case("single dots at several depths, off screen and behind", DOTS),
    case("trails: first two vertices", TRAILS),
    case("host line routine: queue emptied first", DOTS, host_line=1),
    case("colour tally running", [dict(d, slot=5) for d in DOTS[:3]], tally=0x0107),
    case("palette slot assigned at depth 1", [dict(DOTS[0], slot=5)], depth=1),
    case("empty queue", []),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for entry in CALL_LOGS:
        address, base, nargs = entry[:3]
        extra = entry[3:] + [-1, 0][len(entry) - 3:]
        emu.stubs[address] = lambda e, b=base, n=nargs, x=tuple(extra): log_call(e, b, n, *x)
    before = bytes(emu.mem)
    emu.call(c["routine"], [], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "draw_distant_object_dots", "args": [],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
