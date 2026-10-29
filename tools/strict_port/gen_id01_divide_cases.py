#!/usr/bin/env python3
"""Generate comparison cases for the ID01 32-bit divide runtime by running the ORIGINAL bytes.

ID01.bin is loaded at address = file offset. The stack entries (rt_udiv32 0x110, rt_umod32 0x130,
rt_sdiv32 0x152, rt_smod32 0x172) are called with the dividend and divisor pushed and a sentinel
in D1, which they must preserve; the register cores (rt_sdivmod32_core 0x194, rt_udivmod32_core
0x1c2) get D0 = dividend, D1 = divisor and return D0 / D1. Operands cover every path of the
unsigned core (divisor above the dividend, word dividend, word divisor, the shifted estimate and
its corrections), every sign combination, 0x80000000 and pseudo-random values; zero divisors are
excluded (the original takes the zero-divide exception). test_id01_divide.gd checks the port.

Usage: python3 tools/strict_port/gen_id01_divide_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id01_divide_cases.json")
BINARY = "sources/resedit-1-0-3/CODE/ID01.bin"
STACK_TOP = 0x8000
D1_SENTINEL = 0x5A5AA5A5
STACK_ENTRIES = {0x110: "rt_udiv32", 0x130: "rt_umod32", 0x152: "rt_sdiv32", 0x172: "rt_smod32"}
CORES = {0x194: "rt_sdivmod32_core", 0x1C2: "rt_udivmod32_core"}

EDGES = [0, 1, 2, 3, 7, 10, 0xFF, 0xFFFF, 0x10000, 0x10001, 0x12345, 0x7FFF, 0x8000, 0xFFFE0001, 0x7FFFFFFF, 0x80000000,
         0x80000001, 0xFFFFFFFF, 0xFFFFFFFE, 0x00010000 * 0xFFFF, 0xDEADBEEF, 1000000000, 0x00FFFFFF, 0x01000000]


def operands() -> list[tuple[int, int]]:
    rng = random.Random(0x1D01)
    pairs = [(a, b) for a in EDGES for b in EDGES if b != 0]
    for _ in range(400):
        bits_a, bits_b = rng.randint(1, 32), rng.randint(1, 32)
        a, b = rng.getrandbits(bits_a), rng.getrandbits(bits_b)
        if b:
            pairs.append((a, b))
    return pairs


def main() -> None:
    emu = Emulator(0x10000, BINARY, file_delta=0)
    cases = []
    for a, b in operands():
        for addr, name in STACK_ENTRIES.items():
            emu.d[1] = D1_SENTINEL
            d0 = emu.call(addr, [a, b], STACK_TOP)
            assert emu.d[1] == D1_SENTINEL, f"{name} lost D1"
            cases.append([name, a, b, d0 & 0xFFFFFFFF])
        for addr, name in CORES.items():
            emu.d[0], emu.d[1] = a, b
            d0 = emu.call(addr, [], STACK_TOP)
            cases.append([name, a, b, d0 & 0xFFFFFFFF, emu.d[1] & 0xFFFFFFFF])
    FIXTURE.write_text(json.dumps({"binary": BINARY, "cases": cases}, separators=(",", ":")) + "\n")
    print(f"{len(cases)} calls")


if __name__ == "__main__":
    main()
