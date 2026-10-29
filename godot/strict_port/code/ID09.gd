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

const TRAP_OPEN: int = 0xa000           ## _Open (A0: the parameter block; D0: the result)
const TRAP_HFS_DISPATCH: int = 0xa260   ## _HFSDispatch (D0: the selector)
const TRAP_GET_VOL_INFO: int = 0xa207   ## _GetVolInfo (HFS)
const KEYBOARD_TYPES: Array = [3, 0x13, 0xb, 2, 1]  ## the bytes at 0x54..0x58: keyboard type = index + 1

## 0x48: SysEnvirons(version, VAR world) for systems without it: the 16-byte record filled from low
## memory: version 1; the machine from the ROM (ROMBase 0x2ae: +9 = 0xff unknown -2; +8 > 0: 4, 3 or
## 0 for versions 1, 2, higher; else ROM85 0x28e and HWCfgFlags 0xb22 give -1, 1 or 2); the processor
## (CPUFlag 0x12f + 1, up to a 68030); an FPU (HWCfgFlags bit 12); colour QuickDraw (ROM85 <=
## 0x3fff); the keyboard (KbdType 0x21e in the table at 0x54); the AppleTalk driver version (port B
## config 0x1fb = 1, from *(0x2dc) + 7); the system volume (BootDrive 0x210, or, with HFS (FSFCBLen
## 0x3f6 >= 0), a working directory on the system file's volume: GetFCBInfo of SysMap 0xa58,
## GetVolInfo, OpenWD 'ERIK', in a 0x7a-byte block on the stack). The glue pops its arguments and
## answers -5500 (envNotPresent) in its result slot (returned here).
func sysenvirons_glue_fallback(_version: int, world: int) -> int:
	var rec: int = C68kScript.u32(world)
	for i in 8:
		memory.write_u16(rec + 2 * i, 0)
	memory.write_u16(rec, 1)
	var rom: int = memory.read_u32(0x2ae)
	memory.write_u16(rec + 2, 0xfffe)
	if memory.read_u8(C68kScript.u32(rom + 9)) != 0xff:
		var version: int = C68kScript.s8(memory.read_u8(C68kScript.u32(rom + 8)))
		if version > 0:
			memory.write_u16(rec + 2, 0)
			if version <= 2:
				memory.write_u16(rec + 2, 3 if version == 2 else 4)
		else:
			memory.write_u16(rec + 2, 0xffff)
			if memory.read_s16(0x28e) >= 0:
				memory.write_u16(rec + 2, 1)
				if memory.read_s16(0xb22) < 0:
					memory.write_u16(rec + 2, 2)
	memory.write_u16(rec + 4, 0)
	var cpu: int = C68kScript.s8(memory.read_u8(0x12f))
	if cpu <= 2:
		memory.write_u8(rec + 7, (cpu + 1) & 0xff)
	if memory.read_s16(0x28e) >= 0 and memory.read_u8(0xb22) & 0x10 != 0:
		memory.write_u8(rec + 8, 1)
	if memory.read_u16(0x28e) <= 0x3fff:
		memory.write_u8(rec + 9, 1)
	var kind: int = memory.read_u8(0x21e)
	var index: int = -1
	for k in range(4, -1, -1):
		if KEYBOARD_TYPES[k] == kind:
			index = k
			break
	memory.write_u16(rec + 0xa, C68kScript.u16(index + 1))
	if C68kScript.s8(memory.read_u8(0x291)) >= 0 and memory.read_u8(0x1fb) & 0xf == 1:
		memory.write_u8(rec + 0xd, memory.read_u8(C68kScript.u32(memory.read_u32(0x2dc) + 7)))
	memory.write_u16(rec + 0xe, memory.read_u16(0x210))
	if memory.read_s16(0x3f6) >= 0:
		assert(a7 != 0, "sysenvirons_glue_fallback needs a7 (its parameter block is on the stack)")
		memory.write_u16(rec + 0xe, 0)
		var block: int = a7 - 0x7a
		for k in 0x3d:
			memory.write_u16(block + 2 * k, 0)
		memory.write_u16(block + 0x18, memory.read_u16(0xa58))
		var err: int = _trap(TRAP_HFS_DISPATCH, [8, block])
		if err & 0xffff == 0:
			memory.write_u16(block + 0x16, memory.read_u16(block + 0x34))
			err = _trap(TRAP_GET_VOL_INFO, [err, block])
			if err & 0xffff == 0:
				memory.write_u32(block + 0x30, memory.read_u32(block + 0x5a))
				memory.write_u32(block + 0x1c, 0x4552494b)
				err = _trap(TRAP_HFS_DISPATCH, [1, block])
				if err & 0xffff == 0:
					memory.write_u16(rec + 0xe, memory.read_u16(block + 0x16))
	return 0xea84

## 0x2a6: FSOpen(name, vRefNum, VAR refNum): _Open with a parameter block in the frame (name, volume,
## permission and version 0, no misc); the reference number stored; returns the result word.
func fsopen_glue(name: int, vref: int, ref_num: int) -> int:
	assert(a7 != 0, "fsopen_glue needs a7 (its parameter block is in its frame)")
	var block: int = a7 - 4 - 0x32
	memory.write_u32(block + 0x12, C68kScript.u32(name))
	memory.write_u16(block + 0x16, vref & 0xffff)
	memory.write_u8(block + 0x1a, 0)
	memory.write_u8(block + 0x1b, 0)
	memory.write_u32(block + 0x1c, 0)
	var err: int = _trap(TRAP_OPEN, [0, block])
	memory.write_u16(C68kScript.u32(ref_num), memory.read_u16(block + 0x18))
	return err & 0xffff
