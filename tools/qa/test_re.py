#!/usr/bin/env python3
"""Regression checks for targeted reverse-engineering retrieval."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "re_query.py"


def run(*args: str) -> str:
    result = subprocess.run(
        [sys.executable, str(TOOL), *args], cwd=ROOT, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
    )
    return result.stdout


def run_failure(*args: str) -> str:
    result = subprocess.run(
        [sys.executable, str(TOOL), *args], cwd=ROOT, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    assert result.returncode != 0, (args, result.stdout, result.stderr)
    return result.stderr


def main() -> int:
    function = run("function", "--segment", "Pacific Conflict", "FUN_0000e42a")
    assert "table_lerp_1b2c0" in function and "Original: FUN_0000e42a" in function
    assert "Pacific Conflict::FUN_0000e42a" in run("function", "--segment", "Pacific Conflict", "0xe42a")
    excerpt = run("excerpt", "--segment", "Pacific Conflict", "FUN_0000e792", "--lines", "120:135")
    excerpt_lines = excerpt.splitlines()
    match = re.fullmatch(
        r"// (sources/resedit-1-0-3/CODE/Pacific Conflict\.decomp\.c):(\d+)-(\d+) "
        r"\[Pacific Conflict::FUN_0000e792 relative 120:135\]",
        excerpt_lines[0],
    )
    assert match is not None, excerpt_lines[0]
    source_path, start_text, end_text = match.groups()
    start, end = int(start_text), int(end_text)
    assert end - start == 15
    source_lines = (ROOT / source_path).read_text(encoding="utf-8").splitlines()
    assert excerpt_lines[1:] == source_lines[start - 1:end]
    assert "void update_aircraft_entity" not in excerpt
    block = run("excerpt", "--segment", "Pacific Conflict", "FUN_0000e792", "--address", "0xf47c", "--limit", "12")
    assert "LAB_0000f47c:" in block and len(block.splitlines()) <= 14
    named_block = run("excerpt", "--segment", "Pacific Conflict", "FUN_0000e792", "--block", "Block 6c", "--limit", "8")
    assert "Block 6c" in named_block and len(named_block.splitlines()) <= 10
    assert "DAT_0001b2c0" in run("globals", "table_lerp_1b2c0", "--access", "unknown")
    radar = run("globals", "--segment", "Pacific Conflict", "update_radar_scope")
    assert '"DAT_0001b51c"' in radar and '"radar_tracks"' in radar
    assert "update_aircraft_entity" in run("callers", "table_lerp_1b2c0")
    assert "Pacific Conflict::FUN_0000e42a" in run("callees", "--segment", "Pacific Conflict", "FUN_0000e792")
    status = run("status", "--segment", "Pacific Conflict", "FUN_0000e42a", "--detail")
    assert '"reconstruction_status": "VERIFIED"' in status and '"technical_evidence"' in status
    assert "altitude curve" in run("symbol", "DAT_0001b2c0")
    assert "contact_pair_hash" in run("source-map", "FUN_0001358c")
    correspondence = run("correspondence", "--segment", "Pacific Conflict", "FUN_0001358c")
    assert '"original"' in correspondence and '"strict_port"' in correspondence
    test_case = run("tests", "test_flight_math", "--case", "_test_fun_0000e42a")
    assert "godot/tests/unit/test_flight_math.gd:59-76" in test_case
    assert "module setup" in test_case and "res://hellcats/core/flight_math.gd" in test_case
    assert "func _test_fun_0000e468" not in test_case and len(test_case.splitlines()) < 60
    helper_case = run("tests", "test_replay", "--case", "run")
    assert "direct helpers: 1" in helper_case and "func _run_once" in helper_case
    recovered_failures = {
        ("ID02", "FUN_000002b0"): "ansi_memset",
        ("ID02", "FUN_00004b62"): "init_standard_colour_indices",
        ("ID05", "FUN_000008b8"): "init_protection_table",
        ("ID05", "FUN_00000964"): "validate_protection_response",
    }
    for (segment, original), semantic in recovered_failures.items():
        recovered = run("function", "--segment", segment, original)
        recovered_status = run("status", "--segment", segment, original)
        assert semantic in recovered and '"reconstruction_status": "VERIFIED"' in recovered_status
    assert "ambiguous function query" in run_failure("function", "FUN_00000006")
    assert "unsupported address mapping" in run_failure("function", "--segment", "Pacific Conflict", "0xdeadbeef")
    print("PASS targeted reverse-engineering retrieval")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
