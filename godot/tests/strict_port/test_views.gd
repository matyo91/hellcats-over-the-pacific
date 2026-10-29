extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## resolve_bailout_outcome, update_bailout_view and begin_replay_view, checked against the ORIGINAL
## bytes: tools/strict_port/gen_view_cases.py runs them in the m68k_emu interpreter
## (fixtures/view_cases.json, returned D0 included); helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/view_cases.json")
