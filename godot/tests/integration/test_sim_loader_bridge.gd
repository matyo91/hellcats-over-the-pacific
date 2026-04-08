extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const SimCoreScript := preload("res://hellcats/core/sim_core.gd")
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
	var sim = SimCoreScript.new(0x1234)
	sim.load_loader_metadata_from_file(FIXTURE_PATH)

	ok = Assertions.assert_equal(
		sim.get_loader_target_count(),
		EXPECTED_TARGETS.size(),
		"sim loader target count"
	) and ok

	for expected in EXPECTED_TARGETS:
		var label: String = expected["label"]
		var by_tail: Dictionary = sim.resolve_loader_target(expected["segment_id"], expected["stored_tail"])
		ok = Assertions.assert_equal(
			int(by_tail.get("entrypoint_offset", -1)),
			expected["entrypoint_offset"],
			"sim loader bridge %s" % label
		) and ok

		var by_id00: Dictionary = sim.resolve_loader_target_by_id00_entry_offset(expected["id00_entry_offset"])
		ok = Assertions.assert_equal(
			int(by_id00.get("entrypoint_offset", -1)),
			expected["entrypoint_offset"],
			"sim id00 loader bridge %s" % label
		) and ok

	sim.tick()
	ok = Assertions.assert_equal(sim.get_tick_count(), 1, "sim tick after loader metadata") and ok
	return ok
