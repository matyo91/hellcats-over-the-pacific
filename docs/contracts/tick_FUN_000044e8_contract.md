# FUN_000044e8 / FUN_000044a4 — entity tick implementation contract

Tags: **[RECONSTRUCTED]** / **[INFERRED]** / **[MVP APPROXIMATION]**

**Sources:** `Pacific Conflict.c` `FUN_000044e8` (≈5096–5145), `FUN_000044a4` (≈5079–5092), `FUN_0000435a` (≈5008–5075).

---

## FUN_000044e8 — main sim tick structure

**[RECONSTRUCTED]** Order of operations:

1. If `*(short *)(DAT_0001b5a0 + 0xac) == 0` → call **`FUN_00005df8()`**.
2. If `0 < *(short *)(DAT_0001b5a0 + 0xa8) < 6` (mission phase gate):
   - Iterate **`DAT_0001d4a4`** (count **`DAT_0001c1e0`**): for each pointer, **`FUN_000044a4(entity, 0)`**.
   - Iterate **`DAT_0001b5a4`** (count **`DAT_0001b734`**): **`FUN_000044a4(entity, 0)`**.
   - Iterate **`DAT_0001d0e4`** (count **`DAT_0001c1dc`**): **`FUN_000044a4(entity, 1)`**.
   - Iterate **`DAT_0001cbe4`** (count **`DAT_0001c1d8`**): **`FUN_000044a4(entity, 1)`**.
   - Call **`FUN_00006fb8()`**.

**[RECONSTRUCTED]** Globals: **`DAT_0001b5a0 + 0xa8`** = mission phase; **`+ 0xac`** = mission flag (zero triggers **`FUN_00005df8`** before the phase gate).

**[INFERRED]** Player aircraft is commonly associated with **array 2** (`DAT_0001b5a4` / **`DAT_0001b738`**); full entity typing is **[UNKNOWN]** for every object.

---

## FUN_000044a4 — per-entity dispatch

**[RECONSTRUCTED]** **`FUN_000044a4(char *param_1, int param_2)`** calls **`FUN_0000435a(param_1, param_2)`**, then optional flag updates on **`param_1 + 4`** depending on **`param_1 + 8`** and mission **`DAT_0001b5a0 + 0xb0`**.

**[RECONSTRUCTED]** Inside **`FUN_0000435a`**, **`param_2`** is used in at least one branch: for entity type **`*param_1 == 0x02`**, a loop updates data only when **`param_2 == 0`** (Pacific Conflict.c:5048–5071). So **second argument distinguishes code paths** inside the update chain.

**[INFERRED]** Arrays **1–2** use **`param_2 == 0`**; arrays **3–4** use **`param_2 == 1`** — not “player vs non-player” by array index alone; it is **which dispatch path** **`FUN_0000435a`** applies.

---

## Godot `SimCore` mapping

| Original | Godot |
|----------|--------|
| Phase gate `0 < a8 < 6` | `mission_phase_a8 > 0 && mission_phase_a8 < 6` |
| Flag `ac == 0` → FUN_00005df8 | `_call_05df8()` |
| Array 1..4 iteration | `entity_array_1` … `entity_array_4` with same **param_2** (0,0,1,1) |
| FUN_00006fb8 | `_call_06fb8()` |
| FUN_000044a4 → entity update | `_update_single_entity` (placeholder / ported slices) |

**[MVP APPROXIMATION]** Mission-1 **playable** path uses **`PlayerAircraft` + `FlightModelMvp`** on **`_physics_process`**; **`SimCore`** is the **deterministic / parity** bridge and **does not** drive that scene’s frame loop unless explicitly wired later.

**[MVP TUNING]** Ordering traces and snapshots are for **validation** and **future** wiring; default **`tick_order_trace_enabled`** is **false** to avoid overhead in batch tests.

---

## Related

- `docs/NOTES.md` — FUN_000044e8 log
- `docs/STRUCTS.md` — array symbols
- `hellcats/core/sim_core.gd` — implementation
