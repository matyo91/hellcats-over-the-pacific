extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## player_slew_mode, checked against the ORIGINAL bytes: tools/strict_port/gen_slew_mode_cases.py
## runs it in the m68k_emu interpreter with spawn_ordnance_oriented recording its arguments
## (fixtures/slew_mode_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/slew_mode_cases.json")
