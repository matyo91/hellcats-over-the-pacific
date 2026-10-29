extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The trap-free ID02 routines (design coordinates, back colour, decimal Pascal strings, the sound
## channel engine, the palette lookups), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id02_trapfree_cases.py runs ID02.bin in the m68k_emu interpreter
## (fixtures/id02_trapfree_cases.json); helpers/segment_cases.gd replays them.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_trapfree_cases.json", ID02)
