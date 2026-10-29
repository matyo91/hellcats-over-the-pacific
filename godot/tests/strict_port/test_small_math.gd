extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## A batch of small routines (block copy, kill check, attitude from a direction, the tagged
## attitude invokers, vector rotation, recolouring, back-face test, background rows, overlay
## reset, scaled acos), checked against the ORIGINAL bytes: tools/strict_port/gen_small_math_cases.py
## runs them in the m68k_emu interpreter (fixtures/small_math_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/small_math_cases.json")
