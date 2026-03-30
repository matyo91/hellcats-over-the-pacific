extends SceneTree

const FIXTURE_PATH := "res://hellcats/tests/fixtures/proven_loader_targets.json"
const SimCoreScript := preload("res://hellcats/core/sim_core.gd")
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
	var sim = SimCoreScript.new(0x1234)
	sim.load_loader_metadata_from_file(FIXTURE_PATH)

	if sim.get_loader_target_count() != EXPECTED_TARGETS.size():
		print("FAIL loader target count got %d want %d" % [sim.get_loader_target_count(), EXPECTED_TARGETS.size()])
		ok = false
	else:
		print("PASS loader target count")

	for expected in EXPECTED_TARGETS:
		var label: String = expected["label"]
		var by_tail: Dictionary = sim.resolve_loader_target(expected["segment_id"], expected["stored_tail"])
		if by_tail.is_empty() or int(by_tail.get("entrypoint_offset", -1)) != expected["entrypoint_offset"]:
			print("FAIL sim loader bridge %s" % label)
			ok = false
		else:
			print("PASS sim loader bridge %s" % label)

		var by_id00: Dictionary = sim.resolve_loader_target_by_id00_entry_offset(expected["id00_entry_offset"])
		if by_id00.is_empty() or int(by_id00.get("entrypoint_offset", -1)) != expected["entrypoint_offset"]:
			print("FAIL sim resolve_loader_target_by_id00_entry_offset(%d) %s" % [expected["id00_entry_offset"], label])
			ok = false
		else:
			print("PASS sim resolve_loader_target_by_id00_entry_offset(%d) %s" % [expected["id00_entry_offset"], label])

	sim.tick()
	if sim.get_tick_count() != 1:
		print("FAIL sim tick after loader metadata")
		ok = false
	else:
		print("PASS sim tick after loader metadata")

	quit(0 if ok else 1)
