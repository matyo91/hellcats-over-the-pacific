extends RefCounted

const Assertions := preload("res://godot/tests/helpers/assertions.gd")

func run() -> bool:
	var ok := true
	var scene := load("res://godot/scenes/missions/Mission01Training.tscn")
	ok = Assertions.assert_true(scene != null, "mission scene resource loads") and ok
	if scene == null:
		return false
	var instance: Node = scene.instantiate()
	ok = Assertions.assert_true(instance != null, "mission scene instantiates") and ok
	ok = Assertions.assert_true(instance.has_node("World"), "mission scene has world child") and ok
	ok = Assertions.assert_true(instance.has_node("PlayerAircraft"), "mission scene has player child") and ok
	ok = Assertions.assert_true(instance.has_node("Checkpoints"), "mission scene has checkpoints child") and ok
	ok = Assertions.assert_true(instance.has_node("HUD"), "mission scene has HUD child") and ok
	ok = Assertions.assert_true(instance.has_node("MissionController"), "mission scene has mission controller child") and ok
	instance.free()
	return ok
