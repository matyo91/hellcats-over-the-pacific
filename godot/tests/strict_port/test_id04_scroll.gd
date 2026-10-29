extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID04 := preload("res://strict_port/code/ID04.gd")

## The second ID04 batch (pilot ranking and pruning, the scrolling text item and its scroll bar,
## the named sound, the event poll, the system check and the mission title), checked against the
## ORIGINAL bytes: tools/strict_port/gen_id04_scroll_cases.py runs ID04.bin (with ID01's switch
## helper) in the m68k_emu interpreter with every trap and slot logged
## (fixtures/id04_scroll_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id04_scroll_cases.json", ID04)
