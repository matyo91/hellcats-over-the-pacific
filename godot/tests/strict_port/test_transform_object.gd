extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## transform_and_project_object, checked against the ORIGINAL bytes:
## tools/strict_port/gen_transform_object_cases.py runs it in the m68k_emu interpreter with the
## controller pre-render hook logged (fixtures/transform_object_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/transform_object_cases.json")
