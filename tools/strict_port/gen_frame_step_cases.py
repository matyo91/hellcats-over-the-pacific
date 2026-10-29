#!/usr/bin/env python3
"""Generate comparison cases for overlay_frame_step by running the ORIGINAL bytes.

The scene reuses the readout fixture's host layout (gen_readout_cases.case: gauges, readouts,
panel frame) and adds three small mission children (one vertex, no faces, +7 bit 2 so they keep
their place in the visible list), the slot usage maps, two span buffers, an altitude band that
holds (no land rebuild) and near / far objects kept in range (kind 4, far ones hidden by +4 bit
0x40, so they are sorted but never drawn). Every host routine the frame reaches (+0x78 / +0x80 /
+0x84 / +0x266 / +0x26a / +0x26e, the cursor hook +0x2c2, the span filler, the dot erase / plot
routines, the presenters' +0x80 / +0x296, the depth-1 sky routine +0x27e, the heading tape's port
routines and the Memory Manager hooks) is a logging stub on both sides; everything else runs as
ported. Cases that allocate (present_bw_frame / present_spans_to_window, a re-laid sky) get a real
heap (gen_object_list_cases.Setup, block 0x2c000..0x30000); step 0 in view 1 re-creates the
session buffers over handles into free memory; one case points host +0x26a at clear_flag_00020ae4
so the panels stay pending. Depth-1 panel cases use a sloped horizon over 20 cached rows (a flat
one leaves the host routine's x arguments unset in the original), and the depth-1 layout runs on
an odd frame (see the case). test_frame_step.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_frame_step_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_gauge_cases import WORLD  # noqa: E402
from gen_object_list_cases import HEAP_BLOCK, Setup  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402
import gen_readout_cases as readouts  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/frame_step_cases.json")
ROUTINE = 0x6578                                    # runtime address (file 0x6598)
STACK_GUARD = (STACK_TOP - 0x2000, STACK_TOP + 0x40)
HOOKS = {0x78: 0x30800, 0x80: 0x30900, 0x84: 0x30A00, 0x266: 0x30B00, 0x26A: 0x30C00, 0x26E: 0x30D00}
ERASE, PLOT = 0x30E00, 0x30F00
MM_HOOKS = {0x2C6: 0x31C00, 0x2CE: 0x31C40, 0x2D2: 0x31C80, 0x2D6: 0x31CC0, 0x2DA: 0x31D00, 0x2DE: 0x31D40, 0x2E2: 0x31D80}
MM_ARGS = {0x2C6: 1, 0x2CE: 2, 0x2D2: 1, 0x2D6: 1, 0x2DA: 1, 0x2DE: 1, 0x2E2: 0}
HANDLES, HANDLE_BUFS = 0x31E00, 0x3A400
CLEAR_PANELS = 0x6EAE                                # clear_flag_00020ae4 (file 0x6ece) as host +0x26a
HOST_BW, HOST_COPY, DEPTH1 = 0x30980, 0x31F00, 0x31F80   # +0x80 as present_bw_frame calls it, +0x296, +0x27e
CALL_LOGS = readouts.CALL_LOGS + [[HOOKS[0x78], 0x3A004, 0], [HOOKS[0x80], 0x3A044, 1], [HOOKS[0x84], 0x3A084, 1],
                                  [HOOKS[0x266], 0x3A0C4, 0], [HOOKS[0x26A], 0x3A104, 0], [HOOKS[0x26E], 0x3A144, 0],
                                  [ERASE, 0x3A184, 0], [PLOT, 0x3A1C4, 4],
                                  [HOST_BW, 0x3A204, 3], [HOST_COPY, 0x3A244, 4], [DEPTH1, 0x3A304, 9]]
CALL_LOGS += [[addr, 0x3B404 + 0x80 * k, MM_ARGS[off]] for k, (off, addr) in enumerate(MM_HOOKS.items())]
TAPE_SETUP, TAPE_SWITCH, TAPE_RELEASE, TAPE_COPYBITS = 0x31E80, 0x31EA0, 0x31EC0, 0x31EE0   # +0x282 / +0x286 / +0x28a / +0x29a
CALL_LOGS += [[TAPE_SETUP, 0x3B804, 4, 3, 2], [TAPE_SWITCH, 0x3B884, 1], [TAPE_RELEASE, 0x3B904, 1],
              [TAPE_COPYBITS, 0x3B984, 5, 2, 2, 4, 2]]
CHILD0, CHILD1, CHILD23 = 0x33000, 0x33100, 0x33200
MAP_A, MAP_B, SLOT_MAP, HOST72, PAIRS = 0x34000, 0x34100, 0x34200, 0x34400, 0x34500
SPAN_A, SPAN_B, EDGES = 0x35000, 0x36000, 0x37000
NEAR, FAR = 0x31000, 0x32000                       # 0x80-byte object records
CAM = (100000, 3000, -40000)


def child(addr: int, i: int) -> list[tuple[int, int, int]]:
    verts, view, faces = 0x33400 + 0x100 * i, 0x33800 + 0x100 * i, 0x33C00 + 0x100 * i
    w = [(addr, 1, 3), (addr + 7, 1, 4), (addr + 0x36, 2, 1), (addr + 0x44, 4, verts), (addr + 0x4C, 4, view),
         (addr + 0x48, 4, faces), (addr + 0x32, 2, 1), (addr + 0x10, 4, 0x4000), (addr + 0x18, 4, CAM[0] + 500 * i),
         (addr + 0x1C, 4, CAM[1]), (addr + 0x20, 4, CAM[2] + 3000)]
    for k in range(10):
        w += [(verts + 12 * k, 4, 40 * k - 100), (verts + 12 * k + 4, 4, 7 * k), (verts + 12 * k + 8, 4, 900 + 33 * k)]
    return w


def case(name: str, step: int = 1, new_frame: int = 0, view: int = 0, depth: int = 8, panels: int = 1,
         host76: int = 0, host9e: int = 0, haze: int = 0, retire: int = 0, near: int = 0, far: list[int] = (),
         pairs: list[tuple[int, int, int]] = (), drawn: int = 0, heap: bool = False, session: bool = False, keep_pending: bool = False, extra: list[tuple[int, int, int]] = ()) -> dict:
    c = readouts.case(name, "update_view_readouts_and_overlays", [], panels=panels, drawn=drawn, host_line=host9e)
    w = c["writes"]
    zero = [(a, 4, 0) for start, end in [(0x33000, 0x34600), (SPAN_A, SPAN_B + 0x1000), (NEAR, FAR + 0x800),
                                         (0x3A000, 0x3A400), (0x3B800, 0x3BC00), (0x1BDBC, 0x1BDBC + 0x400), (0x1C9DC, 0x1C9DC + 0x100),
                                         (0x1D4A4, 0x1D4A4 + 0x40), (0x1B5A4, 0x1B5A4 + 0x40), (0x265D0, 0x26650),
                                         (EDGES, EDGES + 0x400), (0x1EAAC, 0x1EAAC + 0x200), (0x1DAA4, 0x1DAA4 + 0x100)]
            for a in range(start, end, 4)]
    vals = [(WORLD + 0x76, 2, host76), (WORLD + 0x9E, 2, host9e), (WORLD + 0xAA, 2, haze), (WORLD + 0xAC, 2, 0),
            (WORLD + 0x72, 4, HOST72), (HOST72 + 6, 2, 1)] + [(WORLD + off, 4, addr) for off, addr in HOOKS.items()]
    vals += [(WORLD + 0x80, 4, HOST_BW if host9e else HOOKS[0x80]), (WORLD + 0x296, 4, HOST_COPY), (WORLD + 0x27E, 4, DEPTH1)]
    vals += [(WORLD + 0x282, 4, TAPE_SETUP), (WORLD + 0x286, 4, TAPE_SWITCH), (WORLD + 0x28A, 4, TAPE_RELEASE),
             (WORLD + 0x29A, 4, TAPE_COPYBITS)]
    vals += [(0x1DA84, 4, ERASE), (0x1DA80, 4, PLOT), (0x1D864, 4, MAP_A), (0x1D860, 4, MAP_B), (0x1DA8A, 2, 5),
             (0x1D85C, 4, SLOT_MAP), (SLOT_MAP + 0x10, 2, 0x44), (SLOT_MAP + 0x1A0, 2, 0x88), (0x24CF0, 4, retire),
             (0x1B826, 2, depth), (0x1D858, 2, view), (0x1B794, 4, SPAN_B), (0x1B798, 4, SPAN_A), (0x20AE6, 2, 6),
             (0x1B82A, 2, 0x40), (0x20AF0, 4, (0x3F << 16) | 0x8000), (0x1B76C, 4, EDGES), (0x20AB0, 4, 0), (0x1B834, 4, 0), (0x20AEA, 2, 2), (0x1B73E, 2, 30), (0x20AE8, 2, 20),
             (0x1BDB4, 4, CHILD0), (0x1BDB0, 4, CHILD1), (0x1BDAC, 4, CHILD23), (0x1BDA4, 4, CHILD0),
             (0x1C1D4, 4, 0), (0x1C1D0, 4, 0), (0x1C1DC, 4, 0), (0x1C1D8, 4, 0), (0x1C1CC, 4, 0), (0x1C1E0, 4, near), (0x1B734, 4, len(far)), (0x1B85C, 2, len(pairs)), (0x1B860, 4, PAIRS),
             (0x1D838, 4, CAM[0]), (0x1D834, 4, CAM[1]), (0x1D830, 4, CAM[2]), (0x1D70C, 4, 2048), (0x1D704, 2, 11),
             (0x1D810, 2, 0x0100), (0x1D80E, 2, -0x0200), (0x1D80C, 2, 0x0300), (0x1D808, 4, 0x2400), (0x1D804, 4, 0x0123),
             (0x1D800, 4, -0x0456), (0x20B26, 2, 200), (0x20B28, 2, 256),
             (0x2666E, 4, 1), (0x2666A, 4, 0x26AC0), (WORLD + 0x1E0, 2, 20), (WORLD + 0x1E4, 2, 100), (WORLD + 0x1DA, 2, 9),
             (WORLD + 0x1DC, 2, 3)]
    for k, v in enumerate(reversed(CAM)):
        vals += [(0x1D71C + 4 * k, 4, v), (0x1D710 + 4 * k, 4, v)]
    for i, addr in enumerate((CHILD0, CHILD1, CHILD23)):
        vals += child(addr, i)
    for i in range(near):
        obj = NEAR + 0x80 * i
        vals += [(0x1D4A4 + 4 * i, 4, obj), (obj, 1, 4), (obj + 0xC, 4, 0x7FFFFFFF), (obj + 0x18, 4, CAM[0] + 100 * i),
                 (obj + 0x1C, 4, CAM[1]), (obj + 0x20, 4, CAM[2] - 50 * i)]
    for i, dx in enumerate(far):
        obj = FAR + 0x80 * i
        vals += [(0x1B5A4 + 4 * i, 4, obj), (obj, 1, 4), (obj + 4, 4, 0x40), (obj + 0xC, 4, 0x7FFFFFFF),
                 (obj + 0x18, 4, CAM[0] + dx), (obj + 0x1C, 4, CAM[1] + 10 * i), (obj + 0x20, 4, CAM[2])]
    for k, (carrier, rider, level) in enumerate(pairs):
        cobj, robj = FAR + 0x80 * carrier, FAR + 0x80 * rider
        cctl = 0x34580 + 0x40 * k
        vals += [(PAIRS + 8 * k, 4, cobj), (PAIRS + 8 * k + 4, 4, robj), (cobj + 8, 4, cctl), (cctl + 0x54, 2, level),
                 (cobj + 0x14, 4, 0x3000 + 0x100 * k)]
    if session:                                   # handles for unlock / allocate / lock session buffers
        zero += [(a, 4, 0) for a in list(range(HANDLES, HANDLES + 0x100, 4)) + list(range(0x3B400, 0x3B800, 4))
                 + list(range(0x1B744, 0x1B7A0, 4))]
        vals += [(WORLD + off, 4, addr) for off, addr in MM_HOOKS.items()]
        vals += [(0x3B404 + 0x80 * 6 - 4, 4, 0x100000), (0x3B404 - 4, 4, HANDLES + 0xF0), (WORLD, 1, 1), (WORLD + 0xE, 2, 8),
                 (WORLD + 0xC, 2, 0x140), (0x20C4C, 4, 0x77), (WORLD + 0xA2, 2, 1), (0x1B794, 4, SPAN_B), (0x1B798, 4, SPAN_A)]
        slots = [0x1B744] + [0x1B74C + 4 * k for k in range(1, 4)] + [0x1B75C + 4 * k for k in range(1, 4)]
        for i, slot in enumerate(slots):
            vals += [(slot, 4, HANDLES + 0x10 * i), (HANDLES + 0x10 * i, 4, HANDLE_BUFS + 0x200 * i)]
    if keep_pending:
        vals.append((WORLD + 0x26A, 4, CLEAR_PANELS))
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in zero + vals + list(extra)]
    if heap:                                      # a real heap for present_bw_frame's buffer
        h = Setup()
        h.w(HEAP_BLOCK, 4, 0x800)                   # 8-byte units: 0x2c000..0x30000, clear of the scene
        w = h.writes() + w + [[0x1B778, 4, 0x2A000], [0x1B77C, 4, 0x2A200], [0x1B780, 4, 0]]
    return {"name": name, "routine": ROUTINE, "args": [step, new_frame], "writes": w}


FAR4 = [3000, -9000, 500, 12000]
# Depth 1 hands the sky / ground host routine the horizon's x at both ends; a flat horizon leaves
# them unset in the original, so the depth-1 panel cases use a sloped one (y1, x1, y0, x0) over
# a cached geometry with rows.
SLOPED = [(0x1BD94, 4, -30), (0x1BD98, 4, -20), (0x1BD9C, 4, 30), (0x1BDA0, 4, 25),
          (WORLD + 0x18C, 2, 20), (0x25F3A, 2, 20)]          # 20 cached rows (host and cache agree)
# Host pointer slots +0x192 / +0x1ac / +0x1b4 / +0xd8 and the screen addresses they point at
# (with high garbage that 24-bit addressing masks off).


def pointers(high: int = 0) -> list[tuple[int, int, int]]:
    return [(WORLD + 0x192, 4, 0x34600), (WORLD + 0x1AC, 4, 0x34604), (WORLD + 0x1B4, 4, 0x34608), (WORLD + 0xD8, 4, 0x3460C),
            (0x34600, 4, high | 0x2A000), (0x34604, 4, high | 0x2A100), (0x34608, 4, high | 0x2A200), (0x3460C, 4, high | 0x50000),
            (0x20AD8, 4, 0), (0x20AD4, 4, 0), (WORLD + 0x18C, 2, 20)]   # the new +0x196 re-lays 20 sky rows, allocated fresh


CASES = [
    case("depth 1, readouts off (step 0)", step=0, depth=1),
    case("depth 1, new frame: maps swapped, tally counted, dots drawn", step=0, depth=1, new_frame=1),
    case("depth 1 with the host line routine: present_bw_frame", step=0, depth=1, host9e=1, new_frame=1, heap=True),
    case("depth 8: scan converted into the span filler", step=0),
    case("depth 4, half rows", step=0, depth=4, extra=[(0x1B834, 4, 1)]),
    case("depth 8 through present_spans_to_window", step=0, host9e=1, heap=True),
    case("cursor hooks (host +0x76)", step=0, host76=1),
    case("view mode 2: six-angle camera", step=0, view=2),
    case("haze: child 1 transformed, banded and shaded", step=0, haze=1),
    case("twenty retirements reset the distance bases", step=0, retire=0x14),
    case("near entities get their camera metric", step=0, near=3),
    case("far objects sorted by fresh metric", step=0, far=FAR4),
    case("far objects sorted with carried pairs", step=0, far=FAR4, pairs=[(0, 1, 2500), (2, 3, 9000), (1, 2, 100)]),
    case("readouts only (panels not drawn)", panels=0),
    case("readouts only with cursor hooks", panels=0, host76=1),
    case("panels drawn: readouts, gauges, radar buttons, bombs", panels=1),
    case("panels drawn with cursor hooks", panels=1, host76=1),
    case("panels drawn at depth 1 (sloped horizon)", panels=1, depth=1, extra=SLOPED),
    case("panels drawn at depth 1 with cursor hooks", panels=1, depth=1, host76=1, extra=SLOPED),
    case("new frame slot 1 with everything", new_frame=1, near=2, far=FAR4[:3], host76=1),
    case("view 1 lays out the panels (geometry cached)", view=1, panels=0),
    case("view 1 layout with cursor hooks", view=1, panels=0, host76=1),
    # The readouts' second sky / ground pass follows the layout's, which cleared the corners, so on
    # an even frame the original would hand the depth-1 host routine an unset colour word: odd frame.
    case("view 1 layout at depth 1 (odd frame)", view=1, panels=0, depth=1, extra=SLOPED + [(0x25F48, 2, 1)]),
    case("view 1 layout, step 0: session buffers re-created", step=0, view=1, panels=0, session=True),
    case("view 1 layout, step 0 with cursor hooks", step=0, view=1, panels=0, session=True, host76=1),
    case("view 1 layout, step 0: host keeps the panels pending", step=0, view=1, panels=0, session=True, keep_pending=True),
    case("view 1 layout, new frame: host pointers reloaded", view=1, panels=0, new_frame=1, heap=True, extra=pointers()),
    case("view 1 layout, new frame, 24-bit pointers", view=1, panels=0, new_frame=1, heap=True, host76=1, extra=pointers(0xAB000000)),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for entry in CALL_LOGS:
        address, log_base, nargs = entry[:3]
        di, dn = (entry[3], entry[4]) if len(entry) > 3 else (-1, 0)
        emu.stubs[address] = lambda e, b=log_base, n=nargs, i=di, k=dn: log_call(e, b, n, i, k)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "overlay_frame_step", "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
