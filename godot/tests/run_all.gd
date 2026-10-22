extends SceneTree
## Project-local headless test runner.
## Usage:
##   godot --headless --path . --script res://tests/run_all.gd

const TEST_PATHS := [
	"res://tests/strict_port/test_c68k.gd",
	"res://tests/strict_port/test_memory_68k.gd",
	"res://tests/strict_port/test_contact_pair_hash.gd",
	"res://tests/strict_port/test_find_contact_record.gd",
	"res://tests/strict_port/test_reset_radar_tracks.gd",
	"res://tests/strict_port/test_abs_int.gd",
	"res://tests/strict_port/test_approx_dist3_xyz.gd",
	"res://tests/strict_port/test_camera_metric.gd",
	"res://tests/strict_port/test_sin_cos_fixed14.gd",
	"res://tests/strict_port/test_attitude_bases.gd",
	"res://tests/strict_port/test_attitude_matrix.gd",
	"res://tests/strict_port/test_attitude_variants.gd",
	"res://tests/strict_port/test_transform_vecs12.gd",
	"res://tests/strict_port/test_transform_int3.gd",
	"res://tests/strict_port/test_template_chain_xform.gd",
	"res://tests/strict_port/test_node_chain.gd",
	"res://tests/strict_port/test_scene_traversal.gd",
	"res://tests/strict_port/test_type80_visitor.gd",
	"res://tests/strict_port/test_clip_polygon.gd",
	"res://tests/strict_port/test_collect_map_features.gd",
	"res://tests/strict_port/test_plot_map_symbols.gd",
	"res://tests/strict_port/test_segment_point_min_distance.gd",
	"res://tests/strict_port/test_overlay_rng_retire.gd",
	"res://tests/unit/test_rng.gd",
	"res://tests/unit/test_rng_overlay_11564.gd",
	"res://tests/unit/test_flight_math.gd",
	"res://tests/unit/test_loader_metadata.gd",
	"res://tests/unit/test_mission_objectives_m1.gd",
	"res://tests/unit/test_player_input_frame.gd",
	"res://tests/unit/test_flight_model_mvp.gd",
	"res://tests/unit/test_world_collision_mvp.gd",
	"res://tests/integration/test_sim_loader_bridge.gd",
	"res://tests/integration/test_sim_tick_ordering.gd",
	"res://tests/integration/test_sim_entity_controls.gd",
	"res://tests/integration/test_movement_smoothing.gd",
	"res://tests/integration/test_replay.gd",
	"res://tests/integration/test_mission_scene_load.gd",
	"res://tests/integration/test_hud_mvp_scene.gd",
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
