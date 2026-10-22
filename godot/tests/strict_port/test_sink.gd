extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x40000
const STACK_TOP := 0x3f000
const OBJ := 0x21000
const FACES := 0x21100
## sin / cos tables copied from the immutable original binary (runtime = file - 0x20), as
## in test_sin_cos_fixed14.gd: angles 0 then give the identity matrix (4096 on the diagonal).
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const SIN_FILE := 0x1ab8c
const COS_FILE := 0x1ad8c

## Worked out by hand from the disassembly of 0x1562e (clip) and 0x15762 (sink). Template:
## vertices v0 (0, 50, 0), v1 (100, 50, 0), v2 (100, -50, 0), v3 (0, -50, 0), normal points (0,
## 0, 10 / 20 / 30); faces [0 1 2 3], [1 2 0] (packed byte +7 bit 1), [2 3 2]. Object at (1000,
## 0, 2000), shift 0, angles 0, drop 0, slot offsets 0. Clipping to y >= 0 gives
## face 0: (0,0,0) (0,50,0) (100,50,0) (100,0,0) -> ids 0..3 (buckets 0, 6, 31, 25);
## face 1: (100,50,0) (100,0,0) (50,0,0) (0,50,0) -> ids 2, 3, 4 (new, bucket 12), 1;
## face 2: nothing left -> hidden.

var memory
var port
var fixture

func _setup() -> int:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(0x200):
		memory.write_u8(SIN_FILE - 0x20 + i, binary[SIN_FILE + i])
		memory.write_u8(COS_FILE - 0x20 + i, binary[COS_FILE + i])
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 0)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	memory.write_u16(desc + 0x1a, 4)
	memory.write_u16(desc + 0x1e, 3)
	var vectors := [[0, 50, 0], [100, 50, 0], [100, -50, 0], [0, -50, 0], [0, 0, 10], [0, 0, 20], [0, 0, 30]]
	for n in range(vectors.size()):
		for c in range(3):
			memory.write_u32(desc + 0x22 + 12 * n + 4 * c, vectors[n][c] & 0xffffffff)
	var packed := desc + 0x22 + 12 * vectors.size()
	for f in [[[0, 1, 2, 3], 0], [[1, 2, 0], 2], [[2, 3, 2], 0]]:
		memory.write_u8(packed + 7, f[1])
		memory.write_u8(packed + 8, f[0].size())
		for k in range(f[0].size()):
			memory.write_u16(packed + 0xe + 2 * k, f[0][k])
		packed += 0xe + 2 * f[0].size()
	memory.write_u8(OBJ, 2)
	memory.write_u8(OBJ + 1, 1)
	memory.write_u32(OBJ + 0x24, PoolFixtureScript.ROOT)
	memory.write_u32(OBJ + 0x18, 1000)
	memory.write_u32(OBJ + 0x20, 2000)
	memory.write_u16(OBJ + 0x3a, 3)
	memory.write_u32(OBJ + 0x48, FACES)
	memory.write_u32(OBJ + 0x44, port.heap_alloc(12))
	memory.write_u32(OBJ + 0x4c, port.heap_alloc(12))
	for f in range(3):
		memory.write_u8(FACES + 0x20 * f + 0x13, 2)
		memory.write_u32(FACES + 0x20 * f + 0x18, port.heap_alloc(2))
	return desc

func _indices(face: int) -> Array:
	var out := []
	for k in range(memory.read_u16(face + 0x14)):
		out.append(memory.read_u16(memory.read_u32(face + 0x18) + 2 * k))
	return out

func _point(i: int) -> Array:
	var p: int = memory.read_u32(OBJ + 0x44) + 12 * i
	return [memory.read_s32(p), memory.read_s32(p + 4), memory.read_s32(p + 8)]

func run() -> bool:
	var ok := true
	_setup()
	ok = Assertions.assert_equal(port.sink_object_shape_at_waterline(OBJ, 0, 0, 0, 0), 1, "a face survives -> 1") and ok
	var f0 := FACES
	var f1 := FACES + 0x20
	var f2 := FACES + 0x40
	ok = Assertions.assert_equal([_indices(f0), memory.read_u8(f0 + 0x13) & 2], [[0, 1, 2, 3], 0], "face 0 clipped to 4 points; hidden bit cleared") and ok
	ok = Assertions.assert_equal([_indices(f1), memory.read_u8(f1 + 0x13) & 2], [[2, 3, 4, 1], 2], "face 1 shares points (ids reused); packed byte +7 bit 1 keeps it hidden") and ok
	ok = Assertions.assert_equal(memory.read_u8(f2 + 0x13) & 2, 2, "face 2 entirely below: hidden") and ok
	ok = Assertions.assert_equal([memory.read_u16(OBJ + 0x36), memory.read_u32(OBJ + 4) & 0x40], [5, 0], "five unique points") and ok
	ok = Assertions.assert_equal([_point(0), _point(1), _point(2), _point(3), _point(4)], [[0, 0, 0], [0, 50, 0], [100, 50, 0], [100, 0, 0], [50, 0, 0]], "points in id order (absolute x / z)") and ok
	ok = Assertions.assert_equal([_point(5), _point(6), _point(7)], [[0, -50, 10], [0, -50, 20], [0, -50, 30]], "normal points: minus old vertex 0, plus new vertex 0") and ok
	ok = Assertions.assert_equal(memory.read_u8(memory.read_u32(OBJ + 0x44) - 4) == 0xff and memory.read_u32(memory.read_u32(OBJ + 0x44) - 8) >= (8 * 12 + 7) / 8 + 1, true, "+0x44 regrown to (5 + 3) * 12 bytes") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok

	## Dropped by 60: everything below the waterline -> 0, long +4 |= 0x40.
	_setup()
	ok = Assertions.assert_equal(port.sink_object_shape_at_waterline(OBJ, 0, 0, 0, 60), 0, "all sunk -> 0") and ok
	ok = Assertions.assert_equal([memory.read_u32(OBJ + 4) & 0x40, memory.read_u8(FACES + 0x13) & 2], [0x40, 2], "object hidden, faces hidden") and ok

	## clip_polygon_y_nonneg alone: a face fully above keeps its points and returns 0.
	var verts := 0x22000
	var idx := 0x22100
	var out := 0x22200
	var count := 0x22300
	for n in range(3):
		memory.write_u16(verts + 12 * n + 2, 10 * n)
		memory.write_u16(verts + 12 * n + 6, 5)
		memory.write_u16(verts + 12 * n + 10, -n & 0xffff)
		memory.write_u16(idx + 2 * n, n)
	memory.write_u16(count, 3)
	ok = Assertions.assert_equal([port.clip_polygon_y_nonneg(count, verts, idx, out), memory.read_u16(count), memory.read_s16(out + 12 + 2), memory.read_s16(out + 24 + 10)], [0, 3, 10, -2], "nothing below: copied, flag 0") and ok
	return ok
