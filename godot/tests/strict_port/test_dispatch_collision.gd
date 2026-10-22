extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const HANDLER_A := 0x701 ## test-only handler addresses
const HANDLER_B := 0x702

## The pair table is copied from the original binary (file 0x1b45c = runtime 0x1b43c). Expected
## dispatch from the disassembly of 0x14348..0x14438: (14, 1) -> runtime 0x167d4 =
## bullet_hits_aircraft; (12, 4) -> runtime 0x14326, a lone rts that returns D0 unchanged;
## no pair -> a's handler when a byte +6 bit 5, else b's; view_mode 8 or byte +5 bit 0 -> none.

var calls: Array = []
var memory
var port

func _handler_a(a: int, b: int, c: int) -> int:
	calls.append(["A", a, b, c])
	return 0xaaaa

func _handler_b(a: int, b: int, c: int) -> int:
	calls.append(["B", a, b, c])
	return 0xbbbb

func _object(address: int, def_type: int, handler: int) -> void:
	var ctl := address + 0x100
	var definition := address + 0x200
	memory.write_u32(address + 8, ctl)
	memory.write_u32(ctl + 4, definition)
	memory.write_u16(definition, def_type)
	memory.write_u32(definition + 0x12, handler)

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1b45c + 80, true, "original binary readable") and ok
	if not ok:
		return false
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	for i in range(80):
		memory.write_u8(0x1b43c + i, binary[0x1b45c + i])
	port.code_table[HANDLER_A] = Callable(self, "_handler_a")
	port.code_table[HANDLER_B] = Callable(self, "_handler_b")
	port.overlay_rng_init(1)

	## Bullet (type 0xe) vs aircraft (type 1), far apart: bullet_hits_aircraft returns the distance.
	var bullet := 0x21000
	var aircraft := 0x22000
	_object(bullet, 0xe, HANDLER_A)
	_object(aircraft, 1, HANDLER_B)
	memory.write_u32(aircraft + 0x18, 5000)
	memory.write_u32(aircraft + 0x14, 10)
	ok = Assertions.assert_equal(port.dispatch_collision(bullet, aircraft), 5000, "pair (14, 1) -> bullet_hits_aircraft") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x26284), 0x1b43c + 8 * 1, "cursor left on entry 1") and ok
	ok = Assertions.assert_equal(port.dispatch_collision(aircraft, bullet), 5000, "reversed order still calls it with the bullet first") and ok
	ok = Assertions.assert_equal(calls.size(), 0, "no own handler called for a pair") and ok

	## Type 0xc vs 4 -> lone rts: D0 unchanged.
	var a := 0x23000
	var b := 0x24000
	_object(a, 0xc, HANDLER_A)
	_object(b, 4, HANDLER_B)
	ok = Assertions.assert_equal(port.dispatch_collision(a, b, 0x55), 0x55, "pair (12, 4) -> rts keeps D0") and ok

	## No pair: b's handler, or a's with byte +6 bit 5.
	memory.write_u16(a + 0x200, 5)
	memory.write_u16(b + 0x200, 6)
	ok = Assertions.assert_equal(port.dispatch_collision(a, b), 0xbbbb, "no pair -> b's handler") and ok
	ok = Assertions.assert_equal(calls[-1], ["B", b, a, 0], "b's handler gets (b, a, 0)") and ok
	ok = Assertions.assert_equal(memory.read_u32(0x26284), 0x1b43c + 8 * 10, "cursor past the table") and ok
	memory.write_u8(a + 6, 0x20)
	ok = Assertions.assert_equal(port.dispatch_collision(a, b), 0xaaaa, "a moving -> a's handler") and ok
	ok = Assertions.assert_equal(calls[-1], ["A", a, b, 0], "a's handler gets (a, b, 0)") and ok

	## One handler only; then the early exits.
	memory.write_u32(b + 0x200 + 0x12, 0)
	memory.write_u8(a + 6, 0)
	ok = Assertions.assert_equal(port.dispatch_collision(a, b), 0xaaaa, "single handler (a)") and ok
	ok = Assertions.assert_equal(port.dispatch_collision(b, a), 0xaaaa, "single handler, a second") and ok
	ok = Assertions.assert_equal(calls[-1], ["A", a, b, 0], "owner first") and ok
	var count := calls.size()
	memory.write_u8(b + 5, 1)
	ok = Assertions.assert_equal(port.dispatch_collision(a, b, 7), 7, "byte +5 bit 0 -> nothing") and ok
	memory.write_u8(b + 5, 0)
	memory.write_u16(0x1d858, 8)
	ok = Assertions.assert_equal(port.dispatch_collision(a, b, 9), 9, "view_mode 8 -> nothing") and ok
	ok = Assertions.assert_equal(calls.size(), count, "no handler on the early exits") and ok
	return ok
