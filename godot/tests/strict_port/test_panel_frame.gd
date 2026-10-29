extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## draw_panel_frame_lines, checked against the ORIGINAL bytes:
## tools/strict_port/gen_panel_frame_cases.py runs it in the m68k_emu interpreter at each screen
## depth, with the host line routine logged (fixtures/panel_frame_cases.json);
## helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/panel_frame_cases.json")
