#!/usr/bin/env python3
"""Generate comparison cases for the handle and session-buffer routines (ensure_handle_allocated,
lock_handle_nopurge, unlock_handle_purgeable, lock_overlay_buffers, allocate_session_buffers,
lock_session_buffers, unlock_session_buffers) by running the ORIGINAL bytes.

The host Memory Manager hooks (+0x2c6 new handle, +0x2ce reallocate, +0x2d2 lock, +0x2d6 unlock,
+0x2da purgeable, +0x2de no-purge, +0x2e2 free memory) are logging stubs on both sides; the free
memory and new-handle results are set per case. Handles are missing, purged (master pointer 0)
or present (master pointers into real buffers, with high garbage under 24-bit addressing); the
host has one or three screens, depth 1 or not, 24-bit addressing or not.
lock_session_buffers ends in update_view_clip_bounds, run as ported. test_session_buffers.gd
replays the cases (helpers/original_cases.gd).

Usage: python3 tools/strict_port/gen_session_buffer_cases.py  (writes the fixture JSON)
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

FIXTURE = Path("godot/tests/strict_port/fixtures/session_buffer_cases.json")
ROUTINES = {0xD90: "ensure_handle_allocated", 0xDEA: "lock_handle_nopurge", 0xE12: "unlock_handle_purgeable",
            0xE3A: "lock_overlay_buffers", 0xE80: "allocate_session_buffers", 0xF72: "lock_session_buffers",
            0x1074: "unlock_session_buffers"}
BY_NAME = {v: k for k, v in ROUTINES.items()}
WORLD, HANDLES = 0x27000, 0x27800
HOOKS = {0x2C6: (0x30000, 1), 0x2CE: (0x30100, 2), 0x2D2: (0x30200, 1), 0x2D6: (0x30300, 1), 0x2DA: (0x30400, 1),
         0x2DE: (0x30500, 1), 0x2E2: (0x30600, 0)}
CALL_LOGS = [[addr, 0x38004 + 0x200 * k, n] for k, (addr, n) in enumerate(HOOKS.values())]



def case(name: str, routine: str, args: list[int] = (), byte0: int = 1, depth1: int = 0, multi: int = 0, mask24: int = 0,
         free_mem: int = 0x100000, present: bool = True, purged: tuple[int, ...] = (), new_handle: int = 0x27F00) -> dict:
    w = [[a, 4, 0] for a in list(range(WORLD, WORLD + 0x300, 4)) + list(range(HANDLES, HANDLES + 0x200, 4))
         + list(range(0x38000, 0x39000, 4)) + list(range(0x1B744, 0x1B7A0, 4)) + list(range(0x2B000, 0x2E800, 4))]
    vals = [(0x1B5A0, 4, WORLD), (WORLD, 1, byte0), (WORLD + 0xE, 2, 1 if depth1 else 8), (WORLD + 0xB4, 2, multi),
            (WORLD + 0x76, 2, mask24), (WORLD + 0xC, 2, 0x140), (0x38004 + 0x200 * 6 - 4, 4, free_mem),
            (0x38004 - 4, 4, new_handle), (0x20C4C, 4, 0x77), (0x1B828, 2, 200), (0x1D858, 2, 2), (WORLD + 0xA2, 2, 1),
            (WORLD + 0x192, 4, 0x2A000), (WORLD + 0x1AC, 4, 0x2A010), (WORLD + 0x1B4, 4, 0x2A020), (WORLD + 0xD8, 4, 0x2A030)]
    for k, (off, (addr, _n)) in enumerate(HOOKS.items()):
        vals.append((WORLD + off, 4, addr))
    if present:
        slots = [0x1B744] + [0x1B74C + 4 * k for k in range(1, 4)] + [0x1B75C + 4 * k for k in range(1, 4)]
        for i, slot in enumerate(slots):
            h = HANDLES + 0x10 * i
            vals += [(slot, 4, h), (h, 4, 0 if i in purged else (0xFF000000 if mask24 else 0) + 0x2B000 + 0x800 * i)]
    w += [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    return {"name": name, "routine": BY_NAME[routine], "args": list(args), "writes": w}


def build() -> list[dict]:
    return [
        case("ensure: missing handle created", "ensure_handle_allocated", [0x1B744, 0x1000], present=False),
        case("ensure: purged handle reallocated", "ensure_handle_allocated", [0x1B744, 0x2000], purged=(0,)),
        case("ensure: present handle kept", "ensure_handle_allocated", [0x1B744, 0x3000]),
        case("lock one handle", "lock_handle_nopurge", [HANDLES]),
        case("unlock one handle", "unlock_handle_purgeable", [HANDLES]),
        case("lock overlay buffers", "lock_overlay_buffers"),
        case("allocate: plenty of memory, multi-screen, nothing yet", "allocate_session_buffers", multi=1, present=False),
        case("allocate: little memory, single screen, one purged", "allocate_session_buffers", free_mem=0x7D000, purged=(1,)),
        case("allocate: all present", "allocate_session_buffers", multi=1),
        case("allocate: depth 1, no entry handle", "allocate_session_buffers", depth1=1, byte0=0, present=False),
        case("lock session: multi-screen", "lock_session_buffers", multi=1),
        case("lock session: single screen, 24-bit", "lock_session_buffers", mask24=1),
        case("lock session: depth 1", "lock_session_buffers", depth1=1),
        case("unlock session: all", "unlock_session_buffers", multi=1),
        case("unlock session: no handles", "unlock_session_buffers", present=False),
    ]


def run_case(c: dict) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE)
    emu.call(OVERLAY_RNG_INIT, [1], STACK_TOP)
    for addr, size, value in c["writes"]:
        emu.write(addr, size, value)
    for address, base, nargs in CALL_LOGS:
        emu.stubs[address] = lambda e, b=base, n=nargs: log_call(e, b, n)
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
        if ROUTINES[c["routine"]] == "ensure_handle_allocated":
            entry["d0"] = d0
        out["cases"].append(entry)
        print(f"{c['name']}: {len(changes)} bytes changed, d0 {d0:#x}")
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")


if __name__ == "__main__":
    main()
