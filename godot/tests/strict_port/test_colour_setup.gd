extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## overlay_patch_template_u16_pair, reset_palette_owner_tables, init_depth8_colour_state and
## init_depth4_colour_state, checked against the ORIGINAL bytes: tools/strict_port/gen_colour_setup_cases.py
## runs them in the m68k_emu interpreter on a real heap (fixtures/colour_setup_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/colour_setup_cases.json")
