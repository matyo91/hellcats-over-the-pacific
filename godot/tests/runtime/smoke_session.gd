extends SceneTree

## An end-to-end session of the original program on the runtime, headless, driven as a player
## would (STEPS below, in seconds):
##
##   1. Start-up dialogs, then Select a Mission (Return: Bomb Base) into the cockpit. Throttle up;
##      the chase, tower and cockpit views; gear, flaps and the stick (the mouse); the flight's
##      own command keys (triple time, detail, sound; the flight loop ignores ⌘M / ⌘X / ⌘R, as
##      the original's, ID02 0x650); Tab (cycle_view_distance) and ^S around two '4's (the slew
##      mode, player_slew_mode, moved along x); the left arrow twice (the cockpit view turned a
##      quarter left: view 2 and its attitude matrices, build_attitude_matrix_6ang). Stick back for take-off, a burst of the guns (the button,
##      read with StillDown), both bombs ('B', once airborne), pause and resume, eject.
##   2. The mission summary back to the desktop, Instant Replay; by mouse File > High Scores
##      (Erase Nonactive...: its caution answered Cancel) and the About box (Apple menu).
##   3. A new mission (⌘N: the roster, its selected pilot renamed "ace", then Select a
##      Mission), interrupted (Escape) for the Mission Map (⌘M, closed with Return) and Mission
##      Status (⌘X, its text scrolled by the scroll bar's arrow); resumed (⌘R), interrupted
##      again and ended by mouse (File > End Mission: no kills, so no caution, as
##      confirm_end_mission, ID04 0x516).
##   4. The Options, Scenery, File and Apple menus pulled down (check marks, ⌘ keys and dimmed
##      items in shots); Options let go on 3/4 Height, the others outside; then Scenery > Haze and
##      Scenery > Real Time Shading (both off in the settings record) turned on, so the missions
##      after it draw with haze (snapshot_face_colours, update_record_distance_band).
##   5. A third mission, Scramble! (picked by mouse): take-off from its airfield, then the target
##      lock ('A': the original steers at the designated aircraft while it is down,
##      apply_player_mouse_controls) and the guns held for a minute of its raid; interrupted.
##   6. File > Open... (⌘O): Standard File's Get File, Return on the scenery (Pacific Conflict), so
##      the overlay is loaded again from the menu command (bootstrap_window_and_load_overlay).
##   7. After that reload, a fourth mission, Flying Fortress (picked by mouse): take-off while the
##      friendly B-17 flies its route (tick_ai_1b370_mission, kind 3 of the AI fly table); the
##      route is too long for the session to see it land (try_begin_landing_approach); interrupted.
##   8. A fifth mission, Divine Wind (picked by mouse), the player left on its airfield while the
##      waves of kamikazes form and dive at the fleet (tick_wave_spawner, ai_dive_at_target);
##      interrupted.
##   9. File > Quit (⌘Q) with the settings changed (phase 4's 3/4 Height): Save changes to Settings
##      before quitting? (ask_save_changes, ALRT 257) answered Cancel by mouse, so the program goes on.
##
## It fails when the program's thread dies, the runtime notes anything the game reached that it
## does not provide (machine.missing), or a script error happens (ErrorLog: a port's failed
## assertion only aborts that function). The game saves into its own folder (SAVES), so the player's
## pilots and settings are left alone. Not part of run_all.gd (it runs for END seconds):
##
##   Godot --headless --path godot --script res://tests/runtime/smoke_session.gd [-- --shots <dir>]
##       [--coverage <file> [--merge]] [--depth 4|1] [--24bit] [--mission 2-9 [--seconds <s>]]
##       [--missing-scenery | --lost-pilot] [--haze] [--one-line]
##
## --shots <dir>: the screen saved as PNG at each "shot" step.
## --depth 4 | 1: a 16-colour or black-and-white screen (MacMachine.screen_depth) instead of 8 bits.
## --24bit: a 24-bit Mac with a 32-bit screen (MacMachine.addressing_24): the original swaps the MMU
##   mode around its screen accesses.
## --mission <n>: only mission n (2..9), from start-up, the player left where it starts, for
##   MISSION_END seconds or --seconds <s> (mission_steps below says what each reaches).
## --missing-scenery: start-up with saved settings naming a scenery file that is not there
##   (MISSING_SCENERY_STEPS below).
## --lost-pilot: a saved roster with a lost pilot, erased from High Scores (LOST_PILOT_STEPS below).
## --haze: saved settings with Scenery > Haze and Real Time Shading on (with --mission: the missions
##   drawn with haze from the start).
## --one-line: saved settings with Options > One line Instruments on.
## --coverage <file>: the strict port runs from the instrumented copies
##   tools/strict_port/coverage_copies.py writes into res://.coverage (each taking over its
##   original's path before the runtime's scripts load), and a passing session writes every
##   strict-port function that ran ("ID02.gd:main") and the runtime-written routines that ran
##   ("runtime:ID02+0x4a4") as a sorted JSON list.
## --merge: that list is added to the file's.
##
## The evidence for the mappings' runtime_verified (tests/runtime/fixtures/smoke_coverage.json, read
## by tools/strict_port/check_sync.py) merges these runs, each reaching code the others cannot:
##   - the full session at 8 bits, --depth 4, --depth 1 and --24bit (each depth its renderer, the
##     24-bit Mac the MMU swaps);
##   - --mission 2, 3, 4, 8 and 9, --mission 4, 7, 8 and 9 --seconds 300, and --mission 3 --haze
##     --one-line;
##   - --missing-scenery (the scenery-open error) and --lost-pilot (High Scores' erase);
##   - protection_session.gd, plain and --master-disk (the copy-protection challenge; the original
##     floppy refused).
## The game's AI varies between runs, so a rerun can add to it. Steps are timed by the wall clock
## and the game by its frames: a run shares the machine with no other (two at once each see half
## the game).

## The port files in dependency order: a copy's own preloads (ID02 -> ID01, ID03 / ID07 -> ID02)
## must find the copies already in place.
const PORT_ORDER := ["ID01", "ID02", "ID03", "ID04", "ID05", "ID06", "ID07", "ID08", "ID09",
		"pacific_conflict"]
var MacMachine
var GameThread
var ResourceManager
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
	[40, "cmd", 0x07, 0x78], [43, "shot", 0, 0], [44, "cmd", 0x0f, 0x72], [45, "key", 0x30, 0x09], [45.5, "key", 0x01, 0x13], [46, "key", 0x56, 0x34],
	[46.4, "key", 0x56, 0x34], [46.8, "key", 0x01, 0x13], [47, "shot", 0, 0], [47.2, "key", 0x7b, 0x1c], [47.5, "key", 0x7b, 0x1c],
	[47.8, "shot", 0, 0],
	[48, "mouse", 320, 200], [50, "mouse", 320, 300], [52, "mouse", 200, 240], [52.5, "down", 200, 240], [53.8, "up", 200, 240], [53.9, "key", 0x0b, 0x62], [54, "shot", 0, 0], [54.4, "key", 0x0b, 0x62],
	[55, "key", 0x23, 0x70], [57, "key", 0x23, 0x70], [59, "key", 0x26, 0x6a], [65, "shot", 0, 0],
	[67, "key", 0x24, 13], [70, "key", 0x24, 13], [73, "shot", 0, 0], [74, "cmd", 0x22, 0x69],
	[80, "shot", 0, 0], [81, "key", 0x24, 13],
	[83, "mouse", 41, 10], [83.3, "down", 41, 10], [83.8, "mouse", 60, 189], [84.3, "up", 60, 189],
	[87, "shot", 0, 0], [87.3, "mouse", 316, 371], [87.4, "down", 316, 371], [87.6, "up", 316, 371],
	[88, "key", 0x24, 13], [88.6, "key", 0x24, 13],
	[90, "mouse", 14, 10], [90.3, "down", 14, 10], [90.8, "mouse", 30, 29], [91.3, "up", 30, 29],
	[94, "shot", 0, 0], [95, "key", 0x24, 13], [97, "shot", 0, 0],
	[98, "cmd", 0x2d, 0x6e], [101, "shot", 0, 0], [101.3, "type", 0, 0], [102, "key", 0x24, 13], [106, "shot", 0, 0],
	[107, "key", 0x24, 13], [111, "shot", 0, 0], [112, "key", 0x35, 0x1b], [114, "shot", 0, 0],
	[115, "cmd", 0x2e, 0x6d], [118, "shot", 0, 0], [119, "key", 0x24, 13], [121, "shot", 0, 0],
	[122, "cmd", 0x07, 0x78], [124, "mouse", 551, 201], [124.2, "down", 551, 201], [124.6, "up", 551, 201],
	[125, "shot", 0, 0], [126, "key", 0x24, 13], [128, "shot", 0, 0],
	[129, "cmd", 0x0f, 0x72], [131, "shot", 0, 0], [131.5, "throttle", 0, 0], [134, "shot", 0, 0],
	[135, "key", 0x35, 0x1b], [137, "mouse", 41, 10], [137.3, "down", 41, 10], [137.8, "mouse", 60, 157],
	[138.3, "up", 60, 157], [140, "shot", 0, 0],
	[141, "mouse", 122, 10], [141.3, "down", 122, 10], [142, "mouse", 140, 60], [143, "shot", 0, 0],
	[143.5, "mouse", 140, 156], [144, "up", 140, 156], [145, "shot", 0, 0],
	[146, "mouse", 180, 10], [146.3, "down", 180, 10], [147, "mouse", 200, 112], [148, "shot", 0, 0],
	[148.5, "mouse", 400, 300], [149, "up", 400, 300],
	[150, "mouse", 41, 10], [150.3, "down", 41, 10], [151, "mouse", 60, 61], [152, "shot", 0, 0],
	[152.5, "mouse", 400, 300], [153, "up", 400, 300],
	[154, "mouse", 14, 10], [154.3, "down", 14, 10], [155, "mouse", 30, 45], [156, "shot", 0, 0],
	[156.5, "mouse", 400, 300], [157, "up", 400, 300],
	[157.1, "mouse", 180, 10], [157.2, "down", 180, 10], [157.35, "mouse", 200, 123], [157.5, "up", 200, 123],
	[157.55, "mouse", 180, 10], [157.6, "down", 180, 10], [157.75, "mouse", 200, 187], [157.9, "up", 200, 187],
	[158, "cmd", 0x2d, 0x6e], [161, "key", 0x24, 13], [164, "mouse", 374, 207], [164.2, "down", 374, 207],
	[164.4, "up", 374, 207], [165, "shot", 0, 0], [165.5, "key", 0x24, 13], [168, "throttle", 0, 0], [172, "mouse", 320, 300], [178, "mouse", 320, 250],
	[175, "mouse", 320, 240], [175.1, "keydown", 0x00, 0x61], [175.2, "down", 320, 240], [180, "shot", 0, 0],
	[234.8, "up", 320, 240], [234.9, "keyup", 0x00, 0x61],
	[195, "shot", 0, 0], [215, "shot", 0, 0], [236, "key", 0x35, 0x1b], [238, "shot", 0, 0],
	[239, "cmd", 0x1f, 0x6f], [241, "shot", 0, 0], [242, "key", 0x24, 13], [248, "shot", 0, 0],
	[250, "cmd", 0x2d, 0x6e], [253, "key", 0x24, 13], [256, "mouse", 259, 272], [256.2, "down", 259, 272],
	[256.4, "up", 259, 272], [257, "shot", 0, 0], [257.5, "key", 0x24, 13], [260, "throttle", 0, 0],
	[264, "mouse", 320, 300], [270, "mouse", 320, 250], [280, "shot", 0, 0], [310, "shot", 0, 0],
	[318, "key", 0x35, 0x1b], [320, "shot", 0, 0],
	[321, "cmd", 0x2d, 0x6e], [324, "key", 0x24, 13], [327, "mouse", 409, 224], [327.2, "down", 409, 224],
	[327.4, "up", 409, 224], [328, "shot", 0, 0], [328.5, "key", 0x24, 13], [330, "mouse", 320, 240],
	[331, "key", 0x08, 0x63], [360, "shot", 0, 0], [400, "shot", 0, 0], [416, "key", 0x35, 0x1b], [418, "shot", 0, 0],
	[419, "cmd", 0x0c, 0x71], [421, "shot", 0, 0], [422, "mouse", 330, 180], [422.2, "down", 330, 180],
	[422.4, "up", 330, 180], [424, "shot", 0, 0]]
const END := 426.0
## --mission <n>: mission n as the first one (after the roster, its radio item clicked: DITL 129
## items 9..16, top left in the dialog, which the Dialog Manager centres at 109, 115); the player
## is left where the mission starts (the stick centred, the view key 'c') for MISSION_END seconds,
## so only the mission's own forces act: in Bomb Base (3) enemy fighters attack the parked player
## (_pursue_attack, apply_random_aircraft_damage, apply_blast_damage, the smoke trails and burst
## effects), The Duel (9) its pursuit phases, Flattop (8) its AI script, Capture Island (4) its
## firing ship (definition key 0x19), burning trails and ground marks, and both it and Flight
## School (2) the fractal terrain (fractal_height_at, test_terrain_collision). Given --seconds 300:
## Divine Wind (7) its kamikazes striking and sinking the fleet (apply_hit_to_sinkable_object,
## sink_object_shape_at_waterline, remove_mission_target, the debris explosions), Flattop and The
## Duel their raids' bombs (ordnance_collision), debris fragments and smoke plumes.
const MISSION_ITEMS := {2: [73, 58], 3: [97, 58], 4: [121, 58], 5: [145, 58], 6: [73, 257],
		7: [97, 257], 8: [121, 257], 9: [143, 257]}
const MISSION_END := 120.0

static func mission_steps(mission: int) -> Array:
	var x: int = 109 + MISSION_ITEMS[mission][1] + 40
	var y: int = 115 + MISSION_ITEMS[mission][0] + 12
	return [[3, "key", 0x24, 13], [5, "mouse", x, y], [5.2, "down", x, y], [5.4, "up", x, y],
		[5.8, "shot", 0, 0], [6, "key", 0x24, 13], [8, "mouse", 320, 240], [9, "key", 0x08, 0x63],
		[40, "shot", 0, 0], [80, "shot", 0, 0], [118, "shot", 0, 0], [180, "shot", 0, 0],
		[240, "shot", 0, 0], [298, "shot", 0, 0]]

## --missing-scenery: the saved settings (HEL1 127, written into SAVES) name a scenery file the
## volume does not hold, as when a player has moved it: the start-up load fails
## (load_overlay_from_resource's FSOpen, twice) and show_scenery_open_error_alert (ID04 0x44e,
## stop alert 0x100) names it; Return, then File > Open... (⌘O) and Return on the real scenery.
const MISSING_SCENERY := "Lost Scenery"
const MISSING_SCENERY_STEPS := [
	[3, "shot", 0, 0], [4, "key", 0x24, 13], [6, "shot", 0, 0], [7, "cmd", 0x1f, 0x6f],
	[9, "shot", 0, 0], [10, "key", 0x24, 13], [14, "shot", 0, 0]]
const MISSING_SCENERY_END := 16.0
## --lost-pilot: the saved roster (HEL1 128, 20 records of 0x40 bytes) holds one pilot, "Lost", whose
## status word +0x20 (the pilot status run_flight_session copies in after a flight) is set; the
## start-up roster cancelled (its Cancel button), File > High Scores by mouse, Erase Nonactive... answered
## Erase (ALRT 260 item 2): run_high_scores_dialog resets that record (reset_pilot_record).
const LOST_PILOT_STEPS := [
	[3, "shot", 0, 0], [3.4, "mouse", 374, 380], [3.5, "down", 374, 380], [3.7, "up", 374, 380],
	[5, "shot", 0, 0], [6, "mouse", 41, 10], [6.3, "down", 41, 10], [6.8, "mouse", 60, 189], [7.3, "up", 60, 189],
	[9, "shot", 0, 0], [9.3, "mouse", 316, 371], [9.4, "down", 316, 371], [9.6, "up", 316, 371],
	[11, "shot", 0, 0], [11.3, "mouse", 410, 179], [11.4, "down", 410, 179], [11.6, "up", 410, 179],
	[13, "shot", 0, 0], [13.5, "key", 0x24, 13], [15, "shot", 0, 0]]
const LOST_PILOT_END := 17.0

var steps: Array = STEPS
var end: float = END

var machine
var runner
var elapsed := 0.0
var step := 0
var shots := ""
var coverage_path := ""

## Script errors while the session runs (a failed assertion in a port, a call Godot refuses): they
## abort only the function they happen in, so the program would carry on past them.
class ErrorLog extends Logger:
	var errors: Array = []
	var _lock := Mutex.new()
	func _log_error(function: String, file: String, line: int, _code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		_lock.lock()
		if errors.size() < 20:
			errors.append("%s (%s:%d %s)" % [rationale, file.get_file(), line, function])
		else:
			errors.resize(21)
		_lock.unlock()
	func _log_message(_message: String, _error: bool) -> void:
		pass

var error_log := ErrorLog.new()

func _initialize() -> void:
	OS.add_logger(error_log)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var at: int = args.find("--shots")
	if at >= 0 and at + 1 < args.size():
		shots = args[at + 1]
	at = args.find("--coverage")
	if at >= 0 and at + 1 < args.size():
		coverage_path = args[at + 1]
	if coverage_path != "":
		Engine.set_meta("strict_coverage", {})
		for name in PORT_ORDER:
			var copy: Script = load("res://.coverage/%s.gd" % name)
			copy.take_over_path("res://strict_port/code/%s.gd" % name)
	at = args.find("--mission")
	if at >= 0 and at + 1 < args.size():
		steps = mission_steps(int(args[at + 1]))
		end = MISSION_END
		at = args.find("--seconds")
		if at >= 0 and at + 1 < args.size():
			end = float(args[at + 1])
	var missing_scenery: bool = args.has("--missing-scenery")
	if missing_scenery:
		steps = MISSING_SCENERY_STEPS
		end = MISSING_SCENERY_END
	var lost_pilot: bool = args.has("--lost-pilot")
	if lost_pilot:
		steps = LOST_PILOT_STEPS
		end = LOST_PILOT_END
	MacMachine = load("res://hellcats/runtime/mac_machine.gd")
	at = args.find("--depth")
	if at >= 0 and at + 1 < args.size():
		MacMachine.screen_depth = int(args[at + 1])
	MacMachine.addressing_24 = args.has("--24bit")
	GameThread = load("res://hellcats/runtime/game_thread.gd")
	ResourceManager = load("res://hellcats/toolbox/resource_manager.gd")
	_clear(SAVES)
	var haze: bool = args.has("--haze")
	var one_line: bool = args.has("--one-line")
	if missing_scenery or haze or one_line:
		_write_settings(MISSING_SCENERY if missing_scenery else "", haze, one_line)
	if lost_pilot:
		_write_lost_pilot()

	ResourceManager.saved_root = SAVES
	machine = MacMachine.new()
	if coverage_path != "":
		machine.coverage = Engine.get_meta("strict_coverage")
	machine.toolbox.quickdraw.glyphs.prepare()
	runner = GameThread.new(machine)
	runner.start()

## A saved settings record (HEL1 127, the original's otherwise): with `scenery`, the scenery name
## (+0x2a, a Pascal string); with `haze`, Scenery > Haze (+0x12) and Real Time Shading (+0x1a) on
## (apply_settings_to_live_options copies them to host +0xaa / +0xb2 at depth 8); with `one_line`,
## Options > One line Instruments (+9): numeric readouts instead of the panel, printed through the
## host's draw_text_in_columns_a5safe (+0x27a).
func _write_settings(scenery: String, haze: bool, one_line: bool) -> void:
	var data: PackedByteArray = load("res://strict_port/ui/resource_files.gd").load_bytes("HEL1", 127)
	if scenery != "":
		var bytes: PackedByteArray = scenery.to_ascii_buffer()
		data[0x2a] = bytes.size()
		for k in bytes.size():
			data[0x2b + k] = bytes[k]
	if haze:
		data[0x13] = 1
		data[0x1b] = 1
	if one_line:
		data[0x9] = 1
	_write_saved(127, data)

## A saved roster (HEL1 128, the original's otherwise) whose record 0 is a lost pilot: name "Lost"
## (+0, a Pascal string), status +0x20 = 1.
func _write_lost_pilot() -> void:
	var data: PackedByteArray = load("res://strict_port/ui/resource_files.gd").load_bytes("HEL1", 128)
	var name: PackedByteArray = "Lost".to_ascii_buffer()
	data[0] = name.size()
	for k in name.size():
		data[1 + k] = name[k]
	data[0x21] = 1
	_write_saved(128, data)

func _write_saved(id: int, data: PackedByteArray) -> void:
	DirAccess.make_dir_recursive_absolute(SAVES + "/hel1")
	var f := FileAccess.open(SAVES + "/hel1/%d.bin" % id, FileAccess.WRITE)
	f.store_buffer(data)
	f.close()

func _process(delta: float) -> bool:
	elapsed += delta
	while step < steps.size() and elapsed > steps[step][0]:
		_act(steps[step])
		step += 1
	if elapsed < end and runner.is_running():
		return false
	OS.remove_logger(error_log)
	var ok: bool = runner.is_running() and machine.missing.is_empty() and error_log.errors.is_empty()
	for key in machine.missing:
		print("  missing %s %s" % [key, machine.missing[key]])
	for e in error_log.errors.slice(0, 20):
		print("  script error: %s" % e)
	if not runner.is_running():
		print("  the program's thread ended: %s" % runner.error)
	print("%s smoke session: %d steps, %d missing, %d script errors" % ["PASS" if ok else "FAIL", step,
			machine.missing.size(), error_log.errors.size()])
	if ok and coverage_path != "":
		var seen: Dictionary = machine.coverage.duplicate()
		if OS.get_cmdline_user_args().has("--merge") and FileAccess.file_exists(coverage_path):
			for k in JSON.parse_string(FileAccess.get_file_as_string(coverage_path)):
				seen[k] = true
		var keys: Array = seen.keys()
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
		"type":                     # the roster's selected name replaced by "ace" (SelIText selects it)
			for c in "ace".to_ascii_buffer():
				events.post_key(0, c, true, false, 0)
				events.post_key(0, c, false, false, 0)
		"keydown":                  # held until its keyup (the target lock 'A' steers while it is down)
			events.post_key(s[2], s[3], true, false, 0)
		"keyup":
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
