class_name PlayerInputMap
extends RefCounted
## Godot input layer aligned with FUN_0000740a semantics (see docs/contracts/input_godot_contract.md).
## [RECONSTRUCTED] Discrete key events, press vs release, throttle step (+/-) vs hold.
## [MVP APPROXIMATION] No DAT_0001d858 FSM; gating = player aircraft active only.

const ACTIONS := {
	"pitch_up": [KEY_UP],
	"pitch_down": [KEY_DOWN],
	"roll_left": [KEY_LEFT, KEY_A],
	"roll_right": [KEY_RIGHT, KEY_D],
	"yaw_left": [KEY_Q],
	"yaw_right": [KEY_E],
	"throttle_up": [KEY_PAGEUP, KEY_W],
	"throttle_down": [KEY_PAGEDOWN, KEY_S],
	## [RECONSTRUCTED] FUN_0000740a: 0x2b/0x3d (+/=) and 0x2d/0x5f (-/_), DAT_00024cf6 step.
	"throttle_step_up": [KEY_EQUAL, KEY_KP_ADD],
	"throttle_step_down": [KEY_MINUS, KEY_KP_SUBTRACT],
	"mission_restart": [KEY_R],
}

## Actions included in per-tick trace (pressed/held/released).
const TRACE_ACTIONS: Array[String] = [
	"pitch_up",
	"pitch_down",
	"roll_left",
	"roll_right",
	"yaw_left",
	"yaw_right",
	"throttle_up",
	"throttle_down",
	"throttle_step_up",
	"throttle_step_down",
]

## [MVP APPROXIMATION] Instant throttle fraction per step edge; not identical to DAT_00024cf6 ramp.
const THROTTLE_STEP_IMPULSE: float = 0.11

## Last trace from read_input_packet(); for debug, tests, or HUD.
static var last_input_trace: Dictionary = {}

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
	return read_input_packet(true).controls

## Returns { "controls": Dictionary, "trace": Dictionary }.
## When player_active is false, controls are zeroed; pressed edges are listed under trace.ignored.
static func read_input_packet(player_active: bool) -> Dictionary:
	var pressed: Array[String] = []
	var held: Array[String] = []
	var released: Array[String] = []
	var ignored: Array[String] = []

	for a: String in TRACE_ACTIONS:
		if Input.is_action_just_pressed(a):
			pressed.append(a)
		if Input.is_action_pressed(a):
			held.append(a)
		if Input.is_action_just_released(a):
			released.append(a)

	var step_up := Input.is_action_just_pressed("throttle_step_up")
	var step_down := Input.is_action_just_pressed("throttle_step_down")

	if not player_active:
		for a: String in pressed:
			ignored.append(a)
		var trace_inactive := {
			"pressed": pressed,
			"held": [],
			"released": released,
			"normalized":
			{"pitch": 0.0, "roll": 0.0, "yaw": 0.0, "throttle": 0.0, "throttle_impulse": 0.0},
			"gated": true,
			"gate_reason": "player_inactive",
			"ignored": ignored,
		}
		last_input_trace = trace_inactive
		return {
			"controls":
			{
				"pitch": 0.0,
				"roll": 0.0,
				"yaw": 0.0,
				"throttle": 0.0,
				"throttle_impulse": 0.0,
			},
			"trace": trace_inactive,
		}

	var axis_pitch := Input.get_axis("pitch_down", "pitch_up")
	var axis_roll := Input.get_axis("roll_left", "roll_right")
	var axis_yaw := Input.get_axis("yaw_left", "yaw_right")
	var axis_throttle := Input.get_axis("throttle_down", "throttle_up")
	var impulse := 0.0
	if step_up:
		impulse += THROTTLE_STEP_IMPULSE
	if step_down:
		impulse -= THROTTLE_STEP_IMPULSE

	var controls := compute_controls(axis_pitch, axis_roll, axis_yaw, axis_throttle, impulse)
	var trace := {
		"pressed": pressed,
		"held": held,
		"released": released,
		"normalized": {
			"pitch": controls["pitch"],
			"roll": controls["roll"],
			"yaw": controls["yaw"],
			"throttle": controls["throttle"],
			"throttle_impulse": controls["throttle_impulse"],
		},
		"gated": false,
		"gate_reason": "none",
		"ignored": ignored,
	}
	last_input_trace = trace
	return {"controls": controls, "trace": trace}

## Pure path for tests: maps axis samples and step edges to control intent (no Input singleton).
static func compute_outputs(
	gate_active: bool,
	axis_pitch: float,
	axis_roll: float,
	axis_yaw: float,
	axis_throttle: float,
	step_up_pressed: bool,
	step_down_pressed: bool
) -> Dictionary:
	if not gate_active:
		return {"pitch": 0.0, "roll": 0.0, "yaw": 0.0, "throttle": 0.0, "throttle_impulse": 0.0}
	var impulse := 0.0
	if step_up_pressed:
		impulse += THROTTLE_STEP_IMPULSE
	if step_down_pressed:
		impulse -= THROTTLE_STEP_IMPULSE
	return compute_controls(axis_pitch, axis_roll, axis_yaw, axis_throttle, impulse)

static func compute_controls(
	pitch: float,
	roll: float,
	yaw: float,
	throttle: float,
	throttle_impulse: float
) -> Dictionary:
	return {
		"pitch": pitch,
		"roll": roll,
		"yaw": yaw,
		"throttle": throttle,
		"throttle_impulse": throttle_impulse,
	}

static func _action_has_key(action: String, keycode: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return true
	return false
