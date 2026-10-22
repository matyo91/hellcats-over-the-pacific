extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const WORLD := 0x23000

## Expected results follow the disassembly of 0x354..0x3f8, 0x488..0x4ce and 0x528a..0x52da
## (signed cmp.l against range and best, dbra over the low word of object_count, 0x100 / 0x200
## kinds; signed word +0x50; sext window words), independent of the C and of this port.
## Distances are approx_dist3_xyz along one axis, so they equal the axis difference.

var memory
var port

func _facility(address: int, type_word: int, x: int, range_long: int) -> void:
	memory.write_u32(address + 8, address + 0x80)
	memory.write_u32(address + 0x84, address + 0xc0)
	memory.write_u16(address + 0xc0, type_word)
	memory.write_u32(address + 0x18, x)
	memory.write_u32(address + 0xc, range_long)

func run() -> bool:
	var ok := true
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	memory.write_u32(0x1b5a0, WORLD)
	var target := 0x21000
	memory.write_u32(target + 0x18, 0)

	## Pool: enemy base at 300 (range 500), friendly base at 200 (range 150: out of range),
	## a non-base at 10, an object without controller, friendly base at 250 (range 400).
	var pool := [0x22000, 0x22100, 0x22200, 0x22300, 0x22400]
	_facility(pool[0], 0x12, 300, 500)
	_facility(pool[1], 0x13, 200, 150)
	_facility(pool[2], 0x05, 10, 1000)
	_facility(pool[4], 0x13, 250, 400)
	for n in range(pool.size()):
		memory.write_u32(0x1b5a4 + 4 * n, pool[n])
	memory.write_u32(0x1b734, 5)
	ok = Assertions.assert_equal(port.probe_nearest_facility_kind(target), 0x200, "nearest in-range base is friendly (250)") and ok
	memory.write_u32(0x1b734, 0x10002)
	ok = Assertions.assert_equal(port.probe_nearest_facility_kind(target), 0x100, "only the low word counts: 2 objects -> enemy") and ok
	memory.write_u32(0x1b734, 0)
	ok = Assertions.assert_equal(port.probe_nearest_facility_kind(target), 0, "empty pool -> 0") and ok

	## tally_destroyed_entity
	memory.write_u16(target + 0x50, 3)
	ok = Assertions.assert_equal(port.tally_destroyed_entity(target), 6, "type 3 -> counter +0xbe, D0 = 6") and ok
	ok = Assertions.assert_equal(memory.read_u16(WORLD + 0xb8 + 6), 1, "type-3 counter") and ok
	memory.write_u16(target + 0x50, 0)
	ok = Assertions.assert_equal(port.tally_destroyed_entity(target), 0, "type 0: nothing, D0 = probe result") and ok
	memory.write_u16(target + 0x50, -1 & 0xffff)
	ok = Assertions.assert_equal(port.tally_destroyed_entity(target, 0x77), 0x77, "negative type -> +0xd2, D0 kept") and ok
	memory.write_u32(0x1b734, 5)
	memory.write_u16(target + 0x50, 3)
	ok = Assertions.assert_equal(port.tally_destroyed_entity(target), 0x200, "near a friendly base -> +0xd2") and ok
	ok = Assertions.assert_equal(memory.read_u16(WORLD + 0xd2), 2, "friendly-kill counter") and ok
	ok = Assertions.assert_equal(memory.read_u16(WORLD + 0xb8 + 6), 1, "type counter unchanged") and ok

	## dispatch_entity_cleanup
	var root := 0x24000
	memory.write_u32(0x1d6fc, root)
	memory.write_u32(root + 0x30, 0x24100)
	memory.write_u16(0x1b88e, 4)
	memory.write_u16(0x1b88c, 6)
	memory.write_u32(0x1b838, 1234)
	var shape := 0x25000
	memory.write_u8(shape, 2)
	memory.write_u32(shape + 0x24, root)
	memory.write_u8(shape + 1, 9)
	memory.write_u8(shape + 2, 9)
	ok = Assertions.assert_equal(port.dispatch_entity_cleanup(shape), 9, "shape outside the window: stamped, D0 = byte +1") and ok
	ok = Assertions.assert_equal([memory.read_u32(shape + 4), memory.read_u32(shape + 0x3c)], [0x42, 1234], "stamp: |= 0x42, frame counter") and ok
	ok = Assertions.assert_equal(port.dispatch_entity_cleanup(shape, 5), 5, "flag bit 1 already set -> no-op") and ok
	memory.write_u32(shape + 4, 0)
	memory.write_u8(shape + 1, 5)
	memory.write_u8(shape + 2, 5)
	port.dispatch_entity_cleanup(shape)
	ok = Assertions.assert_equal(memory.read_s32(shape + 0x18), 1000000000, "shape in the window: retired") and ok
	var other := 0x26000
	memory.write_u8(other, 3)
	port.dispatch_entity_cleanup(other)
	ok = Assertions.assert_equal(memory.read_s32(other + 0x18), 1000000000, "non-shape: retired") and ok
	return ok
