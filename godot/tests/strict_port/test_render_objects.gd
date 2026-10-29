extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## render_visible_objects, checked against the ORIGINAL bytes:
## tools/strict_port/gen_render_objects_cases.py runs it in the m68k_emu interpreter over visible
## lists of prepared objects, with the face output and part sort logged
## (fixtures/render_objects_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/render_objects_cases.json")
