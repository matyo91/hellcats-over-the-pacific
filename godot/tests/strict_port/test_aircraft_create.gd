extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const AIRCRAFT_DEFS := 0x2ca00 ## definition records for keys 1..4 (0x50 apart)
const TURRET_TEMPLATE := 0x22600

## Expected values follow the disassembly of 0xdff0 (init_aircraft_controller), 0xe0ce /
## 0xe1e6 / 0xe2a4 / 0xe340 (the creators), 0x18956 (spawn_object_shadow) and 0x19130
## (spawn_turret_on_object). Each creator is reached through code_table at its runtime
## address, as definition record +6 stores it. Definitions: word +0x1a = 310, +0x1c = 46 (fuel,
## 23 per tank), +0x40 = 50, +0x42 = 277. Shadow templates 1 / 2 / 4 and the turret template
## spawn through the strict pool chain with PoolFixture's factory controllers.

var memory
var port
var fixture

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	for k in [1, 2, 4]:
		fixture.add_template(k, 5)
		memory.write_u32(0x26768 + 4 * k, fixture.template_object(0x22000 + 0x100 * k, k))
	fixture.add_template(5, 5)
	memory.write_u32(0x2677c, fixture.template_object(TURRET_TEMPLATE, 5))
	for k in range(1, 5):
		var d := AIRCRAFT_DEFS + 0x50 * k
		memory.write_u32(0x1b524 + 4 * k, d)
		memory.write_u16(d + 0x1a, 310)
		memory.write_u16(d + 0x1c, 46)
		memory.write_u16(d + 0x40, 50)
		memory.write_u16(d + 0x42, 277)
	var host := PoolFixtureScript.WORLD
	memory.write_u16(host + 0xb9 - 1, 0)
	memory.write_u8(host + 0xb9, 3)
	memory.write_u16(host + 0xb6, 50)
	memory.write_u16(host + 0xb0, 0)
	_aircraft()

func _aircraft(obj: int = OBJ) -> void:
	for i in range(0x40):
		memory.write_u8(obj + i, 0)
	memory.write_u32(obj + 0x18, 1000)
	memory.write_u32(obj + 0x1c, 300)
	memory.write_u32(obj + 0x20, -2000 & 0xffffffff)

## The shadow is the activated shape whose template index (byte +1) is `kind`.
func _shape(index: int) -> int:
	for o in fixture.activated():
		if memory.read_u8(o + 1) == index:
			return o
	return 0

func run() -> bool:
	var ok := true

	## The first aircraft becomes the player: bombs from host byte +0xb9 (3), +0x634 = 310 + 2 *
	## 16 - 32 + 3 * 16 = 358, tanks 23 * 50 / 100 = 11.
	_setup()
	var ctl: int = port._jsr(0xe0ae, [OBJ, 1, 0x10003])
	ok = Assertions.assert_equal([memory.read_u32(0x1b738), memory.read_u32(ctl), memory.read_u32(ctl + 4), memory.read_u16(ctl + 0x614)], [ctl, OBJ, AIRCRAFT_DEFS + 0x50, 3], "player: player_object, object, definition, kind (low word)") and ok
	ok = Assertions.assert_equal([memory.read_u8(ctl + 0x67c), memory.read_u16(ctl + 0x634), memory.read_u8(ctl + 0x67d), memory.read_u8(ctl + 0x67e)], [3, 358, 11, 11], "player: bombs, weight word, fuel percent") and ok
	ok = Assertions.assert_equal([memory.read_u16(ctl + 0x682), memory.read_u16(ctl + 0x626), memory.read_u16(ctl + 0x630), memory.read_u8(ctl + 0x679), memory.read_u8(ctl + 0x63e), memory.read_s32(ctl + 0x2e)], [0x2a3, 277, 0xffa5, 0x2d, 1, 250], "init fields; +0x2e = y - definition +0x40") and ok
	ok = Assertions.assert_equal([memory.read_u32(ctl + 0x32), memory.read_u16(ctl + 0x684), memory.read_u32(OBJ + 4), memory.read_u32(OBJ + 0xc)], [0xe772, 0x4000, 0x122140, 1000000000], "player handler, flags (byte +5 bit 1 from init)") and ok
	ok = Assertions.assert_equal([memory.read_s32(ctl + 0x36), memory.read_s32(ctl + 0x3a), memory.read_s32(ctl + 0x3e), memory.read_s32(ctl + 0x36 + 0x4a * 0x14 + 8)], [1000, 300, -2000, -2000], "pose ring at +0x36") and ok
	var shadow: int = _shape(1)
	ok = Assertions.assert_equal([shadow != 0, memory.read_u32(shadow + 0xc), memory.read_u32(shadow + 4) & 0x40, memory.read_u32(memory.read_u32(shadow + 8) + 0x32), memory.read_u8(OBJ + 3), port.a7], [true, 1000000000, 0x40, OBJ, 1, STACK_TOP], "player shadow (kind 1): far metric, hidden (host +0xb0 = 0), owner linked") and ok

	## A second aircraft (another object) is AI; host +0xb0 != 0 shows its shadow, and its
	## owner is not *player_object, so +0xc stays as the pool set it.
	var other := 0x21800
	_aircraft(other)
	memory.write_u16(PoolFixtureScript.WORLD + 0xb0, 1)
	var ai: int = port._jsr(0xe0ae, [other, 1, 0])
	shadow = 0
	for o in fixture.activated():
		if memory.read_u32(memory.read_u32(o + 8) + 0x32) == other:
			shadow = o
	ok = Assertions.assert_equal([memory.read_u32(0x1b738), memory.read_u32(ai + 0x32), memory.read_u32(other + 4), memory.read_u8(ai + 0x67c), memory.read_u8(ai + 0x67d), memory.read_u16(ai + 0x634)], [ctl, 0x110d4, 0x122100, 2, 23, 342], "AI aircraft: unchanged defaults") and ok
	ok = Assertions.assert_equal([shadow != 0, memory.read_u8(shadow + 1), memory.read_u32(shadow + 4) & 0x40, memory.read_u32(shadow + 0xc) == 1000000000, memory.read_u8(other + 3)], [true, 1, 0, false, 1], "AI shadow (kind 1) shown, not the player's") and ok

	## Host mode +0x90 == 2: six bombs, weight word not adjusted; 0 % fuel -> left tank 1.
	_setup()
	memory.write_u16(PoolFixtureScript.WORLD + 0x90, 2)
	memory.write_u16(PoolFixtureScript.WORLD + 0xb6, 0)
	ctl = port._jsr(0xe0ae, [OBJ, 1, 0])
	ok = Assertions.assert_equal([memory.read_u8(ctl + 0x67c), memory.read_u16(ctl + 0x634), memory.read_u8(ctl + 0x67d), memory.read_u8(ctl + 0x67e)], [6, 342, 1, 0], "mode 2 player: 6 bombs, empty tanks -> left 1") and ok

	## Enemy fighter: the first key-4 object is kept as the template (0, no controller).
	_setup()
	ok = Assertions.assert_equal([port._jsr(0xe1c6, [OBJ, 4, 0]), memory.read_u32(0x26000), fixture.activated().size()], [0, OBJ, 0], "first fighter: template only") and ok
	ctl = port._jsr(0xe1c6, [OBJ, 4, 7])
	ok = Assertions.assert_equal([memory.read_u32(ctl + 0x32), memory.read_u16(ctl + 0x614), memory.read_u32(OBJ + 4), _shape(2) != 0, memory.read_u8(OBJ + 3), port.a7], [0x110d4, 7, 0x122100, true, 1, STACK_TOP], "fighter: AI handler, shadow kind 2") and ok

	## Friendly bomber: gunner turret (template 5) configured and recorded.
	_setup()
	ctl = port._jsr(0xe284, [OBJ, 2, 0])
	var turret_obj: int = _shape(5)
	var turret: int = memory.read_u32(turret_obj + 8)
	ok = Assertions.assert_equal([memory.read_u32(ctl + 0x32), memory.read_u16(ctl + 0x682), memory.read_u8(ctl + 0x67c), memory.read_u16(ctl + 0x634), memory.read_u32(OBJ + 4)], [0x1118e, 0, 8, 342, 0x122100], "bomber: handler, no ammo, 8 bombs (weight not adjusted)") and ok
	ok = Assertions.assert_equal([memory.read_u32(ctl + 0x692), memory.read_u16(turret + 0x40), memory.read_u16(turret + 0x3e), memory.read_u32(turret + 0x42), memory.read_u8(turret_obj + 5) & 1, memory.read_u32(turret + 0x32), memory.read_u8(OBJ + 3)], [turret_obj, 1, 0x200, 25000, 1, OBJ, 2], "bomber turret: recorded, configured, linked (owner count 2)") and ok
	ok = Assertions.assert_equal([_shape(4) != 0, port.a7], [true, STACK_TOP], "bomber shadow kind 4") and ok

	## Enemy bomber: the same, then the turret's +0x3e = 0x100.
	_setup()
	ctl = port._jsr(0xe320, [OBJ, 3, 0])
	turret = memory.read_u32(_shape(5) + 8)
	ok = Assertions.assert_equal([memory.read_u32(ctl + 0x32), memory.read_u16(turret + 0x3e), memory.read_u16(turret + 0x40)], [0x1118e, 0x100, 1], "enemy bomber: turret +0x3e = 0x100") and ok
	return ok
