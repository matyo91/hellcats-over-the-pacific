#!/usr/bin/env python3
"""Generate comparison cases for overlay_init_template_pointer_tables and init_mission_object_tables
by running the ORIGINAL bytes.

The template copies come from the built-in records in the image (0x1a790..); the heap is a real
one (gen_object_list_cases.Setup) with the small size classes 2..5 seeded with free 32-byte
blocks, so no host sbrk is needed. The mission scene is a group root descriptor (kind 3, no class
factory) with eight group children (no grandchildren), so instantiation, activation and the vertex
copies all run as ported. Host word +0x90 picks child 3 instead of 2 as mission_child2or3.
test_mission_tables.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_mission_tables_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/mission_tables_cases.json")
ROUTINES = {0x34: "overlay_init_template_pointer_tables", 0x16C2: "init_mission_object_tables"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, DESC_BASE, SMALL = 0x27000, 0x28000, 0x2E000
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)
CHILDREN = 8


def case(name: str, routine: str, variant: int = 0) -> dict:
    s = Setup()
    s.w(HEAP_BLOCK, 4, 0x1C00)
    for a in list(range(WORLD, WORLD + 0x200, 4)) + list(range(DESC_BASE, DESC_BASE + 0x800, 4)) \
            + list(range(0x1B524, 0x1B524 + 0x80, 4)) + list(range(0x1BC28, 0x1BC40, 4)):
        s.w(a, 4, 0)
    for cls in range(2, 6):
        head = SMALL + 0x400 * (cls - 2)
        for k in range(30):
            block = head + 0x20 * k
            s.w(block, 4, block + 0x20 if k < 29 else 0)
            for off in range(4, 0x20, 4):
                s.w(block + off, 4, 0)
        s.w(0x20C64 + 4 * cls, 4, head)
    root = DESC_BASE
    for addr, size, v in [(0x1B5A0, 4, WORLD), (WORLD + 0x8C, 4, DESC_BASE), (WORLD + 0x90, 2, variant), (0x1B838, 4, 77),
                          (root, 1, 3), (root + 1, 1, 0), (root + 2, 4, 1000), (root + 0x16, 2, 4), (root + 0x18, 2, CHILDREN),
                          (0x1B734, 4, 9), (0x1C1E0, 4, 0)]:
        s.w(addr, size, v)
    for k in range(CHILDREN):
        rec = root + 0x1A + 24 * k
        child = 0x400 + 0x40 * k
        for off, size, v in [(2, 2, 0x100 * k), (8, 4, 50 * k), (0x14, 4, child)]:
            s.w(rec + off, size, v)
        for off, size, v in [(0, 1, 3), (1, 1, 0), (2, 4, 10 * k), (6, 4, 20 * k), (0xA, 4, -5 * k), (0x16, 2, 0), (0x18, 2, 0)]:
            s.w(DESC_BASE + child + off, size, v)
    return {"name": name, "routine": BY_NAME[routine], "args": [], "writes": s.writes()}


def build() -> list[dict]:
    return [
        case("template pointer tables", "overlay_init_template_pointer_tables"),
        case("mission object tables", "init_mission_object_tables"),
        case("mission object tables, host +0x90 == 2", "init_mission_object_tables", variant=2),
    ]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {}, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
