extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const CTL := 0x21000
const BULLET := 0x21100
const HIT := 0x21200
const WORLD := 0x23000

## Expected values follow the disassembly of 0x15dc8..0x15e60: +7 / +3 bias then asr #3 / #2
## for the effect size, addq.w #1 then cmpi.w #$1f, gravity moveq #$a5 (-0x5b) after frame 3,
## asr.l #6 into +0xc, retirement when y <= ground (bgt keeps the bullet). spawn_effect is
## ported (its log is read back; the pool object it spawns has no vertices and is retired, see `fixture`); the surface comes from the ported
## surface_type_under_object (no active objects -> default ground face code 0x20).

var memory
var port


## Effects as logged by the ported spawn_effect (live play: replay_state 0).
func _logged_effects() -> Array:
	var out := []
	for n in range(memory.read_u16(0x260ec)):
		var e := 0x260ee + 0x18 * n
		out.append([memory.read_u8(e), memory.read_s16(e + 4), memory.read_s16(e + 6), memory.read_u8(e + 1), memory.read_u8(e + 2),
				memory.read_s32(e + 8), memory.read_s32(e + 0xc), memory.read_s32(e + 0x10)])
	return out

## The spawned pool object goes through the strict spawn_mission_pool_object /
## instantiate_mission_pool_slot chain on PoolFixture's scene; its template is far (make_far), so
## it is deferred without vertices, the spawn retires it and spawn_effect returns 0 after logging.
var fixture

func _setup(counter: int, speed: int, y: int, ground: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = 0x2f000
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	fixture.add_template(0, 0)
	fixture.make_far(0)
	memory.write_u32(0x1bda8, 0x2a000)
	memory.write_u8(0x2a016, 0x20)
	memory.write_u32(0x1b5a0, WORLD)
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
	ok = Assertions.assert_equal(_logged_effects().map(func(e): return e.slice(0, 2)), [[3, -9]], "effect: size -12, explosion at 3 * -12 / 4 = -9") and ok
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
	ok = Assertions.assert_equal(_logged_effects().map(func(e): return e.slice(0, 2)), [[3, 18]], "raised: size 25, explosion 3 * 25 / 4 = 18") and ok
	ok = Assertions.assert_equal(memory.read_u16(WORLD + 0xb8 + 4), 0, "no tally without player credit") and ok
	return ok
