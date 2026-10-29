#!/usr/bin/env python3
"""Generate comparison cases for the trap-free ID05 routines (ansi_rand / ansi_srand, the base-26
codes, overlay poisoning, the challenge table and response check, the code packing helpers) by
running the ORIGINAL bytes.

ID05.bin is loaded at 0x30000 (its code is PC-relative) with A5 = 0x20000. The challenge table
holds four 12-byte records (code pointer, length, three words) whose codes are the key-shifted
letters of known responses; strlen (JT $522) is a logging stand-in returning the length set per
case. test_id05_protection.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id05_protection_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id05_protection_cases.json")
BINARY = "sources/resedit-1-0-3/CODE/ID05.bin"
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
STACK_TOP = 0x2F000
STACK_GUARD = (0x2E000, 0x2F040)
DATA, TABLE, CODES, OVERLAY, OUT = 0x10000, 0x11000, 0x11100, 0x12000, 0x13000
LOGS = 0x14000
CALL_LOGS = [["jt", 0x522, LOGS + 4, [4], False, 0, {}]]
ROUTINES = {"ansi_rand": 0x728, "ansi_srand": 0x746, "encode_base26_6chars": 0x754, "decode_base26_6chars": 0x7A8,
            "poison_overlay_bytes": 0x7F6, "restore_poisoned_overlay_bytes": 0x85E, "init_protection_table": 0x8B8,
            "pick_random_protection_challenge": 0x8D6, "record_code_index_equals": 0x934, "validate_protection_response": 0x964,
            "random_28bit_value": 0xA62, "pack_fields_to_code_buf68": 0xA90, "unpack_fields_from_code": 0xB10,
            "encode_code28_to_buf54": 0xB84, "decode_code_to_long_a": 0xBA8, "encode_long_to_buf40": 0xBC2,
            "decode_code_to_long_b": 0xBDE}
VOID = {"ansi_srand", "decode_base26_6chars", "poison_overlay_bytes", "restore_poisoned_overlay_bytes", "init_protection_table",
        "pick_random_protection_challenge", "unpack_fields_from_code"}
WORD_RESULT = {"record_code_index_equals", "validate_protection_response"}
KEY = [0x13, 0x85, 0x27, 0x9A, 0x61, 0x0C, 0x7E, 0x44, 0xF0, 0x39]
RESPONSES = [b"ALPHA", b"BRAVO7", b"Q", b"DELTAFOX"]


def common() -> list[list[int]]:
    w = [[a, 4, 0] for start, end in [(DATA, OUT + 0x100), (LOGS, LOGS + 0x100), (A5 - 0x100, A5)] for a in range(start, end, 4)]
    w += [[A5 - 0x6C, 4, 12345], [A5 - 0xBA, 4, TABLE], [A5 - 0xB6, 2, len(RESPONSES)]]
    w += [[A5 - 0x2C + k, 1, v] for k, v in enumerate(KEY)]
    for i, resp in enumerate(RESPONSES):
        rec, code = TABLE + 12 * i, CODES + 0x20 * i
        w += [[rec, 4, code], [rec + 4, 2, len(resp)], [rec + 6, 2, 100 + i], [rec + 8, 2, 200 + i], [rec + 10, 2, 300 + i]]
        w += [[code + j, 1, (b + (KEY[j] & 0x7F)) & 0xFF] for j, b in enumerate(resp)]
    w += [[OVERLAY + k, 1, (k * 7) & 0xFF] for k in range(0x100)]
    return w


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def text(s: bytes) -> list[list[int]]:
    return [[DATA + k, 1, b] for k, b in enumerate(s + b"\x00")]


def build() -> list[dict]:
    out = []
    for seed in (12345, 0, 0xFFFFFFFF, 0x80000000):
        out.append(case(f"rand from seed {seed:#x}", "ansi_rand", [], [], [[A5 - 0x6C, 4, seed]]))
    out.append(case("srand", "ansi_srand", [L(0xDEADBEEF)], [0xDEADBEEF]))
    for v in (0, 1, 26, 308915775, 0x7FFFFFFF, -1, -308915776, 123456789):
        out.append(case(f"encode {v}", "encode_base26_6chars", [L(DATA), L(v)], [DATA, v]))
    for s in (b"AAAAAA", b"ZZZZZZ", b"HELLOS", b"abcdef", b"A\x80Z[@A"):
        out.append(case(f"decode {s!r}", "decode_base26_6chars", [L(DATA), L(OUT)], [DATA, OUT], text(s)))
    for size in (0x100, 3, 0x10000):
        out.append(case(f"poison overlay size {size:#x}", "poison_overlay_bytes", [L(OVERLAY), L(size)], [OVERLAY, size]))
    out.append(case("poison with a null base", "poison_overlay_bytes", [L(0), L(0x100)], [0, 0x100]))
    poisoned = [[A5 - 0xB4 + 6 * i, 4, OVERLAY + 5 * i] for i in range(12)] + [[A5 - 0xB4 + 6 * i + 4, 1, 0x40 + i] for i in range(12)]
    out += [
        case("restore: pending word", "restore_poisoned_overlay_bytes", [], [], poisoned + [[A5 - 0xBC, 2, 1]]),
        case("restore: matches recorded", "restore_poisoned_overlay_bytes", [], [], poisoned + [[A5 - 0xC0, 4, 0x10000]]),
        case("restore: nothing pending", "restore_poisoned_overlay_bytes", [], [], poisoned),
        case("init table", "init_protection_table", [L(TABLE), W(7), L(99)], [TABLE, 7, 99]),
    ]
    for seed in (1, 777, 0xABCDEF):
        out.append(case(f"pick challenge seed {seed}", "pick_random_protection_challenge", [L(OUT), L(OUT + 2), L(OUT + 4)],
                        [OUT, OUT + 2, OUT + 4], [[A5 - 0x6C, 4, seed]]))
    for n, b4, b5 in ((45, 2, 5), (44, 2, 5), (-15, -1, 5), (0, 0, 0)):
        out.append(case(f"record index {n}", "record_code_index_equals", [L(n), L(OUT)], [n, OUT], [[OUT + 4, 1, b4], [OUT + 5, 1, b5]]))
    for i, resp in enumerate(RESPONSES):
        out.append(case(f"validate {resp!r}", "validate_protection_response", [W(100 + i), W(200 + i), W(300 + i), L(DATA)],
                        [100 + i, 200 + i, 300 + i, DATA], text(resp) + [[LOGS, 4, len(resp)]]))
    out += [
        case("validate wrong words", "validate_protection_response", [W(100), W(201), W(300), L(DATA)], [100, 201, 300, DATA],
             text(b"ALPHA") + [[LOGS, 4, 5]]),
        case("validate wrong length", "validate_protection_response", [W(100), W(200), W(300), L(DATA)], [100, 200, 300, DATA],
             text(b"ALPHA") + [[LOGS, 4, 6]]),
        case("validate wrong text", "validate_protection_response", [W(100), W(200), W(300), L(DATA)], [100, 200, 300, DATA],
             text(b"ALPHB") + [[LOGS, 4, 5]]),
    ]
    for seed in (5, 0x7FFF0000):
        out.append(case(f"random 28 bits seed {seed:#x}", "random_28bit_value", [], [], [[A5 - 0x6C, 4, seed]]))
    for f, a, b, c, e in ((0x123, 0x400, 0x780, 0x7C, 0x3000), (-1, -0x80, 0x7FFF, -4, -0x200), (0, 0, 0, 0, 0x7FFF), (0x7FF, 0x7F, 0x81, 3, 0x41FF)):
        out.append(case(f"pack {f},{a},{b},{c},{e}", "pack_fields_to_code_buf68", [W(f), W(a), W(b), W(c), W(e)], [f, a, b, c, e]))
    for s in (b"BCDEFG", b"ZZZZZZ", b"AAAAAB"):
        out.append(case(f"unpack {s!r}", "unpack_fields_from_code", [L(DATA)] + [L(OUT + 2 * k) for k in range(5)],
                        [DATA] + [OUT + 2 * k for k in range(5)], text(s)))
        out.append(case(f"decode a {s!r}", "decode_code_to_long_a", [L(DATA)], [DATA], text(s)))
        out.append(case(f"decode b {s!r}", "decode_code_to_long_b", [L(DATA)], [DATA], text(s)))
    for v in (0x12345678, 0xFFFFFFFF, 7):
        out.append(case(f"encode28 {v:#x}", "encode_code28_to_buf54", [L(v)], [v]))
        out.append(case(f"encode long {v:#x}", "encode_long_to_buf40", [L(v)], [v]))
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
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": CALL_LOGS, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] in WORD_RESULT:
            entry["d0"], entry["d0_mask"] = d0 & 0xFFFF, 0xFFFF
        elif c["method"] not in VOID:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
