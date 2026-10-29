extends RefCounted

## The icon and colour resources decoded from their bytes: the one-bit families ('ICON', 'ICN#',
## 'ics#'), the indexed ones ('icl4' / 'icl8' / 'ics4' / 'ics8', in the folders icI4 / icI8 / ics4 /
## ics8) through the system's default colour tables, 'cicn' through its own table, and 'clut'.

const Files := preload("res://strict_port/ui/resource_files.gd")

## The default 4-bit colour table (clut 4), as 16-bit RGB.
const CLUT4: Array = [
	[0xffff, 0xffff, 0xffff], [0xfc00, 0xf37d, 0x052f], [0xffff, 0x648a, 0x028c], [0xdd6b, 0x08c2, 0x06a2],
	[0xf2d7, 0x0856, 0x84ec], [0x46e3, 0x0000, 0xa53e], [0x0000, 0x0000, 0xd400], [0x0241, 0xab54, 0xeaff],
	[0x1f21, 0xb793, 0x1431], [0x0000, 0x64af, 0x11b0], [0x5600, 0x2c9d, 0x0524], [0x90d7, 0x7160, 0x3a34],
	[0xc000, 0xc000, 0xc000], [0x8000, 0x8000, 0x8000], [0x4000, 0x4000, 0x4000], [0x0000, 0x0000, 0x0000]]

## The folders of the icon types and their geometry: [width, depth, embedded mask].
const ICON_TYPES: Dictionary = {"ICON": [32, 1, false], "ICN#": [32, 1, true], "ics#": [16, 1, true],
		"icI4": [32, 4, false], "icI8": [32, 8, false], "ics4": [16, 4, false], "ics8": [16, 8, false]}

## The default 8-bit colour table (clut 8): the 6 x 6 x 6 cube from white without black (0..214),
## ten-step red, green, blue and grey ramps (215..254), black (255).
static func clut8() -> Array:
	var out: Array = []
	var levels: Array = [0xff, 0xcc, 0x99, 0x66, 0x33, 0x00]
	for r in levels:
		for g in levels:
			for b in levels:
				out.append(Color8(r, g, b))
	out.resize(215)
	var ramp: Array = [0xee, 0xdd, 0xbb, 0xaa, 0x88, 0x77, 0x55, 0x44, 0x22, 0x11]
	for v in ramp:
		out.append(Color8(v, 0, 0))
	for v in ramp:
		out.append(Color8(0, v, 0))
	for v in ramp:
		out.append(Color8(0, 0, v))
	for v in ramp:
		out.append(Color8(v, v, v))
	out.append(Color8(0, 0, 0))
	return out

static func clut4() -> Array:
	return CLUT4.map(func(c): return Color8(c[0] >> 8, c[1] >> 8, c[2] >> 8))

## One-bit rows (row_bytes apart, bit 7 leftmost) at `at`: true where the bit is set.
static func bits(b: PackedByteArray, at: int, row_bytes: int, width: int, height: int) -> Array:
	var out: Array = []
	for y in height:
		var row: Array = []
		for x in width:
			row.append((b[at + y * row_bytes + (x >> 3)] >> (7 - (x & 7))) & 1 == 1)
		out.append(row)
	return out

## An icon type's pixels as an image: one-bit black on white, indexed through the default table.
## The mask (the '#' types' second half) is returned apart, as ResEdit shows it next to the icon.
static func icon(type_name: String, b: PackedByteArray) -> Dictionary:
	var spec: Array = ICON_TYPES[type_name]
	var w: int = spec[0]
	var depth: int = spec[1]
	var image := Image.create(w, w, false, Image.FORMAT_RGBA8)
	var palette: Array = clut4() if depth == 4 else clut8() if depth == 8 else []
	var one: Array = bits(b, 0, w / 8, w, w) if depth == 1 else []
	for y in w:
		for x in w:
			var i: int = y * w + x
			var c: Color
			if depth == 1:
				c = Color.BLACK if one[y][x] else Color.WHITE
			elif depth == 4:
				c = palette[(b[i >> 1] >> (4 * (1 - (i & 1)))) & 15]
			else:
				c = palette[b[i]]
			image.set_pixel(x, y, c)
	var out := {"image": image, "width": w, "depth": depth}
	if spec[2]:
		var mask := Image.create(w, w, false, Image.FORMAT_RGBA8)
		var m: Array = bits(b, w * w / 8, w / 8, w, w)
		for y in w:
			for x in w:
				mask.set_pixel(x, y, Color.BLACK if m[y][x] else Color.WHITE)
		out["mask"] = mask
	return out

## A ColorTable at `at`: seed, flags, then count entries of (value, red, green, blue) words.
static func color_table(b: PackedByteArray, at: int) -> Dictionary:
	var count: int = Files.s16(b, at + 6) + 1
	var entries: Array = []
	for k in count:
		var e: int = at + 8 + 8 * k
		entries.append({"value": Files.u16(b, e), "rgb16": [Files.u16(b, e + 2), Files.u16(b, e + 4), Files.u16(b, e + 6)],
				"color": Color8(b[e + 2], b[e + 4], b[e + 6])})
	return {"seed": Files.u32(b, at), "flags": Files.u16(b, at + 4), "count": count, "entries": entries,
			"end": at + 8 + 8 * count}

## A 'cicn': its PixMap (rowBytes & 0x3fff, bounds, pixelSize), the mask and one-bit BitMaps, then
## the mask data, the one-bit data, the colour table and the indexed pixels.
static func cicn(b: PackedByteArray) -> Dictionary:
	var row_bytes: int = Files.u16(b, 4) & 0x3fff
	var bounds: Rect2i = Files.rect(b, 6)
	var depth: int = Files.u16(b, 32)
	var mask_rb: int = Files.u16(b, 54)
	var bits_rb: int = Files.u16(b, 68)
	var h: int = bounds.size.y
	var w: int = bounds.size.x
	var mask_at: int = 82
	var bits_at: int = mask_at + mask_rb * h
	var table: Dictionary = color_table(b, bits_at + bits_rb * h)
	var lookup := {}
	for e in table["entries"]:
		lookup[e["value"]] = e["color"]
	var pixels_at: int = table["end"]
	var mask: Array = bits(b, mask_at, mask_rb, w, h)
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var shown := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var bit: int = x * depth
			var v: int = (b[pixels_at + y * row_bytes + (bit >> 3)] >> (8 - depth - (bit & 7))) & ((1 << depth) - 1)
			var c: Color = lookup.get(v, Color.BLACK)
			image.set_pixel(x, y, c)
			shown.set_pixel(x, y, c if mask[y][x] else Color(1, 1, 1, 0))
	return {"bounds": bounds, "depth": depth, "row_bytes": row_bytes, "table": table, "image": image, "masked": shown,
			"mask": mask}
