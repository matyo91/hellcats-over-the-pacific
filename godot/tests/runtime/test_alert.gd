extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://runtime/machine/mac_machine.gd")
const Files := preload("res://resources/ui/resource_files.gd")

## CautionAlert ($A988) on the End Mission confirmation (ALRT 259, confirm_end_mission, ID04 0x516),
## from the original resources: the ALRT's bounds (94, 150, 202, 472) and DITL 259 (1 Cancel,
## 2 End Mission, 3 the text); its first stage, 5, draws the default box and keeps item 1 (Cancel)
## the default. Return answers the default item; a click in End Mission's rect (75, 215, 96, 305,
## local to the alert) answers 2, but only when the button is let go inside it.
## The game's other ALRTs (256-258, 260, 261, 1001) open through their call sites' traps and answer
## Return with item 1.
func run() -> bool:
	var machine = MacMachine.new()
	var events = machine.toolbox.events
	var caution: Callable = machine.toolbox.traps[0xa988]
	events.post_key(0x24, 13, true, false, 0)
	var ok := Assertions.assert_equal(caution.call([0, 0x103]), 1, "Return answers the default item, Cancel")
	var at := Vector2i(150 + 260, 94 + 85)
	events.move_mouse(at)
	events.post_mouse(at, true)
	events.post_mouse(at, false)
	ok = Assertions.assert_equal(caution.call([0, 0x103]), 2, "a click on End Mission answers 2") and ok
	# Pressed in End Mission but let go outside it (TrackControl): no hit; Return then answers Cancel.
	events.post_mouse(at, true)
	events.post_mouse(Vector2i(20, 300), false)
	events.post_key(0x24, 13, true, false, 0)
	ok = Assertions.assert_equal(caution.call([0, 0x103]), 1, "let go outside End Mission: not a hit") and ok
	# Every other ALRT of the game, through the trap its call site uses: Return answers item 1, the
	# default of their stage 5.
	for c in [[0xa986, 256, "StopAlert, ID04 0x44e"], [0xa988, 257, "CautionAlert, ID04"],
			[0xa988, 258, "CautionAlert, ID02"], [0xa988, 260, "CautionAlert, ID04 0x560"],
			[0xa986, 261, "StopAlert, ID08"], [0xa985, 1001, "Alert, ID05"]]:
		events.post_key(0x24, 13, true, false, 0)
		var got: int = machine.toolbox.traps[c[0]].call([0, c[1]])
		ok = Assertions.assert_equal(got, 1, "ALRT %d (%s): Return answers item 1" % [c[1], c[2]]) and ok
	return run_param_text(machine) and run_hilite(machine) and ok

## ParamText as ID04 0x44e calls it before ALRT 256 (the file name, nil, nil, nil): DITL 256's text
## "Unable to open Hellcats scenery file '^0'." gets the name in place of ^0, from the DITL's bytes.
func run_param_text(machine) -> bool:
	var dm = machine.toolbox.dialogs
	var name: int = machine.toolbox.heap.new_ptr(32, true)
	var s: PackedByteArray = "Pacific Conflict".to_ascii_buffer()
	machine.memory.write_u8(name, s.size())
	for k in s.size():
		machine.memory.write_u8(name + 1 + k, s[k])
	machine.toolbox.traps[0xa98b].call([0, 0, 0, name])
	var ditl: PackedByteArray = Files.load_bytes("DITL", 256)
	var at: int = -1
	for k in ditl.size() - 1:
		if ditl[k] == 0x5e and ditl[k + 1] == 0x30:
			at = k
			break
	var ok := Assertions.assert_true(at > 0, "DITL 256 holds ^0")
	var line: String = dm._substitute(ditl.slice(at - 36, at + 3)).get_string_from_ascii()
	return Assertions.assert_true(line.ends_with("'Pacific Conflict'"), "^0 becomes the file name") and ok

## HiliteControl(button, 10) (inButton, as TrackControl sets it while the mouse is in the button)
## draws the button inverted; 0 draws it back. On DLOG 129's first button.
func run_hilite(machine) -> bool:
	var dm = machine.toolbox.dialogs
	var d: int = dm.get_new_dialog(129, 0, 0xffffffff)
	machine.toolbox.windows.show(d, true)
	dm.draw_dialog(d)
	var e: Dictionary = dm.dialogs[d]["items"][0]
	var box: Rect2i = e["box"]
	var g: Vector2i = box.position + Vector2i(4, box.size.y / 2) - machine.toolbox.quickdraw.port_bits(d)[2].position
	var at: int = g.y * machine.SCREEN_WIDTH + g.x
	var before: int = machine.screen_bytes()[at]
	machine.toolbox.traps[0xa95d].call([10, e["handle"]])
	var lit: int = machine.screen_bytes()[at]
	machine.toolbox.traps[0xa95d].call([0, e["handle"]])
	var ok := Assertions.assert_equal([before, lit], [0, 255], "a hilited button is drawn inverted")
	ok = Assertions.assert_equal(machine.screen_bytes()[at], 0, "unhilited, it is drawn back") and ok
	# Inactive (255) on the dialog's colour port: the title in the mid grey, the frame still black.
	machine.toolbox.traps[0xa95d].call([255, e["handle"]])
	var gray: int = machine.toolbox.palettes.grayish()
	var seen := {}
	var screen: PackedByteArray = machine.screen_bytes()
	var top_left: Vector2i = box.position - machine.toolbox.quickdraw.port_bits(d)[2].position
	for y in range(top_left.y, top_left.y + box.size.y):
		for x in range(top_left.x, top_left.x + box.size.x):
			seen[screen[y * machine.SCREEN_WIDTH + x]] = true
	ok = Assertions.assert_true(seen.has(gray) and seen.has(255), "an inactive button: grey title, black frame") and ok
	return ok
