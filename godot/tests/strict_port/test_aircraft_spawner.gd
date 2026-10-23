extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const SPAWNER := 0x21000
const CTL := 0x21100
const PLAYER := 0x21200
const PLAYER_CTL := 0x21300
const OLD := 0x21400
const OLD_CTL := 0x21500
const FIGHTER_TEMPLATE := 0x22100

## Expected values follow the disassembly of tick_aircraft_spawner (0x17dd4; slot index scale 4
## and the divsl.l remainder decoded from the extension words). The spawner sits 10000 along +z
## from the player, so attitude_from_velocity gives bearing 0 before the random turn. Rng draws
## come from a twin overlay RNG; sin / cos are the verified strict functions over the original
## tables; fighters spawn through the strict pool chain (PoolFixture).

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
		memory.write_u8(0x1af6c + i, binary[0x1af8c + i])
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(1, 5)
	memory.write_u32(0x26000, fixture.template_object(FIGHTER_TEMPLATE, 1))
	memory.write_u32(0x1b738, PLAYER_CTL)
	memory.write_u32(PLAYER_CTL, PLAYER)
	memory.write_u32(PLAYER + 0x18, 50000)
	memory.write_u32(PLAYER + 0x20, 60000)
	memory.write_u32(SPAWNER + 0x18, 50000)
	memory.write_u32(SPAWNER + 0x20, 70000)
	memory.write_u32(SPAWNER + 0xc, 0x40740)
	memory.write_u32(CTL, SPAWNER)
	memory.write_u16(CTL + 0x32, 5)

func run() -> bool:
	var ok := true

	## A tracked undamaged aircraft holds the group back (no rng drawn); a retired one is released.
	_setup()
	memory.write_u32(CTL + 0x34 + 8, OLD)
	memory.write_u32(OLD + 8, OLD_CTL)
	memory.write_u32(OLD_CTL, OLD)
	memory.write_u8(OLD + 3, 1)
	port._jsr(0x17db4, [CTL])
	ok = Assertions.assert_equal([fixture.activated().size(), memory.read_u32(CTL + 0x3c)], [0, OLD], "an undamaged aircraft holds the group back") and ok
	memory.write_u8(OLD + 7, 2)
	port.tick_aircraft_spawner(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x3c), memory.read_u8(OLD + 3)], [0, 0], "retired aircraft released") and ok

	## Launch: frames until the 1-in-512 gate opens, then the group.
	_setup()
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0x1ff) == 0:
			break
	var group: int = (twin.overlay_rng_next() & 0xffff) % 3 + 1
	var bearing: int = (((twin.overlay_rng_next() & 0x1f) - 0x10) << 6) & 0x3fff
	var r: int = ((0x40740 * 2) / 3) >> 5
	var signed_bearing: int = bearing - 0x4000 if bearing >= 0x2000 else bearing
	var x: int = 50000 - ((r * port.sin_fixed14(signed_bearing)) >> 7)
	var altitude: int = (twin.overlay_rng_next() & 0xfff) * 10 + 30000
	var z: int = 60000 + ((r * port.cos_fixed14(signed_bearing)) >> 7)
	twin.overlay_rng_next()
	var want := []
	for k in range(group):
		x += (twin.overlay_rng_next() & 0xfff) - 0x800
		z += (twin.overlay_rng_next() & 0xfff) - 0x800
		want.append([x, altitude, z])
	for f in range(frames):
		port.tick_aircraft_spawner(CTL)
	var got := []
	for k in range(group):
		var obj: int = memory.read_u32(CTL + 0x34 + 4 * k)
		got.append([memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20)] if obj != 0 else [])
	ok = Assertions.assert_equal(got, want, "group of %d placed around the bearing, offsets cumulative" % group) and ok
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x32), memory.read_u8(memory.read_u32(CTL + 0x34) + 3), port.a7], [5 - group, 1, STACK_TOP], "left count, slots and reference bytes") and ok

	## Replaying or none left: nothing.
	_setup()
	memory.write_u16(0x1b870, 2)
	for f in range(frames):
		port.tick_aircraft_spawner(CTL)
	memory.write_u16(0x1b870, 0)
	memory.write_u16(CTL + 0x32, 0)
	for f in range(frames):
		port.tick_aircraft_spawner(CTL)
	ok = Assertions.assert_equal(fixture.activated().size(), 0, "replay / none left: no launch") and ok
	return ok
