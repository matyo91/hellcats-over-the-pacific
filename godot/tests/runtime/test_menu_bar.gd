extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://runtime/machine/mac_machine.gd")

## When the menu bar is repainted, as the Toolbox's: the game's event loop (ID02 0x2fd4) calls
## HiliteMenu(0) and update_menu_items (0x3174) on every pass, so neither may redraw the bar when
## nothing changed. HiliteMenu redraws only for a new title; EnableItem / DisableItem of item 0
## (the whole menu) change only the flags (set_menu_item_enabled, 0x3590, calls DrawMenuBar after
## them); DrawMenuBar repaints.
func run() -> bool:
	var machine = MacMachine.new()
	var traps: Dictionary = machine.toolbox.traps
	var apple: int = traps[0xa9bf].call([1])                 # GetMenu(1)
	traps[0xa935].call([0, apple])                          # InsertMenu(apple, 0)
	var ok := Assertions.assert_true(apple != 0, "GetMenu(1) returns the Apple menu")
	_mark(machine)
	traps[0xa938].call([0])                                 # HiliteMenu(0), none highlighted
	ok = Assertions.assert_true(_marked(machine), "HiliteMenu(0) with no title highlighted leaves the bar") and ok
	traps[0xa93a].call([0, apple])                          # DisableItem(apple, 0)
	traps[0xa939].call([0, apple])                          # EnableItem(apple, 0)
	ok = Assertions.assert_true(_marked(machine), "Enable / DisableItem of the whole menu leave the bar") and ok
	traps[0xa938].call([1])                                 # HiliteMenu(1)
	ok = Assertions.assert_true(not _marked(machine), "HiliteMenu of a new title redraws the bar") and ok
	_mark(machine)
	traps[0xa938].call([1])
	ok = Assertions.assert_true(_marked(machine), "HiliteMenu of the highlighted title leaves the bar") and ok
	traps[0xa937].call([])                                  # DrawMenuBar
	ok = Assertions.assert_true(not _marked(machine), "DrawMenuBar repaints the bar") and ok
	# MENU 3 (Edit) comes with its enableFlags 0: its title is drawn dimmed, in the mid grey.
	traps[0xa935].call([0, traps[0xa9bf].call([3])])
	traps[0xa937].call([])
	var gray: int = machine.toolbox.palettes.grayish()
	var seen := {}
	for y in range(2, 16):
		for x in range(0, 120):
			seen[machine.memory.read_u8(machine.SCREEN_BASE + y * machine.SCREEN_WIDTH + x)] = true
	ok = Assertions.assert_true(seen.has(gray) and gray != 0 and gray != 255, "a disabled menu's title is grey") and ok
	# The system font's own glyphs the menus draw: 0x11 the command sign before a key equivalent,
	# 0x12 the check mark CheckItem sets (update_menu_items' Options items), 0x14 the Apple logo.
	for c in [0x11, 0x12, 0x14]:
		var lit := 0
		for row in machine.toolbox.quickdraw.glyphs.glyph(c, 0, 12, 0)["bits"]:
			lit += row.count(true)
		ok = Assertions.assert_true(lit > 0, "system glyph 0x%x is drawn (%d pixels)" % [c, lit]) and ok
	return ok

## A pixel at the bar's right end, where no title is drawn, set to a colour the bar never uses.
func _mark(machine) -> void:
	machine.memory.write_u8(machine.SCREEN_BASE + 4 * machine.SCREEN_WIDTH + machine.SCREEN_WIDTH - 8, 0x5a)

func _marked(machine) -> bool:
	return machine.memory.read_u8(machine.SCREEN_BASE + 4 * machine.SCREEN_WIDTH + machine.SCREEN_WIDTH - 8) == 0x5a
