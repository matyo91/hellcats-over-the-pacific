extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 start-up routines (initialize_application, main with its event loop bounded to two
## passes), checked against the ORIGINAL bytes: tools/strict_port/gen_id02_startup_cases.py runs
## ID02.bin (with ID01's switch helper) in the m68k_emu interpreter with every trap, slot and hook
## logged (fixtures/id02_startup_cases.json); helpers/segment_cases.gd replays them with the same
## stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_startup_cases.json", ID02)
