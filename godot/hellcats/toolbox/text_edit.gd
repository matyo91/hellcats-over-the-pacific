extends RefCounted

## TextEdit, as far as the program's scrolling text (ID04's mission summary) uses it. A record
## (TENew) is a handle laid out as the Toolbox's TERec: destRect +0, viewRect +8, lineHeight +0x18,
## fontAscent +0x1a, selStart +0x20, selEnd +0x22, active +0x24, just +0x3a, teLength +0x3c, hText
## +0x3e (the text's handle), crOnly +0x48, txFont +0x4a, txFace +0x4c, txMode +0x4e, txSize
## +0x50, inPort +0x52, nLines +0x5e and lineStarts +0x60 (nLines + 1 words, the last teLength).
## Lines wrap at word breaks to the destination's width and break at CR; the text is drawn from
## the destination's top left, one lineHeight apart, clipped to the view.

const HEADER := 0x60

var machine
var memory
var heap
var qd

func _init(owner, toolbox) -> void:
	machine = owner
	memory = owner.memory
	heap = toolbox.heap
	qd = toolbox.quickdraw

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa9d2, func(a: Array) -> int: return new_record(qd.rect_arg(a[1]), qd.rect_arg(a[0])))  ## TENew(dest, view)
	t.install(0xa9cd, func(_a: Array) -> int: return 0)                                       ## TEDispose (the heap keeps blocks)
	t.install(0xa9d0, func(a: Array) -> int: return cal_text(a[0]))                           ## TECalText(h)
	t.install(0xa9d3, func(a: Array) -> int: return update(a[0], qd.rect_arg(a[1])))         ## TEUpdate(rect, h)
	t.install(0xa9dd, func(a: Array) -> int: return scroll(a[0], qd.s16(a[2]), qd.s16(a[1])))  ## TEScroll(dh, dv, h)
	t.install(0xa9de, func(a: Array) -> int: return insert(a[0], a[2], a[1]))                ## TEInsert(text, length, h)
	t.install(0xa9cf, func(a: Array) -> int: return set_text(a[0], a[2], a[1]))              ## TESetText(text, length, h)
	t.install(0xa9cb, func(a: Array) -> int: return memory.read_u32(memory.read_u32(a[0]) + 0x3e))  ## TEGetText(h)
	t.install(0xa9d1, func(a: Array) -> int:                                                  ## TESetSelect(start, end, h)
		var te: int = memory.read_u32(a[0])
		memory.write_u16(te + 0x20, _clamp_pos(te, a[2]))
		memory.write_u16(te + 0x22, _clamp_pos(te, a[1]))
		return 0)
	for word in [0xa9d8, 0xa9d9, 0xa9da, 0xa9db, 0xa9dc]:                                       ## TEActivate, TEDeactivate, TEIdle, TEKey...
		t.install(word, func(_a: Array) -> int: return 0)
	t.install(0xa9ce, func(a: Array) -> int:                                                  ## TETextBox(text, length, box, just)
		_text_box(a[3], a[2], qd.rect_arg(a[1]))
		return 0)

func _clamp_pos(te: int, v: int) -> int:
	return clampi(qd.s16(v), 0, memory.read_u16(te + 0x3c))

## A record over dest and view in the current port, with its font, an empty text and one line.
func new_record(dest: Rect2i, view: Rect2i) -> int:
	var port: int = qd.the_port()
	var h: int = heap.new_handle(HEADER + 4, true)
	var te: int = memory.read_u32(h)
	qd.write_rect(te, dest)
	qd.write_rect(te + 8, view)
	var info: Array = qd.font_info(port)
	memory.write_u16(te + 0x18, info[0] + info[1] + info[3])
	memory.write_u16(te + 0x1a, info[0])
	memory.write_u16(te + 0x24, 1)
	memory.write_u32(te + 0x3e, heap.new_handle(0, false))
	memory.write_u16(te + 0x4a, memory.read_u16(port + 0x44))
	memory.write_u16(te + 0x4c, memory.read_u16(port + 0x46))
	memory.write_u16(te + 0x4e, memory.read_u16(port + 0x48))
	memory.write_u16(te + 0x50, memory.read_u16(port + 0x4a))
	memory.write_u32(te + 0x52, port)
	cal_text(h)
	return h

func _text(te: int) -> PackedByteArray:
	var th: int = memory.read_u32(te + 0x3e)
	var p: int = memory.read_u32(th)
	var out := PackedByteArray()
	for k in memory.read_u16(te + 0x3c):
		out.append(memory.read_u8(p + k))
	return out

func _store(h: int, text: PackedByteArray) -> void:
	var te: int = memory.read_u32(h)
	var th: int = memory.read_u32(te + 0x3e)
	heap.set_handle_size(th, text.size())
	var p: int = memory.read_u32(th)
	for k in text.size():
		memory.write_u8(p + k, text[k])
	memory.write_u16(memory.read_u32(h) + 0x3c, text.size())

func _width(te: int, bytes: PackedByteArray) -> int:
	return qd.glyphs.width(bytes, memory.read_s16(te + 0x4a), memory.read_s16(te + 0x50), memory.read_u8(te + 0x4c))

## Line starts recomputed: breaks after CR, and before a word that would pass the destination's
## right edge (a word longer than the line breaks where it no longer fits).
func cal_text(h: int) -> int:
	var te: int = memory.read_u32(h)
	var text: PackedByteArray = _text(te)
	var width: int = qd.read_rect(te).size.x
	var starts: Array = [0]
	var start: int = 0
	var i: int = 0
	var last_space: int = -1
	while i < text.size():
		var c: int = text[i]
		if c == 0x0d:
			start = i + 1
			starts.append(start)
			last_space = -1
		else:
			if c == 0x20:
				last_space = i
			if c != 0x20 and _width(te, text.slice(start, i + 1)) > width and i > start:
				start = last_space + 1 if last_space >= start else i
				starts.append(start)
				last_space = -1
				i = start
				continue
		i += 1
	if starts[starts.size() - 1] != text.size():
		starts.append(text.size())
	var lines: int = starts.size() - 1
	heap.set_handle_size(h, HEADER + 2 * starts.size() + 2)
	te = memory.read_u32(h)
	memory.write_u16(te + 0x5e, lines)
	for k in starts.size():
		memory.write_u16(te + 0x60 + 2 * k, starts[k])
	return 0

## The lines over `area` (local) in the record's port: erased within the view, then drawn.
func update(h: int, area: Rect2i) -> int:
	var te: int = memory.read_u32(h)
	var port: int = memory.read_u32(te + 0x52)
	var view: Rect2i = qd.read_rect(te + 8).intersection(area)
	if view.size.x <= 0 or view.size.y <= 0:
		return 0
	var dest: Rect2i = qd.read_rect(te)
	var text: PackedByteArray = _text(te)
	var height: int = memory.read_s16(te + 0x18)
	var ascent: int = memory.read_s16(te + 0x1a)
	var saved_pen: Vector2i = qd.pen_loc(port)
	var style: Array = [memory.read_u16(port + 0x44), memory.read_u16(port + 0x46), memory.read_u16(port + 0x48), memory.read_u16(port + 0x4a)]
	memory.write_u16(port + 0x44, memory.read_u16(te + 0x4a))
	memory.write_u16(port + 0x46, memory.read_u16(te + 0x4c))
	memory.write_u16(port + 0x48, qd.SRC_OR)
	memory.write_u16(port + 0x4a, memory.read_u16(te + 0x50))
	for line in memory.read_u16(te + 0x5e):
		var top: int = dest.position.y + line * height
		if top + height <= view.position.y or top >= view.end.y:
			continue
		var a: int = memory.read_u16(te + 0x60 + 2 * line)
		var b: int = memory.read_u16(te + 0x62 + 2 * line)
		var bytes: PackedByteArray = text.slice(a, b)
		while bytes.size() > 0 and (bytes[bytes.size() - 1] == 0x0d):
			bytes.resize(bytes.size() - 1)
		qd.set_pen_loc(port, Vector2i(dest.position.x, top + ascent))
		qd.draw_text(port, bytes, view)
	memory.write_u16(port + 0x44, style[0])
	memory.write_u16(port + 0x46, style[1])
	memory.write_u16(port + 0x48, style[2])
	memory.write_u16(port + 0x4a, style[3])
	qd.set_pen_loc(port, saved_pen)
	return 0

func _redraw(h: int) -> void:
	var te: int = memory.read_u32(h)
	var port: int = memory.read_u32(te + 0x52)
	var view: Rect2i = qd.read_rect(te + 8)
	qd.fill_rect(port, view, [0, 0, 0, 0, 0, 0, 0, 0], qd.PAT_COPY)
	update(h, view)

## The destination moved by (dh, dv) and the view redrawn.
func scroll(h: int, dh: int, dv: int) -> int:
	var te: int = memory.read_u32(h)
	var dest: Rect2i = qd.read_rect(te)
	qd.write_rect(te, Rect2i(dest.position + Vector2i(dh, dv), dest.size))
	_redraw(h)
	return 0

## `length` bytes at `text` replace the selection; the insertion point follows them.
func insert(h: int, text: int, length: int) -> int:
	var te: int = memory.read_u32(h)
	var old: PackedByteArray = _text(te)
	var a: int = memory.read_u16(te + 0x20)
	var b: int = maxi(memory.read_u16(te + 0x22), a)
	var added := PackedByteArray()
	for k in qd.s16(length) if qd.s16(length) > 0 else 0:
		added.append(memory.read_u8(text + k))
	var out: PackedByteArray = old.slice(0, a)
	out.append_array(added)
	out.append_array(old.slice(b))
	_store(h, out)
	te = memory.read_u32(h)
	memory.write_u16(te + 0x20, a + added.size())
	memory.write_u16(te + 0x22, a + added.size())
	cal_text(h)
	_redraw(h)
	return 0

func set_text(h: int, text: int, length: int) -> int:
	var bytes := PackedByteArray()
	for k in maxi(length, 0):
		bytes.append(memory.read_u8(text + k))
	_store(h, bytes)
	var te: int = memory.read_u32(h)
	memory.write_u16(te + 0x20, bytes.size())
	memory.write_u16(te + 0x22, bytes.size())
	cal_text(h)
	return 0

## TETextBox: the bytes wrapped in the box of the current port.
func _text_box(text: int, length: int, box: Rect2i) -> void:
	var h: int = new_record(box, box)
	set_text(h, text, length)
	update(h, box)
