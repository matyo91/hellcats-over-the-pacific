extends RefCounted

## The Dialog Manager's templates decoded from the resource bytes, field for field as Inside
## Macintosh lays them out (AlertTemplate, DialogTemplate, the item list), and 'ICON' bitmaps.

const Files := preload("res://strict_port/ui/resource_files.gd")

## Item type codes (the type byte without its disabled bit 0x80).
const USER_ITEM := 0
const BUTTON := 4
const CHECKBOX := 5
const RADIO_BUTTON := 6
const RESOURCE_CONTROL := 7
const STATIC_TEXT := 8
const EDIT_TEXT := 16
const ICON_ITEM := 32
const PICTURE_ITEM := 64

## 'ALRT': bounds, the item list's ID and the four stages (stage 1 in the low nibble: bit 3 the bold
## item, 2 the outline drawn, 0..1 the sound).
static func decode_alrt(b: PackedByteArray) -> Dictionary:
	assert(b.size() == 12, "ALRT is 12 bytes")
	var word: int = Files.u16(b, 10)
	return {"bounds": Files.rect(b, 0), "ditl_id": Files.s16(b, 8), "stage_word": word,
			"stages": [word & 15, (word >> 4) & 15, (word >> 8) & 15, (word >> 12) & 15]}

## 'DLOG': bounds, window definition procID, visible, goAwayFlag, refCon, item list ID, title.
static func decode_dlog(b: PackedByteArray) -> Dictionary:
	assert(b.size() >= 21, "DLOG holds its fixed fields and a title")
	var title: Array = Files.pstring(b, 20)
	return {"bounds": Files.rect(b, 0), "proc_id": Files.u16(b, 8), "visible": b[10] != 0, "go_away": b[12] != 0,
			"refcon": Files.u32(b, 14), "ditl_id": Files.s16(b, 18), "title": title[0], "consumed": title[1]}

## 'DITL': count - 1, then per item a reserved long, its rect, the type byte, the data length and
## the data (padded to a word). An item cut short by the end of the resource is left out and
## counted in "truncated".
static func decode_ditl(b: PackedByteArray) -> Dictionary:
	var count: int = Files.u16(b, 0) + 1
	var at: int = 2
	var items: Array = []
	var truncated: int = 0
	for index in range(1, count + 1):
		if at + 14 > b.size():
			truncated = count - index + 1
			break
		var type_byte: int = b[at + 12]
		var length: int = b[at + 13]
		var data: PackedByteArray = b.slice(at + 14, at + 14 + length)
		var kind: int = type_byte & 0x7f
		var item := {"index": index, "bounds": Files.rect(b, at + 4), "type": kind, "enabled": (type_byte & 0x80) == 0,
				"data": data}
		if kind in [BUTTON, CHECKBOX, RADIO_BUTTON, STATIC_TEXT, EDIT_TEXT]:
			item["text"] = Files.mac_roman(data, 0, length)
		elif kind in [ICON_ITEM, PICTURE_ITEM, RESOURCE_CONTROL] and length == 2:
			item["resource_id"] = Files.s16(data, 0)
		items.append(item)
		at += 14 + length
		at += at & 1
	return {"count": count, "items": items, "truncated": truncated, "consumed": at}

## 'CNTL': bounds, value, visible (a byte and its pad), max, min, procID, refCon, title.
static func decode_cntl(b: PackedByteArray) -> Dictionary:
	assert(b.size() >= 23, "CNTL holds its fixed fields and a title")
	var title: Array = Files.pstring(b, 22)
	return {"bounds": Files.rect(b, 0), "value": Files.s16(b, 8), "visible": b[10] != 0, "max": Files.s16(b, 12),
			"min": Files.s16(b, 14), "proc_id": Files.u16(b, 16), "refcon": Files.u32(b, 18), "title": title[0],
			"consumed": title[1]}

## A 32 x 32 one-bit 'ICON' (rows of four bytes, bit 7 leftmost, set = black) as an image.
static func icon_image(b: PackedByteArray) -> Image:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in 32:
		for x in 32:
			var on: bool = (b[y * 4 + (x >> 3)] >> (7 - (x & 7))) & 1 == 1
			image.set_pixel(x, y, Color.BLACK if on else Color.WHITE)
	return image
