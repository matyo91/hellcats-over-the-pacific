#!/usr/bin/env python3
"""Deterministic QA checks for migrated Godot tests and fixtures.

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
GODOT_FIXTURES = GODOT_TESTS / "fixtures"
LEGACY_FIXTURES = GODOT_ROOT / "hellcats" / "tests" / "fixtures"
RUNNER_PATH = GODOT_TESTS / "run_all.gd"

EXPECTED_RUNNER_PATHS = [
    "res://tests/strict_port/test_c68k.gd",
    "res://tests/strict_port/test_memory_68k.gd",
    "res://tests/strict_port/test_contact_pair_hash.gd",
    "res://tests/strict_port/test_find_contact_record.gd",
    "res://tests/strict_port/test_reset_radar_tracks.gd",
    "res://tests/unit/test_rng.gd",
    "res://tests/unit/test_rng_overlay_11564.gd",
    "res://tests/unit/test_flight_math.gd",
    "res://tests/unit/test_loader_metadata.gd",
    "res://tests/unit/test_mission_objectives_m1.gd",
    "res://tests/unit/test_player_input_frame.gd",
    "res://tests/unit/test_flight_model_mvp.gd",
    "res://tests/unit/test_world_collision_mvp.gd",
    "res://tests/integration/test_sim_loader_bridge.gd",
    "res://tests/integration/test_sim_tick_ordering.gd",
    "res://tests/integration/test_sim_entity_controls.gd",
    "res://tests/integration/test_movement_smoothing.gd",
    "res://tests/integration/test_replay.gd",
    "res://tests/integration/test_mission_scene_load.gd",
    "res://tests/integration/test_hud_mvp_scene.gd",
]

EXPECTED_LOADER_TARGETS = [
    {"segment_id": 2, "stored_tail": 0x199E, "entrypoint_offset": 0x19A2, "id00_entry_offset": 776},
    {"segment_id": 5, "stored_tail": 0x0000, "entrypoint_offset": 0x0004, "id00_entry_offset": 1368},
    {"segment_id": 6, "stored_tail": 0x0E0C, "entrypoint_offset": 0x0E10, "id00_entry_offset": 392},
    {"segment_id": 6, "stored_tail": 0x096A, "entrypoint_offset": 0x096E, "id00_entry_offset": 424},
    {"segment_id": 6, "stored_tail": 0x09D4, "entrypoint_offset": 0x09D8, "id00_entry_offset": 432},
    {"segment_id": 7, "stored_tail": 0x018C, "entrypoint_offset": 0x0190, "id00_entry_offset": 1408},
]

ALLOWED_REPLAY_KEYS = {"key_32", "key_61"}
EXPECTED_REPLAY_FRAME_COUNT = 4
EXPECTED_MISSION_OBJECTIVES = [
    "stabilize_flight",
    "turn_left",
    "turn_right",
    "climb",
    "descend",
    "checkpoint_pass",
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


def check_loader_fixture() -> None:
    fixture = GODOT_FIXTURES / "proven_loader_targets.json"
    if not fixture.exists():
        fail(f"Missing fixture: {fixture}")

    data = _load_json(fixture)
    if not isinstance(data, dict):
        fail("proven_loader_targets.json root must be an object")
    if "targets" not in data or not isinstance(data["targets"], list):
        fail("proven_loader_targets.json must contain array key 'targets'")

    targets = data["targets"]
    if len(targets) != len(EXPECTED_LOADER_TARGETS):
        fail(f"loader targets count drifted: got={len(targets)} want={len(EXPECTED_LOADER_TARGETS)}")

    by_tuple = {}
    id00_seen: set[int] = set()
    for idx, entry in enumerate(targets):
        if not isinstance(entry, dict):
            fail(f"targets[{idx}] must be an object")
        for key in ("segment_id", "stored_tail", "entrypoint_offset", "id00_entry_offset", "delta"):
            if key not in entry:
                fail(f"targets[{idx}] missing key {key}")
            if not isinstance(entry[key], int):
                fail(f"targets[{idx}].{key} must be int")

        delta = entry["delta"]
        if delta != 4:
            fail(f"targets[{idx}].delta must be 4")
        if entry["entrypoint_offset"] != entry["stored_tail"] + delta:
            fail(
                f"targets[{idx}] invariant failed: "
                "entrypoint_offset must equal stored_tail + delta"
            )

        tup = (entry["segment_id"], entry["stored_tail"], entry["entrypoint_offset"], entry["id00_entry_offset"])
        if tup in by_tuple:
            fail(f"Duplicate loader target tuple at index {idx}")
        by_tuple[tup] = idx

        id00 = entry["id00_entry_offset"]
        if id00 in id00_seen:
            fail(f"Duplicate id00_entry_offset at index {idx}: {id00}")
        id00_seen.add(id00)

    want = {
        (e["segment_id"], e["stored_tail"], e["entrypoint_offset"], e["id00_entry_offset"])
        for e in EXPECTED_LOADER_TARGETS
    }
    got = set(by_tuple.keys())
    if got != want:
        fail(
            "proven_loader_targets.json content drifted from deterministic expected set.\n"
            f"only_in_got={sorted(got - want)}\n"
            f"only_in_want={sorted(want - got)}"
        )

    # A legacy copy would reintroduce split-brain fixture updates.
    legacy = LEGACY_FIXTURES / "proven_loader_targets.json"
    if legacy.exists():
        fail("Remove legacy proven_loader_targets.json; godot/tests/fixtures is canonical.")


def check_replay_fixture() -> None:
    fixture = GODOT_FIXTURES / "replay_inputs.json"
    if not fixture.exists():
        fail(f"Missing fixture: {fixture}")
    data = _load_json(fixture)
    if not isinstance(data, list):
        fail("replay_inputs.json root must be an array")
    if len(data) != EXPECTED_REPLAY_FRAME_COUNT:
        fail(
            f"replay_inputs.json frame count drifted: got={len(data)} "
            f"want={EXPECTED_REPLAY_FRAME_COUNT}"
        )

    for i, packet in enumerate(data):
        if not isinstance(packet, dict):
            fail(f"replay_inputs[{i}] must be an object")
        unknown_keys = set(packet) - ALLOWED_REPLAY_KEYS
        if unknown_keys:
            fail(f"replay_inputs[{i}] has unknown keys: {sorted(unknown_keys)}")
        for k, v in packet.items():
            if not isinstance(v, int):
                fail(f"replay_inputs[{i}].{k} must be int")

    legacy = LEGACY_FIXTURES / "replay_inputs.json"
    if legacy.exists():
        fail("Remove legacy replay_inputs.json; godot/tests/fixtures is canonical.")


def check_mission_mvp_data() -> None:
    mission_path = REPO_ROOT / "godot" / "data" / "mission_01" / "mission_01_training.json"
    if not mission_path.exists():
        fail(f"Missing mission data: {mission_path}")
    mission = _load_json(mission_path)
    if not isinstance(mission, dict):
        fail("mission_01_training.json root must be an object")
    if mission.get("start_mode") != "airborne":
        fail("Mission 01 MVP must stay airborne-start for the current vertical slice")
    sequence = mission.get("objective_sequence")
    if not isinstance(sequence, list):
        fail("mission_01_training.json objective_sequence must be a list")
    ids = [entry.get("id") for entry in sequence if isinstance(entry, dict)]
    if ids != EXPECTED_MISSION_OBJECTIVES:
        fail(f"Mission objective order drifted: got={ids} want={EXPECTED_MISSION_OBJECTIVES}")
    last_entry = sequence[-1]
    if not isinstance(last_entry, dict) or not bool(last_entry.get("optional", False)):
        fail("checkpoint_pass objective must remain optional in Mission 01 MVP data")
    failure = mission.get("failure", {})
    if float(failure.get("stall_seconds", -1.0)) != 4.0:
        fail("Mission stall failure threshold drifted from 4.0s")
    if float(failure.get("out_of_bounds_seconds", -1.0)) != 8.0:
        fail("Mission out-of-bounds threshold drifted from 8.0s")


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


def main() -> int:
    checks = [
        ("runner-layout", check_runner_layout),
        ("loader-fixture", check_loader_fixture),
        ("replay-fixture", check_replay_fixture),
        ("mission-mvp-data", check_mission_mvp_data),
        ("01a48-kind2-jsr-bytes", check_01a48_kind2_jsr_bytes),
        ("global-alias-docs", check_global_alias_docs),
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
