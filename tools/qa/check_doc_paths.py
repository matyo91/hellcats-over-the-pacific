#!/usr/bin/env python3
"""Every docs/ path named in the repository's text exists.

Markdown links are checked by check_markdown_links.py; this covers the plain mentions in code,
comments and prose (`docs/reference/STRUCTS.md`, "see docs/topics/SOUND_SYSTEM.md"), which a moved
or renamed document would otherwise leave pointing nowhere. Generated fixtures are left out.

Usage: python3 tools/qa/check_doc_paths.py
"""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MENTION = re.compile(r"(?<![\w./-])docs/[\w./#-]*[\w]")
TEXT = {".md", ".py", ".gd", ".c", ".txt", ".cfg", ".sh"}


def main() -> int:
    tracked = subprocess.run(["git", "ls-files", "--cached", "--others", "--exclude-standard"], cwd=ROOT,
                             capture_output=True, text=True, check=True).stdout.split("\n")
    broken = []
    for name in tracked:
        path = ROOT / name
        if not name or path.suffix not in TEXT or "fixtures" in path.parts or not path.is_file():
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            for mention in MENTION.findall(line):
                target = mention.split("#", 1)[0].rstrip(".")
                if not (ROOT / target).exists():
                    broken.append(f"{name}:{number}: {mention}")
    for b in broken:
        print(f"BROKEN {b}")
    print(f"{'FAIL' if broken else 'PASS'} docs/ path mentions: {len(broken)} broken")
    return 1 if broken else 0


if __name__ == "__main__":
    raise SystemExit(main())
