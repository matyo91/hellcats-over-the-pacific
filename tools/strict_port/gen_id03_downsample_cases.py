#!/usr/bin/env python3
"""Generate comparison cases for antialias_downsample_bw_3x (ID03 0xa3c) by running the ORIGINAL
bytes.

The set-up is gen_id03_gauges_cases.py's (ID03.bin at 0x30000, A5 = 0x20000, ID01 and ID02 behind
their slots; nearest_palette_index_rgb runs for real over the seeded palette) with a 1-bit source
port seeded with patterns; MoveTo, Line and the colour slot $36a keep digest logs. Each case records
the original's entry stack pointer ("a7"). test_id03_downsample.gd replays the cases
(helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id03_downsample_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_id03_gauges_cases as gauges  # noqa: E402
import gen_id03_helpers_cases as helpers  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id03_downsample_cases.json")
A5 = helpers.A5
SRC, BITS, OUT = 0x13900, 0x13A00, 0x13980
ROUTINES = {"antialias_downsample_bw_3x": 0xA3C}
L, W, case = helpers.L, helpers.W, helpers.case


def bits(seed: int, density: float) -> list[list[int]]:
    rng = random.Random(seed)
    return [[BITS + k, 1, sum(1 << b for b in range(8) if rng.random() < density)] for k in range(0x200)]


def common() -> list[list[int]]:
    w = gauges.common() + [[a, 4, 0] for a in range(0x13900, 0x13C00, 4)]
    vals = [(SRC + 2, 4, BITS), (SRC + 6, 2, 0x10)]
    return w + [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in vals]


def build() -> list[dict]:
    out = []
    for label, rows, cols, seed, density, mode, with_out in (("sparse, 8-bit", 6, 8, 1, 0.2, 8, True),
                                                             ("dense, 8-bit", 5, 10, 2, 0.8, 8, False),
                                                             ("blank", 4, 6, 3, 0.0, 8, True),
                                                             ("half, 4-bit", 7, 12, 4, 0.5, 4, True),
                                                             ("one row", 1, 5, 5, 0.5, 8, True)):
        out.append(case(f"downsample {label}", "antialias_downsample_bw_3x", [L(SRC), W(40), W(-7), W(rows), W(cols), L(OUT if with_out else 0)],
                        [SRC, 40, -7, rows, cols, OUT if with_out else 0], bits(seed, density) + [[A5 - 0x137A, 2, mode]]))
    return out


def main() -> None:
    base = common()
    helpers.STUBS, helpers.CALL_LOGS, helpers.ROUTINES = gauges.STUBS, gauges.CALL_LOGS, ROUTINES
    logs = [["addr" if e[0] == "local" else e[0], e[1], e[2], e[3], e[4], e[5], {str(i): n for i, n in e[6].items()}] + e[7:]
            for e in gauges.CALL_LOGS]
    out = {"memory_size": helpers.MEMORY_SIZE, "a5": A5, "stack_top": helpers.STACK_TOP, "stack_guard": list(helpers.STACK_GUARD),
           "common_writes": base, "call_logs": logs, "cases": []}
    for c in build():
        changes, _ = helpers.run(c, base)
        out["cases"].append({"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes,
                             "a7": helpers.STACK_TOP - sum(size for size, _ in c["stack"]) - 4})
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
