extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const PLANE := 0x21000
const PLANE_CTL := 0x21100
const LIST := 0x21800
const SMOKE := 0x22100
const FIRE := 0x22200

## Expected values follow the disassembly of request_instant_replay (0x8784),
## attach_trailing_plume (0x11670), spawn_ground_fire_object (0x170ba), attach_ground_fire
## (0x17102) and remove_mission_target (0x17ffe). Spawns run through the strict pool chain
## (PoolFixture; templates 1 = smoke, 2 = ground fire).

var memory
var port
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 5)
	fixture.add_template(2, 5)
	memory.write_u32(0x260e8, fixture.template_object(SMOKE, 1))
	memory.write_u32(0x26658, fixture.template_object(FIRE, 2))
	memory.write_u32(PLANE_CTL, PLANE)
	memory.write_u32(PLANE + 8, PLANE_CTL)

func run() -> bool:
	var ok := true

	_setup()
	port.request_instant_replay(5)
	var first: int = memory.read_u16(0x1b86c)
	port.request_instant_replay(0)
	ok = Assertions.assert_equal([first, memory.read_u16(0x1b86c)], [1, 2], "replay request: airborne 1, ground 2") and ok

	## Trailing plume at (10, 20, 30): eight trail points at the plume, flags, owner linked.
	_setup()
	port.attach_trailing_plume(10, 20, 30, PLANE_CTL)
	var plume_obj: int = fixture.activated()[0]
	var plume: int = memory.read_u32(plume_obj + 8)
	var pts := []
	for i in [0, 7]:
		pts.append([memory.read_s32(plume + 0x40 + 12 * i), memory.read_s32(plume + 0x44 + 12 * i), memory.read_s32(plume + 0x48 + 12 * i)])
	ok = Assertions.assert_equal([pts, memory.read_u32(plume_obj + 4) & 0x100000, memory.read_u16(plume_obj + 0x34), memory.read_u32(plume + 0x3c), memory.read_u8(PLANE + 3), memory.read_u16(plume + 0x36), port.a7], [[[10, 20, 30], [10, 20, 30]], 0, 0, PLANE, 1, 0x48, STACK_TOP], "trailing plume seeded and owned") and ok

	## Ground fire: state 1, timer 0x2d, owner linked.
	_setup()
	var fire: int = port.attach_ground_fire(1, 2, 3, PLANE_CTL)
	ok = Assertions.assert_equal([fire != 0, memory.read_u16(fire + 0x34), memory.read_u16(fire + 0x32), memory.read_u32(fire + 0x50), memory.read_u8(PLANE + 3)], [true, 1, 0x2d, PLANE, 1], "ground fire attached") and ok
	## No template object can be spawned (far): 0.
	_setup()
	fixture.make_far(2)
	ok = Assertions.assert_equal(port.attach_ground_fire(1, 2, 3, PLANE_CTL), 0, "ground fire: nothing spawned -> 0") and ok

	## Mission target list: three slots, the aircraft in two of them.
	_setup()
	memory.write_u32(0x20adc, LIST)
	memory.write_u16(LIST, 2)
	memory.write_u16(LIST + 2, 3)
	memory.write_u32(LIST + 6, PLANE_CTL)
	memory.write_u32(LIST + 10, 0x1234)
	memory.write_u32(LIST + 14, PLANE_CTL)
	port.remove_mission_target(PLANE_CTL)
	ok = Assertions.assert_equal([memory.read_u32(LIST + 6), memory.read_u32(LIST + 10), memory.read_u32(LIST + 14), memory.read_u16(LIST), memory.read_u16(PoolFixtureScript.WORLD + 0xce)], [0, 0x1234, 0, 0, 1], "both entries cleared; count 0 -> host +0xce = 1") and ok
	## Count left non-zero, or +0xce already set: +0xce unchanged.
	memory.write_u16(LIST, 1)
	memory.write_u16(PoolFixtureScript.WORLD + 0xce, 0)
	port.remove_mission_target(0x5555)
	ok = Assertions.assert_equal(memory.read_u16(PoolFixtureScript.WORLD + 0xce), 0, "targets left: +0xce unchanged") and ok
	return ok
