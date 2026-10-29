extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID04 := preload("res://strict_port/code/ID04.gd")

## show_mission_summary_dialog (ID04 0x2de6), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id04_summary_cases.py runs ID04.bin in the m68k_emu interpreter with every
## trap and slot logged and ModalDialog's item hits scripted (fixtures/id04_summary_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id04_summary_cases.json", ID04)
