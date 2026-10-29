#!/usr/bin/env python3
"""Generate comparison cases for scan_convert_edge_rows by running the ORIGINAL bytes.

Each scene is built in the interpreter by the original add_face_edges_to_rows: several polygons
(screen points relative to the view centre) of faces with distinct draw orders and colours fill
the edge pool, the per-row buckets and the row flags. The resulting memory becomes the case's
writes, then the scan converter runs and its span rows (from session_cur_a), the edge records,
the touched faces and the cleared buckets are compared. Scenes cover single and overlapping
polygons, crossing edges (insertion sort in both paths), long coherent runs (the column-wise fast
path), short runs and the half-rows mode. test_scan_convert.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_scan_convert_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/scan_convert_cases.json")
SCAN, ADD_EDGES = 0x2DF4, 0x9B6C                    # runtime addresses (file 0x2e14 / 0x9b8c)
EDGES, FACES, SPANS = 0x28000, 0x27000, 0x2A000
HALF_W, HALF_ROWS = 40, 24
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def scene(polys: list[tuple[int, int, list[tuple[int, int]]]], half_mode: int = 0) -> list[list[int]]:
    """polys: (draw order, colour, points). Returns the memory writes after building the edges."""
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    start = bytes(emu.mem)
    for a in list(range(FACES, FACES + 0x400, 4)) + list(range(EDGES, EDGES + 0x1000, 4)) + list(range(SPANS, SPANS + 0x2000, 4)) \
            + list(range(0x1EAAC, 0x1EAAC + 4 * 2 * HALF_ROWS + 16, 4)) + list(range(0x1DAA4, 0x1DAA4 + 4 * HALF_ROWS + 8, 4)):
        emu.write(a, 4, 0)
    for addr, size, v in [(0x20B2A, 2, HALF_W), (0x20B2C, 2, HALF_ROWS), (0x20AF0, 4, ((2 * HALF_W - 1) << 16) | 0x8000),
                          (0x1B76C, 4, EDGES), (0x20AB0, 4, 0), (0x1B82A, 2, 2 * HALF_W), (0x1DAA0, 2, 0x0909),
                          (0x20AE6, 2, 2 * HALF_ROWS), (0x1B834, 4, half_mode), (0x1B794, 4, SPANS), (0x1B798, 4, SPANS + 0x1800)]:
        emu.write(addr, size, v & ((1 << (8 * size)) - 1))
    for k, (order, colour, pts) in enumerate(polys):
        face = FACES + 0x20 * k
        emu.write(face + 2, 2, order)
        emu.write(face + 4, 4, colour)
        emu.write(face + 0xF, 1, 0xFF)
        emu.write(0x25B1A, 2, len(pts))
        for i, (x, y) in enumerate(pts):
            emu.write(0x24DF2 + 8 * i, 4, x & 0xFFFFFFFF)
            emu.write(0x24DF2 + 8 * i + 4, 4, y & 0xFFFFFFFF)
        emu.call(ADD_EDGES, [face], STACK_TOP)
    return [[a, 4, int.from_bytes(emu.mem[a:a + 4], "big")] for a in range(0, MEMORY_SIZE, 4)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a:a + 4] != start[a:a + 4]]


TRI = [(-20, -18), (25, -5), (-5, 20)]
QUAD = [(-30, -10), (10, -20), (30, 15), (-15, 22)]
BIG = [(-38, -22), (37, -22), (37, 21), (-38, 21)]
CROSS_A = [(-35, -20), (-30, -20), (30, 20), (25, 20)]
CROSS_B = [(25, -20), (30, -20), (-30, 20), (-35, 20)]
CASES = [
    ("one triangle", scene([(3, 0x1111, TRI)])),
    ("one quad", scene([(2, 0x2222, QUAD)])),
    ("full-view rectangle: long coherent runs", scene([(5, 0x3333, BIG)])),
    ("overlapping faces, front by draw order", scene([(2, 0x1111, QUAD), (7, 0x4444, TRI)])),
    ("back face over front face", scene([(9, 0x1111, QUAD), (1, 0x4444, TRI)])),
    ("crossing slivers: insertion sort", scene([(3, 0x5555, CROSS_A), (4, 0x6666, CROSS_B)])),
    ("three faces with a background rectangle", scene([(1, 0x7777, BIG), (4, 0x1111, QUAD), (6, 0x2222, TRI)])),
    ("half-rows mode", scene([(2, 0x2222, QUAD), (3, 0x3333, TRI)], half_mode=1)),
    ("empty scene: background only", scene([])),
]


def run_case(w: list[list[int]]) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in w:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(SCAN, [], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {}, "cases": []}
    for name, w in CASES:
        changes = run_case(w)
        zero, writes = compact(w)
        out["cases"].append({"name": name, "routine": SCAN, "method": "scan_convert_edge_rows", "args": [],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{name}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
