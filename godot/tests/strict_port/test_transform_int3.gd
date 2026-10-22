extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const MATRIX := 0x20000
const SRC := 0x21000
const DST := 0x21100

## Expected values from instruction-level models (independent of the C and of this port):
## 0x2b20..0x2bba: 64-bit muls.l sums x*m[0][j] + y*m[1][j] + z*m[2][j], result
## (lo lsr 12) | (hi asl 20); 0x2a50..0x2aba: asr.l by +0x32 (mod 64), word cut, muls.w
## sums + 0x800, asr.l #12, move.w.
const MATRIX_WORDS := [0x1000, -0x0800, 0x0123, 0x0400, 0x0fff, -0x1000, -0x8000, 0x7fff, 0x0001]
const INT3_CASES := [
	[[100, -200, 300], [-2350, 2149, 207]],
	[[0x7fffffff, -0x80000000, 0x12345678], [-832746433, -777416581, -1994841275]],
	[[-1, -1, -1], [6, -9, 0]],
]
const CAMERA := [0x0fff, 0x0010, -0x0020, -0x0010, 0x0fff, 0x0300, 0x0020, -0x0300, 0x0ffe]

func _write_long3(memory, address: int, v: Array) -> void:
	for c in range(3):
		memory.write_u32(address + 4 * c, v[c] & 0xffffffff)

func _words(memory, record: int) -> Array:
	return [memory.read_s16(record + 2), memory.read_s16(record + 6), memory.read_s16(record + 10)]

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	for k in range(9):
		memory.write_u16(MATRIX + 2 * k, MATRIX_WORDS[k] & 0xffff)

	## transform_int3_vecs_by_matrix3
	for n in range(INT3_CASES.size()):
		_write_long3(memory, SRC + 12 * n, INT3_CASES[n][0])
	memory.write_u32(DST, 0x55555555)
	ok = Assertions.assert_equal(strict_port.transform_int3_vecs_by_matrix3(0, SRC, DST, MATRIX), MATRIX + 0x12, "count 0 returns matrix + 18 (d0 = a0)") and ok
	ok = Assertions.assert_equal(memory.read_u32(DST), 0x55555555, "count 0 writes nothing") and ok
	var last: int = strict_port.transform_int3_vecs_by_matrix3(INT3_CASES.size(), SRC, DST, MATRIX)
	for n in range(INT3_CASES.size()):
		var got := [memory.read_s32(DST + 12 * n), memory.read_s32(DST + 12 * n + 4), memory.read_s32(DST + 12 * n + 8)]
		ok = Assertions.assert_equal(got, INT3_CASES[n][1], "transform_int3_vecs_by_matrix3 vector %d" % n) and ok
	ok = Assertions.assert_equal(last, INT3_CASES[2][1][2], "returns the last component") and ok
	strict_port.transform_int3_vecs_by_matrix3(1, SRC, SRC, MATRIX)
	ok = Assertions.assert_equal([memory.read_s32(SRC), memory.read_s32(SRC + 4), memory.read_s32(SRC + 8)], INT3_CASES[0][1], "in place") and ok

	## transform_listed_object_vecs12_by_1d744: visible_count 3, split 1 -> slots 1 and 2.
	for k in range(9):
		memory.write_u16(0x1d744 + 2 * k, CAMERA[k] & 0xffff)
	memory.write_u32(0x1c1d4, 3)
	memory.write_u32(0x1bdb8, 1)
	var obj_skip := 0x22000
	var obj_a := 0x22100
	var obj_b := 0x22200
	memory.write_u32(0x1c9dc, obj_skip)
	memory.write_u32(0x1c9e0, obj_a)
	memory.write_u32(0x1c9e4, obj_b)
	for spec in [[obj_skip, 0x23000, 1, 0], [obj_a, 0x23100, 2, 2], [obj_b, 0x23200, 1, 40]]:
		memory.write_u32(spec[0] + 0x4c, spec[1])
		memory.write_u16(spec[0] + 0x36, spec[2])
		memory.write_u16(spec[0] + 0x32, spec[3])
	_write_long3(memory, 0x23000, [0x11111111, 0x22222222, 0x33333333])
	_write_long3(memory, 0x23100, [0x12345, -0x6789a, 0x7ffff])
	_write_long3(memory, 0x2310c, [0, 0x7fffffff, 400])
	_write_long3(memory, 0x23200, [0x40000, -0x40000, 0x1234])
	strict_port.transform_listed_object_vecs12_by_1d744()
	ok = Assertions.assert_equal(_words(memory, 0x23100), [18539, 25116, 4550], "listed object A record 0 (shift 2)") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x23100), 0x0001, "high word of x left in place") and ok
	ok = Assertions.assert_equal(_words(memory, 0x2310c), [1, -20, 100], "listed object A record 1 (word cut)") and ok
	ok = Assertions.assert_equal(_words(memory, 0x23200), [0, -1, 0], "listed object B (shift 40)") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x23000), 0x11111111, "object before the split untouched") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x23004), 0x22222222, "object before the split untouched (y)") and ok
	return ok
