extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const PacificConflict := preload("res://strict_port/code/pacific_conflict.gd")

## Expected values from an instruction-level model of 0x3cca..0x3da6 (adda.w low-word deltas,
## approx_dist3_xyz results kept as words, dbra from 4, add.l / asr.l #1 midpoints, signed
## cmp.w), independent of the C and of this port. The fourth case shows that only the low
## word of a delta is used (0x12345 -> 0x2345); the fifth, a distance above 0x7fff read back
## as a negative word.
const CASES := [
	[[0, 0, 0, 1000, 0, 0, 500, 300, 0], 300],
	[[0, 0, 0, 1000, 0, 0, -200, 0, 0], 200],
	[[100, -50, 30, -800, 400, -1200, -300, 100, -500], 57],
	[[0, 0, 0, 0x12345, 0, 0, 0x2345, 10, 0], 10],
	[[0, 0, 0, 100, 0, 0, 40000, 0, 0], -25636],
	[[-1, -1, -1, 3, 3, 3, 0, 0, 0], 0],
]

func run() -> bool:
	var ok := true
	for case in CASES:
		var a: Array = case[0]
		var got: int = PacificConflict.segment_point_min_distance(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8])
		ok = Assertions.assert_equal(got, case[1], "segment_point_min_distance(%s)" % [str(a)]) and ok
	return ok
