#!/usr/bin/env python3
"""Generate comparison cases for the cockpit instrument routines by running the ORIGINAL bytes:
draw_gauge_needle and the needle / lamp / bar updaters (altimeter, airspeed, direction, climb,
tachometer, manifold, bomb lamp, throttle bar, flaps, gear, ammo, fuel). The line, lamp and
rectangle routines they reach through code pointers (host +0x272 / +0x29e / +0x28e and
depth_routine_da98 / _da9c) are logging stubs on both sides; the throttle rectangle is logged by
value. Each updater runs with the readouts drawn and undrawn, with a cached value that matches
and one that does not, and with the host line routine. test_gauges.gd replays the cases
(helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_gauge_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/gauge_cases.json")
ROUTINES = {                                      # runtime addresses (file - 0x20)
    0xC552: "draw_gauge_needle", 0xC644: "update_altimeter_needles", 0xC7EC: "update_airspeed_needle",
    0xC8B6: "update_direction_needle", 0xC928: "update_climb_needle", 0xC9A2: "update_tachometer_needle",
    0xCA24: "update_manifold_needle", 0xCAA6: "update_bomb_indicator", 0xCB42: "update_throttle_gauge",
    0xCBF2: "update_flaps_needle", 0xCCAA: "update_gear_needles", 0xCDFC: "update_ammo_needle",
    0xCEA4: "update_fuel_needles"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, PLAYER, PLAYER_OBJ, PLAYER_DEF = 0x27000, 0x27400, 0x27C00, 0x27D00
HOST_LINE, RESTORE, DRAW, LAMP, RECT = 0x30000, 0x30100, 0x30200, 0x30300, 0x30400
CALL_LOGS = [[HOST_LINE, 0x38004, 5], [RESTORE, 0x38404, 8], [DRAW, 0x38C04, 7], [LAMP, 0x39404, 3], [RECT, 0x39804, 2, 0, 2]]
DIALS = [0xF0, 0x100, 0x120, 0x130, 0x140, 0x150, 0x20E, 0x214, 0x21A, 0x220, 0x226, 0x22C, 0x232]


def base(drawn: int, host_line: int) -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(PLAYER, PLAYER + 0x700, 4))
         + list(range(0x38000, 0x39C00, 4)) + list(range(0x25F4A, 0x26000, 4))]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in [
        (0x1B5A0, 4, WORLD), (0x1B738, 4, PLAYER), (PLAYER, 4, PLAYER_OBJ), (PLAYER + 4, 4, PLAYER_DEF),
        (WORLD + 0x9E, 2, host_line), (WORLD + 0x272, 4, HOST_LINE), (WORLD + 0x29E, 4, LAMP), (WORLD + 0x28E, 4, RECT),
        (0x1DA98, 4, RESTORE), (0x1DA9C, 4, DRAW), (0x25FFC, 2, drawn),
        (WORLD + 0xE4, 2, -3), (WORLD + 6, 4, 0x12345678), (WORLD + 0x10, 2, 0x140), (WORLD + 0xDC, 4, 0x50000),
        (0x1BD7C, 4, 0x1000), (WORLD + 0xE0, 2, 0x7F),
        (WORLD + 0x1FC, 2, 0x11), (WORLD + 0x200, 2, 0x22), (WORLD + 0x202, 4, 0x00500060), (WORLD + 0x206, 4, 0x00A00070),
        (WORLD + 0x20A, 2, 5), (WORLD + 0x20C, 2, 9), (PLAYER_DEF + 0x1C, 2, 0x3D)]]
    for k, off in enumerate(DIALS):
        w += [[WORLD + off, 2, 40 + 30 * k], [WORLD + off + 2, 2, 300 - 7 * k], [WORLD + off + 4, 2, 18 + 3 * k]]
    return w


def case(name: str, routine: str, args: list[int] = (), drawn: int = 0, host_line: int = 0,
         extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": BY_NAME[routine], "args": list(args),
            "writes": base(drawn, host_line) + [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in extra]}


def variants(routine: str, label: str, state: list[tuple[int, int, int]], cache_same: list[tuple[int, int, int]]) -> list[dict]:
    """Undrawn, drawn with a different cache, drawn with the same cache, and the host line routine."""
    return [case(f"{label}: readouts undrawn", routine, extra=state),
            case(f"{label}: drawn, value changed", routine, drawn=1, extra=state + [(a, n, v ^ 1) for a, n, v in cache_same]),
            case(f"{label}: drawn, value unchanged", routine, drawn=1, extra=state + cache_same),
            case(f"{label}: host line routine", routine, host_line=1, extra=state)]


def build() -> list[dict]:
    out = [
        case("needle: host line routine", "draw_gauge_needle", [2, 100, 200, 110, 190], host_line=1),
        case("needle: undrawn", "draw_gauge_needle", [7, 100, 200, 90, 215]),
        case("needle: drawn, moved (old line restored)", "draw_gauge_needle", [7, 100, 200, 90, 215], drawn=1,
             extra=[(0x25F4A + 28, 4, 91), (0x25F92 + 28, 4, 215)]),
        case("needle: drawn, unchanged", "draw_gauge_needle", [7, 100, 200, 90, 215], drawn=1,
             extra=[(0x25F4A + 28, 4, 90), (0x25F92 + 28, 4, 215)]),
    ]
    for y in (3456, 0, 123456, 99999, -2500):
        out.append(case(f"altimeter y {y}: undrawn", "update_altimeter_needles", extra=[(0x1D834, 4, y)]))
    out.append(case("altimeter: drawn, long hand unchanged", "update_altimeter_needles", drawn=1,
                    extra=[(0x1D834, 4, 0)] + [(0x25F4A, 4, 39 + 0), (0x25F92, 4, 299 - 18)]))
    out.append(case("altimeter: drawn, both hands move", "update_altimeter_needles", drawn=1,
                    extra=[(0x1D834, 4, 45678), (0x25FDA, 4, 50), (0x25FDE, 4, 260)]))
    out.append(case("altimeter: host line routine", "update_altimeter_needles", host_line=1, extra=[(0x1D834, 4, 7777)]))
    for v in (0, 0x500, 0xB40, 0xB41, 0x10E0, 0x10E1, 0x2000, 0x3843, 0x3844, 0x5000, -100):
        out.append(case(f"airspeed {v:#x}", "update_airspeed_needle", extra=[(PLAYER + 0x62A, 4, v)]))
    for h in (0, 0x1234, 0xF000, 0x8000):
        out.append(case(f"direction {h:#x}", "update_direction_needle", extra=[(0x1D80E, 2, h)]))
    for c in (0, 1000, -3000, 123456):
        out.append(case(f"climb {c}", "update_climb_needle", extra=[(0x1BC80, 4, c)]))
    for r in (0, 900, 2700, -50):
        out.append(case(f"tachometer {r}", "update_tachometer_needle", extra=[(PLAYER + 0x66A, 4, r)]))
    for m in (0, 30, 95, -10):
        out.append(case(f"manifold {m}", "update_manifold_needle", extra=[(PLAYER + 0x672, 2, m)]))
    for bombs, y in [(0, 1000), (1, 1000), (2, 10), (-1, 0x44)]:
        out += variants("update_bomb_indicator", f"bombs {bombs}, height {y}",
                        [(PLAYER + 0x67C, 1, bombs), (PLAYER_OBJ + 0x1C, 4, y), (PLAYER + 0x2E, 4, 0)],
                        [(0x25FE2, 2, bombs), (0x25FE4, 2, 1 if y > 0x43 else 0)])
    for t in (0, 4, 9):
        out += variants("update_throttle_gauge", f"throttle {t}", [(PLAYER + 0x668, 1, t)], [(0x25FE6, 2, t)])
    for f in (0, 15, -7):
        out += variants("update_flaps_needle", f"flaps {f}", [(PLAYER + 0x67B, 1, f)], [(0x25FE8, 2, f)])
    for g in (0, 0x2D, 20, -9):
        out += variants("update_gear_needles", f"gear {g}", [(PLAYER + 0x679, 1, g)], [(0x25FEA, 2, g)])
    for a in (0, 0x2A3, 100, -40):
        out += variants("update_ammo_needle", f"ammo {a}", [(PLAYER + 0x682, 2, a)], [(0x25FEC, 2, a)])
    for left, right, cap in [(0, 0, 0x3D), (30, 12, 0x3D), (-5, 60, -9), (100, 1, 4)]:
        out += variants("update_fuel_needles", f"fuel {left} / {right} of {cap}",
                        [(PLAYER + 0x67D, 1, left), (PLAYER + 0x67E, 1, right), (PLAYER_DEF + 0x1C, 2, cap)],
                        [(0x25FEE, 2, left), (0x25FF0, 2, right)])
    out.append(case("fuel: right tank changed only", "update_fuel_needles", drawn=1,
                    extra=[(PLAYER + 0x67D, 1, 30), (PLAYER + 0x67E, 1, 12), (0x25FEE, 2, 30), (0x25FF0, 2, 11)]))
    return out


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for entry in CALL_LOGS:
        address, log_base, nargs = entry[:3]
        di, dn = (entry[3], entry[4]) if len(entry) > 3 else (-1, 0)
        emu.stubs[address] = lambda e, b=log_base, n=nargs, i=di, k=dn: log_call(e, b, n, i, k)
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
        if ROUTINES[c["routine"]] == "draw_gauge_needle":
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
