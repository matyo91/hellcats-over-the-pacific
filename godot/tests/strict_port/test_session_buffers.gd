extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The handle and session-buffer routines, checked against the ORIGINAL bytes:
## tools/strict_port/gen_session_buffer_cases.py runs them in the m68k_emu interpreter with the host
## Memory Manager hooks logged (fixtures/session_buffer_cases.json); helpers/original_cases.gd
## replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/session_buffer_cases.json")
