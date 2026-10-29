#!/usr/bin/env python3
"""Generate comparison cases for the ID02 polygon / frame / image-blit / colour-state routines
(paint_polygon_rgb_a5safe, draw_notched_frame_pair_a5safe, blit_image_clipped_to_region and its a5safe
wrapper, check_device_color_state_changed) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py. Every slot, trap and the service called through A5 - 0x1096
is a logging stand-in on both sides (segment_stubs.py; the service is an "addr" stub). The colour
state check builds its maps in its frame (the port models A7); the new map it reports to JT $182
is not logged (its tail past the count is uninitialised frame). test_id02_draw.gd replays the
cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_draw_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_draw_cases.json")
BINARY, CODE, A5 = base_layout.BINARY, base_layout.CODE, base_layout.A5
MEMORY_SIZE = 0x60000
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
DATA, PORT = base_layout.DATA, base_layout.PORT
SERVICE = 0x58000                                    # the indirect service's code address (stand-in)
IMG_PORT, IMG_PH, IMG_PM, IMG_H, IMG_DATA, ROW_H, ROW_TABLE = 0x15000, 0x15080, 0x15090, 0x15100, 0x15200, 0x15300, 0x15400
MAPS = 0x15800
LOGS = 0x40000                                       # logs of 0x1000: 0x40000..
STUBS = [["jt", 0x1CA, [2, 2, 2], False, 0], ["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0],
         ["jt", 0x2D2, [4], True, 2], ["jt", 0x182, [4, 4], False, 0, {1: 0}], ["addr", SERVICE, [], False, 0],
         ["trap", 0xA8CB, [], True, 4], ["trap", 0xA8CC, [], True, 0], ["trap", 0xA893, [2, 2], True, 0],
         ["trap", 0xA891, [2, 2], True, 0], ["trap", 0xA892, [2, 2], True, 0], ["trap", 0xA8CA, [4, 4], True, 0],
         ["trap", 0xA8C7, [4], True, 0], ["trap", 0xA8C6, [4], True, 0], ["trap", 0xA8CD, [4], True, 0],
         ["trap", 0xA8CE, [2, 2, 4], True, 0], ["trap", 0xAA14, [4], True, 0, {0: 2}], ["trap", 0xA89B, [2, 2], True, 0],
         ["trap", 0xA862, [4], True, 0], ["trap", 0xA863, [4], True, 0], ["trap", 0xA89D, [4], True, 0],
         ["trap", 0xA8D8, [], True, 4, {}, [0x16100, 0x16200]], ["trap", 0xA8D9, [4], True, 0], ["trap", 0xA8DA, [], True, 0],
         ["trap", 0xA8DB, [4], True, 0], ["trap", 0xA879, [4], True, 0], ["trap", 0xA87A, [4], True, 0],
         ["trap", 0xA8EC, [4, 2, 4, 4, 4, 4], True, 0], ["trap", 0xA924, [], True, 4], ["trap", 0xAA32, [], True, 4],
         ["trap", 0xAA31, [4], True, 0], ["trap", 0xAA97, [2], True, 0]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x1000 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"paint_polygon_rgb_a5safe": 0xFD2, "draw_notched_frame_pair_a5safe": 0x11EC, "blit_image_clipped_to_region": 0x1876,
            "blit_image_clipped_to_region_a5safe": 0x195C, "check_device_color_state_changed": 0x4C18}


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x1000 * len(STUBS), 4)]
    w += [[a, 4, 0] for a in range(0x15000, 0x16000, 4)]
    vals = [(LOG_OF[("jt", 0x1CA)] - 4, 4, 0x5A5A1234), (LOG_OF[("trap", 0xA8CB)] - 4, 4, 0x16000), (LOG_OF[("jt", 0x2D2)] - 4, 4, 0),
            (LOG_OF[("trap", 0xAA32)] - 4, 4, 0x16300),
            (A5 - 0x119C, 2, 300), (A5 - 0x119A, 2, 20), (A5 - 0x1198, 2, 360), (A5 - 0x1196, 2, 200), (A5 - 0x1192, 2, 400),
            (A5 - 0x118C, 2, 7), (A5 - 0x118A, 2, 9), (A5 - 0x14E2, 4, 0x77), (PORT + 0x34, 2, 3), (PORT + 0x36, 2, 5),
            (A5 - 0x1372, 2, 640), (A5 - 0x1370, 2, 480), (A5 - 0x149E, 4, 0x1400), (A5 - 0x137A, 2, 8),
            (A5 - 0x1496, 4, IMG_PORT), (IMG_PORT + 2, 4, IMG_PH), (IMG_PH, 4, IMG_PM), (IMG_PORT + 0x10, 4, 0x00100020),
            (IMG_PORT + 0x14, 4, 0x01000180), (A5 - 0x12B0, 4, IMG_H), (IMG_H, 4, IMG_DATA), (A5 - 0x13B2, 4, ROW_H), (ROW_H, 4, ROW_TABLE),
            (A5 - 0x13AE, 2, 2), (ROW_TABLE + 2 * 0x160 + 0xA, 2, 0x8280), (A5 - 0x2CC, 2, 8), (PORT + 0x52, 2, 0x41),
            (A5 - 0x1006, 4, 1), (A5 - 0x1096, 4, SERVICE), (A5 - 0x1354, 4, 0x16400)]
    for i in range(1, 4):
        vals += [(A5 - 0x136E + 0x16 * i, 4, 0), (A5 - 0x136E + 0x16 * i + 4, 4, MAPS + 0x200 * (i - 1))]
    pts = [(10, 20), (300, -40), (-50, 70), (0x12345, 0x7FFF)]
    for k, (x, y) in enumerate(pts):
        vals += [(DATA + 8 * k, 4, x), (DATA + 8 * k + 4, 4, y)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


case = base_layout.case
L, W = base_layout.L, base_layout.W


def build() -> list[dict]:
    out = []
    for depth in (1, 8):
        for n, rgb in ((4, 0x11223344), (1, 0xFF80FF00), (0, 0x01020300), (-2, 0x80000000)):
            out.append(case(f"polygon of {n} depth {depth}", "paint_polygon_rgb_a5safe", [L(DATA), L(n), L(rgb)], [DATA, n, rgb],
                            [[A5 - 0x137A, 2, depth]]))
    for paint in (1, 0):
        out.append(case(f"notched frame pair paint {paint}", "draw_notched_frame_pair_a5safe", [L(paint), L(0x10003), L(0xFFFF0005)],
                        [paint, 0x10003, 0xFFFF0005]))
    out += [
        case("image blit, handle unlocked", "blit_image_clipped_to_region", [], []),
        case("image blit, handle already locked", "blit_image_clipped_to_region", [], [], [[LOG_OF[("jt", 0x2D2)] - 4, 4, 0x8000]]),
        case("image blit at depth 1", "blit_image_clipped_to_region", [], [], [[A5 - 0x137A, 2, 1]]),
        case("image blit a5safe", "blit_image_clipped_to_region_a5safe", [], []),
    ]
    devs = [[A5 - 0x136E + 0x16 * 1, 4, 0x16500], [A5 - 0x136E + 0x16 * 3, 4, 0x16600]]
    same = [[MAPS + 2 * i, 2, 0x41] for i in range(0xD9)] + [[MAPS + 0x400 + 2 * i, 2, 0x41] for i in range(0xD9)]
    out += [
        case("colour state: both maps changed", "check_device_color_state_changed", [], [], devs),
        case("colour state: unchanged", "check_device_color_state_changed", [], [], devs + same),
        case("colour state: changed, no service", "check_device_color_state_changed", [], [], devs + [[A5 - 0x1006, 4, 0]]),
        case("colour state: only device 3 changed", "check_device_color_state_changed", [], [],
             devs + [[MAPS + 2 * i, 2, 0x41] for i in range(0xD9)]),
        case("colour state: palette depth 4", "check_device_color_state_changed", [], [],
             devs + [[A5 - 0x2CC, 2, 4], [PORT + 0x52, 2, 3]] + [[MAPS + 2 * i, 2, 3] for i in range(5)]),
        case("colour state at depth 1", "check_device_color_state_changed", [], [], devs + [[A5 - 0x137A, 2, 1]]),
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
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": logs, "cases": []}
    for c in build():
        changes, _d0 = run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
