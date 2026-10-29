extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID08 := preload("res://strict_port/code/ID08.gd")

## load_overlay_from_resource (ID08 0x6), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id08_loader_cases.py runs ID08.bin in the m68k_emu interpreter with every
## slot and trap logged and the overlay file played back through FSRead
## (fixtures/id08_loader_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id08_loader_cases.json", ID08)
