extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 display and settings routines (layout_game_window_and_view,
## configure_display_from_main_device, apply_settings_to_live_options), checked against the ORIGINAL
## bytes: tools/strict_port/gen_id02_display_cases.py runs ID02.bin (with ID01's switch helper) in the
## m68k_emu interpreter with every trap, slot and hook logged (fixtures/id02_display_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_display_cases.json", ID02)
