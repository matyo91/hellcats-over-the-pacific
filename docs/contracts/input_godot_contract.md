# Godot input layer — implementation contract (FUN_0000740a convergence)

Tags: **[RECONSTRUCTED]** from `Pacific Conflict.c` / `docs/briefs/input_FUN_0000740a_brief.md`; **[INFERRED]**; **[MVP APPROXIMATION]** for what is not ported yet.

## Purpose

Define the **stable interface** between reverse-engineered input semantics and the Godot MVP so `PlayerAircraft` + `FlightModelMvp` stay testable while fidelity increases.

## Contract

### Inputs (engine → gather)

**[RECONSTRUCTED]** The original consumes **(key code `param_1`, action `param_2`)** per event; dominant gameplay path uses **`param_2 == 3`** as the primary **down/edge** class.

**[INFERRED]** In Godot we map that to:

- **`Input.is_action_just_pressed` / `just_released` / `pressed`** on named actions (see `PlayerInputMap.ACTIONS`).
- **Normalized axes** via `Input.get_axis(negative_action, positive_action)` in `[-1, 1]` for pitch, roll, yaw, throttle **hold** inputs.

### Outputs (gather → flight model)

Each physics tick, **`PlayerInputMap.read_input_packet(player_active)`** returns:

| Field | Type | Meaning |
|-------|------|---------|
| `controls.pitch` | float | Pitch intent `[-1, 1]`. |
| `controls.roll` | float | Roll intent `[-1, 1]`. |
| `controls.yaw` | float | Yaw intent `[-1, 1]`. |
| `controls.throttle` | float | Throttle **hold** intent `[-1, 1]` (continuous change rate via `flight_model_mvp`). |
| `controls.throttle_impulse` | float | **Discrete step** toward open/closed throttle (**[RECONSTRUCTED]** aligns with `+`/`-` / `DAT_00024cf6` step behavior; not a full port). |

**[MVP APPROXIMATION]** `THROTTLE_STEP_IMPULSE` is a tuned fraction of `0..1`, not the original char accumulator + `FUN_00002e08` path.

### Gating

**[RECONSTRUCTED]** Original input is skipped or branch-suppressed when **game state / mission / entity** gates apply (`DAT_0001d858`, overlay flags, etc.).

**[MVP APPROXIMATION]** Single gate: **`player_active`** on `PlayerAircraft`. When false (mission terminal, crash), controls are zero; **pressed** actions in that frame are listed under `trace.ignored`.

### Trace (instrumentation)

**[INFERRED]** Each tick exposes **`PlayerInputMap.last_input_trace`** (and `trace` inside `read_input_packet` returns):

- `pressed`, `held`, `released` — action names
- `normalized` — copy of control outputs
- `gated`, `gate_reason`, `ignored`
- `tick` — 1-based counter (set on `PlayerAircraft` after gather; **[INFERRED]** aligns with per-physics-tick logging)

## File ownership

| Script | Role |
|--------|------|
| `hellcats/flight/player_input_map.gd` | Actions, gather, `compute_outputs` (pure), trace |
| `hellcats/flight/flight_model_mvp.gd` | Consumes `controls`; applies `throttle_impulse` |
| `hellcats/player/player_aircraft.gd` | Calls `read_input_packet(active)` once per frame |

## Related docs

- `docs/briefs/input_FUN_0000740a_brief.md` — RE extraction
- `docs/NOTES.md` — changelog entries
