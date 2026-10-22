extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BUF_A := 0x21000
const BUF_B := 0x21400

## Expected outputs from an instruction-level model of 0xb190 / 0xb242 / 0xb2f4 / 0xb3aa
## (sext word limits, signed cmpa.l, 32-bit sub.l, muls.l 64-bit product, divs.l 64 / 32
## with the 68020 overflow rule), independent of the C and of this port. Clip rectangle
## x in [-20, 100], y in [-10, 120].
const SQUARE := [[-50, -50], [150, -30], [130, 170], [-70, 150]]
const AFTER_X_MIN := [[-20, -47], [150, -30], [130, 170], [-20, 155]]
const AFTER_X_MAX := [[-20, -47], [100, -35], [100, 167], [-20, 155]]
const AFTER_Y_MIN := [[-20, -10], [100, -10], [100, 167], [-20, 155]]
const AFTER_Y_MAX := [[-20, 120], [-20, -10], [100, -10], [100, 120]]
## 32-bit wrap of the x differences makes the 64 / 32 quotient overflow; divs.l then leaves
## the low long of the product (0 here) in the quotient register.
const WRAP_IN := [[-0x80000000, 0], [0x7fffffff, 100]]
const WRAP_OUT := [[0, 0], [0, 0], [0x7fffffff, 100]]

func _write(memory, address: int, points: Array) -> void:
	for n in range(points.size()):
		memory.write_u32(address + 8 * n, points[n][0] & 0xffffffff)
		memory.write_u32(address + 8 * n + 4, points[n][1] & 0xffffffff)

func _read(memory, address: int, count: int) -> Array:
	var out := []
	for n in range(count):
		out.append([memory.read_s32(address + 8 * n), memory.read_s32(address + 8 * n + 4)])
	return out

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var port = PacificConflictScript.new(memory)
	memory.write_u16(0x20aee, -20 & 0xffff)
	memory.write_u16(0x20aec, 100)
	memory.write_u16(0x20aea, -10 & 0xffff)
	memory.write_u16(0x1b73e, 120)

	_write(memory, BUF_A, SQUARE)
	var n: int = port.clip_polygon_x_min(BUF_A, 4, BUF_B)
	ok = Assertions.assert_equal(_read(memory, BUF_B, n), AFTER_X_MIN, "clip_polygon_x_min") and ok
	n = port.clip_polygon_x_max(BUF_B, n, BUF_A)
	ok = Assertions.assert_equal(_read(memory, BUF_A, n), AFTER_X_MAX, "clip_polygon_x_max") and ok
	n = port.clip_polygon_y_min(BUF_A, n, BUF_B)
	ok = Assertions.assert_equal(_read(memory, BUF_B, n), AFTER_Y_MIN, "clip_polygon_y_min") and ok
	n = port.clip_polygon_y_max(BUF_B, n, BUF_A)
	ok = Assertions.assert_equal(_read(memory, BUF_A, n), AFTER_Y_MAX, "clip_polygon_y_max") and ok

	_write(memory, BUF_A, [[-100, 0], [-90, 10], [-95, 20]])
	ok = Assertions.assert_equal(port.clip_polygon_x_min(BUF_A, 3, BUF_B), 0, "fully outside -> 0") and ok
	ok = Assertions.assert_equal(port.clip_polygon_y_max(BUF_A, 0, BUF_B), 0, "count 0 -> 0") and ok

	memory.write_u16(0x20aee, 0)
	_write(memory, BUF_A, WRAP_IN)
	n = port.clip_polygon_x_min(BUF_A, 2, BUF_B)
	ok = Assertions.assert_equal(_read(memory, BUF_B, n), WRAP_OUT, "divs.l overflow keeps the low product long") and ok
	return ok
