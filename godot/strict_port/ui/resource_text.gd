extends RefCounted

## The menu, string and text resources decoded from their bytes as the Toolbox reads them:
## 'MENU' (MenuInfo and its item list), 'STR#', 'TEXT', 'styl' (TextEdit style runs), 'vers' and
## 'SIZE'.

const Files := preload("res://strict_port/ui/resource_files.gd")

## The SIZE flags from bit 15 down, named as tools/resedit.py names them.
const SIZE_FLAGS: Array = ["save_screen", "accept_suspend_resume_events", "disable_option", "can_background",
		"multi_finder_aware", "background_only", "dont_get_front_click", "ignore_child_died_events",
		"is_32_bit_compatible", "high_level_event_aware", "local_and_remote_high_level_events", "stationery_aware",
		"use_text_edit_services", "reserved_0x0004", "reserved_0x0002", "reserved_0x0001"]

## 'MENU': menuID, width, height, the MDEF's ID, the enable flags (bit 0 the whole menu, bit n item n),
## the title, then per item its text and four bytes (icon, key, mark or submenu, style) up to a
## zero length.
static func decode_menu(b: PackedByteArray) -> Dictionary:
	var title: Array = Files.pstring(b, 14)
	var at: int = title[1]
	var flags: int = Files.u32(b, 10)
	var items: Array = []
	while at < b.size() and b[at] != 0:
		var text: Array = Files.pstring(b, at)
		var e: int = text[1]
		var index: int = items.size() + 1
		items.append({"index": index, "text": text[0], "icon": b[e], "key": b[e + 1], "mark": b[e + 2], "style": b[e + 3],
				"enabled": index > 31 or (flags & (1 << index)) != 0})
		at = e + 4
	return {"menu_id": Files.s16(b, 0), "width": Files.s16(b, 2), "height": Files.s16(b, 4), "mdef": Files.u32(b, 6),
			"flags": flags, "menu_enabled": (flags & 1) != 0, "title": title[0], "items": items, "consumed": at + 1}

## 'STR#': a count, then that many Pascal strings.
static func decode_strlist(b: PackedByteArray) -> Array:
	var out: Array = []
	var at: int = 2
	for k in Files.u16(b, 0):
		var s: Array = Files.pstring(b, at)
		out.append(s[0])
		at = s[1]
	return out

## 'TEXT': the bytes as Mac OS Roman text (lines end with CR).
static func decode_text(b: PackedByteArray) -> String:
	return Files.mac_roman(b, 0, b.size())

## Whether a 'TEXT' holds text, rather than binary words (any control byte but CR and tab).
static func is_text(b: PackedByteArray) -> bool:
	for c in b:
		if c < 0x20 and c != 0x0d and c != 0x09:
			return false
	return true

## 'styl': a run count, then per run (20 bytes) its first character, line height, ascent, font ID,
## face byte, size and colour.
static func decode_styl(b: PackedByteArray) -> Array:
	var runs: Array = []
	for k in Files.u16(b, 0):
		var o: int = 2 + 20 * k
		runs.append({"start": Files.u32(b, o), "line_height": Files.u16(b, o + 4), "ascent": Files.u16(b, o + 6),
				"font_id": Files.u16(b, o + 8), "face": b[o + 10], "size": Files.u16(b, o + 12),
				"rgb16": [Files.u16(b, o + 14), Files.u16(b, o + 16), Files.u16(b, o + 18)]})
	return runs

## 'vers': the BCD version (major, minor.bugfix nibbles), stage, non-release revision, region code,
## then the short and long strings.
static func decode_vers(b: PackedByteArray) -> Dictionary:
	var short: Array = Files.pstring(b, 6)
	var long: Array = Files.pstring(b, short[1])
	var stages := {0x20: "development", 0x40: "alpha", 0x60: "beta", 0x80: "final"}
	return {"major": b[0], "minor": b[1] >> 4, "bugfix": b[1] & 15, "stage": stages.get(b[2], "unknown"), "stage_code": b[2],
			"non_release": b[3], "region": Files.u16(b, 4), "short": short[0], "long": long[0]}

## 'SIZE': the flags word, the preferred and minimum partition sizes.
static func decode_size(b: PackedByteArray) -> Dictionary:
	var flags: int = Files.u16(b, 0)
	var set_flags: Array = []
	for k in 16:
		if (flags >> (15 - k)) & 1:
			set_flags.append(SIZE_FLAGS[k])
	return {"flags": flags, "set_flags": set_flags, "preferred": Files.u32(b, 2), "minimum": Files.u32(b, 6)}
