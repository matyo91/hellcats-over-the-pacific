#!/usr/bin/env python3
"""Generate comparison cases for the small segments ID07 (the STR# 129 string table), ID08
(sysbeep_and_exit_to_shell, alloc_and_read_resource_payload) and ID09 (swapmmumode_glue,
length_prefixed_bytes_to_c_string_in_place) by running the ORIGINAL bytes.

Each segment is loaded at 0x30000 with A5 = 0x20000. ID07 calls ID01's dense switch helper (JT
$3a, reading the inline table after its call) and ID02's memmove (JT $4fa) for real: ID01.bin and
ID02.bin are copied in and the slots hold JMPs to them. Toolbox calls are logging stand-ins on
both sides (segment_stubs.py): GetResource returns a prepared STR# 129 (escapes, "\\p" strings,
empty strings); GetFPos / GetEOF write their VAR results into the caller's frame; SwapMMUMode is
an OS trap on D0. test_id07_09.gd replays the three fixtures (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id07_09_cases.py  (writes the three fixture JSONs)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

CODE_DIR = "sources/resedit-1-0-3/CODE"
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
ID01_AT, ID02_AT = 0x34000, 0x35000
STACK_TOP = 0x2F000
STACK_GUARD = (0x2E000, 0x2F040)
DATA, HANDLE, LOGS = 0x10000, 0x18000, 0x19000


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


def str129(strings: list[bytes]) -> list[list[int]]:
    """STR# 129 at DATA (count word, then Pascal strings) behind the handle at HANDLE."""
    blob = len(strings).to_bytes(2, "big") + b"".join(bytes([len(s)]) + s for s in strings)
    return [[HANDLE, 4, DATA]] + [[DATA + k, 1, b] for k, b in enumerate(blob)]


def strings(variant: int) -> list[bytes]:
    out = []
    for i in range(120):
        kind = (i + variant) % 6
        if kind == 0:
            out.append(b"Plain string %d" % i)
        elif kind == 1:
            out.append(b"Line\\rbreak\\tand tab %d" % i)
        elif kind == 2:
            out.append(b"\\pPascal\\r %d" % i)
        elif kind == 3:
            out.append(b"")
        elif kind == 4:
            out.append(b"back\\slash\\q\\" if i % 2 else b"\\")
        else:
            out.append(b"\\p")
    return out


SEGMENTS = {
    "ID07": {
        "logs": [["trap", 0xA9A0, LOGS + 4, [2, 4], True, 4, {}], ["jt", 0x272, LOGS + 0x104, [4], True, 0, {}]],
        "routines": {"load_str129_string_table": 0x6, "init_string_pointer_groups": 0x190},
        "void": {"load_str129_string_table", "init_string_pointer_groups"},
        "common": [[LOGS, 4, HANDLE]],
        "cases": [case(f"{m}, layout {v}", m, [], [], str129(strings(v)))
                  for v in range(3) for m in ("load_str129_string_table", "init_string_pointer_groups")],
    },
    "ID08": {
        "logs": [["trap", 0xA9C8, LOGS + 4, [2], True, 0, {}], ["trap", 0xA9F4, LOGS + 0x104, [], True, 0, {}],
                 ["jt", 0x2CA, LOGS + 0x204, [4, 2], True, 2, {"0": ["out", 0x100]}],
                 ["jt", 0x2C2, LOGS + 0x304, [4, 2], True, 2, {"0": ["out", 0x1234]}], ["jt", 0x22A, LOGS + 0x404, [4], True, 4, {}],
                 ["jt", 0x2B2, LOGS + 0x504, [4, 4, 2], True, 2, {"1": 1}]],
        "routines": {"sysbeep_and_exit_to_shell": 0x338, "alloc_and_read_resource_payload": 0x348},
        "void": {"sysbeep_and_exit_to_shell"},
        "word": {"alloc_and_read_resource_payload"},
        "common": [[LOGS + 0x400, 4, 0x15000], [LOGS + 0x500, 4, 0xFFDB]],
        "cases": [case("beep and exit", "sysbeep_and_exit_to_shell", [], []),
                  case("read payload from ref 3", "alloc_and_read_resource_payload", [W(3)], [3]),
                  case("read payload, NewPtr fails", "alloc_and_read_resource_payload", [W(-7)], [-7], [[LOGS + 0x400, 4, 0]])],
    },
    "ID09": {
        "logs": [["trap_d0", 0xA05D, LOGS + 4, [1], True, 0, {}, [0x00000001, 0x12345600]]],
        "routines": {"swapmmumode_glue": 0x3C2, "length_prefixed_bytes_to_c_string_in_place": 0x432},
        "void": {"swapmmumode_glue"},
        "common": [],
        "cases": [case("swap MMU mode 32-bit", "swapmmumode_glue", [L(DATA)], [DATA], [[DATA, 1, 1]]),
                  case("swap MMU mode 24-bit", "swapmmumode_glue", [L(DATA)], [DATA], [[DATA, 1, 0], [LOGS + 4, 4, 1]])]
                 + [case(f"Pascal to C {s!r}", "length_prefixed_bytes_to_c_string_in_place", [L(DATA)], [DATA],
                         [[DATA + k, 1, b] for k, b in enumerate(bytes([len(s)]) + s + b"\xEE")])
                    for s in (b"", b"a", b"Hello, world", bytes(range(1, 255)))],
    },
}


def run(seg: str, spec: dict, c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, f"{CODE_DIR}/{seg}.bin", file_delta=0x7FFFFFFF)
    code = open(f"{CODE_DIR}/{seg}.bin", "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    if seg == "ID07":
        emu.mem[ID01_AT:ID01_AT + 0x22E] = open(f"{CODE_DIR}/ID01.bin", "rb").read()[:0x22E]
        id02 = open(f"{CODE_DIR}/ID02.bin", "rb").read()
        emu.mem[ID02_AT:ID02_AT + len(id02)] = id02
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [[e[0], e[1], e[2], e[3], e[4], e[5], {int(k): v for k, v in e[6].items()}] + e[7:] for e in spec["logs"]])
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + spec["routines"][c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    for seg, spec in SEGMENTS.items():
        base = [[a, 4, 0] for start, end in [(DATA, DATA + 0x2000), (HANDLE, HANDLE + 0x10), (LOGS, LOGS + 0x600),
                                             (A5 - 0x2300, A5)] for a in range(start, end, 4)] + spec["common"]
        if seg == "ID07":
            base += [[A5 + 0x3A, 2, 0x4EF9], [A5 + 0x3C, 4, ID01_AT + 0xBE], [A5 + 0x4FA, 2, 0x4EF9], [A5 + 0x4FC, 4, ID02_AT + 0x24A]]
        out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
               "call_logs": spec["logs"], "cases": []}
        for c in spec["cases"]:
            changes, d0 = run(seg, spec, c, base)
            entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
            if c["method"] in spec.get("word", ()):
                entry["d0"], entry["d0_mask"] = d0 & 0xFFFF, 0xFFFF
            elif c["method"] not in spec["void"]:
                entry["d0"] = d0
            out["cases"].append(entry)
        Path(f"godot/tests/strict_port/fixtures/{seg.lower()}_cases.json").write_text(json.dumps(out, separators=(",", ":")) + "\n")
        print(f"{seg}: {len(out['cases'])} cases")


if __name__ == "__main__":
    main()
