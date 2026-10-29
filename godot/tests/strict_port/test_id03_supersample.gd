extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## begin_instrument_supersample, the spinning disc and the ring with status indicators (ID03 0x1538 /
## 0x35e / 0x514), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id03_supersample_cases.py runs ID03.bin (with ID02 behind its slots) in the
## m68k_emu interpreter with every trap and slot logged (fixtures/id03_supersample_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_supersample_cases.json", ID03)
