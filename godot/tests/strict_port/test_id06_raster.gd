extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID06 := preload("res://strict_port/code/ID06.gd")

## The ID06 rasteriser set-up and edge routines (patterns, colour map, aligned blocks, raster
## target, row table, edge pool, polygon edges, band rebasing), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id06_raster_cases.py runs ID06.bin in the m68k_emu interpreter with the
## Memory Manager slots logged (fixtures/id06_raster_cases.json); helpers/segment_cases.gd replays
## them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id06_raster_cases.json", ID06)
