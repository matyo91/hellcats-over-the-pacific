extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 session and redraw routines (begin_overlay_session, ensure_free_memory_and_init_sound,
## call_overlay_session_hooks, the update events, redraw_main_window), checked against the ORIGINAL
## bytes: tools/strict_port/gen_id02_session_cases.py runs ID02.bin in the m68k_emu interpreter with
## every trap, slot and hook logged (fixtures/id02_session_cases.json); helpers/segment_cases.gd
## replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_session_cases.json", ID02)
