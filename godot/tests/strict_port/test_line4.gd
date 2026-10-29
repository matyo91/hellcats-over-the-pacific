extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## draw_line_depth4 and restore_line_depth4, checked against the ORIGINAL bytes:
## tools/strict_port/gen_line4_cases.py runs them in the m68k_emu interpreter for lines in every
## octant on a patterned 4-bit screen and backup (fixtures/line4_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/line4_cases.json")
