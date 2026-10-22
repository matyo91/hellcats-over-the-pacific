extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const DESC := 0x21000

## Expected values follow the disassembly of 0x45ba..0x468e (alloc_object_from_desc), 0x4690
## (instantiate_object_from_desc) and 0x435a..0x44a2 (apply_entity_mission_rates).

var memory
var port
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = 0x2f000
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)

func run() -> bool:
	var ok := true
	_setup()
	## Kind 2: word +0x16 = 0x2001 zero-extended into the flag long; bit 13 sets byte +5 bit 4.
	memory.write_u8(DESC, 2)
	for c in range(3):
		memory.write_u32(DESC + 2 + 4 * c, (c + 1) * 1000)
	memory.write_u32(DESC + 0xe, 777)
	memory.write_u32(DESC + 0x12, 888)
	memory.write_u16(DESC + 0x16, 0x2001)
	memory.write_u16(DESC + 0x18, 3)
	memory.write_u16(DESC + 0x1a, 4)
	memory.write_u16(DESC + 0x1c, 0)
	memory.write_u16(DESC + 0x1e, 6)
	memory.write_u16(DESC + 0x20, 0xffff)
	memory.write_u32(0x1b838, 99)
	var obj: int = port.alloc_object_from_desc(DESC)
	ok = Assertions.assert_equal([memory.read_u32(obj - 8), memory.read_u8(obj), memory.read_u32(obj + 4)], [(0x52 + 7) / 8 + 1, 2, 0x00102001], "0x52-byte block; flags 0x2001 plus byte +5 bit 4") and ok
	ok = Assertions.assert_equal([memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), memory.read_s32(obj + 0xc), memory.read_s32(obj + 0x14)], [1000, 2000, 3000, 777, 888], "position, range, extent") and ok
	ok = Assertions.assert_equal([memory.read_u16(obj + 0x34), memory.read_u16(obj + 0x36), memory.read_u16(obj + 0x38), memory.read_u16(obj + 0x3a), memory.read_u16(obj + 0x50), memory.read_u32(obj + 0x40)], [3, 4, 1, 6, 0xffff, 99], "words (+0x38: 0 -> 1) and frame") and ok
	## Kind 3: 0x34-byte block, words +0x2c / +0x2e, descriptor back-pointer.
	memory.write_u8(DESC, 3)
	obj = port.alloc_object_from_desc(DESC)
	ok = Assertions.assert_equal([memory.read_u32(obj - 8), memory.read_u16(obj + 0x2c), memory.read_u16(obj + 0x2e), memory.read_u32(obj + 0x28), memory.read_u32(obj + 4)], [(0x34 + 7) / 8 + 1, 0x2001, 3, DESC, 0], "kind 3 object") and ok
	## Any other tag returns the caller's D1.
	memory.write_u8(DESC, 7)
	ok = Assertions.assert_equal(port.alloc_object_from_desc(DESC, 0x1234), 0x1234, "other tag -> D1 unchanged") and ok

	## instantiate_object_from_desc: class key 6 -> factory (obj, 6, 0); its first long cleared.
	memory.write_u8(DESC, 2)
	memory.write_u8(DESC + 1, 6)
	memory.write_u32(0x1b524 + 6 * 4, PoolFixtureScript.DEF + 0x60)
	memory.write_u32(PoolFixtureScript.DEF + 0x60 + 6, PoolFixtureScript.FACTORY)
	obj = port.instantiate_object_from_desc(DESC)
	ok = Assertions.assert_equal(fixture.factory_calls[-1], [obj, 6, 0, 0x2f000 - 0x18], "factory (obj, key, 0), 0x18 below") and ok
	ok = Assertions.assert_equal([memory.read_u32(obj + 8), memory.read_u32(PoolFixtureScript.CONTROLLERS)], [PoolFixtureScript.CONTROLLERS, 0], "controller stored, first long cleared") and ok
	fixture.factory_returns_controller = false
	obj = port.instantiate_object_from_desc(DESC)
	ok = Assertions.assert_equal(memory.read_u32(obj + 8), 0, "null controller stored as is") and ok

	## apply_entity_mission_rates: template record at host +0x8c + root template +0x2e.
	_setup()
	fixture.add_template(1, 0)
	var rec := PoolFixtureScript.BASE + 0x400 + 0x40 * 1
	memory.write_u32(rec + 0xe, -5 & 0xffffffff) ## record range -5
	memory.write_u16(rec + 0x1a, 0)
	memory.write_u16(rec + 0x1e, 0)
	memory.write_u8(rec + 0x22 + 8, 1) ## packed face 0: count 1, long +0xa = 10
	memory.write_u32(rec + 0x22 + 0xa, 10)
	memory.write_u8(rec + 0x22 + 0xe + 2 + 8, 0) ## packed face 1: count 0, long +0xa = -3
	memory.write_u32(rec + 0x22 + 0x10 + 0xa, -3 & 0xffffffff)
	var ent := 0x21500
	var faces := 0x21600
	memory.write_u8(ent, 2)
	memory.write_u8(ent + 1, 1)
	memory.write_u32(ent + 0x24, PoolFixtureScript.ROOT)
	memory.write_u32(ent + 0x48, faces)
	memory.write_u16(ent + 0x3a, 2)
	var world := PoolFixtureScript.WORLD
	memory.write_u16(world + 0xa8, 0)
	port.apply_entity_mission_rates(ent, 0)
	ok = Assertions.assert_equal(memory.read_u32(ent + 0xc), 0, "phase 0: nothing") and ok
	memory.write_u16(world + 0xa8, 1) ## scale 0 -> halves (C truncation)
	port.apply_entity_mission_rates(ent, 0)
	ok = Assertions.assert_equal([memory.read_s32(ent + 0xc), memory.read_s32(faces + 0x1c), memory.read_s32(faces + 0x20 + 0x1c)], [-2, 5, -1], "scale 0: -5 / 2, 10 / 2, -3 / 2 (truncating)") and ok
	memory.write_u16(world + 0xa8, 4) ## scale 3
	port.apply_entity_mission_rates(ent, 1)
	ok = Assertions.assert_equal([memory.read_s32(ent + 0xc), memory.read_s32(faces + 0x1c)], [-15, 5], "scale 3; path 1 leaves the faces") and ok
	memory.write_u32(rec + 0xe, 0x200000)
	port.apply_entity_mission_rates(ent, 0)
	ok = Assertions.assert_equal([memory.read_s32(ent + 0xc), memory.read_s32(faces + 0x1c), memory.read_s32(faces + 0x20 + 0x1c)], [0x42b209, 30, -9], "shape range clamped to 0x42b209; faces * 3") and ok
	memory.write_u32(ent + 8, 0x21700)
	memory.write_u32(0x1b738, 0x21700)
	port.apply_entity_mission_rates(ent, 0)
	ok = Assertions.assert_equal([memory.read_s32(faces + 0x1c), memory.read_s32(faces + 0x20 + 0x1c)], [50, -15], "player's object: faces * 5") and ok
	memory.write_u32(ent + 0xc, 1000000000)
	port.apply_entity_mission_rates(ent, 1)
	ok = Assertions.assert_equal(memory.read_s32(ent + 0xc), 1000000000, "parked range left alone") and ok
	memory.write_u8(ent + 7, 2)
	memory.write_u32(ent + 0xc, 7)
	port.apply_entity_mission_rates(ent, 1)
	ok = Assertions.assert_equal(memory.read_s32(ent + 0xc), 7, "byte +7 bit 1: nothing") and ok
	return ok
