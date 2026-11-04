#!/usr/bin/env python3
"""Generate comparison cases for routines the game runtime writes outside the 740
(godot/hellcats/runtime/unexported.gd, overlay_loader.gd) by running their ORIGINAL bytes on the
68000 interpreter (tools/strict_port/m68k_emu.py), as the strict port's own cases are made.

Covered: ID02 0x3e8 ansi_strlen and 0x434 ansi_strncmp (strings at 0xa000 / 0xb000), 0x95a /
0x9fa lock / unlock_session_handles, 0x2da0 save_changed_settings, 0x4d96 restore_screen_globals, 0x4d24 apply_display_palettes, 0x1b42
install_overlay_service_table, 0xa26 redraw_panel_readouts_locked, 0x4a4 end_overlay_session (FreeMem and NewPtrClear answered by stubs);
ID03 0x59f4 release_panel_bitmaps; ID04 0x432 report_panel_store_failure, 0x1b8 install_default_ring_item and 0x2dc
set_radio_group_selection (GetDItem / SetDItem / SetCtlValue as stub layouts), 0x1752
track_summary_text_click (the Control Manager and TextEdit traps likewise), 0x1b3e draw_rank_insignia, 0x1dde draw_mission_awards,
0x3976 run_map_dialog, 0x3614 track_map_bearing_and_distance, 0xe70 run_refuel_dialog, 0xc02 run_scenario_selection_dialog, 0x644 run_duty_roster_dialog, 0x137a run_high_scores_dialog 0x2104 mission_summary_filter_proc and 0x21d6 advance_mission_summary_text; ID02 0x2eaa quit_application (ID01's switch helpers behind $2a / $32 /
$3a); ID05 0x8b2 arm_restore_gate and 0x3ba build_protection_code_strings; ID06 0xee (the grey map
pointer) and 0x858 release_render_buffers; the overlay's 0x15134 carrier_deck_contact (a carrier with a deck and a wire zone, the
player over, beside or above them), 0x4b0 player_left_ground_zone (the player pointer 0x1b738, its controller
at 0x20000 and object at 0x20800) and 0x16208 (the 1-bit erase hook) and 0xd23a redraw_view_readouts (its callees stubbed). A CODE segment is loaded at
its file offsets, the Pacific Conflict image at its runtime addresses (file offset - 0x20); A5 is
the runtime's own (0xc0000), so A5 globals sit where the runtime keeps them, and the jump-table
slots a routine calls (HLock $272 / HUnlock $27a) and the Toolbox traps (ChangedResource,
WriteResource, SetGDevice) are stubs that pop their Pascal argument and do nothing else. Each case gives the
memory it starts from, the D0 the original returns and the memory it leaves at the addresses it
lists; godot/tests/runtime/test_unexported_routines.gd replays them on the runtime's routines.

Usage: python3 tools/hellcats/gen_runtime_cases.py [--check]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "strict_port"))
from m68k_emu import Emulator  # noqa: E402

FIXTURE = ROOT / "godot" / "tests" / "runtime" / "fixtures" / "unexported_cases.json"
ID02 = ROOT / "sources" / "resedit-1-0-3" / "CODE" / "ID02.bin"
OVERLAY = ROOT / "godot" / "hellcats" / "data" / "scenery" / "Pacific Conflict"
STACK_TOP = 0x2F000
A5 = 0x0C0000                  # MacMachine.A5
MEMORY = 0xD0000
CODE = ROOT / "sources" / "resedit-1-0-3" / "CODE"
STR_A, STR_B = 0xA000, 0xB000
PLAYER, CTL, OBJ = 0x1B738, 0x20000, 0x20800


def cstr(addr: int, data: bytes) -> list[list[int]]:
    return [[addr + k, 1, b] for k, b in enumerate(data + b"\0")]


def strlen_cases() -> list[dict]:
    out = []
    for text in (b"", b"a", b"POW!", b"Well bud, looks like you bought the farm on that one!", bytes(range(1, 256))):
        out.append({"name": f"strlen {len(text)}", "routine": "id02_03e8", "segment": "ID02", "address": 0x3E8,
                    "args": [STR_A], "writes": cstr(STR_A, text)})
    return out


def strncmp_cases() -> list[dict]:
    pairs = [(b"Lucky Lindy", b"Lucky Lindy", 30), (b"Lucky Lindy", b"Lucky Lindy", 0), (b"abc", b"abd", 3),
             (b"abd", b"abc", 3), (b"abc", b"abd", 2), (b"abc", b"abcdef", 30), (b"abcdef", b"abc", 30),
             (b"\x80bc", b"\x7fbc", 3), (b"\x7fbc", b"\x80bc", 3), (b"", b"", 5), (b"", b"x", 5), (b"Zed", b"zed", 3)]
    out = []
    for a, b, n in pairs:
        out.append({"name": f"strncmp {a!r} {b!r} {n}", "routine": "id02_0434", "segment": "ID02", "address": 0x434,
                    "args": [STR_A, STR_B, n], "writes": cstr(STR_A, a) + cstr(STR_B, b)})
    return out


def ground_zone_cases() -> list[dict]:
    out = [{"name": "no player", "routine": "_04b0", "segment": "overlay", "address": 0x4B0, "args": [],
            "writes": [[PLAYER, 4, 0]]}]
    for y, ground in ((692, 625), (625 + 4999, 625), (625 + 5000, 625), (100000, 0), (-50000, 625), (0x7FFFFFF0, -100)):
        out.append({"name": f"y {y} ground {ground}", "routine": "_04b0", "segment": "overlay", "address": 0x4B0,
                    "args": [], "writes": [[PLAYER, 4, CTL], [CTL, 4, OBJ], [CTL + 0x2E, 4, ground & 0xFFFFFFFF],
                                           [OBJ + 0x1C, 4, y & 0xFFFFFFFF]]})
    return out


def g(offset: int) -> int:
    return A5 + offset


def gate_cases() -> list[dict]:
    return [{"name": f"arm_restore_gate from {v}", "routine": "id05_08b2", "segment": "ID05", "address": 0x8B2,
             "args": [], "writes": [[g(-0xBC), 2, v]], "check": [[g(-0xBC), 2]], "void": True} for v in (0, 1, 0x7FFF, 0xFFFF)]


def grey_map_cases() -> list[dict]:
    return [{"name": f"grey map {v:#x}", "routine": "id06_00ee", "segment": "ID06", "address": 0xEE, "args": [],
             "writes": [[g(-0x1EDE), 4, v]]} for v in (0, 0x123456, 0xFFFFFFFF)]


def erase_hook_cases() -> list[dict]:
    return [{"name": f"1-bit erase hook from {v:#x}", "routine": "_16208", "segment": "overlay", "address": 0x16208,
             "args": [], "writes": [[0x1DA8C, 2, v], [0x1DA8E, 2, 0x5A5A]], "check": [[0x1DA8C, 4]], "void": True}
            for v in (0, 1, 0xFFFF)]


HANDLES = [-0x11F6, -0x11DC, -0x11D4, -0x12B0]
KEPT = [-0x11F2, -0x11D8, -0x11D0, -0x12AC]


def session_cases() -> list[dict]:
    out = []
    for depth in (0, 1, 2):
        for flag in (0, 1):
            writes = [[g(-0x14F4), 2, depth], [g(-0x1348), 2, flag]]
            for k, h in enumerate(HANDLES):
                master = 0x30000 + 0x10 * k
                writes += [[g(h), 4, master], [master, 4, 0xFF000000 | (0x123450 + 0x100 * k)], [g(KEPT[k]), 4, 0xDEADBEEF]]
            check = [[g(-0x14F4), 2]] + [[g(a), 4] for a in KEPT]
            out.append({"name": f"lock_session_handles depth {depth} flag {flag}", "routine": "id02_095a", "segment": "ID02",
                        "address": 0x95A, "args": [], "writes": writes, "check": check, "void": True, "stubs": [0x272, 0x27A]})
            if depth > 0 and flag == 0:
                out.append({"name": f"unlock_session_handles depth {depth}", "routine": "id02_09fa", "segment": "ID02",
                            "address": 0x9FA, "args": [], "writes": writes, "check": [[g(-0x14F4), 2]], "void": True,
                            "stubs": [0x272, 0x27A]})
    return out


def _pascal_pop_4(emu) -> int:
    """HLock / HUnlock through the ID09 glue are Pascal: the callee pops its 4-byte handle."""
    emu.a[7] = (emu.a[7] + 4) & 0xFFFFFFFF
    return 0


def settings_save_cases() -> list[dict]:
    return [{"name": f"save_changed_settings flag {f}", "routine": "id02_2da0", "segment": "ID02", "address": 0x2DA0,
             "args": [], "writes": [[g(-0x138A), 2, f], [g(-0x13AC), 4, 0]], "check": [[g(-0x138A), 2]], "void": True,
             "traps": {0xA9AA: 4, 0xA9B0: 4}} for f in (0, 1, 0x8000)]


def screen_globals_cases() -> list[dict]:
    writes = [[g(-0x1036), 4, 0], [g(-0x1346), 4, 0x700000], [g(-0x134A), 2, 0x8280], [g(-0x1348), 2, 1],
              [g(-0x1382), 4, 0x11111111], [g(-0x1378), 2, 0x2222], [g(-0x1312), 2, 0x3333]]
    return [{"name": "restore_screen_globals", "routine": "id02_4d96", "segment": "ID02", "address": 0x4D96, "args": [],
             "writes": writes, "check": [[g(-0x1382), 4], [g(-0x1378), 2], [g(-0x1312), 2]], "void": True,
             "traps": {0xAA31: 4}}]


# The carrier (object, controller, faces, vertices), the player and its contact record, in free
# memory above the image's BSS; the deck (tag 1) and the arresting-wire zone (tag 3) are squares.
CARRIER, CCTL, FACES, IDX, VERTS = 0x28000, 0x28100, 0x28200, 0x28300, 0x28400
POBJ, PCTL, PDEF, CONTACT, PAIRS = 0x28600, 0x28700, 0x28800, 0x28900, 0x28A00


def carrier_writes(px: int, pz: int, angle: int = 0, kind: int = 1, replay: int = 0, shift: int = 0,
                   cached: bool = False, deck_y: int = 625) -> list[list[int]]:
    w = [[CARRIER + 8, 4, CCTL], [CARRIER + 0x48, 4, FACES], [CARRIER + 0x3A, 2, 2], [CARRIER + 0x44, 4, VERTS],
         [CARRIER + 0x34, 2, shift], [CCTL + 0x20, 2, angle & 0xFFFF],
         [CCTL + 0x50, 2, 0 if cached else 0xFFFF], [CCTL + 0x52, 2, 1 if cached else 0xFFFF],
         [CCTL + 0x54, 2, 0x111 if cached else 0]]
    for f, (tag, surface, first) in enumerate(((1, 0x60, 1), (3, 0x30, 5))):
        face = FACES + 0x20 * f
        w += [[face + 0x14, 2, 4], [face + 0x16, 1, surface], [face + 0x17, 1, tag], [face + 0x18, 4, IDX + 0x10 * f]]
        w += [[IDX + 0x10 * f + 2 * k, 2, first + k] for k in range(4)]
    squares = {1: (2000, deck_y), 5: (300, deck_y)}
    for first, (half, y) in squares.items():
        for k, (sx, sz) in enumerate(((-1, -1), (1, -1), (1, 1), (-1, 1))):
            v = VERTS + 12 * (first + k)
            w += [[v, 4, (sx * half) & 0xFFFFFFFF], [v + 4, 4, y], [v + 8, 4, (sz * half) & 0xFFFFFFFF]]
    w += [[POBJ + 8, 4, PCTL], [POBJ + 0x18, 4, px & 0xFFFFFFFF], [POBJ + 0x20, 4, pz & 0xFFFFFFFF],
          [PCTL + 4, 4, PDEF], [PDEF, 2, kind], [PCTL + 0x2E, 4, 0x7777], [PCTL + 0x2C, 1, 0x11], [PCTL + 0x63F, 1, 0],
          [CONTACT, 4, POBJ], [CONTACT + 4, 4, CARRIER], [CONTACT + 0xC, 2, 0], [CONTACT + 0xE, 2, 0],
          [0x1B870, 2, replay], [0x1B85A, 2, 4], [0x1B85C, 2, 0], [0x1B860, 4, PAIRS], [PAIRS, 4, 0], [PAIRS + 4, 4, 0]]
    return w


def carrier_cases() -> list[dict]:
    check = [[CCTL + 0x50, 2], [CCTL + 0x52, 2], [CCTL + 0x54, 2], [PCTL + 0x2E, 4], [PCTL + 0x2C, 1],
             [PCTL + 0x63F, 1], [0x1B85C, 2], [PAIRS, 4], [PAIRS + 4, 4]]
    variants = [("over the deck", dict(px=1000, pz=-1500)), ("over the wire zone", dict(px=0, pz=0)),
                ("off the deck", dict(px=5000, pz=5000)), ("heeled over", dict(px=1000, pz=-1500, angle=0x1000)),
                ("in a replay", dict(px=1000, pz=-1500, replay=1)), ("a big type over the wires", dict(px=0, pz=0, kind=5)),
                ("deck shift 2", dict(px=1000, pz=-1500, shift=2)), ("faces cached", dict(px=1000, pz=-1500, cached=True)),
                ("deck below zero", dict(px=1000, pz=-1500, deck_y=-40))]
    return [{"name": f"carrier_deck_contact {name}", "routine": "_15134", "segment": "overlay", "address": 0x15134,
             "args": [CARRIER, POBJ, CONTACT], "writes": carrier_writes(**kw), "check": check, "void": True,
             "image": True} for name, kw in variants]


SERVICE_SLOTS = [-0x1122, -0x111A, -0x111E, -0x1116, -0x1112, -0x10F2, -0x10EE, -0x10EA, -0x1106, -0x10FE, -0x1102,
                 -0x10FA, -0x10F6, -0x110E, -0x110A, -0x10DE, -0x10DA, -0x10D6, -0x10D2, -0x10CE, -0x10CA, -0x10C6,
                 -0x1310, -0x130C, -0x1308, -0x1304, -0x10C2, -0x10BE, -0x10BA, -0x10B6, -0x10B2, -0x10AE, -0x10AA,
                 -0x10A6, -0x10E6, -0x10E2]


def service_table_cases() -> list[dict]:
    """The table's 34 slots (and the two it leaves, -0x10e6 / -0x10e2), each primed with a marker."""
    writes = [[g(a), 4, 0xA5A5A5A5] for a in SERVICE_SLOTS]
    return [{"name": f"install_overlay_service_table FreeMem {free:#x}", "routine": "id02_1b42", "segment": "ID02",
             "address": 0x1B42, "args": [], "writes": writes, "check": [[g(a), 4] for a in SERVICE_SLOTS],
             "void": True, "pascal": {"0x212": [0, free], "0x232": [4, 0x55550000]}} for free in (0x200000, 0x80000)]


PANEL_HANDLES = [-0x11F6, -0x11DC, -0x11D4, -0x12B0]


def panel_release_cases() -> list[dict]:
    """The four panel handles (some null), released by ReleaseResource when the scenery record
    (*(A5 - 0x13b2) + 0x160 * A5 - 0x211e) has its word +0xc set, else by DisposeHandle."""
    out = []
    records, master = 0x29000, 0x29800
    for stored in (0, 1):
        for present in ((1, 1, 1, 1), (1, 0, 1, 0), (0, 0, 0, 0)):
            writes = [[g(-0x13B2), 4, master], [master, 4, records], [g(-0x211E), 2, 2],
                      [records + 0x160 * 2 + 0xC, 2, stored]]
            writes += [[g(h), 4, (0x2A000 + 0x10 * k) if on else 0] for k, (h, on) in enumerate(zip(PANEL_HANDLES, present))]
            out.append({"name": f"release_panel_bitmaps stored {stored} handles {''.join(map(str, present))}",
                        "routine": "id03_59f4", "segment": "ID03", "address": 0x59F4, "args": [], "writes": writes,
                        "check": [[g(h), 4] for h in PANEL_HANDLES], "void": True,
                        "traps": {0xA9A3: 4}, "pascal": {"0x25a": [4, None]}, "log_calls": True})
    return out


def store_failure_cases() -> list[dict]:
    """report_panel_store_failure: with the flag A5 - 0x14a0 set, JT $462 then JT $4ba (the caution
    alert, the message at *(A5 - 0xf42) and 0), the flag cleared. The two calls are stubbed alike
    on both sides (the real ones open an alert)."""
    return [{"name": f"report_panel_store_failure flag {f}", "routine": "id04_0432", "segment": "ID04", "address": 0x432,
             "args": [], "writes": [[g(-0x14A0), 2, f], [g(-0xF42), 4, 0x2B000]], "check": [[g(-0x14A0), 2]], "void": True,
             "c_stubs": {"0x462": [[], 0], "0x4ba": [[4, 2], 0]}, "log_calls": True} for f in (0, 1)]


RENDER_SLOTS = [-0x1EDA, -0x1EDE, -0x1CD6, -0x1CD2, -0x1CCE]


def render_buffers_cases() -> list[dict]:
    """release_render_buffers: the pattern tables (A5 - 0x1eda / - 0x1ede), the edge pool (- 0x1cd6),
    the row table (- 0x1cd2, its blocks at +4 / +0x1c / +0x20) and the raster target (- 0x1cce), some
    null, each aligned block's allocation (*(block - 8)) given to DisposPtr (JT $23a, Pascal, a stub
    logging it) and each pointer cleared."""
    out = []
    for present in ((1, 1, 1, 1, 1), (0, 1, 0, 1, 0), (1, 0, 1, 0, 1), (0, 0, 0, 0, 0)):
        for rows in ((1, 1, 1), (1, 0, 1)):
            writes = []
            for k, (slot, on) in enumerate(zip(RENDER_SLOTS, present)):
                block = 0x2D000 + 0x100 * k
                writes += [[g(slot), 4, block if on else 0], [block - 8, 4, 0x2E000 + 0x10 * k]]
            for j, (off, on) in enumerate(zip((4, 0x1C, 0x20), rows)):
                block = 0x2D800 + 0x100 * j
                writes += [[0x2D300 + off, 4, block if on else 0], [block - 8, 4, 0x2E800 + 0x10 * j]]
            out.append({"name": f"release_render_buffers {''.join(map(str, present))} rows {''.join(map(str, rows))}",
                        "routine": "id06_0858", "segment": "ID06", "address": 0x858, "args": [], "writes": writes,
                        "check": [[g(slot), 4] for slot in RENDER_SLOTS], "void": True,
                        "pascal": {"0x23a": [4, None]}, "log_calls": True})
    return out


HOOK = 0x2C000       # a code address the overlay hook pointers are set to: a stub on both sides


def session_hook_cases() -> list[dict]:
    """redraw_panel_readouts_locked and end_overlay_session: the overlay hook (A5 - 0x1072 /
    - 0x1076) at the stub HOOK, the session handles locked / unlocked around it (HLock / HUnlock
    logged with the handles), the sound off and its twenty slots empty (release_sound_slots then
    calls nothing), DrawMenuBar when the bar was hidden (A5 - 0x1028)."""
    def handles(set_: bool, depth: int) -> list[list[int]]:
        w = [[g(-0x14F4), 2, depth], [g(-0x1348), 2, 0]]
        for k, h in enumerate(HANDLES):
            w += [[g(h), 4, (0x30000 + 0x10 * k) if set_ else 0], [0x30000 + 0x10 * k, 4, 0x123450 + 0x100 * k]]
        return w
    out = []
    for set_ in (True, False):
        out.append({"name": f"redraw_panel_readouts_locked handles {'set' if set_ else 'null'}", "routine": "id02_0a26",
                    "segment": "ID02", "address": 0xA26, "args": [], "void": True, "log_calls": True,
                    "writes": handles(set_, 0) + [[g(-0x1072), 4, HOOK]], "check": [[g(-0x14F4), 2]],
                    "code_stubs": [f"{HOOK:#x}"], "pascal": {"0x272": [4, None], "0x27a": [4, None]}})
    for bar in (0, 1):
        out.append({"name": f"end_overlay_session menu bar hidden {bar}", "routine": "id02_04a4", "segment": "ID02",
                    "address": 0x4A4, "args": [], "void": True, "log_calls": True,
                    "writes": handles(True, 1) + [[g(-0x1076), 4, HOOK], [g(-0x12EE), 2, 0], [g(-0x1028), 2, bar]]
                    + [[g(-0xD62) + 4 * k, 4, 0] for k in range(20)],
                    "check": [[g(-0x14F4), 2]], "code_stubs": [f"{HOOK:#x}"], "traps": {0xA937: 0},
                    "pascal": {"0x272": [4, None], "0x27a": [4, None]}})
    return out


# Dialog Manager traps as layouts: the argument sizes from A7 up (the order the runtime's trap
# argument lists have too), the arguments logged, the pointers whose longs are logged, the VAR
# outputs written (a value per call, the last repeating). A stub on both sides: the real traps
# need a real dialog.
GET_DITEM = {"sizes": [4, 4, 4, 2, 4], "log": [4, 3]}          # box, VAR h, VAR type, item, dialog
SET_DITEM = {"sizes": [4, 4, 2, 2, 4], "log": [4, 3, 2, 1], "deref": {"0": 2}}   # box, h, type, item, dialog
SET_CTL_VALUE = {"sizes": [2, 4], "log": [1, 0]}               # value, control
DIALOG = 0x2C100


def dialog_item_cases() -> list[dict]:
    out = []
    get = dict(GET_DITEM, outs={"2": [2, [0x0080]], "1": [4, [0x11111111]], "0": [8, [[0x00100020, 0x00300040]]]})
    for item, default in ((2, 1), (9, 3)):
        out.append({"name": f"install_default_ring_item item {item} default {default}", "routine": "id04_01b8",
                    "segment": "ID04", "address": 0x1B8, "args": [DIALOG, item, default], "arg_sizes": [4, 2, 2], "void": True, "log_calls": True,
                    "writes": [[g(-0x225E), 2, 0x7777]], "check": [[g(-0x225E), 2]],
                    "trap_specs": {"0xa98d": get, "0xa98e": SET_DITEM}})
    items = 0x2B100
    get = dict(GET_DITEM, outs={"1": [4, [0x1000, 0x2000, 0x3000]]})
    for selected in (4, 5, 6, 7, 3):
        out.append({"name": f"set_radio_group_selection {selected} of 4..6", "routine": "id04_02dc", "segment": "ID04",
                    "address": 0x2DC, "args": [DIALOG, items, 3, selected], "arg_sizes": [4, 4, 2, 2], "void": True, "log_calls": True,
                    "writes": [[items, 2, 4], [items + 2, 2, 5], [items + 4, 2, 6]],
                    "trap_specs": {"0xa98d": get, "0xa963": SET_CTL_VALUE}})
    return out


def click_cases() -> list[dict]:
    """track_summary_text_click: GetPort / SetPort / GlobalToLocal, FindControl at the event's
    where; on the scroll bar (A5 - 0x2236) TrackControl, the thumb (129) without an action and then
    sync_text_scroll_to_control (GetCtlValue, TEScroll when the text must move), other parts with
    the action at slot $16a; 1 then, 0 otherwise."""
    event, bar, other, te_h, te = 0x2C800, 0x2C700, 0x2C780, 0x2C600, 0x2C500
    writes = [[event + 0xA, 4, 0x00500060], [g(-0x2236), 4, bar], [g(-0x223A), 4, te_h], [te_h, 4, te],
              [te, 2, 10], [te + 8, 2, 42], [te + 0x18, 2, 16]]
    out = []
    for name, part, ctl, value in (("nothing hit", 0, 0, 0), ("another control", 20, other, 0),
                                   ("the bar's arrow", 20, bar, 0), ("the thumb, text to move", 129, bar, 1),
                                   ("the thumb, text in place", 129, bar, 2)):
        specs = {"0xa874": {"sizes": [4], "outs": {"0": [4, [0x2C900]]}},
                 "0xa873": {"sizes": [4], "log": [0]},
                 "0xa871": {"sizes": [4], "deref": {"0": 1}},
                 "0xa96c": {"sizes": [4, 4, 4], "log": [1, 2], "outs": {"0": [4, [ctl]]}, "result": [2, [part]]},
                 "0xa968": {"sizes": [4, 4, 4], "log": [0, 1, 2], "result": [2, [part]]},
                 "0xa960": {"sizes": [4], "log": [0], "result": [2, [value]]},
                 "0xa9dd": {"sizes": [4, 2, 2], "log": [0, 1, 2]}}
        out.append({"name": f"track_summary_text_click {name}", "routine": "id04_1752", "segment": "ID04",
                    "address": 0x1752, "args": [DIALOG, event], "d0_size": 2, "log_calls": True, "writes": writes,
                    "trap_specs": specs})
    return out


ID01_BASE = 0xB0000          # ID01's runtime helpers (the switch dispatchers behind $2a / $32 / $3a)


def quit_cases() -> list[dict]:
    """quit_application: confirm_end_mission ($13a) must answer 2; with changed settings
    ask_save_changes ($ba) is asked: 1 saves (save_changed_settings), 2 cancels, others go on; the
    game window hidden when shown (A5 - 0x14c6), then ExitToShell. Both questions, HideWindow and
    ExitToShell are stubs (ExitToShell returns here)."""
    out = []
    window = 0x2CA00
    for confirm, changed, answer, shown in ((0, 1, 1, 1), (2, 0, 0, 1), (2, 1, 1, 1), (2, 1, 2, 1), (2, 1, 3, 0)):
        specs = {"0xa916": {"sizes": [4], "log": [0]}, "0xa9f4": {"sizes": []},
                 "0xa9aa": {"sizes": [4], "log": [0]}, "0xa9b0": {"sizes": [4], "log": [0]}}
        out.append({"name": f"quit_application confirm {confirm} changed {changed} answer {answer} shown {shown}",
                    "routine": "id02_2eaa", "segment": "ID02", "address": 0x2EAA, "args": [], "void": True,
                    "log_calls": True, "id01": True,
                    "writes": [[g(-0x138A), 2, changed], [g(-0x14C6), 2, shown], [g(-0x14CA), 4, window],
                               [g(-0x13AC), 4, 0x2CB00]],
                    "check": [[g(-0x138A), 2]], "c_stubs": {"0x13a": [[], confirm], "0xba": [[], answer]},
                    "trap_specs": specs})
    return out


def rank_insignia_cases() -> list[dict]:
    """draw_rank_insignia (a Pascal user item): the pilot's rank (roster record +0x22) gives
    GetCIcon(256 + rank); the item's box keeps its top and right and takes the icon's size from
    its PixMap bounds (+6); PlotCIcon there, DisposCIcon."""
    out = []
    roster_h, records, icon_h, icon = 0x2CC00, 0x2D000, 0x2CD00, 0x2CE00
    for rank, pilot in ((0, 0), (3, 2), (5, 7)):
        writes = [[g(-0x13A8), 4, roster_h], [roster_h, 4, records], [g(-0x13A4), 2, pilot],
                  [records + 64 * pilot + 0x22, 2, rank], [icon_h, 4, icon], [icon + 6, 4, 0x00000000],
                  [icon + 10, 4, 0x00200020 + 0x10000 * rank]]
        specs = {"0xa98d": dict(GET_DITEM, outs={"0": [8, [[0x0004011E, 0x0024013E]]]}),
                 "0xaa1e": {"sizes": [2], "log": [0], "result": [4, [icon_h]]},
                 "0xaa1f": {"sizes": [4, 4], "log": [0], "deref": {"1": 2}},
                 "0xaa25": {"sizes": [4], "log": [0]}}
        out.append({"name": f"draw_rank_insignia rank {rank}", "routine": "id04_1b3e", "segment": "ID04",
                    "address": 0x1B3E, "args": [DIALOG, 15], "arg_sizes": [4, 2], "pascal_call": True, "void": True,
                    "log_calls": True, "writes": writes, "trap_specs": specs})
    return out


def mission_awards_cases() -> list[dict]:
    """draw_mission_awards (a Pascal user item): the item's box framed (frame_dialog_item_box:
    SetPort, GetDItem, InsetRect -2, PenSize 1, FrameRect, the port restored); in the dialog,
    clipped to the rect of the port at A5 - 0x160c, each medal of the pilot's record +0x26 (bit k)
    framed 60 x 18 in three columns over the box and its cicn (512 + k) plotted at the frame's top
    right at the icon's size (GetCIcon, PlotCIcon, DisposCIcon)."""
    out = []
    roster_h, records, icon_h, icon, port = 0x2CC00, 0x2D000, 0x2CD00, 0x2CE00, 0x2CF00
    for medals, pilot in ((0, 0), (1, 1), (0b10110101, 4), (0xFF, 9)):
        writes = [[g(-0x13A8), 4, roster_h], [roster_h, 4, records], [g(-0x13A4), 2, pilot],
                  [records + 64 * pilot + 0x26, 2, medals], [icon_h, 4, icon], [icon + 6, 4, 0],
                  [icon + 10, 4, 0x00100020], [g(-0x160C), 4, port], [port + 0x10, 4, 0x00000000],
                  [port + 0x14, 4, 0x01E00280]]
        specs = {"0xa873": {"sizes": [4], "log": [0]},
                 "0xa87b": {"sizes": [4], "deref": {"0": 2}},
                 "0xa98d": dict(GET_DITEM, outs={"0": [8, [[0x00400100, 0x008001A0]]]}),
                 "0xa8a9": {"sizes": [2, 2, 4], "log": [0, 1], "deref": {"2": 2}},
                 "0xa89b": {"sizes": [2, 2], "log": [0, 1]},
                 "0xa8a1": {"sizes": [4], "deref": {"0": 2}},
                 "0xa8a8": {"sizes": [2, 2, 4], "log": [0, 1], "deref": {"2": 2}},
                 "0xaa1e": {"sizes": [2], "log": [0], "result": [4, [icon_h]]},
                 "0xaa1f": {"sizes": [4, 4], "log": [0], "deref": {"1": 2}},
                 "0xaa25": {"sizes": [4], "log": [0]}}
        out.append({"name": f"draw_mission_awards medals {medals:#x}", "routine": "id04_1dde", "segment": "ID04",
                    "address": 0x1DDE, "args": [DIALOG, 12], "arg_sizes": [4, 2], "pascal_call": True, "void": True,
                    "log_calls": True, "writes": writes, "trap_specs": specs})
    return out


def map_tracker_cases() -> list[dict]:
    """track_map_bearing_and_distance (C: dialog, event): the click (the event's where) checked
    against the map's box (item 8; GetDItem, GlobalToLocal, PtInRect answered by the case); inside,
    the XOR lines from the centre to each new mouse point (GetMouse / StillDown answered per call)
    and for each the bearing (the heading service at A5 - 0x1056 writing its word) and the distance
    (the square root service at A5 - 0x105a) formatted by the C string glue ($4a2, $2fa, $512,
    $302, stubs) into items 5 and 6 (SetIText); the last line erased, pen size 1, the port back.
    Frame addresses are not logged (they differ between the two machines)."""
    out = []
    event, settings_h, settings = 0x2C400, 0x2C500, 0x2C600
    heading, root = HOOK + 0x40, HOOK + 0x80
    box = [0x00200010, 0x00A00110]                      # top 0x20, left 0x10, bottom 0xa0, right 0x110
    scenarios = (("outside", 0x00080008, [0], [0x00080008], [0], 0x1000),
                 ("drag inside", 0x00500060, [1, 1, 1, 1], [0x00400030, 0x00900100, 0x00900100], [1, 1, 0], 0x0C00),
                 ("drag out", 0x00500060, [1, 1, 0, 0], [0x00010001, 0x00010001, 0x00010001], [1, 1, 0], 0x3FFF),
                 ("no move", 0x00600090, [1, 1], [0x00600090], [0], 0))
    for name, where, inside, points, down, angle in scenarios:
        writes = [[event + 0xA, 4, where], [g(-0x13AC), 4, settings_h], [settings_h, 4, settings],
                  [settings + 0x26, 2, 8], [g(-0x1056), 4, heading], [g(-0x105A), 4, root],
                  [g(-0x160C), 4, 0x2C700], [0x2C700 + 0x10, 4, 0], [0x2C700 + 0x14, 4, 0x01E00280],
                  [g(-0xE56), 4, 0x2C800]]
        specs = {"0xa873": {"sizes": [4], "log": [0]},
                 "0xa98d": dict(GET_DITEM, outs={"0": [8, [box]], "1": [4, [0x2C900]]}),
                 "0xa871": {"sizes": [4]},
                 "0xa8ad": {"sizes": [4, 4], "log": [1], "deref": {"0": 2}, "result": [2, [0x100 * v for v in inside]]},
                 "0xa89b": {"sizes": [2, 2], "log": [0, 1]},
                 "0xa89c": {"sizes": [2], "log": [0]},
                 "0xa893": {"sizes": [2, 2], "log": [0, 1]},
                 "0xa891": {"sizes": [2, 2], "log": [0, 1]},
                 "0xa87b": {"sizes": [4], "deref": {"0": 2}},
                 "0xa972": {"sizes": [4], "outs": {"0": [4, points]}},
                 "0xa974": {"sizes": [], "result": [2, [0x100 * v for v in down]]},
                 "0xa98f": {"sizes": [4, 4], "log": [1]}}
        out.append({"name": f"track_map_bearing_and_distance {name}", "routine": "id04_3614", "segment": "ID04",
                    "address": 0x3614, "args": [DIALOG, event], "void": True, "log_calls": True, "writes": writes,
                    "trap_specs": specs,
                    "code_stubs": [{"at": f"{heading:#x}", "longs": 5, "outs": {"6": [2, angle]}},
                                   {"at": f"{root:#x}", "longs": 1, "result": 0x123}],
                    "c_stubs": {"0x4a2": [[4], 0x2CA00], "0x2fa": [[4], 0x2CB00], "0x512": [[], 0], "0x302": [[], 0]}})
    return out


def map_dialog_cases() -> list[dict]:
    """run_map_dialog: nothing in scenario 2; else GetNewDialog(0x89), JT $472, item 8's procedure
    ($b2, set_dialog_user_item_proc: GetDItem / SetDItem), the default ring (install_default_ring_item),
    ShowWindow, ModalDialog until OK, DisposDialog. Zoom In / Out are pressed only at the scale's
    limits (1 / 0x100), where they change nothing and redraw nothing."""
    out = []
    settings_h, settings = 0x2CF00, 0x2CF80
    for name, scenario, scale, hits in (("Flight School", 2, 8, [1]), ("OK at once", 4, 8, [1]),
                                        ("zoom in at the limit", 4, 1, [3, 3, 1]), ("zoom out at the limit", 4, 0x100, [4, 1])):
        specs = {"0xa97c": {"sizes": [4, 4, 2], "log": [2], "result": [4, [DIALOG]]},
                 "0xa915": {"sizes": [4], "log": [0]},
                 "0xa991": {"sizes": [4, 4], "log": [1], "outs": {"0": [2, hits]}},
                 "0xa983": {"sizes": [4], "log": [0]},
                 "0xa98d": dict(GET_DITEM, outs={"2": [2, [0x0000]], "1": [4, [0x22222222]],
                                                 "0": [8, [[0x00100010, 0x00F000F0]]]}),
                 "0xa98e": SET_DITEM}
        out.append({"name": f"run_map_dialog {name}", "routine": "id04_3976", "segment": "ID04", "address": 0x3976,
                    "args": [], "void": True, "log_calls": True,
                    "writes": [[g(-0x12F8), 2, scenario], [g(-0x13AC), 4, settings_h], [settings_h, 4, settings],
                               [settings + 0x26, 2, scale]],
                    "check": [[settings + 0x26, 2]], "c_stubs": {"0x472": [[4], 0]}, "trap_specs": specs})
    return out


def refuel_cases() -> list[dict]:
    """run_refuel_dialog: the fuel slider starts at the load (A5 - 0x225c = A5 - 0x12d2); GetNewDialog(0x84),
    JT $472, the default ring, item 3's percent bar ($8a), the bomb radios (items 4..6 at A5 - 0x2240) set to 6,
    ShowWindow; ModalDialog with the filter at $14a, each hit but OK given to set_radio_group_selection; then
    get_radio_group_selection (GetCtlValue per radio, the stubs' answers saying which is on): bombs = it - 4,
    fuel = the slider's value; DisposDialog."""
    out = []
    radios = g(-0x2240)
    for name, hits, on, slider in (("OK at once", [1], [0, 0, 1], 57), ("1 bomb", [5, 1], [0, 1, 0], 80),
                                   ("no radio on", [3, 1], [0, 0, 0], 33)):
        specs = {"0xa97c": {"sizes": [4, 4, 2], "log": [2], "result": [4, [DIALOG]]},
                 "0xa915": {"sizes": [4], "log": [0]},
                 "0xa991": {"sizes": [4, 4], "log": [1], "outs": {"0": [2, hits]}},
                 "0xa983": {"sizes": [4], "log": [0]},
                 "0xa98d": dict(GET_DITEM, outs={"2": [2, [0x0004]], "1": [4, [0x1000, 0x2000, 0x3000]],
                                                 "0": [8, [[0x00100010, 0x00200020]]]}),
                 "0xa98e": SET_DITEM, "0xa963": SET_CTL_VALUE,
                 "0xa960": {"sizes": [4], "log": [0], "result": [2, on]}}
        out.append({"name": f"run_refuel_dialog {name}", "routine": "id04_0e70", "segment": "ID04", "address": 0xE70,
                    "args": [], "void": True, "log_calls": True,
                    "writes": [[g(-0x12D2), 2, slider], [g(-0x12D0), 2, 2], [g(-0x12F8), 2, 4], [g(-0x225C), 2, 0],
                               [radios, 2, 4], [radios + 2, 2, 5], [radios + 4, 2, 6]],
                    "check": [[g(-0x12D2), 2], [g(-0x12D0), 2], [g(-0x225C), 2]],
                    "c_stubs": {"0x472": [[4], 0]}, "trap_specs": specs})
    return out


def duty_roster_cases() -> list[dict]:
    """run_duty_roster_dialog: GetNewDialog(0x82), JT $472; the pilots ranked and pruned (the
    original's own routines on the case's roster: twenty records, some retired); up to ten active
    ones listed (SetIText of the rank name, the name and the score through JT $4a2, logged with the
    score: the tallies +0x28 by the weights at A5 - 0xf5e), the current pilot's name field selected (SelIText); ModalDialog (filter $c2): Cancel
    returns 0; OK reads each name back (GetIText), compares it (JT $502 strncmp, answered by the
    case) and copies it (JT $50a) when it differs, the roster changed and written then; the
    edit field's row (dialog +0xa4) becomes the current pilot. The C string glue is stubbed, the
    roster's HLock / HUnlock (JT $272 / $27a) are Pascal stubs; no two pilots tie, so the name order
    (JT $2ea) is never asked (its stub would log it)."""
    out = []
    roster_h, records, settings_h, settings, ranks = 0x2C200, 0x2D000, 0x2C500, 0x2C600, 0x2C300
    for name, hits, differ, retired, current, edit in (
            ("cancel", [3], 0, (2, 7), 3, 15),
            ("OK unchanged", [1], 0, (0, 5, 11), 4, 16),
            ("OK renamed, ten shown", [1], 1, (), 9, 18)):
        writes = [[g(-0x13A8), 4, roster_h], [roster_h, 4, records], [g(-0x13AC), 4, settings_h],
                  [settings_h, 4, settings], [settings + 0x20, 2, current], [g(-0x13A4), 2, 0],
                  [DIALOG + 0xA4, 2, edit]]
        writes += [[g(-0xFFE) + 4 * r, 4, ranks + 0x10 * r] for r in range(8)]
        writes += [[g(-0xF5E) + 2 * k, 2, 5 * k + 3] for k in range(12)]     # the tallies' weights
        for p in range(20):
            rec = records + 64 * p
            writes += [[rec, 4, 0x50000000 | (0x41 + p) << 16], [rec + 0x20, 2, 1 if p in retired else 0],
                       [rec + 0x22, 2, p % 6]]
            writes += [[rec + 0x24 + 2 * k, 2, (p * 37 + k * 11) % 23] for k in range(14)]
        specs = {"0xa97c": {"sizes": [4, 4, 2], "log": [2], "result": [4, [DIALOG]]},
                 "0xa915": {"sizes": [4], "log": [0]},
                 "0xa991": {"sizes": [4, 4], "log": [1], "outs": {"0": [2, hits]}},
                 "0xa983": {"sizes": [4], "log": [0]},
                 "0xa98d": dict(GET_DITEM, outs={"2": [2, [0x0010]], "1": [4, [0x3000 + 4 * k for k in range(80)]],
                                                 "0": [8, [[0x00100010, 0x00200020]]]}),
                 "0xa98e": SET_DITEM,
                 "0xa98f": {"sizes": [4, 4], "log": [1]},
                 "0xa990": {"sizes": [4, 4], "log": [1]},
                 "0xa97e": {"sizes": [2, 2, 2, 4], "log": [0, 1, 2, 3]},
                 "0xa9aa": {"sizes": [4], "log": [0]}, "0xa9b0": {"sizes": [4], "log": [0]}}
        out.append({"name": f"run_duty_roster_dialog {name}", "routine": "id04_0644", "segment": "ID04",
                    "address": 0x644, "args": [], "log_calls": True, "writes": writes, "id01": True,
                    "check": [[g(-0x13A4), 2]] + [[records + 64 * p + k, 4] for p in range(20) for k in (0, 0x20, 0x24)],
                    "c_stubs": {"0x472": [[4], 0], "0x4a2": [[4], 0x2CA00], "0x2fa": [[], 0], "0x302": [[], 0],
                                "0x502": [[], differ], "0x50a": [[], 0]},
                    "pascal": {"0x272": [4, None], "0x27a": [4, None], "0x2ea": [8, None]},
                    "trap_specs": specs})
    return out


COLOUR_INDICES = [-0x11AE, -0x11AC, -0x118C, -0x1188, -0x118A, -0x117C, -0x117E, -0x11FA, -0x11F8]


def display_palette_cases() -> list[dict]:
    """apply_display_palettes: select_palette_for_depth (depth A5 - 0x137a against the palette depth
    A5 - 0x2cc: 4 / 8 SetPalette with their palette and extra entries, 1 the extras alone), then
    rebuild_all_palette_index_maps (depth 1: the standard colour indices looked up in the eight
    fixed colours at A5 - 0x350; with a palette depth the offscreen port A5 - 0x103a closed and
    disposed, the device records 1..3 at A5 - 0x136e empty here), then the overlay hook A5 - 0x10a2
    (a stub)."""
    out = []
    for depth, before, port in ((1, 0, 0), (2, 4, 0), (4, 0, 0x2C700), (8, 4, 0), (8, 8, 0x2C700), (4, 4, 0)):
        writes = [[g(-0x137A), 2, depth], [g(-0x2CC), 2, before], [g(-0x103A), 4, port], [g(-0x102A), 2, 1],
                  [g(-0x14AE), 4, 0x2C800], [g(-0x14AA), 4, 0x2C900], [g(-0x14CA), 4, 0x2CA00],
                  [g(-0x14A6), 4, 0], [g(-0x14A2), 2, 0], [g(-0x10A2), 4, HOOK]]
        writes += [[g(-0x136E) + 0x16 * i, 4, 0] for i in range(1, 4)]
        writes += [[g(a), 2, 0x7777] for a in COLOUR_INDICES]
        for i in range(8):                       # the fixed colours: grey levels (level << 14), two tinted
            level = [0, 0x4000, 0x8000, 0xC000][i % 4] if i < 4 else [0xC000, 0, 0x4000, 0x8000][i % 4]
            writes += [[g(-0x350) + 6 * i, 2, level], [g(-0x350) + 6 * i + 2, 2, level ^ (0x1100 * (i >= 6))],
                       [g(-0x350) + 6 * i + 4, 2, level]]
        out.append({"name": f"apply_display_palettes depth {depth} from {before} port {port:#x}", "routine": "id02_4d24",
                    "segment": "ID02", "address": 0x4D24, "args": [], "void": True, "log_calls": True, "writes": writes,
                    "check": [[g(-0x2CC), 2], [g(-0x14A6), 4], [g(-0x14A2), 2], [g(-0x102A), 2], [g(-0x103A), 4]]
                    + [[g(a), 2] for a in COLOUR_INDICES],
                    "trap_specs": {"0xaa95": {"sizes": [2, 4, 4], "log": [0, 1, 2]},
                                   "0xa87d": {"sizes": [4], "log": [0]}},
                    "pascal": {"0x23a": [4, None]}, "code_stubs": [f"{HOOK:#x}"]})
    return out


def protection_code_cases() -> list[dict]:
    """build_protection_code_strings (C: code, code text, other, other text): the volume name
    buffer copied into the frame (0xfe bytes), the machine fingerprint (SysEnvirons stubbed, no
    Color QuickDraw: the screen bounds at A5 - 0x1680), the TEXT 128 pair read (GetResource answering
    a handle to it); equal, GetVol and the name compared (JT $51a, answered by the case) and on the
    original floppy the pair rewritten as (0, random_28bit_value from the seed A5 - 0x6c) and read
    again; then the other text from A5 - 0xd66 when still equal, else the packed fingerprint and
    the encoded other; the code text encoded. The string glue ($2fa, $51a, $52a) is stubbed and
    logged with its arguments; the encoded buffers at A5 - 0x68 / - 0x54 / - 0x40 are checked."""
    out = []
    code, code_text, other, other_text, pair_h, pair = 0x2C400, 0x2C410, 0x2C440, 0x2C450, 0x2C500, 0x2C600
    for name, first, second, floppy in (("codes differ", 0x1234567, 0x0765432, 1), ("equal elsewhere", 5, 5, 1),
                                        ("equal on the floppy", 5, 5, 0)):
        writes = [[pair_h, 4, pair], [pair, 4, first], [pair + 4, 4, second], [code, 4, 0], [other, 4, 0],
                  [g(-0x6C), 4, 0x13579BDF], [g(-0xD66), 4, 0x2C700],
                  [g(-0x1680), 2, 0], [g(-0x167E), 2, 0], [g(-0x167C), 2, 480], [g(-0x167A), 2, 640]]
        writes += [[g(-0x2C8) + 4 * k, 4, 0x48454C00 + k] for k in range(0x42)]
        writes += [[g(b) + 4 * k, 4, 0] for b in (-0x68, -0x54, -0x40) for k in range(3)]
        specs = {"0xa9a0": {"sizes": [2, 4], "log": [0, 1], "result": [4, [pair_h]]},
                 "0xa9a3": {"sizes": [4], "log": [0]},
                 "0xa9aa": {"sizes": [4], "log": [0]}, "0xa9b0": {"sizes": [4], "log": [0]}}
        out.append({"name": f"build_protection_code_strings {name}", "routine": "id05_03ba", "segment": "ID05",
                    "address": 0x3BA, "args": [code, code_text, other, other_text], "void": True, "log_calls": True,
                    "zero_stack": True, "writes": writes, "trap_specs": specs,
                    "check": [[code, 4], [other, 4], [pair, 4], [pair + 4, 4], [g(-0x6C), 4]]
                    + [[g(b) + 4 * k, 4] for b in (-0x68, -0x54, -0x40) for k in range(2)],
                    "pascal_stubs": {"0x1f2": [6, 2, 0], "0x2ba": [8, 2, 0], "0x28a": [4, 0, 0], "0x282": [4, 0, 0]},
                    "c_stubs": {"0x2fa": [[], 0x2CB00], "0x51a": [[4, 4], floppy], "0x52a": [[4, 4], 0]}})
    return out


def readout_hook_cases() -> list[dict]:
    """The overlay hook 0xd23a, redraw_view_readouts: update_view_readouts_and_overlays(0)
    (0xcfec); with the panel flag 0x20ae4 set, update_throttle_gauge (0xcb42),
    update_radar_range_buttons (0x17a6c) and update_bomb_indicator (0xcaa6), stubbed on both sides
    (by address here, by method in the replay), then mark_view_overlays_drawn (0xd25c, run):
    0x25ffc = 1 and, with the host's word +0x9e (host 0x1b5a0) set, clear_flag_00020ae4 (0x6eae)."""
    out = []
    host = 0x2B000
    for flag, line in ((0, 0), (1, 0), (1, 1), (0, 1)):
        out.append({"name": f"redraw_view_readouts flag {flag} host line {line}", "routine": "_d23a",
                    "segment": "overlay", "address": 0xD23A, "args": [], "void": True, "image": True,
                    "log_calls": True,
                    "writes": [[0x20AE4, 2, flag], [0x25FFC, 2, 0], [0x1B5A0, 4, host], [host + 0x9E, 2, line]],
                    "check": [[0x20AE4, 2], [0x25FFC, 2]],
                    "overlay_stubs": {"0xcfec": 1, "0xcb42": 0, "0x17a6c": 0, "0xcaa6": 0}})
    return out


def scenario_dialog_cases() -> list[dict]:
    """run_scenario_selection_dialog: the settings' scenario (+0x1e, 1 when unset, shown as 2) and
    fuel (A5 - 0x12d2, 100 when unset, into A5 - 0x225c); GetNewDialog(0x81), JT $472, the user items,
    the mission radios (8 at A5 - 0x2256) and bomb radios (3 at A5 - 0x2246) set; ModalDialog (the
    filter at $112): Cancel returns 0, OK ends (confirm_end_mission answers 2 outside a mission),
    other hits select in both groups; then the selections (GetCtlValue per radio, answered by the
    case) and the fuel and pilot stored where they changed (A5 - 0x138a), DisposDialog, JT $4ca, the
    game state set to the scenario, JT $4c2."""
    out = []
    settings_h, settings = 0x2C500, 0x2C600
    missions, bombs = g(-0x2256), g(-0x2246)
    for name, hits, on, scenario, fuel, pilot in (
            ("cancel", [3], [0], 3, 60, 1),
            ("OK unset", [1], [0, 0, 1, 1], 0, 0, 1),
            ("change all", [11, 7, 1], [0, 1, 0, 0, 0, 0, 1], 4, 75, 2),
            ("no radio on", [9, 1], [0] * 11, 2, 40, 1)):
        writes = [[g(-0x13AC), 4, settings_h], [settings_h, 4, settings], [settings + 0x1E, 2, scenario],
                  [settings + 0x20, 2, 1], [settings + 0x22, 2, 60], [settings + 0x24, 2, 2],
                  [g(-0x12D2), 2, fuel], [g(-0x13A4), 2, pilot], [g(-0x138A), 2, 0], [g(-0x12F8), 2, 1],
                  [g(-0x14C4), 2, 1], [g(-0x225C), 2, 0]]
        writes += [[missions + 2 * k, 2, 9 + k] for k in range(8)] + [[bombs + 2 * k, 2, 6 + k] for k in range(3)]
        specs = {"0xa97c": {"sizes": [4, 4, 2], "log": [2], "result": [4, [DIALOG]]},
                 "0xa915": {"sizes": [4], "log": [0]},
                 "0xa991": {"sizes": [4, 4], "log": [1], "outs": {"0": [2, hits]}},
                 "0xa983": {"sizes": [4], "log": [0]},
                 "0xa98d": dict(GET_DITEM, outs={"2": [2, [0x0004]], "1": [4, [0x1000, 0x2000, 0x3000]],
                                                 "0": [8, [[0x00100010, 0x00200020]]]}),
                 "0xa98e": SET_DITEM, "0xa963": SET_CTL_VALUE,
                 "0xa960": {"sizes": [4], "log": [0], "result": [2, on]}}
        out.append({"name": f"run_scenario_selection_dialog {name}", "routine": "id04_0c02", "segment": "ID04",
                    "address": 0xC02, "args": [], "d0_size": 2, "log_calls": True, "writes": writes,
                    "check": [[settings + 0x1E, 2], [settings + 0x20, 2], [settings + 0x22, 2], [settings + 0x24, 2],
                              [g(-0x138A), 2], [g(-0x12F8), 2], [g(-0x12D2), 2], [g(-0x225C), 2], [g(-0x14C4), 2]],
                    "c_stubs": {"0x472": [[4], 0], "0x4ca": [[], 0], "0x4c2": [[], 0]}, "trap_specs": specs})
    return out


def high_scores_cases() -> list[dict]:
    """run_high_scores_dialog: GetNewDialog(0x86), JT $472, the default ring, items 8 ($142) and 10
    ($e2), ShowWindow; ModalDialog (no filter) until OK; Erase Nonactive (item 3) asks
    confirm_erase_high_scores (JT $47a, CautionAlert 0x104): on 2 every retired pilot (record +0x20
    set) is reset with the roster locked, and when any was, the roster is written and item 10's box
    invalidated in the dialog's port."""
    out = []
    roster_h, records = 0x2CC00, 0x2D000
    retired = {3: 1, 7: 2}
    for name, hits, answer in (("OK at once", [1], 1), ("erase confirmed", [3, 1], 2), ("erase refused", [3, 1], 1)):
        writes = [[g(-0x13A8), 4, roster_h], [roster_h, 4, records], [g(-0x160C), 4, 0x2C900]]
        for pilot in range(20):
            rec = records + 64 * pilot
            writes += [[rec, 1, 0x41], [rec + 0x20, 2, retired.get(pilot, 0)], [rec + 0x22, 2, 3], [rec + 0x28, 2, 9]]
        specs = {"0xa97c": {"sizes": [4, 4, 2], "log": [2], "result": [4, [DIALOG]]},
                 "0xa915": {"sizes": [4], "log": [0]},
                 "0xa991": {"sizes": [4, 4], "log": [1], "outs": {"0": [2, hits]}},
                 "0xa983": {"sizes": [4], "log": [0]},
                 "0xa98d": dict(GET_DITEM, outs={"2": [2, [0x0000]], "1": [4, [0x22222222]],
                                                 "0": [8, [[0x00100010, 0x00F000F0]]]}),
                 "0xa98e": SET_DITEM,
                 "0xa988": {"sizes": [4, 2], "log": [1], "result": [2, [answer]]},
                 "0xa9aa": {"sizes": [4], "log": [0]}, "0xa9b0": {"sizes": [4], "log": [0]},
                 "0xa873": {"sizes": [4], "log": [0]},
                 "0xa928": {"sizes": [4], "deref": {"0": 2}}}
        check = [[records + 64 * p + off, 2] for p in (2, 3, 7) for off in (0x20, 0x22, 0x28)]
        check += [[records + 64 * p, 1] for p in (2, 3, 7)]
        out.append({"name": f"run_high_scores_dialog {name}", "routine": "id04_137a", "segment": "ID04",
                    "address": 0x137A, "args": [], "void": True, "log_calls": True, "writes": writes, "check": check,
                    "c_stubs": {"0x472": [[4], 0], "0x47a": [[2], 0]},
                    "pascal": {"0x272": [4, None], "0x27a": [4, None]}, "trap_specs": specs})
    return out


SUMMARY_MESSAGES = list(range(-0x221E, -0x21CA, 4)) + list(range(-0xEEA, -0xE5E, 4))
SUMMARY_LIST = -0x21C6


def summary_text_cases() -> list[dict]:
    """advance_mission_summary_text (C: dialog, item word, phase word). Stage 0
    (A5 - 0x2222) collects the outcome's messages into the list at A5 - 0x21c6 (each message pointer
    a marker here) by the phase's low byte (1: the TickCount picks one of four), its high byte and
    the outcome A5 - 0x12b4, then a commendation (A5 - 0x12b6: the record's +0x24 counted up, the
    roster changed; five or more missions a promotion) and the kill report (A5 - 0x12ba), and
    counts them (A5 - 0x2176). Stage 1 appends one per call (TEInsert of it and the newline; strlen
    $522 stubbed; the scroll bar's maximum, value and the text scrolled to the selection, GetCtlValue
    answered by the case), then stage 2 or the end line. Phase 3 writes its lines at once (the
    outcome, the kill report state, the mission's own line by game state A5 - 0x12f8). Stage 2: the
    scenario's medal (record +0x26) and item 5 redrawn (SetPort, GetDItem, InsetRect, EraseRect,
    InvalRect), then the end or stage 3. Stage 3 with no kills left goes to stage 4 (the roster
    written): the score (tallies +0x28 by the weights A5 - 0xf5e) against the next rank's (A5 - 0xfd6)
    gives the end or the promotion (record +0x22, stage 5). Stage 5 appends its messages, then the
    new rank's line (built in the frame: logged without its address) and items 15 and 9 redrawn.
    Stage 3 reports one kind of kill per call: the line built in the frame, the tallies counted
    (record +0x28, A5 - 0x13a2, the shown counts at *(A5 - 0x2226)), the score item's text, the
    kind's row and the kill markers redrawn (their QuickDraw traps stubbed; the frame starts zeroed)."""
    out = []
    roster_h, records = 0x2CC00, 0x2D000

    def case(name, stage, phase, outcome, extra=(), ticks=0, left=0, more=0, commended=0, raw=(), frame_line=False):
        writes = [[g(-0x2222), 2, stage], [g(-0x12B4), 2, outcome], [g(-0x13A8), 4, roster_h], [roster_h, 4, records],
                  [g(-0x13A4), 2, 2], [g(-0x1002), 2, 7], [g(-0x223A), 4, 0x2CB00], [g(-0x2176), 2, left],
                  [g(-0x2228), 2, more], [g(-0x21CA), 4, g(SUMMARY_LIST)], [records + 128 + 0x24, 2, commended],
                  [g(-0x12B6), 2, 0], [g(-0x12BA), 2, 0], [g(-0x14C0), 2, 1], [g(-0x14C4), 2, 0], [g(-0x12B2), 2, 0]]
        te = 0x2E000                             # the TE record: 20 lines of 10 characters, 12 high, the
        writes += [[0x2CB00, 4, te], [te, 2, 0], [te + 8, 2, 0], [te + 0x18, 2, 12], [te + 0x20, 2, 100],
                   [te + 0x5E, 2, 20], [g(-0x2236), 4, 0x2CA80], [g(-0x2232), 2, 10]]   # selection on line 10
        writes += [[te + 0x60 + 2 * k, 2, 10 * k] for k in range(21)]
        writes += [[g(o), 4, 0x00300000 + (o & 0xFFFF)] for o in SUMMARY_MESSAGES]
        writes += [[g(SUMMARY_LIST) + 4 * k, 4, 0x00400000 + k if stage == 1 else 0] for k in range(16)]
        writes += [[g(-0x12F8), 2, 4], [g(-0x160C), 4, 0x2C700], [records + 128 + 0x22, 2, 1],
                   [records + 128 + 0x26, 2, 0]]
        writes += [[g(-0x12CE) + 2 * k, 2, 0] for k in range(10)] + [[records + 128 + 0x28 + 2 * k, 2, 0] for k in range(12)]
        writes += [[g(-0xF5E) + 2 * k, 2, 1 if k == 0 else 0] for k in range(12)]
        writes += [[g(-0xFD6) + 4 * k, 4, v] for k, v in enumerate((0, 100, 500, 1000, 5000, 10000, 50000, 0x7FFFFFFF))]
        writes += [[g(-0xFFE) + 4 * r, 4, 0x2C300 + 0x10 * r] for r in range(8)]
        writes += [[g(o), 2 if o not in (-0x21CA,) else 4, v] for o, v in extra] + [list(w) for w in raw]
        writes += [[0x2C700 + 0x44, 2, 3], [0x2C710, 4, 0], [0x2C714, 4, 0x01E00280], [g(-0x2226), 4, 0x2CE00],
                   [g(-0xE5E), 4, 0x2CE80]]   # the port: its font and rect
        writes += [[0x2CE00 + 2 * k, 2, k] for k in range(10)] + [[g(-0x13A2) + 2 * k, 2, 2 * k] for k in range(10)]
        writes += [[g(-0xF86) + 4 * k, 4, 0x2CF00 + 0x10 * k] for k in range(10)]
        check = [[g(-0x12CE) + 2 * k, 2] for k in range(10)] + [[g(-0x13A2) + 2 * k, 2] for k in range(10)]
        check += [[0x2CE00 + 2 * k, 2] for k in range(10)] + [[records + 128 + 0x28 + 2 * k, 2] for k in range(10)]
        check += [[g(SUMMARY_LIST) + 4 * k, 4] for k in range(16)] + [[g(o), 2] for o in
                 (-0x2222, -0x2176, -0x12B4, -0x14C4, -0x12B6, -0x12BA)] + [[g(-0x21CA), 4], [records + 128 + 0x24, 2],
                 [records + 128 + 0x22, 2], [records + 128 + 0x26, 2]]
        out.append({"name": f"advance_mission_summary_text {name}", "routine": "id04_21d6", "segment": "ID04",
                    "address": 0x21D6, "args": [DIALOG, 8, phase], "arg_sizes": [4, 2, 2], "d0_size": 2,
                    "log_calls": True, "id01": True, "writes": writes, "check": check,
                    "trap_specs": {"0xa975": {"sizes": [], "result": [4, [ticks]]},
                                   "0xa9de": {"sizes": [4, 4, 4], "log": [0, 1] if frame_line else [0, 1, 2]},
                                   "0xa873": {"sizes": [4], "log": [0]},
                                   "0xa98d": dict(GET_DITEM, outs={"0": [8, [[0x00400100, 0x008001A0]]]}),
                                   "0xa8a9": {"sizes": [2, 2, 4], "log": [0, 1], "deref": {"2": 2}},
                                   "0xa8a3": {"sizes": [4], "deref": {"0": 2}}, "0xa928": {"sizes": [4], "deref": {"0": 2}},
                                   "0xa98f": {"sizes": [4, 4], "log": [0, 1]}, "0xa87b": {"sizes": [4], "deref": {"0": 2}},
                                   "0xa88b": {"sizes": [4]}, "0xa893": {"sizes": [2, 2], "log": [0, 1]},
                                   "0xa887": {"sizes": [2], "log": [0]}, "0xa884": {"sizes": [4]},
                                   "0xa88c": {"sizes": [4], "result": [2, [30]]}, "0xa89b": {"sizes": [2, 2], "log": [0, 1]},
                                   "0xa8a1": {"sizes": [4], "deref": {"0": 2}},
                                   "0xa8a8": {"sizes": [2, 2, 4], "log": [0, 1], "deref": {"2": 2}},
                                   "0xaa14": {"sizes": [4], "deref": {"0": 1}}, "0xa8b8": {"sizes": [4], "deref": {"0": 2}},
                                   "0xa862": {"sizes": [4], "log": [0]},
                                   "0xa9aa": {"sizes": [4], "log": [0]}, "0xa999": {"sizes": [2], "log": [0]},
                                   "0xa965": {"sizes": [2, 4], "log": [0, 1]},
                                   "0xa960": {"sizes": [4], "log": [0], "result": [2, [0, 0, 3]]},
                                   "0xa963": {"sizes": [2, 4], "log": [0, 1]},
                                   "0xa9dd": {"sizes": [4, 2, 2], "log": [0, 1, 2]}},
                    "zero_stack": True,
                    "c_stubs": {"0x522": [[] if frame_line else [4], 5], "0x2fa": [[4], 0], "0x302": [[] if frame_line else [4], 0],
                                "0x4a2": [[4], 0x2CD00],
                                "0x52a": [[], 0], "0x512": [[], 0]}})

    for outcome, more, ticks in ((1, 1, 0), (1, 0, 4), (1, 0, 13), (0, 0, 0)):
        case(f"phase 1 outcome {outcome} {more} ticks {ticks}", 0, 1, outcome, [(-0x12B2, more)], ticks)
    for low in (6, 7):
        for high in (0, 1, 2):
            for outcome in (0, 1, 3, 4):
                case(f"phase {low} high {high} outcome {outcome}", 0, high << 8 | low, outcome)
    for low in (8, 9, 10):
        for high in (0, 1, 2):
            for outcome in (0, 3, 5):
                case(f"phase {low} high {high} outcome {outcome}", 0, high << 8 | low, outcome)
    case("phase 2 (none)", 0, 2, 0)
    for missions, commended in ((1, 0), (3, 1), (4, 2), (5, 2)):   # the record's +0x24 counts commendations
        case(f"commendation {missions} after {commended}", 0, 6, 0, [(-0x12B6, missions)], commended=commended)
    for report in (1, 0, -1):
        case(f"kill report {report}", 0, 7, 0, [(-0x14C0, 0), (-0x12BA, report & 0xFFFF)])
    case("stage 1 next line", 1, 1, 0, left=3)
    case("stage 1 to the pilot", 1, 1, 0, left=0, more=0xFFFF)
    case("stage 1 the end", 1, 1, 0, left=0, more=0)
    kills = [[g(-0x12CE) + 4, 2, 2]]                # two of kind 2 this mission
    case("phase 3 outcome 1", 0, 3, 1)
    case("phase 3 kills", 0, 3, 0, raw=kills)
    case("phase 3 kill report 2", 0, 3, 0, [(-0x14C0, 0), (-0x12BA, 3)])
    for state in (5, 6, 7, 8, 9):
        case(f"phase 3 failed in state {state}", 0, 3, 0, [(-0x14C0, 0), (-0x12BA, 0xFFFF), (-0x12F8, state)])
    case("phase 3 report -2", 0, 3, 0, [(-0x14C0, 0), (-0x12BA, 0xFFFE)])
    for state in (4, 5, 9):
        case(f"stage 2 medal in state {state}", 2, 1, 0, [(-0x12F8, state)])
    case("stage 2 outcome 1, kills", 2, 1, 1, raw=kills)
    case("stage 2 phase 6", 2, 6, 0)
    for at in (0, 10):
        case(f"stage 3 none left from {at}, below the next rank", 3, 1, 0, left=at)
    for score, outcome in ((499, 0), (500, 0), (600, 1), (20000, 0), (0x7FFF, 1)):
        case(f"stage 4 score {score} outcome {outcome}", 4, 1, outcome,
             raw=[[records + 128 + 0x28, 2, score]])
    for name, counts, at, tallies in (("one of kind 0", {0: 1}, 0, (0, 0)), ("kind 3 after none", {3: 2}, 0, (5, 4)),
                                      ("kind 2 (no row)", {2: 3, 6: 1}, 1, (20, 9)), ("kind 9", {9: 7}, 4, (1, 1))):
        raw = [[g(-0x12CE) + 2 * k, 2, n] for k, n in counts.items()]
        raw += [[records + 128 + 0x28, 2, tallies[0]], [records + 128 + 0x2A, 2, tallies[1]]]
        case(f"stage 3 kills {name}", 3, 1, 0, left=at, raw=raw, frame_line=True)
    case("stage 5 next message", 5, 1, 0, left=2)
    for outcome in (0, 1):
        case(f"stage 5 the new rank outcome {outcome}", 5, 1, outcome, left=0, frame_line=True)
    return out


def summary_filter_cases() -> list[dict]:
    """mission_summary_filter_proc (Pascal: dialog, event, VAR item): Return / Enter give the default
    item (A5 - 0x225e) once the text is done (A5 - 0x2230 clear); a click goes to the click handler
    (0x1752, here hitting nothing); an update to JT $492; then the timer: |TickCount - A5 - 0x222c|
    (JT $4da, stubbed) below the step delay A5 - 0x2230 returns false (the text step 0x21d6 is not
    reached here)."""
    out = []
    event, item_hit = 0x2C800, 0x2C8F0
    for name, what, message, delay in (("Return when done", 3, 0x0D, 0), ("Enter when done", 3, 0x03, 0),
                                       ("Return while stepping", 3, 0x0D, 100), ("a click", 1, 0, 100),
                                       ("an update", 6, 0, 100), ("another key", 3, 0x41, 100)):
        writes = [[event, 2, what], [event + 2, 4, message], [event + 0xA, 4, 0x00500060], [item_hit, 2, 0],
                  [g(-0x225E), 2, 3], [g(-0x2230), 4, delay], [g(-0x222C), 4, 990], [g(-0x2236), 4, 0x2C700]]
        specs = {"0xa975": {"sizes": [], "result": [4, [1000]]},
                 "0xa874": {"sizes": [4], "outs": {"0": [4, [0x2C900]]}}, "0xa873": {"sizes": [4], "log": [0]},
                 "0xa871": {"sizes": [4], "deref": {"0": 1}},
                 "0xa96c": {"sizes": [4, 4, 4], "log": [1, 2], "outs": {"0": [4, [0]]}, "result": [2, [0]]}}
        out.append({"name": f"mission_summary_filter_proc {name}", "routine": "id04_2104", "segment": "ID04",
                    "address": 0x2104, "args": [DIALOG, event, item_hit], "arg_sizes": [4, 4, 4], "pascal_call": True,
                    "d0_size": 1, "log_calls": True, "id01": True, "writes": writes, "check": [[item_hit, 2]],
                    "c_stubs": {"0x492": [[4], 0], "0x4da": [[4], 10]}, "trap_specs": specs})
    return out


def _spec_trap(word: int, spec: dict, calls: list):
    """A trap from its layout: arguments read from A7 up, the logged ones and the dereferenced
    pointers' longs appended to calls, the VAR outputs written, the arguments popped (Pascal)."""
    count = [0]

    def trap(emu) -> None:
        at, args = emu.a[7], []
        for size in spec["sizes"]:
            args.append(emu.read(at, size))
            at += size
        entry = [f"trap {word:#x}"] + [args[i] for i in spec.get("log", [])]
        for idx, longs in spec.get("deref", {}).items():
            entry += [emu.read(args[int(idx)] + 4 * k, 4) for k in range(longs)]
        calls.append(entry)
        for idx, (size, values) in spec.get("outs", {}).items():
            value = values[min(count[0], len(values) - 1)]
            if isinstance(value, list):
                for k, long in enumerate(value):
                    emu.write(args[int(idx)] + 4 * k, 4, long)
            else:
                emu.write(args[int(idx)], size, value)
        count[0] += 1
        emu.a[7] = (emu.a[7] + sum(spec["sizes"])) & 0xFFFFFFFF
        if "result" in spec:                     # a Pascal function: the result in the caller's slot
            size, values = spec["result"]
            emu.write(emu.a[7], size, values[min(count[0] - 1, len(values) - 1)])
    return trap


def _c_stub(arg_sizes: list[int], result: int, calls: list, name: str):
    """A C routine behind a jump-table slot: its arguments read off the stack (the caller pops
    them), [name, arguments...] logged, the result in D0."""
    def stub(emu) -> int:
        at, args = emu.a[7], []
        for size in arg_sizes:
            args.append(emu.read(at, size))
            at += 4 if size == 4 else 2
        calls.append([name] + args)
        return result
    return stub


def _pascal_stub(arg_bytes: int, result: int, calls: list | None = None, name: str = ""):
    """Pascal glue: the callee pops its arguments and leaves its result in the long the caller reserved
    (a procedure, result None, leaves nothing)."""
    def stub(emu) -> int:
        if calls is not None and arg_bytes:
            calls.append([name, emu.read(emu.a[7], 4)])
        emu.a[7] = (emu.a[7] + arg_bytes) & 0xFFFFFFFF
        if result is None:
            return 0
        emu.write(emu.a[7], 4, result)
        return result
    return stub


def _stub_at(stub) -> str:
    return stub if isinstance(stub, str) else stub["at"]


def _code_stub(stub, calls: list):
    """A code address reached through a pointer (C): logged with its first `longs` arguments, the
    VAR outputs written (argument index: [size, value]), D0 answered."""
    spec = {"at": stub} if isinstance(stub, str) else stub

    def call(emu) -> int:            # the return address popped: the arguments from A7 up
        args = [emu.read(emu.a[7] + 4 * k, 4) for k in range(max([spec.get("longs", 0)]
                                                                   + [int(i) + 1 for i in spec.get("outs", {})]))]
        calls.append([f"code {spec['at']}"] + args[:spec.get("longs", 0)])
        for idx, (size, value) in spec.get("outs", {}).items():
            emu.write(args[int(idx)], size, value)
        return spec.get("result", 0)
    return call


def _sized_pascal_stub(arg_bytes: int, size: int, result: int, calls: list, name: str):
    """Pascal glue stubbed alike on both sides (the runtime's real one not run): logged by name, its
    arguments popped, a result of `size` bytes (0: a procedure) left in the caller's slot."""
    def stub(emu) -> int:
        calls.append([name])
        emu.a[7] = (emu.a[7] + arg_bytes) & 0xFFFFFFFF
        if size:
            emu.write(emu.a[7], size, result)
        return result
    return stub


def run(case: dict) -> None:
    if case["segment"] == "overlay":
        emu = Emulator(MEMORY, str(OVERLAY), file_delta=0x20)
    else:
        emu = Emulator(MEMORY, str(CODE / f"{case['segment']}.bin"), file_delta=0)
    emu.a[5] = A5
    if case.get("image"):
        emu.mem[CARRIER:PAIRS + 0x100] = bytes(PAIRS + 0x100 - CARRIER)   # past the image: as the runtime's
    for slot in case.get("stubs", []):
        emu.stubs[A5 + slot] = _pascal_pop_4
    calls = []
    for slot, (arg_bytes, result) in case.get("pascal", {}).items():
        emu.stubs[A5 + int(slot, 16)] = _pascal_stub(arg_bytes, result, calls, f"jt {slot}")
    for slot, (arg_bytes, size, result) in case.get("pascal_stubs", {}).items():
        emu.stubs[A5 + int(slot, 16)] = _sized_pascal_stub(arg_bytes, size, result, calls, f"jt {slot}")
    for word, spec in case.get("trap_specs", {}).items():
        emu.traps[int(word, 16)] = _spec_trap(int(word, 16), spec, calls)
    for address, longs in case.get("overlay_stubs", {}).items():
        emu.stubs[int(address, 16)] = _code_stub({"at": address, "longs": longs}, calls)
    for stub in case.get("code_stubs", []):
        emu.stubs[int(_stub_at(stub), 16)] = _code_stub(stub, calls)
    for slot, (sizes, result) in case.get("c_stubs", {}).items():
        emu.stubs[A5 + int(slot, 16)] = _c_stub(sizes, result, calls, f"jt {slot}")
    for word, pops in case.get("traps", {}).items():
        def trap(e, n=pops, w=word):
            if n == 0:
                calls.append([f"trap {w:#x}"])
            else:
                calls.append([f"trap {w:#x}", e.read(e.a[7], 4) if n >= 4 else e.read(e.a[7], 2)])
            e.a[7] = (e.a[7] + n) & 0xFFFFFFFF
        emu.traps[word] = trap
    for addr, size, value in case["writes"]:
        emu.write(addr, size, value)
    if case.get("id01"):
        emu.mem[ID01_BASE:ID01_BASE + 0x22E] = (CODE / "ID01.bin").read_bytes()[:0x22E]
        for slot, target in ((0x2A, 0x96), (0x32, 0xAA), (0x3A, 0xBE)):
            emu.write(A5 + slot, 2, 0x4EF9)
            emu.write(A5 + slot + 2, 4, ID01_BASE + target)
    if "arg_sizes" in case:              # MPW C: shorts are pushed as words
        a7 = STACK_TOP
        pairs = list(zip(case["arg_sizes"], case["args"]))
        if case.get("pascal_call"):      # Pascal: the first argument is pushed first (highest)
            pairs.reverse()
        for size, value in reversed(pairs):
            a7 -= size
            emu.write(a7, size, value)
        d0 = emu.call(case["address"], [], a7) & 0xFFFFFFFF
    else:
        d0 = emu.call(case["address"], case["args"], STACK_TOP) & 0xFFFFFFFF
    if not case.get("void"):
        case["d0"] = d0 & {1: 0xFF, 2: 0xFFFF}.get(case.get("d0_size"), 0xFFFFFFFF)
    case["after"] = [[a, size, emu.read(a, size)] for a, size in case.get("check", [])]
    if case.get("log_calls"):
        case["calls"] = calls
    case.pop("check", None)
    case["traps"] = {f"{k:#x}": v for k, v in case.get("traps", {}).items()}


def build() -> dict:
    cases = (strlen_cases() + strncmp_cases() + ground_zone_cases() + gate_cases() + grey_map_cases()
             + erase_hook_cases() + session_cases() + settings_save_cases() + screen_globals_cases() + carrier_cases()
             + service_table_cases() + panel_release_cases() + store_failure_cases() + session_hook_cases()
             + dialog_item_cases() + click_cases() + quit_cases() + rank_insignia_cases()
             + map_dialog_cases() + refuel_cases() + high_scores_cases()
             + summary_filter_cases() + render_buffers_cases() + mission_awards_cases()
             + map_tracker_cases() + scenario_dialog_cases() + duty_roster_cases()
             + display_palette_cases() + protection_code_cases() + summary_text_cases()
             + readout_hook_cases())
    for c in cases:
        run(c)
    return {"source": "tools/hellcats/gen_runtime_cases.py", "cases": cases}


def main() -> int:
    text = json.dumps(build(), indent=1) + "\n"
    if "--check" in sys.argv:
        if not FIXTURE.exists() or FIXTURE.read_text(encoding="utf-8") != text:
            print(f"FAIL {FIXTURE.relative_to(ROOT)} is stale; rerun without --check")
            return 1
        print("PASS runtime routine cases are up to date")
        return 0
    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(text, encoding="utf-8")
    print(f"wrote {FIXTURE.relative_to(ROOT)}: {text.count('\"routine\"')} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
