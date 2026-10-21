# C-to-C reconstruction checkpoint

This is the concise entry point for focused semantic reconstruction.

**Next target:** none - every function is VERIFIED (Pacific Conflict 443/443, ID01..ID09 complete).
CODE 0 is also structurally complete: `ID00.c` is a byte-exact reconstructed
data export and `ID00.decomp.c` decodes its header plus all 175 Segment Manager
jump-table entries. It has no application function bodies and is therefore not
part of the function-count inventory.
The four functions for which Ghidra emitted only `Unable to decompile` records
are now byte-reconstructed and VERIFIED: ID02 `FUN_000002b0` / `FUN_00004b62`
and ID05 `FUN_000008b8` / `FUN_00000964`. The canonical inventory includes
failed-export identities and currently contains 740 verified functions.
The four computed-jump span blitters `fill_span_rows_4bit_a` / `_4bit_b` / `_4bit_c` / `fill_span_rows_8bit`
(FUN_000032ba / FUN_00003466 / FUN_00003608 / FUN_000037b4) were the last: delta span renderers that redraw only
changed spans through self-patched tail tables (c is a byte copy of b; the 8-bit one swaps two 2048-entry tables by
destination parity) - see their headers.
**Readability pass** (rename-only, after the verification pass): Ghidra-style names (iVarN / uVarN / local_xx /
param_N / auStack / in_stack / extraout / DAT_ / PTR_) are being replaced by evidence-based names, the original
kept in a declaration comment; globals go through a `#define readable DAT_xxxx` block per file and
DECOMPILATION_SYMBOLS.md; every edit must stay token-identical after reverse mapping. Done: Pacific Conflict 0x20 .. 0xfe96, fragments included. Remaining: 212 functions, 10315 names. Next: release_ai_target (0x100bc) onwards.

Overlay segments (all 30 ID02 C-runtime functions (abs_long..ansi_strncat) plus begin_overlay_session / ensure_free_memory_and_init_sound / run_flight_session / call_overlay_session_hooks / the four A5-safe drawing services 0xa42..0xca4 / the port, blit, fill, frame, text, colour and design-coordinate helpers 0xca6..0x19a0 / the memory and handle wrappers 0x19a2..0x1b3e / format_int_decimal_pstring / show_caution_alert_with_number / the two dialog helpers / the four sound-slot routines 0x1e68..0x2128 / reset_overlay_state / the display set-up routines 0x2192..0x2a42 / apply_settings_to_live_options / initialize_application / wait_for_click_or_key / show_resource_file_error_box / copy_pascal_string / handle_mouse_down / handle_activate_event / poll_and_dispatch_event / main / install_menus / update_menu_items / set_menu_item_enabled / set_view_size_option / start_new_mission / do_menu_command / the sound helpers 0x3d36..0x435c / all three VBL sound handlers 0x39a8..0x3d32 / the window placement helpers 0x435e..0x462a / the palette routines 0x462c..0x4b60 / the update helpers 0x4c18..0x4e18, both ID07 functions, the six ID01 divide helpers, all four ID08 bodies, four ID09 routines, all 24 ID05 functions and all 24 ID06 functions VERIFIED; each IDnn.bin maps Ghidra address = file offset,
4-byte CODE header, cross-segment calls via JSR d16(A5) jump-table slots and Toolbox A-traps). No overlay work remains in the ID01..ID09 segments:
ID01 through ID09 are all complete (every exported function verified). Functions whose C is only halt_baddata() need an
evidence-backed reconstruction from the bytes before they can be verified (inline switch tables go through
the ID01 0xbe range helper, JSR $3a(A5), or the ID01 0xaa long value-list helper, JSR $32(A5), or the ID01 0x96 word value-list helper, JSR $2a(A5)).

Open questions recorded in `update_aircraft_entity`: blk 3b reads the blk 2b engine
locals uninitialised for non-player aircraft (reachability unknown); blk 2b's divs.w
could trap on a zero divisor (reachability unknown). Section-check comments say
"blk N", never "Block N", so `re_query.py excerpt --block` stays unambiguous.

The overlay heap (sbrk, size-class / large-block growth, alloc, free) and the overlay
RNG (init, mul_mix, next) are fully VERIFIED; the false entry FUN_00001a48 is settled.
Already VERIFIED:
`ai_pursue_target`, `bullet_hits_aircraft`, `steer_entity_toward_point`,
`apply_relative_heading_steer`, `retire_entity`, `dispatch_entity_cleanup`, `deactivate_object`, `release_fractal_reference`, `heap_free_coalesce`, `heap_alloc`, `heap_new_size_class_block`, `heap_add_large_block`, `heap_sbrk`, `isqrt_floor`, `update_aircraft_entity`, `fold_angle_pm_0x2000`, `compute_template_force_from_626` (+ false split e512), `abs_int`, `transform_vecs12_by_matrix3`, `build_attitude_matrix` (wrapper), `load_attitude_angle_sincos`, `fill_attitude_rotation_bases`, `fill_attitude_rotation_basis_4`, `finalize_attitude_matrix_4ang`, `matmul3x3_s16`, `enemy_fighter_notice_object`, `invert_ai_bias_67b_if_positive`, `ai_attack_or_fly`, `ai_fly`, `ai_dive_at_target`, `ai_bombing_run`, `adjust_ai_throttle_vs_speed`, `max_ai_throttle_maybe_invert_679`, `ensure_ai_script_1b2e0_tick`, `tick_ai_climb_then_waypoint`, `advance_route_waypoint`, `ai_bootstrap_climb_phase`, `enqueue_control_inputs_avg4`, `ensure_ai_script_1b340_tick`, `ensure_ai_script_1b310_tick`, `tick_ai_1b310_approach_fire`, `ai_script_try_fire_burst`, `tick_ai_1b370_mission`, `try_begin_landing_approach`, `find_nearest_runway_approach_ends`, `store_xyz_asr`, `tick_landing_approach_glide`, `apply_player_mouse_controls`, `process_flight_input_and_outcome`, `copy_player_pose_to_camera`, `update_bailout_view`, `player_slew_mode`, `point_near_camera_or_type80_object`, `compute_camera_abs_metric`, `nearest_type80_centroid_visitor`, `update_object_camera_metric`, `transform_through_node_chain`, `translate_int3_vecs`, `transform_int3_vecs_by_matrix3`, `build_attitude_matrix_3ang`, `finalize_attitude_matrix_3ang`, `build_attitude_matrix_3ang_alt`, `finalize_attitude_matrix_3ang_alt`, `apply_template_chain_xform`, `apply_template_chain_xform_always`, `activate_near_range_object`, `update_object_distance_band`, `shade_object_faces`, `apply_entity_mission_rates`, `build_object_poly_buffers`, `write_face_palette_slot`, `assign_face_colour`, `snapshot_face_colours`, `queue_face_palette_entry`, `set_object_faces_bw_pattern`, `sink_object_shape_at_waterline`, `clip_polygon_y_nonneg`, `transform_vecs12_to_int3_by_matrix3`, `heap_realloc_grow_only`, `build_land_outline_at_detail`, `update_altitude_detail_bands`, `reset_object_to_template_pose`, `overlay_frame_step`, `collect_near_objects`, `build_visible_object_list`, `update_ground_scatter_objects`, `surface_type_at_point`, `spawn_mission_pool_object`, `instantiate_mission_pool_slot`, `build_attitude_matrix_x_alt`, `build_attitude_matrix_x`, `noop_stub_2e12`, `surface_type_under_object`, `face_camera_heading`, `clear_flag_00020ae4`, `point_over_face_xz`, `begin_offscreen_drawing`, `create_spinner_controller`, `create_plume_controller`, `create_camera_facing_controller`, `create_basic_ship_controller`, `create_firing_ship_controller`, `create_sinking_controller`, `create_bullet_controller`, `create_trail_controller`, `create_ground_fire_controller`, `create_debris_controller`, `create_ground_mark_controller`, `create_shadow_controller`, `create_flak_controller`, `create_cloud_controller`, `create_view_attached_controller`, `create_singleton_type10_controller`, `create_effect_controller`, `create_ordnance_controller`, `create_turret_controller`, `create_parachute_controller`, `create_carrier_controller`, `create_aircraft_spawner_controller`, `create_wave_spawner_controller`, `copy_block_return_dst`, `overlay_init_noop`, `overlay_patch_template_u16_pair`, `effect_pre_render_hook`, `erase_radar_blip_bw`, `draw_radar_blip_bw`, `lock_handle_nopurge`, `unlock_handle_purgeable`, `end_offscreen_drawing`, `mark_effect_log_end`, `heap_alloc_cleared`, `build_attitude_matrix_6ang`, `build_attitude_matrix_6ang_alt`, `rotate_int3_vecs_by_3ang`, `init_depth8_colour_state`, `test_player_vs_type0e_proximity`, `tick_sinking_controller`, `turret_pre_render`, `lock_overlay_buffers`, `heap_zero_payload_tail`, `invoke_tagged_attitude_compose_neg_sins4`, `recolour_kind2_object`, `stop_game_sound`, `reset_overlay_display_state`, `spawn_ordnance_oriented`, `heap_calloc`, `reset_object_to_template_pose_tail`, `reset_distance_base_globals`, `spawn_ordnance_oriented_3ang`, `for_each_mission_scene_object`, `heap_realloc_grow_only_tail`, `compose_attitude_matrix_x_alt`, `invoke_tagged_attitude_compose_neg_sins6`, `create_enemy_bomber`, `ai_fly_bomber`, `destroy_plume_controller`, `plume_pre_render`, `overlay_printf`, `compose_attitude_matrix_x`, `heap_zero_payload`, `fill_attitude_rotation_basis_4_rx`, `dispatch_entity_tick`, `overlay_rng_warmup_epilogue`, `impact_one_time_in_16`, `tick_view_attached_object`, `any_mission_kills_recorded`, `load_attitude_angle_sincos_5_6`, `compose_attitude_matrix_6ang_alt`, `FUN_00002de8` (fragment), `init_span_table_32ba`, `init_span_table_3466`, `init_span_table_3608`, `FUN_00003c48` (fragment), `aircraft_destroy`, `test_proximity_collision`, `FUN_00001db8` (fragment), `compose_attitude_matrix_6ang`, `present_bw_frame`, `ordnance_collision`, `attach_ground_fire`, `FUN_00003be0` (fragment), `acos_scaled_dot3`, `bullet_pre_render`, `follow_camera_offset`, `tally_destroyed_entity`, `face_is_back_facing`, `spawn_enemy_fighter`, `tick_effect`, `spawn_trail`, `scale_int3_vecs`, `reset_background_rows`, `destroy_aircraft_spawner_controller`, `ensure_handle_allocated`, `heap_add_large_block_tail` (fragment), `create_enemy_fighter`, `attach_smoke_trail`, `spawn_turret_on_object`, `update_direction_needle`, `update_climb_needle`, `update_tachometer_needle`, `update_manifold_needle`, `destroy_trail_controller`, `remove_mission_target`, `overlay_initialise`, `copy_object_vertex_buffer`, `begin_flight_for_rank`, `plot_dot_bw`, `fill_attitude_rotation_bases_5_6`, `update_throttle_gauge`, `replay_logged_effects`, `spawn_weapon_entity`, `spawn_object_shadow`, `update_ammo_needle`, `aircraft_collision`, `apply_blast_damage`, `tick_shadow`, `spawn_camera_relative_object`, `update_record_distance_band`, `update_bomb_indicator`, `update_flaps_needle`, `create_friendly_bomber`, `start_mission_scene`, `emit_face_chain`, `output_face_colour`, `tick_debris_fragment`, `transform_int3_vecs_asr_by_1d744`, `reset_span_row_lists`, `draw_gauge_needle`, `handle_player_contact`, `attach_burning_trail`, `load_player_fuel_and_bombs`, `find_anchor_point`, `output_face_bw`, `unlock_session_buffers`, `apply_controller_velocities`, `spawn_debris_fragment`, `widen_printf_format`, `update_fuel_needles`, `reset_palette_owner_tables`, `update_altimeter_needles`, `update_gear_needles`, `process_flight_input_tail` (fragment), `init_aircraft_controller`, `present_spans_to_window`, `erase_dots_depth8`, `plot_dot_depth8`, `erase_radar_blip_depth8`, `overlay_main_entry`, `update_airspeed_needle`, `traverse_scene_tree`, `init_effect_kind1_column`, `update_radar_range_buttons`, `init_code_pointer_tables`, `probe_nearest_facility_kind`, `update_view_clip_bounds`, `init_effect_kind0_flat_ring`, `animate_effect_kind0_ring_tail` (fragment), `spawn_ground_mark`, `spawn_bailout_parachute`, `lock_session_buffers`, `aircraft_create`, `memzero`, `FUN_00001d56` (fragment), `transform_listed_object_vecs12_by_1d744`, `tick_flagged_object_controllers`, `spawn_ordnance_scattered`, `project_prepared_object`, `parachute_tick`, `animate_effect_kind1_column`, `tick_wave_spawner`, `allocate_session_buffers`, `FUN_00002aba` (fragment), `shape_trailing_plume`, `animate_effect_kind0_ring`, `anchor_point_visitor`, `handle_terrain_contact`, `draw_radar_blip_depth4`, `emit_faces_unnumbered`, `clip_polygon_y_min`, `clip_polygon_y_max`, `clip_polygon_x_min`, `clip_polygon_x_max`, `init_effect_kind3_debris_explosion`, `erase_dots_depth4`, `emit_faces_in_order`, `spawn_effect`, `init_depth4_colour_state`, `run_simulation_tick`, `erase_radar_blip_depth4`, `point_in_face_by_axis`, `ordnance_ballistic_step`, `test_object_collision`, `transform_face_vertices`, `ordnance_tick`, `plot_dot_depth4`, `shadow_pre_render`, `dispatch_collision`, `init_effect_kind2_burst`, `animate_effect_kind2_burst`, `test_terrain_collision`, `create_fractal_contact_record`, `spawn_cloud_layer`, `step_sinking_object`, `track_ground_plane_horizon`, `clip_face_near_plane`, `respawn_player_at_anchor`, `refresh_object_colours_for_depth`, `update_radar_scope`, `plot_mission_map_symbols`, `init_mission_object_tables`, `play_game_sound`, `ordnance_detonation`, `apply_hit_to_sinkable_object`, `build_attitude_matrix_from_dir_roll`, `collect_map_features`, `emit_faces_bsp`, `shape_free_plume`, `add_face_edges_to_rows`, `carry_attached_objects`, `aircraft_tick`, `spawn_destruction_effect`, `create_shape_contact_record`, `tick_aircraft_spawner`, `animate_smoke_trail`, `advance_frame_and_tick_controllers`, `tick_turret`, `animate_effect_kind3_debris`, `lift_object_onto_terrain`, `tick_firing_ship_controller`, `animate_landing_gear`, `submit_object_faces`, `memmove_block`, `aircraft_notice_object`, `animate_ground_fire`, `configure_renderer_for_display`, `fractal_height_at`, `copy_rect_depth8`, `parachute_descend`, `animate_burning_trail`, `draw_panel_frame_lines`, `draw_distant_object_dots`, `tick_flak_gun`, `update_game_sounds`, `sort_group_parts_by_distance`, `update_heading_tape`, `render_visible_objects`, `update_aircraft_damage_state`, `copy_rect_depth4`, `overlay_init_template_pointer_tables`, `transform_and_project_object`, `draw_sky_and_ground`, `draw_line_depth8`, `restore_line_depth8`, `draw_line_depth4`, `restore_line_depth4`, `scan_convert_edge_rows`, `update_view_readouts_and_overlays`, `overlay_rng_next` (lagged additive RNG,
x[n] = x[n-1] + x[n-32] over the 55-long ring 0x2600c..0x260e7).

The angle path feeding `attitude_from_velocity` is established:
`acos_fixed14` and `atan_fixed14` match independent disassembly, and their
cosine/tangent lookup-table scales are recorded in the symbol reference.

A function may be marked `VERIFIED` when its body matches an independent
disassembly of the bytes and every call argument omitted by Ghidra is recorded
as a call-argument correction in
[`DECOMPILATION_SYMBOLS.md`](DECOMPILATION_SYMBOLS.md).

## Current coverage

Run `python3 tools/progress_stats.py` for current orthogonal reconstruction,
strict-port, and resource counts. The segment-qualified canonical records live
in [`DECOMPILATION_INVENTORY.json`](DECOMPILATION_INVENTORY.json); statuses are
reconstruction states, not Godot coverage. The strict-port manifest is the sole
authoritative C-to-GDScript mapping.

## Canonical sources

- Immutable Ghidra exports: `sources/resedit-1-0-3/CODE/*.c`
- Semantic reconstructions: `sources/resedit-1-0-3/CODE/*.decomp.c`
- Function inventory: `DECOMPILATION_INVENTORY.json`
- Symbols, globals, fields, and confidence: `DECOMPILATION_SYMBOLS.md`
- Immutable-source hashes: `DECOMPILATION_PROTECTED_CHECKSUMS.sha256`
- Strict C-to-GDScript mappings: `godot/strict_port/mappings/functions.json`

Source-local provenance comments remain authoritative evidence and must not be
removed merely because the same identity is retrievable elsewhere.

## Focused reconstruction

1. Inspect `git status --short`; do not overwrite unrelated edits.
2. Select one target from this checkpoint.
3. Retrieve only the required function, excerpt, callers, callees, globals, and
   test case with `tools/re_query.py`.
4. Compare the immutable `.c`, semantic `.decomp.c`, and independent
   binary/disassembly evidence.
5. Preserve identifiers, widths, arithmetic, conditions, layouts, and
   unresolved annotations in every evidence-backed edit.
6. Regenerate the inventory and run targeted checks, followed by the validation
   in `README.md` before handoff.

## Priority queue

1. Verify `update_aircraft_entity` (FUN_0000e792; flight update after AI steering).
2. Identify the `overlay_rng_init` caller and its seed source.
3. Continue independent verification of high-traffic Pacific Conflict functions.
4. Resolve remaining ID09/ID05 segment-entry evidence.
5. Investigate `FUN_00003cca` only when its dependencies are needed.

The `$1A48` allocator ABI is resolved: the runtime address maps to `heap_alloc`
at file offset `0x1a68`.
