extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Templates := preload("res://strict_port/ui/dialog_templates.gd")
const Files := preload("res://strict_port/ui/resource_files.gd")
const Images := preload("res://strict_port/ui/resource_images.gd")
const Finder := preload("res://strict_port/ui/finder_view.gd")

## The imported interface resources beyond the dialogs (godot/strict_port/cntl, bndl, fref and the
## icon families, cicn, clut): CNTL / BNDL / FREF decode as the resource evidence says
## (fixtures/resedit_interface.json, written by tools/strict_port/import_resedit.py); every icon
## decoded from its bytes matches the PNG derived next to it wherever that PNG is opaque (all but
## ics8: its derived PNGs do not follow the default 8-bit table, e.g. entry 245 comes out dark blue
## and 255 mid grey, while the icl8 PNGs follow it exactly); every cicn matches its PNG; and every
## scene of every imported folder draws something.
func run() -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/strict_port/fixtures/resedit_interface.json"))
	var mismatches: Array = []
	for c in fixture["cases"]:
		var bytes: PackedByteArray = Files.load_bytes(c["type"], int(c["id"]))
		var got: Dictionary = {}
		match String(c["type"]):
			"CNTL":
				got = Templates.decode_cntl(bytes)
				var r: Rect2i = got["bounds"]
				got["bounds"] = [r.position.x, r.position.y, r.size.x, r.size.y]
				got.erase("consumed")
			"BNDL":
				got = Finder.decode_bndl(bytes)
				got.erase("consumed")
				var types := {}
				for t in got["types"]:
					var pairs := {}
					for local in got["types"][t]:
						pairs[str(local)] = got["types"][t][local]
					types[t] = pairs
				got["types"] = types
			"FREF":
				got = Finder.decode_fref(bytes)
		var want: Dictionary = c.duplicate()
		want.erase("type")
		want.erase("id")
		if _canon(got) != _canon(want):
			mismatches.append("%s %d: %s" % [c["type"], c["id"], _canon(got)])
	ok = Assertions.assert_equal(mismatches, [], "CNTL, BNDL and FREF decode as the resource evidence") and ok
	var bad: Array = []
	var compared := 0
	for type_name in Images.ICON_TYPES:
		for id in _ids(type_name):
			var png: Image = _png(type_name, id)
			if png == null or type_name == "ics8":
				continue
			var bytes: PackedByteArray = Files.load_bytes(type_name, id)
			var image: Image = Images.icon(type_name, bytes)["image"]
			for y in image.get_height():
				for x in image.get_width():
					var p: Color = png.get_pixel(x, y)
					if p.a == 0.0:
						continue
					var want: Color = image.get_pixel(x, y)
					compared += 1
					if not _same(p, want):
						bad.append("%s %d (%d, %d)" % [type_name, id, x, y])
	ok = Assertions.assert_equal(bad.slice(0, 5), [], "icons match their derived PNGs (%d opaque pixels)" % compared) and ok
	var cicn_bad: Array = []
	for id in _ids("cicn"):
		var decoded: Dictionary = Images.cicn(Files.load_bytes("cicn", id))
		var png: Image = _png("cicn", id)
		for y in png.get_height():
			for x in png.get_width():
				if not _same(png.get_pixel(x, y), decoded["image"].get_pixel(x, y)):
					cicn_bad.append("cicn %d (%d, %d)" % [id, x, y])
	ok = Assertions.assert_equal(cicn_bad.slice(0, 5), [], "cicns match their derived PNGs (%d icons)" % _ids("cicn").size()) and ok
	var clut: Dictionary = Images.color_table(Files.load_bytes("clut", 999), 0)
	ok = Assertions.assert_equal([clut["count"], clut["seed"], clut["entries"][1]["rgb16"]], [16, 14721, [0, 65535, 65535]], "clut 999 decodes") and ok
	var empty: Array = []
	var scenes := 0
	for type_name in ["CNTL", "BNDL", "FREF", "ICON", "ICN#", "ics#", "icI4", "icI8", "ics4", "ics8", "cicn", "clut"]:
		for path in DirAccess.get_files_at(Files.folder(type_name)):
			if path.ends_with(".tscn"):
				var view = (load(Files.folder(type_name) + "/" + path) as PackedScene).instantiate()
				scenes += 1
				if view.build_display_list().size() < 3:
					empty.append(type_name + "/" + path)
				view.free()
	ok = Assertions.assert_equal(empty, [], "every interface scene draws its resource (%d scenes)" % scenes) and ok
	var bundle = (load(Files.folder("BNDL") + "/132.tscn") as PackedScene).instantiate()
	bundle.build_display_list()
	var rows: Array = bundle.rows.map(func(r): return [r["file_type"], r["icon_id"], r["icons"].size()])
	bundle.free()
	ok = Assertions.assert_equal(rows, [["APPL", 128, 6], ["HELL", 129, 6]], "BNDL 132 shows each file type with its six icons") and ok
	return ok

func _ids(type_name: String) -> Array:
	var out: Array = []
	for path in DirAccess.get_files_at(Files.folder(type_name)):
		if path.ends_with(".bin"):
			out.append(int(path.get_basename()))
	out.sort()
	return out

func _png(type_name: String, id: int) -> Image:
	if not Files.exists(type_name, id, "png"):
		return null
	var image := Image.new()
	image.load_png_from_buffer(FileAccess.get_file_as_bytes(Files.path(type_name, id, "png")))
	image.convert(Image.FORMAT_RGBA8)
	return image

func _same(a: Color, b: Color) -> bool:
	return a.r8 == b.r8 and a.g8 == b.g8 and a.b8 == b.b8

func _canon(v: Variant) -> String:
	if v is Dictionary:
		var keys: Array = v.keys()
		keys.sort()
		return "{" + ",".join(keys.map(func(k): return str(k) + ":" + _canon(v[k]))) + "}"
	if v is Array:
		return "[" + ",".join(v.map(func(x): return _canon(x))) + "]"
	if v is float and v == floorf(v):
		return str(int(v))
	return str(v)
