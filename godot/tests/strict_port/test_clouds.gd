extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## spawn_cloud_layer and spawn_camera_relative_object, checked against the ORIGINAL bytes:
## tools/strict_port/gen_cloud_cases.py runs them in the m68k_emu interpreter with the pool spawn
## stubbed and logging every call (fixtures/cloud_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/cloud_cases.json")
