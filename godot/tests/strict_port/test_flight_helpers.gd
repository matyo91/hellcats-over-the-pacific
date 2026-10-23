extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const REC := 0x21000
const PLANE := 0x21200
const CTL := 0x21300
const OUT := 0x21f00

## Expected values: table_lerp_1b2c0 (0xe42a), damp_short_if_below_0x200 (0xe468),
## compute_template_force_from_626 (0xe4a4) and scale_template_field_38 (0xe570) from an
## instruction-level Python model over the altitude table bytes (file 0x1b2e0) and the player's
## type record values (lift 0 / 599, flaps 2457 / 599, stall 832, power 8343704);
## adjust_ai_throttle_vs_speed (0x10c2c) and max_ai_throttle_maybe_invert_679 (0x10cb2) worked
## by hand from their bytes.

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var port = PacificConflictScript.new(memory)
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(9 * 4):
		memory.write_u8(0x1b2c0 + i, binary[0x1b2e0 + i])
	memory.write_u32(0x26004, REC)
	memory.write_u16(REC + 0x26, 0)
	memory.write_u16(REC + 0x28, 599)
	memory.write_u16(REC + 0x2a, 2457)
	memory.write_u16(REC + 0x2c, 599)
	memory.write_u16(REC + 0x34, 832)
	memory.write_u32(REC + 0x38, 8343704)

	var got := []
	for a in [0, 0x8000, 0x18000, 0x70000, 0x7ffff, 0x123456]:
		got.append(port.table_lerp_1b2c0(a))
	ok = Assertions.assert_equal(got, [421, 466, 569, 2623, 0, 2086], "altitude curve (band clamped at 7, sawtooth past it)") and ok
	got = []
	for c in [[0x200, 1000], [0x1ff, 1000], [0, 1000], [-100, 500], [100, -800]]:
		got.append(port.damp_short_if_below_0x200(c[0], c[1]))
	ok = Assertions.assert_equal(got, [1000, 1000, 875, 426, -720], "ground effect damping below 0x200") and ok
	got = []
	for c in [[100, 0], [-100, 0], [100, 15], [100, -7], [840, 0], [900, 15], [2000, 0]]:
		memory.write_u8(OUT, 0)
		got.append([port.compute_template_force_from_626(c[0], c[1], OUT), memory.read_u8(OUT)])
	ok = Assertions.assert_equal(got, [[935, 0], [-935, 0], [3392, 0], [2081, 0], [5840, 0xc], [0, 0xc], [0, 0xc]], "lift by angle of attack and flaps, stall fade") and ok
	got = []
	for dn in [421, 1000, 2623]:
		port.scale_template_field_38(dn, OUT)
		got.append(memory.read_s32(OUT))
	ok = Assertions.assert_equal(got, [8343704, 4497777, 1955555], "engine power by density (sea level = rated)") and ok

	## Throttle: airspeed 400 (+0x62a = 1600), throttle 3.
	memory.write_u32(CTL, PLANE)
	memory.write_u32(CTL + 0x62a, 1600)
	memory.write_u8(CTL + 0x668, 3)
	memory.write_u32(PLANE + 0x1c, 300)
	memory.write_u32(CTL + 0x2e, 100)
	memory.write_u8(CTL + 0x679, 5)
	## Target 420: error 20, acc 660 -> throttle + 2, remainder 148; acc > 0x1c2 opens up fully,
	## and the gear moving down 200 above the ground goes back up.
	port.adjust_ai_throttle_vs_speed(CTL, 420)
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x668), memory.read_s16(CTL + 0x63c), memory.read_s16(CTL + 0x620), memory.read_s8(CTL + 0x679)], [9, 148, 20, -5], "faster: full throttle, gear up") and ok
	## Target 380 from a fresh state: acc -660 -> throttle - 2, remainder -148.
	memory.write_u8(CTL + 0x668, 5)
	memory.write_u16(CTL + 0x63c, 0)
	memory.write_u16(CTL + 0x620, 0)
	port.adjust_ai_throttle_vs_speed(CTL, 380)
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x668), memory.read_s16(CTL + 0x63c)], [3, -148], "slower: throttle back") and ok
	## Target 340 from a fresh state: acc -1980 < -0x438 -> throttle clamps to 0, gear 0 -> 1.
	memory.write_u8(CTL + 0x668, 3)
	memory.write_u16(CTL + 0x63c, 0)
	memory.write_u16(CTL + 0x620, 0)
	memory.write_u8(CTL + 0x679, 0)
	port.adjust_ai_throttle_vs_speed(CTL, 340)
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x668), memory.read_u8(CTL + 0x679)], [0, 1], "much slower: throttle 0, gear lowered") and ok
	## Near the ground the gear is not sent back up.
	memory.write_u32(PLANE + 0x1c, 150)
	memory.write_u8(CTL + 0x679, 5)
	port.max_ai_throttle_maybe_invert_679(CTL)
	ok = Assertions.assert_equal([memory.read_u8(CTL + 0x668), memory.read_u8(CTL + 0x679)], [9, 5], "max throttle near the ground: gear kept") and ok
	return ok
