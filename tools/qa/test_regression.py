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


def check_resedit_mirror() -> None:
    import subprocess
    result = subprocess.run([sys.executable, str(REPO_ROOT / "tools" / "strict_port" / "import_resedit.py"), "--check"],
                            capture_output=True, text=True)
    if result.returncode != 0:
        fail("the resource folders in godot/strict_port drifted from sources/resedit-1-0-3:\n" + result.stdout)


def main() -> int:
    checks = [
        ("runner-layout", check_runner_layout),
        ("loader-targets", check_loader_targets),
        ("game-scenes", check_game_scenes),
        ("01a48-kind2-jsr-bytes", check_01a48_kind2_jsr_bytes),
        ("global-alias-docs", check_global_alias_docs),
        ("resedit-mirror", check_resedit_mirror),
    ]
    optional = [
        ("optional-capstone", check_optional_capstone),
        ("optional-ghidra", check_optional_ghidra),
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
