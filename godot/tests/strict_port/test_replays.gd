extends RefCounted

## The replay-only evidence: each fixture was recorded from the original 68000 code by its generator
## (tools/strict_port/gen_*_cases.py; the fixture's name is the generator's), and the port must
## reproduce every case exactly. Overlay fixtures replay on pacific_conflict.gd against the original
## image (helpers/original_cases.gd); segment fixtures on their segment's port with logging stand-ins
## (helpers/segment_cases.gd). A fixture listed here is a mapping's deterministic_test.

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")
const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const FIXTURES := "res://tests/strict_port/fixtures/"

const OVERLAY := [
	"ai_state_cases.json", "altitude_band_cases.json", "anchor_present_cases.json",
	"camera_cases.json", "cloud_cases.json", "collision_cases.json",
	"colour_setup_cases.json", "controller_misc_cases.json", "copy_rect_cases.json",
	"distant_dots_cases.json", "dot_cases.json", "face_emit_cases.json",
	"face_output_cases.json", "flight_input_cases.json", "flight_start_cases.json",
	"frame_loop_cases.json", "frame_step_cases.json", "game_sound_cases.json",
	"gauge_cases.json", "ground_scatter_cases.json", "heading_tape_cases.json",
	"line4_cases.json", "line8_cases.json", "mission_start_cases.json",
	"mission_tables_cases.json", "object_list_cases.json", "object_pipeline_cases.json",
	"ordnance_cases.json", "overlay_entry_cases.json", "panel_frame_cases.json",
	"parachute_cases.json", "plume_cases.json", "polygon_cases.json",
	"pre_render_cases.json", "radar_blip_cases.json", "radar_cases.json",
	"readout_cases.json", "render_objects_cases.json", "renderer_config_cases.json",
	"scan_convert_cases.json", "session_buffer_cases.json", "sim_step_cases.json",
	"sky_ground_cases.json", "slew_mode_cases.json", "small_math_cases.json",
	"sort_parts_cases.json", "sound_effect_log_cases.json", "span4_cases.json",
	"span_fill_cases.json", "template_registration_cases.json", "terrain_cases.json",
	"tracking_cases.json", "transform_object_cases.json", "view_cases.json",
	"visibility_cases.json",
]

## fixture -> the segment port it replays on
const SEGMENTS := {
	"id02_commands_cases.json": "ID02",
	"id02_crt_cases.json": "ID02",
	"id02_dialog_cases.json": "ID02",
	"id02_display_cases.json": "ID02",
	"id02_draw_cases.json": "ID02",
	"id02_events_cases.json": "ID02",
	"id02_flight_cases.json": "ID02",
	"id02_glue_cases.json": "ID02",
	"id02_memory_cases.json": "ID02",
	"id02_menu_cases.json": "ID02",
	"id02_palette_cases.json": "ID02",
	"id02_session_cases.json": "ID02",
	"id02_sound_cases.json": "ID02",
	"id02_startup_cases.json": "ID02",
	"id02_toolbox_cases.json": "ID02",
	"id02_trapfree_cases.json": "ID02",
	"id03_boxes_cases.json": "ID03",
	"id03_downsample_cases.json": "ID03",
	"id03_gauges_cases.json": "ID03",
	"id03_glyph_cases.json": "ID03",
	"id03_helpers_cases.json": "ID03",
	"id03_panel_cases.json": "ID03",
	"id03_prepare_cases.json": "ID03",
	"id03_remap_cases.json": "ID03",
	"id03_supersample_cases.json": "ID03",
	"id04_about_cases.json": "ID04",
	"id04_dialog_cases.json": "ID04",
	"id04_draw_cases.json": "ID04",
	"id04_filter_cases.json": "ID04",
	"id04_scroll_cases.json": "ID04",
	"id04_summary_cases.json": "ID04",
	"id05_dialog_cases.json": "ID05",
	"id05_protection_cases.json": "ID05",
	"id06_raster_cases.json": "ID06",
	"id06_render_cases.json": "ID06",
	"id08_loader_cases.json": "ID08",
}

func run() -> bool:
	var ok := true
	for name in OVERLAY:
		ok = OriginalCases.replay(FIXTURES + name) and ok
	for name in SEGMENTS:
		var port: GDScript = load("res://strict_port/code/%s.gd" % SEGMENTS[name])
		ok = SegmentCases.replay(FIXTURES + name, port) and ok
	return ok
