#!/usr/bin/env python3
"""Generate comparison cases for a batch of small routines by running the ORIGINAL bytes:
copy_block_return_dst, any_mission_kills_recorded, build_attitude_matrix_from_dir_roll, the two
tagged attitude invokers, rotate_int3_vecs_by_3ang, recolour_kind2_object, clear_flag_00020ae4,
face_is_back_facing, reset_background_rows, reset_overlay_display_state and acos_scaled_dot3.
Arguments are signed in the fixture (masked to longs for the interpreter); routines that return
a value also compare D0 (the void ones and the tagged invokers, whose D0 is the composer's
leftover, do not). Direction vectors keep x * x + z * z within a long: beyond it the original's
isqrt gets a negative value and divides by zero. test_small_math.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_small_math_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/small_math_cases.json")
ROUTINES = {                                      # runtime addresses (file - 0x20)
    0x12: "copy_block_return_dst", 0x314: "any_mission_kills_recorded", 0x227E: "build_attitude_matrix_from_dir_roll",
    0x2782: "invoke_tagged_attitude_compose_neg_sins4", 0x27AC: "invoke_tagged_attitude_compose_neg_sins6",
    0x2886: "rotate_int3_vecs_by_3ang", 0x41CC: "recolour_kind2_object", 0x6EAE: "clear_flag_00020ae4",
    0x9AC0: "face_is_back_facing", 0xB440: "reset_background_rows", 0xB47E: "reset_overlay_display_state",
    0xE392: "acos_scaled_dot3"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
NO_D0 = {"recolour_kind2_object", "clear_flag_00020ae4", "reset_background_rows", "reset_overlay_display_state",
         "invoke_tagged_attitude_compose_neg_sins4", "invoke_tagged_attitude_compose_neg_sins6"}
WORLD, BUF, OUT, OBJ, TEMPLATE, TABLE, DESCS = 0x27000, 0x27400, 0x27600, 0x27700, 0x27800, 0x27900, 0x27A00
ROWS, MODEL, NORMALS, FACE = 0x28000, 0x28400, 0x28500, 0x28600


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in range(WORLD, 0x27C00, 4)]
    w += [[a, 4, 0] for a in range(ROWS, ROWS + 0x700, 4)]
    w += [[0x1B5A0, 4, WORLD]]
    return w


def case(name: str, routine: str, args: list[int], extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": BY_NAME[routine], "args": args,
            "writes": base() + [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in extra]}


def angles(seed: int) -> list[tuple[int, int, int]]:
    """Values for the twelve angle cos / sin words (0x1d7e6 .. 0x1d7fc)."""
    return [(0x1D7E6 + 2 * k, 2, ((seed * 0x2F1 + k * 0x9B5) % 0x2000) - 0x1000) for k in range(12)]


def build() -> list[dict]:
    out = [
        case("copy block: 0x30 bytes forward", "copy_block_return_dst", [BUF + 0x100, BUF, 0x30],
             [(BUF + 4 * k, 4, 0x01020304 * (k + 1)) for k in range(16)]),
        case("copy block: overlapping, backwards", "copy_block_return_dst", [BUF + 6, BUF, 0x1A],
             [(BUF + 4 * k, 4, 0xA0B0C0D0 + k) for k in range(16)]),
        case("copy block: nothing", "copy_block_return_dst", [BUF, BUF + 0x40, 0]),
        case("kills: none", "any_mission_kills_recorded", []),
        case("kills: the last word", "any_mission_kills_recorded", [], [(WORLD + 0xD0, 2, 3)]),
        case("kills: the first word", "any_mission_kills_recorded", [], [(WORLD + 0xBA, 2, 1)]),
        case("kills: past the twelve words", "any_mission_kills_recorded", [], [(WORLD + 0xD2, 2, 1)]),
        case("clear panels_drawn", "clear_flag_00020ae4", [], [(0x20AE4, 2, 0x1234)]),
    ]
    for x, y, z, roll, flag in [(1000, 200, 3000, 0x400, 0), (-5000, -800, 1200, 0x3F00, 0), (20000, 15000, -25000, 0x1234, 0),
                                (0, 500, 0, 0x800, 1), (7, -3, -9, 0, 0), (2000, 0, 0, 0x2000, 1)]:
        out.append(case(f"attitude from direction ({x}, {y}, {z}) roll {roll:#x} flag {flag}",
                        "build_attitude_matrix_from_dir_roll", [x, y, z, roll, OUT, flag], angles(1)))
    for tag, name in [(0x2408, "3ang"), (0x2468, "x"), (0x26E0, "6ang")]:
        for routine in ("invoke_tagged_attitude_compose_neg_sins4", "invoke_tagged_attitude_compose_neg_sins6"):
            out.append(case(f"{routine[-5:]} through the {name} composer", routine, [OUT],
                            angles(tag) + [(0x20CE4, 4, tag)]))
    verts = [(1000, -200, 3000), (-4000, 500, 70), (12345, -6789, -2222)]
    vec_writes = [(BUF + 12 * i + 4 * k, 4, v) for i, vec in enumerate(verts) for k, v in enumerate(vec)]
    for a in [(0x400, 0x100, 0x3000), (0, 0, 0), (0x2000, 0x1FFF, 0x800)]:
        out.append(case(f"rotate 3 vectors by {a}", "rotate_int3_vecs_by_3ang", [*a, 3, BUF, OUT], vec_writes))
    out.append(case("rotate in place", "rotate_int3_vecs_by_3ang", [0x123, 0x456, 0x789, 3, BUF, BUF], vec_writes))
    shape = [(OBJ, 1, 2), (OBJ + 0x10, 4, 0x5000), (OBJ + 0x30, 2, 1), (OBJ + 0x24, 4, TEMPLATE), (OBJ + 0x3A, 2, 0),
             (OBJ + 0x44, 4, BUF), (TEMPLATE + 0x28, 4, TABLE), (TABLE + 0x2E, 4, 0x100), (WORLD + 0x8C, 4, DESCS - 0x100),
             (0x1B18C, 4, -0x7FFFFFFF)] + [(0x1B190 + 4 * k, 4, 0x2000 * k) for k in range(16)]
    out.append(case("recolour a shape: band moves", "recolour_kind2_object", [OBJ], shape))
    out.append(case("recolour a non-shape: nothing", "recolour_kind2_object", [OBJ], shape + [(OBJ, 1, 3)]))
    for vi, eye, shift in [(0, (100, 50, -300), 0), (2, (-2000, 40, 900), 2), (1, (5, 5, 5), 1), (3, (0, 0, 0), 0)]:
        extra = [(0x24D4A, 4, NORMALS), (0x24D4E, 4, 10), (0x24D52, 4, -20), (0x24D56, 4, 30), (0x24D5A, 2, shift),
                 (0x24D60, 2, eye[0]), (0x24D5E, 2, eye[1]), (0x24D5C, 2, eye[2]), (0x25B24, 4, OBJ), (OBJ + 0x44, 4, MODEL),
                 (FACE + 0x18, 4, FACE + 0x40), (FACE + 0x40, 2, 2)]
        extra += [(NORMALS + 4 * k, 4, (k * 0x3B1) % 0x700 - 0x380) for k in range(12)]
        extra += [(MODEL + 4 * k, 4, (k * 0x1F37) % 0x4000 - 0x2000) for k in range(9)]
        out.append(case(f"back-facing: normal {vi}, eye {eye}, shift {shift}", "face_is_back_facing", [vi, FACE], extra))
    rows = [(0x20AD4, 4, ROWS), (WORLD + 0x18C, 2, 200), (0x1B82A, 2, 0x1C0), (0x1DAA0, 2, 0x55)]
    out.append(case("background rows: 200", "reset_background_rows", [], rows))
    out.append(case("background rows: no buffer", "reset_background_rows", [], rows[1:] + [(0x20AD4, 4, 0)]))
    out.append(case("background rows: negative count", "reset_background_rows", [], rows + [(WORLD + 0x18C, 2, -3)]))
    out.append(case("overlay display state reset", "reset_overlay_display_state", [],
                    rows + [(0x25FFE, 2, 0x99), (0x25FFC, 2, 1)]))
    for a, b in [((1000, 0, 0, 1000), (0, 1000, 0, 1000)), ((3000, 4000, 0, 5000), (3000, 4000, 0, 5000)),
                 ((-700, 300, 200, 800), (650, -100, -300, 730)), ((10, 10, 10, 17), (10, 10, 10, 17)),
                 ((200000, -100000, 50000, 230000), (-150000, 90000, 20000, 176000))]:
        out.append(case(f"acos of {a} . {b}", "acos_scaled_dot3", [*a, *b]))
    return out


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], [a & 0xFFFFFFFF for a in c["args"]], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in build():
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": ROUTINES[c["routine"]], "args": c["args"],
                             "zero": zero, "writes": writes, "changes": changes})
        if ROUTINES[c["routine"]] not in NO_D0:
            out["cases"][-1]["d0"] = d0
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
