extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Files := preload("res://strict_port/ui/resource_files.gd")
const Sound := preload("res://strict_port/ui/resource_sound.gd")

## The derived PICT PNGs that are not their picture frame's size (frames 137 x 751 and 438 x 93).
const DERIVED_PNG_SIZES := {131: Vector2i(135, 749), 1000: Vector2i(425, 88)}

## The imported sounds, pictures and application data (godot/strict_port/snds, pict, data, drel,
## hel1, hell, mdpl, zero): every sound decodes as the resource evidence says
## (fixtures/resedit_media.json, written by tools/strict_port/import_resedit.py), down to the
## SHA-256 of its samples, and becomes a playable stream of that many samples at its rate; every
## PICT's picSize and version match and its derived PNG has the picture frame's size (but for the two
## derived PNGs a few pixels short of their frame, listed in DERIVED_PNG_SIZES); every data
## resource is the evidence's bytes and its scene lays all of them out in hex; every scene draws.
func run() -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/strict_port/fixtures/resedit_media.json"))
	var mismatches: Array = []
	for c in fixture["cases"]:
		var bytes: PackedByteArray = Files.load_bytes(c["type"], int(c["id"]))
		var got := {}
		var want: Dictionary = c.duplicate()
		match String(c["type"]):
			"snds":
				var s: Dictionary = Sound.decode_snd(bytes)
				var hash := HashingContext.new()
				hash.start(HashingContext.HASH_SHA256)
				hash.update(s["samples"])
				var wav: AudioStreamWAV = Sound.stream(s)
				got = {"length": s["length"], "rate_fixed": s["rate_fixed"], "loop": [s["loop_start"], s["loop_end"]],
						"base_note": s["base_note"], "synth": s["synth"], "samples_sha256": hash.finish().hex_encode(),
						"commands": s["commands"].map(func(k): return [k["command"], k["param1"], k["param2"]])}
				if wav.data.size() != s["length"] or wav.mix_rate != roundi(s["rate_hz"]):
					mismatches.append("snds %d stream" % c["id"])
			"PICT":
				var view = (load(Files.folder("PICT") + "/%d.tscn" % int(c["id"])) as PackedScene).instantiate()
				view.build_display_list()
				got = {"size": view.decoded["size"], "version": view.decoded["version"]}
				var expected_png: Vector2i = DERIVED_PNG_SIZES.get(int(c["id"]), (view.decoded["frame"] as Rect2i).size)
				if view.decoded.get("png_size", Vector2i.ZERO) != expected_png:
					mismatches.append("PICT %d frame %s png %s" % [c["id"], view.decoded["frame"], view.decoded.get("png_size")])
				view.free()
			_:
				var hash := HashingContext.new()
				hash.start(HashingContext.HASH_SHA256)
				hash.update(bytes)
				got = {"bytes": bytes.size(), "sha256": hash.finish().hex_encode()}
				var view = (load(Files.folder(c["type"]) + "/%d.tscn" % int(c["id"])) as PackedScene).instantiate()
				var rows: int = view.build_display_list().filter(func(op): return op["op"] == "text" and String(op["text"]).length() == 6 and String(op["text"]).is_valid_hex_number()).size()
				view.free()
				if rows != (bytes.size() + 7) / 8:
					mismatches.append("%s %d: %d hex rows" % [c["type"], c["id"], rows])
		want.erase("type")
		want.erase("id")
		if JSON.stringify(got, "", true) != JSON.stringify(_ints(want), "", true):
			mismatches.append("%s %d: %s" % [c["type"], c["id"], JSON.stringify(got)])
	ok = Assertions.assert_equal(mismatches, [], "sounds, pictures and data match the evidence (%d resources)" % fixture["cases"].size()) and ok
	var empty: Array = []
	var scenes := 0
	for type_name in ["snds", "PICT", "DATA", "DREL", "HEL1", "HELL", "MDPL", "ZERO"]:
		for path in DirAccess.get_files_at(Files.folder(type_name)):
			if path.ends_with(".tscn"):
				var view = (load(Files.folder(type_name) + "/" + path) as PackedScene).instantiate()
				scenes += 1
				if view.build_display_list().size() < 3:
					empty.append(type_name + "/" + path)
				view.free()
	ok = Assertions.assert_equal(empty, [], "every sound, picture and data scene draws its resource (%d scenes)" % scenes) and ok
	return ok

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
