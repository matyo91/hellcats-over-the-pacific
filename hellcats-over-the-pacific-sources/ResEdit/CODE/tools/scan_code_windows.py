#!/usr/bin/env python3
"""
Score fixed-size windows in Pacific Conflict by 68k opcode pattern density.
Output: top N offsets by code score (and optional JSON).
"""

import argparse
import json
import struct
import sys
from pathlib import Path

# 68k opcode words (big-endian) that strongly indicate code
M68K_PATTERNS = {
    0x4E75,  # RTS
    0x4E56,  # LINK
    0x4E5E,  # UNLK
    0x4E71,  # NOP
    0x48E7,  # MOVEM.L xx,-(SP)
    0x4CDF,  # MOVEM.L (SP)+,xx
    0x4CEE,  # MOVEM.L (SP)+,xx (reg list)
    0x2F00,  # MOVE.L D0,-(SP)
    0x2F08,  # MOVE.L A0,-(SP)
    0x2F02,  # MOVE.L D2,-(SP)
    0x2F0F,  # MOVE.L A7,-(SP)
    0x201F,  # MOVE.L (SP)+,D0
    0x41F9,  # LEA (xxx.L),A0
    0x43F9,  # LEA (xxx.L),A1
    0x2079,  # MOVEA.L (xxx.L),A0
    0x2279,  # MOVEA.L (xxx.L),A1
    0x4EF9,  # JMP (xxx.L)
    0x4EB9,  # JSR (xxx.L)
    0x6100,  # BSR.W
    0x6000,  # BRA.W
    0x6600,  # BNE.W
    0x6700,  # BEQ.W
    0x302F,  # MOVE.W d(SP),D0
    0x322F,  # MOVE.W d(SP),D1
    0x3080,  # MOVE.W D0,(A0)
    0x3140,  # MOVE.W D0,d(A0)
    0x3F00,  # MOVE.W D0,-(SP)
    0x3E1F,  # MOVE.W (SP)+,D7
    0x242F,  # MOVE.L d(SP),D2
    0x202F,  # MOVE.L d(SP),D0
    0x2F2F,  # MOVE.L d(SP),-(SP)
    0x4E90,  # JSR (A0)
    0x4E92,  # JSR (A2)
    0x4ED0,  # JMP (A0)
    0x2F2E,  # MOVE.L d(A6),-(SP)
    0x2F0E,  # MOVE.L A6,-(SP)
    0x2F0B,  # MOVE.L A3,-(SP)
    0x206E,  # MOVEA.L d(A6),A0
    0x226E,  # MOVEA.L d(A6),A1
    0x2D40,  # MOVE.L D0,d(A6)
    0x2D48,  # MOVE.L A0,d(A6)
    0x4EFA,  # JMP (pc,d)
    0x6100,  # BSR
    0x5340,  # SUBQ.W #2,D0
    0x5580,  # SUBQ.L #2,D0
    0x5280,  # ADDQ.L #1,D0
    0x5380,  # SUBQ.L #1,D0
    0x51C8,  # DBF
    0x51C9,  # DBF
    0x51CA,  # DBF
    0x51CB,  # DBF
    0x51CC,  # DBF
    0x51CD,  # DBF
    0x51CE,  # DBF
    0x51CF,  # DBF
}


def score_window(data: bytes, offset: int, window: int) -> float:
    """Return fraction of words in window that match 68k opcode patterns."""
    end = min(offset + window, len(data))
    if end - offset < 4:
        return 0.0
    chunk = data[offset:end]
    words = (end - offset) // 2
    hits = 0
    for j in range(0, len(chunk) - 1, 2):
        w = struct.unpack(">H", chunk[j : j + 2])[0]
        if w in M68K_PATTERNS:
            hits += 1
    return hits / words if words else 0.0


def main():
    ap = argparse.ArgumentParser(description="Score windows by 68k code patterns; output top offsets.")
    ap.add_argument("input", nargs="?", default=None, help="Path to Pacific Conflict binary")
    ap.add_argument("-w", "--window", type=int, default=256, help="Window size in bytes (default 256)")
    ap.add_argument("-s", "--stride", type=int, default=16, help="Stride in bytes (default 16)")
    ap.add_argument("-n", "--top", type=int, default=80, help="Number of top offsets to print (default 80)")
    ap.add_argument("--skip-header", type=int, default=0x20, help="Skip bytes at start (default 0x20)")
    ap.add_argument("-o", "--output", help="Write JSON list of {offset, score} to file")
    args = ap.parse_args()

    script_dir = Path(__file__).resolve().parent
    default_path = script_dir / ".." / ".." / ".." / "Hellcats" / "Pacific Conflict"
    path = Path(args.input) if args.input else default_path

    if not path.exists():
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    data = path.read_bytes()
    file_size = len(data)
    results = []
    offset = args.skip_header
    while offset + args.window <= file_size:
        score = score_window(data, offset, args.window)
        if score >= 0.06:  # threshold
            results.append({"offset": offset, "score": round(score, 4)})
        offset += args.stride

    results.sort(key=lambda x: -x["score"])
    top = results[: args.top]

    print(f"Top {len(top)} offsets (window={args.window}, stride={args.stride}, skip={args.skip_header}):")
    print(f"{'offset':>10} {'hex':>10} {'score':>8}")
    print("-" * 30)
    for r in top:
        print(f"{r['offset']:>10} {r['offset']:>10x} {r['score']:>8.4f}")

    if args.output:
        Path(args.output).write_text(json.dumps({"window": args.window, "stride": args.stride, "top_offsets": top}, indent=2), encoding="utf-8")
        print(f"\nWrote {args.output}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
