extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const CTL := 0x21000
const BULLET := 0x21100
const HIT := 0x21200
const WORLD := 0x23000

## Expected values follow the disassembly of 0x15dc8..0x15e60: +7 / +3 bias then asr #3 / #2
## for the effect size, addq.w #1 then cmpi.w #$1f, gravity moveq #$a5 (-0x5b) after frame 3,
## asr.l #6 into +0xc, retirement when y <= ground (bgt keeps the bullet). spawn_effect and
## surface_type_under_object are unported and supplied as recorders.

var effects: Array = []
var memory
var port

func _spawn_effect(kind: int, size: int, lifetime: int, byte_38: int, debris: int, x: int, y: int, z: int) -> int:
	effects.append([kind, size])
	return 0

func _surface(_obj: int) -> int:
	return 0x20

func _setup(counter: int, speed: int, y: int, ground: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.code_table[0x11c38] = Callable(self, "_spawn_effect")
	port.code_table[0x13432] = Callable(self, "_surface")
	effects.clear()
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(0x1d6fc, 0x24000)
	memory.write_u32(CTL, BULLET)
	memory.write_u16(CTL + 0x38, counter)
	memory.write_u32(CTL + 0x32, speed & 0xffffffff)
	memory.write_u32(CTL + 0x2e, ground & 0xffffffff)
	memory.write_u32(BULLET + 0x1c, y & 0xffffffff)
	memory.write_u32(BULLET + 0x18, 777)

func run() -> bool:
	var ok := true

	_setup(0, 640, 500, 0)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x38), memory.read_s32(CTL + 0x32), memory.read_s32(CTL + 0xc)], [1, 640, 10], "frame 1: no gravity, +0xc = speed asr 6") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 777, "above ground: kept") and ok

	_setup(3, 640, 500, 0)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal([memory.read_s32(CTL + 0x32), memory.read_s32(CTL + 0xc)], [549, 8], "frame 4: gravity -0x5b") and ok

	_setup(5, -100, 500, 0)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal(memory.read_s32(CTL + 0xc), -3, "negative speed: asr floors (-191 asr 6)") and ok

	_setup(0x1e, 640, 500, 0)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000000000, "frame 0x1f: retired") and ok
	ok = Assertions.assert_equal(memory.read_s32(CTL + 0xc), 0, "frame 0x1f: +0xc not updated") and ok

	_setup(1, 640, 100, 100)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000000000, "y <= ground: retired") and ok

	## Hit: range -100 -> (-100 + 7) asr 3 = -12; player bullet tallies type 2; the hit shape
	## (outside the scene root's window) is stamped; the bullet is retired.
	_setup(0, 640, 500, 0)
	memory.write_u32(CTL + 0x3c, HIT)
	memory.write_u16(CTL + 0x36, 1)
	memory.write_u32(HIT + 0x14, -100 & 0xffffffff)
	memory.write_u8(HIT, 2)
	memory.write_u16(HIT + 0x50, 2)
	memory.write_u32(0x1b838, 55)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal(effects, [[3, -9]], "effect: size -12, explosion at 3 * -12 / 4 = -9") and ok
	ok = Assertions.assert_equal(memory.read_u16(WORLD + 0xb8 + 4), 1, "kill tallied for type 2") and ok
	ok = Assertions.assert_equal([memory.read_u32(HIT + 4), memory.read_u32(HIT + 0x3c)], [0x42, 55], "hit shape stamped") and ok
	ok = Assertions.assert_equal(memory.read_s32(BULLET + 0x18), 1000000000, "hitting bullet retired") and ok

	## Raised hit object (+0x1c set): range / 4.
	_setup(0, 640, 500, 0)
	memory.write_u32(CTL + 0x3c, HIT)
	memory.write_u32(HIT + 0x14, 100)
	memory.write_u32(HIT + 0x1c, 1)
	memory.write_u8(HIT, 2)
	port.tick_bullet(CTL)
	ok = Assertions.assert_equal(effects, [[3, 18]], "raised: size 25, explosion 3 * 25 / 4 = 18") and ok
	ok = Assertions.assert_equal(memory.read_u16(WORLD + 0xb8 + 4), 0, "no tally without player credit") and ok
	return ok
