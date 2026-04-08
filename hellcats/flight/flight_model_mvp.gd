class_name FlightModelMvp
extends RefCounted

const AircraftStateScript := preload("res://hellcats/flight/aircraft_state.gd")

var config: Dictionary = {}
var _pitch_input: float = 0.0
var _roll_input: float = 0.0
var _yaw_input: float = 0.0

func configure(data: Dictionary) -> void:
	config = data.duplicate(true)

func reset() -> void:
	_pitch_input = 0.0
	_roll_input = 0.0
	_yaw_input = 0.0

func step(state, controls: Dictionary, delta: float) -> void:
	if state == null:
		return

	var limits: Dictionary = config.get("limits", {})
	var rates: Dictionary = config.get("control_rates", {})
	var speed_model: Dictionary = config.get("speed_model", {})
	var climb_model: Dictionary = config.get("climb_model", {})
	var assist: Dictionary = config.get("assist", {})
	var stall: Dictionary = config.get("stall", {})

	state.throttle_01 = clampf(
		state.throttle_01 + float(controls.get("throttle", 0.0)) * float(rates.get("throttle_change_per_s", 0.45)) * delta,
		0.0,
		1.0
	)

	var input_lerp := clampf(delta * 5.0, 0.0, 1.0)
	_pitch_input = lerpf(_pitch_input, float(controls.get("pitch", 0.0)), input_lerp)
	_roll_input = lerpf(_roll_input, float(controls.get("roll", 0.0)), input_lerp)
	_yaw_input = lerpf(_yaw_input, float(controls.get("yaw", 0.0)), input_lerp)

	state.pitch_deg = clampf(
		state.pitch_deg + _pitch_input * float(rates.get("pitch_rate_deg_s", 38.0)) * delta,
		-35.0,
		35.0
	)

	state.roll_deg = clampf(
		state.roll_deg + _roll_input * float(rates.get("roll_rate_deg_s", 70.0)) * delta,
		-65.0,
		65.0
	)
	if is_zero_approx(float(controls.get("roll", 0.0))):
		state.roll_deg = lerpf(state.roll_deg, 0.0, clampf(float(assist.get("roll_auto_level_gain", 0.2)) * delta, 0.0, 1.0))

	var speed_min: float = _first_float(speed_model.get("throttle_to_target_speed_mps", [45.0, 190.0]), 45.0)
	var speed_max: float = _second_float(speed_model.get("throttle_to_target_speed_mps", [45.0, 190.0]), 190.0)
	var target_speed: float = lerpf(speed_min, speed_max, state.throttle_01)
	var speed_error: float = target_speed - state.airspeed_mps
	var pitch_drag: float = absf(state.pitch_deg) * float(speed_model.get("drag_gain", 0.012))
	state.airspeed_mps += (speed_error * float(speed_model.get("speed_response_gain", 1.6)) - pitch_drag) * delta
	state.airspeed_mps = clampf(
		state.airspeed_mps,
		float(limits.get("min_speed_mps", 45.0)),
		float(limits.get("max_speed_mps", 190.0))
	)

	var bank_factor: float = clampf(state.roll_deg / 45.0, -1.5, 1.5)
	var yaw_rate: float = (_yaw_input * float(rates.get("yaw_rate_deg_s", 24.0))) + (bank_factor * state.airspeed_mps * float(assist.get("yaw_assist_gain", 0.3)))
	state.heading_deg = wrapf(state.heading_deg + yaw_rate * delta, 0.0, 360.0)
	state.bank_deg = state.roll_deg

	state.vertical_speed_mps = (state.pitch_deg * float(climb_model.get("pitch_to_vertical_speed_gain", 1.15))) - (float(climb_model.get("gravity_drop_mps2", 9.81)) * (1.0 - state.throttle_01) * 0.18)
	if state.airspeed_mps < float(stall.get("speed_mps_below", 55.0)):
		state.vertical_speed_mps -= 16.0
		state.stall_seconds += delta
	else:
		state.stall_seconds = maxf(0.0, state.stall_seconds - delta * 2.0)

	var heading_rad := deg_to_rad(state.heading_deg)
	var pitch_rad := deg_to_rad(state.pitch_deg)
	var horizontal_speed: float = cos(pitch_rad) * state.airspeed_mps
	state.position_m.x += sin(heading_rad) * horizontal_speed * delta
	state.position_m.z += cos(heading_rad) * horizontal_speed * delta
	state.position_m.y = clampf(
		state.position_m.y + state.vertical_speed_mps * delta,
		float(limits.get("min_altitude_m", 0.0)),
		float(limits.get("max_altitude_m", 5000.0))
	)

func _first_float(value: Variant, default_value: float) -> float:
	if value is Array and value.size() > 0:
		return float(value[0])
	return default_value

func _second_float(value: Variant, default_value: float) -> float:
	if value is Array and value.size() > 1:
		return float(value[1])
	return default_value
