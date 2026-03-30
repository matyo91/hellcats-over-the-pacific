class_name TraceWriter
extends RefCounted
## Writes one JSONL line per sim tick (trace format per docs/TRACE.md).

var _file: FileAccess
var _path: String = ""

func _init(path: String = "") -> void:
	_path = path

## Open file for a fresh run (truncates existing content). Call before write_frame.
func open(path: String = "") -> bool:
	var p := path if path != "" else _path
	if p.is_empty():
		return false
	_file = FileAccess.open(p, FileAccess.WRITE_READ)
	return true

## Append one trace record as a single JSON line. Record must match TRACE.md (frame, input, rng_state, mission_phase_a8, mission_flag_ac, player).
func write_record(record: Dictionary) -> void:
	if _file == null:
		return
	var line := JSON.stringify(record)
	_file.store_line(line)

## Append the last trace record from sim (call after sim.tick() with trace_enabled).
func write_frame(sim: RefCounted) -> void:
	var rec = sim.get_last_trace_record()
	if rec != null:
		write_record(rec as Dictionary)

## Close the file. Safe to call if not open.
func close() -> void:
	if _file != null:
		_file.close()
		_file = null
