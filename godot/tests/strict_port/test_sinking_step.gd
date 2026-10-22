extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x40000
const STACK_TOP := 0x3f000
const SHIP := 0x21000
const FACES := 0x21100
const CTL := 0x21300
const TYPE15 := 0x21400
const CARGO := 0x21800
const CARGO_CTL := 0x21900
const TYPE7 := 0x21a00
const FACILITY := 0x21c00
const FACILITY_CTL := 0x21d00
const TYPE13 := 0x21e00
const TARGETS := 0x21f00
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const SIN_FILE := 0x1ab8c
const COS_FILE := 0x1ad8c

## Expected values follow the disassembly of 0x14bea (carry_attached_objects), 0x14d86
## (step_sinking_object) and 0x155d8 (tick_sinking_controller). The ship is test_sink.gd's
## shape: vertices (0, +-50, 0) / (100, +-50, 0), three faces, at (1000, 0, 2000). The sin / cos
## tables come from the original binary, so zero angles give the identity matrix. The cargo
## (type 7) hangs from the scene root's slot 3 at (1100, 50, 2200): carrying recomputes it there,
## rotates the word offset from the ship (100, 50, 200) and subtracts the drop from y.

var memory
var port
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(0x200):
		memory.write_u8(SIN_FILE - 0x20 + i, binary[SIN_FILE + i])
		memory.write_u8(COS_FILE - 0x20 + i, binary[COS_FILE + i])
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 0)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	memory.write_u16(desc + 0x1a, 4)
	memory.write_u16(desc + 0x1e, 3)
	var vectors := [[0, 50, 0], [100, 50, 0], [100, -50, 0], [0, -50, 0], [0, 0, 10], [0, 0, 20], [0, 0, 30]]
	for n in range(vectors.size()):
		for c in range(3):
			memory.write_u32(desc + 0x22 + 12 * n + 4 * c, vectors[n][c] & 0xffffffff)
	var packed := desc + 0x22 + 12 * vectors.size()
	for f in [[0, 1, 2, 3], [1, 2, 0], [2, 3, 2]]:
		memory.write_u8(packed + 8, f.size())
		for k in range(f.size()):
			memory.write_u16(packed + 0xe + 2 * k, f[k])
		packed += 0xe + 2 * f.size()
	memory.write_u8(SHIP, 2)
	memory.write_u8(SHIP + 1, 1)
	memory.write_u32(SHIP + 0x24, PoolFixtureScript.ROOT)
	memory.write_u32(SHIP + 0x18, 1000)
	memory.write_u32(SHIP + 0x20, 2000)
	memory.write_u32(SHIP + 0x14, 0x10000)
	memory.write_u16(SHIP + 0x3a, 3)
	memory.write_u32(SHIP + 0x48, FACES)
	memory.write_u32(SHIP + 0x44, port.heap_alloc(12))
	memory.write_u32(SHIP + 0x4c, port.heap_alloc(12))
	for f in range(3):
		memory.write_u8(FACES + 0x20 * f + 0x13, 2)
		memory.write_u32(FACES + 0x20 * f + 0x18, port.heap_alloc(2))
	## Sinking controller: due now, drop rate 3, two steps 5 frames apart, type 0x15.
	memory.write_u32(0x1b838, 100)
	memory.write_u32(CTL, SHIP)
	memory.write_u32(CTL + 4, TYPE15)
	memory.write_u16(TYPE15, 0x15)
	memory.write_u32(CTL + 0x48, 100)
	memory.write_u16(CTL + 0x42, 3)
	memory.write_u16(CTL + 0x44, 5)
	memory.write_u16(CTL + 0x46, 2)
	memory.write_u16(CTL + 0x32, 1)
	memory.write_u16(CTL + 0x4c, 1)
	memory.write_u16(CTL + 0x54, 40)
	## Cargo in object_pool.
	var table: int = memory.read_u32(PoolFixtureScript.ROOT + 0x30)
	for c in range(3):
		memory.write_u32(table + 3 * 0x18 + 8 + 4 * c, [1100, 50, 2200][c])
	memory.write_u8(CARGO + 1, 3)
	memory.write_u8(CARGO + 2, 3)
	memory.write_u32(CARGO + 0x24, PoolFixtureScript.ROOT)
	memory.write_u32(CARGO + 8, CARGO_CTL)
	memory.write_u32(CARGO_CTL, CARGO)
	memory.write_u32(CARGO_CTL + 4, TYPE7)
	memory.write_u16(TYPE7, 7)
	memory.write_u32(CARGO + 0x18, 1050)
	memory.write_u32(CARGO + 0x20, 2050)
	memory.write_u32(0x1b5a4, CARGO)
	memory.write_u32(0x1b734, 1)
	memory.write_u16(0x1b88e, 5) ## empty child window
	memory.write_u16(0x1b88c, 0)

func _pos(obj: int) -> Array:
	return [memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20)]

func run() -> bool:
	var ok := true

	## Not started (word +0x4c == 0): nothing.
	_setup()
	memory.write_u16(CTL + 0x4c, 0)
	port._jsr(0x155b8, [CTL])
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x46), memory.read_u16(CTL + 0x40)], [2, 0], "tick: not started") and ok
	## Not due yet (frame 99 < 100): nothing.
	_setup()
	memory.write_u32(0x1b838, 99)
	port.tick_sinking_controller(CTL)
	ok = Assertions.assert_equal(memory.read_u16(CTL + 0x40), 0, "step: not due") and ok

	## Angle rates wrap at 0x4000 (the cargo is then rotated too, so its position is not checked).
	_setup()
	memory.write_u16(CTL + 0x34, 0x3ff0)
	memory.write_u16(CTL + 0x3a, 0x20)
	memory.write_u16(CTL + 0x3c, 0x10)
	memory.write_u16(CTL + 0x38, 0x123)
	memory.write_u16(CTL + 0x3e, 0x3fff)
	port.tick_sinking_controller(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x34), memory.read_u16(CTL + 0x36), memory.read_u16(CTL + 0x38)], [0x10, 0x10, 0x122], "step: angle words += rates, & 0x3fff") and ok

	## Due, zero angles: drop 3, still afloat -> cargo carried to (1100, 50 - 3, 2200).
	_setup()
	port.tick_sinking_controller(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x40), memory.read_u16(CTL + 0x54), memory.read_u16(CTL + 0x46), memory.read_u32(CTL + 0x48)], [3, 37, 1, 105], "step: drop, type-0x15 word, steps, next frame") and ok
	ok = Assertions.assert_equal([_pos(CARGO), memory.read_u32(SHIP + 4) & 0x40, port.a7], [[1100, 47, 2200], 0, STACK_TOP], "afloat: cargo carried, ship visible") and ok
	## Last step: next frame 1000000000.
	memory.write_u32(0x1b838, 105)
	port.tick_sinking_controller(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x46), memory.read_u32(CTL + 0x48), memory.read_u16(CTL + 0x40), _pos(CARGO)[1]], [0, 1000000000, 6, 44], "last step: no next frame") and ok
	## Word +0x32 == 0 gives the step back.
	_setup()
	memory.write_u16(CTL + 0x32, 0)
	port.tick_sinking_controller(CTL)
	ok = Assertions.assert_equal(memory.read_u16(CTL + 0x46), 2, "no end: step given back") and ok

	## Sunk (drop 60 + 3): cargo removed, a mission-7 facility (type 0x13, kind 0x200) nearby
	## marks the target list, and the ship is cleaned up (kind 2 outside the window -> hidden).
	_setup()
	memory.write_u16(CTL + 0x40, 60)
	memory.write_u32(FACILITY + 8, FACILITY_CTL)
	memory.write_u32(FACILITY_CTL + 4, TYPE13)
	memory.write_u16(TYPE13, 0x13)
	memory.write_u32(FACILITY + 0x18, 1000)
	memory.write_u32(FACILITY + 0x20, 2000)
	memory.write_u32(FACILITY + 0xc, 0x100000)
	memory.write_u32(0x1b5a8, FACILITY)
	memory.write_u32(0x1b734, 2)
	memory.write_u16(PoolFixtureScript.WORLD + 0x90, 7)
	memory.write_u32(0x20adc, TARGETS)
	port.tick_sinking_controller(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CARGO + 0x18), memory.read_u32(CARGO + 4) & 2], [1000000000, 2], "sunk: cargo retired") and ok
	ok = Assertions.assert_equal([memory.read_u16(PoolFixtureScript.WORLD + 0xce), memory.read_u16(TARGETS + 4)], [0xffff, 1], "sunk near a mission-7 facility: +0xce = -1, target list word +4 = 1") and ok
	ok = Assertions.assert_equal([memory.read_u32(SHIP + 4) & 0x42, memory.read_u32(SHIP + 0x3c), port.a7], [0x42, 100, STACK_TOP], "sunk: ship cleaned up") and ok

	## carry_attached_objects filters: flagged, out of range, wrong type -> untouched.
	_setup()
	memory.write_u32(CARGO + 4, 0x200)
	port.carry_attached_objects(SHIP, 0, 0, 0, 3, 0)
	memory.write_u32(CARGO + 4, 0)
	memory.write_u32(SHIP + 0x14, 50)
	port.carry_attached_objects(SHIP, 0, 0, 0, 3, 0)
	memory.write_u32(SHIP + 0x14, 0x10000)
	memory.write_u16(TYPE7, 9)
	port.carry_attached_objects(SHIP, 0, 0, 0, 3, 0)
	ok = Assertions.assert_equal(_pos(CARGO), [1050, 0, 2050], "carry: filtered objects untouched") and ok
	## A drop that takes the cargo below 0 cleans it up.
	memory.write_u16(TYPE7, 0x1b)
	port.carry_attached_objects(SHIP, 0, 0, 0, 51, 0)
	ok = Assertions.assert_equal(memory.read_u32(CARGO + 0x18), 1000000000, "carry: cargo below 0 cleaned up") and ok
	return ok
