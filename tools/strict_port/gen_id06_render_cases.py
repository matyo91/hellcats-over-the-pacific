#!/usr/bin/env python3
"""Generate comparison cases for ID06's render_scanline_spans and rasterize_and_present by running
the ORIGINAL bytes.

The set-up is gen_id06_raster_cases.py's (ID06.bin at 0x30000, A5 = CurrentA5 = 0x20000, scenes the
ORIGINAL built with init_raster_target and add_polygon_edges, captured as writes). The renderer
keeps its data and registers in its own code (0x39e / 0x3ae), so the port is told the load address
("port_vars": code_base) and a continued render starts from a scene captured after the first band.
rasterize_and_present reaches the renderer through the row table's pointer (A5 + 0x192, an "addr"
stand-in here) and JT $322 (a logging stand-in). Each case records the original's entry stack
pointer ("a7"). test_id06_render.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id06_render_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id06_raster_cases as raster  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id06_render_cases.json")
CODE, A5, MEMORY_SIZE = raster.CODE, raster.A5, raster.MEMORY_SIZE
STACK_TOP, STACK_GUARD = raster.STACK_TOP, raster.STACK_GUARD
L, W, DATA = raster.L, raster.W, raster.DATA
RENDERER = A5 + 0x192
PRESENT_LOG = raster.LOGS + 0x3800 + 4
CALL_LOGS = raster.CALL_LOGS + [["jt", 0x322, PRESENT_LOG, [4, 4, 4, 4], False, 0, {}],
                                ["addr", RENDERER, raster.LOGS + 0x3C00 + 4, [2, 2, 4, 4], False, 0, {}]]
ROUTINES = dict(raster.ROUTINES, render_scanline_spans=0x318, rasterize_and_present=0xE10)
SQUARE = [(-60, -30), (40, -30), (40, 20), (-60, 20)]
DIAMOND = [(0, -40), (90, 0), (0, 40), (-90, 0)]
DEST, STRIDE = 0x70000, 0x40


def emulator(writes: list[list[int]], real_renderer: bool = True) -> Emulator:
    emu = Emulator(MEMORY_SIZE, raster.BINARY, file_delta=0x7FFFFFFF)
    code = open(raster.BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in writes:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, CALL_LOGS if not real_renderer else CALL_LOGS[:-1])
    return emu


def scene(base: list[list[int]], steps: list) -> list[list[int]]:
    """The writes that make the ORIGINAL's raster target, its polygons and any further calls."""
    emu = emulator(base)
    start = bytes(emu.mem)
    raster.call(emu, "init_raster_target", [L(0x60000), W(0x40), W(5), W(raster.WIDTH), W(raster.HEIGHT)])
    for routine, stack, extra in steps:
        for addr, size, value in extra:
            emu.write(addr, size, value)
        a7 = STACK_TOP
        for size, value in reversed(stack):
            a7 -= size
            emu.write(a7, size, value)
        emu.call(CODE + ROUTINES[routine], [], a7)
    return [[a, 4, int.from_bytes(emu.mem[a:a + 4], "big")] for a in range(0, MEMORY_SIZE, 4)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a:a + 4] != start[a:a + 4]]


def polys(*shapes: tuple) -> list:
    return [("add_polygon_edges", [L(len(pts)), L(colour), L(depth), L(DATA)], raster.poly(pts)) for pts, colour, depth in shapes]


def render(first: int, count: int) -> tuple:
    return ("render_scanline_spans", [W(first), W(count), L(DEST), L(STRIDE)], [])


def case(name: str, method: str, stack: list, port_args: list[int], writes: list[list[int]]) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args], "writes": writes}


def build(base: list[list[int]]) -> list[dict]:
    two = polys((raster.TRI, 7, 1), (raster.WIDE, 9, 2))
    overlap = polys((SQUARE, 3, 5), (DIAMOND, 12, 2))
    empty = scene(base, [])
    s_two, s_overlap = scene(base, two), scene(base, overlap)
    after_band = scene(base, overlap + [render(0, 0x20)])
    out = [case("render: no polygons", "render_scanline_spans", [W(0), W(raster.HEIGHT), L(DEST), L(STRIDE)], [0, raster.HEIGHT, DEST, STRIDE], empty),
           case("render: two polygons", "render_scanline_spans", [W(0), W(raster.HEIGHT), L(DEST), L(STRIDE)], [0, raster.HEIGHT, DEST, STRIDE], s_two),
           case("render: overlapping, depth ordered", "render_scanline_spans", [W(0), W(raster.HEIGHT), L(DEST), L(STRIDE)],
                [0, raster.HEIGHT, DEST, STRIDE], s_overlap),
           case("render: first band", "render_scanline_spans", [W(0), W(0x20), L(DEST), L(STRIDE)], [0, 0x20, DEST, STRIDE], s_overlap),
           case("render: continued band", "render_scanline_spans", [W(1), W(0x40), L(DEST + 0x800), L(0x30)],
                [1, 0x40, DEST + 0x800, 0x30], after_band)]
    rest = [[A5 - 0x1372, 2, 0x200], [A5 - 0x137A, 2, 1]]
    for name, stack, args, writes in (("whole target", [L(0), L(0), L(0)], [0, 0, 0], s_two),
                                      ("one band", [L(DEST), L(0x100), L(5)], [DEST, 0x100, 5], s_two + rest),
                                      ("bands of 0x20", [L(DEST), L(0x20), L(5)], [DEST, 0x20, 5], s_two + rest),
                                      ("bands of 0x25, depth 8", [L(DEST), L(0x25), L(6)], [DEST, 0x25, 6],
                                       s_overlap + [[A5 - 0x1372, 2, 0x1FF], [A5 - 0x137A, 2, 8]]),
                                      ("no row table", [L(DEST), L(0x20), L(5)], [DEST, 0x20, 5], [])):
        out.append(case(f"rasterize: {name}", "rasterize_and_present", stack, args, writes))
    return out


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = emulator(base + c["writes"], real_renderer=c["method"] != "rasterize_and_present")
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE) if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    base = raster.common() + [[a, 4, 0] for a in range(raster.LOGS + 0x3800, raster.LOGS + 0x4000, 4)]
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": CALL_LOGS, "port_vars": {"code_base": CODE}, "cases": []}
    for c in build(base):
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": run(c, base),
                             "a7": STACK_TOP - sum(size for size, _ in c["stack"]) - 4})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
