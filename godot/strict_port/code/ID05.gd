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
