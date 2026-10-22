extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const OBJ := 0x21000
const CTL := 0x21100

## spawn_effect is ported; its arguments are read back from the effect log it writes in live
## play; the pool object it spawns has no vertices and is retired (see `fixture`). surface_type_under_object is the ported one: with no active objects
## it returns the default ground face's code (DAT_0001bda8 +0x16), which the test sets.
## Expected arguments follow the pushes of 0x11db4..0x11efa (kind, size, lifetime, byte_38,
## debris, x, y, z).

const DEFAULT_FACE := 0x2a000
var memory
var port


## Effects as logged by the ported spawn_effect (live play: replay_state 0).
func _logged_effects() -> Array:
	var out := []
	for n in range(memory.read_u16(0x260ec)):
		var e := 0x260ee + 0x18 * n
		out.append([memory.read_u8(e), memory.read_s16(e + 4), memory.read_s16(e + 6), memory.read_u8(e + 1), memory.read_u8(e + 2),
				memory.read_s32(e + 8), memory.read_s32(e + 0xc), memory.read_s32(e + 0x10)])
	return out

## The spawned pool object goes through the strict spawn_mission_pool_object /
## instantiate_mission_pool_slot chain on PoolFixture's scene; its template is far (make_far), so
## it is deferred without vertices, the spawn retires it and spawn_effect returns 0 after logging.
var fixture

func _setup(with_ctl: bool, ground: int, surface_byte: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = 0x2f000
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(0, 0)
	fixture.make_far(0)
	memory.write_u32(0x1bda8, DEFAULT_FACE)
	memory.write_u8(DEFAULT_FACE + 0x16, 0x99) ## would show up if consulted unexpectedly
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
	ok = Assertions.assert_equal(_logged_effects(), [[2, 40, 5, 0, 1, 1010, 480, -1970]], "air burst") and ok

	## Near (480 - 400 = 80), surface byte 0x30: ground height kept, 3 * 40 / 4 = 30.
	_setup(true, 400, 0x30)
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, 40), 1, "near -> 1") and ok
	ok = Assertions.assert_equal(_logged_effects(), [[3, 30, 0x2d, 1, 0, 1010, 400, -1970]], "debris explosion on 0x30") and ok
	ok = Assertions.assert_equal(_logged_effects()[0][0], 3, "surface byte used when the ground height is set (0x99 not consulted)") and ok

	## Near, surface byte 0x10 (water): ring, y = 0.
	_setup(true, 400, 0x10)
	port.spawn_destruction_effect(OBJ, 40)
	ok = Assertions.assert_equal(_logged_effects(), [[0, 40, 0x4b, 0, 0, 1010, 0, -1970]], "water ring") and ok

	## Near with ground height 0: surface from 0x13452; negative size truncates (3 * -5 / 4 = -3).
	_setup(true, 0, 0x30)
	memory.write_u32(OBJ + 0x1c, 50)
	memory.write_u8(DEFAULT_FACE + 0x16, 0x20)
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, -5), 1, "near (30 < 100)") and ok
	ok = Assertions.assert_equal(_logged_effects(), [[3, -3, 0x2d, 1, 0, 1010, 0, -1970]], "other surface: explosion, y 0") and ok

	## Sign-extended surface byte 0xf0 (-16) is not 0x10.
	_setup(true, 400, 0xf0)
	port.spawn_destruction_effect(OBJ, 8)
	ok = Assertions.assert_equal(_logged_effects()[0][0], 3, "byte 0xf0 sign-extends to -16") and ok

	## No controller: near, y 0, surface from 0x13452 (water).
	_setup(false, 0, 0)
	memory.write_u8(DEFAULT_FACE + 0x16, 0x10)
	ok = Assertions.assert_equal(port.spawn_destruction_effect(OBJ, 12), 1, "no controller -> 1") and ok
	ok = Assertions.assert_equal(port.a7, 0x2f000, "a7 restored") and ok
	ok = Assertions.assert_equal(_logged_effects(), [[0, 12, 0x4b, 0, 0, 1000, 0, -2000]], "no controller: object x / z") and ok
	return ok
