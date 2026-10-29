extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## draw_sky_and_ground, checked against the ORIGINAL bytes: tools/strict_port/gen_sky_ground_cases.py
## runs it in the m68k_emu interpreter on a real heap with the span filler, the depth-1 host
## routine and the cursor hook logged (fixtures/sky_ground_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/sky_ground_cases.json")
