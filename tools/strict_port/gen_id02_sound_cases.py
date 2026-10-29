#!/usr/bin/env python3
"""Generate comparison cases for the ID02 sound system routines (the three VBL sound handlers and
init_sound_system) by running the ORIGINAL bytes.

The set-up is gen_id02_session_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, CurrentA5 = A5,
SoundBase = 0x12000, SndNewChannel and SndDisposeChannel logged) with two sample buffers, channel 0
and 1 nodes in the channel records and the previous sound hook (A5 - 0xc36) an "addr" stand-in: a
handler returns through it. The handlers keep their A5 in a long inside their own code (0x39c4 /
0x3aca / 0x3be0): a case writes it there (or leaves it 0 to see the first call record it), and the
port gets the code base as "code_base". shutdown_sound, clear_sound_buffer_to_silence and
alloc_sound_buffer_node run for real. Each case records the original's entry stack pointer ("a7").
test_id02_sound.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_sound_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_memory_cases as memory  # noqa: E402
import gen_id02_session_cases as session  # noqa: E402
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_sound_cases.json")
A5, CODE, LOGS = memory.A5, memory.CODE, memory.LOGS
CHAIN, SAMPLE0, SAMPLE1 = 0x3AB00, 0x18000, 0x19000
STUBS = session.STUBS + [["addr", CHAIN, [], False, 0]]
CALL_LOGS = [memory.log_entry(i, s) for i, s in enumerate(STUBS)]
INDEX = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"vbl_sound_handler_ch0_unrolled": 0x39A8, "vbl_sound_handler_ch0_variant": 0x3AAE,
            "vbl_sound_handler_two_channel": 0x3BC4, "init_sound_system": 0x3DD0}
SLOTS = {"vbl_sound_handler_ch0_unrolled": 0x39C4, "vbl_sound_handler_ch0_variant": 0x3ACA,
         "vbl_sound_handler_two_channel": 0x3BE0}
REC0, REC1 = A5 - 0x7D0, A5 - 0x598
L = memory.L


def node(rec: int, i: int) -> int:
    return rec + 8 + 0x1C * i


def set_node(at: int, pos: int, frac: int, sample: int, loop: int, end: int, nxt: int) -> list:
    return [[at, 4, pos], [at + 4, 4, frac], [at + 8, 4, sample], [at + 0xC, 4, loop], [at + 0x10, 4, end], [at + 0x18, 4, nxt]]


def rate(step: int, frac: int, span: int) -> list:
    return [[A5 - 0xC32, 4, step], [A5 - 0xC2E, 4, frac], [A5 - 0xC2A, 4, span]]


def common() -> list[list[int]]:
    w = session.common() + [[a, 4, 0] for a in range(LOGS + 0x400 * len(session.STUBS), LOGS + 0x400 * len(STUBS), 4)]
    vals = [(A5 - 0xC36, 4, CHAIN), (A5 - 0x360, 4, 0x33AAE), (A5 - 0x35C, 4, 0x33BC4), (A5 - 0x352, 2, 0),
            (LOG_OF[("trap", 0xA807)] - 4, 4, 0)]
    for k in range(0, 0x800, 4):
        vals.append((SAMPLE0 + k, 4, int.from_bytes(bytes(((k + j) * 7 + 3) & 0xFF for j in range(4)), "big")))
        vals.append((SAMPLE1 + k, 4, int.from_bytes(bytes(((k + j) * 13 + 1) & 0xFF for j in range(4)), "big")))
    w += [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]
    w += set_node(node(REC0, 0), 0x10, 0, SAMPLE0, 0x40, 0x600, node(REC0, 1))
    w += set_node(node(REC0, 1), 0x40, 0, SAMPLE0, 0x40, 0x300, node(REC0, 1))
    w += set_node(node(REC1, 0), 0x20, 0, SAMPLE1, 0x80, 0x700, node(REC1, 1))
    w += set_node(node(REC1, 1), 0, 0, A5 - 0xC26, 0, 0x172, node(REC1, 1))
    w += [[REC0, 4, node(REC0, 0)], [REC1, 4, node(REC1, 0)]] + rate(1, 0, 0x172)
    return w


def case(name: str, method: str, stack: list, args: list[int], writes: list = (), results: dict | None = None) -> dict:
    primed = [[CODE + SLOTS[method], 4, A5]] if method in SLOTS and "first call" not in name else []
    c = memory.case(name, method, stack, args, primed + list(writes))
    if results:
        logs = copy.deepcopy(CALL_LOGS)
        for key, r in results.items():
            logs[INDEX[key]][7:] = [r]
        c["call_logs"] = logs
    return c


def build() -> list[dict]:
    out = []
    near_end = [[node(REC0, 0), 4, 0x590]]
    variants = (("rate 1.0", []), ("rate 0.5", rate(0, 0x80000000, 0xB9)), ("rate 1.5", rate(1, 0x80000000, 0x22B)),
                ("near the node's end", near_end), ("near the end at rate 1.5", near_end + rate(1, 0x80000000, 0x22B)),
                ("odd position", [[node(REC0, 0), 4, 0x11]]), ("fraction carried", [[node(REC0, 0) + 4, 4, 0xC0000000]] +
                                                               rate(0, 0x60000000, 0x8A)))
    for method in SLOTS:
        out.append(case(f"{method}: first call", method, [], []))
        for name, w in variants:
            out.append(case(f"{method}: {name}", method, [], [], w))
    two = "vbl_sound_handler_two_channel"
    out += [case(f"{two}: channel 1 reaches the silence node", two, [], [], [[node(REC1, 0), 4, 0x600]]),
            case(f"{two}: channel 1 loops", two, [], [], [[node(REC1, 0), 4, 0x600], [node(REC1, 0) + 0x18, 4, node(REC1, 2)]] +
                 set_node(node(REC1, 2), 0, 0, SAMPLE1, 0x100, 0x400, node(REC1, 2)))]
    init = "init_sound_system"
    out += [case("init: ready, flag 1", init, [L(1)], [1], [[A5 - 0xC38, 2, 1]]),
            case("init: not ready, flag 0", init, [L(0)], [0], [[A5 - 0xC38, 2, 0]]),
            case("init: handlers already primed", init, [L(0)], [0], [[A5 - 0xC38, 2, 0], [A5 - 0x352, 2, 1]]),
            case("init: SndNewChannel fails", init, [L(1)], [1], [[A5 - 0xC38, 2, 0]], {("trap", 0xA807): [0xFF9C]})]
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(memory.MEMORY_SIZE, memory.BINARY, file_delta=0x7FFFFFFF)
    code = open(memory.BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, c.get("call_logs", CALL_LOGS))
    a7 = memory.STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return [[a, emu.mem[a]] for a in range(memory.MEMORY_SIZE)
            if not (memory.STACK_GUARD[0] <= a < memory.STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF


def main() -> None:
    base = common()
    out = {"memory_size": memory.MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
           "port_vars": {"code_base": CODE}, "common_writes": base, "call_logs": session.as_json(CALL_LOGS), "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                 "a7": memory.STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if c["method"] == "init_sound_system":
            entry["d0"] = d0
        if "call_logs" in c:
            entry["call_logs"] = session.as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
