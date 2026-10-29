extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## update_heading_tape, begin_offscreen_drawing and end_offscreen_drawing, checked against the
## ORIGINAL bytes: tools/strict_port/gen_heading_tape_cases.py runs them in the m68k_emu
## interpreter with the host routines and copy_rect_depth8 logged
## (fixtures/heading_tape_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/heading_tape_cases.json")
