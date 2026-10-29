#!/usr/bin/env python3
"""Generate comparison cases for update_ground_scatter_objects by running the ORIGINAL bytes.

The 64 scatter points sit on a grid around the camera (identity camera matrix, so view z is the
world z offset); some lie beyond 0x4d58 and are re-placed by the overlay RNG (on the player
heading circle or in the square). The scatter objects are children of the scene root, so a
reused object's scene record is also its template-chain slot. The land list is empty, so
surface_type_at_point returns the default surface byte; other surfaces come from cached bytes.
The pool spawn is stubbed on both sides and logs every call. test_ground_scatter.gd replays the
cases (helpers/original_cases.gd); the stack guard is widened to 0x1000 for the callees' frames.

Usage: python3 tools/strict_port/gen_ground_scatter_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import (  # noqa: E402
    ARGS_POOL, MEMORY_SIZE, OVERLAY_RNG_INIT, SPAWN_MISSION_POOL_OBJECT, STACK_TOP, record_args)

FIXTURE = Path("godot/tests/strict_port/fixtures/ground_scatter_cases.json")
SCATTER = 0x5E08                                  # runtime address (file 0x5e28)
STACK_GUARD = (STACK_TOP - 0x1000, STACK_TOP + 0x40)   # surface_type_at_point's frame lies 0xa60 below
WORLD, SCENE, TABLE, RECS, DESCS = 0x27000, 0x27400, 0x27600, 0x27700, 0x27900
TEMPLATES, OCEAN, PLAYER, OBJS = 0x27B00, 0x27C00, 0x27C80, 0x24000
POINTS, STATE, SLOT_POINT, SURFACE, TEMPLATE_BY_SURFACE, SLOTS = 0x1B924, 0x1B8E4, 0x1B894, 0x1B8A4, 0x1BC24, 0x1BC64
CAM = (100000, 3000, -40000)


def grid(i: int) -> tuple[int, int]:
    """Point i's (dx, dz) from the camera: 8 x 8, rows from behind the camera to 10800 ahead."""
    return (i % 8 - 4) * 2400 + 300, (i // 8) * 2400 - 6000


class Case:
    def __init__(self, name: str, mode: int = 0, reset: int = 0, started: int = 1, active: int = 1,
                 player_y: int = 0, far: tuple[int, ...] = ()) -> None:
        self.name = name
        self.writes: list[list[int]] = []
        for start, end in [(WORLD, 0x27D00), (OBJS, OBJS + 0x400), (ARGS_POOL, ARGS_POOL + 0x200),
                           (POINTS, POINTS + 0x300), (STATE, STATE + 0x40), (SLOT_POINT, SLOT_POINT + 0x10),
                           (SURFACE, SURFACE + 0x40), (TEMPLATE_BY_SURFACE, SLOTS + 0x1C), (0x1D744, 0x1D758),
                           (0x1B18C, 0x1B1D0)]:
            self.w_range(start, end)
        for addr, size, value in [
                (0x1B5A0, 4, WORLD), (WORLD + 0xAC, 2, active), (WORLD + 0x8C, 4, DESCS - 0x100), (WORLD + 0xAA, 2, 0),
                (0x1D6FC, 4, SCENE), (SCENE + 0x28, 4, TABLE), (SCENE + 0x30, 4, RECS), (SCENE + 0x24, 4, 0),
                (0x1D838, 4, CAM[0]), (0x1D834, 4, CAM[1]), (0x1D830, 4, CAM[2]), (0x1D858, 2, mode),
                (0x1B738, 4, PLAYER), (PLAYER + 0x2E, 4, player_y), (PLAYER + 0x22, 2, 0x1234),
                (0x1D856, 2, reset), (0x24CEC, 4, started),
                (0x1D744, 2, 0x1000), (0x1D744 + 8, 2, 0x1000), (0x1D744 + 16, 2, 0x1000),
                (0x20B28, 2, 256), (0x20B26, 2, 200), (0x20AEE, 2, 0xFF00), (0x20AEC, 2, 0xFF),
                (0x20AEA, 2, 0xFF60), (0x1B73E, 2, 0xA0),
                (0x1C1E0, 4, 0), (0x1BDA8, 4, OCEAN), (OCEAN + 0x16, 1, 0x10),
                (0x1B838, 4, 777), (0x1B88E, 2, 100), (0x1B88C, 2, 0),
                (TEMPLATE_BY_SURFACE + 4, 4, TEMPLATES), (TEMPLATE_BY_SURFACE + 8, 4, TEMPLATES + 0x40),
                (TEMPLATES + 1, 1, 1), (TEMPLATES + 0x41, 1, 2),
                (TABLE + 0x2E + 0x18, 4, 0x100), (TABLE + 0x2E + 0x30, 4, 0x180)]:
            self.w(addr, size, value)
        self.w(0x1B18C, 4, -0x7FFFFFFF)
        for k in range(16):
            self.w(0x1B190 + 4 * k, 4, 0x2000 * k)
        for d, (ox, oy, oz) in [(DESCS, (40, 15, -60)), (DESCS + 0x80, (-25, 30, 10))]:
            for off, size, v in [(2, 4, ox), (6, 4, oy), (0xA, 4, oz), (0x1A, 2, 2), (0x1E, 2, 0)]:
                self.w(d + off, size, v)
            for k in range(6):
                self.w(d + 0x22 + 4 * k, 4, 30 * k - 70)
        for i in range(64):
            dx, dz = grid(i)
            if i in far:
                dx += 0x6000 if i % 2 else 0
                dz += 0 if i % 2 else -0x6000
            self.w(POINTS + 12 * i, 4, CAM[0] + dx)
            self.w(POINTS + 12 * i + 8, 4, CAM[2] + dz)
            self.w(STATE + i, 1, 0x3F)

    def w(self, addr: int, size: int, value: int) -> None:
        self.writes.append([addr, size, value & ((1 << (8 * size)) - 1)])

    def w_range(self, start: int, end: int) -> None:
        for addr in range(start, end, 4):
            self.w(addr, 4, 0)

    def state(self, i: int, value: int, surface: int | None = None) -> None:
        self.w(STATE + i, 1, value | (0x40 if surface is not None else 0))
        if surface is not None:
            self.w(SURFACE + i, 1, surface)

    def obj(self, k: int, point: int, cls: int = 1, flags: int = 0, b5: int = 0, verts: bool = True, b7: int = 0) -> int:
        """A scatter object in slot k, a scene child on record k, sitting on the given point."""
        obj = OBJS + 0x80 * k
        self.w(SLOTS + 4 * k, 4, obj)
        self.w(SLOT_POINT + 2 * k, 2, point)
        for off, size, v in [(0, 1, 2), (1, 1, cls), (2, 1, k), (4, 4, flags), (5, 1, b5), (7, 1, b7), (0x24, 4, SCENE),
                             (0x30, 2, 2), (0x36, 2, 2), (0x3A, 2, 0), (0x44, 4, (0x27E00 + 0x20 * k) if verts else 0),
                             (0x48, 4, 0x27F00)]:
            self.w(obj + off, size, v)
        return obj

    def done(self) -> dict:
        return {"name": self.name, "routine": SCATTER, "args": [], "writes": self.writes}


def build() -> list[dict]:
    out = [Case("scatter off (host +0xac == 0): started cleared", active=0).done(),
           Case("camera too high, not started: nothing", started=0, player_y=-8000).done()]
    c = Case("camera too high once started: slots cleaned up", player_y=-8000)
    c.obj(0, 20)
    c.obj(3, 21, b7=2)
    out.append(c.done())
    c = Case("first use: points reset and scattered in the square, empty slots spawn", started=0)
    out.append(c.done())
    c = Case("steady, view 2: circle re-placement, kept / stale / skipped / hidden slots",
             mode=2, far=(3, 12, 40, 41))
    c.state(40, 0xC2)                                 # a re-placed point naming slot 2
    c.obj(0, 50)
    c.state(50, 0xC0)                                 # kept: its point still names it
    c.obj(1, 51)
    c.state(51, 0x81, 0x20)                           # stale (bit 6 off): moves to a new point
    c.obj(2, 52, flags=2)                             # skipped: +4 & 6
    c.obj(4, 53, cls=2)
    c.state(53, 0x05)
    for i, surface in [(34, 0x20), (35, 0x30), (36, 0x20)]:
        c.state(i, 0, surface)
    c.state(37, 0x80, 0x20)                           # already on screen: not newly visible
    out.append(c.done())
    c = Case("view 6: height is camera y, square re-placement, reuse in place", mode=6, far=(0, 9, 63))
    c.obj(0, 10, cls=2)
    c.obj(1, 11, cls=1, b5=0x10)
    c.obj(2, 12, cls=2, verts=False)
    c.obj(5, 13, cls=1)
    for i in range(24, 48):
        c.state(i, 0, 0x20 if i % 3 else 0x10)
    out.append(c.done())
    c = Case("nothing newly visible: live slots hidden", mode=1)
    for i in range(64):
        c.state(i, 0x80)
    c.obj(0, 30)
    c.obj(6, 31)
    out.append(c.done())
    c = Case("reset flag in view 3: square re-placement and slot bit 2 cleared", mode=3, reset=1)
    c.obj(0, 2, flags=4)
    c.obj(1, 3, flags=0x44)
    out.append(c.done())
    c = Case("only surfaces without a template: nothing placed", mode=0)
    for i in range(64):
        c.state(i, 0, 0x30)
    c.obj(2, 5)
    out.append(c.done())
    return out


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    emu.stubs[SPAWN_MISSION_POOL_OBJECT] = lambda e: record_args(e, ARGS_POOL, 8)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD),
           "stubs": {"spawn_mission_pool_object": ARGS_POOL}, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "update_ground_scatter_objects",
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
