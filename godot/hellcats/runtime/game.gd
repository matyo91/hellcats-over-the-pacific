extends Control

## The game's entry scene: builds the Macintosh (MacMachine), shows its screen, hands it Godot's
## mouse and keyboard, and runs the original program on its thread.

const MacMachine := preload("res://hellcats/runtime/mac_machine.gd")
const GameThread := preload("res://hellcats/runtime/game_thread.gd")
const MacKeys := preload("res://hellcats/runtime/mac_keys.gd")

@onready var screen: TextureRect = $Screen
@onready var speaker: AudioStreamPlayer = $Speaker

var machine
var runner

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	machine = MacMachine.new()
	machine.toolbox.quickdraw.glyphs.prepare()
	screen.attach(machine)
	speaker.attach(machine)
	runner = GameThread.new(machine)
	runner.start()

func _process(_delta: float) -> void:
	if machine == null:
		return
	if machine.exited:
		_quit()
	var mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE if machine.cursor_level >= 0 else Input.MOUSE_MODE_HIDDEN
	if Input.mouse_mode != mode:
		Input.mouse_mode = mode

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit()

func _exit_tree() -> void:
	_halt()

## The program's thread parked at its next trap (up to two seconds), then Godot quits.
func _quit() -> void:
	_halt()
	get_tree().quit()

func _halt() -> void:
	if machine == null or machine.parked:
		return
	machine.halting = true
	var waited: int = 0
	while not machine.parked and runner.is_running() and waited < 2000:
		OS.delay_msec(10)
		waited += 10

## A point of the Godot window on the Mac's screen (the 640 x 480 image is fitted and centred).
func to_screen(p: Vector2) -> Vector2i:
	var area: Rect2 = screen.get_global_rect()
	var scale: float = minf(area.size.x / machine.SCREEN_WIDTH, area.size.y / machine.SCREEN_HEIGHT)
	var offset: Vector2 = area.position + (area.size - Vector2(machine.SCREEN_WIDTH, machine.SCREEN_HEIGHT) * scale) / 2.0
	var q: Vector2 = (p - offset) / scale
	return Vector2i(clampi(int(q.x), 0, machine.SCREEN_WIDTH - 1), clampi(int(q.y), 0, machine.SCREEN_HEIGHT - 1))

func _input(event: InputEvent) -> void:
	if machine == null:
		return
	var events = machine.toolbox.events
	if event is InputEventMouseMotion:
		events.move_mouse(to_screen(event.position))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		events.post_mouse(to_screen(event.position), event.pressed)
	elif event is InputEventKey:
		events.post_key(MacKeys.code(event.keycode), MacKeys.character(event), event.pressed, event.echo, MacKeys.modifiers(event))
