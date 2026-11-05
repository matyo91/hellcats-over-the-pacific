#!/usr/bin/env python3
"""Report orthogonal reconstruction, strict-port, and resource counts."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "docs" / "DECOMPILATION_INVENTORY.json"
STRICT_MAP = ROOT / "godot" / "strict_port" / "mappings" / "functions.json"
RESOURCES = ROOT / "sources" / "resedit-1-0-3" / "inventory.json"


def load(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def collect() -> tuple[dict[str, Any], list[str]]:
    inventory = load(INVENTORY)
    strict = load(STRICT_MAP)
    resources = load(RESOURCES)
    rows = inventory.get("functions", [])
    mappings = strict.get("functions", [])
    errors: list[str] = []
    identities = [row.get("identity") for row in rows]
    expected_identities = [f"{row.get('segment')}::{row.get('original_function')}" for row in rows]
    if inventory.get("schema_version") != 3:
        errors.append("decompilation inventory schema_version must be 3")
    if len(rows) != inventory.get("total"):
        errors.append("decompilation inventory total does not match function records")
    if identities != expected_identities:
        errors.append("one or more canonical identities do not match segment::original_function")
    if len(identities) != len(set(identities)):
        errors.append("duplicate segment-qualified function identity")
    if inventory.get("conflicts"):
        errors.append("canonical registry has unresolved conflicts")

    status_counts = inventory.get("status_counts", {})
    recomputed_status = {
        status: sum(row.get("reconstruction_status") == status for row in rows)
        for status in ("ANNOTATED", "BLOCKED", "INVESTIGATING", "NOT_STARTED", "RENAMED", "VERIFIED")
    }
    if status_counts != recomputed_status:
        errors.append("canonical registry status_counts are stale")

    stats = {
        "reconstruction": {
            "total_original_functions": len(rows),
            "renamed_functions": recomputed_status["RENAMED"],
            "name_verified_functions": sum(bool(row.get("name_verified")) for row in rows),
            "semantically_verified_functions": sum(bool(row.get("semantically_verified")) for row in rows),
            "blocked_functions": recomputed_status["BLOCKED"],
        },
        "strict_port": {
            "ported_gdscript_functions": sum(row.get("translation_status") != "NOT_PORTED" for row in mappings),
            "behaviorally_verified_translations": sum(bool(row.get("behaviorally_verified")) for row in mappings),
            "integrated_translations": sum(bool(row.get("integrated")) for row in mappings),
            "runtime_verified_translations": sum(bool(row.get("runtime_verified")) for row in mappings),
        },
        "resources": {
            "identified_resources": int(resources.get("resource_count", 0)),
            "parsed_resources": int(resources.get("decoded_resource_count", 0)),
            "unresolved_resource_formats": int(resources.get("unidentified_structure_count", 0)),
        },
    }
    return stats, errors


def render_text(stats: dict[str, Any]) -> str:
    labels = {
        "total_original_functions": "original functions",
        "renamed_functions": "renamed (awaiting semantic verification)",
        "name_verified_functions": "name verified",
        "semantically_verified_functions": "semantically verified",
        "blocked_functions": "blocked",
        "ported_gdscript_functions": "ported to GDScript",
        "behaviorally_verified_translations": "behaviorally verified translations",
        "integrated_translations": "integrated translations",
        "runtime_verified_translations": "run in the runtime's sessions (runtime verified)",
        "identified_resources": "identified resources",
        "parsed_resources": "parsed resources",
        "unresolved_resource_formats": "unresolved resource formats",
    }
    output = []
    for section, values in stats.items():
        output.append(f"{section}:")
        output.extend(f"  {labels[key]}: {value}" for key, value in values.items())
    return "\n".join(output)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--check", action="store_true", help="validate authorities before reporting")
    args = parser.parse_args()
    stats, errors = collect()
    if args.json:
        print(json.dumps({"statistics": stats, "errors": errors}, indent=2))
    else:
        print(render_text(stats))
        if errors:
            print("validation errors:", file=sys.stderr)
            for error in errors:
                print(f" - {error}", file=sys.stderr)
    if args.check and errors:
        return 1
    if args.check:
        print("PASS progress authorities are internally consistent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
