extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## run_flight_session, checked against the ORIGINAL bytes: tools/strict_port/gen_id02_flight_cases.py
## runs ID02.bin (with ID01's switch helpers) in the m68k_emu interpreter with every trap, slot and
## overlay hook logged and the key hook's results, events and ticks scripted
## (fixtures/id02_flight_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_flight_cases.json", ID02)
