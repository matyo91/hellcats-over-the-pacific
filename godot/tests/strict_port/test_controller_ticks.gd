extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const CTL := 0x21200
const OWNER := 0x21400
const OWNER_CTL := 0x21600

## Expected values follow the disassembly of 0x175c0 (tick_ground_mark), 0x19bbc
## (tick_view_attached_object), 0x189d0 (tick_shadow), 0x174c4 (tick_debris_fragment) and
## 0x116fc (tick_smoke_plume). Each handler is reached through code_table at its runtime address
## (definition record +2). A retired object (retire_entity, object bytes +1 == +2) gets x =
## 1000000000 and long +4 |= 2, and its controller's +0 is cleared.

var memory
var port

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	memory.write_u32(0x1b838, 500)
	memory.write_u32(CTL, OBJ)
	memory.write_u32(OBJ + 8, CTL)
	memory.write_u32(OBJ + 0x18, 100)
	memory.write_u32(OBJ + 0x1c, 200)
	memory.write_u32(OBJ + 0x20, 300)
	memory.write_u32(OWNER + 8, OWNER_CTL)
	memory.write_u32(OWNER_CTL, OWNER)
	memory.write_u32(OWNER + 0x18, 7000)
	memory.write_u32(OWNER + 0x1c, 800)
	memory.write_u32(OWNER + 0x20, -9000 & 0xffffffff)

func _retired(obj: int) -> bool:
	return memory.read_u32(obj + 0x18) == 1000000000 and (memory.read_u32(obj + 4) & 2) != 0

func run() -> bool:
	var ok := true

	## Ground mark: kept before its expiry frame, retired at it.
	_setup()
	memory.write_u32(OBJ + 0x3c, 501)
	port._jsr(0x175a0, [CTL])
	ok = Assertions.assert_equal(_retired(OBJ), false, "ground mark kept before expiry") and ok
	memory.write_u32(OBJ + 0x3c, 500)
	port._jsr(0x175a0, [CTL])
	ok = Assertions.assert_equal([_retired(OBJ), memory.read_u32(CTL), port.a7], [true, 0, STACK_TOP], "ground mark retired at expiry") and ok

	## View-attached: camera (5000, 6000, 7000), heading word 0x0100, pitch word 0xc000.
	_setup()
	memory.write_u32(0x1d838, 5000)
	memory.write_u32(0x1d834, 6000)
	memory.write_u32(0x1d830, 7000)
	memory.write_u16(0x1d80e, 0x0100)
	memory.write_u16(0x1d810, 0xc000)
	port._jsr(0x19b9c, [CTL])
	ok = Assertions.assert_equal([memory.read_s32(CTL + 8), memory.read_s32(CTL + 0xc), memory.read_s32(CTL + 0x10), memory.read_u16(CTL + 0x22), memory.read_u16(CTL + 0x20)], [5000 - (100 + 0xdff), 6000 - (200 - 0x133e), 7000 - (300 + 0x161d), 0x3f00, 0x0000], "view-attached offsets and negated angles") and ok

	## Shadow follows its live owner.
	_setup()
	memory.write_u32(CTL + 0x32, OWNER)
	memory.write_u32(OWNER_CTL + 8, 11)
	memory.write_u32(OWNER_CTL + 0x10, -13 & 0xffffffff)
	memory.write_u32(OWNER_CTL + 0x2e, 42)
	memory.write_u16(OWNER_CTL + 0x22, 0x1234)
	memory.write_u8(OWNER + 7, 2) ## retired flag, but its controller still points at it
	port._jsr(0x189b0, [CTL])
	ok = Assertions.assert_equal([memory.read_s32(OBJ + 0x18), memory.read_s32(OBJ + 0x1c), memory.read_s32(OBJ + 0x20), memory.read_u16(CTL + 0x22), _retired(OBJ)], [7011, 42, -9013, 0x1234, false], "shadow placed under the owner") and ok
	## Owner retired and released: the shadow goes too.
	memory.write_u32(OWNER_CTL, 0)
	memory.write_u8(OWNER + 3, 2)
	port._jsr(0x189b0, [CTL])
	ok = Assertions.assert_equal([_retired(OBJ), memory.read_u8(OWNER + 3), memory.read_u32(CTL + 0x32), port.a7], [true, 1, 0, STACK_TOP], "shadow retired with its owner") and ok

	## Debris fragment: spins wrap at 0x4000, falls; floor 150 not reached.
	_setup()
	memory.write_u16(CTL + 0x20, 0x3e00)
	memory.write_u16(CTL + 0x22, 0x10)
	memory.write_u16(CTL + 0x24, 0x3fff)
	memory.write_u16(CTL + 0x36, 0x20)
	memory.write_u32(CTL + 0x2e, 150)
	memory.write_u32(CTL + 0x32, 499)
	port._jsr(0x174a4, [CTL])
	## 0x20 - 0x5b = -0x3b; asr.w 4 -> -4.
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x20), memory.read_u16(CTL + 0x22), memory.read_u16(CTL + 0x24), memory.read_s16(CTL + 0x36), memory.read_s32(CTL + 0xc), _retired(OBJ)], [0x0200, 0x0210, 0x00ff, -0x3b, -4, false], "debris spins and falls") and ok
	## Replay state 3 moves the object by +8 / +0xc / +0x10 after saving its position.
	memory.write_u16(0x1b870, 3)
	memory.write_u32(CTL + 8, 5)
	memory.write_u32(CTL + 0x10, -7 & 0xffffffff)
	port._jsr(0x174a4, [CTL])
	## +0x36 = -0x3b - 0x5b = -0x96 -> asr 4 = -10.
	ok = Assertions.assert_equal([memory.read_s32(CTL + 0x14), memory.read_s32(CTL + 0x18), memory.read_s32(CTL + 0x1c), memory.read_s32(OBJ + 0x18), memory.read_s32(OBJ + 0x1c), memory.read_s32(OBJ + 0x20)], [100, 200, 300, 105, 190, 293], "replay 3: position saved, then moved") and ok
	## End frame reached -> retired.
	memory.write_u16(0x1b870, 0)
	memory.write_u32(CTL + 0x32, 500)
	port._jsr(0x174a4, [CTL])
	ok = Assertions.assert_equal(_retired(OBJ), true, "debris retired at its end frame") and ok
	## Floor reached -> retired.
	_setup()
	memory.write_u32(CTL + 0x2e, 200)
	port.tick_debris_fragment(CTL)
	ok = Assertions.assert_equal(_retired(OBJ), true, "debris retired on the floor (y <= +0x2e)") and ok

	## Smoke plume: ownerless -> waits for its end frame.
	_setup()
	memory.write_u32(CTL + 0x38, 501)
	port._jsr(0x116dc, [CTL])
	ok = Assertions.assert_equal(_retired(OBJ), false, "ownerless plume waits") and ok
	memory.write_u32(CTL + 0x38, 500)
	port._jsr(0x116dc, [CTL])
	ok = Assertions.assert_equal(_retired(OBJ), true, "ownerless plume retired at its end frame") and ok
	## Owned and burning (byte +0x684 bit 0): ring index 0 -> 7, point 7 = owner position.
	_setup()
	memory.write_u32(CTL + 0x3c, OWNER)
	memory.write_u8(OWNER_CTL + 0x684, 1)
	port._jsr(0x116dc, [CTL])
	var p7 := CTL + 0x40 + 7 * 12
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0xa0), memory.read_s32(p7), memory.read_s32(p7 + 4), memory.read_s32(p7 + 8), memory.read_s32(CTL + 8), memory.read_s32(CTL + 0xc), memory.read_s32(CTL + 0x10), _retired(OBJ)], [7, 7000, 800, -9000, 6900, 600, -9300, false], "burning owner: trail point and offset") and ok
	## Word bit 0 (byte +0x685) is not the flag: no longer burning -> retired.
	memory.write_u8(OWNER_CTL + 0x684, 0)
	memory.write_u8(OWNER_CTL + 0x685, 1)
	port._jsr(0x116dc, [CTL])
	ok = Assertions.assert_equal([_retired(OBJ), port.a7], [true, STACK_TOP], "owner no longer burning: retired") and ok
	return ok
