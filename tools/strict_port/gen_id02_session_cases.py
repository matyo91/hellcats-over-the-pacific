#!/usr/bin/env python3
"""Generate comparison cases for the ID02 session and redraw routines (begin_overlay_session,
ensure_free_memory_and_init_sound, call_overlay_session_hooks, process_pending_update_events,
handle_update_event, redraw_main_window) by running the ORIGINAL bytes.

The set-up is gen_id02_memory_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, the Memory and Resource
Manager stand-ins, so load_game_sounds runs for real) with the overlay's session hooks (code pointers
at A5 - 0x1082 .. -0x1076, the redraw hook A5 - 0x109e) as "addr" stand-ins, the update traps logged,
GetNextEvent answering an "outseq" of events, init_sound_system running for real (SndNewChannel
logged; its VBL handlers record A5 in their code, so the port gets "code_base"), and three unexported
helpers as offset-keyed stand-ins ("local" here, "addr" with the offset in the fixture). The device colour check
runs for real in 1-bit mode. Each case records the original's entry stack pointer ("a7").
test_id02_session.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_session_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_memory_cases as memory  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_session_cases.json")
A5, CODE, LOGS = memory.A5, memory.CODE, memory.LOGS
HOOKS = {-0x1082: 0x3A000, -0x107E: 0x3A100, -0x107A: 0x3A200, -0x1076: 0x3A300, -0x109E: 0x3A400}
WINDOW = 0x15A00


def event(what: int, message: int) -> list[int]:
    return [(what << 16) | (message >> 16), (message & 0xFFFF) << 16, 0, 0]


STUBS = memory.STUBS + [["trap", 0xA9F1, [4], True, 0], ["trap", 0xA922, [4], True, 0], ["trap", 0xA923, [4], True, 0],
                        ["trap", 0xA852, [], True, 0], ["trap", 0xA853, [], True, 0],
                        ["trap", 0xA970, [4, 2], True, 2, {0: ["outseq", [event(6, WINDOW), event(6, WINDOW), event(6, 0x1234)]]},
                         [0x100, 0x100, 0x100, 0]],
                        ["addr", HOOKS[-0x1082], [], False, 0], ["addr", HOOKS[-0x107E], [], False, 0],
                        ["addr", HOOKS[-0x107A], [4, 4], False, 0], ["addr", HOOKS[-0x1076], [], False, 0],
                        ["addr", HOOKS[-0x109E], [], False, 0], ["trap", 0xA807, [4, 4, 2, 4], True, 2], ["local", 0x95A, [], False, 0],
                        ["local", 0x4D96, [], False, 0], ["local", 0xA26, [], False, 0]]
CALL_LOGS = [memory.log_entry(i, s) for i, s in enumerate(STUBS)]
INDEX = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
ROUTINES = {"begin_overlay_session": 0x45A, "ensure_free_memory_and_init_sound": 0x4C6, "call_overlay_session_hooks": 0x930,
            "process_pending_update_events": 0x4D34, "handle_update_event": 0x4D6A, "redraw_main_window": 0x4DB0}


def common() -> list[list[int]]:
    w = memory.common() + [[a, 4, 0] for a in range(LOGS + 0x400 * len(memory.STUBS), LOGS + 0x400 * len(STUBS), 4)]
    vals = [(A5 + k, 4, v) for k, v in HOOKS.items()]
    vals += [(A5 - 0x14CA, 4, WINDOW), (A5 - 0x14C6, 2, 1), (A5 - 0x12F8, 2, 3), (A5 - 0x12EE, 2, 1), (A5 - 0x137A, 2, 1),
             (A5 - 0x12D4, 2, 1), (A5 - 0x1032, 2, 1), (A5 - 0x103C, 2, 0x7777)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list, args: list[int], writes: list[list[int]] = (), results: dict | None = None) -> dict:
    c = memory.case(name, method, stack, args, writes)
    if results:
        logs = copy.deepcopy(CALL_LOGS)
        for key, r in results.items():
            logs[INDEX[key]][7:] = [r]
        c["call_logs"] = logs
    return c


L, W = memory.L, memory.W
FREE = ("jt", 0x212)


def build() -> list[dict]:
    free = memory.LOG_OF[FREE] - 4
    gne = ("trap", 0xA970)
    return [case("begin session, plenty of memory", "begin_overlay_session", [], []),
            case("begin session, short of memory", "begin_overlay_session", [], [], [[free, 4, 50000]]),
            case("free memory, sound on, short", "ensure_free_memory_and_init_sound", [], [], [[free, 4, 400000]]),
            case("free memory, sound off", "ensure_free_memory_and_init_sound", [], [], [[A5 - 0x12EE, 2, 0]]),
            case("session hooks", "call_overlay_session_hooks", [L(7), L(0xCAFE)], [7, 0xCAFE]),
            case("updates: two for the window, then another", "process_pending_update_events", [], []),
            case("updates: none pending", "process_pending_update_events", [], [], results={gne: [0]}),
            case("update event for the window", "handle_update_event", [L(memory.DATA + 0x100)], [memory.DATA + 0x100],
                 [[memory.DATA + 0x102, 4, WINDOW]]),
            case("update event for another window", "handle_update_event", [L(memory.DATA + 0x100)], [memory.DATA + 0x100],
                 [[memory.DATA + 0x102, 4, 0x4321]]),
            case("update event, window down", "handle_update_event", [L(memory.DATA + 0x100)], [memory.DATA + 0x100],
                 [[memory.DATA + 0x102, 4, WINDOW], [A5 - 0x14C6, 2, 0]]),
            case("redraw", "redraw_main_window", [], []),
            case("redraw, already drawn once", "redraw_main_window", [], [], [[A5 - 0x12EA, 2, 1]]),
            case("redraw, no frame buffer", "redraw_main_window", [], [], [[A5 - 0x1006, 4, 0]]),
            case("redraw, no game", "redraw_main_window", [], [], [[A5 - 0x12F8, 2, 0]])]


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(memory.MEMORY_SIZE, memory.BINARY, file_delta=0x7FFFFFFF)
    code = open(memory.BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in c.get("call_logs", CALL_LOGS)])
    a7 = memory.STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return [[a, emu.mem[a]] for a in range(memory.MEMORY_SIZE)
            if not (memory.STACK_GUARD[0] <= a < memory.STACK_GUARD[1]) and emu.mem[a] != before[a]]


def as_json(logs: list) -> list:
    return [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in logs]


def main() -> None:
    base = common()
    out = {"memory_size": memory.MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
           "port_vars": {"code_base": CODE}, "common_writes": base, "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": run(c, base),
                 "a7": memory.STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
