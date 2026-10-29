extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## antialias_downsample_bw_3x (ID03 0xa3c), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id03_downsample_cases.py runs ID03.bin (with ID01 and ID02 behind their
## slots) in the m68k_emu interpreter over seeded 1-bit images (fixtures/id03_downsample_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_downsample_cases.json", ID03)
