extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## overlay_main_entry, overlay_initialise, the two rts stubs and respawn_player_at_anchor, checked
## against the ORIGINAL bytes: tools/strict_port/gen_overlay_entry_cases.py runs them in the
## m68k_emu interpreter (fixtures/overlay_entry_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/overlay_entry_cases.json")
