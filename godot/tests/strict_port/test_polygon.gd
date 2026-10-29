extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## point_in_polygon_xy, project_face_vertices_yz and point_over_face_xz, checked against the
## ORIGINAL bytes: tools/strict_port/gen_polygon_cases.py runs them in the m68k_emu interpreter
## (fixtures/polygon_cases.json, returned D0 included); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/polygon_cases.json")
