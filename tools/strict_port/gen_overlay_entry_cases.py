#!/usr/bin/env python3
"""Generate comparison cases for the overlay entry routines (overlay_main_entry, overlay_initialise,
noop_stub_2e12, overlay_init_noop) and respawn_player_at_anchor by running the ORIGINAL bytes.

The start-up cases begin from the run-writer and span tables the original initialisers build
(exported as writes, so the 16 KB of tables are not repeated as changes) and check the RNG seed,
palette maps, light vector, frame counter, view distance and the 22 host hooks. The respawn cases
use the anchor fixture's mission scene (gen_anchor_present_cases.scene_case) for the runway search
or skip it (0x1d854), with a player controller, its pose ring and definition, an empty contact
table and a pending replay object. test_overlay_entry.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_overlay_entry_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_anchor_present_cases import WORLD, scene_case  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/overlay_entry_cases.json")
ROUTINES = {0x10F2: "overlay_main_entry", 0x18B6: "overlay_initialise", 0x2DF2: "noop_stub_2e12",
            0x3712: "overlay_init_noop", 0x38D4: "respawn_player_at_anchor"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
HOST = 0x29000
PLAYER, PLAYER_OBJ, PLAYER_DEF, REPLAY_CTL, REPLAY_OBJ = 0x2A000, 0x2A700, 0x2A800, 0x2A900, 0x2AA00
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def tables() -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for init in (0x3714, 0x3246, 0x33F2, 0x3594):
        emu.call(init, [], STACK_TOP)
    out = []
    for start, end in [(0x20CEC, 0x24CEC), (0x3222, 0x3246), (0x33CE, 0x33F2), (0x3570, 0x3594)]:
        out += [[a, 4, emu.read(a, 4)] for a in range(start, end, 4)]
    return out


def startup_case(name: str, routine: str, args: list[int]) -> dict:
    w = tables() + [[a, 4, 0] for a in range(HOST, HOST + 0x400, 4)]
    w += [[0x1B5A0, 4, HOST], [0x1D864, 4, 0], [0x1D860, 4, 0], [0x1B838, 4, 999], [0x1BD84, 4, 7], [0x1BD80, 4, 7]]
    return {"name": name, "routine": BY_NAME[routine], "args": args, "writes": w}


def respawn_case(name: str, search: bool, replay: bool = False, b7: int = 0) -> dict:
    base = scene_case("scene", 1, (0, 0, 0))
    w = base["writes"] + [[a, 4, 0] for a in list(range(PLAYER, 0x2AB00, 4)) + list(range(0x1BDBC, 0x1BDBC + 0x400, 4))]
    vals = [(0x1B738, 4, PLAYER), (PLAYER, 4, PLAYER_OBJ), (PLAYER + 4, 4, PLAYER_DEF), (PLAYER_DEF + 0x42, 2, 0x1234),
            (PLAYER_DEF + 0x40, 2, 25), (PLAYER + 0x67A, 1, 0x81), (PLAYER + 0x684, 2, 0x7777), (PLAYER + 0x62A, 4, 99),
            (PLAYER_OBJ + 4, 4, 0x0F), (PLAYER_OBJ + 7, 1, 0x0F | b7), (PLAYER_OBJ + 0x3C, 4, 55), (0x1D854, 2, 0 if search else 1),
            (0x1D83C, 4, 1111), (0x1D840, 4, 222), (0x1D844, 4, -3333), (0x1D848, 4, 0x100), (0x1D84C, 4, 0x200), (0x1D850, 4, 0x300),
            (0x1B838, 4, 500), (0x1D858, 2, 4), (0x1B87C, 4, REPLAY_CTL if replay else 0), (REPLAY_CTL, 4, REPLAY_OBJ),
            (REPLAY_OBJ + 7, 1, 2), (0x1B868, 2, 3), (0x1B874, 2, 3), (0x1B872, 2, 3), (0x1B86C, 2, 3)]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return {"name": name, "routine": BY_NAME["respawn_player_at_anchor"], "args": [], "writes": w}


def build() -> list[dict]:
    return [
        startup_case("overlay_initialise(ticks)", "overlay_initialise", [0x1234567]),
        startup_case("overlay_main_entry(host, ticks)", "overlay_main_entry", [HOST, 42]),
        {"name": "noop stub", "routine": BY_NAME["noop_stub_2e12"], "args": [], "writes": []},
        {"name": "overlay init noop", "routine": BY_NAME["overlay_init_noop"], "args": [], "writes": []},
        respawn_case("respawn at the nearest runway", True),
        respawn_case("respawn at the stored anchor, replay object cleaned up", False, replay=True),
        respawn_case("respawn, object already flagged (byte +7 bit 6)", False, b7=0x40),
    ]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
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
    print(FIXTURE.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
