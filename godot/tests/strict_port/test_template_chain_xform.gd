extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const STACK_TOP := 0x2f000
const OBJ := 0x22000
const P1 := 0x22100
const P2 := 0x22200
const T1 := 0x22300
const T2 := 0x22400
const SRC := 0x22500
const DST := 0x22600

## Chain obj -(slot 1 of P1)-> P1 -(slot 0 of P2)-> P2. Slot 1 of P1: angles (0x100, 0,
## 0x2000), offsets (10, -20, 30); slot 0 of P2: angles 0, offsets (1000, 2000, -3000).
## Expected values from a model that follows 0x2bd8..0x2d0e / 0x2d10..0x2e04 and uses
## instruction-level models of build_attitude_matrix_3ang (composer 0x24f8), 0x2ada and
## 0x1c5c - independent of the C and of this port. Object word +0x34 = 3.
const POS := [5000, -6000, 7000]
const VERTS := [[100, 200, 300], [-400, 500, -600]]
const POINT := [-3990, 8636, 3408]
const MESH := [[7980, 15670, -23442], [8480, 15283, -24309]]
const MESH_ALWAYS := [[910, 1810, -2652], [1410, 1423, -3519]]

func _long3(memory, address: int) -> Array:
	return [memory.read_s32(address), memory.read_s32(address + 4), memory.read_s32(address + 8)]

func _write_long3(memory, address: int, v: Array) -> void:
	for c in range(3):
		memory.write_u32(address + 4 * c, v[c] & 0xffffffff)

func _world(binary: PackedByteArray):
	var memory = Memory68kScript.new(MEMORY_SIZE)
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
	_write_long3(memory, OBJ + 0x18, POS)
	memory.write_u32(OBJ + 0x24, P1)
	memory.write_u8(OBJ + 2, 1)
	memory.write_u16(OBJ + 0x34, 3)
	memory.write_u32(P1 + 0x30, T1)
	memory.write_u32(P1 + 0x24, P2)
	memory.write_u8(P1 + 2, 0)
	memory.write_u32(P2 + 0x30, T2)
	memory.write_u32(P2 + 0x24, 0)
	var s1 := T1 + 0x18
	memory.write_u16(s1 + 2, 0x100)
	memory.write_u16(s1 + 4, 0)
	memory.write_u16(s1 + 6, 0x2000)
	_write_long3(memory, s1 + 8, [10, -20, 30])
	_write_long3(memory, T2 + 8, [1000, 2000, -3000])
	for n in range(2):
		_write_long3(memory, SRC + 12 * n, VERTS[n])
	return memory

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1ad8c + 0x200, true, "original binary readable") and ok
	if not ok:
		return false
	for fn in ["apply_template_chain_xform", "apply_template_chain_xform_always"]:
		## Point path, both null: the frame copy is committed to +0x18..+0x20.
		var memory = _world(binary)
		var strict_port = PacificConflictScript.new(memory)
		strict_port.a7 = STACK_TOP
		strict_port.call(fn, OBJ, 0, 0, 0)
		ok = Assertions.assert_equal(_long3(memory, OBJ + 0x18), POINT, "%s point path commits" % fn) and ok
		ok = Assertions.assert_equal(strict_port.a7, STACK_TOP, "%s restores a7" % fn) and ok

		## Point path with only src set: transformed in the frame (a6 - 0x1e), not committed.
		memory = _world(binary)
		strict_port = PacificConflictScript.new(memory)
		strict_port.a7 = STACK_TOP
		strict_port.call(fn, OBJ, 2, SRC, 0)
		ok = Assertions.assert_equal(_long3(memory, STACK_TOP - 0x22), POINT, "%s frame copy at a6 - 0x1e" % fn) and ok
		ok = Assertions.assert_equal(_long3(memory, OBJ + 0x18), POS, "%s no commit when src is set" % fn) and ok

		## Mesh path: two vertices SRC -> DST, source untouched, position untouched.
		memory = _world(binary)
		strict_port = PacificConflictScript.new(memory)
		strict_port.a7 = STACK_TOP
		strict_port.call(fn, OBJ, 2, SRC, DST)
		var expected: Array = MESH if fn == "apply_template_chain_xform" else MESH_ALWAYS
		ok = Assertions.assert_equal([_long3(memory, DST), _long3(memory, DST + 12)], expected, "%s mesh path" % fn) and ok
		ok = Assertions.assert_equal(_long3(memory, SRC), VERTS[0], "%s source untouched" % fn) and ok
		ok = Assertions.assert_equal(_long3(memory, OBJ + 0x18), POS, "%s mesh path leaves the position" % fn) and ok

	## translate_int3_vecs alone: count 0 writes nothing, add.l wraps.
	var mem2 = Memory68kScript.new(MEMORY_SIZE)
	var port2 = PacificConflictScript.new(mem2)
	_write_long3(mem2, SRC, [0x7fffffff, -0x80000000, 5])
	mem2.write_u32(DST, 0x55555555)
	port2.translate_int3_vecs(0, SRC, DST, 1, -1, 2)
	ok = Assertions.assert_equal(mem2.read_u32(DST), 0x55555555, "translate count 0") and ok
	port2.translate_int3_vecs(1, SRC, DST, 1, -1, 2)
	ok = Assertions.assert_equal(_long3(mem2, DST), [-0x80000000, 0x7fffffff, 7], "translate wraps at 32 bits") and ok
	return ok
