#!/usr/bin/env python3
"""Generate comparison cases for the view-distance and radar routines by running the ORIGINAL bytes.

Covers set_view_distance, cycle_view_distance, reset_radar_tracks, update_radar_range_buttons and
update_radar_scope. Their host and depth routines (host +0x28e button draw, host +0x272 line,
*0x1da90 blip erase, *0x1da94 blip draw) are pointed at fake addresses whose calls are logged on
both sides (long count, then the arguments of each call), so call order and arguments are
compared with the memory. test_radar.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_radar_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/radar_cases.json")
SET_VIEW_DISTANCE = 0x176FA      # runtime addresses (file - 0x20)
CYCLE_VIEW_DISTANCE = 0x17716
RESET_RADAR_TRACKS = 0x1774A
RANGE_BUTTONS = 0x17A6C
RADAR_SCOPE = 0x17B48
DRAW_BUTTON, DRAW_LINE, ERASE_BLIP, DRAW_BLIP = 0x3F400, 0x3F404, 0x3F408, 0x3F40C
CALL_LOGS = [[DRAW_BUTTON, 0x3F500, 2], [DRAW_LINE, 0x3F600, 5], [ERASE_BLIP, 0x3F800, 2], [DRAW_BLIP, 0x3F900, 2]]
WORLD = 0x23000
PLAYER_CTL = 0x24000
PLAYER = 0x24100
TRACKS_A = 0x24200              # radar_tracks (this frame)
TRACKS_B = 0x24300              # radar_drawn_tracks (last frame)


def base() -> list[list[int]]:
    w: list[list[int]] = []
    for start, end in [(WORLD, WORLD + 0x300), (PLAYER_CTL, PLAYER_CTL + 0x40), (PLAYER, PLAYER + 0x40),
                       (TRACKS_A, TRACKS_A + 0x100), (TRACKS_B, TRACKS_B + 0x100)]:
        for addr in range(start, end, 4):
            w.append([addr, 4, 0])
    for log_base in (0x3F500, 0x3F600, 0x3F800, 0x3F900):
        w.append([log_base, 4, 0])
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (0x1B738, 4, PLAYER_CTL), (PLAYER_CTL, 4, PLAYER),
        (PLAYER + 0x18, 4, 100000), (PLAYER + 0x20, 4, (-50000) & 0xFFFFFFFF), (0x1D80E, 2, 0x0600),
        (WORLD + 0x28E, 4, DRAW_BUTTON), (WORLD + 0x272, 4, DRAW_LINE), (0x1DA90, 4, ERASE_BLIP), (0x1DA94, 4, DRAW_BLIP),
        (WORLD + 0x1DA, 2, 7), (WORLD + 0x1DC, 2, 3), (WORLD + 0xE4, 2, 0xFF),
        (WORLD + 0x1E0, 2, 400), (WORLD + 0x1E4, 2, 480), (WORLD + 0x1DE, 2, 200), (WORLD + 0x1E2, 2, 280),
        (WORLD + 0x1E8, 2, 440), (WORLD + 0x1EA, 2, 240),
        (0x2666E, 4, 0), (0x2666A, 4, 0xCE40), (0x26666, 4, 0x19C80), (0x26664, 2, 0x52),
        (0x1B51C, 4, TRACKS_A), (0x1B520, 4, TRACKS_B), (0x26672, 4, 0), (0x26676, 4, 0),
    ]:
        w.append([addr, size, value])
    return w


def tracks(table: int, entries: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    w = []
    for i, (x, z, drawn) in enumerate(entries):
        w += [(table + 0x14 * i, 4, x & 0xFFFFFFFF), (table + 0x14 * i + 4, 4, z & 0xFFFFFFFF),
              (table + 0x14 * i + 0x10, 4, drawn)]
    return w


CURRENT = [(100000 + 1500, -50000 + 800, 0), (100000 - 2600, -50000 - 1900, 0), (100000 + 40000, -50000, 0),
           (100000, -50000 + 3200, 0)]


def case(name: str, routine: int, args: list[int], extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": base() + [list(e) for e in extra]}


CASES = [
    case("set_view_distance 0x26ac0", SET_VIEW_DISTANCE, [0x26AC0]),
    case("set_view_distance negative (asl wraps)", SET_VIEW_DISTANCE, [0xC0000001]),
    case("cycle: 0xce40 -> 0xc15c0", CYCLE_VIEW_DISTANCE, []),
    case("cycle: 0xc15c0 -> 0x26ac0", CYCLE_VIEW_DISTANCE, [], [(0x2666A, 4, 0xC15C0)]),
    case("cycle: 0x26ac0 -> 0xce40", CYCLE_VIEW_DISTANCE, [], [(0x2666A, 4, 0x26AC0)]),
    case("cycle: other -> 0xce40", CYCLE_VIEW_DISTANCE, [], [(0x2666A, 4, 1234)]),
    case("reset radar tracks (flag is a long)", RESET_RADAR_TRACKS, [], [(0x2666E, 4, 0x7F7F7F7F), (0x26672, 4, 5), (0x26676, 4, 6)]),
    case("range buttons: unchanged, nothing", RANGE_BUTTONS, []),
    case("range buttons: 0xce40 lit", RANGE_BUTTONS, [], [(0x2666E, 4, 1)]),
    case("range buttons: 0x26ac0 lit", RANGE_BUTTONS, [], [(0x2666E, 4, 1), (0x2666A, 4, 0x26AC0)]),
    case("range buttons: 0xc15c0 lit, odd scope width", RANGE_BUTTONS, [], [(0x2666E, 4, 1), (0x2666A, 4, 0xC15C0), (WORLD + 0x1E4, 2, 477)]),
    case("range buttons: reversed scope (negative width)", RANGE_BUTTONS, [], [(0x2666E, 4, 1), (WORLD + 0x1E4, 2, 300)]),
    case("scope, colour: erase 2 of 3 old blips, draw new tracks", RADAR_SCOPE, [],
         tracks(TRACKS_B, [(410, 210, 1), (0, 0, 0), (470, 270, 1)]) + [(0x26672, 4, 3), (0x26676, 4, 4)] + tracks(TRACKS_A, CURRENT)),
    case("scope, black and white: two lines per visible track", RADAR_SCOPE, [],
         [(WORLD + 0x9E, 2, 1), (0x26676, 4, 4)] + tracks(TRACKS_A, CURRENT)),
    case("scope: no tracks, lists swap", RADAR_SCOPE, [], [(0x26672, 4, 2)] + tracks(TRACKS_B, [(1, 2, 1), (3, 4, 1)])),
    case("scope: heading 0x2a00, larger scale", RADAR_SCOPE, [],
         [(0x1D80E, 2, 0x2A00), (0x26664, 2, 0x200), (0x26676, 4, 4)] + tracks(TRACKS_A, CURRENT)),
]


def log_call(emu: Emulator, base: int, nargs: int, deref_index: int = -1, deref_n: int = 0,
             deref2_index: int = -1, deref2_n: int = 0) -> int:
    """A logging stub: append the call's long arguments (plus deref_n longs read at argument
    deref_index, and deref2_n at deref2_index, for buffers passed by address) to the log at base
    (long count first) and return the long at base - 4 (0 unless a case sets it)."""
    args = [emu.read(emu.a[7] + 4 * i, 4) for i in range(nargs)]
    values = list(args)
    values += [emu.read((args[deref_index] + 4 * k) & 0xFFFFFFFF, 4) for k in range(deref_n)]
    values += [emu.read((args[deref2_index] + 4 * k) & 0xFFFFFFFF, 4) for k in range(deref2_n)]
    count = emu.read(base, 4)
    for i, value in enumerate(values):
        emu.write(base + 4 + (count * len(values) + i) * 4, 4, value)
    emu.write(base, 4, count + 1)
    return emu.read(base - 4, 4)


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], c["args"], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes, _d0 = run_case(c)
        zero, writes = compact(c["writes"])
        method = {SET_VIEW_DISTANCE: "set_view_distance", CYCLE_VIEW_DISTANCE: "cycle_view_distance",
                  RESET_RADAR_TRACKS: "reset_radar_tracks", RANGE_BUTTONS: "update_radar_range_buttons",
                  RADAR_SCOPE: "update_radar_scope"}[c["routine"]]
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": method, "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
