# Convergence backlog (Mission-1 MVP, prioritized)

Tags: **[RECONSTRUCTED]** / **[INFERRED]** / **[UNKNOWN]**. Order = recommended convergence sequence.

| # | System / symbol | Why it matters | Difficulty | Depends on | Status |
|---|-----------------|----------------|------------|--------------|--------|
| 1 | Mission state `DAT_0001b5a0` +0xa8 / +0xac / +0xb0 | Gates **FUN_000044e8** and **FUN_000044a4** tail; links mission flow to sim tick | Medium | Loader/mission JSON | **Done** (MVP: `MissionController.mission_phase_a8` / `mission_flag_ac`; `get_mission_sim_bridge_state()`) |
| 2 | RNG consumption timing (`FUN_00011564` / LCG order) | Deterministic replay parity; ordering tests | Medium | SimCore tick order | **Done** (`SimCore` `_rng_consume`, `rng_draws_this_tick` in `last_tick_order`) |
| 3 | **FUN_0000435a** `param_2` branches | Different update path for arrays 1–2 vs 3–4 | High | FUN_000044a4, entity type | **Partial** (`docs/contracts/FUN_0000435a_contract.md`, `param_2_entity_updates` counts; logic not split) |
| 4 | **FUN_00005df8** / **FUN_00006fb8** | Pre/post tick hooks around entity passes | Medium | Mission flag +0xac | Not started |
| 5 | Player **DAT_0001b738** ↔ Godot **PlayerAircraft** | Single source of “player” for smoothing/input | Low | SimCore designated entity | Partial |
| 6 | HUD telemetry vs entity fields (ID03 / cockpit) | Visible fidelity | Medium | AircraftState snapshot | Not started |
| 7 | Camera / projection (**FUN_0000739a** path) | Training visibility | Medium | Player transform | Not started |
| 8 | Minimal ground / altitude contact | Impact / failure | High | Collision mesh | Not started |

**[INFERRED]** Items 1–3 unblock trace-diff and sim parity without campaign/combat.
