extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## overlay_init_template_pointer_tables and init_mission_object_tables, checked against the
## ORIGINAL bytes: tools/strict_port/gen_mission_tables_cases.py runs them in the m68k_emu
## interpreter on a real heap (fixtures/mission_tables_cases.json); helpers/original_cases.gd
## replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/mission_tables_cases.json")
