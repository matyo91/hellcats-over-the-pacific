extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## project_prepared_object, transform_face_vertices, clip_face_near_plane and submit_object_faces,
## checked against the ORIGINAL bytes: tools/strict_port/gen_object_pipeline_cases.py runs them in
## the m68k_emu interpreter on a small object with vertices behind the near plane
## (fixtures/object_pipeline_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/object_pipeline_cases.json")
