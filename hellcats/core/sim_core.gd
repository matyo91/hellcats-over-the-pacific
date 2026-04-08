class_name SimCore
extends RefCounted
## Deterministic sim tick loop; no rendering.
## [RECONSTRUCTED] Update order matches FUN_000044e8 (Pacific Conflict.c:5096–5144): four entity passes + FUN_00006fb8.

const Rng68kScript := preload("res://hellcats/core/rng.gd")
const EntityStateScript := preload("res://hellcats/core/entity_state.gd")
const LoaderMetadataScript := preload("res://hellcats/core/loader_metadata.gd")
const FlightMathScript := preload("res://hellcats/core/flight_math.gd")

## [RECONSTRUCTED] Pass ids align with iteration order in FUN_000044e8 (array symbols).
const PASS_DAT_0001D4A4 := 1
const PASS_DAT_0001B5A4 := 2
const PASS_DAT_0001D0E4 := 3
const PASS_DAT_0001CBE4 := 4

## Mission state (proven offsets from DAT_0001b5a0)
var mission_phase_a8: int = 0
var mission_flag_ac: int = 0

## Entity arrays: order and counts match FUN_000044e8 (elements are EntityState).
var entity_array_1: Array = []  # DAT_0001d4a4, count DAT_0001c1e0
var entity_array_2: Array = []  # DAT_0001b5a4, count DAT_0001b734
var entity_array_3: Array = []  # DAT_0001d0e4, count DAT_0001c1dc
var entity_array_4: Array = []  # DAT_0001cbe4, count DAT_0001c1d8

## Loader-derived metadata table (ID00/loader chain). Proven targets only; no runtime relocation implied.
var loader_metadata: RefCounted

## Optional: shared RNG for sim (deterministic)
var rng: RefCounted

## Input packet for this frame (key/button events; enqueue per frame)
var input_packet: Dictionary = {}

## Per-frame trace (optional): each element is a Dictionary for that tick.
var trace_enabled: bool = false
var _trace: Array = []

## [RECONSTRUCTED] FUN_000044a4 second argument: 0 for arrays 1–2, 1 for arrays 3–4 (Pacific Conflict.c:5109–5139).
## Exposed for ordering tests and future FUN_0000435a path splits.
var last_pass_param_2: int = -1
var last_pass_id: int = -1

## Last tick ordering summary (always updated in tick()). See docs/contracts/tick_FUN_000044e8_contract.md
var last_tick_order: Dictionary = {}

## When true, last_tick_order includes player snapshots and rng_state (QA cost).
var tick_order_trace_enabled: bool = false

var _tick_count: int = 0

## [RECONSTRUCTED] Count of rng.next() calls this tick (RNG timing / parity). Reset each tick().
var _rng_draws_this_tick: int = 0

## [RECONSTRUCTED] Entities updated per FUN_000044a4 param_2 (0 vs 1) this tick. See docs/contracts/FUN_0000435a_contract.md.
var _param_2_entity_updates: Dictionary = {0: 0, 1: 0}

## Designated entity refs (DAT_0001b738 / DAT_0001b888). Only these receive 0x66e/0x672/0x66a updates (Pacific Conflict.c:14179).
var designated_player_entity: RefCounted = null
var designated_target_entity: RefCounted = null

func _init(initial_rng_seed: int = 0) -> void:
	rng = Rng68kScript.new()
	rng.seed(initial_rng_seed)
	loader_metadata = LoaderMetadataScript.new()

## One deterministic sim tick. No delta; fixed-step.
func tick() -> void:
	_tick_count += 1
	_rng_draws_this_tick = 0
	_param_2_entity_updates = {0: 0, 1: 0}
	designated_player_entity = entity_array_2[0] if entity_array_2.size() > 0 else null
	var input_used: Dictionary = input_packet.duplicate()
	var player_before: Variant = null
	if tick_order_trace_enabled and designated_player_entity != null:
		player_before = _snapshot_entity_order(designated_player_entity)

	if mission_flag_ac == 0:
		_call_05df8()

	var passes: Array = []
	var arrays_ran: bool = mission_phase_a8 > 0 and mission_phase_a8 < 6
	if arrays_ran:
		passes.append(_run_pass(PASS_DAT_0001D4A4, "DAT_0001d4a4", entity_array_1, 0))
		passes.append(_run_pass(PASS_DAT_0001B5A4, "DAT_0001b5a4", entity_array_2, 0))
		var player_after_pass_2: Variant = null
		if tick_order_trace_enabled and designated_player_entity != null:
			player_after_pass_2 = _snapshot_entity_order(designated_player_entity)
		passes.append(_run_pass(PASS_DAT_0001D0E4, "DAT_0001d0e4", entity_array_3, 1))
		passes.append(_run_pass(PASS_DAT_0001CBE4, "DAT_0001cbe4", entity_array_4, 1))
		_call_06fb8()
		last_tick_order = {
			"frame": _tick_count,
			"mission_flag_ac": mission_flag_ac,
			"mission_phase_a8": mission_phase_a8,
			"arrays_ran": true,
			"passes": passes,
			"designated_player_is_array2_index0": entity_array_2.size() > 0,
			"rng_draws_this_tick": _rng_draws_this_tick,
			"param_2_entity_updates": _param_2_entity_updates.duplicate(),
		}
		if tick_order_trace_enabled:
			last_tick_order["player_snapshot_before_tick"] = player_before
			last_tick_order["player_snapshot_after_pass_2"] = player_after_pass_2
			last_tick_order["player_snapshot_after_tick"] = (
				_snapshot_entity_order(designated_player_entity)
				if designated_player_entity != null
				else null
			)
			last_tick_order["rng_state_after_tick"] = rng.get_state()
	else:
		last_tick_order = {
			"frame": _tick_count,
			"mission_flag_ac": mission_flag_ac,
			"mission_phase_a8": mission_phase_a8,
			"arrays_ran": false,
			"passes": [],
			"designated_player_is_array2_index0": entity_array_2.size() > 0,
			"rng_draws_this_tick": _rng_draws_this_tick,
			"param_2_entity_updates": _param_2_entity_updates.duplicate(),
		}
		if tick_order_trace_enabled:
			last_tick_order["player_snapshot_before_tick"] = player_before
			last_tick_order["rng_state_after_tick"] = rng.get_state()

	if trace_enabled:
		_trace.append(
			{
				"frame": _tick_count,
				"input": input_used,
				"rng_state": rng.get_state(),
				"mission_phase_a8": mission_phase_a8,
				"mission_flag_ac": mission_flag_ac,
				"player": _snapshot_player(),
				"tick_order": last_tick_order.duplicate(true),
			}
		)

func get_last_tick_order() -> Dictionary:
	return last_tick_order

func _rng_consume() -> int:
	_rng_draws_this_tick += 1
	return rng.next()

## [INFERRED] Minimal fields for ordering QA; not full entity export.
func _snapshot_entity_order(entity: RefCounted) -> Dictionary:
	if entity == null:
		return {}
	return {
		"movement_66e": entity.get_field("movement_66e"),
		"movement_672": entity.get_s16_field("movement_672"),
		"movement_66a": entity.get_field("movement_66a"),
	}

func _run_pass(pass_id: int, dat_symbol: String, arr: Array, param_2: int) -> Dictionary:
	last_pass_id = pass_id
	last_pass_param_2 = param_2
	_update_entity_array(arr, param_2, pass_id)
	return {"pass_id": pass_id, "dat": dat_symbol, "param_2": param_2, "count": arr.size()}

## Placeholder: FUN_00005df8 (mission flag_ac path).
func _call_05df8() -> void:
	pass

## Placeholder: FUN_00006fb8 (after all four arrays updated).
func _call_06fb8() -> void:
	pass

## Update one array; param_2 is 0 or 1 (FUN_000044a4 second arg).
func _update_entity_array(arr: Array, param_2: int, pass_id: int) -> void:
	for entity in arr:
		_param_2_entity_updates[param_2] = int(_param_2_entity_updates.get(param_2, 0)) + 1
		_update_single_entity(entity as RefCounted, param_2, pass_id)

## Placeholder: per-entity update (FUN_000044a4 → FUN_0000435a / FUN_0000e792).
func _update_single_entity(entity: RefCounted, param_2: int, _pass_id: int) -> void:
	if entity == null:
		return
	_apply_randomized_control_offsets(entity)
	_apply_control_gate_accumulator(entity)
	_apply_control_threshold_decrement(entity)
	_apply_movement_smoothing(entity)

func _apply_randomized_control_offsets(entity: RefCounted) -> void:
	var flags_685: int = entity.get_u8_field("flags_685")
	if (flags_685 & 0x04) != 0:
		var movement_662: int = entity.get_s16_field("movement_662") + (_rng_consume() & 0x7F) - 0x40
		entity.set_s16_field("movement_662", _clamp_s16(movement_662, -0x200, 0x200))
	if (flags_685 & 0x08) != 0:
		var movement_666: int = entity.get_s16_field("movement_666") + (_rng_consume() & 0x7F) - 0x40
		entity.set_s16_field("movement_666", _clamp_s16(movement_666, -0x140, 0x140))
	if (entity.get_u16_field("status_1a1") & 0x0001) != 0:
		entity.set_s16_field("movement_662", 0)
		entity.set_s16_field("movement_666", -0x80)

func _clamp_s16(value: int, lower: int, upper: int) -> int:
	return mini(maxi(value, lower), upper)

func _apply_control_gate_accumulator(entity: RefCounted) -> void:
	var control_accumulator: int = entity.get_s8_field("field_19a")
	var flags_685: int = entity.get_u8_field("flags_685")
	var status_1a1: int = entity.get_u16_field("status_1a1")
	var status_1a3: int = entity.get_s16_field("status_1a3")
	var count_67d: int = entity.get_s8_field("weapon_count_67d")
	var count_67e: int = entity.get_s8_field("weapon_count_67e")
	var gate_enabled := (((flags_685 & 0x40) == 0) or status_1a3 != 0) and ((status_1a1 & 0x0300) == 0) and (count_67d != 0 or count_67e != 0)
	entity.set_u8_field("movement_669", 1 if gate_enabled else 0)
	if not gate_enabled:
		control_accumulator = 0
	elif (flags_685 & 0x80) != 0:
		control_accumulator = _half_toward_zero(control_accumulator)
	entity.set_s16_field("status_1a0", entity.get_s16_field("status_1a0") + control_accumulator)

func _half_toward_zero(value: int) -> int:
	if value < 0:
		value += 1
	return value >> 1

func _apply_control_threshold_decrement(entity: RefCounted) -> void:
	var template: RefCounted = entity.external_template
	if template == null:
		return
	var threshold: int = template.get_s16_field("field_1e")
	var accumulator: int = entity.get_s16_field("status_1a0")
	if threshold >= accumulator:
		return
	entity.set_s16_field("status_1a0", accumulator - threshold)
	var count_67d: int = entity.get_s8_field("weapon_count_67d")
	var count_67e: int = entity.get_s8_field("weapon_count_67e")
	if ((_rng_consume() & 1) == 0) or count_67d == 0:
		if count_67e != 0:
			entity.set_s8_field("weapon_count_67e", count_67e - 1)
	else:
		entity.set_s8_field("weapon_count_67d", count_67d - 1)

## Movement-smoothing block (Pacific Conflict.c:14179-14244). Only for designated player or target entity.
func _apply_movement_smoothing(entity: RefCounted) -> void:
	if entity != designated_player_entity and entity != designated_target_entity:
		return
	var template: RefCounted = entity.external_template
	if template == null:
		return
	var i_var20: int = entity.get_field("movement_62a") >> 2
	var pos_1c: int = entity.get_field("pos_1c")
	var e42a_out: int = FlightMathScript.fun_0000e42a(pos_1c)
	var s_var15: int = (e42a_out & 0xFFFF)
	if s_var15 >= 0x8000:
		s_var15 -= 0x1_0000
	var local_26: int = FlightMathScript.fun_0000e570(template.get_field("field_38"), s_var15)
	var flags_685: int = entity.get_u8_field("flags_685")
	var status_1a1: int = entity.get_u16_field("status_1a1")
	var status_1a3: int = entity.get_s16_field("status_1a3")
	var count_67d: int = entity.get_s8_field("weapon_count_67d")
	var count_67e: int = entity.get_s8_field("weapon_count_67e")
	var gate_enabled: bool = (((flags_685 & 0x40) == 0) or status_1a3 != 0) and ((status_1a1 & 0x0300) == 0) and (count_67d != 0 or count_67e != 0)
	var s_var21: int = entity.get_s8_field("field_19a") if gate_enabled else 0
	if gate_enabled and (flags_685 & 0x80) != 0:
		s_var21 = _half_toward_zero(s_var21)
	var movement_666: int = entity.get_s16_field("movement_666")
	var denom: int = (s_var15 + 0xa25) >> 5
	var local_46: int = 0
	if denom != 0:
		var div_val: int = 0x5e50 / denom
		if div_val >= 0x8000:
			div_val = (div_val & 0xFFFF) - 0x1_0000
		local_46 = (div_val * s_var21 * movement_666) >> 5
		var current_66e: int = _entity_s32(entity, "movement_66e")
		var delta_66e: int = local_46 - current_66e
		entity.set_field("movement_66e", FlightMathScript.add_delta_smoothed_int(current_66e, delta_66e))
	var source_672: int = 0
	if entity.get_u8_field("movement_669") != 0 and (status_1a1 & 0x4300) == 0:
		source_672 = (local_26 >> 9)
		if source_672 >= 0x8000:
			source_672 -= 0x1_0000
	if (flags_685 & 0x80) != 0:
		source_672 = _half_toward_zero(source_672)
	var current_672: int = entity.get_s16_field("movement_672")
	var delta_672: int = source_672 - current_672
	entity.set_s16_field("movement_672", FlightMathScript.add_delta_smoothed_s16(current_672, delta_672))
	var local_42: int = (i_var20 << 0x11) / 0x1c20
	var adj: int = local_42 - local_46
	if adj < 0:
		adj += 1
	var target_66a: int = local_46 + (adj >> 1)
	var current_66a: int = _entity_s32(entity, "movement_66a")
	var delta_66a: int = target_66a - current_66a
	entity.set_field("movement_66a", FlightMathScript.add_delta_smoothed_int(current_66a, delta_66a))
	if (status_1a1 & 0x40) != 0 and entity.get_field("movement_66e") == 0:
		entity.set_u8_field("movement_669", 0)

func _entity_s32(entity: RefCounted, key: String) -> int:
	var v: int = entity.get_field(key) & 0xFFFFFFFF
	return v - 0x1_0000_0000 if v >= 0x8000_0000 else v

func compute_template_field_40_adjustment(entity: RefCounted) -> int:
	var template: RefCounted = entity.external_template
	if template == null:
		return 0
	return FlightMathScript.compute_template_field_40_adjustment(
		template.get_s16_field("field_40"),
		entity.get_s8_field("direction_char_679")
	)

## Snapshot first entity in entity_array_2 (player) as proven-offset dict; null if none.
func _snapshot_player() -> Variant:
	if entity_array_2.is_empty():
		return null
	var entity: RefCounted = entity_array_2[0]
	var out: Dictionary = {}
	for key in EntityStateScript.OFFSETS:
		var v: int = entity.get_field(key)
		if v != 0:
			out[key] = v
	return out if out.size() > 0 else null

func get_tick_count() -> int:
	return _tick_count

## Return a copy of the trace buffer (for tests or logging). Clear with clear_trace().
func get_trace() -> Array:
	return _trace.duplicate()

## Last trace record (after latest tick); for TraceWriter. Returns null if none.
func get_last_trace_record() -> Variant:
	if _trace.is_empty():
		return null
	return _trace[_trace.size() - 1]

func clear_trace() -> void:
	_trace.clear()

## Push a key/action for this frame (consumed in tick).
func push_input(action: String, value: int) -> void:
	input_packet[action] = value

## Clear input after tick (call at start of tick or end).
func clear_input() -> void:
	input_packet.clear()

func load_loader_metadata_from_json_text(text: String) -> void:
	loader_metadata = LoaderMetadataScript.from_json_text(text)

func load_loader_metadata_from_file(path: String) -> void:
	loader_metadata = LoaderMetadataScript.from_file(path)

func resolve_loader_target(segment_id: int, stored_tail: int) -> Dictionary:
	return loader_metadata.get_target(segment_id, stored_tail)

## Resolve loader target by ID00 jump-table entry offset (A5-relative; LOADER_CHAIN §5).
func resolve_loader_target_by_id00_entry_offset(id00_entry_offset: int) -> Dictionary:
	return loader_metadata.get_target_by_id00_entry_offset(id00_entry_offset)

func get_loader_target_count() -> int:
	return loader_metadata.get_target_count()
