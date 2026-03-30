extends SceneTree

const FIXTURE_PATH := "res://hellcats/tests/fixtures/replay_inputs.json"
const TRACE_A_PATH := "user://trace_replay_a.jsonl"
const TRACE_B_PATH := "user://trace_replay_b.jsonl"
const ReplayRunnerScript := preload("res://hellcats/core/replay_runner.gd")

func _init() -> void:
	var ok := true
	ok = _run_once(TRACE_A_PATH) and ok
	ok = _run_once(TRACE_B_PATH) and ok
	var trace_a := FileAccess.get_file_as_string(TRACE_A_PATH)
	var trace_b := FileAccess.get_file_as_string(TRACE_B_PATH)
	if trace_a != trace_b:
		print("FAIL replay trace mismatch")
		ok = false
	else:
		print("PASS replay trace parity")
		print(trace_a.strip_edges())
	quit(0 if ok else 1)

func _run_once(trace_path: String) -> bool:
	var runner := ReplayRunnerScript.new(0x1234, FIXTURE_PATH, trace_path)
	var frames := runner.run()
	if frames != 4:
		print("FAIL replay frame count got %d want 4" % frames)
		return false
	return true
