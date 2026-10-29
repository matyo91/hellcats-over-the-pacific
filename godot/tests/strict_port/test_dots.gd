extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The bullet dot routines (plot_dot_depth8 / erase_dots_depth8, plot_dot_depth4 /
## erase_dots_depth4, plot_dot_bw), checked against the ORIGINAL bytes:
## tools/strict_port/gen_dot_cases.py runs them in the m68k_emu interpreter on a fake screen, with
## the 1-bit polygon fill logged together with its points (fixtures/dot_cases.json);
## helpers/original_cases.gd replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/dot_cases.json")
