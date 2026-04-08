extends RefCounted

## Deterministic validation (no Input singleton): FUN_0000740a-aligned contract via compute_outputs.

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const PlayerInputMapScript := preload("res://hellcats/flight/player_input_map.gd")

func run() -> bool:
	var ok := true
	ok = _scenario_hold_pitch() and ok
	ok = _scenario_tap_roll() and ok
	ok = _scenario_throttle_steps() and ok
	ok = _scenario_gate_inactive() and ok
	return ok

func _scenario_hold_pitch() -> bool:
	## Hold pitch up for N conceptual ticks: axis = 1.0
	var c := PlayerInputMapScript.compute_outputs(true, 1.0, 0.0, 0.0, 0.0, false, false)
	var ok := Assertions.assert_equal(c.get("pitch", -99.0), 1.0, "hold_pitch: pitch axis")
	ok = Assertions.assert_equal(c.get("throttle_impulse", -99.0), 0.0, "hold_pitch: no step") and ok
	return ok

func _scenario_tap_roll() -> bool:
	## Tap left: one tick left -1, neutral 0
	var tap := PlayerInputMapScript.compute_outputs(true, 0.0, -1.0, 0.0, 0.0, false, false)
	var ok := Assertions.assert_equal(tap.get("roll", 0.0), -1.0, "tap_roll: roll -1")
	var neutral := PlayerInputMapScript.compute_outputs(true, 0.0, 0.0, 0.0, 0.0, false, false)
	ok = Assertions.assert_equal(neutral.get("roll", -99.0), 0.0, "tap_roll: roll neutral") and ok
	return ok

func _scenario_throttle_steps() -> bool:
	var up := PlayerInputMapScript.compute_outputs(true, 0.0, 0.0, 0.0, 0.0, true, false)
	var down := PlayerInputMapScript.compute_outputs(true, 0.0, 0.0, 0.0, 0.0, false, true)
	var ok := Assertions.assert_equal(
		up.get("throttle_impulse", 0.0),
		PlayerInputMapScript.THROTTLE_STEP_IMPULSE,
		"throttle: step up impulse"
	)
	ok = Assertions.assert_equal(
		down.get("throttle_impulse", 0.0),
		-PlayerInputMapScript.THROTTLE_STEP_IMPULSE,
		"throttle: step down impulse"
	) and ok
	return ok

func _scenario_gate_inactive() -> bool:
	var c := PlayerInputMapScript.compute_outputs(false, 1.0, -1.0, 1.0, 1.0, true, true)
	var ok := Assertions.assert_equal(c.get("pitch", -1.0), 0.0, "gated: pitch zero")
	ok = Assertions.assert_equal(c.get("throttle_impulse", -1.0), 0.0, "gated: no impulse") and ok
	return ok
