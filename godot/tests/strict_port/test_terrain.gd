extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## create_fractal_contact_record, fractal_height_at and handle_terrain_contact, checked against
## the ORIGINAL bytes: tools/strict_port/gen_terrain_cases.py runs them in the m68k_emu interpreter
## on a small fractal terrain it builds (fixtures/terrain_cases.json, returned D0 included);
## helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/terrain_cases.json")
