#!/usr/bin/env python3
"""Generate comparison cases for widen_printf_format, overlay_printf and start_mission_scene by
running the ORIGINAL bytes.

The format cases widen "%d" / "%x" (and leave "%s", "%%", a trailing "%" and plain text alone);
overlay_printf hands the widened buffer and its five arguments to the host printf (+0x262), a
logging stub that also records the first 16 bytes of the format. The mission-start cases reuse the
anchor fixture's mission scene (gen_anchor_present_cases.scene_case) for find_anchor_point (mode
0), add a scene-root table whose records name the scene objects (kind 4, so activation and
deactivation only refresh / skip), a player with its pose ring, clouds off and no sound table;
every callee runs as ported. test_mission_start.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_mission_start_cases.py  (writes the fixture JSON)
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
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/mission_start_cases.json")
ROUTINES = {0x11C6: "widen_printf_format", 0x1234: "overlay_printf", 0x3AA4: "start_mission_scene"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
TEXT, PRINTF = 0x29F00, 0x30000
CALL_LOGS = [[PRINTF, 0x38004, 6, 0, 4]]
SCENE, SCENE_TABLE, SOBJ, PLAYER, PLAYER_OBJ = 0x29000, 0x29100, 0x29400, 0x29800, 0x2A000
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def text_case(name: str, routine: str, text: bytes, extra_args: list[int] = ()) -> dict:
    w = [[a, 4, 0] for a in list(range(TEXT, TEXT + 0x80, 4)) + list(range(0x20B4C, 0x20B4C + 0x80, 4))
         + list(range(0x38000, 0x38100, 4))]
    w += [[0x1B5A0, 4, WORLD], [WORLD + 0x262, 4, PRINTF], [0x38000, 4, 0x55]]
    w += [[TEXT + k, 1, b] for k, b in enumerate(text)]
    return {"name": name, "routine": BY_NAME[routine], "args": [TEXT] + list(extra_args), "writes": w}


def mission_case(name: str, scene: int, previous: bool, frame: int = 1000) -> dict:
    base = scene_case("scene", 0, (0, 0, 0))
    w = base["writes"] + [[a, 4, 0] for a in range(SCENE, 0x2A100, 4)]
    vals = [(0x1D6FC, 4, SCENE), (SCENE + 0x30, 4, SCENE_TABLE), (0x1D700, 4, SOBJ + 0x80 if previous else 0),
            (0x1B738, 4, PLAYER), (PLAYER, 4, PLAYER_OBJ), (PLAYER + 0x20, 2, 0x1234), (PLAYER + 0x22, 2, -0x300),
            (PLAYER + 0x24, 2, 0x0777), (PLAYER_OBJ + 0x18, 4, 1000), (PLAYER_OBJ + 0x1C, 4, 200), (PLAYER_OBJ + 0x20, 4, -500),
            (0x1B838, 4, frame), (WORLD + 0xAE, 2, 0), (WORLD + 0x25E, 4, 0), (0x1C1E0, 4, 0), (0x1D858, 2, 5), (0x1D856, 2, 0)]
    for n in range(4):
        vals.append((SCENE_TABLE + 24 * n + 0x74, 4, SOBJ + 0x40 * n))
    for k in range(5):
        vals += [(SOBJ + 0x40 * k, 1, 4), (SOBJ + 0x40 * k + 0x18, 4, 300 * k), (SOBJ + 0x40 * k + 0x20, 4, -100 * k)]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return {"name": name, "routine": BY_NAME["start_mission_scene"], "args": [scene], "writes": w}


def build() -> list[dict]:
    return [
        text_case("widen: %d and %x", "widen_printf_format", b"x=%d y=%x"),
        text_case("widen: other conversions and text", "widen_printf_format", b"%s %% %c 100%"),
        text_case("widen: empty", "widen_printf_format", b""),
        text_case("printf: widened format and five arguments", "overlay_printf", b"%d,%x,%d", [1, -2, 0x30, 4, 5]),
        mission_case("mission 0, first start", 0, False),
        mission_case("mission 2, previous scene object deactivated", 2, True, frame=77),
    ]


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs, di, dn in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs, i=di, k=dn: log_call(e, b, n, i, k)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        entry = {"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if ROUTINES[c["routine"]] != "start_mission_scene":
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
