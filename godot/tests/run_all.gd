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
	"res://tests/strict_port/test_bullet_hits.gd",
	"res://tests/strict_port/test_dispatch_collision.gd",
	"res://tests/strict_port/test_facility_tally_cleanup.gd",
	"res://tests/strict_port/test_spawn_destruction_effect.gd",
	"res://tests/strict_port/test_tick_bullet.gd",
	"res://tests/strict_port/test_surface_type.gd",
	"res://tests/strict_port/test_spawn_effect.gd",
	"res://tests/strict_port/test_pool_spawn.gd",
	"res://tests/strict_port/test_heap.gd",
	"res://tests/strict_port/test_object_creation.gd",
	"res://tests/strict_port/test_object_buffers.gd",
	"res://tests/strict_port/test_activate.gd",
	"res://tests/strict_port/test_shading.gd",
	"res://tests/strict_port/test_sink.gd",
	"res://tests/strict_port/test_land_outline.gd",
	"res://tests/strict_port/test_factories.gd",
	"res://tests/strict_port/test_effect_init.gd",
	"res://tests/strict_port/test_aircraft_create.gd",
	"res://tests/strict_port/test_effect_animate.gd",
	"res://tests/strict_port/test_effect_debris.gd",
	"res://tests/strict_port/test_controller_ticks.gd",
	"res://tests/strict_port/test_ground_fire.gd",
	"res://tests/strict_port/test_trails.gd",
	"res://tests/strict_port/test_sinking_step.gd",
	"res://tests/strict_port/test_inverse_trig.gd",
	"res://tests/strict_port/test_turret.gd",
	"res://tests/strict_port/test_blast_damage.gd",
	"res://tests/strict_port/test_flak_gun.gd",
	"res://tests/strict_port/test_wave_spawner.gd",
	"res://tests/strict_port/test_aircraft_spawner.gd",
	"res://tests/strict_port/test_firing_ship.gd",
	"res://tests/strict_port/test_small_handlers.gd",
	"res://tests/strict_port/test_aircraft_handlers.gd",
	"res://tests/strict_port/test_aircraft_notice.gd",
	"res://tests/strict_port/test_fighter_notice.gd",
	"res://tests/strict_port/test_overlap_dispatch.gd",
	"res://tests/strict_port/test_landing_gear.gd",
	"res://tests/strict_port/test_damage_helpers.gd",
	"res://tests/strict_port/test_damage_state.gd",
	"res://tests/strict_port/test_aircraft_tick.gd",
	"res://tests/strict_port/test_flight_helpers.gd",
	"res://tests/strict_port/test_steering.gd",
	"res://tests/strict_port/test_flight_misc.gd",
	"res://tests/strict_port/test_flight_model.gd",
	"res://tests/strict_port/test_ai_states.gd",
	"res://tests/strict_port/test_ordnance.gd",
	"res://tests/strict_port/test_parachute.gd",
	"res://tests/strict_port/test_controller_misc.gd",
	"res://tests/strict_port/test_template_registration.gd",
	"res://tests/strict_port/test_radar.gd",
	"res://tests/strict_port/test_sound_effect_log.gd",
	"res://tests/strict_port/test_plume.gd",
	"res://tests/strict_port/test_pre_render.gd",
	"res://tests/strict_port/test_polygon.gd",
	"res://tests/strict_port/test_dots.gd",
	"res://tests/strict_port/test_object_list.gd",
	"res://tests/strict_port/test_visibility.gd",
	"res://tests/strict_port/test_collision.gd",
	"res://tests/strict_port/test_terrain.gd",
	"res://tests/strict_port/test_sim_step.gd",
	"res://tests/strict_port/test_camera.gd",
	"res://tests/strict_port/test_radar_blips.gd",
	"res://tests/strict_port/test_views.gd",
	"res://tests/strict_port/test_tracking_camera.gd",
	"res://tests/strict_port/test_frame_loop.gd",
	"res://tests/strict_port/test_clouds.gd",
	"res://tests/strict_port/test_altitude_bands.gd",
	"res://tests/strict_port/test_ground_scatter.gd",
	"res://tests/strict_port/test_small_math.gd",
	"res://tests/strict_port/test_gauges.gd",
	"res://tests/strict_port/test_readouts.gd",
	"res://tests/strict_port/test_panel_frame.gd",
	"res://tests/strict_port/test_heading_tape.gd",
	"res://tests/strict_port/test_sky_ground.gd",
	"res://tests/strict_port/test_copy_rect.gd",
	"res://tests/strict_port/test_line8.gd",
	"res://tests/strict_port/test_line4.gd",
	"res://tests/strict_port/test_face_emit.gd",
	"res://tests/strict_port/test_face_output.gd",
	"res://tests/strict_port/test_object_pipeline.gd",
	"res://tests/strict_port/test_transform_object.gd",
	"res://tests/strict_port/test_render_objects.gd",
	"res://tests/strict_port/test_sort_parts.gd",
	"res://tests/strict_port/test_span_fill.gd",
	"res://tests/strict_port/test_span4.gd",
	"res://tests/strict_port/test_scan_convert.gd",
	"res://tests/strict_port/test_colour_setup.gd",
	"res://tests/strict_port/test_session_buffers.gd",
	"res://tests/strict_port/test_anchor_present.gd",
	"res://tests/strict_port/test_flight_start.gd",
	"res://tests/strict_port/test_mission_start.gd",
	"res://tests/strict_port/test_overlay_entry.gd",
	"res://tests/strict_port/test_mission_tables.gd",
	"res://tests/strict_port/test_distant_dots.gd",
	"res://tests/strict_port/test_renderer_config.gd",
	"res://tests/strict_port/test_slew_mode.gd",
	"res://tests/strict_port/test_game_sounds.gd",
	"res://tests/strict_port/test_frame_step.gd",
	"res://tests/strict_port/test_flight_input.gd",
	"res://tests/strict_port/test_id01_divide.gd",
	"res://tests/strict_port/test_id02_crt.gd",
	"res://tests/strict_port/test_id02_trapfree.gd",
	"res://tests/strict_port/test_id02_glue.gd",
	"res://tests/strict_port/test_id02_toolbox.gd",
	"res://tests/strict_port/test_id02_dialog.gd",
	"res://tests/strict_port/test_id02_palette.gd",
	"res://tests/strict_port/test_id02_draw.gd",
	"res://tests/strict_port/test_id02_memory.gd",
	"res://tests/strict_port/test_id02_menu.gd",
	"res://tests/strict_port/test_id05_protection.gd",
	"res://tests/strict_port/test_id06_raster.gd",
	"res://tests/strict_port/test_id07_09.gd",
	"res://tests/strict_port/test_id04_dialog.gd",
	"res://tests/strict_port/test_id04_scroll.gd",
	"res://tests/strict_port/test_id04_filter.gd",
	"res://tests/strict_port/test_id04_draw.gd",
	"res://tests/strict_port/test_id04_about.gd",
	"res://tests/strict_port/test_id04_summary.gd",
	"res://tests/strict_port/test_id05_dialog.gd",
	"res://tests/strict_port/test_id08_09_glue.gd",
	"res://tests/strict_port/test_id08_loader.gd",
	"res://tests/strict_port/test_id06_render.gd",
	"res://tests/strict_port/test_id03_helpers.gd",
	"res://tests/strict_port/test_id03_glyph.gd",
	"res://tests/strict_port/test_id03_panel.gd",
	"res://tests/strict_port/test_id03_boxes.gd",
	"res://tests/strict_port/test_id03_supersample.gd",
	"res://tests/strict_port/test_id03_gauges.gd",
	"res://tests/strict_port/test_id03_remap.gd",
	"res://tests/strict_port/test_id03_downsample.gd",
	"res://tests/strict_port/test_id03_prepare.gd",
	"res://tests/strict_port/test_id02_session.gd",
	"res://tests/strict_port/test_id02_display.gd",
	"res://tests/strict_port/test_id02_events.gd",
	"res://tests/strict_port/test_id02_commands.gd",
	"res://tests/strict_port/test_id02_sound.gd",
	"res://tests/strict_port/test_id02_startup.gd",
	"res://tests/strict_port/test_id02_flight.gd",
	"res://tests/strict_port/test_resedit_dialogs.gd",
	"res://tests/strict_port/test_resedit_interface.gd",
	"res://tests/strict_port/test_resedit_text.gd",
	"res://tests/strict_port/test_resedit_media.gd",
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
