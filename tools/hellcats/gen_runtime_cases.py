#!/usr/bin/env python3
"""Generate comparison cases for routines the game runtime writes outside the 740
(godot/hellcats/runtime/unexported.gd, overlay_loader.gd) by running their ORIGINAL bytes on the
68000 interpreter (tools/strict_port/m68k_emu.py), as the strict port's own cases are made.

Covered: ID02 0x3e8 ansi_strlen and 0x434 ansi_strncmp (ID02.bin loaded at its file offsets,
strings at 0xa000 / 0xb000), and the overlay's 0x4b0 player_left_ground_zone (the Pacific
Conflict image at its runtime addresses: file offset - 0x20; the player pointer 0x1b738, its
controller at 0x20000 and object at 0x20800). Each case gives the memory it starts from and the
D0 the original returns; godot/tests/runtime/test_unexported_routines.gd replays them on the
runtime's routines.

Usage: python3 tools/hellcats/gen_runtime_cases.py [--check]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "strict_port"))
from m68k_emu import Emulator  # noqa: E402

FIXTURE = ROOT / "godot" / "tests" / "runtime" / "fixtures" / "unexported_cases.json"
ID02 = ROOT / "sources" / "resedit-1-0-3" / "CODE" / "ID02.bin"
OVERLAY = ROOT / "godot" / "hellcats" / "data" / "scenery" / "Pacific Conflict"
STACK_TOP = 0x2F000
STR_A, STR_B = 0xA000, 0xB000
PLAYER, CTL, OBJ = 0x1B738, 0x20000, 0x20800


def cstr(addr: int, data: bytes) -> list[list[int]]:
    return [[addr + k, 1, b] for k, b in enumerate(data + b"\0")]


def strlen_cases() -> list[dict]:
    out = []
    for text in (b"", b"a", b"POW!", b"Well bud, looks like you bought the farm on that one!", bytes(range(1, 256))):
        out.append({"name": f"strlen {len(text)}", "routine": "id02_03e8", "segment": "ID02", "address": 0x3E8,
                    "args": [STR_A], "writes": cstr(STR_A, text)})
    return out


def strncmp_cases() -> list[dict]:
    pairs = [(b"Lucky Lindy", b"Lucky Lindy", 30), (b"Lucky Lindy", b"Lucky Lindy", 0), (b"abc", b"abd", 3),
             (b"abd", b"abc", 3), (b"abc", b"abd", 2), (b"abc", b"abcdef", 30), (b"abcdef", b"abc", 30),
             (b"\x80bc", b"\x7fbc", 3), (b"\x7fbc", b"\x80bc", 3), (b"", b"", 5), (b"", b"x", 5), (b"Zed", b"zed", 3)]
    out = []
    for a, b, n in pairs:
        out.append({"name": f"strncmp {a!r} {b!r} {n}", "routine": "id02_0434", "segment": "ID02", "address": 0x434,
                    "args": [STR_A, STR_B, n], "writes": cstr(STR_A, a) + cstr(STR_B, b)})
    return out


def ground_zone_cases() -> list[dict]:
    out = [{"name": "no player", "routine": "_04b0", "segment": "overlay", "address": 0x4B0, "args": [],
            "writes": [[PLAYER, 4, 0]]}]
    for y, ground in ((692, 625), (625 + 4999, 625), (625 + 5000, 625), (100000, 0), (-50000, 625), (0x7FFFFFF0, -100)):
        out.append({"name": f"y {y} ground {ground}", "routine": "_04b0", "segment": "overlay", "address": 0x4B0,
                    "args": [], "writes": [[PLAYER, 4, CTL], [CTL, 4, OBJ], [CTL + 0x2E, 4, ground & 0xFFFFFFFF],
                                           [OBJ + 0x1C, 4, y & 0xFFFFFFFF]]})
    return out


def run(case: dict) -> int:
    if case["segment"] == "ID02":
        emu = Emulator(0x30000, str(ID02), file_delta=0)
    else:
        emu = Emulator(0x30000, str(OVERLAY), file_delta=0x20)
    for addr, size, value in case["writes"]:
        emu.write(addr, size, value)
    return emu.call(case["address"], case["args"], STACK_TOP) & 0xFFFFFFFF


def build() -> dict:
    cases = strlen_cases() + strncmp_cases() + ground_zone_cases()
    for c in cases:
        c["d0"] = run(c)
    return {"source": "tools/hellcats/gen_runtime_cases.py", "cases": cases}


def main() -> int:
    text = json.dumps(build(), indent=1) + "\n"
    if "--check" in sys.argv:
        if not FIXTURE.exists() or FIXTURE.read_text(encoding="utf-8") != text:
            print(f"FAIL {FIXTURE.relative_to(ROOT)} is stale; rerun without --check")
            return 1
        print("PASS runtime routine cases are up to date")
        return 0
    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(text, encoding="utf-8")
    print(f"wrote {FIXTURE.relative_to(ROOT)}: {text.count('\"routine\"')} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
