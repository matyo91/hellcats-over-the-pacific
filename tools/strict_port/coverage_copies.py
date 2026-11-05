#!/usr/bin/env python3
"""Instrumented copies of the strict port for the smoke session's coverage run.

The strict port files are never edited: this writes copies of godot/strict_port/code/*.gd into
godot/.coverage/ (ignored by Godot's importer and by Git), each named function's body starting with
one line that records "ID02.gd:name" in Engine's "strict_coverage" metadata. smoke_session.gd
--coverage loads each copy and makes it take over its original's res:// path before the runtime
loads the port, so every call, including those between routines of one file, is recorded.

The copies drop their class_name line (the original keeps the registration; the copy answers its
path). A one-line function (func f(c: int) -> int: return ...) is split into its signature, the
recording line and its body. Anonymous lambdas (func(...) inside expressions) are not instrumented.

--check instruments in memory only and fails unless every function's recording line sits in its
own body, under its own name (a misplaced one would credit the wrong function in the evidence).

Usage: python3 tools/strict_port/coverage_copies.py [--check]
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "godot" / "strict_port" / "code"
OUT = ROOT / "godot" / ".coverage"
FUNC = re.compile(r"^(\s*)(?:static\s+)?func\s+(\w+)\s*\(")


def instrument(text: str, name: str) -> tuple[str, int]:
    lines = text.split("\n")
    out: list[str] = []
    count = 0
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("class_name "):
            i += 1
            continue
        m = FUNC.match(line)
        out.append(line)
        if not m:
            i += 1
            continue
        # The signature may span lines: it ends where its parameter list closes, at the ':' after
        # it (a return type has no ':'); what follows on that line is a one-line function's body.
        depth = 0
        close = -1                                 # where the parameter list closes, on the last line
        while True:
            for k, ch in enumerate(out[-1]):
                if ch == "(":
                    depth += 1
                elif ch == ")":
                    depth -= 1
                    if depth == 0:
                        close = k
                        break
            if close >= 0:
                break
            i += 1
            out.append(lines[i])
        last = out[-1]
        colon = last.index(":", close)
        body = last[colon + 1:].strip()
        body_indent = m.group(1) + "\t"
        marker = f'{body_indent}Engine.get_meta("strict_coverage")["{name}:{m.group(2)}"] = true'
        if body and not body.startswith("#"):
            out[-1] = last[:colon + 1]
            out.append(marker)
            out.append(body_indent + body)
        else:
            out.append(marker)
        count += 1
        i += 1
    return "\n".join(out), count


def misplaced() -> list[str]:
    """Recording lines that name another function than the one whose body holds them, and
    functions with no recording line."""
    problems = []
    for path in sorted(SOURCE.glob("*.gd")):
        text, _ = instrument(path.read_text(encoding="utf-8"), path.name)
        current = None
        marked: set[str] = set()
        declared: set[str] = set()
        for line in text.split("\n"):
            m = FUNC.match(line)
            if m:
                current = m.group(2)
                declared.add(current)
            r = re.search(r'\["[^"]+:(\w+)"\] = true', line)
            if r:
                if r.group(1) != current:
                    problems.append(f"{path.name}: {r.group(1)}'s line is in {current}")
                marked.add(r.group(1))
        problems += [f"{path.name}: {f} has no recording line" for f in sorted(declared - marked)]
    return problems


def main() -> int:
    if "--check" in sys.argv:
        problems = misplaced()
        for p in problems:
            print(f"FAIL {p}")
        if not problems:
            print("PASS every function records itself")
        return 1 if problems else 0
    OUT.mkdir(exist_ok=True)
    (OUT / ".gdignore").write_text("", encoding="utf-8")
    (OUT / ".gitignore").write_text("*\n", encoding="utf-8")
    for stale in OUT.glob("*.gd"):                 # a removed port file leaves no copy behind
        stale.unlink()
    total = 0
    for path in sorted(SOURCE.glob("*.gd")):
        text, n = instrument(path.read_text(encoding="utf-8"), path.name)
        (OUT / path.name).write_text(text, encoding="utf-8")
        total += n
    print(f"wrote {len(list(SOURCE.glob('*.gd')))} instrumented copies ({total} functions) to {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
