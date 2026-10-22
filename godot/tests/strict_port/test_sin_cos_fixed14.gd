extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
## The tables are copied from the immutable original binary: file 0x1ab8c / 0x1ad8c are
## the runtime addresses $1ab6c / $1ad6c that lea.l names (runtime = file - 0x20 here).
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const SIN_FILE := 0x1ab8c
const COS_FILE := 0x1ad8c
const SIN_TABLE := 0x1ab6c
const COS_TABLE := 0x1ad6c

## [angle, sin, cos]: expected values from an instruction-level model of 0x1d76..0x1dd6 and
## 0x1dd8..0x1e38 over the same table bytes, independent of the C and of this port. They
## cover the fraction steps, the quarter turns, the floor of a negative delta (cos 0x1020)
## and the masked next index at the end of the table (0x3fc0 / 0x3fff).
const VECTORS := [
	[0x0, 0, 4096], [0x1, 1, 4096], [0x20, 50, 4096], [0x3f, 99, 4096],
	[0x40, 101, 4095], [0x41, 102, 4095], [0x123, 455, 4070], [0x1000, 4096, 0],
	[0x1020, 4096, -50], [0x2000, 0, -4096], [0x2abc, -3560, -2025], [0x3000, -4096, 0],
	[0x3fc0, -101, 4095], [0x3fff, -2, 4095],
]

func run() -> bool:
	var ok := true
	var path := ProjectSettings.globalize_path("res://").path_join(BINARY_PATH)
	var binary := FileAccess.get_file_as_bytes(path)
	ok = Assertions.assert_equal(binary.size() >= COS_FILE + 0x200, true, "original binary readable at %s" % path) and ok
	if not ok:
		return false
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	for i in range(0x200):
		memory.write_u8(SIN_TABLE + i, binary[SIN_FILE + i])
		memory.write_u8(COS_TABLE + i, binary[COS_FILE + i])
	for vector in VECTORS:
		ok = Assertions.assert_equal(strict_port.sin_fixed14(vector[0]), vector[1], "sin_fixed14(0x%x)" % vector[0]) and ok
		ok = Assertions.assert_equal(strict_port.cos_fixed14(vector[0]), vector[2], "cos_fixed14(0x%x)" % vector[0]) and ok
	return ok
