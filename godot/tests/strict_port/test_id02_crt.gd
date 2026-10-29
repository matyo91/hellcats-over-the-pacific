extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 C runtime (abs_long .. ansi_strncat), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id02_crt_cases.py runs ID02.bin (with ID01's divide behind jump-table
## slots $5a / $62) in the m68k_emu interpreter (fixtures/id02_crt_cases.json);
## helpers/segment_cases.gd replays them.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_crt_cases.json", ID02)
