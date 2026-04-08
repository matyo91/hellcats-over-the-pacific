class_name AircraftState
extends RefCounted

var position_m: Vector3 = Vector3.ZERO
var heading_deg: float = 0.0
var pitch_deg: float = 0.0
var roll_deg: float = 0.0
var airspeed_mps: float = 0.0
var throttle_01: float = 0.0
var vertical_speed_mps: float = 0.0
var bank_deg: float = 0.0
var out_of_bounds_seconds: float = 0.0
var stall_seconds: float = 0.0
var is_crashed: bool = false

func apply_spawn(spawn_data: Dictionary) -> void:
	var position: Array = spawn_data.get("position_m", [0.0, 1200.0, 0.0])
	position_m = Vector3(
		float(position[0]) if position.size() > 0 else 0.0,
		float(position[1]) if position.size() > 1 else 1200.0,
		float(position[2]) if position.size() > 2 else 0.0
	)
	heading_deg = float(spawn_data.get("heading_deg", 0.0))
	pitch_deg = 0.0
	roll_deg = 0.0
	bank_deg = 0.0
	airspeed_mps = float(spawn_data.get("airspeed_mps", 95.0))
	throttle_01 = float(spawn_data.get("throttle_01", 0.72))
	vertical_speed_mps = 0.0
	out_of_bounds_seconds = 0.0
	stall_seconds = 0.0
	is_crashed = false

func snapshot() -> Dictionary:
	return {
		"position_m": position_m,
		"altitude_m": position_m.y,
		"heading_deg": heading_deg,
		"pitch_deg": pitch_deg,
		"roll_deg": roll_deg,
		"bank_deg": bank_deg,
		"airspeed_mps": airspeed_mps,
		"throttle_01": throttle_01,
		"vertical_speed_mps": vertical_speed_mps,
		"stall_seconds": stall_seconds,
		"is_crashed": is_crashed,
	}
