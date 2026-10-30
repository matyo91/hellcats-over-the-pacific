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
	_trap(TRAP_INSET_RECT, [0xfffe, 0xfffe, C68kScript.u32(a6 - 0xe)])
	_trap(TRAP_PEN_SIZE, [1, 1])
	_trap(TRAP_FRAME_RECT, [_box(a6 - 0xe)])
	_trap(TRAP_SET_PORT, [saved])

## 0x16e (a user item procedure, Pascal): the default button (item A5 - 0x225e, not the item drawn)
## outlined: a 3 x 3 pen, InsetRect -4, FrameRoundRect 16 x 16.
func draw_default_button_outline(dialog: int, _item: int) -> void:
	_item_handle(dialog, memory.read_u16(C68kScript.u32(a5 - 0x225e)))
	var a6: int = a7 - 4
	_trap(TRAP_PEN_SIZE, [3, 3])
	_trap(TRAP_INSET_RECT, [0xfffc, 0xfffc, C68kScript.u32(a6 - 0xe)])
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
	_trap(TRAP_INSET_RECT, [0xffff, 0xffff, C68kScript.u32(a6 - 0x1a)])
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
		_trap(TRAP_INSET_RECT, [0x64, 0x64, C68kScript.u32(a6 - 8)])
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
	_trap(TRAP_INSET_RECT, [0xfffe, 0xfffe, C68kScript.u32(a6 - 0x12)])
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
	_trap(TRAP_INSET_RECT, [0xfffe, 0, C68kScript.u32(a6 - 0x1a)])
	_trap(TRAP_OFFSET_RECT, [0, 2, C68kScript.u32(a6 - 0x1a)])
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

const JT_DRAW_UPDATE: int = 0x492    ## ID02: a dialog's update event handled (C, event)
const JT_P2C: int = 0x2fa            ## C string conversions in place (C, string): the string
const JT_C2P: int = 0x302
const JT_STRCPY: int = 0x52a         ## (C: dest, src)
const JT_STRCAT: int = 0x512         ## (C: dest, src)
const JT_NUM_TO_STRING: int = 0x4a2  ## (C: value, dest)
const TRAP_GLOBAL_TO_LOCAL: int = 0xa871
const TRAP_PT_IN_RECT: int = 0xa8ad
const TRAP_GET_MOUSE: int = 0xa972
const TRAP_STILL_DOWN: int = 0xa973
const TRAP_INVAL_RECT: int = 0xa928
const TRAP_UPDATE_RES_FILE: int = 0xa999
const TRAP_SET_ORIGIN: int = 0xa878
const TRAP_CLIP_RECT: int = 0xa87b
const TRAP_FORE_COLOR: int = 0xa862
const TRAP_LINE: int = 0xa892
const TRAP_MOVE: int = 0xa894
const TRAP_DRAW_CHAR: int = 0xa883
const LOCAL_TRACK_MAP_BEARING: int = 0x3614  ## track_map_bearing_and_distance (C: dialog, event; not exported)
const LOCAL_MISSION_SUMMARY: int = 0x2de6    ## show_mission_summary_dialog (C: word, which, arg): word

## A call to a routine of this segment not ported yet, by its segment offset.
func _local(offset: int, args: Array) -> int:
	assert(code_routines.has(offset), "segment routine %x has no stand-in" % offset)
	return code_routines[offset].call(args)

## A key-down's character (the message's low byte): Return (13) or Enter (3) press item 1.
func _return_presses_item(event: int, item_hit: int, item: int) -> int:
	var c: int = memory.read_u32(C68kScript.u32(event + 2)) & 0xff
	if c == 0xd or c == 3:
		memory.write_u16(C68kScript.u32(item_hit), item & 0xffff)
		return 1
	return 0

## 0x5e4 (a ModalDialog filter, Pascal; ID01's sparse switches on the event and the character):
## Return / Enter press item 1 (true); an update event goes to JT $492 (false); anything else false.
func duty_roster_filter_proc(_dialog: int, event: int, item_hit: int) -> int:
	match memory.read_u16(C68kScript.u32(event)):
		3:
			return _return_presses_item(event, item_hit, 1)
		6:
			_jt(JT_DRAW_UPDATE, [C68kScript.u32(event)])
	return 0

## 0xa8e: the slider filter: Return / Enter press item 1; an update event goes to JT $492; a click
## in the slider item's box tracks the mouse while the button is down, the percent (A5 - 0x225c,
## 0 left of the box, 100 right of it, else (h - left) * 100 / width with DIVS.L) redrawn by
## draw_percent_bar_item when it changes, and then presses the slider item (true). The port is the
## dialog's while it runs; the current one (A5 - 0x160c) is restored.
func fuel_slider_dialog_filter(dialog: int, event: int, item_hit: int, item: int) -> int:
	match memory.read_u16(C68kScript.u32(event)):
		3:
			return _return_presses_item(event, item_hit, 1)
		6:
			_jt(JT_DRAW_UPDATE, [C68kScript.u32(event)])
			return 0
		1:
			pass
		_:
			return 0
	assert(a7 != 0, "fuel_slider_dialog_filter needs a7 (GetDItem / GlobalToLocal write into its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	_get_ditem(dialog, item, a6 - 4, a6 - 8, a6 - 0x10)
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	memory.write_u32(a6 - 0x14, memory.read_u32(C68kScript.u32(event + 0xa)))
	_trap(TRAP_GLOBAL_TO_LOCAL, [a6 - 0x14])
	if (_trap(TRAP_PT_IN_RECT, [_box(a6 - 0x10), memory.read_u32(a6 - 0x14)]) >> 8) & 0xff == 0:
		_trap(TRAP_SET_PORT, [saved])
		return 0
	while (_trap(TRAP_STILL_DOWN, []) >> 8) & 0xff != 0:
		var h: int = memory.read_s16(a6 - 0x12)
		var left: int = memory.read_s16(a6 - 0xe)
		var right: int = memory.read_s16(a6 - 0xa)
		var percent: int
		if h >= left and h <= right:
			var scaled: int = C68kScript.s32(C68kScript.u32(C68kScript.s16(h - left) * 0x64))
			percent = C68kScript.u16(C68kScript.divs_trunc(scaled, C68kScript.s16(right - left)))
		elif h < left:
			percent = 0
		else:
			percent = 0x64
		if percent != memory.read_u16(C68kScript.u32(a5 - 0x225c)):
			memory.write_u16(C68kScript.u32(a5 - 0x225c), percent)
			a7 = entry - 4 - 0x18 - 6 - 4
			draw_percent_bar_item(dialog, item)
			a7 = entry
		_trap(TRAP_GET_MOUSE, [a6 - 0x14])
	memory.write_u16(C68kScript.u32(item_hit), item & 0xffff)
	_trap(TRAP_SET_PORT, [saved])
	return 1

## 0xbda / 0xe48 (ModalDialog filters, Pascal): fuel_slider_dialog_filter on item 5 / item 3.
func scenario_selection_filter_proc(dialog: int, event: int, item_hit: int) -> int:
	return _slider_filter(dialog, event, item_hit, 5)

func refuel_dialog_filter_proc(dialog: int, event: int, item_hit: int) -> int:
	return _slider_filter(dialog, event, item_hit, 3)

func _slider_filter(dialog: int, event: int, item_hit: int, item: int) -> int:
	var entry: int = a7
	a7 = entry - 4 - 0xe - 4
	var hit: int = fuel_slider_dialog_filter(dialog, event, item_hit, item)
	a7 = entry
	return hit

## 0x3902 (a ModalDialog filter, Pascal): Return / Enter press the default item (A5 - 0x225e,
## true); an update event goes to JT $492; a click is tracked by track_map_bearing_and_distance
## (0x3614); otherwise false.
func map_dialog_filter_proc(dialog: int, event: int, item_hit: int) -> int:
	match memory.read_u16(C68kScript.u32(event)):
		3:
			return _return_presses_item(event, item_hit, memory.read_u16(C68kScript.u32(a5 - 0x225e)))
		6:
			_jt(JT_DRAW_UPDATE, [C68kScript.u32(event)])
		1:
			_local(LOCAL_TRACK_MAP_BEARING, [C68kScript.u32(dialog), C68kScript.u32(event)])
	return 0

## 0x2d86: the item's text = the score label (*(A5 - 0xe5e)) + the current pilot's score
## (compute_pilot_score of A5 - 0x13a4, JT $4a2 into A5 - 0x2160), built in A5 - 0x2174.
func set_score_item_text(dialog: int, item: int) -> void:
	var text: int = C68kScript.u32(a5 - 0x2174)
	var number: int = C68kScript.u32(a5 - 0x2160)
	_jt(JT_STRCPY, [text, memory.read_u32(C68kScript.u32(a5 - 0xe5e))])
	var score: int = compute_pilot_score(memory.read_u16(C68kScript.u32(a5 - 0x13a4)))
	_jt(JT_NUM_TO_STRING, [score, number])
	var c_number: int = C68kScript.u32(_jt(JT_P2C, [number]))
	_jt(JT_STRCAT, [text, c_number])
	_jt(JT_C2P, [text])
	var entry: int = a7
	a7 = entry - 4 - 0xa - 4
	set_dialog_item_text(dialog, item, text)
	a7 = entry

## 0x192e: the summary dialog's buttons: A5 - 0x2230 cleared; item 3 enabled unless a mission is on
## (A5 - 0x14c4), A5 - 0x12f0 clear and A5 - 0x2228 is -1; item 1 enabled when A5 - 0x12f0 is
## clear. Unless `which` is 3, in that same mission state with the default item (A5 - 0x225e) not
## 1, the old and new default items' boxes (4 pixels out) are erased and invalidated in the dialog's
## port and item 1 becomes the default.
func update_summary_dialog_buttons(dialog: int, which: int) -> void:
	var entry: int = a7
	var a6: int = entry - 4
	memory.write_u32(C68kScript.u32(a5 - 0x2230), 0)
	var mission: bool = memory.read_u16(C68kScript.u32(a5 - 0x14c4)) != 0
	var pending: bool = memory.read_u16(C68kScript.u32(a5 - 0x12f0)) != 0
	var unset: bool = memory.read_u16(C68kScript.u32(a5 - 0x2228)) == 0xffff
	a7 = entry - 4 - 0x12 - 6 - 4
	if not mission or pending or not unset:
		enable_dialog_control(dialog, 3)
	if not pending:
		enable_dialog_control(dialog, 1)
	a7 = entry
	if C68kScript.s16(which) == 3 or not mission or not unset or memory.read_u16(C68kScript.u32(a5 - 0x225e)) == 1:
		return
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	for item in [memory.read_u16(C68kScript.u32(a5 - 0x225e)), 1]:
		_get_ditem(dialog, item, a6 - 2, a6 - 6, a6 - 0xe)
		_trap(TRAP_INSET_RECT, [0xfffc, 0xfffc, C68kScript.u32(a6 - 0xe)])
		_trap(TRAP_ERASE_RECT, [_box(a6 - 0xe)])
		_trap(TRAP_INVAL_RECT, [_box(a6 - 0xe)])
	memory.write_u16(C68kScript.u32(a5 - 0x225e), 1)
	_trap(TRAP_SET_PORT, [saved])

## 0x1a0e (a user item procedure, Pascal): the current pilot's rank (the string for word +0x22 in
## the table at A5 - 0xffe), A5 - 0x2138 and his name joined in the frame (C string calls through
## the jump table) and drawn centred in the item's box (erased first).
func build_rank_and_name_string(dialog: int, item: int) -> void:
	assert(a7 != 0, "build_rank_and_name_string needs a7 (its frame holds the string)")
	var a6: int = a7 - 4
	var buffer: int = a6 - 0x82
	var rec: int = _roster(memory.read_u16(C68kScript.u32(a5 - 0x13a4)))
	var rank: int = memory.read_u32(C68kScript.u32(a5 - 0xffe + 4 * memory.read_s16(rec + 0x22)))
	_jt(JT_P2C, [rank])
	_jt(JT_STRCPY, [buffer, rank])
	_jt(JT_STRCAT, [buffer, C68kScript.u32(a5 - 0x2138)])
	rec = _roster(memory.read_u16(C68kScript.u32(a5 - 0x13a4)))
	_jt(JT_STRCAT, [buffer, C68kScript.u32(_jt(JT_P2C, [rec]))])
	_jt(JT_C2P, [_roster(memory.read_u16(C68kScript.u32(a5 - 0x13a4)))])
	_jt(JT_C2P, [rank])
	_jt(JT_C2P, [buffer])
	_get_ditem(dialog, item, a6 - 4, a6 - 8, a6 - 0x18)
	var width: int = C68kScript.u16(memory.read_u16(a6 - 0x12) - memory.read_u16(a6 - 0x16))
	var height: int = C68kScript.u16(memory.read_u16(a6 - 0x14) - memory.read_u16(a6 - 0x18))
	var text_width: int = _trap(TRAP_STRING_WIDTH, [buffer]) & 0xffff
	_trap(TRAP_GET_FONT_INFO, [a6 - 0x10])
	_trap(TRAP_ERASE_RECT, [_box(a6 - 0x18)])
	var x: int = C68kScript.u16(_wdiv(width, 2) + memory.read_u16(a6 - 0x16) - _wdiv(text_width, 2))
	var y: int = C68kScript.u16(_wdiv(height, 2) + memory.read_u16(a6 - 0x18) + _wdiv(memory.read_u16(a6 - 0x10), 2))
	_trap(TRAP_MOVE_TO, [y, x])
	_trap(TRAP_DRAW_STRING, [buffer])

## 0x31aa: the end of a mission: a first death (A5 - 0x12b4 = 1, not in state 2, `which` not 3)
## sets A5 - 0x14c2 and plays the sound when A5 - 0x12ee is set; a non-zero status outside `which`
## 3 sets A5 - 0x14c4; show_mission_summary_dialog(-1, which, arg) (0x2de6) runs (the sound stopped
## after it); a changed pilot status (+0x20) is stored and the roster written (ChangedResource,
## UpdateResFile A5 - 0x1002). Returns the summary's answer (a word).
func conclude_mission(which: int, arg: int) -> int:
	var w: int = C68kScript.s16(which)
	var status: int = memory.read_u16(C68kScript.u32(a5 - 0x12b4))
	if memory.read_s16(C68kScript.u32(a5 - 0x12f8)) != 2 and status == 1 and w != 3 \
			and memory.read_u16(C68kScript.u32(a5 - 0x14c2)) == 0:
		memory.write_u16(C68kScript.u32(a5 - 0x14c2), 1)
		if memory.read_u16(C68kScript.u32(a5 - 0x12ee)) != 0:
			play_named_sound_async()
	if w != 3 and memory.read_u16(C68kScript.u32(a5 - 0x12b4)) != 0:
		memory.write_u16(C68kScript.u32(a5 - 0x14c4), 1)
	var answer: int = _local(LOCAL_MISSION_SUMMARY, [0xffff, which & 0xffff, C68kScript.u32(arg)]) & 0xffff
	if memory.read_u16(C68kScript.u32(a5 - 0x12ee)) != 0:
		stop_named_sound()
	var rec: int = _roster(memory.read_u16(C68kScript.u32(a5 - 0x13a4)))
	if memory.read_u16(rec + 0x20) != memory.read_u16(C68kScript.u32(a5 - 0x12b4)):
		memory.write_u16(rec + 0x20, memory.read_u16(C68kScript.u32(a5 - 0x12b4)))
		_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])
		_trap(TRAP_UPDATE_RES_FILE, [memory.read_u16(C68kScript.u32(a5 - 0x1002))])
	return answer

## 0x3260: the map's origin set (A5 - 0x2148 / -0x2146), its rect (A5 - 0x2144) offset by half the
## size (A5 - 0x214c width, -0x214a height) and clipped to; colour 30 (A5 - 0x137a = 1) or 33; the
## quarter lines (1-pixel pen; i * size as a word, / 4) and a 3-pixel cross of 10 at the centre;
## A5 - 0x214e set.
func draw_map_grid_and_centre_mark() -> void:
	var width: int = memory.read_s16(C68kScript.u32(a5 - 0x214c))
	var height: int = memory.read_s16(C68kScript.u32(a5 - 0x214a))
	_trap(TRAP_SET_ORIGIN, [memory.read_u16(C68kScript.u32(a5 - 0x2146)), memory.read_u16(C68kScript.u32(a5 - 0x2148))])
	_trap(TRAP_OFFSET_RECT, [C68kScript.u16(_wdiv(height, 2)), C68kScript.u16(_wdiv(width, 2)), C68kScript.u32(a5 - 0x2144)])
	_trap(TRAP_CLIP_RECT, [C68kScript.u32(a5 - 0x2144)])
	_trap(TRAP_FORE_COLOR, [0x1e if memory.read_u16(C68kScript.u32(a5 - 0x137a)) == 1 else 0x21])
	_trap(TRAP_PEN_SIZE, [1, 1])
	for i in range(1, 4):
		_trap(TRAP_MOVE_TO, [0, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(i * width), 4))])
		_trap(TRAP_LINE, [C68kScript.u16(height), 0])
		_trap(TRAP_MOVE_TO, [C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(i * height), 4)), 0])
		_trap(TRAP_LINE, [0, C68kScript.u16(width)])
	_trap(TRAP_PEN_SIZE, [3, 3])
	_trap(TRAP_MOVE_TO, [C68kScript.u16(_wdiv(height, 2) - 1), C68kScript.u16(_wdiv(width, 2) - 1)])
	_trap(TRAP_MOVE, [0xfffb, 0])
	_trap(TRAP_LINE, [0xa, 0])
	_trap(TRAP_MOVE, [0xfffb, 0xfffb])
	_trap(TRAP_LINE, [0, 0xa])
	memory.write_u16(C68kScript.u32(a5 - 0x214e), 1)

## 0x3352 (a plotting callback, C; A5 from CurrentA5 at 0x904): the grid drawn first if not yet
## (A5 - 0x214e); the symbol (the low byte of the first argument) drawn in colour 30 at the point
## moved from the origin to the map's half-size offset.
func plot_map_symbol_callback(symbol: int, x: int, y: int) -> void:
	var saved_a5: int = a5
	a5 = memory.read_u32(0x904)
	if memory.read_u16(C68kScript.u32(a5 - 0x214e)) == 0:
		draw_map_grid_and_centre_mark()
	var ox: int = memory.read_s16(C68kScript.u32(a5 - 0x2148))
	var oy: int = memory.read_s16(C68kScript.u32(a5 - 0x2146))
	var px: int = C68kScript.u32(C68kScript.u32(x) - C68kScript.s16(ox - _wdiv(memory.read_u16(C68kScript.u32(a5 - 0x214c)), 2)) + ox)
	var py: int = C68kScript.u32(C68kScript.u32(y) - C68kScript.s16(oy - _wdiv(memory.read_u16(C68kScript.u32(a5 - 0x214a)), 2)) + oy)
	_trap(TRAP_FORE_COLOR, [0x1e])
	_trap(TRAP_MOVE_TO, [py & 0xffff, px & 0xffff])
	_trap(TRAP_DRAW_CHAR, [C68kScript.u16(C68kScript.s8(symbol & 0xff))])
	a5 = saved_a5

const JT_COLOR_PATTERN: int = 0x1ca  ## (C: RGBColor by value): a pattern for FillRect
const TRAP_TEXT_FONT: int = 0xa887
const TRAP_RGB_FORE_COLOR: int = 0xaa14
const TRAP_PAINT_OVAL: int = 0xa8b8
const TRAP_PAINT_RECT: int = 0xa8a2

## A call through a code pointer (a routine of another segment kept in an A5 global).
func _call_address(address: int, args: Array) -> int:
	assert(code_routines.has(address), "code address %x has no routine" % address)
	return code_routines[address].call(args)

## 0x1200 (a user item procedure, Pascal): the high-score table: the pilots ranked into the frame,
## the item's box erased, the columns' left edges from items 4..7; up to ten pilots with a name or a
## score drawn 20 pixels apart (rank A5 - 0xffe, name, status A5 - 0xfae, score via JT $4a2) with
## the roster locked.
func draw_high_scores_table(dialog: int, item: int) -> void:
	assert(a7 != 0, "draw_high_scores_table needs a7 (its frame holds the ranking)")
	var entry: int = a7
	var a6: int = entry - 4
	var scores: int = a6 - 0x6c
	var order: int = a6 - 0x94
	a7 = entry - 4 - 0x10c - 8 - 4
	rank_pilots_by_score(scores, order)
	a7 = entry
	_get_ditem(dialog, item, a6 - 8, a6 - 0xc, a6 - 0x14)
	_trap(TRAP_ERASE_RECT, [_box(a6 - 0x14)])
	for i in 4:
		_get_ditem(dialog, i + 4, a6 - 8, a6 - 0xc, a6 - 0x1c)
		memory.write_u16(a6 - 0x9c + 2 * i, memory.read_u16(a6 - 0x1a))
	_jt(JT_HLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])
	_trap(TRAP_GET_FONT_INFO, [a6 - 0x10c])
	var row: int = 0
	for i in 0x14:
		var rec: int = _roster(memory.read_u16(order + 2 * i))
		if memory.read_u8(rec) == 0 and memory.read_u32(scores + 4 * i) == 0:
			continue
		var y: int = C68kScript.u16(row * 0x14 + memory.read_u16(a6 - 0x10c) + memory.read_u16(a6 - 0x14))
		_trap(TRAP_MOVE_TO, [y, memory.read_u16(a6 - 0x9c)])
		_trap(TRAP_DRAW_STRING, [memory.read_u32(C68kScript.u32(a5 - 0xffe + 4 * memory.read_s16(rec + 0x22)))])
		_trap(TRAP_MOVE_TO, [y, memory.read_u16(a6 - 0x9a)])
		_trap(TRAP_DRAW_STRING, [rec])
		_trap(TRAP_MOVE_TO, [y, memory.read_u16(a6 - 0x98)])
		_trap(TRAP_DRAW_STRING, [memory.read_u32(C68kScript.u32(a5 - 0xfae + 4 * memory.read_s16(rec + 0x20)))])
		_jt(JT_NUM_TO_STRING, [memory.read_u32(scores + 4 * i), a6 - 0x104])
		_trap(TRAP_MOVE_TO, [y, memory.read_u16(a6 - 0x96)])
		_trap(TRAP_DRAW_STRING, [a6 - 0x104])
		row += 1
		if row == 0xa:
			break
	_jt(JT_HUNLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])

## 0x1bc8: one row of the targets-destroyed list (kinds 2, 4 and 8 are skipped and close the gaps):
## 23 pixels a row in the item's box, erased; the kind's name (A5 - 0xf86) with " x" + its count
## (the counts at *(A5 - 0x2226)) when non-zero in font 1, and the points (count * weight A5 - 0xf5e)
## right-aligned; the font and port restored.
func draw_targets_destroyed_row(dialog: int, item: int, index: int) -> void:
	assert(a7 != 0, "draw_targets_destroyed_row needs a7 (its frame holds the strings)")
	var a6: int = a7 - 4
	var port: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	var font: int = memory.read_u16(C68kScript.u32(port + 0x44))
	var idx: int = C68kScript.s16(index)
	if idx == 2 or idx == 4 or idx == 8:
		return
	var row: int = idx
	for gap in [2, 4, 8]:
		if idx > gap:
			row -= 1
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	_trap(TRAP_CLIP_RECT, [C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x160c)) + 0x10)])
	_get_ditem(dialog, item, a6 - 8, a6 - 0xc, a6 - 0x14)
	_trap(TRAP_INSET_RECT, [0, 4, C68kScript.u32(a6 - 0x14)])
	_trap(TRAP_GET_FONT_INFO, [a6 - 0x92])
	var top: int = memory.read_u16(a6 - 0x14)
	var y: int = C68kScript.u16(row * 0x17 + memory.read_u16(a6 - 0x92) + top + 3)
	memory.write_u16(a6 - 0x14, C68kScript.u16(row * 0x17 + top + 3))
	memory.write_u16(a6 - 0x10, C68kScript.u16(memory.read_u16(a6 - 0x14) + 0x10))
	_trap(TRAP_ERASE_RECT, [_box(a6 - 0x14)])
	_trap(TRAP_MOVE_TO, [y, memory.read_u16(a6 - 0x12)])
	var buffer: int = a6 - 0x80
	var name: int = memory.read_u32(C68kScript.u32(a5 - 0xf86 + 4 * idx))
	var count: int = memory.read_s16(C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x2226)) + 2 * idx))
	_jt(JT_STRCPY, [buffer, name])
	if count != 0:
		_jt(JT_STRCAT, [buffer, C68kScript.u32(a5 - 0x2136)])
		var number: int = C68kScript.u32(_jt(JT_NUM_TO_STRING, [C68kScript.u32(count), a6 - 0x8a]))
		_jt(JT_STRCAT, [buffer, C68kScript.u32(_jt(JT_P2C, [number]))])
	_jt(JT_C2P, [buffer])
	_trap(TRAP_TEXT_FONT, [1])
	_trap(TRAP_DRAW_STRING, [buffer])
	var points: int = C68kScript.u32(count * memory.read_s16(C68kScript.u32(a5 - 0xf5e + 2 * idx)))
	_jt(JT_NUM_TO_STRING, [points, buffer])
	var width: int = _trap(TRAP_STRING_WIDTH, [buffer]) & 0xffff
	_trap(TRAP_MOVE_TO, [y, C68kScript.u16(memory.read_u16(a6 - 0xe) - width)])
	_trap(TRAP_DRAW_STRING, [buffer])
	_trap(TRAP_TEXT_FONT, [font])
	_trap(TRAP_SET_PORT, [port])

## 0x1d9e (a user item procedure, Pascal): the item's box framed and the ten rows drawn.
func draw_targets_destroyed_list(dialog: int, item: int) -> void:
	var entry: int = a7
	a7 = entry - 4 - 2 - 6 - 4
	frame_dialog_item_box(dialog, item)
	a7 = entry - 4 - 2 - 8 - 4
	for i in 0xa:
		draw_targets_destroyed_row(dialog, item, i)
	a7 = entry

## 0x1f5e: the item's box framed; in the dialog's port (clipped to its rect) one marker per aircraft
## kill (the current pilot's first two tallies, at most 24), six to a row: a 26 x 16 frame and a red
## oval inset by 3 in a 16 x 16 square; the current port restored.
func draw_aircraft_kill_markers(dialog: int, item: int) -> void:
	assert(a7 != 0, "draw_aircraft_kill_markers needs a7 (its frame holds the rects)")
	var entry: int = a7
	var a6: int = entry - 4
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	memory.write_u32(a6 - 0x30, saved)
	a7 = entry - 4 - 0x36 - 6 - 4
	frame_dialog_item_box(dialog, item)
	a7 = entry
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	_trap(TRAP_CLIP_RECT, [C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x160c)) + 0x10)])
	_get_ditem(dialog, item, a6 - 0x18, a6 - 0x1c, a6 - 0x24)
	var width: int = C68kScript.s16(memory.read_u16(a6 - 0x1e) - memory.read_u16(a6 - 0x22))
	var height: int = C68kScript.s16(memory.read_u16(a6 - 0x20) - memory.read_u16(a6 - 0x24))
	var tallies: int = _roster(memory.read_u16(C68kScript.u32(a5 - 0x13a4))) + 0x28
	var kills: int = C68kScript.s16(memory.read_u16(tallies) + memory.read_u16(tallies + 2))
	if kills > 0x18:
		kills = 0x18
	memory.write_u16(a6 - 0x36, 0xffff)
	memory.write_u16(a6 - 0x34, 0)
	memory.write_u16(a6 - 0x32, 0)
	var col: int = 0
	var row: int = 0
	for i in range(kills):
		var x: int = C68kScript.divs_trunc(C68kScript.s16(width * col), 6)
		var y: int = C68kScript.divs_trunc(C68kScript.s16(height * row), 4)
		memory.write_u16(a6 - 0x2a, C68kScript.u16(x - 0xd))
		memory.write_u16(a6 - 0x26, C68kScript.u16(x - 0xd + 0x1a))
		memory.write_u16(a6 - 0x2c, C68kScript.u16(y - 8))
		memory.write_u16(a6 - 0x28, C68kScript.u16(y - 8 + 0x10))
		_trap(TRAP_OFFSET_RECT, [C68kScript.u16(memory.read_u16(a6 - 0x24) + 0xa), C68kScript.u16(memory.read_u16(a6 - 0x22) + 0xf), a6 - 0x2c])
		_trap(TRAP_FRAME_RECT, [_box(a6 - 0x2c)])
		memory.write_u16(a6 - 0x2a, C68kScript.u16(x + memory.read_u16(a6 - 0x22) + 7))
		memory.write_u16(a6 - 0x26, C68kScript.u16(memory.read_u16(a6 - 0x2a) + 0x10))
		_trap(TRAP_INSET_RECT, [3, 3, C68kScript.u32(a6 - 0x2c)])
		_trap(TRAP_RGB_FORE_COLOR, [C68kScript.u32(a6 - 0x36)])
		_trap(TRAP_PAINT_OVAL, [_box(a6 - 0x2c)])
		_trap(TRAP_FORE_COLOR, [0x21])
		col += 1
		if col == 6:
			col = 0
			row += 1
	_trap(TRAP_SET_PORT, [saved])

## 0x20e8 (a user item procedure, Pascal): draw_aircraft_kill_markers.
func aircraft_kill_markers_user_item_proc(dialog: int, item: int) -> void:
	var entry: int = a7
	a7 = entry - 4 - 6 - 4
	draw_aircraft_kill_markers(dialog, item)
	a7 = entry

## 0x33d6: the map item: its box framed; the map rect (GetDItem into A5 - 0x2144) moved to the
## origin (A5 - 0x2148 / -0x2146) and its size kept (A5 - 0x214c / -0x214a); the sea filled (a blue
## pattern from JT $1ca at night, A5 - 0x137a = 1, else painted in colour 0x199); the origin and rect
## centred and clipped to; the map symbols plotted through *(A5 - 0x1052) (scale from settings +0x26,
## callback A5 + 0x72), the grid drawn if not yet, a north arrow in colour 30; the origin, pen, clip
## and port restored; item 7's text = the scale + *(A5 - 0xe5a).
func draw_map_view_item(dialog: int, item: int) -> void:
	assert(a7 != 0, "draw_map_view_item needs a7 (its frame holds the colour and text)")
	var entry: int = a7
	var a6: int = entry - 4
	var rect: int = C68kScript.u32(a5 - 0x2144)
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	memory.write_u16(C68kScript.u32(a5 - 0x214e), 0)
	a7 = entry - 4 - 0x46 - 6 - 4
	frame_dialog_item_box(dialog, item)
	a7 = entry
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	_get_ditem(dialog, item, a6 - 6, a6 - 0xa, rect)
	memory.write_u16(C68kScript.u32(a5 - 0x2148), C68kScript.u16(-memory.read_u16(C68kScript.u32(a5 - 0x2142))))
	memory.write_u16(C68kScript.u32(a5 - 0x2146), C68kScript.u16(-memory.read_u16(rect)))
	_trap(TRAP_SET_ORIGIN, [memory.read_u16(C68kScript.u32(a5 - 0x2146)), memory.read_u16(C68kScript.u32(a5 - 0x2148))])
	_trap(TRAP_OFFSET_RECT, [C68kScript.u16(-memory.read_u16(rect)), C68kScript.u16(-memory.read_u16(C68kScript.u32(a5 - 0x2142))), rect])
	memory.write_u16(C68kScript.u32(a5 - 0x214c), memory.read_u16(C68kScript.u32(a5 - 0x213e)))
	memory.write_u16(C68kScript.u32(a5 - 0x214a), memory.read_u16(C68kScript.u32(a5 - 0x2140)))
	memory.write_u16(a6 - 0x12, 0)
	memory.write_u16(a6 - 0x14, 0)
	memory.write_u16(a6 - 0x10, 0xffff)
	if memory.read_u16(C68kScript.u32(a5 - 0x137a)) == 1:
		var pattern: int = _jt(JT_COLOR_PATTERN, [memory.read_u16(a6 - 0x14), memory.read_u32(a6 - 0x12)])
		_trap(TRAP_FILL_RECT, [C68kScript.u32(pattern), _box(rect)])
	else:
		_trap(TRAP_FORE_COLOR, [0x199])
		_trap(TRAP_PAINT_RECT, [rect])
	var width: int = memory.read_s16(C68kScript.u32(a5 - 0x214c))
	var height: int = memory.read_s16(C68kScript.u32(a5 - 0x214a))
	_trap(TRAP_SET_ORIGIN, [C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x2146)) - _wdiv(height, 2)),
			C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x2148)) - _wdiv(width, 2))])
	_trap(TRAP_OFFSET_RECT, [C68kScript.u16(_wdiv(-height, 2)), C68kScript.u16(_wdiv(-width, 2)), rect])
	_trap(TRAP_CLIP_RECT, [rect])
	var settings: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	var scaled: int = C68kScript.u32(C68kScript.u32(C68kScript.s16(C68kScript.u16(memory.read_u16(settings + 0x26) << 2))) * 0xce40)
	var scale: int = C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(scaled), width))
	_call_address(memory.read_u32(C68kScript.u32(a5 - 0x1052)), [scale, C68kScript.u32(a5 + 0x72)])
	if memory.read_u16(C68kScript.u32(a5 - 0x214e)) == 0:
		draw_map_grid_and_centre_mark()
	width = memory.read_u16(C68kScript.u32(a5 - 0x214c))
	_trap(TRAP_FORE_COLOR, [0x1e])
	_trap(TRAP_PEN_SIZE, [2, 2])
	_trap(TRAP_MOVE_TO, [0x14, C68kScript.u16(width - 0x12)])
	_trap(TRAP_LINE, [0xfff4, 0])
	_trap(TRAP_LINE, [0xc, 8])
	_trap(TRAP_LINE, [0xfff4, 0])
	_trap(TRAP_MOVE_TO, [0x1e, C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x214c)) - 0x14)])
	_trap(TRAP_LINE, [0xfffa, 6])
	_trap(TRAP_LINE, [6, 6])
	_trap(TRAP_MOVE_TO, [0x18, C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x214c)) - 0xe)])
	_trap(TRAP_LINE, [0x12, 0])
	_trap(TRAP_FORE_COLOR, [0x21])
	_trap(TRAP_SET_ORIGIN, [0, 0])
	_trap(TRAP_PEN_SIZE, [1, 1])
	_trap(TRAP_CLIP_RECT, [C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x160c)) + 0x10)])
	_trap(TRAP_SET_PORT, [saved])
	var text: int = a6 - 0x46
	settings = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	var number: int = _jt(JT_NUM_TO_STRING, [C68kScript.u32(memory.read_s16(settings + 0x26)), text])
	_jt(JT_P2C, [C68kScript.u32(number)])
	_jt(JT_STRCAT, [text, memory.read_u32(C68kScript.u32(a5 - 0xe5a))])
	_jt(JT_C2P, [text])
	a7 = entry - 4 - 0x46 - 0xa - 4
	set_dialog_item_text(dialog, 7, text)
	a7 = entry

## 0x35f8 (a user item procedure, Pascal): draw_map_view_item.
func map_view_user_item_proc(dialog: int, item: int) -> void:
	var entry: int = a7
	a7 = entry - 4 - 6 - 4
	draw_map_view_item(dialog, item)
	a7 = entry

const JT_CENTRE_DIALOG: int = 0x48a   ## (C, dialog): placed before it is shown
const JT_CENTRE_ABOUT: int = 0x472    ## (C, dialog)
const JT_HNOPURGE: int = 0x28a
const JT_HPURGE: int = 0x282
const TRAP_GET_NEW_DIALOG: int = 0xa97c
const TRAP_DRAW_DIALOG: int = 0xa981
const TRAP_DISPOSE_DIALOG: int = 0xa983
const TRAP_GET_RESOURCE: int = 0xa9a0
const TRAP_DRAW_PICTURE: int = 0xa8f6
const TRAP_TICK_COUNT: int = 0xa975
const TRAP_BUTTON: int = 0xa974
const TRAP_COPY_BITS: int = 0xa8ec

## 0x478: dialog 0x83 (placed by JT $48a, shown and drawn) stays up until a key goes down and then
## up (GetNextEvent for key events only, into the frame), then is disposed.
func show_paused_dialog() -> void:
	assert(a7 != 0, "show_paused_dialog needs a7 (GetNextEvent writes into its frame)")
	var a6: int = a7 - 4
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, 0x83]))
	memory.write_u32(a6 - 4, dialog)
	_jt(JT_CENTRE_DIALOG, [dialog])
	_trap(TRAP_SHOW_WINDOW, [dialog])
	_trap(TRAP_DRAW_DIALOG, [dialog])
	var state: int = 0
	while state != 2:
		if (_trap(TRAP_GET_NEXT_EVENT, [a6 - 0x14, 0x18]) >> 8) & 0xff == 0:
			continue
		var what: int = memory.read_u16(a6 - 0x14)
		if (state == 0 and what == 3) or (state == 1 and what == 4):
			state += 1
	_trap(TRAP_DISPOSE_DIALOG, [dialog])

## 0x3a8c: the About box (dialog 0x8a at night, A5 - 0x137a = 1, else 0x7f; placed by JT $472,
## shown and drawn, the current port saved): the version ('vers' 1, "M.0.F" in font 1 size 8 at
## item 3's bottom left; the minor digit is always 0, the original masks 0xf0 and shifts by 8);
## PICT 0x83 (locked, unpurgeable) drawn centred at the top of item 2, three seconds to look at it
## (a click or key cuts it short), then scrolled up a line every two ticks (CopyBits within the
## dialog, the picture redrawn a line higher, clipped to the item's bottom line) until it has gone,
## the button is down or a click or key comes; the picture released, the port restored and the
## dialog disposed.
func show_about_dialog() -> void:
	assert(a7 != 0, "show_about_dialog needs a7 (its frame holds the rects and strings)")
	var entry: int = a7
	var a6: int = entry - 4
	var id: int = 0x8a if memory.read_u16(C68kScript.u32(a5 - 0x137a)) == 1 else 0x7f
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, id]))
	memory.write_u32(a6 - 4, dialog)
	if dialog == 0:
		return
	_jt(JT_CENTRE_ABOUT, [dialog])
	_trap(TRAP_SHOW_WINDOW, [dialog])
	_trap(TRAP_DRAW_DIALOG, [dialog])
	_trap(TRAP_GET_PORT, [a6 - 0x4c])
	_trap(TRAP_SET_PORT, [dialog])
	_get_ditem(dialog, 3, a6 - 8, a6 - 0x10, a6 - 0x20)
	_trap(TRAP_MOVE_TO, [memory.read_u16(a6 - 0x1c), memory.read_u16(a6 - 0x1e)])
	_trap(TRAP_TEXT_FONT, [1])
	_trap(TRAP_TEXT_SIZE, [8])
	var vers: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [1, 0x76657273]))
	memory.write_u32(a6 - 0x14, vers)
	var version: int = memory.read_u16(memory.read_u32(vers))
	memory.write_u16(a6 - 6, version)
	memory.write_u8(a6 - 0x55, ((C68kScript.s16(version) >> 8) + 0x30) & 0xff)
	memory.write_u8(a6 - 0x54, 0x2e)
	memory.write_u8(a6 - 0x53, (((version & 0xf0) >> 8) + 0x30) & 0xff)
	memory.write_u8(a6 - 0x52, 0x2e)
	memory.write_u8(a6 - 0x51, ((version & 0xf) + 0x30) & 0xff)
	memory.write_u8(a6 - 0x56, 5)
	_trap(TRAP_DRAW_STRING, [_box(a6 - 0x56)])
	_get_ditem(dialog, 2, a6 - 8, a6 - 0x10, a6 - 0x20)
	for dst in [a6 - 0x30, a6 - 0x38, a6 - 0x40]:
		memory.write_u32(dst, memory.read_u32(a6 - 0x20))
		memory.write_u32(dst + 4, memory.read_u32(a6 - 0x1c))
	memory.write_u16(a6 - 0x38, C68kScript.u16(memory.read_u16(a6 - 0x38) - 1))
	memory.write_u16(a6 - 0x34, C68kScript.u16(memory.read_u16(a6 - 0x34) - 1))
	memory.write_u16(a6 - 0x40, C68kScript.u16(memory.read_u16(a6 - 0x3c) - 1))
	var picture: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [0x83, 0x50494354]))
	memory.write_u32(a6 - 0x18, picture)
	if picture != 0:
		_about_picture(entry, a6, dialog, picture)
	_trap(TRAP_SET_PORT, [memory.read_u32(a6 - 0x4c)])
	_trap(TRAP_DISPOSE_DIALOG, [dialog])

func _about_picture(entry: int, a6: int, dialog: int, picture: int) -> void:
	_jt(JT_HLOCK, [picture])
	_jt(JT_HNOPURGE, [picture])
	var frame: int = a6 - 0x28
	memory.write_u32(frame, memory.read_u32(memory.read_u32(picture) + 2))
	memory.write_u32(frame + 4, memory.read_u32(memory.read_u32(picture) + 6))
	_trap(TRAP_OFFSET_RECT, [C68kScript.u16(-memory.read_u16(frame)), C68kScript.u16(-memory.read_u16(a6 - 0x26)), C68kScript.u32(frame)])
	var centre: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(memory.read_u16(a6 - 0x1a) - memory.read_u16(a6 - 0x1e)
			- memory.read_u16(a6 - 0x22) - memory.read_u16(a6 - 0x26)), 2))
	memory.write_u16(a6 - 0xc, centre)
	_trap(TRAP_OFFSET_RECT, [memory.read_u16(a6 - 0x20), C68kScript.u16(memory.read_u16(a6 - 0x1e) + centre), C68kScript.u32(frame)])
	_trap(TRAP_CLIP_RECT, [_box(a6 - 0x20)])
	_trap(TRAP_DRAW_PICTURE, [_box(frame), picture])
	var p: int = memory.read_u32(picture)
	var height: int = C68kScript.s16(memory.read_u16(p + 6) - memory.read_u16(p + 2))
	var until: int = C68kScript.s32(_trap(TRAP_TICK_COUNT, []) + 0xb4)
	while C68kScript.s32(_trap(TRAP_TICK_COUNT, [])) < until:
		if _poll_at(entry, 0x56) & 0xffff != 0:
			height = 0
			break
	var line: int = 0
	var next_tick: int = 0
	while line < height and _poll_at(entry, 0x56) & 0xffff == 0:
		if C68kScript.s32(_trap(TRAP_TICK_COUNT, [])) <= next_tick:
			continue
		_trap(TRAP_CLIP_RECT, [_box(a6 - 0x20)])
		_trap(TRAP_COPY_BITS, [0, 0, _box(a6 - 0x38), _box(a6 - 0x30), C68kScript.u32(dialog + 2), C68kScript.u32(dialog + 2)])
		_trap(TRAP_CLIP_RECT, [_box(a6 - 0x40)])
		_trap(TRAP_DRAW_PICTURE, [_box(frame), picture])
		memory.write_u16(frame, C68kScript.u16(memory.read_u16(frame) - 1))
		memory.write_u16(a6 - 0x24, C68kScript.u16(memory.read_u16(a6 - 0x24) - 1))
		line += 1
		next_tick = C68kScript.s32(_trap(TRAP_TICK_COUNT, []) + 2)
		if (_trap(TRAP_BUTTON, []) >> 8) & 0xff != 0:
			break
	_jt(JT_HPURGE, [picture])
	_jt(JT_HUNLOCK, [picture])
	_trap(TRAP_RELEASE_RESOURCE, [picture])

## poll_click_or_key_event from a routine whose frame is `locals` bytes.
func _poll_at(entry: int, locals: int) -> int:
	a7 = entry - 4 - locals - 4
	var hit: int = poll_click_or_key_event()
	a7 = entry
	return hit

const JT_BLOCK_MOVE: int = 0x4ea              ## (C: dest, src, count)
const TRAP_MODAL_DIALOG: int = 0xa991
const LOCAL_DEFAULT_RING: int = 0x1b8         ## the default-button ring installer (C: dialog, user item, default item; not exported)
const LOCAL_ADVANCE_SUMMARY: int = 0x21d6     ## advance_mission_summary_text (C: dialog, item, phase): word (not exported)

## 0x2de6: the mission summary (dialog 0x85, placed by JT $472) for `pilot` (-1: the mission's own,
## settings +0x20) in `phase`: five user items (6, 5, 7, 9, 15), items 3 and 1 disabled, the
## scrolling text in item 8, item 3 titled `title`; the twelve tallies copied into the frame (A5 -
## 0x2226 points at them; in phase 3 the mission's kills A5 - 0x12ce are added); items 1 and 4 hidden
## for a pilot, shown for the mission; the default ring on item 2 around item 3 (or 1 at the end of a
## mission); the score text; shown; the summary advanced (0x21d6) and the buttons updated when it
## says so; ModalDialog (filter A5 + 0xca) until item 3, or item 1 for a pilot, or item 1 confirmed
## (confirm_end_mission 2) for the mission (item 4 sets A5 - 0x2230 to 1 while it is set). An early
## death in phase 1 sets A5 - 0x14c0; ending the mission clears the state, hides the window A5 -
## 0x14ca and sets A5 - 0x14c4. The default item and pilot are restored; returns the item hit. In
## game state 2 the mission's summary is skipped (1).
func show_mission_summary_dialog(pilot: int, phase: int, title: int) -> int:
	assert(a7 != 0, "show_mission_summary_dialog needs a7 (its frame holds the tallies)")
	var entry: int = a7
	var a6: int = entry - 4
	var hit: int = a6 - 0xc
	memory.write_u16(hit, 1)
	var saved_pilot: int = memory.read_u16(C68kScript.u32(a5 - 0x13a4))
	var saved_default: int = memory.read_u16(C68kScript.u32(a5 - 0x225e))
	var tallies: int = a6 - 0x4a
	memory.write_u32(C68kScript.u32(a5 - 0x2226), tallies)
	var who: int = pilot & 0xffff
	if memory.read_u16(C68kScript.u32(a5 - 0x12f8)) == 2 and who == 0xffff:
		memory.write_u16(C68kScript.u32(a5 - 0x13a4), saved_pilot)
		return 1
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, 0x85]))
	_jt(JT_CENTRE_ABOUT, [dialog])
	a7 = entry - 4 - 0x4a - 0xa - 4
	for pair in [[6, 0xaa], [5, 0x152], [7, 0xea], [9, 0x7a], [0xf, 0x15a]]:
		set_dialog_user_item_proc(dialog, pair[0], C68kScript.u32(a5 + pair[1]))
	a7 = entry - 4 - 0x4a - 6 - 4
	disable_dialog_control(dialog, 3)
	disable_dialog_control(dialog, 1)
	create_scrolling_text_item(dialog, 8)
	a7 = entry - 4 - 0x4a - 0xa - 4
	set_dialog_control_title(dialog, 3, title)
	a7 = entry - 4 - 0x4a - 6 - 4
	memory.write_u16(C68kScript.u32(a5 - 0x2228), who)
	if who != 0xffff:
		memory.write_u16(C68kScript.u32(a5 - 0x13a4), who)
		memory.write_u32(C68kScript.u32(a5 - 0x2230), 1)
		_jt(JT_BLOCK_MOVE, [tallies, _roster(who) + 0x28, 0x18])
		hide_dialog_control(dialog, 1)
		hide_dialog_control(dialog, 4)
	else:
		memory.write_u16(C68kScript.u32(a5 - 0x13a4), memory.read_u16(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + 0x20))
		memory.write_u32(C68kScript.u32(a5 - 0x2230), 0x2d)
		_jt(JT_BLOCK_MOVE, [tallies, C68kScript.u32(a5 - 0x13a2), 0x18])
		show_dialog_control(dialog, 1)
		show_dialog_control(dialog, 4)
	var p: int = C68kScript.s16(phase)
	if p == 3:
		for i in 0xc:
			memory.write_u16(tallies + 2 * i, C68kScript.u16(memory.read_u16(tallies + 2 * i) + memory.read_u16(C68kScript.u32(a5 - 0x12ce + 2 * i))))
		_local(LOCAL_DEFAULT_RING, [dialog, 2, 3])
		hide_dialog_control(dialog, 4)
	elif memory.read_u16(C68kScript.u32(a5 - 0x14c4)) != 0 and memory.read_u16(C68kScript.u32(a5 - 0x2228)) == 0xffff:
		_local(LOCAL_DEFAULT_RING, [dialog, 2, 1])
	else:
		_local(LOCAL_DEFAULT_RING, [dialog, 2, 3])
	set_score_item_text(dialog, 0xe)
	a7 = entry
	_trap(TRAP_SHOW_WINDOW, [dialog])
	memory.write_u32(C68kScript.u32(a5 - 0x222c), C68kScript.u32(_trap(TRAP_TICK_COUNT, [])))
	memory.write_u16(C68kScript.u32(a5 - 0x2222), 0)
	memory.write_u16(C68kScript.u32(a5 - 0x2220), phase & 0xffff)
	if _local(LOCAL_ADVANCE_SUMMARY, [dialog, 8, phase & 0xffff]) & 0xffff != 0:
		a7 = entry - 4 - 0x4a - 6 - 4
		update_summary_dialog_buttons(dialog, phase)
		a7 = entry
	var early_death: bool = (phase & 0xff) == 1 and memory.read_u16(C68kScript.u32(a5 - 0x12b4)) != 1
	while true:
		_trap(TRAP_MODAL_DIALOG, [hit, C68kScript.u32(a5 + 0xca)])
		var item: int = memory.read_u16(hit)
		if item == 3:
			break
		if item == 4 and memory.read_u32(C68kScript.u32(a5 - 0x2230)) != 0:
			memory.write_u32(C68kScript.u32(a5 - 0x2230), 1)
		if item != 1:
			continue
		if memory.read_u16(C68kScript.u32(a5 - 0x2228)) != 0xffff:
			break
		if early_death and memory.read_u16(C68kScript.u32(a5 - 0x12b4)) != 1:
			memory.write_u16(C68kScript.u32(a5 - 0x14c0), 1)
		if confirm_end_mission() & 0xffff == 2:
			break
	dispose_scrolling_text_item()
	_trap(TRAP_DISPOSE_DIALOG, [dialog])
	var mission: bool = memory.read_u16(C68kScript.u32(a5 - 0x2228)) == 0xffff
	if mission and (phase & 0xff) == 1 and memory.read_u16(C68kScript.u32(a5 - 0x12b4)) != 1:
		memory.write_u16(C68kScript.u32(a5 - 0x14c0), 1)
	if memory.read_u16(hit) == 1 and mission:
		memory.write_u16(C68kScript.u32(a5 - 0x12f8), 0)
		_trap(TRAP_HIDE_WINDOW, [memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
		memory.write_u16(C68kScript.u32(a5 - 0x14c6), 0)
		memory.write_u16(C68kScript.u32(a5 - 0x14c4), 1)
	memory.write_u16(C68kScript.u32(a5 - 0x225e), saved_default)
	memory.write_u16(C68kScript.u32(a5 - 0x13a4), saved_pilot)
	return memory.read_u16(hit)
