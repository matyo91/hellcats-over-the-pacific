extends RefCounted

## The fonts' glyphs as one-bit bitmaps, for QuickDraw's text drawing on the game thread. The
## resource fork holds no FONT / NFNT, and the Mac's own faces (Chicago for the system font, ID 0;
## Geneva, ID 3; Monaco, ID 4) are not installed with Godot, so the nearest installed face stands in,
## rasterised without antialiasing through the TextServer (prepare() on the main thread, before
## the game thread starts, for the sizes the game uses; other sizes on demand).
##
## A glyph: bits (rows of booleans), left / top (from the pen on the baseline), advance.

const FACES := {0: ["Chicago", "Charcoal", "Geneva", "Lucida Grande", "Helvetica"],
		3: ["Geneva", "Verdana", "Lucida Grande", "Helvetica"], 4: ["Monaco", "Menlo", "Courier New", "Courier"]}
const DEFAULT_SIZE := 12
const BOLD := 1

var _fonts: Dictionary = {}
var _glyphs: Dictionary = {}
var _metrics: Dictionary = {}
var _lock := Mutex.new()

func prepare() -> void:
	for spec in [[0, 12, 0], [0, 12, BOLD], [3, 9, 0], [3, 10, 0], [3, 12, 0], [3, 9, BOLD], [3, 10, BOLD], [4, 9, 0]]:
		for c in SYSTEM_GLYPHS.keys() + range(32, 256):
			glyph(c, spec[0], spec[1], spec[2])

func _font(id: int, face: int) -> Font:
	var key := "%d:%d" % [id, face & BOLD]
	if not _fonts.has(key):
		var f := SystemFont.new()
		f.font_names = PackedStringArray(FACES.get(id, FACES[0]))
		f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		f.hinting = TextServer.HINTING_NORMAL
		f.font_weight = 700 if (face & BOLD) != 0 else 400
		_fonts[key] = f
	return _fonts[key]

static func _size(size: int) -> int:
	return size if size > 0 else DEFAULT_SIZE

## The system font's own glyphs below 0x20: 0x11 the command sign, 0x12 the check mark, 0x14 the
## Apple logo.
const SYSTEM_GLYPHS := {0x11: 0x2318, 0x12: 0x2713, 0x13: 0x25c6, 0x14: 0xf8ff}

static func mac_char(c: int) -> int:
	if SYSTEM_GLYPHS.has(c):
		return SYSTEM_GLYPHS[c]
	if c < 0x80:
		return c
	return preload("res://strict_port/ui/resource_files.gd").MAC_ROMAN_HIGH[c - 0x80]

func glyph(c: int, id: int, size: int, face: int) -> Dictionary:
	size = _size(size)
	var key: int = (c << 24) | ((id & 0xff) << 16) | ((size & 0xff) << 8) | (face & 0xff)
	_lock.lock()
	var cached = _glyphs.get(key)
	_lock.unlock()
	if cached != null:
		return cached
	var g: Dictionary = _render(c, id, size, face)
	_lock.lock()
	_glyphs[key] = g
	_lock.unlock()
	return g

func _render(c: int, id: int, size: int, face: int) -> Dictionary:
	var font: Font = _font(id, face)
	var ts := TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	var cp: int = mac_char(c)
	var index: int = ts.font_get_glyph_index(rid, size, cp, 0)
	var fsize := Vector2i(size, 0)
	ts.font_render_glyph(rid, fsize, index)
	var advance: int = int(round(ts.font_get_glyph_advance(rid, size, index).x))
	var out := {"bits": [], "left": 0, "top": 0, "advance": advance}
	var uv: Rect2 = ts.font_get_glyph_uv_rect(rid, fsize, index)
	var tex: int = ts.font_get_glyph_texture_idx(rid, fsize, index)
	if tex < 0 or uv.size.x < 1 or uv.size.y < 1:
		return out
	var image: Image = ts.font_get_texture_image(rid, fsize, tex)
	var offset: Vector2 = ts.font_get_glyph_offset(rid, fsize, index)
	var bits: Array = []
	for y in int(uv.size.y):
		var row: Array = []
		for x in int(uv.size.x):
			row.append(image.get_pixel(int(uv.position.x) + x, int(uv.position.y) + y).a > 0.5)
		bits.append(row)
	out["bits"] = bits
	out["left"] = int(round(offset.x))
	out["top"] = int(round(offset.y))
	return out

func width(text: PackedByteArray, id: int, size: int, face: int) -> int:
	var w: int = 0
	for c in text:
		w += glyph(c, id, size, face)["advance"]
	return w

## [ascent, descent, widMax, leading] as GetFontInfo gives them.
func metrics(id: int, size: int) -> Array:
	size = _size(size)
	var key := "%d:%d" % [id, size]
	if not _metrics.has(key):
		var font: Font = _font(id, 0)
		_metrics[key] = [int(ceil(font.get_ascent(size))), int(ceil(font.get_descent(size))), size, 1]
	return _metrics[key]
