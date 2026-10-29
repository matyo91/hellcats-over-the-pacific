extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## init_code_pointer_tables and fill_span_rows_8bit, checked against the ORIGINAL bytes:
## tools/strict_port/gen_span_fill_cases.py runs them in the m68k_emu interpreter on seeded
## background row records (fixtures/span_fill_cases.json); helpers/original_cases.gd replays them.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/span_fill_cases.json")
