#!/usr/bin/env python3
"""Generate comparison cases for overlay_patch_template_u16_pair, reset_palette_owner_tables,
init_depth8_colour_state and init_depth4_colour_state by running the ORIGINAL bytes.

The palette owner tables live on a real heap (gen_object_list_cases.Setup, with a larger free
block): cases start with no tables and with three allocated tables to free, with and without the
multi-screen flag (host word +0xb4). The depth-4 set-up builds its 125-entry tables from three
seeded 8-word source tables (one missing in one case). test_colour_setup.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_colour_setup_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import HEAP_BLOCK, Setup  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/colour_setup_cases.json")
ROUTINES = {0x0000: "overlay_patch_template_u16_pair", 0x1274: "reset_palette_owner_tables",
            0x12E0: "init_depth8_colour_state", 0x12FC: "init_depth4_colour_state"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, COLOURS, SOURCES = 0x27000, 0x27400, 0x27800


def case(name: str, routine: str, args: list[int] = (), multi: int = 0, existing: bool = False,
         missing: int | None = None, seed: int = 0) -> dict:
    rnd = random.Random(seed)
    s = Setup()
    s.w(HEAP_BLOCK, 4, 0x1C00)
    for a in range(WORLD, 0x27A00, 4):
        s.w(a, 4, 0)
    for addr, size, v in [(0x1B5A0, 4, WORLD), (WORLD + 0xB4, 2, multi), (WORLD + 0x34, 4, COLOURS),
                          (COLOURS + 0x1A0, 2, 0x5A5A), (COLOURS + 0x10, 2, 0x0C0C), (0x1DA8A, 2, 7),
                          (0x1DA70, 4, 0), (0x1DA74, 4, 0), (0x1DA78, 4, 0), (0x1DA7C, 4, 0x1234)]:
        s.w(addr, size, v)
    if existing:
        for k in range(3):
            s.w(0x1DA70 + 4 * k, 4, s.alloc(0x40))
    for n in range(1, 4):
        if n != missing:
            s.w(WORLD + 0x16 * n + 0x1E, 4, SOURCES + 0x20 * n)
            for k in range(8):
                s.w(SOURCES + 0x20 * n + 2 * k, 2, rnd.choice([rnd.randint(0, 15), rnd.randint(-3, 15)]))
    return {"name": name, "routine": BY_NAME[routine], "args": list(args), "writes": s.writes()}


def build() -> list[dict]:
    return [
        case("patch template words", "overlay_patch_template_u16_pair", [0xABCD1234]),
        case("palette tables: none yet, single screen", "reset_palette_owner_tables"),
        case("palette tables: three freed, multi-screen", "reset_palette_owner_tables", multi=1, existing=True),
        case("palette tables: three freed, single screen", "reset_palette_owner_tables", existing=True),
        case("depth 8 set-up", "init_depth8_colour_state", existing=True),
        case("depth 4 set-up, single screen", "init_depth4_colour_state", seed=1),
        case("depth 4 set-up, multi-screen", "init_depth4_colour_state", multi=1, seed=2),
        case("depth 4 set-up, multi-screen, screen 2 without a source", "init_depth4_colour_state", multi=1, missing=2, seed=3),
    ]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
