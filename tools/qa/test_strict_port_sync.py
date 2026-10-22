#!/usr/bin/env python3
"""Tests for strict-port mapping validation and source-change detection."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = REPO_ROOT / "tools/strict_port/check_sync.py"
SPEC = importlib.util.spec_from_file_location("strict_port_check_sync", MODULE_PATH)
assert SPEC and SPEC.loader
SYNC = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SYNC)
MANIFEST = REPO_ROOT / "godot/strict_port/mappings/functions.json"


class StrictPortSyncTest(unittest.TestCase):
    def test_current_source_is_synchronized(self) -> None:
        report, errors = SYNC.check(MANIFEST, REPO_ROOT)
        rows = json.loads(MANIFEST.read_text(encoding="utf-8"))["functions"]
        self.assertEqual(errors, [])
        self.assertEqual(report["decompiled_functions"], 740)
        self.assertEqual(report["mapped_functions"], len(rows))
        self.assertEqual(report["not_ported_functions"], 740 - len(rows))
        self.assertEqual(report["behaviorally_verified"], sum(1 for row in rows if row["behaviorally_verified"]))
        self.assertGreaterEqual(len(rows), 3)

    def test_wrapped_signature_is_extracted(self) -> None:
        source = (
            "int one_line(int a) /* c */\n{\n  return a;\n}\n"
            "void wrapped(int a,\n             int b) /* Original: FUN_x */\n{\n  if (a) {\n    b = 1;\n  }\n}\n"
        )
        self.assertEqual(SYNC.extract_function(source, "one_line"), "int one_line(int a) /* c */\n{\n  return a;\n}")
        self.assertTrue(SYNC.extract_function(source, "wrapped").startswith("void wrapped(int a,\n"))
        self.assertTrue(SYNC.extract_function(source, "wrapped").endswith("  }\n}"))
        commented = "void noted /* c */ (int a /* (one) */,\n           int b /* two */)\n{\n  return;\n}\n"
        self.assertEqual(SYNC.extract_function(commented, "noted"), commented.rstrip("\n"))

    def test_changed_source_is_reported_without_rewriting_manifest(self) -> None:
        manifest_before = MANIFEST.read_bytes()
        mappings = json.loads(MANIFEST.read_text(encoding="utf-8"))["functions"]
        mapping = mappings[0]
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            paths = {"docs/DECOMPILATION_INVENTORY.json"}
            for row in mappings:
                paths.update(row[key] for key in ("source_file", "target_file", "deterministic_test"))
            for relative_path in paths:
                source = REPO_ROOT / relative_path
                target = root / relative_path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(source.read_bytes())
            source_copy = root / mapping["source_file"]
            source_copy.write_text(
                source_copy.read_text(encoding="utf-8").replace(
                    "return param_1 ^ param_2 << 2;",
                    "return param_1 ^ param_2 << 3;",
                    1,
                ),
                encoding="utf-8",
            )
            report, errors = SYNC.check(MANIFEST, root)

        self.assertEqual(report["source_changed"], 1)
        self.assertTrue(any("SOURCE_CHANGED" in error for error in errors))
        self.assertEqual(MANIFEST.read_bytes(), manifest_before)


if __name__ == "__main__":
    unittest.main()
