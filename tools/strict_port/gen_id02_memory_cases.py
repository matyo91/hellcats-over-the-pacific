#!/usr/bin/env python3
"""Generate comparison cases for the ID02 memory / sound-set / horizon routines
(fatal_memory_error_exit, new_handle_clear_or_die_a5safe, realloc_and_clear_handle_a5safe,
load_game_sounds, paint_view_horizon_bands_a5safe) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py. Every slot and trap is a logging stand-in on both sides
(segment_stubs.py); ExitToShell returns (the RTS after it ends the routine); GetNamedResource is
scripted so the eleventh sound is missing and its fallback loads; Button is scripted down / up for
the sound error dialog; MemError reads its log's result word. test_id02_memory.gd replays the
cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_memory_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_memory_cases.json")
BINARY, CODE, A5 = base_layout.BINARY, base_layout.CODE, base_layout.A5
MEMORY_SIZE = 0x60000
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
DATA, PORT = base_layout.DATA, base_layout.PORT
SND, NEWH, BLOCK, DIALOG, ALRT_H, ALRT_RECT = 0x15000, 0x15100, 0x15200, 0x15400, 0x15500, 0x15510
LOGS = 0x40000
STUBS = [["jt", 0x23A, [4], True, 0], ["jt", 0x252, [4], True, 4], ["jt", 0x29A, [], True, 2], ["jt", 0x26A, [4, 4], True, 0],
         ["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0], ["jt", 0x282, [4], True, 0], ["jt", 0x28A, [4], True, 0],
         ["jt", 0x212, [], True, 4], ["jt", 0x21A, [4], True, 4, {0: 0}], ["jt", 0x262, [4], True, 4], ["jt", 0x302, [4], False, 0],
         ["jt", 0x2FA, [4], False, 0], ["jt", 0x1CA, [2, 2, 2], False, 0],
         ["trap", 0xA9F4, [], True, 0], ["trap", 0xA801, [1, 4], True, 2], ["trap", 0xA98B, [4, 4, 4, 4], True, 0, {2: "pstr"}],
         ["trap", 0xA9A0, [2, 4], True, 4], ["trap", 0xA8A7, [2, 2, 2, 2, 4], True, 0], ["trap", 0xA988, [4, 2], True, 2],
         ["trap", 0xA9A1, [4, 4], True, 4, {}, [SND] * 10 + [0, SND]], ["trap", 0xA9A3, [4], True, 0], ["trap", 0xA9A6, [4], True, 2],
         ["trap", 0xA9A7, [2, 4], True, 0], ["trap", 0xA9AA, [4], True, 0], ["trap", 0xA97C, [4, 4, 2], True, 4],
         ["trap", 0xA915, [4], True, 0], ["trap", 0xA981, [4], True, 0], ["trap", 0xA983, [4], True, 0],
         ["trap", 0xA974, [], True, 2, {}, [0, 0x100, 0x100, 0]], ["trap", 0xA91B, [1, 2, 2, 4], True, 0],
         ["trap", 0xA8D8, [], True, 4], ["trap", 0xA87A, [4], True, 0], ["trap", 0xA879, [4], True, 0],
         ["trap", 0xA8A2, [4], True, 0, {0: 2}], ["trap", 0xA8CB, [], True, 4], ["trap", 0xA893, [2, 2], True, 0],
         ["trap", 0xA891, [2, 2], True, 0], ["trap", 0xA8CC, [], True, 0], ["trap", 0xA8C7, [4], True, 0], ["trap", 0xA8CD, [4], True, 0],
         ["trap", 0xA89D, [4], True, 0], ["trap", 0xA8D9, [4], True, 0]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x400 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"fatal_memory_error_exit": 0x19E2, "new_handle_clear_or_die_a5safe": 0x19A2, "realloc_and_clear_handle_a5safe": 0x1A28,
            "load_game_sounds": 0x1F8E, "paint_view_horizon_bands_a5safe": 0xAD0}
RESULT = {"new_handle_clear_or_die_a5safe"}


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x400 * len(STUBS), 4)]
    w += [[a, 4, 0] for a in range(0x15000, 0x16000, 4)]
    vals = [(LOG_OF[("jt", 0x252)] - 4, 4, NEWH), (LOG_OF[("jt", 0x212)] - 4, 4, 0x100000), (LOG_OF[("jt", 0x21A)] - 4, 4, 0x200000),
            (LOG_OF[("jt", 0x262)] - 4, 4, SND), (LOG_OF[("jt", 0x1CA)] - 4, 4, 0x5A5A1234), (LOG_OF[("trap", 0xA9A0)] - 4, 4, ALRT_H),
            (LOG_OF[("trap", 0xA97C)] - 4, 4, DIALOG), (LOG_OF[("trap", 0xA8D8)] - 4, 4, 0x15800), (LOG_OF[("trap", 0xA8CB)] - 4, 4, 0x15900),
            (LOG_OF[("trap", 0xA9A6)] - 4, 4, 0x0004), (ALRT_H, 4, ALRT_RECT), (ALRT_RECT, 2, 40), (ALRT_RECT + 2, 2, 60),
            (ALRT_RECT + 4, 2, 200), (ALRT_RECT + 6, 2, 420), (NEWH, 4, BLOCK),
            (A5 - 0x1680, 2, 0), (A5 - 0x167E, 2, 0), (A5 - 0x167C, 2, 768), (A5 - 0x167A, 2, 1024), (0xBAA, 2, 20),
            (DIALOG + 0x10, 2, 0x28), (DIALOG + 0x12, 2, 0x10), (DIALOG + 0x14, 2, 0xC8), (DIALOG + 0x16, 2, 0x190),
            (A5 - 0x1006, 4, 0x15300), (A5 - 0xDD2, 4, DATA), (A5 - 0xD12, 2, 0), (A5 - 0x356, 4, 0x15600), (A5 - 0xC36, 4, 0x339A8),
            (A5 - 0x13B6, 4, 0x15700), (A5 - 0x1202, 2, 16), (A5 - 0x1200, 2, 30), (A5 - 0x11FE, 2, 200), (A5 - 0x11FC, 2, 320),
            (A5 - 0x137A, 2, 8)]
    vals += [(A5 - 0xD62 + 4 * i, 4, 0) for i in range(20)]
    vals += [(BLOCK + k, 1, 0xAA) for k in range(0x40)]
    vals += [(DATA + k, 1, b) for k, b in enumerate(b"No memory\x00")]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


case = base_layout.case
L, W = base_layout.L, base_layout.W


def build() -> list[dict]:
    mem_error = [[LOG_OF[("jt", 0x29A)] - 4, 4, 0xFF94]]
    out = [
        case("fatal exit with a frame buffer", "fatal_memory_error_exit", [], []),
        case("fatal exit, no frame buffer, sound off", "fatal_memory_error_exit", [], [], [[A5 - 0x1006, 4, 0], [A5 - 0xC38, 2, 0]]),
        case("new handle", "new_handle_clear_or_die_a5safe", [L(0x400)], [0x400]),
        case("new handle fails", "new_handle_clear_or_die_a5safe", [L(0x400)], [0x400], mem_error),
        case("realloc and clear", "realloc_and_clear_handle_a5safe", [L(NEWH), L(0x30)], [NEWH, 0x30]),
        case("realloc fails", "realloc_and_clear_handle_a5safe", [L(NEWH), L(0x30)], [NEWH, 0x30], mem_error),
        case("load game sounds", "load_game_sounds", [], [], [[A5 - 0xD62 + 4 * 3, 4, 0x15A14]]),
        case("load game sounds, little memory", "load_game_sounds", [], [], [[LOG_OF[("jt", 0x212)] - 4, 4, 0x1000],
                                                                            [LOG_OF[("jt", 0x21A)] - 4, 4, 0x1000]]),
        case("load game sounds, middle memory", "load_game_sounds", [], [], [[LOG_OF[("jt", 0x212)] - 4, 4, 0x20000]]),
    ]
    for depth in (8, 1):
        for a, b in ((40, 120), (150, 60), (-10, -10)):
            args = [a, b, 0x5555, 3, 4, 0x10070, 0xFFFF0090, 5, 6]
            out.append(case(f"horizon bands {a}..{b} depth {depth}", "paint_view_horizon_bands_a5safe", [L(v) for v in args], args,
                            [[A5 - 0x137A, 2, depth]]))
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
        if c["method"] in RESULT:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
