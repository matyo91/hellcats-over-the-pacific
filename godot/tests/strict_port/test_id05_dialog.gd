extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID05 := preload("res://strict_port/code/ID05.gd")

## The rest of ID05 (template centring, the screen fingerprint, the 'DATA' / 'TEXT' 128 pairs, the
## code dialog's filter, the upper-cased item text and the protection dialog), checked against the
## ORIGINAL bytes: tools/strict_port/gen_id05_dialog_cases.py runs ID05.bin in the m68k_emu
## interpreter with every trap and slot logged and the texts and item hits scripted
## (fixtures/id05_dialog_cases.json); helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id05_dialog_cases.json", ID05)
