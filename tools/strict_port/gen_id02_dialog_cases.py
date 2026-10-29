#!/usr/bin/env python3
"""Generate comparison cases for the next ID02 Toolbox batch (offscreen frame blit, notched frame
polygon, view frame outline, FreeMem, the caution alert with a number, the sound-error and
"creating" dialogs, the menu bar) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py. Every slot and trap is a logging stand-in on both sides
(segment_stubs.py): ParamText logs its third string by content (it may be the caller's frame);
Button is scripted up, down, down, up so the click-wait loops end; GetNewDialog / GetMenu /
GetResource / OpenPoly / NewPtr return prepared records. test_id02_dialog.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_dialog_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_dialog_cases.json")
BINARY, MEMORY_SIZE, CODE, A5 = base_layout.BINARY, base_layout.MEMORY_SIZE, base_layout.CODE, base_layout.A5
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
DATA, PORT = base_layout.DATA, base_layout.PORT
PORTREC, HANDLE, PIXMAP, RGN = 0x15000, 0x15100, 0x15200, 0x15300
DIALOG, ALRT_H, ALRT_RECT, POLY, MENU = 0x15400, 0x15500, 0x15510, 0x15600, 0x15700
LOGS = 0x16000                                        # 27 logs of 0x100: 0x16000..0x17b00
STUBS = [["jt", 0x212, [], True, 4], ["jt", 0x302, [4], False, 0], ["jt", 0x2FA, [4], False, 0], ["jt", 0x232, [4], True, 4],
         ["trap", 0xA862, [4], True, 0], ["trap", 0xA863, [4], True, 0], ["trap", 0xA8EC, [4, 2, 4, 4, 4, 4], True, 0],
         ["trap", 0xAA00, [4], True, 0], ["trap", 0xA873, [4], True, 0], ["trap", 0xA8DF, [4, 4], True, 0, {0: 2}],
         ["trap", 0xA8CB, [], True, 4], ["trap", 0xA8CC, [], True, 0], ["trap", 0xA893, [2, 2], True, 0],
         ["trap", 0xA891, [2, 2], True, 0], ["trap", 0xA892, [2, 2], True, 0], ["trap", 0xA98B, [4, 4, 4, 4], True, 0, {2: "pstr"}],
         ["trap", 0xA988, [4, 2], True, 2], ["trap", 0xA9A0, [2, 4], True, 4], ["trap", 0xA8A7, [2, 2, 2, 2, 4], True, 0],
         ["trap", 0xA97C, [4, 4, 2], True, 4], ["trap", 0xA915, [4], True, 0], ["trap", 0xA981, [4], True, 0],
         ["trap", 0xA983, [4], True, 0], ["trap", 0xA974, [], True, 2, {}, [0, 0x100, 0x100, 0]], ["trap", 0xA91B, [1, 2, 2, 4], True, 0],
         ["trap", 0xA9BF, [2], True, 4], ["trap", 0xA935, [2, 4], True, 0], ["trap", 0xA94D, [4, 4], True, 0],
         ["trap", 0xA937, [], True, 0]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x100 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"blit_offscreen_frame_to_window": 0xD3A, "build_notched_frame_poly": 0x10CE, "draw_view_frame_outline": 0x16AA,
            "freemem_a5safe": 0x1B14, "show_caution_alert_with_number": 0x1D48, "show_sound_error_dialog_once": 0x1DD4,
            "show_creating_panel_dialog": 0x1E32, "install_menus": 0x30FA}
RESULT = {"build_notched_frame_poly", "freemem_a5safe", "show_creating_panel_dialog"}


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x100 * len(STUBS), 4)]
    vals = [(LOG_OF[("jt", 0x212)] - 4, 4, 0x123456), (LOG_OF[("jt", 0x232)] - 4, 4, PORTREC), (LOG_OF[("trap", 0xA8CB)] - 4, 4, POLY),
            (LOG_OF[("trap", 0xA988)] - 4, 4, 1), (LOG_OF[("trap", 0xA9A0)] - 4, 4, ALRT_H), (LOG_OF[("trap", 0xA97C)] - 4, 4, DIALOG),
            (LOG_OF[("trap", 0xA9BF)] - 4, 4, MENU), (ALRT_H, 4, ALRT_RECT), (ALRT_RECT, 2, 40), (ALRT_RECT + 2, 2, 60),
            (ALRT_RECT + 4, 2, 200), (ALRT_RECT + 6, 2, 420), (PORTREC + 2, 4, HANDLE), (HANDLE, 4, PIXMAP), (PORTREC + 0x18, 4, RGN),
            (A5 - 0x1680, 2, 0), (A5 - 0x167E, 2, 0), (A5 - 0x167C, 2, 768), (A5 - 0x167A, 2, 1024), (0xBAA, 2, 20),
            (DIALOG + 0x10, 2, 0x28), (DIALOG + 0x12, 2, 0x10), (DIALOG + 0x14, 2, 0xC8), (DIALOG + 0x16, 2, 0x190),
            (A5 - 0x1372, 2, 640), (A5 - 0x1370, 2, 480), (A5 - 0x137E, 2, 16), (A5 - 0x103A, 4, 0), (A5 - 0xD12, 2, 0),
            (PORT + 0x34, 2, 12), (PORT + 0x36, 2, -7)]
    for k, off in enumerate((-0xD0E, -0xD0C, -0xD0A, -0xD08, -0xD06, -0xD04, -0xD02)):
        vals.append((A5 + off, 1, 0))
    vals += [(DATA + k, 1, b) for k, b in enumerate(b"Out of memory\x00")]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


case = base_layout.case
L, W = base_layout.L, base_layout.W


def build() -> list[dict]:
    out = []
    for name, extra in (("first blit makes the port", []), ("later blit reuses the port", [[A5 - 0x103A, 4, PORTREC]]),
                        ("first blit at depth 4", [[A5 - 0x137A, 2, 4], [A5 - 0x1372, 2, 321]])):
        for mode in (1, 2, 3):
            out.append(case(f"{name}, mode {mode}", "blit_offscreen_frame_to_window", [L(0x40000), L(30), L(0x10050), L(mode)],
                            [0x40000, 30, 0x10050, mode], extra))
    for a, b, c, d in ((10, 20, 300, 400), (0, 0, 100, 50), (-5, 7, 9, -3)):
        out.append(case(f"notched poly {a},{b},{c},{d}", "build_notched_frame_poly", [W(a), W(b), W(c), W(d)], [a, b, c, d]))
    for depth in (1, 8):
        out.append(case(f"view frame outline depth {depth}", "draw_view_frame_outline", [], [], [[A5 - 0x137A, 2, depth]]))
    out.append(case("free memory", "freemem_a5safe", [], []))
    for msg, number in ((DATA, 0), (DATA, 1234), (DATA, -32768), (0, 7)):
        out.append(case(f"caution alert msg {msg:#x} number {number}", "show_caution_alert_with_number", [L(msg), W(number)],
                        [msg, number]))
    out += [
        case("sound error dialog", "show_sound_error_dialog_once", [], []),
        case("sound error dialog already shown", "show_sound_error_dialog_once", [], [], [[A5 - 0xD12, 2, 1]]),
        case("creating dialog", "show_creating_panel_dialog", [], []),
        case("install menus", "install_menus", [], []),
    ]
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
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_guard": list(STACK_GUARD), "common_writes": base, "call_logs": logs, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] in RESULT:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
