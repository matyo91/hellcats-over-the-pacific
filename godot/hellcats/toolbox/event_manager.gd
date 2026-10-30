extends RefCounted

## The Event Manager: an event queue fed by Godot's input on the main thread (post_* below) and read
## by the game thread through GetNextEvent / WaitNextEvent / EventAvail, with the mouse and the
## button for GetMouse / Button / StillDown and the keyboard map for GetKeys. Update and activate
## events come from the Window Manager when the queue holds nothing else. EventRecord: what +0,
## message +2, when +6, where +0xa (v, h, global), modifiers +0xe.

const NULL_EVENT := 0
const MOUSE_DOWN := 1
const MOUSE_UP := 2
const KEY_DOWN := 3
const KEY_UP := 4
const AUTO_KEY := 5
const UPDATE_EVT := 6
const ACTIVATE_EVT := 8
## Modifier bits.
const ACTIVE_FLAG := 0x1
const BTN_STATE := 0x80
const CMD_KEY := 0x100
const SHIFT_KEY := 0x200
const ALPHA_LOCK := 0x400
const OPTION_KEY := 0x800
const CONTROL_KEY := 0x1000

var machine
var memory
var windows
var _lock := Mutex.new()
var _queue: Array = []
var mouse := Vector2i(320, 240)
var button := false
var modifiers: int = 0
var keymap := PackedByteArray()
## Set when the program exits (ExitToShell): the game thread then waits for the scene to end.
var stopping := false

func _init(owner) -> void:
	machine = owner
	memory = owner.memory
	keymap.resize(16)

# ---- the main thread's side ---------------------------------------------------------------------------

func post(what: int, message: int, where: Vector2i, mods: int) -> void:
	_lock.lock()
	_queue.append({"what": what, "message": message, "where": where, "modifiers": mods, "when": machine.ticks()})
	_lock.unlock()

func post_mouse(where: Vector2i, down: bool) -> void:
	_lock.lock()
	mouse = where
	button = down
	_lock.unlock()
	post(MOUSE_DOWN if down else MOUSE_UP, 0, where, modifiers | (0 if down else BTN_STATE))

func move_mouse(where: Vector2i) -> void:
	_lock.lock()
	mouse = where
	_lock.unlock()

## A key: its Mac virtual key code and character, down / up / repeat.
func post_key(key_code: int, char_code: int, down: bool, repeat: bool, mods: int) -> void:
	_lock.lock()
	modifiers = mods
	if key_code >= 0 and key_code < 128:
		var byte: int = key_code >> 3
		var bit: int = 1 << (key_code & 7)
		keymap[byte] = (keymap[byte] | bit) if down else (keymap[byte] & ~bit)
	_lock.unlock()
	var what: int = (AUTO_KEY if repeat else KEY_DOWN) if down else KEY_UP
	post(what, ((key_code & 0xff) << 8) | (char_code & 0xff), mouse, mods | (0 if button else BTN_STATE))

# ---- the game thread's side --------------------------------------------------------------------------

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa970, func(a: Array) -> int: return get_next_event(a[1], a[0], true))       ## GetNextEvent(mask, VAR evt)
	t.install(0xa971, func(a: Array) -> int: return get_next_event(a[1], a[0], false))      ## EventAvail(mask, VAR evt)
	t.install(0xa860, func(a: Array) -> int: return get_next_event(a[3], a[2], true))       ## WaitNextEvent(mask, VAR evt, sleep, rgn)
	t.install(0xa974, func(_a: Array) -> int: return 0x100 if is_button_down() else 0)       ## Button
	t.install(0xa973, func(_a: Array) -> int:                                                ## StillDown
		return 0x100 if is_button_down() and not has_mouse_up() else 0)
	t.install(0xa977, func(_a: Array) -> int:                                                ## WaitMouseUp
		var up: bool = not is_button_down()
		if up:
			flush_mouse_ups()
		return 0 if up else 0x100)
	t.install(0xa972, func(a: Array) -> int:                                                 ## GetMouse(VAR pt): local
		var origin: Vector2i = machine.toolbox.quickdraw.port_bits(machine.toolbox.quickdraw.the_port())[2].position
		var p: Vector2i = mouse_position() + origin
		memory.write_u16(a[0], p.y & 0xffff)
		memory.write_u16(a[0] + 2, p.x & 0xffff)
		return 0)
	t.install(0xa976, func(a: Array) -> int:                                                 ## GetKeys(VAR map)
		_lock.lock()
		for k in 16:
			memory.write_u8(a[0] + k, keymap[k])
		_lock.unlock()
		return 0)
	t.install(0xa9b4, func(_a: Array) -> int: return 0)                                      ## SystemTask
	t.install(0xa975, func(_a: Array) -> int: return machine.ticks())                        ## TickCount
	t.install(0xa032, func(_a: Array) -> int:                                                ## FlushEvents
		_lock.lock()
		_queue.clear()
		_lock.unlock()
		return 0)

func mouse_position() -> Vector2i:
	_lock.lock()
	var p: Vector2i = mouse
	_lock.unlock()
	return p

func is_button_down() -> bool:
	_lock.lock()
	var b: bool = button
	_lock.unlock()
	return b

func has_mouse_up() -> bool:
	_lock.lock()
	var found := false
	for e in _queue:
		if e["what"] == MOUSE_UP:
			found = true
	_lock.unlock()
	return found

func flush_mouse_ups() -> void:
	_lock.lock()
	_queue = _queue.filter(func(e): return e["what"] != MOUSE_UP)
	_lock.unlock()

## The first queued event the mask accepts (removed when `take`), else an update or activate event
## from the Window Manager, else a null event (after a short sleep, so polling loops idle).
func next_event(mask: int, take: bool) -> Dictionary:
	_lock.lock()
	var found: Dictionary = {}
	for i in _queue.size():
		var e: Dictionary = _queue[i]
		if (mask >> e["what"]) & 1:
			found = e
			if take:
				_queue.remove_at(i)
			break
	_lock.unlock()
	if found.is_empty() and windows != null:
		found = windows.pending_event(mask, take)
	if found.is_empty():
		machine.idle(2)
		found = {"what": NULL_EVENT, "message": 0, "where": mouse_position(), "modifiers": modifiers | (0 if is_button_down() else BTN_STATE),
				"when": machine.ticks()}
	return found

func write_event(at: int, e: Dictionary) -> void:
	memory.write_u16(at, e["what"])
	memory.write_u32(at + 2, e["message"] & 0xffffffff)
	memory.write_u32(at + 6, e["when"] & 0xffffffff)
	memory.write_u16(at + 0xa, e["where"].y & 0xffff)
	memory.write_u16(at + 0xc, e["where"].x & 0xffff)
	memory.write_u16(at + 0xe, e["modifiers"] & 0xffff)

func get_next_event(mask: int, at: int, take: bool) -> int:
	while stopping:
		machine.idle(100)
	var e: Dictionary = next_event(mask & 0xffff, take)
	write_event(at, e)
	return 0x100 if e["what"] != NULL_EVENT else 0
