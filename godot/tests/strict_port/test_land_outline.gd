extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x40000
const STACK_TOP := 0x3f000 ## a 0x1c08-byte frame below the entry
const OBJ := 0x21000
const FACES := 0x21100
const CLIP_GLOBALS := [0x20aee, 0x20aec, 0x20aea, 0x1b73e]

## Worked out by hand from the disassembly of 0x4958..0x4e04. Template (slot offsets 0, so
## the chain leaves it unchanged): vertices v0 (0, 0, 0), v1 (101, 3, 0), v2 (101, 7, 100),
## v3 (0, 0, 100); faces [0 1 2 3], [1 2 0], [0 0 0]. detail_ref (10, 20), shift 1: outline
## pairs ((x - 10) asr 1, (z - 20) asr 1), scaled back (v asl 1) + ref, so x 101 -> 100.
## Old +0x44: vertex 0 (5, 5, 5), normal points at 4..6 (5, 15, 5) (5, 5, 25) (35, 5, 5).

var memory
var port

func _setup(level: int, camera_x: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	var fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 0)
	memory.write_u16(PoolFixtureScript.WORLD + 0xa8, level)
	memory.write_u32(0x1d838, camera_x)
	memory.write_u32(0x1d724, 10)
	memory.write_u32(0x1d71c, 20)
	for g in CLIP_GLOBALS:
		memory.write_u16(g, 0x1111)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	memory.write_u16(desc + 0x1a, 4)
	memory.write_u16(desc + 0x1e, 3)
	var vectors := [[0, 0, 0], [101, 3, 0], [101, 7, 100], [0, 0, 100], [9, 9, 9], [9, 9, 9], [9, 9, 9]]
	for n in range(vectors.size()):
		for c in range(3):
			memory.write_u32(desc + 0x22 + 12 * n + 4 * c, vectors[n][c] & 0xffffffff)
	var packed := desc + 0x22 + 12 * vectors.size()
	for f in [[0, 1, 2, 3], [1, 2, 0], [0, 0, 0]]:
		memory.write_u8(packed + 8, f.size())
		for k in range(f.size()):
			memory.write_u16(packed + 0xe + 2 * k, f[k])
		packed += 0xe + 2 * f.size()
	memory.write_u8(OBJ, 2)
	memory.write_u8(OBJ + 1, 1)
	memory.write_u32(OBJ + 0x24, PoolFixtureScript.ROOT)
	memory.write_u16(OBJ + 0x34, 2)
	memory.write_u16(OBJ + 0x36, 4)
	memory.write_u16(OBJ + 0x3a, 3)
	memory.write_u32(OBJ + 0x48, FACES)
	var old := [[5, 5, 5], [0, 0, 0], [0, 0, 0], [0, 0, 0], [5, 15, 5], [5, 5, 25], [35, 5, 5]]
	memory.write_u32(OBJ + 0x44, port.heap_alloc(12 * old.size()))
	memory.write_u32(OBJ + 0x4c, port.heap_alloc(12 * old.size()))
	for n in range(old.size()):
		for c in range(3):
			memory.write_u32(memory.read_u32(OBJ + 0x44) + 12 * n + 4 * c, old[n][c])
	for f in range(3):
		memory.write_u8(FACES + 0x20 * f + 0x13, 2)
		memory.write_u32(FACES + 0x20 * f + 0x18, port.heap_alloc(2))

func _indices(face: int) -> Array:
	var out := []
	for k in range(memory.read_u16(face + 0x14)):
		out.append(memory.read_u16(memory.read_u32(face + 0x18) + 2 * k))
	return out

func _points(count: int) -> Array:
	var out := []
	for i in range(count):
		var p: int = memory.read_u32(OBJ + 0x44) + 12 * i
		out.append([memory.read_s32(p), memory.read_s32(p + 4), memory.read_s32(p + 8)])
	return out

func _hidden() -> Array:
	return [memory.read_u8(FACES + 0x13) & 2, memory.read_u8(FACES + 0x33) & 2, memory.read_u8(FACES + 0x53) & 2]

func _globals() -> Array:
	var out := []
	for g in CLIP_GLOBALS:
		out.append(memory.read_u16(g))
	return out

func run() -> bool:
	var ok := true

	## Level 0x1000 (divisor 0x1003), camera at 0: every vertex kept; limit 0x7fe4: no clipping.
	_setup(0x1000, 0)
	port.build_land_outline_at_detail(OBJ, 0x9000, 1, 0x7fe4)
	ok = Assertions.assert_equal([_indices(FACES), _indices(FACES + 0x20), _indices(FACES + 0x40), _hidden()], [[0, 1, 2, 3], [1, 2, 0], [0, 0, 0], [0, 0, 0]], "faces share the unique points") and ok
	ok = Assertions.assert_equal([memory.read_u16(OBJ + 0x36), memory.read_u32(OBJ + 4) & 0x40], [4, 0], "four unique points") and ok
	ok = Assertions.assert_equal(_points(7), [[0, 0, 0], [100, 0, 0], [100, 0, 100], [0, 0, 100], [0, 10, 0], [0, 0, 20], [30, 0, 0]], "points (y 0, x 101 through the shift -> 100), then the normal points rebased on the new vertex 0") and ok
	## Metric: |10| / 0 / |20| -> 20 + (10 asr 2) = 22. (22 asr 2) + 22 + 0x9000 = 0x901b, asl 2 =
	## 0x2406c -> 0x12036 -> 0x901b -> 0x480d: three steps.
	ok = Assertions.assert_equal([memory.read_s32(OBJ + 0x18), memory.read_s32(OBJ + 0x20), memory.read_u32(OBJ + 0x14), memory.read_u32(OBJ + 0x10), memory.read_u16(OBJ + 0x32)], [10, 20, 0x9000, 22, 3], "position = detail_ref, range, metric, detail shift") and ok
	ok = Assertions.assert_equal([_globals(), port.a7], [[0x1111, 0x1111, 0x1111, 0x1111], STACK_TOP], "clip bounds and a7 restored") and ok

	## Limit 30: outline (-5,-10) (45,-10) (45,40) (-5,40) clipped to x <= 30, then y <= 30:
	## (-5,30) (-5,-10) (30,-10) (30,30) -> scaled back (0,80) (0,0) (70,0) (70,80).
	_setup(0x1000, 0)
	port.build_land_outline_at_detail(OBJ, 0x9000, 1, 30)
	ok = Assertions.assert_equal([_indices(FACES), _points(4)], [[0, 1, 2, 3], [[0, 0, 80], [0, 0, 0], [70, 0, 0], [70, 0, 80]]], "face 0 clipped to the +-30 square") and ok
	ok = Assertions.assert_equal(_globals(), [0x1111, 0x1111, 0x1111, 0x1111], "clip bounds restored after clipping") and ok

	## Level 0 (divisor 3), camera x 600: face 0 keeps v0 and v2 (skipped 101 + 126 = 227 >=
	## 524 / 3 = 174), face 1 keeps v1 and v0 (100 + 101 = 201 >= 600 / 3), face 2 keeps v0:
	## fewer than three pairs everywhere -> all hidden, long +4 |= 0x40, +0x36 untouched.
	_setup(0, 600)
	port.build_land_outline_at_detail(OBJ, 0x9000, 1, 0x7fe4)
	ok = Assertions.assert_equal([_hidden(), memory.read_u32(OBJ + 4) & 0x40, memory.read_u16(OBJ + 0x36)], [[2, 2, 2], 0x40, 4], "thinned below three points: hidden") and ok
	return ok
