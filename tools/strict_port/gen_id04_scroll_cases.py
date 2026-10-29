#!/usr/bin/env python3
"""Generate comparison cases for the second ID04 batch (pilot ranking and pruning, the scrolling
text item and its scroll bar, the named sound, the event poll, the system check and the mission
title) by running the ORIGINAL bytes.

ID04.bin is loaded at 0x30000 with A5 = 0x20000; the dense switch of scroll_bar_action_proc and
poll_click_or_key_event runs ID01's helper for real (ID01.bin at 0x3C000, JMP in slot $3a). Every
trap and other slot is a logging stand-in on both sides (segment_stubs.py): GetDItem writes a fixed
box into the caller's frame, GetPort / SndNewChannel / GetFontInfo write fixed VAR results; a case
may replace the call logs to vary GetNextEvent's event and SysEnvirons' record. test_id04_scroll.gd
replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id04_scroll_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id04_scroll_cases.json")
BINARY, ID01 = "sources/resedit-1-0-3/CODE/ID04.bin", "sources/resedit-1-0-3/CODE/ID01.bin"
MEMORY_SIZE, CODE, A5, ID01_AT = 0x40000, 0x30000, 0x20000, 0x3C000
STACK_TOP = 0x2F000
STACK_GUARD = (0x2E000, 0x2F040)
DATA, DIALOG, HANDLE, ROSTER_H, ROSTER, LOGS = 0x10000, 0x11000, 0x11100, 0x11200, 0x11300, 0x14000
TE_H, CTL, TE, SND_H, CHAN, SAVED_PORT = 0x11E00, 0x11E80, 0x12100, 0x11F80, 0x11F40, 0x11F00
BOX = [(30 << 16) | 40, (50 << 16) | 240]


def event(what: int) -> dict:
    return {0: ["out", what, 2]}


def environs(processor: int, color: int) -> dict:
    return {0: ["out", [0x00010000, processor & 0xFFFF, color << 16, 0]]}


STUBS = [["trap", 0xA98D, [4, 4, 4, 2, 4], True, 0, {0: ["out", BOX], 1: ["out", HANDLE, 4], 2: ["out", 4, 2]}],
         ["trap", 0xA8A3, [4], True, 0], ["trap", 0xA9D3, [4, 4], True, 0, {1: 2}], ["trap", 0xA8A9, [2, 2, 4], True, 0, {2: 2}],
         ["trap", 0xA89B, [2, 2], True, 0], ["trap", 0xA8A1, [4], True, 0, {0: 2}], ["trap", 0xA960, [4], True, 2],
         ["trap", 0xA9DD, [4, 2, 2], True, 0], ["trap", 0xA965, [2, 4], True, 0], ["trap", 0xA963, [2, 4], True, 0],
         ["trap", 0xA9D0, [4], True, 0], ["trap", 0xA874, [4], True, 0, {0: ["out", SAVED_PORT]}], ["trap", 0xA873, [4], True, 0],
         ["trap", 0xA9D2, [4, 4], True, 4, {0: 2, 1: 2}], ["trap", 0xA954, [4, 2, 2, 2, 2, 1, 4, 4, 4], True, 4, {7: 2}],
         ["trap", 0xA8A8, [2, 2, 4], True, 0, {2: 2}], ["trap", 0xA9CD, [4], True, 0], ["trap", 0xA955, [4], True, 0],
         ["trap", 0xA9DE, [4, 4, 4], True, 0], ["trap", 0xA9AA, [4], True, 0], ["trap", 0xA9B0, [4], True, 0],
         ["trap", 0xA9A1, [4, 4], True, 4], ["trap", 0xA807, [4, 4, 2, 4], True, 2, {3: ["out", CHAN]}],
         ["trap", 0xA805, [1, 4, 4], True, 2], ["trap", 0xA801, [1, 4], True, 2], ["trap", 0xA9A3, [4], True, 0],
         ["trap", 0xA9B4, [], True, 0], ["trap", 0xA970, [4, 2], True, 2, event(1)], ["trap", 0xA88A, [2], True, 0],
         ["trap", 0xA88C, [4], True, 2], ["trap", 0xA88B, [4], True, 0, {0: ["out", (12 << 16) | 3]}], ["trap", 0xA893, [2, 2], True, 0],
         ["trap", 0xA884, [4], True, 0], ["jt", 0x2EA, [4, 4], True, 2, {}, [1, 0xFFFF, 0, 0xFFFF, 1, 0xFFFF]],
         ["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0], ["jt", 0x522, [4], False, 0],
         ["jt", 0x1F2, [4, 2], True, 2, environs(3, 1)], ["jt", 0x4BA, [4, 2], False, 0],
         ["trap", 0xA98E, [4, 4, 2, 2, 4], True, 0, {0: 2}]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x200 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}


def logs_with(key: tuple, derefs: dict) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for e in logs:
        if (e[0], e[1]) == key:
            e[6] = derefs
    return logs


ROUTINES = {"draw_select_mission_title": 0x9EE, "rank_pilots_by_score": 0xF4E, "reset_pilot_record": 0x1106,
            "prune_inactive_pilots_beyond_ten": 0x116A, "draw_scrolling_text_item": 0x14A0, "scrolling_text_user_item_proc": 0x14F2,
            "sync_text_scroll_to_control": 0x150E, "update_scroll_bar_maximum": 0x1562, "scroll_text_to_show_selection": 0x158C,
            "fit_text_view_to_box": 0x1638, "scroll_bar_action_proc": 0x16C4, "create_scrolling_text_item": 0x17E6,
            "dispose_scrolling_text_item": 0x189C, "append_line_to_scrolling_text": 0x18B0, "play_named_sound_async": 0x3124,
            "stop_named_sound": 0x3178, "poll_click_or_key_event": 0x3A56, "check_system_requirements": 0x3D42}
LONG_RESULT = {"poll_click_or_key_event", "check_system_requirements"}


def te_record(top: int, dest_top: int, line_height: int, lines: int, sel: int) -> list:
    """A TextEdit record: destRect top, viewRect (top, 10, top + 100, 200), line height, selection
    start, line count and line starts every 7 characters."""
    vals = [(TE, 2, dest_top), (TE + 2, 2, 10), (TE + 4, 2, dest_top + 300), (TE + 6, 2, 200), (TE + 8, 2, top), (TE + 0xA, 2, 10),
            (TE + 0xC, 2, top + 100), (TE + 0xE, 2, 200), (TE + 0x18, 2, line_height), (TE + 0x20, 2, sel), (TE + 0x5E, 2, lines)]
    vals += [(TE + 0x60 + 2 * k, 2, 7 * k) for k in range(lines + 1)]
    vals += [(TE + 0x60 + 2 * k, 2, 0x7FFF) for k in range(lines + 1, 64)]
    return [[a, s, v] for a, s, v in vals]


def common() -> list[list[int]]:
    w = [[a, 4, 0] for start, end in [(DATA, 0x12400), (LOGS, LOGS + 0x200 * len(STUBS)), (A5 - 0x2300, A5)] for a in range(start, end, 4)]
    vals = [(A5 + 0x3A, 2, 0x4EF9), (A5 + 0x3C, 4, ID01_AT + 0xBE), (A5 - 0x13A8, 4, ROSTER_H), (ROSTER_H, 4, ROSTER),
            (A5 - 0x223A, 4, TE_H), (TE_H, 4, TE), (A5 - 0x2236, 4, CTL), (A5 - 0x2232, 2, 10), (A5 - 0xE46, 4, 0x11A80),
            (A5 - 0xE52, 4, 0x11AC0), (A5 - 0x2152, 4, CHAN), (A5 - 0x2156, 4, SND_H),
            (LOG_OF[("trap", 0xA9D2)] - 4, 4, TE_H), (LOG_OF[("trap", 0xA954)] - 4, 4, CTL), (LOG_OF[("trap", 0xA9A1)] - 4, 4, SND_H),
            (LOG_OF[("trap", 0xA960)] - 4, 4, 3), (LOG_OF[("trap", 0xA88C)] - 4, 4, 77), (LOG_OF[("jt", 0x522)] - 4, 4, 11)]
    vals += [(A5 - 0xF5E + 2 * i, 2, [10, 20, 50, 5, -3, 100, 1, 2, 3, 4, 500, 7][i]) for i in range(12)]
    for p in range(20):
        vals += [(ROSTER + 64 * p + 0x28 + 2 * i, 2, ((p * 13 + i * 7) % 40 - 5) if p % 4 else (p % 3)) for i in range(12)]
        vals += [(ROSTER + 64 * p, 1, 0 if p % 3 == 0 else 3), (ROSTER + 64 * p + 0x20, 2, 1 if p % 5 else 0),
                 (ROSTER + 64 * p + 0x22, 2, p), (ROSTER + 64 * p + 0x24, 2, 2 * p), (ROSTER + 64 * p + 0x26, 2, 3 * p)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals] + te_record(40, 40, 12, 30, 0)


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = (),
         logs: list | None = None) -> dict:
    c = {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
         "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}
    if logs is not None:
        c["call_logs"] = logs
    return c


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


SCORES, ORDER = DATA + 0x400, DATA + 0x500


def build() -> list[dict]:
    ctl_value = LOG_OF[("trap", 0xA960)] - 4
    out = [case("rank pilots", "rank_pilots_by_score", [L(SCORES), L(ORDER)], [SCORES, ORDER]),
           case("rank pilots, all named, equal weights", "rank_pilots_by_score", [L(SCORES), L(ORDER)], [SCORES, ORDER],
                [[ROSTER + 64 * p, 1, 2] for p in range(20)] + [[A5 - 0xF5E + 2 * i, 2, 1] for i in range(12)])]
    for pilot in (2, 19):
        out.append(case(f"reset pilot {pilot}", "reset_pilot_record", [W(pilot)], [pilot]))
    for name, order, extra in (("in order", list(range(20)), []), ("reversed", list(range(19, -1, -1)), []),
                               ("few active", list(range(20)), [[ROSTER + 64 * p + 0x20, 2, 1 if p < 6 else 0] for p in range(20)])):
        out.append(case(f"prune pilots {name}", "prune_inactive_pilots_beyond_ten", [L(ORDER)], [ORDER],
                        [[ORDER + 2 * i, 2, o] for i, o in enumerate(order)] + extra))
    out += [case("draw scrolling text", "draw_scrolling_text_item", [L(DIALOG), W(5)], [DIALOG, 5]),
            case("scrolling text user item (Pascal)", "scrolling_text_user_item_proc", [W(5), L(DIALOG)], [DIALOG, 5])]
    for value, top, dest in ((3, 40, 40), (0, 40, 40), (2, 40, 16), (5, 70, -20)):
        out.append(case(f"sync scroll value {value} view {top} dest {dest}", "sync_text_scroll_to_control", [], [],
                        [[ctl_value, 4, value]] + te_record(top, dest, 12, 30, 0)))
    for lines, visible in ((30, 10), (5, 10), (10, 10)):
        out.append(case(f"scroll max {lines} lines {visible} visible", "update_scroll_bar_maximum", [], [],
                        te_record(40, 40, 12, lines, 0) + [[A5 - 0x2232, 2, visible]]))
    for value, sel in ((3, 30), (3, 21), (3, 90), (3, 0), (0, 150), (5, 200)):
        out.append(case(f"show selection {sel} from {value}", "scroll_text_to_show_selection", [], [],
                        [[ctl_value, 4, value]] + te_record(40, 40, 12, 30, sel)))
    for rect, lh in (((20, 30, 150, 300), 12), ((0, 0, 37, 100), 10), ((5, 5, 5, 50), 9)):
        out.append(case(f"fit view {rect} lines of {lh}", "fit_text_view_to_box", [L(DATA + 0x600)], [DATA + 0x600],
                        [[DATA + 0x600 + 2 * k, 2, v] for k, v in enumerate(rect)] + te_record(40, 40, lh, 30, 0)))
    for part in (0, 20, 21, 22, 23):
        out.append(case(f"scroll bar part {part}", "scroll_bar_action_proc", [W(part), L(CTL)], [CTL, part]))
    out += [case("create scrolling text", "create_scrolling_text_item", [L(DIALOG), W(6)], [DIALOG, 6]),
            case("dispose scrolling text", "dispose_scrolling_text_item", [], []),
            case("append line", "append_line_to_scrolling_text", [L(0x1234), W(9), L(0x11B00)], [0x1234, 9, 0x11B00],
                 [[ctl_value, 4, 0]] + te_record(40, 40, 12, 30, 140)),
            case("play sound", "play_named_sound_async", [], []),
            case("play sound, none", "play_named_sound_async", [], [], [[LOG_OF[("trap", 0xA9A1)] - 4, 4, 0]]),
            case("stop sound", "stop_named_sound", [], []),
            case("stop sound, no channel", "stop_named_sound", [], [], [[A5 - 0x2152, 4, 0]]),
            case("stop sound, nothing", "stop_named_sound", [], [], [[A5 - 0x2152, 4, 0], [A5 - 0x2156, 4, 0]])]
    for what in range(0, 9):
        out.append(case(f"poll event {what}", "poll_click_or_key_event", [], [], logs=logs_with(("trap", 0xA970), event(what))))
    for proc, color in ((3, 1), (4, 1), (2, 1), (3, 0), (1, 0)):
        out.append(case(f"system: processor {proc} colour {color}", "check_system_requirements", [], [],
                        logs=logs_with(("jt", 0x1F2), environs(proc, color))))
    out += [case("mission title", "draw_select_mission_title", [W(7), L(DIALOG)], [DIALOG, 7]),
            case("mission title, wide", "draw_select_mission_title", [W(7), L(DIALOG)], [DIALOG, 7],
                 [[LOG_OF[("trap", 0xA88C)] - 4, 4, 301]])]
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, c.get("call_logs", CALL_LOGS))
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def as_json(logs: list) -> list:
    return [[e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:] for e in logs]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        if c["method"] in LONG_RESULT:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
