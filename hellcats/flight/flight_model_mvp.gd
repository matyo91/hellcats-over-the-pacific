class_name FlightModelMvp
extends RefCounted

const FlightMathScript := preload("res://hellcats/core/flight_math.gd")

var config: Dictionary = {}
## After step(); for HUD / QA (see docs/flight_FUN_0000e792_contract.md).
var last_flight_trace: Dictionary = {}

func configure(data: Dictionary) -> void:
	config = data.duplicate(true)

func reset() -> void:
	last_flight_trace = {}

func step(state, controls: Dictionary, delta: float) -> void:
	if state == null:
		return

	var limits: Dictionary = config.get("limits", {})
	var rates: Dictionary = config.get("control_rates", {})
	var speed_model: Dictionary = config.get("speed_model", {})
	var climb_model: Dictionary = config.get("climb_model", {})
	var assist: Dictionary = config.get("assist", {})
	var stall: Dictionary = config.get("stall", {})
	var smooth: Dictionary = config.get("movement_smoothing", {})

	## [RECONSTRUCTED] FUN_0000740a DAT_00024cf6 step edges map to throttle_impulse; hold uses axis.
	## [MVP APPROXIMATION] Impulse is direct 0..1 delta; original uses stepped char accumulation.
	var throttle_axis: float = float(controls.get("throttle", 0.0))
	var throttle_impulse: float = float(controls.get("throttle_impulse", 0.0))
	state.throttle_01 = clampf(
		state.throttle_01
		+ throttle_axis * float(rates.get("throttle_change_per_s", 0.45)) * delta
		+ throttle_impulse,
		0.0,
		1.0
	)

	## [RECONSTRUCTED] FUN_0000e792 ownership-branch delta smoothing on movement_66e / 672 / 66a.
	## [MVP APPROXIMATION] Targets are scaled float commands, not full local_46/local_42 from airspeed.
	## [MVP TUNING] max_int scales; optional extra roll centering when roll input ~ 0.
	var pitch_max: int = int(smooth.get("pitch_max_int", 8192))
	var roll_max: int = int(smooth.get("roll_max_int", 8192))
	var yaw_max: int = int(smooth.get("yaw_max_int", 8192))
	var pitch_cmd: float = float(controls.get("pitch", 0.0))
	var roll_cmd: float = float(controls.get("roll", 0.0))
	var yaw_cmd: float = float(controls.get("yaw", 0.0))

	var pitch_target: int = _scaled_cmd_to_int(pitch_cmd, pitch_max)
	var roll_target: int = _scaled_cmd_to_int(roll_cmd, roll_max)
	var yaw_target: int = _scaled_cmd_to_int(yaw_cmd, yaw_max)

	state.movement_66e = FlightMathScript.add_delta_smoothed_int(
		state.movement_66e, pitch_target - state.movement_66e
	)
	state.movement_672 = FlightMathScript.add_delta_smoothed_s16(
		state.movement_672, roll_target - state.movement_672
	)
	state.movement_66a = FlightMathScript.add_delta_smoothed_int(
		state.movement_66a, yaw_target - state.movement_66a
	)

	var pitch_norm: float = clampf(
		float(state.movement_66e) / float(maxi(pitch_max, 1)), -1.0, 1.0
	)
	var roll_norm: float = clampf(
		float(state.movement_672) / float(maxi(roll_max, 1)), -1.0, 1.0
	)
	var yaw_norm: float = clampf(
		float(state.movement_66a) / float(maxi(yaw_max, 1)), -1.0, 1.0
	)

	var p_min: float = float(limits.get("min_pitch_deg", -35.0))
	var p_max: float = float(limits.get("max_pitch_deg", 35.0))
	var r_min: float = float(limits.get("min_roll_deg", -65.0))
	var r_max: float = float(limits.get("max_roll_deg", 65.0))
	state.pitch_deg = clampf(
		state.pitch_deg + pitch_norm * float(rates.get("pitch_rate_deg_s", 38.0)) * delta,
		p_min,
		p_max
	)

	state.roll_deg = clampf(
		state.roll_deg + roll_norm * float(rates.get("roll_rate_deg_s", 70.0)) * delta,
		r_min,
		r_max
	)

	## [MVP TUNING] Light roll centering when stick neutral (teachable level flight).
	if is_zero_approx(roll_cmd):
		state.roll_deg = lerpf(
			state.roll_deg,
			0.0,
			clampf(float(assist.get("roll_auto_level_gain", 0.2)) * delta, 0.0, 1.0)
		)

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
	var yaw_rate: float = (yaw_norm * float(rates.get("yaw_rate_deg_s", 24.0))) + (
		bank_factor * state.airspeed_mps * float(assist.get("yaw_assist_gain", 0.3))
	)
	state.heading_deg = wrapf(state.heading_deg + yaw_rate * delta, 0.0, 360.0)
	state.bank_deg = state.roll_deg

	var throttle_lift: float = float(climb_model.get("throttle_lift_factor", 0.18))
	state.vertical_speed_mps = (state.pitch_deg * float(climb_model.get("pitch_to_vertical_speed_gain", 1.15))) - (float(climb_model.get("gravity_drop_mps2", 9.81)) * (1.0 - state.throttle_01) * throttle_lift)
	var stall_vs_penalty: float = float(stall.get("vertical_speed_penalty_mps", 16.0))
	if state.airspeed_mps < float(stall.get("speed_mps_below", 55.0)):
		state.vertical_speed_mps -= stall_vs_penalty
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

	last_flight_trace = {
		"movement_66e": state.movement_66e,
		"movement_672": state.movement_672,
		"movement_66a": state.movement_66a,
		"pitch_norm": pitch_norm,
		"roll_norm": roll_norm,
		"yaw_norm": yaw_norm,
		"pitch_deg": state.pitch_deg,
		"roll_deg": state.roll_deg,
		"heading_deg": state.heading_deg,
		"airspeed_mps": state.airspeed_mps,
		"throttle_01": state.throttle_01,
		"vertical_speed_mps": state.vertical_speed_mps,
	}

func _scaled_cmd_to_int(cmd: float, max_int: int) -> int:
	var m: int = maxi(max_int, 1)
	return clampi(int(round(cmd * float(m))), -m, m)

func _first_float(value: Variant, default_value: float) -> float:
	if value is Array and value.size() > 0:
		return float(value[0])
	return default_value

func _second_float(value: Variant, default_value: float) -> float:
	if value is Array and value.size() > 1:
		return float(value[1])
	return default_value
