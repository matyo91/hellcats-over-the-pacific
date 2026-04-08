class_name CheckpointManager
extends Node3D

const CheckpointScene := preload("res://godot/scenes/mission/Checkpoint.tscn")

signal checkpoint_passed(checkpoint_id: String)

var checkpoints: Array = []

func configure(checkpoint_data: Dictionary) -> void:
	for child in get_children():
		child.queue_free()
	checkpoints.clear()
	for item in checkpoint_data.get("checkpoints", []):
		var checkpoint = CheckpointScene.instantiate()
		add_child(checkpoint)
		checkpoint.configure(item)
		checkpoint.checkpoint_passed.connect(_on_checkpoint_passed)
		checkpoints.append(checkpoint)

func check_player_position(world_position: Vector3) -> void:
	for checkpoint in checkpoints:
		if checkpoint.check_pass(world_position):
			return

## Next checkpoint for HUD compass / range ([MVP AUTHORING DECISION]).
func get_next_nav_checkpoint() -> MissionCheckpoint:
	var best: MissionCheckpoint = null
	var best_order: int = 999999
	for checkpoint in checkpoints:
		if checkpoint is MissionCheckpoint:
			var cp: MissionCheckpoint = checkpoint
			if cp.is_passed():
				continue
			if cp.order < best_order:
				best_order = cp.order
				best = cp
	return best

func _on_checkpoint_passed(checkpoint_id: String) -> void:
	checkpoint_passed.emit(checkpoint_id)
