#!/usr/bin/env python3
"""Generate comparison cases for the ID02 C runtime (abs_long .. ansi_strncat) by running the
ORIGINAL bytes.

ID02.bin is loaded at address = file offset with A5 = 0x9000: the ctype table at A5 - 0x1608 is a
seeded pseudo-random table (every class bit pattern occurs), strtok's saved position is A5 -
0x1508. ansi_ldiv reaches ID01 through jump-table slots $5a / $62: ID01.bin is copied to 0x6000
and the slots hold JMP to its rt_sdiv32 / rt_smod32, so the original divide runs too. Arguments
are pushed as the routines read them (MPW C ints are words). Strings and buffers live at 0xa000.
test_id02_crt.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_crt_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_crt_cases.json")
BINARY, ID01 = "sources/resedit-1-0-3/CODE/ID02.bin", "sources/resedit-1-0-3/CODE/ID01.bin"
MEMORY_SIZE, A5, ID01_BASE = 0x10000, 0x9000, 0x6000
STACK_TOP = 0xF000
STACK_GUARD = (0xE000, 0xF040)
DATA = 0xA000                                          # strings / buffers (0xa000..0xc000)
TABLE, STRTOK = A5 - 0x1608, A5 - 0x1508
ROUTINES = {"abs_long": 0x1E, "ansi_div": 0x38, "ansi_ldiv": 0x66, "ansi_isalnum": 0x9A, "ansi_isalpha": 0xB6,
            "ansi_iscntrl": 0xD2, "ansi_isdigit": 0xEE, "ansi_isgraph": 0x10A, "ansi_islower": 0x126, "ansi_isprint": 0x142,
            "ansi_ispunct": 0x15E, "ansi_isspace": 0x17A, "ansi_isupper": 0x196, "ansi_isxdigit": 0x1B2,
            "ansi_toupper": 0x1CE, "ansi_tolower": 0x200, "ansi_memcpy": 0x232, "ansi_memmove": 0x24A, "ansi_memset": 0x2B0,
            "ansi_strcpy": 0x2C8, "ansi_strcat": 0x2D8, "ansi_strcmp": 0x2EE, "ansi_strchr": 0x30C, "ansi_strcspn": 0x324,
            "ansi_strpbrk": 0x33E, "ansi_strrchr": 0x35A, "ansi_strspn": 0x370, "ansi_strstr": 0x38C, "ansi_strtok": 0x3AA,
            "ansi_strncpy": 0x3F6, "ansi_strncat": 0x412}
VOID = {"ansi_div", "ansi_ldiv"}


def table() -> list[int]:
    rng = random.Random(0x1D02)
    return [rng.choice([0, 0x80, 0x40, 0x10, 0x08, 0x04, 0x02, 0x01, 0x30, 0x90, 0xC1, 0xFF, 0x22]) for _ in range(256)]


def common() -> list[list[int]]:
    w = [[TABLE + k, 1, v] for k, v in enumerate(table())]
    w += [[A5 + 0x5A, 2, 0x4EF9], [A5 + 0x5C, 4, ID01_BASE + 0x152], [A5 + 0x62, 2, 0x4EF9], [A5 + 0x64, 4, ID01_BASE + 0x172]]
    return w


def strings(*items: tuple[int, bytes]) -> list[list[int]]:
    return [[addr + k, 1, b] for addr, data in items for k, b in enumerate(data)]


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args], "writes": list(writes)}


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def build() -> list[dict]:
    out = []
    for v in (0, 1, -1, 12345, -12345, 0x7FFFFFFF, -0x80000000):
        out.append(case(f"abs_long {v}", "abs_long", [L(v)], [v]))
    for n, d in ((17, 5), (-17, 5), (17, -5), (-17, -5), (0, 3), (-0x8000, -1), (-0x8000, 1), (0x7FFF, -1), (100, 7)):
        ops = ((n & 0xFFFF) << 16) | (d & 0xFFFF)
        out.append(case(f"div {n} / {d}", "ansi_div", [L(DATA), L(ops)], [DATA, ops]))
    for n, d in ((1000000, 7), (-1000000, 7), (1000000, -7), (-0x80000000, -1), (-0x80000000, 3), (5, 1000000), (0x7FFFFFFF, 0x10000)):
        out.append(case(f"ldiv {n} / {d}", "ansi_ldiv", [L(DATA), L(n), L(d)], [DATA, n, d]))
    for name in ("ansi_isalnum", "ansi_isalpha", "ansi_iscntrl", "ansi_isdigit", "ansi_isgraph", "ansi_islower", "ansi_isprint",
                 "ansi_ispunct", "ansi_isspace", "ansi_isupper", "ansi_isxdigit", "ansi_toupper", "ansi_tolower"):
        for c in list(range(0, 256, 3)) + [0x1241, 0xFF61, 0x0100, 0xFFFF]:
            out.append(case(f"{name} {c:#x}", name, [W(c)], [c]))
    src = DATA + 0x100
    text = b"Hello, strict port world!\x00"
    out += [
        case("memcpy 10", "ansi_memcpy", [L(DATA), L(src), L(10)], [DATA, src, 10], strings((src, text))),
        case("memcpy 0", "ansi_memcpy", [L(DATA), L(src), L(0)], [DATA, src, 0], strings((src, text))),
        case("memmove forward (src above)", "ansi_memmove", [L(src), L(src + 3), L(12)], [src, src + 3, 12], strings((src, text))),
        case("memmove backward (overlap)", "ansi_memmove", [L(src + 3), L(src), L(12)], [src + 3, src, 12], strings((src, text))),
        case("memmove same", "ansi_memmove", [L(src), L(src), L(5)], [src, src, 5], strings((src, text))),
        case("memmove 0", "ansi_memmove", [L(src + 1), L(src), L(0)], [src + 1, src, 0], strings((src, text))),
        case("memset 7 of 0x1a5", "ansi_memset", [L(DATA), W(0x1A5), L(7)], [DATA, 0x1A5, 7]),
        case("memset 0", "ansi_memset", [L(DATA), W(0x33), L(0)], [DATA, 0x33, 0]),
        case("strcpy", "ansi_strcpy", [L(DATA), L(src)], [DATA, src], strings((src, text))),
        case("strcpy empty", "ansi_strcpy", [L(DATA), L(src)], [DATA, src], strings((DATA, b"xyz"), (src, b"\x00"))),
        case("strcat", "ansi_strcat", [L(DATA), L(src)], [DATA, src], strings((DATA, b"abc\x00"), (src, b"def\x00"))),
        case("strcat onto empty", "ansi_strcat", [L(DATA), L(src)], [DATA, src], strings((DATA, b"\x00"), (src, b"q\x00"))),
    ]
    for a, b in ((b"abc", b"abc"), (b"abc", b"abd"), (b"abd", b"abc"), (b"ab", b"abc"), (b"abc", b"ab"), (b"\xe9", b"e"),
                 (b"", b""), (b"", b"a")):
        out.append(case(f"strcmp {a!r} {b!r}", "ansi_strcmp", [L(DATA), L(src)], [DATA, src], strings((DATA, a + b"\x00"), (src, b + b"\x00"))))
    hay = b"the quick brown fox, the end\x00"
    for c in (ord("q"), ord("t"), ord("z"), 0, 0x1265, ord(",")):
        out.append(case(f"strchr {c:#x}", "ansi_strchr", [L(DATA), W(c)], [DATA, c], strings((DATA, hay))))
        out.append(case(f"strrchr {c:#x}", "ansi_strrchr", [L(DATA), W(c)], [DATA, c], strings((DATA, hay))))
    for s in (b"aeiou", b" ,", b"xyz", b"", b"eht"):
        for name in ("ansi_strcspn", "ansi_strpbrk", "ansi_strspn"):
            out.append(case(f"{name} {s!r}", name, [L(DATA), L(src)], [DATA, src], strings((DATA, hay), (src, s + b"\x00"))))
    for needle in (b"quick", b"the end", b"end!", b"", b"t", b"fox,", b"the quick brown fox, the end!"):
        out.append(case(f"strstr {needle!r}", "ansi_strstr", [L(DATA), L(src)], [DATA, src], strings((DATA, hay), (src, needle + b"\x00"))))
    toks = b",,alpha, beta,,gamma \x00"
    out += [
        case("strtok first token", "ansi_strtok", [L(DATA), L(src)], [DATA, src], strings((DATA, toks), (src, b", \x00"))),
        case("strtok continues", "ansi_strtok", [L(0), L(src)], [0, src], strings((DATA, toks), (src, b", \x00")) + [[STRTOK, 4, DATA + 8]]),
        case("strtok last token at the terminator", "ansi_strtok", [L(0), L(src)], [0, src],
             strings((DATA, b"tail\x00"), (src, b",\x00")) + [[STRTOK, 4, DATA]]),
        case("strtok nothing saved", "ansi_strtok", [L(0), L(src)], [0, src], strings((src, b",\x00"))),
        case("strtok only delimiters", "ansi_strtok", [L(DATA), L(src)], [DATA, src], strings((DATA, b",, ,\x00"), (src, b", \x00"))
             + [[STRTOK, 4, 0x1234]]),
        case("strtok empty delimiter set", "ansi_strtok", [L(DATA), L(src)], [DATA, src], strings((DATA, b"a,b\x00"), (src, b"\x00"))),
    ]
    for n in (0, 3, 6, 12):
        out.append(case(f"strncpy {n}", "ansi_strncpy", [L(DATA), L(src)] + [L(n)], [DATA, src, n],
                        strings((DATA, b"ZZZZZZZZZZZZZZZZ"), (src, b"abcde\x00"))))
        out.append(case(f"strncat {n}", "ansi_strncat", [L(DATA), L(src), L(n)], [DATA, src, n],
                        strings((DATA, b"xy\x00ZZZZZZZZZZZZ"), (src, b"abcde\x00"))))
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0)
    emu.mem[ID01_BASE:ID01_BASE + 0x22E] = open(ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(ROUTINES[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_guard": list(STACK_GUARD), "common_writes": base, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] not in VOID:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
