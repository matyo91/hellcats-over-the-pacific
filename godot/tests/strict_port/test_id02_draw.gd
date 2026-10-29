extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 polygon fill, notched frame pair, clipped image blit and colour-state check, checked
## against the ORIGINAL bytes: tools/strict_port/gen_id02_draw_cases.py runs ID02.bin in the m68k_emu
## interpreter with every trap, slot and the indirect service logged (fixtures/id02_draw_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_draw_cases.json", ID02)
