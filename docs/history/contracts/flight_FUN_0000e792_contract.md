# FUN_0000e792 — flight motion implementation contract (MVP convergence)

Tags: **[RECONSTRUCTED]** / **[INFERRED]** / **[MVP APPROXIMATION]** / **[MVP TUNING]**

**Source:** `Pacific Conflict.c` `FUN_0000e792` (≈14018–14247+) and the
source-local annotation in `Pacific Conflict.decomp.c`.

## Purpose

Bind the Godot **Mission-1** flight path to **evidence-backed** motion rules from **`FUN_0000e792`** without porting the full entity/sim stack. The MVP **player** is always the **designated player** (mirrors `param_1 == DAT_0001b738` for this slice).

## Update order (this pass)

**[RECONSTRUCTED]** Randomized controls (`Pacific Conflict.c:14105–14138`): for flags `0x04` / `0x08`, draw from `FUN_00011564` in that order, add `(draw & 0x7f) - 0x40` to `0x662` / `0x666`, narrow the sum to signed 16 bits (`short sVar21`), then clamp to ±`0x200` / ±`0x140`. `FUN_00002e08` (3461–3468) is integer absolute value. The status-bit override follows both draws. `SimCore` now preserves narrowing before clamping; deterministic overflow and ordinary-value fixtures in `test_sim_tick_ordering.gd` distinguish this from wide-integer clamping. This slice does not alter playable `FlightModelMvp`.

**[RECONSTRUCTED]** Contact early-out (Pacific Conflict.c:14083–14104; Capstone `@0xE85A–0xE89C`): if `(status_1a1 & 8) != 0`, update `position_velocity_c` from `pos_2e` vs `*(iVar1+0x1c)`, optional `status\|0x1000` / `DAT_0001b850`, then two 11544-callsite draws: `61e+=rng&0x7f` → `field_24=(field_24+61e)&0x3fff`; `61a-=rng&0x7f` → `pos_20=(pos_20+61a)&0x3fff`; clear `0x669`; early exit. Godot: `apply_contact_61a_61e_attitude`. **[INFERRED]** Call-site `FUN_00011544` ≡ one `FUN_00011564`.

**[RECONSTRUCTED]** In the original, the **0x66e / 0x672 / 0x66a** block runs **after** control/status setup and **FUN_0000e42a** / **FUN_0000e468** / **FUN_0000e570** prep (`local_26`, `local_46`, `local_42`), and **only** for **player** or **designated target** (`DAT_0001b738` / `DAT_0001b888`).

**[RECONSTRUCTED]** `local_46 = (int)(short)(0x5e50 / (short)((sVar15 + 0xa25) >> 5)) * sVar21 * 0x666 >> 5` (Pacific Conflict.c:14183). The `0x666` factor is a **literal constant**, not entity field `movement_666`. Godot: `FlightMath.compute_local_46` / `SimCore._apply_movement_smoothing`.

**[RECONSTRUCTED]** Prep trio (asm `0xE9BE`–`0xE9EA`): `e42a(*(world+0x1c))` → `sVar15`; `e468(world+0x1c − pos_2e, e42a)` → separate slot (`SimCore.last_e468_out`); `e570` / `local_46` keep **raw e42a**. Not entity `pos_1c`.

**[RECONSTRUCTED]** `movement_626` update (Pacific Conflict.c:14248–14304) after the designated-player `0x66e/672/66a` block — applies to **all** entities that reach it. Formula uses `movement_662`, `iVar20=movement_62a>>2`, template `+0x34/+0x36/+0x44`. **`e468` is not in this formula** (drag divisor later at ~14356 / asm `0xEDF8`). Godot: `FlightMath.apply_movement_626_step` / `SimCore._apply_movement_626_step`.

**[RECONSTRUCTED]** Reverse-flight when `field_63e!=0` and `direction_char_679=='-'` (14305–14342), **before** e4a4: `0x626` clamps; designated `local_48` from stashed `local_46`/`local_42`; `DAT_0001b858=0` for player; `attitude_22` (`local_2a`) += `local_48` masked. Godot: `compute_reverse_local_48` / `_apply_movement_626_reverse_clamp`.

**[RECONSTRUCTED]** `FUN_0000e4a4` + e468 drag + `0x636` + `0x63e`/`field_18e` + `local_34`/stall (14344–14433). Godot: `FlightMath.apply_ivar25_stall_step`, `SimCore._apply_e4a4_and_linear_drag` (`field_190`, `dat_0001b868`).

**[RECONSTRUCTED]** `FUN_000025a8` → matrix → `FUN_000028dc` + `field_18c`/`param_1[2..4] >> 6` (2942–2949, 3111–3139, 14438–14445). Godot: `fun_000025a8` / `fun_00001d02` / `apply_position_commit_after_028dc`. Trig: overlay dump at file `0x1ab8c`/`0x1ad8c` (`trig_tables_ab6c_ad6c.json`; Ghidra symbols are 0x20 early).

**[RECONSTRUCTED]** Airborne post-commit (14486–14495): `iVar20 = FUN_0000e372(e²+a²+6²)`; `FUN_00001f22`; clear `field_190` when `==2`. Grounded (14497–14603): `e372(e²+z²)`, `pvc←iVar23−surface`, optional `13452`, `field_0b` switch (`bVar6` / status / early return / clear `b856` / `0x10` soft `11564→uVar13` / `@` two 11544-callsite draws → `field_18c`/`uVar13` + optional `11564` `b854` / player `b854` when `b856≠0`), clamp `local_28`, prestall when `!bVar6`. LAB_0000f47c (14606–14629): clear `63f`, commit `pos_20`/`attitude_22`, yaw-blend `field_24`, write `movement_62a`, player `DAT_0001bc8c` ring. Char epilogue (14631–14647): `67b`/`679` increments + `field_67a|=2` + status `0x2000`/`~0x2000`. Weapons (14648–14719): `19d`/`19f` → `12840`→`05116`; `676`/`682` → `15d20`→`0262e`→`15bf6`→`028dc`→`05116`→`1a63e(+0x40)`; `677` → `19430`→`05116`→fields→0xd vertex `>>3`/`*0x1c6`/`*0x255` + player `b874`/`d858`/`b87c`. `flags_685&2` ammo tail (14721–14734) via 11544-callsite draws. `bVar6` cleanup (14736–14748): `status_1a2` clamp/clear, `status=(s&0x8000)|0x900`, `state_32=0xe772`, clear `61a`/`61e`. Skipped on `0x10` early return. Godot: `_call_fun_00012840` / `_call_fun_00015d20` / `_call_fun_00019430` / `_call_fun_00005116` / `_call_fun_000046da` / `apply_045ba_from_desc` / `apply_03b98_camera_abs_axes` + combine / `04e6e` list+`(36+3a)*0xC`→`+0x44/+0x4c` / `046da`/`04690` vtable `+8` + `04e6e`/`04808`→`01a68` (large adjacent coalesce on free) + `02bd8`/`02d10`(null-aux) + tick `044a4` + `03da8`+ROM `b190` / `01d56≡01d76` in LAB_f47c. **[DEFERRED]** `FUN_00000054`→live `1b524` factories; `01a48` on backward coalesce; `02d10` both-aux; full `1a63e`.

**[RECONSTRUCTED]** Touchdown when `field_63e==0` and altitude crosses surface (14446–14449): `field_63e←1`, `param_1[3]←iVar23−*(world+0x1c)`. Pitch follow-on (14450–14476): hard `attitude_0e*0x10 < -0x168` → `status|0x400` + early return; if `pos_2e==0` call `FUN_00013452(world)` → `FUN_00013346(*(w+0x18/1c/20))` and store low byte to `field_0b` (14456–14458). Else rough if pitch `< -0xd8` or `abs(e40c(uVar13))>0x200` or `e40c(local_28)<-0x100`; gentle player sets `DAT_0001b856=1`; non-hard clears `field_18e` and player `DAT_0001b868=1`. `FUN_0000e40c` folds to ±0x2000. Airborne clear (14479–14484). Godot: `fun_00013452` / `fun_00013346` (empty-list path). **[DEFERRED]** Non-empty `FUN_00013346` object scan.

**[MVP APPROXIMATION]** Mission-1 `FlightModelMvp` still applies the **smoothed delta accumulation rule** toward **command scalars** from normalized pitch/roll/yaw (not the full airspeed/`local_46` chain).

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

**[UNKNOWN]** Semantic mapping of **which** axis is **pitch vs roll vs yaw** in **0x66e/0x672/0x66a**; the integration convention is **66e→pitch**, **672→roll**, **66a→yaw** (**[INFERRED]**).

## Skipped in this pass (explicit)

- **0x669 clear** when `(status_1a1 & 0x40) && movement_66e == 0` (**[RECONSTRUCTED]** 14244–14246) — no `status_1a1` in MVP **AircraftState**.
- **flags_685** RNG perturbation on **0x662 / 0x666** (**[RECONSTRUCTED]** 14105–14137).
- **Full** `local_46` / `local_42` from **FUN_0000e42a** chain and **template** fields.
- **Combat**, mission scripting, map/replay.

## Constants

**[RECONSTRUCTED]** Delta rule: if `|delta| < 8` add full `delta`; else add `(delta + (7 if delta < 0 else 0)) >> 3` — implemented as `FlightMath.add_delta_smoothed_int` / `add_delta_smoothed_s16`.

**[MVP TUNING]** `pitch_max_int` / `roll_max_int` / `yaw_max_int` — scale **float** commands to **int** targets (default **8192**).

## Related files

- `godot/hellcats/core/flight_math.gd` — smoothing helpers
- `godot/hellcats/flight/flight_model_mvp.gd` — integrator
- `godot/hellcats/flight/aircraft_state.gd` — `movement_66e`, `movement_672`, `movement_66a`
