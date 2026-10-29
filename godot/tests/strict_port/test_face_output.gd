extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## output_face_colour, output_face_bw, add_face_edges_to_rows and track_ground_plane_horizon,
## checked against the ORIGINAL bytes: tools/strict_port/gen_face_output_cases.py runs them in the
## m68k_emu interpreter with the host polygon routine logged (fixtures/face_output_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/face_output_cases.json")
