#!/usr/bin/env python3
"""
Inspect Pacific Conflict binary: header u32/u16, section tables, 68k code-like regions.
Output: JSON (and optional sections.json path).
No guessing from DAT_ symbols; structure from header and pattern scan only.
"""

import argparse
import json
import math
import struct
import sys
from pathlib import Path

FILE_SIZE = 255_360
HEADER_SIZE = 0x20  # first 32 bytes reserved for header

# 68k instruction signatures (big-endian, word): opcode word or prefix
# 4E75=RTS, 4E56=LINK, 4E5E=UNLK, 48E7=MOVEM to stack, 2F=MOVE to -(SP), etc.
M68K_SIGNATURES = {
    0x4E75: "RTS",
    0x4E56: "LINK",
    0x4E5E: "UNLK",
    0x4E71: "NOP",
    0x48E7: "MOVEM.L to -(SP)",
    0x4CDF: "MOVEM.L (SP)+",
    0x2F00: "MOVE.L D0,-(SP)",
    0x2F08: "MOVE.L A0,-(SP)",
    0x2F0F: "MOVE.L A7,-(SP)",
    0x201F: "MOVE.L (SP)+,D0",
    0x41F9: "LEA (xxx.L),A0",
    0x43F9: "LEA (xxx.L),A1",
    0x2079: "MOVEA.L (xxx.L),A0",
    0x2279: "MOVEA.L (xxx.L),A1",
    0x4EF9: "JMP (xxx.L)",
    0x4EB9: "JSR (xxx.L)",
    0x6100: "BSR",
    0x6000: "BRA",
    0x6600: "BNE",
    0x6700: "BEQ",
    0x302F: "MOVE.W d(SP),D0",
    0x322F: "MOVE.W d(SP),D1",
    0x3080: "MOVE.W D0,(A0)",
    0x3140: "MOVE.W D0,d(A0)",
    0x3F00: "MOVE.W D0,-(SP)",
    0x3E1F: "MOVE.W (SP)+,D7",
    0x4CEE: "MOVEM.L (SP)+",
    0x2F02: "MOVE.L D2,-(SP)",
    0x242F: "MOVE.L d(SP),D2",
    0x202F: "MOVE.L d(SP),D0",
    0x2F2F: "MOVE.L d(SP),-(SP)",
}


def read_u16_be(data: bytes, offset: int) -> int:
    if offset + 2 > len(data):
        return None
    return struct.unpack(">H", data[offset : offset + 2])[0]


def read_u32_be(data: bytes, offset: int) -> int:
    if offset + 4 > len(data):
        return None
    return struct.unpack(">I", data[offset : offset + 4])[0]


def entropy(data: bytes) -> float:
    if not data:
        return 0.0
    counts = [0] * 256
    for b in data:
        counts[b] += 1
    n = len(data)
    e = 0.0
    for c in counts:
        if c:
            p = c / n
            e -= p * math.log2(p)
    return e


def scan_code_like_regions(data: bytes, window: int = 64, stride: int = 2) -> list:
    """Scan for regions that look like 68k code (word-aligned, high density of known opcodes)."""
    results = []
    i = HEADER_SIZE
    while i + window <= len(data):
        chunk = data[i : i + window]
        hits = 0
        for j in range(0, len(chunk) - 1, 2):
            w = struct.unpack(">H", chunk[j : j + 2])[0]
            if w in M68K_SIGNATURES:
                hits += 1
        density = hits / (len(chunk) // 2)
        if density >= 0.08:  # at least ~8% of words are known opcodes
            results.append({"offset": i, "window": window, "hits": hits, "density": round(density, 4)})
        i += stride
    return results


def detect_section_tables(data: bytes, header_u32: list, file_size: int) -> list:
    """Check if header fields point to tables (sequences of in-file offsets)."""
    candidates = []
    for idx, val in enumerate(header_u32):
        if val >= file_size or val < HEADER_SIZE:
            continue
        # Try interpreting as start of u32 table
        table = []
        off = val
        while off + 4 <= file_size and len(table) < 2048:
            u = read_u32_be(data, off)
            if u is None:
                break
            if u < HEADER_SIZE or u >= file_size:
                if table and len(table) >= 3:
                    candidates.append({"header_index": idx, "table_start": val, "entries": table.copy(), "note": "break on out-of-range"})
                break
            table.append(u)
            off += 4
        if len(table) >= 3:
            # Check monotonic
            monotonic = all(table[i] <= table[i + 1] for i in range(len(table) - 1))
            candidates.append({
                "header_index": idx,
                "table_start": val,
                "entry_count": len(table),
                "monotonic": monotonic,
                "first": table[0],
                "last": table[-1],
            })
    return candidates


def main():
    ap = argparse.ArgumentParser(description="Inspect Pacific Conflict binary: header, sections, code regions.")
    ap.add_argument("input", nargs="?", default=None, help="Path to Pacific Conflict binary (default: ../../../Hellcats/Pacific Conflict)")
    ap.add_argument("-o", "--output", help="Write JSON to file")
    ap.add_argument("--sections-json", help="Write sections.json to this path")
    args = ap.parse_args()

    script_dir = Path(__file__).resolve().parent
    default_path = script_dir / ".." / ".." / ".." / "Hellcats" / "Pacific Conflict"
    path = Path(args.input) if args.input else default_path

    if not path.exists():
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    data = path.read_bytes()
    file_size = len(data)
    if file_size != FILE_SIZE:
        print(f"Note: file size {file_size} (expected {FILE_SIZE})", file=sys.stderr)

    # --- Header ---
    header_u32 = []
    for i in range(8):
        u = read_u32_be(data, i * 4)
        header_u32.append(u if u is not None else 0)

    header_u16 = []
    for i in range(16):
        u = read_u16_be(data, i * 2)
        header_u16.append(u if u is not None else 0)

    # --- Section directory: do header values look like offsets to tables? ---
    table_candidates = detect_section_tables(data, header_u32[:4], file_size)

    # --- Code-like regions (coarse scan) ---
    code_regions = scan_code_like_regions(data, window=64, stride=32)

    # --- Build report ---
    report = {
        "file": str(path.resolve()),
        "file_size": file_size,
        "header_u32": [hex(x) for x in header_u32[:4]],
        "header_u32_dec": header_u32[:4],
        "header_u16_first_16": [hex(x) for x in header_u16[:16]],
        "table_candidates": table_candidates,
        "code_like_region_count": len(code_regions),
        "code_like_regions_sample": code_regions[:50],
    }

    # --- Sections from header interpretation (no DAT_ guessing) ---
    # H1: segment lengths; H2: segment offsets
    sections = []
    u0, u1, u2, u3 = header_u32[0], header_u32[1], header_u32[2], header_u32[3]
    # Segment 1: from 0x20, length u1 - 0x20 if u1 > 0x20
    if u1 > HEADER_SIZE and u1 <= file_size:
        start = HEADER_SIZE
        size = u1 - start
        if size > 0:
            ent = entropy(data[start : start + min(size, 65536)])
            # code score: density over first 1K
            sample = data[start : start + min(1024, size)]
            score = sum(1 for j in range(0, len(sample) - 1, 2) if struct.unpack(">H", sample[j:j+2])[0] in M68K_SIGNATURES) / (len(sample) // 2) if len(sample) >= 2 else 0
            sections.append({"name": "segment_1_after_header", "offset": start, "size": size, "entropy": round(ent, 4), "code_score": round(score, 4), "source": "u32[1]=length, start=0x20"})
    # Offsets as segment starts (u1, u2, u3)
    for idx, off_val in enumerate([u1, u2, u3]):
        if off_val >= file_size or off_val < HEADER_SIZE:
            continue
        # size = next segment start - this start, or to end
        next_starts = [u1, u2, u3]
        next_starts.sort()
        next_start = file_size
        for n in next_starts:
            if n > off_val:
                next_start = n
                break
        size = next_start - off_val
        if size <= 0:
            size = file_size - off_val
        sample = data[off_val : off_val + min(1024, size)]
        score = sum(1 for j in range(0, len(sample) - 1, 2) if struct.unpack(">H", sample[j:j+2])[0] in M68K_SIGNATURES) / (len(sample) // 2) if len(sample) >= 2 else 0
        ent = entropy(data[off_val : off_val + min(size, 65536)])
        sections.append({"name": f"at_offset_u32[{idx+1}]", "offset": off_val, "size": size, "entropy": round(ent, 4), "code_score": round(score, 4), "source": f"header offset {hex(off_val)}"})

    # Dedupe by offset, then sort by offset
    seen = set()
    unique_sections = []
    for s in sections:
        k = (s["offset"], s["size"])
        if k in seen:
            continue
        seen.add(k)
        unique_sections.append(s)
    unique_sections.sort(key=lambda x: x["offset"])

    report["sections"] = unique_sections

    out_json = json.dumps(report, indent=2)
    if args.output:
        Path(args.output).write_text(out_json, encoding="utf-8")
        print(f"Wrote {args.output}")
    else:
        print(out_json)

    if args.sections_json:
        Path(args.sections_json).write_text(json.dumps({"sections": unique_sections, "file_size": file_size}, indent=2), encoding="utf-8")
        print(f"Wrote {args.sections_json}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
