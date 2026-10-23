extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const RUNS := 0x22000
const OBJ := 0x21000
const OTHER := 0x21200
const PARACHUTE := 0x22800

## Expected values follow the disassembly of reset_span_row_lists (0x6e74),
## update_view_clip_bounds (0x6ed6), release_fractal_reference (0x14af2),
## drop_contact_records_for_object (0x137da) and spawn_bailout_parachute (0x19430).

var memory
var port
var fixture
var printed: Array = []

func _printf(format: int) -> void:
	printed.append(format)

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.code_table[0x1234] = Callable(self, "_printf")
	port.code_table[0x1254 - 0x20] = Callable(self, "_printf")
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	printed.clear()

func run() -> bool:
	var ok := true

	## Span runs: view 3 rows of width 320, fill colour 7; only slot 2 has a buffer.
	_setup()
	memory.write_u16(0x1b828, 3)
	memory.write_u16(0x1b82a, 320)
	memory.write_u16(0x1daa0, 7)
	memory.write_u32(0x1b77c, RUNS)
	port.reset_span_row_lists(1)
	ok = Assertions.assert_equal(memory.read_u16(RUNS + 2), 0, "slot 1 requested: slot 2 untouched") and ok
	port.reset_span_row_lists(0)
	var runs := []
	for r in range(4):
		runs.append([memory.read_u16(RUNS + 8 * r), memory.read_u16(RUNS + 8 * r + 2), memory.read_u16(RUNS + 8 * r + 4), memory.read_u16(RUNS + 8 * r + 6)])
	ok = Assertions.assert_equal(runs, [[0, 1, 320, 7], [0, 1, 320, 7], [0, 1, 320, 7], [0, 0, 0, 0]], "all slots: one run per row") and ok

	## View bounds: 201 rows, cockpit view (mode 2) with host +0xa2 set -> inset 0x14.
	_setup()
	memory.write_u16(0x1b828, 201)
	memory.write_u16(0x1d858, 2)
	memory.write_u16(PoolFixtureScript.WORLD + 0xa2, 1)
	memory.write_u16(0x20b14, 111)
	memory.write_u16(0x20afc, 222)
	memory.write_u16(0x20b16, 333)
	memory.write_u16(0x20afe, 444)
	port.update_view_clip_bounds()
	ok = Assertions.assert_equal([memory.read_u16(0x1b73e), memory.read_u16(0x20ae8), memory.read_u16(0x20ae6), memory.read_u16(0x20ae2), memory.read_u16(0x1daa2), memory.read_u16(0x20b28), memory.read_u16(0x20b26)], [80, 80, 181, 4, 1, 111, 222], "inset view: half 100 - 20, last row 181, entry-0 scales") and ok
	## View mode 6 with scale index 1: the second table entries; no inset in mode 1.
	memory.write_u16(0x1d858, 6)
	memory.write_u16(0x20af4, 1)
	port.update_view_clip_bounds()
	ok = Assertions.assert_equal([memory.read_u16(0x20b28), memory.read_u16(0x20b26)], [333, 444], "mode 6: indexed scales") and ok
	memory.write_u16(0x1d858, 1)
	port.update_view_clip_bounds()
	ok = Assertions.assert_equal([memory.read_u16(0x1b73e), memory.read_u16(0x20ae6), memory.read_u16(0x20ae2), memory.read_u16(0x20b28)], [100, 201, 0, 111], "mode 1: no inset, entry 0") and ok

	## Fractal reference: a user counts the shared block down (to 0 -> deferred free flag).
	_setup()
	var block: int = port.heap_alloc(8)
	memory.write_u16(block, 1)
	memory.write_u32(OBJ + 0x2c, block)
	port.release_fractal_reference(OBJ)
	ok = Assertions.assert_equal([memory.read_u16(block), memory.read_u16(0x1c1bc), memory.read_u32(OBJ + 0x2c)], [0, 1, 0], "user: block count 1 -> 0, deferred free") and ok
	## An owner (byte +6 bit 1) whose block is still used by another pool object releases it and
	## frees the block and the list; the warning is not printed once the block is unused.
	_setup()
	block = port.heap_alloc(8)
	var list: int = port.heap_alloc(8)
	memory.write_u16(block, 1)
	memory.write_u16(list, 1)
	memory.write_u32(list + 4, block)
	memory.write_u8(OBJ + 6, 2)
	memory.write_u32(OBJ + 0x2c, list)
	memory.write_u32(OTHER + 0x2c, block)
	memory.write_u32(0x1b5a4, OTHER)
	memory.write_u32(0x1b734, 1)
	port.release_fractal_reference(OBJ)
	ok = Assertions.assert_equal([memory.read_u32(OTHER + 0x2c), memory.read_u32(OBJ + 0x2c), printed, port.heap_alloc(8) == list or port.heap_alloc(8) == block, port.a7], [0, 0, [], true, STACK_TOP], "owner: user released, blocks freed, no warning") and ok

	## Contact records naming the object are freed and cleared; others stay.
	_setup()
	var rec_a: int = port.heap_alloc(12)
	var rec_b: int = port.heap_alloc(12)
	memory.write_u32(rec_a, OBJ)
	memory.write_u32(rec_a + 4, OTHER)
	memory.write_u32(rec_b, OTHER)
	memory.write_u32(rec_b + 4, 0x21400)
	memory.write_u32(0x1bdbc + 4 * 5, rec_a)
	memory.write_u32(0x1bdbc + 4 * 9, rec_b)
	port.drop_contact_records_for_object(OBJ)
	ok = Assertions.assert_equal([memory.read_u32(0x1bdbc + 4 * 5), memory.read_u32(0x1bdbc + 4 * 9)], [0, rec_b], "contact records of the object dropped") and ok

	## Parachute: thirteen vertices of template 1 (all (80, -16, 8)) scaled by 1/8; velocities.
	_setup()
	fixture.add_template(1, 5)
	var desc := PoolFixtureScript.BASE + 0x400 + 0x40
	memory.write_u16(desc + 0x1a, 13)
	for v in range(13):
		memory.write_u32(desc + 0x22 + 12 * v, 80)
		memory.write_u32(desc + 0x26 + 12 * v, -16 & 0xffffffff)
		memory.write_u32(desc + 0x2a + 12 * v, 8)
	memory.write_u32(0x26780, fixture.template_object(PARACHUTE, 1))
	memory.write_u32(0x1b838, 77)
	## Angles 0 (no rotation through the template slot), so the vertices stay (80, -16, 8).
	var ctl: int = port.spawn_bailout_parachute(0x10005, 0, 0, 0, 0, 0, 0)
	var verts: int = memory.read_u32(memory.read_u32(ctl) + 0x44)
	ok = Assertions.assert_equal([memory.read_u32(ctl + 0x610), memory.read_u16(ctl + 0x614), memory.read_s32(verts + 12 * 12), memory.read_s32(verts + 12 * 12 + 4), memory.read_s32(ctl + 0x622 + 48), memory.read_s32(ctl + 0x656 + 48), memory.read_s32(ctl + 0x68a + 48), memory.read_u32(ctl + 0x618), memory.read_u16(ctl + 0x61c), port.a7], [77, 5, 10, -2, 10 * 0x1c6, -2 * 0x1c6, 1 * 0x255, 7, 0x62, STACK_TOP], "parachute: vertices / 8, start velocities") and ok
	## The attitude words are stored as given.
	var ctl2: int = port.spawn_bailout_parachute(0, 0, 0, 0, 0x100, 0x200, 0x300)
	ok = Assertions.assert_equal([memory.read_u16(ctl2 + 0x20), memory.read_u16(ctl2 + 0x22), memory.read_u16(ctl2 + 0x24)], [0x100, 0x200, 0x300], "parachute: attitude words") and ok
	return ok
