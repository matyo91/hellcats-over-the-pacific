extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The 4-bit span fillers (fill_span_rows_4bit_a / _b / _c) and their table inits, checked against
## the ORIGINAL bytes: tools/strict_port/gen_span4_cases.py runs them in the m68k_emu interpreter on
## seeded background row records (fixtures/span4_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/span4_cases.json")
