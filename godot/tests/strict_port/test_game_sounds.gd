extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## update_game_sounds, checked against the ORIGINAL bytes: tools/strict_port/gen_game_sound_cases.py
## runs it in the m68k_emu interpreter with the host sound routines logged
## (fixtures/game_sound_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/game_sound_cases.json")
