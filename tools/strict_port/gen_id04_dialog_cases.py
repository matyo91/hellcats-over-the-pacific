#!/usr/bin/env python3
"""Generate comparison cases for the first ID04 batch (dialog item helpers, user item procedures,
the radio group, the temporary window, the alerts, the kill report and pilot score) by running the
ORIGINAL bytes.

ID04.bin is loaded at 0x30000 with A5 = 0x20000. Every trap and jump-table slot is a logging
stand-in on both sides (segment_stubs.py): GetDItem writes a fixed item type, handle and box
through its VAR arguments into the caller's frame (the ports model A7); rect arguments in the
frame are logged by value; GetCtlValue answers 0, 0, 1. test_id04_dialog.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id04_dialog_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id04_dialog_cases.json")
BINARY = "sources/resedit-1-0-3/CODE/ID04.bin"
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
STACK_TOP = 0x2F000
STACK_GUARD = (0x2E000, 0x2F040)
DATA, DIALOG, HANDLE, ROSTER_H, ROSTER, LOGS = 0x10000, 0x11000, 0x11100, 0x11200, 0x11300, 0x14000
BOX = [(30 << 16) | 40, (50 << 16) | 240]
STUBS = [["trap", 0xA98D, [4, 4, 4, 2, 4], True, 0, {0: ["out", BOX], 1: ["out", HANDLE, 4], 2: ["out", 4, 2]}],
         ["trap", 0xA98E, [4, 4, 2, 2, 4], True, 0, {0: 2}], ["trap", 0xA98F, [4, 4], True, 0], ["trap", 0xA95D, [2, 4], True, 0],
         ["trap", 0xA958, [4], True, 0], ["trap", 0xA957, [4], True, 0], ["trap", 0xA95F, [4, 4], True, 0],
         ["trap", 0xA960, [4], True, 2, {}, [0, 0, 1]], ["trap", 0xA873, [4], True, 0], ["trap", 0xA8A9, [2, 2, 4], True, 0, {2: 2}],
         ["trap", 0xA89B, [2, 2], True, 0], ["trap", 0xA8A1, [4], True, 0, {0: 2}], ["trap", 0xA8B0, [2, 2, 4], True, 0, {2: 2}],
         ["trap", 0xA8A5, [4, 4], True, 0, {1: 2}], ["trap", 0xA913, [4, 1, 4, 2, 1, 4, 4, 4], True, 4, {6: 2}],
         ["trap", 0xA915, [4], True, 0], ["trap", 0xA916, [4], True, 0], ["trap", 0xA98B, [4, 4, 4, 4], True, 0],
         ["trap", 0xA986, [4, 2], True, 2], ["trap", 0xA988, [4, 2], True, 2], ["jt", 0x47A, [2], False, 0], ["jt", 0x4AA, [], False, 0]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x200 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"disable_dialog_control": 0x6, "enable_dialog_control": 0x2E, "hide_dialog_control": 0x54, "show_dialog_control": 0x78,
            "set_dialog_item_text": 0x9C, "set_dialog_control_title": 0xC4, "set_dialog_user_item_proc": 0xEC,
            "frame_dialog_item_box": 0x120, "draw_default_button_outline": 0x16E, "draw_grey_user_item": 0x1F2,
            "draw_percent_bar_item": 0x220, "percent_bar_user_item_proc": 0x2C0, "get_radio_group_selection": 0x362,
            "run_with_temporary_window": 0x3C2, "show_scenery_open_error_alert": 0x44E, "ask_save_changes": 0x4F0,
            "confirm_end_mission": 0x516, "confirm_erase_high_scores": 0x560, "compute_pilot_score": 0x588,
            "get_mission_kill_report_state": 0x18E0}
WORD_RESULT = {"get_radio_group_selection", "show_scenery_open_error_alert", "ask_save_changes", "confirm_end_mission",
               "confirm_erase_high_scores"}
LONG_RESULT = {"compute_pilot_score", "get_mission_kill_report_state"}


def common() -> list[list[int]]:
    w = [[a, 4, 0] for start, end in [(DATA, 0x12000), (LOGS, LOGS + 0x200 * len(STUBS)), (A5 - 0x2300, A5)] for a in range(start, end, 4)]
    vals = [(LOG_OF[("trap", 0xA913)] - 4, 4, 0x11800), (LOG_OF[("trap", 0xA986)] - 4, 4, 1), (LOG_OF[("trap", 0xA988)] - 4, 4, 2),
            (LOG_OF[("jt", 0x47A)] - 4, 4, 0xABCD0000), (A5 - 0x160C, 4, 0x11900), (A5 - 0x225E, 2, 1), (A5 - 0x225C, 2, 37),
            (A5 - 0x1680, 2, 0), (A5 - 0x167E, 2, 0), (A5 - 0x167C, 2, 768), (A5 - 0x167A, 2, 1024), (A5 - 0xE4E, 4, 0x11A00),
            (A5 - 0x13A8, 4, ROSTER_H), (ROSTER_H, 4, ROSTER)]
    vals += [(A5 - 0xF5E + 2 * i, 2, [10, 20, 50, 5, -3, 100, 1, 2, 3, 4, 500, 7][i]) for i in range(12)]
    vals += [(ROSTER + 64 * p + 0x28 + 2 * i, 2, (p * 13 + i * 7) % 40 - 5) for p in range(4) for i in range(12)]
    vals += [(DATA + 2 * k, 2, v) for k, v in enumerate((5, 6, 7, 8))]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def build() -> list[dict]:
    out = []
    for name in ("disable_dialog_control", "enable_dialog_control", "hide_dialog_control", "show_dialog_control",
                 "frame_dialog_item_box", "draw_percent_bar_item"):
        out.append(case(name, name, [L(DIALOG), W(3)], [DIALOG, 3]))
    for name in ("set_dialog_item_text", "set_dialog_control_title", "set_dialog_user_item_proc"):
        out.append(case(name, name, [L(DIALOG), W(4), L(0x11C00)], [DIALOG, 4, 0x11C00]))
    for name in ("draw_default_button_outline", "draw_grey_user_item", "percent_bar_user_item_proc"):
        out.append(case(f"{name} (Pascal)", name, [W(2), L(DIALOG)], [DIALOG, 2]))
    for pct in (0, 100, -10, 250):
        out.append(case(f"percent bar at {pct}%", "draw_percent_bar_item", [L(DIALOG), W(3)], [DIALOG, 3], [[A5 - 0x225C, 2, pct]]))
    out += [
        case("radio group: third set", "get_radio_group_selection", [L(DIALOG), L(DATA), W(4)], [DIALOG, DATA, 4]),
        case("radio group: none of two set", "get_radio_group_selection", [L(DIALOG), L(DATA), W(2)], [DIALOG, DATA, 2]),
        case("radio group: empty", "get_radio_group_selection", [L(DIALOG), L(DATA), W(0)], [DIALOG, DATA, 0]),
        case("temporary window made", "run_with_temporary_window", [], []),
        case("temporary window reused", "run_with_temporary_window", [], [], [[A5 - 0x225A, 4, 0x11B00]]),
        case("scenery error alert", "show_scenery_open_error_alert", [L(0x11D00)], [0x11D00]),
        case("save changes?", "ask_save_changes", [], []),
        case("erase scores?", "confirm_erase_high_scores", [], []),
    ]
    for name, extra in (("no mission", []), ("mission, nothing to report", [[A5 - 0x12F8, 2, 3], [A5 - 0x14C0, 2, 1]]),
                        ("mission with kills", [[A5 - 0x12F8, 2, 4], [A5 - 0x14C0, 2, 1], [A5 - 0x12CE + 2 * 7, 2, 1]]),
                        ("mission, report pending", [[A5 - 0x12F8, 2, 3], [A5 - 0x12BA, 2, 2]]),
                        ("mission in mode 1", [[A5 - 0x12F8, 2, 5], [A5 - 0x14C4, 2, 1], [A5 - 0x12BA, 2, 2]]),
                        ("state 2", [[A5 - 0x12F8, 2, 2], [A5 - 0x12BA, 2, 2]])):
        out.append(case(f"end mission: {name}", "confirm_end_mission", [], [], extra))
        out.append(case(f"kill report: {name}", "get_mission_kill_report_state", [], [], extra))
    for pilot in range(4):
        out.append(case(f"pilot {pilot} score", "compute_pilot_score", [W(pilot)], [pilot]))
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
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
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    base = common()
    logs = [[e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:] for e in CALL_LOGS]
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": logs, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] in WORD_RESULT:
            entry["d0"], entry["d0_mask"] = d0 & 0xFFFF, 0xFFFF
        elif c["method"] in LONG_RESULT:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
