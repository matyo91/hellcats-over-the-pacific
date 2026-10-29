extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## prepare_instrument_panel (ID03 0x5cc4), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id03_prepare_cases.py runs ID03.bin (with ID01 and ID02 behind their
## slots) in the m68k_emu interpreter: a current cache entry, a stored one loaded, and the whole
## panel redrawn (fixtures/id03_prepare_cases.json); helpers/segment_cases.gd replays them with the
## same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_prepare_cases.json", ID03)
