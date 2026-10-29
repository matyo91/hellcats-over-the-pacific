#!/usr/bin/env python3
"""Generate comparison cases for copy_object_vertex_buffer, deactivate_object and
collect_near_objects by running the ORIGINAL bytes.

deactivate_object frees heap blocks, so each case first builds a real heap in the interpreter:
a free large block, then the object's buffers allocated by the original heap_alloc (file
0x1a68). The memory that setup leaves (relative to the image after overlay_rng_init(1)) becomes
the case's writes, so the port starts from the identical heap. test_object_list.gd replays the
cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_object_list_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/object_list_cases.json")
COPY_VERTS, DEACTIVATE, COLLECT_NEAR = 0x1BE4, 0x52BC, 0x53D8   # runtime addresses (file - 0x20)
METHODS = {COPY_VERTS: "copy_object_vertex_buffer", DEACTIVATE: "deactivate_object", COLLECT_NEAR: "collect_near_objects"}
HEAP_ALLOC = 0x1A48
HEAP_SENTINEL, HEAP_ROVER, HEAP_BLOCK = 0x20C58, 0x20C60, 0x2C000
OBJECTS = 0x24000                # objects of 0x80 bytes
CTLS = 0x25000                   # their controllers (first long = object link)
LIST = 0x26000                   # the near list for collect_near_objects
COUNT = 0x26100
FRAME = 1000


class Setup:
    """Build a case's memory in the interpreter; `writes` returns the bytes it changed."""

    def __init__(self) -> None:
        self.emu = Emulator(MEMORY_SIZE)
        self.emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
        self.start = bytes(self.emu.mem)
        for addr in range(HEAP_BLOCK, HEAP_BLOCK + 0x2000, 4):
            self.w(addr, 4, 0)
        for start, end in [(OBJECTS, OBJECTS + 0x800), (CTLS, CTLS + 0x400), (LIST, LIST + 0x120)]:
            for addr in range(start, end, 4):
                self.w(addr, 4, 0)
        for addr, size, value in [(HEAP_SENTINEL, 4, 0), (HEAP_SENTINEL + 4, 4, HEAP_BLOCK), (HEAP_ROVER, 4, HEAP_SENTINEL),
                                  (HEAP_BLOCK, 4, 0x400), (HEAP_BLOCK + 4, 4, HEAP_SENTINEL),
                                  (0x1B838, 4, FRAME), (0x1C1D0, 4, 0), (0x1C1D4, 4, 0), (0x1C1DC, 4, 0),
                                  (0x1D838, 4, 100000), (0x1D834, 4, 3000), (0x1D830, 4, (-40000) & 0xFFFFFFFF),
                                  (0x1D6FC, 4, 0x7FFF0000), (0x1B88E, 2, 0), (0x1B88C, 2, 0)]:
            self.w(addr, size, value)

    def w(self, addr: int, size: int, value: int) -> None:
        self.emu.write(addr, size, value & ((1 << (8 * size)) - 1))

    def alloc(self, size: int) -> int:
        """At least 32 bytes, so the large-block free list serves it (the small size classes would
        need the host's sbrk)."""
        return self.emu.call(HEAP_ALLOC, [max(size, 32)], STACK_TOP) & 0xFFFFFFFF

    def shape(self, i: int, verts: int, faces: int, **fields: int) -> int:
        obj, ctl = OBJECTS + 0x80 * i, CTLS + 0x40 * i
        self.w(obj, 1, 2)
        self.w(obj + 8, 4, ctl)
        self.w(ctl, 4, obj)
        self.w(obj + 0x3A, 2, faces)
        self.w(obj + 0x36, 2, verts - faces)
        buf_a, buf_b = self.alloc(12 * verts), self.alloc(12 * verts)
        for k in range(3 * verts):
            self.w(buf_a + 4 * k, 4, 0x1000 * i + 17 * k)
        self.w(obj + 0x44, 4, buf_a)
        self.w(obj + 0x4C, 4, buf_b)
        table = self.alloc(0x20 * faces)
        self.w(obj + 0x48, 4, table)
        for f in range(faces):
            self.w(table + 0x20 * f + 0x18, 4, self.alloc(8))
        for name, value in fields.items():
            off, size = FIELD[name]
            self.w(obj + off, size, value)
        return obj

    def group(self, i: int, children: list[int]) -> int:
        obj, ctl = OBJECTS + 0x80 * i, CTLS + 0x40 * i
        self.w(obj, 1, 3)
        self.w(obj + 8, 4, ctl)
        self.w(ctl, 4, obj)
        table = self.alloc(0x18 * len(children))
        for k, child in enumerate(children):
            self.w(table + 0x18 * k + 0x14, 4, child)
        self.w(obj + 0x2E, 2, len(children))
        self.w(obj + 0x30, 4, table)
        return obj

    def writes(self) -> list[list[int]]:
        """Every aligned long that setup changed (outside the stack guard), as a long write."""
        out = []
        for a in range(0, MEMORY_SIZE, 4):
            if STACK_GUARD[0] <= a < STACK_GUARD[1] or self.emu.mem[a:a + 4] == self.start[a:a + 4]:
                continue
            out.append([a, 4, int.from_bytes(self.emu.mem[a:a + 4], "big")])
        return out


FIELD = {"range": (0xC, 4), "dist": (0x10, 4), "size": (0x14, 4), "x": (0x18, 4), "y": (0x1C, 4), "z": (0x20, 4),
         "flags": (4, 4), "b1": (1, 1), "b2": (2, 1), "b7": (7, 1), "shift": (0x34, 2), "seen": (0x3C, 4), "refs": (3, 1)}


def copy_case(name: str, verts: int, faces: int) -> dict:
    s = Setup()
    obj = s.shape(0, max(verts, 1), max(faces, 1))
    s.w(obj + 0x3A, 2, faces)
    s.w(obj + 0x36, 2, verts - faces)
    return {"name": name, "routine": COPY_VERTS, "args": [obj], "writes": s.writes()}


def deactivate_case(name: str, build) -> dict:
    s = Setup()
    obj = build(s)
    return {"name": name, "routine": DEACTIVATE, "args": [obj], "writes": s.writes()}


def collect_case(name: str, build) -> dict:
    s = Setup()
    objs = build(s)
    for k, obj in enumerate(objs):
        s.w(LIST + 4 * k, 4, obj)
    s.w(COUNT, 4, len(objs))
    return {"name": name, "routine": COLLECT_NEAR, "args": [LIST, COUNT], "writes": s.writes()}


def near_mix(s: Setup) -> list[int]:
    return [
        s.shape(0, 4, 2, range=50000, dist=20000, size=3000, x=101000, y=3500, z=-41000),
        s.shape(1, 4, 2, range=50000, dist=30000, size=200000, x=90000, y=0, z=-30000, shift=1),
        s.shape(2, 4, 2, range=50000, dist=20000, flags=0x40),
        s.shape(3, 4, 2, range=50000, dist=20000, flags=4, size=100),
        s.shape(4, 4, 2, range=10000, dist=60000),
        s.shape(5, 4, 2, range=10000, dist=10000 + 0x19C80, seen=FRAME - 0x4B, b1=1, b2=1),
        s.shape(6, 4, 2, range=10000, dist=10000 + 0x19C80, seen=0, b1=1, b2=1),
        s.shape(7, 4, 2, range=50000, dist=20000, b7=2, seen=FRAME - 200, b1=1, b2=1),
    ]


CASES = [
    copy_case("copy vertices: 5 + 3", 8, 3),
    copy_case("copy vertices: one", 1, 1),
    copy_case("copy vertices: none (0)", 0, 0),
    deactivate_case("deactivate shape: buffers and faces freed, controller unlinked",
                    lambda s: s.shape(0, 6, 3, b1=4, b2=4)),
    deactivate_case("deactivate shape with bytes +1 != +2 (cleanup)",
                    lambda s: s.shape(0, 4, 2, b1=4, b2=5, flags=0x80000)),
    deactivate_case("deactivate shape without a controller",
                    lambda s: (s.w(OBJECTS + 8, 4, 0), s.shape(0, 4, 1))[1]),
    deactivate_case("deactivate group: children marked and unlinked",
                    lambda s: s.group(3, [s.shape(0, 4, 1, refs=3), s.shape(1, 4, 1, refs=1), s.shape(2, 4, 1)])),
    deactivate_case("deactivate a kind 4 object: nothing", lambda s: (s.w(OBJECTS, 1, 4), OBJECTS)[1]),
    collect_case("collect near: visible, detail, far, recent, retired and hidden", near_mix),
    collect_case("collect near: empty list", lambda s: []),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]],
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
