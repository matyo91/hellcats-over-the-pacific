#!/usr/bin/env python3
"""Generate comparison cases for the ID06 software rasteriser set-up and edge routines (all but
render_scanline_spans and rasterize_and_present) by running the ORIGINAL bytes.

ID06.bin is loaded at 0x30000 with A5 = CurrentA5 = 0x20000 and a seeded grey-pattern table at
A5 - 0x1ed6. The Memory Manager slots (FreeMem, MaxMem, NewPtr, DisposPtr) are logging stand-ins
on both sides (segment_stubs.py); NewPtr hands out scripted blocks (0x6000 apart from 0x40000)
and 0 from its eleventh call, so a case presets the call count to make an allocation fail. Most
cases start from a scene the ORIGINAL built: init_raster_target (512 x 96 at depth 1) run in the
interpreter, optionally followed by polygons, captured as writes. test_id06_raster.gd replays the
cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id06_raster_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id06_raster_cases.json")
BINARY = "sources/resedit-1-0-3/CODE/ID06.bin"
MEMORY_SIZE, CODE, A5 = 0x80000, 0x30000, 0x20000
STACK_TOP = 0x2F000
STACK_GUARD = (0x2E000, 0x2F040)
DATA, OUT, LOGS = 0x10000, 0x11000, 0x12000
BLOCKS = [0x40000 + 0x6000 * i for i in range(10)]
NEWPTR_LOG = LOGS + 0x2000 + 4
CALL_LOGS = [["jt", 0x212, LOGS + 4, [], True, 4, {}], ["jt", 0x21A, LOGS + 0x1004, [4], True, 4, {"0": 0}],
             ["jt", 0x232, NEWPTR_LOG, [4], True, 4, {}, BLOCKS + [0]], ["jt", 0x23A, LOGS + 0x3004, [4], True, 0, {}]]
ROUTINES = {"init_pattern_tables": 0x4, "alloc_pattern_tables": 0xB0, "get_pattern_table": 0xF4, "rgb_to_bw_pattern": 0x116,
            "lookup_colour_map": 0x17C, "reverse_lookup_colour_map": 0x1A2, "alloc_aligned_clear": 0x1DC, "free_aligned": 0x24C,
            "init_row_table_fields": 0x26C, "free_row_table": 0x512, "alloc_row_table": 0x598, "init_edge_pool": 0x666,
            "init_raster_target": 0x7B0, "set_raster_target_base": 0x87A, "set_active_row_count": 0x8A2,
            "get_raster_target_size": 0x916, "realloc_row_table": 0x942, "reset_edge_table": 0x96E, "add_polygon_edges": 0x9D8,
            "add_rect_polygon": 0xD02, "rebase_edge_rows_for_band": 0xD84, "restore_edge_rows_after_band": 0xDCA}
VOID = {"free_row_table", "set_raster_target_base", "set_active_row_count", "reset_edge_table",
        "add_rect_polygon", "rebase_edge_rows_for_band", "restore_edge_rows_after_band"}
WORD_RESULT = {"lookup_colour_map", "reverse_lookup_colour_map", "add_polygon_edges"}
WIDTH, HEIGHT = 0x200, 0x60
# The scene's allocations come in a fixed order (patterns, colour map, target, row table, rows,
# edge pool), each aligned block 0xc past its NewPtr block.
SCENE_ROWS, SCENE_POOL = BLOCKS[3] + 0xC, BLOCKS[5] + 0xC


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def common() -> list[list[int]]:
    rng = random.Random(0x1D06)
    w = [[a, 4, 0] for start, end in [(DATA, OUT + 0x100), (LOGS, LOGS + 0x4000), (A5 - 0x1F00, A5)] for a in range(start, end, 4)]
    w += [[0x904, 4, A5]] + [[A5 - 0x1ED6 + k, 1, rng.randrange(256)] for k in range(0x200)]
    w += [[LOGS, 4, 0x100000]]                                           # FreeMem: plenty
    return w


def emulator(writes: list[list[int]]) -> Emulator:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in writes:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, CALL_LOGS)
    return emu


def call(emu: Emulator, routine: str, stack: list[tuple[int, int]]) -> int:
    a7 = STACK_TOP
    for size, value in reversed(stack):
        a7 -= size
        emu.write(a7, size, value)
    return emu.call(CODE + ROUTINES[routine], [], a7)


def poly(points: list[tuple[int, int]]) -> list[list[int]]:
    w = []
    for k, (x, y) in enumerate(points):
        w += [[DATA + 8 * k, 4, x & 0xFFFFFFFF], [DATA + 8 * k + 4, 4, y & 0xFFFFFFFF]]
    return w


def scene(base: list[list[int]], steps: list[tuple[str, list, list]] = ()) -> list[list[int]]:
    """The writes that make the ORIGINAL's raster target (and any further steps) from `base`."""
    emu = emulator(base)
    start = bytes(emu.mem)
    call(emu, "init_raster_target", [L(0x60000), W(0x40), W(5), W(WIDTH), W(HEIGHT)])
    for routine, stack, extra in steps:
        for addr, size, value in extra:
            emu.write(addr, size, value)
        call(emu, routine, stack)
    return [[a, 4, int.from_bytes(emu.mem[a:a + 4], "big")] for a in range(0, MEMORY_SIZE, 4)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a:a + 4] != start[a:a + 4]]


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


TRI = [(-50, -20), (60, 10), (-10, 40)]
WIDE = [(-400, -10), (400, -30), (380, 30), (-420, 20)]          # crosses both sides
TALL = [(-30, -80), (30, -60), (10, 90)]                         # crosses the top and bottom
LEFT = [(-600, 0), (-300, 10), (-400, 30)]                       # wholly left
RIGHT = [(300, 0), (600, 10), (400, 30)]                         # wholly right
FLAT = [(-20, 5), (40, 5), (40, 25), (-20, 25)]                  # horizontal edges
SLIVER = [(-256, -48), (255, 47), (-256, 47)]                    # corner to corner


def build() -> list[dict]:
    base = common()
    s = scene(base)
    with_polys = scene(base, [("add_polygon_edges", [L(3), L(7), L(1), L(DATA)], poly(TRI)),
                              ("add_polygon_edges", [L(4), L(9), L(2), L(DATA)], poly(WIDE))])
    out = [
        case("init pattern tables", "init_pattern_tables", [], [], s),
        case("alloc pattern tables from scratch", "alloc_pattern_tables", [], []),
        case("alloc pattern tables already there", "alloc_pattern_tables", [], [], s),
        case("alloc pattern tables, out of memory", "alloc_pattern_tables", [], [], [[NEWPTR_LOG, 4, 10]]),
        case("get pattern table from scratch", "get_pattern_table", [], []),
        case("get pattern table existing", "get_pattern_table", [], [], s),
        case("get pattern table, out of memory", "get_pattern_table", [], [], [[NEWPTR_LOG, 4, 10]]),
        case("alloc aligned, low free memory", "alloc_aligned_clear", [L(0x123)], [0x123], [[LOGS, 4, 0x1000]]),
        case("alloc aligned, plenty", "alloc_aligned_clear", [L(0x10)], [0x10]),
        case("alloc aligned fails", "alloc_aligned_clear", [L(0x10)], [0x10], [[NEWPTR_LOG, 4, 10]]),
        case("free aligned null", "free_aligned", [L(0)], [0]),
        case("free aligned block", "free_aligned", [L(BLOCKS[0] + 0xC)], [BLOCKS[0] + 0xC], s),
        case("init raster target from scratch", "init_raster_target", [L(0x60000), W(0x40), W(5), W(WIDTH), W(HEIGHT)],
             [0x60000, 0x40, 5, WIDTH, HEIGHT]),
        case("init raster target, odd sizes", "init_raster_target", [L(0x61000), W(0x21), W(0x1FF), W(0x101), W(0x31)],
             [0x61000, 0x21, 0x1FF, 0x101, 0x31]),
        case("init raster target again (reuse)", "init_raster_target", [L(0x62000), W(0x40), W(3), W(WIDTH), W(0x20)],
             [0x62000, 0x40, 3, WIDTH, 0x20], s),
        case("init raster target, pattern alloc fails", "init_raster_target", [L(0x60000), W(0x40), W(5), W(WIDTH), W(HEIGHT)],
             [0x60000, 0x40, 5, WIDTH, HEIGHT], [[NEWPTR_LOG, 4, 10]]),
        case("set raster base", "set_raster_target_base", [L(0x70000)], [0x70000], s),
        case("set raster base without a target", "set_raster_target_base", [L(0x70000)], [0x70000]),
        case("raster size", "get_raster_target_size", [L(OUT), L(OUT + 2)], [OUT, OUT + 2], s),
        case("raster size without a target", "get_raster_target_size", [L(OUT), L(OUT + 2)], [OUT, OUT + 2]),
        case("row table fields colour 9, 40 rows", "init_row_table_fields", [W(9), W(40)], [9, 40], s),
        case("free row table", "free_row_table", [], [], s),
        case("alloc row table, more rows (re-made)", "alloc_row_table", [W(2), W(0x80)], [2, 0x80], s),
        case("alloc row table, fewer rows (kept)", "alloc_row_table", [W(2), W(0x10)], [2, 0x10], s),
        case("alloc row table without a target", "alloc_row_table", [W(2), W(0x10)], [2, 0x10]),
        case("init edge pool on the scene", "init_edge_pool", [], [], s),
        case("init edge pool without rows", "init_edge_pool", [], []),
        case("realloc row table", "realloc_row_table", [W(0x30)], [0x30], s),
        case("reset edge table", "reset_edge_table", [], [], with_polys),
        case("reset edge table, flag set", "reset_edge_table", [], [], with_polys + [[SCENE_ROWS + 0x14, 4, 1]]),
        case("rebase rows for a band", "rebase_edge_rows_for_band", [W(0x20)], [0x20], with_polys),
        case("restore rows after a band", "restore_edge_rows_after_band", [W(0x20)], [0x20], with_polys),
        case("rect polygon", "add_rect_polygon", [W(4), W(-30), W(-10), W(50), W(20)], [4, -30, -10, 50, 20], s),
        case("rect polygon off the left", "add_rect_polygon", [W(4), W(-500), W(-10), W(-300), W(20)], [4, -500, -10, -300, 20], s),
    ]
    for value in (0, 7, 0x100, 0x7FFF, -1, 0x1FF):
        out.append(case(f"colour map {value}", "lookup_colour_map", [W(value)], [value], s))
    for value in (0x07E0, 0x0400, 0x1234):
        out.append(case(f"reverse colour {value:#x}", "reverse_lookup_colour_map", [W(value)], [value], s))
    for r, g, b in ((0, 0, 0), (0xFFFF, 0xFFFF, 0xFFFF), (0x8000, 0x4000, 0xC000), (0x1200, 0xFF00, 0x0100)):
        out.append(case(f"grey pattern {r:#x},{g:#x},{b:#x}", "rgb_to_bw_pattern", [W(r), W(g), W(b)], [r, g, b], s))
    for rows in (10, 0, 1000, 1, -5):
        out.append(case(f"active rows {rows}", "set_active_row_count", [L(rows)], [rows], s))
    out.append(case("active rows without a target", "set_active_row_count", [L(10)], [10]))
    for name, pts in (("triangle", TRI), ("wide", WIDE), ("tall", TALL), ("wholly left", LEFT), ("wholly right", RIGHT),
                      ("flat edges", FLAT), ("corner sliver", SLIVER)):
        out.append(case(f"polygon {name}", "add_polygon_edges", [L(len(pts)), L(6), L(3), L(DATA)], [len(pts), 6, 3, DATA],
                        s + poly(pts)))
    out.append(case("polygon with a full pool", "add_polygon_edges", [L(3), L(6), L(3), L(DATA)], [3, 6, 3, DATA],
                    with_polys + poly(TRI) + [[SCENE_POOL + 0x8A4, 4, SCENE_POOL + 0x5B7C]]))
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = emulator(base + c["writes"])
    before = bytes(emu.mem)
    d0 = call(emu, c["method"], c["stack"])
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] in WORD_RESULT:
            entry["d0"], entry["d0_mask"] = d0 & 0xFFFF, 0xFFFF
        elif c["method"] not in VOID:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
