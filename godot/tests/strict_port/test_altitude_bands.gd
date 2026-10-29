extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## update_altitude_detail_bands, checked against the ORIGINAL bytes:
## tools/strict_port/gen_altitude_band_cases.py runs it in the m68k_emu interpreter on real heaps,
## land objects and far lists, with the destroy hook logged (fixtures/altitude_band_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/altitude_band_cases.json")
