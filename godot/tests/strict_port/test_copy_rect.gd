extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## copy_rect_depth8 and copy_rect_depth4, checked against the ORIGINAL bytes:
## tools/strict_port/gen_copy_rect_cases.py runs them in the m68k_emu interpreter for every
## destination / source alignment (fixtures/copy_rect_cases.json); helpers/original_cases.gd
## replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/copy_rect_cases.json")
