extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const TURRET := 0x21000
const CTL := 0x21100
const CARRIER := 0x21200
const CARRIER_CTL := 0x21300
const TARGET := 0x21800
const BULLET_TEMPLATE := 0x22100
const SCRATCH := 0x21c00

## Expected values follow the disassembly of spawn_ordnance_scattered (0x15bf6),
## spawn_ordnance_oriented (0x15d20), spawn_ordnance_oriented_3ang (0x15d78) and tick_turret
## (0x1917c). The trig tables come from the original binary; rng draws are predicted by a twin
## overlay RNG seeded identically. Aiming (heading 0x3000, pitch 0 for a target straight along
## +x) matches the attitude_from_velocity model in test_inverse_trig.gd.

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
	memory.write_u32(0x2664a, fixture.template_object(BULLET_TEMPLATE, 1))
	memory.write_u32(CTL, TURRET)
	memory.write_u32(TURRET + 8, CTL)
	memory.write_u16(CTL + 0x40, 1)
	memory.write_u32(CTL + 0x42, 2000)
	memory.write_u32(TARGET + 0x18, 1000)
	memory.write_u32(TARGET + 0x44, 1)

func _bullet() -> int:
	for o in fixture.activated():
		if memory.read_u8(o + 1) == 1:
			return memory.read_u32(o + 8)
	return 0

func _identity(address: int) -> void:
	port.a7 = STACK_TOP - 0x400
	port.build_attitude_matrix_3ang(0, 0, 0, address)
	port.a7 = STACK_TOP

func run() -> bool:
	var ok := true

	## spawn_ordnance_scattered along the identity: velocity (0, 0, 0x100 asr 4 + 0x2015 = 0x2025)
	## plus the three jitters; bullet placed a quarter of it ahead; mode 5 -> +0x3a = 2.
	_setup()
	_identity(SCRATCH)
	var j := [(twin.overlay_rng_next() & 0x3f) - 0x20, (twin.overlay_rng_next() & 0x3f) - 0x20, (twin.overlay_rng_next() & 0x3f) - 0x20]
	var v := [j[0], j[1], 0x2025 + j[2]]
	var ctl: int = port.spawn_ordnance_scattered(0x100, 5, 100, 200, 300, SCRATCH)
	var bullet_obj: int = memory.read_u32(ctl)
	ok = Assertions.assert_equal([memory.read_s32(ctl + 8), memory.read_s32(ctl + 0xc), memory.read_s32(ctl + 0x10), memory.read_s32(ctl + 0x32), memory.read_u16(ctl + 0x38), memory.read_u16(ctl + 0x3a)], [v[0] >> 2, v[1] >> 2, v[2] >> 2, v[1] << 4, 0, 2], "scattered: velocity quarters, +0x32 = vy << 4, mode 2") and ok
	ok = Assertions.assert_equal([memory.read_s32(bullet_obj + 0x18), memory.read_s32(bullet_obj + 0x1c), memory.read_s32(bullet_obj + 0x20)], [100 + (v[0] >> 2), 200 + (v[1] >> 2), 300 + (v[2] >> 2)], "scattered: bullet placed ahead") and ok
	var same := true
	for i in range(0x12):
		same = same and memory.read_u8(ctl + 0x40 + i) == memory.read_u8(SCRATCH + i)
	ok = Assertions.assert_equal([same, port.a7], [true, STACK_TOP], "scattered: matrix copied to +0x40") and ok
	## The 4-angle variant with zero angles gives the same velocity frame (mode 0 -> 1).
	_setup()
	ctl = port.spawn_ordnance_oriented(0x100, 0, 0, 0, 0, 0, 0, 0, 0)
	ok = Assertions.assert_equal([memory.read_u16(ctl + 0x3a), memory.read_s32(ctl + 0x10) >> 9, port.a7], [1, 0x2025 >> 11, STACK_TOP], "oriented (4 angles): forward along z, mode 1") and ok

	## tick_turret: the facility probe runs once.
	_setup()
	memory.write_u16(CTL + 0x40, 0)
	memory.write_u16(CTL + 0x3e, 0x5555)
	port._jsr(0x1915c, [CTL])
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x40), memory.read_u16(CTL + 0x3e)], [1, 0], "probe once") and ok

	## Carried: the turret takes the carrier's position; a burning carrier releases it.
	_setup()
	memory.write_u32(CTL + 0x32, CARRIER)
	memory.write_u32(CARRIER + 0x44, 1)
	memory.write_u32(CARRIER + 8, CARRIER_CTL)
	memory.write_u32(CARRIER + 0x18, 77)
	memory.write_u32(CARRIER + 0x20, 88)
	memory.write_u8(CARRIER + 3, 1)
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([memory.read_s32(TURRET + 0x18), memory.read_s32(TURRET + 0x20)], [77, 88], "carried: follows the carrier") and ok
	memory.write_u8(CARRIER_CTL + 0x685, 0x10)
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x32), memory.read_u8(CARRIER + 3), memory.read_u32(TURRET + 0x18), port.a7], [0, 0, 1000000000, STACK_TOP], "burning carrier: released, turret cleaned up") and ok

	## A target without vertices is released.
	_setup()
	memory.write_u32(CTL + 0x36, TARGET)
	memory.write_u32(TARGET + 0x44, 0)
	memory.write_u8(TARGET + 3, 2)
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x36), memory.read_u8(TARGET + 3)], [0, 1], "target without vertices released") and ok

	## Aim along +x (distance 1000 within 2000): heading 0x3000, pitch 0; then wait for the
	## twin's first draw with a low nibble of 0 to start a burst.
	_setup()
	memory.write_u32(CTL + 0x36, TARGET)
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0xf) == 0:
			break
	var burst: int = (twin.overlay_rng_next() & 7) + 7
	var sx: int = (0x80 - (twin.overlay_rng_next() & 0xff)) & 0xffff
	var sy: int = (0x80 - (twin.overlay_rng_next() & 0xff)) & 0xffff
	for f in range(frames):
		port.tick_turret(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x3a), memory.read_u16(CTL + 0x4e), memory.read_u16(CTL + 0x4c)], [1000, 0x3000, 0], "aim: distance, heading, pitch") and ok
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x4a), memory.read_u16(CTL + 0x50), memory.read_u16(CTL + 0x52), fixture.activated().size()], [burst, sx, sy, 0], "burst started after the predicted number of frames") and ok
	## Out of range: nothing after the distance.
	memory.write_u32(CTL + 0x42, 999)
	memory.write_u16(CTL + 0x4e, 0)
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x4e), memory.read_u16(CTL + 0x4a)], [0, burst], "out of range: no aim, no burst step") and ok

	## Firing: delay 1 -> fire, scatter 0x10 / -0x10 -> 14 / -14, delay 2, burst 3 -> 2.
	_setup()
	memory.write_u32(CTL + 0x36, TARGET)
	memory.write_u16(CTL + 0x4a, 3)
	memory.write_u16(CTL + 0x48, 1)
	memory.write_u16(CTL + 0x50, 0x10)
	memory.write_u16(CTL + 0x52, -0x10 & 0xffff)
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([_bullet() != 0, memory.read_s16(CTL + 0x50), memory.read_s16(CTL + 0x52), memory.read_u16(CTL + 0x48), memory.read_u16(CTL + 0x4a), port.a7], [true, 14, -14, 2, 2, STACK_TOP], "fire: bullet, scatter 7/8, delay 2, burst - 1") and ok
	## Next frame: delay 2 -> 1, no shot.
	var before: int = fixture.activated().size()
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([fixture.activated().size(), memory.read_u16(CTL + 0x48), memory.read_u16(CTL + 0x4a)], [before, 1, 1], "delay counting, no shot") and ok
	## Replaying: aims but never fires.
	memory.write_u16(0x1b870, 2)
	memory.write_u16(CTL + 0x48, 0)
	port.tick_turret(CTL)
	ok = Assertions.assert_equal([fixture.activated().size(), memory.read_u16(CTL + 0x4a)], [before, 1], "replay: no fire") and ok
	return ok
