#!/usr/bin/env python3
"""Generate comparison cases for load_overlay_from_resource (ID08 0x6) by running the ORIGINAL bytes.

ID08.bin is loaded at 0x30000 with A5 = 0x20000. Every jump-table slot and trap is a logging stand-in
on both sides (segment_stubs.py); alloc_and_read_resource_payload (0x348, already ported) runs for
real. The file is played back through FSRead's buffer argument: an "outseq" list writes, call by
call, the 32-byte header, the code, the data, each 8-byte relocation entry and the payload. The
image block (NewPtr) is deliberately unaligned. A case replaces the call logs to script another
file. Each case records the original's entry stack pointer ("a7"). test_id08_loader.gd replays the
cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id08_loader_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id08_loader_cases.json")
BINARY = "sources/resedit-1-0-3/CODE/ID08.bin"
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
STACK_TOP, STACK_GUARD = 0x2F000, (0x2E000, 0x2F040)
DATA, REC_H, REC, IMAGE, LOGS = 0x10000, 0x11200, 0x11240, 0x12001, 0x14000


def header(code: int, data: int, extra: int, first: int, second: int) -> list[int]:
    return [0x48454C4C, code, data, extra, 0, 0, 8 * first, 8 * second]


def reloc(offset: int, flags: int) -> list[int]:
    return [offset, flags]


GOOD = [header(0x20, 0x10, 0x8, 2, 1), [0x11111111, 0x00000010, 0x22222222, 0x00000004], [0x00000008, 0x33333333],
        reloc(4, 0x40), reloc(0xC, 0xC0), reloc(0, 0x40), [0x55555555]]
STUBS = [["jt", 0x2A2, [4, 2, 4], True, 2, {0: ["out", 7, 2]}, [0]], ["jt", 0x4D2, [4, 4], False, 0], ["jt", 0xFA, [4], False, 0],
         ["jt", 0x23A, [4], True, 0], ["jt", 0x2B2, [4, 4, 2], True, 2, {0: ["outseq", GOOD], 1: 1}, [0]],
         ["jt", 0x4BA, [4, 2], False, 0], ["jt", 0x232, [4], True, 4], ["jt", 0x2CA, [4, 2], True, 2, {0: ["out", 0x100]}],
         ["jt", 0x2C2, [4, 2], True, 2, {0: ["out", 0x1234]}], ["jt", 0x22A, [4], True, 4], ["jt", 0x4C2, [], False, 0],
         ["jt", 0x2AA, [2], True, 2], ["jt", 0x53A, [4, 4], False, 0], ["trap", 0xA975, [], True, 4],
         ["jt", 0x542, [4, 2, 4], False, 0], ["jt", 0x582, [4, 4], False, 0, {0: ["out", 0x1357], 1: ["out", 0x2468]}],
         ["jt", 0x552, [4], False, 0], ["jt", 0x54A, [4, 4], False, 0, {}, [1, 0]], ["jt", 0x532, [], False, 0],
         ["jt", 0x572, [4, 4], False, 0, {0: ["out", 0x9999]}], ["jt", 0x55A, [], False, 0], ["jt", 0x57A, [4, 4], False, 0],
         ["jt", 0x2BA, [4, 4], True, 2, {0: ["out", 0xFFFE, 2]}], ["jt", 0x2FA, [4], False, 0], ["jt", 0x51A, [4, 4], False, 0],
         ["jt", 0x47A, [2], False, 0], ["trap", 0xA986, [4, 2], True, 2], ["trap", 0xA9F4, [], True, 0],
         ["jt", 0x21A, [4], True, 4, {0: ["out", 0x5000]}]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}


def logs_with(changes: dict) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for e in logs:
        key = (e[0], e[1])
        if key in changes:
            derefs, results = changes[key]
            if derefs is not None:
                e[6] = derefs
            if results is not None:
                e[7:] = [results]
    return logs


def file(chunks: list) -> tuple:
    return {0: ["outseq", chunks], 1: 1}, None


def common() -> list[list[int]]:
    w = [[a, 4, 0] for start, end in [(DATA, 0x13000), (LOGS, LOGS + 0x200 * len(STUBS)), (A5 - 0x2000, A5)] for a in range(start, end, 4)]
    vals = [(A5 - 0x13AC, 4, REC_H), (REC_H, 4, REC), (REC + 0x28, 2, 3), (REC + 0x2A, 4, 0x04484F4C), (REC + 0x2E, 4, 0x45000000),
            (LOG_OF[("jt", 0x232)] - 4, 4, IMAGE), (LOG_OF[("jt", 0x22A)] - 4, 4, 0x12800), (LOG_OF[("trap", 0xA975)] - 4, 4, 0x4321),
            (LOG_OF[("jt", 0x552)] - 4, 4, 0x77), (LOG_OF[("jt", 0x2FA)] - 4, 4, 0x11300), (LOG_OF[("jt", 0x51A)] - 4, 4, 1),
            (A5 - 0xDF6, 4, 0x11400), (A5 - 0xDF2, 4, 0x11410), (A5 - 0xDEE, 4, 0x11420), (A5 - 0xDEA, 4, 0x11430)]
    vals += [(A5 - 0x1A24 + 4 * k, 4, 0x01010101 * (k + 1)) for k in range(0x40)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, writes: list[list[int]] = (), changes: dict | None = None) -> dict:
    c = {"name": name, "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}
    if changes:
        c["call_logs"] = logs_with(changes)
    return c


def build() -> list[dict]:
    fs_read = ("jt", 0x2B2)
    return [
        case("loads and relocates"),
        case("replaces a previous image", [[A5 - 0x1006, 4, 0x12F00]]),
        case("opens on the default volume", changes={("jt", 0x2A2): (None, [0xFFD5, 0])}),
        case("cannot open", changes={("jt", 0x2A2): (None, [0xFFD5])}),
        case("header read fails", changes={fs_read: (None, [0xFFD9])}),
        case("no memory", [[LOG_OF[("jt", 0x232)] - 4, 4, 0]]),
        case("no data part", changes={fs_read: file([header(0x10, 0, 0, 1, 0), [0, 0, 0x40, 0], reloc(8, 0x40), [7]])}),
        case("relocation flagged as an error", changes={fs_read: file([header(0x10, 0x8, 0, 2, 0), [1, 2, 3, 4], [5, 6],
                                                                       reloc(0, 0x40), reloc(4, 0x10)])}),
        case("relocation of another kind", changes={fs_read: file([header(0x10, 0x8, 0, 1, 0), [1, 2, 3, 4], [5, 6], reloc(0, 0x20)])}),
        case("checks pass", changes={("jt", 0x54A): (None, [0])}),
        case("checks fail twice", changes={("jt", 0x54A): (None, [1])}),
        case("on the locked volume", [[LOG_OF[("jt", 0x51A)] - 4, 4, 0]]),
    ]


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, c.get("call_logs", CALL_LOGS))
    before = bytes(emu.mem)
    d0 = emu.call(CODE + 0x6, [], STACK_TOP)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def as_json(logs: list) -> list:
    return [[e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:] for e in logs]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": "load_overlay_from_resource", "args": [], "writes": c["writes"], "changes": changes,
                 "d0": d0, "a7": STACK_TOP - 4}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
