extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"

## Angles 1..6 and the cos / sin words they leave at 0x1d7fa.. / 0x1d7ea.. (instruction-level
## model of sin_fixed14 / cos_fixed14 over the original tables).
const ANGLES := [0x0123, 0x1000, 0x2abc, 0x3fc0, 0x0800, 0x3333]
const SINCOS := {
	0x1d7fa: 4070, 0x1d7fc: 455, 0x1d7f6: 0, 0x1d7f8: 4096,
	0x1d7f2: -2025, 0x1d7f4: -3560, 0x1d7ee: 4095, 0x1d7f0: -101,
	0x1d7ea: 2896, 0x1d7ec: 2896, 0x1d7e6: 1265, 0x1d7e8: -3896,
}
## Expected 3x3 words, produced by interpreting the disassembled move.w / clr.w / neg.w
## sequences of 0x20e6, 0x21a0, 0x2220 and 0x21e0 over those words (not by running this port).
const BASES := {
	0x1d7d4: [4096, 0, 0, 0, 4070, -455, 0, 455, 4070],
	0x1d7bc: [0, 0, 4096, 0, 4096, 0, -4096, 0, 0],
	0x1d7a4: [-2025, -3560, 0, 3560, -2025, 0, 0, 0, 4096],
	0x1d78c: [4095, 0, -101, 0, 4096, 0, 101, 0, 4095],
	0x1d774: [4096, 0, 0, 0, 2896, -2896, 0, 2896, 2896],
	0x1d75c: [1265, 0, -3896, 0, 4096, 0, 3896, 0, 1265],
}
const BASIS4_RX := [4096, 0, 0, 0, 4095, 101, 0, -101, 4095]

func _matrix(memory, base: int) -> Array:
	var out := []
	for k in range(9):
		out.append(memory.read_s16(base + 2 * k))
	return out

func run() -> bool:
	var ok := true
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	ok = Assertions.assert_equal(binary.size() >= 0x1ad8c + 0x200, true, "original binary readable") and ok
	if not ok:
		return false
	var memory = Memory68kScript.new(MEMORY_SIZE)
	var strict_port = PacificConflictScript.new(memory)
	for i in range(0x200):
		memory.write_u8(0x1ab6c + i, binary[0x1ab8c + i])
		memory.write_u8(0x1ad6c + i, binary[0x1ad8c + i])

	strict_port.load_attitude_angle_sincos(ANGLES[0], ANGLES[1], ANGLES[2], ANGLES[3])
	strict_port.load_attitude_angle_sincos_5_6(ANGLES[4], ANGLES[5])
	for address in SINCOS:
		ok = Assertions.assert_equal(memory.read_s16(address), SINCOS[address], "sincos word 0x%x" % address) and ok

	strict_port.fill_attitude_rotation_bases()
	strict_port.fill_attitude_rotation_basis_4()
	strict_port.fill_attitude_rotation_bases_5_6()
	for base in BASES:
		ok = Assertions.assert_equal(_matrix(memory, base), BASES[base], "basis at 0x%x" % base) and ok

	strict_port.fill_attitude_rotation_basis_4_rx()
	ok = Assertions.assert_equal(_matrix(memory, 0x1d78c), BASIS4_RX, "basis 4 as ~Rx") and ok

	## neg.w keeps 0x8000: -(-0x8000) is still -0x8000 as a word.
	memory.write_u16(0x1d7f0, 0x8000)
	strict_port.fill_attitude_rotation_basis_4()
	ok = Assertions.assert_equal(memory.read_s16(0x1d78c + 0xc), -0x8000, "neg.w of 0x8000 wraps") and ok
	return ok
