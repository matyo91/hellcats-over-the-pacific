extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x110000
const MATRIX := 0x20000
const SRC := 0x21000
const DST := 0x22000
const BIG := 0x40000

## Expected rows from an instruction-level model of 0x28dc..0x2974 / 0x2976..0x2a0c
## (muls.w x*m[i], y*m[3+i], z*m[6+i] added in that order, addi.l #$800, asr.l #12; move.w
## or move.l stores), independent of the C and of this port. The loop model of dbra d5 /
## clr.w / subq.l / bcc gives 0, 1, 3, 0x10000 and 0x10001 iterations for those counts.
const MATRIX_WORDS := [0x1000, -0x0800, 0x0123, 0x0400, 0x0fff, -0x1000, -0x8000, 0x7fff, 0x0001]
const VECTORS := [[100, -200, 300], [-0x8000, 0x7fff, -1], [0x1234, -0x4321, 0x0fed]]
const WORDS := [[-2350, 2150, 207], [-24568, -16401, 30441], [-32252, 13104, 17517]]
const LONGS := [[-2350, 2150, 207], [-24568, 49135, -35095], [-32252, 13104, 17517]]
## All words -0x8000: each sum is 3 * 2^30 + 0x800, which wraps to a negative long.
const WRAP_LONG := -262144
const WRAP_WORD := 0

func _setup(memory, matrix_words: Array, vectors: Array) -> void:
	for k in range(9):
		memory.write_u16(MATRIX + 2 * k, matrix_words[k] & 0xffff)
	for n in range(vectors.size()):
		for c in range(3):
			memory.write_u16(SRC + 12 * n + 2 + 4 * c, vectors[n][c] & 0xffff)

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	_setup(memory, MATRIX_WORDS, VECTORS)

	memory.write_u16(DST + 2, 0x5555)
	strict_port.transform_vecs12_by_matrix3(0, SRC, DST, MATRIX)
	ok = Assertions.assert_equal(memory.read_u16(DST + 2), 0x5555, "count 0 writes nothing") and ok

	strict_port.transform_vecs12_by_matrix3(3, SRC, DST, MATRIX)
	for n in range(3):
		var got := [memory.read_s16(DST + 12 * n + 2), memory.read_s16(DST + 12 * n + 6), memory.read_s16(DST + 12 * n + 10)]
		ok = Assertions.assert_equal(got, WORDS[n], "transform_vecs12_by_matrix3 record %d" % n) and ok

	strict_port.transform_vecs12_to_int3_by_matrix3(3, SRC, DST, MATRIX)
	for n in range(3):
		var got := [memory.read_s32(DST + 12 * n), memory.read_s32(DST + 12 * n + 4), memory.read_s32(DST + 12 * n + 8)]
		ok = Assertions.assert_equal(got, LONGS[n], "transform_vecs12_to_int3_by_matrix3 record %d" % n) and ok

	## In place (dst == src): all three inputs are loaded before the first store.
	strict_port.transform_vecs12_by_matrix3(1, SRC, SRC, MATRIX)
	ok = Assertions.assert_equal([memory.read_s16(SRC + 2), memory.read_s16(SRC + 6), memory.read_s16(SRC + 10)], WORDS[0], "in-place record") and ok

	_setup(memory, [-0x8000, -0x8000, -0x8000, -0x8000, -0x8000, -0x8000, -0x8000, -0x8000, -0x8000], [[-0x8000, -0x8000, -0x8000]])
	strict_port.transform_vecs12_to_int3_by_matrix3(1, SRC, DST, MATRIX)
	ok = Assertions.assert_equal(memory.read_s32(DST), WRAP_LONG, "32-bit sum wraps before asr") and ok
	strict_port.transform_vecs12_by_matrix3(1, SRC, DST, MATRIX)
	ok = Assertions.assert_equal(memory.read_s16(DST + 2), WRAP_WORD, "word store of the wrapped sum") and ok

	## High word of the count: 0x10001 records. With m[0] = 0 every processed record's x word
	## becomes 0, so record 0x10000 (the last) is cleared and record 0x10001 keeps its sentinel.
	_setup(memory, [0, 0, 0, 0, 0x1000, 0, 0, 0, 0x1000], [])
	memory.write_u16(BIG + 12 * 0x10000 + 2, 0x7777)
	memory.write_u16(BIG + 12 * 0x10001 + 2, 0x7777)
	strict_port.transform_vecs12_by_matrix3(0x10001, BIG, BIG, MATRIX)
	ok = Assertions.assert_equal(memory.read_u16(BIG + 12 * 0x10000 + 2), 0, "record 0x10000 (the 0x10001st) is transformed") and ok
	ok = Assertions.assert_equal(memory.read_u16(BIG + 12 * 0x10001 + 2), 0x7777, "record 0x10001 untouched") and ok
	return ok
