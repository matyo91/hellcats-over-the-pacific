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
