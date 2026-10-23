extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const LIST := 0x22000
const HEADER := 0x22100
const DEF_WITH := 0x22200
const DEF_WITHOUT := 0x22300
const HANDLER := 0x709 ## test-only notice handler

## Expected pairs follow the disassembly of dispatch_overlap_collisions (0x5832). The list is in
## decreasing metric order: D (1004, radius 1), C (1000, 5), B (120, 10), A (100, 50). Pairs
## are dispatched where the reach (metric + radius) of a later entry passes an earlier entry's
## start (metric - radius); the backward scan stops at the first entry whose running minimum
## (+0x28) is above that reach. B's definition has no notice handler.

var memory
var port
var calls: Array = []

func _notice(self_obj: int, other: int) -> void:
	calls.append([self_obj, other, port.a7])

func _object(address: int, metric: int, radius: int, definition: int) -> void:
	memory.write_u32(address + 0x10, metric)
	memory.write_u32(address + 0xc, radius)
	memory.write_u32(address + 8, address + 0x80)
	memory.write_u32(address + 0x84, definition)

func run() -> bool:
	var ok := true
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.code_table[HANDLER] = Callable(self, "_notice")
	memory.write_u32(DEF_WITH + 0x16, HANDLER)
	var a := 0x21000
	var b := 0x21100
	var c := 0x21200
	var d := 0x21300
	_object(d, 1004, 1, DEF_WITH)
	_object(c, 1000, 5, DEF_WITH)
	_object(b, 120, 10, DEF_WITHOUT)
	_object(a, 100, 50, DEF_WITH)
	var order := [d, c, b, a]
	for i in range(4):
		memory.write_u32(LIST + 4 * i, order[i])
	memory.write_u16(HEADER + 2, 4)
	memory.write_u32(0x1b888, 0x1234)
	port.dispatch_overlap_collisions(LIST, HEADER)
	ok = Assertions.assert_equal(calls, [[c, d, STACK_TOP - 0x30], [d, c, STACK_TOP - 0x30], [a, b, STACK_TOP - 0x30]], "pairs (C, D), (D, C), (A, B); B has no handler; A never reaches C") and ok
	ok = Assertions.assert_equal([memory.read_s32(d + 0x28), memory.read_s32(c + 0x28), memory.read_s32(b + 0x28), memory.read_s32(a + 0x28)], [1003, 995, 110, 50], "running minimum start in +0x28") and ok
	ok = Assertions.assert_equal([memory.read_u32(0x1b888), port.a7], [0, STACK_TOP], "designated_entity_2 cleared") and ok
	## Replay state 3 keeps designated_entity_2.
	memory.write_u32(0x1b888, 0x1234)
	memory.write_u16(0x1b870, 3)
	calls.clear()
	port.dispatch_overlap_collisions(LIST, HEADER)
	ok = Assertions.assert_equal([memory.read_u32(0x1b888), calls.size()], [0x1234, 3], "replay 3: designated kept, same pairs") and ok
	return ok
