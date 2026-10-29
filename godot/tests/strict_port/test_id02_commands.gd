extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 menu routines (do_menu_command, start_new_mission), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id02_commands_cases.py runs ID02.bin (with ID01's switch helper) in the m68k_emu
## interpreter with every trap, slot and hook logged (fixtures/id02_commands_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_commands_cases.json", ID02)
