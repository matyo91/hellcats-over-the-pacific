class_name PlayerAircraft
extends Node3D

signal crashed(reason: String)

const AircraftStateScript := preload("res://hellcats/flight/aircraft_state.gd")
const FlightModelScript := preload("res://hellcats/flight/flight_model_mvp.gd")
const PlayerInputMapScript := preload("res://hellcats/flight/player_input_map.gd")

var aircraft_state
var flight_model
var aircraft_data: Dictionary = {}
var active: bool = false
var _input_tick: int = 0

func _ready() -> void:
	PlayerInputMapScript.ensure_actions()
	aircraft_state = AircraftStateScript.new()
	flight_model = FlightModelScript.new()
	_ensure_visuals()

func setup_mission(aircraft_config: Dictionary, mission_data: Dictionary) -> void:
	aircraft_data = aircraft_config.duplicate(true)
	flight_model.configure(aircraft_data)
	flight_model.reset()
	aircraft_state.apply_spawn(mission_data.get("spawn", {}))
	active = true
	_apply_state_to_transform()

func set_active(enabled: bool) -> void:
	active = enabled

func restart(mission_data: Dictionary) -> void:
	flight_model.reset()
	aircraft_state.apply_spawn(mission_data.get("spawn", {}))
	active = true
	_apply_state_to_transform()

func _physics_process(delta: float) -> void:
	if not active:
		return
	var packet: Dictionary = PlayerInputMapScript.read_input_packet(active)
	var controls: Dictionary = packet.get("controls", {}) as Dictionary
	var trace: Dictionary = packet.get("trace", {}) as Dictionary
	if not trace.is_empty():
		_input_tick += 1
		trace["tick"] = _input_tick
		PlayerInputMapScript.last_input_trace = trace
	flight_model.step(aircraft_state, controls, delta)
	_apply_state_to_transform()
	if aircraft_state.position_m.y <= 0.5 and not aircraft_state.is_crashed:
		aircraft_state.is_crashed = true
		active = false
		crashed.emit("terrain_or_sea_impact")

func _apply_state_to_transform() -> void:
	global_position = aircraft_state.position_m
	rotation = Vector3(
		deg_to_rad(-aircraft_state.pitch_deg),
		deg_to_rad(-aircraft_state.heading_deg),
		deg_to_rad(aircraft_state.roll_deg)
	)

func get_snapshot() -> Dictionary:
	return aircraft_state.snapshot()

func _ensure_visuals() -> void:
	var mesh_instance: MeshInstance3D = get_node_or_null("AircraftMesh")
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "AircraftMesh"
		add_child(mesh_instance)
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(4.5, 0.8, 6.0)
	mesh_instance.mesh = body_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.35, 0.45)
	mesh_instance.set_surface_override_material(0, material)

	var wings: MeshInstance3D = get_node_or_null("Wings")
	if wings == null:
		wings = MeshInstance3D.new()
		wings.name = "Wings"
		add_child(wings)
	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(12.0, 0.15, 1.6)
	wings.mesh = wing_mesh
	wings.position = Vector3(0.0, 0.0, 0.4)
	wings.set_surface_override_material(0, material)

	var camera: Camera3D = get_node_or_null("FollowCamera")
	if camera == null:
		camera = Camera3D.new()
		camera.name = "FollowCamera"
		add_child(camera)
	camera.position = Vector3(0.0, 3.0, 14.0)
	camera.rotation_degrees = Vector3(-10.0, 180.0, 0.0)
	camera.current = true
