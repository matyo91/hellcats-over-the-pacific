extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID02 := preload("res://strict_port/code/ID02.gd")

## The ID02 sound system routines (vbl_sound_handler_ch0_unrolled, vbl_sound_handler_ch0_variant,
## vbl_sound_handler_two_channel, init_sound_system), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id02_sound_cases.py runs ID02.bin in the m68k_emu interpreter with every
## trap and the chained sound hook logged (fixtures/id02_sound_cases.json); helpers/segment_cases.gd
## replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id02_sound_cases.json", ID02)
