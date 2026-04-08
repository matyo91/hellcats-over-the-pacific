extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const MissionObjectivesScript := preload("res://hellcats/mission/mission_objectives_m1.gd")

func run() -> bool:
	var ok := true
	var objectives = MissionObjectivesScript.new()
	objectives.configure([
		{
			"id": "stabilize_flight",
			"type": "hold_altitude",
			"target_altitude_m": 1200.0,
			"tolerance_m": 120.0,
			"hold_seconds": 0.2,
		},
		{
			"id": "turn_left",
			"type": "reach_bank",
			"min_bank_deg": 20.0,
			"direction": "left",
		},
		{
			"id": "checkpoint_pass",
			"type": "checkpoint_pass",
			"checkpoint_id": "cp_01",
			"optional": true,
		},
	])

	var result := objectives.step({"altitude_m": 1180.0, "bank_deg": 0.0}, 0.1)
	ok = Assertions.assert_true(not bool(result.get("mission_complete", false)), "required objective not complete yet") and ok
	result = objectives.step({"altitude_m": 1190.0, "bank_deg": 0.0}, 0.1)
	ok = Assertions.assert_equal(String(result.get("completed_id", "")), "stabilize_flight", "hold altitude objective completes") and ok
	result = objectives.step({"altitude_m": 1190.0, "bank_deg": -25.0}, 0.1)
	ok = Assertions.assert_equal(String(result.get("completed_id", "")), "turn_left", "reach bank objective completes") and ok
	ok = Assertions.assert_true(bool(result.get("mission_complete", false)), "required objectives complete before optional checkpoint") and ok
	objectives.notify_checkpoint("cp_01")
	result = objectives.step({"altitude_m": 1190.0, "bank_deg": 0.0}, 0.1)
	ok = Assertions.assert_equal(String(result.get("completed_id", "")), "checkpoint_pass", "optional checkpoint can complete") and ok
	return ok
