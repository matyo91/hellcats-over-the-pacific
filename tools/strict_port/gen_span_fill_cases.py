#!/usr/bin/env python3
"""Generate comparison cases for init_code_pointer_tables and fill_span_rows_8bit by running the
ORIGINAL bytes.

The init case checks both 0x800-entry run-writer tables. The filler cases start from the
original init's tables (only the first 300 entries are written: no run is longer) and redraw
seeded random background rows on a patterned screen at even and odd starting addresses. Row
records are a header long (the span count) then (end x << 16 | colour) spans over a 160-pixel
row; equal stretches are skipped and the record pointers stored back. test_span_fill.gd replays
the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_span_fill_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/span_fill_cases.json")
INIT, FILL = 0x3714, 0x3794                         # runtime addresses (file 0x3734 / 0x37b4)
NEW, OLD, PTRS, SCREEN = 0x27000, 0x27800, 0x27F00, 0x28000
WIDTH = 160
COLOURS = [0x1111, 0x2222, 0x3434, 0x5656, 0x7A7A]


def tables() -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    emu.call(INIT, [], STACK_TOP)
    return [[a, 4, emu.read(a, 4)] for t in (0x20CEC, 0x22CEC) for a in range(t, t + 4 * 300, 4)]


def row(rnd: random.Random, base: list[tuple[int, int]] | None = None) -> list[tuple[int, int]]:
    if base is not None and rnd.random() < 0.5:
        out = [(x, c if rnd.random() < 0.6 else rnd.choice(COLOURS)) for x, c in base]
        return out
    cuts = sorted(rnd.sample(range(1, WIDTH), rnd.randint(0, 5)))
    return [(x, rnd.choice(COLOURS)) for x in cuts + [WIDTH]]


def records(addr: int, rows: list[list[tuple[int, int]]]) -> list[list[int]]:
    w = []
    for spans in rows:
        w.append([addr, 4, len(spans)])
        addr += 4
        for x, c in spans:
            w.append([addr, 4, (x << 16) | c])
            addr += 4
    w.append([addr, 4, 0xDEAD0001])
    return w


def fill_case(name: str, seed: int, nrows: int, odd: int, skip: int) -> dict:
    rnd = random.Random(seed)
    old_rows = [row(rnd) for _ in range(nrows)]
    new_rows = [row(rnd, o) for o in old_rows]
    w = [[a, 4, 0] for a in list(range(NEW, PTRS + 0x10, 4))]
    w += [[SCREEN + 4 * k, 4, (0xC0C1C2C3 + 0x04040404 * k) & 0xFFFFFFFF] for k in range(0x200)]
    w += tables() + records(NEW, new_rows) + records(OLD, old_rows) + [[PTRS, 4, NEW], [PTRS + 4, 4, OLD]]
    return {"name": name, "routine": FILL, "method": "fill_span_rows_8bit",
            "args": [PTRS, PTRS + 4, nrows, SCREEN + 0x10 + odd, skip], "writes": w}


def build() -> list[dict]:
    out = [{"name": "init: both run-writer tables", "routine": INIT, "method": "init_code_pointer_tables", "args": [],
            "writes": [[a, 4, 0] for t in (0x20CEC, 0x22CEC) for a in range(t, t + 0x2000, 4)]}]
    for seed in range(8):
        out.append(fill_case(f"fill: seed {seed}, 6 rows, even start", seed, 6, 0, 0x100 - WIDTH))
        out.append(fill_case(f"fill: seed {seed}, 5 rows, odd start", 100 + seed, 5, 1, 0x101 - WIDTH))
    out.append(fill_case("fill: one row, start +2", 999, 1, 2, 0))
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": c["method"], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(FIXTURE.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
