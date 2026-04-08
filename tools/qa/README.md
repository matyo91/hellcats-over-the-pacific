# QA (Mission 1 MVP + determinism)

This folder contains Python-side deterministic guardrails that complement the
Godot-native runtime tests in `godot/tests`. Mission 1 MVP validation is split:
**automated** (math, fixtures, future mission-rule unit tests) vs **manual**
(camera, world, HUD, feel); see `docs/MISSION_01_MVP.md` § QA.

## Mission 1 smoke (manual, ~10–15 min)

Run after RE/data/Godot/gameplay changes. Assumes keyboard layout from the MVP doc.

**Launch**

- Open project in Godot; run `godot/scenes/missions/Mission01Training.tscn` (or `Main.tscn` if that boots Mission 01). If the scene path differs, use whatever entry scene wires `mission_runtime` + player + HUD.

**Sanity (≤ 1 min)**

- HUD shows speed, altitude, heading, throttle, objective text; values change while flying.
- Aircraft responds to pitch/roll/yaw/throttle; no immediate uncontrolled spin at spawn.

**Happy path**

- Complete objectives **in order** (stabilize → left turn → right turn → climb → descend → checkpoint) per on-screen objective text.
- Confirm **success banner** appears; controls freeze or mission state is clearly terminal; **R** restarts cleanly.

**Failure spot-check (pick one)**

- Provoke **hard stall** (throttle low until speed < 48 m/s for ~4 s) **or** fly **out of bounds** ~8 s **or** hit **sea/terrain** — expect **failure banner** + frozen/terminal state; **R** restarts.

**Pass:** no crashes, objectives cannot be skipped, success and at least one failure path behave consistently.

## Automated commands (CI / local)

```bash
# Godot headless suite (RNG, flight math, loader, replay, …)
godot --headless --path . --script res://godot/tests/run_all.gd

# Static fixture + runner layout checks (no engine)
python3 tools/qa/test_regression.py
```

When Mission 1 rule tests land, register them in `godot/tests/run_all.gd` and keep `EXPECTED_RUNNER_PATHS` in `test_regression.py` aligned.

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
