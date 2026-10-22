extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const INIT := 0x705 ## test-only initialiser address stored in effect_init_table
const DEBRIS_TEMPLATE := 0x22900

## Expected values follow the disassembly of 0x11c58..0x11db2 and of the strict callees it
## reaches (spawn_mission_pool_object, instantiate_mission_pool_slot, spawn_debris_fragment).
## PoolFixture supplies the scene and a class factory returning controllers; activated shapes
## are read from the lists activate_near_range_object publishes to; template index k <->
## effect kind k, index 9 <-> debris.

var init_calls: Array = []
var memory
var port
var fixture

func _init_handler(obj: int) -> void:
	init_calls.append([obj, port.a7])

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.code_table[INIT] = Callable(self, "_init_handler")
	port.overlay_rng_init(1)
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	init_calls.clear()
	for k in range(4):
		fixture.add_template(k, 5)
		memory.write_u32(0x2626e + 4 * k, fixture.template_object(0x22000 + 0x100 * k, k))
		memory.write_u32(0x1b40c + 4 * k, INIT)
	fixture.add_template(9, 5)
	memory.write_u32(0x2665c, fixture.template_object(DEBRIS_TEMPLATE, 9))
	memory.write_u32(0x1b838, 4242)

func run() -> bool:
	var ok := true

	## Live play, kind 3 with debris, near (5000): logged, near-explosion timer, object set up.
	_setup()
	memory.write_u16(0x260ec, 15)
	var ctl: int = port.spawn_effect(3, 30, 0x2d, 0x101, 1, 5000, -6, 7)
	ok = Assertions.assert_equal(ctl, PoolFixtureScript.CONTROLLERS, "returns the factory's controller") and ok
	var e := 0x260ee + 15 * 0x18
	ok = Assertions.assert_equal([memory.read_u8(e), memory.read_u8(e + 1), memory.read_u8(e + 2), memory.read_s16(e + 4), memory.read_s16(e + 6)], [3, 1, 1, 30, 0x2d], "log: kind, low byte of byte_38, debris, words") and ok
	ok = Assertions.assert_equal([memory.read_s32(e + 8), memory.read_s32(e + 0xc), memory.read_s32(e + 0x10), memory.read_u32(e + 0x14)], [5000, -6, 7, 4242], "log: position and frame") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x260ec), 0, "log index wraps at 16") and ok
	ok = Assertions.assert_equal([memory.read_u16(0x1b84a), memory.read_u16(0x1b848)], [0x1e, 0], "near explosion timer") and ok
	var obj: int = fixture.activated()[0]
	ok = Assertions.assert_equal([memory.read_u8(obj + 1), memory.read_u8(obj + 2)], [3, 0], "object of template 3 in slot 0") and ok
	ok = Assertions.assert_equal([memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20)], [5000, -6, 7], "slot offsets placed the object (template chain)") and ok
	ok = Assertions.assert_equal(fixture.factory_calls[0].slice(0, 3), [obj, 5, 0], "class factory (obj, key, record word +0)") and ok
	ok = Assertions.assert_equal([memory.read_u32(ctl), memory.read_u32(0x1c25c), memory.read_u32(0x1c1cc)], [obj, ctl, 4], "activation: *ctl = object (after the factory cleared it); controller listed (with the three debris controllers)") and ok
	ok = Assertions.assert_equal([memory.read_u8(ctl + 0x32), memory.read_u16(ctl + 0x34), memory.read_u16(ctl + 0x36), memory.read_u8(ctl + 0x38), memory.read_u8(ctl + 0x39)], [3, 30, 0x2d, 1, 1], "controller fields") and ok
	ok = Assertions.assert_equal(init_calls, [[obj, STACK_TOP - 0x30]], "initialiser with the object, 0x30 below") and ok
	ok = Assertions.assert_equal(fixture.activated().size(), 4, "effect object + three debris fragments activated") and ok
	var debris_obj: int = fixture.activated()[1]
	ok = Assertions.assert_equal([memory.read_u8(debris_obj + 1), memory.read_s32(debris_obj + 0x18)], [9, 5000], "debris from template 9 at the position") and ok
	var debris_ctl: int = memory.read_u32(debris_obj + 8)
	## Word +0xe is the low word of the y velocity stored just before (+0xc), so +0x36 is it asl 4.
	ok = Assertions.assert_equal([memory.read_u32(debris_ctl + 0x32), memory.read_u16(debris_ctl + 0x36)], [4242 + 0x2d, (memory.read_u16(debris_ctl + 0xe) << 4) & 0xffff], "debris: frame + 0x2d, +0x36 = y velocity low word asl 4") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok

	## Distant (20000) -> distant timer; far (50000) -> none; view mode 5 or kind 1 -> none.
	_setup()
	port.spawn_effect(0, 1, 2, 0, 0, 20000, 0, 0)
	ok = Assertions.assert_equal([memory.read_u16(0x1b84a), memory.read_u16(0x1b848)], [0, 0xf], "distant explosion timer") and ok
	ok = Assertions.assert_equal(fixture.activated().size(), 1, "no debris without the flag") and ok
	_setup()
	port.spawn_effect(0, 1, 2, 0, 0, 50000, 0, 0)
	memory.write_u16(0x1d858, 5)
	port.spawn_effect(0, 1, 2, 0, 0, 100, 0, 0)
	memory.write_u16(0x1d858, 0)
	port.spawn_effect(1, 1, 2, 0, 0, 100, 0, 0)
	ok = Assertions.assert_equal([memory.read_u16(0x1b84a), memory.read_u16(0x1b848)], [0, 0], "no timers far, in view 5, or for kind 1") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x260ec), 3, "three calls logged") and ok

	## Replay: state 2 refuses kind 0 (no log, no spawn) but runs kind 1 unlogged; state -1 runs all.
	_setup()
	memory.write_u16(0x1b870, 2)
	ok = Assertions.assert_equal(port.spawn_effect(0, 1, 2, 0, 0, 100, 0, 0), 0, "replay state 2, kind 0 -> 0") and ok
	ok = Assertions.assert_equal([fixture.activated().size(), memory.read_u16(0x260ec)], [0, 0], "nothing spawned or logged") and ok
	ok = Assertions.assert_equal(port.spawn_effect(1, 1, 2, 0, 0, 100, 0, 0) != 0, true, "replay state 2, kind 1 runs") and ok
	memory.write_u16(0x1b870, -1 & 0xffff)
	ok = Assertions.assert_equal(port.spawn_effect(2, 1, 2, 0, 0, 100, 0, 0) != 0, true, "replay state -1 runs any kind") and ok
	ok = Assertions.assert_equal(memory.read_u16(0x260ec), 0, "replay calls are not logged") and ok

	## Far template: the object is deferred without vertices, the pool spawn retires it -> 0.
	_setup()
	fixture.make_far(2)
	ok = Assertions.assert_equal(port.spawn_effect(2, 1, 2, 0, 1, 100, 0, 0), 0, "deferred object without vertices: retired, 0") and ok
	ok = Assertions.assert_equal(memory.read_s32(memory.read_u32(0x1d0e4) + 0x18), 1000000000, "that object was retired") and ok
	ok = Assertions.assert_equal([init_calls.size(), fixture.activated().size()], [0, 0], "no initialiser, activation or debris") and ok
	return ok
