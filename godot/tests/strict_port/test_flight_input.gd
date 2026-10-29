extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## process_flight_input_and_outcome, checked against the ORIGINAL bytes:
## tools/strict_port/gen_flight_input_cases.py runs it in the m68k_emu interpreter with the host
## sound routines logged (fixtures/flight_input_cases.json); helpers/original_cases.gd replays them
## and compares the returned outcome.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/flight_input_cases.json")
