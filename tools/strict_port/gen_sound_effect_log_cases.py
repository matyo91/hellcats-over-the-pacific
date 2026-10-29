#!/usr/bin/env python3
"""Generate comparison cases for the effect log and sound routines by running the ORIGINAL bytes.

Covers replay_logged_effects, mark_effect_log_end, stop_all_sound_channels, play_game_sound and
stop_game_sound. The host sound routines (+0x2aa play, +0x2b6 is playing, +0x2be stop channel,
+0x2ba stop channel 1) log their calls on both sides and return the long just before their log;
the effect pool spawn is stubbed (arguments recorded, returns 0). test_sound_effect_log.gd
replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_sound_effect_log_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import (  # noqa: E402
    ARGS_POOL, MEMORY_SIZE, OVERLAY_RNG_INIT, SPAWN_MISSION_POOL_OBJECT, STACK_GUARD, STACK_TOP, record_args)
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/sound_effect_log_cases.json")
PLAY, IS_PLAYING, STOP, STOP1 = 0x3F400, 0x3F404, 0x3F408, 0x3F40C
CALL_LOGS = [[PLAY, 0x3F500, 6], [IS_PLAYING, 0x3F700, 1], [STOP, 0x3F800, 1], [STOP1, 0x3F900, 1]]
METHODS = {0x11B76: "replay_logged_effects", 0x11C0C: "mark_effect_log_end", 0x9530: "stop_all_sound_channels",
           0x958C: "play_game_sound", 0x968E: "stop_game_sound"}
REPLAY, MARK_END, STOP_ALL, PLAY_SOUND, STOP_SOUND = METHODS
WORLD = 0x23000
TABLE = 0x24000                  # sound table: record pointer per id (0..99), +0x1c used by id 100
RECORDS = 0x24200                # records of 0x20 bytes: +4 size, +0xc / +0x10 loop points
LOG = 0x260EE
FRAME = 1000


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(WORLD, WORLD + 0x300), (TABLE, TABLE + 0x190), (RECORDS, RECORDS + 0x400),
                       (LOG, LOG + 16 * 0x18)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    for log_base in (0x3F500, 0x3F700, 0x3F800, 0x3F900):
        w += [[log_base - 4, 4, 0], [log_base, 4, 0]]
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (WORLD + 0x25E, 4, TABLE), (WORLD + 0x2AA, 4, PLAY), (WORLD + 0x2B6, 4, IS_PLAYING),
        (WORLD + 0x2BE, 4, STOP), (WORLD + 0x2BA, 4, STOP1), (0x24D10, 4, 0), (0x24D14, 4, 3),
        (0x1B870, 2, 0), (0x1B838, 4, FRAME), (0x260EC, 2, 0), (0x1D858, 2, 1),
    ]:
        w.append([addr, size, value])
    for i in range(16):
        rec = RECORDS + 0x20 * i
        w += [[rec + 4, 4, 0x1000 + 0x100 * i], [rec + 0xC, 4, 0x200 + i], [rec + 0x10, 4, 0x800 + i]]
    for sound_id in range(14):
        w.append([TABLE + 4 * sound_id, 4, RECORDS + 0x20 * sound_id])
    w.append([TABLE + 4 * 99, 4, RECORDS + 0x20 * 14])
    return w


def log_entry(index: int, kind: int, w34: int, w36: int, b38: int, debris: int, xyz: tuple[int, int, int], frame: int) -> list[tuple[int, int, int]]:
    e = LOG + 0x18 * index
    return [(e, 1, kind), (e + 1, 1, b38 & 0xFF), (e + 2, 1, debris & 0xFF), (e + 4, 2, w34 & 0xFFFF), (e + 6, 2, w36 & 0xFFFF),
            (e + 8, 4, xyz[0] & 0xFFFFFFFF), (e + 0xC, 4, xyz[1] & 0xFFFFFFFF), (e + 0x10, 4, xyz[2] & 0xFFFFFFFF), (e + 0x14, 4, frame)]


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": base() + [list(e) for e in extra]}


LOGGED = (log_entry(3, 2, 200, 5, 1, 1, (1000, 2000, 3000), FRAME - 2) + log_entry(4, 0, 0x96, 0x2D, 0xFF, 0, (-5, 6, 7), FRAME)
          + log_entry(5, 3, 0x96, 0x2D, 1, 0, (8, 9, 10), FRAME) + log_entry(6, 1, 1, 1, 1, 1, (0, 0, 0), FRAME + 1)
          + [(0x260EC, 2, 3)])
CASES = [
    case("replay: skip an old entry, respawn two of this frame, stop at a later one", REPLAY, [], LOGGED),
    case("replay: stops at an end mark, replay state restored", REPLAY, [], [(0x1B870, 2, 2), (0x260EC, 2, 15)]
         + log_entry(15, 2, 1, 2, 3, 0, (1, 2, 3), FRAME) + log_entry(0, 0, 0, 0, 0, 0, (0, 0, 0), 0x7FFFFFFF)),
    case("mark the log end at index 15 (wraps to 0)", MARK_END, [], [(0x260EC, 2, 15)]),
    case("mark the log end at index 4", MARK_END, [], [(0x260EC, 2, 4)]),
    case("stop all: both channels playing", STOP_ALL, [], [(0x3F6FC, 4, 1)]),
    case("stop all: nothing playing", STOP_ALL, []),
    case("stop all: no sound table", STOP_ALL, [], [(WORLD + 0x25E, 4, 0)]),
]
for sound_id in [0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 99]:
    CASES.append(case(f"play sound {sound_id}", PLAY_SOUND, [sound_id]))
CASES += [
    case("play sound 50: no record", PLAY_SOUND, [50]),
    case("play sound 100: record at table +0x1c, offset 0x48c0", PLAY_SOUND, [100]),
    case("play sound 100 without a record: claims the channel", PLAY_SOUND, [100], [(TABLE + 0x1C, 4, 0)]),
    case("play sound 6 while 4 plays: refused", PLAY_SOUND, [6], [(0x24D10, 4, 4)]),
    case("play sound 3 while 4 plays: takes over", PLAY_SOUND, [3], [(0x24D10, 4, 4)]),
    case("play sound -3 (negative id)", PLAY_SOUND, [0xFFFFFFFD], [(TABLE - 12, 4, RECORDS + 0x20 * 2)]),
    case("stop sound 7 while 7 plays", STOP_SOUND, [7], [(0x24D10, 4, 7)]),
    case("stop sound 7 while 6 plays", STOP_SOUND, [7], [(0x24D10, 4, 6)]),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    emu.stubs[SPAWN_MISSION_POOL_OBJECT] = lambda e: record_args(e, ARGS_POOL, 8)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD),
           "stubs": {"spawn_mission_pool_object": ARGS_POOL}, "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]],
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
