extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://runtime/machine/mac_machine.gd")

## Typing in the Duty Roster (DLOG 130, run_duty_roster_dialog ID04 0x644): the current pilot's
## name field (item 15 + row) is selected with SelIText(d, item, 0, 1000), so a key replaces the
## name, as TextEdit replaces a selection; without a selection keys are added at the end; Tab
## moves to the next edit field (DITL order) and selects all of its text.
## And the summary's scroll bar under the Toolbox: SetCtlMax / SetCtlMin keep the Control Manager's
## range rules, TEScroll moves the text by the delta sync_text_scroll_to_control computes, and
## TECalText breaks lines by TextEdit's documented rules.
var machine
var traps: Dictionary
var dm

func run() -> bool:
	machine = MacMachine.new()
	traps = machine.toolbox.traps
	dm = machine.toolbox.dialogs
	var d: int = traps[0xa97c].call([0xffffffff, 0, 130])           # GetNewDialog(130, nil, -1)
	machine.toolbox.windows.show(d, true)
	var items: Array = dm.dialogs[d]["items"]
	_set_text(items[14]["handle"], "TOTO")
	_set_text(items[15]["handle"], "ACE")
	traps[0xa97e].call([1000, 0, 15, d])                            # SelIText(d, 15, 0, 1000)
	var ok := Assertions.assert_equal(_key(d, 0x4d, items[14]["handle"]), "M", "a key replaces the selected name")
	ok = Assertions.assert_equal(_key(d, 0x41, items[14]["handle"]), "MA", "then keys are added") and ok
	ok = Assertions.assert_equal(_key(d, 0x08, items[14]["handle"]), "M", "Backspace removes one") and ok
	_key(d, 0x09, items[15]["handle"])
	ok = Assertions.assert_equal(dm.dialogs[d]["edit"], 15, "Tab moves to item 16") and ok
	ok = Assertions.assert_equal(_key(d, 0x5a, items[15]["handle"]), "Z", "Tab selected all of its text") and ok
	# SetCtlMax below the min: the max becomes the min (the Control Manager's rule; the summary clamps
	# its own max to >= 0 first, ID04 0x1562, so it never passes one).
	var bar: int = dm.new_control(d, Rect2i(10, 10, 16, 80), PackedByteArray(), true, 0, 0, 10, 16, 0)
	traps[0xa965].call([0xfffd, bar])                               # SetCtlMax(bar, -3)
	ok = Assertions.assert_equal([traps[0xa962].call([bar]), traps[0xa960].call([bar])], [0, 0],
			"a max below the min is stored as the min, the value kept in range") and ok
	traps[0xa965].call([10, bar])                                   # SetCtlMax(bar, 10)
	traps[0xa964].call([12, bar])                                   # SetCtlMin(bar, 12): above the max
	ok = Assertions.assert_equal([traps[0xa961].call([bar]), traps[0xa962].call([bar]), traps[0xa960].call([bar])],
			[12, 10, 12], "a min above the max: the max kept, the value raised to the min") and ok
	return run_te_scroll() and ok

## TEScroll(0, dv, h) moves destRect by dv: with sync_text_scroll_to_control's delta (ID04 0x150e:
## viewRect.top - destRect.top - value * lineHeight), the first visible line is the bar's value.
func run_te_scroll() -> bool:
	var m = machine.memory
	var rects: int = machine.toolbox.heap.new_ptr(16, true)
	machine.toolbox.quickdraw.write_rect(rects, Rect2i(20, 40, 200, 100))       # destRect
	machine.toolbox.quickdraw.write_rect(rects + 8, Rect2i(20, 40, 200, 100))   # viewRect
	var h: int = traps[0xa9d2].call([rects + 8, rects])                          # TENew(dest, view)
	var te: int = m.read_u32(h)
	var line: int = m.read_s16(te + 0x18)
	var value: int = 3
	var delta: int = (m.read_s16(te + 8) - m.read_s16(te)) - value * line
	traps[0xa9dd].call([h, delta & 0xffff, 0])                                    # TEScroll(0, delta, h)
	te = m.read_u32(h)
	var ok := Assertions.assert_true(line > 0, "TENew sets the lineHeight from the port's font (%d)" % line)
	ok = Assertions.assert_equal(m.read_s16(te), 40 - value * line, "destRect.top = viewRect.top - 3 lines") and ok
	return run_cal_text(h) and ok

## TECalText's line starts, by TextEdit's rules: a line breaks after the last space that fits (the
## spaces hang past the edge), a word wider than the line breaks at a character, CR ends a line.
func run_cal_text(h: int) -> bool:
	var m = machine.memory
	var te_rect: int = m.read_u32(h)
	var w: int = machine.toolbox.quickdraw.glyphs.width("WW".to_ascii_buffer(), m.read_s16(te_rect + 0x4a),
			m.read_s16(te_rect + 0x50), m.read_u8(te_rect + 0x4c))     # in the record's font
	machine.toolbox.quickdraw.write_rect(te_rect, Rect2i(0, 0, w, 100))        # two W's wide
	var s: PackedByteArray = "WW  WWWWW\rW".to_ascii_buffer()
	var p: int = machine.toolbox.heap.new_ptr(s.size(), true)
	for k in s.size():
		m.write_u8(p + k, s[k])
	traps[0xa9cf].call([h, s.size(), p])                                          # TESetText(text, length, h)
	traps[0xa9d0].call([h])                                                       # TECalText(h)
	var te: int = m.read_u32(h)
	var starts: Array = []
	for k in m.read_u16(te + 0x5e) + 1:
		starts.append(m.read_u16(te + 0x60 + 2 * k))
	return Assertions.assert_equal(starts, [0, 4, 6, 8, 10, 11], "line starts: hanging spaces, a broken word, CR")

func _set_text(h: int, s: String) -> void:
	var p: int = machine.toolbox.heap.new_ptr(256, true)
	var b: PackedByteArray = s.to_ascii_buffer()
	machine.memory.write_u8(p, b.size())
	for k in b.size():
		machine.memory.write_u8(p + 1 + k, b[k])
	traps[0xa98f].call([p, h])                                      # SetIText(h, text)

## One keyDown through the dialog's default handling; the field's text after it (GetIText).
func _key(d: int, ch: int, h: int) -> String:
	var event: int = machine.toolbox.heap.new_ptr(16, true)
	machine.memory.write_u16(event, 3)
	machine.memory.write_u32(event + 2, ch)
	dm._handle(d, event)
	var p: int = machine.toolbox.heap.new_ptr(256, true)
	traps[0xa990].call([p, h])                                      # GetIText(h, VAR text)
	var out := PackedByteArray()
	for k in machine.memory.read_u8(p):
		out.append(machine.memory.read_u8(p + 1 + k))
	return out.get_string_from_ascii()
