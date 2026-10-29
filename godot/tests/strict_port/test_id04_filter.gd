extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID04 := preload("res://strict_port/code/ID04.gd")

## The third ID04 batch (the ModalDialog filters and the fuel slider, the summary buttons, the
## rank-and-name title, the score text, conclude_mission, the map grid and plotting), checked
## against the ORIGINAL bytes: tools/strict_port/gen_id04_filter_cases.py runs ID04.bin (with ID01's switch
## helpers) in the m68k_emu interpreter with every trap and slot logged
## (fixtures/id04_filter_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id04_filter_cases.json", ID04)
