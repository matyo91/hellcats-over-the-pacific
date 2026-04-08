#!/usr/bin/env python3
"""Deterministic QA checks for migrated Godot tests and fixtures.

This script is intentionally static/data-oriented and complements (does not duplicate)
runtime Godot tests in `godot/tests/run_all.gd`.
"""

from __future__ import annotations

import ast
import json
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
GODOT_TESTS = REPO_ROOT / "godot" / "tests"
GODOT_FIXTURES = GODOT_TESTS / "fixtures"
LEGACY_FIXTURES = REPO_ROOT / "hellcats" / "tests" / "fixtures"
RUNNER_PATH = GODOT_TESTS / "run_all.gd"

EXPECTED_RUNNER_PATHS = [
    "res://godot/tests/unit/test_rng.gd",
    "res://godot/tests/unit/test_flight_math.gd",
    "res://godot/tests/unit/test_loader_metadata.gd",
    "res://godot/tests/integration/test_sim_loader_bridge.gd",
    "res://godot/tests/integration/test_replay.gd",
]

EXPECTED_LOADER_TARGETS = [
    {"segment_id": 2, "stored_tail": 0x199E, "entrypoint_offset": 0x19A2, "id00_entry_offset": 770},
    {"segment_id": 5, "stored_tail": 0x0000, "entrypoint_offset": 0x0006, "id00_entry_offset": 1362},
    {"segment_id": 6, "stored_tail": 0x0E0C, "entrypoint_offset": 0x0E10, "id00_entry_offset": 386},
    {"segment_id": 6, "stored_tail": 0x096A, "entrypoint_offset": 0x096E, "id00_entry_offset": 418},
    {"segment_id": 6, "stored_tail": 0x09D4, "entrypoint_offset": 0x09D8, "id00_entry_offset": 426},
    {"segment_id": 7, "stored_tail": 0x018C, "entrypoint_offset": 0x0190, "id00_entry_offset": 1402},
]

ALLOWED_REPLAY_KEYS = {"key_32", "key_61"}
EXPECTED_REPLAY_FRAME_COUNT = 4


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
        fp = REPO_ROOT / rel
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
        if delta not in (4, 6):
            fail(f"targets[{idx}].delta must be 4 or 6")
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

    # If legacy fixtures still exist, enforce byte-identical copy to prevent split-brain updates.
    legacy = LEGACY_FIXTURES / "proven_loader_targets.json"
    if legacy.exists() and legacy.read_bytes() != fixture.read_bytes():
        fail("Legacy and migrated loader fixtures differ; update both or remove legacy fixture.")


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
    if legacy.exists() and legacy.read_bytes() != fixture.read_bytes():
        fail("Legacy and migrated replay fixtures differ; update both or remove legacy fixture.")


def main() -> int:
    checks = [
        ("runner-layout", check_runner_layout),
        ("loader-fixture", check_loader_fixture),
        ("replay-fixture", check_replay_fixture),
    ]
    try:
        for name, fn in checks:
            fn()
            print(f"PASS {name}")
    except AssertionError as exc:
        print(f"FAIL {exc}")
        return 1
    print("All deterministic QA regression checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
