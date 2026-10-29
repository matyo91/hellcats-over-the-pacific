extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The radar blip routines (8-bit / 4-bit erase and draw, 1-bit host rectangle), checked against the
## ORIGINAL bytes: tools/strict_port/gen_radar_blip_cases.py runs them in the m68k_emu interpreter on
## a fake frame and saved panel (fixtures/radar_blip_cases.json); helpers/original_cases.gd replays
## the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/radar_blip_cases.json")
