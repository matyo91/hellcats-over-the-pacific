#!/usr/bin/env python3
"""Generate comparison cases for the leaf ID02 routines that call the Toolbox (thick lines, colour
entries, port blits, offscreen port, rect paint, segment-3 entry, sound slots, activate event, menu
items, sound shutdown, window / alert placement, palettes) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py (ID02 at 0x30000, A5 = CurrentA5 = 0x20000; the main screen
rect, MBarHeight 0xbaa, a window, an alert template behind GetResource, twenty sound slots,
palettes). Every jump-table slot and trap is a logging stand-in on both sides
(segment_stubs.py); bytes pushed with MOVE.B -(A7) are logged as bytes. test_id02_toolbox.gd
replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_toolbox_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_toolbox_cases.json")
BINARY, MEMORY_SIZE, CODE, A5 = base_layout.BINARY, base_layout.MEMORY_SIZE, base_layout.CODE, base_layout.A5
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
DATA = base_layout.DATA
PORTREC, HANDLE, PIXMAP, RGN = 0x15000, 0x15100, 0x15200, 0x15300
WIN, ALRT_H, ALRT_RECT, SRCPORT, SRC_H, SRC_PM, SND_H = 0x15400, 0x15500, 0x15510, 0x15600, 0x15700, 0x15710, 0x15800
LOGS = 0x16000                                        # 29 logs of 0x100: 0x16000..0x17d00
STUBS = [["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0], ["jt", 0x282, [4], True, 0], ["jt", 0x262, [4], True, 4],
         ["jt", 0x17A, [], False, 0], ["jt", 0x1CA, [2, 2, 2], False, 0],
         ["trap", 0xA873, [4], True, 0], ["trap", 0xAA00, [4], True, 0], ["trap", 0xA8DF, [4, 4], True, 0, {0: 2}],
         ["trap", 0xA89D, [4], True, 0], ["trap", 0xA89B, [2, 2], True, 0], ["trap", 0xA893, [2, 2], True, 0],
         ["trap", 0xA891, [2, 2], True, 0], ["trap", 0xA862, [4], True, 0], ["trap", 0xA863, [4], True, 0],
         ["trap", 0xA89C, [2], True, 0], ["trap", 0xAA3F, [4, 2, 2], True, 0], ["trap", 0xA8EC, [4, 2, 4, 4, 4, 4], True, 0],
         ["trap", 0xA8A2, [4], True, 0], ["trap", 0xA9F1, [4], True, 0], ["trap", 0xA928, [4], True, 0],
         ["trap", 0xA939, [2, 4], True, 0], ["trap", 0xA93A, [2, 4], True, 0], ["trap", 0xA937, [], True, 0],
         ["trap", 0xA801, [1, 4], True, 2], ["trap", 0xA91B, [1, 2, 2, 4], True, 0], ["trap", 0xA9A0, [2, 4], True, 4],
         ["trap", 0xA8A7, [2, 2, 2, 2, 4], True, 0], ["trap", 0xAA95, [2, 4, 4], True, 0]]
CALL_LOGS = [[kind, key, LOGS + 0x100 * i + 4, sizes, pascal, result, (rest[0] if rest else {})]
             for i, (kind, key, sizes, pascal, result, *rest) in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"draw_thick_line_pixel_index_a5safe": 0xA42, "draw_thick_xor_line_a5safe": 0xA86,
            "apply_pending_color_entries_a5safe": 0xC68, "blit_pixels_via_port_a5safe": 0xE3E,
            "open_offscreen_cport_a5safe": 0xE9E, "paint_rect_color_index_a5safe": 0xFA0,
            "run_segment3_entry_and_unload_a5safe": 0x197C, "release_sound_slots": 0x1E68, "lock_sound_slots": 0x20BE,
            "handle_activate_event": 0x2FA0, "set_menu_item_enabled": 0x3590, "shutdown_sound": 0x4318,
            "position_window_on_screen": 0x435E, "position_alert_template": 0x442E, "centre_window_on_screen": 0x4582,
            "detach_window_palette": 0x4610, "select_palette_for_depth": 0x462C}
SLOTS = A5 - 0xD62


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x100 * len(STUBS), 4)]
    vals = [(LOG_OF[("jt", 0x1CA)] - 4, 4, 0x5A5A1234), (LOG_OF[("trap", 0xA9A0)] - 4, 4, ALRT_H), (ALRT_H, 4, ALRT_RECT),
            (ALRT_RECT, 2, 40), (ALRT_RECT + 2, 2, 60), (ALRT_RECT + 4, 2, 200), (ALRT_RECT + 6, 2, 420),
            (LOG_OF[("jt", 0x262)] - 4, 4, SND_H), (LOG_OF[("trap", 0xA801)] - 4, 4, 0xFFFF),
            (PORTREC + 2, 4, HANDLE), (HANDLE, 4, PIXMAP), (PORTREC + 0x18, 4, RGN), (SRCPORT + 2, 4, SRC_H), (SRC_H, 4, SRC_PM),
            (A5 - 0x1680, 2, 0), (A5 - 0x167E, 2, 0), (A5 - 0x167C, 2, 768), (A5 - 0x167A, 2, 1024), (0xBAA, 2, 20),
            (WIN + 0x10, 2, 0x28), (WIN + 0x12, 2, 0x10), (WIN + 0x14, 2, 0x1E0), (WIN + 0x16, 2, 0x280),
            (A5 - 0x14CA, 4, WIN), (A5 - 0x14C6, 2, 1), (A5 - 0x14AE, 4, 0x1A100), (A5 - 0x14AA, 4, 0x1A200), (A5 - 0x2CC, 2, 0),
            (A5 - 0x356, 4, 0x1A300), (A5 - 0xC36, 4, 0x339A8), (A5 - 0x14B2, 4, 0x1A400), (0x1A406, 2, 6)]
    vals += [(SLOTS + 4 * i, 4, 0) for i in range(20)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


case = base_layout.case
L, W = base_layout.L, base_layout.W


def build() -> list[dict]:
    out = [
        case("thick line", "draw_thick_line_pixel_index_a5safe", [L(0x33), L(0x10012), L(-5), L(300), L(0xFFFF0040)],
             [0x33, 0x10012, -5, 300, 0xFFFF0040]),
        case("thick xor line", "draw_thick_xor_line_a5safe", [L(7), L(-8), L(0x20009), L(10)], [7, -8, 0x20009, 10]),
        case("pending colour entries", "apply_pending_color_entries_a5safe", [], []),
        case("pending colour entries, none", "apply_pending_color_entries_a5safe", [], [], [[0x1A406, 2, 0]]),
        case("blit to the current port", "blit_pixels_via_port_a5safe", [L(SRCPORT), L(0x40000), L(DATA), L(0), L(DATA + 8)],
             [SRCPORT, 0x40000, DATA, 0, DATA + 8]),
        case("blit to another port", "blit_pixels_via_port_a5safe", [L(SRCPORT), L(0x50000), L(DATA), L(PORTREC), L(DATA + 8)],
             [SRCPORT, 0x50000, DATA, PORTREC, DATA + 8]),
        case("open offscreen port", "open_offscreen_cport_a5safe", [L(PORTREC), L(0x140), L(0x60000), L(DATA)],
             [PORTREC, 0x140, 0x60000, DATA], [[DATA, 2, 10], [DATA + 2, 2, 20], [DATA + 4, 2, 250], [DATA + 6, 2, 340]]),
        case("open offscreen port, row bytes with bit 15", "open_offscreen_cport_a5safe", [L(PORTREC), L(0x18010), L(0), L(DATA)],
             [PORTREC, 0x18010, 0, DATA], [[DATA, 2, -4], [DATA + 2, 2, -8], [DATA + 4, 2, 4], [DATA + 6, 2, 8]]),
        case("segment 3 entry and unload", "run_segment3_entry_and_unload_a5safe", [], []),
    ]
    for depth in (1, 8):
        out.append(case(f"paint rect index 3 depth {depth}", "paint_rect_color_index_a5safe", [L(DATA), L(0x10003)], [DATA, 0x10003],
                        [[A5 - 0x137A, 2, depth]]))
    slots = [[SLOTS + 4 * i, 4, 0x18000 + 0x40 * i] for i in (0, 3, 19)]
    out += [
        case("release sound slots", "release_sound_slots", [], [], slots),
        case("release sound slots, handles not found", "release_sound_slots", [], [], slots + [[LOG_OF[("jt", 0x262)] - 4, 4, 0]]),
        case("release with no slots", "release_sound_slots", [], []),
        case("lock sound slots", "lock_sound_slots", [], [],
             [[SLOTS + 4 * i, 4, SND_H + 8 * i] for i in (1, 7)] + [[SND_H + 8, 4, 0x19000], [SND_H + 56, 4, 0x19800]]),
    ]
    ev = lambda what, msg, mods: ([W(what), L(msg), L(12345), L(0x00400080), W(mods)], [what, msg, 12345, 0x00400080, mods])
    for name, msg, mods, extra in (("game window activated", WIN, 0x0103, []), ("deactivate", WIN, 0x0102, []),
                                   ("another window", 0x15900, 0x0003, []), ("flag off", WIN, 3, [[A5 - 0x14C6, 2, 0]]),
                                   ("no game window", 0, 3, [[A5 - 0x14CA, 4, 0]])):
        stack, args = ev(8, msg, mods)
        out.append(case(f"activate: {name}", "handle_activate_event", stack, args, extra))
    for item, enable in ((3, 1), (3, 0), (0, 1), (0, 0)):
        out.append(case(f"menu item {item} enable {enable}", "set_menu_item_enabled", [L(0x1A500), W(item), W(enable)],
                        [0x1A500, item, enable]))
    out += [
        case("shutdown sound", "shutdown_sound", [], []),
        case("shutdown sound, not running", "shutdown_sound", [], [], [[A5 - 0xC38, 2, 0]]),
        case("position window (fits)", "position_window_on_screen", [L(WIN)], [WIN]),
        case("position tall window", "position_window_on_screen", [L(WIN)], [WIN], [[WIN + 0x14, 2, 0x330]]),
        case("position window on a small odd screen", "position_window_on_screen", [L(WIN)], [WIN],
             [[A5 - 0x167C, 2, 341], [A5 - 0x167A, 2, 513], [WIN + 0x16, 2, 0x281]]),
        case("position alert (third)", "position_alert_template", [W(129)], [129]),
        case("position tall alert (half)", "position_alert_template", [W(130)], [130], [[ALRT_RECT + 4, 2, 700]]),
        case("centre window", "centre_window_on_screen", [L(WIN)], [WIN]),
        case("centre window with odd sizes", "centre_window_on_screen", [L(WIN)], [WIN], [[0xBAA, 2, 21], [WIN + 0x12, 2, -3]]),
        case("detach palette", "detach_window_palette", [], [], [[A5 - 0x2CC, 2, 8]]),
        case("detach palette, no window", "detach_window_palette", [], [], [[A5 - 0x14CA, 4, 0], [A5 - 0x2CC, 2, 8]]),
    ]
    for depth, current in ((4, 0), (8, 4), (1, 8), (2, 4), (8, 8)):
        out.append(case(f"palette for depth {depth} (was {current})", "select_palette_for_depth", [], [],
                        [[A5 - 0x137A, 2, depth], [A5 - 0x2CC, 2, current]]))
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
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": [[k, key, b, s, p, r, {str(i): n for i, n in d.items()}] for k, key, b, s, p, r, d in CALL_LOGS], "cases": []}
    for c in build():
        changes, _d0 = run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
