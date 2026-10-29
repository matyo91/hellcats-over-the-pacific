extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The ordnance controller (definition key 0xc): ordnance_tick with ordnance_ballistic_step and
## ordnance_detonation, and ordnance_collision, checked against the ORIGINAL bytes:
## tools/strict_port/gen_ordnance_cases.py runs them on the binary image in the m68k_emu
## interpreter (spawn_mission_pool_object stubbed on both sides) and records every byte changed
## outside the stack (fixtures/ordnance_cases.json); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/ordnance_cases.json")
