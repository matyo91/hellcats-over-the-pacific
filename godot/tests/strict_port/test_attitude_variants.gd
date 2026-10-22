extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const STACK_TOP := 0x2f000
const OUT := 0x21000
const TAG := 0x20ce4

## Expected out / temp matrices and composer tag from a model that executes each composer's
## disassembly (its pushes decide every matmul3x3_s16 (a, b, dst); the fills are interpreted
## move.w / clr.w / neg.w; matmul and sin / cos follow their instructions), independent of the
## C and of this port. The temp sits at a6 - 0x12 of the composer; each builder enters its
## composer at the stack depth given by its link / pushes / bsr (0x1c, 0x40 or 0x24).
const CASES := [
	["build_attitude_matrix_3ang_alt", [0x0123, 0x1000, 0x2abc], 0x1c, 0,
		[395, -225, 4070, 3537, -2013, -455, 2025, 3560, 0],
		[0, 455, 4070, 0, 4070, -455, -4096, 0, 0]],
	["build_attitude_matrix_x_alt", [0x0123, 0x1000, 0x2abc, 0x3fc0], 0x40, 0,
		[395, -326, 4063, 3537, -2002, -505, 2025, 3559, 87],
		[395, -225, 4070, 3537, -2013, -455, 2025, 3560, 0]],
	["build_attitude_matrix_3ang", [0x0123, 0x1000, 0x2abc], 0x1c, 0x2408,
		[-395, -3538, -2025, -224, -2013, 3560, -4070, 455, 0],
		[-2025, -3538, 395, 3560, -2013, 224, 0, 455, 4070]],
	["build_attitude_matrix_x", [0x3fc0, 0x0123, 0x1000, 0x2abc], 0x1c, 0x2468,
		[-395, -3538, -2025, -325, -2001, 3559, -4063, 503, -88],
		[-2025, -3538, 395, 3559, -2001, 325, -88, 503, 4063]],
	["build_attitude_matrix_6ang", [0x0123, 0x1000, 0x2abc, 0x3fc0, 0x0800, 0x3333], 0x24, 0x26e0,
		[3744, -1573, -542, 925, 854, 3897, -1382, -3683, 1135],
		[-542, -1573, -3744, 3897, 854, -925, 1135, -3683, 1382]],
	["build_attitude_matrix_6ang_alt", [0x0123, 0x1000, 0x2abc, 0x3fc0, 0x0800, 0x3333], 0x24, 0,
		[3986, 390, 851, 612, -3905, -1074, 708, 1172, -3860],
		[3986, -326, 879, 612, -2002, -3521, 708, 3559, -1900]],
]

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
	for case in CASES:
		var memory = Memory68kScript.new(MEMORY_SIZE)
		var strict_port = PacificConflictScript.new(memory)
		for i in range(0x200):
			memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
			memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
		strict_port.a7 = STACK_TOP
		var args: Array = case[1].duplicate()
		args.append(OUT)
		strict_port.callv(case[0], args)
		ok = Assertions.assert_equal(_read(memory, OUT), case[4], "%s out" % case[0]) and ok
		ok = Assertions.assert_equal(_read(memory, STACK_TOP - case[2] - 0x16), case[5], "%s temp at a6 - 0x12" % case[0]) and ok
		ok = Assertions.assert_equal(memory.read_u32(TAG), case[3], "%s composer tag" % case[0]) and ok
		ok = Assertions.assert_equal(strict_port.a7, STACK_TOP, "%s restores a7" % case[0]) and ok
	return ok
