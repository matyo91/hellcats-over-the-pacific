extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const Rng68kScript := preload("res://hellcats/core/rng.gd")

func run() -> bool:
	var ok := true
	var want_15: Array[int] = []
	var state := 0
	for _i in range(5):
		state = (state * 0x41c64e6d + 0x3039) & 0xFFFFFFFF
		want_15.append(((state << 1) & 0xFFFFFFFF) >> 0x11)

	var r0 := Rng68kScript.new()
	r0.seed(0)
	for i in range(want_15.size()):
		ok = Assertions.assert_equal(r0.next(), want_15[i], "rng seed=0 next[%d]" % i) and ok

	var r1 := Rng68kScript.new()
	r1.seed(1)
	var state1 := (1 * 0x41c64e6d + 0x3039) & 0xFFFFFFFF
	r1.next()
	ok = Assertions.assert_equal(r1.get_state(), state1, "rng seed=1 state after next") and ok

	var r2 := Rng68kScript.new()
	r2.seed(12345)
	var u16_0 := r2.next_u16()
	var u16_1 := r2.next_u16()
	var r3 := Rng68kScript.new()
	r3.seed(12345)
	ok = Assertions.assert_equal(r3.next_u16(), u16_0, "rng next_u16 replay 0") and ok
	ok = Assertions.assert_equal(r3.next_u16(), u16_1, "rng next_u16 replay 1") and ok

	var r4 := Rng68kScript.new()
	r4.seed(999)
	var u8_vals: Array[int] = []
	for _j in range(4):
		u8_vals.append(r4.next_u8())
	var r5 := Rng68kScript.new()
	r5.seed(999)
	for j in range(4):
		ok = Assertions.assert_equal(r5.next_u8(), u8_vals[j], "rng next_u8 replay %d" % j) and ok

	return ok
