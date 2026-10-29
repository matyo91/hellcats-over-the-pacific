extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## widen_printf_format, overlay_printf and start_mission_scene, checked against the ORIGINAL bytes:
## tools/strict_port/gen_mission_start_cases.py runs them in the m68k_emu interpreter with the host
## printf logged (fixtures/mission_start_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/mission_start_cases.json")
