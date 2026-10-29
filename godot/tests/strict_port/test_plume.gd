extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The smoke plume shapes (plume_pre_render, shape_free_plume, shape_trailing_plume), checked
## against the ORIGINAL bytes: tools/strict_port/gen_plume_cases.py runs them in the m68k_emu
## interpreter (fixtures/plume_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/plume_cases.json")
