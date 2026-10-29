extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## Small controller routines (destroy hooks of the plume / ground fire / shadow records,
## effect_pre_render_hook with face_object_to_camera, follow_camera_offset,
## create_singleton_type10_controller, impact_one_time_in_16, fill_pose_history_angles / _flags),
## checked against the ORIGINAL bytes: tools/strict_port/gen_controller_misc_cases.py runs them in
## the m68k_emu interpreter (fixtures/controller_misc_cases.json, with the returned D0 where it
## matters); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/controller_misc_cases.json")
