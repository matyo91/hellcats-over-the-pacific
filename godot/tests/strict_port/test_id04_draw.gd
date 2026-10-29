extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID04 := preload("res://strict_port/code/ID04.gd")

## The fourth ID04 batch (the high-score table, the targets-destroyed rows and list, the aircraft
## kill markers and the map view, with their user item procedures), checked against the ORIGINAL
## bytes: tools/strict_port/gen_id04_draw_cases.py runs ID04.bin (with ID01's switch helpers) in the
## m68k_emu interpreter with every trap and slot logged (fixtures/id04_draw_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id04_draw_cases.json", ID04)
