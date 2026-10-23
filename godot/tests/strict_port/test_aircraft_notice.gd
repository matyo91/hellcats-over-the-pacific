extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const SELF := 0x21000
const SELF_CTL := 0x21100
const OTHER := 0x21800
const OTHER_CTL := 0x21900
const OTHER_TYPE := 0x21f00
const FACILITY := 0x21c00
const FACILITY_CTL := 0x21d00
const FACILITY_TYPE := 0x21f10
const TRACKS := 0x22000

## Expected values follow the disassembly of aircraft_notice_object (0xfe96; jump table of types
## 3..0x19 decoded from the words at 0xff48) and release_ai_target (0x100bc). Chance for a range
## 500 object 1000 away: ((500 * 0x6720 / 500) << 6) / 1000 = 1689, always above rng & 0x7f.
## Rng draws come from a twin overlay RNG.

var memory
var port
var twin

func _setup(type: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	PoolFixtureScript.new().setup(memory, port)
	memory.write_u32(SELF + 8, SELF_CTL)
	memory.write_u32(SELF_CTL, SELF)
	memory.write_u32(SELF_CTL + 0x32, 0x110d4)
	memory.write_u16(SELF_CTL + 0x682, 2)
	memory.write_u8(SELF_CTL + 0x67b, 3)
	memory.write_u32(OTHER + 8, OTHER_CTL)
	memory.write_u32(OTHER_CTL, OTHER)
	memory.write_u32(OTHER_CTL + 4, OTHER_TYPE)
	memory.write_u16(OTHER_TYPE, type)
	memory.write_u32(OTHER + 0x18, 1000)
	memory.write_u32(OTHER + 0x14, 500)

## Frames until the twin's 1-in-64 draw, then the chance draw.
func _frames() -> int:
	var frames: int = 0
	while true:
		frames += 1
		if (twin.overlay_rng_next() & 0x3f) == 0:
			return frames
	return 0

func run() -> bool:
	var ok := true

	## AI fighter notices an enemy aircraft (type 3): taken after the predicted draw.
	_setup(3)
	var frames: int = _frames()
	for f in range(frames):
		port._jsr(0xfe76, [SELF, OTHER, 0])
	ok = Assertions.assert_equal([memory.read_u32(SELF_CTL + 0x692), memory.read_u32(SELF_CTL + 0x696), memory.read_u8(OTHER + 3), memory.read_u32(SELF_CTL + 0x32), memory.read_u8(SELF_CTL + 0x67b), port.a7], [OTHER, 1000, 1, 0x110d4, 0xfd, STACK_TOP], "AI takes an aircraft target") and ok
	## release_ai_target drops it.
	port._jsr(0x1009c, [SELF_CTL])
	ok = Assertions.assert_equal([memory.read_u32(SELF_CTL + 0x692), memory.read_u8(OTHER + 3)], [0, 0], "target released") and ok

	## Out of ammo (word +0x682 <= 1): the draw happens but nothing is taken.
	_setup(4)
	memory.write_u16(SELF_CTL + 0x682, 1)
	frames = _frames()
	for f in range(frames):
		port.aircraft_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal(memory.read_u32(SELF_CTL + 0x692), 0, "no ammo: no aircraft target") and ok

	## A ship (type 0x16) near a friendly facility (type 0x12 -> 0x100), with bombs: bombing run.
	_setup(0x16)
	memory.write_u8(SELF_CTL + 0x67c, 2)
	memory.write_u32(FACILITY + 8, FACILITY_CTL)
	memory.write_u32(FACILITY_CTL + 4, FACILITY_TYPE)
	memory.write_u16(FACILITY_TYPE, 0x12)
	memory.write_u32(FACILITY + 0x18, 1000)
	memory.write_u32(FACILITY + 0xc, 0x100000)
	memory.write_u32(0x1b5a4, FACILITY)
	memory.write_u32(0x1b734, 1)
	frames = _frames()
	for f in range(frames):
		port.aircraft_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal([memory.read_u32(SELF_CTL + 0x692), memory.read_u32(SELF_CTL + 0x32), memory.read_u8(SELF_CTL + 0x675), memory.read_u8(SELF_CTL + 0x67b)], [OTHER, 0x112c0, 0, 0xfd], "AI bomber takes a ship near a 0x100 facility") and ok

	## Ignored types (e.g. 9) draw nothing.
	_setup(9)
	port.aircraft_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal(port.overlay_rng_next(), twin.overlay_rng_next(), "type 9: no rng drawn") and ok

	## Player: in view mode 1 a high aircraft gets a radar track and becomes designated; a farther
	## one does not replace it.
	_setup(2)
	memory.write_u32(0x1b738, SELF_CTL)
	memory.write_u16(0x1d858, 1)
	memory.write_u32(0x1b51c, TRACKS)
	memory.write_u32(0x26666, 0x100000)
	memory.write_u32(OTHER + 0x1c, 3000)
	memory.write_u32(OTHER + 0x10, 500)
	port.aircraft_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal([memory.read_u32(0x26676), memory.read_u32(0x1b888)], [1, OTHER_CTL], "player: radar track, designated") and ok
	memory.write_u32(OTHER + 0x10, 600)
	memory.write_u32(0x1b888, 0x21e00)
	memory.write_u32(0x21e00, 0x21e80)
	memory.write_u32(0x21e80 + 0x10, 550)
	port.aircraft_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal(memory.read_u32(0x1b888), 0x21e00, "player: a farther aircraft is not designated") and ok
	## Other view modes: nothing.
	memory.write_u16(0x1d858, 2)
	memory.write_u32(0x26676, 0)
	port.aircraft_notice_object(SELF, OTHER)
	ok = Assertions.assert_equal(memory.read_u32(0x26676), 0, "player in view mode 2: nothing") and ok
	return ok
