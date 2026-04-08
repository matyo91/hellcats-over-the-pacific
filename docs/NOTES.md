# Daily log (evidence-first)

Every statement is tagged: **[RECONSTRUCTED]** (from decompiler/binary), **[INFERRED]** (reasoning from evidence), **[UNKNOWN]** (unverified or missing).

## Template (copy for new days)

```markdown
### YYYY-MM-DD
- [RECONSTRUCTED] ...
- [INFERRED] ...
- [UNKNOWN] ...
```

## Entries

### 2026-04-08 — Convergence Loop Mode (batch: mission bridge + RNG draws + FUN_0000435a counts)

- **[INFERRED]** Backlog + loop template: `docs/CONVERGENCE_BACKLOG.md`, `docs/CONVERGENCE_LOOP_TEMPLATE.md`.
- **[RECONSTRUCTED]** **Iteration 1 — Mission gates:** `MissionController` sets **`mission_phase_a8` / `mission_flag_ac`** (running: 1/1; terminal: 0/0); **`get_mission_sim_bridge_state()`**. See `docs/contracts/mission_state_DAT_contract.md`.
- **[RECONSTRUCTED]** **Iteration 2 — RNG timing:** `SimCore._rng_consume()` counts draws per tick; **`last_tick_order.rng_draws_this_tick`**.
- **[RECONSTRUCTED]** **Iteration 3 — FUN_0000435a / param_2:** **`last_tick_order.param_2_entity_updates`** `{0: n, 1: m}`; contract `docs/contracts/FUN_0000435a_contract.md` (type 0x02 loop gated by `param_2==0` not yet branched in code).
- **Validation:** `godot/tests/integration/test_sim_tick_ordering.gd` (includes RNG/param2 counts).

### 2026-04-08 — Entity tick ordering convergence (FUN_000044e8 / FUN_000044a4)

- **[RECONSTRUCTED]** `SimCore.tick()` now records **`last_tick_order`**: four passes in order **DAT_0001d4a4** → **DAT_0001b5a4** → **DAT_0001d0e4** → **DAT_0001cbe4** with **`param_2`** **0, 0, 1, 1**, then **`_call_06fb8()`**, matching Pacific Conflict.c:5105–5142.
- **[RECONSTRUCTED]** **`FUN_000044a4`** second argument surfaced as **`last_pass_param_2`** / **`last_pass_id`** during **`_run_pass`** (Pacific Conflict.c:5109–5139).
- **[INFERRED]** Optional **`tick_order_trace_enabled`**: player **`movement_66e`/`672`/`66a`** snapshots before tick, after pass 2 (array 2), and after full gated section; **`rng_state_after_tick`**.
- **[MVP APPROXIMATION]** Mission-1 **playable** loop remains **`PlayerAircraft` + `FlightModelMvp`**; **`SimCore`** is the **deterministic** bridge for parity tests and future wiring (see `docs/contracts/tick_FUN_000044e8_contract.md`).

**Validation:** `godot/tests/integration/test_sim_tick_ordering.gd`. Run: `godot --headless --path . -s godot/tests/run_all.gd`.

### 2026-04-08 — Flight model convergence pass (FUN_0000e792 motion slice)

- **[RECONSTRUCTED]** `FlightModelMvp` now drives pitch/roll/yaw from **FUN_0000e792-style** smoothed accumulators **`movement_66e`**, **`movement_672`**, **`movement_66a`** using `FlightMath.add_delta_smoothed_int` / `add_delta_smoothed_s16` (Pacific Conflict.c:14182–14242; see `docs/contracts/flight_FUN_0000e792_contract.md`).
- **[INFERRED]** Axis assignment **66e→pitch**, **672→roll**, **66a→yaw** for MVP integration; full `local_46`/`local_42` airspeed/template chain not ported.
- **[MVP APPROXIMATION]** Command targets are **scaled** `[-1,1]` × `pitch_max_int` / `roll_max_int` / `yaw_max_int` (default **8192** in `aircraft_mvp.json` → `movement_smoothing`).
- **[MVP TUNING]** `roll_auto_level_gain` still applied when roll stick neutral; rates/drag unchanged unless data changes.
- **[INFERRED]** Per-tick **`FlightModelMvp.last_flight_trace`** (and `PlayerAircraft.get_flight_trace()`) exposes accumulators, norms, telemetry for QA.

**Validation:** `godot/tests/unit/test_flight_model_mvp.gd` (straight, sustained turn, climb, descend, throttle sequence, smoothing). Run: `godot --headless --path . -s godot/tests/run_all.gd`.

### 2026-04-08 — Input convergence pass (FUN_0000740a → Godot)

- **[RECONSTRUCTED]** `PlayerInputMap` now mirrors **press/hold/release** traces and **throttle step** (`+`/`-` / keypad) as **edges** → `throttle_impulse`, with **hold** throttle still on `W`/`S` / Page Up/Down (`read_input_packet`, `compute_outputs`). See `docs/contracts/input_godot_contract.md`.
- **[RECONSTRUCTED]** `FlightModelMvp` applies `controls.throttle_impulse` as an instant delta on top of axis rate (original `DAT_00024cf6` path is not fully ported).
- **[MVP APPROXIMATION]** Single gate **`player_active`** instead of `DAT_0001d858` / overlay / mission `+0x98` branches; gated presses recorded in `trace.ignored`.
- **[INFERRED]** Per-tick trace: `pressed` / `held` / `released` / `normalized` / `gated` — inspect `PlayerInputMap.last_input_trace` during play or tests.
- **[UNKNOWN]** Full Mac `param_2` enum parity; only Godot action edges are logged.

**Validation:** `godot/tests/unit/test_player_input_frame.gd` (deterministic scenarios: hold pitch, tap roll, throttle steps, gate). Run: `godot --headless --path . -s godot/tests/run_all.gd` (from project root; requires Godot 4 on `PATH`).

### FUN_000044e8 — main sim update order

- **[RECONSTRUCTED]** `FUN_000044e8` (Pacific Conflict.c:5094) is the main sim tick: it checks `*(short *)(DAT_0001b5a0 + 0xac)`; if zero, calls `FUN_00005df8()`. [Pacific Conflict.c:5101-5102]
- **[RECONSTRUCTED]** If `0 < *(short *)(DAT_0001b5a0 + 0xa8) && *(short *)(DAT_0001b5a0 + 0xa8) < 6`, it then updates four entity arrays in order: (1) `DAT_0001d4a4` count `DAT_0001c1e0`, (2) `DAT_0001b5a4` count `DAT_0001b734`, (3) `DAT_0001d0e4` count `DAT_0001c1dc`, (4) `DAT_0001cbe4` count `DAT_0001c1d8`. [Pacific Conflict.c:5104-5138]
- **[RECONSTRUCTED]** Each array is iterated with `FUN_000044a4((char *)*puVar2, param_2)`: arrays 1–2 use `param_2 = 0`, arrays 3–4 use `param_2 = 1`. [Pacific Conflict.c:5109, 5117, 5126, 5135]
- **[RECONSTRUCTED]** After all four arrays, `FUN_00006fb8()` is called. [Pacific Conflict.c:5139]
- **[INFERRED]** This order is the single source of truth for our SimCore tick; reordering would break parity with the original.

### FUN_0000740a — input handler variables

- **[RECONSTRUCTED]** `FUN_0000740a(int param_1, int param_2)` (Pacific Conflict.c:7366) is an input/key handler. `param_1` and `param_2` are key code and action (e.g. 3 = press). [Pacific Conflict.c:7366, 7452-7466]
- **[RECONSTRUCTED]** It reads/writes: `DAT_0001d858` (game state, e.g. 1, 8, 9), `DAT_0001b738` (player entity pointer), `DAT_0001b870`, `DAT_0001b87c`, `DAT_0001b884`, `DAT_0001b86e`, `DAT_0001b86c`, `DAT_0001b888`, `DAT_00020b2a`, `DAT_0001b5a0` (mission base). [Pacific Conflict.c:7391-7393, 7396-7445]
- **[RECONSTRUCTED]** Mission block at `DAT_0001b5a0`: `*(short *)(DAT_0001b5a0 + 0x98)` and `*(short *)(DAT_0001b5a0 + 0x25e)`, `(DAT_0001b5a0 + 0x2b6)`, `(DAT_0001b5a0 + 0x2be)` (callbacks). [Pacific Conflict.c:7420-7425]
- **[RECONSTRUCTED]** Player-relative reads: `*DAT_0001b738 + 7`, `*DAT_0001b738 + 4`, `*DAT_0001b738 + 0x18/0x1c/0x20`, `(int)DAT_0001b738 + 0x22`, `(int)DAT_0001b738 + 0x63e`; and `(int)piVar14 + 0x19a`, `(int)piVar14 + 0x19e`, `(int)piVar14 + 0x62a`, `(int)piVar14 + 0x32`. [Pacific Conflict.c:7398-7401, 7433-7436, 7473-7477]
- **[INFERRED]** Replay/trace input packets should map to the same (param_1, param_2) semantics used here; exact key-to-param_1 mapping is [UNKNOWN] until we capture a key table.

### FUN_0000e792 — entity (param_1) offsets

- **[RECONSTRUCTED]** `FUN_0000e792(int *param_1)` (Pacific Conflict.c:14016) updates a single entity; `param_1` is the entity pointer (int* = 4-byte units). [Pacific Conflict.c:14016, 14058]
- **[RECONSTRUCTED]** Offsets used in FUN_0000e792 (byte offsets from entity base) are documented in STRUCTS.md “Entity (FUN_0000e792)” table; each row cites the line(s) where the offset is read or written. [Pacific Conflict.c:14060-14334 and surrounding]
- **[INFERRED]** Entity layout is shared by all four arrays; FUN_000044a4 calls FUN_0000e792 (or equivalent logic), so the same offsets apply to entity_array_1..4. [UNKNOWN] whether any array uses a different struct.
- **[RECONSTRUCTED]** A minimal ported slice now exists in Godot for lines 14103-14135: if `(flags_685 & 4) != 0`, `movement_662` is perturbed by `(FUN_00011564() & 0x7f) - 0x40` and clamped to `[-0x200, 0x200]`; if `(flags_685 & 8) != 0`, `movement_666` is perturbed the same way and clamped to `[-0x140, 0x140]`; if `(status_1a1 & 1) != 0`, then `movement_662 = 0` and `movement_666 = 0xff80`. [Pacific Conflict.c:14103-14135; `godot/hellcats/core/sim_core.gd`]
- **[RECONSTRUCTED]** A second minimal slice now exists in Godot for lines 14137-14152: `movement_669` is set to `1` only when the `(flags_685 & 0x40)`, `status_1a3`, `status_1a1 & 0x300`, and `67d/67e` gate allows it; otherwise it is cleared and the local accumulator becomes zero. If `flags_685` is negative, the signed byte at `0x19a` is halved toward zero before being added into `status_1a0`. [Pacific Conflict.c:14137-14152; `godot/hellcats/core/sim_core.gd`]
- **[RECONSTRUCTED]** The threshold/decrement logic at lines 14153-14163 is now ported in Godot using a minimal external auxiliary record: if `external_template.field_1e < status_1a0`, subtract that threshold from `status_1a0`, draw one RNG value, and decrement `67e` unless `(rng & 1) != 0` and `67d != 0`, in which case decrement `67d`. [Pacific Conflict.c:14153-14163; `godot/hellcats/core/entity_template.gd`; `godot/hellcats/core/sim_core.gd`]
- **[RECONSTRUCTED]** `param_1[1]` also has a proven short at `+0x40`, used earlier in entity setup and in `FUN_0000e792`; this stays documented as external pointed-to state, not folded into `EntityState`. [Pacific Conflict.c:4446, 13615, 13661, 13699, 14068, 14071]
- **[RECONSTRUCTED]** Additional external-template shorts are now documented and modeled at offsets `+0x3c`, `+0x3e`, `+0x42`, `+0x44`, `+0x46`, and `+0x48`, because the next adjacent `FUN_0000e792` math block references them directly. [Pacific Conflict.c:14173, 14177, 14298, 14302-14306, 14679, 14914, 15044]
- **[RECONSTRUCTED]** Godot now exposes a reusable helper for the `+0x40` rule from `FUN_0000e792`: if `direction_char_679 == '-'`, use `external_template.field_40` directly; otherwise halve it toward zero. [Pacific Conflict.c:14067-14074; `godot/hellcats/core/sim_core.gd`]
- **[RECONSTRUCTED]** The helper trio behind the next math block is now reconstructed in `godot/hellcats/core/flight_math.gd`: `FUN_0000e42a(uint)` uses the raw overlapping table at `DAT_0001b2c0`; `FUN_0000e468(int, short)` damps the second parameter only when the first is below `0x200`; `FUN_0000e570(short, int*)` scales `external_template.field_38` by a ratio derived from `param_1`. [Pacific Conflict.c:13796-13915]
- **[INFERRED]** `compute_local_34()` is now modeled as a pure helper using the already-proven `external_template.field_3c`, `field_3e`, and the output of `FUN_0000e570`, but it is not yet wired into the live tick because the surrounding block still depends on more helper-driven state (`0x66e`, `0x672`, `0x66a`) and ownership semantics.

### FUN_0000e792 — ownership branch (DAT_0001b738 / DAT_0001b888) and 0x66e / 0x672 / 0x66a

- **[RECONSTRUCTED]** The block at Pacific Conflict.c:14179–14244 runs **only when** `(param_1 == DAT_0001b738) || (param_1 == DAT_0001b888)`. No other entity receives the updates to offsets 0x66e, 0x672, or 0x66a in this block. [Pacific Conflict.c:14179]
- **[RECONSTRUCTED]** **DAT_0001b738** is the **player entity pointer**: set when the first qualifying entity is created (e.g. `FUN_0000dff0` at 13616–13617 assigns `DAT_0001b738 = puVar2`). It is read/written across the codebase as the single “player” plane. [Pacific Conflict.c:13616–13617, 4424, 5049, 7351–7358, 7392, 7446, 14179, 14334, etc.]
- **[RECONSTRUCTED]** **DAT_0001b888** is a **second entity pointer** (e.g. target or second player): set to 0 at 6101; set from `*(param_2 + 8)` in FUN_0000ff44 at 15122 when `DAT_0001d858` is 1, 8, or 7 and other conditions. [Pacific Conflict.c:6101, 7450, 7485–7486, 15117–15122]
- **[INFERRED]** The branch is “special” because **only the entity that is the current player or the current target** gets the **movement-smoothing accumulators** at 0x66e (int), 0x672 (short), and 0x66a (int) updated in this block. All other entities skip this block entirely. **[UNKNOWN]** High-level semantics (e.g. “pitch” vs “roll” vs “yaw”) of 0x66e/0x672/0x66a; only the formulas and conditions below are proven.

**Exact conditions under which 0x66e, 0x672, and 0x66a are updated**

- **[RECONSTRUCTED]** **Guard:** Updates occur **only if** `param_1 == DAT_0001b738` **or** `param_1 == DAT_0001b888`. [Pacific Conflict.c:14179]
- **[RECONSTRUCTED]** **0x66e (int):** `local_46` = `(int)(short)(0x5e50 / (short)(sVar15 + 0xa25 >> 5)) * sVar21 * 0x666 >> 5`. Delta = `local_46 - *(int *)((int)param_1 + 0x66e)`. If `|delta| < 8` (i.e. `(delta + 7*(delta<0)) >> 3 == 0`): add delta to 0x66e; else add `(delta + 7*(delta<0)) >> 3` to 0x66e. [Pacific Conflict.c:14180–14194]
- **[RECONSTRUCTED]** **0x672 (short):** If `*(char *)((int)param_1 + 0x669) == 0` **or** `(*(ushort *)(param_1 + 0x1a1) & 0x4300) != 0`, the effective source value is 0; else it is `(short)(local_26 >> 9)`. If `*(char *)((int)param_1 + 0x685) < 0`, that value is adjusted (round toward zero then `>> 1`). Delta = that value − `*(short *)((int)param_1 + 0x672)`. Same rule: add delta or `delta>>3` (with negative rounding). [Pacific Conflict.c:14196–14222]
- **[RECONSTRUCTED]** **0x66a (int):** `local_42 = (iVar20 << 0x11) / 0x1c20` where `iVar20 = *(int *)((int)param_1 + 0x62a) >> 2`. `iVar19` = current `*(int *)((int)param_1 + 0x66a)`. `iVar10 = local_42 - local_46`; then `iVar10 = -(iVar19 - (local_46 + (iVar10 >> 1)))`. Same add delta or `delta>>3`. [Pacific Conflict.c:14180, 14165–14167, 14223–14241]
- **[RECONSTRUCTED]** **0x669 clear:** Inside the same branch, if `(*(byte *)(param_1 + 0x1a1) & 0x40) != 0` **and** `*(int *)((int)param_1 + 0x66e) == 0`, then `*(byte *)((int)param_1 + 0x669) = 0`. [Pacific Conflict.c:14241–14243]

**Safe for live port now vs unresolved**

- **Safe to implement (evidence-backed):** (1) **Branch condition:** run the 0x66e/0x672/0x66a update block only when the entity pointer equals the “player” entity or the “target” entity (Godot must pass the same two designations from its sim state). (2) **Field writes:** the exact delta rules (add full delta when `|delta| < 8`, else add `delta>>3` with negative rounding) and the formulas for `local_46`, `local_42`, and the 0x672 source from `local_26` and the 0x669/0x1a1/0x685 gates. (3) **0x669 clear:** when in this branch and status_1a1 has bit 0x40 and 0x66e is zero, set 0x669 to 0.
- **Unresolved (do not guess):** (1) Semantic names for 0x66e, 0x672, 0x66a (e.g. which axis or control surface). (2) Whether DAT_0001b888 is always “target” or sometimes a second player; Godot can mirror “two designated entities” without ascribing meaning. (3) Any other code paths that read/write these offsets outside FUN_0000e792 (see STRUCTS.md for read sites).

## Doc sync: helper trio, ownership, next live-port

- **[RECONSTRUCTED]** The **helper trio** is reconstructed in `godot/hellcats/core/flight_math.gd`: FUN_0000e42a (raw table at DAT_0001b2c0), FUN_0000e468 (damp when first param &lt; 0x200), FUN_0000e570 (scale external_template.field_38 by ratio from param_1). [Pacific Conflict.c:13796–13915] **[INFERRED]** `compute_local_34()` is modeled from proven external_template fields but not yet wired into the tick.
- **[RECONSTRUCTED]** **Ownership branch status:** Only the entity matching **DAT_0001b738** (player) or **DAT_0001b888** (second designated entity) receives writes to 0x66e, 0x672, 0x66a in the block at 14179–14244. DAT_0001b738 is set at entity creation (e.g. FUN_0000dff0); DAT_0001b888 is set to 0 at 6101 and from FUN_0000ff44 when DAT_0001d858 is 1, 8, or 7. [Pacific Conflict.c:14179, 13616–13617, 6101, 15117–15122]
- **Exact next live-port boundary [RECONSTRUCTED]:** Godot Engineer may port the **movement-smoothing block** (14179–14244) into the per-entity tick: (1) run the 0x66e/0x672/0x66a update **only when** current entity pointer equals SimCore's designated player entity or designated target entity; (2) use the proven formulas and delta rules (add full delta when |delta|&lt;8, else add delta&gt;&gt;3 with negative rounding); (3) apply the 0x669 clear when in branch and (status_1a1 &amp; 0x40) and 0x66e==0. **[UNKNOWN] Blocked:** assigning semantic names to 0x66e/0x672/0x66a; defining DAT_0001b888 beyond "second designated entity"; porting any logic that depends on unverified code paths for these offsets.

## Changelog

| Date       | Topic | Change |
|------------|--------|--------|
| (today)    | FUN_000044e8, FUN_0000740a, FUN_0000e792 | Initial log entries from Pacific Conflict.c. |
| (today)    | FUN_0000e792 ownership branch | Documented DAT_0001b738/DAT_0001b888 branch, 0x66e/0x672/0x66a update conditions, safe vs unresolved for movement-smoothing port. |
| (today)    | Doc sync | Helper trio reconstructed; ownership branch status; exact next live-port boundary (ROADMAP, STRUCTS). |

### ID00 / loader chain

- **[RECONSTRUCTED]** `ID00.bin` begins with four big-endian u32 values: `0x00000598`, `0x0000225e`, `0x00000578`, `0x00000020`. [ResEdit/CODE/ID00.bin bytes `0x0000..0x000f`; verified with `xxd`]
- **[RECONSTRUCTED]** Starting at file offset `0x0012`, `ID00.bin` contains repeated byte patterns `3f 3c <seg_id> a9 f0`, which decode as `MOVE.W #seg_id,-(SP); _LoadSeg`. [ResEdit/CODE/ID00.bin; decoded by `tools/decode_id00_loadseg.py`]
- **[RECONSTRUCTED]** The Toolbox trap `A9F0` is `LoadSeg`. [Apple Toolbox trap table, `A9F0 LoadSeg`]
- **[RECONSTRUCTED]** `ID00.bin` contains 174 `_LoadSeg` entries grouped by CODE resource id in this order: `1` (10 entries), `4` (33), `3` (3), `6` (9), `8` (3), `9` (36), `2` (68), `5` (11), `7` (1). [Decoded from `ID00.bin` by `tools/decode_id00_loadseg.py`]
- **[INFERRED]** `ID00.bin` is acting as a segment loader/dispatch table for CODE resources rather than ordinary gameplay logic.
- **[RECONSTRUCTED]** Correlating the `ID00.bin` tail words against exported `FUN_0000xxxx` symbols in `ID01.c`-`ID09.c` shows strong near-matches in several segments: `ID05` matches 11/11 within `+4` or `+6`, `ID02` matches 65/68 within `+4`, `ID07` matches 1/1 within `+4`, and `ID06` matches 6/9 within `+4`. [Generated by `tools/correlate_id00_to_functions.py`]
- **[INFERRED]** The `ID00.bin` tail word often appears to point a few bytes before the decompiler-labeled function start, most commonly `+4`, and less often `+6`.
- **[INFERRED]** `ID00.bin` therefore likely references segment-local routine entry slots rather than arbitrary data offsets, at least for segments `ID02`, `ID05`, `ID06`, and `ID07`.
- **[RECONSTRUCTED]** The trailing u16 is the segment-local **stored routine offset** (first_instruction_offset − 4, or −6 when segment has 6-byte header). Bytes at tail in ID02: UNLK (4e 5e), RTS (4e 75), then LINK at tail+4; in ID05 first routine: header at 0, LINK at 6 ⇒ tail+6. See [LOADER_CHAIN.md](LOADER_CHAIN.md) §4.2.
- **[RECONSTRUCTED]** Entrypoint handoff: JSR offset(A5) → jump table entry (MOVE.W #seg,-(SP); LoadSeg; .word tail) → LoadSeg → Segment Manager sets routine = base+(tail+4 or tail+6), JMP to routine (LINK). Ibid. §5.

## Loader-chain sync (docs vs artifact)

- **[RECONSTRUCTED]** Per [LOADER_CHAIN.md](LOADER_CHAIN.md) §10, **six** loader targets are proven by byte-level evidence (UNLK/RTS/LINK at tail or 6-byte prologue + RTS/LINK): ID02×1, ID05×1, ID06×3, ID07×1.
- **[RECONSTRUCTED]** `tools/proven_loader_targets.json` currently lists **two** targets (ID02, ID05). The four additional targets (ID06 at 0x0e10, 0x096e, 0x09d8; ID07 at 0x0190) are proven in LOADER_CHAIN but not yet in that JSON; the artifact is updated only when the maintainer re-runs the proof (LOADER_CHAIN §8).
- **[INFERRED]** Godot consumes whatever targets are present in the JSON; the headless test proves SimCore with the two targets currently in the artifact.
- **[UNKNOWN]** Still blocked by address mapping: runtime relocation, jump-table patching, and actual segment load execution are out of scope until the address model is proven further (LOADER_CHAIN §9).
- **Next milestone:** Extend `proven_loader_targets.json` to include the four remaining proven targets (ID06×3, ID07×1), or document the decision to keep the artifact minimal; then proceed to trace capture for parity validation.

### Mission 01 MVP extraction brief (flight school / pilot training)

#### Useful now

- **[RECONSTRUCTED]** `DAT_0001b738` is the player entity pointer and is used as the primary flight actor in the input path (`FUN_0000740a`) and camera/world-anchor updates (`DAT_0001d838/d834/d830` copied from player `+0x18/+0x1c/+0x20`). [Pacific Conflict.c:7392, 7437-7439, 7702-7704]
- **[RECONSTRUCTED]** Mission runtime gating needed for a deterministic training loop is already proven: mission tick uses `*(short *)(DAT_0001b5a0 + 0xac)` and `*(short *)(DAT_0001b5a0 + 0xa8)`; only when `0 < +0xa8 < 6` are all four entity arrays updated. [Pacific Conflict.c:5102-5138]
- **[RECONSTRUCTED]** Input events are key/action pairs (`FUN_0000740a(int param_1, int param_2)`), with explicit press checks (`param_2 == 3`) and release/other-action handling paths. [Pacific Conflict.c:7368, 7455, 7462-7469]
- **[RECONSTRUCTED]** Training-relevant mode/state transitions are keyed through `DAT_0001d858` and values including 1, 5, 7, 8, 9; examples: key `'c'`/`'C'` sets state 5, key `'e'`/`'E'` can enter state 7 when secondary pointer exists, key `'v'`/`'V'` returns to state 1 and recenters anchor vars. [Pacific Conflict.c:7675-7704]
- **[RECONSTRUCTED]** Proven per-frame player-control accumulators exist (`0x66e`, `0x672`, `0x66a`) and are updated only for designated player/secondary entities (`DAT_0001b738` / `DAT_0001b888`) with deterministic smoothing deltas. This is sufficient for an MVP-stable "aircraft feel" seam without full semantic naming. [Pacific Conflict.c:14179-14244]
- **[INFERRED]** HUD-minimum telemetry for MVP can safely use already-proven player fields (`+0x18/+0x1c/+0x20` world position and heading/attitude-related shorts used across input/update paths) even before exact cockpit/HUD parity is solved.

#### Ignore for MVP

- **[INFERRED]** Loader-chain deep work (`ID00` dispatch/tail-offset proof, segment entry correlation) does not unblock a playable single training slice.
- **[INFERRED]** Full DAT block reconstruction for `DAT_0001b5a0` beyond `+0xa8/+0xac/+0x98/+0x25e/+0x2b6/+0x2be` is unnecessary for Mission 01 MVP.
- **[INFERRED]** Full semantic labeling of advanced entity offsets (all `0x61a..0x685` behaviors, full weapon/system modes) is not required for initial flight school progression.
- **[INFERRED]** Exact original non-training states/campaign transitions implied by the broader `DAT_0001d858` FSM can be deferred.

#### Unknown but not blocking

- **[UNKNOWN]** Exact canonical meaning of each `DAT_0001d858` value (1..9) as player-facing named modes.
- **[UNKNOWN]** Exact original keycode-to-keyboard-layout mapping for all `param_1` values; we have direct codepoint evidence for many keys, but not a full authoritative table per platform layout.
- **[UNKNOWN]** Exact historical training mission script/scoring thresholds/objective timing text.
- **[UNKNOWN]** Exact semantic names for movement accumulators `0x66e`, `0x672`, `0x66a` (axis/control-surface identity).
