extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x40000
const STACK_TOP := 0x3f000 ## sink_object_shape_at_waterline needs a 0x3358-byte frame below the entry
const OBJ := 0x21000
const CTL := 0x21200
const TYPE_DEF := 0x21300

## Expected behaviour follows the disassembly of 0x4e6e..0x5114 (and of the ported
## shade_object_faces 0x3ea0 and sink_object_shape_at_waterline 0x15762 it reaches).
## build_land_outline_at_detail 0x4958 runs ported too. The sin / cos tables are copied from
## the original binary (runtime = file - 0x20) so the sink's attitude matrix is real.
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const SIN_FILE := 0x1ab8c
const COS_FILE := 0x1ad8c

var memory
var port
var fixture

## Template 1: a kind-2 descriptor with two template vectors and one face of 3 indices.
func _setup(flags5: int, flags6: int, flags7: int, with_ctl: bool) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(0x200):
		memory.write_u8(SIN_FILE - 0x20 + i, binary[SIN_FILE + i])
		memory.write_u8(COS_FILE - 0x20 + i, binary[COS_FILE + i])
	fixture.add_template(1, 0)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	memory.write_u16(desc + 0x1a, 1) ## one vertex + one normal point: the face colour follows them
	memory.write_u16(desc + 0x1e, 1)
	memory.write_u16(0x1bd8c, 0x7fff) ## light x
	var vectors := [[100, 0, -100], [-50, 20, 70]]
	for n in range(2):
		for c in range(3):
			memory.write_u32(desc + 0x22 + 12 * n + 4 * c, vectors[n][c] & 0xffffffff)
	var face := desc + 0x22 + 24
	memory.write_u32(face, 0x00a0b0c0)
	memory.write_u8(face + 8, 3)
	memory.write_u8(face + 9, 0x40)
	memory.write_u32(memory.read_u32(PoolFixtureScript.ROOT + 0x30) + 8, 1000) ## slot 0 offset x
	memory.write_u8(OBJ, 2)
	memory.write_u8(OBJ + 1, 1)
	memory.write_u8(OBJ + 2, 0)
	memory.write_u8(OBJ + 5, flags5)
	memory.write_u8(OBJ + 6, flags6)
	memory.write_u8(OBJ + 7, flags7)
	memory.write_u32(OBJ + 0x24, PoolFixtureScript.ROOT)
	memory.write_u16(OBJ + 0x34, 1) ## mesh offsets << 1
	memory.write_u16(OBJ + 0x36, 1)
	memory.write_u16(OBJ + 0x3a, 1)
	if with_ctl:
		memory.write_u32(OBJ + 8, CTL)
		memory.write_u32(CTL + 4, TYPE_DEF)
		memory.write_u16(TYPE_DEF, 0x16)
		for w in [[0x34, 3], [0x36, -4], [0x38, 5], [0x40, 6]]:
			memory.write_u16(CTL + w[0], w[1] & 0xffff)

func _vertex(n: int) -> Array:
	var base: int = memory.read_u32(OBJ + 0x44) + 12 * n
	return [memory.read_s32(base), memory.read_s32(base + 4), memory.read_s32(base + 8)]

func run() -> bool:
	var ok := true

	## Default path: template chain (slot offset 1000 << shift 1 on x), shading, flag 0x800.
	_setup(0, 0, 0, true)
	port.activate_near_range_object(OBJ)
	ok = Assertions.assert_equal([memory.read_u32(0x1b5a4), memory.read_u32(0x1b734)], [OBJ, 1], "published on object_pool") and ok
	ok = Assertions.assert_equal([memory.read_u8(memory.read_u32(OBJ + 0x44) - 4), memory.read_u32(OBJ + 0x4c) != 0], [5, true], "+0x44 / +0x4c: 24 bytes -> size class 5 (32-byte blocks)") and ok
	ok = Assertions.assert_equal([_vertex(0), _vertex(1)], [[2100, 0, -100], [1950, 20, 70]], "vertices through the template chain (offset 1000 << 1)") and ok
	var faces: int = memory.read_u32(OBJ + 0x48)
	ok = Assertions.assert_equal([memory.read_u16(faces + 0x14), memory.read_u8(faces + 0x16)], [3, 0x40], "face records from the stream after the vectors (+0xc is then rewritten by the shading)") and ok
	ok = Assertions.assert_equal([memory.read_u32(CTL), memory.read_u32(0x1c25c), memory.read_u32(0x1c1cc)], [OBJ, CTL, 1], "controller linked and listed") and ok
	## Shading (depth 8, no haze): normal point - vertex 0 = (-150, 20, 170) words; I = -150 *
	## 0x7fff asr 13 = -600 (turned away) -> factor 0x4000 + (I + 0x10000) / 4 = 0x7f6a; base
	## colour (0x00, 0xa0, 0xb0) -> (0, 0x4f, 0x57); the face does not own slot 0 -> byte +0xf 0.
	ok = Assertions.assert_equal([memory.read_u8(faces + 0xc), memory.read_u8(faces + 0xd), memory.read_u8(faces + 0xe), memory.read_u8(faces + 0xf)], [0, 0x4f, 0x57, 0], "shaded face colour") and ok
	ok = Assertions.assert_equal(memory.read_u16(OBJ + 6) & 0x800, 0x800, "word +6 |= 0x800") and ok

	## Byte +5 bit 4: vectors copied unchanged (translate by 0), shaded 0x28 below.
	_setup(0x10, 0, 1, false)
	port.activate_near_range_object(OBJ)
	ok = Assertions.assert_equal([_vertex(0), _vertex(1)], [[100, 0, -100], [-50, 20, 70]], "+5 bit 4: vectors copied") and ok
	ok = Assertions.assert_equal([memory.read_u32(0x1d4a4), memory.read_u32(0x1c1e0)], [OBJ, 1], "byte +7 bit 0: entity_array_1") and ok
	## Unchanged vectors: normal - vertex 0 = (-150, 20, 170) as well -> same colour.
	ok = Assertions.assert_equal(memory.read_u8(memory.read_u32(OBJ + 0x48) + 0xd), 0x4f, "shaded") and ok

	## Byte +6 bit 4: land outline (obj, 0xb4e1, 0, 0x7fe4); one-bit display -> pattern 0x80.
	_setup(0, 0x10, 0, false)
	memory.write_u16(PoolFixtureScript.WORLD + 0xe, 1)
	memory.write_u32(PoolFixtureScript.WORLD + 0x88, 0x29000)
	memory.write_u32(0x1d724, 7)
	memory.write_u32(0x1d71c, 9)
	memory.write_u16(0x29000 + 0x100, 0x3333)
	port.activate_near_range_object(OBJ)
	## The land outline: the one-vertex face thins to a single pair -> hidden, no point -> long
	## +4 |= 0x40; range +0x14 = 0xb4e1, position = detail_ref (set to 7 / 9 here).
	ok = Assertions.assert_equal([memory.read_u8(memory.read_u32(OBJ + 0x48) + 0x13) & 2, memory.read_u32(OBJ + 4) & 0x40, memory.read_u32(OBJ + 0x14), memory.read_s32(OBJ + 0x18), memory.read_s32(OBJ + 0x20)], [2, 0x40, 0xb4e1, 7, 9], "land outline (obj, 0xb4e1, 0, 0x7fe4)") and ok
	ok = Assertions.assert_equal([memory.read_u32(memory.read_u32(OBJ + 0x48) + 4), memory.read_u8(memory.read_u32(OBJ + 0x48) + 0xd)], [0x3333, 0xa0], "pattern 0x80 instead of shading (stream colour left as built)") and ok
	memory.write_u16(PoolFixtureScript.WORLD + 0xe, 0)
	memory.write_u8(OBJ + 6, 0x10)
	port.activate_near_range_object(OBJ)
	## Byte +6 bit 4 leaves +0x44 as allocated (no template chain): both vectors 0 -> I = 0 ->
	## factor 0x8000 -> base colour halved.
	ok = Assertions.assert_equal(memory.read_u8(memory.read_u32(OBJ + 0x48) + 0xd), 0x50, "colour display: shaded") and ok

	## Byte +7 bit 4: sink with the words of a type-0x16 controller (angles 3 / -4 / 5, drop 6):
	## the face's single vertex (its three indices are 0) ends 12 below the waterline (drop << shift
	## 1) -> clipped away: face hidden, no point left -> long +4 |= 0x40. Byte +6 bit 1 keeps
	## word +6.
	_setup(0, 2, 0x10, true)
	port.activate_near_range_object(OBJ)
	var sunk_face: int = memory.read_u32(OBJ + 0x48)
	ok = Assertions.assert_equal([memory.read_u8(sunk_face + 0x13) & 2, memory.read_u32(OBJ + 4) & 0x40], [2, 0x40], "type 0x16: sunk below the waterline") and ok
	ok = Assertions.assert_equal(memory.read_u16(OBJ + 6) & 0x800, 0, "byte +6 bit 1: no 0x800") and ok
	## Type 0x14: zero angles and drop -> the vertex stays at y 0, the face survives with one point.
	memory.write_u16(TYPE_DEF, 0x14)
	port.activate_near_range_object(OBJ)
	sunk_face = memory.read_u32(OBJ + 0x48)
	ok = Assertions.assert_equal([memory.read_u8(sunk_face + 0x13) & 2, memory.read_u32(OBJ + 4) & 0x40, memory.read_u16(OBJ + 0x36)], [0, 0, 1], "type 0x14: zeros -> afloat, one unique point") and ok

	## Kind 3: published, child table copied (+0x14 relocated) and each child instantiated.
	_setup(0, 0, 0, false)
	var group := 0x21800
	var gdesc := PoolFixtureScript.BASE + 0x1000
	memory.write_u8(group, 3)
	memory.write_u32(group + 0x28, gdesc)
	memory.write_u16(group + 0x2e, 2)
	for i in range(2):
		memory.write_u32(gdesc + 0x1a + 0x18 * i + 0x14, 0x400 + 0x40)
	port.activate_near_range_object(group)
	var table: int = memory.read_u32(group + 0x30)
	ok = Assertions.assert_equal([memory.read_u32(0x1d4a4), memory.read_u32(table - 8)], [group, (2 * 0x18 + 7) / 8 + 1], "group published; table of 2 records") and ok
	var child0: int = memory.read_u32(table + 0x14)
	var child1: int = memory.read_u32(table + 0x18 + 0x14)
	ok = Assertions.assert_equal([memory.read_u32(child0 + 0x24), memory.read_u8(child0 + 2), memory.read_u8(child1 + 2), memory.read_u8(child1 + 3)], [group, 0, 1, 1], "children instantiated (slot == type -> byte +3 += 1)") and ok
	ok = Assertions.assert_equal(fixture.activated(), [child0, child1, group], "both children activated (object_pool), the group on entity_array_1") and ok

	## Other kinds: only the camera metric.
	_setup(0, 0, 0, false)
	memory.write_u8(OBJ, 5)
	memory.write_u32(OBJ + 0x18, 300)
	port.activate_near_range_object(OBJ)
	ok = Assertions.assert_equal([memory.read_u32(OBJ + 0x10), memory.read_u32(OBJ + 0x44), memory.read_u32(0x1b734)], [300, 0, 0], "kind 5: metric only") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok
	return ok
