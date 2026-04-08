extends SceneTree
## Project-local headless test runner.
## Usage:
##   godot --headless --path . --script res://godot/tests/run_all.gd

const TEST_PATHS := [
	"res://godot/tests/unit/test_rng.gd",
	"res://godot/tests/unit/test_flight_math.gd",
	"res://godot/tests/unit/test_loader_metadata.gd",
	"res://godot/tests/unit/test_mission_objectives_m1.gd",
	"res://godot/tests/integration/test_sim_loader_bridge.gd",
	"res://godot/tests/integration/test_replay.gd",
	"res://godot/tests/integration/test_mission_scene_load.gd",
	"res://godot/tests/integration/test_hud_mvp_scene.gd",
]

func _init() -> void:
	var failed: Array[String] = []
	print("Running %d Godot project-local tests..." % TEST_PATHS.size())

	for test_path in TEST_PATHS:
		var script := load(test_path)
		if script == null:
			print("FAIL load %s" % test_path)
			failed.append(test_path)
			continue

		var test_object = script.new()
		if not test_object.has_method("run"):
			print("FAIL run() missing %s" % test_path)
			failed.append(test_path)
			continue

		print("-- %s" % test_path)
		var ok := bool(test_object.run())
		if ok:
			print("OK %s" % test_path)
		else:
			print("FAILED %s" % test_path)
			failed.append(test_path)

	var pass_count := TEST_PATHS.size() - failed.size()
	print("Test result: %d passed, %d failed" % [pass_count, failed.size()])
	if not failed.is_empty():
		print("Failures:")
		for test_path in failed:
			print(" - %s" % test_path)

	quit(0 if failed.is_empty() else 1)
