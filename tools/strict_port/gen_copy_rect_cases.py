#!/usr/bin/env python3
"""Generate comparison cases for copy_rect_depth8 and copy_rect_depth4 by running the ORIGINAL
bytes. A patterned source area is copied into a patterned destination for every destination
and source alignment (bytes at depth 8, 4-bit pixels at depth 4), with column counts that leave
leading, whole-long / whole-word and trailing parts, a count that ends inside the leading part,
negative row strides and a single row. test_copy_rect.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_copy_rect_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/copy_rect_cases.json")
ROUTINES = {0xBF90: "copy_rect_depth8", 0xBC88: "copy_rect_depth4"}
SRC, DST = 0x28000, 0x2A000


def base() -> list[list[int]]:
    w = [[SRC + 4 * k, 4, (0x01234567 * (k + 3) ^ (k << 20)) & 0xFFFFFFFF] for k in range(0x800)]
    w += [[DST + 4 * k, 4, (0xA5A50000 + k * 0x1111) & 0xFFFFFFFF] for k in range(0x800)]
    return w


def case(routine: int, name: str, dst: int, src: int, count: int, height: int, src_row: int, dst_row: int) -> dict:
    return {"name": name, "routine": routine, "args": [dst, src, count, height, src_row, dst_row], "writes": base()}


def build() -> list[dict]:
    out = []
    for d in range(4):
        for s in range(4):
            out.append(case(0xBF90, f"depth 8: dst +{d}, src +{s}, 23 columns x 5", DST + 0x400 + d, SRC + 0x400 + s, 23, 5, 0x40, 0x60))
    out += [
        case(0xBF90, "depth 8: count ends in the leading columns", DST + 0x401, SRC + 0x400, 2, 4, 0x40, 0x40),
        case(0xBF90, "depth 8: zero count, unaligned", DST + 0x403, SRC, 0, 3, 0x40, 0x40),
        case(0xBF90, "depth 8: three columns aligned (no long)", DST + 0x400, SRC + 2, 3, 3, 0x40, 0x40),
        case(0xBF90, "depth 8: exactly 8 aligned", DST + 0x400, SRC + 0x400, 8, 2, 0x20, 0x20),
        case(0xBF90, "depth 8: negative strides", DST + 0x1800, SRC + 0x1800, 17, 6, -0x50, -0x30),
        case(0xBF90, "depth 8: one row", DST + 0x402, SRC + 0x401, 40, 1, 0x40, 0x40),
    ]
    for d in range(4):
        for s in range(4):
            out.append(case(0xBC88, f"depth 4: dst px +{d}, src px +{s}, 27 pixels x 5", 2 * (DST + 0x400) + d,
                            2 * (SRC + 0x400) + s + 8, 27, 5, 0x80, 0xC0))
    out += [
        case(0xBC88, "depth 4: count ends in the leading pixels", 2 * DST + 0x801, 2 * SRC + 0x800, 2, 4, 0x80, 0x80),
        case(0xBC88, "depth 4: zero count", 2 * DST + 0x803, 2 * SRC, 0, 3, 0x80, 0x80),
        case(0xBC88, "depth 4: three pixels (no word)", 2 * DST + 0x800, 2 * SRC + 0x805, 3, 3, 0x80, 0x80),
        case(0xBC88, "depth 4: negative strides, odd row bytes", 2 * (DST + 0x1800) + 1, 2 * (SRC + 0x1800) + 2, 19, 6, -0xA1, -0x61),
        case(0xBC88, "depth 4: one row, 41 pixels", 2 * DST + 0x802, 2 * SRC + 0x803, 41, 1, 0x80, 0x80),
    ]
    return out


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
