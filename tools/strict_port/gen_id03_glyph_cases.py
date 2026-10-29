#!/usr/bin/env python3
"""Generate comparison cases for the second ID03 batch (the inset face oval region, compositing and
finishing a supersampled instrument, the vector glyph string and vector number) by running the
ORIGINAL bytes.

The set-up is gen_id03_helpers_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID02.bin behind its
jump-table slots) with more stand-ins: the panel-coordinate slots $3ca / $382 answer scripted
sequences, the region traps and CopyBits are logged, and the colour slot $36a keeps a digest log
(antialias_downsample_bw_3x runs for real, pixel by pixel). Six vector glyphs (A5 - 0x20b0) and ten vector digits
(A5 - 0x1fde) are seeded. Each case records the original's entry stack pointer ("a7").
test_id03_glyph.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_glyph_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_helpers_cases as helpers  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_glyph_cases.json")
A5, DATA, LOGS = helpers.A5, helpers.DATA, helpers.LOGS
GLYPHS, DIGITS, PANEL, RGN = 0x12C00, 0x12E00, 0x11600, 0x11700
EXTRA_STUBS = [["trap", 0xA89B, [2, 2], True, 0], ["trap", 0xA8A9, [2, 2, 4], True, 0, {2: 2}], ["trap", 0xA8D8, [], True, 4],
               ["trap", 0xA8DA, [], True, 0], ["trap", 0xA8DB, [4], True, 0], ["trap", 0xA8B7, [4], True, 0, {0: 2}],
               ["trap", 0xA8A8, [2, 2, 4], True, 0, {2: 2}], ["trap", 0xA8EC, [4, 2, 4, 4, 4, 4], True, 0, {2: 2, 3: 2}],
               ["jt", 0x3CA, [2], False, 0, {}, [12, 40, 7]], ["jt", 0x382, [2], False, 0, {}, [30, 8, 99]],
               ["jt", 0x36A, [2], False, 0, {-1: "digest"}]]
N_FIRST = len(helpers.STUBS)
STUBS = helpers.STUBS + EXTRA_STUBS
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
ROUTINES = {"make_inset_face_oval_region": 0x3832, "composite_instrument_bitmap": 0x146A, "finish_instrument_supersample": 0x1844,
            "draw_vector_glyph_string_centred": 0x77E, "draw_vector_number": 0x912}
GLYPH_DATA = [b"N\x04" + bytes([0, 0, 0, 0xFA, 4, 6, 0, 0xFA]) + b"c", b"E\x03" + bytes([3, 0, 0xFD, 0, 0, 6, 3, 0]) + b"c",
              b"S\x03" + bytes([3, 0, 0xFD, 0, 0, 3, 3, 0, 0, 3, 0xFD, 0]) + b"c", b"W\x05" + bytes([0, 0, 1, 6, 2, 0xFC, 2, 4, 1, 0xFA]) + b"c",
              b"-\x02" + bytes([0, 3, 2, 0]) + b"c", b"0\x03" + bytes([0, 0, 3, 0, 0, 6, 0xFD, 0, 0, 0xFA]) + b"c"]
DIGIT_DATA = [bytes([0, 0, 3, 0, 0, 6, 0xFD, 0, 0, 0xFA]) + b"c"] + [bytes([k % 3, 0, 1, k % 5 + 1, 0xFF, 1]) + b"c" for k in range(1, 10)]


def common() -> list[list[int]]:
    w = [x for x in helpers.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_FIRST)]
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]
    vals = [(A5 - 0x1496, 4, PANEL), (CALL_LOGS[N_FIRST + 2][2] - 4, 4, RGN), (A5 - 0x1FA6, 2, 0x1234),
            (A5 - 0x1FA4, 4, 0x56789ABC), (DATA + 0x300 + 0x10, 4, (0 << 16) | 0), (DATA + 0x300 + 0x14, 4, (60 << 16) | 60),
            (DATA + 0x300 + 0x18, 4, 0x11800), (DATA + 0x300 + 2, 4, 0x12000)]
    for k, blob in enumerate(GLYPH_DATA):
        vals += [(A5 - 0x20B0 + 4 * k, 4, GLYPHS + 0x20 * k)] + [(GLYPHS + 0x20 * k + j, 1, b) for j, b in enumerate(blob)]
    for k, blob in enumerate(DIGIT_DATA):
        vals += [(A5 - 0x1FDE + 4 * k, 4, DIGITS + 0x20 * k)] + [(DIGITS + 0x20 * k + j, 1, b) for j, b in enumerate(blob)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


L, W, case = helpers.L, helpers.W, helpers.case


def text(s: bytes) -> list[list[int]]:
    return [[DATA + 0x80 + k, 1, b] for k, b in enumerate(s + b"\x00")]


def build() -> list[dict]:
    port = DATA + 0x300
    out = [case("inset face oval", "make_inset_face_oval_region", [L(DATA + 0x40), W(600), W(100), W(-40)], [DATA + 0x40, 600, 100, -40]),
           case("inset face oval, small", "make_inset_face_oval_region", [L(DATA + 0x40), W(15), W(0), W(0)], [DATA + 0x40, 15, 0, 0],
                [[A5 - 0x149E, 4, 4800]])]
    for mode in (1, 8):
        out.append(case(f"composite, mode {mode}", "composite_instrument_bitmap", [L(port), W(300), W(0), W(250), W(-120)],
                        [port, 300, 0, 250, -120], [[A5 - 0x137A, 2, mode]]))
        out.append(case(f"finish supersample, mode {mode}", "finish_instrument_supersample", [L(port), W(300), W(250), W(-120)],
                        [port, 300, 250, -120], [[A5 - 0x137A, 2, mode]]))
    for s, scale in ((b"NEWS", 40), (b"N", 25), (b"S-W 0", 18), (b"QNXE", 30), (b"", 10), (b"EE", -12)):
        out.append(case(f"glyphs {s!r} at {scale}", "draw_vector_glyph_string_centred", [L(DATA + 0x80), W(scale), W(300), W(-50)],
                        [DATA + 0x80, scale, 300, -50], text(s)))
    for n, scale in ((0, 20), (7, 30), (1945, 12), (32767, 8), (10, 50)):
        out.append(case(f"number {n} at {scale}", "draw_vector_number", [W(n), W(scale), W(-200), W(80)], [n, scale, -200, 80]))
    return out


def main() -> None:
    base = common()
    helpers.STUBS, helpers.CALL_LOGS, helpers.ROUTINES = STUBS, CALL_LOGS, ROUTINES
    logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in CALL_LOGS]
    out = {"memory_size": helpers.MEMORY_SIZE, "a5": A5, "stack_top": helpers.STACK_TOP, "stack_guard": list(helpers.STACK_GUARD),
           "common_writes": base, "call_logs": logs, "cases": []}
    for c in build():
        changes, d0 = helpers.run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                 "a7": helpers.STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if c["method"] == "make_inset_face_oval_region":
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
