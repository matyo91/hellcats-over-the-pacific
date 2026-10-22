extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const STACK_TOP := 0x2f000
const OUT := 0x21000
const A := 0x21100
const B := 0x21200
const C := 0x21300

## Expected values from an instruction-level model of 0x1d02..0x1d74 (muls.w products added
## in the binary's order A[r][0]B[0][c], A[r][1]B[1][c], A[r][2]B[2][c]; asr.l #12; move.w),
## independent of the C and of this port. The 32-bit wrap of the sum cannot reach the
## stored word (bits 12..27), so the vectors exercise the floor of negative sums instead.
const MIXED_A := [1, 2, 3, 4, 5, 6, 7, 8, 9]
const MIXED_B := [0x1000, -0x1000, 0x7fff, 3, -5, 0x123, -0x8000, 0x10, 0x800]
const MIXED_AB := [-23, -1, 9, -44, -4, 35, -65, -7, 61]
## build_attitude_matrix(0x3fc0, 0x0123, 0x1000, 0x2abc): same bases as test_attitude_bases;
## temp = (R4 * Rz) * Rx at a6 - 0x12 of finalize, out = temp * Ry.
const BUILD_TEMP := [-2025, -3549, 295, 3560, -2013, 224, -50, 367, 4078]
const BUILD_OUT := [-295, -3549, -2025, -224, -2013, 3560, -4078, 367, -50]

func _write(memory, base: int, values: Array) -> void:
	for k in range(9):
		memory.write_u16(base + 2 * k, values[k] & 0xffff)

func _read(memory, base: int) -> Array:
	var out := []
	for k in range(9):
		out.append(memory.read_s16(base + 2 * k))
	return out

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1ad8c + 0x200, true, "original binary readable") and ok
	if not ok:
		return false
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])

	_write(memory, A, MIXED_A)
	_write(memory, B, MIXED_B)
	var returned: int = strict_port.matmul3x3_s16(A, B, C)
	ok = Assertions.assert_equal(_read(memory, C), MIXED_AB, "matmul3x3_s16 mixed signs") and ok
	ok = Assertions.assert_equal(returned, B + 6, "matmul3x3_s16 returns b + 6 (a0)") and ok

	strict_port.a7 = STACK_TOP
	strict_port.build_attitude_matrix(0x3fc0, 0x0123, 0x1000, 0x2abc, OUT)
	ok = Assertions.assert_equal(_read(memory, OUT), BUILD_OUT, "build_attitude_matrix output") and ok
	ok = Assertions.assert_equal(_read(memory, STACK_TOP - 0x1c - 0x16), BUILD_TEMP, "finalize temp at a6 - 0x12") and ok
	ok = Assertions.assert_equal(strict_port.a7, STACK_TOP, "a7 restored") and ok
	return ok
