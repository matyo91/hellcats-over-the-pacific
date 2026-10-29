@tool
extends "res://strict_port/ui/resource_canvas.gd"

## The Finder bundle resources shown as ResEdit's BNDL editor shows them, from their own bytes:
## the signature, then one row per file reference (its file type and the icon family it names:
## ICN#, icl4, icl8, ics#, ics4, ics8 at actual size). A 'FREF' scene shows its own row, found
## through the bundle that lists it.

const Files := preload("res://strict_port/ui/resource_files.gd")
const Images := preload("res://strict_port/ui/resource_images.gd")

const FAMILY := ["ICN#", "icI4", "icI8", "ics#", "ics4", "ics8"]
const ROW := 44

## The decoded bundle and the rows shown (the tests read them).
var bundle: Dictionary = {}
var rows: Array = []

## 'BNDL': the signature, its version word, then the type count - 1 and per type its four-character
## code, the mapping count - 1 and (local ID, resource ID) pairs.
static func decode_bndl(b: PackedByteArray) -> Dictionary:
	var types := {}
	var at: int = 8
	for t in Files.u16(b, 6) + 1:
		var code: String = Files.mac_roman(b, at, 4)
		var pairs := {}
		for k in Files.u16(b, at + 4) + 1:
			pairs[Files.s16(b, at + 6 + 4 * k)] = Files.s16(b, at + 8 + 4 * k)
		types[code] = pairs
		at += 6 + 4 * pairs.size()
	return {"signature": Files.mac_roman(b, 0, 4), "version": Files.u16(b, 4), "types": types, "consumed": at}

## 'FREF': the file type, the local icon ID, the file name (a Pascal string).
static func decode_fref(b: PackedByteArray) -> Dictionary:
	return {"file_type": Files.mac_roman(b, 0, 4), "local_icon_id": Files.s16(b, 4), "filename": Files.pstring(b, 6)[0]}

## The bundle that lists FREF `id` (the first one with it).
static func bundle_of_fref(id: int) -> Array:
	for path in DirAccess.get_files_at(Files.folder("BNDL")):
		if path.ends_with(".bin"):
			var bid: int = int(path.get_basename())
			var d: Dictionary = decode_bndl(Files.load_bytes("BNDL", bid))
			if (d["types"].get("FREF", {}) as Dictionary).values().has(id):
				return [bid, d]
	return [0, {}]

func build_display_list() -> Array:
	var out: Array = []
	rows = []
	var frefs: Array = []
	bundle = {}
	if not Files.exists(resource_type, resource_id):
		return out
	if resource_type == "BNDL":
		bundle = decode_bndl(Files.load_bytes("BNDL", resource_id))
		var locals: Array = (bundle["types"].get("FREF", {}) as Dictionary).keys()
		locals.sort()
		for local in locals:
			frefs.append(bundle["types"]["FREF"][local])
	else:
		bundle = bundle_of_fref(resource_id)[1]
		frefs.append(resource_id)
	if bundle.is_empty():
		return out
	var y: int = 16
	out.append({"op": "text", "pos": Vector2i(16, y + 12), "text": "Signature: %s     Version: %d" % [bundle["signature"], bundle["version"]]})
	y += 28
	out.append({"op": "text", "pos": Vector2i(16, y + 12), "text": "Type"})
	out.append({"op": "text", "pos": Vector2i(96, y + 12), "text": "Finder Icons"})
	y += 18
	out.append({"op": "line", "from": Vector2i(8, y), "to": Vector2i(440, y)})
	y += 6
	for fref_id in frefs:
		var fref: Dictionary = decode_fref(Files.load_bytes("FREF", fref_id))
		var icon_id: int = (bundle["types"].get("ICN#", {}) as Dictionary).get(fref["local_icon_id"], 0)
		var row := {"fref": fref_id, "file_type": fref["file_type"], "icon_id": icon_id, "icons": []}
		out.append({"op": "text", "pos": Vector2i(16, y + 26), "text": fref["file_type"]})
		var x: int = 96
		for family in FAMILY:
			if Files.exists(family, icon_id):
				var icon: Dictionary = Images.icon(family, Files.load_bytes(family, icon_id))
				var w: int = icon["width"]
				out.append({"op": "texture", "rect": Rect2i(x, y + (32 - w) / 2 + 4, w, w),
						"texture": ImageTexture.create_from_image(icon["image"]), "source": "%s:%d" % [family, icon_id]})
				row["icons"].append(family)
			x += 52
		if fref["filename"] != "":
			out.append({"op": "text", "pos": Vector2i(x + 8, y + 26), "text": fref["filename"]})
		rows.append(row)
		y += ROW
	custom_minimum_size = Vector2i(448, y + 8)
	size = custom_minimum_size
	out.push_front({"op": "frame", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "width": 1})
	out.push_front({"op": "fill", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "color": Color.WHITE})
	return out
