extends RefCounted

## The Dialog Manager and the Control Manager's part the dialogs use. A dialog is a window record
## (windowKind 2) plus items +0x9c (its item list's handle), textH +0xa0, editField +0xa4, aDefItem
## +0xa8; its items are decoded from the DITL bytes (godot/strict_port/ui/dialog_templates.gd) and
## each gets a handle as GetDItem returns it: a control record for buttons, check boxes and radio
## buttons (contrlRect +8, contrlVis +0x10, contrlHilite +0x11, contrlValue +0x12, contrlMin +0x14,
## contrlMax +0x16, contrlTitle +0x28), a text handle for static and edit text, the picture / icon
## resource for those, and for user items the procedure SetDItem installs (called back with
## (dialog, item) to draw). ModalDialog reads events, gives them to the filter procedure first
## (called with (dialog, event, VAR itemHit) in that order; nonzero means handled) and otherwise
## handles typing in the edit field, Return / Enter for the default item and clicks on enabled items.
## Alerts (Alert, StopAlert, NoteAlert, CautionAlert) are the same over an ALRT and its stages.

const Templates := preload("res://strict_port/ui/dialog_templates.gd")
const Files := preload("res://strict_port/ui/resource_files.gd")

const DIALOG_KIND := 2
const BUTTON := 4
const CHECKBOX := 5
const RADIO := 6
const STATIC_TEXT := 8
const EDIT_TEXT := 16
const ICON := 32
const PICTURE := 64
const USER_ITEM := 0

var machine
var memory
var qd
var heap
var windows
var events
var params: Array = [PackedByteArray(), PackedByteArray(), PackedByteArray(), PackedByteArray()]
var dialogs: Dictionary = {}          ## dialog -> {items: [...], edit: index, default: index}
var _controls: Dictionary = {}        ## control handle -> [dialog, item index]
var _standalone: Dictionary = {}      ## NewControl's control handle -> its window

func _init(owner, toolbox) -> void:
	machine = owner
	memory = owner.memory
	qd = toolbox.quickdraw
	heap = toolbox.heap
	windows = toolbox.windows
	events = toolbox.events
	windows.on_redraw = func() -> void:
		for d in dialogs:
			if windows.is_visible(d):
				draw_dialog(d)

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa97c, func(a: Array) -> int: return get_new_dialog(a[2], a[1], a[0]))        ## GetNewDialog(id, storage, behind)
	t.install(0xa98b, func(a: Array) -> int:                                                  ## ParamText(s0, s1, s2, s3)
		for k in 4:
			params[k] = qd.pstr_arg(a[3 - k])
		return 0)
	t.install(0xa981, func(a: Array) -> int: return draw_dialog(a[0]))                        ## DrawDialog
	t.install(0xa978, func(a: Array) -> int: return draw_dialog(a[1]))                        ## UpdtDialog(dialog, rgn)
	t.install(0xa983, func(a: Array) -> int: return dispose(a[0]))                            ## DisposDialog
	t.install(0xa982, func(a: Array) -> int: return dispose(a[0]))                            ## CloseDialog
	t.install(0xa991, func(a: Array) -> int: return modal_dialog(a[1], a[0]))                 ## ModalDialog(filter, VAR item)
	t.install(0xa98d, func(a: Array) -> int: return get_ditem(a[4], a[3], a[2], a[1], a[0]))  ## GetDItem(d, item, VAR type, VAR h, VAR box)
	t.install(0xa98e, func(a: Array) -> int: return set_ditem(a[4], a[3], a[2], a[1], a[0]))  ## SetDItem(d, item, type, h, box)
	t.install(0xa990, func(a: Array) -> int: return get_itext(a[1], a[0]))                    ## GetIText(h, VAR text)
	t.install(0xa98f, func(a: Array) -> int: return set_itext(a[1], a[0]))                    ## SetIText(h, text)
	t.install(0xa97e, func(a: Array) -> int:                                                  ## SelIText(d, item, start, end)
		set_edit(a[3] & 0xffffffff, qd.s16(a[2]) - 1)
		return 0)
	t.install(0xa984, func(a: Array) -> int: return find_ditem(a[1], a[0]))                   ## FindDItem(d, pt)
	t.install(0xa827, func(_a: Array) -> int: return 0)                                       ## HideDItem
	t.install(0xa828, func(_a: Array) -> int: return 0)                                       ## ShowDItem
	t.install(0xa985, func(a: Array) -> int: return alert(a[1], a[0]))                        ## Alert(id, filter)
	t.install(0xa986, func(a: Array) -> int: return alert(a[1], a[0]))                        ## StopAlert
	t.install(0xa987, func(a: Array) -> int: return alert(a[1], a[0]))                        ## NoteAlert
	t.install(0xa988, func(a: Array) -> int: return alert(a[1], a[0]))                        ## CautionAlert
	t.install(0xa97f, func(a: Array) -> int:                                                  ## IsDialogEvent(event): Boolean
		var w: int = windows.front_window()
		return 0x100 if dialogs.has(w) else 0)
	t.install(0xa960, func(a: Array) -> int: return _ctl(a[0], 0x12))                         ## GetCtlValue
	t.install(0xa961, func(a: Array) -> int: return _ctl(a[0], 0x14))                         ## GetCtlMin
	t.install(0xa962, func(a: Array) -> int: return _ctl(a[0], 0x16))                         ## GetCtlMax
	t.install(0xa963, func(a: Array) -> int: return _set_ctl(a[1], 0x12, a[0]))               ## SetCtlValue(c, v)
	t.install(0xa964, func(a: Array) -> int: return _set_ctl(a[1], 0x14, a[0]))               ## SetCtlMin
	t.install(0xa965, func(a: Array) -> int: return _set_ctl(a[1], 0x16, a[0]))               ## SetCtlMax
	t.install(0xa95d, func(a: Array) -> int:                                                  ## HiliteControl(c, state)
		var c: int = memory.read_u32(a[1])
		memory.write_u8(c + 0x11, a[0] & 0xff)
		_redraw_control(a[1])
		return 0)
	t.install(0xa95e, func(a: Array) -> int:                                                  ## GetCTitle(c, VAR title)
		var c: int = memory.read_u32(a[1])
		for k in memory.read_u8(c + 0x28) + 1:
			memory.write_u8(a[0] + k, memory.read_u8(c + 0x28 + k))
		return 0)
	t.install(0xa969, func(_a: Array) -> int: return 0)                                       ## DrawControls
	t.install(0xa954, func(a: Array) -> int:                                                  ## NewControl(w, r, title, vis, val, min, max, proc, refCon)
		return new_control(a[8], qd.rect_arg(a[7]), qd.pstr_arg(a[6]), a[5] & 0xff00 != 0 or a[5] & 0xff == 1,
				a[4], a[3], a[2], a[1], a[0]))
	t.install(0xa955, func(a: Array) -> int:                                                  ## DisposeControl
		_standalone.erase(a[0] & 0xffffffff)
		return 0)
	t.install(0xa956, func(a: Array) -> int:                                                  ## KillControls(window)
		for h in _standalone.keys():
			if _standalone[h] == a[0] & 0xffffffff:
				_standalone.erase(h)
		return 0)
	t.install(0xa957, func(a: Array) -> int: return _show_control(a[0], true))                ## ShowControl
	t.install(0xa958, func(a: Array) -> int: return _show_control(a[0], false))               ## HideControl
	t.install(0xa95f, func(a: Array) -> int:                                                  ## SetCTitle(c, title)
		var c: int = memory.read_u32(a[1])
		var title: PackedByteArray = qd.pstr_arg(a[0])
		memory.write_u8(c + 0x28, title.size())
		for k in title.size():
			memory.write_u8(c + 0x29 + k, title[k])
		_redraw_control(a[1])
		return 0)
	t.install(0xa96c, func(a: Array) -> int:                                                  ## FindControl(pt, window, VAR c): part
		return find_control(Vector2i(qd.s16(a[2]), qd.s16(a[2] >> 16)), a[1] & 0xffffffff, a[0]))
	t.install(0xa968, func(a: Array) -> int:                                                  ## TrackControl(c, pt, action): part
		return track_control(a[2] & 0xffffffff, Vector2i(qd.s16(a[1]), qd.s16(a[1] >> 16)), a[0] & 0xffffffff))
	t.install(0xa96d, func(a: Array) -> int:                                                  ## Draw1Control
		_redraw_control(a[0])
		return 0)

# ---- dialogs ------------------------------------------------------------------------------------------

## The current edit field: the dialog's state and its record's editField (+0xa4, the item number - 1).
func set_edit(d: int, index: int) -> void:
	if dialogs.has(d):
		dialogs[d]["edit"] = index
		memory.write_u16(d + 0xa4, index & 0xffff)

func get_new_dialog(id: int, storage: int, behind: int) -> int:
	var bytes: PackedByteArray = Files.load_bytes("DLOG", qd.s16(id))
	if bytes.is_empty():
		return 0
	var t: Dictionary = Templates.decode_dlog(bytes)
	var d: int = windows.new_window(storage, t["bounds"], t["title"].to_utf8_buffer(), false, t["proc_id"], behind, t["go_away"],
			t["refcon"], true, DIALOG_KIND, windows.DIALOG_RECORD)
	_attach_items(d, t["ditl_id"])
	if t["visible"]:
		windows.show(d, true)
		draw_dialog(d)
	return d

func _attach_items(d: int, ditl_id: int) -> void:
	var h: int = machine.toolbox.resources.get_resource("DITL", ditl_id)
	memory.write_u32(d + 0x9c, h)
	var decoded: Dictionary = Templates.decode_ditl(Files.load_bytes("DITL", ditl_id))
	var items: Array = []
	for item in decoded["items"]:
		var e := {"type": item["type"], "enabled": item["enabled"], "box": item["bounds"], "handle": 0, "proc": 0}
		match item["type"]:
			BUTTON, CHECKBOX, RADIO:
				e["handle"] = _new_control(d, item, items.size())
			STATIC_TEXT, EDIT_TEXT:
				var text := PackedByteArray()
				for b in item["data"]:
					text.append(b)
				e["handle"] = heap.new_handle(text.size(), false)
				_store_text(e["handle"], text)
			ICON, PICTURE:
				e["resource"] = item.get("resource_id", 0)
		items.append(e)
	var first_edit: int = -1
	for i in items.size():
		if items[i]["type"] == EDIT_TEXT:
			first_edit = i
			break
	dialogs[d] = {"items": items, "edit": first_edit, "default": 0}
	memory.write_u16(d + 0xa4, (first_edit) & 0xffff)
	memory.write_u16(d + 0xa8, 1)

func _new_control(d: int, item: Dictionary, index: int) -> int:
	var h: int = heap.new_handle(0x128, true)
	var c: int = memory.read_u32(h)
	memory.write_u32(c + 4, d)
	qd.write_rect(c + 8, item["bounds"])
	memory.write_u8(c + 0x10, 0xff)
	memory.write_u16(c + 0x16, 1)
	var title := PackedByteArray()
	for b in item["data"]:
		title.append(b)
	memory.write_u8(c + 0x28, title.size())
	for k in title.size():
		memory.write_u8(c + 0x29 + k, title[k])
	_controls[h] = [d, index]
	return h

func _store_text(h: int, text: PackedByteArray) -> void:
	heap.set_handle_size(h, text.size())
	var p: int = memory.read_u32(h)
	for k in text.size():
		memory.write_u8(p + k, text[k])

func _text(h: int) -> PackedByteArray:
	var out := PackedByteArray()
	var p: int = memory.read_u32(h)
	for k in heap.handle_size(h):
		out.append(memory.read_u8(p + k))
	return out

func dispose(d: int) -> int:
	d &= 0xffffffff
	dialogs.erase(d)
	windows.dispose(d)
	return 0

func get_ditem(d: int, index: int, type_ptr: int, handle_ptr: int, box_ptr: int) -> int:
	var e: Dictionary = _item(d, index)
	if e.is_empty():
		return 0
	memory.write_u16(type_ptr, e["type"] | (0 if e["enabled"] else 0x80))
	memory.write_u32(handle_ptr, e["proc"] if e["type"] == USER_ITEM else e["handle"])
	qd.write_rect(box_ptr, e["box"])
	return 0

func set_ditem(d: int, index: int, type_code: int, h: int, box) -> int:
	var e: Dictionary = _item(d, index)
	if e.is_empty():
		return 0
	e["enabled"] = (type_code & 0x80) == 0
	if (type_code & 0x7f) == USER_ITEM:
		e["proc"] = h & 0xffffffff
	else:
		e["handle"] = h & 0xffffffff
	e["box"] = qd.rect_arg(box)
	return 0

func _item(d: int, index: int) -> Dictionary:
	d &= 0xffffffff
	index = qd.s16(index)
	if not dialogs.has(d) or index < 1 or index > dialogs[d]["items"].size():
		return {}
	return dialogs[d]["items"][index - 1]

func get_itext(h: int, out: int) -> int:
	var text: PackedByteArray = _text(h)
	memory.write_u8(out, text.size())
	for k in text.size():
		memory.write_u8(out + 1 + k, text[k])
	return 0

func set_itext(h: int, text_arg) -> int:
	_store_text(h & 0xffffffff, qd.pstr_arg(text_arg))
	for d in dialogs:
		for e in dialogs[d]["items"]:
			if e["handle"] == (h & 0xffffffff) and windows.is_visible(d):
				_draw_item(d, e)
	return 0

func find_ditem(d: int, pt: int) -> int:
	var p := Vector2i(qd.s16(pt), qd.s16(pt >> 16))
	d &= 0xffffffff
	if not dialogs.has(d):
		return -1
	var items: Array = dialogs[d]["items"]
	for i in items.size():
		if (items[i]["box"] as Rect2i).has_point(p):
			return i
	return -1

func _ctl(h: int, field: int) -> int:
	return memory.read_u16(memory.read_u32(h) + field)

## SetCtlValue / SetCtlMin / SetCtlMax: the value stays within min and max, as the Control Manager
## keeps it.
func _set_ctl(h: int, field: int, v: int) -> int:
	var c: int = memory.read_u32(h)
	memory.write_u16(c + field, v & 0xffff)
	var lo: int = qd.s16(memory.read_u16(c + 0x14))
	var hi: int = qd.s16(memory.read_u16(c + 0x16))
	if field == 0x16 and hi < lo:
		hi = lo
	memory.write_u16(c + 0x12, clampi(qd.s16(memory.read_u16(c + 0x12)), lo, maxi(hi, lo)) & 0xffff)
	_redraw_control(h)
	return 0

## A control record (contrlOwner +4, contrlRect +8, contrlVis +0x10, value / min / max +0x12..,
## contrlDefProc +0x18 holding the procID, contrlRfCon +0x24, contrlTitle +0x28) in its window.
func new_control(w: int, r: Rect2i, title: PackedByteArray, visible: bool, value: int, lo: int, hi: int,
		proc_id: int, ref_con: int) -> int:
	var h: int = heap.new_handle(0x128, true)
	var c: int = memory.read_u32(h)
	memory.write_u32(c + 4, w)
	qd.write_rect(c + 8, r)
	memory.write_u8(c + 0x10, 0xff if visible else 0)
	memory.write_u16(c + 0x12, value & 0xffff)
	memory.write_u16(c + 0x14, lo & 0xffff)
	memory.write_u16(c + 0x16, hi & 0xffff)
	memory.write_u32(c + 0x18, proc_id & 0xffff)
	memory.write_u32(c + 0x24, ref_con)
	memory.write_u8(c + 0x28, title.size())
	for k in title.size():
		memory.write_u8(c + 0x29 + k, title[k])
	_standalone[h] = w & 0xffffffff
	_redraw_control(h)
	return h

func _show_control(h: int, on: bool) -> int:
	var c: int = memory.read_u32(h)
	memory.write_u8(c + 0x10, 0xff if on else 0)
	if on:
		_redraw_control(h)
	elif _standalone.has(h & 0xffffffff):
		_in_port(_standalone[h & 0xffffffff], func(port: int) -> void:
			qd.fill_rect(port, qd.read_rect(c + 8), [0, 0, 0, 0, 0, 0, 0, 0], qd.PAT_COPY))
	return 0

func _in_port(port: int, draw: Callable) -> void:
	var saved: int = qd.the_port()
	memory.write_u32(qd.globals, port)
	draw.call(port)
	memory.write_u32(qd.globals, saved)

## A scroll bar (procID 16..): framed, arrow boxes at its ends, and when active (max above min,
## not hilited 255) a gray track with the thumb at the value; other kinds as a framed title.
func _draw_standalone(h: int) -> void:
	var c: int = memory.read_u32(h)
	var w: int = _standalone[h]
	if memory.read_u8(c + 0x10) == 0 or not windows.is_visible(w):
		return
	_in_port(w, func(port: int) -> void:
		var r: Rect2i = qd.read_rect(c + 8)
		var white := [0, 0, 0, 0, 0, 0, 0, 0]
		memory.write_u32(port + 0x34, 0x00010001)
		memory.write_u16(port + 0x38, qd.PAT_COPY)
		for k in 8:
			memory.write_u8(port + 0x3a + k, 0xff)
		qd.fill_rect(port, r, white, qd.PAT_COPY)
		qd.frame_rect(port, r)
		if memory.read_u16(c + 0x1a) & 0xfff0 != 0x10:
			return
		var vertical: bool = r.size.y >= r.size.x
		var arrow: int = mini(r.size.x, r.size.y)
		var first := Rect2i(r.position, Vector2i(arrow, arrow))
		var last := Rect2i(r.end - Vector2i(arrow, arrow), Vector2i(arrow, arrow))
		qd.frame_rect(port, first)
		qd.frame_rect(port, last)
		var lo: int = qd.s16(memory.read_u16(c + 0x14))
		var hi: int = qd.s16(memory.read_u16(c + 0x16))
		if hi <= lo or memory.read_u8(c + 0x11) == 0xff:
			return
		var track := Rect2i(first.end.x - 1, r.position.y, last.position.x - first.end.x + 2, r.size.y) if not vertical \
				else Rect2i(r.position.x, first.end.y - 1, r.size.x, last.position.y - first.end.y + 2)
		qd.fill_rect(port, track.grow(-1), [0x88, 0x22, 0x88, 0x22, 0x88, 0x22, 0x88, 0x22], qd.PAT_COPY)
		var span: int = (track.size.y if vertical else track.size.x) - arrow
		var at: int = (clampi(qd.s16(memory.read_u16(c + 0x12)), lo, hi) - lo) * span / (hi - lo)
		var thumb := Rect2i(r.position.x, track.position.y + at, arrow, arrow) if vertical \
				else Rect2i(track.position.x + at, r.position.y, arrow, arrow)
		qd.fill_rect(port, thumb, white, qd.PAT_COPY)
		qd.frame_rect(port, thumb))

## The part of a visible, active control of `w` under the local point (VAR c set; 0 without one):
## a scroll bar's arrows 20 / 21, page areas 22 / 23 and thumb 129; a dialog's button 10, check
## box or radio button 11.
func find_control(p: Vector2i, w: int, out: int) -> int:
	memory.write_u32(out, 0)
	for h in _standalone:
		if _standalone[h] != w:
			continue
		var c: int = memory.read_u32(h)
		var r: Rect2i = qd.read_rect(c + 8)
		if memory.read_u8(c + 0x10) == 0 or memory.read_u8(c + 0x11) == 0xff or not r.has_point(p):
			continue
		memory.write_u32(out, h)
		return _scroll_part(c, p)
	if dialogs.has(w):
		for e in dialogs[w]["items"]:
			if e["type"] in [BUTTON, CHECKBOX, RADIO] and (e["box"] as Rect2i).has_point(p):
				var c: int = memory.read_u32(e["handle"])
				if memory.read_u8(c + 0x11) == 0xff:
					return 0
				memory.write_u32(out, e["handle"])
				return 10 if e["type"] == BUTTON else 11
	return 0

func _scroll_part(c: int, p: Vector2i) -> int:
	var r: Rect2i = qd.read_rect(c + 8)
	var vertical: bool = r.size.y >= r.size.x
	var arrow: int = mini(r.size.x, r.size.y)
	var along: int = (p.y - r.position.y) if vertical else (p.x - r.position.x)
	var length: int = r.size.y if vertical else r.size.x
	if along < arrow:
		return 20
	if along >= length - arrow:
		return 21
	var lo: int = qd.s16(memory.read_u16(c + 0x14))
	var hi: int = qd.s16(memory.read_u16(c + 0x16))
	if hi <= lo:
		return 0
	var at: int = arrow + (clampi(qd.s16(memory.read_u16(c + 0x12)), lo, hi) - lo) * (length - 3 * arrow) / (hi - lo)
	if along < at:
		return 22
	if along >= at + arrow:
		return 23
	return 129

## Follows the mouse while the button is down: the thumb's new value is set from where it is let go;
## other parts call the action procedure (control, part) once and then as long as the button is
## held. The part is returned (0 when let go outside the control).
func track_control(h: int, start: Vector2i, action: int) -> int:
	var c: int = memory.read_u32(h)
	var w: int = memory.read_u32(c + 4)
	var part: int = find_control(start, w, heap.new_ptr(4, true))
	if part == 0:
		return 0
	var origin: Vector2i = qd.port_bits(w)[2].position
	if part == 129:
		while events.is_button_down() and not events.has_mouse_up():
			machine.idle(10)
		events.flush_mouse_ups()
		var r: Rect2i = qd.read_rect(c + 8)
		var p: Vector2i = events.mouse_position() + origin
		var vertical: bool = r.size.y >= r.size.x
		var arrow: int = mini(r.size.x, r.size.y)
		var length: int = (r.size.y if vertical else r.size.x) - 3 * arrow
		var along: int = ((p.y - start.y) if vertical else (p.x - start.x))
		var lo: int = qd.s16(memory.read_u16(c + 0x14))
		var hi: int = qd.s16(memory.read_u16(c + 0x16))
		var value: int = qd.s16(memory.read_u16(c + 0x12))
		if length > 0:
			value = clampi(value + along * (hi - lo) / length, lo, hi)
		_set_ctl(h, 0x12, value)
		return part
	var first := true
	while first or (events.is_button_down() and not events.has_mouse_up()):
		if action != 0 and action != 0xffffffff:
			machine.segments.call_procedure(action, [h, part])
		first = false
		machine.idle(60)
	events.flush_mouse_ups()
	return part

func _redraw_control(h: int) -> void:
	h &= 0xffffffff
	if _standalone.has(h):
		_draw_standalone(h)
		return
	if _controls.has(h):
		var d: int = _controls[h][0]
		if dialogs.has(d) and windows.is_visible(d):
			_draw_item(d, dialogs[d]["items"][_controls[h][1]])

# ---- drawing ------------------------------------------------------------------------------------------

func draw_dialog(d: int) -> int:
	d &= 0xffffffff
	if not dialogs.has(d):
		return 0
	var saved: int = qd.the_port()
	memory.write_u32(qd.globals, d)
	for e in dialogs[d]["items"]:
		_draw_item(d, e)
	memory.write_u32(qd.globals, saved)
	for h in _standalone:
		if _standalone[h] == d:
			_draw_standalone(h)
	return 0

## The text with ParamText's strings in place of ^0 .. ^3.
func _substitute(text: PackedByteArray) -> PackedByteArray:
	var out := PackedByteArray()
	var i: int = 0
	while i < text.size():
		if text[i] == 0x5e and i + 1 < text.size() and text[i + 1] >= 0x30 and text[i + 1] <= 0x33:
			out.append_array(params[text[i + 1] - 0x30])
			i += 2
		else:
			out.append(text[i])
			i += 1
	return out

func _draw_item(d: int, e: Dictionary) -> void:
	var saved: int = qd.the_port()
	memory.write_u32(qd.globals, d)
	var port: int = d
	var r: Rect2i = e["box"]
	var white := [0, 0, 0, 0, 0, 0, 0, 0]
	var black := [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
	memory.write_u16(port + 0x44, 0)
	memory.write_u16(port + 0x4a, 12)
	memory.write_u8(port + 0x46, 0)
	memory.write_u32(port + 0x34, 0x00010001)
	memory.write_u16(port + 0x38, qd.PAT_COPY)
	for k in 8:
		memory.write_u8(port + 0x3a + k, 0xff)
	match e["type"]:
		BUTTON, CHECKBOX, RADIO:
			var c: int = memory.read_u32(e["handle"])
			var title := PackedByteArray()
			for k in memory.read_u8(c + 0x28):
				title.append(memory.read_u8(c + 0x29 + k))
			var dim: bool = memory.read_u8(c + 0x11) == 0xff
			if e["type"] == BUTTON:
				qd.paint_round(port, r, 16, 16, white, qd.PAT_COPY)
				qd.frame_round(port, r, 16, 16)
				var tw: int = qd.string_width(port, title)
				qd.set_pen_loc(port, Vector2i(r.position.x + (r.size.x - tw) / 2, r.position.y + (r.size.y - 16) / 2 + 13))
			else:
				var box := Rect2i(r.position.x + 2, r.position.y + (r.size.y - 12) / 2, 12, 12)
				qd.fill_rect(port, r, white, qd.PAT_COPY)
				if e["type"] == RADIO:
					qd.frame_round(port, box, 12, 12)
					if memory.read_u16(c + 0x12) != 0:
						qd.paint_round(port, box.grow(-3), 6, 6, black, qd.PAT_COPY)
				else:
					qd.frame_rect(port, box)
					if memory.read_u16(c + 0x12) != 0:
						qd.draw_line(port, box.position, box.end - Vector2i(1, 1))
						qd.draw_line(port, Vector2i(box.end.x - 1, box.position.y), Vector2i(box.position.x, box.end.y - 1))
				qd.set_pen_loc(port, Vector2i(r.position.x + 17, r.position.y + (r.size.y - 16) / 2 + 13))
			qd.draw_text(port, title)
			if dim:
				qd.fill_rect(port, r.grow(-1), [0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55], qd.PAT_BIC)
		STATIC_TEXT, EDIT_TEXT:
			var text: PackedByteArray = _text(e["handle"])
			if e["type"] == STATIC_TEXT:
				text = _substitute(text)
			qd.fill_rect(port, r, white, qd.PAT_COPY)
			if e["type"] == EDIT_TEXT:
				qd.frame_rect(port, r.grow(3))
			_text_box(port, text, r)
		ICON:
			var bytes: PackedByteArray = Files.load_bytes("ICON", e.get("resource", 0))
			if bytes.size() >= 128:
				qd.draw_image(port, Templates.icon_image(bytes), r)
		PICTURE:
			var image: Image = machine.toolbox.resources.picture(e.get("resource", 0))
			if image != null:
				qd.draw_image(port, image, r)
		USER_ITEM:
			if e["proc"] != 0:
				var index: int = dialogs[d]["items"].find(e) + 1
				machine.segments.call_procedure(e["proc"], [d, index])
	memory.write_u32(qd.globals, saved)

## TextBox: words wrapped to the rect, lines broken at CR, 16 pixels apart from the ascent.
func _text_box(port: int, text: PackedByteArray, r: Rect2i) -> void:
	var lines: Array = []
	var line := PackedByteArray()
	var word := PackedByteArray()
	for i in text.size() + 1:
		var c: int = text[i] if i < text.size() else 0x0d
		if c == 0x20 or c == 0x0d:
			var trial := line.duplicate()
			if trial.size() > 0:
				trial.append(0x20)
			trial.append_array(word)
			if line.size() > 0 and qd.string_width(port, trial) > r.size.x:
				lines.append(line)
				line = word.duplicate()
			else:
				line = trial
			word = PackedByteArray()
			if c == 0x0d:
				lines.append(line)
				line = PackedByteArray()
		else:
			word.append(c)
	var y: int = r.position.y + 12
	for l in lines:
		if y > r.end.y + 3:
			break
		qd.set_pen_loc(port, Vector2i(r.position.x, y))
		qd.draw_text(port, l)
		y += 16

# ---- the modal loop -------------------------------------------------------------------------------------

func modal_dialog(filter: int, item_ptr: int) -> int:
	var d: int = windows.front_window()
	if not dialogs.has(d):
		return 0
	var event: int = heap.new_ptr(16, true)
	while true:
		events.write_event(event, events.next_event(0xffff, true))
		memory.write_u16(item_ptr, 0)
		if filter != 0:
			var handled: int = machine.segments.call_procedure(filter, [d, event, item_ptr])
			if handled != 0 and memory.read_u16(item_ptr) != 0:
				return 0
		var hit: int = _handle(d, event)
		if hit > 0:
			memory.write_u16(item_ptr, hit)
			return 0
	return 0

## A dialog's default handling of an event: the item it hits (1-based), or 0.
func _handle(d: int, event: int) -> int:
	var what: int = memory.read_u16(event)
	var state: Dictionary = dialogs[d]
	var items: Array = state["items"]
	match what:
		1:
			var origin: Vector2i = -qd.port_bits(d)[2].position
			var p := Vector2i(memory.read_s16(event + 0xc), memory.read_s16(event + 0xa)) - origin
			for i in items.size():
				if items[i]["enabled"] and (items[i]["box"] as Rect2i).has_point(p):
					if items[i]["type"] == EDIT_TEXT:
						set_edit(d, i)
					return i + 1
		3, 5:
			var c: int = memory.read_u8(event + 5)
			if c == 0x0d or c == 0x03:
				return memory.read_u16(d + 0xa8)
			var edit: int = state["edit"]
			if c == 0x09:
				for k in range(1, items.size() + 1):
					var j: int = (edit + k) % items.size()
					if items[j]["type"] == EDIT_TEXT:
						set_edit(d, j)
						break
				return 0
			if edit >= 0:
				var e: Dictionary = items[edit]
				var text: PackedByteArray = _text(e["handle"])
				if c == 0x08:
					if text.size() > 0:
						text.resize(text.size() - 1)
				elif c >= 0x20:
					text.append(c)
				_store_text(e["handle"], text)
				_draw_item(d, e)
				return edit + 1 if e["enabled"] else 0
		6:
			if memory.read_u32(event + 2) == d:
				draw_dialog(d)
	return 0

## An alert: the ALRT's window (a modal box) over its item list, the default item outlined when
## its first stage says so, the loop until an item is hit; the item number is returned.
func alert(id: int, filter: int) -> int:
	var bytes: PackedByteArray = Files.load_bytes("ALRT", qd.s16(id))
	if bytes.is_empty():
		return -1
	var t: Dictionary = Templates.decode_alrt(bytes)
	var d: int = windows.new_window(0, t["bounds"], PackedByteArray(), false, 1, 0xffffffff, false, 0, true, DIALOG_KIND, windows.DIALOG_RECORD)
	_attach_items(d, t["ditl_id"])
	var stage: int = t["stages"][0]
	var default_item: int = 2 if (stage & 8) != 0 else 1
	memory.write_u16(d + 0xa8, default_item)
	windows.show(d, true)
	draw_dialog(d)
	if (stage & 4) != 0:
		var e: Dictionary = _item(d, default_item)
		if not e.is_empty():
			var saved: int = qd.the_port()
			memory.write_u32(qd.globals, d)
			memory.write_u32(d + 0x34, 0x00030003)
			qd.frame_round(d, (e["box"] as Rect2i).grow(4), 16, 16)
			memory.write_u32(d + 0x34, 0x00010001)
			memory.write_u32(qd.globals, saved)
	var item_ptr: int = heap.new_ptr(2, true)
	modal_dialog(filter, item_ptr)
	var hit: int = memory.read_u16(item_ptr)
	dispose(d)
	return hit
