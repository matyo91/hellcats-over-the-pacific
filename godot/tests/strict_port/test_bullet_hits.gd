extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BULLET := 0x21000
const BULLET_CTL := 0x21100
const TARGET := 0x21200
const TARGET_CTL := 0x21300
const TEMPLATE := 0x21400

## Bullet at (1000, 0, 0), velocity (101, -3, 0); target at (1010, 0, 30): segment distance 31.
## RNG seeded with 777: outputs 57333, 43628, 32283, 7414, 52649, 37177, 42248, 38011, ...
## Expected D0 values and stores from instruction-level models of 0x1665a, 0x16724, 0x167f4
## (with the earlier models of 0x3cca, 0x11564, 0x51ec), independent of the C and of this port.

var memory
var port

func _setup(range_word: int, flags6: int, with_ctl: bool, b_type: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.overlay_rng_init(777)
	memory.write_u32(BULLET + 8, BULLET_CTL)
	memory.write_u32(BULLET + 0x18, 1000)
	memory.write_u32(BULLET_CTL + 8, 101)
	memory.write_u32(BULLET_CTL + 0xc, -3 & 0xffffffff)
	memory.write_u16(BULLET_CTL + 0x36, 1)
	memory.write_u32(TARGET + 0x18, 1010)
	memory.write_u32(TARGET + 0x20, 30)
	memory.write_u32(TARGET + 0x14, range_word)
	memory.write_u8(TARGET + 6, flags6)
	if with_ctl:
		memory.write_u32(TARGET + 8, TARGET_CTL)
		memory.write_u32(TARGET_CTL + 4, TEMPLATE)
		memory.write_u16(TEMPLATE, b_type)
	memory.write_u32(0x1d6fc, 0x22000)
	memory.write_u32(0x22000 + 0x30, 0x22100)

func run() -> bool:
	var ok := true

	_setup(20, 0, true, 2)
	ok = Assertions.assert_equal(port.bullet_hits_shape(BULLET, TARGET), 31, "shape out of range returns the distance") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000, "no retire on a miss") and ok

	_setup(50, 4, true, 2)
	ok = Assertions.assert_equal(port.bullet_hits_shape(BULLET, TARGET), 5, "flag 4: rng & 7") and ok
	ok = Assertions.assert_equal(memory.read_u32(BULLET_CTL + 0x3c), 0, "no latch when rng & 7 != 0") and ok

	_setup(50, 0, true, 0xe)
	ok = Assertions.assert_equal(port.bullet_hits_shape(BULLET, TARGET), 0xe, "type 0xe target ignored") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000, "type 0xe: bullet kept") and ok

	_setup(50, 0, true, 0x1b)
	ok = Assertions.assert_equal(port.bullet_hits_shape(BULLET, TARGET), 5, "type 0x1b: retire with D0 = rng & 0xf") and ok
	ok = Assertions.assert_equal(memory.read_u16(TARGET_CTL + 0x46), 0, "type 0x1b: +0x46 only on rng & 0xf == 0") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000000000, "type 0x1b: bullet retired") and ok

	_setup(50, 0, false, 0)
	ok = Assertions.assert_equal(port.bullet_hits_shape(BULLET, TARGET), 31, "no controller: retire keeps D0 = distance") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000000000, "no controller: bullet retired") and ok

	## Aircraft: the target controller is the player's; template kind 2; damage word 0x0202.
	_setup(50, 0, true, 2)
	memory.write_u32(0x1b738, TARGET_CTL)
	memory.write_u16(TARGET_CTL + 0x684, 0x0202)
	memory.write_u16(TARGET_CTL + 0x688, 9)
	ok = Assertions.assert_equal(port.bullet_hits_aircraft(BULLET, TARGET), 43628, "aircraft: rng & 7 = 5, player, even roll") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x1b842), 0, "even roll: no hit sound") and ok
	ok = Assertions.assert_equal(port.bullet_hits_aircraft(BULLET, TARGET), 7414, "aircraft: rng & 7 = 3, even roll") and ok
	ok = Assertions.assert_equal(port.bullet_hits_aircraft(BULLET, TARGET), 37177, "aircraft: odd roll") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x1b842), 1, "odd roll: hit sound") and ok
	ok = Assertions.assert_equal(port.bullet_hits_aircraft(BULLET, TARGET), 0x200, "aircraft: rng & 7 = 0 -> damage, retire") and ok
	ok = Assertions.assert_equal(memory.read_u16(TARGET_CTL + 0x684), 0x8102, "damage roll 123: bit 9 -> bit 8, bit 15 (by player)") and ok
	ok = Assertions.assert_equal(memory.read_u16(TARGET_CTL + 0x688), 0, "damage roll 123: +0x688 cleared") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000000000, "damaging bullet retired") and ok

	## apply_random_aircraft_damage alone: kind 1 sets snd_hit and escapes on rng & 3 != 0.
	_setup(50, 0, true, 1)
	ok = Assertions.assert_equal(port.apply_random_aircraft_damage(TARGET_CTL, 0), 1, "kind 1: rng & 3 = 1 escapes") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x1b842), 1, "kind 1: snd_hit") and ok
	ok = Assertions.assert_equal(port.apply_random_aircraft_damage(TARGET_CTL, 0), 0x1b, "kind 1: rng & 3 = 0 -> roll 27") and ok
	ok = Assertions.assert_equal(memory.read_u16(TARGET_CTL + 0x684), 2, "roll 27 sets bit 1") and ok
	return ok
