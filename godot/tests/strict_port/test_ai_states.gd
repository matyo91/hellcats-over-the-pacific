extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The AI state handlers (ai_attack_or_fly with ai_pursue_target, ai_fly, ai_fly_bomber,
## ai_dive_at_target, ai_bombing_run), the per-kind fly routines and the landing glide, checked
## against the ORIGINAL bytes: tools/strict_port/gen_ai_state_cases.py runs them on the binary
## image in the m68k_emu interpreter and records every byte changed outside the stack
## (fixtures/ai_state_cases.json); helpers/original_cases.gd replays the cases through the port.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/ai_state_cases.json")
