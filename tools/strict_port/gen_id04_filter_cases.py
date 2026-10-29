#!/usr/bin/env python3
"""Generate comparison cases for the third ID04 batch (the ModalDialog filters and the fuel slider,
the summary dialog's buttons, the rank-and-name title, the score text, conclude_mission and the map
grid and plotting callback) by running the ORIGINAL bytes.

ID04.bin is loaded at 0x30000 with A5 = 0x20000; ID01's sparse switch helpers (slots $2a / $32)
run for real (ID01.bin at 0x3C000). Every trap and other slot is a logging stand-in on both sides
(segment_stubs.py, the first batch's stubs and more); the two segment routines not ported yet
(track_map_bearing_and_distance 0x3614, show_mission_summary_dialog 0x2de6) are "addr" stand-ins,
keyed by their runtime address here and by their segment offset in the fixture. GlobalToLocal and
GetMouse write fixed points, StillDown answers true, true, false; a case may replace the call logs.
Each case records the original's stack pointer on entry ("a7"), so frame addresses passed to the
stand-ins match. test_id04_filter.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id04_filter_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/id04_filter_cases.json")
BINARY, ID01 = first.BINARY, "sources/resedit-1-0-3/CODE/ID01.bin"
MEMORY_SIZE, CODE, A5, ID01_AT = 0x40000, 0x30000, 0x20000, 0x3C000
STACK_TOP, STACK_GUARD = first.STACK_TOP, first.STACK_GUARD
DATA, DIALOG, LOGS = first.DATA, first.DIALOG, first.LOGS
EVENT, HIT, RANK_STR, CHAN, SND_H = DATA + 0x700, DATA + 0x720, 0x11C80, 0x11F40, 0x11F80


def point(v: int, h: int) -> int:
    return ((v & 0xFFFF) << 16) | (h & 0xFFFF)


STUBS = first.STUBS + [
    ["trap", 0xA871, [4], True, 0, {0: ["out", point(40, 140)]}], ["trap", 0xA8AD, [4, 4], True, 2, {0: 2}],
    ["trap", 0xA972, [4], True, 0, {0: ["out", point(40, 300)]}], ["trap", 0xA973, [], True, 2, {}, [0x100, 0x100, 0]],
    ["trap", 0xA928, [4], True, 0, {0: 2}], ["trap", 0xA8A3, [4], True, 0, {0: 2}], ["trap", 0xA88C, [4], True, 2],
    ["trap", 0xA88B, [4], True, 0, {0: ["out", (12 << 16) | 3]}], ["trap", 0xA893, [2, 2], True, 0], ["trap", 0xA884, [4], True, 0],
    ["trap", 0xA9AA, [4], True, 0], ["trap", 0xA999, [2], True, 0], ["trap", 0xA878, [2, 2], True, 0],
    ["trap", 0xA8A8, [2, 2, 4], True, 0], ["trap", 0xA87B, [4], True, 0], ["trap", 0xA862, [4], True, 0],
    ["trap", 0xA892, [2, 2], True, 0], ["trap", 0xA894, [2, 2], True, 0], ["trap", 0xA883, [2], True, 0],
    ["trap", 0xA9A1, [4, 4], True, 4], ["trap", 0xA807, [4, 4, 2, 4], True, 2, {3: ["out", CHAN]}],
    ["trap", 0xA805, [1, 4, 4], True, 2], ["trap", 0xA801, [1, 4], True, 2], ["trap", 0xA9A3, [4], True, 0],
    ["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0], ["jt", 0x492, [4], False, 0], ["jt", 0x2FA, [4], False, 0],
    ["jt", 0x302, [4], False, 0], ["jt", 0x52A, [4, 4], False, 0], ["jt", 0x512, [4, 4], False, 0], ["jt", 0x4A2, [4, 4], False, 0],
    ["addr", 0x3614, [4, 4], False, 0], ["addr", 0x2DE6, [2, 2, 4], False, 0]]
CALL_LOGS = [first.log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}


def logs_with(key: tuple, derefs: dict | None = None, results: list | None = None) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for e in logs:
        if (e[0], e[1]) == key:
            if derefs is not None:
                e[6] = derefs
            if results is not None:
                e[7:] = [results]
    return logs


ROUTINES = {"duty_roster_filter_proc": 0x5E4, "fuel_slider_dialog_filter": 0xA8E, "scenario_selection_filter_proc": 0xBDA,
            "refuel_dialog_filter_proc": 0xE48, "update_summary_dialog_buttons": 0x192E, "build_rank_and_name_string": 0x1A0E,
            "set_score_item_text": 0x2D86, "conclude_mission": 0x31AA, "draw_map_grid_and_centre_mark": 0x3260,
            "plot_map_symbol_callback": 0x3352, "map_dialog_filter_proc": 0x3902}
LONG_RESULT = {"duty_roster_filter_proc", "fuel_slider_dialog_filter", "scenario_selection_filter_proc",
               "refuel_dialog_filter_proc", "map_dialog_filter_proc"}
WORD_RESULT = {"conclude_mission"}


def common() -> list[list[int]]:
    w = first.common()
    w += [[a, 4, 0] for a in range(0x12000, 0x12400, 4)]
    w += [[a, 4, 0] for a in range(LOGS + 0x200 * len(first.STUBS), LOGS + 0x200 * len(STUBS), 4)]
    vals = [(A5 + 0x2A, 2, 0x4EF9), (A5 + 0x2C, 4, ID01_AT + 0x96), (A5 + 0x32, 2, 0x4EF9), (A5 + 0x34, 4, ID01_AT + 0xAA),
            (0x904, 4, A5), (A5 - 0x160C, 4, 0x11900), (A5 - 0x225E, 2, 2), (A5 - 0x13A4, 2, 2), (A5 - 0xE5E, 4, 0x11CC0),
            (A5 - 0xFFE + 4 * 3, 4, RANK_STR), (first.ROSTER + 64 * 2 + 0x22, 2, 3), (A5 - 0x2228, 2, -1),
            (A5 - 0x2148, 2, 100), (A5 - 0x2146, 2, 50), (A5 - 0x214C, 2, 300), (A5 - 0x214A, 2, 200),
            (A5 - 0x2152, 4, CHAN), (A5 - 0x2156, 4, SND_H), (A5 - 0x1002, 2, 7),
            (LOG_OF[("trap", 0xA8AD)] - 4, 4, 0x100), (LOG_OF[("trap", 0xA88C)] - 4, 4, 90),
            (LOG_OF[("jt", 0x2FA)] - 4, 4, 0x11D40), (LOG_OF[("addr", 0x2DE6)] - 4, 4, 0x00050004),
            (LOG_OF[("trap", 0xA9A1)] - 4, 4, SND_H), (EVENT + 0xA, 4, point(120, 80))]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = (),
         logs: list | None = None) -> dict:
    c = {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
         "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}
    if logs is not None:
        c["call_logs"] = logs
    return c


L, W = first.L, first.W


def event(what: int, char: int = 0) -> list[list[int]]:
    return [[EVENT, 2, what], [EVENT + 2, 4, 0x2400 | char]]


def build() -> list[dict]:
    out = []
    pascal_filters = ("duty_roster_filter_proc", "scenario_selection_filter_proc", "refuel_dialog_filter_proc", "map_dialog_filter_proc")
    events = [("Return", event(3, 13)), ("Enter", event(3, 3)), ("key x", event(3, 0x78)), ("update", event(6)),
              ("click", event(1)), ("auto-key", event(5, 13)), ("null", event(0))]
    for name in pascal_filters:
        for label, writes in events:
            out.append(case(f"{name}: {label}", name, [L(HIT), L(EVENT), L(DIALOG)], [DIALOG, EVENT, HIT], writes))
    slider = [L(DIALOG), L(EVENT), L(HIT), W(4)]
    out += [case("slider: drag to the right edge", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4], event(1)),
            case("slider: Return", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4], event(3, 13)),
            case("slider: click outside", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4],
                 event(1) + [[LOG_OF[("trap", 0xA8AD)] - 4, 4, 0]]),
            case("slider: released at once", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4], event(1),
                 logs_with(("trap", 0xA973), results=[0])),
            case("slider: same percent", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4], event(1) + [[A5 - 0x225C, 2, 50]],
                 logs_with(("trap", 0xA972), {0: ["out", point(40, 140)]})),
            case("slider: left of the box", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4], event(1),
                 logs_with(("trap", 0xA871), {0: ["out", point(40, -5)]})),
            case("slider: on the left edge", "fuel_slider_dialog_filter", slider, [DIALOG, EVENT, HIT, 4], event(1),
                 logs_with(("trap", 0xA871), {0: ["out", point(40, 40)]}))]
    for label, writes in (("no mission", [[A5 - 0x14C4, 2, 0]]), ("mission", [[A5 - 0x14C4, 2, 1]]),
                          ("mission, default 1", [[A5 - 0x14C4, 2, 1], [A5 - 0x225E, 2, 1]]),
                          ("mission, pending", [[A5 - 0x14C4, 2, 1], [A5 - 0x12F0, 2, 1]]),
                          ("mission, choice made", [[A5 - 0x14C4, 2, 1], [A5 - 0x2228, 2, 2]])):
        for which in (1, 3):
            out.append(case(f"summary buttons {which}: {label}", "update_summary_dialog_buttons", [L(DIALOG), W(which)], [DIALOG, which],
                            writes + [[A5 - 0x2230, 4, 0x1234]]))
    out += [case("rank and name", "build_rank_and_name_string", [W(4), L(DIALOG)], [DIALOG, 4]),
            case("score text", "set_score_item_text", [L(DIALOG), W(5)], [DIALOG, 5])]
    for label, writes in (("quiet", []), ("first death with sound", [[A5 - 0x12B4, 2, 1], [A5 - 0x12EE, 2, 1]]),
                          ("first death", [[A5 - 0x12B4, 2, 1]]), ("already dead", [[A5 - 0x12B4, 2, 1], [A5 - 0x14C2, 2, 1]]),
                          ("state 2", [[A5 - 0x12B4, 2, 1], [A5 - 0x12F8, 2, 2]]), ("captured", [[A5 - 0x12B4, 2, 2]]),
                          ("status unchanged", [[A5 - 0x12B4, 2, 1], [first.ROSTER + 64 * 2 + 0x20, 2, 1]])):
        for which in (0, 3):
            out.append(case(f"conclude {which}: {label}", "conclude_mission", [W(which), L(0x11E00)], [which, 0x11E00], writes))
    for label, writes in (("night", [[A5 - 0x137A, 2, 1]]), ("day", []),
                          ("odd sizes", [[A5 - 0x214C, 2, 301], [A5 - 0x214A, 2, -7]]),
                          ("big sizes", [[A5 - 0x214C, 2, 30000], [A5 - 0x214A, 2, 20000]])):
        out.append(case(f"map grid: {label}", "draw_map_grid_and_centre_mark", [], [], writes))
    for label, sym, x, y, writes in (("first symbol", 0x41, 10, 20, []), ("grid drawn", 0x2A, -5, 300, [[A5 - 0x214E, 2, 1]]),
                                     ("high byte", 0x1234_56F0, 0x12345, -70000, [[A5 - 0x214E, 2, 1]])):
        out.append(case(f"plot: {label}", "plot_map_symbol_callback", [L(sym), L(x), L(y)], [sym, x, y], writes))
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    logs = [[e[0], CODE + e[1] if e[0] == "addr" else e[1]] + e[2:] for e in c.get("call_logs", CALL_LOGS)]
    install(emu, A5, logs)
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
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                 "a7": STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        if c["method"] in LONG_RESULT:
            entry["d0"] = d0
        elif c["method"] in WORD_RESULT:
            entry["d0"], entry["d0_mask"] = d0 & 0xFFFF, 0xFFFF
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
