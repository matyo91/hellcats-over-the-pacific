#!/usr/bin/env python3
"""Check strict-port provenance mappings and detect decompiled-source drift."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
ALLOWED_STATUSES = {
    "NOT_PORTED",
    "PORTING",
    "PORTED_UNVERIFIED",
    "VERIFIED",
    "BLOCKED",
    "SOURCE_CHANGED",
}


def extract_function(source: str, name: str) -> str:
    signature = re.compile(rf"^[^\n]*\b{re.escape(name)}\b[^\n]*\([^;\n]*\)[^\n]*$", re.MULTILINE)
    # Fallback for parameter lists wrapped over several lines (tried only when the
    # one-line form finds no definition, so existing hashes are unchanged).
    wrapped = re.compile(rf"^[^\n]*\b{re.escape(name)}\b[^\n]*\([^;{{}}]*?\)[^\n;{{}}]*$(?=\s*\{{)", re.MULTILINE)
    # Last resort: parameter comments that contain ';', '{' or '}' (comments matched whole).
    commented = re.compile(
        rf"^[^\n]*\b{re.escape(name)}\b[^\n]*\((?:/\*.*?\*/|[^;{{}}/])*?\)[^\n;{{}}]*$(?=\s*\{{)",
        re.MULTILINE | re.DOTALL,
    )
    # Parameter list starting on the line after the name (tried last, so existing hashes are
    # unchanged).
    next_line = re.compile(
        rf"^[^\n]*\b{re.escape(name)}\b[^\n(]*\n\s*\([^;{{}}]*?\)[^\n;{{}}]*$(?=\s*\{{)", re.MULTILINE)
    for pattern in (signature, wrapped, commented, next_line):
        found = _extract_with(source, pattern)
        if found is not None:
            return found
    raise ValueError(f"function definition not found: {name}")


def _extract_with(source: str, signature: re.Pattern) -> str | None:
    for match in signature.finditer(source):
        brace = source.find("{", match.end())
        if brace < 0:
            continue
        between = source[match.end():brace]
        if between.strip():
            continue
        depth = 0
        for index in range(brace, len(source)):
            char = source[index]
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    return source[match.start():index + 1].replace("\r\n", "\n")
    return None


def source_hash(path: Path, function_name: str) -> str:
    function = extract_function(path.read_text(encoding="utf-8", errors="replace"), function_name)
    return hashlib.sha256(function.encode("utf-8")).hexdigest()


def check(manifest_path: Path, source_root: Path) -> tuple[dict, list[str]]:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    rows = manifest.get("functions", [])
    errors: list[str] = []
    counts = {status: 0 for status in sorted(ALLOWED_STATUSES)}
    tested = structural = behavioral = integrated = runtime = 0

    for row in rows:
        identity = f"{row.get('source_file')}::{row.get('source_function')}"
        status = row.get("translation_status")
        if status not in ALLOWED_STATUSES:
            errors.append(f"{identity}: invalid translation_status {status!r}")
            continue
        counts[status] += 1

        source_path = source_root / row["source_file"]
        target_path = source_root / row["target_file"]
        test_path = source_root / row["deterministic_test"] if row.get("deterministic_test") else None
        if not source_path.is_file():
            errors.append(f"{identity}: missing source file")
            continue
        try:
            actual_hash = source_hash(source_path, row["source_function"])
        except ValueError as exc:
            errors.append(f"{identity}: {exc}")
            continue
        if actual_hash != row.get("source_sha256"):
            errors.append(
                f"{identity}: SOURCE_CHANGED expected={row.get('source_sha256')} actual={actual_hash}"
            )
        if not target_path.is_file():
            errors.append(f"{identity}: missing target file")
        elif not re.search(
            rf"^\s*(?:static\s+)?func\s+{re.escape(row['target_function'])}\s*\(",
            target_path.read_text(encoding="utf-8"),
            re.MULTILINE,
        ):
            errors.append(f"{identity}: target function not found")
        if test_path:
            if test_path.is_file():
                tested += 1
            else:
                errors.append(f"{identity}: missing deterministic test")
        structural += int(bool(row.get("structurally_verified")))
        behavioral += int(bool(row.get("behaviorally_verified")))
        integrated += int(bool(row.get("integrated")))
        runtime += int(bool(row.get("runtime_verified")))

    inventory_path = source_root / "docs/DECOMPILATION_INVENTORY.json"
    decompiled_total = 0
    if inventory_path.is_file():
        inventory = json.loads(inventory_path.read_text(encoding="utf-8"))
        decompiled_total = int(inventory.get("total", 0))

    report = {
        "decompiled_functions": decompiled_total,
        "mapped_functions": len(rows),
        "not_ported_functions": max(0, decompiled_total - len(rows)),
        "status_counts": counts,
        "with_deterministic_tests": tested,
        "structurally_verified": structural,
        "behaviorally_verified": behavioral,
        "integrated": integrated,
        "runtime_verified": runtime,
        "source_changed": sum("SOURCE_CHANGED" in error for error in errors),
    }
    return report, errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest",
        type=Path,
        default=REPO_ROOT / "godot/strict_port/mappings/functions.json",
    )
    parser.add_argument("--source-root", type=Path, default=REPO_ROOT)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    report, errors = check(args.manifest, args.source_root)
    if args.json:
        print(json.dumps({"report": report, "errors": errors}, indent=2))
    else:
        print(json.dumps(report, sort_keys=True))
        for error in errors:
            print(f"ERROR {error}")
        print("PASS strict-port mappings are synchronized" if not errors else "FAIL strict-port synchronization")
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
