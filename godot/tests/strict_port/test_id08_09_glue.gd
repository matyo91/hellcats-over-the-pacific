extends RefCounted

const SegmentCases := preload("res://tests/strict_port/helpers/segment_cases.gd")
const ID08 := preload("res://strict_port/code/ID08.gd")
const ID09 := preload("res://strict_port/code/ID09.gd")

## ID09's SysEnvirons fallback and FSOpen glue and ID08's bootstrap, checked against the ORIGINAL
## bytes: tools/strict_port/gen_id08_09_glue_cases.py runs ID09.bin / ID08.bin in the m68k_emu
## interpreter with low memory set per case and every trap and slot logged (the parameter-block OS
## traps as "trap_a0" stand-ins; fixtures/id09_glue_cases.json, fixtures/id08_bootstrap_cases.json);
## helpers/segment_cases.gd replays them with the same stand-ins.
func run() -> bool:
	var ok := SegmentCases.replay("res://tests/strict_port/fixtures/id09_glue_cases.json", ID09)
	return SegmentCases.replay("res://tests/strict_port/fixtures/id08_bootstrap_cases.json", ID08) and ok
