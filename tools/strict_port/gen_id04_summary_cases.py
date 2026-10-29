#!/usr/bin/env python3
"""Generate comparison cases for show_mission_summary_dialog (ID04 0x2de6) by running the ORIGINAL
bytes.

ID04.bin is loaded at 0x30000 with A5 = 0x20000. Every trap and slot is a logging stand-in on both
sides (segment_stubs.py; the first batch's stubs and the scrolling text's); the dialog's own
helpers already ported run for real on both sides, the two not exported (the default-ring
installer 0x1b8, advance_mission_summary_text 0x21d6) are offset-keyed stand-ins ("local" here,
"addr" with the offset in the fixture). ModalDialog's item hits follow an "outseq" list; a case
replaces the call logs to script another session. Each case records the original's entry stack
pointer ("a7"): the routine stores its frame's tally buffer in A5 - 0x2226. test_id04_summary.gd
replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id04_summary_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/id04_summary_cases.json")
BINARY = first.BINARY
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
STACK_TOP, STACK_GUARD, LOGS, DATA, ROSTER = first.STACK_TOP, first.STACK_GUARD, first.LOGS, first.DATA, first.ROSTER
TE_H, TE, CTL, SAVED_PORT, SETTINGS_H, SETTINGS, WINDOW = 0x11E00, 0x12100, 0x11E80, 0x11F00, 0x12200, 0x12240, 0x12280


def hits(items: list[int]) -> dict:
    return {0: ["outseq", items, 2]}


STUBS = first.STUBS + [
    ["trap", 0xA97C, [4, 4, 2], True, 4], ["jt", 0x472, [4], False, 0], ["trap", 0xA8A8, [2, 2, 4], True, 0, {2: 2}],
    ["trap", 0xA874, [4], True, 0, {0: ["out", SAVED_PORT]}], ["trap", 0xA9D2, [4, 4], True, 4, {0: 2, 1: 2}],
    ["trap", 0xA954, [4, 2, 2, 2, 2, 1, 4, 4, 4], True, 4, {7: 2}], ["trap", 0xA9D0, [4], True, 0], ["jt", 0x4EA, [4, 4, 4], False, 0],
    ["trap", 0xA975, [], True, 4], ["trap", 0xA991, [4, 4], True, 0, hits([2, 4, 3])], ["trap", 0xA983, [4], True, 0],
    ["trap", 0xA9CD, [4], True, 0], ["trap", 0xA955, [4], True, 0], ["jt", 0x52A, [4, 4], False, 0], ["jt", 0x4A2, [4, 4], False, 0],
    ["jt", 0x2FA, [4], False, 0], ["jt", 0x512, [4, 4], False, 0], ["jt", 0x302, [4], False, 0],
    ["trap", 0xA8A3, [4], True, 0, {0: 2}], ["trap", 0xA928, [4], True, 0, {0: 2}],
    ["local", 0x1B8, [4, 2, 2], False, 0], ["local", 0x21D6, [4, 2, 2], False, 0]]
CALL_LOGS = [first.log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}


def logs_with(changes: dict) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for e in logs:
        if (e[0], e[1]) in changes:
            e[6] = changes[(e[0], e[1])]
    return logs


def common() -> list[list[int]]:
    w = first.common()
    w += [[a, 4, 0] for a in range(0x12000, 0x12400, 4)]
    w += [[a, 4, 0] for a in range(LOGS + 0x200 * len(first.STUBS), LOGS + 0x200 * len(STUBS), 4)]
    vals = [(LOG_OF[("trap", 0xA97C)] - 4, 4, 0x11000), (LOG_OF[("trap", 0xA9D2)] - 4, 4, TE_H), (TE_H, 4, TE),
            (TE + 0x18, 2, 12), (LOG_OF[("trap", 0xA954)] - 4, 4, CTL), (LOG_OF[("trap", 0xA975)] - 4, 4, 0x12345),
            (LOG_OF[("local", 0x21D6)] - 4, 4, 1), (LOG_OF[("jt", 0x2FA)] - 4, 4, 0x11D40), (A5 - 0x13AC, 4, SETTINGS_H),
            (SETTINGS_H, 4, SETTINGS), (SETTINGS + 0x20, 2, 3), (A5 - 0x14CA, 4, WINDOW), (A5 - 0xE5E, 4, 0x11CC0), (A5 - 0x13A4, 2, 1)]
    vals += [(A5 - 0x13A2 + 2 * i, 2, 100 + i) for i in range(12)] + [(A5 - 0x12CE + 2 * i, 2, i * 3 - 4) for i in range(12)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, pilot: int, phase: int, writes: list[list[int]] = (), items: list[int] | None = None,
         extra: dict | None = None) -> dict:
    changes = dict(extra or {})
    if items is not None:
        changes[("trap", 0xA991)] = hits(items)
    c = {"name": name, "stack": [(2, pilot & 0xFFFF), (2, phase & 0xFFFF), (4, 0x11B80)],
         "args": [pilot & 0xFFFF, phase & 0xFFFF, 0x11B80], "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}
    if changes:
        c["call_logs"] = logs_with(changes)
    return c


def build() -> list[dict]:
    a5 = lambda off, size, v: [A5 + off, size, v]  # noqa: E731
    return [
        case("pilot 2, OK", 2, 0, items=[3]),
        case("pilot 0, item 1", 0, 0, items=[2, 1]),
        case("mission, phase 3, items 2 4 3", -1, 3),
        case("mission over, ended", -1, 1, [a5(-0x14C4, 2, 1)], [4, 1]),
        case("mission, early death, ended", -1, 0x101, [a5(-0x12B4, 2, 0)], [1]),
        case("mission running, confirmed", -1, 1, [a5(-0x12F8, 2, 4), a5(-0x12CE + 6, 2, 1)], [4, 1]),
        case("mission running, nothing to report", -1, 0, [a5(-0x12F8, 2, 4), a5(-0x14C0, 2, 1)], [1]),
        case("mission, phase 3, no advance", -1, 3, [[LOG_OF[("local", 0x21D6)] - 4, 4, 0]], [3]),
        case("state 2, skipped", -1, 0, [a5(-0x12F8, 2, 2)]),
        case("state 2, pilot 3", 3, 2, [a5(-0x12F8, 2, 2)], [1]),
    ]


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in c.get("call_logs", CALL_LOGS)])
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + 0x2DE6, [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFF)


def as_json(logs: list) -> list:
    return [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in logs]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": "show_mission_summary_dialog", "args": c["args"], "writes": c["writes"],
                 "changes": changes, "d0": d0, "d0_mask": 0xFFFF, "a7": STACK_TOP - 8 - 4}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
