extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const GUN := 0x21000
const CTL := 0x21100
const VERTS := 0x21300
const FACES := 0x21400
const IDX := 0x21480
const TARGET := 0x21800
const TARGET_CTL := 0x21900
const INIT := 0x705

## Expected values follow the disassembly of tick_flak_gun (0x18c96). Aim angles come from the
## attitude_from_velocity Python model (test_inverse_trig.gd): barrel normal offset (30, 40, 0)
## -> heading 0x3000, pitch 64; target offset (0, 1500, 500) -> heading 0, pitch 3257. Rng
## draws are predicted by a twin overlay RNG; bursts go through the strict spawn_effect
## (PoolFixture, effect initialisers stubbed) and apply_blast_damage.

var memory
var port
var twin
var fixture

func _init_handler(_obj: int) -> void:
	pass

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
	port.code_table[INIT] = Callable(self, "_init_handler")
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	for k in range(4):
		fixture.add_template(k, 5)
		memory.write_u32(0x2626e + 4 * k, fixture.template_object(0x22000 + 0x100 * k, k))
		memory.write_u32(0x1b40c + 4 * k, INIT)
	memory.write_u32(0x1b838, 100)
	memory.write_u32(CTL, GUN)
	memory.write_u32(GUN + 8, CTL)
	memory.write_u32(GUN + 0x44, VERTS)
	memory.write_u32(GUN + 0x48, FACES)
	memory.write_u16(GUN + 0x36, 4)
	memory.write_u16(GUN + 0x3a, 2)
	var points := [[0, 0, 0], [100, 0, 0], [100, 0, 100], [0, 0, 100], [9, 9, 9], [30, 40, 0]]
	for n in range(points.size()):
		for c in range(3):
			memory.write_u32(VERTS + 12 * n + 4 * c, points[n][c])
	## Face 0 is not the barrel; face 1 (byte +0x17 = 1) has vertices 0, 1, 2.
	memory.write_u8(FACES + 0x20 + 0x17, 1)
	memory.write_u16(FACES + 0x20 + 0x14, 3)
	memory.write_u32(FACES + 0x20 + 0x18, IDX)
	for k in range(3):
		memory.write_u16(IDX + 2 * k, k)
	memory.write_u32(CTL + 0x42, 10000)
	memory.write_u16(CTL + 0x46, 5)
	memory.write_u32(TARGET + 8, TARGET_CTL)
	memory.write_u32(TARGET + 0x44, 1)
	memory.write_u32(TARGET + 0x1c, 3000)
	memory.write_u32(TARGET + 0x20, 1000)
	memory.write_u32(TARGET_CTL + 8, 10)
	memory.write_u32(TARGET_CTL + 0x10, -20 & 0xffffffff)
	memory.write_u32(TARGET_CTL + 0x2e, 2900)
	memory.write_u8(TARGET + 3, 1)

func run() -> bool:
	var ok := true

	## First tick: barrel at the mean of face 1 ((0 + 100 + 100) / 3, 0, 100 / 3), aimed along its
	## normal point minus vertex 0; the facility probe runs once. No target yet.
	_setup()
	port._jsr(0x18c76, [CTL])
	ok = Assertions.assert_equal([memory.read_s32(CTL + 0x48), memory.read_s32(CTL + 0x4c), memory.read_s32(CTL + 0x50), memory.read_u16(CTL + 0x56), memory.read_u16(CTL + 0x54), memory.read_u16(CTL + 0x40), port.a7], [66, 0, 33, 0x3000, 64, 1, STACK_TOP], "barrel set up once") and ok

	## A retired gun releases its target.
	_setup()
	memory.write_u32(CTL + 0x36, TARGET)
	memory.write_u8(GUN + 7, 2)
	port.tick_flak_gun(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x36), memory.read_u8(TARGET + 3)], [0, 0], "retired gun releases the target") and ok
	## Out of shells: target released.
	_setup()
	memory.write_u32(CTL + 0x36, TARGET)
	memory.write_u16(CTL + 0x46, 0)
	port.tick_flak_gun(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x36), memory.read_u8(TARGET + 3)], [0, 0], "no shells: target released") and ok

	## Shooting: one draw per frame until & 0x3f == 0x15; the barrel heading is 0 (target dead
	## ahead in z). Distance 3000 + 1000 / 4 = 3250 -> fuse 3 frames; lead = 3 + rng & 0x3f.
	_setup()
	memory.write_u16(CTL + 0x40, 1)
	memory.write_u16(CTL + 0x56, 0)
	memory.write_u32(CTL + 0x36, TARGET)
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0x3f) == 0x15:
			break
	var lead: int = 3 + (twin.overlay_rng_next() & 0x3f)
	var bx: int = lead * 10 - 0x800 + (twin.overlay_rng_next() & 0xfff)
	var by: int = 3000 - 0x800 + (twin.overlay_rng_next() & 0xfff)
	var bz: int = lead * -20 + 1000 - 0x800 + (twin.overlay_rng_next() & 0xfff)
	if by - 500 < 2900:
		by = 3400
	for f in range(frames):
		port.tick_flak_gun(CTL)
	ok = Assertions.assert_equal([memory.read_u32(CTL + 0x3a), memory.read_u16(CTL + 0x46), memory.read_u32(CTL + 0xd2), memory.read_s32(CTL + 0x5a), memory.read_s32(CTL + 0x5e), memory.read_s32(CTL + 0x62)], [3250, 4, 103, bx, by, bz], "shot after the predicted frame: fuse, lead, jitter, floor") and ok
	## Out of the barrel's arc (heading 0 vs barrel 0x2001 -> fold 0x1fff > 0x1000): no shot.
	_setup()
	memory.write_u16(CTL + 0x40, 1)
	memory.write_u16(CTL + 0x56, 0x2001)
	memory.write_u32(CTL + 0x36, TARGET)
	for f in range(frames):
		port.tick_flak_gun(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x46), memory.read_u32(CTL + 0xd2)], [5, 0], "outside the barrel's arc: no shot") and ok

	## A due burst slot explodes: logged as spawn_effect(2, 100, 0x1e) at its point, slot cleared.
	_setup()
	memory.write_u16(CTL + 0x40, 1)
	memory.write_u32(CTL + 0x36, TARGET)
	memory.write_u32(CTL + 0xd2 + 4 * 3, 100)
	memory.write_u32(CTL + 0x5a + 12 * 3, 11)
	memory.write_u32(CTL + 0x5a + 12 * 3 + 4, 22)
	memory.write_u32(CTL + 0x5a + 12 * 3 + 8, 33)
	memory.write_u32(CTL + 0xd2 + 4 * 4, 101)
	port.tick_flak_gun(CTL)
	var e := 0x260ee
	ok = Assertions.assert_equal([memory.read_u8(e), memory.read_s16(e + 4), memory.read_s16(e + 6), memory.read_s32(e + 8), memory.read_s32(e + 0xc), memory.read_s32(e + 0x10), memory.read_u32(CTL + 0xd2 + 12), memory.read_u32(CTL + 0xd2 + 16), port.a7], [2, 100, 0x1e, 11, 22, 33, 0, 101, STACK_TOP], "due burst explodes, later one waits") and ok
	## Replaying: nothing after the setup.
	memory.write_u16(0x1b870, 2)
	memory.write_u32(CTL + 0xd2 + 16, 50)
	port.tick_flak_gun(CTL)
	ok = Assertions.assert_equal(memory.read_u32(CTL + 0xd2 + 16), 50, "replay: no bursts") and ok
	return ok
