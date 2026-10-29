#!/usr/bin/env python3
"""Generate comparison cases for the paused dialog and the About box (ID04 0x478 / 0x3a8c) by
running the ORIGINAL bytes.

ID04.bin is loaded at 0x30000 with A5 = 0x20000; poll_click_or_key_event's dense switch runs ID01's
helper for real (ID01.bin at 0x3C000). Every trap and slot is a logging stand-in on both sides
(segment_stubs.py): GetNextEvent's event kind follows an "outseq" list call by call, TickCount,
Button and GetResource answer scripted sequences, rects and the version string are logged by
value. A case replaces the call logs to script another session. Each case records the original's
entry stack pointer ("a7"). test_id04_about.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id04_about_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id04_dialog_cases as first  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id04_about_cases.json")
BINARY, ID01 = first.BINARY, "sources/resedit-1-0-3/CODE/ID01.bin"
MEMORY_SIZE, CODE, A5, ID01_AT = 0x40000, 0x30000, 0x20000, 0x3C000
STACK_TOP, STACK_GUARD, LOGS, DATA = first.STACK_TOP, first.STACK_GUARD, first.LOGS, first.DATA
DIALOG, SAVED_PORT, VERS_H, VERS, PICT_H, PICT = 0x11000, 0x11900, 0x11400, 0x11440, 0x11480, 0x114C0
TICKS = [0, 10, 200] + [201 + 4 * k + j for k in range(8) for j in (0, 1)]  # each scroll step sees a later tick

STUBS = [["trap", 0xA97C, [4, 4, 2], True, 4], ["jt", 0x48A, [4], False, 0], ["jt", 0x472, [4], False, 0],
         ["trap", 0xA915, [4], True, 0], ["trap", 0xA981, [4], True, 0],
         ["trap", 0xA970, [4, 2], True, 2, {0: ["outseq", [0, 3, 0, 4], 2]}, [0x100]], ["trap", 0xA983, [4], True, 0],
         ["trap", 0xA874, [4], True, 0, {0: ["out", SAVED_PORT]}], ["trap", 0xA873, [4], True, 0],
         first.STUBS[0], ["trap", 0xA893, [2, 2], True, 0], ["trap", 0xA887, [2], True, 0], ["trap", 0xA88A, [2], True, 0],
         ["trap", 0xA9A0, [2, 4], True, 4, {}, [VERS_H, PICT_H]], ["trap", 0xA884, [4], True, 0, {0: 2}],
         ["trap", 0xA8A8, [2, 2, 4], True, 0, {2: 2}], ["trap", 0xA87B, [4], True, 0, {0: 2}],
         ["trap", 0xA8F6, [4, 4], True, 0, {0: 2}], ["trap", 0xA975, [], True, 4, {}, TICKS], ["trap", 0xA974, [], True, 2, {}, [0, 0x100]],
         ["trap", 0xA8EC, [4, 2, 4, 4, 4, 4], True, 0, {2: 2, 3: 2}], ["trap", 0xA9B4, [], True, 0],
         ["jt", 0x272, [4], True, 0], ["jt", 0x28A, [4], True, 0], ["jt", 0x282, [4], True, 0], ["jt", 0x27A, [4], True, 0],
         ["trap", 0xA9A3, [4], True, 0]]
CALL_LOGS = [first.log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"show_paused_dialog": 0x478, "show_about_dialog": 0x3A8C}


def logs_with(changes: dict) -> list:
    """Call logs with (kind, key) -> (derefs or None, results or None) replaced."""
    logs = copy.deepcopy(CALL_LOGS)
    for e in logs:
        if (e[0], e[1]) in changes:
            derefs, results = changes[(e[0], e[1])]
            if derefs is not None:
                e[6] = derefs
            if results is not None:
                e[7:] = [results]
    return logs


def events(whats: list[int]) -> dict:
    return {0: ["outseq", whats, 2]}


def common() -> list[list[int]]:
    w = [[a, 4, 0] for start, end in [(DATA, 0x12000), (LOGS, LOGS + 0x200 * len(STUBS)), (A5 - 0x2300, A5)] for a in range(start, end, 4)]
    vals = [(A5 + 0x3A, 2, 0x4EF9), (A5 + 0x3C, 4, ID01_AT + 0xBE), (LOG_OF[("trap", 0xA97C)] - 4, 4, DIALOG),
            (VERS_H, 4, VERS), (VERS, 2, 0x0123), (PICT_H, 4, PICT), (PICT + 2, 4, (2 << 16) | 5), (PICT + 6, 4, (6 << 16) | 105)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, writes: list[list[int]] = (), logs: list | None = None) -> dict:
    c = {"name": name, "method": method, "stack": [], "args": [], "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}
    if logs is not None:
        c["call_logs"] = logs
    return c


def build() -> list[dict]:
    gne = ("trap", 0xA970)
    return [
        case("paused: down, up", "show_paused_dialog"),
        case("paused: stray events", "show_paused_dialog", logs=logs_with({gne: (events([4, 1, 3, 3, 1, 4]), [0x100, 0, 0x100])})),
        case("about: scrolls until the button", "show_about_dialog", logs=logs_with({gne: (events([0]), [0])})),
        case("about: night, scrolls out", "show_about_dialog", [[A5 - 0x137A, 2, 1]],
             logs_with({gne: (events([0]), [0]), ("trap", 0xA974): (None, [0])})),
        case("about: key while looking", "show_about_dialog", logs=logs_with({gne: (events([0, 3]), [0])})),
        case("about: click while scrolling", "show_about_dialog",
             logs=logs_with({gne: (events([0, 0, 0, 1]), [0]), ("trap", 0xA974): (None, [0])})),
        case("about: version 0x1f9", "show_about_dialog", [[VERS, 2, 0x01F9]], logs_with({gne: (events([0]), [0])})),
        case("about: no picture", "show_about_dialog", logs=logs_with({("trap", 0xA9A0): (None, [VERS_H, 0])})),
        case("about: no dialog", "show_about_dialog", [[LOG_OF[("trap", 0xA97C)] - 4, 4, 0]]),
    ]


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, c.get("call_logs", CALL_LOGS))
    before = bytes(emu.mem)
    emu.call(CODE + ROUTINES[c["method"]], [], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE) if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def as_json(logs: list) -> list:
    return [[e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:] for e in logs]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        entry = {"name": c["name"], "method": c["method"], "args": [], "writes": c["writes"], "changes": run(c, base), "a7": STACK_TOP - 4}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
