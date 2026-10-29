class_name StrictID06
extends RefCounted
## Strict translations owned by CODE segment 6 (ID06.bin; address = file offset, 4-byte header):
## the software rasteriser (1-bit patterns, colour map, raster target, row table, edge pool,
## polygon edges). The sole provenance and verification record lives in mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`;
## the "a5safe" routines reload it from CurrentA5 at 0x904). Calls leaving the segment go through
## `_jt`, filled by tests with logging stand-ins.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const A5_PATTERNS: int = -0x1eda      ## long: 0xc00-byte pattern table (32 x 8 masks, 64 x 8 patterns)
const A5_COLOUR_MAP: int = -0x1ede    ## long: 256 colour words
const A5_PATTERN_BYTES: int = -0x1ed6 ## 64 x 8 bytes of grey patterns (A5 data)
const A5_TARGET: int = -0x1cce        ## long: raster target (0x10 bytes)
const A5_ROWS: int = -0x1cd2          ## long: row table (0x24 bytes; +4 rows of 12 bytes)
const A5_POOL: int = -0x1cd6          ## long: edge pool (0x5e9c bytes)
const A5_HALF_W: int = -0x1cca        ## word: x offset (width / 2)
const A5_HALF_H: int = -0x1cc8        ## word: y offset (height / 2)
const A5_ACTIVE_ROWS: int = -0x1cc6   ## word
const A5_RENDERER: int = 0x192        ## the row renderer's jump-table entry (A5 + 0x192)
const LM_CURRENT_A5: int = 0x904
const JT_FREE_MEM: int = 0x212
const JT_MAX_MEM: int = 0x21a
const JT_NEW_PTR: int = 0x232
const JT_DISPOSE_PTR: int = 0x23a

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

func _g(offset: int) -> int:
	return C68kScript.u32(a5 + offset)

func _l(offset: int) -> int:
	return memory.read_u32(_g(offset))

## 0x4: the pattern table: 32 groups of 8 copies of the left-edge masks (0, 0x80000000,
## 0xc0000000, ...), then 64 grey levels x 8 rows of the pattern byte repeated in all four bytes,
## and the colour map: entry i = ((0x3f - (i asr 4) * 4) << 5) + 0x400. Returns 1.
func init_pattern_tables() -> int:
	var p: int = _l(A5_PATTERNS)
	var mask: int = 0
	for _g6 in 0x20:
		for _k in 8:
			memory.write_u32(p, mask)
			p += 4
		mask = (mask >> 1) | 0x80000000
	var src: int = _g(A5_PATTERN_BYTES)
	for level in 0x40:
		for row in 8:
			var b: int = memory.read_u8(C68kScript.u32(src + C68kScript.s16(C68kScript.u16((level << 3) + row))))
			var w: int = b | (b << 8)
			memory.write_u32(p, (w << 16) | w)
			p += 4
	for i in 0x100:
		var v: int = C68kScript.u16(C68kScript.u16(C68kScript.u16(0x3f - ((i >> 4) << 2)) << 3) << 2)
		memory.write_u16(C68kScript.u32(_l(A5_COLOUR_MAP) + 2 * i), C68kScript.u16(v + 0x400))
	return 1

## 0xb0: the pattern table (0xc00) and colour map (0x200) allocated when missing (0 on failure),
## then init_pattern_tables.
func alloc_pattern_tables() -> int:
	if _l(A5_PATTERNS) == 0:
		var p: int = alloc_aligned_clear(0xc00)
		memory.write_u32(_g(A5_PATTERNS), p)
		if p == 0:
			return 0
	if _l(A5_COLOUR_MAP) == 0:
		var m: int = alloc_aligned_clear(0x200)
		memory.write_u32(_g(A5_COLOUR_MAP), m)
		if m == 0:
			return 0
	return init_pattern_tables()

## 0xf4: the pattern table, allocated (0xc00) when missing; 0 on failure.
func get_pattern_table() -> int:
	if _l(A5_PATTERNS) == 0:
		var p: int = alloc_aligned_clear(0xc00)
		memory.write_u32(_g(A5_PATTERNS), p)
		if p == 0:
			return 0
	return _l(A5_PATTERNS)

## 0x116: the grey pattern of an RGB colour (words; the high bytes weighted 0x13 / 0x26 / 7,
## LSR.W 6): A5 - 0x1ed6 + (0x3f - luma / 4) * 8.
func rgb_to_bw_pattern(r: int, g: int, b: int) -> int:
	var luma: int = C68kScript.u16(C68kScript.u16(((r & 0xffff) >> 8) * 0x13) + C68kScript.u16(((g & 0xffff) >> 8) * 0x26)
			+ C68kScript.u16(((b & 0xffff) >> 8) * 7)) >> 6
	var idx: int = C68kScript.s16(C68kScript.u16(C68kScript.u16(0x3f - (C68kScript.s16(luma) >> 2)) << 3))
	return C68kScript.u32(_g(A5_PATTERN_BYTES) + idx)

## 0x17c: colour map entry (index clamped to 0xff from 0x100); a word.
func lookup_colour_map(index: int) -> int:
	var i: int = C68kScript.s16(index)
	if i >= 0x100:
		i = 0xff
	return memory.read_u16(C68kScript.u32(_l(A5_COLOUR_MAP) + C68kScript.s32(i * 2)))

## 0x1a2: the first index whose colour map entry is the value, else 0 (a word).
func reverse_lookup_colour_map(value: int) -> int:
	for i in 0x100:
		if memory.read_u16(C68kScript.u32(_l(A5_COLOUR_MAP) + 2 * i)) == (value & 0xffff):
			return i
	return 0

## 0x1dc: a long-aligned block of `size` bytes (NewPtr size + 12; MaxMem first when FreeMem is
## under 0x7a120) with the size at -4 and the allocation at -8; 0 when NewPtr fails.
func alloc_aligned_clear(size: int) -> int:
	if C68kScript.s32(_jt(JT_FREE_MEM, [])) < 0x7a120:
		_jt(JT_MAX_MEM, [[]])
	var p: int = C68kScript.u32(_jt(JT_NEW_PTR, [C68kScript.u32(size + 0xc)]))
	if p == 0:
		return 0
	var aligned: int = (p + 0xc) & 0xfffffffc
	memory.write_u32(aligned - 4, C68kScript.u32(size))
	memory.write_u32(aligned - 8, p)
	return aligned

## 0x24c: DisposPtr of the allocation behind an aligned block; 0 for null, else 1.
func free_aligned(p: int) -> int:
	if C68kScript.u32(p) == 0:
		return 0
	_jt(JT_DISPOSE_PTR, [memory.read_u32(C68kScript.u32(p - 8))])
	return 1

## 0x26c: the row table's fields: renderer A5 + 0x192, colour (colour map), shift 0xb, the row
## origin (target +4 - (target +8 * target +6) / 8), each row's pattern row (pattern table + (row
## % 8) * 4), the row count, and the two flags cleared. Returns 1.
func init_row_table_fields(colour: int, rows: int) -> int:
	var rt: int = _l(A5_ROWS)
	var tgt: int = _l(A5_TARGET)
	memory.write_u32(rt, _g(A5_RENDERER))
	memory.write_u16(rt + 8, lookup_colour_map(colour))
	memory.write_u16(rt + 0xa, 0xb)
	var span: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_s16(tgt + 8) * memory.read_s16(tgt + 6))), 8))
	memory.write_u16(rt + 0xc, C68kScript.u16(memory.read_u16(tgt + 4) - span))
	var r: int = 0
	while r < C68kScript.s16(rows):
		var rem: int = r - C68kScript.divs_trunc(r, 8) * 8
		memory.write_u32(C68kScript.u32(memory.read_u32(rt + 4) + r * 0xc + 8), C68kScript.u32(memory.read_u32(tgt + 0xc) + rem * 4))
		r += 1
	memory.write_u16(rt + 0xe, rows & 0xffff)
	memory.write_u32(rt + 0x10, 0)
	memory.write_u32(rt + 0x14, 0)
	return 1

## 0x512: the row table's rows, its +0x1c / +0x20 blocks and the table itself freed; cleared.
func free_row_table() -> void:
	var rt: int = _l(A5_ROWS)
	for off in [4, 0x1c, 0x20]:
		rt = _l(A5_ROWS)
		if rt != 0 and memory.read_u32(rt + off) != 0:
			free_aligned(memory.read_u32(rt + off))
	if _l(A5_ROWS) != 0:
		free_aligned(_l(A5_ROWS))
	memory.write_u32(_g(A5_ROWS), 0)

## 0x598: with a target: a row table too small for `rows` is freed; a new one (0x24) and its rows
## (rows * 12) allocated (0 on failure); every row cleared; init_row_table_fields.
func alloc_row_table(colour: int, rows: int) -> int:
	if _l(A5_TARGET) == 0:
		return 0
	if _l(A5_ROWS) != 0 and memory.read_s16(_l(A5_ROWS) + 0xe) < C68kScript.s16(rows):
		free_row_table()
	if _l(A5_ROWS) == 0:
		var rt: int = alloc_aligned_clear(0x24)
		memory.write_u32(_g(A5_ROWS), rt)
		if rt == 0:
			return 0
		var block: int = alloc_aligned_clear(C68kScript.u32(C68kScript.u32(C68kScript.s16(rows)) * 0xc))
		memory.write_u32(_l(A5_ROWS) + 4, block)
		if block == 0:
			return 0
	var r: int = 0
	while r < C68kScript.s16(rows):
		var row: int = C68kScript.u32(memory.read_u32(_l(A5_ROWS) + 4) + r * 0xc)
		memory.write_u32(row, 0)
		memory.write_u32(row + 4, 0)
		memory.write_u32(row + 8, 0)
		r += 1
	return init_row_table_fields(colour, rows)

## 0x666: the edge pool (0x5e9c, allocated when missing) with its two sentinel edges (head at
## +0x8ac, tail at +0x5e74, linked +0x10 / +0x14; colour words +0x1c / +0x1e from the row table,
## +0x22 = -10; the tail's x is width << (shift + extra)), the free edges from +0x8d4 to +0x5b7c.
## 0 without a row table or memory, else 1.
func init_edge_pool() -> int:
	if _l(A5_ROWS) == 0:
		return 0
	if _l(A5_POOL) == 0:
		var p: int = alloc_aligned_clear(0x5e9c)
		memory.write_u32(_g(A5_POOL), p)
		if p == 0:
			return 0
	var pool: int = _l(A5_POOL)
	memory.write_u32(pool + 0x898, C68kScript.u32(pool + 0x8ac))
	memory.write_u32(pool + 0x89c, C68kScript.u32(pool + 0x5e74))
	memory.write_u32(memory.read_u32(pool + 0x898) + 0x10, memory.read_u32(pool + 0x89c))
	memory.write_u32(memory.read_u32(pool + 0x89c) + 0x14, memory.read_u32(pool + 0x898))
	var rt: int = _l(A5_ROWS)
	var head: int = memory.read_u32(pool + 0x898)
	memory.write_u32(head, 0)
	memory.write_u16(head + 0x1c, memory.read_u16(rt + 8))
	memory.write_u16(head + 0x1e, memory.read_u16(rt + 8))
	memory.write_u16(head + 0x22, 0xfff6)
	var shift: int = C68kScript.u32(C68kScript.s16(memory.read_u16(rt + 0xa)) + memory.read_u32(rt + 0x10))
	var tail: int = memory.read_u32(pool + 0x89c)
	memory.write_u32(tail, C68kScript.lsl32(C68kScript.u32(memory.read_s16(_l(A5_TARGET) + 8)), shift))
	memory.write_u16(tail + 0x1c, memory.read_u16(rt + 8))
	memory.write_u16(tail + 0x1e, memory.read_u16(rt + 8))
	memory.write_u16(tail + 0x22, 0xfff6)
	memory.write_u32(pool, memory.read_u32(pool + 0x898))
	memory.write_u32(pool + 0x8a0, C68kScript.u32(pool + 0x8d4))
	memory.write_u32(pool + 0x8a4, memory.read_u32(pool + 0x8a0))
	memory.write_u32(pool + 0x8a8, C68kScript.u32(pool + 0x5b7c))
	return 1

## 0x7b0: the raster target over `base` (row bytes, depth 1, width, height, pattern table), its row
## table (`colour`, height rows) and edge pool; the x / y offsets are width / 2 and height / 2
## (ASR.W). 0 on any failure, else 1.
func init_raster_target(base: int, row_bytes: int, colour: int, width: int, height: int) -> int:
	if alloc_pattern_tables() & 0xffff == 0:
		return 0
	if _l(A5_TARGET) == 0:
		var t: int = alloc_aligned_clear(0x10)
		memory.write_u32(_g(A5_TARGET), t)
		if t == 0:
			return 0
	var tgt: int = _l(A5_TARGET)
	memory.write_u32(tgt, C68kScript.u32(base))
	memory.write_u16(tgt + 4, row_bytes & 0xffff)
	memory.write_u16(tgt + 6, 1)
	memory.write_u16(tgt + 8, width & 0xffff)
	memory.write_u16(tgt + 0xa, height & 0xffff)
	memory.write_u32(_l(A5_TARGET) + 0xc, get_pattern_table())
	if alloc_row_table(colour, height) & 0xffff == 0:
		return 0
	if init_edge_pool() & 0xffff == 0:
		return 0
	memory.write_u16(_g(A5_HALF_W), C68kScript.u16(C68kScript.s16(width) >> 1))
	memory.write_u16(_g(A5_HALF_H), C68kScript.u16(C68kScript.s16(height) >> 1))
	return 1

## 0x87a: the target's base address.
func set_raster_target_base(base: int) -> void:
	if _l(A5_TARGET) != 0:
		memory.write_u32(_l(A5_TARGET), C68kScript.u32(base))

## 0x8a2 (A5 from CurrentA5): with a target and a row table, the active rows (clamped to the
## target height when above it or below 1) become the row table's count; the active-row word
## (A5 - 0x1cc6) takes the row table's count - read through the row-table pointer even when it is
## null, as in the original.
func set_active_row_count(rows: int) -> void:
	var saved: int = a5
	a5 = memory.read_u32(LM_CURRENT_A5)
	var n: int = C68kScript.s32(rows)
	if _l(A5_TARGET) != 0 and _l(A5_ROWS) != 0:
		var height: int = memory.read_s16(_l(A5_TARGET) + 0xa)
		if height < n or n < 1:
			n = height
		memory.write_u16(_l(A5_ROWS) + 0xe, n & 0xffff)
	memory.write_u16(_g(A5_ACTIVE_ROWS), memory.read_u16(C68kScript.u32(_l(A5_ROWS) + 0xe)))
	a5 = saved

## 0x916: the target's width / height words into *w / *h; 1, or 0 without a target.
func get_raster_target_size(w: int, h: int) -> int:
	var tgt: int = _l(A5_TARGET)
	if tgt == 0:
		return 0
	memory.write_u16(w, memory.read_u16(tgt + 8))
	memory.write_u16(h, memory.read_u16(tgt + 0xa))
	return 1

## 0x942: the row table re-made for `colour` with its current count, then the edge pool; 0 on
## failure, else the edge pool's result (1).
func realloc_row_table(colour: int) -> int:
	if alloc_row_table(colour, memory.read_u16(_l(A5_ROWS) + 0xe)) & 0xffff == 0:
		return 0
	var r: int = init_edge_pool()
	return r if r & 0xffff != 0 else 0

## 0x96e (A5 from CurrentA5): every row's first two longs cleared (DBRA over the row count), the
## edge pool emptied, the frame flag (row table +0x14) toggled to 0 / 1, the active rows cleared.
func reset_edge_table() -> void:
	var saved: int = a5
	a5 = memory.read_u32(LM_CURRENT_A5)
	var rt: int = _l(A5_ROWS)
	var count: int = (memory.read_u16(rt + 0xe) - 1) & 0xffff
	var row: int = memory.read_u32(rt + 4)
	while true:
		memory.write_u32(row, 0)
		memory.write_u32(row + 4, 0)
		row = C68kScript.u32(row + 0xc)
		count = (count - 1) & 0xffff
		if count == 0xffff:
			break
	var pool: int = _l(A5_POOL)
	memory.write_u32(pool + 0x8a4, memory.read_u32(pool + 0x8a0))
	rt = _l(A5_ROWS)
	memory.write_u32(rt + 0x14, 1 if memory.read_u32(rt + 0x14) == 0 else 0)
	memory.write_u16(_g(A5_ACTIVE_ROWS), 0)
	a5 = saved

## MULS.L src, Dh:Dl then DIVS.L div, Dh:Dl (64-bit dividend): the quotient, or the low long of
## the product when the quotient overflows (the 68k leaves the registers unchanged then).
static func _muldiv(a: int, b: int, div: int) -> int:
	var p: int = C68kScript.s32(a) * C68kScript.s32(b)
	assert(C68kScript.s32(div) != 0, "add_polygon_edges: DIVS.L by zero")
	var q: int = C68kScript.divs_trunc(p, C68kScript.s32(div))
	if q < -0x80000000 or q > 0x7fffffff:
		return C68kScript.s32(p)
	return q

## 0x9d8 (A5 from CurrentA5): the edges of a polygon of `count` points (x, y longs at `points`,
## offset by the half sizes) into the edge pool, clipped to the target: none when it lies wholly
## left or right or the pool is full (0). Each non-horizontal edge, top to bottom, is clipped to
## row 0 and cut at x = 0 and x = width into vertical pieces (the outside parts become vertical
## edges at the border); each piece gets its slope (dx << shift / dy << extra), its start x
## << (shift + extra), the polygon's first edge (+0x18; colour / order words +0x1c / +0x24 set on
## that first edge), its bucket row (pushed on the row's list) and its remaining rows (+0x22),
## and marks the row it ends on. Returns 1 when any edge was added.
func add_polygon_edges(count: int, colour: int, order: int, points: int) -> int:
	var saved: int = a5
	a5 = memory.read_u32(LM_CURRENT_A5)
	var result: int = _add_polygon_edges(count, colour, order, points)
	a5 = saved
	return result

func _add_polygon_edges(count: int, colour: int, order: int, points: int) -> int:
	var rt: int = _l(A5_ROWS)
	var shift_a: int = memory.read_s16(rt + 0xa)
	var shift_b: int = memory.read_s16(rt + 0x12)
	var pool: int = _l(A5_POOL)
	var edge: int = memory.read_u32(pool + 0x8a4)
	var width: int = memory.read_s16(_l(A5_TARGET) + 8)
	var cx: int = memory.read_s16(_g(A5_HALF_W))
	var cy: int = memory.read_s16(_g(A5_HALF_H))
	var lo: int = width
	var hi: int = 0
	var n: int = C68kScript.s32(count)
	var p: int = C68kScript.u32(points)
	var left: int = n
	while left > 0:
		var x: int = C68kScript.s32(cx + memory.read_u32(p))
		p = C68kScript.u32(p + 8)
		if x < lo:
			lo = x
		if x > hi:
			hi = x
		left -= 1
	if hi == 0 or width == lo:
		return 0
	if C68kScript.u32(edge) >= memory.read_u32(pool + 0x8a8):
		return 0
	var first: int = edge
	memory.write_u16(edge + 0x1c, colour & 0xffff)
	memory.write_u16(first + 0x24, order & 0xffff)
	var rows: int = memory.read_s16(rt + 0xe)
	var last: int = C68kScript.u32(points + C68kScript.s32(C68kScript.lsl32(C68kScript.u32(n * 2 - 2), 2)))
	var x1: int = C68kScript.s32(cx + memory.read_u32(last))
	var y1: int = C68kScript.s32(cy + memory.read_u32(last + 4))
	var cur: int = C68kScript.u32(points)
	var k: int = n
	var carry: int = 0
	while true:
		var kk: int = k
		k = C68kScript.s32(k - 1)
		if kk == 0:
			break
		var x0: int = C68kScript.s32(cx + memory.read_u32(cur))
		var y0: int = C68kScript.s32(cy + memory.read_u32(cur + 4))
		cur = C68kScript.u32(cur + 8)
		var ok: bool = y0 != y1
		var tx: int = x0
		var ty: int = y0
		var bx: int = x1
		var by: int = y1
		if ok and y0 > y1:
			carry = x0
			tx = x1
			ty = y1
			bx = x0
			by = y0
		if ok and (by <= 0 or rows <= ty):
			ok = false
		if ok:
			if ty < 0:
				tx = C68kScript.s32(tx - _muldiv(bx - tx, ty, by - ty))
				ty = 0
			while true:
				var end_row: int
				var slope: int
				if tx <= 0:
					if bx > 0:
						end_row = C68kScript.s32(ty - _muldiv(by - ty, tx, bx - tx))
					else:
						end_row = by
					tx = 0
					carry = 1
					slope = 0
				elif width <= tx:
					if width > bx:
						end_row = C68kScript.s32(ty + _muldiv(by - ty, width - tx, bx - tx))
					else:
						end_row = by
					tx = width
					carry = C68kScript.s32(width - 1)
					slope = 0
				else:
					if bx <= 0:
						end_row = C68kScript.s32(ty - _muldiv(by - ty, tx - 1, bx - tx))
						carry = 0
					elif width <= bx:
						carry = width
						end_row = C68kScript.s32(ty - _muldiv(by - ty, -width + 1 + tx, bx - tx))
					else:
						end_row = by
					slope = C68kScript.lsl32(C68kScript.u32(_muldiv(bx - tx, C68kScript.lsl32(1, shift_a), by - ty)), shift_b)
				memory.write_u32(edge + 4, C68kScript.u32(slope))
				memory.write_u32(edge + 0x18, first)
				memory.write_u32(edge + 8, C68kScript.lsl32(C68kScript.u32(tx), C68kScript.u16(shift_a + shift_b)))
				var bucket: int = C68kScript.u32(C68kScript.u32(C68kScript.u32(ty) * 0xc) + memory.read_u32(rt + 4))
				memory.write_u32(edge + 0xc, memory.read_u32(bucket))
				memory.write_u32(bucket, edge)
				memory.write_u16(edge + 0x22, C68kScript.u16(rows - end_row - 1))
				if rows > end_row:
					memory.write_u32(C68kScript.u32(C68kScript.u32(C68kScript.u32(end_row) * 0xc) + memory.read_u32(rt + 4)) + 4, 1)
				edge = C68kScript.u32(edge + 0x28)
				if end_row < by and rows > end_row:
					ty = end_row
					tx = carry
					continue
				break
		x1 = C68kScript.s32(cx + memory.read_u32(C68kScript.u32(cur - 8)))
		y1 = C68kScript.s32(cy + memory.read_u32(C68kScript.u32(cur - 4)))
	memory.write_u32(pool + 0x8a4, edge)
	return 1 if edge != first else 0

## 0xd02: the rectangle (x0, y0) .. (x1, y1) (words) as a 4-point polygon in this routine's frame,
## added with the colour map colour and order 0.
func add_rect_polygon(colour: int, x0: int, y0: int, x1: int, y1: int) -> void:
	assert(a7 != 0, "add_rect_polygon needs a7 (its frame holds the points)")
	var pts: int = a7 - 4 - 0x30
	var values: Array = [x0, y0, x1, y0, x1, y1, x0, y1]
	for k in 8:
		memory.write_u32(pts + 4 * k, C68kScript.u32(C68kScript.s16(values[k])))
	var c: int = C68kScript.u32(C68kScript.s16(lookup_colour_map(colour)))
	var entry: int = a7
	a7 = entry - 4 - 0x30 - 4 - 0x10 - 4
	add_polygon_edges(4, c, 0, pts)
	a7 = entry

## 0xd84 / 0xdca: every used edge's remaining rows (+0x22) shifted by n - the row count (rebase
## for a band) or back.
func rebase_edge_rows_for_band(n: int) -> void:
	_shift_edge_rows(C68kScript.s16(n), -1)

func restore_edge_rows_after_band(n: int) -> void:
	_shift_edge_rows(-C68kScript.s16(n), 1)

func _shift_edge_rows(delta: int, rows_sign: int) -> void:
	var e: int = memory.read_u32(_l(A5_POOL) + 0x8a0)
	while C68kScript.u32(e) < memory.read_u32(_l(A5_POOL) + 0x8a4):
		var rows: int = memory.read_u16(_l(A5_ROWS) + 0xe)
		memory.write_u16(e + 0x22, C68kScript.u16(memory.read_u16(e + 0x22) + delta + rows_sign * rows))
		e = C68kScript.u32(e + 0x28)
