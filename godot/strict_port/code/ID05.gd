class_name StrictID05
extends RefCounted
## Strict translations owned by CODE segment 5 (ID05.bin; address = file offset, 4-byte header):
## the copy-protection code and its helpers. The sole provenance and verification record lives in
## mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`).
## Calls leaving the segment go through `_jt` / `_trap` (see StrictID02), filled by tests with
## logging stand-ins.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const A5_RAND_SEED: int = -0x6c         ## long: the ansi_rand state
const A5_POISON_TABLE: int = -0xb4      ## 12 records of 6 bytes: +0 address, +4 original byte
const A5_TABLE: int = -0xba             ## long: the challenge table (12-byte records)
const A5_TABLE_COUNT: int = -0xb6       ## word: its record count
const A5_RESTORE_PENDING: int = -0xbc   ## word: poisoned bytes to restore
const A5_MATCHES: int = -0xc0           ## long: matching responses (its low word is returned)
const A5_KEY: int = -0x2c               ## the response key bytes
const A5_CODE_BUF68: int = -0x68
const A5_CODE_BUF54: int = -0x54
const A5_CODE_BUF40: int = -0x40
const JT_STRLEN: int = 0x522            ## C strlen (D0)

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

func _g(offset: int) -> int:
	return C68kScript.u32(a5 + offset)

## 0x728: seed = seed * 0x41c64e6d + 0x3039 (MULU.L, 32-bit); returns BFEXTU seed{1:15}, bits
## 30..16.
func ansi_rand() -> int:
	var seed: int = C68kScript.u32(memory.read_u32(_g(A5_RAND_SEED)) * 0x41c64e6d + 0x3039)
	memory.write_u32(_g(A5_RAND_SEED), seed)
	return (seed >> 16) & 0x7fff

## 0x746: seed = the argument.
func ansi_srand(seed: int) -> void:
	memory.write_u32(_g(A5_RAND_SEED), C68kScript.u32(seed))

## 0x754: six base-26 letters of value ('A' + remainder, DIVSL.L #26: signed, the last digit
## first) at dst, then a terminator; D0 is left holding the last quotient (returned).
func encode_base26_6chars(dst: int, value: int) -> int:
	var v: int = C68kScript.s32(value)
	for k in 6:
		var q: int = C68kScript.divs_trunc(v, 26)
		memory.write_u8(C68kScript.u32(dst + 5 - k), (v - q * 26 + 0x41) & 0xff)
		v = q
	memory.write_u8(C68kScript.u32(dst + 6), 0)
	return C68kScript.u32(v)

## 0x7a8: value = value * 26 (MULU.L) + (letter - 'A', sign-extended byte) over six letters;
## stored at *out_value.
func decode_base26_6chars(src: int, out_value: int) -> void:
	memory.write_u32(out_value, _decode26(src))

func _decode26(src: int) -> int:
	var v: int = 0
	for k in 6:
		v = C68kScript.u32(C68kScript.u32(v * 26) + C68kScript.s16(C68kScript.s8(memory.read_u8(C68kScript.u32(src + k))) - 0x41))
	return v

## 0x7f6: up to twelve random bytes of the overlay (base + (rand low word) MODU.L size) are
## recorded (address, original byte at A5 - 0xb4) and set to 0xff; nothing for a null base.
func poison_overlay_bytes(base: int, size: int) -> void:
	var i: int = 0
	while C68kScript.u32(base) != 0 and i < 12:
		var r: int = ansi_rand() & 0xffff
		var p: int = C68kScript.u32(r % C68kScript.u32(size) + base)
		var rec: int = _g(A5_POISON_TABLE + 6 * i)
		memory.write_u32(rec, p)
		memory.write_u8(rec + 4, memory.read_u8(p))
		memory.write_u8(p, 0xff)
		i += 1

## 0x85e: when a restore is pending (word A5 - 0xbc or long A5 - 0xc0), the twelve recorded bytes
## are put back, last first.
func restore_poisoned_overlay_bytes() -> void:
	if memory.read_u16(_g(A5_RESTORE_PENDING)) == 0 and memory.read_u32(_g(A5_MATCHES)) == 0:
		return
	for i in range(11, -1, -1):
		var rec: int = _g(A5_POISON_TABLE + 6 * i)
		memory.write_u8(memory.read_u32(rec), memory.read_u8(rec + 4))

## 0x8b8: ansi_srand(seed), the challenge table and its count (word).
func init_protection_table(table: int, count: int, seed: int) -> void:
	ansi_srand(seed)
	memory.write_u32(_g(A5_TABLE), C68kScript.u32(table))
	memory.write_u16(_g(A5_TABLE_COUNT), count & 0xffff)

## 0x8d6: a random record (rand low word DIVU.W count, the remainder) gives its words +6 / +8 / +0xa.
func pick_random_protection_challenge(out6: int, out8: int, out10: int) -> void:
	var idx: int = (ansi_rand() & 0xffff) % memory.read_u16(_g(A5_TABLE_COUNT))
	var rec: int = C68kScript.u32(C68kScript.s32(C68kScript.s16(idx) * 0xc) + memory.read_u32(_g(A5_TABLE)))
	memory.write_u16(out6, memory.read_u16(rec + 6))
	memory.write_u16(out8, memory.read_u16(rec + 8))
	memory.write_u16(out10, memory.read_u16(rec + 0xa))

## 0x934: (byte +4 * 20 + byte +5, sign-extended bytes, MULU.L) == n as a word 1 / 0 (the low word
## of D0 is the result).
func record_code_index_equals(n: int, rec: int) -> int:
	var v: int = C68kScript.u32(C68kScript.u32(C68kScript.s8(memory.read_u8(rec + 4)) * 0x14) + C68kScript.s8(memory.read_u8(rec + 5)))
	return 1 if v == C68kScript.u32(n) else 0

## 0x964: counts (A5 - 0xc0) the records whose code matches `text` keyed by A5 - 0x2c (each byte
## text[j] + (key[j] & 0x7f) equals the record's code byte, compared as bytes, from the last), whose
## length word +4 is strlen(text) (JT $522) and whose words +6 / +8 / +0xa are the three given;
## returns the low word of the count.
func validate_protection_response(w6: int, w8: int, w10: int, text: int) -> int:
	memory.write_u32(_g(A5_MATCHES), 0)
	var i: int = 0
	while i < memory.read_s16(_g(A5_TABLE_COUNT)):
		var rec: int = C68kScript.u32(C68kScript.s32(i * 0xc) + memory.read_u32(_g(A5_TABLE)))
		var j: int = C68kScript.s16(memory.read_u16(rec + 4) - 1)
		while j >= 0:
			var sum: int = (C68kScript.s8(memory.read_u8(C68kScript.u32(text + j))) + (C68kScript.s8(memory.read_u8(_g(A5_KEY + j))) & 0x7f)) & 0xff
			if memory.read_u8(C68kScript.u32(memory.read_u32(rec) + j)) != sum:
				break
			j -= 1
		if j < 0:
			var length: int = C68kScript.u32(_jt(JT_STRLEN, [C68kScript.u32(text)]))
			rec = C68kScript.u32(C68kScript.s32(i * 0xc) + memory.read_u32(_g(A5_TABLE)))
			if C68kScript.u32(memory.read_s16(rec + 4)) == length and (w6 & 0xffff) == memory.read_u16(rec + 6) \
					and (w8 & 0xffff) == memory.read_u16(rec + 8) and (w10 & 0xffff) == memory.read_u16(rec + 0xa):
				memory.write_u32(_g(A5_MATCHES), C68kScript.u32(memory.read_u32(_g(A5_MATCHES)) + 1))
		i += 1
	return memory.read_u16(_g(A5_MATCHES) + 2)

## 0xa62: (rand << 16 | rand) & 0xfffffff (each the low word of ansi_rand).
func random_28bit_value() -> int:
	var hi: int = ansi_rand() & 0xffff
	var lo: int = ansi_rand() & 0xffff
	return ((hi << 16) | lo) & 0xfffffff

## 0xa90: five words packed into a 28-bit code, encoded as six letters at A5 - 0x68 (returned):
## e = e / 0x200 (DIVS.W) capped at 0x20; ((a / 0x80) << 12 | (b / 0x80) << 8 | (c / 4) << 5) as a
## word, sign-extended; | f << 16 (sign-extended) | e (sign-extended), & 0xfffffff.
func pack_fields_to_code_buf68(f: int, a: int, b: int, c: int, e: int) -> int:
	var ev: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s16(e), 0x200))
	if ev > 0x20:
		ev = 0x20
	var w: int = C68kScript.u16(C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(a), 0x80) << 12)
			| C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(b), 0x80) << 8)
			| C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(c), 4) << 5))
	var v: int = C68kScript.u32(C68kScript.lsl32(C68kScript.s16(f), 16) | C68kScript.u32(C68kScript.s16(w)) | C68kScript.u32(ev)) & 0xfffffff
	encode_base26_6chars(_g(A5_CODE_BUF68), v)
	return _g(A5_CODE_BUF68)

## 0xb10: the six-letter code decoded and split: bits 16..31, bits 12..15 << 7, bits 8..11 << 7,
## bits 5..7 << 2, bits 0..4 (words).
func unpack_fields_from_code(code: int, o1: int, o2: int, o3: int, o4: int, o5: int) -> void:
	var v: int = _decode26(code)
	memory.write_u16(o1, (C68kScript.asr32(v, 16) & 0xffff))
	memory.write_u16(o2, ((C68kScript.asr32(v, 12) & 0xf) << 7))
	memory.write_u16(o3, ((C68kScript.asr32(v, 8) & 0xf) << 7))
	memory.write_u16(o4, ((C68kScript.asr32(v, 5) & 7) << 2))
	memory.write_u16(o5, v & 0x1f)

## 0xb84: value & 0xfffffff encoded at A5 - 0x54 (returned).
func encode_code28_to_buf54(value: int) -> int:
	encode_base26_6chars(_g(A5_CODE_BUF54), C68kScript.u32(value) & 0xfffffff)
	return _g(A5_CODE_BUF54)

## 0xba8 / 0xbde: the decoded value of a six-letter code.
func decode_code_to_long_a(code: int) -> int:
	return _decode26(code)

func decode_code_to_long_b(code: int) -> int:
	return _decode26(code)

## 0xbc2: value encoded at A5 - 0x40 (returned).
func encode_long_to_buf40(value: int) -> int:
	encode_base26_6chars(_g(A5_CODE_BUF40), value)
	return _g(A5_CODE_BUF40)

const JT_MENU_BAR_HEIGHT: int = 0x20a   ## (Pascal): word
const JT_SYS_ENVIRONS: int = 0x1f2      ## SysEnvirons(version, VAR rec): OSErr
const JT_HNOPURGE: int = 0x28a
const JT_HPURGE: int = 0x282
const JT_P2C: int = 0x2fa
const JT_C2P: int = 0x302
const JT_TO_UPPER: int = 0x4e2          ## (C, a character as a word): the character
const JT_NUM_TO_STRING: int = 0x2f2     ## NumToString(value, VAR string) (Pascal)
const TRAP_GET_RESOURCE: int = 0xa9a0
const TRAP_RELEASE_RESOURCE: int = 0xa9a3
const TRAP_CHANGED_RESOURCE: int = 0xa9aa
const TRAP_WRITE_RESOURCE: int = 0xa9b0
const TRAP_GET_MAIN_DEVICE: int = 0xaa32
const TRAP_SET_PORT: int = 0xa873
const TRAP_GET_PORT: int = 0xa874
const TRAP_INIT_CURSOR: int = 0xa850
const TRAP_GET_DITEM: int = 0xa98d
const TRAP_GET_ITEXT: int = 0xa990
const TRAP_PEN_SIZE: int = 0xa89b
const TRAP_INSET_RECT: int = 0xa8a9
const TRAP_FRAME_ROUND_RECT: int = 0xa8b0
const TRAP_HILITE_CONTROL: int = 0xa95d
const TRAP_GET_NEW_DIALOG: int = 0xa97c
const TRAP_EXIT_TO_SHELL: int = 0xa9f4
const TRAP_SHOW_WINDOW: int = 0xa915
const TRAP_PARAM_TEXT: int = 0xa98b
const TRAP_DRAW_DIALOG: int = 0xa981
const TRAP_MODAL_DIALOG: int = 0xa991
const TRAP_STOP_ALERT: int = 0xa985
const TRAP_DISPOSE_DIALOG: int = 0xa983
const A5_FILTER_ARMED: int = -0x2ca     ## word: code_dialog_filter's first-call counter
const A5_ITEM_TEXT: int = -0x1c9        ## get_dialog_item_text_upper's buffer
const A5_CTYPE: int = -0x1608           ## the C library's character class table (bit 7: lower case)
const LOCAL_BUILD_CODE_STRINGS: int = 0x3ba  ## routine B, the code-string builder (C: 4 pointers; not exported)

func _trap(word: int, args: Array) -> int:
	assert(traps.has(word), "A-line trap %04x has no routine" % word)
	return traps[word].call(args)

## A call to a routine of this segment not ported yet, by its segment offset.
func _local(offset: int, args: Array) -> int:
	assert(code_routines.has(offset), "segment routine %x has no stand-in" % offset)
	return code_routines[offset].call(args)

func _box(p: int) -> Array:
	return [memory.read_u32(p), memory.read_u32(p + 4)]

## 0x6: the template (GetResource type / id) moved to the screen's horizontal centre (screen right
## A5 - 0x167a) and a third of the way down below the menu bar (JT $20a, screen bottom A5 - 0x167c).
func center_template_rect_on_screen(type: int, id: int) -> void:
	var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [id & 0xffff, C68kScript.u32(type)]))
	if h == 0:
		return
	var r: int = memory.read_u32(h)
	var width: int = C68kScript.u16(memory.read_u16(r + 6) - memory.read_u16(r + 2))
	var x: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(memory.read_u16(_g(-0x167a)) - width), 2))
	memory.write_u16(r + 6, C68kScript.u16(memory.read_u16(r + 6) + x - memory.read_u16(r + 2)))
	memory.write_u16(r + 2, x)
	var bar: int = _jt(JT_MENU_BAR_HEIGHT, []) & 0xffff
	var height: int = C68kScript.u16(memory.read_u16(r + 4) - memory.read_u16(r))
	var y: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(memory.read_u16(_g(-0x167c)) - bar - height), 3))
	var dy: int = C68kScript.u16(y - memory.read_u16(r))
	bar = _jt(JT_MENU_BAR_HEIGHT, []) & 0xffff
	memory.write_u16(r + 4, C68kScript.u16(memory.read_u16(r + 4) + bar + dy))
	bar = _jt(JT_MENU_BAR_HEIGHT, []) & 0xffff
	memory.write_u16(r, C68kScript.u16(bar + y))

## 0xc8: the machine type (SysEnvirons +2) and, with colour QuickDraw, the main device's pixel map
## words +0xc / +0xa / +0x20, else the screen's width / height (A5 - 0x167a - -0x167e, -0x167c -
## -0x1680) and depth 1; the last output cleared.
func get_machine_screen_fingerprint(machine: int, out_b: int, out_c: int, depth: int, out_e: int) -> void:
	assert(a7 != 0, "get_machine_screen_fingerprint needs a7 (SysEnvirons writes into its frame)")
	var a6: int = a7 - 4
	_jt(JT_SYS_ENVIRONS, [a6 - 0x10, 1])
	memory.write_u16(C68kScript.u32(machine), memory.read_u16(a6 - 0xe))
	if memory.read_u8(a6 - 7) != 0:
		var device: int = C68kScript.u32(_trap(TRAP_GET_MAIN_DEVICE, []))
		var pm: int = memory.read_u32(memory.read_u32(memory.read_u32(device) + 0x16))
		memory.write_u16(C68kScript.u32(out_b), memory.read_u16(pm + 0xc))
		memory.write_u16(C68kScript.u32(out_c), memory.read_u16(pm + 0xa))
		memory.write_u16(C68kScript.u32(depth), memory.read_u16(pm + 0x20))
	else:
		memory.write_u16(C68kScript.u32(out_b), C68kScript.u16(memory.read_u16(_g(-0x167a)) - memory.read_u16(_g(-0x167e))))
		memory.write_u16(C68kScript.u32(out_c), C68kScript.u16(memory.read_u16(_g(-0x167c)) - memory.read_u16(_g(-0x1680))))
		memory.write_u16(C68kScript.u32(depth), 1)
	memory.write_u16(C68kScript.u32(out_e), 0)

## 0x160 / 0x214: the two longs of 'DATA' / 'TEXT' 128 (0 when missing), the resource kept
## unpurgeable while read and released.
func read_DATA128_pair(out1: int, out2: int) -> void:
	_read_pair(0x44415441, out1, out2)

func read_TEXT128_pair(out1: int, out2: int) -> void:
	_read_pair(0x54455854, out1, out2)

func _read_pair(type: int, out1: int, out2: int) -> void:
	memory.write_u32(C68kScript.u32(out1), 0)
	memory.write_u32(C68kScript.u32(out2), 0)
	var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [0x80, type]))
	if h == 0:
		return
	_jt(JT_HNOPURGE, [h])
	memory.write_u32(C68kScript.u32(out1), memory.read_u32(memory.read_u32(h)))
	memory.write_u32(C68kScript.u32(out2), memory.read_u32(memory.read_u32(h) + 4))
	_jt(JT_HPURGE, [h])
	_trap(TRAP_RELEASE_RESOURCE, [h])

## 0x1bc / 0x270: the two longs stored in 'DATA' / 'TEXT' 128, marked changed and written.
func write_DATA128_pair(v1: int, v2: int) -> void:
	_write_pair(0x44415441, v1, v2)

func write_TEXT128_pair(v1: int, v2: int) -> void:
	_write_pair(0x54455854, v1, v2)

func _write_pair(type: int, v1: int, v2: int) -> void:
	var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [0x80, type]))
	if h == 0:
		return
	_jt(JT_HNOPURGE, [h])
	memory.write_u32(memory.read_u32(h), C68kScript.u32(v1))
	memory.write_u32(memory.read_u32(h) + 4, C68kScript.u32(v2))
	_trap(TRAP_CHANGED_RESOURCE, [h])
	_trap(TRAP_WRITE_RESOURCE, [h])
	_jt(JT_HPURGE, [h])
	_trap(TRAP_RELEASE_RESOURCE, [h])

## 0x2c8 (a ModalDialog filter, Pascal): on its first call (A5 - 0x2ca counts calls) the OK button
## gets its ring and is dimmed while item 3's text is empty; a key-down or auto-key resets the count:
## Return / Enter press item 1 (1), Escape item 2 (2); otherwise 0.
func code_dialog_filter(dialog: int, event: int, item_hit: int) -> int:
	assert(a7 != 0, "code_dialog_filter needs a7 (GetDItem / GetIText write into its frame)")
	var a6: int = a7 - 4
	_trap(TRAP_SET_PORT, [C68kScript.u32(dialog)])
	var calls: int = memory.read_u16(_g(A5_FILTER_ARMED))
	memory.write_u16(_g(A5_FILTER_ARMED), C68kScript.u16(calls + 1))
	if calls == 0:
		_trap(TRAP_GET_DITEM, [a6 - 0xe, a6 - 6, a6 - 2, 3, C68kScript.u32(dialog)])
		_trap(TRAP_GET_ITEXT, [a6 - 0x10e, memory.read_u32(a6 - 6)])
		_trap(TRAP_GET_DITEM, [a6 - 0xe, a6 - 6, a6 - 2, 1, C68kScript.u32(dialog)])
		_trap(TRAP_PEN_SIZE, [3, 3])
		_trap(TRAP_INSET_RECT, [0xfffc, 0xfffc, C68kScript.u32(a6 - 0xe)])
		_trap(TRAP_FRAME_ROUND_RECT, [0x10, 0x10, _box(a6 - 0xe)])
		_trap(TRAP_HILITE_CONTROL, [0xff if memory.read_u8(a6 - 0x10e) == 0 else 0, memory.read_u32(a6 - 6)])
	var what: int = memory.read_u16(C68kScript.u32(event))
	if what != 3 and what != 5:
		return 0
	memory.write_u16(_g(A5_FILTER_ARMED), 0)
	var c: int = memory.read_u8(C68kScript.u32(event + 5))
	if c == 0xd or c == 3:
		memory.write_u16(C68kScript.u32(item_hit), 1)
		return 1
	if c == 0x1b:
		memory.write_u16(C68kScript.u32(item_hit), 2)
		return 2
	return 0

## 0x4e4: the item's text (GetIText into A5 - 0x1c9, JT $2fa) with its lower-case letters (class
## table A5 - 0x1608 bit 7) through JT $4e2; returns the buffer.
func get_dialog_item_text_upper(dialog: int, item: int) -> int:
	assert(a7 != 0, "get_dialog_item_text_upper needs a7 (GetDItem writes into its frame)")
	var a6: int = a7 - 4
	_trap(TRAP_GET_DITEM, [a6 - 0xc, a6 - 4, a6 - 0xe, item & 0xffff, C68kScript.u32(dialog)])
	var text: int = _g(A5_ITEM_TEXT)
	_trap(TRAP_GET_ITEXT, [text, memory.read_u32(a6 - 4)])
	_jt(JT_P2C, [text])
	var p: int = text
	while memory.read_u8(p) != 0:
		var c: int = memory.read_u8(p)
		if memory.read_u8(C68kScript.u32(_g(A5_CTYPE) + c)) & 0x80 != 0:
			memory.write_u8(p, _jt(JT_TO_UPPER, [C68kScript.u16(C68kScript.s8(c))]) & 0xff)
		p += 1
	return text

## 0x560: the copy-protection dialog: the code strings built (0x3ba) and, unless the stored code's
## index already matches, a random challenge shown (three numbers via NumToString, DLOG 1000
## centred, ExitToShell when it cannot be made) until a response validates: item 4 decoded into the
## stored code, item 3 checked against the challenge, a failed answer shown in ALRT 1001 (centred).
## Item 2 quits. A matching index afterwards stores the pair in 'TEXT' 128; the port is restored.
func run_protection_dialog(code: int, other: int) -> void:
	assert(a7 != 0, "run_protection_dialog needs a7 (its frame holds the strings)")
	var entry: int = a7
	var a6: int = entry - 4
	_trap(TRAP_GET_PORT, [a6 - 0x272])
	_trap(TRAP_INIT_CURSOR, [])
	_local(LOCAL_BUILD_CODE_STRINGS, [C68kScript.u32(code), a6 - 0x100, C68kScript.u32(other), a6 - 0x200])
	if record_code_index_equals(memory.read_u32(C68kScript.u32(code)), a6 - 0x1fa) & 0xffff != 0:
		return
	pick_random_protection_challenge(a6 - 0x262, a6 - 0x264, a6 - 0x266)
	_jt(JT_NUM_TO_STRING, [a6 - 0x220, C68kScript.u32(memory.read_s16(a6 - 0x262))])
	_jt(JT_NUM_TO_STRING, [a6 - 0x240, C68kScript.u32(memory.read_s16(a6 - 0x264))])
	_jt(JT_NUM_TO_STRING, [a6 - 0x260, C68kScript.u32(memory.read_s16(a6 - 0x266))])
	center_template_rect_on_screen(0x444c4f47, 0x3e8)
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, 0x3e8]))
	if dialog == 0:
		_trap(TRAP_EXIT_TO_SHELL, [])
	_trap(TRAP_SHOW_WINDOW, [dialog])
	var valid: int = 0
	while valid == 0:
		_jt(JT_C2P, [a6 - 0x200])
		_trap(TRAP_PARAM_TEXT, [a6 - 0x200, a6 - 0x260, a6 - 0x240, a6 - 0x220])
		_trap(TRAP_DRAW_DIALOG, [dialog])
		while true:
			_trap(TRAP_MODAL_DIALOG, [a6 - 0x268, _g(0x562)])
			var hit: int = memory.read_u16(a6 - 0x268)
			if hit == 1:
				break
			if hit == 2:
				_trap(TRAP_EXIT_TO_SHELL, [])
		_jt(JT_P2C, [a6 - 0x200])
		a7 = entry - 4 - 0x272 - 6 - 4
		var decoded: int = decode_code_to_long_b(get_dialog_item_text_upper(dialog, 4))
		memory.write_u32(C68kScript.u32(code), C68kScript.u32(decoded))
		var answer: int = get_dialog_item_text_upper(dialog, 3)
		a7 = entry
		valid = validate_protection_response(memory.read_u16(a6 - 0x262), memory.read_u16(a6 - 0x264), memory.read_u16(a6 - 0x266), answer) & 0xffff
		if valid != 0:
			break
		a7 = entry - 4 - 0x272 - 6 - 4
		var shown: int = get_dialog_item_text_upper(dialog, 3)
		a7 = entry
		_trap(TRAP_PARAM_TEXT, [0, 0, 0, C68kScript.u32(_jt(JT_C2P, [shown]))])
		center_template_rect_on_screen(0x414c5254, 0x3e9)
		_trap(TRAP_STOP_ALERT, [0, 0x3e9])
	_trap(TRAP_DISPOSE_DIALOG, [dialog])
	if record_code_index_equals(memory.read_u32(C68kScript.u32(code)), a6 - 0x1fa) & 0xffff != 0:
		write_TEXT128_pair(memory.read_u32(C68kScript.u32(code)), memory.read_u32(C68kScript.u32(other)))
	_trap(TRAP_SET_PORT, [memory.read_u32(a6 - 0x272)])
