#!/usr/bin/env python3
"""Generate comparison cases for update_game_sounds by running the ORIGINAL bytes.

Each case sets the view mode, the one-frame sound flags, the explosion timers, the followed
aircraft (gear, flaps, stalled engine, rpm) and the engine-sound state. The host sound routines
(+0x2aa play, +0x2b2 rate, +0x2b6 is playing, +0x2ba stop channel 1, +0x2be stop channel) log
their calls on both sides and return the long just before their log (the case's "playing"
answer). play_game_sound / stop_game_sound / stop_all_sound_channels run for real.
test_game_sounds.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_game_sound_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/game_sound_cases.json")
ROUTINE = 0x96D4                                    # runtime address (file 0x96f4)
PLAY, RATE, IS_PLAYING, STOP1, STOP = 0x3F400, 0x3F404, 0x3F408, 0x3F40C, 0x3F410
CALL_LOGS = [[PLAY, 0x3F500, 6], [RATE, 0x3F700, 1], [IS_PLAYING, 0x3F800, 1], [STOP1, 0x3F900, 1], [STOP, 0x3FA00, 1]]
WORLD, TABLE, RECORDS = 0x23000, 0x24000, 0x24200
PLAYER, OTHER = 0x25000, 0x25800
FLAGS = {"wheel": 0x1B856, "gun": 0x1B852, "ditch": 0x1B850, "grass": 0x1B854, "gear_alt": 0x1B846, "ugh": 0x1B844,
         "hit": 0x1B842, "ok": 0x1B83C, "refused": 0x1B83E, "gear_moving": 0x1B84E, "flaps_moving": 0x1B84C}


def case(name: str, view: int = 0, sound: int = 1, engine: int = 1, playing: int = 0, channel1: int = 0, choice: int = 3,
         near: int = 0, far: int = 0, flags: tuple[str, ...] = (), ctl: dict | None = None, other: dict | None = None,
         missing: tuple[int, ...] = ()) -> dict:
    w = [(a, 4, 0) for start, end in [(WORLD, WORLD + 0x300), (TABLE, TABLE + 0x190), (RECORDS, RECORDS + 0x400),
                                      (PLAYER, PLAYER + 0x700), (OTHER, OTHER + 0x700)] for a in range(start, end, 4)]
    for _, log_base, _ in CALL_LOGS:
        w += [(log_base - 4, 4, playing), (log_base, 4, 0)]
    w += [(0x1B5A0, 4, WORLD), (WORLD + 0x9A, 2, sound), (WORLD + 0x9C, 2, engine), (WORLD + 0x25E, 4, TABLE),
          (WORLD + 0x2AA, 4, PLAY), (WORLD + 0x2B2, 4, RATE), (WORLD + 0x2B6, 4, IS_PLAYING), (WORLD + 0x2BA, 4, STOP1),
          (WORLD + 0x2BE, 4, STOP), (0x1D858, 2, view), (0x24D10, 4, channel1), (0x24D14, 4, choice),
          (0x1B84A, 2, near), (0x1B848, 2, far), (0x1B738, 4, PLAYER), (0x1B888, 4, OTHER)]
    w += [(a, 2, 0) for a in FLAGS.values()] + [(FLAGS[f], 2, 1) for f in flags]
    for i in range(16):
        rec = RECORDS + 0x20 * i
        w += [(rec + 4, 4, 0x1000 + 0x100 * i), (rec + 0xC, 4, 0x200 + i), (rec + 0x10, 4, 0x800 + i)]
    for sound_id in range(14):
        if sound_id not in missing:
            w.append((TABLE + 4 * sound_id, 4, RECORDS + 0x20 * sound_id))
    w.append((TABLE + 0x1C, 4, RECORDS + 0x20 * 7))
    for base, fields in ((PLAYER, ctl or {}), (OTHER, other or {})):
        w += [(base + 0x679, 1, fields.get("gear", 0)), (base + 0x67B, 1, fields.get("flaps", 0)),
              (base + 0x685, 1, fields.get("b685", 0)), (base + 0x669, 1, fields.get("stalled", 0)),
              (base + 0x66A, 4, fields.get("rpm", 0))]
    return {"name": name, "routine": ROUTINE, "args": [], "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in w]}


ALL = ("wheel", "gun", "ditch", "grass", "gear_alt", "ugh", "hit", "ok", "refused")
CASES = [
    case("sound off: only the flags clear", sound=0, near=3, far=2, flags=ALL),
    case("view 3 stops every channel", view=3, playing=1, near=1),
    case("view 4 stops every channel (idle)", view=4),
    case("view 9 also stops every channel", view=9, playing=1, far=4),
    case("view 8 plays the pending explosions", view=8, near=5, far=2),
    case("view 8, channel 1 busy with sound 3", view=8, playing=1, channel1=3, near=5, far=2),
    case("view 0 quiet, engine idle rpm", ctl={"rpm": 5000}),
    case("view 0 all flags, channel 1 free", flags=ALL, near=2, ctl={"rpm": 20000}),
    case("view 1 gun / wheel / grass with priority", view=1, flags=("gun", "wheel", "grass"), channel1=6, playing=1,
         ctl={"rpm": 12000}),
    case("view 2 near explosion becomes distant", view=2, near=4, ctl={"rpm": 40000}),
    case("view 5 gear moving", view=5, ctl={"gear": 10}),
    case("gear at 0x2d", ctl={"gear": 0x2D}),
    case("gear negative, held by +0x685", ctl={"gear": -5, "b685": 0x20}),
    case("flaps moving", ctl={"flaps": -3}),
    case("flaps at 0xf", ctl={"flaps": 0xF}),
    case("flaps sound stops when channel 1 holds it", channel1=7, playing=1),
    case("ditch sound stops when channel 1 holds 0xb", channel1=0xB, playing=1),
    case("stalled engine, channel 0 idle", ctl={"stalled": 1, "rpm": 1234}),
    case("stalled engine, already chosen and playing", playing=1, choice=0, ctl={"stalled": 1, "rpm": -77}),
    case("stalled engine without record 0", playing=1, ctl={"stalled": 1}, missing=(0,)),
    case("high rpm, same choice playing", playing=1, choice=10, ctl={"rpm": 30001}),
    case("high rpm, changed choice", playing=1, choice=0, ctl={"rpm": 0x40000000}),
    case("rpm exactly 10000 stops channel 0", playing=1, ctl={"rpm": 10000}),
    case("negative rpm stops channel 0 (idle)", ctl={"rpm": -50000}),
    case("engine sound off", engine=0, playing=1, ctl={"rpm": 30000}),
    case("channel 1 holds voice 1: engine stops", playing=1, channel1=1, ctl={"rpm": 30000}),
    case("channel 1 holds voice 4, idle", channel1=4, ctl={"rpm": 30000}),
    case("view 7 follows designated_entity_2", view=7, flags=("gun",), near=2,
         ctl={"gear": 10, "stalled": 1}, other={"rpm": 25000, "gear": 3}),
    case("view 7 stalled designated aircraft", view=7, playing=1, other={"stalled": 1, "rpm": 100}),
    case("view 7 keeps last frame's gear flag", view=7, flags=("gear_moving",), other={"rpm": 100}),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    emu.call(c["routine"], [], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "update_game_sounds", "args": [],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
