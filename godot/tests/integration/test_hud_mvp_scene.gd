extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")

func run() -> bool:
	var ok := true
	var scene := load("res://godot/scenes/ui/HUD_MVP.tscn")
	ok = Assertions.assert_true(scene != null, "HUD scene resource loads") and ok
	if scene == null:
		return false
	var root: Node = scene.instantiate()
	ok = Assertions.assert_true(root != null, "HUD scene instantiates") and ok
	if root == null:
		return false
	ok = Assertions.assert_true(root.get_node_or_null("RootMargin/VBox/TitleLabel") != null, "HUD has TitleLabel path") and ok
	ok = Assertions.assert_true(root.get_node_or_null("RootMargin/VBox/ObjectiveLabel") != null, "HUD has ObjectiveLabel path") and ok
	ok = Assertions.assert_true(root.get_node_or_null("RootMargin/VBox/TelemetryLabel") != null, "HUD has TelemetryLabel path") and ok
	ok = Assertions.assert_true(root.get_node_or_null("RootMargin/VBox/StatusLabel") != null, "HUD has StatusLabel path") and ok
	root.free()
	return ok
