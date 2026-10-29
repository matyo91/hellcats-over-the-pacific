extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The template registration hooks (definition record +6 before the first controller is made),
## checked against the ORIGINAL bytes: tools/strict_port/gen_template_registration_cases.py runs
## every single-template hook and every slot-table fill level in the m68k_emu interpreter
## (fixtures/template_registration_cases.json, D0 included); helpers/original_cases.gd replays
## the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/template_registration_cases.json")
