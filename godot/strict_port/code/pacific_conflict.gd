class_name StrictPacificConflict
extends RefCounted
## Strict translations owned by the Pacific Conflict CODE overlay.
## The sole provenance and verification record lives in mappings/functions.json.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

const DAT_0001ab6c: int = 0x1ab6c ## sin_table: 256 words (runtime address; file 0x1ab8c)
const DAT_0001ad6c: int = 0x1ad6c ## cos_table: 256 words (runtime address; file 0x1ad8c)
const DAT_0001af6c: int = 0x1af6c ## tan_table: 128 longs, 4096 * tan((i - 0x3f) * pi / 128) (runtime address; file 0x1af8c)
const DAT_0001b5a0: int = 0x1b5a0 ## host_world: pointer to the host A5 world
const DAT_0001b524: int = 0x1b524 ## template_ptr_table_base: definition record per class key (+6: factory code address)
const DAT_0001b540: int = 0x1b540 ## template_ptr_table_base[7]: plume definition
const DAT_0001b550: int = 0x1b550 ## template_ptr_table_base[11]: ground fire definition
const DAT_0001b864: int = 0x1b864 ## first_carrier_ctl (long)
const DAT_0002627a: int = 0x2627a ## effect_template_3 (long)
const DAT_00026000: int = 0x26000 ## enemy_fighter_template (long): first key-4 fighter object, kept as a template
const DAT_00026768: int = 0x26768 ## shadow_templates: template object per shadow kind (long each)
const DAT_0002677c: int = 0x2677c ## turret_template (long)
const DAT_0001b41c: int = 0x1b41c ## effect_anim_table: per-kind effect animator (runtime code addresses)
const DAT_000260e8: int = 0x260e8 ## smoke_template (long), just past the overlay RNG ring
const DAT_00026660: int = 0x26660 ## ground_mark_template (long)
const DAT_0001d80e: int = 0x1d80e ## neg_camera_heading (word)
const DAT_00020adc: int = 0x20adc ## mission_target_list (long pointer; word +4 set when mission 7's facility sinks)
const DAT_0001b50c: int = 0x1b50c ## trail_init_table: per-kind trail initialiser (runtime code addresses)
const DAT_0001b514: int = 0x1b514 ## trail_animate_table: per-kind trail animator (runtime code addresses)
const DAT_0001d83c: int = 0x1d83c ## anchor_x (anchor record +0; y +4, z +8)
const DAT_0001d854: int = 0x1d854 ## anchor_found (word, anchor record +0x18)
const DAT_0002664a: int = 0x2664a ## bullet_template (long)
const DAT_00026650: int = 0x26650 ## trail_templates: template object per trail kind (long each)
const DAT_0001d810: int = 0x1d810 ## neg_camera_pitch (word)
const RANGE_0x26ac0: int = 0x26ac0 ## flak range table (address stored by create_flak_controller)
const DAT_0001b5a4: int = 0x1b5a4 ## object_pool: near-list object pointers
const DAT_0001b734: int = 0x1b734 ## object_count (long; its low word at 0x1b736 is the dbra count)
const DAT_0001b738: int = 0x1b738 ## player_object: pointer to the player controller (+0 object)
const DAT_0001b73e: int = 0x1b73e ## clip_y_max (word)
const DAT_0001b740: int = 0x1b740 ## clip_y_max_alt (word)
const DAT_0001b838: int = 0x1b838 ## frame_counter (long)
const DAT_0001b842: int = 0x1b842 ## snd_hit (word): one-frame player-hit sound flag
const DAT_0001b40c: int = 0x1b40c ## effect_init_table: per-kind initialiser (runtime code addresses)
const DAT_0001b190: int = 0x1b190 ## band_limits: ascending distance band thresholds (band_limits_lo = this - 4)
const DAT_0001b43c: int = 0x1b43c ## collision_pair_table: 10 x (type word, type word, handler long)
const DAT_0001b848: int = 0x1b848 ## snd_distant_explosion_timer (word)
const DAT_0001b84a: int = 0x1b84a ## snd_explosion_timer (word)
const DAT_0001b870: int = 0x1b870 ## replay_state (word)
const DAT_0001b826: int = 0x1b826 ## view_depth (word): 1, 4 or 8
const DAT_0001b880: int = 0x1b880 ## player_shot_ctl (long)
const DAT_0001b88c: int = 0x1b88c ## child_window_hi (word)
const DAT_0001b88e: int = 0x1b88e ## child_window_lo (word)
const DAT_0001bc64: int = 0x1bc64 ## scatter_slots: 7 object pointers
const DAT_0001d6fc: int = 0x1d6fc ## scene_root (+0x30: child table, 0x18-byte records)
const DAT_00024cf0: int = 0x24cf0 ## retire_count (long)
const DAT_00026008: int = 0x26008 ## rng_cursor: pointer into the 55-long ring 0x2600c..0x260e7
const DAT_000260ec: int = 0x260ec ## effect_log_index (word, wraps at 16)
const DAT_000260ee: int = 0x260ee ## effect_log: 16 x 0x18-byte records
const DAT_0002626e: int = 0x2626e ## effect_templates: template object per kind
const DAT_0002665c: int = 0x2665c ## debris_template: debris fragment template object
const DAT_00026284: int = 0x26284 ## collision_pair_cursor (long)
const DAT_0002600c: int = 0x2600c ## rng_state: first ring long (the seed)
const DAT_0001bd80: int = 0x1bd80 ## palette_search_cursor (long, 0..199)
const DAT_0001bd88: int = 0x1bd88 ## light_z (word)
const DAT_0001bd8a: int = 0x1bd8a ## light_y (word)
const DAT_0001bd8c: int = 0x1bd8c ## light_x (word)
const DAT_0001bda8: int = 0x1bda8 ## default_surface_face: ground-plane face (+0x16 surface code)
const DAT_0001bdb8: int = 0x1bdb8 ## visible_list_split (long; its low word at 0x1bdba)
const DAT_0001bdbc: int = 0x1bdbc
const DAT_00020c50: int = 0x20c50 ## heap_break: byte offset into the arena at host_world +0x348
const DAT_00020c58: int = 0x20c58 ## heap_ring_sentinel (size 0; next link at 0x20c5c)
const DAT_00020c60: int = 0x20c60 ## heap_roving_cursor: large-block ring cursor
const DAT_00020c64: int = 0x20c64 ## heap_class_lists: free-list head of class c at + 4c
const DAT_00020aea: int = 0x20aea ## clip_y_min (word)
const DAT_00020aec: int = 0x20aec ## clip_x_max (word)
const DAT_00020aee: int = 0x20aee ## clip_x_min (word)
const DAT_0001c1d4: int = 0x1c1d4 ## visible_count (long; its low word at 0x1c1d6)
const DAT_0001c1cc: int = 0x1c1cc ## controller_count (long)
const DAT_0001c1dc: int = 0x1c1dc ## entity_array_3_count (long)
const DAT_0001c1e0: int = 0x1c1e0 ## entity_array_1_count (long; low word at 0x1c1e2)
const DAT_0001c25c: int = 0x1c25c ## controller_list: active controller pointers
const DAT_0001c9dc: int = 0x1c9dc ## visible_list: object pointers
const DAT_0001d858: int = 0x1d858 ## view_mode (word)
const DAT_0001d0e4: int = 0x1d0e4 ## entity_array_3: far / deferred object pointers
const DAT_0001d4a4: int = 0x1d4a4 ## entity_array_1: active object pointers
const DAT_0001d85a: int = 0x1d85a ## palette_direct_mode (word)
const DAT_0001d85c: int = 0x1d85c ## slot_to_index_map: pointer to slot -> pixel index words
const DAT_0001d860: int = 0x1d860 ## slot_usage_prev: pointer to a 200-byte usage map
const DAT_0001d864: int = 0x1d864 ## slot_usage_cur: pointer to a 200-byte usage map
const DAT_0001da70: int = 0x1da70 ## palette_owner_tables: three table pointers (0x1da70 / 74 / 78)
const DAT_0001da7c: int = 0x1da7c ## palette_owner_current: owner table in use (256 longs)
const DAT_0001daa2: int = 0x1daa2 ## palette_changed (word)
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
const DAT_0001d71c: int = 0x1d71c ## detail_ref_z
const DAT_0001d724: int = 0x1d724 ## detail_ref_x
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
	## Controller factories: definition record +6 holds the RUNTIME address (file - 0x20); the
	## callers jsr them with (obj, class key, 0).
	code_table[0x11466] = func(o: int, k: int, _c: int = 0) -> int: return create_spinner_controller(o, k)
	code_table[0x11590] = func(o: int, _k: int = 0, _c: int = 0) -> int: return create_plume_controller(o)
	code_table[0x11a8e] = func(o: int, k: int, _c: int = 0) -> int: return create_camera_facing_controller(o, k)
	code_table[0x11ade] = func(o: int, k: int, _c: int = 0) -> int: return create_effect_controller(o, k)
	code_table[0x127a6] = func(o: int, k: int, _c: int = 0) -> int: return create_ordnance_controller(o, k)
	code_table[0x150a8] = func(o: int, k: int, _c: int = 0) -> int: return create_carrier_controller(o, k)
	code_table[0x152ee] = func(o: int, k: int, _c: int = 0) -> int: return create_firing_ship_controller(o, k)
	code_table[0x15560] = func(o: int, k: int, c: int = 0) -> int: return create_sinking_controller(o, k, c)
	code_table[0x155cc] = func(o: int, k: int, _c: int = 0) -> int: return create_basic_ship_controller(o, k)
	code_table[0x15b72] = func(o: int, k: int, _c: int = 0) -> int: return create_bullet_controller(o, k)
	code_table[0x16a1a] = func(o: int, k: int, _c: int = 0) -> int: return create_trail_controller(o, k)
	code_table[0x1704a] = func(o: int, _k: int = 0, _c: int = 0) -> int: return create_ground_fire_controller(o)
	code_table[0x17382] = func(o: int, k: int, _c: int = 0) -> int: return create_debris_controller(o, k)
	code_table[0x17546] = func(o: int, k: int, _c: int = 0) -> int: return create_ground_mark_controller(o, k)
	code_table[0x1889a] = func(o: int, k: int, _c: int = 0) -> int: return create_shadow_controller(o, k)
	code_table[0x18b32] = func(o: int, k: int, _c: int = 0) -> int: return create_flak_controller(o, k)
	code_table[0x190a0] = func(o: int, k: int, _c: int = 0) -> int: return create_turret_controller(o, k)
	code_table[0x19396] = func(o: int, k: int, _c: int = 0) -> int: return create_parachute_controller(o, k)
	code_table[0x199fa] = func(o: int, k: int, _c: int = 0) -> int: return create_cloud_controller(o, k)
	code_table[0x19b62] = func(o: int, k: int, _c: int = 0) -> int: return create_view_attached_controller(o, k)
	## effect_anim_table (0x1b41c) entries 0 / 1 (runtime addresses); tick_effect jsrs them.
	code_table[0x123ae] = Callable(self, "animate_effect_kind0_ring")
	code_table[0x12466] = Callable(self, "animate_effect_kind1_column")
	code_table[0x12276] = Callable(self, "animate_effect_kind2_burst")
	code_table[0x12508] = Callable(self, "animate_effect_kind3_debris")
	## Controller tick handlers (definition record +2, runtime addresses).
	code_table[0x116dc] = Callable(self, "tick_smoke_plume")
	code_table[0x174a4] = Callable(self, "tick_debris_fragment")
	code_table[0x175a0] = Callable(self, "tick_ground_mark")
	code_table[0x189b0] = Callable(self, "tick_shadow")
	code_table[0x19b9c] = Callable(self, "tick_view_attached_object")
	code_table[0x17360] = Callable(self, "tick_ground_fire")
	code_table[0x155b8] = Callable(self, "tick_sinking_controller")
	code_table[0x1915c] = Callable(self, "tick_turret")
	code_table[0x18c76] = Callable(self, "tick_flak_gun")
	## Trails: init / animate tables (0x1b50c / 0x1b514), tick and destroy handlers.
	code_table[0x16aa4] = Callable(self, "init_trail_kind0")
	code_table[0x16ab6] = Callable(self, "init_trail_kind1")
	code_table[0x16c4a] = Callable(self, "animate_smoke_trail")
	code_table[0x16de6] = Callable(self, "animate_burning_trail")
	code_table[0x1700a] = Callable(self, "tick_trail")
	code_table[0x16c04] = Callable(self, "destroy_trail_controller")
	## Aircraft class factories (definition records of keys 1..4, +6).
	code_table[0xe0ae] = func(o: int, k: int, c: int = 0) -> int: return aircraft_create(o, k, c)
	code_table[0xe1c6] = func(o: int, k: int, c: int = 0) -> int: return create_enemy_fighter(o, k, c)
	code_table[0xe284] = func(o: int, k: int, c: int = 0) -> int: return create_friendly_bomber(o, k, c)
	code_table[0xe320] = func(o: int, k: int, c: int = 0) -> int: return create_enemy_bomber(o, k, c)
	## effect_init_table (0x1b40c) entries 0..3, runtime addresses; spawn_effect jsrs them with
	## the new effect object.
	code_table[0x1201a] = Callable(self, "init_effect_kind0_flat_ring")
	code_table[0x120aa] = Callable(self, "init_effect_kind1_column")
	code_table[0x11edc] = Callable(self, "init_effect_kind2_burst")
	code_table[0x1215e] = Callable(self, "init_effect_kind3_debris_explosion")


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
## surface_type_under_object is entered 0x20 below (six saved registers, argument, bsr).
func _call_surface_type_under_object(obj: int) -> int:
	var entry_a7: int = a7
	a7 = entry_a7 - 0x20
	var result: int = surface_type_under_object(obj)
	a7 = entry_a7
	return result

## spawn_effect is entered 0x3c below (six saved registers, eight arguments, bsr).
func _call_spawn_effect(kind: int, word_34: int, word_36: int, byte_38: int, debris: int, x: int, y: int, z: int) -> int:
	var entry_a7: int = a7
	a7 = entry_a7 - 0x3c
	var result: int = spawn_effect(kind, word_34, word_36, byte_38, debris, x, y, z)
	a7 = entry_a7
	return result

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
				surface = C68kScript.s16(_call_surface_type_under_object(obj))
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
		surface = C68kScript.s16(_call_surface_type_under_object(obj))
	if near == 0:
		_call_spawn_effect(2, size, 5, 0, 1, x, y, z)
	elif surface == 0x10:
		_call_spawn_effect(0, size, 0x4b, 0, 0, x, y, z)
	else:
		_call_spawn_effect(3, C68kScript.divs_trunc(C68kScript.s32(size * 3), 4), 0x2d, 1, 0, x, y, z)
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
		var entry_a7: int = a7
		a7 = entry_a7 - 0x18 ## three saved registers, two arguments, bsr
		spawn_destruction_effect(hit_obj, effect_range)
		a7 = entry_a7
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

## Even-odd test of the point against a polygon of 12-byte vertices (words +2 = first, +10 =
## second coordinate) listed by vidx: for each edge from the previous vertex (the last one
## first) that straddles pz (signed word compares), count a crossing when both first
## coordinates exceed px, or - when they lie on both sides - when prev + (pz - prev2) *
## (cur - prev) / (cur2 - prev2) > 0 (sub.w, muls.w, divs.l truncating). Returns the parity.
func point_in_polygon_xz(px: int, pz: int, verts: int, count: int, vidx: int) -> int:
	return _point_in_polygon(px, pz, verts, count, vidx, 2)

## As point_in_polygon_xz with the first coordinate at +6 (0x1310e: same code, other offsets).
func point_in_polygon_yz(py: int, pz: int, verts: int, count: int, vidx: int) -> int:
	return _point_in_polygon(py, pz, verts, count, vidx, 6)

func _point_in_polygon(pa: int, pb: int, verts: int, count: int, vidx: int, off_a: int) -> int:
	assert(memory != null, "point_in_polygon requires original global memory")
	var crossings: int = 0
	var cur: int
	var prev: int
	pa = C68kScript.s16(pa)
	pb = C68kScript.s16(pb)
	count = C68kScript.s16(count)
	cur = verts + memory.read_s16(vidx + (count - 1) * 2) * 0xc
	while true:
		prev = cur
		count = C68kScript.s16(count - 1)
		if count == -1:
			return crossings & 1
		cur = verts + memory.read_s16(vidx) * 0xc
		vidx = vidx + 2
		var prev_b: int = memory.read_s16(prev + 10)
		var cur_b: int = memory.read_s16(cur + 10)
		if not ((pb < prev_b and cur_b <= pb) or (prev_b <= pb and pb < cur_b)):
			continue
		var prev_a: int = memory.read_s16(prev + off_a)
		var cur_a: int = memory.read_s16(cur + off_a)
		if pa < prev_a and pa < cur_a:
			crossings = C68kScript.s16(crossings + 1)
		elif pa < prev_a or pa < cur_a:
			var num: int = C68kScript.s16(pb - prev_b) * C68kScript.s16(cur_a - prev_a)
			if 0 < C68kScript.s32(prev_a + C68kScript.divs_trunc(C68kScript.s32(num), C68kScript.s16(cur_b - prev_b))):
				crossings = C68kScript.s16(crossings + 1)
	return crossings & 1 ## not reached: the loop exits through its return

## For each vertex index of the face (count word +0x14, list +0x18), the object vertex (+0x44,
## 12-byte longs) asr.l by the word shift (mod 64) minus the word origins goes to the same
## index of out as words +2 and +10 (xz) or +2 and +6 (xy).
func project_face_vertices_xz(model: int, shift: int, face: int, origin_x: int, origin_z: int, out: int) -> void:
	_project_face_vertices(model, shift, face, origin_x, origin_z, out, 8, 10)

func project_face_vertices_xy(model: int, shift: int, face: int, origin_x: int, origin_y: int, out: int) -> void:
	_project_face_vertices(model, shift, face, origin_x, origin_y, out, 4, 6)

func _project_face_vertices(model: int, shift: int, face: int, origin_a: int, origin_b: int, out: int, src_b: int, dst_b: int) -> void:
	assert(memory != null, "project_face_vertices requires original global memory")
	var model_verts: int = memory.read_u32(model + 0x44)
	var left: int = memory.read_s16(face + 0x14)
	var vidx: int = memory.read_u32(face + 0x18)
	shift = C68kScript.s16(shift) & 0x3f
	while true:
		left = C68kScript.s16(left - 1)
		if left == -1:
			return
		var mv: int = model_verts + memory.read_s16(vidx) * 0xc
		var ov: int = out + memory.read_s16(vidx) * 0xc
		memory.write_u16(ov + 2, C68kScript.u16(C68kScript.asr32(memory.read_u32(mv), shift) - origin_a))
		memory.write_u16(ov + dst_b, C68kScript.u16(C68kScript.asr32(memory.read_u32(mv + src_b), shift) - origin_b))
		vidx = vidx + 2

## Surface code at (x, z): walks entity_array_1 from the end (low word of its count, dbra),
## skipping objects whose |metric +0x10 - camera metric of the point| or approx distance
## exceeds their range +0x14, or whose long +4 has 0x42; tests their faces from the last
## (only those with a surface byte +0x16) by projecting with shift word +0x32 + 1 and
## point_in_polygon_xz(0, 0, ...); returns the first hit's code, else the default face's,
## sign-extended (extb.l). Frame (link.w a6,#-0x690): projection buffer at a6 - 0x690.
func surface_type_at_point(x: int, y_unused: int, z: int) -> int:
	assert(memory != null, "surface_type_at_point requires original global memory")
	assert(a7 != 0, "surface_type_at_point needs a7 (its frame holds the projection buffer)")
	var projected: int = a7 - 4 - 0x690
	var left: int = memory.read_s16(DAT_0001c1e0 + 2)
	var slot: int = DAT_0001d4a4 + left * 4
	var metric: int = compute_camera_abs_metric(x, y_unused, z)
	var obj: int
	var faces_left: int
	var face: int
	var shift: int

	while true:
		left = C68kScript.s16(left - 1)
		if left == -1:
			return memory.read_s8(memory.read_u32(DAT_0001bda8) + 0x16)
		slot = slot - 4
		obj = memory.read_u32(slot)
		if memory.read_s32(obj + 0x14) < abs_int(C68kScript.s32(memory.read_s32(obj + 0x10) - metric)):
			continue
		if (memory.read_u32(obj + 4) & 0x42) != 0:
			continue
		if memory.read_s32(obj + 0x14) < approx_dist3_xyz(x, y_unused, z, memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20)):
			continue
		faces_left = memory.read_s16(obj + 0x3a)
		face = C68kScript.u32(memory.read_u32(obj + 0x48) + faces_left * 0x20 - 0x20)
		while true:
			faces_left = C68kScript.s16(faces_left - 1)
			if faces_left == -1:
				break
			if memory.read_u8(face + 0x16) != 0:
				shift = C68kScript.s32(memory.read_s16(obj + 0x32) + 1)
				project_face_vertices_xz(obj, shift, face, C68kScript.s16(C68kScript.asr32(x, shift & 0x3f)), C68kScript.s16(C68kScript.asr32(z, shift & 0x3f)), projected)
				if point_in_polygon_xz(0, 0, projected, memory.read_s16(face + 0x14), memory.read_u32(face + 0x18)) != 0:
					return memory.read_s8(face + 0x16)
			face = face - 0x20
	return 0 ## not reached: the loop exits through its returns

## surface_type_at_point(object x, y, z); no frame, so the callee is entered 0x10 below
## (three arguments, bsr).
func surface_type_under_object(obj: int) -> int:
	assert(memory != null, "surface_type_under_object requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x10
	var result: int = surface_type_at_point(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20))
	a7 = entry_a7
	return result

## Effect spawn. Live play (word replay_state == 0) logs the call in the 16-entry ring 0x260ee
## + 24 * index (byte kind, byte_38 (+1, the low byte of the long argument), debris (+2), words
## +4 / +6, x / y / z longs +8.., frame +0x14; index + 1 & 0xf); while replaying only state -1
## or kind 1 continue, else 0. Kind != 1 in view modes <= 2 or 8 sets the explosion sound
## timers by compute_camera_abs_metric (<= 9999 -> word 0x1b84a = 0x1e, else <= 39999 ->
## word 0x1b848 = 0xf). Spawns effect_templates[kind] at (x, y, z) with
## spawn_mission_pool_object (null -> 0), stores the arguments in its
## controller (+0x32, +0x34, +0x36, +0x39, +0x38), calls effect_init_table[kind](object) and,
## with debris, spawn_debris_fragment three times; returns the controller.
## Frame link.w a6,#0 + nine saved registers: the pool spawn is entered 0x4c below, the
## initialiser 0x30, each debris call 0x3c.
func spawn_effect(kind: int, word_34: int, word_36: int, byte_38: int, debris: int, x: int, y: int, z: int) -> int:
	assert(memory != null, "spawn_effect requires original global memory")
	var entry_a7: int = a7
	var entry: int
	var tmp: int
	var ctl: int
	var left: int

	kind = C68kScript.s32(kind)
	if memory.read_s16(DAT_0001b870) == 0:
		entry = DAT_000260ee + memory.read_s16(DAT_000260ec) * 0x18
		memory.write_u8(entry, C68kScript.u8(kind))
		memory.write_u16(entry + 4, C68kScript.u16(word_34))
		memory.write_u16(entry + 6, C68kScript.u16(word_36))
		memory.write_u8(entry + 2, C68kScript.u8(debris))
		memory.write_u8(entry + 1, C68kScript.u8(byte_38))
		memory.write_u32(entry + 8, C68kScript.u32(x))
		memory.write_u32(entry + 0xc, C68kScript.u32(y))
		memory.write_u32(entry + 0x10, C68kScript.u32(z))
		memory.write_u32(entry + 0x14, memory.read_u32(DAT_0001b838))
		memory.write_u16(DAT_000260ec, (memory.read_u16(DAT_000260ec) + 1) & 0xf)
	elif memory.read_s16(DAT_0001b870) != -1 and kind != 1:
		return 0
	if kind != 1 and (memory.read_s16(DAT_0001d858) <= 2 or memory.read_s16(DAT_0001d858) == 8):
		tmp = compute_camera_abs_metric(x, y, z)
		if tmp <= 9999:
			memory.write_u16(DAT_0001b84a, 0x1e)
		elif tmp <= 39999:
			memory.write_u16(DAT_0001b848, 0xf)
	a7 = entry_a7 - 0x4c
	tmp = spawn_mission_pool_object(memory.read_u32(DAT_0002626e + kind * 4), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if tmp == 0:
		return 0
	ctl = memory.read_u32(tmp + 8)
	memory.write_u8(ctl + 0x32, C68kScript.u8(kind))
	memory.write_u16(ctl + 0x34, C68kScript.u16(word_34))
	memory.write_u16(ctl + 0x36, C68kScript.u16(word_36))
	memory.write_u8(ctl + 0x39, C68kScript.u8(debris))
	memory.write_u8(ctl + 0x38, C68kScript.u8(byte_38))
	a7 = entry_a7 - 0x30
	_jsr(memory.read_u32(DAT_0001b40c + kind * 4), [tmp])
	a7 = entry_a7
	if debris != 0:
		left = 3
		while true:
			left = left - 1
			if left == -1:
				break
			a7 = entry_a7 - 0x3c
			spawn_debris_fragment(x, y, z)
			a7 = entry_a7
	return ctl

## Takes the first free slot (+0x14 == 0) of the scene root's table (+0x30, sext word count
## +0x2e, 0x18-byte records); when none is free the table grows by 10 records through
## heap_realloc_grow_only. The slot gets word +0 = low word of factory_arg,
## offsets +8 / +0xc / +0x10 and the low words of the angles at +2 / +4 / +6; then
## instantiate_mission_pool_slot(root, byte tmpl +1, slot). The slot's object
## is returned, or retired and 0 when its +0x44 (vertices) is null. Frame link.w a6,#0 + four
## saved registers: the instantiation is entered 0x24 below.
func spawn_mission_pool_object(tmpl_obj: int, off_x: int, off_y: int, off_z: int, angle1: int, angle2: int, angle3: int, factory_arg: int) -> int:
	assert(memory != null, "spawn_mission_pool_object requires original global memory")
	var entry_a7: int = a7
	var root: int = memory.read_u32(DAT_0001d6fc)
	var table: int = memory.read_u32(root + 0x30)
	var count: int = memory.read_s16(root + 0x2e)
	var slot: int = 0
	var obj: int

	while slot < count:
		if memory.read_u32(table + slot * 0x18 + 0x14) == 0:
			break
		slot = slot + 1
	if count == slot:
		table = heap_realloc_grow_only(table, C68kScript.s32((count + 10) * 0x18))
		root = memory.read_u32(DAT_0001d6fc)
		memory.write_u32(root + 0x30, table)
		memory.write_u16(root + 0x2e, C68kScript.u16(memory.read_u16(root + 0x2e) + 10))
	var record: int = table + slot * 0x18
	memory.write_u16(record, C68kScript.u16(factory_arg))
	memory.write_u32(record + 8, C68kScript.u32(off_x))
	memory.write_u32(record + 0xc, C68kScript.u32(off_y))
	memory.write_u32(record + 0x10, C68kScript.u32(off_z))
	memory.write_u16(record + 2, C68kScript.u16(angle1))
	memory.write_u16(record + 4, C68kScript.u16(angle2))
	memory.write_u16(record + 6, C68kScript.u16(angle3))
	a7 = entry_a7 - 0x24
	instantiate_mission_pool_slot(memory.read_u32(DAT_0001d6fc), memory.read_u8(tmpl_obj + 1), slot)
	a7 = entry_a7
	obj = memory.read_u32(memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30) + slot * 0x18 + 0x14)
	if memory.read_u32(obj + 0x44) == 0:
		retire_entity(obj)
		return 0
	return obj

## Spawns the debris template at (x, y, z); its controller gets +0x32 = frame + 0x2d,
## velocities +8 / +0xc / +0x10 = (rng & 0xff) - 0x7f, word +0x36 = word +0xe asl 4 and
## angles +0x20 / +0x22 / +0x24 = (rng & 0xff) asl 6 (words). Returns the controller or 0.
## Frame link.w a6,#0 + three saved registers: the pool spawn is entered 0x34 below.
func spawn_debris_fragment(x: int, y: int, z: int) -> int:
	assert(memory != null, "spawn_debris_fragment requires original global memory")
	var entry_a7: int = a7
	var obj: int
	var ctl: int

	a7 = entry_a7 - 0x34
	obj = spawn_mission_pool_object(memory.read_u32(DAT_0002665c), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	ctl = memory.read_u32(obj + 8)
	memory.write_u32(ctl + 0x32, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x2d))
	memory.write_u32(ctl + 8, C68kScript.u32((overlay_rng_next() & 0xff) - 0x7f))
	memory.write_u32(ctl + 0xc, C68kScript.u32((overlay_rng_next() & 0xff) - 0x7f))
	memory.write_u32(ctl + 0x10, C68kScript.u32((overlay_rng_next() & 0xff) - 0x7f))
	memory.write_u16(ctl + 0x36, C68kScript.u16(memory.read_u16(ctl + 0xe) << 4))
	memory.write_u16(ctl + 0x20, C68kScript.u16((overlay_rng_next() & 0xff) << 6))
	memory.write_u16(ctl + 0x22, C68kScript.u16((overlay_rng_next() & 0xff) << 6))
	memory.write_u16(ctl + 0x24, C68kScript.u16((overlay_rng_next() & 0xff) << 6))
	return ctl

## Arena break: returns host_world +0x348 + heap_break, then heap_break += nbytes (no limit).
func heap_sbrk(nbytes: int) -> int:
	assert(memory != null, "heap_sbrk requires original global memory")
	var old_break: int = C68kScript.u32(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x348) + memory.read_u32(DAT_00020c50))
	memory.write_u32(DAT_00020c50, C68kScript.u32(memory.read_u32(DAT_00020c50) + nbytes))
	return old_break

## New small block of 1 << class bytes: class byte at +0, payload at +4 (-1 when sbrk fails).
func heap_new_size_class_block(size_class: int) -> int:
	var block: int = heap_sbrk(C68kScript.lsl32(1, size_class & 0x3f))
	if block == 0xffffffff:
		return -1
	memory.write_u8(block, C68kScript.u8(size_class))
	return C68kScript.u32(block + 4)

## New large block of units * 8 bytes (header: units, tag 0xff), freed into the ring; returns
## the ring cursor afterwards (0 when sbrk fails).
func heap_add_large_block(units: int) -> int:
	var header: int = heap_sbrk(C68kScript.lsl32(units, 3))
	if header == 0xffffffff:
		return 0
	memory.write_u32(header, C68kScript.u32(units))
	memory.write_u8(header + 4, 0xff)
	heap_free_coalesce(header + 8)
	return memory.read_u32(DAT_00020c60)

## Free. Large (tag byte 0xff at payload - 4): the block (header at payload - 8: units, next)
## goes into the address-ordered ring after the cursor's position (unsigned compares, wrap at
## the highest block), merging with its successor and predecessor when adjacent; the cursor
## becomes the predecessor (also through the fall-through store at 0x1a48). Small: payload - 4
## is pushed on its class list (link = old head).
func heap_free_coalesce(payload: int) -> void:
	assert(memory != null, "heap_free_coalesce requires original global memory")
	var block: int
	var cur: int
	var nxt: int
	if memory.read_u8(payload - 4) != 0xff:
		var link: int = payload - 4
		var list: int = DAT_00020c64 + memory.read_u8(link) * 4
		memory.write_u32(link, memory.read_u32(list))
		memory.write_u32(list, link)
		return
	block = payload - 8
	cur = memory.read_u32(DAT_00020c60)
	while true:
		nxt = memory.read_u32(cur + 4)
		if cur < block and block < nxt:
			break
		if not (cur < nxt) and (cur < block or block < nxt):
			break
		cur = nxt
	nxt = memory.read_u32(cur + 4)
	if C68kScript.u32(block + memory.read_u32(block) * 8) == nxt:
		memory.write_u32(block, C68kScript.u32(memory.read_u32(block) + memory.read_u32(nxt)))
		memory.write_u32(block + 4, memory.read_u32(nxt + 4))
	else:
		memory.write_u32(block + 4, nxt)
	if block == C68kScript.u32(cur + memory.read_u32(cur) * 8):
		memory.write_u32(cur, C68kScript.u32(memory.read_u32(cur) + memory.read_u32(block)))
		memory.write_u32(cur + 4, memory.read_u32(block + 4))
	else:
		memory.write_u32(cur + 4, block)
	memory.write_u32(DAT_00020c60, cur)

## Allocate. Class = 2 + bit length of ((nbytes + 7) & ~3) - 1 >> 2 (lsr); classes up to 5 take
## the class list head (class byte rewritten) or a new class block. Larger requests need
## units = (nbytes + 7) >> 3 + 1 eight-byte units: first fit around the ring from the cursor
## (created on first use as the size-0 sentinel at 0x20c58), growing the arena with
## heap_add_large_block when the walk reaches the cursor again; an exact fit is unlinked,
## otherwise the tail of the block is cut off. Returns the payload (header + 8), or 0.
func heap_alloc(nbytes: int) -> int:
	assert(memory != null, "heap_alloc requires original global memory")
	var bits: int = C68kScript.u32(((nbytes + 7) & 0xfffffffc) - 1) >> 2
	var size_class: int = 2
	while bits != 0:
		size_class += 1
		bits = bits >> 1
	if size_class <= 5:
		var head: int = memory.read_u32(DAT_00020c64 + size_class * 4)
		if head == 0:
			return heap_new_size_class_block(size_class)
		memory.write_u32(DAT_00020c64 + size_class * 4, memory.read_u32(head))
		memory.write_u8(head, size_class)
		return C68kScript.u32(head + 4)
	var units: int = (C68kScript.u32(nbytes + 7) >> 3) + 1
	var prev: int = memory.read_u32(DAT_00020c60)
	if prev == 0:
		prev = DAT_00020c58
		memory.write_u32(DAT_00020c60, prev)
		memory.write_u32(DAT_00020c58 + 4, prev)
		memory.write_u32(DAT_00020c58, 0)
	var block: int = memory.read_u32(prev + 4)
	while units > memory.read_u32(block):
		if block == memory.read_u32(DAT_00020c60):
			block = heap_add_large_block(units)
			if block == 0:
				return 0
		prev = block
		block = memory.read_u32(block + 4)
	if units == memory.read_u32(block):
		memory.write_u32(prev + 4, memory.read_u32(block + 4))
	else:
		memory.write_u32(block, memory.read_u32(block) - units)
		block = C68kScript.u32(block + memory.read_u32(block) * 8)
		memory.write_u32(block, units)
	memory.write_u32(DAT_00020c60, prev)
	memory.write_u8(block + 4, 0xff)
	return C68kScript.u32(block + 8)

## Clears the usable payload: (units - 1) * 8 bytes for a large block, (1 << class) - 4 else.
func heap_zero_payload(payload: int) -> void:
	if memory.read_u8(payload - 4) == 0xff:
		memzero(payload, C68kScript.u32((memory.read_u32(payload - 8) - 1) * 8))
	else:
		memzero(payload, C68kScript.lsl32(1, memory.read_u8(payload - 4)) - 4)

func heap_alloc_cleared(nbytes: int) -> int:
	var block: int = heap_alloc(nbytes)
	heap_zero_payload(block)
	return block

## heap_alloc(count * elem_size) (muls.l), cleared when non-null.
func heap_calloc(count: int, elem_size: int) -> int:
	var block: int = heap_alloc(C68kScript.s32(C68kScript.s32(count) * C68kScript.s32(elem_size)))
	if block != 0:
		heap_zero_payload(block)
	return block

## Grows only: when new_size exceeds the usable size (unsigned), a cleared block of new_size is
## allocated, the old usable size copied (memmove_block) and the old block freed.
func heap_realloc_grow_only(payload: int, new_size: int) -> int:
	var old_size: int
	if memory.read_u8(payload - 4) == 0xff:
		old_size = C68kScript.u32((memory.read_u32(payload - 8) - 1) * 8)
	else:
		old_size = C68kScript.u32(C68kScript.lsl32(1, memory.read_u8(payload - 4)) - 4)
	if C68kScript.u32(new_size) <= old_size:
		return payload
	var grown: int = heap_calloc(new_size, 1)
	memmove_block(payload, grown, old_size)
	heap_free_coalesce(payload)
	return grown

## Overlap-safe copy of nbytes from src to dst; returns 0. The bytes copy forward unless
## src < dst and dst - src <= nbytes (signed), when they copy backward. The original moves
## longs where alignment allows and bytes otherwise; in either direction that choice does not
## change the bytes written, so this keeps the direction rule and copies bytes.
func memmove_block(src: int, dst: int, nbytes: int) -> int:
	assert(memory != null, "memmove_block requires original global memory")
	var diff: int = C68kScript.s32(dst - src)
	var n: int = C68kScript.s32(nbytes)
	if diff == 0:
		return 0
	if diff > 0 and diff <= n:
		var i: int = n - 1
		while i >= 0:
			memory.write_u8(dst + i, memory.read_u8(src + i))
			i -= 1
		return 0
	var k: int = 0
	while k < n:
		memory.write_u8(dst + k, memory.read_u8(src + k))
		k += 1
	return 0

## Clears nbytes at dst (nothing when nbytes is negative as a long); returns 0.
func memzero(dst: int, nbytes: int) -> int:
	assert(memory != null, "memzero requires original global memory")
	var n: int = C68kScript.s32(nbytes)
	var k: int = 0
	while k < n:
		memory.write_u8(dst + k, 0)
		k += 1
	return 0

## New object from a scene descriptor. Kind 2: cleared 0x52-byte object; flag long +4 = zero-
## extended word desc +0x16 (byte +6 bit 5, i.e. word bit 13, also sets byte +5 bit 4);
## position +0x18.. from desc +2 / +6 / +0xa, +0xc from +0xe, +0x14 from +0x12; words +0x34 /
## +0x36 / +0x38 (0 -> 1) / +0x3a / +0x50 from +0x18 / +0x1a / +0x1c / +0x1e / +0x20; +0x40 =
## frame. Kind 3: cleared 0x34 bytes; position, +0xc, +0x14, words +0x2c / +0x2e from +0x16 /
## +0x18, +0x28 = desc. Any other tag returns the caller's D1 unchanged (d1_in).
func alloc_object_from_desc(desc: int, d1_in: int = 0) -> int:
	assert(memory != null, "alloc_object_from_desc requires original global memory")
	var obj: int
	var tag: int = memory.read_u8(desc)
	if tag == 2:
		obj = heap_alloc_cleared(0x52)
		memory.write_u8(obj, tag)
		memory.write_u32(obj + 4, memory.read_u16(desc + 0x16))
		if (memory.read_u8(obj + 6) & 0x20) != 0:
			memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 0x10)
		memory.write_u32(obj + 0x18, memory.read_u32(desc + 2))
		memory.write_u32(obj + 0x1c, memory.read_u32(desc + 6))
		memory.write_u32(obj + 0x20, memory.read_u32(desc + 0xa))
		memory.write_u32(obj + 0xc, memory.read_u32(desc + 0xe))
		memory.write_u32(obj + 0x14, memory.read_u32(desc + 0x12))
		memory.write_u16(obj + 0x34, memory.read_u16(desc + 0x18))
		memory.write_u16(obj + 0x36, memory.read_u16(desc + 0x1a))
		memory.write_u16(obj + 0x38, memory.read_u16(desc + 0x1c))
		if memory.read_u16(desc + 0x1c) == 0:
			memory.write_u16(obj + 0x38, 1)
		memory.write_u16(obj + 0x3a, memory.read_u16(desc + 0x1e))
		memory.write_u16(obj + 0x50, memory.read_u16(desc + 0x20))
		memory.write_u32(obj + 0x40, memory.read_u32(DAT_0001b838))
		return obj
	if tag == 3:
		obj = heap_alloc_cleared(0x34)
		memory.write_u8(obj, tag)
		memory.write_u32(obj + 0x18, memory.read_u32(desc + 2))
		memory.write_u32(obj + 0x1c, memory.read_u32(desc + 6))
		memory.write_u32(obj + 0x20, memory.read_u32(desc + 0xa))
		memory.write_u32(obj + 0xc, memory.read_u32(desc + 0xe))
		memory.write_u32(obj + 0x14, memory.read_u32(desc + 0x12))
		memory.write_u16(obj + 0x2c, memory.read_u16(desc + 0x16))
		memory.write_u32(obj + 0x28, desc)
		memory.write_u16(obj + 0x2e, memory.read_u16(desc + 0x18))
		return obj
	return d1_in

## Calls the class factory of definition key k (sext byte desc +1, when non-zero): code address
## = long at (long DAT_0001b524[k]) + 6, called with (obj, k, extra); its result goes to +8 and,
## when non-null, its first long is cleared. Entered `depth` below the caller's a7.
func _call_class_factory(obj: int, desc: int, extra: int, depth: int) -> int:
	var key: int = memory.read_s8(desc + 1)
	var entry: int = memory.read_u32(DAT_0001b524 + key * 4)
	var entry_a7: int = a7
	a7 = entry_a7 - depth
	var ctl: int = C68kScript.u32(_jsr(memory.read_u32(entry + 6), [obj, key, extra]))
	a7 = entry_a7
	memory.write_u32(obj + 8, ctl)
	if ctl != 0:
		memory.write_u32(ctl, 0)
	return ctl

## alloc_object_from_desc, then the class factory with (obj, key, 0) (entered 0x18 below:
## two saved registers, three arguments, jsr). Returns the object.
func instantiate_object_from_desc(desc: int) -> int:
	assert(memory != null, "instantiate_object_from_desc requires original global memory")
	var obj: int = alloc_object_from_desc(desc)
	if memory.read_u8(desc + 1) != 0:
		_call_class_factory(obj, desc, 0, 0x18)
	return obj

## Mission rates for an entity not flagged (byte +7 bit 1) in phases 1..5 (word host +0xa8):
## scale = 1 for byte +5 bit 1, else phase - 1. Unless +0xc is parked (1000000000), +0xc =
## template record +0xe * scale (muls.l) or, at scale 0, record / 2 (C truncation); a shape
## above 0x42b209 without byte +6 bit 4 is clamped to it. For shapes on path 0, every face +0x1c
## gets the packed face long +0xa * 5 for the player's object, else * scale or / 2.
func apply_entity_mission_rates(entity: int, path: int) -> void:
	assert(memory != null, "apply_entity_mission_rates requires original global memory")
	var world: int = memory.read_u32(DAT_0001b5a0)
	var scale: int
	var rec: int
	var phase: int = memory.read_s16(world + 0xa8)
	if (memory.read_u8(entity + 7) & 2) != 0 or phase <= 0 or phase > 5:
		return
	rec = C68kScript.u32(memory.read_u32(world + 0x8c) + memory.read_u32(memory.read_u32(memory.read_u32(entity + 0x24) + 0x28) + 0x2e + memory.read_u8(entity + 1) * 0x18))
	if (memory.read_u8(entity + 5) & 2) != 0:
		scale = 1
	else:
		scale = phase - 1
	if memory.read_s32(entity + 0xc) != 1000000000:
		if scale == 0:
			memory.write_u32(entity + 0xc, C68kScript.u32(C68kScript.divs_trunc(memory.read_s32(rec + 0xe), 2)))
		else:
			memory.write_u32(entity + 0xc, C68kScript.u32(scale * memory.read_s32(rec + 0xe)))
		if memory.read_u8(entity) == 2 and memory.read_s32(entity + 0xc) > 0x42b209 and (memory.read_u8(entity + 6) & 0x10) == 0:
			memory.write_u32(entity + 0xc, 0x42b209)
	if memory.read_u8(entity) != 2 or path != 0:
		return
	var face_rec: int = rec + 0x22 + memory.read_s16(rec + 0x1a) * 0xc + memory.read_s16(rec + 0x1e) * 0xc
	var is_player: bool = memory.read_u32(entity + 8) != 0 and memory.read_u32(DAT_0001b738) == memory.read_u32(entity + 8)
	var face_value: int = memory.read_u32(entity + 0x48) + 0x1c
	var i: int = 0
	while i < memory.read_s16(entity + 0x3a):
		var v: int = memory.read_s32(face_rec + 0xa)
		if is_player:
			memory.write_u32(face_value, C68kScript.u32((v << 2) + v))
		elif scale == 0:
			memory.write_u32(face_value, C68kScript.u32(C68kScript.divs_trunc(v, 2)))
		else:
			memory.write_u32(face_value, C68kScript.u32(scale * v))
		face_rec = face_rec + 0xe + memory.read_u8(face_rec + 8) * 2
		face_value = face_value + 0x20
		i += 1

## Instantiates pool slot `slot` of root from template record `type`: descriptor = host +0x8c +
## long (root +0x28 record + 0x18 * type + 0x2e); object into slot +0x14, +0x24 = root, byte +1
## = type, byte +2 = low byte of slot, byte +3 += 1 when slot == type, long +4 |= 1 when type <
## sext word root +0x2c; apply_template_chain_xform(obj, 1, 0, 0) (0x2c below); class factory
## with (obj, key, sext record word +0) (0x28 below) and, for a controller, words +0x20..+0x24
## = record words +2..+6; apply_entity_mission_rates(obj, 1); camera metric - +0xc <= 0x19c7f
## -> activate_near_range_object (0x20 below), else appended to
## entity_array_3. No frame; six saved registers.
func instantiate_mission_pool_slot(root: int, type: int, slot: int) -> void:
	assert(memory != null, "instantiate_mission_pool_slot requires original global memory")
	var entry_a7: int = a7
	var desc: int = C68kScript.u32(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c) + memory.read_u32(memory.read_u32(root + 0x28) + type * 0x18 + 0x2e))
	var obj: int = alloc_object_from_desc(desc)
	memory.write_u32(memory.read_u32(root + 0x30) + 0x14 + slot * 0x18, obj)
	memory.write_u32(obj + 0x24, root)
	memory.write_u8(obj + 1, C68kScript.u8(type))
	memory.write_u8(obj + 2, C68kScript.u8(slot))
	if slot == type:
		memory.write_u8(obj + 3, C68kScript.u8(memory.read_u8(obj + 3) + 1))
	if type < memory.read_s16(root + 0x2c):
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 1)
	a7 = entry_a7 - 0x2c
	apply_template_chain_xform(obj, 1, 0, 0)
	a7 = entry_a7
	if memory.read_u8(desc + 1) != 0:
		var record: int = memory.read_u32(root + 0x30) + slot * 0x18
		var ctl: int = _call_class_factory(obj, desc, memory.read_s16(record), 0x28)
		record = memory.read_u32(root + 0x30) + slot * 0x18
		if ctl != 0:
			memory.write_u16(ctl + 0x20, memory.read_u16(record + 2))
			memory.write_u16(ctl + 0x22, memory.read_u16(record + 4))
			memory.write_u16(ctl + 0x24, memory.read_u16(record + 6))
	apply_entity_mission_rates(obj, 1)
	if C68kScript.s32(update_object_camera_metric(obj) - memory.read_s32(obj + 0xc)) <= 0x19c7f:
		a7 = entry_a7 - 0x20
		activate_near_range_object(obj)
		a7 = entry_a7
	else:
		var count: int = memory.read_u32(DAT_0001c1dc)
		memory.write_u32(DAT_0001d0e4 + count * 4, obj)
		memory.write_u32(DAT_0001c1dc, C68kScript.u32(count + 1))

## Shared band search of update_object_distance_band / update_record_distance_band: with b =
## the band word, d >= T[b] steps b up while T[b] <= d; d < T[b - 1] steps down from b - 2 while
## d < T[b] (word index), then b + 1; otherwise the band is kept (returns 0). T = DAT_0001b190.
func _distance_band(band_word: int, dist: int) -> int:
	var band: int = memory.read_s16(band_word)
	dist = C68kScript.s32(dist)
	if dist < memory.read_s32(DAT_0001b190 + band * 4):
		if memory.read_s32(DAT_0001b190 - 4 + band * 4) <= dist:
			return 0
		band = C68kScript.s16(band - 2)
		while dist < memory.read_s32(DAT_0001b190 + band * 4):
			band = C68kScript.s16(band - 1)
		band = C68kScript.s16(band + 1)
	else:
		band = C68kScript.s16(band + 1)
		while memory.read_s32(DAT_0001b190 + band * 4) <= dist:
			band = C68kScript.s16(band + 1)
	memory.write_u16(band_word, C68kScript.u16(band))
	return 1

## Band word +0x30 of an object (0x3da8).
func update_object_distance_band(obj: int, dist: int) -> int:
	assert(memory != null, "update_object_distance_band requires original global memory")
	return _distance_band(obj + 0x30, dist)

## Band word +4 of a record (0x3e02: same code, other offset).
func update_record_distance_band(rec: int, dist: int) -> int:
	assert(memory != null, "update_record_distance_band requires original global memory")
	return _distance_band(rec + 4, dist)

## Face records from the packed stream: heap_alloc(0x20 * faces (+ 6 * faces + 2 * word +0x38
## when byte +6 bit 1)) at +0x48; per face +8 = 0, +0xc long, bytes +0x10..+0x13, word +0x14 =
## zero-extended count byte +8, +0x16 / +0x17 = high / low nibble of byte +9, +0x1c = long
## +0xa, +0x18 = heap_alloc(count * 2) holding the count index words; the stream advances 0xe +
## 2 * count. With byte +6 bit 1, words 0 .. word +0x38 - 1 follow the face records. Sets
## palette_changed.
func build_object_poly_buffers(obj: int, src: int) -> void:
	assert(memory != null, "build_object_poly_buffers requires original global memory")
	var size: int = memory.read_s16(obj + 0x3a) * 0x20
	if (memory.read_u8(obj + 6) & 2) != 0:
		size = memory.read_s16(obj + 0x3a) * 6 + memory.read_s16(obj + 0x38) * 2 + size
	var face: int = heap_alloc(C68kScript.s32(size))
	memory.write_u32(obj + 0x48, face)
	var i: int = 0
	while i < memory.read_s16(obj + 0x3a):
		memory.write_u32(face + 8, 0)
		memory.write_u32(face + 0xc, memory.read_u32(src))
		for k in range(4):
			memory.write_u8(face + 0x10 + k, memory.read_u8(src + 4 + k))
		memory.write_u16(face + 0x14, memory.read_u8(src + 8))
		memory.write_u8(face + 0x16, memory.read_u8(src + 9) & 0xf0)
		memory.write_u8(face + 0x17, memory.read_u8(src + 9) & 0xf)
		memory.write_u32(face + 0x1c, memory.read_u32(src + 0xa))
		src = src + 0xe
		var indices: int = heap_alloc(memory.read_s16(face + 0x14) << 1)
		memory.write_u32(face + 0x18, indices)
		var k2: int = 0
		while k2 < memory.read_s16(face + 0x14):
			memory.write_u16(indices + k2 * 2, memory.read_u16(src + k2 * 2))
			k2 += 1
		src = src + memory.read_s16(face + 0x14) * 2
		face = face + 0x20
		i += 1
	if (memory.read_u8(obj + 6) & 2) != 0:
		var trailer: int = memory.read_u32(obj + 0x48) + memory.read_s16(obj + 0x3a) * 0x20
		i = 0
		while i < memory.read_s16(obj + 0x38):
			memory.write_u16(trailer + i * 2, C68kScript.u16(i))
			i += 1
	memory.write_u16(DAT_0001daa2, 1)

## Every face: long +4 = sext word host_world +0x88 table [level], byte +0xf = 0xff.
func set_object_faces_bw_pattern(obj: int, level: int) -> void:
	assert(memory != null, "set_object_faces_bw_pattern requires original global memory")
	var face: int = memory.read_u32(obj + 0x48)
	var i: int = 0
	while i < memory.read_s16(obj + 0x3a):
		memory.write_u32(face + 4, C68kScript.u32(memory.read_s16(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x88) + level * 2)))
		memory.write_u8(face + 0xf, 0xff)
		face = face + 0x20
		i = C68kScript.s16(i + 1)

## Unless byte +7 bit 1: position and +0x14 back to the template descriptor's, then
## apply_template_chain_xform(obj, 1, 0, 0) (entered 0x20 below: three saved registers, four
## arguments, bsr).
func reset_object_to_template_pose(obj: int) -> void:
	assert(memory != null, "reset_object_to_template_pose requires original global memory")
	if (memory.read_u8(obj + 7) & 2) != 0:
		return
	var desc: int = C68kScript.u32(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c) + memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18))
	memory.write_u32(obj + 0x18, memory.read_u32(desc + 2))
	memory.write_u32(obj + 0x1c, memory.read_u32(desc + 6))
	memory.write_u32(obj + 0x20, memory.read_u32(desc + 0xa))
	memory.write_u32(obj + 0x14, memory.read_u32(desc + 0x12))
	var entry_a7: int = a7
	a7 = entry_a7 - 0x20
	apply_template_chain_xform(obj, 1, 0, 0)
	a7 = entry_a7

## Activation. Kind 2 (shape): published on entity_array_1 (byte +7 bit 0) or object_pool;
## n = word +0x36 + word +0x3a (word add); +0x4c and +0x44 = heap_alloc(sext n * 12); face
## records from the descriptor stream after its n template vectors (build_object_poly_buffers);
## a controller gets *ctl = obj and joins controller_list. Then by flags:
## byte +6 bit 4 -> build_land_outline_at_detail(obj, 0xb4e1, 0, 0x7fe4) and, in host word +0xe
## == 1 (one-bit display), set_object_faces_bw_pattern(obj, 0x80), else shade_object_faces;
## byte +7 bit 4 -> mission rates, band, sink_object_shape_at_waterline(obj, words +0x34 /
## +0x36 / +0x38 / +0x40 of a controller whose type word is 0x15..0x19, else zeros);
## byte +5 bit 4 -> translate the template vectors into +0x44 unchanged, rates, band, shade;
## otherwise apply_template_chain_xform(obj, n, template vectors, +0x44), rates, band, shade.
## Unless byte +6 bit 1, word +6 |= 0x800. Kind 3 (group): published on entity_array_1, its
## child table copied from the descriptor (+0x14 relocated by host +0x8c) and every child
## instantiated. Other kinds only refresh the metric, which every path ends with.
## Every callee is ported. No frame; six saved registers.
func activate_near_range_object(obj: int) -> void:
	assert(memory != null, "activate_near_range_object requires original global memory")
	var entry_a7: int = a7
	var kind: int = memory.read_s8(obj)
	var world: int = memory.read_u32(DAT_0001b5a0)
	if kind == 2:
		if (memory.read_u8(obj + 7) & 1) != 0:
			var count1: int = memory.read_u32(DAT_0001c1e0)
			memory.write_u32(DAT_0001d4a4 + count1 * 4, obj)
			memory.write_u32(DAT_0001c1e0, C68kScript.u32(count1 + 1))
		else:
			var count2: int = memory.read_u32(DAT_0001b734)
			memory.write_u32(DAT_0001b5a4 + count2 * 4, obj)
			memory.write_u32(DAT_0001b734, C68kScript.u32(count2 + 1))
		var n: int = C68kScript.s16(memory.read_u16(obj + 0x36) + memory.read_u16(obj + 0x3a))
		var size: int = C68kScript.s32(n * 0xc)
		memory.write_u32(obj + 0x4c, heap_alloc(size))
		memory.write_u32(obj + 0x44, heap_alloc(size))
		var work: int = C68kScript.u32(memory.read_u32(world + 0x8c) + memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18) + 0x22)
		build_object_poly_buffers(obj, C68kScript.u32(work + size))
		if memory.read_u32(obj + 8) != 0:
			memory.write_u32(memory.read_u32(obj + 8), obj)
			var count3: int = memory.read_u32(DAT_0001c1cc)
			memory.write_u32(DAT_0001c25c + count3 * 4, memory.read_u32(obj + 8))
			memory.write_u32(DAT_0001c1cc, C68kScript.u32(count3 + 1))
		if (memory.read_u8(obj + 6) & 0x10) != 0:
			a7 = entry_a7 - 0x2c
			build_land_outline_at_detail(obj, 0xb4e1, 0, 0x7fe4)
			a7 = entry_a7
			if memory.read_s16(world + 0xe) == 1:
				set_object_faces_bw_pattern(obj, 0x80)
			else:
				_call_shade_object_faces(obj, 0x20)
		elif (memory.read_u8(obj + 7) & 0x10) != 0:
			apply_entity_mission_rates(obj, 0)
			update_object_distance_band(obj, memory.read_s32(obj + 0x10))
			var ctl: int = memory.read_u32(obj + 8)
			var sink: Array = [0, 0, 0, 0]
			if ctl != 0:
				var type_word: int = memory.read_s16(memory.read_u32(ctl + 4))
				if type_word > 0x14 and type_word <= 0x19:
					sink = [memory.read_s16(ctl + 0x34), memory.read_s16(ctl + 0x36), memory.read_s16(ctl + 0x38), memory.read_s16(ctl + 0x40)]
			a7 = entry_a7 - 0x30
			sink_object_shape_at_waterline(obj, sink[0], sink[1], sink[2], sink[3])
			a7 = entry_a7
		elif (memory.read_u8(obj + 5) & 0x10) != 0:
			translate_int3_vecs(n, work, memory.read_u32(obj + 0x44), 0, 0, 0)
			apply_entity_mission_rates(obj, 0)
			update_object_distance_band(obj, memory.read_s32(obj + 0x10))
			_call_shade_object_faces(obj, 0x28)
		else:
			a7 = entry_a7 - 0x2c
			apply_template_chain_xform(obj, n, work, memory.read_u32(obj + 0x44))
			a7 = entry_a7
			apply_entity_mission_rates(obj, 0)
			update_object_distance_band(obj, memory.read_s32(obj + 0x10))
			_call_shade_object_faces(obj, 0x20)
		if (memory.read_u8(obj + 6) & 2) == 0:
			memory.write_u16(obj + 6, memory.read_u16(obj + 6) | 0x800)
	elif kind == 3:
		var count4: int = memory.read_u32(DAT_0001c1e0)
		memory.write_u32(DAT_0001d4a4 + count4 * 4, obj)
		memory.write_u32(DAT_0001c1e0, C68kScript.u32(count4 + 1))
		var src: int = memory.read_u32(obj + 0x28) + 0x1a
		memory.write_u32(obj + 0x30, heap_alloc(C68kScript.s32(memory.read_s16(obj + 0x2e) * 0x18)))
		var off: int = 0
		var i: int = 0
		while i < memory.read_s16(obj + 0x2e):
			var dst: int = memory.read_u32(obj + 0x30) + off
			for k in range(6):
				memory.write_u32(dst + 4 * k, memory.read_u32(src + 4 * k))
			src = src + 0x18
			var name_field: int = memory.read_u32(obj + 0x30) + 0x14 + off
			memory.write_u32(name_field, C68kScript.u32(memory.read_u32(name_field) + memory.read_u32(world + 0x8c)))
			off = off + 0x18
			i += 1
		i = 0
		while i < memory.read_s16(obj + 0x2e):
			a7 = entry_a7 - 0x28
			instantiate_mission_pool_slot(obj, i, i)
			a7 = entry_a7
			i += 1
	update_object_camera_metric(obj)

## shade_object_faces entered `depth` below the caller's a7 (it needs no stack memory; kept for
## the record of the bytes' depths).
func _call_shade_object_faces(obj: int, depth: int) -> void:
	var entry_a7: int = a7
	a7 = entry_a7 - depth
	shade_object_faces(obj)
	a7 = entry_a7

## Claims palette slot byte +0xf in the current owner table. Direct mode (word 0x1d85a):
## face +4 = v | v << 8 with v = r + g + low byte of (b divs.w 3), 0 -> 1. Otherwise idx =
## sext word map[slot]; face +4 = idx | idx << 8; one more ColorSpec {idx, r * 256 - 1,
## g * 256 - 1, b * 256 - 1 (each >= 0)} is appended to the pending table at host +0x72 (count
## word +6, entry at +8 + 8 * old count). The callers ignore D0.
func queue_face_palette_entry(face: int) -> void:
	assert(memory != null, "queue_face_palette_entry requires original global memory")
	var slot: int = memory.read_u8(face + 0xf)
	memory.write_u32(memory.read_u32(DAT_0001da7c) + slot * 4, face)
	if memory.read_s16(DAT_0001d85a) != 0:
		var q: int = C68kScript.u8(C68kScript.divs_trunc(memory.read_u8(face + 0xe), 3))
		var v: int = memory.read_u8(face + 0xc) + memory.read_u8(face + 0xd) + q
		if v == 0:
			v = 1
		memory.write_u32(face + 4, C68kScript.u32((v << 8) | v))
		return
	var idx: int = memory.read_s16(memory.read_u32(DAT_0001d85c) + slot * 2)
	memory.write_u32(face + 4, C68kScript.u32((idx << 8) | idx))
	var table: int = memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x72)
	var count: int = memory.read_s16(table + 6)
	var spec: int = C68kScript.u32(table + count * 8 + 8)
	memory.write_u16(table + 6, C68kScript.u16(count + 1))
	memory.write_u16(spec, C68kScript.u16(idx))
	for k in range(3):
		var component: int = (memory.read_u8(face + 0xc + k) << 8) - 1
		memory.write_u16(spec + 2 + 2 * k, C68kScript.u16(component) if component >= 0 else 0)

## queue_face_palette_entry; with the multi-screen flag (host word +0xb4), the slot of every other
## non-null owner table (0x1da70..0x1da78) gets -face. The callers ignore D0.
func write_face_palette_slot(face: int) -> void:
	assert(memory != null, "write_face_palette_slot requires original global memory")
	queue_face_palette_entry(face)
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xb4) == 0:
		return
	for n in range(3):
		var table: int = memory.read_u32(DAT_0001da70 + 4 * n)
		if table != 0 and memory.read_u32(DAT_0001da7c) != table:
			memory.write_u32(table + memory.read_u8(face + 0xf) * 4, C68kScript.u32(-face))

## Face colour for the view depth. 1: luma (19r + 38g + 7b) / 64, stretched (luma - 128) * 16 /
## 12 + 128 (divs.l), clamped, face +4 = sext word host +0x88 table [luma]; 4: face +4 = owner
## table [25r + 5g + b]; both set byte +0xf = 0xff. 8: re-queue a slot this face owns (table entry
## == -face), otherwise claim the first slot free in both usage maps, scanning at most 200 from the
## round-robin cursor (wrap at 200): byte +0xf = low byte of the cursor, write_face_palette_slot,
## palette_changed. Returns 1 when no slot is free, else 0.
func assign_face_colour(face: int) -> int:
	assert(memory != null, "assign_face_colour requires original global memory")
	var depth: int = memory.read_s16(DAT_0001b826)
	if depth == 1:
		var luma: int = C68kScript.divs_trunc(memory.read_u8(face + 0xc) * 0x13 + memory.read_u8(face + 0xd) * 0x26 + memory.read_u8(face + 0xe) * 7, 64)
		var work: int = C68kScript.divs_trunc((luma - 0x80) << 4, 0xc) + 0x80
		if work > 0xff:
			work = 0xff
		elif work < 0:
			work = 0
		memory.write_u32(face + 4, C68kScript.u32(memory.read_s16(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x88) + work * 2)))
		memory.write_u8(face + 0xf, 0xff)
		return 0
	if depth == 4:
		var index: int = memory.read_u8(face + 0xc) * 0x19 + memory.read_u8(face + 0xd) * 5 + memory.read_u8(face + 0xe)
		memory.write_u32(face + 4, memory.read_u32(memory.read_u32(DAT_0001da7c) + index * 4))
		memory.write_u8(face + 0xf, 0xff)
		return 0
	if memory.read_u32(memory.read_u32(DAT_0001da7c) + memory.read_u8(face + 0xf) * 4) == C68kScript.u32(-face):
		queue_face_palette_entry(face)
		return 0
	var tried: int = 0
	while true:
		var cursor: int = memory.read_u32(DAT_0001bd80)
		if memory.read_u8(memory.read_u32(DAT_0001d860) + cursor) == 0 and memory.read_u8(memory.read_u32(DAT_0001d864) + cursor) == 0:
			memory.write_u8(face + 0xf, C68kScript.u8(cursor))
			write_face_palette_slot(face)
			memory.write_u16(DAT_0001daa2, 1)
			return 0
		memory.write_u32(DAT_0001bd80, C68kScript.u32(cursor + 1))
		if memory.read_u32(DAT_0001bd80) == 0xc8:
			memory.write_u32(DAT_0001bd80, 0)
		tried += 1
		if tried > 0xc7:
			return 1
	return 1 ## not reached

## After the faces and the index trailer (+0x48 + 32 * faces + 2 * word +0x38): per face a 6-byte
## {long face +0xc, word 0}.
func snapshot_face_colours(obj: int) -> void:
	assert(memory != null, "snapshot_face_colours requires original global memory")
	var face: int = memory.read_u32(obj + 0x48)
	var snap: int = face + memory.read_s16(obj + 0x3a) * 0x20 + memory.read_s16(obj + 0x38) * 2
	var i: int = 0
	while i < memory.read_s16(obj + 0x3a):
		memory.write_u32(snap, memory.read_u32(face + 0xc))
		memory.write_u16(snap + 4, 0)
		face = face + 0x20
		snap = snap + 6
		i += 1

## Flat shading of a kind-2 object (not byte +7 bit 1). Per face (unless byte +0x13 bit 2: I =
## 0xffff): I = (dx * light_x + dy * light_y + dz * light_z) asr 13 with d = normal point i (the
## +0x44 entries after the word +0x36 vertices) - vertex 0, as words; factor f = 0x8000 + I / 2
## (I >= 0) or 0x4000 + (I + 0x10000) / 4 (truncating), as a zero-extended word; base colour
## bytes c from the template's packed faces. Depth 1: c * f asr 16, then assign_face_colour;
## depth 4: (c * f / 64 + 0x2000) asr 16, then assign_face_colour; else c * f asr 16, blended
## with haze (host +0xaa, unless long +4 & 0x1280) as (c * (32 - band) + band * {0x7d, 0x84,
## 0xa8}) lsr 5, then write_face_palette_slot when the face owns its slot, else slot 0.
## Afterwards snapshot_face_colours when the haze option is on and byte +6 bit 1.
func shade_object_faces(obj: int) -> void:
	assert(memory != null, "shade_object_faces requires original global memory")
	if (memory.read_u8(obj + 7) & 2) != 0 or memory.read_u8(obj) != 2:
		return
	var world: int = memory.read_u32(DAT_0001b5a0)
	var haze_option: int = memory.read_s16(world + 0xaa)
	var haze: int = haze_option
	var band: int = 0
	var haze_rgb: Array = [0, 0, 0]
	if haze_option != 0:
		band = memory.read_s16(obj + 0x30)
		haze_rgb = [C68kScript.s32(band * 0x7d), C68kScript.s32(band * 0x84), C68kScript.s32(band * 0xa8)]
		if (memory.read_u32(obj + 4) & 0x1280) != 0:
			haze = 0
	var depth: int = memory.read_s16(world + 0xe)
	var v0: int = memory.read_u32(obj + 0x44)
	var normals: int = v0 + memory.read_s16(obj + 0x36) * 0xc
	var desc: int = C68kScript.u32(memory.read_u32(world + 0x8c) + memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18))
	var base_rgb: int = desc + 0x22 + memory.read_s16(desc + 0x1a) * 0xc + memory.read_s16(desc + 0x1e) * 0xc
	var face: int = memory.read_u32(obj + 0x48)
	var inv_band: int = 0x20 - band
	var i: int = 0
	while i < memory.read_s16(obj + 0x3a):
		var intensity: int
		if (memory.read_u8(face + 0x13) & 4) != 0:
			intensity = 0xffff
		else:
			var n: int = normals + i * 0xc
			var dx: int = C68kScript.s16(memory.read_u16(n + 2) - memory.read_u16(v0 + 2))
			var dy: int = C68kScript.s16(memory.read_u16(n + 6) - memory.read_u16(v0 + 6))
			var dz: int = C68kScript.s16(memory.read_u16(n + 10) - memory.read_u16(v0 + 10))
			intensity = C68kScript.asr32(dx * memory.read_s16(DAT_0001bd8c) + dy * memory.read_s16(DAT_0001bd8a) + dz * memory.read_s16(DAT_0001bd88), 13)
		var factor: int
		if intensity < 0:
			factor = C68kScript.u16(C68kScript.divs_trunc(intensity + 0x10000, 4) + 0x4000)
		else:
			factor = C68kScript.u16(C68kScript.divs_trunc(intensity, 2) + 0x8000)
		var rgb: Array = []
		for k in range(3):
			var product: int = memory.read_u8(base_rgb + k) * factor
			if depth == 4:
				rgb.append(C68kScript.u8(C68kScript.asr32(C68kScript.divs_trunc(product, 64) + 0x2000, 16)))
			else:
				rgb.append(C68kScript.u8(C68kScript.asr32(product, 16)))
		if depth == 1 or depth == 4:
			for k in range(3):
				memory.write_u8(face + 0xc + k, rgb[k])
			assign_face_colour(face)
		else:
			if haze != 0:
				for k in range(3):
					rgb[k] = C68kScript.u8(C68kScript.u32(rgb[k] * inv_band + haze_rgb[k]) >> 5)
			for k in range(3):
				memory.write_u8(face + 0xc + k, rgb[k])
			if face == memory.read_u32(memory.read_u32(DAT_0001da7c) + memory.read_u8(face + 0xf) * 4):
				write_face_palette_slot(face)
			else:
				memory.write_u8(face + 0xf, 0)
		base_rgb = base_rgb + 0xe + memory.read_u8(base_rgb + 8) * 2
		face = face + 0x20
		i += 1
	if haze_option != 0 and (memory.read_u8(obj + 6) & 2) != 0:
		snapshot_face_colours(obj)

## Sutherland-Hodgman clip of one face (12-byte vertices, words +2 / +6 / +10) against y >= 0:
## kept vertices are copied, an edge crossing y = 0 adds base + (-base.y * (other - base)) /
## (other.y - base.y) (muls.l / divs.l, add.w) with y = 0, base being the vertex below 0. The
## count word at count_ptr is rewritten; returns 1 when any vertex was below 0. Word +0 of the
## output entries is not written.
func clip_polygon_y_nonneg(count_ptr: int, verts: int, vidx: int, out: int) -> int:
	assert(memory != null, "clip_polygon_y_nonneg requires original global memory")
	var clipped: int = 0
	var left: int = memory.read_s16(count_ptr)
	var prev: int = verts + memory.read_s16(vidx + (left - 1) * 2) * 0xc
	var dst: int = out
	while true:
		if left == 0:
			memory.write_u16(count_ptr, C68kScript.u16(C68kScript.divs_trunc(dst - out, 0xc)))
			return clipped
		var cur: int = verts + memory.read_s16(vidx) * 0xc
		if memory.read_s16(cur + 6) < 0:
			clipped = 1
			if memory.read_s16(prev + 6) >= 0:
				_clip_y_cross(cur, prev, dst)
				dst += 0xc
		else:
			if memory.read_s16(prev + 6) < 0:
				clipped = 1
				_clip_y_cross(prev, cur, dst)
				for k in range(3):
					memory.write_u16(dst + 0xe + 4 * k, memory.read_u16(cur + 2 + 4 * k))
				dst += 0xc
			else:
				for k in range(3):
					memory.write_u16(dst + 2 + 4 * k, memory.read_u16(cur + 2 + 4 * k))
			dst += 0xc
		left -= 1
		vidx += 2
		prev = cur
	return clipped ## not reached

func _clip_y_cross(base: int, other: int, dst: int) -> void:
	var dy: int = memory.read_s16(other + 6) - memory.read_s16(base + 6)
	var dy_cut: int = -memory.read_s16(base + 6)
	for k in [0, 2]:
		var off: int = 2 + 4 * k
		var q: int = C68kScript.divs_trunc(C68kScript.s32(dy_cut * (memory.read_s16(other + off) - memory.read_s16(base + off))), dy)
		memory.write_u16(dst + off, C68kScript.u16(memory.read_s16(base + off) + q))
	memory.write_u16(dst + 6, 0)

## Sinking / tilting shape cut at the waterline: the template vectors (vertices + normal points)
## are rotated by build_attitude_matrix_3ang(ang1..3), placed by the template chain, the
## vertices rebased in their low WORDS by -(position << shift) and -(drop << shift) (y); each
## packed face is clipped to y >= 0 (none left -> face byte +0x13 |= 2; else count +0x14, the
## hidden bit cleared unless packed byte +7 bit 1, the index list regrown); clipped points (x /
## z re-offset) are de-duplicated through 256 hash buckets (((y asr 1) + x + z) asr 2 & 0xff,
## linear probing). No point -> long +4 |= 0x40; else +4 &= ~0x40, +0x36 = points, +0x4c /
## +0x44 regrown to (points + faces) * 12, the points copied and the normal points (minus the
## old vertex 0, plus the new one) stored after them. Then shade_object_faces; returns 1 when a
## face is left. The whole 0x3358-byte frame (link.w a6,#-0x3358) is kept in memory at the
## bytes' offsets; build_attitude_matrix_3ang / apply_template_chain_xform are entered 0x3398
## below the entry.
func sink_object_shape_at_waterline(obj: int, ang1: int, ang2: int, ang3: int, drop: int) -> int:
	assert(memory != null, "sink_object_shape_at_waterline requires original global memory")
	assert(a7 != 0, "sink_object_shape_at_waterline needs a7 (its frame holds the work buffers)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var any_face: int = a6 - 0x3336
	var clip_count: int = a6 - 0x3334
	var att_matrix: int = a6 - 0x3332
	var normals: int = a6 - 0x3320
	var id_bucket: int = a6 - 0x2d20
	var bucket_ids: int = a6 - 0x2920
	var clip_out: int = a6 - 0x2520
	var verts: int = a6 - 0x1e90
	var bucket_pts: int = a6 - 0x1800
	memory.write_u16(any_face, 0)
	var world: int = memory.read_u32(DAT_0001b5a0)
	var tmpl: int = C68kScript.u32(memory.read_u32(world + 0x8c) + memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18))
	var n: int = C68kScript.s16(memory.read_u16(tmpl + 0x1a) + memory.read_u16(tmpl + 0x1e))
	var packed: int = tmpl + 0x22 + n * 0xc
	a7 = entry_a7 - 0x3398
	build_attitude_matrix_3ang(C68kScript.s16(ang1), C68kScript.s16(ang2), C68kScript.s16(ang3), att_matrix)
	a7 = entry_a7
	transform_vecs12_to_int3_by_matrix3(n, tmpl + 0x22, verts, att_matrix)
	a7 = entry_a7 - 0x3398
	apply_template_chain_xform(obj, n, verts, verts)
	a7 = entry_a7
	var i: int = 0
	while i < memory.read_s16(tmpl + 0x1e):
		var src: int = verts + (memory.read_s16(tmpl + 0x1a) + i) * 0xc
		for k in range(3):
			memory.write_u32(normals + i * 0xc + 4 * k, C68kScript.u32(memory.read_u32(src + 4 * k) - memory.read_u32(verts + 4 * k)))
		i = C68kScript.s16(i + 1)
	var shift: int = memory.read_s16(obj + 0x34) & 0x3f
	var neg_off_x: int = C68kScript.s32(-C68kScript.lsl32(memory.read_u32(obj + 0x18), shift))
	var neg_drop: int = C68kScript.s32(-C68kScript.lsl32(C68kScript.s16(drop), shift))
	var neg_off_z: int = C68kScript.s32(-C68kScript.lsl32(memory.read_u32(obj + 0x20), shift))
	memory.write_u32(a6 - 0x3342, C68kScript.u32(neg_off_x))
	memory.write_u32(a6 - 0x3346, C68kScript.u32(neg_off_z))
	var left: int = memory.read_s16(tmpl + 0x1a)
	var v: int = verts
	while true:
		left = C68kScript.s16(left - 1)
		if left == -1:
			break
		memory.write_u16(v + 2, C68kScript.u16(memory.read_u16(v + 2) + neg_off_x))
		memory.write_u16(v + 6, C68kScript.u16(memory.read_u16(v + 6) + neg_drop))
		memory.write_u16(v + 10, C68kScript.u16(memory.read_u16(v + 10) + neg_off_z))
		v += 0xc
	for k in range(0x100):
		memory.write_u32(bucket_ids + 4 * k, 0xffffffff)
	var uniq: int = 0
	i = 0
	while i < memory.read_s16(tmpl + 0x1e):
		memory.write_u16(clip_count, memory.read_u8(packed + 8))
		clip_polygon_y_nonneg(clip_count, verts, packed + 0xe, clip_out)
		var face: int = memory.read_u32(obj + 0x48) + i * 0x20
		var count: int = memory.read_s16(clip_count)
		if count == 0:
			memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) | 2)
		else:
			memory.write_u16(any_face, 1)
			memory.write_u16(face + 0x14, C68kScript.u16(count))
			if (memory.read_u8(packed + 7) & 2) == 0:
				memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) & 0xfd)
			memory.write_u32(face + 0x18, heap_realloc_grow_only(memory.read_u32(face + 0x18), count << 1))
			var k2: int = 0
			while k2 < count:
				var e: int = clip_out + k2 * 0xc
				var px: int = C68kScript.s32(memory.read_s16(e + 2) - neg_off_x)
				var py: int = memory.read_s16(e + 6)
				var pz: int = C68kScript.s32(memory.read_s16(e + 10) - neg_off_z)
				var bucket: int = C68kScript.u16(C68kScript.asr32(C68kScript.s32((py >> 1) + px + pz), 2)) & 0xff
				var pt: int = bucket_pts + bucket * 0xc
				var reused: bool = false
				while memory.read_s16(bucket_ids + C68kScript.s16(bucket) * 2) >= 0:
					if memory.read_s32(pt) == px and memory.read_s32(pt + 4) == py and memory.read_s32(pt + 8) == pz:
						memory.write_u16(memory.read_u32(face + 0x18) + k2 * 2, memory.read_u16(bucket_ids + C68kScript.s16(bucket) * 2))
						reused = true
						break
					pt += 0xc
					bucket = C68kScript.u16(bucket + 1)
				if not reused:
					var slot: int = C68kScript.s16(bucket)
					memory.write_u32(bucket_pts + slot * 0xc, C68kScript.u32(px))
					memory.write_u32(bucket_pts + slot * 0xc + 4, C68kScript.u32(py))
					memory.write_u32(bucket_pts + slot * 0xc + 8, C68kScript.u32(pz))
					memory.write_u16(bucket_ids + slot * 2, uniq)
					memory.write_u16(id_bucket + uniq * 2, bucket)
					memory.write_u16(memory.read_u32(face + 0x18) + k2 * 2, uniq)
					uniq = C68kScript.s16(uniq + 1)
				k2 += 1
		packed = packed + 0xe + memory.read_u8(packed + 8) * 2
		i = C68kScript.s16(i + 1)
	if uniq == 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
	else:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)
		memory.write_u16(obj + 0x36, uniq)
		var size: int = C68kScript.s16(uniq + memory.read_u16(obj + 0x3a)) * 0xc
		memory.write_u32(obj + 0x4c, heap_realloc_grow_only(memory.read_u32(obj + 0x4c), size))
		memory.write_u32(obj + 0x44, heap_realloc_grow_only(memory.read_u32(obj + 0x44), size))
		i = 0
		while i < uniq:
			var b: int = memory.read_s16(id_bucket + i * 2)
			for k in range(3):
				memory.write_u32(memory.read_u32(obj + 0x44) + i * 0xc + 4 * k, memory.read_u32(bucket_pts + b * 0xc + 4 * k))
			i += 1
		i = 0
		while i < memory.read_s16(obj + 0x3a):
			var nrm: int = normals + i * 0xc
			for k in range(3):
				memory.write_u32(nrm + 4 * k, C68kScript.u32(memory.read_u32(memory.read_u32(obj + 0x44) + 4 * k) + memory.read_u32(nrm + 4 * k)))
			var dst: int = memory.read_u32(obj + 0x44) + (i + memory.read_s16(obj + 0x36)) * 0xc
			for k in range(3):
				memory.write_u32(dst + 4 * k, memory.read_u32(nrm + 4 * k))
			i += 1
	shade_object_faces(obj)
	return memory.read_s16(any_face)

## Land outline at a detail level: the normal points are saved relative to vertex 0, the
## template vertices placed by the template chain (apply_template_chain_xform entered 0x1c48
## below the entry), then for every packed face the vertex outline is thinned - vertex 0 is
## always kept; a later vertex is kept when (horizontal camera distance) divs.l (word host
## +0xa8 + 3) <= the summed distances of the vertices skipped since the last kept one - and
## stored as ((x - detail_ref_x) asr shift, (z - detail_ref_z) asr shift) pairs. Fewer than 3
## pairs -> nothing; else it is clipped to the +-limit square (clip_x_min / x_max / y_min /
## y_max, each bound global saved, set and restored; a zero count stops). Face byte +0x13 |= 2
## when empty; else +0x14 = count, the hidden bit cleared, +0x18 regrown and each clipped point
## scaled back (asl shift + ref) and found or appended among the unique (x, 0, z) points. Then
## the +4 / +0x36 / +0x4c / +0x44 rebuild as in the sink, +0x18 / +0x20 = detail_ref_x / z,
## +0x14 = range, update_object_camera_metric, and +0x32 = the number of asr #1 steps that
## bring ((+0x10 asr 2) + +0x10 + +0x14) asl word +0x34 below 0x8000 (a negative value never
## gets there, as in the original). Frame arrays live in memory at the link.w a6,#-0x1c08
## offsets.
func build_land_outline_at_detail(obj: int, range_value: int, shift: int, limit: int) -> void:
	assert(memory != null, "build_land_outline_at_detail requires original global memory")
	assert(a7 != 0, "build_land_outline_at_detail needs a7 (its frame holds the work buffers)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var last_x: int = a6 - 0x1bf4
	var last_z: int = a6 - 0x1bf8
	var rel_pts: int = a6 - 0x1be0
	var xf_verts: int = a6 - 0x15e0
	var unique_pts: int = a6 - 0xf50
	var clip_buf: int = a6 - 0x8c0
	var outline: int = a6 - 0x460
	var world: int = memory.read_u32(DAT_0001b5a0)
	var rec: int = C68kScript.u32(memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18) + memory.read_u32(world + 0x8c))
	var i: int = 0
	while i < memory.read_s16(obj + 0x3a):
		var vert: int = memory.read_u32(obj + 0x44) + (memory.read_s16(obj + 0x36) + i) * 0xc
		for k in range(3):
			memory.write_u32(rel_pts + i * 0xc + 4 * k, C68kScript.u32(memory.read_u32(vert + 4 * k) - memory.read_u32(memory.read_u32(obj + 0x44) + 4 * k)))
		i = C68kScript.s16(i + 1)
	var face_src: int = C68kScript.u32(rec + 0x22 + memory.read_s16(rec + 0x1a) * 0xc + memory.read_s16(rec + 0x1e) * 0xc)
	a7 = entry_a7 - 0x1c48
	apply_template_chain_xform(obj, memory.read_s16(rec + 0x1a), C68kScript.u32(rec + 0x22), xf_verts)
	a7 = entry_a7
	var unique: int = 0
	var divisor: int = C68kScript.s16(memory.read_u16(world + 0xa8) + 3)
	var neg_limit: int = C68kScript.u16(-limit)
	var face_i: int = 0
	while face_i < memory.read_s16(obj + 0x3a):
		var idx: int = face_src + 0xe
		var cursor: int = outline
		var skipped: int = 0
		var count: int = 0
		while count < memory.read_u8(face_src + 8):
			var v: int = memory.read_s16(idx + count * 2)
			var vx: int = memory.read_s32(xf_verts + v * 0xc)
			var vz: int = memory.read_s32(xf_verts + v * 0xc + 8)
			var keep: bool = count == 0
			if not keep:
				skipped = C68kScript.s32(skipped + approx_dist3_xyz(memory.read_s32(last_x), 0, memory.read_s32(last_z), vx, 0, vz))
				var cam: int = approx_dist3_xyz(memory.read_s32(DAT_0001d838), 0, memory.read_s32(DAT_0001d830), vx, 0, vz)
				keep = C68kScript.divs_trunc(cam, divisor) <= skipped
			if keep:
				memory.write_u32(last_x, C68kScript.u32(vx))
				memory.write_u32(last_z, C68kScript.u32(vz))
				skipped = 0
				memory.write_u32(cursor, C68kScript.u32(C68kScript.asr32(C68kScript.s32(vx - memory.read_s32(DAT_0001d724)), shift)))
				memory.write_u32(cursor + 4, C68kScript.u32(C68kScript.asr32(C68kScript.s32(vz - memory.read_s32(DAT_0001d71c)), shift)))
				cursor += 8
			count = C68kScript.s16(count + 1)
		count = C68kScript.s16(C68kScript.asr32(cursor - outline, 3))
		if count <= 2:
			count = 0
		else:
			var saved: int = memory.read_u16(DAT_00020aee)
			memory.write_u16(DAT_00020aee, neg_limit)
			count = C68kScript.s16(clip_polygon_x_min(outline, count, clip_buf))
			memory.write_u16(DAT_00020aee, saved)
			if count != 0:
				saved = memory.read_u16(DAT_00020aec)
				memory.write_u16(DAT_00020aec, C68kScript.u16(limit))
				count = C68kScript.s16(clip_polygon_x_max(clip_buf, count, outline))
				memory.write_u16(DAT_00020aec, saved)
			if count != 0:
				saved = memory.read_u16(DAT_00020aea)
				memory.write_u16(DAT_00020aea, neg_limit)
				count = C68kScript.s16(clip_polygon_y_min(outline, count, clip_buf))
				memory.write_u16(DAT_00020aea, saved)
			if count != 0:
				saved = memory.read_u16(DAT_0001b73e)
				memory.write_u16(DAT_0001b73e, C68kScript.u16(limit))
				count = C68kScript.s16(clip_polygon_y_max(clip_buf, count, outline))
				memory.write_u16(DAT_0001b73e, saved)
		var face: int = C68kScript.u32(memory.read_u32(obj + 0x48) + face_i * 0x20)
		if count == 0:
			memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) | 2)
		else:
			memory.write_u16(face + 0x14, C68kScript.u16(count))
			memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) & 0xfd)
			memory.write_u32(face + 0x18, heap_realloc_grow_only(memory.read_u32(face + 0x18), count << 1))
			var k2: int = 0
			while k2 < count:
				var px: int = C68kScript.s32(C68kScript.lsl32(memory.read_u32(outline + k2 * 8), shift) + memory.read_u32(DAT_0001d724))
				var pz: int = C68kScript.s32(C68kScript.lsl32(memory.read_u32(outline + k2 * 8 + 4), shift) + memory.read_u32(DAT_0001d71c))
				var pt: int = unique_pts
				var left: int = unique
				var found: bool = false
				while true:
					left = C68kScript.s16(left - 1)
					if left == -1:
						break
					if memory.read_s32(pt) == px and memory.read_s32(pt + 8) == pz:
						memory.write_u16(memory.read_u32(face + 0x18) + k2 * 2, C68kScript.u16(unique - left - 1))
						found = true
						break
					pt += 0xc
				if not found:
					var u: int = unique_pts + unique * 0xc
					memory.write_u32(u, C68kScript.u32(px))
					memory.write_u32(u + 4, 0)
					memory.write_u32(u + 8, C68kScript.u32(pz))
					memory.write_u16(memory.read_u32(face + 0x18) + k2 * 2, unique)
					unique = C68kScript.s16(unique + 1)
				k2 = C68kScript.s16(k2 + 1)
		face_src = C68kScript.u32(idx + memory.read_u8(face_src + 8) * 2)
		face_i = C68kScript.s16(face_i + 1)
	if unique == 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
	else:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)
		memory.write_u16(obj + 0x36, unique)
		var size: int = C68kScript.s16(unique + memory.read_u16(obj + 0x3a)) * 0xc
		memory.write_u32(obj + 0x4c, heap_realloc_grow_only(memory.read_u32(obj + 0x4c), size))
		memory.write_u32(obj + 0x44, heap_realloc_grow_only(memory.read_u32(obj + 0x44), size))
		i = 0
		while i < unique:
			for k in range(3):
				memory.write_u32(memory.read_u32(obj + 0x44) + i * 0xc + 4 * k, memory.read_u32(unique_pts + i * 0xc + 4 * k))
			i = C68kScript.s16(i + 1)
		i = 0
		while i < memory.read_s16(obj + 0x3a):
			var nrm: int = rel_pts + i * 0xc
			for k in range(3):
				memory.write_u32(nrm + 4 * k, C68kScript.u32(memory.read_u32(memory.read_u32(obj + 0x44) + 4 * k) + memory.read_u32(nrm + 4 * k)))
			var dst: int = memory.read_u32(obj + 0x44) + (memory.read_s16(obj + 0x36) + i) * 0xc
			for k in range(3):
				memory.write_u32(dst + 4 * k, memory.read_u32(nrm + 4 * k))
			i = C68kScript.s16(i + 1)
	memory.write_u32(obj + 0x18, memory.read_u32(DAT_0001d724))
	memory.write_u32(obj + 0x20, memory.read_u32(DAT_0001d71c))
	memory.write_u32(obj + 0x14, C68kScript.u32(range_value))
	update_object_camera_metric(obj)
	var d0: int = C68kScript.s32(C68kScript.asr32(memory.read_u32(obj + 0x10), 2) + memory.read_s32(obj + 0x10) + memory.read_s32(obj + 0x14))
	var d2: int = C68kScript.u32(C68kScript.lsl32(d0, memory.read_s16(obj + 0x34)))
	var steps: int = 0
	while (d2 & 0xffff8000) != 0:
		steps = C68kScript.s16(steps + 1)
		d2 = C68kScript.u32(C68kScript.asr32(d2, 1))
	memory.write_u16(obj + 0x32, C68kScript.u16(steps))

## Fills the 75 pose entries (0x14 bytes each) of a ring with (x, y, z) at +0 / +4 / +8
## (word index 0..0x4a, cmpi.w #$4a / ble). The other entry bytes are left as they are.
func fill_pose_history(ring: int, x: int, y: int, z: int) -> void:
	assert(memory != null, "fill_pose_history requires original global memory")
	var i: int = 0
	while true:
		var off: int = i * 0x14
		memory.write_u32(ring + off, C68kScript.u32(x))
		memory.write_u32(ring + off + 4, C68kScript.u32(y))
		memory.write_u32(ring + off + 8, C68kScript.u32(z))
		i = C68kScript.s16(i + 1)
		if i > 0x4a:
			break

## Controller factories (definition record +6). Each allocates a cleared controller with
## heap_alloc_cleared (bsr 0x1b6c), stores the object at +0 and the definition long
## DAT_0001b524[key] (long key, index scale 4) at +4, and returns the controller in D0 (the
## allocator's D0, untouched, or move.l aN,d0). The object flag writes are long ori on +4,
## word ori on +6 or bset on byte +5, as in the bytes.
func _definition(def_key: int) -> int:
	return memory.read_u32(C68kScript.u32(DAT_0001b524 + C68kScript.s32(def_key) * 4))

## 0x11486: 0x3a bytes; long +0x36 cleared again (clr.l).
func create_spinner_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x3a)
	memory.write_u32(ctl, obj)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u32(ctl + 0x36, 0)
	return ctl

## 0x115b0: 0xa2 bytes; object long +4 |= 0x112000; +4 = template_ptr_table_base[7] (absolute
## long 0x1b540, no key argument read).
func create_plume_controller(obj: int) -> int:
	var ctl: int = heap_alloc_cleared(0xa2)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x112000)
	memory.write_u32(ctl + 4, memory.read_u32(DAT_0001b540))
	return ctl

## 0x11aae: 0x32 bytes; object byte +5 bit 4 set.
func create_camera_facing_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x32)
	memory.write_u32(ctl, obj)
	memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 0x10)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x11afe: 0xd6 bytes; object long +4 |= 0x170000; the object held in effect_template_3
## (0x2627a) also gets word +6 |= 0x2000.
func create_effect_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0xd6)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x170000)
	if memory.read_u32(DAT_0002627a) == C68kScript.u32(obj):
		memory.write_u16(obj + 6, memory.read_u16(obj + 6) | 0x2000)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x127c6: 0x620 bytes; object long +4 |= 0x122000; pose ring at +0x32 filled with the
## object position +0x18 / +0x1c / +0x20.
func create_ordnance_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x620)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x122000)
	memory.write_u32(ctl + 4, _definition(def_key))
	fill_pose_history(ctl + 0x32, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
	return ctl

## 0x150c8: 0x56 bytes; object word +6 |= 0x4000; words +0x50 / +0x52 = -1, long +0x48 =
## 1000000000, word +0x32 = definition word +0x1a, word +0x44 = 7; the first one becomes
## first_carrier_ctl (0x1b864).
func create_carrier_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x56)
	memory.write_u32(ctl, obj)
	memory.write_u16(obj + 6, memory.read_u16(obj + 6) | 0x4000)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u16(ctl + 0x50, 0xffff)
	memory.write_u16(ctl + 0x52, 0xffff)
	memory.write_u32(ctl + 0x48, 1000000000)
	memory.write_u16(ctl + 0x32, memory.read_u16(memory.read_u32(ctl + 4) + 0x1a))
	memory.write_u16(ctl + 0x44, 7)
	if memory.read_u32(DAT_0001b864) == 0:
		memory.write_u32(DAT_0001b864, ctl)
	return ctl

## 0x1530e: 300 bytes; word +0x50 = 0x14, long +0x48 = 1000000000, word +0x44 = 7, word
## +0x32 = definition word +0x1a.
func create_firing_ship_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x12c)
	memory.write_u32(ctl, obj)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u16(ctl + 0x50, 0x14)
	memory.write_u32(ctl + 0x48, 1000000000)
	memory.write_u16(ctl + 0x44, 7)
	memory.write_u16(ctl + 0x32, memory.read_u16(memory.read_u32(ctl + 4) + 0x1a))
	return ctl

## 0x15580: 0x56 bytes; word +0x54 = the low word of the third argument ($12(a6)); object
## long +4 |= 0x102000; long +0x48 = 1000000000, word +0x44 = 3, word +0x32 = definition
## word +0x1a.
func create_sinking_controller(obj: int, def_key: int, word_54: int) -> int:
	var ctl: int = heap_alloc_cleared(0x56)
	memory.write_u32(ctl, obj)
	memory.write_u16(ctl + 0x54, C68kScript.u16(word_54))
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x102000)
	memory.write_u32(ctl + 0x48, 1000000000)
	memory.write_u16(ctl + 0x44, 3)
	memory.write_u16(ctl + 0x32, memory.read_u16(memory.read_u32(ctl + 4) + 0x1a))
	return ctl

## 0x155ec: 0x50 bytes; long +0x48 = 1000000000, word +0x44 = 7, word +0x32 = definition
## word +0x1a.
func create_basic_ship_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x50)
	memory.write_u32(ctl, obj)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u32(ctl + 0x48, 1000000000)
	memory.write_u16(ctl + 0x44, 7)
	memory.write_u16(ctl + 0x32, memory.read_u16(memory.read_u32(ctl + 4) + 0x1a))
	return ctl

## 0x15b92: 0x52 bytes; object long +4 |= 0x122000, object long +0x14 = 0x9c4.
func create_bullet_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x52)
	memory.write_u32(ctl, obj)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x122000)
	memory.write_u32(obj + 0x14, 0x9c4)
	return ctl

## 0x16a3a: 0x58 bytes; object long +4 |= 0x12000, word +0x34 = 0.
func create_trail_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x58)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x12000)
	memory.write_u16(obj + 0x34, 0)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x1706a: 0x54 bytes; object long +4 |= 0x12040, word +0x34 = 0; +4 =
## template_ptr_table_base[11] (absolute long 0x1b550, no key argument read).
func create_ground_fire_controller(obj: int) -> int:
	var ctl: int = heap_alloc_cleared(0x54)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x12040)
	memory.write_u16(obj + 0x34, 0)
	memory.write_u32(ctl + 4, memory.read_u32(DAT_0001b550))
	return ctl

## 0x173a2: 0x38 bytes; object long +4 |= 0x152000.
func create_debris_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x38)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x152000)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x17566: 0x32 bytes; object byte +5 bit 1 set.
func create_ground_mark_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x32)
	memory.write_u32(ctl, obj)
	memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 2)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x188ba: 0x36 bytes; object long +4 |= 0x112000.
func create_shadow_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x36)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x112000)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x18b52: 0xfa bytes; word +0x46 = 0x3c, long +0x42 = 0x26ac0; object byte +5 bit 1 set.
func create_flak_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0xfa)
	memory.write_u32(ctl, obj)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u16(ctl + 0x46, 0x3c)
	memory.write_u32(ctl + 0x42, RANGE_0x26ac0)
	memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 2)
	return ctl

## 0x190c0: 0x54 bytes; object byte +5 bit 1 set, and bit 4 when long +0x1c (y) is 0; long
## +0x42 = 0xce40.
func create_turret_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x54)
	memory.write_u32(ctl, obj)
	memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 2)
	if memory.read_u32(obj + 0x1c) == 0:
		memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 0x10)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u32(ctl + 0x42, 0xce40)
	return ctl

## 0x193b6: 0x6be bytes; object long +4 |= 0x132000; pose ring at +0x32 filled with the
## object position.
func create_parachute_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x6be)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x132000)
	memory.write_u32(ctl + 4, _definition(def_key))
	fill_pose_history(ctl + 0x32, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
	return ctl

## 0x19a1a: 0x40 bytes; object long +4 |= 0x132000.
func create_cloud_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x40)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x132000)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## 0x19b82: 0x32 bytes; object long +4 |= 0x132000.
func create_view_attached_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x32)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x132000)
	memory.write_u32(ctl + 4, _definition(def_key))
	return ctl

## Effect initialisers (effect_init_table 0x1b40c, kinds 0..3). Each takes the effect object
## (+8 controller, +0x44 vertex longs, word +0x34 shift, +0x14 range): scale = (sext word ctl
## +0x34 asl 8) divs.l 100; selected vertex longs become muls.l(v asr (word +0x34), scale) asr 8
## (register shift counts mod 64, low long of the product); start velocities go to ctl +0x3a /
## +0x6e (/ +0xa2) + 4 * i (index scale 4 in the extension words); word +0x34 = 0 and +0x14 =
## muls.l(scale, +0x14) asr 8. "Halved" velocities are v asl 9 (or asl 8), plus 1 when negative
## (bpl), asr 1: a division by 2 rounded toward zero.
func _effect_scale_long(obj: int, address: int, scale: int) -> int:
	var v: int = C68kScript.asr32(memory.read_u32(address), memory.read_u16(obj + 0x34))
	v = C68kScript.asr32(C68kScript.s32(v * scale), 8)
	memory.write_u32(address, C68kScript.u32(v))
	return v

func _halve_toward_zero(v: int) -> int:
	v = C68kScript.s32(v)
	if v < 0:
		v = C68kScript.s32(v + 1)
	return C68kScript.asr32(v, 1)

func _effect_finish(obj: int, scale: int) -> void:
	memory.write_u16(obj + 0x34, 0)
	memory.write_u32(obj + 0x14, C68kScript.u32(C68kScript.asr32(C68kScript.s32(scale * memory.read_s32(obj + 0x14)), 8)))

func _effect_scale(ctl: int) -> int:
	return C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(ctl + 0x34) << 8), 100)

## Kind 0 (0x1203a): vertices 0..5, x / z (+0 / +8) scaled; velocity (v asl 9) / 2.
func init_effect_kind0_flat_ring(obj: int) -> void:
	assert(memory != null, "init_effect_kind0_flat_ring requires original global memory")
	var ctl: int = memory.read_u32(obj + 8)
	var scale: int = _effect_scale(ctl)
	var verts: int = memory.read_u32(obj + 0x44)
	var i: int = 0
	while i <= 5:
		var x: int = _effect_scale_long(obj, verts + i * 0xc, scale)
		var z: int = _effect_scale_long(obj, verts + i * 0xc + 8, scale)
		memory.write_u32(ctl + 0x3a + i * 4, C68kScript.u32(_halve_toward_zero(C68kScript.lsl32(x, 9))))
		memory.write_u32(ctl + 0x6e + i * 4, C68kScript.u32(_halve_toward_zero(C68kScript.lsl32(z, 9))))
		i = C68kScript.s16(i + 1)
	_effect_finish(obj, scale)

## Kind 1 (0x120ca): vertices 0, 1, 3 (2 skipped), x / z scaled; velocity (v asl 9) divs.l 3.
## Then vertex 2 y (+0x1c) = 0 and vertex 2's velocities: x (+0x42) = 0, z (+0x76) = ((5 *
## scale) asl 8) asr 8 (lea (a4,d3.l*4): the low 24 bits, sign-extended).
func init_effect_kind1_column(obj: int) -> void:
	assert(memory != null, "init_effect_kind1_column requires original global memory")
	var ctl: int = memory.read_u32(obj + 8)
	var scale: int = _effect_scale(ctl)
	var verts: int = memory.read_u32(obj + 0x44)
	var i: int = 0
	while i <= 3:
		if i != 2:
			var x: int = _effect_scale_long(obj, verts + i * 0xc, scale)
			var z: int = _effect_scale_long(obj, verts + i * 0xc + 8, scale)
			memory.write_u32(ctl + 0x3a + i * 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(x, 9)), 3)))
			memory.write_u32(ctl + 0x6e + i * 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(z, 9)), 3)))
		i = C68kScript.s16(i + 1)
	memory.write_u32(verts + 0x1c, 0)
	memory.write_u32(ctl + 0x42, 0)
	memory.write_u32(ctl + 0x76, C68kScript.u32(C68kScript.asr32(C68kScript.lsl32(C68kScript.s32(scale * 5), 8), 8)))
	_effect_finish(obj, scale)

## Kind 2 (0x11efc): phase = overlay_rng_next() & 1 (word); vertices 0..11, x / y (+0 / +4)
## scaled. For i <= 5 each velocity is ((v asl 1) - 0x3f + (rng & 0x7f)) asl 8, halved, and when
## (i + phase) is odd both are tripled (v + (v asl 1)); for i >= 6 it is ((v asl 1) - 0x1f +
## (rng & 0x3f)) asl 8, halved. One rng call per velocity, x first.
func init_effect_kind2_burst(obj: int) -> void:
	assert(memory != null, "init_effect_kind2_burst requires original global memory")
	var ctl: int = memory.read_u32(obj + 8)
	var scale: int = _effect_scale(ctl)
	var verts: int = memory.read_u32(obj + 0x44)
	var phase: int = overlay_rng_next() & 1
	var i: int = 0
	while i <= 0xb:
		var x: int = _effect_scale_long(obj, verts + i * 0xc, scale)
		var y: int = _effect_scale_long(obj, verts + i * 0xc + 4, scale)
		var mask: int = 0x3f
		var bias: int = 0x1f
		if i <= 5:
			mask = 0x7f
			bias = 0x3f
		var r: int = overlay_rng_next() & mask
		memory.write_u32(ctl + 0x3a + i * 4, C68kScript.u32(_halve_toward_zero(C68kScript.lsl32(C68kScript.lsl32(x, 1) - bias + r, 8))))
		r = overlay_rng_next() & mask
		memory.write_u32(ctl + 0x6e + i * 4, C68kScript.u32(_halve_toward_zero(C68kScript.lsl32(C68kScript.lsl32(y, 1) - bias + r, 8))))
		if i <= 5 and ((i + phase) & 1) != 0:
			for base in [0x3a, 0x6e]:
				var v: int = memory.read_u32(ctl + base + i * 4)
				memory.write_u32(ctl + base + i * 4, C68kScript.u32(v + C68kScript.lsl32(v, 1)))
		i = C68kScript.s16(i + 1)
	_effect_finish(obj, scale)

## Kind 3 (0x1217e): first spawn_effect(2, (sext word ctl +0x34 + 3 if negative) asr.w 2, 2, 0,
## 0, object x / y / z) (bsr.w, entered 0x3c below). Then vertices 0..12, x / y / z scaled;
## ctl +0x3a = (x asl 9) / 2, +0x6e = (y divs.l 6) asl 4, +0xa2 = (z asl 9) / 2, vertex y = 0;
## ctl word +0x36 = 0x7fff and, while replaying (word replay_state != 0), byte +0x33 |= 1.
func init_effect_kind3_debris_explosion(obj: int) -> void:
	assert(memory != null, "init_effect_kind3_debris_explosion requires original global memory")
	var ctl: int = memory.read_u32(obj + 8)
	var size: int = memory.read_s16(ctl + 0x34)
	if size < 0:
		size = C68kScript.s16(size + 3)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x3c
	spawn_effect(2, size >> 2, 2, 0, 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
	a7 = entry_a7
	var scale: int = _effect_scale(ctl)
	var verts: int = memory.read_u32(obj + 0x44)
	var i: int = 0
	while i <= 0xc:
		var x: int = _effect_scale_long(obj, verts + i * 0xc, scale)
		var y: int = _effect_scale_long(obj, verts + i * 0xc + 4, scale)
		var z: int = _effect_scale_long(obj, verts + i * 0xc + 8, scale)
		memory.write_u32(ctl + 0x3a + i * 4, C68kScript.u32(_halve_toward_zero(C68kScript.lsl32(x, 9))))
		memory.write_u32(ctl + 0x6e + i * 4, C68kScript.u32(C68kScript.lsl32(C68kScript.divs_trunc(y, 6), 4)))
		memory.write_u32(ctl + 0xa2 + i * 4, C68kScript.u32(_halve_toward_zero(C68kScript.lsl32(z, 9))))
		memory.write_u32(verts + i * 0xc + 4, 0)
		i = C68kScript.s16(i + 1)
	_effect_finish(obj, scale)
	memory.write_u16(ctl + 0x36, 0x7fff)
	if memory.read_s16(DAT_0001b870) != 0:
		memory.write_u8(ctl + 0x33, memory.read_u8(ctl + 0x33) | 1)

## 0xdff0: cleared 0x6b0-byte aircraft controller. Byte +0x67c (bombs) = 2, word +0x682 (ammo)
## = 0x2a3, word +0x614 = kind (low word of the third argument), +0 = object, +4 =
## DAT_0001b524[key]; word +0x634 = definition word +0x1a + (extb +0x67c asl 4) (word add);
## both tanks +0x67d / +0x67e = definition word +0x1c / 2 (rounded toward zero, asr.w); word
## +0x626 = definition word +0x42, word +0x630 = -0x5b, byte +0x679 = 0x2d (gear down); pose
## ring at +0x36 filled with the object position; object byte +5 bit 1 set.
func init_aircraft_controller(obj: int, def_key: int, kind: int) -> int:
	assert(memory != null, "init_aircraft_controller requires original global memory")
	var ctl: int = heap_alloc_cleared(0x6b0)
	memory.write_u8(ctl + 0x67c, 2)
	memory.write_u16(ctl + 0x682, 0x2a3)
	memory.write_u16(ctl + 0x614, C68kScript.u16(kind))
	memory.write_u32(ctl, obj)
	memory.write_u32(ctl + 4, _definition(def_key))
	var definition: int = memory.read_u32(ctl + 4)
	memory.write_u16(ctl + 0x634, C68kScript.u16((memory.read_s8(ctl + 0x67c) << 4) + memory.read_u16(definition + 0x1a)))
	for tank in [0x67d, 0x67e]:
		var fuel: int = memory.read_s16(definition + 0x1c)
		if fuel < 0:
			fuel = C68kScript.s16(fuel + 1)
		memory.write_u8(ctl + tank, C68kScript.u8(fuel >> 1))
	memory.write_u16(ctl + 0x626, memory.read_u16(definition + 0x42))
	memory.write_u16(ctl + 0x630, 0xffa5)
	memory.write_u8(ctl + 0x679, 0x2d)
	fill_pose_history(ctl + 0x36, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
	memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 2)
	return ctl

## Shared opening of the aircraft creators: byte +0x63e = 1 and long +0x2e = object long +0x1c
## - sext definition word +0x40 (suba.w).
func _aircraft_common(obj: int, ctl: int) -> void:
	memory.write_u8(ctl + 0x63e, 1)
	memory.write_u32(ctl + 0x2e, C68kScript.u32(memory.read_u32(obj + 0x1c) - memory.read_s16(memory.read_u32(ctl + 4) + 0x40)))

## 0xe0ce: init_aircraft_controller, then the first one becomes the player (player_object =
## ctl, +0x32 = 0xe772, word +0x684 |= 0x4000; bombs byte +0x67c = 6 in host mode word +0x90 ==
## 2, else the host's byte +0xb9 with word +0x634 moved by the difference * 16; both tanks
## scaled by host word +0xb6 percent (muls.l / divs.l 100), at least 1 in the left tank when
## both are empty; object long +4 |= 0x102140, +0xc = 1000000000). Others: +0x32 = 0x110d4,
## object long +4 |= 0x102100. Then spawn_object_shadow(x, 0, z, 1, obj), entered 0x24 below.
func aircraft_create(obj: int, def_key: int, kind: int) -> int:
	assert(memory != null, "aircraft_create requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	var ctl: int = init_aircraft_controller(obj, def_key, kind)
	a7 = entry_a7
	_aircraft_common(obj, ctl)
	if memory.read_u32(DAT_0001b738) == 0:
		memory.write_u32(DAT_0001b738, ctl)
		memory.write_u32(ctl + 0x32, 0xe772)
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x4000)
		var host: int = memory.read_u32(DAT_0001b5a0)
		if memory.read_s16(host + 0x90) == 2:
			memory.write_u8(ctl + 0x67c, 6)
		else:
			memory.write_u16(ctl + 0x634, C68kScript.u16(memory.read_u16(ctl + 0x634) - (memory.read_s8(ctl + 0x67c) << 4)))
			memory.write_u8(ctl + 0x67c, memory.read_u8(host + 0xb9))
			memory.write_u16(ctl + 0x634, C68kScript.u16(memory.read_u16(ctl + 0x634) + (memory.read_s8(ctl + 0x67c) << 4)))
		host = memory.read_u32(DAT_0001b5a0)
		var left: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s8(ctl + 0x67d) * memory.read_s16(host + 0xb6)), 100)
		memory.write_u8(ctl + 0x67d, C68kScript.u8(left))
		var right: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s8(ctl + 0x67e) * memory.read_s16(host + 0xb6)), 100)
		memory.write_u8(ctl + 0x67e, C68kScript.u8(right))
		if memory.read_u8(ctl + 0x67d) == 0 and C68kScript.u8(right) == 0:
			memory.write_u8(ctl + 0x67d, 1)
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x102140)
		memory.write_u32(obj + 0xc, 1000000000)
	else:
		memory.write_u32(ctl + 0x32, 0x110d4)
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x102100)
	a7 = entry_a7 - 0x24
	spawn_object_shadow(memory.read_u32(obj + 0x18), 0, memory.read_u32(obj + 0x20), 1, obj)
	a7 = entry_a7
	return ctl

## 0xe1e6: the first key-4 object while enemy_fighter_template is 0 becomes that template (no
## controller, returns 0). Otherwise init_aircraft_controller, +0x32 = 0x110d4, object long +4
## |= 0x102100 and spawn_object_shadow(x, 0, z, 2, obj), entered 0x30 below (the init
## arguments are still on the stack).
func create_enemy_fighter(obj: int, def_key: int, kind: int) -> int:
	assert(memory != null, "create_enemy_fighter requires original global memory")
	if memory.read_u32(DAT_00026000) == 0 and C68kScript.s32(def_key) == 4:
		memory.write_u32(DAT_00026000, obj)
		return 0
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	var ctl: int = init_aircraft_controller(obj, def_key, kind)
	_aircraft_common(obj, ctl)
	memory.write_u32(ctl + 0x32, 0x110d4)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x102100)
	a7 = entry_a7 - 0x30
	spawn_object_shadow(memory.read_u32(obj + 0x18), 0, memory.read_u32(obj + 0x20), 2, obj)
	a7 = entry_a7
	return ctl

## 0xe2a4: init_aircraft_controller, +0x32 = 0x1118e, word +0x682 (ammo) = 0, object long +4 |=
## 0x102100, bombs byte +0x67c = 8 (word +0x634 not adjusted), spawn_object_shadow(x, 0, z, 4,
## obj) (0x30 below), then spawn_turret_on_object(obj) (0x14 below): a gunner turret gets word
## +0x40 = 1, word +0x3e = 0x200, long +0x42 = 25000, its object byte +5 bit 0, and +0x692 =
## that object.
func create_friendly_bomber(obj: int, def_key: int, kind: int) -> int:
	assert(memory != null, "create_friendly_bomber requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	var ctl: int = init_aircraft_controller(obj, def_key, kind)
	_aircraft_common(obj, ctl)
	memory.write_u32(ctl + 0x32, 0x1118e)
	memory.write_u16(ctl + 0x682, 0)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x102100)
	memory.write_u8(ctl + 0x67c, 8)
	a7 = entry_a7 - 0x30
	spawn_object_shadow(memory.read_u32(obj + 0x18), 0, memory.read_u32(obj + 0x20), 4, obj)
	a7 = entry_a7 - 0x14
	var turret: int = spawn_turret_on_object(obj)
	a7 = entry_a7
	if turret != 0:
		memory.write_u16(turret + 0x40, 1)
		memory.write_u16(turret + 0x3e, 0x200)
		memory.write_u32(turret + 0x42, 25000)
		var turret_obj: int = memory.read_u32(turret)
		memory.write_u8(turret_obj + 5, memory.read_u8(turret_obj + 5) | 1)
		memory.write_u32(ctl + 0x692, memory.read_u32(turret))
	return ctl

## 0xe340: create_friendly_bomber (0x10 below), then the gunner turret's controller (object
## +0x692, its +8) gets word +0x3e = 0x100.
func create_enemy_bomber(obj: int, def_key: int, kind: int) -> int:
	assert(memory != null, "create_enemy_bomber requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x10
	var ctl: int = create_friendly_bomber(obj, def_key, kind)
	a7 = entry_a7
	if memory.read_u32(ctl + 0x692) != 0:
		memory.write_u16(memory.read_u32(memory.read_u32(ctl + 0x692) + 8) + 0x3e, 0x100)
	return ctl

## 0x18956: spawn_mission_pool_object(shadow_templates[kind], x, y, z, 0, 0, 0, 0) (0x2c below);
## null -> 0. The player's shadow (owner == *player_object) gets +0xc = 1000000000; with host
## word +0xb0 == 0 the shadow is hidden (long +4 |= 0x40). Its controller +0x32 = owner, owner
## byte +3 += 1; returns the controller.
func spawn_object_shadow(x: int, y: int, z: int, kind: int, owner: int) -> int:
	assert(memory != null, "spawn_object_shadow requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x2c
	var shadow: int = spawn_mission_pool_object(memory.read_u32(C68kScript.u32(DAT_00026768 + C68kScript.s32(kind) * 4)), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if shadow == 0:
		return 0
	if C68kScript.u32(owner) == memory.read_u32(memory.read_u32(DAT_0001b738)):
		memory.write_u32(shadow + 0xc, 1000000000)
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xb0) == 0:
		memory.write_u32(shadow + 4, memory.read_u32(shadow + 4) | 0x40)
	var ctl: int = memory.read_u32(shadow + 8)
	memory.write_u32(ctl + 0x32, owner)
	memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) + 1))
	return ctl

## 0x19130: spawn_mission_pool_object(turret_template, host x, y, z, 0, 0, 0, 0) (0x28 below);
## null -> 0. Its controller +0x32 = host, host byte +3 += 1, turret object word +6 &= 0xfbff;
## returns the controller.
func spawn_turret_on_object(host_obj: int) -> int:
	assert(memory != null, "spawn_turret_on_object requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x28
	var turret_obj: int = spawn_mission_pool_object(memory.read_u32(DAT_0002677c), memory.read_u32(host_obj + 0x18), memory.read_u32(host_obj + 0x1c), memory.read_u32(host_obj + 0x20), 0, 0, 0, 0)
	a7 = entry_a7
	if turret_obj == 0:
		return 0
	var ctl: int = memory.read_u32(turret_obj + 8)
	memory.write_u32(ctl + 0x32, host_obj)
	memory.write_u8(host_obj + 3, C68kScript.u8(memory.read_u8(host_obj + 3) + 1))
	memory.write_u16(turret_obj + 6, memory.read_u16(turret_obj + 6) & 0xfbff)
	return ctl

## Velocity decay used by the effect animators: v * 3 (asl.l #1 + add.l), plus 3 when the sum
## is negative (bpl), asr.l #2 - three quarters rounded toward zero.
func _three_quarters(v: int) -> int:
	var t: int = C68kScript.s32(C68kScript.lsl32(v, 1) + v)
	if t < 0:
		t = C68kScript.s32(t + 3)
	return C68kScript.asr32(t, 2)

## 0x123ce (Ghidra splits its loop tail off as FUN_00012466): finished (1) while rewinding
## (word replay_state == 1) or at lifetime 0. At lifetime 0x47 it spawns a kind-1 effect
## (sext words +0x34 / +0x36, 0, 0, object position; bsr.w entered 0x3c below). Then the six
## ring vertices move by velocity asr 8 in x / z and both velocities decay to 3/4; returns 0.
func animate_effect_kind0_ring(ctl: int) -> int:
	assert(memory != null, "animate_effect_kind0_ring requires original global memory")
	var obj: int = memory.read_u32(ctl)
	if memory.read_s16(DAT_0001b870) == 1 or memory.read_s16(ctl + 0x36) == 0:
		return 1
	if memory.read_s16(ctl + 0x36) == 0x47:
		var entry_a7: int = a7
		a7 = entry_a7 - 0x3c
		spawn_effect(1, memory.read_s16(ctl + 0x34), memory.read_s16(ctl + 0x36), 0, 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
		a7 = entry_a7
	var verts: int = memory.read_u32(obj + 0x44)
	var i: int = 0
	while i <= 5:
		for axis in [[0x3a, 0], [0x6e, 8]]:
			var vel: int = ctl + axis[0] + i * 4
			var coord: int = verts + i * 0xc + axis[1]
			memory.write_u32(coord, C68kScript.u32(memory.read_u32(coord) + C68kScript.asr32(memory.read_u32(vel), 8)))
		for base in [0x3a, 0x6e]:
			var vel2: int = ctl + base + i * 4
			memory.write_u32(vel2, C68kScript.u32(_three_quarters(memory.read_u32(vel2))))
		i = C68kScript.s16(i + 1)
	return 0

## 0x12486: finished (1) while rewinding or at lifetime 0. Otherwise the vertical velocity
## +0x76 loses 0x5b and vertex 2 y (+0x1c) moves by it asr 4; once that y is negative the
## effect is finished (1). Else vertices 0, 1, 3 move in x / z by velocity asr 8 and the
## velocities decay to 3/4; returns 0.
func animate_effect_kind1_column(ctl: int) -> int:
	assert(memory != null, "animate_effect_kind1_column requires original global memory")
	var obj: int = memory.read_u32(ctl)
	if memory.read_s16(DAT_0001b870) == 1 or memory.read_s16(ctl + 0x36) == 0:
		return 1
	var verts: int = memory.read_u32(obj + 0x44)
	memory.write_u32(ctl + 0x76, C68kScript.u32(memory.read_u32(ctl + 0x76) - 0x5b))
	var y: int = C68kScript.s32(C68kScript.asr32(memory.read_u32(ctl + 0x76), 4) + memory.read_u32(verts + 0x1c))
	memory.write_u32(verts + 0x1c, C68kScript.u32(y))
	if y < 0:
		return 1
	var i: int = 0
	while i <= 3:
		if i != 2:
			for axis in [[0x3a, 0], [0x6e, 8]]:
				var vel: int = ctl + axis[0] + i * 4
				var coord: int = verts + i * 0xc + axis[1]
				memory.write_u32(coord, C68kScript.u32(memory.read_u32(coord) + C68kScript.asr32(memory.read_u32(vel), 8)))
			for base in [0x3a, 0x6e]:
				var vel2: int = ctl + base + i * 4
				memory.write_u32(vel2, C68kScript.u32(_three_quarters(memory.read_u32(vel2))))
		i = C68kScript.s16(i + 1)
	return 0

## Darkens every face of an effect object at colour depth 8: bytes +0xc / +0xd / +0xe become c *
## factor asr 3 (unsigned bytes, so never negative); a face that owns its palette slot (palette
## owner table[byte +0xf] == face) rewrites it, any other gets byte +0xf = 0. Word +0x3a faces
## (dbra). The caller sets a7 to write_face_palette_slot's entry depth.
func _darken_effect_faces(obj: int, factor: int) -> void:
	var face: int = memory.read_u32(obj + 0x48)
	var left: int = memory.read_u16(obj + 0x3a)
	while true:
		left = C68kScript.u16(left - 1)
		if left == 0xffff:
			break
		for k in [0xc, 0xd, 0xe]:
			memory.write_u8(face + k, C68kScript.u8((memory.read_u8(face + k) * factor) >> 3))
		if memory.read_u32(memory.read_u32(DAT_0001da7c) + memory.read_u8(face + 0xf) * 4) == face:
			write_face_palette_slot(face)
		else:
			memory.write_u8(face + 0xf, 0)
		face += 0x20

## 0x12296: while rewinding or at lifetime 0 it is finished (1); at lifetime 0 with smoke byte
## +0x38 it first spawns spawn_smoke_plume(size * 3, size * 6, 0x2a3, 1, 0, position) (muls.w
## of word +0x34; entered 0x44 below). Otherwise the twelve vertices move by velocity asr 8 in
## x / y and the velocities halve toward zero; at view_depth 8 the faces darken by 6/8. Returns 0.
func animate_effect_kind2_burst(ctl: int) -> int:
	assert(memory != null, "animate_effect_kind2_burst requires original global memory")
	var obj: int = memory.read_u32(ctl)
	if memory.read_s16(DAT_0001b870) == 1 or memory.read_s16(ctl + 0x36) == 0:
		if memory.read_s16(ctl + 0x36) == 0 and memory.read_u8(ctl + 0x38) != 0:
			var size: int = memory.read_s16(ctl + 0x34)
			var entry_a7: int = a7
			a7 = entry_a7 - 0x44
			spawn_smoke_plume(size * 3, size * 6, 0x2a3, 1, 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
			a7 = entry_a7
		return 1
	var verts: int = memory.read_u32(obj + 0x44)
	var i: int = 0
	while i <= 0xb:
		for axis in [[0x3a, 0], [0x6e, 4]]:
			var vel: int = ctl + axis[0] + i * 4
			var coord: int = verts + i * 0xc + axis[1]
			memory.write_u32(coord, C68kScript.u32(memory.read_u32(coord) + C68kScript.asr32(memory.read_u32(vel), 8)))
			memory.write_u32(vel, C68kScript.u32(_halve_toward_zero(memory.read_u32(vel))))
		i = C68kScript.s16(i + 1)
	if memory.read_s16(DAT_0001b826) == 8:
		var entry_a7b: int = a7
		a7 = entry_a7b - 0x28
		_darken_effect_faces(obj, 6)
		a7 = entry_a7b
	return 0

## 0x12528: debris. Byte +0x33 bit 0 marks debris spawned while replaying: it is finished (1)
## on rewind (replay_state 1). Live debris is hidden (long +4 |= 0x40) and idle (0) while any
## replay runs, else shown again. Then for vertices 0..11: y velocity (+0x6e) -= 0x5b, x += x
## velocity asr 8, y += y velocity asr 4 (clamped at 0), z += z velocity (+0xa2) asr 8; a
## vertex with y > 0 keeps the effect airborne; x / z velocities decay to 3/4. Vertex 12 y =
## vertex 2 y * 3/2 (halved toward zero, plus itself). Host word +0xe == 8 darkens the faces by
## 7/8. Airborne -> 0. Landed: replay debris is finished unless replay_state is 3 (0); live
## debris spawns spawn_ground_mark(vertex 1 z, x, 0, z) when the object lies at y 0 (0x40
## below) and, with smoke byte +0x38, spawn_smoke_plume(s / 2, s, 0x2a3, 1, 0, position) with s
## = word(low word of vertex 1 z + vertex 1 z halved) (0x50 below); finished (1).
func animate_effect_kind3_debris(ctl: int) -> int:
	assert(memory != null, "animate_effect_kind3_debris requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	var depth: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe)
	var verts: int = memory.read_u32(obj + 0x44)
	var replay_debris: bool = (memory.read_u8(ctl + 0x33) & 1) != 0
	if replay_debris:
		if memory.read_s16(DAT_0001b870) == 1:
			return 1
	elif memory.read_s16(DAT_0001b870) != 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
		return 0
	else:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)
	var airborne: bool = false
	var i: int = 0
	while i <= 0xb:
		var vy: int = ctl + 0x6e + i * 4
		memory.write_u32(vy, C68kScript.u32(memory.read_u32(vy) - 0x5b))
		var v: int = verts + i * 0xc
		memory.write_u32(v, C68kScript.u32(memory.read_u32(v) + C68kScript.asr32(memory.read_u32(ctl + 0x3a + i * 4), 8)))
		var y: int = C68kScript.s32(C68kScript.asr32(memory.read_u32(vy), 4) + memory.read_u32(v + 4))
		memory.write_u32(v + 4, C68kScript.u32(y))
		if y < 0:
			memory.write_u32(v + 4, 0)
		memory.write_u32(v + 8, C68kScript.u32(memory.read_u32(v + 8) + C68kScript.asr32(memory.read_u32(ctl + 0xa2 + i * 4), 8)))
		if memory.read_s32(v + 4) > 0:
			airborne = true
		for base in [0x3a, 0xa2]:
			var vel: int = ctl + base + i * 4
			memory.write_u32(vel, C68kScript.u32(_three_quarters(memory.read_u32(vel))))
		i = C68kScript.s16(i + 1)
	memory.write_u32(verts + 0x94, C68kScript.u32(_halve_toward_zero(memory.read_u32(verts + 0x1c)) + memory.read_u32(verts + 0x1c)))
	if depth == 8:
		a7 = entry_a7 - 0x34
		_darken_effect_faces(obj, 7)
		a7 = entry_a7
	if airborne:
		return 0
	if replay_debris:
		return 0 if memory.read_s16(DAT_0001b870) == 3 else 1
	if memory.read_u32(obj + 0x1c) == 0:
		a7 = entry_a7 - 0x40
		spawn_ground_mark(memory.read_u32(verts + 0x14), memory.read_u32(obj + 0x18), 0, memory.read_u32(obj + 0x20))
		a7 = entry_a7
	if memory.read_u8(ctl + 0x38) != 0:
		var s_word: int = C68kScript.s16(memory.read_u16(verts + 0x16) + _halve_toward_zero(memory.read_u32(verts + 0x14)))
		var half: int = s_word
		if half < 0:
			half = C68kScript.s16(half + 1)
		a7 = entry_a7 - 0x50
		spawn_smoke_plume(half >> 1, s_word, 0x2a3, 1, 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20))
		a7 = entry_a7
	return 1

## 0x12768: D0 = effect_anim_table[byte +0x32](ctl) (jsr, entered 0xc below); lifetime word
## +0x36 counts down, at 0 the object is hidden (long +4 |= 0x40) instead; a non-zero animator
## word retires the object (retire_entity, 0xc below, with that D0).
func tick_effect(ctl: int) -> void:
	assert(memory != null, "tick_effect requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0xc
	var d0: int = C68kScript.u32(_jsr(memory.read_u32(DAT_0001b41c + memory.read_u8(ctl + 0x32) * 4), [ctl]))
	a7 = entry_a7
	if memory.read_u16(ctl + 0x36) != 0:
		memory.write_u16(ctl + 0x36, C68kScript.u16(memory.read_u16(ctl + 0x36) - 1))
	else:
		var obj: int = memory.read_u32(ctl)
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
	if (d0 & 0xffff) != 0:
		a7 = entry_a7 - 0xc
		retire_entity(memory.read_u32(ctl), d0)
		a7 = entry_a7

## 0x115fc: spawn_mission_pool_object(smoke_template, x, y, z, 0, 0, 0, 0) (0x28 below); null ->
## 0. Its controller: word +0x36 = size_a asl (sext word object +0x34), word +0x34 = size_b asl
## the same, word +0x32 = the low word of the fourth argument, long +0x38 = duration +
## frame_counter. The fifth argument is not read. Returns the controller.
func spawn_smoke_plume(size_a: int, size_b: int, duration: int, word_32: int, _unused: int, x: int, y: int, z: int) -> int:
	assert(memory != null, "spawn_smoke_plume requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x28
	var spawned: int = spawn_mission_pool_object(memory.read_u32(DAT_000260e8), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if spawned == 0:
		return 0
	var ctl: int = memory.read_u32(spawned + 8)
	memory.write_u16(ctl + 0x36, C68kScript.u16(C68kScript.lsl32(size_a, memory.read_s16(spawned + 0x34))))
	memory.write_u16(ctl + 0x34, C68kScript.u16(C68kScript.lsl32(size_b, memory.read_s16(spawned + 0x34))))
	memory.write_u16(ctl + 0x32, C68kScript.u16(word_32))
	memory.write_u32(ctl + 0x38, C68kScript.u32(duration + memory.read_u32(DAT_0001b838)))
	return ctl

## 0x175de: spawn_mission_pool_object(ground_mark_template, x, y, z, 0, 0, 0, 0) (0x44 below);
## null -> 0. scale = (size_pct asl 8) divs.l 100; each of the six vertices moves toward its
## spawn point: c = origin + (muls.l((c asr word +0x34) - origin, scale) asr 8) per axis. Word
## +0x34 = 0, +0x14 = muls.l(scale, +0x14) asr 8, +0x3c = frame_counter + 0xa8c; returns the
## controller (+8).
func spawn_ground_mark(size_pct: int, x: int, y: int, z: int) -> int:
	assert(memory != null, "spawn_ground_mark requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x44
	var obj: int = spawn_mission_pool_object(memory.read_u32(DAT_00026660), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var scale: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(size_pct, 8)), 100)
	var verts: int = memory.read_u32(obj + 0x44)
	var origin := [C68kScript.s32(x), C68kScript.s32(y), C68kScript.s32(z)]
	var i: int = 0
	while i <= 5:
		for k in range(3):
			var c: int = verts + i * 0xc + 4 * k
			var d: int = C68kScript.s32(C68kScript.asr32(memory.read_u32(c), memory.read_u16(obj + 0x34)) - origin[k])
			memory.write_u32(c, C68kScript.u32(C68kScript.asr32(C68kScript.s32(d * scale), 8) + origin[k]))
		i = C68kScript.s16(i + 1)
	memory.write_u16(obj + 0x34, 0)
	memory.write_u32(obj + 0x14, C68kScript.u32(C68kScript.asr32(C68kScript.s32(scale * memory.read_s32(obj + 0x14)), 8)))
	memory.write_u32(obj + 0x3c, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0xa8c))
	return memory.read_u32(obj + 8)

## Controller tick handlers. None of them sets D0 before retire_entity, so the caller's D0
## passes through (d0_in).

## 0x175c0: retires the ground mark once its expiry frame (object long +0x3c) is reached
## (signed, <= frame_counter); retire_entity entered 8 below.
func tick_ground_mark(ctl: int, d0_in: int = 0) -> void:
	assert(memory != null, "tick_ground_mark requires original global memory")
	var obj: int = memory.read_u32(ctl)
	if memory.read_s32(obj + 0x3c) <= memory.read_s32(DAT_0001b838):
		var entry_a7: int = a7
		a7 = entry_a7 - 8
		retire_entity(obj, d0_in)
		a7 = entry_a7

## 0x19bbc: controller +8 / +0xc / +0x10 = camera - (object position + (0xdff, -0x133e,
## 0x161d)); words +0x22 / +0x20 = negated neg_camera_heading / neg_camera_pitch & 0x3fff.
func tick_view_attached_object(ctl: int) -> void:
	assert(memory != null, "tick_view_attached_object requires original global memory")
	var obj: int = memory.read_u32(ctl)
	memory.write_u32(ctl + 8, C68kScript.u32(memory.read_u32(DAT_0001d838) - (memory.read_u32(obj + 0x18) + 0xdff)))
	memory.write_u32(ctl + 0xc, C68kScript.u32(memory.read_u32(DAT_0001d834) - (memory.read_u32(obj + 0x1c) - 0x133e)))
	memory.write_u32(ctl + 0x10, C68kScript.u32(memory.read_u32(DAT_0001d830) - (memory.read_u32(obj + 0x20) + 0x161d)))
	memory.write_u16(ctl + 0x22, C68kScript.u16(-memory.read_u16(DAT_0001d80e)) & 0x3fff)
	memory.write_u16(ctl + 0x20, C68kScript.u16(-memory.read_u16(DAT_0001d810)) & 0x3fff)

## 0x189d0: a shadow follows its owner (+0x32): x / z = owner position + owner controller +8 /
## +0x10, y = owner controller +0x2e (ground height), word +0x22 = owner controller word +0x22.
## When the owner is retired (byte +7 bit 1) and its controller's +0 cleared, the shadow is
## retired (0x14 below), the owner's reference count byte +3 drops and +0x32 = 0.
func tick_shadow(ctl: int, d0_in: int = 0) -> void:
	assert(memory != null, "tick_shadow requires original global memory")
	var obj: int = memory.read_u32(ctl)
	var owner: int = memory.read_u32(ctl + 0x32)
	var owner_ctl: int = memory.read_u32(owner + 8)
	if (memory.read_u8(owner + 7) & 2) != 0 and memory.read_u32(owner_ctl) == 0:
		var entry_a7: int = a7
		a7 = entry_a7 - 0x14
		retire_entity(obj, d0_in)
		a7 = entry_a7
		memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) - 1))
		memory.write_u32(ctl + 0x32, 0)
		return
	memory.write_u32(obj + 0x18, C68kScript.u32(memory.read_u32(memory.read_u32(ctl + 0x32) + 0x18) + memory.read_u32(owner_ctl + 8)))
	memory.write_u32(obj + 0x1c, memory.read_u32(owner_ctl + 0x2e))
	memory.write_u32(obj + 0x20, C68kScript.u32(memory.read_u32(memory.read_u32(ctl + 0x32) + 0x20) + memory.read_u32(owner_ctl + 0x10)))
	memory.write_u16(ctl + 0x22, memory.read_u16(owner_ctl + 0x22))

## 0x174c4: the fragment spins (words +0x20 / +0x22 / +0x24 += 0x400 / 0x200 / 0x100, & 0x3fff)
## and falls (word +0x36 -= 0x5b, long +0xc = sext(word +0x36 asr.w 4)). In replay state 3 a
## present object saves its position to +0x14 / +0x18 / +0x1c and moves by +8 / +0xc / +0x10.
## It is retired (8 below) at its end frame (long +0x32 == frame_counter) or once its y is at
## or below the floor long +0x2e (signed).
func tick_debris_fragment(ctl: int, d0_in: int = 0) -> void:
	assert(memory != null, "tick_debris_fragment requires original global memory")
	var obj: int = memory.read_u32(ctl)
	for spin in [[0x20, 0x400], [0x22, 0x200], [0x24, 0x100]]:
		memory.write_u16(ctl + spin[0], (memory.read_u16(ctl + spin[0]) + spin[1]) & 0x3fff)
	memory.write_u16(ctl + 0x36, C68kScript.u16(memory.read_u16(ctl + 0x36) - 0x5b))
	memory.write_u32(ctl + 0xc, C68kScript.u32(memory.read_s16(ctl + 0x36) >> 4))
	if memory.read_s16(DAT_0001b870) == 3 and obj != 0:
		memory.write_u32(ctl + 0x14, memory.read_u32(obj + 0x18))
		memory.write_u32(ctl + 0x18, memory.read_u32(obj + 0x1c))
		memory.write_u32(ctl + 0x1c, memory.read_u32(obj + 0x20))
		memory.write_u32(obj + 0x18, C68kScript.u32(memory.read_u32(obj + 0x18) + memory.read_u32(ctl + 8)))
		memory.write_u32(obj + 0x1c, C68kScript.u32(memory.read_u32(obj + 0x1c) + memory.read_u32(ctl + 0xc)))
		memory.write_u32(obj + 0x20, C68kScript.u32(memory.read_u32(obj + 0x20) + memory.read_u32(ctl + 0x10)))
	if memory.read_u32(ctl + 0x32) == memory.read_u32(DAT_0001b838) or memory.read_s32(obj + 0x1c) <= memory.read_s32(ctl + 0x2e):
		var entry_a7: int = a7
		a7 = entry_a7 - 8
		retire_entity(obj, d0_in)
		a7 = entry_a7

## 0x116fc: an ownerless plume (+0x3c == 0) is retired at its end frame (+0x38 ==
## frame_counter). An owned plume follows its aircraft while the owner is live (byte +7 bit 1
## clear), bit 0 of its controller's byte +0x684 (the high byte of that word, so word bit 8) is
## set and no rewind runs: ring index word +0xa0 = (index - 1) & 7, ring point +0x40 + 12 * index = owner
## position, +8 / +0xc / +0x10 = owner position - plume object position. Otherwise it is
## retired (0xc below).
func tick_smoke_plume(plume: int, d0_in: int = 0) -> void:
	assert(memory != null, "tick_smoke_plume requires original global memory")
	var owner: int = memory.read_u32(plume + 0x3c)
	if owner == 0:
		if memory.read_u32(plume + 0x38) != memory.read_u32(DAT_0001b838):
			return
	elif (memory.read_u8(owner + 7) & 2) == 0 and (memory.read_u8(memory.read_u32(owner + 8) + 0x684) & 1) != 0 and memory.read_s16(DAT_0001b870) != 1:
		var ring_i: int = (memory.read_u16(plume + 0xa0) - 1) & 7
		memory.write_u16(plume + 0xa0, ring_i)
		var point: int = plume + 0x40 + ring_i * 12
		for k in range(3):
			memory.write_u32(point + 4 * k, memory.read_u32(owner + 0x18 + 4 * k))
		var plume_obj: int = memory.read_u32(plume)
		for k in range(3):
			memory.write_u32(plume + 8 + 4 * k, C68kScript.u32(memory.read_u32(owner + 0x18 + 4 * k) - memory.read_u32(plume_obj + 0x18 + 4 * k)))
		return
	var entry_a7: int = a7
	a7 = entry_a7 - 0xc
	retire_entity(memory.read_u32(plume), d0_in)
	a7 = entry_a7

## 0x17150: ground fire burning around the owner (+0x50). speed = |owner controller +8| +
## |+0x10| (abs_int). A retired owner (byte +7 bit 1) or zero speed ends it (state word +0x34 =
## 3, and a state-1 fire also clears its timer +0x32); a rewind (replay_state 1) ends any fire
## not in state 1. State 3: timer counts down, finished (1) at 0 or on rewind, else 0. State 1
## shows the object (long +4 &= ~0x40) and becomes 2. State 2 (and 1): for vertices 0..3, low
## bit first of mask word +0x4e (asr.w per vertex): an attached vertex sits beside the owner,
## across its velocity - x = owner x + word((vz asl 5) divs.l speed), z = owner z + word((-vx
## asl 5) divs.l speed) for vertices 2 / 3, the opposite side for 0 / 1, y 0 - and stores those
## offsets / 8 (toward zero) as drift words +0x36 / +0x46; a detached vertex drifts by them.
## Vertex 4 = the mean of x and z (y 0). Then: owner damage word +0x684 & 0x1800 == 0 detaches
## all four; else unless vertices 0 and 3 are both detached, one of them detaches (rng bit 0:
## vertex 0, else vertex 3). All four detached -> state 3. Returns 0 (ext.l of a word).
func animate_ground_fire(ctl: int) -> int:
	assert(memory != null, "animate_ground_fire requires original global memory")
	var fire_obj: int = memory.read_u32(ctl)
	var owner: int = memory.read_u32(ctl + 0x50)
	var owner_ctl: int = memory.read_u32(owner + 8)
	var speed: int = C68kScript.s32(abs_int(memory.read_s32(owner_ctl + 8)) + abs_int(memory.read_s32(owner_ctl + 0x10)))
	if (memory.read_u8(owner + 7) & 2) != 0 or speed == 0:
		if memory.read_s16(ctl + 0x34) == 1:
			memory.write_u16(ctl + 0x32, 0)
		memory.write_u16(ctl + 0x34, 3)
	if memory.read_s16(DAT_0001b870) == 1 and memory.read_s16(ctl + 0x34) != 1:
		memory.write_u16(ctl + 0x34, 3)
	var state: int = memory.read_s16(ctl + 0x34)
	if state == 3:
		if memory.read_u16(ctl + 0x32) != 0:
			memory.write_u16(ctl + 0x32, C68kScript.u16(memory.read_u16(ctl + 0x32) - 1))
		if memory.read_u16(ctl + 0x32) == 0 or memory.read_s16(DAT_0001b870) == 1:
			return 1
		return 0
	if state == 1:
		memory.write_u16(ctl + 0x34, 2)
		memory.write_u32(fire_obj + 4, memory.read_u32(fire_obj + 4) & 0xffffffbf)
	elif state != 2:
		return 0
	var verts: int = memory.read_u32(fire_obj + 0x44)
	var mask: int = memory.read_s16(ctl + 0x4e)
	var sum_x: int = 0
	var sum_z: int = 0
	var v: int = 0
	while v <= 3:
		var p: int = verts + v * 0xc
		if (mask & 1) == 0:
			var vx: int = memory.read_s32(owner_ctl + 8)
			var vz: int = memory.read_s32(owner_ctl + 0x10)
			var off_x: int
			var across: int
			if v == 2 or v == 3:
				off_x = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(vz, 5)), speed))
				across = C68kScript.s32(-vx)
			else:
				off_x = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.s32(-vz), 5)), speed))
				across = vx
			var off_z: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(across, 5)), speed))
			memory.write_u32(p, C68kScript.u32(off_x + memory.read_u32(owner + 0x18)))
			memory.write_u32(p + 4, 0)
			memory.write_u32(p + 8, C68kScript.u32(off_z + memory.read_u32(owner + 0x20)))
			for drift in [[0x36, off_x], [0x46, off_z]]:
				var d: int = drift[1]
				if d < 0:
					d = C68kScript.s16(d + 7)
				memory.write_u16(ctl + drift[0] + v * 2, C68kScript.u16(d >> 3))
		else:
			memory.write_u32(p, C68kScript.u32(memory.read_s16(ctl + 0x36 + v * 2) + memory.read_u32(p)))
			memory.write_u32(p + 8, C68kScript.u32(memory.read_s16(ctl + 0x46 + v * 2) + memory.read_u32(p + 8)))
		sum_x = C68kScript.s32(sum_x + memory.read_u32(p))
		sum_z = C68kScript.s32(sum_z + memory.read_u32(p + 8))
		v += 1
		mask = mask >> 1
	for centre in [[0x30, sum_x], [0x38, sum_z]]:
		var c: int = centre[1]
		if c < 0:
			c = C68kScript.s32(c + 3)
		memory.write_u32(verts + centre[0], C68kScript.u32(c >> 2))
	memory.write_u32(verts + 0x34, 0)
	var detached: int = memory.read_u16(ctl + 0x4e)
	if (memory.read_u16(owner_ctl + 0x684) & 0x1800) == 0:
		detached = detached | 0xf
	elif (detached & 9) != 9:
		if (overlay_rng_next() & 1) != 0:
			detached = detached | 1
		else:
			detached = detached | 8
	memory.write_u16(ctl + 0x4e, detached)
	if detached == 0xf:
		memory.write_u16(ctl + 0x34, 3)
	return 0

## 0x17380: animate_ground_fire (bsr.w, 0xc below); a non-zero word result retires the object
## (0xc below, with that D0).
func tick_ground_fire(ctl: int) -> void:
	assert(memory != null, "tick_ground_fire requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0xc
	var d0: int = animate_ground_fire(ctl)
	if (d0 & 0xffff) != 0:
		retire_entity(memory.read_u32(ctl), d0)
	a7 = entry_a7

## Trails: a four-vertex ribbon that follows its owner aircraft (+0x52) while its vertices are
## attached (mask word +0x50, bit v = vertex v detached), lifetime word +0x34, state word +0x36.

## 0x16ac4 / 0x16ad6 (identical): lifetime 0x4b, state 1. The object argument is not read.
func init_trail_kind0(_obj: int, ctl: int) -> void:
	memory.write_u16(ctl + 0x34, 0x4b)
	memory.write_u16(ctl + 0x36, 1)

func init_trail_kind1(_obj: int, ctl: int) -> void:
	memory.write_u16(ctl + 0x34, 0x4b)
	memory.write_u16(ctl + 0x36, 1)

## 0x16ae8: spawn_mission_pool_object(trail_templates[kind], x, y, z, 0, 0, 0, 0) (0x30 below);
## null -> 0. Controller word +0x32 = kind, then trail_init_table[kind](obj, ctl) (jsr, 0x18
## below); returns the controller.
func spawn_trail(kind: int, x: int, y: int, z: int) -> int:
	assert(memory != null, "spawn_trail requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x30
	var obj: int = spawn_mission_pool_object(memory.read_u32(C68kScript.u32(DAT_00026650 + C68kScript.s32(kind) * 4)), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var ctl: int = memory.read_u32(obj + 8)
	memory.write_u16(ctl + 0x32, C68kScript.u16(kind))
	a7 = entry_a7 - 0x18
	_jsr(memory.read_u32(C68kScript.u32(DAT_0001b50c + C68kScript.s32(kind) * 4)), [obj, ctl])
	a7 = entry_a7
	return ctl

## 0x16b4c: a smoke trail (kind 0, spawn_trail 0x1c below) for owner_ctl's aircraft: word +0x32
## = 0, +0x52 = the aircraft object, word +0x56 = 1 (counted), owner_ctl word +0x68c += 1, the
## aircraft's reference byte +3 += 1, then one tick_trail (0x10 below). Returns the trail.
func attach_smoke_trail(x: int, y: int, z: int, owner_ctl: int) -> int:
	assert(memory != null, "attach_smoke_trail requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	var trail: int = spawn_trail(0, x, y, z)
	a7 = entry_a7
	if trail == 0:
		return 0
	memory.write_u16(trail + 0x32, 0)
	memory.write_u32(trail + 0x52, memory.read_u32(owner_ctl))
	memory.write_u16(trail + 0x56, 1)
	memory.write_u16(owner_ctl + 0x68c, C68kScript.u16(memory.read_u16(owner_ctl + 0x68c) + 1))
	var owner: int = memory.read_u32(owner_ctl)
	memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) + 1))
	a7 = entry_a7 - 0x10
	tick_trail(trail)
	a7 = entry_a7
	return trail

## 0x16b9e: a burning trail (kind 1, spawn_trail 0x28 below): word +0x32 = 1, +0x52 = the
## aircraft, word +0x56 = 1, its reference byte +3 += 1 (no +0x68c count), one tick_trail (0x1c
## below); then the explosion sound by camera distance (<= 4999 -> word 0x1b84a = 0x1e, else
## <= 19999 -> word 0x1b848 = 0xf). Returns the trail.
func attach_burning_trail(x: int, y: int, z: int, owner_ctl: int) -> int:
	assert(memory != null, "attach_burning_trail requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x28
	var trail: int = spawn_trail(1, x, y, z)
	a7 = entry_a7
	if trail == 0:
		return 0
	memory.write_u16(trail + 0x32, 1)
	memory.write_u32(trail + 0x52, memory.read_u32(owner_ctl))
	memory.write_u16(trail + 0x56, 1)
	var owner: int = memory.read_u32(owner_ctl)
	memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) + 1))
	a7 = entry_a7 - 0x1c
	tick_trail(trail)
	a7 = entry_a7
	var dist: int = compute_camera_abs_metric(x, y, z)
	if dist <= 0x1387:
		memory.write_u16(DAT_0001b84a, 0x1e)
	elif dist <= 0x4e1f:
		memory.write_u16(DAT_0001b848, 0xf)
	return trail

## 0x16c24: releases a trail's owner references: kind 0 drops the owner's byte +3 and, while
## counted (word +0x56), its controller's word +0x68c; kind 1 only drops byte +3.
func destroy_trail_controller(ctl: int) -> void:
	assert(memory != null, "destroy_trail_controller requires original global memory")
	var kind: int = memory.read_s16(ctl + 0x32)
	var owner: int = memory.read_u32(ctl + 0x52)
	if kind == 0:
		if owner != 0:
			memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) - 1))
			if memory.read_u16(ctl + 0x56) != 0:
				var count: int = memory.read_u32(owner + 8) + 0x68c
				memory.write_u16(count, C68kScript.u16(memory.read_u16(count) - 1))
	elif kind == 1 and owner != 0:
		memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) - 1))

## Attached ribbon vertices sit at the owner's position, y offset by +dy for vertices 1 / 2 and
## -dy for 0 / 3 (low bit of the mask first, asr.w per vertex).
func _place_trail_vertices(verts: int, owner: int, mask: int, dy: int) -> void:
	var v: int = 0
	while v <= 3:
		if (mask & 1) == 0:
			var off: int = dy if (v == 1 or v == 2) else -dy
			var p: int = verts + v * 0xc
			memory.write_u32(p, memory.read_u32(owner + 0x18))
			memory.write_u32(p + 4, C68kScript.u32(off + memory.read_u32(owner + 0x1c)))
			memory.write_u32(p + 8, memory.read_u32(owner + 0x20))
		v += 1
		mask = C68kScript.s16(mask) >> 1

## The detach coin shared by both animators: with vertices 0 and 1 both detached, rng bit 0
## detaches vertex 2 (set) or 3 (clear); otherwise vertex 0 (set) or 1 (clear).
func _detach_trail_vertex(mask: int) -> int:
	if (mask & 3) == 3:
		return mask | (4 if (overlay_rng_next() & 1) != 0 else 8)
	return mask | (1 if (overlay_rng_next() & 1) != 0 else 2)

## 0x16c6a (kind 0): an owner that is retired or no longer smoking (damage word +0x684 &
## 0x3c0 == 0) releases the trail (state 4; a state-1 trail also loses its lifetime); a rewind
## releases any trail not in state 1. States (sext word, 1..4 by jump table): 1 -> 2; 2: ribbon
## +-0x22 follows the owner; when nothing is detached, or rng & 3 == 0, one more vertex
## detaches; all four detached or lifetime 0 -> released, state 3. 3: one rng draw (& 0x1f
## while byte +0x685 of the owner controller is negative, else & 3); 0 attaches a fresh smoke
## trail (0x38 below) and this one goes to state 4. 4: finished (1) at lifetime 0 or on rewind.
## Releasing drops the owner controller's trail count word +0x68c and clears word +0x56.
func animate_smoke_trail(ctl: int) -> int:
	assert(memory != null, "animate_smoke_trail requires original global memory")
	var trail_obj: int = memory.read_u32(ctl)
	var release: bool = false
	var finished: int = 0
	var owner: int = memory.read_u32(ctl + 0x52)
	var owner_ctl: int = memory.read_u32(owner + 8)
	if (memory.read_u8(owner + 7) & 2) != 0 or (memory.read_u16(owner_ctl + 0x684) & 0x3c0) == 0:
		if memory.read_s16(ctl + 0x36) == 1:
			memory.write_u16(ctl + 0x34, 0)
		release = true
		memory.write_u16(ctl + 0x36, 4)
	if memory.read_s16(DAT_0001b870) == 1 and memory.read_s16(ctl + 0x36) != 1:
		release = true
		memory.write_u16(ctl + 0x36, 4)
	var state: int = memory.read_s16(ctl + 0x36)
	if state == 1 or state == 2:
		if state == 1:
			memory.write_u16(ctl + 0x36, 2)
		_place_trail_vertices(memory.read_u32(trail_obj + 0x44), owner, memory.read_u16(ctl + 0x50), 0x22)
		var mask: int = memory.read_u16(ctl + 0x50)
		if mask == 0 or (overlay_rng_next() & 3) == 0:
			mask = _detach_trail_vertex(mask)
		memory.write_u16(ctl + 0x50, mask)
		if mask == 0xf or memory.read_u16(ctl + 0x34) == 0:
			release = true
			memory.write_u16(ctl + 0x36, 3)
	elif state == 3:
		var draw: int
		if memory.read_s8(owner_ctl + 0x685) < 0:
			draw = overlay_rng_next() & 0x1f
		else:
			draw = overlay_rng_next() & 3
		if draw == 0:
			var entry_a7: int = a7
			a7 = entry_a7 - 0x38
			attach_smoke_trail(memory.read_u32(owner + 0x18), memory.read_u32(owner + 0x1c), memory.read_u32(owner + 0x20), owner_ctl)
			a7 = entry_a7
			memory.write_u16(ctl + 0x36, 4)
	elif state == 4:
		if memory.read_u16(ctl + 0x34) == 0 or memory.read_s16(DAT_0001b870) == 1:
			finished = 1
	if release:
		memory.write_u16(owner_ctl + 0x68c, C68kScript.u16(memory.read_u16(owner_ctl + 0x68c) - 1))
		memory.write_u16(ctl + 0x56, 0)
	return finished

## 0x16e06 (kind 1): a retired owner releases the trail (state 4; a state-1 trail also loses
## its lifetime); a rewind releases any trail not in state 1. State 1 -> 2; 2: ribbon +-100
## follows the owner; when nothing is detached, or rng bit 0 is clear, one more vertex detaches;
## all detached or lifetime 0 -> released, state 4. State 4: finished (1) at lifetime 0 or on
## rewind. Every state then lets detached vertices drift (y +4 for 1 / 2, -4 for 0 / 3) using
## the mask as it now stands. Lifetime <= 0x3b hides face 1 (byte +0x33 of the face records);
## above, vertices 4..7 = centre + (vertex - centre) / 2 toward zero, centre = sum asr 2 per
## axis. Releasing only clears word +0x56.
func animate_burning_trail(ctl: int) -> int:
	assert(memory != null, "animate_burning_trail requires original global memory")
	var trail_obj: int = memory.read_u32(ctl)
	var release: bool = false
	var finished: int = 0
	var owner: int = memory.read_u32(ctl + 0x52)
	var verts: int = memory.read_u32(trail_obj + 0x44)
	var mask: int = memory.read_u16(ctl + 0x50)
	if (memory.read_u8(owner + 7) & 2) != 0:
		if memory.read_s16(ctl + 0x36) == 1:
			memory.write_u16(ctl + 0x34, 0)
		release = true
		memory.write_u16(ctl + 0x36, 4)
	if memory.read_s16(DAT_0001b870) == 1 and memory.read_s16(ctl + 0x36) != 1:
		release = true
		memory.write_u16(ctl + 0x36, 4)
	var state: int = memory.read_s16(ctl + 0x36)
	if state == 1 or state == 2:
		if state == 1:
			memory.write_u16(ctl + 0x36, 2)
		_place_trail_vertices(verts, owner, mask, 100)
		mask = memory.read_u16(ctl + 0x50)
		if mask == 0 or (overlay_rng_next() & 1) == 0:
			mask = _detach_trail_vertex(mask)
		memory.write_u16(ctl + 0x50, mask)
		if mask == 0xf or memory.read_u16(ctl + 0x34) == 0:
			release = true
			memory.write_u16(ctl + 0x36, 4)
	elif state == 4:
		if memory.read_u16(ctl + 0x34) == 0 or memory.read_s16(DAT_0001b870) == 1:
			finished = 1
	var v: int = 0
	var drift: int = mask
	while v <= 3:
		if (drift & 1) != 0:
			var y: int = verts + v * 0xc + 4
			memory.write_u32(y, C68kScript.u32(memory.read_u32(y) + (4 if (v == 1 or v == 2) else -4)))
		v += 1
		drift = C68kScript.s16(drift) >> 1
	if memory.read_s16(ctl + 0x34) <= 0x3b:
		var faces: int = memory.read_u32(trail_obj + 0x48)
		memory.write_u8(faces + 0x33, memory.read_u8(faces + 0x33) | 2)
	else:
		var centre := [0, 0, 0]
		for i in range(4):
			for k in range(3):
				centre[k] = C68kScript.s32(centre[k] + memory.read_u32(verts + i * 0xc + 4 * k))
		for k in range(3):
			centre[k] = centre[k] >> 2
		for i in range(4):
			for k in range(3):
				var dev: int = C68kScript.s32(memory.read_u32(verts + i * 0xc + 4 * k) - centre[k])
				memory.write_u32(verts + 0x30 + i * 0xc + 4 * k, C68kScript.u32(centre[k] + _halve_toward_zero(dev)))
	if release:
		memory.write_u16(ctl + 0x56, 0)
	return finished

## 0x1702a: D0 = trail_animate_table[sext word +0x32](ctl) (jsr, 0xc below); lifetime word +0x34
## counts down, at 0 the object is hidden (long +4 |= 0x40) instead; a non-zero animator word
## retires the object (0xc below, with that D0).
func tick_trail(ctl: int) -> void:
	assert(memory != null, "tick_trail requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0xc
	var d0: int = C68kScript.u32(_jsr(memory.read_u32(C68kScript.u32(DAT_0001b514 + memory.read_s16(ctl + 0x32) * 4)), [ctl]))
	a7 = entry_a7
	if memory.read_u16(ctl + 0x34) != 0:
		memory.write_u16(ctl + 0x34, C68kScript.u16(memory.read_u16(ctl + 0x34) - 1))
	else:
		var obj: int = memory.read_u32(ctl)
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
	if (d0 & 0xffff) != 0:
		a7 = entry_a7 - 0xc
		retire_entity(memory.read_u32(ctl), d0)
		a7 = entry_a7

## 0x14bea: moves the objects a sinking carrier holds. heading = sum of the chain slot
## headings (word slot +4 of each parent's +0x30 table at the child's byte +2, & 0x3fff);
## matrix = build_attitude_matrix(-heading & 0x3fff, angle1, (angle2 + heading) & 0x3fff,
## angle3) in the frame at a6 - 0x12 (entered 0x64 below). For every object_pool object
## (word count 0x1b736, dbra) that is live (long +4 & 0x202 == 0), within the carrier's range
## (approx_dist3_xyz < long +0x14), has a controller and a type word of 7, 0x1b, 0x1a or 8:
## remove != 0 -> dispatch_entity_cleanup (0x54 below). Otherwise its position is cleared and
## recomputed by apply_template_chain_xform(obj, 1, 0, 0) (0x60 below); the word offsets from
## the carrier (low words, suba.w) are rotated in the frame record at a6 - 0x1e by
## transform_vecs12_by_matrix3 (0x70 below), then x / z = carrier + sext offset, y = carrier +
## sext offset - sext drop; a negative y also cleans the object up.
func carry_attached_objects(carrier: int, angle1: int, angle2: int, angle3: int, drop: int, remove: int) -> void:
	assert(memory != null, "carry_attached_objects requires original global memory")
	assert(a7 != 0, "carry_attached_objects needs a7 (its frame holds the matrix and offset record)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var vec: int = a6 - 0x1e
	var matrix: int = a6 - 0x12
	var cx: int = memory.read_u32(carrier + 0x18)
	var cy: int = memory.read_u32(carrier + 0x1c)
	var cz: int = memory.read_u32(carrier + 0x20)
	var part: int = memory.read_u8(carrier + 2)
	var heading: int = 0
	var link: int = memory.read_u32(carrier + 0x24)
	while link != 0:
		heading = (heading + memory.read_u16(memory.read_u32(link + 0x30) + part * 0x18 + 4)) & 0x3fff
		part = memory.read_u8(link + 2)
		link = memory.read_u32(link + 0x24)
	a7 = entry_a7 - 0x64
	build_attitude_matrix((-heading) & 0x3fff, C68kScript.s16(angle1), (C68kScript.u16(angle2) + heading) & 0x3fff, C68kScript.s16(angle3), matrix)
	a7 = entry_a7
	var left: int = memory.read_u16(DAT_0001b734 + 2)
	var slot: int = DAT_0001b5a4
	while true:
		left = C68kScript.u16(left - 1)
		if left == 0xffff:
			break
		var obj: int = memory.read_u32(slot)
		slot += 4
		if (memory.read_u32(obj + 4) & 0x202) != 0:
			continue
		var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), C68kScript.s32(cx), C68kScript.s32(cy), C68kScript.s32(cz))
		if dist >= memory.read_s32(carrier + 0x14):
			continue
		var obj_ctl: int = memory.read_u32(obj + 8)
		if obj_ctl == 0:
			continue
		var type: int = memory.read_s16(memory.read_u32(obj_ctl + 4))
		if type != 7 and type != 0x1b and type != 0x1a and type != 8:
			continue
		if C68kScript.u32(remove) == 0:
			for k in range(3):
				memory.write_u32(obj + 0x18 + 4 * k, 0)
			a7 = entry_a7 - 0x60
			apply_template_chain_xform(obj, 1, 0, 0)
			a7 = entry_a7
			memory.write_u16(vec + 2, C68kScript.u16(memory.read_u16(obj + 0x1a) - cx))
			memory.write_u16(vec + 6, C68kScript.u16(memory.read_u16(obj + 0x1e) - cy))
			memory.write_u16(vec + 10, C68kScript.u16(memory.read_u16(obj + 0x22) - cz))
			a7 = entry_a7 - 0x70
			transform_vecs12_by_matrix3(1, vec, vec, matrix)
			a7 = entry_a7
			memory.write_u32(obj + 0x18, C68kScript.u32(memory.read_s16(vec + 2) + cx))
			memory.write_u32(obj + 0x1c, C68kScript.u32(memory.read_s16(vec + 6) + cy - C68kScript.s16(drop)))
			memory.write_u32(obj + 0x20, C68kScript.u32(memory.read_s16(vec + 10) + cz))
			if memory.read_s32(obj + 0x1c) >= 0:
				continue
		a7 = entry_a7 - 0x54
		dispatch_entity_cleanup(obj)
		a7 = entry_a7

## 0x14d86: one sinking step when its frame (long +0x48, signed) is due and the object is
## live (byte +7 bit 1 clear): angle words +0x34 / +0x36 / +0x38 += rates +0x3a / +0x3c / +0x3e
## (& 0x3fff), drop word +0x40 += +0x42 (and a type-0x15 controller's word +0x54 -= +0x42);
## steps word +0x46 - 1: 0 -> +0x48 = 1000000000, else +0x48 = frame + sext word +0x44. Then
## sink_object_shape_at_waterline(obj, the angles, the drop) (0x20 below). Nothing left above the
## water: carry_attached_objects(obj, 0, 0, 0, 0, 1) (0x28 below; a seventh long, sext word
## +0x4e, is pushed but never read), tally_destroyed_entity when word +0x4e != 0, the two
## type-0x15 facility checks (probe_nearest_facility_kind 0x200 in host mode 7 / 9 -> host word
## +0xce = -1 unless negative, mode 7 also sets mission_target_list word +4 = 1; 0x100 in mode 8
## / 9 with +0xce == 0 -> +0xce = 1) and dispatch_entity_cleanup (each 0x10 below). Otherwise
## carry_attached_objects(obj, the angles, the drop, 0) (0x24 below). Word +0x32 == 0 (no
## end) gives the step back (+0x46 += 1). The D0 that the tally / cleanup calls return is not
## used here.
func step_sinking_object(ctl: int) -> void:
	assert(memory != null, "step_sinking_object requires original global memory")
	if memory.read_s32(DAT_0001b838) < memory.read_s32(ctl + 0x48):
		return
	var obj: int = memory.read_u32(ctl)
	if (memory.read_u8(obj + 7) & 2) != 0:
		return
	for pair in [[0x34, 0x3a], [0x36, 0x3c], [0x38, 0x3e]]:
		memory.write_u16(ctl + pair[0], (memory.read_u16(ctl + pair[0]) + memory.read_u16(ctl + pair[1])) & 0x3fff)
	memory.write_u16(ctl + 0x40, C68kScript.u16(memory.read_u16(ctl + 0x40) + memory.read_u16(ctl + 0x42)))
	var is_15: bool = memory.read_s16(memory.read_u32(ctl + 4)) == 0x15
	if is_15:
		memory.write_u16(ctl + 0x54, C68kScript.u16(memory.read_u16(ctl + 0x54) - memory.read_u16(ctl + 0x42)))
	memory.write_u16(ctl + 0x46, C68kScript.u16(memory.read_u16(ctl + 0x46) - 1))
	if memory.read_u16(ctl + 0x46) == 0:
		memory.write_u32(ctl + 0x48, 1000000000)
	else:
		memory.write_u32(ctl + 0x48, C68kScript.u32(memory.read_s16(ctl + 0x44) + memory.read_u32(DAT_0001b838)))
	var entry_a7: int = a7
	a7 = entry_a7 - 0x20
	var afloat: int = sink_object_shape_at_waterline(obj, memory.read_s16(ctl + 0x34), memory.read_s16(ctl + 0x36), memory.read_s16(ctl + 0x38), memory.read_s16(ctl + 0x40))
	a7 = entry_a7
	if afloat == 0:
		a7 = entry_a7 - 0x28
		carry_attached_objects(obj, 0, 0, 0, 0, 1)
		a7 = entry_a7 - 0x10
		if memory.read_u16(ctl + 0x4e) != 0:
			tally_destroyed_entity(obj)
		var host: int = memory.read_u32(DAT_0001b5a0)
		if is_15 and probe_nearest_facility_kind(obj) == 0x200:
			var mode: int = memory.read_s16(host + 0x90)
			if mode == 7 or mode == 9:
				if memory.read_s16(host + 0xce) >= 0:
					memory.write_u16(host + 0xce, 0xffff)
				if memory.read_s16(host + 0x90) == 7:
					memory.write_u16(memory.read_u32(DAT_00020adc) + 4, 1)
		if memory.read_s16(memory.read_u32(ctl + 4)) == 0x15 and probe_nearest_facility_kind(obj) == 0x100:
			var mode2: int = memory.read_s16(host + 0x90)
			if (mode2 == 8 or mode2 == 9) and memory.read_s16(host + 0xce) == 0:
				memory.write_u16(host + 0xce, 1)
		dispatch_entity_cleanup(obj)
		a7 = entry_a7
	else:
		a7 = entry_a7 - 0x24
		carry_attached_objects(obj, memory.read_s16(ctl + 0x34), memory.read_s16(ctl + 0x36), memory.read_s16(ctl + 0x38), memory.read_s16(ctl + 0x40), 0)
		a7 = entry_a7
	if memory.read_u16(ctl + 0x32) == 0:
		memory.write_u16(ctl + 0x46, C68kScript.u16(memory.read_u16(ctl + 0x46) + 1))

## 0x155d8: steps the sinking object once sinking has started (word +0x4c != 0; 8 below).
func tick_sinking_controller(ctl: int) -> void:
	assert(memory != null, "tick_sinking_controller requires original global memory")
	if memory.read_u16(ctl + 0x4c) != 0:
		var entry_a7: int = a7
		a7 = entry_a7 - 8
		step_sinking_object(ctl)
		a7 = entry_a7

## Binary searches shared by the inverse functions: lo / hi are words, the midpoint is (hi + lo)
## halved toward zero (32-bit sum, asr.l #1), the loop runs while sext(hi) - 1 > lo (subq.w on
## an address register is a 32-bit subtract).

## 0x1e3a: x clamped to +-0x1000; the largest index lo in 0..0x80 with x <= cos_table[lo]
## (signed words, a decreasing table), then lo asl 6 + word((-(x - c0) asl 6) divs.l (c0 - c1))
## (c0 / c1 = cos_table[lo] / [lo + 1]), the word sum sign-extended.
func acos_fixed14(x: int) -> int:
	assert(memory != null, "acos_fixed14 requires the original cos_table in memory")
	x = C68kScript.s32(x)
	if x > 0x1000:
		x = 0x1000
	if x < -0x1000:
		x = -0x1000
	var lo: int = 0
	var hi: int = 0x80
	while true:
		var sum: int = hi + lo
		if sum < 0:
			sum += 1
		var mid: int = C68kScript.s16(sum >> 1)
		if x > memory.read_s16(DAT_0001ad6c + mid * 2):
			hi = mid
		else:
			lo = mid
		if not (hi - 1 > lo):
			break
	var c0: int = memory.read_s16(DAT_0001ad6c + lo * 2)
	var c1: int = memory.read_s16(DAT_0001ad6c + lo * 2 + 2)
	var q: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.s32(-(x - c0)), 6)), c0 - c1)
	return C68kScript.s16((lo << 6) + q)

## 0x1ebc: the largest index lo in 0..0x7f with tan_table[lo] <= ratio (signed longs), then
## ((lo - 0x3f) asl 6 with its low word increased by word((t0 - ratio) asl 6 divs.l (t0 - t1)))
## & 0x3fff.
func atan_fixed14(ratio: int) -> int:
	assert(memory != null, "atan_fixed14 requires the original tan_table in memory")
	ratio = C68kScript.s32(ratio)
	var lo: int = 0
	var hi: int = 0x7f
	while true:
		var sum: int = hi + lo
		if sum < 0:
			sum += 1
		var mid: int = C68kScript.s16(sum >> 1)
		if ratio < memory.read_s32(DAT_0001af6c + mid * 4):
			hi = mid
		else:
			lo = mid
		if not (hi - 1 > lo):
			break
	var t0: int = memory.read_s32(DAT_0001af6c + lo * 4)
	var t1: int = memory.read_s32(DAT_0001af6c + lo * 4 + 4)
	var q: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.s32(t0 - ratio), 6)), C68kScript.s32(t0 - t1))
	return C68kScript.u16(((lo - 0x3f) << 6) + q) & 0x3fff

## 0xe372: the largest lo in 0..0x7fff with muls.w(lo, lo) <= n (signed), sign-extended.
func isqrt_floor(n: int) -> int:
	n = C68kScript.s32(n)
	var lo: int = 0
	var hi: int = 0x7fff
	while true:
		var sum: int = hi + lo
		if sum < 0:
			sum += 1
		var mid: int = C68kScript.s16(sum >> 1)
		if n < mid * mid:
			hi = mid
		else:
			lo = mid
		if not (hi - 1 > lo):
			break
	return lo

## 0x1f22: heading and pitch (0x4000 per turn) of a velocity given as words. |x| / |z| are the
## low words of abs_int. |z| < |x|: heading = 0x1000 - atan((vz asl 12) / |x|), negated when vx
## > 0, & 0x3fff. Else vz == 0 leaves the heading unwritten; otherwise heading = atan((-vx asl
## 12) / |z|), and for vz < 0 (0x2000 - that) & 0x3fff. Speed 0 leaves the pitch unwritten.
## Steep (|vy| > |x| + |z|, longs): pitch = acos((isqrt(speed_sq - vy * vy) asl 12) / speed),
## negated & 0x3fff for vy < 0; else pitch = (0x1000 - acos((vy asl 12) / speed)) & 0x3fff.
## Divisions are divs.l (truncating). The outputs are words at the two pointers.
func attitude_from_velocity(vx: int, vy: int, vz: int, speed: int, speed_sq: int, pitch: int, heading: int) -> void:
	assert(memory != null, "attitude_from_velocity requires original global memory")
	vx = C68kScript.s16(vx)
	vy = C68kScript.s16(vy)
	vz = C68kScript.s16(vz)
	var abs_x: int = C68kScript.s16(abs_int(vx))
	var abs_z: int = C68kScript.s16(abs_int(vz))
	if abs_z < abs_x:
		var angle: int = C68kScript.u16(0x1000 - atan_fixed14(C68kScript.divs_trunc(C68kScript.s32(vz << 12), abs_x)))
		if vx > 0:
			angle = C68kScript.u16(-angle)
		memory.write_u16(heading, angle & 0x3fff)
	elif vz != 0:
		var angle2: int = atan_fixed14(C68kScript.divs_trunc(C68kScript.s32((-vx) << 12), abs_z))
		if vz < 0:
			angle2 = C68kScript.u16(0x2000 - angle2) & 0x3fff
		memory.write_u16(heading, angle2)
	speed = C68kScript.s32(speed)
	if speed == 0:
		return
	var p: int
	if abs_int(vy) > abs_z + abs_x:
		var len: int = isqrt_floor(C68kScript.s32(C68kScript.s32(speed_sq) - vy * vy))
		p = C68kScript.u16(acos_fixed14(C68kScript.divs_trunc(C68kScript.s32(C68kScript.s16(len) << 12), speed)))
		if vy < 0:
			p = C68kScript.u16(-p) & 0x3fff
	else:
		p = C68kScript.u16(0x1000 - acos_fixed14(C68kScript.divs_trunc(C68kScript.s32(vy << 12), speed))) & 0x3fff
	memory.write_u16(pitch, p)

## 0x15bf6: a bullet from (x, y, z) along a 3x3 attitude. The frame record at a6 - 0xc holds
## the velocity words (0, 0, word((speed asr 4) + 0x2015)), rotated in place by
## transform_vecs12_by_matrix3; then each word gets (rng & 0x3f) - 0x20 (x, y, z order).
## spawn_mission_pool_object(bullet_template, x / y / z + sext(v asr.w 2), 0, 0, 0, 0) (0x4c
## below); null -> 0. The controller: +0x32 = ext(vy) asl 4, +8 / +0xc / +0x10 = sext(v asr.w
## 2), word +0x38 = 0, word +0x3a = 1 (mode 0) or 2, and the 0x12-byte matrix copied to +0x40
## (memmove_block, 0x28 below). Returns the controller.
func spawn_ordnance_scattered(speed: int, mode: int, x: int, y: int, z: int, matrix: int) -> int:
	assert(memory != null, "spawn_ordnance_scattered requires original global memory")
	assert(a7 != 0, "spawn_ordnance_scattered needs a7 (its frame holds the velocity record)")
	var entry_a7: int = a7
	var vel: int = entry_a7 - 4 - 0xc
	memory.write_u16(vel + 6, 0)
	memory.write_u16(vel + 2, 0)
	memory.write_u16(vel + 10, C68kScript.u16(C68kScript.asr32(speed, 4) + 0x2015))
	transform_vecs12_by_matrix3(1, vel, vel, matrix)
	for off in [2, 6, 10]:
		memory.write_u16(vel + off, C68kScript.u16(memory.read_u16(vel + off) - 0x20 + (overlay_rng_next() & 0x3f)))
	var q := []
	for off in [2, 6, 10]:
		q.append(memory.read_s16(vel + off) >> 2)
	a7 = entry_a7 - 0x4c
	var obj: int = spawn_mission_pool_object(memory.read_u32(DAT_0002664a), C68kScript.u32(x + q[0]), C68kScript.u32(y + q[1]), C68kScript.u32(z + q[2]), 0, 0, 0, 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var ctl: int = memory.read_u32(obj + 8)
	memory.write_u32(ctl + 0x32, C68kScript.u32(memory.read_s16(vel + 6) << 4))
	memory.write_u32(ctl + 8, C68kScript.u32(q[0]))
	memory.write_u32(ctl + 0xc, C68kScript.u32(q[1]))
	memory.write_u32(ctl + 0x10, C68kScript.u32(q[2]))
	memory.write_u16(ctl + 0x38, 0)
	memory.write_u16(ctl + 0x3a, 2 if C68kScript.u32(mode) != 0 else 1)
	a7 = entry_a7 - 0x28
	memmove_block(matrix, ctl + 0x40, 0x12)
	a7 = entry_a7
	return ctl

## 0x15d20: build_attitude_matrix_x(att_a, att_b, att_c, att_d) (sext words; 0x3c below) into
## the frame matrix at a6 - 0x12, then spawn_ordnance_scattered (0x54 below).
func spawn_ordnance_oriented(speed: int, mode: int, x: int, y: int, z: int, att_b: int, att_c: int, att_d: int, att_a: int) -> int:
	assert(a7 != 0, "spawn_ordnance_oriented needs a7 (its frame holds the matrix)")
	var entry_a7: int = a7
	var matrix: int = entry_a7 - 4 - 0x12
	a7 = entry_a7 - 0x3c
	build_attitude_matrix_x(C68kScript.s16(att_a), C68kScript.s16(att_b), C68kScript.s16(att_c), C68kScript.s16(att_d), matrix)
	a7 = entry_a7 - 0x54
	var ctl: int = spawn_ordnance_scattered(speed, mode, x, y, z, matrix)
	a7 = entry_a7
	return ctl

## 0x15d78: build_attitude_matrix_3ang(sext words ang1..3; 0x34 below) into the frame matrix at
## a6 - 0x12, then spawn_ordnance_scattered (0x5c below; the matrix arguments are still on the
## stack).
func spawn_ordnance_oriented_3ang(speed: int, mode: int, x: int, y: int, z: int, ang1: int, ang2: int, ang3: int) -> int:
	assert(a7 != 0, "spawn_ordnance_oriented_3ang needs a7 (its frame holds the matrix)")
	var entry_a7: int = a7
	var matrix: int = entry_a7 - 4 - 0x12
	a7 = entry_a7 - 0x34
	build_attitude_matrix_3ang(C68kScript.s16(ang1), C68kScript.s16(ang2), C68kScript.s16(ang3), matrix)
	a7 = entry_a7 - 0x5c
	var ctl: int = spawn_ordnance_scattered(speed, mode, x, y, z, matrix)
	a7 = entry_a7
	return ctl

## 0x1917c: once (word +0x40), word +0x3e = probe_nearest_facility_kind (0x28 below). A carrier
## (+0x32) that is retired, has no vertices (+0x44 == 0) or (with a controller) is burning
## (controller byte +0x685 bit 4) is released (its byte +3 - 1, +0x32 = 0) and the turret
## cleaned up (0x28 below); otherwise the turret takes its position. A live turret with a
## target (+0x36): a retired or vertex-less target is released (byte +3 - 1, +0x36 = 0). Else,
## unless word +0x46 is set, +0x3a = approx_dist3_xyz(turret, target); within range (long
## +0x42, signed) the offset to the target, shifted right by (steps to bring the distance below
## 0x8000) + 1, gives the aim: attitude_from_velocity(offset, isqrt(|offset|^2), |offset|^2,
## pitch +0x4c, heading +0x4e) (isqrt 0x28, attitude 0x44 below). Live play only: with no burst
## left (word +0x4a == 0), one rng in 16 starts a burst of (rng & 7) + 7 with scatter words
## +0x50 / +0x52 = 0x80 - (rng & 0xff); during a burst the delay word +0x48 counts down and at <= 0
## fires spawn_ordnance_oriented_3ang(0, 0, turret position, (pitch + scatter) & 0x3fff,
## (heading + scatter) & 0x3fff, 0) (0x44 below), the scatter shrinks to 7/8 (toward zero) and
## the delay resets to 2; the burst count drops by one each frame.
func tick_turret(ctl: int) -> void:
	assert(memory != null, "tick_turret requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	if memory.read_u16(ctl + 0x40) == 0:
		a7 = entry_a7 - 0x28
		memory.write_u16(ctl + 0x3e, C68kScript.u16(probe_nearest_facility_kind(obj)))
		a7 = entry_a7
		memory.write_u16(ctl + 0x40, 1)
	var carrier: int = memory.read_u32(ctl + 0x32)
	if carrier != 0:
		var release: bool = (memory.read_u8(carrier + 7) & 2) != 0 or memory.read_u32(carrier + 0x44) == 0
		if not release and memory.read_u32(carrier + 8) != 0:
			release = (memory.read_u8(memory.read_u32(carrier + 8) + 0x685) & 0x10) != 0
		if release:
			memory.write_u8(carrier + 3, C68kScript.u8(memory.read_u8(carrier + 3) - 1))
			memory.write_u32(ctl + 0x32, 0)
			a7 = entry_a7 - 0x28
			dispatch_entity_cleanup(obj)
			a7 = entry_a7
		else:
			for k in range(3):
				memory.write_u32(obj + 0x18 + 4 * k, memory.read_u32(carrier + 0x18 + 4 * k))
	if (memory.read_u8(obj + 7) & 2) != 0 or memory.read_u32(ctl + 0x36) == 0:
		return
	var target: int = memory.read_u32(ctl + 0x36)
	if (memory.read_u8(target + 7) & 2) != 0 or memory.read_u32(target + 0x44) == 0:
		memory.write_u8(target + 3, C68kScript.u8(memory.read_u8(target + 3) - 1))
		memory.write_u32(ctl + 0x36, 0)
		return
	if memory.read_u16(ctl + 0x46) != 0:
		return
	var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20))
	memory.write_u32(ctl + 0x3a, C68kScript.u32(dist))
	if dist > memory.read_s32(ctl + 0x42):
		return
	var shift: int = 0
	var d: int = C68kScript.u32(dist)
	while (d & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		d = C68kScript.u32(C68kScript.asr32(d, 1))
	shift = C68kScript.s16(shift + 1)
	var rel := []
	for k in range(3):
		rel.append(C68kScript.asr32(C68kScript.s32(memory.read_u32(target + 0x18 + 4 * k) - memory.read_u32(obj + 0x18 + 4 * k)), shift))
	var sq: int = C68kScript.s32(C68kScript.s32(rel[0] * rel[0]) + C68kScript.s32(rel[1] * rel[1]) + C68kScript.s32(rel[2] * rel[2]))
	a7 = entry_a7 - 0x28
	var len: int = isqrt_floor(sq)
	a7 = entry_a7 - 0x44
	attitude_from_velocity(rel[0], rel[1], rel[2], C68kScript.s16(len), sq, ctl + 0x4c, ctl + 0x4e)
	a7 = entry_a7
	if memory.read_u16(DAT_0001b870) != 0:
		return
	if memory.read_u16(ctl + 0x4a) == 0:
		if (overlay_rng_next() & 0xf) == 0:
			memory.write_u16(ctl + 0x4a, (overlay_rng_next() & 7) + 7)
			memory.write_u16(ctl + 0x50, C68kScript.u16(0x80 - (overlay_rng_next() & 0xff)))
			memory.write_u16(ctl + 0x52, C68kScript.u16(0x80 - (overlay_rng_next() & 0xff)))
		return
	memory.write_u16(ctl + 0x48, C68kScript.u16(memory.read_u16(ctl + 0x48) - 1))
	if memory.read_s16(ctl + 0x48) <= 0:
		a7 = entry_a7 - 0x44
		spawn_ordnance_oriented_3ang(0, 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), (memory.read_s16(ctl + 0x4c) + memory.read_s16(ctl + 0x50)) & 0x3fff, (memory.read_s16(ctl + 0x4e) + memory.read_s16(ctl + 0x52)) & 0x3fff, 0)
		a7 = entry_a7
		for off in [0x50, 0x52]:
			var v: int = memory.read_s16(ctl + off) * 7
			if v < 0:
				v += 7
			memory.write_u16(ctl + off, C68kScript.u16(v >> 3))
		memory.write_u16(ctl + 0x48, 2)
	memory.write_u16(ctl + 0x4a, C68kScript.u16(memory.read_u16(ctl + 0x4a) - 1))

## 0xe40c: the word angle folded into -0x2000..0x2000 (+-0x4000 once), sign-extended.
func fold_angle_pm_0x2000(angle: int) -> int:
	var a: int = C68kScript.s16(angle)
	if a > 0x2000:
		a = C68kScript.s16(a - 0x4000)
	elif a < -0x2000:
		a = C68kScript.s16(a + 0x4000)
	return a

## 0x14f48: a hit on a sinkable ship. The anchor (word 0x1d854) is cleared when the ship lies
## within its range of the anchor point; credit sets word +0x4e. With hits left (word +0x32) one
## is used up, and the new count picks the sinking motion (each part from overlay_rng_next):
## 0 (the last): angle a = +-((rng & 0xffff) % 0x140 + 0x500) (the sign of the folded first angle
## word +0x34), drop = rng % 200 + 1000, and, if sinking had not started (word +0x4c), also
## the roll of count 2; 1: a = +-((rng & 0x3f) + 0x100) (rng bit 0), drop = rng % 100 + 100, and
## the count-2 roll unless sinking started; 2: angle c = +-((rng & 0x7f) + 0x200), drop = rng % 100
## + 100; other counts change nothing and keep the drop register as the caller left it (D4,
## d4_in; apply_blast_damage leaves its credit flag there). Then over 15 steps: rates +0x3a /
## +0x3c / +0x3e / +0x42 = a / 0 / c / drop divs.w 15 (word quotients), next frame = frame + 0x1e,
## started = 1.
func apply_hit_to_sinkable_object(ctl: int, credit: int, d4_in: int = 0) -> void:
	assert(memory != null, "apply_hit_to_sinkable_object requires original global memory")
	if memory.read_u16(DAT_0001d854) != 0:
		var obj: int = memory.read_u32(ctl)
		var dist: int = approx_dist3_xyz(memory.read_s32(DAT_0001d83c), memory.read_s32(DAT_0001d83c + 4), memory.read_s32(DAT_0001d83c + 8), memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20))
		if dist <= memory.read_s32(obj + 0x14):
			memory.write_u16(DAT_0001d854, 0)
	if C68kScript.u32(credit) != 0:
		memory.write_u16(ctl + 0x4e, 1)
	if memory.read_u16(ctl + 0x32) == 0:
		return
	memory.write_u16(ctl + 0x32, C68kScript.u16(memory.read_u16(ctl + 0x32) - 1))
	var total_a: int = 0
	var total_c: int = 0
	var drop: int = C68kScript.s16(d4_in)
	var hits: int = memory.read_s16(ctl + 0x32)
	var roll_c: bool = false
	if hits == 0:
		total_a = C68kScript.s16(((overlay_rng_next() & 0xffff) % 0x140) + 0x500)
		if fold_angle_pm_0x2000(memory.read_s16(ctl + 0x34)) < 0:
			total_a = C68kScript.s16(-total_a)
		drop = C68kScript.s16(((overlay_rng_next() & 0xffff) % 200) + 1000)
		roll_c = memory.read_u16(ctl + 0x4c) == 0
	elif hits == 1:
		total_a = (overlay_rng_next() & 0x3f) + 0x100
		if (overlay_rng_next() & 1) != 0:
			total_a = -total_a
		drop = C68kScript.s16(((overlay_rng_next() & 0xffff) % 100) + 100)
		roll_c = memory.read_u16(ctl + 0x4c) == 0
	elif hits == 2:
		roll_c = true
	if roll_c:
		total_c = (overlay_rng_next() & 0x7f) + 0x200
		if (overlay_rng_next() & 1) != 0:
			total_c = -total_c
		drop = C68kScript.s16(((overlay_rng_next() & 0xffff) % 100) + 100)
	memory.write_u16(ctl + 0x46, 0xf)
	var steps: int = memory.read_s16(ctl + 0x46)
	memory.write_u16(ctl + 0x3a, C68kScript.u16(C68kScript.divs_trunc(total_a, steps)))
	memory.write_u16(ctl + 0x3c, 0)
	memory.write_u16(ctl + 0x3e, C68kScript.u16(C68kScript.divs_trunc(total_c, steps)))
	memory.write_u16(ctl + 0x42, C68kScript.u16(C68kScript.divs_trunc(drop, steps)))
	memory.write_u32(ctl + 0x48, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x1e))
	memory.write_u16(ctl + 0x4c, 1)

## 0x12b66: blast at (x, y, z). For each object_pool object (word count, dbra) that is live
## (long +4 & 0x10242 == 0) or is the player's (its controller == player_object): objects whose
## range (long +0x14) exceeds the radius are only hit as ships - with hit_ships, a ship type
## (0x15..0x19) inside its range takes apply_hit_to_sinkable_object. Others within range + 1999:
## inside the range they are hit; non-aircraft (no controller, or type > 4) are hit within 599
## past it; aircraft (type <= 4) are hit when sure_hit is 0 and the overshoot is <= (rng &
## 0x3ff), otherwise they take apply_random_aircraft_damage. A hit ship (0x15..0x19) takes
## apply_hit_to_sinkable_object; a hit aircraft gets damage word +0x684 |= 0x400; anything else
## gets spawn_destruction_effect(obj, range / 8 on the ground (y 0), else range / 4, toward zero),
## a kill tally when credited, and dispatch_entity_cleanup. Calls are entered 0x38 / 0x34 below.
func apply_blast_damage(x: int, y: int, z: int, radius: int, credit: int, sure_hit: int, hit_ships: int) -> void:
	assert(memory != null, "apply_blast_damage requires original global memory")
	var entry_a7: int = a7
	var left: int = memory.read_u16(DAT_0001b734 + 2)
	var slot: int = DAT_0001b5a4
	while true:
		left = C68kScript.u16(left - 1)
		if left == 0xffff:
			break
		var obj: int = memory.read_u32(slot)
		slot += 4
		var obj_ctl: int = memory.read_u32(obj + 8)
		if (memory.read_u32(obj + 4) & 0x10242) != 0:
			if obj_ctl == 0 or obj_ctl != memory.read_u32(DAT_0001b738):
				continue
		var rng: int = memory.read_s32(obj + 0x14)
		var type: int = memory.read_s16(memory.read_u32(obj_ctl + 4)) if obj_ctl != 0 else 0
		if rng > C68kScript.s32(radius):
			if C68kScript.u32(hit_ships) != 0 and obj_ctl != 0 and type > 0x14 and type <= 0x19:
				var d2: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), C68kScript.s32(x), C68kScript.s32(y), C68kScript.s32(z))
				if d2 < rng:
					a7 = entry_a7 - 0x38
					apply_hit_to_sinkable_object(obj_ctl, credit, credit)
					a7 = entry_a7
			continue
		var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), C68kScript.s32(x), C68kScript.s32(y), C68kScript.s32(z))
		var over: int = C68kScript.s32(dist - rng)
		if over > 0x7cf:
			continue
		var hit: bool
		if dist < rng:
			hit = true
		elif obj_ctl == 0 or type > 4:
			hit = over <= 0x257
		elif C68kScript.u32(sure_hit) == 0 and over <= (overlay_rng_next() & 0x3ff):
			hit = true
		else:
			a7 = entry_a7 - 0x38
			apply_random_aircraft_damage(obj_ctl, credit)
			a7 = entry_a7
			hit = false
		if not hit:
			continue
		if obj_ctl != 0 and type > 0x14 and type <= 0x19:
			a7 = entry_a7 - 0x38
			apply_hit_to_sinkable_object(obj_ctl, credit, credit)
			a7 = entry_a7
		elif obj_ctl != 0 and type <= 4:
			memory.write_u16(obj_ctl + 0x684, memory.read_u16(obj_ctl + 0x684) | 0x400)
		else:
			var size: int = rng
			if memory.read_u32(obj + 0x1c) == 0:
				if size < 0:
					size += 7
				size = size >> 3
			else:
				if size < 0:
					size += 3
				size = size >> 2
			a7 = entry_a7 - 0x38
			spawn_destruction_effect(obj, size)
			a7 = entry_a7 - 0x34
			if C68kScript.u32(credit) != 0:
				tally_destroyed_entity(obj)
			dispatch_entity_cleanup(obj)
			a7 = entry_a7

## 0x18c96: flak gun. A retired gun releases its target (byte +3 - 1, +0x36 = 0). Once (word
## +0x40): the first face whose byte +0x17 is 1 gives the barrel - the mean of its vertices
## (each asr word +0x34; divs.l by the word count) at +0x48 / +0x4c / +0x50, and the aim of its
## normal point minus vertex 0 (attitude_from_velocity with speed 0x4000 and 0x10000000 into the
## frame words a6 - 2 / a6 - 4, entered 0x68 below; a heading the call leaves unwritten keeps
## the frame's old word) at +0x54 / +0x56, +0x58 = 0 - then word +0x3e = the facility probe
## (0x50 below). With a target (+0x36) in live play: every due burst slot (long +0xd2 + 4i,
## 0..9, 0 < due <= frame) is cleared and bursts at +0x5a + 12i: spawn_effect(2, 100, 0x1e, 0,
## 0) (0x6c below) and apply_blast_damage(500, 0, 1, 0) (0x68 below). Out of shells (word
## +0x46), or a retired / vertex-less target, releases it. Otherwise one rng in 64 (& 0x3f ==
## 0x15) tries a shot: distance +0x3a within range +0x42; the offset to the target, shifted as
## in tick_turret, is aimed (muls.w squares of the low words, isqrt 0x50 below, attitude into
## a6 - 6 / a6 - 8, 0x68 below); a pitch above 0x3f and a heading within 0x1000 of the barrel
## (|fold(heading - word +0x56)|) fire into the first free slot: shells - 1, due = frame +
## word(distance / 1024 toward zero); lead = that word + (rng & 0x3f); the burst point is the
## target position + lead * its controller's velocity (+8 / +0xc / +0x10, muls.l) - 0x800 +
## (rng & 0xfff) per axis, its y raised to the target controller's ground (+0x2e) + 500 when
## below it + 500.
func tick_flak_gun(ctl: int) -> void:
	assert(memory != null, "tick_flak_gun requires original global memory")
	assert(a7 != 0, "tick_flak_gun needs a7 (its frame holds the attitude words)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var obj: int = memory.read_u32(ctl)
	if (memory.read_u8(obj + 7) & 2) != 0:
		var t: int = memory.read_u32(ctl + 0x36)
		if t != 0:
			memory.write_u8(t + 3, C68kScript.u8(memory.read_u8(t + 3) - 1))
			memory.write_u32(ctl + 0x36, 0)
		return
	if memory.read_u16(ctl + 0x40) == 0:
		var normals: int = C68kScript.u32(memory.read_s16(obj + 0x36) * 0xc + memory.read_u32(obj + 0x44))
		var face: int = memory.read_u32(obj + 0x48)
		var i: int = 0
		while i < memory.read_s16(obj + 0x3a):
			if memory.read_u8(face + 0x17) == 1:
				var sums := [0, 0, 0]
				var idx: int = memory.read_u32(face + 0x18)
				var left: int = memory.read_u16(face + 0x14)
				while true:
					left = C68kScript.u16(left - 1)
					if left == 0xffff:
						break
					var vert: int = memory.read_u32(obj + 0x44) + memory.read_s16(idx) * 0xc
					idx += 2
					for k in range(3):
						sums[k] = C68kScript.s32(sums[k] + C68kScript.asr32(memory.read_u32(vert + 4 * k), memory.read_s16(obj + 0x34)))
				var count: int = memory.read_s16(face + 0x14)
				for k in range(3):
					memory.write_u32(ctl + 0x48 + 4 * k, C68kScript.u32(C68kScript.divs_trunc(sums[k], count)))
				var v0: int = memory.read_u32(obj + 0x44)
				var rel := []
				for k in range(3):
					rel.append(C68kScript.s32(memory.read_u32(normals + i * 0xc + 4 * k) - memory.read_u32(v0 + 4 * k)))
				a7 = entry_a7 - 0x68
				attitude_from_velocity(rel[0], rel[1], rel[2], 0x4000, 0x10000000, a6 - 2, a6 - 4)
				a7 = entry_a7
				memory.write_u16(ctl + 0x54, memory.read_u16(a6 - 2))
				memory.write_u16(ctl + 0x56, memory.read_u16(a6 - 4))
				memory.write_u16(ctl + 0x58, 0)
				break
			i += 1
			face += 0x20
		a7 = entry_a7 - 0x50
		memory.write_u16(ctl + 0x3e, C68kScript.u16(probe_nearest_facility_kind(obj)))
		a7 = entry_a7
		memory.write_u16(ctl + 0x40, 1)
	if memory.read_u32(ctl + 0x36) == 0 or memory.read_u16(DAT_0001b870) != 0:
		return
	for slot in range(10):
		var due: int = memory.read_s32(ctl + 0xd2 + 4 * slot)
		if due != 0 and due <= memory.read_s32(DAT_0001b838):
			memory.write_u32(ctl + 0xd2 + 4 * slot, 0)
			var p: int = ctl + 0x5a + 12 * slot
			a7 = entry_a7 - 0x6c
			spawn_effect(2, 100, 0x1e, 0, 0, memory.read_u32(p), memory.read_u32(p + 4), memory.read_u32(p + 8))
			a7 = entry_a7 - 0x68
			apply_blast_damage(memory.read_u32(p), memory.read_u32(p + 4), memory.read_u32(p + 8), 500, 0, 1, 0)
			a7 = entry_a7
	var target: int = memory.read_u32(ctl + 0x36)
	if memory.read_u16(ctl + 0x46) == 0 or (memory.read_u8(target + 7) & 2) != 0 or memory.read_u32(target + 0x44) == 0:
		memory.write_u8(target + 3, C68kScript.u8(memory.read_u8(target + 3) - 1))
		memory.write_u32(ctl + 0x36, 0)
		return
	if (overlay_rng_next() & 0x3f) != 0x15:
		return
	var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20))
	memory.write_u32(ctl + 0x3a, C68kScript.u32(dist))
	if dist > memory.read_s32(ctl + 0x42):
		return
	var shift: int = 0
	var d: int = C68kScript.u32(dist)
	while (d & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		d = C68kScript.u32(C68kScript.asr32(d, 1))
	shift = C68kScript.s16(shift + 1)
	var off := []
	for k in range(3):
		off.append(C68kScript.asr32(C68kScript.s32(memory.read_u32(target + 0x18 + 4 * k) - memory.read_u32(obj + 0x18 + 4 * k)), shift))
	var sq: int = 0
	for k in range(3):
		sq = C68kScript.s32(sq + C68kScript.s16(off[k]) * C68kScript.s16(off[k]))
	a7 = entry_a7 - 0x50
	var len: int = isqrt_floor(sq)
	a7 = entry_a7 - 0x68
	attitude_from_velocity(C68kScript.s16(off[0]), C68kScript.s16(off[1]), C68kScript.s16(off[2]), C68kScript.s16(len), sq, a6 - 6, a6 - 8)
	a7 = entry_a7
	if memory.read_s16(a6 - 6) <= 0x3f:
		return
	if abs_int(fold_angle_pm_0x2000(C68kScript.s32(memory.read_s16(a6 - 8) - memory.read_s16(ctl + 0x56)))) > 0x1000:
		return
	var free_slot: int = -1
	for slot2 in range(10):
		if memory.read_u32(ctl + 0xd2 + 4 * slot2) == 0:
			free_slot = slot2
			break
	if free_slot == -1:
		return
	memory.write_u16(ctl + 0x46, C68kScript.u16(memory.read_u16(ctl + 0x46) - 1))
	var fuse_src: int = memory.read_s32(ctl + 0x3a)
	if fuse_src < 0:
		fuse_src = C68kScript.s32(fuse_src + 0x3ff)
	var fuse: int = C68kScript.s16(fuse_src >> 10)
	memory.write_u32(ctl + 0xd2 + 4 * free_slot, C68kScript.u32(fuse + memory.read_u32(DAT_0001b838)))
	var lead: int = C68kScript.s16(fuse + (overlay_rng_next() & 0x3f))
	var target_ctl: int = memory.read_u32(target + 8)
	var burst: int = ctl + 0x5a + 12 * free_slot
	for k in range(3):
		var jitter: int = overlay_rng_next() & 0xfff
		memory.write_u32(burst + 4 * k, C68kScript.u32(C68kScript.s32(lead * memory.read_s32(target_ctl + 8 + 4 * k)) + memory.read_u32(target + 0x18 + 4 * k) - 0x800 + jitter))
	if C68kScript.s32(memory.read_u32(burst + 4) - 500) < memory.read_s32(target_ctl + 0x2e):
		memory.write_u32(burst + 4, C68kScript.u32(memory.read_u32(target_ctl + 0x2e) + 500))

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
