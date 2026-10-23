extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const PLANE := 0x21000
const CTL := 0x21100
const REC := 0x21900

## update_aircraft_entity (0xe792). Block 0 (a wreck on the ground, damage word bit 0x800, only
## settles and wobbles) is checked by hand from the bytes 0xe792..0xe89c with a twin overlay RNG.
## The flight path is checked against the ORIGINAL bytes: tools/strict_port/
## gen_flight_model_cases.py runs the routine on the binary image in the m68k_emu interpreter
## and records every byte it changes outside the stack (fixtures/flight_model_cases.json); here
## the same image, RNG seed and writes go through the port, which must change exactly the
## same bytes.
const FIXTURE := "res://tests/strict_port/fixtures/flight_model_cases.json"
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"

var memory
var port
var twin

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	memory.write_u32(CTL, PLANE)
	memory.write_u32(CTL + 4, REC)
	memory.write_u16(REC + 0x40, 51)
	memory.write_u16(CTL + 0x684, 0x800)
	memory.write_u32(CTL + 0x2e, 1000)
	memory.write_u16(CTL + 0x20, 0x3ff0)
	memory.write_u16(CTL + 0x24, 0x10)
	memory.write_u8(CTL + 0x669, 1)

func run() -> bool:
	var ok := true

	## Ground at 1000, wreck at 1010 (within 0x16 of it): floor = 1000 + 51 / 2 = 1025, so +0xc =
	## 1025 - 1010 = 15.
	_setup()
	memory.write_u32(PLANE + 0x1c, 1010)
	var r1: int = twin.overlay_rng_next() & 0x7f
	var r2: int = twin.overlay_rng_next() & 0x7f
	port._jsr(0xe772, [CTL])
	ok = Assertions.assert_equal([memory.read_s32(CTL + 0xc), memory.read_u32(REC) == memory.read_u32(REC), memory.read_u32(0x26004)], [15, true, REC], "wreck: settles to the floor, type record bound") and ok
	ok = Assertions.assert_equal([memory.read_s16(CTL + 0x61e), memory.read_u16(CTL + 0x24), memory.read_s16(CTL + 0x61a), memory.read_u16(CTL + 0x20), memory.read_u8(CTL + 0x669), port.a7], [r1, (0x10 + r1) & 0x3fff, -r2, (0x3ff0 - r2) & 0x3fff, 0, STACK_TOP], "wreck: wobble, engine off") and ok
	## Gear down ('-') uses the full template +0x40; sinking on water (type 0x10) sets 0x1000 and,
	## for the player, the ditch sound.
	_setup()
	memory.write_u8(CTL + 0x679, 0x2d)
	memory.write_u8(CTL + 0x2c, 0x10)
	memory.write_u32(PLANE + 0x1c, 1000)
	memory.write_u32(0x1b738, CTL)
	port.update_aircraft_entity(CTL)
	ok = Assertions.assert_equal([memory.read_s32(CTL + 0xc), memory.read_u16(CTL + 0x684) & 0x1000, memory.read_u16(0x1b850)], [51, 0x1000, 1], "wreck on water: full adjustment, sinking flag, ditch sound") and ok
	## More than 0x16 above the ground (+0x2e < y - 0x16): falls at -0x16.
	_setup()
	memory.write_u32(PLANE + 0x1c, 2000)
	port.update_aircraft_entity(CTL)
	ok = Assertions.assert_equal(memory.read_s32(CTL + 0xc), -0x16, "wreck above the floor: falls at -0x16") and ok
	ok = _original_cases() and ok
	return ok

func _original_cases() -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	var size: int = int(fixture["memory_size"])
	var image := binary.slice(0x20, 0x20 + size)
	image.resize(size)
	var guard_lo: int = int(fixture["stack_guard"][0])
	var guard_hi: int = int(fixture["stack_guard"][1])
	for c in fixture["cases"]:
		var mem = Memory68kScript.new(size)
		mem._bytes = image.duplicate()
		var p = PacificConflictScript.new(mem)
		p.a7 = int(fixture["stack_top"])
		p.overlay_rng_init(1)
		for w in c["writes"]:
			match int(w[1]):
				1:
					mem.write_u8(int(w[0]), int(w[2]))
				2:
					mem.write_u16(int(w[0]), int(w[2]))
				_:
					mem.write_u32(int(w[0]), int(w[2]))
		var before: PackedByteArray = mem._bytes.duplicate()
		p._jsr(int(fixture["routine"]), [int(fixture["ctl"])])
		var got := []
		for addr in range(size):
			if addr >= guard_lo and addr < guard_hi:
				continue
			if mem._bytes[addr] != before[addr]:
				got.append([addr, mem._bytes[addr]])
		var want := []
		for ch in c["changes"]:
			want.append([int(ch[0]), int(ch[1])])
		if got != want:
			var diffs := []
			var gd := {}
			for g in got:
				gd[g[0]] = g[1]
			var wd := {}
			for x in want:
				wd[x[0]] = x[1]
			for addr in gd.keys() + wd.keys():
				if gd.get(addr, -1) != wd.get(addr, -1) and diffs.size() < 12 and not diffs.has("%x: port %d original %d" % [addr, gd.get(addr, before[addr]), wd.get(addr, before[addr])]):
					diffs.append("%x: port %d original %d" % [addr, gd.get(addr, before[addr]), wd.get(addr, before[addr])])
			diffs.sort()
			print("  diffs: ", diffs)
		ok = Assertions.assert_equal(got.size() == want.size() and got == want, true, "original bytes: %s (%d bytes)" % [c["name"], want.size()]) and ok
	return ok
