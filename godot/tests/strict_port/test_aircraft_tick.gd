extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const PLANE := 0x21000
const CTL := 0x21100
const PLAYER_CTL := 0x21900
const TYPE := 0x21f00
const AI := 0x70d ## test-only AI / flight handler at +0x32

## Expected values follow the disassembly of aircraft_tick (0xe5aa; pose ring index scale 4
## decoded from the extension word). The AI handler is a stub that sets the velocity; damage
## words without stage bits keep update_aircraft_damage_state from drawing rng, except where
## noted (a twin overlay RNG predicts the timer then).

var memory
var port
var twin
var fixture
var ai_calls: Array = []

func _ai(ctl: int) -> void:
	ai_calls.append([ctl, port.a7])
	memory.write_u32(ctl + 8, 5)
	memory.write_u32(ctl + 0xc, 6)
	memory.write_u32(ctl + 0x10, 7)

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	port.code_table[AI] = Callable(self, "_ai")
	ai_calls.clear()
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(5, 5)
	fixture.make_far(5)
	memory.write_u32(0x26650, fixture.template_object(0x22500, 5))
	memory.write_u32(CTL, PLANE)
	memory.write_u32(PLANE + 8, CTL)
	memory.write_u32(CTL + 4, TYPE)
	memory.write_u16(TYPE, 3)
	memory.write_u32(CTL + 0x32, AI)
	memory.write_u32(PLANE + 0x18, 100)
	memory.write_u32(PLANE + 0x1c, 200)
	memory.write_u32(PLANE + 0x20, 300)
	memory.write_u16(CTL + 0x20, 0x11)
	memory.write_u16(CTL + 0x22, 0x22)
	memory.write_u16(CTL + 0x24, 0x33)
	memory.write_u32(0x1b738, PLAYER_CTL)
	memory.write_u8(PLAYER_CTL + 0x679, 0x2d)
	memory.write_u32(0x1b838, 50)
	memory.write_u32(PLANE + 0x40, 50)

func _pose(i: int) -> Array:
	var p: int = CTL + 0x36 + 0x14 * i
	return [memory.read_s32(p), memory.read_s32(p + 4), memory.read_s32(p + 8), memory.read_u16(p + 0xc), memory.read_u16(p + 0xe), memory.read_u16(p + 0x10), memory.read_u16(p + 0x12)]

func _record(i: int, pos: Array, damage: int) -> void:
	var p: int = CTL + 0x36 + 0x14 * i
	for k in range(3):
		memory.write_u32(p + 4 * k, pos[k])
	memory.write_u16(p + 0xc, 0x44)
	memory.write_u16(p + 0xe, 0x55)
	memory.write_u16(p + 0x10, 0x66)
	memory.write_u16(p + 0x12, damage)

func run() -> bool:
	var ok := true

	## Live play: the handler flies, the entry records position + velocity, angles, damage.
	_setup()
	port._jsr(0xe58a, [CTL])
	ok = Assertions.assert_equal([ai_calls, _pose(0), memory.read_u16(CTL + 0x612), port.a7], [[[CTL, STACK_TOP - 0x18]], [105, 206, 307, 0x11, 0x22, 0x33, 0], 1, STACK_TOP], "live: AI handler, pose recorded") and ok
	## The index wraps after entry 0x4a.
	memory.write_u16(CTL + 0x612, 0x4a)
	port.aircraft_tick(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x612), _pose(0x4a)[0]], [0, 105], "ring wraps at 0x4b") and ok
	## Destroyed now and last frame: no flight, velocity 0.
	_setup()
	memory.write_u16(CTL + 0x684, 0x400)
	memory.write_u16(CTL + 0x686, 0x400)
	memory.write_u32(CTL + 8, 9)
	port.aircraft_tick(CTL)
	ok = Assertions.assert_equal([ai_calls.size(), memory.read_u32(CTL + 8), _pose(0)], [0, 0, [100, 200, 300, 0x11, 0x22, 0x33, 0x400]], "destroyed: no flight, pose at the wreck") and ok

	## Replay before the start frame: nothing but the index.
	_setup()
	memory.write_u16(0x1b870, 2)
	memory.write_u32(PLANE + 0x40, 51)
	port.aircraft_tick(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x612), memory.read_s32(PLANE + 0x18)], [1, 100], "replay before the start frame") and ok
	## Start frame: jump onto the entry; gear up (0x2000) -> gear byte 0.
	_setup()
	memory.write_u16(0x1b870, 2)
	_record(0, [1, 2, 3], 0x2000)
	port.aircraft_tick(CTL)
	ok = Assertions.assert_equal([memory.read_s32(PLANE + 0x18), memory.read_s32(PLANE + 0x20), memory.read_u32(CTL + 8), memory.read_u16(CTL + 0x684), memory.read_u16(CTL + 0x686), memory.read_u8(CTL + 0x679), memory.read_u16(CTL + 0x22), ai_calls.size()], [1, 3, 0, 0x2000, 0x2000, 0, 0x55, 0], "replay start: jump, gear up, no flight") and ok
	## Start frame with a recorded burning stage (0x100, no 0x1000): restarts as new smoke, whose
	## step arms a timer (the trail spawns nothing).
	_setup()
	memory.write_u16(0x1b870, 2)
	_record(0, [1, 2, 3], 0x100)
	var timer: int = 0x7f + ((twin.overlay_rng_next() & 0xff) >> 1)
	port.aircraft_tick(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x684), memory.read_u16(CTL + 0x688)], [0x40, timer], "replay start: stage restarted as smoke") and ok
	## Later frame: velocity is the step to the entry. The gear-bit test after the damage step
	## never fires - update_aircraft_damage_state always ends with +0x686 = +0x684 - so the gear
	## byte is left alone, as in the bytes.
	_setup()
	memory.write_u16(0x1b870, 2)
	memory.write_u32(0x1b838, 60)
	_record(0, [110, 200, 290], 0x2000)
	port.aircraft_tick(CTL)
	ok = Assertions.assert_equal([memory.read_s32(CTL + 8), memory.read_s32(CTL + 0x10), memory.read_s32(PLANE + 0x18), memory.read_u16(CTL + 0x684), memory.read_u8(CTL + 0x679), memory.read_u16(CTL + 0x686)], [10, -10, 100, 0x2000, 0, 0x2000], "replay later: step velocity, gear byte untouched (dead check)") and ok
	return ok
