#!/usr/bin/env python3
"""Generate comparison cases for the ID02 event and display-refresh routines (refresh_display_if_changed,
reset_overlay_state, set_view_size_option, wait_for_click_or_key, show_resource_file_error_box,
handle_mouse_down, poll_and_dispatch_event) by running the ORIGINAL bytes.

The set-up is gen_id02_display_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, ID01's switch helper
behind slot $3a, here at 0x5f000 to leave room for the logs; the display configuration, settings,
redraw and palette routines running for real) with the event, menu, window and text traps, GetPtrSize,
the JT $172 idle routine and the overlay's entry (A5 - 0x1006 + - 0x1012) as logging stand-ins, and
the unexported overlay-globals sync (0x4d24) as an offset-keyed stand-in; do_menu_command runs for real
(HiWord / LoWord scripted; its own stand-ins are listed here for gen_id02_menu_cases.py). GetNextEvent answers an "outseq" of event records, FindWindow an "out" window, each
scripted per case. update_menu_items and handle_activate_event run for real. Each case records the
original's entry stack pointer ("a7"). test_id02_events.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_events_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_display_cases as display  # noqa: E402
import gen_id02_memory_cases as memory  # noqa: E402
import gen_id02_session_cases as session  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

MEMORY_SIZE = 0x70000                                  # room for the logs of the flight-session stand-ins too
display.ID01_AT = 0x6F000
FIXTURE = Path("godot/tests/strict_port/fixtures/id02_events_cases.json")
A5, LOGS, WINDOW, DATA = memory.A5, memory.LOGS, session.WINDOW, memory.DATA
OVERLAY_ENTRY, MISSION_HOOK = 0x3A900, 0x3AA00
FLIGHT_HOOKS = {-0x106E: (0x3AC00, [4], 0), -0x106A: (0x3AD00, [4, 4], 2), -0x1086: (0x3AE00, [], 4), -0x108E: (0x3AF00, [], 0),
                -0x108A: (0x3B000, [], 0)}
STUBS = display.STUBS + [
    ["trap", 0xA9B4, [], True, 0], ["trap", 0xA9B3, [4, 4], True, 0], ["trap", 0xA92C, [4, 4], True, 2, {0: ["out", WINDOW]}, [3]],
    ["trap", 0xA93D, [4], True, 4], ["trap", 0xA93E, [2], True, 4], ["trap", 0xA91E, [4, 4], True, 2], ["trap", 0xA938, [2], True, 0],
    ["trap", 0xA913, [4, 1, 4, 2, 1, 4, 4, 4], True, 4, {5: "pstr"}], ["trap", 0xA887, [2], True, 0], ["trap", 0xA975, [], True, 4],
    ["trap", 0xA884, [4], True, 0, {0: "pstr"}], ["trap", 0xA924, [], True, 4], ["trap", 0xA939, [2, 4], True, 0],
    ["trap", 0xA93A, [2, 4], True, 0], ["trap", 0xA937, [], True, 0], ["trap", 0xA945, [1, 2, 4], True, 0], ["trap", 0xA928, [4], True, 0],
    ["jt", 0x242, [4], True, 4], ["jt", 0x172, [], False, 0], ["addr", OVERLAY_ENTRY, [4, 4], False, 0],
    ["local", 0x4D24, [], False, 0],
    ["trap", 0xA86A, [4], True, 2], ["trap", 0xA86B, [4], True, 2], ["trap", 0xA874, [4], True, 0, {0: ["out", 0x13000]}],
    ["trap", 0xA946, [4, 2, 4], True, 0, {0: ["out", 0x03444131]}], ["trap", 0xA9B6, [4], True, 2], ["trap", 0xA9C2, [2], True, 2],
    ["trap", 0xA9C8, [2], True, 0], ["jt", 0x132, [], False, 2], ["jt", 0x82, [], False, 2], ["jt", 0x162, [], False, 0],
    ["jt", 0x1DA, [], False, 0], ["jt", 0xDA, [2, 4], False, 2], ["jt", 0x10A, [], False, 0], ["jt", 0x13A, [], False, 2],
    ["jt", 0x102, [], False, 0], ["addr", MISSION_HOOK, [4], False, 0], ["local", 0x2DA0, [], False, 0],
    ["local", 0x2EAA, [], False, 0], ["local", 0x4A4, [], False, 0], ["trap", 0xA91F, [4], True, 0], ["trap", 0xAA31, [4], True, 0],
    ["trap", 0xA972, [4], True, 0, {0: ["out", 0x00640032]}], ["trap", 0xA999, [2], True, 0], ["trap", 0xA850, [], True, 0],
    ["jt", 0x9A, [], False, 0], ["jt", 0x122, [], False, 0], ["jt", 0x17A, [], False, 0], ["jt", 0x1FA, [2], True, 0]] + [
    ["addr", addr, sizes, False, size] for addr, sizes, size in FLIGHT_HOOKS.values()]
CALL_LOGS = [memory.log_entry(i, s) for i, s in enumerate(STUBS)]
INDEX = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"refresh_display_if_changed": 0x29F2, "reset_overlay_state": 0x212A, "set_view_size_option": 0x35BC,
            "wait_for_click_or_key": 0x2DB8, "show_resource_file_error_box": 0x2E36, "handle_mouse_down": 0x2F1E,
            "poll_and_dispatch_event": 0x2FD4}
L, W = memory.L, memory.W
GNE, FIND = ("trap", 0xA970), ("trap", 0xA92C)


def event(what: int, message: int = 0, where: int = 0, modifiers: int = 0) -> list[int]:
    when = 0x1234
    return [(what << 16) | (message >> 16), ((message & 0xFFFF) << 16) | (when >> 16), ((when & 0xFFFF) << 16) | (where >> 16),
            ((where & 0xFFFF) << 16) | modifiers]


def common() -> list[list[int]]:
    w = display.common()
    w = [x for x in w if x[0] not in (A5 + 0x3C,)] + [[A5 + 0x3C, 4, display.ID01_AT + 0xBE]]
    w += [[A5 + 0x32, 2, 0x4EF9], [A5 + 0x34, 4, display.ID01_AT + 0xAA]]   # ID01's sparse long switch (the flight keys)
    w += [[a, 4, 0] for a in range(LOGS + 0x400 * len(display.STUBS), LOGS + 0x400 * len(STUBS), 4)]
    vals = [(LOG_OF[("trap", 0xA93D)] - 4, 4, 0x00810003), (LOG_OF[("trap", 0xA93E)] - 4, 4, 0x00820005),
            (LOG_OF[("trap", 0xA91E)] - 4, 4, 0x100), (LOG_OF[("trap", 0xA913)] - 4, 4, 0x17900), (LOG_OF[("trap", 0xA975)] - 4, 4, 0x55AA),
            (LOG_OF[("trap", 0xA924)] - 4, 4, WINDOW), (LOG_OF[("jt", 0x242)] - 4, 4, 0x10),
            (A5 - 0x1012, 4, OVERLAY_ENTRY - 0x15300), (LOG_OF[("addr", FLIGHT_HOOKS[-0x106A][0])] - 4, 4, 5),
            (A5 - 0x13A8, 4, 0x17D90), (0x17D90, 4, 0x17DA0),
            *[(A5 + k, 4, v[0]) for k, v in FLIGHT_HOOKS.items()], (A5 - 0x109A, 4, MISSION_HOOK), (LOG_OF[("jt", 0x132)] - 4, 4, 1),
            (LOG_OF[("jt", 0x82)] - 4, 4, 1), (LOG_OF[("jt", 0x13A)] - 4, 4, 2), (LOG_OF[("jt", 0xDA)] - 4, 4, 3), (A5 - 0x1022, 4, 0x10), (A5 - 0x101E, 4, 8), (A5 - 0x101A, 4, 0x20),
            (A5 - 0x1040, 4, 0x15340), (A5 - 0x1036, 4, display.H[1]), (A5 - 0xD72, 4, DATA + 0x40), (A5 - 0xD6E, 4, DATA + 0x60)]
    vals += [(0x15318 + k, 1, 0x55) for k in range(0x20)] + [(0x15340 + k, 1, 0x66) for k in range(0x10)]
    vals += [(A5 - 0xC50 + k, 1, b) for k, b in enumerate(b"\x05Oops!")]
    vals += [(DATA + 0x40 + k, 1, b) for k, b in enumerate(b"\x05Error")] + [(DATA + 0x60 + k, 1, b) for k, b in enumerate(b"\x04File")]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list, args: list[int], writes: list = (), events: list | None = None,
         part: int | None = None, found: int | None = None, results: dict | None = None) -> dict:
    c = memory.case(name, method, stack, args, writes)
    if events is not None or part is not None or found is not None or results:
        logs = copy.deepcopy(CALL_LOGS)
        if events is not None:
            logs[INDEX[GNE]][6] = {0: ["outseq", [e for e, _ in events]]}
            logs[INDEX[GNE]][7:] = [[0x100 if got else 0 for _, got in events]]
        if part is not None:
            logs[INDEX[FIND]][7:] = [[part]]
        if found is not None:
            logs[INDEX[FIND]][6] = {0: ["out", found]}
        for key, r in (results or {}).items():
            logs[INDEX[key]][7:] = [r]
        c["call_logs"] = logs
    return c


D1 = [[display.DEVS[1] + 0x90 + 0x20, 2, 1], [A5 - 0x137A, 2, 1]]   # a 1-bit main device: the redraws stay in 1-bit mode


def build() -> list[dict]:
    rf, rs, vs = "refresh_display_if_changed", "reset_overlay_state", "set_view_size_option"
    out = [
        case("refresh: same device and depth", rf, [], [], D1),
        case("refresh: another main device", rf, [], [], D1 + [[A5 - 0x1036, 4, 0]]),
        case("refresh: depth changed", rf, [], [], D1[:1] + [[A5 - 0x137A, 2, 4]]),
        case("refresh: depth changed, window down", rf, [], [], D1[:1] + [[A5 - 0x137A, 2, 4], [A5 - 0x14C6, 2, 0]]),
        case("reset overlay state", rs, [], [], D1),
        case("reset overlay state, empty blocks", rs, [], [], D1 + [[A5 - 0x101A, 4, 0]], results={("jt", 0x242): [0]}),
        case("view size option unchanged", vs, [W(1)], [1]),
        case("view size option 2", vs, [W(2)], [2]),
        case("resource file error box", "show_resource_file_error_box", [], []),
    ]
    wait = "wait_for_click_or_key"
    seq = [(event(0), False), (event(6, WINDOW), True), (event(6, 0x1234), True), (event(8, WINDOW, 0, 3), True), (event(2), True),
           (event(4), True), (event(7), True)]
    for name, last in (("key down", event(3, 0x41)), ("mouse down", event(1)), ("auto key", event(5, 0x42))):
        out.append(case(f"wait: events then {name}", wait, [], [], D1, events=seq + [(last, True)]))
    out.append(case("wait: update with the window down", wait, [], [], D1 + [[A5 - 0x14C6, 2, 0]],
                    events=[(event(6, WINDOW), True), (event(3), True)]))
    ev = DATA + 0x100
    md = "handle_mouse_down"
    rec = [[ev, 4, event(1)[0]], [ev + 4, 4, event(1, 0, 0x00500060)[1]], [ev + 8, 4, event(1, 0, 0x00500060)[2]],
           [ev + 0xC, 4, event(1, 0, 0x00500060)[3]]]
    for name, part, found, res in (("menu bar", 1, None, None), ("system window", 2, None, None), ("content", 3, None, None),
                                   ("drag", 4, None, None), ("grow", 5, None, None), ("close box", 6, None, None),
                                   ("close box released outside", 6, None, {("trap", 0xA91E): [0]}),
                                   ("close box of another window", 6, 0x1234, None), ("desk", 0, None, None)):
        out.append(case(f"mouse down: {name}", md, [L(ev)], [ev], D1 + rec, part=part, found=found, results=res))
    poll = "poll_and_dispatch_event"
    for name, e, got, extra, part in (
            ("no event", event(0), False, [], None), ("mouse down in the menu bar", event(1, 0, 0x00050010), True, [], 1),
            ("mouse up", event(2), True, [], None), ("command key", event(3, 0x0151, 0, 0x100), True, [], None),
            ("plain key", event(3, 0x51), True, [], None), ("command auto key", event(5, 0x00F1, 0, 0x180), True, [], None),
            ("key up", event(4), True, [], None), ("update of the window", event(6, WINDOW), True, [], None),
            ("update, window down", event(6, WINDOW), True, [[A5 - 0x14C6, 2, 0]], None),
            ("update of another window", event(6, 0x4444), True, [], None), ("activate", event(8, WINDOW, 0, 3), True, [], None), ("deactivate", event(8, WINDOW, 0, 1), True, [], None),
            ("disk event", event(7), True, [], None), ("update after a depth change", event(6, WINDOW), True, [[display.DEVS[1] + 0x90 + 0x20, 2, 1], [A5 - 0x137A, 2, 4]], None)):
        out.append(case(f"poll: {name}", poll, [], [], D1 + extra, events=[(e, got)], part=part))
    return out


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE, memory.BINARY, file_delta=0x7FFFFFFF)
    code = open(memory.BINARY, "rb").read()
    emu.mem[memory.CODE:memory.CODE + len(code)] = code
    emu.mem[display.ID01_AT:display.ID01_AT + 0x22E] = open(display.ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", memory.CODE + e[1]] + e[2:] if e[0] == "local" else e for e in c.get("call_logs", CALL_LOGS)])
    a7 = memory.STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    emu.call(memory.CODE + ROUTINES[c["method"]], [], a7, max_steps=20_000_000)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (memory.STACK_GUARD[0] <= a < memory.STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
           "port_vars": {"code_base": memory.CODE}, "common_writes": base, "call_logs": session.as_json(CALL_LOGS), "cases": []}
    for c in build():
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": run(c, base),
                 "a7": memory.STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if "call_logs" in c:
            entry["call_logs"] = session.as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
