#!/usr/bin/env python3
"""Generate comparison cases for prepare_instrument_panel (ID03 0x5cc4) by running the ORIGINAL
bytes.

The set-up is gen_id03_remap_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID01 and ID02 behind
their slots, a "Bitmap Cache" of four entries and small panel and gyro bitmaps seeded) with the
Resource Manager, region and handle calls as logging stand-ins; the panel-coordinate slots answer
fixed values so the panel stays a few pixels across; the bitmap release helper (0x59f4, not
exported) is an offset-keyed stand-in; every stand-in keeps a digest log. Every instrument runs for
real on the redraw path. Each case
records the original's entry stack pointer ("a7"). test_id03_prepare.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_prepare_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_helpers_cases as helpers  # noqa: E402
import gen_id03_remap_cases as remap  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_prepare_cases.json")
A5, LOGS = helpers.A5, helpers.LOGS
N_BEFORE = len(remap.STUBS)
CACHE_H, HANDLES = remap.SCENERY_H, [0x13A00, 0x13B00, 0x13A00, 0x13B00]
STUBS = remap.STUBS + [["trap", 0xA862, [4], True, 0], ["trap", 0xA994, [], True, 2, {}, [5]], ["trap", 0xA998, [2], True, 0],
                       ["trap", 0xA8D6, [4, 4], True, 0], ["trap", 0xA8D3, [4], True, 0], ["trap", 0xA983, [4], True, 0],
                       ["jt", 0x24A, [4], True, 4, {}, [0x13A00]], ["jt", 0x252, [4], True, 4, {}, [0x13B00, 0x13B00, 0x13E40]],
                       ["jt", 0x49A, [], False, 0], ["jt", 0x3BA, [], False, 0], ["local", 0x59F4, [], False, 0]]
CALL_LOGS = [[s[0], s[1], LOGS + 0x200 * i + 4, s[2], s[3], s[4], {**(s[5] if len(s) > 5 else {}), -1: "digest"}] + s[6:]
             for i, s in enumerate(STUBS)]  # the whole panel calls each stand-in hundreds of times: digest logs throughout
INDEX = {(e[0], e[1]): i for i, e in enumerate(CALL_LOGS)}
ROUTINES = {"prepare_instrument_panel": 0x5CC4}


def logs_with(changes: dict) -> list:
    logs = copy.deepcopy(CALL_LOGS)
    for key, results in changes.items():
        logs[INDEX[key]][7:] = [results]
    return logs


def common() -> list[list[int]]:
    w = [x for x in remap.common() if not (LOGS <= x[0] < LOGS + 0x200 * N_BEFORE)]
    w += [[a, 4, 0] for a in range(LOGS, LOGS + 0x200 * len(STUBS), 4)]
    vals = [(A5 - 0x1372, 2, 0x30), (A5 - 0x1370, 2, 0x10), (A5 - 0x137E, 2, 0x50), (A5 - 0x137C, 2, 0x60), (A5 - 0x1002, 2, 9),
            (A5 - 0x1066, 4, helpers.SIN), (A5 - 0x1062, 4, helpers.COS), (A5 - 0x1496, 4, 0x13D00), (A5 - 0x11CC, 4, 0x13D80),
            (A5 - 0x13B6, 4, 0x13DC0), (A5 - 0xDFA, 4, 0x11E00), (0x13E40, 4, 0x13E60), (CALL_LOGS[INDEX[("jt", 0x49A)]][2] - 4, 4, 0x13E80)]
    rec = remap.SCENERY + 0x160 * 2
    vals += [(rec, 2, 4), (rec + 6, 2, 0x30), (rec + 8, 2, 0x10), (rec + 0xA, 2, 0x8018), (rec + 0xE, 4, 7)]
    vals += [(remap.SCENERY + 0x160 * k + 0xE, 4, [3, 9, 7, 2][k]) for k in (0, 1, 3)]
    return w + [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def case(name: str, writes: list[list[int]], results: dict) -> dict:
    fixed = {("jt", 0x3CA): [12], ("jt", 0x382): [10]}
    fixed.update(results)
    c = helpers.case(name, "prepare_instrument_panel", [], [], writes)
    c["call_logs"] = logs_with(fixed)
    return c


def build() -> list[dict]:
    one = remap.SCENERY + 0x160
    cache = ("trap", 0xA9A0)
    return [case("current entry", [], {cache: [CACHE_H]}),
            case("stored entry loaded", [[A5 - 0x13AE, 2, 0], [one, 2, 4], [one + 2, 2, 0x50], [one + 4, 2, 0x60], [one + 6, 2, 0x30],
                                         [one + 8, 2, 0x10], [one + 0xA, 2, 0x8018], [one + 0xC, 2, 1]],
                 {cache: [CACHE_H, 0x13B00, 0x13B00, 0x13E40, 0x13A00]}),
            case("redraw at depth 4", [[remap.SCENERY + 0x160 * 2, 2, 8]], {cache: [CACHE_H]}),
            case("redraw at depth 1, no cache", [[A5 - 0x137A, 2, 1]], {cache: [0], ("jt", 0x252): [CACHE_H, 0x13B00, 0x13B00, 0x13E40]})]


def main() -> None:
    base = common()
    helpers.STUBS, helpers.ROUTINES = STUBS, ROUTINES
    as_json = lambda logs: [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5],  # noqa: E731
                             {str(i): n for i, n in e[6].items()}] + e[7:] for e in logs]
    out = {"memory_size": helpers.MEMORY_SIZE, "a5": A5, "stack_top": helpers.STACK_TOP, "stack_guard": list(helpers.STACK_GUARD),
           "common_writes": base, "call_logs": as_json(CALL_LOGS), "cases": []}
    for c in build():
        helpers.CALL_LOGS = c["call_logs"]
        changes, _ = helpers.run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                             "call_logs": as_json(c["call_logs"]), "a7": helpers.STACK_TOP - 4})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
