# Offset tables (evidence-first)

Every row must cite **source file:line** or **binary offset**. All statements tagged: **[RECONSTRUCTED]** / **[INFERRED]** / **[UNKNOWN]**.

## Mission / sim globals (DAT_0001b5a0 block)

**[RECONSTRUCTED]** Base: `DAT_0001b5a0` (Pacific Conflict.c:60, 73, 889). Mission data block; used in FUN_000044e8 and FUN_0000740a.

| Offset (hex) | Size / type | Description | Source |
|--------------|-------------|-------------|--------|
| +0x98 | short | Condition used in input path | Pacific Conflict.c:7420 |
| +0xa8 | short | Mission phase (0 &lt; phase &lt; 6 → run four arrays) | Pacific Conflict.c:5104 |
| +0xac | short | Ground Clutter option (0 → clear_pending_entity_slots) [PROVEN: MENU 5 item 9 → HEL1:127 +0x15 → A5-0x12dc] | Pacific Conflict.c:5101 |
| +0xb0 | short | Shadows option [PROVEN] | semantic C (shadow_pre_render) |
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

**[RECONSTRUCTED]** `entity_array_1` … `entity_array_4`, **`pass_id`** 1–4, **`last_tick_order`** / **`get_last_tick_order`** — see `docs/contracts/tick_FUN_000044e8_contract.md`.

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

**[RECONSTRUCTED]** Throttle **step** actions correspond to **`+` / `=`** and **`-`** / keypad plus/minus (Pacific Conflict.c cases `0x2b`/`0x3d` and `0x2d`/`0x5f` for `DAT_00024cf6` when `DAT_0001d858 < 6`). Implemented as `throttle_step_up` / `throttle_step_down` → `throttle_impulse` in `godot/hellcats/flight/player_input_map.gd`.

**[RECONSTRUCTED]** Per-tick **trace** lists `pressed` / `held` / `released` action names and `normalized` floats passed to `FlightModelMvp`.

**[MVP APPROXIMATION]** `THROTTLE_STEP_IMPULSE` (float in `0..1`) replaces the original signed char + shift/`FUN_00002e08` accumulator chain.

**[MVP APPROXIMATION]** **Gating** is only `player_active` on `PlayerAircraft`, not the full `DAT_0001d858` / `DAT_0001b870` / mission `+0x98` tree.

See `docs/contracts/input_godot_contract.md`.

## Godot `AircraftState` / `FlightModelMvp` (FUN_0000e792 convergence)

**[RECONSTRUCTED]** `movement_66e`, `movement_672`, `movement_66a` mirror proven **byte offsets** `0x66e`, `0x672`, `0x66a` on the player entity; updated each tick with **`FlightMath.add_delta_smoothed_*`** toward **int** targets from normalized controls (see `docs/contracts/flight_FUN_0000e792_contract.md`).

**[MVP APPROXIMATION]** Targets are not **local_46** / **local_42** from **FUN_0000e42a** / template math; they are **[MVP TUNING]** scaled commands.

**[INFERRED]** `snapshot` includes these fields for HUD/objectives/traces.

## Entity (FUN_0000e792) — key offsets

**[RECONSTRUCTED]** `param_1` is `int *` (entity pointer). Byte offsets: `(int)param_1 + 0xNNN` or `param_1 + K` (K in ints → byte offset K*4). Only offsets explicitly read/written in FUN_0000e792 or its immediate callees are listed; size/role inferred from access.

| Offset (hex) | Access | Source (Pacific Conflict.c) |
|--------------|--------|-----------------------------|
| 0x00 | *(int*) world/surface object ptr | [RECONSTRUCTED] `iVar1 = *param_1`; `*(iVar1+0x1c)` surface height (e792 14061/14084; also `*DAT_0001b738+0x1c` at 7354). Type byte at +0 for FUN_0000528a is **[INFERRED]** overlay/BE — Godot keeps `field_00` separate until byte buffer. |
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
| 0x662 | short | ctrl avg from `enqueue_control_inputs_avg4` p3; see bitfield § |
| 0x664 | short | ctrl avg from avg4 p2 |
| 0x666 | short | ctrl avg from avg4 p4 (heading-ish) |
| 0x669 | byte | 14097, 14155, 14156, 14200, 14238 |
| 0x66a | int | 14077, 14078, 14234-14236 |
| 0x66e | int | 14198, 14202, 14206 |
| 0x672 | short | 14214-14222 |
| 0x679 | char | 14066, 14067, 14138, 14202, 14301 |
| 0x67c | byte | 961 (DAT_0001b5a0+0xb9) |
| 0x67d | byte | 14078, 14103, 14157, 14238, 953 |
| 0x67e | byte | 14077, 14078, 14104, 14158, 954-955 |
| 0x685 | byte | `flags_685` — bitfield below |
| 0x19a | short/byte | throttle nibble 0..9 (+0x668) |
| 0x1a0 | short | 14151, 14152, 14253 |
| 0x1a1 | byte/ushort | status at +0x684 (Ghidra int* index) |
| 0x1a3 | short | 14137 |

### Control channels + `flags_685` bitfield

Fed by `enqueue_control_inputs_avg4` (`FUN_00010558`) when **bit0 clear**; consumed in `update_aircraft_entity` Block 1+.

| Offset | Avg4 source | Role [STRONG INFERENCE] |
|--------|-------------|-------------------------|
| **+0x666** | mean(param_4) | heading / yaw command |
| **+0x662** | mean(param_3) | pitch-ish / lateral companion |
| **+0x664** | mean(param_2) | third axis (often 0 from steer) |

| `flags_685` bit | Mask | Confidence | Effect |
|-----------------|------|------------|--------|
| 0 | `0x01` | [PROVEN] | Gates avg4 enqueue; also gates special-weapon spawn path (`677`) |
| 1 | `0x02` | [PROVEN] | Block 7c ammo / draw tail |
| 2 | `0x04` | [PROVEN] | RNG jitter on **+0x662** (±0x40 then clamp ±0x200) @0xE8A0 |
| 3 | `0x08` | [PROVEN] | RNG jitter on **+0x666** (clamp ±0x140) @0xE8E6 |
| 4 | `0x10` | [PROVEN] | Blocks oriented-ordnance spawn when set |
| 5 | `0x20` | [PROVEN] | Affects `67b`/`679` epilogue / contact branches |
| 6 | `0x40` | [PROVEN] | Part of `movement_669` gate with status_1a3 |
| 7 | `0x80` | [PROVEN] | Sign bit: halve throttle byte +0x19a toward 0 |

Related: **+0x684 bit0** (status) forces `+0x662=0`, `+0x666=0xFF80` after jitter.

**[RECONSTRUCTED]** Offsets **0x66e**, **0x672**, and **0x66a** are **written** only inside the ownership branch in the next section (Pacific Conflict.c:14179–14244). They are **read** elsewhere (e.g. 11730, 11753, 7936, 14427).

**[INFERRED]** Names in our EntityState (field_00, pos_2e, weapon_count_67d, etc.) match these offsets. **[UNKNOWN]** Full entity size and any padding; 0x1a3 is last offset we use in the trace.

## FUN_0000e792 — ownership branch (0x66e, 0x672, 0x66a writes)

**[RECONSTRUCTED]** The following writes occur **only when** `(param_1 == DAT_0001b738) || (param_1 == DAT_0001b888)` (Pacific Conflict.c:14179). **DAT_0001b738** = player entity pointer; **DAT_0001b888** = second entity pointer (e.g. target). Setup/use sites are recorded in the `FUN_0000e792` source-local annotation. **[UNKNOWN]** Semantic meaning of the three accumulators (e.g. axis or control surface).

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
**[RECONSTRUCTED]** `compute_template_field_40_adjustment` in `SimCore` mirrors the proven `FUN_0000e792` rule at lines 14067-14074: `field_40` is used directly when `direction_char_679 == '-'`, otherwise it is halved toward zero.
**[RECONSTRUCTED]** `field_38` is also now modeled in Godot helper math because `FUN_0000e570` reads `*(int *)(DAT_00026004 + 0x38)` directly. [Pacific Conflict.c:13910-13915]

## Record layouts: world object, face, controller (2026-10-22)

Consolidated from the semantic C (`sources/resedit-1-0-3/CODE/Pacific Conflict.decomp.c`, cited by
function name and original address; the line numbers in the older sections above refer to the Ghidra
`Pacific Conflict.c` and are not maintained). Tags: **[PROVEN]** = byte-checked function that reads
or writes the field with that meaning; **[STRONG INFERENCE]** / **[HYPOTHESIS]** as in the C.
The older "Entity (FUN_0000e792)" table mixes the controller (`param_1`) with the object it points
to (`*param_1`); use the tables below for the split.

### World object (scene object; pointer arrays DAT_0001d4a4 / DAT_0001b5a4 / DAT_0001d0e4)

| Offset | Size | Meaning | Tag | Evidence |
|--------|------|---------|-----|----------|
| +0x00 | byte | kind: 2 = shape, 3 = group (others: metric only) | [PROVEN] | activate_near_range_object 0x4e6e, dispatch_entity_cleanup 0x528a |
| +0x01 | byte | child index in the parent's 0x18-byte template table | [PROVEN] | init_mission_object_tables 0x16e2; reset_object_to_template_pose |
| +0x02 | byte | slot / child index (same value as +1 at setup) | [PROVEN] | init_mission_object_tables 0x16e2 |
| +0x03 | byte | reference count (AI targets, burning trails) | [PROVEN] | attach_burning_trail 0x16b9e; aircraft destroy hook +0xa |
| +0x05 | byte | flags (bit 0x10 = camera-facing controller attached) | [PROVEN] store / [HYPOTHESIS] role | create_camera_facing_controller 0x11aae |
| +0x06 | word | flags: 0x10 of byte +6 = land object (rebuilt by detail bands; template pose restored on release), 2 = group / index trailer, 0x1000 = spawn-gate setup, bits 11 / 13 = mover, bit 15 = collision list | [PROVEN] | build_object_poly_buffers 0x4808, collect_near_objects, update_altitude_detail_bands |
| +0x07 | byte | bit 0 = far list (DAT_0001d4a4) else near list (DAT_0001b5a4); bit 1 = flagged / skip | [PROVEN] | activate_near_range_object 0x4e6e; reset_object_to_template_pose |
| +0x08 | long | controller pointer (controller +0 points back) | [PROVEN] | activate_near_range_object 0x4e6e |
| +0x0c | long | active range (compared with +0x10) | [PROVEN] | collect_near_objects; probe_nearest_facility_kind 0x354 |
| +0x10 | long | camera metric = max + (mid + min) / 4 of the axis distances | [PROVEN] | update_object_camera_metric 0x3b98 |
| +0x14 | long | extent (sweep half-width; effect range) | [PROVEN] | collect_far_objects, collision sweep |
| +0x18 / +0x1c / +0x20 | long ×3 | world position x / y / z | [PROVEN] | update_object_camera_metric 0x3b98, approx_dist3_xyz callers |
| +0x24 | long | parent / scene root (descriptor via +0x28) | [PROVEN] | init_mission_object_tables 0x16e2 (`obj[9] = root`) |
| +0x2c | long | support list (groups) / fractal terrain reference | [PROVEN] | sort_group_parts_by_distance 0x1443a; fractal lift helpers |
| +0x2e | word | child template count (root) | [PROVEN] | init_mission_object_tables 0x16e2 |
| +0x30 | long / word | root: child table pointer (0x18-byte records); other objects: distance band word | [PROVEN] | init_mission_object_tables 0x16e2; update_record_distance_band 0x3e02 callers |
| +0x32 | word | projection shift for the camera-relative centre | [PROVEN] | collect_near_objects |
| +0x34 | word | scale shift (object units) | [PROVEN] | sort_group_parts_by_distance 0x1443a |
| +0x36 | word | vertex count (normals / points before the faces' vertices) | [PROVEN] | copy_object_vertex_buffer 0x1c04, activate_near_range_object |
| +0x38 | word | part count (groups) / trailer index count | [PROVEN] | build_object_poly_buffers 0x4808, sort_group_parts_by_distance |
| +0x3a | word | face count (also the first part face in groups) | [PROVEN] | build_object_poly_buffers 0x4808 |
| +0x3c | long | frame of last activity (retired after 0x4b frames out of range) | [PROVEN] | collect_near_objects |
| +0x44 | long | vertex array (12-byte x / y / z), `n * 12` with n = +0x36 + +0x3a | [PROVEN] | activate_near_range_object 0x4ede |
| +0x48 | long | face records (0x20 bytes each, below) | [PROVEN] | build_object_poly_buffers 0x4808 |
| +0x4c | long | second vertex array (transformed copy, same size) | [PROVEN] | copy_object_vertex_buffer 0x1c04, activate_near_range_object 0x4ede |

### Face record, live (0x20 bytes, at object +0x48)

| Offset | Size | Meaning | Tag | Evidence |
|--------|------|---------|-----|----------|
| +0x02 | word | draw order | [PROVEN] | output_face_colour 0xa16e, output_face_bw 0xa220 |
| +0x04 | word | colour / pattern index | [PROVEN] | output_face_colour 0xa16e, queue_face_palette_entry 0x147a, assign_face_colour 0x159e |
| +0x08 | long | cleared at build | [PROVEN] | build_object_poly_buffers 0x4808 |
| +0x0c..+0x0e | byte ×3 | r / g / b (fogged toward 0x7d / 0x84 / 0xa8 by distance band) | [PROVEN] | sort_group_parts_by_distance 0x1443a, write_face_palette_slot 0x1548 |
| +0x0f | byte | palette slot (0 = none) | [PROVEN] | write_face_palette_slot 0x1548 |
| +0x10..+0x13 | byte ×4 | copied from packed bytes +4..+7 | [PROVEN] | build_object_poly_buffers 0x4808 |
| +0x14 | word | vertex index count | [PROVEN] | build_object_poly_buffers 0x4808 |
| +0x16 | byte | surface code (high nibble of packed +9) | [PROVEN] | surface_type_at_point 0x13346 |
| +0x17 | byte | tag (low nibble: 1 carrier deck, 3 arresting zone) | [PROVEN] | carrier_deck_contact |
| +0x18 | long | vertex index list (heap, count words) | [PROVEN] | build_object_poly_buffers 0x4808 |
| +0x1c | long | packed long +0xa (× level scale later; durability reading open) | [PROVEN] store / [UNKNOWN] role | apply_entity_mission_rates |

### Face record, packed (scene data stream, 0xe + 2 × count bytes)

| Offset | Size | Meaning | Evidence |
|--------|------|---------|----------|
| +0x00 | long | colour long (→ live +0x0c) | build_object_poly_buffers 0x4808 |
| +0x04 | byte ×4 | → live +0x10..+0x13 | same |
| +0x08 | byte | vertex count | same; nearest_type80_centroid_visitor |
| +0x09 | byte | surface code \| tag (type 0x80 = facility centroid, 0x70 tested elsewhere) | same; nearest_type80_centroid_visitor |
| +0x0a | long | → live +0x1c | same |
| +0x0e | word × count | vertex indices | same |

### Controller (pointed to by object +0x08)

Common header **[PROVEN]**: +0x00 = owning object; +0x20 / +0x22 / +0x24 = attitude words (pitch-type,
heading, bank; `attitude_from_velocity` outputs, update_aircraft_entity 0xe792); +0x2e = ground height
under the controller (ordnance). Kind-specific fields:

| Kind | Fields | Evidence |
|------|--------|----------|
| aircraft | +0x36 pose ring, +0x612 ring index, +0x616 buffer, +0x61a / +0x61c / +0x61e previous steering errors, +0x626 / +0x62a throttle / movement, +0x63f / +0x640 state bytes, +0x675 bombing stage, +0x679 gear position, +0x67a gear bits, +0x67b flaps, +0x67c bombs, +0x684 / +0x686 / +0x688 damage / previous / timer, +0x692 AI target object, +0x6ac release frame | update_aircraft_entity 0xe792 and its helpers (param comments) |
| effect | +0x32 kind, +0x33 flags, +0x34 size, +0x36 lifetime, +0x38 smoke byte, +0x3a / +0x6e / +0xa2 velocities, +0x76 vertical velocity, +0x52 owner controller, +0x56 trail flag | spawn_effect 0x11c58, attach_burning_trail 0x16b9e, effect tick helpers |
| ordnance | +0x32 pose ring, +0x60e ring index, +0x610 speed, +0x614 kind, +0x616 direct hit, +0x618 blast frame, +0x61c / +0x61e flags | spawn_weapon_entity, ordnance tick helpers |
| ship (sinking / firing) | +0x32 hits left, +0x34.. angles, +0x3a.. rates, +0x40 drop, +0x44 interval, +0x46 steps, +0x48 next frame, +0x4c sinking started, +0x4e credit, +0x50 shots, +0x52 guns, +0x54 gun positions, +0xe4 aims | ship controller helpers (docs/SHIP_CONTROLLERS.md) |
| spinner (0x3a bytes) | +0x22 heading word | spin_object_heading 0x114b4 |

### Surface-contact records

Two record variants, as named in the C **[PROVEN, param comments of byte-checked functions]**:

- face-contact record (point_over_face_xz 0x132c8): +0x00 object, +0x04 model, +0x0c position shift,
  +0x0e vertex shift;
- fractal-terrain record (fractal_height_at 0x13980, reached through object +0x2c): +0x04 object,
  +0x0e..+0x14 rotation, +0x16 cell size, +0x18..+0x1e cell bounds, +0x22 / +0x30 planes.

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
