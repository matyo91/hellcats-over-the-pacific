extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The view distance and radar routines (set_view_distance, cycle_view_distance,
## reset_radar_tracks, update_radar_range_buttons, update_radar_scope), checked against the
## ORIGINAL bytes: tools/strict_port/gen_radar_cases.py runs them in the m68k_emu interpreter with
## the host / depth drawing routines logging their calls (fixtures/radar_cases.json);
## helpers/original_cases.gd replays the cases and compares the memory and the call logs.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/radar_cases.json")
