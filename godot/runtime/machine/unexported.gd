extends RefCounted

## The routines the program calls that are not in the strict port (Ghidra never defined them, so
## they are outside the 740), written from the disassembly of their bytes and registered where the
## port calls them: by segment and offset (`_local`) or by jump-table slot. Each says where it is.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

var machine
var memory
var a5: int

func _init(owner) -> void:
	machine = owner
	memory = owner.memory
	a5 = owner.A5
	var segments = owner.segments
	id02 = segments.instances[2]
	segments.register_local(2, 0x1b42, func(_a: Array) -> int: return id02_1b42())
	segments.register_local(2, 0x4d24, func(_a: Array) -> int: return id02_4d24())
	segments.register_local(2, 0x4d96, func(_a: Array) -> int: return id02_4d96())
	segments.register_local(2, 0x4a4, func(_a: Array) -> int: return id02_04a4())
	segments.register_local(2, 0x95a, func(_a: Array) -> int: return id02_095a())
	segments.register_local(2, 0x9fa, func(_a: Array) -> int: return id02_09fa())
	segments.register_local(2, 0xa26, func(_a: Array) -> int: return id02_0a26())
	segments.register_local(2, 0x2da0, func(_a: Array) -> int: return id02_2da0())
	segments.register_local(2, 0x2eaa, func(_a: Array) -> int: return id02_2eaa())
	id05 = segments.instances[5]
	id06 = segments.instances[6]
	segments.register_local(5, 0x3ba, func(a: Array) -> int: return id05_03ba(a[0], a[1], a[2], a[3]))
	segments.stand_ins[0x532] = func(_a: Array) -> int: return id05_08b2()
	segments.stand_ins[0x1b2] = func(_a: Array) -> int: return id06_0858()
	segments.stand_ins[0x172] = func(_a: Array) -> int: return id04_0432()
	id04 = segments.instances[4]
	segments.stand_ins[0x132] = func(_a: Array) -> int: return id04_0644()
	segments.register_local(4, 0x1b8, func(a: Array) -> int: return id04_01b8(a[0], a[1], a[2]))
	segments.stand_ins[0x502] = func(a: Array) -> int: return id02_0434(a[0], a[1], a[2])
	segments.stand_ins[0x522] = func(a: Array) -> int: return id02_03e8(a[0])
	segments.stand_ins[0x82] = func(_a: Array) -> int: return id04_0c02()
	segments.register_local(4, 0x2dc, func(a: Array) -> int: return id04_02dc(a[0], a[1], a[2], a[3]))
	segments.register_local(3, 0x59f4, func(_a: Array) -> int: return id03_59f4())
	segments.register_local(4, 0x21d6, func(a: Array) -> int: return id04_21d6(a[0], a[1], a[2]))
	segments.register_local(4, 0x1752, func(a: Array) -> int: return id04_1752(a[0], a[1]))
	segments.stand_ins[0xca] = func(a: Array) -> int: return id04_2104(a[0], a[1], a[2])
	segments.stand_ins[0x15a] = func(a: Array) -> int: return id04_1b3e(a[0], a[1])
	segments.stand_ins[0x152] = func(a: Array) -> int: return id04_1dde(a[0], a[1])
	segments.stand_ins[0x10a] = func(_a: Array) -> int: return id04_3976()
	segments.stand_ins[0x9a] = func(_a: Array) -> int: return id04_0e70()
	segments.stand_ins[0x1d2] = func(_a: Array) -> int: return id06_00ee()
	segments.register_local(4, 0x3614, func(a: Array) -> int: return id04_3614(a[0], a[1]))
	segments.stand_ins[0x102] = func(_a: Array) -> int: return id04_137a()

var id02
var id04
var id05
var id06

## Runs a ported routine of a segment port with a stack below the ports' frames.
func _run(port, method: String, args: Array = []) -> int:
	var saved: int = port.a7
	port.a7 = machine.free_stack()
	var r = port.callv(method, args)
	port.a7 = saved
	return 0 if r == null else int(r)

func _g(offset: int) -> int:
	return (a5 + offset) & 0xffffffff

## Runs a ported ID02 routine with a stack below the ports' frames.
func _id02(method: String, args: Array = []) -> int:
	var saved: int = id02.a7
	id02.a7 = machine.free_stack()
	var r = id02.callv(method, args)
	id02.a7 = saved
	return 0 if r == null else int(r)

func _jt(offset: int, args: Array = []) -> int:
	return id02.jt_routines[offset].call(args)

func _trap(word: int, args: Array = []) -> int:
	return id02.traps[word].call(args)

## ID02 0x4d24 (apply_display_palettes in ID02.decomp.c's unexported block):
## select_palette_for_depth (0x462c), rebuild_all_palette_index_maps (0x46b4), then the overlay's
## hook A5 - 0x10a2 (configure_renderer_for_display).
func id02_4d24() -> int:
	_id02("select_palette_for_depth")
	_id02("rebuild_all_palette_index_maps")
	id02._call_address(memory.read_u32(_g(-0x10a2)), [])
	return 0

## ID02 0x4d96 (restore_screen_globals, the same file's block): SetGDevice(A5 - 0x1036), then the
## screen base / row bytes / flag back from A5 - 0x1346 / - 0x134a / - 0x1348 into A5 - 0x1382 / -
## 0x1378 / - 0x1312.
func id02_4d96() -> int:
	_trap(0xaa31, [memory.read_u32(_g(-0x1036))])
	memory.write_u32(_g(-0x1382), memory.read_u32(_g(-0x1346)))
	memory.write_u16(_g(-0x1378), memory.read_u16(_g(-0x134a)))
	memory.write_u16(_g(-0x1312), memory.read_u16(_g(-0x1348)))
	return 0

## ID02 0x4a4 (end_overlay_session): with sound on (A5 - 0x12ee) shutdown_sound (0x4318); the
## overlay's hook A5 - 0x1076; release_sound_slots (0x1e68); 0x9fa; DrawMenuBar when the menu bar
## was hidden (A5 - 0x1028).
func id02_04a4() -> int:
	if memory.read_u16(_g(-0x12ee)) != 0:
		_id02("shutdown_sound")
	id02._call_address(memory.read_u32(_g(-0x1076)), [])
	_id02("release_sound_slots")
	id02_09fa()
	if memory.read_u16(_g(-0x1028)) != 0:
		_trap(0xa937)
	return 0

## ID02 0x95a (lock_session_handles in ID02.decomp.c's unexported block): the first of nested calls
## (counter A5 - 0x14f4) locks the four session handles (A5 - 0x11f6, - 0x11dc, - 0x11d4, - 0x12b0:
## JT $272 HLock) and keeps their master pointers in A5 - 0x11f2, - 0x11d8, - 0x11d0, - 0x12ac
## (24-bit cleaned when A5 - 0x1348 is set).
func id02_095a() -> int:
	var depth: int = memory.read_u16(_g(-0x14f4))
	memory.write_u16(_g(-0x14f4), (depth + 1) & 0xffff)
	if depth != 0:
		return 0
	for h in [-0x11f6, -0x11dc, -0x11d4, -0x12b0]:
		_jt(0x272, [memory.read_u32(_g(h))])
	for pair in [[-0x11f6, -0x11f2], [-0x11dc, -0x11d8], [-0x11d4, -0x11d0], [-0x12b0, -0x12ac]]:
		var p: int = memory.read_u32(memory.read_u32(_g(pair[0])))
		if memory.read_u16(_g(-0x1348)) != 0:
			p &= 0xffffff
		memory.write_u32(_g(pair[1]), p)
	return 0

## ID02 0x9fa (unlock_session_handles, the same block): the last of the nested calls unlocks them
## (JT $27a HUnlock).
func id02_09fa() -> int:
	var depth: int = (memory.read_u16(_g(-0x14f4)) - 1) & 0xffff
	memory.write_u16(_g(-0x14f4), depth)
	if depth == 0:
		for h in [-0x12b0, -0x11f6, -0x11dc, -0x11d4]:
			_jt(0x27a, [memory.read_u32(_g(h))])
	return 0

## ID02 0xa26 (redraw_panel_readouts_locked, the same file's block): with the first two session
## handles allocated, the overlay's hook A5 - 0x1072 (its readouts and gauges, overlay 0xd23a)
## between lock_session_handles (0x95a) and unlock_session_handles (0x9fa).
func id02_0a26() -> int:
	if memory.read_u32(_g(-0x11f6)) != 0 and memory.read_u32(_g(-0x11dc)) != 0:
		id02_095a()
		id02._call_address(memory.read_u32(_g(-0x1072)), [])
		id02_09fa()
	return 0

## ID02 0x2da0 (save_changed_settings in ID02.decomp.c): changed settings (A5 - 0x138a) written:
## ChangedResource and WriteResource of the handle A5 - 0x13ac, the flag cleared.
func id02_2da0() -> int:
	if memory.read_u16(_g(-0x138a)) != 0:
		_trap(0xa9aa, [memory.read_u32(_g(-0x13ac))])
		_trap(0xa9b0, [memory.read_u32(_g(-0x13ac))])
		memory.write_u16(_g(-0x138a), 0)
	return 0

## ID02 0x2eaa (quit_application in ID02.decomp.c; quit): JT $13a must answer 2; with changed
## settings JT $ba asks (ID01's dense switch on 1..2: 1 saves them (0x2da0), 2 cancels the quit,
## others quit without saving); the game window hidden while it is up; ExitToShell.
func id02_2eaa() -> int:
	if _jt(0x13a) & 0xffff != 2:
		return 0
	if memory.read_u16(_g(-0x138a)) != 0:
		var choice: int = _jt(0xba) & 0xffff
		if choice == 1:
			id02_2da0()
		elif choice == 2:
			return 0
	if memory.read_u16(_g(-0x14c6)) != 0:
		_trap(0xa916, [memory.read_u32(_g(-0x14ca))])
	_trap(0xa9f4)
	return 0

## ID02 0x1b42 (install_overlay_service_table in ID02.decomp.c; main's set-up): the host service
## table the overlay calls through, each entry a jump-table slot address (A5 + offset), then A5 -
## 0x1040 = NewPtrClear(0x4e390), or 0x35cf0 when FreeMem is not above 1 MB.
func id02_1b42() -> int:
	var table: Array = [[-0x1122, 0x33a], [-0x111a, 0x3aa], [-0x111e, 0x372], [-0x1116, 0x3fa], [-0x1112, 0x32a],
			[-0x10f2, 0x322], [-0x10ee, 0x34a], [-0x10ea, 0x3c2], [-0x1106, 0x3d2], [-0x10fe, 0x312], [-0x1102, 0x352],
			[-0x10fa, 0x39a], [-0x10f6, 0x3f2], [-0x110e, 0x362], [-0x110a, 0x3ea], [-0x10de, 0x442], [-0x10da, 0x42a],
			[-0x10d6, 0x452], [-0x10d2, 0x43a], [-0x10ce, 0x44a], [-0x10ca, 0x432], [-0x10c6, 0x35a], [-0x1310, 0x1ba],
			[-0x130c, 0x1c2], [-0x1308, 0x19a], [-0x1304, 0x1a2], [-0x10c2, 0x31a], [-0x10be, 0x332], [-0x10ba, 0x40a],
			[-0x10b6, 0x342], [-0x10b2, 0x37a], [-0x10ae, 0x3da], [-0x10aa, 0x3b2], [-0x10a6, 0x38a]]
	for entry in table:
		memory.write_u32(a5 + entry[0], a5 + entry[1])
	var heap = machine.toolbox.heap
	var size: int = 0x4e390 if heap.free_mem() > 0x100000 else 0x35cf0
	memory.write_u32(a5 - 0x1040, heap.new_ptr(size, true))
	return 0

## ID05 0x3ba (build_protection_code_strings in ID05.decomp.c; C: code, code text, other, other
## text): builds the protection dialog's strings. The volume name buffer (A5 - 0x2c8, 0xfe bytes)
## copied into the frame; the machine's fingerprint (get_machine_screen_fingerprint, five words in
## the frame, the machine type at A6 - 2 down to the last at A6 - 0xa); the TEXT 128 pair read into
## *code / *other. When they are equal and the current volume is the original floppy (GetVol, its
## name made C and compared with A5 - 0xca) the pair is written again as (0, random_28bit_value) and
## read back. Equal: the other text is the string at A5 - 0xd66; otherwise the fields packed
## (pack_fields_to_code_buf68) followed, 6 bytes on, by encode_code28_to_buf54(*other). The code
## text is encode_long_to_buf40(*code).
func id05_03ba(code: int, code_text: int, other: int, other_text: int) -> int:
	var frame: int = machine.free_stack()
	var a6: int = frame - 4
	for k in 0xfe:                  # MOVEQ #$3e, DBF over MOVE.L (a1)+,(a0)+, then one MOVE.W
		memory.write_u8(a6 - 0x10c + k, memory.read_u8(_g(-0x2c8) + k))
	# PEA -$a .. -2 (A6): -2, pushed last, is the first argument (the machine type).
	_run(id05, "get_machine_screen_fingerprint", [a6 - 2, a6 - 4, a6 - 6, a6 - 8, a6 - 0xa])
	_run(id05, "read_TEXT128_pair", [code, other])
	if memory.read_u32(code) == memory.read_u32(other):
		_jt(0x2ba, [a6 - 0xc, a6 - 0x10c])
		var name: int = _jt(0x2fa, [a6 - 0x10c])
		if _jt(0x51a, [name, _g(-0xca)]) & 0xffff == 0:
			_run(id05, "write_TEXT128_pair", [0, _run(id05, "random_28bit_value")])
	_run(id05, "read_TEXT128_pair", [code, other])
	if memory.read_u32(other) == memory.read_u32(code):
		_jt(0x52a, [other_text, memory.read_u32(_g(-0xd66))])
	else:
		var fields: Array = []
		for off in [2, 4, 6, 8, 0xa]:
			fields.append(memory.read_u16(a6 - off))
		_jt(0x52a, [other_text, _run(id05, "pack_fields_to_code_buf68", fields)])
		_jt(0x52a, [other_text + 6, _run(id05, "encode_code28_to_buf54", [memory.read_u32(other)])])
	_jt(0x52a, [code_text, _run(id05, "encode_long_to_buf40", [memory.read_u32(code)])])
	return 0

## ID05 0x8b2 (arm_restore_gate in ID05.decomp.c; jump-table slot $532): A5 - 0xbc counts up.
func id05_08b2() -> int:
	memory.write_u16(_g(-0xbc), (memory.read_u16(_g(-0xbc)) + 1) & 0xffff)
	return 0

## ID06 0x858 (slot $1b2, release_render_buffers in ID06.decomp.c's unexported block): the
## renderer's buffers released: free_pattern_tables (0x15a: the tables at A5 - 0x1eda and - 0x1ede),
## free_edge_pool (0x582: A5 - 0x1cd6), free_row_table (0x512), then the raster target A5 - 0x1cce,
## each pointer cleared. The two unexported helpers are inlined here as their bytes read.
func id06_0858() -> int:
	for slot in [-0x1eda, -0x1ede, -0x1cd6]:
		if slot == -0x1cd6 and memory.read_u32(_g(slot)) == 0:
			continue
		_run(id06, "free_aligned", [memory.read_u32(_g(slot))])
		memory.write_u32(_g(slot), 0)
	_run(id06, "free_row_table")
	if memory.read_u32(_g(-0x1cce)) != 0:
		_run(id06, "free_aligned", [memory.read_u32(_g(-0x1cce))])
	memory.write_u32(_g(-0x1cce), 0)
	return 0

## ID04 0x432 (report_panel_store_failure in ID04.decomp.c; slot $172, run every pass of the event
## loop): a pending message (A5 - 0x14a0) is shown: JT $462, then show_caution_alert_with_number
## (JT $4ba) with the C string at A5 - 0xf42 and 0; the flag cleared.
func id04_0432() -> int:
	if memory.read_u16(_g(-0x14a0)) != 0:
		_jt(0x462)
		_jt(0x4ba, [memory.read_u32(_g(-0xf42)), 0])
		memory.write_u16(_g(-0x14a0), 0)
	return 0

## ID02 0x434 (slot $502, C strncmp(a, b, n); ansi_strncmp in ID02.decomp.c's unexported block): 0
## when the first n bytes (up to a terminator) are equal, else -1 / 1 as the first difference is
## below / above (unsigned).
func id02_0434(a: int, b: int, n: int) -> int:
	n &= 0xffffffff
	var k: int = 0
	while n > 0:
		var x: int = memory.read_u8(a + k)
		var y: int = memory.read_u8(b + k)
		if x != y:
			return 1 if x > y else 0xffffffff
		if x == 0:
			return 0
		k += 1
		n -= 1
	return 0

## ID02 0x3e8 (slot $522, C strlen; ansi_strlen in ID02.decomp.c's unexported block): the bytes
## before the first zero.
func id02_03e8(s: int) -> int:
	var n: int = 0
	while memory.read_u8(s + n) != 0:
		n += 1
	return n

## ID04 0x1b8 (install_default_ring_item in ID04.decomp.c; C: dialog, item, value): the item
## becomes a user item drawn by the procedure at slot $12a (GetDItem, SetDItem with its type and
## box), and A5 - 0x225e = value.
func id04_01b8(dialog: int, item: int, value: int) -> int:
	var f: int = machine.free_stack() - 0x10
	_trap(0xa98d, [f, f + 8, f + 0xc, item, dialog])
	_trap(0xa98e, [f, _g(0x12a), memory.read_u16(f + 0xc), item, dialog])
	memory.write_u16(_g(-0x225e), value & 0xffff)
	return 0

## ID04 0x644 (run_duty_roster_dialog in ID04.decomp.c; slot $132, the Active Duty Roster): DLOG
## 130 centred (JT $472); the pilots ranked (rank_pilots_by_score into the frame,
## prune_inactive_pilots_beyond_ten); up to ten active ones (record +0x20 clear) listed: item n+5
## their rank's name (the string table at A5 - 0xffe by record +0x22), item n+15 their name, item
## n+25 their score (compute_pilot_score through JT $4a2). The settings' pilot (+0x20) is the
## current one (A5 - 0x13a4); the field selected is its row when it is listed with a name or a
## score. Item 2 drawn by slot $12a (0x1b8), item 39 by slot $142 (set_dialog_user_item_proc).
## ModalDialog with the filter at slot $c2: Cancel (3) returns 0, item 4 shows the selected pilot's
## record (show_mission_summary_dialog with the message at A5 - 0xe4a), OK (1) writes back the
## edited names (30 bytes, strncmp / strncpy; the roster resource changed and written when one
## differs), makes the selected row's pilot current and returns 1.
func id04_0644() -> int:
	var frame: int = machine.free_stack()
	var a6: int = frame - 4
	var dlg: int = _trap(0xa97c, [0xffffffff, 0, 0x82])
	_jt(0x472, [dlg])
	_run(id04, "rank_pilots_by_score", [a6 - 0xd4, a6 - 0xfc])
	_run(id04, "prune_inactive_pilots_beyond_ten", [a6 - 0xfc])
	var records: int = memory.read_u32(memory.read_u32(_g(-0x13a8)))
	var shown: Array = []
	var box: int = a6 - 0x1a
	for i in 20:
		var pilot: int = memory.read_s16(a6 - 0xfc + 2 * i)
		var rec: int = records + (pilot << 6)
		if memory.read_u16(rec + 0x20) != 0:
			continue
		var n: int = shown.size()
		_trap(0xa98d, [box, a6 - 0x12, a6 - 0xe, n + 5, dlg])
		_trap(0xa98f, [memory.read_u32(_g(-0xffe) + 4 * memory.read_s16(rec + 0x22)), memory.read_u32(a6 - 0x12)])
		_trap(0xa98d, [box, a6 - 0x12, a6 - 0xe, n + 15, dlg])
		_trap(0xa98f, [rec, memory.read_u32(a6 - 0x12)])
		_trap(0xa98d, [box, a6 - 0x12, a6 - 0xe, n + 25, dlg])
		var score_text: int = a6 - 0x7e + 10 * n
		_jt(0x4a2, [_run(id04, "compute_pilot_score", [pilot]), score_text])
		_trap(0xa98f, [score_text, memory.read_u32(a6 - 0x12)])
		shown.append(pilot)
		if shown.size() == 10:
			break
	var settings: int = memory.read_u32(memory.read_u32(_g(-0x13ac)))
	memory.write_u16(_g(-0x13a4), memory.read_u16(settings + 0x20))
	var current: int = memory.read_s16(_g(-0x13a4))
	var selected: int = 0
	for i in shown.size():
		if shown[i] == current:
			var rec: int = records + (shown[i] << 6)
			if memory.read_u8(rec) != 0 or _run(id04, "compute_pilot_score", [shown[i]]) != 0:
				selected = i
	_trap(0xa98d, [box, a6 - 0x12, a6 - 0xe, selected + 15, dlg])
	_trap(0xa97e, [0x3e8, 0, selected + 15, dlg])
	id04_01b8(dlg, 2, 1)
	_run(id04, "set_dialog_user_item_proc", [dlg, 0x27, _g(0x142)])
	_trap(0xa915, [dlg])
	while true:
		_trap(0xa991, [a6 - 0xc, _g(0xc2)])
		var hit: int = memory.read_u16(a6 - 0xc)
		if hit == 3:
			_trap(0xa983, [dlg])
			return 0
		if hit == 4:
			var row: int = memory.read_s16(dlg + 0xa4) - 14
			_run(id04, "show_mission_summary_dialog", [shown[clampi(row, 0, shown.size() - 1)], 0, memory.read_u32(_g(-0xe4a))])
		if hit == 1:
			break
	var changed: bool = false
	for i in shown.size():
		var rec: int = records + (shown[i] << 6)
		_trap(0xa98d, [box, a6 - 0x12, a6 - 0xe, i + 15, dlg])
		_trap(0xa990, [a6 - 0x214, memory.read_u32(a6 - 0x12)])
		_jt(0x2fa, [a6 - 0x214])
		_jt(0x2fa, [rec])
		if _jt(0x502, [rec, a6 - 0x214, 0x1e]) & 0xffff != 0:          # strncmp (JT $502, 0x976)
			changed = true
			_jt(0x50a, [rec, a6 - 0x214, 0x1e])
		# As the original: a name of 30 characters or more is copied without its NUL (strncpy, 30), so
		# c2pstr runs on into record +0x1e..+0x1f up to the status word +0x20 (0 for an active pilot).
		_jt(0x302, [rec])
	if changed:
		_trap(0xa9aa, [memory.read_u32(_g(-0x13a8))])
		_trap(0xa9b0, [memory.read_u32(_g(-0x13a8))])
	var row: int = memory.read_s16(dlg + 0xa4) - 14
	memory.write_u16(_g(-0x13a4), shown[clampi(row, 0, shown.size() - 1)] & 0xffff if shown.size() > 0 else 0)
	_trap(0xa983, [dlg])
	return 1

## ID04 0x2dc (set_radio_group_selection in ID04.decomp.c; C: dialog, item numbers, count,
## selected): when `selected` is within the group (from its first to its last item) every radio
## button of the group gets value 1 if it is the selected one, else 0.
func id04_02dc(dialog: int, items: int, count: int, selected: int) -> int:
	selected = qd_s16(selected)
	count = qd_s16(count)
	if selected < memory.read_s16(items) or selected > memory.read_s16(items + 2 * (count - 1)):
		return 0
	var f: int = machine.free_stack() - 0x10
	for k in count:
		var item: int = memory.read_s16(items + 2 * k)
		_trap(0xa98d, [f, f + 8, f + 0xc, item, dialog])
		_trap(0xa963, [1 if item == selected else 0, memory.read_u32(f + 8)])
	return 0

static func qd_s16(v: int) -> int:
	v &= 0xffff
	return v - 0x10000 if v >= 0x8000 else v

## ID04 0xc02 (run_scenario_selection_dialog in ID04.decomp.c; slot $82, Select a Mission): the
## settings' scenario (+0x1e, 1 when unset) and the fuel percent (A5 - 0x12d2, 100 when unset, into
## A5 - 0x225c); DLOG 129 centred; item 2 by slot $12a (0x1b8), item 4 by slot $11a (the title),
## item 19 by slot $142, item 5 by slot $8a (the fuel bar); the scenario's radio button (scenario +
## 7, scenario 1 shown as 2) among the 8 at A5 - 0x2256 and bombs item 8 among the 3 at A5 - 0x2246
## selected. ModalDialog with the filter at slot $112: Cancel (3) returns 0; OK (1) goes on when
## confirm_end_mission answers 2; any other item selects within both groups. Then the bombs
## (selection - 6, settings +0x24), the scenario (selection - 7, +0x1e), the fuel (+0x22) and the
## pilot (+0x20, A5 - 0x13a4) are stored when they changed (A5 - 0x138a set); the dialog disposed,
## the settings applied (JT $4ca), A5 - 0x14c4 cleared, the game state A5 - 0x12f8 = the scenario,
## the overlay reset (JT $4c2); the scenario is returned.
func id04_0c02() -> int:
	var frame: int = machine.free_stack()
	var a6: int = frame - 4
	var settings: int = memory.read_u32(memory.read_u32(_g(-0x13ac)))
	var scenario: int = memory.read_s16(settings + 0x1e)
	if scenario == 0:
		scenario = 1
	if memory.read_u16(_g(-0x12d2)) == 0:
		memory.write_u16(_g(-0x12d2), 100)
	memory.write_u16(_g(-0x225c), memory.read_u16(_g(-0x12d2)))
	var dlg: int = _trap(0xa97c, [0xffffffff, 0, 0x81])
	_jt(0x472, [dlg])
	id04_01b8(dlg, 2, 1)
	_run(id04, "set_dialog_user_item_proc", [dlg, 4, _g(0x11a)])
	_run(id04, "set_dialog_user_item_proc", [dlg, 0x13, _g(0x142)])
	_run(id04, "set_dialog_user_item_proc", [dlg, 5, _g(0x8a)])
	if scenario == 1:
		scenario = 2
	id04_02dc(dlg, _g(-0x2256), 8, scenario + 7)
	id04_02dc(dlg, _g(-0x2246), 3, 8)
	_trap(0xa915, [dlg])
	while true:
		_trap(0xa991, [a6 - 6, _g(0x112)])
		var hit: int = memory.read_u16(a6 - 6)
		if hit == 3:
			_trap(0xa983, [dlg])
			return 0
		if hit == 1:
			if _run(id04, "confirm_end_mission") & 0xffff == 2:
				break
			continue
		id04_02dc(dlg, _g(-0x2256), 8, hit)
		id04_02dc(dlg, _g(-0x2246), 3, hit)
	var bombs: int = _run(id04, "get_radio_group_selection", [dlg, _g(-0x2246), 3])
	settings = memory.read_u32(memory.read_u32(_g(-0x13ac)))
	if qd_s16(bombs) != -1 and qd_s16(bombs - 6) != memory.read_s16(settings + 0x24):
		memory.write_u16(settings + 0x24, (bombs - 6) & 0xffff)
		memory.write_u16(_g(-0x138a), 1)
	var mission: int = _run(id04, "get_radio_group_selection", [dlg, _g(-0x2256), 8])
	if qd_s16(mission) != -1 and qd_s16(mission - 7) != memory.read_s16(settings + 0x1e):
		memory.write_u16(settings + 0x1e, (mission - 7) & 0xffff)
		memory.write_u16(_g(-0x138a), 1)
	if memory.read_u16(settings + 0x22) != memory.read_u16(_g(-0x225c)):
		memory.write_u16(settings + 0x22, memory.read_u16(_g(-0x225c)))
		memory.write_u16(_g(-0x138a), 1)
	if memory.read_u16(settings + 0x20) != memory.read_u16(_g(-0x13a4)):
		memory.write_u16(settings + 0x20, memory.read_u16(_g(-0x13a4)))
		memory.write_u16(_g(-0x138a), 1)
	_trap(0xa983, [dlg])
	_jt(0x4ca)
	memory.write_u16(_g(-0x14c4), 0)
	memory.write_u16(_g(-0x12f8), memory.read_u16(settings + 0x1e))
	_jt(0x4c2)
	return memory.read_u16(_g(-0x12f8))

## ID03 0x59f4 (release_panel_bitmaps in ID03.decomp.c): the four session handles (A5 - 0x11f6, -
## 0x11dc, - 0x11d4, - 0x12b0) released: a resource (the current scenery record's word +0xc set:
## *(A5 - 0x13b2) + 0x160 * A5 - 0x211e) by ReleaseResource, otherwise by DisposeHandle (JT $25a);
## each cleared.
func id03_59f4() -> int:
	for slot in [-0x11f6, -0x11dc, -0x11d4, -0x12b0]:
		var h: int = memory.read_u32(_g(slot))
		if h == 0:
			continue
		var record: int = memory.read_u32(memory.read_u32(_g(-0x13b2))) + memory.read_s16(_g(-0x211e)) * 0x160
		if memory.read_u16(record + 0xc) != 0:
			_trap(0xa9a3, [h])
		else:
			_jt(0x25a, [h])
		memory.write_u32(_g(slot), 0)
	return 0

# ---- the mission summary (ID04) --------------------------------------------------------------------

## A frame for a routine written here: its a6 below the ports' frames, with ID04's a7 lowered past
## its `size` bytes of locals so the routines it calls stack below them. [a6, ID04's a7 to restore]
func _enter(size: int) -> Array:
	var saved: int = id04.a7
	var a6: int = machine.free_stack() - 4
	id04.a7 = a6 - size
	return [a6, saved]

func _w(offset: int) -> int:
	return memory.read_u16(_g(offset))

func _sw(offset: int) -> int:
	return qd_s16(memory.read_u16(_g(offset)))

func _set_w(offset: int, v: int) -> void:
	memory.write_u16(_g(offset), v & 0xffff)

## The current pilot's 64-byte roster record (handle A5 - 0x13a8, pilot A5 - 0x13a4).
func _pilot_record() -> int:
	return (memory.read_u32(memory.read_u32(_g(-0x13a8))) + (_sw(-0x13a4) << 6)) & 0xffffffff

## The summary's message list (A5 - 0x21c6, next slot A5 - 0x21ca): the string pointer at A5 + off.
func _push_message(off: int) -> void:
	_push_pointer(memory.read_u32(_g(off)))

func _push_pointer(p: int) -> void:
	var at: int = memory.read_u32(_g(-0x21ca))
	memory.write_u32(at, p & 0xffffffff)
	memory.write_u32(_g(-0x21ca), (at + 4) & 0xffffffff)

func _append_line(dialog: int, item: int, line: int) -> void:
	_run(id04, "append_line_to_scrolling_text", [dialog, item, line & 0xffffffff])

func _roster_changed() -> void:
	_trap(0xa9aa, [memory.read_u32(_g(-0x13a8))])
	_trap(0xa999, [_w(-0x1002)])

## ID04 0x21d6 (C: dialog, item, phase): advance_mission_summary_text, one step of the summary's
## text (item 8) per call, by stage (A5 - 0x2222). Stage 0 collects the outcome's messages by the
## phase's low byte, its high byte (bit 0, bit 1) and the outcome (A5 - 0x12b4), then a promotion
## (A5 - 0x12b6: five or more missions gives the outcome 1, else the record's word +0x24 counts up
## to 3 commendations, the third the outcome 4) and the kill report (A5 - 0x12ba) when it applies;
## phase 3 writes its lines at once. Stage 1 appends one message per call, then stage 2 (the
## mission's own pilot) or the end. Stage 2: the medal for the scenario (A5 - 0x12f8, record +0x26
## bit (scenario - 3)) on success, then the kills (stage 3) unless there are none. Stage 3: one kind
## of kill per call ("n name[s]"), added to the record, the pilot's and the shown tallies, and the
## score, row and markers redrawn. Stage 4: a rank reached (score against A5 - 0xfd6 by rank + 1)
## gives the promotion messages (stage 5, one per call, then the new rank's line and items 15 and 9
## redrawn). The end is stage 100 and returns 1; a step otherwise returns 0.
func id04_21d6(dialog: int, item: int, phase: int) -> int:
	var f: Array = _enter(0x5e)
	var r: int = _id04_21d6(f[0], dialog, item, phase & 0xffff)
	id04.a7 = f[1]
	return r

func _id04_21d6(a6: int, dialog: int, item: int, phase: int) -> int:
	var skip: bool = false          # -0x46
	var kills: bool = false         # -0x48
	var low: int = phase & 0xff
	var high: int = phase >> 8
	match _sw(-0x2222):
		0:
			memory.write_u32(_g(-0x21ca), _g(-0x21c6))
			match low:
				1:
					if _sw(-0x12b4) == 1:
						if _w(-0x12b2) != 0:
							_push_message(-0xeea)
						else:
							_push_message(-0xee6)
							_push_message([-0xee2, -0xede, -0xeda, -0xed6][(_trap(0xa975) >> 2) & 3])
					else:
						_push_message(-0xed2)
				6, 7:
					kills = true
					_push_message(-0x221e if low == 6 else -0x21d2)
					if _sw(-0x12b4) == 4:
						_push_message(-0x220a if low == 6 else -0x21ce)
						_push_message(-0x2206)
					elif high & 2:
						_push_message(-0x21f6)
						match _sw(-0x12b4):
							0: _push_message(-0x21ee)
							1: _push_message(-0x21ea if low == 6 else -0x21de)
					else:
						_push_message(-0x21fe if high & 1 else -0x21fa)
						match _sw(-0x12b4):
							0: _push_message(-0x21f2)
							1: _push_message(-0x21ea if low == 6 else -0x21de)
							3:
								_push_message(-0x21e6)
								_push_message(-0x21e2)
				10:
					kills = true
					for off in [-0x2216, -0x2212, -0x21e6, -0x21e2]:
						_push_message(off)
				8:
					kills = true
					_push_message(-0x221a)
					if high & 2:
						match _sw(-0x12b4):
							0: _push_message(-0x21ee)
							5: _push_message(-0x21de)
					else:
						_push_message(-0x21fe if high & 1 else -0x21fa)
						match _sw(-0x12b4):
							0: _push_message(-0x21f2)
							5: _push_message(-0x21de)
							3:
								_push_message(-0x21e6)
								_push_message(-0x21e2)
				9:
					_push_message(-0x220e)
					if high & 1:
						_push_message(-0x21fe)
						if _sw(-0x12b4) == 3:
							kills = true
							_push_message(-0x21e6)
							_push_message(-0x21e2)
						else:
							_push_message(-0x21da)
							_push_message(-0x21d6)
				3:
					_append_line(dialog, item, memory.read_u32(_g(-0xece)))
					var report: int = _run(id04, "get_mission_kill_report_state")
					if _sw(-0x12b4) == 1:
						_append_line(dialog, item, memory.read_u32(_g(-0xeca)))
					elif report == 1:
						_append_line(dialog, item, memory.read_u32(_g(-0xec6)))
					elif report == 2:
						_append_line(dialog, item, memory.read_u32(_g(-0xec2)))
					if _w(-0x14c0) == 0:
						if _sw(-0x12ba) == -1:
							match _sw(-0x12f8):
								5: _append_line(dialog, item, memory.read_u32(_g(-0xebe)))
								6: _append_line(dialog, item, memory.read_u32(_g(-0xeba)))
								7, 9: _append_line(dialog, item, memory.read_u32(_g(-0xeb6)))
						elif _sw(-0x12ba) == -2:
							_append_line(dialog, item, memory.read_u32(_g(-0xeb2)))
					_set_w(-0x2222, 100)
					return 1
				_:
					skip = true
			if not skip and _sw(-0x12b4) == 0 and _w(-0x12b6) != 0:
				_push_message(-0x2202)
				if _sw(-0x12b6) >= 5:
					_push_message(-0xeae)
					_push_message(-0xeaa)
					_set_w(-0x12b4, 1)
					_set_w(-0x14c4, 1)
				else:
					var rec: int = _pilot_record()
					memory.write_u16(rec + 0x24, (memory.read_u16(rec + 0x24) + 1) & 0xffff)
					_roster_changed()
					match qd_s16(memory.read_u16(_pilot_record() + 0x24)):
						1:
							_push_message(-0xea6)
							_push_message(-0xea2)
						2:
							_push_message(-0xe9e)
							_push_message(-0xe9a)
						3:
							_push_message(-0xe96)
							_push_message(-0x2206)
							_set_w(-0x12b4, 4)
							_set_w(-0x14c4, 1)
				_set_w(-0x12b6, 0)
			if kills and _w(-0x14c0) == 0 and _sw(-0x12b4) == 0:
				if _sw(-0x12ba) > 0:
					_push_pointer(_g(-0x2134))
					_push_message(-0xe92)
					_push_message(-0xe8e)
				elif _sw(-0x12ba) == 0:
					_push_pointer(_g(-0x2132))
					_push_message(-0xe8a)
					_push_message(-0xe86)
				_set_w(-0x12ba, -2)
			_set_w(-0x2176, (memory.read_u32(_g(-0x21ca)) - _g(-0x21c6)) >> 2)
			memory.write_u32(_g(-0x21ca), _g(-0x21c6))
			_set_w(-0x2222, 1)
			return 0
		1:
			var left: int = _w(-0x2176)
			_set_w(-0x2176, left - 1)
			if left != 0:
				_append_line(dialog, item, _pop_message())
				return 0
			if _w(-0x2228) == 0xffff:
				_set_w(-0x2222, 2)
				return 0
			_append_line(dialog, item, memory.read_u32(_g(-0xe82)))
			_set_w(-0x2222, 100)
			return 1
		2:
			_append_line(dialog, item, _g(-0x2130))
			if low == 1 and _sw(-0x12b4) != 1:
				var saved: int = memory.read_u32(_g(-0x160c))
				var rec: int = _pilot_record()
				var shift: int = (_w(-0x12f8) - 3) & 0xffff
				var bit: int = (1 << (shift & 63)) & 0xffff if (shift & 63) < 16 else 0
				memory.write_u16(rec + 0x26, memory.read_u16(rec + 0x26) | bit)
				_roster_changed()
				_redraw_item(dialog, 5, a6, -4, -4)
				_trap(0xa873, [saved])
			if _run(id04, "get_mission_kill_report_state") == 0:
				_append_line(dialog, item, memory.read_u32(_g(-0xe7e)))
				_set_w(-0x2222, 100)
				return 1
			_append_line(dialog, item, memory.read_u32(_g(-0xe7a)))
			_append_line(dialog, item, memory.read_u32(_g(-0xe76)))
			_set_w(-0x2222, 3)
			_set_w(-0x2176, 0)
			return 0
		3:
			if _id04_21d6_kill(a6, dialog, item):
				return 0
			return _id04_21d6_rank(dialog)
		4:
			return _id04_21d6_rank(dialog)
		5:
			var left: int = _w(-0x2176)
			_set_w(-0x2176, left - 1)
			if left != 0:
				_append_line(dialog, item, _pop_message())
				return 0
			var saved: int = memory.read_u32(_g(-0x160c))
			var name: int = memory.read_u32(_g(-0xffe) + 4 * qd_s16(memory.read_u16(_pilot_record() + 0x22)))
			_jt(0x2fa, [name])
			var line: int = a6 - 0x44
			_jt(0x52a, [line, memory.read_u32(_g(-0xe66 if _sw(-0x12b4) == 1 else -0xe62))])
			_jt(0x512, [line, name])
			_jt(0x512, [line, _g(-0x212a)])
			_jt(0x302, [name])
			_append_line(dialog, item, line)
			_trap(0xa873, [dialog])     # once: the two redraws below set no port of their own
			_redraw_item(dialog, 0xf, a6, -0x24, -4, false)
			_redraw_item(dialog, 9, a6, -4, -4, false)
			_trap(0xa873, [saved])
			_set_w(-0x2222, 100)
			return 1
	return 0

func _pop_message() -> int:
	var at: int = memory.read_u32(_g(-0x21ca))
	memory.write_u32(_g(-0x21ca), (at + 4) & 0xffffffff)
	return memory.read_u32(at)

## SetPort(dialog) (unless set_port is false: stage 5 sets it once for two items); the item's box
## (GetDItem into the frame at a6 - 0x56) inset by (dh, dv), erased and invalidated.
func _redraw_item(dialog: int, item: int, a6: int, dh: int, dv: int, set_port: bool = true) -> void:
	if set_port:
		_trap(0xa873, [dialog])
	var box: int = a6 - 0x56
	_trap(0xa98d, [box, a6 - 0x4e, a6 - 0x4a, item, dialog])
	_trap(0xa8a9, [dv & 0xffff, dh & 0xffff, box])
	_trap(0xa8a3, [box])
	_trap(0xa928, [box])

## Stage 3 of 0x21d6: the next kind with mission kills (A5 - 0x12ce, from A5 - 0x2176) reported;
## false (stage 4 next, the message list reset, the roster written) when none is left.
func _id04_21d6_kill(a6: int, dialog: int, item: int) -> bool:
	var kind: int = 0
	var count: int = 0
	while _sw(-0x2176) < 10:
		kind = _sw(-0x2176)
		count = qd_s16(memory.read_u16(_g(-0x12ce) + 2 * kind))
		if count != 0:
			break
		_set_w(-0x2176, _w(-0x2176) + 1)
	var at: int = _sw(-0x2176)
	_set_w(-0x2176, at + 1)
	if at >= 10:
		_roster_changed()
		_set_w(-0x2222, 4)
		memory.write_u32(_g(-0x21ca), _g(-0x21c6))
		return false
	var line: int = a6 - 0x44
	_jt(0x2fa, [_jt(0x4a2, [count & 0xffffffff, line])])
	_jt(0x512, [line, _g(-0x212e)])
	_jt(0x512, [line, memory.read_u32(_g(-0xf86) + 4 * kind)])
	var rec: int = _pilot_record() + 2 * kind
	memory.write_u16(rec + 0x28, (memory.read_u16(rec + 0x28) + count) & 0xffff)
	memory.write_u16(_g(-0x12ce) + 2 * kind, 0)
	memory.write_u16(_g(-0x13a2) + 2 * kind, (memory.read_u16(_g(-0x13a2) + 2 * kind) + count) & 0xffff)
	var shown: int = (memory.read_u32(_g(-0x2226)) + 2 * kind) & 0xffffffff
	memory.write_u16(shown, (memory.read_u16(shown) + count) & 0xffff)
	if count > 1:
		_jt(0x512, [line, _g(-0x212c)])
	_append_line(dialog, item, line)
	_run(id04, "set_score_item_text", [dialog, 0xe])
	_run(id04, "draw_targets_destroyed_row", [dialog, 6, kind])
	_run(id04, "draw_aircraft_kill_markers", [dialog, 7])
	return true

## Stage 4 of 0x21d6: a score reaching the next rank's (A5 - 0xfd6) gives the promotion messages and
## the highest rank the score reaches (record +0x22, the roster written), then stage 5; else the end.
func _id04_21d6_rank(_dialog: int) -> int:
	var score: int = C68kScript.s32(_run(id04, "compute_pilot_score", [_w(-0x13a4)]))
	var rec: int = _pilot_record()
	var next: int = C68kScript.s32(memory.read_u32(_g(-0xfd6) + 4 * (qd_s16(memory.read_u16(rec + 0x22)) + 1)))
	if score < next:
		_set_w(-0x2222, 100)
		return 1
	if _sw(-0x12b4) == 1:
		_push_message(-0xe72)
	else:
		_push_message(-0xe6e)
		_push_message(-0xe6a)
	var rank: int = 0
	while C68kScript.s32(memory.read_u32(_g(-0xfd6) + 4 * rank)) <= score:
		rank += 1
	memory.write_u16(_pilot_record() + 0x22, (rank - 1) & 0xffff)
	_roster_changed()
	_set_w(-0x2176, (memory.read_u32(_g(-0x21ca)) - _g(-0x21c6)) >> 2)
	memory.write_u32(_g(-0x21ca), _g(-0x21c6))
	_set_w(-0x2222, 5)
	return 0

## ID04 0x2104 (mission_summary_filter_proc in ID04.decomp.c; slot $ca, the summary's ModalDialog
## filter, Pascal (dialog, event, VAR item)): Return or Enter give the default item (A5 - 0x225e)
## once the text is done (A5 - 0x2230 clear); a click on the text's scroll bar (0x1752) gives item
## 8; an update goes to JT $492. Otherwise, once |TickCount - A5 - 0x222c| (as a word) reaches A5 -
## 0x2230, the text advances a step (0x21d6 with the phase A5 - 0x2220), the buttons are updated
## when it ends, and the time is taken again.
func id04_2104(dialog: int, event: int, item_hit: int) -> int:
	match memory.read_u16(event):
		3:
			var c: int = memory.read_u32(event + 2) & 0xff
			if (c == 13 or c == 3) and memory.read_u32(_g(-0x2230)) == 0:
				memory.write_u16(item_hit, _w(-0x225e))
				return 1
		1:
			if id04_1752(dialog, event) != 0:
				memory.write_u16(item_hit, 8)
				return 1
		6:
			_jt(0x492, [event])
	var elapsed: int = qd_s16(_jt(0x4da, [(_trap(0xa975) - memory.read_u32(_g(-0x222c))) & 0xffffffff]))
	if elapsed < C68kScript.s32(memory.read_u32(_g(-0x2230))):
		return 0
	if id04_21d6(dialog, 8, _w(-0x2220)) & 0xffff != 0:
		_run(id04, "update_summary_dialog_buttons", [dialog, 0])
	memory.write_u32(_g(-0x222c), _trap(0xa975) & 0xffffffff)
	return 0

## ID04 0x1752 (track_summary_text_click in ID04.decomp.c; C: dialog, event): a click in the dialog
## (its where, local) on the scrolling text's bar (A5 - 0x2236) is tracked: the thumb (part 129)
## without an action and the text synced, other parts with the action procedure at slot $16a; 1
## then, 0 for anything else. The port is restored.
func id04_1752(dialog: int, event: int) -> int:
	var f: Array = _enter(0x12)
	var a6: int = f[0]
	memory.write_u32(a6 - 0x10, memory.read_u32(event + 0xa))
	var result: int = 1
	_trap(0xa874, [a6 - 0xc])
	_trap(0xa873, [dialog])
	_trap(0xa871, [a6 - 0x10])
	var pt: int = memory.read_u32(a6 - 0x10)
	var part: int = qd_s16(_trap(0xa96c, [a6 - 6, dialog, pt]))
	if part == 0:
		result = 0
	elif memory.read_u32(a6 - 6) == memory.read_u32(_g(-0x2236)):
		if part == 0x81:
			_trap(0xa968, [0, pt, memory.read_u32(a6 - 6)])
			_run(id04, "sync_text_scroll_to_control")
		else:
			_trap(0xa968, [_g(0x16a), pt, memory.read_u32(a6 - 6)])
	else:
		result = 0
	_trap(0xa873, [memory.read_u32(a6 - 0xc)])
	id04.a7 = f[1]
	return result

## ID04 0x1b3e (draw_rank_insignia in ID04.decomp.c; slot $15a, a user item procedure, Pascal
## (dialog, item)): the pilot's rank insignia (cicn 256 + record +0x22) at the item box's top
## right, at the icon's own size.
func id04_1b3e(dialog: int, item: int) -> int:
	var f: Array = _enter(0x1a)
	var a6: int = f[0]
	_trap(0xa98d, [a6 - 0xe, a6 - 6, a6 - 2, item, dialog])
	var icon: int = _trap(0xaa1e, [(memory.read_u16(_pilot_record() + 0x22) + 0x100) & 0xffff])
	_place_icon(icon, a6 - 0xe)
	_trap(0xaa1f, [icon, a6 - 0xe])
	_trap(0xaa25, [icon])
	id04.a7 = f[1]
	return 0

## The rect at `r` keeps its top and right; its left and bottom take the colour icon's size (its
## PixMap bounds, +6).
func _place_icon(icon: int, r: int) -> void:
	var b: int = memory.read_u32(icon) + 6
	var w: int = memory.read_u16(b + 6) - memory.read_u16(b + 2)
	var h: int = memory.read_u16(b + 4) - memory.read_u16(b)
	memory.write_u16(r + 2, (memory.read_u16(r + 6) - w) & 0xffff)
	memory.write_u16(r + 4, (h + memory.read_u16(r)) & 0xffff)

## ID04 0x1dde (draw_mission_awards in ID04.decomp.c; slot $152, a user item procedure, Pascal
## (dialog, item)): the item's box framed (frame_dialog_item_box); in the dialog (clipped to the
## port at A5 - 0x160c's rect, the port left set) the pilot's medals (record +0x26, bit k for medal
## k of 8) in three columns: each a 60 x 18 frame centred at (w * column / 3, h * row / 3) + the
## box's top left + (32, 11), its cicn (512 + k) at the frame's top right.
func id04_1dde(dialog: int, item: int) -> int:
	var f: Array = _enter(0x36)
	var a6: int = f[0]
	_run(id04, "frame_dialog_item_box", [dialog, item])
	_trap(0xa873, [dialog])
	_trap(0xa87b, [memory.read_u32(_g(-0x160c)) + 0x10])
	_trap(0xa98d, [a6 - 0x1e, a6 - 0x16, a6 - 0x12, item, dialog])
	var box: Rect2i = qd_rect(a6 - 0x1e)
	var w: int = box.size.x
	var h: int = box.size.y
	var column: int = 0
	var row: int = 0
	var medals: int = qd_s16(memory.read_u16(_pilot_record() + 0x26))
	var r: int = a6 - 0x26
	for k in 8:
		if medals & 1:
			var x: int = C68kScript.divs_trunc(qd_s16(w * column), 3)
			var y: int = C68kScript.divs_trunc(qd_s16(h * row), 3)
			memory.write_u16(r, (y - 9) & 0xffff)
			memory.write_u16(r + 4, (y - 9 + 0x12) & 0xffff)
			memory.write_u16(r + 2, (x - 30) & 0xffff)
			memory.write_u16(r + 6, (x - 30 + 0x3c) & 0xffff)
			_trap(0xa8a8, [(box.position.y + 0xb) & 0xffff, (box.position.x + 0x20) & 0xffff, r])
			_trap(0xa8a1, [r])
			var icon: int = _trap(0xaa1e, [0x200 + k])
			_place_icon(icon, r)
			_trap(0xaa1f, [icon, r])
			_trap(0xaa25, [icon])
			column += 1
			if column == 3:
				column = 0
				row += 1
		medals >>= 1
	id04.a7 = f[1]
	return 0

func qd_rect(at: int) -> Rect2i:
	var top: int = qd_s16(memory.read_u16(at))
	var left: int = qd_s16(memory.read_u16(at + 2))
	return Rect2i(left, top, qd_s16(memory.read_u16(at + 6)) - left, qd_s16(memory.read_u16(at + 4)) - top)

## ID04 0x3976 (run_map_dialog in ID04.decomp.c; slot $10a, Mission Map): not in scenario 2 (A5 -
## 0x12f8); DLOG 0x89 centred (JT $472), item 8 drawn by the map procedure at slot $b2, the default
## ring on item 1 (0x1b8 with 2, 1), shown; ModalDialog with the filter at slot $d2 until OK (1):
## item 3 halves the settings' map scale (+0x26, while above 1), item 4 doubles it (asl.w, while
## below 0x100), each redrawing the map (draw_map_view_item, item 8). The dialog disposed.
func id04_3976() -> int:
	if _sw(-0x12f8) == 2:
		return 0
	var f: Array = _enter(0x2a)
	var a6: int = f[0]
	memory.write_u16(a6 - 0xc, 1)
	var dlg: int = _trap(0xa97c, [0xffffffff, 0, 0x89]) & 0xffffffff
	_jt(0x472, [dlg])
	_run(id04, "set_dialog_user_item_proc", [dlg, 8, _g(0xb2)])
	id04_01b8(dlg, 2, 1)
	_trap(0xa915, [dlg])
	while true:
		_trap(0xa991, [a6 - 0xc, _g(0xd2)])
		var item: int = qd_s16(memory.read_u16(a6 - 0xc))
		var settings: int = memory.read_u32(memory.read_u32(_g(-0x13ac)))
		var scale: int = qd_s16(memory.read_u16(settings + 0x26))
		if item == 3 and scale > 1:
			memory.write_u16(settings + 0x26, C68kScript.divs_trunc(scale, 2) & 0xffff)
			_run(id04, "draw_map_view_item", [dlg, 8])
		if item == 4 and scale < 0x100:
			memory.write_u16(settings + 0x26, (scale << 1) & 0xffff)
			_run(id04, "draw_map_view_item", [dlg, 8])
		if item == 1:
			break
	_trap(0xa983, [dlg])
	id04.a7 = f[1]
	return 0

## ID04 0x137a (run_high_scores_dialog in ID04.decomp.c; slot $102, High Scores): DLOG 0x86 centred
## (JT $472), the default ring on item 1 (0x1b8 with 2, 1), item 8 drawn by slot $142 and item 10
## (the table) by slot $e2, shown; ModalDialog (no filter) until OK (1). Item 3 (erase) asks
## confirm_erase_high_scores: on 2 every retired pilot (record +0x20 set) of the twenty is reset
## (reset_pilot_record) with the roster locked (JT $272 / $27a); when any was, the roster is marked
## changed and written and item 10's box invalidated (in the dialog's port, the port at A5 - 0x160c
## restored). The dialog disposed.
func id04_137a() -> int:
	var f: Array = _enter(0x22)
	var a6: int = f[0]
	var dlg: int = _trap(0xa97c, [0xffffffff, 0, 0x86]) & 0xffffffff
	_jt(0x472, [dlg])
	id04_01b8(dlg, 2, 1)
	_run(id04, "set_dialog_user_item_proc", [dlg, 8, _g(0x142)])
	_run(id04, "set_dialog_user_item_proc", [dlg, 10, _g(0xe2)])
	_trap(0xa915, [dlg])
	while true:
		_trap(0xa991, [a6 - 0xc, 0])
		var item: int = qd_s16(memory.read_u16(a6 - 0xc))
		if item == 3 and qd_s16(_run(id04, "confirm_erase_high_scores")) == 2:
			_jt(0x272, [memory.read_u32(_g(-0x13a8))])
			var any: bool = false
			for pilot in 0x14:
				var rec: int = memory.read_u32(memory.read_u32(_g(-0x13a8))) + (pilot << 6)
				if memory.read_u16(rec + 0x20) != 0:
					_run(id04, "reset_pilot_record", [pilot])
					any = true
			_jt(0x27a, [memory.read_u32(_g(-0x13a8))])
			if any:
				var saved: int = memory.read_u32(_g(-0x160c))
				_trap(0xa9aa, [memory.read_u32(_g(-0x13a8))])
				_trap(0xa9b0, [memory.read_u32(_g(-0x13a8))])
				_trap(0xa873, [dlg])
				_trap(0xa98d, [a6 - 0x1a, a6 - 0x12, a6 - 0xe, 10, dlg])
				_trap(0xa928, [a6 - 0x1a])
				_trap(0xa873, [saved])
		if item == 1:
			break
	_trap(0xa983, [dlg])
	id04.a7 = f[1]
	return 0

## ID04 0x3614 (track_map_bearing_and_distance in ID04.decomp.c; C: dialog, event): a click inside
## the Mission Map's item 8 (the event's where, local) is tracked while the button is down: a
## 2 x 2 XOR line (PenMode 2) from the map's centre to the mouse, the previous one erased, clipped
## to the map; for each new point item 5 shows the bearing, 360 - angle * 360 / 0x4000 with the
## angle the heading attitude_from_velocity (the service at A5 - 0x1056) gives for (dx, 0, -dy,
## 0, dx * dx + dy * dy), and A5 - 0x2122 after it; item 6 the distance, the square root (the
## service at A5 - 0x105a) of dx * dx + dy * dy times the map scale (settings +0x26) over the
## map's width / 40, as "<d / 10>" A5 - 0x2120 "<d % 10>" and STR# 129's " mi." (*(A5 - 0xe56)).
## The last line is erased on release; pen size 1 and the port at A5 - 0x160c are restored.
func id04_3614(dialog: int, event: int) -> int:
	var f: Array = _enter(0x82)
	var a6: int = f[0]
	memory.write_u16(a6 - 0x12, 0)
	memory.write_u32(a6 - 0x2c, memory.read_u32(_g(-0x160c)))
	_trap(0xa873, [dialog])
	_trap(0xa98d, [a6 - 0x20, a6 - 0x18, a6 - 0x14, 8, dialog])
	memory.write_u32(a6 - 0x24, memory.read_u32(event + 0xa))
	_trap(0xa871, [a6 - 0x24])
	if (_trap(0xa8ad, [a6 - 0x20, memory.read_u32(a6 - 0x24)]) >> 8) & 0xff != 0:
		var top: int = _sw16(a6 - 0x20)
		var left: int = _sw16(a6 - 0x1e)
		var w: int = qd_s16(_sw16(a6 - 0x1a) - left)
		var h: int = qd_s16(_sw16(a6 - 0x1c) - top)
		memory.write_u16(a6 - 6, w & 0xffff)
		memory.write_u16(a6 - 8, h & 0xffff)
		var cx: int = qd_s16(C68kScript.divs_trunc(w, 2) + left)
		var cy: int = qd_s16(C68kScript.divs_trunc(h, 2) + top)
		_trap(0xa89b, [2, 2])
		memory.write_u16(a6 - 0x26, cx & 0xffff)
		memory.write_u16(a6 - 0x28, cy & 0xffff)
		while true:
			var inside: bool = (_trap(0xa8ad, [a6 - 0x20, memory.read_u32(a6 - 0x24)]) >> 8) & 0xff != 0
			var moved: bool = memory.read_u32(a6 - 0x24) != memory.read_u32(a6 - 0x28)
			if inside and moved:
				_track_map_point(dialog, a6, cx, cy, w)
			_trap(0xa972, [a6 - 0x24])
			if (_trap(0xa974) >> 8) & 0xff == 0:
				break
		if memory.read_u16(a6 - 0x12) != 0:
			_trap(0xa89c, [2])
			_trap(0xa893, [cy & 0xffff, cx & 0xffff])
			_trap(0xa891, [memory.read_u16(a6 - 0x28), memory.read_u16(a6 - 0x26)])
			_trap(0xa89c, [0])
	_trap(0xa89b, [1, 1])
	_trap(0xa873, [memory.read_u32(a6 - 0x2c)])
	id04.a7 = f[1]
	return 0

func _sw16(at: int) -> int:
	return qd_s16(memory.read_u16(at))

## One point of track_map_bearing_and_distance: the old line erased and the new drawn, the
## bearing into item 5 and the distance into item 6.
func _track_map_point(dialog: int, a6: int, cx: int, cy: int, w: int) -> void:
	_trap(0xa87b, [a6 - 0x20])
	_trap(0xa89c, [2])
	if memory.read_u16(a6 - 0x12) != 0:
		_trap(0xa893, [cy & 0xffff, cx & 0xffff])
		_trap(0xa891, [memory.read_u16(a6 - 0x28), memory.read_u16(a6 - 0x26)])
	_trap(0xa893, [cy & 0xffff, cx & 0xffff])
	_trap(0xa891, [memory.read_u16(a6 - 0x24), memory.read_u16(a6 - 0x22)])
	memory.write_u32(a6 - 0x28, memory.read_u32(a6 - 0x24))
	memory.write_u16(a6 - 0x12, 1)
	_trap(0xa89c, [0])
	_trap(0xa87b, [memory.read_u32(_g(-0x160c)) + 0x10])
	var dx: int = qd_s16(_sw16(a6 - 0x22) - cx)
	var dy: int = qd_s16(_sw16(a6 - 0x24) - cy)
	var r2: int = (dx * dx + dy * dy) & 0xffffffff
	machine.segments.call_procedure(memory.read_u32(_g(-0x1056)),
			[dx & 0xffffffff, 0, (-dy) & 0xffffffff, 0, r2, a6 - 0x80, a6 - 0x82])
	var deg: int = C68kScript.divs_trunc(C68kScript.s32(_sw16(a6 - 0x82) * 0x168), 0x4000)
	var line: int = a6 - 0x64
	_jt(0x2fa, [_jt(0x4a2, [(0x168 - deg) & 0xffffffff, line])])
	_jt(0x512, [line, _g(-0x2122)])
	_jt(0x302, [line])
	_run(id04, "set_dialog_item_text", [dialog, 5, line])
	var root: int = qd_s16(machine.segments.call_procedure(memory.read_u32(_g(-0x105a)), [r2]))
	var scale: int = _sw16(memory.read_u32(memory.read_u32(_g(-0x13ac))) + 0x26)
	var per: int = qd_s16(C68kScript.divs_trunc(w, 0x28))
	var dist: int = C68kScript.divs_trunc(C68kScript.s32(scale * root), per)
	var tenths: int = dist - C68kScript.divs_trunc(dist, 10) * 10
	_jt(0x2fa, [_jt(0x4a2, [C68kScript.divs_trunc(dist, 10) & 0xffffffff, line])])
	_jt(0x512, [line, _g(-0x2120)])
	_jt(0x512, [line, _jt(0x2fa, [_jt(0x4a2, [tenths & 0xffffffff, a6 - 0x6e])])])
	_jt(0x512, [line, memory.read_u32(_g(-0xe56))])
	_jt(0x302, [line])
	_run(id04, "set_dialog_item_text", [dialog, 6, line])

## ID04 0xe70 (slot $9a, run_refuel_dialog in ID04.decomp.c): the fuel slider starts at the
## current load (A5 - 0x225c = A5 - 0x12d2); DLOG 0x84 centred (JT $472), the default ring on item
## 1 (install_default_ring_item with 2, 1), item 3 the percent bar (slot $8a), the bomb radios
## (the item list A5 - 0x2240, three of them) set to item 6, shown; ModalDialog with the filter at
## slot $14a until OK (1), each other hit given to set_radio_group_selection (the slider's item
## 3 falls outside the group). Then the bombs (A5 - 0x12d0) = the selected radio - 4 when one is,
## the fuel (A5 - 0x12d2) = the slider's A5 - 0x225c, and the dialog disposed.
func id04_0e70() -> int:
	var f: Array = _enter(0x18)
	var a6: int = f[0]
	memory.write_u16(a6 - 0x16, _w(-0x12f8))
	memory.write_u16(a6 - 0x18, _w(-0x12d0))
	_set_w(-0x225c, _w(-0x12d2))
	var dlg: int = _trap(0xa97c, [0xffffffff, 0, 0x84]) & 0xffffffff
	_jt(0x472, [dlg])
	id04_01b8(dlg, 2, 1)
	_run(id04, "set_dialog_user_item_proc", [dlg, 3, _g(0x8a)])
	id04_02dc(dlg, _g(-0x2240), 3, 6)
	_trap(0xa915, [dlg])
	while true:
		_trap(0xa991, [a6 - 6, _g(0x14a)])
		var item: int = _sw16(a6 - 6)
		if item == 1:
			break
		id04_02dc(dlg, _g(-0x2240), 3, item)
	var sel: int = qd_s16(_run(id04, "get_radio_group_selection", [dlg, _g(-0x2240), 3]))
	if sel != -1:
		_set_w(-0x12d0, sel - 4)
	_set_w(-0x12d2, _w(-0x225c))
	_trap(0xa983, [dlg])
	id04.a7 = f[1]
	return 0

## ID06 0xee (slot $1d2, the entry without a LINK frame before 0xf4): the grey map's pointer
## (A5 - 0x1ede), the 1-bit view buffer's base for ID02.
func id06_00ee() -> int:
	return memory.read_u32(_g(-0x1ede))
