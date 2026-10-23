extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const SHIP := 0x21000
const CTL := 0x21100
const VERTS := 0x21300
const FACES := 0x21400
const IDX := 0x21500
const ORDNANCE_TEMPLATE := 0x22100

## Expected values follow the disassembly of spawn_weapon_entity (0x12840) and
## tick_firing_ship_controller (0x15356; the gun pick is a divsl.l remainder, decoded from the
## extension word). Gun aims come from the attitude_from_velocity Python model: normal offset
## (30, 40, 0) -> pitch 64, heading 0x3000; (0, 0, 50) -> pitch 0, heading 0. Rng draws come
## from a twin overlay RNG; shells spawn through the strict pool chain.

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
	memory.write_u32(0x26280, fixture.template_object(ORDNANCE_TEMPLATE, 1))
	memory.write_u32(CTL, SHIP)
	memory.write_u32(SHIP + 8, CTL)
	memory.write_u32(SHIP + 0x44, VERTS)
	memory.write_u32(SHIP + 0x48, FACES)
	memory.write_u16(SHIP + 0x36, 4)
	memory.write_u16(SHIP + 0x3a, 3)
	var points := [[0, 0, 0], [100, 0, 0], [100, 0, 100], [0, 0, 100], [30, 40, 0], [9, 9, 9], [0, 0, 50]]
	for n in range(points.size()):
		for c in range(3):
			memory.write_u32(VERTS + 12 * n + 4 * c, points[n][c])
	## Faces 0 and 2 are guns: vertices [0 1 2] and [1 2 3].
	for f in [[0, [0, 1, 2]], [2, [1, 2, 3]]]:
		var face: int = FACES + 0x20 * f[0]
		memory.write_u8(face + 0x17, 1)
		memory.write_u16(face + 0x14, 3)
		memory.write_u32(face + 0x18, IDX + 8 * f[0])
		for k in range(3):
			memory.write_u16(IDX + 8 * f[0] + 2 * k, f[1][k])
	memory.write_u16(CTL + 0x50, 4)

func run() -> bool:
	var ok := true

	## Sinking: only the sinking step (here not due) - no gun setup.
	_setup()
	memory.write_u16(CTL + 0x4c, 1)
	memory.write_u32(CTL + 0x48, 1000)
	port._jsr(0x15336, [CTL])
	ok = Assertions.assert_equal(memory.read_u16(CTL + 0x52), 0, "sinking ship: no guns set up") and ok

	## Gun setup, then shots: frames until a low byte of 0x1b.
	_setup()
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0xff) == 0x1b:
			break
	var gun: int = (twin.overlay_rng_next() & 0xffff) % 2
	var aims := [[64, 0x3000], [0, 0]]
	var pitch: int = (aims[gun][0] + (twin.overlay_rng_next() & 0xff) - 0x80) & 0x3fff
	var heading: int = (aims[gun][1] + (twin.overlay_rng_next() & 0xff) - 0x80) & 0x3fff
	var speed: int = 0x7fff - (twin.overlay_rng_next() & 0xff)
	var guns := [[66, 0, 33], [66, 0, 66]]
	for f in range(frames):
		port.tick_firing_ship_controller(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x52), memory.read_s32(CTL + 0x54), memory.read_s32(CTL + 0x5c), memory.read_s32(CTL + 0x60), memory.read_s32(CTL + 0x68)], [2, 66, 33, 66, 66], "two guns at their face means") and ok
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0xe4), memory.read_u16(CTL + 0xe6), memory.read_u16(CTL + 0xea), memory.read_u16(CTL + 0xec)], [64, 0x3000, 0, 0], "gun aims") and ok
	var shell_obj: int = fixture.activated()[0]
	var shell: int = memory.read_u32(shell_obj + 8)
	ok = Assertions.assert_equal([memory.read_s32(shell_obj + 0x18), memory.read_s32(shell_obj + 0x1c), memory.read_s32(shell_obj + 0x20)], [guns[gun][0], guns[gun][1] + 10, guns[gun][2]], "shell from gun %d, 10 up" % gun) and ok
	ok = Assertions.assert_equal([memory.read_u16(shell + 0x610), memory.read_u16(shell + 0x61c) & 0x40, memory.read_u16(shell + 0x20), memory.read_u16(shell + 0x22), memory.read_u16(shell + 0x24), memory.read_u16(CTL + 0x50), port.a7], [speed, 0x40, pitch, heading, 0, 3, STACK_TOP], "shell speed, flag, jittered aim; one shot used") and ok

	## Replaying: the shot is used but nothing spawns.
	_setup()
	memory.write_u16(0x1b870, 2)
	for f in range(frames):
		port.tick_firing_ship_controller(CTL)
	ok = Assertions.assert_equal([fixture.activated().size(), memory.read_u16(CTL + 0x50)], [0, 3], "replay: shot used, no shell") and ok
	## No shots left: no rng, no shell.
	_setup()
	memory.write_u16(CTL + 0x50, 0)
	for f in range(frames):
		port.tick_firing_ship_controller(CTL)
	ok = Assertions.assert_equal(fixture.activated().size(), 0, "no shots left") and ok
	return ok
