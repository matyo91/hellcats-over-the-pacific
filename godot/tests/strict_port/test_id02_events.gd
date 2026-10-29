extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 event and display-refresh routines (refresh_display_if_changed, reset_overlay_state,
## set_view_size_option, wait_for_click_or_key, show_resource_file_error_box, handle_mouse_down,
## poll_and_dispatch_event), checked against the ORIGINAL bytes: tools/strict_port/gen_id02_events_cases.py
## runs ID02.bin (with ID01's switch helper) in the m68k_emu interpreter with every trap, slot and hook
## logged (fixtures/id02_events_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_events_cases.json", ID02)
