extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const LoaderMetadataScript := preload("res://hellcats/core/loader_metadata.gd")
const FIXTURE_PATH := "res://godot/tests/fixtures/proven_loader_targets.json"
const EXPECTED_TARGETS := [
	{"segment_id": 2, "stored_tail": 0x199e, "entrypoint_offset": 0x19a2, "id00_entry_offset": 770, "label": "ID02"},
	{"segment_id": 5, "stored_tail": 0x0000, "entrypoint_offset": 0x0006, "id00_entry_offset": 1362, "label": "ID05"},
	{"segment_id": 6, "stored_tail": 0x0e0c, "entrypoint_offset": 0x0e10, "id00_entry_offset": 386, "label": "ID06/0e10"},
	{"segment_id": 6, "stored_tail": 0x096a, "entrypoint_offset": 0x096e, "id00_entry_offset": 418, "label": "ID06/096e"},
	{"segment_id": 6, "stored_tail": 0x09d4, "entrypoint_offset": 0x09d8, "id00_entry_offset": 426, "label": "ID06/09d8"},
	{"segment_id": 7, "stored_tail": 0x018c, "entrypoint_offset": 0x0190, "id00_entry_offset": 1402, "label": "ID07"},
]

func run() -> bool:
	var ok := true
	var text := FileAccess.get_file_as_string(FIXTURE_PATH)
	if text.is_empty():
		print("FAIL fixture load %s" % FIXTURE_PATH)
		return false

	var metadata: RefCounted = LoaderMetadataScript.from_json_text(text)
	ok = Assertions.assert_equal(
		metadata.targets.size(),
		EXPECTED_TARGETS.size(),
		"loader metadata target count"
	) and ok

	for expected in EXPECTED_TARGETS:
		var label: String = expected["label"]
		var by_tail: Dictionary = metadata.get_target(expected["segment_id"], expected["stored_tail"])
		ok = Assertions.assert_equal(
			int(by_tail.get("entrypoint_offset", -1)),
			expected["entrypoint_offset"],
			"%s target decode" % label
		) and ok

		var by_id00: Dictionary = metadata.get_target_by_id00_entry_offset(expected["id00_entry_offset"])
		ok = Assertions.assert_equal(
			int(by_id00.get("segment_id", -1)),
			expected["segment_id"],
			"%s id00 segment_id" % label
		) and ok
		ok = Assertions.assert_equal(
			int(by_id00.get("entrypoint_offset", -1)),
			expected["entrypoint_offset"],
			"%s id00 entrypoint_offset" % label
		) and ok
		ok = Assertions.assert_true(
			by_id00 == by_tail,
			"%s id00 lookup matches segment+tail" % label
		) and ok

	return ok
