#!/usr/bin/env python3
"""Retrieve narrow, source-backed reverse-engineering evidence."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "docs" / "DECOMPILATION_INVENTORY.json"
SYMBOLS = ROOT / "docs" / "DECOMPILATION_SYMBOLS.md"
STRICT_MAP = ROOT / "godot" / "strict_port" / "mappings" / "functions.json"
CONTROL_WORDS = {"if", "for", "while", "switch", "return", "sizeof"}
ADDRESS_RE = re.compile(r"^(?:0x|\$)?([0-9A-Fa-f]+)$")
GLOBAL_RE = re.compile(r"\b_?DAT_[0-9A-Fa-f]+\b")
CALL_RE = re.compile(r"\b([A-Za-z_]\w*)\s*\(")


def relative(path: Path) -> str:
    return str(path.resolve().relative_to(ROOT))


def normalize_segment(value: str) -> str:
    name = Path(value).name
    for suffix in (".decomp.c", ".c"):
        if name.endswith(suffix):
            name = name.removesuffix(suffix)
    return name


def mask_comments(text: str) -> str:
    return re.sub(
        r"/\*.*?\*/|//[^\n]*",
        lambda match: re.sub(r"[^\n]", " ", match.group()),
        text,
        flags=re.DOTALL,
    )


class Registry:
    def __init__(self) -> None:
        data = json.loads(INVENTORY.read_text(encoding="utf-8"))
        if data.get("schema_version") != 3:
            raise ValueError("decompilation inventory is not canonical schema v3; regenerate it")
        self.rows: list[dict[str, Any]] = data["functions"]

    def resolve(self, query: str, segment: str | None = None) -> dict[str, Any]:
        if "::" in query:
            embedded_segment, query = query.split("::", 1)
            if segment and normalize_segment(segment) != normalize_segment(embedded_segment):
                raise LookupError("segment option conflicts with segment-qualified query")
            segment = embedded_segment
        normalized_segment = normalize_segment(segment) if segment else None
        address_match = ADDRESS_RE.fullmatch(query)
        normalized_address = f"0x{int(address_match.group(1), 16):x}" if address_match else None
        matches = []
        for row in self.rows:
            if normalized_segment and row["segment"].casefold() != normalized_segment.casefold():
                continue
            if query.casefold() in {
                row["original_function"].casefold(),
                (row.get("semantic_name") or "").casefold(),
            } or normalized_address == row["original_address"].casefold():
                matches.append(row)
        if not matches:
            if normalized_address:
                qualifier = f" in segment {normalized_segment!r}" if normalized_segment else ""
                raise LookupError(f"unsupported address mapping: {normalized_address}{qualifier}")
            raise LookupError(f"function not found: {query}")
        if len(matches) != 1:
            identities = ", ".join(row["identity"] for row in matches)
            raise LookupError(f"ambiguous function query {query!r}; qualify --segment ({identities})")
        return matches[0]


REGISTRY: Registry | None = None


def registry() -> Registry:
    global REGISTRY
    if REGISTRY is None:
        REGISTRY = Registry()
    return REGISTRY


def source_lines(row: dict[str, Any]) -> tuple[Path, list[str], int, int]:
    source = row["semantic_source"]
    path = ROOT / source["path"]
    all_lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    start, end = int(source["line_start"]), int(source["line_end"])
    if not (1 <= start <= end <= len(all_lines)):
        raise ValueError(f"invalid canonical source range for {row['identity']}: {start}-{end}")
    return path, all_lines[start - 1:end], start, end


def print_slice(path: Path, lines: list[str], start: int, end: int, label: str | None = None) -> None:
    heading = f"// {relative(path)}:{start}-{end}"
    if label:
        heading += f" [{label}]"
    print(heading)
    print("\n".join(lines))


def correspondence(row: dict[str, Any], detail: bool = False) -> dict[str, Any]:
    result: dict[str, Any] = {
        "identity": row["identity"],
        "original": {
            "function": row["original_function"],
            "address": row["original_address"],
            **row["original_source"],
        },
        "reconstructed": {
            "name": row["semantic_name"],
            **row["semantic_source"],
        },
        "renaming_confidence": row["renaming_confidence"],
        "reconstruction_status": row["reconstruction_status"],
        "behavioral_verification_status": row["behavioral_verification_status"],
        "strict_port": row.get("strict_port"),
    }
    if detail:
        result["evidence_references"] = row["evidence_references"]
        result["known_blockers"] = row["known_blockers"]
        result["technical_evidence"] = row.get("technical_evidence", {})
        result["source_revision"] = row.get("source_revision")
    return result


def cmd_function(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    if args.detail:
        print(json.dumps(correspondence(row, True), indent=2, ensure_ascii=False))
    path, lines, start, end = source_lines(row)
    print_slice(path, lines, start, end, row["identity"])
    return 0


def cmd_correspondence(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    print(json.dumps(correspondence(row, args.detail), indent=2, ensure_ascii=False))
    return 0


def cmd_excerpt(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    path, body, absolute_start, _ = source_lines(row)
    if args.lines:
        match = re.fullmatch(r"(\d+):(\d+)", args.lines)
        if not match:
            raise ValueError("--lines must be a relative START:END range")
        start, end = map(int, match.groups())
        if not (1 <= start <= end <= len(body)):
            raise ValueError(f"relative range {start}:{end} exceeds function lines 1:{len(body)}")
        label = f"{row['identity']} relative {start}:{end}"
    elif args.address:
        address_match = ADDRESS_RE.fullmatch(args.address)
        if not address_match:
            raise ValueError("--address must be hexadecimal")
        address = int(address_match.group(1), 16)
        if address == int(row["original_address"], 16):
            start = 1
        else:
            label_re = re.compile(rf"^\s*(?:LAB_|loc_)0*{address:x}\s*:", re.IGNORECASE)
            hits = [index for index, line in enumerate(body, 1) if label_re.search(line)]
            if len(hits) != 1:
                reason = "ambiguous" if hits else "unsupported"
                raise LookupError(f"{reason} address-to-source mapping {args.address} within {row['identity']}")
            start = hits[0]
        end = min(len(body), start + args.limit - 1)
        label = f"{row['identity']} address 0x{address:x}"
    else:
        needle = args.block.casefold()
        label_pattern = re.compile(r"^\s*(?:LAB_[0-9A-Fa-f]+|[A-Za-z_]\w*):")
        hits = [
            index for index, line in enumerate(body, 1)
            if needle in line.casefold() and (label_pattern.search(line) or "block" in line.casefold())
        ]
        if len(hits) != 1:
            reason = "ambiguous" if hits else "not found"
            raise LookupError(f"named block {args.block!r} {reason} in {row['identity']}")
        start = hits[0]
        next_labels = [
            index for index, line in enumerate(body[start:], start + 1)
            if label_pattern.search(line)
        ]
        end = min(next_labels[0] - 1 if next_labels else len(body), start + args.limit - 1)
        label = f"{row['identity']} block {args.block}"
    selected = body[start - 1:end]
    actual_start = absolute_start + start - 1
    print_slice(path, selected, actual_start, actual_start + len(selected) - 1, label)
    return 0


def call_names(row: dict[str, Any]) -> set[str]:
    return {row["original_function"], row["semantic_name"]}


def textual_callers(target: dict[str, Any]) -> list[str]:
    names = call_names(target)
    hits: list[str] = []
    for caller in registry().rows:
        path, body, start, _ = source_lines(caller)
        masked = mask_comments("\n".join(body)).splitlines()
        for offset, line in enumerate(masked):
            if any(re.search(rf"\b{re.escape(name)}\s*\(", line) for name in names):
                if caller["identity"] == target["identity"] and offset == 0:
                    continue
                hits.append(
                    f"{relative(path)}:{start + offset}:DIRECT_TEXTUAL_CALL:{caller['identity']}"
                    f"/{caller['semantic_name']}: {body[offset].strip()}"
                )
    return hits


def cmd_callers(args: argparse.Namespace) -> int:
    hits = textual_callers(registry().resolve(args.query, args.segment))
    for hit in hits[:args.limit]:
        print(hit)
    if len(hits) > args.limit:
        print(f"... {len(hits) - args.limit} more; rerun with --limit {len(hits)}")
    return 0


def textual_callees(caller: dict[str, Any]) -> list[tuple[int, str, str]]:
    path, body, start, _ = source_lines(caller)
    masked = mask_comments("\n".join(body))
    by_name: dict[str, list[dict[str, Any]]] = {}
    for row in registry().rows:
        for name in call_names(row):
            by_name.setdefault(name, []).append(row)
    hits: list[tuple[int, str, str]] = []
    for offset, line in enumerate(masked.splitlines()):
        for name in CALL_RE.findall(line):
            if name in CONTROL_WORDS or name == caller["semantic_name"] and offset == 0:
                continue
            matches = by_name.get(name, [])
            if len(matches) > 1:
                identities = ", ".join(row["identity"] for row in matches)
                raise LookupError(f"ambiguous callee {name!r} at {relative(path)}:{start + offset}: {identities}")
            if matches:
                hits.append((start + offset, matches[0]["identity"], body[offset].strip()))
    seen: set[tuple[int, str]] = set()
    unique = []
    for line, identity, source in hits:
        if (line, identity) not in seen:
            unique.append((line, identity, source))
            seen.add((line, identity))
    return unique


def cmd_callees(args: argparse.Namespace) -> int:
    caller = registry().resolve(args.query, args.segment)
    path = relative(ROOT / caller["semantic_source"]["path"])
    for line, identity, source in textual_callees(caller):
        print(f"{path}:{line}:DIRECT_TEXTUAL_CALL:{identity}: {source}")
    return 0


def access_for(line: str, name: str) -> str:
    stripped = line.strip()
    if re.search(rf"(?:\+\+|--)\s*{re.escape(name)}|{re.escape(name)}\s*(?:\+\+|--)", stripped):
        return "READ_WRITE"
    assignment = re.search(r"(?<![=!<>])([+\-*/%&|^]?=)(?!=)", stripped)
    if assignment:
        lhs, rhs = stripped[:assignment.start()], stripped[assignment.end():]
        in_lhs, in_rhs = name in lhs, name in rhs
        if in_lhs and (assignment.group(1) != "=" or in_rhs):
            return "READ_WRITE"
        if in_lhs:
            return "WRITE"
        if in_rhs:
            return "READ"
    return "UNKNOWN_ACCESS"


ALIAS_DEFINE_RE = re.compile(r"^#define\s+([A-Za-z_]\w*)\s+(_?DAT_[0-9A-Fa-f]+|PTR_\w+)\b", re.M)
_ALIAS_CACHE: dict[Path, dict[str, str]] = {}


def global_aliases(path: Path) -> dict[str, str]:
    """Readable `#define alias DAT_xxxx` names of one source file, as {alias: symbol}."""
    if path not in _ALIAS_CACHE:
        text = path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""
        _ALIAS_CACHE[path] = {alias: symbol for alias, symbol in ALIAS_DEFINE_RE.findall(text)}
    return _ALIAS_CACHE[path]


def textual_globals(path: Path, body: list[str], start: int, access: str = "all") -> list[dict[str, Any]]:
    accesses: dict[str, set[str]] = {}
    evidence: dict[str, list[str]] = {}
    aliases_seen: dict[str, set[str]] = {}
    aliases = global_aliases(path)
    alias_re = re.compile(r"\b(?:" + "|".join(sorted(map(re.escape, aliases), key=len, reverse=True)) + r")\b") if aliases else None
    masked = mask_comments("\n".join(body)).splitlines()
    for offset, line in enumerate(masked):
        found = {name: name for name in GLOBAL_RE.findall(line)}
        if alias_re:
            for alias in alias_re.findall(line):
                found.setdefault(alias, aliases[alias])
        for token, name in found.items():
            accesses.setdefault(name, set()).add(access_for(line, token))
            location = f"{relative(path)}:{start + offset}"
            if location not in evidence.setdefault(name, []):
                evidence[name].append(location)
            if token != name:
                aliases_seen.setdefault(name, set()).add(token)
    selected = []
    for name in sorted(accesses):
        values = sorted(accesses[name])
        if access != "all":
            wanted = {"reads": {"READ", "READ_WRITE"}, "writes": {"WRITE", "READ_WRITE"}, "unknown": {"UNKNOWN_ACCESS"}}[access]
            if not wanted.intersection(values):
                continue
        entry: dict[str, Any] = {"name": name, "access": values, "evidence": evidence[name]}
        if name in aliases_seen:
            entry["alias"] = sorted(aliases_seen[name])
        selected.append(entry)
    return selected


def cmd_globals(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    path, body, start, _ = source_lines(row)
    selected = textual_globals(path, body, start, args.access)
    print(json.dumps({"identity": row["identity"], "source": relative(path), "globals": selected}, indent=2))
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    print(json.dumps(correspondence(row, args.detail), indent=2, ensure_ascii=False))
    return 0


def cmd_symbol(args: argparse.Namespace) -> int:
    lines = SYMBOLS.read_text(encoding="utf-8", errors="replace").splitlines()
    hits = [index for index, line in enumerate(lines) if args.query.casefold() in line.casefold()]
    if not hits:
        raise LookupError(f"no symbol record found: {args.query}")
    shown: set[int] = set()
    for hit in hits[:args.limit]:
        for index in range(max(0, hit - args.context), min(len(lines), hit + args.context + 1)):
            if index not in shown:
                print(f"{relative(SYMBOLS)}:{index + 1}:{lines[index]}")
                shown.add(index)
    return 0


def cmd_source_map(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    mapping = row.get("strict_port")
    if not mapping:
        print(f"{row['identity']}: no strict-port translation")
        return 1
    print(json.dumps(mapping, indent=2, sort_keys=True))
    return 0


def gdscript_functions(path: Path) -> tuple[list[str], list[dict[str, Any]]]:
    lines = path.read_text(encoding="utf-8", errors="strict").splitlines()
    starts: list[tuple[int, str]] = []
    pattern = re.compile(r"^(?:static\s+)?func\s+([A-Za-z_]\w*)\s*\(")
    for number, line in enumerate(lines, 1):
        match = pattern.match(line)
        if match:
            starts.append((number, match.group(1)))
    if not starts:
        raise ValueError(f"no top-level GDScript functions in {relative(path)}")
    functions = []
    for index, (start, name) in enumerate(starts):
        end = starts[index + 1][0] - 1 if index + 1 < len(starts) else len(lines)
        while end > start and (not lines[end - 1].strip() or lines[end - 1].startswith("#")):
            end -= 1
        if end == start or not any(line.startswith(("\t", " ")) and line.strip() for line in lines[start:end]):
            raise ValueError(f"ambiguous/empty GDScript body at {relative(path)}:{start}")
        functions.append({"name": name, "start": start, "end": end, "lines": lines[start - 1:end]})
    return lines, functions


def find_test_file(query: str) -> Path:
    normalized = query.removesuffix(".gd")
    matches = [path for path in sorted((ROOT / "godot" / "tests").rglob("*.gd")) if path.stem == normalized]
    if not matches:
        raise LookupError(f"canonical GDScript test file not found: {query}")
    if len(matches) > 1:
        paths = ", ".join(relative(path) for path in matches)
        raise LookupError(f"ambiguous test file {query!r}: {paths}")
    return matches[0]


def cmd_tests(args: argparse.Namespace) -> int:
    path = find_test_file(args.query)
    lines, functions = gdscript_functions(path)
    by_name = {function["name"]: function for function in functions}
    if args.case not in by_name:
        candidates = [name for name in by_name if args.case.casefold() in name.casefold()]
        suffix = f"; partial matches: {', '.join(candidates)}" if candidates else ""
        raise LookupError(f"test case {args.case!r} not found in {relative(path)}{suffix}")
    selected = by_name[args.case]
    masked = mask_comments("\n".join(selected["lines"]))
    dependencies = []
    for name in dict.fromkeys(CALL_RE.findall(masked)):
        if name in by_name and name != args.case:
            dependencies.append(by_name[name])
    preamble_end = functions[0]["start"] - 1
    while preamble_end and not lines[preamble_end - 1].strip():
        preamble_end -= 1
    chunks: list[tuple[str, int, int, list[str]]] = []
    if preamble_end:
        chunks.append(("module setup", 1, preamble_end, lines[:preamble_end]))
    chunks.append(("selected test", selected["start"], selected["end"], selected["lines"]))
    for dependency in dependencies:
        chunks.append(("direct helper", dependency["start"], dependency["end"], dependency["lines"]))
    fixture_pattern = re.compile(r"res://[^\"']+")
    fixtures = sorted({match for _, _, _, chunk in chunks for match in fixture_pattern.findall("\n".join(chunk))})
    print(f"// test file: {relative(path)}; case: {args.case}; direct helpers: {len(dependencies)}")
    if fixtures:
        print("// fixtures: " + ", ".join(fixtures))
    for label, start, end, chunk in chunks:
        print_slice(path, chunk, start, end, label)
    return 0


# ---------------------------------------------------------------------------
# evidence: one bounded packet (original C, semantic C, 68020 bytes, context)
# ---------------------------------------------------------------------------

PROTECTED = ROOT / "docs" / "DECOMPILATION_PROTECTED_CHECKSUMS.sha256"
CODE_DIR = ROOT / "sources" / "resedit-1-0-3" / "CODE"
OVERLAY_BINARY = ROOT / "sources" / "mac-os-9" / "Pacific Conflict"
# docs/MISSION_DATA_LOCATIONS.md, "External file layout" (not in PROTECTED).
OVERLAY_SHA256 = "ee6040c7c38586551f95bf62a96453eef41b8b27409bc89d7a6689dc2c8b5030"
# docs/DECOMPILATION_SYMBOLS.md, "False entries and runtime-address callees":
# overlay lea/jsr/pea abs.l code operands are runtime addresses = file offset - 0x20.
OVERLAY_RUNTIME_SHIFT = 0x20
# Longest 68020 instruction is 22 bytes; decode real bytes past a bound so
# Capstone never fills a cut instruction with invented operand bytes.
LOOKAHEAD = 22
LABEL_RE = re.compile(r"^\s*(?:LAB_|loc_)([0-9A-Fa-f]+)\s*:")
ABS_RE = re.compile(r"^\$([0-9a-f]+)\.([wl])$")
UNRESOLVED_RE = re.compile(r"\b(?:UNRESOLVED|UNKNOWN|TODO|BLOCKED|UNVERIFIED)\b|\?\?")
CONDITIONS = "t f hi ls cc cs ne eq vc vs pl mi ge lt gt le hs lo ra".split()
SIGNED_CC = {"ge", "lt", "gt", "le", "mi", "pl", "vs", "vc"}
UNSIGNED_CC = {"hi", "ls", "cc", "cs", "hs", "lo"}
TERMINATORS = {"rts", "rte", "rtd", "rtr", "jmp", "bra"}
READ_ONLY = {"tst", "cmp", "cmpi", "cmpa", "cmpm", "cmp2", "btst", "chk", "chk2", "pea", "lea", "jsr", "jmp"}
WRITE_ONLY = {"move", "movea", "moveq", "clr", "lea"} | {f"s{cc}" for cc in CONDITIONS}
BUDGET_DIVISOR = 2.5  # bytes per token floor; cl100k measures ~2.7 on this C


class Budget:
    """Token counter: max(tiktoken cl100k_base, ceil(UTF-8 bytes / 2.5))."""

    def __init__(self) -> None:
        try:
            import tiktoken
            self.encoder = tiktoken.get_encoding("cl100k_base")
            self.name = f"max(cl100k_base, bytes/{BUDGET_DIVISOR})"
        except Exception:  # tokenizer missing or its encoding not cached
            self.encoder = None
            self.name = f"bytes/{BUDGET_DIVISOR} (no tiktoken)"

    def count(self, text: str) -> int:
        floor = -(-len(text.encode("utf-8")) * 2 // 5)
        if self.encoder is None:
            return floor
        return max(floor, len(self.encoder.encode(text, disallowed_special=())))


def sha256_bytes(data: bytes) -> str:
    import hashlib
    return hashlib.sha256(data).hexdigest()


def protected_checksums() -> dict[str, str]:
    result = {}
    for line in PROTECTED.read_text(encoding="utf-8").splitlines():
        if line.strip() and not line.startswith("#"):
            digest, name = line.split(None, 1)
            result[name.strip()] = digest
    return result


def segment_binary(segment: str) -> dict[str, Any]:
    if segment == "Pacific Conflict":
        path, expected, shift = OVERLAY_BINARY, OVERLAY_SHA256, OVERLAY_RUNTIME_SHIFT
        checksum_source = "docs/MISSION_DATA_LOCATIONS.md"
        mapping = "address = file offset; abs code operands are runtime = file - 0x20"
    else:
        path, shift = CODE_DIR / f"{segment}.bin", None
        expected = protected_checksums().get(path.name)
        checksum_source = relative(PROTECTED)
        mapping = "address = CODE payload offset (4-byte header included); A5 operands unresolved"
        if expected is None:
            raise LookupError(f"no protected checksum for {relative(path)}")
    blob = path.read_bytes()
    actual = sha256_bytes(blob)
    if actual != expected:
        raise ValueError(f"protected binary checksum mismatch: {relative(path)} {actual} != {expected} ({checksum_source})")
    return {"path": relative(path), "blob": blob, "sha256": actual, "size": len(blob),
            "checksum_source": checksum_source, "runtime_shift": shift, "mapping": mapping}


def disassembler() -> Any:
    import capstone
    engine = capstone.Cs(capstone.CS_ARCH_M68K, capstone.CS_MODE_BIG_ENDIAN | capstone.CS_MODE_M68K_020)
    engine.detail = False
    return engine, f"capstone {capstone.__version__} M68K_020 big-endian"


def decode(blob: bytes, start: int, end: int) -> list[dict[str, Any]]:
    engine, _ = disassembler()
    out = []
    for insn in engine.disasm(blob[start:min(len(blob), end + LOOKAHEAD)], start):
        if insn.address >= end:
            break
        if insn.address + insn.size > len(blob):
            raise ValueError(f"instruction at 0x{insn.address:x} runs past end of binary")
        out.append({"address": insn.address, "size": insn.size, "bytes": insn.bytes.hex(),
                    "mnemonic": insn.mnemonic, "op_str": insn.op_str})
    return out


def base_mnemonic(insn: dict[str, Any]) -> str:
    return insn["mnemonic"].split(".", 1)[0]


def operands(insn: dict[str, Any]) -> list[str]:
    parts, depth, current = [], 0, ""
    for char in insn["op_str"]:
        if char == "," and depth == 0:
            parts.append(current.strip()); current = ""
            continue
        depth += char == "("
        depth -= char == ")"
        current += char
    if current.strip():
        parts.append(current.strip())
    return parts


def branch_target(insn: dict[str, Any]) -> int | None:
    base = base_mnemonic(insn)
    if not (base == "bsr" or (base.startswith("b") and base[1:] in CONDITIONS)
            or (base.startswith("db") and base[2:] in CONDITIONS)):
        return None
    match = re.fullmatch(r"\$([0-9a-f]+)", operands(insn)[-1])
    return int(match.group(1), 16) if match else None


def extension_note(insn: dict[str, Any]) -> str | None:
    """Decode the mul.l/div.l extension word, which Capstone text abbreviates."""
    raw = bytes.fromhex(insn["bytes"])
    if len(raw) < 4 or (raw[0] != 0x4C) or (raw[1] & 0xC0) not in (0x00, 0x40):
        return None
    word = int.from_bytes(raw[2:4], "big")
    low, high = (word >> 12) & 7, word & 7
    kind = "div" if raw[1] & 0x40 else "mul"
    sign = "signed" if word & 0x800 else "unsigned"
    if kind == "div":
        size = "64/32" if word & 0x400 else "32/32"
        return f"ext ${word:04x} {sign[0]} {size} q=d{low} r=d{high}"
    size = "32x32->64 hi=d" + str(high) if word & 0x400 else "32x32->32"
    return f"ext ${word:04x} {sign[0]} {size} d{low}"


def c_function(path: Path, line_start: int, expected_name: str) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    offset = sum(len(line) + 1 for line in lines[:line_start - 1])
    masked = mask_comments(text)
    opening = masked.find("{", offset)
    if opening < 0 or not re.search(rf"\b{re.escape(expected_name)}\s*\(", masked[offset:opening]):
        raise ValueError(f"{relative(path)}:{line_start} does not open function {expected_name}")
    depth = 0
    for closing in range(opening, len(masked)):
        depth += masked[closing] == "{"
        depth -= masked[closing] == "}"
        if depth == 0 and masked[closing] == "}":
            break
    else:
        raise ValueError(f"unclosed function {expected_name} in {relative(path)}")
    line_end = text.count("\n", 0, closing) + 1
    return {"path": relative(path), "line_start": line_start, "line_end": line_end,
            "lines": lines[line_start - 1:line_end], "all_lines": lines, "text": text,
            "sha256": sha256_bytes(text[offset:closing + 1].replace("\r\n", "\n").encode("utf-8"))}


def labels_in(lines: list[str], first_line: int) -> dict[int, int]:
    result = {}
    for index, line in enumerate(lines):
        match = LABEL_RE.match(line)
        if match:
            result.setdefault(int(match.group(1), 16), first_line + index)
    return result


def function_extent(row: dict[str, Any], binary: dict[str, Any]) -> dict[str, Any]:
    start = int(row["original_address"], 16)
    addresses = sorted({int(other["original_address"], 16) for other in registry().rows
                        if other["segment"] == row["segment"]})
    later = [address for address in addresses if address > start]
    bound = later[0] if later else binary["size"]
    insns = decode(binary["blob"], start, bound)
    notes: list[str] = []
    furthest, end, method = start, None, None
    for insn in insns:
        if insn["mnemonic"] == "dc.w":
            end, method = insn["address"], "stopped at undecodable word"
            notes.append(f"UNCERTAIN: undecodable word at 0x{insn['address']:x}")
            break
        base = base_mnemonic(insn)
        target = branch_target(insn)
        if target is not None and base != "bsr":
            if start <= target < bound:
                furthest = max(furthest, target)
            else:
                notes.append(f"UNCERTAIN: branch 0x{insn['address']:x} leaves entry range -> 0x{target:x}")
        if base == "jmp" and "," in insn["op_str"]:
            notes.append(f"UNCERTAIN: computed jump 0x{insn['address']:x} {insn['op_str']}")
        if base in TERMINATORS and furthest <= insn["address"]:
            end = insn["address"] + insn["size"]
            method = f"{insn['mnemonic']}@0x{insn['address']:x}, no branch beyond"
            break
    if end is None:
        end = insns[-1]["address"] + insns[-1]["size"] if insns else start
        method = "no terminator before next entry"
        notes.append(f"UNCERTAIN: no terminating instruction before 0x{bound:x}")
    if end > bound:
        notes.append(f"UNCERTAIN: last instruction crosses next entry 0x{bound:x}")
    if end < bound:
        notes.append(f"{bound - end} bytes 0x{end:x}-0x{bound:x} precede next entry, outside this extent")
    insns = [insn for insn in insns if insn["address"] < end]
    return {"start": start, "end": end, "next_entry": bound, "method": method, "notes": notes, "insns": insns}


def resolve_address(segment: str, address: int) -> dict[str, Any] | None:
    for row in registry().rows:
        if row["segment"] == segment and int(row["original_address"], 16) == address:
            return row
    return None


def describe(segment: str, address: int) -> str:
    row = resolve_address(segment, address)
    return f"{row['original_function']}/{row['semantic_name']}" if row else f"0x{address:x} (no inventory entry)"


def is_push(insn: dict[str, Any]) -> int:
    base = base_mnemonic(insn)
    if base == "pea":
        return 4
    ops = operands(insn)
    if base in {"move", "clr", "movea"} and ops and ops[-1] == "-(a7)":
        return 4 if insn["mnemonic"].endswith(".l") else 2
    return 0


def call_sites(extent: dict[str, Any], segment: str, shift: int | None) -> list[dict[str, Any]]:
    insns = extent["insns"]
    targets = {branch_target(insn) for insn in insns}
    a_regs: dict[str, tuple[int, int]] = {}
    pushes: list[dict[str, Any]] = []
    reg_setup: dict[str, int] = {}
    calls = []
    for index, insn in enumerate(insns):
        base, ops = base_mnemonic(insn), operands(insn)
        if insn["address"] in targets:
            pushes = []
        dest = ops[-1] if ops else ""
        if base not in READ_ONLY - {"lea"} and re.fullmatch(r"[ad][0-7]", dest):
            a_regs.pop(dest, None)
            reg_setup[dest] = insn["address"]
        if base == "lea" and len(ops) == 2 and re.fullmatch(r"a[0-6]", ops[1]):
            pc_relative = re.fullmatch(r"\$([0-9a-f]+)\(pc\)", ops[0])
            if ABS_RE.match(ops[0]):
                a_regs[ops[1]] = ("runtime", int(ABS_RE.match(ops[0]).group(1), 16), insn["address"])
            elif pc_relative:
                a_regs[ops[1]] = ("file", int(pc_relative.group(1), 16), insn["address"])
        size = is_push(insn)
        if size:
            pushes.append({"address": insn["address"], "bytes": size, "text": f"{insn['mnemonic']} {insn['op_str']}"})
            continue
        if base in {"bsr", "jsr"}:
            call: dict[str, Any] = {"address": insn["address"], "text": f"{insn['mnemonic']} {insn['op_str']}"}
            operand = ops[0]
            absolute = ABS_RE.match(operand)
            if base == "bsr" or re.fullmatch(r"\$[0-9a-f]+\(pc\)", operand):
                file_target = branch_target(insn) if base == "bsr" else int(operand[1:operand.index("(")], 16)
                call.update(file_target=file_target, ghidra_name=f"FUN_{file_target:08x}", via="pc-relative")
            elif operand[1:3] in a_regs and a_regs[operand[1:3]][0] == "file" and operand == f"({operand[1:3]})":
                _, file_target, lea_at = a_regs[operand[1:3]]
                call.update(file_target=file_target, ghidra_name=f"FUN_{file_target:08x}", via=f"lea pc@0x{lea_at:x}")
            elif absolute or re.fullmatch(r"\(a[0-6]\)", operand):
                if absolute:
                    runtime, via = int(absolute.group(1), 16), "abs.l"
                elif operand[1:3] in a_regs:
                    _, runtime, lea_at = a_regs[operand[1:3]]
                    via = f"lea@0x{lea_at:x}"
                else:
                    runtime, via = None, "register not traced"
                if runtime is not None:
                    file_target = runtime + shift if shift is not None else None
                    call.update(runtime=runtime, file_target=file_target, ghidra_name=f"FUN_{runtime:08x}", via=via)
                else:
                    call.update(via=via)
            else:
                call["via"] = "unresolved operand (A5 jump table or indirect)"
            if call.get("file_target") is not None:
                call["callee"] = describe(segment, call["file_target"])
            nxt = insns[index + 1] if index + 1 < len(insns) else None
            cleanup = None
            if nxt:
                nops = operands(nxt)
                if nops and nops[-1] == "a7" and base_mnemonic(nxt) in {"addq", "adda", "lea"}:
                    match = re.match(r"#?\$([0-9a-f]+)", nops[0])
                    cleanup = int(match.group(1), 16) if match else None
            call.update(pushes=pushes, cleanup=cleanup,
                        regs={reg: f"0x{address:x}" for reg, address in sorted(reg_setup.items())
                              if reg in {"d0", "d1", "a0", "a1"}})
            calls.append(call)
            pushes, reg_setup = [], {}
        elif base in TERMINATORS or branch_target(insn) is not None or dest == "a7":
            pushes = []
    return calls


def c_call_args(lines: list[str], first_line: int, name: str) -> list[tuple[int, int]]:
    text = mask_comments("\n".join(lines))
    result = []
    for match in re.finditer(rf"\b{re.escape(name)}\s*\(", text):
        depth, index, args, current = 1, match.end(), 0, ""
        while index < len(text) and depth:
            char = text[index]
            depth += char == "("
            depth -= char == ")"
            if depth == 1 and char == ",":
                args += 1
            elif depth and not char.isspace():
                current += char
            index += 1
        line = first_line + text.count("\n", 0, match.start())
        result.append((line, args + 1 if current.strip() not in ("", "void") else 0))
    return result


def argument_checks(calls: list[dict[str, Any]], original: dict[str, Any], corrections: list[str]) -> list[str]:
    by_name: dict[str, list[dict[str, Any]]] = {}
    for call in calls:
        if "ghidra_name" in call:
            by_name.setdefault(call["ghidra_name"], []).append(call)
    out = []
    first = original["line_start"]
    for name in sorted(by_name):
        binary = [len(call["pushes"]) for call in by_name[name]]
        source = c_call_args(original["lines"], first, name)
        counts = [count for _, count in source]
        recorded = any(name in row or (by_name[name][0].get("callee", "").split("/")[-1] in row) for row in corrections)
        flag = ""
        if len(binary) == len(counts):
            short = [f"0x{call['address']:x}: C {c} < pushed {b}"
                     for call, b, c in zip(by_name[name], binary, counts) if c < b]
            if short:
                flag = "CANDIDATE omitted args (" + "; ".join(short) + ")"
        elif counts and max(counts) < max(binary):
            flag = f"CANDIDATE omitted args (count mismatch C={len(counts)} binary={len(binary)})"
        elif not counts:
            flag = "no textual call in original C"
        else:
            flag = f"call count differs C={len(counts)} binary={len(binary)}"
        out.append(f"{name}: binary pushes {binary}; original C args {counts}"
                   + (f" @ lines {[line for line, _ in source]}" if source else "")
                   + (f" -> {flag}" if flag else " -> consistent")
                   + (" [recorded correction exists]" if recorded and flag.startswith("CANDIDATE") else ""))
    return out


def symbol_rows(row: dict[str, Any]) -> list[str]:
    lines = SYMBOLS.read_text(encoding="utf-8", errors="replace").splitlines()
    names = [name for name in call_names(row) if name]
    section, out = "", []
    wanted = ("Call-argument corrections", "Signature corrections", "False entries and runtime-address callees")
    for number, line in enumerate(lines, 1):
        if line.startswith("## "):
            section = line[3:].strip()
        if section in wanted and line.startswith("|") and any(re.search(rf"\b{re.escape(n)}\b", line) for n in names):
            out.append(f"{relative(SYMBOLS)}:{number} [{section}] {line}")
    return out


def binary_callers(row: dict[str, Any], binary: dict[str, Any]) -> tuple[list[str], int]:
    blob, shift, target = binary["blob"], binary["runtime_shift"], int(row["original_address"], 16)
    import struct
    candidates: set[int] = set()
    for offset in range(0, len(blob) - 6, 2):
        word = struct.unpack_from(">H", blob, offset)[0]
        hi = word & 0xFF00
        if word == 0x6100 or word == 0x4EBA:
            if offset + 2 + struct.unpack_from(">h", blob, offset + 2)[0] == target:
                candidates.add(offset)
        elif word == 0x61FF:
            if offset + 2 + struct.unpack_from(">i", blob, offset + 2)[0] == target:
                candidates.add(offset)
        elif hi == 0x6100 and offset + 2 + struct.unpack_from(">b", blob, offset + 1)[0] == target:
            candidates.add(offset)
        elif shift is not None and (word & 0xF1FF in (0x41F9,) or word in (0x4EB9, 0x4879, 0x4EF9)):
            if struct.unpack_from(">I", blob, offset + 2)[0] + shift == target:
                candidates.add(offset)
    entries = sorted({int(other["original_address"], 16): other for other in registry().rows
                      if other["segment"] == row["segment"]}.items())
    decoded: dict[int, dict[int, dict[str, Any]]] = {}
    hits, rejected = [], 0
    for offset in sorted(candidates):
        owners = [other for address, other in entries if address <= offset]
        if not owners:
            rejected += 1
            continue
        owner = owners[-1]
        key = int(owner["original_address"], 16)
        if key not in decoded:
            extent = function_extent(owner, binary)
            decoded[key] = {insn["address"]: insn for insn in extent["insns"]}
        insn = decoded[key].get(offset)
        if insn is None:
            rejected += 1
            continue
        hits.append(f"0x{offset:x} {owner['original_function']}/{owner['semantic_name']}: {insn['mnemonic']} {insn['op_str']}")
    return hits, rejected


def callee_signature(callee: dict[str, Any]) -> str:
    path, lines, start, _ = source_lines(callee)
    header = []
    for line in lines:
        header.append(line.strip())
        if "{" in line or line.rstrip().endswith(")"):
            break
    signature = re.sub(r"/\*\s*Original:[^*]*\*/", "", " ".join(header)).replace("{", "").strip()
    return (f"{callee['original_function']}@{callee['original_address']} [{callee['reconstruction_status']}] "
            f"{' '.join(signature.split())}  ({relative(path)}:{start})")


def binary_globals(insns: list[dict[str, Any]]) -> list[str]:
    seen: dict[str, set[str]] = {}
    where: dict[str, list[str]] = {}
    for insn in insns:
        base, ops = base_mnemonic(insn), operands(insn)
        if base in {"lea", "pea", "jsr", "jmp"}:
            continue
        for index, operand in enumerate(ops):
            match = ABS_RE.match(operand)
            if not match:
                continue
            last = index == len(ops) - 1 and (len(ops) > 1 or base not in READ_ONLY)
            access = "R" if base in READ_ONLY or not last else "W" if base in WRITE_ONLY else "RW"
            width = insn["mnemonic"].split(".", 1)[1] if "." in insn["mnemonic"] else "?"
            name = f"DAT_{int(match.group(1), 16):08x}"
            seen.setdefault(name, set()).add(f"{access}.{width}")
            where.setdefault(name, []).append(f"0x{insn['address']:x}")
    return [f"{name} {','.join(sorted(seen[name]))} @ {' '.join(where[name])}" for name in sorted(seen)]


def checklist(insns: list[dict[str, Any]], calls: list[dict[str, Any]], globals_: list[str],
              labels: dict[int, int], window: tuple[int, int]) -> list[str]:
    widths: dict[str, int] = {}
    signed, unsigned, shifts, muldiv = set(), set(), set(), []
    for insn in insns:
        mnemonic = insn["mnemonic"]
        if "." in mnemonic:
            widths[mnemonic.rsplit(".", 1)[1]] = widths.get(mnemonic.rsplit(".", 1)[1], 0) + 1
        base = base_mnemonic(insn)
        cc = base[1:] if base.startswith("b") else base[2:] if base.startswith("db") else base[1:] if base.startswith("s") else ""
        if branch_target(insn) is not None or base in {f"s{c}" for c in CONDITIONS}:
            (signed if cc in SIGNED_CC else unsigned if cc in UNSIGNED_CC else set()).add(base)
        if base[:3] in {"asr", "asl", "lsr", "lsl", "ror", "rol"} or base in {"ext", "extb"}:
            shifts.add(mnemonic)
        if base[:3] in {"mul", "div"}:
            muldiv.append(f"{mnemonic}@0x{insn['address']:x}")
    inside = {branch_target(insn) for insn in insns} - {None}
    inside = {target for target in inside if window[0] <= target < window[1]}
    unlabeled = sorted(target for target in inside if target not in labels and target != window[0])
    writes = [entry for entry in globals_ if " W" in entry or "RW" in entry]
    targets = sorted({call.get("callee") or call["via"] for call in calls})
    return [
        f"[ ] widths: {', '.join(f'.{k}x{v}' for k, v in sorted(widths.items()))}; mul/div: {', '.join(muldiv) or 'none'}",
        f"[ ] signedness: signed cc {sorted(signed) or '-'}; unsigned cc {sorted(unsigned) or '-'}; shifts/ext {sorted(shifts) or '-'}",
        f"[ ] branches: {len(inside)} in-window targets; without original-C LAB_: {', '.join(f'0x{t:x}' for t in unlabeled) or 'none'} (structured if/loop, not missing)",
        f"[ ] call targets: {'; '.join(targets) or 'none'}",
        f"[ ] global writes (binary abs operands): {'; '.join(w.split(' @')[0] for w in writes) or 'none'}",
    ]


def doc_comment(lines: list[str], line_start: int) -> tuple[int, int] | None:
    index = line_start - 2
    while index >= 0 and not lines[index].strip():
        index -= 1
    if index < 0 or not lines[index].rstrip().endswith("*/"):
        return None
    end = index
    while index >= 0 and "/*" not in lines[index]:
        index -= 1
    return (index + 1, end + 1) if index >= 0 else None


def label_window(source: dict[str, Any], address: int, until: int, function_start: int) -> tuple[int, int] | None:
    """C lines from the label at `address` to the line before the first later
    label whose address is >= `until` (function end when there is none)."""
    labels = labels_in(source["lines"], source["line_start"])
    if address == function_start:
        first = source["line_start"]
    elif address in labels:
        first = labels[address]
    else:
        return None
    later = [line for label, line in labels.items() if label >= until and line > first]
    return first, (min(later) - 1 if later else source["line_end"])


def line_diff(old: list[str], old_first: int, new: list[str], new_first: int) -> list[str]:
    """Line diff with absolute line numbers. Replaced original lines are not
    repeated: they are in the original-C section of the same packet."""
    import difflib
    out = []
    matcher = difflib.SequenceMatcher(a=old, b=new, autojunk=False)
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            continue
        source = f"{old_first + i1}-{old_first + i2 - 1}" if i2 > i1 else f"after {old_first + i1 - 1}"
        target = f"{new_first + j1}-{new_first + j2 - 1}" if j2 > j1 else "deleted"
        out.append(f"@@ orig {source} -> sem {target}")
        out.extend(new[j1:j2])
    return out or ["(identical to original C excerpt)"]


def render_text(sections: list[dict[str, Any]]) -> str:
    out = []
    for section in sections:
        if section["title"]:
            out.append(f"## {section['title']}")
        out.extend(section["lines"])
    return "\n".join(out) + "\n"


def render_json(sections: list[dict[str, Any]]) -> str:
    return json.dumps({section["key"]: section["data"] for section in sections},
                      ensure_ascii=False, separators=(",", ":"), sort_keys=False) + "\n"


def cmd_evidence(args: argparse.Namespace) -> int:
    row = registry().resolve(args.query, args.segment)
    segment, ident = row["segment"], row["identity"]
    qualified = f"--segment {json.dumps(segment)} {row['original_function']}"
    budget = Budget()
    binary = segment_binary(segment)
    original_path = ROOT / row["original_source"]["path"]
    protected = protected_checksums()
    original = c_function(original_path, int(row["original_source"]["line_start"]), row["original_function"])
    original_file_ok = sha256_bytes(original["text"].encode("utf-8")) == protected.get(original_path.name)
    if not original_file_ok:
        raise ValueError(f"protected checksum mismatch for {relative(original_path)}")
    semantic = c_function(ROOT / row["semantic_source"]["path"], int(row["semantic_source"]["line_start"]), row["semantic_name"])
    if semantic["line_end"] != int(row["semantic_source"]["line_end"]):
        raise ValueError(f"semantic function end {semantic['line_end']} != inventory {row['semantic_source']['line_end']}")
    semantic_hash = "MATCH" if semantic["sha256"] == row["semantic_source"]["function_sha256"] else "STALE(inventory differs)"
    extent = function_extent(row, binary)
    start, end = extent["start"], extent["end"]
    addresses = {insn["address"] for insn in extent["insns"]}
    original_labels = labels_in(original["lines"], original["line_start"])

    def parse(value: str | None) -> int | None:
        if value is None:
            return None
        match = ADDRESS_RE.fullmatch(value)
        if not match:
            raise ValueError(f"address must be hexadecimal: {value}")
        return int(match.group(1), 16)

    focus, until = parse(args.address), parse(args.to)
    if focus is None:
        window = (start, end)
        orig_range = (original["line_start"], original["line_end"])
        sem_range: tuple[int, int] | None = (semantic["line_start"], semantic["line_end"])
    else:
        if focus not in addresses:
            raise LookupError(f"0x{focus:x} is not an instruction boundary inside {ident} extent 0x{start:x}-0x{end:x}")
        if until is not None and (until <= focus or (until not in addresses and until != end)):
            raise LookupError(f"--to 0x{until:x} must be an instruction boundary after 0x{focus:x} (or extent end 0x{end:x})")
        if until is None:
            later = sorted(address for address in original_labels if focus < address < end)
            until = later[0] if later else end
        window = (focus, until)
        orig_range = label_window(original, focus, until, start)
        if orig_range is None:
            nearby = ", ".join(f"0x{a:x}" for a in sorted(original_labels)[:30])
            raise LookupError(f"no original-C label LAB_{focus:08x} in {ident}; labelled addresses: {nearby}")
        sem_range = label_window(semantic, focus, until, start)
    window_insns = [insn for insn in extent["insns"] if window[0] <= insn["address"] < window[1]]

    calls_all = call_sites(extent, segment, binary["runtime_shift"])
    calls = [call for call in calls_all if window[0] <= call["address"] < window[1]]
    corrections = symbol_rows(row)
    targets = {branch_target(insn) for insn in extent["insns"]} - {None}

    # --- core sections ---------------------------------------------------
    _, engine_name = disassembler()
    blockers = "; ".join(row["known_blockers"]) or "none"
    tech = "; ".join(f"{k}={v}" for k, v in sorted(row.get("technical_evidence", {}).items())) or "none"
    header_data = {
        "identity": ident, "semantic_name": row["semantic_name"], "address": row["original_address"],
        "status": {k: row[k] for k in ("reconstruction_status", "renaming_confidence", "name_verified",
                                       "semantically_verified", "behavioral_verification_status")},
        "strict_port": bool(row.get("strict_port")), "blockers": row["known_blockers"],
        "technical_evidence": row.get("technical_evidence", {}),
        "binary": {k: binary[k] for k in ("path", "sha256", "size", "checksum_source", "mapping")},
        "decoder": engine_name,
        "extent": {"start": f"0x{start:x}", "end": f"0x{end:x}", "next_entry": f"0x{extent['next_entry']:x}",
                   "method": extent["method"], "instructions": len(extent["insns"]), "notes": extent["notes"]},
        "window": {"start": f"0x{window[0]:x}", "end": f"0x{window[1]:x}", "focused": focus is not None},
    }
    header_lines = [
        f"# EVIDENCE {ident} = {row['semantic_name']}",
        f"status {row['reconstruction_status']}; naming {row['renaming_confidence']} verified={row['name_verified']}; "
        f"semantic={row['semantically_verified']}; behavioral {row['behavioral_verification_status']}; "
        f"strict_port {'yes' if row.get('strict_port') else 'none'}; blockers: {blockers}; evidence: {tech}",
        f"binary {binary['path']} sha256 {binary['sha256'][:12]}.. OK; {binary['mapping']}; {engine_name}",
        f"extent 0x{start:x}-0x{end:x} ({len(extent['insns'])} insns) by {extent['method']}; next entry 0x{extent['next_entry']:x}",
    ] + [f"extent note: {note}" for note in extent["notes"]]
    if focus is not None:
        header_lines.append(f"focus: 0x{window[0]:x}-0x{window[1]:x} ({len(window_insns)} insns); C excerpts are "
                            f"LAB_-delimited, Ghidra structuring can move code across labels")
    sections: list[dict[str, Any]] = [{"key": "header", "title": "", "lines": header_lines, "data": header_data, "required": True}]

    orig_lines = original["all_lines"][orig_range[0] - 1:orig_range[1]]
    sections.append({
        "key": "original_c", "required": True,
        "title": f"original C {original['path']}:{orig_range[0]}-{orig_range[1]} "
                 f"(fn {original['line_start']}-{original['line_end']} sha256 {original['sha256'][:12]}.., file checksum OK)",
        "lines": orig_lines,
        "data": {"path": original["path"], "lines": list(orig_range), "function_lines": [original["line_start"], original["line_end"]],
                 "function_sha256": original["sha256"], "file_protected": True, "text": "\n".join(orig_lines)},
    })
    sem_form = "none"
    if sem_range is not None:
        sem_lines = semantic["all_lines"][sem_range[0] - 1:sem_range[1]]
        sem_form = "full"
        title = (f"semantic C {semantic['path']}:{sem_range[0]}-{sem_range[1]} (fn {semantic['line_start']}-"
                 f"{semantic['line_end']} sha256 {semantic['sha256'][:12]}.. inventory {semantic_hash})")
        if args.semantic != "full":
            diff = line_diff(orig_lines, orig_range[0], sem_lines, sem_range[0])
            if args.semantic == "diff" or budget.count("\n".join(diff)) < budget.count("\n".join(sem_lines)):
                sem_lines, sem_form = diff, "diff"
                title += " as diff: '@@ orig A-B -> sem C-D' replaces original lines A-B with the lines that follow (--semantic full)"
    else:
        sem_lines = [f"NOT FOUND: no LAB_{focus:08x} label in semantic C; full function {semantic['path']}:"
                     f"{semantic['line_start']}-{semantic['line_end']}"]
        title = "semantic C"
    sections.append({
        "key": "semantic_c", "required": True, "title": title, "lines": sem_lines,
        "data": {"path": semantic["path"], "lines": list(sem_range) if sem_range else None,
                 "function_lines": [semantic["line_start"], semantic["line_end"]],
                 "function_sha256": semantic["sha256"], "inventory_hash": semantic_hash, "form": sem_form,
                 "text": "\n".join(sem_lines)},
    })
    call_by_address = {call["address"]: call for call in calls_all}
    lea_notes = {}
    for insn in window_insns:
        ops = operands(insn)
        if (base_mnemonic(insn) in {"lea", "jsr", "jmp"} and ops and ABS_RE.match(ops[0])
                and ops[0].endswith(".l") and binary["runtime_shift"] is not None):
            runtime = int(ABS_RE.match(ops[0]).group(1), 16)
            target_row = resolve_address(segment, runtime + binary["runtime_shift"])
            lea_notes[insn["address"]] = (f"file 0x{runtime + binary['runtime_shift']:x}"
                                          + (f" {target_row['semantic_name']}" if target_row else " (no entry)"))
    disasm_lines, disasm_data = [], []
    for insn in window_insns:
        notes = []
        call = call_by_address.get(insn["address"])
        if call and call.get("callee"):
            notes.append(f"-> {call['callee'].split('/')[-1]}")
        elif call:
            notes.append(f"-> {call['via']}")
        if insn["address"] in lea_notes:
            notes.append(lea_notes[insn["address"]])
        extension = extension_note(insn)
        if extension:
            notes.append(extension)
        target = branch_target(insn)
        if target is not None and base_mnemonic(insn) != "bsr" and not window[0] <= target < window[1]:
            notes.append("leaves window")
        mark = "*" if insn["address"] in targets else " "
        raw = f"{insn['bytes']} " if args.bytes else ""
        text = f"{insn['address']:05x}{mark}{raw}{insn['mnemonic']} {insn['op_str']}".rstrip()
        disasm_lines.append(text + (f" ; {'; '.join(notes)}" if notes else ""))
        entry = {**insn, "branch_target": insn["address"] in targets, "notes": notes}
        if not args.bytes:
            entry.pop("bytes")
        disasm_data.append(entry)
    window_sha = sha256_bytes(binary["blob"][window[0]:window[1]])
    sections.append({
        "key": "disassembly", "required": True,
        "title": f"68020 disassembly 0x{window[0]:x}-0x{window[1]:x} (* = branch target; "
                 f"bytes sha256 {window_sha[:12]}..{'' if args.bytes else ', raw via --bytes'})",
        "lines": disasm_lines, "data": disasm_data,
    })

    # --- supplementary sections, in priority order ----------------------
    call_lines = []
    for call in calls:
        pushes = ", ".join(f"0x{p['address']:x} {p['text']}" for p in call["pushes"]) or "none"
        regs = ", ".join(f"{reg}@{at}" for reg, at in call["regs"].items()) or "-"
        cleanup = f"{call['cleanup']} bytes" if call["cleanup"] is not None else "not immediate"
        call_lines.append(f"0x{call['address']:x} {call['text']} -> {call.get('callee', call['via'])}: "
                          f"pushes [{pushes}] cleanup {cleanup}; d0/d1/a0/a1 set {regs}")
    sections.append({"key": "calls", "required": False, "title": "binary calls in window (pushes since previous call/branch; heuristic)",
                     "lines": call_lines or ["none"], "data": calls,
                     "hint": f"re_query.py evidence {qualified} --json --max-tokens N"})
    checks = argument_checks(calls_all if focus is None else calls, original, corrections)
    sections.append({"key": "argument_checks", "required": False,
                     "title": "argument-count cross-check vs original C (CANDIDATE = unverified)",
                     "lines": checks or ["no resolved calls"], "data": checks,
                     "hint": f"re_query.py evidence {qualified} --json"})
    sections.append({"key": "recorded_corrections", "required": False,
                     "title": "recorded corrections (docs/DECOMPILATION_SYMBOLS.md)",
                     "lines": corrections or ["none recorded"], "data": corrections,
                     "hint": f"re_query.py symbol {row['original_function']}"})
    window_globals = binary_globals(window_insns)
    labels_for_check = set(original_labels) | {start}
    sections.append({"key": "checklist", "required": False, "title": "verification checklist",
                     "lines": checklist(window_insns, calls, window_globals, labels_for_check, window),
                     "data": checklist(window_insns, calls, window_globals, labels_for_check, window),
                     "hint": "rerun with a larger --max-tokens"})
    unresolved = []
    doc = doc_comment(semantic["all_lines"], semantic["line_start"])
    scan_from = doc[0] if doc else semantic["line_start"]
    for number in range(scan_from, semantic["line_end"] + 1):
        line = semantic["all_lines"][number - 1]
        if re.search(r"Confidence:", line) or UNRESOLVED_RE.search(line):
            unresolved.append(f"{semantic['path']}:{number}: {line.strip()[:160]}")
    if doc:
        unresolved.insert(0, f"doc comment {semantic['path']}:{doc[0]}-{doc[1]} (not included)")
    sections.append({"key": "unresolved", "required": False, "title": "confidence / unresolved markers (semantic C)",
                     "lines": unresolved or ["none"], "data": unresolved,
                     "hint": f"rerun with a larger --max-tokens"})
    callee_rows: dict[str, dict[str, Any]] = {}
    for _, identity, _ in textual_callees(row):
        callee_rows[identity] = next(r for r in registry().rows if r["identity"] == identity)
    for call in calls_all:
        callee = resolve_address(segment, call["file_target"]) if call.get("file_target") is not None else None
        if callee:
            callee_rows[callee["identity"]] = callee
    callee_rows.pop(ident, None)
    signatures = [callee_signature(callee_rows[key]) for key in sorted(callee_rows)]
    sections.append({"key": "callees", "required": False, "title": "callee signatures (source + binary targets)",
                     "lines": signatures or ["none"], "data": signatures,
                     "hint": f"re_query.py callees {qualified}"})
    if sem_range is not None:
        globals_source = textual_globals(ROOT / semantic["path"], semantic["all_lines"][sem_range[0] - 1:sem_range[1]], sem_range[0])
    else:
        globals_source = textual_globals(original_path, orig_lines, orig_range[0])
    global_lines = [f"{g['name']}{' (' + ', '.join(g['alias']) + ')' if g.get('alias') else ''} {'/'.join(g['access'])} @ {', '.join(e.rsplit(':', 1)[1] for e in g['evidence'])}" for g in globals_source]
    sections.append({"key": "globals", "required": False,
                     "title": "globals: source access (line numbers) | binary abs operands (R/W.width @addr)",
                     "lines": (global_lines or ["source: none"]) + (["binary:"] + window_globals if window_globals else ["binary: none"]),
                     "data": {"source": globals_source, "binary": window_globals},
                     "hint": f"re_query.py globals {qualified}"})
    header_end = semantic["line_start"] + next(i for i, line in enumerate(semantic["lines"]) if "{" in line)
    source_callers = [hit for hit in textual_callers(row)
                      if not (f":DIRECT_TEXTUAL_CALL:{ident}/" in hit
                              and int(hit.split(":", 2)[1]) <= header_end)]
    limit = args.callers
    caller_lines = source_callers[:limit]
    if len(source_callers) > limit:
        caller_lines.append(f"... {len(source_callers) - limit} more: re_query.py callers {qualified} --limit {len(source_callers)}")
    sections.append({"key": "callers_source", "required": False, "title": f"callers in source ({len(source_callers)})",
                     "lines": caller_lines or ["none"], "data": source_callers,
                     "hint": f"re_query.py callers {qualified}"})
    bin_hits, rejected = binary_callers(row, binary)
    bin_lines = bin_hits[:limit] + ([f"... {len(bin_hits) - limit} more (--callers {len(bin_hits)})"] if len(bin_hits) > limit else [])
    bin_lines.append(f"byte matches rejected (not an instruction boundary in a known function): {rejected}")
    sections.append({"key": "callers_binary", "required": False,
                     "title": f"callers in binary ({len(bin_hits)} verified bsr/jsr/lea/pea references)",
                     "lines": bin_lines, "data": {"verified": bin_hits, "rejected": rejected},
                     "hint": f"re_query.py evidence {qualified} --callers {len(bin_hits)} --max-tokens N"})

    # --- budget: required core, then whole optional sections by priority ---
    render = render_json if args.json else render_text
    required = [section for section in sections if section["required"]]
    optional = [section for section in sections if not section["required"]]
    focus_args = (f" --address 0x{window[0]:x} --to 0x{window[1]:x}" if focus is not None else "")
    complete = budget.count(render(sections + [{"key": "budget", "title": "", "lines": ["-- budget: ~00000/00000"], "data": {}}])) + 16
    rerun = f"re_query.py evidence {qualified}{focus_args} --max-tokens {complete}"

    def assemble(chosen: list[dict[str, Any]], left_out: list[dict[str, Any]]) -> str:
        final = [section for section in sections if section in chosen]
        if left_out:
            lines = [f"{o['key']} ~{budget.count(render([o]))}: {o['hint'] if o['hint'].startswith('re_query.py') and 'evidence' not in o['hint'] else 'complete packet'}"
                     for o in left_out]
            lines.append(f"complete packet: {rerun}")
            final.append({"key": "omitted", "title": "OMITTED whole sections for --max-tokens (~tokens: retrieve with)",
                          "lines": lines, "data": {"sections": [o["key"] for o in left_out], "complete_packet": rerun}})
        footer = {"key": "budget", "title": "", "lines": [], "data": None}
        final.append(footer)
        text = render(final)
        tokens = budget.count(text)
        footer["lines"] = [f"-- budget: ~{tokens}/{args.max_tokens} tokens ({budget.name}), {len(text.encode())} bytes"]
        footer["data"] = {"tokens": tokens, "max_tokens": args.max_tokens, "counter": budget.name}
        return render(final)

    chosen, left_out = list(required), []
    output = assemble(chosen, optional)
    if budget.count(output) > args.max_tokens:
        core = {section["key"]: budget.count(render([section])) for section in required}
        label_list = sorted({window[0]} | {address for address in original_labels if window[0] < address < window[1]})
        counts = []
        for index, address in enumerate(label_list):
            nxt = label_list[index + 1] if index + 1 < len(label_list) else window[1]
            counts.append(f"0x{address:x}({sum(1 for a in addresses if address <= a < nxt)})")
        hint = (f"Narrow with --address A [--to B] (A = function start or an original-C LAB_ address; "
                f"--to may be any instruction boundary). Blocks (insns to next label): "
                f"{', '.join(counts[:40])}{' ...' if len(counts) > 40 else ''}. Or raise --max-tokens.")
        print(f"ERROR: core evidence for {ident} window 0x{window[0]:x}-0x{window[1]:x} needs ~{budget.count(output)} tokens "
              f"> --max-tokens {args.max_tokens} ({', '.join(f'{k} ~{v}' for k, v in core.items())}; with omission notice; "
              f"counter {budget.name}). Nothing was truncated. {hint}", file=sys.stderr)
        return 2
    for index, section in enumerate(optional):
        trial = assemble(chosen + [section], left_out + optional[index + 1:])
        if budget.count(trial) <= args.max_tokens:
            chosen.append(section)
        else:
            left_out.append(section)
    output = assemble(chosen, left_out)
    assert budget.count(output) <= args.max_tokens
    sys.stdout.write(output)
    return 0


def add_function_query(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("query")
    parser.add_argument("--segment")


def parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="command", required=True)
    command = sub.add_parser("function", help="print one reconstructed C function")
    add_function_query(command); command.add_argument("--detail", action="store_true"); command.set_defaults(func=cmd_function)
    command = sub.add_parser("correspondence", help="show original/reconstruction/strict-port correspondence")
    add_function_query(command); command.add_argument("--detail", action="store_true"); command.set_defaults(func=cmd_correspondence)
    command = sub.add_parser("excerpt", help="print a bounded relative line, address, or named-block excerpt")
    add_function_query(command)
    group = command.add_mutually_exclusive_group(required=True)
    group.add_argument("--lines"); group.add_argument("--address"); group.add_argument("--block")
    command.add_argument("--limit", type=int, default=40); command.set_defaults(func=cmd_excerpt)
    command = sub.add_parser("callers", help="print direct textual call sites")
    add_function_query(command); command.add_argument("--limit", type=int, default=40); command.set_defaults(func=cmd_callers)
    command = sub.add_parser("callees", help="print direct reconstructed callees")
    add_function_query(command); command.set_defaults(func=cmd_callees)
    command = sub.add_parser("globals", help="list globals and conservative access direction")
    add_function_query(command); command.add_argument("--access", choices=("all", "reads", "writes", "unknown"), default="all"); command.set_defaults(func=cmd_globals)
    command = sub.add_parser("status", help="show canonical reconstruction status")
    add_function_query(command); command.add_argument("--detail", action="store_true"); command.set_defaults(func=cmd_status)
    command = sub.add_parser("symbol", help="search the symbol reference")
    command.add_argument("query"); command.add_argument("--context", type=int, default=1); command.add_argument("--limit", type=int, default=10); command.set_defaults(func=cmd_symbol)
    command = sub.add_parser("source-map", help="show strict-port mapping for one function")
    add_function_query(command); command.set_defaults(func=cmd_source_map)
    command = sub.add_parser("tests", help="print one GDScript test case plus direct dependencies")
    command.add_argument("query"); command.add_argument("--case", required=True); command.set_defaults(func=cmd_tests)
    command = sub.add_parser("evidence", help="one token-bounded packet: original C, semantic C, 68020 bytes, calls, globals, status")
    add_function_query(command)
    command.add_argument("--address", help="focus on the LAB_-delimited block starting at this address")
    command.add_argument("--to", help="end the focused window at this address (exclusive)")
    command.add_argument("--max-tokens", type=int, default=4000)
    command.add_argument("--callers", type=int, default=12, help="caller sites listed per source/binary list")
    command.add_argument("--bytes", action="store_true", help="include raw instruction bytes")
    command.add_argument("--semantic", choices=("auto", "full", "diff"), default="auto",
                         help="semantic C verbatim, or as a lossless diff vs the original (auto: smaller)")
    command.add_argument("--json", action="store_true"); command.set_defaults(func=cmd_evidence)
    return ap


def main() -> int:
    args = parser().parse_args()
    try:
        return args.func(args)
    except (LookupError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
