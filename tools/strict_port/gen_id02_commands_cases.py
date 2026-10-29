#!/usr/bin/env python3
"""Generate comparison cases for the ID02 menu routines (do_menu_command, start_new_mission) by running
the ORIGINAL bytes.

The set-up is gen_id02_events_cases.py's (ID02.bin at 0x30000, A5 = 0x20000, ID01's switch helper,
the display, settings and redraw routines running for real, a 1-bit main device) with HiWord /
LoWord scripted per case to pick the menu and item. The File / Apple / Edit slots, the overlay's
mission hook (A5 - 0x109a) and GetPort / GetItem ("out" results), OpenDeskAcc, SystemEdit and SysBeep
are logging stand-ins; the unexported settings save (0x2da0) and quit (0x2eaa) are offset-keyed stand-ins;
run_flight_session runs for real (its key hook answers 5 at once: quit). set_view_size_option, start_new_mission and
apply_settings_to_live_options run for real. Each case records the original's entry stack pointer
("a7"). test_id02_commands.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_commands_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id02_events_cases as events  # noqa: E402
import gen_id02_memory_cases as memory  # noqa: E402
import gen_id02_session_cases as session  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_commands_cases.json")
A5, D1, L, W = events.A5, events.D1, events.L, events.W
events.ROUTINES.update({"do_menu_command": 0x36A2, "start_new_mission": 0x35E4})
HI, LO = ("trap", 0xA86A), ("trap", 0xA86B)
COUNTERS = [[A5 - 0x13A2 + 2 * i, 2, 0x100 + i] for i in range(12)] + [[A5 - 0x12CE + 2 * i, 2, 0x200 + i] for i in range(12)]
COUNTERS += [[A5 + off, 2, 7] for off in (-0x12B4, -0x12B6, -0x12B2, -0x14C4, -0x14C2, -0x14C0, -0x12F0)]


def menu(menu_id: int, item: int, writes: list = (), results: dict | None = None, note: str = "") -> dict:
    res = {HI: [menu_id], LO: [item]}
    res.update(results or {})
    return events.case(f"menu {menu_id} item {item}" + (f" ({note})" if note else ""), "do_menu_command",
                       [L((menu_id << 16) | item)], [(menu_id << 16) | item], D1 + list(writes), results=res)


def build() -> list[dict]:
    out = [menu(1, 1), menu(1, 3)]
    out += [menu(2, i) for i in range(1, 14)]
    out += [menu(2, 9, results={("jt", 0x13A): [0]}, note="kept open"), menu(2, 4, COUNTERS, note="counters set"),
            menu(2, 4, results={("jt", 0x82): [0]}, note="check declines")]
    out += [menu(3, 2), menu(3, 4, results={("trap", 0xA9C2): [0x100]}, note="taken by a desk accessory")]
    out += [menu(4, i) for i in range(1, 11)]
    out += [menu(5, i) for i in range(1, 12)]
    out += [menu(0, 1), menu(6, 2)]
    sm = "start_new_mission"
    out += [events.case("mission: started", sm, [], [], D1 + COUNTERS),
            events.case("mission: not ready", sm, [], [], D1 + COUNTERS, results={("jt", 0x132): [0]}),
            events.case("mission: check declines", sm, [], [], D1 + COUNTERS, results={("jt", 0x82): [0]}),
            events.case("mission: window down", sm, [], [], D1 + COUNTERS + [[A5 - 0x14C6, 2, 0]]),
            events.case("mission: no game", sm, [], [], D1 + COUNTERS + [[A5 - 0x12F8, 2, 0xFFFE]])]
    return out


def main() -> None:
    base = events.common()
    out = {"memory_size": events.MEMORY_SIZE, "a5": A5, "stack_top": memory.STACK_TOP, "stack_guard": list(memory.STACK_GUARD),
           "port_vars": {"code_base": memory.CODE}, "common_writes": base, "call_logs": session.as_json(events.CALL_LOGS), "cases": []}
    for c in build():
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": events.run(c, base),
                 "a7": memory.STACK_TOP - sum(size for size, _ in c["stack"]) - 4}
        if "call_logs" in c:
            entry["call_logs"] = session.as_json(c["call_logs"])
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
