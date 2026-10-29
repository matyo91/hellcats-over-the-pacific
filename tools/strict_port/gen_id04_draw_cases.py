#!/usr/bin/env python3
"""Generate comparison cases for the fourth ID04 batch (the high-score table, the targets-destroyed
rows and list, the aircraft kill markers and the map view, with their user item procedures) by
running the ORIGINAL bytes.

The set-up is gen_id04_filter_cases.py's (ID04.bin at 0x30000, A5 = 0x20000, ID01's switch helpers
at 0x3C000, the same logging stand-ins) with a few more traps and slots; the map's plotting service
(*(A5 - 0x1052)) is an "addr" stand-in at 0x3B000, and the segment routines not ported yet stay
offset-keyed stand-ins ("local" here). GetDItem writes the same box for every item. Each case
records the original's entry stack pointer ("a7"). test_id04_draw.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id04_draw_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id04_dialog_cases as first  # noqa: E402
import gen_id04_filter_cases as third  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id04_draw_cases.json")
MEMORY_SIZE, CODE, A5, ID01_AT = third.MEMORY_SIZE, third.CODE, third.A5, third.ID01_AT
STACK_TOP, STACK_GUARD, LOGS, DIALOG, ROSTER = third.STACK_TOP, third.STACK_GUARD, third.LOGS, third.DIALOG, first.ROSTER
PLOT_SERVICE, SETTINGS_H, SETTINGS, COUNTS = 0x3B000, 0x12200, 0x12240, 0x122C0

STUBS = [["local" if s[0] == "addr" else s[0]] + s[1:] for s in third.STUBS] + [
    ["trap", 0xA887, [2], True, 0], ["trap", 0xAA14, [4], True, 0, {0: 2}], ["trap", 0xA8B8, [4], True, 0, {0: 2}],
    ["trap", 0xA8A2, [4], True, 0], ["jt", 0x1CA, [2, 4], False, 0], ["jt", 0x2EA, [4, 4], True, 2, {}, [1, 0xFFFF, 0]],
    ["addr", PLOT_SERVICE, [4, 4], False, 0]]
CALL_LOGS = [first.log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}

ROUTINES = {"draw_high_scores_table": 0x1200, "draw_targets_destroyed_row": 0x1BC8, "draw_targets_destroyed_list": 0x1D9E,
            "draw_aircraft_kill_markers": 0x1F5E, "aircraft_kill_markers_user_item_proc": 0x20E8, "draw_map_view_item": 0x33D6,
            "map_view_user_item_proc": 0x35F8}


def common() -> list[list[int]]:
    w = third.common()
    w += [[a, 4, 0] for a in range(LOGS + 0x200 * len(third.STUBS), LOGS + 0x200 * len(STUBS), 4)]
    vals = [(A5 - 0x1052, 4, PLOT_SERVICE), (A5 - 0x13AC, 4, SETTINGS_H), (SETTINGS_H, 4, SETTINGS), (SETTINGS + 0x26, 2, 50),
            (A5 - 0x2226, 4, COUNTS), (A5 - 0xE5A, 4, 0x11D80), (0x11900 + 0x44, 2, 3), (LOG_OF[("jt", 0x1CA)] - 4, 4, 0x11DC0),
            (LOG_OF[("jt", 0x4A2)] - 4, 4, 0x11E40)]
    vals += [(A5 - 0xF86 + 4 * k, 4, 0x11B00 + 0x10 * k) for k in range(10)]
    vals += [(A5 - 0xFAE + 4 * k, 4, 0x11A00 + 0x10 * k) for k in range(4)]
    vals += [(A5 - 0xFFE + 4 * k, 4, 0x11C00 + 0x10 * k) for k in range(8)]
    vals += [(COUNTS + 2 * k, 2, [3, 0, 5, 1, 2, 0, 7, -2, 4, 9][k]) for k in range(10)]
    vals += [(ROSTER + 64 * p + 0x22, 2, p % 8) for p in range(20)] + [(ROSTER + 64 * p + 0x20, 2, p % 4) for p in range(20)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list, port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


L, W = first.L, first.W


def build() -> list[dict]:
    named = [[ROSTER + 64 * p, 1, 4] for p in range(13)]
    out = [case("high scores", "draw_high_scores_table", [W(3), L(DIALOG)], [DIALOG, 3]),
           case("high scores, thirteen named", "draw_high_scores_table", [W(3), L(DIALOG)], [DIALOG, 3], named),
           case("high scores, two named with no tallies", "draw_high_scores_table", [W(3), L(DIALOG)], [DIALOG, 3],
                [[ROSTER + 64 * p + 0x28 + 2 * i, 2, 0] for p in range(4) for i in range(12)] + [[ROSTER + 64 * 5, 1, 2], [ROSTER + 64 * 9, 1, 1]])]
    for idx in range(10):
        out.append(case(f"targets row {idx}", "draw_targets_destroyed_row", [L(DIALOG), W(6), W(idx)], [DIALOG, 6, idx]))
    out.append(case("targets list", "draw_targets_destroyed_list", [W(6), L(DIALOG)], [DIALOG, 6]))
    for label, writes in (("49 kills", []), ("none", [[ROSTER + 128 + 0x28, 2, 0], [ROSTER + 128 + 0x2A, 2, 0]]),
                          ("seven", [[ROSTER + 128 + 0x28, 2, 3], [ROSTER + 128 + 0x2A, 2, 4]]),
                          ("negative", [[ROSTER + 128 + 0x28, 2, -9], [ROSTER + 128 + 0x2A, 2, 4]])):
        out.append(case(f"kill markers: {label}", "draw_aircraft_kill_markers", [L(DIALOG), W(8)], [DIALOG, 8], writes))
    out.append(case("kill markers (Pascal)", "aircraft_kill_markers_user_item_proc", [W(8), L(DIALOG)], [DIALOG, 8]))
    for label, writes in (("day", []), ("night", [[A5 - 0x137A, 2, 1]]), ("scale 3", [[SETTINGS + 0x26, 2, 3]]),
                          ("big scale", [[SETTINGS + 0x26, 2, 0x5000]])):
        out.append(case(f"map view: {label}", "draw_map_view_item", [L(DIALOG), W(9)], [DIALOG, 9], writes))
    out.append(case("map view (Pascal)", "map_view_user_item_proc", [W(9), L(DIALOG)], [DIALOG, 9]))
    return out


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE, third.BINARY, file_delta=0x7FFFFFFF)
    code = open(third.BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(third.ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in CALL_LOGS])
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE) if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    base = common()
    logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in CALL_LOGS]
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": logs, "cases": []}
    for c in build():
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"],
                             "changes": run(c, base), "a7": STACK_TOP - sum(size for size, _ in c["stack"]) - 4})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
