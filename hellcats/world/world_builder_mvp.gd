class_name WorldBuilderMvp
extends Node3D

func _ready() -> void:
	_ensure_environment()
	_ensure_light()
	_ensure_sea()
	_ensure_island()

func _ensure_environment() -> void:
	var environment_node: WorldEnvironment = get_node_or_null("WorldEnvironment")
	if environment_node == null:
		environment_node = WorldEnvironment.new()
		environment_node.name = "WorldEnvironment"
		add_child(environment_node)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.50, 0.73, 0.96)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.8, 0.86, 0.94)
	environment_node.environment = environment

func _ensure_light() -> void:
	var light: DirectionalLight3D = get_node_or_null("SunLight")
	if light == null:
		light = DirectionalLight3D.new()
		light.name = "SunLight"
		add_child(light)
	light.rotation_degrees = Vector3(-35.0, -30.0, 0.0)
	light.light_energy = 1.2

func _ensure_sea() -> void:
	var sea: MeshInstance3D = get_node_or_null("Sea")
	if sea == null:
		sea = MeshInstance3D.new()
		sea.name = "Sea"
		add_child(sea)
	var plane := PlaneMesh.new()
	plane.size = Vector2(20000.0, 20000.0)
	sea.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.08, 0.26, 0.48)
	material.roughness = 0.15
	sea.set_surface_override_material(0, material)
	sea.position = Vector3(0.0, 0.0, 0.0)

func _ensure_island() -> void:
	var island: MeshInstance3D = get_node_or_null("Island")
	if island == null:
		island = MeshInstance3D.new()
		island.name = "Island"
		add_child(island)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1200.0, 50.0, 1200.0)
	island.mesh = mesh
	island.position = Vector3(0.0, -24.0, 2600.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.38, 0.52, 0.26)
	island.set_surface_override_material(0, material)
