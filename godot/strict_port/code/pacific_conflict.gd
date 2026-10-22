class_name StrictPacificConflict
extends RefCounted
## Strict translations owned by the Pacific Conflict CODE overlay.
## The sole provenance and verification record lives in mappings/functions.json.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const DAT_0001ab6c: int = 0x1ab6c ## sin_table: 256 words (runtime address; file 0x1ab8c)
const DAT_0001ad6c: int = 0x1ad6c ## cos_table: 256 words (runtime address; file 0x1ad8c)
const DAT_0001bdbc: int = 0x1bdbc
const DAT_00020ce4: int = 0x20ce4 ## attitude_compose_tag: composer runtime address ($2408 / $2468 / $26e0)
const DAT_0001d75c: int = 0x1d75c ## basis6: 3x3 s16, element [r][c] at +2 * (3r + c)
const DAT_0001d774: int = 0x1d774 ## basis5
const DAT_0001d78c: int = 0x1d78c ## basis4
const DAT_0001d7a4: int = 0x1d7a4 ## basis3
const DAT_0001d7bc: int = 0x1d7bc ## basis2
const DAT_0001d7d4: int = 0x1d7d4 ## basis1
const DAT_0001d7e6: int = 0x1d7e6 ## angle6_cos
const DAT_0001d7e8: int = 0x1d7e8 ## angle6_sin
const DAT_0001d7ea: int = 0x1d7ea ## angle5_cos
const DAT_0001d7ec: int = 0x1d7ec ## angle5_sin
const DAT_0001d7ee: int = 0x1d7ee ## angle4_cos
const DAT_0001d7f0: int = 0x1d7f0 ## angle4_sin
const DAT_0001d7f2: int = 0x1d7f2 ## angle3_cos
const DAT_0001d7f4: int = 0x1d7f4 ## angle3_sin
const DAT_0001d7f6: int = 0x1d7f6 ## angle2_cos
const DAT_0001d7f8: int = 0x1d7f8 ## angle2_sin
const DAT_0001d7fa: int = 0x1d7fa ## angle1_cos
const DAT_0001d7fc: int = 0x1d7fc ## angle1_sin
const DAT_0001d830: int = 0x1d830 ## camera_z
const DAT_0001d834: int = 0x1d834 ## camera_y
const DAT_0001d838: int = 0x1d838 ## camera_x
const _DAT_0002666e: int = 0x2666e
const DAT_00026672: int = 0x26672
const DAT_00026676: int = 0x26676

var memory
## Stack pointer at entry of the outermost ported call (the address of its return
## address). Only frame locals whose values flow into results are modelled (the
## finalize temp matrix); saved registers and register spills are not written.
var a7: int = 0

func _init(param_memory = null) -> void:
	memory = param_memory

## move.l 4(a7),d0 / bge / neg.l: NEG.L leaves 0x80000000 unchanged, so abs_int(INT_MIN) is INT_MIN.
static func abs_int(value: int) -> int:
	value = C68kScript.s32(value)
	if value < 0:
		value = C68kScript.s32(-value)
	return value

## Signature as restored in the semantic C (stack longs 8..0x1c(A6)); suba.l, signed cmp.l,
## add.l and asr.l #2 all wrap or shift at 32 bits.
static func approx_dist3_xyz(ax: int, ay: int, az: int, bx: int, by: int, bz: int) -> int:
	var d1: int
	var d2: int
	var d3: int
	var dmax: int

	d1 = abs_int(C68kScript.s32(bx - ax))
	d2 = abs_int(C68kScript.s32(by - ay))
	d3 = abs_int(C68kScript.s32(bz - az))
	dmax = d1
	if d1 < d2:
		dmax = d2
		d2 = d1
	d1 = d3
	if dmax < d3:
		d1 = dmax
		dmax = d3
	return C68kScript.s32(dmax + C68kScript.asr32(d1 + d2, 2))

## Source parameter names, expression order, and byte result are preserved.
static func contact_pair_hash(param_1: int, param_2: int) -> int:
	return C68kScript.u8(C68kScript.u8(param_1) ^ (C68kScript.s8(param_2) << 2))

## Object position +0x18 / +0x1c / +0x20 minus the camera (suba.l, 32-bit); the metric is
## stored at +0x10 and also left in D0 (return restored in the semantic C).
func update_object_camera_metric(obj: int) -> int:
	assert(memory != null, "update_object_camera_metric requires original global memory")
	var d1: int
	var d2: int
	var d3: int
	var dmax: int

	d1 = abs_int(C68kScript.s32(memory.read_s32(obj + 0x18) - memory.read_s32(DAT_0001d838)))
	d2 = abs_int(C68kScript.s32(memory.read_s32(obj + 0x1c) - memory.read_s32(DAT_0001d834)))
	d3 = abs_int(C68kScript.s32(memory.read_s32(obj + 0x20) - memory.read_s32(DAT_0001d830)))
	dmax = d1
	if d1 < d2:
		dmax = d2
		d2 = d1
	d1 = d3
	if dmax < d3:
		d1 = dmax
		dmax = d3
	memory.write_u32(obj + 0x10, C68kScript.u32(dmax + C68kScript.asr32(d1 + d2, 2)))
	return memory.read_s32(obj + 0x10)

## Signature (x, y, z) as restored in the semantic C (stack longs 8 / 0xc / 0x10(A6)).
func compute_camera_abs_metric(x: int, y: int, z: int) -> int:
	assert(memory != null, "compute_camera_abs_metric requires original global memory")
	var d1: int
	var d2: int
	var d3: int
	var dmax: int

	d1 = abs_int(C68kScript.s32(x - memory.read_s32(DAT_0001d838)))
	d2 = abs_int(C68kScript.s32(y - memory.read_s32(DAT_0001d834)))
	d3 = abs_int(C68kScript.s32(z - memory.read_s32(DAT_0001d830)))
	dmax = d1
	if d1 < d2:
		dmax = d2
		d2 = d1
	d1 = d3
	if dmax < d3:
		d1 = dmax
		dmax = d3
	return C68kScript.s32(dmax + C68kScript.asr32(d1 + d2, 2))

## Piecewise-linear lookup in the 256-word table (index angle >> 6 with the +0x3f bias of a
## negative angle, 6-bit fraction, muls.l, add.w / ext.l). Callers pass 0..0x3fff.
func sin_fixed14(angle: int) -> int:
	assert(memory != null, "sin_fixed14 requires the original sin_table in memory")
	var idx_src: int
	var next_src: int
	var frac_src: int
	var delta: int

	angle = C68kScript.s32(angle)
	idx_src = angle
	if angle < 0:
		idx_src = C68kScript.s32(angle + 0x3f)
	next_src = angle
	if angle < 0:
		next_src = C68kScript.s32(angle + 0x3f)
	frac_src = angle
	if angle < 0:
		frac_src = C68kScript.s32(angle + 0x3f)
	delta = C68kScript.s32((memory.read_s16(DAT_0001ab6c + C68kScript.u32((C68kScript.asr32(next_src, 6) + 1) & 0xff) * 2) -
			memory.read_s16(DAT_0001ab6c + C68kScript.asr32(idx_src, 6) * 2)) *
			C68kScript.s32(-C68kScript.s32((frac_src & 0xffffffc0) - angle)))
	if delta < 0:
		delta = C68kScript.s32(delta + 0x3f)
	return C68kScript.s16(memory.read_s16(DAT_0001ab6c + C68kScript.asr32(idx_src, 6) * 2) + C68kScript.s16(C68kScript.asr32(delta, 6)))

## Same code as sin_fixed14 on the cosine table.
func cos_fixed14(angle: int) -> int:
	assert(memory != null, "cos_fixed14 requires the original cos_table in memory")
	var idx_src: int
	var next_src: int
	var frac_src: int
	var delta: int

	angle = C68kScript.s32(angle)
	idx_src = angle
	if angle < 0:
		idx_src = C68kScript.s32(angle + 0x3f)
	next_src = angle
	if angle < 0:
		next_src = C68kScript.s32(angle + 0x3f)
	frac_src = angle
	if angle < 0:
		frac_src = C68kScript.s32(angle + 0x3f)
	delta = C68kScript.s32((memory.read_s16(DAT_0001ad6c + C68kScript.u32((C68kScript.asr32(next_src, 6) + 1) & 0xff) * 2) -
			memory.read_s16(DAT_0001ad6c + C68kScript.asr32(idx_src, 6) * 2)) *
			C68kScript.s32(-C68kScript.s32((frac_src & 0xffffffc0) - angle)))
	if delta < 0:
		delta = C68kScript.s32(delta + 0x3f)
	return C68kScript.s16(memory.read_s16(DAT_0001ad6c + C68kScript.asr32(idx_src, 6) * 2) + C68kScript.s16(C68kScript.asr32(delta, 6)))

## Each cos / sin result is stored as a word, cos first (move.w d0,abs.l).
func load_attitude_angle_sincos(angle1: int, angle2: int, angle3: int, angle4: int) -> void:
	assert(memory != null, "load_attitude_angle_sincos requires original global memory")
	var value: int

	value = cos_fixed14(angle1)
	memory.write_u16(DAT_0001d7fa, C68kScript.u16(value))
	value = sin_fixed14(angle1)
	memory.write_u16(DAT_0001d7fc, C68kScript.u16(value))
	value = cos_fixed14(angle2)
	memory.write_u16(DAT_0001d7f6, C68kScript.u16(value))
	value = sin_fixed14(angle2)
	memory.write_u16(DAT_0001d7f8, C68kScript.u16(value))
	value = cos_fixed14(angle3)
	memory.write_u16(DAT_0001d7f2, C68kScript.u16(value))
	value = sin_fixed14(angle3)
	memory.write_u16(DAT_0001d7f4, C68kScript.u16(value))
	value = cos_fixed14(angle4)
	memory.write_u16(DAT_0001d7ee, C68kScript.u16(value))
	value = sin_fixed14(angle4)
	memory.write_u16(DAT_0001d7f0, C68kScript.u16(value))
	return

func load_attitude_angle_sincos_5_6(angle5: int, angle6: int) -> void:
	assert(memory != null, "load_attitude_angle_sincos_5_6 requires original global memory")
	var value: int

	value = cos_fixed14(angle5)
	memory.write_u16(DAT_0001d7ea, C68kScript.u16(value))
	value = sin_fixed14(angle5)
	memory.write_u16(DAT_0001d7ec, C68kScript.u16(value))
	value = cos_fixed14(angle6)
	memory.write_u16(DAT_0001d7e6, C68kScript.u16(value))
	value = sin_fixed14(angle6)
	memory.write_u16(DAT_0001d7e8, C68kScript.u16(value))
	return

## ~Rx (angle 1), ~Ry (angle 2), ~Rz (angle 3); neg.w wraps at 16 bits.
func fill_attitude_rotation_bases() -> void:
	assert(memory != null, "fill_attitude_rotation_bases requires original global memory")
	memory.write_u16(DAT_0001d7d4 + 0x0, 0x1000)
	memory.write_u16(DAT_0001d7d4 + 0x2, 0)
	memory.write_u16(DAT_0001d7d4 + 0x4, 0)
	memory.write_u16(DAT_0001d7d4 + 0x6, 0)
	memory.write_u16(DAT_0001d7d4 + 0x8, memory.read_u16(DAT_0001d7fa))
	memory.write_u16(DAT_0001d7d4 + 0xa, C68kScript.u16(-memory.read_s16(DAT_0001d7fc)))
	memory.write_u16(DAT_0001d7d4 + 0xc, 0)
	memory.write_u16(DAT_0001d7d4 + 0xe, memory.read_u16(DAT_0001d7fc))
	memory.write_u16(DAT_0001d7d4 + 0x10, memory.read_u16(DAT_0001d7fa))
	memory.write_u16(DAT_0001d7bc + 0x0, memory.read_u16(DAT_0001d7f6))
	memory.write_u16(DAT_0001d7bc + 0x2, 0)
	memory.write_u16(DAT_0001d7bc + 0x4, memory.read_u16(DAT_0001d7f8))
	memory.write_u16(DAT_0001d7bc + 0x6, 0)
	memory.write_u16(DAT_0001d7bc + 0x8, 0x1000)
	memory.write_u16(DAT_0001d7bc + 0xa, 0)
	memory.write_u16(DAT_0001d7bc + 0xc, C68kScript.u16(-memory.read_s16(DAT_0001d7f8)))
	memory.write_u16(DAT_0001d7bc + 0xe, 0)
	memory.write_u16(DAT_0001d7bc + 0x10, memory.read_u16(DAT_0001d7f6))
	memory.write_u16(DAT_0001d7a4 + 0x0, memory.read_u16(DAT_0001d7f2))
	memory.write_u16(DAT_0001d7a4 + 0x2, memory.read_u16(DAT_0001d7f4))
	memory.write_u16(DAT_0001d7a4 + 0x4, 0)
	memory.write_u16(DAT_0001d7a4 + 0x6, C68kScript.u16(-memory.read_s16(DAT_0001d7f4)))
	memory.write_u16(DAT_0001d7a4 + 0x8, memory.read_u16(DAT_0001d7f2))
	memory.write_u16(DAT_0001d7a4 + 0xa, 0)
	memory.write_u16(DAT_0001d7a4 + 0xc, 0)
	memory.write_u16(DAT_0001d7a4 + 0xe, 0)
	memory.write_u16(DAT_0001d7a4 + 0x10, 0x1000)
	return

## ~Ry from angle 4.
func fill_attitude_rotation_basis_4() -> void:
	assert(memory != null, "fill_attitude_rotation_basis_4 requires original global memory")
	memory.write_u16(DAT_0001d78c + 0x0, memory.read_u16(DAT_0001d7ee))
	memory.write_u16(DAT_0001d78c + 0x2, 0)
	memory.write_u16(DAT_0001d78c + 0x4, memory.read_u16(DAT_0001d7f0))
	memory.write_u16(DAT_0001d78c + 0x6, 0)
	memory.write_u16(DAT_0001d78c + 0x8, 0x1000)
	memory.write_u16(DAT_0001d78c + 0xa, 0)
	memory.write_u16(DAT_0001d78c + 0xc, C68kScript.u16(-memory.read_s16(DAT_0001d7f0)))
	memory.write_u16(DAT_0001d78c + 0xe, 0)
	memory.write_u16(DAT_0001d78c + 0x10, memory.read_u16(DAT_0001d7ee))
	return

## ~Rx from angle 4 (same matrix as basis 4).
func fill_attitude_rotation_basis_4_rx() -> void:
	assert(memory != null, "fill_attitude_rotation_basis_4_rx requires original global memory")
	memory.write_u16(DAT_0001d78c + 0x0, 0x1000)
	memory.write_u16(DAT_0001d78c + 0x2, 0)
	memory.write_u16(DAT_0001d78c + 0x4, 0)
	memory.write_u16(DAT_0001d78c + 0x6, 0)
	memory.write_u16(DAT_0001d78c + 0x8, memory.read_u16(DAT_0001d7ee))
	memory.write_u16(DAT_0001d78c + 0xa, C68kScript.u16(-memory.read_s16(DAT_0001d7f0)))
	memory.write_u16(DAT_0001d78c + 0xc, 0)
	memory.write_u16(DAT_0001d78c + 0xe, memory.read_u16(DAT_0001d7f0))
	memory.write_u16(DAT_0001d78c + 0x10, memory.read_u16(DAT_0001d7ee))
	return

## ~Rx (angle 5) and ~Ry (angle 6).
func fill_attitude_rotation_bases_5_6() -> void:
	assert(memory != null, "fill_attitude_rotation_bases_5_6 requires original global memory")
	memory.write_u16(DAT_0001d774 + 0x0, 0x1000)
	memory.write_u16(DAT_0001d774 + 0x2, 0)
	memory.write_u16(DAT_0001d774 + 0x4, 0)
	memory.write_u16(DAT_0001d774 + 0x6, 0)
	memory.write_u16(DAT_0001d774 + 0x8, memory.read_u16(DAT_0001d7ea))
	memory.write_u16(DAT_0001d774 + 0xa, C68kScript.u16(-memory.read_s16(DAT_0001d7ec)))
	memory.write_u16(DAT_0001d774 + 0xc, 0)
	memory.write_u16(DAT_0001d774 + 0xe, memory.read_u16(DAT_0001d7ec))
	memory.write_u16(DAT_0001d774 + 0x10, memory.read_u16(DAT_0001d7ea))
	memory.write_u16(DAT_0001d75c + 0x0, memory.read_u16(DAT_0001d7e6))
	memory.write_u16(DAT_0001d75c + 0x2, 0)
	memory.write_u16(DAT_0001d75c + 0x4, memory.read_u16(DAT_0001d7e8))
	memory.write_u16(DAT_0001d75c + 0x6, 0)
	memory.write_u16(DAT_0001d75c + 0x8, 0x1000)
	memory.write_u16(DAT_0001d75c + 0xa, 0)
	memory.write_u16(DAT_0001d75c + 0xc, C68kScript.u16(-memory.read_s16(DAT_0001d7e8)))
	memory.write_u16(DAT_0001d75c + 0xe, 0)
	memory.write_u16(DAT_0001d75c + 0x10, memory.read_u16(DAT_0001d7e6))
	return

## dst[3i+j] = (a[3i]*b[j] + a[3i+1]*b[3+j] + a[3i+2]*b[6+j]) asr 12: muls.w 16x16 -> 32,
## add.l, asr.l #12, move.w. Returns a0 = b + 6 (the C's b_next). dst must not alias a or b.
func matmul3x3_s16(a: int, b: int, dst: int) -> int:
	assert(memory != null, "matmul3x3_s16 requires original global memory")
	var row_off: int
	var j: int
	var b_col: int
	var b_next: int
	var out: int
	var i: int

	i = 0
	while true:
		j = 0
		row_off = i * 6
		b_col = b
		out = row_off + dst
		while true:
			b_next = b_col + 2
			memory.write_u16(out, C68kScript.u16(C68kScript.asr32(
					memory.read_s16(row_off + a + 4) * memory.read_s16(b + (j + 6) * 2) +
					memory.read_s16(row_off + a + 2) * memory.read_s16(b + (j + 3) * 2) +
					memory.read_s16(a + row_off) * memory.read_s16(b_col), 0xc)))
			j = j + 1
			b_col = b_next
			out = out + 2
			if not (j < 3):
				break
		i = i + 1
		if not (i < 3):
			break
	return b_next

## out = R4 * Rz, temp = out * Rx, out = temp * Ry. temp is the frame local at a6 - 0x12
## (link.w a6,#-0x14), i.e. a7 - 0x16 with a7 = this function's entry stack pointer.
func finalize_attitude_matrix_4ang(out: int) -> void:
	assert(memory != null, "finalize_attitude_matrix_4ang requires original global memory")
	assert(a7 != 0, "finalize_attitude_matrix_4ang needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	matmul3x3_s16(DAT_0001d78c, DAT_0001d7a4, out)
	matmul3x3_s16(out, DAT_0001d7d4, temp)
	matmul3x3_s16(temp, DAT_0001d7bc, out)
	return

## load_attitude_angle_sincos receives (angle1, angle2, angle3, angle4) = (param_2..4, param_1).
## finalize is entered with the stack 0x1c below this function's entry (link a6 = 4, five
## argument longs = 0x14, bsr return address = 4; the arguments are popped only at the end).
func build_attitude_matrix(angle4: int, angle1: int, angle2: int, angle3: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix needs a7 (finalize's frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, angle4)
	fill_attitude_rotation_bases()
	fill_attitude_rotation_basis_4()
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	finalize_attitude_matrix_4ang(out)
	a7 = entry_a7
	return

## temp = Ry * Rx, out = temp * Rz (0x2428).
func finalize_attitude_matrix_3ang_alt(out: int) -> void:
	assert(memory != null, "finalize_attitude_matrix_3ang_alt requires original global memory")
	assert(a7 != 0, "finalize_attitude_matrix_3ang_alt needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	fill_attitude_rotation_bases()
	matmul3x3_s16(DAT_0001d7bc, DAT_0001d7d4, temp)
	matmul3x3_s16(temp, DAT_0001d7a4, out)
	return

## Fourth angle 0 (clr.l); composer entered 0x1c below (link 4, four args + out, bsr) (0x2464).
func build_attitude_matrix_3ang_alt(angle1: int, angle2: int, angle3: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix_3ang_alt needs a7 (the composer frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, 0)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	finalize_attitude_matrix_3ang_alt(out)
	a7 = entry_a7
	return

## out = Ry * Rx, temp = out * Rz, out = temp * R4x (0x2488).
func compose_attitude_matrix_x_alt(out: int) -> void:
	assert(memory != null, "compose_attitude_matrix_x_alt requires original global memory")
	assert(a7 != 0, "compose_attitude_matrix_x_alt needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	fill_attitude_rotation_bases()
	fill_attitude_rotation_basis_4_rx()
	matmul3x3_s16(DAT_0001d7bc, DAT_0001d7d4, out)
	matmul3x3_s16(out, DAT_0001d7a4, temp)
	matmul3x3_s16(temp, DAT_0001d78c, out)
	return

## link.w a6,#-0x24 and no pop before unlk: composer entered 0x40 below (0x24d6).
func build_attitude_matrix_x_alt(angle1: int, angle2: int, angle3: int, angle4: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix_x_alt needs a7 (the composer frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, angle4)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x40
	compose_attitude_matrix_x_alt(out)
	a7 = entry_a7
	return

## Tag $2408 (move.l #imm), temp = Rz * Rx, out = temp * Ry (0x24f8).
func finalize_attitude_matrix_3ang(out: int) -> void:
	assert(memory != null, "finalize_attitude_matrix_3ang requires original global memory")
	assert(a7 != 0, "finalize_attitude_matrix_3ang needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	memory.write_u32(DAT_00020ce4, 0x2408)
	fill_attitude_rotation_bases()
	matmul3x3_s16(DAT_0001d7a4, DAT_0001d7d4, temp)
	matmul3x3_s16(temp, DAT_0001d7bc, out)
	return

## Fourth angle 0; composer entered 0x1c below (0x253e).
func build_attitude_matrix_3ang(angle1: int, angle2: int, angle3: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix_3ang needs a7 (the composer frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, 0)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	finalize_attitude_matrix_3ang(out)
	a7 = entry_a7
	return

## Tag $2468, out = R4x * Rz, temp = out * Rx, out = temp * Ry (0x25d6).
func compose_attitude_matrix_x(out: int) -> void:
	assert(memory != null, "compose_attitude_matrix_x requires original global memory")
	assert(a7 != 0, "compose_attitude_matrix_x needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	memory.write_u32(DAT_00020ce4, 0x2468)
	fill_attitude_rotation_bases()
	fill_attitude_rotation_basis_4_rx()
	matmul3x3_s16(DAT_0001d78c, DAT_0001d7a4, out)
	matmul3x3_s16(out, DAT_0001d7d4, temp)
	matmul3x3_s16(temp, DAT_0001d7bc, out)
	return

## Arguments (param_2..4, param_1) as build_attitude_matrix; composer entered 0x1c below (0x262e).
func build_attitude_matrix_x(angle4: int, angle1: int, angle2: int, angle3: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix_x needs a7 (the composer frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, angle4)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	compose_attitude_matrix_x(out)
	a7 = entry_a7
	return

## Tag $26e0, R5 * R6 * R4x * Rz * Rx * Ry, alternating out / temp (0x2654).
func compose_attitude_matrix_6ang(out: int) -> void:
	assert(memory != null, "compose_attitude_matrix_6ang requires original global memory")
	assert(a7 != 0, "compose_attitude_matrix_6ang needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	memory.write_u32(DAT_00020ce4, 0x26e0)
	fill_attitude_rotation_bases()
	fill_attitude_rotation_basis_4_rx()
	fill_attitude_rotation_bases_5_6()
	matmul3x3_s16(DAT_0001d774, DAT_0001d75c, out)
	matmul3x3_s16(out, DAT_0001d78c, temp)
	matmul3x3_s16(temp, DAT_0001d7a4, out)
	matmul3x3_s16(out, DAT_0001d7d4, temp)
	matmul3x3_s16(temp, DAT_0001d7bc, out)
	return

## Composer entered 0x24 below (link 4, four + two args, out, bsr) (0x26cc).
func build_attitude_matrix_6ang(angle1: int, angle2: int, angle3: int, angle4: int, angle5: int, angle6: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix_6ang needs a7 (the composer frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, angle4)
	load_attitude_angle_sincos_5_6(angle5, angle6)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x24
	compose_attitude_matrix_6ang(out)
	a7 = entry_a7
	return

## Ry * Rx * Rz * R4x * R6 * R5, alternating out / temp (0x2700).
func compose_attitude_matrix_6ang_alt(out: int) -> void:
	assert(memory != null, "compose_attitude_matrix_6ang_alt requires original global memory")
	assert(a7 != 0, "compose_attitude_matrix_6ang_alt needs a7 (its frame holds the temp matrix)")
	var temp: int = a7 - 0x16

	fill_attitude_rotation_bases()
	fill_attitude_rotation_basis_4_rx()
	fill_attitude_rotation_bases_5_6()
	matmul3x3_s16(DAT_0001d7bc, DAT_0001d7d4, out)
	matmul3x3_s16(out, DAT_0001d7a4, temp)
	matmul3x3_s16(temp, DAT_0001d78c, out)
	matmul3x3_s16(out, DAT_0001d75c, temp)
	matmul3x3_s16(temp, DAT_0001d774, out)
	return

## Composer entered 0x24 below (0x276e).
func build_attitude_matrix_6ang_alt(angle1: int, angle2: int, angle3: int, angle4: int, angle5: int, angle6: int, out: int) -> void:
	assert(a7 != 0, "build_attitude_matrix_6ang_alt needs a7 (the composer frame lies below it)")
	load_attitude_angle_sincos(angle1, angle2, angle3, angle4)
	load_attitude_angle_sincos_5_6(angle5, angle6)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x24
	compose_attitude_matrix_6ang_alt(out)
	a7 = entry_a7
	return

## out_i = (x * m[i] + y * m[3 + i] + z * m[6 + i] + 0x800) asr 12 per 12-byte record (words
## +2 / +6 / +0xa), stored as words. 32-bit count: dbra, then clr.w / subq.l / bcc.
func transform_vecs12_by_matrix3(count: int, src: int, dst: int, matrix: int) -> void:
	assert(memory != null, "transform_vecs12_by_matrix3 requires original global memory")
	var y: int
	var z: int
	var count_hi: int
	var x: int

	count = C68kScript.u32(count)
	while true:
		count_hi = C68kScript.u16(count >> 0x10)
		x = C68kScript.s16(count - 1)
		count = C68kScript.u32((count_hi << 0x10) | C68kScript.u16(x))
		if x == -1:
			count = C68kScript.u32(count_hi * 0x10000 - 1)
			if count_hi == 0:
				break
		x = memory.read_s16(src + 2)
		y = memory.read_s16(src + 6)
		z = memory.read_s16(src + 10)
		memory.write_u16(dst + 2, C68kScript.u16(C68kScript.asr32(z * memory.read_s16(matrix + 12) + y * memory.read_s16(matrix + 6) + x * memory.read_s16(matrix + 0) + 0x800, 0xc)))
		memory.write_u16(dst + 6, C68kScript.u16(C68kScript.asr32(z * memory.read_s16(matrix + 14) + y * memory.read_s16(matrix + 8) + x * memory.read_s16(matrix + 2) + 0x800, 0xc)))
		memory.write_u16(dst + 10, C68kScript.u16(C68kScript.asr32(z * memory.read_s16(matrix + 16) + y * memory.read_s16(matrix + 10) + x * memory.read_s16(matrix + 4) + 0x800, 0xc)))
		src = src + 0xc
		dst = dst + 0xc
	return

## Same rows stored as longs (move.l), dst += 12 per record.
func transform_vecs12_to_int3_by_matrix3(count: int, src: int, dst: int, matrix: int) -> void:
	assert(memory != null, "transform_vecs12_to_int3_by_matrix3 requires original global memory")
	var y: int
	var z: int
	var count_hi: int
	var x: int

	count = C68kScript.u32(count)
	while true:
		count_hi = C68kScript.u16(count >> 0x10)
		x = C68kScript.s16(count - 1)
		count = C68kScript.u32((count_hi << 0x10) | C68kScript.u16(x))
		if x == -1:
			count = C68kScript.u32(count_hi * 0x10000 - 1)
			if count_hi == 0:
				break
		x = memory.read_s16(src + 2)
		y = memory.read_s16(src + 6)
		z = memory.read_s16(src + 10)
		memory.write_u32(dst + 0, C68kScript.u32(C68kScript.asr32(z * memory.read_s16(matrix + 12) + y * memory.read_s16(matrix + 6) + x * memory.read_s16(matrix + 0) + 0x800, 0xc)))
		memory.write_u32(dst + 4, C68kScript.u32(C68kScript.asr32(z * memory.read_s16(matrix + 14) + y * memory.read_s16(matrix + 8) + x * memory.read_s16(matrix + 2) + 0x800, 0xc)))
		memory.write_u32(dst + 8, C68kScript.u32(C68kScript.asr32(z * memory.read_s16(matrix + 16) + y * memory.read_s16(matrix + 10) + x * memory.read_s16(matrix + 4) + 0x800, 0xc)))
		src = src + 0xc
		dst = dst + 0xc
	return

func find_contact_record(param_1: int, param_2: int) -> int:
	assert(memory != null, "find_contact_record requires original global memory")
	var piVar1: int
	var bVar3: int
	var uVar2: int
	var sVar4: int

	bVar3 = contact_pair_hash(C68kScript.u8(param_1), C68kScript.s8(param_2))
	uVar2 = bVar3
	sVar4 = 0x100
	while true:
		sVar4 = C68kScript.s16(sVar4 - 1)
		if sVar4 == -1:
			return 0
		piVar1 = memory.read_u32(DAT_0001bdbc + C68kScript.s16(uVar2) * 4)
		if piVar1 != 0 and param_1 == memory.read_u32(piVar1) and param_2 == memory.read_u32(piVar1 + 4):
			break
		uVar2 = C68kScript.u32((C68kScript.s16(uVar2) + 1) & 0xff)
	return piVar1

func reset_radar_tracks() -> void:
	assert(memory != null, "reset_radar_tracks requires original global memory")
	memory.write_u32(DAT_00026672, 0)
	memory.write_u32(DAT_00026676, 0)
	memory.write_u8(_DAT_0002666e, 1)
	return
