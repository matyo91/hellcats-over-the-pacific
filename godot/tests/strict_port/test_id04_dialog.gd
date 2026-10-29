extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID04 := preload("res://strict_port/code/ID04.gd")

## The first ID04 batch (dialog item helpers, user item procedures, the radio group, the
## temporary window, the alerts, the kill report and pilot score), checked against the ORIGINAL
## bytes: tools/strict_port/gen_id04_dialog_cases.py runs ID04.bin in the m68k_emu interpreter with
## every trap and slot logged (fixtures/id04_dialog_cases.json); helpers/segment_cases.gd replays
## them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id04_dialog_cases.json", ID04)
