#!/usr/bin/env python3
"""Deterministic QA checks for the Godot tests, the game runtime's data and the scenes.

This script is intentionally static/data-oriented and complements (does not duplicate)
runtime Godot tests in `godot/tests/run_all.gd`.
"""

from __future__ import annotations

import ast
import json
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
GODOT_ROOT = REPO_ROOT / "godot"
GODOT_TESTS = GODOT_ROOT / "tests"
JUMP_TABLE = GODOT_ROOT / "hellcats" / "data" / "jump_table.json"
RUNNER_PATH = GODOT_TESTS / "run_all.gd"

EXPECTED_RUNNER_PATHS = [
    "res://tests/strict_port/test_c68k.gd",
    "res://tests/strict_port/test_memory_68k.gd",
    "res://tests/strict_port/test_contact_pair_hash.gd",
    "res://tests/strict_port/test_find_contact_record.gd",
    "res://tests/strict_port/test_reset_radar_tracks.gd",
    "res://tests/strict_port/test_abs_int.gd",
    "res://tests/strict_port/test_approx_dist3_xyz.gd",
    "res://tests/strict_port/test_camera_metric.gd",
    "res://tests/strict_port/test_sin_cos_fixed14.gd",
    "res://tests/strict_port/test_attitude_bases.gd",
    "res://tests/strict_port/test_attitude_matrix.gd",
    "res://tests/strict_port/test_attitude_variants.gd",
    "res://tests/strict_port/test_transform_vecs12.gd",
    "res://tests/strict_port/test_transform_int3.gd",
    "res://tests/strict_port/test_template_chain_xform.gd",
    "res://tests/strict_port/test_node_chain.gd",
    "res://tests/strict_port/test_scene_traversal.gd",
    "res://tests/strict_port/test_type80_visitor.gd",
    "res://tests/strict_port/test_clip_polygon.gd",
    "res://tests/strict_port/test_collect_map_features.gd",
    "res://tests/strict_port/test_plot_map_symbols.gd",
    "res://tests/strict_port/test_segment_point_min_distance.gd",
    "res://tests/strict_port/test_overlay_rng_retire.gd",
    "res://tests/strict_port/test_bullet_hits.gd",
    "res://tests/strict_port/test_dispatch_collision.gd",
    "res://tests/strict_port/test_facility_tally_cleanup.gd",
    "res://tests/strict_port/test_spawn_destruction_effect.gd",
    "res://tests/strict_port/test_tick_bullet.gd",
    "res://tests/strict_port/test_surface_type.gd",
    "res://tests/strict_port/test_spawn_effect.gd",
    "res://tests/strict_port/test_pool_spawn.gd",
    "res://tests/strict_port/test_heap.gd",
    "res://tests/strict_port/test_object_creation.gd",
    "res://tests/strict_port/test_object_buffers.gd",
    "res://tests/strict_port/test_activate.gd",
    "res://tests/strict_port/test_shading.gd",
    "res://tests/strict_port/test_sink.gd",
    "res://tests/strict_port/test_land_outline.gd",
    "res://tests/strict_port/test_factories.gd",
    "res://tests/strict_port/test_effect_init.gd",
    "res://tests/strict_port/test_aircraft_create.gd",
    "res://tests/strict_port/test_effect_animate.gd",
    "res://tests/strict_port/test_effect_debris.gd",
    "res://tests/strict_port/test_controller_ticks.gd",
    "res://tests/strict_port/test_ground_fire.gd",
    "res://tests/strict_port/test_trails.gd",
    "res://tests/strict_port/test_sinking_step.gd",
    "res://tests/strict_port/test_inverse_trig.gd",
    "res://tests/strict_port/test_turret.gd",
    "res://tests/strict_port/test_blast_damage.gd",
    "res://tests/strict_port/test_flak_gun.gd",
    "res://tests/strict_port/test_wave_spawner.gd",
    "res://tests/strict_port/test_aircraft_spawner.gd",
    "res://tests/strict_port/test_firing_ship.gd",
    "res://tests/strict_port/test_small_handlers.gd",
    "res://tests/strict_port/test_aircraft_handlers.gd",
    "res://tests/strict_port/test_aircraft_notice.gd",
    "res://tests/strict_port/test_fighter_notice.gd",
    "res://tests/strict_port/test_overlap_dispatch.gd",
    "res://tests/strict_port/test_landing_gear.gd",
    "res://tests/strict_port/test_damage_helpers.gd",
    "res://tests/strict_port/test_damage_state.gd",
    "res://tests/strict_port/test_aircraft_tick.gd",
    "res://tests/strict_port/test_flight_helpers.gd",
    "res://tests/strict_port/test_steering.gd",
    "res://tests/strict_port/test_flight_misc.gd",
    "res://tests/strict_port/test_flight_model.gd",
    "res://tests/strict_port/test_ai_states.gd",
    "res://tests/strict_port/test_ordnance.gd",
    "res://tests/strict_port/test_parachute.gd",
    "res://tests/strict_port/test_controller_misc.gd",
    "res://tests/strict_port/test_template_registration.gd",
    "res://tests/strict_port/test_radar.gd",
    "res://tests/strict_port/test_sound_effect_log.gd",
    "res://tests/strict_port/test_plume.gd",
    "res://tests/strict_port/test_pre_render.gd",
    "res://tests/strict_port/test_polygon.gd",
    "res://tests/strict_port/test_dots.gd",
    "res://tests/strict_port/test_object_list.gd",
    "res://tests/strict_port/test_visibility.gd",
    "res://tests/strict_port/test_collision.gd",
    "res://tests/strict_port/test_terrain.gd",
    "res://tests/strict_port/test_sim_step.gd",
    "res://tests/strict_port/test_camera.gd",
    "res://tests/strict_port/test_radar_blips.gd",
    "res://tests/strict_port/test_views.gd",
    "res://tests/strict_port/test_tracking_camera.gd",
    "res://tests/strict_port/test_frame_loop.gd",
    "res://tests/strict_port/test_clouds.gd",
    "res://tests/strict_port/test_altitude_bands.gd",
    "res://tests/strict_port/test_ground_scatter.gd",
    "res://tests/strict_port/test_small_math.gd",
    "res://tests/strict_port/test_gauges.gd",
    "res://tests/strict_port/test_readouts.gd",
    "res://tests/strict_port/test_panel_frame.gd",
    "res://tests/strict_port/test_heading_tape.gd",
    "res://tests/strict_port/test_sky_ground.gd",
    "res://tests/strict_port/test_copy_rect.gd",
    "res://tests/strict_port/test_line8.gd",
    "res://tests/strict_port/test_line4.gd",
    "res://tests/strict_port/test_face_emit.gd",
    "res://tests/strict_port/test_face_output.gd",
    "res://tests/strict_port/test_object_pipeline.gd",
    "res://tests/strict_port/test_transform_object.gd",
    "res://tests/strict_port/test_render_objects.gd",
    "res://tests/strict_port/test_sort_parts.gd",
    "res://tests/strict_port/test_span_fill.gd",
    "res://tests/strict_port/test_span4.gd",
    "res://tests/strict_port/test_scan_convert.gd",
    "res://tests/strict_port/test_colour_setup.gd",
    "res://tests/strict_port/test_session_buffers.gd",
    "res://tests/strict_port/test_anchor_present.gd",
    "res://tests/strict_port/test_flight_start.gd",
    "res://tests/strict_port/test_mission_start.gd",
    "res://tests/strict_port/test_overlay_entry.gd",
    "res://tests/strict_port/test_mission_tables.gd",
    "res://tests/strict_port/test_distant_dots.gd",
    "res://tests/strict_port/test_renderer_config.gd",
    "res://tests/strict_port/test_slew_mode.gd",
    "res://tests/strict_port/test_game_sounds.gd",
    "res://tests/strict_port/test_frame_step.gd",
    "res://tests/strict_port/test_flight_input.gd",
    "res://tests/strict_port/test_id01_divide.gd",
    "res://tests/strict_port/test_id02_crt.gd",
    "res://tests/strict_port/test_id02_trapfree.gd",
    "res://tests/strict_port/test_id02_glue.gd",
    "res://tests/strict_port/test_id02_toolbox.gd",
    "res://tests/strict_port/test_id02_dialog.gd",
    "res://tests/strict_port/test_id02_palette.gd",
    "res://tests/strict_port/test_id02_draw.gd",
    "res://tests/strict_port/test_id02_memory.gd",
    "res://tests/strict_port/test_id02_menu.gd",
    "res://tests/strict_port/test_id05_protection.gd",
    "res://tests/strict_port/test_id06_raster.gd",
    "res://tests/strict_port/test_id07_09.gd",
    "res://tests/strict_port/test_id04_dialog.gd",
    "res://tests/strict_port/test_id04_scroll.gd",
    "res://tests/strict_port/test_id04_filter.gd",
    "res://tests/strict_port/test_id04_draw.gd",
    "res://tests/strict_port/test_id04_about.gd",
    "res://tests/strict_port/test_id04_summary.gd",
    "res://tests/strict_port/test_id05_dialog.gd",
    "res://tests/strict_port/test_id08_09_glue.gd",
    "res://tests/strict_port/test_id08_loader.gd",
    "res://tests/strict_port/test_id06_render.gd",
    "res://tests/strict_port/test_id03_helpers.gd",
    "res://tests/strict_port/test_id03_glyph.gd",
    "res://tests/strict_port/test_id03_panel.gd",
    "res://tests/strict_port/test_id03_boxes.gd",
    "res://tests/strict_port/test_id03_supersample.gd",
    "res://tests/strict_port/test_id03_gauges.gd",
    "res://tests/strict_port/test_id03_remap.gd",
    "res://tests/strict_port/test_id03_downsample.gd",
    "res://tests/strict_port/test_id03_prepare.gd",
    "res://tests/strict_port/test_id02_session.gd",
    "res://tests/strict_port/test_id02_display.gd",
    "res://tests/strict_port/test_id02_events.gd",
    "res://tests/strict_port/test_id02_commands.gd",
    "res://tests/strict_port/test_id02_sound.gd",
    "res://tests/strict_port/test_id02_startup.gd",
    "res://tests/strict_port/test_id02_flight.gd",
    "res://tests/strict_port/test_resedit_dialogs.gd",
    "res://tests/strict_port/test_resedit_interface.gd",
    "res://tests/strict_port/test_resedit_text.gd",
    "res://tests/strict_port/test_resedit_media.gd",
    "res://tests/runtime/test_unexported_routines.gd",
    "res://tests/runtime/test_sound_channels.gd",
    "res://tests/runtime/test_event_mask.gd",
    "res://tests/runtime/test_menu_bar.gd",
    "res://tests/runtime/test_alert.gd",
    "res://tests/runtime/test_dialog_edit.gd",
]

EXPECTED_LOADER_TARGETS = [
    {"segment_id": 2, "stored_tail": 0x199E, "entrypoint_offset": 0x19A2, "id00_entry_offset": 776},
    {"segment_id": 5, "stored_tail": 0x0000, "entrypoint_offset": 0x0004, "id00_entry_offset": 1368},
    {"segment_id": 6, "stored_tail": 0x0E0C, "entrypoint_offset": 0x0E10, "id00_entry_offset": 392},
    {"segment_id": 6, "stored_tail": 0x096A, "entrypoint_offset": 0x096E, "id00_entry_offset": 424},
    {"segment_id": 6, "stored_tail": 0x09D4, "entrypoint_offset": 0x09D8, "id00_entry_offset": 432},
    {"segment_id": 7, "stored_tail": 0x018C, "entrypoint_offset": 0x0190, "id00_entry_offset": 1408},
]



def fail(msg: str) -> None:
    raise AssertionError(msg)


def parse_runner_paths(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    marker = "const TEST_PATHS := ["
    start = text.find(marker)
    if start < 0:
        fail("run_all.gd: TEST_PATHS constant not found")
    rest = text[start + len(marker) :]
    end = rest.find("]")
    if end < 0:
        fail("run_all.gd: TEST_PATHS closing ']' not found")

    list_body = rest[: end + 1]
    list_text = "[" + list_body
    list_text = list_text.replace("\t", " ").replace("\r", "")
    try:
        parsed = ast.literal_eval(list_text)
    except Exception as exc:  # pragma: no cover
        fail(f"run_all.gd: could not parse TEST_PATHS ({exc})")
    if not isinstance(parsed, list) or not all(isinstance(v, str) for v in parsed):
        fail("run_all.gd: TEST_PATHS must be a list of strings")
    return parsed


def check_runner_layout() -> None:
    if not RUNNER_PATH.exists():
        fail("Missing godot/tests/run_all.gd")
    got = parse_runner_paths(RUNNER_PATH)
    if got != EXPECTED_RUNNER_PATHS:
        fail(
            "run_all.gd TEST_PATHS drifted.\n"
            f"got={got}\nwant={EXPECTED_RUNNER_PATHS}"
        )

    for res_path in got:
        rel = res_path.replace("res://", "", 1)
        fp = GODOT_ROOT / rel
        if not fp.exists():
            fail(f"run_all.gd references missing test file: {res_path}")


def _load_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"Invalid JSON at {path}: {exc}")


def check_loader_targets() -> None:
    """The proven loader targets are jump-table entries of CODE 0 as the game runtime links them."""
    table = _load_json(JUMP_TABLE)
    if not isinstance(table, dict) or not isinstance(table.get("entries"), list):
        fail(f"{JUMP_TABLE} must hold an object with array key 'entries'")
    base = table["jump_table_offset"]
    by_offset = {e["a5_offset"]: e for e in table["entries"]}
    for target in EXPECTED_LOADER_TARGETS:
        if target["entrypoint_offset"] != target["stored_tail"] + 4:
            fail(f"loader target {target}: entrypoint_offset must equal stored_tail + 4")
        # A CODE 0 entry is 8 bytes after its 16-byte header; the JMP's A5 offset is 2 bytes in.
        a5_offset = base + target["id00_entry_offset"] - 16 + 2
        entry = by_offset.get(a5_offset)
        if entry is None:
            fail(f"loader target {target}: no jump-table entry at A5+0x{a5_offset:x}")
        if (entry["segment"], entry["target"]) != (target["segment_id"], target["entrypoint_offset"]):
            fail(f"loader target {target}: jump table has segment {entry['segment']} +0x{entry['target']:x}")


def check_game_scenes() -> None:
    """The main scene runs the original game (scenes/game/Game.tscn); the MVP prototype is gone."""
    main = (GODOT_ROOT / "scenes" / "main" / "Main.tscn").read_text(encoding="utf-8")
    if 'path="res://scenes/game/Game.tscn"' not in main:
        fail("scenes/main/Main.tscn must instance res://scenes/game/Game.tscn")
    project = (GODOT_ROOT / "project.godot").read_text(encoding="utf-8")
    if 'run/main_scene="res://scenes/main/Main.tscn"' not in project:
        fail("project.godot main scene must be res://scenes/main/Main.tscn")
    for gone in ("hellcats/core", "hellcats/flight", "hellcats/mission", "hellcats/player", "hellcats/ui",
                 "hellcats/world", "data/mission_01", "tests/unit", "tests/integration"):
        if (GODOT_ROOT / gone).exists():
            fail(f"godot/{gone} belongs to the removed MVP prototype")


def check_01a48_kind2_jsr_bytes() -> None:
    """PROVEN: kind2/B572 LEA $1A48, but $1A48 is heap_free epilogue; $1A68 is heap_alloc."""
    binary = REPO_ROOT / "sources" / "mac-os-9" / "Pacific Conflict"
    if not binary.is_file():
        fail(f"Missing binary: {binary}")
    data = binary.read_bytes()
    if len(data) < 0xB57A:
        fail(f"Pacific Conflict too small: {len(data)}")
    # @0x4ED8: LEA $00001A48,A2 ; JSR (A2) ; MOVE.L D0,$4C(A4)
    if data[0x4ED8:0x4EE4] != bytes.fromhex("45f900001a484e922940004c"):
        fail(f"kind2 first JSR drifted: {data[0x4ED8:0x4EE4].hex()}")
    # second JSR (A2) ; MOVE.L D0,$44(A4)
    if data[0x4EE6:0x4EEC] != bytes.fromhex("4e9229400044"):
        fail(f"kind2 second JSR drifted: {data[0x4EE6:0x4EEC].hex()}")
    # @0xB572: same LEA $1A48 pattern (another malloc-style site)
    if data[0xB572:0xB57A] != bytes.fromhex("47f900001a484e93"):
        fail(f"B572 LEA/JSR drifted: {data[0xB572:0xB57A].hex()}")
    # @0x1A48: MOVE.L A1,$20C60 ; BRA.B $1A64 — free epilogue, not alloc
    if data[0x1A48:0x1A50] != bytes.fromhex("23c900020c606014"):
        fail(f"$1A48 free-epi drifted: {data[0x1A48:0x1A50].hex()}")
    # @0x1A64: MOVEA.L (A7)+,A2 ; RTS — restores free's saved A2
    if data[0x1A64:0x1A68] != bytes.fromhex("245f4e75"):
        fail(f"$1A64 free RTS drifted: {data[0x1A64:0x1A68].hex()}")
    # @0x1A68: MOVEM.L D2-D3/A2,-(A7) — real heap_alloc prologue (= LEA+0x20)
    if data[0x1A68:0x1A6C] != bytes.fromhex("48e73020"):
        fail(f"$1A68 prologue drifted: {data[0x1A68:0x1A6C].hex()}")
    # Alloc reads size at $10(a7) after MOVEM — matches push-size then JSR convention
    if data[0x1A6C:0x1A70] != bytes.fromhex("242f0010"):
        fail(f"$1A68 size slot drifted: {data[0x1A6C:0x1A70].hex()}")


def check_global_alias_docs() -> None:
    """Every `#define alias DAT_xxxx` in a *.decomp.c has one matching DECOMPILATION_SYMBOLS.md row, and back."""
    define_re = re.compile(r"^#define\s+(\w+)\s+(_?DAT_[0-9A-Fa-f]+|PTR_\w+)\b", re.M)
    row_re = re.compile(r"\|\s*([^|]+?)\s*\|\s*`(\w+)`\s*\|\s*`(_?DAT_[0-9A-Fa-f]+|PTR_\w+)`\s*\|")
    rows: dict[str, dict[str, str]] = {}
    for line in (REPO_ROOT / "docs" / "DECOMPILATION_SYMBOLS.md").read_text(encoding="utf-8").splitlines():
        match = row_re.match(line)
        if match:
            rows.setdefault(match.group(1), {})[match.group(2)] = match.group(3)
    seen = set()
    for path in sorted((REPO_ROOT / "sources" / "resedit-1-0-3" / "CODE").glob("*.decomp.c")):
        segment = path.name[: -len(".decomp.c")]
        defines = dict(define_re.findall(path.read_text(encoding="utf-8")))
        documented = rows.get(segment, {})
        seen.add(segment)
        missing = sorted(set(defines) - set(documented))
        extra = sorted(set(documented) - set(defines))
        wrong = sorted(a for a in defines if a in documented and documented[a] != defines[a])
        if missing or extra or wrong:
            fail(f"{segment} global aliases out of sync: undocumented {missing[:5]}, "
                 f"no define {extra[:5]}, symbol mismatch {wrong[:5]}")
    unknown = sorted(set(rows) - seen)
    if unknown:
        fail(f"DECOMPILATION_SYMBOLS.md alias rows for unknown segments: {unknown}")


def check_optional_capstone() -> str:
    """Optional: Capstone m68k import. Returns PASS/SKIP message suffix."""
    try:
        import capstone  # type: ignore
        from capstone import CS_ARCH_M68K, CS_MODE_BIG_ENDIAN, Cs  # type: ignore

        _ = Cs(CS_ARCH_M68K, CS_MODE_BIG_ENDIAN)
        return f"available ({capstone.__version__})"
    except Exception as exc:  # pragma: no cover
        return f"skipped ({exc})"


def check_optional_ghidra() -> str:
    import os

    root = Path(os.environ.get("GHIDRA_INSTALL_DIR", "/Users/math/Sites/tests/ghidra_12.1.x"))
    headless = root / "support" / "analyzeHeadless"
    if not headless.is_file():
        return "skipped (analyzeHeadless not found)"
    return f"available ({root})"


def check_runtime_coverage() -> None:
    """Everything the strict port can call has a routine behind it in the game runtime: the
    jump-table slots and segment-local offsets the ports call, the slots the CODE segments hand out
    as procedure pointers (PEA / LEA d16(A5), UnloadSeg's segment names aside), the code pointers in
    the overlay's relocation table, and the trap words the ports use."""
    hellcats = GODOT_ROOT / "hellcats"
    runtime_src = "\n".join(p.read_text(encoding="utf-8") for p in sorted(hellcats.glob("**/*.gd")))
    entries = {e["a5_offset"]: e for e in _load_json(JUMP_TABLE)["entries"]}
    segment_methods = _load_json(hellcats / "data" / "segment_methods.json")
    overlay_methods = {int(k, 16) for k in _load_json(hellcats / "data" / "overlay_methods.json")}
    stand_ins = {int(m, 16) for m in re.findall(r"stand_ins\[(0x[0-9a-f]+)\] =", runtime_src)}
    provided = {off for off, e in entries.items() if e["method"]} | stand_ins
    locals_ = {}
    for seg, off in re.findall(r"register_local\((\d+), (0x[0-9a-f]+)", runtime_src):
        locals_.setdefault(seg, set()).add(int(off, 16))
    installed = {int(w, 16) for w in re.findall(r"install\((0xa[0-9a-f]{3})", runtime_src)}
    for group in re.findall(r"for word in \[([^\]]*)\]", runtime_src):
        installed |= {int(w, 16) for w in re.findall(r"0xa[0-9a-f]{3}", group)}
    # Only on sysenvirons_glue_fallback's path, which needs SysEnvirons missing (the runtime has it).
    unreachable_traps = {0xA260, 0xA207}
    problems = []
    for path in sorted((GODOT_ROOT / "strict_port" / "code").glob("*.gd")):
        src = path.read_text(encoding="utf-8")
        consts = {m.group(1): int(m.group(2), 16) for m in re.finditer(r"^const (\w+): int = (0x[0-9a-f]+)", src, re.M)}
        value = lambda tok: int(tok, 16) if tok.startswith("0x") else consts.get(tok)
        for tok in re.findall(r"_jt\((\w+)", src):
            off = value(tok)
            if off in entries and off not in provided:
                problems.append(f"{path.name}: jump-table slot ${off:x} has no routine")
        if path.name.startswith("ID"):
            seg = str(int(path.name[2:4]))
            for tok in re.findall(r"_local\((\w+)", src):
                off = value(tok)
                ported = f"0x{off:x}" in segment_methods.get(seg, {}) if off is not None else True
                if off is not None and not ported and off not in locals_.get(seg, set()):
                    problems.append(f"{path.name}: segment {seg} offset 0x{off:x} has no routine")
        for tok in re.findall(r"_trap\((\w+)", src):
            word = value(tok)
            if word is not None and 0xA000 <= word <= 0xAFFF and word not in installed | unreachable_traps:
                problems.append(f"{path.name}: trap {word:04x} ({tok}) is not installed")
    code_dir = REPO_ROOT / "sources" / "resedit-1-0-3" / "CODE"
    for n in range(1, 10):
        b = (code_dir / f"ID0{n}.bin").read_bytes()
        for o in range(0, len(b) - 6, 2):
            if int.from_bytes(b[o:o + 2], "big") in (0x486D, 0x41ED, 0x43ED, 0x45ED, 0x47ED, 0x49ED):
                disp = int.from_bytes(b[o + 2:o + 4], "big", signed=True)
                unload = int.from_bytes(b[o + 4:o + 6], "big") == 0xA9F1
                if disp > 0 and disp in entries and disp not in provided and not unload:
                    problems.append(f"ID0{n} 0x{o:x}: slot ${disp:x} passed as a procedure has no routine")
    scenery = (hellcats / "data" / "scenery" / "Pacific Conflict").read_bytes()
    u32 = lambda o: int.from_bytes(scenery[o:o + 4], "big")
    port_src = (GODOT_ROOT / "strict_port" / "code" / "pacific_conflict.gd").read_text(encoding="utf-8")
    rts_only = re.search(r"^const RTS_ONLY := \[([^\]]*)\]", port_src, re.M).group(1)
    covered = overlay_methods | {int(a, 16) for a in re.findall(r"0x[0-9a-f]+", rts_only)}
    covered |= {int(a, 16) for a in re.findall(r"code_table\[(0x[0-9a-f]+)\] =", port_src + runtime_src)}
    covered |= {int(a, 16) for a in re.findall(r"(0x[0-9a-f]+): \"_", runtime_src)}
    code, data = u32(4), u32(8)
    first, second = u32(24) // 8, u32(28) // 8
    at = 0x20 + code + data
    for i in range(first + second):
        offset, flags = u32(at), u32(at + 4)
        at += 8
        if (flags >> 7) & 1:
            continue
        cell = offset + (code if i >= first else 0)
        target = u32(0x20 + cell)
        if target < code and target not in covered:
            problems.append(f"overlay cell 0x{cell:x}: code pointer 0x{target:x} has no routine")
    # An "Unexported function" block in a semantic decompilation must not name a ported function.
    seg_of = {f"ID0{n}": str(n) for n in range(10)}
    for path in sorted(code_dir.glob("*.decomp.c")):
        text = path.read_text(encoding="utf-8", errors="replace")
        for m in re.finditer(r"Unexported functions? at (ID0\d|overlay) offsets? (0x[0-9a-f]+)", text):
            seg, off = m.group(1), int(m.group(2), 16)
            if seg == "overlay":
                ported = (off - 0x20) in overlay_methods
            else:
                ported = f"0x{off:x}" in segment_methods.get(seg_of[seg], {})
            if ported:
                problems.append(f"{path.name}: the unexported block at {seg} 0x{off:x} names a ported function")
    if problems:
        fail("runtime coverage:\n  " + "\n  ".join(problems))


def check_resedit_mirror() -> None:
    import subprocess
    result = subprocess.run([sys.executable, str(REPO_ROOT / "tools" / "strict_port" / "import_resedit.py"), "--check"],
                            capture_output=True, text=True)
    if result.returncode != 0:
        fail("the resource folders in godot/strict_port drifted from sources/resedit-1-0-3:\n" + result.stdout)


def check_source_extraction() -> None:
    """check_sync's function extractor finds the definition, not a comment that names the function
    with parentheses after it (twelve mappings had been hashed over such a comment and the function
    after it, the wrapped-signature pattern spanning lines from the comment)."""
    sys.path.insert(0, str(REPO_ROOT / "tools" / "strict_port"))
    import check_sync
    source = (
        "/* see also\n"
        " * the gauge (target_routine flags 0x0f), drawn after (other_helper, x)\n"
        " */\n"
        "void decoy /* Original: FUN_1 */\n"
        "   (short a)\n"
        "{\n  return;\n}\n"
        "void target_routine /* Original: FUN_2 */\n"
        "   (short b)\n"
        "{\n  b = 1;\n}\n"
    )
    found = check_sync.extract_function(source, "target_routine")
    if not found.startswith("void target_routine"):
        fail("check_sync.extract_function matched a comment instead of the definition:\n" + found[:120])


def check_xrefs() -> None:
    """tools/decomp/xrefs.py finds the cross-references already established in the bytes: a jump-table
    call across segments, an overlay definition record, an intra-segment JSR d16(PC), and none for an
    unreferenced routine."""
    sys.path.insert(0, str(REPO_ROOT / "tools" / "decomp"))
    import xrefs
    cases = [
        (("ID04", 0x432), ["jump-table slot $172", "ID02: JSR $172(A5) at 0x2fe2"]),
        (("Pacific Conflict", 0x155D8), ["overlay: long 0x155b8 at file 0x1aaf0 (after 0016)"]),
        (("ID05", 0x3BA), ["ID05: JSR d16(PC) at 0x57c"]),
        (("Pacific Conflict", 0x54), ["overlay: BSR.L at 0x16e6"]),
        (("Pacific Conflict", 0x168AE), []),            # its value at runtime 0x2a7fc is not relocated
        (("ID05", 0xBA8), []),
    ]
    for (segment, target), expected in cases:
        got = xrefs.overlay_xrefs(target) if segment == "Pacific Conflict" else xrefs.segment_xrefs(segment, target)
        if got != expected:
            fail(f"xrefs {segment} 0x{target:x}: {got}, expected {expected}")


def check_entry_points() -> None:
    """Every entry point the bytes publish is accounted for. Each CODE 0 jump-table entry names a
    registry function start, a routine of GAME_RUNTIME.md's index, a segment's unload handle (offset
    4, used only as PEA slot(A5) before _UnloadSeg), or an offset its segment's decomp documents; every
    relocated overlay pointer into the code lands on a registry function start or a known entry."""
    import struct
    sys.path.insert(0, str(REPO_ROOT / "tools" / "decomp"))
    import xrefs
    rows = json.loads((REPO_ROOT / "docs" / "DECOMPILATION_INVENTORY.json").read_text(encoding="utf-8"))
    rows = rows if isinstance(rows, list) else rows["functions"]
    starts = {(r["segment"], int(r["original_address"], 16)) for r in rows}
    runtime_doc = (REPO_ROOT / "docs" / "GAME_RUNTIME.md").read_text(encoding="utf-8")
    index = runtime_doc[runtime_doc.index("## Routines outside the 740"):]
    indexed = {(m.group(1), int(m.group(2), 16)) for m in re.finditer(r"\| (ID0\d) \| (0x[0-9a-f]+) \|", index)}
    code_dir = REPO_ROOT / "sources" / "resedit-1-0-3" / "CODE"
    problems = []
    for e in json.loads((REPO_ROOT / "godot" / "hellcats" / "data" / "jump_table.json").read_text(encoding="utf-8"))["entries"]:
        segment, target = f"ID0{e['segment']}", int(e["target"])
        if (segment, target) in starts or (segment, target) in indexed:
            continue
        if target == 4:
            uses = xrefs.segment_xrefs(segment, 4)[1:]
            if uses and all(" PEA " in f" {u.split(': ', 1)[1]}" and struct.unpack(">H", (code_dir / f"{u.split(':')[0]}.bin").read_bytes()[
                    int(u.rsplit("0x", 1)[1], 16) + 4:int(u.rsplit("0x", 1)[1], 16) + 6])[0] == 0xA9F1 for u in uses):
                continue
        decomp = (code_dir / f"{segment}.decomp.c").read_text(encoding="utf-8", errors="replace").lower()
        if not re.search(rf"\b0x0*{target:x}\b", decomp):
            problems.append(f"jump-table slot ${int(e['a5_offset']):x} -> {segment} 0x{target:x} is not accounted for")
    image = (REPO_ROOT / "godot" / "hellcats" / "data" / "scenery" / "Pacific Conflict").read_bytes()
    code = struct.unpack(">I", image[4:8])[0]
    overlay_starts = {a - 0x20 for s, a in starts if s == "Pacific Conflict"}
    known = {0x4B0, 0xD23A, 0x15134, 0x16208,        # runtime-written routines (GAME_RUNTIME.md)
             0x12740, 0x12744,                       # clr.l d0; rts tails in face_object_to_camera
             0x12F70, 0x14326,                       # the RTS-only stubs
             0x177F0}                                # draw_radar_blip_depth8, a second entry
    for cell in xrefs.relocated_cells(image):
        target = struct.unpack(">I", image[cell + 0x20:cell + 0x24])[0]
        if 0 < target < code and target not in overlay_starts and target not in known:
            problems.append(f"overlay pointer at runtime 0x{cell:x} -> 0x{target:x} lands on no known entry")
    if problems:
        fail("entry points:\n  " + "\n  ".join(problems))


def check_trap_annotations() -> None:
    """Every call annotation a semantic decompilation writes beside its C is in the function's bytes
    (its start up to the next registry function): a trap word (/* $Axxx */) issued there or by an ID09
    glue routine it calls (that glue's body, up to the next entry); a jump-table slot (JT $xxx) used by
    a JSR / PEA / LEA slot(A5); a branch target (BSR / JSR 0xnnnn) reached by a BSR or JSR d16(PC)."""
    import struct
    sys.path.insert(0, str(REPO_ROOT / "tools" / "decomp"))
    import inventory_functions
    import xrefs
    rows = json.loads((REPO_ROOT / "docs" / "DECOMPILATION_INVENTORY.json").read_text(encoding="utf-8"))
    rows = rows if isinstance(rows, list) else rows["functions"]
    starts: dict[str, list[int]] = {}
    for r in rows:
        starts.setdefault(r["segment"], []).append(int(r["original_address"], 16))
    for v in starts.values():
        v.sort()
    code_dir = REPO_ROOT / "sources" / "resedit-1-0-3" / "CODE"
    glue = (code_dir / "ID09.bin").read_bytes()
    entries = json.loads((REPO_ROOT / "godot" / "hellcats" / "data" / "jump_table.json").read_text(encoding="utf-8"))["entries"]
    targets = sorted({int(e["target"]) for e in entries if e["segment"] == 9} | set(starts["ID09"]))
    issued_by_slot: dict[int, set[int]] = {}
    for e in entries:
        if e["segment"] != 9:
            continue
        t = int(e["target"])
        end = next((x for x in targets if x > t), len(glue))
        words = {struct.unpack(">H", glue[o:o + 2])[0] for o in range(t, end - 1, 2)}
        issued_by_slot[int(e["a5_offset"])] = {w & ~0x400 for w in words if w >> 12 == 0xA}
    problems = []
    for path in sorted(code_dir.glob("*.decomp.c")):
        segment = path.name.replace(".decomp.c", "")
        if segment in ("ID00", "ID09"):
            continue
        image = (REPO_ROOT / "godot" / "hellcats" / "data" / "scenery" / "Pacific Conflict") if segment == "Pacific Conflict" else code_dir / f"{segment}.bin"
        data = image.read_bytes()
        text = path.read_text(encoding="utf-8", errors="replace")
        for d in inventory_functions.definitions(path):
            if not d["original_ids"]:
                continue
            start = int(d["original_ids"][-1][4:], 16)
            end = next((x for x in starts[segment] if x > start), len(data))
            region = data[start:end]
            body_words = {struct.unpack(">H", region[o:o + 2])[0] & ~0x400 for o in range(0, len(region) - 1, 2)}
            glue_words = set()
            for slot, words in issued_by_slot.items():
                if struct.pack(">Hh", 0x4EAD, slot) in region:
                    glue_words |= words
            body = text[d["start"]:d["end"]]
            for w in {int(x, 16) for x in re.findall(r"/\*[^*]*?\$([Aa][0-9A-Fa-f]{3})\b", body)}:
                if w & ~0x400 not in body_words and w & ~0x400 not in glue_words:
                    problems.append(f"{segment} {d['name']}: ${w:X} is neither in its bytes nor in a glue it calls")
            # "JT $xxx": a JSR / PEA / LEA slot(A5) in its bytes.
            for slot in {int(x, 16) for x in re.findall(r"/\*[^*]*?\bJT \$([0-9a-fA-F]{2,3})\b", body)}:
                if not any(struct.pack(">Hh", op, slot) in region for op in [0x4EAD, 0x486D] + [0x41ED | (r << 9) for r in range(8)]):
                    problems.append(f"{segment} {d['name']}: JT ${slot:x} is not used in its bytes")
            # "BSR / JSR 0xnnnn": a branch from its bytes to that offset (overlay: file or runtime address).
            for t in {int(x, 16) for x in re.findall(r"/\*[^*]*?\b(?:BSR|BSR\.[WLS]|JSR)\s+(?:file\s+)?0x([0-9a-fA-F]+)\b", body)}:
                candidates = [t] + ([t + 0x20] if segment == "Pacific Conflict" else [])
                if not any(xrefs.branches(region, c - start) for c in candidates):
                    problems.append(f"{segment} {d['name']}: no branch to 0x{t:x} in its bytes")
    if problems:
        fail("call annotations:\n  " + "\n  ".join(problems))


def check_port_headers() -> None:
    """Every strict-port function cites the address it translates in its doc comment: a leading
    "## 0xnnnn" that is one of its mapping rows' source addresses (overlay: file or runtime), or that
    address elsewhere in the comment."""
    mapping = json.loads((REPO_ROOT / "godot" / "strict_port" / "mappings" / "functions.json").read_text(encoding="utf-8"))
    rows = mapping["functions"] if isinstance(mapping, dict) else mapping
    targets: dict[tuple[str, str], list[int]] = {}
    for r in rows:
        targets.setdefault((r["target_file"], r["target_function"]), []).append(int(r["source_address"], 16))
    texts: dict[str, list[str]] = {}
    problems = []
    for (path, name), addresses in sorted(targets.items()):
        lines = texts.setdefault(path, (REPO_ROOT / path).read_text(encoding="utf-8").split("\n"))
        at = next((i for i, line in enumerate(lines) if re.match(rf"(static )?func {re.escape(name)}\(", line)), None)
        if at is None:
            problems.append(f"{path}: {name} not found")
            continue
        header = []
        j = at - 1
        while j >= 0 and lines[j].startswith("##"):
            header.insert(0, lines[j])
            j -= 1
        accepted = {a for x in addresses for a in (x, x - 0x20, x + 0x20)}
        lead = re.match(r"## (0x[0-9a-f]+)", header[0]) if header else None
        if lead:
            if int(lead.group(1), 16) not in accepted:
                problems.append(f"{path}: {name} leads with {lead.group(1)}, not its source address")
        elif not any(re.search(rf"0x0*{a:x}\b", " ".join(header)) for a in accepted):
            problems.append(f"{path}: {name} does not cite its source address")
    if problems:
        fail("strict-port headers:\n  " + "\n  ".join(problems))


def check_runtime_headers() -> None:
    """Every routine of GAME_RUNTIME.md's index of routines outside the 740 is defined in the runtime and
    its doc comment cites the address the index gives."""
    doc = (REPO_ROOT / "docs" / "GAME_RUNTIME.md").read_text(encoding="utf-8")
    index = doc[doc.index("## Routines outside the 740"):]
    rest = index.find("\n## ", 5)
    index = index if rest < 0 else index[:rest]
    sources = [(REPO_ROOT / p).read_text(encoding="utf-8").split("\n") for p in (
        "godot/hellcats/runtime/unexported.gd", "godot/hellcats/runtime/overlay_loader.gd", "godot/hellcats/toolbox/toolbox.gd")]
    problems, count = [], 0
    for line in index.split("\n"):
        cells = [c.strip() for c in line.split("|")[1:-1]]
        if len(cells) < 4 or not re.match(r"0x[0-9a-f]+$", cells[1]):
            continue
        count += 1
        address = int(cells[1], 16)
        name = next(n for n in re.findall(r"`([^`]+)`", cells[3]) if not n.endswith(".gd"))
        header = None
        for lines in sources:
            at = next((i for i, x in enumerate(lines) if re.match(rf"(static )?func {re.escape(name)}\(", x)), None)
            if at is not None:
                j, header = at - 1, []
                while j >= 0 and lines[j].startswith("##"):
                    header.insert(0, lines[j])
                    j -= 1
                break
        if header is None:
            problems.append(f"{cells[0]} {cells[1]}: {name} is not defined in the runtime")
        elif not re.search(rf"0x0*{address:x}\b", " ".join(header)):
            problems.append(f"{cells[0]} {cells[1]}: {name}'s doc comment does not cite it")
    if count != 35:
        problems.append(f"the index lists {count} routines, not 35")
    if problems:
        fail("runtime headers:\n  " + "\n  ".join(problems))


def check_unused_traps() -> str:
    """docs/GAME_RUNTIME.md's "Traps the game never issues": its counts and its word list are the
    runtime's installed trap words against the words the original bytes issue at instruction
    boundaries (ID01..ID08 and the overlay's code; auto-pop variants folded)."""
    try:
        import capstone  # type: ignore
    except Exception:
        return "skipped (capstone not installed)"
    runtime_src = "\n".join(p.read_text(encoding="utf-8") for p in sorted((GODOT_ROOT / "hellcats").glob("**/*.gd")))
    installed = {int(w, 16) for w in re.findall(r"install\((0xa[0-9a-f]{3})", runtime_src)}
    for group in re.findall(r"for word in \[([^\]]*)\]", runtime_src):
        installed |= {int(w, 16) for w in re.findall(r"0xa[0-9a-f]{3}", group)}
    fold = lambda w: w & ~0x400 if w & 0x800 else w
    md = capstone.Cs(capstone.CS_ARCH_M68K, capstone.CS_MODE_M68K_020)
    md.skipdata = True
    issued: set[int] = set()

    def scan(b: bytes, start: int, end: int) -> None:
        for ins in md.disasm(b[start:end], start):
            w = int.from_bytes(b[ins.address:ins.address + 2], "big")
            if w >> 12 == 0xA:
                issued.add(fold(w))
    for n in range(1, 9):
        b = (REPO_ROOT / "sources" / "resedit-1-0-3" / "CODE" / f"ID0{n}.bin").read_bytes()
        scan(b, 0, len(b))
    s = (GODOT_ROOT / "hellcats" / "data" / "scenery" / "Pacific Conflict").read_bytes()
    scan(s, 0x20, 0x20 + int.from_bytes(s[4:8], "big"))
    others = {w for w in installed if fold(w) not in issued}
    text = (REPO_ROOT / "docs" / "GAME_RUNTIME.md").read_text(encoding="utf-8")
    section = text.split("### Traps the game never issues", 1)[1].split("\n## ", 1)[0]
    listed = {int(w, 16) for w in re.findall(r"\$(A[0-9A-F]{3})", section)}
    pattern = r"installs (\d+) trap words|finds (\d+) issued|other (\d+), three|remaining (\d+) have"
    numbers = [int("".join(m)) for m in re.findall(pattern, " ".join(section.split()))]
    expected = [len(installed), len(installed) - len(others), len(others), len(others) - 3]
    if numbers != expected:
        fail(f"GAME_RUNTIME.md unused traps: counts {numbers}, the bytes give {expected}")
    if listed != others:
        fail("GAME_RUNTIME.md unused traps: listed but issued or not installed "
             f"{sorted(hex(w) for w in listed - others)}, missing {sorted(hex(w) for w in others - listed)}")
    return f"{len(others) - 3} unused of {len(installed)} installed"


def check_runtime_coverage_doc() -> str:
    """docs/RUNTIME_COVERAGE.md is what tools/strict_port/coverage_gaps.py generates now."""
    try:
        import capstone  # type: ignore  # noqa: F401
    except Exception:
        return "skipped (capstone not installed)"
    import subprocess
    r = subprocess.run([sys.executable, str(REPO_ROOT / "tools" / "strict_port" / "coverage_gaps.py"), "--check"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        fail(r.stdout.strip() or r.stderr.strip())
    return "up to date"


def check_callees() -> str:
    """Each strict-port function reaches what its semantic C calls (no inlined shortcut)."""
    import subprocess
    r = subprocess.run([sys.executable, str(REPO_ROOT / "tools" / "strict_port" / "check_callees.py")],
                       capture_output=True, text=True)
    if r.returncode != 0:
        fail(r.stdout.strip() or r.stderr.strip())
    return r.stdout.strip().removeprefix("PASS ")


def check_coverage_copies() -> str:
    """The coverage instrumentation credits each strict-port function in its own body."""
    import subprocess
    r = subprocess.run([sys.executable, str(REPO_ROOT / "tools" / "strict_port" / "coverage_copies.py"), "--check"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        fail(r.stdout.strip() or r.stderr.strip())
    return "every function records itself"


def main() -> int:
    checks = [
        ("runner-layout", check_runner_layout),
        ("loader-targets", check_loader_targets),
        ("game-scenes", check_game_scenes),
        ("01a48-kind2-jsr-bytes", check_01a48_kind2_jsr_bytes),
        ("global-alias-docs", check_global_alias_docs),
        ("resedit-mirror", check_resedit_mirror),
        ("runtime-coverage", check_runtime_coverage),
        ("source-extraction", check_source_extraction),
        ("xrefs", check_xrefs),
        ("entry-points", check_entry_points),
        ("call-annotations", check_trap_annotations),
        ("port-headers", check_port_headers),
        ("runtime-headers", check_runtime_headers),
    ]
    optional = [
        ("optional-capstone", check_optional_capstone),
        ("optional-ghidra", check_optional_ghidra),
        ("optional-unused-traps", check_unused_traps),
        ("strict-port-callees", check_callees),
        ("coverage-copies", check_coverage_copies),
        ("optional-runtime-coverage-doc", check_runtime_coverage_doc),
    ]
    try:
        for name, fn in checks:
            fn()
            print(f"PASS {name}")
        for name, fn in optional:
            detail = fn()
            print(f"PASS {name}: {detail}")
    except AssertionError as exc:
        print(f"FAIL {exc}")
        return 1
    print("All deterministic QA regression checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
