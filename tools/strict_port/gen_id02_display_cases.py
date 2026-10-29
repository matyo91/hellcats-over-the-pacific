#!/usr/bin/env python3
"""Generate comparison cases for the ID02 display and settings routines (layout_game_window_and_view,
configure_display_from_main_device, apply_settings_to_live_options) by running the ORIGINAL bytes.

The set-up is gen_id02_session_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, ID01 behind slot $3a, the Memory, Resource
and alert stand-ins, the overlay hooks, redraw_main_window running for real in 1-bit mode) with the
device traps (three devices walked by GetNextDevice, the main one scripted per case), the window,
palette and origin traps, HasDeepScreens, the view-buffer slots ($1aa / $1b2 / $1d2) and the overlay's
settings hooks (A5 - 0x10a2 / - 0x1092 / - 0x104e / - 0x1096) as logging stand-ins, and the unexported
offscreen-port close (0xd24) as an offset-keyed stand-in. scan_display_devices, configure_palette_
entries, select_palette_for_depth, show_caution_alert_with_number and fatal_memory_error_exit run
for real. Each case records the original's entry stack pointer ("a7"). test_id02_display.gd replays
the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_display_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_memory_cases as memory  # noqa: E402
import gen_id02_session_cases as session  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_display_cases.json")
A5, CODE, LOGS = memory.A5, memory.CODE, memory.LOGS
DEVS = [0x17000, 0x17100, 0x17200]                    # device record, its handle +0x80, pixmap +0x90 (handle at +0x88)
NEW_WINDOW, PAL4, PAL8, SET_H, SET = 0x17800, 0x17A00, 0x17B00, 0x17C00, 0x17C10
ID01, ID01_AT = "sources/resedit-1-0-3/CODE/ID01.bin", 0x5C000   # ID01's dense switch helper behind slot $3a
HOOKS = {-0x10A2: 0x3A500, -0x1092: 0x3A600, -0x104E: 0x3A700, -0x1096: 0x3A800}
H = [d + 0x80 for d in DEVS]
STUBS = session.STUBS + [
    ["jt", 0x2DA, [], True, 2], ["jt", 0x232, [4], True, 4], ["trap", 0xAA29, [], True, 4], ["trap", 0xAA2A, [], True, 4, {}, [H[1]] * 2],
    ["trap", 0xAA2B, [4], True, 4, {}, [H[1], H[2], 0] * 2], ["trap", 0xA916, [4], True, 0], ["trap", 0xA91D, [1, 2, 2, 4], True, 0],
    ["trap", 0xAA45, [4, 1, 4, 2, 1, 4, 4, 4], True, 4, {5: "pstr", 6: 2}], ["trap", 0xAA91, [2, 2, 4, 2], True, 4, {}, [PAL4, PAL8]],
    ["trap", 0xA873, [4], True, 0], ["trap", 0xA878, [2, 2], True, 0], ["trap", 0xAA9E, [2, 2, 2, 4], True, 0, {-1: "digest"}],
    ["trap", 0xAA9C, [4, 2, 4], True, 0, {-1: "digest"}], ["trap", 0xAA95, [1, 4, 4], True, 0],
    ["jt", 0x1B2, [], False, 0], ["jt", 0x1AA, [4, 2, 2, 2, 2], False, 2], ["jt", 0x1D2, [], False, 4],
    ["local", 0xD24, [4], False, 0]] + [["addr", v, [], False, 0] for v in HOOKS.values()]
CALL_LOGS = [memory.log_entry(i, s) for i, s in enumerate(STUBS)]
INDEX = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"layout_game_window_and_view": 0x2334, "configure_display_from_main_device": 0x27E4,
            "apply_settings_to_live_options": 0x2A44}
L, W = memory.L, memory.W


def device(i: int, top: int, left: int, bottom: int, right: int, pixel_size: int = 8) -> list:
    rec = DEVS[i]
    h, pmh, pm = rec + 0x80, rec + 0x88, rec + 0x90
    return [(h, 4, rec), (rec + 4, 2, 2), (rec + 0x14, 1, 1), (rec + 0x16, 4, pmh), (pmh, 4, pm), (pm, 4, 0x400000 + 0x10000 * i),
            (pm + 4, 2, 0x8000 | (0x280 + 0x40 * i)), (pm + 6, 2, top), (pm + 8, 2, left), (pm + 10, 2, bottom), (pm + 12, 2, right),
            (pm + 0x20, 2, pixel_size)]


def settings(**over: int) -> list:
    rec = {2: 1, 4: 2, 6: 3, 8: 4, 0xA: 5, 0xC: 1, 0xE: 1, 0x10: 6, 0x12: 7, 0x14: 8, 0x16: 9, 0x18: 10, 0x1A: 11, 0x1C: 0,
           0x22: 12, 0x24: 13}
    rec.update({int(k[1:], 16): v for k, v in over.items()})
    return [(SET + k, 2, v) for k, v in rec.items()]


def common() -> list[list[int]]:
    w = session.common() + [[a, 4, 0] for a in range(LOGS + 0x400 * len(session.STUBS), LOGS + 0x400 * len(STUBS), 4)]
    w += [[a, 4, 0] for a in range(0x17000, 0x18000, 4)]
    vals = [(A5 + k, 4, v) for k, v in HOOKS.items()] + [(A5 + 0x3A, 2, 0x4EF9), (A5 + 0x3C, 4, ID01_AT + 0xBE)]
    vals += [(LOG_OF[("trap", 0xAA29)] - 4, 4, H[0]), (LOG_OF[("jt", 0x232)] - 4, 4, 0x17E00), (LOG_OF[("trap", 0xAA45)] - 4, 4, NEW_WINDOW),
             (LOG_OF[("jt", 0x1AA)] - 4, 4, 1), (LOG_OF[("jt", 0x1D2)] - 4, 4, 0xABCDE0), (A5 - 0x13AC, 4, SET_H), (SET_H, 4, SET),
             (A5 - 0x137E, 2, 640), (A5 - 0x137C, 2, 460), (A5 - 0x137A, 2, 8), (A5 - 0xD76, 4, memory.DATA), (A5 - 0x102E, 2, 1),
             (A5 - 0x2CC, 2, 0), (A5 - 0x1346, 4, 0x17D00), (A5 - 0x134A, 2, 3)]
    vals += [(A5 - 0xC92 + k, 1, b) for k, b in enumerate(b"\x04Game")]
    vals += device(0, 0, -640, 480, 0) + device(1, 0, 0, 480, 640) + device(2, 0, 640, 480, 1280)
    for i, base in ((1, 0x400000), (2, 0x410000)):
        rec = A5 - 0x136E + 0x16 * i
        vals += [(rec, 4, H[i]), (rec + 0xA, 4, base), (rec + 0xE, 2, 0x280)]
    vals += settings()
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list, args: list[int], writes: list = (), results: dict | None = None) -> dict:
    c = memory.case(name, method, stack, args, writes)
    if results:
        logs = copy.deepcopy(CALL_LOGS)
        for key, r in results.items():
            logs[INDEX[key]][7:] = [r]
        c["call_logs"] = logs
    return c


def layout(name: str, rect: tuple, writes: list = (), results: dict | None = None) -> dict:
    return case(f"layout: {name}", "layout_game_window_and_view", [W(v) for v in rect], list(rect), writes, results)


def build() -> list[dict]:
    screen = (20, 0, 480, 640)
    two = [[SET + 0x1C, 2, 1], [A5 - 0x1032, 2, 1], [A5 - 0x1342, 4, H[0]]]
    out = [
        layout("whole view, depth 8", screen),
        layout("half view, depth 4", screen, [[SET + 0xE, 2, 2], [A5 - 0x137A, 2, 4]]),
        layout("three quarters, depth 8", screen, [[SET + 0xE, 2, 3]]),
        layout("quarter, depth 1", screen, [[SET + 0xE, 2, 4], [A5 - 0x137A, 2, 1]]),
        layout("no size option", screen, [[SET + 0xE, 2, 0]]),
        layout("two screens with a left device", screen, two),
        layout("two screens, no left device", screen, two[:2] + [[A5 - 0x1342, 4, 0]]),
        layout("512 x 322 skips the menu bar", (20, 0, 342, 512), [[A5 - 0x137E, 2, 512], [A5 - 0x137C, 2, 322], [A5 - 0x1028, 2, 0]]),
        layout("menu bar already skipped", (0, 0, 342, 512), [[A5 - 0x137E, 2, 512], [A5 - 0x137C, 2, 342], [A5 - 0x1028, 2, 1]]),
        layout("skipped, now a wider screen", screen, [[A5 - 0x1028, 2, 1]]),
        layout("short rect shrinks the view", (20, 0, 200, 640)),
        layout("short rect, depth 2", (20, 0, 300, 640), [[A5 - 0x137A, 2, 2]]),
        layout("new window at depth 4", screen, [[A5 - 0x14CA, 4, 0], [A5 - 0x137A, 2, 4]]),
        layout("new window at depth 8", screen, [[A5 - 0x14CA, 4, 0]]),
        layout("visible window, offscreen port, resize hook", screen,
               [[session.WINDOW + 0x6E, 1, 0xFF], [A5 - 0x103A, 4, 0x17F00]]),
        layout("depth 1 buffer fails", screen, [[A5 - 0x137A, 2, 1]], {("jt", 0x1AA): [0]}),
        layout("offset rect", (60, 100, 500, 900), [[SET + 0xE, 2, 2]]),
    ]
    cfg = "configure_display_from_main_device"
    out += [
        case("configure: depth 8", cfg, [], []),
        case("configure: depth 1", cfg, [], [], [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in device(1, 0, 0, 480, 640, 1)]),
        case("configure: deep screens", cfg, [], [], [[LOG_OF[("jt", 0x2DA)] - 4, 4, 0x100]]),
        case("configure: depth 2 stays", cfg, [], [], [[DEVS[1] + 0x90 + 0x20, 2, 2], [session.WINDOW + 0x6E, 1, 1]]),
        case("configure: depth 2, then a depth 8 main", cfg, [], [], [[DEVS[1] + 0x90 + 0x20, 2, 2], [session.WINDOW + 0x6E, 1, 1]],
             {("trap", 0xAA2A): [H[1], H[2]]}),
        case("configure: hidden window shown again", cfg, [], [], [[A5 - 0xD10, 2, 1]]),
        case("configure: hidden, no game", cfg, [], [], [[A5 - 0xD10, 2, 1], [A5 - 0x12F8, 2, 0]]),
    ]
    app = "apply_settings_to_live_options"
    same = [[A5 + g, 2, v] for g, v in ((-0x12E0, 6), (-0x12D8, 10), (-0x12E6, 4), (-0x12DC, 8), (-0x12DA, 9), (-0x12DE, 7))]
    out += [
        case("settings: all changed, depth 1", app, [], [], [[A5 - 0x137A, 2, 1]]),
        case("settings: nothing changed", app, [], [], same),
        case("settings: only +0x16", app, [], [], same[:4] + [[A5 - 0x137A, 2, 1]]),
        case("settings: depth 8, window down", app, [], [], same[:5] + [[A5 - 0x14C6, 2, 0]]),
        case("settings: depth 8, no frame buffer", app, [], [], [[A5 - 0x1006, 4, 0]]),
    ]
    return out


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(memory.MEMORY_SIZE, memory.BINARY, file_delta=0x7FFFFFFF)
    code = open(memory.BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(ID01, "rb").read()[:0x22E]
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


def main() -> None:
    base = common()
    out = {"memory_size": memory.MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
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
