#!/usr/bin/env python3
"""Generate comparison cases for the ID02 start-up routines (initialize_application, main) by running
the ORIGINAL bytes.

The set-up is gen_id02_events_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, ID01's switch helper,
the display, settings, menu, mission and event routines running for real, a 1-bit main device) in a
larger memory (0x70000, ID01 at 0x6f000) for the extra logs: the Toolbox initialisation traps, the
resource traps (GetResource answering a scripted sequence: MENU 2, 'HEL1' 127, 'HEL1' 128),
SysEnvirons writing its record through an "out" argument, the start-up slots and the menu traps are
logging stand-ins, and the unexported set-up 0x1b42 an offset-keyed stand-in. install_menus,
scan_display_devices, configure_display_from_main_device, copy_pascal_string,
show_resource_file_error_box, start_new_mission and poll_and_dispatch_event run for real.

main never returns: the run stops when its loop comes back to the poll the third time (two passes);
the port gets the same bound as "event_loop_passes" = 2. Each case records the original's entry stack
pointer ("a7"). test_id02_startup.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_startup_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_display_cases as display  # noqa: E402
import gen_id02_events_cases as events  # noqa: E402
import gen_id02_memory_cases as memory  # noqa: E402
import gen_id02_session_cases as session  # noqa: E402
from m68k_emu import Emulator, RETURN_SENTINEL  # noqa: E402
from segment_stubs import install  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_startup_cases.json")
MEMORY_SIZE, ID01_AT = 0x70000, 0x6F000
A5, CODE, LOGS, D1 = memory.A5, memory.CODE, memory.LOGS, events.D1
PASSES, LOOP_POLL = 2, 0x30F0
MENU_H, HEL1_B, SEED = 0x17D80, 0x17D90, 0x0BADCAFE
ENV_COLOUR = [0x00020011, 0x07010003, 0x00010000, 0]       # processor 3 (68020) at +6, hasColorQD at +9
ENV_PLAIN = [0x00020011, 0x06070001, 0x00000000, 0]        # a 68000 without Color QuickDraw
STUBS = events.STUBS + [
    ["jt", 0x222, [], False, 0], ["jt", 0x292, [], False, 0], ["jt", 0x202, [2, 2], True, 0],
    ["jt", 0x592, [], False, 0], ["jt", 0xF2, [], False, 2], ["jt", 0x1F2, [4, 2], True, 2, {0: ["out", ENV_COLOUR]}],
    ["jt", 0x1E2, [], False, 2], ["trap", 0xA994, [], True, 2], ["trap", 0xA86E, [4], True, 0], ["trap", 0xA8FE, [], True, 0],
    ["trap", 0xA912, [], True, 0], ["trap", 0xA930, [], True, 0], ["trap", 0xA9CC, [], True, 0], ["trap", 0xA97B, [4], True, 0],
    ["trap", 0xAA28, [], True, 4], ["trap", 0xA9AB, [4, 2, 4, 4], True, 0],
    ["trap", 0xA9B0, [4], True, 0], ["trap", 0xA9A2, [4], True, 0], ["trap", 0xA9BF, [2], True, 4, {}, [0x17E10, 0x17E20, 0x17E30,
                                                                                                        0x17E40, 0x17E50]],
    ["trap", 0xA935, [2, 4], True, 0], ["trap", 0xA94D, [4, 4], True, 0], ["local", 0x1B42, [], False, 0]]
STUBS = [s for s in STUBS if not (s[0] == "trap" and s[1] == 0xA9A0)] + [
    ["trap", 0xA9A0, [2, 4], True, 4, {}, [memory.ALRT_H]]]
CALL_LOGS = [memory.log_entry(i, s) for i, s in enumerate(STUBS)]
INDEX = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
LOG_OF = {(e[0], e[1]): e[2] for e in CALL_LOGS}
ROUTINES = {"initialize_application": 0x2BBC, "main": 0x309A}
GET_RES, ENVIRONS = ("trap", 0xA9A0), ("jt", 0x1F2)
L = memory.L


def common() -> list[list[int]]:
    w = [x for x in events.common() if x[0] not in (A5 + 0x3C, A5 + 0x34) and not (LOGS <= x[0] < LOGS + 0x400 * len(events.STUBS))]
    w += [[A5 + 0x3C, 4, ID01_AT + 0xBE], [A5 + 0x34, 4, ID01_AT + 0xAA]] + [[a, 4, 0] for a in range(LOGS, LOGS + 0x400 * len(STUBS), 4)]
    old = {(e[0], e[1]): e[2] for e in events.CALL_LOGS}
    moved = {old[k] - 4: LOG_OF[k] - 4 for k in old if k in LOG_OF}          # the default results move with their logs
    defaults = [[moved[x[0]], x[1], x[2]] for x in events.common() if x[0] in moved and x[2]]
    vals = [(LOG_OF[("trap", 0xAA28)] - 4, 4, SEED), (LOG_OF[("jt", 0xF2)] - 4, 4, 1), (LOG_OF[("jt", 0x1E2)] - 4, 4, 0),
            (LOG_OF[("trap", 0xA994)] - 4, 4, 0x2A), (A5 - 0x14CA, 4, session.WINDOW)]
    vals += [(A5 - 0xC78 + k, 1, b) for k, b in enumerate(b"\x06Pilot!")] + [(A5 - 0xC90 + k, 1, b) for k, b in enumerate(b"\x03Opt")]
    vals += [(A5 - 0xC66 + k, 1, b) for k, b in enumerate(b"\x03Map")] + [(HEL1_B, 4, HEL1_B + 0x10)]
    return w + defaults + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, method: str, writes: list = (), resources: list | None = None, env: list | None = None,
         results: dict | None = None) -> dict:
    c = memory.case(name, method, [], [], D1 + list(writes))
    logs = copy.deepcopy(CALL_LOGS)
    logs[INDEX[GET_RES]][7:] = [resources or [MENU_H, display.SET_H, HEL1_B]]
    if env is not None:
        logs[INDEX[ENVIRONS]][6] = {0: ["out", env]}
    for key, r in (results or {}).items():
        logs[INDEX[key]][7:] = [r]
    c["call_logs"] = logs
    return c


def build() -> list[dict]:
    ia = "initialize_application"
    return [case("init: colour, resources present", ia),
            case("init: 68000 without colour", ia, env=ENV_PLAIN),
            case("init: settings resources missing", ia, resources=[MENU_H, 0, 0]),
            case("init: MENU missing", ia, resources=[0, display.SET_H, HEL1_B]),
            case("init: system check fails", ia, results={("jt", 0xF2): [0]}),
            case("main: two passes", "main"),
            case("main: a mission at once", "main", results={("jt", 0x1E2): [1]}),
            case("main: flag on a 2-bit screen (no game)", "main", [[display.DEVS[1] + 0x90 + 0x20, 2, 2]],
                 results={("jt", 0x1E2): [1]})]


def run(c: dict, base: list[list[int]]) -> list[list[int]]:
    emu = Emulator(MEMORY_SIZE, memory.BINARY, file_delta=0x7FFFFFFF)
    code = open(memory.BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    emu.mem[ID01_AT:ID01_AT + 0x22E] = open(display.ID01, "rb").read()[:0x22E]
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    install(emu, A5, [["addr", CODE + e[1]] + e[2:] if e[0] == "local" else e for e in c["call_logs"]])
    before = bytes(emu.mem)
    emu.a[7] = memory.STACK_TOP
    emu.push(RETURN_SENTINEL)
    emu.pc = CODE + ROUTINES[c["method"]]
    arrivals, steps = 0, 0
    while emu.pc != RETURN_SENTINEL:
        if emu.pc == CODE + LOOP_POLL:
            arrivals += 1
            if arrivals > PASSES:
                break
        if emu.pc in emu.stubs:
            ret = emu.pop()
            emu.d[0] = emu.stubs[emu.pc](emu) & 0xFFFFFFFF
            emu.pc = ret
            continue
        emu.step()
        steps += 1
        assert steps < 20_000_000, "step limit"
    return [[a, emu.mem[a]] for a in range(MEMORY_SIZE)
            if not (memory.STACK_GUARD[0] <= a < memory.STACK_GUARD[1]) and emu.mem[a] != before[a]]


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
           "port_vars": {"code_base": CODE, "event_loop_passes": PASSES}, "common_writes": base,
           "call_logs": session.as_json(CALL_LOGS), "cases": []}
    for c in build():
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"],
                             "changes": run(c, base), "a7": memory.STACK_TOP - 4, "call_logs": session.as_json(c["call_logs"])})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
