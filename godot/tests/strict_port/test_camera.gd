extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## copy_player_pose_to_camera, place_camera_behind_object and turn_camera_toward_point, checked
## against the ORIGINAL bytes: tools/strict_port/gen_camera_cases.py runs them in the m68k_emu
## interpreter (fixtures/camera_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/camera_cases.json")
