extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"
const PITCH := 0x21000
const HEADING := 0x21002

## Expected values from an instruction-level Python model of acos_fixed14 (0x1e3a),
## atan_fixed14 (0x1ebc), isqrt_floor (0xe372) and attitude_from_velocity (0x1f22) over the same
## table bytes (cos_table file 0x1ad8c, tan_table file 0x1af8c; runtime = file - 0x20),
## independent of this port. isqrt_floor never returns 0x7fff: the search stops at hi - 1, so
## isqrt(0x3fff0001) is 32766. Tangents past the table land on its last, out-of-order entry.
const ACOS := [[0x1000, 0], [0x2000, 0], [-0x2000, 8192], [0, 4096], [0x800, 2730], [-0x800, 5461], [1234, 3298], [-3000, 6239], [0xfff, 64]]
const ATAN := [[0, 0], [0x1000, 2048], [-0x1000, 14335], [0x800, 1208], [-0x2345, 13399], [0x7fffffff, 4223], [-0x7fffffff, 12479], [100, 63]]
const ISQRT := [[0, 0], [1, 1], [2, 1], [3, 1], [4, 2], [15, 3], [16, 4], [17, 4], [10000, 100], [10001, 100], [0x3fff0001, 32766], [0x7fffffff, 32766], [-5, 0]]
## [vx, vy, vz, speed, speed_sq, heading, pitch] (-1 = left unwritten)
const ATTITUDE := [
	[100, 0, 0, 100, 10000, 12288, 0], [-100, 0, 0, 100, 10000, 4096, 0],
	[0, 0, 100, 100, 10000, 0, 0], [0, 0, -100, 100, 10000, 8192, 0],
	[30, 40, -50, 70, 5000, 9602, 1586], [-70, 10, 20, 73, 5400, 3371, 359],
	[5, -200, 3, 200, 40034, 13696, 12353], [0, 0, 0, 0, 0, -1, -1],
	[3, 90, 4, 90, 8125, 14705, 3951], [-20, -30, 10, 37, 1400, 2888, 13919],
]

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var port = PacificConflictScript.new(memory)
	for i in range(0x200):
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])
		memory.write_u8(0x1af6c + i, binary[0x1af8c + i])
	for c in ACOS:
		ok = Assertions.assert_equal(port.acos_fixed14(c[0]), c[1], "acos_fixed14(%d)" % c[0]) and ok
	for c in ATAN:
		ok = Assertions.assert_equal(port.atan_fixed14(c[0]), c[1], "atan_fixed14(%d)" % c[0]) and ok
	for c in ISQRT:
		ok = Assertions.assert_equal(port.isqrt_floor(c[0]), c[1], "isqrt_floor(%d)" % c[0]) and ok
	for c in ATTITUDE:
		memory.write_u16(PITCH, 0xffff)
		memory.write_u16(HEADING, 0xffff)
		port.attitude_from_velocity(c[0], c[1], c[2], c[3], c[4], PITCH, HEADING)
		var got := [memory.read_u16(HEADING), memory.read_u16(PITCH)]
		var want := [c[5] if c[5] >= 0 else 0xffff, c[6] if c[6] >= 0 else 0xffff]
		ok = Assertions.assert_equal(got, want, "attitude_from_velocity(%d, %d, %d)" % [c[0], c[1], c[2]]) and ok
	return ok
