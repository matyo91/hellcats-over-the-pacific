#!/usr/bin/env python3
"""Generate comparison cases for the ID03 gauges (fuel, landing gear, flaps, ammunition, climb,
tachometer, manifold pressure, altimeter, airspeed,
direction, percent scale) the panel section with numbered boxes draw_instrument, the artificial horizon, the gyro and the turn and bank indicator by running the ORIGINAL bytes.

The set-up is gen_id03_supersample_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID02.bin behind
its slots, every trap and other slot a logging stand-in; the ring, the supersample, the arc ticks,
the text style and the finishing all run for real on both sides) with the text traps added
(GetFontInfo writes a fixed ascent, StringWidth answers a fixed width) and the gear strokes and
labels seeded. Each case records the original's entry stack pointer ("a7"): the gauges pass
pointers into their own argument slots. test_id03_gauges.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_gauges_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_helpers_cases as helpers  # noqa: E402
import gen_id03_supersample_cases as supersample  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_gauges_cases.json")
A5, LOGS, DATA = helpers.A5, helpers.LOGS, helpers.DATA
N_BEFORE = len(supersample.STUBS)
STUBS = supersample.STUBS + [["trap", 0xA887, [2], True, 0], ["trap", 0xA88B, [4], True, 0, {0: ["out", (11 << 16) | 3]}],
                             ["trap", 0xA88C, [4], True, 2], ["trap", 0xA884, [4], True, 0],
                             ["trap", 0xA8A7, [2, 2, 2, 2, 4], True, 0], ["addr", 0x3A200, [4, 4, 4, 4, 4, 4], False, 0],
                             ["trap", 0xA8E6, [4, 4, 4], True, 0], ["jt", 0x402, [2, 4, 4, 4], False, 0],
                             ["jt", 0x392, [4], False, 0], ["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0],
                             ["trap", 0xA8E8, [4, 4], True, 2, {}, [0x100, 0x100, 0, 0x100, 0, 0x100, 0x100, 0x100, 0, 0x100, 0]],
                             ["jt", 0x26A, [4, 4], True, 0]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
ROUTINES = {"draw_fuel_gauge": 0x532E, "draw_landing_gear_indicator": 0x54FE, "draw_flaps_indicator": 0x4C42,
            "draw_ammo_counter": 0x4ECC, "draw_climb_indicator": 0x1FEE, "draw_tachometer": 0x22FE,
            "draw_manifold_pressure_gauge": 0x2600, "draw_altimeter": 0x1876,
            "draw_airspeed_indicator": 0x1B48, "draw_direction_indicator": 0x2950,
            "draw_percent_scale_gauge": 0x4790, "draw_panel_section_with_numbered_boxes": 0x4304,
            "draw_instrument": 0x3C02, "draw_artificial_horizon": 0x38FC,
            "draw_gyro_instrument": 0x32B8, "draw_turn_and_bank_indicator": 0x2D1C}
W, case = helpers.W, helpers.case
GEAR = [0x62, -20, -10, 20, -10, 20, 15, 0x62, 0, 15, 0, 30, -5, 35, 0x63]


def common() -> list[list[int]]:
    w = [x for x in supersample.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_BEFORE)]
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]
    vals = [(CALL_LOGS[N_BEFORE + 2][2] - 4, 4, 57), (A5 - 0xE12, 4, 0x11F00), (A5 - 0xE0E, 4, 0x11F20), (A5 - 0xE1A, 4, 0x11F40), (A5 - 0xE16, 4, 0x11F60), (A5 - 0xE36, 4, 0x11F80), (A5 - 0xE32, 4, 0x11FA0), (A5 - 0xE2E, 4, 0x11FC0), (A5 - 0xE2A, 4, 0x11FE0), (A5 - 0xE42, 4, 0x11E40), (A5 - 0xE3E, 4, 0x11E60), (A5 - 0xE3A, 4, 0x11E80), (A5 - 0xE26, 4, 0x11EA0), (A5 - 0x1EE6, 2, 0x4E00), (A5 - 0x1EE4, 2, 0x4500),
            (A5 - 0x1EE2, 2, 0x5300), (A5 - 0x1EE0, 2, 0x5700), (0x11D10, 4, 0x13400), (0x11D30, 4, 0x13480), (0x11D20, 4, 0x134C0), (A5 - 0x105E, 4, 0x3A200), (A5 - 0xE22, 4, 0x11EC0), (A5 - 0xE1E, 4, 0x11EE0), (A5 - 0x2114, 2, 300),
            (A5 - 0x149E, 4, 160)]  # a quarter of the helpers' scale: the faces are downsampled pixel by pixel
    vals += [(A5 - 0x1F80 + 2 * k, 2, v) for k, v in enumerate(GEAR)]
    vals += [(A5 - 0x1FA0 + k, 1, v) for k, v in enumerate([0xF6, 0, 0x0A, 0, 0, 0xFC])]
    vals += [(A5 - 0x1F9A + k, 1, (7 * k + 3) % 40 - 20) for k in range(20)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def build() -> list[dict]:
    out = []
    for label, mode, args in (("1-bit", 1, (700, 900, 12, 25, -100, 300)), ("8-bit", 8, (700, 900, 12, 25, -100, 300)),
                              ("4-bit, odd", 4, (461, 777, 9, 41, 50, -20))):
        out.append(case(f"percent scale, {label}", "draw_percent_scale_gauge", [W(v) for v in args], list(args),
                        [[A5 - 0x137A, 2, mode]]))
    for mode in (1, 4, 8):
        out.append(case(f"panel section, depth {mode}", "draw_panel_section_with_numbered_boxes", [], [], [[A5 - 0x137A, 2, mode]]))
    for spans in (0, 1):
        for mode in (1, 8):
            out.append(case(f"horizon, spans {spans}, depth {mode}", "draw_artificial_horizon",
                            [W(900), W(3), W(25), W(-100), W(250), W(spans)], [900, 3, 25, -100, 250, spans], [[A5 - 0x137A, 2, mode]]))
    for card in (0, 1):
        for mode in (1, 8):
            out.append(case(f"gyro, card {card}, depth {mode}", "draw_gyro_instrument",
                            [W(900), W(3), W(25), W(-100), W(250), W(card)], [900, 3, 25, -100, 250, card], [[A5 - 0x137A, 2, mode]]))
    for kind in range(-1, 11):
        out.append(case(f"instrument kind {kind}", "draw_instrument", [W(kind), W(700), W(3), W(25), W(-100), W(250)],
                        [kind, 700, 3, 25, -100, 250], [[A5 - 0x137A, 2, 8]]))
    for method in [m for m in ROUTINES if m not in ("draw_percent_scale_gauge", "draw_panel_section_with_numbered_boxes",
                                                    "draw_instrument", "draw_artificial_horizon",
                                                    "draw_gyro_instrument")]:
        for label, mode, args in (("1-bit", 1, (900, 3, 25, -200, 400)), ("8-bit", 8, (900, 3, 25, -200, 400)),
                                  ("4-bit, small", 4, (480, 2, 40, 100, -300))):
            out.append(case(f"{method}, {label}", method, [W(v) for v in args], list(args), [[A5 - 0x137A, 2, mode]]))
    return out


def main() -> None:
    base = common()
    helpers.STUBS, helpers.CALL_LOGS, helpers.ROUTINES = STUBS, CALL_LOGS, ROUTINES
    logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in CALL_LOGS]
    out = {"memory_size": helpers.MEMORY_SIZE, "a5": A5, "stack_top": helpers.STACK_TOP, "stack_guard": list(helpers.STACK_GUARD),
           "common_writes": base, "call_logs": logs, "cases": []}
    for c in build():
        changes, _ = helpers.run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                             "a7": helpers.STACK_TOP - sum(size for size, _ in c["stack"]) - 4})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
