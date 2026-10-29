extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## refresh_object_colours_for_depth, begin_flight_for_rank and apply_player_mouse_controls,
## checked against the ORIGINAL bytes: tools/strict_port/gen_flight_start_cases.py runs them in the
## m68k_emu interpreter (fixtures/flight_start_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/flight_start_cases.json")
