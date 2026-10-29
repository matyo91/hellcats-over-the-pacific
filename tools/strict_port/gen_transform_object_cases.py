#!/usr/bin/env python3
"""Generate comparison cases for transform_and_project_object by running the ORIGINAL bytes.

A prepared object (eight model vertices, five faces with mixed +0x13 marks) is brought into
camera space: without a controller (with and without byte +6 bit 1), with an unlinked controller,
and with a controller whose definition pre-render hook (+0xe, a logging stub; its return value is
set per case: 0, bit 0, bit 1, bit 2) runs. Oriented objects (byte +5 bit 4) build their attitude
from the controller angles, compose it with the camera matrix and turn the eye (and, when lit,
the light vector) into the object. The distance band runs with host word +0xaa; the object's kind
byte is 3, so shade_object_faces returns at once. Both signs of the eye shift are covered.
test_transform_object.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_transform_object_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_pipeline_cases import FACE_VERTS, MODEL  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/transform_object_cases.json")
ROUTINE = 0xA73E                                   # runtime address (file 0xa75e)
WORLD, OBJ, VERTS, VIEW, FACES, IDX, CTL, DEF = 0x26800, 0x27000, 0x27100, 0x27200, 0x27300, 0x27500, 0x27600, 0x27700
HOOK, HOOK_LOG = 0x30000, 0x38004
CALL_LOGS = [[HOOK, HOOK_LOG, 2]]


def setup(ctl: bool = True, linked: bool = True, hook_ret: int | None = 0, oriented: bool = False, lit: int = 0,
          lit_flag: int = 0, haze: int = 0, shift: tuple[int, int] = (1, 3), b6: int = 0) -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x100, 4)) + list(range(OBJ, 0x27800, 4))
         + list(range(0x24D66, 0x24D66 + 0x20, 4)) + list(range(0x256B2, 0x256B2 + 0x80, 4)) + list(range(0x38000, 0x38100, 4))]
    vals = [(0x1B5A0, 4, WORLD), (WORLD + 0xAA, 2, haze), (WORLD + 0xB2, 2, lit), (0x25B24, 4, OBJ),
            (OBJ, 1, 3), (OBJ + 5, 1, 0x10 if oriented else 0), (OBJ + 6, 1, b6 | lit_flag), (OBJ + 8, 4, CTL if ctl else 0),
            (OBJ + 0x10, 4, 0x5000), (OBJ + 0x30, 2, 1), (OBJ + 0x18, 4, 101000), (OBJ + 0x1C, 4, 2500), (OBJ + 0x20, 4, -39000),
            (OBJ + 0x32, 2, shift[0]), (OBJ + 0x34, 2, shift[1]), (OBJ + 0x36, 2, len(MODEL)), (OBJ + 0x38, 2, 2),
            (OBJ + 0x3A, 2, len(FACE_VERTS)), (OBJ + 0x44, 4, VERTS), (OBJ + 0x48, 4, FACES), (OBJ + 0x4C, 4, VIEW),
            (CTL, 4, OBJ if linked else 0), (CTL + 4, 4, DEF), (DEF + 0xE, 4, HOOK if hook_ret is not None else 0),
            (HOOK_LOG - 4, 4, hook_ret or 0), (CTL + 0x20, 2, 0x0400), (CTL + 0x22, 2, -0x0300), (CTL + 0x24, 2, 0x1200),
            (0x1D838, 4, 100000), (0x1D834, 4, 3000), (0x1D830, 4, -40000), (0x20B28, 2, 256), (0x20B26, 2, 200),
            (0x1BD8C, 2, 0x2000), (0x1BD8A, 2, -0x1800), (0x1BD88, 2, 0x0800), (0x20CE4, 4, 0x2408)]
    for k in range(16):
        vals.append((0x1B190 + 4 * k, 4, 0x2000 * k))
    vals.append((0x1B18C, 4, -0x7FFFFFFF))
    for k, v in enumerate([0x1000, 0x80, -0x40, -0x60, 0xFF0, 0x100, 0x30, -0xC0, 0xFE0]):
        vals.append((0x1D744 + 2 * k, 2, v))
    for i, (x, y, z) in enumerate(MODEL):
        vals += [(VERTS + 12 * i, 4, 2 * x + 100000 // 4), (VERTS + 12 * i + 4, 4, 2 * y + 3000 // 4),
                 (VERTS + 12 * i + 8, 4, 2 * z - 40000 // 4)]
    cursor = IDX
    for f, vs in enumerate(FACE_VERTS):
        rec = FACES + 32 * f
        vals += [(rec + 0x14, 2, len(vs)), (rec + 0x18, 4, cursor), (rec + 0x13, 1, [0x20, 0x60, 0x00, 0x20, 0x40][f])]
        for v in vs:
            vals.append((cursor, 2, v))
            cursor += 2
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return w


CASES = [
    ("no controller, haze: band then vertices", setup(ctl=False, haze=1)),
    ("no controller, byte +6 bit 1: no band", setup(ctl=False, haze=1, b6=2)),
    ("unlinked controller: returns 4", setup(linked=False)),
    ("hook returns bit 2: returns 4", setup(hook_ret=4)),
    ("controller without hook, not oriented", setup(hook_ret=None, haze=1)),
    ("oriented, hook 0: attitude from the controller", setup(oriented=True)),
    ("oriented, hook bit 0 | bit 1: attitude kept, hook called again", setup(oriented=True, hook_ret=3)),
    ("oriented, lit: light vector turned and restored", setup(oriented=True, lit=1, lit_flag=1, haze=1)),
    ("oriented, negative eye shift", setup(oriented=True, shift=(4, 1))),
    ("not oriented, negative eye shift", setup(shift=(3, 0))),
]


def run_case(w: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in w:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    d0 = emu.call(ROUTINE, [], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for name, w in CASES:
        changes, d0 = run_case(w)
        zero, writes = compact(w)
        out["cases"].append({"name": name, "routine": ROUTINE, "method": "transform_and_project_object", "args": [],
                             "zero": zero, "writes": writes, "changes": changes, "d0": d0})
        print(f"{name}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
