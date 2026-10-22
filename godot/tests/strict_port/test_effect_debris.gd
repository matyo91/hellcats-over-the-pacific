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
const FACES := 0x21600
const OWNERS := 0x21800
const SMOKE := 0x22800
const MARK := 0x22a00

## Kind 2 (0x12296) and kind 3 (0x12528) effect animators. Movement expectations come from an
## instruction-level Python model of their loops, independent of this port: velocities x =
## 1000 (i + 1) (-1)^i, y = -777 i + 3, z = 513 (-1)^i - i; vertex i = (10 i, 40 i - 200,
## -20 i). The spawn paths run through the strict pool chain: template 1 is the smoke
## template, template 2 (six vertex vectors) the ground mark.

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
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40 * 2
	memory.write_u16(desc + 0x1a, 6)
	memory.write_u32(0x260e8, fixture.template_object(SMOKE, 1))
	memory.write_u32(0x26660, fixture.template_object(MARK, 2))
	memory.write_u32(0x1b838, 1000)
	memory.write_u32(CTL, OBJ)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u32(OBJ + 0x48, FACES)
	memory.write_u32(OBJ + 0x18, 400)
	memory.write_u32(OBJ + 0x1c, 0)
	memory.write_u32(OBJ + 0x20, -900 & 0xffffffff)
	memory.write_u16(CTL + 0x34, 10)
	memory.write_u16(CTL + 0x36, 5)
	for i in range(12):
		var sign: int = 1 if i % 2 == 0 else -1
		memory.write_u32(CTL + 0x3a + 4 * i, (1000 * (i + 1) * sign) & 0xffffffff)
		memory.write_u32(CTL + 0x6e + 4 * i, (-777 * i + 3) & 0xffffffff)
		memory.write_u32(CTL + 0xa2 + 4 * i, (513 * sign - i) & 0xffffffff)
	for i in range(13):
		for c in range(3):
			memory.write_u32(VERTS + 12 * i + 4 * c, [10 * i, 40 * i - 200, -20 * i][c] & 0xffffffff)
	## Two faces: face 0 owns palette slot 3, face 1 claims slot 4 but does not own it.
	memory.write_u16(OBJ + 0x3a, 2)
	memory.write_u32(0x1da7c, OWNERS)
	memory.write_u32(OWNERS + 3 * 4, FACES)
	for f in range(2):
		memory.write_u8(FACES + 0x20 * f + 0xc, 200)
		memory.write_u8(FACES + 0x20 * f + 0xd, 81)
		memory.write_u8(FACES + 0x20 * f + 0xe, 7)
		memory.write_u8(FACES + 0x20 * f + 0xf, 3 + f)

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

func _face(f: int) -> Array:
	var b: int = FACES + 0x20 * f
	return [memory.read_u8(b + 0xc), memory.read_u8(b + 0xd), memory.read_u8(b + 0xe), memory.read_u8(b + 0xf)]

func _spawned(template: int) -> int:
	for o in fixture.activated():
		if memory.read_u8(o + 1) == template:
			return o
	return 0

func run() -> bool:
	var ok := true

	## Kind 2, through code_table: x / y move, velocities halve; view depth 8 darkens by 6/8.
	_setup()
	memory.write_u16(0x1b826, 8)
	ok = Assertions.assert_equal(port._jsr(0x12276, [CTL]), 0, "kind 2: running") and ok
	ok = Assertions.assert_equal(_verts(12), [[3, -200, 0], [2, -164, -20], [31, -127, -40], [14, -90, -60], [59, -53, -80], [26, -16, -100], [87, 21, -120], [38, 58, -140], [115, 95, -160], [50, 132, -180], [142, 169, -200], [63, 206, -220]], "kind 2: x / y moved, z untouched") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 12), _longs(CTL + 0x6e, 12)], [[500, -1000, 1500, -2000, 2500, -3000, 3500, -4000, 4500, -5000, 5500, -6000], [1, -387, -775, -1164, -1552, -1941, -2329, -2718, -3106, -3495, -3883, -4272]], "kind 2: velocities halved toward zero") and ok
	ok = Assertions.assert_equal([_face(0), _face(1)], [[150, 60, 5, 3], [150, 60, 5, 0]], "kind 2: colours * 6 >> 3; the owner keeps its slot, the other loses it") and ok
	## Lifetime 0 with smoke byte: smoke (30, 60, 0x2a3, 1) spawned, finished.
	_setup()
	memory.write_u16(CTL + 0x36, 0)
	memory.write_u8(CTL + 0x38, 1)
	ok = Assertions.assert_equal(port.animate_effect_kind2_burst(CTL), 1, "kind 2 at lifetime 0: finished") and ok
	var smoke: int = memory.read_u32(_spawned(1) + 8)
	ok = Assertions.assert_equal([memory.read_u16(smoke + 0x36), memory.read_u16(smoke + 0x34), memory.read_u16(smoke + 0x32), memory.read_u32(smoke + 0x38), port.a7], [30, 60, 1, 1000 + 0x2a3, STACK_TOP], "kind 2: smoke plume size * 3 / * 6") and ok

	## Kind 3, live, landed everywhere: moved, clamped, 3/4 decay; then the ground mark (object
	## at y 0) and smoke: vertex 1 z = -23 -> s = word(0xffe9 + (-11)) = -34, s / 2 = -17.
	_setup()
	memory.write_u8(CTL + 0x38, 1)
	memory.write_u32(OBJ + 4, 0x40)
	ok = Assertions.assert_equal(port._jsr(0x12508, [CTL]), 1, "kind 3: landed -> finished") and ok
	ok = Assertions.assert_equal(_verts(13), [[3, 0, 2], [2, 0, -23], [31, 0, -39], [14, 0, -63], [59, 0, -79], [26, 0, -103], [87, 0, -119], [38, 0, -143], [115, 0, -159], [50, 0, -183], [142, 0, -199], [63, 0, -223], [120, 0, -240]], "kind 3: y clamped at 0; vertex 12 y = vertex 2 y * 3 / 2") and ok
	ok = Assertions.assert_equal([_longs(CTL + 0x3a, 12), _longs(CTL + 0x6e, 12), _longs(CTL + 0xa2, 12)], [[750, -1500, 2250, -3000, 3750, -4500, 5250, -6000, 6750, -7500, 8250, -9000], [-88, -865, -1642, -2419, -3196, -3973, -4750, -5527, -6304, -7081, -7858, -8635], [384, -385, 383, -387, 381, -388, 380, -390, 378, -391, 377, -393]], "kind 3: gravity on y, x / z decay to 3/4") and ok
	ok = Assertions.assert_equal(memory.read_u32(OBJ + 4), 0, "kind 3 live: shown again") and ok
	var mark: int = _spawned(2)
	smoke = memory.read_u32(_spawned(1) + 8)
	ok = Assertions.assert_equal([mark != 0, memory.read_u32(mark + 0x3c), memory.read_u16(smoke + 0x36), memory.read_u16(smoke + 0x34), memory.read_u32(smoke + 0x38), port.a7], [true, 1000 + 0xa8c, 0xffef, 0xffde, 1000 + 0x2a3, STACK_TOP], "kind 3: ground mark and smoke (-17, -34)") and ok
	## Airborne: vertex 2 starts at y 1000 -> 1000 + ((-777 * 2 + 3 - 0x5b) asr 4) = 897, vertex
	## 12 y = 448 + 897 = 1345; still flying -> 0, nothing spawned.
	_setup()
	memory.write_u32(VERTS + 0x1c, 1000)
	memory.write_u32(OBJ + 0x1c, 0)
	ok = Assertions.assert_equal([port.animate_effect_kind3_debris(CTL), memory.read_s32(VERTS + 0x1c), memory.read_s32(VERTS + 0x94), fixture.activated().size()], [0, 897, 1345, 0], "kind 3: airborne -> running, no spawn") and ok
	## Live debris during a replay: hidden and idle, nothing moved.
	_setup()
	memory.write_u16(0x1b870, 2)
	ok = Assertions.assert_equal([port.animate_effect_kind3_debris(CTL), memory.read_u32(OBJ + 4), memory.read_s32(VERTS)], [0, 0x40, 0], "kind 3 live while replaying: hidden, idle") and ok
	## Replay debris (+0x33 bit 0): rewind -> finished; landed in replay 3 -> 0, else 1, no spawns.
	_setup()
	memory.write_u8(CTL + 0x33, 1)
	memory.write_u16(0x1b870, 1)
	ok = Assertions.assert_equal(port.animate_effect_kind3_debris(CTL), 1, "replay debris on rewind: finished") and ok
	_setup()
	memory.write_u8(CTL + 0x33, 1)
	memory.write_u8(CTL + 0x38, 1)
	memory.write_u16(0x1b870, 3)
	ok = Assertions.assert_equal([port.animate_effect_kind3_debris(CTL), fixture.activated().size()], [0, 0], "replay debris landed in state 3: 0") and ok
	memory.write_u16(0x1b870, 2)
	ok = Assertions.assert_equal([port.animate_effect_kind3_debris(CTL), fixture.activated().size()], [1, 0], "replay debris landed otherwise: finished, no spawn") and ok
	return ok
