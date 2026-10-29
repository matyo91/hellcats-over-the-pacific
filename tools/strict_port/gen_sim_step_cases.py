#!/usr/bin/env python3
"""Generate comparison cases for the per-frame simulation steps by running the ORIGINAL bytes.

Covers clear_pending_entity_slots, apply_controller_velocities, tick_flagged_object_controllers
(the controller ticks it runs log their calls on both sides), dispatch_entity_tick and age_contact_records. Objects and the
heap come from gen_object_list_cases.Setup. test_sim_step.gd replays the cases.

Usage: python3 tools/strict_port/gen_sim_step_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import CTLS, FRAME, MEMORY_SIZE, OBJECTS, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP, Setup  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/sim_step_cases.json")
CLEAR_SLOTS, VELOCITIES, TICK_FLAGGED, ENTITY_TICK, AGE_CONTACTS = 0x5DD8, 0x945C, 0x94B2, 0x4484, 0x1375A
METHODS = {CLEAR_SLOTS: "clear_pending_entity_slots", VELOCITIES: "apply_controller_velocities",
           TICK_FLAGGED: "tick_flagged_object_controllers", ENTITY_TICK: "dispatch_entity_tick",
           AGE_CONTACTS: "age_contact_records"}
TICK = 0x3F400
CALL_LOGS = [[TICK, 0x3F500, 1]]
LIST = 0x1C25C
DEFS = 0x26800


def setup() -> Setup:
    s = Setup()
    for log in CALL_LOGS:
        s.w(log[1] - 4, 4, 0)
        s.w(log[1], 4, 0)
    for addr in list(range(0x1BC64, 0x1BC64 + 28, 4)) + list(range(LIST, LIST + 0x40, 4)) + list(range(0x1BDBC, 0x1BDBC + 0x400, 4)) + list(range(DEFS, DEFS + 0x100, 4)):
        s.w(addr, 4, 0)
    s.w(0x1C1C8, 4, 0)
    s.w(0x1C1CC, 4, 0)
    s.w(0x1B5A0, 4, 0x23000)
    for addr in range(0x23000, 0x23100, 4):
        s.w(addr, 4, 0)
    return s


def controller(s: Setup, k: int, obj_flags5: int = 0, obj_flags6: int = 0, tick: bool = False, live_obj: bool = True) -> int:
    obj, ctl, d = OBJECTS + 0x80 * k, CTLS + 0x40 * k, DEFS + 0x20 * k
    s.w(ctl, 4, obj if live_obj else 0)
    s.w(obj + 8, 4, ctl)
    s.w(ctl + 4, 4, d)
    if tick:
        s.w(d + 2, 4, TICK)
    s.w(obj + 5, 1, obj_flags5)
    s.w(obj + 6, 1, obj_flags6)
    for j, v in enumerate((1000 * k + 1, 2000 * k + 2, 3000 * k + 3)):
        s.w(obj + 0x18 + 4 * j, 4, v)
    for j, v in enumerate((10 + k, -(20 + k), 30 + k)):
        s.w(ctl + 8 + 4 * j, 4, v & 0xFFFFFFFF)
    s.w(ctl + 0x2E, 4, 0x777)
    return ctl


def case(name: str, routine: int, args: list[int], s: Setup) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": s.writes()}


def build() -> list[dict]:
    cases = []
    s = setup()
    for k in (0, 3, 6):
        s.w(0x1BC64 + 4 * k, 4, OBJECTS + 0x80 * k)
        s.w(OBJECTS + 0x80 * k, 1, 2)
    s.w(OBJECTS + 0x80 * 3 + 7, 1, 2)
    cases.append(case("clear pending slots 0, 3 (hidden), 6", CLEAR_SLOTS, [], s))
    s = setup()
    ctls = [controller(s, 0, obj_flags6=0x20), controller(s, 1), controller(s, 2, obj_flags6=0x20, live_obj=False), controller(s, 3, obj_flags6=0x24)]
    for k, ctl in enumerate(ctls):
        s.w(LIST + 4 * k, 4, ctl)
    s.w(0x1C1C8, 4, 4)
    cases.append(case("velocities: moved, unflagged, no object, moved", VELOCITIES, [], s))
    s = setup()
    ctls = [controller(s, 0, 4, tick=True), controller(s, 1, live_obj=False), controller(s, 2, 4), controller(s, 3, 4, tick=True),
            controller(s, 4, 0, tick=True)]
    for k, ctl in enumerate(ctls):
        s.w(LIST + 4 * k, 4, ctl)
    s.w(0x1C1CC, 4, 5)
    cases.append(case("tick flagged: one dropped, two ticked, compacted", TICK_FLAGGED, [], s))
    s = setup()
    ctls = [controller(s, 0, 4, tick=True), controller(s, 1, live_obj=False), controller(s, 2, 4, tick=True)]
    for k, ctl in enumerate(ctls):
        s.w(LIST + 4 * k, 4, ctl)
    s.w(LIST + 12, 4, controller(s, 5, 4))
    s.w(0x1C1CC, 4, 0x10003)
    cases.append(case("tick flagged: count long above its loop word (copy of 0)", TICK_FLAGGED, [], s))
    s = setup()
    ctls = [controller(s, 0, 4, tick=True), controller(s, 1, 4)]
    for k, ctl in enumerate(ctls):
        s.w(LIST + 4 * k, 4, ctl)
    s.w(0x1C1CC, 4, 2)
    cases.append(case("tick flagged: nothing dropped", TICK_FLAGGED, [], s))
    for name, b0, type_word in [("type 5 hidden (host +0xb0 = 0)", 0, 5), ("type 5 shown", 1, 5), ("type 2 unchanged", 0, 2)]:
        s = setup()
        controller(s, 0)
        s.w(DEFS, 2, type_word)
        s.w(OBJECTS + 4, 4, 0x41 if b0 else 0x1)
        s.w(0x23000 + 0xB0, 2, b0)
        cases.append(case(f"entity tick: {name}", ENTITY_TICK, [OBJECTS, 0], s))
    s = setup()
    recs = []
    for k, age in enumerate((0, 3, 0)):
        rec = s.alloc(32)
        s.w(rec, 4, OBJECTS + 0x80 * k)
        s.w(rec + 4, 4, OBJECTS + 0x80 * (k + 4))
        s.w(rec + 8, 2, age)
        s.w(0x1BDBC + 4 * (17 * k + 5), 4, rec)
        recs.append(rec)
    s.w(OBJECTS + 0x80 * 6 + 6, 1, 2)
    s.w(OBJECTS + 0x80 * 2 + 6, 1, 0x20)
    cases.append(case("age contacts: two freed, one aged", AGE_CONTACTS, [], s))
    return cases


CASES = build()


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
    before = bytes(emu.mem)
    emu.call(c["routine"], c["args"], STACK_TOP)
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "stubs": {},
           "call_logs": CALL_LOGS, "cases": []}
    for c in CASES:
        changes = run_case(c)
        zero, writes = compact(c["writes"])
        out["cases"].append({"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]],
                             "args": c["args"], "zero": zero, "writes": writes, "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
