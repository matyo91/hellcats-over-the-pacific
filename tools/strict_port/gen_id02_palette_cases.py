#!/usr/bin/env python3
"""Generate comparison cases for the ID02 sound loading, palette and display routines
(load_named_sound_into_slot, rebuild_all_palette_index_maps, configure_palette_entries,
build_palette_index_map, scan_display_devices) by running the ORIGINAL bytes.

Layout as gen_id02_trapfree_cases.py. Every slot and trap is a logging stand-in on both sides
(segment_stubs.py), with logs of 0x1000 bytes (the palette loops make hundreds of calls). Three
devices (records with a pixmap handle) are walked by scripted GetNextDevice results; MaxMem's VAR
argument (the caller's frame) is not logged. rebuild_all_palette_index_maps hands its frame to
build_palette_index_map, so the port models A7 (segment_cases passes the fixture's stack top).
test_id02_palette.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_palette_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
import gen_id02_trapfree_cases as base_layout  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_palette_cases.json")
BINARY, CODE, A5 = base_layout.BINARY, base_layout.CODE, base_layout.A5
MEMORY_SIZE = 0x60000                                 # the 0x1000-byte logs live above the code
STACK_TOP, STACK_GUARD = base_layout.STACK_TOP, base_layout.STACK_GUARD
DATA, PORT = base_layout.DATA, base_layout.PORT
SND_H, MAP_BUF, NEW_MAP = 0x15000, 0x15400, 0x15800
DEVS = [0x15C00, 0x15D00, 0x15E00]                    # device record, its handle +0x80, pixmap +0x90 (handle at +0x88)
LOGS = 0x40000                                        # 0x18 logs of 0x1000: 0x40000..0x58000
STUBS = [["jt", 0x272, [4], True, 0], ["jt", 0x27A, [4], True, 0], ["jt", 0x282, [4], True, 0], ["jt", 0x28A, [4], True, 0],
         ["jt", 0x212, [], True, 4], ["jt", 0x21A, [4], True, 4, {0: 0}], ["jt", 0x232, [4], True, 4],
         ["jt", 0x2DA, [], True, 2], ["jt", 0x23A, [4], True, 0],
         ["trap", 0xA9A1, [4, 4], True, 4], ["trap", 0xA9A3, [4], True, 0], ["trap", 0xA9A6, [4], True, 2],
         ["trap", 0xA9A7, [2, 4], True, 0], ["trap", 0xA9AA, [4], True, 0], ["trap", 0xAA9E, [2, 2, 2, 4], True, 0],
         ["trap", 0xAA9C, [4, 2, 4], True, 0], ["trap", 0xA924, [], True, 4], ["trap", 0xAA32, [], True, 4],
         ["trap", 0xAA31, [4], True, 0], ["trap", 0xAA97, [2], True, 0], ["trap", 0xAA29, [], True, 4],
         ["trap", 0xAA2A, [], True, 4], ["trap", 0xAA2B, [4], True, 4, {}, [DEVS[1], DEVS[2], 0]], ["trap", 0xA87D, [4], True, 0]]


def log_entry(i: int, stub: list) -> list:
    kind, key, sizes, pascal, result, *rest = stub
    entry = [kind, key, LOGS + 0x1000 * i + 4, sizes, pascal, result, rest[0] if rest else {}]
    if len(rest) > 1:
        entry.append(rest[1])
    return entry


CALL_LOGS = [log_entry(i, s) for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"load_named_sound_into_slot": 0x1EDC, "rebuild_all_palette_index_maps": 0x46B4, "configure_palette_entries": 0x4738,
            "build_palette_index_map": 0x48AE, "scan_display_devices": 0x2192}
RESULT = {"load_named_sound_into_slot", "build_palette_index_map"}


def device(i: int, top: int, left: int, bottom: int, right: int, pixel_size: int = 8, flags: int = 1, kind: int = 2) -> list:
    rec = DEVS[i]
    h, pmh, pm = rec + 0x80, rec + 0x88, rec + 0x90
    return [(h, 4, rec), (rec + 4, 2, kind), (rec + 0x14, 1, flags), (rec + 0x16, 4, pmh), (pmh, 4, pm), (pm, 4, 0x400000 + 0x10000 * i),
            (pm + 4, 2, 0x8000 | (0x280 + 0x40 * i)), (pm + 6, 2, top), (pm + 8, 2, left), (pm + 10, 2, bottom), (pm + 12, 2, right),
            (pm + 0x20, 2, pixel_size)]


def common() -> list[list[int]]:
    w = base_layout.common()
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x1000 * len(STUBS), 4)]
    w += [[a, 4, 0] for a in range(0x15000, 0x16000, 4)]
    vals = [(LOG_OF[("trap", 0xA9A1)] - 4, 4, SND_H), (LOG_OF[("jt", 0x212)] - 4, 4, 0x100000), (LOG_OF[("jt", 0x21A)] - 4, 4, 0x200000),
            (LOG_OF[("trap", 0xA9A6)] - 4, 4, 0x0004), (LOG_OF[("trap", 0xAA32)] - 4, 4, 0x15F00), (LOG_OF[("jt", 0x232)] - 4, 4, NEW_MAP),
            (LOG_OF[("trap", 0xAA29)] - 4, 4, DEVS[0] + 0x80), (LOG_OF[("trap", 0xAA2A)] - 4, 4, DEVS[1] + 0x80),
            (A5 - 0x14AE, 4, 0x15A00), (A5 - 0x14AA, 4, 0x15B00), (A5 - 0x2CC, 2, 8), (A5 - 0x137A, 2, 8), (PORT + 0x52, 2, 0x41),
            (A5 - 0x14CA, 4, 0x15F80), (A5 - 0x103A, 4, 0)]
    for i in range(1, 4):
        vals += [(A5 - 0x136E + 0x16 * i, 4, 0), (A5 - 0x136E + 0x16 * i + 4, 4, MAP_BUF + 0x200 * (i - 1))]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


case = base_layout.case
L, W = base_layout.L, base_layout.W


def build() -> list[dict]:
    out = []
    for name, extra in (("plenty of memory", []), ("low memory: released", [[LOG_OF[("jt", 0x212)] - 4, 4, 0x1000],
                                                                          [LOG_OF[("jt", 0x21A)] - 4, 4, 0x2FFF]]),
                        ("FreeMem low, MaxMem enough", [[LOG_OF[("jt", 0x212)] - 4, 4, 0x1000]]),
                        ("already purgeable on disk", [[LOG_OF[("trap", 0xA9A6)] - 4, 4, 0x24]]),
                        ("missing", [[LOG_OF[("trap", 0xA9A1)] - 4, 4, 0]])):
        out.append(case(f"load sound: {name}", "load_named_sound_into_slot", [L(DATA), W(5)], [DATA, 5], extra))
    for depth in (4, 8, 1):
        out.append(case(f"palette entries depth {depth}", "configure_palette_entries", [W(depth)], [depth]))
    for pdepth, colour in ((8, 0x41), (4, 0x07)):
        out.append(case(f"index map device 2, palette depth {pdepth}", "build_palette_index_map",
                        [W(2), L(DATA), L(MAP_BUF), L(DATA + 0x100)], [2, DATA, MAP_BUF, DATA + 0x100],
                        [[A5 - 0x136E + 0x16 * 2, 4, 0x15F10], [A5 - 0x2CC, 2, pdepth], [PORT + 0x52, 2, colour]]))
    out.append(case("index map without a device", "build_palette_index_map", [W(1), L(DATA), L(MAP_BUF), L(DATA + 0x100)],
                    [1, DATA, MAP_BUF, DATA + 0x100]))
    devs = [[A5 - 0x136E + 0x16 * 1, 4, 0x15F10], [A5 - 0x136E + 0x16 * 3, 4, 0x15F20]]
    out += [
        case("rebuild maps at depth 8 (port closed)", "rebuild_all_palette_index_maps", [], [], devs + [[A5 - 0x103A, 4, 0x15F40]]),
        case("rebuild maps at palette depth 4", "rebuild_all_palette_index_maps", [], [], devs + [[A5 - 0x2CC, 2, 4], [PORT + 0x52, 2, 3]]),
        case("rebuild maps at depth 1", "rebuild_all_palette_index_maps", [], [], devs + [[A5 - 0x137A, 2, 1]]),
        case("rebuild maps without a palette", "rebuild_all_palette_index_maps", [], [], devs + [[A5 - 0x2CC, 2, 0]]),
    ]
    main_left = [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in device(0, 0, -640, 480, 0) + device(1, 0, 0, 480, 640)
                 + device(2, 0, 640, 480, 1280)]
    out += [
        case("scan: main between two neighbours", "scan_display_devices", [], [], main_left),
        case("scan: main record has its map", "scan_display_devices", [], [], main_left + [[A5 - 0x1358 + 4, 4, 0x15F60]]),
        case("scan: deep screens test true", "scan_display_devices", [], [], main_left + [[LOG_OF[("jt", 0x2DA)] - 4, 4, 0x100]]),
        case("scan: mismatched devices", "scan_display_devices", [], [],
             [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in device(0, 20, -640, 480, 0, flags=0) + device(1, 0, 0, 480, 640, kind=0)
              + device(2, 0, 640, 480, 1280, pixel_size=4)]),
    ]
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, CALL_LOGS)
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    base = common()
    logs = [[e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:] for e in CALL_LOGS]
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": logs, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] == "build_palette_index_map":       # MOVE.W of the count: only the low word is defined
            entry["d0"] = d0 & 0xFFFF
            entry["d0_mask"] = 0xFFFF
        elif c["method"] in RESULT:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
