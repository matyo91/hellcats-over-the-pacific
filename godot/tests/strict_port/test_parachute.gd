extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The parachute controller: parachute_tick with parachute_descend, and
## destroy_parachute_controller, checked against the ORIGINAL bytes:
## tools/strict_port/gen_parachute_cases.py runs them on the binary image in the m68k_emu
## interpreter (spawn_mission_pool_object stubbed on both sides) and records every byte changed
## outside the stack (fixtures/parachute_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/parachute_cases.json")
