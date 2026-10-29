extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID04 := preload("res://strict_port/code/ID04.gd")

## The paused dialog and the About box (ID04 0x478 / 0x3a8c), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id04_about_cases.py runs ID04.bin (with ID01's switch helper) in the
## m68k_emu interpreter with every trap and slot logged and the events, ticks and button scripted
## (fixtures/id04_about_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id04_about_cases.json", ID04)
