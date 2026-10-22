extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const STACK_TOP := 0x2f000
const WORLD := 0x23000
const HOOK := 0x999 ## test-only address stored at host_world +0x292
const CTX := 0x24000
const NODE := 0x25000
const RECORD := 0x25400
const PATH := 0x25500
const FACE := 0x25600
const PLAYER_CTL := 0x25700
const PLAYER_OBJ := 0x25800

## One path record (angles 0, offsets 1000, 50, -2000) over a node (origin 10, 20, 30, scale
## shift 1, four vertices). Player at x 800, z -1500; map scale 2; clip x [500, 780], y-min
## -1250, y-max -2000 replaced by -1050 for the last pass. Expected values from a model of
## 0x6ec..0x952 with the earlier instruction models of 0x4f8, 0x1c5c and the four clippers,
## independent of the C and of this port.
const VERTS := [[-300, 5, -100], [400, 6, -120], [380, 7, 500], [-350, 8, 520]]
const OUTLINE := [[500, -1050], [500, -1250], [780, -1250], [780, -1050]]
const ORIGIN := [1010, 70, -1970]

var hook_calls: Array = []
var port

func _hook(outline: int, count: int, face_long: int) -> void:
	var points := []
	for n in range(count):
		points.append([port.memory.read_s32(outline + 8 * n), port.memory.read_s32(outline + 8 * n + 4)])
	hook_calls.append([count, face_long, points, port.memory.read_s16(0x1b73e), port.a7])

func _write_long3(memory, address: int, v: Array) -> void:
	for c in range(3):
		memory.write_u32(address + 4 * c, v[c] & 0xffffffff)

func _long3(memory, address: int) -> Array:
	return [memory.read_s32(address), memory.read_s32(address + 4), memory.read_s32(address + 8)]

func _world(binary: PackedByteArray, flags: int, face_type: int, kind: int):
	var memory = Memory68kScript.new(MEMORY_SIZE)
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(WORLD + 0x292, HOOK)
	memory.write_u32(0x1b738, PLAYER_CTL)
	memory.write_u32(PLAYER_CTL, PLAYER_OBJ)
	memory.write_u32(PLAYER_OBJ + 0x18, 800)
	memory.write_u32(PLAYER_OBJ + 0x20, -1500 & 0xffffffff)
	memory.write_u16(0x20aee, 500)
	memory.write_u16(0x20aec, 780)
	memory.write_u16(0x20aea, -1250 & 0xffff)
	memory.write_u16(0x1b73e, -2000 & 0xffff)
	memory.write_u16(0x1b740, -1050 & 0xffff)
	memory.write_u32(CTX, 2)
	_write_long3(memory, RECORD + 8, [1000, 50, -2000])
	memory.write_u32(PATH, RECORD)
	memory.write_u8(NODE + 1, kind)
	memory.write_u32(NODE + 0xe, 0x1234)
	_write_long3(memory, NODE + 2, [10, 20, 30])
	memory.write_u16(NODE + 0x16, flags)
	memory.write_u16(NODE + 0x18, 1)
	memory.write_u16(NODE + 0x1a, VERTS.size())
	for n in range(VERTS.size()):
		_write_long3(memory, NODE + 0x22 + 12 * n, VERTS[n])
	memory.write_u32(FACE, 0xdeadbeef)
	memory.write_u8(FACE + 8, 4)
	memory.write_u8(FACE + 9, face_type)
	for k in range(4):
		memory.write_u16(FACE + 0xe + 2 * k, k)
	memory.write_u16(FACE + 0xe, 2) ## zone face: first index = vertex 2
	memory.write_u16(FACE + 0x10, 1)
	memory.write_u16(FACE + 0x12, 0)
	return memory

func _new_port(memory):
	port = PacificConflictScript.new(memory)
	port.code_table[HOOK] = Callable(self, "_hook")
	port.a7 = STACK_TOP
	return port

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1ad8c + 0x200, true, "original binary readable") and ok
	if not ok:
		return false

	## Land node: outline over vertices 0, 1, 2, 3.
	var memory = _world(binary, 0x1000, 0x10, 0) ## byte +0x16 bit 4 = word 0x1000
	_new_port(memory)
	memory.write_u16(FACE + 0xe, 0)
	memory.write_u16(FACE + 0x10, 1)
	memory.write_u16(FACE + 0x12, 2)
	port.code_table[0x6cc].call(CTX, NODE, FACE, PATH + 4, 1)
	ok = Assertions.assert_equal(hook_calls.size(), 1, "outline hook called once") and ok
	if hook_calls.size() == 1:
		ok = Assertions.assert_equal(hook_calls[0][0], 4, "clipped count") and ok
		ok = Assertions.assert_equal(hook_calls[0][1], 0xdeadbeef, "face long +0 passed") and ok
		ok = Assertions.assert_equal(hook_calls[0][2], OUTLINE, "clipped outline") and ok
		ok = Assertions.assert_equal(hook_calls[0][3], -2000, "clip_y_max restored before the hook") and ok
		ok = Assertions.assert_equal(hook_calls[0][4], STACK_TOP - 0xf94, "hook stack depth") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok

	## Zone face (type 0x70): (x, y of vertex 2, z) appended at ctx + 4.
	memory = _world(binary, 0, 0x70, 0)
	_new_port(memory)
	memory.write_u16(CTX + 0xb58, 0)
	port.collect_map_features(CTX, NODE, FACE, PATH + 4, 1)
	ok = Assertions.assert_equal(_long3(memory, CTX + 4), [ORIGIN[0], 107, ORIGIN[2]], "zone entry") and ok
	ok = Assertions.assert_equal(memory.read_u16(CTX + 0xb58), 1, "zone count") and ok

	## Site (node kind 0x13): id, kind and (x, y, z) at index word +0xb5a = 2.
	memory = _world(binary, 0, 0x10, 0x13)
	_new_port(memory)
	memory.write_u16(CTX + 0xb5a, 2)
	port.collect_map_features(CTX, NODE, FACE, PATH + 4, 1)
	ok = Assertions.assert_equal(memory.read_u32(CTX + 0x9c8 + 8), 0x1234, "site id") and ok
	ok = Assertions.assert_equal(memory.read_u8(CTX + 0x964 + 2), 0x13, "site kind") and ok
	ok = Assertions.assert_equal(_long3(memory, CTX + 0x4b4 + 24), ORIGIN, "site position") and ok
	ok = Assertions.assert_equal(memory.read_u16(CTX + 0xb5a), 3, "site count") and ok

	## Anything else: nothing written.
	memory = _world(binary, 0, 0x10, 0x05)
	_new_port(memory)
	port.collect_map_features(CTX, NODE, FACE, PATH + 4, 1)
	ok = Assertions.assert_equal([memory.read_u16(CTX + 0xb58), memory.read_u16(CTX + 0xb5a)], [0, 0], "other nodes ignored") and ok
	return ok
