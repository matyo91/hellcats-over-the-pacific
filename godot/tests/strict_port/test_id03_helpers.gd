extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## The first ID03 batch (text scaling, max3_int, the nearest palette entry, the 1-bit offscreen port,
## the dial arc, the colour port on a buffer, close_port_glue, the identity colour remap), checked
## against the ORIGINAL bytes: tools/strict_port/gen_id03_helpers_cases.py runs ID03.bin (with ID02's
## abs_long and memset for real) in the m68k_emu interpreter with every trap and slot logged
## (fixtures/id03_helpers_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_helpers_cases.json", ID03)
