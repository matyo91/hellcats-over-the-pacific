extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## remap_cached_panel_colours and remap_panel_colours_identity (ID03 0x6c1c / 0x71a2), checked
## against the ORIGINAL bytes: tools/strict_port/gen_id03_remap_cases.py runs ID03.bin (with ID01
## and ID02 behind their slots) in the m68k_emu interpreter on a seeded cached panel
## (fixtures/id03_remap_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_remap_cases.json", ID03)
