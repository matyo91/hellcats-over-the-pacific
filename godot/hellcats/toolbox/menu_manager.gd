extends RefCounted

## The Menu Manager: menus are their MENU resources' handles (MenuInfo: menuID +0, menuWidth +2,
## menuHeight +4, menuProc +6, enableFlags +0xa, the title +0xe, then the items: text, icon, key,
## mark, style), the menu bar the list InsertMenu builds. DrawMenuBar draws the titles in the system
## font (character 0x14 the Apple logo); MenuSelect pulls a menu down under the mouse while the
## button is held, saving and restoring the screen under it, and returns menuID << 16 | item;
## MenuKey finds a command key among the enabled items.

const BAR_LEFT := 10
const TITLE_GAP := 13
const ROW := 16

var machine
var memory
var qd
var events
var menus: Array = []          ## menu handles, left to right
var hilited: int = 0

func _init(owner, toolbox) -> void:
	machine = owner
	memory = owner.memory
	qd = toolbox.quickdraw
	events = toolbox.events

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa9bf, func(a: Array) -> int:                                       ## GetMenu(id)
		return machine.toolbox.resources.get_resource("MENU", qd.s16(a[0])))
	t.install(0xa935, func(a: Array) -> int:                                       ## InsertMenu(menu, beforeID)
		var h: int = a[1] & 0xffffffff
		if not menus.has(h):
			menus.append(h)
		return 0)
	t.install(0xa936, func(a: Array) -> int:                                       ## DeleteMenu(id)
		var h: int = _menu(a[0])
		menus.erase(h)
		return 0)
	t.install(0xa94d, func(_a: Array) -> int: return 0)                            ## AddResMenu: no desk accessories
	t.install(0xa937, func(_a: Array) -> int:                                       ## DrawMenuBar
		draw_menu_bar()
		return 0)
	t.install(0xa938, func(a: Array) -> int:                                       ## HiliteMenu(id)
		hilited = qd.s16(a[0])
		draw_menu_bar()
		return 0)
	t.install(0xa939, func(a: Array) -> int: return _enable(a[1], a[0], true))     ## EnableItem(menu, item)
	t.install(0xa93a, func(a: Array) -> int: return _enable(a[1], a[0], false))    ## DisableItem(menu, item)
	t.install(0xa945, func(a: Array) -> int:                                       ## CheckItem(menu, item, checked)
		var at: int = _item_at(a[2], a[1])
		if at >= 0:
			memory.write_u8(at + 2, 0x12 if (a[0] & 0xff00) != 0 or (a[0] & 0xff) != 0 else 0)
		return 0)
	t.install(0xa944, func(a: Array) -> int:                                       ## SetItemMark(menu, item, mark)
		var at: int = _item_at(a[2], a[1])
		if at >= 0:
			memory.write_u8(at + 2, a[0] & 0xff)
		return 0)
	t.install(0xa949, func(a: Array) -> int: return _menu(a[0]))                   ## GetMHandle(id)
	t.install(0xa950, func(a: Array) -> int: return _items(a[0]).size())           ## CountMItems
	t.install(0xa946, func(a: Array) -> int:                                       ## GetItem(menu, item, VAR text)
		var items: Array = _items(a[2])
		var i: int = qd.s16(a[1]) - 1
		if i >= 0 and i < items.size():
			var start: int = items[i]
			for k in memory.read_u8(start) + 1:
				memory.write_u8(a[0] + k, memory.read_u8(start + k))
		return 0)
	t.install(0xa93d, func(a: Array) -> int: return menu_select(a[0]))             ## MenuSelect(pt): long
	t.install(0xa93e, func(a: Array) -> int: return menu_key(a[0] & 0xff))         ## MenuKey(ch): long
	t.install(0xa94c, func(_a: Array) -> int: return 0)                            ## FlashMenuBar
	t.install(0xa93b, func(_a: Array) -> int: return 0)                            ## GetMenuBar (unused)

func _menu(id: int) -> int:
	for h in menus:
		if memory.read_s16(memory.read_u32(h)) == qd.s16(id):
			return h
	return 0

## The addresses of a menu's items (each its text's length byte).
func _items(h: int) -> Array:
	var out: Array = []
	var p: int = memory.read_u32(h & 0xffffffff)
	var at: int = p + 0xe + memory.read_u8(p + 0xe) + 1
	while memory.read_u8(at) != 0:
		out.append(at)
		at += memory.read_u8(at) + 1 + 4
	return out

## The address of an item's four attribute bytes (icon, key, mark, style), or -1.
func _item_at(h: int, item: int) -> int:
	var items: Array = _items(h)
	var i: int = qd.s16(item) - 1
	if i < 0 or i >= items.size():
		return -1
	return items[i] + memory.read_u8(items[i]) + 1

func _enable(h: int, item: int, on: bool) -> int:
	var p: int = memory.read_u32(h & 0xffffffff)
	var flags: int = memory.read_u32(p + 0xa)
	var bit: int = 1 << (qd.s16(item) & 31)
	memory.write_u32(p + 0xa, (flags | bit) if on else (flags & ~bit))
	if qd.s16(item) == 0:
		draw_menu_bar()
	return 0

func _enabled(h: int, item: int) -> bool:
	var flags: int = memory.read_u32(memory.read_u32(h) + 0xa)
	return (flags & 1) != 0 and (item > 31 or ((flags >> item) & 1) != 0)

func _title(h: int) -> PackedByteArray:
	var p: int = memory.read_u32(h)
	var out := PackedByteArray()
	for k in memory.read_u8(p + 0xe):
		out.append(memory.read_u8(p + 0xf + k))
	return out

func _text(at: int) -> PackedByteArray:
	var out := PackedByteArray()
	for k in memory.read_u8(at):
		out.append(memory.read_u8(at + 1 + k))
	return out

## The titles' extents across the bar: [handle, left, right].
func _layout() -> Array:
	var out: Array = []
	var x: int = BAR_LEFT
	for h in menus:
		var w: int = qd.glyphs.width(_title(h), 0, 12, 0)
		out.append([h, x - 6, x + w + 7])
		x += w + TITLE_GAP
	return out

func draw_menu_bar() -> void:
	var port: int = qd.window_manager_port()
	var white := [0, 0, 0, 0, 0, 0, 0, 0]
	var bar: int = machine.MENU_BAR_HEIGHT
	qd.fill_rect(port, Rect2i(0, 0, machine.SCREEN_WIDTH, bar - 1), white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
	memory.write_u16(port + 0x44, 0)
	memory.write_u16(port + 0x4a, 12)
	for t in _layout():
		var h: int = t[0]
		var on: bool = memory.read_s16(memory.read_u32(h)) == hilited and hilited != 0
		if on:
			qd.fill_rect(port, Rect2i(t[1], 0, t[2] - t[1], bar - 1), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], qd.PAT_COPY, qd.BLACK, qd.WHITE)
		qd.set_pen_loc(port, Vector2i(t[1] + 6, 14))
		var dim: bool = (memory.read_u32(memory.read_u32(h) + 0xa) & 1) == 0
		_draw_label(port, _title(h), qd.WHITE if on else (128 if dim else qd.BLACK))

## Text at the pen in the system font, in one palette index (black, white on a highlight, grey dimmed).
func _draw_label(port: int, text: PackedByteArray, colour: int) -> void:
	var pen: Vector2i = qd.pen_loc(port)
	var bits: Array = qd.port_bits(port)
	var x: int = pen.x
	for c in text:
		var g: Dictionary = qd.glyphs.glyph(c, 0, 12, 0)
		for row in g["bits"].size():
			for col in g["bits"][row].size():
				if g["bits"][row][col]:
					qd._plot(bits, x + g["left"] + col, pen.y + g["top"] + row, true, qd.SRC_OR, colour, qd.WHITE)
		x += g["advance"]
	qd.set_pen_loc(port, Vector2i(x, pen.y))

## Pulls the menu under the mouse down while the button is held; the chosen item, or 0.
func menu_select(_pt: int) -> int:
	var result: int = 0
	var open: int = -1
	var saved := PackedByteArray()
	var box := Rect2i()
	var choice: int = 0
	while true:
		var p: Vector2i = events.mouse_position()
		var layout: Array = _layout()
		if p.y < machine.MENU_BAR_HEIGHT:
			for i in layout.size():
				if p.x >= layout[i][1] and p.x < layout[i][2] and i != open:
					if open >= 0:
						_restore(saved, box)
					open = i
					hilited = memory.read_s16(memory.read_u32(layout[i][0]))
					draw_menu_bar()
					box = _menu_box(layout[i])
					saved = _save(box)
					choice = 0
					_draw_menu(layout[i][0], box, 0)
		elif open >= 0:
			var h: int = layout[open][0]
			var row: int = (p.y - box.position.y - 1) / ROW + 1 if box.has_point(p) else 0
			if row > _items(h).size():
				row = 0
			if row != choice:
				choice = row
				_draw_menu(h, box, choice)
		if not events.is_button_down():
			if open >= 0:
				var h2: int = layout[open][0]
				_restore(saved, box)
				if choice > 0 and _enabled(h2, choice) and _text(_items(h2)[choice - 1]) != PackedByteArray([0x2d]):
					result = (memory.read_s16(memory.read_u32(h2)) << 16) | choice
			break
		machine.idle(10)
	events.flush_mouse_ups()
	if result == 0:
		hilited = 0
		draw_menu_bar()
	return result & 0xffffffff

func _menu_box(t: Array) -> Rect2i:
	var h: int = t[0]
	var widest: int = 0
	for at in _items(h):
		var w: int = qd.glyphs.width(_text(at), 0, 12, 0)
		if memory.read_u8(at + memory.read_u8(at) + 2) > 0x20:
			w += 30
		widest = maxi(widest, w)
	return Rect2i(t[1], machine.MENU_BAR_HEIGHT - 1, widest + 34, _items(h).size() * ROW + 2)

func _save(box: Rect2i) -> PackedByteArray:
	var out := PackedByteArray()
	for y in range(box.position.y, mini(box.end.y + 1, machine.SCREEN_HEIGHT)):
		for x in range(box.position.x, mini(box.end.x + 1, machine.SCREEN_WIDTH)):
			out.append(memory.read_u8(machine.SCREEN_BASE + y * machine.SCREEN_WIDTH + x))
	return out

func _restore(saved: PackedByteArray, box: Rect2i) -> void:
	var i: int = 0
	for y in range(box.position.y, mini(box.end.y + 1, machine.SCREEN_HEIGHT)):
		for x in range(box.position.x, mini(box.end.x + 1, machine.SCREEN_WIDTH)):
			memory.write_u8(machine.SCREEN_BASE + y * machine.SCREEN_WIDTH + x, saved[i])
			i += 1

func _draw_menu(h: int, box: Rect2i, choice: int) -> void:
	var port: int = qd.window_manager_port()
	var white := [0, 0, 0, 0, 0, 0, 0, 0]
	var black := [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
	qd.fill_rect(port, Rect2i(box.position + Vector2i(1, 1), box.size), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
	qd.fill_rect(port, box, white, qd.PAT_COPY, qd.BLACK, qd.WHITE)
	memory.write_u32(port + 0x34, 0x00010001)
	qd.frame_rect(port, box)
	var y: int = box.position.y + 1
	var items: Array = _items(h)
	for i in items.size():
		var at: int = items[i]
		var text: PackedByteArray = _text(at)
		var attrs: int = at + memory.read_u8(at) + 1
		var on: bool = choice == i + 1 and _enabled(h, i + 1) and text != PackedByteArray([0x2d])
		if on:
			qd.fill_rect(port, Rect2i(box.position.x + 1, y, box.size.x - 2, ROW), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
		if text == PackedByteArray([0x2d]):
			for x in range(box.position.x + 1, box.end.x - 1, 2):
				qd.fill_rect(port, Rect2i(x, y + ROW / 2, 1, 1), black, qd.PAT_COPY, qd.BLACK, qd.WHITE)
		else:
			var colour: int = qd.WHITE if on else (qd.BLACK if _enabled(h, i + 1) else 128)
			if memory.read_u8(attrs + 2) != 0:
				qd.set_pen_loc(port, Vector2i(box.position.x + 3, y + 12))
				_draw_label(port, PackedByteArray([memory.read_u8(attrs + 2)]), colour)
			qd.set_pen_loc(port, Vector2i(box.position.x + 14, y + 12))
			_draw_label(port, text, colour)
			var key: int = memory.read_u8(attrs + 1)
			if key > 0x20:
				var label := PackedByteArray([0x11, key])
				qd.set_pen_loc(port, Vector2i(box.end.x - 8 - qd.glyphs.width(label, 0, 12, 0), y + 12))
				_draw_label(port, label, colour)
		y += ROW

func menu_key(ch: int) -> int:
	var upper: int = ch - 0x20 if ch >= 0x61 and ch <= 0x7a else ch
	for h in menus:
		var items: Array = _items(h)
		for i in items.size():
			var attrs: int = items[i] + memory.read_u8(items[i]) + 1
			if memory.read_u8(attrs + 1) == upper and _enabled(h, i + 1):
				hilited = memory.read_s16(memory.read_u32(h))
				draw_menu_bar()
				return ((hilited << 16) | (i + 1)) & 0xffffffff
	return 0
