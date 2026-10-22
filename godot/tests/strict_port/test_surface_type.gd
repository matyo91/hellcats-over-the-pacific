extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const VERTS := 0x21100
const FACES := 0x21200
const INDEX := 0x21300
const DEFAULT_FACE := 0x2a000
const BUF := 0x22000

## Geometry chosen so the answers follow from the disassembly without arithmetic doubt:
## a square of vertices (+-400, 0, +-400) seen with shift 1 (word +0x32 = 0, +1) is +-200 in
## the projected words; a point projects to (x asr 1, z asr 1). Faces are tested from the last:
## the last has surface byte 0 (skipped), the first is 0x40 (grass). Objects are skipped when
## their metric or approx distance is out of range or long +4 has 0x42.

var memory
var port

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	memory.write_u32(0x1bda8, DEFAULT_FACE)
	memory.write_u8(DEFAULT_FACE + 0x16, 0x10)
	memory.write_u32(0x1c1e0, 1)
	memory.write_u32(0x1d4a4, OBJ)
	memory.write_u32(OBJ + 0x10, 115)
	memory.write_u32(OBJ + 0x14, 1000)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u32(OBJ + 0x48, FACES)
	memory.write_u16(OBJ + 0x3a, 2)
	var square := [[-400, 0, -400], [400, 0, -400], [400, 0, 400], [-400, 0, 400]]
	for n in range(4):
		for c in range(3):
			memory.write_u32(VERTS + 12 * n + 4 * c, square[n][c] & 0xffffffff)
		memory.write_u16(INDEX + 2 * n, n)
	for f in range(2):
		memory.write_u16(FACES + 0x20 * f + 0x14, 4)
		memory.write_u32(FACES + 0x20 * f + 0x18, INDEX)
	memory.write_u8(FACES + 0x16, 0x40)
	memory.write_u8(FACES + 0x20 + 0x16, 0)

func run() -> bool:
	var ok := true
	_setup()
	ok = Assertions.assert_equal(port.surface_type_at_point(100, 0, 60), 0x40, "inside the square -> 0x40") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 kept") and ok
	ok = Assertions.assert_equal(port.surface_type_at_point(900, 0, 60), 0x10, "outside -> default code") and ok
	memory.write_u32(OBJ + 4, 0x40)
	ok = Assertions.assert_equal(port.surface_type_at_point(100, 0, 60), 0x10, "flag 0x40 -> skipped") and ok
	memory.write_u32(OBJ + 4, 0)
	memory.write_u32(OBJ + 0x10, 115 + 1001)
	ok = Assertions.assert_equal(port.surface_type_at_point(100, 0, 60), 0x10, "metric difference > range -> skipped") and ok
	memory.write_u32(OBJ + 0x10, 115)
	memory.write_u8(FACES + 0x16, 0x80)
	ok = Assertions.assert_equal(port.surface_type_at_point(100, 0, 60), -128, "code 0x80 sign-extends (extb.l)") and ok
	memory.write_u8(FACES + 0x16, 0x40)
	memory.write_u32(0x24000 + 0x18, 100)
	memory.write_u32(0x24000 + 0x20, 60)
	ok = Assertions.assert_equal(port.surface_type_under_object(0x24000), 0x40, "surface_type_under_object uses +0x18 / +0x20") and ok
	memory.write_u32(0x1c1e0, 0x10000)
	ok = Assertions.assert_equal(port.surface_type_at_point(100, 0, 60), 0x10, "only the low word of the count") and ok

	## point_in_polygon_xz on a triangle (0,0) (100,0) (0,100) in words +2 / +10, point (0, 0)
	## after subtracting the origin: the vertices are written relative to it.
	var tri := [[-10, -10], [90, -10], [-10, 90]]
	for n in range(3):
		memory.write_u16(BUF + 12 * n + 2, tri[n][0] & 0xffff)
		memory.write_u16(BUF + 12 * n + 10, tri[n][1] & 0xffff)
		memory.write_u16(INDEX + 2 * n, n)
	ok = Assertions.assert_equal(port.point_in_polygon_xz(0, 0, BUF, 3, INDEX), 1, "point inside the triangle") and ok
	var far := [[50, 50], [150, 50], [50, 150]]
	for n in range(3):
		memory.write_u16(BUF + 12 * n + 2, far[n][0] & 0xffff)
		memory.write_u16(BUF + 12 * n + 10, far[n][1] & 0xffff)
	ok = Assertions.assert_equal(port.point_in_polygon_xz(0, 0, BUF, 3, INDEX), 0, "point outside the triangle") and ok
	## yz variant reads +6 instead of +2.
	for n in range(3):
		memory.write_u16(BUF + 12 * n + 6, tri[n][0] & 0xffff)
	ok = Assertions.assert_equal(port.point_in_polygon_yz(0, 0, BUF, 3, INDEX), 0, "yz: +10 still outside") and ok
	for n in range(3):
		memory.write_u16(BUF + 12 * n + 10, tri[n][1] & 0xffff)
	ok = Assertions.assert_equal(port.point_in_polygon_yz(0, 0, BUF, 3, INDEX), 1, "yz: inside with +6 / +10") and ok

	## project_face_vertices_xy: x and y (asr 2) minus the origins into +2 / +6.
	memory.write_u16(FACES + 0x14, 1)
	memory.write_u16(INDEX, 1)
	memory.write_u32(VERTS + 12 + 4, 0x404)
	port.project_face_vertices_xy(OBJ, 2, FACES, 7, -3, BUF)
	ok = Assertions.assert_equal([memory.read_s16(BUF + 12 + 2), memory.read_s16(BUF + 12 + 6)], [93, 260], "xy projection of vertex 1") and ok
	return ok
