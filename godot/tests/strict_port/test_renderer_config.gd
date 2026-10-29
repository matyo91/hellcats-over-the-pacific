extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## configure_renderer_for_display, checked against the ORIGINAL bytes:
## tools/strict_port/gen_renderer_config_cases.py runs it in the m68k_emu interpreter on a real heap
## (fixtures/renderer_config_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/renderer_config_cases.json")
