extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## The second ID03 batch (the inset face oval region, compositing and finishing a supersampled
## instrument, the vector glyph string and vector number), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id03_glyph_cases.py runs ID03.bin (with ID02 behind its slots) in the
## m68k_emu interpreter with every trap and slot logged (fixtures/id03_glyph_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_glyph_cases.json", ID03)
