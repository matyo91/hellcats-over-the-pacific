extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 routines that call the Toolbox (handle and port wrappers, fill pattern, draw colour,
## offscreen colour port), checked against the ORIGINAL bytes: tools/strict_port/gen_id02_glue_cases.py
## runs ID02.bin in the m68k_emu interpreter with every jump-table slot and trap logged
## (fixtures/id02_glue_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_glue_cases.json", ID02)
