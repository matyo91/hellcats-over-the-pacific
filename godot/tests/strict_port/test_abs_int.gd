extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const PacificConflict := preload("res://strict_port/code/pacific_conflict.gd")

## Expected values come from an instruction-level model of 0x2e08..0x2e10
## (move.l 4(a7),d0; bge; neg.l d0), independent of the C and of this port.
const VECTORS := [
	[0, 0],
	[1, 1],
	[-1, 1],
	[0x7fffffff, 0x7fffffff],
	[-0x7fffffff, 0x7fffffff],
	[-0x80000000, -0x80000000],
	[0x80000000, -0x80000000],
	[-12345, 12345],
]

func run() -> bool:
	var ok := true
	for vector in VECTORS:
		var actual: int = PacificConflict.abs_int(vector[0])
		ok = Assertions.assert_equal(actual, vector[1], "abs_int(%d)" % vector[0]) and ok
	return ok
