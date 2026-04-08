# Roadmap — Phase A / B / C

Every statement is tagged: **[RECONSTRUCTED]** / **[INFERRED]** / **[UNKNOWN]**.

**[INFERRED]** Ongoing convergence backlog: `docs/CONVERGENCE_BACKLOG.md`; process template: `docs/CONVERGENCE_LOOP_TEMPLATE.md`.

---

## Phase A — Skeleton and determinism

**Goal:** [INFERRED] Run a deterministic sim tick loop that matches the original update order and can be traced/replayed.

| Item | Status | Evidence / notes |
|------|--------|-------------------|
| Sim tick order (four arrays + FUN_00006fb8) | Done | [RECONSTRUCTED] FUN_000044e8 (Pacific Conflict.c:5096-5144). SimCore: explicit `PASS_DAT_*`, `last_tick_order`, `param_2` 0/1 per pass; `docs/contracts/tick_FUN_000044e8_contract.md`. |
| Mission phase/flag (0xa8, 0xac) | Done | [RECONSTRUCTED] Pacific Conflict.c:5101, 5104. SimCore.mission_phase_a8 / mission_flag_ac. |
| RNG (LCG, 0x41c64e6d, 0x3039) | Done | [RECONSTRUCTED] ID05; Rng68k in godot. |
| Entity state layout (proven offsets) | Skeleton | [RECONSTRUCTED] FUN_0000e792 (Pacific Conflict.c:14016+). EntityState has keys; from_bytes TODO. |
| Trace format + TraceWriter + ReplayRunner | Done | [INFERRED] docs/TRACE.md, trace_diff.py, TraceWriter, ReplayRunner. |
| FUN_00005df8 | Placeholder | [RECONSTRUCTED] Called when mission_flag_ac == 0 (Pacific Conflict.c:5102). [UNKNOWN] behavior. |
| FUN_00006fb8 | Placeholder | [RECONSTRUCTED] Called after four arrays (Pacific Conflict.c:5139). [UNKNOWN] behavior. |
| FUN_000044a4 / per-entity update | Partial | [RECONSTRUCTED] `FUN_000044a4` → `_update_single_entity`; **`param_2`** passed through (5035a path not fully ported). [RECONSTRUCTED] Minimal slices: `flags_685` RNG, gates, movement smoothing, etc. [RECONSTRUCTED] **Helper trio** in `flight_math.gd`. [RECONSTRUCTED] Designated player/target for 0x66e/0x672/0x66a. **MVP:** `flight_model_mvp.gd` for Mission-1 aircraft; **Next:** full **FUN_0000435a** branch parity by `param_2`. |

**Acceptance (Phase A):** [INFERRED] Same seed + same inputs ⇒ identical trace (see docs/TRACE.md). **[UNKNOWN]** Until entity/mission logic is ported, traces will only reflect phase/flag/input/RNG.

---

## Phase B — Input and mission logic

**Goal:** [INFERRED] Map input to original key/action semantics; run mission and entity updates enough to validate parity on real gameplay traces.

| Item | Status | Evidence / notes |
|------|--------|-------------------|
| Input handler (FUN_0000740a) variables | Documented | [RECONSTRUCTED] Pacific Conflict.c:7366+; STRUCTS.md “FUN_0000740a”. |
| Godot gather + throttle step + trace | Done | [RECONSTRUCTED] Step keys → `throttle_impulse`; [MVP APPROXIMATION] gate + `THROTTLE_STEP_IMPULSE`. `docs/contracts/input_godot_contract.md`, `PlayerInputMap.last_input_trace`. |
| FUN_0000e792 movement smoothing → MVP flight | Partial | [RECONSTRUCTED] `movement_66e`/`672`/`66a` + `FlightMath` delta rule in `flight_model_mvp.gd`; [MVP APPROXIMATION] scaled cmd targets; [UNKNOWN] full `local_46`/`local_42` chain. `docs/contracts/flight_FUN_0000e792_contract.md`. |
| FUN_000044e8 pass ordering + `last_tick_order` | Done | [RECONSTRUCTED] Four passes + `param_2` pattern; `docs/contracts/tick_FUN_000044e8_contract.md`; `test_sim_tick_ordering.gd`. |
| Key code → param_1 mapping | Partial | [RECONSTRUCTED] Brief + Godot `ACTIONS`; [UNKNOWN] full Mac table vs all branches. |
| DAT_0001d858 state machine | Not started | [RECONSTRUCTED] Values 1, 7, 8, 9 in code. [UNKNOWN] full FSM. |
| FUN_00005df8 behavior | Not started | [RECONSTRUCTED] Called when flag_ac == 0. [UNKNOWN] logic. |
| FUN_00006fb8 behavior | Not started | [RECONSTRUCTED] Post-entity tick. [UNKNOWN] logic. |

**Acceptance (Phase B):** [INFERRED] Replay of a captured input sequence produces a trace that matches the original (same seed). **[UNKNOWN]** Depends on Phase A entity/mission placeholders being implemented.

---

## Phase C — Full parity and validation

**Goal:** [INFERRED] All critical entity and mission behavior ported; trace_diff on long sessions shows no divergence.

| Item | Status | Evidence / notes |
|------|--------|-------------------|
| FUN_0000e792 full port | Not started | [RECONSTRUCTED] Entity movement/weapons (Pacific Conflict.c:14016+). Large function. |
| FUN_000044a4 second arg (0 vs 1) | Not started | [RECONSTRUCTED] Arrays 1–2: 0, arrays 3–4: 1 (Pacific Conflict.c:5109, 5126). [UNKNOWN] effect. |
| Other entity arrays’ roles | Not started | [INFERRED] Array 2 = player-related (DAT_0001b738). [UNKNOWN] roles of 1, 3, 4. |
| Binary trace capture (original game) | Not started | [UNKNOWN] Whether we can log RNG/state from the original binary for cross-check. |

**Acceptance (Phase C):** [INFERRED] Same seed + same inputs ⇒ identical trace over full mission; trace_diff.py is the arbiter.

---

## Next live-port boundary (Godot Engineer)

**[RECONSTRUCTED]** The following is the **exact boundary** for the next movement-smoothing live port. A contributor can rely on this to know what the Godot Engineer is allowed to port.

- **Allowed:** (1) Wire the **movement-smoothing block** (Pacific Conflict.c:14179–14244) into the per-entity tick. (2) Run the 0x66e/0x672/0x66a (and 0x669 clear) update **only when** the current entity pointer equals SimCore’s **designated player entity** or **designated target entity** (mirror DAT_0001b738 and DAT_0001b888). (3) Use the proven formulas and delta rules (add full delta when |delta|&lt;8, else add delta&gt;&gt;3 with negative rounding); inputs from FUN_0000e42a, FUN_0000e468, FUN_0000e570, compute_local_34 are already in `flight_math.gd`. (4) Apply the 0x669 clear when in branch and (status_1a1 &amp; 0x40) and 0x66e==0.
- **Blocked [UNKNOWN]:** (1) Assigning semantic names to 0x66e, 0x672, 0x66a (e.g. axis or control surface). (2) Defining DAT_0001b888 beyond “second designated entity.” (3) Porting logic that depends on code paths outside FUN_0000e792 for these offsets (unverified). (4) Address mapping, loader runtime, and segment execution (see LOADER_CHAIN.md).

Reference: [NOTES.md](NOTES.md) “Doc sync: helper trio, ownership, next live-port”; [STRUCTS.md](STRUCTS.md) “Ownership branch status.”

---

## Current status summary

- **Phase A:** Skeleton done (tick order, RNG, trace/replay/diff). Helper trio reconstructed. [RECONSTRUCTED] Next: wire 0x66e/0x672/0x66a block with ownership guard. [INFERRED]
- **Phase B:** Not started; input and mission globals documented in STRUCTS.md and NOTES.md. [INFERRED]
- **Phase C:** Not started. [INFERRED]

**[UNKNOWN]** Target date for Phase B/C; depends on reverse-engineering depth and porting priorities.
