extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const SELF := 0x21000
const SELF_CTL := 0x21100
const OTHER := 0x21800
const OTHER_CTL := 0x21900
const OTHER_TYPE := 0x21f00
const FACILITY := 0x21c00
const FACILITY_CTL := 0x21d00
const FACILITY_TYPE := 0x21f10

## Expected values follow the disassembly of enemy_fighter_notice_object (0x100d4; jump table
## on type - 1 decoded from the words at 0x10104: types 1, 2 and 0x15..0x19). Chance for a
## range 500 object 1000 away is 1689 (always above rng & 0x7f). Rng draws come from a twin
## overlay RNG; a facility of type 0x13 (probe 0x200) or 0x12 (0x100) sits by the target.

var memory
var port
var twin

func _setup(type: int, state: int, facility_type: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	PoolFixtureScript.new().setup(memory, port)
	memory.write_u32(SELF + 8, SELF_CTL)
	memory.write_u32(SELF_CTL + 0x32, state)
	memory.write_u16(SELF_CTL + 0x682, 2)
	memory.write_u8(SELF_CTL + 0x67c, 1)
	memory.write_u8(SELF_CTL + 0x67b, 3)
	memory.write_u32(OTHER + 8, OTHER_CTL)
	memory.write_u32(OTHER_CTL + 4, OTHER_TYPE)
	memory.write_u16(OTHER_TYPE, type)
	memory.write_u32(OTHER + 0x18, 1000)
	memory.write_u32(OTHER + 0x14, 500)
	memory.write_u32(FACILITY + 8, FACILITY_CTL)
	memory.write_u32(FACILITY_CTL + 4, FACILITY_TYPE)
	memory.write_u16(FACILITY_TYPE, facility_type)
	memory.write_u32(FACILITY + 0x18, 1000)
	memory.write_u32(FACILITY + 0xc, 0x100000)
	memory.write_u32(0x1b5a4, FACILITY)
	memory.write_u32(0x1b734, 1)

func _run_until_roll() -> void:
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0x3f) == 0:
			break
	for f in range(frames):
		port._jsr(0x100b4, [SELF, OTHER, 0])

func _state() -> Array:
	return [memory.read_u32(SELF_CTL + 0x692), memory.read_u32(SELF_CTL + 0x32), memory.read_u8(OTHER + 3), memory.read_u8(SELF_CTL + 0x67b)]

func run() -> bool:
	var ok := true

	_setup(1, 0x11162, 0x13)
	_run_until_roll()
	ok = Assertions.assert_equal(_state(), [OTHER, 0x110d4, 1, 0xfd], "player aircraft taken: attack state, bias inverted") and ok

	_setup(0x16, 0x110d4, 0x13)
	_run_until_roll()
	ok = Assertions.assert_equal(_state() + [memory.read_u32(SELF_CTL + 0x696)], [OTHER, 0x112c0, 1, 0xfd, 1000], "ship by an enemy facility: bombing run") and ok

	_setup(0x16, 0x110d4, 0x13)
	memory.write_u16(SELF_CTL + 0x684, 2)
	_run_until_roll()
	ok = Assertions.assert_equal(_state(), [OTHER, 0x111ba, 1, 0xfd], "damaged: escort state instead") and ok

	_setup(0x16, 0x110d4, 0x12)
	_run_until_roll()
	ok = Assertions.assert_equal(_state(), [0, 0x110d4, 0, 3], "ship by a friendly facility: ignored") and ok

	## Escort state: a ship by an enemy facility becomes the target, the state stays.
	_setup(0x17, 0x111ba, 0x13)
	_run_until_roll()
	ok = Assertions.assert_equal(_state(), [OTHER, 0x111ba, 1, 3], "escort: ship targeted, state kept, no bias change") and ok

	## Type 3 is not considered: no rng drawn.
	_setup(3, 0x110d4, 0x13)
	port.enemy_fighter_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal(port.overlay_rng_next(), twin.overlay_rng_next(), "type 3: no rng drawn") and ok
	return ok
