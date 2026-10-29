class_name StrictID08
extends RefCounted
## Strict translations owned by CODE segment 08 (ID08.bin; address = file offset, 4-byte header):
## the overlay loader. The sole provenance and verification record lives in mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`).
## Calls leaving the segment go through `_jt` / `_trap` (see StrictID02), filled by tests with
## logging stand-ins.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const A5_PAYLOAD: int = -0x12fc  ## long: the loaded payload
const JT_GET_FPOS: int = 0x2ca   ## GetFPos(refNum, VAR pos): OSErr
const JT_GET_EOF: int = 0x2c2    ## GetEOF(refNum, VAR eof): OSErr
const JT_NEW_PTR: int = 0x22a    ## NewPtr(size): Ptr
const JT_FS_READ: int = 0x2b2    ## FSRead(refNum, VAR count, buffer): OSErr
const TRAP_SYS_BEEP: int = 0xa9c8
const TRAP_EXIT_TO_SHELL: int = 0xa9f4

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

## 0x338: SysBeep(100), then ExitToShell (which does not return on the Mac).
func sysbeep_and_exit_to_shell() -> void:
	_trap(TRAP_SYS_BEEP, [0x64])
	_trap(TRAP_EXIT_TO_SHELL, [])

## 0x348: the rest of the open file `ref_num` read into a new block (A5 - 0x12fc): GetFPos and
## GetEOF into this routine's frame, size = eof - position, NewPtr, FSRead; returns FSRead's
## result word.
func alloc_and_read_resource_payload(ref_num: int) -> int:
	assert(a7 != 0, "alloc_and_read_resource_payload needs a7 (its frame holds the position and size)")
	var a6: int = a7 - 4
	_jt(JT_GET_FPOS, [a6 - 8, ref_num & 0xffff])
	_jt(JT_GET_EOF, [a6 - 4, ref_num & 0xffff])
	memory.write_u32(a6 - 4, C68kScript.u32(memory.read_u32(a6 - 4) - memory.read_u32(a6 - 8)))
	var block: int = C68kScript.u32(_jt(JT_NEW_PTR, [memory.read_u32(a6 - 4)]))
	memory.write_u32(C68kScript.u32(a5 + A5_PAYLOAD), block)
	return _jt(JT_FS_READ, [memory.read_u32(C68kScript.u32(a5 + A5_PAYLOAD)), [memory.read_u32(a6 - 4)], ref_num & 0xffff]) & 0xffff

const JT_POSITION_WINDOW: int = 0x48a   ## ID02 position_window_on_screen (C, window)
const JT_SF_GET_FILE: int = 0x30a       ## SFGetFile(where, prompt, filter, count, types, hook, VAR reply) (Pascal)
const JT_COPY_PSTRING: int = 0x4d2      ## ID02 copy_pascal_string (C)
const TRAP_GET_NEW_DIALOG: int = 0xa97c
const TRAP_SET_PORT: int = 0xa873
const TRAP_LOCAL_TO_GLOBAL: int = 0xa870
const TRAP_DISPOSE_DIALOG: int = 0xa982
const LOCAL_LOAD_OVERLAY: int = 0x6     ## load_overlay_from_resource (C, no arguments)

## A call to a routine of this segment not ported yet, by its segment offset.
func _local(offset: int, args: Array) -> int:
	assert(code_routines.has(offset), "segment routine %x has no stand-in" % offset)
	return code_routines[offset].call(args)

## 0x39c: the standard Get File dialog (-4000) made only to find where it would go (placed by JT
## $48a, its portRect's top left made global in its port, the current port A5 - 0x160c restored,
## disposed); SFGetFile there for 'HELL' files with the prompt A5 - 0x16d8; when one is chosen its
## name and volume go to the record *(A5 - 0x13ac) +0x2a / +0x28, A5 - 0x138a is set and the overlay
## is loaded (0x6).
func bootstrap_window_and_load_overlay() -> void:
	assert(a7 != 0, "bootstrap_window_and_load_overlay needs a7 (its frame holds the reply)")
	var a6: int = a7 - 4
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, 0xf060]))
	memory.write_u32(a6 - 0x5e, dialog)
	_jt(JT_POSITION_WINDOW, [dialog])
	memory.write_u16(a6 - 0x64, memory.read_u16(dialog + 0x12))
	memory.write_u16(a6 - 0x66, memory.read_u16(dialog + 0x10))
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	memory.write_u32(a6 - 0x62, saved)
	_trap(TRAP_SET_PORT, [dialog])
	_trap(TRAP_LOCAL_TO_GLOBAL, [a6 - 0x66])
	_trap(TRAP_SET_PORT, [saved])
	_trap(TRAP_DISPOSE_DIALOG, [dialog])
	memory.write_u32(a6 - 0x10, 0x48454c4c)
	_jt(JT_SF_GET_FILE, [a6 - 0x5a, 0, [memory.read_u32(a6 - 0x10)], 1, 0, C68kScript.u32(a5 - 0x16d8), memory.read_u32(a6 - 0x66)])
	if memory.read_u8(a6 - 0x5a) == 0:
		return
	var rec: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	_jt(JT_COPY_PSTRING, [a6 - 0x50, C68kScript.u32(rec + 0x2a)])
	rec = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	memory.write_u16(rec + 0x28, memory.read_u16(a6 - 0x54))
	memory.write_u16(C68kScript.u32(a5 - 0x138a), 1)
	_local(LOCAL_LOAD_OVERLAY, [])

const JT_FS_OPEN: int = 0x2a2           ## FSOpen(name, vRefNum, VAR refNum): OSErr
const JT_FS_CLOSE: int = 0x2aa
const JT_DISPOSE_PTR: int = 0x23a
const JT_NEW_PTR_CLEAR: int = 0x232     ## NewPtr(size): Ptr for the overlay image
const JT_SHOW_ERROR: int = 0x4ba        ## ID02 show_caution_alert_with_number (C: message, number)
const JT_REPORT_OPEN_FAILURE: int = 0xfa  ## (C, the file name as a C string)
const JT_AFTER_LOAD: int = 0x4c2
const JT_GET_VOL: int = 0x2ba           ## GetVol(VAR name, VAR vRefNum): OSErr
const JT_P2C: int = 0x2fa
const JT_STRCMP: int = 0x51a
const JT_POSITION_ALERT: int = 0x47a
const JT_MAX_MEM: int = 0x21a           ## MaxMem(VAR grow): Size
const TRAP_TICK_COUNT: int = 0xa975
const TRAP_STOP_ALERT: int = 0xa986
const A5_IMAGE: int = -0x1006           ## long: the loaded overlay image
const A5_HEADER: int = -0x1026          ## 32 bytes: +4 code size, +8 data size, +0xc extra, +0x18 / +0x1c relocation bytes

## 0x6: the overlay file (name / volume in the record *(A5 - 0x13ac) +0x2a / +0x28, retried on the
## default volume) opened, or its name reported (JT $fa) and 0 returned. Its 32-byte header read
## into A5 - 0x1026; a block of the three sizes + 4 (any previous one disposed) aligned to 4 bytes
## (A5 - 0x1006); the code and data read; the 8-byte relocations (two tables, the second applying
## past the code) read one by one: flagged 0x80 skipped, 0x10 or a kind other than 2 an error, else
## the image base added to the long at their offset; the rest of the file read as the payload
## (0x348) and JT $4c2 run. On an error (a message from A5 - 0xdf6 / -0xdf2 / -0xdee / -0xdea) the
## image is dropped. The file closed; with an image: JT $53a over the code, JT $542 seeded with
## TickCount, and the JT $582 / $552 / $54a / $532 / $572 / $55a / $57a checks; then the current
## volume (A5 - 0x1a24 copied into the frame, GetVol) compared with A5 - 0x16e2: equal means stop
## alert 0x105 and ExitToShell. MaxMem; returns 1.
func load_overlay_from_resource() -> int:
	assert(a7 != 0, "load_overlay_from_resource needs a7 (its frame holds the reference number and buffers)")
	var entry: int = a7
	var a6: int = entry - 4
	memory.write_u32(a6 - 8, 0)
	var rec: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	var err: int = _jt(JT_FS_OPEN, [a6 - 0xa, memory.read_u16(rec + 0x28), C68kScript.u32(rec + 0x2a)]) & 0xffff
	if err != 0:
		rec = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
		err = _jt(JT_FS_OPEN, [a6 - 0xa, 0, C68kScript.u32(rec + 0x2a)]) & 0xffff
		if err != 0:
			rec = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
			_jt(JT_COPY_PSTRING, [C68kScript.u32(rec + 0x2a), a6 - 0x120])
			_jt(JT_REPORT_OPEN_FAILURE, [a6 - 0x120])
			return 0
	var ref_num: int = memory.read_u16(a6 - 0xa)
	if not _load_image(entry, a6, ref_num):
		memory.write_u32(_g(A5_IMAGE), 0)
	_jt(JT_FS_CLOSE, [memory.read_u16(a6 - 0xa)])
	if memory.read_u32(_g(A5_IMAGE)) != 0:
		_check_image(a6)
	for k in 0x3f:
		memory.write_u32(a6 - 0x228 + 4 * k, memory.read_u32(_g(-0x1a24 + 4 * k)))
	memory.write_u16(a6 - 0x228 + 0xfc, memory.read_u16(_g(-0x1a24 + 0xfc)))
	_jt(JT_GET_VOL, [a6 - 0x22a, a6 - 0x228])
	var name: int = C68kScript.u32(_jt(JT_P2C, [a6 - 0x228]))
	if _jt(JT_STRCMP, [name, _g(-0x16e2)]) & 0xffff == 0:
		_jt(JT_POSITION_ALERT, [0x105])
		_trap(TRAP_STOP_ALERT, [0, 0x105])
		_trap(TRAP_EXIT_TO_SHELL, [])
	_jt(JT_MAX_MEM, [a6 - 8])
	return 1

func _g(offset: int) -> int:
	return C68kScript.u32(a5 + offset)

func _fail(message: int, number: int) -> bool:
	_jt(JT_SHOW_ERROR, [memory.read_u32(_g(message)), number & 0xffff])
	return false

## The header, the image and its relocations; false on an error (the message shown).
func _load_image(entry: int, a6: int, ref_num: int) -> bool:
	if memory.read_u32(_g(A5_IMAGE)) != 0:
		_jt(JT_DISPOSE_PTR, [memory.read_u32(_g(A5_IMAGE))])
	memory.write_u32(a6 - 0x10, 0x20)
	var err: int = _jt(JT_FS_READ, [_g(A5_HEADER), [memory.read_u32(a6 - 0x10)], ref_num]) & 0xffff
	memory.write_u16(a6 - 0xc, err)
	if err != 0:
		return _fail(-0xdf6, err)
	var code_size: int = memory.read_u32(_g(-0x1022))
	var total: int = C68kScript.u32(code_size + memory.read_u32(_g(-0x101e)) + memory.read_u32(_g(-0x101a)))
	memory.write_u32(a6 - 0x14, total)
	var image: int = C68kScript.u32(_jt(JT_NEW_PTR_CLEAR, [C68kScript.u32(total + 4)]))
	memory.write_u32(_g(A5_IMAGE), image)
	if image == 0:
		return _fail(-0xdf2, 0)
	memory.write_u32(_g(A5_IMAGE), C68kScript.u32(image + ((4 - (image & 3)) & 3)))
	memory.write_u32(a6 - 0x10, memory.read_u32(_g(-0x1022)))
	_jt(JT_FS_READ, [memory.read_u32(_g(A5_IMAGE)), [memory.read_u32(a6 - 0x10)], ref_num])
	if memory.read_u32(_g(-0x101e)) != 0:
		memory.write_u32(a6 - 0x10, memory.read_u32(_g(-0x101e)))
		_jt(JT_FS_READ, [C68kScript.u32(memory.read_u32(_g(A5_IMAGE)) + memory.read_u32(_g(-0x1022))), [memory.read_u32(a6 - 0x10)], ref_num])
	var first: int = C68kScript.divs_trunc(memory.read_s32(_g(-0x100e)), 8)
	var second: int = C68kScript.divs_trunc(memory.read_s32(_g(-0x100a)), 8)
	memory.write_u32(a6 - 0x18, C68kScript.u32(first))
	memory.write_u32(a6 - 0x1c, C68kScript.u32(second))
	var i: int = 0
	while C68kScript.s32(first + second) > i:
		memory.write_u32(a6 - 0x10, 8)
		_jt(JT_FS_READ, [a6 - 0x128, [memory.read_u32(a6 - 0x10)], ref_num])
		var flags: int = memory.read_s32(a6 - 0x124)
		if (flags >> 7) & 1 == 0:
			if (flags >> 4) & 1 != 0:
				return _fail(-0xdee, 0)
			if (flags >> 5) & 3 != 2:
				return _fail(-0xdea, 0)
			var base: int = memory.read_u32(_g(A5_IMAGE))
			var at: int = C68kScript.u32(base + memory.read_u32(a6 - 0x128))
			if i >= first:
				at = C68kScript.u32(base + memory.read_u32(_g(-0x1022)) + memory.read_u32(a6 - 0x128))
			memory.write_u32(at, C68kScript.u32(memory.read_u32(at) + base))
		i += 1
		memory.write_u32(a6 - 4, C68kScript.u32(i))
	a7 = entry - 4 - 0x22a - 2 - 4
	alloc_and_read_resource_payload(ref_num)
	a7 = entry
	_jt(JT_AFTER_LOAD, [])
	return true

## The loaded image's checks through the jump table (two values in the frame, -0x12c / -0x130).
func _check_image(a6: int) -> void:
	var image: int = memory.read_u32(_g(A5_IMAGE))
	_jt(0x53a, [image, memory.read_u32(_g(-0x1022))])
	_jt(0x542, [_g(-0x1cc4), 0x38, C68kScript.u32(_trap(TRAP_TICK_COUNT, []))])
	_jt(0x582, [a6 - 0x12c, a6 - 0x130])
	var d: int = C68kScript.u32(_jt(0x552, [memory.read_u32(a6 - 0x130)]))
	if _jt(0x54a, [memory.read_u32(a6 - 0x12c), d]) & 0xffff != 0:
		_jt(0x532, [])
	_jt(0x572, [a6 - 0x12c, a6 - 0x130])
	_jt(0x55a, [])
	d = C68kScript.u32(_jt(0x552, [memory.read_u32(a6 - 0x130)]))
	if _jt(0x54a, [memory.read_u32(a6 - 0x12c), d]) & 0xffff != 0:
		_jt(0x57a, [memory.read_u32(a6 - 0x12c), memory.read_u32(a6 - 0x130)])
