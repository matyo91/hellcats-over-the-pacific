#!/usr/bin/env python3
"""Generate comparison cases for output_face_colour, output_face_bw, add_face_edges_to_rows and
track_ground_plane_horizon by running the ORIGINAL bytes.

Screen polygons (some reaching past every clip bound, some wholly outside) are clipped by the
ported clip_polygon_* passes; colour faces are rasterised into the edge pool and the per-row
buckets (with pre-existing bucket edges to sort against and merge with), 1-bit faces go to the
host polygon routine (+0x7c, a logging stub that also records the first points). The ground face
also tracks the horizon edge and the screen corners. Faces either have no palette slot or still
own theirs; the assign_face_colour path is not exercised here. test_face_output.gd replays the
cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_face_output_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/face_output_cases.json")
ROUTINES = {0xA14E: "output_face_colour", 0xA200: "output_face_bw", 0x9B6C: "add_face_edges_to_rows",
            0xA05E: "track_ground_plane_horizon"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, FACE, GROUND, EDGES, OWNERS, USAGE, OLD_EDGE = 0x27000, 0x27100, 0x27140, 0x28000, 0x27400, 0x27800, 0x27900
HOST_POLY = 0x30000
CALL_LOGS = [[HOST_POLY, 0x38004, 4, 3, 8]]
HALF_W, HALF_ROWS = 100, 60


def setup(points: list[tuple[int, int]], buf: int = 0x24DF2, ground_face: int = GROUND, slot: int = 0xFF,
          owned: bool = True, alt_bottom: int = 40, old_edge: bool = False) -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, 0x27C00, 4)) + list(range(EDGES, EDGES + 0x400, 4))
         + list(range(0x1EAAC, 0x1EAAC + 4 * 2 * HALF_ROWS + 8, 4)) + list(range(0x1DAA4, 0x1DAA4 + 4 * HALF_ROWS + 4, 4))
         + list(range(0x24DF2, 0x24DF2 + 0x100, 4)) + list(range(0x25252, 0x25252 + 0x100, 4)) + list(range(0x38000, 0x38200, 4))]
    vals = [(0x1B5A0, 4, WORLD), (WORLD + 0x7C, 4, HOST_POLY), (0x20AEE, 2, -HALF_W), (0x20AEC, 2, HALF_W - 1),
            (0x20AEA, 2, -HALF_ROWS), (0x1B73E, 2, HALF_ROWS - 1), (0x1B740, 2, alt_bottom), (0x20B2A, 2, HALF_W),
            (0x20B2C, 2, HALF_ROWS), (0x20AF0, 4, ((2 * HALF_W - 1) << 16) | 0x8000), (0x1BDA8, 4, ground_face),
            (0x1B76C, 4, EDGES), (0x20AB0, 4, 2), (0x1DA7C, 4, OWNERS), (0x1D864, 4, USAGE), (0x1BD90, 4, 0),
            (0x1BDA0, 4, 0x11), (0x1BD9C, 4, 0x22), (0x1BD98, 4, 0x33), (0x1BD94, 4, 0x44),
            (FACE + 0xF, 1, slot), (FACE + 4, 4, 0xC0FFEE), (FACE + 2, 2, 9), (GROUND + 0xF, 1, 0xFF), (GROUND + 4, 4, 0x77)]
    if slot != 0xFF and owned:
        vals.append((OWNERS + 4 * slot, 4, FACE))
    vals.append((0x25B1A, 2, len(points)))
    for k, (x, y) in enumerate(points):
        vals += [(buf + 8 * k, 4, x), (buf + 8 * k + 4, 4, y)]
    if old_edge:
        row = HALF_ROWS - 20
        vals += [(0x1EAAC + 4 * row, 4, OLD_EDGE), (OLD_EDGE + 0xC, 4, ((HALF_W - 30) << 16) | 0x8000), (OLD_EDGE + 0x10, 4, 0x8000),
                 (OLD_EDGE + 0x16, 2, HALF_ROWS + 10), (OLD_EDGE + 0x18, 4, OLD_EDGE + 0x20), (OLD_EDGE + 0x2C, 4, ((HALF_W + 50) << 16) | 0x8000),
                 (OLD_EDGE + 0x30, 4, -0x4000), (OLD_EDGE + 0x36, 2, HALF_ROWS + 30)]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return w


TRI = [(-30, -20), (40, 10), (-10, 30)]
BIG = [(-150, -90), (160, -70), (130, 100), (-140, 80)]
OUT = [(200, 0), (300, 10), (250, 50)]
QUAD = [(-30, -20), (20, -20), (20, 10), (-30, 10)]


def build() -> list[dict]:
    c = lambda name, routine, args, w: {"name": name, "routine": BY_NAME[routine], "args": args, "writes": w}
    return [
        c("colour: triangle", "output_face_colour", [FACE], setup(TRI)),
        c("colour: polygon past every bound", "output_face_colour", [FACE], setup(BIG)),
        c("colour: wholly outside", "output_face_colour", [FACE], setup(OUT)),
        c("colour: owned palette slot marked", "output_face_colour", [FACE], setup(TRI, slot=5)),
        c("colour: sorted against and merged with old edges", "output_face_colour", [FACE],
          setup([(-30, -20), (-10, 0), (50, 30)], old_edge=True)),
        c("colour: ground face tracks the horizon", "output_face_colour", [GROUND], setup(BIG)),
        c("colour: ground face cut off by the alternate bottom", "output_face_colour", [GROUND], setup([(-20, 45), (20, 50), (0, 58)])),
        c("bw: triangle to the host", "output_face_bw", [FACE], setup(TRI)),
        c("bw: ground face", "output_face_bw", [GROUND], setup(BIG)),
        c("bw: wholly outside", "output_face_bw", [FACE], setup(OUT)),
        c("edges: quad with horizontal edges", "add_face_edges_to_rows", [FACE], setup(QUAD)),
        c("edges: centre column vertical edge dropped", "add_face_edges_to_rows", [FACE], setup([(99, -10), (99, 20), (50, 5)])),
        c("horizon: full-screen ground polygon", "track_ground_plane_horizon", [4],
          setup([(-HALF_W, -HALF_ROWS), (HALF_W - 1, -HALF_ROWS), (HALF_W - 1, 50), (-HALF_W, 50)], buf=0x25252)),
        c("horizon: sloped edge across the view", "track_ground_plane_horizon", [4],
          setup([(-HALF_W, -10), (HALF_W - 1, 20), (HALF_W - 1, 59), (-HALF_W, 59)], buf=0x25252)),
        c("horizon: clipped away", "track_ground_plane_horizon", [3], setup([(-10, 50), (10, 55), (0, 58)], buf=0x25252)),
    ]


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs, di, dn in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs, i=di, k=dn: log_call(e, b, n, i, k)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        entry = {"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if ROUTINES[c["routine"]] != "add_face_edges_to_rows":
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
