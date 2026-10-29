#!/usr/bin/env python3
"""Generate comparison cases for update_altitude_detail_bands by running the ORIGINAL bytes.

Each case builds its memory in the interpreter (gen_object_list_cases.Setup): the altitude band
and its two tables, the horizon objects whose vertices follow the band value, the near / far
detail references, land objects to rebuild (a minimal template chain with no faces, so the
outline only re-anchors them) and the far / very far lists. Hidden unreferenced objects and
their controllers are real heap blocks, freed by the original heap_free; the definition destroy
hook is a logged code pointer. The land outline's frame lies 0x1c00 below the entry, so the stack
guard is widened. A negative tolerance must leave the outline's range sum positive: otherwise the
original's +0x32 shift count never ends (as the port documents), so table entries stay small.
test_altitude_bands.gd replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_altitude_band_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import HEAP_BLOCK, OBJECTS, Setup  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/altitude_band_cases.json")
BANDS = 0x59F4                                   # runtime address (file 0x5a14)
STACK_GUARD = (STACK_TOP - 0x2400, STACK_TOP + 0x40)
HOOK, HOOK_LOG = 0x30000, 0x3F404                # destroy hook (logged), its log
CALL_LOGS = [[HOOK, HOOK_LOG, 1]]
WORLD, DESCS, TEMPLATE, TABLE, SLOTS = 0x27000, 0x27400, 0x27600, 0x27700, 0x27800
HORIZON2, HORIZON1, VERTS2, VERTS1 = 0x27900, 0x27980, 0x27A00, 0x27B00
DEF_HOOK, DEF_NONE = 0x27C00, 0x27C40
CAM = (100000, 3000, -40000)
BAND, LOG, REF_NEAR, REF_FAR = 0x1D70C, 0x1D704, 0x1D71C, 0x1D710
ARRAY1, COUNT1, ARRAY3, COUNT3, ARRAY4, COUNT4, CTLS, COUNT_CTL = (
    0x1D4A4, 0x1C1E0, 0x1D0E4, 0x1C1DC, 0x1CBE4, 0x1C1D8, 0x1C25C, 0x1C1CC)
VALUES = [(1000 + 37 * k) * (1 if k % 3 else -1) for k in range(16)]
TOLERANCES = [0x123456, 0x8000, 0x7FFF, -0x100, 0x4E20, 0x1FFFF, 0x7FFFFFF, -5] + [0xB4E1 + 0x100 * k for k in range(8)]


class Case:
    def __init__(self, name: str, cam_y: int = CAM[1], band: int = 2048, log: int = 11,
                 near: tuple[int, int, int] = CAM, far: tuple[int, int, int] = CAM) -> None:
        self.name = name
        self.s = Setup()
        s = self.s
        s.w(HEAP_BLOCK, 4, 0x1C00)
        for start, end in [(WORLD, 0x27D00), (HOOK_LOG - 4, HOOK_LOG + 0x40)]:
            for addr in range(start, end, 4):
                s.w(addr, 4, 0)
        s.w(0x1D838, 4, CAM[0])
        s.w(0x1D834, 4, cam_y)
        s.w(0x1D830, 4, CAM[2])
        s.w(BAND, 4, band)
        s.w(LOG, 2, log)
        for k in range(16):
            s.w(0x1B214 + 4 * k, 4, VALUES[k])
            s.w(0x1B264 + 4 * k, 4, TOLERANCES[k])
        for k, v in enumerate(reversed(near)):
            s.w(REF_NEAR + 4 * k, 4, v)
        for k, v in enumerate(reversed(far)):
            s.w(REF_FAR + 4 * k, 4, v)
        s.w(0x1BDAC, 4, HORIZON2)
        s.w(0x1BDB0, 4, HORIZON1)
        s.w(HORIZON2 + 0x44, 4, VERTS2)
        s.w(HORIZON1 + 0x44, 4, VERTS1)
        for addr, n in [(COUNT1, 0), (COUNT3, 0), (COUNT4, 0), (COUNT_CTL, 0)]:
            s.w(addr, 4, n)
        # A one-slot template chain (slot 0 rotates and translates) and one descriptor.
        s.w(0x1B5A0, 4, WORLD)
        s.w(WORLD + 0x8C, 4, DESCS - 0x100)
        s.w(WORLD + 0xA8, 2, 5)
        s.w(TEMPLATE + 0x28, 4, TABLE)
        s.w(TABLE + 0x2E, 4, 0x100)
        s.w(TEMPLATE + 0x30, 4, SLOTS)
        for off, size, v in [(4, 2, 0x200), (8, 4, 700), (0xC, 4, -30), (0x10, 4, 1200)]:
            s.w(SLOTS + off, size, v)
        for off, size, v in [(2, 4, 101000), (6, 4, 2500), (0xA, 4, -39000), (0x12, 4, 4000), (0x1A, 2, 2), (0x1E, 2, 0)]:
            s.w(DESCS + off, size, v)
        for k in range(6):
            s.w(DESCS + 0x22 + 4 * k, 4, 50 * k - 120)
        s.w(DEF_HOOK + 0xA, 4, HOOK)
        s.w(DEF_NONE + 0xA, 4, 0)
        self.next_fixed = 0

    def fixed(self, dx: int = 0, kind: int = 4, b7: int = 0, refs: int = 0, rng: int = 0) -> int:
        """An object at a fixed address (never freed), dx from the camera."""
        obj = OBJECTS + 0x80 * self.next_fixed
        self.next_fixed += 1
        s = self.s
        s.w(obj, 1, kind)
        s.w(obj + 3, 1, refs)
        s.w(obj + 7, 1, b7)
        s.w(obj + 0xC, 4, rng)
        s.w(obj + 0x18, 4, CAM[0] + dx)
        s.w(obj + 0x1C, 4, CAM[1])
        s.w(obj + 0x20, 4, CAM[2])
        return obj

    def land(self, hidden: bool = False) -> int:
        obj = self.fixed(kind=2, b7=2 if hidden else 0)
        s = self.s
        s.w(obj + 6, 1, 0x10)
        s.w(obj + 0x24, 4, TEMPLATE)
        s.w(obj + 0x3A, 2, 0)
        s.w(obj + 0x36, 2, 3)
        s.w(obj + 0x10, 4, 1234)
        return obj

    def doomed(self, ctl_def: int | None) -> int:
        """A hidden unreferenced heap object, with a heap controller on the given definition."""
        s = self.s
        obj = s.alloc(0x80)
        for off in range(0, 0x80, 4):
            s.w(obj + off, 4, 0)
        s.w(obj, 1, 2)
        s.w(obj + 7, 1, 2)
        if ctl_def is not None:
            ctl = s.alloc(0x40)
            for off in range(0, 0x40, 4):
                s.w(ctl + off, 4, 0)
            s.w(ctl, 4, obj)
            s.w(ctl + 4, 4, ctl_def)
            s.w(obj + 8, 4, ctl)
            self.add_ctl(ctl)
        return obj

    def add_ctl(self, ctl: int) -> None:
        n = self.s.emu.read(COUNT_CTL, 4)
        self.s.w(CTLS + 4 * n, 4, ctl)
        self.s.w(COUNT_CTL, 4, n + 1)

    def live_ctl(self, i: int) -> None:
        ctl = 0x27C80 + 0x10 * i
        self.s.w(ctl, 4, OBJECTS)
        self.add_ctl(ctl)

    def array(self, base: int, count: int, objs: list[int]) -> None:
        for k, obj in enumerate(objs):
            self.s.w(base + 4 * k, 4, obj)
        self.s.w(count, 4, len(objs))

    def done(self) -> dict:
        return {"name": self.name, "routine": BANDS, "args": [], "writes": self.s.writes()}


def build() -> list[dict]:
    out = []
    out.append(Case("band kept, references at the camera: only the horizon vertices").done())
    c = Case("band climbs from 128 to 2048: land outlines rebuilt", band=128, log=7)
    c.array(ARRAY1, COUNT1, [c.fixed(5000), c.land(), c.fixed(9000), c.land(hidden=True)])
    out.append(c.done())
    c = Case("camera at y 0: band 0, rebuild from 2048", cam_y=0)
    c.array(ARRAY1, COUNT1, [c.land()])
    out.append(c.done())
    out.append(Case("band 64 -> 128, both under 0x100: no rebuild", cam_y=200, band=64, log=6).done())
    out.append(Case("band 512 -> 256 (camera fell): rebuild with no land", cam_y=300, band=512, log=9).done())
    for log, y in [(3, 9), (6, 100), (15, 40000), (14, 20000)]:
        c = Case(f"tolerance of band log {log} (from band 0x10000)", cam_y=y, band=0x10000, log=0)
        c.array(ARRAY1, COUNT1, [c.land()])
        out.append(c.done())
    c = Case("near reference moved: the far list re-sorted", near=(CAM[0] + 60000, CAM[1], CAM[2]))
    keep_ref = c.fixed(b7=2, refs=1)
    c.live_ctl(0)
    far_list = [c.doomed(DEF_HOOK), c.fixed(0x90000), keep_ref, c.fixed(0x20000), c.doomed(None),
                c.fixed(0x1000), c.fixed(0x80E7F + 0x10, rng=0x10), c.fixed(0xCE40), c.fixed(0xCE3F), c.doomed(DEF_NONE)]
    c.live_ctl(1)
    c.array(ARRAY3, COUNT3, far_list)
    c.array(ARRAY4, COUNT4, [c.fixed(0x100000), c.fixed(0x95000)])
    c.array(ARRAY1, COUNT1, [c.land()])
    out.append(c.done())
    c = Case("near reference just inside: nothing moves", near=(CAM[0] + 0xB7F0, CAM[1], CAM[2]))
    c.array(ARRAY3, COUNT3, [c.fixed(0x1000)])
    out.append(c.done())
    c = Case("far reference moved: very far list re-sorted first", far=(CAM[0] - 600000, CAM[1], CAM[2] + 1000))
    c.live_ctl(0)
    c.array(ARRAY4, COUNT4, [c.fixed(0x100000), c.doomed(DEF_HOOK), c.fixed(0x30000), c.fixed(0x500), c.fixed(b7=2, refs=2),
                             c.doomed(None), c.fixed(0x80E80), c.fixed(0x80E7F)])
    c.array(ARRAY3, COUNT3, [c.fixed(0x40000), c.doomed(DEF_HOOK), c.fixed(0x90000)])
    out.append(c.done())
    c = Case("far reference moved, nothing hidden: controller list untouched", far=(CAM[0], CAM[1] + 0x90000, CAM[2]))
    c.live_ctl(0)
    c.live_ctl(1)
    c.array(ARRAY4, COUNT4, [c.fixed(0x20000)])
    c.array(ARRAY3, COUNT3, [c.fixed(0x100000), c.fixed(0x100)])
    out.append(c.done())
    return out


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "update_altitude_detail_bands",
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
