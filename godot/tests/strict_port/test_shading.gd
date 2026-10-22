extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const FACE := 0x21000
const OWNER := 0x22000 ## current owner table (256 longs)
const OTHER := 0x22400 ## another screen's owner table
const MAP := 0x22800 ## slot -> pixel index words
const SPECS := 0x22a00 ## pending ColorSpec table (count word +6, entries from +8)
const PATTERNS := 0x22c00 ## host +0x88 pattern words
const USAGE_A := 0x22e00
const USAGE_B := 0x22f00

## Expected values are worked out from the disassembly of 0x147a, 0x1548, 0x159e, 0x3e5c and
## 0x3ea0 (formulas noted with each case).

var memory
var port
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = 0x2f000
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	var world := PoolFixtureScript.WORLD
	memory.write_u32(0x1da7c, OWNER)
	memory.write_u32(0x1d85c, MAP)
	memory.write_u32(world + 0x72, SPECS)
	memory.write_u32(world + 0x88, PATTERNS)
	memory.write_u32(0x1d860, USAGE_A)
	memory.write_u32(0x1d864, USAGE_B)

func _rgb(face: int, r: int, g: int, b: int) -> void:
	memory.write_u8(face + 0xc, r)
	memory.write_u8(face + 0xd, g)
	memory.write_u8(face + 0xe, b)

func run() -> bool:
	var ok := true
	var world := PoolFixtureScript.WORLD

	## queue_face_palette_entry, normal mode: slot 5, map word 0x12, two pending entries already.
	_setup()
	memory.write_u8(FACE + 0xf, 5)
	memory.write_u16(MAP + 10, 0x12)
	memory.write_u16(SPECS + 6, 2)
	_rgb(FACE, 0, 0x40, 0xff)
	port.queue_face_palette_entry(FACE)
	var e := SPECS + 8 + 2 * 8
	ok = Assertions.assert_equal([memory.read_u32(OWNER + 20), memory.read_u32(FACE + 4), memory.read_u16(SPECS + 6)], [FACE, 0x1212, 3], "owner, idx | idx << 8, count") and ok
	ok = Assertions.assert_equal([memory.read_u16(e), memory.read_u16(e + 2), memory.read_u16(e + 4), memory.read_u16(e + 6)], [0x12, 0, 0x3fff, 0xfeff], "ColorSpec {idx, c * 256 - 1 clamped at 0}") and ok
	## Direct mode: v = r + g + b / 3 (0 -> 1).
	memory.write_u16(0x1d85a, 1)
	_rgb(FACE, 10, 20, 200)
	port.queue_face_palette_entry(FACE)
	ok = Assertions.assert_equal(memory.read_u32(FACE + 4), 0x6060, "direct: 10 + 20 + 66 = 0x60") and ok
	_rgb(FACE, 0, 0, 0)
	port.queue_face_palette_entry(FACE)
	ok = Assertions.assert_equal([memory.read_u32(FACE + 4), memory.read_u16(SPECS + 6)], [0x0101, 3], "direct: 0 -> 1; nothing queued") and ok

	## write_face_palette_slot with the multi-screen flag: other non-null tables get -face.
	_setup()
	memory.write_u16(world + 0xb4, 1)
	memory.write_u32(0x1da70, OWNER)
	memory.write_u32(0x1da74, OTHER)
	memory.write_u8(FACE + 0xf, 3)
	port.write_face_palette_slot(FACE)
	ok = Assertions.assert_equal([memory.read_u32(OWNER + 12), memory.read_u32(OTHER + 12)], [FACE, (-FACE) & 0xffffffff], "current owner = face, other screen = -face") and ok

	## assign_face_colour, depth 1: luma (19 * 100 + 38 * 150 + 7 * 200) / 64 = 140, stretched
	## (140 - 128) * 16 / 12 + 128 = 144; black stretches to -42 -> 0.
	_setup()
	memory.write_u16(0x1b826, 1)
	memory.write_u16(PATTERNS + 2 * 144, -2 & 0xffff)
	memory.write_u16(PATTERNS, 0x77)
	_rgb(FACE, 100, 150, 200)
	ok = Assertions.assert_equal([port.assign_face_colour(FACE), memory.read_u32(FACE + 4), memory.read_u8(FACE + 0xf)], [0, 0xfffffffe, 0xff], "depth 1: pattern word 144, sign-extended") and ok
	_rgb(FACE, 0, 0, 0)
	port.assign_face_colour(FACE)
	ok = Assertions.assert_equal(memory.read_u32(FACE + 4), 0x77, "depth 1: black clamps to 0") and ok
	## Depth 4: owner table long [25 r + 5 g + b].
	memory.write_u16(0x1b826, 4)
	memory.write_u32(OWNER + 4 * 38, 0xabcd)
	_rgb(FACE, 1, 2, 3)
	port.assign_face_colour(FACE)
	ok = Assertions.assert_equal(memory.read_u32(FACE + 4), 0xabcd, "depth 4: cube index 38") and ok
	## Depth 8: claim the first slot free in both maps from cursor 198 (198 used in A, 199 in B).
	memory.write_u16(0x1b826, 8)
	memory.write_u8(FACE + 0xf, 7)
	memory.write_u32(0x1bd80, 198)
	memory.write_u8(USAGE_A + 198, 1)
	memory.write_u8(USAGE_B + 199, 1)
	ok = Assertions.assert_equal(port.assign_face_colour(FACE), 0, "depth 8: claimed") and ok
	ok = Assertions.assert_equal([memory.read_u8(FACE + 0xf), memory.read_u32(OWNER), memory.read_u16(0x1daa2), memory.read_u32(0x1bd80)], [0, FACE, 1, 0], "slot 0 after wrapping at 200") and ok
	## A slot owned through -face is re-queued.
	memory.write_u8(FACE + 0xf, 9)
	memory.write_u32(OWNER + 36, (-FACE) & 0xffffffff)
	ok = Assertions.assert_equal([port.assign_face_colour(FACE), memory.read_u32(OWNER + 36)], [0, FACE], "re-queued own slot") and ok
	## No slot free in 200 tries -> 1.
	for i in range(200):
		memory.write_u8(USAGE_A + i, 1)
	memory.write_u8(FACE + 0xf, 4)
	memory.write_u32(0x1bd80, 50)
	ok = Assertions.assert_equal([port.assign_face_colour(FACE), memory.read_u32(0x1bd80)], [1, 50], "none free -> 1, cursor back where it started") and ok

	## shade_object_faces, depth 8 with haze, band 8: face flag bit 2 -> I = 0xffff -> factor
	## 0xffff -> c * 0xffff >> 16 = (99, 199, 0); haze (c * 24 + 8 * {0x7d, 0x84, 0xa8}) lsr 5 =
	## (105, 182, 42). The face owns its slot -> write_face_palette_slot.
	_setup()
	fixture.add_template(1, 0)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	memory.write_u8(desc + 0x22, 100) ## packed face 0 colour bytes (no template vectors)
	memory.write_u8(desc + 0x23, 200)
	memory.write_u8(desc + 0x24, 0)
	var obj := 0x23800
	var faces := 0x23900
	memory.write_u8(obj, 2)
	memory.write_u8(obj + 1, 1)
	memory.write_u32(obj + 0x24, PoolFixtureScript.ROOT)
	memory.write_u32(obj + 0x44, 0x23a00)
	memory.write_u32(obj + 0x48, faces)
	memory.write_u16(obj + 0x3a, 1)
	memory.write_u16(obj + 0x38, 2)
	memory.write_u16(obj + 0x30, 8)
	memory.write_u16(world + 0xaa, 1)
	memory.write_u8(faces + 0x13, 4)
	memory.write_u8(faces + 0xf, 6)
	memory.write_u32(OWNER + 24, faces)
	port.shade_object_faces(obj)
	ok = Assertions.assert_equal([memory.read_u8(faces + 0xc), memory.read_u8(faces + 0xd), memory.read_u8(faces + 0xe), memory.read_u8(faces + 0xf)], [105, 182, 42, 6], "haze blend; slot kept") and ok
	ok = Assertions.assert_equal(memory.read_u16(SPECS + 6), 1, "palette entry queued for the owned slot") and ok
	var snap := faces + 0x20 + 2 * 2
	ok = Assertions.assert_equal(memory.read_u32(snap), 0, "no snapshot without byte +6 bit 1") and ok
	## Byte +6 bit 1 is flag-long bit 0x200, one of the 0x1280 bits that switch the haze off for
	## the object; with the haze option on it also takes the snapshot (after faces and trailer).
	## A face not owning its slot gets 0.
	memory.write_u8(obj + 6, 2)
	memory.write_u32(OWNER + 24, 0)
	port.shade_object_faces(obj)
	ok = Assertions.assert_equal([memory.read_u8(faces + 0xc), memory.read_u8(faces + 0xd), memory.read_u8(faces + 0xf)], [99, 199, 0], "no haze; slot cleared") and ok
	ok = Assertions.assert_equal([memory.read_u32(snap), memory.read_u16(snap + 4)], [memory.read_u32(faces + 0xc), 0], "snapshot after faces and trailer") and ok
	## Depth 4: (c * f / 64 + 0x2000) asr 16 with f = 0xffff, then assign_face_colour (cube).
	memory.write_u16(world + 0xe, 4)
	memory.write_u16(0x1b826, 4)
	port.shade_object_faces(obj)
	ok = Assertions.assert_equal([memory.read_u8(faces + 0xc), memory.read_u8(faces + 0xd), memory.read_u8(faces + 0xf)], [1, 3, 0xff], "depth 4 rounding to the 5-level cube") and ok
	return ok
