extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x40000
const OBJ := 0x21000
const KEY := 5
const DEF5 := 0x2c900
const DEF7 := 0x2ca00
const DEF11 := 0x2cb00

## Expected values read off the disassembly of each factory (0x11486 .. 0x19b82) and of
## fill_pose_history (0xdf5e). Every factory is reached through code_table at its RUNTIME
## address (file - 0x20), as the definition record +6 pointers store it, with (obj, key,
## extra). The object starts with long +4 = 1, +0x14 = 0x55, +0x18 / +0x1c / +0x20 = 11 / 5 /
## 33 and word +0x34 = 0x77; DAT_0001b524[5] has word +0x1a = 0x1234.
## [runtime, name, controller fields [offset, width, value], object long +4 after]
const CASES := [
	[0x11466, "spinner", [[0x36, 4, 0]], 0x1],
	[0x11590, "plume", [], 0x112001],
	[0x11a8e, "camera facing", [], 0x100001],
	[0x11ade, "effect", [], 0x170001],
	[0x127a6, "ordnance", [], 0x122001],
	[0x150a8, "carrier", [[0x50, 2, 0xffff], [0x52, 2, 0xffff], [0x48, 4, 1000000000], [0x32, 2, 0x1234], [0x44, 2, 7]], 0x4001],
	[0x152ee, "firing ship", [[0x50, 2, 0x14], [0x48, 4, 1000000000], [0x44, 2, 7], [0x32, 2, 0x1234]], 0x1],
	[0x15560, "sinking", [[0x54, 2, 0x5678], [0x48, 4, 1000000000], [0x44, 2, 3], [0x32, 2, 0x1234]], 0x102001],
	[0x155cc, "basic ship", [[0x48, 4, 1000000000], [0x44, 2, 7], [0x32, 2, 0x1234]], 0x1],
	[0x15b72, "bullet", [], 0x122001],
	[0x16a1a, "trail", [], 0x12001],
	[0x1704a, "ground fire", [], 0x12041],
	[0x17382, "debris", [], 0x152001],
	[0x17546, "ground mark", [], 0x20001],
	[0x1889a, "shadow", [], 0x112001],
	[0x18b32, "flak", [[0x46, 2, 0x3c], [0x42, 4, 0x26ac0]], 0x20001],
	[0x190a0, "turret", [[0x42, 4, 0xce40]], 0x20001],
	[0x19396, "parachute", [], 0x132001],
	[0x199fa, "cloud", [], 0x132001],
	[0x19b62, "view attached", [], 0x132001],
]

var memory
var port

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = 0x3f000
	PoolFixtureScript.new().setup(memory, port)
	memory.write_u32(0x1b524 + KEY * 4, DEF5)
	memory.write_u16(DEF5 + 0x1a, 0x1234)
	memory.write_u32(0x1b540, DEF7)
	memory.write_u32(0x1b550, DEF11)
	memory.write_u32(OBJ + 4, 1)
	memory.write_u32(OBJ + 0x14, 0x55)
	memory.write_u32(OBJ + 0x18, 11)
	memory.write_u32(OBJ + 0x1c, 5)
	memory.write_u32(OBJ + 0x20, 33)
	memory.write_u16(OBJ + 0x34, 0x77)

func _read(address: int, width: int) -> int:
	return memory.read_u32(address) if width == 4 else memory.read_u16(address)

func run() -> bool:
	var ok := true
	for c in CASES:
		_setup()
		var ctl: int = port._jsr(c[0], [OBJ, KEY, 0x12345678])
		var definition: int = DEF5
		if c[1] == "plume":
			definition = DEF7
		elif c[1] == "ground fire":
			definition = DEF11
		ok = Assertions.assert_equal([ctl != 0, memory.read_u32(ctl), memory.read_u32(ctl + 4), memory.read_u32(OBJ + 4)], [true, OBJ, definition, c[3]], "%s: +0 object, +4 definition, object flags" % c[1]) and ok
		var got := []
		var want := []
		for f in c[2]:
			got.append(_read(ctl + f[0], f[1]))
			want.append(f[2])
		ok = Assertions.assert_equal(got, want, "%s: controller fields" % c[1]) and ok
		var tail := [memory.read_u32(OBJ + 0x14), memory.read_u16(OBJ + 0x34)]
		var tail_want := [0x55, 0x77]
		if c[1] == "bullet":
			tail_want = [0x9c4, 0x77]
		elif c[1] == "trail" or c[1] == "ground fire":
			tail_want = [0x55, 0]
		ok = Assertions.assert_equal(tail, tail_want, "%s: object +0x14 / +0x34" % c[1]) and ok
		if c[1] == "ordnance" or c[1] == "parachute":
			var ring: int = ctl + 0x32
			ok = Assertions.assert_equal([memory.read_u32(ring), memory.read_u32(ring + 4), memory.read_u32(ring + 8), memory.read_u32(ring + 0x4a * 0x14 + 8), memory.read_u32(ring + 0x4b * 0x14), memory.read_u32(ring + 0xc)], [11, 5, 33, 33, 0, 0], "%s: 75 pose entries hold the position, +0xc and entry 75 untouched" % c[1]) and ok

	## The object held in effect_template_3 also gets word +6 |= 0x2000.
	_setup()
	memory.write_u32(0x2627a, OBJ)
	port._jsr(0x11ade, [OBJ, KEY, 0])
	ok = Assertions.assert_equal(memory.read_u32(OBJ + 4), 0x172001, "effect_template_3: word +6 |= 0x2000") and ok

	## A turret on the ground (+0x1c == 0) also gets byte +5 bit 4.
	_setup()
	memory.write_u32(OBJ + 0x1c, 0)
	port._jsr(0x190a0, [OBJ, KEY, 0])
	ok = Assertions.assert_equal(memory.read_u32(OBJ + 4), 0x120001, "grounded turret: byte +5 |= 0x12") and ok

	## Only the first carrier controller is recorded in first_carrier_ctl.
	_setup()
	var first: int = port._jsr(0x150a8, [OBJ, KEY, 0])
	var second: int = port._jsr(0x150a8, [OBJ, KEY, 0])
	ok = Assertions.assert_equal([memory.read_u32(0x1b864) == first, first != second], [true, true], "first_carrier_ctl keeps the first") and ok

	## Cleared allocation: a byte the factory does not write is 0 even when the heap reuses
	## a dirty block.
	_setup()
	var dirty: int = port.heap_alloc(0x40)
	for i in range(0x40):
		memory.write_u8(dirty + i, 0xaa)
	port.heap_free_coalesce(dirty)
	var cloud: int = port._jsr(0x199fa, [OBJ, KEY, 0])
	ok = Assertions.assert_equal([cloud == dirty, memory.read_u8(cloud + 0x3f), memory.read_u32(cloud + 8)], [true, 0, 0], "cloud controller reuses the freed 0x40 block, cleared") and ok
	return ok
