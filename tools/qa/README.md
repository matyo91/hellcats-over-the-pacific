# QA Determinism Checks

This folder contains Python-side deterministic guardrails that complement the
Godot-native runtime tests in `godot/tests`.

## Scope split (no overlap)

- `godot/tests/run_all.gd`:
  - Executes runtime behavior checks (RNG parity, replay parity, loader metadata
    lookup behavior, sim integration bridge).
- `tools/qa/test_regression.py`:
  - Validates migrated test layout is stable (`run_all.gd` path list).
  - Enforces fixture schema and deterministic fixture contents.
  - Detects fixture drift between migrated fixtures and legacy duplicates.

The Python QA checks avoid engine execution and avoid duplicating runtime logic.

## Run

From repo root:

```bash
python3 tools/qa/test_regression.py
```

## Deterministic expectations (enforced)

- RNG parity is owned by `godot/tests/unit/test_rng.gd`.
- Replay parity is owned by `godot/tests/integration/test_replay.gd`:
  same seed + same replay fixture => byte-identical JSONL traces.
- Loader metadata consistency is owned by:
  - `godot/tests/unit/test_loader_metadata.gd`
  - `godot/tests/integration/test_sim_loader_bridge.gd`
- Fixture drift protection is owned by `tools/qa/test_regression.py`:
  - exact loader target tuple set for proven entries
  - `entrypoint_offset == stored_tail + delta` invariant (`delta` in `{4, 6}`)
  - replay input packet shape and frame count
  - byte-equality between legacy and migrated fixture copies (while both exist)
