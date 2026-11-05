extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://hellcats/runtime/mac_machine.gd")

## The system event mask (SysEvtMask, low memory $144): the jump-table glue $1fa is SetEventMask (ID09
## 0x18a), and as PostEvent does, an event type the mask disables is not queued. The Mac's default
## leaves key-up out; the game's flight mask 0xfff9 (run_flight_session) leaves the mouse clicks out.
func run() -> bool:
	var machine = MacMachine.new()
	var events = machine.toolbox.events
	var set_mask: Callable = machine.segments.stand_ins[0x1fa]
	var ok := Assertions.assert_equal(machine.memory.read_u16(0x144), 0xffef, "the default mask, in low memory")
	events.post_key(0x24, 13, true, false, 0)
	events.post_key(0x24, 13, false, false, 0)
	ok = Assertions.assert_equal(_whats(events), [3], "key-down queued, key-up left out by default") and ok
	set_mask.call([0xfff9])
	ok = Assertions.assert_equal(machine.memory.read_u16(0x144), 0xfff9, "SetEventMask writes SysEvtMask") and ok
	events.post_mouse(Vector2i(10, 30), true)
	events.post_mouse(Vector2i(10, 30), false)
	events.post_key(0x24, 13, true, false, 0)
	ok = Assertions.assert_equal(_whats(events), [3], "the flight mask drops mouse down / up, keeps keys") and ok
	set_mask.call([0xffff])
	events.post_mouse(Vector2i(10, 30), true)
	ok = Assertions.assert_equal(_whats(events), [1], "every event again once the mask is 0xffff") and ok
	machine.low_memory()
	ok = Assertions.assert_equal(machine.memory.read_u16(0x144), 0xffff, "low_memory keeps the game's mask") and ok
	return run_idle() and ok

func _whats(events) -> Array:
	var out: Array = []
	while true:
		var e: Dictionary = events.next_event(0xffff, true)
		if int(e["what"]) == 0 or int(e["what"]) >= 6:
			break
		out.append(int(e["what"]))
	return out

## Null events: the first two polls of a tick return at once (the flight loop's two a frame); a
## tight idle loop beyond that sleeps.
func run_idle() -> bool:
	var machine = MacMachine.new()
	var events = machine.toolbox.events
	var start: int = Time.get_ticks_usec()
	events.next_event(0xffff, true)
	events.next_event(0xffff, true)
	var two: int = Time.get_ticks_usec() - start
	start = Time.get_ticks_usec()
	for k in 8:
		events.next_event(0xffff, true)
	var eight: int = Time.get_ticks_usec() - start
	var ok := Assertions.assert_true(two < 1500, "two null polls return at once (%d us)" % two)
	return Assertions.assert_true(eight >= 6000, "a tight loop of null polls sleeps (%d us)" % eight) and ok
