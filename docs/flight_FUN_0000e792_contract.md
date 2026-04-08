# FUN_0000e792 — flight motion implementation contract (MVP convergence)

Tags: **[RECONSTRUCTED]** / **[INFERRED]** / **[MVP APPROXIMATION]** / **[MVP TUNING]**

**Source:** `Pacific Conflict.c` `FUN_0000e792` (≈14018–14247+), `docs/NOTES.md` ownership branch.

---

## Purpose

Bind the Godot **Mission-1** flight path to **evidence-backed** motion rules from **`FUN_0000e792`** without porting the full entity/sim stack. The MVP **player** is always the **designated player** (mirrors `param_1 == DAT_0001b738` for this slice).

---

## Update order (this pass)

**[RECONSTRUCTED]** In the original, the **0x66e / 0x672 / 0x66a** block runs **after** control/status setup and **FUN_0000e42a** / **FUN_0000e468** / **FUN_0000e570** prep (`local_26`, `local_46`, `local_42`), and **only** for **player** or **designated target** (`DAT_0001b738` / `DAT_0001b888`).

**[MVP APPROXIMATION]** In Godot MVP we apply **only** the **smoothed delta accumulation rule** toward **command scalars** derived from **normalized** pitch/roll/yaw inputs (not full `local_46` / `local_42` from airspeed/template math).

**Order in `flight_model_mvp.step`:**

1. Throttle integration (FUN_0000740a path; unchanged contract from input pass).
2. **Targets** from controls: `pitch_cmd`, `roll_cmd`, `yaw_cmd` in `[-1, 1]`.
3. **Integer targets** scaled by **[MVP TUNING]** `pitch_max_int`, `roll_max_int`, `yaw_max_int` (default `8192`).
4. **Accumulators** (entity offsets, Godot names):
   - **`movement_66e`** — `FlightMath.add_delta_smoothed_int` toward pitch target (**[RECONSTRUCTED]** Pacific Conflict.c:14182–14197).
   - **`movement_672`** — `FlightMath.add_delta_smoothed_s16` toward roll target (**[RECONSTRUCTED]** 14207–14224).
   - **`movement_66a`** — `FlightMath.add_delta_smoothed_int` toward yaw target (**[RECONSTRUCTED]** 14230–14242).
5. **Attitude / heading integration** from **accumulator ratios** × **control_rates** × `delta`.
6. Speed, VS, position (existing MVP physics; **[MVP TUNING]** on gains).

**[UNKNOWN]** Semantic mapping of **which** axis is **pitch vs roll vs yaw** in **0x66e/0x672/0x66a**; we follow **NOTES.md** ordering and **integration** convention: **66e→pitch**, **672→roll**, **66a→yaw** (**[INFERRED]**).

---

## Skipped in this pass (explicit)

- **0x669 clear** when `(status_1a1 & 0x40) && movement_66e == 0` (**[RECONSTRUCTED]** 14244–14246) — no `status_1a1` in MVP **AircraftState**.
- **flags_685** RNG perturbation on **0x662 / 0x666** (**[RECONSTRUCTED]** 14105–14137).
- **Full** `local_46` / `local_42` from **FUN_0000e42a** chain and **template** fields.
- **Combat**, mission scripting, map/replay.

---

## Constants

**[RECONSTRUCTED]** Delta rule: if `|delta| < 8` add full `delta`; else add `(delta + (7 if delta < 0 else 0)) >> 3` — implemented as `FlightMath.add_delta_smoothed_int` / `add_delta_smoothed_s16`.

**[MVP TUNING]** `pitch_max_int` / `roll_max_int` / `yaw_max_int` — scale **float** commands to **int** targets (default **8192**).

---

## Related files

- `hellcats/core/flight_math.gd` — smoothing helpers
- `hellcats/flight/flight_model_mvp.gd` — integrator
- `hellcats/flight/aircraft_state.gd` — `movement_66e`, `movement_672`, `movement_66a`
