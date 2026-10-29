#!/usr/bin/env python3
"""Generate comparison cases for resolve_bailout_outcome, update_bailout_view and
begin_replay_view by running the ORIGINAL bytes. The parachute and the player each get a
controller with a pose ring; facilities near the player are object_pool entries. Returned D0 is
compared where it matters. test_views.gd replays the cases.

Usage: python3 tools/strict_port/gen_view_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/view_cases.json")
RESOLVE, BAILOUT, REPLAY = 0x877E, 0x8952, 0x8FD4          # runtime addresses (file - 0x20)
METHODS = {RESOLVE: "resolve_bailout_outcome", BAILOUT: "update_bailout_view", REPLAY: "begin_replay_view"}
WORLD = 0x23000
PCTL, POBJ, PREC = 0x24000, 0x24800, 0x24900          # player controller (pose ring at +0x36), object, type record
CCTL, COBJ = 0x25000, 0x25800                         # parachute controller (pose ring at +0x32), object
FAC, FAC_CTL, FAC_REC = 0x25900, 0x25A00, 0x25B00
FRAME = 1000


def base() -> list[list[int]]:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(PCTL, PCTL + 0x700, 4)) + list(range(POBJ, POBJ + 0x80, 4))
         + list(range(PREC, PREC + 0x80, 4)) + list(range(CCTL, CCTL + 0x700, 4)) + list(range(COBJ, COBJ + 0x80, 4))
         + list(range(FAC, FAC + 0x80, 4)) + list(range(FAC_CTL, FAC_CTL + 0x40, 4)) + list(range(FAC_REC, FAC_REC + 0x20, 4))]
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (0x1B738, 4, PCTL), (PCTL, 4, POBJ), (PCTL + 4, 4, PREC), (POBJ + 8, 4, PCTL),
        (0x1B87C, 4, CCTL), (CCTL, 4, COBJ), (COBJ + 8, 4, CCTL), (0x1B838, 4, FRAME), (0x1B87A, 2, 0),
        (0x1B734, 4, 0), (0x1C1E0, 4, 0), (0x1D858, 2, 1), (0x1B870, 2, 0), (0x1B86C, 2, 1), (0x1B884, 4, 0), (0x1B888, 4, 0),
        (POBJ + 0x18, 4, 50000), (POBJ + 0x1C, 4, 3000), (POBJ + 0x20, 4, 20000),
        (COBJ + 0x18, 4, 51000), (COBJ + 0x1C, 4, 2000), (COBJ + 0x20, 4, 21000), (COBJ + 0x40, 4, FRAME - 200),
        (0x1D838, 4, 40000), (0x1D834, 4, 4000), (0x1D830, 4, 10000), (0x24D1A, 2, 0x100), (0x24D18, 2, 0x200),
    ]:
        w.append([addr, size, value])
    for i in range(75):
        for ring, base_ in ((PCTL + 0x36, 0), (CCTL + 0x32, 1)):
            e = ring + 0x14 * i
            w += [[e, 4, 50000 + 100 * i + 7 * base_], [e + 4, 4, 3000 - 10 * i], [e + 8, 4, 20000 + 50 * i], [e + 0xE, 2, (0x80 * i) & 0x3FFF]]
    return w


def facility(type_word: int) -> list[tuple[int, int, int]]:
    return [(0x1B734, 4, 1), (0x1B5A4, 4, FAC), (FAC + 8, 4, FAC_CTL), (FAC_CTL + 4, 4, FAC_REC), (FAC_REC, 2, type_word),
            (FAC + 0xC, 4, 100000), (FAC + 0x18, 4, 50000), (FAC + 0x20, 4, 20000)]


def case(name: str, routine: int, extra: list[tuple[int, int, int]] = (), with_d0: bool = True) -> dict:
    return {"name": name, "routine": routine, "args": [], "with_d0": with_d0, "writes": base() + [list(e) for e in extra]}


CASES = []
for kind_name, fac in [("open country", []), ("near an enemy facility", facility(0x12)), ("near a friendly facility", facility(0x13))]:
    for cursor in (0x2600C, 0x26020, 0x26034, 0x26048, 0x2605C):
        CASES.append(case(f"outcome {kind_name}, rng cursor {cursor:#x}", RESOLVE, fac + [(0x26008, 4, cursor)]))
CASES += [
    case("outcome: hard landing (low, fast)", RESOLVE, [(COBJ + 0x1C, 4, 0x300), (CCTL + 0x614, 2, 0x600)]),
    case("outcome: verdict already set, abandoned intact aircraft", RESOLVE, [(WORLD + 0xD4, 2, 2), (0x1B87A, 2, 1)]),
    case("outcome: no verdict, abandoned intact aircraft (4)", RESOLVE, [(0x1B87A, 2, 1), (0x26008, 4, 0x26020)]),
    case("bailout view: high chute, behind it toward the aircraft", BAILOUT, [(CCTL + 0x2E, 4, 0)]),
    case("bailout view: recent chute, aircraft too far: pose ring", BAILOUT, [(COBJ + 0x40, 4, FRAME - 10), (POBJ + 0x18, 4, 500000), (CCTL + 0x60E, 2, 74)]),
    case("bailout view: low old chute: pose ring", BAILOUT, [(CCTL + 0x2E, 4, 1900), (CCTL + 0x60E, 2, 5)]),
    case("bailout view: landed fast chute resolves", BAILOUT, [(CCTL + 0x61E, 2, 1), (CCTL + 0x614, 2, 0x601)]),
    case("bailout view: no parachute resolves", BAILOUT, [(0x1B87C, 4, 0)]),
    case("replay view: airborne side, contact-tracked player", REPLAY, [(PCTL + 0x612, 2, 10), (POBJ + 4, 4, 0x40)], False),
    case("replay view: ground side, index 0 wraps, floor raised", REPLAY, [(PCTL + 0x612, 2, 0), (0x1B86C, 2, 2), (PCTL + 0x2E, 4, 3500),
                                                                          (0x1B884, 4, FAC_CTL), (FAC_CTL, 4, FAC)], False),
]


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(c["routine"], c["args"], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {}, "cases": []}
    for c in CASES:
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        entry = {"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if c["with_d0"]:
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
