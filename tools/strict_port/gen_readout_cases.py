#!/usr/bin/env python3
"""Generate comparison cases for update_view_readouts_and_overlays, mark_view_overlays_drawn and
c_strlen by running the ORIGINAL bytes.

The readout half prints the four numeric readouts (altitude, speed, heading, climb) through the
host text routine (host +0x27a), a logging stub that also records the first three longs of the
text it receives. The drawn-panels half runs the sky / ground (with its geometry cached, so no
row buffers are reallocated), heading tape, panel frame lines (into a small depth-8 screen) and
instruments as ported, over the gauge fixture's host layout (gen_gauge_cases.base) with an empty
radar; the host routines they reach are logging stubs. test_readouts.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_readout_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_gauge_cases import CALL_LOGS as GAUGE_LOGS, PLAYER, PLAYER_OBJ, WORLD, base  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/readout_cases.json")
ROUTINES = {0xCFEC: "update_view_readouts_and_overlays", 0xD25C: "mark_view_overlays_drawn", 0x1A73E: "c_strlen"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
TEXT_OUT, SUBJECT, SUBJECT_OBJ, STRINGS = 0x30500, 0x27E00, 0x27F00, 0x28000
CURSOR = 0x30600
SPAN_FILLER = 0x30700
CALL_LOGS = GAUGE_LOGS + [[TEXT_OUT, 0x39A04, 6, 0, 3], [SPAN_FILLER, 0x39E04, 5], [CURSOR, 0x39E84, 0]]
FRAME = 0x2A000                                   # screen bytes the panel frame lines draw into


def case(name: str, routine: str, args: list[int] = (), extra: list[tuple[int, int, int]] = (), panels: int = 0,
         drawn: int = 0, host_line: int = 0) -> dict:
    w = base(drawn, host_line)
    w += [[a, 4, 0] for a in list(range(0x39A00, 0x3A000, 4)) + list(range(SUBJECT, STRINGS + 0x100, 4))]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in [
        (WORLD + 0x27A, 4, TEXT_OUT), (WORLD + 0x2C2, 4, CURSOR), (0x20AC0, 4, SPAN_FILLER), (0x20AD8, 4, 0x2B000),
        (0x20AD4, 4, 0x2B400), (0x25F34, 4, 0), (0x25F38, 4, 0), (0x25F3C, 4, 0), (0x25F40, 4, 0), (0x25F44, 4, 0),
        (0x1B828, 2, 80), (0x20B2A, 2, 64), (0x20B2C, 2, 40), (0x1BD90, 4, 3), (0x1BD94, 4, 0), (0x1BD98, 4, 0),
        (0x1BD9C, 4, 0), (0x1BDA0, 4, 0), (0x25F48, 2, 0), (0x20AE4, 2, panels), (0x1D858, 2, 0), (0x1B888, 4, SUBJECT), (SUBJECT, 4, SUBJECT_OBJ),
        (0x20AE2, 2, 0), (0x25FF2, 2, 0), (0x26672 + 2, 2, 0), (0x26676 + 2, 2, 0), (WORLD + 0xE2, 2, 7),
        (PLAYER_OBJ + 0x1C, 4, 12345), (PLAYER + 0x62A, 4, 0x1500), (PLAYER + 0x22, 2, 0x1234), (0x1BC80, 4, -2400),
        (SUBJECT_OBJ + 0x1C, 4, -777), (SUBJECT + 0x62A, 4, -100), (SUBJECT + 0x22, 2, -0x2000),
        (0x1B826, 2, 8), (WORLD + 0x25C, 2, 0x3C), (WORLD + 0x238, 2, 2), (WORLD + 0x23A, 2, 9), (WORLD + 0x23C, 2, 1),
        (WORLD + 0x23E, 2, 5), (WORLD + 0x242, 2, 0), (WORLD + 0x244, 2, 12), (WORLD + 0x246, 2, 3), (WORLD + 0x248, 2, 10),
        (WORLD + 0x24C, 4, FRAME), (WORLD + 0x250, 4, FRAME + 0x30), (WORLD + 0x254, 4, FRAME + 0x400), (WORLD + 0x258, 4, FRAME + 0x500)]]
    w += [[a, 4, 0] for a in range(FRAME, FRAME + 0x800, 4)]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in extra]
    return {"name": name, "routine": BY_NAME[routine], "args": list(args), "writes": w}


def cache(values: list[int]) -> list[tuple[int, int, int]]:
    return [(0x25FF4 + 2 * k, 2, v) for k, v in enumerate(values)]


def build() -> list[dict]:
    r = "update_view_readouts_and_overlays"
    out = [
        case("readouts: inset 4 resets and prints all four (five passes)", r, [0], [(0x20AE2, 2, 4)]),
        case("readouts: inset 0, nothing", r, [0]),
        case("readouts: one pass from index 2 (heading)", r, [0], [(0x20AE2, 2, 1), (0x25FF2, 2, 2)] + cache([0, 0, 0, 0])),
        case("readouts: two passes, index 3 wraps to 0", r, [0], [(0x20AE2, 2, 2), (0x25FF2, 2, 3)] + cache([1, 1, 1, 1])),
        case("readouts: cached values unchanged", r, [0], [(0x20AE2, 2, 3), (0x25FF2, 2, 0)] + cache([1234, 0x48A, 0x0F6, 0x7FFF])),
        case("readouts: view 7, designated aircraft, climb skipped", r, [0], [(0x20AE2, 2, 4), (0x1D858, 2, 7)]),
        case("readouts: negative altitude and speed", r, [0], [(0x20AE2, 2, 2), (PLAYER_OBJ + 0x1C, 4, -99999), (PLAYER + 0x62A, 4, -9000)]),
        case("readouts: zero values", r, [0], [(0x20AE2, 2, 4), (PLAYER_OBJ + 0x1C, 4, 0), (PLAYER + 0x62A, 4, 0),
                                               (PLAYER + 0x22, 2, 0), (0x1BC80, 4, 0)]),
        case("readouts: heading word -1 and climb 0x7fff", r, [0], [(0x20AE2, 2, 4), (PLAYER + 0x22, 2, -1), (0x1BC80, 4, 0x7FFF)]),
        case("panels drawn: sky, tape, frame and instruments", r, [1], panels=1),
        case("panels drawn, readouts drawn: offset kept, unchanged needles skipped", r, [0], panels=1, drawn=1,
             extra=[(0x1BD7C, 4, 0x4321)]),
        case("panels drawn, host line routine: no sky or tape", r, [5], panels=1, host_line=1),
        case("mark overlays drawn", "mark_view_overlays_drawn", [], [(0x25FFC, 2, 0), (0x20AE4, 2, 7)]),
        case("mark overlays drawn with the host line routine", "mark_view_overlays_drawn", [], [(0x20AE4, 2, 7)], host_line=1),
    ]
    for text in (b"", b"a", b"hello, world", bytes(range(1, 200))):
        out.append(case(f"strlen of {len(text)} bytes", "c_strlen", [STRINGS],
                        [(STRINGS + k, 1, b) for k, b in enumerate(text)] + [(STRINGS + len(text), 1, 0)]))
    return out


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for entry in CALL_LOGS:
        address, log_base, nargs = entry[:3]
        di, dn = (entry[3], entry[4]) if len(entry) > 3 else (-1, 0)
        emu.stubs[address] = lambda e, b=log_base, n=nargs, i=di, k=dn: log_call(e, b, n, i, k)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        entry = {"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if ROUTINES[c["routine"]] == "c_strlen":
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
