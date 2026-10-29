extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## update_ground_scatter_objects, checked against the ORIGINAL bytes:
## tools/strict_port/gen_ground_scatter_cases.py runs it in the m68k_emu interpreter with the pool
## spawn stubbed and logging every call (fixtures/ground_scatter_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/ground_scatter_cases.json")
