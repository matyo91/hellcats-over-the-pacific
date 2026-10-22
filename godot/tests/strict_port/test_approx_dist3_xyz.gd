extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const PacificConflict := preload("res://strict_port/code/pacific_conflict.gd")

## Expected values come from an instruction-level model of 0x3c68..0x3cc8 (suba.l deltas,
## abs_int through runtime $2de8, signed cmp.l / ble swaps, add.l, asr.l #2, add.l),
## independent of the C and of this port. The last two vectors exercise 32-bit wrapping.
const VECTORS := [
	[[0, 0, 0, 3, 4, 12], 13],
	[[10, 0, 0, 0, -8, 2], 12],
	[[5, 5, 5, 5, 5, 5], 0],
	[[7, 0, 0, 0, 0, 0], 7],
	[[-100, 200, -300, 100, -200, 300], 750],
	[[-1, 0, 0, 0x7fffffff, 0, 0], -0x20000000],
	[[0, 0, 0, 0x40000000, 0x40000000, 0x40000000], 0x20000000],
]

func run() -> bool:
	var ok := true
	for vector in VECTORS:
		var a: Array = vector[0]
		var actual: int = PacificConflict.approx_dist3_xyz(a[0], a[1], a[2], a[3], a[4], a[5])
		ok = Assertions.assert_equal(actual, vector[1], "approx_dist3_xyz(%s)" % [str(a)]) and ok
	return ok
