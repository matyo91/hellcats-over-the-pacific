extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const STACK_TOP := 0x2f000
const OBJECT := 0x22000
const NODE_A := 0x22100
const NODE_B := 0x22200
const PATH := 0x22300
const OUT := 0x22400
const VERTEX_OUT := 0x22500

## Path stack [NODE_A, NODE_B]: B (the top) is applied first, then A. Expected values from a
## model that follows 0x4f8..0x5f8 with instruction-level models of build_attitude_matrix_3ang
## (composer 0x24f8), 0x2ada and 0x1c5c, independent of the C and of this port.
const POS := [1234, -5678, 9012]
const VERTS := [[10, 20, 30], [-40, 50, -60]]
const WORLD_POS := [-9311, -1999, 5088]
const WORLD_VERTS := [[716, 541, 2355], [810, 517, 2312]]

func _long3(memory, address: int) -> Array:
	return [memory.read_s32(address), memory.read_s32(address + 4), memory.read_s32(address + 8)]

func _write_long3(memory, address: int, v: Array) -> void:
	for c in range(3):
		memory.write_u32(address + 4 * c, v[c] & 0xffffffff)

func _node(memory, node: int, angles: Array, offsets: Array) -> void:
	for c in range(3):
		memory.write_u16(node + 2 + 2 * c, angles[c] & 0xffff)
	_write_long3(memory, node + 8, offsets)

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1ad8c + 0x200, true, "original binary readable") and ok
	if not ok:
		return false
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
	_write_long3(memory, OBJECT + 2, POS)
	memory.write_u16(OBJECT + 0x18, 2)
	memory.write_u16(OBJECT + 0x1a, 2)
	for n in range(2):
		_write_long3(memory, OBJECT + 0x22 + 12 * n, VERTS[n])
	_node(memory, NODE_A, [0x0800, 0x0100, 0], [-50, 60, -70])
	_node(memory, NODE_B, [0, 0x1000, 0x0200], [300, -400, 500])
	memory.write_u32(PATH, NODE_A)
	memory.write_u32(PATH + 4, NODE_B)

	strict_port.a7 = STACK_TOP
	strict_port.transform_through_node_chain(PATH + 8, 2, OBJECT, OUT, OUT + 4, OUT + 8, VERTEX_OUT)
	ok = Assertions.assert_equal(_long3(memory, OUT), WORLD_POS, "world position through the outs") and ok
	ok = Assertions.assert_equal([_long3(memory, VERTEX_OUT), _long3(memory, VERTEX_OUT + 12)], WORLD_VERTS, "vertices into the buffer") and ok
	ok = Assertions.assert_equal(_long3(memory, OBJECT + 0x22), VERTS[0], "object vertices untouched") and ok
	ok = Assertions.assert_equal(_long3(memory, STACK_TOP - 0x10), WORLD_POS, "running position at a6 - 0xc") and ok
	ok = Assertions.assert_equal(strict_port.a7, STACK_TOP, "a7 restored") and ok

	## No vertex buffer and node count 0: the outs get the object position unchanged.
	_write_long3(memory, OUT, [0, 0, 0])
	strict_port.transform_through_node_chain(PATH + 8, 0, OBJECT, OUT, OUT + 4, OUT + 8, 0)
	ok = Assertions.assert_equal(_long3(memory, OUT), POS, "node count 0 copies the position") and ok

	## scale_int3_vecs: muls.l keeps the low 32 bits.
	_write_long3(memory, 0x22600, [0x12345, -3, 0x7fffffff])
	memory.write_u32(0x22700, 0x55555555)
	strict_port.scale_int3_vecs(0, 0x22600, 0x22700, 0x10000, 7, 2)
	ok = Assertions.assert_equal(memory.read_u32(0x22700), 0x55555555, "scale count 0") and ok
	strict_port.scale_int3_vecs(1, 0x22600, 0x22700, 0x10000, 7, 2)
	ok = Assertions.assert_equal(_long3(memory, 0x22700), [591724544, -21, -2], "scale wraps at 32 bits") and ok
	return ok
