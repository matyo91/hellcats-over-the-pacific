extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The broad-phase collision tests (test_proximity_collision, test_player_vs_type0e_proximity,
## create_shape_contact_record, handle_player_contact, point_in_face_by_axis,
## test_object_collision), checked against the ORIGINAL bytes: tools/strict_port/
## gen_collision_cases.py runs them in the m68k_emu interpreter on heaps and shapes it builds,
## with the collision handler and the unported terrain routines logging their calls
## (fixtures/collision_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/collision_cases.json")
