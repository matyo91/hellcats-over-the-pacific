class_name StrictPacificConflict
extends RefCounted
## Strict translations owned by the Pacific Conflict CODE overlay.
## The sole provenance and verification record lives in mappings/functions.json.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const DAT_0001ab6c: int = 0x1ab6c ## sin_table: 256 words (runtime address; file 0x1ab8c)
const DAT_0001ad6c: int = 0x1ad6c ## cos_table: 256 words (runtime address; file 0x1ad8c)
const DAT_0001b5a0: int = 0x1b5a0 ## host_world: pointer to the host A5 world
const DAT_0001b5a4: int = 0x1b5a4 ## object_pool: near-list object pointers
const DAT_0001b734: int = 0x1b734 ## object_count (long; its low word at 0x1b736 is the dbra count)
const DAT_0001b738: int = 0x1b738 ## player_object: pointer to the player controller (+0 object)
const DAT_0001b73e: int = 0x1b73e ## clip_y_max (word)
const DAT_0001b740: int = 0x1b740 ## clip_y_max_alt (word)
const DAT_0001b838: int = 0x1b838 ## frame_counter (long)
const DAT_0001b842: int = 0x1b842 ## snd_hit (word): one-frame player-hit sound flag
const DAT_0001b43c: int = 0x1b43c ## collision_pair_table: 10 x (type word, type word, handler long)
const DAT_0001b880: int = 0x1b880 ## player_shot_ctl (long)
const DAT_0001b88c: int = 0x1b88c ## child_window_hi (word)
const DAT_0001b88e: int = 0x1b88e ## child_window_lo (word)
const DAT_0001bc64: int = 0x1bc64 ## scatter_slots: 7 object pointers
const DAT_0001d6fc: int = 0x1d6fc ## scene_root (+0x30: child table, 0x18-byte records)
const DAT_00024cf0: int = 0x24cf0 ## retire_count (long)
const DAT_00026008: int = 0x26008 ## rng_cursor: pointer into the 55-long ring 0x2600c..0x260e7
const DAT_00026284: int = 0x26284 ## collision_pair_cursor (long)
const DAT_0002600c: int = 0x2600c ## rng_state: first ring long (the seed)
const DAT_0001bdb8: int = 0x1bdb8 ## visible_list_split (long; its low word at 0x1bdba)
const DAT_0001bdbc: int = 0x1bdbc
const DAT_00020aea: int = 0x20aea ## clip_y_min (word)
const DAT_00020aec: int = 0x20aec ## clip_x_max (word)
const DAT_00020aee: int = 0x20aee ## clip_x_min (word)
const DAT_0001c1d4: int = 0x1c1d4 ## visible_count (long; its low word at 0x1c1d6)
const DAT_0001c9dc: int = 0x1c9dc ## visible_list: object pointers
const DAT_0001d858: int = 0x1d858 ## view_mode (word)
const DAT_0001d744: int = 0x1d744 ## camera_m00: 3x3 s16 camera matrix
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
## Code addresses reached through pointers (jsr (an)) mapped to their ported Callables. Keys are
## RUNTIME addresses (file offset - 0x20): what the original pushes (pea x(pc) evaluates at
## runtime) or stores in its tables. A call to an address with no entry is an error: the
## original target is not ported yet.
var code_table: Dictionary = {}

func _init(param_memory = null) -> void:
	memory = param_memory
	## pea $aba(pc) in point_near_camera_or_type80_object: file 0xaba = runtime 0xa9a.
	code_table[0xa9a] = Callable(self, "nearest_type80_centroid_visitor")
	## pea $6ec(pc) in plot_mission_map_symbols: file 0x6ec = runtime 0x6cc.
	code_table[0x6cc] = Callable(self, "collect_map_features")
	## collision_pair_table handlers (file 0x1b45c): runtime 0x167d4 = file 0x167f4
	## bullet_hits_aircraft, runtime 0x14326 = file 0x14346, a lone rts (pair ignored).
	code_table[0x167d4] = func(a: int, b: int, _c: int) -> int: return bullet_hits_aircraft(a, b)


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

## For every visible object from visible_list_split to visible_count (word counts, 32-bit
## difference in a6, subq.w / cmpa.w #-1 on the address register): its +0x36 int3
## vertices at +0x4c, each shifted right by word +0x32 (asr.l, count mod 64) and cut to a
## word, are transformed in place by the camera matrix 0x1d744 into the 12-byte record
## words +2 / +6 / +0xa (muls.w sums + 0x800, asr.l #12).
func transform_listed_object_vecs12_by_1d744() -> void:
	assert(memory != null, "transform_listed_object_vecs12_by_1d744 requires original global memory")
	var obj: int
	var x: int
	var y: int
	var z: int
	var shift: int
	var verts_left: int
	var dst: int
	var src: int
	var next_slot: int
	var slot: int
	var objs_left: int

	objs_left = C68kScript.s32(memory.read_s16(DAT_0001c1d4 + 2) - memory.read_s16(DAT_0001bdb8 + 2))
	slot = C68kScript.u32(DAT_0001c9dc + C68kScript.lsl32(memory.read_u32(DAT_0001bdb8), 2))
	while true:
		objs_left = C68kScript.s32(objs_left - 1)
		if objs_left == -1:
			break
		next_slot = slot + 4
		obj = memory.read_u32(slot)
		dst = memory.read_u32(obj + 0x4c)
		verts_left = memory.read_s16(obj + 0x36)
		shift = memory.read_s16(obj + 0x32)
		src = dst
		while true:
			verts_left = C68kScript.s16(verts_left - 1)
			slot = next_slot
			if verts_left == -1:
				break
			x = C68kScript.s16(C68kScript.asr32(memory.read_s32(src), shift & 0x3f))
			y = C68kScript.s16(C68kScript.asr32(memory.read_s32(src + 4), shift & 0x3f))
			z = C68kScript.s16(C68kScript.asr32(memory.read_s32(src + 8), shift & 0x3f))
			memory.write_u16(dst + 2, C68kScript.u16(C68kScript.asr32(z * memory.read_s16(DAT_0001d744 + 12) + y * memory.read_s16(DAT_0001d744 + 6) + x * memory.read_s16(DAT_0001d744 + 0) + 0x800, 0xc)))
			memory.write_u16(dst + 6, C68kScript.u16(C68kScript.asr32(z * memory.read_s16(DAT_0001d744 + 14) + y * memory.read_s16(DAT_0001d744 + 8) + x * memory.read_s16(DAT_0001d744 + 2) + 0x800, 0xc)))
			memory.write_u16(dst + 10, C68kScript.u16(C68kScript.asr32(z * memory.read_s16(DAT_0001d744 + 16) + y * memory.read_s16(DAT_0001d744 + 10) + x * memory.read_s16(DAT_0001d744 + 4) + 0x800, 0xc)))
			src = src + 0xc
			dst = dst + 0xc
	return

## out_j = bits 12..43 of x * m[0][j] + y * m[1][j] + z * m[2][j] (muls.l 32x32 -> 64,
## add.l / addx.l), i.e. the 64-bit sum asr 12 cut to 32 bits; no rounding. The nine words
## are sign-extended into the frame (a6 - 0x24) first; that copy is kept in a local here
## because nothing outside the function reads it. Unsigned count (subq.l / bcc). Returns
## d0: the last stored component, or matrix + 18 when count is 0.
func transform_int3_vecs_by_matrix3(count: int, src: int, dst: int, matrix: int) -> int:
	assert(memory != null, "transform_int3_vecs_by_matrix3 requires original global memory")
	var m: Array[int] = []
	var left: int
	var x: int
	var y: int
	var z: int
	var result: int = 0

	for k in range(9):
		m.append(memory.read_s16(matrix + 2 * k))
	result = matrix + 0x12 ## the copy loop leaves d0 = a0 = matrix + 18 (returned when count is 0)
	left = C68kScript.u32(count)
	while left != 0:
		left = left - 1
		x = memory.read_s32(src)
		y = memory.read_s32(src + 4)
		z = memory.read_s32(src + 8)
		memory.write_u32(dst, C68kScript.u32((m[6] * z + m[3] * y + m[0] * x) >> 0xc))
		memory.write_u32(dst + 4, C68kScript.u32((m[7] * z + m[4] * y + m[1] * x) >> 0xc))
		result = C68kScript.s32((m[8] * z + m[5] * y + m[2] * x) >> 0xc)
		memory.write_u32(dst + 8, C68kScript.u32(result))
		src = src + 0xc
		dst = dst + 0xc
	return result

## Adds (dx, dy, dz) to count int3 vectors (add.l, stride 12; src and dst may alias). 32-bit
## count: dbra, then clr.w / subq.l / bcc. No frame (movem only).
func translate_int3_vecs(count: int, src: int, dst: int, dx: int, dy: int, dz: int) -> void:
	assert(memory != null, "translate_int3_vecs requires original global memory")
	var count_hi: int
	var count_lo: int

	count = C68kScript.u32(count)
	while true:
		count_hi = C68kScript.u16(count >> 0x10)
		count_lo = C68kScript.s16(count - 1)
		count = C68kScript.u32((count_hi << 0x10) | C68kScript.u16(count_lo))
		if count_lo == -1:
			count = C68kScript.u32(count_hi * 0x10000 - 1)
			if count_hi == 0:
				break
		memory.write_u32(dst, C68kScript.u32(memory.read_s32(src) + dx))
		memory.write_u32(dst + 4, C68kScript.u32(memory.read_s32(src + 4) + dy))
		memory.write_u32(dst + 8, C68kScript.u32(memory.read_s32(src + 8) + dz))
		dst = dst + 0xc
		src = src + 0xc
	return

## Walks the parent chain (+0x24) of obj; each parent's 0x18-byte slot (parent +0x30 +
## 0x18 * child byte +2) rotates (build_attitude_matrix_3ang when an angle word +2 / +4 / +6
## is non-zero) and translates (+8 / +0xc / +0x10). Point path (src or dst 0): the frame copy
## of obj +0x18..+0x20; mesh path: vert_count vertices src -> dst, offsets << word +0x34.
## The copy is committed only when src and dst are both 0. Frame (link.w a6,#-0x20): pos at
## a6 - 0x1e (a7 - 0x22), matrix at a6 - 0x12 (a7 - 0x16); build_attitude_matrix_3ang is
## entered 0x5c below (link 4 + 0x20, movem of nine registers, four arguments, bsr).
func apply_template_chain_xform(obj: int, vert_count: int, src: int, dst: int) -> void:
	assert(memory != null, "apply_template_chain_xform requires original global memory")
	assert(a7 != 0, "apply_template_chain_xform needs a7 (its frame holds pos and the matrix)")
	var slot_index: int
	var rotates: bool
	var shift: int
	var slot: int
	var parent: int
	var pos_x: int = a7 - 0x22
	var matrix: int = a7 - 0x16
	var entry_a7: int = a7

	memory.write_u32(pos_x, memory.read_u32(obj + 0x18))
	memory.write_u32(pos_x + 4, memory.read_u32(obj + 0x1c))
	memory.write_u32(pos_x + 8, memory.read_u32(obj + 0x20))
	parent = memory.read_u32(obj + 0x24)
	slot_index = memory.read_u8(obj + 2)
	if parent != 0:
		while true:
			slot = C68kScript.u32(memory.read_u32(parent + 0x30) + slot_index * 0x18)
			rotates = false
			if memory.read_s16(slot + 2) != 0 or memory.read_s16(slot + 4) != 0 or memory.read_s16(slot + 6) != 0:
				rotates = true
			if rotates:
				a7 = entry_a7 - 0x5c
				build_attitude_matrix_3ang(memory.read_s16(slot + 2), memory.read_s16(slot + 4), memory.read_s16(slot + 6), matrix)
				a7 = entry_a7
			if src == 0 or dst == 0:
				if rotates:
					transform_int3_vecs_by_matrix3(1, pos_x, pos_x, matrix)
				translate_int3_vecs(1, pos_x, pos_x, memory.read_s32(slot + 8), memory.read_s32(slot + 0xc), memory.read_s32(slot + 0x10))
			else:
				if rotates:
					transform_int3_vecs_by_matrix3(vert_count, src, dst, matrix)
					src = dst
				shift = memory.read_s16(obj + 0x34)
				translate_int3_vecs(vert_count, src, dst,
						C68kScript.s32(C68kScript.lsl32(memory.read_u32(slot + 8), shift & 0x3f)),
						C68kScript.s32(C68kScript.lsl32(memory.read_u32(slot + 0xc), shift & 0x3f)),
						C68kScript.s32(C68kScript.lsl32(memory.read_u32(slot + 0x10), shift & 0x3f)))
				src = dst
			slot_index = memory.read_u8(parent + 2)
			parent = memory.read_u32(parent + 0x24)
			if parent == 0:
				break
	if src == 0 and dst == 0:
		memory.write_u32(obj + 0x18, memory.read_u32(pos_x))
		memory.write_u32(obj + 0x1c, memory.read_u32(pos_x + 4))
		memory.write_u32(obj + 0x20, memory.read_u32(pos_x + 8))
	return

## As apply_template_chain_xform, but every slot rotates and the mesh offsets are not
## shifted. Frame as there; movem saves eight registers, so build_attitude_matrix_3ang is
## entered 0x58 below.
func apply_template_chain_xform_always(obj: int, vert_count: int, src: int, dst: int) -> void:
	assert(memory != null, "apply_template_chain_xform_always requires original global memory")
	assert(a7 != 0, "apply_template_chain_xform_always needs a7 (its frame holds pos and the matrix)")
	var slot_index: int
	var slot: int
	var parent: int
	var count: int
	var vecs: int
	var off_y: int
	var off_z: int
	var pos_x: int = a7 - 0x22
	var matrix: int = a7 - 0x16
	var entry_a7: int = a7

	memory.write_u32(pos_x, memory.read_u32(obj + 0x18))
	memory.write_u32(pos_x + 4, memory.read_u32(obj + 0x1c))
	memory.write_u32(pos_x + 8, memory.read_u32(obj + 0x20))
	parent = memory.read_u32(obj + 0x24)
	slot_index = memory.read_u8(obj + 2)
	if parent != 0:
		while true:
			slot = C68kScript.u32(memory.read_u32(parent + 0x30) + slot_index * 0x18)
			a7 = entry_a7 - 0x58
			build_attitude_matrix_3ang(memory.read_s16(slot + 2), memory.read_s16(slot + 4), memory.read_s16(slot + 6), matrix)
			a7 = entry_a7
			if src == 0 or dst == 0:
				transform_int3_vecs_by_matrix3(1, pos_x, pos_x, matrix)
				off_z = memory.read_s32(slot + 0x10)
				off_y = memory.read_s32(slot + 0xc)
				slot = memory.read_s32(slot + 8)
				count = 1
				vecs = pos_x
			else:
				transform_int3_vecs_by_matrix3(vert_count, src, dst, matrix)
				off_z = memory.read_s32(slot + 0x10)
				off_y = memory.read_s32(slot + 0xc)
				slot = memory.read_s32(slot + 8)
				src = dst
				count = vert_count
				vecs = dst
			translate_int3_vecs(count, vecs, vecs, slot, off_y, off_z)
			slot_index = memory.read_u8(parent + 2)
			parent = memory.read_u32(parent + 0x24)
			if parent == 0:
				break
	if src == 0 and dst == 0:
		memory.write_u32(obj + 0x18, memory.read_u32(pos_x))
		memory.write_u32(obj + 0x1c, memory.read_u32(pos_x + 4))
		memory.write_u32(obj + 0x20, memory.read_u32(pos_x + 8))
	return

## Multiplies count int3 vectors component-wise (muls.l 32 x 32 -> low 32 bits, stride 12;
## src and dst may alias). 32-bit count: dbra, then clr.w / subq.l / bcc.
func scale_int3_vecs(count: int, src: int, dst: int, sx: int, sy: int, sz: int) -> void:
	assert(memory != null, "scale_int3_vecs requires original global memory")
	var count_hi: int
	var count_lo: int

	count = C68kScript.u32(count)
	while true:
		count_hi = C68kScript.u16(count >> 0x10)
		count_lo = C68kScript.s16(count - 1)
		count = C68kScript.u32((count_hi << 0x10) | C68kScript.u16(count_lo))
		if count_lo == -1:
			count = C68kScript.u32(count_hi * 0x10000 - 1)
			if count_hi == 0:
				break
		memory.write_u32(dst, C68kScript.u32(memory.read_s32(src) * C68kScript.s32(sx)))
		memory.write_u32(dst + 4, C68kScript.u32(memory.read_s32(src + 4) * C68kScript.s32(sy)))
		memory.write_u32(dst + 8, C68kScript.u32(memory.read_s32(src + 8) * C68kScript.s32(sz)))
		dst = dst + 0xc
		src = src + 0xc
	return

## Pops node_count nodes (dbra on the word) from the node-pointer stack below path_top;
## each rotates (build_attitude_matrix_3ang of node +2 / +4 / +6) and translates (+8 / +0xc /
## +0x10) the running position, which starts at the longs object +2 / +6 / +0xa. With a
## vertex buffer, the sext word +0x1a vertices (object +0x22, then the buffer in place) are
## rotated into the buffer and translated by the offsets << word +0x18. Frame (link.w
## a6,#-0x24): matrix at a6 - 0x1e (a7 - 0x22), position at a6 - 0xc (a7 - 0x10); the path
## cursor at a6 - 0x22 is kept in a local (nothing else reads it). build_attitude_matrix_3ang
## is entered 0x60 below (link 4 + 0x24, nine saved registers, four arguments, bsr.l).
func transform_through_node_chain(path_top: int, node_count: int, object: int, out_x: int, out_y: int, out_z: int, vertex_out: int) -> void:
	assert(memory != null, "transform_through_node_chain requires original global memory")
	assert(a7 != 0, "transform_through_node_chain needs a7 (its frame holds the matrix and position)")
	var node: int
	var shift: int
	var src: int
	var path: int
	var matrix: int = a7 - 0x22
	var pos_x: int = a7 - 0x10
	var entry_a7: int = a7

	path = path_top
	memory.write_u32(pos_x, memory.read_u32(object + 2))
	memory.write_u32(pos_x + 4, memory.read_u32(object + 6))
	memory.write_u32(pos_x + 8, memory.read_u32(object + 10))
	src = object + 0x22
	node_count = C68kScript.s16(node_count)
	while true:
		node_count = C68kScript.s16(node_count - 1)
		if node_count == -1:
			break
		path = path - 4
		node = memory.read_u32(path)
		a7 = entry_a7 - 0x60
		build_attitude_matrix_3ang(memory.read_s16(node + 2), memory.read_s16(node + 4), memory.read_s16(node + 6), matrix)
		a7 = entry_a7
		transform_int3_vecs_by_matrix3(1, pos_x, pos_x, matrix)
		translate_int3_vecs(1, pos_x, pos_x, memory.read_s32(node + 8), memory.read_s32(node + 0xc), memory.read_s32(node + 0x10))
		if vertex_out != 0:
			transform_int3_vecs_by_matrix3(memory.read_s16(object + 0x1a), src, vertex_out, matrix)
			shift = memory.read_s16(object + 0x18)
			translate_int3_vecs(memory.read_s16(object + 0x1a), vertex_out, vertex_out,
					C68kScript.s32(C68kScript.lsl32(memory.read_u32(node + 8), shift & 0x3f)),
					C68kScript.s32(C68kScript.lsl32(memory.read_u32(node + 0xc), shift & 0x3f)),
					C68kScript.s32(C68kScript.lsl32(memory.read_u32(node + 0x10), shift & 0x3f)))
			src = vertex_out
	memory.write_u32(out_x, memory.read_u32(pos_x))
	memory.write_u32(out_y, memory.read_u32(pos_x + 4))
	memory.write_u32(out_z, memory.read_u32(pos_x + 8))
	return

## Runtime addresses of a lone rts: a jsr there returns with D0 unchanged.
const RTS_ONLY := [0x14326] ## file 0x14346, just before dispatch_collision

## Direct bsr / jsr to a function that is not ported yet: looked up in code_table under its
## runtime address (file - 0x20), so a test or adapter must supply it explicitly; the
## assertion keeps an unported callee from being skipped silently.
func _bsr_unported(file_address: int, args: Array):
	var address: int = file_address - 0x20
	assert(code_table.has(address), "bsr to unported function at file 0x%x" % file_address)
	return code_table[address].callv(args)

## d0 is the caller's D0 at the jsr, returned as-is when the target is a lone rts.
func _jsr(address: int, args: Array, d0: int = 0):
	if RTS_ONLY.has(address):
		return d0
	assert(code_table.has(address), "jsr to unported code address 0x%x" % address)
	return code_table[address].callv(args)

## For each of the sext word group +0x18 child records (group + 0x1a + 24 i): the record is
## stored at *path; child = long (host_world +0x8c) + record +0x14. A child of type byte 3
## recurses (path + 4, depth + 1); otherwise visitor(ctx, child, face, path + 4, depth + 1)
## runs for each of the sext word child +0x1e faces, the first at child + 0x22 + 12 * word
## +0x1a + 12 * word +0x1e, the next at face + 0xe + 2 * byte face +8. Signed word compares.
## No frame (movem of ten registers): both the recursion and the visitor are entered 0x40
## below this function's entry (0x28 saved, five arguments, return address).
func traverse_scene_tree(visitor: int, ctx: int, path: int, depth: int, group: int) -> void:
	assert(memory != null, "traverse_scene_tree requires original global memory")
	var record: int
	var face_index: int
	var child_index: int
	var child: int
	var face: int
	var entry_a7: int = a7

	child_index = 0
	if 0 < memory.read_s16(group + 0x18):
		while true:
			record = group + 0x1a + child_index * 0x18
			memory.write_u32(path, record)
			child = C68kScript.u32(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c) + memory.read_u32(record + 0x14))
			if memory.read_u8(child) == 3:
				a7 = entry_a7 - 0x40
				traverse_scene_tree(visitor, ctx, path + 4, C68kScript.s32(depth + 1), child)
				a7 = entry_a7
			else:
				face = child + memory.read_s16(child + 0x1e) * 0xc + memory.read_s16(child + 0x1a) * 0xc + 0x22
				face_index = 0
				if 0 < memory.read_s16(child + 0x1e):
					while true:
						a7 = entry_a7 - 0x40
						_jsr(visitor, [ctx, child, face, path + 4, C68kScript.s32(depth + 1)])
						a7 = entry_a7
						face = face + memory.read_u8(face + 8) * 2 + 0xe
						face_index = C68kScript.s16(face_index + 1)
						if not (face_index < memory.read_s16(child + 0x1e)):
							break
			child_index = C68kScript.s16(child_index + 1)
			if not (child_index < memory.read_s16(group + 0x18)):
				break
	return

## traverse_scene_tree(visitor, ctx, path stack, 0, root) with root = long (host_world +0x8c)
## + long ((host_world +0x8c) + 24 * sext word host_world +0x90 + 0x8e). Frame link.w
## a6,#-0x6b8: the ten-slot path stack is at a6 - 0x28 (a7 - 0x2c); traverse is entered
## 0x6d8 below (link 4 + 0x6b8, saved a2, five arguments, bsr).
func for_each_mission_scene_object(visitor: int, ctx: int) -> void:
	assert(memory != null, "for_each_mission_scene_object requires original global memory")
	assert(a7 != 0, "for_each_mission_scene_object needs a7 (its frame holds the path stack)")
	var path_stack: int = a7 - 0x2c
	var world: int = memory.read_u32(DAT_0001b5a0)
	var base: int = memory.read_u32(world + 0x8c)
	var entry_a7: int = a7

	a7 = entry_a7 - 0x6d8
	traverse_scene_tree(visitor, ctx, path_stack, 0,
			C68kScript.u32(base + memory.read_u32(base + memory.read_s16(world + 0x90) * 0x18 + 0x8e)))
	a7 = entry_a7
	return

## Scene visitor: for a face whose type nibble (byte +9 & 0xf0) is 0x80, places the node's
## vertices through the path (transform_through_node_chain into the frame buffer), averages
## the face's vertices (word indices from +0xe, count byte +8; each component asr.l by word
## node +0x18), adds 100 to y (divs.l truncating; a zero count would trap) and stores the
## centroid in best[0..2] when its camera metric is strictly lower. Frame (link.w
## a6,#-0x6a8): vertex buffer a6 - 0x690, sums a6 - 0x69c / - 0x698 / - 0x694, origin outs
## a6 - 0x6a0 / - 0x6a4 / - 0x6a8; transform_through_node_chain is entered 0x6e4 below.
## compute_camera_abs_metric is reached through lea $3be0 (runtime address of 0x3c00).
func nearest_type80_centroid_visitor(best: int, node: int, face: int, path: int, depth: int) -> void:
	assert(memory != null, "nearest_type80_centroid_visitor requires original global memory")
	assert(a7 != 0, "nearest_type80_centroid_visitor needs a7 (its frame holds the vertex buffer)")
	var a6: int = a7 - 4
	var verts: int = a6 - 0x690
	var sum_x: int = a6 - 0x69c
	var cand_metric: int
	var best_metric: int
	var i: int
	var count: int
	var shift: int
	var entry_a7: int = a7

	if (memory.read_u8(face + 9) & 0xf0) != 0x80:
		return
	a7 = entry_a7 - 0x6e4
	transform_through_node_chain(path, C68kScript.s16(depth), node, a6 - 0x6a0, a6 - 0x6a4, a6 - 0x6a8, verts)
	a7 = entry_a7
	memory.write_u32(sum_x + 8, 0)
	memory.write_u32(sum_x + 4, 0)
	memory.write_u32(sum_x, 0)
	i = 0
	while i < memory.read_u8(face + 8):
		var vert: int = verts + memory.read_s16(face + 0xe + i * 2) * 0xc
		shift = memory.read_s16(node + 0x18) & 0x3f
		memory.write_u32(sum_x, C68kScript.u32(memory.read_s32(sum_x) + C68kScript.asr32(memory.read_u32(vert), shift)))
		memory.write_u32(sum_x + 4, C68kScript.u32(memory.read_s32(sum_x + 4) + C68kScript.asr32(memory.read_u32(vert + 4), shift)))
		memory.write_u32(sum_x + 8, C68kScript.u32(memory.read_s32(sum_x + 8) + C68kScript.asr32(memory.read_u32(vert + 8), shift)))
		i = C68kScript.s16(i + 1)
	count = memory.read_u8(face + 8)
	memory.write_u32(sum_x, C68kScript.u32(C68kScript.divs_trunc(memory.read_s32(sum_x), count)))
	memory.write_u32(sum_x + 4, C68kScript.u32(C68kScript.divs_trunc(memory.read_s32(sum_x + 4), count) + 100))
	memory.write_u32(sum_x + 8, C68kScript.u32(C68kScript.divs_trunc(memory.read_s32(sum_x + 8), count)))
	cand_metric = compute_camera_abs_metric(memory.read_s32(sum_x), memory.read_s32(sum_x + 4), memory.read_s32(sum_x + 8))
	best_metric = compute_camera_abs_metric(memory.read_s32(best), memory.read_s32(best + 4), memory.read_s32(best + 8))
	if cand_metric < best_metric:
		memory.write_u32(best, memory.read_u32(sum_x))
		memory.write_u32(best + 4, memory.read_u32(sum_x + 4))
		memory.write_u32(best + 8, memory.read_u32(sum_x + 8))
	return

## 1 when the point's camera metric is below 0x33900; otherwise point x = 1000000000, the
## mission scene is searched with nearest_type80_centroid_visitor (runtime 0xa9a) and 1 is
## returned when a centroid was found whose metric is below 0x40741, else 0. No frame
## (saved a2): for_each_mission_scene_object is entered 0x10 below.
func point_near_camera_or_type80_object(point: int) -> int:
	assert(memory != null, "point_near_camera_or_type80_object requires original global memory")
	var metric: int
	var entry_a7: int = a7

	metric = compute_camera_abs_metric(memory.read_s32(point), memory.read_s32(point + 4), memory.read_s32(point + 8))
	if metric < 0x33900:
		return 1
	memory.write_u32(point, 1000000000)
	a7 = entry_a7 - 0x10
	for_each_mission_scene_object(0xa9a, point)
	a7 = entry_a7
	if memory.read_s32(point) != 1000000000:
		metric = compute_camera_abs_metric(memory.read_s32(point), memory.read_s32(point + 4), memory.read_s32(point + 8))
		if metric < 0x40741:
			return 1
	return 0

## Sutherland-Hodgman pass over n (x, y) long pairs against x >= sext word 0x00020aee
## (0xb190). The previous point starts at the last one; a crossing emits the boundary point
## (32-bit differences, muls.l 32 x 32 -> 64, divs.l 64 / 32), entering also emits the
## current point. Unsigned long count (subq.l / bne). Returns the output count (bytes asr 3).
func clip_polygon_x_min(src: int, n: int, out: int) -> int:
	assert(memory != null, "clip_polygon_x_min requires original global memory")
	var dst: int = out
	var prev: int
	var lim: int

	n = C68kScript.u32(n)
	if n != 0:
		prev = C68kScript.u32(src + n * 8 - 8)
		while true:
			lim = memory.read_s16(DAT_00020aee)
			if memory.read_s32(src + 0) < lim:
				if not (memory.read_s32(prev + 0) < lim):
					memory.write_u32(dst, C68kScript.u32(lim))
					memory.write_u32(dst + 4, C68kScript.u32(memory.read_s32(src + 4) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(prev + 4) - memory.read_s32(src + 4)) * C68kScript.s32(lim - memory.read_s32(src + 0)), C68kScript.s32(memory.read_s32(prev + 0) - memory.read_s32(src + 0)))))
					dst = dst + 8
			else:
				if memory.read_s32(prev + 0) < lim:
					memory.write_u32(dst, C68kScript.u32(lim))
					memory.write_u32(dst + 4, C68kScript.u32(memory.read_s32(prev + 4) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(src + 4) - memory.read_s32(prev + 4)) * C68kScript.s32(lim - memory.read_s32(prev + 0)), C68kScript.s32(memory.read_s32(src + 0) - memory.read_s32(prev + 0)))))
					memory.write_u32(dst + 8, memory.read_u32(src))
					memory.write_u32(dst + 12, memory.read_u32(src + 4))
					dst = dst + 16
				else:
					memory.write_u32(dst, memory.read_u32(src))
					memory.write_u32(dst + 4, memory.read_u32(src + 4))
					dst = dst + 8
			prev = src
			src = src + 8
			n = n - 1
			if n == 0:
				break
	return C68kScript.asr32(dst - out, 3)

## Sutherland-Hodgman pass over n (x, y) long pairs against x <= sext word 0x00020aec
## (0xb242). The previous point starts at the last one; a crossing emits the boundary point
## (32-bit differences, muls.l 32 x 32 -> 64, divs.l 64 / 32), entering also emits the
## current point. Unsigned long count (subq.l / bne). Returns the output count (bytes asr 3).
func clip_polygon_x_max(src: int, n: int, out: int) -> int:
	assert(memory != null, "clip_polygon_x_max requires original global memory")
	var dst: int = out
	var prev: int
	var lim: int

	n = C68kScript.u32(n)
	if n != 0:
		prev = C68kScript.u32(src + n * 8 - 8)
		while true:
			lim = memory.read_s16(DAT_00020aec)
			if lim < memory.read_s32(src + 0):
				if not (lim < memory.read_s32(prev + 0)):
					memory.write_u32(dst, C68kScript.u32(lim))
					memory.write_u32(dst + 4, C68kScript.u32(memory.read_s32(src + 4) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(prev + 4) - memory.read_s32(src + 4)) * C68kScript.s32(lim - memory.read_s32(src + 0)), C68kScript.s32(memory.read_s32(prev + 0) - memory.read_s32(src + 0)))))
					dst = dst + 8
			else:
				if lim < memory.read_s32(prev + 0):
					memory.write_u32(dst, C68kScript.u32(lim))
					memory.write_u32(dst + 4, C68kScript.u32(memory.read_s32(prev + 4) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(src + 4) - memory.read_s32(prev + 4)) * C68kScript.s32(lim - memory.read_s32(prev + 0)), C68kScript.s32(memory.read_s32(src + 0) - memory.read_s32(prev + 0)))))
					memory.write_u32(dst + 8, memory.read_u32(src))
					memory.write_u32(dst + 12, memory.read_u32(src + 4))
					dst = dst + 16
				else:
					memory.write_u32(dst, memory.read_u32(src))
					memory.write_u32(dst + 4, memory.read_u32(src + 4))
					dst = dst + 8
			prev = src
			src = src + 8
			n = n - 1
			if n == 0:
				break
	return C68kScript.asr32(dst - out, 3)

## Sutherland-Hodgman pass over n (x, y) long pairs against y >= sext word 0x00020aea
## (0xb2f4). The previous point starts at the last one; a crossing emits the boundary point
## (32-bit differences, muls.l 32 x 32 -> 64, divs.l 64 / 32), entering also emits the
## current point. Unsigned long count (subq.l / bne). Returns the output count (bytes asr 3).
func clip_polygon_y_min(src: int, n: int, out: int) -> int:
	assert(memory != null, "clip_polygon_y_min requires original global memory")
	var dst: int = out
	var prev: int
	var lim: int

	n = C68kScript.u32(n)
	if n != 0:
		prev = C68kScript.u32(src + n * 8 - 8)
		while true:
			lim = memory.read_s16(DAT_00020aea)
			if memory.read_s32(src + 4) < lim:
				if not (memory.read_s32(prev + 4) < lim):
					memory.write_u32(dst, C68kScript.u32(memory.read_s32(src + 0) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(prev + 0) - memory.read_s32(src + 0)) * C68kScript.s32(lim - memory.read_s32(src + 4)), C68kScript.s32(memory.read_s32(prev + 4) - memory.read_s32(src + 4)))))
					memory.write_u32(dst + 4, C68kScript.u32(lim))
					dst = dst + 8
			else:
				if memory.read_s32(prev + 4) < lim:
					memory.write_u32(dst, C68kScript.u32(memory.read_s32(prev + 0) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(src + 0) - memory.read_s32(prev + 0)) * C68kScript.s32(lim - memory.read_s32(prev + 4)), C68kScript.s32(memory.read_s32(src + 4) - memory.read_s32(prev + 4)))))
					memory.write_u32(dst + 4, C68kScript.u32(lim))
					memory.write_u32(dst + 8, memory.read_u32(src))
					memory.write_u32(dst + 12, memory.read_u32(src + 4))
					dst = dst + 16
				else:
					memory.write_u32(dst, memory.read_u32(src))
					memory.write_u32(dst + 4, memory.read_u32(src + 4))
					dst = dst + 8
			prev = src
			src = src + 8
			n = n - 1
			if n == 0:
				break
	return C68kScript.asr32(dst - out, 3)

## Sutherland-Hodgman pass over n (x, y) long pairs against y <= sext word 0x0001b73e
## (0xb3aa). The previous point starts at the last one; a crossing emits the boundary point
## (32-bit differences, muls.l 32 x 32 -> 64, divs.l 64 / 32), entering also emits the
## current point. Unsigned long count (subq.l / bne). Returns the output count (bytes asr 3).
func clip_polygon_y_max(src: int, n: int, out: int) -> int:
	assert(memory != null, "clip_polygon_y_max requires original global memory")
	var dst: int = out
	var prev: int
	var lim: int

	n = C68kScript.u32(n)
	if n != 0:
		prev = C68kScript.u32(src + n * 8 - 8)
		while true:
			lim = memory.read_s16(DAT_0001b73e)
			if lim < memory.read_s32(src + 4):
				if not (lim < memory.read_s32(prev + 4)):
					memory.write_u32(dst, C68kScript.u32(memory.read_s32(src + 0) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(prev + 0) - memory.read_s32(src + 0)) * C68kScript.s32(lim - memory.read_s32(src + 4)), C68kScript.s32(memory.read_s32(prev + 4) - memory.read_s32(src + 4)))))
					memory.write_u32(dst + 4, C68kScript.u32(lim))
					dst = dst + 8
			else:
				if lim < memory.read_s32(prev + 4):
					memory.write_u32(dst, C68kScript.u32(memory.read_s32(prev + 0) + C68kScript.divs_l_64_32(C68kScript.s32(memory.read_s32(src + 0) - memory.read_s32(prev + 0)) * C68kScript.s32(lim - memory.read_s32(prev + 4)), C68kScript.s32(memory.read_s32(src + 4) - memory.read_s32(prev + 4)))))
					memory.write_u32(dst + 4, C68kScript.u32(lim))
					memory.write_u32(dst + 8, memory.read_u32(src))
					memory.write_u32(dst + 12, memory.read_u32(src + 4))
					dst = dst + 16
				else:
					memory.write_u32(dst, memory.read_u32(src))
					memory.write_u32(dst + 4, memory.read_u32(src + 4))
					dst = dst + 8
			prev = src
			src = src + 8
			n = n - 1
			if n == 0:
				break
	return C68kScript.asr32(dst - out, 3)

## 68020 divs.l <ea>,Dq (32 / 32 -> 32 quotient): truncating; INT_MIN / -1 overflows and
## leaves Dq unchanged; division by zero traps.
static func _divs_l_32(dividend: int, divisor: int) -> int:
	assert(divisor != 0, "68020 divs.l by zero traps")
	if C68kScript.s32(dividend) == -0x80000000 and C68kScript.s32(divisor) == -1:
		return C68kScript.s32(dividend)
	return C68kScript.divs_trunc(C68kScript.s32(dividend), C68kScript.s32(divisor))

## Map visitor (plot_mission_map_symbols through for_each_mission_scene_object).
## Land nodes (byte +0x16 bit 4, word +0x16 & 0x240 clear): vertices through the node chain,
## made player-relative (-player x / z), x and z divided by plot_ctx[0], the face outline
## (count byte +8, word indices from +0xe) clipped x-min, x-max, y-min, then y-max with
## clip_y_max temporarily replaced by the word at 0x1b740, and handed to the host hook
## host_world +0x292 (outline, count, face long +0). Faces of type nibble 0x70 append
## (x, vertex[word +0xe].y, z) at ctx + 4 + 12 * word ctx +0xb58; node kinds 0x12 / 0x13
## append the long node +0xe at ctx + 0x9c8 + 4 k, the kind byte at ctx + 0x964 + k and
## (x, y, z) at ctx + 0x4b4 + 12 k (k = word ctx +0xb5a). Frame (link.w a6,#-0xf60):
## vertices a6 - 0x690, outline a6 - 0xaf0, clip buffer a6 - 0xf50, origin x / y / z at
## a6 - 0xf54 / - 0xf58 / - 0xf5c. transform_through_node_chain is entered 0xfa4 below, the
## hook 0xf94 below.
func collect_map_features(plot_ctx: int, node: int, face: int, path: int, depth: int) -> void:
	assert(memory != null, "collect_map_features requires original global memory")
	assert(a7 != 0, "collect_map_features needs a7 (its frame holds the vertex and outline buffers)")
	var entry_a7: int = a7
	var a6: int = a7 - 4
	var verts: int = a6 - 0x690
	var outline: int = a6 - 0xaf0
	var clip_buf: int = a6 - 0xf50
	var pos_x: int = a6 - 0xf54
	var pos_y: int = a6 - 0xf58
	var pos_z: int = a6 - 0xf5c
	var player: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	var entry: int
	var i: int
	var work: int
	var saved_y_max: int

	if (memory.read_u8(node + 0x16) & 0x10) == 0 or (memory.read_u16(node + 0x16) & 0x240) != 0:
		if (memory.read_u8(face + 9) & 0xf0) == 0x70:
			a7 = entry_a7 - 0xfa4
			transform_through_node_chain(path, C68kScript.s16(depth), node, pos_x, pos_y, pos_z, verts)
			a7 = entry_a7
			entry = plot_ctx + memory.read_s16(plot_ctx + 0xb58) * 0xc + 4
			memory.write_u16(plot_ctx + 0xb58, C68kScript.u16(memory.read_u16(plot_ctx + 0xb58) + 1))
			memory.write_u32(entry, memory.read_u32(pos_x))
			memory.write_u32(entry + 4, memory.read_u32(verts + memory.read_s16(face + 0xe) * 0xc + 4))
		else:
			if memory.read_u8(node + 1) != 0x13 and memory.read_u8(node + 1) != 0x12:
				return
			a7 = entry_a7 - 0xfa4
			transform_through_node_chain(path, C68kScript.s16(depth), node, pos_x, pos_y, pos_z, 0)
			a7 = entry_a7
			memory.write_u32(plot_ctx + memory.read_s16(plot_ctx + 0xb5a) * 4 + 0x9c8, memory.read_u32(node + 0xe))
			memory.write_u8(plot_ctx + memory.read_s16(plot_ctx + 0xb5a) + 0x964, memory.read_u8(node + 1))
			entry = plot_ctx + memory.read_s16(plot_ctx + 0xb5a) * 0xc + 0x4b4
			memory.write_u16(plot_ctx + 0xb5a, C68kScript.u16(memory.read_u16(plot_ctx + 0xb5a) + 1))
			memory.write_u32(entry, memory.read_u32(pos_x))
			memory.write_u32(entry + 4, memory.read_u32(pos_y))
		memory.write_u32(entry + 8, memory.read_u32(pos_z))
		return
	a7 = entry_a7 - 0xfa4
	transform_through_node_chain(path, C68kScript.s16(depth), node, pos_x, pos_y, pos_z, verts)
	a7 = entry_a7
	translate_int3_vecs(memory.read_s16(node + 0x1a), verts, verts,
			C68kScript.s32(-memory.read_s32(player + 0x18)), 0, C68kScript.s32(-memory.read_s32(player + 0x20)))
	i = 0
	while i < memory.read_s16(node + 0x1a):
		work = verts + i * 0xc
		memory.write_u32(work, C68kScript.u32(_divs_l_32(memory.read_s32(work), memory.read_s32(plot_ctx))))
		memory.write_u32(work + 8, C68kScript.u32(_divs_l_32(memory.read_s32(work + 8), memory.read_s32(plot_ctx))))
		i = C68kScript.s16(i + 1)
	i = 0
	while i < memory.read_u8(face + 8):
		work = verts + memory.read_s16(face + 0xe + i * 2) * 0xc
		memory.write_u32(outline + i * 8, memory.read_u32(work))
		memory.write_u32(outline + i * 8 + 4, memory.read_u32(work + 8))
		i = C68kScript.s16(i + 1)
	work = clip_polygon_x_min(outline, memory.read_u8(face + 8), clip_buf)
	if C68kScript.s16(work) == 0:
		return
	work = clip_polygon_x_max(clip_buf, C68kScript.s16(work), outline)
	if C68kScript.s16(work) == 0:
		return
	work = clip_polygon_y_min(outline, C68kScript.s16(work), clip_buf)
	if C68kScript.s16(work) == 0:
		return
	saved_y_max = memory.read_u16(DAT_0001b73e)
	memory.write_u16(DAT_0001b73e, memory.read_u16(DAT_0001b740))
	work = clip_polygon_y_max(clip_buf, C68kScript.s16(work), outline)
	memory.write_u16(DAT_0001b73e, saved_y_max)
	if C68kScript.s16(work) == 0:
		return
	a7 = entry_a7 - 0xf94
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x292), [outline, C68kScript.s16(work), memory.read_u32(face)])
	a7 = entry_a7
	return

## Fills a map context through the mission scene (collect_map_features, runtime 0x6cc): zone
## points at ctx + 4 (count word ctx +0xb58), sites at ctx + 0x4b4 with kind bytes at +0x964
## and ranges at +0x9c8 (count word +0xb5a). Each zone point gets symbol 'A', or - at the
## first site whose approx_dist3_xyz is below its range - 'C' when the point's y > 0, 'B'
## for a kind-0x13 site, none for a kind-0x12 site; plot_symbol(symbol, (x - player x) /
## scale, (player z - z) / scale) (divs.l, extb.l of the symbol). Missions 3 and 4 (word
## host_world +0x90) also plot 'T' (0x54) at a fixed point. Frame (link.w a6,#-0xb5c): ctx at
## a6 - 0xb5c; for_each_mission_scene_object is entered 0xb94 below, plot_symbol 0xba0.
func plot_mission_map_symbols(scale: int, plot_symbol: int) -> void:
	assert(memory != null, "plot_mission_map_symbols requires original global memory")
	assert(a7 != 0, "plot_mission_map_symbols needs a7 (its frame holds the map context)")
	var entry_a7: int = a7
	var ctx: int = a7 - 4 - 0xb5c
	var player: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	var i: int
	var site: int
	var point: int
	var symbol: int
	var dist: int
	var work_x: int
	var t_symbol_z: int = 0

	memory.write_u32(ctx, C68kScript.u32(scale))
	memory.write_u16(ctx + 0xb5a, 0)
	memory.write_u16(ctx + 0xb58, 0)
	a7 = entry_a7 - 0xb94
	for_each_mission_scene_object(0x6cc, ctx)
	a7 = entry_a7
	i = 0
	while i < memory.read_s16(ctx + 0xb58):
		point = ctx + 4 + i * 0xc
		symbol = 0x41
		site = 0
		while site < memory.read_s16(ctx + 0xb5a):
			var site_pos: int = ctx + 0x4b4 + site * 0xc
			dist = approx_dist3_xyz(memory.read_s32(point), memory.read_s32(point + 4), memory.read_s32(point + 8),
					memory.read_s32(site_pos), memory.read_s32(site_pos + 4), memory.read_s32(site_pos + 8))
			if dist < memory.read_s32(ctx + 0x9c8 + site * 4):
				if 0 < memory.read_s32(point + 4):
					symbol = 0x43
					break
				if memory.read_u8(ctx + 0x964 + site) == 0x13:
					symbol = 0x42
					break
				if memory.read_u8(ctx + 0x964 + site) == 0x12:
					symbol = 0
					break
			site = C68kScript.s16(site + 1)
		if symbol != 0:
			a7 = entry_a7 - 0xba0
			_jsr(plot_symbol, [C68kScript.s8(symbol),
					_divs_l_32(C68kScript.s32(memory.read_s32(point) - memory.read_s32(player + 0x18)), scale),
					_divs_l_32(C68kScript.s32(memory.read_s32(player + 0x20) - memory.read_s32(point + 8)), scale)])
			a7 = entry_a7
		i = C68kScript.s16(i + 1)
	work_x = 1000000000
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) == 3:
		work_x = -0x3bcd3
		t_symbol_z = 0x2b246a
	elif memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) == 4:
		work_x = -0xf2bf12
		t_symbol_z = 0xb242d8
	if work_x != 1000000000:
		a7 = entry_a7 - 0xba0
		_jsr(plot_symbol, [0x54,
				_divs_l_32(C68kScript.s32(work_x - memory.read_s32(player + 0x18)), scale),
				_divs_l_32(C68kScript.s32(memory.read_s32(player + 0x20) - t_symbol_z), scale)])
		a7 = entry_a7
	return

## Approximate distance from the point to the segment start .. start + (word dx, dy, dz)
## (adda.w: only the low words of the deltas, sign-extended): both end distances (word
## results), then four bisection steps (dbra from 4, entered at the test) replacing the
## farther end by the midpoint (add.l, asr.l #1); returns the smaller end distance as a
## sign-extended word (signed cmp.w, ties keep the far end).
static func segment_point_min_distance(x0: int, y0: int, z0: int, dx: int, dy: int, dz: int, px: int, py: int, pz: int) -> int:
	var dist_start: int
	var dist_end: int
	var dist_mid: int
	var steps: int
	var sx: int = C68kScript.s32(x0)
	var sy: int = C68kScript.s32(y0)
	var sz: int = C68kScript.s32(z0)
	var ex: int = C68kScript.s32(sx + C68kScript.s16(dx))
	var ey: int = C68kScript.s32(sy + C68kScript.s16(dy))
	var ez: int = C68kScript.s32(sz + C68kScript.s16(dz))
	var mx: int
	var my: int
	var mz: int

	dist_start = C68kScript.s16(approx_dist3_xyz(sx, sy, sz, px, py, pz))
	dist_end = C68kScript.s16(approx_dist3_xyz(ex, ey, ez, px, py, pz))
	steps = 4
	while true:
		steps = steps - 1
		if steps == -1:
			break
		mx = C68kScript.asr32(sx + ex, 1)
		my = C68kScript.asr32(sy + ey, 1)
		mz = C68kScript.asr32(sz + ez, 1)
		dist_mid = C68kScript.s16(approx_dist3_xyz(mx, my, mz, px, py, pz))
		if dist_end < dist_start:
			sx = mx
			sy = my
			sz = mz
			dist_start = dist_mid
		else:
			ex = mx
			ey = my
			ez = mz
			dist_end = dist_mid
	if dist_start < dist_end:
		dist_end = dist_start
	return dist_end

## (a * b) mod 2^32 assembled from 16-bit halves: three muls.l, the cross sum masked to 16
## bits and shifted up (lsl.l #16), plus the low product.
static func overlay_rng_mul_mix(a: int, b: int) -> int:
	a = C68kScript.u32(a)
	b = C68kScript.u32(b)
	var cross: int = C68kScript.u32((b & 0xffff) * (a >> 0x10) + (a & 0xffff) * (b >> 0x10))
	return C68kScript.s32(((cross & 0xffff) << 0x10) + (b & 0xffff) * (a & 0xffff))

## Seed at 0x2600c, ring longs 1..54 = previous * 0x1df5e0d + 1, cursor 0x260e4, then 10000
## discarded outputs.
func overlay_rng_init(seed: int) -> void:
	assert(memory != null, "overlay_rng_init requires original global memory")
	var i: int
	var slot: int

	memory.write_u32(DAT_0002600c, C68kScript.u32(seed))
	i = 1
	slot = DAT_0002600c + 4
	while true:
		memory.write_u32(slot, C68kScript.u32(overlay_rng_mul_mix(0x1df5e0d, memory.read_u32(DAT_00026008 + i * 4)) + 1))
		i = i + 1
		slot = slot + 4
		if not (i < 0x37):
			break
	memory.write_u32(DAT_00026008, 0x260e4)
	i = 0
	while true:
		overlay_rng_next()
		i = i + 1
		if not (i < 10000):
			break
	return

## Lagged-Fibonacci step over the ring: the next slot (wrapping at 0x260e8, unsigned compares)
## becomes slot(+0x5c) + slot(+0xd8) (each wrapped by -0xdc); returns its high word.
func overlay_rng_next() -> int:
	assert(memory != null, "overlay_rng_next requires original global memory")
	var slot: int
	var tap_a: int
	var tap_b: int
	var sum: int

	slot = memory.read_u32(DAT_00026008) + 4
	if not (0x260e8 > slot):
		slot = slot - 0xdc
	memory.write_u32(DAT_00026008, slot)
	tap_a = slot + 0x5c
	if not (0x260e8 > tap_a):
		tap_a = tap_a - 0xdc
	tap_b = slot + 0xd8
	if not (0x260e8 > tap_b):
		tap_b = tap_b - 0xdc
	sum = C68kScript.u32(memory.read_u32(tap_a) + memory.read_u32(tap_b))
	memory.write_u32(slot, sum)
	return sum >> 0x10

## Clears player_shot_ctl when it is obj's controller; when byte +1 != byte +2, clears the
## scene-root child table entry +0x14 of index byte +2 and, if byte +1 lies in [child_window_lo,
## child_window_hi] (sext words, signed), removes obj from the seven scatter slots; then x
## (+0x18) = 1000000000, long +4 |= 2, +0x3c = 0, *controller = 0, retire_count += 1.
## Returns D0 as left by the bytes (callers return it in turn): the caller's D0 (d0_in) when
## bytes +1 and +2 are equal, else byte +1 zero-extended, or 7 after the slot scrub.
func retire_entity(obj: int, d0_in: int = 0) -> int:
	assert(memory != null, "retire_entity requires original global memory")
	var k: int
	var d0: int = d0_in

	if memory.read_u32(obj + 8) == memory.read_u32(DAT_0001b880):
		memory.write_u32(DAT_0001b880, 0)
	if memory.read_u8(obj + 1) != memory.read_u8(obj + 2):
		memory.write_u32(memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30) + 0x14 + memory.read_u8(obj + 2) * 0x18, 0)
		d0 = memory.read_u8(obj + 1)
		if memory.read_s16(DAT_0001b88e) <= memory.read_u8(obj + 1) and memory.read_u8(obj + 1) <= memory.read_s16(DAT_0001b88c):
			k = 0
			while true:
				if obj == memory.read_u32(DAT_0001bc64 + k * 4):
					memory.write_u32(DAT_0001bc64 + k * 4, 0)
				k = k + 1
				if not (k < 7):
					break
			d0 = k
	memory.write_u32(obj + 0x18, 1000000000)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 2)
	memory.write_u32(obj + 0x3c, 0)
	if memory.read_u32(obj + 8) != 0:
		memory.write_u32(memory.read_u32(obj + 8), 0)
	memory.write_u32(DAT_00024cf0, C68kScript.u32(memory.read_u32(DAT_00024cf0) + 1))
	return d0

## Bullet path this frame: segment from position - velocity / 2 (C truncation: +1 bias then
## asr.l #1) over the velocity (controller +8 / +0xc / +0x10) against the shape position;
## within range +0x14 (signed cmp.l): flag 4 of byte +6 -> 1 in 8 (rng & 7 == 0) latches the
## shape in bullet controller +0x3c; else a type-0xe target is ignored, a type-0x1b one gets
## word +0x46 = 1 with rng & 0xf == 0, and the bullet is retired. Returns D0 of each path.
func bullet_hits_shape(bullet: int, shape: int) -> int:
	assert(memory != null, "bullet_hits_shape requires original global memory")
	var bullet_ctl: int = memory.read_u32(bullet + 8)
	var d0: int
	var b_type: int

	d0 = _bullet_segment_distance(bullet, bullet_ctl, shape)
	if not (d0 <= memory.read_s32(shape + 0x14)):
		return d0
	if (memory.read_u8(shape + 6) & 4) != 0:
		d0 = overlay_rng_next() & 7
		if d0 == 0:
			memory.write_u32(bullet_ctl + 0x3c, shape)
		return d0
	if memory.read_u32(shape + 8) != 0:
		b_type = memory.read_s16(memory.read_u32(memory.read_u32(shape + 8) + 4))
		d0 = C68kScript.s32((d0 & 0xffff0000) | C68kScript.u16(b_type))
		if b_type == 0xe:
			return d0
		if b_type == 0x1b:
			d0 = overlay_rng_next() & 0xf
			if d0 == 0:
				memory.write_u16(memory.read_u32(shape + 8) + 0x46, 1)
	return retire_entity(bullet, d0)

## Shared argument computation of the two bullet tests (0x1666a..0x166b8 / 0x16804..0x16852).
func _bullet_segment_distance(bullet: int, bullet_ctl: int, target: int) -> int:
	var vx: int = memory.read_s32(bullet_ctl + 8)
	var vy: int = memory.read_s32(bullet_ctl + 0xc)
	var vz: int = memory.read_s32(bullet_ctl + 0x10)
	return segment_point_min_distance(
			C68kScript.s32(memory.read_s32(bullet + 0x18) - C68kScript.divs_trunc(vx, 2)),
			C68kScript.s32(memory.read_s32(bullet + 0x1c) - C68kScript.divs_trunc(vy, 2)),
			C68kScript.s32(memory.read_s32(bullet + 0x20) - C68kScript.divs_trunc(vz, 2)),
			vx, vy, vz,
			memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20))

## Type 1 (player aircraft): snd_hit = 1; types 1 and 3 escape 3 times in 4 (rng & 3). Else a
## roll (rng & 0xff, signed word compares) sets one damage bit of word +0x684: <= 5 bit 0,
## <= 0x2a bit 1, <= 0x37 bit 2, <= 0x44 bit 3, <= 0x50 bit 4, <= 0x5d bit 5; above, bit 6
## when bits 6..9 are clear, otherwise (bit 9 -> bit 8 when byte +0x684 bit 1) word +0x688 = 0.
## by_player != 0 sets bit 15. Returns D0.
func apply_random_aircraft_damage(ctl: int, by_player: int) -> int:
	assert(memory != null, "apply_random_aircraft_damage requires original global memory")
	var d0: int
	var flags: int = ctl + 0x684
	var kind: int = memory.read_s16(memory.read_u32(ctl + 4))

	if kind == 1 or kind == 3:
		if kind == 1:
			memory.write_u16(DAT_0001b842, 1)
		d0 = overlay_rng_next() & 3
		if d0 != 0:
			return d0
	d0 = overlay_rng_next() & 0xff
	if d0 <= 5:
		memory.write_u16(flags, memory.read_u16(flags) | 1)
	elif d0 <= 0x2a:
		memory.write_u16(flags, memory.read_u16(flags) | 2)
	elif d0 <= 0x37:
		memory.write_u16(flags, memory.read_u16(flags) | 4)
	elif d0 <= 0x44:
		memory.write_u16(flags, memory.read_u16(flags) | 8)
	elif d0 <= 0x50:
		memory.write_u16(flags, memory.read_u16(flags) | 0x10)
	elif d0 <= 0x5d:
		memory.write_u16(flags, memory.read_u16(flags) | 0x20)
	else:
		d0 = memory.read_u16(flags) & 0x3c0
		if d0 == 0:
			memory.write_u16(flags, memory.read_u16(flags) | 0x40)
		else:
			if (memory.read_u8(flags) & 2) != 0:
				memory.write_u16(flags, memory.read_u16(flags) & 0xfdff)
				memory.write_u16(flags, memory.read_u16(flags) | 0x100)
			memory.write_u16(ctl + 0x688, 0)
	if by_player != 0:
		memory.write_u16(flags, memory.read_u16(flags) | 0x8000)
	return d0

## Same bullet segment against an aircraft; within range: 1 in 8 (rng & 7 == 0) damages the
## aircraft controller (by_player = sext word bullet controller +0x36) and retires the
## bullet; otherwise, when the aircraft controller is the player's, rng bit 0 sets snd_hit.
## Returns D0 of each path.
func bullet_hits_aircraft(bullet: int, aircraft: int) -> int:
	assert(memory != null, "bullet_hits_aircraft requires original global memory")
	var bullet_ctl: int = memory.read_u32(bullet + 8)
	var air_ctl: int
	var d0: int

	d0 = _bullet_segment_distance(bullet, bullet_ctl, aircraft)
	if not (d0 <= memory.read_s32(aircraft + 0x14)):
		return d0
	air_ctl = memory.read_u32(aircraft + 8)
	d0 = overlay_rng_next() & 7
	if d0 == 0:
		d0 = apply_random_aircraft_damage(air_ctl, memory.read_s16(bullet_ctl + 0x36))
		return retire_entity(bullet, d0)
	if air_ctl == memory.read_u32(DAT_0001b738):
		d0 = overlay_rng_next()
		if (d0 & 1) != 0:
			memory.write_u16(DAT_0001b842, 1)
	return d0

## Calls the collision handler(s) at definition (controller +4) +0x12 of objects a and b,
## unless view_mode == 8 or either byte +5 has bit 0. One handler: (owner, other, 0). Two: the
## 10-entry pair table (cursor left at 0x26284 on the match) by definition type words in
## either order, else a's handler when byte +6 of a has bit 5, else b's. Returns D0 (the
## handler's, or the caller's d0_in when nothing is called).
func dispatch_collision(obj_a: int, obj_b: int, d0_in: int = 0) -> int:
	assert(memory != null, "dispatch_collision requires original global memory")
	var def_a: int = 0
	var def_b: int = 0
	var handler_a: int = 0
	var handler_b: int = 0
	var left: int
	var cursor: int

	if memory.read_s16(DAT_0001d858) == 8:
		return d0_in
	if (memory.read_u8(obj_a + 5) & 1) != 0:
		return d0_in
	if (memory.read_u8(obj_b + 5) & 1) != 0:
		return d0_in
	if memory.read_u32(obj_a + 8) != 0:
		def_a = memory.read_u32(memory.read_u32(obj_a + 8) + 4)
		handler_a = memory.read_u32(def_a + 0x12)
	if memory.read_u32(obj_b + 8) != 0:
		def_b = memory.read_u32(memory.read_u32(obj_b + 8) + 4)
		handler_b = memory.read_u32(def_b + 0x12)
	if handler_a == 0 or handler_b == 0:
		if handler_a != 0:
			return _jsr(handler_a, [obj_a, obj_b, 0], d0_in)
		if handler_b == 0:
			return d0_in
		return _jsr(handler_b, [obj_b, obj_a, 0], d0_in)
	memory.write_u32(DAT_00026284, DAT_0001b43c)
	left = 10
	while true:
		left = C68kScript.s16(left - 1)
		if left == -1:
			break
		cursor = memory.read_u32(DAT_00026284)
		if memory.read_s16(cursor) == memory.read_s16(def_a) and memory.read_s16(cursor + 2) == memory.read_s16(def_b):
			return _jsr(memory.read_u32(cursor + 4), [obj_a, obj_b, 0], d0_in)
		if memory.read_s16(cursor) == memory.read_s16(def_b) and memory.read_s16(cursor + 2) == memory.read_s16(def_a):
			return _jsr(memory.read_u32(cursor + 4), [obj_b, obj_a, 0], d0_in)
		memory.write_u32(DAT_00026284, C68kScript.u32(cursor + 8))
	if (memory.read_u8(obj_a + 6) & 0x20) != 0:
		return _jsr(handler_a, [obj_a, obj_b, 0], d0_in)
	return _jsr(handler_b, [obj_b, obj_a, 0], d0_in)

## Nearest object of the near list (low word of object_count, dbra) whose controller type word
## is 0x12 or 0x13 and whose approx_dist3_xyz to obj is below its range +0xc and below the best
## so far (signed cmp.l); returns 0x100 for type 0x12, 0x200 for 0x13, else 0.
func probe_nearest_facility_kind(object: int) -> int:
	assert(memory != null, "probe_nearest_facility_kind requires original global memory")
	var best_dist: int = 0x7fffffff
	var slot: int = DAT_0001b5a4
	var best: int = 0
	var left: int = memory.read_s16(DAT_0001b734 + 2)
	var facility: int
	var type_word: int
	var dist: int

	while true:
		left = C68kScript.s16(left - 1)
		if left == -1:
			break
		facility = memory.read_u32(slot)
		slot = slot + 4
		if memory.read_u32(facility + 8) == 0:
			continue
		type_word = memory.read_s16(memory.read_u32(memory.read_u32(facility + 8) + 4))
		if type_word != 0x12 and type_word != 0x13:
			continue
		dist = approx_dist3_xyz(memory.read_s32(object + 0x18), memory.read_s32(object + 0x1c), memory.read_s32(object + 0x20),
				memory.read_s32(facility + 0x18), memory.read_s32(facility + 0x1c), memory.read_s32(facility + 0x20))
		if dist < memory.read_s32(facility + 0xc) and dist < best_dist:
			best_dist = dist
			best = facility
	if best != 0:
		if memory.read_s16(memory.read_u32(memory.read_u32(best + 8) + 4)) == 0x12:
			return 0x100
		if memory.read_s16(memory.read_u32(memory.read_u32(best + 8) + 4)) == 0x13:
			return 0x200
	return 0

## Kill tally: word +0x50 < 0, or a friendly air base (0x200) nearest -> word host_world +0xd2
## += 1; else type 0 does nothing and type t increments word host_world +0xb8 + 2t. Returns D0.
func tally_destroyed_entity(entity: int, d0_in: int = 0) -> int:
	assert(memory != null, "tally_destroyed_entity requires original global memory")
	var d0: int = d0_in
	var counter: int

	if memory.read_s16(entity + 0x50) >= 0:
		d0 = probe_nearest_facility_kind(entity)
		if d0 != 0x200:
			if memory.read_s16(entity + 0x50) == 0:
				return d0
			d0 = C68kScript.s32(memory.read_s16(entity + 0x50) << 1)
			counter = memory.read_u32(DAT_0001b5a0) + d0 + 0xb8
			memory.write_u16(counter, C68kScript.u16(memory.read_u16(counter) + 1))
			return d0
	counter = memory.read_u32(DAT_0001b5a0) + 0xd2
	memory.write_u16(counter, C68kScript.u16(memory.read_u16(counter) + 1))
	return d0

## No-op when byte +7 bit 1 (long +4 bit 1, set by retire_entity) is set. Retires the entity when
## it belongs to the scene root's published child window (+0x24 == scene_root, sext words
## child_window_lo <= byte +1 <= child_window_hi) or is not a shape (byte +0 != 2); a shape
## outside the window is stamped instead: long +4 |= 0x42, +0x3c = frame_counter. Returns D0.
func dispatch_entity_cleanup(obj: int, d0_in: int = 0) -> int:
	assert(memory != null, "dispatch_entity_cleanup requires original global memory")
	var d0: int = d0_in
	var in_window: bool = false

	if (memory.read_u8(obj + 7) & 2) != 0:
		return d0
	if memory.read_u32(obj + 0x24) == memory.read_u32(DAT_0001d6fc):
		d0 = memory.read_u8(obj + 1)
		in_window = memory.read_s16(DAT_0001b88e) <= d0 and d0 <= memory.read_s16(DAT_0001b88c)
	if in_window or memory.read_u8(obj) != 2:
		return retire_entity(obj, d0)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x42)
	memory.write_u32(obj + 0x3c, memory.read_u32(DAT_0001b838))
	return d0

## Effect for a destroyed object at its position (+ controller velocity when it has a
## controller). With a controller: near the surface when y - ground height (+0x2e) < 100
## (signed); surface = sext byte +0x2c, or surface_type_under_object (0x13452) when the ground
## height is 0; the effect y is the ground height on surfaces 0x30 / 0x60 / 0x70, else 0.
## Without one: near, y = 0, surface from 0x13452. Airborne -> spawn_effect (0x11c58)(2, size,
## 5, 0, 1); surface 0x10 -> (0, size, 0x4b, 0, 0); otherwise (3, 3 * size / 4 truncating, 0x2d,
## 1, 0). Surface compares are signed words of D0. Returns the near flag (0 / 1).
func spawn_destruction_effect(obj: int, size: int) -> int:
	assert(memory != null, "spawn_destruction_effect requires original global memory")
	var ctl: int = memory.read_u32(obj + 8)
	var near: int
	var surface: int
	var x: int
	var y: int
	var z: int

	if ctl != 0:
		x = C68kScript.s32(memory.read_s32(obj + 0x18) + memory.read_s32(ctl + 8))
		y = C68kScript.s32(memory.read_s32(obj + 0x1c) + memory.read_s32(ctl + 0xc))
		z = C68kScript.s32(memory.read_s32(obj + 0x20) + memory.read_s32(ctl + 0x10))
		near = 1 if C68kScript.s32(y - memory.read_s32(ctl + 0x2e)) <= 99 else 0
		surface = memory.read_s8(ctl + 0x2c)
		if near != 0:
			if memory.read_u32(ctl + 0x2e) == 0:
				surface = C68kScript.s16(_bsr_unported(0x13452, [obj]))
			if surface == 0x30 or surface == 0x60 or surface == 0x70:
				y = memory.read_s32(ctl + 0x2e)
			else:
				y = 0
		else:
			surface = 0
	else:
		near = 1
		x = memory.read_s32(obj + 0x18)
		y = 0
		z = memory.read_s32(obj + 0x20)
		surface = C68kScript.s16(_bsr_unported(0x13452, [obj]))
	if near == 0:
		_bsr_unported(0x11c58, [2, size, 5, 0, 1, x, y, z])
	elif surface == 0x10:
		_bsr_unported(0x11c58, [0, size, 0x4b, 0, 0, x, y, z])
	else:
		_bsr_unported(0x11c58, [3, C68kScript.divs_trunc(C68kScript.s32(size * 3), 4), 0x2d, 1, 0, x, y, z])
	return near

## Bullet controller tick (definition key 0xe, +2). When the bullet hit an object (+0x3c, set
## by bullet_hits_shape): destruction effect at its range +0x14 / 8 (C-truncating), or / 4 when
## its +0x1c is set; a kill tally when the bullet was the player's (word +0x36); cleanup of the
## hit object and retirement of the bullet. Then the lifetime word +0x38 += 1: at 0x1f the
## bullet retires; after frame 3 the long +0x32 gains -0x5b (gravity) and +0xc = it asr 6; the
## bullet retires once its y (+0x1c) <= ground height +0x2e (signed). The tick loops ignore D0.
func tick_bullet(ctl: int) -> void:
	assert(memory != null, "tick_bullet requires original global memory")
	var obj: int = memory.read_u32(ctl)
	var hit_obj: int = memory.read_u32(ctl + 0x3c)
	var effect_range: int

	if hit_obj != 0:
		if memory.read_u32(hit_obj + 0x1c) == 0:
			effect_range = C68kScript.divs_trunc(memory.read_s32(hit_obj + 0x14), 8)
		else:
			effect_range = C68kScript.divs_trunc(memory.read_s32(hit_obj + 0x14), 4)
		spawn_destruction_effect(hit_obj, effect_range)
		if memory.read_s16(ctl + 0x36) != 0:
			tally_destroyed_entity(hit_obj)
		dispatch_entity_cleanup(hit_obj)
		retire_entity(obj)
	memory.write_u16(ctl + 0x38, C68kScript.u16(memory.read_u16(ctl + 0x38) + 1))
	if memory.read_s16(ctl + 0x38) != 0x1f:
		if 3 < memory.read_s16(ctl + 0x38):
			memory.write_u32(ctl + 0x32, C68kScript.u32(memory.read_s32(ctl + 0x32) - 0x5b))
		memory.write_u32(ctl + 0xc, C68kScript.u32(C68kScript.asr32(memory.read_u32(ctl + 0x32), 6)))
		if memory.read_s32(ctl + 0x2e) < memory.read_s32(obj + 0x1c):
			return
	retire_entity(obj)
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
