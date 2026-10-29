#!/usr/bin/env python3
"""Generate comparison cases for the rest of ID05 (template centring, the screen fingerprint, the
'DATA' / 'TEXT' 128 pairs, the code dialog's filter, the upper-cased item text and the protection
dialog itself) by running the ORIGINAL bytes.

The set-up is gen_id05_protection_cases.py's (ID05.bin at 0x30000, A5 = 0x20000, the challenge
table of four records whose codes are the key-shifted letters of known responses) with every trap
and slot a logging stand-in on both sides (segment_stubs.py). One handle answers every
GetResource (a rect / pair record); GetIText writes the texts of an "outseq" list call by call (C
strings, as JT $2fa is a stand-in) and ModalDialog's item hits another. The response that passes is
the one for the record ansi_rand picks from the seed. The code-string builder (0x3ba, not exported)
is an offset-keyed stand-in. Each case records the original's entry stack pointer ("a7").
test_id05_dialog.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id05_dialog_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id05_protection_cases as base_set  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id05_dialog_cases.json")
BINARY, MEMORY_SIZE, CODE, A5 = base_set.BINARY, base_set.MEMORY_SIZE, base_set.CODE, base_set.A5
STACK_TOP, STACK_GUARD, DATA = base_set.STACK_TOP, base_set.STACK_GUARD, base_set.DATA
LOGS = 0x14000
RES_H, RES, DEVICE, GD, PMAP_H, PMAP, DIALOG, HANDLE = 0x13200, 0x13240, 0x13280, 0x132C0, 0x13300, 0x13340, 0x13400, 0x13480
BOX = [(30 << 16) | 40, (50 << 16) | 240]
EVENT, HIT, OUTS = 0x13500, 0x13520, 0x13540


def environs(machine: int, color: int) -> dict:
    return {0: ["out", [(1 << 16) | machine, 3, color << 16, 0]]}


def texts(strings: list[bytes]) -> dict:
    """GetIText's C strings, one per call (padded to 12 bytes: three longs)."""
    return {0: ["outseq", [[int.from_bytes((s + bytes(12))[4 * k:4 * k + 4], "big") for k in range(3)] for s in strings]]}


def hits(items: list[int]) -> dict:
    return {0: ["outseq", items, 2]}


STUBS = [["trap", 0xA9A0, [2, 4], True, 4], ["jt", 0x20A, [], True, 2], ["jt", 0x1F2, [4, 2], True, 2, environs(5, 1)],
         ["trap", 0xAA32, [], True, 4], ["jt", 0x28A, [4], True, 0], ["jt", 0x282, [4], True, 0], ["trap", 0xA9A3, [4], True, 0],
         ["trap", 0xA9AA, [4], True, 0], ["trap", 0xA9B0, [4], True, 0], ["trap", 0xA873, [4], True, 0],
         ["trap", 0xA874, [4], True, 0, {0: ["out", 0x13600]}], ["trap", 0xA850, [], True, 0],
         ["trap", 0xA98D, [4, 4, 4, 2, 4], True, 0, {0: ["out", BOX], 1: ["out", HANDLE, 4], 2: ["out", 4, 2]}],
         ["trap", 0xA990, [4, 4], True, 0, texts([b"HELLO"])], ["trap", 0xA89B, [2, 2], True, 0],
         ["trap", 0xA8A9, [2, 2, 4], True, 0, {2: 2}], ["trap", 0xA8B0, [2, 2, 4], True, 0, {2: 2}], ["trap", 0xA95D, [2, 4], True, 0],
         ["trap", 0xA97C, [4, 4, 2], True, 4], ["trap", 0xA9F4, [], True, 0], ["trap", 0xA915, [4], True, 0],
         ["trap", 0xA98B, [4, 4, 4, 4], True, 0], ["trap", 0xA981, [4], True, 0], ["trap", 0xA991, [4, 4], True, 0, hits([1])],
         ["trap", 0xA985, [4, 2], True, 2], ["trap", 0xA983, [4], True, 0], ["jt", 0x2FA, [4], False, 0], ["jt", 0x302, [4], False, 0],
         ["jt", 0x4E2, [2], False, 0, {}, [0x41, 0x42, 0x43, 0x44, 0x45, 0x46]], ["jt", 0x2F2, [4, 4], True, 0],
         ["jt", 0x522, [4], False, 0], ["local", 0x3BA, [4, 4, 4, 4], False, 0]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], s[5] if len(s) > 5 else {}] + s[6:] for i, s in enumerate(STUBS)]
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"center_template_rect_on_screen": 0x6, "get_machine_screen_fingerprint": 0xC8, "read_DATA128_pair": 0x160,
            "write_DATA128_pair": 0x1BC, "read_TEXT128_pair": 0x214, "write_TEXT128_pair": 0x270, "code_dialog_filter": 0x2C8,
            "get_dialog_item_text_upper": 0x4E4, "run_protection_dialog": 0x560}
LONG_RESULT = {"code_dialog_filter", "get_dialog_item_text_upper"}


def picked_record(seed: int) -> int:
    seed = (seed * 0x41C64E6D + 0x3039) & 0xFFFFFFFF
    return ((seed >> 16) & 0x7FFF) % len(base_set.RESPONSES)


def logs_with(changes: dict) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for e in logs:
        if (e[0], e[1]) in changes:
            e[6] = changes[(e[0], e[1])]
    return logs


def common() -> list[list[int]]:
    w = [x for x in base_set.common() if not (base_set.LOGS <= x[0] < base_set.LOGS + 0x100)]
    w += [[a, 4, 0] for start, end in [(0x13000, 0x13700), (LOGS, LOGS + 0x200 * len(STUBS)), (A5 - 0x1700, A5 - 0x100)]
          for a in range(start, end, 4)]
    right = base_set.RESPONSES[picked_record(12345)]
    vals = [(LOG_OF[("trap", 0xA9A0)] - 4, 4, RES_H), (RES_H, 4, RES), (RES, 4, (100 << 16) | 50), (RES + 4, 4, (300 << 16) | 450),
            (LOG_OF[("jt", 0x20A)] - 4, 4, 20), (A5 - 0x167A, 2, 640), (A5 - 0x167C, 2, 480), (A5 - 0x167E, 2, 0), (A5 - 0x1680, 2, 0),
            (LOG_OF[("trap", 0xAA32)] - 4, 4, DEVICE), (DEVICE, 4, GD), (GD + 0x16, 4, PMAP_H), (PMAP_H, 4, PMAP),
            (PMAP + 0xA, 2, 0x280), (PMAP + 0xC, 2, 0x1E0), (PMAP + 0x20, 2, 8), (LOG_OF[("trap", 0xA97C)] - 4, 4, DIALOG),
            (LOG_OF[("jt", 0x302)] - 4, 4, 0x13680), (LOG_OF[("jt", 0x522)] - 4, 4, len(right))]
    vals += [(A5 - 0x1608 + c, 1, 0x80) for c in range(0x61, 0x7B)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, stack: list, port_args: list[int], writes: list[list[int]] = (), changes: dict | None = None) -> dict:
    c = {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
         "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}
    if changes:
        c["call_logs"] = logs_with(changes)
    return c


L, W = base_set.L, base_set.W


def build() -> list[dict]:
    out = [case("centre the template", "center_template_rect_on_screen", [L(0x444C4F47), W(0x3E8)], [0x444C4F47, 0x3E8]),
           case("centre: wide template", "center_template_rect_on_screen", [L(0x414C5254), W(7)], [0x414C5254, 7],
                [[RES, 4, (10 << 16) | 0], [RES + 4, 4, (470 << 16) | 700]]),
           case("centre: no template", "center_template_rect_on_screen", [L(0x444C4F47), W(1)], [0x444C4F47, 1],
                [[LOG_OF[("trap", 0xA9A0)] - 4, 4, 0]])]
    outs = [L(OUTS + 2 * k) for k in range(5)]
    args = [OUTS + 2 * k for k in range(5)]
    out += [case("fingerprint: colour", "get_machine_screen_fingerprint", outs, args),
            case("fingerprint: black and white", "get_machine_screen_fingerprint", outs, args, changes={("jt", 0x1F2): environs(2, 0)})]
    for kind in ("DATA", "TEXT"):
        out += [case(f"read {kind} pair", f"read_{kind}128_pair", [L(OUTS), L(OUTS + 4)], [OUTS, OUTS + 4]),
                case(f"read {kind} pair: missing", f"read_{kind}128_pair", [L(OUTS), L(OUTS + 4)], [OUTS, OUTS + 4],
                     [[LOG_OF[("trap", 0xA9A0)] - 4, 4, 0], [OUTS, 4, 0x1234]]),
                case(f"write {kind} pair", f"write_{kind}128_pair", [L(0xCAFEBABE), L(42)], [0xCAFEBABE, 42]),
                case(f"write {kind} pair: missing", f"write_{kind}128_pair", [L(1), L(2)], [1, 2], [[LOG_OF[("trap", 0xA9A0)] - 4, 4, 0]])]
    flt = [L(HIT), L(EVENT), L(DIALOG)]
    for label, writes, changes in (("first call, text", [[EVENT, 2, 1]], None),
                                   ("first call, empty", [[EVENT, 2, 1]], {("trap", 0xA990): texts([b""])}),
                                   ("Return", [[EVENT, 2, 3], [EVENT + 5, 1, 13], [A5 - 0x2CA, 2, 4]], None),
                                   ("Enter (auto-key)", [[EVENT, 2, 5], [EVENT + 5, 1, 3], [A5 - 0x2CA, 2, 1]], None),
                                   ("Escape", [[EVENT, 2, 3], [EVENT + 5, 1, 0x1B], [A5 - 0x2CA, 2, 1]], None),
                                   ("other key", [[EVENT, 2, 3], [EVENT + 5, 1, 0x41], [A5 - 0x2CA, 2, 1]], None),
                                   ("mouse, armed", [[EVENT, 2, 1], [A5 - 0x2CA, 2, 9]], None)):
        out.append(case(f"code filter: {label}", "code_dialog_filter", flt, [DIALOG, EVENT, HIT], writes, changes))
    out += [case("item text upper-cased", "get_dialog_item_text_upper", [L(DIALOG), W(3)], [DIALOG, 3],
                 changes={("trap", 0xA990): texts([b"mixedCase9z"])}),
            case("item text already upper", "get_dialog_item_text_upper", [L(DIALOG), W(4)], [DIALOG, 4])]
    right = base_set.RESPONSES[picked_record(12345)]
    run = [L(OUTS), L(OUTS + 4)]
    out += [case("protection: already matching", "run_protection_dialog", run, [OUTS, OUTS + 4], [[OUTS, 4, 0]]),
            case("protection: right first time, stored", "run_protection_dialog", run, [OUTS, OUTS + 4], [[OUTS, 4, 7], [OUTS + 4, 4, 9]],
                 {("trap", 0xA990): texts([b"AAAAAA", right])}),
            case("protection: wrong then right", "run_protection_dialog", run, [OUTS, OUTS + 4], [[OUTS, 4, 7]],
                 {("trap", 0xA990): texts([b"BAAAAA", b"NOPE", b"NOPE", b"BAAAAA", right]), ("trap", 0xA991): hits([3, 1])}),
            case("protection: quit pressed, then right", "run_protection_dialog", run, [OUTS, OUTS + 4], [[OUTS, 4, 7]],
                 {("trap", 0xA990): texts([b"ZZZZZZ", right]), ("trap", 0xA991): hits([2, 1])}),
            case("protection: no dialog", "run_protection_dialog", run, [OUTS, OUTS + 4], [[OUTS, 4, 7], [LOG_OF[("trap", 0xA97C)] - 4, 4, 0]],
                 {("trap", 0xA990): texts([b"AAAAAA", right])})]
    return out


def run_case(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in c.get("call_logs", CALL_LOGS)])
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def as_json(logs: list) -> list:
    return [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in logs]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
           "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        changes, d0 = run_case(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                 "a7": STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if "call_logs" in c:
            entry["call_logs"] = as_json(c["call_logs"])
        if c["method"] in LONG_RESULT:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
