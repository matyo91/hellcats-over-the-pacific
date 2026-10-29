#!/usr/bin/env python3
"""Generate comparison cases for the ID02 routines that call the Toolbox (handle and port wrappers,
the fill pattern and draw colour, the offscreen colour port) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py (ID02 at 0x30000, A5 = CurrentA5 = 0x20000). Every call
leaving the segment is a logging stand-in on both sides (segment_stubs.py): the ID09 glue slots
are Pascal (callee pops; NewPtr returns a prepared port record through its result slot), the
RGB-to-pattern slot $1ca is a C routine (D0), and the Toolbox traps (ClosePort, SetPort,
OpenCPort, RectRgn with its rectangle logged by value, PenPat) pop their arguments.
test_id02_glue.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_glue_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_glue_cases.json")
BINARY, MEMORY_SIZE, CODE, A5 = base_layout.BINARY, base_layout.MEMORY_SIZE, base_layout.CODE, base_layout.A5
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
PORTREC, HANDLE, PIXMAP, RGN, CUR_PORT = 0x15000, 0x15100, 0x15200, 0x15300, base_layout.PORT
LOGS = 0x14000
STUBS = [["jt", 0x23A, [4], True, 0], ["jt", 0x232, [4], True, 4], ["jt", 0x25A, [4], True, 0], ["jt", 0x272, [4], True, 0],
         ["jt", 0x27A, [4], True, 0], ["jt", 0x282, [4], True, 0], ["jt", 0x28A, [4], True, 0], ["jt", 0x2E2, [4], True, 0],
         ["jt", 0x1CA, [2, 2, 2], False, 0], ["trap", 0xA87D, [4], True, 0], ["trap", 0xA873, [4], True, 0],
         ["trap", 0xAA00, [4], True, 0], ["trap", 0xA8DF, [4, 4], True, 0, {0: 2}], ["trap", 0xA89D, [4], True, 0]]
CALL_LOGS = [[kind, key, LOGS + 0x100 * i + 4, sizes, pascal, result, (rest[0] if rest else {})]
             for i, (kind, key, sizes, pascal, result, *rest) in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"close_and_dispose_port": 0xD24, "close_port_a5safe": 0xF52, "swap_port_a5safe": 0xF74,
            "swap_mmu_mode_a5safe": 0x14E6, "dispose_handle_a5safe": 0x1A04, "hlock_a5safe": 0x1A84, "hunlock_a5safe": 0x1AA8,
            "hpurge_a5safe": 0x1ACC, "hnopurge_a5safe": 0x1AF0, "get_blended_fill_pattern": 0x150A,
            "set_draw_color_index": 0x15CC, "new_offscreen_cport": 0xCA6}
VOID = {"close_and_dispose_port", "close_port_a5safe", "swap_mmu_mode_a5safe", "dispose_handle_a5safe", "hlock_a5safe",
        "hunlock_a5safe", "hpurge_a5safe", "hnopurge_a5safe", "set_draw_color_index"}


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x100 * len(STUBS), 4)]
    w += [[LOG_OF[("jt", 0x232)] - 4, 4, PORTREC], [LOG_OF[("jt", 0x1CA)] - 4, 4, 0x5A5A1234], [PORTREC + 2, 4, HANDLE],
          [HANDLE, 4, PIXMAP], [PORTREC + 0x18, 4, RGN], [CUR_PORT, 4, 0x77777777]]
    return w


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return base_layout.case(name, method, stack, port_args, writes)


L, W = base_layout.L, base_layout.W


def build() -> list[dict]:
    out = []
    for name in ("close_and_dispose_port", "close_port_a5safe", "swap_port_a5safe", "dispose_handle_a5safe", "hlock_a5safe",
                 "hunlock_a5safe", "hpurge_a5safe", "hnopurge_a5safe"):
        for arg in (0x16000, 0):
            out.append(case(f"{name} {arg:#x}", name, [L(arg)], [arg]))
    out.append(case("swap mmu mode", "swap_mmu_mode_a5safe", [], []))
    for depth in (1, 8):
        for fore, back in ((2, 5), (9, 3), (10, 11), (0, 8), (-1, 4)):
            out.append(case(f"blended pattern depth {depth} ({fore}, {back})", "get_blended_fill_pattern", [], [],
                            [[A5 - 0x137A, 2, depth], [A5 - 0x13BA, 2, fore], [A5 - 0x13B8, 2, back]]))
        for index in (3, 9, 11, 8, -2):
            out.append(case(f"draw colour {index} depth {depth}", "set_draw_color_index", [W(index)], [index],
                            [[A5 - 0x137A, 2, depth]]))
    for rb, b, tl, br in ((0x8140, 0x40000000, 0x00000000, 0x01E00280), (0x8020, 0x12345678, 0xFFF0FFE0, 0x00100020)):
        out.append(case(f"offscreen port rowbytes {rb:#x}", "new_offscreen_cport", [W(rb), L(b), L(tl), L(br)], [rb, b, tl, br]))
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
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] not in VOID:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
