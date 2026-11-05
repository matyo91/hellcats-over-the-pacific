extends SceneTree

## An end-to-end session of the original program on the runtime, headless, as a player would drive
## it: through the start-up dialogs to Select a Mission (Return), into the cockpit, throttle up,
## the chase, tower and cockpit views, gear, flaps, the stick (the mouse), the flight's ⌘ keys
## (triple time, detail levels, sound; ⌘M, ⌘X and ⌘R, which the flight loop ignores as the original
## does, ID02 0x650), the stick held back from take-off, a burst of the guns (the button, which
## the flight reads with StillDown), pause and resume,
## eject, the mission summary dismissed back to the desktop, Instant Replay, then by mouse File > High
## Scores and the About box (Apple menu), then a new mission (⌘N: the roster, Select a Mission),
## interrupted (Escape) for the Mission Map (⌘M, enabled only with a mission under way, closed
## with Return) and Mission Status (⌘X), resumed (⌘R) and throttled up, interrupted again and ended
## by mouse (File > End Mission: no kills, so no caution alert, as confirm_end_mission, ID04 0x516).
## The Options, Scenery, File (no mission) and Apple menus are then pulled down (their check marks, ⌘
## keys and dimmed items in shots) and let go outside.
## It fails when the program's thread dies or the runtime notes anything the game reached that it does not provide
## (machine.missing). The game saves into its own folder (SAVES), so the player's pilots and
## settings are left alone.
## Not part of run_all.gd (it runs for END seconds of real time, below):
##
##   Godot --headless --path godot --script res://tests/runtime/smoke_session.gd [-- --shots <dir>] [--coverage <file>]
##
## With --shots, the screen is saved as PNG at each step marked "shot". With --coverage <file>, a
## passing session writes the strict-port routines the loaders dispatched, and the runtime-written
## ones ("runtime:ID02+0x4a4"), as a sorted JSON list (machine.coverage): the evidence for the mappings' runtime_verified (tests/runtime/fixtures/
## smoke_coverage.json, checked by tools/strict_port/check_sync.py).

const MacMachine := preload("res://hellcats/runtime/mac_machine.gd")
const GameThread := preload("res://hellcats/runtime/game_thread.gd")
const ResourceManager := preload("res://hellcats/toolbox/resource_manager.gd")
## The session's own save folder, emptied first: the player's pilots and settings are not touched.
const SAVES := "user://smoke_session_resources"

## [seconds, action, Mac key code or x, character or y]
const STEPS := [
	[3, "key", 0x24, 13], [6, "key", 0x24, 13], [9, "key", 0x24, 13], [11, "shot", 0, 0],
	[11.5, "mouse", 320, 300], [12, "throttle", 0, 0], [17, "key", 0x08, 0x63], [19, "shot", 0, 0],
	[20, "key", 0x11, 0x74], [22, "shot", 0, 0], [23, "key", 0x09, 0x76], [24, "key", 0x05, 0x67],
	[25, "key", 0x03, 0x66], [26, "cmd", 0x11, 0x74], [27, "cmd", 0x14, 0x33], [28, "cmd", 0x17, 0x35],
	[29, "shot", 0, 0], [30, "cmd", 0x12, 0x31], [31, "cmd", 0x01, 0x73], [32, "cmd", 0x01, 0x73],
	[33, "cmd", 0x11, 0x74], [34, "cmd", 0x2e, 0x6d], [37, "shot", 0, 0], [38, "key", 0x24, 13],
	[40, "cmd", 0x07, 0x78], [43, "shot", 0, 0], [44, "cmd", 0x0f, 0x72], [47, "shot", 0, 0],
	[48, "mouse", 320, 200], [50, "mouse", 320, 300], [52, "mouse", 200, 240], [52.5, "down", 200, 240], [53.8, "up", 200, 240], [54, "shot", 0, 0],
	[55, "key", 0x23, 0x70], [57, "key", 0x23, 0x70], [59, "key", 0x26, 0x6a], [65, "shot", 0, 0],
	[67, "key", 0x24, 13], [70, "key", 0x24, 13], [73, "shot", 0, 0], [74, "cmd", 0x22, 0x69],
	[80, "shot", 0, 0], [81, "key", 0x24, 13],
	[83, "mouse", 41, 10], [83.3, "down", 41, 10], [83.8, "mouse", 60, 189], [84.3, "up", 60, 189],
	[87, "shot", 0, 0], [88, "key", 0x24, 13],
	[90, "mouse", 14, 10], [90.3, "down", 14, 10], [90.8, "mouse", 30, 29], [91.3, "up", 30, 29],
	[94, "shot", 0, 0], [95, "key", 0x24, 13], [97, "shot", 0, 0],
	[98, "cmd", 0x2d, 0x6e], [101, "shot", 0, 0], [102, "key", 0x24, 13], [106, "shot", 0, 0],
	[107, "key", 0x24, 13], [111, "shot", 0, 0], [112, "key", 0x35, 0x1b], [114, "shot", 0, 0],
	[115, "cmd", 0x2e, 0x6d], [118, "shot", 0, 0], [119, "key", 0x24, 13], [121, "shot", 0, 0],
	[122, "cmd", 0x07, 0x78], [125, "shot", 0, 0], [126, "key", 0x24, 13], [128, "shot", 0, 0],
	[129, "cmd", 0x0f, 0x72], [131, "shot", 0, 0], [131.5, "throttle", 0, 0], [134, "shot", 0, 0],
	[135, "key", 0x35, 0x1b], [137, "mouse", 41, 10], [137.3, "down", 41, 10], [137.8, "mouse", 60, 157],
	[138.3, "up", 60, 157], [140, "shot", 0, 0],
	[141, "mouse", 122, 10], [141.3, "down", 122, 10], [142, "mouse", 140, 60], [143, "shot", 0, 0],
	[143.5, "mouse", 400, 300], [144, "up", 400, 300], [145, "shot", 0, 0],
	[146, "mouse", 180, 10], [146.3, "down", 180, 10], [147, "mouse", 200, 112], [148, "shot", 0, 0],
	[148.5, "mouse", 400, 300], [149, "up", 400, 300],
	[150, "mouse", 41, 10], [150.3, "down", 41, 10], [151, "mouse", 60, 61], [152, "shot", 0, 0],
	[152.5, "mouse", 400, 300], [153, "up", 400, 300],
	[154, "mouse", 14, 10], [154.3, "down", 14, 10], [155, "mouse", 30, 45], [156, "shot", 0, 0],
	[156.5, "mouse", 400, 300], [157, "up", 400, 300]]
const END := 159.0

var machine
var runner
var elapsed := 0.0
var step := 0
var shots := ""
var coverage_path := ""

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var at: int = args.find("--shots")
	if at >= 0 and at + 1 < args.size():
		shots = args[at + 1]
	at = args.find("--coverage")
	if at >= 0 and at + 1 < args.size():
		coverage_path = args[at + 1]
	_clear(SAVES)
	ResourceManager.saved_root = SAVES
	machine = MacMachine.new()
	if coverage_path != "":
		machine.coverage = {}
	machine.toolbox.quickdraw.glyphs.prepare()
	runner = GameThread.new(machine)
	runner.start()

func _process(delta: float) -> bool:
	elapsed += delta
	while step < STEPS.size() and elapsed > STEPS[step][0]:
		_act(STEPS[step])
		step += 1
	if elapsed < END and runner.is_running():
		return false
	var ok: bool = runner.is_running() and machine.missing.is_empty()
	for key in machine.missing:
		print("  missing %s %s" % [key, machine.missing[key]])
	if not runner.is_running():
		print("  the program's thread ended: %s" % runner.error)
	print("%s smoke session: %d steps, %d missing" % ["PASS" if ok else "FAIL", step, machine.missing.size()])
	if ok and coverage_path != "":
		var keys: Array = machine.coverage.keys()
		keys.sort()
		var f := FileAccess.open(coverage_path, FileAccess.WRITE)
		f.store_string(JSON.stringify(keys, "  ") + "\n")
		f.close()
		print("  %d routines dispatched (strict port and runtime:), written to %s" % [keys.size(), coverage_path])
	machine.halting = true
	var waited: int = 0
	while not machine.parked and runner.is_running() and waited < 2000:
		OS.delay_msec(10)
		waited += 10
	quit(0 if ok else 1)
	return true

func _act(s: Array) -> void:
	var events = machine.toolbox.events
	match s[1]:
		"key":
			events.post_key(s[2], s[3], true, false, 0)
			events.post_key(s[2], s[3], false, false, 0)
		"cmd":                      # with the Command key: a menu's key equivalent
			events.post_key(s[2], s[3], true, false, 0x100)
			events.post_key(s[2], s[3], false, false, 0x100)
		"throttle":
			for k in 12:
				events.post_key(0x18, 0x3d, true, false, 0)
				events.post_key(0x18, 0x3d, false, false, 0)
		"mouse":
			events.move_mouse(Vector2i(s[2], s[3]))
		"down":                     # the button, at a point (a menu title: MenuSelect tracks the mouse)
			events.post_mouse(Vector2i(s[2], s[3]), true)
		"up":
			events.post_mouse(Vector2i(s[2], s[3]), false)
		"shot":
			if shots != "":
				_shot("%s/smoke_%02d.png" % [shots, step])

func _shot(path: String) -> void:
	var image := Image.create(machine.SCREEN_WIDTH, machine.SCREEN_HEIGHT, false, Image.FORMAT_RGBA8)
	var bytes: PackedByteArray = machine.screen_bytes()
	var table: Array = machine.toolbox.palettes.colours()
	for y in machine.SCREEN_HEIGHT:
		for x in machine.SCREEN_WIDTH:
			image.set_pixel(x, y, table[bytes[y * machine.SCREEN_WIDTH + x]])
	image.save_png(path)

func _clear(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_clear(path.path_join(sub))
	for file in dir.get_files():
		dir.remove(file)
	DirAccess.remove_absolute(path)
