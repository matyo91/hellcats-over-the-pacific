#!/usr/bin/env python3
"""Generate comparison cases for the ID02 status-line columns and menu-item update
(draw_text_in_columns_a5safe, update_menu_items) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py. Every trap is a logging stand-in on both sides
(segment_stubs.py); GetPen writes a fixed pen point through its VAR argument (the routine reads it
back from its frame, so the port models A7); FrontWindow returns a window whose kind word is set
per case. test_id02_menu.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_menu_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_menu_cases.json")
BINARY, CODE, A5 = base_layout.BINARY, base_layout.CODE, base_layout.A5
MEMORY_SIZE = 0x60000
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
DATA = base_layout.DATA
WINDOW, SETTINGS_H, SETTINGS = 0x15000, 0x15100, 0x15200
LOGS = 0x40000
PEN = 0x00140050
STUBS = [["trap", 0xA862, [4], True, 0], ["trap", 0xA863, [4], True, 0], ["trap", 0xA8A5, [4, 4], True, 0, {1: 2}],
         ["trap", 0xA893, [2, 2], True, 0], ["trap", 0xA888, [2], True, 0], ["trap", 0xA88D, [2], True, 2],
         ["trap", 0xA884, [4], True, 0], ["trap", 0xA89A, [4], True, 0, {0: ["out", PEN]}], ["trap", 0xA894, [2, 2], True, 0],
         ["trap", 0xA885, [2, 2, 4], True, 0], ["trap", 0xA924, [], True, 4], ["trap", 0xA939, [2, 4], True, 0],
         ["trap", 0xA93A, [2, 4], True, 0], ["trap", 0xA937, [], True, 0], ["trap", 0xA945, [1, 2, 4], True, 0]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x1000 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"draw_text_in_columns_a5safe": 0x1308, "update_menu_items": 0x3174}


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x1000 * len(STUBS), 4)]
    w += [[a, 4, 0] for a in range(0x15000, 0x16000, 4)]
    vals = [(LOG_OF[("trap", 0xA88D)] - 4, 4, 7), (LOG_OF[("trap", 0xA924)] - 4, 4, WINDOW), (A5 - 0x1372, 2, 640), (A5 - 0x1370, 2, 480),
            (A5 - 0xDE2, 4, 0x16000), (A5 - 0xDDE, 4, 0x16010), (A5 - 0xDDA, 4, 0x16020), (A5 - 0xDD6, 4, 0x16030),
            (A5 - 0x14DA, 2, 60), (A5 - 0x14D8, 2, 150), (A5 - 0x14D6, 2, 240), (A5 - 0x14D4, 2, 330),
            (A5 - 0x14D2, 2, 35), (A5 - 0x14D0, 2, 21), (A5 - 0x14CE, 2, 28), (A5 - 0x14CC, 2, 28),
            (A5 - 0xC4A, 4, 0x16100), (A5 - 0xC46, 4, 0x16200), (A5 - 0xC42, 4, 0x16300), (A5 - 0xC3E, 4, 0x16400),
            (A5 - 0x13AC, 4, SETTINGS_H), (SETTINGS_H, 4, SETTINGS), (WINDOW + 0x6C, 2, 8), (A5 - 0xC3A, 2, 0),
            (A5 - 0x102F, 1, 1), (A5 - 0x137A, 2, 8)]
    for off, v in ((3, 1), (5, 0), (7, 1), (9, 0), (0xE, 2), (0x10, 3), (0x13, 1), (0x15, 0), (0x17, 1), (0x19, 0), (0x1B, 1)):
        vals.append((SETTINGS + off, 1 if off not in (0xE, 0x10) else 2, v))
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


case = base_layout.case
L, W = base_layout.L, base_layout.W


def flags(playing=0, state=0, paused=0, mode=0, buffer=0, b4=0, busy=0, front_kind=8, depth=8, last_da=0) -> list[list[int]]:
    return [[A5 - 0x102E, 2, playing], [A5 - 0x12F8, 2, state], [A5 - 0x12F0, 2, paused], [A5 - 0x14C4, 2, mode],
            [A5 - 0x1006, 4, buffer], [A5 - 0x12B4, 2, b4], [A5 - 0x1032, 2, busy], [A5 - 0x12D4, 2, busy],
            [WINDOW + 0x6C, 2, front_kind & 0xFFFF], [A5 - 0x137A, 2, depth], [A5 - 0xC3A, 2, last_da]]


def build() -> list[dict]:
    out = []
    for layout, three in ((1, 0), (1, 1)):
        out.append(case(f"status line layout (three columns {three})", "draw_text_in_columns_a5safe",
                        [L(DATA), L(0), L(0), L(0), L(layout), L(three)], [DATA, 0, 0, 0, layout, three]))
    for column in (0, 2, 3):
        out.append(case(f"status column {column}", "draw_text_in_columns_a5safe", [L(DATA), L(column), L(2), L(5), L(0), L(0)],
                        [DATA, column, 2, 5, 0, 0]))
    for name, f in (("idle", {}), ("playing state 1", dict(playing=1, state=1, buffer=1)),
                    ("playing paused, mode 1", dict(playing=1, state=1, paused=1, mode=1, buffer=1, b4=1)),
                    ("playing unpaused, mode 1", dict(playing=1, state=4, mode=1, buffer=1, b4=1)),
                    ("state 2 with a buffer", dict(playing=1, state=2, buffer=1, b4=1)),
                    ("state 3, busy, depth 4", dict(playing=1, state=3, busy=1, depth=4)),
                    ("desk accessory in front", dict(front_kind=-3)), ("desk accessory still in front", dict(front_kind=-3, last_da=1)),
                    ("no front window, state 0 mode 2", dict(front_kind=0, mode=2, playing=1)),
                    ("not playing, state 5", dict(state=5, mode=1))):
        extra = flags(**f)
        if name.startswith("no front window"):
            extra.append([LOG_OF[("trap", 0xA924)] - 4, 4, 0])
        out.append(case(f"menus: {name}", "update_menu_items", [], [], extra))
    return out


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, CALL_LOGS)
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    base = common()
    logs = [[e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:] for e in CALL_LOGS]
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": logs, "cases": []}
    for c in build():
        changes = run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
