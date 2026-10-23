extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const OBJ := 0x21000
const CTL := 0x21100
const DEF := 0x21800
const FACES := 0x21a00
const IDX := 0x21b00
const VERTS := 0x21c00
const SCRATCH := 0x21e00

## Expected values follow the disassembly of animate_landing_gear (0xfb2a). Template: vertex 0
## (0, 0, 0), a right gear leg (40, -10, 5) / (40, -60, 5) and its mirror (-40, -10, 5) /
## (-40, -60, 5); normal points (0, 9, 0) and (1, 2, 3). Face 0 is the body (byte +0x17 = 0),
## faces 1 and 2 are the legs ([1 2], [3 4]). Shift 0. With the gear down (0x2d) the angle is 0
## and both matrices are the identity, so every gear point lands back on the template; at 20
## the left leg mirrors the right one. The trig tables come from the original binary.

var memory
var port

func _setup(pos: int, gear_bits: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
	var fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 0)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	var vectors := [[0, 0, 0], [40, -10, 5], [40, -60, 5], [-40, -10, 5], [-40, -60, 5], [0, 9, 0], [1, 2, 3], [4, 5, 6]]
	for n in range(vectors.size()):
		for c in range(3):
			memory.write_u32(desc + 0x22 + 12 * n + 4 * c, vectors[n][c] & 0xffffffff)
	memory.write_u8(OBJ + 1, 1)
	memory.write_u32(OBJ + 0x24, PoolFixtureScript.ROOT)
	memory.write_u16(OBJ + 0x36, 5)
	memory.write_u16(OBJ + 0x3a, 3)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u32(OBJ + 0x48, FACES)
	for f in [[1, [1, 2]], [2, [3, 4]]]:
		var face: int = FACES + 0x20 * f[0]
		memory.write_u8(face + 0x17, 1)
		memory.write_u8(face + 0x13, 2)
		memory.write_u16(face + 0x14, 2)
		memory.write_u32(face + 0x18, IDX + 8 * f[0])
		for k in range(2):
			memory.write_u16(IDX + 8 * f[0] + 2 * k, f[1][k])
	memory.write_u8(FACES + 0x13, 0)
	memory.write_u32(CTL, OBJ)
	memory.write_u32(CTL + 4, DEF)
	memory.write_u16(DEF + 0x44, 0x80)
	memory.write_u16(CTL + 0x626, 0x200)
	memory.write_u16(CTL + 0x20, 0x10)
	memory.write_u16(CTL + 0x22, 0x20)
	memory.write_u16(CTL + 0x24, 0x30)
	memory.write_u8(CTL + 0x679, pos & 0xff)
	memory.write_u8(CTL + 0x67a, gear_bits)

func _vertex(i: int) -> Array:
	return [memory.read_s32(VERTS + 12 * i), memory.read_s32(VERTS + 12 * i + 4), memory.read_s32(VERTS + 12 * i + 8)]

func _body_matrix_matches() -> bool:
	port.a7 = STACK_TOP - 0x400
	port.build_attitude_matrix_x(0x180, 0x10, 0x20, 0x30, SCRATCH)
	port.a7 = STACK_TOP
	for i in range(0x12):
		if memory.read_u8(0x1d72c + i) != memory.read_u8(SCRATCH + i):
			return false
	return true

func run() -> bool:
	var ok := true

	## Gear arriving down (bit 1 set, position 0x2d): angle 0, identity swing; legs shown.
	_setup(0x2d, 2)
	ok = Assertions.assert_equal(port._jsr(0xfb0a, [CTL]), 1, "returns 1") and ok
	ok = Assertions.assert_equal([_vertex(1), _vertex(2), _vertex(3), _vertex(4), _vertex(6), _vertex(7)], [[40, -10, 5], [40, -60, 5], [-40, -10, 5], [-40, -60, 5], [1, 2, 3], [4, 5, 6]], "down: gear points and normals on the template") and ok
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x67a), memory.read_u8(FACES + 0x33) & 2, memory.read_u8(FACES + 0x53) & 2, _vertex(5), port.a7], [0, 0, 0, [0, 0, 0], STACK_TOP], "down: bits cleared, legs shown, body normal untouched") and ok
	ok = Assertions.assert_equal(_body_matrix_matches(), true, "body matrix 0x1d72c = build_attitude_matrix_x(0x200 - 0x80, 0x10, 0x20, 0x30)") and ok

	## Fully up: legs hidden, bit 0 set, bit 1 cleared; nothing swung.
	_setup(0, 2)
	port.animate_landing_gear(CTL)
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x67a), memory.read_u8(FACES + 0x33) & 2, memory.read_u8(FACES + 0x53) & 2, memory.read_u8(FACES + 0x13) & 2, _vertex(1)], [1, 2, 2, 0, [0, 0, 0]], "up: legs hidden, body face untouched") and ok

	## Moving (position 20): bit 1 set, legs swung - the left leg mirrors the right one in x.
	_setup(20, 0)
	port.animate_landing_gear(CTL)
	var r1: Array = _vertex(1)
	var r2: Array = _vertex(2)
	var l1: Array = _vertex(3)
	var l2: Array = _vertex(4)
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x67a), [l1[0], l1[1], l1[2]] == [-r1[0], r1[1], r1[2]], [l2[0], l2[1], l2[2]] == [-r2[0], r2[1], r2[2]], r2 != [40, -60, 5]], [2, true, true, true], "moving: legs swung, mirrored") and ok

	## Down and at rest (bit 1 clear): only the body matrix.
	_setup(0x2d, 0)
	port.animate_landing_gear(CTL)
	ok = Assertions.assert_equal([_vertex(1), memory.read_u8(FACES + 0x33) & 2, _body_matrix_matches()], [[0, 0, 0], 2, true], "at rest: gear untouched, body matrix built") and ok
	return ok
