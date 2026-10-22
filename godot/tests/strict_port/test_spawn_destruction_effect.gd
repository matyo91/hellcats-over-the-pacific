extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const OBJ := 0x21000
const CTL := 0x21100

## spawn_effect (file 0x11c58) and surface_type_under_object (file 0x13452) are not ported; the
## test supplies them under their runtime addresses and records the calls. Expected arguments
## follow the pushes of 0x11db4..0x11efa (kind, size, lifetime, byte_38, debris, x, y, z).

var effects: Array = []
var surface_calls := 0
var surface_value := 0
var memory
var port

func _spawn_effect(kind: int, size: int, lifetime: int, byte_38: int, debris: int, x: int, y: int, z: int) -> int:
	effects.append([kind, size, lifetime, byte_38, debris, x, y, z])
	return 0

func _surface(_obj: int) -> int:
	surface_calls += 1
	return surface_value

func _setup(with_ctl: bool, ground: int, surface_byte: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.code_table[0x11c38] = Callable(self, "_spawn_effect")
	port.code_table[0x13432] = Callable(self, "_surface")
	effects.clear()
	surface_calls = 0
	memory.write_u32(OBJ + 0x18, 1000)
	memory.write_u32(OBJ + 0x1c, 500)
	memory.write_u32(OBJ + 0x20, -2000 & 0xffffffff)
	if with_ctl:
		memory.write_u32(OBJ + 8, CTL)
		memory.write_u32(CTL + 8, 10)
		memory.write_u32(CTL + 0xc, -20 & 0xffffffff)
		memory.write_u32(CTL + 0x10, 30)
		memory.write_u32(CTL + 0x2e, ground)
		memory.write_u8(CTL + 0x2c, surface_byte)

func run() -> bool:
	var ok := true

	## Airborne: y 480 - ground 300 = 180 >= 100.
	_setup(true, 300, 0x30)
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, 40), 0, "airborne -> 0") and ok
	ok = Assertions.assert_equal(effects, [[2, 40, 5, 0, 1, 1010, 480, -1970]], "air burst") and ok

	## Near (480 - 400 = 80), surface byte 0x30: ground height kept, 3 * 40 / 4 = 30.
	_setup(true, 400, 0x30)
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, 40), 1, "near -> 1") and ok
	ok = Assertions.assert_equal(effects, [[3, 30, 0x2d, 1, 0, 1010, 400, -1970]], "debris explosion on 0x30") and ok
	ok = Assertions.assert_equal(surface_calls, 0, "surface byte used when the ground height is set") and ok

	## Near, surface byte 0x10 (water): ring, y = 0.
	_setup(true, 400, 0x10)
	port.spawn_destruction_effect(OBJ, 40)
	ok = Assertions.assert_equal(effects, [[0, 40, 0x4b, 0, 0, 1010, 0, -1970]], "water ring") and ok

	## Near with ground height 0: surface from 0x13452; negative size truncates (3 * -5 / 4 = -3).
	_setup(true, 0, 0x30)
	memory.write_u32(OBJ + 0x1c, 50)
	surface_value = 0x20
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, -5), 1, "near (30 < 100)") and ok
	ok = Assertions.assert_equal(surface_calls, 1, "surface_type_under_object asked") and ok
	ok = Assertions.assert_equal(effects, [[3, -3, 0x2d, 1, 0, 1010, 0, -1970]], "other surface: explosion, y 0") and ok

	## Sign-extended surface byte 0xf0 (-16) is not 0x10.
	_setup(true, 400, 0xf0)
	port.spawn_destruction_effect(OBJ, 8)
	ok = Assertions.assert_equal(effects[0][0], 3, "byte 0xf0 sign-extends to -16") and ok

	## No controller: near, y 0, surface from 0x13452 (water).
	_setup(false, 0, 0)
	surface_value = 0x10
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, 12), 1, "no controller -> 1") and ok
	ok = Assertions.assert_equal(effects, [[0, 12, 0x4b, 0, 0, 1000, 0, -2000]], "no controller: object x / z") and ok
	return ok
