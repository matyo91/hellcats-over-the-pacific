extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## overlay_frame_step, checked against the ORIGINAL bytes: tools/strict_port/gen_frame_step_cases.py
## runs one whole overlay frame in the m68k_emu interpreter with the host routines logged
## (fixtures/frame_step_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/frame_step_cases.json")
