extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID03 := preload("res://strict_port/code/ID03.gd")

## The ID03 gauges (fuel, landing gear, flaps, ammunition, climb, tachometer,
## manifold pressure, altimeter, airspeed, direction, percent scale) and the panel section with
## numbered boxes, draw_instrument, the artificial horizon, the gyro and the turn and bank
## indicator, checked against the ORIGINAL bytes:
## tools/strict_port/gen_id03_gauges_cases.py runs ID03.bin (with ID02 behind its slots) in the
## m68k_emu interpreter with every trap and slot logged (fixtures/id03_gauges_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id03_gauges_cases.json", ID03)
