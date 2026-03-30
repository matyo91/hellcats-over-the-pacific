extends SceneTree
## Headless entry (from project root, folder containing project.godot):
##   godot --headless --script hellcats/tests/test_rng.gd
##   godot --headless -s res://hellcats/tests/test_rng.gd
## Deterministic test vectors for Rng68k (ID05 LCG parity).

const Rng68kScript := preload("res://hellcats/core/rng.gd")

func _init() -> void:
	var ok := true
	# Build expected 15-bit sequence from seed 0 using reference LCG
	var want_15: Array[int] = []
	var state := 0
	for _i in range(5):
		state = (state * 0x41c64e6d + 0x3039) & 0xFFFFFFFF
		want_15.append(((state << 1) & 0xFFFFFFFF) >> 0x11)

	var r0 := Rng68kScript.new()
	r0.seed(0)
	for i in range(want_15.size()):
		var got := r0.next()
		if got != want_15[i]:
			print("FAIL seed=0 next() [%d] got %d want %d" % [i, got, want_15[i]])
			ok = false
	if ok:
		print("PASS seed=0 next() (15-bit)")

	# Seed 1: state after one step
	var r1 := Rng68kScript.new()
	r1.seed(1)
	var state1 := (1 * 0x41c64e6d + 0x3039) & 0xFFFFFFFF
	r1.next()
	if r1.get_state() != state1:
		print("FAIL seed=1 state after next() got 0x%x want 0x%x" % [r1.get_state(), state1])
		ok = false
	else:
		print("PASS seed=1 state")

	# next_u16 / next_u8: deterministic replay
	var r2 := Rng68kScript.new()
	r2.seed(12345)
	var u16_0 := r2.next_u16()
	var u16_1 := r2.next_u16()
	var r3 := Rng68kScript.new()
	r3.seed(12345)
	if r3.next_u16() != u16_0 or r3.next_u16() != u16_1:
		print("FAIL next_u16 replay")
		ok = false
	else:
		print("PASS next_u16 replay")

	var r4 := Rng68kScript.new()
	r4.seed(999)
	var u8_vals: Array[int] = []
	for _j in range(4):
		u8_vals.append(r4.next_u8())
	var r5 := Rng68kScript.new()
	r5.seed(999)
	for j in range(4):
		if r5.next_u8() != u8_vals[j]:
			print("FAIL next_u8 replay at %d" % j)
			ok = false
	if ok:
		print("PASS next_u8 replay")

	print("Result: %s" % ("ALL PASS" if ok else "SOME FAIL"))
	quit(0 if ok else 1)
