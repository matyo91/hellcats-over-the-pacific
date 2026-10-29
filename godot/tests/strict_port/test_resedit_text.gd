extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Files := preload("res://strict_port/ui/resource_files.gd")
const Text := preload("res://strict_port/ui/resource_text.gd")

## The imported menu, string and information resources (godot/strict_port/menu, str#, text, styl,
## vers, size): each decodes from its bytes as the resource evidence says
## (fixtures/resedit_text.json, written by tools/strict_port/import_resedit.py), and every scene
## draws it: the Edit menu dimmed as its enable flags say, the File menu's command keys, the
## 120 strings of STR# 129, TEXT 1000 in its styl run's size, TEXT 128 (binary longs) in hex.
func run() -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/strict_port/fixtures/resedit_text.json"))
	var mismatches: Array = []
	for c in fixture["cases"]:
		var bytes: PackedByteArray = Files.load_bytes(c["type"], int(c["id"]))
		var got := {}
		match String(c["type"]):
			"MENU":
				var m: Dictionary = Text.decode_menu(bytes)
				got = {"menu_id": m["menu_id"], "flags": m["flags"], "title": m["title"],
						"items": m["items"].map(func(i): return [i["text"], i["icon"], i["key"], i["mark"], i["style"]])}
			"STR#":
				got = {"strings": Text.decode_strlist(bytes)}
			"TEXT":
				got = {"text": Text.decode_text(bytes)}
			"styl":
				got = {"runs": Text.decode_styl(bytes).map(func(r): return [r["start"], r["line_height"], r["ascent"], r["font_id"], r["face"], r["size"], r["rgb16"]])}
			"vers":
				var v: Dictionary = Text.decode_vers(bytes)
				got = {"fields": [v["major"], v["minor"], v["bugfix"], v["stage"], v["non_release"], v["region"], v["short"], v["long"]]}
			"SIZE":
				var z: Dictionary = Text.decode_size(bytes)
				got = {"flags": z["flags"], "set_flags": z["set_flags"], "preferred": z["preferred"], "minimum": z["minimum"]}
		var want: Dictionary = c.duplicate()
		want.erase("type")
		want.erase("id")
		if JSON.stringify(got, "", true) != JSON.stringify(_ints(want), "", true):
			mismatches.append("%s %d" % [c["type"], c["id"]])
	ok = Assertions.assert_equal(mismatches, [], "menus, strings and information resources decode as the evidence (%d)" % fixture["cases"].size()) and ok
	var empty: Array = []
	var scenes := 0
	for type_name in ["MENU", "STR#", "TEXT", "styl", "vers", "SIZE"]:
		for path in DirAccess.get_files_at(Files.folder(type_name)):
			if path.ends_with(".tscn"):
				var view = (load(Files.folder(type_name) + "/" + path) as PackedScene).instantiate()
				scenes += 1
				if view.build_display_list().size() < 3:
					empty.append(type_name + "/" + path)
				view.free()
	ok = Assertions.assert_equal(empty, [], "every menu and text scene draws its resource (%d scenes)" % scenes) and ok
	var edit: Array = _texts("MENU", 3)
	ok = Assertions.assert_equal(edit.filter(func(op): return op["color"] == Color.BLACK).map(func(op): return op["text"]), [],
			"MENU 3 (Edit, enable flags 0) is drawn dimmed") and ok
	var file: Array = _texts("MENU", 2).map(func(op): return op["text"])
	ok = Assertions.assert_true(file.has("Open…") and file.has("⌘O"), "MENU 2 shows Open… with ⌘O") and ok
	ok = Assertions.assert_equal(_texts("STR#", 129).filter(func(op): return String(op["text"]).ends_with(")") and String(op["text"]).trim_suffix(")").is_valid_int()).size(), 120,
			"STR# 129 lists its 120 strings") and ok
	var text: Array = _texts("TEXT", 1000)
	ok = Assertions.assert_true(text.size() >= 7 and text.all(func(op): return op.get("size", 12) == 10), "TEXT 1000 is drawn in styl 1000's 10-point run") and ok
	ok = Assertions.assert_true(_texts("TEXT", 128).any(func(op): return op["text"] == "0000 069B 0E72 33A6 "), "TEXT 128 is shown in hex") and ok
	return ok

func _texts(type_name: String, id: int) -> Array:
	var view = (load(Files.folder(type_name) + "/%d.tscn" % id) as PackedScene).instantiate()
	var out: Array = view.build_display_list().filter(func(op): return op["op"] == "text").map(func(op):
		var o: Dictionary = op.duplicate()
		o["color"] = op.get("color", Color.BLACK)
		return o)
	view.free()
	return out

func _ints(v: Variant) -> Variant:
	if v is Dictionary:
		var out := {}
		for k in v:
			out[k] = _ints(v[k])
		return out
	if v is Array:
		return v.map(func(x): return _ints(x))
	if v is float and v == floorf(v):
		return int(v)
	return v
