extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## scan_convert_edge_rows, checked against the ORIGINAL bytes:
## tools/strict_port/gen_scan_convert_cases.py builds scenes with the original
## add_face_edges_to_rows and runs the scan converter in the m68k_emu interpreter
## (fixtures/scan_convert_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/scan_convert_cases.json")
