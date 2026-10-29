#!/usr/bin/env python3
"""Generate comparison cases for project_prepared_object, transform_face_vertices,
clip_face_near_plane and submit_object_faces by running the ORIGINAL bytes.

A small object (eight model vertices, five faces) is set up with an object-to-camera matrix and
an eye so some vertices land behind the near plane. submit_object_faces runs over a queue of
faces (transformed or not, force_near_clip off / on) in near modes 0, 1 and 2 with kept back
faces; the face output pointer (depth_routine_ab4) is a logging stub returning 1, and the face
polygons stay off the view axis, so point_in_polygon_xy runs (as ported) without a hit and
dispatch_collision is not reached. test_object_pipeline.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_object_pipeline_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/object_pipeline_cases.json")
ROUTINES = {0xA656: "project_prepared_object", 0xA4F2: "transform_face_vertices", 0xB008: "clip_face_near_plane",
            0xA2D2: "submit_object_faces"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
OBJ, VERTS, VIEW, FACES, IDX, MATRIX, PLAYER = 0x27000, 0x27100, 0x27200, 0x27300, 0x27500, 0x27600, 0x27700
OUTPUT = 0x30000
CALL_LOGS = [[OUTPUT, 0x38004, 1]]
MODEL = [(300, 200, 900), (900, 250, 950), (850, 700, 400), (250, 650, 300), (-400, 300, -200),
         (-900, 350, 100), (500, -600, 20), (700, -700, -300)]
FACE_VERTS = [[0, 1, 2], [0, 2, 3], [4, 5, 0], [6, 7, 1], [1, 2, 6, 7]]


def setup(near: int = 0, force: int = 0, queue: list[int] = (0, 1, 2, 3, 4), back: list[int] = (),
          transformed: bool = False, flags: list[int] = (0, 0x10, 8, 0x18, 0)) -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(OBJ, 0x27800, 4)) + list(range(0x24D66, 0x24D66 + 0x20, 4))
         + list(range(0x256B2, 0x256B2 + 0x80, 4)) + list(range(0x24DF2, 0x24DF2 + 0x100, 4))
         + list(range(0x25D30, 0x25D30 + 0x40, 4)) + list(range(0x25B2C, 0x25B2C + 0x40, 4)) + list(range(0x38000, 0x38100, 4))]
    vals = [(0x25B24, 4, OBJ), (OBJ + 0x44, 4, VERTS), (OBJ + 0x48, 4, FACES), (OBJ + 0x4C, 4, VIEW), (OBJ + 0x32, 2, 1),
            (OBJ + 0x36, 2, len(MODEL)), (OBJ + 0x38, 2, 2), (OBJ + 0x3A, 2, len(FACE_VERTS)), (OBJ + 4, 4, 0x0C),
            (0x25B20, 4, VIEW), (0x25F30, 4, FACES), (0x24D5A, 2, 1), (0x24D62, 4, MATRIX), (0x24D60, 2, 50),
            (0x24D5E, 2, 120), (0x24D5C, 2, 60), (0x20B28, 2, 256), (0x20B26, 2, 200), (0x25B16, 2, near),
            (0x25B14, 2, force), (0x25B12, 2, 0), (0x20AB4, 4, OUTPUT), (0x38000, 4, 1), (0x1B738, 4, PLAYER),
            (PLAYER, 4, PLAYER + 0x40)]
    for k, v in enumerate([0x1000, 0x80, -0x40, -0x60, 0xFF0, 0x100, 0x30, -0xC0, 0xFE0]):
        vals.append((MATRIX + 2 * k, 2, v))
    for i, (x, y, z) in enumerate(MODEL):
        vals += [(VERTS + 12 * i, 4, 2 * x), (VERTS + 12 * i + 4, 4, 2 * y), (VERTS + 12 * i + 8, 4, 2 * z)]
        if transformed:
            vals += [(VIEW + 12 * i + 2, 2, x - 50), (VIEW + 12 * i + 6, 2, y - 120), (VIEW + 12 * i + 10, 2, z - 60)]
    cursor = IDX
    for f, vs in enumerate(FACE_VERTS):
        rec = FACES + 32 * f
        vals += [(rec + 0x14, 2, len(vs)), (rec + 0x18, 4, cursor), (rec + 0x13, 1, flags[f] | (0x60 if transformed else 0))]
        for v in vs:
            vals.append((cursor, 2, v))
            cursor += 2
    for k, f in enumerate(queue):
        vals.append((0x25D30 + 4 * k, 4, FACES + 32 * f))
    vals.append((0x25D2C, 4, 0x25D30 + 4 * len(queue)))
    for k, f in enumerate(back):
        vals.append((0x25B2C + 4 * k, 4, FACES + 32 * f))
    vals.append((0x25B28, 4, 0x25B2C + 4 * len(back)))
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return w


def build() -> list[dict]:
    c = lambda name, routine, args, w: {"name": name, "routine": BY_NAME[routine], "args": args, "writes": w}
    out = [
        c("project prepared object (pre-transformed vertices)", "project_prepared_object", [], setup(transformed=True)),
        c("transform face 0", "transform_face_vertices", [FACES], setup()),
        c("transform face 4 (some vertices behind)", "transform_face_vertices", [FACES + 32 * 4], setup()),
        c("transform face 2 with vertex 0 already done", "transform_face_vertices", [FACES + 64], setup() + [[0x24D66, 1, 1]]),
    ]
    for f in range(len(FACE_VERTS)):
        w = setup(transformed=True)
        w.append([0x25B1A, 2, len(FACE_VERTS[f])])
        out.append(c(f"near-plane clip of face {f}", "clip_face_near_plane",
                     [0x25B1A, VIEW, IDX + 2 * sum(len(v) for v in FACE_VERTS[:f]), 0x256B2, 0x24DF2], w))
    for near in (0, 1, 2):
        for force in (0, 1):
            out.append(c(f"submit: near {near}, force clip {force}", "submit_object_faces", [],
                         setup(near=near, force=force, back=[1, 2] if near else [])))
    out.append(c("submit: pre-transformed faces, near 1", "submit_object_faces", [], setup(near=1, transformed=True, back=[3])))
    out.append(c("submit: empty queue, near 1 with back faces", "submit_object_faces", [], setup(near=1, queue=[], back=[0, 4])))
    return out


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
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
        if ROUTINES[c["routine"]] == "clip_face_near_plane":
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
