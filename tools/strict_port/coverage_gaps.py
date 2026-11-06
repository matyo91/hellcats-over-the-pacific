#!/usr/bin/env python3
"""The mappings the smoke session never ran (runtime_verified false), split by whether the
original program can reach them at all.

A function is unreachable when every reference to it in the original bytes (tools/decomp/xrefs.py:
branches, PC-relative addresses, jump-table uses, relocated pointers) lies inside functions that are
themselves unreachable; one with no reference at all is the base case. Its missing coverage is
expected. The rest are reachable gaps the session could close.

Conservative: a reference counts as live when it lies in a function that ran, in a routine the
runtime writes outside the 740 (docs/architecture/GAME_RUNTIME.md's table), in the overlay's data (definition
records and other tables past its code), or anywhere no known function encloses. One exception:
install_overlay_service_table (ID02 0x1b42) only stores slot addresses in the overlay's host table
(its pairs as the runtime's id02_1b42 writes them), so its LEA of a slot is live only when the
overlay uses that host entry: in its bytes, an operand $off(aN) once aN holds the host pointer
($1b5a0), or in its semantic C, host_world + off. Two more kinds of reference are dead: an
overlay MOVE.L #routine, $slot.l into a slot no instruction ever reads (configure_renderer_for_display
fills span_filler_2 / _3, which nothing calls), and one inside a block DEAD_BLOCKS proves never
entered.

Some reachable gaps need what the runtime's sessions do not stage: NEEDS names them with what
each needs: a failure (an error path; a session stages one only through the program's own saved
files, as smoke_session.gd --missing-scenery does), another machine than the runtime's (a Mac short
of memory, a device colour table of its own), another scenery file (a definition whose key no object
of Pacific Conflict's world tree carries: checked against the tree, placed_keys), or longer or flown
play (a landing, a kill, a fire, an AI out of ammunition: the scripted sessions steer only roughly
and last minutes, and the original's random damage decides the rest). The
document lists them apart.

Writes docs/generated/RUNTIME_COVERAGE.md with --write; --check fails when that document is stale.

Usage: python3 tools/strict_port/coverage_gaps.py [--list | --write | --check]
"""
from __future__ import annotations

import bisect
import collections
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "decomp"))
import xrefs  # noqa: E402

MANIFEST = ROOT / "godot" / "strict_port" / "mappings" / "functions.json"
DOC = ROOT / "docs" / "generated" / "RUNTIME_COVERAGE.md"
INVENTORY = ROOT / "docs" / "DECOMPILATION_INVENTORY.json"
RUNTIME_DOC = ROOT / "docs" / "architecture" / "GAME_RUNTIME.md"
OVERLAY = "Pacific Conflict"
REF = re.compile(r"^(ID0\d|overlay): .* at (?:file )?(0x[0-9a-f]+)")
SLOT = re.compile(r"\$([0-9a-f]+)\(A5\)")
UNEXPORTED = ROOT / "godot" / "hellcats" / "runtime" / "unexported.gd"
OVERLAY_C = ROOT / "sources" / "resedit-1-0-3" / "CODE" / "Pacific Conflict.decomp.c"
INSTALLER = ("ID02", 0x1B42)                 # install_overlay_service_table (runtime-written)
HOST_POINTER = "$1b5a0.l"                    # the overlay's pointer to the host table
HOST_BASE = 0x1388                           # host entry +off is A5 - (0x1388 - off)
## Reachable gaps the sessions do not stage, by target function: (kind, what it needs).
FAILURE, MACHINE, SCENERY, FLOWN = ("only on a failure", "only on another machine", "only with another scenery",
                                   "only in longer or flown play")
WORLD_ROOT = 0x22994                         # the scenery's world tree (file 0x22994; kind 3 groups)
## Definition handlers whose definition key no object of the world tree carries: function -> key.
UNPLACED = {"create_spinner_controller": 6, "spin_object_heading": 6,
            "create_singleton_type10_controller": 0x10,
            "create_sinking_controller": 0x16, "tick_sinking_controller": 0x16}
LANDING = "a touchdown and stop on a friendly deck or runway (outcome 9: run_flight_session's refuel)"
APPROACH = ("the game's landing approach: Flying Fortress's B-17 completing its route, or 'G' with the "
            "hidden setting +0x0a (host +0xa4) set")
FIRE = "an aircraft set burning by its damage (+0x684 bit 0x10, update_aircraft_damage_state)"
NEEDS = {
    "fatal_memory_error_exit": (FAILURE, "the Memory Manager refusing a block (out of memory)"),
    "overlay_printf": (FAILURE, "an overlay diagnostic: a carrier without a deck tag (0x15154), a fractal "
                                "block still in use when its owner is released (release_fractal_reference)"),
    "widen_printf_format": (FAILURE, "an overlay diagnostic (overlay_printf's format)"),
    "show_caution_alert_with_number": (FAILURE, "a failed start-up check (system, display) or a failed load"),
    "show_sound_error_dialog_once": (FAILURE, "a sound resource that cannot be loaded"),
    "show_resource_file_error_box": (FAILURE, "MENU 2 missing from the application's resources"),
    "realloc_and_clear_handle_a5safe": (MACHINE, "a purgeable handle the Memory Manager has purged (a Mac "
                                        "short of memory; ensure_handle_allocated, overlay 0xdb0)"),
    "clear_ctab_size_callback": (MACHINE, "a device colour table mapping two of the first 200 palette "
                                  "entries to one index (build_palette_index_map then picks service $46a)"),
    **{f: (SCENERY, f"an object of definition key 0x{k:x}, which Pacific Conflict's world tree never "
                     "places (its controllers are made only through a descriptor's key byte, "
                     "_call_class_factory)") for f, k in UNPLACED.items()},
    "ai_fly": (FLOWN, "an AI aircraft left with two rounds or fewer (+0x682) after a dive or bombing "
                      "run: its out-of-ammunition state 0x11162"),
    "ai_script_try_fire_burst": (FLOWN, "a route AI reaching its firing phase (tick_ai_1b310_approach_fire "
                                        "phase 2, or the B-17's waypoint 4 in Flying Fortress, which "
                                        "--mission 5 --seconds 900 with the player parked does not reach)"),
    "destroy_flak_controller": (FLOWN, "the player destroying a flak battery (definition key 0x1a)"),
    "refuel_dialog_filter_proc": (FLOWN, LANDING),
    "any_mission_kills_recorded": (FLOWN, LANDING),
    "respawn_player_at_anchor": (FLOWN, LANDING + ", then the next sortie"),
    "fill_pose_history_flags": (FLOWN, LANDING + ", then the next sortie"),
    "load_player_fuel_and_bombs": (FLOWN, LANDING + ", then the next sortie"),
    "try_begin_landing_approach": (FLOWN, APPROACH),
    "find_nearest_runway_approach_ends": (FLOWN, APPROACH),
    "store_xyz_asr": (FLOWN, APPROACH),
    "tick_landing_approach_glide": (FLOWN, APPROACH),
    "tally_destroyed_entity": (FLOWN, "the player destroying a target (a kill tallied)"),
    "create_ground_fire_controller": (FLOWN, FIRE),
    "spawn_ground_fire_object": (FLOWN, FIRE),
    "attach_ground_fire": (FLOWN, FIRE),
    "destroy_ground_fire_controller": (FLOWN, FIRE),
    "animate_ground_fire": (FLOWN, FIRE),
    "tick_ground_fire": (FLOWN, FIRE),
}


## Overlay code the original never enters (file offsets, end exclusive): the reason.
DEAD_BLOCKS = [
    (0xc444, 0xc486, "update_heading_tape's depth-4 strip copy: its block (0xc42a) is entered only at "
                     "depth 8 (cmpi.w #8 / beq.w at 0xc328), where the depth-4 test at 0xc43a fails"),
]


_CODE = None


def overlay_code() -> list:
    """The overlay's code, disassembled once (file offsets)."""
    global _CODE
    if _CODE is None:
        import capstone
        image = xrefs.OVERLAY.read_bytes()
        md = capstone.Cs(capstone.CS_ARCH_M68K, capstone.CS_MODE_M68K_020)
        md.skipdata = True
        _CODE = list(md.disasm(image[xrefs.OVERLAY_DELTA:xrefs.OVERLAY_DELTA + int.from_bytes(image[4:8], "big")], xrefs.OVERLAY_DELTA))
    return _CODE


STORE = re.compile(r"^#\$[0-9a-f]+, \$([0-9a-f]+)\.l$")


def dead_store_sites() -> set[int]:
    """Instruction starts of MOVE.L #imm, $X.l whose X no instruction reads (only such stores name
    it)."""
    stores: dict[int, list[int]] = collections.defaultdict(list)
    other: set[int] = set()
    for ins in overlay_code():
        m = STORE.match(ins.op_str) if ins.mnemonic == "move.l" else None
        if m:
            stores[int(m.group(1), 16)].append(ins.address)
        for v in re.findall(r"\$([0-9a-f]+)\.l", ins.op_str if not m else ""):
            other.add(int(v, 16))
    return {a for slot, sites in stores.items() if slot not in other for a in sites}


def instruction_at(at: int) -> int:
    """The start of the overlay instruction holding file offset `at`."""
    code = overlay_code()
    i = bisect.bisect_right([ins.address for ins in code], at) - 1
    return code[i].address if i >= 0 else -1


def placed_keys() -> set[int]:
    """The definition keys (descriptor byte +1) of every leaf of the scenery's world tree: a kind 3
    group lists 0x18-byte children from +0x1a (count word +0x18), each pointing (+0x14, relative to
    the root) at a group or a leaf."""
    image = xrefs.OVERLAY.read_bytes()
    keys: set[int] = set()
    seen: set[int] = set()
    stack = [WORLD_ROOT]
    while stack:
        node = stack.pop()
        if node in seen:
            continue
        seen.add(node)
        if image[node] == 3:
            count = int.from_bytes(image[node + 0x18:node + 0x1a], "big", signed=True)
            for i in range(max(count, 0)):
                rel = int.from_bytes(image[node + 0x1a + 0x18 * i + 0x14:node + 0x1a + 0x18 * i + 0x18], "big")
                stack.append(WORLD_ROOT + rel)
        else:
            keys.add(image[node + 1])
    return keys


def host_entry_of_slot() -> dict[int, int]:
    """Slot -> host entry offset, from the runtime's id02_1b42 pairs [A5 offset, slot]."""
    src = UNEXPORTED.read_text(encoding="utf-8")
    body = src[src.index("func id02_1b42"):]
    body = body[:body.index("\nfunc ", 1)]
    return {int(slot, 16): HOST_BASE + int(a5, 16) for a5, slot in re.findall(r"\[(-0x[0-9a-f]+), (0x[0-9a-f]+)\]", body)}


def used_host_entries() -> set[int]:
    """Host entries the overlay uses: from its bytes and from its semantic C (a union)."""
    code = overlay_code()
    used: set[int] = set()
    holders: dict[str, int] = {}                  # address register -> instruction index it got the pointer
    for i, ins in enumerate(code):
        if ins.op_str.startswith(HOST_POINTER + ", a"):
            holders[ins.op_str[-2:]] = i
        for reg, at in list(holders.items()):
            if i - at > 12:
                del holders[reg]
                continue
            for off in re.findall(r"\$([0-9a-f]+)\(" + reg + r"\)", ins.op_str):
                used.add(int(off, 16))
    used |= {int(off, 16) for off in re.findall(r"host_world \+ 0x([0-9a-f]+)\)", OVERLAY_C.read_text(encoding="utf-8", errors="replace"))}
    return used


def segment_of(row: dict) -> str:
    return OVERLAY if OVERLAY in row["source_file"] else Path(row["source_file"]).name[:4]


def references(segment: str, address: int) -> list[tuple[str, int, int]]:
    """(segment, file offset, slot or -1) of each reference to the function, the jump-table slots
    themselves left out; the slot is the A5 offset an LEA / JSR / PEA slot(A5) names."""
    found = xrefs.overlay_xrefs(address) if segment == OVERLAY else xrefs.segment_xrefs(segment, address)
    out = []
    for r in found:
        m = REF.match(r)
        if m:
            s = SLOT.search(r)
            out.append((OVERLAY if m.group(1) == "overlay" else m.group(1), int(m.group(2), 16), int(s.group(1), 16) if s else -1))
    return out


def main(argv: list[str]) -> int:
    rows = json.loads(MANIFEST.read_text(encoding="utf-8"))["functions"]
    inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    inventory = inventory if isinstance(inventory, list) else inventory["functions"]
    # Function starts by segment: the inventory's, then the runtime-written routines (always live).
    starts: dict[str, dict[int, str]] = collections.defaultdict(dict)
    names: dict[tuple[str, int], str] = {}
    for r in inventory:
        starts[r["segment"]][int(r["original_address"], 16)] = "inventory"
        names[(r["segment"], int(r["original_address"], 16))] = r["semantic_name"]
    for seg, off in re.findall(r"^\| (ID0\d|Pacific Conflict) \| (0x[0-9a-f]+) \|", RUNTIME_DOC.read_text(encoding="utf-8"), re.M):
        address = int(off, 16) + (xrefs.OVERLAY_DELTA if seg == OVERLAY else 0)
        starts[seg][address] = "written"
    sorted_starts = {seg: sorted(s) for seg, s in starts.items()}
    image = xrefs.OVERLAY.read_bytes()
    overlay_code_end = xrefs.OVERLAY_DELTA + int.from_bytes(image[4:8], "big")

    by_key = {(segment_of(r), int(r["source_address"], 16)): r for r in rows}
    unrun = {k for k, r in by_key.items() if not r.get("runtime_verified")}
    refs = {k: references(*k) for k in unrun}

    placed = placed_keys()
    wrong = {f: k for f, k in UNPLACED.items() if k in placed}
    if wrong:
        raise SystemExit(f"UNPLACED names keys the world tree places: {wrong}")
    slot_host = host_entry_of_slot()
    used_hosts = used_host_entries()
    UNUSED = ("unused host entry", 0)                     # always counted unreachable
    dead_stores = dead_store_sites()

    def container(seg: str, at: int, slot: int):
        if seg == OVERLAY and at >= overlay_code_end:
            return None                                   # data: a table entry is a live use
        if seg == OVERLAY and (instruction_at(at) in dead_stores or any(a <= at < b for a, b, _ in DEAD_BLOCKS)):
            return UNUSED                                 # a store nothing reads, or code never entered
        s = sorted_starts.get(seg, [])
        i = bisect.bisect_right(s, at) - 1
        if i >= 0 and (seg, s[i]) == INSTALLER and slot in slot_host and slot_host[slot] not in used_hosts:
            return UNUSED                                 # stored in a host entry the overlay never uses
        if i < 0 or starts[seg][s[i]] == "written":
            return None
        return (seg, s[i])

    dead: set = set()
    changed = True
    while changed:
        changed = False
        for k in unrun - dead:
            holders = [container(seg, at, slot) for seg, at, slot in refs[k]]
            # every holder is unreachable or the function itself (recursion); none at all is the base case
            if all(h is not None and h in dead | {k, UNUSED} for h in holders):
                dead.add(k)
                changed = True

    def referrer(seg: str, at: int, slot: int) -> str:
        """Who holds a reference, for the document."""
        if seg == OVERLAY and at >= overlay_code_end:
            return "overlay data"
        s = sorted_starts.get(seg, [])
        i = bisect.bisect_right(s, at) - 1
        if i < 0:
            return f"{seg} 0x{at:x}"
        if (seg, s[i]) == INSTALLER:
            used = slot in slot_host and slot_host[slot] in used_hosts
            return f"the host table (+0x{slot_host.get(slot, 0):x}, {'used' if used else 'unused'} by the overlay)"
        if starts[seg][s[i]] == "written":
            return f"runtime-written {seg} 0x{s[i]:x}"
        return names.get((seg, s[i]), f"{seg} 0x{s[i]:x}")

    if "--write" in argv or "--check" in argv:
        text = document(rows, unrun, dead, by_key, refs, referrer)
        if "--check" in argv:
            if not DOC.exists() or DOC.read_text(encoding="utf-8") != text:
                print(f"FAIL {DOC.relative_to(ROOT)} is stale; rerun with --write")
                return 1
            print("PASS runtime coverage document is up to date")
            return 0
        DOC.write_text(text, encoding="utf-8")
        print(f"wrote {DOC.relative_to(ROOT)}")
        return 0

    table: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    for k in unrun:
        table[Path(by_key[k]["target_file"]).name]["unreachable" if k in dead else "reachable"] += 1
    print(f"{len(rows) - len(unrun)} of {len(rows)} mappings ran in the smoke session; {len(unrun)} did not:")
    print(f"  {'file':22} {'reachable':>9} {'unreachable':>11}")
    for name in sorted(table):
        print(f"  {name:22} {table[name]['reachable']:>9} {table[name]['unreachable']:>11}")
    total = sum(table.values(), collections.Counter())
    print(f"  {'total':22} {total['reachable']:>9} {total['unreachable']:>11}")
    if "--list" in argv:
        for label, chosen in (("unreachable in the original", dead), ("reachable, not run yet", unrun - dead)):
            print(f"{label}:")
            for k in sorted(chosen, key=lambda k: (Path(by_key[k]["target_file"]).name, k[1])):
                r = by_key[k]
                print(f"  {Path(r['target_file']).name}:{r['target_function']} ({r['source_address']})")
    return 0


def document(rows, unrun, dead, by_key, refs, referrer) -> str:
    def file_of(k):
        return Path(by_key[k]["target_file"]).name
    staged = {kind: {k for k in unrun - dead if NEEDS.get(by_key[k]["target_function"], ("",))[0] == kind}
              for kind in (FAILURE, MACHINE, SCENERY, FLOWN)}
    open_gaps = unrun - dead - set().union(*staged.values())
    order = lambda k: (file_of(k), k[1])
    lines = [
        "# Runtime coverage",
        "",
        "Generated by `tools/strict_port/coverage_gaps.py --write` from the mappings' `runtime_verified`",
        "(`tests/runtime/fixtures/smoke_coverage.json`) and the original bytes; do not edit by hand (`--check`",
        "in validation). The rules for reachable and unreachable are in that tool's docstring.",
        "",
        f"{len(rows) - len(unrun)} of {len(rows)} mappings have run in the runtime's sessions; {len(unrun)} have not:"
        f" {len(dead)} the original can never reach, "
        + ", ".join(f"{len(staged[kind])} {kind}" for kind in (FAILURE, MACHINE, SCENERY, FLOWN))
        + f", {len(open_gaps)} otherwise.",
        "",
        "| File | Ran | Reachable, not run | Unreachable |",
        "|---|---|---|---|",
    ]
    by_file: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    for r in rows:
        k = (segment_of(r), int(r["source_address"], 16))
        by_file[Path(r["target_file"]).name]["ran" if k not in unrun else "unreachable" if k in dead else "reachable"] += 1
    for name in sorted(by_file):
        c = by_file[name]
        lines.append(f"| {name} | {c['ran']} | {c['reachable']} | {c['unreachable']} |")
    lines += ["", "## Reachable, not run yet", ""]
    if open_gaps:
        lines += ["Each with what references it in the original (at most three).", "",
                  "| Function | Address | Referenced from |", "|---|---|---|"]
    else:
        lines += ["None: every mapping not run is accounted for in the sections below."]
    for k in sorted(open_gaps, key=order):
        holders = sorted({referrer(*ref) for ref in refs[k]})
        shown = ", ".join(holders[:3]) + (f" (+{len(holders) - 3})" if len(holders) > 3 else "")
        lines.append(f"| `{file_of(k)}` `{by_key[k]['target_function']}` | {by_key[k]['source_address']} | {shown} |")
    for kind, intro in ((FAILURE, "Error paths; the failure each needs."),
                        (MACHINE, "What another Mac than the runtime's would do; what each needs."),
                        (SCENERY, "Definitions the Pacific Conflict scenery never instantiates."),
                        (FLOWN, "What the scripted sessions do not fly or wait for; what each needs.")):
        lines += ["", f"## Reachable {kind}", "", intro, "", "| Function | Address | Needs |", "|---|---|---|"]
        for k in sorted(staged[kind], key=order):
            lines.append(f"| `{file_of(k)}` `{by_key[k]['target_function']}` | {by_key[k]['source_address']} | {NEEDS[by_key[k]['target_function']][1]} |")
    lines += ["", "## Unreachable in the original", "",
              "No reference, or only references from other unreachable code or unused host-table entries.", "",
              "| Function | Address |", "|---|---|"]
    for k in sorted(dead, key=order):
        lines.append(f"| `{file_of(k)}` `{by_key[k]['target_function']}` | {by_key[k]['source_address']} |")
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
