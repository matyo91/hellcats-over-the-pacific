#!/usr/bin/env python3
"""Generate comparison cases for find_anchor_point (with anchor_point_visitor), the display
presenters (present_spans_to_window, present_bw_frame) and load_player_fuel_and_bombs by running
the ORIGINAL bytes.

The anchor cases build a small mission scene (a group with a sub-group and two leaves, as in
test_scene_traversal.gd) whose faces include runways (type nibble 0x70) above and below ground and
a leaf of kind 1; mode 1 picks the nearest runway, mode 0 the shallowest kind-1 node and its
record's attitude. The presenter cases run on a real heap with the span filler and the host copy /
1-bit routines logged, at depths 4 and 8 and for row counts that need one or several chunks. The
fuel cases vary the capacity, fuel percentage and bombs. test_anchor_present.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_anchor_present_cases.py  (writes the fixture JSON)
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
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/anchor_present_cases.json")
ROUTINES = {0xD4A: "find_anchor_point", 0xD278: "present_spans_to_window", 0xD32C: "present_bw_frame",
            0x3DA: "load_player_fuel_and_bombs"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, BASE, GROUP, SUBGROUP, LEAF_1, LEAF_2, ANCHOR = 0x27000, 0x28000, 0x28100, 0x28200, 0x28300, 0x28500, 0x27F00
FILLER, HOST_COPY, HOST_BW = 0x30000, 0x30100, 0x30200
CALL_LOGS = [[FILLER, 0x38004, 5], [HOST_COPY, 0x38404, 4], [HOST_BW, 0x38804, 3]]
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def leaf(w: list, addr: int, kind: int, verts: list[tuple[int, int, int]], faces: list[tuple[int, list[int]]]) -> None:
    w += [(addr, 1, 2), (addr + 1, 1, kind), (addr + 0x18, 2, 0), (addr + 0x1A, 2, len(verts)), (addr + 0x1E, 2, len(faces))]
    for k, (x, y, z) in enumerate(verts):
        w += [(addr + 0x22 + 12 * k, 4, x), (addr + 0x26 + 12 * k, 4, y), (addr + 0x2A + 12 * k, 4, z)]
    face = addr + 0x22 + 12 * len(verts) + 12 * len(faces)
    for ftype, idx in faces:
        w += [(face + 8, 1, len(idx)), (face + 9, 1, ftype)]
        for i, v in enumerate(idx):
            w.append((face + 0xE + 2 * i, 2, v))
        face += 0xE + 2 * len(idx)


def scene_case(name: str, mode: int, ref: tuple[int, int, int], leaf1_kind: int = 0) -> dict:
    w: list = [(a, 4, 0) for a in range(WORLD, 0x28800, 4)]
    w += [(0x1B5A0, 4, WORLD), (WORLD + 0x8C, 4, BASE), (WORLD + 0x90, 2, 1), (BASE + 0x18 + 0x8E, 4, GROUP - BASE),
          (GROUP, 1, 3), (GROUP + 2, 4, 0), (GROUP + 0x18, 2, 2), (GROUP + 0x1A + 0x14, 4, SUBGROUP - BASE),
          (GROUP + 0x1A + 0x18 + 0x14, 4, LEAF_1 - BASE), (SUBGROUP, 1, 3), (SUBGROUP + 0x18, 2, 1),
          (SUBGROUP + 0x1A + 0x14, 4, LEAF_2 - BASE)]
    rec1, rec2 = GROUP + 0x1A + 0x18, SUBGROUP + 0x1A
    w += [(rec1 + 2, 2, 0x100), (rec1 + 4, 2, -0x80), (rec1 + 6, 2, 0x40), (rec1 + 8, 4, 500), (rec1 + 0xC, 4, 0), (rec1 + 0x10, 4, -300),
          (rec2 + 2, 2, 0), (rec2 + 4, 2, 0x200), (rec2 + 6, 2, 0), (rec2 + 8, 4, -2000), (rec2 + 0xC, 4, 0), (rec2 + 0x10, 4, 1500)]
    leaf(w, LEAF_1, leaf1_kind, [(0, 0, 0), (100, -5, 40), (-60, 0, 90), (20, 30, -50)],
         [(0x70, [0, 1, 2]), (0x70, [3, 0, 1]), (0x20, [1, 2, 3])])
    leaf(w, LEAF_2, 1, [(10, -2, 10), (300, 0, 0), (0, 0, 300)], [(0x70, [0, 1, 2]), (0x75, [1, 2, 0])])
    w += [(ANCHOR + 4 * k, 4, v) for k, v in enumerate(ref)] + [(ANCHOR + 0x18, 2, 0)]
    return {"name": name, "routine": BY_NAME["find_anchor_point"], "args": [ANCHOR, mode],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in w]}


def present_case(name: str, routine: str, args: list[int], depth: int, width: int) -> dict:
    s = Setup()
    s.w(HEAP_BLOCK, 4, 0x1C00)
    for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(0x38000, 0x38C00, 4)) + list(range(0x2A000, 0x2A800, 4)):
        s.w(a, 4, 0)
    for addr, size, v in [(0x1B5A0, 4, WORLD), (WORLD + 0x296, 4, HOST_COPY), (WORLD + 0x80, 4, HOST_BW), (0x20AC0, 4, FILLER),
                          (0x1B826, 2, depth), (0x1B82A, 2, width), (0x1B828, 2, 6), (0x1DAA0, 2, 0x4242),
                          (0x1B778, 4, 0x2A000), (0x1B77C, 4, 0x2A200), (0x1B780, 4, 0)]:
        s.w(addr, size, v)
    return {"name": name, "routine": BY_NAME[routine], "args": args, "writes": s.writes()}


def fuel_case(name: str, capacity: int, percent: int, bombs: int) -> dict:
    player, definition = 0x27100, 0x27200
    w = [(a, 4, 0) for a in range(WORLD, 0x27800, 4)]
    w += [(0x1B5A0, 4, WORLD), (0x1B738, 4, player), (player + 4, 4, definition), (definition + 0x1C, 2, capacity),
          (definition + 0x1A, 2, 0x150), (WORLD + 0xB6, 2, percent), (WORLD + 0xB9, 1, bombs), (player + 0x684, 2, 0xFFFF),
          (player + 0x674, 1, 9), (player + 0x680, 2, 0x55), (0x1B73C, 2, 0)]
    return {"name": name, "routine": BY_NAME["load_player_fuel_and_bombs"], "args": [],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in w]}


def build() -> list[dict]:
    return [
        scene_case("anchor: nearest runway (mode 1)", 1, (0, 0, 0)),
        scene_case("anchor: nearest runway from far away (mode 1)", 1, (-3000, 50, 2000)),
        scene_case("anchor: shallowest kind-1 node (mode 0)", 0, (0, 0, 0)),
        scene_case("anchor: kind-1 leaf at both depths (mode 0)", 0, (0, 0, 0), leaf1_kind=1),
        present_case("present spans: depth 8, three chunks", "present_spans_to_window", [0x2B000, 0x2B800, 120, 0, 0, 1], 8, 160),
        present_case("present spans: depth 4, one chunk", "present_spans_to_window", [0x2B000, 0x2B800, 20, 0, 0, 2], 4, 160),
        present_case("present spans: all slots reset", "present_spans_to_window", [0x2B000, 0x2B800, 51, 7, 9, 0], 8, 200),
        present_case("present 1-bit frame: depth 1", "present_bw_frame", [0x1234], 1, 512),
        present_case("present 1-bit frame: depth 4", "present_bw_frame", [0x99], 4, 150),
        fuel_case("fuel: full tanks, two bombs", 0x3D, 100, 2),
        fuel_case("fuel: half tanks, no bombs", 0x50, 50, 0),
        fuel_case("fuel: empty tanks get one", 0x10, 5, 1),
        fuel_case("fuel: negative product", 0x40, -30, -1),
    ]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
