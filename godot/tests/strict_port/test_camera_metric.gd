extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const CAMERA_X := 0x1d838
const CAMERA_Y := 0x1d834
const CAMERA_Z := 0x1d830
const OBJECT := 0x20000

## Expected values come from an instruction-level model of 0x3b98..0x3bfe and
## 0x3c00..0x3c66 (suba.l against $1d838 / $1d834 / $1d830, abs_int through runtime
## $2de8, the binary's own d2 / d3 / d1 swap order, add.l, asr.l #2, add.l), independent
## of the C and of this port. Camera = (1000, -200, 0x7fffff00).
const VECTORS := [
	[[1000, -200, 0x7fffff00], 0],
	[[1300, 200, 0x7fffff00 - 50], 487],
	[[-0x7fffffff, 0, 0], -1610613192],
	[[0, 0x40000000, -0x3fffff00], 1342178092],
]

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	memory.write_u32(CAMERA_X, 1000)
	memory.write_u32(CAMERA_Y, -200 & 0xffffffff)
	memory.write_u32(CAMERA_Z, 0x7fffff00)
	for vector in VECTORS:
		var p: Array = vector[0]
		ok = Assertions.assert_equal(strict_port.compute_camera_abs_metric(p[0], p[1], p[2]), vector[1], "compute_camera_abs_metric(%s)" % [str(p)]) and ok
		memory.write_u32(OBJECT + 0x0c, 0xa5a5a5a5)
		memory.write_u32(OBJECT + 0x14, 0x5a5a5a5a)
		memory.write_u32(OBJECT + 0x18, p[0] & 0xffffffff)
		memory.write_u32(OBJECT + 0x1c, p[1] & 0xffffffff)
		memory.write_u32(OBJECT + 0x20, p[2] & 0xffffffff)
		ok = Assertions.assert_equal(strict_port.update_object_camera_metric(OBJECT), vector[1], "update_object_camera_metric returns D0 for %s" % [str(p)]) and ok
		ok = Assertions.assert_equal(memory.read_s32(OBJECT + 0x10), vector[1], "update_object_camera_metric stores +0x10 for %s" % [str(p)]) and ok
		ok = Assertions.assert_equal(memory.read_u32(OBJECT + 0x0c), 0xa5a5a5a5, "+0x0c untouched") and ok
		ok = Assertions.assert_equal(memory.read_u32(OBJECT + 0x14), 0x5a5a5a5a, "+0x14 untouched") and ok
	return ok
