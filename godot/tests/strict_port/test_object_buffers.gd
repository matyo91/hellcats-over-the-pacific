extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const OBJ := 0x21000
const STREAM := 0x21100

## Expected values follow the disassembly of 0x3da8 / 0x3e02 (band search), 0x4808 (face
## records), 0x4916 (pattern) and 0x4e06 (template pose).

var memory
var port
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = 0x2f000
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)

func run() -> bool:
	var ok := true
	_setup()
	## Bands: T[-1] = 0, T = 100, 200, 400, 800, max.
	var limits := [0, 100, 200, 400, 800, 0x7fffffff]
	for i in range(limits.size()):
		memory.write_u32(0x1b18c + 4 * i, limits[i])
	memory.write_u16(OBJ + 0x30, 1)
	ok = Assertions.assert_equal([port.update_object_distance_band(OBJ, 150), memory.read_s16(OBJ + 0x30)], [0, 1], "inside band 1 [100, 200): kept") and ok
	ok = Assertions.assert_equal([port.update_object_distance_band(OBJ, 450), memory.read_s16(OBJ + 0x30)], [1, 3], "450 -> band 3 [400, 800)") and ok
	ok = Assertions.assert_equal([port.update_object_distance_band(OBJ, 50), memory.read_s16(OBJ + 0x30)], [1, 0], "50 -> band 0 [0, 100)") and ok
	memory.write_u16(OBJ + 4, 4)
	ok = Assertions.assert_equal([port.update_record_distance_band(OBJ, 250), memory.read_s16(OBJ + 4)], [1, 2], "record word +4: 250 -> band 2") and ok

	## Face records: 2 faces (counts 3 and 1); byte +6 bit 1 with word +0x38 = 3 adds the trailer.
	memory.write_u16(OBJ + 0x3a, 2)
	memory.write_u16(OBJ + 0x38, 3)
	memory.write_u8(OBJ + 6, 2)
	var faces := [[0x11223344, [5, 6, 7, 8], 3, 0x4a, 0x99, [10, 11, 12]], [0x55667788, [1, 2, 3, 4], 1, 0x71, 0x77, [9]]]
	var at := STREAM
	for f in faces:
		memory.write_u32(at, f[0])
		for k in range(4):
			memory.write_u8(at + 4 + k, f[1][k])
		memory.write_u8(at + 8, f[2])
		memory.write_u8(at + 9, f[3])
		memory.write_u32(at + 0xa, f[4])
		for k in range(f[2]):
			memory.write_u16(at + 0xe + 2 * k, f[5][k])
		at += 0xe + 2 * f[2]
	port.build_object_poly_buffers(OBJ, STREAM)
	var rec: int = memory.read_u32(OBJ + 0x48)
	ok = Assertions.assert_equal(memory.read_u32(rec - 8), (2 * 0x20 + 2 * 6 + 3 * 2 + 7) / 8 + 1, "size 2 * 0x20 + 6 * 2 + 2 * 3") and ok
	ok = Assertions.assert_equal([memory.read_u32(rec + 0xc), memory.read_u8(rec + 0x13), memory.read_u16(rec + 0x14), memory.read_u8(rec + 0x16), memory.read_u8(rec + 0x17), memory.read_u32(rec + 0x1c)], [0x11223344, 8, 3, 0x40, 0x0a, 0x99], "face 0 fields") and ok
	var idx: int = memory.read_u32(rec + 0x18)
	ok = Assertions.assert_equal([memory.read_u16(idx), memory.read_u16(idx + 2), memory.read_u16(idx + 4)], [10, 11, 12], "face 0 indices") and ok
	ok = Assertions.assert_equal([memory.read_u32(rec + 0x20 + 0xc), memory.read_u16(rec + 0x20 + 0x14), memory.read_u8(rec + 0x20 + 0x16), memory.read_u16(memory.read_u32(rec + 0x20 + 0x18))], [0x55667788, 1, 0x70, 9], "face 1 (stream advanced 0xe + 2 * 3)") and ok
	ok = Assertions.assert_equal([memory.read_u16(rec + 0x40), memory.read_u16(rec + 0x42), memory.read_u16(rec + 0x44), memory.read_u16(0x1daa2)], [0, 1, 2, 1], "trailer 0..2; palette_changed") and ok

	## Pattern: face +4 = sext word host +0x88 table [level], byte +0xf = 0xff.
	memory.write_u32(PoolFixtureScript.WORLD + 0x88, 0x29000)
	memory.write_u16(0x29000 + 2 * 3, -7 & 0xffff)
	port.set_object_faces_bw_pattern(OBJ, 3)
	ok = Assertions.assert_equal([memory.read_s32(rec + 4), memory.read_u8(rec + 0xf), memory.read_s32(rec + 0x24), memory.read_u8(rec + 0x2f)], [-7, 0xff, -7, 0xff], "both faces patterned") and ok

	## Template pose: position and +0x14 from the descriptor, through the template chain.
	fixture.add_template(2, 0, [111, 222, 333])
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40 * 2
	memory.write_u32(desc + 0x12, 444)
	var shape := 0x21800
	memory.write_u8(shape + 1, 2)
	memory.write_u8(shape + 2, 0)
	memory.write_u32(shape + 0x24, PoolFixtureScript.ROOT)
	var table: int = memory.read_u32(PoolFixtureScript.ROOT + 0x30)
	memory.write_u32(table + 8, 1000) ## slot 0 offset x
	port.reset_object_to_template_pose(shape)
	ok = Assertions.assert_equal([memory.read_s32(shape + 0x18), memory.read_s32(shape + 0x1c), memory.read_s32(shape + 0x20), memory.read_s32(shape + 0x14)], [1111, 222, 333, 444], "descriptor pose plus the slot offset") and ok
	memory.write_u8(shape + 7, 2)
	memory.write_u32(shape + 0x18, 5)
	port.reset_object_to_template_pose(shape)
	ok = Assertions.assert_equal(memory.read_s32(shape + 0x18), 5, "byte +7 bit 1: left alone") and ok
	return ok
