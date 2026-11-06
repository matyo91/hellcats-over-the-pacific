#!/usr/bin/env python3
"""Reproduce the audit's representative context workloads (UTF-8 bytes / 4)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
PYTHON = sys.executable
BASELINES = {
    "A_decompilation_iteration_full": 11085,
    "A_decompilation_iteration_hand_filtered": 3863,
    "B_strict_port_translation": 29011,
    "C_resource_inspection": 2346,
    "D_architecture_startup": 5658,
    "E_regression_investigation": 4056,
}


def command_bytes(*args: str) -> tuple[int, str]:
    result = subprocess.run(args, cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return len(result.stdout), " ".join(args[1:])


def workload(files: list[str], commands: list[tuple[str, ...]]) -> dict[str, Any]:
    inputs = []
    total = 0
    for name in files:
        size = len((ROOT / name).read_bytes())
        total += size
        inputs.append({"input": name, "bytes": size})
    for command in commands:
        size, label = command_bytes(*command)
        total += size
        inputs.append({"input": label, "bytes": size})
    return {"bytes": total, "estimated_tokens": (total + 3) // 4, "inputs": inputs}


def main() -> int:
    re_query = (PYTHON, "tools/re_query.py")
    resedit = (PYTHON, "tools/resedit.py")
    measured = {
        "A_decompilation_iteration": workload(
            ["AGENTS.md", "docs/port/DECOMPILATION_PROGRESS.md"],
            [
                (*re_query, "correspondence", "--segment", "Pacific Conflict", "FUN_0000e792"),
                (*re_query, "excerpt", "--segment", "Pacific Conflict", "FUN_0000e792", "--address", "0xf47c", "--limit", "40"),
                (*re_query, "globals", "--segment", "Pacific Conflict", "FUN_0000e792", "--access", "writes"),
            ],
        ),
        "B_strict_port_translation": workload(
            ["AGENTS.md", "docs/port/STRICT_PORT_FOUNDATION.md"],
            [
                (*re_query, "function", "--segment", "Pacific Conflict", "FUN_0000e42a"),
                (*re_query, "callers", "--segment", "Pacific Conflict", "FUN_0000e42a"),
                (*re_query, "globals", "--segment", "Pacific Conflict", "FUN_0000e42a"),
                (*re_query, "correspondence", "--segment", "Pacific Conflict", "FUN_0000e42a"),
                (*re_query, "tests", "test_flight_math", "--case", "_test_fun_0000e42a"),
            ],
        ),
        "C_resource_inspection": workload(
            ["AGENTS.md"],
            [
                (*resedit, "inspect", "DITL", "137"),
                (*resedit, "item", "DITL", "137", "5"),
                (*resedit, "references", "DITL", "137"),
            ],
        ),
        "D_architecture_startup": workload(
            ["AGENTS.md", "README.md", "docs/architecture/PROJECT_STATUS.md"], []
        ),
        "E_regression_investigation": workload(
            ["AGENTS.md"],
            [
                (*re_query, "function", "--segment", "Pacific Conflict", "FUN_0000e42a"),
                (*re_query, "tests", "test_flight_math", "--case", "_test_fun_0000e42a"),
            ],
        ),
    }
    comparisons = {
        "A_vs_full": {
            "before": BASELINES["A_decompilation_iteration_full"],
            "after": measured["A_decompilation_iteration"]["estimated_tokens"],
        },
        "A_vs_hand_filtered": {
            "before": BASELINES["A_decompilation_iteration_hand_filtered"],
            "after": measured["A_decompilation_iteration"]["estimated_tokens"],
        },
    }
    for key in ("B_strict_port_translation", "C_resource_inspection", "D_architecture_startup", "E_regression_investigation"):
        comparisons[key] = {"before": BASELINES[key], "after": measured[key]["estimated_tokens"]}
    for values in comparisons.values():
        values["reduction_tokens"] = values["before"] - values["after"]
        values["reduction_percent"] = round(100 * values["reduction_tokens"] / values["before"], 1)
    print(json.dumps({"method": "ceil(UTF-8 bytes / 4); command stdout plus listed files", "measured": measured, "comparisons": comparisons}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
