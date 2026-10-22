extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const CTL := 0x21200
const VERTS := 0x21400
const INIT := 0x705 ## test-only effect initialiser for the nested kind-1 spawn
const ANIM := 0x709 ## test-only animator for tick_effect

## Kinds 0 / 1: expected values from an instruction-level Python model of 0x123ce / 0x12486
## (asr.l #8 moves, v * 3 with +3 when negative and asr.l #2, 32-bit wrap), independent of this
## port. Velocities x = 1000, -1000, 255, -255, 7, -7 and z = -513, 513, -1, 1, 0x7fffff00,
## -0x7fffff00 (the last two overflow when tripled); vertex i = (10 i, 5, -20 i).
## tick_effect (0x12768), spawn_smoke_plume (0x115fc) and spawn_ground_mark (0x175de) follow
## their bytes; the spawners run through the strict pool chain (PoolFixture).
const VX := [1000, -1000, 255, -255, 7, -7]
const VZ := [-513, 513, -1, 1, 0x7fffff00, -0x7fffff00]

var memory
var port
var fixture
var anim_result := 0
var anim_calls: Array = []

func _init_handler(_obj: int) -> void:
	pass

func _anim(ctl: int) -> int:
	anim_calls.append([ctl, port.a7])
	return anim_result

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	port.code_table[INIT] = Callable(self, "_init_handler")
	port.code_table[ANIM] = Callable(self, "_anim")
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	for k in range(4):
		fixture.add_template(k, 5)
		memory.write_u32(0x2626e + 4 * k, fixture.template_object(0x22000 + 0x100 * k, k))
		memory.write_u32(0x1b40c + 4 * k, INIT)
	memory.write_u32(0x1b838, 1000)
	memory.write_u32(CTL, OBJ)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u32(OBJ + 0x18, 400)
	memory.write_u32(OBJ + 0x1c, 0)
	memory.write_u32(OBJ + 0x20, -900 & 0xffffffff)
	memory.write_u16(CTL + 0x34, 30)
	memory.write_u16(CTL + 0x36, 10)
	for i in range(6):
		memory.write_u32(CTL + 0x3a + 4 * i, VX[i] & 0xffffffff)
		memory.write_u32(CTL + 0x6e + 4 * i, VZ[i] & 0xffffffff)
		for c in range(3):
			memory.write_u32(VERTS + 12 * i + 4 * c, [10 * i, 5, -20 * i][c] & 0xffffffff)

func _longs(base: int, count: int) -> Array:
	var out := []
	for i in range(count):
		out.append(memory.read_s32(base + 4 * i))
	return out

func _verts(count: int) -> Array:
	var out := []
	for i in range(count):
		out.append(_longs(VERTS + 12 * i, 3))
	return out

func run() -> bool:
	var ok := true

	## Kind 0 through code_table at its runtime address.
	_setup()
	ok = Assertions.assert_equal(port._jsr(0x123ae, [CTL]), 0, "kind 0: running") and ok
	ok = Assertions.assert_equal(_verts(6), [[3, 5, -3], [6, 5, -18], [20, 5, -41], [29, 5, -60], [40, 5, 8388527], [49, 5, -8388707]], "kind 0: x / z moved by velocity asr 8") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 6), _longs(CTL + 0x6e, 6)], [[750, -750, 191, -191, 5, -5], [-384, 384, 0, 0, 536870720, -536870720]], "kind 0: velocities * 3 / 4 toward zero, 32-bit wrap") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x260ee + 8), 0, "kind 0: no spawn away from lifetime 0x47") and ok
	memory.write_u16(CTL + 0x36, 0)
	ok = Assertions.assert_equal(port.animate_effect_kind0_ring(CTL), 1, "kind 0: lifetime 0 -> finished") and ok
	memory.write_u16(CTL + 0x36, 5)
	memory.write_u16(0x1b870, 1)
	ok = Assertions.assert_equal([port.animate_effect_kind0_ring(CTL), port.animate_effect_kind1_column(CTL)], [1, 1], "rewind (replay_state 1) -> finished") and ok

	## Lifetime 0x47: a kind-1 effect (size 30, lifetime 0x47) at the object, logged by spawn_effect.
	_setup()
	memory.write_u16(CTL + 0x36, 0x47)
	port.animate_effect_kind0_ring(CTL)
	var e := 0x260ee
	ok = Assertions.assert_equal([memory.read_u8(e), memory.read_s16(e + 4), memory.read_s16(e + 6), memory.read_u8(e + 2), memory.read_s32(e + 8), memory.read_s32(e + 0xc), memory.read_s32(e + 0x10), port.a7], [1, 30, 0x47, 0, 400, 0, -900, STACK_TOP], "kind 0 at 0x47: spawn_effect(1, 30, 0x47, 0, 0, position)") and ok

	## Kind 1: +0x76 = 0x100 -> 0xa5, vertex 2 y 5 + (0xa5 asr 4) = 15; vertex 2 x / z untouched.
	_setup()
	memory.write_u32(CTL + 0x76, 0x100)
	ok = Assertions.assert_equal(port._jsr(0x12466, [CTL]), 0, "kind 1: running") and ok
	ok = Assertions.assert_equal([memory.read_s32(CTL + 0x76), _verts(4)], [165, [[3, 5, -3], [6, 5, -18], [20, 15, -40], [29, 5, -60]]], "kind 1: column rises, others spread") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 4), _longs(CTL + 0x6e, 2)], [[750, -750, 255, -191], [-384, 384]], "kind 1: velocities decay except vertex 2") and ok
	## Falling below 0: vertex 2 y 5, +0x76 = 0 -> -0x5b, y 5 + (-0x5b asr 4 = -6) = -1 -> finished.
	_setup()
	memory.write_u32(CTL + 0x76, 0)
	ok = Assertions.assert_equal([port.animate_effect_kind1_column(CTL), memory.read_s32(VERTS + 0x1c), memory.read_s32(VERTS)], [1, -1, 0], "kind 1: column below 0 -> finished, nothing else moved") and ok

	## tick_effect: the animator of kind byte +0x32 (entered 0xc below); lifetime counts down.
	_setup()
	memory.write_u8(CTL + 0x32, 2)
	memory.write_u32(0x1b41c + 8, ANIM)
	anim_result = 0x10000 ## only the low word is tested
	anim_calls.clear()
	port.tick_effect(CTL)
	ok = Assertions.assert_equal([anim_calls, memory.read_u16(CTL + 0x36), memory.read_u32(OBJ + 4), memory.read_u32(OBJ + 0x18)], [[[CTL, STACK_TOP - 0xc]], 9, 0, 400], "tick: animator called, lifetime 10 -> 9, D0.w 0 -> kept") and ok
	memory.write_u16(CTL + 0x36, 0)
	anim_result = 1
	port.tick_effect(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x36), memory.read_u32(OBJ + 4), memory.read_u32(OBJ + 0x18)], [0, 0x42, 1000000000], "tick at lifetime 0: hidden (0x40), finished -> retired (+4 |= 2, x = 1000000000)") and ok

	## spawn_smoke_plume: template 1 as the smoke template; words truncated, end frame.
	_setup()
	memory.write_u32(0x260e8, fixture.template_object(0x22800, 1))
	var smoke: int = port.spawn_smoke_plume(0x12345, 7, 50, 0xabcd1234, 99, 10, 20, 30)
	ok = Assertions.assert_equal([smoke != 0, memory.read_u16(smoke + 0x36), memory.read_u16(smoke + 0x34), memory.read_u16(smoke + 0x32), memory.read_u32(smoke + 0x38), port.a7], [true, 0x2345, 7, 0x1234, 1050, STACK_TOP], "smoke plume: sizes, word +0x32, end frame") and ok

	## spawn_ground_mark: template 2 with six vertex vectors; size 150 -> scale 384; each vertex
	## = spawn point + (vector * 384 >> 8).
	_setup()
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40 * 2
	memory.write_u16(desc + 0x1a, 6)
	var vecs := [[0, 0, 0], [100, 0, 0], [-100, 2, 0], [0, 0, 33], [0, 0, -33], [7, -7, 7]]
	for n in range(6):
		for c in range(3):
			memory.write_u32(desc + 0x22 + 12 * n + 4 * c, vecs[n][c] & 0xffffffff)
	memory.write_u32(0x26660, fixture.template_object(0x22a00, 2))
	var mark: int = port.spawn_ground_mark(150, 1000, 0, -2000)
	var mark_obj: int = memory.read_u32(mark)
	var got := []
	for n in range(6):
		var b: int = memory.read_u32(mark_obj + 0x44) + 12 * n
		got.append([memory.read_s32(b), memory.read_s32(b + 4), memory.read_s32(b + 8)])
	ok = Assertions.assert_equal(got, [[1000, 0, -2000], [1150, 0, -2000], [850, 3, -2000], [1000, 0, -1951], [1000, 0, -2050], [1010, -11, -1990]], "ground mark: vertices scaled about the spawn point") and ok
	ok = Assertions.assert_equal([memory.read_u16(mark_obj + 0x34), memory.read_u32(mark_obj + 0x3c), port.a7], [0, 1000 + 0xa8c, STACK_TOP], "ground mark: shift cleared, expiry frame") and ok
	return ok
