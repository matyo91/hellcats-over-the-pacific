# Testing

This project uses **project-local tests** only:
- Godot runtime tests in `godot/tests`
- Python QA checks in `tools/qa`

We do **not** use Godot engine-internal doctest. Contributors should not assume engine source checkout, engine test harnesses, or doctest macros.

## Why no engine-internal doctest

- This repo is a clean-room game reimplementation, not a Godot engine fork.
- Contributors should be able to validate behavior from repo root with standard Godot + Python.
- Keeping tests project-local avoids coupling to engine internals and engine build workflows.

## Test categories

### 1) Godot unit tests (`godot/tests/unit`)
- Examples: RNG parity, flight math, loader metadata parsing.
- **Proves:** isolated core logic and deterministic helpers match expected fixtures/vectors.
- **Does not prove:** full-system behavior across multi-step runtime flows.

### 2) Godot integration tests (`godot/tests/integration`)
- Examples: sim/loader bridge behavior, replay trace parity.
- **Proves:** cross-module behavior and deterministic replay behavior at runtime.
- **Does not prove:** historical binary equivalence for every code path or platform-level timing.

### 3) Replay/trace determinism checks (Godot)
- Implemented via integration replay tests.
- **Proves:** same seed + same replay fixture => stable trace output for covered scenarios.
- **Does not prove:** determinism for scenarios not represented in fixtures.

### 4) Fixture/metadata integrity checks (Python)
- `tools/qa/test_regression.py` validates fixture schema/content and expected test layout.
- **Proves:** fixtures and metadata are structurally valid and not silently drifting.
- **Does not prove:** runtime gameplay correctness by itself.

### 5) Python-side binary/tool validation (`tools/qa`)
- Validates deterministic assumptions around migrated fixtures/tool outputs.
- **Proves:** non-engine validation guardrails stay intact in CI/local checks.
- **Does not prove:** Godot runtime behavior (that is covered by `godot/tests`).

## Run commands

Run from repo root (`/Users/math/Sites/darkwood/hellcats-over-the-pacific`).

### Run one Godot test (single-file temporary runner)

```bash
python3 - <<'PY'
from pathlib import Path
test_path = "res://godot/tests/unit/test_rng.gd"  # change as needed
runner = Path("godot/tests/.run_one_tmp.gd")
runner.write_text(f"""extends SceneTree
func _init() -> void:
\tvar t = load("{test_path}").new()
\tquit(0 if bool(t.run()) else 1)
""")
PY
godot --headless --path . --script res://godot/tests/.run_one_tmp.gd
rm -f godot/tests/.run_one_tmp.gd
```

### Run all Godot tests

```bash
godot --headless --path . --script res://godot/tests/run_all.gd
```

### Run Python QA validation

```bash
python3 tools/qa/test_regression.py
```
