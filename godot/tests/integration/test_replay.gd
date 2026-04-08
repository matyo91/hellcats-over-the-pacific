extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")
const ReplayRunnerScript := preload("res://hellcats/core/replay_runner.gd")
const FIXTURE_PATH := "res://godot/tests/fixtures/replay_inputs.json"
const TRACE_A_PATH := "user://trace_replay_a.jsonl"
const TRACE_B_PATH := "user://trace_replay_b.jsonl"

func run() -> bool:
	var ok := true
	ok = _run_once(TRACE_A_PATH) and ok
	ok = _run_once(TRACE_B_PATH) and ok

	var trace_a := FileAccess.get_file_as_string(TRACE_A_PATH)
	var trace_b := FileAccess.get_file_as_string(TRACE_B_PATH)
	ok = Assertions.assert_true(trace_a == trace_b, "replay trace parity") and ok
	return ok

func _run_once(trace_path: String) -> bool:
	var runner := ReplayRunnerScript.new(0x1234, FIXTURE_PATH, trace_path)
	var frames := runner.run()
	return Assertions.assert_equal(frames, 4, "replay frame count for %s" % trace_path)
