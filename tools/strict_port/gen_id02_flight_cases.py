#!/usr/bin/env python3
"""Generate comparison cases for run_flight_session (ID02 0x4fc) by running the ORIGINAL bytes.

The set-up is gen_id02_events_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, ID01's switch helpers,
a 1-bit main device; the session, settings, update / activate, redraw and menu routines running for
real) with the overlay's flight hooks (pilot A5 - 0x106e, key A5 - 0x106a, mouse A5 - 0x1086, end
A5 - 0x108e / - 0x108a, step A5 - 0x107a) as "addr" stand-ins, end_overlay_session (0x4a4), the
screen-globals sync (0x4d96) and quit (0x2eaa) as offset-keyed stand-ins. Per case: GetNextEvent's
answers (key events, then the other events of each frame, in call order), the key hook's results
(the flight ends on the first non-zero one), TickCount climbing 4 a call, and JT $da's answer.
Each case records the original's entry stack pointer ("a7"). test_id02_flight.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_flight_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_events_cases as events  # noqa: E402
import gen_id02_memory_cases as memory  # noqa: E402
import gen_id02_session_cases as session  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_flight_cases.json")
A5, D1, WINDOW, event = events.A5, events.D1, session.WINDOW, events.event
events.ROUTINES["run_flight_session"] = 0x4FC
KEY_HOOK, MOUSE_HOOK = ("addr", events.FLIGHT_HOOKS[-0x106A][0]), ("addr", events.FLIGHT_HOOKS[-0x1086][0])
TICKS, CONCLUDE = ("trap", 0xA975), ("jt", 0xDA)
NONE = (event(0), False)
CMD = 0x100


def flight(name: str, keys: list[int], evs: list | None = None, writes: list = (), results: dict | None = None,
           window_up: bool = False) -> dict:
    res = {KEY_HOOK: keys, TICKS: list(range(1000, 1000 + 4 * 400, 4))}
    res.update(results or {})
    up = [] if window_up else [[A5 - 0x14C6, 2, 0]]
    return events.case(f"flight: {name}", "run_flight_session", [], [], D1 + up + list(writes), events=evs or [NONE], results=res)


def cmd_up(ch: int) -> tuple:
    return (event(4, ch, 0, CMD), True)


def build() -> list[dict]:
    return [
        flight("quit at once", [5]),
        flight("three frames, then quit", [0, 0, 5]),
        flight("window already up (updates processed)", [5], [(event(6, WINDOW), True), NONE], window_up=True),
        flight("plain key, then result 7 restarts", [7, 5], [(event(3, 0x61), True), NONE]),
        flight("command keys T, 3, then Q", [0, 0], [cmd_up(0x54), NONE, cmd_up(0x33), NONE, cmd_up(0x51), NONE]),
        flight("command keys S, E, t, 5, q", [0, 0, 0, 0],
               [cmd_up(0x53), NONE, cmd_up(0x45), NONE, cmd_up(0x74), NONE, cmd_up(0x35), NONE, cmd_up(0x71), NONE]),
        flight("command key without a case", [0, 5], [cmd_up(0x5A), NONE, NONE]),
        flight("command key down", [5], [(event(3, 0x51, 0, CMD), True), NONE]),
        flight("update and activate in flight", [0, 5], [NONE, (event(6, WINDOW), True), (event(8, WINDOW, 0, 3), True),
                                                        (event(7), True), NONE]),
        flight("mouse hook asks twice", [0, 0, 6, 5], writes=[[A5 - 0x1030, 2, 1]], results={MOUSE_HOOK: [1]}),
        flight("mouse hook quiet", [0, 5], writes=[[A5 - 0x1030, 2, 1]], results={MOUSE_HOOK: [0]}),
        flight("result 2 restarts", [2, 5]),
        flight("result 4: paused dialog", [4, 5]),
        flight("result 9 restarts at once", [9, 5]),
        flight("result 1 restarts after the hook", [0x101, 5]),
        flight("conclude declines", [8], results={CONCLUDE: [0]}),
        flight("result 3 returns", [3]),
        flight("pilot status changed", [5], writes=[[A5 - 0x12B4, 2, 3], [A5 - 0x13A4, 2, 1]]),
        flight("two-screen flag, mouse moved", [0, 5], writes=[[A5 - 0x12D4, 2, 1], [A5 - 0x1032, 2, 1], [A5 - 0x14F8, 4, 0x00640032]]),
    ]


def main() -> None:
    base = events.common()
    out = {"memory_size": events.MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
           "port_vars": {"code_base": memory.CODE}, "common_writes": base, "call_logs": session.as_json(events.CALL_LOGS),
           "cases": []}
    for c in build():
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"],
                             "changes": events.run(c, base), "a7": memory.STACK_TOP - 4, "call_logs": session.as_json(c["call_logs"])})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
