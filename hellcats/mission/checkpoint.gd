class_name MissionCheckpoint
extends Node3D

signal checkpoint_passed(checkpoint_id: String)

var checkpoint_id: String = ""
var label_text: String = ""
var radius_m: float = 100.0
var required: bool = false
var order: int = 0
var _passed: bool = false

func configure(data: Dictionary) -> void:
	checkpoint_id = String(data.get("id", ""))
	label_text = String(data.get("label", checkpoint_id))
	radius_m = float(data.get("radius_m", 100.0))
	required = bool(data.get("required", false))
	order = int(data.get("order", 0))
	var pos: Array = data.get("position_m", [0.0, 1000.0, 0.0])
	position = Vector3(
		float(pos[0]) if pos.size() > 0 else 0.0,
		float(pos[1]) if pos.size() > 1 else 1000.0,
		float(pos[2]) if pos.size() > 2 else 0.0
	)
	_build_visuals()

func is_passed() -> bool:
	return _passed

func check_pass(world_position: Vector3) -> bool:
	if _passed:
		return false
	if world_position.distance_to(global_position) > radius_m:
		return false
	_passed = true
	checkpoint_passed.emit(checkpoint_id)
	_play_pass_feedback_then_hide()
	return true

func _play_pass_feedback_then_hide() -> void:
	var mesh_instance: MeshInstance3D = get_node_or_null("RingMesh")
	var player: AudioStreamPlayer3D = get_node_or_null("PassAudio")
	if player != null and player.stream != null:
		player.play()
	if mesh_instance == null:
		visible = false
		return
	var mat: StandardMaterial3D = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	var tw := create_tween()
	tw.tween_property(mesh_instance, "scale", Vector3(1.12, 1.12, 1.12), 0.1)
	if mat:
		mat.emission_enabled = true
		tw.parallel().tween_property(mat, "emission", Color(1.0, 0.95, 0.45) * 2.4, 0.08)
	tw.tween_callback(func(): visible = false)

func _build_visuals() -> void:
	var mesh_instance: MeshInstance3D = get_node_or_null("RingMesh")
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "RingMesh"
		add_child(mesh_instance)
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(2.0, radius_m * 0.04)
	torus.outer_radius = radius_m
	torus.rings = 32
	torus.ring_segments = 16
	mesh_instance.mesh = torus
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.85, 0.2, 0.75)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.set_surface_override_material(0, material.duplicate())
	rotation_degrees = Vector3(90.0, 0.0, 0.0)
