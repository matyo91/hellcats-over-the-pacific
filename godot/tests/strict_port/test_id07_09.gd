extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID07 := preload("res://strict_port/code/ID07.gd")
const ID08 := preload("res://strict_port/code/ID08.gd")
const ID09 := preload("res://strict_port/code/ID09.gd")

## The small segments - ID07's string table, ID08's beep-and-exit and payload read, ID09's
## SwapMMUMode glue and Pascal-to-C conversion - checked against the ORIGINAL bytes:
## tools/strict_port/gen_id07_09_cases.py runs each segment in the m68k_emu interpreter
## (fixtures/id07_cases.json, id08_cases.json, id09_cases.json); helpers/segment_cases.gd replays
## them with the same stand-ins.
func run() -> bool:
	var ok := SegmentCases.replay("res://tests/strict_port/fixtures/id07_cases.json", ID07)
	ok = SegmentCases.replay("res://tests/strict_port/fixtures/id08_cases.json", ID08) and ok
	return SegmentCases.replay("res://tests/strict_port/fixtures/id09_cases.json", ID09) and ok
