extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const PLANE := 0x21000
const PLANE_CTL := 0x21100
const OTHER := 0x21800
const OTHER_CTL := 0x21900
const SHIP_TYPE := 0x21f00
const PLANE_TYPE := 0x21f10
const TRACKS := 0x22000

## Expected values follow the disassembly of aircraft_destroy (0xe0a4), aircraft_collision
## (0xfe0a), invert_ai_bias_67b_if_positive (0x10cd8) and add_radar_track (0x176b2). The
## handlers are reached through code_table at the runtime addresses the aircraft definition
## records hold (+0xa / +0x12).

var memory
var port

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	PoolFixtureScript.new().setup(memory, port)
	memory.write_u32(PLANE + 8, PLANE_CTL)
	memory.write_u32(PLANE_CTL, PLANE)
	memory.write_u32(PLANE_CTL + 4, PLANE_TYPE)
	memory.write_u16(PLANE_TYPE, 1)
	memory.write_u32(OTHER + 8, OTHER_CTL)
	memory.write_u32(OTHER_CTL, OTHER)

func run() -> bool:
	var ok := true

	## Destroy: the +0x616 buffer goes back to the heap (the next block of its size is it), the AI
	## target loses a reference.
	_setup()
	var buffer: int = port.heap_alloc(0x40)
	memory.write_u32(PLANE_CTL + 0x616, buffer)
	memory.write_u32(PLANE_CTL + 0x692, OTHER)
	memory.write_u8(OTHER + 3, 2)
	port._jsr(0xe084, [PLANE_CTL])
	ok = Assertions.assert_equal([port.heap_alloc(0x40), memory.read_u8(OTHER + 3)], [buffer, 1], "destroy: buffer freed, target released") and ok

	## Collision with another aircraft: both damaged (0x400); nothing while replaying.
	_setup()
	memory.write_u32(OTHER_CTL + 4, PLANE_TYPE)
	memory.write_u16(0x1b870, 1)
	port._jsr(0xfdea, [PLANE, OTHER, 0])
	ok = Assertions.assert_equal([memory.read_u16(PLANE_CTL + 0x684), memory.read_u16(OTHER_CTL + 0x684)], [0, 0], "replay: no damage") and ok
	memory.write_u16(0x1b870, 0)
	port.aircraft_collision(PLANE, OTHER)
	ok = Assertions.assert_equal([memory.read_u16(PLANE_CTL + 0x684), memory.read_u16(OTHER_CTL + 0x684)], [0x400, 0x400], "aircraft vs aircraft: both damaged") and ok

	## Collision with a ship (type 0x16, range 500 > radius 10): the blast hits it as a ship -
	## one hit used, credited because this is the player's aircraft. The blast y is the
	## aircraft's ground (+0x2e = 50) since the aircraft is below it.
	_setup()
	memory.write_u32(OTHER_CTL + 4, SHIP_TYPE)
	memory.write_u16(SHIP_TYPE, 0x16)
	memory.write_u32(OTHER + 0x14, 500)
	memory.write_u32(OTHER + 0x1c, 50)
	memory.write_u16(OTHER_CTL + 0x32, 3)
	memory.write_u32(PLANE + 0x1c, 20)
	memory.write_u32(PLANE_CTL + 0x2e, 50)
	memory.write_u32(0x1b738, PLANE_CTL)
	memory.write_u32(0x1b5a4, OTHER)
	memory.write_u32(0x1b734, 1)
	port.aircraft_collision(PLANE, OTHER)
	ok = Assertions.assert_equal([memory.read_u16(OTHER_CTL + 0x32), memory.read_u16(OTHER_CTL + 0x4e), memory.read_u16(OTHER_CTL + 0x684), port.a7], [2, 1, 0, STACK_TOP], "aircraft vs ship: blast hits the ship, credited") and ok

	## AI bias: positive values flip, others stay.
	_setup()
	for c in [[5, 0xfb], [0xfd, 0xfd], [0, 0], [0x7f, 0x81]]:
		memory.write_u8(PLANE_CTL + 0x67b, c[0])
		port.invert_ai_bias_67b_if_positive(PLANE_CTL)
		ok = Assertions.assert_equal(memory.read_u8(PLANE_CTL + 0x67b), c[1], "invert bias 0x%x" % c[0]) and ok

	## Radar tracks: appended within the limit, not past it, and at most six.
	_setup()
	memory.write_u32(0x1b51c, TRACKS)
	memory.write_u32(0x26666, 1000)
	memory.write_u32(PLANE + 0x18, 11)
	memory.write_u32(PLANE + 0x20, 22)
	memory.write_u16(PLANE_CTL + 0xa, 0xfffe)
	memory.write_u16(PLANE_CTL + 0x12, 7)
	memory.write_u32(PLANE + 0x10, 1000)
	port.add_radar_track(PLANE)
	ok = Assertions.assert_equal([memory.read_u32(0x26676), memory.read_s32(TRACKS), memory.read_s32(TRACKS + 4), memory.read_s32(TRACKS + 8), memory.read_s32(TRACKS + 0xc), memory.read_u32(TRACKS + 0x10)], [1, 11, 22, -2, 7, 0], "track appended") and ok
	memory.write_u32(PLANE + 0x10, 1001)
	port.add_radar_track(PLANE)
	memory.write_u32(PLANE + 0x10, 0)
	memory.write_u32(0x26676, 6)
	port.add_radar_track(PLANE)
	ok = Assertions.assert_equal([memory.read_u32(0x26676), memory.read_u32(TRACKS + 0x14)], [6, 0], "beyond the limit / six tracks: nothing") and ok
	return ok
