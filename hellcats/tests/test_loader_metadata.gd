extends SceneTree

const LoaderMetadataScript := preload("res://hellcats/core/loader_metadata.gd")
const FIXTURE_PATH := "res://hellcats/tests/fixtures/proven_loader_targets.json"
const EXPECTED_TARGETS := [
	{"segment_id": 2, "stored_tail": 0x199e, "entrypoint_offset": 0x19a2, "id00_entry_offset": 770, "label": "ID02"},
	{"segment_id": 5, "stored_tail": 0x0000, "entrypoint_offset": 0x0006, "id00_entry_offset": 1362, "label": "ID05"},
	{"segment_id": 6, "stored_tail": 0x0e0c, "entrypoint_offset": 0x0e10, "id00_entry_offset": 386, "label": "ID06/0e10"},
	{"segment_id": 6, "stored_tail": 0x096a, "entrypoint_offset": 0x096e, "id00_entry_offset": 418, "label": "ID06/096e"},
	{"segment_id": 6, "stored_tail": 0x09d4, "entrypoint_offset": 0x09d8, "id00_entry_offset": 426, "label": "ID06/09d8"},
	{"segment_id": 7, "stored_tail": 0x018c, "entrypoint_offset": 0x0190, "id00_entry_offset": 1402, "label": "ID07"},
]

func _init() -> void:
	var ok := true
	var text := FileAccess.get_file_as_string(FIXTURE_PATH)
	if text.is_empty():
		print("FAIL fixture load")
		quit(1)
		return

	var metadata: RefCounted = LoaderMetadataScript.from_json_text(text)
	if metadata.targets.size() != EXPECTED_TARGETS.size():
		print("FAIL target count got %d want %d" % [metadata.targets.size(), EXPECTED_TARGETS.size()])
		ok = false

	for expected in EXPECTED_TARGETS:
		var label: String = expected["label"]
		var by_tail: Dictionary = metadata.get_target(expected["segment_id"], expected["stored_tail"])
		if by_tail.is_empty() or int(by_tail.get("entrypoint_offset", -1)) != expected["entrypoint_offset"]:
			print("FAIL %s target decode" % label)
			ok = false
		else:
			print("PASS %s target decode" % label)

		# Resolve by id00_entry_offset (proven field; LOADER_CHAIN §5 JSR offset(A5)).
		var by_id00: Dictionary = metadata.get_target_by_id00_entry_offset(expected["id00_entry_offset"])
		if by_id00.is_empty() or int(by_id00.get("segment_id", -1)) != expected["segment_id"] or int(by_id00.get("entrypoint_offset", -1)) != expected["entrypoint_offset"]:
			print("FAIL get_target_by_id00_entry_offset(%d) %s" % [expected["id00_entry_offset"], label])
			ok = false
		else:
			print("PASS get_target_by_id00_entry_offset(%d) %s" % [expected["id00_entry_offset"], label])

		if by_id00 != by_tail:
			print("FAIL id00 lookup must match segment+stored_tail lookup for %s" % label)
			ok = false
		else:
			print("PASS id00 lookup matches segment+stored_tail for %s" % label)

	print("Result: %s" % ("ALL PASS" if ok else "SOME FAIL"))
	quit(0 if ok else 1)
