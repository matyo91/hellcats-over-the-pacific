extends RefCounted

## Standard File's Get File dialog (SFGetFile, the ID09 glue at slot $30a) over the File Manager's
## volume: the files there in a list, the first selected; a click selects a row (a double click
## opens it), Open or Return / Enter answers with the selected file, Cancel or Escape / ⌘. with
## none. The reply (SFReply) gets good +0, fType +2 ('HELL', the scenery files' type: the volume
## holds only those), vRefNum +6, fName +10 (a Pascal string).

const SIZE := Vector2i(348, 180)
const LIST := Rect2i(16, 32, 200, 130)
const OPEN := Rect2i(240, 60, 82, 20)
const CANCEL := Rect2i(240, 92, 82, 20)
const ROW := 16

var machine
var memory
var qd
var windows
var events
var files

func _init(owner, toolbox) -> void:
	machine = owner
	memory = owner.memory
	qd = toolbox.quickdraw
	windows = toolbox.windows
	events = toolbox.events
	files = toolbox.files

func install(stand_ins: Dictionary) -> void:
	## The ports pass the Pascal parameters last first: VAR reply, dlgHook, typeList, numTypes,
	## fileFilter, prompt, where.
	stand_ins[0x30a] = func(a: Array) -> int: return get_file(a[0], a[5], a[6])

func get_file(reply: int, prompt: int, where: int) -> int:
	var names: Array = files.volume_files()
	# `where` comes from the System file's DLOG -4000, which the game's resources lack: when it does
	# not put the dialog on the screen, it goes where Standard File centres it.
	var top_left := Vector2i(qd.s16(where), qd.s16(where >> 16))
	if not Rect2i(0, machine.MENU_BAR_HEIGHT, machine.SCREEN_WIDTH, machine.SCREEN_HEIGHT - machine.MENU_BAR_HEIGHT) \
			.encloses(Rect2i(top_left, SIZE)):
		top_left = Vector2i((machine.SCREEN_WIDTH - SIZE.x) / 2, (machine.SCREEN_HEIGHT - SIZE.y) / 3)
	var saved: int = qd.the_port()
	var w: int = windows.new_window(0, Rect2i(top_left, SIZE), PackedByteArray(), true, 1, 0xffffffff, false, 0, true,
			2, windows.DIALOG_RECORD)
	var label: PackedByteArray = qd.pstr_arg(prompt) if prompt != 0 else PackedByteArray()
	var selected: int = 0 if names.size() > 0 else -1
	var chosen: int = -2
	var last_click: int = -1000
	_draw(w, names, selected, label)
	while chosen == -2:
		var e: Dictionary = events.next_event(0xffff, true)
		match e["what"]:
			1:
				var p: Vector2i = e["where"] - windows.content(w).position
				if OPEN.has_point(p) and selected >= 0:
					chosen = selected
				elif CANCEL.has_point(p):
					chosen = -1
				elif LIST.has_point(p):
					var row: int = (p.y - LIST.position.y - 1) / ROW
					if row < names.size():
						if row == selected and machine.ticks() - last_click < 30:
							chosen = row
						selected = row
						last_click = machine.ticks()
						_draw(w, names, selected, label)
			3, 5:
				var c: int = e["message"] & 0xff
				var command: bool = (e["modifiers"] & 0x100) != 0
				if (c == 0x0d or c == 0x03) and selected >= 0:
					chosen = selected
				elif c == 0x1b or (command and c == 0x2e):
					chosen = -1
				elif c == 0x1e and selected > 0:
					selected -= 1
					_draw(w, names, selected, label)
				elif c == 0x1f and selected < names.size() - 1:
					selected += 1
					_draw(w, names, selected, label)
	windows.dispose(w)
	memory.write_u32(qd.globals, saved)
	for k in 0x4a:
		memory.write_u8(reply + k, 0)
	if chosen >= 0:
		var name: PackedByteArray = String(names[chosen]).to_utf8_buffer()
		memory.write_u8(reply, 1)
		memory.write_u32(reply + 2, 0x48454c4c)
		memory.write_u16(reply + 6, files.VREF)
		memory.write_u8(reply + 10, name.size())
		for k in name.size():
			memory.write_u8(reply + 11 + k, name[k])
	return 0

func _draw(w: int, names: Array, selected: int, label: PackedByteArray) -> void:
	var saved: int = qd.the_port()
	memory.write_u32(qd.globals, w)
	var white := [0, 0, 0, 0, 0, 0, 0, 0]
	var black := [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
	memory.write_u32(w + 0x34, 0x00010001)
	memory.write_u16(w + 0x38, qd.PAT_COPY)
	qd.fill_rect(w, Rect2i(Vector2i.ZERO, SIZE), white, qd.PAT_COPY)
	qd.set_pen_loc(w, Vector2i(LIST.position.x, 22))
	qd.draw_text(w, label if label.size() > 0 else "Open which scenery?".to_utf8_buffer())
	qd.frame_rect(w, LIST)
	for i in names.size():
		var row := Rect2i(LIST.position.x + 1, LIST.position.y + 1 + i * ROW, LIST.size.x - 2, ROW)
		if row.end.y > LIST.end.y:
			break
		qd.set_pen_loc(w, Vector2i(row.position.x + 4, row.position.y + 12))
		qd.draw_text(w, String(names[i]).to_utf8_buffer())
		if i == selected:
			qd.fill_rect(w, row, black, qd.PAT_XOR)
	for b in [[OPEN, "Open"], [CANCEL, "Cancel"]]:
		var r: Rect2i = b[0]
		qd.frame_round(w, r, 16, 16)
		var title: PackedByteArray = String(b[1]).to_utf8_buffer()
		qd.set_pen_loc(w, Vector2i(r.position.x + (r.size.x - qd.string_width(w, title)) / 2, r.position.y + 14))
		qd.draw_text(w, title)
	qd.frame_round(w, OPEN.grow(4), 20, 20)
	qd.frame_round(w, OPEN.grow(3), 20, 20)
	qd.frame_round(w, OPEN.grow(2), 20, 20)
	memory.write_u32(qd.globals, saved)
