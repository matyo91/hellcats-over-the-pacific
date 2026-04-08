class_name MissionObjectivesM1
extends RefCounted

var objectives: Array[Dictionary] = []
var _current_index: int = 0
var _hold_timer: float = 0.0
var _checkpoint_hits: Dictionary = {}

func configure(sequence: Array) -> void:
	objectives.clear()
	for item in sequence:
		objectives.append((item as Dictionary).duplicate(true))
	_current_index = 0
	_hold_timer = 0.0
	_checkpoint_hits.clear()

func notify_checkpoint(checkpoint_id: String) -> void:
	_checkpoint_hits[checkpoint_id] = true

func current_objective() -> Dictionary:
	if _current_index >= objectives.size():
		return {}
	return objectives[_current_index]

func current_label(prefix: String = "Objective") -> String:
	var objective := current_objective()
	if objective.is_empty():
		return "%s: Mission complete" % prefix
	return "%s: %s" % [prefix, String(objective.get("id", "unknown"))]

func step(snapshot: Dictionary, delta: float) -> Dictionary:
	var advanced := false
	var completed_id := ""
	if _current_index < objectives.size():
		var objective := objectives[_current_index]
		if _is_objective_complete(objective, snapshot, delta):
			completed_id = String(objective.get("id", ""))
			_current_index += 1
			_hold_timer = 0.0
			advanced = true
			while _current_index < objectives.size() and _is_optional_already_complete(objectives[_current_index], snapshot):
				_current_index += 1
	var required_complete := are_required_objectives_complete()
	return {
		"advanced": advanced,
		"completed_id": completed_id,
		"mission_complete": required_complete,
		"current_objective": current_objective(),
	}

func are_required_objectives_complete() -> bool:
	for index in range(objectives.size()):
		var objective := objectives[index]
		if bool(objective.get("optional", false)):
			continue
		if index >= _current_index:
			return false
	return true

func _is_optional_already_complete(objective: Dictionary, snapshot: Dictionary) -> bool:
	if not bool(objective.get("optional", false)):
		return false
	return _is_objective_complete(objective, snapshot, 0.0)

func _is_objective_complete(objective: Dictionary, snapshot: Dictionary, delta: float) -> bool:
	var objective_type := String(objective.get("type", ""))
	match objective_type:
		"hold_altitude":
			var altitude := float(snapshot.get("altitude_m", 0.0))
			var target := float(objective.get("target_altitude_m", altitude))
			var tolerance := float(objective.get("tolerance_m", 100.0))
			if absf(altitude - target) <= tolerance:
				_hold_timer += delta
			else:
				_hold_timer = 0.0
			return _hold_timer >= float(objective.get("hold_seconds", 1.0))
		"reach_bank":
			var bank := float(snapshot.get("bank_deg", 0.0))
			var min_bank := float(objective.get("min_bank_deg", 15.0))
			var direction := String(objective.get("direction", "left"))
			return bank <= -min_bank if direction == "left" else bank >= min_bank
		"reach_altitude":
			var altitude_now := float(snapshot.get("altitude_m", 0.0))
			if objective.has("min_altitude_m"):
				return altitude_now >= float(objective.get("min_altitude_m", altitude_now))
			if objective.has("max_altitude_m"):
				return altitude_now <= float(objective.get("max_altitude_m", altitude_now))
			return false
		"checkpoint_pass":
			return _checkpoint_hits.get(String(objective.get("checkpoint_id", "")), false)
		_:
			return false
