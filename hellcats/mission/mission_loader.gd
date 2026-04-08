class_name MissionLoader
extends RefCounted

func load_bundle(mission_path: String, aircraft_path: String) -> Dictionary:
	var mission := _load_json(mission_path)
	var aircraft := _load_json(aircraft_path)
	var checkpoint_file := String(mission.get("checkpoint_ref", ""))
	var checkpoints: Dictionary = {"checkpoints": []}
	if not checkpoint_file.is_empty():
		var base_dir := mission_path.get_base_dir()
		checkpoints = _load_json(base_dir.path_join(checkpoint_file))
	return {
		"mission": mission,
		"aircraft": aircraft,
		"checkpoints": checkpoints,
	}

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open JSON: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null or not (parsed is Dictionary):
		push_error("Invalid JSON object at: %s" % path)
		return {}
	return parsed
