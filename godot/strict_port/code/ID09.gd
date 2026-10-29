class_name StrictID09
extends RefCounted
## Strict translations owned by CODE segment 09 (ID09.bin; address = file offset, 4-byte header):
## the Toolbox glue. The sole provenance and verification record lives in mappings/functions.json.
##
## MPW C passes int as a 16-bit word; pointers and longs are longs. Globals live below A5 (`a5`).
## Calls leaving the segment go through `_jt` / `_trap` (see StrictID02), filled by tests with
## logging stand-ins.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const TRAP_SWAP_MMU_MODE: int = 0xa05d  ## OS trap: the mode byte in D0, the old mode back in D0

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

## 0x3c2: SwapMMUMode(VAR mode): the mode byte through the trap (D0) and the result's low byte
## stored back (the glue pops its argument).
func swapmmumode_glue(mode: int) -> void:
	var d0: int = _trap(TRAP_SWAP_MMU_MODE, [memory.read_u8(C68kScript.u32(mode))])
	memory.write_u8(C68kScript.u32(mode), d0 & 0xff)

## 0x432: a length-prefixed string turned into a C string in place (bytes moved down one, then a
## terminator); returns it.
func length_prefixed_bytes_to_c_string_in_place(p: int) -> int:
	var n: int = memory.read_u8(C68kScript.u32(p))
	for k in n:
		memory.write_u8(C68kScript.u32(p + k), memory.read_u8(C68kScript.u32(p + k + 1)))
	memory.write_u8(C68kScript.u32(p + n), 0)
	return C68kScript.u32(p)
