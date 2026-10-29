class_name StrictID07
extends RefCounted
## Strict translations owned by CODE segment 07 (ID07.bin; address = file offset, 4-byte header):
## the STR# 129 string table. The sole provenance and verification record lives in mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`).
## Calls leaving the segment go through `_jt` / `_trap` (see StrictID02), filled by tests with
## logging stand-ins.

const C68kScript := preload("res://strict_port/compat/c68k.gd")
const StrictID02Script := preload("res://strict_port/code/ID02.gd")

const A5_STRINGS: int = -0xf46   ## 121 string pointers (entries 1..120 used)
const JT_HLOCK: int = 0x272
const TRAP_GET_RESOURCE: int = 0xa9a0

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

## 0x6: STR# 129 (GetResource, locked) turned in place into 120 usable strings, pointers at A5 -
## 0xf46 + 4 i (i = 1..120). Each Pascal string has its escapes resolved ("\r" -> 13, "\t" -> 9,
## any other backslash kept as is: the dense switch of ID01 JT $3a on the next character); one that
## starts with "\p" loses those two characters and stays a Pascal string, any other becomes a C
## string (moved down a byte and terminated). The moves go through ID02's memmove (JT $4fa).
func load_str129_string_table() -> void:
	var id02 = StrictID02Script.new(memory, a5)
	var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [0x81, 0x53545223]))
	_jt(JT_HLOCK, [h])
	var p: int = C68kScript.u32(memory.read_u32(h) + 2)
	for i in range(1, 0x79):
		var length: int = memory.read_u8(p)
		var next: int = C68kScript.u32(p + length + 1)
		var c_string: bool = true
		if memory.read_u8(p + 1) == 0x5c and memory.read_u8(p + 2) == 0x70:
			id02.ansi_memmove(C68kScript.u32(p + 1), C68kScript.u32(p + 3), C68kScript.u32(C68kScript.s16(length) - 2))
			length = C68kScript.s16(length - 2)
			c_string = false
		var d: int = 1
		var j: int = 1
		while j <= length:
			var ch: int = memory.read_u8(C68kScript.u32(p + C68kScript.s16(j)))
			if ch == 0x5c:
				match memory.read_u8(C68kScript.u32(p + C68kScript.s16(j) + 1)):
					0x72:
						ch = 0x0d
						j += 1
					0x74:
						ch = 0x09
						j += 1
			memory.write_u8(C68kScript.u32(p + C68kScript.s16(d)), ch)
			d += 1
			j += 1
		length = C68kScript.s16(d - 1)
		if c_string:
			id02.ansi_memmove(p, C68kScript.u32(p + 1), C68kScript.u32(length))
			memory.write_u8(C68kScript.u32(p + length), 0)
		else:
			memory.write_u8(p, length & 0xff)
		memory.write_u32(C68kScript.u32(a5 + A5_STRINGS + 4 * i), p)
		p = next

## 0x190: the string table loaded, then four groups of its pointers copied: entries 2..22 to A5 -
## 0x221e, 0x5e..0x63 to A5 - 0xffe, 0x64..0x69 to A5 - 0xfae and 0x6a..0x73 to A5 - 0xf86.
func init_string_pointer_groups() -> void:
	load_str129_string_table()
	for group in [[-0x221e, 2, 0x15], [-0xffe, 0x5e, 6], [-0xfae, 0x64, 6], [-0xf86, 0x6a, 0xa]]:
		for k in group[2]:
			memory.write_u32(C68kScript.u32(a5 + group[0] + 4 * k), memory.read_u32(C68kScript.u32(a5 + A5_STRINGS + 4 * (k + group[1]))))
