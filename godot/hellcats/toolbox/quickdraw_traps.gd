extends RefCounted

## QuickDraw's trap words, each reading its arguments as the ports pass them (last pushed first:
## a Pascal routine's parameters reversed) and acting on the current port (quickdraw.gd).

const Files := preload("res://strict_port/ui/resource_files.gd")
const Images := preload("res://strict_port/ui/resource_images.gd")

var qd
var memory
var machine
var _cicons: Dictionary = {}          ## GetCIcon's handle -> its masked image

func _init(quickdraw) -> void:
	qd = quickdraw
	memory = quickdraw.memory
	machine = quickdraw.machine

func _port() -> int:
	return qd.the_port()

func _pt(v: int, h: int) -> Vector2i:
	return Vector2i(qd.s16(h), qd.s16(v))

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa86e, func(a: Array) -> int: return qd.init_graf(a[0]))                       ## InitGraf
	for word in [0xa8fe, 0xa851, 0xa856]:                                                       ## InitFonts, SetCursor, ObscureCursor
		t.install(word, func(_a: Array) -> int: return 0)
	# The cursor level (0 shown, below hidden): the Godot pointer follows it (game.gd).
	t.install(0xa850, func(_a: Array) -> int:                                                    ## InitCursor
		machine.cursor_level = 0
		return 0)
	t.install(0xa852, func(_a: Array) -> int:                                                    ## HideCursor
		machine.cursor_level -= 1
		return 0)
	t.install(0xa853, func(_a: Array) -> int:                                                    ## ShowCursor
		machine.cursor_level = mini(machine.cursor_level + 1, 0)
		return 0)
	t.install(0xaa2a, func(_a: Array) -> int: return qd.main_device)                             ## GetMainDevice
	t.install(0xaa29, func(_a: Array) -> int: return qd.main_device)                             ## GetDeviceList
	t.install(0xaa2b, func(_a: Array) -> int: return 0)                                          ## GetNextDevice
	t.install(0xaa32, func(_a: Array) -> int: return qd.main_device)                             ## GetGDevice
	t.install(0xaa31, func(_a: Array) -> int: return 0)                                          ## SetGDevice
	t.install(0xaa28, func(_a: Array) -> int: return 1)                                          ## GetCTSeed
	# Ports.
	t.install(0xa873, func(a: Array) -> int:                                                     ## SetPort
		memory.write_u32(qd.globals, a[0] & 0xffffffff)
		return 0)
	t.install(0xa874, func(a: Array) -> int:                                                     ## GetPort(VAR port)
		memory.write_u32(a[0], _port())
		return 0)
	t.install(0xa86f, func(a: Array) -> int:                                                     ## OpenPort
		qd.init_port(a[0], false)
		memory.write_u32(qd.globals, a[0] & 0xffffffff)
		return 0)
	t.install(0xa86d, func(a: Array) -> int:                                                     ## InitPort
		qd.init_port(a[0], false)
		return 0)
	t.install(0xaa00, func(a: Array) -> int:                                                     ## OpenCPort
		qd.init_port(a[0], true)
		memory.write_u32(qd.globals, a[0] & 0xffffffff)
		return 0)
	t.install(0xa87d, func(_a: Array) -> int: return 0)                                          ## ClosePort
	t.install(0xa875, func(a: Array) -> int:                                                     ## SetPortBits(bm)
		var port: int = _port()
		if a[0] is Array:
			# By value (the port logs the BitMap's first 12 bytes): baseAddr, rowBytes, top, left, bottom;
			# the right edge is the row's full width.
			var v: Array = a[0]
			memory.write_u32(port + 2, int(v[0]))
			memory.write_u32(port + 6, int(v[1]))
			memory.write_u32(port + 0xa, int(v[2]))
			var rb: int = (int(v[1]) >> 16) & 0x3fff
			memory.write_u16(port + 0xe, (memory.read_s16(port + 0xa) + rb * 8) & 0xffff)
		else:
			for k in 14:
				memory.write_u8(port + 2 + k, memory.read_u8(a[0] + k))
		return 0)
	t.install(0xa878, func(a: Array) -> int:                                                     ## SetOrigin(h, v)
		var port: int = _port()
		var r: Rect2i = qd.read_rect(port + 0x10)
		var to := _pt(a[0], a[1])
		var d: Vector2i = to - r.position
		qd.write_rect(port + 0x10, Rect2i(to, r.size))
		var bounds_at: int = port + 8 if not qd.is_color(memory, port) else memory.read_u32(memory.read_u32(port + 2)) + 6
		var b: Rect2i = qd.read_rect(bounds_at)
		qd.write_rect(bounds_at, Rect2i(b.position + d, b.size))
		return 0)
	t.install(0xa870, func(a: Array) -> int: return _shift_point(a[0], -1))                      ## LocalToGlobal(VAR pt)
	t.install(0xa871, func(a: Array) -> int: return _shift_point(a[0], 1))                       ## GlobalToLocal(VAR pt)
	# Regions (as their bounding rects).
	t.install(0xa8d8, func(_a: Array) -> int: return qd.new_region(Rect2i()))                    ## NewRgn
	t.install(0xa8d9, func(_a: Array) -> int: return 0)                                          ## DisposeRgn
	t.install(0xa8da, func(_a: Array) -> int:                                                    ## OpenRgn
		qd.rgn_open = true
		qd.rgn_points = []
		qd.rgn_ovals = []
		return 0)
	t.install(0xa8db, func(a: Array) -> int:                                                     ## CloseRgn: the recorded extent
		qd.rgn_open = false
		var box := Rect2i()
		if qd.rgn_points.size() > 0:
			box = Rect2i(qd.rgn_points[0], Vector2i.ZERO)
			for q in qd.rgn_points:
				box = box.expand(q)
		qd.set_region(a[0], box)
		if qd.rgn_ovals.size() == 1 and qd.rgn_points.size() == 2:
			qd.ovals[a[0] & 0xffffffff] = qd.rgn_ovals[0]
		return 0)
	t.install(0xa8e6, func(a: Array) -> int:                                                     ## DiffRgn(a, b, dst): a kept
		qd.copy_region(a[2], a[0])
		return 0)
	t.install(0xa8e7, func(a: Array) -> int:                                                     ## XorRgn(a, b, dst)
		qd.set_region(a[0], qd.region_rect(a[2]).merge(qd.region_rect(a[1])))
		return 0)
	t.install(0xa8e8, func(a: Array) -> int:                                                     ## PtInRgn(pt, rgn): Boolean
		return 0x100 if qd.point_in_region(a[0], _pt(a[1] >> 16, a[1])) else 0)
	t.install(0xa8dd, func(a: Array) -> int:                                                     ## SetEmptyRgn
		qd.set_region(a[0], Rect2i())
		return 0)
	t.install(0xa8d5, func(a: Array) -> int:                                                     ## InvertRgn
		qd.fill_rect(_port(), qd.region_rect(a[0]), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], qd.PAT_XOR)
		return 0)
	t.install(0xa8d6, func(a: Array) -> int:                                                     ## FillRgn(rgn, pat)
		qd.fill_rect(_port(), qd.region_rect(a[1]), qd.pattern_arg(a[0]), qd.PAT_COPY)
		return 0)
	t.install(0xa8df, func(a: Array) -> int:                                                     ## RectRgn(rgn, r)
		qd.set_region(a[1], qd.rect_arg(a[0]))
		return 0)
	t.install(0xa8de, func(a: Array) -> int:                                                     ## SetRectRgn(rgn, l, t, r, b)
		qd.set_region(a[4], Rect2i(qd.s16(a[3]), qd.s16(a[2]), qd.s16(a[1]) - qd.s16(a[3]), qd.s16(a[0]) - qd.s16(a[2])))
		return 0)
	t.install(0xa8dc, func(a: Array) -> int:                                                     ## CopyRgn(src, dst)
		qd.copy_region(a[1], a[0])
		return 0)
	t.install(0xa8e4, func(a: Array) -> int:                                                     ## SectRgn(a, b, dst)
		qd.set_region(a[0], qd.region_rect(a[2]).intersection(qd.region_rect(a[1])))
		return 0)
	t.install(0xa8e5, func(a: Array) -> int:                                                     ## UnionRgn(a, b, dst)
		qd.set_region(a[0], qd.region_rect(a[2]).merge(qd.region_rect(a[1])))
		return 0)
	t.install(0xa8e0, func(a: Array) -> int:                                                     ## OffsetRgn(rgn, dh, dv)
		qd.offset_region(a[2], _pt(a[0], a[1]))
		return 0)
	t.install(0xa879, func(a: Array) -> int:                                                     ## SetClip(rgn)
		qd.copy_region(a[0], memory.read_u32(_port() + 0x1c))
		return 0)
	t.install(0xa87a, func(a: Array) -> int:                                                     ## GetClip(rgn)
		qd.copy_region(memory.read_u32(_port() + 0x1c), a[0])
		return 0)
	t.install(0xa87b, func(a: Array) -> int:                                                     ## ClipRect(r)
		qd.set_region(memory.read_u32(_port() + 0x1c), qd.rect_arg(a[0]))
		return 0)
	t.install(0xa8d2, func(a: Array) -> int:                                                     ## FrameRgn
		qd.frame_rect(_port(), qd.region_rect(a[0]))
		return 0)
	t.install(0xa8d3, func(a: Array) -> int:                                                     ## PaintRgn
		qd.fill_rect(_port(), qd.region_rect(a[0]), qd.pen_rows(_port()), qd.pen_mode(_port()))
		return 0)
	t.install(0xa8d4, func(a: Array) -> int:                                                     ## EraseRgn
		qd.fill_rect(_port(), qd.region_rect(a[0]), _bk_rows(), qd.PAT_COPY)
		return 0)
	# Rect arithmetic.
	t.install(0xa8a7, func(a: Array) -> int:                                                     ## SetRect(r, l, t, r, b)
		qd.write_rect(a[4], Rect2i(qd.s16(a[3]), qd.s16(a[2]), qd.s16(a[1]) - qd.s16(a[3]), qd.s16(a[0]) - qd.s16(a[2])))
		return 0)
	t.install(0xa8a8, func(a: Array) -> int:                                                     ## OffsetRect(r, dh, dv)
		var r: Rect2i = qd.rect_arg(a[2])
		qd.update_rect(a[2], Rect2i(r.position + _pt(a[0], a[1]), r.size))
		return 0)
	t.install(0xa8a9, func(a: Array) -> int:                                                     ## InsetRect(r, dh, dv)
		var r: Rect2i = qd.rect_arg(a[2])
		var d := _pt(a[0], a[1])
		qd.update_rect(a[2], Rect2i(r.position + d, r.size - 2 * d))
		return 0)
	t.install(0xa8aa, func(a: Array) -> int:                                                     ## SectRect(a, b, VAR dst): Boolean
		var r: Rect2i = qd.rect_arg(a[2]).intersection(qd.rect_arg(a[1]))
		qd.write_rect(a[0], r)
		return 0x100 if r.has_area() else 0)
	t.install(0xa8ad, func(a: Array) -> int:                                                     ## PtInRect(pt, r): Boolean
		var p := _pt(a[1] >> 16, a[1])
		return 0x100 if qd.rect_arg(a[0]).has_point(p) else 0)
	t.install(0xa8ab, func(a: Array) -> int:                                                     ## UnionRect(a, b, VAR dst)
		qd.write_rect(a[0], qd.rect_arg(a[2]).merge(qd.rect_arg(a[1])))
		return 0)
	# Pen.
	t.install(0xa89b, func(a: Array) -> int:                                                     ## PenSize(w, h)
		memory.write_u16(_port() + 0x34, a[0] & 0xffff)
		memory.write_u16(_port() + 0x36, a[1] & 0xffff)
		return 0)
	t.install(0xa89c, func(a: Array) -> int:                                                     ## PenMode
		memory.write_u16(_port() + 0x38, a[0] & 0xffff)
		return 0)
	t.install(0xa87c, func(a: Array) -> int:                                                     ## BackPat
		if not qd.is_color(memory, _port()):
			_set_pattern(_port() + 0x20, a[0])
		return 0)
	t.install(0xa89d, func(a: Array) -> int:                                                     ## PenPat
		_set_pattern(_port() + 0x3a, a[0])
		return 0)
	t.install(0xa89e, func(_a: Array) -> int:                                                    ## PenNormal
		var port: int = _port()
		memory.write_u32(port + 0x34, 0x00010001)
		memory.write_u16(port + 0x38, qd.PAT_COPY)
		for k in 8:
			memory.write_u8(port + 0x3a + k, 0xff)
		return 0)
	t.install(0xa89a, func(a: Array) -> int:                                                     ## GetPen(VAR pt)
		memory.write_u32(a[0], memory.read_u32(_port() + 0x30))
		return 0)
	t.install(0xa896, func(_a: Array) -> int:                                                    ## HidePen
		memory.write_u16(_port() + 0x42, (memory.read_s16(_port() + 0x42) - 1) & 0xffff)
		return 0)
	t.install(0xa897, func(_a: Array) -> int:                                                    ## ShowPen
		memory.write_u16(_port() + 0x42, (memory.read_s16(_port() + 0x42) + 1) & 0xffff)
		return 0)
	t.install(0xa893, func(a: Array) -> int:                                                     ## MoveTo(h, v)
		_move(_pt(a[0], a[1]))
		return 0)
	t.install(0xa894, func(a: Array) -> int:                                                     ## Move(dh, dv)
		_move(qd.pen_loc(_port()) + _pt(a[0], a[1]))
		return 0)
	t.install(0xa891, func(a: Array) -> int:                                                     ## LineTo(h, v)
		_line(_pt(a[0], a[1]))
		return 0)
	t.install(0xa892, func(a: Array) -> int:                                                     ## Line(dh, dv)
		_line(qd.pen_loc(_port()) + _pt(a[0], a[1]))
		return 0)
	# Polygons.
	t.install(0xa8cb, func(_a: Array) -> int:                                                    ## OpenPoly
		qd.poly_open = machine.toolbox.heap.new_handle(10, true)
		qd.poly_points = []
		return qd.poly_open)
	t.install(0xa8cc, func(_a: Array) -> int:                                                    ## ClosePoly
		qd.close_poly()
		return 0)
	t.install(0xa8cd, func(_a: Array) -> int: return 0)                                          ## KillPoly
	t.install(0xa8ce, func(a: Array) -> int:                                                     ## OffsetPoly(poly, dh, dv)
		var p: int = memory.read_u32(a[2])
		var d := _pt(a[0], a[1])
		var r: Rect2i = qd.read_rect(p + 2)
		qd.write_rect(p + 2, Rect2i(r.position + d, r.size))
		for i in (memory.read_u16(p) - 10) / 4:
			memory.write_u16(p + 10 + 4 * i, (memory.read_s16(p + 10 + 4 * i) + d.y) & 0xffff)
			memory.write_u16(p + 12 + 4 * i, (memory.read_s16(p + 12 + 4 * i) + d.x) & 0xffff)
		return 0)
	t.install(0xa8c6, func(a: Array) -> int:                                                     ## FramePoly
		var pts: Array = qd.poly_of(a[0])
		for i in range(1, pts.size()):
			qd.draw_line(_port(), pts[i - 1], pts[i])
		return 0)
	t.install(0xa8c7, func(a: Array) -> int:                                                     ## PaintPoly
		qd.fill_poly(_port(), qd.poly_of(a[0]), qd.pen_rows(_port()), qd.pen_mode(_port()))
		return 0)
	t.install(0xa8c8, func(a: Array) -> int:                                                     ## ErasePoly
		qd.fill_poly(_port(), qd.poly_of(a[0]), _bk_rows(), qd.PAT_COPY)
		return 0)
	t.install(0xa8c9, func(a: Array) -> int:                                                     ## InvertPoly
		qd.fill_poly(_port(), qd.poly_of(a[0]), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], qd.PAT_XOR)
		return 0)
	t.install(0xa8ca, func(a: Array) -> int:                                                     ## FillPoly(poly, pat)
		qd.fill_poly(_port(), qd.poly_of(a[1]), qd.pattern_arg(a[0]), qd.PAT_COPY)
		return 0)
	t.install(0xa876, func(a: Array) -> int:                                                     ## PortSize(width, height)
		var r: Rect2i = qd.read_rect(_port() + 0x10)
		qd.write_rect(_port() + 0x10, Rect2i(r.position, _pt(a[0], a[1])))
		return 0)
	# Shapes.
	t.install(0xa8a1, func(a: Array) -> int:                                                     ## FrameRect
		if qd.record_shape(qd.rect_arg(a[0]), false):
			return 0
		qd.frame_rect(_port(), qd.rect_arg(a[0]))
		return 0)
	t.install(0xa8a2, func(a: Array) -> int:                                                     ## PaintRect
		qd.fill_rect(_port(), qd.rect_arg(a[0]), qd.pen_rows(_port()), qd.pen_mode(_port()))
		return 0)
	t.install(0xaa1e, func(a: Array) -> int:                                                     ## GetCIcon(id)
		var bytes: PackedByteArray = Files.load_bytes("cicn", qd.s16(a[0]))
		if bytes.is_empty():
			return 0
		var h: int = qd.heap.handle_with(bytes)
		_cicons[h] = Images.cicn(bytes)["masked"]
		return h)
	t.install(0xaa1f, func(a: Array) -> int:                                                     ## PlotCIcon(r, icon)
		var image = _cicons.get(a[0] & 0xffffffff)
		if image != null:
			qd.draw_image(_port(), image, qd.rect_arg(a[1]))
		return 0)
	t.install(0xaa25, func(a: Array) -> int:                                                     ## DisposCIcon
		_cicons.erase(a[0] & 0xffffffff)
		return 0)
	t.install(0xa8a3, func(a: Array) -> int:                                                     ## EraseRect
		qd.fill_rect(_port(), qd.rect_arg(a[0]), _bk_rows(), qd.PAT_COPY)
		return 0)
	t.install(0xa8a4, func(a: Array) -> int:                                                     ## InvertRect
		qd.fill_rect(_port(), qd.rect_arg(a[0]), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], qd.PAT_XOR)
		return 0)
	t.install(0xa8a5, func(a: Array) -> int:                                                     ## FillRect(r, pat)
		qd.fill_rect(_port(), qd.rect_arg(a[1]), qd.pattern_arg(a[0]), qd.PAT_COPY)
		return 0)
	t.install(0xa8b0, func(a: Array) -> int:                                                     ## FrameRoundRect(r, ow, oh)
		if qd.record_shape(qd.rect_arg(a[2]), false):
			return 0
		qd.frame_round(_port(), qd.rect_arg(a[2]), qd.s16(a[1]), qd.s16(a[0]))
		return 0)
	t.install(0xa8b1, func(a: Array) -> int:                                                     ## PaintRoundRect
		qd.paint_round(_port(), qd.rect_arg(a[2]), qd.s16(a[1]), qd.s16(a[0]), qd.pen_rows(_port()), qd.pen_mode(_port()))
		return 0)
	t.install(0xa8b2, func(a: Array) -> int:                                                     ## EraseRoundRect
		qd.paint_round(_port(), qd.rect_arg(a[2]), qd.s16(a[1]), qd.s16(a[0]), _bk_rows(), qd.PAT_COPY)
		return 0)
	t.install(0xa8b3, func(a: Array) -> int:                                                     ## InvertRoundRect
		qd.paint_round(_port(), qd.rect_arg(a[2]), qd.s16(a[1]), qd.s16(a[0]), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], qd.PAT_XOR)
		return 0)
	t.install(0xa8b7, func(a: Array) -> int:                                                     ## FrameOval
		var r: Rect2i = qd.rect_arg(a[0])
		if qd.record_shape(r, true):
			return 0
		qd.frame_round(_port(), r, r.size.x, r.size.y)
		return 0)
	t.install(0xa8b8, func(a: Array) -> int:                                                     ## PaintOval
		var r: Rect2i = qd.rect_arg(a[0])
		qd.paint_round(_port(), r, r.size.x, r.size.y, qd.pen_rows(_port()), qd.pen_mode(_port()))
		return 0)
	t.install(0xa8b9, func(a: Array) -> int:                                                     ## EraseOval
		var r: Rect2i = qd.rect_arg(a[0])
		qd.paint_round(_port(), r, r.size.x, r.size.y, _bk_rows(), qd.PAT_COPY)
		return 0)
	# Colour.
	t.install(0xa862, func(a: Array) -> int: return _classic(false, a[0]))                       ## ForeColor(classic)
	t.install(0xa863, func(a: Array) -> int: return _classic(true, a[0]))                        ## BackColor(classic)
	t.install(0xaa14, func(a: Array) -> int: return _rgb(0x24, a[0]))                             ## RGBForeColor(rgb)
	t.install(0xaa15, func(a: Array) -> int: return _rgb(0x2a, a[0]))                             ## RGBBackColor(rgb)
	t.install(0xaa19, func(a: Array) -> int:                                                     ## GetForeColor(VAR rgb)
		for k in 6:
			memory.write_u8(a[0] + k, memory.read_u8(_port() + 0x24 + k))
		return 0)
	t.install(0xaa1a, func(a: Array) -> int:                                                     ## GetBackColor(VAR rgb)
		for k in 6:
			memory.write_u8(a[0] + k, memory.read_u8(_port() + 0x2a + k))
		return 0)
	# Text.
	t.install(0xa887, func(a: Array) -> int:                                                     ## TextFont
		memory.write_u16(_port() + 0x44, a[0] & 0xffff)
		return 0)
	t.install(0xa888, func(a: Array) -> int:                                                     ## TextFace
		memory.write_u8(_port() + 0x46, a[0] & 0xff)
		return 0)
	t.install(0xa889, func(a: Array) -> int:                                                     ## TextMode
		memory.write_u16(_port() + 0x48, a[0] & 0xffff)
		return 0)
	t.install(0xa88a, func(a: Array) -> int:                                                     ## TextSize
		memory.write_u16(_port() + 0x4a, a[0] & 0xffff)
		return 0)
	t.install(0xa884, func(a: Array) -> int:                                                     ## DrawString
		qd.draw_text(_port(), qd.pstr_arg(a[0]))
		return 0)
	t.install(0xa883, func(a: Array) -> int:                                                     ## DrawChar
		qd.draw_text(_port(), PackedByteArray([a[0] & 0xff]))
		return 0)
	t.install(0xa885, func(a: Array) -> int:                                                     ## DrawText(buf, first, count)
		var out := PackedByteArray()
		for k in qd.s16(a[0]):
			out.append(memory.read_u8(a[2] + qd.s16(a[1]) + k))
		qd.draw_text(_port(), out)
		return 0)
	t.install(0xa88c, func(a: Array) -> int:                                                     ## StringWidth: word
		return qd.string_width(_port(), qd.pstr_arg(a[0])))
	t.install(0xa88d, func(a: Array) -> int:                                                     ## CharWidth: word
		return qd.string_width(_port(), PackedByteArray([a[0] & 0xff])))
	t.install(0xa886, func(a: Array) -> int:                                                     ## TextWidth(buf, first, count)
		var out := PackedByteArray()
		for k in qd.s16(a[0]):
			out.append(memory.read_u8(a[2] + qd.s16(a[1]) + k))
		return qd.string_width(_port(), out))
	t.install(0xa88b, func(a: Array) -> int:                                                     ## GetFontInfo(VAR info)
		var m: Array = qd.font_info(_port())
		for k in 4:
			memory.write_u16(a[0] + 2 * k, m[k])
		return 0)
	# Bits and pictures.
	t.install(0xa8ec, func(a: Array) -> int:                                                     ## CopyBits(src, dst, sr, dr, mode, mask)
		var dst: Array = qd.bitmap_at(a[4])
		var port: int = _port()
		var clip := Rect2i(-32768, -32768, 65535, 65535)
		if qd.port_bits(port)[0] == dst[0]:
			clip = qd.clip_of(port)
		qd.copy_bits(qd.bitmap_at(a[5]), dst, qd.rect_arg(a[3]), qd.rect_arg(a[2]), a[1] & 0xffff, clip)
		return 0)
	t.install(0xa8f6, func(a: Array) -> int:                                                     ## DrawPicture(pic, r)
		var image: Image = machine.toolbox.resources.picture_image(a[1])
		if image != null:
			qd.draw_image(_port(), image, qd.rect_arg(a[0]))
		return 0)
	t.install(0xa8f5, func(_a: Array) -> int: return 0)                                          ## KillPicture

func _bk_rows() -> Array:
	var rows: Array = []
	if qd.is_color(memory, _port()):
		return [0, 0, 0, 0, 0, 0, 0, 0]
	for k in 8:
		rows.append(memory.read_u8(_port() + 0x20 + k))
	return rows

func _set_pattern(at: int, arg) -> void:
	var rows: Array = qd.pattern_arg(arg)
	for k in 8:
		memory.write_u8(at + k, rows[k])

## A classic colour constant (blackColor 33, whiteColor 30, ...): kept as is in an old port; a colour
## port takes its RGB and pixel value.
func _classic(background: bool, constant: int) -> int:
	var port: int = _port()
	if qd.is_color(memory, port):
		var c: Color = qd._palette[qd.CLASSIC.get(constant & 0xffffffff, qd.WHITE if background else qd.BLACK)]
		qd.set_rgb(port, background, c.r8 * 0x101, c.g8 * 0x101, c.b8 * 0x101)
	else:
		memory.write_u32(port + (0x54 if background else 0x50), constant & 0xffffffff)
	return 0

## A port's colour (RGB, 16 bits each) set from the RGBColor at `rgb` (field offset in the port).
## An RGBColor by address, or by value as the ports pass it in two longs ([red << 16 | green,
## blue << 16 | the word after]).
func _rgb(field: int, rgb) -> int:
	var c: Array
	if rgb is Array:
		c = [(int(rgb[0]) >> 16) & 0xffff, int(rgb[0]) & 0xffff, (int(rgb[1]) >> 16) & 0xffff]
	else:
		c = [memory.read_u16(rgb), memory.read_u16(rgb + 2), memory.read_u16(rgb + 4)]
	var port: int = _port()
	if qd.is_color(memory, port):
		qd.set_rgb(port, field == 0x2a, c[0], c[1], c[2])
	else:
		var black: bool = c[0] + c[1] + c[2] < 0x18000
		memory.write_u32(port + (0x50 if field == 0x24 else 0x54), 33 if black else 30)
	return 0

## A point in the current port moved by its bitmap's origin: local to global (-1) or back (+1).
func _shift_point(at: int, sign: int) -> int:
	var origin: Vector2i = qd.port_bits(_port())[2].position
	var p := Vector2i(memory.read_s16(at + 2), memory.read_s16(at))
	p += sign * origin
	memory.write_u16(at, p.y & 0xffff)
	memory.write_u16(at + 2, p.x & 0xffff)
	return 0

func _move(to: Vector2i) -> void:
	if qd.recording():
		qd.record_point(to, true)
	qd.set_pen_loc(_port(), to)

func _line(to: Vector2i) -> void:
	var port: int = _port()
	if qd.recording():
		if qd.poly_open != 0 and qd.poly_points.is_empty():
			qd.record_point(qd.pen_loc(port), true)
		qd.record_point(to, false)
	else:
		qd.draw_line(port, qd.pen_loc(port), to)
	qd.set_pen_loc(port, to)
