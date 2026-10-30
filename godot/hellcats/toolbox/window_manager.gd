extends RefCounted

## The Window Manager: windows as their records in memory (a GrafPort or CGrafPort, then windowKind
## +0x6c, visible +0x6e, hilited +0x6f, goAwayFlag +0x70, strucRgn +0x72, contRgn +0x76, updateRgn
## +0x7a, windowDefProc +0x7e (the procID here), titleHandle +0x86, nextWindow +0x90, refCon +0x98),
## kept front to back. A window's port draws through its bitmap's bounds: global = local - bounds'
## top left, so the bounds' top left is minus the window's global position. Frames follow the
## System 7 black-and-white window definitions; the screen is redrawn whole (desktop, menu bar,
## every visible window back to front) when windows move or go, and the windows whose content was
## covered get update events.

const RECORD := 0x9c
const DIALOG_RECORD := 0xaa
## FindWindow parts.
const IN_DESK := 0
const IN_MENU_BAR := 1
const IN_CONTENT := 3
const IN_DRAG := 4
const IN_GO_AWAY := 6

var machine
var memory
var qd
var heap
var windows: Array = []           ## front to back
var _updates: Array = []          ## windows awaiting an update event
var _activates: Array = []        ## [window, active]
var on_redraw: Callable           ## the Dialog Manager redraws dialogs (they have no update events of their own)

func _init(owner, quickdraw, memory_manager) -> void:
	machine = owner
	memory = owner.memory
	qd = quickdraw
	heap = memory_manager

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa912, func(_a: Array) -> int:                                               ## InitWindows
		qd.draw_desktop()
		return 0)
	t.install(0xa913, func(a: Array) -> int:                                                ## NewWindow
		return new_window(a[7], qd.rect_arg(a[6]), qd.pstr_arg(a[5]), (a[4] & 0xff00) != 0 or (a[4] & 0xff) != 0, a[3], a[2], a[1] != 0, a[0], false))
	t.install(0xaa45, func(a: Array) -> int:                                                ## NewCWindow
		return new_window(a[7], qd.rect_arg(a[6]), qd.pstr_arg(a[5]), (a[4] & 0xff00) != 0 or (a[4] & 0xff) != 0, a[3], a[2], a[1] != 0, a[0], true))
	t.install(0xa915, func(a: Array) -> int: return show(a[0], true))                       ## ShowWindow
	t.install(0xa916, func(a: Array) -> int: return show(a[0], false))                      ## HideWindow
	t.install(0xa91f, func(a: Array) -> int: return select(a[0]))                            ## SelectWindow
	t.install(0xa910, func(a: Array) -> int: return bring_to_front(a[0]))                    ## BringToFront
	t.install(0xa914, func(a: Array) -> int: return dispose(a[0]))                           ## DisposeWindow
	t.install(0xa92d, func(a: Array) -> int: return dispose(a[0]))                           ## CloseWindow
	t.install(0xa924, func(_a: Array) -> int: return front_window())                         ## FrontWindow
	t.install(0xa91b, func(a: Array) -> int:                                                ## MoveWindow(w, h, v, front)
		move(a[3], Vector2i(qd.s16(a[2]), qd.s16(a[1])))
		return 0)
	t.install(0xa91d, func(a: Array) -> int:                                                ## SizeWindow(w, width, height, update)
		resize(a[3], Vector2i(qd.s16(a[2]), qd.s16(a[1])))
		return 0)
	t.install(0xa92c, func(a: Array) -> int: return find_window(a[1], a[0]))                ## FindWindow(pt, VAR w): part
	t.install(0xa922, func(a: Array) -> int:                                                ## BeginUpdate
		_updates.erase(a[0] & 0xffffffff)
		return 0)
	t.install(0xa923, func(_a: Array) -> int: return 0)                                     ## EndUpdate
	t.install(0xa928, func(_a: Array) -> int:                                                ## InvalRect(r)
		invalidate(qd.the_port())
		return 0)
	t.install(0xa927, func(_a: Array) -> int:                                                ## InvalRgn
		invalidate(qd.the_port())
		return 0)
	t.install(0xa929, func(_a: Array) -> int: return 0)                                     ## ValidRgn
	t.install(0xa92a, func(_a: Array) -> int: return 0)                                     ## ValidRect
	t.install(0xa904, func(_a: Array) -> int: return 0)                                     ## DrawGrowIcon
	t.install(0xa91e, func(_a: Array) -> int: return 0x100)                                 ## TrackGoAway: true
	t.install(0xa925, func(_a: Array) -> int: return 0)                                     ## DragWindow
	t.install(0xa917, func(a: Array) -> int: return memory.read_u32(a[0] + 0x98))           ## GetWRefCon
	t.install(0xa918, func(a: Array) -> int:                                                ## SetWRefCon(w, data)
		memory.write_u32(a[1] + 0x98, a[0] & 0xffffffff)
		return 0)
	t.install(0xa91a, func(a: Array) -> int:                                                ## SetWTitle(w, title)
		_set_title(a[1], qd.pstr_arg(a[0]))
		redraw_screen()
		return 0)
	t.install(0xa919, func(a: Array) -> int:                                                ## GetWTitle(w, VAR title)
		var h: int = memory.read_u32(a[1] + 0x86)
		var p: int = memory.read_u32(h)
		for k in memory.read_u8(p) + 1:
			memory.write_u8(a[0] + k, memory.read_u8(p + k))
		return 0)

## A new window: its record (allocated when `storage` is 0), its port over the screen, at `bounds`
## (global, the content), procID, before the `behind` window (-1: in front).
func new_window(storage: int, bounds: Rect2i, title: PackedByteArray, visible: bool, proc_id: int, behind: int, go_away: bool,
		refcon: int, color: bool, kind: int = 8, size: int = RECORD) -> int:
	var w: int = storage & 0xffffffff
	if w == 0:
		w = heap.new_ptr(size, true)
	for k in size:
		memory.write_u8(w + k, 0)
	qd.init_port(w, color)
	qd.write_rect(w + 0x10, Rect2i(Vector2i.ZERO, bounds.size))
	_set_origin(w, bounds.position)
	qd.set_region(memory.read_u32(w + 0x18), Rect2i(Vector2i.ZERO, bounds.size))
	memory.write_u16(w + 0x6c, kind)
	memory.write_u8(w + 0x70, 1 if go_away else 0)
	memory.write_u32(w + 0x72, qd.new_region(bounds))
	memory.write_u32(w + 0x76, qd.new_region(bounds))
	memory.write_u32(w + 0x7a, qd.new_region(Rect2i()))
	memory.write_u32(w + 0x7e, proc_id & 0xffff)
	memory.write_u32(w + 0x98, refcon & 0xffffffff)
	_set_title(w, title)
	if (behind & 0xffffffff) == 0:
		windows.append(w)
	else:
		windows.push_front(w)
	if visible:
		show(w, true)
	return w

func _set_title(w: int, title: PackedByteArray) -> void:
	var h: int = memory.read_u32(w + 0x86)
	if h == 0:
		h = heap.new_handle(256, true)
		memory.write_u32(w + 0x86, h)
	var p: int = memory.read_u32(h)
	memory.write_u8(p, title.size())
	for k in title.size():
		memory.write_u8(p + 1 + k, title[k])

## The window's content rect on the screen.
func content(w: int) -> Rect2i:
	var origin: Vector2i = -qd.port_bits(w)[2].position
	return Rect2i(origin, qd.read_rect(w + 0x10).size)

func _set_origin(w: int, global: Vector2i) -> void:
	var at: int = w + 8 if not qd.is_color(memory, w) else memory.read_u32(memory.read_u32(w + 2)) + 6
	qd.write_rect(at, Rect2i(-global - qd.read_rect(w + 0x10).position, Vector2i(machine.SCREEN_WIDTH, machine.SCREEN_HEIGHT)))

func is_visible(w: int) -> bool:
	return memory.read_u8(w + 0x6e) != 0

func front_window() -> int:
	for w in windows:
		if is_visible(w):
			return w
	return 0

func show(w: int, visible: bool) -> int:
	w &= 0xffffffff
	if is_visible(w) == visible:
		return 0
	memory.write_u8(w + 0x6e, 1 if visible else 0)
	if visible:
		_draw_window(w, true)
		invalidate(w)
		_activates.append([w, true])
	else:
		redraw_screen()
	return 0

func bring_to_front(w: int) -> int:
	w &= 0xffffffff
	windows.erase(w)
	windows.push_front(w)
	if is_visible(w):
		_draw_window(w, true)
		invalidate(w)
	return 0

func select(w: int) -> int:
	bring_to_front(w)
	_activates.append([w & 0xffffffff, true])
	return 0

func dispose(w: int) -> int:
	windows.erase(w & 0xffffffff)
	_updates.erase(w & 0xffffffff)
	redraw_screen()
	return 0

func move(w: int, to: Vector2i) -> void:
	w &= 0xffffffff
	_set_origin(w, to)
	qd.set_region(memory.read_u32(w + 0x76), content(w))
	if is_visible(w):
		redraw_screen()

func resize(w: int, size: Vector2i) -> void:
	w &= 0xffffffff
	var r: Rect2i = qd.read_rect(w + 0x10)
	qd.write_rect(w + 0x10, Rect2i(r.position, size))
	qd.set_region(memory.read_u32(w + 0x18), Rect2i(r.position, size))
	qd.set_region(memory.read_u32(w + 0x76), content(w))
	if is_visible(w):
		redraw_screen()

func invalidate(w: int) -> void:
	w &= 0xffffffff
	if windows.has(w) and not _updates.has(w):
		_updates.append(w)

## The whole screen again: desktop, menu bar, every visible window back to front (their contents
## invalidated, so the program redraws them on its update events).
func redraw_screen() -> void:
	qd.draw_desktop()
	if machine.toolbox.menus != null:
		machine.toolbox.menus.draw_menu_bar()
	for i in range(windows.size() - 1, -1, -1):
		var w: int = windows[i]
		if is_visible(w):
			_draw_window(w, true)
			invalidate(w)
	if on_redraw.is_valid():
		on_redraw.call()

## The frame of the window's procID around its content, and the content erased.
func _draw_window(w: int, erase: bool) -> void:
	var port: int = qd.window_manager_port()
	var c: Rect2i = content(w)
	var proc: int = memory.read_u32(w + 0x7e) & 0xffff
	var white := [0, 0, 0, 0, 0, 0, 0, 0]
	var black := [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
	match proc & ~8:
		1:
			qd.fill_rect(port, c.grow(8), white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			_frame(port, c.grow(8), 1)
			_frame(port, c.grow(6), 2)
		2:
			qd.fill_rect(port, c.grow(1), white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			_frame(port, c.grow(1), 1)
		3:
			qd.fill_rect(port, Rect2i(c.position + Vector2i(1, 1), c.size + Vector2i(2, 2)), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			qd.fill_rect(port, c.grow(1), white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			_frame(port, c.grow(1), 1)
		_:
			var bar := Rect2i(c.position.x - 1, c.position.y - 19, c.size.x + 2, 19)
			qd.fill_rect(port, Rect2i(c.position + Vector2i(1, 1), c.size + Vector2i(1, 1)), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			qd.fill_rect(port, c.grow(1), white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			_frame(port, c.grow(1), 1)
			qd.fill_rect(port, bar, white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			_frame(port, bar, 1)
			for k in 6:
				qd.fill_rect(port, Rect2i(bar.position.x + 2, bar.position.y + 4 + 2 * k, bar.size.x - 4, 1), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
			var title: PackedByteArray = _title(w)
			if title.size() > 0:
				var tw: int = qd.glyphs.width(title, 0, 12, 0)
				var tx: int = bar.position.x + (bar.size.x - tw) / 2
				qd.fill_rect(port, Rect2i(tx - 6, bar.position.y + 1, tw + 12, 17), white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
				qd.set_pen_loc(port, Vector2i(tx, bar.position.y + 14))
				memory.write_u16(port + 0x44, 0)
				memory.write_u16(port + 0x4a, 12)
				qd.draw_text(port, title)
	if erase:
		qd.fill_rect(port, c, white, qd.PAT_COPY, qd.BLACK, qd.WHITE)

func _frame(port: int, r: Rect2i, thickness: int) -> void:
	var black := [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
	qd.fill_rect(port, Rect2i(r.position, Vector2i(r.size.x, thickness)), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
	qd.fill_rect(port, Rect2i(r.position.x, r.end.y - thickness, r.size.x, thickness), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
	qd.fill_rect(port, Rect2i(r.position, Vector2i(thickness, r.size.y)), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
	qd.fill_rect(port, Rect2i(r.end.x - thickness, r.position.y, thickness, r.size.y), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)

func _title(w: int) -> PackedByteArray:
	var out := PackedByteArray()
	var h: int = memory.read_u32(w + 0x86)
	if h == 0:
		return out
	var p: int = memory.read_u32(h)
	for k in memory.read_u8(p):
		out.append(memory.read_u8(p + 1 + k))
	return out

func find_window(pt: int, out: int) -> int:
	var p := Vector2i(qd.s16(pt), qd.s16(pt >> 16))
	memory.write_u32(out, 0)
	if p.y < machine.MENU_BAR_HEIGHT:
		return IN_MENU_BAR
	for w in windows:
		if not is_visible(w):
			continue
		var c: Rect2i = content(w)
		if c.has_point(p):
			memory.write_u32(out, w)
			return IN_CONTENT
		var proc: int = memory.read_u32(w + 0x7e) & 0xffff
		if (proc & ~8) in [0, 4, 16] and Rect2i(c.position.x - 1, c.position.y - 19, c.size.x + 2, 19).has_point(p):
			memory.write_u32(out, w)
			return IN_DRAG
	return IN_DESK

## An update or activate event the mask accepts, for the Event Manager.
func pending_event(mask: int, take: bool) -> Dictionary:
	if (mask >> 8) & 1 and not _activates.is_empty():
		var a: Array = _activates[0]
		if take:
			_activates.remove_at(0)
		return {"what": 8, "message": a[0], "where": Vector2i.ZERO, "modifiers": 1 if a[1] else 0, "when": machine.ticks()}
	if (mask >> 6) & 1 and not _updates.is_empty():
		var w: int = _updates[0]
		if take:
			_updates.remove_at(0)
		return {"what": 6, "message": w, "where": Vector2i.ZERO, "modifiers": 0, "when": machine.ticks()}
	return {}
