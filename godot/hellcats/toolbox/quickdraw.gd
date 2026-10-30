extends RefCounted

## QuickDraw over the machine's memory, as Inside Macintosh lays its structures out, drawing into
## any bitmap the ports name (the 640 x 480 8-bit screen, offscreen 1- or 8-bit maps). Pixels of an
## 8-bit map are indices into the default 8-bit colour table (0 white .. 255 black).
##
## Ports: GrafPort (portBits +2: baseAddr, rowBytes, bounds; portRect +0x10; visRgn +0x18; clipRgn
## +0x1c; bkPat +0x20; fillPat +0x28; pnLoc +0x30; pnSize +0x34; pnMode +0x38; pnPat +0x3a; pnVis
## +0x42; txFont +0x44; txFace +0x46; txMode +0x48; txSize +0x4a; fgColor +0x50; bkColor +0x54) and
## CGrafPort (portPixMap +2 a handle, portVersion +6 with its two high bits set, rgbFgColor +0x24,
## rgbBkColor +0x2a). Local coordinates map to the bitmap through its bounds' top left. Regions are
## kept as their bounding rects (rgnSize 10); clipping is the port rect, clip and visible regions'
## intersection.
##
## Arguments arrive last-pushed first (a Pascal routine's parameters reversed); a string the port
## logs by value comes as an Array of its bytes (length first), a rect as an Array of two longs.

const Glyphs := preload("res://hellcats/toolbox/glyph_cache.gd")
const Images := preload("res://strict_port/ui/resource_images.gd")

const WHITE := 0
const BLACK := 255
## Offsets below the thePort variable (QuickDraw globals).
const QD_RAND_SEED := -126
const QD_SCREEN_BITS := -122
const QD_ARROW := -108
const QD_DK_GRAY := -40
const QD_LT_GRAY := -32
const QD_GRAY := -24
const QD_BLACK := -16
const QD_WHITE := -8
## Pen and transfer modes.
const SRC_COPY := 0
const SRC_OR := 1
const SRC_XOR := 2
const SRC_BIC := 3
const PAT_COPY := 8
const PAT_OR := 9
const PAT_XOR := 10
const PAT_BIC := 11
## Classic QuickDraw colours (ForeColor / BackColor).
const CLASSIC := {33: BLACK, 30: WHITE, 205: 35, 341: 185, 409: 210, 273: 180, 137: 30, 69: 5}

var machine
var memory
var heap
var glyphs
var globals: int = 0
var width: int
var height: int
var main_device: int = 0
var _palette: Array = []

func _init(owner, memory_manager) -> void:
	machine = owner
	memory = owner.memory
	heap = memory_manager
	width = owner.SCREEN_WIDTH
	height = owner.SCREEN_HEIGHT
	glyphs = Glyphs.new()
	_palette = Images.clut8()

# ---- arguments -----------------------------------------------------------------------------------

static func s16(v: int) -> int:
	v &= 0xffff
	return v - 0x10000 if v >= 0x8000 else v

## A rect argument: its address, or two longs (top << 16 | left, bottom << 16 | right) when the
## port passes it by value (as its test stubs logged it). A routine that changes a rect in place
## (InsetRect, OffsetRect) cannot reach a rect passed by value, so its result is kept and applied to
## the next use of the same value, as the in-place change would have been.
var _rect_edits: Dictionary = {}

func rect_arg(arg) -> Rect2i:
	if arg is Array:
		var key := "%d:%d" % [int(arg[0]), int(arg[1])]
		if _rect_edits.has(key):
			return _rect_edits[key]
		var a: int = int(arg[0])
		var b: int = int(arg[1])
		return Rect2i(s16(a), s16(a >> 16), s16(b) - s16(a), s16(b >> 16) - s16(a >> 16))
	return read_rect(int(arg))

## A rect changed in place: written back to its address. A rect the port passed by value is looked
## for in the frames below the ports' stack pointers (where the caller keeps its locals: the first
## match going down from each) and written back there; only when it is nowhere is the change kept
## for its by-value key.
func update_rect(arg, r: Rect2i) -> void:
	if not arg is Array:
		write_rect(int(arg), r)
		return
	var key := "%d:%d" % [int(arg[0]), int(arg[1])]
	var at: int = _frame_rect(int(arg[0]) & 0xffffffff, int(arg[1]) & 0xffffffff)
	if at != 0:
		write_rect(at, r)
		_rect_edits.erase(key)
	else:
		_rect_edits[key] = r

const FRAME_SEARCH := 0x400

func _frame_rect(a: int, b: int) -> int:
	for port in machine.segments.all_ports():
		if not machine.segments.has_stack_pointer(port):
			continue
		var top: int = int(port.a7)
		if top <= machine.STACK_LIMIT or top > machine.STACK_TOP:
			continue
		var p: int = top - 2
		while p >= top - FRAME_SEARCH:
			if memory.read_u32(p) == a and memory.read_u32(p + 4) == b:
				return p
			p -= 2
	return 0

func read_rect(at: int) -> Rect2i:
	var top: int = memory.read_s16(at)
	var left: int = memory.read_s16(at + 2)
	return Rect2i(left, top, memory.read_s16(at + 6) - left, memory.read_s16(at + 4) - top)

func write_rect(at: int, r: Rect2i) -> void:
	memory.write_u16(at, r.position.y & 0xffff)
	memory.write_u16(at + 2, r.position.x & 0xffff)
	memory.write_u16(at + 4, r.end.y & 0xffff)
	memory.write_u16(at + 6, r.end.x & 0xffff)

## A Pascal string argument (its address, or an Array of its bytes) as bytes without the length.
func pstr_arg(arg) -> PackedByteArray:
	var out := PackedByteArray()
	if arg is Array:
		for k in range(1, mini(arg.size(), int(arg[0]) + 1)):
			out.append(int(arg[k]))
		return out
	var at: int = int(arg)
	if at == 0:
		return out
	for k in memory.read_u8(at):
		out.append(memory.read_u8(at + 1 + k))
	return out

func pattern_arg(arg) -> Array:
	var rows: Array = []
	for k in 8:
		rows.append(int(arg[k]) if arg is Array else memory.read_u8(int(arg) + k))
	return rows

# ---- ports -----------------------------------------------------------------------------------------

func the_port() -> int:
	return memory.read_u32(globals) if globals != 0 else 0

static func is_color(m, port: int) -> bool:
	return (m.read_u16(port + 6) & 0xc000) == 0xc000

## The port's bitmap: [baseAddr, rowBytes, bounds, depth].
func port_bits(port: int) -> Array:
	if is_color(memory, port):
		var pm: int = memory.read_u32(memory.read_u32(port + 2))
		return [memory.read_u32(pm), memory.read_u16(pm + 4) & 0x3fff, read_rect(pm + 6), maxi(memory.read_u16(pm + 0x20), 1)]
	return [memory.read_u32(port + 2), memory.read_u16(port + 6) & 0x3fff, read_rect(port + 8), 1 if (memory.read_u16(port + 6) & 0x8000) == 0 else 8]

## A bitmap or PixMap argument (CopyBits): [baseAddr, rowBytes, bounds, depth]. A colour port's
## portBits (port + 2) is its PixMap's handle, marked by the two high bits of the rowBytes field
## (portVersion): QuickDraw follows the handle then.
func bitmap_at(at: int) -> Array:
	var rb: int = memory.read_u16(at + 4)
	if (rb & 0xc000) == 0xc000:
		return bitmap_at(memory.read_u32(memory.read_u32(at)))
	if (rb & 0x8000) != 0:
		return [memory.read_u32(at), rb & 0x3fff, read_rect(at + 6), maxi(memory.read_u16(at + 0x20), 1)]
	return [memory.read_u32(at), rb & 0x3fff, read_rect(at + 6), 1]

func region_rect(rgn: int) -> Rect2i:
	if rgn == 0 or memory.read_u32(rgn) == 0:
		return Rect2i(-32768, -32768, 65535, 65535)
	return read_rect(memory.read_u32(rgn) + 2)

## The port's drawable area, in local coordinates.
func clip_of(port: int) -> Rect2i:
	_clip_oval = ovals.get(memory.read_u32(port + 0x1c) & 0xffffffff, Rect2i())
	var r: Rect2i = read_rect(port + 0x10)
	r = r.intersection(region_rect(memory.read_u32(port + 0x1c)))
	return r.intersection(region_rect(memory.read_u32(port + 0x18)))

func init_port(port: int, color: bool) -> void:
	for k in (0x6c if not color else 0x6c):
		memory.write_u8(port + k, 0)
	if color:
		var pm: int = heap.new_handle(50, true)
		var p: int = memory.read_u32(pm)
		memory.write_u32(p, machine.SCREEN_BASE)
		memory.write_u16(p + 4, width | 0x8000)
		write_rect(p + 6, Rect2i(0, 0, width, height))
		memory.write_u16(p + 0x20, 8)
		memory.write_u32(port + 2, pm)
		memory.write_u16(port + 6, 0xc000)
		for k in 3:
			memory.write_u16(port + 0x2a + 2 * k, 0xffff)
	else:
		memory.write_u32(port + 2, machine.SCREEN_BASE)
		memory.write_u16(port + 6, width | 0x8000)
		write_rect(port + 8, Rect2i(0, 0, width, height))
	write_rect(port + 0x10, Rect2i(0, 0, width, height))
	memory.write_u32(port + 0x18, new_region(Rect2i(0, 0, width, height)))
	memory.write_u32(port + 0x1c, new_region(Rect2i(-32767, -32767, 65534, 65534)))
	for k in 8:
		if not color:      # a CGrafPort holds its pattern handles and RGB colours there instead
			memory.write_u8(port + 0x20 + k, 0)
			memory.write_u8(port + 0x28 + k, 0xff)
		memory.write_u8(port + 0x3a + k, 0xff)
	memory.write_u32(port + 0x34, 0x00010001)
	memory.write_u16(port + 0x38, PAT_COPY)
	memory.write_u16(port + 0x48, SRC_OR)           # txMode: OpenPort's srcOr
	memory.write_u16(port + 0x4a, 0)
	memory.write_u32(port + 0x50, BLACK if color else 33)
	memory.write_u32(port + 0x54, WHITE if color else 30)

func new_region(r: Rect2i) -> int:
	var h: int = heap.new_handle(10, true)
	var p: int = memory.read_u32(h)
	memory.write_u16(p, 10)
	write_rect(p + 2, r)
	return h

func set_region(rgn: int, r: Rect2i) -> void:
	if r.size.x <= 0 or r.size.y <= 0:
		r = Rect2i()
	write_rect(memory.read_u32(rgn) + 2, r)
	ovals.erase(rgn & 0xffffffff)

## Regions that are one oval (framed alone between OpenRgn and CloseRgn: an instrument face's clip)
## keep it here besides their bounding rect; clipping to such a region tests the oval too.
var ovals: Dictionary = {}           ## region handle -> the oval's rect
var _clip_oval := Rect2i()           ## the oval of the clip the drawing in progress uses

## `dst` becomes `src` (its rect, and its oval when it has one).
func copy_region(src: int, dst: int) -> void:
	set_region(dst, region_rect(src))
	if ovals.has(src & 0xffffffff):
		ovals[dst & 0xffffffff] = ovals[src & 0xffffffff]

func offset_region(rgn: int, by: Vector2i) -> void:
	var r: Rect2i = region_rect(rgn)
	var oval = ovals.get(rgn & 0xffffffff)
	set_region(rgn, Rect2i(r.position + by, r.size))
	if oval != null:
		ovals[rgn & 0xffffffff] = Rect2i(oval.position + by, oval.size)

## Whether a point is in a region: its rect, and its oval when it is one.
func point_in_region(rgn: int, p: Vector2i) -> bool:
	if not region_rect(rgn).has_point(p):
		return false
	var oval = ovals.get(rgn & 0xffffffff)
	return oval == null or not _outside_oval(oval, p.x, p.y)

func _outside_clip_oval(x: int, y: int) -> bool:
	return _outside_oval(_clip_oval, x, y)

static func _outside_oval(o: Rect2i, x: int, y: int) -> bool:
	var rx: float = o.size.x / 2.0
	var ry: float = o.size.y / 2.0
	var dx: float = (x + 0.5 - o.position.x - rx) / rx
	var dy: float = (y + 0.5 - o.position.y - ry) / ry
	return dx * dx + dy * dy > 1.0

# ---- polygons and recorded regions ---------------------------------------------------------------

## While a polygon is open (OpenPoly) the pen's moves and lines record its points instead of drawing;
## while a region is open (OpenRgn) they record its extent (regions are kept as rects).
var poly_open: int = 0
var poly_points: Array = []
var rgn_open := false
var rgn_points: Array = []
var rgn_ovals: Array = []              ## ovals framed while the region is open

func recording() -> bool:
	return poly_open != 0 or rgn_open

## A framed shape while a region is open: its corners recorded (and an oval's rect), not drawn.
func record_shape(r: Rect2i, oval: bool) -> bool:
	if not rgn_open:
		return false
	rgn_points.append(r.position)
	rgn_points.append(r.end)
	if oval:
		rgn_ovals.append(r)
	return true

func record_point(p: Vector2i, start: bool) -> void:
	if poly_open != 0:
		if poly_points.is_empty() or not start:
			poly_points.append(p)
		else:
			poly_points.append(p)
	if rgn_open:
		rgn_points.append(p)

## A Polygon: polySize, polyBBox, then the points (v, h).
func close_poly() -> void:
	var h: int = poly_open
	poly_open = 0
	if h == 0:
		return
	heap.set_handle_size(h, 10 + 4 * poly_points.size())
	var p: int = memory.read_u32(h)
	memory.write_u16(p, 10 + 4 * poly_points.size())
	var box := Rect2i(poly_points[0] if poly_points.size() > 0 else Vector2i.ZERO, Vector2i.ZERO)
	for q in poly_points:
		box = box.expand(q)
	write_rect(p + 2, box)
	for i in poly_points.size():
		memory.write_u16(p + 10 + 4 * i, poly_points[i].y & 0xffff)
		memory.write_u16(p + 12 + 4 * i, poly_points[i].x & 0xffff)

func poly_of(h: int) -> Array:
	var p: int = memory.read_u32(h)
	var out: Array = []
	for i in (memory.read_u16(p) - 10) / 4:
		out.append(Vector2i(memory.read_s16(p + 12 + 4 * i), memory.read_s16(p + 10 + 4 * i)))
	return out

## The polygon filled by scanlines (even-odd, pixel centres), with a pattern through a mode.
func fill_poly(port: int, points: Array, rows: Array, mode: int, fg: int = -1, bk: int = -1) -> void:
	if points.size() < 3:
		return
	var top: int = points[0].y
	var bottom: int = points[0].y
	for q in points:
		top = mini(top, q.y)
		bottom = maxi(bottom, q.y)
	for y in range(top, bottom):
		var fy: float = y + 0.5
		var xs: Array = []
		for i in points.size():
			var a: Vector2i = points[i]
			var b: Vector2i = points[(i + 1) % points.size()]
			if (a.y <= fy and b.y > fy) or (b.y <= fy and a.y > fy):
				xs.append(a.x + (fy - a.y) * (b.x - a.x) / float(b.y - a.y))
		xs.sort()
		for k in range(0, xs.size() - 1, 2):
			var x0: int = int(round(xs[k]))
			var x1: int = int(round(xs[k + 1]))
			if x1 > x0:
				fill_rect(port, Rect2i(x0, y, x1 - x0, 1), rows, mode, fg, bk)

# ---- colours --------------------------------------------------------------------------------------

## The nearest device-table index to a 16-bit RGB colour (the Palette Manager's table once it
## exists, else the default table).
func color_index(r16: int, g16: int, b16: int) -> int:
	if machine.toolbox != null and machine.toolbox.palettes != null:
		return machine.toolbox.palettes.nearest(Color8(r16 >> 8, g16 >> 8, b16 >> 8))
	var best: int = 0
	var best_d: int = 1 << 60
	for k in 256:
		var c: Color = _palette[k]
		var d: int = int(pow(c.r8 - (r16 >> 8), 2) + pow(c.g8 - (g16 >> 8), 2) + pow(c.b8 - (b16 >> 8), 2))
		if d < best_d:
			best_d = d
			best = k
	return best

## The pixel values drawn with: a colour port keeps them in fgColor / bkColor (+0x50 / +0x54) as
## Color QuickDraw does (the index of its RGB colour, or the value the program stores there); an old
## port keeps the classic colour constants there.
func fg_index(port: int) -> int:
	if is_color(memory, port):
		return memory.read_u32(port + 0x50) & 0xff
	return CLASSIC.get(memory.read_u32(port + 0x50), BLACK)

func bk_index(port: int) -> int:
	if is_color(memory, port):
		return memory.read_u32(port + 0x54) & 0xff
	return CLASSIC.get(memory.read_u32(port + 0x54), WHITE)

## A colour port's foreground or background set from 16-bit RGB: the RGB field and the pixel value.
func set_rgb(port: int, background: bool, r16: int, g16: int, b16: int) -> void:
	var field: int = 0x2a if background else 0x24
	memory.write_u16(port + field, r16)
	memory.write_u16(port + field + 2, g16)
	memory.write_u16(port + field + 4, b16)
	memory.write_u32(port + (0x54 if background else 0x50), color_index(r16, g16, b16))

# ---- pixels ---------------------------------------------------------------------------------------

## Writes one pixel of a bitmap at global (bitmap) coordinates through a transfer mode, where `on`
## says whether the source / pattern bit is set.
func _plot(bits: Array, x: int, y: int, on: bool, mode: int, fg: int, bk: int) -> void:
	var bounds: Rect2i = bits[2]
	if not bounds.has_point(Vector2i(x, y)):
		return
	if _clip_oval.has_area() and _outside_clip_oval(x, y):
		return
	var depth: int = bits[3]
	var row: int = bits[0] + (y - bounds.position.y) * bits[1]
	var col: int = x - bounds.position.x
	var m: int = mode & 3
	if depth == 1:
		var at: int = row + (col >> 3)
		var mask: int = 0x80 >> (col & 7)
		var v: int = memory.read_u8(at)
		var black: bool = (v & mask) != 0
		match m:
			0:
				black = on if (mode & 4) == 0 else not on
			1:
				black = black or on
			2:
				black = black != on
			3:
				black = black and not on
		memory.write_u8(at, (v | mask) if black else (v & ~mask))
		return
	var at8: int = row + col
	match m:
		0:
			var src: bool = on if (mode & 4) == 0 else not on
			memory.write_u8(at8, fg if src else bk)
		1:
			if on:
				memory.write_u8(at8, fg)
		2:
			if on:
				memory.write_u8(at8, 255 - memory.read_u8(at8))
		3:
			if on:
				memory.write_u8(at8, bk)

## Fills a local rect of the current port with a pattern through a pattern mode.
func fill_rect(port: int, r: Rect2i, rows: Array, mode: int, fg: int = -1, bk: int = -1) -> void:
	var bits: Array = port_bits(port)
	var area: Rect2i = r.intersection(clip_of(port))
	var origin: Vector2i = bits[2].position
	fg = fg_index(port) if fg < 0 else fg
	bk = bk_index(port) if bk < 0 else bk
	for y in range(area.position.y, area.end.y):
		var pat: int = rows[(y - origin.y) & 7]
		for x in range(area.position.x, area.end.x):
			_plot(bits, x, y, (pat >> (7 - ((x - origin.x) & 7))) & 1 == 1, mode, fg, bk)

func pen_rows(port: int) -> Array:
	var rows: Array = []
	for k in 8:
		rows.append(memory.read_u8(port + 0x3a + k))
	return rows

func pen_mode(port: int) -> int:
	return memory.read_u16(port + 0x38)

func pen_size(port: int) -> Vector2i:
	return Vector2i(maxi(memory.read_s16(port + 0x36), 0), maxi(memory.read_s16(port + 0x34), 0))

func pen_loc(port: int) -> Vector2i:
	return Vector2i(memory.read_s16(port + 0x32), memory.read_s16(port + 0x30))

func set_pen_loc(port: int, p: Vector2i) -> void:
	memory.write_u16(port + 0x30, p.y & 0xffff)
	memory.write_u16(port + 0x32, p.x & 0xffff)

## A line drawn with the pen (its size as a rect dragged along, Bresenham).
func draw_line(port: int, from: Vector2i, to: Vector2i) -> void:
	var size: Vector2i = pen_size(port)
	if size.x == 0 or size.y == 0 or memory.read_s16(port + 0x42) < 0:
		return
	var rows: Array = pen_rows(port)
	var mode: int = pen_mode(port)
	var dx: int = absi(to.x - from.x)
	var dy: int = -absi(to.y - from.y)
	var sx: int = 1 if from.x < to.x else -1
	var sy: int = 1 if from.y < to.y else -1
	var err: int = dx + dy
	var p: Vector2i = from
	while true:
		fill_rect(port, Rect2i(p, size), rows, mode)
		if p == to:
			break
		var e2: int = 2 * err
		if e2 >= dy:
			err += dy
			p.x += sx
		if e2 <= dx:
			err += dx
			p.y += sy

func frame_rect(port: int, r: Rect2i) -> void:
	var s: Vector2i = pen_size(port)
	if r.size.x <= 0 or r.size.y <= 0 or memory.read_s16(port + 0x42) < 0:
		return
	var rows: Array = pen_rows(port)
	var mode: int = pen_mode(port)
	fill_rect(port, Rect2i(r.position, Vector2i(r.size.x, s.y)), rows, mode)
	fill_rect(port, Rect2i(r.position.x, r.end.y - s.y, r.size.x, s.y), rows, mode)
	fill_rect(port, Rect2i(r.position, Vector2i(s.x, r.size.y)), rows, mode)
	fill_rect(port, Rect2i(r.end.x - s.x, r.position.y, s.x, r.size.y), rows, mode)

## An oval or round rect outline / fill: per row, the span inside the corner ellipses.
func _round_spans(r: Rect2i, ow: int, oh: int) -> Array:
	var spans: Array = []
	var rx: float = mini(ow, r.size.x) / 2.0
	var ry: float = mini(oh, r.size.y) / 2.0
	for y in range(r.position.y, r.end.y):
		var inset: int = 0
		var fy: float = y + 0.5
		var dy: float = 0.0
		if fy < r.position.y + ry:
			dy = r.position.y + ry - fy
		elif fy > r.end.y - ry:
			dy = fy - (r.end.y - ry)
		if dy > 0.0 and ry > 0.0:
			inset = int(round(rx - rx * sqrt(maxf(0.0, 1.0 - (dy / ry) * (dy / ry)))))
		spans.append([r.position.x + inset, r.end.x - inset])
	return spans

func paint_round(port: int, r: Rect2i, ow: int, oh: int, rows: Array, mode: int, fg: int = -1, bk: int = -1) -> void:
	var spans: Array = _round_spans(r, ow, oh)
	for i in spans.size():
		fill_rect(port, Rect2i(spans[i][0], r.position.y + i, spans[i][1] - spans[i][0], 1), rows, mode, fg, bk)

func frame_round(port: int, r: Rect2i, ow: int, oh: int) -> void:
	var outer: Array = _round_spans(r, ow, oh)
	var s: Vector2i = pen_size(port)
	var inner_r := Rect2i(r.position + s, r.size - 2 * s)
	var inner: Array = _round_spans(inner_r, maxi(ow - 2 * s.x, 0), maxi(oh - 2 * s.y, 0)) if inner_r.size.x > 0 and inner_r.size.y > 0 else []
	var rows: Array = pen_rows(port)
	var mode: int = pen_mode(port)
	for i in outer.size():
		var y: int = r.position.y + i
		var j: int = y - inner_r.position.y
		if j >= 0 and j < inner.size():
			fill_rect(port, Rect2i(outer[i][0], y, inner[j][0] - outer[i][0], 1), rows, mode)
			fill_rect(port, Rect2i(inner[j][1], y, outer[i][1] - inner[j][1], 1), rows, mode)
		else:
			fill_rect(port, Rect2i(outer[i][0], y, outer[i][1] - outer[i][0], 1), rows, mode)

# ---- text -----------------------------------------------------------------------------------------

func text_style(port: int) -> Array:
	return [memory.read_s16(port + 0x44), memory.read_u8(port + 0x46), memory.read_s16(port + 0x4a)]

func string_width(port: int, text: PackedByteArray) -> int:
	var style: Array = text_style(port)
	return glyphs.width(text, style[0], style[2], style[1])

## Draws the bytes at the pen (the baseline), in the port's text mode, and moves the pen past them
## (clipped to the port's clip and, when given, `within`).
func draw_text(port: int, text: PackedByteArray, within: Rect2i = Rect2i()) -> void:
	var style: Array = text_style(port)
	var pen: Vector2i = pen_loc(port)
	var bits: Array = port_bits(port)
	var clip: Rect2i = clip_of(port)
	if within.has_area():
		clip = clip.intersection(within)
	var fg: int = fg_index(port)
	var bk: int = bk_index(port)
	var mode: int = memory.read_u16(port + 0x48)
	var x: int = pen.x
	for c in text:
		var g: Dictionary = glyphs.glyph(c, style[0], style[2], style[1])
		var img: Array = g["bits"]
		for row in img.size():
			var y: int = pen.y + g["top"] + row
			for col in img[row].size():
				var px: int = x + g["left"] + col
				if img[row][col] and clip.has_point(Vector2i(px, y)):
					_plot(bits, px, y, true, SRC_OR if mode != SRC_XOR else SRC_XOR, fg, bk)
				elif mode == SRC_COPY and clip.has_point(Vector2i(px, y)):
					_plot(bits, px, y, false, SRC_COPY, fg, bk)
		x += g["advance"]
	set_pen_loc(port, Vector2i(x, pen.y))

func font_info(port: int) -> Array:
	var style: Array = text_style(port)
	return glyphs.metrics(style[0], style[2])

# ---- CopyBits -------------------------------------------------------------------------------------

## Copies (scaling) a source rect of a bitmap to a destination rect of another through a source
## mode, clipped to the destination port when it is the current port's bitmap.
func copy_bits(src: Array, dst: Array, sr: Rect2i, dr: Rect2i, mode: int, clip: Rect2i) -> void:
	if sr.size.x <= 0 or sr.size.y <= 0 or dr.size.x <= 0 or dr.size.y <= 0:
		return
	var area: Rect2i = dr.intersection(clip).intersection(dst[2])
	for y in range(area.position.y, area.end.y):
		var sy: int = sr.position.y + (y - dr.position.y) * sr.size.y / dr.size.y
		for x in range(area.position.x, area.end.x):
			var sx: int = sr.position.x + (x - dr.position.x) * sr.size.x / dr.size.x
			var v: int = _read_pixel(src, sx, sy)
			if v < 0:
				continue
			if src[3] == 1:
				_plot(dst, x, y, v == 1, mode, BLACK, WHITE)
			elif dst[3] == 8 and (mode & 3) == 0:
				_write_pixel8(dst, x, y, v)
			else:
				_plot(dst, x, y, v != WHITE, mode, v, WHITE)

func _read_pixel(bits: Array, x: int, y: int) -> int:
	var bounds: Rect2i = bits[2]
	if not bounds.has_point(Vector2i(x, y)):
		return -1
	var row: int = bits[0] + (y - bounds.position.y) * bits[1]
	var col: int = x - bounds.position.x
	if bits[3] == 1:
		return (memory.read_u8(row + (col >> 3)) >> (7 - (col & 7))) & 1
	if bits[3] == 8:
		return memory.read_u8(row + col)
	var depth: int = bits[3]
	var bit: int = col * depth
	return (memory.read_u8(row + (bit >> 3)) >> (8 - depth - (bit & 7))) & ((1 << depth) - 1)

func _write_pixel8(bits: Array, x: int, y: int, v: int) -> void:
	var bounds: Rect2i = bits[2]
	memory.write_u8(bits[0] + (y - bounds.position.y) * bits[1] + x - bounds.position.x, v)

## A texture (a PICT's derived PNG) drawn into a local rect of the port, scaled, by nearest
## default-table index.
func draw_image(port: int, image: Image, r: Rect2i) -> void:
	var bits: Array = port_bits(port)
	var area: Rect2i = r.intersection(clip_of(port))
	var cache := {}
	for y in range(area.position.y, area.end.y):
		var iy: int = (y - r.position.y) * image.get_height() / r.size.y
		for x in range(area.position.x, area.end.x):
			var c: Color = image.get_pixel((x - r.position.x) * image.get_width() / r.size.x, iy)
			if c.a < 0.5:
				continue
			var key: int = c.to_rgba32()
			if not cache.has(key):
				cache[key] = color_index(c.r8 << 8, c.g8 << 8, c.b8 << 8)
			if bits[3] == 8:
				_write_pixel8(bits, x, y, cache[key])
			else:
				_plot(bits, x, y, cache[key] > 127, SRC_COPY, BLACK, WHITE)

# ---- globals and the screen ------------------------------------------------------------------------

func init_graf(the_port: int) -> int:
	globals = the_port & 0xffffffff
	var bits: int = globals + QD_SCREEN_BITS
	memory.write_u32(bits, machine.SCREEN_BASE)
	memory.write_u16(bits + 4, width)
	write_rect(bits + 6, Rect2i(0, 0, width, height))
	var patterns := {QD_WHITE: [0, 0], QD_BLACK: [0xff, 0xff], QD_GRAY: [0xaa, 0x55], QD_LT_GRAY: [0x88, 0x22],
			QD_DK_GRAY: [0x77, 0xdd]}
	for offset in patterns:
		for row in 8:
			memory.write_u8(globals + offset + row, patterns[offset][row % 2])
	memory.write_u32(globals + QD_RAND_SEED, 1)
	return 0

## The one screen as Color QuickDraw describes it (Inside Macintosh V), in the heap: a GDevice
## (gdType +4 = 0, clutType: indexed; gdFlags +0x14: colour device, main screen, screen device;
## gdRect +0x22) whose gdPMap (+0x16) is a handle to a PixMap: baseAddr the screen, rowBytes 640 |
## 0x8000, bounds 0, 0, 480, 640, 72 dpi, pixelSize (+0x20) 8, one 8-bit component.
func make_main_device() -> void:
	var pm: int = heap.new_handle(50, true)
	var p: int = memory.read_u32(pm)
	memory.write_u32(p, machine.SCREEN_BASE)
	memory.write_u16(p + 4, width | 0x8000)
	write_rect(p + 6, Rect2i(0, 0, width, height))
	memory.write_u32(p + 0x16, 0x00480000)
	memory.write_u32(p + 0x1a, 0x00480000)
	memory.write_u16(p + 0x20, 8)
	memory.write_u16(p + 0x22, 1)
	memory.write_u16(p + 0x24, 8)
	main_device = heap.new_handle(62, true)
	var g: int = memory.read_u32(main_device)
	memory.write_u16(g + 0x14, 0xb801)
	memory.write_u32(g + 0x16, pm)
	write_rect(g + 0x22, Rect2i(0, 0, width, height))

## The screen's port for the managers' own drawing (desktop, menu bar, window frames).
var wm_port: int = 0

func window_manager_port() -> int:
	if wm_port == 0:
		wm_port = heap.new_ptr(0x6c, true)
		init_port(wm_port, false)
	return wm_port

func draw_desktop() -> void:
	var port: int = window_manager_port()
	fill_rect(port, Rect2i(0, 0, width, height), [0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55], PAT_COPY, BLACK, WHITE)
	var bar: int = machine.MENU_BAR_HEIGHT
	fill_rect(port, Rect2i(0, 0, width, bar - 1), [0, 0, 0, 0, 0, 0, 0, 0], PAT_COPY, BLACK, WHITE)
	fill_rect(port, Rect2i(0, bar - 1, width, 1), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], PAT_COPY, BLACK, WHITE)
