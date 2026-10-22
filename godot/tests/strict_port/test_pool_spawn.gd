extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const TEMPLATE_OBJ := 0x22000

## Expected behaviour follows the disassembly of 0x5116..0x51ea and 0x46da..0x4806 (with
## alloc_object_from_desc 0x45ba and activate_near_range_object 0x4e6e): the table lives in
## the strict heap; PoolFixture provides the scene and the class factory.

var memory
var port
var fixture

func run() -> bool:
	var ok := true
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port, 3)
	fixture.add_template(0x21, 4, [100, 200, 300])
	memory.write_u16(PoolFixtureScript.ROOT + 0x2c, 0x22) ## types below 0x22 get flag long bit 0
	fixture.template_object(TEMPLATE_OBJ, 0x21)
	var table: int = memory.read_u32(PoolFixtureScript.ROOT + 0x30)
	memory.write_u32(table + 0x14, 0x1111)
	memory.write_u32(table + 0x18 + 0x14, 0x2222)

	## First free slot is 2; argument longs keep only their low words where the bytes use move.w.
	var obj: int = port.spawn_mission_pool_object(TEMPLATE_OBJ, 10, -20, 30, 0x10004, 0x20005, 0x30006, 0x40007)
	var rec := table + 2 * 0x18
	ok = Assertions.assert_equal(memory.read_u32(rec + 0x14), obj, "object stored in slot 2") and ok
	ok = Assertions.assert_equal([memory.read_u16(rec), memory.read_u16(rec + 2), memory.read_u16(rec + 4), memory.read_u16(rec + 6)], [7, 4, 5, 6], "factory and angle words (low words)") and ok
	ok = Assertions.assert_equal([memory.read_u8(obj), memory.read_u8(obj + 1), memory.read_u8(obj + 2), memory.read_u8(obj + 3), memory.read_u32(obj + 0x24)], [2, 0x21, 2, 0, PoolFixtureScript.ROOT], "kind, type, slot, no self count, parent root") and ok
	ok = Assertions.assert_equal(memory.read_u32(obj + 4) & 1, 1, "type 0x21 < root word 0x22 -> flag bit 0") and ok
	ok = Assertions.assert_equal(fixture.factory_calls[0].slice(0, 3), [obj, 4, 7], "factory (obj, key 4, sext record word +0)") and ok
	var ctl: int = memory.read_u32(obj + 8)
	ok = Assertions.assert_equal([memory.read_u32(ctl), memory.read_u16(ctl + 0x20), memory.read_u16(ctl + 0x22), memory.read_u16(ctl + 0x24)], [obj, 4, 5, 6], "controller: cleared by the instantiation, then *ctl = object on activation; words +0x20..+0x24 = record angles") and ok
	ok = Assertions.assert_equal(fixture.factory_calls[0][3], STACK_TOP - 0x24 - 0x28, "factory 0x28 below the instantiation") and ok
	ok = Assertions.assert_equal([memory.read_u32(0x1d4a4), memory.read_u32(0x1c1e0), memory.read_u16(obj + 6) & 0x800], [obj, 1, 0x800], "activated: flag bit 0 (type below the root word) -> entity_array_1; word +6 |= 0x800") and ok
	## Angles 4 / 5 / 6 rotate in apply_template_chain_xform; only the descriptor position and
	## the offset matter for the parked check below.
	ok = Assertions.assert_equal(memory.read_s32(obj + 0x18) != 100, true, "slot transform applied to the descriptor position") and ok

	## Table full: grows by 10 records in the heap, the new slot is the old count.
	obj = port.spawn_mission_pool_object(TEMPLATE_OBJ, 1, 2, 3, 0, 0, 0, 0)
	var new_table: int = memory.read_u32(PoolFixtureScript.ROOT + 0x30)
	ok = Assertions.assert_equal([new_table != table, memory.read_u32(new_table - 8), memory.read_u16(PoolFixtureScript.ROOT + 0x2e)], [true, (13 * 0x18 + 7) / 8 + 1, 13], "table regrown to 13 records") and ok
	ok = Assertions.assert_equal([memory.read_u32(new_table + 0x14), memory.read_u16(new_table + 2 * 0x18 + 2)], [0x1111, 4], "old records copied") and ok
	ok = Assertions.assert_equal([memory.read_u32(new_table + 3 * 0x18 + 0x14), memory.read_s32(obj + 0x18)], [obj, 101], "slot 3: object at descriptor x + offset") and ok

	## Far object (metric - range > 0x19c7f): appended to entity_array_3 instead of activated, so
	## it has no vertices: spawn_mission_pool_object retires it and returns 0 while
	## entity_array_3 keeps the pointer; retire_entity also frees its slot (bytes +1 / +2 differ).
	fixture.make_far(0x21)
	var before: int = fixture.activated().size()
	obj = port.spawn_mission_pool_object(TEMPLATE_OBJ, 0, 0, 0, 0, 0, 0, 0)
	var deferred: int = memory.read_u32(0x1d0e4)
	ok = Assertions.assert_equal([obj, fixture.activated().size(), memory.read_u32(0x1c1dc), memory.read_u8(deferred + 2), memory.read_s32(deferred + 0x18), memory.read_u32(new_table + 4 * 0x18 + 0x14)], [0, before, 1, 4, 1000000000, 0], "far object: deferred, retired, slot freed, 0 returned") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok
	return ok
