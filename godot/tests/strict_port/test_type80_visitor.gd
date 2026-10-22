extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const STACK_TOP := 0x2f000
const WORLD := 0x23000
const BASE := 0x24000
const GROUP := 0x24100
const LEAF := 0x24300
const POINT := 0x25000

## One group record (angles 0x400, 0, 0; offsets 100, 0, -100) over one leaf (scale shift 1,
## four vertices, faces: type 0x80 over vertices 0, 1, 3, then a type 0x10 face). Camera
## (500, -300, 2000). Expected centroid (134, 449, 567), metric 1711, from a model of
## 0xaba..0xbe8 with the earlier instruction models (composer 0x24f8, 0x2ada, 0x1c5c, 0x3c00),
## independent of the C and of this port.
const VERTS := [[1000, -200, 3000], [-800, 600, 1500], [90, 70, -4000], [5, 5, 5]]
const CENTROID := [134, 449, 567]

func _long3(memory, address: int) -> Array:
	return [memory.read_s32(address), memory.read_s32(address + 4), memory.read_s32(address + 8)]

func _write_long3(memory, address: int, v: Array) -> void:
	for c in range(3):
		memory.write_u32(address + 4 * c, v[c] & 0xffffffff)

func _world(binary: PackedByteArray, type80: bool):
	var memory = Memory68kScript.new(MEMORY_SIZE)
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
	_write_long3(memory, 0x1d830, [2000, 0, 0])
	memory.write_u32(0x1d834, -300 & 0xffffffff)
	memory.write_u32(0x1d838, 500)
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(WORLD + 0x8c, BASE)
	memory.write_u16(WORLD + 0x90, 0)
	memory.write_u32(BASE + 0x8e, GROUP - BASE)
	memory.write_u8(GROUP, 3)
	memory.write_u16(GROUP + 0x18, 1)
	var record := GROUP + 0x1a
	memory.write_u16(record + 2, 0x400)
	_write_long3(memory, record + 8, [100, 0, -100])
	memory.write_u32(record + 0x14, LEAF - BASE)
	memory.write_u8(LEAF, 2)
	memory.write_u16(LEAF + 0x18, 1)
	memory.write_u16(LEAF + 0x1a, VERTS.size())
	memory.write_u16(LEAF + 0x1e, 2)
	for n in range(VERTS.size()):
		_write_long3(memory, LEAF + 0x22 + 12 * n, VERTS[n])
	var face := LEAF + 0x22 + 12 * VERTS.size() + 12 * 2
	memory.write_u8(face + 8, 3)
	memory.write_u8(face + 9, 0x83 if type80 else 0x13)
	for k in range(3):
		memory.write_u16(face + 0xe + 2 * k, [0, 1, 3][k])
	face += 0xe + 2 * 3
	memory.write_u8(face + 8, 1)
	memory.write_u8(face + 9, 0x10)
	return memory

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1ad8c + 0x200, true, "original binary readable") and ok
	if not ok:
		return false

	## Far point: replaced by the type-0x80 centroid, which is near enough -> 1.
	var memory = _world(binary, true)
	var port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	_write_long3(memory, POINT, [400000, 0, 0])
	ok = Assertions.assert_equal(port.point_near_camera_or_type80_object(POINT), 1, "far point -> centroid found") and ok
	ok = Assertions.assert_equal(_long3(memory, POINT), CENTROID, "point replaced by the centroid") and ok
	ok = Assertions.assert_equal(port.compute_camera_abs_metric(CENTROID[0], CENTROID[1], CENTROID[2]), 1711, "centroid metric") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok

	## Near point: 1 at once, unchanged.
	_write_long3(memory, POINT, [600, -300, 2000])
	ok = Assertions.assert_equal(port.point_near_camera_or_type80_object(POINT), 1, "near point") and ok
	ok = Assertions.assert_equal(_long3(memory, POINT), [600, -300, 2000], "near point unchanged") and ok

	## No type-0x80 face: x stays 1000000000 -> 0.
	memory = _world(binary, false)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	_write_long3(memory, POINT, [400000, 7, 8])
	ok = Assertions.assert_equal(port.point_near_camera_or_type80_object(POINT), 0, "no type-0x80 face") and ok
	ok = Assertions.assert_equal(_long3(memory, POINT), [1000000000, 7, 8], "x left at 1000000000") and ok

	## The visitor keeps a nearer best (strict compare): best already at the centroid.
	memory = _world(binary, true)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	_write_long3(memory, POINT, CENTROID)
	port.for_each_mission_scene_object(0xa9a, POINT)
	ok = Assertions.assert_equal(_long3(memory, POINT), CENTROID, "equal metric keeps the best") and ok
	return ok
