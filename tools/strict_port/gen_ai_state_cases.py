#!/usr/bin/env python3
"""Generate the AI state handler comparison cases by running the ORIGINAL bytes.

Same method as gen_flight_model_cases.py (which supplies the base world / controller writes):
each case seeds the overlay RNG with the original overlay_rng_init(1), applies its writes, runs
one of the handlers ai_attack_or_fly (0x110f4, with ai_pursue_target 0x1820a), ai_fly (0x11182),
ai_fly_bomber (0x111ae), ai_dive_at_target (0x111da) or ai_bombing_run (0x112e0) in the m68k_emu interpreter, and records every byte changed outside the
stack. The aircraft kind (word +0x614) is 0, whose ai_fly_table entry is 0, so the fly step is
update_aircraft_entity; other kinds run the per-kind fly routines of ai_fly_table (patrol routes,
the attack run, the scripted mission with its landing approach); the landing glide (0x1a1a6) is run directly. A frame that drops a bomb or
fires the guns needs a live object pool, so spawn_weapon_entity (file 0x12840) and
spawn_ordnance_oriented (file 0x15d20) are stubbed on both sides: they record their arguments
(longs at ARGS_WEAPON / ARGS_ORDNANCE) and return 0 (no object). test_ai_states.gd replays the cases through the strict port.

Usage: python3 tools/strict_port/gen_ai_state_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_flight_model_cases import (  # noqa: E402
    CTL, MEMORY_SIZE, OBJ, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP, WORLD, base_writes)

FIXTURE = Path("godot/tests/strict_port/fixtures/ai_state_cases.json")
AI_ATTACK_OR_FLY = 0x110D4
LANDING_GLIDE = 0x1A186          # +0x32 handler installed by try_begin_landing_approach
AI_FLY = 0x11162                 # runtime addresses (file - 0x20)
AI_FLY_BOMBER = 0x1118E
AI_DIVE_AT_TARGET = 0x111BA
AI_BOMBING_RUN = 0x112C0
TARGET = 0x24900
TARGET_LIST = 0x24A00
TARGET_CTL = 0x25000             # target controller: pose ring of 75 x 0x14 at +0x36, index +0x612
SPAWN_WEAPON_ENTITY = 0x12820    # runtime address of file 0x12840
SPAWN_ORDNANCE_ORIENTED = 0x15D00  # runtime address of file 0x15d20
ARGS_WEAPON = 0x3F100            # the stubs' argument records (outside the stack guard)
ARGS_ORDNANCE = 0x3F200
SCENE = 0x2A800                  # zeroed scratch for routes, heap, parent and runway objects
SCENE_END = 0x2E000
ROUTE = 0x2A800                  # a prepared route block (+0 phase, +2 speed, +4 index, +6 count)
PARENT = 0x2B000                 # template parent of the aircraft object, slot table at SLOTS
SLOTS = 0x2B100
HEAP_SENTINEL = 0x20C58          # large-block free list: sentinel, rover at 0x20c60
HEAP_ROVER = 0x20C60
HEAP_BLOCK = 0x2C000             # one free block of 0x100 units (8 bytes each)
FACILITY = 0x2D000               # an air base (type word 0x13) near the runway pad
FACILITY_CTL = 0x2D100
FACILITY_REC = 0x2D200
PAD = 0x2D300                    # the runway: one 'p' quad
PAD_VERTS = 0x2D400
PAD_FACES = 0x2D500
PAD_INDEX = 0x2D600


def case(name: str, routine: int, extra: list[tuple[int, int, int]]) -> dict:
    w = base_writes(False)
    for addr in range(TARGET, TARGET + 0x60, 4):
        w.append([addr, 4, 0])
    for addr in range(TARGET_LIST, TARGET_LIST + 0x10, 4):
        w.append([addr, 4, 0])
    for addr in range(TARGET_CTL, TARGET_CTL + 0x700, 4):
        w.append([addr, 4, 0])
    for addr in range(SCENE, SCENE_END, 4):
        w.append([addr, 4, 0])
    w += [[HEAP_SENTINEL, 4, 0], [HEAP_SENTINEL + 4, 4, HEAP_BLOCK], [HEAP_ROVER, 4, HEAP_SENTINEL],
          [HEAP_BLOCK, 4, 0x100], [HEAP_BLOCK + 4, 4, HEAP_SENTINEL],
          [0x1B734, 4, 0], [0x1C1E0, 4, 0], [0x1B838, 4, 1000]]
    w += [[TARGET + 8, 4, TARGET_CTL], [0x1B876, 2, 3], [0x1B878, 2, 5], [0x20ADC, 4, TARGET_LIST], [OBJ + 0x1C, 4, 5000], [CTL + 0x62A, 4, 4 * 1400],
          [CTL + 0x668, 1, 6], [TARGET + 3, 1, 2], [TARGET + 0x44, 4, 0x25000]]
    return {"name": name, "routine": routine, "writes": w + [list(e) for e in extra]}


def target_at(x: int, y: int, z: int) -> list[tuple[int, int, int]]:
    return [(CTL + 0x692, 4, TARGET), (TARGET + 0x18, 4, x & 0xFFFFFFFF), (TARGET + 0x1C, 4, y), (TARGET + 0x20, 4, z & 0xFFFFFFFF)]


def pursuit(x: int, y: int, z: int, vx: int = 0, vz: int = 0, heading: int = 0) -> list[tuple[int, int, int]]:
    """A target at (x, y, z) whose pose ring (index 10) shows it moving (vx, 0, vz) per frame."""
    w = target_at(x, y, z) + [(TARGET_CTL + 0x612, 2, 10), (TARGET_CTL + 0x22, 2, heading),
                              (TARGET_CTL + 0x62A, 4, 4 * 1300)]
    for i in range(75):
        k = i - 10
        w += [(TARGET_CTL + 0x36 + i * 0x14, 4, (x + k * vx) & 0xFFFFFFFF),
              (TARGET_CTL + 0x3A + i * 0x14, 4, y),
              (TARGET_CTL + 0x3E + i * 0x14, 4, (z + k * vz) & 0xFFFFFFFF)]
    return w


def kind(k: int) -> list[tuple[int, int, int]]:
    return [(CTL + 0x614, 2, k)]


def route(phase: int, speed: int, index: int, points: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    w = [(CTL + 0x616, 4, ROUTE), (ROUTE, 2, phase & 0xFFFF), (ROUTE + 2, 2, speed), (ROUTE + 4, 2, index),
         (ROUTE + 6, 2, len(points))]
    for i, (x, y, z) in enumerate(points):
        w += [(ROUTE + 8 + 12 * i, 4, x & 0xFFFFFFFF), (ROUTE + 12 + 12 * i, 4, y), (ROUTE + 16 + 12 * i, 4, z & 0xFFFFFFFF)]
    return w


MISSION = [(-406400, 15000, 3078400), (-54100, 25000, 3385200), (-79700, 30000, 3697800), (52700, 30000, 3833200),
           (81200, 30000, 3933500), (-131700, 30000, 3909200), (-8600, 30000, 3135800), (-89100, 15000, 2859300)]
PATROL = [(20000, 6000, 30000), (-20000, 6000, 30000), (-20000, 2000, -30000), (20000, 9000, -30000)]


def own(x: int, y: int, z: int) -> list[tuple[int, int, int]]:
    return [(OBJ + 0x18, 4, x & 0xFFFFFFFF), (OBJ + 0x1C, 4, y), (OBJ + 0x20, 4, z & 0xFFFFFFFF)]


def parent_pose() -> list[tuple[int, int, int]]:
    """The aircraft object's template parent: slot 0 turned 0x400 and offset (1000, 2000, 3000)."""
    return [(OBJ + 0x24, 4, PARENT), (PARENT + 0x30, 4, SLOTS), (SLOTS + 2, 2, 0x400),
            (SLOTS + 8, 4, 1000), (SLOTS + 0xC, 4, 2000), (SLOTS + 0x10, 4, 3000)]


def runway(corners: list[tuple[int, int, int]], shift: int = 0) -> list[tuple[int, int, int]]:
    """object_pool = [air base, pad]; the pad has one 'p' quad (plus a non-runway face first)."""
    w = [(0x1B734, 4, 2), (0x1B5A4, 4, FACILITY), (0x1B5A8, 4, PAD),
         (FACILITY + 8, 4, FACILITY_CTL), (FACILITY_CTL + 4, 4, FACILITY_REC), (FACILITY_REC, 2, 0x13),
         (FACILITY + 0xC, 4, 200000), (FACILITY + 0x18, 4, 0), (FACILITY + 0x1C, 4, 0), (FACILITY + 0x20, 4, 20000),
         (PAD, 1, 2), (PAD + 0x18, 4, 0), (PAD + 0x20, 4, 0), (PAD + 0x34, 2, shift), (PAD + 0x3A, 2, 2),
         (PAD + 0x44, 4, PAD_VERTS), (PAD + 0x48, 4, PAD_FACES),
         (PAD_FACES + 0x14, 2, 4), (PAD_FACES + 0x16, 1, 0x71), (PAD_FACES + 0x18, 4, PAD_INDEX),
         (PAD_FACES + 0x34, 2, 4), (PAD_FACES + 0x36, 1, 0x70), (PAD_FACES + 0x38, 4, PAD_INDEX)]
    for i, (x, y, z) in enumerate(corners):
        w += [(PAD_VERTS + 12 * i, 4, x & 0xFFFFFFFF), (PAD_VERTS + 4 + 12 * i, 4, y & 0xFFFFFFFF),
              (PAD_VERTS + 8 + 12 * i, 4, z & 0xFFFFFFFF), (PAD_INDEX + 2 * i, 2, i)]
    return w


STRIP = [(-500, 0, -8000), (500, 0, -8000), (500, 0, 8000), (-500, 0, 8000)]
STRIP_ROTATED = [(500, 0, -8000), (500, 0, 8000), (-500, 0, 8000), (-500, 0, -8000)]

def glide(own_xyz: tuple[int, int, int], blend: int = 0, integral: int = 0, start: tuple[int, int] | None = None,
          dir_xz: tuple[int, int] = (0, 0x1000)) -> list[tuple[int, int, int]]:
    """Glide globals as try_begin_landing_approach leaves them: aim (0, 0x43, 0), runway along
    dir, floor 0x11b, saved handler 0x110d4; the aircraft at own_xyz."""
    sx, sz = start if start is not None else (own_xyz[0], own_xyz[2])
    return own(*own_xyz) + [
        (CTL + 0x32, 4, LANDING_GLIDE), (CTL + 0x2E, 4, 10), (CTL + 0x679, 1, 0x2D),
        (0x267BC, 4, 0), (0x267C0, 4, 0x43), (0x267C4, 4, 0),
        (0x267B2, 2, dir_xz[0] & 0xFFFF), (0x267B6, 2, 0xFDC0), (0x267BA, 2, dir_xz[1] & 0xFFFF),
        (0x267AE, 2, 0x11B), (0x26798, 4, 0x110D4), (0x267AC, 2, blend),
        (0x267A4, 4, 0), (0x267A8, 4, integral & 0xFFFFFFFF), (0x267A0, 4, sx & 0xFFFFFFFF), (0x2679C, 4, sz & 0xFFFFFFFF),
        (0x20B40, 4, 0), (0x1B83C, 2, 0)]


CASES = [
    case("glide: far (> 0xae30), high above the slope", LANDING_GLIDE, glide((300, 9000, -60000))),
    case("glide: band 0x8e30..0xae30, rise blended", LANDING_GLIDE, glide((-400, 5200, -40500))),
    case("glide: near, no rise, below 4000 throttle 0", LANDING_GLIDE, glide((150, 900, -12500))),
    case("glide: below the floor, integral clamped at 0x4b0", LANDING_GLIDE, glide((0, 80, -30000))),
    case("glide: off the centre line (lateral offset)", LANDING_GLIDE, glide((-6000, 4000, -36000))),
    case("glide: skewed runway direction", LANDING_GLIDE, glide((9000, 4000, -30000), dir_xz=(0x0B50, 0x0B50))),
    case("glide: blend 1 (with velocity)", LANDING_GLIDE, glide((200, 4000, -30000), blend=1, start=(1000, -29000)) + [(CTL + 8, 4, 20), (CTL + 0xC, 4, 0xFFFFFFF8), (CTL + 0x10, 4, 60)]),
    case("glide: blend 2 wraps to 0", LANDING_GLIDE, glide((200, 4000, -30000), blend=2) + [(CTL + 8, 4, 20), (CTL + 0x10, 4, 60)]),
    case("glide: touchdown restores the saved handler", LANDING_GLIDE, glide((0, 70, -9000)) + [(CTL + 0x63E, 1, 1)]),
    case("glide: wave-off window, height error", LANDING_GLIDE, glide((0, 6000, -15000))),
    case("glide: wave-off window, speed error", LANDING_GLIDE, glide((0, 2600, -16500)) + [(CTL + 0x62A, 4, 4 * 4000)]),
    case("glide: integral 0x4a0 pulled back (below the slope)", LANDING_GLIDE, glide((0, 3000, -30000), integral=0x4A0)),
    case("glide: integral clamped at -0x4b0", LANDING_GLIDE, glide((0, 9000, -30000), integral=-0x4A0)),
    case("glide: type10 tracker object mirrors the target", LANDING_GLIDE, glide((100, 4000, -30000)) + [(0x20B40, 4, TARGET_CTL), (TARGET_CTL, 4, TARGET)]),
    case("kind 1: first use builds the patrol (heap, parent pose), climbs", AI_FLY, kind(1) + parent_pose() + own(0, 5000, 0)),
    case("kind 2: first use, low with the gear lowering", AI_FLY, kind(2) + parent_pose() + own(0, 1000, 0) + [(CTL + 0x679, 1, 5)]),
    case("kind 5: first use (speed 0xd5c), climb flaps set", AI_FLY, kind(5) + own(0, 1500, 0) + [(CTL + 0x67B, 1, 3), (CTL + 0x20, 2, 0x3000)]),
    case("kind 1: patrol leg, steering to the point", AI_FLY, kind(1) + route(1, 0x9D8, 0, PATROL) + own(1000, 5000, 1000)),
    case("kind 2: patrol point reached, next one pushed out", AI_FLY, kind(2) + route(1, 0x9D8, 1, PATROL) + own(-18000, 5000, 28000)),
    case("kind 5: last point reached, wraps to 0", AI_FLY, kind(5) + route(1, 0xD5C, 3, PATROL) + own(19000, 8000, -29000)),
    case("kind 1: low point, aim 0x1000 above the ground", AI_FLY, kind(1) + route(1, 0x9D8, 2, PATROL) + own(0, 3000, 0) + [(CTL + 0x2E, 4, 1500)]),
    case("kind 4: attack run starts near the fixed point", AI_FLY, kind(4) + route(1, 0xD5C, 0, PATROL) + own(-265459 + 30000, 25000, 2827370)),
    case("kind 4: attack run not while burning", AI_FLY, kind(4) + route(1, 0xD5C, 0, PATROL) + own(-265459 + 30000, 25000, 2827370) + [(CTL + 0x684, 1, 1)]),
    case("kind 4: attack run too low", AI_FLY, kind(4) + route(1, 0xD5C, 0, PATROL) + own(-265459, 20000, 2827370)),
    case("kind 4: bomb release waits for the frame", AI_FLY, kind(4) + route(2, 0xD5C, 0, PATROL) + own(0, 9000, 0) + [(CTL + 0x67C, 1, 3), (CTL + 0x6AC, 4, 1001)]),
    case("kind 4: bombs gone -> phase 3", AI_FLY, kind(4) + route(2, 0xD5C, 0, PATROL) + own(0, 9000, 0) + [(CTL + 0x6AC, 4, 1000)]),
    case("kind 4: bomb phase busy", AI_FLY, kind(4) + route(2, 0xD5C, 0, PATROL) + own(0, 9000, 0) + [(CTL + 0x67C, 1, 3), (CTL + 0x674, 1, 3)]),
    case("kind 4: bomb release roll (rng cursor 0x26024)", AI_FLY, kind(4) + route(2, 0xD5C, 0, PATROL) + own(0, 9000, 0) + [(CTL + 0x67C, 1, 3), (0x26008, 4, 0x26024)]),
    case("kind 3: first use copies the mission route", AI_FLY, kind(3) + own(-80000, 1000, 2860000)),
    case("kind 3: phase 1 at point 4 -> 2", AI_FLY, kind(3) + route(1, 0, 4, MISSION) + own(0, 30000, 3900000)),
    case("kind 3: phase 1 en route", AI_FLY, kind(3) + route(1, 0, 2, MISSION) + own(0, 30000, 3500000)),
    case("kind 3: phase 3 back at point 0, no runway", AI_FLY, kind(3) + route(3, 0, 7, MISSION) + own(-89000, 15000, 2859000)),
    case("kind 3: phase 3 back at point 0, landing approach", AI_FLY, kind(3) + route(3, 0, 7, MISSION) + own(-89000, 15000, 2859000)
         + runway([(x - 89000, y, z + 2900000) for x, y, z in STRIP]) + [(PAD + 0x18, 4, 0), (CTL + 0x67B, 1, 4), (CTL + 0x684, 2, 0x4000), (CTL + 0x32, 4, 0x110D4)]),
    case("landing approach: rotated pad, shifted vertices", AI_FLY, kind(3) + route(3, 0, 7, MISSION) + own(-89000, 15000, 2859000)
         + runway([(2 * (x - 89000), 2 * y, 2 * (z + 2880000)) for x, y, z in STRIP_ROTATED], 1)),
    case("landing approach: runway too close", AI_FLY, kind(3) + route(3, 0, 7, MISSION) + own(-89000, 15000, 2859000)
         + runway([(x - 89000, 14000, z + 2867000) for x, y, z in STRIP])),
    case("kind 3: phase 4 in host mode 5, type key 2 -> glide", AI_FLY, kind(3) + route(4, 0, 0, MISSION) + own(0, 2000, 0) + [(WORLD + 0x90, 2, 5), (0x1A790, 2, 2)]),
    case("kind 3: phase 5 fast glide", AI_FLY, kind(3) + route(5, 0, 0, MISSION) + own(0, 2000, 0) + [(CTL + 0x62A, 4, 4 * 2000)]),
    case("kind 3: phase 2 bombs gone -> 3", AI_FLY, kind(3) + route(2, 0, 5, MISSION) + own(-130000, 30000, 3900000)),
    case("kind 3: phase 0 climb", AI_FLY, kind(3) + route(0, 0, 3, MISSION) + own(0, 2500, 0)),
    case("kind 3: unknown phase chases the player", AI_FLY, kind(3) + route(9, 0, 3, MISSION) + own(0, 2500, 0) + [(0x1B738, 4, TARGET_CTL), (TARGET_CTL, 4, TARGET), (TARGET + 0x18, 4, 5000), (TARGET + 0x1C, 4, 4000)]),
    case("attack: no ammo drops the target", AI_ATTACK_OR_FLY, target_at(100, 5000, 3000) + [(CTL + 0x682, 2, 1)]),
    case("attack: dead target dropped", AI_ATTACK_OR_FLY, target_at(100, 5000, 3000) + [(TARGET + 7, 1, 2)]),
    case("attack: no target flies the kind step", AI_ATTACK_OR_FLY, []),
    case("pursue: beyond 20000 steers straight", AI_ATTACK_OR_FLY, pursuit(15000, 7000, 18000) + [(CTL + 0x69A, 1, 2)]),
    case("pursue: ahead at 0x2800, attack", AI_ATTACK_OR_FLY, pursuit(300, 5200, 10000, 4, 30)),
    case("pursue: ahead at 0x1800, throttle blend", AI_ATTACK_OR_FLY, pursuit(-200, 4900, 6000, 0, 25)),
    case("pursue: close at 0xc00, throttle scaled", AI_ATTACK_OR_FLY, pursuit(50, 5050, 3000, 3, 20)),
    case("pursue: very close, throttle 0", AI_ATTACK_OR_FLY, pursuit(10, 5000, 1500, 0, 20)),
    case("pursue: dead ahead, guns (+0x676)", AI_ATTACK_OR_FLY, pursuit(0, 5000, 4000, 0, 0)),
    case("pursue: far side, attack beyond 0x3000", AI_ATTACK_OR_FLY, pursuit(-9000, 6000, 12000, -20, 10)),
    case("pursue: behind, same heading -> manoeuvre", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30)),
    case("pursue: behind, fast, level -> maybe loop", AI_ATTACK_OR_FLY, pursuit(-700, 5100, -5000, 5, 30) + [(CTL + 0x62A, 4, 4 * 3500)]),
    case("pursue: behind, opposite heading -> rng", AI_ATTACK_OR_FLY, pursuit(800, 5000, -7000, 0, -30, 0x2000)),
    case("pursue: behind, manoeuvre 4 keeps attacking", AI_ATTACK_OR_FLY, pursuit(800, 5000, -7000, 0, -30, 0x2000) + [(CTL + 0x69A, 1, 4)]),
    case("manoeuvre 1 phase 0 near waypoint", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 1), (CTL + 0x69C, 4, 300), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A4, 4, 200), (CTL + 0x6A8, 4, 100)]),
    case("manoeuvre 1 phase 1 near waypoint -> repick", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 1), (CTL + 0x69B, 1, 1), (CTL + 0x69C, 4, 300), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 100)]),
    case("manoeuvre 2 phase 0 within 400", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 2), (CTL + 0x69C, 4, 100), (CTL + 0x6A0, 4, 5100), (CTL + 0x6A8, 4, 900)]),
    case("manoeuvre 2 phase 1", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 2), (CTL + 0x69B, 1, 1), (CTL + 0x69C, 4, 100), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 900), (CTL + 0x22, 2, 0x300)]),
    case("manoeuvre 2 phase 2", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 2), (CTL + 0x69B, 1, 2), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A4, 4, 300), (CTL + 0x6A8, 4, 900)]),
    case("manoeuvre 3 phase 0", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 3), (CTL + 0x69C, 4, 1000), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 10), (CTL + 0x22, 2, 0x34)]),
    case("manoeuvre 3 phase 1", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 3), (CTL + 0x69B, 1, 1), (CTL + 0x6A0, 4, 6000), (CTL + 0x6A8, 4, 10)]),
    case("manoeuvre 3 phase 2", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 3), (CTL + 0x69B, 1, 2), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 10)]),
    case("manoeuvre 2 waypoint far: keeps flying to it", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 2), (CTL + 0x69C, 4, 3000), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 4000)]),
    case("manoeuvre 2 waypoint receding past best", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 2), (CTL + 0x69C, 4, 1500), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 1400)]),
    case("manoeuvre 2 waypoint closing (not past best)", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 2), (CTL + 0x69C, 4, 1500), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 1600)]),
    case("manoeuvre 3 phase 0 (pitched 0x100)", AI_ATTACK_OR_FLY, pursuit(500, 5000, -6000, 0, 30) + [(CTL + 0x69A, 1, 3), (CTL + 0x6A0, 4, 5000), (CTL + 0x6A8, 4, 10), (CTL + 0x20, 2, 0x100)]),
    case("manoeuvre 4 ends on rng & 0x1f == 0 (rng cursor 0x2603c)", AI_ATTACK_OR_FLY, pursuit(-800, 5000, -7000, 0, -30, 0x2100) + [(CTL + 0x69A, 1, 4), (0x26008, 4, 0x2603C)]),
    case("other-type lag 0x1b878 (record key 2)", AI_ATTACK_OR_FLY, pursuit(300, 5200, 10000, 4, 30) + [(0x1A790, 2, 2)]),
    case("ai_fly: kind 0 flies update_aircraft_entity", AI_FLY, []),
    case("ai_fly_bomber: kind 0 flies update_aircraft_entity", AI_FLY_BOMBER, [(CTL + 0x662, 2, 80)]),
    case("dive: near target, aims at its height", AI_DIVE_AT_TARGET, target_at(20000, 1500, -15000)),
    case("dive: far target, aims at 40000", AI_DIVE_AT_TARGET, target_at(-60000, 1500, 30000)),
    case("dive: dead target released, ammo -> 0x110d4", AI_DIVE_AT_TARGET, target_at(100, 0, 100) + [(TARGET + 7, 1, 2)]),
    case("dive: target without vertices, no ammo -> 0x11162", AI_DIVE_AT_TARGET, target_at(100, 0, 100) + [(TARGET + 0x44, 4, 0), (CTL + 0x682, 2, 2)]),
    case("dive: no target, host mode 0 -> state reset", AI_DIVE_AT_TARGET, []),
    case("dive: no target, host mode 7, empty list -> flies on", AI_DIVE_AT_TARGET, [(WORLD + 0x90, 2, 7)]),
    case("dive: no target, host mode 7, list busy -> state reset", AI_DIVE_AT_TARGET, [(WORLD + 0x90, 2, 7), (TARGET_LIST + 4, 2, 3)]),
    case("bombing: no bombs -> released", AI_BOMBING_RUN, target_at(1000, 0, 1000)),
    case("bombing: no target -> state reset", AI_BOMBING_RUN, [(CTL + 0x67C, 1, 4)]),
    case("bombing stage 0: far, heads in at 30000", AI_BOMBING_RUN, target_at(70000, 300, 0) + [(CTL + 0x67C, 1, 4)]),
    case("bombing stage 0: near and high -> stage 1", AI_BOMBING_RUN, target_at(30000, 300, 0) + [(CTL + 0x67C, 1, 4), (OBJ + 0x1C, 4, 26000)]),
    case("bombing stage 0: near but low", AI_BOMBING_RUN, target_at(30000, 300, 0) + [(CTL + 0x67C, 1, 4), (OBJ + 0x1C, 4, 24999)]),
    case("bombing stage 1: diving above 5000", AI_BOMBING_RUN, target_at(8000, 300, 2000) + [(CTL + 0x67C, 1, 4), (CTL + 0x675, 1, 1), (OBJ + 0x1C, 4, 9000), (CTL + 0x2E, 4, 77)]),
    case("bombing stage 1: below 5000 arms the bombs", AI_BOMBING_RUN, target_at(3000, 300, 1000) + [(CTL + 0x67C, 1, 4), (CTL + 0x675, 1, 1), (OBJ + 0x1C, 4, 4999)]),
    case("bombing stage 2: pulling out near", AI_BOMBING_RUN, target_at(3000, 300, 1000) + [(CTL + 0x67C, 1, 4), (CTL + 0x675, 1, 2), (CTL + 8, 4, 0xFFFFFFF0), (CTL + 0x10, 4, 12)]),
    case("bombing stage 2: past 45000 resets and releases", AI_BOMBING_RUN, target_at(-50000, 300, 1000) + [(CTL + 0x67C, 1, 4), (CTL + 0x675, 1, 2), (CTL + 8, 4, 30), (CTL + 0x10, 4, 5)]),
    case("bombing stage 3: no stage flies the kind step", AI_BOMBING_RUN, target_at(3000, 300, 1000) + [(CTL + 0x67C, 1, 4), (CTL + 0x675, 1, 3)]),
]


def record_args(emu: Emulator, out: int, count: int) -> int:
    """The spawn stub: copy its long arguments to out and return 0 (no object)."""
    for i in range(count):
        emu.write(out + 4 * i, 4, emu.read(emu.a[7] + 4 * i, 4))
    return 0


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    emu.stubs[SPAWN_WEAPON_ENTITY] = lambda e: record_args(e, ARGS_WEAPON, 8)
    emu.stubs[SPAWN_ORDNANCE_ORIENTED] = lambda e: record_args(e, ARGS_ORDNANCE, 9)
    before = bytes(emu.mem)
    emu.call(c["routine"], [CTL], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def compact(writes: list[list[int]]) -> tuple[list[list[int]], list[list[int]]]:
    """Runs of zero longs become [start, end) ranges, cleared before the remaining writes; the
    result must leave memory exactly as the writes in order do."""
    zero: list[list[int]] = []
    rest: list[list[int]] = []
    written: set[int] = set()
    for addr, size, value in writes:
        clearable = size == 4 and value == 0 and not written.intersection(range(addr, addr + 4))
        if clearable and zero and zero[-1][1] == addr:
            zero[-1][1] = addr + 4
        elif clearable:
            zero.append([addr, addr + 4])
        else:
            rest.append([addr, size, value])
            written.update(range(addr, addr + size))

    def apply(state: dict[int, int], items: list[list[int]]) -> None:
        for addr, size, value in items:
            for k in range(size):
                state[addr + k] = (value >> (8 * (size - 1 - k))) & 0xFF

    ordered: dict[int, int] = {}
    apply(ordered, writes)
    replay: dict[int, int] = {a: 0 for start, end in zero for a in range(start, end)}
    apply(replay, rest)
    assert replay == ordered, "compacted writes differ"
    return zero, rest


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD),
           "ctl": CTL, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
