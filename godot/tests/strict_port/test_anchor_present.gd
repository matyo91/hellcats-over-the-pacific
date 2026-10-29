extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## find_anchor_point (with anchor_point_visitor), present_spans_to_window, present_bw_frame and
## load_player_fuel_and_bombs, checked against the ORIGINAL bytes:
## tools/strict_port/gen_anchor_present_cases.py runs them in the m68k_emu interpreter
## (fixtures/anchor_present_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/anchor_present_cases.json")
