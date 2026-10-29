extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The effect log (replay_logged_effects, mark_effect_log_end) and the sound routines
## (stop_all_sound_channels, play_game_sound, stop_game_sound), checked against the ORIGINAL bytes:
## tools/strict_port/gen_sound_effect_log_cases.py runs them in the m68k_emu interpreter with the
## host sound routines logging their calls (fixtures/sound_effect_log_cases.json);
## helpers/original_cases.gd replays the cases and compares the memory and the call logs.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/sound_effect_log_cases.json")
