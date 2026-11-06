# Import status (decompiled C ↔ Godot)

> **Historical.** This page maps symbols to the removed MVP prototype. Every function is now
> strict-ported (`godot/strict_port/mappings/functions.json`, `tools/progress_stats.py`) and runs
> as the original game ([GAME_RUNTIME.md](../architecture/GAME_RUNTIME.md)); the analysis notes below remain.

Tags: **[RECONSTRUCTED]** / **[INFERRED]** / **[UNKNOWN]** / **[DEFERRED]**.

**Purpose:** Technical cross-reference showing which **Pacific Conflict.c** (and segment) symbols are reflected in the prototype. Current strict-port status comes only from `godot/strict_port/mappings/functions.json` and `tools/progress_stats.py`.

**Corpus:** `Hellcats-Over-the-Pacific_Mac_EN/ResEdit/CODE/` — **Pacific Conflict.c** (main game), **ID01.c–ID09.c** (segment/runtime splits). See `docs/architecture/LOADER_CHAIN.md` for how ID segments relate to the overlay.

**Related:** `docs/architecture/SUBSYSTEM_MAP.md`, `docs/port/STRICT_PORT_FOUNDATION.md`.

## Resource corpus

The Macintosh resource side is inventoried separately in
[`RESOURCE_ANALYSIS.md`](../reference/RESOURCE_ANALYSIS.md). Run `python3 tools/resedit.py inventory`
for current corpus counts. Generated CODE-reference annotations remain distinct
from runtime-verified behavior. This does not mean the resources are imported
into Godot: PICT opcode rendering, resource-backed UI construction, sound
playback, and most proprietary data consumers remain unported.

## Legend

| Status | Meaning |
|--------|---------|
| **Done** | Behavior or ordering represented in Godot/tests; contract may still note approximations. |
| **Partial** | Some paths, data, or branches ported; parity incomplete. |
| **Doc only** | Documented in `docs/history/contracts/*_contract.md` or `STRUCTS.md`; not executed in Godot (or only as comments). |
| **Not started** | No meaningful port; **[UNKNOWN]** may still apply to the original. |
| **DEFERRED** | Intentionally out of scope for current milestones (often runtime/helpers). |

## A) Sim tick and entity dispatch

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_000044e8** | `Pacific Conflict.c` (~5096–5145); `docs/history/contracts/tick_FUN_000044e8_contract.md` | `godot/hellcats/core/sim_core.gd`; `godot/tests/integration/test_sim_tick_ordering.gd` | **Done** | **[INFERRED]** Mission-1 playable loop uses `PlayerAircraft` + `FlightModelMvp`; SimCore is parity / future wiring. |
| **FUN_000044a4** | Same; dispatches to **FUN_0000435a** | `SimCore._update_single_entity` | **Partial** | **param_2** surfaced; full tail parity **[UNKNOWN]**. |
| **FUN_0000435a** | `Pacific Conflict.c` (~5008–5075); `docs/history/contracts/FUN_0000435a_contract.md` | `SimCore` (counts / `param_2`); branch logic not fully split | **Partial** | Critical for array 1–2 vs 3–4 fidelity. |
| **FUN_00005df8** | Called when `DAT_0001b5a0 + 0xac == 0`; clears 7× `DAT_0001bc64` after `FUN_0000528a` (Pacific Conflict.c:6434–6447) | `SimCore._call_05df8` + `dat_0001bc64`; tick-order counters; test in `test_sim_tick_ordering.gd` | **Done** (loop/clear) | **`FUN_0000528a` body deferred** (call counted only). |
| **FUN_0000528a** | Cleanup invoked by **FUN_00005df8** (Pacific Conflict.c:5784–5798) | `SimCore._call_0528a` + entity offsets `flags_07` / `field_24` / `field_3c` | **Done** (control flow) | Calls **FUN_000051ec** or type-0x02 alt (`field_04\|0x42`, `field_3c=DAT_0001b838`). |
| **FUN_000051ec** | Called from **FUN_0000528a** (Pacific Conflict.c:5751–5779) | `SimCore._call_051ec` + `mem_u32` | **Done** (proven stores) | Entity writes, table poke via `mem_u32[*(DAT_0001d6fc+0x30)+0x14+field_02*0x18]`, and `mem_u32[entity+8]=0`. Full Mac heap identity **[INFERRED]** via flat `mem_u32`. |
| **FUN_00006fb8** | After four entity passes; body sets six globals to `100000000` (Pacific Conflict.c:7180–7189) | `SimCore._call_06fb8` + `last_tick_order.fun_00006fb8_*`; `test_sim_tick_ordering.gd` | **Done** (side effect) | Semantic role of the six DATs **[INFERRED]** / partially **[UNKNOWN]**. |
| Entity arrays **DAT_0001d4a4**, **DAT_0001b5a4**, **DAT_0001d0e4**, **DAT_0001cbe4** + counts | `STRUCTS.md`, tick contract | `SimCore` pass lists | **Done** (structural) | **[INFERRED]** Roles of arrays 1,3,4 beyond counts **[UNKNOWN]**. |

## B) Flight model and entity update (FUN_0000e792)

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_0000e792** | `Pacific Conflict.c` (~14016+); `docs/history/contracts/flight_FUN_0000e792_contract.md` | `FlightModelMvp` + `AircraftState`; `SimCore` slices incl. contact early-out | **Partial** | Contact `61a`/`61e`; LAB_f47c `01d56≡01d76`; spawn + tick-`044a4`+vtable `+8`; `01a68`+large coalesce; `016e2` through `bc28`; `04e6e` kind2 paths incl. `15762` through bias_1a + `04958` clip+`01ba8` grow; `local_f54`/`1562e`/`03ea0` body open; `01be4` ABI deferred; `01b6c` still open. |
| **FUN_0000e42a**, **FUN_0000e468**, **FUN_0000e570** | Inside / near **FUN_0000e792** block (~13796–13915) | `godot/hellcats/core/flight_math.gd` | **Done** (helpers) | Used by convergence; not always wired in live tick. |
| **FUN_00011564** | Overlay table RNG (Pacific Conflict.c:16407–16433) | `rng_overlay_11564.gd`; `SimCore.rng` / `_rng_consume` | **Done** | Paired with **FUN_0001150a** / **FUN_000114ca** init. ID05 on `rng_id05`. |
| **FUN_0001150a** / **FUN_000114ca** | Init + mul helper (Pacific Conflict.c:16355–16385) | `init_1150a` / `fun_000114ca` / `set_seed` | **Done** | `table[0]` prior value **[UNKNOWN]** (=0). |
| **DAT_0001b738** (player entity ptr) | `STRUCTS.md`, input + **FUN_0000e792** | `PlayerAircraft` / mission flow | **Partial** | Single “player” in Godot; SimCore designation **[INFERRED]** partial. |
| **DAT_0001b888** (second designated entity) | Ownership branch ~14179 | Not modeled end-to-end | **Doc only** | **[UNKNOWN]** full semantics. |

## C) Input (FUN_0000740a)

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_0000740a** | `Pacific Conflict.c` (~7366+); `docs/history/briefs/input_FUN_0000740a_brief.md`, `STRUCTS.md` | `godot/hellcats/flight/player_input_map.gd`; `docs/history/contracts/input_godot_contract.md` | **Partial** | Throttle steps → `throttle_impulse`; full **DAT_0001d858** FSM not ported. |
| **DAT_00024cf6** (throttle step accumulator path) | C input handler | Approximated as impulse | **Partial** | **[MVP APPROXIMATION]** per `docs/history/contracts/input_godot_contract.md`. |
| **DAT_0001d858** (game state) | Values 1, 7, 8, 9 | `player_active` gate only | **Doc only** / **Partial** | Menu/pause parity **[DEFERRED]**. |

## D) Mission globals and bridge

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **DAT_0001b5a0** + **0xa8** / **0xac** | `docs/history/contracts/mission_state_DAT_contract.md`, `STRUCTS.md` | `MissionController.mission_phase_a8`, `mission_flag_ac`; `get_mission_sim_bridge_state` | **Done** (MVP bridge) | Matches gates for tick narrative. |
| Full **DAT_0001b5a0** layout | C | Partial in `STRUCTS.md` | **Doc only** | **[UNKNOWN]** many fields. |

## E) Camera

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_0000739a** | Called around tick / render path (`Pacific Conflict.c` ~7350, ~4442, etc.) | Godot `PlayerAircraft` chase camera (authored) | **Not started** (RE parity) | **[INFERRED]** MVP uses Godot camera, not a line-accurate port. |

## F) RNG (Macintosh LCG vs in-game)

| Symbol / cluster | Source (evidence) | Godot / tests | Status | MVP notes |
|------------------|-------------------|---------------|--------|-----------|
| **FUN_00000728** (LCG `* 0x41c64e6d + 0x3039`) | **ID05.c** (~130–135) | `Rng68k` / SimCore seeding pattern | **Done** (algorithm) | Segment-local; parity uses same constants **[RECONSTRUCTED]**. |
| **FUN_00011564** | **Pacific Conflict.c** | See §B; `rng_overlay_11564.gd` | **Partial** | Fixture exists; not yet the SimCore consumer. |

## G) Loader / segments (ID01–ID09)

| File | Role **[INFERRED]** | Import status | MVP notes |
|------|----------------------|---------------|-----------|
| **ID01.c** | Integer/math runtime fragments | **DEFERRED** | Use Godot math, not a C port. |
| **ID02.c** | Large segment helpers (`unaff_A5` patterns) | **DEFERRED** | Not game rules. |
| **ID03.c–ID04.c**, **ID06.c–ID07.c**, **ID09.c** | Mixed helpers; some bad decomp regions | **DEFERRED** / **[UNKNOWN]** | Port only if proven game-critical and missing from **Pacific Conflict.c**. |
| **ID05.c** | LCG + helpers | **Partial** (RNG constant match) | See §F. |
| **ID08.c** | LoadSeg / resource traps; see `LOADER_CHAIN.md` | **Doc only** | Full loader parity **[DEFERRED]**. |

Resource provenance caveat: the protected ResEdit `CODE:2` payload is 19,994
bytes, while the independently recovered 1.0.4 fork has a 24,832-byte segment.
Both hashes are retained in `sources/resedit-1-0-3/CODE/ID02.json`; the protected input
was not replaced.

## H) HUD / cockpit numeric fields

| Topic | Godot / docs | Status | MVP notes |
|-------|----------------|--------|-----------|
| Cockpit ↔ **FUN_0000e792** entity fields | `AircraftState` snapshot; training HUD | **Partial** | Field-accurate HUD vs original remains **[INFERRED]** and open for parity. |
