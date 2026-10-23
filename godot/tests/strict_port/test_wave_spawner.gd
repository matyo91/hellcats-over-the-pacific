extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const CTL := 0x21000
const FIGHTER_TEMPLATE := 0x22100
const TARGETS := 0x21400

## Expected values follow the disassembly of spawn_enemy_fighter (0xe262) and tick_wave_spawner
## (0x180c8). Rng draws come from a twin overlay RNG; sin / cos are the verified strict
## sin_fixed14 / cos_fixed14 over the original tables. The fighter template spawns through the
## strict pool chain (PoolFixture, its factory controllers).

var memory
var port
var twin
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 5)
	memory.write_u32(0x26000, fixture.template_object(FIGHTER_TEMPLATE, 1))
	memory.write_u32(0x20adc, TARGETS)
	memory.write_u32(0x1b838, 500)
	memory.write_u16(CTL + 0x32, 6)
	memory.write_u32(CTL + 0x34, 500)

func run() -> bool:
	var ok := true

	## Not due, none left, or replaying: nothing (no rng drawn).
	_setup()
	memory.write_u32(CTL + 0x34, 501)
	port._jsr(0x180a8, [CTL])
	memory.write_u32(CTL + 0x34, 500)
	memory.write_u16(0x1b870, 1)
	port.tick_wave_spawner(CTL)
	memory.write_u16(0x1b870, 0)
	memory.write_u16(CTL + 0x32, 0)
	port.tick_wave_spawner(CTL)
	ok = Assertions.assert_equal([fixture.activated().size(), memory.read_u32(CTL + 0x34)], [0, 500], "idle cases") and ok

	## Due, 6 left, host mode 7: a fighter on a random bearing, recorded in the target list.
	_setup()
	memory.write_u16(PoolFixtureScript.WORLD + 0x90, 7)
	var bearing: int = (((twin.overlay_rng_next() & 0xffff) % 0x1540) + 0xf580) & 0x3fff
	var r: int = twin.overlay_rng_next()
	if r >= 0x8000:
		r -= 0x10000
	var dist: int = (r + 0x5a3c0) >> 4
	var x: int = -0xb92670 - ((port.sin_fixed14(bearing) * dist) >> 8)
	var z: int = ((port.cos_fixed14(bearing) * dist) >> 8) + 0x7f8e4c
	twin.overlay_rng_next()
	var next: int = 500 + 0x1356 + ((twin.overlay_rng_next() & 0xffff) % 0x1c2) - 0xe1
	port.tick_wave_spawner(CTL)
	var fighter_obj: int = fixture.activated()[0]
	var fighter: int = memory.read_u32(fighter_obj + 8)
	ok = Assertions.assert_equal([memory.read_s32(fighter_obj + 0x18), memory.read_s32(fighter_obj + 0x1c), memory.read_s32(fighter_obj + 0x20)], [x, 40000, z], "fighter placed on the bearing") and ok
	ok = Assertions.assert_equal([memory.read_u16(fighter + 0x684) & 0x20, memory.read_u32(fighter + 0x32), memory.read_u16(CTL + 0x32), memory.read_u32(TARGETS + 6 + 5 * 4), memory.read_u32(CTL + 0x34), port.a7], [0x20, 0x111ba, 5, fighter, next, STACK_TOP], "fighter flagged, counted, listed; next wave delay for 5 left") and ok

	## Target list word +4 set: no 0x111ba handler; other host mode: not listed; 4 left -> 0x546.
	_setup()
	memory.write_u16(TARGETS + 4, 1)
	memory.write_u16(CTL + 0x32, 5)
	twin.overlay_rng_next()
	twin.overlay_rng_next()
	twin.overlay_rng_next()
	next = 500 + 0x546 + ((twin.overlay_rng_next() & 0xffff) % 0x1c2) - 0xe1
	port.tick_wave_spawner(CTL)
	fighter = memory.read_u32(fixture.activated()[0] + 8)
	ok = Assertions.assert_equal([memory.read_u32(fighter + 0x32), memory.read_u16(CTL + 0x32), memory.read_u32(TARGETS + 6 + 4 * 4), memory.read_u32(CTL + 0x34)], [0, 4, 0, next], "mission list set, mode 0: plain fighter, short delay") and ok

	## The spawn fails (far template): count kept, still rescheduled.
	_setup()
	fixture.make_far(1)
	port.tick_wave_spawner(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x32), memory.read_u32(CTL + 0x34) > 500], [6, true], "failed spawn: count kept, rescheduled") and ok
	return ok
