extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const CTL := 0x21100
const GUN := 0x21200
const GUN_CTL := 0x21300
const PLANE := 0x21400
const PLANE_CTL := 0x21500
const PLANE_TYPE := 0x21580
const PLANE2 := 0x21600

## Expected values follow the disassembly of spin_object_heading (0x114b4), face_camera_heading
## (0x11ae6), create / destroy_aircraft_spawner_controller (0x17d16 / 0x17db8; the destroy
## handler releases slots 0..2 only), create_wave_spawner_controller (0x18040),
## destroy_flak_controller (0x18b98) and flak_notice_object (0x18bba). Each is reached through
## code_table at its runtime address (definition records +2 / +6 / +0xa / +0xe / +0x16 found by
## scanning the data file). Rng draws come from a twin overlay RNG.

var memory
var port
var twin

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	PoolFixtureScript.new().setup(memory, port)
	memory.write_u32(0x1b838, 100)

func run() -> bool:
	var ok := true

	_setup()
	memory.write_u16(CTL + 0x22, 0x3fe0)
	port._jsr(0x11494, [CTL])
	ok = Assertions.assert_equal(memory.read_u16(CTL + 0x22), 0x20, "spin: +0x40, wraps") and ok
	memory.write_u16(0x1d80e, 0x0100)
	ok = Assertions.assert_equal([port._jsr(0x11ac6, [CTL]), memory.read_u16(CTL + 0x22)], [0, 0x3f00], "face camera: negated heading") and ok

	## Aircraft spawner create: the range picks the count.
	for c in [[0x80e80, 1], [0xc15c0, 2], [0x40740, 3], [0x12345, 4]]:
		_setup()
		memory.write_u32(OBJ + 0xc, c[0])
		memory.write_u32(0x1b524 + 0x12 * 4, 0x2ca00)
		var r: int = twin.overlay_rng_next() & 0xf
		var want: int = r
		match c[1]:
			1:
				want = (r & 3) + 1
			2:
				want = (r & 3) + 2
			3:
				want = r % 3
		var ctl: int = port._jsr(0x17cf6, [OBJ, 0x12, 0])
		ok = Assertions.assert_equal([memory.read_u32(ctl), memory.read_u32(ctl + 4), memory.read_u32(OBJ + 4), memory.read_u16(ctl + 0x32)], [OBJ, 0x2ca00, 0x130040, want], "aircraft spawner create, range 0x%x" % c[0]) and ok
	## Another key: no byte +5 bit 4.
	_setup()
	var other_ctl: int = port.create_aircraft_spawner_controller(OBJ, 0x13)
	ok = Assertions.assert_equal(memory.read_u32(OBJ + 4), 0x30040, "key 0x13: no +5 bit 4") and ok
	## Destroy: only slots 0..2 are released.
	for i in range(5):
		memory.write_u32(other_ctl + 0x34 + 4 * i, PLANE + 0x10 * i)
		memory.write_u8(PLANE + 0x10 * i + 3, 5)
	port._jsr(0x17d98, [other_ctl])
	var refs := []
	for i in range(5):
		refs.append(memory.read_u8(PLANE + 0x10 * i + 3))
	ok = Assertions.assert_equal(refs, [4, 4, 4, 5, 5], "aircraft spawner destroy releases slots 0..2 only") and ok

	## Wave spawner create: in host mode 7 the mission target list is allocated.
	_setup()
	memory.write_u16(PoolFixtureScript.WORLD + 0x90, 7)
	var wave: int = port._jsr(0x18020, [OBJ, 0x14, 0])
	var list: int = memory.read_u32(0x20adc)
	ok = Assertions.assert_equal([memory.read_u16(wave + 0x32), memory.read_u32(wave + 0x34), memory.read_u32(OBJ + 4), list != 0, memory.read_u16(list), memory.read_u16(list + 2), memory.read_u32(list + 6)], [10, 100 + 0x546, 0x130040, true, 10, 10, 0], "wave spawner create (mode 7)") and ok
	_setup()
	port.create_wave_spawner_controller(OBJ, 0x14)
	ok = Assertions.assert_equal(memory.read_u32(0x20adc), 0, "wave spawner create (mode 0): no list") and ok

	## Flak destroy: both references dropped.
	_setup()
	memory.write_u32(GUN_CTL + 0x36, PLANE)
	memory.write_u32(GUN_CTL + 0x32, PLANE2)
	memory.write_u8(PLANE + 3, 1)
	memory.write_u8(PLANE2 + 3, 1)
	port._jsr(0x18b78, [GUN_CTL])
	ok = Assertions.assert_equal([memory.read_u8(PLANE + 3), memory.read_u8(PLANE2 + 3)], [0, 0], "flak destroy") and ok

	## Flak notice: an enemy-carrier gun (0x200) takes a type-3 aircraft 1000 away once the
	## 1-in-64 draw comes (chance 0x339000 / 1000 = 3379 always beats rng & 0x7f).
	_setup()
	memory.write_u32(GUN + 8, GUN_CTL)
	memory.write_u16(GUN_CTL + 0x3e, 0x200)
	memory.write_u16(GUN_CTL + 0x40, 1)
	memory.write_u32(PLANE + 8, PLANE_CTL)
	memory.write_u32(PLANE_CTL + 4, PLANE_TYPE)
	memory.write_u16(PLANE_TYPE, 3)
	memory.write_u32(PLANE + 0x18, 1000)
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0x3f) == 0:
			break
	var d0: int = 0
	for f in range(frames):
		d0 = port._jsr(0x18b9a, [GUN, PLANE, 0])
	var r2: int = twin.overlay_rng_next() & 0x7f
	ok = Assertions.assert_equal([memory.read_u32(GUN_CTL + 0x36), memory.read_u32(GUN_CTL + 0x3a), memory.read_u8(PLANE + 3), d0], [PLANE, 1000, 1, r2], "flak notice: target taken (D0 = second draw)") and ok
	## A friendly-carrier gun (0x100) ignores type 3; the type word comes back over D0's high word.
	memory.write_u16(GUN_CTL + 0x3e, 0x100)
	ok = Assertions.assert_equal(port.flak_notice_object(GUN, PLANE, 0x12340000), 0x12340003, "flak notice: type 3 ignored by a 0x100 gun") and ok
	## Held target 1000 away: a closer one (400: 800 < 1000) replaces it.
	memory.write_u16(GUN_CTL + 0x3e, 0x200)
	memory.write_u32(PLANE2 + 8, PLANE_CTL)
	memory.write_u32(PLANE2 + 0x18, 400)
	frames = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0x3f) == 0:
			break
	for f in range(frames):
		port.flak_notice_object(GUN, PLANE2, 0)
	twin.overlay_rng_next()
	ok = Assertions.assert_equal([memory.read_u32(GUN_CTL + 0x36), memory.read_u32(GUN_CTL + 0x3a), memory.read_u8(PLANE + 3), memory.read_u8(PLANE2 + 3)], [PLANE2, 400, 0, 1], "flak notice: closer target replaces the held one") and ok
	return ok
