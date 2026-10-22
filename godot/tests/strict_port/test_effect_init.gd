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
const INIT := 0x705 ## test-only kind-2 initialiser for the nested spawn of kind 3
const DIRTY := 0xa5a5a5a5

## Kinds 0, 1 and 3: expected values from an instruction-level Python model of 0x1203a,
## 0x120ca and 0x1217e (asr.l by register, muls.l low long, asl / bpl / addq / asr #1, divs.l
## truncating), independent of this port. Inputs: object word +0x34 = 1, +0x14 = 1000, ctl
## size word +0x34 = 150 -> scale 38400 / 100 = 384, range 1500; vertex i = (100 (i + 1)
## (-1)^i + 3, -(7 i + 5), 37 i - 200). The controller starts filled with 0xa5 bytes so the
## slots an initialiser leaves alone stay visible.
## Kind 2: the same formulas from the bytes of 0x11efc, fed with the overlay RNG sequence of a
## second port seeded identically (the RNG itself is covered by test_overlay_rng_retire.gd).

var memory
var port
var init_calls: Array = []

func _init_handler(obj: int) -> void:
	init_calls.append([obj, port.a7])

func _vertex_in(i: int) -> Array:
	var sign: int = 1 if i % 2 == 0 else -1
	return [100 * (i + 1) * sign + 3, -(7 * i + 5), 37 * i - 200]

func _object(count: int) -> void:
	for i in range(0xd6):
		memory.write_u8(CTL + i, 0xa5)
	memory.write_u16(CTL + 0x34, 150)
	memory.write_u8(CTL + 0x33, 0)
	memory.write_u32(OBJ + 8, CTL)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u16(OBJ + 0x34, 1)
	memory.write_u32(OBJ + 0x14, 1000)
	memory.write_u32(OBJ + 0x18, 5000)
	memory.write_u32(OBJ + 0x1c, -6 & 0xffffffff)
	memory.write_u32(OBJ + 0x20, 7)
	for i in range(count):
		var v: Array = _vertex_in(i)
		for c in range(3):
			memory.write_u32(VERTS + 12 * i + 4 * c, v[c] & 0xffffffff)

func _plain(count: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	_object(count)

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

func _finish_ok(name: String) -> bool:
	return Assertions.assert_equal([memory.read_u16(OBJ + 0x34), memory.read_s32(OBJ + 0x14)], [0, 1500], "%s: shift cleared, range * 384 >> 8" % name)

func _halve(v: int) -> int:
	v = v & 0xffffffff
	if v >= 0x80000000:
		v -= 0x100000000
	if v < 0:
		v += 1
	return v >> 1

func run() -> bool:
	var ok := true
	var d: int = DIRTY - 0x100000000

	_plain(6)
	port._jsr(0x1201a, [OBJ])
	ok = Assertions.assert_equal(_verts(6), [[76, -5, -150], [-149, -12, -123], [226, -19, -95], [-299, -26, -68], [376, -33, -39], [-449, -40, -12]], "kind 0: x / z scaled, y untouched") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 7), _longs(CTL + 0x6e, 7)], [[19456, -38144, 57856, -76544, 96256, -114944, d], [-38400, -31488, -24320, -17408, -9984, -3072, d]], "kind 0: six velocity pairs (v asl 9, halved toward zero)") and ok
	ok = _finish_ok("kind 0") and ok

	_plain(4)
	port._jsr(0x120aa, [OBJ])
	ok = Assertions.assert_equal(_verts(4), [[76, -5, -150], [-149, -12, -123], [303, 0, -126], [-299, -26, -68]], "kind 1: vertex 2 left unscaled, its y cleared") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 4), _longs(CTL + 0x6e, 4), memory.read_s32(CTL + 0x76)], [[12970, -25429, 0, -51029], [-25600, -20992, 1920, -11605], 1920], "kind 1: (v asl 9) / 3; vertex 2 gets x velocity 0 (+0x42) and z velocity 5 * 384 (+0x76 = +0x6e + 8)") and ok
	ok = _finish_ok("kind 1") and ok

	## Kind 2 against the formulas, with the RNG values a twin port draws.
	_plain(12)
	var twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	port._jsr(0x11edc, [OBJ])
	var phase: int = twin.overlay_rng_next() & 1
	var want_v := []
	var want_x := []
	var want_y := []
	for i in range(12):
		var v: Array = _vertex_in(i)
		var x: int = ((v[0] >> 1) * 384) >> 8
		var y: int = ((v[1] >> 1) * 384) >> 8
		want_v.append([x, y, v[2]])
		var mask: int = 0x7f if i <= 5 else 0x3f
		var bias: int = 0x3f if i <= 5 else 0x1f
		var vx: int = _halve(((x << 1) - bias + (twin.overlay_rng_next() & mask)) << 8)
		var vy: int = _halve(((y << 1) - bias + (twin.overlay_rng_next() & mask)) << 8)
		if i <= 5 and (i + phase) % 2 == 1:
			vx *= 3
			vy *= 3
		want_x.append(vx)
		want_y.append(vy)
	ok = Assertions.assert_equal(_verts(12), want_v, "kind 2: x / y scaled, z untouched") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 12), _longs(CTL + 0x6e, 12)], [want_x, want_y], "kind 2: jittered velocities, the first six tripled on alternate vertices") and ok
	ok = _finish_ok("kind 2") and ok

	## Kind 3 through the strict spawn chain: the nested spawn_effect(2, 150 / 4, 2, 0, 0, pos)
	## is logged in the effect ring and runs the (stubbed) kind-2 initialiser 0x3c + 0x30 below.
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	port.code_table[INIT] = Callable(self, "_init_handler")
	var fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	for k in range(4):
		fixture.add_template(k, 5)
		memory.write_u32(0x2626e + 4 * k, fixture.template_object(0x22000 + 0x100 * k, k))
		memory.write_u32(0x1b40c + 4 * k, INIT)
	_object(13)
	init_calls.clear()
	port.init_effect_kind3_debris_explosion(OBJ)
	var e := 0x260ee
	ok = Assertions.assert_equal([memory.read_u8(e), memory.read_s16(e + 4), memory.read_s16(e + 6), memory.read_u8(e + 1), memory.read_u8(e + 2), memory.read_s32(e + 8), memory.read_s32(e + 0xc), memory.read_s32(e + 0x10)], [2, 37, 2, 0, 0, 5000, -6, 7], "kind 3: burst spawned (kind 2, size 150 asr 2, 2, 0, 0, position)") and ok
	ok = Assertions.assert_equal([init_calls.size(), init_calls[0][1] if init_calls.size() > 0 else 0], [1, STACK_TOP - 0x3c - 0x30], "kind 3: the burst's initialiser runs below the nested spawn") and ok
	ok = Assertions.assert_equal(_verts(13), [[76, 0, -150], [-149, 0, -123], [226, 0, -95], [-299, 0, -68], [376, 0, -39], [-449, 0, -12], [526, 0, 16], [-599, 0, 43], [676, 0, 72], [-749, 0, 99], [826, 0, 127], [-899, 0, 154], [976, 0, 183]], "kind 3: scaled, y cleared") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 13), _longs(CTL + 0x6e, 13), _longs(CTL + 0xa2, 13)], [[19456, -38144, 57856, -76544, 96256, -114944, 134656, -153344, 173056, -191744, 211456, -230144, 249856], [0, -16, -32, -48, -64, -80, -96, -96, -112, -128, -144, -160, -176], [-38400, -31488, -24320, -17408, -9984, -3072, 4096, 11008, 18432, 25344, 32512, 39424, 46848]], "kind 3: x / 2, (y / 6) << 4, z / 2 velocities") and ok
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x36), memory.read_u8(CTL + 0x33), port.a7], [0x7fff, 0, STACK_TOP], "kind 3: word +0x36 = 0x7fff; live play leaves +0x33") and ok
	ok = _finish_ok("kind 3") and ok

	## While replaying, the nested spawn returns 0 at once and byte +0x33 |= 1.
	_object(13)
	memory.write_u16(0x1b870, 1)
	init_calls.clear()
	port.init_effect_kind3_debris_explosion(OBJ)
	ok = Assertions.assert_equal([init_calls.size(), memory.read_u8(CTL + 0x33)], [0, 1], "kind 3 replaying: no burst, +0x33 |= 1") and ok
	return ok
