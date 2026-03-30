extends SceneTree
## Focused tests for the movement-smoothing slice (Pacific Conflict.c:14179-14244).
## Evidence: NOTES.md ownership branch; STRUCTS.md 0x66e/0x672/0x66a; ROADMAP next live-port boundary.

const EntityStateScript := preload("res://hellcats/core/entity_state.gd")
const EntityTemplateScript := preload("res://hellcats/core/entity_template.gd")
const FlightMathScript := preload("res://hellcats/core/flight_math.gd")
const SimCoreScript := preload("res://hellcats/core/sim_core.gd")

func _init() -> void:
	var ok := true
	ok = _test_delta_smoothed_int() and ok
	ok = _test_delta_smoothed_s16() and ok
	ok = _test_669_clear_when_66e_zero_and_1a1_bit40() and ok
	ok = _test_designated_target_also_receives_smoothing() and ok
	print("Result: %s" % ("ALL PASS" if ok else "SOME FAIL"))
	quit(0 if ok else 1)

func _test_delta_smoothed_int() -> bool:
	if FlightMathScript.add_delta_smoothed_int(0, 5) != 5:
		print("FAIL add_delta_smoothed_int |delta|<8 add full")
		return false
	if FlightMathScript.add_delta_smoothed_int(0, -3) != -3:
		print("FAIL add_delta_smoothed_int negative full")
		return false
	if FlightMathScript.add_delta_smoothed_int(100, 20) != 102:
		print("FAIL add_delta_smoothed_int delta>>3 got %d want 102" % FlightMathScript.add_delta_smoothed_int(100, 20))
		return false
	if FlightMathScript.add_delta_smoothed_int(100, -24) != 97:
		var got := FlightMathScript.add_delta_smoothed_int(100, -24)
		print("FAIL add_delta_smoothed_int negative >>3 got %d want 97" % got)
		return false
	print("PASS delta smoothed int")
	return true

func _test_delta_smoothed_s16() -> bool:
	if FlightMathScript.add_delta_smoothed_s16(0, 4) != 4:
		print("FAIL add_delta_smoothed_s16 full delta")
		return false
	if FlightMathScript.add_delta_smoothed_s16(100, 16) != 102:
		print("FAIL add_delta_smoothed_s16 >>3")
		return false
	print("PASS delta smoothed s16")
	return true

func _test_669_clear_when_66e_zero_and_1a1_bit40() -> bool:
	var sim = SimCoreScript.new(0x1111)
	sim.mission_phase_a8 = 1
	var template = EntityTemplateScript.new()
	template.set_s16_field("field_38", 0x80)
	var player = EntityStateScript.new()
	player.external_template = template
	player.set_field("movement_62a", 0x800)
	player.set_field("pos_1c", 0x00008000)
	player.set_field("movement_66e", 0)
	player.set_u8_field("movement_669", 1)
	player.set_u16_field("status_1a1", 0x40)
	sim.entity_array_2.append(player)
	sim.tick()
	if player.get_u8_field("movement_669") != 0:
		print("FAIL 0x669 should be cleared when 0x66e==0 and status_1a1&0x40")
		return false
	print("PASS 0x669 clear in branch")
	return true

func _test_designated_target_also_receives_smoothing() -> bool:
	var sim = SimCoreScript.new(0x2222)
	sim.mission_phase_a8 = 1
	var template = EntityTemplateScript.new()
	template.set_s16_field("field_38", 0x200)
	var player = EntityStateScript.new()
	player.external_template = template
	player.set_field("movement_62a", 0x400)
	player.set_field("pos_1c", 0x00020000)
	player.set_field("movement_66e", 0)
	sim.entity_array_2.append(player)
	var target = EntityStateScript.new()
	target.external_template = template
	target.set_field("movement_62a", 0x400)
	target.set_field("pos_1c", 0x00020000)
	target.set_field("movement_66e", 50)
	target.set_s16_field("movement_672", 5)
	target.set_field("movement_66a", 100)
	sim.entity_array_1.append(target)
	sim.designated_target_entity = target
	sim.tick()
	if target.get_field("movement_66e") == 50 and target.get_s16_field("movement_672") == 5 and target.get_field("movement_66a") == 100:
		print("FAIL designated target should receive 0x66e/0x672/0x66a updates")
		return false
	print("PASS designated target receives smoothing")
	return true
