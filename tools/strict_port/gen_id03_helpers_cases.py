#!/usr/bin/env python3
"""Generate comparison cases for the first ID03 batch (text scaling, max3_int, the nearest palette
entry, the 1-bit offscreen port, the dial arc, the colour port on a buffer, close_port_glue and the
identity colour remap) by running the ORIGINAL bytes.

ID03.bin is loaded at 0x30000 with A5 = 0x20000; ID02.bin at 0x40000 runs for real behind jump-table
slots $4da (abs_long) and $4f2 (memset), as the ports call ID02's, and ID01's switch helpers
(slots $3a dense, $2a sparse) at 0x46000. Every trap and other slot is a
logging stand-in on both sides (segment_stubs.py; MoveTo, LineTo and Line keep digest logs, as
the downsampler plots pixel by pixel and the panel draws hundreds of lines); the sine / cosine routines (A5 - 0x2118 /
-0x211c) are "addr" stand-ins answering scripted sequences; remap_cached_panel_colours runs for real
(it returns at once without a scenery record). Each
case records the original's entry stack pointer ("a7"). test_id03_helpers.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_helpers_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_helpers_cases.json")
CODE_DIR = "sources/resedit-1-0-3/CODE"
MEMORY_SIZE, CODE, A5, ID02_AT, ID01_AT = 0x60000, 0x30000, 0x20000, 0x40000, 0x46000
STACK_TOP, STACK_GUARD = 0x2F000, (0x2E000, 0x2F040)
DATA, PORTREC, PMH, PM, EXTRA, LOGS = 0x10000, 0x11000, 0x11100, 0x11140, 0x11200, 0x14000
SIN, COS, BITS, BWPORT = 0x3A000, 0x3A100, 0x12000, 0x12800
STUBS = [["trap", 0xA888, [2], True, 0], ["trap", 0xA88A, [2], True, 0], ["jt", 0x232, [4], True, 4, {}, [BITS, BWPORT]],
         ["jt", 0x23A, [4], True, 0], ["trap", 0xA86F, [4], True, 0], ["trap", 0xA875, [4], True, 0, {0: 3}],
         ["trap", 0xA876, [2, 2], True, 0], ["trap", 0xA8DF, [4, 4], True, 0, {0: 2}], ["trap", 0xA87D, [4], True, 0],
         ["addr", SIN, [4], False, 0, {}, [0x1000, 0xB50, 0, -0xB50, -0x1000, -0x800, 0x400]],
         ["addr", COS, [4], False, 0, {}, [0, 0xB50, 0x1000, 0xB50, 0, 0x800, -0x400]],
         ["trap", 0xA893, [2, 2], True, 0, {-1: "digest"}], ["trap", 0xA891, [2, 2], True, 0, {-1: "digest"}],
         ["trap", 0xA892, [2, 2], True, 0, {-1: "digest"}], ["trap", 0xA89D, [4], True, 0],
         ["trap", 0xAA00, [4], True, 0, {0: ["out", [PMH >> 16, (PMH & 0xFFFF) << 16]]}], ["trap", 0xA873, [4], True, 0]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
ROUTINES = {"set_scaled_text_style": 0x6, "scale_design_480_min10": 0x56, "scale_design_4800": 0x8A,
            "scale_design_4800_pen_centred": 0xA6, "max3_int": 0xC8, "nearest_palette_index_rgb": 0xF4,
            "new_offscreen_bw_port": 0x2A8, "dispose_offscreen_bw_port": 0x33C, "dial_point_at_angle": 0x5718,
            "open_cport_on_buffer": 0x5C36, "close_port_glue": 0x5CB6, "remap_panel_colours_identity": 0x71A2}
VOID = {"set_scaled_text_style", "dispose_offscreen_bw_port", "dial_point_at_angle", "close_port_glue", "remap_panel_colours_identity"}
PALETTE = [(0, 0, 0), (0xFFFF, 0xFFFF, 0xFFFF), (0xFFFF, 0, 0), (0, 0xFFFF, 0), (0, 0, 0xFFFF), (0x8000, 0x8000, 0x8000),
           (0xFFFF, 0xFFFF, 0), (0x4000, 0x2000, 0x1000)]
EXTRAS = [(0x1000, 0x1000, 0x1000), (0x9000, 0x9000, 0x9000), (0x7000, 0x7000, 0x7000), (0x8100, 0x8000, 0x7F00)]


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def common() -> list[list[int]]:
    w = [[a, 4, 0] for start, end in [(DATA, 0x13000), (LOGS, LOGS + 0x200 * len(STUBS)), (A5 - 0x2200, A5)] for a in range(start, end, 4)]
    vals = [(A5 + 0x3A, 2, 0x4EF9), (A5 + 0x3C, 4, ID01_AT + 0xBE), (A5 + 0x2A, 2, 0x4EF9), (A5 + 0x2C, 4, ID01_AT + 0x96), (A5 + 0x4DA, 2, 0x4EF9), (A5 + 0x4DC, 4, ID02_AT + 0x1E), (A5 + 0x4F2, 2, 0x4EF9), (A5 + 0x4F4, 4, ID02_AT + 0x2B0),
            (A5 - 0x149E, 4, 640), (A5 - 0x137A, 2, 8), (A5 - 0x160C, 4, PORTREC), (PORTREC + 0x36, 2, 3), (A5 - 0x2118, 4, SIN),
            (A5 - 0x211C, 4, COS), (A5 - 0x14A6, 4, EXTRA), (A5 - 0x14A2, 2, len(EXTRAS)), (PMH, 4, PM), (A5 - 0x1354, 4, 0xABCD),
            (BWPORT + 0x18, 4, 0x11300)]
    vals += [(A5 - 0x1FB6 + 2 * k, 2, 0x80 >> k) for k in range(8)]
    for k, (r, g, b) in enumerate(PALETTE):
        vals += [(A5 - 0x350 + 6 * k, 2, r), (A5 - 0x350 + 6 * k + 2, 2, g), (A5 - 0x350 + 6 * k + 4, 2, b)]
    for k, (r, g, b) in enumerate(EXTRAS):
        vals += [(EXTRA + 6 * k, 2, r), (EXTRA + 6 * k + 2, 2, g), (EXTRA + 6 * k + 4, 2, b)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list, port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


def rgb(r: int, g: int, b: int) -> list[list[int]]:
    return [[DATA, 2, r], [DATA + 2, 2, g], [DATA + 4, 2, b]]


def build() -> list[dict]:
    out = []
    for size, mode in ((12, 1), (12, 8), (-7, 1), (30, 4)):
        out.append(case(f"text style {size} in mode {mode}", "set_scaled_text_style", [W(size)], [size], [[A5 - 0x137A, 2, mode]]))
    for v, scale in ((10, 640), (0, 640), (1000, 480), (-50, 640), (3, 9000)):
        w = [[A5 - 0x149E, 4, scale]]
        out += [case(f"scale /480 {v} at {scale}", "scale_design_480_min10", [W(v)], [v], w),
                case(f"scale /4800 {v} at {scale}", "scale_design_4800", [W(v)], [v], w),
                case(f"scale /4800 pen-centred {v} at {scale}", "scale_design_4800_pen_centred", [W(v)], [v], w)]
    for a, b, c in ((1, 2, 3), (3, 2, 1), (-5, -9, -7), (0x7FFFFFFF, -1, 5), (4, 4, 4)):
        out.append(case(f"max3 {a} {b} {c}", "max3_int", [L(a), L(b), L(c)], [a, b, c]))
    for label, colour, mode, extra in (("grey, 8-bit", (0x8000, 0x8000, 0x8000), 8, len(EXTRAS)),
                                       ("near an extra, 8-bit", (0x9100, 0x9100, 0x9100), 8, len(EXTRAS)),
                                       ("red, 1-bit", (0xF000, 0x1000, 0x0800), 1, len(EXTRAS)),
                                       ("blue, 4-bit, no extras", (0x0100, 0x0200, 0xEE00), 4, 0),
                                       ("brown, 2-bit", (0x4100, 0x2100, 0x0F00), 2, len(EXTRAS)),
                                       ("no extras, 2-bit", (0x4100, 0x2100, 0x0F00), 2, 0)):
        out.append(case(f"nearest colour: {label}", "nearest_palette_index_rgb", [L(DATA)], [DATA],
                        rgb(*colour) + [[A5 - 0x137A, 2, mode], [A5 - 0x14A2, 2, extra]]))
    for w, h in ((100, 50), (17, 3), (0, 0)):
        out.append(case(f"offscreen port {w} x {h}", "new_offscreen_bw_port", [W(w), W(h)], [w, h]))
    out.append(case("dispose offscreen port", "dispose_offscreen_bw_port", [L(BWPORT)], [BWPORT], [[BWPORT + 2, 4, BITS]]))
    rect = [[DATA + 0x40, 4, (10 << 16) | 20], [DATA + 0x44, 4, (110 << 16) | 120]]
    for start, sweep in ((0, 30), (90, -20), (300, 5), (-45, 0)):
        out.append(case(f"dial arc from {start} for {sweep}", "dial_point_at_angle",
                        [L(DATA + 0x40), W(start), W(sweep), L(DATA + 0x50), L(DATA + 0x52)],
                        [DATA + 0x40, start, sweep, DATA + 0x50, DATA + 0x52], rect))
    out.append(case("colour port on a buffer", "open_cport_on_buffer",
                    [L(DATA + 0x200), W(0x140), L(0x50000), L((5 << 16) | 6), L((205 << 16) | 306)],
                    [DATA + 0x200, 0x140, 0x50000, (5 << 16) | 6, (205 << 16) | 306], [[DATA + 0x200 + 0x18, 4, 0x11400]]))
    out.append(case("close port", "close_port_glue", [L(BWPORT)], [BWPORT]))
    out.append(case("identity colour remap", "remap_panel_colours_identity", [], []))
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, f"{CODE_DIR}/ID03.bin", file_delta=0x7FFFFFFF)
    code = open(f"{CODE_DIR}/ID03.bin", "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    id02 = open(f"{CODE_DIR}/ID02.bin", "rb").read()
    emu.mem[ID02_AT:ID02_AT + len(id02)] = id02
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(f"{CODE_DIR}/ID01.bin", "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in CALL_LOGS])
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7, max_steps=60_000_000)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    base = common()
    logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in CALL_LOGS]
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": logs, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                 "a7": STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if c["method"] not in VOID:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
