class_name StrictID03
extends RefCounted
## Strict translations owned by CODE segment 03 (ID03.bin; address = file offset, 4-byte header):
## the instrument panel (scaling helpers, palette matching, offscreen ports, dials, gauges). The
## sole provenance and verification record lives in mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`).
## Calls leaving the segment go through `_jt` / `_trap` / `_call_address` / `_local` (see
## StrictID02), filled by tests with logging stand-ins; ID02's abs_long (JT $4da) and memset (JT
## $4f2) run for real, as the original's jump table reaches them.

const C68kScript := preload("res://strict_port/compat/c68k.gd")
const StrictID02Script := preload("res://strict_port/code/ID02.gd")

const A5_DESIGN_SCALE: int = -0x149e   ## long: the panel's scale (design units of 480 / 4800)
const A5_COLOUR_MODE: int = -0x137a    ## word: 1 / 4 / 8 bit depth
const A5_PALETTE: int = -0x350         ## 8 RGB triples (words)
const A5_EXTRA_PALETTE: int = -0x14a6  ## long: more RGB triples ...
const A5_EXTRA_COUNT: int = -0x14a2    ## word: ... and their count
const A5_SIN: int = -0x2118            ## long: sine routine (angle in 1/0x4000 turns): 4.12 fixed
const A5_COS: int = -0x211c            ## long: cosine routine
const JT_ABS_LONG: int = 0x4da
const JT_MEMSET: int = 0x4f2
const JT_NEW_PTR: int = 0x232
const JT_DISPOSE_PTR: int = 0x23a
const TRAP_TEXT_FACE: int = 0xa888
const TRAP_TEXT_SIZE: int = 0xa88a
const TRAP_OPEN_PORT: int = 0xa86f
const TRAP_SET_PORT_BITS: int = 0xa875
const TRAP_PORT_SIZE: int = 0xa876
const TRAP_RECT_RGN: int = 0xa8df
const TRAP_CLOSE_PORT: int = 0xa87d
const TRAP_MOVE_TO: int = 0xa893
const TRAP_LINE_TO: int = 0xa891
const TRAP_OPEN_CPORT: int = 0xaa00
const TRAP_SET_PORT: int = 0xa873

var memory
var a5: int = 0
var a7: int = 0
var jt_routines: Dictionary = {}
var traps: Dictionary = {}
var code_routines: Dictionary = {}

func _init(memory_68k = null, a5_value: int = 0) -> void:
	memory = memory_68k
	a5 = a5_value

func _jt(offset: int, args: Array) -> int:
	assert(jt_routines.has(offset), "jump-table slot $%x has no routine" % offset)
	return jt_routines[offset].call(args)

func _trap(word: int, args: Array) -> int:
	assert(traps.has(word), "A-line trap %04x has no routine" % word)
	return traps[word].call(args)

## A call through a code pointer kept in an A5 global.
func _call_address(address: int, args: Array) -> int:
	assert(code_routines.has(address), "code address %x has no routine" % address)
	return code_routines[address].call(args)

## A call to a routine of this segment not ported yet, by its segment offset.
func _local(offset: int, args: Array) -> int:
	assert(code_routines.has(offset), "segment routine %x has no stand-in" % offset)
	return code_routines[offset].call(args)

func _g(offset: int) -> int:
	return C68kScript.u32(a5 + offset)

func _box(p: int) -> Array:
	return [memory.read_u32(p), memory.read_u32(p + 4)]

## 0x6: the text face and size for a design point size: plain and size * 10 / 3 (as a word) in
## 1-bit mode (A5 - 0x137a = 1), else bold and size * 10, both through scale_design_4800.
func set_scaled_text_style(size: int) -> void:
	if memory.read_u16(_g(A5_COLOUR_MODE)) == 1:
		_trap(TRAP_TEXT_FACE, [0])
		var tenths: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(C68kScript.s16(size) * 0xa)), 3)
		_trap(TRAP_TEXT_SIZE, [scale_design_4800(tenths) & 0xffff])
	else:
		_trap(TRAP_TEXT_FACE, [1])
		_trap(TRAP_TEXT_SIZE, [scale_design_4800(C68kScript.u16(C68kScript.s16(size) * 0xa)) & 0xffff])

## 0x56: (v * scale + 5) / 480 (MULU.L, DIVS.L), at least 10 (a word; D0's high word is the
## quotient's unless MOVEQ #10 clamped it).
func scale_design_480_min10(v: int) -> int:
	var q: int = C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(_scaled(v) + 5), 0x1e0))
	if C68kScript.s16(q) < 0xa:
		return 0xa
	return q

## 0x8a: v * scale / 4800 (MULU.L, DIVS.L).
func scale_design_4800(v: int) -> int:
	return C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(_scaled(v)), 0x12c0))

func _scaled(v: int) -> int:
	return C68kScript.u32(C68kScript.u32(C68kScript.s16(v)) * memory.read_u32(_g(A5_DESIGN_SCALE)))

## 0xa6: scale_design_4800 less half the current pen's width (thePort +0x36, DIVS.W 2; the low word).
func scale_design_4800_pen_centred(v: int) -> int:
	var d0: int = scale_design_4800(v)
	var half: int = C68kScript.divs_trunc(memory.read_s16(C68kScript.u32(memory.read_u32(_g(-0x160c)) + 0x36)), 2)
	return (d0 & 0xffff0000) | ((d0 - half) & 0xffff)

## 0xc8: the largest of three longs (signed).
func max3_int(a: int, b: int, c: int) -> int:
	var m: int = a if C68kScript.s32(a) >= C68kScript.s32(b) else b
	return C68kScript.u32(m if C68kScript.s32(m) >= C68kScript.s32(c) else c)

## 0xf4: the palette entry nearest an RGB triple (the largest per-channel difference, through
## ID02's abs_long): the eight colours at A5 - 0x350 first, then the extra ones (A5 - 0x14a6, count
## A5 - 0x14a2) until one is nearer (index + 8). In 1- and 4-bit modes the index, in 8-bit mode the
## index + 200 (in D0's low word; other modes leave D0 as the search did).
func nearest_palette_index_rgb(rgb: int) -> int:
	var id02 = StrictID02Script.new(memory, a5)
	var r: int = memory.read_u16(C68kScript.u32(rgb))
	var g: int = memory.read_u16(C68kScript.u32(rgb + 2))
	var b: int = memory.read_u16(C68kScript.u32(rgb + 4))
	var best: int = 0xffff
	var best_distance: int = 0x7fffffff
	var d0: int = 0
	for i in 8:
		var e: int = _g(A5_PALETTE + 6 * i)
		d0 = _distance(id02, e, r, g, b)
		if C68kScript.s32(d0) < C68kScript.s32(best_distance):
			best = i
			best_distance = d0
	var i: int = 0
	while true:
		d0 = (d0 & 0xffff0000) | (i & 0xffff)
		if i >= memory.read_s16(_g(A5_EXTRA_COUNT)):
			break
		var e: int = C68kScript.u32(6 * i + memory.read_u32(_g(A5_EXTRA_PALETTE)))
		d0 = _distance(id02, e, r, g, b)
		if C68kScript.s32(d0) < C68kScript.s32(best_distance):
			d0 = (d0 & 0xffff0000) | ((i + 8) & 0xffff)
			best = i + 8
			best_distance = d0
			break
		i += 1
	var mode: int = memory.read_u16(_g(A5_COLOUR_MODE))
	if mode == 4 or mode == 1:
		return (d0 & 0xffff0000) | (best & 0xffff)
	if mode == 8:
		return (d0 & 0xffff0000) | ((best + 0xc8) & 0xffff)
	return d0

func _distance(id02, e: int, r: int, g: int, b: int) -> int:
	var dr: int = id02.abs_long(C68kScript.u32(memory.read_u16(e) - r))
	var dg: int = id02.abs_long(C68kScript.u32(memory.read_u16(e + 2) - g))
	var db: int = id02.abs_long(C68kScript.u32(memory.read_u16(e + 4) - b))
	return max3_int(dr, dg, db)

## 0x2a8: a 1-bit offscreen port w x h: bits (rows of (w / 16) * 2 + 2 bytes) and the port record
## (0x6c) from NewPtr, OpenPort, SetPortBits from the frame's bitmap, portRect and PortSize set,
## the visible region the rect; returns the port.
func new_offscreen_bw_port(width: int, height: int) -> int:
	assert(a7 != 0, "new_offscreen_bw_port needs a7 (its frame holds the bitmap)")
	var a6: int = a7 - 4
	memory.write_u16(a6 - 6, 0)
	memory.write_u16(a6 - 8, 0)
	memory.write_u16(a6 - 2, width & 0xffff)
	memory.write_u16(a6 - 4, height & 0xffff)
	var row_bytes: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(width), 0x10) * 2 + 2)
	memory.write_u16(a6 - 0xa, row_bytes)
	var size: int = C68kScript.u32(C68kScript.u32(C68kScript.s16(height)) * C68kScript.u32(C68kScript.s16(row_bytes)))
	memory.write_u32(a6 - 0xe, C68kScript.u32(_jt(JT_NEW_PTR, [size])))
	var port: int = C68kScript.u32(_jt(JT_NEW_PTR, [0x6c]))
	memory.write_u32(a6 - 0x12, port)
	_trap(TRAP_OPEN_PORT, [port])
	_trap(TRAP_SET_PORT_BITS, [[memory.read_u32(a6 - 0xe), memory.read_u32(a6 - 0xa), memory.read_u32(a6 - 6)]])
	memory.write_u32(port + 0x10, memory.read_u32(a6 - 8))
	memory.write_u32(port + 0x14, memory.read_u32(a6 - 4))
	_trap(TRAP_PORT_SIZE, [height & 0xffff, width & 0xffff])
	_trap(TRAP_RECT_RGN, [_box(a6 - 8), memory.read_u32(port + 0x18)])
	return port

## 0x33c: ClosePort, then the bits and the record disposed.
func dispose_offscreen_bw_port(port: int) -> void:
	_trap(TRAP_CLOSE_PORT, [C68kScript.u32(port)])
	_jt(JT_DISPOSE_PTR, [memory.read_u32(C68kScript.u32(port + 2))])
	_jt(JT_DISPOSE_PTR, [C68kScript.u32(port)])

## 0x5718: an arc of the dial in `rect` from `start` degrees for `sweep` degrees, in 5-degree steps
## (the sweep extended by one step): each point at the radius (half the width) from the centre via
## the sine / cosine routines (A5 - 0x2118 / -0x211c; angles (deg - 90) * 0x4000 / 360 wrapped into
## 0..0x4000, products >> 12); the first point is MoveTo'd and returned through out_h / out_v, the
## rest LineTo'd.
func dial_point_at_angle(rect: int, start: int, sweep: int, out_h: int, out_v: int) -> void:
	var p: int = C68kScript.u32(rect)
	var cx: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_u16(p + 6) + memory.read_u16(p + 2))), 2)
	var cy: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_u16(p + 4) + memory.read_u16(p))), 2)
	var radius: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_u16(p + 6) - memory.read_u16(p + 2))), 2)
	var step: int = -5 if C68kScript.s16(sweep) < 0 else 5
	var left: int = C68kScript.u16(sweep + step)
	var angle: int = start & 0xffff
	while left != 0:
		var turn: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.u32(C68kScript.s16(angle) - 0x5a), 14)), 0x168)
		while turn < 0:
			turn += 0x4000
		while turn > 0x4000:
			turn -= 0x4000
		var s: int = C68kScript.u32(_call_address(memory.read_u32(_g(A5_SIN)), [C68kScript.u32(turn)]))
		var x: int = C68kScript.u16(C68kScript.asr32(C68kScript.u32(C68kScript.u32(radius) * s), 12) + cx)
		var c: int = C68kScript.u32(_call_address(memory.read_u32(_g(A5_COS)), [C68kScript.u32(turn)]))
		var y: int = C68kScript.u16(C68kScript.asr32(C68kScript.u32(C68kScript.u32(radius) * c), 12) + cy)
		if angle == start & 0xffff:
			memory.write_u16(C68kScript.u32(out_h), x)
			memory.write_u16(C68kScript.u32(out_v), y)
			_trap(TRAP_MOVE_TO, [y, x])
		else:
			_trap(TRAP_LINE_TO, [y, x])
		angle = C68kScript.u16(angle + step)
		left = C68kScript.u16(left - step)

## 0x5c36: a colour port record (0x6c bytes, cleared through ID02's memset) opened (OpenCPort, the
## current port A5 - 0x160c restored) on a buffer: its pixel map's base, row bytes and bounds, its
## portRect and visible region the rect (passed by value); returns the port.
func open_cport_on_buffer(port: int, row_bytes: int, base: int, rect_top_left: int, rect_bottom_right: int) -> int:
	assert(a7 != 0, "open_cport_on_buffer needs a7 (its rect argument is on the stack)")
	var p: int = C68kScript.u32(port)
	StrictID02Script.new(memory, a5).ansi_memset(p, 0, 0x6c)
	var saved: int = memory.read_u32(_g(-0x160c))
	_trap(TRAP_OPEN_CPORT, [p])
	_trap(TRAP_SET_PORT, [saved])
	var pm: int = memory.read_u32(memory.read_u32(p + 2))
	memory.write_u16(pm + 4, row_bytes & 0xffff)
	pm = memory.read_u32(memory.read_u32(p + 2))
	memory.write_u32(pm, C68kScript.u32(base))
	pm = memory.read_u32(memory.read_u32(p + 2))
	memory.write_u32(pm + 6, C68kScript.u32(rect_top_left))
	memory.write_u32(pm + 0xa, C68kScript.u32(rect_bottom_right))
	memory.write_u32(p + 0x10, C68kScript.u32(rect_top_left))
	memory.write_u32(p + 0x14, C68kScript.u32(rect_bottom_right))
	_trap(TRAP_RECT_RGN, [[C68kScript.u32(rect_top_left), C68kScript.u32(rect_bottom_right)], memory.read_u32(p + 0x18)])
	return p

## 0x5cb6: ClosePort.
func close_port_glue(port: int) -> void:
	_trap(TRAP_CLOSE_PORT, [C68kScript.u32(port)])

## 0x71a2: remap_cached_panel_colours with the identity table (256 words in the frame) and
## A5 - 0x1354.
func remap_panel_colours_identity() -> void:
	assert(a7 != 0, "remap_panel_colours_identity needs a7 (its frame holds the table)")
	var table: int = a7 - 4 - 0x200
	for k in 0x100:
		memory.write_u16(table + 2 * k, k)
	var entry: int = a7
	a7 = entry - 4 - 0x200 - 4 - 8 - 4
	remap_cached_panel_colours(table, memory.read_u32(_g(-0x1354)))
	a7 = entry

const JT_ROUND_H: int = 0x3ca          ## (C, word): the horizontal panel coordinate for a design one
const JT_ROUND_V: int = 0x382          ## (C, word): the vertical one
const A5_PANEL_PORT: int = -0x1496     ## long: the panel's port
const A5_GLYPHS: int = -0x20b0         ## 6 vector glyphs: character, width, then (dx, dy) pairs to 'c'
const A5_DIGITS: int = -0x1fde         ## 10 vector digits: (dx, dy) pairs to 'c'
const TRAP_PEN_SIZE: int = 0xa89b
const TRAP_INSET_RECT: int = 0xa8a9
const TRAP_NEW_RGN: int = 0xa8d8
const TRAP_OPEN_RGN: int = 0xa8da
const TRAP_CLOSE_RGN: int = 0xa8db
const TRAP_FRAME_OVAL: int = 0xa8b7
const TRAP_OFFSET_RECT: int = 0xa8a8
const TRAP_COPY_BITS: int = 0xa8ec

## 0x3832: a region framing the inset oval of an instrument face of design `size` centred at (h, v):
## the rect's top left from JT $382 / $3ca (+1), its size scale_design_4800(size) - 2, inset by
## scale_design_4800(50) each way; FrameOval recorded into a new region (returned).
func make_inset_face_oval_region(rect: int, size: int, h: int, v: int) -> int:
	var r: int = C68kScript.u32(rect)
	_trap(TRAP_PEN_SIZE, [1, 1])
	var half: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	memory.write_u16(r + 2, C68kScript.u16(_jt(JT_ROUND_H, [C68kScript.u16(v - half)]) + 1))
	memory.write_u16(r, C68kScript.u16(_jt(JT_ROUND_V, [C68kScript.u16(h - half)]) + 1))
	memory.write_u16(r + 6, C68kScript.u16(scale_design_4800(size) + memory.read_u16(r + 2) - 2))
	memory.write_u16(r + 4, C68kScript.u16(scale_design_4800(size) + memory.read_u16(r) - 2))
	var dh: int = scale_design_4800(0x32) & 0xffff
	var dv: int = scale_design_4800(0x32) & 0xffff
	_trap(TRAP_INSET_RECT, [dv, dh, _box(r)])
	var rgn: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_OPEN_RGN, [])
	_trap(TRAP_FRAME_OVAL, [_box(r)])
	_trap(TRAP_CLOSE_RGN, [rgn])
	return rgn

## 0x146a: an instrument's supersampled bitmap (in `port`) put on the panel at the design point
## (a, b) less half the size: in 1-bit mode copied (srcBic) into the panel port A5 - 0x1496 at the
## offset portRect; otherwise antialias_downsample_bw_3x (the colour at A5 - 0x1fa6 is pushed too but
## never read).
func composite_instrument_bitmap(port: int, size: int, _unused: int, a: int, b: int) -> void:
	assert(a7 != 0, "composite_instrument_bitmap needs a7 (its frame holds the rect)")
	var a6: int = a7 - 4
	var p: int = C68kScript.u32(port)
	var w: int = scale_design_4800(size) & 0xffff
	var hgt: int = scale_design_4800(size) & 0xffff
	var half: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	var dh: int = _jt(JT_ROUND_H, [C68kScript.u16(b - half)]) & 0xffff
	var dv: int = _jt(JT_ROUND_V, [C68kScript.u16(a - half)]) & 0xffff
	if memory.read_u16(_g(A5_COLOUR_MODE)) == 1:
		memory.write_u32(a6 - 0x10, memory.read_u32(p + 0x10))
		memory.write_u32(a6 - 0xc, memory.read_u32(p + 0x14))
		_trap(TRAP_OFFSET_RECT, [dv, dh, _box(a6 - 0x10)])
		_trap(TRAP_COPY_BITS, [0, 3, _box(a6 - 0x10), _box(p + 0x10), C68kScript.u32(memory.read_u32(_g(A5_PANEL_PORT)) + 2),
				C68kScript.u32(p + 2)])
	else:
		var entry: int = a7
		a7 = entry - 4 - 0x10 - 0x16 - 4
		antialias_downsample_bw_3x(p, dh, dv, w, hgt, 0)
		a7 = entry

## 0x1844: the panel port made current, the bitmap composited and its offscreen port disposed.
func finish_instrument_supersample(port: int, size: int, a: int, b: int) -> void:
	var entry: int = a7
	_trap(TRAP_SET_PORT, [memory.read_u32(_g(A5_PANEL_PORT))])
	a7 = entry - 4 - 0xc - 4
	composite_instrument_bitmap(port, size, 0, a, b)
	a7 = entry
	dispose_offscreen_bw_port(port)

## A vector glyph's strokes from (x, y) at `scale`: MoveTo the first point, LineTo the rest until
## 'c', each through scale_design_4800_pen_centred.
func _strokes(q: int, x: int, y: int, scale: int) -> void:
	var px: int = x
	var py: int = y
	var first: bool = true
	while first or memory.read_u8(q) != 0x63:
		px = C68kScript.u16(px + C68kScript.s16(C68kScript.u16(C68kScript.s8(memory.read_u8(q)) * C68kScript.s16(scale))))
		var hh: int = scale_design_4800_pen_centred(px) & 0xffff
		py = C68kScript.u16(py + C68kScript.s16(C68kScript.u16(C68kScript.s8(memory.read_u8(q + 1)) * C68kScript.s16(scale))))
		var vv: int = scale_design_4800_pen_centred(py) & 0xffff
		_trap(TRAP_MOVE_TO if first else TRAP_LINE_TO, [vv, hh])
		q = C68kScript.u32(q + 2)
		first = false

func _glyph_for(c: int) -> int:
	for k in 6:
		var g: int = memory.read_u32(_g(A5_GLYPHS + 4 * k))
		if memory.read_u8(g) == c:
			return g
	return 0

## 0x77e: a string of vector glyphs (A5 - 0x20b0: character, width, strokes) at `scale`, centred
## on x (half of every glyph's (width + 1) * scale but the last's taken off), then drawn advancing
## by (width + 1) * scale; characters without a glyph are skipped.
func draw_vector_glyph_string_centred(text: int, scale: int, x: int, y: int) -> void:
	var s: int = C68kScript.u32(text)
	var cx: int = x & 0xffff
	var p: int = s
	while memory.read_u8(C68kScript.u32(p + 1)) != 0:
		var g: int = _glyph_for(memory.read_u8(p))
		if g != 0:
			var w: int = C68kScript.s16(C68kScript.u16((C68kScript.s8(memory.read_u8(g + 1)) + 1) * C68kScript.s16(scale)))
			cx = C68kScript.u16(cx - C68kScript.divs_trunc(w, 2))
		p = C68kScript.u32(p + 1)
	while memory.read_u8(s) != 0:
		var g: int = _glyph_for(memory.read_u8(s))
		if g != 0:
			_strokes(C68kScript.u32(g + 2), cx, y, scale)
			cx = C68kScript.u16(cx + C68kScript.u16((C68kScript.s8(memory.read_u8(g + 1)) + 1) * C68kScript.s16(scale)))
		s = C68kScript.u32(s + 1)

## 0x912: a non-negative number in vector digits (A5 - 0x1fde) at `scale`, 6 * scale apart,
## centred on x.
func draw_vector_number(n: int, scale: int, x: int, y: int) -> void:
	var digits: Array = [0, 0, 0, 0, 0]
	var k: int = 5
	var v: int = C68kScript.s16(n)
	while true:
		k -= 1
		digits[k] = v - C68kScript.divs_trunc(v, 0xa) * 0xa
		v = C68kScript.divs_trunc(v, 0xa)
		if v == 0:
			break
	var cx: int = C68kScript.u16(x - C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16((4 - k) * 6 * C68kScript.s16(scale))), 2))
	while k < 5:
		var d: int = digits[k]
		k += 1
		_strokes(memory.read_u32(_g(A5_DIGITS + 4 * d)), cx, y, scale)
		cx = C68kScript.u16(cx + C68kScript.s16(scale) * 6)

const JT_PANEL_COLOUR: int = 0x45a     ## (C: r, g, b words): a panel colour
const JT_FORE_PANEL_COLOUR: int = 0x36a  ## (C, colour)
const JT_BACK_PANEL_COLOUR: int = 0x3a2  ## (C, colour)
const JT_PANEL_PATTERN: int = 0x3e2    ## (C): the fill pattern
const TRAP_OPEN_POLY: int = 0xa8cb
const TRAP_CLOSE_POLY: int = 0xa8cc
const TRAP_KILL_POLY: int = 0xa8cd
const TRAP_FILL_POLY: int = 0xa8ca
const TRAP_PAINT_POLY: int = 0xa8c7
const TRAP_PAINT_RECT: int = 0xa8a2
const TRAP_FRAME_RECT: int = 0xa8a1

func _panel_colour(level: int) -> int:
	return _jt(JT_PANEL_COLOUR, [level, level, level]) & 0xffff

## A closed polygon through the points (h, v) given as pairs of the routine's eight words.
func _poly(points: Array) -> int:
	var poly: int = C68kScript.u32(_trap(TRAP_OPEN_POLY, []))
	_trap(TRAP_MOVE_TO, [points[0][1] & 0xffff, points[0][0] & 0xffff])
	for k in range(1, points.size()):
		_trap(TRAP_LINE_TO, [points[k][1] & 0xffff, points[k][0] & 0xffff])
	_trap(TRAP_CLOSE_POLY, [])
	return poly

## 0x3f24: a bevelled frame between the outer corners (h0, v0)-(h3, v3) and the inner ones
## (h1, v1)-(h2, v2): the top and left bevels filled light (foreground 1, background 0, the panel
## pattern JT $3e2), the bottom and right dark (3 / 4), the face painted in colour 2.
func draw_bevelled_frame(h0: int, v0: int, h1: int, v1: int, h2: int, v2: int, h3: int, v3: int) -> void:
	for side in [[1, 0, [[h0, v0], [h3, v0], [h2, v1], [h1, v1], [h0, v0]]],
			[1, 0, [[h0, v0], [h1, v1], [h1, v2], [h0, v3], [h0, v0]]],
			[3, 4, [[h0, v3], [h3, v3], [h2, v2], [h1, v2], [h0, v3]]]]:
		_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(side[0])])
		_jt(JT_BACK_PANEL_COLOUR, [_panel_colour(side[1])])
		var poly: int = _poly(side[2])
		_trap(TRAP_FILL_POLY, [C68kScript.u32(_jt(JT_PANEL_PATTERN, [])), poly])
		_trap(TRAP_KILL_POLY, [poly])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(2)])
	var face: int = _poly([[h3, v0], [h2, v1], [h2, v2], [h3, v3], [h3, v0]])
	_trap(TRAP_PAINT_POLY, [face])
	_trap(TRAP_KILL_POLY, [face])

## 0x4b32: a display box of design size w x h centred at (a, b): painted in colour 0, framed in
## colour 2, its left and right halves (split at the middle, inset by 3) kept at A5 - 0x119c and
## A5 - 0x1194.
func draw_split_display_box(width: int, height: int, _unused: int, a: int, b: int) -> void:
	assert(a7 != 0, "draw_split_display_box needs a7 (its frame holds the rect)")
	var a6: int = a7 - 4
	var rect: int = a6 - 0xa
	_trap(TRAP_PEN_SIZE, [1, 1])
	memory.write_u16(a6 - 8, _jt(JT_ROUND_H, [C68kScript.u16(b - C68kScript.divs_trunc(C68kScript.s16(width), 2))]) & 0xffff)
	memory.write_u16(rect, _jt(JT_ROUND_V, [C68kScript.u16(a - C68kScript.divs_trunc(C68kScript.s16(height), 2))]) & 0xffff)
	memory.write_u16(a6 - 4, C68kScript.u16(scale_design_4800(width) + memory.read_u16(a6 - 8)))
	memory.write_u16(a6 - 6, C68kScript.u16(scale_design_4800(height) + memory.read_u16(rect)))
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_PAINT_RECT, [_box(rect)])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(2)])
	_trap(TRAP_FRAME_RECT, [_box(rect)])
	_trap(TRAP_INSET_RECT, [3, 3, _box(rect)])
	var span: int = C68kScript.u16(memory.read_u16(a6 - 4) - memory.read_u16(a6 - 8))
	memory.write_u16(a6 - 0x20, span)
	memory.write_u16(a6 - 4, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(span), 2) + memory.read_u16(a6 - 8) - 1))
	memory.write_u32(_g(-0x119c), memory.read_u32(rect))
	memory.write_u32(_g(-0x1198), memory.read_u32(rect + 4))
	memory.write_u16(a6 - 4, C68kScript.u16(memory.read_u16(a6 - 8) + span))
	memory.write_u16(a6 - 8, C68kScript.u16(memory.read_u16(a6 - 4) - C68kScript.divs_trunc(C68kScript.s16(span), 2) + 1))
	memory.write_u32(_g(-0x1194), memory.read_u32(rect))
	memory.write_u32(_g(-0x1190), memory.read_u32(rect + 4))

func _dial(routine: int, angle: int) -> int:
	return C68kScript.u32(_call_address(memory.read_u32(_g(routine)), [C68kScript.u32(angle)]))

static func _fx(r: int, f: int) -> int:
	return C68kScript.asr32(C68kScript.u32(C68kScript.u32(r) * f), 12)

## 0x5158: the 13 ticks of an arc scale (angles (i * 0x1555 / 12 - 0xaab) & 0x3fff): every fourth
## long (4 x `length`) with a pen of width / 10, the others 2 x `length` with 2 * width / 30; from
## the radius inwards, mirrored left when `clockwise` is 0.
func draw_arc_scale_ticks(radius: int, length: int, width: int, cy: int, cx: int, clockwise: int) -> void:
	var r: int = C68kScript.s16(radius)
	for i in 0xd:
		var angle: int = (C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(i * 0x1555)), 0xc) + 0xfffff555) & 0x3fff
		var tick: int
		if i % 4 == 0:
			var pen: int = C68kScript.divs_trunc(C68kScript.s16(width), 0xa) & 0xffff
			_trap(TRAP_PEN_SIZE, [pen, pen])
			tick = C68kScript.u16(length << 2)
		else:
			var pen: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(width * 2)), 0x1e) & 0xffff
			_trap(TRAP_PEN_SIZE, [pen, pen])
			tick = C68kScript.u16(length * 2)
		var inner: int = C68kScript.s16(C68kScript.u16(r - tick))
		var x1: int
		var x2: int
		if clockwise & 0xffff != 0:
			x1 = C68kScript.u16(_fx(r, _dial(A5_SIN, angle)) + C68kScript.s16(cx))
			x2 = C68kScript.u16(_fx(inner, _dial(A5_SIN, angle)) + C68kScript.s16(cx))
		else:
			x1 = C68kScript.u16(C68kScript.s16(cx) - _fx(r, _dial(A5_SIN, angle)))
			x2 = C68kScript.u16(C68kScript.s16(cx) - _fx(inner, _dial(A5_SIN, angle)))
		var y2: int = C68kScript.u16(C68kScript.s16(cy) - _fx(inner, _dial(A5_COS, angle)))
		var y1: int = C68kScript.u16(C68kScript.s16(cy) - _fx(r, _dial(A5_COS, angle)))
		var h1: int = scale_design_4800_pen_centred(x1) & 0xffff
		_trap(TRAP_MOVE_TO, [scale_design_4800_pen_centred(y1) & 0xffff, h1])
		var h2: int = scale_design_4800_pen_centred(x2) & 0xffff
		_trap(TRAP_LINE_TO, [scale_design_4800_pen_centred(y2) & 0xffff, h2])

const TRAP_SET_RES_LOAD: int = 0xa99b
const TRAP_GET_RESOURCE: int = 0xa9a0
const TRAP_RMVE_RESOURCE: int = 0xa9ad
const TRAP_ADD_RESOURCE: int = 0xa9ab
const TRAP_RES_ERROR: int = 0xa9af
const TRAP_UPDATE_RES_FILE: int = 0xa999
const TRAP_CHANGED_RESOURCE: int = 0xa9aa
const PANEL_TYPE: int = 0x48454c32     ## 'HEL2'

## 0x4110: a numbered box in `rect`: painted in colour 0 inside a bevel (JT $3ca(20) - JT $3ca(0)
## wide, draw_bevelled_frame), the rect becoming the inner one; the number drawn in vector digits
## (colour 4 in 1-bit mode, else 3) at the box's design centre, the pen and scale from the design
## scale (at least 1 and 10).
func draw_numbered_bevel_box(rect: int, number: int) -> void:
	assert(a7 != 0, "draw_numbered_bevel_box needs a7 (its frame holds the inner rect)")
	var a6: int = a7 - 4
	var r: int = C68kScript.u32(rect)
	var outer: int = _jt(JT_ROUND_H, [0x14]) & 0xffff
	var bevel: int = C68kScript.u16(outer - _jt(JT_ROUND_H, [0]))
	var left: int = memory.read_u16(r + 2)
	var top: int = memory.read_u16(r)
	var right: int = memory.read_u16(r + 6)
	var bottom: int = memory.read_u16(r + 4)
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	memory.write_u16(a6 - 6, C68kScript.u16(left + bevel))
	memory.write_u16(a6 - 8, C68kScript.u16(top + bevel))
	memory.write_u16(a6 - 2, C68kScript.u16(right - bevel))
	memory.write_u16(a6 - 4, C68kScript.u16(bottom - bevel))
	_trap(TRAP_PAINT_RECT, [_box(a6 - 8)])
	draw_bevelled_frame(left, top, C68kScript.u16(left + bevel), C68kScript.u16(top + bevel), C68kScript.u16(right - bevel),
			C68kScript.u16(bottom - bevel), right, bottom)
	memory.write_u32(r, memory.read_u32(a6 - 8))
	memory.write_u32(r + 4, memory.read_u32(a6 - 4))
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(4 if memory.read_u16(_g(A5_COLOUR_MODE)) == 1 else 3)])
	var cx: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(right - left)), 2) + right)
	var cy: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(bottom - top)), 2) + top)
	var scale: int = C68kScript.s16(C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(0xa * memory.read_u32(_g(A5_DESIGN_SCALE)))), 0x1e0)))
	if scale < 1:
		scale = 1
	var pen: int = C68kScript.s16(scale_design_480_min10(0xc))
	if pen < 0xa:
		pen = 0xa
	var p: int = C68kScript.divs_trunc(pen, 0xa) & 0xffff
	_trap(TRAP_PEN_SIZE, [p, p])
	var design: int = memory.read_s32(_g(A5_DESIGN_SCALE))
	var x: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(C68kScript.s16(cx)) * 0x12c0)), design)
	var y: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(C68kScript.s16(cy)) * 0x12c0)), design)
	draw_vector_number(number, scale & 0xffff, x & 0xffff, y & 0xffff)

## 0x5860: the panel's screen layout: rows from JT $382 (-300, -100, 100 + 2, 300 + 2, 0) and
## columns from JT $3ca (0, -300, -100, 100 + 2, 300 + 2, each made even) stored at A5 - 0x1150 ..
## -0x113e; four screen addresses (row * rowBytes A5 - 0x1378 + base A5 - 0x1382 + column / (8 /
## depth)) at A5 - 0x113c .. -0x1130.
func compute_panel_screen_addresses() -> void:
	var r1: int = C68kScript.s16(_jt(JT_ROUND_V, [0xfed4]))
	memory.write_u16(_g(-0x1150), r1 & 0xffff)
	var r2: int = C68kScript.s16(_jt(JT_ROUND_V, [0xff9c]))
	memory.write_u16(_g(-0x114e), r2 & 0xffff)
	var r3: int = C68kScript.s16(C68kScript.u16(_jt(JT_ROUND_V, [0x64]) + 2))
	memory.write_u16(_g(-0x114c), r3 & 0xffff)
	var r4: int = C68kScript.s16(C68kScript.u16(_jt(JT_ROUND_V, [0x12c]) + 2))
	memory.write_u16(_g(-0x114a), r4 & 0xffff)
	var c1: int = _even_column(0, 0)
	memory.write_u16(_g(-0x1148), c1 & 0xffff)
	var c2: int = _even_column(0xfed4, 0)
	memory.write_u16(_g(-0x1146), c2 & 0xffff)
	var c3: int = _even_column(0xff9c, 0)
	memory.write_u16(_g(-0x1144), c3 & 0xffff)
	var c4: int = _even_column(0x64, 2)
	memory.write_u16(_g(-0x1142), c4 & 0xffff)
	var c5: int = _even_column(0x12c, 2)
	memory.write_u16(_g(-0x1140), c5 & 0xffff)
	var r0: int = C68kScript.s16(_jt(JT_ROUND_V, [0]))
	memory.write_u16(_g(-0x113e), r0 & 0xffff)
	var divisor: int = C68kScript.s16(C68kScript.divs_trunc(8, memory.read_s16(_g(A5_COLOUR_MODE))))
	for pair in [[-0x113c, r1, c1], [-0x1138, r3, c1], [-0x1134, r0, c2], [-0x1130, r0, c4]]:
		var row: int = C68kScript.u32(C68kScript.u32(memory.read_s16(_g(-0x1378))) * C68kScript.u32(pair[1]))
		memory.write_u32(_g(pair[0]), C68kScript.u32(row + memory.read_u32(_g(-0x1382)) + C68kScript.divs_trunc(pair[2], divisor)))

func _even_column(design: int, extra: int) -> int:
	var h: int = C68kScript.s16(_jt(JT_ROUND_H, [design]))
	return C68kScript.s16(C68kScript.u16(C68kScript.divs_trunc(h, 2) * 2 + extra))

## 0x5ab6: the four panel bitmaps (handles A5 - 0x12b0 / -0x11f6 / -0x11dc / -0x11d4, names
## A5 - 0xe0a ..) stored as 'HEL2' resources (scenery A5 - 0x13ae + 200 / 300 / 400 / 500): the old
## ones removed (resources not loaded meanwhile), the file updated, each added (ResError summed);
## the scenery record (*(A5 - 0x13b2) + 0x160 * scenery) +0xc set to 1 on success, else cleared and
## A5 - 0x14a0 set; the record marked changed and the file updated.
func store_panel_bitmaps_as_resources() -> void:
	var scenery: int = memory.read_u16(_g(-0x13ae))
	var errors: int = 0
	_trap(TRAP_SET_RES_LOAD, [0])
	for k in 4:
		var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [C68kScript.u16(scenery + 0xc8 + 0x64 * k), PANEL_TYPE]))
		if h != 0:
			_trap(TRAP_RMVE_RESOURCE, [h])
	_trap(TRAP_SET_RES_LOAD, [1])
	_trap(TRAP_UPDATE_RES_FILE, [memory.read_u16(_g(-0x1002))])
	var handles: Array = [-0x12b0, -0x11f6, -0x11dc, -0x11d4]
	for k in 4:
		_trap(TRAP_ADD_RESOURCE, [memory.read_u32(_g(-0xe0a + 4 * k)), C68kScript.u16(scenery + 0xc8 + 0x64 * k), PANEL_TYPE,
				memory.read_u32(_g(handles[k]))])
		errors = C68kScript.u16(errors + _trap(TRAP_RES_ERROR, []))
	var rec: int = C68kScript.u32(C68kScript.s16(scenery) * 0x160 + memory.read_u32(memory.read_u32(_g(-0x13b2))))
	if errors != 0:
		memory.write_u16(rec + 0xc, 0)
		memory.write_u16(_g(-0x14a0), 1)
	else:
		memory.write_u16(rec + 0xc, 1)
	_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(_g(-0x13b2))])
	_trap(TRAP_UPDATE_RES_FILE, [memory.read_u16(_g(-0x1002))])

const TRAP_SET_CLIP: int = 0xa879
const TRAP_DISPOSE_RGN: int = 0xa8d9
const TRAP_SET_ORIGIN: int = 0xa878

## 0x1538: an instrument's offscreen port at the face's size (`*size` design units): in 1-bit mode
## at 1x, otherwise at 3x with a 2-pixel margin (the origin at -2, -2 and *a / *b tripled). Its clip
## is the face oval (inset by 20 design units + 1, or x3 + 3); the face's half-width x 10 and
## centre x 10 come back through out_half / out_x / out_y, computed with the design scale held at
## 480 (A5 - 0x149e, restored from its low word); in 1-bit mode *b is at least 15. *factor = 1 or 3.
func begin_instrument_supersample(size: int, a: int, b: int, _unused: int, port_out: int, out_half: int, out_x: int, out_y: int,
		factor: int) -> void:
	assert(a7 != 0, "begin_instrument_supersample needs a7 (its frame holds the face rect)")
	var entry: int = a7
	var a6: int = entry - 4
	var three: bool = memory.read_u16(_g(A5_COLOUR_MODE)) != 1
	var k: int = 3 if three else 1
	var margin: int = 6 if three else 0
	if three:
		memory.write_u16(C68kScript.u32(a), C68kScript.u16(memory.read_s16(C68kScript.u32(a)) * 3))
		memory.write_u16(C68kScript.u32(b), C68kScript.u16(memory.read_s16(C68kScript.u32(b)) * 3))
	var w: int = C68kScript.u16(scale_design_4800(memory.read_u16(C68kScript.u32(size))) * k)
	var h: int = C68kScript.u16(scale_design_4800(memory.read_u16(C68kScript.u32(size))) * k + margin)
	a7 = entry - 4 - 0x10 - 4 - 4
	var port: int = new_offscreen_bw_port(C68kScript.u16(w + margin), h)
	a7 = entry
	memory.write_u32(C68kScript.u32(port_out), port)
	if three:
		_trap(TRAP_SET_ORIGIN, [0xfffe, 0xfffe])
	_face_rect(a6, size, k)
	var rgn: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_OPEN_RGN, [])
	_trap(TRAP_FRAME_OVAL, [_box(a6 - 8)])
	_trap(TRAP_CLOSE_RGN, [rgn])
	_trap(TRAP_SET_CLIP, [rgn])
	_trap(TRAP_DISPOSE_RGN, [rgn])
	var saved: int = memory.read_s16(_g(-0x149c))
	memory.write_u32(_g(A5_DESIGN_SCALE), 0x1e0)
	_face_rect(a6, size, k)
	var right: int = memory.read_u16(a6 - 2)
	var left: int = memory.read_u16(a6 - 6)
	memory.write_u16(C68kScript.u32(out_half), C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16((right - left) * 0xa)), 2)))
	var centre: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16((right + left) * 0xa)), 2))
	memory.write_u16(C68kScript.u32(out_y), centre)
	memory.write_u16(C68kScript.u32(out_x), centre)
	if not three and memory.read_s16(C68kScript.u32(b)) < 0xf:
		memory.write_u16(C68kScript.u32(b), 0xf)
	memory.write_u32(_g(A5_DESIGN_SCALE), C68kScript.u32(saved))
	memory.write_u16(C68kScript.u32(factor), k)

## The face rect (0, 0, scale(*size) * k) in the frame at -8, inset by scale(20) * k + k.
func _face_rect(a6: int, size: int, k: int) -> void:
	memory.write_u16(a6 - 6, 0)
	memory.write_u16(a6 - 8, 0)
	memory.write_u16(a6 - 4, C68kScript.u16(scale_design_4800(memory.read_u16(C68kScript.u32(size))) * k))
	memory.write_u16(a6 - 2, C68kScript.u16(scale_design_4800(memory.read_u16(C68kScript.u32(size))) * k))
	var dh: int = C68kScript.u16(scale_design_4800(0x14) * k + k)
	var dv: int = C68kScript.u16(scale_design_4800(0x14) * k + k)
	_trap(TRAP_INSET_RECT, [dv, dh, _box(a6 - 8)])

const TRAP_GET_CLIP: int = 0xa87a
const TRAP_PAINT_OVAL: int = 0xa8b8

## 0x35e: a small spinning disc (design size A5 - 0x2114) centred at (h, v): painted in colour 2;
## when it is at least 5 pixels, a black spoke for the phase A5 - 0x2112 (vertical, the two
## diagonals clipped to the disc, horizontal), the phase advancing by 5 mod 4. The clip is restored.
func draw_spinning_disc_indicator(h: int, v: int) -> void:
	assert(a7 != 0, "draw_spinning_disc_indicator needs a7 (its frame holds the rect)")
	var a6: int = a7 - 4
	var saved: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_GET_CLIP, [saved])
	var disc: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	var size: int = memory.read_u16(_g(-0x2114))
	var half: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	var left: int = _jt(JT_ROUND_H, [C68kScript.u16(h - half)]) & 0xffff
	var top: int = _jt(JT_ROUND_V, [C68kScript.u16(v - half)]) & 0xffff
	var right: int = C68kScript.u16(scale_design_4800(size) + left)
	var bottom: int = C68kScript.u16(scale_design_4800(size) + top)
	memory.write_u16(a6 - 0xc, top)
	memory.write_u16(a6 - 0xa, left)
	memory.write_u16(a6 - 8, bottom)
	memory.write_u16(a6 - 6, right)
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(2)])
	_trap(TRAP_PAINT_OVAL, [_box(a6 - 0xc)])
	_trap(TRAP_OPEN_RGN, [])
	_trap(TRAP_FRAME_OVAL, [_box(a6 - 0xc)])
	_trap(TRAP_CLOSE_RGN, [disc])
	var cx: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(right - left)), 2) + left)
	var cy: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(bottom - top)), 2) + top)
	if C68kScript.s16(scale_design_4800(memory.read_u16(_g(-0x2114)))) >= 5:
		_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
		var phase: int = memory.read_u16(_g(-0x2112))
		match phase:
			0:
				_trap(TRAP_MOVE_TO, [top, cx])
				_trap(TRAP_LINE_TO, [C68kScript.u16(bottom - 1), cx])
			1:
				_trap(TRAP_SET_CLIP, [disc])
				_trap(TRAP_MOVE_TO, [top, left])
				_trap(TRAP_LINE_TO, [C68kScript.u16(bottom - 1), C68kScript.u16(right - 1)])
			2:
				_trap(TRAP_SET_CLIP, [disc])
				_trap(TRAP_MOVE_TO, [top, C68kScript.u16(right - 1)])
				_trap(TRAP_LINE_TO, [C68kScript.u16(bottom - 1), left])
			_:
				_trap(TRAP_MOVE_TO, [cy, left])
				_trap(TRAP_LINE_TO, [cy, C68kScript.u16(right - 1)])
		memory.write_u16(_g(-0x2112), (phase + 5) & 3)
	_trap(TRAP_SET_CLIP, [saved])
	_trap(TRAP_DISPOSE_RGN, [disc])
	_trap(TRAP_DISPOSE_RGN, [saved])

## 0x514: a black ring (design size, framed in colour 2 with a pen of `pen` / 10) centred at (h, v)
## and a spinning disc 30 units beyond it for each status bit: 0 top left, 1 top right, 2 bottom
## right, 3 bottom left (at 45 degrees: half the size x 0xb50 >> 12), 4 straight below.
func draw_ring_with_status_indicators(size: int, pen: int, v: int, h: int, flags: int) -> void:
	assert(a7 != 0, "draw_ring_with_status_indicators needs a7 (its frame holds the rect)")
	var entry: int = a7
	var a6: int = entry - 4
	var half: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	memory.write_u16(a6 - 6, _jt(JT_ROUND_H, [C68kScript.u16(h - half)]) & 0xffff)
	memory.write_u16(a6 - 8, _jt(JT_ROUND_V, [C68kScript.u16(v - half)]) & 0xffff)
	memory.write_u16(a6 - 2, C68kScript.u16(scale_design_4800(size) + memory.read_u16(a6 - 6)))
	memory.write_u16(a6 - 4, C68kScript.u16(scale_design_4800(size) + memory.read_u16(a6 - 8)))
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_PAINT_OVAL, [_box(a6 - 8)])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(2)])
	var p: int = C68kScript.divs_trunc(C68kScript.s16(pen), 0xa) & 0xffff
	_trap(TRAP_PEN_SIZE, [p, p])
	_trap(TRAP_FRAME_OVAL, [_box(a6 - 8)])
	var d: int = C68kScript.asr32(C68kScript.u32(C68kScript.u32(half) * 0xb50), 12)
	var spots: Array = [[-1, -1], [1, -1], [1, 1], [-1, 1]]
	a7 = entry - 4 - 0xc - 4 - 4
	for bit in 4:
		if flags & (1 << bit) != 0:
			var x: int = C68kScript.u16(C68kScript.s16(h) + spots[bit][0] * (d + 0x1e))
			var y: int = C68kScript.u16(C68kScript.s16(v) + spots[bit][1] * (d + 0x1e))
			draw_spinning_disc_indicator(x, y)
	if flags & 0x10 != 0:
		draw_spinning_disc_indicator(h & 0xffff, C68kScript.u16(half + C68kScript.s16(v) + 0x1e))
	a7 = entry

const TRAP_TEXT_FONT: int = 0xa887
const TRAP_GET_FONT_INFO: int = 0xa88b
const TRAP_STRING_WIDTH: int = 0xa88c
const TRAP_DRAW_STRING: int = 0xa884
const A5_GEAR_STROKES: int = -0x1f80  ## word pairs: 'b' starts a stroke, 'c' ends the list

## Gauge frame layouts (offsets from A6): port, half-width, centre x, centre y, factor, font info.
const SMALL_GAUGE: Array = [-0x32, -0x16, -0xa, -0xc, -8, -0x3e]
const WIDE_GAUGE: Array = [-0x34, -0x18, -0xc, -0xe, -0xa, -0x40]
const ALTIMETER_GAUGE: Array = [-0x32, -0x16, -0xa, -0xc, -6, -0x3e]
var _layout: Array = SMALL_GAUGE

## The gauges' common start: the arguments placed in their stack slots (begin_instrument_supersample
## works on them in place), the ring with its status discs (`flags`; none when negative), then the
## supersample begun into the frame at `_layout` (port, half, centre x / y, factor, font info).
## Returns a6.
func _gauge_begin(entry: int, locals: int, size: int, tick: int, pen: int, v: int, h: int, flags: int = 0xf) -> int:
	var a6: int = entry - 4
	memory.write_u16(a6 + 8, size & 0xffff)
	memory.write_u16(a6 + 0xa, tick & 0xffff)
	memory.write_u16(a6 + 0xc, pen & 0xffff)
	memory.write_u16(a6 + 0xe, v & 0xffff)
	memory.write_u16(a6 + 0x10, h & 0xffff)
	if flags >= 0:
		a7 = entry - 4 - locals - 0xa - 4
		draw_ring_with_status_indicators(size, pen, v, h, flags)
	a7 = entry - 4 - locals - 0x24 - 4
	begin_instrument_supersample(a6 + 8, a6 + 0xa, a6 + 0xc, ((v & 0xffff) << 16) | (h & 0xffff), a6 + _layout[0], a6 + _layout[1],
			a6 + _layout[2], a6 + _layout[3], a6 + _layout[4])
	a7 = entry
	return a6

## A gauge's label (the string at A5 + `label`, `points`-point bold) centred on the face's x, `rise`
## design units x factor above its centre (the ascent added, unless `below`: then that far below,
## baseline there).
func _gauge_label(entry: int, a6: int, locals: int, label: int, rise: int, points: int = 0x18, below: bool = false) -> void:
	_trap(TRAP_TEXT_FONT, [1])
	a7 = entry - 4 - locals - 2 - 4
	set_scaled_text_style(points)
	a7 = entry
	_trap(TRAP_GET_FONT_INFO, [a6 + _layout[5]])
	var text: int = memory.read_u32(_g(label))
	var x: int = scale_design_4800(memory.read_u16(a6 + _layout[2])) & 0xffff
	var width: int = _trap(TRAP_STRING_WIDTH, [text]) & 0xffff
	var hh: int = C68kScript.u16(x - C68kScript.divs_trunc(C68kScript.s16(width), 2))
	var vv: int
	if below:
		vv = scale_design_4800(C68kScript.u16(memory.read_s16(a6 + _layout[4]) * rise + memory.read_u16(a6 + _layout[3]))) & 0xffff
	else:
		var y: int = C68kScript.u16(memory.read_u16(a6 + _layout[3]) - memory.read_s16(a6 + _layout[4]) * rise)
		vv = C68kScript.u16(scale_design_4800(y) + memory.read_u16(a6 + _layout[5]))
	_trap(TRAP_MOVE_TO, [vv, hh])
	_trap(TRAP_DRAW_STRING, [text])

func _gauge_finish(entry: int, a6: int, locals: int) -> void:
	a7 = entry - 4 - locals - 0xa - 4
	finish_instrument_supersample(memory.read_u32(a6 + _layout[0]), memory.read_u16(a6 + 8), memory.read_u16(a6 + 0xe), memory.read_u16(a6 + 0x10))
	a7 = entry

## 0x532e: the fuel gauge: two arc scales either side of the face centre (40 design units x factor
## out, clockwise and mirrored, radius 2/3 of the half-width), the label A5 - 0xe12 233 units up,
## and its needle hotspots (A5 - 0x1162 .. -0x1158) for the panel.
func draw_fuel_gauge(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_fuel_gauge needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	var a6: int = _gauge_begin(entry, 0x42, size, tick, pen, v, h)
	var half: int = memory.read_u16(a6 - 0x16)
	var x: int = memory.read_u16(a6 - 0xa)
	var factor: int = memory.read_s16(a6 - 8)
	var radius: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(half * 2)), 3))
	a7 = entry - 4 - 0x42 - 0xc - 4
	draw_arc_scale_ticks(radius, memory.read_u16(a6 + 0xa), memory.read_u16(a6 + 0xc), memory.read_u16(a6 - 0xc),
			C68kScript.u16(x - half + factor * 0x28), 1)
	draw_arc_scale_ticks(radius, memory.read_u16(a6 + 0xa), memory.read_u16(a6 + 0xc), memory.read_u16(a6 - 0xc),
			C68kScript.u16(x + half - factor * 0x28), 0)
	a7 = entry
	_gauge_label(entry, a6, 0x42, -0xe12, 0xe9)
	var row: int = _jt(JT_ROUND_V, [memory.read_u16(a6 + 0xe)]) & 0xffff
	memory.write_u16(_g(-0x115a), row)
	memory.write_u16(_g(-0x1160), row)
	var s: int = memory.read_s16(a6 + 8)
	var hc: int = memory.read_s16(a6 + 0x10)
	memory.write_u16(_g(-0x1162), _jt(JT_ROUND_H, [C68kScript.u16(hc - C68kScript.divs_trunc(s, 2) + 0x28)]) & 0xffff)
	memory.write_u16(_g(-0x115c), _jt(JT_ROUND_H, [C68kScript.u16(C68kScript.divs_trunc(s, 2) + hc - 0x28)]) & 0xffff)
	var reach: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(scale_design_4800(C68kScript.divs_trunc(s, 2)) * 2)), 3)
	var needle: int = C68kScript.u16(reach - scale_design_4800(0x32))
	memory.write_u16(_g(-0x1158), needle)
	memory.write_u16(_g(-0x115e), needle)
	_gauge_finish(entry, a6, 0x42)

## 0x54fe: the landing gear indicator: the gear outline (strokes at A5 - 0x1f80 x factor from the
## face centre, pen of pen / 10 up to 3), the label A5 - 0xe0e 217 units up, and its hotspots
## (A5 - 0x1174 .. -0x1164).
func draw_landing_gear_indicator(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_landing_gear_indicator needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	var a6: int = _gauge_begin(entry, 0x46, size, tick, pen, v, h)
	var p: int = C68kScript.divs_trunc(memory.read_s16(a6 + 0xc), 0xa)
	if p > 3:
		p = 3
	_trap(TRAP_PEN_SIZE, [p & 0xffff, p & 0xffff])
	var factor: int = memory.read_s16(a6 - 8)
	var q: int = _g(A5_GEAR_STROKES)
	while memory.read_u16(q) != 0x63:
		var move: bool = memory.read_u16(q) == 0x62
		if move:
			q = C68kScript.u32(q + 2)
		var hh: int = scale_design_4800_pen_centred(C68kScript.u16(memory.read_s16(q) * factor + memory.read_u16(a6 - 0xa))) & 0xffff
		var vv: int = scale_design_4800_pen_centred(C68kScript.u16(memory.read_s16(q + 2) * factor + memory.read_u16(a6 - 0xc))) & 0xffff
		_trap(TRAP_MOVE_TO if move else TRAP_LINE_TO, [vv, hh])
		q = C68kScript.u32(q + 4)
	_gauge_label(entry, a6, 0x46, -0xe0e, 0xd9)
	var hc: int = memory.read_s16(a6 + 0x10)
	var vc: int = memory.read_s16(a6 + 0xe)
	memory.write_u16(_g(-0x1174), _jt(JT_ROUND_H, [C68kScript.u16(hc - 0x96)]) & 0xffff)
	memory.write_u16(_g(-0x1172), C68kScript.u16(_jt(JT_ROUND_V, [C68kScript.u16(vc + 0x25)]) + 1))
	memory.write_u16(_g(-0x116e), _jt(JT_ROUND_H, [C68kScript.u16(hc + 0x96)]) & 0xffff)
	memory.write_u16(_g(-0x116c), memory.read_u16(_g(-0x1172)))
	memory.write_u16(_g(-0x1168), _jt(JT_ROUND_H, [hc & 0xffff]) & 0xffff)
	memory.write_u16(_g(-0x1166), C68kScript.u16(_jt(JT_ROUND_V, [C68kScript.u16(vc + 0xbb)]) + 1))
	var w: int = scale_design_4800(0x4b) & 0xffff
	memory.write_u16(_g(-0x1164), w)
	memory.write_u16(_g(-0x116a), w)
	memory.write_u16(_g(-0x1170), w)
	_gauge_finish(entry, a6, 0x46)

## A needle-scale tick from the face centre at `angle`: long (`major_length` x the tick length, a
## pen of pen / 10) when `major`, else 2 x with 2 * pen / 30; inwards from the half-width, x to the
## left (`x_sign` -1) or right (1) and y down (`y_sign` 1) or up (-1). Returns the tick's length.
func _face_tick(a6: int, angle: int, major: bool, y_sign: int, x_sign: int = -1, major_length: int = 4) -> int:
	var pen: int = memory.read_s16(a6 + 0xc)
	var tick: int
	if major:
		var p: int = C68kScript.divs_trunc(pen, 0xa) & 0xffff
		_trap(TRAP_PEN_SIZE, [p, p])
		tick = C68kScript.u16(memory.read_u16(a6 + 0xa) * major_length)
	else:
		var p: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(pen * 2)), 0x1e) & 0xffff
		_trap(TRAP_PEN_SIZE, [p, p])
		tick = C68kScript.u16(memory.read_u16(a6 + 0xa) * 2)
	_face_stroke(a6, angle, tick, y_sign, x_sign)
	return tick

## A tick's stroke: from the half-width to `tick` inside it along `angle`.
func _face_stroke(a6: int, angle: int, tick: int, y_sign: int, x_sign: int) -> void:
	var half: int = memory.read_s16(a6 + _layout[1])
	var x: int = memory.read_s16(a6 + _layout[2])
	var y: int = memory.read_s16(a6 + _layout[3])
	var inner: int = C68kScript.s16(C68kScript.u16(half - tick))
	var x1: int = C68kScript.u16(x + x_sign * _fx(half, _dial(A5_SIN, angle)))
	var y1: int = C68kScript.u16(y + y_sign * _fx(half, _dial(A5_COS, angle)))
	var x2: int = C68kScript.u16(x + x_sign * _fx(inner, _dial(A5_SIN, angle)))
	var y2: int = C68kScript.u16(y + y_sign * _fx(inner, _dial(A5_COS, angle)))
	var h1: int = scale_design_4800_pen_centred(x1) & 0xffff
	_trap(TRAP_MOVE_TO, [scale_design_4800_pen_centred(y1) & 0xffff, h1])
	var h2: int = scale_design_4800_pen_centred(x2) & 0xffff
	_trap(TRAP_LINE_TO, [scale_design_4800_pen_centred(y2) & 0xffff, h2])

## The hotspot words a small gauge leaves for the panel: its row (JT $382), column (JT $3ca) and
## needle length (half the face less 50 units).
func _gauge_hotspots(a6: int, row: int, column: int, needle: int) -> void:
	memory.write_u16(_g(row), _jt(JT_ROUND_V, [memory.read_u16(a6 + 0xe)]) & 0xffff)
	memory.write_u16(_g(column), _jt(JT_ROUND_H, [memory.read_u16(a6 + 0x10)]) & 0xffff)
	var half: int = C68kScript.divs_trunc(C68kScript.s16(scale_design_4800(memory.read_u16(a6 + 8))), 2)
	memory.write_u16(_g(needle), C68kScript.u16(half - scale_design_4800(0x32)))

## 0x4c42: the flaps indicator: nine ticks over a quarter turn ((i << 12) / 8 + 0x80, every fourth
## long) on the lower face, the label A5 - 0xe1a (20-point) 100 units up, hotspots A5 - 0x117a ..
## -0x1176.
func draw_flaps_indicator(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_flaps_indicator needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	var a6: int = _gauge_begin(entry, 0x42, size, tick, pen, v, h, 0)
	for i in 9:
		_face_tick(a6, C68kScript.divs_trunc(i << 12, 8) + 0x80, i % 4 == 0, 1)
	_gauge_label(entry, a6, 0x42, -0xe1a, 0x64, 0x14)
	_gauge_hotspots(a6, -0x1178, -0x117a, -0x1176)
	_gauge_finish(entry, a6, 0x42)

## 0x4ecc: the ammunition counter: thirteen ticks over a third of a turn (i * 0x1555 / 12 + 0x555,
## every third long) on the upper face, the label A5 - 0xe16 (20-point) 100 units below, hotspots
## A5 - 0x1156 .. -0x1152.
func draw_ammo_counter(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_ammo_counter needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	var a6: int = _gauge_begin(entry, 0x42, size, tick, pen, v, h, 0)
	for i in 0xd:
		_face_tick(a6, C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(i * 0x1555)), 0xc) + 0x555, i % 3 == 0, -1)
	_gauge_label(entry, a6, 0x42, -0xe16, 0x64, 0x14, true)
	_gauge_hotspots(a6, -0x1154, -0x1156, -0x1152)
	_gauge_finish(entry, a6, 0x42)

## A scale number beyond a major tick: `n` in vector digits of size `digits` (or `size`) at the
## radius (half - digits * 52 / 10 - tick - 45) along the tick's angle.
func _face_number(a6: int, angle: int, tick: int, digits: int, n: int, x_sign: int, size: int = -1) -> void:
	var at: Array = _face_label_point(a6, angle, tick, digits, x_sign)
	draw_vector_number(n, (digits if size < 0 else size) & 0xffff, at[0], at[1])

## Where a scale label of size `digits` goes beyond a tick: [x, y].
func _face_label_point(a6: int, angle: int, tick: int, digits: int, x_sign: int) -> Array:
	var half: int = memory.read_u16(a6 + _layout[1])
	var r: int = C68kScript.s16(C68kScript.u16(half - C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(C68kScript.s16(digits) * 0x34)), 0xa) - tick)) - 0x2d
	var x: int = C68kScript.u16(memory.read_s16(a6 + _layout[2]) + x_sign * _fx(r, _dial(A5_SIN, angle)))
	var y: int = C68kScript.u16(memory.read_s16(a6 + _layout[3]) + _fx(r, _dial(A5_COS, angle)))
	return [x, y]

## 0x1fee: the rate-of-climb indicator: 39 ticks round the face ((i << 14) / 39; every third long,
## numbered 0..6..1 in the tick-length digit size; the minor ticks 18..21 left out), the label
## A5 - 0xe36 (20-point) 100 units up.
func draw_climb_indicator(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_climb_indicator needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	_layout = SMALL_GAUGE
	var a6: int = _gauge_begin(entry, 0x42, size, tick, pen, v, h, -1)
	for i in 0x27:
		var major: bool = i % 3 == 0
		if not major and i >= 0x12 and i <= 0x15:
			continue
		var angle: int = C68kScript.divs_trunc(i << 14, 0x27)
		var length: int = _face_tick(a6, angle, major, 1)
		if major:
			var third: int = i / 3
			_face_number(a6, angle, length, memory.read_u16(a6 + 0xa), 0xd - third if third > 6 else third, -1)
	_gauge_label(entry, a6, 0x42, -0xe36, 0x64, 0x14)
	_gauge_finish(entry, a6, 0x42)

## 0x22fe: the tachometer: 28 ticks over 7/15 of a turn from -40 (((2i - 40) mod 60) << 14 / 60;
## every third long and numbered i * 10 / 6 in digits the tick length's size), the label
## A5 - 0xe32 (20-point) 83 units up; no status ring. Its frame differs (WIDE_GAUGE).
func draw_tachometer(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_tachometer needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	_layout = WIDE_GAUGE
	var a6: int = _gauge_begin(entry, 0x44, size, tick, pen, v, h, -1)
	for i in 0x1c:
		var t: int = C68kScript.s16(C68kScript.u16(i * 2 - 0x28))
		if t < 0:
			t += 0x3c
		var angle: int = C68kScript.divs_trunc(t << 14, 0x3c)
		var major: bool = i % 3 == 0
		var length: int = _face_tick(a6, angle, major, 1, 1)
		if major:
			var digits: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_s16(a6 + 0xa) * 3)), 3)
			_face_number(a6, angle, length, digits, C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(i * 0xa)), 6), 1)
	_gauge_label(entry, a6, 0x44, -0xe32, 0x53, 0x14)
	_gauge_finish(entry, a6, 0x44)
	_layout = SMALL_GAUGE

## The label string at A5 + `label` centred on the face's x with its baseline at `y`.
func _centred_text(a6: int, label: int, y: int) -> void:
	var text: int = memory.read_u32(_g(label))
	var x: int = scale_design_4800(memory.read_u16(a6 + _layout[2])) & 0xffff
	var width: int = _trap(TRAP_STRING_WIDTH, [text]) & 0xffff
	_trap(TRAP_MOVE_TO, [y & 0xffff, C68kScript.u16(x - C68kScript.divs_trunc(C68kScript.s16(width), 2))])
	_trap(TRAP_DRAW_STRING, [text])

## 0x2600: the manifold pressure gauge: 69 ticks from -40 (((i - 40) mod 69) << 14 / 69) from the
## fourth on, every fifth long and every tenth numbered i + 7; two 16-point labels (A5 - 0xe2e with
## its baseline 100 units up, A5 - 0xe2a a line below); no status ring (WIDE_GAUGE).
func draw_manifold_pressure_gauge(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_manifold_pressure_gauge needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	_layout = WIDE_GAUGE
	var a6: int = _gauge_begin(entry, 0x44, size, tick, pen, v, h, -1)
	for i in 0x45:
		var t: int = i - 0x28
		if t < 0:
			t += 0x45
		var angle: int = C68kScript.divs_trunc(t << 14, 0x45)
		var major: bool = (i - 3) % 5 == 0
		if not major and i < 3:
			continue
		var length: int = _face_tick(a6, angle, major, 1, 1)
		if (i - 3) % 0xa == 0:
			_face_number(a6, angle, length, memory.read_u16(a6 + 0xa), i + 7, 1)
	_trap(TRAP_TEXT_FONT, [1])
	a7 = entry - 4 - 0x44 - 2 - 4
	set_scaled_text_style(0x10)
	a7 = entry
	_trap(TRAP_GET_FONT_INFO, [a6 - 0x40])
	var y: int = C68kScript.u16(memory.read_u16(a6 - 0xe) - memory.read_s16(a6 - 0xa) * 0x64)
	_centred_text(a6, -0xe2e, scale_design_4800(y))
	y = C68kScript.u16(memory.read_u16(a6 - 0xe) - memory.read_s16(a6 - 0xa) * 0x64)
	_centred_text(a6, -0xe2a, C68kScript.u16(scale_design_4800(y) + memory.read_u16(a6 - 0x40) + memory.read_u16(a6 - 0x3e)))
	_gauge_finish(entry, a6, 0x44)
	_layout = SMALL_GAUGE

## 0x1876: the altimeter: 20 ticks from -5 (((i - 5) mod 20) << 14 / 20), the even ones long (3 x)
## and numbered 0..9, the label A5 - 0xe42 (20-point) 100 units up; no status ring
## (ALTIMETER_GAUGE: the factor sits at -6).
func draw_altimeter(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_altimeter needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	_layout = ALTIMETER_GAUGE
	var a6: int = _gauge_begin(entry, 0x42, size, tick, pen, v, h, -1)
	var number: int = 0
	for i in 0x14:
		var t: int = i - 5
		if t < 0:
			t += 0x14
		var angle: int = C68kScript.divs_trunc(t << 14, 0x14)
		var major: bool = i & 1 == 0
		var length: int = _face_tick(a6, angle, major, 1, 1, 3)
		if major:
			_face_number(a6, angle, length, memory.read_u16(a6 + 0xa), number, 1)
			number += 1
	_gauge_label(entry, a6, 0x42, -0xe42, 0x64, 0x14)
	_gauge_finish(entry, a6, 0x42)
	_layout = SMALL_GAUGE

## 0x1b48: the airspeed indicator: 160 ticks from -40 (((i - 40) mod 160) << 14 / 160): every tenth
## heavy (pen * 15 / 100, 5 x), every fifth medium (pen / 10, 3 x), the rest from the twentieth
## light (2 * pen / 30, 2 x), each followed by pen / 10; every tenth numbered (0, 40, then i + 40:
## tens below 100, every 20 above in 8/10-size digits); two 18-point labels (A5 - 0xe3e with its
## baseline 100 units up, A5 - 0xe3a a line below); no status ring.
func draw_airspeed_indicator(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_airspeed_indicator needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	_layout = SMALL_GAUGE
	var a6: int = _gauge_begin(entry, 0x42, size, tick, pen, v, h, -1)
	var p: int = memory.read_s16(a6 + 0xc)
	var length: int = memory.read_s16(a6 + 0xa)
	var thin: int = C68kScript.divs_trunc(p, 0xa) & 0xffff
	for i in 0xa0:
		var t: int = i - 0x28
		if t < 0:
			t += 0xa0
		var angle: int = C68kScript.divs_trunc(t << 14, 0xa0)
		var pen_size: int
		var tick_length: int
		if i % 0xa == 0:
			pen_size = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(p * 0xf)), 0x64) & 0xffff
			tick_length = C68kScript.u16(length * 5)
		elif i % 5 == 0:
			pen_size = thin
			tick_length = C68kScript.u16(length * 3)
		elif i < 0x14:
			continue
		else:
			pen_size = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(p * 2)), 0x1e) & 0xffff
			tick_length = C68kScript.u16(length * 2)
		_trap(TRAP_PEN_SIZE, [pen_size, pen_size])
		_face_stroke(a6, angle, tick_length, 1, 1)
		_trap(TRAP_PEN_SIZE, [thin, thin])
		if i % 0xa != 0:
			continue
		var n: int = 0 if i == 0 else (0x28 if i == 0xa else i + 0x28)
		if n < 0x64:
			_face_number(a6, angle, tick_length, length, C68kScript.divs_trunc(n, 0xa), 1)
		elif n % 0x14 == 0:
			var small: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(length << 3)), 0xa)
			_face_number(a6, angle, tick_length, length, n, 1, small)
	_trap(TRAP_PEN_SIZE, [thin, thin])
	_trap(TRAP_TEXT_FONT, [1])
	a7 = entry - 4 - 0x42 - 2 - 4
	set_scaled_text_style(0x12)
	a7 = entry
	_trap(TRAP_GET_FONT_INFO, [a6 - 0x3e])
	var y: int = C68kScript.u16(memory.read_u16(a6 - 0xc) - memory.read_s16(a6 - 8) * 0x64)
	_centred_text(a6, -0xe3e, scale_design_4800(y))
	_centred_text(a6, -0xe3a, C68kScript.u16(scale_design_4800(y) + memory.read_u16(a6 - 0x3e) + memory.read_u16(a6 - 0x3c)))
	_gauge_finish(entry, a6, 0x42)

## 0x2950: the direction indicator: 36 ticks from -9 (((i - 9) mod 36) << 14 / 36), every third
## long (3 x); the compass letters (strings at A5 - 0x1ee6 / -0x1ee4 / -0x1ee2 / -0x1ee0) at every
## ninth in vector glyphs; at the other thirds the label point is computed (2/3-size) but nothing
## drawn; the label A5 - 0xe26 (18-point) 100 units up; no status ring (WIDE_GAUGE).
func draw_direction_indicator(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_direction_indicator needs a7 (its frame and argument slots are used)")
	var entry: int = a7
	_layout = WIDE_GAUGE
	var a6: int = _gauge_begin(entry, 0x44, size, tick, pen, v, h, -1)
	for i in 0x24:
		var t: int = i - 9
		if t < 0:
			t += 0x24
		var angle: int = C68kScript.divs_trunc(t << 14, 0x24)
		var length: int = _face_tick(a6, angle, i % 3 == 0, 1, 1, 3)
		var digits: int = memory.read_u16(a6 + 0xa)
		if i % 9 == 0:
			var letters: int = _g(-0x1ee6 + 2 * (i / 9))
			var at: Array = _face_label_point(a6, angle, length, digits, 1)
			draw_vector_glyph_string_centred(letters, digits, at[0], at[1])
		elif i % 3 == 0:
			_face_label_point(a6, angle, length, C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(digits * 2)), 3), 1)
	_gauge_label(entry, a6, 0x44, -0xe26, 0x64, 0x12)
	_gauge_finish(entry, a6, 0x44)
	_layout = SMALL_GAUGE

## 0x4790: a percent scale of design size w x h centred at (h0 - 20 after the box, v0): the box
## painted in colour 0 and framed (colour 3 in 1-bit mode, else 2); a 60-unit bar inside it
## (framed, then inset by 1 and kept at A5 - 0x1186) with ten marks (the ends long); "100" and "0"
## drawn at 3x in an offscreen port downsampled into the box (antialias_downsample_bw_3x, out = 0).
func draw_percent_scale_gauge(w: int, h: int, digits: int, pen: int, v: int, h0: int) -> void:
	assert(a7 != 0, "draw_percent_scale_gauge needs a7 (its frame is read beyond its arguments)")
	var entry: int = a7
	var a6: int = entry - 4
	var wide: int = C68kScript.u16(C68kScript.u16(C68kScript.s16(digits) * 3) * 6)
	var bar_span: int = C68kScript.u16(wide + 0xaa)
	var p: int = C68kScript.divs_trunc(C68kScript.s16(pen), 0xa) & 0xffff
	_trap(TRAP_PEN_SIZE, [p, p])
	var left: int = _jt(JT_ROUND_H, [C68kScript.u16(h0 - C68kScript.divs_trunc(C68kScript.s16(w), 2))]) & 0xffff
	var top: int = _jt(JT_ROUND_V, [C68kScript.u16(v - C68kScript.divs_trunc(C68kScript.s16(h), 2))]) & 0xffff
	var right: int = C68kScript.u16(scale_design_4800(w) + left)
	var bottom: int = C68kScript.u16(scale_design_4800(h) + top)
	memory.write_u16(a6 - 0xa, top)
	memory.write_u16(a6 - 8, left)
	memory.write_u16(a6 - 6, bottom)
	memory.write_u16(a6 - 4, right)
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_PAINT_RECT, [_box(a6 - 0xa)])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(3 if memory.read_u16(_g(A5_COLOUR_MODE)) == 1 else 2)])
	_trap(TRAP_FRAME_RECT, [_box(a6 - 0xa)])
	var hc: int = C68kScript.s16(C68kScript.u16(h0 - 0x14))
	var half_bar: int = C68kScript.divs_trunc(C68kScript.s16(bar_span), 2)
	var bar_left: int = _jt(JT_ROUND_H, [C68kScript.u16(half_bar + hc - 0x3c)]) & 0xffff
	memory.write_u16(a6 - 0x10, bar_left)
	memory.write_u16(a6 - 0xc, C68kScript.u16(scale_design_4800(0x3c) + bar_left))
	var half_h: int = C68kScript.divs_trunc(C68kScript.s16(h), 2)
	memory.write_u16(a6 - 0x12, _jt(JT_ROUND_V, [C68kScript.u16(v - half_h + 0x1e)]) & 0xffff)
	memory.write_u16(a6 - 0xe, _jt(JT_ROUND_V, [C68kScript.u16(half_h + v - 0x1e)]) & 0xffff)
	_trap(TRAP_FRAME_RECT, [_box(a6 - 0x12)])
	var mark_left: int = C68kScript.u16(half_bar + hc - 0x8c)
	var mark_right: int = C68kScript.u16(mark_left + 0x32)
	var base: int = C68kScript.u16(half_h + v - 0x1e)
	var span: int = C68kScript.u16(memory.read_u16(a6 - 0xe) - memory.read_u16(a6 - 0x12) - 1)
	_trap(TRAP_PEN_SIZE, [p, p])
	var row: int = 0
	for i in 0xa:
		var start: int = mark_left if i == 0 or i == 9 else C68kScript.u16(mark_left + 0x1e)
		row = C68kScript.u16(_jt(JT_ROUND_V, [base]) - C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(C68kScript.s16(span) * i)), 9))
		_trap(TRAP_MOVE_TO, [C68kScript.u16(row - 1), _jt(JT_ROUND_H, [start]) & 0xffff])
		_trap(TRAP_LINE_TO, [C68kScript.u16(row - 1), _jt(JT_ROUND_H, [mark_right]) & 0xffff])
	var w3: int = C68kScript.u16(scale_design_4800(w) * 3)
	var h3: int = C68kScript.u16(scale_design_4800(h) * 3 + 4)
	a7 = entry - 4 - 0x2a - 4 - 4
	var port: int = new_offscreen_bw_port(C68kScript.u16(w3 + 4), h3)
	a7 = entry
	_trap(TRAP_SET_PORT, [port])
	_trap(TRAP_SET_ORIGIN, [0xfffe, 0xfffe])
	var size: int = C68kScript.u16(C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(3 * memory.read_u32(_g(A5_DESIGN_SCALE)))), 0x1e0)) * C68kScript.s16(digits))
	var pen3: int = C68kScript.u16(C68kScript.s16(pen) * 3)
	var q: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(pen3 * 2)), 0x1e) & 0xffff
	_trap(TRAP_PEN_SIZE, [q, q])
	var x: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(C68kScript.s16(w) * 3)), 2)
			- C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(C68kScript.s16(bar_span) * 3)), 2) + 0x10e)
	draw_vector_number(0x64, size, x, 0xd2)
	draw_vector_number(0, size, x, C68kScript.u16(C68kScript.s16(h) * 3 - 0xd2))
	_trap(TRAP_SET_PORT, [memory.read_u32(_g(A5_PANEL_PORT))])
	a7 = entry - 4 - 0x2a - 0x10 - 4
	antialias_downsample_bw_3x(port, left, top, C68kScript.u16(bottom - top), C68kScript.u16(right - left), 0)
	a7 = entry
	dispose_offscreen_bw_port(port)
	_trap(TRAP_INSET_RECT, [1, 1, _box(a6 - 0x12)])
	memory.write_u32(_g(-0x1186), memory.read_u32(a6 - 0x12))
	memory.write_u32(_g(-0x1182), memory.read_u32(a6 - 0xe))

const TRAP_SET_RECT: int = 0xa8a7

func _h(design: int) -> int:
	return _jt(JT_ROUND_H, [design & 0xffff]) & 0xffff

func _v(design: int) -> int:
	return _jt(JT_ROUND_V, [design & 0xffff]) & 0xffff

## 0x4304: the panel's centre section: the area (-400, 750)-(400, 1560) painted black, then inset by
## 2 in black (1- / 4-bit) or green and kept at A5 - 0x11aa (A5 - 0x11a0 / -0x119e: (-10, 1150);
## A5 - 0x11c8 the depth); a grid in grey or green (columns at -270, -140, -10 and their right
## twins, rows at 880, 1010, 1140 and their lower twins); a bevelled frame 30 units out; three
## numbered boxes (1, 3, 15) at (490..610) x (720..840 / 900..1020 / 1080..1200), kept at
## A5 - 0x11c6 / -0x11be / -0x11b6.
func draw_panel_section_with_numbered_boxes() -> void:
	assert(a7 != 0, "draw_panel_section_with_numbered_boxes needs a7 (its frame holds the rect)")
	var entry: int = a7
	var a6: int = entry - 4
	var rect: int = a6 - 0xa
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	memory.write_u16(a6 - 8, _h(-0x190))
	memory.write_u16(rect, _v(0x2ee))
	memory.write_u16(a6 - 4, _h(0x190))
	memory.write_u16(a6 - 6, _v(0x618))
	_trap(TRAP_PAINT_RECT, [_box(rect)])
	var mode: int = memory.read_u16(_g(A5_COLOUR_MODE))
	if mode == 1 or mode == 4:
		_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	else:
		_jt(JT_FORE_PANEL_COLOUR, [_jt(JT_PANEL_COLOUR, [0, 1, 0]) & 0xffff])
	_trap(TRAP_INSET_RECT, [2, 2, _box(rect)])
	_trap(TRAP_PAINT_RECT, [_box(rect)])
	memory.write_u32(_g(-0x11aa), memory.read_u32(rect))
	memory.write_u32(_g(-0x11a6), memory.read_u32(rect + 4))
	memory.write_u16(_g(-0x11a0), _h(-0xa))
	memory.write_u16(_g(-0x119e), _v(0x47e))
	memory.write_u16(_g(-0x11c8), memory.read_u16(_g(A5_COLOUR_MODE)))
	if memory.read_u16(_g(A5_COLOUR_MODE)) == 1:
		_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(2)])
	else:
		_jt(JT_FORE_PANEL_COLOUR, [_jt(JT_PANEL_COLOUR, [0, 2, 0]) & 0xffff])
	_trap(TRAP_PEN_SIZE, [1, 1])
	for lines in [[-0x1b, -1, 0], [-1, 0x19, 1]]:
		var i: int = lines[0]
		while i <= lines[1]:
			var x: int = _h(i * 0xa)
			_trap(TRAP_MOVE_TO, [C68kScript.u16(_v(0x2ee) + 2), C68kScript.u16(x + lines[2])])
			x = _h(i * 0xa)
			_trap(TRAP_LINE_TO, [C68kScript.u16(_v(0x618) - 3), C68kScript.u16(x + lines[2])])
			i += 0xd
	for lines in [[-0x1a, 0, 0], [0, 0x1a, 1]]:
		var i: int = lines[0]
		while i <= lines[1]:
			var x: int = _h(-0x190)
			_trap(TRAP_MOVE_TO, [C68kScript.u16(_v(i * 0xa + 0x47e) + lines[2]), C68kScript.u16(x + 2)])
			x = _h(0x190)
			_trap(TRAP_LINE_TO, [C68kScript.u16(_v(i * 0xa + 0x47e) + lines[2]), C68kScript.u16(x - 3)])
			i += 0xd
	var frame: Array = [_h(-0x1ae), _v(0x2d0), _h(-0x190), _v(0x2ee), _h(0x190), _v(0x618), _h(0x1ae), _v(0x636)]
	draw_bevelled_frame(frame[0], frame[1], frame[2], frame[3], frame[4], frame[5], frame[6], frame[7])
	for box in [[0x2d0, 0x348, 1, -0x11c6], [0x384, 0x3fc, 3, -0x11be], [0x438, 0x4b0, 0xf, -0x11b6]]:
		var left: int = _h(0x1ea)
		var top: int = _v(box[0])
		var right: int = _h(0x262)
		var bottom: int = _v(box[1])
		_trap(TRAP_SET_RECT, [bottom, right, top, left, rect])
		a7 = entry - 4 - 0x18 - 6 - 4
		draw_numbered_bevel_box(rect, box[2])
		a7 = entry
		memory.write_u32(_g(box[3]), memory.read_u32(rect))
		memory.write_u32(_g(box[3] + 4), memory.read_u32(rect + 4))


## 0x3c02: one instrument of `kind` (ID01's dense switch on 0..9: altimeter, airspeed, turn and bank,
## climb, manifold pressure, tachometer, direction, -, gyro, horizon) after its ring (status discs
## 0x1b for the direction indicator, else 0xf) in colour 4; its record (A5 - 0x12a2 + 16 * kind:
## the face rect's top / left / height / width, the depth, the centre and the needle length) filled.
func draw_instrument(kind: int, size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_instrument needs a7 (the gauges use their frames)")
	var entry: int = a7
	var k: int = C68kScript.s16(kind)
	a7 = entry - 4 - 0xa - 0xa - 4
	draw_ring_with_status_indicators(size, pen, v, h, 0x1b if k == 6 else 0xf)
	a7 = entry
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(4)])
	a7 = entry - 4 - 0xa - 0xa - 4
	match k:
		0:
			draw_altimeter(size, tick, pen, v, h)
		1:
			draw_airspeed_indicator(size, tick, pen, v, h)
		2:
			draw_turn_and_bank_indicator(size, tick, pen, v, h)
		3:
			draw_climb_indicator(size, tick, pen, v, h)
		4:
			draw_manifold_pressure_gauge(size, tick, pen, v, h)
		5:
			draw_tachometer(size, tick, pen, v, h)
		6:
			draw_direction_indicator(size, tick, pen, v, h)
		8:
			draw_gyro_instrument(size, tick, pen, v, h, 1)
		9:
			draw_artificial_horizon(size, tick, pen, v, h, 1)
	a7 = entry
	var rec: int = C68kScript.u32(_g(-0x12a2) + C68kScript.lsl32(C68kScript.u32(k), 4))
	var half: int = C68kScript.divs_trunc(C68kScript.s16(scale_design_4800(size)), 2)
	memory.write_u16(rec + 0xe, C68kScript.u16(half - scale_design_4800(0x32)))
	memory.write_u16(rec + 0xc, _v(v))
	memory.write_u16(rec + 0xa, _h(h))
	memory.write_u16(rec + 8, memory.read_u16(_g(A5_COLOUR_MODE)))
	var s2: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	memory.write_u16(rec + 2, _h(C68kScript.s16(h) - s2))
	memory.write_u16(rec, _v(C68kScript.s16(v) - s2))
	memory.write_u16(rec + 4, C68kScript.u16(_h(s2 + C68kScript.s16(h)) - memory.read_u16(rec + 2)))
	memory.write_u16(rec + 6, C68kScript.u16(_v(s2 + C68kScript.s16(v)) - memory.read_u16(rec)))

const TRAP_DIFF_RGN: int = 0xa8e6
const TRAP_PT_IN_RGN: int = 0xa8e8
const JT_SET_HANDLE_SIZE: int = 0x26a   ## SetHandleSize(handle, size) (Pascal)

## 0x38fc: the artificial horizon: within the face oval less its inset oval (the inset region from
## make_inset_face_oval_region, which also shrinks the frame's rect), seven marks in colour 4 over
## the top half ((i << 13) / 6 from the centre out to half the size + 10 x the pen, pen (pen + 5) / 10
## at least 1); the face rect kept at A5 - 0x1202 .. -0x11fc; with `spans` set, each row's span inside
## the inset oval (PtInRgn outwards from the middle) stored as left / right words in the handle
## A5 - 0x11f6 (sized 4 per row).
func draw_artificial_horizon(size: int, _tick: int, pen: int, v: int, h: int, spans: int) -> void:
	assert(a7 != 0, "draw_artificial_horizon needs a7 (its frame holds the rect)")
	var entry: int = a7
	var a6: int = entry - 4
	var rect: int = a6 - 0x1c
	_trap(TRAP_PEN_SIZE, [1, 1])
	var s2: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	memory.write_u16(a6 - 0x1a, C68kScript.u16(_h(C68kScript.s16(h) - s2) + 1))
	memory.write_u16(rect, C68kScript.u16(_v(C68kScript.s16(v) - s2) + 1))
	memory.write_u16(a6 - 0x16, C68kScript.u16(scale_design_4800(size) + memory.read_u16(a6 - 0x1a) - 2))
	memory.write_u16(a6 - 0x18, C68kScript.u16(scale_design_4800(size) + memory.read_u16(rect) - 2))
	var face: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_OPEN_RGN, [])
	_trap(TRAP_FRAME_OVAL, [_box(rect)])
	_trap(TRAP_CLOSE_RGN, [face])
	var inset: int = make_inset_face_oval_region(rect, size, v, h)
	_trap(TRAP_DIFF_RGN, [face, inset, face])
	var saved: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_GET_CLIP, [saved])
	_trap(TRAP_SET_CLIP, [face])
	var p: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(pen + 5)), 0xa)
	if p == 0:
		p = 1
	_trap(TRAP_PEN_SIZE, [p & 0xffff, p & 0xffff])
	var r: int = C68kScript.s16(C68kScript.u16(s2 + p * 0xa))
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(4)])
	var off: int = C68kScript.divs_trunc(p, 2) + 1
	for i in 7:
		var angle: int = C68kScript.divs_trunc(i << 13, 6)
		var x: int = C68kScript.u16(_fx(r, _dial(A5_SIN, angle)) + C68kScript.s16(h))
		var y: int = C68kScript.u16(C68kScript.s16(v) - _fx(r, _dial(A5_COS, angle)))
		var hh: int = C68kScript.u16(_h(x) - off)
		_trap(TRAP_MOVE_TO, [C68kScript.u16(_v(y) - off), hh])
		hh = C68kScript.u16(_h(h) - off)
		_trap(TRAP_LINE_TO, [C68kScript.u16(_v(v) - off), hh])
	_trap(TRAP_SET_CLIP, [saved])
	var left: int = memory.read_u16(a6 - 0x1a)
	var top: int = memory.read_u16(rect)
	memory.write_u16(_g(-0x1200), left)
	memory.write_u16(_g(-0x1202), top)
	memory.write_u16(_g(-0x11fe), C68kScript.u16(memory.read_u16(a6 - 0x16) - left))
	memory.write_u16(_g(-0x11fc), C68kScript.u16(memory.read_u16(a6 - 0x18) - top))
	if spans & 0xffff != 0:
		_jt(JT_SET_HANDLE_SIZE, [C68kScript.u32(memory.read_s16(_g(-0x11fc)) * 4), memory.read_u32(_g(-0x11f6))])
		var row: int = memory.read_s16(rect)
		while row < memory.read_s16(a6 - 0x18):
			var mid: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_u16(a6 - 0x1a) + memory.read_u16(a6 - 0x16))), 2)
			var lo: int = mid
			var hi: int = mid
			while true:
				lo -= 1
				if not _inside(inset, row, lo):
					break
			lo += 1
			while true:
				hi += 1
				if not _inside(inset, row, hi):
					break
			if C68kScript.u16(lo) == C68kScript.u16(hi):
				hi += 1
			var at: int = C68kScript.u32(memory.read_u32(memory.read_u32(_g(-0x11f6)))
					+ C68kScript.lsl32(C68kScript.u32(C68kScript.s16(C68kScript.u16(row - memory.read_u16(rect)))), 2))
			memory.write_u16(at, C68kScript.u16(lo))
			memory.write_u16(at + 2, C68kScript.u16(hi))
			row = C68kScript.s16(C68kScript.u16(row + 1))
	_trap(TRAP_DISPOSE_RGN, [inset])
	_trap(TRAP_DISPOSE_RGN, [face])
	_trap(TRAP_DISPOSE_RGN, [saved])

func _inside(rgn: int, row: int, x: int) -> bool:
	return (_trap(TRAP_PT_IN_RGN, [rgn, ((row & 0xffff) << 16) | (x & 0xffff)]) >> 8) & 0xff != 0

const JT_HLOCK: int = 0x272
const JT_HUNLOCK: int = 0x27a
const JT_NEW_CPORT_ON: int = 0x402      ## (C: rowBytes word, base, rect by value): a colour port
const JT_DISPOSE_CPORT: int = 0x392     ## (C, port)

## 0x32b8: the gyro (heading) instrument: its frame (the face inset by 70 x 180 units, framed in
## colour 2, short top and bottom marks at the centre) and its window globals (A5 - 0x11ee .. -0x11e2:
## top-left, width, height, 3/4 height, x 9 width); with `card` set, the heading card (36 marks every
## 10 degrees over 9 window widths, every third long and numbered 0, 33..3) drawn at 1x or 3x in an
## offscreen port with the design scale at 480, then put through a colour port on the handle
## A5 - 0x11dc (rowBytes | 0x8000 at A5 - 0x11de; A5 - 0x11d4 sized to the width) by CopyBits in
## 1-bit mode or antialias_downsample_bw_3x (marking the drawn columns in A5 - 0x11d4).
func draw_gyro_instrument(size: int, tick: int, pen: int, v: int, h: int, card: int) -> void:
	assert(a7 != 0, "draw_gyro_instrument needs a7 (its frame holds the rects)")
	var entry: int = a7
	var a6: int = entry - 4
	var rect: int = a6 - 0x26
	_trap(TRAP_PEN_SIZE, [1, 1])
	var s2: int = C68kScript.divs_trunc(C68kScript.s16(size), 2)
	memory.write_u16(a6 - 0x24, _h(C68kScript.s16(h) - s2))
	memory.write_u16(rect, _v(C68kScript.s16(v) - s2))
	memory.write_u16(a6 - 0x20, C68kScript.u16(scale_design_4800(size) + memory.read_u16(a6 - 0x24)))
	memory.write_u16(a6 - 0x22, C68kScript.u16(scale_design_4800(size) + memory.read_u16(rect)))
	var dh: int = scale_design_4800(0x46) & 0xffff
	var dv: int = scale_design_4800(0xb4) & 0xffff
	_trap(TRAP_INSET_RECT, [dv, dh, _box(rect)])
	_trap(TRAP_MOVE_TO, [memory.read_u16(rect), _h(h)])
	var x: int = _h(h)
	_trap(TRAP_LINE_TO, [C68kScript.u16(scale_design_4800(0x28) + memory.read_u16(rect)), x])
	x = _h(h)
	_trap(TRAP_MOVE_TO, [C68kScript.u16(memory.read_u16(a6 - 0x22) - 1), x])
	x = _h(h)
	_trap(TRAP_LINE_TO, [C68kScript.u16(memory.read_u16(a6 - 0x22) - scale_design_4800(0x28) - 1), x])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(2)])
	var p: int = C68kScript.divs_trunc(C68kScript.s16(pen), 0xa) & 0xffff
	_trap(TRAP_PEN_SIZE, [p, p])
	_trap(TRAP_FRAME_RECT, [_box(rect)])
	memory.write_u16(_g(-0x11ec), C68kScript.u16(memory.read_u16(a6 - 0x24) + 1))
	memory.write_u16(_g(-0x11ea), C68kScript.u16(memory.read_u16(a6 - 0x20) - memory.read_u16(_g(-0x11ec)) - 1))
	memory.write_u16(_g(-0x11ee), C68kScript.u16(scale_design_4800(0x32) + memory.read_u16(rect)))
	memory.write_u16(_g(-0x11e8), C68kScript.u16(memory.read_u16(a6 - 0x22) - scale_design_4800(0x32) - memory.read_u16(_g(-0x11ee))))
	memory.write_u16(_g(-0x11e6), C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_s16(_g(-0x11e8)) * 3)), 4)))
	memory.write_u16(_g(-0x11e2), memory.read_u16(_g(-0x11e8)))
	memory.write_u16(_g(-0x11e4), C68kScript.u16(memory.read_s16(_g(-0x11ea)) * 9))
	if card & 0xffff == 0:
		return
	_gyro_card(entry, a6, rect, tick, pen)

func _gyro_card(entry: int, a6: int, rect: int, tick: int, pen: int) -> void:
	var k: int = 1 if memory.read_u16(_g(A5_COLOUR_MODE)) == 1 else 3
	var width: int = memory.read_s16(_g(-0x11e4))
	var height: int = memory.read_s16(_g(-0x11e2))
	var saved_port: int = memory.read_u32(_g(-0x160c))
	a7 = entry - 4 - 0x54 - 4 - 4
	var port: int = new_offscreen_bw_port(C68kScript.u16(width * k + 4), C68kScript.u16(height * k + 4))
	a7 = entry
	_trap(TRAP_SET_PORT, [port])
	if k == 3:
		_trap(TRAP_SET_ORIGIN, [0xfffe, 0xfffe])
	var digits: int = tick & 0xffff
	var t: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(C68kScript.s16(C68kScript.u16(C68kScript.s16(tick) * k)))
			* memory.read_u32(_g(A5_DESIGN_SCALE)))), 0x1e0) & 0xffff
	if t != 0:
		digits = t
	var pen_k: int = C68kScript.u16(C68kScript.s16(pen) * k)
	var saved_scale: int = memory.read_s16(_g(-0x149c))
	memory.write_u32(_g(A5_DESIGN_SCALE), 0x1e0)
	var wk: int = C68kScript.s16(C68kScript.u16(width * k))
	var hk: int = C68kScript.s16(C68kScript.u16(height * k))
	var origin: int = C68kScript.s16(C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(wk) * 0xa)), 0x48)))
	memory.write_u16(_g(-0x11e0), C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(scale_design_4800(origin)), k)))
	var number_row: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(hk) * 0x1e)), 8))
	var mark_top: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(hk) * 0x1e)), 4))
	var last_h: int = 0
	for i in 0x24:
		var q: int
		if i % 3 == 0 or k == 1:
			q = C68kScript.divs_trunc(C68kScript.s16(pen_k), 0xa) & 0xffff
		else:
			q = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(pen_k * 2)), C68kScript.s16(C68kScript.u16(k * 0xa))) & 0xffff
		_trap(TRAP_PEN_SIZE, [q, q])
		var mx: int = _gyro_mark_x(i, k, origin)
		var hh: int = scale_design_4800_pen_centred(mx) & 0xffff
		_trap(TRAP_MOVE_TO, [scale_design_4800_pen_centred(mark_top) & 0xffff, hh])
		last_h = scale_design_4800_pen_centred(mx) & 0xffff
		_trap(TRAP_LINE_TO, [scale_design_4800_pen_centred(0x7fff) & 0xffff, last_h])
		if i % 3 == 0:
			draw_vector_number(0 if i == 0 else 0x24 - i, digits, _gyro_mark_x(i, k, origin), number_row)
	memory.write_u32(_g(A5_DESIGN_SCALE), C68kScript.u32(saved_scale))
	var row_bytes: int = C68kScript.u16(C68kScript.asr32(C68kScript.u32(C68kScript.u32(C68kScript.u32(width) * C68kScript.u32(memory.read_s16(_g(A5_COLOUR_MODE)))) + 0xf), 4) * 2)
	memory.write_u16(_g(-0x11de), 0x8000 | row_bytes)
	_jt(JT_SET_HANDLE_SIZE, [C68kScript.u32(C68kScript.u32(height) * C68kScript.u32(C68kScript.s16(row_bytes))), memory.read_u32(_g(-0x11dc))])
	_jt(JT_SET_HANDLE_SIZE, [C68kScript.u32(width), memory.read_u32(_g(-0x11d4))])
	_jt(JT_HLOCK, [memory.read_u32(_g(-0x11dc))])
	_jt(JT_HLOCK, [memory.read_u32(_g(-0x11d4))])
	memory.write_u16(rect, 0)
	memory.write_u16(a6 - 0x24, 0)
	memory.write_u16(a6 - 0x20, width & 0xffff)
	memory.write_u16(a6 - 0x22, height & 0xffff)
	var cport: int = C68kScript.u32(_jt(JT_NEW_CPORT_ON, [0x8000 | row_bytes, memory.read_u32(memory.read_u32(_g(-0x11dc))),
			memory.read_u32(rect), memory.read_u32(rect + 4)]))
	_trap(TRAP_SET_PORT, [cport])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_PAINT_RECT, [_box(rect)])
	if memory.read_u16(_g(A5_COLOUR_MODE)) == 1:
		_trap(TRAP_COPY_BITS, [0, 3, _box(port + 0x10), _box(port + 0x10), C68kScript.u32(cport + 2), C68kScript.u32(port + 2)])
	else:
		a7 = entry - 4 - 0x54 - 0x10 - 4
		antialias_downsample_bw_3x(port, 0, 0, height & 0xffff, width & 0xffff, memory.read_u32(memory.read_u32(_g(-0x11d4))))
		a7 = entry
	_jt(JT_HUNLOCK, [memory.read_u32(_g(-0x11dc))])
	_jt(JT_HUNLOCK, [memory.read_u32(_g(-0x11d4))])
	_trap(TRAP_SET_PORT, [saved_port])
	dispose_offscreen_bw_port(port)
	_jt(JT_DISPOSE_CPORT, [cport])

## A heading mark's x on the card: i * width * factor * 100 / 360 + the card's origin.
func _gyro_mark_x(i: int, k: int, origin: int) -> int:
	var w: int = C68kScript.u32(memory.read_s16(_g(-0x11e4)))
	var d0: int = C68kScript.u32(C68kScript.u32(i) * w)
	var d1: int = C68kScript.u32(C68kScript.u32(C68kScript.u32(k) * d0) * 0x64)
	return C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(d1), 0x168) + origin)

const A5_ROTATE_POINTS: int = -0x105e  ## long: (C: 0, 0, angle, count, src, dst) rotates long (x, y, -) triples

## A turn-and-bank shape: `count` points (signed byte pairs at A5 + `table` x the tick size, the y
## from the label radius) built as 12-byte records in the frame, rotated by *(A5 - 0x105e) through
## `angle`, then outlined `shift` design units across and 110 down from the face centre.
func _turn_shape(a6: int, table: int, count: int, angle: int, shift: int) -> void:
	var pts: int = a6 - 0xb8
	var size: int = memory.read_s16(a6 + 0xa)
	var y0: int = C68kScript.s16(C68kScript.u16(memory.read_u16(a6 + _layout[1]) - C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(size * 0x34)), 0xa) - 0x2d))
	for i in count:
		memory.write_u32(pts + 0xc * i, C68kScript.u32(C68kScript.s16(C68kScript.u16(C68kScript.s8(memory.read_u8(_g(table + 2 * i))) * size))))
		memory.write_u32(pts + 0xc * i + 4, C68kScript.u32(C68kScript.s16(C68kScript.u16(C68kScript.s8(memory.read_u8(_g(table + 2 * i + 1))) * size + y0))))
	_call_address(memory.read_u32(_g(A5_ROTATE_POINTS)), [0, 0, angle, count, pts, pts])
	for i in count:
		var hh: int = scale_design_4800_pen_centred(C68kScript.u16(memory.read_s16(a6 + _layout[2]) + memory.read_s32(pts + 0xc * i) + shift)) & 0xffff
		var vv: int = scale_design_4800_pen_centred(C68kScript.u16(memory.read_s16(a6 + _layout[3]) - memory.read_s32(pts + 0xc * i + 4) + 0x6e)) & 0xffff
		_trap(TRAP_MOVE_TO if i == 0 else TRAP_LINE_TO, [vv, hh])

## 0x2d1c: the turn and bank indicator: the aircraft symbol's wings (3 points from A5 - 0x1fa0,
## rotated by 0x555, 150 units left) and tail (10 from A5 - 0x1f9a, rotated by 0x3aaa, 150 right),
## the ball window painted, two needles at 0x2d55 and 0x32aa (3 x the tick length), labels
## A5 - 0xe22 (133 units up) and A5 - 0xe1e (17 down), 18-point; no status ring (WIDE_GAUGE).
func draw_turn_and_bank_indicator(size: int, tick: int, pen: int, v: int, h: int) -> void:
	assert(a7 != 0, "draw_turn_and_bank_indicator needs a7 (its frame holds the points)")
	var entry: int = a7
	_layout = WIDE_GAUGE
	var a6: int = _gauge_begin(entry, 0xbc, size, tick, pen, v, h, -1)
	var p: int = C68kScript.divs_trunc(memory.read_s16(a6 + 0xc), 0xa) & 0xffff
	_trap(TRAP_PEN_SIZE, [p, p])
	_turn_shape(a6, -0x1fa0, 3, 0x555, -0x96)
	_turn_shape(a6, -0x1f9a, 0xa, 0x3aaa, 0x96)
	var x: int = memory.read_u16(a6 - 0xc)
	var y: int = memory.read_u16(a6 - 0xe)
	var half: int = memory.read_u16(a6 - 0x18)
	memory.write_u16(a6 - 0x28, scale_design_4800(C68kScript.u16(y - half)) & 0xffff)
	memory.write_u16(a6 - 0x26, scale_design_4800(C68kScript.u16(x - 0x3c)) & 0xffff)
	memory.write_u16(a6 - 0x24, scale_design_4800(C68kScript.u16(y - half + 0x3c)) & 0xffff)
	memory.write_u16(a6 - 0x22, scale_design_4800(C68kScript.u16(x + 0x5a)) & 0xffff)
	_trap(TRAP_PAINT_RECT, [_box(a6 - 0x28)])
	var needle: int = C68kScript.u16(memory.read_s16(a6 + 0xa) * 3)
	_face_stroke(a6, 0x2d55, needle, 1, 1)
	_face_stroke(a6, 0x32aa, needle, 1, 1)
	_trap(TRAP_TEXT_FONT, [1])
	a7 = entry - 4 - 0xbc - 2 - 4
	set_scaled_text_style(0x12)
	a7 = entry
	_trap(TRAP_GET_FONT_INFO, [a6 - 0x40])
	var factor: int = memory.read_s16(a6 - 0xa)
	_centred_text(a6, -0xe22, C68kScript.u16(scale_design_4800(C68kScript.u16(memory.read_u16(a6 - 0xe) - factor * 0x85)) + memory.read_u16(a6 - 0x40)))
	_centred_text(a6, -0xe1e, C68kScript.u16(scale_design_4800(C68kScript.u16(factor * 0x11 + memory.read_u16(a6 - 0xe))) + memory.read_u16(a6 - 0x40)))
	_gauge_finish(entry, a6, 0xbc)
	_layout = SMALL_GAUGE

const JT_FLUSH_PANEL_1BIT: int = 0x482  ## (C): the 1-bit panel's refresh

func _remapped(table: int, index: int) -> int:
	return memory.read_u16(C68kScript.u32(table + 2 * C68kScript.s16(index)))

func _colour_via(table: int, r: int, g: int, b: int) -> int:
	return _remapped(table, _jt(JT_PANEL_COLOUR, [r, g, b]) & 0xffff)

## Every pixel of a bitmap (`rows` x `bytes` from `base`, `row_bytes` apart) put through the inverse
## map in the frame and `table`: nibble by nibble at depth 4, byte by byte at depth 8.
func _remap_bitmap(inv: int, table: int, base: int, rows: int, bytes: int, row_bytes: int, nibbles: bool) -> void:
	var row: int = base
	var r: int = rows & 0xffff
	while r != 0:
		r = (r - 1) & 0xffff
		var p: int = row
		var n: int = bytes & 0xffff
		while n != 0:
			n = (n - 1) & 0xffff
			var b: int = memory.read_u8(p)
			if nibbles:
				var hi: int = _remapped(table, memory.read_u16(inv + 2 * (b >> 4)))
				var lo: int = _remapped(table, memory.read_u16(inv + 2 * (b & 0xf)))
				memory.write_u8(p, ((hi << 4) | lo) & 0xff)
			else:
				memory.write_u8(p, _remapped(table, memory.read_u16(inv + 2 * b)) & 0xff)
			p = C68kScript.u32(p + 1)
		row = C68kScript.u32(row + C68kScript.s16(row_bytes))

## 0x6c1c: the cached panel (scenery record *(A5 - 0x13b2) + 0x160 * A5 - 0x13ae) recoloured for the
## current palette when it was drawn at this depth and screen geometry (+0..+8 against A5 - 0x137a,
## -0x137e, -0x137c, -0x1372, -0x1370): 1-bit panels are just refreshed (JT $482); otherwise the panel
## slots' colours (`map` 0..12 at depth 4, 200..216 at depth 8; ID01's sparse switch) give an inverse
## map, every pixel of the panel bitmap (*(A5 - 0x12b0), rowBytes from +0xa) and the gyro card
## (*(A5 - 0x11dc)) is put through it and `table`, and the cached fill patterns and colours
## (A5 - 0x11fa / -0x11f8, -0x11ae .. -0x112c, -0x12a4) are refreshed.
func remap_cached_panel_colours(map: int, table: int) -> void:
	assert(a7 != 0, "remap_cached_panel_colours needs a7 (its frame holds the inverse map)")
	var inv: int = a7 - 4 - 0x200
	var scenery: int = memory.read_s16(_g(-0x13ae))
	if scenery < 0 or memory.read_u32(_g(-0x13b2)) == 0:
		return
	var rec: int = C68kScript.u32(C68kScript.s16(scenery) * 0x160 + memory.read_u32(memory.read_u32(_g(-0x13b2))))
	for check in [[0, A5_COLOUR_MODE], [2, -0x137e], [4, -0x137c], [6, -0x1372], [8, -0x1370]]:
		if memory.read_u16(rec + check[0]) != memory.read_u16(_g(check[1])):
			return
	var mode: int = memory.read_u16(_g(A5_COLOUR_MODE))
	if mode == 1:
		_jt(JT_FLUSH_PANEL_1BIT, [])
		return
	for k in 0x100:
		memory.write_u16(inv + 2 * k, 0)
	var row_bytes: int = memory.read_u16(rec + 0xa) & 0x1fff
	if mode == 4 or mode == 8:
		var first: int = 0 if mode == 4 else 0xc8
		var last: int = 0xd if mode == 4 else 0xd9
		for k in range(first, last):
			var slot: int = memory.read_s16(C68kScript.u32(map + 2 * k))
			if slot >= 0 and slot <= 0xff:
				memory.write_u16(inv + 2 * slot, k)
		var nibbles: bool = mode == 4
		var panel: int = memory.read_u32(_g(A5_PANEL_PORT))
		var rows: int = C68kScript.u16(memory.read_u16(panel + 0x14) - memory.read_u16(panel + 0x10))
		var width: int = C68kScript.u16(memory.read_u16(panel + 0x16) - memory.read_u16(panel + 0x12))
		_remap_bitmap(inv, table, memory.read_u32(memory.read_u32(_g(-0x12b0))), rows,
				C68kScript.s16(width) >> 1 if nibbles else width, row_bytes, nibbles)
		var gyro_width: int = memory.read_u16(_g(-0x11e4))
		_remap_bitmap(inv, table, memory.read_u32(memory.read_u32(_g(-0x11dc))), memory.read_u16(_g(-0x11e2)),
				C68kScript.s16(gyro_width) >> 1 if nibbles else gyro_width, memory.read_u16(_g(-0x11de)) & 0x1fff, nibbles)
		for pair in [[-0x11fa, 4, 0, 0], [-0x11f8, 1, 1, 1]]:
			var c: int = _colour_via(table, pair[3], pair[2], pair[1])
			if nibbles:
				memory.write_u16(_g(pair[0]), C68kScript.u16((c << 12) | (c << 8) | (c << 4) | c))
			else:
				memory.write_u16(_g(pair[0]), C68kScript.u16((c << 8) | c))
	memory.write_u16(_g(-0x11ae), _colour_via(table, 0, 2, 0))
	memory.write_u16(_g(-0x11ac), _colour_via(table, 0, 0, 0))
	memory.write_u16(_g(-0x11a2), _colour_via(table, 3, 3, 3))
	if mode == 4:
		memory.write_u16(_g(-0x11a2), C68kScript.u16((memory.read_u16(_g(-0x11a2)) << 4) | memory.read_u16(_g(-0x11a2))))
	memory.write_u16(_g(-0x118c), _colour_via(table, 0, 0, 0))
	memory.write_u16(_g(-0x1188), _colour_via(table, 2, 2, 2))
	memory.write_u16(_g(-0x118a), _colour_via(table, 2, 2, 2))
	memory.write_u16(_g(-0x117c), _colour_via(table, 2, 2, 2))
	memory.write_u16(_g(-0x117e), _colour_via(table, 0, 0, 0))
	memory.write_u16(_g(-0x112c), _colour_via(table, 0, 0, 0))
	memory.write_u16(_g(-0x12a4), _colour_via(table, 3, 3, 3))
	if mode == 4:
		memory.write_u16(_g(-0x12a4), C68kScript.u16((memory.read_u16(_g(-0x12a4)) << 4) | memory.read_u16(_g(-0x12a4))))

const TRAP_PEN_PAT: int = 0xa89d
const TRAP_LINE: int = 0xa892
const A5_BIT_MASKS: int = -0x1fb6   ## 8 words: the bit of x & 7
## The 7 x 7 window's weights, W[dx][row] (969 in all): immediates of the unrolled original.
const WINDOW: Array = [[0, 1, 3, 4, 3, 1, 0], [1, 8, 21, 29, 21, 8, 1], [3, 21, 54, 73, 54, 21, 3],
		[4, 29, 73, 97, 73, 29, 4], [3, 21, 54, 73, 54, 21, 3], [1, 8, 21, 29, 21, 8, 1], [0, 1, 3, 4, 3, 1, 0]]

## 0xa3c: a 1-bit 3x image (the port `src`: bits +2, rowBytes +6) drawn as grey palette pixels at
## (x0, y0): for each output pixel (rows - 1 by cols, the source advancing 3 pixels / rows) the
## weighted count of set bits in its 7 x 7 window, when non-zero, as a grey (sum * 0xffff / 969) put
## through nearest_palette_index_rgb and JT $36a and plotted (MoveTo, Line(0, 0)) in the black pen
## pattern; `out` (when given, cleared first) marks the columns drawn.
func antialias_downsample_bw_3x(src: int, x0: int, y0: int, rows: int, cols: int, out: int) -> void:
	assert(a7 != 0, "antialias_downsample_bw_3x needs a7 (its frame holds the grey)")
	var a6: int = a7 - 4
	var s: int = C68kScript.u32(src)
	_trap(TRAP_PEN_PAT, [_g(-0x161c)])
	var step: int = memory.read_s16(s + 6)
	var row: Array = [memory.read_u32(s + 2)]
	for k in range(1, 7):
		row.append(C68kScript.u32(row[k - 1] + step))
	var step3: int = C68kScript.s16(C68kScript.u16(step * 3))
	var o: int = C68kScript.u32(out)
	var n: int = C68kScript.s16(cols)
	if o != 0:
		for i in n:
			memory.write_u8(C68kScript.u32(o + i), 0)
	var r: int = 0
	while r < C68kScript.s16(C68kScript.u16(rows - 1)):
		var x: int = 0
		for i in n:
			var sum: int = 0
			for dx in 7:
				var at: int = C68kScript.s16(C68kScript.u16(x + dx))
				var mask: int = memory.read_u16(_g(A5_BIT_MASKS + 2 * (at & 7)))
				var bx: int = at >> 3
				for k in 7:
					var w: int = WINDOW[dx][k]
					if w != 0 and memory.read_u8(C68kScript.u32(row[k] + bx)) & mask != 0:
						sum += w
			sum = C68kScript.s16(C68kScript.u16(sum))
			if sum != 0:
				var level: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.u32(C68kScript.u32(sum) * 0xffff)), 0x3c9))
				memory.write_u16(a6 - 0x2a, level)
				memory.write_u16(a6 - 0x28, level)
				memory.write_u16(a6 - 0x2c, level)
				_jt(JT_FORE_PANEL_COLOUR, [nearest_palette_index_rgb(a6 - 0x2c) & 0xffff])
				_trap(TRAP_MOVE_TO, [C68kScript.u16(y0 + r), C68kScript.u16(x0 + i)])
				_trap(TRAP_LINE, [0, 0])
				if o != 0:
					memory.write_u8(C68kScript.u32(o + i), 1)
			x = C68kScript.s16(C68kScript.u16(x + 3))
		for k in 7:
			row[k] = C68kScript.u32(row[k] + step3)
		r += 1

const TRAP_CUR_RES_FILE: int = 0xa994
const TRAP_FORE_COLOR: int = 0xa862
const TRAP_USE_RES_FILE: int = 0xa998
const TRAP_FILL_RGN: int = 0xa8d6
const TRAP_PAINT_RGN: int = 0xa8d3
const TRAP_DISPOSE_DIALOG: int = 0xa983
const JT_NEW_HANDLE: int = 0x24a          ## NewHandle(size) (Pascal)
const JT_NEW_HANDLE_CLEAR: int = 0x252    ## NewHandleClear(size) (Pascal)
const JT_CREATING_PANEL_DIALOG: int = 0x49a  ## show_creating_panel_dialog (C): the dialog
const JT_VIEW_FRAME_OUTLINE: int = 0x3ba  ## draw_view_frame_outline (C)
const LOCAL_RELEASE_BITMAPS: int = 0x59f4 ## releases the current panel bitmaps (C; not exported)
const PANEL_ENTRY_SIZE: int = 0x160

func _entry(n: int) -> int:
	return C68kScript.u32(C68kScript.s16(n) * PANEL_ENTRY_SIZE + memory.read_u32(memory.read_u32(_g(-0x13b2))))

func _copy(dst: int, src: int, n: int) -> void:
	for k in n:
		memory.write_u8(C68kScript.u32(dst + k), memory.read_u8(C68kScript.u32(src + k)))

## The screen records an entry of the panel cache holds: (A5 offset, entry offset, bytes).
const PANEL_RECORDS: Array = [[-0x11c8, 0xe8, 0x2c], [-0x119c, 0x114, 0x16], [-0x1186, 0x12a, 0xc], [-0x117a, 0x136, 0x18],
		[-0x1162, 0x14e, 0xc], [-0x1156, 0x15a, 6]]

## The panel bitmap locked and lent to the panel port (base and rowBytes of its pixel map).
func _lend_panel_bitmap(a6: int) -> void:
	_jt(JT_HLOCK, [memory.read_u32(_g(-0x12b0))])
	memory.write_u32(a6 - 0x22, memory.read_u32(_g(-0x160c)))
	var pm: int = memory.read_u32(memory.read_u32(memory.read_u32(_g(A5_PANEL_PORT)) + 2))
	memory.write_u32(pm, memory.read_u32(memory.read_u32(_g(-0x12b0))))
	pm = memory.read_u32(memory.read_u32(memory.read_u32(_g(A5_PANEL_PORT)) + 2))
	memory.write_u16(pm + 4, memory.read_u16(_entry(memory.read_u16(_g(-0x13ae))) + 0xa))
	_trap(TRAP_SET_PORT, [memory.read_u32(_g(A5_PANEL_PORT))])

## The left or right corner arc of the panel's upper edge (design x from `x0` to `x1`, y 1010..1540).
func _corner_arc(a6: int, x0: int, x1: int, start: int, sweep: int) -> void:
	var rect: int = a6 - 0x1e
	memory.write_u16(rect + 2, _h(x0))
	memory.write_u16(rect, C68kScript.u16(_v(0x3f2) + 1))
	memory.write_u16(rect + 6, _h(x1))
	memory.write_u16(rect + 4, C68kScript.u16(_v(0x604) + 1))
	dial_point_at_angle(rect, start, sweep, a6 - 6, a6 - 8)

func _line_to(x: int, dx: int, y: int, dy: int) -> void:
	var h: int = C68kScript.u16(_h(x) + dx)
	_trap(TRAP_LINE_TO, [C68kScript.u16(_v(y) + dy), h])

## 0x5cc4: the instrument panel made ready: the panel scale (3/4 of the half view width, A5 - 0x149e /
## -0x149a), the sine / cosine routines from the overlay, the cache "Bitmap Cache" ('HEL2' 127, made
## of four 0x160-byte entries when missing), the screen layout, the panel port on its buffer. A cache
## entry of this display configuration (depth, colour bits, view size) that is current or stored is
## used (a stored one loaded: its records, bitmaps 'HEL2' 200 / 300 / 400 / 500 + entry, made the
## most recent, recoloured) with its gyro window blanked; otherwise the panel is drawn afresh into
## the least recently used entry (handles made, key and rowBytes set, the frame and edge regions, the
## outline, all instruments at their design places, the records saved, the bitmaps stored as
## resources, recoloured) under the "creating panel" dialog. Then the gyro tape port (depths 1 / 4)
## and the horizon face region (depth 1); the resource file restored.
func prepare_instrument_panel() -> void:
	assert(a7 != 0, "prepare_instrument_panel needs a7 (its frame holds the rects)")
	var entry: int = a7
	var a6: int = entry - 4
	var r: int = a6 - 0x1e
	memory.write_u16(a6 - 0xa, 0)
	var saved_res: int = _trap(TRAP_CUR_RES_FILE, []) & 0xffff
	memory.write_u16(a6 - 0x28, saved_res)
	_trap(TRAP_USE_RES_FILE, [memory.read_u16(_g(-0x1002))])
	var w: int = memory.read_s16(_g(-0x1372))
	var scale: int = C68kScript.s16(C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(C68kScript.divs_trunc(w, 2) + w)), 2)))
	memory.write_u32(_g(A5_DESIGN_SCALE), C68kScript.u32(scale))
	memory.write_u32(_g(-0x149a), memory.read_u32(_g(A5_DESIGN_SCALE)))
	memory.write_u32(_g(A5_COS), memory.read_u32(_g(-0x1066)))
	memory.write_u32(_g(A5_SIN), memory.read_u32(_g(-0x1062)))
	memory.write_u32(_g(-0x13b2), C68kScript.u32(_trap(TRAP_GET_RESOURCE, [0x7f, PANEL_TYPE])))
	if memory.read_u32(_g(-0x13b2)) == 0:
		memory.write_u32(_g(-0x13b2), C68kScript.u32(_jt(JT_NEW_HANDLE_CLEAR, [0x580])))
		_trap(TRAP_ADD_RESOURCE, [memory.read_u32(_g(-0xdfa)), 0x7f, PANEL_TYPE, memory.read_u32(_g(-0x13b2))])
	compute_panel_screen_addresses()
	memory.write_u16(r + 2, 0)
	memory.write_u16(r + 6, memory.read_u16(_g(-0x1372)))
	memory.write_u16(r, _v(0x29e))
	memory.write_u16(r + 4, memory.read_u16(_g(-0x1370)))
	if memory.read_u32(_g(-0x11cc)) != 0:
		close_port_glue(memory.read_u32(_g(-0x11cc)))
		memory.write_u32(_g(-0x11cc), 0)
	if memory.read_u32(_g(-0x13b6)) != 0:
		_trap(TRAP_DISPOSE_RGN, [memory.read_u32(_g(-0x13b6))])
	if memory.read_u32(_g(A5_PANEL_PORT)) != 0:
		close_port_glue(memory.read_u32(_g(A5_PANEL_PORT)))
	a7 = entry - 4 - 0x30 - 0x12 - 4
	memory.write_u32(_g(A5_PANEL_PORT), open_cport_on_buffer(_g(-0x1492), 0, 0, memory.read_u32(r), memory.read_u32(r + 4)))
	a7 = entry
	var found: bool = false
	for i in 4:
		var e: int = _entry(i)
		var same: bool = true
		for check in [[0, A5_COLOUR_MODE], [2, -0x137e], [4, -0x137c], [6, -0x1372], [8, -0x1370]]:
			if memory.read_u16(e + check[0]) != memory.read_u16(_g(check[1])):
				same = false
				break
		if not same:
			continue
		var current: bool = memory.read_s16(_g(-0x13ae)) == i
		if not current and memory.read_u16(e + 0xc) == 0:
			continue
		if not current:
			_load_cached_panel(entry, i)
		_lend_panel_bitmap(a6)
		memory.write_u16(r + 2, memory.read_u16(_g(-0x11ec)))
		memory.write_u16(r, memory.read_u16(_g(-0x11ee)))
		memory.write_u16(r + 6, C68kScript.u16(memory.read_u16(r + 2) + memory.read_u16(_g(-0x11ea))))
		memory.write_u16(r + 4, C68kScript.u16(memory.read_u16(r) + memory.read_u16(_g(-0x11e8))))
		_trap(TRAP_FORE_COLOR, [0x21])
		_trap(TRAP_PAINT_RECT, [_box(r)])
		_trap(TRAP_SET_PORT, [memory.read_u32(a6 - 0x22)])
		_jt(JT_HUNLOCK, [memory.read_u32(_g(-0x12b0))])
		found = true
		break
	if not found:
		_draw_new_panel(entry, a6, r)
	if memory.read_u16(_g(A5_COLOUR_MODE)) == 1 or memory.read_u16(_g(A5_COLOUR_MODE)) == 4:
		memory.write_u16(r + 2, 0)
		memory.write_u16(r, 0)
		memory.write_u16(r + 6, memory.read_u16(_g(-0x11e4)))
		memory.write_u16(r + 4, memory.read_u16(_g(-0x11e2)))
		a7 = entry - 4 - 0x30 - 0x12 - 4
		memory.write_u32(_g(-0x11cc), open_cport_on_buffer(_g(-0x1426), memory.read_u16(_g(-0x11de)), 0, memory.read_u32(r), memory.read_u32(r + 4)))
		a7 = entry
	if memory.read_u16(_g(A5_COLOUR_MODE)) == 1:
		memory.write_u32(_g(-0x13b6), make_inset_face_oval_region(a6 - 0x30, 0x2d0, 0x49c, 0x4ce))
	_trap(TRAP_USE_RES_FILE, [memory.read_u16(a6 - 0x28)])

## A stored cache entry `i` made current: its records and bitmaps loaded, it made the most recent.
func _load_cached_panel(entry: int, i: int) -> void:
	for k in 0xa:
		_copy(_g(-0x12a2 + 0x10 * k), _entry(i) + 0x10 * k + 0x12, 0x10)
	_local(LOCAL_RELEASE_BITMAPS, [])
	_copy(_g(-0x1202), _entry(i) + 0xb2, 0x14)
	memory.write_u32(_g(-0x11f6), C68kScript.u32(_trap(TRAP_GET_RESOURCE, [C68kScript.u16(i + 0x12c), PANEL_TYPE])))
	_copy(_g(-0x11ee), _entry(i) + 0xc6, 0x22)
	memory.write_u32(_g(-0x11dc), C68kScript.u32(_trap(TRAP_GET_RESOURCE, [C68kScript.u16(i + 0x190), PANEL_TYPE])))
	memory.write_u32(_g(-0x11d4), C68kScript.u32(_trap(TRAP_GET_RESOURCE, [C68kScript.u16(i + 0x1f4), PANEL_TYPE])))
	for k in 4:
		if memory.read_s32(_entry(i) + 0xe) < memory.read_s32(_entry(k) + 0xe):
			memory.write_u32(_entry(i) + 0xe, C68kScript.u32(memory.read_u32(_entry(k) + 0xe) + 1))
			_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(_g(-0x13b2))])
	for rec in PANEL_RECORDS:
		_copy(_g(rec[0]), _entry(i) + rec[1], rec[2])
	memory.write_u32(_g(-0x12b0), C68kScript.u32(_trap(TRAP_GET_RESOURCE, [C68kScript.u16(i + 0xc8), PANEL_TYPE])))
	memory.write_u16(_g(-0x12a8), memory.read_u16(_entry(i) + 0xa) & 0x1fff)
	memory.write_u16(_g(-0x12a6), _v(0x29e))
	memory.write_u16(_g(-0x211e), i)
	memory.write_u16(_g(-0x13ae), i)
	_trap(TRAP_UPDATE_RES_FILE, [memory.read_u16(_g(-0x1002))])
	var e2: int = a7
	a7 = entry - 4 - 0x30 - 4
	remap_panel_colours_identity()
	a7 = e2

func _draw_new_panel(entry: int, a6: int, r: int) -> void:
	var dialog: int = C68kScript.u32(_jt(JT_CREATING_PANEL_DIALOG, []))
	memory.write_u32(a6 - 0x26, dialog)
	var best: int = 0x7fffffff
	var k: int = 0
	for i in 4:
		var use: int = memory.read_s32(_entry(i) + 0xe)
		if use < best:
			best = use
			k = i
	_local(LOCAL_RELEASE_BITMAPS, [])
	memory.write_u16(_g(-0x211e), k)
	memory.write_u16(_g(-0x13ae), k)
	memory.write_u32(_g(-0x12b0), C68kScript.u32(_jt(JT_NEW_HANDLE, [1])))
	memory.write_u32(_g(-0x11f6), C68kScript.u32(_jt(JT_NEW_HANDLE_CLEAR, [1])))
	memory.write_u32(_g(-0x11dc), C68kScript.u32(_jt(JT_NEW_HANDLE_CLEAR, [1])))
	memory.write_u32(_g(-0x11d4), C68kScript.u32(_jt(JT_NEW_HANDLE_CLEAR, [1])))
	best = -0x80000000
	for i in 4:
		best = maxi(best, memory.read_s32(_entry(i) + 0xe))
	var cur: int = memory.read_u16(_g(-0x13ae))
	memory.write_u32(_entry(cur) + 0xe, C68kScript.u32(best + 1))
	_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(_g(-0x13b2))])
	memory.write_u16(_entry(cur), memory.read_u16(_g(A5_COLOUR_MODE)))
	memory.write_u16(_entry(cur) + 2, memory.read_u16(_g(-0x137e)))
	memory.write_u16(_entry(cur) + 4, memory.read_u16(_g(-0x137c)))
	memory.write_u16(_entry(cur) + 6, memory.read_u16(_g(-0x1372)))
	memory.write_u16(_entry(cur) + 8, memory.read_u16(_g(-0x1370)))
	var bits: int = C68kScript.u16(memory.read_s16(_g(-0x1372)) * memory.read_s16(_g(A5_COLOUR_MODE)) + 0xf)
	memory.write_u16(_entry(cur) + 0xa, C68kScript.u16((C68kScript.s16(bits) >> 4) * 2) | 0x8000)
	var rows: int = C68kScript.u32(C68kScript.s16(C68kScript.u16(memory.read_u16(r + 4) - memory.read_u16(r))))
	_jt(JT_SET_HANDLE_SIZE, [C68kScript.u32(rows * (memory.read_u16(_entry(cur) + 0xa) & 0x1fff)), memory.read_u32(_g(-0x12b0))])
	memory.write_u16(_g(-0x12a8), memory.read_u16(_entry(cur) + 0xa) & 0x1fff)
	memory.write_u16(_g(-0x12a6), _v(0x29e))
	_lend_panel_bitmap(a6)
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_PAINT_RECT, [_box(memory.read_u32(_g(A5_PANEL_PORT)) + 0x10)])
	_trap(TRAP_PEN_SIZE, [1, 1])
	var frame: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	memory.write_u32(a6 - 0x12, frame)
	_trap(TRAP_OPEN_RGN, [])
	_jt(JT_VIEW_FRAME_OUTLINE, [])
	_trap(TRAP_CLOSE_RGN, [frame])
	var edge: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	memory.write_u32(a6 - 0x16, edge)
	_trap(TRAP_OPEN_RGN, [])
	_panel_edge(entry, a6)
	_trap(TRAP_CLOSE_RGN, [edge])
	_trap(TRAP_DIFF_RGN, [frame, edge, frame])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(1)])
	_jt(JT_BACK_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_FILL_RGN, [C68kScript.u32(_jt(JT_PANEL_PATTERN, [])), frame])
	_trap(TRAP_PAINT_RGN, [edge])
	_jt(JT_FORE_PANEL_COLOUR, [_panel_colour(0)])
	_trap(TRAP_DISPOSE_RGN, [edge])
	_trap(TRAP_DISPOSE_RGN, [frame])
	_trap(TRAP_PEN_SIZE, [3, 3])
	_jt(JT_VIEW_FRAME_OUTLINE, [])
	var h: int = C68kScript.u16(_h(-0xc80) - 1)
	_trap(TRAP_MOVE_TO, [_v(0x4b0), h])
	_line_to(-0xc80, 0, 0x4b0, 0)
	_line_to(-0x424, 0, 0x29e, 0)
	_line_to(0x424, -4, 0x29e, 0)
	_line_to(0xc80, -4, 0x4b0, 0)
	_line_to(0xfa0, 0, 0x4b0, 0)
	a7 = entry - 4 - 0x30 - 0x10 - 4
	_corner_arc(a6, -0xa69, -0x857, -0xe, -0x5a)
	_line_to(-0x95a, 0, 0x960, 1)
	_corner_arc(a6, 0x857, 0xa69, 0xe, 0x5a)
	_line_to(0x95a, -3, 0x960, 1)
	_draw_panel_instruments(entry)
	var cur2: int = memory.read_u16(_g(-0x13ae))
	_copy(_entry(cur2) + 0xb2, _g(-0x1202), 0x14)
	_copy(_entry(cur2) + 0xc6, _g(-0x11ee), 0x22)
	for n in 0xa:
		_copy(_entry(cur2) + 0x10 * n + 0x12, _g(-0x12a2 + 0x10 * n), 0x10)
	for rec in PANEL_RECORDS:
		_copy(_entry(cur2) + rec[1], _g(rec[0]), rec[2])
	_trap(TRAP_SET_PORT, [memory.read_u32(a6 - 0x22)])
	_jt(JT_HUNLOCK, [memory.read_u32(_g(-0x12b0))])
	_trap(TRAP_DISPOSE_DIALOG, [memory.read_u32(a6 - 0x26)])
	store_panel_bitmaps_as_resources()
	a7 = entry - 4 - 0x30 - 4
	remap_panel_colours_identity()
	a7 = entry

## The panel's upper edge (recorded into the edge region): both corner arcs, the slanted sides to
## (-/+2394, 2400) and the top from (-/+1060, 670).
func _panel_edge(entry: int, a6: int) -> void:
	a7 = entry - 4 - 0x30 - 0x10 - 4
	_corner_arc(a6, -0xa69, -0x857, -0xe, -0x5a)
	a7 = entry
	_line_to(-0x95a, 0, 0x960, 1)
	_line_to(0x95a, -3, 0x960, 1)
	_trap(TRAP_MOVE_TO, [memory.read_u16(a6 - 8), memory.read_u16(a6 - 6)])
	_line_to(-0x424, 0, 0x29e, 0)
	a7 = entry - 4 - 0x30 - 0x10 - 4
	_corner_arc(a6, 0x857, 0xa69, 0xe, 0x5a)
	a7 = entry
	_line_to(0x95a, -3, 0x960, 1)
	_trap(TRAP_MOVE_TO, [memory.read_u16(a6 - 8), memory.read_u16(a6 - 6)])
	_line_to(0x424, -4, 0x29e, 0)
	_line_to(-0x424, 0, 0x29e, 0)

## Every instrument at its design place (size, tick, pen, y, x).
func _draw_panel_instruments(entry: int) -> void:
	memory.write_u16(_g(-0x2114), 0x28)
	a7 = entry - 4 - 0x30 - 4
	draw_panel_section_with_numbered_boxes()
	a7 = entry - 4 - 0x30 - 0xc - 4
	draw_percent_scale_gauge(0x14a, 0x258, 7, scale_design_480_min10(0xa), 0x794, 0x898)
	draw_split_display_box(0x17c, 0x17c, (7 << 16) | (scale_design_480_min10(0xa) & 0xffff), 0x474, -0x2a8)
	draw_instrument(0, 0x30c, 0xa, scale_design_480_min10(0xc), 0x744, -0x67c)
	draw_instrument(1, 0x30c, 9, scale_design_480_min10(0xa), 0x744, -0x320)
	draw_instrument(2, 0x280, 7, scale_design_480_min10(0xa), 0x794, 0)
	draw_instrument(3, 0x2a8, 8, scale_design_480_min10(0xa), 0x780, 0x320)
	draw_instrument(4, 0x2a8, 7, scale_design_480_min10(0xa), 0x780, 0x67c)
	draw_instrument(5, 0x230, 7, scale_design_480_min10(0xa), 0x544, 0x898)
	draw_instrument(6, 0x21c, 7, scale_design_480_min10(0xa), 0x550, -0x898)
	a7 = entry - 4 - 0x30 - 0xa - 4
	draw_landing_gear_indicator(0x258, 7, scale_design_480_min10(0xa), 0x7a8, -0xb2c)
	draw_flaps_indicator(0x190, 7, scale_design_480_min10(0xa), 0x582, -0xb54)
	draw_fuel_gauge(0x258, 9, scale_design_480_min10(0xa), 0x7a8, 0xb2c)
	draw_ammo_counter(0x190, 7, scale_design_480_min10(0xa), 0x582, 0xb54)
	memory.write_u16(_g(-0x2114), 0x32)
	a7 = entry - 4 - 0x30 - 0xc - 4
	draw_instrument(9, 0x2d0, 0xa, scale_design_480_min10(0xa), 0x49c, 0x4ce)
	memory.write_u16(_g(-0x2114), 0x28)
	draw_instrument(8, 0x258, 9, scale_design_480_min10(0xa), 0x474, -0x4ce)
	a7 = entry
