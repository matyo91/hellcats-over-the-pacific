extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## collect_far_objects, build_visible_object_list and transform_int3_vecs_asr_by_1d744, checked
## against the ORIGINAL bytes: tools/strict_port/gen_visibility_cases.py runs them in the m68k_emu
## interpreter with the four broad-phase collision tests logging their calls
## (fixtures/visibility_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/visibility_cases.json")
