extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const CTL := 0x21200
const VERTS := 0x21400
const OWNER := 0x21600
const OWNER_CTL := 0x21800

## Expected values worked out from the disassembly of 0x17150 (animate_ground_fire) and 0x17380
## (tick_ground_fire). Owner at (1000, _, 2000) with controller velocity (301, _, -97): speed
## 398. Vertices 0 / 1 sit at (+word(3104 / 398) = 7, +word(9632 / 398) = 24), vertices 2 / 3
## at (-7, -24) (divs.l truncates); drift words = offset / 8 toward zero: x 0 / 0, z 3 / -3 (the
## asr.w of -24 + 7 = -17 is -3). The detach coin comes from a twin overlay RNG.

var memory
var port

func _setup(state: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	memory.write_u32(CTL, OBJ)
	memory.write_u32(OBJ + 8, CTL)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u32(OBJ + 4, 0x40)
	memory.write_u32(CTL + 0x50, OWNER)
	memory.write_u16(CTL + 0x34, state)
	memory.write_u16(CTL + 0x32, 2)
	memory.write_u32(OWNER + 8, OWNER_CTL)
	memory.write_u32(OWNER + 0x18, 1000)
	memory.write_u32(OWNER + 0x20, 2000)
	memory.write_u32(OWNER_CTL + 8, 301)
	memory.write_u32(OWNER_CTL + 0x10, -97 & 0xffffffff)
	memory.write_u16(OWNER_CTL + 0x684, 0x0800)

func _verts(count: int) -> Array:
	var out := []
	for i in range(count):
		out.append([memory.read_s32(VERTS + 12 * i), memory.read_s32(VERTS + 12 * i + 4), memory.read_s32(VERTS + 12 * i + 8)])
	return out

func _words(base: int) -> Array:
	var out := []
	for i in range(4):
		out.append(memory.read_s16(base + 2 * i))
	return out

func run() -> bool:
	var ok := true

	## State 1: shown, becomes 2, all four vertices placed; the damaged owner detaches one.
	_setup(1)
	var twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	var first_bit: int = 1 if (twin.overlay_rng_next() & 1) != 0 else 8
	ok = Assertions.assert_equal(port.animate_ground_fire(CTL), 0, "state 1: running") and ok
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x34), memory.read_u32(OBJ + 4)], [2, 0], "state 1 -> 2, object shown") and ok
	ok = Assertions.assert_equal(_verts(5), [[1007, 0, 2024], [1007, 0, 2024], [993, 0, 1976], [993, 0, 1976], [1000, 0, 2000]], "vertices beside the owner, vertex 4 the mean") and ok
	ok = Assertions.assert_equal([_words(CTL + 0x36), _words(CTL + 0x46), memory.read_u16(CTL + 0x4e)], [[0, 0, 0, 0], [3, 3, -3, -3], first_bit], "drift words and one detached vertex") and ok

	## Next frame: the detached vertex drifts by its words, the other is placed again; with the
	## other end of the pair still attached the coin is tossed again.
	var second: int = twin.overlay_rng_next() & 1
	memory.write_u32(OWNER + 0x18, 1100)
	port.animate_ground_fire(CTL)
	var moved: int = 0 if first_bit == 1 else 3
	var kept: int = 3 - moved
	var v := _verts(4)
	var want_moved: Array = [1007, 0, 2027] if moved == 0 else [993, 0, 1973]
	var want_kept: Array = [1107, 0, 2024] if kept == 0 else [1093, 0, 1976]
	ok = Assertions.assert_equal([v[moved], v[kept]], [want_moved, want_kept], "detached vertex drifts, attached one follows the owner") and ok
	var expected_mask: int = first_bit | (1 if second != 0 else 8)
	ok = Assertions.assert_equal(memory.read_u16(CTL + 0x4e), expected_mask, "second coin") and ok

	## An undamaged owner (word +0x684 & 0x1800 == 0) detaches everything -> state 3.
	_setup(2)
	memory.write_u16(OWNER_CTL + 0x684, 0x07ff)
	port.animate_ground_fire(CTL)
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x4e), memory.read_u16(CTL + 0x34)], [0xf, 3], "undamaged owner: all detached, state 3") and ok
	## State 3: timer 2 -> 1 (running), 1 -> 0 (finished); tick_ground_fire then retires.
	ok = Assertions.assert_equal([port.animate_ground_fire(CTL), memory.read_u16(CTL + 0x32)], [0, 1], "state 3 counting down") and ok
	port._jsr(0x17360, [CTL])
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x32), memory.read_u32(OBJ + 0x18), memory.read_u32(OBJ + 4) & 2, port.a7], [0, 1000000000, 2, STACK_TOP], "timer out: tick_ground_fire retires the fire") and ok

	## A retired owner ends a state-1 fire at once (timer cleared) -> finished.
	_setup(1)
	memory.write_u8(OWNER + 7, 2)
	ok = Assertions.assert_equal([port.animate_ground_fire(CTL), memory.read_u16(CTL + 0x34), memory.read_u16(CTL + 0x32)], [1, 3, 0], "owner retired: state 3, timer 0, finished") and ok
	## A stopped owner ends a state-2 fire but keeps its timer.
	_setup(2)
	memory.write_u32(OWNER_CTL + 8, 0)
	memory.write_u32(OWNER_CTL + 0x10, 0)
	ok = Assertions.assert_equal([port.animate_ground_fire(CTL), memory.read_u16(CTL + 0x34), memory.read_u16(CTL + 0x32)], [0, 3, 1], "owner stopped: state 3, timer counts") and ok
	## Rewind ends a state-2 fire and finishes it; a state-1 fire is left as it is.
	_setup(2)
	memory.write_u16(0x1b870, 1)
	ok = Assertions.assert_equal([port.animate_ground_fire(CTL), memory.read_u16(CTL + 0x34)], [1, 3], "rewind: finished") and ok
	## Any other state word: nothing happens.
	_setup(5)
	ok = Assertions.assert_equal([port.animate_ground_fire(CTL), memory.read_u32(OBJ + 4), memory.read_s32(VERTS)], [0, 0x40, 0], "unknown state: idle") and ok
	return ok
