class_name LoaderMetadata
extends RefCounted

const TARGETS_KEY := "targets"
const NOTES_KEY := "notes"

var notes: Array = []
var targets: Array = []

static func from_json_text(text: String):
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("LoaderMetadata: invalid JSON")
		return new()

	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("LoaderMetadata: root must be a dictionary")
		return new()

	var metadata := new()
	metadata.notes = (data.get(NOTES_KEY, []) as Array).duplicate()
	metadata.targets = (data.get(TARGETS_KEY, []) as Array).duplicate()
	return metadata

static func from_file(path: String):
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("LoaderMetadata: could not read %s" % path)
		return new()
	return from_json_text(text)

func get_target(segment_id: int, stored_tail: int) -> Dictionary:
	for target in targets:
		if int(target.get("segment_id", -1)) == segment_id and int(target.get("stored_tail", -1)) == stored_tail:
			return (target as Dictionary).duplicate()
	return {}

## Resolve target by ID00 jump-table entry offset (A5-relative offset from loader chain).
## Proven: LOADER_CHAIN §5 "JSR offset(A5)"; id00_entry_offset in proven_loader_targets.json.
func get_target_by_id00_entry_offset(id00_entry_offset: int) -> Dictionary:
	for target in targets:
		if int(target.get("id00_entry_offset", -1)) == id00_entry_offset:
			return (target as Dictionary).duplicate()
	return {}

func get_target_count() -> int:
	return targets.size()
