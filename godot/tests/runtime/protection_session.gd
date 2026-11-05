extends SceneTree

## The copy-protection challenge, end to end on the runtime, headless. The smoke session never meets
## it: run_protection_dialog (ID05 0x560, from the overlay load, ID08 0x6) shows DLOG 1000 only
## when the registration does not match: record_code_index_equals(code, outB + 6), the code being
## TEXT 128's first long (build_protection_code_strings, ID05 0x3ba, reads it over DATA 128's) and
## the record encoded from the second. Here the session's own save folder holds a TEXT 128 whose
## code matches no record, so the challenge appears at start-up, and it is answered as a player
## types it: first a wrong word with a made-up unlock code (the 1001 alert, then the dialog
## again), then the right one (the unlock field emptied as well), read
## the way validate_protection_response (ID05 0x964) checks it: the entry of the A5 - 0xba table
## (0xc bytes: the stored word, its length, the three numbers) whose numbers are the challenge's
## (^0..^2, from ParamText), each byte less the key's at A5 - 0x2c & 0x7f. Each try first deletes
## what the field holds, and is typed in lowercase (get_dialog_item_text_upper uppercases what the
## game's ctype table marks with 0x80). It fails unless the dialog closes after the right word with
## the program's thread alive and nothing missing (machine.missing). Not in run_all.gd:
##
##   Godot --headless --path godot --script res://tests/runtime/protection_session.gd
##       [-- --coverage <file> [--merge]] [--master-disk]
##
## --coverage / --merge as smoke_session.gd's: the evidence merges this run in.
## --master-disk: the program run from its original floppy (MacMachine.volume_name "Hellcats",
##   ID05's A5 - 0xca and ID08's A5 - 0x16e2) with an unregistered TEXT 128 (code and other equal,
##   both 0): build_protection_code_strings writes a new pair (write_TEXT128_pair(0,
##   random_28bit_value)), which no record matches, so the challenge appears; once it is answered
##   load_overlay_from_resource refuses the master disk (stop alert 0x105, answered Return) and
##   quits. It passes when the program has quit by itself (ExitToShell).

const SAVES := "user://protection_session_resources"
const PORT_ORDER := ["ID01", "ID02", "ID03", "ID04", "ID05", "ID06", "ID07", "ID08", "ID09",
		"pacific_conflict"]
const END := 60.0

var MacMachine
var machine
var runner
var elapsed := 0.0
var coverage_path := ""
var answers := 0           ## words typed into the challenge
var passed := false
var _next_check := 2.0
var master_disk := false

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var at: int = args.find("--coverage")
	if at >= 0 and at + 1 < args.size():
		coverage_path = args[at + 1]
		Engine.set_meta("strict_coverage", {})
		for name in PORT_ORDER:
			(load("res://.coverage/%s.gd" % name) as Script).take_over_path("res://strict_port/code/%s.gd" % name)
	MacMachine = load("res://hellcats/runtime/mac_machine.gd")
	master_disk = args.has("--master-disk")
	if master_disk:
		MacMachine.volume_name = "Hellcats"
	var ResourceManager = load("res://hellcats/toolbox/resource_manager.gd")
	var Files = load("res://strict_port/ui/resource_files.gd")
	_clear(SAVES)
	DirAccess.make_dir_recursive_absolute(SAVES + "/text")
	var data: PackedByteArray = Files.load_bytes("TEXT", 128)
	for k in 8:                                          # a code that matches no record (or, on the
		data[k] = 0 if master_disk else 0x5a ^ k         # master disk, an unregistered equal pair)
	var f := FileAccess.open(SAVES + "/text/128.bin", FileAccess.WRITE)
	f.store_buffer(data)
	f.close()
	ResourceManager.saved_root = SAVES
	machine = MacMachine.new()
	if coverage_path != "":
		machine.coverage = Engine.get_meta("strict_coverage")
	machine.toolbox.quickdraw.glyphs.prepare()
	runner = load("res://hellcats/runtime/game_thread.gd").new(machine)
	runner.start()

func _process(delta: float) -> bool:
	elapsed += delta
	if elapsed > _next_check and (not passed or master_disk):
		_next_check = elapsed + 1.5
		_step()
	if elapsed < END and runner.is_running() and not (passed and elapsed > _next_check + 3.0):
		return false
	var ok: bool = passed and (machine.exited if master_disk else runner.is_running()) and machine.missing.is_empty()
	for key in machine.missing:
		print("  missing %s %s" % [key, machine.missing[key]])
	print("%s protection session: %d words typed, challenge %s" % ["PASS" if ok else "FAIL", answers,
			"passed" if passed else "not passed"])
	if ok and coverage_path != "":
		var seen: Dictionary = machine.coverage.duplicate()
		if OS.get_cmdline_user_args().has("--merge") and FileAccess.file_exists(coverage_path):
			for k in JSON.parse_string(FileAccess.get_file_as_string(coverage_path)):
				seen[k] = true
		var keys: Array = seen.keys()
		keys.sort()
		var out := FileAccess.open(coverage_path, FileAccess.WRITE)
		out.store_string(JSON.stringify(keys, "  ") + "\n")
		out.close()
		print("  %d routines, written to %s" % [keys.size(), coverage_path])
	machine.halting = true
	quit(0 if ok else 1)
	return true

## One look at the screen's front dialog: the challenge gets a word, the 1001 alert a Return.
func _step() -> void:
	var dm = machine.toolbox.dialogs
	var front: int = machine.toolbox.windows.front_window()
	var challenge: bool = false
	for d in dm.dialogs:
		if _is_challenge(dm, d):
			challenge = true
			if d == front:
				_answer(dm)
				return
	if challenge:                                        # the 1001 alert over it: dismiss
		_type([0x0d])
	elif answers >= 2:
		if passed and master_disk:
			_type([0x0d])                                # stop alert 0x105: the master disk refused
		passed = true
	else:
		_type([0x0d])                                    # start-up dialogs before the challenge

func _is_challenge(dm, d: int) -> bool:
	var items: Array = dm.dialogs[d]["items"]
	return items.size() >= 11 and dm._text(items[10]["handle"]).get_string_from_ascii().begins_with("Turn to page")

func _answer(dm) -> void:
	answers += 1
	var clear := PackedByteArray()
	clear.resize(32)
	clear.fill(0x08)                                     # what an earlier try left in the field, deleted
	if answers == 1:
		# A wrong word, and in the UNLOCK CODE field (item 4, Tab) a code that unlocks nothing: OK
		# decodes it (decode_code_to_long_a / _b, decode_base26_6chars) before checking the word.
		_type(clear + "wrong".to_ascii_buffer() + PackedByteArray([0x09]) + "abcdefghijkl".to_ascii_buffer()
				+ PackedByteArray([0x0d]))
		return
	var word: PackedByteArray = _expected_word(dm)
	print("  challenge %s: %s" % [[dm.params[0].get_string_from_ascii(), dm.params[1].get_string_from_ascii(),
			dm.params[2].get_string_from_ascii()], word.get_string_from_ascii()])
	assert(not word.is_empty(), "no table entry for the challenge")
	# The insertion point is still in the unlock field: emptied, then Tab back to the word.
	_type(clear + PackedByteArray([0x09]) + clear + word.get_string_from_ascii().to_lower().to_ascii_buffer()
			+ PackedByteArray([0x0d]))

## The word the table holds for the challenge's three numbers, as validate_protection_response
## compares it.
func _expected_word(dm) -> PackedByteArray:
	var m = machine.memory
	var a5: int = machine.A5
	var numbers: Array = []
	for k in 3:
		numbers.append(int(dm.params[k].get_string_from_ascii()))
	var table: int = m.read_u32(a5 - 0xba)
	for i in m.read_s16(a5 - 0xb6):
		var entry: int = table + i * 0xc
		if [m.read_s16(entry + 6), m.read_s16(entry + 8), m.read_s16(entry + 10)] != numbers:
			continue
		var stored: int = m.read_u32(entry)
		var out := PackedByteArray()
		for k in m.read_s16(entry + 4):
			out.append((m.read_u8(stored + k) - (m.read_u8(a5 - 0x2c + k) & 0x7f)) & 0xff)
		return out
	return PackedByteArray()

## Characters typed as key-down events (key code 0: the program reads the character).
func _type(chars: PackedByteArray) -> void:
	for c in chars:
		machine.toolbox.events.post_key(0x24 if c == 0x0d else 0, c, true, false, 0)
		machine.toolbox.events.post_key(0x24 if c == 0x0d else 0, c, false, false, 0)

func _clear(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_clear(path.path_join(sub))
	for file in dir.get_files():
		dir.remove(file)
	DirAccess.remove_absolute(path)
