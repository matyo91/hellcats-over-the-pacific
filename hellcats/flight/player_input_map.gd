class_name PlayerInputMap
extends RefCounted

const ACTIONS := {
	"pitch_up": [KEY_UP],
	"pitch_down": [KEY_DOWN],
	"roll_left": [KEY_LEFT, KEY_A],
	"roll_right": [KEY_RIGHT, KEY_D],
	"yaw_left": [KEY_Q],
	"yaw_right": [KEY_E],
	"throttle_up": [KEY_PAGEUP, KEY_W],
	"throttle_down": [KEY_PAGEDOWN, KEY_S],
	"mission_restart": [KEY_R],
}

static func ensure_actions() -> void:
	for action in ACTIONS.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in ACTIONS[action]:
			if _action_has_key(action, keycode):
				continue
			var event := InputEventKey.new()
			event.keycode = keycode
			InputMap.action_add_event(action, event)

static func read_input() -> Dictionary:
	return {
		"pitch": Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"),
		"roll": Input.get_action_strength("roll_right") - Input.get_action_strength("roll_left"),
		"yaw": Input.get_action_strength("yaw_right") - Input.get_action_strength("yaw_left"),
		"throttle": Input.get_action_strength("throttle_up") - Input.get_action_strength("throttle_down"),
	}

static func _action_has_key(action: String, keycode: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return true
	return false
