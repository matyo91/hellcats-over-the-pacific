#!/usr/bin/env python3
"""Generate comparison cases for emit_face_chain, emit_faces_bsp, emit_faces_in_order and
emit_faces_unnumbered by running the ORIGINAL bytes.

Each case builds a prepared object with seeded random faces: BSP children (+0x10 / +0x11, a
tree), +0x12 chains (always to a later face, so they end), +0x13 flags (bit 0 two-sided, bit 1
hidden, bit 4 set at random to see it cleared), +0x1c distances around the object distance, and
normals / vertices so face_is_back_facing (run as ported) gives a mix of answers. Cases run with
near mode off and on. test_face_emit.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_face_emit_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/face_emit_cases.json")
ROUTINES = {0x9D14: "emit_face_chain", 0x9D86: "emit_faces_bsp", 0x9ED8: "emit_faces_in_order", 0x9FA4: "emit_faces_unnumbered"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
OBJ, FACES, NORMALS, MODEL, VLISTS, QUEUE, BACKQ = 0x27000, 0x27100, 0x27400, 0x27500, 0x27600, 0x27800, 0x27A00
N = 14
DIST = 5000


def setup(seed: int, near: int) -> list[list[int]]:
    rnd = random.Random(seed)
    w = [[a, 4, 0] for a in range(OBJ, 0x27C00, 4)]
    vals = [(0x25B24, 4, OBJ), (0x25F30, 4, FACES), (0x24D4A, 4, NORMALS), (OBJ + 0x44, 4, MODEL), (OBJ + 0x10, 4, DIST),
            (0x25D2C, 4, QUEUE), (0x25B28, 4, BACKQ), (0x1C1BE, 2, 7), (0x25B16, 2, near), (0x25B18, 2, 5),
            (0x24D4E, 4, 10), (0x24D52, 4, -20), (0x24D56, 4, 30), (0x24D5A, 2, 1),
            (0x24D60, 2, rnd.randint(-300, 300)), (0x24D5E, 2, rnd.randint(-300, 300)), (0x24D5C, 2, rnd.randint(-300, 300))]
    for k in range(3 * N):
        vals.append((NORMALS + 4 * k, 4, rnd.randint(-0x300, 0x300)))
    for k in range(3 * 8):
        vals.append((MODEL + 4 * k, 4, rnd.randint(-0x800, 0x800)))
    for i in range(N):
        f = FACES + 32 * i
        left, right = 2 * i + 1, 2 * i + 2
        chain = rnd.choice([-1, -1] + list(range(i + 1, N)))
        flags = rnd.choice([0, 0, 1, 1, 2, 0x10, 0x11])
        vals += [(f + 0x10, 1, left if left < N and rnd.random() < 0.85 else -1), (f + 0x11, 1, right if right < N and rnd.random() < 0.85 else -1),
                 (f + 0x12, 1, chain), (f + 0x13, 1, flags), (f + 0x18, 4, VLISTS + 4 * i),
                 (f + 0x1C, 4, DIST + rnd.choice([-100, 0, 300, 2000])), (f + 2, 2, 0xEEEE)]
        vals.append((VLISTS + 4 * i, 2, rnd.randint(0, 7)))
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return w


def build() -> list[dict]:
    out = []
    for seed in range(6):
        for near in (0, 1):
            w = setup(seed, near)
            label = f"seed {seed}, near {near}"
            out.append({"name": f"bsp from 0, {label}", "routine": BY_NAME["emit_faces_bsp"], "args": [0], "writes": w})
            out.append({"name": f"in order, {label}", "routine": BY_NAME["emit_faces_in_order"], "args": [], "writes": w})
            out.append({"name": f"unnumbered, {label}", "routine": BY_NAME["emit_faces_unnumbered"], "args": [], "writes": w})
            out.append({"name": f"chain from 2, {label}", "routine": BY_NAME["emit_face_chain"], "args": [2, DIST], "writes": w})
            out.append({"name": f"chain from 0, far limit, {label}", "routine": BY_NAME["emit_face_chain"], "args": [0, DIST + 400], "writes": w})
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    sizes = [len(c["changes"]) for c in out["cases"]]
    print(len(sizes), "cases; changed bytes min", min(sizes), "max", max(sizes), "; empty", sizes.count(0))


if __name__ == "__main__":
    main()
