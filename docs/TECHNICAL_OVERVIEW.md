# Technical overview — Hellcats Over the Pacific (Godot)

This document is a **single entry point**: what the project is, how the code is organized, how reverse engineering feeds implementation, and how we iterate without breaking the playable slice. For symbol-level tables and contracts, see `docs/SUBSYSTEM_MAP.md`, `docs/STRUCTS.md`, and `docs/contracts/`.

## 1) Project overview

### What is *Hellcats Over the Pacific*?

*Hellcats Over the Pacific* is a classic Macintosh flight combat sim. This repository does **not** ship the original binary as playable code. It hosts a **clean-room reimplementation** of the simulation and mission layer in **Godot 4**, driven by evidence from decompiled C and documented behavior.

### What this project is doing

- Rebuild gameplay-relevant systems with **traceable links** to the original (function names, offsets, gates).
- Keep a **playable vertical slice** (Mission 01 training) while gradually replacing approximations with reconstructed logic.
- Prefer **determinism and testability** where the original allows it (tick order, RNG layer, structured traces).

### Why Godot

- Modern scene graph for **player, world, HUD, and mission orchestration** without emulating the classic Mac UI toolkit.
- Scriptable integration tests and headless runs for **regression and convergence** work.
- Clear separation between **authored presentation** (3D placeholders, camera) and **simulation seams** (`SimCore`, flight math, input mapping).

## 2) Current state of the project

### What is already implemented

- A **deterministic RE core**: sim tick ordering aligned with the original main update (`FUN_000044e8`), four entity passes with `param_2` pattern, mission phase/flag bridge, RNG (segment LCG style), entity state keys, loader metadata ingestion.
- **Contracts and docs** for tick, input, flight slices, mission globals (`docs/contracts/`, `docs/NOTES.md`).
- **Trace / replay scaffolding**: JSONL traces, replay runner, diff tool — see `docs/TRACE.md`.

### What is playable

- **Mission 01** (training vertical slice): authored mission JSON, objectives, checkpoints, success/failure, restart, HUD telemetry (speed, altitude, heading, throttle, objective text).
- **Keyboard flight** via an MVP flight model wired to input and smoothing work derived from the entity update path (`FUN_0000e792` slices).

### What is still approximate

- Full **per-entity update** (`FUN_0000e792` in its entirety), **post-tick hooks** (`FUN_00005df8`, `FUN_00006fb8`), and **array-specific semantics** beyond structure.
- **Input**: full game-state FSM (`DAT_0001d858`) and complete Mac keycode mapping vs all branches.
- **Rendering and camera**: placeholder world and chase camera, not a line-accurate port of original camera code.
- **Loader/runtime**: segment load and relocation are documented and partially correlated; **not** executed as in the original app — see `docs/LOADER_CHAIN.md`.

## 3) High-level architecture

### Godot structure (scenes and scripts)

- **Entry**: `project.godot` points at a main scene (typically `godot/scenes/main/Main.tscn`), which loads the mission scene.
- **Mission 01** wires: world placeholder, **PlayerAircraft**, checkpoints, **HUD_MVP**, **MissionController**. Details: `docs/MISSION_01_MVP.md`.
- **Scripts** live under `godot/hellcats/` by concern: `core/` (sim, RNG, math), `flight/` (input map, MVP flight model, aircraft state), `mission/`, `player/`, `ui/`, `world/`.

### Simulation vs rendering vs UI

| Layer | Role |
|--------|------|
| **Simulation seams** | `sim_core.gd` — tick order, bridges to mission gates, entity update scaffolding, trace hooks. Mission gameplay may also use `FlightModelMvp` directly for the live loop. |
| **Flight / input** | `player_input_map.gd`, `flight_model_mvp.gd`, `flight_math.gd`, `aircraft_state.gd` — player intent, integrator, reconstructed math helpers. |
| **Mission logic** | `mission_controller.gd` — JSON-driven objectives, phase/flag exposure for the sim bridge, HUD and failure/restart. |
| **Rendering** | Placeholder meshes, simple world builder, **authored** chase camera on the player — not yet tied to original camera function parity. |
| **UI** | `HUD_MVP` — mission text and telemetry; not a full cockpit asset pass. |

### Where the player lives

- **Gameplay**: `PlayerAircraft` + `FlightModelMvp` drive the flyable aircraft for Mission 01.
- **Evidence chain**: Original **player entity pointer** `DAT_0001b738` corresponds conceptually to “the player plane”; Godot uses a single player node and gradually aligns `SimCore` designation for parity tests.

### Where the mission logic lives

- **MissionController** loads data under `godot/data/mission_01/`, tracks objectives and checkpoints, sets **mission phase** and **mission flag** fields that mirror the original mission block gates (`DAT_0001b5a0` offsets `+0xa8`, `+0xac`) for the deterministic core and docs.

### Where the simulation loop lives

- **Playable loop**: `_physics_process` / per-frame update on player and mission nodes (see `MISSION_01_MVP.md`).
- **Deterministic tick mirror**: `SimCore.tick()` implements the **four-pass** order and instrumentation described in `docs/contracts/tick_FUN_000044e8_contract.md`. Tests assert ordering, RNG draw counts, and `param_2` usage; full behavioral parity is ongoing.

## 4) Reverse engineering approach

### Decompiled code usage

- **Primary behavioral reference**: `Pacific Conflict.c` (Ghidra export) — most game-identifiable `FUN_*` logic for parity work.
- **Segments**: `ID01.c`–`ID09.c` — runtime, RNG, loader-related code; see `docs/LOADER_CHAIN.md`.
- We treat the C as **evidence**, not as something to paste wholesale: we extract **invariants** (order, gates, offsets, formulas) and reimplement them in GDScript with tests.

### Evidence-based extraction

- Claims are tagged in docs and changelogs:
  - **[RECONSTRUCTED]** — directly supported by decompiler output or binary-adjacent proof.
  - **[INFERRED]** — consistent interpretation; may need future verification.
  - **[UNKNOWN]** — not yet proven; do not silently “fill in” in code.
  - **[DEFERRED]** — intentionally later (e.g. full loader emulation).

### Implementation tags (code and design)

- **[MVP APPROXIMATION]** — stands in for a full port (e.g. simplified gates, scaled command targets).
- **[MVP TUNING]** — feel knobs for the slice, not claimed as original constants.
- **[MVP AUTHORING DECISION]** — chosen for scope (mission layout, HUD layout).

This keeps the difference **honest** between “we know this from the binary” and “we chose this to ship the slice.”

## 5) Convergence method

### What a convergence pass is

A **focused iteration** on **one subsystem** (e.g. input edges, movement smoothing, tick instrumentation): extract contract → implement behind stable APIs → add traces/tests → keep Mission 01 playable.

### How we iterate

A typical loop (see `docs/CONVERGENCE_LOOP_TEMPLATE.md`):

1. **RE** — Document behavior and gates in a contract or `NOTES.md` (with tags).
2. **Godot** — Small, reviewable diff in the relevant module (`PlayerInputMap`, `FlightModelMvp`, `SimCore`, etc.).
3. **Gameplay** — Confirm Mission 01 still runs: complete, fail, restart.
4. **QA** — Headless `godot/tests/run_all.gd`, targeted unit/integration tests, optional `tools/qa/test_regression.py`.
5. **Docs** — Update contracts or backlog (`docs/CONVERGENCE_BACKLOG.md`) so the next contributor knows status.

### Why we do not rewrite everything at once

- Parity is **incremental**: order and gates first, then input semantics, then larger entity update chunks.
- A **stable MVP** is the safety net: we can validate each step against gameplay and automated checks.
- **Trace-diff** (`docs/TRACE.md`) is the long-term arbiter for determinism; until entity logic is complete, traces mainly cover phase/flag/input/RNG and selected fields — see `docs/ROADMAP.md` phases.

## 6) Key systems already studied

High-level only; details live in `docs/contracts/` and `docs/SUBSYSTEM_MAP.md`.

| System | Original anchor | Role |
|--------|-----------------|------|
| **Input** | `FUN_0000740a` | Key/action handler: maps input to game and player state, throttle steps, mission-related branches. Godot: `player_input_map.gd` with press/hold/release and throttle impulses; full `DAT_0001d858` FSM not ported. |
| **Flight model** | `FUN_0000e792` | Large per-entity update: movement, flags, RNG-touched behavior, **movement-smoothing accumulators** for designated entities. Godot: partial slices in `SimCore` / `FlightMath`; MVP feel via `FlightModelMvp` and reconstructed smoothing rules. |
| **Entity update loop** | `FUN_000044e8` / `FUN_000044a4` | Main tick: mission gates, four array passes, per-entity dispatch with `param_2`, post-pass call. Godot: `SimCore` mirrors pass order and records `last_tick_order`. |
| **Mission state bridge** | `DAT_0001b5a0` fields | Phase (`+0xa8`) and flag (`+0xac`) gate whether the mid-tick entity updates run. Godot: `MissionController` exposes `mission_phase_a8`, `mission_flag_ac`, and `get_mission_sim_bridge_state()`. |

## 7) Data and decompiled code

### ID01–ID09

- **CODE segments** as exported C: RNG helpers, loader-adjacent routines, low-level pieces used before or alongside the main overlay.
- **ID00** (binary) relates to **LoadSeg** dispatch; correlation to routine entry points is documented in `docs/LOADER_CHAIN.md`.
- Not assumed to contain all gameplay identifiers — many named game functions live in **Pacific Conflict.c**.

### Pacific Conflict.c

- Main **overlay**-style source for **tick, input, entity update, mission references**, and much of what we port or test against.

### Code vs data

- **Code** — Control flow, formulas, gates (what we reimplement).
- **Data** — Mission JSON, aircraft tuning JSON, loader metadata JSON — **authored or extracted** for the Godot slice; original data layout is only partially reconstructed (`STRUCTS.md`).

### What is still unknown

- Full **runtime relocation** and **segment execution** as on a real Mac.
- Complete **mission block** and **game-state machine** semantics.
- **Binary trace capture** from the original for automated cross-check (roadmap item).
- Many **secondary systems** (full combat, damage model, map mode, etc.) — not required for the current MVP milestone.

## 8) Current limitations

- **Approximated**: MVP flight tuning, simplified mission/game-state gating, placeholder art and physics.
- **Missing**: Full `FUN_0000e792`, `FUN_0000435a` branch depth, `FUN_00005df8` / `FUN_00006fb8`, camera parity, ground/collision fidelity.
- **Intentionally simplified**: One training mission, HUD-first UX, no full campaign or multiplayer.

## 9) Next steps

- **Refinement**: Movement-smoothing ownership wiring, deeper `param_2` behavior, more `SimCore` ↔ player alignment — see `docs/ROADMAP.md` and `docs/CONVERGENCE_BACKLOG.md`.
- **Simulation**: Expand entity update porting in slices; grow trace coverage as fields stabilize.
- **HUD / telemetry**: Map display fields to proven entity offsets where possible (`IMPORT_STATUS.md` §HUD).
- **Map / rendering**: Deferred until core sim and mission loop mature; placeholder world remains.

## 10) How to work on the project

### Approaching a new system

1. Find or write a **short contract** (`docs/contracts/`) or subsection in `NOTES.md` with **[RECONSTRUCTED]** vs **[INFERRED]**.
2. Locate the **Godot seam** (`SUBSYSTEM_MAP.md`, `IMPORT_STATUS.md`).
3. Implement **one vertical slice** of behavior with tests; avoid unrelated refactors.

### Running a convergence pass

- Use `docs/CONVERGENCE_LOOP_TEMPLATE.md`: define outputs (contract, code, traces, tests, playability).
- Run headless tests from repo root (see root `README.md` for Godot and Python commands).
- Update `CONVERGENCE_BACKLOG.md` or `NOTES.md` when an item advances.

### Avoiding MVP breakage

- Keep **Mission 01** runnable: start, fly, pass/fail objectives, restart.
- Prefer **feature flags** or isolated modules over large rewrites.
- Add or extend **tests** when changing ordering, RNG, or input semantics.

## Related documents

| Document | Use |
|----------|-----|
| `README.md` | Run instructions, repo tree, quick status |
| `docs/SUBSYSTEM_MAP.md` | One-page decompilation ↔ Godot map |
| `docs/ROADMAP.md` | Phases A–C and acceptance ideas |
| `docs/IMPORT_STATUS.md` | Per-symbol port status |
| `docs/LOADER_CHAIN.md` | ID segments and loading |
| `docs/TRACE.md` | Trace/replay format |
| `docs/MISSION_01_MVP.md` | Mission 01 scene and script layout |

*This file is a map, not the territory. When in doubt, trust the contracts and evidence tags over this summary.*
