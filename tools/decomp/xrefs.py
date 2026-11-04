#!/usr/bin/env python3
"""Byte-level cross-references to a routine of a CODE segment or of the Pacific Conflict overlay,
found in the original bytes rather than the decompiled text (which misses indirect and
unexported callers).

For a CODE segment (ID01..ID09) and a file offset:
  - in the same segment: BSR.S / BSR.W / BSR.L and JSR / PEA / LEA d16(PC) to it;
  - through the CODE 0 jump table (godot/hellcats/data/jump_table.json): the A5 slots naming it, and
    in every segment the JSR / PEA / LEA slot(A5) that use them.
For the overlay and a file offset (Ghidra's addresses; runtime = file - 0x20):
  - BSR.S / .W / .L to it, and every long equal to its runtime address (JSR / LEA / PEA abs.L, and
    data such as definition records), reported with the two bytes before it.

Usage:
  python3 tools/decomp/xrefs.py ID05 0x3ba
  python3 tools/decomp/xrefs.py "Pacific Conflict" 0x155d8
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CODE = ROOT / "sources" / "resedit-1-0-3" / "CODE"
OVERLAY = ROOT / "godot" / "hellcats" / "data" / "scenery" / "Pacific Conflict"
JUMP_TABLE = ROOT / "godot" / "hellcats" / "data" / "jump_table.json"
OVERLAY_DELTA = 0x20


def u16(b: bytes, o: int) -> int:
    return struct.unpack(">H", b[o:o + 2])[0]


def s16(b: bytes, o: int) -> int:
    return struct.unpack(">h", b[o:o + 2])[0]


def branches(b: bytes, target: int) -> list[str]:
    """PC-relative branches and effective addresses that land on `target` (a file offset)."""
    out = []
    for o in range(0, len(b) - 5, 2):
        w = u16(b, o)
        if w >> 8 == 0x61:
            low = w & 0xFF
            if low == 0:
                dest, kind = o + 2 + s16(b, o + 2), "BSR.W"
            elif low == 0xFF:
                dest, kind = o + 2 + struct.unpack(">i", b[o + 2:o + 6])[0], "BSR.L"
            else:
                dest, kind = o + 2 + struct.unpack(">b", bytes([low]))[0], "BSR.S"
            if dest == target:
                out.append(f"{kind} at 0x{o:x}")
        elif w in (0x4EBA, 0x487A) or (w & 0xF1FF) == 0x41FA:        # JSR / PEA / LEA d16(PC)
            if o + 2 + s16(b, o + 2) == target:
                kind = {0x4EBA: "JSR d16(PC)", 0x487A: "PEA d16(PC)"}.get(w, f"LEA d16(PC),A{(w >> 9) & 7}")
                out.append(f"{kind} at 0x{o:x}")
    return out


def a5_uses(b: bytes, offset: int) -> list[str]:
    """JSR / PEA / LEA slot(A5) with the given A5 offset."""
    out = []
    for o in range(0, len(b) - 3, 2):
        w = u16(b, o)
        if (w in (0x4EAD, 0x486D) or (w & 0xF1FF) == 0x41ED) and s16(b, o + 2) == offset:
            kind = {0x4EAD: "JSR", 0x486D: "PEA"}.get(w, f"LEA ...,A{(w >> 9) & 7}")
            out.append(f"{kind} ${offset:x}(A5) at 0x{o:x}")
    return out


def segment_xrefs(segment: str, target: int) -> list[str]:
    number = int(segment[2:])
    out = [f"{segment}: {r}" for r in branches((CODE / f"{segment}.bin").read_bytes(), target)]
    entries = json.loads(JUMP_TABLE.read_text(encoding="utf-8"))["entries"]
    for e in entries:
        if int(e["segment"]) == number and int(e["target"]) == target:
            offset = int(e["a5_offset"])
            out.append(f"jump-table slot ${offset:x}")
            for path in sorted(CODE.glob("ID0*.bin")):
                out += [f"{path.stem}: {r}" for r in a5_uses(path.read_bytes(), offset)]
    return out


def overlay_xrefs(target: int) -> list[str]:
    b = OVERLAY.read_bytes()
    out = [f"overlay: {r}" for r in branches(b, target)]
    runtime = target - OVERLAY_DELTA
    for o in range(0, len(b) - 3, 2):
        if struct.unpack(">I", b[o:o + 4])[0] == runtime:
            out.append(f"overlay: long 0x{runtime:x} at file 0x{o:x} (after {b[o - 2:o].hex()})")
    return out


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(__doc__.strip())
        return 2
    segment, target = argv[1], int(argv[2], 0)
    refs = overlay_xrefs(target) if segment == "Pacific Conflict" else segment_xrefs(segment, target)
    for r in refs:
        print(r)
    if not refs:
        print("no reference in the bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
