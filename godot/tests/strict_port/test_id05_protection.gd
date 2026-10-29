extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID05 := preload("res://strict_port/code/ID05.gd")

## The trap-free ID05 routines (random numbers, base-26 codes, overlay poisoning, the challenge
## table and response check, code packing), checked against the ORIGINAL bytes:
## tools/strict_port/gen_id05_protection_cases.py runs ID05.bin in the m68k_emu interpreter
## (fixtures/id05_protection_cases.json); helpers/segment_cases.gd replays them.
func run() -> bool:
	return SegmentCases.replay("res://tests/strict_port/fixtures/id05_protection_cases.json", ID05)
