#!/usr/bin/env python3
"""Generate comparison cases for the 4-bit span fillers (fill_span_rows_4bit_a / _b / _c) and
their table inits by running the ORIGINAL bytes.

The init cases check each 9-entry run-writer table (patched into the code segment). The filler
cases start from the original init's tables and redraw seeded random background rows (records:
a header long with the span count, then (end x << 16 | colour) spans over a 160-pixel row) on a
patterned 4-bit screen; variant A takes record handles and alternates the colour byte between
rows, B and C take the records directly and still store the end pointers through their first
two arguments. Colours use different high and low bytes so the alternate rows show.
test_span4.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_span4_cases.py  (writes the fixture JSON)
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
from gen_span_fill_cases import NEW, OLD, PTRS, SCREEN, WIDTH, records  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/span4_cases.json")
VARIANTS = {  # name: (init runtime, filler runtime, table runtime, handles)
    "a": (0x3246, 0x329A, 0x3222, True),
    "b": (0x33F2, 0x3446, 0x33CE, False),
    "c": (0x3594, 0x35E8, 0x3570, False)}
INIT_NAMES = {"a": "init_span_table_32ba", "b": "init_span_table_3466", "c": "init_span_table_3608"}
COLOURS = [0x1122, 0x3344, 0x5A6B, 0x7C8D, 0x9EAF]


def table(v: str) -> list[list[int]]:
    init, _fill, tab, _h = VARIANTS[v]
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    emu.call(init, [], STACK_TOP)
    return [[a, 4, emu.read(a, 4)] for a in range(tab, tab + 36, 4)]


def row(rnd: random.Random, base: list[tuple[int, int]] | None = None) -> list[tuple[int, int]]:
    if base is not None and rnd.random() < 0.5:
        return [(x, c if rnd.random() < 0.6 else rnd.choice(COLOURS)) for x, c in base]
    cuts = sorted(rnd.sample(range(1, WIDTH), rnd.randint(0, 6)))
    return [(x, rnd.choice(COLOURS)) for x in cuts + [WIDTH]]


def fill_case(v: str, seed: int, nrows: int) -> dict:
    _init, fill, _tab, handles = VARIANTS[v]
    rnd = random.Random(seed)
    old_rows = [row(rnd) for _ in range(nrows)]
    new_rows = [row(rnd, o) for o in old_rows]
    w = [[a, 4, 0] for a in range(NEW, PTRS + 0x10, 4)]
    w += [[SCREEN + 4 * k, 4, (0xC0C1C2C3 + 0x04040404 * k) & 0xFFFFFFFF] for k in range(0x180)]
    w += table(v) + records(NEW, new_rows) + records(OLD, old_rows) + [[PTRS, 4, NEW], [PTRS + 4, 4, OLD]]
    args = [PTRS, PTRS + 4] if handles else [NEW, OLD]
    return {"name": f"fill {v}: seed {seed}, {nrows} rows", "routine": fill, "method": f"fill_span_rows_4bit_{v}",
            "args": args + [nrows, SCREEN + 0x10, 0x100 - WIDTH // 2], "writes": w}


def build() -> list[dict]:
    out = []
    for v, (init, _fill, tab, _h) in VARIANTS.items():
        out.append({"name": f"init {v}: run-writer table", "routine": init, "method": INIT_NAMES[v], "args": [],
                    "writes": [[a, 4, 0] for a in range(tab, tab + 36, 4)]})
        for seed in range(5):
            out.append(fill_case(v, 10 * seed + len(out), 5))
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


if __name__ == "__main__":
    main()
