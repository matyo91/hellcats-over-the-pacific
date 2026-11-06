#!/usr/bin/env python3
"""Build and validate the segment-qualified decompilation function registry."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CODE = ROOT / "sources" / "resedit-1-0-3" / "CODE"
DEFAULT_OUTPUT = ROOT / "docs" / "DECOMPILATION_INVENTORY.json"
STRICT_MAP = ROOT / "godot" / "strict_port" / "mappings" / "functions.json"
FUN_RE = re.compile(
    r"^(?P<ret>[A-Za-z_][\w\s*]*?)\b(?P<name>[A-Za-z_]\w*)"
    r"\s*\([^;{}]*\)\s*\{",
    re.MULTILINE,
)
ORIGINAL_RE = re.compile(r"\bFUN_[0-9A-Fa-f]+\b")
ORIGINAL_LABEL_RE = re.compile(r"Original:\s*(FUN_[0-9A-Fa-f]+)\b")
DOC_ORIGINAL_RE = re.compile(r"^\s*\*\s*Original:\s*(FUN_[0-9A-Fa-f]+)\b", re.MULTILINE)
FAILED_DECOMPILE_RE = re.compile(r"Unable to decompile '(FUN_[0-9A-Fa-f]+)'")
STATUS_VALUES = {"NOT_STARTED", "INVESTIGATING", "ANNOTATED", "RENAMED", "VERIFIED", "BLOCKED"}


def rel(path: Path) -> str:
    return str(path.resolve().relative_to(ROOT))


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.replace("\r\n", "\n").encode("utf-8")).hexdigest()


def mask_comments(text: str) -> str:
    """Replace comments with spaces while retaining offsets and newlines."""
    return re.sub(
        r"/\*.*?\*/|//[^\n]*",
        lambda match: re.sub(r"[^\n]", " ", match.group()),
        text,
        flags=re.DOTALL,
    )


def matching_brace(masked: str, opening: int) -> int:
    depth = 0
    for index in range(opening, len(masked)):
        if masked[index] == "{":
            depth += 1
        elif masked[index] == "}":
            depth -= 1
            if depth == 0:
                return index
    raise ValueError(f"unclosed function body at byte offset {opening}")


RECOVERED_NAME_RE = re.compile(r"Recovered name(?: \(comment only\))?: ([A-Za-z_][A-Za-z0-9_]*) \[([^\]]+)\]")
## The overlay's, ID08's and ID09's header style: "Proposed name: <name>" (or "Recovered name:", a
## note after it allowed), then the next line "Confidence: [LEVEL] ...".
PROPOSED_NAME_RE = re.compile(r"(?:Proposed|Recovered) name: ([A-Za-z_][A-Za-z0-9_]*)[^\n]*\n[ \t]*\*[ \t]*Confidence:[ \t]*([^\n]+)")
## A false entry: a label inside another function that Ghidra split off, kept under its original
## identifier ("Proposed name: *(false mid-label of ...)*" or "Status: false entry").
FALSE_ENTRY_RE = re.compile(r"false (?:entry|mid-label)|not a callable (?:entry|function)", re.IGNORECASE)


def header_confidence(comment: str, name: str) -> str | None:
    """The name's confidence as the decomp's header before the function states it, brackets dropped."""
    for m in RECOVERED_NAME_RE.finditer(comment):
        if m.group(1) == name:
            return m.group(2).strip()
    for m in PROPOSED_NAME_RE.finditer(comment):
        if m.group(1) == name:
            return " ".join(m.group(2).replace("[", "").replace("]", "").split())
    if FALSE_ENTRY_RE.search(comment):
        return "FALSE ENTRY: a fragment of another function, its original identifier kept"
    return None


def definitions(path: Path) -> list[dict[str, Any]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    masked = mask_comments(text)
    rows: list[dict[str, Any]] = []
    previous_end = 0
    for match in FUN_RE.finditer(masked):
        opening = masked.find("{", match.start(), match.end())
        if opening < 0:
            continue
        closing = matching_brace(masked, opening)
        signature = text[match.start():opening]
        ids = ORIGINAL_LABEL_RE.findall(signature)
        if not ids:
            prefix = text[max(previous_end, match.start() - 1800):match.start()]
            ids = DOC_ORIGINAL_RE.findall(prefix)
        rows.append(
            {
                "name": match.group("name"),
                "return": " ".join(match.group("ret").split()),
                "line_start": text.count("\n", 0, match.start()) + 1,
                "line_end": text.count("\n", 0, closing) + 1,
                "start": match.start(),
                "end": closing + 1,
                "original_ids": list(dict.fromkeys(ids[-2:])),
                "body_sha256": sha256_text(text[match.start():closing + 1]),
                # The decomp's own header, "Recovered name: <name> [<LEVEL>]", the evidence for the name.
                "name_confidence": header_confidence(text[previous_end:match.start()], match.group("name")),
                "whole_function_verified": bool(
                    re.search(
                        r"\bVERIFIED\b.*?independent.*?disassembly.*?identical",
                        text[previous_end:match.start()],
                        flags=re.IGNORECASE | re.DOTALL,
                    )
                ),
            }
        )
        previous_end = closing + 1
    return rows


def original_inventory(path: Path) -> list[dict[str, Any]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    rows = [
        {
            "original_function": row["name"],
            "return_type": row["return"],
            "original_line": row["line_start"],
        }
        for row in definitions(path)
    ]
    known = {row["original_function"] for row in rows}
    for match in FAILED_DECOMPILE_RE.finditer(text):
        if match.group(1) not in known:
            rows.append({
                "original_function": match.group(1),
                "return_type": "unrecovered",
                "original_line": text.count("\n", 0, match.start()) + 1,
            })
    return sorted(rows, key=lambda row: row["original_line"])


def stable_technical_text(value: str) -> str:
    """Remove process chronology while retaining the technical statement."""
    value = re.sub(
        r"\b(?:iterations?|iters?\.?)\s*-?\s*\d+"
        r"(?:\s*(?:-|/|–|—|and)\s*\d+)*\b[:,]?[ ]*",
        "",
        value,
        flags=re.IGNORECASE,
    )
    value = re.sub(r"\b20\d{2}-\d{2}-\d{2}\b[:,]?[ ]*", "", value)
    value = re.sub(r"\(\s*\)", "", value)
    value = re.sub(r"\s+([,;:.])", r"\1", value)
    return re.sub(r"\s+", " ", value).strip(" ;,:")


def strict_rows(path: Path) -> dict[tuple[str, str], dict[str, Any]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    rows: dict[tuple[str, str], dict[str, Any]] = {}
    for row in data.get("functions", []):
        segment = Path(row["source_file"]).name.removesuffix(".decomp.c")
        key = (segment, row["original_function"])
        if key in rows:
            raise ValueError(f"duplicate strict-port identity: {segment}::{row['original_function']}")
        rows[key] = row
    return rows


def address_for(original: str) -> str:
    return f"0x{int(original.removeprefix('FUN_'), 16):x}"


def build_registry(code_dir: Path, previous: dict[str, Any]) -> dict[str, Any]:
    strict = strict_rows(STRICT_MAP)
    prior = {
        (row.get("segment"), row.get("original_function")): row
        for row in previous.get("functions", [])
        if row.get("segment") and row.get("original_function")
    }
    functions: list[dict[str, Any]] = []
    conflicts: list[dict[str, Any]] = []
    file_counts: dict[str, int] = {}

    original_files = [code_dir / f"ID{i:02}.c" for i in range(1, 10)] + [code_dir / "Pacific Conflict.c"]
    for original_path in original_files:
        segment = original_path.stem
        semantic_path = code_dir / f"{segment}.decomp.c"
        originals = original_inventory(original_path)
        semantics = definitions(semantic_path)
        semantic_by_id: dict[str, list[dict[str, Any]]] = {}
        semantic_by_name = {row["name"]: row for row in semantics}
        for semantic in semantics:
            for original_id in semantic["original_ids"]:
                semantic_by_id.setdefault(original_id, []).append(semantic)
        file_counts[original_path.name] = len(originals)

        for original in originals:
            original_id = original["original_function"]
            key = (segment, original_id)
            candidates = semantic_by_id.get(original_id, [])
            if not candidates and original_id in semantic_by_name:
                candidates = [semantic_by_name[original_id]]
            if len(candidates) != 1:
                conflicts.append(
                    {
                        "key": f"{segment}::{original_id}",
                        "reason": "semantic_definition_ambiguity" if candidates else "semantic_definition_missing",
                        "candidates": [row["name"] for row in candidates],
                    }
                )
                semantic = None
            else:
                semantic = candidates[0]

            old = prior.get(key, {})
            if old:
                status = old.get("reconstruction_status", "ANNOTATED")
                confidence = stable_technical_text(old.get("renaming_confidence", "UNRECORDED"))
            else:
                status = "RENAMED" if semantic and semantic["name"] != original_id else "ANNOTATED"
                confidence = "UNRECORDED"
            if status not in STATUS_VALUES:
                conflicts.append({"key": f"{segment}::{original_id}", "reason": "unknown_status", "value": status})
                status = "ANNOTATED"
            if semantic and semantic["whole_function_verified"]:
                status = "VERIFIED"
            if semantic and semantic.get("name_confidence"):
                confidence = stable_technical_text(semantic["name_confidence"])
            strict_row = strict.get(key)
            evidence = [f"{rel(original_path)}:{original['original_line']}"]
            if semantic:
                evidence.append(f"{rel(semantic_path)}:{semantic['line_start']}-{semantic['line_end']}")
            for reference in old.get("evidence_references", []):
                if reference.startswith((
                    "docs/reference/DECOMPILATION_SYMBOLS.md:",
                    f"{rel(original_path)}:",
                    f"{rel(semantic_path)}:",
                )):
                    continue
                evidence.append(reference)
            evidence = list(dict.fromkeys(evidence))

            blockers = list(old.get("known_blockers", []))
            blockers = list(dict.fromkeys(blockers))
            technical_evidence = {
                field: stable_technical_text(value)
                for field, value in old.get("technical_evidence", {}).items()
            }
            blockers = [stable_technical_text(value) for value in dict.fromkeys(blockers)]
            confidence_upper = confidence.upper()
            row = {
                "identity": f"{segment}::{original_id}",
                "segment": segment,
                "original_function": original_id,
                "original_address": address_for(original_id),
                "original_source": {
                    "path": rel(original_path),
                    "line_start": original["original_line"],
                    "return_type": original["return_type"],
                },
                "semantic_name": semantic["name"] if semantic else old.get("semantic_name"),
                "semantic_source": {
                    "path": rel(semantic_path),
                    "line_start": semantic["line_start"] if semantic else None,
                    "line_end": semantic["line_end"] if semantic else None,
                    "function_sha256": semantic["body_sha256"] if semantic else None,
                },
                "renaming_confidence": confidence,
                "reconstruction_status": status,
                # Sticky once set; a name the decomp's header now marks PROVEN is verified too.
                "name_verified": bool(old.get("name_verified", "PROVEN" in confidence_upper or status == "VERIFIED"))
                or (confidence_upper.startswith("PROVEN") and "INFERENCE" not in confidence_upper
                    and "HYPOTHESIS" not in confidence_upper),
                "semantically_verified": status == "VERIFIED",
                "behavioral_verification_status": (
                    "VERIFIED" if strict_row and strict_row.get("behaviorally_verified")
                    else strict_row.get("translation_status", "NOT_PORTED") if strict_row
                    else "NOT_PORTED"
                ),
                "evidence_references": evidence,
                "known_blockers": blockers,
                "technical_evidence": technical_evidence,
                "source_revision": semantic["body_sha256"] if semantic else None,
                "strict_port": strict_row,
            }
            for annotation_key in ("notes", "review"):
                if annotation_key in old:
                    row[annotation_key] = old[annotation_key]
            functions.append(row)

    identities = [row["identity"] for row in functions]
    if len(identities) != len(set(identities)):
        raise ValueError("duplicate segment-qualified identities in generated inventory")
    status_counts = {status: sum(row["reconstruction_status"] == status for row in functions) for status in sorted(STATUS_VALUES)}
    return {
        "schema_version": 3,
        "identity": "segment::original_function",
        "total": len(functions),
        "file_counts": file_counts,
        "status_counts": status_counts,
        "conflicts": conflicts,
        "functions": functions,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--code-dir", type=Path, default=DEFAULT_CODE)
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--check", action="store_true", help="fail if the committed registry is stale")
    args = parser.parse_args()
    previous = json.loads(args.output.read_text(encoding="utf-8")) if args.output.exists() else {}
    generated = build_registry(args.code_dir, previous)
    rendered = json.dumps(generated, indent=2, ensure_ascii=False) + "\n"
    if args.check:
        if not args.output.exists() or args.output.read_text(encoding="utf-8") != rendered:
            print(f"FAIL stale registry: {rel(args.output)}; rerun without --check", file=sys.stderr)
            return 1
        print(f"PASS registry coverage={generated['total']} conflicts={len(generated['conflicts'])}")
        return 0
    args.output.write_text(rendered, encoding="utf-8")
    print(
        f"wrote {rel(args.output)} functions={generated['total']} "
        f"conflicts={len(generated['conflicts'])}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
