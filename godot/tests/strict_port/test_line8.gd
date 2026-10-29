extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## draw_line_depth8 and restore_line_depth8, checked against the ORIGINAL bytes:
## tools/strict_port/gen_line8_cases.py runs them in the m68k_emu interpreter for lines in every
## octant on a patterned screen and backup (fixtures/line8_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/line8_cases.json")
