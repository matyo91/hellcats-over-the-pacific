extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Templates := preload("res://strict_port/ui/dialog_templates.gd")
const Files := preload("res://strict_port/ui/resource_files.gd")

## The imported dialog resources (godot/strict_port/alrt, dlog, ditl): the GDScript
## decoder reads every original payload the way tools/resedit.py decodes it
## (fixtures/resedit_dialogs.json, written by tools/strict_port/import_resedit.py from the resource
## evidence), and every scene builds its drawing: the window, each item's text, its icon or
## picture, the alert's default-button outline.
func run() -> bool:
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/strict_port/fixtures/resedit_dialogs.json"))
	var mismatches: Array = []
	for c in fixture["cases"]:
		var type_name: String = c["type"]
		var id: int = int(c["id"])
		var bytes: PackedByteArray = Files.load_bytes(type_name, id)
		var got: Dictionary = {}
		match type_name:
			"ALRT":
				var t: Dictionary = Templates.decode_alrt(bytes)
				got = {"bounds": _rect(t["bounds"]), "ditl_id": t["ditl_id"], "stage_word": t["stage_word"]}
			"DLOG":
				var t: Dictionary = Templates.decode_dlog(bytes)
				got = {"bounds": _rect(t["bounds"]), "ditl_id": t["ditl_id"], "proc_id": t["proc_id"], "title": t["title"],
						"visible": t["visible"], "go_away": t["go_away"]}
			"DITL":
				var t: Dictionary = Templates.decode_ditl(bytes)
				var items: Array = []
				for item in t["items"]:
					var e := {"type": item["type"], "enabled": item["enabled"], "bounds": _rect(item["bounds"])}
					if item.has("text"):
						e["text"] = item["text"]
					if item.has("resource_id") and item["type"] != Templates.RESOURCE_CONTROL:
						e["resource_id"] = item["resource_id"]
					items.append(e)
				got = {"count": t["count"], "items": items}
		var want: Dictionary = c.duplicate()
		want.erase("type")
		want.erase("id")
		if JSON.stringify(_ints(got)) != JSON.stringify(_ints(want)):
			mismatches.append("%s %d" % [type_name, id])
	var ok: bool = Assertions.assert_equal(mismatches, [], "dialog templates decode as the resource evidence (%d resources)" % fixture["cases"].size())
	var empty: Array = []
	for type_name in ["ALRT", "DLOG", "DITL"]:
		for path in DirAccess.get_files_at(Files.folder(type_name)):
			if not path.ends_with(".tscn"):
				continue
			var view = (load(Files.folder(type_name) + "/" + path) as PackedScene).instantiate()
			var list: Array = view.build_display_list()
			var texts := 0
			for op in list:
				texts += 1 if op["op"] in ["text", "texture"] else 0
			if list.size() < 3 or (view.items.get("items", []).size() > 0 and texts == 0 and type_name != "DITL"):
				empty.append(path)
			view.free()
	ok = Assertions.assert_equal(empty, [], "every dialog scene draws its window and items") and ok
	var about = (load(Files.folder("DLOG") + "/127.tscn") as PackedScene).instantiate()
	var sources: Array = []
	for op in about.build_display_list():
		if op["op"] == "texture":
			sources.append(op["source"])
	about.free()
	ok = Assertions.assert_equal(sources, ["PICT:128"], "the About box draws its picture") and ok
	var alert = (load(Files.folder("ALRT") + "/256.tscn") as PackedScene).instantiate()
	var outlined := false
	var labels: Array = []
	for op in alert.build_display_list():
		outlined = outlined or (op["op"] == "round" and op["width"] == 3)
		if op["op"] == "text":
			labels.append(op["text"])
	alert.free()
	ok = Assertions.assert_true(outlined, "ALRT 256 outlines its default button") and ok
	ok = Assertions.assert_equal(labels, ["OK", "Unable to open Hellcats scenery", "file '^0'."], "ALRT 256 draws its texts") and ok
	return ok

func _rect(r: Rect2i) -> Array:
	return [r.position.x, r.position.y, r.size.x, r.size.y]

## JSON numbers come back as floats: compare everything as ints where they are whole.
func _ints(v: Variant) -> Variant:
	if v is Dictionary:
		var out := {}
		var keys: Array = v.keys()
		keys.sort()
		for k in keys:
			out[k] = _ints(v[k])
		return out
	if v is Array:
		return v.map(func(x): return _ints(x))
	if v is float and v == floorf(v):
		return int(v)
	return v
