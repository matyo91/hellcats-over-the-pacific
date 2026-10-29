#!/usr/bin/env python3
"""Generate comparison cases for render_visible_objects by running the ORIGINAL bytes.

Copies of the transform fixture's object (gen_transform_object_cases.setup: eight vertices, five
faces) fill the visible list: pre-transformed ones (pass 1), plain ones, one with a parent
(deferred to pass 3, drawn with its parent's draw order), one asking for its parts to be sorted
(byte +6 bit 1: sort_group_parts_by_distance runs as ported) and an unlinked one (skipped). View
1 allows near mode (objects within their range) and draws mission_child4 last. The face output
pointer is a logging stub returning 1; everything else runs as ported. test_render_objects.gd
replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_render_objects_cases.py  (writes the fixture JSON)
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
from gen_transform_object_cases import CALL_LOGS as HOOK_LOGS, CTL, FACES, OBJ, setup  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/render_objects_cases.json")
ROUTINE = 0xAC52                                   # runtime address (file 0xac72)
OUTPUT = 0x30100
COPIES, PARENT, CTL_DEAD = 0x28000, 0x28F00, 0x28F80
CALL_LOGS = HOOK_LOGS + [[OUTPUT, 0x38204, 1]]
STACK = (STACK_TOP - 0x1000, STACK_TOP + 0x40)


def case(name: str, objects: list[dict], split: int, view: int = 0, first_pass: int = 0, flag_d856: int = 0) -> dict:
    w = setup(oriented=False, haze=0)
    w += [[a, 4, 0] for a in list(range(COPIES, COPIES + 0x1000, 4)) + list(range(0x25D2C, 0x25D30 + 0x80, 4))
          + list(range(0x25B28, 0x25B2C + 0x40, 4)) + list(range(0x38200, 0x38600, 4)) + list(range(0x1C9DC, 0x1C9DC + 0x40, 4))]
    base = {k: v for k, v in [(a, (s, v)) for a, s, v in w if OBJ <= a < OBJ + 0x80]}
    vals = [(0x20AB4, 4, OUTPUT), (0x38200, 4, 1), (0x1D858, 2, view), (0x1D856, 2, flag_d856), (0x1BDB8, 4, split),
            (0x1C1D4, 4, len(objects)), (0x1C1C0, 2, first_pass), (0x1BDA4, 4, OBJ), (PARENT + 2, 2, 0x55),
            (CTL_DEAD, 4, 0), (CTL_DEAD + 4, 4, CTL + 0x100)]
    for f in range(5):
        rec = FACES + 32 * f
        vals += [(rec + 0x10, 1, -1), (rec + 0x11, 1, -1), (rec + 0x12, 1, f + 1 if f < 4 else -1), (rec + 0x1C, 4, 0x7FFF)]
    for i, o in enumerate(objects):
        addr = COPIES + 0x100 * i
        for a, (s, v) in base.items():
            vals.append((addr + (a - OBJ), s, v))
        vals += [(addr + 6, 1, o.get("b6", 0)), (addr + 7, 1, o.get("b7", 0)), (addr + 0x2C, 4, PARENT if o.get("child") else 0),
                 (addr + 0x10, 4, o.get("dist", 0x5000)), (addr + 0x14, 4, o.get("range", 0x1000)),
                 (addr + 8, 4, CTL_DEAD if o.get("dead") else CTL)]
        vals.append((0x1C9DC + 4 * i, 4, addr))
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return {"name": name, "writes": w}


PLAIN, BSP, NEAR = {}, {"b7": 0x20}, {"dist": 0x800, "range": 0x9000}
CASES = [
    case("one pre-transformed, two plain", [PLAIN, PLAIN, BSP], split=1),
    case("view 1: near objects, cockpit object last", [NEAR, dict(NEAR, b7=0x20), PLAIN], split=0, view=1, first_pass=5),
    case("deferred child drawn with its parent's order", [PLAIN, {"child": True}, BSP], split=0),
    case("parts sorted, then faces unnumbered", [{"b6": 2}, PLAIN], split=0),
    case("unlinked controller skipped, sort request carried to the next", [{"b6": 2, "dead": True}, PLAIN], split=0),
    case("view 1 with view_flag_d856: no near mode", [NEAR, NEAR], split=0, view=1, first_pass=5, flag_d856=1),
    case("near threshold below the count", [NEAR, NEAR, NEAR], split=0, view=1, first_pass=1),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    emu.call(ROUTINE, [], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK[0] <= a < STACK[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": ROUTINE, "method": "render_visible_objects", "args": [],
                             "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
