#!/usr/bin/env python3
"""Each strict-port function calls what its semantic C calls.

For every mapping, the mapped functions the semantic .decomp.c body calls (by name) must be
reached by the ported body: called by name, through a jump-table constant (_jt, by
runtime/data/jump_table.json), a segment offset (_local, segment_methods.json) or an overlay
code address (_jsr / _bsr_unported, overlay_methods.json), directly or through the port file's
own private helpers (names starting with '_', followed transitively). A callee the port never
reaches is a shortcut the original does not take: an inlined copy, another routine (as ID05's
decoders once skipped decode_base26_6chars). A port that computes a callee's address cannot be
followed: ALLOWED names those, with why.

The reverse holds too: a ported body (its own, helpers aside) calls no mapped function of its
file that none of the C bodies mapped to it calls (one port function may stand for a routine
Ghidra split, its _tail included), or the runtime evidence would credit a function the original
does not run there (ansi_strcat once called ansi_strcpy for its inline copy). C calls by Ghidra
name (FUN_000002b0) are resolved by address; a call Ghidra left as a label is in EXTRA_ALLOWED,
with the evidence for it.

Usage: python3 tools/strict_port/check_callees.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "godot" / "strict_port" / "mappings" / "functions.json"
DATA = ROOT / "godot" / "runtime" / "data"
## Ports that reach their callees through a computed address: "file:function" -> why.
ALLOWED = {
    "pacific_conflict.gd:collect_far_objects": "_far_collision computes the address of one of the four collision "
                                               "tests (handle_player_contact, test_object_collision, "
                                               "test_player_vs_type0e_proximity, test_proximity_collision)",
}
## Port calls the C bodies make only through a label Ghidra did not recover: "file:function" ->
## {callee: the evidence}.
EXTRA_ALLOWED = {
    "pacific_conflict.gd:turn_camera_toward_point": {
        "fold_angle_pm_0x2000": "the header's call to file 0xe40c (LAB_0000e3e8_4 in the Ghidra C)"},
    "pacific_conflict.gd:build_attitude_matrix_from_dir_roll": {
        "isqrt_floor": "LEA $e352 = isqrt_floor (file 0xe372), called through LAB_0000e350_2"},
}
CALL = re.compile(r"\b(\w+)\s*\(")
## A GDScript comment: '#' to the end of the line, outside a string (the ports' strings hold no '#').
GD_COMMENT = re.compile(r"#[^\n]*")
GD_FUNC = re.compile(r"^(?:static )?func ", re.M)


def braced(text: str, start: int) -> str:
    """The { ... } block from the first brace at or after start."""
    i = text.index("{", start)
    depth = 0
    for j in range(i, len(text)):
        depth += {"{": 1, "}": -1}.get(text[j], 0)
        if depth == 0:
            return text[i:j + 1]
    return text[i:]


def c_body(text: str, name: str) -> str | None:
    """A definition's body: a line starting at column 0 (not a statement inside another body)."""
    m = re.search(r"^(?:[A-Za-z_][^\n;=]*?\b)?" + re.escape(name) + r"\s*\([^;{]*\)\s*\{", text, re.M)
    return braced(text, m.start()) if m else None


def gd_func(text: str, name: str) -> str | None:
    m = re.search(r"^(?:static )?func " + re.escape(name) + r"\(", text, re.M)
    if not m:
        return None
    n = GD_FUNC.search(text, m.end())
    return text[m.start():n.start() if n else len(text)]


def with_helpers(text: str, body: str) -> str:
    """The body and, transitively, the bodies of the file's private helpers it calls."""
    seen: set[str] = set()
    stack, out = [body], []
    while stack:
        b = stack.pop()
        out.append(b)
        for helper in set(re.findall(r"\b(_\w+)\s*\(", b)) - seen:
            seen.add(helper)
            hb = gd_func(text, helper)
            if hb:
                stack.append(hb)
    return "\n".join(out)


def reached(text: str, body: str, segment: str | None, jt: dict, segments: dict, overlay: dict) -> set[str]:
    """The names a ported body reaches: called directly or through a slot, offset or address."""
    consts = dict(re.findall(r"^const (\w+): int = (0x[0-9a-f]+|\d+)", text, re.M))
    names = set(CALL.findall(body))
    for kind, arg in re.findall(r"\b(_jt|_jsr|_bsr_unported|_local)\(\s*(\w+)", body):
        value = consts.get(arg, arg if re.fullmatch(r"0x[0-9a-f]+|\d+", arg) else None)
        if value is None:
            continue
        n = int(value, 0)
        if kind == "_jt":
            names.add(jt.get(n, ""))
        elif kind == "_jsr":
            names.add(overlay.get(n, ""))
        elif kind == "_bsr_unported":
            names.add(overlay.get(n - 0x20, ""))         # a file address; overlay methods are by runtime address
        elif segment is not None:
            names.add(segments.get(segment, {}).get(hex(n), ""))
    return names


def main() -> int:
    rows = json.loads(MANIFEST.read_text(encoding="utf-8"))["functions"]
    jt = {e["a5_offset"]: e["method"] for e in json.loads((DATA / "jump_table.json").read_text())["entries"] if e["method"]}
    segments = json.loads((DATA / "segment_methods.json").read_text())
    overlay = {int(k, 16): v for k, v in json.loads((DATA / "overlay_methods.json").read_text()).items()}
    sources = {r["source_function"] for r in rows}
    target = {r["source_function"]: r["target_function"] for r in rows}
    # A semantic C body may call a function by its Ghidra name (FUN_000002b0): that is the mapping
    # at that address in the same source file.
    by_address = {(r["source_file"], int(r["source_address"], 16)): r["source_function"] for r in rows}
    texts: dict[Path, str] = {}

    def read(path: Path, strip_comments: bool) -> str:
        if path not in texts:
            t = path.read_text(encoding="utf-8", errors="replace")
            # C: block comments; GDScript: line comments (a doc comment names calls it does not make)
            texts[path] = re.sub(r"/\*.*?\*/", "", t, flags=re.S) if strip_comments else GD_COMMENT.sub("", t)
        return texts[path]

    failures, unlocated = [], []
    groups: dict[str, dict] = {}                         # port function -> its C calls, rows, body
    for r in rows:
        key = f"{Path(r['target_file']).name}:{r['target_function']}"
        c = c_body(read(ROOT / r["source_file"], True), r["source_function"])
        gd_text = read(ROOT / r["target_file"], False)
        gd = gd_func(gd_text, r["target_function"])
        if c is None or gd is None:
            unlocated.append(key)
            continue
        stem = Path(r["target_file"]).stem
        segment = str(int(stem[2:])) if stem.startswith("ID") else None
        names = reached(gd_text, with_helpers(gd_text, gd), segment, jt, segments, overlay)
        called = {by_address.get((r["source_file"], int(n[4:], 16)), n) if re.fullmatch(r"FUN_[0-9a-f]{8}", n) else n
                  for n in CALL.findall(c)}
        g = groups.setdefault(key, {"calls": set(), "sources": set(), "own": reached(gd_text, gd, segment, jt, segments, overlay)})
        g["calls"] |= called
        g["sources"].add(r["source_function"])
        callees = {n for n in called if n in sources and n != r["source_function"]}
        missing = sorted(n for n in callees if target[n] not in names)
        if missing and key not in ALLOWED:
            failures.append(f"{key} never reaches {', '.join(missing)}")
    # The reverse: mapped functions of the same file the port's own body reaches, which no C body
    # mapped to it calls.
    by_target: dict[str, set[str]] = {}
    for r in rows:
        by_target.setdefault(f"{Path(r['target_file']).name}:{r['target_function']}", set()).add(r["source_function"])
    for key, g in groups.items():
        file = key.split(":")[0]
        for other, srcs in by_target.items():
            name = other.split(":")[1]
            if other == key or other.split(":")[0] != file or name not in g["own"]:
                continue
            if srcs & (g["calls"] | g["sources"]) or name in EXTRA_ALLOWED.get(key, {}):
                continue
            failures.append(f"{key} calls {name}, which its semantic C does not")
    for f in failures:
        print(f"FAIL {f}")
    print(f"{'PASS' if not failures else 'FAIL'} {len(rows) - len(unlocated)} ports checked against their semantic C's "
          f"callees, both ways ({len(ALLOWED)} computed and {sum(map(len, EXTRA_ALLOWED.values()))} label calls "
          f"allowed; {len(unlocated)} bodies not located)")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
