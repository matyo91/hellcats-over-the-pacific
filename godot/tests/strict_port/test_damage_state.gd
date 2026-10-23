extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const PLANE := 0x21000
const CTL := 0x21100
const TYPE := 0x21f00
const INIT := 0x705

## Expected values follow the disassembly of update_aircraft_damage_state (0x10650): the stage
## pass repeats on the newly set bits (with the newly cleared ones as "previous"),
## `btst #3,$684` is damage bit 0x800, and an armed timer becomes 0x7f + ((rng & 0xff) >> 1).
## Rng draws are predicted by a twin overlay RNG. The smoke-trail and plume templates are made
## unspawnable so those attaches draw nothing; effect templates use a stub initialiser.

var memory
var port
var twin
var fixture

func _init_handler(_obj: int) -> void:
	pass

func _setup(damage: int, previous: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	port.code_table[INIT] = Callable(self, "_init_handler")
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	for k in range(4):
		fixture.add_template(k, 5)
		memory.write_u32(0x2626e + 4 * k, fixture.template_object(0x22000 + 0x100 * k, k))
		memory.write_u32(0x1b40c + 4 * k, INIT)
	fixture.add_template(5, 5)
	fixture.make_far(5)
	memory.write_u32(0x26650, fixture.template_object(0x22500, 5))
	memory.write_u32(0x260e8, 0x22500)
	memory.write_u32(CTL, PLANE)
	memory.write_u32(PLANE + 8, CTL)
	memory.write_u32(CTL + 4, TYPE)
	memory.write_u16(TYPE, 3)
	memory.write_u32(CTL + 0x32, 0x110d4)
	memory.write_u16(CTL + 0x684, damage)
	memory.write_u16(CTL + 0x686, previous)

func _timer() -> int:
	return 0x7f + ((twin.overlay_rng_next() & 0xff) >> 1)

func run() -> bool:
	var ok := true

	## Newly smoking: smoke trail attached (nothing spawns here), timer armed.
	_setup(0x40, 0)
	var t: int = _timer()
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x684), memory.read_u16(CTL + 0x686), memory.read_u16(CTL + 0x688), port.a7], [0x40, 0x40, t, STACK_TOP], "new smoke: timer armed, damage kept") and ok

	## Smoking already: a coin may stop the smoke and escalate it to 0x80 or 0x200.
	_setup(0x40, 0x40)
	var want: int = 0x40
	if (twin.overlay_rng_next() & 1) != 0:
		want = 0x80 if (twin.overlay_rng_next() & 1) != 0 else 0x200
	t = _timer()
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x684), memory.read_u16(CTL + 0x688)], [want, t], "old smoke: coin outcome 0x%x" % want) and ok

	## A running timer hides the stage bits: only the timer counts down.
	_setup(0x40, 0x40)
	memory.write_u16(CTL + 0x688, 5)
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x684), memory.read_u16(CTL + 0x688), port.overlay_rng_next() == twin.overlay_rng_next()], [0x40, 4, true], "timer running: no stage step, no rng") and ok

	## Newly burning with bit 0x800: timer 0x16, no rng (the plume attach spawns nothing; the
	## AI bail-out roll that bit 0x100 allows is skipped because byte +0x677 is already set).
	_setup(0x900, 0)
	memory.write_u8(CTL + 0x677, 1)
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x684), memory.read_u16(CTL + 0x688), port.overlay_rng_next() == twin.overlay_rng_next()], [0x900, 0x16, true], "new burning with 0x800: timer 0x16") and ok
	## Burning already with 0x800: destroyed (0x400) on the spot.
	_setup(0x900, 0x900)
	memory.write_u16(PoolFixtureScript.WORLD + 0x90, 6)
	memory.write_u16(PLANE + 0x50, 3)
	memory.write_u16(CTL + 0x684, 0x8900)
	memory.write_u16(CTL + 0x686, 0x8900)
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x684) & 0x7c0, memory.read_u16(CTL + 0x686) & 0x400, memory.read_u16(PoolFixtureScript.WORLD + 0xce), memory.read_u16(PoolFixtureScript.WORLD + 0xb8 + 6), memory.read_u32(PLANE + 0x18), memory.read_u16(0x1b870), port.a7], [0x400, 0x400, 1, 1, 1000000000, 0, STACK_TOP], "destroyed: stage bits cleared, mission-6 flag, kill tallied, aircraft cleaned up, replay state restored") and ok

	## The player newly at bit 0x1 without a parachute: flags and the "ugh" sound.
	_setup(0x1, 0)
	memory.write_u32(0x1b738, CTL)
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal([memory.read_u16(0x1b874), memory.read_u16(0x1b872), memory.read_u16(PoolFixtureScript.WORLD + 0xd4), memory.read_u16(0x1b844)], [1, 0, 1, 1], "player bit 0x1: bail-out flags") and ok

	## AI with bit 0x100 and no bail-out yet: one rng & 0x1f == 0 sets byte +0x677.
	_setup(0x100, 0x100)
	memory.write_u16(CTL + 0x688, 3)
	var bails: bool = (twin.overlay_rng_next() & 0x1f) == 0
	port.update_aircraft_damage_state(CTL)
	ok = Assertions.assert_equal(memory.read_u8(CTL + 0x677), 1 if bails else 0, "AI bail-out roll") and ok
	return ok
