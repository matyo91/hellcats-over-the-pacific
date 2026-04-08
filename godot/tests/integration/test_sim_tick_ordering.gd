extends RefCounted

## Validates FUN_000044e8-aligned pass order and param_2 pattern in SimCore (deterministic).

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const SimCoreScript := preload("res://hellcats/core/sim_core.gd")
const EntityStateScript := preload("res://hellcats/core/entity_state.gd")

func run() -> bool:
	var ok := true
	ok = _test_pass_order_and_param2() and ok
	ok = _test_phase_gate_skips_arrays() and ok
	ok = _test_multi_tick_stable_order() and ok
	ok = _test_trace_includes_tick_order() and ok
	return ok

func _test_pass_order_and_param2() -> bool:
	var sim := SimCoreScript.new(0xABCDEF)
	sim.mission_phase_a8 = 1
	sim.mission_flag_ac = 1
	for _i in 4:
		sim.entity_array_1.append(EntityStateScript.new())
		sim.entity_array_2.append(EntityStateScript.new())
		sim.entity_array_3.append(EntityStateScript.new())
		sim.entity_array_4.append(EntityStateScript.new())
	sim.tick()
	var order: Dictionary = sim.get_last_tick_order()
	var passes: Array = order.get("passes", [])
	var ok := Assertions.assert_true(passes.size() == 4, "tick_order: four passes")
	ok = Assertions.assert_true(int(passes[0].get("pass_id", -1)) == 1, "pass 1 id (PASS_DAT_0001D4A4)") and ok
	ok = Assertions.assert_true(int(passes[0].get("param_2", -99)) == 0, "pass 1 param_2 == 0") and ok
	ok = Assertions.assert_true(int(passes[1].get("param_2", -99)) == 0, "pass 2 param_2 == 0") and ok
	ok = Assertions.assert_true(int(passes[2].get("param_2", -99)) == 1, "pass 3 param_2 == 1") and ok
	ok = Assertions.assert_true(int(passes[3].get("param_2", -99)) == 1, "pass 4 param_2 == 1") and ok
	ok = Assertions.assert_true(bool(order.get("arrays_ran", false)), "arrays_ran") and ok
	return ok

func _test_phase_gate_skips_arrays() -> bool:
	var sim := SimCoreScript.new(0x1111)
	sim.mission_phase_a8 = 0
	sim.mission_flag_ac = 1
	sim.tick()
	var order: Dictionary = sim.get_last_tick_order()
	var ok := Assertions.assert_true(not bool(order.get("arrays_ran", true)), "phase gate: arrays not run")
	ok = Assertions.assert_true((order.get("passes", []) as Array).is_empty(), "phase gate: no passes") and ok
	return ok

func _test_multi_tick_stable_order() -> bool:
	var sim := SimCoreScript.new(0x2222)
	sim.mission_phase_a8 = 3
	sim.mission_flag_ac = 1
	sim.entity_array_2.append(EntityStateScript.new())
	for _t in 10:
		sim.tick()
		var p: Array = sim.get_last_tick_order().get("passes", []) as Array
		if p.size() != 4:
			print("FAIL multi_tick: expected 4 passes got %d" % p.size())
			return false
		if int(p[2].get("param_2", -1)) != 1:
			print("FAIL multi_tick: pass 3 param_2")
			return false
	print("PASS multi_tick stable order")
	return true

func _test_trace_includes_tick_order() -> bool:
	var sim := SimCoreScript.new(0x3333)
	sim.mission_phase_a8 = 2
	sim.mission_flag_ac = 1
	sim.trace_enabled = true
	sim.entity_array_2.append(EntityStateScript.new())
	sim.tick()
	var rec: Variant = sim.get_last_trace_record()
	var ok := Assertions.assert_true(rec is Dictionary, "trace record exists")
	if not ok:
		return false
	var nested: Variant = (rec as Dictionary).get("tick_order", {})
	ok = Assertions.assert_true(nested is Dictionary and (nested as Dictionary).has("passes"), "trace has tick_order.passes") and ok
	return ok
