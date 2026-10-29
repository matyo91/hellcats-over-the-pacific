extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const CHANGED_FLAG := 0x2666e
const BLIPS_TO_ERASE_COUNT := 0x26672
const TRACK_COUNT := 0x26676

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)

	memory.write_u8(CHANGED_FLAG - 1, 0xa5)
	memory.write_u8(CHANGED_FLAG, 0x7f)
	memory.write_u8(CHANGED_FLAG + 1, 0x5a)
	memory.write_u32(BLIPS_TO_ERASE_COUNT, 0x89abcdef)
	memory.write_u32(TRACK_COUNT, 0x76543210)

	strict_port.reset_radar_tracks()

	ok = Assertions.assert_equal(memory.read_u32(BLIPS_TO_ERASE_COUNT), 0, "clears 32-bit radar blip count") and ok
	ok = Assertions.assert_equal(memory.read_u32(TRACK_COUNT), 0, "clears 32-bit radar track count") and ok
	## moveq #1,d0 / move.l d0,$2666e (0x17776): the flag is a LONG set to 1, overwriting all four bytes.
	ok = Assertions.assert_equal(memory.read_u32(CHANGED_FLAG), 1, "sets the 32-bit radar changed flag") and ok
	ok = Assertions.assert_equal(memory.read_u8(CHANGED_FLAG - 1), 0xa5, "flag store preserves the preceding byte") and ok
	return ok
