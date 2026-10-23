extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const PLANE := 0x21000
const CTL := 0x21100
const OUT := 0x21f00

## Expected values follow the disassembly of atan2_fixed14 (0x102d6),
## enqueue_control_inputs_avg4 (0x10558), build_relative_steer_sample (0x10360),
## apply_relative_heading_steer (0x109ba) and steer_entity_toward_point (0x10b2e). With level
## attitude (angles 0, identity) the steering sample's angles come from the
## attitude_from_velocity Python model: (1000, 0, 0) -> pitch 0, heading -0x1000; (1000, 2000,
## 0) -> pitch 2887; the far, climb-limited (0x4000, 0x1000, 0) -> pitch 639. The trig tables are
## the original ones.

var memory
var port

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
		memory.write_u8(0x1af6c + i, binary[0x1af8c + i])
	memory.write_u32(CTL, PLANE)

func _sample(x: int, y: int, z: int) -> Array:
	var low: int = port.build_relative_steer_sample(CTL, x, y, z, OUT, OUT + 4, OUT + 0x10, OUT + 0x12)
	return [low, memory.read_s32(OUT), memory.read_s16(OUT + 4 + 2), memory.read_s16(OUT + 4 + 6), memory.read_s16(OUT + 0x10), memory.read_s16(OUT + 0x12)]

func run() -> bool:
	var ok := true
	_setup()

	## atan2: the four axes, and (0, 0) returning the caller's D2 & 0x3fff.
	ok = Assertions.assert_equal([port.atan2_fixed14(100, 0), port.atan2_fixed14(-100, 0), port.atan2_fixed14(0, 100), port.atan2_fixed14(0, -100), port.atan2_fixed14(0, 0, 0x12345)], [0x3000, 0x1000, 0, 0x2000, 0x2345], "atan2 axes and the untouched-D2 case") and ok

	## Control ring: clamps, then averages over the ring (the slot written three calls ago drops).
	var got := []
	for c in [[100, 1000, -500], [0, 0, 40], [-10, 100, 40], [0, 0, 0], [0, 0, 0]]:
		port.enqueue_control_inputs_avg4(CTL, c[0], c[1], c[2])
		got.append([memory.read_s16(CTL + 0x666), memory.read_s16(CTL + 0x662), memory.read_s16(CTL + 0x664)])
	ok = Assertions.assert_equal(got, [[-80, 128, 16], [-70, 128, 16], [-60, 153, 13], [20, 25, -2], [10, 25, -2]], "ring: clamped inputs, sums / 4 toward zero") and ok
	## Damage byte +0x685 bit 0: inputs ignored.
	memory.write_u8(CTL + 0x685, 1)
	port.enqueue_control_inputs_avg4(CTL, 50, 50, 50)
	ok = Assertions.assert_equal(memory.read_s16(CTL + 0x666), 10, "damaged controls: ignored") and ok

	## Steering sample, level flight 5000 up: target 1000 ahead in x.
	_setup()
	memory.write_u32(PLANE + 0x1c, 5000)
	ok = Assertions.assert_equal(_sample(1000, 5000, 0), [0, 5000, 1000, 0, 0, -0x1000], "sample: high, target along x") and ok
	## 2000 up: the target is raised by 2000 (y 2000 -> 4000) and the flag set.
	memory.write_u32(PLANE + 0x1c, 2000)
	ok = Assertions.assert_equal(_sample(1000, 2000, 0), [1, 2000, 1000, 2000, 2887, -0x1000], "sample: low, target raised") and ok
	## Far away (0x10000 in x) with a 0x1000 climb: limited to horiz / 4, scaled down by 4.
	memory.write_u32(PLANE + 0x1c, 5000)
	ok = Assertions.assert_equal(_sample(0x10000, 5000 + 0x1000, 0), [0, 5000, 0x4000, 0x1000, 639, -0x1000], "sample: far, climb limited") and ok

	## Steer, small errors: elevator 5p - 4p', aileron 2h - h', rudder aileron / 16.
	_setup()
	memory.write_u16(CTL + 0x61a, 10)
	memory.write_u16(CTL + 0x61c, 20)
	port.apply_relative_heading_steer(CTL, 100, OUT, 40, 100)
	ok = Assertions.assert_equal([memory.read_s16(CTL + 0x64c), memory.read_s16(CTL + 0x644), memory.read_s16(CTL + 0x654), memory.read_s16(CTL + 0x61a), memory.read_s16(CTL + 0x61c)], [160, 180, 11, 40, 100], "small errors: PD commands") and ok
	## Big heading error, target to the left (-100, 0), height 0x800: bank limited to 0x800.
	_setup()
	memory.write_u16(OUT + 2, -100 & 0xffff)
	memory.write_u16(OUT + 6, 0)
	port.apply_relative_heading_steer(CTL, 0x800, OUT, 0, 0x1500)
	var elev: int = (port.cos_fixed14(0x800) << 9) >> 12
	ok = Assertions.assert_equal([memory.read_s16(CTL + 0x61e), memory.read_s16(CTL + 0x644), memory.read_s16(CTL + 0x64c), memory.read_s16(CTL + 0x654)], [0x800, 0x140, elev, 0], "big error: bank to the height limit, aileron clamped, elevator from cos") and ok
	## steer_entity_toward_point runs both with the frame (level, 5000 up, target along x).
	_setup()
	memory.write_u32(PLANE + 0x1c, 5000)
	port.steer_entity_toward_point(CTL, 1000, 5000, 0)
	## Heading error -0x1000 is large: bank error fold(atan2(1000, 0)) = -0x1000. At 5000 up the
	## bank limit is 0x1000 + ((5000 - 0x1000) << 12 >> 14) = 4322; the target 0x3000 lies above
	## its mirror 0x4000 - 4322, so the bank error stays -0x1000.
	ok = Assertions.assert_equal([memory.read_s16(CTL + 0x61c), memory.read_s16(CTL + 0x61a), memory.read_s16(CTL + 0x61e), port.a7], [-0x1000, 0, -0x1000, STACK_TOP], "steer_entity_toward_point: errors stored, bank error kept") and ok
	return ok
