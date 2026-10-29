extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## draw_distant_object_dots, checked against the ORIGINAL bytes:
## tools/strict_port/gen_distant_dots_cases.py runs it in the m68k_emu interpreter with the erase and
## plot routines logged (fixtures/distant_dots_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/distant_dots_cases.json")
