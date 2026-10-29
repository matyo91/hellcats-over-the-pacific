class_name StrictID04
extends RefCounted
## Strict translations owned by CODE segment 04 (ID04.bin; address = file offset, 4-byte header):
## dialogs, the roster and scores, the mission summary and the map. The sole provenance and verification record lives in mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`).
## Calls leaving the segment go through `_jt` / `_trap` (see StrictID02), filled by tests with
## logging stand-ins.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const TRAP_GET_DITEM: int = 0xa98d       ## GetDItem(dialog, item, VAR type, VAR handle, VAR box)
const TRAP_SET_DITEM: int = 0xa98e
const TRAP_SET_ITEXT: int = 0xa98f
const TRAP_HILITE_CONTROL: int = 0xa95d
const TRAP_HIDE_CONTROL: int = 0xa958
const TRAP_SHOW_CONTROL: int = 0xa957
const TRAP_SET_CTITLE: int = 0xa95f
const TRAP_GET_CTL_VALUE: int = 0xa960
const TRAP_SET_PORT: int = 0xa873
const TRAP_INSET_RECT: int = 0xa8a9
const TRAP_PEN_SIZE: int = 0xa89b
const TRAP_FRAME_RECT: int = 0xa8a1
const TRAP_FRAME_ROUND_RECT: int = 0xa8b0
const TRAP_FILL_RECT: int = 0xa8a5
const TRAP_NEW_WINDOW: int = 0xa913
const TRAP_SHOW_WINDOW: int = 0xa915
const TRAP_HIDE_WINDOW: int = 0xa916
const TRAP_PARAM_TEXT: int = 0xa98b
const TRAP_STOP_ALERT: int = 0xa986
const TRAP_CAUTION_ALERT: int = 0xa988
const JT_POSITION_ALERT: int = 0x47a     ## ID02 position_alert_template (C, word id)
const JT_TEMP_WINDOW_BODY: int = 0x4aa   ## C, no arguments: drawn while the temporary window shows

var memory
var a5: int = 0
var a7: int = 0
var jt_routines: Dictionary = {}
var traps: Dictionary = {}
var code_routines: Dictionary = {}

func _init(memory_68k = null, a5_value: int = 0) -> void:
	memory = memory_68k
	a5 = a5_value

func _jt(offset: int, args: Array) -> int:
	assert(jt_routines.has(offset), "jump-table slot $%x has no routine" % offset)
	return jt_routines[offset].call(args)

func _trap(word: int, args: Array) -> int:
	assert(traps.has(word), "A-line trap %04x has no routine" % word)
	return traps[word].call(args)

## GetDItem into this routine's frame: the type word at type_ptr, the handle at handle_ptr and the
## box (8 bytes) at box_ptr.
func _get_ditem(dialog: int, item: int, type_ptr: int, handle_ptr: int, box_ptr: int) -> void:
	_trap(TRAP_GET_DITEM, [box_ptr, handle_ptr, type_ptr, item & 0xffff, C68kScript.u32(dialog)])

func _box(p: int) -> Array:
	return [memory.read_u32(p), memory.read_u32(p + 4)]

## The handle of a dialog item, through GetDItem into the standard frame (type -2, handle -6, box
## -0xe below A6).
func _item_handle(dialog: int, item: int) -> int:
	assert(a7 != 0, "dialog item helpers need a7 (GetDItem writes into their frame)")
	var a6: int = a7 - 4
	_get_ditem(dialog, item, a6 - 2, a6 - 6, a6 - 0xe)
	return memory.read_u32(a6 - 6)

## 0x6 / 0x2e: HiliteControl(item control, 255 / 0).
func disable_dialog_control(dialog: int, item: int) -> void:
	_trap(TRAP_HILITE_CONTROL, [0xff, _item_handle(dialog, item)])

func enable_dialog_control(dialog: int, item: int) -> void:
	_trap(TRAP_HILITE_CONTROL, [0, _item_handle(dialog, item)])

## 0x54 / 0x78: HideControl / ShowControl of the item's control.
func hide_dialog_control(dialog: int, item: int) -> void:
	_trap(TRAP_HIDE_CONTROL, [_item_handle(dialog, item)])

func show_dialog_control(dialog: int, item: int) -> void:
	_trap(TRAP_SHOW_CONTROL, [_item_handle(dialog, item)])

## 0x9c: SetIText(item handle, text).
func set_dialog_item_text(dialog: int, item: int, text: int) -> void:
	_trap(TRAP_SET_ITEXT, [C68kScript.u32(text), _item_handle(dialog, item)])

## 0xc4: SetCTitle(item control, title).
func set_dialog_control_title(dialog: int, item: int, title: int) -> void:
	_trap(TRAP_SET_CTITLE, [C68kScript.u32(title), _item_handle(dialog, item)])

## 0xec: SetDItem(dialog, item, its type, proc, its box): the item becomes a user item drawn by proc.
func set_dialog_user_item_proc(dialog: int, item: int, proc: int) -> void:
	_item_handle(dialog, item)
	var a6: int = a7 - 4
	_trap(TRAP_SET_DITEM, [_box(a6 - 0xe), C68kScript.u32(proc), memory.read_u16(a6 - 2), item & 0xffff, C68kScript.u32(dialog)])

## 0x120: the item's box framed 2 pixels out (InsetRect -2, a 1 x 1 pen) in the dialog's port,
## the current port (A5 - 0x160c) restored.
func frame_dialog_item_box(dialog: int, item: int) -> void:
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	_item_handle(dialog, item)
	var a6: int = a7 - 4
	_trap(TRAP_INSET_RECT, [0xfffe, 0xfffe, _box(a6 - 0xe)])
	_trap(TRAP_PEN_SIZE, [1, 1])
	_trap(TRAP_FRAME_RECT, [_box(a6 - 0xe)])
	_trap(TRAP_SET_PORT, [saved])

## 0x16e (a user item procedure, Pascal): the default button (item A5 - 0x225e, not the item drawn)
## outlined: a 3 x 3 pen, InsetRect -4, FrameRoundRect 16 x 16.
func draw_default_button_outline(dialog: int, _item: int) -> void:
	_item_handle(dialog, memory.read_u16(C68kScript.u32(a5 - 0x225e)))
	var a6: int = a7 - 4
	_trap(TRAP_PEN_SIZE, [3, 3])
	_trap(TRAP_INSET_RECT, [0xfffc, 0xfffc, _box(a6 - 0xe)])
	_trap(TRAP_FRAME_ROUND_RECT, [0x10, 0x10, _box(a6 - 0xe)])

## 0x1f2 (a user item procedure, Pascal): the item's box filled with the grey pattern A5 - 0x1624.
func draw_grey_user_item(dialog: int, item: int) -> void:
	_item_handle(dialog, item)
	var a6: int = a7 - 4
	_trap(TRAP_FILL_RECT, [C68kScript.u32(a5 - 0x1624), _box(a6 - 0xe)])

## 0x220: the percent bar in the item's box: the left part (percent A5 - 0x225c of the width,
## MULU.L / DIVS.L 100) filled with A5 - 0x1634, the rest with A5 - 0x1614, and the box framed 1
## pixel out.
func draw_percent_bar_item(dialog: int, item: int) -> void:
	assert(a7 != 0, "draw_percent_bar_item needs a7 (GetDItem writes into its frame)")
	var a6: int = a7 - 4
	var box: int = a6 - 0x12
	_get_ditem(dialog, item, a6 - 2, a6 - 0xa, box)
	memory.write_u32(a6 - 0x1a, memory.read_u32(box))
	memory.write_u32(a6 - 0x16, memory.read_u32(box + 4))
	var right: int = memory.read_u16(box + 6)
	var width: int = C68kScript.u16(right - memory.read_u16(box + 2))
	var filled: int = C68kScript.u32(C68kScript.u32(memory.read_s16(C68kScript.u32(a5 - 0x225c))) * C68kScript.u32(C68kScript.s16(width)))
	var cut: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(filled), 0x64) + memory.read_s16(box + 2))
	memory.write_u16(box + 6, cut)
	_trap(TRAP_FILL_RECT, [C68kScript.u32(a5 - 0x1634), _box(box)])
	memory.write_u16(box + 2, C68kScript.u16(cut + 1))
	memory.write_u16(box + 6, right)
	_trap(TRAP_FILL_RECT, [C68kScript.u32(a5 - 0x1614), _box(box)])
	_trap(TRAP_INSET_RECT, [0xffff, 0xffff, _box(a6 - 0x1a)])
	_trap(TRAP_PEN_SIZE, [1, 1])
	_trap(TRAP_FRAME_RECT, [_box(a6 - 0x1a)])

## 0x2c0 (a user item procedure, Pascal): draw_percent_bar_item.
func percent_bar_user_item_proc(dialog: int, item: int) -> void:
	var entry: int = a7
	a7 = entry - 4 - 6 - 4
	draw_percent_bar_item(dialog, item)
	a7 = entry

## 0x362: the first of `count` radio buttons (item numbers at `items`) whose control value is set;
## -1 when none is.
func get_radio_group_selection(dialog: int, items: int, count: int) -> int:
	assert(a7 != 0, "get_radio_group_selection needs a7 (GetDItem writes into its frame)")
	var a6: int = a7 - 4
	var i: int = 0
	while i < C68kScript.s16(count):
		var item: int = memory.read_u16(C68kScript.u32(items + 2 * i))
		_get_ditem(dialog, item, a6 - 4, a6 - 8, a6 - 0x10)
		if _trap(TRAP_GET_CTL_VALUE, [memory.read_u32(a6 - 8)]) & 0xffff != 0:
			return item
		i += 1
	return 0xffffffff

## 0x3c2: the temporary window (made once, A5 - 0x225a: NewWindow over the main screen rect, kept at
## A5 - 0x14be, inset by 100, title A5 - 0xe4e, document proc 3, in front, with a go-away box)
## shown as the current port while the routine at JT $4aa runs, then hidden.
func run_with_temporary_window() -> void:
	if memory.read_u32(C68kScript.u32(a5 - 0x225a)) == 0:
		assert(a7 != 0, "run_with_temporary_window needs a7 (its frame holds the window rect)")
		var a6: int = a7 - 4
		memory.write_u32(C68kScript.u32(a5 - 0x14be), memory.read_u32(C68kScript.u32(a5 - 0x1680)))
		memory.write_u32(C68kScript.u32(a5 - 0x14ba), memory.read_u32(C68kScript.u32(a5 - 0x167c)))
		memory.write_u32(a6 - 8, memory.read_u32(C68kScript.u32(a5 - 0x14be)))
		memory.write_u32(a6 - 4, memory.read_u32(C68kScript.u32(a5 - 0x14ba)))
		_trap(TRAP_INSET_RECT, [0x64, 0x64, _box(a6 - 8)])
		var window: int = C68kScript.u32(_trap(TRAP_NEW_WINDOW, [0, 1, 0xffffffff, 3, 1, memory.read_u32(C68kScript.u32(a5 - 0xe4e)),
				_box(a6 - 8), 0]))
		memory.write_u32(C68kScript.u32(a5 - 0x225a), window)
	var w: int = memory.read_u32(C68kScript.u32(a5 - 0x225a))
	_trap(TRAP_SET_PORT, [w])
	_trap(TRAP_SHOW_WINDOW, [memory.read_u32(C68kScript.u32(a5 - 0x225a))])
	_jt(JT_TEMP_WINDOW_BODY, [])
	_trap(TRAP_HIDE_WINDOW, [memory.read_u32(C68kScript.u32(a5 - 0x225a))])

## 0x44e: the message in stop alert 0x100 (placed with position_alert_template through JT $47a);
## returns the item hit.
func show_scenery_open_error_alert(message: int) -> int:
	_trap(TRAP_PARAM_TEXT, [0, 0, 0, C68kScript.u32(message)])
	_jt(JT_POSITION_ALERT, [0x100])
	return _trap(TRAP_STOP_ALERT, [0, 0x100]) & 0xffff

## 0x4f0 / 0x560: caution alerts 0x101 (save changes?) and 0x104 (erase the high scores?).
func ask_save_changes() -> int:
	return _caution(0x101)

func confirm_erase_high_scores() -> int:
	return _caution(0x104)

func _caution(id: int) -> int:
	_jt(JT_POSITION_ALERT, [id])
	return _trap(TRAP_CAUTION_ALERT, [0, id]) & 0xffff

## 0x516: in a running mission (state A5 - 0x12f8 from 3, A5 - 0x14c4 clear) with something to
## report (get_mission_kill_report_state), caution alert 0x103's answer; otherwise 2.
func confirm_end_mission() -> int:
	if memory.read_s16(C68kScript.u32(a5 - 0x12f8)) < 3 or memory.read_u16(C68kScript.u32(a5 - 0x14c4)) != 0:
		return 2
	if get_mission_kill_report_state() & 0xffff == 0:
		return 2
	return _caution(0x103)

## 0x18e0: 0 in game state 2; 2 when A5 - 0x14c0 is clear and A5 - 0x12ba is positive; 1 when any
## of the ten kill counts at A5 - 0x12ce is set; else 0.
func get_mission_kill_report_state() -> int:
	if memory.read_s16(C68kScript.u32(a5 - 0x12f8)) == 2:
		return 0
	if memory.read_u16(C68kScript.u32(a5 - 0x14c0)) == 0 and memory.read_s16(C68kScript.u32(a5 - 0x12ba)) > 0:
		return 2
	for i in 0xa:
		if memory.read_u16(C68kScript.u32(a5 - 0x12ce + 2 * i)) != 0:
			return 1
	return 0

## 0x588: a pilot's score: the sum of his twelve tallies (words +0x28 of his 64-byte roster record
## in the handle A5 - 0x13a8) times their weights (words at A5 - 0xf5e), MULU.L of the signed words.
func compute_pilot_score(pilot: int) -> int:
	var rec: int = C68kScript.u32(C68kScript.lsl32(C68kScript.u32(C68kScript.s16(pilot)), 6) + memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13a8))))
	var sum: int = 0
	for i in 0xc:
		var tally: int = C68kScript.u32(memory.read_s16(C68kScript.u32(rec + 2 * i + 0x28)))
		var weight: int = C68kScript.u32(memory.read_s16(C68kScript.u32(a5 - 0xf5e + 2 * i)))
		sum = C68kScript.u32(sum + C68kScript.u32(tally * weight))
	return sum

const A5_TE: int = -0x223a          ## TEHandle of the scrolling text item
const A5_SCROLL_BAR: int = -0x2236  ## its scroll bar control
const A5_VISIBLE_LINES: int = -0x2232
const JT_STRING_ORDER: int = 0x2ea  ## IUCompString-like Pascal function (a, b): word
const JT_HLOCK: int = 0x272
const JT_HUNLOCK: int = 0x27a
const JT_STRLEN: int = 0x522
const JT_SYS_ENVIRONS: int = 0x1f2  ## SysEnvirons(version, VAR rec): OSErr
const JT_CAUTION_NUMBER: int = 0x4ba ## ID02 show_caution_alert_with_number (C: message, number word)
const TRAP_ERASE_RECT: int = 0xa8a3
const TRAP_TE_UPDATE: int = 0xa9d3
const TRAP_TE_SCROLL: int = 0xa9dd
const TRAP_TE_CAL_TEXT: int = 0xa9d0
const TRAP_TE_NEW: int = 0xa9d2
const TRAP_TE_DISPOSE: int = 0xa9cd
const TRAP_TE_INSERT: int = 0xa9de
const TRAP_SET_CTL_MAX: int = 0xa965
const TRAP_SET_CTL_VALUE: int = 0xa963
const TRAP_NEW_CONTROL: int = 0xa954
const TRAP_DISPOSE_CONTROL: int = 0xa955
const TRAP_GET_PORT: int = 0xa874
const TRAP_OFFSET_RECT: int = 0xa8a8
const TRAP_CHANGED_RESOURCE: int = 0xa9aa
const TRAP_WRITE_RESOURCE: int = 0xa9b0
const TRAP_GET_NAMED_RESOURCE: int = 0xa9a1
const TRAP_RELEASE_RESOURCE: int = 0xa9a3
const TRAP_SND_NEW_CHANNEL: int = 0xa807
const TRAP_SND_PLAY: int = 0xa805
const TRAP_SND_DISPOSE_CHANNEL: int = 0xa801
const TRAP_SYSTEM_TASK: int = 0xa9b4
const TRAP_GET_NEXT_EVENT: int = 0xa970
const TRAP_TEXT_SIZE: int = 0xa88a
const TRAP_STRING_WIDTH: int = 0xa88c
const TRAP_GET_FONT_INFO: int = 0xa88b
const TRAP_MOVE_TO: int = 0xa893
const TRAP_DRAW_STRING: int = 0xa884

func _roster(pilot: int) -> int:
	return C68kScript.u32(C68kScript.lsl32(C68kScript.u32(C68kScript.s16(pilot)), 6) + memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13a8))))

## 0xf4e: the twenty pilots ranked: scores[i] = compute_pilot_score(i), order[i] = i, then for each
## pair (i, j > i) the entries swap when j scores more, or scores the same and either i has no
## name, or both have names and j's does not sort after i's (JT $2ea >= 0).
func rank_pilots_by_score(scores: int, order: int) -> void:
	for i in 0x14:
		memory.write_u32(C68kScript.u32(scores + 4 * i), compute_pilot_score(i))
		memory.write_u16(C68kScript.u32(order + 2 * i), i)
	for i in 0x13:
		for j in range(i + 1, 0x14):
			var a: int = _roster(memory.read_u16(C68kScript.u32(order + 2 * i)))
			var b: int = _roster(memory.read_u16(C68kScript.u32(order + 2 * j)))
			var si: int = memory.read_s32(C68kScript.u32(scores + 4 * i))
			var sj: int = memory.read_s32(C68kScript.u32(scores + 4 * j))
			var swap: bool = sj > si
			if not swap and sj == si:
				if memory.read_u8(a) == 0:
					swap = true
				elif memory.read_u8(b) != 0:
					swap = C68kScript.s16(_jt(JT_STRING_ORDER, [b, a])) >= 0
			if swap:
				memory.write_u32(C68kScript.u32(scores + 4 * j), C68kScript.u32(si))
				memory.write_u32(C68kScript.u32(scores + 4 * i), C68kScript.u32(sj))
				var oj: int = memory.read_u16(C68kScript.u32(order + 2 * j))
				memory.write_u16(C68kScript.u32(order + 2 * j), memory.read_u16(C68kScript.u32(order + 2 * i)))
				memory.write_u16(C68kScript.u32(order + 2 * i), oj)

## 0x1106: a roster record cleared: words +0x20..+0x26, the twelve tallies, the name length.
func reset_pilot_record(pilot: int) -> void:
	var rec: int = _roster(pilot)
	for off in [0x22, 0x20, 0x24, 0x26]:
		memory.write_u16(rec + off, 0)
	for i in 0xc:
		memory.write_u16(rec + 0x28 + 2 * i, 0)
	memory.write_u8(rec, 0)

## 0x116a: with the roster handle locked, active pilots (+0x20) after the first ten in rank order are
## reset; when any was, the roster resource is marked changed and written.
func prune_inactive_pilots_beyond_ten(order: int) -> void:
	_jt(JT_HLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])
	var kept: int = 0
	var changed: bool = false
	for i in 0x14:
		var pilot: int = memory.read_u16(C68kScript.u32(order + 2 * i))
		if memory.read_u16(_roster(pilot) + 0x20) == 0:
			continue
		var old: int = kept
		kept += 1
		if old >= 0xa:
			reset_pilot_record(pilot)
			changed = true
	_jt(JT_HUNLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])
	if changed:
		_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])
		_trap(TRAP_WRITE_RESOURCE, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])

## 0x14a0: the scrolling text item: its view erased, TEUpdate over the item box, the box framed 2
## pixels out.
func draw_scrolling_text_item(dialog: int, item: int) -> void:
	assert(a7 != 0, "draw_scrolling_text_item needs a7 (GetDItem writes into its frame)")
	var a6: int = a7 - 4
	_get_ditem(dialog, item, a6 - 2, a6 - 0xa, a6 - 0x12)
	var te: int = memory.read_u32(C68kScript.u32(a5 + A5_TE))
	_trap(TRAP_ERASE_RECT, [C68kScript.u32(memory.read_u32(te) + 8)])
	_trap(TRAP_TE_UPDATE, [te, _box(a6 - 0x12)])
	_trap(TRAP_INSET_RECT, [0xfffe, 0xfffe, _box(a6 - 0x12)])
	_trap(TRAP_PEN_SIZE, [1, 1])
	_trap(TRAP_FRAME_RECT, [_box(a6 - 0x12)])

## 0x14f2 (a user item procedure, Pascal): draw_scrolling_text_item.
func scrolling_text_user_item_proc(dialog: int, item: int) -> void:
	var entry: int = a7
	a7 = entry - 4 - 6 - 4
	draw_scrolling_text_item(dialog, item)
	a7 = entry

## 0x150e: TEScroll by (view top - dest top) - scroll value * line height, when non-zero.
func sync_text_scroll_to_control() -> void:
	var te: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 + A5_TE)))
	var offset: int = C68kScript.u16(memory.read_u16(te + 8) - memory.read_u16(te))
	var value: int = _trap(TRAP_GET_CTL_VALUE, [memory.read_u32(C68kScript.u32(a5 + A5_SCROLL_BAR))])
	te = memory.read_u32(memory.read_u32(C68kScript.u32(a5 + A5_TE)))
	var shown: int = C68kScript.u16(C68kScript.s16(value) * memory.read_s16(te + 0x18))
	var delta: int = C68kScript.u16(offset - shown)
	if delta != 0:
		_trap(TRAP_TE_SCROLL, [memory.read_u32(C68kScript.u32(a5 + A5_TE)), delta, 0])

## 0x1562: the scroll bar's maximum = text lines - visible lines (0 when not positive).
func update_scroll_bar_maximum() -> void:
	var te: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 + A5_TE)))
	var extra: int = C68kScript.s16(memory.read_u16(te + 0x5e) - memory.read_u16(C68kScript.u32(a5 + A5_VISIBLE_LINES)))
	_trap(TRAP_SET_CTL_MAX, [extra if extra > 0 else 0, memory.read_u32(C68kScript.u32(a5 + A5_SCROLL_BAR))])

## 0x158c: the maximum updated and the text synced; when the selection start lies outside the
## visible lines (line starts +0x60), the scroll value becomes its line + 1 - half the visible lines.
func scroll_text_to_show_selection() -> void:
	update_scroll_bar_maximum()
	sync_text_scroll_to_control()
	var handle: int = memory.read_u32(C68kScript.u32(a5 + A5_TE))
	var top: int = C68kScript.s16(_trap(TRAP_GET_CTL_VALUE, [memory.read_u32(C68kScript.u32(a5 + A5_SCROLL_BAR))]))
	var bottom: int = C68kScript.s16(top + memory.read_u16(C68kScript.u32(a5 + A5_VISIBLE_LINES)))
	var sel: int = memory.read_s16(memory.read_u32(handle) + 0x20)
	if sel >= _line_start(handle, top) and sel < _line_start(handle, bottom):
		return
	var line: int = 0
	while memory.read_s16(memory.read_u32(handle) + 0x20) >= _line_start(handle, line):
		line += 1
	var half: int = C68kScript.divs_trunc(memory.read_s16(C68kScript.u32(a5 + A5_VISIBLE_LINES)), 2)
	_trap(TRAP_SET_CTL_VALUE, [C68kScript.u16(line - half), memory.read_u32(C68kScript.u32(a5 + A5_SCROLL_BAR))])
	sync_text_scroll_to_control()

func _line_start(handle: int, line: int) -> int:
	return memory.read_s16(C68kScript.u32(memory.read_u32(handle) + 2 * line + 0x60))

## 0x1638: the text view set to the box (16 pixels left for the scroll bar), cut to whole lines
## (visible lines kept at A5 - 0x2232), the destination's right edge matched, TECalText.
func fit_text_view_to_box(box: int) -> void:
	var handle: int = memory.read_u32(C68kScript.u32(a5 + A5_TE))
	var te: int = memory.read_u32(handle)
	memory.write_u32(te + 8, memory.read_u32(C68kScript.u32(box)))
	memory.write_u32(te + 0xc, memory.read_u32(C68kScript.u32(box + 4)))
	memory.write_u16(te + 0xe, C68kScript.u16(memory.read_u16(te + 0xe) - 0x10))
	var lines: int = C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_u16(te + 0xc) - memory.read_u16(te + 8))), memory.read_s16(te + 0x18))
	memory.write_u16(C68kScript.u32(a5 + A5_VISIBLE_LINES), C68kScript.u16(lines))
	memory.write_u16(te + 0xc, C68kScript.u16(C68kScript.s16(memory.read_u16(te + 0x18)) * C68kScript.s16(lines) + memory.read_u16(te + 8)))
	memory.write_u16(te + 6, memory.read_u16(te + 0xe))
	_trap(TRAP_TE_CAL_TEXT, [handle])

## 0x16c4 (a control action procedure, Pascal): for a part (ID01's dense switch on 20..23: up -1,
## down +1, page up / down by the visible lines - 1) the scroll value moves and the text follows.
## (Other non-zero parts would add an unset frame word in the original.)
func scroll_bar_action_proc(control: int, part: int) -> void:
	var p: int = C68kScript.s16(part)
	if p == 0:
		return
	var te: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 + A5_TE)))
	var page: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(memory.read_u16(te + 0xc) - memory.read_u16(te + 8))), memory.read_s16(te + 0x18)) - 1)
	assert(p >= 0x14 and p <= 0x17, "scroll_bar_action_proc: part %d reads an unset frame word in the original" % p)
	var delta: int = [-1, 1, -page, page][p - 0x14]
	var value: int = _trap(TRAP_GET_CTL_VALUE, [C68kScript.u32(control)])
	_trap(TRAP_SET_CTL_VALUE, [C68kScript.u16(value + delta), C68kScript.u32(control)])
	sync_text_scroll_to_control()

## 0x17e6: the scrolling text item: its box (GetDItem) gets a TextEdit record (TENew, A5 - 0x223a)
## and a scroll bar (NewControl procID 16 in the box's right 16 pixels, 2 out at top and bottom,
## title A5 - 0x213c, A5 - 0x2236); the view is fitted and the item drawn by A5 + 0x92; the port is
## restored.
func create_scrolling_text_item(dialog: int, item: int) -> void:
	assert(a7 != 0, "create_scrolling_text_item needs a7 (its frame holds the rects and port)")
	var entry: int = a7
	var a6: int = entry - 4
	_get_ditem(dialog, item, a6 - 2, a6 - 0xa, a6 - 0x12)
	memory.write_u32(a6 - 0x1a, memory.read_u32(a6 - 0x12))
	memory.write_u32(a6 - 0x16, memory.read_u32(a6 - 0xe))
	memory.write_u16(a6 - 0x18, C68kScript.u16(memory.read_u16(a6 - 0xc) - 0x10))
	_trap(TRAP_INSET_RECT, [0xfffe, 0, _box(a6 - 0x1a)])
	_trap(TRAP_OFFSET_RECT, [0, 2, _box(a6 - 0x1a)])
	_trap(TRAP_GET_PORT, [a6 - 0x1e])
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	memory.write_u32(C68kScript.u32(a5 + A5_TE), C68kScript.u32(_trap(TRAP_TE_NEW, [_box(a6 - 0x12), _box(a6 - 0x12)])))
	memory.write_u32(C68kScript.u32(a5 + A5_SCROLL_BAR), C68kScript.u32(_trap(TRAP_NEW_CONTROL, [0, 0x10, 0, 0, 0, 1,
			C68kScript.u32(a5 - 0x213c), _box(a6 - 0x1a), C68kScript.u32(dialog)])))
	a7 = entry - 4 - 0x1e - 4 - 4
	fit_text_view_to_box(a6 - 0x12)
	a7 = entry - 4 - 0x1e - 0xa - 4
	set_dialog_user_item_proc(dialog, item, C68kScript.u32(a5 + 0x92))
	a7 = entry
	_trap(TRAP_SET_PORT, [memory.read_u32(a6 - 0x1e)])

## 0x189c: TEDispose and DisposeControl of the scrolling text item.
func dispose_scrolling_text_item() -> void:
	_trap(TRAP_TE_DISPOSE, [memory.read_u32(C68kScript.u32(a5 + A5_TE))])
	_trap(TRAP_DISPOSE_CONTROL, [memory.read_u32(C68kScript.u32(a5 + A5_SCROLL_BAR))])

## 0x18b0: the C string `line` and a newline (A5 - 0x213a) inserted into the text, which scrolls
## to show it.
func append_line_to_scrolling_text(_unused_8: int, _unused_c: int, line: int) -> void:
	var length: int = C68kScript.u32(_jt(JT_STRLEN, [C68kScript.u32(line)]))
	_trap(TRAP_TE_INSERT, [memory.read_u32(C68kScript.u32(a5 + A5_TE)), length, C68kScript.u32(line)])
	_trap(TRAP_TE_INSERT, [memory.read_u32(C68kScript.u32(a5 + A5_TE)), 1, C68kScript.u32(a5 - 0x213a)])
	scroll_text_to_show_selection()

## 0x3124: the 'snd ' named at A5 - 0x2128 loaded (A5 - 0x2156) and locked, a sampled-sound channel
## made (SndNewChannel, init 0x80, into A5 - 0x2152) and the sound played asynchronously.
func play_named_sound_async() -> void:
	memory.write_u32(C68kScript.u32(a5 - 0x2156), 0)
	memory.write_u32(C68kScript.u32(a5 - 0x2152), 0)
	var h: int = C68kScript.u32(_trap(TRAP_GET_NAMED_RESOURCE, [C68kScript.u32(a5 - 0x2128), 0x736e6420]))
	memory.write_u32(C68kScript.u32(a5 - 0x2156), h)
	if h == 0:
		return
	_jt(JT_HLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x2156))])
	_trap(TRAP_SND_NEW_CHANNEL, [0, 0x80, 0, C68kScript.u32(a5 - 0x2152)])
	if memory.read_u32(C68kScript.u32(a5 - 0x2152)) == 0:
		return
	_trap(TRAP_SND_PLAY, [1, memory.read_u32(C68kScript.u32(a5 - 0x2156)), memory.read_u32(C68kScript.u32(a5 - 0x2152))])

## 0x3178: the channel disposed (quietly) and the sound unlocked and released, both cleared.
func stop_named_sound() -> void:
	if memory.read_u32(C68kScript.u32(a5 - 0x2152)) != 0:
		_trap(TRAP_SND_DISPOSE_CHANNEL, [1, memory.read_u32(C68kScript.u32(a5 - 0x2152))])
		memory.write_u32(C68kScript.u32(a5 - 0x2152), 0)
	if memory.read_u32(C68kScript.u32(a5 - 0x2156)) != 0:
		_jt(JT_HUNLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x2156))])
		_trap(TRAP_RELEASE_RESOURCE, [memory.read_u32(C68kScript.u32(a5 - 0x2156))])
		memory.write_u32(C68kScript.u32(a5 - 0x2156), 0)

## 0x3a56: SystemTask, then any event (GetNextEvent into the frame): 1 for a mouse-down, key-down
## or auto-key event (ID01's dense switch on 1..5), else 0.
func poll_click_or_key_event() -> int:
	assert(a7 != 0, "poll_click_or_key_event needs a7 (GetNextEvent writes into its frame)")
	var a6: int = a7 - 4
	_trap(TRAP_SYSTEM_TASK, [])
	_trap(TRAP_GET_NEXT_EVENT, [a6 - 0x10, 0xffff])
	var what: int = memory.read_u16(a6 - 0x10)
	return 1 if what == 1 or what == 3 or what == 5 else 0

## 0x3d42: SysEnvirons(1) into the frame: colour QuickDraw (+9) and a processor of at least a
## 68020 (+6 >= 3) are required, else the caution alert with the message at A5 - 0xe52 and 0.
func check_system_requirements() -> int:
	assert(a7 != 0, "check_system_requirements needs a7 (SysEnvirons writes into its frame)")
	var a6: int = a7 - 4
	_jt(JT_SYS_ENVIRONS, [a6 - 0x10, 1])
	if memory.read_u8(a6 - 7) == 0 or memory.read_s16(a6 - 0xa) < 3:
		_jt(JT_CAUTION_NUMBER, [memory.read_u32(C68kScript.u32(a5 - 0xe52)), 0])
		return 0
	return 1

## 0x9ee (a user item procedure, Pascal): the mission title (A5 - 0xe46) in 24-point type centred
## in the item's box (StringWidth, GetFontInfo's ascent), the size set back to 0.
func draw_select_mission_title(dialog: int, item: int) -> void:
	assert(a7 != 0, "draw_select_mission_title needs a7 (GetDItem / GetFontInfo write into its frame)")
	var a6: int = a7 - 4
	var title: int = memory.read_u32(C68kScript.u32(a5 - 0xe46))
	_get_ditem(dialog, item, a6 - 2, a6 - 6, a6 - 0x16)
	var width: int = C68kScript.u16(memory.read_u16(a6 - 0x10) - memory.read_u16(a6 - 0x14))
	var height: int = C68kScript.u16(memory.read_u16(a6 - 0x12) - memory.read_u16(a6 - 0x16))
	_trap(TRAP_TEXT_SIZE, [0x18])
	var text_width: int = _trap(TRAP_STRING_WIDTH, [title]) & 0xffff
	_trap(TRAP_GET_FONT_INFO, [a6 - 0xe])
	var x: int = C68kScript.u16(_wdiv(width, 2) + memory.read_u16(a6 - 0x14) - _wdiv(text_width, 2))
	var y: int = C68kScript.u16(_wdiv(height, 2) + memory.read_u16(a6 - 0x16) + _wdiv(memory.read_u16(a6 - 0xe), 2))
	_trap(TRAP_MOVE_TO, [y, x])
	_trap(TRAP_DRAW_STRING, [title])
	_trap(TRAP_TEXT_SIZE, [0])

static func _wdiv(v: int, d: int) -> int:
	return C68kScript.divs_trunc(C68kScript.s16(v), d)
