extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## sort_group_parts_by_distance, checked against the ORIGINAL bytes:
## tools/strict_port/gen_sort_parts_cases.py runs it in the m68k_emu interpreter on seeded group
## objects with and without group lists (fixtures/sort_parts_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/sort_parts_cases.json")
