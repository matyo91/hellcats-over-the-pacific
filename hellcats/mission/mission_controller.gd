class_name MissionController
extends Node

const MissionLoaderScript := preload("res://hellcats/mission/mission_loader.gd")
const MissionObjectivesScript := preload("res://hellcats/mission/mission_objectives_m1.gd")
const PlayerInputMapScript := preload("res://hellcats/flight/player_input_map.gd")

@export_file("*.json") var mission_data_path := "res://godot/data/mission_01/mission_01_training.json"
@export_file("*.json") var aircraft_data_path := "res://godot/data/mission_01/aircraft_mvp.json"
@export var player_path: NodePath = ^"../PlayerAircraft"
@export var hud_path: NodePath = ^"../HUD"
@export var checkpoints_path: NodePath = ^"../Checkpoints"
@export var bounds_radius_m: float = 4200.0

var mission_bundle: Dictionary = {}
var mission_state: String = "boot"
var _mission_loader
var _objectives
var _player
var _hud
var _checkpoints

func _ready() -> void:
	PlayerInputMapScript.ensure_actions()
	_mission_loader = MissionLoaderScript.new()
	_objectives = MissionObjectivesScript.new()
	_player = get_node(player_path)
	_hud = get_node(hud_path)
	_checkpoints = get_node(checkpoints_path)
	_checkpoints.checkpoint_passed.connect(_on_checkpoint_passed)
	_player.crashed.connect(_on_player_crashed)
	_load_and_start()

func _physics_process(delta: float) -> void:
	if mission_state != "running":
		return
	var snapshot: Dictionary = _player.get_snapshot()
	_hud.update_telemetry(snapshot)
	_check_failure(snapshot, delta)
	if mission_state != "running":
		return
	_checkpoints.check_player_position(snapshot.get("position_m", Vector3.ZERO))
	var result: Dictionary = _objectives.step(snapshot, delta)
	if bool(result.get("advanced", false)):
		var current_objective: Dictionary = result.get("current_objective", {})
		if current_objective is Dictionary and not current_objective.is_empty():
			_hud.set_objective(_objective_prefix(), String(current_objective.get("id", "")))
	if bool(result.get("mission_complete", false)):
		_set_terminal_state("Mission success", true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mission_restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _load_and_start() -> void:
	mission_bundle = _mission_loader.load_bundle(mission_data_path, aircraft_data_path)
	var mission: Dictionary = mission_bundle.get("mission", {})
	var aircraft: Dictionary = mission_bundle.get("aircraft", {})
	var checkpoints: Dictionary = mission_bundle.get("checkpoints", {})
	_objectives.configure(mission.get("objective_sequence", []))
	_player.setup_mission(aircraft, mission)
	_checkpoints.configure(checkpoints)
	_hud.set_brief_title(String(mission.get("ui", {}).get("brief_title", "Flight School")))
	var first_objective: Dictionary = _objectives.current_objective()
	_hud.set_objective(_objective_prefix(), String(first_objective.get("id", "stabilize_flight")))
	_hud.set_status("Training in progress")
	mission_state = "running"

func _check_failure(snapshot: Dictionary, delta: float) -> void:
	var mission: Dictionary = mission_bundle.get("mission", {})
	var failure_data: Dictionary = mission.get("failure", {})
	if bool(failure_data.get("terrain_or_sea_impact", true)) and float(snapshot.get("altitude_m", 0.0)) <= 0.5:
		_set_terminal_state("Mission failed: impact", false)
		return
	var horizontal_pos: Vector3 = snapshot.get("position_m", Vector3.ZERO)
	var horizontal_distance := Vector2(horizontal_pos.x, horizontal_pos.z).length()
	if horizontal_distance > bounds_radius_m:
		_player.aircraft_state.out_of_bounds_seconds += delta
	else:
		_player.aircraft_state.out_of_bounds_seconds = maxf(0.0, _player.aircraft_state.out_of_bounds_seconds - delta)
	if _player.aircraft_state.out_of_bounds_seconds >= float(failure_data.get("out_of_bounds_seconds", 8.0)):
		_set_terminal_state("Mission failed: out of bounds", false)
		return
	if float(snapshot.get("stall_seconds", 0.0)) >= float(failure_data.get("stall_seconds", 4.0)):
		_set_terminal_state("Mission failed: stall", false)

func _set_terminal_state(text: String, success: bool) -> void:
	if mission_state == "success" or mission_state == "failure":
		return
	mission_state = "success" if success else "failure"
	_player.set_active(false)
	_hud.set_status(text + "  |  R to restart", success)

func _on_checkpoint_passed(checkpoint_id: String) -> void:
	_objectives.notify_checkpoint(checkpoint_id)

func _on_player_crashed(_reason: String) -> void:
	_set_terminal_state("Mission failed: impact", false)

func _objective_prefix() -> String:
	var mission: Dictionary = mission_bundle.get("mission", {})
	return String(mission.get("ui", {}).get("objective_prefix", "Objective"))
