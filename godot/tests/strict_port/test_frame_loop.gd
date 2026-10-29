extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The frame loop (advance_frame_and_tick_controllers, run_simulation_tick,
## reset_distance_base_globals), checked against the ORIGINAL bytes: tools/strict_port/
## gen_frame_loop_cases.py runs them in the m68k_emu interpreter with the controller ticks logging
## their calls (fixtures/frame_loop_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/frame_loop_cases.json")
