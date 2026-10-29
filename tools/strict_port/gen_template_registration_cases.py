#!/usr/bin/env python3
"""Generate comparison cases for the template registration hooks by running the ORIGINAL bytes.

Each definition record's first create hook (+6) stores the template object and redirects +6 to
the controller factory; the slot variants (effect, trail, shadow, cloud) fill the first empty
slot and redirect past a threshold. Same method as gen_controller_misc_cases.py, with the
returned D0 (always 0) recorded. test_template_registration.gd replays the cases.

Usage: python3 tools/strict_port/gen_template_registration_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_ordnance_cases import MEMORY_SIZE, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/template_registration_cases.json")
KEY = 0x0C                      # the definition key used by every case
DEFINITION = 0x24000            # its record (0x1e bytes), +6 starts as 0x12345678
TEMPLATE = 0x24800
SINGLES = {  # runtime address -> (name, template global)
    0x115BA: ("smoke", 0x260E8), 0x127FE: ("ordnance", 0x26280), 0x15BB4: ("bullet", 0x2664A),
    0x17078: ("ground fire", 0x26658), 0x173BC: ("debris", 0x2665C), 0x1757E: ("ground mark", 0x26660),
    0x190EE: ("turret", 0x2677C), 0x193EE: ("parachute", 0x26780),
}
SLOTS = {  # runtime address -> (name, table, slot count)
    0x11B28: ("effect", 0x2626E, 4), 0x16A58: ("trail", 0x26650, 2), 0x188D4: ("shadow", 0x2676C, 4),
    0x19A34: ("cloud", 0x26784, 5),
}


def base() -> list[list[int]]:
    w = [[addr, 4, 0] for addr in range(DEFINITION, DEFINITION + 0x20, 4)]
    w += [[0x1B524 + 4 * KEY, 4, DEFINITION], [DEFINITION + 6, 4, 0x12345678]]
    for _name, glob in SINGLES.values():
        w.append([glob, 4, 0])
    for _name, table, count in SLOTS.values():
        for i in range(count + 1):
            w.append([table + 4 * i, 4, 0])
    return w


def case(name: str, routine: int, extra: list[tuple[int, int, int]] = ()) -> dict:
    return {"name": name, "routine": routine, "args": [TEMPLATE, KEY, 0], "writes": base() + [list(e) for e in extra]}


CASES = [case(f"register {name} template", routine) for routine, (name, _glob) in SINGLES.items()]
for routine, (name, table, count) in SLOTS.items():
    for filled in range(count + 1):
        CASES.append(case(f"register {name} template with {filled} of {count} slots taken", routine,
                          [(table + 4 * i, 4, 0x25000 + i) for i in range(filled)]))
CASES.append(case("register effect template: a gap before the last slot", 0x11B28,
                  [(0x2626E, 4, 0x25000), (0x26276, 4, 0x25002), (0x2627A, 4, 0x25003)]))


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
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "cases": []}
    for c in CASES:
        changes, d0 = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "args": c["args"], "zero": zero,
                             "writes": writes, "changes": changes, "d0": d0})
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
