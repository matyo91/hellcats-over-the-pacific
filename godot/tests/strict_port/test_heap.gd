extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const WORLD := 0x23000
const ARENA := 0x28000

## Expected addresses come from a Python model of 0x1958..0x1c00 written from the disassembly
## (class computation with lsr, class lists, first fit around the address-ordered ring with
## unsigned compares, tail cut, coalescing on free), independent of the C and of this port.

var memory
var port

func _fresh() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(WORLD + 0x348, ARENA)

func run() -> bool:
	var ok := true
	_fresh()
	## Small classes: 10 bytes -> class 4 (16-byte blocks, payload at +4); a freed block is reused.
	var a: int = port.heap_alloc(10)
	var b: int = port.heap_alloc(10)
	port.heap_free_coalesce(a)
	var c: int = port.heap_alloc(12)
	ok = Assertions.assert_equal([a, b, c, memory.read_u8(a - 4)], [0x28004, 0x28014, 0x28004, 4], "small blocks and reuse") and ok

	## Large blocks: units = (n + 7) >> 3 + 1; freeing two neighbours merges them; a later request
	## is cut from the merged block's tail; a request that does not fit grows the arena.
	var l1: int = port.heap_alloc(100)
	var l2: int = port.heap_alloc(100)
	var l3: int = port.heap_alloc(40)
	ok = Assertions.assert_equal([l1, l2, l3, memory.read_u32(l1 - 8), memory.read_u32(l3 - 8)], [0x28028, 0x28098, 0x28108, 14, 6], "large blocks") and ok
	port.heap_free_coalesce(l2)
	port.heap_free_coalesce(l1)
	ok = Assertions.assert_equal([memory.read_u32(0x20c60), memory.read_u32(0x20c5c), memory.read_u32(0x28020)], [0x20c58, 0x28020, 28], "freed neighbours merged (28 units) after the sentinel") and ok
	var l4: int = port.heap_alloc(200)
	ok = Assertions.assert_equal([l4, memory.read_u32(l4 - 8), memory.read_u32(0x28020)], [0x28038, 26, 2], "tail cut: 26 units, 2 left") and ok
	var l5: int = port.heap_alloc(30)
	ok = Assertions.assert_equal([l5, memory.read_u32(l5 - 8), memory.read_u32(0x20c50)], [0x28138, 5, 0x158], "no fit -> arena grows") and ok

	## Grow-only realloc: 72-byte table (10 units) grown to 312 bytes (40 units), contents kept,
	## new part cleared, old block freed and reused.
	_fresh()
	var t: int = port.heap_calloc(3, 0x18)
	for i in range(72):
		memory.write_u8(t + i, i + 1)
	ok = Assertions.assert_equal(port.heap_realloc_grow_only(t, 40), t, "no growth when it fits") and ok
	var g: int = port.heap_realloc_grow_only(t, 312)
	ok = Assertions.assert_equal([t, g, memory.read_u32(g - 8)], [0x28008, 0x28058, 40], "grown block") and ok
	ok = Assertions.assert_equal([memory.read_u8(g), memory.read_u8(g + 71), memory.read_u8(g + 72), memory.read_u8(g + 311)], [1, 72, 0, 0], "old bytes copied, rest cleared") and ok
	ok = Assertions.assert_equal(port.heap_alloc(72), 0x28008, "old block reused") and ok

	## memmove_block: overlapping copies in both directions; memzero ignores a negative count.
	_fresh()
	for i in range(8):
		memory.write_u8(0x29000 + i, i + 1)
	port.memmove_block(0x29000, 0x29002, 6)
	var up := []
	for i in range(8):
		up.append(memory.read_u8(0x29000 + i))
	ok = Assertions.assert_equal(up, [1, 2, 1, 2, 3, 4, 5, 6], "overlap, dst above src: backward copy") and ok
	port.memmove_block(0x29002, 0x29000, 6)
	var down := []
	for i in range(8):
		down.append(memory.read_u8(0x29000 + i))
	ok = Assertions.assert_equal(down, [1, 2, 3, 4, 5, 6, 5, 6], "overlap, dst below src: forward copy") and ok
	port.memzero(0x29000, -1)
	ok = Assertions.assert_equal(memory.read_u8(0x29000), 1, "negative count: nothing cleared") and ok
	port.memzero(0x29001, 5)
	ok = Assertions.assert_equal([memory.read_u8(0x29000), memory.read_u8(0x29001), memory.read_u8(0x29005), memory.read_u8(0x29006)], [1, 0, 0, 5], "memzero of 5 from an odd address") and ok
	return ok
