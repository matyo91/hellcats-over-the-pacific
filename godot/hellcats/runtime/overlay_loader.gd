extends RefCounted

## The Pacific Conflict overlay, loaded by the original code (ID08 load_overlay_from_resource): it
## reads the scenery file's 32-byte header, allocates the image (code + data + bss + 4), reads the
## code and data, and adds the image's address to every long the two relocation tables name.
##
## The strict overlay port addresses the image at base 0 (runtime address = file offset - 0x20).
## So the runtime gives the image the address 0x01000000 (its 24 low bits are 0, see
## mac_memory.gd): the host sees a nonzero pointer, the bytes land at 0. When the file is closed
## the relocated longs get that 0x01000000 taken off again, the low-memory globals the image covered
## get back the values they held when the file was opened (the program's own: after a first mission
## SoundHook is the empty task shutdown_sound put back, and a handler written there instead would be
## saved by the next init_sound_system as its own predecessor, ID02 0x3dd0 / 0x4318, and chain to
## itself), and the overlay's port is linked: its entry (image + header +0x14) and the
## hooks it installs in the host world (OVERLAY_HOOKS) become code addresses the host can call,
## and the host's jump-table slots become addresses the overlay can call. A scenery opened again
## (File > Open…) is loaded the same way over the old image, with a port of its own.

const Overlay := preload("res://strict_port/code/pacific_conflict.gd")
const METHODS := "res://hellcats/data/overlay_methods.json"
const IMAGE_BASE := 0x01000000
const HEADER := 0x20
## The jump-table slot ID08 calls once the image and its relocations are read (ID02
## reset_overlay_state, which enters the overlay): the image is linked just before it.
const AFTER_LOAD := 0x4c2

var machine
var port
var methods: Dictionary = {}       ## runtime address -> ported method name

## The scenery file being loaded (its bytes, from FSOpen until the image is linked).
var _pending: PackedByteArray
var _pending_name := ""
var _low_memory: Array = []

func _init(owner) -> void:
	machine = owner
	var doc: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(METHODS))
	for key in doc:
		methods[key.hex_to_int()] = doc[key]
	owner.toolbox.files.on_open = _on_open
	owner.segments.before_slot[AFTER_LOAD] = _link_pending

static func _u32(b: PackedByteArray, at: int) -> int:
	return (b[at] << 24) | (b[at + 1] << 16) | (b[at + 2] << 8) | b[at + 3]

static func _is_image(bytes: PackedByteArray) -> bool:
	return bytes.size() > HEADER and HEADER + _u32(bytes, 4) + _u32(bytes, 8) <= bytes.size()

func _on_open(name: String, bytes: PackedByteArray) -> void:
	if _is_image(bytes):
		var total: int = _u32(bytes, 4) + _u32(bytes, 8) + _u32(bytes, 12)
		machine.toolbox.heap.reserve(total + 4, IMAGE_BASE)
		_pending = bytes
		_pending_name = name
		_low_memory = machine.save_low_memory()

func _link_pending() -> void:
	if _pending.is_empty():
		return
	var bytes: PackedByteArray = _pending
	var name: String = _pending_name
	_pending = PackedByteArray()
	var code: int = _u32(bytes, 4)
	var first: int = _u32(bytes, 24) / 8
	var second: int = _u32(bytes, 28) / 8
	var at: int = HEADER + code + _u32(bytes, 8)
	var memory = machine.memory
	for i in first + second:
		var offset: int = _u32(bytes, at)
		var flags: int = _u32(bytes, at + 4)
		at += 8
		if (flags >> 7) & 1:
			continue
		var cell: int = IMAGE_BASE + offset + (code if i >= first else 0)
		memory.write_u32(cell, (memory.read_u32(cell) - IMAGE_BASE) & 0xffffffff)
	machine.restore_low_memory(_low_memory)
	_attach(_u32(bytes, 20))
	machine.log_line("overlay %s loaded: code 0x%x, %d relocations" % [name, code, first + second])

func _attach(entry: int) -> void:
	port = Overlay.new(machine.memory)
	var own: Array = port.code_table.keys()          # the port's own routines, before the host slots
	var segments = machine.segments
	segments.link_overlay(port)
	segments.register_address(IMAGE_BASE + entry, func(args: Array) -> int:
		var saved: int = port.a7
		port.a7 = machine.free_stack()
		port.overlay_main_entry(args[0], args[1])
		port.a7 = saved
		return 0)
	for hook in Overlay.OVERLAY_HOOKS:
		segments.register_address(hook, _hook(hook))
	# Its own registrations include routines without a result, whose callers read D0 as an int: each
	# answers 0 then. They are C routines called through pointers, so a call may pass more arguments
	# than one declares (every definition +0xe pre-render hook gets (controller, phase),
	# transform_and_project_object; animate_landing_gear and shadow_pre_render declare only the
	# controller): the extra ones are dropped, as segment_loader.gd's C slots do; Godot's callv
	# would neither run the routine nor report the mismatch. The host slots link_overlay added take
	# any arguments (...args) and are left as they are.
	for address in port.code_table.keys():
		port.code_table[address] = _with_result(port.code_table[address], own.has(address))
	# The overlay also jumps through code addresses it stores (controller ticks, collision hooks):
	# every ported routine is reachable by its runtime address, with its arguments as they come.
	for address in methods:
		if not port.code_table.has(address):
			port.code_table[address] = _positional(methods[address])
	for address in UNPORTED:
		if not port.code_table.has(address):
			port.code_table[address] = _unported(address)
	port.code_table[0x16208] = func(...args: Array) -> int: return _16208()
	port.code_table[0x15134] = func(...args: Array) -> int:
		machine.cover_key("runtime:overlay+0x15134")
		args.resize(3)
		return _15134(int(args[0] if args[0] != null else 0), int(args[1] if args[1] != null else 0), int(args[2] if args[2] != null else 0))

## Overlay routines the overlay calls by address that are outside the 740 (not ported yet).
const UNPORTED := {}

## Overlay routines outside the 740 written here from their bytes (runtime address -> method below).
const WRITTEN := {0xd23a: "_d23a", 0x4b0: "_04b0"}

static func _with_result(routine: Callable, trim: bool = false) -> Callable:
	var arity: int = routine.get_argument_count() if trim else -1
	return func(...args: Array):
		var r = routine.callv(args.slice(0, arity) if arity >= 0 and args.size() > arity else args)
		return 0 if r == null else r

func _positional(method: String) -> Callable:
	var arity: int = 0
	for m in port.get_method_list():
		if m["name"] == method:
			arity = m["args"].size()
	return func(...args: Array) -> int:
		var list: Array = args.duplicate()
		list.resize(arity)
		for k in arity:
			if list[k] == null:
				list[k] = 0
		var r = port.callv(method, list)
		return 0 if r == null else int(r)

func _unported(address: int) -> Callable:
	return func(...args: Array) -> int:
		machine.note_missing("overlay:0x%x" % address, "%s, %d args" % [UNPORTED[address], args.size()])
		return 0

## For tests: the image (code and data) at base 0 as the loader leaves it once linked (its
## relocated longs hold runtime addresses, which the file's already are), and its port attached.
func attach_image(bytes: PackedByteArray) -> void:
	var size: int = _u32(bytes, 4) + _u32(bytes, 8)
	for k in size:
		machine.memory.write_u8(k, bytes[HEADER + k])
	_attach(_u32(bytes, 20))

func _hook(address: int) -> Callable:
	if WRITTEN.has(address):
		return func(args: Array) -> int:
			var saved: int = port.a7
			port.a7 = machine.free_stack()
			machine.cover_key("runtime:overlay+0x%x" % address)
			var r: int = call(WRITTEN[address])
			port.a7 = saved
			return r
	var method = methods.get(address)
	if method == null:
		return func(args: Array) -> int:
			machine.note_missing("overlay:0x%x" % address, "unported overlay hook, %d args" % args.size())
			return 0
	var arity: int = 0
	for m in port.get_method_list():
		if m["name"] == method:
			arity = m["args"].size()
	return func(args: Array) -> int:
		var list: Array = args.duplicate()
		list.resize(arity)
		for k in arity:
			if list[k] == null:
				list[k] = 0
		var saved: int = port.a7
		port.a7 = machine.free_stack()
		var result = port.callv(method, list)
		port.a7 = saved
		return 0 if result == null else int(result)

## For tests: ported overlay methods the written routines' calls go to a stand-in for (by name).
var test_stubs: Dictionary = {}

func _run(method: String, args: Array = []) -> int:
	if test_stubs.has(method):
		return int(test_stubs[method].call(args))
	var r = port.callv(method, args)
	return 0 if r == null else int(r)

## Overlay hook 0xd23a (file 0xd25a, redraw_view_readouts in Pacific Conflict.decomp.c's
## unexported block): update_view_readouts_and_overlays(0); with the panel flag
## 0x20ae4 set, update_throttle_gauge, update_radar_range_buttons, update_bomb_indicator and the
## overlays marked drawn (0xd25c: 0x25ffc = 1, and with host word +0x9e clear_flag_00020ae4).
func _d23a() -> int:
	_run("update_view_readouts_and_overlays", [0])
	if machine.memory.read_u16(0x20ae4) != 0:
		_run("update_throttle_gauge")
		_run("update_radar_range_buttons")
		_run("update_bomb_indicator")
		_run("mark_view_overlays_drawn")
	return 0

## Overlay routine 0x15134 (file 0x15154): carrier_deck_contact, the carrier's contact handler
## (definition +0x12 of controller key 0x15; Pacific Conflict.decomp.c, its unexported block).
## Called (carrier, player, contact record). The carrier's controller (+8) caches its deck face
## (+0x50, the face tagged 1 at face byte +0x17, found once; "Can't find deck tag on carrier"
## otherwise), the face tagged 3 (+0x52, the arresting-wire zone) and the deck height (+0x54: the
## deck's first vertex's y, asr by the carrier's +0x34). A player with a controller over the deck
## while the carrier's |fold(+0x20)| <= 0x4ff (not heeled over) gets the deck as its ground (+0x2e)
## and, outside replays (0x1b870), the deck face's surface byte (+0x16 into +0x2c); a player of
## type <= 4 over the tag-3 face gets the arrest request +0x63f = 1. With a deck above 0 the pair
## is added to the carried pairs (0x1b860, count 0x1b85c, capacity 0x1b85a grown by 4).
func _15134(carrier: int, player: int, contact_record: int) -> int:
	var m = machine.memory
	var ctrl: int = m.read_u32(carrier + 8)
	var pc: int = m.read_u32(player + 8)
	if pc == 0:
		return 0
	var faces: int = m.read_u32(carrier + 0x48)
	if m.read_u16(ctrl + 0x50) == 0xffff:
		for i in maxi(m.read_s16(carrier + 0x3a), 0):
			var tag: int = m.read_u8(faces + i * 0x20 + 0x17)
			if tag == 1:
				m.write_u16(ctrl + 0x50, i)
			if tag == 3:
				m.write_u16(ctrl + 0x52, i)
		if m.read_u16(ctrl + 0x50) == 0xffff:
			_run("overlay_printf", [0x15114, 0, 0, 0, 0, 0])
		var deck_face: int = (faces + (m.read_s16(ctrl + 0x50) << 5)) & 0xffffffff
		var w: int = m.read_s16(m.read_u32(deck_face + 0x18))
		# LEA (A0,A0.L*2) then MOVE.L 4(A1,A0.L*4): vertex w's y in the 12-byte vertex table.
		var y: int = m.read_s32(m.read_u32(carrier + 0x44) + 12 * w + 4)
		m.write_u16(ctrl + 0x54, (y >> (m.read_u16(carrier + 0x34) & 63)) & 0xffff)
	var deck: int = (faces + (m.read_s16(ctrl + 0x50) << 5)) & 0xffffffff
	var folded: int = qd_s16(_run("fold_angle_pm_0x2000", [m.read_s16(ctrl + 0x20)]))
	if absi(folded) <= 0x4ff and _run("point_over_face_xz", [contact_record, deck]) != 0:
		m.write_u32(pc + 0x2e, m.read_s16(ctrl + 0x54) & 0xffffffff)
		if m.read_u16(0x1b870) == 0:
			m.write_u8(pc + 0x2c, m.read_u8(deck + 0x16))
	if m.read_s16(m.read_u32(pc + 4)) <= 4 and m.read_u16(ctrl + 0x52) != 0xffff:
		if _run("point_over_face_xz", [contact_record, (faces + (m.read_s16(ctrl + 0x52) << 5)) & 0xffffffff]) != 0:
			m.write_u8(pc + 0x63f, 1)
	if m.read_s16(ctrl + 0x54) > 0:
		if m.read_s16(0x1b85a) <= m.read_s16(0x1b85c):
			m.write_u16(0x1b85a, (m.read_u16(0x1b85a) + 4) & 0xffff)
			var size: int = m.read_s16(0x1b85a) * 8
			if m.read_u32(0x1b860) == 0:
				m.write_u32(0x1b860, _run("heap_alloc", [size]) & 0xffffffff)
			else:
				m.write_u32(0x1b860, _run("heap_realloc_grow_only", [m.read_u32(0x1b860), size]) & 0xffffffff)
		var entry: int = m.read_u32(0x1b860) + m.read_s16(0x1b85c) * 8
		m.write_u32(entry, carrier & 0xffffffff)
		m.write_u32(entry + 4, player & 0xffffffff)
		m.write_u16(0x1b85c, (m.read_u16(0x1b85c) + 1) & 0xffff)
	return 0

static func qd_s16(v: int) -> int:
	v &= 0xffff
	return v - 0x10000 if v >= 0x8000 else v

## Overlay routine 0x16208 (file 0x16228): the 1-bit renderer's erase hook (RENDERER_HOOKS_1 puts
## it in 0x1da84): CLR.W $1da8c; RTS.
func _16208() -> int:
	machine.memory.write_u16(0x1da8c, 0)
	return 0

## Overlay hook 0x4b0 (file 0x4d0, player_left_ground_zone in Pacific Conflict.decomp.c's
## unexported block): 0 while the player (0x1b738) is within 0x1387 above its ground (its object's
## y +0x1c less the controller's ground height +0x2e), else 1 (also without a player).
func _04b0() -> int:
	var m = machine.memory
	var ctl: int = m.read_u32(0x1b738)
	if ctl == 0:
		return 1
	# SUB.L: the difference wraps at 32 bits before the signed compare.
	var d: int = (m.read_u32(m.read_u32(ctl) + 0x1c) - m.read_u32(ctl + 0x2e)) & 0xffffffff
	if d >= 0x80000000:
		d -= 0x100000000
	return 0 if d <= 0x1387 else 1
