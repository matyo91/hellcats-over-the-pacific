extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## draw_gauge_needle and the cockpit instrument updaters, checked against the ORIGINAL bytes:
## tools/strict_port/gen_gauge_cases.py runs them in the m68k_emu interpreter with the line, lamp
## and rectangle routines logged (fixtures/gauge_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/gauge_cases.json")
