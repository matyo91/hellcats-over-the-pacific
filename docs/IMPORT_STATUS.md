# Import status (decompiled C ↔ Godot)

Tags: **[RECONSTRUCTED]** / **[INFERRED]** / **[UNKNOWN]** / **[DEFERRED]**.

**Purpose:** Single place to see which **Pacific Conflict.c** (and segment) symbols are reflected in the repo, and how complete that reflection is. This is a **living** table—update it when contracts or code change.

**Corpus:** `Hellcats-Over-the-Pacific_Mac_EN/ResEdit/CODE/` — **Pacific Conflict.c** (main game), **ID01.c–ID09.c** (segment/runtime splits). See `docs/LOADER_CHAIN.md` for how ID segments relate to the overlay.

**Related:** `docs/SUBSYSTEM_MAP.md`, `docs/CONVERGENCE_BACKLOG.md`, `docs/ROADMAP.md`.

---

## Legend

| Status | Meaning |
|--------|---------|
| **Done** | Behavior or ordering represented in Godot/tests; contract may still note approximations. |
| **Partial** | Some paths, data, or branches ported; parity incomplete. |
| **Doc only** | Documented in `docs/*_contract.md` or `STRUCTS.md`; not executed in Godot (or only as comments). |
| **Not started** | No meaningful port; **[UNKNOWN]** may still apply to the original. |
| **DEFERRED** | Intentionally out of scope for current milestones (often runtime/helpers). |

---

## A) Sim tick and entity dispatch

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_000044e8** | `Pacific Conflict.c` (~5096–5145); `docs/tick_FUN_000044e8_contract.md` | `hellcats/core/sim_core.gd`; `godot/tests/integration/test_sim_tick_ordering.gd` | **Done** | **[INFERRED]** Mission-1 playable loop uses `PlayerAircraft` + `FlightModelMvp`; SimCore is parity / future wiring. |
| **FUN_000044a4** | Same; dispatches to **FUN_0000435a** | `SimCore._update_single_entity` | **Partial** | **param_2** surfaced; full tail parity **[UNKNOWN]**. |
| **FUN_0000435a** | `Pacific Conflict.c` (~5008–5075); `docs/FUN_0000435a_contract.md` | `SimCore` (counts / `param_2`); branch logic not fully split | **Partial** | Critical for array 1–2 vs 3–4 fidelity. |
| **FUN_00005df8** | Called when `DAT_0001b5a0 + 0xac == 0` | Placeholder / not implemented | **Not started** | **[UNKNOWN]** behavior. |
| **FUN_00006fb8** | After four entity passes | Placeholder / not implemented | **Not started** | **[UNKNOWN]** behavior. |
| Entity arrays **DAT_0001d4a4**, **DAT_0001b5a4**, **DAT_0001d0e4**, **DAT_0001cbe4** + counts | `STRUCTS.md`, tick contract | `SimCore` pass lists | **Done** (structural) | **[INFERRED]** Roles of arrays 1,3,4 beyond counts **[UNKNOWN]**. |

---

## B) Flight model and entity update (FUN_0000e792)

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_0000e792** | `Pacific Conflict.c` (~14016+); `docs/flight_FUN_0000e792_contract.md` | `FlightModelMvp` + `AircraftState`; `SimCore` minimal slices | **Partial** | Movement smoothing **0x66e/0x672/0x66a** partially; full function **[DEFERRED]** for parity. |
| **FUN_0000e42a**, **FUN_0000e468**, **FUN_0000e570** | Inside / near **FUN_0000e792** block (~13796–13915) | `hellcats/core/flight_math.gd` | **Done** (helpers) | Used by convergence; not always wired in live tick. |
| **FUN_00011564** | Many call sites; RNG draws | `SimCore` RNG consumption / `last_tick_order` | **Partial** | Ordering tests; not all consumers ported. |
| **DAT_0001b738** (player entity ptr) | `STRUCTS.md`, input + **FUN_0000e792** | `PlayerAircraft` / mission flow | **Partial** | Single “player” in Godot; SimCore designation **[INFERRED]** partial. |
| **DAT_0001b888** (second designated entity) | Ownership branch ~14179 | Not modeled end-to-end | **Doc only** | **[UNKNOWN]** full semantics. |

---

## C) Input (FUN_0000740a)

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_0000740a** | `Pacific Conflict.c` (~7366+); `docs/input_FUN_0000740a_brief.md`, `STRUCTS.md` | `hellcats/flight/player_input_map.gd`; `docs/input_godot_contract.md` | **Partial** | Throttle steps → `throttle_impulse`; full **DAT_0001d858** FSM not ported. |
| **DAT_00024cf6** (throttle step accumulator path) | C input handler | Approximated as impulse | **Partial** | **[MVP APPROXIMATION]** per `input_godot_contract.md`. |
| **DAT_0001d858** (game state) | Values 1, 7, 8, 9 | `player_active` gate only | **Doc only** / **Partial** | Menu/pause parity **[DEFERRED]**. |

---

## D) Mission globals and bridge

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **DAT_0001b5a0** + **0xa8** / **0xac** | `docs/mission_state_DAT_contract.md`, `STRUCTS.md` | `MissionController.mission_phase_a8`, `mission_flag_ac`; `get_mission_sim_bridge_state()` | **Done** (MVP bridge) | Matches gates for tick narrative. |
| Full **DAT_0001b5a0** layout | C | Partial in `STRUCTS.md` | **Doc only** | **[UNKNOWN]** many fields. |

---

## E) Camera

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_0000739a** | Called around tick / render path (`Pacific Conflict.c` ~7350, ~4442, etc.) | Godot `PlayerAircraft` chase camera (authored) | **Not started** (RE parity) | **[INFERRED]** MVP uses Godot camera, not a line-accurate port. |

---

## F) RNG (Macintosh LCG vs in-game)

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_00000728** (LCG `* 0x41c64e6d + 0x3039`) | **ID05.c** (~130–135); cited in `docs/ROADMAP.md` | `Rng68k` / SimCore seeding pattern | **Done** (algorithm) | Segment-local; parity uses same constants **[RECONSTRUCTED]**. |
| **FUN_00011564** | **Pacific Conflict.c** | See §B | **Partial** | Consumption order matters for replay. |

---

## G) Loader / segments (ID01–ID09)

| File | Role **[INFERRED]** | Import status | MVP notes |
|------|----------------------|---------------|-----------|
| **ID01.c** | Integer/math runtime fragments | **DEFERRED** | Use Godot math, not a C port. |
| **ID02.c** | Large segment helpers (`unaff_A5` patterns) | **DEFERRED** | Not game rules. |
| **ID03.c–ID04.c**, **ID06.c–ID07.c**, **ID09.c** | Mixed helpers; some bad decomp regions | **DEFERRED** / **[UNKNOWN]** | Port only if proven game-critical and missing from **Pacific Conflict.c**. |
| **ID05.c** | LCG + helpers | **Partial** (RNG constant match) | See §F. |
| **ID08.c** | LoadSeg / resource traps; see `LOADER_CHAIN.md` | **Doc only** | Full loader parity **[DEFERRED]**. |

---

## H) HUD / cockpit numeric fields

| Topic | Godot / docs | Status | MVP notes |
|-------|----------------|--------|-----------|
| Cockpit ↔ **FUN_0000e792** entity fields | `AircraftState` snapshot; training HUD | **Partial** | `CONVERGENCE_BACKLOG.md` #6: field-accurate HUD vs original **[INFERRED]** still open for parity. |

---

## Update log

| Date | Change |
|------|--------|
| 2026-04-08 | Initial **IMPORT_STATUS.md** from architecture audit. |

When you complete a row (e.g. **FUN_00006fb8**), update this file and add a line to `docs/NOTES.md`.
