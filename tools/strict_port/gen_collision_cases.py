#!/usr/bin/env python3
"""Generate comparison cases for the broad-phase collision tests by running the ORIGINAL bytes.

Covers test_proximity_collision, test_player_vs_type0e_proximity, create_shape_contact_record,
handle_player_contact, point_in_face_by_axis and test_object_collision. Objects, faces and the
heap are built in the interpreter (gen_object_list_cases.Setup); a contact record that should
already exist is made by the original create_shape_contact_record during setup. The collision
handler (definition +0x12) logs its calls on both sides; the terrain paths (handle_terrain_contact,
test_terrain_collision) have their own cases in gen_terrain_cases.py. test_collision.gd replays them.

Usage: python3 tools/strict_port/gen_collision_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from gen_ai_state_cases import compact  # noqa: E402
from gen_object_list_cases import CTLS, MEMORY_SIZE, OBJECTS, OVERLAY_RNG_INIT, STACK_GUARD, STACK_TOP, Setup  # noqa: E402
from gen_radar_cases import log_call  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/collision_cases.json")
PROXIMITY, PLAYER_PROX, CREATE_REC, PLAYER_CONTACT, POINT_IN_FACE, OBJECT_COLLISION = (
    0x13E2E, 0x13E8E, 0x135C8, 0x1427C, 0x1344C, 0x13EC0)
METHODS = {PROXIMITY: "test_proximity_collision", PLAYER_PROX: "test_player_vs_type0e_proximity",
           CREATE_REC: "create_shape_contact_record", PLAYER_CONTACT: "handle_player_contact",
           POINT_IN_FACE: "point_in_face_by_axis", OBJECT_COLLISION: "test_object_collision"}
HANDLER = 0x3F400
CALL_LOGS = [[HANDLER, 0x3F500, 3]]
DEFS = 0x26800                    # definition records: +0 type word, +0x12 collision handler
A, B = OBJECTS, OBJECTS + 0x80


def setup() -> Setup:
    s = Setup()
    for log in CALL_LOGS:
        s.w(log[1] - 4, 4, 0)
        s.w(log[1], 4, 0)
    for addr in range(0x1BDBC, 0x1BDBC + 0x400, 4):
        s.w(addr, 4, 0)
    for addr in range(DEFS, DEFS + 0x100, 4):
        s.w(addr, 4, 0)
    s.w(0x1D858, 2, 1)
    s.w(0x1B738, 4, 0)
    return s


def obj(s: Setup, base: int, ctl: int, type_word: int, handler: bool, **fields: int) -> None:
    """An object with a controller whose definition has type `type_word` (and the logged handler)."""
    d = DEFS + 0x20 * (ctl - CTLS) // 0x40
    s.w(base + 8, 4, ctl)
    s.w(ctl, 4, base)
    s.w(ctl + 4, 4, d)
    s.w(d, 2, type_word)
    if handler:
        s.w(d + 0x12, 4, HANDLER)
    for name, value in fields.items():
        off, size = FIELD[name]
        s.w(base + off, size, value)


FIELD = {"x": (0x18, 4), "y": (0x1C, 4), "z": (0x20, 4), "radius": (0x14, 4), "metric": (0x10, 4),
         "flags": (4, 4), "b5": (5, 1), "b6": (6, 1), "shift": (0x34, 2), "kind": (0, 1)}


def plate(s: Setup, base: int, faces: int = 1) -> None:
    """Shape b: a 2000-square plate in y = 0 (4 vertices), `faces` faces over it, each with a normal
    entry vertex 0 + (0, 100, 0); face +0x1c extent 100 (selected when the metric is 0)."""
    verts = s.alloc(12 * (4 + faces))
    for i, (x, y, z) in enumerate([(-1000, 0, -1000), (1000, 0, -1000), (1000, 0, 1000), (-1000, 0, 1000)]):
        for j, v in enumerate((x, y, z)):
            s.w(verts + 12 * i + 4 * j, 4, v)
    for f in range(faces):
        for j, v in enumerate((-1000, 100 + 50 * f, -1000)):
            s.w(verts + 12 * (4 + f) + 4 * j, 4, v)
    table = s.alloc(0x20 * faces)
    for f in range(faces):
        idx = s.alloc(8)
        for k in range(4):
            s.w(idx + 2 * k, 2, k)
        s.w(table + 0x20 * f + 0x14, 2, 4)
        s.w(table + 0x20 * f + 0x18, 4, idx)
        s.w(table + 0x20 * f + 0x1C, 4, 100 if f != 1 else 0xFFFFFF00)
    s.w(base + 0x44, 4, verts)
    s.w(base + 0x48, 4, table)
    s.w(base + 0x36, 2, 4)
    s.w(base + 0x3A, 2, faces)


def existing_record(s: Setup, sides: int) -> int:
    rec = s.emu.call(CREATE_REC, [A, B], STACK_TOP) & 0xFFFFFFFF
    count = s.emu.read(rec + 0xA, 2)
    for k in range(count):
        s.w(rec + 0x10 + 2 * count + 2 * k, 2, sides)
    return rec


def case(name: str, routine: int, args: list[int], s: Setup, with_d0: bool = False) -> dict:
    return {"name": name, "routine": routine, "args": args, "writes": s.writes(), "with_d0": with_d0}


def build_cases() -> list[dict]:
    cases = []
    for name, fa, fb, ax in [("both flagged and close: dispatch", 0x100000, 0x100000, 500),
                             ("both flagged, far apart", 0x100000, 0x100000, 9000),
                             ("only one flagged", 0x100000, 0, 500)]:
        s = setup()
        obj(s, A, CTLS, 2, False, x=ax, radius=600, flags=fa)
        obj(s, B, CTLS + 0x40, 0x17, True, radius=100, flags=fb)
        cases.append(case(f"proximity: {name}", PROXIMITY, [A, B], s))
    for name, player, type_b in [("player against type 0xe", True, 0xE), ("player against type 2", True, 2),
                                 ("not the player", False, 0xE)]:
        s = setup()
        obj(s, A, CTLS, 1, False, x=300, radius=600, flags=0x100000)
        obj(s, B, CTLS + 0x40, type_b, True, radius=100, flags=0x100000)
        if player:
            s.w(0x1B738, 4, CTLS)
        cases.append(case(f"player vs 0xe: {name}", PLAYER_PROX, [A, B], s))
    s = setup()
    obj(s, A, CTLS, 1, False, radius=300)
    obj(s, B, CTLS + 0x40, 0x17, False, radius=900, shift=1)
    plate(s, B, 3)
    cases.append(case("create contact record: 3 faces (one too small), shift 1", CREATE_REC, [A, B], s, True))
    for name, extra in [("new record, hook", {}), ("too far", {"x": 90000})]:
        s = setup()
        obj(s, A, CTLS, 1, False, radius=300, **{k: v for k, v in extra.items() if k == "x"})
        obj(s, B, CTLS + 0x40, 0x17, True, radius=900, b6=extra.get("b6", 0x40))
        plate(s, B)
        s.w(0x1B738, 4, CTLS)
        cases.append(case(f"player contact: {name}", PLAYER_CONTACT, [A, B], s))
    s = setup()
    obj(s, A, CTLS, 1, False, radius=300)
    obj(s, B, CTLS + 0x40, 0x17, True, radius=900, b6=0x40)
    plate(s, B)
    s.w(0x1B738, 4, CTLS)
    existing_record(s, 0)
    cases.append(case("player contact: existing record, hook", PLAYER_CONTACT, [A, B], s))
    for name, pos, sides in [("old record, crossing inside: dispatch", (100, -50, 200), 0),
                             ("old record, crossing outside the face", (1500, -50, 200), 0),
                             ("old record, same side", (100, -50, 200), 1),
                             ("old record, above the plate", (100, 50, 200), 1)]:
        s = setup()
        obj(s, A, CTLS, 1, True, x=pos[0], y=pos[1], z=pos[2], radius=300)
        obj(s, B, CTLS + 0x40, 0x17, False, radius=2000)
        plate(s, B)
        existing_record(s, sides)
        cases.append(case(f"object collision: {name}", OBJECT_COLLISION, [A, B], s))
    for name, b6, a_type in [("new record, hook (sides stored)", 0x40, 1), ("frozen (+5 bit 0)", 0x40, 1)]:
        s = setup()
        obj(s, A, CTLS, a_type, True, x=100, y=-50, z=200, radius=300, b5=1 if "frozen" in name else 0)
        obj(s, B, CTLS + 0x40, 0x17, True, radius=900, b6=b6)
        plate(s, B)
        cases.append(case(f"object collision: {name}", OBJECT_COLLISION, [A, B], s))
    s = setup()
    obj(s, A, CTLS, 1, False, x=100, y=-50, z=200, radius=300)
    obj(s, B, CTLS + 0x40, 0x17, False, radius=900)
    plate(s, B)
    rec = existing_record(s, 0)
    face = s.emu.read(B + 0x48, 4)
    for axis in (0, 1, 2, 3):
        cases.append(case(f"point in face, axis {axis}", POINT_IN_FACE, [rec, A, B, face, 0, 0, 0, 0, axis], s, True))
    return cases


CASES = build_cases()


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, log_base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=log_base, n=nargs: log_call(e, b, n)
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
        entry = {"name": c["name"], "routine": c["routine"], "method": METHODS[c["routine"]], "args": c["args"],
                 "zero": zero, "writes": writes, "changes": changes}
        if c["with_d0"]:
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
