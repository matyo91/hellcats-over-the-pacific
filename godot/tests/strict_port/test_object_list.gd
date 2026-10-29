extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## copy_object_vertex_buffer, deactivate_object and collect_near_objects, checked against the
## ORIGINAL bytes: tools/strict_port/gen_object_list_cases.py builds each case's heap with the
## original allocator in the m68k_emu interpreter and records every byte the routine changes
## (fixtures/object_list_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/object_list_cases.json")
