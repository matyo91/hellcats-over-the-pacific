extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const WORLD := 0x23000
const BASE := 0x24000
const GROUP := 0x24100
const SUBGROUP := 0x24200
const LEAF_1 := 0x24300
const LEAF_2 := 0x24400
const VISITOR := 0x777 ## test-only code address registered in code_table

## Expected visits from an instruction-level model of 0x5fa..0x6a4 and 0x6a6..0x6ea over the
## same scene (independent of the C and of this port): [ctx, node, face, path, depth, path
## slots from path - 4 downwards]. The sub-group (type 3) is visited before the second
## leaf; the faces of a leaf step by 0xe + 2 * byte +8.
const VISITS := [
	[0x1234, 0x24400, 0x2443a, 0x2efdc, 2, [0x2421a, 0x2411a]],
	[0x1234, 0x24300, 0x24352, 0x2efd8, 1, [0x24132]],
	[0x1234, 0x24300, 0x24366, 0x2efd8, 1, [0x24132]],
]

var visits: Array = []
var port

func _visitor(ctx: int, node: int, face: int, path: int, depth: int) -> void:
	var slots := []
	for k in range(1, depth + 1):
		slots.append(port.memory.read_u32(path - 4 * k))
	visits.append([ctx, node, face, path, depth, slots, port.a7])

func _leaf(memory, leaf: int, vert_count: int, faces: Array) -> void:
	memory.write_u8(leaf, 2)
	memory.write_u16(leaf + 0x1a, vert_count)
	memory.write_u16(leaf + 0x1e, faces.size())
	var face := leaf + 0x22 + 12 * vert_count + 12 * faces.size()
	for count in faces:
		memory.write_u8(face + 8, count)
		face += 0xe + 2 * count

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(WORLD + 0x8c, BASE)
	memory.write_u16(WORLD + 0x90, 1)
	memory.write_u32(BASE + 0x18 + 0x8e, GROUP - BASE)
	memory.write_u8(GROUP, 3)
	memory.write_u16(GROUP + 0x18, 2)
	memory.write_u32(GROUP + 0x1a + 0x14, SUBGROUP - BASE)
	memory.write_u32(GROUP + 0x1a + 0x18 + 0x14, LEAF_1 - BASE)
	memory.write_u8(SUBGROUP, 3)
	memory.write_u16(SUBGROUP + 0x18, 1)
	memory.write_u32(SUBGROUP + 0x1a + 0x14, LEAF_2 - BASE)
	_leaf(memory, LEAF_1, 2, [3, 1])
	_leaf(memory, LEAF_2, 1, [2])
	port.code_table[VISITOR] = Callable(self, "_visitor")

	port.a7 = STACK_TOP
	port.for_each_mission_scene_object(VISITOR, 0x1234)
	ok = Assertions.assert_equal(visits.size(), VISITS.size(), "visit count") and ok
	for n in range(min(visits.size(), VISITS.size())):
		ok = Assertions.assert_equal(visits[n].slice(0, 6), VISITS[n], "visit %d" % n) and ok
	## Visitors are entered 0x40 below each traverse level; the first level is 0x6d8 below.
	if visits.size() == 3:
		ok = Assertions.assert_equal(visits[0][6], STACK_TOP - 0x6d8 - 0x80, "depth-2 visitor a7") and ok
		ok = Assertions.assert_equal(visits[1][6], STACK_TOP - 0x6d8 - 0x40, "depth-1 visitor a7") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok
	return ok
