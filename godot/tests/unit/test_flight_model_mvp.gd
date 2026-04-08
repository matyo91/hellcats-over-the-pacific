extends RefCounted

## Deterministic flight-model scenarios (no Input): FUN_0000e792 smoothing path via FlightMath.

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const AircraftStateScript := preload("res://hellcats/flight/aircraft_state.gd")
const FlightModelMvpScript := preload("res://hellcats/flight/flight_model_mvp.gd")

func run() -> bool:
	var ok := true
	ok = _scenario_straight() and ok
	ok = _scenario_sustained_turn_left() and ok
	ok = _scenario_climb() and ok
	ok = _scenario_descend() and ok
	ok = _scenario_throttle_sequence() and ok
	ok = _scenario_smoothing_nonzero_when_commanded() and ok
	return ok

func _default_config() -> Dictionary:
	return {
		"limits":
		{"min_altitude_m": 0.0, "max_altitude_m": 5000.0, "min_speed_mps": 45.0, "max_speed_mps": 190.0},
		"control_rates":
		{
			"pitch_rate_deg_s": 38.0,
			"roll_rate_deg_s": 70.0,
			"yaw_rate_deg_s": 24.0,
			"throttle_change_per_s": 0.45
		},
		"speed_model":
		{
			"throttle_to_target_speed_mps": [45.0, 190.0],
			"speed_response_gain": 1.6,
			"drag_gain": 0.012
		},
		"climb_model": {"pitch_to_vertical_speed_gain": 1.15, "gravity_drop_mps2": 9.81},
		"assist": {"yaw_assist_gain": 0.3, "roll_auto_level_gain": 0.2},
		"stall": {"speed_mps_below": 55.0},
		"movement_smoothing": {"pitch_max_int": 8192, "roll_max_int": 8192, "yaw_max_int": 8192},
	}

func _step_n(model, state, controls: Dictionary, dt: float, n: int) -> void:
	for _i in n:
		model.step(state, controls, dt)

func _scenario_straight() -> bool:
	var state := AircraftStateScript.new()
	state.apply_spawn({"position_m": [0.0, 1200.0, 0.0], "heading_deg": 90.0, "airspeed_mps": 95.0, "throttle_01": 0.72})
	var model := FlightModelMvpScript.new()
	model.configure(_default_config())
	var h0 := state.heading_deg
	_step_n(model, state, {"pitch": 0.0, "roll": 0.0, "yaw": 0.0, "throttle": 0.0}, 0.05, 40)
	var ok := Assertions.assert_true(absf(state.pitch_deg) < 2.0, "straight: pitch stays small")
	ok = Assertions.assert_true(absf(angle_delta_deg(h0, state.heading_deg)) < 3.0, "straight: heading nearly constant") and ok
	return ok

func _scenario_sustained_turn_left() -> bool:
	var state := AircraftStateScript.new()
	state.apply_spawn({"position_m": [0.0, 1200.0, 0.0], "heading_deg": 0.0, "airspeed_mps": 95.0, "throttle_01": 0.72})
	var model := FlightModelMvpScript.new()
	model.configure(_default_config())
	var h0 := state.heading_deg
	_step_n(model, state, {"pitch": 0.0, "roll": -1.0, "yaw": 0.0, "throttle": 0.0}, 0.05, 60)
	var dh := absf(angle_delta_deg(h0, state.heading_deg))
	var ok := Assertions.assert_true(dh > 5.0, "left turn: heading changes materially")
	return ok

func _scenario_climb() -> bool:
	var state := AircraftStateScript.new()
	state.apply_spawn({"position_m": [0.0, 1200.0, 0.0], "heading_deg": 0.0, "airspeed_mps": 95.0, "throttle_01": 0.85})
	var model := FlightModelMvpScript.new()
	model.configure(_default_config())
	var y0 := state.position_m.y
	_step_n(model, state, {"pitch": 1.0, "roll": 0.0, "yaw": 0.0, "throttle": 0.0}, 0.05, 50)
	var ok := Assertions.assert_true(state.position_m.y > y0 + 5.0, "climb: altitude increases")
	return ok

func _scenario_descend() -> bool:
	var state := AircraftStateScript.new()
	state.apply_spawn({"position_m": [0.0, 1200.0, 0.0], "heading_deg": 0.0, "airspeed_mps": 95.0, "throttle_01": 0.72})
	var model := FlightModelMvpScript.new()
	model.configure(_default_config())
	var y0 := state.position_m.y
	_step_n(model, state, {"pitch": -1.0, "roll": 0.0, "yaw": 0.0, "throttle": 0.0}, 0.05, 50)
	var ok := Assertions.assert_true(state.position_m.y < y0 - 5.0, "descend: altitude decreases")
	return ok

func _scenario_throttle_sequence() -> bool:
	var state := AircraftStateScript.new()
	state.apply_spawn({"position_m": [0.0, 1200.0, 0.0], "heading_deg": 0.0, "airspeed_mps": 95.0, "throttle_01": 0.5})
	var model := FlightModelMvpScript.new()
	model.configure(_default_config())
	_step_n(model, state, {"pitch": 0.0, "roll": 0.0, "yaw": 0.0, "throttle": 1.0}, 0.05, 20)
	var t_hi := state.throttle_01
	_step_n(model, state, {"pitch": 0.0, "roll": 0.0, "yaw": 0.0, "throttle": -1.0}, 0.05, 20)
	var ok := Assertions.assert_true(t_hi > 0.55, "throttle seq: up raises throttle")
	ok = Assertions.assert_true(state.throttle_01 < t_hi - 0.05, "throttle seq: down lowers throttle") and ok
	return ok

func _scenario_smoothing_nonzero_when_commanded() -> bool:
	var state := AircraftStateScript.new()
	state.apply_spawn({"position_m": [0.0, 1200.0, 0.0], "heading_deg": 0.0, "airspeed_mps": 95.0, "throttle_01": 0.72})
	var model := FlightModelMvpScript.new()
	model.configure(_default_config())
	model.step(state, {"pitch": 1.0, "roll": 0.0, "yaw": 0.0, "throttle": 0.0}, 0.05)
	var ok := Assertions.assert_true(state.movement_66e != 0, "smoothing: movement_66e reacts to pitch cmd")
	return ok

static func angle_delta_deg(from_deg: float, to_deg: float) -> float:
	var d := fposmod(to_deg - from_deg + 540.0, 360.0) - 180.0
	return d
