extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The shadow, turret and bullet pre-render hooks, checked against the ORIGINAL bytes:
## tools/strict_port/gen_pre_render_cases.py runs them in the m68k_emu interpreter
## (fixtures/pre_render_cases.json, returned D0 included); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/pre_render_cases.json")
