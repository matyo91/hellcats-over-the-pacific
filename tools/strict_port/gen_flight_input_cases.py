#!/usr/bin/env python3
"""Generate comparison cases for process_flight_input_and_outcome by running the ORIGINAL bytes.

A player aircraft (controller, object, definition with a pose ring), an optional designated
target and an optional facility object (for probe_nearest_facility_kind) sit in a quiet world:
no controllers to tick, sound off, an empty contact table, three span-row buffers for
update_view_clip_bounds. Cases press every key of the dispatch table (down / up / between
frames, in the views and modes that change what it does), drive the throttle ramp and the
keyboard-steered mouse point, fire the gun, run the replay / crash-end / instant-replay
transitions, classify stopped aircraft (ditched, after a touchdown, on and off the runway, fuel
recording; the random status draws run on the seeded overlay RNG) and move the camera for views
1, 2, 5, 6, 7 and 9. The host sound routines (+0x2aa / +0x2b6 / +0x2ba / +0x2be) are logging
stubs on both sides; everything else runs as ported. test_flight_input.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_flight_input_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_TOP  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/flight_input_cases.json")
ROUTINE = 0x73EA                                    # runtime address (file 0x740a)
STACK_GUARD = (STACK_TOP - 0x1000, STACK_TOP + 0x40)
PLAY, IS_PLAYING, STOP1, STOP = 0x30000, 0x30100, 0x30200, 0x30300
CALL_LOGS = [[PLAY, 0x38004, 6], [IS_PLAYING, 0x38404, 1], [STOP1, 0x38804, 1], [STOP, 0x38C04, 1]]
WORLD, PLAYER, OBJ, DEF = 0x27000, 0x28000, 0x28800, 0x28900
TARGET, TOBJ, TDEF = 0x29000, 0x29800, 0x29900
FAC, FCTL, FDEF = 0x29A00, 0x29A80, 0x29AC0
ROWS = 0x2A000
FRAME = 1000
SLEW, NORMAL = 0xF7F0, 0xE772
RNG_NEXT = 0x11544                                  # overlay_rng_next (file 0x11564)


def case(name: str, key: int = 0, event: int = 0, view: int = 1, playing: int = 0, target: bool = True,
         ground: bool = False, facility: int = 0, extra: list[tuple[int, int, int]] = ()) -> dict:
    w = [(a, 4, 0) for start, end in [(WORLD, WORLD + 0x400), (PLAYER, 0x2A400), (0x38000, 0x39000),
                                      (0x1BDBC, 0x1BDBC + 0x400), (0x1B5A4, 0x1B5A4 + 0x20), (0x1C25C, 0x1C25C + 0x20),
                                      (0x260EC, 0x260EC + 0x184), (0x20AFC, 0x20B30), (0x24CF4, 0x24D38)]
         for a in range(start, end, 4)]
    w += [(0x38404 - 4, 4, playing)]
    vals = [(0x1B5A0, 4, WORLD), (WORLD + 0x25E, 4, 0), (WORLD + 0x2AA, 4, PLAY), (WORLD + 0x2B6, 4, IS_PLAYING),
            (WORLD + 0x2BA, 4, STOP1), (WORLD + 0x2BE, 4, STOP), (WORLD + 0x33E, 2, 0x40), (WORLD + 0x340, 2, 0x28),
            (0x1B738, 4, PLAYER), (0x1B888, 4, TARGET if target else 0), (0x1D858, 2, view), (0x1B870, 2, 0), (0x1B86E, 2, 0),
            (0x1B86C, 2, 0), (0x1B87C, 4, 0), (0x1B884, 4, 0), (0x1B874, 2, 0), (0x1B872, 2, 0), (0x1B858, 2, 0),
            (0x1B868, 2, 0), (0x1B86A, 2, 0), (0x1B73C, 2, 0), (0x1D856, 2, 0), (0x1B838, 4, FRAME), (0x1C1CC, 4, 0),
            (0x1C1C8, 4, 0), (0x1C1E0, 4, 0), (0x1B734, 4, 1 if facility else 0), (0x1B828, 2, 8), (0x1B82A, 2, 0x40), (0x1DAA0, 2, 0x55),
            (0x1B778, 4, ROWS), (0x1B77C, 4, ROWS + 0x100), (0x1B780, 4, ROWS + 0x200), (0x20AE2, 2, 0),
            (0x20B2A, 2, 0x40), (0x20B2C, 2, 0x28), (0x20B28, 2, 256), (0x20B26, 2, 200), (0x20B14, 2, 256), (0x20AFC, 2, 200),
            (0x1D804, 4, 0), (0x1D800, 4, 0), (0x1D838, 4, 0), (0x1D834, 4, 0), (0x1D830, 4, 0), (0x1B880, 4, 0),
            (0x1B87A, 2, 0), (0x1D81C, 4, 30), (0x1D818, 4, -5), (0x1D814, 4, 40), (0x24D28, 4, 99500), (0x24D24, 4, 3100),
            (0x24D20, 4, -40100)]
    vals += [(0x260EE + 0x18 * i + 0x14, 4, 0x7FFFFFFF) for i in range(16)]
    # The player: object, definition, attitude, a pose ring of 75 entries (+0x36, 0x14 each).
    vals += [(PLAYER, 4, OBJ), (PLAYER + 4, 4, DEF), (OBJ + 8, 4, PLAYER), (OBJ + 0x18, 4, 100000), (OBJ + 0x1C, 4, 3000),
             (OBJ + 0x20, 4, -40000), (OBJ + 0x14, 4, 0x200), (PLAYER + 0x20, 2, 0x0123), (PLAYER + 0x22, 2, 0x0456),
             (PLAYER + 0x24, 2, 0x0789), (DEF + 0x44, 2, 0x0100), (DEF + 0x1C, 2, 0x50), (PLAYER + 0x626, 2, 0x0040),
             (PLAYER + 0x32, 4, NORMAL), (PLAYER + 0x2E, 4, 0x100), (PLAYER + 0x612, 2, 30), (PLAYER + 0x682, 2, 50),
             (PLAYER + 0x668, 1, 5), (PLAYER + 0x62A, 4, 0 if ground else 0x2000), (PLAYER + 0x63E, 1, 1 if ground else 0),
             (PLAYER + 0x66A, 4, 0 if ground else 15000), (PLAYER + 0x67D, 1, 20), (PLAYER + 0x67E, 1, 12),
             (PLAYER + 0x67C, 1, 3), (PLAYER + 0x2C, 1, 0x30)]
    for i in range(75):
        e = PLAYER + 0x36 + 0x14 * i
        vals += [(e, 4, 99000 + 10 * i), (e + 4, 4, 2900 + i), (e + 8, 4, -40500 + 7 * i), (e + 0xC, 2, 0x100 + i),
                 (e + 0xE, 2, 0x2000 + 3 * i), (e + 0x10, 2, -5 * i)]
    if target:
        vals += [(TARGET, 4, TOBJ), (TARGET + 4, 4, TDEF), (TOBJ + 0x18, 4, 104000), (TOBJ + 0x1C, 4, 3500),
                 (TOBJ + 0x20, 4, -38000), (TARGET + 0x20, 2, 0x0200), (TARGET + 0x22, 2, 0x3000), (TARGET + 0x24, 2, 0x0010),
                 (TDEF + 0x44, 2, 0x0300), (TARGET + 0x626, 2, 0x0123)]
    if facility:
        vals += [(0x1B5A4, 4, FAC), (FAC + 8, 4, FCTL), (FCTL + 4, 4, FDEF), (FDEF, 2, facility), (FAC + 0xC, 4, 50000),
                 (FAC + 0x18, 4, 100500), (FAC + 0x1C, 4, 3000), (FAC + 0x20, 4, -40200)]
    draws = sum(s for a, s, v in extra if a == "rng")
    extra = [e for e in extra if e[0] != "rng"]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals + list(extra)]
    w = [list(x) for x in w]
    if draws:                                     # advance the overlay RNG: its state becomes writes
        emu = Emulator(MEMORY_SIZE)
        emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
        start = bytes(emu.mem)
        for _ in range(draws):
            emu.call(RNG_NEXT, [], STACK_TOP)
        w = [[a, 4, int.from_bytes(emu.mem[a:a + 4], "big")] for a in range(0, MEMORY_SIZE, 4)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a:a + 4] != start[a:a + 4]] + w
    return {"name": name, "routine": ROUTINE, "args": [key, event], "writes": w}


DOWN, UP = 3, 4
SLEWING = [(PLAYER + 0x32, 4, SLEW)]
STEER = [(0x24D34, 2, 1), (0x24D32, 2, 0x40), (0x24D30, 2, 0x28)]
STOPPED = [(PLAYER + 0x62A, 4, 0), (PLAYER + 0x66A, 4, 0)]
CASES = [
    case("idle frame in the cockpit"),
    case("unfiltered key between frames", key=0x51),
    case("key up of an unlisted key", key=0x46, event=UP),
    case("out-of-table key down", key=0x7F, event=DOWN),
    case("Tab cycles the view distance", key=9, event=DOWN, extra=[(0x2666A, 4, 0xCE40)]),
    case("control-S: into slew mode", key=0x13, event=DOWN),
    case("control-S: back to normal flight", key=0x13, event=DOWN, extra=SLEWING),
    case("control-X flags the target", key=0x18, event=DOWN),
    case("control-X without a target", key=0x18, event=DOWN, target=False),
    case("ESC ends the flight", key=0x1B, event=DOWN),
    case("backquote ends the flight", key=0x60, event=DOWN),
    case("left arrow", key=0x1C, event=DOWN, extra=[(0x24CFC, 4, 0x100)]),
    case("right arrow wraps", key=0x1D, event=DOWN, extra=[(0x24CFC, 4, 0x3C00)]),
    case("up arrow", key=0x1E, event=DOWN),
    case("up arrow at its limit", key=0x1E, event=DOWN, extra=[(0x24CF8, 4, 0x3040)]),
    case("down arrow", key=0x1F, event=DOWN, view=2),
    case("down arrow at its limit", key=0x1F, event=DOWN, extra=[(0x24CF8, 4, 0xA80)]),
    case("arrow in the chase view does nothing", key=0x1C, event=DOWN, view=5),
    case("space on the ground: brakes on", key=0x20, event=DOWN, ground=True),
    case("space released on the ground", key=0x20, event=UP, ground=True, extra=[(PLAYER + 0x641, 1, 1)]),
    case("space in the air with keyboard steering: fire", key=0x20, event=DOWN, extra=STEER),
    case("space in the air without keyboard steering", key=0x20, event=DOWN),
    case("space while bailed out", key=0x20, event=DOWN, ground=True, extra=[(0x1B874, 2, 1)]),
    case("plus: throttle ramp up", key=0x2B, event=DOWN),
    case("plus released", key=0x3D, event=UP, extra=[(0x24CF6, 2, 2)]),
    case("minus: throttle ramp down", key=0x2D, event=DOWN),
    case("underscore between frames", key=0x5F, event=0, extra=[(0x24CF6, 2, -2)]),
    case("plus in view 6 zooms in", key=0x2B, event=DOWN, view=6, extra=[(0x20AF4, 2, 2), (0x1D838, 4, 99000)]),
    case("plus in view 6 at the last zoom", key=0x2B, event=DOWN, view=6, extra=[(0x20AF4, 2, 8)]),
    case("minus in view 6 zooms out", key=0x2D, event=DOWN, view=6, extra=[(0x20AF4, 2, 3), (0x20B16, 2, 300), (0x20AFE, 2, 250)]),
    case("minus in view 6 at the first zoom", key=0x2D, event=DOWN, view=6),
    case("Z down: rudder left", key=0x5A, event=DOWN),
    case("> down: rudder left", key=0x3E, event=DOWN),
    case("z down clears the rudder", key=0x7A, event=DOWN, extra=[(0x1B858, 2, 0x40)]),
    case("X down: rudder right", key=0x58, event=DOWN),
    case("? down: rudder right", key=0x3F, event=DOWN),
    case("X released clears the rudder", key=0x58, event=UP, extra=[(0x1B858, 2, -0x40)]),
    case("/ between frames clears the rudder", key=0x2F, event=0, extra=[(0x1B858, 2, -0x40)]),
    case("digit 0 in normal flight does nothing", key=0x30, event=DOWN),
    case("digit 7 in slew mode sets the throttle", key=0x37, event=DOWN, extra=SLEWING + [(PLAYER + 0x684, 2, 0x4000)]),
    case("digit 2: elevator down", key=0x32, event=DOWN),
    case("digit 2 released", key=0x32, event=UP),
    case("digit 8: elevator up", key=0x38, event=DOWN),
    case("digit 8 released", key=0x38, event=UP),
    case("digit 4: aileron left", key=0x34, event=DOWN),
    case("digit 4 released", key=0x34, event=UP),
    case("digit 6: aileron right", key=0x36, event=DOWN),
    case("digit 6 released", key=0x36, event=UP),
    case("digit 5 recentres the mouse", key=0x35, event=DOWN),
    case("digit 4 in slew mode", key=0x34, event=DOWN, extra=SLEWING),
    case("digit 5 in slew mode", key=0x35, event=DOWN, extra=SLEWING),
    case("A: target lock", key=0x41, event=DOWN),
    case("a released: lock off", key=0x61, event=UP, extra=[(0x1B872, 2, 1)]),
    case("A without a target", key=0x41, event=DOWN, target=False),
    case("B: bomb run high enough", key=0x42, event=DOWN),
    case("b too low", key=0x62, event=DOWN, extra=[(PLAYER + 0x2E, 4, 3000 - 0x43)]),
    case("C: chase view", key=0x43, event=DOWN, extra=[(OBJ + 7, 1, 0x40), (OBJ + 4, 4, 0x40)]),
    case("C in the chase view returns to the cockpit", key=0x63, event=DOWN, view=5),
    case("E: target view", key=0x45, event=DOWN),
    case("E without a target falls into V", key=0x65, event=DOWN, target=False, view=5),
    case("E on the ground falls into V", key=0x45, event=DOWN, ground=True, view=2),
    case("V: cockpit, look reset", key=0x56, event=DOWN, view=5, extra=[(0x24CF8, 4, 0x500), (0x1D800, 4, 0x700)]),
    case("F: flaps out", key=0x46, event=DOWN),
    case("f: flaps toggled back", key=0x66, event=DOWN, extra=[(PLAYER + 0x67B, 1, 7)]),
    case("F while bailed out", key=0x46, event=DOWN, extra=[(0x1B874, 2, 1)]),
    case("G: gear down, no approach", key=0x47, event=DOWN),
    case("g: gear up", key=0x67, event=DOWN, extra=[(PLAYER + 0x679, 1, 0x2D)]),
    case("G down with approaches on: refused (no runway)", key=0x47, event=DOWN,
         extra=[(WORLD + 0xA4, 2, 1), (0x1B734, 4, 1), (0x1B5A4, 4, FAC), (FAC, 1, 4)]),
    case("G on the ground does nothing", key=0x47, event=DOWN, ground=True),
    case("J: bail out", key=0x4A, event=DOWN),
    case("j already bailing", key=0x6A, event=DOWN, extra=[(PLAYER + 0x677, 1, 1)]),
    case("M: engine off", key=0x4D, event=DOWN),
    case("P pauses (result 4)", key=0x50, event=DOWN),
    case("R: look back in the cockpit", key=0x52, event=DOWN),
    case("r in the chase view: cockpit looking back", key=0x72, event=DOWN, view=5),
    case("T: external camera near the camera", key=0x54, event=DOWN, extra=[(0x1D824, 4, 1000), (0x1D828, 4, 50), (0x1D82C, 4, -900)]),
    case("T in view 6 returns to the cockpit", key=0x74, event=DOWN, view=6),
    case("throttle ramp +1 (engine on)", extra=[(0x24CF6, 2, 1)]),
    case("throttle ramp -1 clamps at 0", extra=[(0x24CF6, 2, -1), (PLAYER + 0x668, 1, 0)]),
    case("throttle ramp +1 clamps at 9", extra=[(0x24CF6, 2, 1), (PLAYER + 0x668, 1, 9)]),
    case("throttle ramp with the engine off restarts it", extra=[(0x24CF6, 2, 1), (PLAYER + 0x684, 2, 0x4000)]),
    case("throttle ramp 2 steps down", extra=[(0x24CF6, 2, 2)]),
    case("throttle ramp -2 steps up", extra=[(0x24CF6, 2, -2)]),
    case("keyboard steering recentres (small offsets)", extra=STEER + [(WORLD + 0x33E, 2, 0x40 - 10), (0x24D32, 2, 0x40 - 10),
                                                                      (WORLD + 0x340, 2, 0x28 + 7), (0x24D30, 2, 0x28 + 7)]),
    case("keyboard steering recentres (large offsets)", extra=STEER + [(WORLD + 0x33E, 2, 0x40 + 100), (0x24D32, 2, 0x40 + 100),
                                                                      (WORLD + 0x340, 2, 0x28 - 90), (0x24D30, 2, 0x28 - 90)]),
    case("keyboard steering clamps far offsets", extra=STEER + [(WORLD + 0x33E, 2, 0x40 - 300), (0x24D32, 2, 0x40 - 300),
                                                               (WORLD + 0x340, 2, 0x28 + 250), (0x24D30, 2, 0x28 + 250)]),
    case("keyboard steering clamps the other way", extra=STEER + [(WORLD + 0x33E, 2, 0x40 + 300), (0x24D32, 2, 0x40 + 300),
                                                                 (WORLD + 0x340, 2, 0x28 - 250), (0x24D30, 2, 0x28 - 250)]),
    case("keyboard steering with keys held", extra=STEER + [(0x24D2E, 2, 1), (0x24D2C, 2, -1)]),
    case("keyboard steering with the other keys held", extra=STEER + [(0x24D2E, 2, -1), (0x24D2C, 2, 1)]),
    case("a real mouse move ends keyboard steering", extra=STEER + [(WORLD + 0x33E, 2, 0x50), (WORLD + 0x342, 2, 1)]),
    case("mouse button fires the gun", extra=[(WORLD + 0x342, 2, 1)]),
    case("gun already cycling", extra=[(WORLD + 0x342, 2, 1), (PLAYER + 0x676, 1, 2)]),
    case("gun out of ammo", extra=[(WORLD + 0x342, 2, 1), (PLAYER + 0x682, 2, 1)]),
    case("gun jammed (+0x685 bit 4)", extra=[(WORLD + 0x342, 2, 1), (PLAYER + 0x685, 1, 0x10)]),
    case("replay running: state 1 -> 2", extra=[(0x1B870, 2, 1), (0x1B86E, 2, 5)]),
    case("replay over: view 8 ends into view 1", view=8, extra=[(0x1B870, 2, 3)]),
    case("view 8 ends into view 9 with a parachute", view=8, extra=[(0x1B87C, 4, 0x29F00)]),
    case("view 8 ends, player already hidden", view=8, extra=[(OBJ + 7, 1, 0x40), (OBJ + 4, 4, 0x40)]),
    case("crash end: replay from behind (channel idle)", extra=[(WORLD + 0x98, 2, 2), (WORLD + 0x25E, 4, 0x2A800)]),
    case("crash end: channel 0 silenced", playing=1, extra=[(WORLD + 0x98, 2, 2), (WORLD + 0x25E, 4, 0x2A800)]),
    case("instant replay requested in the air", extra=[(WORLD + 0x98, 2, 1)]),
    case("instant replay requested on the ground", ground=True, extra=[(WORLD + 0x98, 2, 1)]),
    case("view 7 without a target returns to the cockpit", view=7, target=False),
    case("view 7 on the ground returns to the cockpit", view=7, ground=True),
    case("view 7 follows the target", view=7),
    case("view 8 replay, ESC ends it", key=0x1B, event=DOWN, view=8, extra=[(0x1B870, 2, 3), (0x1B86E, 2, 5)]),
    case("view 9, quote key ends it", key=0x22, event=DOWN, view=9),
    case("view 9 ignores other keys", key=0x41, event=DOWN, view=9, extra=[(0x1B87C, 4, 0)]),
    case("cockpit with a look target switches to view 2", extra=[(0x24CFC, 4, 0x800)]),
    case("look view eases with host +0xa0", view=2, extra=[(WORLD + 0xA0, 2, 1), (0x24CF8, 4, 0x540), (0x24CFC, 4, 0x3800),
                                                          (0x1D804, 4, 0x100), (0x1D800, 4, 0x3F00)]),
    case("look view jumps without host +0xa0", view=2, extra=[(0x24CF8, 4, 0x540), (0x24CFC, 4, 0x2000)]),
    case("look view settles back to the cockpit", view=2, extra=[(0x1D804, 4, 0x10), (0x1D800, 4, 0x3FF0)]),
    case("look view easing home stays in view 2", view=2, extra=[(WORLD + 0xA0, 2, 1), (0x1D804, 4, 0x200), (0x1D800, 4, 0x3FE8)]),
    case("chase view: pose ring 7 frames back", view=5),
    case("chase view wraps the pose ring", view=5, extra=[(PLAYER + 0x612, 2, 3)]),
    case("external camera eases toward the player", view=6, extra=[(0x1D838, 4, 99000), (0x1D834, 4, 2800), (0x1D830, 4, -41000),
                                                                   (0x24D00, 4, 0x3F00), (0x24D04, 4, 0x2100)]),
    case("external camera snaps on a large change", view=6, extra=[(0x1D838, 4, 99000), (0x1D834, 4, 2800), (0x1D830, 4, -41000),
                                                                   (0x24D00, 4, 0x2000), (0x24D04, 4, 0x0100)]),
    case("external camera far away (shifted)", view=6, extra=[(0x1D838, 4, 20000), (0x1D834, 4, 9000), (0x1D830, 4, 30000)]),
    case("pitch past the vertical is mirrored", view=5, extra=[(PLAYER + 0x36 + 0x14 * 23 + 0xC, 2, -0x1800)]),
    case("pitch mirrored the other side", view=5, extra=[(PLAYER + 0x36 + 0x14 * 23 + 0xC, 2, -0x2800)]),
    case("stopped: host status 1 already set", ground=True, extra=STOPPED + [(WORLD + 0xD4, 2, 1)]),
    case("stopped and ditched, intact with fuel", ground=True, extra=STOPPED + [(PLAYER + 0x684, 2, 0x1000)]),
    case("stopped and ditched, damaged", ground=True, extra=STOPPED + [(PLAYER + 0x684, 2, 0x1002)]),
    case("ditched near a friendly facility", ground=True, facility=0x12, extra=STOPPED + [(PLAYER + 0x684, 2, 0x1000),
                                                                                         (PLAYER + 0x67D, 1, 0), (PLAYER + 0x67E, 1, 0)]),
    case("ditched near an enemy facility", ground=True, facility=0x13, extra=STOPPED + [(PLAYER + 0x684, 2, 0x1004)]),
    case("stopped with the engine running", ground=True, extra=[(PLAYER + 0x62A, 4, 0)]),
    case("touchdown stop: friendly landing scored", ground=True, facility=0x13, extra=STOPPED + [(0x1B868, 2, 2), (WORLD + 0xCE, 2, 1)]),
    case("touchdown stop: already scored", ground=True, facility=0x13, extra=STOPPED + [(0x1B868, 2, 2), (WORLD + 0xCE, 2, 1),
                                                                                       (0x1B86A, 2, 1)]),
    case("touchdown stop on an enemy runway", ground=True, facility=0x12, extra=STOPPED + [(0x1B868, 2, 2)]),
    case("touchdown stop on a runway elsewhere", ground=True, extra=STOPPED + [(0x1B868, 2, 2)]),
    case("touchdown stop off the runway, damaged", ground=True, extra=STOPPED + [(0x1B868, 2, 2), (PLAYER + 0x2C, 1, 0x10),
                                                                                (PLAYER + 0x684, 2, 0x0020)]),
    case("touchdown stop off the runway near the enemy, empty", ground=True, facility=0x12,
         extra=STOPPED + [(0x1B868, 2, 2), (PLAYER + 0x2C, 1, 0x10), (PLAYER + 0x67D, 1, 0), (PLAYER + 0x67E, 1, 0)]),
    case("touchdown stop off the runway near the enemy, intact", ground=True, facility=0x12,
         extra=STOPPED + [(0x1B868, 2, 2), (PLAYER + 0x2C, 1, 0x10)]),
    case("touchdown stop off the runway, no kills", ground=True, extra=STOPPED + [(0x1B868, 2, 2), (PLAYER + 0x2C, 1, 0x10)]),
    case("touchdown stop off the runway, kills recorded", ground=True,
         extra=STOPPED + [(0x1B868, 2, 2), (PLAYER + 0x2C, 1, 0x10), (WORLD + 0xC0, 2, 2)]),
    case("on the deck with the engine off: fuel recorded", ground=True, extra=STOPPED + [(PLAYER + 0x2C, 1, 0x60), (PLAYER + 0x684, 2, 0x4000)]),
    case("fuel already recorded", ground=True, extra=STOPPED + [(PLAYER + 0x684, 2, 0x4000), (0x1B73C, 2, 1)]),
    case("stopped on the runway, engine on: nothing", ground=True, extra=STOPPED),
]
for seed_frame in (7, 11, 23, 42):          # the status draws on other RNG states (rng advanced by the frame)
    CASES.append(case(f"ditched, damaged, rng after {seed_frame} draws", ground=True, extra=STOPPED + [(PLAYER + 0x684, 2, 0x1002),
                                                                                                   ("rng", seed_frame, 0)]))


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], c["args"], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": "process_flight_input_and_outcome",
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes, "d0": d0})
        print(f"{c['name']}: {len(changes)} bytes changed, result {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
