class_name ReplayRunner
extends RefCounted
## Loads input packets from JSON, runs sim with fixed seed, produces identical trace (for parity validation).
## Acceptance: same seed + same inputs => identical trace (see docs/TRACE.md).

const SimCoreScript := preload("res://hellcats/core/sim_core.gd")
const TraceWriterScript := preload("res://hellcats/core/trace_writer.gd")

var _sim: RefCounted
var _trace_writer: RefCounted
var _inputs: Array = []  # array of input packets (Dictionary per frame)

func _init(initial_seed: int, replay_path: String, trace_out_path: String) -> void:
	_sim = SimCoreScript.new(initial_seed)
	_sim.trace_enabled = true
	_trace_writer = TraceWriterScript.new(trace_out_path)
	_load_replay(replay_path)

func _load_replay(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("ReplayRunner: file not found: " + path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("ReplayRunner: cannot open: " + path)
		return
	var text := f.get_as_text()
	f.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("ReplayRunner: invalid JSON: " + path)
		return
	var data = json.get_data()
	if typeof(data) != TYPE_ARRAY:
		push_error("ReplayRunner: replay file must be a JSON array of input packets")
		return
	_inputs.clear()
	for p in data:
		_inputs.append(p)

## Run N frames (or all if max_frames <= 0). Returns number of frames run.
func run(max_frames: int = 0) -> int:
	if not _trace_writer.open():
		return 0
	var n := _inputs.size() if max_frames <= 0 else mini(max_frames, _inputs.size())
	for i in n:
		var packet: Dictionary = _inputs[i] if i < _inputs.size() else {}
		_sim.input_packet.clear()
		for k in packet:
			_sim.input_packet[k] = int(packet[k])
		_sim.tick()
		_trace_writer.write_frame(_sim)
	_trace_writer.close()
	return n

## Sim (read-only) for inspection after run.
func get_sim() -> RefCounted:
	return _sim
