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
const DAT_00026280: int = 0x26280 ## ordnance_template (long)
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
const DAT_0001b884: int = 0x1b884 ## view_follow_target (long)
const DAT_0001b87c: int = 0x1b87c ## parachute_object (long)
const DAT_0001b87a: int = 0x1b87a ## abandoned_intact_aircraft (word)
const DAT_0001b874: int = 0x1b874 ## state_flag_b874 (word)
const DAT_0001b872: int = 0x1b872 ## state_flag_b872 (word)
const DAT_0001b844: int = 0x1b844 ## snd_ugh (word)
const DAT_00026004: int = 0x26004 ## aircraft_type_rec: definition record of the aircraft being updated
const DAT_0001b2c0: int = 0x1b2c0 ## altitude curve: 9 longs (inverse air density per 0x10000 band)
const DAT_0001b828: int = 0x1b828 ## view_rows (word)
const DAT_0001b82a: int = 0x1b82a ## view_width (word)
const DAT_0001daa0: int = 0x1daa0 ## fill_colour (word)
const DAT_0001b778: int = 0x1b778 ## session_ptr_a_slot1: span-run buffers of slots 1..3 (longs)
const DAT_0001c1bc: int = 0x1c1bc ## deferred_free_flag (word)
const DAT_00026780: int = 0x26780 ## parachute_template (long)
const DAT_0001b2e0: int = 0x1b2e0 ## route_1b2e0: 4 patrol points (12 bytes) in the aircraft's frame
const DAT_0001b310: int = 0x1b310 ## route_1b310: 4 patrol points
const DAT_0001b340: int = 0x1b340 ## route_1b340: 4 patrol points
const DAT_0001b370: int = 0x1b370 ## route_1b370: 8 world points of the scripted mission
const DAT_0001b3d0: int = 0x1b3d0 ## route_1b370_speeds: throttle target per mission point (long each)
const DAT_00020b40: int = 0x20b40 ## type10_controller: controller whose object mirrors the glide target (long, may be 0)
const DAT_0001b83c: int = 0x1b83c ## snd_approach_ok (word): set when the glide is waved off
const DAT_00026798: int = 0x26798 ## glide_saved_state: +0x32 handler before the landing approach
const DAT_0002679c: int = 0x2679c ## glide_start_z (long)
const DAT_000267a0: int = 0x267a0 ## glide_start_x (long)
const DAT_000267a4: int = 0x267a4 ## glide_long_267a4
const DAT_000267a8: int = 0x267a8 ## glide_long_267a8
const DAT_000267ac: int = 0x267ac ## glide_blend (word)
const DAT_000267ae: int = 0x267ae ## glide_height_floor (word)
const DAT_000267b2: int = 0x267b2 ## glide_dir x / y / z (words at +0 / +4 / +8)
const DAT_000267bc: int = 0x267bc ## glide_aim x / y / z (longs)
const DAT_0001b876: int = 0x1b876 ## ai_aim_lag_key1 (word): pose-ring lag for type-record key 1
const DAT_0001b878: int = 0x1b878 ## ai_aim_lag (word): pose-ring lag for the other aircraft
const DAT_0001b3f4: int = 0x1b3f4 ## ai_fly_table: per-kind fly handler (runtime code addresses; 0 = update_aircraft_entity)
const DAT_0001b86c: int = 0x1b86c ## replay_request (word): 1 airborne, 2 on the ground
const DAT_00026658: int = 0x26658 ## ground_fire_template (long)
const DAT_0001b888: int = 0x1b888 ## designated_entity_2 (controller pointer): nearest radar-worthy aircraft for the player
const DAT_00026666: int = 0x26666 ## radar_limit (long): 2 * radar_range
const DAT_0001b51c: int = 0x1b51c ## radar_tracks (pointer): up to 6 tracks of 0x14 bytes

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
	code_table[0x180a8] = Callable(self, "tick_wave_spawner")
	code_table[0x17db4] = Callable(self, "tick_aircraft_spawner")
	code_table[0x15336] = Callable(self, "tick_firing_ship_controller")
	code_table[0x11494] = Callable(self, "spin_object_heading")
	code_table[0x11ac6] = Callable(self, "face_camera_heading")
	code_table[0x17cf6] = func(o: int, k: int, _c: int = 0) -> int: return create_aircraft_spawner_controller(o, k)
	code_table[0x17d98] = Callable(self, "destroy_aircraft_spawner_controller")
	code_table[0x18020] = func(o: int, k: int, _c: int = 0) -> int: return create_wave_spawner_controller(o, k)
	code_table[0x18b78] = Callable(self, "destroy_flak_controller")
	code_table[0xe084] = Callable(self, "aircraft_destroy")
	code_table[0xfe76] = func(a: int, b: int, _c: int = 0) -> void: aircraft_notice_object(a, b)
	code_table[0x1009c] = Callable(self, "release_ai_target")
	code_table[0x100b4] = func(a: int, b: int, _c: int = 0) -> void: enemy_fighter_notice_object(a, b)
	code_table[0xfb0a] = Callable(self, "animate_landing_gear")
	code_table[0xe58a] = Callable(self, "aircraft_tick")
	code_table[0xe772] = Callable(self, "update_aircraft_entity")
	code_table[0x110d4] = Callable(self, "ai_attack_or_fly")
	code_table[0x10d48] = Callable(self, "ensure_ai_script_1b2e0_tick")
	code_table[0x1a186] = Callable(self, "tick_landing_approach_glide")
	code_table[0x10d88] = Callable(self, "ensure_ai_script_1b310_tick")
	code_table[0x10dc8] = Callable(self, "ensure_ai_script_1b340_tick")
	code_table[0x10eac] = Callable(self, "tick_ai_1b310_approach_fire")
	code_table[0x10f48] = Callable(self, "tick_ai_1b370_mission")
	code_table[0x11162] = Callable(self, "ai_fly")
	code_table[0x1118e] = Callable(self, "ai_fly_bomber")
	code_table[0x111ba] = Callable(self, "ai_dive_at_target")
	code_table[0x112c0] = Callable(self, "ai_bombing_run")
	code_table[0xfdea] = func(a: int, b: int, _c: int = 0) -> void: aircraft_collision(a, b)
	code_table[0x18b9a] = func(g: int, o: int, _c: int = 0, d0_in: int = 0) -> int: return flak_notice_object(g, o, d0_in)
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

## 0xe262: spawn_mission_pool_object(enemy_fighter_template, the seven arguments unchanged)
## (0x28 below); returns the new object's controller (+8), or 0.
func spawn_enemy_fighter(x: int, y: int, z: int, angle_a: int, angle_b: int, angle_c: int, arg_word: int) -> int:
	assert(memory != null, "spawn_enemy_fighter requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x28
	var spawned: int = spawn_mission_pool_object(memory.read_u32(DAT_00026000), x, y, z, angle_a, angle_b, angle_c, arg_word)
	a7 = entry_a7
	if spawned == 0:
		return 0
	return memory.read_u32(spawned + 8)

## 0x180c8: while fighters remain (word +0x32), in live play, at the due frame (long +0x34,
## signed): bearing = word((rng & 0xffff) % 0x1540 - 0xa80) & 0x3fff; distance = (sext word rng +
## 0x5a3c0) asr 4; a fighter at (-0xb92670 - (sin * distance asr 8), 40000, 0x7f8e4c + (cos *
## distance asr 8)) (muls.l of the sign-extended sin / cos words), heading word (bearing +
## (rng & 0x1ff) + 0xdf00) & 0x3fff, arguments (0, heading, 0, 1) (spawn_enemy_fighter 0x48
## below). A spawned fighter gets damage word +0x684 |= 0x20 and, while mission_target_list word
## +4 is 0, +0x32 = 0x111ba; the count drops by one and in host mode 7 the controller is stored
## at mission_target_list + 6 + 4 * count. Next due frame: frame + (0x1356 when 5 remain, else
## 0x546) + (rng & 0xffff) % 0x1c2 - 0xe1.
func tick_wave_spawner(ctl: int) -> void:
	assert(memory != null, "tick_wave_spawner requires original global memory")
	if memory.read_u16(ctl + 0x32) == 0 or memory.read_u16(DAT_0001b870) != 0:
		return
	if memory.read_s32(DAT_0001b838) < memory.read_s32(ctl + 0x34):
		return
	var bearing: int = C68kScript.u16(((overlay_rng_next() & 0xffff) % 0x1540) + 0xf580) & 0x3fff
	var dist: int = C68kScript.asr32(C68kScript.s16(overlay_rng_next()) + 0x5a3c0, 4)
	var x: int = C68kScript.s32(-0xb92670 - C68kScript.asr32(C68kScript.s32(C68kScript.s16(sin_fixed14(bearing)) * dist), 8))
	var z: int = C68kScript.s32(C68kScript.asr32(C68kScript.s32(C68kScript.s16(cos_fixed14(bearing)) * dist), 8) + 0x7f8e4c)
	var heading: int = C68kScript.u16(bearing + 0xe000 + (overlay_rng_next() & 0x1ff) + 0xff00) & 0x3fff
	var entry_a7: int = a7
	a7 = entry_a7 - 0x48
	var fighter: int = spawn_enemy_fighter(C68kScript.u32(x), 40000, C68kScript.u32(z), 0, heading, 0, 1)
	a7 = entry_a7
	if fighter != 0:
		memory.write_u16(fighter + 0x684, memory.read_u16(fighter + 0x684) | 0x20)
		if memory.read_u16(memory.read_u32(DAT_00020adc) + 4) == 0:
			memory.write_u32(fighter + 0x32, 0x111ba)
		memory.write_u16(ctl + 0x32, C68kScript.u16(memory.read_u16(ctl + 0x32) - 1))
		if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) == 7:
			memory.write_u32(memory.read_u32(DAT_00020adc) + 6 + memory.read_s16(ctl + 0x32) * 4, fighter)
	var delay: int = 0x1356 if memory.read_s16(ctl + 0x32) == 5 else 0x546
	var r: int = (overlay_rng_next() & 0xffff) % 0x1c2
	memory.write_u32(ctl + 0x34, C68kScript.u32(delay + memory.read_u32(DAT_0001b838) + r - 0xe1))

## 0x17dd4: aircraft spawner (word +0x32 aircraft left, five slots at +0x34 + 4i; live play).
## Slots holding a retired aircraft, or one whose controller +0 is cleared, are released (byte
## +3 - 1, slot 0); a group launches only when no tracked aircraft is undamaged (controller
## word +0x684 & 0x3fe == 0) and one rng in 512 (& 0x1ff == 0) allows it. Group size =
## (rng & 0xffff) % min(left, 3) + 1 (divsl.l remainder). Bearing: heading of the spawner
## seen from the player (attitude_from_velocity on (dx, 0, dz) shifted below 0x8000, speed 0,
## heading into the frame word a6 - 2 - left unwritten when the call writes none) plus
## ((rng & 0x1f) - 0x10) asl 6. With r = word(((spawner range +0xc) asl 1) divs.l 3 asr 5):
## x = player x - (muls.w(r, sin) asr 7), altitude = (rng & 0xfff) * 10 + 30000, z = player z +
## (muls.w(r, cos) asr 7); the launch heading = bearing + ((rng & 0x1f) - 0x10) asl 6 + 0x2000.
## For each aircraft of the group: the next empty slot (search kept across the group), x / z
## each moved by (rng & 0xfff) - 0x800 (cumulative), spawn_enemy_fighter(x, altitude, z, 0,
## heading, 0, 1) (0x5c below); a fighter uses one of the left count and its object goes into
## the slot with its reference byte +3 + 1.
func tick_aircraft_spawner(ctl: int) -> void:
	assert(memory != null, "tick_aircraft_spawner requires original global memory")
	assert(a7 != 0, "tick_aircraft_spawner needs a7 (its frame holds the heading word)")
	if memory.read_u16(ctl + 0x32) == 0 or memory.read_u16(DAT_0001b870) != 0:
		return
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var alive: int = 0
	for slot in range(5):
		var obj: int = memory.read_u32(ctl + 0x34 + 4 * slot)
		if obj == 0:
			continue
		if (memory.read_u8(obj + 7) & 2) != 0 or memory.read_u32(memory.read_u32(obj + 8)) == 0:
			memory.write_u8(obj + 3, C68kScript.u8(memory.read_u8(obj + 3) - 1))
			memory.write_u32(ctl + 0x34 + 4 * slot, 0)
		elif (memory.read_u16(memory.read_u32(obj + 8) + 0x684) & 0x3fe) == 0:
			alive += 1
	if alive != 0 or (overlay_rng_next() & 0x1ff) != 0:
		return
	var spawner: int = memory.read_u32(ctl)
	var player: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	var group: int = memory.read_s16(ctl + 0x32) if memory.read_s16(ctl + 0x32) <= 2 else 3
	group = C68kScript.s16((overlay_rng_next() & 0xffff) % group + 1)
	var dx: int = C68kScript.s32(memory.read_u32(spawner + 0x18) - memory.read_u32(player + 0x18))
	var dz: int = C68kScript.s32(memory.read_u32(spawner + 0x20) - memory.read_u32(player + 0x20))
	var span: int = C68kScript.u32(abs_int(dx) + abs_int(dz))
	var shift: int = 0
	while (span & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		span = C68kScript.u32(C68kScript.asr32(span, 1))
	a7 = entry_a7 - 0x5c
	attitude_from_velocity(C68kScript.asr32(dx, shift), 0, C68kScript.asr32(dz, shift), 0, 0, 0, a6 - 2)
	a7 = entry_a7
	memory.write_u16(a6 - 2, C68kScript.u16(memory.read_u16(a6 - 2) + (((overlay_rng_next() & 0x1f) - 0x10) << 6)) & 0x3fff)
	var r: int = C68kScript.asr32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(memory.read_u32(spawner + 0xc), 1)), 3), 5)
	var heading: int = memory.read_s16(a6 - 2)
	var x: int = C68kScript.s32(memory.read_u32(player + 0x18) - C68kScript.asr32(C68kScript.s16(r) * C68kScript.s16(sin_fixed14(heading)), 7))
	var altitude: int = (overlay_rng_next() & 0xfff) * 10 + 30000
	var z: int = C68kScript.s32(C68kScript.asr32(C68kScript.s16(r) * C68kScript.s16(cos_fixed14(heading)), 7) + memory.read_u32(player + 0x20))
	memory.write_u16(a6 - 2, C68kScript.u16(memory.read_u16(a6 - 2) + (((overlay_rng_next() & 0x1f) - 0x10) << 6) + 0x2000) & 0x3fff)
	var slot2: int = 0
	var k: int = 0
	while k < group:
		while memory.read_u32(ctl + 0x34 + 4 * slot2) != 0:
			slot2 = C68kScript.s16(slot2 + 1)
		x = C68kScript.s32(x - 0x800 + (overlay_rng_next() & 0xfff))
		z = C68kScript.s32(z - 0x800 + (overlay_rng_next() & 0xfff))
		a7 = entry_a7 - 0x5c
		var fighter: int = spawn_enemy_fighter(C68kScript.u32(x), altitude, C68kScript.u32(z), 0, memory.read_s16(a6 - 2), 0, 1)
		a7 = entry_a7
		if fighter != 0:
			memory.write_u16(ctl + 0x32, C68kScript.u16(memory.read_u16(ctl + 0x32) - 1))
			var fobj: int = memory.read_u32(fighter)
			memory.write_u32(ctl + 0x34 + 4 * slot2, fobj)
			memory.write_u8(fobj + 3, C68kScript.u8(memory.read_u8(fobj + 3) + 1))
		k += 1

## 0x12840: spawn_mission_pool_object(ordnance_template, x, y, z, sext pitch / att_22 / bank
## words, 0) (0x34 below); null -> 0. The controller: word +0x61c |= 0x40 when flag_40, word
## +0x610 = the low word of speed, words +0x20 / +0x22 / +0x24 = the three angle words.
func spawn_weapon_entity(speed: int, flag_40: int, x: int, y: int, z: int, pitch: int, att_22: int, bank: int) -> int:
	assert(memory != null, "spawn_weapon_entity requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x34
	var obj: int = spawn_mission_pool_object(memory.read_u32(DAT_00026280), x, y, z, C68kScript.s16(pitch), C68kScript.s16(att_22), C68kScript.s16(bank), 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var ctl: int = memory.read_u32(obj + 8)
	if C68kScript.u32(flag_40) != 0:
		memory.write_u16(ctl + 0x61c, memory.read_u16(ctl + 0x61c) | 0x40)
	memory.write_u16(ctl + 0x610, C68kScript.u16(speed))
	memory.write_u16(ctl + 0x20, C68kScript.u16(pitch))
	memory.write_u16(ctl + 0x22, C68kScript.u16(att_22))
	memory.write_u16(ctl + 0x24, C68kScript.u16(bank))
	return ctl

## 0x15356: a sinking ship (word +0x4c) only steps its sinking (0x44 below). Otherwise, once
## (gun count word +0x52 == 0): every face with byte +0x17 == 1 is a gun - its vertex mean
## (asr word +0x34; divs.l by the word count; the vertex loop runs the count unsigned via
## subq / bcc) at +0x54 + 12 g, and the aim of its normal point minus vertex 0
## (attitude_from_velocity speed 0x4000, 0x10000000 into the frame words a6 - 2 / a6 - 4, 0x5c
## below) at words +0xe4 / +0xe6 + 6 g, +0xe8 + 6 g = 0; the count is stored. With shots left
## (word +0x50) one rng in 256 (low byte 0x1b) uses a shot: gun = (rng & 0xffff) % guns
## (divsl.l remainder); pitch / heading = gun aim + (rng & 0xff) - 0x80 (& 0x3fff, kept in the
## frame words); in live play spawn_weapon_entity(0x7fff - (rng & 0xff), 1, gun x, gun y + 10,
## gun z, pitch, heading, 0) (0x60 below).
func tick_firing_ship_controller(ctl: int) -> void:
	assert(memory != null, "tick_firing_ship_controller requires original global memory")
	assert(a7 != 0, "tick_firing_ship_controller needs a7 (its frame holds the aim words)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var obj: int = memory.read_u32(ctl)
	if memory.read_u16(ctl + 0x4c) != 0:
		a7 = entry_a7 - 0x44
		step_sinking_object(ctl)
		a7 = entry_a7
		return
	if memory.read_u16(ctl + 0x52) == 0:
		var normals: int = C68kScript.u32(memory.read_s16(obj + 0x36) * 0xc + memory.read_u32(obj + 0x44))
		var face: int = memory.read_u32(obj + 0x48)
		var guns: int = 0
		var i: int = 0
		while i < memory.read_s16(obj + 0x3a):
			if memory.read_u8(face + 0x17) == 1:
				var sums := [0, 0, 0]
				var idx: int = memory.read_u32(face + 0x18)
				var left: int = memory.read_u16(face + 0x14)
				while left != 0:
					left = C68kScript.u16(left - 1)
					var vert: int = memory.read_u32(obj + 0x44) + memory.read_s16(idx) * 0xc
					idx += 2
					for k in range(3):
						sums[k] = C68kScript.s32(sums[k] + C68kScript.asr32(memory.read_u32(vert + 4 * k), memory.read_s16(obj + 0x34)))
				var count: int = memory.read_s16(face + 0x14)
				for k in range(3):
					memory.write_u32(ctl + 0x54 + 12 * guns + 4 * k, C68kScript.u32(C68kScript.divs_trunc(sums[k], count)))
				var v0: int = memory.read_u32(obj + 0x44)
				var rel := []
				for k in range(3):
					rel.append(C68kScript.s32(memory.read_u32(normals + i * 0xc + 4 * k) - memory.read_u32(v0 + 4 * k)))
				a7 = entry_a7 - 0x5c
				attitude_from_velocity(rel[0], rel[1], rel[2], 0x4000, 0x10000000, a6 - 2, a6 - 4)
				a7 = entry_a7
				memory.write_u16(ctl + 0xe4 + 6 * guns, memory.read_u16(a6 - 2))
				memory.write_u16(ctl + 0xe6 + 6 * guns, memory.read_u16(a6 - 4))
				memory.write_u16(ctl + 0xe8 + 6 * guns, 0)
				guns = C68kScript.s16(guns + 1)
			i += 1
			face += 0x20
		memory.write_u16(ctl + 0x52, C68kScript.u16(guns))
	if memory.read_u16(ctl + 0x50) == 0:
		return
	if (overlay_rng_next() & 0xff) != 0x1b:
		return
	memory.write_u16(ctl + 0x50, C68kScript.u16(memory.read_u16(ctl + 0x50) - 1))
	var draw: int = overlay_rng_next() & 0xffff
	var gun: int = C68kScript.s16(C68kScript.rems_trunc(draw, memory.read_s16(ctl + 0x52)))
	var gun_pos: int = ctl + 0x54 + gun * 12
	var aim: int = ctl + 0xe4 + gun * 6
	memory.write_u16(a6 - 2, C68kScript.u16(memory.read_u16(aim) + (overlay_rng_next() & 0xff) - 0x80) & 0x3fff)
	memory.write_u16(a6 - 4, C68kScript.u16(memory.read_u16(aim + 2) + (overlay_rng_next() & 0xff) - 0x80) & 0x3fff)
	if memory.read_u16(DAT_0001b870) != 0:
		return
	var speed: int = 0x7fff - (overlay_rng_next() & 0xff)
	a7 = entry_a7 - 0x60
	spawn_weapon_entity(speed, 1, memory.read_u32(gun_pos), C68kScript.u32(memory.read_u32(gun_pos + 4) + 10), memory.read_u32(gun_pos + 8), memory.read_s16(a6 - 2), memory.read_s16(a6 - 4), 0)
	a7 = entry_a7

## 0x114b4: spinner tick: heading word +0x22 += 0x40 (& 0x3fff).
func spin_object_heading(ctl: int) -> void:
	memory.write_u16(ctl + 0x22, (memory.read_u16(ctl + 0x22) + 0x40) & 0x3fff)

## 0x11ae6: camera-facing animate handler: heading word +0x22 = -neg_camera_heading & 0x3fff;
## returns 0.
func face_camera_heading(ctl: int) -> int:
	memory.write_u16(ctl + 0x22, C68kScript.u16(-memory.read_u16(DAT_0001d80e)) & 0x3fff)
	return 0

## 0x17d16: cleared 0x48-byte spawner controller: +0 = object, object long +4 |= 0x30040
## (key 0x12 also sets byte +5 bit 4), +4 = DAT_0001b524[key]; aircraft to launch word +0x32 =
## rng & 0xf, reduced by the object's range: 0x80e80 -> (rng & 3) + 1, 0xc15c0 -> (rng & 3) +
## 2, 0x40740 -> (rng & 0xf) % 3 (divs.w remainder), any other range keeps rng & 0xf.
func create_aircraft_spawner_controller(obj: int, def_key: int) -> int:
	assert(memory != null, "create_aircraft_spawner_controller requires original global memory")
	var ctl: int = heap_alloc_cleared(0x48)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x30040)
	if C68kScript.s32(def_key) == 0x12:
		memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 0x10)
	memory.write_u32(ctl + 4, _definition(def_key))
	var left: int = overlay_rng_next() & 0xf
	var rng: int = memory.read_s32(obj + 0xc)
	if rng == 0x80e80:
		left = (left & 3) + 1
	elif rng == 0xc15c0:
		left = (left & 3) + 2
	elif rng == 0x40740:
		left = left % 3
	memory.write_u16(ctl + 0x32, left)
	return ctl

## 0x17db8: drops the reference byte +3 of the objects in slots 0..2 (+0x34 + 4i) - only three
## of the five slots tick_aircraft_spawner uses, as in the bytes.
func destroy_aircraft_spawner_controller(ctl: int) -> void:
	for i in range(3):
		var ref: int = memory.read_u32(ctl + 0x34 + 4 * i)
		if ref != 0:
			memory.write_u8(ref + 3, C68kScript.u8(memory.read_u8(ref + 3) - 1))

## 0x18040: cleared 0x38-byte wave spawner: +0 = object, object long +4 |= 0x130040, +4 =
## DAT_0001b524[key], word +0x32 = 10, long +0x34 = frame + 0x546. In host mode 7 it also
## allocates the cleared mission_target_list (10 + 4 * count bytes) with words +0 / +2 = count.
func create_wave_spawner_controller(obj: int, def_key: int) -> int:
	assert(memory != null, "create_wave_spawner_controller requires original global memory")
	var ctl: int = heap_alloc_cleared(0x38)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x130040)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u16(ctl + 0x32, 10)
	memory.write_u32(ctl + 0x34, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x546))
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) == 7:
		var list: int = heap_alloc_cleared(memory.read_s16(ctl + 0x32) * 4 + 10)
		memory.write_u32(DAT_00020adc, list)
		memory.write_u16(list + 2, memory.read_u16(ctl + 0x32))
		memory.write_u16(list, memory.read_u16(ctl + 0x32))
	return ctl

## 0x18b98: drops the reference bytes of the held target (+0x36) and carrier (+0x32).
func destroy_flak_controller(ctl: int) -> void:
	for off in [0x36, 0x32]:
		var ref: int = memory.read_u32(ctl + off)
		if ref != 0:
			memory.write_u8(ref + 3, C68kScript.u8(memory.read_u8(ref + 3) - 1))

## 0x18bba: a flak gun notices another object. Guns probing an enemy carrier (+0x3e == 0x200)
## consider types 3..4, guns probing a friendly one (0x100) types <= 2; once set up (+0x40),
## one rng in 64 rolls the target: chance = 0x339000 / distance (0x7fffffff at 0), halved when
## a target is held; rng & 0x7f below it takes the new object, replacing a held target only
## when it is under half the held distance (+0x3a) - the old target's reference byte drops,
## the new one's rises. D0 is returned as the bytes leave it: the type word over the caller's
## high word, then each rng draw's masked value, or twice the distance on the replace test.
func flak_notice_object(gun: int, other: int, d0_in: int = 0) -> int:
	assert(memory != null, "flak_notice_object requires original global memory")
	var ctl: int = memory.read_u32(gun + 8)
	var type: int = memory.read_s16(memory.read_u32(memory.read_u32(other + 8) + 4))
	var d0: int = (C68kScript.u32(d0_in) & 0xffff0000) | C68kScript.u16(type)
	var probe: int = memory.read_u16(ctl + 0x3e)
	var wanted: bool = (probe == 0x200 and type > 2 and type <= 4) or (probe == 0x100 and type <= 2)
	if not wanted or memory.read_u16(ctl + 0x40) == 0:
		return d0
	d0 = overlay_rng_next() & 0x3f
	if d0 != 0:
		return d0
	var dist: int = approx_dist3_xyz(memory.read_s32(gun + 0x18), memory.read_s32(gun + 0x1c), memory.read_s32(gun + 0x20), memory.read_s32(other + 0x18), memory.read_s32(other + 0x1c), memory.read_s32(other + 0x20))
	var chance: int = 0x7fffffff if dist == 0 else C68kScript.divs_trunc(0x339000, dist)
	if memory.read_u32(ctl + 0x36) != 0:
		chance = chance >> 1
	d0 = overlay_rng_next() & 0x7f
	if chance <= d0:
		return d0
	if memory.read_u32(ctl + 0x36) != 0:
		d0 = C68kScript.u32(C68kScript.lsl32(dist, 1))
		if C68kScript.s32(d0) >= memory.read_s32(ctl + 0x3a):
			return d0
		memory.write_u32(ctl + 0x3a, C68kScript.u32(dist))
		var old: int = memory.read_u32(ctl + 0x36)
		memory.write_u8(old + 3, C68kScript.u8(memory.read_u8(old + 3) - 1))
		memory.write_u32(ctl + 0x36, other)
	else:
		memory.write_u32(ctl + 0x36, other)
		memory.write_u32(ctl + 0x3a, C68kScript.u32(dist))
	memory.write_u8(other + 3, C68kScript.u8(memory.read_u8(other + 3) + 1))
	return d0

## 0xe0a4: aircraft destroy handler: frees the controller's buffer (+0x616) and drops the AI
## target's (+0x692) reference byte +3.
func aircraft_destroy(ctl: int) -> void:
	assert(memory != null, "aircraft_destroy requires original global memory")
	if memory.read_u32(ctl + 0x616) != 0:
		heap_free_coalesce(memory.read_u32(ctl + 0x616))
	var target: int = memory.read_u32(ctl + 0x692)
	if target != 0:
		memory.write_u8(target + 3, C68kScript.u8(memory.read_u8(target + 3) - 1))

## 0xfe0a: aircraft collision handler (live play only): this aircraft's damage word +0x684 |=
## 0x400; another aircraft (type <= 4) gets the same; hitting a ship (type 0x15..0x19) sets off
## apply_blast_damage at this aircraft (y raised to its controller's ground +0x2e when below),
## radius 10, credited when this is the player's controller, sure_hit 0, hit_ships 1 (0x2c
## below).
func aircraft_collision(self_obj: int, other_obj: int) -> void:
	assert(memory != null, "aircraft_collision requires original global memory")
	if memory.read_u16(DAT_0001b870) != 0:
		return
	var self_ctl: int = memory.read_u32(self_obj + 8)
	memory.write_u16(self_ctl + 0x684, memory.read_u16(self_ctl + 0x684) | 0x400)
	var other_ctl: int = memory.read_u32(other_obj + 8)
	if other_ctl == 0:
		return
	var type: int = memory.read_s16(memory.read_u32(other_ctl + 4))
	if type <= 4:
		memory.write_u16(other_ctl + 0x684, memory.read_u16(other_ctl + 0x684) | 0x400)
	elif type > 0x14 and type <= 0x19:
		var y: int = memory.read_s32(self_obj + 0x1c)
		if y <= memory.read_s32(self_ctl + 0x2e):
			y = memory.read_s32(self_ctl + 0x2e)
		var entry_a7: int = a7
		a7 = entry_a7 - 0x2c
		apply_blast_damage(memory.read_u32(self_obj + 0x18), C68kScript.u32(y), memory.read_u32(self_obj + 0x20), 10, 1 if self_ctl == memory.read_u32(DAT_0001b738) else 0, 0, 1)
		a7 = entry_a7

## 0x10cd8: a positive AI bias byte +0x67b is negated.
func invert_ai_bias_67b_if_positive(ctl: int) -> void:
	var v: int = memory.read_s8(ctl + 0x67b)
	if v > 0:
		memory.write_u8(ctl + 0x67b, C68kScript.u8(-v))

## 0x176b2: while fewer than six tracks are in use (long count 0x26676) and the object's metric
## (+0x10) is within radar_limit (signed), appends a track at radar_tracks + 0x14 * count: x,
## z, sext controller words +0xa / +0x12, 0.
func add_radar_track(obj: int) -> void:
	assert(memory != null, "add_radar_track requires original global memory")
	if memory.read_s32(DAT_00026676) > 5:
		return
	var ctl: int = memory.read_u32(obj + 8)
	var word_a: int = memory.read_s16(ctl + 0xa)
	var word_12: int = memory.read_s16(ctl + 0x12)
	if memory.read_s32(obj + 0x10) > memory.read_s32(DAT_00026666):
		return
	var track: int = C68kScript.u32(memory.read_u32(DAT_00026676) * 0x14 + memory.read_u32(DAT_0001b51c))
	memory.write_u32(DAT_00026676, C68kScript.u32(memory.read_u32(DAT_00026676) + 1))
	memory.write_u32(track, memory.read_u32(obj + 0x18))
	memory.write_u32(track + 4, memory.read_u32(obj + 0x20))
	memory.write_u32(track + 8, C68kScript.u32(word_a))
	memory.write_u32(track + 0xc, C68kScript.u32(word_12))
	memory.write_u32(track + 0x10, 0)

## 0xfe96: an aircraft notices another object (its type word, signed).
## Player's aircraft: only in view modes 1 / 8 / 7 and for aircraft (type <= 4); one flying
## more than 1999 above its ground gets a radar track (0x24 below); a non-player aircraft
## (type != 1) closer than the designated one (metric +0x10, signed) becomes
## designated_entity_2 (its controller).
## AI aircraft (types 3, 4 and 0x15..0x19 by the jump table): one rng in 64, unless byte +0x63e
## is set, and only in AI states 0x110d4 / 0x11162: chance = ((other range +0x14 * 0x6720)
## divs.l 500 asl 6) divs.l distance (0x7fffffff at 0). Ships need probe_nearest_facility_kind
## 0x100 (0x24 below) and bombs (byte +0x67c); aircraft need state 0x110d4 and ammo (word +0x682)
## above 1. A held target (+0x692) halves the chance; rng & 0x7f below it takes the object
## (replacing a held one only when under half its distance +0x696; references moved). Taking a
## ship: invert_ai_bias_67b_if_positive, state 0x112c0, byte +0x675 = 0; an aircraft: state
## 0x110d4, then invert_ai_bias_67b_if_positive.
func aircraft_notice_object(self_obj: int, other_obj: int) -> void:
	assert(memory != null, "aircraft_notice_object requires original global memory")
	var entry_a7: int = a7
	var self_ctl: int = memory.read_u32(self_obj + 8)
	var other_ctl: int = memory.read_u32(other_obj + 8)
	var type: int = memory.read_s16(memory.read_u32(other_ctl + 4))
	if self_ctl == memory.read_u32(DAT_0001b738):
		var view: int = memory.read_s16(DAT_0001d858)
		if view != 1 and view != 8 and view != 7:
			return
		if type > 4:
			return
		if C68kScript.s32(memory.read_u32(other_obj + 0x1c) - memory.read_u32(other_ctl + 0x2e)) > 0x7cf:
			a7 = entry_a7 - 0x24
			add_radar_track(other_obj)
			a7 = entry_a7
		if type == 1:
			return
		var designated: int = memory.read_u32(DAT_0001b888)
		if designated != 0 and memory.read_s32(other_obj + 0x10) >= memory.read_s32(memory.read_u32(designated) + 0x10):
			return
		memory.write_u32(DAT_0001b888, other_ctl)
		return
	var ship: bool = type >= 0x15 and type <= 0x19
	if not (type == 3 or type == 4 or ship):
		return
	if (overlay_rng_next() & 0x3f) != 0:
		return
	if memory.read_u8(self_ctl + 0x63e) != 0:
		return
	var state: int = memory.read_u32(self_ctl + 0x32)
	if state != 0x110d4 and state != 0x11162:
		return
	var dist: int = approx_dist3_xyz(memory.read_s32(self_obj + 0x18), memory.read_s32(self_obj + 0x1c), memory.read_s32(self_obj + 0x20), memory.read_s32(other_obj + 0x18), memory.read_s32(other_obj + 0x1c), memory.read_s32(other_obj + 0x20))
	var chance: int = 0x7fffffff
	if dist != 0:
		var scaled: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s32(other_obj + 0x14) * 0x6720), 500)
		chance = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(scaled, 6)), dist)
	if ship:
		a7 = entry_a7 - 0x24
		var facility: int = probe_nearest_facility_kind(other_obj)
		a7 = entry_a7
		if facility != 0x100 or memory.read_u8(self_ctl + 0x67c) == 0:
			return
	elif type <= 4:
		if state == 0x11162 or memory.read_s16(self_ctl + 0x682) <= 1:
			return
	if memory.read_u32(self_ctl + 0x692) != 0:
		chance = chance >> 1
	if chance <= (overlay_rng_next() & 0x7f):
		return
	var held: int = memory.read_u32(self_ctl + 0x692)
	if held != 0:
		if C68kScript.s32(C68kScript.lsl32(dist, 1)) >= memory.read_s32(self_ctl + 0x696):
			return
		memory.write_u32(self_ctl + 0x696, C68kScript.u32(dist))
		memory.write_u8(held + 3, C68kScript.u8(memory.read_u8(held + 3) - 1))
		memory.write_u32(self_ctl + 0x692, other_obj)
	else:
		memory.write_u32(self_ctl + 0x692, other_obj)
		memory.write_u32(self_ctl + 0x696, C68kScript.u32(dist))
	memory.write_u8(other_obj + 3, C68kScript.u8(memory.read_u8(other_obj + 3) + 1))
	a7 = entry_a7 - 0x24
	if ship:
		invert_ai_bias_67b_if_positive(self_ctl)
		memory.write_u32(self_ctl + 0x32, 0x112c0)
		memory.write_u8(self_ctl + 0x675, 0)
	elif type <= 4:
		memory.write_u32(self_ctl + 0x32, 0x110d4)
		invert_ai_bias_67b_if_positive(self_ctl)
	a7 = entry_a7

## 0x100bc: drops the AI target's (+0x692) reference byte +3 and clears the target.
func release_ai_target(ctl: int) -> void:
	var target: int = memory.read_u32(ctl + 0x692)
	if target != 0:
		memory.write_u8(target + 3, C68kScript.u8(memory.read_u8(target + 3) - 1))
		memory.write_u32(ctl + 0x692, 0)

## 0x100d4: an enemy fighter notices another object. Only types 1, 2 and 0x15..0x19 (the jump
## table on type - 1) are considered; one rng in 64, unless byte +0x63e is set, in AI states
## 0x110d4 / 0x11162 / 0x111ba / 0x112c0; chance as in aircraft_notice_object.
## State 0x111ba (escort): with no target, a ship near an enemy facility
## (probe_nearest_facility_kind 0x200, 0x24 below) is taken when rng & 0x7f < chance.
## Other states: a held target halves the chance; rng & 0x7f below it lets the object compete
## (always without a target, else when under half the held distance). A ship near an enemy
## facility switches the AI to 0x111ba when damaged (word +0x684 & 0x3b2), else to the bombing
## state 0x112c0 (byte +0x675 = 0) when it has bombs, else is not taken; an aircraft (type <= 4)
## needs ammo (word +0x682 > 1) and sets 0x110d4. A switch also runs
## invert_ai_bias_67b_if_positive (0x24 below); the target and its references are then moved.
## The D0 the bytes leave is not modelled (callers of the notice handlers are not ported yet).
func enemy_fighter_notice_object(self_obj: int, other_obj: int) -> void:
	assert(memory != null, "enemy_fighter_notice_object requires original global memory")
	var entry_a7: int = a7
	var self_ctl: int = memory.read_u32(self_obj + 8)
	var type: int = memory.read_s16(memory.read_u32(memory.read_u32(other_obj + 8) + 4))
	var ship: bool = type >= 0x15 and type <= 0x19
	if not (type == 1 or type == 2 or ship):
		return
	if (overlay_rng_next() & 0x3f) != 0:
		return
	if memory.read_u8(self_ctl + 0x63e) != 0:
		return
	var state: int = memory.read_u32(self_ctl + 0x32)
	if state != 0x110d4 and state != 0x11162 and state != 0x111ba and state != 0x112c0:
		return
	var dist: int = approx_dist3_xyz(memory.read_s32(self_obj + 0x18), memory.read_s32(self_obj + 0x1c), memory.read_s32(self_obj + 0x20), memory.read_s32(other_obj + 0x18), memory.read_s32(other_obj + 0x1c), memory.read_s32(other_obj + 0x20))
	var chance: int = 0x7fffffff
	if dist != 0:
		var scaled: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s32(other_obj + 0x14) * 0x6720), 500)
		chance = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(scaled, 6)), dist)
	if state == 0x111ba:
		if memory.read_u32(self_ctl + 0x692) != 0 or not ship:
			return
		a7 = entry_a7 - 0x24
		var facility: int = probe_nearest_facility_kind(other_obj)
		a7 = entry_a7
		if facility != 0x200:
			return
		if chance <= (overlay_rng_next() & 0x7f):
			return
		memory.write_u32(self_ctl + 0x692, other_obj)
		memory.write_u32(self_ctl + 0x696, C68kScript.u32(dist))
		memory.write_u8(other_obj + 3, C68kScript.u8(memory.read_u8(other_obj + 3) + 1))
		return
	if memory.read_u32(self_ctl + 0x692) != 0:
		chance = chance >> 1
	if chance <= (overlay_rng_next() & 0x7f):
		return
	var held: int = memory.read_u32(self_ctl + 0x692)
	if held != 0 and C68kScript.s32(C68kScript.lsl32(dist, 1)) >= memory.read_s32(self_ctl + 0x696):
		return
	var take: bool = false
	if ship:
		a7 = entry_a7 - 0x24
		var facility2: int = probe_nearest_facility_kind(other_obj)
		a7 = entry_a7
		if facility2 == 0x200:
			if (memory.read_u16(self_ctl + 0x684) & 0x3b2) != 0:
				memory.write_u32(self_ctl + 0x32, 0x111ba)
				take = true
			elif memory.read_u8(self_ctl + 0x67c) != 0:
				memory.write_u32(self_ctl + 0x32, 0x112c0)
				memory.write_u8(self_ctl + 0x675, 0)
				take = true
	elif type <= 4 and memory.read_s16(self_ctl + 0x682) > 1:
		memory.write_u32(self_ctl + 0x32, 0x110d4)
		take = true
	if not take:
		return
	a7 = entry_a7 - 0x24
	invert_ai_bias_67b_if_positive(self_ctl)
	a7 = entry_a7
	if held != 0:
		memory.write_u32(self_ctl + 0x696, C68kScript.u32(dist))
		memory.write_u8(held + 3, C68kScript.u8(memory.read_u8(held + 3) - 1))
		memory.write_u32(self_ctl + 0x692, other_obj)
	else:
		memory.write_u32(self_ctl + 0x692, other_obj)
		memory.write_u32(self_ctl + 0x696, C68kScript.u32(dist))
	memory.write_u8(other_obj + 3, C68kScript.u8(memory.read_u8(other_obj + 3) + 1))

## 0x5832: one-dimensional sweep over a list of objects sorted by metric (+0x10) with radii
## (+0xc); count = word header +2 (dbra). designated_entity_2 is cleared first unless replay
## state 3. Each object whose reach (metric + radius) exceeds the smallest start (metric -
## radius) seen so far scans back over the earlier entries: an earlier object whose start lies
## below the reach is a pair - the definition +0x16 notice handler of each (when it has a
## controller and a handler) is jsr'd as (self, other), this object's first (0x30 below); an
## earlier object that does not reach ends the scan once its running minimum (+0x28) is above
## the reach. Every object then stores the running minimum start in +0x28.
func dispatch_overlap_collisions(list: int, header: int) -> void:
	assert(memory != null, "dispatch_overlap_collisions requires original global memory")
	var entry_a7: int = a7
	if memory.read_s16(DAT_0001b870) != 3:
		memory.write_u32(DAT_0001b888, 0)
	var left: int = memory.read_u16(header + 2)
	var min_start: int = 0x7fffffff
	var cursor: int = list
	while true:
		left = C68kScript.u16(left - 1)
		if left == 0xffff:
			break
		var obj: int = memory.read_u32(cursor)
		cursor += 4
		var reach: int = C68kScript.s32(memory.read_u32(obj + 0x10) + memory.read_u32(obj + 0xc))
		if min_start < reach:
			var back: int = cursor - 4
			var back_left: int = C68kScript.u16(C68kScript.asr32(back - list, 2))
			while true:
				back_left = C68kScript.u16(back_left - 1)
				if back_left == 0xffff:
					break
				back -= 4
				var other: int = memory.read_u32(back)
				var start: int = C68kScript.s32(memory.read_u32(other + 0x10) - memory.read_u32(other + 0xc))
				if reach <= start:
					if reach < memory.read_s32(other + 0x28):
						break
					continue
				for pair in [[obj, other], [other, obj]]:
					var ctl: int = memory.read_u32(pair[0] + 8)
					if ctl == 0:
						continue
					var notice: int = memory.read_u32(memory.read_u32(ctl + 4) + 0x16)
					if notice == 0:
						continue
					a7 = entry_a7 - 0x30
					_jsr(notice, [pair[0], pair[1]])
					a7 = entry_a7
		var own_start: int = C68kScript.s32(memory.read_u32(obj + 0x10) - memory.read_u32(obj + 0xc))
		if own_start < min_start:
			min_start = own_start
		memory.write_u32(obj + 0x28, C68kScript.u32(min_start))

## 0xfb2a: landing gear (definition +0xe animate handler of the aircraft records). It works
## while gear bit 1 (byte +0x67a) is set or the gear position byte +0x679 is neither 0x2d
## (down) nor 0 (up, via abs_int). Position 0 or 0x2d clears bit 1, others set it. Fully up:
## bit 0 set and every gear face (byte +0x17 == 1) hidden (+0x13 |= 2). Otherwise bit 0 is
## cleared; angle = -((0x2d - |pos|) asl 12) divs.l 0x2d & 0x3fff gives two matrices
## (build_attitude_matrix_3ang_alt(angle, angle, 0) / (angle, -angle & 0x3fff, 0), frame a6 -
## 0x1e / - 0x30, entered 0x8c / 0x9c below). Each gear face is shown and swung on the side of
## its first vertex (template x > 0: the first matrix about x = 0x46 << shift, else the second
## about -0x46 << shift, as words): its normal point (vertex +0x36 + face index) is rotated
## about template vertex 0, its vertices about (pivot, -0x1a << shift) - each through
## transform_vecs12_to_int3_by_matrix3 in place (low words in, longs out). Finally the body
## matrix 0x1d72c = build_attitude_matrix_x((word +0x626 - definition word +0x44) & 0x3fff,
## words +0x20 / +0x22 / +0x24) (0x8c below). Returns 1.
func animate_landing_gear(ctl: int) -> int:
	assert(memory != null, "animate_landing_gear requires original global memory")
	assert(a7 != 0, "animate_landing_gear needs a7 (its frame holds the gear matrices)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var matrix_pos: int = a6 - 0x1e
	var matrix_neg: int = a6 - 0x30
	var obj: int = memory.read_u32(ctl)
	var pos: int = memory.read_s8(ctl + 0x679)
	if (memory.read_u8(ctl + 0x67a) & 2) != 0 or (pos != 0x2d and abs_int(pos) > 0):
		var up: bool = pos == 0
		if up or pos == 0x2d:
			memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) & 0xfd)
		else:
			memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) | 2)
		var face: int = memory.read_u32(obj + 0x48)
		if up:
			memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) | 1)
			var left: int = memory.read_u16(obj + 0x3a)
			while true:
				left = C68kScript.u16(left - 1)
				if left == 0xffff:
					break
				if memory.read_u8(face + 0x17) == 1:
					memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) | 2)
				face += 0x20
		else:
			memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) & 0xfe)
			var angle: int = C68kScript.divs_trunc(C68kScript.s32(-C68kScript.lsl32(0x2d - abs_int(pos), 12)), 0x2d) & 0x3fff
			a7 = entry_a7 - 0x8c
			build_attitude_matrix_3ang_alt(angle, angle, 0, matrix_pos)
			a7 = entry_a7 - 0x9c
			build_attitude_matrix_3ang_alt(angle, (-angle) & 0x3fff, 0, matrix_neg)
			a7 = entry_a7
			var world: int = memory.read_u32(DAT_0001b5a0)
			var tmpl: int = C68kScript.u32(memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18) + memory.read_u32(world + 0x8c) + 0x22)
			var origin := [memory.read_u32(tmpl), memory.read_u32(tmpl + 4), memory.read_u32(tmpl + 8)]
			var n_off: int = memory.read_s16(obj + 0x36) * 0xc
			var verts: int = memory.read_u32(obj + 0x44)
			var shift: int = memory.read_s16(obj + 0x34)
			var x_pos: int = C68kScript.s16(C68kScript.lsl32(0x46, shift))
			var x_neg: int = C68kScript.s16(C68kScript.lsl32(-0x46, shift))
			var pivot_dy: int = C68kScript.s32(C68kScript.lsl32(0x1a, shift))
			var i: int = 0
			while i < memory.read_s16(obj + 0x3a):
				if memory.read_u8(face + 0x17) == 1:
					memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) & 0xfd)
					var idx: int = memory.read_u32(face + 0x18)
					var mat: int = matrix_neg
					var x_off: int = x_neg
					if memory.read_s32(tmpl + memory.read_s16(idx) * 0xc) > 0:
						mat = matrix_pos
						x_off = x_pos
					var src: int = tmpl + n_off + i * 0xc
					var dst: int = verts + n_off + i * 0xc
					for k in range(3):
						memory.write_u32(dst + 4 * k, C68kScript.u32(memory.read_u32(src + 4 * k) - origin[k]))
					transform_vecs12_to_int3_by_matrix3(1, dst, dst, mat)
					for k in range(3):
						memory.write_u32(dst + 4 * k, C68kScript.u32(memory.read_u32(dst + 4 * k) + origin[k]))
					var left2: int = memory.read_u16(face + 0x14)
					while true:
						left2 = C68kScript.u16(left2 - 1)
						if left2 == 0xffff:
							break
						var v: int = memory.read_s16(idx) * 0xc
						idx += 2
						var sv: int = tmpl + v
						var dv: int = verts + v
						memory.write_u32(dv, C68kScript.u32(memory.read_u32(sv) - x_off))
						memory.write_u32(dv + 4, C68kScript.u32(pivot_dy + memory.read_u32(sv + 4)))
						memory.write_u32(dv + 8, memory.read_u32(sv + 8))
						transform_vecs12_to_int3_by_matrix3(1, dv, dv, mat)
						memory.write_u32(dv, C68kScript.u32(memory.read_u32(dv) + x_off))
						memory.write_u32(dv + 4, C68kScript.u32(memory.read_u32(dv + 4) - pivot_dy))
				i += 1
				face += 0x20
	a7 = entry_a7 - 0x8c
	build_attitude_matrix_x((memory.read_s16(ctl + 0x626) - memory.read_s16(memory.read_u32(ctl + 4) + 0x44)) & 0x3fff, memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24), 0x1d72c)
	a7 = entry_a7
	return 1

## 0x8784: replay_request = 1 when airborne (long argument != 0), else 2.
func request_instant_replay(airborne: int) -> void:
	memory.write_u16(DAT_0001b86c, 1 if C68kScript.u32(airborne) != 0 else 2)

## 0x11670: spawn_smoke_plume(0x48, 0, 0, 0, 0, x, y, z) (0x2c below); when a plume comes back its
## eight trail points (+0x40 + 12 i) start at the plume object's position, the object's long +4
## loses bit 0x100000 and its word +0x34 is cleared, +0x3c = the owner's object, whose reference
## byte +3 rises.
func attach_trailing_plume(x: int, y: int, z: int, owner: int) -> void:
	assert(memory != null, "attach_trailing_plume requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x2c
	var plume: int = spawn_smoke_plume(0x48, 0, 0, 0, 0, x, y, z)
	a7 = entry_a7
	if plume == 0:
		return
	var plume_obj: int = memory.read_u32(plume)
	for i in range(8):
		for k in range(3):
			memory.write_u32(plume + 0x40 + 12 * i + 4 * k, memory.read_u32(plume_obj + 0x18 + 4 * k))
	memory.write_u32(plume_obj + 4, memory.read_u32(plume_obj + 4) & 0xffefffff)
	memory.write_u16(plume_obj + 0x34, 0)
	var owner_obj: int = memory.read_u32(owner)
	memory.write_u32(plume + 0x3c, owner_obj)
	memory.write_u8(owner_obj + 3, C68kScript.u8(memory.read_u8(owner_obj + 3) + 1))

## 0x170ba: spawn_mission_pool_object(ground_fire_template, x, y, z, 0, 0, 0, 0) (0x28 below);
## the controller gets word +0x34 = 1 (state 1) and +0x32 = 0x2d (timer); null -> 0.
func spawn_ground_fire_object(x: int, y: int, z: int) -> int:
	assert(memory != null, "spawn_ground_fire_object requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x28
	var obj: int = spawn_mission_pool_object(memory.read_u32(DAT_00026658), x, y, z, 0, 0, 0, 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var ctl: int = memory.read_u32(obj + 8)
	memory.write_u16(ctl + 0x34, 1)
	memory.write_u16(ctl + 0x32, 0x2d)
	return ctl

## 0x17102: spawn_ground_fire_object (0x14 below); a fire follows the owner's object (+0x50),
## whose reference byte +3 rises; returns the fire, or 0 when none came back or its +0 is clear.
func attach_ground_fire(x: int, y: int, z: int, owner_ctl: int) -> int:
	assert(memory != null, "attach_ground_fire requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x14
	var fire: int = spawn_ground_fire_object(x, y, z)
	a7 = entry_a7
	if fire == 0:
		return 0
	var owner_obj: int = memory.read_u32(owner_ctl)
	memory.write_u32(fire + 0x50, owner_obj)
	memory.write_u8(owner_obj + 3, C68kScript.u8(memory.read_u8(owner_obj + 3) + 1))
	return fire if memory.read_u32(fire) != 0 else 0

## 0x17ffe: clears every mission_target_list entry (long at +6 + 4 i, i < word +2) holding this
## aircraft, counting the live word +0 down for each; once it reaches 0, host word +0xce is set to
## 1 when still 0.
func remove_mission_target(aircraft: int) -> void:
	assert(memory != null, "remove_mission_target requires original global memory")
	var i: int = 0
	while i < memory.read_s16(memory.read_u32(DAT_00020adc) + 2):
		var list: int = memory.read_u32(DAT_00020adc)
		if memory.read_u32(list + 6 + i * 4) == C68kScript.u32(aircraft):
			memory.write_u32(list + 6 + i * 4, 0)
			memory.write_u16(list, C68kScript.u16(memory.read_u16(list) - 1))
		i = C68kScript.s16(i + 1)
	var host: int = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(memory.read_u32(DAT_00020adc)) == 0 and memory.read_u16(host + 0xce) == 0:
		memory.write_u16(host + 0xce, 1)

## 0x10650: one damage step of an aircraft controller (word +0x684 damage, +0x686 last frame,
## +0x688 stage timer). A running timer counts down and hides the stage bits (0x3c0) for this
## step. Stage pass (repeated while bits become newly set; the next pass sees only the newly
## set bits, with the newly cleared ones as "previous"): exactly 0x40 (smoking) - new:
## attach_smoke_trail; old: rng bit 0 clears it and a second rng bit 0 escalates to 0x80, else
## 0x200; 0x80 - with the previous low byte negative (0x80 already) an rng & 3 == 0 turns it
## into 0x200; 0x100 (burning) - with damage bit 0x800 the timer is 0x16, else a timer is armed;
## new: attach_trailing_plume; old: bit 0x800 or rng bit 0 turns it into 0x400 (destroyed); 0x40
## / 0x80 / 0x200 arm a timer. Each pass writes the changed bits into +0x684.
## Then: newly destroyed (0x400 now, not last frame) - for the player, request_instant_replay
## (airborne unless 0x800), host +0x98 = 2 in live play, view_follow_target =
## designated_entity_2, and while replaying host +0xd4 = 1 (no parachute) or 4 (abandoned
## aircraft); stage bits cleared; spawn_destruction_effect(obj, 300 in state 0x111ba else 100)
## with replay_state forced to -1 around it; in live play the mission-5 / 6 outcome flags (host
## +0xce), mission 7's remove_mission_target, and the kill tally (object word +0x50 when damage
## bit 0x8000: positive -> host word +0xb8 + 2 n, else +0xd2); then dispatch_entity_cleanup.
## Newly 0x1000 (crashed): attach_ground_fire at the ground height (+0x2e). An AI aircraft with
## 0x100 bails out (byte +0x677 = 1) on rng & 0x1f == 0 unless diving (0x111ba) or in host mode
## 2. The player newly at bit 0x1: flags 0x1b874 = 1, 0x1b872 = 0 and, without a parachute,
## host +0xd4 = 1 and snd_ugh = 1. An armed timer becomes 0x7f + ((rng & 0xff) >> 1). Finally
## +0x686 = +0x684. (The D0 the bytes leave is not used by aircraft_tick and is not modelled.)
func update_aircraft_damage_state(ctl: int) -> void:
	assert(memory != null, "update_aircraft_damage_state requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	var timer_range: int = 0
	var damage: int = memory.read_u16(ctl + 0x684)
	var prev: int = memory.read_u16(ctl + 0x686)
	if memory.read_u16(ctl + 0x688) != 0:
		memory.write_u16(ctl + 0x688, C68kScript.u16(memory.read_u16(ctl + 0x688) - 1))
		damage = damage & 0xfc3f
	while true:
		var before: int = damage
		var stage: int = damage & 0x3c0
		if stage == 0x40:
			timer_range = 0xff
			if (prev & 0x40) == 0:
				a7 = entry_a7 - 0x2c
				attach_smoke_trail(memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), ctl)
				a7 = entry_a7
			elif (overlay_rng_next() & 1) != 0:
				damage = damage & 0xffbf
				if (overlay_rng_next() & 1) != 0:
					damage = damage | 0x80
				else:
					damage = damage | 0x200
		elif stage == 0x80:
			timer_range = 0xff
			if (prev & 0x80) != 0 and (overlay_rng_next() & 3) == 0:
				damage = (damage & 0xff7f) | 0x200
		elif stage == 0x100:
			if (memory.read_u8(ctl + 0x684) & 8) != 0:
				memory.write_u16(ctl + 0x688, 0x16)
			else:
				timer_range = 0xff
			if (prev & 0x100) == 0:
				a7 = entry_a7 - 0x2c
				attach_trailing_plume(memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), ctl)
				a7 = entry_a7
			elif (memory.read_u8(ctl + 0x684) & 8) != 0 or (overlay_rng_next() & 1) != 0:
				damage = (damage & 0xfeff) | 0x400
		elif stage == 0x200:
			timer_range = 0xff
		var changed: int = (before ^ damage) & 0xffff
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & (~changed & 0xffff))
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | (changed & damage))
		prev = before & changed
		damage = changed & damage
		if damage == 0:
			break
	var host: int = memory.read_u32(DAT_0001b5a0)
	var player: int = memory.read_u32(DAT_0001b738)
	if (memory.read_u8(ctl + 0x684) & 4) != 0 and (memory.read_u8(ctl + 0x686) & 4) == 0:
		if ctl == player:
			a7 = entry_a7 - 0x20
			request_instant_replay(0 if (memory.read_u8(ctl + 0x684) & 8) != 0 else 1)
			a7 = entry_a7
			if memory.read_u16(DAT_0001b870) == 0:
				memory.write_u16(host + 0x98, 2)
			memory.write_u32(DAT_0001b884, memory.read_u32(DAT_0001b888))
			if memory.read_u16(DAT_0001b870) != 0:
				if memory.read_u32(DAT_0001b87c) == 0:
					memory.write_u16(host + 0xd4, 1)
				elif memory.read_u16(DAT_0001b87a) != 0:
					memory.write_u16(host + 0xd4, 4)
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xfc3f)
		var saved: int = memory.read_u16(DAT_0001b870)
		memory.write_u16(DAT_0001b870, 0xffff)
		a7 = entry_a7 - 0x24
		spawn_destruction_effect(obj, 300 if memory.read_u32(ctl + 0x32) == 0x111ba else 100)
		a7 = entry_a7
		memory.write_u16(DAT_0001b870, saved)
		if saved == 0:
			var type: int = memory.read_s16(memory.read_u32(ctl + 4))
			if memory.read_s16(host + 0x90) == 5 and type == 2 and memory.read_u16(host + 0xce) == 0:
				memory.write_u16(host + 0xce, 0xffff)
			if memory.read_s16(host + 0x90) == 6 and type == 3 and memory.read_u16(host + 0xce) == 0:
				memory.write_u16(host + 0xce, 1)
			if memory.read_s16(host + 0x90) == 7:
				a7 = entry_a7 - 0x20
				remove_mission_target(ctl)
				a7 = entry_a7
			var tally: int = memory.read_s16(obj + 0x50)
			if tally != 0 and memory.read_s8(ctl + 0x684) < 0:
				var counter: int = host + 0xb8 + tally * 2 if tally > 0 else host + 0xd2
				memory.write_u16(counter, C68kScript.u16(memory.read_u16(counter) + 1))
		a7 = entry_a7 - 0x20
		dispatch_entity_cleanup(obj)
		a7 = entry_a7
	if (memory.read_u8(ctl + 0x684) & 0x10) != 0 and (memory.read_u8(ctl + 0x686) & 0x10) == 0:
		a7 = entry_a7 - 0x2c
		attach_ground_fire(memory.read_u32(obj + 0x18), memory.read_u32(ctl + 0x2e), memory.read_u32(obj + 0x20), ctl)
		a7 = entry_a7
	if (memory.read_u8(ctl + 0x684) & 1) != 0 and memory.read_u8(ctl + 0x677) == 0 and ctl != player:
		if (overlay_rng_next() & 0x1f) == 0 and memory.read_u32(ctl + 0x32) != 0x111ba and memory.read_s16(host + 0x90) != 2:
			memory.write_u8(ctl + 0x677, 1)
	if ctl == player and (memory.read_u8(ctl + 0x685) & 1) != 0 and (memory.read_u8(ctl + 0x687) & 1) == 0:
		memory.write_u16(DAT_0001b874, 1)
		memory.write_u16(DAT_0001b872, 0)
		if memory.read_u32(DAT_0001b87c) == 0:
			memory.write_u16(host + 0xd4, 1)
			memory.write_u16(DAT_0001b844, 1)
	if timer_range != 0:
		var r: int = overlay_rng_next() & 0xffff
		memory.write_u16(ctl + 0x688, C68kScript.u16(((timer_range & r) >> 1) + (timer_range >> 1)))
	memory.write_u16(ctl + 0x686, memory.read_u16(ctl + 0x684))

## 0xe5aa: aircraft tick (definition +2). The pose ring (75 entries of 0x14 bytes at +0x36,
## index word +0x612, wrapping at 0x4b) records or replays the aircraft.
## Live play: a destroyed aircraft (damage 0x400 now and last frame) stops (velocity +8 / +0xc /
## +0x10 = 0), otherwise its AI / flight handler (+0x32) runs (jsr, 0x18 below); then
## update_aircraft_damage_state (0x18 below) and the entry records position + velocity, the
## angle words +0x20 / +0x22 / +0x24 and the damage word.
## Replay: nothing before the object's start frame (+0x40). On a rewind (state 1) or the start
## frame the aircraft jumps to the entry: velocity 0, position, timer +0x688 = 0, +0x686 =
## damage & 0xeeff, +0x684 = damage, gear byte +0x679 = 0 when damage bit 0x2000 (gear up) else
## 0x2d; a recorded stage without 0x1000 restarts as smoking (0x40). Otherwise the velocity
## is the step to the entry, the damage word is taken over and the timer +0x688 is 1 when the
## stage bits did not change (else 0). Either way the angles are copied back and the damage step
## runs. The gear-bit test that follows (0x2000 of +0x684 against +0x686, moving the gear byte
## to -|player gear| or |player gear|) can never fire, because the damage step always ends with
## +0x686 = +0x684; it is kept as in the bytes. Finally +0x686 = the damage word before the step.
func aircraft_tick(ctl: int) -> void:
	assert(memory != null, "aircraft_tick requires original global memory")
	var entry_a7: int = a7
	var pose: int = ctl + 0x36 + memory.read_s16(ctl + 0x612) * 0x14
	memory.write_u16(ctl + 0x612, C68kScript.u16(memory.read_u16(ctl + 0x612) + 1))
	if memory.read_u16(ctl + 0x612) == 0x4b:
		memory.write_u16(ctl + 0x612, 0)
	var obj: int = memory.read_u32(ctl)
	if memory.read_u16(DAT_0001b870) == 0:
		if (memory.read_u8(ctl + 0x684) & 4) != 0 and (memory.read_u8(ctl + 0x686) & 4) != 0:
			for k in range(3):
				memory.write_u32(ctl + 8 + 4 * k, 0)
		else:
			a7 = entry_a7 - 0x18
			_jsr(memory.read_u32(ctl + 0x32), [ctl])
			a7 = entry_a7
		a7 = entry_a7 - 0x18
		update_aircraft_damage_state(ctl)
		a7 = entry_a7
		for k in range(3):
			memory.write_u32(pose + 4 * k, C68kScript.u32(memory.read_u32(obj + 0x18 + 4 * k) + memory.read_u32(ctl + 8 + 4 * k)))
		memory.write_u16(pose + 0xc, memory.read_u16(ctl + 0x20))
		memory.write_u16(pose + 0xe, memory.read_u16(ctl + 0x22))
		memory.write_u16(pose + 0x10, memory.read_u16(ctl + 0x24))
		memory.write_u16(pose + 0x12, memory.read_u16(ctl + 0x684))
		return
	var frame: int = memory.read_s32(DAT_0001b838)
	if frame < memory.read_s32(obj + 0x40):
		return
	var recorded: int = memory.read_u16(pose + 0x12)
	if memory.read_s16(DAT_0001b870) == 1 or frame == memory.read_s32(obj + 0x40):
		for k in range(3):
			memory.write_u32(ctl + 8 + 4 * k, 0)
			memory.write_u32(obj + 0x18 + 4 * k, memory.read_u32(pose + 4 * k))
		memory.write_u16(ctl + 0x688, 0)
		memory.write_u16(ctl + 0x686, recorded & 0xeeff)
		memory.write_u16(ctl + 0x684, recorded)
		memory.write_u8(ctl + 0x679, 0 if (memory.read_u8(ctl + 0x684) & 0x20) != 0 else 0x2d)
		if (recorded & 0x3c0) != 0 and (memory.read_u8(pose + 0x12) & 0x10) == 0:
			memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xfc3f)
			memory.write_u16(ctl + 0x686, memory.read_u16(ctl + 0x686) & 0xfc3f)
			memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x40)
	else:
		for k in range(3):
			memory.write_u32(ctl + 8 + 4 * k, C68kScript.u32(memory.read_u32(pose + 4 * k) - memory.read_u32(obj + 0x18 + 4 * k)))
		memory.write_u16(ctl + 0x684, recorded)
		memory.write_u16(ctl + 0x688, 0 if ((memory.read_u16(ctl + 0x684) ^ memory.read_u16(ctl + 0x686)) & 0x3c0) != 0 else 1)
	memory.write_u16(ctl + 0x20, memory.read_u16(pose + 0xc))
	memory.write_u16(ctl + 0x22, memory.read_u16(pose + 0xe))
	memory.write_u16(ctl + 0x24, memory.read_u16(pose + 0x10))
	var flags_now: int = memory.read_u16(ctl + 0x684)
	a7 = entry_a7 - 0x18
	update_aircraft_damage_state(ctl)
	a7 = entry_a7
	if ((memory.read_u16(ctl + 0x684) ^ memory.read_u16(ctl + 0x686)) & 0x2000) != 0:
		var player_gear: int = abs_int(memory.read_s8(memory.read_u32(DAT_0001b738) + 0x679))
		if (memory.read_u8(ctl + 0x684) & 0x20) != 0:
			memory.write_u8(ctl + 0x679, C68kScript.u8(-player_gear))
		else:
			memory.write_u8(ctl + 0x679, C68kScript.u8(player_gear))
			if memory.read_u8(ctl + 0x679) == 0:
				memory.write_u8(ctl + 0x679, 1)
	memory.write_u16(ctl + 0x686, flags_now)

## 0xe42a: altitude curve lookup: band = altitude asr 16, at most 7 (a negative band is not
## clamped, as in the bytes); result = sext(low word of entry[band] + ((entry[band + 1] -
## entry[band]) muls.l (altitude & 0xffff) asr 16)) - a word add.
func table_lerp_1b2c0(altitude: int) -> int:
	assert(memory != null, "table_lerp_1b2c0 requires the altitude table in memory")
	var band: int = C68kScript.asr32(altitude, 16)
	if band > 7:
		band = 7
	var entry: int = DAT_0001b2c0 + band * 4
	var delta: int = C68kScript.s32(memory.read_u32(entry + 4) - memory.read_u32(entry))
	var step: int = C68kScript.asr32(C68kScript.s32(delta * (C68kScript.u32(altitude) & 0xffff)), 16)
	return C68kScript.s16(step + memory.read_u16(entry + 2))

## 0xe468: below 0x200 above the ground the density word is reduced by ((0x200 - height) *
## density) asr 12 (rounded toward zero); returns the word sign-extended.
func damp_short_if_below_0x200(height: int, density: int) -> int:
	var d: int = C68kScript.s16(density)
	height = C68kScript.s32(height)
	if height <= 0x1ff:
		var r: int = C68kScript.s32(d * C68kScript.s32(-(height - 0x200)))
		if r < 0:
			r = C68kScript.s32(r + 0xfff)
		d = C68kScript.s16(d - (r >> 12))
	return d

## 0xe4a4: lift coefficient from the angle of attack (word +0x626) and flaps (byte +0x67b) for
## aircraft_type_rec: base / slope = +0x26 / +0x28, blended toward +0x2a / +0x2c by |flaps| / 15
## (muls.l, divs.l). Up to the stall angle +0x34: base + (slope * aoa) / 64 (toward zero); past
## it the out byte is set to 0xc and the lift at the stall fades over 0x20 more: (0x20 - (aoa
## - stall), at least 0) * (slope * stall + base) / 2048 (toward zero). Returns the word
## sign-extended.
func compute_template_force_from_626(aoa: int, flaps: int, smooth_frames: int) -> int:
	assert(memory != null, "compute_template_force_from_626 requires original global memory")
	var rec: int = memory.read_u32(DAT_00026004)
	aoa = C68kScript.s16(aoa)
	flaps = C68kScript.s16(flaps)
	var lift: int
	var slope: int
	if flaps == 0:
		lift = memory.read_s16(rec + 0x26)
		slope = memory.read_s16(rec + 0x28)
	else:
		var f: int = C68kScript.s16(abs_int(flaps))
		lift = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32((memory.read_s16(rec + 0x2a) - memory.read_s16(rec + 0x26)) * f), 15)) + memory.read_s16(rec + 0x26)
		slope = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32((memory.read_s16(rec + 0x2c) - memory.read_s16(rec + 0x28)) * f), 15) + memory.read_s16(rec + 0x28))
	var stall: int = memory.read_s16(rec + 0x34)
	if aoa <= stall:
		var t: int = C68kScript.s32(C68kScript.s16(slope) * aoa)
		if t < 0:
			t = C68kScript.s32(t + 0x3f)
		return C68kScript.s16((t >> 6) + C68kScript.s16(lift))
	memory.write_u8(smooth_frames, 0xc)
	var fade: int = C68kScript.s32(0x20 - (aoa - stall))
	if fade < 0:
		fade = 0
	var peak: int = C68kScript.s32(C68kScript.s32(stall * C68kScript.s16(slope)) + C68kScript.s16(lift))
	var t2: int = C68kScript.s32(peak * fade)
	if t2 < 0:
		t2 = C68kScript.s32(t2 + 0x7ff)
	return C68kScript.s16(t2 >> 11)

## 0xe570: *out = (aircraft_type_rec long +0x38 * word(0x551a divs.w word((density + 0x105) asr
## 3))) asr 8 - the rated power at this air density.
func scale_template_field_38(density: int, out: int) -> void:
	assert(memory != null, "scale_template_field_38 requires original global memory")
	var divisor: int = C68kScript.s16(C68kScript.asr32(C68kScript.s16(density) + 0x105, 3))
	var q: int = C68kScript.s16(C68kScript.divs_trunc(0x551a, divisor))
	memory.write_u32(out, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_s32(memory.read_u32(DAT_00026004) + 0x38) * q), 8)))

## 0x10c2c: AI throttle: speed error = target - word(airspeed +0x62a asr 2); acc = 33 * error
## - 32 * previous error (+0x620) + remainder (+0x63c) (word arithmetic); the new remainder is
## acc % 256 (toward zero) and the throttle byte +0x668 moves by acc / 256 (toward zero),
## clamped to 0..9. acc < -0x438 lowers the gear (byte +0x679 0 -> 1); acc > 0x1c2 opens up
## fully (max_ai_throttle_maybe_invert_679).
func adjust_ai_throttle_vs_speed(ctl: int, target_speed: int) -> void:
	assert(memory != null, "adjust_ai_throttle_vs_speed requires original global memory")
	var err: int = C68kScript.s16(C68kScript.s16(target_speed) - C68kScript.asr32(memory.read_u32(ctl + 0x62a), 2))
	var delta: int = C68kScript.s16(err - memory.read_s16(ctl + 0x620))
	memory.write_u16(ctl + 0x620, C68kScript.u16(err))
	var acc: int = C68kScript.s16(err + memory.read_s16(ctl + 0x63c) + C68kScript.s16(delta << 5))
	var rounded: int = C68kScript.s16(acc + 0xff) if acc < 0 else acc
	memory.write_u16(ctl + 0x63c, C68kScript.u16(acc - C68kScript.s16(rounded & 0xff00)))
	memory.write_u8(ctl + 0x668, C68kScript.u8(memory.read_u8(ctl + 0x668) + (rounded >> 8)))
	if memory.read_s8(ctl + 0x668) < 0:
		memory.write_u8(ctl + 0x668, 0)
	elif memory.read_s8(ctl + 0x668) > 9:
		memory.write_u8(ctl + 0x668, 9)
	if acc < -0x438:
		if memory.read_u8(ctl + 0x679) == 0:
			memory.write_u8(ctl + 0x679, 1)
	elif acc > 0x1c2:
		max_ai_throttle_maybe_invert_679(ctl)

## 0x10cb2: throttle byte +0x668 = 9; a gear moving down (byte +0x679 > 0) more than 100 above
## the ground is sent back up (negated).
func max_ai_throttle_maybe_invert_679(ctl: int) -> void:
	memory.write_u8(ctl + 0x668, 9)
	var gear: int = memory.read_s8(ctl + 0x679)
	if gear > 0 and C68kScript.s32(memory.read_u32(memory.read_u32(ctl) + 0x1c) - memory.read_u32(ctl + 0x2e)) > 100:
		memory.write_u8(ctl + 0x679, C68kScript.u8(-gear))

## 0x102d6: angle of the word vector (dx, dz), 0x4000 per turn: |dz| < |dx| (words) ->
## 0x1000 - atan((dz asl 12) / |dx|), negated when dx > 0; else dz != 0 -> atan((-dx asl 12) /
## |dz|), 0x2000 - that when dz < 0; & 0x3fff. For (0, 0) the result register D2 is never
## written, so the caller's D2 comes back (d2_in & 0x3fff).
func atan2_fixed14(dx: int, dz: int, d2_in: int = 0) -> int:
	dx = C68kScript.s16(dx)
	dz = C68kScript.s16(dz)
	var abs_x: int = C68kScript.s16(abs_int(dx))
	var abs_z: int = C68kScript.s16(abs_int(dz))
	var d2: int = C68kScript.u32(d2_in)
	if abs_z < abs_x:
		d2 = C68kScript.u16(0x1000 - atan_fixed14(C68kScript.divs_trunc(C68kScript.s32(dz << 12), abs_x)))
		if dx > 0:
			d2 = C68kScript.u16(-d2)
	elif dz != 0:
		d2 = atan_fixed14(C68kScript.divs_trunc(C68kScript.s32((-dx) << 12), abs_z))
		if dz < 0:
			d2 = C68kScript.u16(0x2000 - d2)
	return d2 & 0x3fff

## 0x10558: control inputs into the 4-entry ring (+0x642 index; aileron +0x644, elevator +0x64c,
## rudder +0x654 slots; running sums +0x65c / +0x65e / +0x660), clamped to +-0x140 / +-0x200 /
## +-0x40: the new value is added, the next slot's value (written 3 calls ago) subtracted, and
## the outputs +0x666 / +0x662 / +0x664 = sum / 4 toward zero. Nothing when the damage byte +0x685
## has bit 0 (word bit 0x100).
func enqueue_control_inputs_avg4(ctl: int, rudder: int, elevator: int, aileron: int) -> void:
	assert(memory != null, "enqueue_control_inputs_avg4 requires original global memory")
	if (memory.read_u8(ctl + 0x685) & 1) != 0:
		return
	var inputs := [[C68kScript.s16(aileron), 0x140, 0x644, 0x65c, 0x666], [C68kScript.s16(elevator), 0x200, 0x64c, 0x65e, 0x662], [C68kScript.s16(rudder), 0x40, 0x654, 0x660, 0x664]]
	for c in inputs:
		if abs_int(c[0]) > c[1]:
			c[0] = -c[1] if c[0] < 0 else c[1]
	var ring: int = memory.read_s16(ctl + 0x642)
	for c in inputs:
		memory.write_u16(ctl + c[2] + ring * 2, C68kScript.u16(c[0]))
		memory.write_u16(ctl + c[3], C68kScript.u16(memory.read_u16(ctl + c[3]) + c[0]))
	ring = C68kScript.s16(ring + 1)
	if ring == 4:
		ring = 0
	for c in inputs:
		memory.write_u16(ctl + c[3], C68kScript.u16(memory.read_u16(ctl + c[3]) - memory.read_u16(ctl + c[2] + ring * 2)))
		var sum: int = memory.read_s16(ctl + c[3])
		if sum < 0:
			sum += 3
		memory.write_u16(ctl + c[4], C68kScript.u16(sum >> 2))
	memory.write_u16(ctl + 0x642, C68kScript.u16(ring))

## 0x10360: the target seen from the aircraft. height = obj y + 0x2d * vertical speed (+0xc) -
## ground (+0x2e) goes to *height_out; below 4000 the target is raised by (4000 - height) (and
## at or below 1000 the AI opens up fully: max_ai_throttle_maybe_invert_679, 0x4c below) and
## the function returns 1, else 0. Offsets dx / dy / dz; far away (|dx| + |dz| > 0x8000) the
## climb is limited: aim = |dy| > 0x800 ? horiz / 4 : (horiz / 256) * |dy| / 32 (toward zero,
## signed like dy), blended back toward dy while horiz <= 0xffff ((aim - dy) * (horiz - 0x8000)
## / 0x8000). The vector, shifted to fit 15 bits, is written as words +2 / +6 / +10 of vec,
## rotated by the inverse attitude (build_attitude_matrix_3ang_alt of the negated angle words,
## frame a6 - 0x12, 0x58 below; transform_vecs12_by_matrix3 in place), and aimed at
## (attitude_from_velocity into the frame words a6 - 0x14 / - 0x16, isqrt 0x4c / attitude 0x68
## below); the folded pitch / heading go to *pitch_err / *heading_err (words).
func build_relative_steer_sample(ctl: int, x: int, y: int, z: int, height_out: int, vec: int, pitch_err: int, heading_err: int) -> int:
	assert(memory != null, "build_relative_steer_sample requires original global memory")
	assert(a7 != 0, "build_relative_steer_sample needs a7 (its frame holds the matrix and angles)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var obj: int = memory.read_u32(ctl)
	var height: int = C68kScript.s32(C68kScript.s32(0x2d * memory.read_s32(ctl + 0xc)) + memory.read_u32(obj + 0x1c) - memory.read_u32(ctl + 0x2e))
	memory.write_u32(height_out, C68kScript.u32(height))
	var low: int = 0
	var ty: int = C68kScript.s32(y)
	if height <= 0xf9f:
		ty = C68kScript.s32(ty + 0xfa0 - height)
		if height <= 0x3e8:
			a7 = entry_a7 - 0x4c
			max_ai_throttle_maybe_invert_679(ctl)
			a7 = entry_a7
		low = 1
	var dx: int = C68kScript.s32(C68kScript.s32(x) - memory.read_u32(obj + 0x18))
	var horiz: int = abs_int(dx)
	var dy: int = C68kScript.s32(ty - memory.read_u32(obj + 0x1c))
	var abs_dy: int = abs_int(dy)
	var dz: int = C68kScript.s32(C68kScript.s32(z) - memory.read_u32(obj + 0x20))
	horiz = C68kScript.s32(horiz + abs_int(dz))
	if horiz > 0x8000:
		var aim: int
		if abs_dy > 0x800:
			aim = horiz
			if aim < 0:
				aim += 3
			aim = aim >> 2
		else:
			var h: int = horiz
			if h < 0:
				h += 0xff
			aim = C68kScript.s32((h >> 8) * abs_dy)
			if aim < 0:
				aim += 0x1f
			aim = aim >> 5
		if dy < 0:
			aim = -aim
		if horiz <= 0xffff:
			var t: int = C68kScript.s32((aim - dy) * (horiz - 0x8000))
			if t < 0:
				t += 0x7fff
			dy = C68kScript.s32(dy + (t >> 15))
		else:
			dy = aim
		abs_dy = abs_int(dy)
	var span: int = C68kScript.u32(horiz + abs_dy)
	var shift: int = 0
	while (span & 0xffff8000) != 0:
		shift += 1
		span = C68kScript.u32(C68kScript.asr32(span, 1))
	memory.write_u16(vec + 2, C68kScript.u16(C68kScript.asr32(dx, shift)))
	memory.write_u16(vec + 6, C68kScript.u16(C68kScript.asr32(dy, shift)))
	memory.write_u16(vec + 10, C68kScript.u16(C68kScript.asr32(dz, shift)))
	var matrix: int = a6 - 0x12
	a7 = entry_a7 - 0x58
	build_attitude_matrix_3ang_alt((-memory.read_s16(ctl + 0x20)) & 0x3fff, (-memory.read_s16(ctl + 0x22)) & 0x3fff, (-memory.read_s16(ctl + 0x24)) & 0x3fff, matrix)
	a7 = entry_a7
	transform_vecs12_by_matrix3(1, vec, vec, matrix)
	var sq: int = 0
	for off in [2, 6, 10]:
		sq = C68kScript.s32(sq + memory.read_s16(vec + off) * memory.read_s16(vec + off))
	var length: int = isqrt_floor(sq)
	attitude_from_velocity(memory.read_s16(vec + 2), memory.read_s16(vec + 6), memory.read_s16(vec + 10), C68kScript.s16(length), sq, a6 - 0x14, a6 - 0x16)
	memory.write_u16(pitch_err, C68kScript.u16(fold_angle_pm_0x2000(memory.read_s16(a6 - 0x14))))
	memory.write_u16(heading_err, C68kScript.u16(fold_angle_pm_0x2000(memory.read_s16(a6 - 0x16))))
	return low

## 0x109ba: steering. Small errors (both within 0x500) at or above the ground: elevator = 5 *
## pitch - 4 * previous pitch (+0x61a), aileron = 2 * heading - previous heading (+0x61c),
## rudder = aileron asr 4. Otherwise a bank toward the target: bank error = fold(atan2(vec +2,
## vec +6)); below 0x5000 the target bank (current bank +0x24 + error) is limited to a height-
## dependent maximum (0 below the ground, the height up to 0x1000, then 0x1000 + (height -
## 0x1000) / 4; mirrored past 0x2000) and the error recomputed; aileron = the error, or within
## 0x280 (3 * error - 2 * previous +0x61e) / 2; elevator = (cos(error) asl 9) asr 12; rudder 0;
## +0x61e = error. The errors are kept in +0x61a / +0x61c and the commands queued
## (enqueue_control_inputs_avg4, 0x3c below). d2_in is the caller's D2, which atan2_fixed14
## returns for a zero vector.
func apply_relative_heading_steer(ctl: int, height: int, vec: int, pitch_err: int, heading_err: int, d2_in: int = 0) -> void:
	assert(memory != null, "apply_relative_heading_steer requires original global memory")
	var entry_a7: int = a7
	height = C68kScript.s32(height)
	pitch_err = C68kScript.s16(pitch_err)
	heading_err = C68kScript.s16(heading_err)
	var rudder: int = 0
	var elevator: int
	var aileron: int
	if abs_int(heading_err) <= 0x500 and abs_int(pitch_err) <= 0x500 and height >= 0:
		elevator = C68kScript.s16((C68kScript.s16(pitch_err - memory.read_s16(ctl + 0x61a)) << 2) + pitch_err)
		aileron = C68kScript.s16(heading_err + (heading_err - memory.read_s16(ctl + 0x61c)))
		rudder = aileron >> 4
	else:
		var bank_err: int = C68kScript.s16(fold_angle_pm_0x2000(atan2_fixed14(memory.read_s16(vec + 2), memory.read_s16(vec + 6), d2_in)))
		if height <= 0x4fff:
			var target: int = C68kScript.u16(bank_err + memory.read_u16(ctl + 0x24)) & 0x3fff
			var limit: int
			if height < 0:
				limit = 0
			elif height <= 0xfff:
				limit = C68kScript.s16(height)
			else:
				var t: int = C68kScript.s32((height - 0x1000) << 12)
				if t < 0:
					t += 0x3fff
				limit = C68kScript.s16((t >> 14) + 0x1000)
			if target > 0x2000:
				limit = C68kScript.s16(0x4000 - limit)
				if target < limit:
					target = limit
			elif target > limit:
				target = limit
			bank_err = C68kScript.s16(fold_angle_pm_0x2000((C68kScript.s16(target) - memory.read_s16(ctl + 0x24)) & 0x3fff))
		if abs_int(bank_err) > 0x280:
			aileron = bank_err
		else:
			aileron = C68kScript.s16(C68kScript.asr32(bank_err + 2 * (bank_err - memory.read_s16(ctl + 0x61e)), 1))
		elevator = C68kScript.s16(C68kScript.asr32(C68kScript.lsl32(cos_fixed14(bank_err & 0x3fff), 9), 12))
		memory.write_u16(ctl + 0x61e, C68kScript.u16(bank_err))
	memory.write_u16(ctl + 0x61a, C68kScript.u16(pitch_err))
	memory.write_u16(ctl + 0x61c, C68kScript.u16(heading_err))
	a7 = entry_a7 - 0x3c
	enqueue_control_inputs_avg4(ctl, rudder, elevator, aileron)
	a7 = entry_a7

## 0x10b2e: build_relative_steer_sample into the frame (height a6 - 0x10, vector a6 - 0xc,
## pitch a6 - 0x12, heading a6 - 0x14; 0x44 below), then apply_relative_heading_steer (0x38
## below) - with D2 still holding the vector's address.
func steer_entity_toward_point(ctl: int, x: int, y: int, z: int) -> void:
	assert(a7 != 0, "steer_entity_toward_point needs a7 (its frame holds the sample)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var vec: int = a6 - 0xc
	a7 = entry_a7 - 0x44
	build_relative_steer_sample(ctl, x, y, z, a6 - 0x10, vec, a6 - 0x12, a6 - 0x14)
	a7 = entry_a7 - 0x38
	apply_relative_heading_steer(ctl, memory.read_s32(a6 - 0x10), vec, memory.read_s16(a6 - 0x12), memory.read_s16(a6 - 0x14), vec)
	a7 = entry_a7

## 0x6e74: resets the span runs of the device slots 1..3 (buffers at 0x1b778 + 4 (i - 1)) -
## every slot when slot == 0, else that one: for each view row (sext word view_rows) an 8-byte
## run (0, 1, view_width, fill_colour).
func reset_span_row_lists(slot: int) -> void:
	assert(memory != null, "reset_span_row_lists requires original global memory")
	for i in range(1, 4):
		var run: int = memory.read_u32(DAT_0001b778 + 4 * (i - 1))
		if run == 0 or (C68kScript.u32(slot) != 0 and C68kScript.s32(slot) != i):
			continue
		var row: int = 0
		while row < memory.read_s16(DAT_0001b828):
			memory.write_u16(run, 0)
			memory.write_u16(run + 2, 1)
			memory.write_u16(run + 4, memory.read_u16(DAT_0001b82a))
			memory.write_u16(run + 6, memory.read_u16(DAT_0001daa0))
			run += 8
			row += 1

## 0x6ed6: per-view setup: reset_span_row_lists(0) (8 below), palette_changed = 1, 0x1da8c =
## 0; the clip y max / view half height (0x1b73e / 0x20ae8) = view_rows / 2 toward zero and the
## last scan row (0x20ae6) = view_rows, both 0x14 less with an inset (view_inset 0x20ae2 = 4)
## when the view mode is neither 1 nor 8 and host word +0xa2 is set (else inset 0); 0x20ae4 /
## 0x20ae0 = 0; the projection scales (0x20b28 / 0x20b26) from the tables at 0x20b14 / 0x20afc
## - entry (word 0x20af4) in view mode 6 when it is non-zero, else entry 0; 0x1da8a = 0.
func update_view_clip_bounds() -> void:
	assert(memory != null, "update_view_clip_bounds requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	reset_span_row_lists(0)
	a7 = entry_a7
	memory.write_u16(0x1daa2, 1)
	memory.write_u16(0x1da8c, 0)
	var rows: int = memory.read_s16(DAT_0001b828)
	var half: int = C68kScript.s16((rows + 1 if rows < 0 else rows) >> 1)
	memory.write_u16(DAT_0001b73e, C68kScript.u16(half))
	memory.write_u16(0x20ae8, C68kScript.u16(half))
	memory.write_u16(0x20ae6, C68kScript.u16(rows))
	var view: int = memory.read_s16(DAT_0001d858)
	if view != 1 and view != 8 and memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xa2) != 0:
		var inset_half: int = C68kScript.u16(half - 0x14)
		memory.write_u16(DAT_0001b73e, inset_half)
		memory.write_u16(0x20ae8, inset_half)
		memory.write_u16(0x20ae6, C68kScript.u16(memory.read_u16(0x20ae6) - 0x14))
		memory.write_u16(0x20ae2, 4)
	else:
		memory.write_u16(0x20ae2, 0)
	memory.write_u16(0x20ae4, 0)
	memory.write_u16(0x20ae0, 0)
	var index: int = 0
	if view == 6 and memory.read_u16(0x20af4) != 0:
		index = memory.read_s16(0x20af4)
	memory.write_u16(0x20b28, memory.read_u16(0x20b14 + index * 2))
	memory.write_u16(0x20b26, memory.read_u16(0x20afc + index * 2))
	memory.write_u16(0x1da8a, 0)

## 0x14af2: drops an object's fractal reference (+0x2c). A static scenery piece (byte +5 bit 3
## without bit 4) first goes back to its template position (descriptor +2 / +6 / +0xa) through
## apply_template_chain_xform(obj, 1, 0, 0) (0x34 below). A user (byte +6 bit 1 clear) counts the
## shared block's users down (word +0), setting deferred_free_flag at 0. An owner walks its block
## list (word count +0, longs from +4): a block still in use releases every object_pool object
## pointing at it (recursively), still-used blocks print a warning through the host
## (overlay_printf, unported; 0x28 below like the recursion), and each block and then the list
## are freed. +0x2c = 0.
func release_fractal_reference(obj: int) -> void:
	assert(memory != null, "release_fractal_reference requires original global memory")
	var entry_a7: int = a7
	if (memory.read_u8(obj + 5) & 8) != 0 and (memory.read_u8(obj + 5) & 0x10) == 0:
		var desc: int = C68kScript.u32(memory.read_u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18) + memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c))
		for k in range(3):
			memory.write_u32(obj + 0x18 + 4 * k, memory.read_u32(desc + 2 + 4 * k))
		a7 = entry_a7 - 0x34
		apply_template_chain_xform(obj, 1, 0, 0)
		a7 = entry_a7
	if (memory.read_u8(obj + 6) & 2) == 0:
		var block: int = memory.read_u32(obj + 0x2c)
		memory.write_u16(block, C68kScript.u16(memory.read_u16(block) - 1))
		if memory.read_u16(block) == 0:
			memory.write_u16(DAT_0001c1bc, 1)
	else:
		var list: int = memory.read_u32(obj + 0x2c)
		if list != 0:
			var left: int = memory.read_u16(list)
			var cursor: int = list + 4
			while true:
				left = C68kScript.u16(left - 1)
				if left == 0xffff:
					break
				var block2: int = memory.read_u32(cursor)
				cursor += 4
				if memory.read_u16(block2) != 0:
					var n: int = memory.read_u16(DAT_0001b734 + 2)
					var slot: int = DAT_0001b5a4
					while true:
						n = C68kScript.u16(n - 1)
						if n == 0xffff:
							break
						var other: int = memory.read_u32(slot)
						slot += 4
						if memory.read_u32(other + 0x2c) == block2:
							a7 = entry_a7 - 0x28
							release_fractal_reference(other)
							a7 = entry_a7
				if memory.read_u16(block2) != 0:
					a7 = entry_a7 - 0x28
					_bsr_unported(0x1254, [0x14a9a])
					a7 = entry_a7
				heap_free_coalesce(block2)
			heap_free_coalesce(memory.read_u32(obj + 0x2c))
	memory.write_u32(obj + 0x2c, 0)

## 0x137da: drops every contact record (contact_table 0x1bdbc, 256 slots) that names obj as
## object a or b; when b is a fractal owner (byte +6 bit 1) and a holds a fractal reference
## (byte +6 bit 5 and +0x2c), a releases it first (0x18 below); the record is freed and its
## slot cleared.
func drop_contact_records_for_object(obj: int) -> void:
	assert(memory != null, "drop_contact_records_for_object requires original global memory")
	var entry_a7: int = a7
	for i in range(0x100):
		var slot: int = DAT_0001bdbc + 4 * i
		var rec: int = memory.read_u32(slot)
		if rec == 0:
			continue
		if memory.read_u32(rec) != C68kScript.u32(obj) and memory.read_u32(rec + 4) != C68kScript.u32(obj):
			continue
		var obj_a: int = memory.read_u32(rec)
		if (memory.read_u8(memory.read_u32(rec + 4) + 6) & 2) != 0 and (memory.read_u8(obj_a + 6) & 0x20) != 0 and memory.read_u32(obj_a + 0x2c) != 0:
			a7 = entry_a7 - 0x18
			release_fractal_reference(obj_a)
			a7 = entry_a7
		heap_free_coalesce(rec)
		memory.write_u32(slot, 0)

## 0x19430: spawn_mission_pool_object(parachute_template, x, y, z, sext pitch / heading / bank,
## 0) (0x40 below); null -> 0. The controller: +0x610 = frame_counter, word +0x614 = the low word
## of the first argument, words +0x20 / +0x22 / +0x24 = the angles; the 13 vertices are scaled
## by 1/8 (asr) and give start velocities +0x622 / +0x656 / +0x68a + 4 v = x * 0x1c6, y * 0x1c6,
## z * 0x255 (muls.l); +0x618 = 7, word +0x61c = 0x62. Returns the controller.
func spawn_bailout_parachute(word_614: int, x: int, y: int, z: int, pitch: int, heading: int, bank: int) -> int:
	assert(memory != null, "spawn_bailout_parachute requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x40
	var obj: int = spawn_mission_pool_object(memory.read_u32(DAT_00026780), x, y, z, C68kScript.s16(pitch), C68kScript.s16(heading), C68kScript.s16(bank), 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var ctl: int = memory.read_u32(obj + 8)
	memory.write_u32(ctl + 0x610, memory.read_u32(DAT_0001b838))
	memory.write_u16(ctl + 0x614, C68kScript.u16(word_614))
	memory.write_u16(ctl + 0x20, C68kScript.u16(pitch))
	memory.write_u16(ctl + 0x22, C68kScript.u16(heading))
	memory.write_u16(ctl + 0x24, C68kScript.u16(bank))
	var verts: int = memory.read_u32(obj + 0x44)
	for v in range(13):
		var p: int = verts + v * 0xc
		for k in range(3):
			memory.write_u32(p + 4 * k, C68kScript.u32(C68kScript.asr32(memory.read_u32(p + 4 * k), 3)))
		memory.write_u32(ctl + 0x622 + v * 4, C68kScript.u32(memory.read_s32(p) * 0x1c6))
		memory.write_u32(ctl + 0x656 + v * 4, C68kScript.u32(memory.read_s32(p + 4) * 0x1c6))
		memory.write_u32(ctl + 0x68a + v * 4, C68kScript.u32(memory.read_s32(p + 8) * 0x255))
	memory.write_u32(ctl + 0x618, 7)
	memory.write_u16(ctl + 0x61c, 0x62)
	return ctl

## 0xe792: aircraft flight model (update_aircraft_entity), the +0x32 handler of the player
## (runtime 0xe772) and the core of every AI state. Translated block by block from the bytes /
## section-checked semantic C (blocks 0 .. 7c as named there).
## Frame: link.w a6,#-0x4c and ten saved registers (body 0x78 below the entry). Locals kept in
## frame memory where the bytes read them uninitialised or pass their address: -0x42 local_46
## (power target), -0x3e local_42 (windmill term), -0x30 local_34 (thrust), -0x22 local_26,
## -0x24 / -0x26 pitch / att_22 words, -0x1e matrix, -0xc velocity record.
func update_aircraft_entity(ctl: int) -> void:
	assert(memory != null, "update_aircraft_entity requires original global memory")
	assert(a7 != 0, "update_aircraft_entity needs a7 (its frame holds the locals)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body_a7: int = a6 - 0x4c - 40
	var obj: int = memory.read_u32(ctl)
	var rough: bool = false
	memory.write_u32(DAT_00026004, memory.read_u32(ctl + 4))
	var rec: int = memory.read_u32(DAT_00026004)
	memory.write_u16(a6 - 0x24, memory.read_u16(ctl + 0x20))
	memory.write_u16(a6 - 0x26, memory.read_u16(ctl + 0x22))
	var heading: int = memory.read_u16(ctl + 0x24)
	var speed: int = memory.read_s32(ctl + 0x62a)
	var airspeed: int = speed >> 2
	var adj: int = memory.read_s16(rec + 0x40)
	if memory.read_u8(ctl + 0x679) != 0x2d:
		if adj < 0:
			adj += 1
		adj = adj >> 1
	var floor_y: int = C68kScript.s32(memory.read_u32(ctl + 0x2e) + adj)
	var rpm_start: int = memory.read_s32(ctl + 0x66a)
	var weight: int = C68kScript.s16(memory.read_s8(ctl + 0x67d) + memory.read_u16(ctl + 0x634) + memory.read_s8(ctl + 0x67e))
	## Block 0: wrecked on the ground (damage word bit 0x800).
	if (memory.read_u8(ctl + 0x684) & 8) != 0:
		if memory.read_s32(ctl + 0x2e) < C68kScript.s32(memory.read_u32(obj + 0x1c) - 0x16):
			memory.write_u32(ctl + 0xc, C68kScript.u32(-0x16))
		else:
			if memory.read_u8(ctl + 0x2c) == 0x10:
				memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x1000)
				if ctl == memory.read_u32(DAT_0001b738):
					memory.write_u16(0x1b850, 1)
			memory.write_u32(ctl + 0xc, C68kScript.u32(floor_y - memory.read_u32(obj + 0x1c)))
		memory.write_u16(ctl + 0x61e, C68kScript.u16(memory.read_u16(ctl + 0x61e) + (overlay_rng_next() & 0x7f)))
		memory.write_u16(ctl + 0x24, (memory.read_u16(ctl + 0x61e) + memory.read_u16(ctl + 0x24)) & 0x3fff)
		memory.write_u16(ctl + 0x61a, C68kScript.u16(memory.read_u16(ctl + 0x61a) - (overlay_rng_next() & 0x7f)))
		memory.write_u16(ctl + 0x20, (memory.read_u16(ctl + 0x61a) + memory.read_u16(ctl + 0x20)) & 0x3fff)
		memory.write_u8(ctl + 0x669, 0)
		return
	## Block 1: damaged elevator (0x4) / ailerons (0x8) jitter; 0x100 rolls the aircraft off.
	for c in [[4, 0x662, 0x200], [8, 0x666, 0x140]]:
		if (memory.read_u8(ctl + 0x685) & c[0]) != 0:
			var v: int = C68kScript.s16(memory.read_u16(ctl + c[1]) + (overlay_rng_next() & 0x7f) - 0x40)
			memory.write_u16(ctl + c[1], C68kScript.u16(v))
			if abs_int(v) > c[2]:
				memory.write_u16(ctl + c[1], C68kScript.u16(-c[2] if memory.read_s16(ctl + c[1]) < 0 else c[2]))
	if (memory.read_u8(ctl + 0x684) & 1) != 0:
		memory.write_u16(ctl + 0x662, 0)
		memory.write_u16(ctl + 0x666, 0xff80)
	## Block 1b: engine gate and the fuel-burn accumulator (+0x680).
	var throttle: int = memory.read_s8(ctl + 0x668)
	memory.write_u8(ctl + 0x669, 1)
	var smoke_gate: bool = (memory.read_u8(ctl + 0x685) & 0x40) != 0 and memory.read_u16(ctl + 0x68c) == 0
	if smoke_gate or (memory.read_u16(ctl + 0x684) & 0x300) != 0 or (memory.read_u8(ctl + 0x67d) == 0 and memory.read_u8(ctl + 0x67e) == 0):
		memory.write_u8(ctl + 0x669, 0)
		throttle = 0
	elif memory.read_s8(ctl + 0x685) < 0:
		if throttle < 0:
			throttle += 1
		throttle = throttle >> 1
	memory.write_u16(ctl + 0x680, C68kScript.u16(throttle + memory.read_u16(ctl + 0x680)))
	if memory.read_s16(ctl + 0x680) > memory.read_s16(rec + 0x1e):
		memory.write_u16(ctl + 0x680, C68kScript.u16(memory.read_u16(ctl + 0x680) - memory.read_u16(rec + 0x1e)))
		if (overlay_rng_next() & 1) != 0 and memory.read_u8(ctl + 0x67d) != 0:
			memory.write_u8(ctl + 0x67d, memory.read_u8(ctl + 0x67d) - 1)
		elif memory.read_u8(ctl + 0x67e) != 0:
			memory.write_u8(ctl + 0x67e, memory.read_u8(ctl + 0x67e) - 1)
	## Block 2a: air density, ground effect, rated power and the thrust term.
	var density: int = C68kScript.s16(table_lerp_1b2c0(memory.read_u32(obj + 0x1c)))
	var damped: int = C68kScript.s16(damp_short_if_below_0x200(C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(ctl + 0x2e)), density))
	scale_template_field_38(density, a6 - 0x22)
	var field38: int = memory.read_s32(a6 - 0x22)
	var thrust: int = 0
	if throttle != 0:
		if memory.read_s16(rec + 0x3e) < airspeed:
			thrust = C68kScript.divs_trunc(C68kScript.divs_trunc(C68kScript.s32(field38 * throttle), 9), airspeed)
		else:
			thrust = C68kScript.divs_trunc(throttle * memory.read_s16(rec + 0x3c), 9)
	memory.write_u32(a6 - 0x30, C68kScript.u32(thrust))
	## Block 2b: engine model (player / designated aircraft only).
	if ctl == memory.read_u32(DAT_0001b738) or ctl == memory.read_u32(DAT_0001b888):
		memory.write_u32(a6 - 0x3e, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(airspeed, 17)), 0x1c20)))
		var q: int = C68kScript.divs_trunc(0x5e50, C68kScript.s16(C68kScript.asr32(density + 0xa25, 5)))
		memory.write_u32(a6 - 0x42, C68kScript.u32(C68kScript.asr32(C68kScript.s32(q * C68kScript.s32(throttle * 0x666)), 5)))
		var power_target: int = memory.read_s32(a6 - 0x42)
		memory.write_u32(ctl + 0x66e, C68kScript.u32(memory.read_s32(ctl + 0x66e) + _ease8(C68kScript.s32(power_target - memory.read_s32(ctl + 0x66e)))))
		var manifold: int = 0
		if memory.read_u8(ctl + 0x669) != 0 and (memory.read_u16(ctl + 0x684) & 0x4300) == 0:
			manifold = C68kScript.s16(C68kScript.asr32(field38, 9))
		if memory.read_s8(ctl + 0x685) < 0:
			if manifold < 0:
				manifold += 1
			manifold = manifold >> 1
		memory.write_u16(ctl + 0x672, C68kScript.u16(memory.read_u16(ctl + 0x672) + _ease8(manifold - memory.read_s16(ctl + 0x672))))
		var half: int = C68kScript.s32(memory.read_s32(a6 - 0x3e) - power_target)
		if half < 0:
			half += 1
		var rpm_target: int = C68kScript.s32(power_target + (half >> 1))
		memory.write_u32(ctl + 0x66a, C68kScript.u32(memory.read_s32(ctl + 0x66a) + _ease8(C68kScript.s32(rpm_target - rpm_start))))
		if (memory.read_u8(ctl + 0x684) & 0x40) != 0 and memory.read_u32(ctl + 0x66e) == 0:
			memory.write_u8(ctl + 0x669, 0)
	## Block 3a: angle-of-attack step (+0x626) toward the stick.
	var stick: int
	var gain: int
	var roll_cmd: int
	var yaw_cmd: int
	if airspeed < 0xca8:
		if memory.read_s16(rec + 0x36) < airspeed:
			var g: int = C68kScript.s32(memory.read_s16(ctl + 0x662) * (memory.read_s16(rec + 0x34) - 0x200))
			if g < 0:
				g += 0x1ff
			stick = C68kScript.s16(memory.read_s16(ctl + 0x662) + C68kScript.divs_trunc(C68kScript.s32((g >> 9) * (0xca8 - airspeed)), 0xca8 - memory.read_s16(rec + 0x36)))
		else:
			var g2: int = C68kScript.s32(memory.read_s16(ctl + 0x662) * memory.read_s16(rec + 0x34))
			if g2 < 0:
				g2 += 0x1ff
			stick = C68kScript.s16(g2 >> 9)
		gain = _scale_by_speed(airspeed, 0x2a)
		roll_cmd = C68kScript.s16(_scale_by_speed(airspeed, memory.read_s16(ctl + 0x664)))
		yaw_cmd = C68kScript.s16(_scale_by_speed(airspeed, memory.read_s16(ctl + 0x666)))
	else:
		stick = memory.read_s16(ctl + 0x662)
		gain = 0x2a
		roll_cmd = memory.read_s16(ctl + 0x664)
		yaw_cmd = memory.read_s16(ctl + 0x666)
	var step: int = C68kScript.s32(gain * (stick - (memory.read_s16(ctl + 0x626) - memory.read_s16(rec + 0x44))))
	if step < 0:
		step += 0xff
	memory.write_u16(ctl + 0x626, C68kScript.u16(memory.read_u16(ctl + 0x626) + (step >> 8)))
	## Block 3b: on the ground with the gear down ('-' = 0x2d): AoA held to the three-point
	## attitude, blended back up between ground speeds +0x46 and +0x48; the roll command becomes
	## steering from the engine terms (local_46 / local_42 - stale for non-engine aircraft).
	var on_ground_gear: bool = memory.read_u8(ctl + 0x63e) != 0 and memory.read_u8(ctl + 0x679) == 0x2d
	if on_ground_gear:
		if memory.read_s16(ctl + 0x626) > memory.read_s16(rec + 0x42):
			memory.write_u16(ctl + 0x626, memory.read_u16(rec + 0x42))
		if airspeed < memory.read_s16(rec + 0x48):
			var t46: int = memory.read_s16(rec + 0x46)
			if t46 < airspeed:
				memory.write_u16(ctl + 0x626, C68kScript.u16(memory.read_s16(rec + 0x42) + C68kScript.divs_trunc(C68kScript.s32((memory.read_s16(ctl + 0x626) - memory.read_s16(rec + 0x42)) * (airspeed - t46)), memory.read_s16(rec + 0x48) - t46)))
			else:
				memory.write_u16(ctl + 0x626, memory.read_u16(rec + 0x42))
		var mix: int = C68kScript.s32(memory.read_s32(a6 - 0x42) + C68kScript.s32(memory.read_s32(a6 - 0x3e) * 2))
		if mix < 0:
			mix += 1
		mix = mix >> 1
		if mix < 0x10000:
			var m2: int = C68kScript.s32(mix * memory.read_s16(ctl + 0x666))
			if m2 < 0:
				m2 += 0xffff
			roll_cmd = C68kScript.s16(m2 >> 16)
		else:
			roll_cmd = memory.read_s16(ctl + 0x666)
		roll_cmd = roll_cmd >> 2
		if ctl == memory.read_u32(DAT_0001b738):
			memory.write_u16(0x1b858, 0)
	heading = (yaw_cmd + heading) & 0x3fff
	roll_cmd = roll_cmd & 0x3fff
	if on_ground_gear:
		memory.write_u16(a6 - 0x26, (roll_cmd + memory.read_u16(a6 - 0x26)) & 0x3fff)
	## Block 4a: lift coefficient (+0x63a), eased over the post-stall frames (byte +0x678).
	var lift: int = C68kScript.s16(compute_template_force_from_626(memory.read_s16(ctl + 0x626), memory.read_s8(ctl + 0x67b), ctl + 0x678))
	if memory.read_u8(ctl + 0x678) != 0:
		var d: int = lift - memory.read_s16(ctl + 0x63a)
		if d < 0:
			d += 7
		lift = (d >> 3) + memory.read_s16(ctl + 0x63a)
		memory.write_u8(ctl + 0x678, memory.read_u8(ctl + 0x678) - 1)
	memory.write_u16(ctl + 0x63a, C68kScript.u16(lift))
	## Block 4b: linear drag (long -0x4c) and the quadratic (induced) drag term.
	var t22: int = memory.read_s16(rec + 0x22)
	var lin: int = C68kScript.s32(airspeed * C68kScript.divs_trunc(C68kScript.s32(t22 * C68kScript.asr32(C68kScript.s32(airspeed * lift), 8)), damped))
	if lin < 0:
		lin += 7
	lin = C68kScript.divs_trunc(C68kScript.divs_trunc(lin >> 3, 0xa0), weight)
	memory.write_u32(a6 - 0x4c, C68kScript.u32(lin))
	var quad_in: int = C68kScript.asr32(C68kScript.s32(memory.read_s16(rec + 0x24) * C68kScript.asr32(C68kScript.s32(lift * lift), 4)), 20)
	var quad: int = C68kScript.s32(airspeed * C68kScript.divs_trunc(C68kScript.s32(t22 * C68kScript.asr32(C68kScript.s32(airspeed * quad_in), 8)), damped))
	if quad < 0:
		quad += 7
	quad = C68kScript.divs_trunc(quad >> 3, 0xa0)
	## Block 4c: parasite drag with gear (|+0x679| / 11) and flaps (|+0x67b| / 15), carried
	## through the remainder +0x636; ground friction (12-bit carry +0x638); arrest braking.
	var t20: int = memory.read_s16(rec + 0x20)
	var gear_drag: int = 0
	if memory.read_u8(ctl + 0x679) != 0:
		gear_drag = C68kScript.divs_trunc(C68kScript.s32(abs_int(memory.read_s8(ctl + 0x679)) * t20), 0xb)
	memory.write_u32(a6 - 0x48, C68kScript.u32(gear_drag))
	var flap_drag: int = 0
	if memory.read_u8(ctl + 0x67b) != 0:
		flap_drag = C68kScript.divs_trunc(C68kScript.s32(abs_int(memory.read_s8(ctl + 0x67b)) * t20), 0xf)
	var parasite: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.divs_trunc(C68kScript.asr32(C68kScript.s32((t20 + gear_drag + flap_drag) * airspeed), 8), density) * airspeed * 2), 0xa0)
	var drag_sum: int = C68kScript.s32(quad + parasite + memory.read_s16(ctl + 0x636))
	memory.write_u16(ctl + 0x636, C68kScript.u16(C68kScript.rems_trunc(drag_sum, weight)))
	speed = C68kScript.s32(speed - C68kScript.divs_trunc(drag_sum, weight))
	if memory.read_u8(ctl + 0x63e) != 0:
		var base: int = 0
		var surface_type: int = memory.read_u8(ctl + 0x2c)
		if abs_int(memory.read_s8(ctl + 0x679)) == 0x2d:
			base = memory.read_s16(rec + 0x2e) if (airspeed < memory.read_s16(rec + 0x46) or surface_type == 0x40) else memory.read_s16(rec + 0x30)
			if memory.read_u8(ctl + 0x641) != 0 or surface_type == 0x50:
				base += memory.read_s16(rec + 0x32)
		elif (memory.read_u8(ctl + 0x684) & 0x10) != 0:
			base = memory.read_s16(rec + 0x32) * 3
			if base < 0:
				base += 1
			base = base >> 1
			if ctl == memory.read_u32(DAT_0001b738):
				memory.write_u16(0x1b850, 1)
		var v: int = C68kScript.s32(base * (0x5b - lin) + memory.read_s16(ctl + 0x638))
		memory.write_u16(ctl + 0x638, C68kScript.u16(C68kScript.rems_trunc(v, 0x1000)))
		speed = C68kScript.s32(speed - C68kScript.divs_trunc(v, 0x1000))
	if memory.read_u8(ctl + 0x640) == 1:
		speed = C68kScript.s32(speed - 0xb6)
	speed = C68kScript.s32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(memory.read_u32(a6 - 0x30), 2)), weight) + speed)
	if speed <= 0:
		speed = 0
		memory.write_u8(ctl + 0x640, 2)
		if memory.read_u32(ctl + 0x62a) != 0 and ctl == memory.read_u32(DAT_0001b738) and memory.read_u16(0x1b868) == 1:
			memory.write_u16(0x1b868, 2)
	## Block 5a: body-frame velocity (0, linear drag, speed) through the attitude matrix.
	var vec: int = a6 - 0xc
	var matrix: int = a6 - 0x1e
	memory.write_u16(vec + 2, 0)
	memory.write_u16(vec + 6, C68kScript.u16(lin))
	memory.write_u16(vec + 10, C68kScript.u16(speed))
	a7 = body_a7 - 0x18
	build_attitude_matrix(C68kScript.s16(roll_cmd), memory.read_s16(a6 - 0x24), memory.read_s16(a6 - 0x26), C68kScript.s16(heading), matrix)
	a7 = entry_a7
	transform_vecs12_by_matrix3(1, vec, vec, matrix)
	memory.write_u16(vec + 6, C68kScript.u16(memory.read_u16(vec + 6) + memory.read_u16(ctl + 0x630)))
	memory.write_u16(ctl + 0x630, 0xffa5)
	memory.write_u32(ctl + 8, C68kScript.u32(memory.read_s16(vec + 2) >> 6))
	memory.write_u32(ctl + 0xc, C68kScript.u32(memory.read_s16(vec + 6) >> 6))
	memory.write_u32(ctl + 0x10, C68kScript.u32(memory.read_s16(vec + 10) >> 6))
	## Block 5b: touchdown / leaving the ground. The impact speed is the vertical word taken
	## BEFORE the snap (the bytes load +0xe first).
	var player: int = memory.read_u32(DAT_0001b738)
	if memory.read_u8(ctl + 0x63e) == 0:
		var world_y: int = memory.read_s32(obj + 0x1c)
		if C68kScript.s32(memory.read_u32(ctl + 0xc) + world_y) < floor_y and floor_y <= world_y:
			var impact: int = memory.read_s16(ctl + 0xe) << 4
			memory.write_u8(ctl + 0x63e, 1)
			memory.write_u32(ctl + 0xc, C68kScript.u32(floor_y - world_y))
			if impact < -0x168:
				memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x400)
				if memory.read_u32(ctl + 0x2e) == 0:
					a7 = body_a7 - 8
					memory.write_u8(ctl + 0x2c, C68kScript.u8(surface_type_under_object(obj)))
					a7 = entry_a7
				return
			if impact < -0xd8:
				rough = true
			elif abs_int(fold_angle_pm_0x2000(heading)) > 0x200 or fold_angle_pm_0x2000(memory.read_s16(a6 - 0x24)) < -0x100:
				rough = true
			elif ctl == player:
				memory.write_u16(0x1b856, 1)
			memory.write_u16(ctl + 0x638, 0)
			if ctl == player:
				memory.write_u16(0x1b868, 1)
	elif floor_y <= C68kScript.s32(memory.read_u32(ctl + 0xc) + memory.read_u32(obj + 0x1c)):
		memory.write_u8(ctl + 0x63e, 0)
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xefff)
		if ctl == player:
			memory.write_u16(0x1b868, 0)
	## Block 6a: in flight the speed is |velocity| and the attitude follows the velocity.
	var final_speed: int
	if memory.read_u8(ctl + 0x63e) == 0:
		var sum: int = 0
		for off in [2, 6, 10]:
			sum = C68kScript.s32(sum + memory.read_s16(vec + off) * memory.read_s16(vec + off))
		final_speed = C68kScript.s16(isqrt_floor(sum))
		attitude_from_velocity(memory.read_s16(vec + 2), memory.read_s16(vec + 6), memory.read_s16(vec + 10), final_speed, sum, a6 - 0x24, a6 - 0x26)
		if memory.read_u8(ctl + 0x640) == 2:
			memory.write_u8(ctl + 0x640, 0)
	else:
		## Block 6b: on the ground - horizontal speed, the surface type (byte +0x2c) decides
		## the bank (d6), rough handling, sounds and the arrest latch.
		if memory.read_u32(ctl + 0x2e) == 0:
			a7 = body_a7 - 8
			memory.write_u8(ctl + 0x2c, C68kScript.u8(surface_type_under_object(obj)))
			a7 = entry_a7
		final_speed = C68kScript.s16(isqrt_floor(C68kScript.s32(memory.read_s16(vec + 2) * memory.read_s16(vec + 2) + memory.read_s16(vec + 10) * memory.read_s16(vec + 10))))
		memory.write_u32(ctl + 0xc, C68kScript.u32(floor_y - memory.read_u32(obj + 0x1c)))
		var kind: int = memory.read_u8(ctl + 0x2c)
		var quarter: int = final_speed >> 2
		var gear_down: bool = abs_int(memory.read_s8(ctl + 0x679)) == 0x2d
		if kind == 0x40:
			if not gear_down:
				rough = true
			var bump: int = overlay_rng_next() & 0x7f
			var wobble: int = C68kScript.s16((overlay_rng_next() & 0x7f) - 0x40)
			if quarter < 0x438:
				wobble = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(quarter * wobble), 0x438))
				bump = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(quarter * bump), 0x438))
			heading = wobble & 0x3fff
			memory.write_u16(ctl + 0x630, C68kScript.u16(bump + memory.read_u16(ctl + 0x630)))
			if ctl == player:
				if memory.read_u16(0x1b856) != 0:
					memory.write_u16(0x1b854, 1)
					memory.write_u16(0x1b856, 0)
				elif final_speed > 0x10e0:
					if (overlay_rng_next() & 0xf) == 0:
						memory.write_u16(0x1b854, 1)
				elif final_speed > 0x2d0:
					if (overlay_rng_next() & 0x1f) == 0:
						memory.write_u16(0x1b854, 1)
		elif kind == 0x20:
			if (memory.read_u8(ctl + 0x684) & 8) == 0:
				rough = true
		elif kind == 0x10:
			memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x1000)
			if memory.read_u8(ctl + 0x679) != 0 or fold_angle_pm_0x2000(memory.read_s16(ctl + 0x626)) < -0x80:
				memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x400)
				return
			var half_bank: int = fold_angle_pm_0x2000(heading)
			if half_bank < 0:
				half_bank += 1
			var b: int = C68kScript.s16((overlay_rng_next() & 0x3f) + (half_bank >> 1) - 0x20)
			if quarter < 0x438:
				b = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(quarter * b), 0x438))
			heading = b & 0x3fff
			if ctl == player:
				memory.write_u16(0x1b856, 0)
		elif kind == 0x30 or kind == 0x60 or kind == 0x70:
			if not gear_down:
				rough = true
			heading = 0
		elif kind == 0x50:
			if not gear_down:
				rough = true
			if ctl == player and memory.read_u16(0x1b856) != 0:
				memory.write_u16(0x1b856, 0)
			heading = 0
		if memory.read_s16(a6 - 0x24) > 0x2000:
			memory.write_u16(a6 - 0x24, 0)
		if not rough and memory.read_u8(ctl + 0x63f) != 0 and memory.read_u8(ctl + 0x640) == 0:
			memory.write_u8(ctl + 0x640, 1)
	## Block 6c: commit attitude, bank (with the turn coordination from the heading change)
	## and speed; the player's 120-frame climb-rate sum.
	memory.write_u8(ctl + 0x63f, 0)
	var turn: int = fold_angle_pm_0x2000(memory.read_s16(a6 - 0x26) - memory.read_s16(ctl + 0x22))
	memory.write_u16(ctl + 0x20, memory.read_u16(a6 - 0x24))
	memory.write_u16(ctl + 0x22, memory.read_u16(a6 - 0x26))
	memory.write_u16(ctl + 0x24, C68kScript.u16(heading + C68kScript.asr32(C68kScript.s32(C68kScript.s16(turn) * sin_fixed14(memory.read_s16(a6 - 0x24))), 12)) & 0x3fff)
	memory.write_u32(ctl + 0x62a, C68kScript.u32(final_speed))
	if ctl == player:
		var climb: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.asr32(C68kScript.lsl32(sin_fixed14(memory.read_s16(ctl + 0x20)), 13), 12) * final_speed), 0x1ce)
		climb = clampi(climb, -0x1d80, 0x1d80)
		var index: int = memory.read_s16(0x1bc84)
		memory.write_u16(0x1bc8c + index * 2, C68kScript.u16(climb))
		memory.write_u32(0x1bc80, C68kScript.u32(memory.read_s32(0x1bc80) + C68kScript.s16(climb)))
		index += 1
		if index == 0x78:
			index = 0
		memory.write_u32(0x1bc80, C68kScript.u32(memory.read_s32(0x1bc80) - memory.read_s16(0x1bc8c + index * 2)))
		memory.write_u16(0x1bc84, C68kScript.u16(index))
	## Block 7a: flaps (+0x67b) and gear (+0x679) ramps.
	var flaps: int = memory.read_s8(ctl + 0x67b)
	if (flaps > 0 and flaps < 0xf) or flaps < 0:
		memory.write_u8(ctl + 0x67b, C68kScript.u8(flaps + 1))
	var gear: int = memory.read_s8(ctl + 0x679)
	if gear >= 1 and gear <= 0x2c and (memory.read_u8(ctl + 0x685) & 0x20) == 0:
		memory.write_u8(ctl + 0x679, C68kScript.u8(gear + 1))
		memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) | 2)
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xdfff)
	elif gear < 0:
		memory.write_u8(ctl + 0x679, C68kScript.u8(gear + 1))
		memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) | 2)
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x2000)
	## Block 7b: bombs (phase +0x674, count +0x67c), guns (phase +0x676, ammo +0x682), bail-out.
	if memory.read_u8(ctl + 0x674) != 0 and memory.read_u8(ctl + 0x67c) != 0:
		if memory.read_u8(ctl + 0x674) == 1:
			a7 = body_a7 - 0x24
			var bomb: int = spawn_weapon_entity(final_speed, 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24))
			a7 = entry_a7
			if bomb != 0 and ctl == player:
				memory.write_u32(DAT_0001b880, bomb)
				memory.write_u16(bomb + 0x614, 1)
				memory.write_u16(0x1b846, 1)
			memory.write_u8(ctl + 0x67c, memory.read_u8(ctl + 0x67c) - 1)
			if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) != 2:
				memory.write_u16(ctl + 0x634, C68kScript.u16(memory.read_u16(ctl + 0x634) - 0x10))
		var phase: int = memory.read_u8(ctl + 0x674)
		memory.write_u8(ctl + 0x674, (phase + 1) & 0xff)
		if phase == 4:
			memory.write_u8(ctl + 0x674, 0)
	if memory.read_u8(ctl + 0x676) != 0:
		if memory.read_u8(ctl + 0x676) == 1 and memory.read_s16(ctl + 0x682) > 1 and (memory.read_u8(ctl + 0x685) & 0x10) == 0:
			memory.write_u16(a6 - 0x24, (memory.read_u16(ctl + 0x20) + 0x40) & 0x3fff)
			a7 = body_a7 - 0x28
			var round: int = spawn_ordnance_oriented(final_speed, 1, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24), (memory.read_s16(ctl + 0x626) - memory.read_s16(memory.read_u32(ctl + 4) + 0x44)) & 0x3fff)
			a7 = entry_a7
			if round != 0 and ctl == player:
				memory.write_u16(round + 0x36, 1)
			memory.write_u16(ctl + 0x682, C68kScript.u16(memory.read_u16(ctl + 0x682) - 2))
		var gun_phase: int = memory.read_u8(ctl + 0x676)
		memory.write_u8(ctl + 0x676, (gun_phase + 1) & 0xff)
		if gun_phase == 2:
			memory.write_u8(ctl + 0x676, 0)
	if memory.read_u8(ctl + 0x677) == 1 and (memory.read_u8(ctl + 0x685) & 1) == 0:
		a7 = body_a7 - 0x20
		var chute: int = spawn_bailout_parachute(memory.read_u32(ctl + 0x62a), memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24))
		a7 = entry_a7
		memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 1)
		memory.write_u8(ctl + 0x677, 2)
		if ctl == player:
			memory.write_u16(0x1b874, 1)
			memory.write_u16(0x1b872, 0)
			memory.write_u16(DAT_0001d858, 9)
			if (memory.read_u16(ctl + 0x684) & 0x3fe) == 0 and (memory.read_u8(ctl + 0x67d) != 0 or memory.read_u8(ctl + 0x67e) != 0):
				memory.write_u16(0x1b87a, 1)
			memory.write_u32(0x1b87c, chute)
			var player_obj: int = memory.read_u32(player)
			if (memory.read_u8(player_obj + 7) & 0x40) != 0:
				memory.write_u32(player_obj + 4, memory.read_u32(player_obj + 4) & 0xffffffbf)
				a7 = body_a7 - 8
				drop_contact_records_for_object(player_obj)
				a7 = entry_a7
			a7 = body_a7 - 4
			update_view_clip_bounds()
			a7 = entry_a7
	## Block 7c: fuel leak (damage word bit 0x2) and the crash after a rough landing.
	if (memory.read_u8(ctl + 0x685) & 2) != 0:
		if (overlay_rng_next() & 0x3f) == 0:
			if (overlay_rng_next() & 1) != 0 and memory.read_u8(ctl + 0x67d) != 0:
				memory.write_u8(ctl + 0x67d, memory.read_u8(ctl + 0x67d) - 1)
			elif memory.read_u8(ctl + 0x67e) != 0:
				memory.write_u8(ctl + 0x67e, memory.read_u8(ctl + 0x67e) - 1)
	if rough:
		if (memory.read_u8(ctl + 0x684) & 1) == 0:
			memory.write_u16(ctl + 0x688, 0)
		elif memory.read_s16(ctl + 0x688) > 0x16:
			memory.write_u16(ctl + 0x688, 0x16)
		memory.write_u16(ctl + 0x684, (memory.read_u16(ctl + 0x684) & 0x8000) | 0x900)
		memory.write_u32(ctl + 0x32, 0xe772)
		memory.write_u16(ctl + 0x61a, 0)
		memory.write_u16(ctl + 0x61e, 0)

## Ease toward a target: d / 8 (toward zero), or d itself when that is 0 (the engine model's
## snap below 8).
func _ease8(d: int) -> int:
	var t: int = d
	if t < 0:
		t += 7
	return d if (t >> 3) == 0 else (t >> 3)

## (speed * v / 4096) * 0x143a / 4096, both divisions toward zero (the control scaling of blk 3a).
func _scale_by_speed(airspeed: int, v: int) -> int:
	var t: int = C68kScript.s32(airspeed * v)
	if t < 0:
		t += 0xfff
	t = C68kScript.s32((t >> 12) * 0x143a)
	if t < 0:
		t += 0xfff
	return t >> 12

## 0x110f4: AI state 0x110d4 (attack). A target is dropped (target +3 count down, +0x692 = 0)
## without ammo (word +0x682 <= 1), when it is dead (+7 bit 1) or has no vertices (+0x44);
## otherwise +0x696 = approx_dist3_xyz(own, target) (0x20 below) and ai_pursue_target flies the
## frame (0x24 below). Without a pursuit the kind's fly step runs (0xc below).
func ai_attack_or_fly(ctl: int) -> void:
	assert(memory != null, "ai_attack_or_fly requires original global memory")
	var entry_a7: int = a7
	var target: int = memory.read_u32(ctl + 0x692)
	if target != 0:
		if memory.read_s16(ctl + 0x682) <= 1 or (memory.read_u8(target + 7) & 2) != 0 or memory.read_u32(target + 0x44) == 0:
			memory.write_u8(target + 3, C68kScript.u8(memory.read_u8(target + 3) - 1))
			memory.write_u32(ctl + 0x692, 0)
		else:
			var own: int = memory.read_u32(ctl)
			a7 = entry_a7 - 0x20
			memory.write_u32(ctl + 0x696, C68kScript.u32(approx_dist3_xyz(memory.read_s32(own + 0x18), memory.read_s32(own + 0x1c), memory.read_s32(own + 0x20), memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20))))
			a7 = entry_a7 - 0x24
			ai_pursue_target(ctl)
			a7 = entry_a7
			return
	_ai_fly_step(ctl, entry_a7, 0xc)

## Waypoint offset for ai_pursue_target's manoeuvres: own coordinate + ((factor * airspeed
## +0x62a) asr 6) * trig asr 12 (muls.l low longs).
func _pursue_offset(ctl: int, base: int, factor: int, trig: int) -> int:
	return C68kScript.u32(C68kScript.asr32(C68kScript.s32(C68kScript.asr32(C68kScript.s32(factor * memory.read_s32(ctl + 0x62a)), 6) * C68kScript.s16(trig)), 12) + base)

## 0x1820a: pursue the AI target (+0x692) at distance +0x696, then fly (update_aircraft_entity,
## 0x68 below). Link a6 -0x40 plus seven saved registers: the body sits 0x60 below the entry and
## the locals passed by address live in the frame (range a6 - 0x10, vector a6 - 0xc, errors
## a6 - 0x12 / - 0x14, relative vector a6 - 0x20, matrix a6 - 0x32, angles a6 - 0x34 / - 0x36).
## Beyond 20000 it steers straight at the target (0x74 below), opens up (0x78 below) and clears
## the manoeuvre byte +0x69a. Nearer it aims at the target's pose ring (75 entries of 0x14 at
## target controller +0x36, index word +0x612) lag words back (0x1b876 for type key 1, else
## 0x1b878), extrapolated (lag + 4) times the step to the next entry (build_relative_steer_sample,
## 0x84 below; errors / 4 toward zero). A heading error beyond 0x53f outside manoeuvre 4 compares
## headings: within 0x1000, or on an even rng, it manoeuvres (below); otherwise manoeuvre 4. The
## attack: apply_relative_heading_steer (0x78 below, with the extrapolated z still in D2);
## within 0x2fff the throttle tracks a speed from the target's airspeed (0x6c below), else full
## (0x68 below); the target, shifted to fit 15 bits and turned into the own frame (attitude matrix
## 0x74 below, transform 0x84, isqrt 0x68, attitude_from_velocity 0x84, folds 0x68 / 0x6c), sets
## the gun phase byte +0x676 = 1 when both errors are within 0x7f; +0x69a is cleared unless it is
## 4 and the rng & 0x1f is non-zero. A manoeuvre (full throttle, 0x68 below) picks a waypoint
## +0x69c / +0x6a0 / +0x6a4 while +0x69a is 0: rng & 3 == 1 at airspeed above 0x32a0 with pitch
## within 0x1ff -> 3 (loop), rng & 3 <= 1 -> 2 (break turn), else 1 (reverse); phase +0x69b and
## best distance +0x6a8 reset. A waypoint reached (under 2000 and either receding from +0x6a8 or
## under 400) advances the phase, and the steer goes to the waypoint (0x74 below).
func ai_pursue_target(ctl: int) -> void:
	assert(memory != null, "ai_pursue_target requires original global memory")
	assert(a7 != 0, "ai_pursue_target needs a7 (its frame holds the steering locals)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x60
	var target: int = memory.read_u32(ctl + 0x692)
	if memory.read_s32(ctl + 0x696) > 0x4e20:
		a7 = body - 0x14
		steer_entity_toward_point(ctl, memory.read_u32(target + 0x18), memory.read_u32(target + 0x1c), memory.read_u32(target + 0x20))
		a7 = body - 0x18
		max_ai_throttle_maybe_invert_679(ctl)
		memory.write_u8(ctl + 0x69a, 0)
		a7 = body - 8
		update_aircraft_entity(ctl)
		a7 = entry_a7
		return
	var own: int = memory.read_u32(ctl)
	var target_ctl: int = memory.read_u32(target + 8)
	var lag: int = memory.read_s16(DAT_0001b876) if memory.read_s16(memory.read_u32(ctl + 4)) == 1 else memory.read_s16(DAT_0001b878)
	var ring: int = C68kScript.s32(memory.read_s16(target_ctl + 0x612) - lag)
	if ring < 0:
		ring = C68kScript.s32(ring + 0x4b)
	var pose_a: int = C68kScript.u32(target_ctl + 0x36 + ring * 0x14)
	ring = C68kScript.s32(ring + 1)
	if ring == 0x4b:
		ring = 0
	var pose_b: int = C68kScript.u32(target_ctl + 0x36 + ring * 0x14)
	var steps: int = lag + 4
	var aim: Array = []
	for off in [0, 4, 8]:
		aim.append(C68kScript.u32(C68kScript.s32(C68kScript.s32(memory.read_u32(pose_b + off) - memory.read_u32(pose_a + off)) * steps) + memory.read_u32(pose_a + off)))
	a7 = body - 0x24
	build_relative_steer_sample(ctl, aim[0], aim[1], aim[2], a6 - 0x10, a6 - 0xc, a6 - 0x12, a6 - 0x14)
	for off in [0x12, 0x14]:
		var e: int = memory.read_s16(a6 - off)
		if e < 0:
			e += 3
		memory.write_u16(a6 - off, C68kScript.u16(e >> 2))
	var manoeuvre: bool = false
	if abs_int(memory.read_s16(a6 - 0x14)) > 0x53f and memory.read_s8(ctl + 0x69a) != 4:
		a7 = body - 8
		var fold: int = fold_angle_pm_0x2000(C68kScript.s32(memory.read_s16(target_ctl + 0x22) - memory.read_s16(ctl + 0x22)))
		a7 = entry_a7
		if abs_int(fold) <= 0x1000:
			manoeuvre = true
		else:
			a7 = body - 4
			var r: int = overlay_rng_next()
			a7 = entry_a7
			if (r & 1) == 0:
				manoeuvre = true
			else:
				memory.write_u8(ctl + 0x69a, 4)
	if manoeuvre:
		_pursue_manoeuvre(ctl, own, body)
	else:
		_pursue_attack(ctl, own, target, target_ctl, a6, body, aim[2])
	a7 = body - 8
	update_aircraft_entity(ctl)
	a7 = entry_a7

## ai_pursue_target's attack branch (0x18372..0x1856a).
func _pursue_attack(ctl: int, own: int, target: int, target_ctl: int, a6: int, body: int, d2: int) -> void:
	var entry_a7: int = a7
	a7 = body - 0x18
	apply_relative_heading_steer(ctl, memory.read_s32(a6 - 0x10), a6 - 0xc, memory.read_s16(a6 - 0x12), memory.read_s16(a6 - 0x14), d2)
	var dist: int = memory.read_s32(ctl + 0x696)
	if dist <= 0x2fff:
		var speed: int = C68kScript.asr32(memory.read_u32(target_ctl + 0x62a), 2)
		if dist <= 0x7ff:
			speed = 0
		if dist <= 0xfff:
			speed = C68kScript.s32(speed * dist)
			if speed < 0:
				speed = C68kScript.s32(speed + 0xfff)
			speed = C68kScript.asr32(speed, 12)
		else:
			var blend: int = C68kScript.s32((0x1c21 - speed) * C68kScript.s32(dist - 0x2000))
			if blend < 0:
				blend = C68kScript.s32(blend + 0x1fff)
			speed = C68kScript.s32(speed + C68kScript.asr32(blend, 13))
		a7 = body - 0xc
		adjust_ai_throttle_vs_speed(ctl, speed)
	else:
		a7 = body - 8
		max_ai_throttle_maybe_invert_679(ctl)
	var shift: int = 0
	var d1: int = dist
	while (C68kScript.u32(d1) & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		d1 = C68kScript.asr32(d1, 1)
	shift = C68kScript.s16(shift + 1)
	var offsets: Array = [[0x18, 0x1e], [0x1c, 0x1a], [0x20, 0x16]]
	for pair in offsets:
		memory.write_u16(a6 - pair[1], C68kScript.u16(C68kScript.asr32(C68kScript.s32(memory.read_u32(target + pair[0]) - memory.read_u32(own + pair[0])), shift)))
	a7 = body - 0x14
	build_attitude_matrix_3ang_alt(-memory.read_s16(ctl + 0x20) & 0x3fff, -memory.read_s16(ctl + 0x22) & 0x3fff, -memory.read_s16(ctl + 0x24) & 0x3fff, a6 - 0x32)
	a7 = body - 0x24
	transform_vecs12_by_matrix3(1, a6 - 0x20, a6 - 0x20, a6 - 0x32)
	var rx: int = memory.read_s16(a6 - 0x1e)
	var ry: int = memory.read_s16(a6 - 0x1a)
	var rz: int = memory.read_s16(a6 - 0x16)
	var sq: int = C68kScript.s32(C68kScript.s32(rx * rx + ry * ry) + rz * rz)
	a7 = body - 8
	var length: int = isqrt_floor(sq)
	a7 = body - 0x24
	attitude_from_velocity(rx, ry, rz, C68kScript.s16(length), sq, a6 - 0x34, a6 - 0x36)
	a7 = body - 8
	memory.write_u16(a6 - 0x12, C68kScript.u16(fold_angle_pm_0x2000(memory.read_s16(a6 - 0x34))))
	a7 = body - 0xc
	memory.write_u16(a6 - 0x14, C68kScript.u16(fold_angle_pm_0x2000(memory.read_s16(a6 - 0x36))))
	a7 = entry_a7
	var trim: int = C68kScript.s32(memory.read_s16(ctl + 0x626) - memory.read_s16(memory.read_u32(ctl + 4) + 0x44))
	if abs_int(C68kScript.s32(memory.read_s16(a6 - 0x12) - trim)) <= 0x7f and abs_int(memory.read_s16(a6 - 0x14)) <= 0x7f and memory.read_u8(ctl + 0x676) == 0:
		memory.write_u8(ctl + 0x676, 1)
	if memory.read_s8(ctl + 0x69a) == 4:
		a7 = body - 4
		var r: int = overlay_rng_next()
		a7 = entry_a7
		if (r & 0x1f) != 0:
			return
	memory.write_u8(ctl + 0x69a, 0)

## ai_pursue_target's manoeuvre loop (0x1856e..0x188a2): sin / cos run 0x68 / 0x6c below.
func _pursue_manoeuvre(ctl: int, own: int, body: int) -> void:
	var entry_a7: int = a7
	a7 = body - 8
	max_ai_throttle_maybe_invert_679(ctl)
	a7 = entry_a7
	var dist: int
	var fresh: bool = memory.read_s8(ctl + 0x69a) == 0
	while true:
		if fresh:
			memory.write_u32(ctl + 0x69c, memory.read_u32(own + 0x18))
			memory.write_u32(ctl + 0x6a0, memory.read_u32(own + 0x1c))
			memory.write_u32(ctl + 0x6a4, memory.read_u32(own + 0x20))
			a7 = body - 4
			var pick: int = overlay_rng_next() & 3
			a7 = entry_a7
			var loop_ok: bool = false
			if pick == 1 and memory.read_s32(ctl + 0x62a) > 0x32a0:
				a7 = body - 8
				var pitch: int = fold_angle_pm_0x2000(memory.read_s16(ctl + 0x20))
				a7 = body - 0xc
				loop_ok = abs_int(pitch) <= 0x1ff
				a7 = entry_a7
			if loop_ok:
				memory.write_u8(ctl + 0x69a, 3)
			elif pick <= 1:
				memory.write_u8(ctl + 0x69a, 2)
			else:
				memory.write_u8(ctl + 0x69a, 1)
			memory.write_u8(ctl + 0x69b, 0)
			memory.write_u32(ctl + 0x6a8, 0)
			dist = 1
		else:
			a7 = body - 0x1c
			dist = approx_dist3_xyz(memory.read_s32(own + 0x18), memory.read_s32(own + 0x1c), memory.read_s32(own + 0x20), memory.read_s32(ctl + 0x69c), memory.read_s32(ctl + 0x6a0), memory.read_s32(ctl + 0x6a4))
			a7 = entry_a7
		dist = C68kScript.s32(dist)
		if dist <= 0x7cf and (dist > memory.read_s32(ctl + 0x6a8) or dist <= 0x18f):
			_pursue_advance_phase(ctl, own, body)
			dist = 0x7fffffff
		if memory.read_s8(ctl + 0x69a) != 0:
			break
		fresh = true
	memory.write_u32(ctl + 0x6a8, C68kScript.u32(dist))
	a7 = body - 0x14
	steer_entity_toward_point(ctl, memory.read_u32(ctl + 0x69c), memory.read_u32(ctl + 0x6a0), memory.read_u32(ctl + 0x6a4))
	a7 = entry_a7

## Set the waypoint x / z from an angle (sin 0x68, cos 0x6c below).
func _pursue_waypoint(ctl: int, own: int, body: int, angle: int, factor: int) -> void:
	var entry_a7: int = a7
	a7 = body - 8
	memory.write_u32(ctl + 0x69c, _pursue_offset(ctl, memory.read_u32(own + 0x18), factor, sin_fixed14(angle)))
	a7 = body - 0xc
	memory.write_u32(ctl + 0x6a4, _pursue_offset(ctl, memory.read_u32(own + 0x20), factor, cos_fixed14(angle)))
	a7 = entry_a7

## A reached waypoint: the next phase of manoeuvre +0x69a (0x18634..0x18878).
func _pursue_advance_phase(ctl: int, own: int, body: int) -> void:
	var entry_a7: int = a7
	var state: int = memory.read_s8(ctl + 0x69a)
	var phase: int = memory.read_s8(ctl + 0x69b)
	if state == 1:
		if phase != 0:
			memory.write_u8(ctl + 0x69a, 0)
			return
		memory.write_u32(ctl + 0x6a0, memory.read_u32(own + 0x1c))
		_pursue_waypoint(ctl, own, body, -memory.read_s16(ctl + 0x22) & 0x3fff, 0x4b)
		memory.write_u8(ctl + 0x69b, 1)
	elif state == 2:
		var base: int
		if phase == 0:
			memory.write_u32(ctl + 0x6a0, memory.read_u32(own + 0x1c))
			a7 = body - 4
			base = 0xfe00 if (overlay_rng_next() & 1) != 0 else 0x200
			a7 = entry_a7
		else:
			a7 = body - 4
			if (overlay_rng_next() & 1) != 0:
				memory.write_u8(ctl + 0x69a, 0)
			a7 = entry_a7
			base = 0xfc00 if memory.read_s8(ctl + 0x69b) == 1 else 0x400
		memory.write_u8(ctl + 0x69b, 2 if base == 0xfe00 or base == 0xfc00 else 1)
		_pursue_waypoint(ctl, own, body, (base - memory.read_u16(ctl + 0x22)) & 0x3fff, 0x2d)
	elif state == 3:
		if phase == 0:
			_pursue_waypoint(ctl, own, body, -memory.read_s16(ctl + 0x22) & 0x3fff, 0x2d)
			memory.write_u32(ctl + 0x6a0, C68kScript.u32(memory.read_u32(own + 0x1c) + 0x1388))
			memory.write_u8(ctl + 0x69b, 1)
		elif phase == 1:
			a7 = body - 4
			var angle: int = (overlay_rng_next() & 0xff) << 6
			a7 = entry_a7
			_pursue_waypoint(ctl, own, body, angle, 0x78)
			memory.write_u32(ctl + 0x6a0, C68kScript.u32(memory.read_u32(own + 0x1c) + 0xbb8))
			memory.write_u8(ctl + 0x69b, 2)
		elif phase == 2:
			memory.write_u8(ctl + 0x69a, 0)

## 0x10b84: the take-off climb. Byte +0x67b (flaps) 0 -> 1; more than 200 above the ground a
## lowering gear (byte +0x679 > 0) is raised (negated); throttle 9; pitch error = fold(0x2c0 -
## pitch +0x20) (0x14 below), elevator = error + error asr 1 - previous (+0x61a, then = error),
## clamped to +-0x200 when abs_int > 0x200; enqueue_control_inputs_avg4(ctl, 0, elevator, 0)
## (0x20 below). Above 2000 the flaps are negated and 1 is returned, else 0.
func ai_bootstrap_climb_phase(ctl: int) -> int:
	assert(memory != null, "ai_bootstrap_climb_phase requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	if memory.read_u8(ctl + 0x67b) == 0:
		memory.write_u8(ctl + 0x67b, 1)
	if C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(ctl + 0x2e)) > 200 and memory.read_s8(ctl + 0x679) > 0:
		memory.write_u8(ctl + 0x679, C68kScript.u8(-memory.read_s8(ctl + 0x679)))
	memory.write_u8(ctl + 0x668, 9)
	a7 = entry_a7 - 0x14
	var err: int = C68kScript.s16(fold_angle_pm_0x2000(C68kScript.s32(0x2c0 - memory.read_s16(ctl + 0x20))))
	a7 = entry_a7
	var elevator: int = C68kScript.s16(C68kScript.s16((err >> 1) + err) - memory.read_s16(ctl + 0x61a))
	memory.write_u16(ctl + 0x61a, C68kScript.u16(err))
	if abs_int(elevator) > 0x200:
		elevator = -0x200 if elevator < 0 else 0x200
	a7 = entry_a7 - 0x20
	enqueue_control_inputs_avg4(ctl, 0, elevator, 0)
	a7 = entry_a7
	if C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(ctl + 0x2e)) > 0x7d0:
		memory.write_u8(ctl + 0x67b, C68kScript.u8(-memory.read_s8(ctl + 0x67b)))
		return 1
	return 0

## Aim at a route point: its y, but at least 0x1000 above the ground (+0x2e).
func _route_aim_y(ctl: int, point: int) -> int:
	if C68kScript.s32(memory.read_u32(point + 4) - memory.read_u32(ctl + 0x2e)) <= 0xfff:
		return C68kScript.u32(memory.read_u32(ctl + 0x2e) + 0x1000)
	return memory.read_u32(point + 4)

## 0x10ce8: route block +0x616 (word +0 phase, +2 speed, +4 route): phase 0 climbs
## (ai_bootstrap_climb_phase, 0x14 below; done -> phase 1); otherwise the route point
## (advance_route_waypoint(object, block + 4), 0x18 below), the throttle toward word +2 (0x20
## below) and the steer at the point (0x20 below). Then update_aircraft_entity (0x14 below).
func tick_ai_climb_then_waypoint(ctl: int) -> void:
	assert(memory != null, "tick_ai_climb_then_waypoint requires original global memory")
	var entry_a7: int = a7
	var route: int = memory.read_u32(ctl + 0x616)
	if memory.read_u16(route) == 0:
		a7 = entry_a7 - 0x14
		if ai_bootstrap_climb_phase(ctl) != 0:
			memory.write_u16(route, C68kScript.u16(memory.read_u16(route) + 1))
	else:
		a7 = entry_a7 - 0x18
		var point: int = advance_route_waypoint(memory.read_u32(ctl), route + 4)
		a7 = entry_a7 - 0x20
		adjust_ai_throttle_vs_speed(ctl, memory.read_s16(route + 2))
		var aim_y: int = _route_aim_y(ctl, point)
		a7 = entry_a7 - 0x20
		steer_entity_toward_point(ctl, memory.read_u32(point), aim_y, memory.read_u32(point + 8))
	a7 = entry_a7 - 0x14
	update_aircraft_entity(ctl)
	a7 = entry_a7

## The route patrols 0x10d68 / 0x10da8 / 0x10de8: on first use the 4 points are moved into the
## world by the aircraft's template pose (alloc_transformed_vertex_block(object, 8, 4, src), 0x18
## below) and word +2 = speed; then tick_ai_climb_then_waypoint (0xc below).
func _ensure_route_tick(ctl: int, src: int, speed: int) -> void:
	var entry_a7: int = a7
	if memory.read_u32(ctl + 0x616) == 0:
		a7 = entry_a7 - 0x18
		var block: int = alloc_transformed_vertex_block(memory.read_u32(ctl), 8, 4, src)
		memory.write_u32(ctl + 0x616, block)
		memory.write_u16(block + 2, speed)
	a7 = entry_a7 - 0xc
	tick_ai_climb_then_waypoint(ctl)
	a7 = entry_a7

## 0x10d68 (ai_fly_table kind 1, runtime 0x10d48): patrol route_1b2e0 at speed 0x9d8.
func ensure_ai_script_1b2e0_tick(ctl: int) -> void:
	assert(memory != null, "ensure_ai_script_1b2e0_tick requires original global memory")
	_ensure_route_tick(ctl, DAT_0001b2e0, 0x9d8)

## 0x10da8 (kind 5, runtime 0x10d88): patrol route_1b310 at speed 0xd5c.
func ensure_ai_script_1b310_tick(ctl: int) -> void:
	assert(memory != null, "ensure_ai_script_1b310_tick requires original global memory")
	_ensure_route_tick(ctl, DAT_0001b310, 0xd5c)

## 0x10de8 (kind 2, runtime 0x10dc8): patrol route_1b340 at speed 0x9d8.
func ensure_ai_script_1b340_tick(ctl: int) -> void:
	assert(memory != null, "ensure_ai_script_1b340_tick requires original global memory")
	_ensure_route_tick(ctl, DAT_0001b340, 0x9d8)

## 0x10e28: from frame +0x6ac on: no bombs (byte +0x67c) -> 1. Otherwise, with the bomb phase
## +0x674 idle and rng & 7 == 0 (0x10 below): phase 2, heading = (+0x22 - 0x80 + (rng & 0xff))
## & 0x3fff (0x14 below), pitch = (+0x20 + (rng & 0x7f)) & 0x3fff (0x18 below),
## spawn_weapon_entity(+0x62a, 0, own position, pitch, heading, +0x24) (0x30 below), one bomb
## less and word +0x634 - 6. Returns 0.
func ai_script_try_fire_burst(ctl: int) -> int:
	assert(memory != null, "ai_script_try_fire_burst requires original global memory")
	var entry_a7: int = a7
	if memory.read_s32(DAT_0001b838) < memory.read_s32(ctl + 0x6ac):
		return 0
	if memory.read_u8(ctl + 0x67c) == 0:
		return 1
	if memory.read_u8(ctl + 0x674) != 0:
		return 0
	a7 = entry_a7 - 0x10
	var gate: int = overlay_rng_next()
	a7 = entry_a7
	if (gate & 7) != 0:
		return 0
	var obj: int = memory.read_u32(ctl)
	memory.write_u8(ctl + 0x674, 2)
	var bank: int = memory.read_s16(ctl + 0x24)
	a7 = entry_a7 - 0x14
	var heading: int = C68kScript.s32(memory.read_s16(ctl + 0x22) - 0x80 + (overlay_rng_next() & 0xff)) & 0x3fff
	a7 = entry_a7 - 0x18
	var pitch: int = C68kScript.s32(memory.read_s16(ctl + 0x20) + (overlay_rng_next() & 0x7f)) & 0x3fff
	a7 = entry_a7 - 0x30
	spawn_weapon_entity(memory.read_u32(ctl + 0x62a), 0, memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), pitch, heading, bank)
	a7 = entry_a7
	memory.write_u8(ctl + 0x67c, C68kScript.u8(memory.read_u8(ctl + 0x67c) - 1))
	memory.write_u16(ctl + 0x634, C68kScript.u16(memory.read_u16(ctl + 0x634) - 6))
	return 0

## 0x10ecc (kind 4, runtime 0x10eac): the route_1b310 patrol (0x14 below), then the attack run
## by phase: 1 -> 2 within 50000 horizontally of the fixed point (-0x40af3, 0x2b246a) (0x28
## below) above 20000 while not burning (word +0x684 bit 0x100): +0x6ac = frame + 0x4b, host
## word +0xce = -1 if it was 0. Phase 2 -> 3 when ai_script_try_fire_burst returns non-zero.
func tick_ai_1b310_approach_fire(ctl: int) -> void:
	assert(memory != null, "tick_ai_1b310_approach_fire requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	a7 = entry_a7 - 0x14
	ensure_ai_script_1b310_tick(ctl)
	a7 = entry_a7
	var route: int = memory.read_u32(ctl + 0x616)
	var phase: int = memory.read_s16(route)
	if phase == 1:
		a7 = entry_a7 - 0x28
		var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), 0, memory.read_s32(obj + 0x20), -0x40af3, 0, 0x2b246a)
		a7 = entry_a7
		if dist <= 0xc34f and memory.read_s32(obj + 0x1c) > 0x4e20 and (memory.read_u8(ctl + 0x684) & 1) == 0:
			memory.write_u16(route, 2)
			memory.write_u32(ctl + 0x6ac, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x4b))
			var host: int = memory.read_u32(DAT_0001b5a0)
			if memory.read_u16(host + 0xce) == 0:
				memory.write_u16(host + 0xce, 0xffff)
	elif phase == 2:
		a7 = entry_a7 - 0x14
		var done: int = ai_script_try_fire_burst(ctl)
		a7 = entry_a7
		if done != 0:
			memory.write_u16(route, 3)

## 0x10f68 (kind 3, runtime 0x10f48): the scripted mission. On first use the 8 route_1b370
## points are copied (alloc_copied_vertex_block(object, 8, 8, src), 0x20 below) with the route
## index (word +4) at 3. Phase word +0 (jump table; other values steer at the player's object):
## 0 climbs (0x14 below; done -> 1) and flies; 1 at point 4 -> 2 (+0x6ac = frame + 0x4b); 2 ->
## 3 when ai_script_try_fire_burst (0x14 below) returns non-zero; 4 (in host mode 5 for type
## key 2 sets host word +0xce = 1 if it was 0) -> 5; 5 glides: enqueue(ctl, 0, 0, 0x140 below
## airspeed 0x5a0 else 0) (0x20 below), throttle 0, byte +0x641 = 1. Phases 1..3 then follow
## the route (advance_route_waypoint, 0x18 below): phase 3 back at point 0 becomes 4, lowers the
## gear (+0x679 = 1) and tries the landing approach (0x14 below); otherwise the throttle goes
## toward route_1b370_speeds[index] (0x18 below) and it steers at the point (0x20 below).
## Every phase ends in update_aircraft_entity (0x14 below).
func tick_ai_1b370_mission(ctl: int) -> void:
	assert(memory != null, "tick_ai_1b370_mission requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	if memory.read_u32(ctl + 0x616) == 0:
		a7 = entry_a7 - 0x20
		var block: int = alloc_copied_vertex_block(obj, 8, 8, DAT_0001b370)
		a7 = entry_a7
		memory.write_u32(ctl + 0x616, block)
		memory.write_u16(block + 4, 3)
	var route: int = memory.read_u32(ctl + 0x616)
	var phase: int = memory.read_s16(route)
	var follow: bool = false
	if phase == 0:
		a7 = entry_a7 - 0x14
		if ai_bootstrap_climb_phase(ctl) != 0:
			memory.write_u16(route, C68kScript.u16(memory.read_u16(route) + 1))
	elif phase == 1:
		if memory.read_s16(route + 4) == 4:
			memory.write_u16(route, 2)
			memory.write_u32(ctl + 0x6ac, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x4b))
		follow = true
	elif phase == 2:
		a7 = entry_a7 - 0x14
		if ai_script_try_fire_burst(ctl) != 0:
			memory.write_u16(route, 3)
		follow = true
	elif phase == 3:
		follow = true
	elif phase == 4 or phase == 5:
		if phase == 4:
			var host: int = memory.read_u32(DAT_0001b5a0)
			if memory.read_s16(host + 0x90) == 5 and memory.read_s16(memory.read_u32(ctl + 4)) == 2 and memory.read_u16(host + 0xce) == 0:
				memory.write_u16(host + 0xce, 1)
			memory.write_u16(route, 5)
		a7 = entry_a7 - 0x20
		enqueue_control_inputs_avg4(ctl, 0, 0, 0x140 if C68kScript.asr32(memory.read_u32(ctl + 0x62a), 2) <= 0x59f else 0)
		memory.write_u8(ctl + 0x668, 0)
		memory.write_u8(ctl + 0x641, 1)
	else:
		var player_obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
		a7 = entry_a7 - 0x20
		steer_entity_toward_point(ctl, memory.read_u32(player_obj + 0x18), memory.read_u32(player_obj + 0x1c), memory.read_u32(player_obj + 0x20))
	if follow:
		a7 = entry_a7 - 0x18
		var point: int = advance_route_waypoint(obj, route + 4)
		if memory.read_s16(route) == 3 and memory.read_u16(route + 4) == 0:
			memory.write_u16(route, 4)
			memory.write_u8(ctl + 0x679, 1)
			a7 = entry_a7 - 0x14
			try_begin_landing_approach(ctl)
		else:
			adjust_ai_throttle_vs_speed(ctl, memory.read_u32(DAT_0001b3d0 + memory.read_s16(route + 4) * 4))
			var aim_y: int = _route_aim_y(ctl, point)
			a7 = entry_a7 - 0x20
			steer_entity_toward_point(ctl, memory.read_u32(point), aim_y, memory.read_u32(point + 8))
	a7 = entry_a7 - 0x14
	update_aircraft_entity(ctl)
	a7 = entry_a7

## 0x168d2: a cleared heap block of header + 12 * count bytes (heap_alloc_cleared, 0x1c below),
## count word at header - 2, and the count points transformed into it by the object's template
## chain (apply_template_chain_xform_always, 0x2c below). Returns the block.
func alloc_transformed_vertex_block(obj: int, header: int, count: int, src: int) -> int:
	assert(memory != null, "alloc_transformed_vertex_block requires original global memory")
	var entry_a7: int = a7
	count = C68kScript.s16(count)
	a7 = entry_a7 - 0x1c
	var block: int = heap_alloc_cleared(C68kScript.s32(header + count * 12))
	memory.write_u16(block + header - 2, C68kScript.u16(count))
	a7 = entry_a7 - 0x2c
	apply_template_chain_xform_always(obj, count, src, C68kScript.u32(block + header))
	a7 = entry_a7
	return block

## 0x1691c: as alloc_transformed_vertex_block, but the points are copied unchanged
## (memmove_block, 0x28 below); the object is not used.
func alloc_copied_vertex_block(_obj: int, header: int, count: int, src: int) -> int:
	assert(memory != null, "alloc_copied_vertex_block requires original global memory")
	var entry_a7: int = a7
	count = C68kScript.s16(count)
	a7 = entry_a7 - 0x1c
	var block: int = heap_alloc_cleared(C68kScript.s32(header + count * 12))
	memory.write_u16(block + header - 2, C68kScript.u16(count))
	a7 = entry_a7 - 0x28
	memmove_block(src, C68kScript.u32(block + header), C68kScript.s32(count * 12))
	a7 = entry_a7
	return block

## 0x16966: route = word index, word count, 12-byte points. Within 4999 horizontally of the
## current point (0x34 below) the index moves on (to 0 at the count) and the new point is pushed
## away from the aircraft: d = 3D distance (0x34 below), s = asr steps until d & 0xffff8000 is
## 0; each axis += muls.w((point - own) asr s, 5000) divs.l ext((d asr s) asr s). Returns the
## current point.
func advance_route_waypoint(obj: int, route: int) -> int:
	assert(memory != null, "advance_route_waypoint requires original global memory")
	var entry_a7: int = a7
	var point: int = route + 4 + memory.read_s16(route) * 12
	a7 = entry_a7 - 0x34
	var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), 0, memory.read_s32(obj + 0x20), memory.read_s32(point), 0, memory.read_s32(point + 8))
	a7 = entry_a7
	if dist > 0x1387:
		return point
	memory.write_u16(route, C68kScript.u16(memory.read_u16(route) + 1))
	if memory.read_s16(route + 2) <= memory.read_s16(route):
		memory.write_u16(route, 0)
	point = route + 4 + memory.read_s16(route) * 12
	a7 = entry_a7 - 0x34
	var d: int = C68kScript.s32(approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), memory.read_s32(point), memory.read_s32(point + 4), memory.read_s32(point + 8)))
	a7 = entry_a7
	var shift: int = 0
	while (C68kScript.u32(d) & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		d = C68kScript.asr32(d, 1)
	var divisor: int = C68kScript.s16(C68kScript.asr32(d, shift))
	assert(divisor != 0, "advance_route_waypoint: divs.l by zero traps")
	for off in [0, 4, 8]:
		var delta: int = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(point + off) - memory.read_u32(obj + 0x18 + off)), shift)) * 5000
		memory.write_u32(point + off, C68kScript.u32(C68kScript.divs_trunc(delta, divisor) + memory.read_u32(point + off)))
	return point

## 0x19c26: out (register A1) = (x, y, z) asr shift (asr.l by the long count).
func store_xyz_asr(x: int, y: int, z: int, shift: int, out: int) -> int:
	assert(memory != null, "store_xyz_asr requires original global memory")
	memory.write_u32(out, C68kScript.u32(C68kScript.asr32(C68kScript.s32(x), shift)))
	memory.write_u32(out + 4, C68kScript.u32(C68kScript.asr32(C68kScript.s32(y), shift)))
	memory.write_u32(out + 8, C68kScript.u32(C68kScript.asr32(C68kScript.s32(z), shift)))
	return out

## Halved sum of two frame points (+1 before asr when negative), into dst.
func _runway_midpoint(a: int, b: int, dst: int) -> void:
	for off in [0, 4, 8]:
		var v: int = C68kScript.s32(memory.read_u32(a + off) + memory.read_u32(b + off))
		if v < 0:
			v += 1
		memory.write_u32(dst + off, C68kScript.u32(v >> 1))

## 0x19c5e: the nearest runway end. Link a6 -0x7c and ten registers: the body is 0xa8 below the
## entry; the four pad corners are kept in the frame (a6 - 0xc / - 0x18 / - 0x24 / - 0x30) and
## the midpoints at a6 - 0x48 / - 0x54. object_pool then entity_array_1 are walked from the end
## (word counts, subq / bcc). For a shape (type byte 2) near a friendly facility (probe 0x200,
## 0xb0 below) nearer than the best object so far (0xc4 below): each face with byte +0x16 'p'
## and word +0x14 == 4 has its corners (vertex index words, 12-byte vertices +0x44) shifted by
## word +0x34 (store_xyz_asr); the best object distance is taken; when the second side (P2P3,
## horizontal, 0xdc below) is shorter than the first (P1P2, 0xc4 below) the corners rotate by
## one; the midpoints of P1P2 and P3P4 are measured from the aircraft (0xc4 / 0xdc below) and
## the nearer one, if it beats the best end, goes to *near_end and the other to *far_end.
## Returns 1 when nothing was found within 0x40740, else 0.
func find_nearest_runway_approach_ends(own: int, near_end: int, far_end: int) -> int:
	assert(memory != null, "find_nearest_runway_approach_ends requires original global memory")
	assert(a7 != 0, "find_nearest_runway_approach_ends needs a7 (its frame holds the corners)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0xa8
	var best_end: int = 0x7fffffff
	var best_obj: int = 0x7fffffff
	var ox: int = memory.read_s32(own + 0x18)
	var oy: int = memory.read_s32(own + 0x1c)
	var oz: int = memory.read_s32(own + 0x20)
	var corners: Array = [a6 - 0xc, a6 - 0x18, a6 - 0x24, a6 - 0x30]
	var tmp: int = a6 - 0x3c
	var m12: int = a6 - 0x48
	var m34: int = a6 - 0x54
	for pass_index in 2:
		var list: int = DAT_0001b5a4 if pass_index == 0 else DAT_0001d4a4
		var count_addr: int = DAT_0001b734 if pass_index == 0 else DAT_0001c1e0
		var slot: int = C68kScript.u32(memory.read_u32(count_addr) * 4 + list)
		var count: int = memory.read_u16(count_addr + 2)
		while count != 0:
			count -= 1
			slot -= 4
			var cand: int = memory.read_u32(slot)
			if memory.read_u8(cand) != 2:
				continue
			a7 = body - 8
			var kind: int = probe_nearest_facility_kind(cand)
			a7 = entry_a7
			if kind != 0x200:
				continue
			var obj_dist: int = approx_dist3_xyz(ox, oy, oz, memory.read_s32(cand + 0x18), memory.read_s32(cand + 0x1c), memory.read_s32(cand + 0x20))
			if obj_dist >= best_obj:
				continue
			var face: int = memory.read_u32(cand + 0x48)
			var faces: int = memory.read_u16(cand + 0x3a)
			while faces != 0:
				faces -= 1
				if memory.read_u8(face + 0x16) == 0x70 and memory.read_s16(face + 0x14) == 4:
					var verts: int = memory.read_u32(cand + 0x44)
					var vidx: int = memory.read_u32(face + 0x18)
					best_obj = obj_dist
					var shift: int = memory.read_s16(cand + 0x34)
					for k in 4:
						var v: int = C68kScript.u32(verts + memory.read_s16(vidx + 2 * k) * 12)
						store_xyz_asr(memory.read_u32(v), memory.read_u32(v + 4), memory.read_u32(v + 8), shift, corners[k])
					var side12: int = approx_dist3_xyz(memory.read_s32(a6 - 0xc), 0, memory.read_s32(a6 - 0x4), memory.read_s32(a6 - 0x18), 0, memory.read_s32(a6 - 0x10))
					var side23: int = approx_dist3_xyz(memory.read_s32(a6 - 0x18), 0, memory.read_s32(a6 - 0x10), memory.read_s32(a6 - 0x24), 0, memory.read_s32(a6 - 0x1c))
					if side23 < side12:
						_copy_xyz(corners[0], tmp)
						_copy_xyz(corners[1], corners[0])
						_copy_xyz(corners[2], corners[1])
						_copy_xyz(corners[3], corners[2])
						_copy_xyz(tmp, corners[3])
					_runway_midpoint(a6 - 0xc, a6 - 0x18, m12)
					_runway_midpoint(a6 - 0x24, a6 - 0x30, m34)
					var near_dist: int = approx_dist3_xyz(ox, oy, oz, memory.read_s32(m12), memory.read_s32(m12 + 4), memory.read_s32(m12 + 8))
					var other: int = approx_dist3_xyz(ox, oy, oz, memory.read_s32(m34), memory.read_s32(m34 + 4), memory.read_s32(m34 + 8))
					if near_dist > other:
						near_dist = other
						_copy_xyz(m12, tmp)
						_copy_xyz(m34, m12)
						_copy_xyz(tmp, m34)
					if near_dist < best_end:
						best_end = near_dist
						_copy_xyz(m12, near_end)
						_copy_xyz(m34, far_end)
				face = C68kScript.u32(face + 0x20)
	a7 = entry_a7
	return 1 if best_end == 0x7fffffff or best_end > 0x40740 else 0

## Copy three longs (the runway search's point moves).
func _copy_xyz(src: int, dst: int) -> void:
	for off in [0, 4, 8]:
		memory.write_u32(dst + off, memory.read_u32(src + off))

## 0x19fba: start the landing glide. Link a6 -0x28 and five registers (body 0x40 below). The
## nearest runway ends (a6 - 0xc near, a6 - 0x18 far; 0x50 below) must exist and the near end be
## 10000..0x26ac0 from the aircraft (0x5c below), else 1. glide_aim = near + 6 * (far - near) / 64
## (x, z; toward zero), y = near y; glide_dir = (far - near) asr 3 as words, x / z normalised to
## 4096 by the isqrt length (0x48 below, divs.l), y = -0x240; aim += dir * 10000 / 4096 (x, z;
## toward zero), y + 0x43. Blend 0, flaps (+0x67b) negated if positive, word +0x684 bit 0x4000
## cleared, +0x622 / +0x620 / 0x267a4 / 0x267a8 = 0, start = own x / z, height floor 0x11b when
## aim y <= 0x43 else 0x181; the +0x32 handler is saved (0x26798) and becomes 0x1a186
## (tick_landing_approach_glide). Returns 0.
func try_begin_landing_approach(ctl: int) -> int:
	assert(memory != null, "try_begin_landing_approach requires original global memory")
	assert(a7 != 0, "try_begin_landing_approach needs a7 (its frame holds the runway ends)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var obj: int = memory.read_u32(ctl)
	var near: int = a6 - 0xc
	var far: int = a6 - 0x18
	a7 = entry_a7 - 0x50
	var missing: int = find_nearest_runway_approach_ends(obj, near, far)
	a7 = entry_a7
	if missing != 0:
		return 1
	var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), memory.read_s32(near), memory.read_s32(near + 4), memory.read_s32(near + 8))
	if dist <= 0x270f or dist > 0x26ac0:
		return 1
	var dx: int = C68kScript.s32(memory.read_u32(far) - memory.read_u32(near))
	var dy: int = C68kScript.s32(memory.read_u32(far + 4) - memory.read_u32(near + 4))
	var dz: int = C68kScript.s32(memory.read_u32(far + 8) - memory.read_u32(near + 8))
	for pair in [[dx, 0, 0], [dz, 8, 8]]:
		var v: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(C68kScript.lsl32(pair[0], 1) + pair[0]), 1))
		if v < 0:
			v = C68kScript.s32(v + 0x3f)
		memory.write_u32(DAT_000267bc + pair[2], C68kScript.u32(C68kScript.asr32(v, 6) + memory.read_u32(near + pair[1])))
	memory.write_u32(DAT_000267bc + 4, memory.read_u32(near + 4))
	memory.write_u16(DAT_000267b2, C68kScript.u16(C68kScript.asr32(dx, 3)))
	memory.write_u16(DAT_000267b2 + 4, C68kScript.u16(C68kScript.asr32(dy, 3)))
	memory.write_u16(DAT_000267b2 + 8, C68kScript.u16(C68kScript.asr32(dz, 3)))
	var gx: int = memory.read_s16(DAT_000267b2)
	var gy: int = memory.read_s16(DAT_000267b2 + 4)
	var gz: int = memory.read_s16(DAT_000267b2 + 8)
	a7 = entry_a7 - 0x48
	var length: int = C68kScript.s16(isqrt_floor(C68kScript.s32(C68kScript.s32(gx * gx + gy * gy) + gz * gz)))
	a7 = entry_a7
	assert(length != 0, "try_begin_landing_approach: divs.l by zero traps")
	memory.write_u16(DAT_000267b2, C68kScript.u16(C68kScript.divs_trunc(C68kScript.lsl32(gx, 12), length)))
	memory.write_u16(DAT_000267b2 + 4, 0xfdc0)
	memory.write_u16(DAT_000267b2 + 8, C68kScript.u16(C68kScript.divs_trunc(C68kScript.lsl32(gz, 12), length)))
	for off in [0, 8]:
		var v: int = memory.read_s16(DAT_000267b2 + off) * 10000
		if v < 0:
			v += 0xfff
		memory.write_u32(DAT_000267bc + off, C68kScript.u32((v >> 12) + memory.read_u32(DAT_000267bc + off)))
		if off == 0:
			memory.write_u32(DAT_000267bc + 4, C68kScript.u32(memory.read_u32(DAT_000267bc + 4) + 0x43))
	memory.write_u16(DAT_000267ac, 0)
	if memory.read_s8(ctl + 0x67b) > 0:
		memory.write_u8(ctl + 0x67b, C68kScript.u8(-memory.read_s8(ctl + 0x67b)))
	memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xbfff)
	memory.write_u32(ctl + 0x622, 0)
	memory.write_u16(ctl + 0x620, 0)
	memory.write_u32(DAT_000267a8, 0)
	memory.write_u32(DAT_000267a4, 0)
	memory.write_u32(DAT_000267a0, memory.read_u32(obj + 0x18))
	memory.write_u32(DAT_0002679c, memory.read_u32(obj + 0x20))
	memory.write_u16(DAT_000267ae, 0x11b if memory.read_s32(DAT_000267bc + 4) <= 0x43 else 0x181)
	memory.write_u32(DAT_00026798, memory.read_u32(ctl + 0x32))
	memory.write_u32(ctl + 0x32, 0x1a186)
	return 0

## Truncating (x * word) / 4096 as the glide does it: muls.l, +0xfff when negative, asr 12.
func _glide_scale(value: int, word: int) -> int:
	var v: int = C68kScript.s32(value * word)
	if v < 0:
		v = C68kScript.s32(v + 0xfff)
	return C68kScript.asr32(v, 12)

## 0x1a1a6 (+0x32 handler 0x1a186): the landing glide. Link a6 -0x10 and ten registers (body 0x3c
## below); the heading word lives at a6 - 2 (attitude_from_velocity may leave it unwritten).
## +0x2e is held at -4000 and the gear byte +0x679 saved for the frame. Range d = 3D distance to
## glide_aim (0x58 below); lead s = d - 13000 above 0xae30, (d - 10000) - (d - 0x8e30) * 3000 /
## 8192 above 0x8e30, else d - 10000. Target = aim - s * glide_dir / 4096 (x, y, z); y at or
## below aim y + floor (word 0x267ae) sits on the floor, else s > 40000 adds (own y - y) / 8 and
## s > 0x8c40 adds ((s - 0x8c40) * (own y - y) / 4096) / 8. Throttle target 0x9d8 (s > 0x9ab0),
## 0 (s < 4000) or 0x7bc. Heading to the target (k = 1 + asr steps of |dx| + |dz|, abs 0x44 /
## 0x48 below, attitude 0x5c below); lateral offset = abs_int(word of ((own x - aim x) * dir z -
## (own z - aim z) * dir x) / 4096) (0x60 below); x -= sin(heading) * off / 4096, z += cos *
## off / 4096 (muls.w; sin 0x44 / cos 0x48 below). On the ground (+0x63e) +0x32 = the saved
## handler. Blend word 0x267ac (1, 2 -> 0) mixes the target halfway with own position + 45 *
## velocity (x / z stored in glide_start at 1). Height error e = y - own y feeds a 33 e - 32
## e(prev, +0x622) controller with remainder 0x267a4 and integral 0x267a8 (/ 16, clamped to
## +-0x4b0) added to y; glide_start x / z move 1/8 of the way to x / z and are the target, also
## mirrored into the type10_controller object. adjust_ai_throttle_vs_speed (0x48 below),
## steer_entity_toward_point (0x58 below). Within 15000..18000 an |e| > 100 (0x44 below) or a
## speed error over 0x5a waves off: word 0x1b83c = 1, +0x32 = saved handler. +0x2e and the gear
## byte are restored; update_aircraft_entity (0x44 below).
func tick_landing_approach_glide(ctl: int) -> void:
	assert(memory != null, "tick_landing_approach_glide requires original global memory")
	assert(a7 != 0, "tick_landing_approach_glide needs a7 (its frame holds the heading word)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x3c
	var saved_floor: int = memory.read_u32(ctl + 0x2e)
	var saved_gear: int = memory.read_u8(ctl + 0x679)
	var obj: int = memory.read_u32(ctl)
	var aim_x: int = memory.read_s32(DAT_000267bc)
	var aim_y: int = memory.read_s32(DAT_000267bc + 4)
	var aim_z: int = memory.read_s32(DAT_000267bc + 8)
	a7 = body - 0x1c
	var range_d: int = C68kScript.s32(approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), aim_x, aim_y, aim_z))
	a7 = entry_a7
	memory.write_u32(ctl + 0x2e, 0xfffff060)
	var lead: int
	if range_d > 0xae30:
		lead = C68kScript.s32(range_d - 13000)
	elif range_d > 0x8e30:
		var cut: int = C68kScript.s32(C68kScript.s32(range_d - 0x8e30) * 3000)
		if cut < 0:
			cut = C68kScript.s32(cut + 0x1fff)
		lead = C68kScript.s32(C68kScript.s32(range_d - 10000) - C68kScript.asr32(cut, 13))
	else:
		lead = C68kScript.s32(range_d - 10000)
	var tx: int = C68kScript.s32(aim_x - _glide_scale(memory.read_s16(DAT_000267b2), lead))
	var ty: int = C68kScript.s32(aim_y - _glide_scale(memory.read_s16(DAT_000267b2 + 4), lead))
	var floor_y: int = C68kScript.s32(memory.read_s16(DAT_000267ae) + memory.read_u32(DAT_000267bc + 4))
	if floor_y >= ty:
		ty = floor_y
	else:
		var rise: int = 0
		var apply: bool = true
		if lead > 0x9c40:
			rise = C68kScript.s32(memory.read_u32(obj + 0x1c) - ty)
		elif lead > 0x8c40:
			rise = _glide_scale(C68kScript.s32(memory.read_u32(obj + 0x1c) - ty), C68kScript.s32(lead - 0x8c40))
		else:
			apply = false
		if apply:
			if rise < 0:
				rise += 7
			ty = C68kScript.s32(ty + (rise >> 3))
	var tz: int = C68kScript.s32(aim_z - _glide_scale(memory.read_s16(DAT_000267b2 + 8), lead))
	var throttle: int = 0x9d8 if lead > 0x9ab0 else (0 if lead <= 0xf9f else 0x7bc)
	var sum: int = C68kScript.s32(abs_int(C68kScript.s32(memory.read_u32(obj + 0x18) - tx)) + abs_int(C68kScript.s32(memory.read_u32(obj + 0x20) - tz)))
	var shift: int = 0
	while (C68kScript.u32(sum) & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		sum = C68kScript.asr32(sum, 1)
	shift = C68kScript.s16(shift + 1)
	a7 = body - 0x20
	attitude_from_velocity(C68kScript.asr32(C68kScript.s32(tx - memory.read_u32(obj + 0x18)), shift), 0, C68kScript.asr32(C68kScript.s32(tz - memory.read_u32(obj + 0x20)), shift), 0, 0, 0, a6 - 2)
	a7 = entry_a7
	var cross: int = C68kScript.s32(C68kScript.s32(memory.read_s16(DAT_000267b2 + 8) * C68kScript.s32(memory.read_u32(obj + 0x18) - aim_x)) - C68kScript.s32(memory.read_s16(DAT_000267b2) * C68kScript.s32(memory.read_u32(obj + 0x20) - aim_z)))
	if cross < 0:
		cross = C68kScript.s32(cross + 0xfff)
	var offset: int = C68kScript.s16(abs_int(C68kScript.s16(C68kScript.asr32(cross, 12))))
	var heading: int = memory.read_s16(a6 - 2)
	a7 = body - 8
	var turn: int = C68kScript.s16(sin_fixed14(heading)) * offset
	if turn < 0:
		turn += 0xfff
	tx = C68kScript.s32(tx - (turn >> 12))
	a7 = body - 0xc
	turn = C68kScript.s16(cos_fixed14(heading)) * offset
	a7 = entry_a7
	if turn < 0:
		turn += 0xfff
	tz = C68kScript.s32(tz + (turn >> 12))
	if memory.read_u8(ctl + 0x63e) != 0:
		memory.write_u32(ctl + 0x32, memory.read_u32(DAT_00026798))
	var blend: int = memory.read_s16(DAT_000267ac)
	if blend != 0:
		var px: int = C68kScript.s32(C68kScript.s32(0x2d * memory.read_s32(ctl + 8)) + memory.read_u32(obj + 0x18))
		var py: int = C68kScript.s32(C68kScript.s32(0x2d * memory.read_s32(ctl + 0xc)) + memory.read_u32(obj + 0x1c))
		var pz: int = C68kScript.s32(C68kScript.s32(0x2d * memory.read_s32(ctl + 0x10)) + memory.read_u32(obj + 0x20))
		var mx: int = C68kScript.s32(C68kScript.s32(C68kScript.s32(px - aim_x) * (2 - blend)) + C68kScript.s32(C68kScript.s32(tx - aim_x) * blend))
		if mx < 0:
			mx += 1
		var my: int = C68kScript.s32(C68kScript.s32((2 - blend) * py) + C68kScript.s32(blend * ty))
		if my < 0:
			my += 1
		var mz: int = C68kScript.s32(C68kScript.s32(C68kScript.s32(pz - aim_z) * (2 - blend)) + C68kScript.s32(C68kScript.s32(tz - aim_z) * blend))
		if mz < 0:
			mz += 1
		ty = my >> 1
		tx = C68kScript.s32((mx >> 1) + memory.read_u32(DAT_000267bc))
		tz = C68kScript.s32((mz >> 1) + memory.read_u32(DAT_000267bc + 8))
		if blend == 1:
			memory.write_u32(DAT_000267a0, C68kScript.u32(tx))
			memory.write_u32(DAT_0002679c, C68kScript.u32(tz))
		memory.write_u16(DAT_000267ac, C68kScript.u16(memory.read_u16(DAT_000267ac) + 1))
		if memory.read_s16(DAT_000267ac) == 2:
			memory.write_u16(DAT_000267ac, 0)
	var err: int = C68kScript.s32(ty - memory.read_u32(obj + 0x1c))
	var acc: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(err - memory.read_u32(ctl + 0x622)), 5) + memory.read_u32(DAT_000267a4))
	memory.write_u32(ctl + 0x622, C68kScript.u32(err))
	acc = C68kScript.s32(err + acc)
	var rounded: int = C68kScript.s32(acc + 0xf) if acc < 0 else acc
	memory.write_u32(DAT_000267a4, C68kScript.u32(acc - (rounded & ~0xf)))
	var integral: int = C68kScript.s32(memory.read_u32(DAT_000267a8) + C68kScript.asr32(rounded, 4))
	integral = clampi(integral, -0x4b0, 0x4b0)
	memory.write_u32(DAT_000267a8, C68kScript.u32(integral))
	ty = C68kScript.s32(ty + integral)
	var dx: int = C68kScript.s32(tx - memory.read_u32(DAT_000267a0))
	if dx < 0:
		dx += 7
	var sx: int = C68kScript.s32((dx >> 3) + memory.read_u32(DAT_000267a0))
	var dz: int = C68kScript.s32(tz - memory.read_u32(DAT_0002679c))
	if dz < 0:
		dz += 7
	var sz: int = C68kScript.s32((dz >> 3) + memory.read_u32(DAT_0002679c))
	memory.write_u32(DAT_000267a0, C68kScript.u32(sx))
	memory.write_u32(DAT_0002679c, C68kScript.u32(sz))
	var tracker: int = memory.read_u32(DAT_00020b40)
	if tracker != 0:
		memory.write_u32(memory.read_u32(tracker) + 0x18, C68kScript.u32(sx))
		memory.write_u32(memory.read_u32(tracker) + 0x1c, C68kScript.u32(ty))
		memory.write_u32(memory.read_u32(tracker) + 0x20, C68kScript.u32(sz))
	a7 = body - 0xc
	adjust_ai_throttle_vs_speed(ctl, throttle)
	a7 = body - 0x1c
	steer_entity_toward_point(ctl, C68kScript.u32(sx), C68kScript.u32(ty), C68kScript.u32(sz))
	a7 = entry_a7
	if range_d <= 0x464f and range_d > 0x3a98:
		if abs_int(err) > 100 or abs_int(C68kScript.s32(throttle - C68kScript.asr32(memory.read_u32(ctl + 0x62a), 2))) > 0x5a:
			memory.write_u16(DAT_0001b83c, 1)
			memory.write_u32(ctl + 0x32, memory.read_u32(DAT_00026798))
	memory.write_u32(ctl + 0x2e, saved_floor)
	memory.write_u8(ctl + 0x679, saved_gear)
	a7 = body - 8
	update_aircraft_entity(ctl)
	a7 = entry_a7

## The AI fly step shared by the state handlers: ai_fly_table[word +0x614] (kind) when non-zero
## (jsr), else update_aircraft_entity; entered `depth` below the caller's entry.
func _ai_fly_step(ctl: int, entry_a7: int, depth: int) -> void:
	var handler: int = memory.read_u32(DAT_0001b3f4 + memory.read_s16(ctl + 0x614) * 4)
	a7 = entry_a7 - depth
	if handler != 0:
		_jsr(handler, [ctl])
	else:
		update_aircraft_entity(ctl)
	a7 = entry_a7

## 0x11182: AI state 0x11162 (no ammo left): just the kind's fly step (0xc below).
func ai_fly(ctl: int) -> void:
	assert(memory != null, "ai_fly requires original global memory")
	_ai_fly_step(ctl, a7, 0xc)

## 0x111ae: AI state 0x1118e (friendly bomber): the same fly step (0xc below).
func ai_fly_bomber(ctl: int) -> void:
	assert(memory != null, "ai_fly_bomber requires original global memory")
	_ai_fly_step(ctl, a7, 0xc)

## 0x111da: AI state 0x111ba (escort / dive). With a live target that has vertices: +0x696 =
## horizontal distance (approx_dist3_xyz with y 0); aim at the target's height within 45000
## (0xafc8), else 40000; throttle toward 0xd5c (0x1c below); with the ground lowered to -40000
## (+0x2e) steer at the target (0x2c below), then fly with the ground at 0 (update_aircraft_entity,
## 0x30 below) and restore +0x2e. Without a target, in host mode 7 while the target list word +4
## is 0, it just flies on; otherwise (or with a dead target) the target is released and the state
## becomes 0x110d4 with ammo (word +0x682 > 2) or 0x11162. A frame not flown by the dive takes
## the kind's fly step (0x18 below).
func ai_dive_at_target(ctl: int) -> void:
	assert(memory != null, "ai_dive_at_target requires original global memory")
	var entry_a7: int = a7
	var target: int = memory.read_u32(ctl + 0x692)
	if target != 0 and (memory.read_u8(target + 7) & 2) == 0 and memory.read_u32(target + 0x44) != 0:
		var own: int = memory.read_u32(ctl)
		memory.write_u32(ctl + 0x696, C68kScript.u32(approx_dist3_xyz(memory.read_s32(own + 0x18), 0, memory.read_s32(own + 0x20), memory.read_s32(target + 0x18), 0, memory.read_s32(target + 0x20))))
		var aim_y: int = memory.read_u32(target + 0x1c) if memory.read_s32(ctl + 0x696) <= 0xafc8 else 0x9c40
		a7 = entry_a7 - 0x1c
		adjust_ai_throttle_vs_speed(ctl, 0xd5c)
		var saved_floor: int = memory.read_u32(ctl + 0x2e)
		memory.write_u32(ctl + 0x2e, 0xffff63c0)
		a7 = entry_a7 - 0x2c
		steer_entity_toward_point(ctl, memory.read_u32(target + 0x18), aim_y, memory.read_u32(target + 0x20))
		memory.write_u32(ctl + 0x2e, 0)
		a7 = entry_a7 - 0x30
		update_aircraft_entity(ctl)
		a7 = entry_a7
		memory.write_u32(ctl + 0x2e, saved_floor)
		return
	var waiting: bool = target == 0 and memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) == 7 and memory.read_u16(memory.read_u32(DAT_00020adc) + 4) == 0
	if not waiting:
		a7 = entry_a7 - 0x18
		release_ai_target(ctl)
		a7 = entry_a7
		memory.write_u32(ctl + 0x32, 0x110d4 if memory.read_s16(ctl + 0x682) > 2 else 0x11162)
	_ai_fly_step(ctl, entry_a7, 0x18)

## 0x112e0: AI state 0x112c0 (bombing run) on a live target with bombs (byte +0x67c): +0x696 =
## horizontal distance. Stage byte +0x675: 0 approach - within 40000 and above 24999 it becomes
## 1 (aiming at the target), else it heads for the target at 30000; 1 dive - below 5000 the
## bombs are armed (+0x674 = 1) and the stage becomes 2; it steers at the target with the ground
## lowered to -40000 and flies with the ground at 0 (restored after); 2 pull out - steers toward
## its own position + 0x2000 * velocity at 30000 and, past 45000, resets the stage and releases the
## target. Other stage values fly nothing here. Each stage steers 0x34 / flies 0x38 below; then
## the throttle eases toward 0xd5c (0x2c below). Without a usable target the target is released
## and the state becomes 0x110d4 (ammo > 2) or 0x11162. A frame not flown takes the kind's fly
## step (0x28 below).
func ai_bombing_run(ctl: int) -> void:
	assert(memory != null, "ai_bombing_run requires original global memory")
	var entry_a7: int = a7
	var target: int = memory.read_u32(ctl + 0x692)
	var flown: bool = false
	if target == 0 or memory.read_u8(ctl + 0x67c) == 0 or (memory.read_u8(target + 7) & 2) != 0 or memory.read_u32(target + 0x44) == 0:
		a7 = entry_a7 - 0x28
		release_ai_target(ctl)
		a7 = entry_a7
		memory.write_u32(ctl + 0x32, 0x110d4 if memory.read_s16(ctl + 0x682) > 2 else 0x11162)
	else:
		var own: int = memory.read_u32(ctl)
		memory.write_u32(ctl + 0x696, C68kScript.u32(approx_dist3_xyz(memory.read_s32(own + 0x18), 0, memory.read_s32(own + 0x20), memory.read_s32(target + 0x18), 0, memory.read_s32(target + 0x20))))
		var aim_x: int = memory.read_u32(target + 0x18)
		var aim_y: int = memory.read_u32(target + 0x1c)
		var aim_z: int = memory.read_u32(target + 0x20)
		var stage: int = memory.read_s8(ctl + 0x675)
		if stage == 1:
			if memory.read_s32(own + 0x1c) <= 0x1387:
				memory.write_u8(ctl + 0x674, 1)
				memory.write_u8(ctl + 0x675, 2)
			var saved_floor: int = memory.read_u32(ctl + 0x2e)
			memory.write_u32(ctl + 0x2e, 0xffff63c0)
			a7 = entry_a7 - 0x34
			steer_entity_toward_point(ctl, aim_x, aim_y, aim_z)
			memory.write_u32(ctl + 0x2e, 0)
			a7 = entry_a7 - 0x38
			update_aircraft_entity(ctl)
			a7 = entry_a7
			flown = true
			memory.write_u32(ctl + 0x2e, saved_floor)
		elif stage == 0:
			if memory.read_s32(ctl + 0x696) <= 0x9c40 and memory.read_s32(own + 0x1c) > 0x61a7:
				memory.write_u8(ctl + 0x675, 1)
			else:
				aim_y = 0x7530
			a7 = entry_a7 - 0x34
			steer_entity_toward_point(ctl, aim_x, aim_y, aim_z)
			a7 = entry_a7 - 0x38
			update_aircraft_entity(ctl)
			a7 = entry_a7
			flown = true
		elif stage == 2:
			a7 = entry_a7 - 0x34
			steer_entity_toward_point(ctl, C68kScript.u32(C68kScript.lsl32(memory.read_u32(ctl + 8), 13) + memory.read_u32(own + 0x18)), 0x7530, C68kScript.u32(C68kScript.lsl32(memory.read_u32(ctl + 0x10), 13) + memory.read_u32(own + 0x20)))
			a7 = entry_a7 - 0x38
			update_aircraft_entity(ctl)
			a7 = entry_a7
			flown = true
			if memory.read_s32(ctl + 0x696) > 0xafc8:
				memory.write_u8(ctl + 0x675, 0)
				a7 = entry_a7 - 0x2c
				release_ai_target(ctl)
				a7 = entry_a7
		a7 = entry_a7 - 0x2c
		adjust_ai_throttle_vs_speed(ctl, 0xd5c)
		a7 = entry_a7
	if not flown:
		_ai_fly_step(ctl, entry_a7, 0x28)

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
