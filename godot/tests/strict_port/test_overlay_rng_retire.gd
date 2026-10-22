extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000

## Expected values from instruction-level models of 0x114ca, 0x1150a and 0x11564 (unsigned
## bhi wraps at 0x260e8, adda.w #$ff24, add.l, lsr.l #16), independent of the C, of this
## port and of the prototype RNG.
const SEEDS := [
	[0, [42625, 59345, 6542, 14398, 22236, 30360], 0xeacfdd38],
	[12345, [4793, 168, 62024, 3141, 49731, 38474], 0xd0909f88],
]

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var port = PacificConflictScript.new(memory)

	ok = Assertions.assert_equal(PacificConflictScript.overlay_rng_mul_mix(0x1df5e0d, 0x12345678) & 0xffffffff, 0xeef07418, "mul_mix low 32 bits") and ok
	ok = Assertions.assert_equal(PacificConflictScript.overlay_rng_mul_mix(0xffffffff, 0xffffffff), 1, "mul_mix (-1) * (-1)") and ok
	for case in SEEDS:
		port.overlay_rng_init(case[0])
		ok = Assertions.assert_equal(memory.read_u32(0x26010), case[2], "seed %d: ring long 1" % case[0]) and ok
		var outs := []
		for n in range(6):
			outs.append(port.overlay_rng_next())
		ok = Assertions.assert_equal(outs, case[1], "seed %d: outputs after warm-up" % case[0]) and ok
		ok = Assertions.assert_equal(memory.read_u32(0x26008), 0x260d4, "seed %d: cursor" % case[0]) and ok

	## retire_entity
	var obj := 0x21000
	var ctl := 0x21100
	var root := 0x21200
	var table := 0x21300
	memory.write_u32(0x1d6fc, root)
	memory.write_u32(root + 0x30, table)
	memory.write_u32(obj + 8, ctl)
	memory.write_u32(ctl, obj)
	memory.write_u32(0x1b880, ctl)
	memory.write_u8(obj + 1, 5)
	memory.write_u8(obj + 2, 3)
	memory.write_u32(table + 0x14 + 3 * 0x18, 0x77777777)
	memory.write_u16(0x1b88e, 4)
	memory.write_u16(0x1b88c, 6)
	memory.write_u32(0x1bc64 + 2 * 4, obj)
	memory.write_u32(0x1bc64 + 6 * 4, obj)
	memory.write_u32(0x1bc64 + 5 * 4, 0x12345)
	memory.write_u32(obj + 4, 0x10)
	memory.write_u32(obj + 0x3c, 99)
	memory.write_u32(0x24cf0, 7)
	port.retire_entity(obj)
	ok = Assertions.assert_equal(memory.read_u32(0x1b880), 0, "player_shot_ctl cleared") and ok
	ok = Assertions.assert_equal(memory.read_u32(table + 0x14 + 3 * 0x18), 0, "child table entry of index byte +2 cleared") and ok
	ok = Assertions.assert_equal([memory.read_u32(0x1bc64 + 8), memory.read_u32(0x1bc64 + 24), memory.read_u32(0x1bc64 + 20)], [0, 0, 0x12345], "scatter slots scrubbed") and ok
	ok = Assertions.assert_equal(memory.read_s32(obj + 0x18), 1000000000, "x parked") and ok
	ok = Assertions.assert_equal(memory.read_u32(obj + 4), 0x12, "long +4 |= 2") and ok
	ok = Assertions.assert_equal(memory.read_u32(obj + 0x3c), 0, "+0x3c cleared") and ok
	ok = Assertions.assert_equal(memory.read_u32(ctl), 0, "*controller cleared") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x24cf0), 8, "retire_count + 1") and ok

	## Byte +1 outside the window: slots kept; equal bytes: no table write.
	memory.write_u8(obj + 1, 9)
	memory.write_u32(0x1bc64, obj)
	port.retire_entity(obj)
	ok = Assertions.assert_equal(memory.read_u32(0x1bc64), obj, "outside the window the slots stay") and ok
	memory.write_u8(obj + 1, 3)
	memory.write_u32(table + 0x14 + 3 * 0x18, 0x55)
	port.retire_entity(obj)
	ok = Assertions.assert_equal(memory.read_u32(table + 0x14 + 3 * 0x18), 0x55, "equal bytes leave the table") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x24cf0), 10, "retire_count counts every call") and ok
	return ok
