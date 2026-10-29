extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## update_view_readouts_and_overlays, mark_view_overlays_drawn and c_strlen, checked against the
## ORIGINAL bytes: tools/strict_port/gen_readout_cases.py runs them in the m68k_emu interpreter
## with the host text routine and the three unported drawing routines logged
## (fixtures/readout_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/readout_cases.json")
