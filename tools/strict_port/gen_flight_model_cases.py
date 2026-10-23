#!/usr/bin/env python3
"""Generate the update_aircraft_entity (0xe792) comparison cases by running the ORIGINAL bytes.

Each case starts from the binary image (runtime = file - 0x20), seeds the overlay RNG with the
original overlay_rng_init(1), applies its writes, runs the original routine in the m68k_emu
interpreter, and records every byte that changed outside the stack. The Godot test
test_flight_model.gd replays the same writes on the same image through the strict port and
requires exactly the same changed bytes.

Usage: python3 tools/strict_port/gen_flight_model_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/flight_model_cases.json")
MEMORY_SIZE = 0x40000
STACK_TOP = 0x3f000
STACK_GUARD = (STACK_TOP - 0x800, STACK_TOP + 0x40)
UPDATE_AIRCRAFT_ENTITY = 0xE772  # runtime address of file 0xe792
OVERLAY_RNG_INIT = 0x114EA       # runtime address of file 0x1150a
WORLD = 0x23000
CTL = 0x24000
OBJ = 0x24800
REC_KEY1 = 0x1A790               # player type record (file 0x1a7b0)


def base_writes(player: bool) -> list[list[int]]:
    w: list[list[int]] = []
    for addr in range(WORLD, WORLD + 0x400, 4):
        w.append([addr, 4, 0])
    for addr in range(CTL, CTL + 0x700, 4):
        w.append([addr, 4, 0])
    for addr in range(OBJ, OBJ + 0x80, 4):
        w.append([addr, 4, 0])
    for addr, size, value in [
        (0x1B5A0, 4, WORLD), (0x1B738, 4, CTL if player else 0), (0x1B888, 4, 0),
        (0x1B870, 2, 0), (0x1D858, 2, 1), (0x1B850, 2, 0), (0x1B854, 2, 0), (0x1B856, 2, 0),
        (0x1B858, 2, 0), (0x1B868, 2, 0), (0x1BC80, 4, 0), (0x1BC84, 2, 0),
        (CTL, 4, OBJ), (CTL + 4, 4, REC_KEY1), (OBJ + 8, 4, CTL),
        (CTL + 0x67D, 1, 23), (CTL + 0x67E, 1, 23), (CTL + 0x634, 2, 342), (CTL + 0x682, 2, 0x2A3),
    ]:
        w.append([addr, size, value])
    return w


def case(name: str, player: bool, extra: list[tuple[int, int, int]]) -> dict:
    return {"name": name, "writes": base_writes(player) + [list(e) for e in extra]}


CASES = [
    case("AI cruising level, throttle 6", False, [
        (OBJ + 0x1C, 4, 5000), (CTL + 0x62A, 4, 4 * 1500), (CTL + 0x668, 1, 6)]),
    case("AI climbing turn, stick and ailerons", False, [
        (OBJ + 0x1C, 4, 8000), (CTL + 0x62A, 4, 4 * 1200), (CTL + 0x668, 1, 9),
        (CTL + 0x662, 2, 120), (CTL + 0x666, 2, 0xFFC0), (CTL + 0x20, 2, 0x200), (CTL + 0x24, 2, 0x3F00)]),
    case("player cruising: engine model and climb ring", True, [
        (OBJ + 0x1C, 4, 6000), (CTL + 0x62A, 4, 4 * 1400), (CTL + 0x668, 1, 7),
        (CTL + 0x66A, 4, 0x20000), (CTL + 0x66E, 4, 0x18000), (CTL + 0x20, 2, 0x100)]),
    case("player slow, flaps and gear lowering", True, [
        (OBJ + 0x1C, 4, 2000), (CTL + 0x62A, 4, 4 * 700), (CTL + 0x668, 1, 3),
        (CTL + 0x67B, 1, 7), (CTL + 0x679, 1, 20), (CTL + 0x662, 2, 300)]),
    case("AI damaged: elevator / ailerons jitter, fuel leak, half engine", False, [
        (OBJ + 0x1C, 4, 4000), (CTL + 0x62A, 4, 4 * 1300), (CTL + 0x668, 1, 8),
        (CTL + 0x684, 2, 0x008E)]),
    case("AI fuel-burn accumulator overflow", False, [
        (OBJ + 0x1C, 4, 4000), (CTL + 0x62A, 4, 4 * 1300), (CTL + 0x668, 1, 9),
        (CTL + 0x680, 2, 9140)]),
    case("touchdown: gentle landing on the deck", True, [
        (OBJ + 0x1C, 4, 40), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 500), (CTL + 0x668, 1, 2),
        (CTL + 0x679, 1, 0x2D), (CTL + 0x2C, 1, 0x30), (CTL + 0x20, 2, 0x3FC0)]),
    case("rolling on the deck, gear down", True, [
        (OBJ + 0x1C, 4, 43), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 300), (CTL + 0x668, 1, 4),
        (CTL + 0x679, 1, 0x2D), (CTL + 0x63E, 1, 1), (CTL + 0x2C, 1, 0x30), (CTL + 0x63F, 1, 1)]),
    case("rolling on grass", True, [
        (OBJ + 0x1C, 4, 43), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 900), (CTL + 0x668, 1, 6),
        (CTL + 0x679, 1, 0x2D), (CTL + 0x63E, 1, 1), (CTL + 0x2C, 1, 0x40)]),
    case("arrested on the wire (latch 1)", True, [
        (OBJ + 0x1C, 4, 43), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 200), (CTL + 0x668, 1, 0),
        (CTL + 0x679, 1, 0x2D), (CTL + 0x63E, 1, 1), (CTL + 0x2C, 1, 0x30), (CTL + 0x640, 1, 1)]),
    case("hard landing: steep dive into the deck", True, [
        (OBJ + 0x1C, 4, 90), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 2500), (CTL + 0x668, 1, 9),
        (CTL + 0x679, 1, 0x2D), (CTL + 0x2C, 1, 0x30), (CTL + 0x20, 2, 0x3800)]),
    case("tilted touchdown: banked onto the deck (rough -> crash)", False, [
        (OBJ + 0x1C, 4, 80), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 500), (CTL + 0x668, 1, 2),
        (CTL + 0x679, 1, 0x2D), (CTL + 0x2C, 1, 0x30), (CTL + 0x20, 2, 0x3FA0), (CTL + 0x24, 2, 0x600)]),
    case("on water with the gear up (ditching)", True, [
        (OBJ + 0x1C, 4, 43), (CTL + 0x2E, 4, 10), (CTL + 0x62A, 4, 4 * 300), (CTL + 0x668, 1, 2),
        (CTL + 0x679, 1, 0), (CTL + 0x63E, 1, 1), (CTL + 0x2C, 1, 0x10), (CTL + 0x626, 2, 0x100)]),
    case("gear lever cycling and flap ramp (negative values)", False, [
        (OBJ + 0x1C, 4, 3000), (CTL + 0x62A, 4, 4 * 900), (CTL + 0x668, 1, 5),
        (CTL + 0x679, 1, 0xF0), (CTL + 0x67B, 1, 0xFA)]),
    case("engine switched off with smoke (0x4040), player", True, [
        (OBJ + 0x1C, 4, 3000), (CTL + 0x62A, 4, 4 * 900), (CTL + 0x668, 1, 5),
        (CTL + 0x684, 2, 0x4040), (CTL + 0x66E, 4, 5)]),
]


def run_case(c: dict) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    before = bytes(emu.mem)
    emu.call(UPDATE_AIRCRAFT_ENTITY, [CTL], STACK_TOP)
    changes = []
    for addr in range(MEMORY_SIZE):
        if STACK_GUARD[0] <= addr < STACK_GUARD[1]:
            continue
        if emu.mem[addr] != before[addr]:
            changes.append([addr, emu.mem[addr]])
    return changes


def main() -> None:
    out = {"memory_size": MEMORY_SIZE, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD),
           "routine": UPDATE_AIRCRAFT_ENTITY, "ctl": CTL, "cases": []}
    for c in CASES:
        changes = run_case(c)
        out["cases"].append({"name": c["name"], "writes": c["writes"], "changes": changes})
        print(f"{c['name']}: {len(changes)} bytes changed")
    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
