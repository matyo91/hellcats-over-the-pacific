extends RefCounted

## The imported resource fork: byte-identical copies of sources/resedit-1-0-3/<TYPE>/<id>.bin
## (and the media already derived next to them) in godot/strict_port/<type>/, beside code/, under
## the same file names, each folder its source folder's name lower-cased (ALRT -> alrt, ICN# ->
## icn#, icI4 -> ici4; tools/strict_port/import_resedit.py keeps them in sync and checks them).
## Callers name a type by its source folder ("ALRT", "ICN#", "icI4"); folder() makes the path.

const ROOT := "res://strict_port"

## Mac OS Roman bytes 0x80..0xff as code points (Python's mac_roman, as tools/resedit.py decodes).
const MAC_ROMAN_HIGH: Array[int] = [
	0x00c4, 0x00c5, 0x00c7, 0x00c9, 0x00d1, 0x00d6, 0x00dc, 0x00e1, 0x00e0, 0x00e2, 0x00e4, 0x00e3,
	0x00e5, 0x00e7, 0x00e9, 0x00e8, 0x00ea, 0x00eb, 0x00ed, 0x00ec, 0x00ee, 0x00ef, 0x00f1, 0x00f3,
	0x00f2, 0x00f4, 0x00f6, 0x00f5, 0x00fa, 0x00f9, 0x00fb, 0x00fc, 0x2020, 0x00b0, 0x00a2, 0x00a3,
	0x00a7, 0x2022, 0x00b6, 0x00df, 0x00ae, 0x00a9, 0x2122, 0x00b4, 0x00a8, 0x2260, 0x00c6, 0x00d8,
	0x221e, 0x00b1, 0x2264, 0x2265, 0x00a5, 0x00b5, 0x2202, 0x2211, 0x220f, 0x03c0, 0x222b, 0x00aa,
	0x00ba, 0x03a9, 0x00e6, 0x00f8, 0x00bf, 0x00a1, 0x00ac, 0x221a, 0x0192, 0x2248, 0x2206, 0x00ab,
	0x00bb, 0x2026, 0x00a0, 0x00c0, 0x00c3, 0x00d5, 0x0152, 0x0153, 0x2013, 0x2014, 0x201c, 0x201d,
	0x2018, 0x2019, 0x00f7, 0x25ca, 0x00ff, 0x0178, 0x2044, 0x20ac, 0x2039, 0x203a, 0xfb01, 0xfb02,
	0x2021, 0x00b7, 0x201a, 0x201e, 0x2030, 0x00c2, 0x00ca, 0x00c1, 0x00cb, 0x00c8, 0x00cd, 0x00ce,
	0x00cf, 0x00cc, 0x00d3, 0x00d4, 0xf8ff, 0x00d2, 0x00da, 0x00db, 0x00d9, 0x0131, 0x02c6, 0x02dc,
	0x00af, 0x02d8, 0x02d9, 0x02da, 0x00b8, 0x02dd, 0x02db, 0x02c7]

static func folder(type_name: String) -> String:
	return "%s/%s" % [ROOT, type_name.to_lower()]

static func path(type_name: String, id: int, extension: String = "bin") -> String:
	return "%s/%d.%s" % [folder(type_name), id, extension]

static func exists(type_name: String, id: int, extension: String = "bin") -> bool:
	return FileAccess.file_exists(path(type_name, id, extension))

## The resource's original bytes (empty when it is not in the file).
static func load_bytes(type_name: String, id: int) -> PackedByteArray:
	if not exists(type_name, id):
		return PackedByteArray()
	return FileAccess.get_file_as_bytes(path(type_name, id))

## A media file derived next to the resource (the PICT / cicn PNGs), as a texture.
static func load_png(type_name: String, id: int) -> Texture2D:
	if not exists(type_name, id, "png"):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path(type_name, id, "png"))) != OK:
		return null
	return ImageTexture.create_from_image(image)

static func u8(b: PackedByteArray, at: int) -> int:
	return b[at]

static func u16(b: PackedByteArray, at: int) -> int:
	return (b[at] << 8) | b[at + 1]

static func s16(b: PackedByteArray, at: int) -> int:
	var v: int = u16(b, at)
	return v - 0x10000 if v >= 0x8000 else v

static func u32(b: PackedByteArray, at: int) -> int:
	return (u16(b, at) << 16) | u16(b, at + 2)

## A QuickDraw Rect (top, left, bottom, right words) as a Rect2i in global coordinates.
static func rect(b: PackedByteArray, at: int) -> Rect2i:
	var top: int = s16(b, at)
	var left: int = s16(b, at + 2)
	return Rect2i(left, top, s16(b, at + 6) - left, s16(b, at + 4) - top)

## Mac OS Roman bytes as a String (CR kept as \r, as the Dialog Manager breaks lines on it).
static func mac_roman(b: PackedByteArray, at: int, count: int) -> String:
	var out := ""
	for k in count:
		var c: int = b[at + k]
		out += String.chr(c if c < 0x80 else MAC_ROMAN_HIGH[c - 0x80])
	return out

## A Pascal string (length byte first) at `at`: [text, the offset after it].
static func pstring(b: PackedByteArray, at: int) -> Array:
	var n: int = b[at]
	return [mac_roman(b, at + 1, n), at + 1 + n]
