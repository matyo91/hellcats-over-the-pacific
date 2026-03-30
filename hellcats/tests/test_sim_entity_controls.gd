extends SceneTree

const EntityStateScript := preload("res://hellcats/core/entity_state.gd")
const EntityTemplateScript := preload("res://hellcats/core/entity_template.gd")
const SimCoreScript := preload("res://hellcats/core/sim_core.gd")

func _init() -> void:
	var ok := true
	ok = _test_rng_control_offsets() and ok
	ok = _test_status_override() and ok
	ok = _test_control_gate_accumulator_enabled() and ok
	ok = _test_control_gate_accumulator_disabled() and ok
	ok = _test_control_gate_accumulator_halved_for_negative_flag() and ok
	ok = _test_threshold_decrement_prefers_67e_when_67d_zero() and ok
	ok = _test_threshold_decrement_uses_rng_bit_for_count_choice() and ok
	ok = _test_template_field_40_adjustment() and ok
	ok = _test_movement_smoothing_only_for_designated() and ok
	print("Result: %s" % ("ALL PASS" if ok else "SOME FAIL"))
	quit(0 if ok else 1)

func _test_rng_control_offsets() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	entity.set_u8_field("flags_685", 0x0C)
	sim.entity_array_1.append(entity)
	sim.tick()

	var expected_662 := _simulate_control_delta(0x1234, -0x200, 0x200)
	var expected_666 := _simulate_control_delta(_lcg_step(0x1234), -0x140, 0x140)
	var got_662 := entity.get_s16_field("movement_662")
	var got_666 := entity.get_s16_field("movement_666")

	if got_662 != expected_662:
		print("FAIL RNG control movement_662 got %d want %d" % [got_662, expected_662])
		return false
	if got_666 != expected_666:
		print("FAIL RNG control movement_666 got %d want %d" % [got_666, expected_666])
		return false
	print("PASS RNG control offsets")
	return true

func _test_status_override() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	entity.set_u8_field("flags_685", 0x0C)
	entity.set_u16_field("status_1a1", 0x0001)
	entity.set_s16_field("movement_662", 0x123)
	entity.set_s16_field("movement_666", 0x77)
	sim.entity_array_1.append(entity)
	sim.tick()

	if entity.get_s16_field("movement_662") != 0:
		print("FAIL status override movement_662")
		return false
	if entity.get_s16_field("movement_666") != -0x80:
		print("FAIL status override movement_666")
		return false
	print("PASS status override")
	return true

func _test_control_gate_accumulator_enabled() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	entity.set_s8_field("field_19a", 6)
	entity.set_u8_field("weapon_count_67d", 1)
	entity.set_s16_field("status_1a0", 10)
	sim.entity_array_1.append(entity)
	sim.tick()

	if entity.get_u8_field("movement_669") != 1:
		print("FAIL control gate enabled movement_669")
		return false
	if entity.get_s16_field("status_1a0") != 16:
		print("FAIL control gate enabled status_1a0 got %d want 16" % entity.get_s16_field("status_1a0"))
		return false
	print("PASS control gate enabled")
	return true

func _test_control_gate_accumulator_disabled() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	entity.set_s8_field("field_19a", 6)
	entity.set_u16_field("status_1a1", 0x0100)
	entity.set_u8_field("weapon_count_67d", 1)
	entity.set_s16_field("status_1a0", 10)
	sim.entity_array_1.append(entity)
	sim.tick()

	if entity.get_u8_field("movement_669") != 0:
		print("FAIL control gate disabled movement_669")
		return false
	if entity.get_s16_field("status_1a0") != 10:
		print("FAIL control gate disabled status_1a0 got %d want 10" % entity.get_s16_field("status_1a0"))
		return false
	print("PASS control gate disabled")
	return true

func _test_control_gate_accumulator_halved_for_negative_flag() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	entity.set_s8_field("field_19a", -5)
	entity.set_u8_field("flags_685", 0x80)
	entity.set_u8_field("weapon_count_67e", 1)
	sim.entity_array_1.append(entity)
	sim.tick()

	if entity.get_u8_field("movement_669") != 1:
		print("FAIL control gate halved movement_669")
		return false
	if entity.get_s16_field("status_1a0") != -2:
		print("FAIL control gate halved status_1a0 got %d want -2" % entity.get_s16_field("status_1a0"))
		return false
	print("PASS control gate halved")
	return true

func _test_threshold_decrement_prefers_67e_when_67d_zero() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	var template = EntityTemplateScript.new()
	template.set_s16_field("field_1e", 4)
	entity.external_template = template
	entity.set_s16_field("status_1a0", 9)
	entity.set_s8_field("weapon_count_67d", 0)
	entity.set_s8_field("weapon_count_67e", 3)
	sim.entity_array_1.append(entity)
	sim.tick()

	if entity.get_s16_field("status_1a0") != 5:
		print("FAIL threshold decrement status_1a0 got %d want 5" % entity.get_s16_field("status_1a0"))
		return false
	if entity.get_s8_field("weapon_count_67e") != 2:
		print("FAIL threshold decrement 67e got %d want 2" % entity.get_s8_field("weapon_count_67e"))
		return false
	print("PASS threshold decrement with 67d zero")
	return true

func _test_threshold_decrement_uses_rng_bit_for_count_choice() -> bool:
	var sim = SimCoreScript.new(0x1234)
	sim.mission_phase_a8 = 1
	var entity = EntityStateScript.new()
	var template = EntityTemplateScript.new()
	template.set_s16_field("field_1e", 3)
	entity.external_template = template
	entity.set_s16_field("status_1a0", 8)
	entity.set_s8_field("weapon_count_67d", 2)
	entity.set_s8_field("weapon_count_67e", 2)
	sim.entity_array_1.append(entity)
	sim.tick()

	var use_67e := (_simulate_rng_low_bit(0x1234) == 0)
	if entity.get_s16_field("status_1a0") != 5:
		print("FAIL threshold RNG branch status_1a0 got %d want 5" % entity.get_s16_field("status_1a0"))
		return false
	if use_67e:
		if entity.get_s8_field("weapon_count_67e") != 1 or entity.get_s8_field("weapon_count_67d") != 2:
			print("FAIL threshold RNG branch expected 67e decrement")
			return false
	else:
		if entity.get_s8_field("weapon_count_67d") != 1 or entity.get_s8_field("weapon_count_67e") != 2:
			print("FAIL threshold RNG branch expected 67d decrement")
			return false
	print("PASS threshold decrement RNG branch")
	return true

func _test_template_field_40_adjustment() -> bool:
	var sim = SimCoreScript.new(0x1234)
	var entity = EntityStateScript.new()
	var template = EntityTemplateScript.new()
	template.set_s16_field("field_40", 5)
	entity.external_template = template

	entity.set_s8_field("direction_char_679", 0x2D)
	if sim.compute_template_field_40_adjustment(entity) != 5:
		print("FAIL template field_40 adjustment for '-'")
		return false

	entity.set_s8_field("direction_char_679", 0)
	if sim.compute_template_field_40_adjustment(entity) != 2:
		print("FAIL template field_40 adjustment halve positive")
		return false

	template.set_s16_field("field_40", -5)
	if sim.compute_template_field_40_adjustment(entity) != -2:
		print("FAIL template field_40 adjustment halve negative")
		return false

	print("PASS template field_40 adjustment")
	return true

func _simulate_control_delta(seed: int, lower: int, upper: int) -> int:
	var state := _lcg_step(seed)
	var delta := ((state >> 16) & 0x7FFF) & 0x7F
	delta -= 0x40
	return mini(maxi(delta, lower), upper)

func _lcg_step(state: int) -> int:
	return int((int(state) * 0x41c64e6d + 0x3039) & 0xFFFFFFFF)

func _simulate_rng_low_bit(seed: int) -> int:
	var state := _lcg_step(seed)
	return ((state >> 16) & 0x7FFF) & 1

func _test_movement_smoothing_only_for_designated() -> bool:
	var sim = SimCoreScript.new(0x9999)
	sim.mission_phase_a8 = 1
	var template = EntityTemplateScript.new()
	template.set_s16_field("field_38", 0x100)
	template.set_s16_field("field_3c", 100)
	template.set_s16_field("field_3e", 50)
	var non_player = EntityStateScript.new()
	non_player.external_template = template
	non_player.set_field("movement_62a", 0x1000)
	non_player.set_field("pos_1c", 0x00010000)
	non_player.set_field("movement_66e", 100)
	non_player.set_s16_field("movement_672", 10)
	non_player.set_field("movement_66a", 200)
	sim.entity_array_1.append(non_player)
	var player = EntityStateScript.new()
	player.external_template = template
	player.set_field("movement_62a", 0x1000)
	player.set_field("pos_1c", 0x00010000)
	player.set_s16_field("movement_666", 1)
	player.set_field("movement_66e", 100)
	player.set_s16_field("movement_672", 10)
	player.set_field("movement_66a", 200)
	sim.entity_array_2.append(player)
	sim.tick()
	if non_player.get_field("movement_66e") != 100 or non_player.get_s16_field("movement_672") != 10 or non_player.get_field("movement_66a") != 200:
		print("FAIL movement smoothing applied to non-designated entity")
		return false
	var pe: RefCounted = sim.designated_player_entity
	if pe != player:
		print("FAIL designated player should be array_2[0]")
		return false
	if player.get_field("movement_66e") == 100 and player.get_s16_field("movement_672") == 10 and player.get_field("movement_66a") == 200:
		print("FAIL movement smoothing should have updated designated player")
		return false
	print("PASS movement smoothing only for designated")
	return true
