extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## emit_face_chain, emit_faces_bsp, emit_faces_in_order and emit_faces_unnumbered, checked against
## the ORIGINAL bytes: tools/strict_port/gen_face_emit_cases.py runs them in the m68k_emu
## interpreter on seeded random face sets (fixtures/face_emit_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/face_emit_cases.json")
