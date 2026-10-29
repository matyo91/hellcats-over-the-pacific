extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## update_tracking_camera, checked against the ORIGINAL bytes: tools/strict_port/
## gen_tracking_cases.py runs it in the m68k_emu interpreter (fixtures/tracking_cases.json, returned
## D0 included); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/tracking_cases.json")
