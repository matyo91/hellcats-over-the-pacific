extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID06 := preload("res://strict_port/code/ID06.gd")

## ID06's render_scanline_spans and rasterize_and_present, checked against the ORIGINAL bytes:
## tools/strict_port/gen_id06_render_cases.py renders scenes the original built (and continues a
## band from the registers it kept in its own code) in the m68k_emu interpreter
## (fixtures/id06_render_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id06_render_cases.json", ID06)
