# Offset tables (evidence-first)

Every row must cite **source file:line** or **binary offset**. All statements tagged: **[RECONSTRUCTED]** / **[INFERRED]** / **[UNKNOWN]**.

## Mission / sim globals (DAT_0001b5a0 block)

**[RECONSTRUCTED]** Base: `DAT_0001b5a0` (Pacific Conflict.c:60, 73, 889). Mission data block; used in FUN_000044e8 and FUN_0000740a.

| Offset (hex) | Size / type | Description | Source |
|--------------|-------------|-------------|--------|
| +0x98 | short | Condition used in input path | Pacific Conflict.c:7420 |
| +0xa8 | short | Mission phase (0 &lt; phase &lt; 6 → run four arrays) | Pacific Conflict.c:5104 |
| +0xac | short | Mission flag (0 → call FUN_00005df8) | Pacific Conflict.c:5101 |
| +0x25e | int | Non-zero check before callback | Pacific Conflict.c:7423 |
| +0x2b6 | ptr | Callback (0) | Pacific Conflict.c:7424 |
| +0x2be | ptr | Callback (0) | Pacific Conflict.c:7425 |

**[INFERRED]** Our SimCore `mission_phase_a8` = +0xa8, `mission_flag_ac` = +0xac. **[UNKNOWN]** Full layout of DAT_0001b5a0.

## FUN_000044e8 — array and count symbols

**[RECONSTRUCTED]** Update order and symbols from Pacific Conflict.c:5105-5138.

| Symbol | Role | Source |
|--------|------|--------|
| DAT_0001c1e0 | Count for array 1 | Pacific Conflict.c:5105, 5112 |
| DAT_0001d4a4 | Ptr to first entity ptr (array 1) | Pacific Conflict.c:5106-5107 |
| DAT_0001b734 | Count for array 2 | Pacific Conflict.c:5114, 5121 |
| DAT_0001b5a4 | Ptr to first entity ptr (array 2) | Pacific Conflict.c:5115-5116 |
| DAT_0001c1dc | Count for array 3 | Pacific Conflict.c:5122, 5129 |
| DAT_0001d0e4 | Ptr to first entity ptr (array 3) | Pacific Conflict.c:5123-5124 |
| DAT_0001c1d8 | Count for array 4 | Pacific Conflict.c:5131, 5138 |
| DAT_0001cbe4 | Ptr to first entity ptr (array 4) | Pacific Conflict.c:5132-5133 |

**[RECONSTRUCTED]** **`FUN_000044a4(..., param_2)`**: second argument **0** for arrays **1–2**, **1** for arrays **3–4** (Pacific Conflict.c:5109–5139). **`FUN_0000435a`** uses **`param_2`** in at least one branch (`*param_1 == 0x02` loop when **`param_2 == 0`**, Pacific Conflict.c:5048–5071).

**[UNKNOWN]** Runtime-memory to file-offset mapping for these symbols. Symbol suffixes must not be treated as file offsets.

### Godot `SimCore` mapping

**[RECONSTRUCTED]** `entity_array_1` … `entity_array_4`, **`pass_id`** 1–4, **`last_tick_order`** / **`get_last_tick_order()`** — see `docs/contracts/tick_FUN_000044e8_contract.md`.

## FUN_0000740a — input handler globals

**[RECONSTRUCTED]** Variables read/written in FUN_0000740a (Pacific Conflict.c:7366+).

| Symbol | Type / use | Source |
|--------|------------|--------|
| DAT_0001d858 | Game state (e.g. 1, 7, 8, 9) | Pacific Conflict.c:7391, 7396, 7448-7452 |
| DAT_0001b738 | Player entity pointer (int *) | Pacific Conflict.c:7392, 7393, 7446, 7473 |
| DAT_0001b870 | State flag (0, 1, 2, 3) | Pacific Conflict.c:7394, 7412-7418, 7428 |
| DAT_0001b87c | Condition | Pacific Conflict.c:7396, 7405 |
| DAT_0001b884 | Set to 0 | Pacific Conflict.c:7408 |
| DAT_0001b86e | Delay/counter (e.g. 0x1e) | Pacific Conflict.c:7412, 7429, 7438 |
| DAT_0001b86c | Condition | Pacific Conflict.c:7438, 7442 |
| DAT_0001b888 | Pointer (int *) | Pacific Conflict.c:7449, 14172 |
| DAT_00020b2a | Read in handler | Pacific Conflict.c:7445 |
| DAT_0001b5a0 | Mission base (see above) | Pacific Conflict.c:7446 |

**[UNKNOWN]** Exact semantics of each value (e.g. meaning of DAT_0001d858 values 1–9).

## Godot `PlayerInputMap` (FUN_0000740a convergence)

**[RECONSTRUCTED]** Throttle **step** actions correspond to **`+` / `=`** and **`-`** / keypad plus/minus (Pacific Conflict.c cases `0x2b`/`0x3d` and `0x2d`/`0x5f` for `DAT_00024cf6` when `DAT_0001d858 < 6`). Implemented as `throttle_step_up` / `throttle_step_down` → `throttle_impulse` in `hellcats/flight/player_input_map.gd`.

**[RECONSTRUCTED]** Per-tick **trace** lists `pressed` / `held` / `released` action names and `normalized` floats passed to `FlightModelMvp`.

**[MVP APPROXIMATION]** `THROTTLE_STEP_IMPULSE` (float in `0..1`) replaces the original signed char + shift/`FUN_00002e08` accumulator chain.

**[MVP APPROXIMATION]** **Gating** is only `player_active` on `PlayerAircraft`, not the full `DAT_0001d858` / `DAT_0001b870` / mission `+0x98` tree.

See `docs/contracts/input_godot_contract.md`.

## Godot `AircraftState` / `FlightModelMvp` (FUN_0000e792 convergence)

**[RECONSTRUCTED]** `movement_66e`, `movement_672`, `movement_66a` mirror proven **byte offsets** `0x66e`, `0x672`, `0x66a` on the player entity; updated each tick with **`FlightMath.add_delta_smoothed_*`** toward **int** targets from normalized controls (see `docs/contracts/flight_FUN_0000e792_contract.md`).

**[MVP APPROXIMATION]** Targets are not **local_46** / **local_42** from **FUN_0000e42a** / template math; they are **[MVP TUNING]** scaled commands.

**[INFERRED]** `snapshot()` includes these fields for HUD/objectives/traces.

## Entity (FUN_0000e792) — key offsets

**[RECONSTRUCTED]** `param_1` is `int *` (entity pointer). Byte offsets: `(int)param_1 + 0xNNN` or `param_1 + K` (K in ints → byte offset K*4). Only offsets explicitly read/written in FUN_0000e792 or its immediate callees are listed; size/role inferred from access.

| Offset (hex) | Access | Source (Pacific Conflict.c) |
|--------------|--------|-----------------------------|
| 0x00 | *(byte) type | [INFERRED] entity_data_ptr / type elsewhere |
| 0x04 | *(uint) | FUN_000045ba and others (not in 0e792 excerpt) |
| 0x08 | *(uint) ptr | param_1[2] → *param_1; entity_data_ptr |
| 0x0c | position/velocity | *param_1+0xc in 1351-1353 |
| 0x10 | ptr | 4541 |
| 0x14 | ptr | 1352, 2297-2300 |
| 0x18 | int | 3336, 3376, 3433; *DAT_0001b738+0x18 in 7435 |
| 0x1c | int | 3337, 3377, 3434; *DAT_0001b738+0x1c in 7435 |
| 0x20 | int | 3338, 3378, 3435; *DAT_0001b738+0x20 in 7436 |
| 0x22 | short | (int)param_1+0x22 in 7433 |
| 0x2e | int | 14076, 14080, 14089, 14169, 14281 |
| 0x32 | int | 14077, 7476 |
| 0x3a | short | 2293 |
| 0x48 | int | 4734 |
| 0x50 | short | 979, 980, 983 |
| 0x61a | short | 14094-14096 |
| 0x61e | short | 14091-14093 |
| 0x626 | short | 14300, 14307-14315 |
| 0x62a | int | 14064, 14065 |
| 0x63e | byte | 7439, 7449, 14301 |
| 0x662 | short | 14102-14114, 14123, 14256-14294 |
| 0x666 | short | 14115-14127, 14123, 14280-14330 |
| 0x669 | byte | 14097, 14155, 14156, 14200, 14238 |
| 0x66a | int | 14077, 14078, 14234-14236 |
| 0x66e | int | 14198, 14202, 14206 |
| 0x672 | short | 14214-14222 |
| 0x679 | char | 14066, 14067, 14138, 14202, 14301 |
| 0x67c | byte | 961 (DAT_0001b5a0+0xb9) |
| 0x67d | byte | 14078, 14103, 14157, 14238, 953 |
| 0x67e | byte | 14077, 14078, 14104, 14158, 954-955 |
| 0x685 | byte | 14100, 14115, 14137, 14201, 14203 |
| 0x19a | short/byte | 14124, 14150, 7474 |
| 0x664 | short (param_1+0x199 as int*) | 14271, 14293 |
| 0x1a0 | short | 14151, 14152, 14253 |
| 0x1a1 | byte/ushort | 14079, 14120, 14121, 14137, 14238 |
| 0x1a3 | short | 14137 |

**[RECONSTRUCTED]** Offsets **0x66e**, **0x672**, and **0x66a** are **written** only inside the ownership branch in the next section (Pacific Conflict.c:14179–14244). They are **read** elsewhere (e.g. 11730, 11753, 7936, 14427).

**[INFERRED]** Names in our EntityState (field_00, pos_2e, weapon_count_67d, etc.) match these offsets. **[UNKNOWN]** Full entity size and any padding; 0x1a3 is last offset we use in the trace.

## FUN_0000e792 — ownership branch (0x66e, 0x672, 0x66a writes)

**[RECONSTRUCTED]** The following writes occur **only when** `(param_1 == DAT_0001b738) || (param_1 == DAT_0001b888)` (Pacific Conflict.c:14179). **DAT_0001b738** = player entity pointer; **DAT_0001b888** = second entity pointer (e.g. target). See [NOTES.md](NOTES.md) “FUN_0000e792 — ownership branch” for setup/use sites. **[UNKNOWN]** Semantic meaning of the three accumulators (e.g. axis or control surface).

| Offset | Type | Condition for write | Delta rule | Source (Pacific Conflict.c) |
|--------|------|---------------------|------------|------------------------------|
| **0x66e** | int | Same branch guard above | delta = local_46 − current_0x66e; if \|delta\| &lt; 8 add delta, else add (delta with negative rounding) &gt;&gt; 3 | 14180–14194 |
| **0x672** | short | Same branch guard; source = 0 if (0x669==0 or (0x1a1&amp;0x4300)!=0), else (local_26&gt;&gt;9) with optional 0x685 adjustment | Same: add delta or delta&gt;&gt;3 | 14196–14222 |
| **0x66a** | int | Same branch guard | delta from local_42, local_46, current_0x66a; same add delta or delta&gt;&gt;3 | 14223–14241 |
| **0x669** | byte | Same branch **and** (param_1+0x1a1)&amp;0x40 **and** 0x66e==0 | Set to 0 | 14241–14243 |

**Proven inputs to the branch:** `iVar1 = *param_1`, `DAT_00026004 = param_1[1]`, `iVar20 = *(int*)(param_1+0x62a)>>2`, `sVar15` from FUN_0000e42a/FUN_0000e468, `local_26` from FUN_0000e570, `sVar21` from earlier 0x669/0x1a1/0x685/0x19a logic (Pacific Conflict.c:14166–14177). **[RECONSTRUCTED]** Safe for port: branch condition and delta rules. **[UNKNOWN]** Unresolved: semantic names for 0x66e/0x672/0x66a; full meaning of DAT_0001b888 (Godot may treat as “second designated entity” only).

## Ownership branch status (DAT_0001b738 / DAT_0001b888)

- **[RECONSTRUCTED]** **DAT_0001b738** = player entity pointer; assigned when the first qualifying entity is created (e.g. FUN_0000dff0 at 13616–13617); read/written as the single “player” plane. [Pacific Conflict.c:13616–13617, 7392, 7446, 14179]
- **[RECONSTRUCTED]** **DAT_0001b888** = second entity pointer; cleared at 6101; set from `*(param_2+8)` in FUN_0000ff44 when DAT_0001d858 is 1, 8, or 7 and other conditions. [Pacific Conflict.c:6101, 7450, 7485–7486, 15117–15122]
- **[RECONSTRUCTED]** The 0x66e / 0x672 / 0x66a (and 0x669 clear) writes happen **only** when `param_1 == DAT_0001b738` or `param_1 == DAT_0001b888`. No other entity receives these updates. [Pacific Conflict.c:14179]
- **[INFERRED]** For the live port, Godot must maintain two designated entity references (player + second) and run the movement-smoothing block only for those two. **[UNKNOWN]** Semantic role of DAT_0001b888 (e.g. “target” vs “second player”); do not ascribe beyond “second designated entity.”

## External pointed-to record (param_1[1]) — proven offsets

**[RECONSTRUCTED]** `param_1[1]` is an external pointer used repeatedly in `FUN_0000e792` and nearby setup code. Only offsets read directly in currently ported logic are listed here.

| Offset (hex) | Access | Source (Pacific Conflict.c) |
|--------------|--------|-----------------------------|
| 0x1e | short | 14154-14155 |
| 0x3c | short | 14177 |
| 0x3e | short | 14173 |
| 0x40 | short | 4446, 13615, 13661, 13699, 14068, 14071 |
| 0x42 | short | 14302, 14304, 14310 |
| 0x44 | short | 14298, 14679, 14914, 15044 |
| 0x46 | short | 14305 |
| 0x48 | short | 14304, 14306 |

**[INFERRED]** Godot models this as `EntityTemplate`, a separate auxiliary record attached to `EntityState`, specifically to avoid guessing packed entity layout or folding external pointed-to data into the entity byte offsets.
**[RECONSTRUCTED]** `compute_template_field_40_adjustment()` in `SimCore` mirrors the proven `FUN_0000e792` rule at lines 14067-14074: `field_40` is used directly when `direction_char_679 == '-'`, otherwise it is halved toward zero.
**[RECONSTRUCTED]** `field_38` is also now modeled in Godot helper math because `FUN_0000e570` reads `*(int *)(DAT_00026004 + 0x38)` directly. [Pacific Conflict.c:13910-13915]

## Cross-reference to Godot

**[INFERRED]** The following names are used in the Godot sim and tests; offsets are from the sections above.

| Our name | Offset (hex) | STRUCTS section |
|----------|--------------|------------------|
| mission_phase_a8 | 0xa8 @ DAT_0001b5a0 | Mission / sim globals |
| mission_flag_ac | 0xac @ DAT_0001b5a0 | Mission / sim globals |
| entity_array_1 | DAT_0001d4a4 / DAT_0001c1e0 | FUN_000044e8 |
| entity_array_2 | DAT_0001b5a4 / DAT_0001b734 | FUN_000044e8 |
| entity_array_3 | DAT_0001d0e4 / DAT_0001c1dc | FUN_000044e8 |
| entity_array_4 | DAT_0001cbe4 / DAT_0001c1d8 | FUN_000044e8 |
| EntityState.OFFSETS | See entity table above | Entity (FUN_0000e792) |

**[INFERRED]** Player in trace = first entity in array 2 (DAT_0001b5a4 / DAT_0001b738 is player ptr in FUN_0000740a).

## Godot integration boundary / blocked

- **[INFERRED]** Godot integration uses **offset-based** layout only: mission block and entity offsets above are reflected in SimCore and EntityState; loader targets are consumed from `tools/proven_loader_targets.json` via `loader_metadata.gd` (parsed JSON only, no segment-manager emulation). See [LOADER_CHAIN.md](LOADER_CHAIN.md) §9.
- **[UNKNOWN]** Runtime-memory to file-offset mapping for DAT_ symbols (e.g. DAT_0001b5a0, DAT_0001c1e0) is not established; relocation, jump-table patching, and segment load execution remain blocked by address mapping.
