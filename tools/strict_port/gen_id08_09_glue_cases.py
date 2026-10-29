#!/usr/bin/env python3
"""Generate comparison cases for ID09's SysEnvirons fallback and FSOpen glue and ID08's bootstrap
(the Get File dialog and the overlay load) by running the ORIGINAL bytes.

Each segment is loaded at 0x30000 with A5 = 0x20000; low memory (ROMBase, ROM85, HWCfgFlags,
CPUFlag, KbdType, BootDrive, FSFCBLen, SysMap...) is written per case. The parameter-block OS traps
(_Open, _HFSDispatch, _GetVolInfo) are "trap_a0" stand-ins (segment_stubs.a0_trap: D0 and the block
logged, VAR fields written into the block, the flags set from the result); everything else is a
logging stand-in, and ID08's load_overlay_from_resource (0x6, not ported yet) an offset-keyed one
("local" here, "addr" with the offset in the fixture). Each case records the original's entry stack
pointer ("a7"): both glues build their parameter blocks on the stack. test_id08_09_glue.gd replays
both fixtures (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id08_09_glue_cases.py  (writes the two fixture JSONs)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402
from segment_stubs import install  # noqa: E402

CODE_DIR = "sources/resedit-1-0-3/CODE"
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
STACK_TOP, STACK_GUARD = 0x2F000, (0x2E000, 0x2F040)
DATA, ROM, ABUS, LOGS = 0x10000, 0x12000, 0x12100, 0x14000
DIALOG, REC_H, REC = 0x11000, 0x11200, 0x11240


def entries(stubs: list) -> list:
    return [[s[0], s[1], LOGS + 0x200 * i + 4] + s[2:] for i, s in enumerate(stubs)]


ID09_LOGS = entries([["trap_a0", 0xA260, [], False, 0, {"d0": True, "block": 0x1E, "out": [[0x34, 2, 0xFFFF], [0x16, 2, 0x8123]]}, [0]],
                     ["trap_a0", 0xA207, [], False, 0, {"d0": True, "block": 0x1E, "out": [[0x5A, 4, 0x11112222]]}, [0]],
                     ["trap_a0", 0xA000, [], False, 0, {"block": 8, "out": [[0x18, 2, 0x1234]]}, [0]]])
ID08_LOGS = entries([["trap", 0xA97C, [4, 4, 2], True, 4, {}], ["jt", 0x48A, [4], False, 0, {}], ["trap", 0xA873, [4], True, 0, {}],
                     ["trap", 0xA870, [4], True, 0, {"0": ["out", (60 << 16) | 90]}], ["trap", 0xA982, [4], True, 0, {}],
                     ["jt", 0x30A, [4, 4, 4, 2, 4, 4, 4], True, 0,
                      {"0": ["out", [0x01004845, 0x4C4C0007, 0x00000548, 0x454C4C21]], "2": 1}],
                     ["jt", 0x4D2, [4, 4], False, 0, {}], ["local", 0x6, [], False, 0, {}]])


def low(rom8: int = 0, rom9: int = 0, rom85: int = 0x3FFF, hwcfg: int = 0x9000, cpu: int = 2, kbd: int = 0xB, at: int = 0,
        spconfig: int = 1, boot: int = 0xFFFF, fcblen: int = 0x5E) -> list[list[int]]:
    vals = [(0x2AE, 4, ROM), (ROM + 8, 1, rom8), (ROM + 9, 1, rom9), (0x28E, 2, rom85), (0xB22, 2, hwcfg), (0x12F, 1, cpu),
            (0x21E, 1, kbd), (0x291, 1, at), (0x1FB, 1, spconfig), (0x2DC, 4, ABUS), (ABUS + 7, 1, 0x35), (0x210, 2, boot),
            (0x3F6, 2, fcblen), (0xA58, 2, 0x0002)]
    return [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def logs_with(logs: list, key: tuple, results: list) -> list:
    out = copy.deepcopy(logs)
    for e in out:
        if (e[0], e[1]) == key:
            e[7:] = [results]
    return out


def id09_cases() -> list[dict]:
    world = [(4, DATA), (2, 1)]
    out = []
    for name, kw, logs in (("Mac II, HFS", {}, None), ("Plus, MFS", dict(rom85=-1, fcblen=-1, cpu=0, kbd=3, rom8=0), None),
                           ("unknown ROM", dict(rom9=0xFF, kbd=0x55), None), ("ROM version 1", dict(rom8=1, cpu=1, kbd=2), None),
                           ("ROM version 3", dict(rom8=3, cpu=3, kbd=0x13, at=0x80), None),
                           ("SE with FPU flag", dict(rom85=0x7FFF, hwcfg=-0x7000, kbd=1, spconfig=2), None),
                           ("GetFCBInfo fails", {}, logs_with(ID09_LOGS, ("trap_a0", 0xA260), [0xFFFFFFD6])),
                           ("GetVolInfo fails", {}, logs_with(ID09_LOGS, ("trap_a0", 0xA207), [0xFFFFFFC9])),
                           ("OpenWD fails", {}, logs_with(ID09_LOGS, ("trap_a0", 0xA260), [0, 0xFFFFFFCC]))):
        c = {"name": f"SysEnvirons fallback: {name}", "method": "sysenvirons_glue_fallback", "stack": world, "args": [1, DATA],
             "writes": low(**kw) + [[DATA + 4 * k, 4, 0xEEEEEEEE] for k in range(5)]}
        if logs is not None:
            c["call_logs"] = logs
        out.append(c)
    for name, logs in (("FSOpen", None), ("FSOpen fails", logs_with(ID09_LOGS, ("trap_a0", 0xA000), [0xFFFFFFD5]))):
        c = {"name": name, "method": "fsopen_glue", "stack": [(4, DATA + 0x40), (2, 0xFFFE), (4, DATA + 0x80)],
             "args": [DATA + 0x80, 0xFFFE, DATA + 0x40], "writes": [], "d0_mask": 0xFFFF}
        if logs is not None:
            c["call_logs"] = logs
        out.append(c)
    return out


def id08_cases() -> list[dict]:
    common = [[A5 - 0x160C, 4, 0x11300], [A5 - 0x13AC, 4, REC_H], [REC_H, 4, REC], [DIALOG + 0x10, 4, (40 << 16) | 70]]
    good = ID08_LOGS
    cancel = copy.deepcopy(ID08_LOGS)
    cancel[5][6] = {"0": ["out", [0, 0, 0, 0]], "2": 1}
    return [{"name": "bootstrap: file chosen", "method": "bootstrap_window_and_load_overlay", "stack": [], "args": [], "writes": common,
             "call_logs": good},
            {"name": "bootstrap: cancelled", "method": "bootstrap_window_and_load_overlay", "stack": [], "args": [], "writes": common,
             "call_logs": cancel}]


SEGMENTS = {"ID09": ("id09_glue_cases.json", {"sysenvirons_glue_fallback": 0x48, "fsopen_glue": 0x2A6}, ID09_LOGS, id09_cases),
            "ID08": ("id08_bootstrap_cases.json", {"bootstrap_window_and_load_overlay": 0x39C}, ID08_LOGS, id08_cases)}


def run(seg: str, routines: dict, logs: list, c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, f"{CODE_DIR}/{seg}.bin", file_delta=0x7FFFFFFF)
    code = open(f"{CODE_DIR}/{seg}.bin", "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in c.get("call_logs", logs)])
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + routines[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def as_json(logs: list) -> list:
    return [["addr" if e[0] == "local" else e[0]] + e[1:] for e in logs]


def main() -> None:
    for seg, (fixture, routines, logs, build) in SEGMENTS.items():
        base = [[a, 4, 0] for start, end in [(DATA, 0x13000), (LOGS, LOGS + 0x200 * len(logs)), (A5 - 0x2000, A5)]
                for a in range(start, end, 4)]
        out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": STACK_TOP, "stack_guard": list(STACK_GUARD), "common_writes": base,
               "call_logs": as_json(logs), "cases": []}
        for c in build():
            changes, d0 = run(seg, routines, logs, c, base)
            entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                     "a7": STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
            if "call_logs" in c:
                entry["call_logs"] = as_json(c["call_logs"])
            if "d0_mask" in c:
                entry["d0"], entry["d0_mask"] = d0 & c["d0_mask"], c["d0_mask"]
            out["cases"].append(entry)
        Path(f"godot/tests/strict_port/fixtures/{fixture}").write_text(json.dumps(out, separators=(",", ":")) + "\n")
        print(f"{fixture}: {len(out['cases'])} cases")


if __name__ == "__main__":
    main()
