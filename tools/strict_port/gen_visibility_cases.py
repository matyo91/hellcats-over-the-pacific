#!/usr/bin/env python3
"""Generate comparison cases for collect_far_objects, build_visible_object_list and
transform_int3_vecs_asr_by_1d744 by running the ORIGINAL bytes.

Objects and heaps are built in the interpreter as in gen_object_list_cases.py. The four broad-
phase collision tests collect_far_objects calls (test_object_collision 0x13ee0,
handle_player_contact 0x1429c, test_proximity_collision 0x13e4e,
test_player_vs_type0e_proximity 0x13eae; not ported) log their calls on both sides, so the pairs
tested and their order are compared. test_visibility.gd replays the cases.

Usage: python3 tools/strict_port/gen_visibility_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import COUNT, FRAME, LIST, MEMORY_SIZE, OBJECTS, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP, Setup  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/visibility_cases.json")
COLLECT_FAR, BUILD_VISIBLE, TRANSFORM = 0x553A, 0x58CC, 0x27E2   # runtime addresses (file - 0x20)
METHODS = {COLLECT_FAR: "collect_far_objects", BUILD_VISIBLE: "build_visible_object_list",
           TRANSFORM: "transform_int3_vecs_asr_by_1d744"}
CALL_LOGS = [[0x13EC0, 0x3F500, 2], [0x1427C, 0x3F600, 2], [0x13E2E, 0x3F700, 2], [0x13E8E, 0x3F800, 2]]
VP = 0x1C43C
VL = 0x1C9DC
SRC = 0x26200
DST = 0x26400


def prepared(s: Setup) -> None:
    for log in CALL_LOGS:
        s.w(log[1] - 4, 4, 0)
        s.w(log[1], 4, 0)
    s.w(0x1C1C4, 4, 0)
    for k, v in enumerate([0x1000, 0, 0, 0, 0x0E00, 0x07FF, 0, 0xF801, 0x0E00]):
        s.w(0x1D744 + 2 * k, 2, v & 0xFFFF)


def far_case(name: str, build) -> dict:
    s = Setup()
    prepared(s)
    objs = build(s)
    for k, obj in enumerate(objs):
        s.w(LIST + 4 * k, 4, obj)
    s.w(COUNT, 4, len(objs))
    return {"name": name, "routine": COLLECT_FAR, "args": [LIST, COUNT], "writes": s.writes()}


def far_mix(s: Setup) -> list[int]:
    """Metric-sorted far objects: overlapping spans so the active / passive scans meet."""
    return [
        s.shape(0, 4, 1, range=900000, dist=100000, size=40000, x=101000, y=3500, z=-41000, flags=0x8000),
        s.shape(1, 4, 1, range=900000, dist=110000, size=30000, flags=0x2000),
        s.shape(2, 4, 1, range=900000, dist=120000, size=30000, flags=0x100000),
        s.shape(3, 4, 1, range=900000, dist=125000, size=30000, flags=0x0800 | 0x40),
        s.shape(4, 4, 1, range=900000, dist=130000, size=5000, b7=0x40),
        s.shape(5, 4, 1, range=900000, dist=500000, size=1000, flags=0x2000),
        s.shape(6, 4, 1, range=900000, dist=135000, size=20000, flags=0x2000 | 0x100000),
        s.shape(7, 4, 1, range=100000, dist=110000, size=1000),
        s.shape(8, 4, 1, range=10000, dist=10000 + 0x19C80, size=1000, seen=FRAME - 10, b1=1, b2=1),
        s.shape(9, 4, 1, range=10000, dist=10000 + 0x19C80, size=1000, seen=0, b1=1, b2=1),
    ]


def visible_case(name: str, first_pass: int, objs: list[tuple[dict, tuple[int, int, int]]]) -> dict:
    s = Setup()
    prepared(s)
    for k, (fields, point) in enumerate(objs):
        obj = OBJECTS + 0x80 * k
        for field, value in fields.items():
            off, size = {"dist": (0x10, 4), "size": (0x14, 4), "detail": (0x32, 2), "b7": (7, 1), "flags": (4, 4)}[field]
            s.w(obj + off, size, value)
        s.w(VL + 4 * k, 4, obj)
        for j in range(3):
            s.w(VP + 12 * k + 4 * j, 4, point[j])
    s.w(0x1C1D4, 4, len(objs))
    s.w(0x1C1D0, 4, len(objs))
    s.w(0x1C1C0, 2, first_pass)
    return {"name": name, "routine": BUILD_VISIBLE, "args": [], "writes": s.writes()}


VISIBLE = [
    ({"dist": 1000, "size": 2000}, (100, 50, -300)),
    ({"dist": 50000, "size": 1000, "detail": 2}, (40, 30, 2000)),
    ({"dist": 50000, "size": 1000, "detail": 2}, (40, 30, -2000)),
    ({"dist": 50000, "size": 100, "detail": 0}, (5000, 30, 1000)),
    ({"dist": 50000, "size": 100, "detail": 0, "b7": 4}, (0, 0, 0)),
    ({"dist": 50000, "size": 800, "detail": 1}, (300, 1200, 900)),
]


def transform_case(name: str, count: int, shift: int) -> dict:
    s = Setup()
    prepared(s)
    for k in range(8 * 3):
        s.w(SRC + 4 * k, 4, (k * 12345 - 70000) & 0xFFFFFFFF)
    return {"name": name, "routine": TRANSFORM, "args": [count, SRC, DST, shift], "writes": s.writes()}


CASES = [
    far_case("far: overlap list, active / passive scans, kept and dropped", far_mix),
    far_case("far: empty list", lambda s: []),
    visible_case("visible: inside, in front, behind, off to the side, no point, tall", 3, VISIBLE),
    visible_case("visible: all in the far pass", 0, VISIBLE),
    transform_case("transform 8 vectors, shift 2", 8, 2),
    transform_case("transform none", 0, 0),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
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
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]],
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
