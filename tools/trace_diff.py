#!/usr/bin/env python3
"""
Diff two JSONL trace files. Reports the first frame and field(s) where they differ.
Exit 0 if traces are identical; non-zero on first divergence or length mismatch.
"""

import json
import sys
from pathlib import Path


def load_trace(path: Path) -> list[dict]:
    records = []
    with open(path, "r", encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as e:
                print(f"{path}: line {i}: invalid JSON: {e}", file=sys.stderr)
                sys.exit(2)
    return records


def compare_value(a: object, b: object) -> bool:
    """Compare for equality; treat missing key as 0 for int fields."""
    if a is None and b is None:
        return True
    if type(a) != type(b):
        return False
    if isinstance(a, dict):
        return compare_record(a, b)
    if isinstance(a, int) and isinstance(b, int):
        return (a & 0xFFFFFFFF) == (b & 0xFFFFFFFF)
    return a == b


def compare_record(left: dict, right: dict) -> bool:
    """Compare two trace records; return True if equal."""
    all_keys = set(left) | set(right)
    for k in all_keys:
        lv = left.get(k)
        rv = right.get(k)
        if k == "player":
            if not compare_value(lv, rv):
                return False
            continue
        if k == "input":
            if not compare_value(lv or {}, rv or {}):
                return False
            continue
        if isinstance(lv, dict) and isinstance(rv, dict):
            if not compare_record(lv, rv):
                return False
            continue
        # int or scalar: missing => 0 for parity with "omit zero" in player
        lv = lv if lv is not None else 0
        rv = rv if rv is not None else 0
        if not compare_value(lv, rv):
            return False
    return True


def diff_fields(left: dict, right: dict, prefix: str = "") -> list[str]:
    """Return list of field paths that differ (e.g. 'rng_state', 'player.pos_2e')."""
    diffs: list[str] = []
    all_keys = set(left) | set(right)
    for k in all_keys:
        path = f"{prefix}{k}" if prefix else k
        lv = left.get(k)
        rv = right.get(k)
        if k == "player":
            if lv is None and rv is None:
                continue
            if lv is None or rv is None:
                diffs.append(path)
                continue
            diffs.extend(diff_fields(lv, rv, f"{path}."))
            continue
        if k == "input":
            if compare_value(lv or {}, rv or {}):
                continue
            if isinstance(lv, dict) and isinstance(rv, dict):
                diffs.extend(diff_fields(lv, rv, f"{path}."))
            else:
                diffs.append(path)
            continue
        lv = lv if lv is not None else 0
        rv = rv if rv is not None else 0
        if not compare_value(lv, rv):
            diffs.append(path)
    return diffs


def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: trace_diff.py <trace_a.jsonl> <trace_b.jsonl>", file=sys.stderr)
        sys.exit(2)
    path_a = Path(sys.argv[1])
    path_b = Path(sys.argv[2])
    if not path_a.is_file():
        print(f"Not a file: {path_a}", file=sys.stderr)
        sys.exit(2)
    if not path_b.is_file():
        print(f"Not a file: {path_b}", file=sys.stderr)
        sys.exit(2)

    trace_a = load_trace(path_a)
    trace_b = load_trace(path_b)

    for i, (ra, rb) in enumerate(zip(trace_a, trace_b)):
        frame = ra.get("frame", i + 1)
        if not compare_record(ra, rb):
            fields = diff_fields(ra, rb)
            print(f"First divergence at frame {frame}")
            print(f"  Fields: {', '.join(fields)}")
            for f in fields:
                parts = f.split(".")
                a_val = ra
                b_val = rb
                for p in parts:
                    a_val = (a_val or {}).get(p)
                    b_val = (b_val or {}).get(p)
                print(f"    {f}: a={a_val!r} b={b_val!r}")
            sys.exit(1)

    if len(trace_a) != len(trace_b):
        print(f"Length mismatch: {path_a} has {len(trace_a)} frames, {path_b} has {len(trace_b)}")
        print(f"First extra frame in {'B' if len(trace_b) > len(trace_a) else 'A'} at frame index {min(len(trace_a), len(trace_b)) + 1}")
        sys.exit(1)

    # Identical
    print(f"Traces identical ({len(trace_a)} frames).")
    sys.exit(0)


if __name__ == "__main__":
    main()
