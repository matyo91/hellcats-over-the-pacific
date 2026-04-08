# Mission 01 MVP (Flight School vertical slice)

Implementation-oriented notes for the first playable training mission. **[RECONSTRUCTED]** = from binary analysis; **[INFERRED]** = reasonable extrapolation; **[MVP AUTHORING DECISION]** = chosen for speed/scope; **[UNKNOWN]** = not blocking the slice.

---

## 1. Goal

- **[INFERRED]** One playable training mission in Godot with deterministic stepping and seams for higher-fidelity RE later.
- **[MVP AUTHORING DECISION]** Prefer playability and momentum over full historical parity (campaign, rendering, systems).

---

## 2. Scope

| In scope | Out of scope (this milestone) |
| -------- | ------------------------------ |
| One mission, ordered objectives, success/failure | Full campaign, replay infra, full loader emulation |
| HUD-first (speed, altitude, heading, throttle, objective, banners) | Map mode, polished cockpit art/audio, full NPC logic |
| Placeholder world/aircraft, keyboard flight | Full weapons, damage, carrier ops, exact takeoff fidelity |

**Unknown but not blocking:** **[UNKNOWN]** Original training script wording, exact historical scoring, full HUD/rendering parity.

---

## 3. RE context (constraints, not blocking code)

Useful for future fidelity; MVP can approximate.

- **[RECONSTRUCTED]** Tick order (`FUN_000044e8`), entity arrays, RNG parity (tested).
- **[RECONSTRUCTED]** Input mapping (`FUN_0000740a`): semantic paths, press/release (`param_2 == 3`), mission globals.
- **[RECONSTRUCTED]** `DAT_0001b738` player flight actor; mission gates `DAT_0001b5a0 + 0xa8/+0xac` (`0 < phase < 6`, `+0xac == 0` pre-step path).
- **[INFERRED]** Mimic transitions around states `1/5/7/8/9` without a full FSM name map.
- **[UNKNOWN]** Full names for control accumulators (`0x66e`/`0x672`/`0x66a`) and complete key-table parity—refine after the slice plays.

---

## 4. Architecture

### 4.1 Scene layout (current)

Paths under `res://godot/scenes/` (see also `Main.tscn` run scene in `project.godot`).

- `main/Main.tscn` — root `Node` that instances `missions/Mission01Training.tscn`.
- `missions/Mission01Training.tscn` — `World` (instances `world/Mission01World.tscn`), `PlayerAircraft`, `Checkpoints` (`Node3D` + `checkpoint_manager.gd`), `HUD` (instances `ui/HUD_MVP.tscn`), `MissionController` (`mission_controller.gd`).
- `world/Mission01World.tscn` — `Node3D` + `world_builder_mvp.gd` (builds sky, sun, sea, island placeholder at runtime).
- `player/PlayerAircraft.tscn` — `Node3D` + `player_aircraft.gd`, simple meshes, follow `Camera3D`.
- `mission/Checkpoint.tscn` — `Node3D` + `checkpoint.gd` (ring pass), spawned by checkpoint manager from JSON.
- `ui/HUD_MVP.tscn` — `CanvasLayer` + labels for title, objective, telemetry, status (`hud_mvp.gd` uses paths under `RootMargin/VBox/`).

### 4.2 Scripts and roles

| Area | Script (expected path) | Role |
| ---- | ---------------------- | ---- |
| Core | `hellcats/core/sim_core.gd` | Fixed-step / deterministic sequencing (existing sim bridge). |
| Core | `hellcats/core/flight_math.gd` | Shared math for flight/control. |
| Flight | `hellcats/flight/aircraft_state.gd` | Telemetry: speed, altitude, attitude, throttle, flags. |
| Flight | `hellcats/flight/player_input_map.gd` | Actions → normalized control intent. |
| Flight | `hellcats/flight/flight_model_mvp.gd` | MVP integrator (`AircraftState` + control intent + `flight_math`). |
| Mission | `hellcats/mission/mission_controller.gd` | Loads JSON, wires player, checkpoints, HUD; objectives, failure checks, restart. |
| Mission | `hellcats/mission/mission_objectives_m1.gd` | Pure, testable objective evaluation from telemetry snapshots (data-driven). |
| Mission | `hellcats/mission/checkpoint.gd` | Ring pass / signal once per pass. |
| Player | `hellcats/player/player_aircraft.gd` | Scene adapter: input → model → transform/collisions. |
| UI | `hellcats/ui/hud_mvp.gd` | Presentation only; no direct mission logic queries. |
| World | `hellcats/world/world_builder_mvp.gd` | Placeholder terrain/sea/sky (if used). |

**Seams (later fidelity):** keep tuning in one place (e.g. `flight_tuning_mvp` / resources); objectives driven from `godot/data/`; RNG via `hellcats/core/rng.gd` for anything stochastic.

---

## 5. Data layer

**Authoritative gameplay tunables** live in **`godot/data/mission_01/`** (committed JSON). **[MVP AUTHORING DECISION]** Do not mix loader/extraction fixtures (`hellcats/tests/fixtures/proven_loader_targets.json`, segment IDs, etc.) into mission gameplay JSON.

| File | Purpose |
| ---- | -------- |
| `mission_01_training.json` | `mission_id`, `version`, `start_mode`, `spawn`, `objective_sequence`, `success`, `failure`, optional `checkpoint_ref` / `ui`. |
| `checkpoints_mission_01.json` | Ring `id`, `position_m`, `radius_m`, `required`, `order`. |
| `aircraft_mvp.json` | **[INFERRED]** Optional until flight tuning is fully externalized; schema in earlier drafts: limits, control rates, speed/climb model. |

If this doc’s numbers drift from JSON, **trust the JSON** and update the doc.

---

## 6. Controls

**Primary**

| Action | Keys |
| ------ | ---- |
| Pitch down / up | `Down` / `Up` |
| Roll left / right | `Left` / `Right` or `A` / `D` |
| Yaw left / right | `Q` / `E` |
| Throttle down / up | `Page Down` / `Page Up` or `S` / `W` |

**Mission**

| Action | Keys |
| ------ | ---- |
| Restart | `R` |
| Quit / back | `Esc` (or stop scene in harness) **[MVP AUTHORING DECISION]** |

**Behavior:** **[MVP AUTHORING DECISION]** Keyboard-only, digital axes with smoothing (`input_lerp`); opposite inputs on one axis net to zero.

---

## 7. Start condition

- **[MVP AUTHORING DECISION]** **Airborne** start (no carrier deck) to avoid deck collision, launch alignment, and low-speed edge cases before the flight model is mature.
- **Spawn defaults:** see `mission_01_training.json` → `spawn` (position, `heading_deg`, `airspeed_mps`, `throttle_01`). Example values at authoring time: altitude ~1200 m, ~95 m/s, throttle ~0.72—**[INFERRED]** pitch/roll/yaw neutral with a short settle window in code if needed.

---

## 8. Flight model (MVP)

**[MVP AUTHORING DECISION]** Low-parameter arcade blend; deterministic.

- **State:** throttle 0–1, airspeed, altitude, VS, pitch/roll/yaw and rates, heading.
- **Rough behavior:** throttle → target speed band; pitch affects climb and bleed; roll drives bank and turn rate with speed; yaw is weak trim; VS from pitch + speed, damped.
- **Safety:** soft stall band (`aircraft_mvp.json` → `stall.speed_mps_below`, **55 m/s** at authoring) with heavy damping/sink bias; **hard fail** if **`stall_seconds`** in the snapshot reaches **`failure.stall_seconds`** (**4.0 s**); optional auto-level when no pitch/roll input.

Exact coefficients may live in code or future `aircraft_mvp.json`.

---

## 9. Mission flow and objectives

High-level order (strict; no skipping):

1. Stabilize (level flight in band).
2. Left turn (bank / heading per rules).
3. Right turn.
4. Climb.
5. Descend.
6. Checkpoint (may be optional in data—see below).

Then **mission_success** (freeze, banner, restart) or **mission_failure** (reason, freeze, restart).

### 9.1 Pass/fail — align with `mission_01_training.json`

The JSON is the contract. Snapshot at authoring (update when files change):

| Step | Intent (from data) |
| ---- | ------------------ |
| Stabilize | Hold near target altitude with tolerance and `hold_seconds` (e.g. ~6 s, band centered on spawn altitude ± tolerance). |
| Left / right turn | `reach_bank` with `min_bank_deg` and direction. |
| Climb | Reach at least `min_altitude_m` (e.g. +250 m from cruise). |
| Descend | At or below `max_altitude_m`. |
| Checkpoint | `checkpoint_pass` with `checkpoint_id`; **`optional: true`** means success triggers after required objectives; optional step can be skipped (`mission_objectives_m1` + `mission_controller`). |

**[INFERRED]** Additional checks (e.g. minimum heading change on turns, min airspeed on climb) may exist in code even if not in JSON—keep evaluator and data in sync.

**Mission success:** after all **required** objectives complete (per `success` block).

**Mission failure (global during play):**

- Terrain/sea impact (altitude vs surface + margin).
- Out of bounds horizontal radius from mission center for **> 8.0 s** (tune in scene).
- Hard stall: **`stall_seconds`** ≥ **`failure.stall_seconds`** (4.0 s), driven by sub-threshold airspeed in `flight_model_mvp` vs `stall.speed_mps_below` in `aircraft_mvp.json` (55 m/s at authoring).

Checkpoint ring size/position: `checkpoints_mission_01.json` (`radius_m`, etc.).

---

## 10. HUD

**[MVP AUTHORING DECISION]** Overlay: speed, altitude, heading, throttle %, current objective, success/failure banner. Optional later: horizon line, cockpit frame.

---

## 11. Deferred (explicit)

- Enemy AI, wingmen, combat.
- Weapons, ammo, damage.
- Carrier takeoff/landing, radio/VO, briefing cinematics.
- Advanced aero (torque, compressibility, high-fidelity stall).
- Full campaign scoring/debrief screens.

---

## 12. Build order (suggested)

1. Scenes + `mission_runtime` + HUD shell.
2. `player_input_map` + `flight_model_mvp` + `player_aircraft` loop.
3. `mission_objectives_m1` + checkpoints + data load from `godot/data/mission_01/`.
4. HUD bindings + failure checks (impact, OOB timer, stall timer).
5. Placeholder art + camera; polish pass.

---

## 13. Run and test

### Run (editor)

- Open Godot at **project root** (folder with `project.godot`).
- For fast iteration: set **`godot/scenes/missions/Mission01Training.tscn`** as run scene, or open and play it.
- Alternatively **`Main.tscn`** if it boots Mission 01.

### Automated

From repo root (paths match `godot/tests/run_all.gd`):

```bash
godot --headless --path . --script res://godot/tests/run_all.gd
python3 tools/qa/test_regression.py
```

Extend `run_all.gd` when mission-rule unit tests are added; keep `tools/qa/test_regression.py` path lists aligned.

### Manual smoke

Short session checklist: **`tools/qa/README.md`** → **Mission 1 smoke** (HUD live, complete objectives in order, success banner, one failure path, **R** restart).

---

## 14. QA principle

Automate cheap, deterministic contracts (math, RNG, loader fixtures, objective evaluator inputs). Manual: camera, readability, feel. Details: **`tools/qa/README.md`**.

---

## 15. Reusable RE knowledge (short)

- **[RECONSTRUCTED]** Main sim tick order, input mapping seeds, deterministic RNG, early flight-math slices—enough for a stable MVP loop and future swaps.
- **[INFERRED]** Full loader→mission context chain is long-term; not required for Mission 01 playability.
