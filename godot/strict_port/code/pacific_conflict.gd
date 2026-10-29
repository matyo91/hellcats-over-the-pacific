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
const DAT_0001b42c: int = 0x1b42c ## effect_pre_render_table: per-kind effect pre-render hook (runtime code addresses)
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
const DAT_00026784: int = 0x26784 ## cloud_templates: template object per cloud kind (long each, 5 slots)
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
const DAT_0002666a: int = 0x2666a ## radar_range (long)
const DAT_00026664: int = 0x26664 ## radar_scale (word): radar_range per scope pixel
const DAT_0001b520: int = 0x1b520 ## radar_drawn_tracks (pointer): last frame's tracks
const DAT_0001da90: int = 0x1da90 ## depth routine: erase a radar blip (x, y)
const DAT_0001da94: int = 0x1da94 ## depth routine: draw a radar blip (x, y)
const DAT_00024d10: int = 0x24d10 ## channel1_sound (long): the sound playing on channel 1, 0 when none
const DAT_00024d14: int = 0x24d14 ## engine_sound_choice (long)
const DAT_000265d0: int = 0x265d0 ## dot_object_count (word): objects drawn as dots this frame (up to 30)
const DAT_000265d2: int = 0x265d2 ## dot_object_list: object pointers drawn as dots
const DAT_0001da88: int = 0x1da88 ## bw_pattern_first (word): the dot colour / pattern
const DAT_0001da8c: int = 0x1da8c ## dot_record_count (word): dots plotted this frame
const DAT_00020b2a: int = 0x20b2a ## view_half_width (word)
const DAT_00020b2c: int = 0x20b2c ## view_half_rows (word)
const DAT_00026288: int = 0x26288 ## dot_records: 14 bytes each (+0 pixel, +4 phase, +6 size, +8 colour, +9..+0xc saved)
const DAT_0001c1be: int = 0x1c1be ## draw_order_next (word)
const DAT_0001b48c: int = 0x1b48c ## dot_corner_dx: 4 corners x 4 sizes (long)
const DAT_0001b4cc: int = 0x1b4cc ## dot_corner_dy: 4 corners x 4 sizes (long)
const DAT_0001c1d0: int = 0x1c1d0 ## view_point_count (long)
const DAT_0001c43c: int = 0x1c43c ## view_points: camera-relative points (3 longs each)
const DAT_0001c1c0: int = 0x1c1c0 ## visible_first_pass (word): visible_list entries of the near pass
const DAT_0001c1c4: int = 0x1c1c4 ## overlap_count (long)
const DAT_0001c1e4: int = 0x1c1e4 ## overlap_list: objects with +4 bit 0x8000
const DAT_00020b44: int = 0x20b44 ## cell_face_a / cell_face_b (words at +0 / +2): the terrain cell faces found
const DAT_00020b48: int = 0x20b48 ## cell_plane (long): the plane fractal_height_at used
const DAT_0001c1c8: int = 0x1c1c8 ## live_controller_count (long; its low word at 0x1c1ca)
const DAT_0001d80c: int = 0x1d80c ## camera_angle3 (word): negated camera bank
const DAT_0001d808: int = 0x1d808 ## camera_angle4 (long)
const DAT_00024d1a: int = 0x24d1a ## camera_pitch (word)
const DAT_00024d18: int = 0x24d18 ## camera_heading (word)
const DAT_0001bd7c: int = 0x1bd7c ## panel_back_offset (long): saved panel copy offset
const DAT_00024d20: int = 0x24d20 ## camera_goal z / y / x (longs at 0x24d20 / 24 / 28)
const DAT_0001d814: int = 0x1d814 ## camera_step z / y / x (longs at 0x1d814 / 18 / 1c)
const DAT_0001b86e: int = 0x1b86e ## replay_frames_left (word)
const DAT_00024d1c: int = 0x24d1c ## target_hold_frames (long)
const DAT_0001cbe4: int = 0x1cbe4 ## entity_array_4: object pointers
const DAT_0001c1d8: int = 0x1c1d8 ## entity_array_4_count (long)
const DAT_0001d710: int = 0x1d710 ## far_ref / detail_ref z, y, x (six longs to 0x1d724)
const DAT_0001d70c: int = 0x1d70c ## alt_band (long): power of two at or below camera y
const DAT_0001d704: int = 0x1d704 ## alt_band_log2 (word)
const DAT_0001bdac: int = 0x1bdac ## mission_child2or3 (object pointer): its first four vertices follow the altitude value
const DAT_0001bdb0: int = 0x1bdb0 ## mission_child1 (object pointer): vertices 8 / 9 follow the altitude value
const DAT_0001b214: int = 0x1b214 ## alt_value_table: altitude value per band (long)
const DAT_0001b264: int = 0x1b264 ## alt_tolerance_table: outline tolerance per band (long)
const DAT_00024cec: int = 0x24cec ## scatter_started (long)
const DAT_0001d856: int = 0x1d856 ## view_flag_d856 (word): reset the ground scatter points
const DAT_0001b924: int = 0x1b924 ## scatter_point_x: 64 ground scatter points (x, y, z longs)
const DAT_0001b8e4: int = 0x1b8e4 ## scatter_state: 64 bytes (bit 7 on screen, bit 6 surface cached, low 6 bits slot or 0x3f)
const DAT_0001b894: int = 0x1b894 ## scatter_slot_point: 7 words, the point each scatter slot sits on
const DAT_0001b8a4: int = 0x1b8a4 ## scatter_surface: 64 cached surface type bytes
const DAT_0001bc24: int = 0x1bc24 ## scatter_templates: template object per surface type >> 4 (long)
const DAT_00020b28: int = 0x20b28 ## proj_scale_x (word)
const DAT_00020b26: int = 0x20b26 ## proj_scale_y (word)
const DAT_00024d4a: int = 0x24d4a ## face_normals: object +0x44 + 12 * vertex count (long)
const DAT_00024d4e: int = 0x24d4e ## vertex0_x: model vertex 0 (x, y, z longs)
const DAT_00024d5a: int = 0x24d5a ## vertex_shift (word): asr count for model vertex longs
const DAT_00024d5c: int = 0x24d5c ## eye_obj_z (word)
const DAT_00024d5e: int = 0x24d5e ## eye_obj_y (word)
const DAT_00024d60: int = 0x24d60 ## eye_obj_x (word)
const DAT_00025b24: int = 0x25b24 ## prepared_object: model being drawn
const DAT_00020ad4: int = 0x20ad4 ## background_rows: 8-byte background spans per view row
const DAT_00025ffe: int = 0x25ffe ## heading_tape_pos (word)
const DAT_00025ffc: int = 0x25ffc ## readouts_drawn (word)
const DAT_00020ae4: int = 0x20ae4 ## panels_drawn (word)
const DAT_00025f4a: int = 0x25f4a ## needle_end_x: needle end x per instrument (long [type])
const DAT_00025f92: int = 0x25f92 ## needle_end_y: needle end y per instrument (long [type])
const DAT_0001da98: int = 0x1da98 ## depth_routine_da98: restore-line code address
const DAT_0001da9c: int = 0x1da9c ## depth_routine_da9c: draw-line code address
const DAT_00025fda: int = 0x25fda ## alt_short_end_x (long)
const DAT_00025fde: int = 0x25fde ## alt_short_end_y (long)
const DAT_00025fe2: int = 0x25fe2 ## bomb_count_shown (word)
const DAT_00025fe4: int = 0x25fe4 ## high_flag_shown (word)
const DAT_00025fe6: int = 0x25fe6 ## throttle_shown (word)
const DAT_00025fe8: int = 0x25fe8 ## flaps_shown (word)
const DAT_00025fea: int = 0x25fea ## gear_shown (word)
const DAT_00025fec: int = 0x25fec ## ammo_shown (word)
const DAT_00025fee: int = 0x25fee ## fuel_left_shown (word)
const DAT_00025ff0: int = 0x25ff0 ## fuel_right_shown (word)
const DAT_0001bc80: int = 0x1bc80 ## climb_rate (long)
const DAT_00020ae2: int = 0x20ae2 ## view_inset (word): 4 when the panels reserve their rows; also the readout loop count
const DAT_00025ff2: int = 0x25ff2 ## readout_index (word): next numeric readout, 0..3
const DAT_00025ff4: int = 0x25ff4 ## readout_cache: last drawn |value| of the four readouts (word [4])
const DAT_00020ad8: int = 0x20ad8 ## background_rows_next: row span buffer built this frame
const DAT_00025f34: int = 0x25f34 ## bg_cache_origin: cached host +0x186..+0x199 (20 bytes)
const DAT_00025f3a: int = 0x25f3a ## bg cache rows (word, cached host +0x18c)
const DAT_00025f44: int = 0x25f44 ## bg_row_extents: cached host +0x196 (per-row x0 / x1 words)
const DAT_00025f48: int = 0x25f48 ## bg_frame_parity (word)
const DAT_0001bd90: int = 0x1bd90 ## horizon_corners (long)
const DAT_0001bd94: int = 0x1bd94 ## horizon_y1 (long)
const DAT_0001bd98: int = 0x1bd98 ## horizon_x1 (long)
const DAT_0001bd9c: int = 0x1bd9c ## horizon_y0 (long)
const DAT_0001bda0: int = 0x1bda0 ## horizon_x0 (long)
const DAT_00020ac0: int = 0x20ac0 ## span_filler: selected span-filler code address
const DAT_00025f30: int = 0x25f30 ## face_table: face records (0x20 bytes) of prepared_object
const DAT_00025d2c: int = 0x25d2c ## face_queue_end: append pointer of the emitted-face queue
const DAT_00025b16: int = 0x25b16 ## near_mode (word)
const DAT_00025b28: int = 0x25b28 ## back_face_queue_end: append cursor of the kept back faces
const DAT_00025b18: int = 0x25b18 ## root_face_count (word)
const DAT_00025b1a: int = 0x25b1a ## screen_poly_count (word)
const DAT_00024df2: int = 0x24df2 ## screen_poly_x: clipped screen polygon ((x, y) long pairs)
const DAT_00025252: int = 0x25252 ## clip_poly_buf: second (x, y) point buffer
const DAT_00020ab0: int = 0x20ab0 ## edge_pool_count (long)
const DAT_0001b76c: int = 0x1b76c ## session_entry_ptr: edge pool base (0x1c-byte records)
const DAT_00020af0: int = 0x20af0 ## view_centre_fixed (long)
const DAT_0001eaac: int = 0x1eaac ## row_edge_buckets: per-row edge list heads (long)
const DAT_0001daa4: int = 0x1daa4 ## row_has_edges: word flag per row
const DAT_00024d62: int = 0x24d62 ## object_matrix: pointer to the nine-word object-to-camera matrix
const DAT_00024d66: int = 0x24d66 ## vertex_done: byte per model vertex
const DAT_000256b2: int = 0x256b2 ## projected_x: projected (x, y) long pair per view vertex (0x80000000 = behind)
const DAT_00025b20: int = 0x25b20 ## view_vertices: camera-space vertex buffer of prepared_object
const DAT_00025b14: int = 0x25b14 ## force_near_clip (word)
const DAT_00025b12: int = 0x25b12 ## face_was_clipped (word)
const DAT_00020ab4: int = 0x20ab4 ## depth_routine_ab4: face output code address (0xa14e / 0xa200)
const DAT_00025d30: int = 0x25d30 ## face_queue: start of the emitted-face queue
const DAT_00025b2c: int = 0x25b2c ## back_face_queue: start of the kept back faces
const DAT_0001d72c: int = 0x1d72c ## object_attitude: 3x3 s16 attitude matrix of the drawn object
const DAT_00024d38: int = 0x24d38 ## object_camera_matrix: object_attitude x camera matrix
const DAT_0001bda4: int = 0x1bda4 ## mission_child4: the object drawn last in view 1
const DAT_0001b83e: int = 0x1b83e ## snd_approach_refused (word)
const DAT_0001b846: int = 0x1b846 ## snd_gear_alt (word): plays sound 100
const DAT_0001b84c: int = 0x1b84c ## flaps_moving (word)
const DAT_0001b84e: int = 0x1b84e ## gear_moving (word)
const DAT_0001b850: int = 0x1b850 ## snd_ditch (word)
const DAT_0001b852: int = 0x1b852 ## snd_gun (word)
const DAT_0001b854: int = 0x1b854 ## snd_grass (word)
const DAT_0001b856: int = 0x1b856 ## snd_wheel (word)
const DAT_0001da8a: int = 0x1da8a ## colour_tally_index (word)
const DAT_0001d800: int = 0x1d800 ## camera_angle6 (long)
const DAT_0001d804: int = 0x1d804 ## camera_angle5 (long)
const DAT_0001bdb4: int = 0x1bdb4 ## mission_child0 (object pointer)
const DAT_0001b85c: int = 0x1b85c ## carried_pair_count (word)
const DAT_0001b860: int = 0x1b860 ## carried_pairs: pointer to (carrier object, rider object) pairs
const DAT_0001c1d6: int = 0x1c1d6 ## low word of visible_count (DAT_0001c1d4)
const DAT_00020ae8: int = 0x20ae8 ## view_half_height (word)
const DAT_0001b834: int = 0x1b834 ## half_rows_mode (long)
const DAT_00020ae6: int = 0x20ae6 ## scan_last_row (word)
const DAT_0001b794: int = 0x1b794 ## session_cur_b (span buffer)
const DAT_0001b798: int = 0x1b798 ## session_cur_a (span buffer)
const DAT_0001b774: int = 0x1b774 ## session_ptrs_a: span buffer a per new_frame (longs)
const DAT_0001b784: int = 0x1b784 ## session_ptrs_b: span buffer b per new_frame (longs)
const DAT_0001b868: int = 0x1b868 ## player_landing_state (word): 2 = stopped after a touchdown
const DAT_0001b86a: int = 0x1b86a ## friendly_landing_scored (word)
const DAT_0001b73c: int = 0x1b73c ## loadout_synced (word)
const DAT_0001b858: int = 0x1b858 ## rudder_key (word): +0x40 / -0x40
const DAT_0001d824: int = 0x1d824 ## ext_camera_point (x, y, z longs) for view 6
const DAT_00024cf4: int = 0x24cf4 ## fire_button (word)
const DAT_00024cf6: int = 0x24cf6 ## throttle_step (word): the +/- throttle ramp
const DAT_00024cf8: int = 0x24cf8 ## view_key_angle_b (long): look pitch target
const DAT_00024cfc: int = 0x24cfc ## view_key_angle_a (long): look yaw target
const DAT_00024d00: int = 0x24d00 ## track_pitch (long): view-6 camera pitch
const DAT_00024d04: int = 0x24d04 ## track_heading (long): view-6 camera heading
const DAT_00024d2c: int = 0x24d2c ## flight_word_24d2c: keyboard elevator (-1 / 0 / +1)
const DAT_00024d2e: int = 0x24d2e ## flight_word_24d2e: keyboard aileron (-1 / 0 / +1)
const DAT_00024d30: int = 0x24d30 ## host_word_340: last keyboard-steered mouse v
const DAT_00024d32: int = 0x24d32 ## host_word_33e: last keyboard-steered mouse h
const DAT_00024d34: int = 0x24d34 ## host_words_valid: keyboard steering on
const DAT_00020af4: int = 0x20af4 ## scale_table_index (word): view-6 zoom level
const DAT_00020afc: int = 0x20afc ## proj_scale_y_table (8 words)
const DAT_00020b14: int = 0x20b14 ## proj_scale_x_table (8 words)
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
	## attitude_compose_tag values: the alt (transposed) composers, run by the tagged invokers.
	code_table[0x2408] = Callable(self, "finalize_attitude_matrix_3ang_alt")
	code_table[0x2468] = Callable(self, "compose_attitude_matrix_x_alt")
	code_table[0x26e0] = Callable(self, "compose_attitude_matrix_6ang_alt")
	## The rectangle blitters the heading tape reaches through code addresses (move.l #imm).
	code_table[0xbc88] = Callable(self, "copy_rect_depth4")
	code_table[0xbf90] = Callable(self, "copy_rect_depth8")
	## The face outputs submit_object_faces reaches through depth_routine_ab4.
	code_table[0xa14e] = Callable(self, "output_face_colour")
	code_table[0xa200] = Callable(self, "output_face_bw")
	## pea $c4c(pc) in find_anchor_point: file 0xc4c = runtime 0xc2c.
	code_table[0xc2c] = Callable(self, "anchor_point_visitor")
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
	code_table[0x12a0a] = Callable(self, "ordnance_tick")
	code_table[0x19918] = Callable(self, "parachute_tick")
	## Broad-phase collision tests (bsr targets of collect_far_objects, see _far_collision).
	code_table[0x13ec0] = func(a: int, b: int) -> int: return test_object_collision(a, b)
	code_table[0x1427c] = func(a: int, b: int) -> void: handle_player_contact(a, b)
	code_table[0x13e2e] = func(a: int, b: int) -> void: test_proximity_collision(a, b)
	code_table[0x13e8e] = func(a: int, b: int) -> void: test_player_vs_type0e_proximity(a, b)
	## Definition records (0x1e bytes: +2 tick, +6 create, +0xa destroy, +0xe pre-render).
	## Template registration: the first create hook (+6) of these records stores the template
	## object and redirects +6 to the controller factory.
	code_table[0x115ba] = func(o: int, k: int, _c: int = 0) -> int: return register_smoke_template(o, k)
	code_table[0x11b28] = func(o: int, k: int, _c: int = 0) -> int: return register_effect_template(o, k)
	code_table[0x127fe] = func(o: int, k: int, _c: int = 0) -> int: return register_ordnance_template(o, k)
	code_table[0x15bb4] = func(o: int, k: int, _c: int = 0) -> int: return register_bullet_template(o, k)
	code_table[0x16a58] = func(o: int, k: int, _c: int = 0) -> int: return register_trail_templates(o, k)
	code_table[0x17078] = func(o: int, k: int, _c: int = 0) -> int: return register_ground_fire_template(o, k)
	code_table[0x173bc] = func(o: int, k: int, _c: int = 0) -> int: return register_debris_template(o, k)
	code_table[0x1757e] = func(o: int, k: int, _c: int = 0) -> int: return register_ground_mark_template(o, k)
	code_table[0x188d4] = func(o: int, k: int, _c: int = 0) -> int: return register_shadow_templates(o, k)
	code_table[0x190ee] = func(o: int, k: int, _c: int = 0) -> int: return register_turret_template(o, k)
	code_table[0x193ee] = func(o: int, k: int, _c: int = 0) -> int: return register_parachute_template(o, k)
	code_table[0x19a34] = func(o: int, k: int, _c: int = 0) -> int: return register_cloud_templates(o, k)
	code_table[0x116c8] = Callable(self, "destroy_plume_controller")
	code_table[0x11a70] = Callable(self, "plume_pre_render")
	code_table[0x18a14] = Callable(self, "shadow_pre_render")
	code_table[0x19374] = Callable(self, "turret_pre_render")
	code_table[0x15e42] = Callable(self, "bullet_pre_render")
	code_table[0x1711c] = Callable(self, "destroy_ground_fire_controller")
	code_table[0x18922] = Callable(self, "destroy_shadow_controller")
	code_table[0x1278a] = Callable(self, "effect_pre_render_hook")
	code_table[0x19b10] = Callable(self, "follow_camera_offset")
	code_table[0x12f72] = func(o: int, k: int, _c: int = 0) -> int: return create_singleton_type10_controller(o, k)
	## effect_pre_render_table (0x1b42c) kinds 0..3: 0x12740 / 0x12744 are the "clr.l d0; rts"
	## tails inside face_object_to_camera (file 0x12760 / 0x12764); kind 2 faces the camera.
	code_table[0x12718] = Callable(self, "face_object_to_camera")
	code_table[0x12740] = func(_ctl: int) -> int: return 0
	code_table[0x12744] = func(_ctl: int) -> int: return 0
	## Collision pair handler (pair table entry at 0x2a7fc).
	code_table[0x1688e] = func(a: int, b: int, _c: int = 0) -> int: return impact_one_time_in_16(a, b)
	code_table[0x194fa] = Callable(self, "destroy_parachute_controller")
	code_table[0x12f32] = func(a: int, b: int, _c: int = 0) -> void: ordnance_collision(a, b)
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
	## clear_flag_00020ae4 (file 0x6ece), reachable as a code address.
	code_table[0x6eae] = Callable(self, "clear_flag_00020ae4")


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

## As point_in_polygon_xz with the second coordinate at +6 (0x12fd2: same code, other offset).
func point_in_polygon_xy(px: int, py: int, verts: int, count: int, vidx: int) -> int:
	return _point_in_polygon(px, py, verts, count, vidx, 2, 6)

func _point_in_polygon(pa: int, pb: int, verts: int, count: int, vidx: int, off_a: int, off_b: int = 10) -> int:
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
		var prev_b: int = memory.read_s16(prev + off_b)
		var cur_b: int = memory.read_s16(cur + off_b)
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

## 0x13268: as project_face_vertices_xz for the y / z pair: vertex +4 / +8 asr.l shift minus the
## origins go to output words +6 / +10.
func project_face_vertices_yz(model: int, shift: int, face: int, origin_y: int, origin_z: int, out: int) -> void:
	assert(memory != null, "project_face_vertices_yz requires original global memory")
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
		memory.write_u16(ov + 6, C68kScript.u16(C68kScript.asr32(memory.read_u32(mv + 4), shift) - origin_y))
		memory.write_u16(ov + 10, C68kScript.u16(C68kScript.asr32(memory.read_u32(mv + 8), shift) - origin_z))
		vidx = vidx + 2

## 0x132c8: is the record's object over the face (xz)? Link a6 -0x690 and four registers (body
## 0x6a4 below): the origin is the object x / z shifted by word rec +0xc (asr by its negation when
## negative, else asl); the face is projected into the frame at a6 - 0x690
## (project_face_vertices_xz(rec +4 model, word rec +0xe, face, ...), 0x1c below) and tested at
## (0, 0) (point_in_polygon_xz, 0x30 below), whose D0 is returned.
func point_over_face_xz(rec: int, face: int) -> int:
	assert(memory != null, "point_over_face_xz requires original global memory")
	assert(a7 != 0, "point_over_face_xz needs a7 (its frame holds the projected vertices)")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x6a4
	var projected: int = entry_a7 - 4 - 0x690
	var obj: int = memory.read_u32(rec)
	var shift: int = memory.read_s16(rec + 0xc)
	var origin_x: int
	var origin_z: int
	if shift < 0:
		origin_x = C68kScript.asr32(memory.read_u32(obj + 0x18), -shift)
		origin_z = C68kScript.asr32(memory.read_u32(obj + 0x20), -shift)
	else:
		origin_x = C68kScript.s32(C68kScript.lsl32(memory.read_u32(obj + 0x18), shift))
		origin_z = C68kScript.s32(C68kScript.lsl32(memory.read_u32(obj + 0x20), shift))
	a7 = body - 0x1c
	project_face_vertices_xz(memory.read_u32(rec + 4), memory.read_s16(rec + 0xe), face, origin_x, origin_z, projected)
	a7 = body - 0x30
	var inside: int = point_in_polygon_xz(0, 0, projected, memory.read_s16(face + 0x14), memory.read_u32(face + 0x18))
	a7 = entry_a7
	return inside

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

## 0x128b6: one ballistic frame. Link a6 -0x24 and six registers (body 0x40 below); the attitude
## words go to the frame (a6 - 0x20 pitch, - 0x22 heading: attitude_from_velocity may leave them
## as they were) with the matrix at a6 - 0x1e and the velocity record at a6 - 0xc (words +2 / +6 /
## +0xa). Velocity = (0, 0, speed word +0x610) turned by the attitude (build_attitude_matrix_3ang
## 0x54 below, transform 0x64 below), y - 0x5b (gravity); +8 / +0xc / +0x10 = each word asr 6.
## speed = isqrt of the squared words (0x48 below) and the attitude follows the velocity
## (attitude_from_velocity, 0x64 below); the bank +0x24 turns by sin(pitch) (0x48 below) * the
## folded heading change asr 12. Reaching the ground (+0x2e) clamps the fall, sets flag 0x400
## and, over land (+0x2e > 0) on surfaces 0x30 / 0x60 / 0x70 (+0x2c), the direct hit +0x616.
func ordnance_ballistic_step(ctl: int) -> void:
	assert(memory != null, "ordnance_ballistic_step requires original global memory")
	assert(a7 != 0, "ordnance_ballistic_step needs a7 (its frame holds the velocity and attitude)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x40
	var obj: int = memory.read_u32(ctl)
	memory.write_u16(a6 - 0x20, memory.read_u16(ctl + 0x20))
	memory.write_u16(a6 - 0x22, memory.read_u16(ctl + 0x22))
	var bank: int = memory.read_s16(ctl + 0x24)
	memory.write_u16(a6 - 0x6, 0)
	memory.write_u16(a6 - 0xa, 0)
	memory.write_u16(a6 - 0x2, memory.read_u16(ctl + 0x610))
	a7 = body - 0x14
	build_attitude_matrix_3ang(memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), bank, a6 - 0x1e)
	a7 = body - 0x24
	transform_vecs12_by_matrix3(1, a6 - 0xc, a6 - 0xc, a6 - 0x1e)
	a7 = entry_a7
	memory.write_u16(a6 - 0x6, C68kScript.u16(memory.read_u16(a6 - 0x6) + 0xffa5))
	var vx: int = memory.read_s16(a6 - 0xa)
	var vy: int = memory.read_s16(a6 - 0x6)
	var vz: int = memory.read_s16(a6 - 0x2)
	memory.write_u32(ctl + 8, C68kScript.u32(vx >> 6))
	memory.write_u32(ctl + 0xc, C68kScript.u32(vy >> 6))
	memory.write_u32(ctl + 0x10, C68kScript.u32(vz >> 6))
	var sq: int = C68kScript.s32(C68kScript.s32(vx * vx + vy * vy) + vz * vz)
	a7 = body - 8
	var speed: int = C68kScript.s16(isqrt_floor(sq))
	a7 = body - 0x24
	attitude_from_velocity(vx, vy, vz, speed, sq, a6 - 0x20, a6 - 0x22)
	a7 = entry_a7
	var turn: int = C68kScript.s16(memory.read_u16(a6 - 0x22) - memory.read_u16(ctl + 0x22))
	if turn > 0x2000:
		turn = C68kScript.s16(turn - 0x4000)
	elif turn < -0x2000:
		turn = C68kScript.s16(turn + 0x4000)
	memory.write_u16(ctl + 0x20, memory.read_u16(a6 - 0x20))
	memory.write_u16(ctl + 0x22, memory.read_u16(a6 - 0x22) & 0x3fff)
	a7 = body - 8
	var sine: int = C68kScript.s16(sin_fixed14(memory.read_s16(a6 - 0x20)))
	a7 = entry_a7
	memory.write_u16(ctl + 0x24, (C68kScript.asr32(sine * turn, 12) + bank) & 0x3fff)
	memory.write_u16(ctl + 0x610, C68kScript.u16(speed))
	if C68kScript.s32(memory.read_u32(obj + 0x1c) + memory.read_u32(ctl + 0xc)) <= memory.read_s32(ctl + 0x2e):
		memory.write_u32(ctl + 0xc, C68kScript.u32(memory.read_u32(ctl + 0x2e) - memory.read_u32(obj + 0x1c)))
		memory.write_u16(ctl + 0x61c, memory.read_u16(ctl + 0x61c) | 0x400)
		var surface: int = memory.read_u8(ctl + 0x2c)
		if memory.read_s32(ctl + 0x2e) > 0 and (surface == 0x30 or surface == 0x60 or surface == 0x70):
			memory.write_u16(ctl + 0x616, 1)

## 0x12a2a (definition +2 tick of key 0xc, runtime 0x12a0a): the pose ring entry (+0x32 + 0x14 *
## word +0x60e) is taken and the index advanced (wrapping at 75). Live (replay word 0x1b870 == 0):
## landed twice running (flag 0x400 in +0x61c and +0x61e) it stops, else
## ordnance_ballistic_step (0x18 below); ordnance_detonation (0x18 below); the entry records the
## next position, attitude words and flags. In a replay, from the object's start frame +0x40: on
## replay 1 or that frame the object is set to the entry (velocity 0; at the start frame +0x61e =
## its flags without 0x40), else the velocity leads to it; the attitude and flags come from the
## entry and ordnance_detonation runs with +0x61e restored to those flags afterwards.
func ordnance_tick(ctl: int) -> void:
	assert(memory != null, "ordnance_tick requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	var pose: int = C68kScript.u32(ctl + 0x32 + memory.read_s16(ctl + 0x60e) * 0x14)
	memory.write_u16(ctl + 0x60e, C68kScript.u16(memory.read_u16(ctl + 0x60e) + 1))
	if memory.read_s16(ctl + 0x60e) == 0x4b:
		memory.write_u16(ctl + 0x60e, 0)
	var replay: int = memory.read_s16(DAT_0001b870)
	var frame: int = memory.read_s32(DAT_0001b838)
	if replay == 0:
		if (memory.read_u8(ctl + 0x61c) & 4) != 0 and (memory.read_u8(ctl + 0x61e) & 4) != 0:
			memory.write_u32(ctl + 0x10, 0)
			memory.write_u32(ctl + 0xc, 0)
			memory.write_u32(ctl + 8, 0)
		else:
			a7 = entry_a7 - 0x18
			ordnance_ballistic_step(ctl)
		a7 = entry_a7 - 0x18
		ordnance_detonation(ctl)
		a7 = entry_a7
		for off in [0, 4, 8]:
			memory.write_u32(pose + off, C68kScript.u32(memory.read_u32(obj + 0x18 + off) + memory.read_u32(ctl + 8 + off)))
		memory.write_u16(pose + 0xc, memory.read_u16(ctl + 0x20))
		memory.write_u16(pose + 0xe, memory.read_u16(ctl + 0x22))
		memory.write_u16(pose + 0x10, memory.read_u16(ctl + 0x24))
		memory.write_u16(pose + 0x12, memory.read_u16(ctl + 0x61c))
		return
	if frame < memory.read_s32(obj + 0x40):
		return
	if replay == 1 or frame == memory.read_s32(obj + 0x40):
		memory.write_u32(ctl + 0x10, 0)
		memory.write_u32(ctl + 0xc, 0)
		memory.write_u32(ctl + 8, 0)
		for off in [0, 4, 8]:
			memory.write_u32(obj + 0x18 + off, memory.read_u32(pose + off))
		if memory.read_s32(DAT_0001b838) == memory.read_s32(obj + 0x40):
			memory.write_u16(ctl + 0x61e, memory.read_u16(pose + 0x12) & 0xffbf)
	else:
		for off in [0, 4, 8]:
			memory.write_u32(ctl + 8 + off, C68kScript.u32(memory.read_u32(pose + off) - memory.read_u32(obj + 0x18 + off)))
	memory.write_u16(ctl + 0x61c, memory.read_u16(pose + 0x12))
	memory.write_u16(ctl + 0x20, memory.read_u16(pose + 0xc))
	memory.write_u16(ctl + 0x22, memory.read_u16(pose + 0xe))
	memory.write_u16(ctl + 0x24, memory.read_u16(pose + 0x10))
	var flags_now: int = memory.read_u16(ctl + 0x61c)
	a7 = entry_a7 - 0x18
	ordnance_detonation(ctl)
	a7 = entry_a7
	memory.write_u16(ctl + 0x61e, flags_now)

## 0x12d34: impact (flag 0x400 in +0x61c). The first frame (not yet in +0x61e): a direct hit
## (+0x616) spawns a water splash (spawn_effect 2, 200, 5, 1, 1 at the next position) at or below
## sea level or a ground blast (3, 0x96, 0x2d, 1, 0; counts as a hit) over land; otherwise
## spawn_destruction_effect(obj, 200) (0x20 below) tells whether something was hit (low word).
## A miss blasts in 5 frames; a hit in 15 and, for a credited bomb (+0x614) on a 'p' surface
## (surface_type_under_object, 0x1c below), near an enemy facility (0x100, probe 0x1c below)
## counts host word +0xcc (live only) and in host mode 3 / 4 within 0xce3f of the mission target
## (0x34 below) sets host word +0xce = 1 if it was 0; near a friendly one (0x200) counts host
## +0xd2. +0x618 = frame + delay; dispatch_entity_cleanup (0x1c below). On frame +0x618 the
## blast lands: apply_blast_damage(position, 0x8d4, word +0x614, 0, word +0x616) (0x34 below) and
## it returns. Otherwise a change of flag 0x40 attaches a burning trail (0x28 below), and +0x61e
## takes +0x61c.
func ordnance_detonation(ctl: int) -> void:
	assert(memory != null, "ordnance_detonation requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	if (memory.read_u8(ctl + 0x61c) & 4) != 0:
		if (memory.read_u8(ctl + 0x61e) & 4) != 0:
			if memory.read_s32(DAT_0001b838) == memory.read_s32(ctl + 0x618):
				a7 = entry_a7 - 0x34
				apply_blast_damage(memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), 0x8d4, memory.read_s16(ctl + 0x614), 0, memory.read_s16(ctl + 0x616))
				a7 = entry_a7
				return
		else:
			var hit: int = 0
			if memory.read_u16(ctl + 0x616) != 0:
				var x: int = C68kScript.u32(memory.read_u32(obj + 0x18) + memory.read_u32(ctl + 8))
				var y: int = C68kScript.u32(memory.read_u32(obj + 0x1c) + memory.read_u32(ctl + 0xc))
				var z: int = C68kScript.u32(memory.read_u32(obj + 0x20) + memory.read_u32(ctl + 0x10))
				a7 = entry_a7 - 0x38
				if memory.read_s32(ctl + 0x2e) > 0:
					spawn_effect(3, 0x96, 0x2d, 1, 0, x, y, z)
					hit = 1
				else:
					spawn_effect(2, 0xc8, 5, 1, 1, x, y, z)
				a7 = entry_a7
			else:
				a7 = entry_a7 - 0x20
				hit = spawn_destruction_effect(obj, 0xc8) & 0xffff
				a7 = entry_a7
			var delay: int = 5
			if hit != 0:
				delay = 0xf
				if memory.read_u16(ctl + 0x614) != 0:
					a7 = entry_a7 - 0x1c
					var surface: int = surface_type_under_object(obj)
					a7 = entry_a7
					if C68kScript.s16(surface) == 0x70:
						a7 = entry_a7 - 0x1c
						var facility: int = C68kScript.s16(probe_nearest_facility_kind(obj))
						a7 = entry_a7
						var host: int = memory.read_u32(DAT_0001b5a0)
						if facility == 0x100:
							if memory.read_u16(DAT_0001b870) == 0:
								memory.write_u16(host + 0xcc, C68kScript.u16(memory.read_u16(host + 0xcc) + 1))
							for mode_target in [[3, -0x3bcd3, 0x2b246a], [4, -0xf29a61, 0xb2584f]]:
								host = memory.read_u32(DAT_0001b5a0)
								if memory.read_s16(host + 0x90) != mode_target[0]:
									continue
								a7 = entry_a7 - 0x34
								var dist: int = approx_dist3_xyz(memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20), mode_target[1], 0, mode_target[2])
								a7 = entry_a7
								host = memory.read_u32(DAT_0001b5a0)
								if dist <= 0xce3f and memory.read_u16(host + 0xce) == 0:
									memory.write_u16(host + 0xce, 1)
						elif facility == 0x200:
							memory.write_u16(host + 0xd2, C68kScript.u16(memory.read_u16(host + 0xd2) + 1))
			memory.write_u32(ctl + 0x618, C68kScript.u32(memory.read_u32(DAT_0001b838) + delay))
			a7 = entry_a7 - 0x1c
			dispatch_entity_cleanup(obj)
			a7 = entry_a7
	if ((memory.read_u16(ctl + 0x61c) ^ memory.read_u16(ctl + 0x61e)) & 0x40) != 0:
		a7 = entry_a7 - 0x28
		attach_burning_trail(memory.read_u32(obj + 0x18), memory.read_u32(obj + 0x1c), memory.read_u32(obj + 0x20), ctl)
		a7 = entry_a7
	memory.write_u16(ctl + 0x61e, memory.read_u16(ctl + 0x61c))

## 0x12f52 (definition +0x12 collision of key 0xc, runtime 0x12f32): live only, the impact flag
## 0x400 is set; an object whose controller type word is 0x15..0x19 (a ship) is a direct hit
## (+0x616 = 1).
func ordnance_collision(self_obj: int, other_obj: int) -> void:
	assert(memory != null, "ordnance_collision requires original global memory")
	var ctl: int = memory.read_u32(self_obj + 8)
	if memory.read_u16(DAT_0001b870) != 0:
		return
	memory.write_u16(ctl + 0x61c, memory.read_u16(ctl + 0x61c) | 0x400)
	if memory.read_u32(other_obj + 8) == 0:
		return
	var type_word: int = memory.read_s16(memory.read_u32(memory.read_u32(other_obj + 8) + 4))
	if type_word > 0x14 and type_word <= 0x19:
		memory.write_u16(ctl + 0x616, 1)

## 0x1951a (definition +0xa destroy of the parachute record, runtime 0x194fa): forget the
## player's parachute (0x1b87c) when it is this controller.
func destroy_parachute_controller(ctl: int) -> void:
	assert(memory != null, "destroy_parachute_controller requires original global memory")
	if C68kScript.u32(ctl) == memory.read_u32(DAT_0001b87c):
		memory.write_u32(DAT_0001b87c, 0)

## 0x1952e: one parachute frame. Link a6 -0x38 and ten registers (body 0x64 below). age = low
## word of the frame counter - word +0x612. From age 16, live up to age 30: at 16 a shadow
## (spawn_object_shadow(x, 0, z, 3, object), 0x7c below); the 13 canopy vertices drift by their
## velocities asr 8 (+0x622 / +0x656 / +0x68a, x / y / z), which decay to 3/4 (x, y) and 2/3
## (z); drag +0x618 += word +0x61c, which decays to 15/16. Later (or replaying) a contact-tracked
## object (+5 bit 0) is untracked (drop_contact_records_for_object, 0x6c below). Falling (word
## +0x61e == 0): speed word +0x614 slowed by the drag over the air density
## (table_lerp_1b2c0(y), 0x6c below) with the carried remainder +0x616 (/ 10; the remainder of
## that divsl.l becomes the new +0x616), turned into a velocity through the
## attitude (matrix 0x7c, transform 0x8c below), gravity -0x5b, / 64 into +8 / +0xc / +0x10 (drift
## -13 / -7 from age 16); the attitude follows (isqrt 0x6c, attitude_from_velocity 0x88, sin 0x6c
## below; frame words a6 - 0x20 / - 0x22) as in ordnance_ballistic_step. Within 0x17f of the
## ground it lands (velocity 0, +0x61e = 1). Landed: the canopy collapses toward heading 0x588
## (fold 0x6c, cos 0x70, sin 0x74 below): each vertex below 0x17f << shift (word object +0x34)
## sinks 10 << shift and is pulled by 15 * (cos, sin) << shift / 4096 while within 0x15e <<
## shift (isqrt 0x6c below); when none is left below, dispatch_entity_cleanup (0x6c below).
func parachute_descend(ctl: int) -> void:
	assert(memory != null, "parachute_descend requires original global memory")
	assert(a7 != 0, "parachute_descend needs a7 (its frame holds the velocity and attitude)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x64
	var obj: int = memory.read_u32(ctl)
	var age: int = C68kScript.s16(memory.read_u16(DAT_0001b838 + 2) - memory.read_u16(ctl + 0x612))
	var drag: int = memory.read_s32(ctl + 0x618)
	if age > 0xf:
		if memory.read_u16(DAT_0001b870) == 0 and age <= 0x1e:
			if age == 0x10:
				a7 = body - 0x18
				spawn_object_shadow(memory.read_u32(obj + 0x18), 0, memory.read_u32(obj + 0x20), 3, obj)
				a7 = entry_a7
			var verts: int = memory.read_u32(obj + 0x44)
			for v in 13:
				var vert: int = verts + v * 12
				for axis in [[0x622, 0], [0x656, 4], [0x68a, 8]]:
					memory.write_u32(vert + axis[1], C68kScript.u32(C68kScript.asr32(memory.read_u32(ctl + axis[0] + v * 4), 8) + memory.read_u32(vert + axis[1])))
				for field in [0x622, 0x656]:
					var vel: int = C68kScript.s32(C68kScript.lsl32(memory.read_u32(ctl + field + v * 4), 1) + memory.read_u32(ctl + field + v * 4))
					if vel < 0:
						vel = C68kScript.s32(vel + 3)
					memory.write_u32(ctl + field + v * 4, C68kScript.u32(C68kScript.asr32(vel, 2)))
				memory.write_u32(ctl + 0x68a + v * 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(memory.read_u32(ctl + 0x68a + v * 4), 1)), 3)))
			memory.write_u32(ctl + 0x618, C68kScript.u32(memory.read_s16(ctl + 0x61c) + memory.read_u32(ctl + 0x618)))
			var decay: int = memory.read_s16(ctl + 0x61c) * 15
			if decay < 0:
				decay += 15
			memory.write_u16(ctl + 0x61c, C68kScript.u16(decay >> 4))
			drag = memory.read_s32(ctl + 0x618)
		elif (memory.read_u8(obj + 5) & 1) != 0:
			memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xfffeffff)
			a7 = body - 8
			drop_contact_records_for_object(obj)
			a7 = entry_a7
	if memory.read_u16(ctl + 0x61e) == 0:
		_parachute_fall(ctl, obj, a6, body, age, drag)
	else:
		_parachute_collapse(ctl, obj, a6, body)
	a7 = entry_a7

## parachute_descend's falling frame (0x1967e..0x19822).
func _parachute_fall(ctl: int, obj: int, a6: int, body: int, age: int, drag: int) -> void:
	var entry_a7: int = a7
	memory.write_u16(a6 - 0x20, memory.read_u16(ctl + 0x20))
	memory.write_u16(a6 - 0x22, memory.read_u16(ctl + 0x22))
	var bank: int = memory.read_s16(ctl + 0x24)
	var speed: int = memory.read_s16(ctl + 0x614)
	var quarter: int = speed >> 2
	a7 = body - 8
	var density: int = C68kScript.s16(table_lerp_1b2c0(memory.read_u32(obj + 0x1c)))
	a7 = entry_a7
	assert(density != 0, "parachute_descend: divs.l by zero traps")
	var slow: int = C68kScript.divs_trunc(C68kScript.s32(drag * quarter), density)
	slow = C68kScript.divs_trunc(C68kScript.lsl32(C68kScript.s32(slow * quarter), 1), 0xa0)
	var total: int = C68kScript.s32(slow + memory.read_s16(ctl + 0x616))
	slow = C68kScript.divs_trunc(total, 10)
	## divsl.l d7,d0:d1 (ext 0x1800): the remainder lands in D0, which is what +0x616 keeps.
	memory.write_u16(ctl + 0x616, C68kScript.u16(C68kScript.rems_trunc(total, 10)))
	memory.write_u16(a6 - 0x6, 0)
	memory.write_u16(a6 - 0xa, 0)
	memory.write_u16(a6 - 0x2, C68kScript.u16(speed - slow))
	a7 = body - 0x18
	build_attitude_matrix_3ang(memory.read_s16(a6 - 0x20), memory.read_s16(a6 - 0x22), bank, a6 - 0x1e)
	a7 = body - 0x28
	transform_vecs12_by_matrix3(1, a6 - 0xc, a6 - 0xc, a6 - 0x1e)
	a7 = entry_a7
	memory.write_u16(a6 - 0x6, C68kScript.u16(memory.read_u16(a6 - 0x6) + 0xffa5))
	var vx: int = memory.read_s16(a6 - 0xa)
	var vy: int = memory.read_s16(a6 - 0x6)
	var vz: int = memory.read_s16(a6 - 0x2)
	memory.write_u32(ctl + 8, C68kScript.u32(vx >> 6))
	memory.write_u32(ctl + 0xc, C68kScript.u32(vy >> 6))
	memory.write_u32(ctl + 0x10, C68kScript.u32(vz >> 6))
	if age > 0xf:
		memory.write_u32(ctl + 8, C68kScript.u32(memory.read_u32(ctl + 8) - 13))
		memory.write_u32(ctl + 0x10, C68kScript.u32(memory.read_u32(ctl + 0x10) - 7))
	var sq: int = C68kScript.s32(C68kScript.s32(vx * vx + vy * vy) + vz * vz)
	a7 = body - 8
	var length: int = C68kScript.s16(isqrt_floor(sq))
	a7 = body - 0x24
	attitude_from_velocity(vx, vy, vz, length, sq, a6 - 0x20, a6 - 0x22)
	a7 = entry_a7
	var turn: int = C68kScript.s16(memory.read_u16(a6 - 0x22) - memory.read_u16(ctl + 0x22))
	if turn > 0x2000:
		turn = C68kScript.s16(turn - 0x4000)
	elif turn < -0x2000:
		turn = C68kScript.s16(turn + 0x4000)
	memory.write_u16(ctl + 0x20, memory.read_u16(a6 - 0x20))
	memory.write_u16(ctl + 0x22, memory.read_u16(a6 - 0x22) & 0x3fff)
	a7 = body - 8
	var sine: int = C68kScript.s16(sin_fixed14(memory.read_s16(a6 - 0x20)))
	a7 = entry_a7
	memory.write_u16(ctl + 0x24, (C68kScript.asr32(sine * turn, 12) + bank) & 0x3fff)
	memory.write_u16(ctl + 0x614, C68kScript.u16(length))
	if C68kScript.s32(memory.read_u32(ctl + 0x2e) + 0x17f) >= C68kScript.s32(memory.read_u32(obj + 0x1c) + memory.read_u32(ctl + 0xc)):
		memory.write_u32(ctl + 0x10, 0)
		memory.write_u32(ctl + 0xc, 0)
		memory.write_u32(ctl + 8, 0)
		memory.write_u16(ctl + 0x61e, 1)

## parachute_descend's collapse on the ground (0x19826..0x1992c).
func _parachute_collapse(ctl: int, obj: int, _a6: int, body: int) -> void:
	var entry_a7: int = a7
	var shift: int = memory.read_s16(obj + 0x34)
	a7 = body - 8
	var angle: int = fold_angle_pm_0x2000(C68kScript.s32(0x588 - memory.read_s16(ctl + 0x22))) & 0x3fff
	a7 = body - 0xc
	var off_c: int = C68kScript.s16(C68kScript.asr32(C68kScript.lsl32(C68kScript.s16(cos_fixed14(angle)) * 15, shift), 12))
	a7 = body - 0x10
	var off_s: int = C68kScript.s16(C68kScript.asr32(C68kScript.lsl32(C68kScript.s16(sin_fixed14(angle)) * 15, shift), 12))
	a7 = entry_a7
	var verts: int = memory.read_u32(obj + 0x44)
	var reach: int = C68kScript.s32(C68kScript.lsl32(0x15e, shift))
	var any_low: bool = false
	for v in 13:
		var vert: int = verts + v * 12
		if C68kScript.s32(C68kScript.lsl32(0x17f, shift)) <= memory.read_s32(vert + 8):
			continue
		any_low = true
		var nx: int = C68kScript.s16(memory.read_u16(vert + 2) - off_c)
		var ny: int = C68kScript.s16(memory.read_u16(vert + 6) - off_s)
		memory.write_u32(vert + 8, C68kScript.u32(C68kScript.lsl32(10, shift) + memory.read_u32(vert + 8)))
		var dz: int = C68kScript.s16(0x15e - memory.read_u16(vert + 0xa))
		a7 = body - 8
		var length: int = C68kScript.s16(isqrt_floor(C68kScript.s32(C68kScript.s32(nx * nx + ny * ny) + dz * dz)))
		a7 = entry_a7
		if reach > length:
			memory.write_u32(vert, C68kScript.u32(nx))
			memory.write_u32(vert + 4, C68kScript.u32(ny))
	if not any_low:
		a7 = body - 8
		dispatch_entity_cleanup(obj)
		a7 = entry_a7

## 0x19938 (definition +2 tick of the parachute record, runtime 0x19918): as ordnance_tick
## without the flags - live it descends (0x14 below) and records the next position and attitude
## in the 75-entry pose ring; replaying (from the object's start frame +0x40) it follows it.
func parachute_tick(ctl: int) -> void:
	assert(memory != null, "parachute_tick requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	var pose: int = C68kScript.u32(ctl + 0x32 + memory.read_s16(ctl + 0x60e) * 0x14)
	memory.write_u16(ctl + 0x60e, C68kScript.u16(memory.read_u16(ctl + 0x60e) + 1))
	if memory.read_s16(ctl + 0x60e) == 0x4b:
		memory.write_u16(ctl + 0x60e, 0)
	var replay: int = memory.read_s16(DAT_0001b870)
	var frame: int = memory.read_s32(DAT_0001b838)
	if replay == 0:
		a7 = entry_a7 - 0x14
		parachute_descend(ctl)
		a7 = entry_a7
		for off in [0, 4, 8]:
			memory.write_u32(pose + off, C68kScript.u32(memory.read_u32(obj + 0x18 + off) + memory.read_u32(ctl + 8 + off)))
		memory.write_u16(pose + 0xc, memory.read_u16(ctl + 0x20))
		memory.write_u16(pose + 0xe, memory.read_u16(ctl + 0x22))
		memory.write_u16(pose + 0x10, memory.read_u16(ctl + 0x24))
		return
	if frame < memory.read_s32(obj + 0x40):
		return
	if replay == 1 or frame == memory.read_s32(obj + 0x40):
		memory.write_u32(ctl + 0x10, 0)
		memory.write_u32(ctl + 0xc, 0)
		memory.write_u32(ctl + 8, 0)
		for off in [0, 4, 8]:
			memory.write_u32(obj + 0x18 + off, memory.read_u32(pose + off))
	else:
		for off in [0, 4, 8]:
			memory.write_u32(ctl + 8 + off, C68kScript.u32(memory.read_u32(pose + off) - memory.read_u32(obj + 0x18 + off)))
	memory.write_u16(ctl + 0x20, memory.read_u16(pose + 0xc))
	memory.write_u16(ctl + 0x22, memory.read_u16(pose + 0xe))
	memory.write_u16(ctl + 0x24, memory.read_u16(pose + 0x10))

## 0x116e8 (definition +0xa destroy of the plume record, runtime 0x116c8): the owner (+0x3c)
## loses a reference (byte +3).
func destroy_plume_controller(ctl: int) -> void:
	assert(memory != null, "destroy_plume_controller requires original global memory")
	_release_owner_reference(memory.read_u32(ctl + 0x3c))

## 0x1713c (destroy of the ground fire record, runtime 0x1711c): owner +0x50 loses a reference.
func destroy_ground_fire_controller(ctl: int) -> void:
	assert(memory != null, "destroy_ground_fire_controller requires original global memory")
	_release_owner_reference(memory.read_u32(ctl + 0x50))

## 0x18942 (destroy of the shadow record, runtime 0x18922): owner +0x32 loses a reference.
func destroy_shadow_controller(ctl: int) -> void:
	assert(memory != null, "destroy_shadow_controller requires original global memory")
	_release_owner_reference(memory.read_u32(ctl + 0x32))

## subq.b #1 on the owner's reference byte +3, when there is an owner.
func _release_owner_reference(owner: int) -> void:
	if owner != 0:
		memory.write_u8(owner + 3, C68kScript.u8(memory.read_u8(owner + 3) - 1))

## 0x12738 (effect_pre_render_table kind 2, runtime 0x12718): the effect faces the camera -
## heading +0x22 = -neg_camera_heading & 0x3fff, pitch +0x20 = -neg_camera_pitch & 0x3fff.
## Returns 0.
func face_object_to_camera(ctl: int) -> int:
	assert(memory != null, "face_object_to_camera requires original global memory")
	memory.write_u16(ctl + 0x22, (-memory.read_u16(DAT_0001d80e)) & 0x3fff)
	memory.write_u16(ctl + 0x20, (-memory.read_u16(DAT_0001d810)) & 0x3fff)
	return 0

## 0x127aa (definition +0xe pre-render of the effect record, runtime 0x1278a): jsr
## effect_pre_render_table[byte +0x32](ctl), entered 8 below (push, jsr).
func effect_pre_render_hook(ctl: int) -> void:
	assert(memory != null, "effect_pre_render_hook requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	_jsr(memory.read_u32(DAT_0001b42c + memory.read_u8(ctl + 0x32) * 4), [ctl])
	a7 = entry_a7

## 0x19b30 (definition +2 tick of the cloud record, runtime 0x19b10): the velocity moves the
## object to the camera + its offset (+0x32 x, +0x3a z); vertically it follows the camera only
## while the camera is above +0x36 - 10000, else stays.
func follow_camera_offset(ctl: int) -> void:
	assert(memory != null, "follow_camera_offset requires original global memory")
	var obj: int = memory.read_u32(ctl)
	memory.write_u32(ctl + 8, C68kScript.u32(memory.read_u32(ctl + 0x32) + memory.read_u32(DAT_0001d838) - memory.read_u32(obj + 0x18)))
	if C68kScript.s32(memory.read_u32(ctl + 0x36) - 10000) < memory.read_s32(DAT_0001d834):
		memory.write_u32(ctl + 0xc, C68kScript.u32(memory.read_u32(DAT_0001d834) - memory.read_u32(obj + 0x1c)))
	else:
		memory.write_u32(ctl + 0xc, 0)
	memory.write_u32(ctl + 0x10, C68kScript.u32(memory.read_u32(ctl + 0x3a) + memory.read_u32(DAT_0001d830) - memory.read_u32(obj + 0x20)))

## 0x12f92 (definition +6 create of record type 0x10, runtime 0x12f72): 0x32 bytes; object long
## +4 |= 0x112100; the controller is published as type10_controller (0x20b40), the target the
## landing glide mirrors.
func create_singleton_type10_controller(obj: int, def_key: int) -> int:
	var ctl: int = heap_alloc_cleared(0x32)
	memory.write_u32(ctl, obj)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x112100)
	memory.write_u32(ctl + 4, _definition(def_key))
	memory.write_u32(DAT_00020b40, ctl)
	return ctl

## 0x168ae (collision pair handler, runtime 0x1688e): one rng in 16 (0xc below) the other object
## takes an ordnance hit (ordnance_collision(other, self), 0x14 below). Returns the rng with its
## low word masked to & 0xf (ordnance_collision leaves D0 alone).
func impact_one_time_in_16(self_obj: int, other_obj: int) -> int:
	assert(memory != null, "impact_one_time_in_16 requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	var rnd: int = C68kScript.u32(overlay_rng_next()) & 0xffff000f
	a7 = entry_a7
	if (rnd & 0xf) == 0:
		a7 = entry_a7 - 0x10
		ordnance_collision(other_obj, self_obj)
		a7 = entry_a7
	return rnd

## 0xdf98: every one of the 75 pose ring entries (0x14 bytes) gets the three attitude words at
## +0xc / +0xe / +0x10 (low words of the long arguments).
func fill_pose_history_angles(ring: int, angle_0c: int, angle_0e: int, angle_10: int) -> void:
	assert(memory != null, "fill_pose_history_angles requires original global memory")
	for i in 0x4b:
		memory.write_u16(ring + i * 0x14 + 0xc, C68kScript.u16(angle_0c))
		memory.write_u16(ring + i * 0x14 + 0xe, C68kScript.u16(angle_0e))
		memory.write_u16(ring + i * 0x14 + 0x10, C68kScript.u16(angle_10))

## 0xdfd2: every pose ring entry gets the flag word at +0x12.
func fill_pose_history_flags(ring: int, flags: int) -> void:
	assert(memory != null, "fill_pose_history_flags requires original global memory")
	for i in 0x4b:
		memory.write_u16(ring + i * 0x14 + 0x12, C68kScript.u16(flags))

## Template registration (definition record +6 hooks). The single-template records store the
## template and redirect +6 to their factory; the slot records fill the first empty long of their
## table (unsigned word index, bls) and redirect once the index passes a threshold. All return 0.
func _register_template(slot: int, tmpl: int, def_key: int, factory: int) -> int:
	memory.write_u32(slot, C68kScript.u32(tmpl))
	memory.write_u32(_definition(def_key) + 6, factory)
	return 0

## First empty long of table[0..count) gets tmpl; returns the index (count when full).
func _store_in_first_free_slot(table: int, count: int, tmpl: int) -> int:
	var i: int = 0
	while i < count:
		if memory.read_u32(table + i * 4) == 0:
			memory.write_u32(table + i * 4, C68kScript.u32(tmpl))
			break
		i += 1
	return i

## 0x115da (runtime 0x115ba): smoke_template; factory 0x11590.
func register_smoke_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_smoke_template requires original global memory")
	return _register_template(DAT_000260e8, tmpl, def_key, 0x11590)

## 0x11b48 (runtime 0x11b28): effect_templates (4 slots); from the fourth (index > 2) +6 becomes
## 0x11ade.
func register_effect_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_effect_template requires original global memory")
	if _store_in_first_free_slot(DAT_0002626e, 4, tmpl) > 2:
		memory.write_u32(_definition(def_key) + 6, 0x11ade)
	return 0

## 0x1281e (runtime 0x127fe): ordnance_template; factory 0x127a6.
func register_ordnance_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_ordnance_template requires original global memory")
	return _register_template(DAT_00026280, tmpl, def_key, 0x127a6)

## 0x15bd4 (runtime 0x15bb4): bullet_template; factory 0x15b72.
func register_bullet_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_bullet_template requires original global memory")
	return _register_template(DAT_0002664a, tmpl, def_key, 0x15b72)

## 0x16a78 (runtime 0x16a58): trail_templates (2 slots); any index but 0 redirects +6 to
## 0x16a1a.
func register_trail_templates(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_trail_templates requires original global memory")
	if _store_in_first_free_slot(DAT_00026650, 2, tmpl) != 0:
		memory.write_u32(_definition(def_key) + 6, 0x16a1a)
	return 0

## 0x17098 (runtime 0x17078): ground_fire_template; factory 0x1704a.
func register_ground_fire_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_ground_fire_template requires original global memory")
	return _register_template(DAT_00026658, tmpl, def_key, 0x1704a)

## 0x173dc (runtime 0x173bc): debris_template; factory 0x17382.
func register_debris_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_debris_template requires original global memory")
	return _register_template(DAT_0002665c, tmpl, def_key, 0x17382)

## 0x1759e (runtime 0x1757e): ground_mark_template; factory 0x17546.
func register_ground_mark_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_ground_mark_template requires original global memory")
	return _register_template(DAT_00026660, tmpl, def_key, 0x17546)

## 0x188f4 (runtime 0x188d4): four slots from 0x2676c (shadow_templates[1..4], so kind 0 stays
## empty); index > 2 redirects +6 to 0x1889a.
func register_shadow_templates(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_shadow_templates requires original global memory")
	if _store_in_first_free_slot(DAT_00026768 + 4, 4, tmpl) > 2:
		memory.write_u32(_definition(def_key) + 6, 0x1889a)
	return 0

## 0x1910e (runtime 0x190ee): turret_template; factory 0x190a0.
func register_turret_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_turret_template requires original global memory")
	return _register_template(DAT_0002677c, tmpl, def_key, 0x190a0)

## 0x1940e (runtime 0x193ee): parachute_template; factory 0x19396.
func register_parachute_template(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_parachute_template requires original global memory")
	return _register_template(DAT_00026780, tmpl, def_key, 0x19396)

## 0x19a54 (runtime 0x19a34): cloud_templates (5 slots); index > 3 redirects +6 to 0x199fa.
func register_cloud_templates(tmpl: int, def_key: int) -> int:
	assert(memory != null, "register_cloud_templates requires original global memory")
	if _store_in_first_free_slot(DAT_00026784, 5, tmpl) > 3:
		memory.write_u32(_definition(def_key) + 6, 0x199fa)
	return 0

## 0x11b96: replay the effect log. replay_state is held at -1 (spawn_effect then neither logs nor
## refuses) and restored; from the log index (word 0x260ec) every entry (0x260ee + 24 i) whose
## frame (+0x14) is not after the current frame is consumed, and one of exactly this frame is
## spawned again: spawn_effect(kind byte, sext word +4, sext word +6, extb +1, extb +2, x, y, z)
## (0x28 below); index + 1 & 0xf.
func replay_logged_effects() -> void:
	assert(memory != null, "replay_logged_effects requires original global memory")
	var entry_a7: int = a7
	var saved: int = memory.read_u16(DAT_0001b870)
	memory.write_u16(DAT_0001b870, 0xffff)
	while true:
		var entry: int = DAT_000260ee + memory.read_s16(DAT_000260ec) * 0x18
		if memory.read_s32(entry + 0x14) > memory.read_s32(DAT_0001b838):
			break
		if memory.read_u32(entry + 0x14) == memory.read_u32(DAT_0001b838):
			a7 = entry_a7 - 0x28
			spawn_effect(memory.read_u8(entry), memory.read_s16(entry + 4), memory.read_s16(entry + 6), memory.read_s8(entry + 1), memory.read_s8(entry + 2), memory.read_u32(entry + 8), memory.read_u32(entry + 0xc), memory.read_u32(entry + 0x10))
			a7 = entry_a7
		memory.write_u16(DAT_000260ec, (memory.read_u16(DAT_000260ec) + 1) & 0xf)
	memory.write_u16(DAT_0001b870, saved)

## 0x11c2c: the entry at the log index gets frame 0x7fffffff (the end mark replay stops at);
## index + 1 & 0xf.
func mark_effect_log_end() -> void:
	assert(memory != null, "mark_effect_log_end requires original global memory")
	memory.write_u32(DAT_000260ee + memory.read_s16(DAT_000260ec) * 0x18 + 0x14, 0x7fffffff)
	memory.write_u16(DAT_000260ec, (memory.read_u16(DAT_000260ec) + 1) & 0xf)

## 0x9550: with a sound table (host +0x25e) each channel 0 / 1 still playing (host +0x2b6) is
## stopped (host +0x2be) (8 below each); engine_sound_choice = -1.
func stop_all_sound_channels() -> void:
	assert(memory != null, "stop_all_sound_channels requires original global memory")
	var entry_a7: int = a7
	if memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x25e) != 0:
		for channel in [0, 1]:
			a7 = entry_a7 - 8
			var playing: int = C68kScript.u32(_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2b6), [channel]))
			if playing != 0:
				_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2be), [channel])
			a7 = entry_a7
	memory.write_u32(DAT_00024d14, 0xffffffff)

## 0x95ac: play sound id on channel 1 unless a sound of the same or higher priority (lower id) is
## playing (channel1_sound). Ids up to 99 need their record (*(host +0x25e))[id]; id 100 plays the
## record at table +0x1c from offset 0x48c0 (a missing one only claims the channel). Ids 1..4, 6,
## 8, 9 and 12 play once; the others (<= 0, 5, 7, 10, 11, 13..99, > 100) with the record's loop
## points (+0xc / +0x10). host +0x2aa(1, record + 0x16, offset, size +4 - 0x172, loop a, loop b)
## (0x24 below); channel1_sound = id. Ids above 100 never load the record: A1 is the caller's
## (a1_in).
func play_game_sound(sound_id: int, a1_in: int = 0) -> void:
	assert(memory != null, "play_game_sound requires original global memory")
	var entry_a7: int = a7
	sound_id = C68kScript.s32(sound_id)
	var current: int = memory.read_s32(DAT_00024d10)
	if current != 0 and sound_id >= current:
		return
	var host: int = memory.read_u32(DAT_0001b5a0)
	var rec: int = a1_in
	if sound_id <= 99:
		rec = memory.read_u32(C68kScript.u32(memory.read_u32(host + 0x25e) + sound_id * 4))
		if rec == 0:
			return
	var args: Array
	if sound_id == 100:
		rec = memory.read_u32(memory.read_u32(host + 0x25e) + 0x1c)
		if rec == 0:
			memory.write_u32(DAT_00024d10, C68kScript.u32(sound_id))
			return
		args = [1, C68kScript.u32(rec + 0x16), 0x48c0, C68kScript.u32(memory.read_u32(rec + 4) - 0x172), 0, 0]
	elif (sound_id >= 1 and sound_id <= 4) or sound_id == 6 or sound_id == 8 or sound_id == 9 or sound_id == 12:
		args = [1, C68kScript.u32(rec + 0x16), 0, C68kScript.u32(memory.read_u32(rec + 4) - 0x172), 0, 0]
	else:
		args = [1, C68kScript.u32(rec + 0x16), 0, C68kScript.u32(memory.read_u32(rec + 4) - 0x172), memory.read_u32(rec + 0xc), memory.read_u32(rec + 0x10)]
	a7 = entry_a7 - 0x24
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2aa), args)
	a7 = entry_a7
	memory.write_u32(DAT_00024d10, C68kScript.u32(sound_id))

## 0x96ae: when sound id is the one on channel 1: channel1_sound = 0 and host +0x2ba(1) (8 below).
func stop_game_sound(sound_id: int) -> void:
	assert(memory != null, "stop_game_sound requires original global memory")
	var entry_a7: int = a7
	if memory.read_u32(DAT_00024d10) == C68kScript.u32(sound_id):
		memory.write_u32(DAT_00024d10, 0)
		a7 = entry_a7 - 8
		_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2ba), [1])
		a7 = entry_a7

## Truncating ((rng & 0xfff) * sext size) / 8192 (muls.l, +0x1fff when negative, asr 13).
func _plume_jitter(size: int) -> int:
	var v: int = C68kScript.s32((overlay_rng_next() & 0xfff) * size)
	if v < 0:
		v = C68kScript.s32(v + 0x1fff)
	return C68kScript.asr32(v, 13)

## 0x11796: a free smoke plume (no owner). Facing the camera (word +0x32) it takes heading
## -neg_camera_heading. A pending width (word +0x36) lays out the x of vertices 0..2 and 4..6 at
## -1/2, -3/8, -1/4, 1/4, 3/8, 1/2 of it (toward zero) and is cleared. Once per frame (long +0x38
## != frame) the y of vertices 1, 3, 5, 7 become (rng & 0xfff) * height (+0x34) / 8192 (vertex
## 3 + half the height) (rng 0x18 below), scaled by age / 45 while the object is younger than 45
## frames (abs_int(frame - object +0x40), 0x1c below; word compare). Returns 0.
func shape_free_plume(ctl: int) -> int:
	assert(memory != null, "shape_free_plume requires original global memory")
	var entry_a7: int = a7
	var obj: int = memory.read_u32(ctl)
	var verts: int = memory.read_u32(obj + 0x44)
	if memory.read_u16(ctl + 0x32) != 0:
		memory.write_u16(ctl + 0x22, (-memory.read_u16(DAT_0001d80e)) & 0x3fff)
	if memory.read_u16(ctl + 0x36) != 0:
		var width: int = memory.read_s16(ctl + 0x36)
		for spec in [[0, -width, 1, 1], [0xc, -3 * width, 7, 3], [0x18, -width, 3, 2], [0x30, width, 3, 2], [0x3c, 3 * width, 7, 3], [0x48, width, 1, 1]]:
			var v: int = spec[1]
			if v < 0:
				v += spec[2]
			memory.write_u32(verts + spec[0], C68kScript.u32(v >> spec[3]))
		memory.write_u16(ctl + 0x36, 0)
	if memory.read_u32(ctl + 0x38) == memory.read_u32(DAT_0001b838):
		return 0
	var height: int = memory.read_s16(ctl + 0x34)
	a7 = entry_a7 - 0x18
	memory.write_u32(verts + 0x10, C68kScript.u32(_plume_jitter(height)))
	var rnd: int = overlay_rng_next()
	var half: int = memory.read_s16(ctl + 0x34)
	if half < 0:
		half += 1
	half = C68kScript.s16(half) >> 1
	var v28: int = C68kScript.s32((rnd & 0xfff) * memory.read_s16(ctl + 0x34))
	if v28 < 0:
		v28 = C68kScript.s32(v28 + 0x1fff)
	memory.write_u32(verts + 0x28, C68kScript.u32(C68kScript.asr32(v28, 13) + half))
	memory.write_u32(verts + 0x40, C68kScript.u32(_plume_jitter(memory.read_s16(ctl + 0x34))))
	memory.write_u32(verts + 0x58, C68kScript.u32(_plume_jitter(memory.read_s16(ctl + 0x34))))
	a7 = entry_a7
	var age: int = C68kScript.s16(abs_int(C68kScript.s32(memory.read_u32(DAT_0001b838) - memory.read_u32(obj + 0x40))))
	if age <= 0x2c:
		for off in [0x10, 0x28, 0x40, 0x58]:
			memory.write_u32(verts + off, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(age * memory.read_s32(verts + off)), 0x2d)))
	return 0

## A point of the trailing plume's ring (ctl +0x40, 8 x 12 bytes) copied into a vertex with a y
## offset.
func _trail_point_to_vertex(ctl: int, index: int, vert: int, dy: int) -> void:
	var point: int = C68kScript.u32(ctl + 0x40 + index * 12)
	memory.write_u32(vert, memory.read_u32(point))
	memory.write_u32(vert + 4, C68kScript.u32(memory.read_u32(point + 4) + dy))
	memory.write_u32(vert + 8, memory.read_u32(point + 8))

## 0x11940: a plume trailing its owner along the 8-point ring (index word +0xa0, newest). The
## newest point gives vertices 0 / 6 (+-0x24 in y), the point two back vertices 2 / 4 (+-0x12),
## random points (rng & 3) behind those vertices 1 / 5 (+-0x1b) and 7 (from the newest) / 3 (from
## four back) (rng 0x20 below each). Returns 0.
func shape_trailing_plume(ctl: int) -> int:
	assert(memory != null, "shape_trailing_plume requires original global memory")
	var entry_a7: int = a7
	var verts: int = memory.read_u32(memory.read_u32(ctl) + 0x44)
	var ring: int = memory.read_s16(ctl + 0xa0)
	_trail_point_to_vertex(ctl, ring, verts, 0x24)
	_trail_point_to_vertex(ctl, ring, verts + 0x48, -0x24)
	var back2: int = (ring + 2) & 7
	_trail_point_to_vertex(ctl, back2, verts + 0x18, 0x12)
	_trail_point_to_vertex(ctl, back2, verts + 0x30, -0x12)
	a7 = entry_a7 - 0x20
	_trail_point_to_vertex(ctl, (ring + (overlay_rng_next() & 3) + 2) & 7, verts + 0xc, 0x1b)
	_trail_point_to_vertex(ctl, (ring + (overlay_rng_next() & 3) + 2) & 7, verts + 0x3c, -0x1b)
	_trail_point_to_vertex(ctl, (ring + (overlay_rng_next() & 3)) & 7, verts + 0x54, 0)
	_trail_point_to_vertex(ctl, (ring + (overlay_rng_next() & 3) + 4) & 7, verts + 0x24, 0)
	a7 = entry_a7
	return 0

## 0x11a90 (definition +0xe pre-render of the plume record, runtime 0x11a70): a plume with an
## owner (+0x3c) trails it, else it is shaped free (8 below).
func plume_pre_render(ctl: int) -> void:
	assert(memory != null, "plume_pre_render requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	if memory.read_u32(ctl + 0x3c) != 0:
		shape_trailing_plume(ctl)
	else:
		shape_free_plume(ctl)
	a7 = entry_a7

## 0x18a34 (definition +0xe pre-render of the shadow record, runtime 0x18a14). A dead owner (+7
## bit 1) -> 4. For an aircraft owner (type word <= 4) the first face's vertices are stretched along
## x by |cos(owner bank +0x24)| (cos 0x40, abs 0x44 below; link a6 -0xc and ten registers): each
## whose template vertex x (host +0x8c + the parent's scene entry +0x2e + 24 * byte object +1, +0x22
## + 12 i) exceeds the half size 0x32 << shift (word object +0x34, sext low word) in magnitude
## takes that x * cos / 4096 as a word, clamped to at least the half size with its sign (abs 0x40
## below). Returns 0.
func shadow_pre_render(ctl: int) -> int:
	assert(memory != null, "shadow_pre_render requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x38
	var obj: int = memory.read_u32(ctl)
	var owner: int = memory.read_u32(ctl + 0x32)
	if (memory.read_u8(owner + 7) & 2) != 0:
		return 4
	if memory.read_s16(memory.read_u32(memory.read_u32(owner + 8) + 4)) > 4:
		return 0
	var face: int = memory.read_u32(obj + 0x48)
	var entry: int = C68kScript.u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x2e + memory.read_u8(obj + 1) * 0x18)
	var template: int = C68kScript.u32(memory.read_u32(entry) + memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c) + 0x22)
	var verts: int = memory.read_u32(obj + 0x44)
	var half: int = C68kScript.s16(C68kScript.lsl32(0x32, memory.read_s16(obj + 0x34)))
	a7 = body - 8
	var stretch: int = C68kScript.s16(abs_int(C68kScript.s16(cos_fixed14(memory.read_s16(memory.read_u32(owner + 8) + 0x24)))))
	a7 = entry_a7
	var idx: int = memory.read_u32(face + 0x18)
	var left: int = memory.read_u16(face + 0x14)
	while left != 0:
		left -= 1
		var vi: int = memory.read_s16(idx)
		var tx: int = memory.read_s32(template + vi * 12)
		if abs_int(tx) > half:
			var x: int = C68kScript.s16(C68kScript.asr32(C68kScript.s32(stretch * tx), 12))
			var vert: int = C68kScript.u32(verts + vi * 12)
			if abs_int(x) > half:
				memory.write_u32(vert, C68kScript.u32(x))
			else:
				memory.write_u32(vert, C68kScript.u32(-half if x < 0 else half))
		idx += 2
	return 0

## 0x19394 (pre-render of the turret record, runtime 0x19374): an aimed turret (+0x36) not firing
## (word +0x46 == 0) shows its aim heading (+0x4e & 0x3fff in +0x22). Returns 0.
func turret_pre_render(ctl: int) -> int:
	assert(memory != null, "turret_pre_render requires original global memory")
	if memory.read_u32(ctl + 0x36) != 0 and memory.read_u16(ctl + 0x46) == 0:
		memory.write_u16(ctl + 0x22, memory.read_u16(ctl + 0x4e) & 0x3fff)
	return 0

## 0x15e62 (pre-render of the bullet record, runtime 0x15e42): with fewer than 30 dot objects
## (word 0x265d0) the bullet is listed (0x265d2); its phase word +0x3a, below 8, gains 8 - at phase
## 2 its two vertices are first turned by its matrix (+0x40) into int3
## (transform_vecs12_to_int3_by_matrix3, 0x18 below). Returns 4 (not drawn as a shape).
func bullet_pre_render(ctl: int) -> int:
	assert(memory != null, "bullet_pre_render requires original global memory")
	var entry_a7: int = a7
	if memory.read_s16(DAT_000265d0) > 0x1d:
		return 4
	if memory.read_s16(ctl + 0x3a) <= 7:
		if memory.read_s16(ctl + 0x3a) == 2:
			var verts: int = memory.read_u32(memory.read_u32(ctl) + 0x44)
			a7 = entry_a7 - 0x18
			transform_vecs12_to_int3_by_matrix3(2, verts, verts, ctl + 0x40)
			a7 = entry_a7
		memory.write_u16(ctl + 0x3a, C68kScript.u16(memory.read_u16(ctl + 0x3a) + 8))
	memory.write_u32(C68kScript.u32(DAT_000265d2 + memory.read_s16(DAT_000265d0) * 4), memory.read_u32(ctl))
	memory.write_u16(DAT_000265d0, C68kScript.u16(memory.read_u16(DAT_000265d0) + 1))
	return 4

## 0x15ebe: erase last frame's dots on an 8-bit screen. For each dot record from the last
## (count word 0x1da8c, dbra) the pixels still showing its colour (+8) get their saved bytes back
## (+9 top-left, +0xa top-right when size +6 > 2, +0xb bottom-left when > 1, +0xc bottom-right
## when > 3; rows host +0x10 apart). The count is cleared.
func erase_dots_depth8() -> void:
	assert(memory != null, "erase_dots_depth8 requires original global memory")
	var row: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x10)
	var i: int = memory.read_u16(DAT_0001da8c)
	while i != 0:
		i -= 1
		var rec: int = DAT_00026288 + C68kScript.s16(i) * 0xe
		var pix: int = memory.read_u32(rec)
		var colour: int = memory.read_u8(rec + 8)
		var size: int = memory.read_s16(rec + 6)
		if memory.read_u8(pix) == colour:
			memory.write_u8(pix, memory.read_u8(rec + 9))
		if size > 2 and memory.read_u8(pix + 1) == colour:
			memory.write_u8(pix + 1, memory.read_u8(rec + 0xa))
		pix = C68kScript.u32(pix + row)
		if size > 1 and memory.read_u8(pix) == colour:
			memory.write_u8(pix, memory.read_u8(rec + 0xb))
		if size > 3 and memory.read_u8(pix + 1) == colour:
			memory.write_u8(pix + 1, memory.read_u8(rec + 0xc))
	memory.write_u16(DAT_0001da8c, 0)

## The dot pixel: screen base host +6 + word(sy + view_half_rows) * row bytes (muls.w) + offset.
func _dot_row_base(sy: int) -> int:
	var host: int = memory.read_u32(DAT_0001b5a0)
	return C68kScript.u32(memory.read_u32(host + 6) + C68kScript.s16(sy + memory.read_s16(DAT_00020b2c)) * memory.read_s16(host + 0x10))

## 0x15f3e: plot a dot of size 1..4 on an 8-bit screen at (view_half_width + sx, view_half_rows +
## sy): the pixel address goes to rec +0, each covered byte is saved (+9..+0xc as in
## erase_dots_depth8) and set to the low byte of bw_pattern_first.
func plot_dot_depth8(rec: int, sx: int, sy: int, size: int) -> void:
	assert(memory != null, "plot_dot_depth8 requires original global memory")
	size = C68kScript.s16(size)
	var row: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x10)
	var colour: int = memory.read_u8(DAT_0001da88 + 1)
	var pix: int = C68kScript.u32(_dot_row_base(sy) + C68kScript.s32(sx) + memory.read_s16(DAT_00020b2a))
	memory.write_u32(rec, pix)
	memory.write_u8(rec + 9, memory.read_u8(pix))
	memory.write_u8(pix, colour)
	if size > 2:
		memory.write_u8(rec + 0xa, memory.read_u8(pix + 1))
		memory.write_u8(pix + 1, colour)
	pix = C68kScript.u32(pix + row)
	if size > 1:
		memory.write_u8(rec + 0xb, memory.read_u8(pix))
		memory.write_u8(pix, colour)
	if size > 3:
		memory.write_u8(rec + 0xc, memory.read_u8(pix + 1))
		memory.write_u8(pix + 1, colour)

## Put back one 4-bit pixel: when the screen nibble (keep_mask's complement) still holds the dot
## colour, the byte becomes saved with the kept nibble of the screen ((pix ^ saved) & keep ^ saved).
func _erase_nibble(pix: int, colour: int, saved: int, test_mask: int) -> void:
	if ((memory.read_u8(pix) ^ colour) & test_mask) == 0:
		memory.write_u8(pix, ((memory.read_u8(pix) ^ saved) & (0xff ^ test_mask)) ^ saved)

## 0x15fb8: erase last frame's dots on a 4-bit screen (two pixels per byte). Records whose phase
## word +4 is 0 start on a high nibble: top row high then (size > 2) low nibble of the same byte
## (both restored from +9), bottom row (size > 1) high and (size > 3) low nibble (both from
## +0xb). Phase 1 starts on a low nibble: top low (+9), next byte high (size > 2, +0xa), bottom
## low (size > 1, +0xb) and next byte high (size > 3, +0xc). The count is cleared.
func erase_dots_depth4() -> void:
	assert(memory != null, "erase_dots_depth4 requires original global memory")
	var row: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x10)
	var i: int = memory.read_u16(DAT_0001da8c)
	while i != 0:
		i -= 1
		var rec: int = DAT_00026288 + C68kScript.s16(i) * 0xe
		var pix: int = memory.read_u32(rec)
		var colour: int = memory.read_u8(rec + 8)
		var size: int = memory.read_s16(rec + 6)
		if memory.read_u16(rec + 4) == 0:
			_erase_nibble(pix, colour, memory.read_u8(rec + 9), 0xf0)
			if size > 2:
				_erase_nibble(pix, colour, memory.read_u8(rec + 9), 0x0f)
			pix = C68kScript.u32(pix + row)
			if size > 1:
				_erase_nibble(pix, colour, memory.read_u8(rec + 0xb), 0xf0)
			if size > 3:
				_erase_nibble(pix, colour, memory.read_u8(rec + 0xb), 0x0f)
		else:
			_erase_nibble(pix, colour, memory.read_u8(rec + 9), 0x0f)
			if size > 2:
				_erase_nibble(pix + 1, colour, memory.read_u8(rec + 0xa), 0xf0)
			pix = C68kScript.u32(pix + row)
			if size > 1:
				_erase_nibble(pix, colour, memory.read_u8(rec + 0xb), 0x0f)
			if size > 3:
				_erase_nibble(pix + 1, colour, memory.read_u8(rec + 0xc), 0xf0)
	memory.write_u16(DAT_0001da8c, 0)

## Set one nibble of a 4-bit pixel byte to the colour's: ((pix ^ colour) & keep) ^ colour.
func _plot_nibble(pix: int, colour: int, keep: int) -> void:
	memory.write_u8(pix, ((memory.read_u8(pix) ^ colour) & keep) ^ colour)

## 0x16128: plot a dot on a 4-bit screen. px = view_half_width + sx (word); the byte is
## row base + px / 2 (toward zero) and the phase px - (px rounded toward zero & ~1) goes to rec +4,
## the address to rec +0. Phase 0: top byte saved (+9) and set whole (size > 2) or its high
## nibble; bottom byte saved (+0xb) always, set whole (size > 3) or high nibble (size > 1). Other
## phases: top low nibble (+9), next byte high nibble (size > 2, +0xa), bottom low nibble (size >
## 1, +0xb), next byte high nibble (size > 3, +0xc).
func plot_dot_depth4(rec: int, sx: int, sy: int, size: int) -> void:
	assert(memory != null, "plot_dot_depth4 requires original global memory")
	size = C68kScript.s16(size)
	var row: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x10)
	var colour: int = memory.read_u8(DAT_0001da88 + 1)
	var px: int = C68kScript.s16(sx + memory.read_s16(DAT_00020b2a))
	var rounded: int = C68kScript.s16(px + 1) if px < 0 else px
	var pix: int = C68kScript.u32(_dot_row_base(sy) + (rounded >> 1))
	memory.write_u16(rec + 4, C68kScript.u16(px - C68kScript.s16(rounded & 0xfffe)))
	memory.write_u32(rec, pix)
	if memory.read_u16(rec + 4) == 0:
		memory.write_u8(rec + 9, memory.read_u8(pix))
		if size > 2:
			memory.write_u8(pix, colour)
		else:
			_plot_nibble(pix, colour, 0x0f)
		pix = C68kScript.u32(pix + row)
		memory.write_u8(rec + 0xb, memory.read_u8(pix))
		if size > 3:
			memory.write_u8(pix, colour)
		elif size > 1:
			_plot_nibble(pix, colour, 0x0f)
	else:
		memory.write_u8(rec + 9, memory.read_u8(pix))
		_plot_nibble(pix, colour, 0xf0)
		if size > 2:
			memory.write_u8(rec + 0xa, memory.read_u8(pix + 1))
			_plot_nibble(pix + 1, colour, 0x0f)
		pix = C68kScript.u32(pix + row)
		if size > 1:
			memory.write_u8(rec + 0xb, memory.read_u8(pix))
			_plot_nibble(pix, colour, 0xf0)
		if size > 3:
			memory.write_u8(rec + 0xc, memory.read_u8(pix + 1))
			_plot_nibble(pix + 1, colour, 0x0f)

## 0x16230: on a 1-bit screen a dot is a 4-point polygon: corner i = (sx, sy) + dot_corner_dx /
## _dy[16 i + 4 (size - 1)], built in the frame (a6 - 0x20, 8 bytes per point; link a6 -0x20 and
## seven registers, body 0x40 below) and filled by host +0x7c(4, pattern word, draw order
## (post-incremented word 0x1c1be), polygon) (0x14 below).
func plot_dot_bw(_rec: int, sx: int, sy: int, size: int) -> void:
	assert(memory != null, "plot_dot_bw requires original global memory")
	assert(a7 != 0, "plot_dot_bw needs a7 (its frame holds the polygon)")
	var entry_a7: int = a7
	var poly: int = entry_a7 - 4 - 0x20
	var size_off: int = C68kScript.s16(size - 1) * 4
	for corner in 4:
		memory.write_u32(poly + corner * 8, C68kScript.u32(memory.read_u32(DAT_0001b48c + corner * 0x10 + size_off) + sx))
		memory.write_u32(poly + corner * 8 + 4, C68kScript.u32(memory.read_u32(DAT_0001b4cc + corner * 0x10 + size_off) + sy))
	var order: int = memory.read_s16(DAT_0001c1be)
	memory.write_u16(DAT_0001c1be, C68kScript.u16(order + 1))
	a7 = entry_a7 - 0x54
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x7c), [4, C68kScript.u32(memory.read_s16(DAT_0001da88)), C68kScript.u32(order), C68kScript.u32(poly)])
	a7 = entry_a7

## 0x1c04: copy the object's live vertices (+0x44) to its second buffer (+0x4c), 12 bytes each, for
## word +0x36 + word +0x3a vertices (none when the sum is not positive). Both pointers are read
## again for every long, as the bytes do.
func copy_object_vertex_buffer(obj: int) -> void:
	assert(memory != null, "copy_object_vertex_buffer requires original global memory")
	var count: int = memory.read_s16(obj + 0x36) + memory.read_s16(obj + 0x3a)
	if count <= 0:
		return
	var off: int = 0
	while true:
		for k in [0, 4, 8]:
			memory.write_u32(memory.read_u32(obj + 0x4c) + off + k, memory.read_u32(memory.read_u32(obj + 0x44) + off + k))
		off += 0xc
		if not (count * 12 > off):
			break

## 0x52dc: release an object leaving the near range. A shape (kind 2): back to its template pose
## when byte +6 bit 4 (0x18 below); its vertex buffers (+0x4c then +0x44; 0x18 / 0x1c below) are
## freed and +0x44 cleared, then every face's index list (+0x48 + 0x18 + 32 i, word +0x3a faces)
## and the face table; its controller's object link (*(+8)) is cleared; an object whose bytes +1 /
## +2 differ goes through dispatch_entity_cleanup; a fractal reference (+0x2c) is released; long
## +4 loses 0x80000. A group (kind 3): each child (+0x30 + 0x14 + 24 i, word +0x2e) releases its
## fractal reference (shapes), gets +4 |= 2, loses a reference (byte +3) and its controller link;
## the child table is freed and cleared, and the group's controller link cleared. Callees 0x18
## below.
func deactivate_object(obj: int) -> void:
	assert(memory != null, "deactivate_object requires original global memory")
	var entry_a7: int = a7
	var kind: int = memory.read_s8(obj)
	if kind == 2:
		a7 = entry_a7 - 0x18
		if (memory.read_u8(obj + 6) & 0x10) != 0:
			reset_object_to_template_pose(obj)
		heap_free_coalesce(memory.read_u32(obj + 0x4c))
		a7 = entry_a7 - 0x1c
		heap_free_coalesce(memory.read_u32(obj + 0x44))
		memory.write_u32(obj + 0x44, 0)
		a7 = entry_a7 - 0x18
		var i: int = 0
		while memory.read_s16(obj + 0x3a) > i:
			heap_free_coalesce(memory.read_u32(memory.read_u32(obj + 0x48) + 0x18 + i * 0x20))
			i += 1
		heap_free_coalesce(memory.read_u32(obj + 0x48))
		if memory.read_u32(obj + 8) != 0:
			memory.write_u32(memory.read_u32(obj + 8), 0)
		if memory.read_u8(obj + 1) != memory.read_u8(obj + 2):
			dispatch_entity_cleanup(obj)
		if memory.read_u32(obj + 0x2c) != 0:
			release_fractal_reference(obj)
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xfff7ffff)
		a7 = entry_a7
	elif kind == 3:
		a7 = entry_a7 - 0x18
		var i: int = 0
		while memory.read_s16(obj + 0x2e) > i:
			var child: int = memory.read_u32(memory.read_u32(obj + 0x30) + 0x14 + i * 0x18)
			if memory.read_u8(child) == 2 and memory.read_u32(child + 0x2c) != 0:
				release_fractal_reference(child)
			memory.write_u32(child + 4, memory.read_u32(child + 4) | 2)
			memory.write_u8(child + 3, C68kScript.u8(memory.read_u8(child + 3) - 1))
			if memory.read_u32(child + 8) != 0:
				memory.write_u32(memory.read_u32(child + 8), 0)
			i += 1
		heap_free_coalesce(memory.read_u32(obj + 0x30))
		memory.write_u32(obj + 0x30, 0)
		if memory.read_u32(obj + 8) != 0:
			memory.write_u32(memory.read_u32(obj + 8), 0)
		a7 = entry_a7

## 0x53f8: sort the near list (count long *count, low word dbra) in place. An object still inside
## its range (+0x10 <= +0xc) and not hidden (+7 bit 1) is kept; a visible shape (kind 2, +4 bit
## 0x40 clear) also gets its detail shift (+0x32: asr steps bringing ((+0x10 asr 2) + +0x10 +
## +0x14) asl word +0x34 under 0x8000), a camera-relative view point (asr by the shift; skipped
## for +4 bit 2) appended at view_points, and a place in visible_list. An object beyond its range
## is still kept while within 0x19c7f of it and not hidden, and a shape seen in the last 0x4b
## frames (frame - +0x3c) stays; otherwise it retires (when +0x3c is set; 0x30 below), is
## deactivated (0x30 below) and moves to entity_array_3. Then view_point_count and *count are
## updated.
func collect_near_objects(list: int, count_ptr: int) -> void:
	assert(memory != null, "collect_near_objects requires original global memory")
	var entry_a7: int = a7
	var point: int = C68kScript.u32(DAT_0001c43c + memory.read_s32(DAT_0001c1d0) * 12)
	var keep: int = list
	var read: int = list
	var left: int = memory.read_u16(count_ptr + 2)
	while left != 0:
		left -= 1
		var obj: int = memory.read_u32(read)
		read += 4
		var hidden: bool = (memory.read_u8(obj + 7) & 2) != 0
		var kept: bool = true
		if memory.read_s32(obj + 0x10) > memory.read_s32(obj + 0xc) or hidden:
			if C68kScript.s32(memory.read_u32(obj + 0x10) - memory.read_u32(obj + 0xc)) > 0x19c7f or hidden:
				if memory.read_u8(obj) == 2 and C68kScript.s32(memory.read_u32(DAT_0001b838) - memory.read_u32(obj + 0x3c)) <= 0x4b:
					pass
				else:
					a7 = entry_a7 - 0x30
					if memory.read_u8(obj) == 2 and memory.read_u32(obj + 0x3c) != 0:
						retire_entity(obj)
					deactivate_object(obj)
					a7 = entry_a7
					memory.write_u32(DAT_0001d0e4 + memory.read_s32(DAT_0001c1dc) * 4, obj)
					memory.write_u32(DAT_0001c1dc, C68kScript.u32(memory.read_u32(DAT_0001c1dc) + 1))
					kept = false
		elif memory.read_u8(obj) == 2 and (memory.read_u32(obj + 4) & 0x40) == 0:
			var size: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(C68kScript.asr32(memory.read_u32(obj + 0x10), 2) + memory.read_u32(obj + 0x10) + memory.read_u32(obj + 0x14)), memory.read_s16(obj + 0x34)))
			var detail: int = 0
			while (C68kScript.u32(size) & 0xffff8000) != 0:
				detail = C68kScript.s16(detail + 1)
				size = C68kScript.asr32(size, 1)
			memory.write_u16(obj + 0x32, C68kScript.u16(detail))
			if (memory.read_u32(obj + 4) & 4) == 0:
				memory.write_u32(point, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x18) - memory.read_u32(DAT_0001d838)), detail)))
				memory.write_u32(point + 4, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(DAT_0001d834)), detail)))
				memory.write_u32(point + 8, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x20) - memory.read_u32(DAT_0001d830)), detail)))
				point += 12
			memory.write_u32(DAT_0001c9dc + memory.read_s32(DAT_0001c1d4) * 4, obj)
			memory.write_u32(DAT_0001c1d4, C68kScript.u32(memory.read_u32(DAT_0001c1d4) + 1))
		if kept:
			memory.write_u32(keep, obj)
			keep += 4
	memory.write_u32(DAT_0001c1d0, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(point - DAT_0001c43c), 12)))
	memory.write_u32(count_ptr, C68kScript.u32(C68kScript.asr32(C68kScript.s32(keep - list), 2)))

## 0x2802: dst = camera matrix (0x1d744 words, rows of 3) * (src >> shift as words), + 0x800 asr
## 12, for an unsigned 32-bit count of int3 vectors (dbra on the low word, then the high word).
func transform_int3_vecs_asr_by_1d744(count: int, src: int, dst: int, shift: int) -> void:
	assert(memory != null, "transform_int3_vecs_asr_by_1d744 requires original global memory")
	var m: int = 0x1d744
	for i in C68kScript.u32(count):
		var x: int = C68kScript.s16(C68kScript.asr32(memory.read_u32(src), shift))
		var y: int = C68kScript.s16(C68kScript.asr32(memory.read_u32(src + 4), shift))
		var z: int = C68kScript.s16(C68kScript.asr32(memory.read_u32(src + 8), shift))
		for j in 3:
			var sum: int = C68kScript.s32(x * memory.read_s16(m + 2 * j) + y * memory.read_s16(m + 6 + 2 * j) + z * memory.read_s16(m + 0xc + 2 * j) + 0x800)
			memory.write_u32(dst + 4 * j, C68kScript.u32(C68kScript.asr32(sum, 12)))
		src = C68kScript.u32(src + 12)
		dst = C68kScript.u32(dst + 12)

## 0x58ec: cull the visible list. The view points are turned into camera space
## (transform_int3_vecs_asr_by_1d744(view_point_count, view_points, view_points, 0), 0x44 below);
## then two passes (the near objects up to visible_first_pass, then the far ones, after which
## visible_first_pass becomes the kept count) keep: objects with +7 bit 2 (no view point), objects
## the camera is inside (dist - dist / 4 < radius; +4 |= 8), and objects in front (z > 0) whose
## max(|x|, |y|) - r (r = radius asr word +0x32, words) times 1.5 is under z + r (abs_int 0x38
## below). visible_count = kept, view_point_count = 0.
func build_visible_object_list() -> void:
	assert(memory != null, "build_visible_object_list requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x30
	a7 = body - 0x14
	transform_int3_vecs_asr_by_1d744(memory.read_u32(DAT_0001c1d0), DAT_0001c43c, DAT_0001c43c, 0)
	a7 = entry_a7
	var keep: int = DAT_0001c9dc
	var read: int = DAT_0001c9dc
	var point: int = DAT_0001c43c
	for pass_index in 2:
		var left: int
		if pass_index == 0:
			left = memory.read_u16(DAT_0001c1c0)
		else:
			left = (memory.read_u16(DAT_0001c1d4 + 2) - memory.read_u16(DAT_0001c1c0)) & 0xffff
			memory.write_u16(DAT_0001c1c0, C68kScript.u16(C68kScript.asr32(keep - DAT_0001c9dc, 2)))
		while left != 0:
			left -= 1
			var obj: int = memory.read_u32(read)
			read += 4
			if (memory.read_u8(obj + 7) & 4) != 0:
				memory.write_u32(keep, obj)
				keep += 4
				continue
			var inner: int = C68kScript.s32(-C68kScript.s32(C68kScript.asr32(memory.read_u32(obj + 0x10), 2) - memory.read_u32(obj + 0x10)))
			if inner < memory.read_s32(obj + 0x14):
				memory.write_u32(keep, obj)
				keep += 4
				memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 8)
			elif memory.read_s32(point + 8) > 0:
				a7 = body - 8
				var ax: int = C68kScript.s16(abs_int(memory.read_s32(point)))
				var ay: int = C68kScript.s16(abs_int(memory.read_s32(point + 4)))
				a7 = entry_a7
				var r: int = C68kScript.s16(C68kScript.asr32(memory.read_u32(obj + 0x14), memory.read_u16(obj + 0x32)))
				var edge: int = C68kScript.s16((ax if ay < ax else ay) - r)
				var reach: int = (C68kScript.s16(edge) >> 1) + edge
				if C68kScript.s32(r + memory.read_s32(point + 8)) > reach:
					memory.write_u32(keep, obj)
					keep += 4
			point += 12
	memory.write_u32(DAT_0001c1d4, C68kScript.u32(C68kScript.asr32(keep - DAT_0001c9dc, 2)))
	memory.write_u32(DAT_0001c1d0, 0)

## One of the four broad-phase tests (bsr in the original: 0x13ee0 test_object_collision, 0x1429c
## handle_player_contact, 0x13e4e test_proximity_collision, 0x13eae
## test_player_vs_type0e_proximity), entered 0xc below the caller's body. They are reached
## through code_table at their runtime addresses so a test can isolate collect_far_objects.
func _far_collision(proximity: bool, player: bool, a: int, b: int) -> void:
	var file_address: int = (0x13eae if player else 0x13e4e) if proximity else (0x1429c if player else 0x13ee0)
	_jsr(file_address - 0x20, [a, b])

## 0x555a: sort the far list (metric-ordered, count long *count, low word dbra) in place, as
## collect_near_objects does for range, view points and the visible list (no kind test: +4 bit
## 0x40 alone hides), while running the broad-phase collisions. Link a6 -0x37c and ten registers
## (body 0x3a8 below); `active` (a6 - 0x370) collects objects with +4 bits 0x2800. A kept object
## with +4 bit 0x8000 joins the overlap list. An active object (word +6 loses 0x800) is tested
## against the earlier kept, unhidden objects it overlaps (reach = +0x10 + +0x14 beyond their
## +0x10 - +0x14), scanning back until one's running minimum (+0x28) passes its reach; others are
## tested against the active objects the same way. The tests (0xc below): +0x100000 on the
## passive one -> proximity, +0x40 on the active one -> player variants. Each kept object then
## stores the running minimum of +0x10 - +0x14 in +0x28. Objects out of range are kept within
## 0x19c7f (unhidden) - those skip overlap and collisions when only kept for being seen in the
## last 0x4b frames - else retire / deactivate (8 below) into entity_array_3.
func collect_far_objects(list: int, count_ptr: int) -> void:
	assert(memory != null, "collect_far_objects requires original global memory")
	assert(a7 != 0, "collect_far_objects needs a7 (its frame holds the active list)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x3a8
	var point: int = C68kScript.u32(DAT_0001c43c + memory.read_s32(DAT_0001c1d0) * 12)
	var keep: int = list
	var read: int = list
	var left: int = memory.read_u16(count_ptr + 2)
	var min_start: int = 0x7fffffff
	var active: int = a6 - 0x370
	var active_count: int = 0
	while left != 0:
		left -= 1
		var obj: int = memory.read_u32(read)
		read += 4
		var flags: int = memory.read_u32(obj + 4)
		var normal: bool = true
		if memory.read_s32(obj + 0x10) > memory.read_s32(obj + 0xc) or (flags & 2) != 0:
			if C68kScript.s32(memory.read_u32(obj + 0x10) - memory.read_u32(obj + 0xc)) > 0x19c7f or (flags & 2) != 0:
				if C68kScript.s32(memory.read_u32(DAT_0001b838) - memory.read_u32(obj + 0x3c)) <= 0x4b:
					normal = false
				else:
					a7 = body - 8
					if memory.read_u32(obj + 0x3c) != 0:
						retire_entity(obj)
					deactivate_object(obj)
					a7 = entry_a7
					memory.write_u32(DAT_0001d0e4 + memory.read_s32(DAT_0001c1dc) * 4, obj)
					memory.write_u32(DAT_0001c1dc, C68kScript.u32(memory.read_u32(DAT_0001c1dc) + 1))
					continue
		elif (flags & 0x40) == 0:
			var size: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(C68kScript.asr32(memory.read_u32(obj + 0x10), 2) + memory.read_u32(obj + 0x10) + memory.read_u32(obj + 0x14)), memory.read_s16(obj + 0x34)))
			var detail: int = 0
			while (C68kScript.u32(size) & 0xffff8000) != 0:
				detail = C68kScript.s16(detail + 1)
				size = C68kScript.asr32(size, 1)
			memory.write_u16(obj + 0x32, C68kScript.u16(detail))
			if (flags & 4) == 0:
				memory.write_u32(point, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x18) - memory.read_u32(DAT_0001d838)), detail)))
				memory.write_u32(point + 4, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(DAT_0001d834)), detail)))
				memory.write_u32(point + 8, C68kScript.u32(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x20) - memory.read_u32(DAT_0001d830)), detail)))
				point += 12
			memory.write_u32(DAT_0001c9dc + memory.read_s32(DAT_0001c1d4) * 4, obj)
			memory.write_u32(DAT_0001c1d4, C68kScript.u32(memory.read_u32(DAT_0001c1d4) + 1))
		if normal:
			if (flags & 0x8000) != 0:
				memory.write_u32(DAT_0001c1e4 + memory.read_s32(DAT_0001c1c4) * 4, obj)
				memory.write_u32(DAT_0001c1c4, C68kScript.u32(memory.read_u32(DAT_0001c1c4) + 1))
			var reach: int = C68kScript.s32(memory.read_u32(obj + 0x10) + memory.read_u32(obj + 0x14))
			if (flags & 0x2800) != 0:
				memory.write_u16(obj + 6, memory.read_u16(obj + 6) & 0xf7ff)
				if min_start < reach:
					var scan: int = keep
					var n: int = C68kScript.asr32(keep - list, 2) & 0xffff
					while n != 0:
						n -= 1
						scan -= 4
						var other: int = memory.read_u32(scan)
						if (memory.read_u8(other + 7) & 2) != 0:
							continue
						if reach > C68kScript.s32(memory.read_u32(other + 0x10) - memory.read_u32(other + 0x14)):
							a7 = body - 0xc
							_far_collision((memory.read_u8(other + 5) & 0x10) != 0, (flags & 0x40) != 0, obj, other)
							a7 = entry_a7
						elif reach < memory.read_s32(other + 0x28):
							break
				memory.write_u32(active + active_count * 4, obj)
				active_count += 1
			elif min_start < reach:
				var n: int = active_count
				var scan: int = active + active_count * 4
				while n != 0:
					n -= 1
					scan -= 4
					var other: int = memory.read_u32(scan)
					if reach > C68kScript.s32(memory.read_u32(other + 0x10) - memory.read_u32(other + 0x14)):
						a7 = body - 0xc
						_far_collision((flags & 0x100000) != 0, (memory.read_u8(other + 7) & 0x40) != 0, other, obj)
						a7 = entry_a7
					elif reach < memory.read_s32(other + 0x28):
						break
			var start: int = C68kScript.s32(memory.read_u32(obj + 0x10) - memory.read_u32(obj + 0x14))
			if min_start > start:
				min_start = start
			memory.write_u32(obj + 0x28, C68kScript.u32(min_start))
		memory.write_u32(keep, obj)
		keep += 4
	memory.write_u32(DAT_0001c1d0, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(point - DAT_0001c43c), 12)))
	memory.write_u32(count_ptr, C68kScript.u32(C68kScript.asr32(C68kScript.s32(keep - list), 2)))

## 0x135e8: a contact record for objects a / b. Link a6 -0xc and eight registers (body 0x30
## below). The faces of b whose extent (+0x1c) reaches half its metric (+0x10 / 2 toward zero)
## are selected; the record (heap_alloc_cleared(6 * count + 0x10), 8 below) holds a, b, the count
## (+0xa), and is put in the first free slot of the 256-entry table 0x1bdbc from
## contact_pair_hash(a, b) (0x10 below). +0xe = asr steps bringing (2 * b +0x14 + a +0x14) asl
## word b +0x34 under 0x8000, +0xc = b +0x34 - that. From +0x10: the selected face indices, then
## (after count side words, left 0) one axis word per face from its normal minus vertex 0 (abs_int
## 8 / 0xc / 0x10 below): 0 when |x| is the largest, 1 for |y|, else 2 (ties to the later axis).
func create_shape_contact_record(obj_a: int, obj_b: int) -> int:
	assert(memory != null, "create_shape_contact_record requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x30
	var half: int = memory.read_s32(obj_b + 0x10)
	if half < 0:
		half += 1
	half = half >> 1
	var selected: Array = []
	var face: int = memory.read_u32(obj_b + 0x48)
	for f in memory.read_u16(obj_b + 0x3a):
		if half <= memory.read_s32(face + 0x1c):
			selected.append(f)
		face = C68kScript.u32(face + 0x20)
	var count: int = C68kScript.s16(selected.size())
	a7 = body - 8
	var rec: int = heap_alloc_cleared(C68kScript.s32(count * 6 + 0x10))
	memory.write_u16(rec + 0xa, C68kScript.u16(count))
	memory.write_u32(rec, C68kScript.u32(obj_a))
	memory.write_u32(rec + 4, C68kScript.u32(obj_b))
	a7 = body - 0x10
	var slot: int = contact_pair_hash(obj_a, obj_b)
	a7 = entry_a7
	while memory.read_u32(DAT_0001bdbc + slot * 4) != 0:
		slot = (slot + 1) & 0xff
	memory.write_u32(DAT_0001bdbc + slot * 4, rec)
	var extent: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(C68kScript.lsl32(memory.read_u32(obj_b + 0x14), 1) + memory.read_u32(obj_a + 0x14)), memory.read_s16(obj_b + 0x34)))
	var shift: int = 0
	while (C68kScript.u32(extent) & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		extent = C68kScript.asr32(extent, 1)
	memory.write_u16(rec + 0xe, C68kScript.u16(shift))
	memory.write_u16(rec + 0xc, C68kScript.u16(memory.read_u16(obj_b + 0x34) - shift))
	for k in selected.size():
		memory.write_u16(rec + 0x10 + 2 * k, C68kScript.u16(selected[k]))
	var verts: int = memory.read_u32(obj_b + 0x44)
	var normals: int = C68kScript.u32(verts + memory.read_s16(obj_b + 0x36) * 12)
	var axis_p: int = rec + 0x10 + count * 4
	for k in selected.size():
		var n: int = C68kScript.u32(normals + memory.read_s16(rec + 0x10 + 2 * k) * 12)
		a7 = body - 8
		var ax: int = C68kScript.s16(abs_int(C68kScript.s32(memory.read_u32(n) - memory.read_u32(verts))))
		a7 = body - 0xc
		var ay: int = C68kScript.s16(abs_int(C68kScript.s32(memory.read_u32(n + 4) - memory.read_u32(verts + 4))))
		a7 = body - 0x10
		var az: int = C68kScript.s16(abs_int(C68kScript.s32(memory.read_u32(n + 8) - memory.read_u32(verts + 8))))
		a7 = entry_a7
		var axis: int
		if ay < ax:
			axis = 0 if az < ax else 2
		else:
			axis = 1 if az < ay else 2
		memory.write_u16(axis_p, axis)
		axis_p += 2
	return rec

## 0x13e4e (broad-phase, runtime 0x13e2e): two objects both flagged 0x100000 collide when 3/4 of
## their distance (asr 2 + asr 1, 0x24 below) is inside either one's radius (+0x14):
## dispatch_collision(a, b) (0x14 below).
func test_proximity_collision(obj_a: int, obj_b: int) -> void:
	assert(memory != null, "test_proximity_collision requires original global memory")
	var entry_a7: int = a7
	if (memory.read_u32(obj_a + 4) & memory.read_u32(obj_b + 4) & 0x100000) == 0:
		return
	a7 = entry_a7 - 0x24
	var dist: int = approx_dist3_xyz(memory.read_s32(obj_a + 0x18), memory.read_s32(obj_a + 0x1c), memory.read_s32(obj_a + 0x20), memory.read_s32(obj_b + 0x18), memory.read_s32(obj_b + 0x1c), memory.read_s32(obj_b + 0x20))
	a7 = entry_a7
	var near: int = C68kScript.s32(C68kScript.asr32(dist, 1) + C68kScript.asr32(dist, 2))
	if near < memory.read_s32(obj_a + 0x14) or near < memory.read_s32(obj_b + 0x14):
		a7 = entry_a7 - 0x14
		dispatch_collision(obj_a, obj_b)
		a7 = entry_a7

## 0x13eae (runtime 0x13e8e): only the player (controller == player_object) against a type 0xe
## object: test_proximity_collision (0x10 below).
func test_player_vs_type0e_proximity(obj_a: int, obj_b: int) -> void:
	assert(memory != null, "test_player_vs_type0e_proximity requires original global memory")
	var entry_a7: int = a7
	if memory.read_u32(obj_a + 8) != memory.read_u32(DAT_0001b738):
		return
	if memory.read_s16(memory.read_u32(memory.read_u32(obj_b + 8) + 4)) != 0xe:
		return
	a7 = entry_a7 - 0x10
	test_proximity_collision(obj_a, obj_b)
	a7 = entry_a7

## The contact record of a / b, created when missing; its live word +8 = 1. Returns the record
## and whether it was created (find / create entered `depth` below a7).
func _touch_contact_record(obj_a: int, obj_b: int, depth: int) -> Array:
	var entry_a7: int = a7
	a7 = entry_a7 - depth
	var rec: int = find_contact_record(obj_a, obj_b)
	var created: bool = rec == 0
	if created:
		rec = create_shape_contact_record(obj_a, obj_b)
	a7 = entry_a7
	memory.write_u16(rec + 8, 1)
	return [rec, created]

## The other object's collision hook (definition +0x12) when its byte +6 bit 6 is set:
## hook(b, a, rec).
func _shape_collision_hook(obj_a: int, obj_b: int, rec: int, depth: int) -> int:
	var entry_a7: int = a7
	a7 = entry_a7 - depth
	var d0: int = C68kScript.u32(_jsr(memory.read_u32(memory.read_u32(memory.read_u32(obj_b + 8) + 4) + 0x12), [obj_b, obj_a, rec]))
	a7 = entry_a7
	return d0

## 0x1429c (runtime 0x1427c): the player touching b - within (radii sum) of 3/4 of their distance
## (0x2c below): terrain (b byte +6 bit 1) goes to handle_terrain_contact (0x1c below);
## otherwise the contact record is touched (0x1c below) and b's collision hook runs (byte +6 bit
## 6, 0x20 below).
func handle_player_contact(obj_a: int, obj_b: int) -> void:
	assert(memory != null, "handle_player_contact requires original global memory")
	var entry_a7: int = a7
	if memory.read_u32(obj_a + 8) != memory.read_u32(DAT_0001b738):
		return
	a7 = entry_a7 - 0x2c
	var dist: int = approx_dist3_xyz(memory.read_s32(obj_a + 0x18), memory.read_s32(obj_a + 0x1c), memory.read_s32(obj_a + 0x20), memory.read_s32(obj_b + 0x18), memory.read_s32(obj_b + 0x1c), memory.read_s32(obj_b + 0x20))
	a7 = entry_a7
	if C68kScript.s32(memory.read_u32(obj_a + 0x14) + memory.read_u32(obj_b + 0x14)) < C68kScript.s32(dist - C68kScript.asr32(dist, 2)):
		return
	if (memory.read_u8(obj_b + 6) & 2) != 0:
		a7 = entry_a7 - 0x1c
		handle_terrain_contact(obj_a, obj_b)
		a7 = entry_a7
		return
	var rec: int = _touch_contact_record(obj_a, obj_b, 0x1c)[0]
	if (memory.read_u8(obj_b + 6) & 0x40) != 0:
		_shape_collision_hook(obj_a, obj_b, rec, 0x20)

## 0x1346c: is object a's position (shifted by record word +0xc: asr by its negation when
## negative, else asl) inside the face projected on the plane the axis word names (0 y/z, 1 x/z,
## 2 x/y; others -> 0)? The face of b is projected with the record's vertex shift (+0xe) into the
## frame (a6 - 0x690; link a6 -0x690 and ten registers, body 0x6bc below; project 0x1c below) and
## tested at (0, 0) (0x30 below). Returns 1 or 0.
func point_in_face_by_axis(rec: int, obj_a: int, obj_b: int, face: int, _dot: int, _nx: int, _ny: int, _nz: int, axis: int) -> int:
	assert(memory != null, "point_in_face_by_axis requires original global memory")
	assert(a7 != 0, "point_in_face_by_axis needs a7 (its frame holds the projected vertices)")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x6bc
	var projected: int = entry_a7 - 4 - 0x690
	var shift: int = memory.read_s16(rec + 0xc)
	var p: Array = []
	for off in [0x18, 0x1c, 0x20]:
		if shift < 0:
			p.append(C68kScript.asr32(memory.read_u32(obj_a + off), -shift))
		else:
			p.append(C68kScript.s32(C68kScript.lsl32(memory.read_u32(obj_a + off), shift)))
	axis = C68kScript.s16(axis)
	var vertex_shift: int = memory.read_s16(rec + 0xe)
	var count: int = memory.read_s16(face + 0x14)
	var idx: int = memory.read_u32(face + 0x18)
	var inside: int
	a7 = body - 0x1c
	if axis == 0:
		project_face_vertices_yz(obj_b, vertex_shift, face, p[1], p[2], projected)
		a7 = body - 0x30
		inside = point_in_polygon_yz(0, 0, projected, count, idx)
	elif axis == 1:
		project_face_vertices_xz(obj_b, vertex_shift, face, p[0], p[2], projected)
		a7 = body - 0x30
		inside = point_in_polygon_xz(0, 0, projected, count, idx)
	elif axis == 2:
		project_face_vertices_xy(obj_b, vertex_shift, face, p[0], p[1], projected)
		a7 = body - 0x30
		inside = point_in_polygon_xy(0, 0, projected, count, idx)
	else:
		a7 = entry_a7
		return 0
	a7 = entry_a7
	return 1 if inside != 0 else 0

## 0x13ee0 (runtime 0x13ec0): moving object a against shape b. Link a6 -0x2c and ten registers
## (body 0x58 below). Beyond (radii sum) of 3/4 of their distance (0x74 below) nothing happens.
## Terrain (b byte +6 bit 1) goes to test_terrain_collision (0x64 below); a bullet (b
## byte +6 bit 2, a's controller of type 0xe, view mode != 8) to bullet_hits_shape (0x64 below).
## Otherwise the contact record is touched (0x64 below), b's collision hook runs (byte +6 bit 6,
## 0x68 below) and, unless either object has +5 bit 0, each recorded face is checked: a's
## position (shifted by +0xc) relative to the face's first vertex (asr +0xe), dotted with the face
## normal minus vertex 0 (words, muls.w), gives the side (1 when <= 0). On an old record a side
## change asks point_in_face_by_axis (record, a, b, face, dot, normal x / y / z, axis word; 0x80
## below); inside -> dispatch_collision(a, b) (0x64 below) and return. The side word is kept.
## Returns D0 as the bytes leave it only in the dispatch case (callers ignore it).
func test_object_collision(obj_a: int, obj_b: int) -> int:
	assert(memory != null, "test_object_collision requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x58
	a7 = body - 0x1c
	var dist: int = approx_dist3_xyz(memory.read_s32(obj_a + 0x18), memory.read_s32(obj_a + 0x1c), memory.read_s32(obj_a + 0x20), memory.read_s32(obj_b + 0x18), memory.read_s32(obj_b + 0x1c), memory.read_s32(obj_b + 0x20))
	a7 = entry_a7
	if C68kScript.s32(memory.read_u32(obj_a + 0x14) + memory.read_u32(obj_b + 0x14)) < C68kScript.s32(dist - C68kScript.asr32(dist, 2)):
		return 0
	if (memory.read_u8(obj_b + 6) & 2) != 0:
		a7 = body - 0xc
		test_terrain_collision(obj_a, obj_b)
		a7 = entry_a7
		return 0
	if (memory.read_u8(obj_b + 6) & 4) != 0 and memory.read_u32(obj_a + 8) != 0 and memory.read_s16(memory.read_u32(memory.read_u32(obj_a + 8) + 4)) == 0xe and memory.read_s16(DAT_0001d858) != 8:
		a7 = body - 0xc
		var hit: int = bullet_hits_shape(obj_a, obj_b)
		a7 = entry_a7
		return hit
	a7 = body
	var touched: Array = _touch_contact_record(obj_a, obj_b, 0xc)
	a7 = entry_a7
	var rec: int = touched[0]
	var created: bool = touched[1]
	if (memory.read_u8(obj_b + 6) & 0x40) != 0:
		a7 = body
		_shape_collision_hook(obj_a, obj_b, rec, 0x10)
		a7 = entry_a7
	if (memory.read_u8(obj_a + 5) & 1) != 0 or (memory.read_u8(obj_b + 5) & 1) != 0:
		return 0
	var faces: int = memory.read_u32(obj_b + 0x48)
	var verts: int = memory.read_u32(obj_b + 0x44)
	var normals: int = C68kScript.u32(verts + memory.read_s16(obj_b + 0x36) * 12)
	var shift: int = memory.read_s16(rec + 0xc)
	var p: Array = []
	for off in [0x18, 0x1c, 0x20]:
		if shift < 0:
			p.append(C68kScript.s16(C68kScript.asr32(memory.read_u32(obj_a + off), -shift)))
		else:
			p.append(C68kScript.s16(C68kScript.lsl32(memory.read_u32(obj_a + off), shift)))
	var count: int = memory.read_u16(rec + 0xa)
	var idx_p: int = rec + 0x10
	var side_p: int = idx_p + C68kScript.s16(count) * 2
	var axis_p: int = side_p + C68kScript.s16(count) * 2
	var vshift: int = memory.read_s16(rec + 0xe)
	while count != 0:
		count -= 1
		var fi: int = memory.read_s16(idx_p)
		var face: int = C68kScript.u32(faces + fi * 0x20)
		var v0: int = C68kScript.u32(verts + memory.read_s16(memory.read_u32(face + 0x18)) * 12)
		var n: int = C68kScript.u32(normals + fi * 12)
		var nx: int = C68kScript.s16(memory.read_u16(n + 2) - memory.read_u16(verts + 2))
		var ny: int = C68kScript.s16(memory.read_u16(n + 6) - memory.read_u16(verts + 6))
		var nz: int = C68kScript.s16(memory.read_u16(n + 0xa) - memory.read_u16(verts + 0xa))
		var dx: int = C68kScript.s16(p[0] - C68kScript.asr32(memory.read_u32(v0), vshift))
		var dy: int = C68kScript.s16(p[1] - C68kScript.asr32(memory.read_u32(v0 + 4), vshift))
		var dz: int = C68kScript.s16(p[2] - C68kScript.asr32(memory.read_u32(v0 + 8), vshift))
		var dot: int = C68kScript.s32(C68kScript.s32(dx * nx + dy * ny) + dz * nz)
		var side: int = 1 if dot <= 0 else 0
		if not created and (memory.read_u16(side_p) ^ side) != 0:
			a7 = body - 0x28
			var inside: int = point_in_face_by_axis(rec, obj_a, obj_b, face, dot, nx, ny, nz, memory.read_s16(axis_p))
			a7 = entry_a7
			if inside != 0:
				a7 = body - 0xc
				var d0: int = dispatch_collision(obj_a, obj_b)
				a7 = entry_a7
				return d0
		memory.write_u16(side_p, side)
		idx_p += 2
		side_p += 2
		axis_p += 2
	return 0

## 0x1383c: a contact record (0x3e bytes, heap_alloc - not cleared; 8 below) for object a over
## the fractal terrain b. Link a6 -0x100 and six registers (body 0x11c below). It goes into the
## contact table like create_shape_contact_record (hash 0x10 below) with the same shifts (+0xc
## steps, +0xa = b +0x34 - steps). The terrain's heading is the sum of the part angles (+4 of the
## 0x18-byte part entries) along b's parent chain, & 0x3fff; when non-zero the record keeps the
## cell rotation (+0xe = cos + (-sin) / 2, +0x10 = -sin, +0x12 = sin + cos / 2, +0x14 = cos; cos
## 8 / sin 0xc below), else +0xe = +0x14 = 0. Cell size +0x16 = (0x19c80 asl b +0x34) asr +0xc;
## the cell bounds +0x18..+0x1e start empty (1, -1, -1, 1).
func create_fractal_contact_record(obj_a: int, obj_b: int) -> int:
	assert(memory != null, "create_fractal_contact_record requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x11c
	a7 = body - 8
	var rec: int = heap_alloc(0x3e)
	memory.write_u32(rec, C68kScript.u32(obj_a))
	memory.write_u32(rec + 4, C68kScript.u32(obj_b))
	a7 = body - 0x10
	var slot: int = contact_pair_hash(obj_a, obj_b)
	a7 = entry_a7
	while memory.read_u32(DAT_0001bdbc + slot * 4) != 0:
		slot = (slot + 1) & 0xff
	memory.write_u32(DAT_0001bdbc + slot * 4, rec)
	var extent: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(C68kScript.lsl32(memory.read_u32(obj_b + 0x14), 1) + memory.read_u32(obj_a + 0x14)), memory.read_s16(obj_b + 0x34)))
	var steps: int = 0
	while (C68kScript.u32(extent) & 0xffff8000) != 0:
		steps = C68kScript.s16(steps + 1)
		extent = C68kScript.asr32(extent, 1)
	memory.write_u16(rec + 0xc, C68kScript.u16(steps))
	memory.write_u16(rec + 0xa, C68kScript.u16(memory.read_u16(obj_b + 0x34) - steps))
	var angle: int = 0
	var part: int = memory.read_u8(obj_b + 2)
	var link: int = memory.read_u32(obj_b + 0x24)
	while link != 0:
		angle = (angle + memory.read_u16(C68kScript.u32(memory.read_u32(link + 0x30) + part * 0x18 + 4))) & 0x3fff
		part = memory.read_u8(link + 2)
		link = memory.read_u32(link + 0x24)
	if angle != 0:
		a7 = body - 8
		var c: int = C68kScript.s16(cos_fixed14(angle))
		a7 = body - 0xc
		var sn: int = C68kScript.s16(sin_fixed14(angle))
		a7 = entry_a7
		var neg_sin: int = C68kScript.s16(-sn)
		memory.write_u16(rec + 0xe, C68kScript.u16(((neg_sin + 1 if neg_sin < 0 else neg_sin) >> 1) + c))
		memory.write_u16(rec + 0x10, C68kScript.u16(neg_sin))
		memory.write_u16(rec + 0x12, C68kScript.u16(((c + 1 if c < 0 else c) >> 1) + sn))
		memory.write_u16(rec + 0x14, C68kScript.u16(c))
	else:
		memory.write_u16(rec + 0x14, 0)
		memory.write_u16(rec + 0xe, 0)
	memory.write_u16(rec + 0x16, C68kScript.u16(C68kScript.asr32(C68kScript.s32(C68kScript.lsl32(0x19c80, memory.read_s16(obj_b + 0x34))), memory.read_u16(rec + 0xc))))
	memory.write_u16(rec + 0x18, 1)
	memory.write_u16(rec + 0x1a, 0xffff)
	memory.write_u16(rec + 0x1c, 0xffff)
	memory.write_u16(rec + 0x1e, 1)
	return rec

## Floor division of a word by the cell size as the bytes do it: divs.w quotient, one less when
## the divs.w remainder is negative.
func _cell_floor(value: int, size: int) -> int:
	assert(size != 0, "fractal_height_at: divs.w by zero traps")
	var q: int = C68kScript.s16(C68kScript.divs_trunc(value, size))
	if C68kScript.s16(C68kScript.rems_trunc(value, size)) < 0:
		q = C68kScript.s16(q - 1)
	return q

## 0x13980: ground height of the fractal terrain at (x, z) relative to it (scaled words). Link a6
## -0x14 and ten registers (body 0x40 below). The point is turned into cell coordinates (u, v):
## rotated by the record's cell matrix (+0xe / +0x12, +0x10 / +0x14, asr 12) or, unrotated, u = x +
## z / 2. Outside the cached cell (+0x18..+0x1e) the cell is recomputed (floor by the cell size
## +0x16) and its two faces looked up: the terrain's face-centre vertices (template vertices from
## +0x22 + 12 (word +0x36 - word +0x38), word +0x38 of them) within 0xad3f (|dx| + |dz|, abs 8 /
## 0xc below) of the cell centre (shifted by +0xa) give face a (centre z <= cell z) or b; each found
## face fills a 14-byte plane (+0x22 / +0x30: face, normal x / y / z minus vertex 0, first vertex
## minus the object position asr +0xc). The triangle (v - cell v < u - cell u -> plane a) is
## remembered in +0x20 (changes set *changed = 1) and 0x20b48. Height = p[5] + ((z - p[6]) * -p[3]
## - (x - p[4]) * p[1]) / p[2], 0 when p[2] is 0 or the height negative.
func fractal_height_at(rec: int, x: int, z: int, changed: int) -> int:
	assert(memory != null, "fractal_height_at requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x40
	x = C68kScript.s16(x)
	z = C68kScript.s16(z)
	var obj: int = memory.read_u32(rec + 4)
	var u: int
	var v: int
	if memory.read_u16(rec + 0xe) != 0 or memory.read_u16(rec + 0x14) != 0:
		u = C68kScript.s16(C68kScript.asr32(C68kScript.s32(x * memory.read_s16(rec + 0xe) + z * memory.read_s16(rec + 0x12)), 12))
		v = C68kScript.s16(C68kScript.asr32(C68kScript.s32(x * memory.read_s16(rec + 0x10) + z * memory.read_s16(rec + 0x14)), 12))
	else:
		u = C68kScript.s16(x + ((z + 1 if z < 0 else z) >> 1))
		v = z
	if u < memory.read_s16(rec + 0x18) or u >= memory.read_s16(rec + 0x1a) or memory.read_s16(rec + 0x1c) > v or not (memory.read_s16(rec + 0x1e) > v):
		memory.write_u16(rec + 0x20, 0xffff)
		var n: int = memory.read_s16(rec + 0x16)
		var half: int = (n + 1 if n < 0 else n) >> 1
		var cu: int = C68kScript.s16(_cell_floor(u, n) * n)
		var cv: int = C68kScript.s16(_cell_floor(v, n) * n)
		memory.write_u16(rec + 0x18, C68kScript.u16(cu))
		memory.write_u16(rec + 0x1a, C68kScript.u16(cu + n))
		memory.write_u16(rec + 0x1c, C68kScript.u16(cv))
		memory.write_u16(rec + 0x1e, C68kScript.u16(cv + n))
		var centre_z: int = C68kScript.s32(half + cv)
		var halved: int = (centre_z + 1 if centre_z < 0 else centre_z) >> 1
		var centre_x: int = C68kScript.s32(half + cu - halved)
		var shift: int = memory.read_s16(rec + 0xa)
		if shift < 0:
			centre_z = C68kScript.s32(C68kScript.lsl32(centre_z, -shift))
			centre_x = C68kScript.s32(C68kScript.lsl32(centre_x, -shift))
		else:
			centre_x = C68kScript.asr32(centre_x, shift)
			centre_z = C68kScript.asr32(centre_z, shift)
		var entry: int = C68kScript.u32(memory.read_u32(C68kScript.u32(memory.read_u32(memory.read_u32(obj + 0x24) + 0x28) + 0x1a + 0x14 + memory.read_u8(obj + 1) * 0x18)) + memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c))
		var centres: int = C68kScript.u32(entry + 0x22 + C68kScript.s32(memory.read_s16(obj + 0x36) - memory.read_s16(obj + 0x38)) * 12)
		memory.write_u16(DAT_00020b44 + 2, 0xffff)
		memory.write_u16(DAT_00020b44, 0xffff)
		var centre: int = centres
		for i in memory.read_u16(obj + 0x38):
			a7 = body - 8
			var dx: int = abs_int(C68kScript.s32(memory.read_u32(centre) - centre_x))
			a7 = body - 0xc
			var dz: int = abs_int(C68kScript.s32(memory.read_u32(centre + 8) - centre_z))
			a7 = entry_a7
			if C68kScript.s32(dx + dz) <= 0xad3f:
				var index: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(centre - centres), 12))
				if centre_z >= memory.read_s32(centre + 8):
					memory.write_u16(DAT_00020b44, index)
				else:
					memory.write_u16(DAT_00020b44 + 2, index)
			centre = C68kScript.u32(centre + 12)
		memory.write_u16(rec + 0x34, 0)
		memory.write_u16(rec + 0x26, 0)
		var verts: int = memory.read_u32(obj + 0x44)
		for k in 2:
			var face_index: int = memory.read_s16(DAT_00020b44 + 2 * k)
			if face_index == -1:
				continue
			var v0: int = C68kScript.u32(verts + memory.read_s16(memory.read_u32(C68kScript.u32(memory.read_u32(obj + 0x48) + face_index * 0x20) + 0x18)) * 12)
			var nrm: int = C68kScript.u32(verts + memory.read_s16(obj + 0x36) * 12 + face_index * 12)
			var plane: int = rec + 0x22 + 0xe * k
			memory.write_u16(plane, C68kScript.u16(face_index))
			memory.write_u16(plane + 2, C68kScript.u16(memory.read_u16(nrm + 2) - memory.read_u16(verts + 2)))
			memory.write_u16(plane + 4, C68kScript.u16(memory.read_u16(nrm + 6) - memory.read_u16(verts + 6)))
			memory.write_u16(plane + 6, C68kScript.u16(memory.read_u16(nrm + 0xa) - memory.read_u16(verts + 0xa)))
			for j in 3:
				memory.write_u16(plane + 8 + 2 * j, C68kScript.u16(C68kScript.asr32(C68kScript.s32(memory.read_u32(v0 + 4 * j) - memory.read_u32(obj + 0x18 + 4 * j)), memory.read_u16(rec + 0xc))))
	var plane_used: int
	if C68kScript.s32(v - memory.read_s16(rec + 0x1c)) < C68kScript.s32(u - memory.read_s16(rec + 0x18)):
		plane_used = rec + 0x22
		if memory.read_u16(rec + 0x20) != 0:
			memory.write_u16(changed, 1)
			memory.write_u16(rec + 0x20, 0)
	else:
		plane_used = rec + 0x30
		if memory.read_s16(rec + 0x20) != 1:
			memory.write_u16(changed, 1)
			memory.write_u16(rec + 0x20, 1)
	memory.write_u32(DAT_00020b48, C68kScript.u32(plane_used))
	var p2: int = memory.read_s16(plane_used + 4)
	if p2 == 0:
		return 0
	var num: int = C68kScript.s32(C68kScript.s32(-memory.read_s16(plane_used + 6) * C68kScript.s16(z - memory.read_u16(plane_used + 0xc))) - C68kScript.s16(x - memory.read_u16(plane_used + 8)) * memory.read_s16(plane_used + 2))
	var height: int = C68kScript.s32(C68kScript.divs_trunc(num, p2) + memory.read_s16(plane_used + 0xa))
	return 0 if height < 0 else height

## The ground height word written back to object a's controller (+0x2e, unscaled by the record's
## +0xa shift) when a has a controller and the height is non-zero; live play also clears its
## surface byte +0x2c.
func _store_terrain_ground(obj_a: int, rec: int, ground: int) -> void:
	if memory.read_u32(obj_a + 8) == 0 or C68kScript.s16(ground) == 0:
		return
	var shift: int = memory.read_s16(rec + 0xa)
	var value: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s16(ground), -shift)) if shift < 0 else C68kScript.asr32(C68kScript.s16(ground), shift)
	memory.write_u32(memory.read_u32(obj_a + 8) + 0x2e, C68kScript.u32(value))
	if memory.read_u16(DAT_0001b870) == 0:
		memory.write_u8(memory.read_u32(obj_a + 8) + 0x2c, 0)

## 0x14198: the player over fractal terrain b. Link a6 -4 and five registers (body 0x1c below).
## The contact record is found (0xc below) or, unless b is terrain (+6 bit 1) while a already
## holds a fractal reference (+0x2c), created (create_fractal_contact_record, 0xc below); its live
## word +8 = 1. The ground height at a's position relative to b (shifted by +0xa;
## fractal_height_at, 0x14 below, its changed flag in the frame at a6 - 2) goes to a's controller;
## a's fractal reference is released (8 below) and the record's triangle forgotten (+0x20 = -1).
func handle_terrain_contact(obj_a: int, obj_b: int) -> void:
	assert(memory != null, "handle_terrain_contact requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x1c
	a7 = body - 0xc
	var rec: int = find_contact_record(obj_a, obj_b)
	if rec == 0:
		if (memory.read_u8(obj_b + 6) & 2) != 0 and memory.read_u32(obj_a + 0x2c) != 0:
			a7 = entry_a7
			return
		rec = create_fractal_contact_record(obj_a, obj_b)
	a7 = entry_a7
	memory.write_u16(rec + 8, 1)
	var shift: int = memory.read_s16(rec + 0xa)
	var rx: int
	var rz: int
	if shift < 0:
		rx = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj_a + 0x18) - memory.read_u32(obj_b + 0x18)), -shift))
		rz = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj_a + 0x20) - memory.read_u32(obj_b + 0x20)), -shift))
	else:
		rx = C68kScript.s16(C68kScript.lsl32(C68kScript.s32(memory.read_u32(obj_a + 0x18) - memory.read_u32(obj_b + 0x18)), shift))
		rz = C68kScript.s16(C68kScript.lsl32(C68kScript.s32(memory.read_u32(obj_a + 0x20) - memory.read_u32(obj_b + 0x20)), shift))
	var changed: int = entry_a7 - 4 - 2
	memory.write_u16(changed, 0)
	a7 = body - 0x14
	var ground: int = fractal_height_at(rec, rx, rz, changed)
	a7 = entry_a7
	_store_terrain_ground(obj_a, rec, ground)
	if memory.read_u32(obj_a + 0x2c) != 0:
		a7 = body - 8
		release_fractal_reference(obj_a)
		a7 = entry_a7
	memory.write_u16(rec + 0x20, 0xffff)

## 0x14830: settle object obj on the terrain and hang it on a support point. Link a6 -4 and eight
## registers (body 0x28 below). An object below the ground (height < ground) without a fractal
## reference is raised by the ground (unscaled by the record shift +0xa): y, and - unless +5 bit 4
## - its vertices (translate_int3_vecs, dy asl +0x34, 0x1c below); unless +5 bit 3 its range +0xc
## follows the new camera metric (update_object_camera_metric, 8 below; the metric it stores makes
## the change 0) and its face extents +0x1c rise by dy; +5 bit 3 is set and the height becomes the
## ground. The support point: with a usable plane (cell_plane +4) the face centre of the record's
## triangle in the terrain's live vertices; otherwise a cell corner mix ((2 corner + other) / 3 per
## axis, by triangle), unrotated u - v / 2, unscaled and offset by the terrain position. The
## terrain's support list (+0x2c: count, capacity, pointers; created with capacity 5) gets the
## point, matched by x / z or created (heap_alloc_cleared 0x10, growing the list by 5 through
## heap_realloc_grow_only, 0xc below); obj leaves its old point (count - 1, deferred_free_flag)
## and holds the new one. Returns the height (word).
func lift_object_onto_terrain(rec: int, ground: int, height: int, obj: int, terrain: int) -> int:
	assert(memory != null, "lift_object_onto_terrain requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x28
	ground = C68kScript.s16(ground)
	height = C68kScript.s32(height)
	var shift: int = memory.read_s16(rec + 0xa)
	if height < ground and memory.read_u32(obj + 0x2c) == 0:
		var dy: int = C68kScript.s32(C68kScript.lsl32(ground, -shift)) if shift < 0 else C68kScript.asr32(ground, shift)
		memory.write_u32(obj + 0x1c, C68kScript.u32(memory.read_u32(obj + 0x1c) + dy))
		if (memory.read_u8(obj + 5) & 0x10) == 0:
			a7 = body - 0x1c
			translate_int3_vecs(memory.read_s16(obj + 0x36) + memory.read_s16(obj + 0x3a), memory.read_u32(obj + 0x44), memory.read_u32(obj + 0x44), 0, C68kScript.s32(C68kScript.lsl32(dy, memory.read_s16(obj + 0x34))), 0)
			a7 = entry_a7
		if (memory.read_u8(obj + 5) & 8) == 0:
			a7 = body - 8
			var metric: int = update_object_camera_metric(obj)
			a7 = entry_a7
			memory.write_u32(obj + 0xc, C68kScript.u32(C68kScript.s32(metric - memory.read_u32(obj + 0x10)) + memory.read_u32(obj + 0xc)))
			var face: int = C68kScript.u32(memory.read_u32(obj + 0x48) + 0x1c)
			for i in memory.read_u16(obj + 0x3a):
				memory.write_u32(face, C68kScript.u32(memory.read_u32(face) + dy))
				face = C68kScript.u32(face + 0x20)
		memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 8)
		height = ground
	var sx: int
	var sz: int
	if memory.read_u16(memory.read_u32(DAT_00020b48) + 4) != 0:
		var centres: int = C68kScript.u32(memory.read_u32(terrain + 0x44) + C68kScript.s32(memory.read_s16(terrain + 0x36) - memory.read_s16(terrain + 0x38)) * 12)
		var fi: int = memory.read_s16(rec + 0x22 + memory.read_s16(rec + 0x20) * 0xe)
		sx = memory.read_u32(C68kScript.u32(centres + fi * 12))
		sz = memory.read_u32(C68kScript.u32(centres + fi * 12 + 8))
	else:
		var su: int
		var sv: int
		if memory.read_u16(rec + 0x20) != 0:
			su = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(rec + 0x1a) + 2 * memory.read_s16(rec + 0x18)), 3))
			sv = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(rec + 0x1c) + 2 * memory.read_s16(rec + 0x1e)), 3))
		else:
			su = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(rec + 0x18) + 2 * memory.read_s16(rec + 0x1a)), 3))
			sv = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(rec + 0x1e) + 2 * memory.read_s16(rec + 0x1c)), 3))
		if memory.read_u16(rec + 0xe) == 0 and memory.read_u16(rec + 0x14) == 0:
			su = C68kScript.s16(su - ((sv + 1 if sv < 0 else sv) >> 1))
		if shift < 0:
			sx = C68kScript.u32(C68kScript.lsl32(su, -shift) + memory.read_u32(terrain + 0x18))
			sz = C68kScript.u32(C68kScript.lsl32(sv, -shift) + memory.read_u32(terrain + 0x20))
		else:
			sx = C68kScript.u32(C68kScript.asr32(su, shift) + memory.read_u32(terrain + 0x18))
			sz = C68kScript.u32(C68kScript.asr32(sv, shift) + memory.read_u32(terrain + 0x20))
	if memory.read_u32(terrain + 0x2c) == 0:
		a7 = body - 8
		var fresh: int = heap_alloc(0x1c)
		a7 = entry_a7
		memory.write_u16(fresh + 2, 5)
		memory.write_u16(fresh, 0)
		memory.write_u32(terrain + 0x2c, fresh)
	var old: int = memory.read_u32(obj + 0x2c)
	if old != 0:
		memory.write_u16(old, C68kScript.u16(memory.read_u16(old) - 1))
		memory.write_u16(DAT_0001c1bc, 1)
	var list: int = memory.read_u32(terrain + 0x2c)
	var support: int = 0
	var cursor: int = list + 4
	for i in memory.read_u16(list):
		var candidate: int = memory.read_u32(cursor)
		cursor += 4
		if memory.read_u32(candidate + 4) == sx and memory.read_u32(candidate + 8) == sz:
			support = candidate
			break
	if support == 0:
		a7 = body - 8
		support = heap_alloc_cleared(0x10)
		a7 = entry_a7
		memory.write_u32(support + 4, sx)
		memory.write_u32(support + 8, sz)
		if memory.read_u16(list + 2) == memory.read_u16(list):
			memory.write_u16(list + 2, C68kScript.u16(memory.read_u16(list + 2) + 5))
			a7 = body - 0xc
			list = heap_realloc_grow_only(list, C68kScript.s32(memory.read_s16(list + 2) * 4 + 8))
			a7 = entry_a7
			memory.write_u32(terrain + 0x2c, list)
		memory.write_u32(C68kScript.u32(list + 4 + memory.read_s16(list) * 4), support)
		memory.write_u16(list, C68kScript.u16(memory.read_u16(list) + 1))
	memory.write_u16(support, C68kScript.u16(memory.read_u16(support) + 1))
	memory.write_u32(obj + 0x2c, support)
	return C68kScript.s16(height)

## 0x13cdc: moving object a against fractal terrain b. Link a6 -4 and six registers (body 0x20
## below). Only within 0x33900 of b (z, and x skewed by z / 2) - then as handle_terrain_contact:
## record found or created (0xc below), height looked up (0x14 below) and stored. When the triangle
## changed, lift_object_onto_terrain (0x18 below) settles a and gives its height; a below the ground
## collides (dispatch_collision, 0xc below).
func test_terrain_collision(obj_a: int, obj_b: int) -> void:
	assert(memory != null, "test_terrain_collision requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x20
	var dz: int = C68kScript.s32(memory.read_u32(obj_a + 0x20) - memory.read_u32(obj_b + 0x20))
	var skew: int = C68kScript.s32(((dz + 1 if dz < 0 else dz) >> 1) + memory.read_u32(obj_a + 0x18) - memory.read_u32(obj_b + 0x18))
	if skew < -0x33900 or skew > 0x33900 or dz < -0x33900 or dz > 0x33900:
		return
	a7 = body - 0xc
	var rec: int = find_contact_record(obj_a, obj_b)
	if rec == 0:
		if (memory.read_u8(obj_b + 6) & 2) != 0 and memory.read_u32(obj_a + 0x2c) != 0:
			a7 = entry_a7
			return
		rec = create_fractal_contact_record(obj_a, obj_b)
	a7 = entry_a7
	memory.write_u16(rec + 8, 1)
	var shift: int = memory.read_s16(rec + 0xa)
	var rx: int
	var ry: int
	var rz: int
	if shift < 0:
		rx = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj_a + 0x18) - memory.read_u32(obj_b + 0x18)), -shift))
		ry = C68kScript.s16(C68kScript.asr32(memory.read_u32(obj_a + 0x1c), -shift))
		rz = C68kScript.s16(C68kScript.asr32(dz, -shift))
	else:
		rx = C68kScript.s16(C68kScript.lsl32(C68kScript.s32(memory.read_u32(obj_a + 0x18) - memory.read_u32(obj_b + 0x18)), shift))
		ry = C68kScript.s16(C68kScript.lsl32(memory.read_u32(obj_a + 0x1c), shift))
		rz = C68kScript.s16(C68kScript.lsl32(dz, shift))
	var changed: int = entry_a7 - 4 - 2
	memory.write_u16(changed, 0)
	a7 = body - 0x14
	var ground: int = C68kScript.s16(fractal_height_at(rec, rx, rz, changed))
	a7 = entry_a7
	_store_terrain_ground(obj_a, rec, ground)
	if memory.read_u16(changed) != 0:
		a7 = body - 0x18
		ry = C68kScript.s16(lift_object_onto_terrain(rec, ground, ry, obj_a, obj_b))
		a7 = entry_a7
	if ry < ground:
		a7 = body - 0xc
		dispatch_collision(obj_a, obj_b)
		a7 = entry_a7

## 0x5df8: each of the 7 scatter slots still holding an object sends it through
## dispatch_entity_cleanup (0x14 below) and is cleared.
func clear_pending_entity_slots() -> void:
	assert(memory != null, "clear_pending_entity_slots requires original global memory")
	var entry_a7: int = a7
	for k in 7:
		var obj: int = memory.read_u32(DAT_0001bc64 + 4 * k)
		if obj != 0:
			a7 = entry_a7 - 0x14
			dispatch_entity_cleanup(obj)
			a7 = entry_a7
			memory.write_u32(DAT_0001bc64 + 4 * k, 0)

## 0x947c: for the live controllers (word 0x1c1ca) whose object has byte +6 bit 5: the old position
## goes to controller +0x14..+0x1c, +0x2e is cleared and the object moves by the velocity +8..+0x10.
func apply_controller_velocities() -> void:
	assert(memory != null, "apply_controller_velocities requires original global memory")
	var slot: int = DAT_0001c25c
	for i in memory.read_u16(DAT_0001c1c8 + 2):
		var ctl: int = memory.read_u32(slot)
		slot += 4
		var obj: int = memory.read_u32(ctl)
		if obj == 0 or (memory.read_u8(obj + 6) & 0x20) == 0:
			continue
		for k in 3:
			memory.write_u32(ctl + 0x14 + 4 * k, memory.read_u32(obj + 0x18 + 4 * k))
		memory.write_u32(ctl + 0x2e, 0)
		for k in 3:
			memory.write_u32(obj + 0x18 + 4 * k, C68kScript.u32(memory.read_u32(obj + 0x18 + 4 * k) + memory.read_u32(ctl + 8 + 4 * k)))

## 0x94d2: compact the controller list (count word 0x1c1ce) to those still holding an object and
## run the tick (definition +2, 0x18 below) of those whose object has byte +5 bit 2. When entries
## were dropped, controllers the ticks appended (count long grew) are moved down after the kept ones
## and the count becomes the new length.
func tick_flagged_object_controllers() -> void:
	assert(memory != null, "tick_flagged_object_controllers requires original global memory")
	var entry_a7: int = a7
	var dst: int = DAT_0001c25c
	var src: int = DAT_0001c25c
	var old: int = memory.read_s16(DAT_0001c1cc + 2)
	for i in memory.read_u16(DAT_0001c1cc + 2):
		var ctl: int = memory.read_u32(src)
		src += 4
		var obj: int = memory.read_u32(ctl)
		if obj == 0:
			continue
		memory.write_u32(dst, ctl)
		dst += 4
		if (memory.read_u8(obj + 5) & 4) != 0 and memory.read_u32(memory.read_u32(ctl + 4) + 2) != 0:
			a7 = entry_a7 - 0x18
			_jsr(memory.read_u32(memory.read_u32(ctl + 4) + 2), [ctl])
			a7 = entry_a7
	var kept: int = C68kScript.s16(C68kScript.asr32(dst - DAT_0001c25c, 2))
	if old > kept:
		if old < memory.read_s32(DAT_0001c1cc):
			for i in (memory.read_u16(DAT_0001c1cc + 2) - old) & 0xffff:
				memory.write_u32(dst, memory.read_u32(src))
				dst += 4
				src += 4
		memory.write_u32(DAT_0001c1cc, C68kScript.u32(C68kScript.asr32(dst - DAT_0001c25c, 2)))

## 0x44a4: apply_entity_mission_rates (0x10 below); a type 5 object is hidden (+4 |= 0x40) unless
## host word +0xb0 is set (then shown).
func dispatch_entity_tick(entity: int, path: int) -> void:
	assert(memory != null, "dispatch_entity_tick requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x10
	apply_entity_mission_rates(entity, path)
	a7 = entry_a7
	var ctl: int = memory.read_u32(entity + 8)
	if ctl == 0 or memory.read_s16(memory.read_u32(ctl + 4)) != 5:
		return
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xb0) != 0:
		memory.write_u32(entity + 4, memory.read_u32(entity + 4) & 0xffffffbf)
	else:
		memory.write_u32(entity + 4, memory.read_u32(entity + 4) | 0x40)

## 0x1377a: age the 256 contact records: a record not touched this frame (+8 == 0) is freed and its
## slot cleared - first releasing object a's fractal reference when b is terrain (+6 bit 1) and a
## has +6 bit 5 (both 0x14 below); a touched one counts its +8 down.
func age_contact_records() -> void:
	assert(memory != null, "age_contact_records requires original global memory")
	var entry_a7: int = a7
	for k in 0x100:
		var slot: int = DAT_0001bdbc + 4 * k
		var rec: int = memory.read_u32(slot)
		if rec == 0:
			continue
		if memory.read_u16(rec + 8) != 0:
			memory.write_u16(rec + 8, C68kScript.u16(memory.read_u16(rec + 8) - 1))
			continue
		a7 = entry_a7 - 0x14
		var obj_a: int = memory.read_u32(rec)
		if (memory.read_u8(memory.read_u32(rec + 4) + 6) & 2) != 0 and (memory.read_u8(obj_a + 6) & 0x20) != 0 and memory.read_u32(obj_a + 0x2c) != 0:
			release_fractal_reference(obj_a)
		heap_free_coalesce(rec)
		a7 = entry_a7
		memory.write_u32(slot, 0)

## 0x739a: the camera sits on the player: position of the player's object, negated pitch / heading
## / bank (0x1d810 / 0x1d80e / 0x1d80c) and camera_angle4 = (type record +0x44 - controller +0x626)
## & 0x3fff (long).
func copy_player_pose_to_camera() -> void:
	assert(memory != null, "copy_player_pose_to_camera requires original global memory")
	var ctl: int = memory.read_u32(DAT_0001b738)
	for k in 3:
		memory.write_u32([DAT_0001d838, DAT_0001d834, DAT_0001d830][k], memory.read_u32(memory.read_u32(ctl) + 0x18 + 4 * k))
	memory.write_u16(DAT_0001d810, (-memory.read_u16(ctl + 0x20)) & 0x3fff)
	memory.write_u16(DAT_0001d80e, (-memory.read_u16(ctl + 0x22)) & 0x3fff)
	memory.write_u16(DAT_0001d80c, (-memory.read_u16(ctl + 0x24)) & 0x3fff)
	memory.write_u32(DAT_0001d808, C68kScript.s32(memory.read_s16(memory.read_u32(ctl + 4) + 0x44) - memory.read_s16(ctl + 0x626)) & 0x3fff)

## 0x88a0: put the camera 1000 units behind obj, away from point p (offsets (obj - p) asr shift as
## words; isqrt length, 0x24 below), raised 0xfa and moved 0xfa left; at zero length on p itself.
## Never below height 0xfa.
func place_camera_behind_object(obj: int, px: int, py: int, pz: int, shift: int) -> void:
	assert(memory != null, "place_camera_behind_object requires original global memory")
	var entry_a7: int = a7
	shift = C68kScript.s16(shift)
	var d: Array = []
	for k in 3:
		d.append(C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x18 + 4 * k) - [px, py, pz][k]), shift)))
	a7 = entry_a7 - 0x24
	var length: int = C68kScript.s16(isqrt_floor(C68kScript.s32(d[0] * d[0] + d[1] * d[1] + d[2] * d[2])))
	a7 = entry_a7
	if length == 0:
		memory.write_u32(DAT_0001d838, C68kScript.u32(px))
		memory.write_u32(DAT_0001d834, C68kScript.u32(py))
		memory.write_u32(DAT_0001d830, C68kScript.u32(pz))
	else:
		memory.write_u32(DAT_0001d838, C68kScript.u32(C68kScript.divs_trunc(d[0] * 1000, length) + memory.read_u32(obj + 0x18) - 0xfa))
		memory.write_u32(DAT_0001d834, C68kScript.u32(C68kScript.divs_trunc(d[1] * 1000, length) + memory.read_u32(obj + 0x1c) + 0xfa))
		memory.write_u32(DAT_0001d830, C68kScript.u32(C68kScript.divs_trunc(d[2] * 1000, length) + memory.read_u32(obj + 0x20)))
	if memory.read_s32(DAT_0001d834) <= 0xf9:
		memory.write_u32(DAT_0001d834, 0xfa)

## 0x8abe: turn the camera toward (x, y, z). Link a6 -4 and six registers (body 0x20 below). The
## offset from the camera, shifted until the camera metric (compute_camera_abs_metric, 0x10 below)
## fits 15 bits plus one, gives a pitch / heading (isqrt 8, attitude_from_velocity 0x24 below,
## frame words a6 - 2 / - 4). Folded differences from camera_pitch / camera_heading (8 / 0xc
## below): beyond 0x1000 either way (abs_int 0x10 / 8 below) the camera snaps to the new angles,
## else it turns a quarter of the way. The negated angles go to 0x1d810 / 0x1d80e; 0x1d80c and
## 0x1d808 are cleared.
func turn_camera_toward_point(x: int, y: int, z: int) -> void:
	assert(memory != null, "turn_camera_toward_point requires original global memory")
	assert(a7 != 0, "turn_camera_toward_point needs a7 (its frame holds the new angles)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x20
	a7 = body - 0x10
	var metric: int = compute_camera_abs_metric(x, y, z)
	a7 = entry_a7
	var shift: int = 0
	while (C68kScript.u32(metric) & 0xffff8000) != 0:
		shift = C68kScript.s16(shift + 1)
		metric = C68kScript.asr32(metric, 1)
	shift = C68kScript.s16(shift + 1)
	var dx: int = C68kScript.asr32(C68kScript.s32(x - memory.read_u32(DAT_0001d838)), shift)
	var dy: int = C68kScript.asr32(C68kScript.s32(y - memory.read_u32(DAT_0001d834)), shift)
	var dz: int = C68kScript.asr32(C68kScript.s32(z - memory.read_u32(DAT_0001d830)), shift)
	var sq: int = C68kScript.s32(C68kScript.s32(C68kScript.s32(dx * dx) + C68kScript.s32(dy * dy)) + C68kScript.s32(dz * dz))
	a7 = body - 8
	var length: int = C68kScript.s16(isqrt_floor(sq))
	a7 = body - 0x24
	attitude_from_velocity(dx, dy, dz, length, sq, a6 - 2, a6 - 4)
	a7 = body - 8
	var dp: int = fold_angle_pm_0x2000(C68kScript.s32(memory.read_s16(a6 - 2) - memory.read_s16(DAT_00024d1a)))
	a7 = body - 0xc
	var dh: int = fold_angle_pm_0x2000(C68kScript.s32(memory.read_s16(a6 - 4) - memory.read_s16(DAT_00024d18)))
	a7 = entry_a7
	if abs_int(dp) > 0x1000 or abs_int(dh) > 0x1000:
		memory.write_u16(DAT_00024d1a, memory.read_u16(a6 - 2) & 0x3fff)
		memory.write_u16(DAT_00024d18, memory.read_u16(a6 - 4) & 0x3fff)
	else:
		memory.write_u16(DAT_00024d1a, (((dp + 3 if dp < 0 else dp) >> 2) + memory.read_u16(DAT_00024d1a)) & 0x3fff)
		memory.write_u16(DAT_00024d18, (((dh + 3 if dh < 0 else dh) >> 2) + memory.read_u16(DAT_00024d18)) & 0x3fff)
	memory.write_u16(DAT_0001d810, (-memory.read_u16(DAT_00024d1a)) & 0x3fff)
	memory.write_u16(DAT_0001d80e, (-memory.read_u16(DAT_00024d18)) & 0x3fff)
	memory.write_u16(DAT_0001d80c, 0)
	memory.write_u32(DAT_0001d808, 0)

## Frame and saved-panel addresses of a radar blip row y - 1 at byte column col: frame = host +6
## + row bytes (+0x10) * (y - 1) + col, panel = host +0xdc - panel_back_offset + panel row bytes
## (+0xe0) * (y - 1) + col (muls.l).
func _blip_addresses(col: int, y: int) -> Array:
	var host: int = memory.read_u32(DAT_0001b5a0)
	var y1: int = C68kScript.s32(C68kScript.s16(y) - 1)
	var frame: int = C68kScript.u32(C68kScript.s32(memory.read_s16(host + 0x10) * y1) + memory.read_u32(host + 6) + col)
	var panel: int = C68kScript.u32(C68kScript.s32(memory.read_u32(host + 0xdc) - memory.read_u32(DAT_0001bd7c)) + C68kScript.s32(memory.read_s16(host + 0xe0) * y1) + col)
	return [frame, panel]

## The 12 bytes of an 8-bit blip around (x, y): rows y - 1 and y + 2 at x, x + 1; rows y and y + 1
## at x - 1 .. x + 2.
func _blip_cross8(x: int) -> Array:
	return [[0, 0], [0, 1], [1, -1], [1, 0], [1, 1], [1, 2], [2, -1], [2, 0], [2, 1], [2, 2], [3, 0], [3, 1]]

## 0x17780 (depth-8 *0x1da90): erase a radar blip on an 8-bit screen: the blip's 12 bytes come back
## from the saved panel.
func erase_radar_blip_depth8(x: int, y: int) -> void:
	assert(memory != null, "erase_radar_blip_depth8 requires original global memory")
	var host: int = memory.read_u32(DAT_0001b5a0)
	var at: Array = _blip_addresses(C68kScript.s16(x), y)
	for cell in _blip_cross8(x):
		memory.write_u8(at[0] + cell[0] * memory.read_s16(host + 0x10) + cell[1], memory.read_u8(at[1] + cell[0] * memory.read_s16(host + 0xe0) + cell[1]))

## 0x17810 (depth-8 *0x1da94; a second entry inside erase_radar_blip_depth8's extent): draw the
## blip's 12 bytes in the colour byte host +0x1e7.
func draw_radar_blip_depth8(x: int, y: int) -> void:
	assert(memory != null, "draw_radar_blip_depth8 requires original global memory")
	var host: int = memory.read_u32(DAT_0001b5a0)
	var frame: int = _blip_addresses(C68kScript.s16(x), y)[0]
	var colour: int = memory.read_u8(host + 0x1e7)
	for cell in _blip_cross8(x):
		memory.write_u8(frame + cell[0] * memory.read_s16(host + 0x10) + cell[1], colour)

## The byte column of a 4-bit pixel x (x / 2 toward zero) and its phase (x - that * 2, as words).
func _blip_column4(x: int) -> Array:
	x = C68kScript.s16(x)
	var rounded: int = x + 1 if x < 0 else x
	return [C68kScript.s16(rounded) >> 1, C68kScript.s16(x - C68kScript.s16(rounded & 0xfffe))]

## 0x17868 (depth-4 *0x1da90): erase a 4-bit blip from the saved panel. Odd phase: 2 bytes on each
## of the rows y - 1 .. y + 2; even: row y - 1 byte 0, rows y and y + 1 bytes -1 .. 1, row y + 2
## byte 0.
func erase_radar_blip_depth4(x: int, y: int) -> void:
	assert(memory != null, "erase_radar_blip_depth4 requires original global memory")
	var host: int = memory.read_u32(DAT_0001b5a0)
	var col: Array = _blip_column4(x)
	var at: Array = _blip_addresses(col[0], y)
	var cells: Array
	if col[1] != 0:
		cells = [[0, 0], [0, 1], [1, 0], [1, 1], [2, 0], [2, 1], [3, 0], [3, 1]]
	else:
		cells = [[0, 0], [1, -1], [1, 0], [1, 1], [2, -1], [2, 0], [2, 1], [3, 0]]
	for cell in cells:
		memory.write_u8(at[0] + cell[0] * memory.read_s16(host + 0x10) + cell[1], memory.read_u8(at[1] + cell[0] * memory.read_s16(host + 0xe0) + cell[1]))

## 0x17948 (depth-4 *0x1da94): draw a 4-bit blip in the colour byte (low byte of host word
## +0x1e6). Odd phase: rows y - 1 and y + 2 set the low nibble of byte 0 and high nibble of byte 1,
## rows y and y + 1 fill both bytes; even: row y - 1 byte 0 whole, rows y and y + 1 the low nibble of
## byte -1, byte 0 whole, the high nibble of byte 1, row y + 2 byte 0 whole.
func draw_radar_blip_depth4(x: int, y: int) -> void:
	assert(memory != null, "draw_radar_blip_depth4 requires original global memory")
	var host: int = memory.read_u32(DAT_0001b5a0)
	var row: int = memory.read_s16(host + 0x10)
	var col: Array = _blip_column4(x)
	var frame: int = _blip_addresses(col[0], y)[0]
	var colour: int = memory.read_u8(host + 0x1e7)
	var cells: Array
	if col[1] != 0:
		cells = [[0, 0, 0xf0], [0, 1, 0x0f], [1, 0, 0], [1, 1, 0], [2, 0, 0], [2, 1, 0], [3, 0, 0xf0], [3, 1, 0x0f]]
	else:
		cells = [[0, 0, 0], [1, -1, 0xf0], [1, 0, 0], [1, 1, 0x0f], [2, -1, 0xf0], [2, 0, 0], [2, 1, 0x0f], [3, 0, 0]]
	for cell in cells:
		var at: int = frame + cell[0] * row + cell[1]
		if cell[2] == 0:
			memory.write_u8(at, colour)
		else:
			memory.write_u8(at, ((memory.read_u8(at) ^ colour) & cell[2]) ^ colour)

## 0x17a34 (1-bit *0x1da90): the blip is a host rectangle call +0x276(x, y, x + 1, y + 1) (0x18
## below); the 1-bit draw (0x17a60) is the same call.
func erase_radar_blip_bw(x: int, y: int) -> void:
	assert(memory != null, "erase_radar_blip_bw requires original global memory")
	_blip_rect_bw(x, y)

## 0x17a60 (1-bit *0x1da94): host +0x276(x, y, x + 1, y + 1) (0x18 below).
func draw_radar_blip_bw(x: int, y: int) -> void:
	assert(memory != null, "draw_radar_blip_bw requires original global memory")
	_blip_rect_bw(x, y)

func _blip_rect_bw(x: int, y: int) -> void:
	var entry_a7: int = a7
	x = C68kScript.s16(x)
	y = C68kScript.s16(y)
	a7 = entry_a7 - 0x18
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x276), [C68kScript.u32(x), C68kScript.u32(y), C68kScript.u32(x + 1), C68kScript.u32(y + 1)])
	a7 = entry_a7

## 0x879e: how the bail-out ends. outcome = probe_nearest_facility_kind(player object) | 7 (0x10
## below); host word +0xd6 = 1. A parachute down below 0x373 that is still falling fast (+0x614 >
## 0x5a0) means a hard landing: host +0xd4 = 1 and the outcome's low byte becomes 1. Without a
## verdict yet: near an enemy facility (0x100) an even rng gives 3 (captured), else one in four 1;
## near a friendly one (0x200) one in eight 1; elsewhere one in four 1, else one in four 3 (rng 0xc
## below). The parachute's object is cleaned up (0x10 below); an intact abandoned aircraft with no
## verdict gives 4. Returns the outcome.
func resolve_bailout_outcome() -> int:
	assert(memory != null, "resolve_bailout_outcome requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x10
	var kind: int = C68kScript.u32(probe_nearest_facility_kind(memory.read_u32(memory.read_u32(DAT_0001b738))))
	a7 = entry_a7
	var outcome: int = kind | 7
	var host: int = memory.read_u32(DAT_0001b5a0)
	memory.write_u16(host + 0xd6, 1)
	var chute: int = memory.read_u32(DAT_0001b87c)
	if chute != 0 and memory.read_s32(memory.read_u32(chute) + 0x1c) <= 0x372 and memory.read_s16(chute + 0x614) > 0x5a0:
		memory.write_u16(host + 0xd4, 1)
		outcome = (outcome & 0xffffff00) | 1
	host = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(host + 0xd4) == 0:
		a7 = entry_a7 - 0xc
		var verdict: int = 0
		if (outcome & 0x100) != 0:
			if (overlay_rng_next() & 1) == 0:
				verdict = 3
			elif (overlay_rng_next() & 3) == 0:
				verdict = 1
		elif (outcome & 0x200) != 0:
			if (overlay_rng_next() & 7) == 0:
				verdict = 1
		elif (overlay_rng_next() & 3) == 0:
			verdict = 1
		elif (overlay_rng_next() & 3) == 0:
			verdict = 3
		a7 = entry_a7
		if verdict != 0:
			memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xd4, verdict)
	chute = memory.read_u32(DAT_0001b87c)
	if chute != 0:
		a7 = entry_a7 - 0x10
		dispatch_entity_cleanup(memory.read_u32(chute))
		a7 = entry_a7
	host = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(DAT_0001b87a) != 0 and memory.read_u16(host + 0xd4) == 0:
		memory.write_u16(host + 0xd4, 4)
	return C68kScript.u32(outcome)

## 0x8972: the camera while the player hangs under the parachute. No parachute, a dead one, or a
## landed one still moving fast resolves the bail-out (0x28 below) and returns its outcome. Early on
## (the chute appeared within 0x4b frames) or still high (more than 0x373 above its ground), with the
## player's aircraft within 0x9ab0 (0x3c below): the camera goes behind the chute away from the
## midpoint (place_camera_behind_object, shift = asr steps of the distance, 0x38 below) and looks at
## the midpoint; otherwise it takes the chute's next pose-ring position (index + 1, wrapping past
## 0x4a) and looks at the chute. turn_camera_toward_point 0x30 below; returns 0.
func update_bailout_view() -> int:
	assert(memory != null, "update_bailout_view requires original global memory")
	var entry_a7: int = a7
	var chute_ctl: int = memory.read_u32(DAT_0001b87c)
	if chute_ctl == 0 or (memory.read_u8(memory.read_u32(chute_ctl) + 7) & 2) != 0 or (memory.read_u16(chute_ctl + 0x61e) != 0 and memory.read_s16(chute_ctl + 0x614) > 0x5a0):
		a7 = entry_a7 - 0x28
		var outcome: int = resolve_bailout_outcome()
		a7 = entry_a7
		return outcome
	var chute: int = memory.read_u32(chute_ctl)
	var target: Array = [memory.read_u32(chute + 0x18), memory.read_u32(chute + 0x1c), memory.read_u32(chute + 0x20)]
	var placed: bool = false
	if memory.read_u32(DAT_0001b738) != 0 and (C68kScript.s32(memory.read_u32(DAT_0001b838) - 0x4b) <= memory.read_s32(chute + 0x40) or C68kScript.s32(memory.read_u32(chute + 0x1c) - memory.read_u32(chute_ctl + 0x2e)) > 0x373):
		var plane: int = memory.read_u32(memory.read_u32(DAT_0001b738))
		a7 = entry_a7 - 0x3c
		var dist: int = C68kScript.s32(approx_dist3_xyz(memory.read_s32(plane + 0x18), memory.read_s32(plane + 0x1c), memory.read_s32(plane + 0x20), memory.read_s32(chute + 0x18), memory.read_s32(chute + 0x1c), memory.read_s32(chute + 0x20)))
		a7 = entry_a7
		if dist <= 0x9ab0:
			for k in 3:
				var m: int = C68kScript.s32(memory.read_u32(plane + 0x18 + 4 * k) + memory.read_u32(chute + 0x18 + 4 * k))
				target[k] = C68kScript.u32((m + 1 if m < 0 else m) >> 1)
			var shift: int = 0
			while (C68kScript.u32(dist) & 0xffff8000) != 0:
				shift = C68kScript.s16(shift + 1)
				dist = C68kScript.asr32(dist, 1)
			a7 = entry_a7 - 0x38
			place_camera_behind_object(chute, target[0], target[1], target[2], shift)
			a7 = entry_a7
			placed = true
	if not placed:
		var slot: int = (memory.read_u16(chute_ctl + 0x60e) + 1) & 0xffff
		if slot > 0x4a:
			slot = (slot - 0x4b) & 0xffff
		var pose: int = C68kScript.u32(chute_ctl + 0x32 + C68kScript.s16(slot) * 0x14)
		memory.write_u32(DAT_0001d838, memory.read_u32(pose))
		memory.write_u32(DAT_0001d834, memory.read_u32(pose + 4))
		memory.write_u32(DAT_0001d830, memory.read_u32(pose + 8))
	a7 = entry_a7 - 0x30
	turn_camera_toward_point(target[0], target[1], target[2])
	a7 = entry_a7
	return 0

## A replay camera position: pose ring entry + the offset (vx, vy, vz) turned by the entry's heading
## word +0xe (build_attitude_matrix_3ang(0, heading, 0), transform in the frame: vector a6 - 0xc,
## matrix a6 - 0x1e).
func _replay_offset(pose: int, a6: int, body: int, vx: int, vy: int, vz: int) -> Array:
	var entry_a7: int = a7
	memory.write_u16(a6 - 6, C68kScript.u16(vy))
	memory.write_u16(a6 - 0xa, C68kScript.u16(vx))
	memory.write_u16(a6 - 2, C68kScript.u16(vz))
	a7 = body - 0x14
	build_attitude_matrix_3ang(0, memory.read_s16(pose + 0xe), 0, a6 - 0x1e)
	a7 = body - 0x24
	transform_vecs12_by_matrix3(1, a6 - 0xc, a6 - 0xc, a6 - 0x1e)
	a7 = entry_a7
	return [C68kScript.u32(memory.read_s16(a6 - 0xa) + memory.read_u32(pose)), C68kScript.u32(memory.read_s16(a6 - 6) + memory.read_u32(pose + 4)), C68kScript.u32(memory.read_s16(a6 - 2) + memory.read_u32(pose + 8))]

## 0x8ff4: start the instant replay. Link a6 -0x20 and five registers (body 0x38 below). View mode
## 8; a contact-tracked player object is untracked (8 below); update_view_clip_bounds (4 below).
## The camera starts 1000 behind the player's current pose-ring entry (+0x36 + 0x14 * word +0x612)
## along its heading; its goal is the previous entry (wrapping to 0x4a) offset (-0x2ee, 0x183,
## +-0x513: the side by replay_request == 1), at least 0x280 above the player's ground, reached in
## 75 steps (0x1d814..). Then: controller word +0x688 = 0, view mode 8, camera heading / pitch
## 0xc001, replay_request 0, replay_frames_left 0x69, replay_state 1, host word +0x98 = 1, a live
## view_follow_target becomes designated_entity_2, the follow target and target_hold_frames are
## cleared, and all sound stops (4 below).
func begin_replay_view() -> void:
	assert(memory != null, "begin_replay_view requires original global memory")
	assert(a7 != 0, "begin_replay_view needs a7 (its frame holds the offset and the matrix)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x38
	memory.write_u16(DAT_0001d858, 8)
	var ctl: int = memory.read_u32(DAT_0001b738)
	var obj: int = memory.read_u32(ctl)
	if (memory.read_u8(obj + 7) & 0x40) != 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)
		a7 = body - 8
		drop_contact_records_for_object(obj)
		a7 = entry_a7
	a7 = body - 4
	update_view_clip_bounds()
	a7 = entry_a7
	ctl = memory.read_u32(DAT_0001b738)
	var index: int = memory.read_s16(ctl + 0x612)
	var cam: Array = _replay_offset(C68kScript.u32(ctl + 0x36 + index * 0x14), a6, body, 0, 0, -1000)
	memory.write_u32(DAT_0001d838, cam[0])
	memory.write_u32(DAT_0001d834, cam[1])
	memory.write_u32(DAT_0001d830, cam[2])
	ctl = memory.read_u32(DAT_0001b738)
	var prev: int = C68kScript.s16(memory.read_s16(ctl + 0x612) - 1)
	if prev < 0:
		prev = 0x4a
	var side: int = -0x513 if memory.read_s16(DAT_0001b86c) == 1 else 0x513
	var goal: Array = _replay_offset(C68kScript.u32(ctl + 0x36 + prev * 0x14), a6, body, -0x2ee, 0x183, side)
	memory.write_u32(DAT_00024d20 + 8, goal[0])
	memory.write_u32(DAT_00024d20 + 4, goal[1])
	memory.write_u32(DAT_00024d20, goal[2])
	var floor_y: int = C68kScript.s32(memory.read_u32(memory.read_u32(DAT_0001b738) + 0x2e) + 0x280)
	if floor_y > memory.read_s32(DAT_00024d20 + 4):
		memory.write_u32(DAT_00024d20 + 4, C68kScript.u32(floor_y))
	memory.write_u32(DAT_0001d814 + 8, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(DAT_00024d20 + 8) - memory.read_u32(DAT_0001d838)), 0x4b)))
	memory.write_u32(DAT_0001d814 + 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(DAT_00024d20 + 4) - memory.read_u32(DAT_0001d834)), 0x4b)))
	memory.write_u32(DAT_0001d814, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(DAT_00024d20) - memory.read_u32(DAT_0001d830)), 0x4b)))
	memory.write_u16(memory.read_u32(DAT_0001b738) + 0x688, 0)
	memory.write_u16(DAT_0001d858, 8)
	memory.write_u16(DAT_00024d18, 0xc001)
	memory.write_u16(DAT_00024d1a, 0xc001)
	memory.write_u16(DAT_0001b86c, 0)
	memory.write_u16(DAT_0001b86e, 0x69)
	memory.write_u16(DAT_0001b870, 1)
	memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0x98, 1)
	var follow: int = memory.read_u32(DAT_0001b884)
	if follow != 0 and memory.read_u32(follow) != 0:
		memory.write_u32(DAT_0001b888, follow)
	memory.write_u32(DAT_0001b884, 0)
	memory.write_u32(DAT_00024d1c, 0)
	a7 = body - 4
	stop_all_sound_channels()
	a7 = entry_a7

## The forward point 0x4000 ahead along a controller's attitude (build_attitude_matrix_3ang 0x14,
## transform 0x24 below; vector a6 - 0xc, matrix a6 - 0x1e), as long offsets.
func _tracking_forward(ctl: int, a6: int, body: int, build_depth: int) -> Array:
	var entry_a7: int = a7
	memory.write_u16(a6 - 0xa, 0)
	memory.write_u16(a6 - 6, 0)
	memory.write_u16(a6 - 2, 0x4000)
	a7 = body - build_depth
	build_attitude_matrix_3ang(memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24), a6 - 0x1e)
	a7 = body - 0x24
	transform_vecs12_by_matrix3(1, a6 - 0xc, a6 - 0xc, a6 - 0x1e)
	a7 = entry_a7
	return [memory.read_s16(a6 - 0xa), memory.read_s16(a6 - 6), memory.read_s16(a6 - 2)]

## 0x8c30: the replay / end-sequence camera. Link a6 -0x2c and ten registers (body 0x58 below).
## Looking at: a live player shot (player_shot_ctl, once past its start frame), else - outside
## replay state 3, with a designated aircraft or a hold running - the midpoint between the player
## and the followed aircraft (a new hold of 20 frames follows designated_entity_2) within 0x9ab0
## (0x1c below): the camera goes behind the player or, when the designated aircraft heads within
## 0x1000 of the player (fold 8, abs 8 below) and its point 0x4000 ahead is nearer the player than
## the player's is to it (0x1c / 0x2c below), behind the aircraft (place_camera_behind_object 0x18
## below); the hold counts down while the followed one is not the designated one. Otherwise it
## looks at the player and, outside state 3, the camera glides by camera_step (re-aimed at the goal
## over frames_left - 0x1e frames when a follow just ended). replay_frames_left counts down; at
## 0x1e the state becomes 3 and at 0, unless host word +0x98 is 2, the result is -1 (not crashed),
## 1 (crashed, no parachute: host +0xd4 = 1) or the bail-out outcome (4 below); host +0x98 = 0.
## turn_camera_toward_point (0x10 below). Returns the result (word).
func update_tracking_camera() -> int:
	assert(memory != null, "update_tracking_camera requires original global memory")
	assert(a7 != 0, "update_tracking_camera needs a7 (its frame holds the forward vector)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x58
	var result: int = 0
	var look_obj: int = -1
	var tracked: bool = false
	var t: Array = [0, 0, 0]
	var shot: int = memory.read_u32(DAT_0001b880)
	if shot != 0 and memory.read_s32(memory.read_u32(shot) + 0x40) < memory.read_s32(DAT_0001b838):
		look_obj = memory.read_u32(shot)
	elif (memory.read_u32(DAT_0001b888) != 0 or memory.read_u32(DAT_00024d1c) != 0) and memory.read_s16(DAT_0001b870) != 3:
		if memory.read_u32(DAT_00024d1c) == 0:
			memory.write_u32(DAT_0001b884, memory.read_u32(DAT_0001b888))
			memory.write_u32(DAT_00024d1c, 0x14)
		var follow: int = memory.read_u32(DAT_0001b884)
		if follow != 0:
			var player_obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
			var target: int = memory.read_u32(follow)
			if target != 0:
				a7 = body - 0x1c
				var dist: int = C68kScript.s32(approx_dist3_xyz(memory.read_s32(player_obj + 0x18), memory.read_s32(player_obj + 0x1c), memory.read_s32(player_obj + 0x20), memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20)))
				a7 = entry_a7
				if dist <= 0x9ab0:
					tracked = true
					for k in 3:
						var m: int = C68kScript.s32(memory.read_u32(target + 0x18 + 4 * k) + memory.read_u32(player_obj + 0x18 + 4 * k))
						t[k] = C68kScript.u32((m + 1 if m < 0 else m) >> 1)
					var shift: int = 0
					while (C68kScript.u32(dist) & 0xffff8000) != 0:
						shift = C68kScript.s16(shift + 1)
						dist = C68kScript.asr32(dist, 1)
					var player_ctl: int = memory.read_u32(DAT_0001b738)
					a7 = body - 8
					var turn: int = fold_angle_pm_0x2000(C68kScript.s32(memory.read_s16(follow + 0x22) - memory.read_s16(player_ctl + 0x22)))
					a7 = entry_a7
					var anchor: int = player_obj
					if memory.read_u32(DAT_0001b888) != 0 and abs_int(turn) <= 0x1000:
						var f: Array = _tracking_forward(player_ctl, a6, body, 0x14)
						a7 = body - 0x1c
						var player_ahead: int = C68kScript.s32(approx_dist3_xyz(C68kScript.s32(f[0] + memory.read_u32(player_obj + 0x18)), C68kScript.s32(f[1] + memory.read_u32(player_obj + 0x1c)), C68kScript.s32(f[2] + memory.read_u32(player_obj + 0x20)), memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20)))
						a7 = entry_a7
						var g: Array = _tracking_forward(memory.read_u32(DAT_0001b884), a6, body, 0x2c)
						a7 = body - 0x2c
						var target_ahead: int = C68kScript.s32(approx_dist3_xyz(C68kScript.s32(g[0] + memory.read_u32(target + 0x18)), C68kScript.s32(g[1] + memory.read_u32(target + 0x1c)), C68kScript.s32(g[2] + memory.read_u32(target + 0x20)), memory.read_s32(player_obj + 0x18), memory.read_s32(player_obj + 0x1c), memory.read_s32(player_obj + 0x20)))
						a7 = entry_a7
						if target_ahead < player_ahead:
							anchor = target
					a7 = body - 0x18
					place_camera_behind_object(anchor, t[0], t[1], t[2], shift)
					a7 = entry_a7
					if memory.read_u32(DAT_0001b888) != memory.read_u32(DAT_0001b884):
						memory.write_u32(DAT_00024d1c, C68kScript.u32(memory.read_u32(DAT_00024d1c) - 1))
	if not tracked:
		if look_obj == -1:
			look_obj = memory.read_u32(memory.read_u32(DAT_0001b738))
		t = [memory.read_u32(look_obj + 0x18), memory.read_u32(look_obj + 0x1c), memory.read_u32(look_obj + 0x20)]
		if memory.read_s16(DAT_0001b870) != 3:
			if memory.read_u32(DAT_0001b884) != 0:
				var frames: int = C68kScript.s32(memory.read_s16(DAT_0001b86e) - 0x1e)
				assert(frames != 0, "update_tracking_camera: divs.l by zero traps")
				memory.write_u32(DAT_0001d814 + 8, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(DAT_00024d20 + 8) - memory.read_u32(DAT_0001d838)), frames)))
				memory.write_u32(DAT_0001d814 + 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(DAT_00024d20 + 4) - memory.read_u32(DAT_0001d834)), frames)))
				memory.write_u32(DAT_0001d814, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(DAT_00024d20) - memory.read_u32(DAT_0001d830)), frames)))
				memory.write_u32(DAT_0001b884, 0)
				memory.write_u32(DAT_00024d1c, 0)
			memory.write_u32(DAT_0001d838, C68kScript.u32(memory.read_u32(DAT_0001d838) + memory.read_u32(DAT_0001d814 + 8)))
			memory.write_u32(DAT_0001d834, C68kScript.u32(memory.read_u32(DAT_0001d834) + memory.read_u32(DAT_0001d814 + 4)))
			memory.write_u32(DAT_0001d830, C68kScript.u32(memory.read_u32(DAT_0001d830) + memory.read_u32(DAT_0001d814)))
	memory.write_u16(DAT_0001b86e, C68kScript.u16(memory.read_u16(DAT_0001b86e) - 1))
	if memory.read_s16(DAT_0001b86e) <= 0x1e:
		memory.write_u16(DAT_0001b870, 3)
		if memory.read_u16(DAT_0001b86e) == 0:
			var host: int = memory.read_u32(DAT_0001b5a0)
			if memory.read_s16(host + 0x98) != 2:
				if (memory.read_u8(memory.read_u32(DAT_0001b738) + 0x684) & 4) == 0:
					result = -1
				elif memory.read_u32(DAT_0001b87c) == 0:
					memory.write_u16(host + 0xd4, 1)
					result = 1
				else:
					a7 = body - 4
					result = C68kScript.s16(resolve_bailout_outcome())
					a7 = entry_a7
			memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0x98, 0)
	a7 = body - 0x10
	turn_camera_toward_point(t[0], t[1], t[2])
	a7 = entry_a7
	return C68kScript.s16(result)

## 0x6fb8: the six distance references (0x1d710..0x1d724) back to 100000000.
func reset_distance_base_globals() -> void:
	assert(memory != null, "reset_distance_base_globals requires original global memory")
	for off in [8, 0x14, 4, 0x10, 0, 0xc]:
		memory.write_u32(DAT_0001d710 + off, 100000000)

## 0x44e8: one simulation tick. Without host word +0xac the pending scatter slots are cleaned
## (0xc below). In mission phases 1..5 (host word +0xa8) every object of entity_array_1 and the
## object pool (path 0) and of entity_array_3 and _4 (path 1) goes through dispatch_entity_tick
## (0x14 below; counts re-read each step), then the distance references reset (0xc below).
func run_simulation_tick() -> void:
	assert(memory != null, "run_simulation_tick requires original global memory")
	var entry_a7: int = a7
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xac) == 0:
		a7 = entry_a7 - 0xc
		clear_pending_entity_slots()
		a7 = entry_a7
	var phase: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xa8)
	if phase <= 0 or phase > 5:
		return
	for pass_spec in [[DAT_0001d4a4, DAT_0001c1e0, 0], [DAT_0001b5a4, DAT_0001b734, 0], [DAT_0001d0e4, DAT_0001c1dc, 1], [DAT_0001cbe4, DAT_0001c1d8, 1]]:
		var i: int = 0
		while i < memory.read_s32(pass_spec[1]):
			a7 = entry_a7 - 0x14
			dispatch_entity_tick(memory.read_u32(pass_spec[0] + 4 * i), pass_spec[2])
			a7 = entry_a7
			i += 1
	a7 = entry_a7 - 0xc
	reset_distance_base_globals()
	a7 = entry_a7

## Replay visibility of one object (advance_frame_and_tick_controllers): not yet born (+0x40 after
## the frame) or already dead (+0x3c set and before the frame) -> hidden (+4 |= 0x40, 0x42 when
## dead); otherwise a hidden-by-flag one (+7 bit 1) loses 0x42, and one born this frame loses 0x40.
func _replay_visibility(obj: int, frame: int) -> void:
	var born: int = memory.read_s32(obj + 0x40)
	var dead: int = memory.read_s32(obj + 0x3c)
	if born > frame or (dead != 0 and dead < frame):
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | (0x42 if dead != 0 and dead < frame else 0x40))
	elif (memory.read_u8(obj + 7) & 2) != 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbd)
	elif born == frame:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)

## 0x92e4: next frame. The frame counter advances (a replay start, state 1, steps back 0x4a frames
## and marks the effect log end, 0x18 below). While replaying, shapes of entity_array_1 and the pool
## objects get their replay visibility and the logged effects of this frame come back (0x18 below).
## Then every controller still holding an object runs its definition tick (0x1c below) while the
## list is compacted (controllers appended by the ticks are moved down when some were dropped);
## live_controller_count = the kept count and apply_controller_velocities (0x18 below).
func advance_frame_and_tick_controllers() -> void:
	assert(memory != null, "advance_frame_and_tick_controllers requires original global memory")
	var entry_a7: int = a7
	memory.write_u32(DAT_0001b838, C68kScript.u32(memory.read_u32(DAT_0001b838) + 1))
	if memory.read_s16(DAT_0001b870) == 1:
		memory.write_u32(DAT_0001b838, C68kScript.u32(memory.read_u32(DAT_0001b838) - 0x4b))
		a7 = entry_a7 - 0x18
		mark_effect_log_end()
		a7 = entry_a7
	var old: int = memory.read_s16(DAT_0001c1cc + 2)
	if memory.read_u16(DAT_0001b870) != 0:
		var frame: int = memory.read_s32(DAT_0001b838)
		var slot: int = DAT_0001d4a4
		for i in memory.read_u16(DAT_0001c1e0 + 2):
			var entity: int = memory.read_u32(slot)
			slot += 4
			if memory.read_u8(entity) == 2:
				_replay_visibility(entity, frame)
		slot = DAT_0001b5a4
		for i in memory.read_u16(DAT_0001b734 + 2):
			_replay_visibility(memory.read_u32(slot), frame)
			slot += 4
		a7 = entry_a7 - 0x18
		replay_logged_effects()
		a7 = entry_a7
	var dst: int = DAT_0001c25c
	var src: int = DAT_0001c25c
	for i in old & 0xffff:
		var ctl: int = memory.read_u32(src)
		src += 4
		if memory.read_u32(ctl) == 0:
			continue
		memory.write_u32(dst, ctl)
		dst += 4
		var tick: int = memory.read_u32(memory.read_u32(ctl + 4) + 2)
		if tick != 0:
			a7 = entry_a7 - 0x1c
			_jsr(tick, [ctl])
			a7 = entry_a7
	var kept: int = C68kScript.s16(C68kScript.asr32(dst - DAT_0001c25c, 2))
	if old > kept:
		if old < memory.read_s32(DAT_0001c1cc):
			for i in (memory.read_u16(DAT_0001c1cc + 2) - old) & 0xffff:
				memory.write_u32(dst, memory.read_u32(src))
				dst += 4
				src += 4
		memory.write_u32(DAT_0001c1cc, C68kScript.u32(C68kScript.asr32(dst - DAT_0001c25c, 2)))
	memory.write_u32(DAT_0001c1c8, C68kScript.u32(kept))
	a7 = entry_a7 - 0x18
	apply_controller_velocities()
	a7 = entry_a7

## 0x19aa2: spawn cloud_templates[cls] at the camera + (dx, dy, dz) (spawn_mission_pool_object,
## 0x24 below; link a6 0 and four registers); its controller keeps the three angle words
## (+0x20 / +0x22 / +0x24, low words of the arguments), the offset (+0x32..+0x3a) and the class
## (+0x3e). Returns the controller, 0 when nothing was spawned.
func spawn_camera_relative_object(cls: int, dx: int, dy: int, dz: int, ang1: int, ang2: int, ang3: int) -> int:
	assert(memory != null, "spawn_camera_relative_object requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x14 - 0x24
	var obj: int = spawn_mission_pool_object(memory.read_u32(C68kScript.u32(DAT_00026784 + C68kScript.s32(cls) * 4)), C68kScript.u32(dx + memory.read_u32(DAT_0001d838)), C68kScript.u32(dy + memory.read_u32(DAT_0001d834)), C68kScript.u32(dz + memory.read_u32(DAT_0001d830)), 0, 0, 0, 0)
	a7 = entry_a7
	if obj == 0:
		return 0
	var ctl: int = memory.read_u32(obj + 8)
	memory.write_u16(ctl + 0x20, C68kScript.u16(ang1))
	memory.write_u16(ctl + 0x22, C68kScript.u16(ang2))
	memory.write_u16(ctl + 0x24, C68kScript.u16(ang3))
	memory.write_u32(ctl + 0x32, C68kScript.u32(dx))
	memory.write_u32(ctl + 0x36, C68kScript.u32(dy))
	memory.write_u32(ctl + 0x3a, C68kScript.u32(dz))
	memory.write_u16(ctl + 0x3e, C68kScript.u16(cls))
	return ctl

## 0x640c: the cloud layer. Link a6 -0x14 and eight registers (body 0x38 below). With clouds (host
## word +0xae) 10 clouds are placed: class = rng % 5 (divu.w remainder), a bearing (rng & 0xff) << 6
## redrawn until it lies at least 0x280 from every earlier one (fold 8, abs 0xc below; bearings in
## the frame at a6 - 0x14); class 4 (high cloud) at distance factor 15..24 and height 300000 + (rng
## & 0xfff) * 10, facing 0x4000; the others at factor 35..44 and height 0xcc4c + rng % 1000, facing
## 0x4000 - bearing; offset = factor * 0x339 * (sin, cos)(bearing) asr 6 (sin 8 / cos 0xc below);
## spawn_camera_relative_object (0x20 below). Without clouds every type 0x1d object of
## entity_array_1 retires (8 below). rng calls 4 below.
func spawn_cloud_layer() -> void:
	assert(memory != null, "spawn_cloud_layer requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x38
	var bearings: int = entry_a7 - 4 - 0x14
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xae) == 0:
		var n: int = 0
		while n < memory.read_s32(DAT_0001c1e0):
			var obj: int = memory.read_u32(DAT_0001d4a4 + n * 4)
			var ctl: int = memory.read_u32(obj + 8)
			if ctl != 0 and memory.read_s16(memory.read_u32(ctl + 4)) == 0x1d:
				a7 = body - 8
				retire_entity(obj)
				a7 = entry_a7
			n = C68kScript.s16(n + 1)
		return
	for n in 10:
		a7 = body - 4
		var cls: int = (overlay_rng_next() & 0xffff) % 5
		var bearing: int
		while true:
			bearing = C68kScript.s16(((overlay_rng_next() & 0xff) << 6))
			var j: int = 0
			while j < n:
				a7 = body - 8
				var turn: int = fold_angle_pm_0x2000(C68kScript.s32(bearing - memory.read_s16(bearings + 2 * j)))
				a7 = body - 0xc
				var far_apart: bool = abs_int(turn) > 0x27f
				a7 = body - 4
				if not far_apart:
					break
				j += 1
			if j == n:
				break
		memory.write_u16(bearings + 2 * n, C68kScript.u16(bearing))
		var factor: int
		var height: int
		if cls == 4:
			factor = (overlay_rng_next() & 0xffff) % 10 + 0xf
			height = (overlay_rng_next() & 0xfff) * 10 + 300000
		else:
			factor = (overlay_rng_next() & 0xffff) % 10 + 0x23
			height = (overlay_rng_next() & 0xffff) % 1000 + 0xcc4c
		a7 = body - 8
		var dx: int = C68kScript.asr32(C68kScript.s32(C68kScript.s16(sin_fixed14(bearing)) * 0x339 * factor), 6)
		a7 = body - 0xc
		var dz: int = C68kScript.asr32(C68kScript.s32(C68kScript.s16(cos_fixed14(bearing)) * 0x339 * factor), 6)
		if cls == 4:
			bearing = 0
		a7 = body - 0x20
		spawn_camera_relative_object(cls, dx, height, dz, 0, (0x4000 - bearing) & 0x3fff, 0)
		a7 = entry_a7

## A hidden (+7 bit 1), unreferenced (+3 == 0) far object is freed: its controller loses the object
## link, runs its definition destroy hook (+0xa) and is freed (0x30 below), then the object.
## Returns whether a controller was freed.
func _free_far_object(slot: int, entry_a7: int) -> bool:
	var freed_ctl: bool = false
	var ctl: int = memory.read_u32(memory.read_u32(slot) + 8)
	a7 = entry_a7 - 0x30
	if ctl != 0:
		memory.write_u32(ctl, 0)
		var hook: int = memory.read_u32(memory.read_u32(ctl + 4) + 0xa)
		if hook != 0:
			_jsr(hook, [ctl])
		heap_free_coalesce(ctl)
		freed_ctl = true
	heap_free_coalesce(memory.read_u32(slot))
	a7 = entry_a7
	return freed_ctl

## 0x5a14: per frame. The altitude band (0x1d70c, a power of two, log in word 0x1d704) follows the
## camera height (rebuilt when y leaves [band, 2 band)); the band value (table 0x1b214, plus the
## interpolation (y - band) * v asr log) becomes the y of the horizon objects' vertices
## (mission_child2or3 vertices 0..3, mission_child1 vertices 8 / 9). The camera metric to the near
## reference (0x1d724..) beyond 0xce40 (m + m / 8, 0x38 below) moves it to the camera; to the far
## reference (0x1d718..) beyond 0x80e80 moves both. A band change across 0xff or any reference move
## rebuilds every land outline (byte +6 bit 4 objects of entity_array_1: template pose 0x30, outline
## 0x40 below) at the band's tolerance (table 0x1b264 halved under 0x8000, * 0x16a1 / 4096, shifted
## back; limit 9/10 of it). After a reference move the very far list (entity_array_4, only on a far
## move) and the far list (entity_array_3) are re-sorted by metric - range (0x30 below): hidden
## unreferenced objects are freed with their controllers, very far ones (beyond 0x80e7f) go to /
## stay in entity_array_4, far ones (beyond 0xce3f) stay in entity_array_3, near ones are activated
## (activate_near_range_object). Freed controllers are compacted out of controller_list.
func update_altitude_detail_bands() -> void:
	assert(memory != null, "update_altitude_detail_bands requires original global memory")
	var entry_a7: int = a7
	var near_moved: bool = false
	var far_moved: bool = false
	var rebuild: bool = false
	var cam_y: int = memory.read_s32(DAT_0001d834)
	var band: int = memory.read_s32(DAT_0001d70c)
	if cam_y < band or not (C68kScript.s32(C68kScript.lsl32(band, 1)) > cam_y):
		var old_band: int = band
		var bits: int = 0
		var y: int = cam_y
		while y != 0:
			y = C68kScript.asr32(y, 1)
			bits += 1
		if bits != 0:
			memory.write_u32(DAT_0001d70c, C68kScript.u32(C68kScript.lsl32(1, bits - 1)))
			memory.write_u16(DAT_0001d704, C68kScript.u16(bits - 1))
		else:
			memory.write_u32(DAT_0001d70c, 0)
			memory.write_u16(DAT_0001d704, 0)
		if memory.read_s32(DAT_0001d70c) > 0xff or old_band > 0xff:
			rebuild = true
	var log2: int = memory.read_s16(DAT_0001d704)
	var value: int = memory.read_s32(C68kScript.u32(DAT_0001b214 + log2 * 4))
	if memory.read_u32(DAT_0001d70c) != 0:
		value = C68kScript.s32(value + C68kScript.asr32(C68kScript.s32(C68kScript.s32(memory.read_u32(DAT_0001d834) - memory.read_u32(DAT_0001d70c)) * value), log2))
	for k in 4:
		memory.write_u32(memory.read_u32(memory.read_u32(DAT_0001bdac) + 0x44) + 4 + 12 * k, C68kScript.u32(value))
	memory.write_u32(memory.read_u32(memory.read_u32(DAT_0001bdb0) + 0x44) + 0x64, C68kScript.u32(value))
	memory.write_u32(memory.read_u32(memory.read_u32(DAT_0001bdb0) + 0x44) + 0x70, C68kScript.u32(value))
	a7 = entry_a7 - 0x38
	var m: int = compute_camera_abs_metric(memory.read_s32(DAT_0001d710 + 0x14), memory.read_s32(DAT_0001d710 + 0x10), memory.read_s32(DAT_0001d710 + 0xc))
	a7 = entry_a7
	if C68kScript.s32(m + C68kScript.asr32(m, 3)) > 0xce40:
		near_moved = true
		rebuild = true
		memory.write_u32(DAT_0001d710 + 0x14, memory.read_u32(DAT_0001d838))
		memory.write_u32(DAT_0001d710 + 0x10, memory.read_u32(DAT_0001d834))
		memory.write_u32(DAT_0001d710 + 0xc, memory.read_u32(DAT_0001d830))
	a7 = entry_a7 - 0x38
	m = compute_camera_abs_metric(memory.read_s32(DAT_0001d710 + 8), memory.read_s32(DAT_0001d710 + 4), memory.read_s32(DAT_0001d710))
	a7 = entry_a7
	if C68kScript.s32(m + C68kScript.asr32(m, 3)) > 0x80e80:
		far_moved = true
		near_moved = true
		rebuild = true
		for k in 3:
			var c: int = memory.read_u32([DAT_0001d838, DAT_0001d834, DAT_0001d830][k])
			memory.write_u32(DAT_0001d710 + 0x14 - 4 * k, c)
			memory.write_u32(DAT_0001d710 + 8 - 4 * k, c)
	if rebuild:
		var v: int = memory.read_s32(C68kScript.u32(DAT_0001b264 + memory.read_s16(DAT_0001d704) * 4))
		var halvings: int = 0
		var w: int = v
		while w > 0x7fff:
			halvings += 1
			w = C68kScript.asr32(w, 1)
		var base: int = C68kScript.asr32(v, halvings)
		var limit: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(base * 9), 10))
		var tol: int = C68kScript.s32(base * 0x16a1)
		if tol < 0:
			tol = C68kScript.s32(tol + 0xfff)
		tol = C68kScript.s32(C68kScript.lsl32(C68kScript.asr32(tol, 12), C68kScript.s16(halvings)))
		var slot: int = DAT_0001d4a4
		for i in memory.read_u32(DAT_0001c1e0):
			var obj: int = memory.read_u32(slot)
			slot += 4
			if (memory.read_u8(obj + 6) & 0x10) == 0:
				continue
			a7 = entry_a7 - 0x30
			reset_object_to_template_pose(obj)
			a7 = entry_a7 - 0x40
			build_land_outline_at_detail(obj, tol, C68kScript.s16(halvings), limit)
			a7 = entry_a7
	if not near_moved:
		return
	var freed: bool = false
	if far_moved:
		var write: int = DAT_0001cbe4
		var read: int = DAT_0001cbe4
		var count3: int = memory.read_s32(DAT_0001c1dc)
		var i: int = 0
		while i < memory.read_s32(DAT_0001c1d8):
			var obj: int = memory.read_u32(read)
			if (memory.read_u8(obj + 7) & 2) != 0:
				if memory.read_u8(obj + 3) != 0:
					memory.write_u32(write, obj)
					write += 4
				elif _free_far_object(read, entry_a7):
					freed = true
				read += 4
			else:
				a7 = entry_a7 - 0x30
				var d: int = C68kScript.s32(update_object_camera_metric(obj) - memory.read_u32(memory.read_u32(read) + 0xc))
				a7 = entry_a7
				obj = memory.read_u32(read)
				if d > 0x80e7f:
					memory.write_u32(write, obj)
					write += 4
				else:
					memory.write_u32(C68kScript.u32(DAT_0001d0e4 + count3 * 4), obj)
					count3 += 1
				read += 4
			i += 1
		memory.write_u32(DAT_0001c1d8, C68kScript.u32(C68kScript.asr32(write - DAT_0001cbe4, 2)))
		memory.write_u32(DAT_0001c1dc, C68kScript.u32(count3))
	var write3: int = DAT_0001d0e4
	var read3: int = DAT_0001d0e4
	var j: int = 0
	while j < memory.read_s32(DAT_0001c1dc):
		var obj: int = memory.read_u32(read3)
		if (memory.read_u8(obj + 7) & 2) != 0:
			if memory.read_u8(obj + 3) != 0:
				memory.write_u32(write3, obj)
				write3 += 4
			elif _free_far_object(read3, entry_a7):
				freed = true
			read3 += 4
		else:
			a7 = entry_a7 - 0x30
			var d: int = C68kScript.s32(update_object_camera_metric(obj) - memory.read_u32(memory.read_u32(read3) + 0xc))
			a7 = entry_a7
			obj = memory.read_u32(read3)
			if d > 0x80e7f:
				memory.write_u32(C68kScript.u32(DAT_0001cbe4 + memory.read_s32(DAT_0001c1d8) * 4), obj)
				memory.write_u32(DAT_0001c1d8, C68kScript.u32(memory.read_u32(DAT_0001c1d8) + 1))
			elif d > 0xce3f:
				memory.write_u32(write3, obj)
				write3 += 4
			else:
				a7 = entry_a7 - 0x30
				activate_near_range_object(obj)
				a7 = entry_a7
			read3 += 4
		j += 1
	memory.write_u32(DAT_0001c1dc, C68kScript.u32(C68kScript.asr32(write3 - DAT_0001d0e4, 2)))
	if freed:
		var dst: int = DAT_0001c25c
		var src: int = DAT_0001c25c
		for i in memory.read_u32(DAT_0001c1cc):
			var ctl: int = memory.read_u32(src)
			src += 4
			if memory.read_u32(ctl) != 0:
				memory.write_u32(dst, ctl)
				dst += 4
		memory.write_u32(DAT_0001c1cc, C68kScript.u32(C68kScript.asr32(dst - DAT_0001c25c, 2)))

## 0x5e28: ground scatter (link.w a6,#-0x388, nine saved registers: calls are entered 0x3b0
## below the entry plus their pushes and the bsr). Off unless host word +0xac; height h = camera
## y, minus the player's +0x2e in views <= 5; above 0x26ac the 7 slots are cleared
## (clear_pending_entity_slots, once) and scatter_started drops. On first use (or with
## view_flag_d856) the 64 points are reset to x = z = 1000000000 and the slots' long +4 bit 2
## cleared. A point beyond 0x4d58 of the camera on x or z (abs_int) is re-placed: views <= 5
## without the reset flag on the 0x4d58 circle at the player heading +-0x600 (mulu, sin / cos
## muls.w), otherwise uniformly in the square (two draws, mulu 0x9ab0 >> 12); a slot it named
## (state 0xc0 | k, k != 0x3f) loses +4 bit 2 (index unbounded, as in the original), and the
## state byte becomes 0x3f. The points are then taken to view space in the frame (a6 - 0x300:
## translate_int3_vecs, transform_vecs12_by_matrix3 on the low words) and projected; on-screen
## points that were not get bit 7 and join the newly-visible list (a6 - 0x380, words; popped
## last first). Each slot k: a live object (+4 & 6 == 0) whose point no longer reads 0xc0 | k
## detaches (|= 0x3f when it still names k) and is hidden (+4 |= 0x40) when nothing is newly
## visible, else unhidden and moved; an empty slot takes a point when one is. Moving pops points
## until one's surface (cached, else surface_type_at_point(x, 0, z)) has a template; the point
## takes k, heading 0x540 on surface 0x10 else (r & 0xfff) * 4. A same-class object with
## vertices is re-placed in place (release_fractal_reference when +0x2c, word +6 |= 0x800, scene
## record x / 0 / z / heading, position from the template origin, vertices rebuilt, metric,
## band, shade); another is cleaned up first; an empty slot spawns
## spawn_mission_pool_object(template, x, y, z, 0, heading, 0, 0).
func update_ground_scatter_objects() -> void:
	assert(memory != null, "update_ground_scatter_objects requires original global memory")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var body: int = entry_a7 - 0x3b0
	var view_buf: int = a6 - 0x300
	var visible: int = a6 - 0x380
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xac) == 0:
		memory.write_u32(DAT_00024cec, 0)
		return
	var h: int = memory.read_s32(DAT_0001d834)
	if memory.read_s16(DAT_0001d858) <= 5:
		h = C68kScript.s32(h - memory.read_u32(memory.read_u32(DAT_0001b738) + 0x2e))
	if h > 0x26ac:
		if memory.read_u32(DAT_00024cec) == 0:
			return
		a7 = body - 4
		clear_pending_entity_slots()
		a7 = entry_a7
		memory.write_u32(DAT_00024cec, 0)
		return
	if memory.read_u32(DAT_00024cec) == 0:
		memory.write_u16(DAT_0001d856, 1)
		memory.write_u32(DAT_00024cec, 1)
	if memory.read_u16(DAT_0001d856) != 0:
		for i in 0x40:
			memory.write_u32(DAT_0001b924 + 12 * i, 1000000000)
			memory.write_u32(DAT_0001b924 + 12 * i + 8, 1000000000)
		for k in 7:
			var slot_obj: int = memory.read_u32(DAT_0001bc64 + 4 * k)
			if slot_obj != 0:
				memory.write_u32(slot_obj + 4, memory.read_u32(slot_obj + 4) & 0xfffffffb)
	var tmpl_base: int = C68kScript.u32(memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x28) + 0x1a)
	for i in 0x40:
		var pt: int = DAT_0001b924 + 12 * i
		a7 = body - 8
		var far: bool = abs_int(C68kScript.s32(memory.read_u32(pt) - memory.read_u32(DAT_0001d838))) > 0x4d58
		if not far:
			far = abs_int(C68kScript.s32(memory.read_u32(pt + 8) - memory.read_u32(DAT_0001d830))) > 0x4d58
		a7 = entry_a7
		if not far:
			continue
		if memory.read_s16(DAT_0001d858) <= 5 and memory.read_u16(DAT_0001d856) == 0:
			a7 = body - 4
			var r: int = overlay_rng_next()
			var bearing: int = C68kScript.u16(C68kScript.asr32(((r & 0xfff) * 0xc00) & 0xffffffff, 12) + memory.read_u16(memory.read_u32(DAT_0001b738) + 0x22) + 0xfa00) & 0x3fff
			a7 = body - 8
			var sin_v: int = sin_fixed14(bearing)
			a7 = body - 0xc
			var cos_v: int = cos_fixed14(bearing)
			a7 = entry_a7
			memory.write_u32(pt, C68kScript.u32(C68kScript.asr32(C68kScript.s16(sin_v) * -0x4d58, 12) + memory.read_s32(DAT_0001d838)))
			memory.write_u32(pt + 4, 0)
			memory.write_u32(pt + 8, C68kScript.u32(C68kScript.asr32(C68kScript.s16(cos_v) * 0x4d58, 12) + memory.read_s32(DAT_0001d830)))
		else:
			a7 = body - 4
			var rx: int = overlay_rng_next()
			a7 = entry_a7
			memory.write_u32(pt, C68kScript.u32(C68kScript.asr32((rx & 0xfff) * 0x9ab0, 12) + memory.read_s32(DAT_0001d838) - 0x4d58))
			memory.write_u32(pt + 4, 0)
			a7 = body - 4
			var rz: int = overlay_rng_next()
			a7 = entry_a7
			memory.write_u32(pt + 8, C68kScript.u32(C68kScript.asr32((rz & 0xfff) * 0x9ab0, 12) + memory.read_s32(DAT_0001d830) - 0x4d58))
		var state: int = memory.read_u8(DAT_0001b8e4 + i)
		if (state & 0xc0) == 0xc0 and (state & 0x3f) != 0x3f:
			var named: int = memory.read_u32(DAT_0001bc64 + 4 * (state & 0x3f))
			if named != 0:
				memory.write_u32(named + 4, memory.read_u32(named + 4) & 0xfffffffb)
		memory.write_u8(DAT_0001b8e4 + i, 0x3f)
	a7 = body - 0x1c
	translate_int3_vecs(0x40, DAT_0001b924, view_buf, C68kScript.s32(-memory.read_s32(DAT_0001d838)), C68kScript.s32(-h), C68kScript.s32(-memory.read_s32(DAT_0001d830)))
	a7 = body - 0x2c
	transform_vecs12_by_matrix3(0x40, view_buf, view_buf, DAT_0001d744)
	a7 = entry_a7
	var n_visible: int = 0
	for i in 0x40:
		var v: int = view_buf + 12 * i
		var vz: int = memory.read_s16(v + 0xa)
		var on_screen: bool = false
		if vz > 4:
			var sx: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(v + 2) * memory.read_s16(DAT_00020b28)), vz)
			var sy: int = C68kScript.divs_trunc(C68kScript.s32(-memory.read_s16(v + 6) * memory.read_s16(DAT_00020b26)), vz)
			on_screen = not (memory.read_s16(DAT_00020aee) > sx or memory.read_s16(DAT_00020aec) < sx
					or memory.read_s16(DAT_00020aea) > sy or memory.read_s16(DAT_0001b73e) < sy)
		if not on_screen:
			memory.write_u8(DAT_0001b8e4 + i, memory.read_u8(DAT_0001b8e4 + i) & 0x7f)
		elif memory.read_u8(DAT_0001b8e4 + i) < 0x80:
			memory.write_u8(DAT_0001b8e4 + i, memory.read_u8(DAT_0001b8e4 + i) | 0x80)
			memory.write_u16(visible + 2 * n_visible, i)
			n_visible += 1
	for k in 7:
		var obj: int = memory.read_u32(DAT_0001bc64 + 4 * k)
		if obj != 0:
			if (memory.read_u32(obj + 4) & 6) != 0:
				continue
			var own: int = memory.read_s16(DAT_0001b894 + 2 * k)
			var own_state: int = memory.read_u8(C68kScript.u32(DAT_0001b8e4 + own))
			if own_state == (k | 0xc0):
				continue
			if (own_state & 0x3f) == k:
				memory.write_u8(C68kScript.u32(DAT_0001b8e4 + own), own_state | 0x3f)
			if n_visible == 0:
				memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
				continue
			memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)
		# Pop newly visible points until one's surface has a template.
		var point: int = 0
		var surface: int = 0
		var template: int = 0
		while n_visible != 0:
			n_visible -= 1
			point = memory.read_s16(visible + 2 * n_visible)
			if (memory.read_u8(DAT_0001b8e4 + point) & 0x40) != 0:
				surface = memory.read_u8(DAT_0001b8a4 + point)
			else:
				var pt0: int = DAT_0001b924 + 12 * point
				a7 = body - 0x10
				surface = C68kScript.s16(surface_type_at_point(memory.read_s32(pt0), 0, memory.read_s32(pt0 + 8)))
				a7 = entry_a7
				memory.write_u8(DAT_0001b8a4 + point, surface & 0xff)
				memory.write_u8(DAT_0001b8e4 + point, memory.read_u8(DAT_0001b8e4 + point) | 0x40)
			template = memory.read_u32(C68kScript.u32(DAT_0001bc24 + C68kScript.asr32(surface, 4) * 4))
			if template != 0:
				break
		if template == 0:
			continue
		var pt: int = DAT_0001b924 + 12 * point
		memory.write_u8(DAT_0001b8e4 + point, (memory.read_u8(DAT_0001b8e4 + point) & 0xc0) | k)
		memory.write_u16(DAT_0001b894 + 2 * k, point)
		var heading: int
		if C68kScript.s16(surface) == 0x10:
			heading = 0x540
		else:
			a7 = body - 4
			heading = C68kScript.asr32(C68kScript.lsl32(overlay_rng_next() & 0xfff, 6), 4)
			a7 = entry_a7
		if obj == 0:
			a7 = body - 0x24
			memory.write_u32(DAT_0001bc64 + 4 * k, C68kScript.u32(spawn_mission_pool_object(template, memory.read_s32(pt), memory.read_s32(pt + 4), memory.read_s32(pt + 8), 0, C68kScript.s16(heading), 0, 0)))
			a7 = entry_a7
		elif memory.read_u8(obj + 1) == memory.read_u8(template + 1) and memory.read_u32(obj + 0x44) != 0:
			if memory.read_u32(obj + 0x2c) != 0:
				a7 = body - 8
				release_fractal_reference(obj)
				a7 = entry_a7
			memory.write_u16(obj + 6, memory.read_u16(obj + 6) | 0x800)
			var rec: int = C68kScript.u32(memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30) + memory.read_u8(obj + 2) * 0x18)
			memory.write_u32(rec + 8, memory.read_u32(pt))
			memory.write_u32(rec + 0xc, 0)
			memory.write_u32(rec + 0x10, memory.read_u32(pt + 8))
			memory.write_u16(rec + 4, C68kScript.u16(heading))
			var desc: int = C68kScript.u32(memory.read_u32(C68kScript.u32(tmpl_base + 0x14 + memory.read_u8(obj + 1) * 0x18)) + memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c))
			memory.write_u32(obj + 0x18, C68kScript.u32(memory.read_u32(pt) + memory.read_u32(desc + 2)))
			memory.write_u32(obj + 0x1c, memory.read_u32(desc + 6))
			memory.write_u32(obj + 0x20, C68kScript.u32(memory.read_u32(pt + 8) + memory.read_u32(desc + 0xa)))
			var n: int = C68kScript.s32(memory.read_s16(obj + 0x36) + memory.read_s16(obj + 0x3a))
			if (memory.read_u8(obj + 5) & 0x10) != 0:
				a7 = body - 0x1c
				translate_int3_vecs(n, C68kScript.u32(desc + 0x22), memory.read_u32(obj + 0x44), 0, 0, 0)
			else:
				a7 = body - 0x14
				apply_template_chain_xform(obj, n, C68kScript.u32(desc + 0x22), memory.read_u32(obj + 0x44))
			a7 = body - 8
			update_object_camera_metric(obj)
			a7 = body - 0x10
			update_object_distance_band(obj, memory.read_s32(obj + 0x10))
			a7 = entry_a7
			_call_shade_object_faces(obj, 0x3b0 + 0x14)
		else:
			a7 = body - 8
			dispatch_entity_cleanup(obj)
			a7 = body - 0x28
			memory.write_u32(DAT_0001bc64 + 4 * k, C68kScript.u32(spawn_mission_pool_object(template, memory.read_s32(pt), memory.read_s32(pt + 4), memory.read_s32(pt + 8), 0, C68kScript.s16(heading), 0, 0)))
			a7 = entry_a7

## 0x32: memmove_block(src, dst, n) (entered 0x14 below: d2, three arguments, bsr); returns dst.
func copy_block_return_dst(dst: int, src: int, nbytes: int) -> int:
	var entry_a7: int = a7
	a7 = entry_a7 - 0x14
	memmove_block(src, dst, nbytes)
	a7 = entry_a7
	return dst

## 0x334: 1 when any of the twelve kill-count words host +0xba .. +0xd0 is non-zero, else 0.
func any_mission_kills_recorded() -> int:
	assert(memory != null, "any_mission_kills_recorded requires original global memory")
	var world: int = memory.read_u32(DAT_0001b5a0)
	var last: int = C68kScript.u32(world + 0x16)
	var a0: int = world
	while true:
		if memory.read_u16(a0 + 0xba) != 0:
			return 1
		a0 = C68kScript.u32(a0 + 2)
		if not (C68kScript.s32(last) >= C68kScript.s32(a0)):
			return 0
	return 0

## 0x229e: an attitude matrix from a direction (x, y, z) and a roll angle. Pitch cos / sin =
## (horizontal length, -y) << 12 / length (isqrt_floor of the s32-wrapping squares, entered 0x78 /
## 0x7c below); heading cos / sin = (z, x) << 12 / horizontal length, or (0x1000, 0) when
## level_flag; roll by cos / sin_fixed14. The globals angle1..3 cos / sin take them; the frame
## (link.w a6,#-0x4c) holds Rx (a6 - 0x12), Ry (- 0x24), Rz (- 0x36) and Ry * Rx (- 0x48);
## out = (Ry * Rx) * Rz by matmul3x3_s16 (entered 0x88 / 0x94 below). Returns its D0.
func build_attitude_matrix_from_dir_roll(x: int, y: int, z: int, roll: int, out: int, level_flag: int) -> int:
	assert(memory != null, "build_attitude_matrix_from_dir_roll requires original global memory")
	assert(a7 != 0, "build_attitude_matrix_from_dir_roll needs a7 (its frame holds the matrices)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var rx: int = a6 - 0x12
	var ry: int = a6 - 0x24
	var rz: int = a6 - 0x36
	var ryx: int = a6 - 0x48
	var xx: int = C68kScript.s32(x * x)
	var zz: int = C68kScript.s32(z * z)
	a7 = entry_a7 - 0x78
	var horiz: int = C68kScript.s16(isqrt_floor(C68kScript.s32(xx + zz)))
	a7 = entry_a7 - 0x7c
	var length: int = C68kScript.s16(isqrt_floor(C68kScript.s32(C68kScript.s32(xx + C68kScript.s32(y * y)) + zz)))
	a7 = entry_a7
	memory.write_u16(DAT_0001d7fa, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(horiz, 12)), length)))
	memory.write_u16(DAT_0001d7fc, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.s32(-y), 12)), length)))
	if level_flag != 0:
		memory.write_u16(DAT_0001d7f6, 0x1000)
		memory.write_u16(DAT_0001d7f8, 0)
	else:
		memory.write_u16(DAT_0001d7f6, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(z, 12)), horiz)))
		memory.write_u16(DAT_0001d7f8, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(x, 12)), horiz)))
	a7 = entry_a7 - 0x78
	memory.write_u16(DAT_0001d7f2, C68kScript.u16(cos_fixed14(roll)))
	a7 = entry_a7 - 0x7c
	var sin_v: int = sin_fixed14(roll)
	a7 = entry_a7
	memory.write_u16(DAT_0001d7f4, C68kScript.u16(sin_v))
	var c1: int = memory.read_u16(DAT_0001d7fa)
	var s1: int = memory.read_u16(DAT_0001d7fc)
	var c2: int = memory.read_u16(DAT_0001d7f6)
	var s2: int = memory.read_u16(DAT_0001d7f8)
	var c3: int = memory.read_u16(DAT_0001d7f2)
	var s3: int = memory.read_u16(DAT_0001d7f4)
	var words: Array = [
		[rx, [0x1000, 0, 0, 0, c1, C68kScript.u16(-s1), 0, s1, c1]],
		[ry, [c2, 0, s2, 0, 0x1000, 0, C68kScript.u16(-s2), 0, c2]],
		[rz, [c3, C68kScript.u16(sin_v), 0, C68kScript.u16(-s3), c3, 0, 0, 0, 0x1000]]]
	for m in words:
		for k in 9:
			memory.write_u16(m[0] + 2 * k, m[1][k])
	a7 = entry_a7 - 0x88
	matmul3x3_s16(ry, rx, ryx)
	a7 = entry_a7 - 0x94
	var d0: int = matmul3x3_s16(ryx, rz, out)
	a7 = entry_a7
	return d0

## 0x27a2: negate the angle1 / angle2 / angle3 / angle4 sines, then run the composer named by
## attitude_compose_tag (its alt, transposed form) on out (entered 8 below).
func invoke_tagged_attitude_compose_neg_sins4(out: int):
	assert(memory != null, "invoke_tagged_attitude_compose_neg_sins4 requires original global memory")
	for g in [DAT_0001d7fc, DAT_0001d7f8, DAT_0001d7f4, DAT_0001d7f0]:
		memory.write_u16(g, C68kScript.u16(-memory.read_u16(g)))
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	var result = _jsr(memory.read_u32(DAT_00020ce4), [out])
	a7 = entry_a7
	return result

## 0x27cc: as invoke_tagged_attitude_compose_neg_sins4, also negating the angle5 / angle6 sines.
func invoke_tagged_attitude_compose_neg_sins6(out: int):
	assert(memory != null, "invoke_tagged_attitude_compose_neg_sins6 requires original global memory")
	for g in [DAT_0001d7fc, DAT_0001d7f8, DAT_0001d7f4, DAT_0001d7f0, DAT_0001d7ec, DAT_0001d7e8]:
		memory.write_u16(g, C68kScript.u16(-memory.read_u16(g)))
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	var result = _jsr(memory.read_u32(DAT_00020ce4), [out])
	a7 = entry_a7
	return result

## 0x28a6: build_attitude_matrix_3ang(a1, a2, a3) into the frame (link.w a6,#-0x14: matrix at
## a6 - 0x12, entered 0x30 below), then transform_int3_vecs_by_matrix3(count, src, dst, matrix)
## (entered 0x40 below). Returns its D0.
func rotate_int3_vecs_by_3ang(angle1: int, angle2: int, angle3: int, count: int, src: int, dst: int) -> int:
	assert(a7 != 0, "rotate_int3_vecs_by_3ang needs a7 (its frame holds the matrix)")
	var entry_a7: int = a7
	var matrix: int = entry_a7 - 4 - 0x12
	a7 = entry_a7 - 0x30
	build_attitude_matrix_3ang(angle1, angle2, angle3, matrix)
	a7 = entry_a7 - 0x40
	var d0: int = transform_int3_vecs_by_matrix3(count, src, dst, matrix)
	a7 = entry_a7
	return d0

## 0x41ec: a shape (byte 0 == 2) gets update_object_distance_band(obj, +0x10) (0x10 below) and
## shade_object_faces (0x14 below).
func recolour_kind2_object(obj: int) -> void:
	assert(memory != null, "recolour_kind2_object requires original global memory")
	if memory.read_u8(obj) != 2:
		return
	var entry_a7: int = a7
	a7 = entry_a7 - 0x10
	update_object_distance_band(obj, memory.read_s32(obj + 0x10))
	a7 = entry_a7
	_call_shade_object_faces(obj, 0x14)

## 0x6ece: panels_drawn = 0.
func clear_flag_00020ae4() -> void:
	memory.write_u16(DAT_00020ae4, 0)

## 0x9ae0: 1 when face normal vi of the prepared object faces away from the eye: (normal - vertex
## 0) . (eye - (first face vertex asr vertex_shift)), word subtractions and muls.w products
## summed in 32 bits, is <= 0; else 0.
func face_is_back_facing(vi: int, face: int) -> int:
	assert(memory != null, "face_is_back_facing requires original global memory")
	var n: int = C68kScript.u32(vi * 12 + memory.read_u32(DAT_00024d4a))
	var dx: int = C68kScript.s16(memory.read_u16(n + 2) - memory.read_u16(DAT_00024d4e + 2))
	var dy: int = C68kScript.s16(memory.read_u16(n + 6) - memory.read_u16(DAT_00024d4e + 6))
	var dz: int = C68kScript.s16(memory.read_u16(n + 0xa) - memory.read_u16(DAT_00024d4e + 0xa))
	var obj: int = memory.read_u32(DAT_00025b24)
	var v: int = C68kScript.u32(memory.read_s16(memory.read_u32(face + 0x18)) * 12 + memory.read_u32(obj + 0x44))
	var shift: int = memory.read_s16(DAT_00024d5a)
	var ex: int = C68kScript.s16(memory.read_s16(DAT_00024d60) - C68kScript.s16(C68kScript.asr32(memory.read_s32(v), shift)))
	var ey: int = C68kScript.s16(memory.read_s16(DAT_00024d5e) - C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 4), shift)))
	var ez: int = C68kScript.s16(memory.read_s16(DAT_00024d5c) - C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 8), shift)))
	var dot: int = C68kScript.s32(C68kScript.s32(dx * ex + dy * ey) + dz * ez)
	return 1 if dot <= 0 else 0

## 0xb460: when background_rows is set, each of the sext word host +0x18c view rows gets the
## span (0, 1, view_width, fill_colour) as words.
func reset_background_rows() -> void:
	assert(memory != null, "reset_background_rows requires original global memory")
	if memory.read_u32(DAT_00020ad4) == 0:
		return
	var row: int = memory.read_u32(DAT_00020ad4)
	var i: int = 0
	while memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x18c) > i:
		memory.write_u16(row, 0)
		memory.write_u16(row + 2, 1)
		memory.write_u16(row + 4, memory.read_u16(DAT_0001b82a))
		memory.write_u16(row + 6, memory.read_u16(DAT_0001daa0))
		row = C68kScript.u32(row + 8)
		i += 1

## 0xb49e: reset_background_rows and reset_radar_tracks (each entered 4 below), then
## heading_tape_pos = 1 and readouts_drawn = 0.
func reset_overlay_display_state() -> void:
	assert(memory != null, "reset_overlay_display_state requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 4
	reset_background_rows()
	reset_radar_tracks()
	a7 = entry_a7
	memory.write_u16(DAT_00025ffe, 1)
	memory.write_u16(DAT_00025ffc, 0)

## 0xe3b2: the angle between two vectors given with their lengths: 0 when (|a| * |b|) asr 16
## is 0, else acos_fixed14(((a . b) asr 4) divs.l that) (entered 0x14 below), sign-extended.
## Products are muls.l (32-bit wrap).
func acos_scaled_dot3(ax: int, ay: int, az: int, a_len: int, bx: int, by: int, bz: int, b_len: int) -> int:
	var scale: int = C68kScript.asr32(C68kScript.s32(a_len * b_len), 16)
	if scale == 0:
		return 0
	var dot: int = C68kScript.s32(C68kScript.s32(C68kScript.s32(ax * bx) + C68kScript.s32(ay * by)) + C68kScript.s32(az * bz))
	var entry_a7: int = a7
	a7 = entry_a7 - 0x14
	var r: int = acos_fixed14(C68kScript.divs_trunc(C68kScript.asr32(dot, 4), scale))
	a7 = entry_a7
	return C68kScript.s16(r)

## 0xc572: draw one instrument needle from (cx, cy) to (ex, ey); five saved registers. With host
## word +0x9e the host line routine (+0x272)(sext word +0xe4, cx, cy, ex, ey) draws it (0x2c
## below). Otherwise, once the readouts are drawn, an unchanged end returns 0 and a changed one
## first restores the old line through depth_routine_da98(cx, cy, old x, old y, host +6, sext
## word +0x10, host +0xdc - panel_back_offset, sext word +0xe0) (0x38 below); then
## depth_routine_da9c(cx, cy, ex, ey, sext word +0xe4, host +6, sext word +0x10) (0x34 below).
## The end is cached per instrument type (needle_end_x / _y); returns 1.
func draw_gauge_needle(kind: int, cx: int, cy: int, ex: int, ey: int) -> int:
	assert(memory != null, "draw_gauge_needle requires original global memory")
	var entry_a7: int = a7
	var world: int = memory.read_u32(DAT_0001b5a0)
	var slot_x: int = C68kScript.u32(DAT_00025f4a + kind * 4)
	var slot_y: int = C68kScript.u32(DAT_00025f92 + kind * 4)
	if memory.read_u16(world + 0x9e) != 0:
		a7 = entry_a7 - 0x2c
		_jsr(memory.read_u32(world + 0x272), [memory.read_s16(world + 0xe4), cx, cy, ex, ey])
	else:
		if memory.read_u16(DAT_00025ffc) != 0:
			if memory.read_s32(slot_x) == C68kScript.s32(ex) and memory.read_s32(slot_y) == C68kScript.s32(ey):
				return 0
			world = memory.read_u32(DAT_0001b5a0)
			a7 = entry_a7 - 0x38
			_jsr(memory.read_u32(DAT_0001da98), [cx, cy, memory.read_s32(slot_x), memory.read_s32(slot_y), memory.read_s32(world + 6),
					memory.read_s16(world + 0x10), C68kScript.s32(memory.read_u32(world + 0xdc) - memory.read_u32(DAT_0001bd7c)), memory.read_s16(world + 0xe0)])
		world = memory.read_u32(DAT_0001b5a0)
		a7 = entry_a7 - 0x34
		_jsr(memory.read_u32(DAT_0001da9c), [cx, cy, ex, ey, memory.read_s16(world + 0xe4), memory.read_s32(world + 6), memory.read_s16(world + 0x10)])
	a7 = entry_a7
	memory.write_u32(slot_x, C68kScript.u32(ex))
	memory.write_u32(slot_y, C68kScript.u32(ey))
	return 1

## The needle end offsets for an angle: (cos, sin) * sext word length asr 12 (muls.w), with
## cos / sin_fixed14 entered cos_depth / cos_depth + 4 below the caller's entry.
func _needle_offsets(angle: int, length_word: int, entry_a7: int, cos_depth: int) -> Array:
	a7 = entry_a7 - cos_depth
	var c: int = C68kScript.s16(cos_fixed14(angle))
	a7 = entry_a7 - cos_depth - 4
	var sn: int = C68kScript.s16(sin_fixed14(angle))
	a7 = entry_a7
	var length: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + length_word)
	return [C68kScript.asr32(c * length, 12), C68kScript.asr32(sn * length, 12)]

## draw_gauge_needle entered depth below the caller's entry.
func _call_draw_gauge_needle(entry_a7: int, depth: int, kind: int, cx: int, cy: int, ex: int, ey: int) -> int:
	a7 = entry_a7 - depth
	var r: int = draw_gauge_needle(kind, C68kScript.s32(cx), C68kScript.s32(cy), C68kScript.s32(ex), C68kScript.s32(ey))
	a7 = entry_a7
	return r

## A dial centre (host words at off, off + 2, each minus 1, as address-register longs).
func _dial_centre(off: int) -> Array:
	var world: int = memory.read_u32(DAT_0001b5a0)
	return [memory.read_s16(world + off) - 1, memory.read_s16(world + off + 2) - 1]

## 0xc664: altimeter. Long hand (type 0): angle ((camera y rems 10000) << 14 divs 10000) +
## 0xf000; when it was drawn, the short hand at 2/3 length: angle ((y rems 100000) << 14 divs
## 100000) + 0xf000, through the host line routine (+0x272, 0x34 below) or depth_routine_da98
## (restore the cached end alt_short_end, when the readouts are drawn; 0x40 below) and
## depth_routine_da9c (0x3c below); its end is cached. Seven saved registers.
func update_altimeter_needles() -> void:
	assert(memory != null, "update_altimeter_needles requires original global memory")
	var entry_a7: int = a7
	var y: int = memory.read_s32(DAT_0001d834)
	var angle: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.rems_trunc(y, 0x2710), 14)), 0x2710) + 0xf000) & 0x3fff
	var centre: Array = _dial_centre(0xf0)
	var off: Array = _needle_offsets(angle, 0xf4, entry_a7, 0x24)
	if _call_draw_gauge_needle(entry_a7, 0x3c, 0, centre[0], centre[1], centre[0] + off[0], centre[1] + off[1]) == 0:
		return
	angle = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(C68kScript.rems_trunc(memory.read_s32(DAT_0001d834), 0x186a0), 14)), 0x186a0) + 0xf000) & 0x3fff
	a7 = entry_a7 - 0x24
	var c: int = C68kScript.s16(cos_fixed14(angle))
	var world: int = memory.read_u32(DAT_0001b5a0)
	var dx: int = C68kScript.asr32(C68kScript.s32(C68kScript.divs_trunc(memory.read_s16(world + 0xf4) * 2, 3) * c), 12)
	a7 = entry_a7 - 0x28
	var sn: int = C68kScript.s16(sin_fixed14(angle))
	a7 = entry_a7
	world = memory.read_u32(DAT_0001b5a0)
	var dy: int = C68kScript.asr32(C68kScript.s32(C68kScript.divs_trunc(memory.read_s16(world + 0xf4) * 2, 3) * sn), 12)
	var cx: int = centre[0]
	var cy: int = centre[1]
	var ex: int = C68kScript.s32(cx + dx)
	var ey: int = C68kScript.s32(cy + dy)
	if memory.read_u16(world + 0x9e) != 0:
		a7 = entry_a7 - 0x34
		_jsr(memory.read_u32(world + 0x272), [memory.read_s16(world + 0xe4), cx, cy, ex, ey])
	else:
		if memory.read_u16(DAT_00025ffc) != 0:
			world = memory.read_u32(DAT_0001b5a0)
			a7 = entry_a7 - 0x40
			_jsr(memory.read_u32(DAT_0001da98), [cx, cy, memory.read_s32(DAT_00025fda), memory.read_s32(DAT_00025fde), memory.read_s32(world + 6),
					memory.read_s16(world + 0x10), C68kScript.s32(memory.read_u32(world + 0xdc) - memory.read_u32(DAT_0001bd7c)), memory.read_s16(world + 0xe0)])
		world = memory.read_u32(DAT_0001b5a0)
		a7 = entry_a7 - 0x3c
		_jsr(memory.read_u32(DAT_0001da9c), [cx, cy, ex, ey, memory.read_s16(world + 0xe4), memory.read_s32(world + 6), memory.read_s16(world + 0x10)])
	a7 = entry_a7
	memory.write_u32(DAT_00025fda, C68kScript.u32(ex))
	memory.write_u32(DAT_00025fde, C68kScript.u32(ey))

## 0xc80c: airspeed (type 1) from player +0x62a: above 0x3843 it wraps down by 0x3843; then
## three linear pieces ((v << 14) divs 0xb409 up to 0xb40, ((v - 0x5a0) << 14) divs 0x5a04 up to
## 0x10e0, else ((v - 0xb41) << 14) divs 0x2d02), + 0xf000. Four saved registers.
func update_airspeed_needle() -> void:
	assert(memory != null, "update_airspeed_needle requires original global memory")
	var entry_a7: int = a7
	var v: int = memory.read_s32(memory.read_u32(DAT_0001b738) + 0x62a)
	if v > 0x3843:
		v = C68kScript.s32(v - 0x3843)
	var d0: int
	if v <= 0xb40:
		d0 = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(v, 14)), 0xb409)
	elif v <= 0x10e0:
		d0 = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(v - 0x5a0, 14)), 0x5a04)
	else:
		d0 = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(v - 0xb41, 14)), 0x2d02)
	var angle: int = C68kScript.u16(d0 + 0xf000) & 0x3fff
	_simple_needle(entry_a7, angle, 0x100, 0x18, 1)

## Centre at host word off (and off + 2), length word off + 4; cos entered cos_depth below,
## draw_gauge_needle cos_depth + 0x18 below (two pushed angles and five arguments).
func _simple_needle(entry_a7: int, angle: int, off: int, cos_depth: int, kind: int) -> void:
	var centre: Array = _dial_centre(off)
	var o: Array = _needle_offsets(angle, off + 4, entry_a7, cos_depth)
	_call_draw_gauge_needle(entry_a7, cos_depth + 0x18, kind, centre[0], centre[1], centre[0] + o[0], centre[1] + o[1])

## 0xc8d6: direction (type 6): angle neg_camera_heading + 0xf000 (word), dial at host +0x150.
func update_direction_needle() -> void:
	assert(memory != null, "update_direction_needle requires original global memory")
	_simple_needle(a7, C68kScript.u16(memory.read_u16(DAT_0001d80e) + 0xf000) & 0x3fff, 0x150, 0x18, 6)

## 0xc948: climb (type 3): (climb_rate divs 0x78) - 0x2000, dial at host +0x120.
func update_climb_needle() -> void:
	assert(memory != null, "update_climb_needle requires original global memory")
	_simple_needle(a7, C68kScript.u32(C68kScript.divs_trunc(memory.read_s32(DAT_0001bc80), 0x78) - 0x2000) & 0x3fff, 0x120, 0x18, 3)

## 0xc9c2: tachometer (type 5): ((player +0x66a << 6) divs 0x23a) + 0x1540, dial at host +0x140.
func update_tachometer_needle() -> void:
	assert(memory != null, "update_tachometer_needle requires original global memory")
	var rpm: int = memory.read_s32(memory.read_u32(DAT_0001b738) + 0x66a)
	_simple_needle(a7, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(rpm, 6)), 0x23a) + 0x1540) & 0x3fff, 0x140, 0x18, 5)

## 0xca44: manifold (type 4): ((sext word player +0x672 << 6) divs 0x5f) - 0x2500, dial at host
## +0x130.
func update_manifold_needle() -> void:
	assert(memory != null, "update_manifold_needle requires original global memory")
	var mp: int = memory.read_s16(memory.read_u32(DAT_0001b738) + 0x672)
	_simple_needle(a7, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(mp, 6)), 0x5f) - 0x2500) & 0x3fff, 0x130, 0x18, 4)

## 0xcac6: bomb lamp. high = (player object y - player +0x2e) > 0x43; unless the readouts are
## drawn with the same bomb count (sext byte player +0x67c) and flag, both are cached and the
## host lamp routine (+0x29e)(high, count > 0 ? word +0x200 : word +0x1fc, count > 1 ? +0x200 :
## +0x1fc) runs (0x1c below; three saved registers).
func update_bomb_indicator() -> void:
	assert(memory != null, "update_bomb_indicator requires original global memory")
	var player: int = memory.read_u32(DAT_0001b738)
	var high: int = 1 if C68kScript.s32(memory.read_u32(memory.read_u32(player) + 0x1c) - memory.read_u32(player + 0x2e)) > 0x43 else 0
	if memory.read_u16(DAT_00025ffc) != 0 and memory.read_s8(player + 0x67c) == memory.read_s16(DAT_00025fe2) and high == memory.read_s16(DAT_00025fe4):
		return
	memory.write_u16(DAT_00025fe2, C68kScript.u16(memory.read_s8(memory.read_u32(DAT_0001b738) + 0x67c)))
	memory.write_u16(DAT_00025fe4, high)
	var world: int = memory.read_u32(DAT_0001b5a0)
	var on: int = memory.read_s16(world + 0x200)
	var off: int = memory.read_s16(world + 0x1fc)
	var count: int = memory.read_s16(DAT_00025fe2)
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	_jsr(memory.read_u32(world + 0x29e), [high, on if count > 0 else off, on if count > 1 else off])
	a7 = entry_a7

## 0xcb62: throttle bar. Unless the readouts are drawn with the same setting (sext byte player
## +0x668), it is cached and the host rectangle routine (+0x28e) fills two rectangles from the
## host rectangle at +0x202 (frame copy at a6 - 8, link.w a6,#-8): bottom = bottom - (height *
## setting) divs 9 with colour word +0x20a (0x24 below), then top = that value with colour
## word +0x20c (0x2c below).
func update_throttle_gauge() -> void:
	assert(memory != null, "update_throttle_gauge requires original global memory")
	assert(a7 != 0, "update_throttle_gauge needs a7 (its frame holds the rectangle)")
	if memory.read_u16(DAT_00025ffc) != 0 and memory.read_s8(memory.read_u32(DAT_0001b738) + 0x668) == memory.read_s16(DAT_00025fe6):
		return
	memory.write_u16(DAT_00025fe6, C68kScript.u16(memory.read_s8(memory.read_u32(DAT_0001b738) + 0x668)))
	var entry_a7: int = a7
	var rect: int = entry_a7 - 4 - 8
	var world: int = memory.read_u32(DAT_0001b5a0)
	var height: int = C68kScript.s16(memory.read_u16(world + 0x206) - memory.read_u16(world + 0x202))
	memory.write_u32(rect, memory.read_u32(world + 0x202))
	memory.write_u32(rect + 4, memory.read_u32(world + 0x206))
	var cut: int = C68kScript.divs_trunc(C68kScript.s32(height * memory.read_s16(DAT_00025fe6)), 9)
	var level: int = C68kScript.u16(memory.read_u16(rect + 4) - cut)
	memory.write_u16(rect + 4, level)
	a7 = entry_a7 - 0x24
	_jsr(memory.read_u32(world + 0x28e), [rect, memory.read_s16(world + 0x20a)])
	world = memory.read_u32(DAT_0001b5a0)
	memory.write_u32(rect, memory.read_u32(world + 0x202))
	memory.write_u32(rect + 4, memory.read_u32(world + 0x206))
	memory.write_u16(rect, level)
	a7 = entry_a7 - 0x2c
	_jsr(memory.read_u32(world + 0x28e), [rect, memory.read_s16(world + 0x20c)])
	a7 = entry_a7

## 0xcc12: flaps (type 0xa). Unless the readouts are drawn with the same byte player +0x67b, it
## is cached; angle ((-abs_int(flaps) muls.l 0xac0) divs 15) + 0x2000 (abs_int 0x18, cos 0x1c,
## needle 0x38 below; four saved registers), dial at host +0x20e.
func update_flaps_needle() -> void:
	assert(memory != null, "update_flaps_needle requires original global memory")
	if memory.read_u16(DAT_00025ffc) != 0 and memory.read_s8(memory.read_u32(DAT_0001b738) + 0x67b) == memory.read_s16(DAT_00025fe8):
		return
	var flaps: int = memory.read_s8(memory.read_u32(DAT_0001b738) + 0x67b)
	memory.write_u16(DAT_00025fe8, C68kScript.u16(flaps))
	var entry_a7: int = a7
	a7 = entry_a7 - 0x18
	var mag: int = abs_int(flaps)
	a7 = entry_a7
	var angle: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.s32(-mag) * 0xac0), 15) + 0x2000) & 0x3fff
	var centre: Array = _dial_centre(0x20e)
	var o: Array = _needle_offsets(angle, 0x212, entry_a7, 0x1c)
	_call_draw_gauge_needle(entry_a7, 0x38, 0xa, centre[0], centre[1], centre[0] + o[0], centre[1] + o[1])

## 0xccca: gear (types 0xb / 0xc / 0xd), nine saved registers. Unless the readouts are drawn with
## the same byte player +0x679, it is cached; angle (abs_int(gear) << 12) divs 0x2d (abs_int 0x2c
## below). Needles at host +0x214 (end centre + offset; cos 0x30, needle 0x48 below), +0x21a
## (x mirrored; cos 0x2c, needle 0x44) and +0x220 (cos 0x48 with the previous arguments still
## pushed, sin 0x2c after the pop; needle 0x40).
func update_gear_needles() -> void:
	assert(memory != null, "update_gear_needles requires original global memory")
	if memory.read_u16(DAT_00025ffc) != 0 and memory.read_s8(memory.read_u32(DAT_0001b738) + 0x679) == memory.read_s16(DAT_00025fea):
		return
	var gear: int = memory.read_s8(memory.read_u32(DAT_0001b738) + 0x679)
	memory.write_u16(DAT_00025fea, C68kScript.u16(gear))
	var entry_a7: int = a7
	a7 = entry_a7 - 0x2c
	var mag: int = abs_int(gear)
	a7 = entry_a7
	var angle: int = C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(mag, 12)), 0x2d) & 0x3fff
	var c1: Array = _dial_centre(0x214)
	var o1: Array = _needle_offsets(angle, 0x218, entry_a7, 0x30)
	_call_draw_gauge_needle(entry_a7, 0x48, 0xb, c1[0], c1[1], c1[0] + o1[0], c1[1] + o1[1])
	var c2: Array = _dial_centre(0x21a)
	var o2: Array = _needle_offsets(angle, 0x21e, entry_a7, 0x2c)
	_call_draw_gauge_needle(entry_a7, 0x44, 0xc, c2[0], c2[1], c2[0] - o2[0], c2[1] + o2[1])
	var c3: Array = _dial_centre(0x220)
	a7 = entry_a7 - 0x48
	var c: int = C68kScript.s16(cos_fixed14(angle))
	a7 = entry_a7 - 0x2c
	var sn: int = C68kScript.s16(sin_fixed14(angle))
	a7 = entry_a7
	var length: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x224)
	_call_draw_gauge_needle(entry_a7, 0x40, 0xd, c3[0], c3[1], c3[0] + C68kScript.asr32(c * length, 12), c3[1] + C68kScript.asr32(sn * length, 12))

## 0xce1c: ammo (type 0xf). Unless the readouts are drawn with the same word player +0x682, it
## is cached; angle sext word ((count muls.w 0x1555) divs 0x2a3 + 0x555) (not masked: the sine
## tables mask), dial at host +0x232, end centre - offset. Four saved registers.
func update_ammo_needle() -> void:
	assert(memory != null, "update_ammo_needle requires original global memory")
	if memory.read_u16(DAT_00025ffc) != 0 and memory.read_u16(memory.read_u32(DAT_0001b738) + 0x682) == memory.read_u16(DAT_00025fec):
		return
	memory.write_u16(DAT_00025fec, memory.read_u16(memory.read_u32(DAT_0001b738) + 0x682))
	var entry_a7: int = a7
	var angle: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(DAT_00025fec) * 0x1555), 0x2a3) + 0x555)
	var centre: Array = _dial_centre(0x232)
	var o: Array = _needle_offsets(angle, 0x236, entry_a7, 0x18)
	_call_draw_gauge_needle(entry_a7, 0x30, 0xf, centre[0], centre[1], centre[0] - o[0], centre[1] - o[1])

## 0xcec4: fuel (types 0x10 / 0x11), nine saved registers. Unless the readouts are drawn with the
## same tank bytes player +0x67d / +0x67e, both are cached; capacity = word (player +4) +0x1c
## halved toward zero; angle ((tank muls.w 0x1555) divs capacity) + 0xf555. Left needle at host
## +0x226 (end x + offset, y - offset; cos 0x2c, needle 0x44 below), right at +0x22c (end centre
## - offset; cos 0x48 with the left arguments still pushed, sin 0x2c; needle 0x40).
func update_fuel_needles() -> void:
	assert(memory != null, "update_fuel_needles requires original global memory")
	var player: int = memory.read_u32(DAT_0001b738)
	if memory.read_u16(DAT_00025ffc) != 0 and memory.read_s8(player + 0x67d) == memory.read_s16(DAT_00025fee) and memory.read_s8(player + 0x67e) == memory.read_s16(DAT_00025ff0):
		return
	memory.write_u16(DAT_00025fee, C68kScript.u16(memory.read_s8(player + 0x67d)))
	memory.write_u16(DAT_00025ff0, C68kScript.u16(memory.read_s8(player + 0x67e)))
	var cap: int = memory.read_s16(memory.read_u32(player + 4) + 0x1c)
	if cap < 0:
		cap = C68kScript.s16(cap + 1)
	cap = C68kScript.s16(cap >> 1)
	var entry_a7: int = a7
	var angle: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(DAT_00025fee) * 0x1555), cap) + 0xf555) & 0x3fff
	var c1: Array = _dial_centre(0x226)
	var o1: Array = _needle_offsets(angle, 0x22a, entry_a7, 0x2c)
	_call_draw_gauge_needle(entry_a7, 0x44, 0x10, c1[0], c1[1], c1[0] + o1[0], c1[1] - o1[1])
	angle = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(DAT_00025ff0) * 0x1555), cap) + 0xf555) & 0x3fff
	var c2: Array = _dial_centre(0x22c)
	a7 = entry_a7 - 0x48
	var c: int = C68kScript.s16(cos_fixed14(angle))
	a7 = entry_a7 - 0x2c
	var sn: int = C68kScript.s16(sin_fixed14(angle))
	a7 = entry_a7
	var length: int = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x230)
	_call_draw_gauge_needle(entry_a7, 0x40, 0x11, c2[0], c2[1], c2[0] - C68kScript.asr32(c * length, 12), c2[1] - C68kScript.asr32(sn * length, 12))

## 0x1a75e: the length of the zero-terminated string at text (dbeq / bne scan: the D0 count
## never ends the scan).
func c_strlen(text: int) -> int:
	assert(memory != null, "c_strlen requires original global memory")
	var a0: int = text
	while memory.read_u8(a0) != 0:
		a0 = C68kScript.u32(a0 + 1)
	return C68kScript.s32(a0 - text)

## 0xd00c (link.w a6,#-0x64, nine saved registers). Panels not drawn yet (panels_drawn == 0): the
## numeric readouts. The subject is designated_entity_2 in view 7 (mode7 = 1), else the player;
## readouts_drawn = 0; then view_inset (word) passes run through dbra. Inset 4 first resets:
## readout_index = 0, host text routine (+0x27a)(0, 0, 0, 0, 1, mode7) (0xa8 below), inset = 1,
## the four cached values = 0x7fff, and the count register becomes 4 (five passes in all). Each
## pass takes readout_index (an index above 3 keeps the previous value, as in the original):
## 0 altitude (object y divs 10), 1 speed ((+0x62a divs 0x12) / 4 toward zero), 2 heading (0x168
## - ((word +0x22 * 0x168) / 256 / 64 toward zero)), 3 climb (((climb_rate divs 0x78) * 0x258) /
## 64 toward zero divs 0x76). In view 7 readout 3 is skipped. A value differing from the cache
## caches its magnitude and is printed into the frame (a6 - 0x64: digits backwards from index 9,
## terminator at 10, a degree sign 0xa1 for the heading, '-' when negative), measured by
## c_strlen (0xa0 below) and sent to the text routine (text, index, 0, length, 0, mode7). The
## index then advances modulo 4. Panels drawn: the panel copy offset (host word +0xe2 * +0xe0)
## is set when the readouts are not drawn; without the host line routine (word +0x9e) the sky /
## ground and the heading tape are drawn (hide_cursor; 0x94 / 0x98 below); then the
## panel frame lines and the instruments, all 0x90 below.
func update_view_readouts_and_overlays(hide_cursor: int) -> void:
	assert(memory != null, "update_view_readouts_and_overlays requires original global memory")
	assert(a7 != 0, "update_view_readouts_and_overlays needs a7 (its frame holds the text)")
	var entry_a7: int = a7
	var text: int = entry_a7 - 4 - 0x64
	if memory.read_u16(DAT_00020ae4) != 0:
		var world: int = memory.read_u32(DAT_0001b5a0)
		if memory.read_u16(DAT_00025ffc) == 0:
			memory.write_u32(DAT_0001bd7c, C68kScript.u32(memory.read_s16(world + 0xe2) * memory.read_s16(world + 0xe0)))
		if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0x9e) == 0:
			a7 = entry_a7 - 0x94
			draw_sky_and_ground(hide_cursor)
			a7 = entry_a7 - 0x98
			update_heading_tape(hide_cursor)
		a7 = entry_a7 - 0x90
		draw_panel_frame_lines()
		update_altimeter_needles()
		update_airspeed_needle()
		update_direction_needle()
		update_climb_needle()
		update_tachometer_needle()
		update_manifold_needle()
		update_radar_scope()
		update_flaps_needle()
		update_ammo_needle()
		update_fuel_needles()
		update_gear_needles()
		a7 = entry_a7
		return
	var subject: int
	var mode7: int
	if memory.read_s16(DAT_0001d858) == 7:
		subject = memory.read_u32(DAT_0001b888)
		mode7 = 1
	else:
		subject = memory.read_u32(DAT_0001b738)
		mode7 = 0
	memory.write_u16(DAT_00025ffc, 0)
	var count: int = memory.read_u16(DAT_00020ae2)
	var value: int = 0
	while true:
		count = (count - 1) & 0xffff
		if count == 0xffff:
			break
		if memory.read_s16(DAT_00020ae2) == 4:
			memory.write_u16(DAT_00025ff2, 0)
			a7 = entry_a7 - 0xa8
			_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x27a), [0, 0, 0, 0, 1, mode7])
			a7 = entry_a7
			memory.write_u16(DAT_00020ae2, 1)
			for k in 4:
				memory.write_u16(DAT_00025ff4 + 2 * k, 0x7fff)
			count = 4
		var index: int = memory.read_s16(DAT_00025ff2)
		if C68kScript.u32(index) <= 3:
			var d0: int
			match index:
				0:
					value = C68kScript.s16(C68kScript.divs_trunc(memory.read_s32(memory.read_u32(subject) + 0x1c), 10))
				1:
					d0 = C68kScript.divs_trunc(memory.read_s32(subject + 0x62a), 0x12)
					if d0 < 0:
						d0 += 3
					value = C68kScript.s16(d0 >> 2)
				2:
					d0 = C68kScript.s32(memory.read_s16(subject + 0x22) * 0x168)
					if d0 < 0:
						d0 += 0xff
					d0 = d0 >> 8
					if d0 < 0:
						d0 += 0x3f
					d0 = d0 >> 6
					value = C68kScript.s16(0x168 - d0)
				3:
					d0 = C68kScript.s32(C68kScript.divs_trunc(memory.read_s32(DAT_0001bc80), 0x78) * 0x258)
					if d0 < 0:
						d0 += 0x3f
					d0 = d0 >> 6
					value = C68kScript.s16(C68kScript.divs_trunc(d0, 0x76))
		var skip: bool = mode7 != 0 and memory.read_s16(DAT_00025ff2) == 3
		var slot: int = C68kScript.u32(DAT_00025ff4 + memory.read_s16(DAT_00025ff2) * 2)
		if not skip and memory.read_s16(slot) != value:
			var negative: bool = value < 0
			if negative:
				value = C68kScript.s16(-value)
			memory.write_u16(slot, C68kScript.u16(value))
			memory.write_u8(text + 10, 0)
			var pos: int = 9
			if memory.read_s16(DAT_00025ff2) == 2:
				memory.write_u8(text + 9, 0xa1)
				pos = 8
			while true:
				memory.write_u8(text + pos, (C68kScript.rems_trunc(value, 10) + 0x30) & 0xff)
				pos -= 1
				value = C68kScript.s16(C68kScript.divs_trunc(value, 10))
				if value == 0:
					break
			if negative:
				memory.write_u8(text + pos, 0x2d)
				pos -= 1
			pos += 1
			var start: int = text + pos
			a7 = entry_a7 - 0xa0
			var length: int = c_strlen(start)
			a7 = entry_a7 - 0xa8
			_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x27a), [start, memory.read_s16(DAT_00025ff2), 0, length, 0, mode7])
			a7 = entry_a7
		memory.write_u16(DAT_00025ff2, C68kScript.u16(memory.read_u16(DAT_00025ff2) + 1))
		if memory.read_s16(DAT_00025ff2) == 4:
			memory.write_u16(DAT_00025ff2, 0)

## 0xd27c: readouts_drawn = 1; with the host line routine (word +0x9e) also clear_flag_00020ae4.
func mark_view_overlays_drawn() -> void:
	assert(memory != null, "mark_view_overlays_drawn requires original global memory")
	memory.write_u16(DAT_00025ffc, 1)
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0x9e) != 0:
		clear_flag_00020ae4()

## 32-bit dbra count (dbra, then clr.w / subq.l / bcc): the long count as an unsigned
## iteration count.
func _dbra32_count(n: int) -> int:
	return C68kScript.u32(n)

## 0xba2a: the four panel frame lines (host words +0x238..+0x24a, colour +0x25c), four saved
## registers. With the host line routine (word +0x9e), unless the view depth is 1: two vertical
## lines (colour, x +0x240, top +0x238 / +0x23c, x +0x240, bottom +0x23a / +0x23e - 2) and two
## horizontal ones (colour, left +0x242 / +0x246, y +0x24a, right +0x244 / +0x248 - 2, y +0x24a)
## through host +0x272 (0x28 / 0x3c below). Otherwise drawn into the screen: depth 4 with the
## byte (c << 4) | c of colour byte +0x25d, depth 8 with the word (c << 8) | c of word +0x25c:
## columns from the addresses at host +0x24c / +0x250 stepping one row (word +0x10, halved
## toward zero at depth 8 and stepped in words) for (bottom - top) rows, and double rows (the
## address and the one a row below) from +0x254 / +0x258 for (right - left) / 2 pixels.
## Address-register differences are sext words subtracted as longs.
func draw_panel_frame_lines() -> void:
	assert(memory != null, "draw_panel_frame_lines requires original global memory")
	var world: int = memory.read_u32(DAT_0001b5a0)
	var depth: int = memory.read_s16(DAT_0001b826)
	var entry_a7: int = a7
	if memory.read_u16(world + 0x9e) != 0:
		if depth == 1:
			return
		a7 = entry_a7 - 0x28
		_jsr(memory.read_u32(world + 0x272), [memory.read_s16(world + 0x25c), memory.read_s16(world + 0x240), memory.read_s16(world + 0x238),
				memory.read_s16(world + 0x240), memory.read_s16(world + 0x23a) - 2])
		world = memory.read_u32(DAT_0001b5a0)
		a7 = entry_a7 - 0x3c
		_jsr(memory.read_u32(world + 0x272), [memory.read_s16(world + 0x25c), memory.read_s16(world + 0x240), memory.read_s16(world + 0x23c),
				memory.read_s16(world + 0x240), memory.read_s16(world + 0x23e) - 2])
		world = memory.read_u32(DAT_0001b5a0)
		a7 = entry_a7 - 0x28
		_jsr(memory.read_u32(world + 0x272), [memory.read_s16(world + 0x25c), memory.read_s16(world + 0x242), memory.read_s16(world + 0x24a),
				memory.read_s16(world + 0x244) - 2, memory.read_s16(world + 0x24a)])
		world = memory.read_u32(DAT_0001b5a0)
		a7 = entry_a7 - 0x3c
		_jsr(memory.read_u32(world + 0x272), [memory.read_s16(world + 0x25c), memory.read_s16(world + 0x246), memory.read_s16(world + 0x24a),
				memory.read_s16(world + 0x248) - 2, memory.read_s16(world + 0x24a)])
		a7 = entry_a7
		return
	if depth != 4 and depth != 8:
		return
	var step: int
	var unit: int
	var colour: int
	if depth == 4:
		step = memory.read_s16(world + 0x10)
		unit = 1
		var c: int = memory.read_u8(world + 0x25d)
		colour = ((c << 4) | c) & 0xff
	else:
		var row: int = memory.read_s16(world + 0x10)
		if row < 0:
			row += 1
		step = C68kScript.s16(row >> 1)
		unit = 2
		var w: int = memory.read_u16(world + 0x25c)
		colour = ((w << 8) | w) & 0xffff
	var put := func(addr: int) -> void:
		if unit == 1:
			memory.write_u8(addr, colour)
		else:
			memory.write_u16(addr, colour)
	for col in [[0x238, 0x23a, 0x24c], [0x23c, 0x23e, 0x250]]:
		world = memory.read_u32(DAT_0001b5a0)
		var n: int = _dbra32_count(C68kScript.s32(memory.read_s16(world + col[1]) - memory.read_s16(world + col[0])))
		var addr: int = memory.read_u32(world + col[2])
		for i in n:
			put.call(addr)
			addr = C68kScript.u32(addr + step * unit)
	for rw in [[0x242, 0x244, 0x254], [0x246, 0x248, 0x258]]:
		world = memory.read_u32(DAT_0001b5a0)
		var width: int = C68kScript.s32(memory.read_s16(world + rw[1]) - memory.read_s16(world + rw[0]))
		if width < 0:
			width += 1
		var n: int = _dbra32_count(width >> 1)
		var a0: int = memory.read_u32(memory.read_u32(DAT_0001b5a0) + rw[2])
		var a1: int = C68kScript.u32(a0 + step * unit)
		for i in n:
			put.call(a0)
			put.call(a1)
			a0 = C68kScript.u32(a0 + unit)
			a1 = C68kScript.u32(a1 + unit)

## 0xc11e (link.w a6,#-8, d2 saved): zero the 0x6c-byte port record (memzero, 0x1c below), then
## the host port setup (+0x282)(port, row_bytes, base, rect) with the frame rect (a6 - 8: top =
## rows (word), left 0, bottom = rows + host word +0x18, right = host word +0x16; 0x30 below) and
## the host port switch (+0x286)(port) (0x34 below), whose D0 (the previous port) is returned.
func begin_offscreen_drawing(port: int, row_bytes: int, base: int, rows: int) -> int:
	assert(memory != null, "begin_offscreen_drawing requires original global memory")
	assert(a7 != 0, "begin_offscreen_drawing needs a7 (its frame holds the rect)")
	var entry_a7: int = a7
	var rect: int = entry_a7 - 4 - 8
	a7 = entry_a7 - 0x1c
	memzero(port, 0x6c)
	a7 = entry_a7
	memory.write_u16(rect + 2, 0)
	memory.write_u16(rect, C68kScript.u16(rows))
	var world: int = memory.read_u32(DAT_0001b5a0)
	memory.write_u16(rect + 6, memory.read_u16(world + 0x16))
	memory.write_u16(rect + 4, C68kScript.u16(rows + memory.read_u16(world + 0x18)))
	a7 = entry_a7 - 0x30
	_jsr(memory.read_u32(world + 0x282), [port, row_bytes, base, rect])
	a7 = entry_a7 - 0x34
	var d0 = _jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x286), [port])
	a7 = entry_a7
	return int(d0)

## 0xc17e: host port release (+0x28a)(port) (0xc below), then the host port switch (+0x286)
## (saved) back (0x10 below).
func end_offscreen_drawing(port: int, saved: int) -> void:
	assert(memory != null, "end_offscreen_drawing requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0xc
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x28a), [port])
	a7 = entry_a7 - 0x10
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x286), [saved])
	a7 = entry_a7

## 0xc1aa (link.w a6,#-0xa0, ten saved registers: body 0xcc below the entry): the heading tape.
## Panels not drawn yet: the window is first cleared in an offscreen port over the saved panel
## copy (begin_offscreen_drawing into the frame port a6 - 0x6c; host rect fill +0x28e with the
## frame rect a6 - 0x74 and colour word +0x25c; end_offscreen_drawing at depth 8), with the host
## cursor hook (+0x2c2) around it when hide_cursor. Position = ((-heading * period) / 0x4000
## toward zero) - window width / 2 (toward zero) + host word +0x1a8, raised by the period while
## negative (never reduced from above). Unchanged from heading_tape_pos: nothing more, except
## the end_offscreen_drawing (and cursor hook) below depth 8 with undrawn panels. Changed (cached):
## below depth 8 the host copy (+0x29a)(+0x1bc, strip +0x1b0, source rect a6 - 0x7c, port or 0,
## destination rect a6 - 0x84) copies the strip window, split in two when it runs past the
## period; then end_offscreen_drawing when the panels are undrawn. At depth 8 the window columns
## are walked against the marking bytes at the old and new positions: runs of columns marked in
## either go to copy_rect_depth8 (runtime 0xbf90, a code pointer)(dst, src, run, height, strip row
## bytes & 0x1fff, row bytes) (0xe8 below), wrapping the strip at the period. The depth-4 strip
## branch (0xc444, copy_rect_depth4) is unreachable: it is only entered at depth 8.
func update_heading_tape(hide_cursor: int) -> void:
	assert(memory != null, "update_heading_tape requires original global memory")
	assert(a7 != 0, "update_heading_tape needs a7 (its frame holds the port and rects)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var port: int = a6 - 0x6c
	var frame_rect: int = a6 - 0x74
	var src_rect: int = a6 - 0x7c
	var dst_rect: int = a6 - 0x84
	var world: int = memory.read_u32(DAT_0001b5a0)
	var strip: int = memory.read_u32(world + 0x1b0)
	var marks: int = memory.read_u32(world + 0x1b8)
	var period: int = memory.read_s16(world + 0x1a4)
	var cols_left: int = memory.read_s16(world + 0x19e)
	var height: int = memory.read_s16(world + 0x1a0)
	var strip_row: int = memory.read_u16(world + 0x1aa) & 0x1fff
	var base: int
	var rel_row: int
	var row_bytes: int
	var saved: int = 0
	var panels: bool = memory.read_u16(DAT_00020ae4) != 0
	if panels:
		base = memory.read_u32(world + 6)
		rel_row = memory.read_s16(world + 0x19a)
		row_bytes = memory.read_s16(world + 0x10)
	else:
		base = memory.read_u32(world + 0xdc)
		rel_row = memory.read_s16(world + 0x19a) - memory.read_s16(world + 0xe2)
		row_bytes = memory.read_s16(world + 0xe0)
		if hide_cursor != 0:
			a7 = entry_a7 - 0xd0
			_jsr(memory.read_u32(world + 0x2c2), [])
		a7 = entry_a7 - 0xe0
		saved = C68kScript.u32(begin_offscreen_drawing(port, row_bytes, base, memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe2)))
		world = memory.read_u32(DAT_0001b5a0)
		memory.write_u16(frame_rect + 2, memory.read_u16(world + 0x19c))
		memory.write_u16(frame_rect, memory.read_u16(world + 0x19a))
		memory.write_u16(frame_rect + 6, C68kScript.u16(memory.read_u16(world + 0x19c) + cols_left))
		memory.write_u16(frame_rect + 4, C68kScript.u16(memory.read_u16(world + 0x19a) + height))
		a7 = entry_a7 - 0xe8
		_jsr(memory.read_u32(world + 0x28e), [frame_rect, memory.read_s16(world + 0x25c)])
		if memory.read_s16(DAT_0001b826) == 8:
			a7 = entry_a7 - 0xd8
			end_offscreen_drawing(port, saved)
		if hide_cursor != 0:
			a7 = entry_a7 - 0xd0
			_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
		a7 = entry_a7
	var turn: int = C68kScript.s32(C68kScript.s32(-memory.read_s16(DAT_0001d80e)) * period)
	if turn < 0:
		turn = C68kScript.s32(turn + 0x3fff)
	turn = turn >> 14
	var half: int = cols_left
	if half < 0:
		half += 1
	half = half >> 1
	var pos: int = C68kScript.s32(C68kScript.s32(turn - half) + memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x1a8))
	while pos < 0:
		pos = C68kScript.s32(pos + period)
	var depth: int = memory.read_s16(DAT_0001b826)
	if memory.read_s16(DAT_00025ffe) == pos:
		if panels or depth == 8:
			return
		if hide_cursor != 0:
			a7 = entry_a7 - 0xd0
			_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
		_heading_tape_finish(entry_a7, port, saved, hide_cursor)
		return
	var old_pos: int = memory.read_s16(DAT_00025ffe)
	memory.write_u16(DAT_00025ffe, C68kScript.u16(pos))
	if depth != 8:
		if hide_cursor != 0:
			a7 = entry_a7 - 0xd0
			_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
			a7 = entry_a7
		var target: int = 0 if panels else port
		world = memory.read_u32(DAT_0001b5a0)
		var left: int = memory.read_u16(world + 0x19c)
		var top: int = memory.read_u16(world + 0x19a)
		memory.write_u16(dst_rect + 2, left)
		memory.write_u16(dst_rect, top)
		var right: int = C68kScript.u16(left + memory.read_u16(world + 0x19e))
		memory.write_u16(dst_rect + 6, right)
		memory.write_u16(dst_rect + 4, C68kScript.u16(top + memory.read_u16(world + 0x1a0)))
		memory.write_u16(src_rect + 2, C68kScript.u16(pos))
		memory.write_u16(src_rect, 0)
		memory.write_u16(src_rect + 4, memory.read_u16(world + 0x1a6))
		var src_right: int = C68kScript.u16(pos + cols_left)
		memory.write_u16(src_rect + 6, src_right)
		if period < C68kScript.s16(src_right):
			var over: int = C68kScript.s32(C68kScript.s16(src_right) - period)
			memory.write_u16(src_rect + 6, C68kScript.u16(src_right - over))
			right = C68kScript.u16(right - over)
			memory.write_u16(dst_rect + 6, right)
			a7 = entry_a7 - 0xe4
			_jsr(memory.read_u32(world + 0x29a), [memory.read_u32(world + 0x1bc), memory.read_u32(world + 0x1b0), src_rect, target, dst_rect])
			a7 = entry_a7
			memory.write_u16(src_rect + 2, 0)
			memory.write_u16(src_rect + 6, C68kScript.u16(over))
			memory.write_u16(dst_rect + 2, memory.read_u16(dst_rect + 6))
			memory.write_u16(dst_rect + 6, C68kScript.u16(memory.read_u16(dst_rect + 6) + over))
		world = memory.read_u32(DAT_0001b5a0)
		a7 = entry_a7 - 0xe4
		_jsr(memory.read_u32(world + 0x29a), [memory.read_u32(world + 0x1bc), memory.read_u32(world + 0x1b0), src_rect, target, dst_rect])
		a7 = entry_a7
		if not panels:
			_heading_tape_finish(entry_a7, port, saved, hide_cursor)
		elif hide_cursor != 0:
			a7 = entry_a7 - 0xd0
			_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
			a7 = entry_a7
		return
	# Depth 8: copy the runs of columns marked at the old or new position.
	var mark_new: int = C68kScript.u32(marks + pos)
	var mark_old: int = C68kScript.u32(marks + old_pos)
	var dst: int = C68kScript.u32(C68kScript.u32(base + C68kScript.s32(C68kScript.s16(rel_row) * row_bytes)) + memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x19c))
	var src: int = C68kScript.u32(strip + pos)
	var col: int = pos
	var skip: int = 0
	var run: int = 0
	var old_col: int = old_pos
	var left_cols: int = C68kScript.u32(cols_left)
	while left_cols != 0:
		left_cols -= 1
		col = C68kScript.s32(col + 1)
		var marked: int = memory.read_u8(mark_old) | memory.read_u8(mark_new)
		mark_old = C68kScript.u32(mark_old + 1)
		mark_new = C68kScript.u32(mark_new + 1)
		if marked != 0:
			run += 1
			if col == period:
				dst = C68kScript.u32(dst + skip)
				_heading_tape_copy(entry_a7, dst, C68kScript.u32(src + skip), run, height, strip_row, row_bytes)
				dst = C68kScript.u32(dst + run)
				run = 0
				skip = 0
				src = strip
				col = 0
				mark_new = marks
		else:
			if run != 0:
				dst = C68kScript.u32(dst + skip)
				src = C68kScript.u32(src + skip)
				_heading_tape_copy(entry_a7, dst, src, run, height, strip_row, row_bytes)
				dst = C68kScript.u32(dst + run)
				src = C68kScript.u32(src + run)
				run = 0
				skip = 0
			skip += 1
			if col == period:
				src = strip
				dst = C68kScript.u32(dst + skip)
				skip = 0
				col = 0
				mark_new = marks
		old_col += 1
		if old_col == period:
			old_col = 0
			mark_old = marks
	if run != 0:
		_heading_tape_copy(entry_a7, C68kScript.u32(dst + skip), C68kScript.u32(src + skip), run, height, strip_row, row_bytes)

## copy_rect_depth8 through its code address (runtime 0xbf90), 0xe8 below the tape's entry.
func _heading_tape_copy(entry_a7: int, dst: int, src: int, run: int, height: int, strip_row: int, row_bytes: int) -> void:
	a7 = entry_a7 - 0xe8
	_jsr(0xbf90, [dst, src, run, height, strip_row, row_bytes])
	a7 = entry_a7

## end_offscreen_drawing (0xd8 below), then the cursor hook (0xd0 below) when hide_cursor.
func _heading_tape_finish(entry_a7: int, port: int, saved: int, hide_cursor: int) -> void:
	a7 = entry_a7 - 0xd8
	end_offscreen_drawing(port, saved)
	if hide_cursor != 0:
		a7 = entry_a7 - 0xd0
		_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
	a7 = entry_a7

## One background row record at a1: header (0, span count - 1) then the spans (x, colour) as
## words; returns the address after it.
func _bg_row(a1: int, spans: Array) -> int:
	var a2: int = a1
	a1 = C68kScript.u32(a1 + 4)
	for sp in spans:
		memory.write_u16(a1, C68kScript.u16(sp[0]))
		memory.write_u16(a1 + 2, C68kScript.u16(sp[1]))
		a1 = C68kScript.u32(a1 + 4)
	memory.write_u16(a2, 0)
	memory.write_u16(a2 + 2, C68kScript.u16(C68kScript.asr32(C68kScript.s32(a1 - a2), 2) - 1))
	return a1

## 0xb4b6 (link.w a6,#-0x14, ten saved registers: body 0x40 below the entry): sky and ground.
## When the view geometry (host +0x186..+0x199) differs from bg_cache_origin, or there is no row
## buffer yet, it is cached, both row buffers are freed (heap_free_coalesce, 0x48 below) and, below
## depth 1, reallocated at rows * 20 bytes (heap_alloc, 0x48 / 0x4c below); reset_background_rows
## (0x44 below) follows either way. The horizon edge (x0, y0)-(x1, y1) is scaled from view to
## cached rows ((half size + v) * rows / view_rows; x + left, then 16.16 with 0x8000); top / bottom
## rows d2 / d3, the x at the top d4 and the slope (dx / dy) follow from its order (equal y leaves
## d4, the slope and the side flag unset, as in the original: the port uses 0). Corners 0xf / 0
## (all ground / all sky) take every row in the upper band with colour +0x190 / +0x18e; otherwise
## the upper / lower band colours (frame words a6 - 0xe / - 0x12) follow corner bits 3 / 0xc. Both
## rows are clamped to the row count. Depth 1: on even frames with the panels drawn, the host
## routine (+0x27e)(top, bottom, rows, upper, lower, x top, x bottom, left colour, right colour)
## (0x68 below), inside the cursor hook (+0x2c2) when hide_cursor. Otherwise each row gets a
## record in background_rows_next from the cached row extents: upper rows (x0 fill, x1 upper,
## width fill), band rows split at the horizon x (left colour a6 - 0x10, right colour), lower rows
## (lower colour); then span_filler(&next, &rows, row count, frame base, row skip) (0x58 below)
## blits them (the saved panel copy when the panels are undrawn, else the screen) and the buffers
## swap. The horizon edge and corners are cleared at the end.
func draw_sky_and_ground(hide_cursor: int) -> void:
	assert(memory != null, "draw_sky_and_ground requires original global memory")
	assert(a7 != 0, "draw_sky_and_ground needs a7 (its frame holds the colours and buffer slots)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var upper_colour: int = a6 - 0xe
	var left_colour: int = a6 - 0x10
	var lower_colour: int = a6 - 0x12
	var x_bottom_slot: int = a6 - 0xc
	var world: int = memory.read_u32(DAT_0001b5a0)
	var same: bool = memory.read_u32(DAT_00020ad8) != 0
	if same:
		for off in [0, 2, 4, 6]:
			if memory.read_u16(world + 0x186 + off) != memory.read_u16(DAT_00025f34 + off):
				same = false
		if memory.read_u32(DAT_00025f34 + 0x10) != memory.read_u32(world + 0x196):
			same = false
	if not same:
		for k in 5:
			memory.write_u32(DAT_00025f34 + 4 * k, memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x186 + 4 * k))
		if memory.read_u32(DAT_00020ad8) != 0:
			a7 = entry_a7 - 0x48
			heap_free_coalesce(memory.read_u32(DAT_00020ad8))
			a7 = entry_a7
			memory.write_u32(DAT_00020ad8, 0)
		if memory.read_u32(DAT_00020ad4) != 0:
			a7 = entry_a7 - 0x48
			heap_free_coalesce(memory.read_u32(DAT_00020ad4))
			a7 = entry_a7
			memory.write_u32(DAT_00020ad4, 0)
		if memory.read_s16(DAT_0001b826) != 1:
			a7 = entry_a7 - 0x48
			memory.write_u32(DAT_00020ad8, C68kScript.u32(heap_alloc(C68kScript.s32(memory.read_s16(DAT_00025f3a) * 20))))
			a7 = entry_a7 - 0x4c
			memory.write_u32(DAT_00020ad4, C68kScript.u32(heap_alloc(C68kScript.s32(memory.read_s16(DAT_00025f3a) * 20))))
		a7 = entry_a7 - 0x44
		reset_background_rows()
		a7 = entry_a7
	var half_w: int = memory.read_s16(DAT_00020b2a)
	var half_h: int = memory.read_s16(DAT_00020b2c)
	var view_rows: int = memory.read_s16(DAT_0001b828)
	var left: int = memory.read_s16(DAT_00025f34 + 2)
	var scale := func(v: int) -> int:
		return C68kScript.divs_trunc(C68kScript.s32(v * memory.read_s16(DAT_00025f3a)), view_rows)
	memory.write_u32(DAT_0001bda0, C68kScript.u32(scale.call(C68kScript.s32(half_w + memory.read_s32(DAT_0001bda0))) + left))
	memory.write_u32(DAT_0001bd9c, C68kScript.u32(scale.call(C68kScript.s32(half_h + memory.read_s32(DAT_0001bd9c)))))
	memory.write_u32(DAT_0001bd98, C68kScript.u32(scale.call(C68kScript.s32(half_w + memory.read_s32(DAT_0001bd98))) + left))
	memory.write_u32(DAT_0001bd94, C68kScript.u32(scale.call(C68kScript.s32(half_h + memory.read_s32(DAT_0001bd94)))))
	memory.write_u32(DAT_0001bda0, C68kScript.u32(C68kScript.lsl32(memory.read_u32(DAT_0001bda0), 16) + 0x8000))
	memory.write_u32(DAT_0001bd98, C68kScript.u32(C68kScript.lsl32(memory.read_u32(DAT_0001bd98), 16) + 0x8000))
	var top: int
	var bottom: int
	var x_top: int = 0
	var slope: int = 0
	var side: int = 0
	var y0: int = memory.read_s32(DAT_0001bd9c)
	var y1: int = memory.read_s32(DAT_0001bd94)
	if y0 == y1:
		bottom = memory.read_s16(DAT_0001bd9c + 2)
		top = bottom
	elif y0 > y1:
		bottom = memory.read_s16(DAT_0001bd9c + 2)
		top = memory.read_s16(DAT_0001bd94 + 2)
		x_top = memory.read_s32(DAT_0001bd98)
		memory.write_u32(x_bottom_slot, memory.read_u32(DAT_0001bda0))
		slope = C68kScript.divs_trunc(C68kScript.s32(memory.read_s32(DAT_0001bda0) - x_top), C68kScript.s32(y0 - y1))
		side = 1
	else:
		bottom = memory.read_s16(DAT_0001bd94 + 2)
		top = memory.read_s16(DAT_0001bd9c + 2)
		x_top = memory.read_s32(DAT_0001bda0)
		memory.write_u32(x_bottom_slot, memory.read_u32(DAT_0001bd98))
		slope = C68kScript.divs_trunc(C68kScript.s32(memory.read_s32(DAT_0001bd98) - x_top), C68kScript.s32(y1 - y0))
		side = 0
	world = memory.read_u32(DAT_0001b5a0)
	var corners: int = memory.read_u32(DAT_0001bd90)
	if corners == 0xf:
		top = memory.read_s16(DAT_00025f3a)
		memory.write_u16(upper_colour, memory.read_u16(world + 0x190))
	elif corners == 0:
		top = memory.read_s16(DAT_00025f3a)
		memory.write_u16(upper_colour, memory.read_u16(world + 0x18e))
	else:
		memory.write_u16(upper_colour, memory.read_u16(world + (0x190 if (corners & 3) != 0 else 0x18e)))
		memory.write_u16(lower_colour, memory.read_u16(world + (0x190 if (corners & 0xc) != 0 else 0x18e)))
	var rows: int = memory.read_s16(DAT_00025f3a)
	if top > rows:
		top = rows
	if bottom > rows:
		bottom = rows
	var right_colour: int
	if side != 0:
		memory.write_u16(left_colour, memory.read_u16(world + 0x18e))
		right_colour = memory.read_s16(world + 0x190)
	else:
		memory.write_u16(left_colour, memory.read_u16(world + 0x190))
		right_colour = memory.read_s16(world + 0x18e)
	if memory.read_s16(DAT_0001b826) == 1:
		if memory.read_u16(DAT_00020ae4) != 0:
			var parity: int = memory.read_u16(DAT_00025f48) & 1
			memory.write_u16(DAT_00025f48, C68kScript.u16(memory.read_u16(DAT_00025f48) + 1))
			if parity == 0:
				if hide_cursor != 0:
					a7 = entry_a7 - 0x44
					_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
				a7 = entry_a7 - 0x68
				_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x27e), [top, bottom, memory.read_s16(DAT_00025f3a), memory.read_s16(upper_colour),
						memory.read_s16(lower_colour), C68kScript.asr32(x_top, 16), C68kScript.asr32(memory.read_s32(x_bottom_slot), 16),
						memory.read_s16(left_colour), right_colour])
				if hide_cursor != 0:
					a7 = entry_a7 - 0x44
					_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2c2), [])
				a7 = entry_a7
	else:
		var extents: int = memory.read_u32(DAT_00025f44)
		var a1: int = memory.read_u32(DAT_00020ad8)
		var fill: int = memory.read_u16(DAT_0001daa0)
		var row: int = 0
		while row < top:
			a1 = _bg_row(a1, [[memory.read_u16(extents + 4 * row), fill], [memory.read_u16(extents + 4 * row + 2), memory.read_u16(upper_colour)],
					[memory.read_u16(DAT_0001b82a), memory.read_u16(DAT_0001daa0)]])
			row += 1
		while row < bottom:
			var x0: int = memory.read_s16(extents + 4 * row)
			var x1: int = memory.read_s16(extents + 4 * row + 2)
			var spans: Array = [[x0, memory.read_u16(DAT_0001daa0)]]
			if C68kScript.s32(C68kScript.lsl32(x0, 16)) >= x_top:
				spans.append([x1, right_colour])
			elif C68kScript.s32(C68kScript.lsl32(x1, 16)) <= x_top:
				spans.append([x1, memory.read_u16(left_colour)])
			else:
				spans.append([C68kScript.asr32(x_top, 16), memory.read_u16(left_colour)])
				spans.append([x1, right_colour])
			spans.append([memory.read_u16(DAT_0001b82a), memory.read_u16(DAT_0001daa0)])
			a1 = _bg_row(a1, spans)
			x_top = C68kScript.s32(x_top + slope)
			row += 1
		while row < memory.read_s16(DAT_00025f3a):
			a1 = _bg_row(a1, [[memory.read_u16(extents + 4 * row), memory.read_u16(DAT_0001daa0)], [memory.read_u16(extents + 4 * row + 2), memory.read_u16(lower_colour)],
					[memory.read_u16(DAT_0001b82a), memory.read_u16(DAT_0001daa0)]])
			row += 1
		world = memory.read_u32(DAT_0001b5a0)
		var base: int
		var skip: int
		if memory.read_u16(DAT_00020ae4) == 0:
			skip = 0
			base = C68kScript.u32(C68kScript.s32(memory.read_s16(world + 0xe0) * C68kScript.s32(memory.read_s16(DAT_00025f34) - memory.read_s16(world + 0xe2))) + memory.read_u32(world + 0xdc))
		else:
			var per_byte: int = C68kScript.divs_trunc(8, memory.read_s16(DAT_0001b826))
			var width_bytes: int = C68kScript.s16(C68kScript.divs_trunc(memory.read_s16(DAT_0001b82a), C68kScript.s16(per_byte)))
			skip = C68kScript.s16(memory.read_u16(world + 0x10) - width_bytes)
			base = C68kScript.u32(C68kScript.s32(memory.read_s16(world + 0x10) * memory.read_s16(DAT_00025f34)) + memory.read_u32(world + 6))
		memory.write_u32(a6 - 4, memory.read_u32(DAT_00020ad8))
		memory.write_u32(a6 - 8, memory.read_u32(DAT_00020ad4))
		a7 = entry_a7 - 0x58
		_jsr(memory.read_u32(DAT_00020ac0), [a6 - 4, a6 - 8, memory.read_s16(DAT_00025f3a), base, skip])
		a7 = entry_a7
		var tmp: int = memory.read_u32(DAT_00020ad8)
		memory.write_u32(DAT_00020ad8, memory.read_u32(DAT_00020ad4))
		memory.write_u32(DAT_00020ad4, tmp)
	memory.write_u32(DAT_0001bd94, 0)
	memory.write_u32(DAT_0001bd9c, 0)
	memory.write_u32(DAT_0001bd90, 0)

## dbra over a word counter loaded with n - 1: n iterations for 1..0x10000 (n = 0 runs 0x10000).
func _dbra_word_count(n: int) -> int:
	return ((n - 1) & 0xffff) + 1

## 0xbfb0 (link.w a6,#-0xc): copy a columns-by-height block of bytes from src (row stride
## src_row) to dst (row stride dst_row). Leading columns go one at a time until dst is long
## aligned (a zero count stops them); then (count word & ~3) / 4 longs per row, src aligned down
## and its misalignment (0..3, jump table) merged from consecutive source longs (lsl / lsr by
## 8 / 16 / 24); then the remaining columns (count & 3, or the whole count when no long fits) one
## at a time. The height loops are dbra words (height 0 would run 0x10000 rows).
func copy_rect_depth8(dst: int, src: int, count: int, height: int, src_row: int, dst_row: int) -> void:
	assert(memory != null, "copy_rect_depth8 requires original global memory")
	var rows: int = _dbra_word_count(C68kScript.s16(height))
	var left: int = C68kScript.u32(count)
	var d5: int = C68kScript.u32(dst)
	var a2: int = C68kScript.u32(src)
	var column := func(to: int, from: int) -> void:
		for r in rows:
			memory.write_u8(to, memory.read_u8(from))
			to = C68kScript.u32(to + dst_row)
			from = C68kScript.u32(from + src_row)
	var stopped: bool = false
	while (d5 & 3) != 0:
		if left == 0:
			stopped = true
			break
		column.call(d5, a2)
		d5 = C68kScript.u32(d5 + 1)
		a2 = C68kScript.u32(a2 + 1)
		left = C68kScript.u32(left - 1)
	var whole: int = C68kScript.s16(left & 0xfffc)
	var tail_dst: int = C68kScript.u32(d5 + whole)
	var tail_src: int = C68kScript.u32(a2 + whole)
	if whole != 0 and not stopped:
		var longs: int = _dbra_word_count(C68kScript.s16((whole + (3 if whole < 0 else 0)) >> 2))
		var mis: int = a2 & 3
		a2 = C68kScript.u32(a2 - mis)
		for r in rows:
			var to: int = d5
			if mis == 0:
				var from: int = a2
				for k in longs:
					memory.write_u32(to, memory.read_u32(from))
					to += 4
					from += 4
			else:
				var shift: int = 8 * mis
				var acc: int = C68kScript.u32(memory.read_u32(a2) << shift)
				var from2: int = C68kScript.u32(a2 + 4)
				for k in longs:
					var nxt: int = memory.read_u32(from2)
					from2 += 4
					memory.write_u32(to, C68kScript.u32(acc | (nxt >> (32 - shift))))
					to += 4
					acc = C68kScript.u32(nxt << shift)
			d5 = C68kScript.u32(d5 + dst_row)
			a2 = C68kScript.u32(a2 + src_row)
		left = left & 3
	while left != 0:
		column.call(tail_dst, tail_src)
		tail_dst = C68kScript.u32(tail_dst + 1)
		tail_src = C68kScript.u32(tail_src + 1)
		left = C68kScript.u32(left - 1)

## One 4-bit pixel column: the pixel at nibble address dst_px takes the one at src_px for
## each row (odd addresses are low nibbles; the four parity cases of the original).
func _copy_nibble_column(dst_px: int, src_px: int, rows: int, src_step: int, dst_step: int) -> void:
	var a0: int = C68kScript.u32(dst_px) >> 1
	var d2: int = C68kScript.u32(src_px) >> 1
	var dst_odd: bool = (dst_px & 1) != 0
	var src_odd: bool = (src_px & 1) != 0
	for r in rows:
		var dv: int = memory.read_u8(a0)
		var sv: int = memory.read_u8(d2)
		var out: int
		if dst_odd and src_odd:
			out = (dv & 0xf0) | (sv & 0x0f)
		elif dst_odd:
			out = (dv & 0xf0) | (sv >> 4)
		elif src_odd:
			out = (dv & 0x0f) | ((sv << 4) & 0xf0)
		else:
			out = (sv & 0xf0) | (dv & 0x0f)
		memory.write_u8(a0, out)
		a0 = C68kScript.u32(a0 + dst_step)
		d2 = C68kScript.u32(d2 + src_step)

## 0xbca8 (link.w a6,#-0x10): as copy_rect_depth8 for 4-bit pixels. dst / src are pixel (nibble)
## addresses and the row strides are halved (asr) to bytes. Leading pixels go one at a time until
## dst is word (4-pixel) aligned; then (count word & ~3) / 4 words per row, the source pixel
## misalignment (0..3, jump table) merged from consecutive source words (shifts 4 / 8 / 12, the
## odd cases starting from the byte before); then the remaining pixels one at a time.
func copy_rect_depth4(dst: int, src: int, count: int, height: int, src_row: int, dst_row: int) -> void:
	assert(memory != null, "copy_rect_depth4 requires original global memory")
	var rows: int = _dbra_word_count(C68kScript.s16(height))
	var src_step: int = C68kScript.asr32(src_row, 1)
	var dst_step: int = C68kScript.asr32(dst_row, 1)
	var left: int = C68kScript.u32(count)
	var d6: int = C68kScript.u32(dst)
	var d5: int = C68kScript.u32(src)
	var stopped: bool = false
	while (d6 & 3) != 0:
		if left == 0:
			stopped = true
			break
		_copy_nibble_column(d6, d5, rows, src_step, dst_step)
		d6 = C68kScript.u32(d6 + 1)
		d5 = C68kScript.u32(d5 + 1)
		left = C68kScript.u32(left - 1)
	var whole: int = C68kScript.s16(left & 0xfffc)
	var tail_dst: int = C68kScript.u32(d6 + whole)
	var tail_src: int = C68kScript.u32(d5 + whole)
	if whole != 0 and not stopped:
		var words: int = _dbra_word_count(C68kScript.s16((whole + (3 if whole < 0 else 0)) >> 2))
		var mis: int = d5 & 3
		var to_row: int = d6 >> 1
		var from_row: int = d5 >> 1
		for r in rows:
			var to: int = to_row
			if mis == 0:
				var from: int = from_row
				for k in words:
					memory.write_u16(to, memory.read_u16(from))
					to += 2
					from += 2
			else:
				var acc: int
				var a0: int
				var shift: int = 4 * mis
				if mis == 1:
					acc = (memory.read_u16(from_row) << 4) & 0xffff
					a0 = C68kScript.u32(from_row + 2)
				else:
					acc = (memory.read_u8(from_row) << shift) & 0xffff
					a0 = C68kScript.u32(from_row + 1)
				for k in words:
					var nxt: int = memory.read_u16(a0)
					a0 += 2
					memory.write_u16(to, acc | (nxt >> (16 - shift)))
					to += 2
					acc = (nxt << shift) & 0xffff
			to_row = C68kScript.u32(to_row + dst_step)
			from_row = C68kScript.u32(from_row + src_step)
		left = left & 3
	while left != 0:
		_copy_nibble_column(tail_dst, tail_src, rows, src_step, dst_step)
		tail_dst = C68kScript.u32(tail_dst + 1)
		tail_src = C68kScript.u32(tail_src + 1)
		left = C68kScript.u32(left - 1)

## The shared two-pixel-thick Bresenham of draw_line_depth8 (0xd3bc) and restore_line_depth8
## (0xd91a), block for block. Draw writes the colour byte / word (c | c << 8); restore copies the
## same bytes / words from the backup bitmap (src base / row bytes), its pointers (a3 / a4) moving
## in step with the screen ones (a0 / a1). X-major lines (|dx| >= |dy|) run left to right two rows
## thick (a0 on the row, a1 one below), y-major ones top to bottom two columns wide; words are
## written on even addresses and the odd pixel of a diagonal step by byte. err starts at 2 minor -
## major (incs 2 minor / 2 (minor - major)); the dbra counter is the major delta - 1 (word). Row
## offsets are mulu.w (row bytes, y). The bgt tests after a jump use the flags of the last
## add / tst of err, i.e. err > 0.
func _line_depth8(restore: bool, x0: int, y0: int, x1: int, y1: int, colour: int, base: int, row: int, src_base: int, src_row: int) -> void:
	var cb: int = colour & 0xff
	var cw: int = ((colour << 8) | colour) & 0xffff
	var put_b := func(d: int, sp: int) -> void:
		memory.write_u8(C68kScript.u32(d), memory.read_u8(C68kScript.u32(sp)) if restore else cb)
	var put_w := func(d: int, sp: int) -> void:
		memory.write_u16(C68kScript.u32(d), memory.read_u16(C68kScript.u32(sp)) if restore else cw)
	var dx: int = abs_int(C68kScript.s32(x0 - x1))
	var dy: int = abs_int(C68kScript.s32(y0 - y1))
	var d7: int
	var err: int
	var straight: int
	var diag: int
	var a0: int
	var a1: int
	var a3: int = 0
	var a4: int = 0
	var label: int
	if not (dy > dx):
		if x1 < x0:
			var t: int = x0
			x0 = x1
			x1 = t
			t = y0
			y0 = y1
			y1 = t
		d7 = (dx - 1) & 0xffff
		a0 = C68kScript.u32(base + x0 + (row & 0xffff) * (y0 & 0xffff))
		a1 = C68kScript.u32(a0 + row)
		if restore:
			a3 = C68kScript.u32(src_base + x0 + (src_row & 0xffff) * (y0 & 0xffff))
			a4 = C68kScript.u32(a3 + src_row)
		err = C68kScript.s32(2 * dy - dx)
		diag = C68kScript.s32(2 * (dy - dx))
		straight = C68kScript.s32(dx + err)
		var dir: int = 1 if y1 > y0 else -1
		# Labels: 0 start, 1 word step (0xd432), 2 err check (0xd456), 3 end (0xd4c8).
		label = 0
		while true:
			match label:
				0:
					if (a0 & 1) != 0:
						put_b.call(a0, a3)
						put_b.call(a1, a4)
						a0 += 1
						a1 += 1
						a3 += 1
						a4 += 1
						label = 2
					else:
						label = 1
				1:
					put_w.call(a0, a3)
					put_w.call(a1, a4)
					a0 += 2
					a1 += 2
					a3 += 2
					a4 += 2
					if err > 0:
						a0 += row * dir
						a1 += row * dir
						a3 += src_row * dir
						a4 += src_row * dir
						if dir > 0:
							put_b.call(a1 - 1, a4 - 1)
						else:
							put_b.call(a0 - 1, a3 - 1)
						err = C68kScript.s32(err + diag)
					else:
						err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					label = 2 if d7 != 0xffff else 3
				2:
					if err > 0:
						if dir > 0:
							put_b.call(a0, a3)
						else:
							put_b.call(a1, a4)
						a0 += row * dir
						a1 += row * dir
						a3 += src_row * dir
						a4 += src_row * dir
						err = C68kScript.s32(err + diag)
					else:
						err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					if d7 != 0xffff:
						label = 1
					else:
						put_b.call(a0, a3)
						put_b.call(a1, a4)
						a0 += 1
						a1 += 1
						a3 += 1
						a4 += 1
						label = 3
				3:
					put_b.call(a0, a3)
					put_b.call(a1, a4)
					return
	# Y-major: two columns wide, top to bottom.
	if y1 < y0:
		var t2: int = x0
		x0 = x1
		x1 = t2
		t2 = y0
		y0 = y1
		y1 = t2
	d7 = (dy - 1) & 0xffff
	a0 = C68kScript.u32(base + x0 + (row & 0xffff) * (y0 & 0xffff))
	a1 = C68kScript.s32(row - 1)
	if restore:
		a3 = C68kScript.u32(src_base + x0 + (src_row & 0xffff) * (y0 & 0xffff))
		a4 = C68kScript.s32(src_row - 1)
	err = C68kScript.s32(2 * dx - dy)
	diag = C68kScript.s32(2 * (dx - dy))
	straight = C68kScript.s32(dy + err)
	var right: bool = x1 > x0
	# Labels: 0 start, 1 byte-pair step (0xd512 / 0xd564), 2 word step (0xd538 / 0xd58c), 3 end.
	label = 0
	while true:
		match label:
			0:
				if (a0 & 1) != 0:
					put_b.call(a0, a3)
					a0 += 1
					a3 += 1
					put_b.call(a0, a3)
					a0 += a1
					a3 += a4
					label = 1
				else:
					put_w.call(a0, a3)
					a0 += row
					a3 += src_row
					label = 2
			1:
				if err > 0:
					if right:
						put_b.call(a0, a3)
						a0 += 1
						a3 += 1
						put_w.call(a0, a3)
					else:
						put_b.call(a0 + 1, a3 + 1)
						a0 -= 1
						a3 -= 1
						put_w.call(a0, a3)
					a0 += row
					a3 += src_row
					err = C68kScript.s32(err + diag)
					d7 = (d7 - 1) & 0xffff
					label = 2 if d7 != 0xffff else 3
				else:
					put_b.call(a0, a3)
					a0 += 1
					a3 += 1
					put_b.call(a0, a3)
					a0 += a1
					a3 += a4
					err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					label = 1 if d7 != 0xffff else 3
			2:
				if err > 0:
					if right:
						put_w.call(a0, a3)
						a0 += 2
						a3 += 2
						put_b.call(a0, a3)
						a0 += a1
						a3 += a4
					else:
						put_w.call(a0, a3)
						a0 -= 1
						a3 -= 1
						put_b.call(a0, a3)
						a0 += row
						a3 += src_row
					err = C68kScript.s32(err + diag)
					d7 = (d7 - 1) & 0xffff
					label = 1 if d7 != 0xffff else 3
				else:
					put_w.call(a0, a3)
					a0 += row
					a3 += src_row
					err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					label = 2 if d7 != 0xffff else 3
			3:
				put_b.call(a0, a3)
				a0 += 1
				a3 += 1
				put_b.call(a0, a3)
				return

## 0xd3bc: a two-pixel-thick line in colour (low byte, doubled for words) on an 8-bit screen at
## base with row bytes (_line_depth8).
func draw_line_depth8(x0: int, y0: int, x1: int, y1: int, colour: int, base: int, row: int) -> void:
	assert(memory != null, "draw_line_depth8 requires original global memory")
	_line_depth8(false, x0, y0, x1, y1, colour, base, row, 0, 0)

## 0xd91a: the pixels draw_line_depth8 would set, copied back from the backup bitmap (src base /
## row bytes) onto the screen (base / row bytes) (_line_depth8).
func restore_line_depth8(x0: int, y0: int, x1: int, y1: int, base: int, row: int, src_base: int, src_row: int) -> void:
	assert(memory != null, "restore_line_depth8 requires original global memory")
	_line_depth8(true, x0, y0, x1, y1, 0, base, row, src_base, src_row)

## The shared two-pixel-thick Bresenham of draw_line_depth4 (0xd5b0) and restore_line_depth4
## (0xdb60) on 4-bit pixels (two per byte, the odd pixel in the low nibble), block for block as
## _line_depth8: the byte offset is x lsr 1; a byte holding both pixels of a pair is written
## whole, a lone pixel merges its nibble (low: (m & 0xf0) | (v & 0x0f), high: (m & 0x0f) |
## (v & 0xf0); eor / and / eor in the original). Draw takes v from the colour byte, restore from
## the backup bitmap byte at the matching address. One exit of each x-major direction writes the
## high and then the low nibble of the same bytes, as in the original.
func _line_depth4(restore: bool, x0: int, y0: int, x1: int, y1: int, colour: int, base: int, row: int, src_base: int, src_row: int) -> void:
	var cb: int = colour & 0xff
	var val := func(sp: int) -> int:
		return memory.read_u8(C68kScript.u32(sp)) if restore else cb
	var full := func(d: int, sp: int) -> void:
		memory.write_u8(C68kScript.u32(d), val.call(sp))
	var lo := func(d: int, sp: int) -> void:
		memory.write_u8(C68kScript.u32(d), (memory.read_u8(C68kScript.u32(d)) & 0xf0) | (val.call(sp) & 0x0f))
	var hi := func(d: int, sp: int) -> void:
		memory.write_u8(C68kScript.u32(d), (memory.read_u8(C68kScript.u32(d)) & 0x0f) | (val.call(sp) & 0xf0))
	var dx: int = abs_int(C68kScript.s32(x0 - x1))
	var dy: int = abs_int(C68kScript.s32(y0 - y1))
	var d7: int
	var err: int
	var straight: int
	var diag: int
	var a0: int
	var a1: int
	var a3: int = 0
	var a4: int = 0
	var label: int
	if not (dy > dx):
		if x1 < x0:
			var t: int = x0
			x0 = x1
			x1 = t
			t = y0
			y0 = y1
			y1 = t
		d7 = (dx - 1) & 0xffff
		a0 = C68kScript.u32(base + (C68kScript.u32(x0) >> 1) + (row & 0xffff) * (y0 & 0xffff))
		a1 = C68kScript.u32(a0 + row)
		if restore:
			a3 = C68kScript.u32(src_base + (C68kScript.u32(x0) >> 1) + (src_row & 0xffff) * (y0 & 0xffff))
			a4 = C68kScript.u32(a3 + src_row)
		err = C68kScript.s32(2 * dy - dx)
		diag = C68kScript.s32(2 * (dy - dx))
		straight = C68kScript.s32(dx + err)
		var dir: int = 1 if y1 > y0 else -1
		# Labels: 0 start, 1 pair step (0xd63e), 2 err check (0xd670), 3 end high (0xd786),
		# 4 end low (0xd76a).
		label = 0
		while true:
			match label:
				0:
					if (x0 & 1) != 0:
						lo.call(a0, a3)
						lo.call(a1, a4)
						a0 += 1
						a1 += 1
						a3 += 1
						a4 += 1
						label = 2
					else:
						label = 1
				1:
					full.call(a0, a3)
					full.call(a1, a4)
					a0 += 1
					a1 += 1
					a3 += 1
					a4 += 1
					if err > 0:
						a0 += row * dir
						a1 += row * dir
						a3 += src_row * dir
						a4 += src_row * dir
						if dir > 0:
							lo.call(a1 - 1, a4 - 1)
						else:
							lo.call(a0 - 1, a3 - 1)
						err = C68kScript.s32(err + diag)
					else:
						err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					label = 2 if d7 != 0xffff else 3
				2:
					if err > 0:
						if dir > 0:
							hi.call(a0, a3)
						else:
							hi.call(a1, a4)
						a0 += row * dir
						a1 += row * dir
						a3 += src_row * dir
						a4 += src_row * dir
						err = C68kScript.s32(err + diag)
					else:
						err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					if d7 != 0xffff:
						label = 1
					else:
						hi.call(a0, a3)
						hi.call(a1, a4)
						label = 4
				3:
					hi.call(a0, a3)
					hi.call(a1, a4)
					return
				4:
					lo.call(a0, a3)
					lo.call(a1, a4)
					return
	if y1 < y0:
		var t2: int = x0
		x0 = x1
		x1 = t2
		t2 = y0
		y0 = y1
		y1 = t2
	d7 = (dy - 1) & 0xffff
	a0 = C68kScript.u32(base + (C68kScript.u32(x0) >> 1) + (row & 0xffff) * (y0 & 0xffff))
	a1 = C68kScript.s32(row - 1)
	if restore:
		a3 = C68kScript.u32(src_base + (C68kScript.u32(x0) >> 1) + (src_row & 0xffff) * (y0 & 0xffff))
		a4 = C68kScript.s32(src_row - 1)
	err = C68kScript.s32(2 * dx - dy)
	diag = C68kScript.s32(2 * (dx - dy))
	straight = C68kScript.s32(dy + err)
	var right: bool = x1 > x0
	# Labels: 0 start, 1 pair column (0xd7fc / 0xd88e), 2 whole byte (0xd842 / 0xd8d4),
	# 3 end pair (0xd8f8), 4 end byte (0xd912).
	label = 0
	while true:
		match label:
			0:
				if (x0 & 1) != 0:
					lo.call(a0, a3)
					a0 += 1
					a3 += 1
					hi.call(a0, a3)
					a0 += a1
					a3 += a4
					label = 1
				else:
					full.call(a0, a3)
					a0 += row
					a3 += src_row
					label = 2
			1:
				if err > 0:
					if right:
						lo.call(a0, a3)
						a0 += 1
						a3 += 1
						full.call(a0, a3)
					else:
						hi.call(a0 + 1, a3 + 1)
						full.call(a0, a3)
					a0 += row
					a3 += src_row
					err = C68kScript.s32(err + diag)
					d7 = (d7 - 1) & 0xffff
					label = 2 if d7 != 0xffff else 4
				else:
					lo.call(a0, a3)
					a0 += 1
					a3 += 1
					hi.call(a0, a3)
					a0 += a1
					a3 += a4
					err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					label = 1 if d7 != 0xffff else 3
			2:
				if err > 0:
					if right:
						full.call(a0, a3)
						a0 += 1
						a3 += 1
						hi.call(a0, a3)
						a0 += a1
						a3 += a4
					else:
						full.call(a0, a3)
						a0 -= 1
						a3 -= 1
						lo.call(a0, a3)
						a0 += row
						a3 += src_row
					err = C68kScript.s32(err + diag)
					d7 = (d7 - 1) & 0xffff
					label = 1 if d7 != 0xffff else 3
				else:
					full.call(a0, a3)
					a0 += row
					a3 += src_row
					err = C68kScript.s32(err + straight)
					d7 = (d7 - 1) & 0xffff
					label = 2 if d7 != 0xffff else 4
			3:
				lo.call(a0, a3)
				a0 += 1
				a3 += 1
				hi.call(a0, a3)
				return
			4:
				full.call(a0, a3)
				return

## 0xd5b0: a two-pixel-thick line in colour (low byte) on a 4-bit screen (_line_depth4).
func draw_line_depth4(x0: int, y0: int, x1: int, y1: int, colour: int, base: int, row: int) -> void:
	assert(memory != null, "draw_line_depth4 requires original global memory")
	_line_depth4(false, x0, y0, x1, y1, colour, base, row, 0, 0)

## 0xdb60: the pixels draw_line_depth4 would set, copied back from the backup bitmap
## (_line_depth4).
func restore_line_depth4(x0: int, y0: int, x1: int, y1: int, base: int, row: int, src_base: int, src_row: int) -> void:
	assert(memory != null, "restore_line_depth4 requires original global memory")
	_line_depth4(true, x0, y0, x1, y1, 0, base, row, src_base, src_row)

## A face record of the prepared object (0x20 bytes, sext word index).
func _face_record(index: int) -> int:
	return C68kScript.u32(memory.read_u32(DAT_00025f30) + C68kScript.s32(C68kScript.s16(index) * 32))

## Emit: face +2 = draw_order_next (then incremented) when numbered; the face joins the queue.
func _emit_face(face: int, numbered: bool) -> void:
	if numbered:
		memory.write_u16(face + 2, memory.read_u16(DAT_0001c1be))
		memory.write_u16(DAT_0001c1be, C68kScript.u16(memory.read_u16(DAT_0001c1be) + 1))
	var q: int = memory.read_u32(DAT_00025d2c)
	memory.write_u32(q, face)
	memory.write_u32(DAT_00025d2c, C68kScript.u32(q + 4))

## face_is_back_facing(sext index, face) entered depth below the caller's entry.
func _call_back_facing(entry_a7: int, depth: int, index: int, face: int) -> int:
	a7 = entry_a7 - depth
	var r: int = face_is_back_facing(index, face)
	a7 = entry_a7
	return r

## 0x9d34 (three saved registers): walk the +0x12 chain from face index: faces nearer than
## distance (long +0x1c < it) or flagged +0x13 bit 1 are skipped; a one-sided face (+0x13 bit 0
## clear) that faces away (face_is_back_facing, 0x18 below) ends the walk; the others are
## numbered and queued.
func emit_face_chain(index: int, distance: int) -> void:
	assert(memory != null, "emit_face_chain requires original global memory")
	var entry_a7: int = a7
	var i: int = C68kScript.s16(index)
	while true:
		var face: int = _face_record(i)
		if not (distance > memory.read_s32(face + 0x1c)) and (memory.read_u8(face + 0x13) & 2) == 0:
			if (memory.read_u8(face + 0x13) & 1) == 0 and _call_back_facing(entry_a7, 0x18, i, face) != 0:
				return
			_emit_face(face, true)
		i = memory.read_s8(face + 0x12)
		if i < 0:
			return

## Near mode (near_mode != 0): a back-facing face is kept in the back-face queue when one-sided,
## else flagged (+0x13 |= 0x10) and processed; a front-facing one loses the flag. Returns
## [back-facing, skip-emit] for emit_faces_bsp, or for the root walks whether to stop.
func _face_near_mode(face: int, back: int, one_sided: bool) -> bool:
	if back != 0:
		if one_sided:
			var q: int = memory.read_u32(DAT_00025b28)
			memory.write_u32(q, face)
			memory.write_u32(DAT_00025b28, C68kScript.u32(q + 4))
			return true
		memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) | 0x10)
	else:
		memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) & 0xef)
	return false

## 0x9da6 (six saved registers): BSP draw order from node index. Back-facing (face_is_back_facing,
## 0x24 below) and near mode as in the root walks (a kept one-sided back face is not emitted); a
## back-facing one-sided face outside near mode is not emitted; a far (+0x1c < the object
## distance, long +0x10 of prepared_object) or +0x13 bit 1 face is not emitted either. Otherwise it
## is numbered and queued. Then the far side first: back-facing -> front subtree (+0x10), else back
## subtree (+0x11) (0x20 below); the face is renumbered; when it was emitted its +0x12 chain
## follows (emit_face_chain, 0x24 below); then the other subtree.
func emit_faces_bsp(node: int) -> void:
	assert(memory != null, "emit_faces_bsp requires original global memory")
	var entry_a7: int = a7
	var idx: int = C68kScript.s16(node)
	var distance: int = memory.read_s32(memory.read_u32(DAT_00025b24) + 0x10)
	var face: int = _face_record(idx)
	var skip: bool = false
	var one_sided: bool = (memory.read_u8(face + 0x13) & 1) == 0
	var back: int = _call_back_facing(entry_a7, 0x24, idx, face)
	var emit_check: bool = true
	if memory.read_u16(DAT_00025b16) != 0:
		if back != 0:
			skip = true
		if _face_near_mode(face, back, one_sided):
			emit_check = false
	elif back != 0:
		skip = true
		if one_sided:
			emit_check = false
	if emit_check:
		if distance > memory.read_s32(face + 0x1c) or (memory.read_u8(face + 0x13) & 2) != 0:
			skip = true
		else:
			_emit_face(face, true)
	var first: int = 0x10 if back != 0 else 0x11
	var second: int = 0x11 if back != 0 else 0x10
	if memory.read_s8(face + first) >= 0:
		a7 = entry_a7 - 0x20
		emit_faces_bsp(memory.read_s8(face + first))
		a7 = entry_a7
	memory.write_u16(face + 2, memory.read_u16(DAT_0001c1be))
	memory.write_u16(DAT_0001c1be, C68kScript.u16(memory.read_u16(DAT_0001c1be) + 1))
	if not skip and memory.read_s8(face + 0x12) >= 0:
		a7 = entry_a7 - 0x24
		emit_face_chain(memory.read_s8(face + 0x12), distance)
		a7 = entry_a7
	if memory.read_s8(face + second) >= 0:
		a7 = entry_a7 - 0x20
		emit_faces_bsp(memory.read_s8(face + second))
		a7 = entry_a7

## The root walks of emit_faces_in_order (0x9ef8) and emit_faces_unnumbered (0x9fc4), seven saved
## registers: for each of root_face_count roots (dbra word), its +0x12 chain until a face is far
## (+0x1c < the object distance) or +0x13 bit 1 (next root). Near mode: back-facing one-sided faces
## go to the back-face queue and end the chain, the others are flagged as in emit_faces_bsp; outside
## it a back-facing one-sided face ends the chain (face_is_back_facing 0x28 below). Faces reached are
## queued (numbered unless unnumbered).
func _emit_root_chains(numbered: bool) -> void:
	var entry_a7: int = a7
	var distance: int = memory.read_s32(memory.read_u32(DAT_00025b24) + 0x10)
	var roots: int = memory.read_u16(DAT_00025b18)
	var root: int = 0
	while true:
		roots = (roots - 1) & 0xffff
		if roots == 0xffff:
			break
		var i: int = C68kScript.s16(root)
		while true:
			var face: int = _face_record(i)
			if distance > memory.read_s32(face + 0x1c) or (memory.read_u8(face + 0x13) & 2) != 0:
				break
			var one_sided: bool = (memory.read_u8(face + 0x13) & 1) == 0
			if memory.read_u16(DAT_00025b16) != 0:
				if _face_near_mode(face, _call_back_facing(entry_a7, 0x28, i, face), one_sided):
					break
			elif one_sided and _call_back_facing(entry_a7, 0x28, i, face) != 0:
				break
			_emit_face(face, numbered)
			i = memory.read_s8(face + 0x12)
			if i < 0:
				break
		root = C68kScript.s16(root + 1)

## 0x9ef8: root chains, faces numbered.
func emit_faces_in_order() -> void:
	assert(memory != null, "emit_faces_in_order requires original global memory")
	_emit_root_chains(true)

## 0x9fc4: root chains, faces queued without numbers.
func emit_faces_unnumbered() -> void:
	assert(memory != null, "emit_faces_unnumbered requires original global memory")
	_emit_root_chains(false)

## 0xa07e (five saved address registers): clip the n points of clip_poly_buf at the alternate
## bottom row (clip_y_max temporarily clip_y_max_alt; clip_polygon_y_max into screen_poly_x, 0x24
## below); none left -> 0. Then each edge (previous point, point) of the ground polygon: a
## previous point on the top (clip_y_min) or alternate bottom row in a left / right screen corner
## sets horizon_corners bit 1 / 2 (top) or 4 / 8 (bottom); an edge not lying along a screen border
## (same y on the top / bottom row, or same x on the left / right column) becomes the horizon edge
## (x0, y0)-(x1, y1). Returns 1.
func track_ground_plane_horizon(n: int) -> int:
	assert(memory != null, "track_ground_plane_horizon requires original global memory")
	var entry_a7: int = a7
	var saved: int = memory.read_u16(DAT_0001b73e)
	memory.write_u16(DAT_0001b73e, memory.read_u16(DAT_0001b740))
	a7 = entry_a7 - 0x24
	var count: int = clip_polygon_y_max(DAT_00025252, n, DAT_00024df2)
	a7 = entry_a7
	memory.write_u16(DAT_0001b73e, saved)
	if count == 0:
		return 0
	var top: int = memory.read_s16(DAT_00020aea)
	var left: int = memory.read_s16(DAT_00020aee)
	var right: int = memory.read_s16(DAT_00020aec)
	var bottom: int = memory.read_s16(DAT_0001b740)
	var prev: int = C68kScript.u32(DAT_00024df2 + 8 * (count - 1))
	var cur: int = DAT_00024df2
	var left_count: int = count
	while true:
		var px: int = memory.read_s32(prev)
		var py: int = memory.read_s32(prev + 4)
		var bit: int = 0
		if py == top:
			bit = 1 if px == left else (2 if px == right else 0)
		elif py == bottom:
			bit = 4 if px == left else (8 if px == right else 0)
		if bit != 0:
			memory.write_u32(DAT_0001bd90, memory.read_u32(DAT_0001bd90) | bit)
		var cx: int = memory.read_s32(cur)
		var cy: int = memory.read_s32(cur + 4)
		var border: bool = false
		if py == cy and (cy == bottom or cy == top):
			border = true
		elif px == cx and (cx == left or cx == right):
			border = true
		if not border:
			memory.write_u32(DAT_0001bda0, C68kScript.u32(px))
			memory.write_u32(DAT_0001bd9c, C68kScript.u32(py))
			memory.write_u32(DAT_0001bd98, C68kScript.u32(cx))
			memory.write_u32(DAT_0001bd94, C68kScript.u32(cy))
		left_count = C68kScript.u32(left_count - 1)
		prev = cur
		cur = C68kScript.u32(cur + 8)
		if left_count == 0:
			return 1
	return 1

## 0x9b8c (six saved registers): rasterise the clipped polygon's edges for face. Word +0 = 0. A
## face with a palette slot (+0xf != 0xff) marks it used (slot_usage_cur) when it still owns it
## (palette_owner_current), else assign_face_colour (0x20 below) gives it one (failure -> return).
## The x of every point becomes 16.16 with 0x8000; then each non-horizontal edge (from the first
## point back round the polygon) takes the next pool record (0x1c bytes at session_entry_ptr): +0
## face, +4 0, +0x16 top row + half rows, +0xc top x + half width << 16, +0x10 slope (dx / dy). An
## edge at the centre column with no slope is dropped (its record stays counted). Others go into
## the top row's bucket, sorted by x then slope; an equal edge of the same row with no second face
## takes this face in +4 instead; an inserted edge flags its row (row_has_edges).
func add_face_edges_to_rows(face: int) -> void:
	assert(memory != null, "add_face_edges_to_rows requires original global memory")
	var entry_a7: int = a7
	var n: int = memory.read_u16(DAT_00025b1a)
	memory.write_u16(face, 0)
	var slot: int = memory.read_u8(face + 0xf)
	if slot != 0xff:
		if memory.read_u32(C68kScript.u32(memory.read_u32(DAT_0001da7c) + slot * 4)) == C68kScript.u32(face):
			memory.write_u8(C68kScript.u32(memory.read_u32(DAT_0001d864) + slot), 1)
		else:
			a7 = entry_a7 - 0x20
			var failed: int = assign_face_colour(face)
			a7 = entry_a7
			if failed != 0:
				return
			memory.write_u8(C68kScript.u32(memory.read_u32(DAT_0001d864) + memory.read_u8(face + 0xf)), 1)
	var k: int = n
	var p: int = DAT_00024df2
	while k != 0:
		memory.write_u32(p, C68kScript.u32(C68kScript.lsl32(memory.read_u32(p), 16) + 0x8000))
		p += 8
		k = (k - 1) & 0xffff
	var half_rows: int = memory.read_s16(DAT_00020b2c)
	var a0: int = DAT_00024df2
	var d3: int = n
	while true:
		d3 = (d3 - 1) & 0xffff
		if d3 == 0xffff:
			break
		var a3: int = C68kScript.u32(DAT_00024df2 + 8 * C68kScript.s16(d3))
		if memory.read_s32(a0 + 4) != memory.read_s32(a3 + 4):
			var rec: int = C68kScript.u32(memory.read_u32(DAT_0001b76c) + C68kScript.s32(0x1c * memory.read_s32(DAT_00020ab0)))
			memory.write_u32(rec, C68kScript.u32(face))
			memory.write_u32(rec + 4, 0)
			var top_x: int
			var top_y: int
			var dxv: int
			var dyv: int
			if memory.read_s32(a0 + 4) > memory.read_s32(a3 + 4):
				memory.write_u16(rec + 0x16, C68kScript.u16(memory.read_u16(a0 + 6) + half_rows))
				top_x = memory.read_s32(a3)
				top_y = memory.read_s32(a3 + 4)
				dxv = C68kScript.s32(memory.read_s32(a0) - top_x)
				dyv = memory.read_s32(a0 + 4)
			else:
				memory.write_u16(rec + 0x16, C68kScript.u16(memory.read_u16(a3 + 6) + half_rows))
				top_x = memory.read_s32(a0)
				top_y = memory.read_s32(a0 + 4)
				dxv = C68kScript.s32(memory.read_s32(a3) - top_x)
				dyv = memory.read_s32(a3 + 4)
			memory.write_u32(rec + 0x10, C68kScript.u32(C68kScript.divs_trunc(dxv, C68kScript.s32(dyv - top_y))))
			var row: int = C68kScript.s32(top_y + half_rows)
			memory.write_u32(rec + 0xc, C68kScript.u32(top_x + C68kScript.lsl32(memory.read_s16(DAT_00020b2a), 16)))
			memory.write_u32(DAT_00020ab0, C68kScript.u32(memory.read_u32(DAT_00020ab0) + 1))
			if not (memory.read_u32(rec + 0xc) == memory.read_u32(DAT_00020af0) and memory.read_u32(rec + 0x10) == 0):
				var link: int = C68kScript.u32(DAT_0001eaac + row * 4)
				var node: int = memory.read_u32(link)
				var merged: bool = false
				while node != 0:
					var rc: int = memory.read_s32(rec + 0xc)
					var nc: int = memory.read_s32(node + 0xc)
					if rc < nc:
						break
					if rc == nc:
						var rs: int = memory.read_s32(rec + 0x10)
						var ns: int = memory.read_s32(node + 0x10)
						if rs < ns:
							break
						if rs == ns and memory.read_u16(node + 0x16) == memory.read_u16(rec + 0x16) and memory.read_u32(node + 4) == 0:
							memory.write_u32(node + 4, C68kScript.u32(face))
							merged = true
							break
					link = C68kScript.u32(node + 0x18)
					node = memory.read_u32(link)
				if not merged:
					memory.write_u32(rec + 0x18, memory.read_u32(link))
					memory.write_u32(link, rec)
					memory.write_u16(C68kScript.u32(DAT_0001daa4 + memory.read_s16(rec + 0x16) * 2), 1)
		a0 = a3

## The four clip passes of the face outputs (clip_polygon_x_min / x_max / y_min into the ping-pong
## buffers, 0x18 below: both outputs save two registers), the ground-plane horizon for the ground
## face (track_ground_plane_horizon, 0x10 below) and clip_polygon_y_max into
## screen_poly_x (its count stored in screen_poly_count). Returns false when a pass leaves nothing.
func _clip_face_polygon(face: int, entry_a7: int, clip_depth: int, track_depth: int) -> bool:
	a7 = entry_a7 - clip_depth
	var n: int = C68kScript.s16(clip_polygon_x_min(DAT_00024df2, memory.read_s16(DAT_00025b1a), DAT_00025252))
	if n == 0:
		a7 = entry_a7
		return false
	n = C68kScript.s16(clip_polygon_x_max(DAT_00025252, n, DAT_00024df2))
	if n == 0:
		a7 = entry_a7
		return false
	n = C68kScript.s16(clip_polygon_y_min(DAT_00024df2, n, DAT_00025252))
	if n == 0:
		a7 = entry_a7
		return false
	if C68kScript.u32(face) == memory.read_u32(DAT_0001bda8):
		a7 = entry_a7 - track_depth
		var ok: int = track_ground_plane_horizon(n)
		if ok == 0:
			a7 = entry_a7
			return false
	a7 = entry_a7 - clip_depth
	var last: int = clip_polygon_y_max(DAT_00025252, n, DAT_00024df2)
	a7 = entry_a7
	memory.write_u16(DAT_00025b1a, C68kScript.u16(last))
	return C68kScript.s16(last) != 0

## 0xa16e (two saved registers): clip the screen polygon (_clip_face_polygon) and rasterise it
## into the row buckets (add_face_edges_to_rows, 0x10 below). Returns 1, or 0 when clipped away.
func output_face_colour(face: int) -> int:
	assert(memory != null, "output_face_colour requires original global memory")
	var entry_a7: int = a7
	if not _clip_face_polygon(face, entry_a7, 0x18, 0x10):
		return 0
	a7 = entry_a7 - 0x10
	add_face_edges_to_rows(face)
	a7 = entry_a7
	return 1

## 0xa220 (two saved registers): clip the screen polygon and hand it to the host polygon routine
## (+0x7c)(count, face +4, sext word face +2, screen_poly_x) (0x1c below). Returns 1, or 0 when
## clipped away.
func output_face_bw(face: int) -> int:
	assert(memory != null, "output_face_bw requires original global memory")
	var entry_a7: int = a7
	if not _clip_face_polygon(face, entry_a7, 0x18, 0x10):
		return 0
	a7 = entry_a7 - 0x1c
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x7c), [memory.read_s16(DAT_00025b1a), memory.read_u32(face + 4), memory.read_s16(face + 2), DAT_00024df2])
	a7 = entry_a7
	return 1

## Project one camera-space vertex (words +2 / +6 / +0xa at view) into the (x, y) long pair at
## out: z > 4 -> x = (x muls.w proj_scale_x) divs z, y = (-y muls.l proj_scale_y) divs z; otherwise
## x = 0x80000000 (behind the near plane; y left as it was).
func _project_view_vertex(view: int, out: int) -> void:
	var z: int = memory.read_s16(view + 0xa)
	if z > 4:
		memory.write_u32(out, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(view + 2) * memory.read_s16(DAT_00020b28)), z)))
		memory.write_u32(out + 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(-memory.read_s16(view + 6) * memory.read_s16(DAT_00020b26)), z)))
	else:
		memory.write_u32(out, 0x80000000)

## 0xa512 (link.w a6,#-0x14): bring the face's vertices into camera space once per frame
## (vertex_done): (vertex asr vertex_shift) - eye, as words, through object_matrix ((sum of muls.w
## + 0x800) asr 12, words +2 / +6 / +0xa of view_vertices), then projected (_project_view_vertex).
func transform_face_vertices(face: int) -> void:
	assert(memory != null, "transform_face_vertices requires original global memory")
	var eye_x: int = memory.read_u16(DAT_00024d60)
	var eye_y: int = memory.read_u16(DAT_00024d5e)
	var eye_z: int = memory.read_u16(DAT_00024d5c)
	var m: int = memory.read_u32(DAT_00024d62)
	var cursor: int = memory.read_u32(face + 0x18)
	var verts: int = memory.read_u32(memory.read_u32(DAT_00025b24) + 0x44)
	var view: int = memory.read_u32(DAT_00025b20)
	var shift: int = memory.read_s16(DAT_00024d5a)
	var left: int = memory.read_u16(face + 0x14)
	while true:
		left = (left - 1) & 0xffff
		if left == 0xffff:
			return
		var i: int = memory.read_s16(cursor)
		if memory.read_u8(C68kScript.u32(DAT_00024d66 + i)) == 0:
			var out: int = C68kScript.u32(view + 12 * i)
			var v: int = C68kScript.u32(verts + 12 * i)
			memory.write_u8(C68kScript.u32(DAT_00024d66 + i), 1)
			var d0: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v), shift) - eye_x)
			var d1: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 4), shift) - eye_y)
			var d2: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 8), shift) - eye_z)
			for k in 3:
				var acc: int = C68kScript.s32(d0 * memory.read_s16(m + 2 * k) + d1 * memory.read_s16(m + 6 + 2 * k) + d2 * memory.read_s16(m + 12 + 2 * k) + 0x800)
				memory.write_u16(out + 2 + 4 * k, C68kScript.u16(C68kScript.asr32(acc, 12)))
			_project_view_vertex(out, C68kScript.u32(DAT_000256b2 + 8 * i))
		cursor = C68kScript.u32(cursor + 2)

## One near-plane crossing between camera-space vertices a (behind) and b (in front): t = (5 -
## a.z) / (b.z - a.z); x = ((b.x - a.x) * (5 - a.z) divs dz + a.x) (word) muls.w proj_scale_x divs 5,
## y = ((a.y - b.y) * (5 - a.z) divs dz - a.y) (word) muls.w proj_scale_y divs 5.
func _near_plane_point(a: int, b: int, out: int) -> void:
	var dz: int = C68kScript.s32(memory.read_s16(b + 0xa) - memory.read_s16(a + 0xa))
	var t: int = C68kScript.s32(5 - memory.read_s16(a + 0xa))
	var x: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.s32(memory.read_s16(b + 2) - memory.read_s16(a + 2)) * t), dz) + memory.read_u16(a + 2))
	memory.write_u32(out, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(x * memory.read_s16(DAT_00020b28)), 5)))
	var y: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(C68kScript.s32(memory.read_s16(a + 6) - memory.read_s16(b + 6)) * t), dz) - memory.read_u16(a + 6))
	memory.write_u32(out + 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(y * memory.read_s16(DAT_00020b26)), 5)))

## 0xb028 (link.w a6,#-8): clip a face polygon (count word at count_ptr, vertex indices) against
## the near plane z = 5, writing projected points to out: a vertex in front (z > 4) keeps its
## projected point; an edge crossing the plane adds the crossing (_near_plane_point). The new
## count is stored; returns 1 when any vertex was behind.
func clip_face_near_plane(count_ptr: int, view: int, indices: int, projected: int, out: int) -> int:
	assert(memory != null, "clip_face_near_plane requires original global memory")
	var clipped: int = 0
	var count: int = memory.read_s16(count_ptr)
	var prev: int = C68kScript.u32(view + 12 * memory.read_s16(C68kScript.u32(indices + 2 * count - 2)))
	var o: int = out
	var cursor: int = indices
	var left: int = count
	while left != 0:
		var i: int = memory.read_s16(cursor)
		var cur: int = C68kScript.u32(view + 12 * i)
		var cur_pt: int = C68kScript.u32(projected + 8 * i)
		if memory.read_s16(cur + 0xa) > 4:
			if memory.read_s16(prev + 0xa) <= 4:
				clipped = 1
				_near_plane_point(prev, cur, o)
				o += 8
			memory.write_u32(o, memory.read_u32(cur_pt))
			memory.write_u32(o + 4, memory.read_u32(cur_pt + 4))
			o += 8
		else:
			clipped = 1
			if memory.read_s16(prev + 0xa) > 4:
				_near_plane_point(cur, prev, o)
				o += 8
		prev = cur
		left = C68kScript.s32(left - 1)
		cursor = C68kScript.u32(cursor + 2)
	memory.write_u16(count_ptr, C68kScript.u16(C68kScript.asr32(C68kScript.s32(o - out), 3)))
	return clipped

## 0xa676: set the renderer up for prepared_object: view_vertices = +0x4c, face_table = +0x48,
## root_face_count = word +0x38, vertex_shift = word +0x32, face_normals = +0x44 + 12 * sext word
## +0x36, vertex0 = the first model vertex; every view vertex (word +0x36 of them) is projected
## (_project_view_vertex) and every face (word +0x3a) gets +0x13 |= 0x60.
func project_prepared_object() -> void:
	assert(memory != null, "project_prepared_object requires original global memory")
	var obj: int = memory.read_u32(DAT_00025b24)
	memory.write_u32(DAT_00025b20, memory.read_u32(obj + 0x4c))
	memory.write_u32(DAT_00025f30, memory.read_u32(obj + 0x48))
	memory.write_u16(DAT_00025b18, memory.read_u16(obj + 0x38))
	memory.write_u16(DAT_00024d5a, memory.read_u16(obj + 0x32))
	memory.write_u32(DAT_00024d4a, C68kScript.u32(C68kScript.s32(memory.read_s16(obj + 0x36) * 12) + memory.read_u32(obj + 0x44)))
	var verts: int = memory.read_u32(obj + 0x44)
	for k in 3:
		memory.write_u32(DAT_00024d4e + 4 * k, memory.read_u32(verts + 4 * k))
	var view: int = memory.read_u32(DAT_00025b20)
	var out: int = DAT_000256b2
	var left: int = memory.read_u16(memory.read_u32(DAT_00025b24) + 0x36)
	while true:
		left = (left - 1) & 0xffff
		if left == 0xffff:
			break
		_project_view_vertex(view, out)
		view += 12
		out += 8
	var faces_left: int = memory.read_u16(memory.read_u32(DAT_00025b24) + 0x3a)
	var flag: int = C68kScript.u32(memory.read_u32(DAT_00025f30) + 0x13)
	while true:
		faces_left = (faces_left - 1) & 0xffff
		if faces_left == 0xffff:
			break
		memory.write_u8(flag, memory.read_u8(flag) | 0x60)
		flag += 0x20

## Near-mode penetration test of a face: point_in_polygon_xy(0, 0, view_vertices, sext word +0x14,
## +0x18) (0x38 below) -> dispatch_collision(player object, prepared_object) (0x2c below).
func _face_penetration(entry_a7: int, face: int) -> void:
	a7 = entry_a7 - 0x38
	var hit: int = point_in_polygon_xy(0, 0, memory.read_u32(DAT_00025b20), memory.read_s16(face + 0x14), memory.read_u32(face + 0x18))
	if hit != 0:
		a7 = entry_a7 - 0x2c
		dispatch_collision(memory.read_u32(memory.read_u32(DAT_0001b738)), memory.read_u32(DAT_00025b24))
	a7 = entry_a7

## 0xa2f2 (eight saved registers): output the queued faces. Each face's vertices are transformed
## unless +0x13 has both 0x20 and 0x40 (then 0x20 is set; transform_face_vertices 0x28 below);
## bit 0x40 is cleared. Its projected points are copied into screen_poly_x unless one is behind the
## near plane or force_near_clip is set: then clip_face_near_plane (0x38 below) builds them and a
## clip sets face_was_clipped. In near mode, a face whose back-facing flag (bit 4) differs from its
## inside flag (bit 3) runs the penetration test (not on near mode 2), and bit 3 takes bit 4. A
## face with points goes to depth_routine_ab4 (0x28 below); any drawn face sets object +4 bit 2,
## else it is cleared. In near mode the kept back faces then run the penetration test (unless near
## mode 2 or already inside; transformed first, without setting 0x20) and become inside. Without a
## near-plane clip, object +4 bit 3 is cleared.
func submit_object_faces() -> void:
	assert(memory != null, "submit_object_faces requires original global memory")
	var entry_a7: int = a7
	var drawn: bool = false
	var queue: int = DAT_00025d30
	var left: int = C68kScript.asr32(C68kScript.s32(memory.read_u32(DAT_00025d2c) - DAT_00025d30), 2) & 0xffff
	while true:
		left = (left - 1) & 0xffff
		if left == 0xffff:
			break
		var face: int = memory.read_u32(queue)
		queue += 4
		if (memory.read_u8(face + 0x13) & 0x60) != 0x60:
			memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) | 0x20)
			a7 = entry_a7 - 0x28
			transform_face_vertices(face)
			a7 = entry_a7
		memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) & 0xbf)
		memory.write_u16(DAT_00025b1a, memory.read_u16(face + 0x14))
		var need_clip: bool = memory.read_u16(DAT_00025b14) != 0
		if not need_clip:
			var out: int = DAT_00024df2
			var idx: int = memory.read_u32(face + 0x18)
			var n: int = memory.read_u16(DAT_00025b1a)
			while true:
				n = (n - 1) & 0xffff
				if n == 0xffff:
					break
				var entry: int = C68kScript.u32(DAT_000256b2 + 8 * memory.read_s16(idx))
				idx += 2
				memory.write_u32(out + 4, memory.read_u32(entry + 4))
				memory.write_u32(out, memory.read_u32(entry))
				if memory.read_u32(entry) == 0x80000000:
					need_clip = true
					break
				out += 8
		if need_clip:
			a7 = entry_a7 - 0x38
			var hit: int = clip_face_near_plane(DAT_00025b1a, memory.read_u32(DAT_00025b20), memory.read_u32(face + 0x18), DAT_000256b2, DAT_00024df2)
			a7 = entry_a7
			if hit != 0:
				memory.write_u16(DAT_00025b12, 1)
		if memory.read_u16(DAT_00025b16) != 0:
			var flipped: int = 1 if (memory.read_u8(face + 0x13) & 0x10) != 0 else 0
			if memory.read_s16(DAT_00025b16) != 2:
				var inside: int = 1 if (memory.read_u8(face + 0x13) & 8) != 0 else 0
				if (flipped ^ inside) != 0:
					_face_penetration(entry_a7, face)
			if flipped != 0:
				memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) | 8)
			else:
				memory.write_u8(face + 0x13, memory.read_u8(face + 0x13) & 0xf7)
		if memory.read_u16(DAT_00025b1a) != 0:
			a7 = entry_a7 - 0x28
			var r = _jsr(memory.read_u32(DAT_00020ab4), [face])
			a7 = entry_a7
			if int(r) != 0:
				drawn = true
	if memory.read_u16(DAT_00025b16) != 0:
		var back: int = DAT_00025b2c
		var count: int = C68kScript.asr32(C68kScript.s32(memory.read_u32(DAT_00025b28) - DAT_00025b2c), 2) & 0xffff
		while true:
			count = (count - 1) & 0xffff
			if count == 0xffff:
				break
			var face2: int = memory.read_u32(back)
			back += 4
			if memory.read_s16(DAT_00025b16) != 2 and (memory.read_u8(face2 + 0x13) & 8) == 0:
				if (memory.read_u8(face2 + 0x13) & 0x60) != 0x60:
					a7 = entry_a7 - 0x28
					transform_face_vertices(face2)
					a7 = entry_a7
				_face_penetration(entry_a7, face2)
			memory.write_u8(face2 + 0x13, memory.read_u8(face2 + 0x13) | 8)
	var obj: int = memory.read_u32(DAT_00025b24)
	if drawn:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 4)
	else:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xfffffffb)
	if memory.read_u16(DAT_00025b12) == 0:
		memory.write_u32(obj + 4, memory.read_u32(memory.read_u32(DAT_00025b24) + 4) & 0xfffffff7)

## A long shifted by a signed count: asr by -n when n < 0, else asl by n.
func _shift_signed(v: int, n: int) -> int:
	if n < 0:
		return C68kScript.asr32(v, -n)
	return C68kScript.s32(C68kScript.lsl32(v, n))

## update_object_distance_band (0x6c below) and, when it changed the band (or always), shade
## (0x68 below) for the prepared object.
func _band_and_shade(entry_a7: int, always_shade: bool, haze: int) -> void:
	var obj: int = memory.read_u32(DAT_00025b24)
	var changed: int = 0
	if haze != 0:
		a7 = entry_a7 - 0x6c
		changed = update_object_distance_band(obj, memory.read_s32(obj + 0x10))
	if always_shade or changed != 0:
		a7 = entry_a7 - 0x68
		shade_object_faces(memory.read_u32(DAT_00025b24))
	a7 = entry_a7

## 0xa75e (link.w a6,#-0x34, ten saved registers: body 0x60 below the entry): bring the prepared
## object into camera space. object_matrix = the camera matrix; vertex_shift = word +0x32; the
## eye is the camera shifted by (word +0x34 - shift) (asr when negative). With a controller: an
## unlinked one (*ctl == 0) returns 4; its definition pre-render hook (+0xe)(ctl, 1) (0x6c below)
## may return bit 2 (return 4), bit 0 (keep the attitude) and bit 1 (call it again with 2 at the
## end). An oriented object (byte +5 bit 4) builds its attitude from ctl words +0x20 / +0x22 / +0x24
## (unless bit 0; 0x74 below), object_matrix = attitude x camera (0x24d38, 0x70 below), the
## inverse attitude through invoke_tagged_attitude_compose_neg_sins4 (0x74 below), and the eye
## becomes (camera - object position) shifted and rotated into the object (transform_vecs12, 0x74
## below; with host word +0xb2 and byte +6 bit 0 the light vector turns with it for shading and is
## then restored). Otherwise (or with no controller unless byte +6 bit 1) the distance band and
## shade follow when host word +0xaa. Then the renderer globals are set as in
## project_prepared_object, vertex_done is cleared ((count / 4) + 1 longs), faces marked 0x20 but
## not 0x40 take 0x40 and mark their vertices (others lose 0x20), and every marked vertex is
## transformed and projected (y by neg.w / muls.w). Returns 0.
func transform_and_project_object() -> int:
	assert(memory != null, "transform_and_project_object requires original global memory")
	assert(a7 != 0, "transform_and_project_object needs a7 (its frame holds the eye vectors)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var rel: int = a6 - 0x24
	memory.write_u32(DAT_00024d62, DAT_0001d744)
	var world: int = memory.read_u32(DAT_0001b5a0)
	var haze: int = memory.read_s16(world + 0xaa)
	var lit: int = memory.read_s16(world + 0xb2)
	var obj: int = memory.read_u32(DAT_00025b24)
	memory.write_u16(DAT_00024d5a, memory.read_u16(obj + 0x32))
	var shift: int = C68kScript.s16(memory.read_u16(obj + 0x34) - memory.read_u16(DAT_00024d5a))
	memory.write_u16(DAT_00024d60, C68kScript.u16(_shift_signed(memory.read_s32(DAT_0001d838), shift)))
	memory.write_u16(DAT_00024d5e, C68kScript.u16(_shift_signed(memory.read_s32(DAT_0001d834), shift)))
	memory.write_u16(DAT_00024d5c, C68kScript.u16(_shift_signed(memory.read_s32(DAT_0001d830), shift)))
	var ctl: int = memory.read_u32(memory.read_u32(DAT_00025b24) + 8)
	if ctl == 0:
		if (memory.read_u8(memory.read_u32(DAT_00025b24) + 6) & 2) == 0:
			_band_and_shade(entry_a7, false, haze)
	else:
		if memory.read_u32(ctl) == 0:
			return 4
		var hook: int = memory.read_u32(memory.read_u32(ctl + 4) + 0xe)
		var res: int = 0
		if hook != 0:
			a7 = entry_a7 - 0x6c
			res = int(_jsr(hook, [ctl, 1]))
			a7 = entry_a7
			if (res & 4) != 0:
				return 4
		obj = memory.read_u32(DAT_00025b24)
		if (memory.read_u8(obj + 5) & 0x10) == 0:
			_band_and_shade(entry_a7, false, haze)
		else:
			if (res & 1) == 0:
				a7 = entry_a7 - 0x74
				build_attitude_matrix_3ang(memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24), DAT_0001d72c)
			a7 = entry_a7 - 0x70
			matmul3x3_s16(DAT_0001d72c, DAT_0001d744, DAT_00024d38)
			memory.write_u32(DAT_00024d62, DAT_00024d38)
			a7 = entry_a7 - 0x74
			invoke_tagged_attitude_compose_neg_sins4(DAT_0001d72c)
			a7 = entry_a7
			obj = memory.read_u32(DAT_00025b24)
			memory.write_u16(rel + 2, C68kScript.u16(_shift_signed(C68kScript.s32(memory.read_u32(DAT_0001d838) - memory.read_u32(obj + 0x18)), shift)))
			memory.write_u16(rel + 6, C68kScript.u16(_shift_signed(C68kScript.s32(memory.read_u32(DAT_0001d834) - memory.read_u32(obj + 0x1c)), shift)))
			memory.write_u16(rel + 0xa, C68kScript.u16(_shift_signed(C68kScript.s32(memory.read_u32(DAT_0001d830) - memory.read_u32(obj + 0x20)), shift)))
			if (memory.read_u8(memory.read_u32(DAT_00025b24) + 6) & 1) != 0 and lit != 0:
				var lx: int = memory.read_u16(DAT_0001bd8c)
				var ly: int = memory.read_u16(DAT_0001bd8a)
				var lz: int = memory.read_u16(DAT_0001bd88)
				memory.write_u16(rel + 0xc + 2, lx)
				memory.write_u16(rel + 0xc + 6, ly)
				memory.write_u16(rel + 0xc + 0xa, lz)
				a7 = entry_a7 - 0x74
				transform_vecs12_by_matrix3(2, rel, rel, DAT_0001d72c)
				a7 = entry_a7
				memory.write_u16(DAT_0001bd8c, memory.read_u16(rel + 0xc + 2))
				memory.write_u16(DAT_0001bd8a, memory.read_u16(rel + 0xc + 6))
				memory.write_u16(DAT_0001bd88, memory.read_u16(rel + 0xc + 0xa))
				_band_and_shade(entry_a7, true, haze)
				memory.write_u16(DAT_0001bd8c, lx)
				memory.write_u16(DAT_0001bd8a, ly)
				memory.write_u16(DAT_0001bd88, lz)
			else:
				a7 = entry_a7 - 0x74
				transform_vecs12_by_matrix3(1, rel, rel, DAT_0001d72c)
				a7 = entry_a7
				_band_and_shade(entry_a7, false, haze)
			memory.write_u16(DAT_00024d60, memory.read_u16(rel + 2))
			memory.write_u16(DAT_00024d5e, memory.read_u16(rel + 6))
			memory.write_u16(DAT_00024d5c, memory.read_u16(rel + 0xa))
			if (res & 2) != 0:
				a7 = entry_a7 - 0x6c
				_jsr(memory.read_u32(memory.read_u32(ctl + 4) + 0xe), [ctl, 2])
				a7 = entry_a7
	obj = memory.read_u32(DAT_00025b24)
	memory.write_u32(DAT_00025b20, memory.read_u32(obj + 0x4c))
	memory.write_u32(DAT_00025f30, memory.read_u32(obj + 0x48))
	memory.write_u16(DAT_00025b18, memory.read_u16(obj + 0x38))
	memory.write_u32(DAT_00024d4a, C68kScript.u32(C68kScript.s32(memory.read_s16(obj + 0x36) * 12) + memory.read_u32(obj + 0x44)))
	var verts: int = memory.read_u32(obj + 0x44)
	for k in 3:
		memory.write_u32(DAT_00024d4e + 4 * k, memory.read_u32(verts + 4 * k))
	var count: int = memory.read_s16(memory.read_u32(DAT_00025b24) + 0x36)
	var q: int = count
	if q < 0:
		q += 3
	q = C68kScript.s16(q >> 2)
	for k in q + 1:
		memory.write_u32(DAT_00024d66 + 4 * k, 0)
	var face: int = memory.read_u32(DAT_00025f30)
	var faces_left: int = memory.read_s16(memory.read_u32(DAT_00025b24) + 0x3a)
	while true:
		faces_left = C68kScript.s32(faces_left - 1)
		if faces_left == -1:
			break
		var flags: int = memory.read_u8(face + 0x13)
		if (flags & 0x60) == 0x20:
			memory.write_u8(face + 0x13, flags | 0x40)
			var idx: int = memory.read_u32(face + 0x18)
			for k in C68kScript.u32(memory.read_s16(face + 0x14)):
				memory.write_u8(C68kScript.u32(DAT_00024d66 + memory.read_s16(idx)), 1)
				idx += 2
		else:
			memory.write_u8(face + 0x13, flags & 0xdf)
		face += 0x20
	var m: int = memory.read_u32(DAT_00024d62)
	var eye_x: int = memory.read_u16(DAT_00024d60)
	var eye_y: int = memory.read_u16(DAT_00024d5e)
	var eye_z: int = memory.read_u16(DAT_00024d5c)
	var vshift: int = memory.read_s16(DAT_00024d5a)
	var view: int = memory.read_u32(DAT_00025b20)
	var out: int = DAT_000256b2
	var left: int = count & 0xffff
	var k2: int = 0
	while true:
		left = (left - 1) & 0xffff
		if left == 0xffff:
			break
		if memory.read_u8(DAT_00024d66 + k2) != 0:
			var v: int = C68kScript.u32(verts + 12 * k2)
			var d0: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v), vshift) - eye_x)
			var d1: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 4), vshift) - eye_y)
			var d2: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 8), vshift) - eye_z)
			var w: int = C68kScript.u32(view + 12 * k2)
			for c in 3:
				var acc: int = C68kScript.s32(d0 * memory.read_s16(m + 2 * c) + d1 * memory.read_s16(m + 6 + 2 * c) + d2 * memory.read_s16(m + 12 + 2 * c) + 0x800)
				memory.write_u16(w + 2 + 4 * c, C68kScript.u16(C68kScript.asr32(acc, 12)))
			var z: int = memory.read_s16(w + 0xa)
			if z > 4:
				memory.write_u32(out, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(w + 2) * memory.read_s16(DAT_00020b28)), z)))
				memory.write_u32(out + 4, C68kScript.u32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.s16(-memory.read_s16(w + 6)) * memory.read_s16(DAT_00020b26)), z)))
			else:
				memory.write_u32(out, 0x80000000)
		out += 8
		k2 += 1
	return 0

## Per-object face pass of render_visible_objects: force_near_clip = object word +6 & 8, clear
## face_was_clipped, reset both face queues, emit (emit_faces_bsp(0) when byte +7 bit 5, else
## emit_faces_in_order; or emit_faces_unnumbered when unnumbered) and submit_object_faces, at the
## given depth (plus 4 for the bsp argument).
func _render_object_faces(entry_a7: int, depth: int, unnumbered: bool) -> void:
	var obj: int = memory.read_u32(DAT_00025b24)
	memory.write_u16(DAT_00025b14, memory.read_u16(obj + 6) & 8)
	memory.write_u16(DAT_00025b12, 0)
	memory.write_u32(DAT_00025d2c, DAT_00025d30)
	memory.write_u32(DAT_00025b28, DAT_00025b2c)
	if unnumbered:
		a7 = entry_a7 - depth
		emit_faces_unnumbered()
	elif (memory.read_u8(obj + 7) & 0x20) != 0:
		a7 = entry_a7 - depth - 4
		emit_faces_bsp(0)
	else:
		a7 = entry_a7 - depth
		emit_faces_in_order()
	a7 = entry_a7 - depth
	submit_object_faces()
	a7 = entry_a7

## Near mode for the prepared object: allowed (view 1) and its distance (+0x10) within its range
## (+0x14) -> 1, and on first entry (byte +5 bit 5 clear) its faces lose +0x13 bit 3, the bit is set
## and near mode is 2; not near -> 0 and the bit is cleared.
func _render_near_mode(allowed: bool) -> void:
	var obj: int = memory.read_u32(DAT_00025b24)
	if allowed:
		var near: int = 1 if memory.read_s32(obj + 0x10) <= memory.read_s32(obj + 0x14) else 0
		memory.write_u16(DAT_00025b16, near)
		if near != 0:
			if (memory.read_u8(obj + 5) & 0x20) == 0:
				var faces: int = memory.read_u32(DAT_00025f30)
				for k in C68kScript.u32(memory.read_s16(obj + 0x3a)):
					memory.write_u8(faces + 32 * k + 0x13, memory.read_u8(faces + 32 * k + 0x13) & 0xf7)
				memory.write_u8(obj + 5, memory.read_u8(obj + 5) | 0x20)
				memory.write_u16(DAT_00025b16, 2)
			return
	else:
		memory.write_u16(DAT_00025b16, 0)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffdfffff)

## 0xac72 (link.w a6,#-0x370, five saved registers: body 0x388 below the entry): draw the visible
## objects. Near mode is allowed in view 1 unless view_flag_d856. The edge pool count, draw order
## (1) and near mode reset. Pass 1: the visible_list_split pre-transformed objects are projected
## (project_prepared_object) and their faces run. Then visible_first_pass = visible_count word -
## it. Pass 2: the others; one with byte +6 bit 1 asks for its parts sorted
## (sort_group_parts_by_distance; the faces then run unnumbered), one with a parent
## (+0x2c) is deferred into the frame list (a6 - 0x370), the rest transform_and_project_object
## (skipped on 4) with near mode decided only while the remaining count is below
## visible_first_pass. Pass 3: deferred objects draw with their parent's draw order (parent word
## +2, written back). The draw order is restored; in view 1 mission_child4 (+4 |= 4) is projected
## and drawn last.
func render_visible_objects() -> void:
	assert(memory != null, "render_visible_objects requires original global memory")
	assert(a7 != 0, "render_visible_objects needs a7 (its frame holds the deferred list)")
	var entry_a7: int = a7
	var deferred: int = entry_a7 - 4 - 0x370
	var deferred_end: int = deferred
	var body: int = 0x388
	var allowed: bool = memory.read_u16(DAT_0001d856) == 0 and memory.read_s16(DAT_0001d858) == 1
	memory.write_u32(DAT_00020ab0, 0)
	memory.write_u16(DAT_0001c1be, 1)
	memory.write_u16(DAT_00025b16, 0)
	var sort_parts: bool = false
	var slot: int = DAT_0001c9dc
	var left: int = C68kScript.u32(memory.read_u32(DAT_0001bdb8))
	while left != 0:
		left -= 1
		memory.write_u32(DAT_00025b24, memory.read_u32(slot))
		slot += 4
		a7 = entry_a7 - body - 4
		project_prepared_object()
		a7 = entry_a7
		_render_object_faces(entry_a7, body + 4, false)
	memory.write_u16(DAT_0001c1c0, C68kScript.u16(memory.read_u16(DAT_0001c1d4 + 2) - memory.read_u16(DAT_0001c1c0)))
	slot = C68kScript.u32(DAT_0001c9dc + 4 * memory.read_u32(DAT_0001bdb8))
	var d2: int = C68kScript.s32(memory.read_u32(DAT_0001c1d4) - memory.read_u32(DAT_0001bdb8))
	while true:
		# dbra on the low word, then the clr.w / subq.l / bcc borrow into the high word.
		if (d2 & 0xffff) == 0:
			d2 = C68kScript.s32(d2 - 1)
			if C68kScript.u32(d2) == 0xffffffff:
				break
		else:
			d2 = C68kScript.s32(d2 - 1)
		var obj: int = memory.read_u32(slot)
		slot += 4
		memory.write_u32(DAT_00025b24, obj)
		if (memory.read_u8(obj + 6) & 2) != 0:
			sort_parts = true
		elif memory.read_u32(obj + 0x2c) != 0:
			memory.write_u32(deferred_end, obj)
			deferred_end += 4
			continue
		a7 = entry_a7 - body - 4
		var r: int = transform_and_project_object()
		a7 = entry_a7
		if r == 4:
			continue
		if memory.read_s16(DAT_0001c1c0) > d2:
			_render_near_mode(allowed)
		else:
			memory.write_u16(DAT_00025b16, 0)
		if sort_parts:
			a7 = entry_a7 - body - 8
			sort_group_parts_by_distance(memory.read_u32(DAT_00025b24))
			a7 = entry_a7
			sort_parts = false
			_render_object_faces(entry_a7, body + 8, true)
		else:
			_render_object_faces(entry_a7, body + 4, false)
	var order: int = memory.read_u16(DAT_0001c1be)
	var p: int = deferred
	while p < deferred_end:
		var obj2: int = memory.read_u32(p)
		p += 4
		memory.write_u32(DAT_00025b24, obj2)
		var parent: int = memory.read_u32(obj2 + 0x2c)
		memory.write_u16(DAT_0001c1be, memory.read_u16(parent + 2))
		a7 = entry_a7 - body - 4
		var r2: int = transform_and_project_object()
		a7 = entry_a7
		if r2 != 4:
			_render_near_mode(allowed)
			_render_object_faces(entry_a7, body + 4, false)
		memory.write_u16(parent + 2, memory.read_u16(DAT_0001c1be))
	memory.write_u16(DAT_0001c1be, order)
	if memory.read_s16(DAT_0001d858) == 1:
		var last: int = memory.read_u32(DAT_0001bda4)
		memory.write_u32(last + 4, memory.read_u32(last + 4) | 4)
		memory.write_u32(DAT_00025b24, last)
		a7 = entry_a7 - body - 4
		project_prepared_object()
		a7 = entry_a7
		_render_object_faces(entry_a7, body + 4, false)

## Number a face record: face +2 = draw_order_next, which then increments.
func _number_face(face: int) -> void:
	memory.write_u16(face + 2, memory.read_u16(DAT_0001c1be))
	memory.write_u16(DAT_0001c1be, C68kScript.u16(memory.read_u16(DAT_0001c1be) + 1))

## Number a group record: +2 = draw_order_next, then draw_order_next += (sext word +0) << 7.
func _number_group(group: int) -> void:
	memory.write_u16(group + 2, memory.read_u16(DAT_0001c1be))
	memory.write_u16(DAT_0001c1be, C68kScript.u16(memory.read_u16(DAT_0001c1be) + C68kScript.lsl32(memory.read_s16(group), 7)))

## 0x1443a (link.w a6,#-0x424, ten saved registers: body 0x450 below the entry): draw order for a
## group object's parts. The camera is saved, scaled by word +0x34 (asl) with y = 0, and restored
## at the end. The parts are the last word +0x38 model vertices (their centres); their face indices
## follow the face table (+0x48 + 32 * word +0x3a). Each part's horizontal camera distance
## (compute_camera_abs_metric(x, 0, z), 0x460 below) goes into the frame array (a6 - 0x400); with
## host word +0xaa the part's colour record (6 bytes after the index list) gets its band
## (update_record_distance_band, 0x468 below) and, when it changed, the part face's colour bytes
## +0xc..+0xe = (base * (0x20 - band) + band * (0x7d / 0x84 / 0xa8)) lsr 5, its palette slot
## rewritten (write_face_palette_slot, 0x458 below) when still owned, else dropped. The parts are
## insertion-sorted far to near. With a group list (+0x2c: word count, then entry pointers;
## entries with word 0 freed and dropped while deferred_free_flag, 0x458 below) the entries are
## sorted far to near by their own metric (+0xc = metric(+4, 0, +8)) and merged with the parts:
## each is numbered before the first part nearer than it, reserving count << 7 numbers; parts get
## one number each. Without groups the parts are numbered in sorted order.
func sort_group_parts_by_distance(obj: int) -> void:
	assert(memory != null, "sort_group_parts_by_distance requires original global memory")
	assert(a7 != 0, "sort_group_parts_by_distance needs a7 (its frame holds the distances)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var dist: int = a6 - 0x400
	var cam_x: int = memory.read_u32(DAT_0001d838)
	var cam_y: int = memory.read_u32(DAT_0001d834)
	var cam_z: int = memory.read_u32(DAT_0001d830)
	var scale: int = memory.read_s16(obj + 0x34)
	memory.write_u32(DAT_0001d838, C68kScript.u32(C68kScript.lsl32(cam_x, scale & 0x3f)))
	memory.write_u32(DAT_0001d834, 0)
	memory.write_u32(DAT_0001d830, C68kScript.u32(C68kScript.lsl32(memory.read_u32(DAT_0001d830), scale & 0x3f)))
	var parts: int = memory.read_s16(obj + 0x38)
	var centres: int = C68kScript.u32(C68kScript.s32(C68kScript.s32(memory.read_s16(obj + 0x36) - parts) * 12) + memory.read_u32(obj + 0x44))
	var faces: int = memory.read_u32(obj + 0x48)
	var list: int = C68kScript.u32(faces + C68kScript.s32(memory.read_s16(obj + 0x3a) * 32))
	var colours: int = C68kScript.u32(list + 2 * parts)
	var lit: bool = memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xaa) != 0
	for k in range(maxi(parts, 0)):
		var part: int = memory.read_s16(list + 2 * k)
		var c: int = C68kScript.u32(centres + 12 * part)
		a7 = entry_a7 - 0x460
		var d: int = compute_camera_abs_metric(memory.read_s32(c), 0, memory.read_s32(c + 8))
		a7 = entry_a7
		memory.write_u32(dist + 4 * k, C68kScript.u32(d))
		if lit:
			var rec: int = C68kScript.u32(colours + 6 * part)
			a7 = entry_a7 - 0x468
			var changed: int = update_record_distance_band(rec, d)
			a7 = entry_a7
			if changed != 0:
				var face: int = C68kScript.u32(faces + 32 * part)
				var band: int = memory.read_s16(rec + 4)
				var keep: int = C68kScript.s32(0x20 - band)
				var tints: Array = [0x7d, 0x84, 0xa8]
				for ch in 3:
					var v: int = C68kScript.u32(C68kScript.s32(memory.read_u8(rec + ch) * keep) + C68kScript.s32(band * tints[ch]))
					memory.write_u8(face + 0xc + ch, (v >> 5) & 0xff)
				var slot: int = memory.read_u8(face + 0xf)
				if memory.read_u32(C68kScript.u32(memory.read_u32(DAT_0001da7c) + slot * 4)) == face:
					a7 = entry_a7 - 0x458
					write_face_palette_slot(face)
					a7 = entry_a7
				else:
					memory.write_u8(face + 0xf, 0)
	# Insertion sort of the part list, far to near.
	for k in range(maxi(parts, 0)):
		var idx: int = memory.read_u16(list + 2 * k)
		var dk: int = memory.read_s32(dist + 4 * k)
		var j: int = k - 1
		while j >= 0 and dk > memory.read_s32(dist + 4 * j):
			memory.write_u16(list + 2 * (j + 1), memory.read_u16(list + 2 * j))
			memory.write_u32(dist + 4 * (j + 1), memory.read_u32(dist + 4 * j))
			j -= 1
		memory.write_u16(list + 2 * (j + 1), idx)
		memory.write_u32(dist + 4 * (j + 1), C68kScript.u32(dk))
	var groups: int = memory.read_u32(obj + 0x2c)
	var count: int = 0
	var entries: int = C68kScript.u32(groups + 4)
	if groups != 0:
		count = memory.read_u16(groups)
		if memory.read_u16(DAT_0001c1bc) != 0:
			var kept: int = entries
			var left: int = count
			var src: int = entries
			while true:
				left = (left - 1) & 0xffff
				if left == 0xffff:
					break
				var e: int = memory.read_u32(src)
				src += 4
				if memory.read_u16(e) != 0:
					memory.write_u32(kept, e)
					kept += 4
				else:
					a7 = entry_a7 - 0x458
					heap_free_coalesce(e)
					a7 = entry_a7
			count = C68kScript.asr32(C68kScript.s32(kept - entries), 2) & 0xffff
			memory.write_u16(groups, count)
	if groups == 0 or C68kScript.s16(count) == 0:
		for k in range(maxi(parts, 0)):
			_number_face(C68kScript.u32(faces + 32 * memory.read_s16(list + 2 * k)))
	else:
		var n: int = C68kScript.s16(count)
		for k in range(maxi(n, 0)):
			var e2: int = memory.read_u32(entries + 4 * k)
			a7 = entry_a7 - 0x460
			var m: int = compute_camera_abs_metric(memory.read_s32(e2 + 4), 0, memory.read_s32(e2 + 8))
			a7 = entry_a7
			memory.write_u32(e2 + 0xc, C68kScript.u32(m))
			var j2: int = k - 1
			while j2 >= 0:
				var other: int = memory.read_u32(entries + 4 * j2)
				if m <= memory.read_s32(other + 0xc):
					break
				memory.write_u32(entries + 4 * (j2 + 1), other)
				j2 -= 1
			memory.write_u32(entries + 4 * (j2 + 1), e2)
		# Merge: groups farther than a part are numbered before it.
		var gi: int = 0
		var group: int = memory.read_u32(entries)
		gi = 1
		var gdist: int = memory.read_s32(group + 0xc)
		var groups_left: int = (n - 1) & 0xffff
		var k3: int = 0
		var finished: bool = false
		while k3 < (parts & 0xffff) and not finished:
			var face2: int = C68kScript.u32(faces + 32 * memory.read_s16(list + 2 * k3))
			var pd: int = memory.read_s32(dist + 4 * k3)
			k3 += 1
			while gdist > pd:
				_number_group(group)
				groups_left = (groups_left - 1) & 0xffff
				if groups_left == 0xffff:
					_number_face(face2)
					while k3 < (parts & 0xffff):
						_number_face(C68kScript.u32(faces + 32 * memory.read_s16(list + 2 * k3)))
						k3 += 1
					finished = true
					break
				group = memory.read_u32(entries + 4 * gi)
				gi += 1
				gdist = memory.read_s32(group + 0xc)
			if not finished:
				_number_face(face2)
		if not finished:
			while true:
				_number_group(group)
				groups_left = (groups_left - 1) & 0xffff
				if groups_left == 0xffff:
					break
				group = memory.read_u32(entries + 4 * gi)
				gi += 1
	memory.write_u32(DAT_0001d838, cam_x)
	memory.write_u32(DAT_0001d834, cam_y)
	memory.write_u32(DAT_0001d830, cam_z)

## Jump tables of fill_span_rows_8bit (run-length writers by run length): even-address table at
## 0x20cec, odd-address table at 0x22cec, 0x800 code addresses each (runtime addresses of labels
## inside fill_span_rows_8bit).
const SPAN8_TABLE_EVEN := 0x20cec
const SPAN8_TABLE_ODD := 0x22cec

## 0x3734: fill the two run-writer tables of fill_span_rows_8bit. Even table: lengths 0..5 ->
## 0x3816, 0x3822, 0x3830, 0x3820, 0x382e, 0x381e, longer -> 0x3838 (the long-word writer). Odd
## table: 0..6 -> 0x3816, 0x3822, 0x3862, 0x386c, 0x387c, 0x3888, 0x3878, longer -> 0x3896.
func init_code_pointer_tables() -> void:
	assert(memory != null, "init_code_pointer_tables requires original global memory")
	var even: Array = [0x3816, 0x3822, 0x3830, 0x3820, 0x382e, 0x381e]
	for k in 0x800:
		memory.write_u32(SPAN8_TABLE_EVEN + 4 * k, even[k] if k < even.size() else 0x3838)
	var odd: Array = [0x3816, 0x3822, 0x3862, 0x386c, 0x387c, 0x3888, 0x3878]
	for k in 0x800:
		memory.write_u32(SPAN8_TABLE_ODD + 4 * k, odd[k] if k < odd.size() else 0x3896)

## 0x37b4: redraw the background rows on an 8-bit screen by difference. For each of rows rows the
## new row record (*new_ptr) and the previous one (*old_ptr) are walked together (header long =
## span count - 1, then (x << 16 | colour) spans ending at x); each stretch where the new colour
## differs from the old is written at the screen cursor through the run-writer tables (the table
## by the cursor's byte parity, swapped after an odd-length run; 0x3838 writes words to a long
## boundary then longs), equal stretches are skipped. The cursor then skips skip bytes. The record
## words are read one long ahead, so at the end both pointers are stored back one long before
## their read position (the next row's header). The table entries are code addresses (run lengths
## index them as words).
func fill_span_rows_8bit(new_ptr: int, old_ptr: int, rows: int, screen: int, skip: int) -> void:
	assert(memory != null, "fill_span_rows_8bit requires original global memory")
	var a0: int = memory.read_u32(new_ptr)
	var a1: int = memory.read_u32(old_ptr)
	var cur: int = SPAN8_TABLE_EVEN
	var other: int = SPAN8_TABLE_ODD
	var a3: int = C68kScript.u32(screen)
	var left: int = C68kScript.u32(rows)
	var d0: int = memory.read_u32(a0)
	a0 += 4
	var d1: int = memory.read_u32(a1)
	a1 += 4
	while true:
		var d7: int = C68kScript.u32(d0 + d1)
		d7 = (d7 & 0xffff0000) | ((d7 - 1) & 0xffff)
		var d2: int = 0
		d0 = memory.read_u32(a0)
		a0 += 4
		d1 = memory.read_u32(a1)
		a1 += 4
		var row_done: bool = false
		while not row_done:
			var colour: int = d0 & 0xffff
			var d0x: int = (d0 & 0xffff0000) | (d1 & 0xffff)
			var run: int
			var write: bool
			if C68kScript.s32(d1) < C68kScript.s32(d0x):
				# The old span ends first.
				d0 = (d0 & 0xffff0000) | colour
				run = C68kScript.u16((d1 >> 16) - d2)
				d2 = C68kScript.u16(d2 + run)
				write = colour != (d1 & 0xffff)
				d1 = memory.read_u32(a1)
				a1 += 4
			elif C68kScript.s32(d1) == C68kScript.s32(d0x):
				run = C68kScript.u16((d0 >> 16) - d2)
				d2 = C68kScript.u16(d2 + run)
				d0 = memory.read_u32(a0)
				a0 += 4
				write = colour != (d1 & 0xffff)
				d1 = memory.read_u32(a1)
				a1 += 4
				d7 = (d7 & 0xffff0000) | ((d7 - 1) & 0xffff)
			else:
				# The new span ends first.
				run = C68kScript.u16((d0 >> 16) - d2)
				d2 = C68kScript.u16(d2 + run)
				d0 = memory.read_u32(a0)
				a0 += 4
				write = colour != (d1 & 0xffff)
			if write:
				var label: int = memory.read_u32(C68kScript.u32(cur + C68kScript.s16(run) * 4))
				var res: Array = _span8_write(label, run, colour, a3, cur, other)
				a3 = res[0]
				cur = res[1]
				other = res[2]
			else:
				a3 = C68kScript.u32(a3 + C68kScript.s16(run))
				if (run & 1) != 0:
					var t: int = cur
					cur = other
					other = t
			d7 = (d7 & 0xffff0000) | ((d7 - 1) & 0xffff)
			if (d7 & 0xffff) == 0xffff:
				row_done = true
		a3 = C68kScript.u32(a3 + skip)
		left = C68kScript.u32(left - 1)
		if left == 0:
			break
	memory.write_u32(new_ptr, C68kScript.u32(a0 - 4))
	memory.write_u32(old_ptr, C68kScript.u32(a1 - 4))

## One run writer of fill_span_rows_8bit, chosen by its code address: its byte (b, colour low
## byte) / word (w, colour word) / table swap (s) sequence at a3; 0x3838 / 0x3896 write words to a
## long boundary, then longs, then dispatch the remainder. Returns [a3, cur, other].
const SPAN8_WRITERS := {0x3816: "", 0x3822: "bs", 0x3830: "w", 0x3820: "wbs", 0x382e: "ww", 0x381e: "wwbs",
		0x3862: "bb", 0x386c: "bws", 0x387c: "bwb", 0x3888: "bwws", 0x3878: "bbbwb"}

func _span8_write(label: int, run: int, colour: int, a3: int, cur: int, other: int) -> Array:
	if SPAN8_WRITERS.has(label):
		for op in String(SPAN8_WRITERS[label]):
			match op:
				"b":
					memory.write_u8(a3, colour & 0xff)
					a3 = C68kScript.u32(a3 + 1)
				"w":
					memory.write_u16(a3, colour)
					a3 = C68kScript.u32(a3 + 2)
				"s":
					var t: int = cur
					cur = other
					other = t
		return [a3, cur, other]
	assert(label == 0x3838 or label == 0x3896, "fill_span_rows_8bit: unknown run writer 0x%x" % label)
	var d3: int = run
	if label == 0x3896:
		memory.write_u8(a3, colour & 0xff)
		a3 = C68kScript.u32(a3 + 1)
		var t0: int = cur
		cur = other
		other = t0
		d3 = C68kScript.u16(d3 - 1)
	if (a3 & 2) != 0:
		memory.write_u16(a3, colour)
		a3 = C68kScript.u32(a3 + 2)
		d3 = C68kScript.u16(d3 - 2)
	var longs: int = _dbra_word_count((d3 & 0xffff) >> 2)
	var pair: int = ((colour & 0xffff) << 16) | (colour & 0xffff)
	for k in longs:
		memory.write_u32(a3, pair)
		a3 = C68kScript.u32(a3 + 4)
	d3 = d3 & 3
	if d3 != 0:
		return _span8_write(memory.read_u32(C68kScript.u32(cur + d3 * 4)), d3, colour, a3, cur, other)
	return [a3, cur, other]

## The 9-entry run-writer table of a 4-bit span filler (in the code segment, runtime address):
## entry 0 the next-span label l0, 1 the high-nibble writer (l0 + 6), 2 one byte (+0x18), 3 a byte
## and a high nibble (+0x20), 4 two bytes (+0x24), 5..8 the two-byte loop (+0x50).
func _init_span4_table(table: int, l0: int) -> void:
	var offsets: Array = [0, 6, 0x18, 0x20, 0x24, 0x50, 0x50, 0x50, 0x50]
	for k in offsets.size():
		memory.write_u32(table + 4 * k, l0 + offsets[k])

## 0x3266 / 0x3412 / 0x35b4: fill the run-writer table of fill_span_rows_4bit_a / _b / _c.
func init_span_table_32ba() -> void:
	assert(memory != null, "init_span_table_32ba requires original global memory")
	_init_span4_table(0x3222, 0x3334)

func init_span_table_3466() -> void:
	assert(memory != null, "init_span_table_3466 requires original global memory")
	_init_span4_table(0x33ce, 0x34d6)

func init_span_table_3608() -> void:
	assert(memory != null, "init_span_table_3608 requires original global memory")
	_init_span4_table(0x3570, 0x3678)

## 0x32ba / 0x3466 / 0x3608: fill_span_rows_8bit for 4-bit pixels (two per byte, the odd pixel in the
## low nibble). The span walk is the same; the pixel parity rides in the low word of d5: a changed
## stretch starting on an odd pixel first merges the low nibble, whole bytes then go through the
## run-writer table (runs over 8 pixels as longs of the replicated colour byte, then the rest), a
## trailing odd pixel merges the high nibble; an unchanged stretch advances the cursor (rounding
## up from an odd start). Between rows d5 = -d5 with its low word cleared: in variant A, a row
## whose d5 is negative takes the colour word's high byte (alternate rows). A takes the record
## pointers by address (handles); B and C take the records directly but still store the end
## pointers through their first two arguments, as the original does.
func _fill_span_rows_4bit(new_arg: int, old_arg: int, rows: int, screen: int, skip: int, table: int, l0: int, handles: bool) -> void:
	var a0: int = memory.read_u32(new_arg) if handles else C68kScript.u32(new_arg)
	var a1: int = memory.read_u32(old_arg) if handles else C68kScript.u32(old_arg)
	var a3: int = C68kScript.u32(screen)
	var left: int = C68kScript.u32(rows)
	var d0: int = memory.read_u32(a0)
	a0 += 4
	var d1: int = memory.read_u32(a1)
	a1 += 4
	var d5: int = 0
	while true:
		var d7: int = C68kScript.u32(d0 + d1)
		d7 = (d7 & 0xffff0000) | ((d7 - 1) & 0xffff)
		var d2: int = 0
		d0 = memory.read_u32(a0)
		a0 += 4
		d1 = memory.read_u32(a1)
		a1 += 4
		while true:
			var colour: int = d0 & 0xffff
			var changed: bool = colour != (d1 & 0xffff)
			var d0x: int = (d0 & 0xffff0000) | (d1 & 0xffff)
			var d3: int
			if C68kScript.s32(d1) < C68kScript.s32(d0x):
				d0 = (d0 & 0xffff0000) | colour
				d3 = C68kScript.u32(d1 - d2)
				d2 = d1
				d1 = memory.read_u32(a1)
				a1 += 4
			elif d1 == d0x:
				d3 = C68kScript.u32(d0x - d2)
				d2 = d0x
				d0 = memory.read_u32(a0)
				a0 += 4
				d1 = memory.read_u32(a1)
				a1 += 4
				d7 = (d7 & 0xffff0000) | ((d7 - 1) & 0xffff)
			else:
				d3 = C68kScript.u32(d0x - d2)
				d2 = d0x
				d0 = memory.read_u32(a0)
				a0 += 4
			d2 = d2 & 0xffff0000
			var run: int = (d3 >> 16) & 0xffff
			if handles and C68kScript.s32(d5) < 0:
				colour = colour >> 8
			d5 = d5 & 0xffff0001
			if (d5 & 0xffff) != 0:
				if run != 0:
					d5 = (d5 & 0xffff0000) | ((d5 + run) & 0xffff)
					if not changed:
						a3 = C68kScript.u32(a3 + C68kScript.s16((((run + 1) & 0xffff) >> 1)))
					else:
						memory.write_u8(a3, (memory.read_u8(a3) & 0xf0) | (colour & 0x0f))
						a3 = C68kScript.u32(a3 + 1)
						run = C68kScript.u16(run - 1)
						if C68kScript.s16(run) > 0:
							a3 = _span4_write(run, colour, a3, table, l0)
			else:
				d5 = (d5 & 0xffff0000) | ((d5 + run) & 0xffff)
				if not changed:
					a3 = C68kScript.u32(a3 + C68kScript.s16(run >> 1))
				else:
					a3 = _span4_write(run, colour, a3, table, l0)
			d7 = (d7 & 0xffff0000) | ((d7 - 1) & 0xffff)
			if (d7 & 0xffff) == 0xffff:
				break
		a3 = C68kScript.u32(a3 + skip)
		left = C68kScript.u32(left - 1)
		if left == 0:
			break
		d5 = C68kScript.u32(-C68kScript.s32(d5)) & 0xffff0000
	memory.write_u32(new_arg, C68kScript.u32(a0 - 4))
	memory.write_u32(old_arg, C68kScript.u32(a1 - 4))

## Write run pixels from an even pixel: over 8, longs of the replicated colour byte (run >> 3 of
## them) and then the remaining run & 7; the table writers then (by label offset from l0): 6 high
## nibble, 0x18 one byte, 0x20 byte + high nibble, 0x24 two bytes, 0x50 pairs of bytes (run >> 2)
## then the remaining run & 3. Returns the cursor.
func _span4_write(run: int, colour: int, a3: int, table: int, l0: int) -> int:
	if C68kScript.s16(run) > 8:
		colour = colour & 0xff
		var quad: int = colour * 0x01010101
		for k in _dbra_word_count(run >> 3):
			memory.write_u32(a3, quad)
			a3 = C68kScript.u32(a3 + 4)
		run = run & 7
	while true:
		var role: int = memory.read_u32(C68kScript.u32(table + C68kScript.s16(run) * 4)) - l0
		match role:
			0:
				return a3
			6:
				memory.write_u8(a3, (memory.read_u8(a3) & 0x0f) | (colour & 0xf0))
				return a3
			0x18:
				memory.write_u8(a3, colour & 0xff)
				return C68kScript.u32(a3 + 1)
			0x20:
				memory.write_u8(a3, colour & 0xff)
				a3 = C68kScript.u32(a3 + 1)
				memory.write_u8(a3, (memory.read_u8(a3) & 0x0f) | (colour & 0xf0))
				return a3
			0x24:
				memory.write_u8(a3, colour & 0xff)
				memory.write_u8(C68kScript.u32(a3 + 1), colour & 0xff)
				return C68kScript.u32(a3 + 2)
			0x50:
				for k in _dbra_word_count(run >> 2):
					memory.write_u8(a3, colour & 0xff)
					memory.write_u8(C68kScript.u32(a3 + 1), colour & 0xff)
					a3 = C68kScript.u32(a3 + 2)
				run = run & 3
			_:
				assert(false, "4-bit span filler: unknown run writer 0x%x" % (role + l0))
				return a3
	return a3

## 0x32ba: variant A (record handles, alternate-row colour byte).
func fill_span_rows_4bit_a(new_ptr: int, old_ptr: int, rows: int, screen: int, skip: int) -> void:
	assert(memory != null, "fill_span_rows_4bit_a requires original global memory")
	_fill_span_rows_4bit(new_ptr, old_ptr, rows, screen, skip, 0x3222, 0x3334, true)

## 0x3466: variant B (records passed directly).
func fill_span_rows_4bit_b(new_rows: int, old_rows: int, rows: int, screen: int, skip: int) -> void:
	assert(memory != null, "fill_span_rows_4bit_b requires original global memory")
	_fill_span_rows_4bit(new_rows, old_rows, rows, screen, skip, 0x33ce, 0x34d6, false)

## 0x3608: variant C (as B, its own table).
func fill_span_rows_4bit_c(new_rows: int, old_rows: int, rows: int, screen: int, skip: int) -> void:
	assert(memory != null, "fill_span_rows_4bit_c requires original global memory")
	_fill_span_rows_4bit(new_rows, old_rows, rows, screen, skip, 0x3570, 0x3678, false)

## Word / swap helpers for the register-level port of scan_convert_edge_rows.
static func _lo(r: int) -> int:
	return r & 0xffff

static func _setlo(r: int, v: int) -> int:
	return (r & 0xffff0000) | (v & 0xffff)

static func _swap(r: int) -> int:
	return ((r << 16) & 0xffff0000) | ((r >> 16) & 0xffff)

## 0x2e14 (link.w a6,#-0x4b0, twelve saved registers): the colour-depth scan converter, ported
## block for block on the original registers (d0..d7, a0..a5; labels are the file addresses).
## It walks rows 0 .. scan_last_row (halved when 0x1b834) emitting span rows (a header long with
## the span count, then (x << 16 | colour) spans) from session_cur_a. Rows with bucket edges or a
## row flag merge the bucket (x-sorted) into the active edge list (two frame lists a6 - 0x23c /
## - 0x43c, swapped each time; edges ending on the row dropped) and run the slow path: each edge
## toggles its faces' inside words (+0x8000), new inside faces join the touched chain (+8, head
## a6 - 0x460, end 1), the front face is the inside face with the highest draw order (+2) and a
## change of its colour (+4) emits a span ending at the edge; the edge then steps by its slope,
## keeps the colour after it (+8) and is insertion-sorted back when it crossed its neighbour
## (or parked at 0x7fff0000 on its last row). The rows up to the next event row then take the
## fast path, stepping the edges without face tracking: under 4 rows one row at a time (a
## crossing ends the run), else as many rows as no two edges cross (divu.l of the gap by the
## slope difference) written column by column. The run counter lives in the high word of d2
## within a row and in the low word between rows; a crossing in the slow path makes the next rows
## slow too. Touched faces lose their inside words at every row end; at the end the chain is
## unlinked and edge_pool_count cleared. The sentinel edge (0x1b174: view_width << 16 | 0x8000)
## toggles the background face at 0x1b184 (order 0x7fff, colour 0x1b188 = fill | 0xffff0000).
func scan_convert_edge_rows() -> void:
	assert(memory != null, "scan_convert_edge_rows requires original global memory")
	assert(a7 != 0, "scan_convert_edge_rows needs a7 (its frame holds the edge lists)")
	var a6: int = a7 - 4
	var d0: int = 0
	var d1: int = 0
	var d2: int = 0
	var d3: int = 0
	var d4: int = 0
	var d5: int = 0
	var d6: int = 0
	var d7: int = 0
	var r0: int = 0
	var r1: int = 0
	var r2: int = 0
	var r3: int = 0
	var r4: int = 0
	var r5: int = 0
	memory.write_u32(a6 - 0x498, 0)
	memory.write_u32(a6 - 0x440, a6 - 0x23c)
	memory.write_u32(a6 - 0x444, a6 - 0x43c)
	memory.write_u32(a6 - 0x1c, DAT_0001eaac)
	memory.write_u32(0x1b174, C68kScript.u32(C68kScript.lsl32(memory.read_s16(DAT_0001b82a), 16)) | 0x8000)
	memory.write_u32(0x1b188, 0xffff0000 | C68kScript.u32(memory.read_s16(DAT_0001daa0)))
	memory.write_u32(memory.read_u32(a6 - 0x440), 0x1b174)
	memory.write_u32(memory.read_u32(a6 - 0x440) + 4, 0)
	memory.write_u32(a6 - 0x460, 1)
	var end_row: int = memory.read_s16(0x20ae6)
	if memory.read_u32(0x1b834) != 0:
		end_row = C68kScript.asr32(end_row, 1)
	memory.write_u32(a6 - 0x4a4, C68kScript.u32(end_row))
	memory.write_u32(a6 - 0x20, DAT_0001daa4)
	memory.write_u16(C68kScript.u32(DAT_0001daa4 + C68kScript.s32(C68kScript.lsl32(end_row, 1))), 1)
	memory.write_u32(a6 - 0x28, memory.read_u32(0x1b798))
	memory.write_u32(a6 - 0x2c, memory.read_u32(0x1b794))
	memory.write_u32(a6 - 0x34, memory.read_u32(a6 - 0x2c))
	d6 = memory.read_u32(a6 - 0x34)
	var label: int = 0x2ede
	while true:
		match label:
			0x2ede:
				memory.write_u32(a6 - 0x30, d6)
				d6 = C68kScript.u32(d6 + 4)
				r1 = memory.read_u32(a6 - 0x440)
				if _lo(d2) != 0:
					label = 0x2f72
					continue
				r5 = memory.read_u32(a6 - 0x1c)
				r2 = C68kScript.u32(r5 + 4)
				r0 = memory.read_u32(a6 - 0x20)
				memory.write_u16(r0, 0)
				r0 = C68kScript.u32(r0 + 2)
				d2 = r2
				while true:
					var bucket_head: int = memory.read_u32(r2)
					r2 = C68kScript.u32(r2 + 4)
					if bucket_head != 0:
						break
					var flag: int = memory.read_u16(r0)
					r0 = C68kScript.u32(r0 + 2)
					if flag != 0:
						r0 = C68kScript.u32(r0 - 2)
						break
				d2 = C68kScript.u32(r2 - d2) >> 2
				memory.write_u32(a6 - 0x20, r0)
				r2 = C68kScript.u32(r2 - 4)
				memory.write_u32(a6 - 0x1c, r2)
				r2 = memory.read_u32(a6 - 0x444)
				memory.write_u32(a6 - 0x440, r2)
				r3 = r2
				memory.write_u32(a6 - 0x444, r1)
				d0 = memory.read_u32(r5)
				if d0 == 0:
					label = 0x2f66
					continue
				r0 = C68kScript.u32(d0 + 0xc)
				d4 = memory.read_u32(r0)
				label = 0x2f56
			0x2f34:
				if memory.read_u16(r4 + 0xa) == _lo(d3):
					label = 0x2f56
					continue
				d1 = memory.read_u32(r4)
				if C68kScript.s32(d4) >= C68kScript.s32(d1):
					label = 0x2f54
					continue
				r1 = C68kScript.u32(r1 - 4)
				d1 = d4
				r4 = r0
				d0 = memory.read_u32(r4 + 0xc)
				if d0 == 0:
					label = 0x2f64
					continue
				r0 = C68kScript.u32(d0 + 0xc)
				d4 = memory.read_u32(r0)
				label = 0x2f54
			0x2f54:
				memory.write_u32(r2, r4)
				r2 = C68kScript.u32(r2 + 4)
				label = 0x2f56
			0x2f56:
				d0 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				r4 = d0
				label = 0x2f34 if d0 != 0 else 0x2f6c
			0x2f5e:
				if memory.read_u16(r4 + 0xa) == _lo(d3):
					label = 0x2f66
					continue
				label = 0x2f64
			0x2f64:
				memory.write_u32(r2, r4)
				r2 = C68kScript.u32(r2 + 4)
				label = 0x2f66
			0x2f66:
				d0 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				r4 = d0
				label = 0x2f5e if d0 != 0 else 0x2f6c
			0x2f6c:
				memory.write_u32(r5, 0)
				memory.write_u32(r2, 0)
				r1 = r3
				label = 0x2f72
			0x2f72:
				d5 = 0xffffffff
				d4 = 0xffffffff
				d2 = _swap(d2) & 0xffff0000
				label = 0x300c
			0x2f7e:
				d0 = 0
				r3 = C68kScript.u32(r4 - 0xc)
				r2 = memory.read_u32(r3)
				r3 = C68kScript.u32(r3 + 4)
				while true:
					var inside: int = memory.read_u16(r2) ^ 0x8000
					memory.write_u16(r2, inside)
					if inside == 0:
						if r5 == r2:
							d0 = 0xffffffff
					else:
						r0 = C68kScript.u32(r2 + 8)
						if memory.read_u32(r0) == 0:
							memory.write_u32(r0, memory.read_u32(a6 - 0x460))
							memory.write_u32(a6 - 0x460, r2)
						r0 = memory.read_u32(r2)
						if C68kScript.s16(_lo(d2)) < C68kScript.s16(_lo(r0)):
							r5 = r2
							d2 = _setlo(d2, _lo(r0))
							d0 = d0 | 1
					r2 = memory.read_u32(r3)
					r3 = C68kScript.u32(r3 + 4)
					if r2 == 0:
						break
				d1 = memory.read_u32(r4)
				r4 = C68kScript.u32(r4 + 4)
				var change: int = C68kScript.s8(d0 & 0xff)
				if change == 0:
					label = 0x2ffe
					continue
				if change < 0:
					d2 = _setlo(d2, 0)
					r3 = a6 - 0x460
					r2 = memory.read_u32(r3)
					while true:
						d0 = memory.read_u32(r2)
						if C68kScript.s32(d0) < 0:
							if C68kScript.s16(_lo(d0)) > C68kScript.s16(_lo(d2)):
								r5 = r2
								d2 = _setlo(d2, _lo(d0))
							r3 = C68kScript.u32(r2 + 8)
						else:
							r0 = C68kScript.u32(r2 + 8)
							memory.write_u32(r3, memory.read_u32(r0))
							memory.write_u32(r0, 0)
						r2 = memory.read_u32(r3)
						if r2 == 1:
							break
				d0 = memory.read_u32(r5 + 4)
				if d0 != d4:
					r0 = d6
					d6 = (d1 & 0xffff0000) | (d4 & 0xffff)
					memory.write_u32(r0, d6)
					r0 = C68kScript.u32(r0 + 4)
					d4 = d0
					d6 = r0
				label = 0x2ffe
			0x2ffe:
				d1 = C68kScript.u32(d1 + memory.read_u32(r4))
				r4 = C68kScript.u32(r4 - 4)
				memory.write_u32(r4, d1)
				memory.write_u16(r4 + 8, _lo(d4))
				if C68kScript.s32(d1) < C68kScript.s32(d5):
					label = 0x304c
					continue
				d5 = d1
				label = 0x300c
			0x300c:
				d0 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				r4 = d0
				if d0 != 0:
					label = 0x2f7e
					continue
				var header: int = memory.read_u32(a6 - 0x30)
				memory.write_u32(header, C68kScript.u32((C68kScript.u32(d6 - header) >> 2) - 1))
				r2 = memory.read_u32(a6 - 0x460)
				while r2 != 1:
					memory.write_u16(r2, 0)
					r2 = memory.read_u32(r2 + 8)
				d3 = C68kScript.u32(d3 + 1)
				d2 = _swap(d2)
				d2 = _setlo(d2, _lo(d2) - 1)
				if C68kScript.s16(_lo(d2)) > 0:
					label = 0x30c4
					continue
				if C68kScript.s16(_lo(d2)) < 0:
					d2 = _setlo(d2, -_lo(d2))
				label = 0x3042
			0x3042:
				label = 0x2ede if C68kScript.s32(d3) < memory.read_s32(a6 - 0x4a4) else 0x307e
			0x304c:
				d0 = _setlo(d0, memory.read_u16(r4 + 0xa) - _lo(d3) - 1)
				if _lo(d0) == 0:
					memory.write_u32(r4, 0x7fff0000)
					label = 0x300c
					continue
				r3 = C68kScript.u32(r1 - 8)
				while true:
					memory.write_u32(r3 + 4, memory.read_u32(r3))
					r3 = C68kScript.u32(r3 - 4)
					r0 = memory.read_u32(r3)
					if not (C68kScript.s32(d1) < memory.read_s32(r0)):
						break
				r3 = C68kScript.u32(r3 + 4)
				memory.write_u32(r3, r4)
				d2 = _swap(d2)
				if C68kScript.s16(_lo(d2)) > 0:
					d2 = _setlo(d2, -_lo(d2) + 2)
				d2 = _swap(d2)
				label = 0x300c
			0x307e:
				memory.write_u32(a6 - 0x46c, a6 - 0x460)
				memory.write_u32(a6 - 0x464, memory.read_u32(a6 - 0x460))
				while memory.read_u32(a6 - 0x464) != 1:
					var face: int = memory.read_u32(a6 - 0x464)
					memory.write_u16(face, 0)
					memory.write_u32(a6 - 0x468, memory.read_u32(face + 8))
					memory.write_u32(face + 8, 0)
					memory.write_u32(a6 - 0x464, memory.read_u32(a6 - 0x468))
				memory.write_u32(DAT_00020ab0, 0)
				return
			0x30c4:
				r5 = d6
				r2 = memory.read_u32(a6 - 0x440)
				while true:
					r4 = memory.read_u32(r2)
					r2 = C68kScript.u32(r2 + 4)
					d0 = memory.read_u32(r4) & 0xffff0000
					r4 = C68kScript.u32(r4 + 4)
					d0 = d0 | memory.read_u32(r4)
					r4 = C68kScript.u32(r4 + 4)
					if d0 != 0:
						break
				r2 = C68kScript.u32(r2 - 8)
				r4 = memory.read_u32(r2)
				r2 = C68kScript.u32(r2 + 4)
				d6 = _setlo(d6, memory.read_u16(r4 + 8))
				label = 0x3162 if C68kScript.s16(_lo(d2)) >= 4 else 0x30e4
			0x30e4:
				d0 = _setlo(d0, _lo(d2))
				d7 = _setlo(d7, _lo(d2) - 1)
				label = 0x30ea
			0x30ea:
				d4 = _setlo(d4, _lo(d6))
				memory.write_u32(a6 - 0x30, r5)
				r5 = C68kScript.u32(r5 + 4)
				d5 = 0xffffffff
				r1 = r2
				r4 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				label = 0x30f8
			0x30f8:
				r0 = r4
				r3 = memory.read_u32(r4)
				r4 = C68kScript.u32(r4 + 4)
				d1 = r3
				r3 = C68kScript.u32(r3 + memory.read_u32(r4))
				r4 = C68kScript.u32(r4 + 4)
				d1 = _setlo(d1, _lo(d4))
				memory.write_u32(r5, d1)
				r5 = C68kScript.u32(r5 + 4)
				d4 = _setlo(d4, memory.read_u16(r4))
				memory.write_u32(r0, r3)
				if C68kScript.s32(r3) < C68kScript.s32(d5):
					label = 0x3130
					continue
				d5 = r3
				label = 0x310e
			0x310e:
				d1 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				r4 = d1
				if d1 != 0:
					label = 0x30f8
					continue
				var hdr: int = memory.read_u32(a6 - 0x30)
				memory.write_u32(hdr, C68kScript.u32((C68kScript.u32(r5 - hdr) >> 2) - 1))
				d7 = _setlo(d7, _lo(d7) - 1)
				if _lo(d7) != 0xffff:
					label = 0x30ea
					continue
				d3 = _setlo(d3, _lo(d3) + _lo(d0))
				d2 = _setlo(d2, _lo(d2) - _lo(d0))
				d6 = r5
				label = 0x3042
			0x3130:
				d0 = _setlo(d0, _lo(d0) - _lo(d7))
				r4 = C68kScript.u32(r4 - 8)
				d1 = r3
				d7 = _setlo(d7, memory.read_u16(r4 + 0xa) - _lo(d3) - 1)
				if _lo(d7) == 0:
					memory.write_u32(r4, 0x7fff0000)
					label = 0x310e
					continue
				r3 = C68kScript.u32(r1 - 8)
				while true:
					memory.write_u32(r3 + 4, memory.read_u32(r3))
					r3 = C68kScript.u32(r3 - 4)
					if C68kScript.s32(r3) < C68kScript.s32(r2):
						break
					r0 = memory.read_u32(r3)
					if not (C68kScript.s32(d1) < memory.read_s32(r0)):
						break
				r3 = C68kScript.u32(r3 + 4)
				memory.write_u32(r3, r4)
				d7 = _setlo(d7, 0)
				label = 0x310e
			0x3162:
				d4 = _setlo(d4, _lo(d6))
				d5 = 0x80000000
				r0 = 0
				d7 = _setlo(d7, _lo(d2))
				r1 = r2
				r4 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				var to_short: bool = false
				while true:
					r4 = C68kScript.u32(r4 + 4)
					d1 = memory.read_u32(r4)
					r4 = C68kScript.u32(r4 + 4)
					d0 = _setlo(d0, memory.read_u16(r4))
					if _lo(d0) != _lo(d4):
						d4 = _setlo(d4, _lo(d0))
						r0 = C68kScript.u32(r0 + 1)
					if C68kScript.s32(d1) < C68kScript.s32(d5):
						d0 = C68kScript.u32(memory.read_u32(r4 - 8) - memory.read_u32(r3 - 8))
						d5 = C68kScript.u32(d5 - d1)
						d0 = d0 / d5
						if C68kScript.s16(_lo(d0)) < C68kScript.s16(_lo(d7)):
							d7 = _setlo(d7, _lo(d0))
							if C68kScript.s16(_lo(d7)) <= 1:
								to_short = true
								break
					d5 = d1
					r3 = r4
					d0 = memory.read_u32(r1)
					r1 = C68kScript.u32(r1 + 4)
					r4 = d0
					if d0 == 0:
						break
				if to_short:
					label = 0x30e4
					continue
				d2 = _setlo(d2, _lo(d2) - _lo(d7))
				d3 = _setlo(d3, _lo(d3) + _lo(d7))
				r3 = r5
				d5 = _setlo(r0, _lo(r0) << 2)
				d0 = _setlo(d0, _lo(d7) - 1)
				while true:
					memory.write_u32(r3, r0)
					r3 = C68kScript.u32(r3 + 4 + C68kScript.s16(_lo(d5)))
					d0 = _setlo(d0, _lo(d0) - 1)
					if _lo(d0) == 0xffff:
						break
				d4 = _setlo(d4, _lo(d6))
				r3 = C68kScript.u32(r5 + 4)
				r1 = r2
				r2 = C68kScript.u32(C68kScript.s16(_lo(d7)) - 1)
				r4 = memory.read_u32(r1)
				r1 = C68kScript.u32(r1 + 4)
				while true:
					d1 = memory.read_u32(r4)
					r4 = C68kScript.u32(r4 + 4)
					d6 = memory.read_u32(r4)
					r4 = C68kScript.u32(r4 + 4)
					r0 = C68kScript.u32(memory.read_s16(r4))
					if _lo(r0) == _lo(d4):
						d0 = C68kScript.u32(C68kScript.s32(r2 + 1) * C68kScript.s32(d6))
						d1 = C68kScript.u32(d1 + d0)
						memory.write_u32(r4 - 8, d1)
					else:
						r5 = r3
						r3 = C68kScript.u32(r3 + 4)
						d7 = r2
						while true:
							memory.write_u32(r5, (d1 & 0xffff0000) | _lo(d4))
							r5 = C68kScript.u32(r5 + 4)
							d1 = C68kScript.u32(d1 + d6)
							r5 = C68kScript.u32(r5 + C68kScript.s16(_lo(d5)))
							d7 = _setlo(d7, _lo(d7) - 1)
							if _lo(d7) == 0xffff:
								break
						d4 = _setlo(d4, _lo(r0))
						memory.write_u32(r4 - 8, d1)
					d0 = memory.read_u32(r1)
					r1 = C68kScript.u32(r1 + 4)
					r4 = d0
					if d0 == 0:
						break
				r5 = C68kScript.u32(r5 - C68kScript.s16(_lo(d5)))
				d6 = r5
				label = 0x3042
			_:
				assert(false, "scan_convert_edge_rows: unknown label 0x%x" % label)
				return

## 0x20: the word argument into both template record words 0x1a7d2 and 0x1a7d2 + 0x4a.
func overlay_patch_template_u16_pair(value: int) -> void:
	assert(memory != null, "overlay_patch_template_u16_pair requires original global memory")
	memory.write_u16(0x1a7d2, C68kScript.u16(value))
	memory.write_u16(0x1a7d2 + 0x4a, C68kScript.u16(value))

## 0x1294 (two saved registers): free the three palette owner tables (0x1da70..0x1da78,
## heap_free_coalesce 0x10 below) and clear them; allocate 0x400 cleared bytes (heap_alloc_cleared,
## 0x10 below) for the first, and for the other two with the multi-screen flag (host word +0xb4);
## the current owner table becomes the first.
func reset_palette_owner_tables() -> void:
	assert(memory != null, "reset_palette_owner_tables requires original global memory")
	var entry_a7: int = a7
	for k in range(1, 4):
		var slot: int = 0x1da6c + 4 * k
		if memory.read_u32(slot) != 0:
			a7 = entry_a7 - 0x10
			heap_free_coalesce(memory.read_u32(slot))
			a7 = entry_a7
			memory.write_u32(slot, 0)
	for k in range(1, 4):
		if k == 1 or memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xb4) != 0:
			a7 = entry_a7 - 0x10
			memory.write_u32(0x1da6c + 4 * k, C68kScript.u32(heap_alloc_cleared(0x400)))
			a7 = entry_a7
	memory.write_u32(DAT_0001da7c, memory.read_u32(DAT_0001da70))

## 0x1300: reset_palette_owner_tables (4 below), colour tally index 0x1da8a = 0, fill_colour = word
## +0x1a0 of the host colour record (long host +0x34).
func init_depth8_colour_state() -> void:
	assert(memory != null, "init_depth8_colour_state requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 4
	reset_palette_owner_tables()
	a7 = entry_a7
	memory.write_u16(0x1da8a, 0)
	memory.write_u16(DAT_0001daa0, memory.read_u16(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x34) + 0x1a0))

## 0x131c (link.w a6,#-4, ten saved registers): reset_palette_owner_tables (0x34 below), then for
## each of the three screens with an owner table and a source table (long host + 0x16 * n + 0x1e:
## eight words indexed by three threshold bits) 125 entries: for r, g, b in 0..4 (b innermost),
## (word[r > 3, g > 3, b > 3] << 12) | (word[r > 1 ..] << 8) | (word[r > 0 ..] << 4) | word[r > 2 ..]
## (sign-extended words, bit index 4r + 2g + b). Then the current owner table is the first, the
## tally index 0 and fill_colour = word +0x10 of the host colour record.
func init_depth4_colour_state() -> void:
	assert(memory != null, "init_depth4_colour_state requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x34
	reset_palette_owner_tables()
	a7 = entry_a7
	for n in range(1, 4):
		memory.write_u32(DAT_0001da7c, memory.read_u32(0x1da6c + 4 * n))
		var source: int = memory.read_u32(C68kScript.u32(memory.read_u32(DAT_0001b5a0) + 0x16 * n + 0x1e))
		if source == 0 or memory.read_u32(DAT_0001da7c) == 0:
			continue
		var table: int = memory.read_u32(DAT_0001da7c)
		var i: int = 0
		var pick := func(r: int, g: int, b: int, t: int) -> int:
			var idx: int = 4 * (1 if r > t else 0) + 2 * (1 if g > t else 0) + (1 if b > t else 0)
			return memory.read_s16(source + 2 * idx)
		for r in 5:
			for g in 5:
				for b in 5:
					var v: int = C68kScript.lsl32(pick.call(r, g, b, 3), 12) | C68kScript.lsl32(pick.call(r, g, b, 1), 8) \
							| C68kScript.lsl32(pick.call(r, g, b, 0), 4) | C68kScript.u32(pick.call(r, g, b, 2))
					memory.write_u32(table + 4 * i, C68kScript.u32(v))
					i += 1
	memory.write_u32(DAT_0001da7c, memory.read_u32(DAT_0001da70))
	memory.write_u16(0x1da8a, 0)
	memory.write_u16(DAT_0001daa0, memory.read_u16(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x34) + 0x10))

## Host Memory Manager hook at host offset (+0x2c6 new handle, +0x2ce reallocate, +0x2d2 lock,
## +0x2d6 unlock, +0x2da purgeable, +0x2de no-purge, +0x2e2 free memory) entered depth below.
func _host_memory_call(entry_a7: int, depth: int, offset: int, args: Array) -> int:
	a7 = entry_a7 - depth
	var r = _jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + offset), args)
	a7 = entry_a7
	return int(r)

## 0xdb0 (three saved registers): make the handle at handle_ptr usable at size bytes: a missing
## handle is created (host +0x2c6, 0x14 below), a purged one (master pointer 0) reallocated
## (+0x2ce, 0x18 below); either way it is made unpurgeable (+0x2de, 0x14 below). Returns 1 when
## it had to (re)allocate, else 0.
func ensure_handle_allocated(handle_ptr: int, size: int) -> int:
	assert(memory != null, "ensure_handle_allocated requires original global memory")
	var entry_a7: int = a7
	var made: int = 0
	if memory.read_u32(handle_ptr) == 0:
		memory.write_u32(handle_ptr, C68kScript.u32(_host_memory_call(entry_a7, 0x14, 0x2c6, [size])))
		made = 1
	var h: int = memory.read_u32(handle_ptr)
	if memory.read_u32(h) == 0:
		_host_memory_call(entry_a7, 0x18, 0x2ce, [h, size])
		made = 1
	_host_memory_call(entry_a7, 0x14, 0x2de, [memory.read_u32(handle_ptr)])
	return made

## 0xe0a: lock the handle (host +0x2d2, 0xc below) and make it unpurgeable (+0x2de, 0x10 below).
func lock_handle_nopurge(handle: int) -> void:
	assert(memory != null, "lock_handle_nopurge requires original global memory")
	var entry_a7: int = a7
	_host_memory_call(entry_a7, 0xc, 0x2d2, [handle])
	_host_memory_call(entry_a7, 0x10, 0x2de, [handle])

## 0xe32: unlock the handle (host +0x2d6, 0xc below) and make it purgeable (+0x2da, 0x10 below).
func unlock_handle_purgeable(handle: int) -> void:
	assert(memory != null, "unlock_handle_purgeable requires original global memory")
	var entry_a7: int = a7
	_host_memory_call(entry_a7, 0xc, 0x2d6, [handle])
	_host_memory_call(entry_a7, 0x10, 0x2da, [handle])

## 0xe5a: lock the host handles at +0x192, +0x1ac, +0x1b4 and +0xd8 (host +0x2d2; 8, 0xc, 0x10,
## 0x14 below as the arguments pile up).
func lock_overlay_buffers() -> void:
	assert(memory != null, "lock_overlay_buffers requires original global memory")
	var entry_a7: int = a7
	var depth: int = 8
	for off in [0x192, 0x1ac, 0x1b4, 0xd8]:
		_host_memory_call(entry_a7, depth, 0x2d2, [memory.read_u32(memory.read_u32(DAT_0001b5a0) + off)])
		depth += 4

## 0xea0 (two saved registers): session buffers sized by the free memory (host +0x2e2, 0xc below):
## over 0x7d000 bytes 800 entries and 30 rows, else 550 and 20. With host byte +0 the entry handle
## (0x1b744, entries * 0x1c bytes). Unless host word +0xe == 1, the two handle groups 0x1b74c /
## 0x1b75c, slot 1 and (with the multi-screen flag) slots 2..3, at rows * host word +0xc * 4 bytes;
## any (re)allocation there sets session_buffers_rebuilt (ensure_handle_allocated, 0x14 below).
func allocate_session_buffers() -> void:
	assert(memory != null, "allocate_session_buffers requires original global memory")
	var entry_a7: int = a7
	memory.write_u32(0x20c4c, 0)
	var free_mem: int = _host_memory_call(entry_a7, 0xc, 0x2e2, [])
	var entries: int = 0x226
	var rows: int = 0x14
	if C68kScript.s32(free_mem) > 0x7d000:
		entries = 0x320
		rows = 0x1e
	if memory.read_u8(memory.read_u32(DAT_0001b5a0)) != 0:
		a7 = entry_a7 - 0x14
		ensure_handle_allocated(0x1b744, entries * 0x1c)
		a7 = entry_a7
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe) == 1:
		return
	for k in range(1, 4):
		for group in [0x1b74c, 0x1b75c]:
			if k == 1 or memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xb4) != 0:
				var size: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(rows * memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xc)), 2))
				a7 = entry_a7 - 0x14
				var made: int = ensure_handle_allocated(group + 4 * k, size)
				a7 = entry_a7
				if made != 0:
					memory.write_u32(0x20c4c, 1)

## A locked handle's master pointer, masked to 24 bits with host word +0x76.
func _locked_pointer(handle: int) -> int:
	var p: int = memory.read_u32(handle)
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0x76) != 0:
		p = p & 0xffffff
	return p

## 0xf92 (six saved registers): lock the session buffers (lock_handle_nopurge, 0x20 below) and keep
## their data pointers: the entry handle into the edge pool base (0x1b76c) with host byte +0;
## unless host word +0xe == 1, the handle groups' slots (1, and 2..3 with the multi-screen flag)
## into 0x1b774 / 0x1b784; session_cur_a / _b = the slot-1 pointers of group b / a. Then
## update_view_clip_bounds (0x1c below), also at depth 1.
func lock_session_buffers() -> void:
	assert(memory != null, "lock_session_buffers requires original global memory")
	var entry_a7: int = a7
	if memory.read_u8(memory.read_u32(DAT_0001b5a0)) != 0:
		a7 = entry_a7 - 0x20
		lock_handle_nopurge(memory.read_u32(0x1b744))
		a7 = entry_a7
		memory.write_u32(DAT_0001b76c, _locked_pointer(memory.read_u32(0x1b744)))
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe) != 1:
		for k in range(1, 4):
			for pair in [[0x1b74c, 0x1b774], [0x1b75c, 0x1b784]]:
				if k == 1 or memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xb4) != 0:
					var h: int = memory.read_u32(pair[0] + 4 * k)
					a7 = entry_a7 - 0x20
					lock_handle_nopurge(h)
					a7 = entry_a7
					memory.write_u32(pair[1] + 4 * k, _locked_pointer(memory.read_u32(pair[0] + 4 * k)))
		memory.write_u32(0x1b794, memory.read_u32(0x1b788))
		memory.write_u32(0x1b798, memory.read_u32(DAT_0001b778))
	a7 = entry_a7 - 0x1c
	update_view_clip_bounds()
	a7 = entry_a7

## 0x1094 (four saved registers): unlock the session buffers (unlock_handle_purgeable, 0x18 below)
## and clear their data pointers (the edge pool base, both groups' slots that have a handle, and
## session_cur_a / _b); the handles stay.
func unlock_session_buffers() -> void:
	assert(memory != null, "unlock_session_buffers requires original global memory")
	var entry_a7: int = a7
	if memory.read_u32(0x1b744) != 0:
		a7 = entry_a7 - 0x18
		unlock_handle_purgeable(memory.read_u32(0x1b744))
		a7 = entry_a7
		memory.write_u32(DAT_0001b76c, 0)
	for k in range(1, 4):
		for pair in [[0x1b74c, 0x1b774], [0x1b75c, 0x1b784]]:
			if memory.read_u32(pair[0] + 4 * k) != 0:
				a7 = entry_a7 - 0x18
				unlock_handle_purgeable(memory.read_u32(pair[0] + 4 * k))
				a7 = entry_a7
				memory.write_u32(pair[1] + 4 * k, 0)
	memory.write_u32(0x1b794, 0)
	memory.write_u32(0x1b798, 0)

## 0x3fa (a2 saved): the player's fuel and bombs for a new flight. Both tanks (+0x67d / +0x67e) =
## ((capacity word def +0x1c muls.w host fuel percent +0xb6) divs 100) / 2 toward zero, at least
## 1 in the first; reserve word +0x680 = 0; bombs (+0x67c) = host byte +0xb9; word +0x634 =
## (bombs << 4) + def word +0x1a; ammo word +0x682 = 0x2a3; byte +0x674 = 0; word +0x684 &= 0xfc01;
## word 0x1b73c = 1.
func load_player_fuel_and_bombs() -> void:
	assert(memory != null, "load_player_fuel_and_bombs requires original global memory")
	var player: int = memory.read_u32(DAT_0001b738)
	var world: int = memory.read_u32(DAT_0001b5a0)
	var fuel: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(memory.read_u32(player + 4) + 0x1c) * memory.read_s16(world + 0xb6)), 100)
	if fuel < 0:
		fuel += 1
	fuel = C68kScript.asr32(fuel, 1)
	memory.write_u8(player + 0x67d, fuel & 0xff)
	player = memory.read_u32(DAT_0001b738)
	memory.write_u8(player + 0x67e, memory.read_u8(player + 0x67d))
	memory.write_u16(player + 0x680, 0)
	if memory.read_u8(player + 0x67d) == 0 and memory.read_u8(player + 0x67e) == 0:
		memory.write_u8(player + 0x67d, 1)
	player = memory.read_u32(DAT_0001b738)
	memory.write_u8(player + 0x67c, memory.read_u8(memory.read_u32(DAT_0001b5a0) + 0xb9))
	var bombs: int = memory.read_s8(player + 0x67c)
	memory.write_u16(player + 0x634, C68kScript.u16(C68kScript.lsl32(bombs, 4) + memory.read_u16(memory.read_u32(player + 4) + 0x1a)))
	memory.write_u16(player + 0x682, 0x2a3)
	memory.write_u8(player + 0x674, 0)
	memory.write_u16(player + 0x684, memory.read_u16(player + 0x684) & 0xfc01)
	memory.write_u16(0x1b73c, 1)

## 0xc4c (link.w a6,#-0x6a8, five saved registers: body 0x6c0 below the entry): the
## for_each_mission_scene_object visitor of find_anchor_point. ctx: +0 the anchor record, +4 /
## +8 / +0xc the reference point, word +0x1e the mode, +0x20 the best value. Mode 1 (runway):
## faces with type nibble 0x70 are transformed (transform_through_node_chain into the frame
## vertex buffer a6 - 0x690, 0x6e0 below) unless their first vertex lies above (y > 0); the
## nearest by approx_dist3_xyz (0x6dc below) becomes the anchor (x, 0x43, z). Mode 0: the
## shallowest node of kind 1 (byte +1) becomes the anchor: its position (transformed, no vertex
## buffer) and the attitude words +2 / +4 / +6 of its parent record (path[-1]). The anchor's
## word +0x18 = 1 when set.
func anchor_point_visitor(ctx: int, node: int, face: int, path: int, depth: int) -> void:
	assert(memory != null, "anchor_point_visitor requires original global memory")
	assert(a7 != 0, "anchor_point_visitor needs a7 (its frame holds the vertex buffer)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var px: int = a6 - 0x6a0
	var py: int = a6 - 0x6a4
	var pz: int = a6 - 0x6a8
	var verts: int = a6 - 0x690
	var level: int = C68kScript.s16(depth)
	if memory.read_u16(ctx + 0x1e) != 0:
		if (memory.read_u8(face + 9) & 0xf0) != 0x70:
			return
		a7 = entry_a7 - 0x6e0
		transform_through_node_chain(path, level, node, px, py, pz, verts)
		a7 = entry_a7
		if memory.read_s32(C68kScript.u32(verts + 12 * memory.read_s16(face + 0xe) + 4)) > 0:
			return
		a7 = entry_a7 - 0x6dc
		var d: int = approx_dist3_xyz(memory.read_s32(ctx + 4), memory.read_s32(ctx + 8), memory.read_s32(ctx + 0xc),
				memory.read_s32(px), memory.read_s32(py), memory.read_s32(pz))
		a7 = entry_a7
		if not (d < memory.read_s32(ctx + 0x20)):
			return
		memory.write_u32(ctx + 0x20, C68kScript.u32(d))
		var anchor: int = memory.read_u32(ctx)
		memory.write_u32(anchor, memory.read_u32(px))
		memory.write_u32(anchor + 4, 0x43)
		memory.write_u32(anchor + 8, memory.read_u32(pz))
	else:
		if memory.read_u8(node + 1) != 1 or not (level < memory.read_s32(ctx + 0x20)):
			return
		memory.write_u32(ctx + 0x20, C68kScript.u32(level))
		a7 = entry_a7 - 0x6e0
		transform_through_node_chain(path, level, node, px, py, pz, 0)
		a7 = entry_a7
		var anchor2: int = memory.read_u32(ctx)
		memory.write_u32(anchor2, memory.read_u32(px))
		memory.write_u32(anchor2 + 4, memory.read_u32(py))
		memory.write_u32(anchor2 + 8, memory.read_u32(pz))
		var parent: int = memory.read_u32(C68kScript.u32(path - 4))
		memory.write_u32(anchor2 + 0xc, C68kScript.u32(memory.read_s16(parent + 2)))
		memory.write_u32(anchor2 + 0x10, C68kScript.u32(memory.read_s16(parent + 4)))
		memory.write_u32(anchor2 + 0x14, C68kScript.u32(memory.read_s16(parent + 6)))
	memory.write_u16(memory.read_u32(ctx) + 0x18, 1)

## 0xd6a (link.w a6,#-0x24): the visitor context in the frame (a6 - 0x24: the anchor record, its
## first 26 bytes copied, the mode word, best 1000000000), then for_each_mission_scene_object with
## anchor_point_visitor (runtime 0xc2c, 0x38 below).
func find_anchor_point(anchor: int, mode: int) -> void:
	assert(memory != null, "find_anchor_point requires original global memory")
	assert(a7 != 0, "find_anchor_point needs a7 (its frame holds the visitor context)")
	var entry_a7: int = a7
	var ctx: int = entry_a7 - 4 - 0x24
	memory.write_u16(ctx + 0x1e, C68kScript.u16(mode))
	memory.write_u32(ctx + 0x20, 1000000000)
	memory.write_u32(ctx, C68kScript.u32(anchor))
	for k in 6:
		memory.write_u32(ctx + 4 + 4 * k, memory.read_u32(C68kScript.u32(anchor + 4 * k)))
	memory.write_u16(ctx + 4 + 24, memory.read_u16(C68kScript.u32(anchor + 24)))
	a7 = entry_a7 - 0x38
	for_each_mission_scene_object(0xc2c, ctx)
	a7 = entry_a7

## Rows of the presenters' 0x2000-byte bounce buffer: 0x2000 divs.w (view_width divs.w (8 divs.w
## depth)), kept even at depth 4.
func _bounce_rows() -> int:
	var per_byte: int = C68kScript.s16(C68kScript.divs_trunc(8, memory.read_s16(DAT_0001b826)))
	var row_bytes: int = C68kScript.s16(C68kScript.divs_trunc(memory.read_s16(DAT_0001b82a), per_byte))
	var rows: int = C68kScript.s16(C68kScript.divs_trunc(0x2000, row_bytes))
	if memory.read_s16(DAT_0001b826) == 4:
		rows -= rows & 1
	return rows

## 0xd298 (link.w a6,#-4, six saved registers): draw rows background rows on screen slot through a
## 0x2000-byte bounce buffer: reset_span_row_lists(slot) (0x28 below), heap_alloc (0x2c below),
## then per chunk of up to _bounce_rows rows span_filler(&new, &old, chunk, buffer, 0) (0x38 below;
## new / old are this routine's own argument slots, advanced by the filler) and the host copy
## (+0x296)(buffer, rows done, chunk, slot) (0x48 below); the buffer is freed (0x28 below).
func present_spans_to_window(new_rows: int, old_rows: int, rows: int, arg4: int, arg5: int, slot: int) -> void:
	assert(memory != null, "present_spans_to_window requires original global memory")
	assert(a7 != 0, "present_spans_to_window needs a7 (the filler updates its argument slots)")
	var entry_a7: int = a7
	memory.write_u32(entry_a7 + 4, C68kScript.u32(new_rows))
	memory.write_u32(entry_a7 + 8, C68kScript.u32(old_rows))
	a7 = entry_a7 - 0x28
	reset_span_row_lists(slot)
	a7 = entry_a7 - 0x2c
	var buffer: int = C68kScript.u32(heap_alloc(0x2000))
	a7 = entry_a7
	var chunk_rows: int = _bounce_rows()
	var total: int = C68kScript.s32(rows)
	var left: int = total
	while true:
		var chunk: int = chunk_rows if left > chunk_rows else left
		a7 = entry_a7 - 0x38
		_jsr(memory.read_u32(DAT_00020ac0), [entry_a7 + 4, entry_a7 + 8, chunk, buffer, 0])
		a7 = entry_a7 - 0x48
		_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x296), [buffer, C68kScript.s32(total - left), chunk, slot])
		a7 = entry_a7
		left = C68kScript.s32(left - chunk)
		if left == 0:
			break
	a7 = entry_a7 - 0x28
	heap_free_coalesce(buffer)
	a7 = entry_a7

## 0xd34c (link.w a6,#0, two saved registers): a 0x2000-byte buffer (heap_alloc, 0x14 below) for
## the host 1-bit frame routine (+0x80)(buffer, _bounce_rows, arg) (0x1c below), then freed (0x20
## below).
func present_bw_frame(arg: int) -> void:
	assert(memory != null, "present_bw_frame requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x14
	var buffer: int = C68kScript.u32(heap_alloc(0x2000))
	a7 = entry_a7
	var rows: int = _bounce_rows()
	a7 = entry_a7 - 0x1c
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x80), [buffer, rows, arg])
	a7 = entry_a7 - 0x20
	heap_free_coalesce(buffer)
	a7 = entry_a7

## 0x4210 (three saved registers): recolour everything for the current view depth. Depth 4 rebuilds
## the 4-bit colour state first (init_depth4_colour_state, 0x10 below). The 256 palette usage bytes
## (0x1d96c) are cleared, and at depth 8 the current owner table too. At depth 1 the first faces of
## mission_child0 / mission_child2or3 take host pattern words +0x180 / +0x80 (sign-extended);
## otherwise both are recoloured (recolour_kind2_object, 0x14 / 0x18 below), as are mission_child1
## and mission_child4. Then entity_array_1 and the object pool: at depth 1 land objects (byte +6
## bit 4) and pool objects whose controller type word is 3..4 get set_object_faces_bw_pattern
## (0x80 / 0, 0x18 below), all others recolour_kind2_object (0x14 below).
func refresh_object_colours_for_depth() -> void:
	assert(memory != null, "refresh_object_colours_for_depth requires original global memory")
	var entry_a7: int = a7
	if memory.read_s16(DAT_0001b826) == 4:
		a7 = entry_a7 - 0x10
		init_depth4_colour_state()
		a7 = entry_a7
	var owners: int = memory.read_u32(DAT_0001da7c)
	for k in 256:
		memory.write_u8(0x1d96c + k, 0)
		if memory.read_s16(DAT_0001b826) == 8:
			memory.write_u32(owners + 4 * k, 0)
	if memory.read_s16(DAT_0001b826) == 1:
		var patterns: int = memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x88)
		memory.write_u32(memory.read_u32(memory.read_u32(0x1bdb4) + 0x48) + 4, C68kScript.u32(memory.read_s16(patterns + 0x180)))
		memory.write_u32(memory.read_u32(memory.read_u32(DAT_0001bdac) + 0x48) + 4, C68kScript.u32(memory.read_s16(patterns + 0x80)))
	else:
		a7 = entry_a7 - 0x14
		recolour_kind2_object(memory.read_u32(0x1bdb4))
		a7 = entry_a7 - 0x18
		recolour_kind2_object(memory.read_u32(DAT_0001bdac))
	a7 = entry_a7 - 0x14
	recolour_kind2_object(memory.read_u32(DAT_0001bdb0))
	a7 = entry_a7 - 0x18
	recolour_kind2_object(memory.read_u32(DAT_0001bda4))
	a7 = entry_a7
	var k1: int = 0
	while k1 < memory.read_s32(DAT_0001c1e0):
		var obj: int = memory.read_u32(DAT_0001d4a4 + 4 * k1)
		if memory.read_s16(DAT_0001b826) == 1 and (memory.read_u8(obj + 6) & 0x10) != 0:
			a7 = entry_a7 - 0x18
			set_object_faces_bw_pattern(obj, 0x80)
		else:
			a7 = entry_a7 - 0x14
			recolour_kind2_object(obj)
		a7 = entry_a7
		k1 += 1
	var k2: int = 0
	while k2 < memory.read_s32(DAT_0001b734):
		var obj2: int = memory.read_u32(DAT_0001b5a4 + 4 * k2)
		var bw: bool = false
		if memory.read_s16(DAT_0001b826) == 1:
			var ctl: int = memory.read_u32(obj2 + 8)
			if ctl != 0:
				var kind: int = memory.read_s16(memory.read_u32(ctl + 4))
				bw = kind > 2 and kind <= 4
		if bw:
			a7 = entry_a7 - 0x18
			set_object_faces_bw_pattern(obj2, 0)
		else:
			a7 = entry_a7 - 0x14
			recolour_kind2_object(obj2)
		a7 = entry_a7
		k2 += 1

## 0x7310: start a flight at a pilot rank: the AI aim lags (0x1b878 / 0x1b876) = rank_aim_lag_table
## [rank]; without host word +0xa4 the player's handler (+0x32) is 0xe772; at depth 1 the objects
## are refreshed (refresh_object_colours_for_depth, 4 below) and 0x1da88 = the first host pattern
## word; flight words 0x24d2c / 0x24d2e and the rudder key are cleared; with host_words_valid the
## host words +0x33e / +0x340 are copied.
func begin_flight_for_rank(rank: int) -> void:
	assert(memory != null, "begin_flight_for_rank requires original global memory")
	var lag: int = memory.read_u16(C68kScript.u32(0x1b2b4 + C68kScript.s32(rank) * 2))
	memory.write_u16(0x1b878, lag)
	memory.write_u16(0x1b876, lag)
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xa4) == 0:
		memory.write_u32(memory.read_u32(DAT_0001b738) + 0x32, 0xe772)
	if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe) == 1:
		var entry_a7: int = a7
		a7 = entry_a7 - 4
		refresh_object_colours_for_depth()
		a7 = entry_a7
		memory.write_u16(0x1da88, memory.read_u16(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x88)))
	memory.write_u16(0x24d2c, 0)
	memory.write_u16(0x24d2e, 0)
	memory.write_u16(0x1b858, 0)
	if memory.read_u16(0x24d34) != 0:
		var world: int = memory.read_u32(DAT_0001b5a0)
		memory.write_u16(0x24d32, memory.read_u16(world + 0x33e))
		memory.write_u16(0x24d30, memory.read_u16(world + 0x340))

## 0x923e (a2 saved): unless the player's byte +0x685 bit 0, steer it: in auto mode (word 0x1b872)
## with a designated aircraft toward that aircraft's position (steer_entity_toward_point, 0x18
## below); otherwise from the mouse (host words +0x33e / +0x340, also copied to 0x24d32 / 0x24d30):
## aileron = 3 * (half width - x) / 2 toward zero, elevator = 3 * (y - half rows), with the rudder
## key word (enqueue_control_inputs_avg4, 0x18 below).
func apply_player_mouse_controls() -> void:
	assert(memory != null, "apply_player_mouse_controls requires original global memory")
	var player: int = memory.read_u32(DAT_0001b738)
	if (memory.read_u8(player + 0x685) & 1) != 0:
		return
	var entry_a7: int = a7
	if memory.read_u16(0x1b872) != 0 and memory.read_u32(DAT_0001b888) != 0:
		var target: int = memory.read_u32(memory.read_u32(DAT_0001b888))
		a7 = entry_a7 - 0x18
		steer_entity_toward_point(player, memory.read_s32(target + 0x18), memory.read_s32(target + 0x1c), memory.read_s32(target + 0x20))
		a7 = entry_a7
		return
	var world: int = memory.read_u32(DAT_0001b5a0)
	memory.write_u16(0x24d32, memory.read_u16(world + 0x33e))
	memory.write_u16(0x24d30, memory.read_u16(world + 0x340))
	var aileron: int = C68kScript.s32(3 * C68kScript.s32(memory.read_s16(DAT_00020b2a) - memory.read_s16(world + 0x33e)))
	if aileron < 0:
		aileron += 1
	aileron = C68kScript.asr32(aileron, 1)
	var elevator: int = C68kScript.s32(3 * C68kScript.s32(memory.read_s16(world + 0x340) - memory.read_s16(DAT_00020b2c)))
	a7 = entry_a7 - 0x18
	enqueue_control_inputs_avg4(memory.read_u32(DAT_0001b738), memory.read_s16(0x1b858), C68kScript.s16(elevator), C68kScript.s16(aileron))
	a7 = entry_a7

## 0x11e6: copy the format into the static buffer 0x20b4c, widening "%d" to "%ld" and "%x" to
## "%lx"; returns the buffer.
func widen_printf_format(fmt: int) -> int:
	assert(memory != null, "widen_printf_format requires original global memory")
	var src: int = C68kScript.u32(fmt)
	var dst: int = 0x20b4c
	while memory.read_u8(src) != 0:
		var c: int = memory.read_u8(src)
		var n: int = memory.read_u8(C68kScript.u32(src + 1))
		if c == 0x25 and (n == 0x64 or n == 0x78):
			memory.write_u8(dst, 0x25)
			memory.write_u8(dst + 1, 0x6c)
			memory.write_u8(dst + 2, n)
			dst += 3
			src = C68kScript.u32(src + 2)
		else:
			memory.write_u8(dst, c)
			dst += 1
			src = C68kScript.u32(src + 1)
	memory.write_u8(dst, 0)
	return 0x20b4c

## 0x1254 (link.w a6,#0, a2 saved): the host printf (+0x262) with the widened format and the five
## following arguments (widen_printf_format and the printf both 0x28 below); returns its D0.
func overlay_printf(fmt: int, a1: int, a2: int, a3_arg: int, a4: int, a5: int) -> int:
	assert(memory != null, "overlay_printf requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x28
	var wide: int = widen_printf_format(fmt)
	var r = _jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x262), [wide, a1, a2, a3_arg, a4, a5])
	a7 = entry_a7
	return int(r)

## 0x3ac4 (a2 saved): start mission scene n. The previous scene object (0x1d700) is deactivated
## (0xc below); the new one is word +0x74 of scene_root record n (+0x30 table, 0x18 bytes each).
## The anchor (find_anchor_point(0x1d83c, 0), 0x10 below) becomes the camera position; view mode,
## view_flag_d856 and 0x1b73c = 1, 0x1d824 = 1000000000; reset_distance_base_globals (0x10
## below), activate the scene object (0x14 below), the frame counter += 0x4b; then
## fill_pose_history_angles(player +0x36, its angle words +0x20 / +0x22 / +0x24),
## copy_player_pose_to_camera, spawn_cloud_layer and stop_all_sound_channels (all 0x24 below).
func start_mission_scene(scene: int) -> void:
	assert(memory != null, "start_mission_scene requires original global memory")
	var entry_a7: int = a7
	if memory.read_u32(0x1d700) != 0:
		a7 = entry_a7 - 0xc
		deactivate_object(memory.read_u32(0x1d700))
		a7 = entry_a7
	var record: int = C68kScript.u32(C68kScript.s32(C68kScript.s32(scene) * 24) + memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30))
	memory.write_u32(0x1d700, memory.read_u32(record + 0x74))
	a7 = entry_a7 - 0x10
	find_anchor_point(0x1d83c, 0)
	a7 = entry_a7
	memory.write_u32(DAT_0001d838, memory.read_u32(0x1d83c))
	memory.write_u32(DAT_0001d834, memory.read_u32(0x1d840))
	memory.write_u32(DAT_0001d830, memory.read_u32(0x1d844))
	memory.write_u16(DAT_0001d858, 1)
	memory.write_u16(DAT_0001d856, 1)
	memory.write_u16(0x1b73c, 1)
	memory.write_u32(0x1d824, 1000000000)
	a7 = entry_a7 - 0x10
	reset_distance_base_globals()
	a7 = entry_a7 - 0x14
	activate_near_range_object(memory.read_u32(0x1d700))
	a7 = entry_a7
	memory.write_u32(DAT_0001b838, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x4b))
	var player: int = memory.read_u32(DAT_0001b738)
	a7 = entry_a7 - 0x24
	fill_pose_history_angles(C68kScript.u32(player + 0x36), memory.read_s16(player + 0x20), memory.read_s16(player + 0x22), memory.read_s16(player + 0x24))
	copy_player_pose_to_camera()
	spawn_cloud_layer()
	stop_all_sound_channels()
	a7 = entry_a7

## 0x2e12 / 0x3732: a lone rts (the second is called twice by overlay_initialise).
func noop_stub_2e12() -> void:
	pass

func overlay_init_noop() -> void:
	pass

## 0x18d6: overlay start-up: the overlay RNG seeded with ticks (8 below), the palette usage maps
## (slot_usage_cur = 0x1d96c, 0x1d860 = 0x1d86c), the 8-bit and 4-bit span tables (all 8 below),
## the light vector (0xd983, 0x69d8, 0xc330), 0x1bd84 = 1, 0x1bd80 = 0, the frame counter 0x4c
## and set_view_distance(0xc15c0) (0xc below).
func overlay_initialise(ticks: int) -> void:
	assert(memory != null, "overlay_initialise requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 8
	overlay_rng_init(ticks)
	a7 = entry_a7
	memory.write_u32(DAT_0001d864, 0x1d96c)
	memory.write_u32(0x1d860, 0x1d86c)
	a7 = entry_a7 - 8
	init_code_pointer_tables()
	overlay_init_noop()
	overlay_init_noop()
	init_span_table_32ba()
	init_span_table_3466()
	init_span_table_3608()
	a7 = entry_a7
	memory.write_u16(DAT_0001bd8c, 0xd983)
	memory.write_u16(DAT_0001bd8a, 0x69d8)
	memory.write_u16(DAT_0001bd88, 0xc330)
	memory.write_u32(0x1bd84, 1)
	memory.write_u32(0x1bd80, 0)
	memory.write_u32(DAT_0001b838, 0x4c)
	a7 = entry_a7 - 0xc
	set_view_distance(0xc15c0)
	a7 = entry_a7

## 0x1112: the host's entry: host globals pointer (DAT_0001b5a0) = host, overlay_initialise(ticks)
## (8 below), host word +0x92 = 9 and the 22 overlay hooks (runtime addresses) into host +0x2e6..
## +0x33a.
const OVERLAY_HOOKS := [0x6fd6, 0x6eb6, 0x3aa4, 0x41f0, 0x44c8, 0x3da, 0x38d4, 0x4b0, 0xe80, 0xf72, 0x6578, 0x1074,
		0xd23a, 0x72f0, 0x73ea, 0x1d56, 0x1db8, 0x2886, 0xe352, 0x1f02, 0x934, 0x63ec]

func overlay_main_entry(host: int, ticks: int) -> void:
	assert(memory != null, "overlay_main_entry requires original global memory")
	var entry_a7: int = a7
	memory.write_u32(DAT_0001b5a0, C68kScript.u32(host))
	a7 = entry_a7 - 8
	overlay_initialise(ticks)
	a7 = entry_a7
	var world: int = memory.read_u32(DAT_0001b5a0)
	memory.write_u16(world + 0x92, 9)
	for k in OVERLAY_HOOKS.size():
		memory.write_u32(world + 0x2e6 + 4 * k, OVERLAY_HOOKS[k])

## 0x38f4 (two saved registers): put the player back at its anchor. Without a player object nothing
## happens. Unless 0x1d854, find_anchor_point(0x1d83c, 1) (0x14 below) picks the runway; the object
## takes the anchor position, the controller its attitude words, word +0x626 the definition's word
## +0x42; the pose ring is refilled (fill_pose_history_angles 0x1c below, fill_pose_history 0x2c
## below) and copied to the camera (0xc below). The flight state is reset (gear 0x2d, flaps 0, the
## ground height = y - definition word +0x40, surface 0x30, rates and inputs cleared, flags word
## +0x684 = 0x4000 into the ring through fill_pose_history_flags, 0x14 below) and so are the
## view / input words; a pending replay object (0x1b87c) is cleaned up (dispatch_entity_cleanup,
## 0x10 below). The object loses +4 bit 1 and gets bit 6 unless byte +7 bit 6, +0x3c = 0; the
## frame counter += 0x4b, view mode 1; drop_contact_records_for_object and
## reset_distance_base_globals (both 0x10 below).
func respawn_player_at_anchor() -> void:
	assert(memory != null, "respawn_player_at_anchor requires original global memory")
	if memory.read_u32(DAT_0001b738) == 0:
		return
	var obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	if obj == 0:
		return
	var entry_a7: int = a7
	if memory.read_u16(0x1d854) == 0:
		a7 = entry_a7 - 0x14
		find_anchor_point(0x1d83c, 1)
		a7 = entry_a7
	memory.write_u32(obj + 0x18, memory.read_u32(0x1d83c))
	memory.write_u32(obj + 0x1c, memory.read_u32(0x1d840))
	memory.write_u32(obj + 0x20, memory.read_u32(0x1d844))
	var ctl: int = memory.read_u32(DAT_0001b738)
	memory.write_u16(ctl + 0x20, memory.read_u16(0x1d83c + 0xe))
	memory.write_u16(ctl + 0x22, memory.read_u16(0x1d83c + 0x12))
	memory.write_u16(ctl + 0x24, memory.read_u16(0x1d83c + 0x16))
	memory.write_u16(ctl + 0x626, memory.read_u16(memory.read_u32(ctl + 4) + 0x42))
	a7 = entry_a7 - 0x1c
	fill_pose_history_angles(C68kScript.u32(memory.read_u32(DAT_0001b738) + 0x36), memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24))
	a7 = entry_a7 - 0x2c
	fill_pose_history(C68kScript.u32(memory.read_u32(DAT_0001b738) + 0x36), memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20))
	a7 = entry_a7 - 0xc
	copy_player_pose_to_camera()
	a7 = entry_a7
	ctl = memory.read_u32(DAT_0001b738)
	memory.write_u8(ctl + 0x679, 0x2d)
	memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) | 2)
	memory.write_u8(ctl + 0x67b, 0)
	memory.write_u8(ctl + 0x63e, 1)
	memory.write_u32(ctl + 0x2e, C68kScript.u32(memory.read_s32(obj + 0x1c) - memory.read_s16(memory.read_u32(ctl + 4) + 0x40)))
	memory.write_u8(ctl + 0x2c, 0x30)
	for off in [0x640, 0x641, 0x674, 0x676, 0x677]:
		memory.write_u8(ctl + off, 0)
	memory.write_u32(ctl + 0x10, 0)
	memory.write_u32(ctl + 0xc, 0)
	memory.write_u32(ctl + 8, 0)
	memory.write_u16(ctl + 0x684, 0x4000)
	a7 = entry_a7 - 0x14
	fill_pose_history_flags(C68kScript.u32(memory.read_u32(DAT_0001b738) + 0x36), memory.read_s16(ctl + 0x684))
	a7 = entry_a7
	ctl = memory.read_u32(DAT_0001b738)
	memory.write_u8(ctl + 0x668, 0)
	memory.write_u32(ctl + 0x66e, 0)
	memory.write_u32(ctl + 0x66a, 0)
	memory.write_u32(ctl + 0x62a, 0)
	memory.write_u16(ctl + 0x636, 0)
	memory.write_u16(ctl + 0x638, 0)
	memory.write_u16(0x1b868, 0)
	memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xd6, 0)
	memory.write_u16(0x1b874, 0)
	memory.write_u16(0x1b872, 0)
	memory.write_u16(0x1b86c, 0)
	var replay: int = memory.read_u32(0x1b87c)
	if replay != 0 and memory.read_u32(replay) != 0:
		a7 = entry_a7 - 0x10
		dispatch_entity_cleanup(memory.read_u32(replay))
		a7 = entry_a7
		memory.write_u32(0x1b87c, 0)
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xfffffffd)
	memory.write_u32(obj + 0x3c, 0)
	memory.write_u32(DAT_0001b838, C68kScript.u32(memory.read_u32(DAT_0001b838) + 0x4b))
	memory.write_u16(DAT_0001d858, 1)
	var player_obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	if (memory.read_u8(player_obj + 7) & 0x40) == 0:
		memory.write_u32(player_obj + 4, memory.read_u32(player_obj + 4) | 0x40)
	a7 = entry_a7 - 0x10
	drop_contact_records_for_object(memory.read_u32(memory.read_u32(DAT_0001b738)))
	reset_distance_base_globals()
	a7 = entry_a7

## The steps of overlay_init_template_pointer_tables after its first loop: (source, size, slot
## offset into DAT_0001b524), in groups of up to three calls whose arguments stay pushed (the
## k-th call of a group is 0xc * k deeper).
const TEMPLATE_STEPS_A := [[[0x1a8b8, 0x1a, 0x14], [0x1a8d2, 0x1a, 0x18], [0x1a8ec, 0x1a, 0x1c]],
		[[0x1a906, 0x1a, 0x28], [0x1a920, 0x1a, 0x2c], [0x1a93a, 0x1a, 0x20]],
		[[0x1a954, 0x1a, 0x24], [0x1a96e, 0x1a, 0x44], [0x1a988, 0x20, 0x30]],
		[[0x1a9a8, 0x1a, 0x34], [0x1a9c2, 0x1a, 0x38], [0x1a9dc, 0x1a, 0x3c]],
		[[0x1a9f6, 0x1a, 0x40], [0x1aa10, 0x1a, 0x48], [0x1aa2a, 0x1a, 0x4c]],
		[[0x1aa44, 0x1a, 0x50]]]
const TEMPLATE_STEPS_B := [[[0x1aaea, 0x1a, 0x68], [0x1ab04, 0x1a, 0x6c], [0x1ab1e, 0x1a, 0x70]],
		[[0x1ab38, 0x1a, 0x74], [0x1ab52, 0x1a, 0x78]]]

## One template copy: heap_alloc(size) then copy_block_return_dst(block, source, size), both entered
## depth below (six saved registers, three pushed arguments, jsr: 0x28, plus earlier calls of the
## group); returns the copy.
func _copy_template(entry_a7: int, depth: int, source: int, size: int) -> int:
	a7 = entry_a7 - depth
	var block: int = C68kScript.u32(heap_alloc(size))
	var copied: int = C68kScript.u32(copy_block_return_dst(block, source, size))
	a7 = entry_a7
	return copied

## 0x54: heap copies of the built-in definition templates into the template pointer table
## (DAT_0001b524): four 0x4a-byte records from 0x1a790 and five 0x1c-byte records from 0x1aa5e at
## the slot their first word names, and the fixed 0x1a / 0x20-byte records of TEMPLATE_STEPS_A / _B.
func overlay_init_template_pointer_tables() -> void:
	assert(memory != null, "overlay_init_template_pointer_tables requires original global memory")
	var entry_a7: int = a7
	for k in 4:
		var src: int = 0x1a790 + 0x4a * k
		memory.write_u32(C68kScript.u32(DAT_0001b524 + memory.read_s16(src) * 4), _copy_template(entry_a7, 0x28, src, 0x4a))
	for group in TEMPLATE_STEPS_A:
		for k in group.size():
			memory.write_u32(DAT_0001b524 + group[k][2], _copy_template(entry_a7, 0x28 + 0xc * k, group[k][0], group[k][1]))
	for k in 5:
		var src2: int = 0x1aa5e + 0x1c * k
		memory.write_u32(C68kScript.u32(DAT_0001b524 + memory.read_s16(src2) * 4), _copy_template(entry_a7, 0x28, src2, 0x1c))
	for group in TEMPLATE_STEPS_B:
		for k in group.size():
			memory.write_u32(DAT_0001b524 + group[k][2], _copy_template(entry_a7, 0x28 + 0xc * k, group[k][0], group[k][1]))

## 0x16e2 (six saved registers): build the mission scene. The template tables first (0x1c below);
## the scene root = instantiate_object_from_desc(host +0x8c) (0x20 below); its 24-byte child records
## (sext word +0x2e of them, from descriptor +0x28 + 0x1a) are copied into a heap table (+0x30,
## heap_alloc 0x24 below) with +0x14 relocated by host +0x8c, then each child is instantiated (0x20
## below) with +0x24 = root and bytes +1 / +2 = its index. Children 0 / 1 / 4 become mission_child0 /
## 1 / 4, child 2 (or 3 when host word +0x90 == 2) mission_child2or3 and its face table
## default_surface_face; they are activated (activate_near_range_object) and children 0 and 4 get
## their vertex copies (copy_object_vertex_buffer; depths as the original's arguments pile up).
## The pool count is cleared; the child window (word root +0x2c - 1 .. + 1) is published in
## 0x1b88e / 0x1b88c and its three children in 0x1bc28 / 0x1bc34 / 0x1bc38.
func init_mission_object_tables() -> void:
	assert(memory != null, "init_mission_object_tables requires original global memory")
	var entry_a7: int = a7
	a7 = entry_a7 - 0x1c
	overlay_init_template_pointer_tables()
	a7 = entry_a7 - 0x20
	var root: int = C68kScript.u32(instantiate_object_from_desc(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c)))
	a7 = entry_a7
	memory.write_u32(DAT_0001d6fc, root)
	var src: int = C68kScript.u32(memory.read_u32(root + 0x28) + 0x1a)
	var count: int = memory.read_s16(root + 0x2e)
	a7 = entry_a7 - 0x24
	memory.write_u32(root + 0x30, C68kScript.u32(heap_alloc(C68kScript.s32(count * 24))))
	a7 = entry_a7
	for k in range(maxi(count, 0)):
		var rec: int = C68kScript.u32(memory.read_u32(root + 0x30) + 24 * k)
		for w in 6:
			memory.write_u32(rec + 4 * w, memory.read_u32(src + 4 * w))
		src = C68kScript.u32(src + 0x18)
		memory.write_u32(rec + 0x14, C68kScript.u32(memory.read_u32(rec + 0x14) + memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x8c)))
	for k in range(maxi(count, 0)):
		var rec2: int = C68kScript.u32(memory.read_u32(root + 0x30) + 24 * k)
		a7 = entry_a7 - 0x20
		var child: int = C68kScript.u32(instantiate_object_from_desc(memory.read_u32(rec2 + 0x14)))
		a7 = entry_a7
		memory.write_u32(C68kScript.u32(memory.read_u32(root + 0x30) + 24 * k + 0x14), child)
		memory.write_u32(child + 0x24, root)
		memory.write_u8(child + 1, k & 0xff)
		memory.write_u8(child + 2, k & 0xff)
	var table: int = memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30)
	memory.write_u32(0x1bdb4, memory.read_u32(table + 0x14))
	a7 = entry_a7 - 0x20
	activate_near_range_object(memory.read_u32(0x1bdb4))
	a7 = entry_a7 - 0x24
	copy_object_vertex_buffer(memory.read_u32(0x1bdb4))
	table = memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30)
	memory.write_u32(DAT_0001bdb0, memory.read_u32(table + 0x2c))
	a7 = entry_a7 - 0x28
	activate_near_range_object(memory.read_u32(DAT_0001bdb0))
	a7 = entry_a7 - 0x2c
	copy_object_vertex_buffer(memory.read_u32(0x1bdb4))
	table = memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30)
	memory.write_u32(DAT_0001bdac, memory.read_u32(table + (0x5c if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0x90) == 2 else 0x44)))
	a7 = entry_a7 - 0x20
	activate_near_range_object(memory.read_u32(DAT_0001bdac))
	a7 = entry_a7
	memory.write_u32(DAT_0001bda8, memory.read_u32(memory.read_u32(DAT_0001bdac) + 0x48))
	table = memory.read_u32(memory.read_u32(DAT_0001d6fc) + 0x30)
	memory.write_u32(DAT_0001bda4, memory.read_u32(table + 0x74))
	a7 = entry_a7 - 0x20
	activate_near_range_object(memory.read_u32(DAT_0001bda4))
	a7 = entry_a7 - 0x24
	copy_object_vertex_buffer(memory.read_u32(DAT_0001bda4))
	a7 = entry_a7
	memory.write_u32(DAT_0001b734, 0)
	var root2: int = memory.read_u32(DAT_0001d6fc)
	var lo: int = C68kScript.s32(memory.read_s16(root2 + 0x2c) - 1)
	memory.write_u16(DAT_0001b88e, C68kScript.u16(lo))
	var children: int = memory.read_u32(root2 + 0x30)
	memory.write_u32(0x1bc28, memory.read_u32(C68kScript.u32(children + 24 * lo + 0x14)))
	memory.write_u32(0x1bc34, memory.read_u32(C68kScript.u32(children + 24 * (lo + 1) + 0x14)))
	memory.write_u32(0x1bc38, memory.read_u32(C68kScript.u32(children + 24 * (lo + 2) + 0x14)))
	memory.write_u16(DAT_0001b88c, C68kScript.u16(lo + 2))

## Camera-matrix transform of a word vector (x, y, z) into a 12-byte view record's words +2 / +6 /
## +0xa ((sum of muls.w + 0x800) asr 12 through the camera matrix 0x1d744).
func _camera_transform_words(x: int, y: int, z: int, out: int) -> void:
	for c in 3:
		var acc: int = C68kScript.s32(x * memory.read_s16(DAT_0001d744 + 2 * c) + y * memory.read_s16(DAT_0001d744 + 6 + 2 * c)
				+ z * memory.read_s16(DAT_0001d744 + 12 + 2 * c) + 0x800)
		memory.write_u16(out + 2 + 4 * c, C68kScript.u16(C68kScript.asr32(acc, 12)))

## 0x162ba (link.w a6,#-0x30, ten saved registers: body 0x5c below the entry): plot the objects
## queued as dots. With the host line routine (word +0x9e) the queue and dot count are emptied
## first. The erase routine (depth_routine_da84, 0x60 below) runs; then for each queued object
## its first face fixes the dot colour: a face with a palette slot takes the colour tally's slot
## when one is running, else assign_face_colour (0x64 below; failure ends the routine at once)
## starts the tally; the colour word 0x1da88 = face word +6 (except with a running tally). A
## trail (controller byte +0x3b bit 1) projects its first two vertices relative to the camera
## (shifted by word +0x34 - shift), anything else its own position (asr shift), through the camera
## matrix into the frame records (a6 - 0x18). Each record in front (z > 4) and on screen gets a
## dot record (0x26288 + 14 n: size word +6 = 4 within 5000 asr shift, 3 within 1.5 times, 2
## within twice, else 1; colour byte +8 = low byte of 0x1da88) plotted through depth_routine_da80
## (record, x, y, size; 0x70 below). The queue is emptied and the dot count stored.
func draw_distant_object_dots() -> void:
	assert(memory != null, "draw_distant_object_dots requires original global memory")
	assert(a7 != 0, "draw_distant_object_dots needs a7 (its frame holds the view records)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var records: int = a6 - 0x18
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0x9e) != 0:
		memory.write_u16(DAT_000265d0, 0)
		memory.write_u16(DAT_0001da8c, 0)
	a7 = entry_a7 - 0x60
	_jsr(memory.read_u32(0x1da84), [])
	a7 = entry_a7
	var queue: int = DAT_000265d2
	var out: int = DAT_00026288
	var left: int = memory.read_u16(DAT_000265d0)
	while true:
		left = (left - 1) & 0xffff
		if left == 0xffff:
			break
		var obj: int = memory.read_u32(queue)
		queue += 4
		var ctl: int = memory.read_u32(obj + 8)
		var face: int = memory.read_u32(obj + 0x48)
		var shift: int = memory.read_s16(obj + 0x32)
		var tally_used: bool = false
		if memory.read_u8(face + 0xf) != 0xff:
			if memory.read_u16(0x1da8a) != 0:
				memory.write_u8(face + 0xf, memory.read_u8(0x1da8b))
				tally_used = true
			else:
				a7 = entry_a7 - 0x64
				var failed: int = assign_face_colour(face)
				a7 = entry_a7
				if failed != 0:
					return
				memory.write_u16(0x1da8a, memory.read_u8(face + 0xf))
		if not tally_used:
			memory.write_u16(DAT_0001da88, memory.read_u16(face + 6))
		var near: int
		var count: int
		if (memory.read_u8(ctl + 0x3b) & 2) != 0:
			var d5: int = C68kScript.s16(memory.read_u16(obj + 0x34) - shift)
			var rel: Array = []
			for k in 3:
				rel.append(_shift_signed(C68kScript.s32(memory.read_u32([DAT_0001d838, DAT_0001d834, DAT_0001d830][k]) - memory.read_u32(obj + 0x18 + 4 * k)), d5))
			near = _shift_signed(5000, d5)
			var v: int = memory.read_u32(obj + 0x44)
			for k in 3:
				var x: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v), shift) - rel[0])
				var y: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 4), shift) - rel[1])
				var z: int = C68kScript.s16(C68kScript.asr32(memory.read_s32(v + 8), shift) - rel[2])
				_camera_transform_words(x, y, z, records + 12 * k)
				v += 12
			count = 2
		else:
			var px: int = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x18) - memory.read_u32(DAT_0001d838)), shift))
			var py: int = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(DAT_0001d834)), shift))
			var pz: int = C68kScript.s16(C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x20) - memory.read_u32(DAT_0001d830)), shift))
			near = C68kScript.asr32(5000, shift)
			_camera_transform_words(px, py, pz, records)
			count = 1
		for k in count:
			var rec: int = records + 12 * k
			var z2: int = memory.read_s16(rec + 0xa)
			if z2 <= 4:
				continue
			var sx: int = C68kScript.divs_trunc(C68kScript.s32(memory.read_s16(rec + 2) * memory.read_s16(DAT_00020b28)), z2)
			var sy: int = C68kScript.divs_trunc(C68kScript.s32(-memory.read_s16(rec + 6) * memory.read_s16(DAT_00020b26)), z2)
			if memory.read_s16(DAT_00020aee) > sx or C68kScript.s32(memory.read_s16(DAT_00020aec) - 1) < sx:
				continue
			if memory.read_s16(DAT_00020aea) > sy or C68kScript.s32(memory.read_s16(0x20ae8) - 1) < sy:
				continue
			var size: int
			if z2 <= near:
				size = 4
			else:
				var half: int = near
				if half < 0:
					half += 1
				var mid: int = C68kScript.s32((half >> 1) + near)
				if mid >= z2:
					size = 3
				elif C68kScript.s32(C68kScript.lsl32(near, 1)) >= z2:
					size = 2
				else:
					size = 1
			memory.write_u16(out + 6, size)
			memory.write_u8(out + 8, memory.read_u8(0x1da89))
			a7 = entry_a7 - 0x70
			_jsr(memory.read_u32(0x1da80), [out, sx, sy, size])
			a7 = entry_a7
			out += 0xe
	memory.write_u16(DAT_000265d0, 0)
	memory.write_u16(DAT_0001da8c, C68kScript.u16(C68kScript.divs_trunc(C68kScript.s32(out - DAT_00026288), 0xe)))

## The depth-specific code addresses configure_renderer_for_display installs (runtime addresses):
## span fillers 0x20ac0 / 0x20abc / 0x20ab8, line draw / restore 0x1da9c / 0x1da98, dot plot / erase
## 0x1da80 / 0x1da84, blip draw / erase 0x1da94 / 0x1da90, face output 0x20ab4.
const RENDERER_HOOKS_8 := [[0x20ac0, 0x3794], [0x20abc, 0x3794], [0x20ab8, 0x3794], [0x1da9c, 0xd39c], [0x1da98, 0xd8fa],
		[0x1da80, 0x15f1e], [0x1da84, 0x15e9e], [0x1da94, 0x177f0], [0x1da90, 0x17760], [0x20ab4, 0xa14e]]
const RENDERER_HOOKS_4 := [[0x20ac0, 0x329a], [0x20abc, 0x3446], [0x20ab8, 0x35e8], [0x1da9c, 0xd590], [0x1da98, 0xdb40],
		[0x1da80, 0x16108], [0x1da84, 0x15f98], [0x1da94, 0x17928], [0x1da90, 0x17848], [0x20ab4, 0xa14e]]
const RENDERER_HOOKS_1 := [[0x1da80, 0x16210], [0x1da84, 0x16208], [0x1da94, 0x17a40], [0x1da90, 0x17a14]]

## 0x6ff6 (d2 saved): view geometry from the host (rows +0x18, width +0x16, origin +0x12 / +0x14:
## half sizes, the centre column 16.16 and the projection scales (width + width / 2) / 2). When the
## depth (host word +0xe) or the multi-screen flag changed: depth 8 / 4 rebuild their colour state
## (8 below) and install their renderer hooks, depth 1 uses the 1-bit face output and the host line
## routine (+0x276) for both line hooks; the new depth and flag are kept, the colour record (+0x34,
## +0x38) copied, the mission built when absent (init_mission_object_tables, 0xc below), the template
## words patched (0x1d5, or 0x195 at depth 1; 0xc below) and faces 1..4 of mission_child4 flagged
## (+0x13 bit 1 set, or cleared at depth 1). Then the colour record again, the clip bounds (x
## -width / 2 .. width / 2 - 1, y -rows / 2 .. rows / 2, toward zero) and update_view_clip_bounds
## (8 below).
func configure_renderer_for_display() -> void:
	assert(memory != null, "configure_renderer_for_display requires original global memory")
	var entry_a7: int = a7
	var world: int = memory.read_u32(DAT_0001b5a0)
	memory.write_u16(DAT_0001b828, memory.read_u16(world + 0x18))
	memory.write_u16(0x20ae6, memory.read_u16(DAT_0001b828))
	var width: int = memory.read_s16(world + 0x16)
	memory.write_u16(DAT_00020b2a, C68kScript.u16(width))
	memory.write_u16(DAT_0001b82a, C68kScript.u16(width))
	memory.write_u16(0x1b82e, memory.read_u16(world + 0x12))
	memory.write_u16(0x1b82c, memory.read_u16(world + 0x14))
	memory.write_u16(DAT_00020b2c, C68kScript.u16(memory.read_s16(DAT_0001b828) >> 1))
	var half_w: int = width >> 1
	memory.write_u16(DAT_00020b2a, C68kScript.u16(half_w))
	memory.write_u32(DAT_00020af0, C68kScript.u32(C68kScript.lsl32(C68kScript.s32(half_w * 2 - 1), 16)) | 0x8000)
	var half_toward: int = width
	if half_toward < 0:
		half_toward += 1
	var scale: int = C68kScript.s32(width + C68kScript.s16(half_toward >> 1))
	if scale < 0:
		scale += 1
	scale = C68kScript.u16(scale >> 1)
	for g in [DAT_00020b28, DAT_00020b26, 0x20b14, 0x20afc]:
		memory.write_u16(g, scale)
	world = memory.read_u32(DAT_0001b5a0)
	var depth: int = memory.read_s16(world + 0xe)
	if not (memory.read_u16(DAT_0001b826) == memory.read_u16(world + 0xe) and memory.read_u16(0x1b824) == memory.read_u16(world + 0xb4)):
		if depth == 8:
			a7 = entry_a7 - 8
			init_depth8_colour_state()
			a7 = entry_a7
			for h in RENDERER_HOOKS_8:
				memory.write_u32(h[0], h[1])
		if memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe) == 4:
			a7 = entry_a7 - 8
			init_depth4_colour_state()
			a7 = entry_a7
			for h in RENDERER_HOOKS_4:
				memory.write_u32(h[0], h[1])
		world = memory.read_u32(DAT_0001b5a0)
		if memory.read_s16(world + 0xe) == 1:
			memory.write_u32(DAT_00020ab4, 0xa200)
			memory.write_u32(DAT_0001da9c, memory.read_u32(world + 0x276))
			memory.write_u32(DAT_0001da98, memory.read_u32(world + 0x276))
			for h in RENDERER_HOOKS_1:
				memory.write_u32(h[0], h[1])
		world = memory.read_u32(DAT_0001b5a0)
		memory.write_u16(DAT_0001b826, memory.read_u16(world + 0xe))
		memory.write_u16(0x1b824, memory.read_u16(world + 0xb4))
		memory.write_u32(DAT_0001d85c, memory.read_u32(world + 0x34))
		memory.write_u16(DAT_0001d85a, memory.read_u16(world + 0x38))
		if memory.read_u32(0x1bdb4) == 0:
			a7 = entry_a7 - 0xc
			init_mission_object_tables()
			a7 = entry_a7
		var bw: bool = memory.read_s16(memory.read_u32(DAT_0001b5a0) + 0xe) == 1
		a7 = entry_a7 - 0xc
		overlay_patch_template_u16_pair(0x195 if bw else 0x1d5)
		a7 = entry_a7
		var faces: int = memory.read_u32(memory.read_u32(DAT_0001bda4) + 0x48)
		for k in range(1, 5):
			var flag: int = faces + 0x20 * k + 0x13
			memory.write_u8(flag, (memory.read_u8(flag) & 0xfd) if bw else (memory.read_u8(flag) | 2))
	world = memory.read_u32(DAT_0001b5a0)
	memory.write_u32(DAT_0001d85c, memory.read_u32(world + 0x34))
	memory.write_u16(DAT_0001d85a, memory.read_u16(world + 0x38))
	var w2: int = memory.read_s16(DAT_0001b82a)
	var neg_w: int = -w2
	if neg_w < 0:
		neg_w += 1
	memory.write_u16(DAT_00020aee, C68kScript.u16(neg_w >> 1))
	var pw: int = w2
	if pw < 0:
		pw += 1
	memory.write_u16(DAT_00020aec, C68kScript.u16((pw >> 1) - 1))
	var rows: int = memory.read_s16(DAT_0001b828)
	var pr: int = rows
	if pr < 0:
		pr += 1
	pr = C68kScript.u16(pr >> 1)
	memory.write_u16(0x20ae8, pr)
	memory.write_u16(DAT_0001b740, pr)
	memory.write_u16(DAT_0001b73e, pr)
	var neg_r: int = -rows
	if neg_r < 0:
		neg_r += 1
	memory.write_u16(DAT_00020aea, C68kScript.u16(neg_r >> 1))
	a7 = entry_a7 - 8
	update_view_clip_bounds()
	a7 = entry_a7

## Slew keys of player_slew_mode: key byte -> (axis 1..3, sign).
const SLEW_KEYS := {4: [1, -1], 6: [1, 1], 2: [2, -1], 8: [2, 1], 1: [3, -1], 7: [3, 1]}

## 0xf810 (link.w a6,#-0x20, four saved registers: body 0x34 below the entry): the slew (free
## flight) mode of the player controller. Yaw / pitch (+0x20 / +0x22) turn by half the input words
## +0x662 / +0x666 (14-bit), roll is 0. Key byte +0x668 drives the speed (+0x62a) along one axis
## (+0x678: 1 x for keys 4 / 6, 2 z for 2 / 8, 3 y for 1 / 7): a new axis starts at -/+1000, the same
## axis adds -/+ max(|speed| / 2, 1000), another axis keeps the magnitude with the key's sign; key 5
## stops. With an axis, a speed under 1000 in magnitude is set to 1000 with the opposite sign (as
## in the original), and the speed is rotated by the attitude (build_attitude_matrix_3ang into the
## frame, 0x48 below; transform_int3_vecs_by_matrix3, 0x58 below) into the velocity (+8 / +0xc /
## +0x10 = vector asr 6). The object is kept above ground (y + vy > 0x3f, else y = 0x40 and vy = 0).
## The key and word +0x626 are cleared; with the gun on (+0x676) a burst is fired every third
## frame (spawn_ordnance_oriented(0, 1, position, attitude, (+0x626 - def word +0x44) & 0x3fff),
## 0x5c below). The gear byte +0x679 moves one step toward down while between 1 and 0x2c
## (unless +0x685 bit 5) or negative, marking +0x67a bit 1.
func player_slew_mode(ctl: int) -> void:
	assert(memory != null, "player_slew_mode requires original global memory")
	assert(a7 != 0, "player_slew_mode needs a7 (its frame holds the matrix and vector)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	var vec: int = a6 - 0xc
	var matrix: int = a6 - 0x1e
	var obj: int = memory.read_u32(ctl)
	for pair in [[0x662, 0x20], [0x666, 0x22]]:
		var turn: int = memory.read_s16(ctl + pair[0])
		if turn < 0:
			turn += 1
		memory.write_u16(ctl + pair[1], C68kScript.u16((turn >> 1) + memory.read_u16(ctl + pair[1])) & 0x3fff)
	memory.write_u16(ctl + 0x24, 0)
	a7 = entry_a7 - 0x3c
	var step: int = abs_int(C68kScript.asr32(memory.read_s32(ctl + 0x62a), 1))
	a7 = entry_a7
	if step < 1000:
		step = 1000
	var key: int = memory.read_u8(ctl + 0x668)
	if key == 5:
		memory.write_u32(ctl + 0x62a, 0)
		memory.write_u8(ctl + 0x678, 0)
	elif SLEW_KEYS.has(key):
		var axis: int = SLEW_KEYS[key][0]
		var sign: int = SLEW_KEYS[key][1]
		var current: int = memory.read_u8(ctl + 0x678)
		if current == 0:
			memory.write_u32(ctl + 0x62a, C68kScript.u32(1000 * sign))
		elif current == axis:
			memory.write_u32(ctl + 0x62a, C68kScript.u32(memory.read_s32(ctl + 0x62a) + step * sign))
		else:
			a7 = entry_a7 - 0x3c
			var mag: int = abs_int(memory.read_s32(ctl + 0x62a))
			a7 = entry_a7
			memory.write_u32(ctl + 0x62a, C68kScript.u32(mag * sign))
		memory.write_u8(ctl + 0x678, axis)
	memory.write_u32(vec, 0)
	memory.write_u32(vec + 4, 0)
	memory.write_u32(vec + 8, 0)
	var axis2: int = memory.read_u8(ctl + 0x678)
	if axis2 != 0:
		a7 = entry_a7 - 0x3c
		var speed_mag: int = abs_int(memory.read_s32(ctl + 0x62a))
		a7 = entry_a7
		if speed_mag < 1000:
			memory.write_u32(ctl + 0x62a, 1000 if memory.read_s32(ctl + 0x62a) < 0 else C68kScript.u32(-1000))
		match axis2:
			1:
				memory.write_u32(vec, memory.read_u32(ctl + 0x62a))
			2:
				memory.write_u32(vec + 8, memory.read_u32(ctl + 0x62a))
			3:
				memory.write_u32(vec + 4, memory.read_u32(ctl + 0x62a))
		a7 = entry_a7 - 0x48
		build_attitude_matrix_3ang(memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24), matrix)
		a7 = entry_a7 - 0x58
		transform_int3_vecs_by_matrix3(1, vec, vec, matrix)
		a7 = entry_a7
	memory.write_u32(ctl + 8, C68kScript.u32(C68kScript.asr32(memory.read_s32(vec), 6)))
	memory.write_u32(ctl + 0xc, C68kScript.u32(C68kScript.asr32(memory.read_s32(vec + 4), 6)))
	memory.write_u32(ctl + 0x10, C68kScript.u32(C68kScript.asr32(memory.read_s32(vec + 8), 6)))
	if not (0x3f < C68kScript.s32(memory.read_u32(obj + 0x1c) + memory.read_u32(ctl + 0xc))):
		memory.write_u32(obj + 0x1c, 0x40)
		memory.write_u32(ctl + 0xc, 0)
	memory.write_u8(ctl + 0x668, 0)
	memory.write_u16(ctl + 0x626, 0)
	var gun: int = memory.read_u8(ctl + 0x676)
	if gun != 0:
		if gun == 1:
			var heading: int = C68kScript.s32(memory.read_s16(ctl + 0x626) - memory.read_s16(memory.read_u32(ctl + 4) + 0x44)) & 0x3fff
			a7 = entry_a7 - 0x5c
			spawn_ordnance_oriented(0, 1, memory.read_s32(obj + 0x18), memory.read_s32(obj + 0x1c), memory.read_s32(obj + 0x20),
					memory.read_s16(ctl + 0x20), memory.read_s16(ctl + 0x22), memory.read_s16(ctl + 0x24), heading)
			a7 = entry_a7
		var old: int = memory.read_u8(ctl + 0x676)
		memory.write_u8(ctl + 0x676, (old + 1) & 0xff)
		if old == 2:
			memory.write_u8(ctl + 0x676, 0)
	var gear: int = memory.read_s8(ctl + 0x679)
	if (gear > 0 and gear <= 0x2c and (memory.read_u8(ctl + 0x685) & 0x20) == 0) or gear < 0:
		memory.write_u8(ctl + 0x679, (memory.read_u8(ctl + 0x679) + 1) & 0xff)
		memory.write_u8(ctl + 0x67a, memory.read_u8(ctl + 0x67a) | 2)

## 0x96f4 (no frame, three saved registers: callees with one argument are entered 0x14 below the
## entry, the six-argument host play 0x28, stop_all_sound_channels 0x10): the per-frame sound
## update. Without sound (host word +0x9a) nothing plays; in views other than 0..2, 5, 7 and 8 all
## channels stop. Otherwise channel 1 idle (host +0x2b6(1)) clears channel1_sound. Views 8 / 9 only
## play the pending explosion sounds (8 near, 9 distant). The other views follow the player (or,
## in view 7, designated_entity_2): outside view 7 a near explosion becomes distant and the gear
## (+0x679 not 0 / 0x2d, +0x685 bit 5 clear) and flaps (+0x67b not 0 / 0xf) moving flags are set;
## the gun (5), flaps / gear (7), ditch (11) and grass (12) loops play or stop, the wheel (6),
## explosions, sound 100 and the one-shot voice sounds 1..4 play. With channel 1 free or holding
## another sound than 1, 3 or 4, and engine sound on (host word +0x9c), the engine runs on channel
## 0: a stalled engine (+0x669) plays record 0 at rate +0x66a + 0x10000, rpm above 10000 record 10
## at (rpm * 4) / 3 + 0x4000, otherwise channel 0 stops; a record is (re)started on channel 0
## (host +0x2aa(0, rec + 0x16, 0, size, 0, size)) when the choice changed or the channel is idle,
## then its rate is set (host +0x2b2). Without engine sound channel 0 stops and the choice is -1.
## The one-frame flags are cleared and the explosion timers count down.
func update_game_sounds() -> void:
	assert(memory != null, "update_game_sounds requires original global memory")
	var entry_a7: int = a7
	var view: int = memory.read_s16(DAT_0001d858)
	if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0x9a) != 0:
		if view <= 2 or view == 5 or view == 7 or view == 8:
			if _sound_host(0x2b6, [1]) == 0:
				memory.write_u32(DAT_00024d10, 0)
			if view == 8 or view == 9:
				_play_pending_explosions()
			else:
				_update_view_sounds(entry_a7, view)
		else:
			a7 = entry_a7 - 0x10
			stop_all_sound_channels()
			a7 = entry_a7
	for flag in [DAT_0001b856, DAT_0001b852, DAT_0001b850, DAT_0001b854]:
		memory.write_u16(flag, 0)
	for timer in [DAT_0001b848, DAT_0001b84a]:
		if memory.read_u16(timer) != 0:
			memory.write_u16(timer, (memory.read_u16(timer) - 1) & 0xffff)
	for flag in [DAT_0001b846, DAT_0001b844, DAT_0001b842, DAT_0001b83e, DAT_0001b83c]:
		memory.write_u16(flag, 0)

## A host sound routine (host_world + offset) called from update_game_sounds (0x14 below its
## entry for one argument, 0x28 for six); returns its long result.
func _sound_host(offset: int, args: Array) -> int:
	var entry_a7: int = a7
	a7 = entry_a7 - (0x28 if args.size() == 6 else 0x14)
	var result: int = C68kScript.u32(_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + offset), args))
	a7 = entry_a7
	return result

## update_game_sounds: a pending near (8) / distant (9) explosion plays and its timer is cleared.
func _play_pending_explosions() -> void:
	var entry_a7: int = a7
	for pair in [[DAT_0001b84a, 8], [DAT_0001b848, 9]]:
		if memory.read_u16(pair[0]) != 0:
			a7 = entry_a7 - 0x14
			play_game_sound(pair[1])
			a7 = entry_a7
			memory.write_u16(pair[0], 0)

## update_game_sounds for the views that follow an aircraft (0..2, 5, 7).
func _update_view_sounds(entry_a7: int, view: int) -> void:
	var ctl: int
	if view == 7:
		ctl = memory.read_u32(DAT_0001b888)
	else:
		ctl = memory.read_u32(DAT_0001b738)
		if memory.read_u16(DAT_0001b84a) != 0:
			memory.write_u16(DAT_0001b848, memory.read_u16(DAT_0001b84a))
			memory.write_u16(DAT_0001b84a, 0)
		var gear: int = abs_int(memory.read_s8(ctl + 0x679))
		memory.write_u16(DAT_0001b84e, 1 if gear != 0 and gear != 0x2d and (memory.read_u8(ctl + 0x685) & 0x20) == 0 else 0)
		var flaps: int = abs_int(memory.read_s8(ctl + 0x67b))
		memory.write_u16(DAT_0001b84c, 1 if flaps != 0 and flaps != 0xf else 0)
	a7 = entry_a7 - 0x14
	_play_or_stop(memory.read_u16(DAT_0001b852) != 0, 5)
	if memory.read_u16(DAT_0001b856) != 0:
		play_game_sound(6)
	_play_or_stop(memory.read_u16(DAT_0001b84e) != 0 or memory.read_u16(DAT_0001b84c) != 0, 7)
	_play_or_stop(memory.read_u16(DAT_0001b850) != 0, 0xb)
	_play_or_stop(memory.read_u16(DAT_0001b854) != 0, 0xc)
	a7 = entry_a7
	_play_pending_explosions()
	a7 = entry_a7 - 0x14
	for pair in [[DAT_0001b846, 100], [DAT_0001b844, 1], [DAT_0001b842, 2], [DAT_0001b83c, 3], [DAT_0001b83e, 4]]:
		if memory.read_u16(pair[0]) != 0:
			play_game_sound(pair[1])
	a7 = entry_a7
	var channel1: int = memory.read_u32(DAT_00024d10)
	var host: int = memory.read_u32(DAT_0001b5a0)
	if (channel1 == 0 or (channel1 != 1 and channel1 != 3 and channel1 != 4)) and memory.read_u16(host + 0x9c) != 0:
		var rate: int = memory.read_s32(ctl + 0x66a)
		var choice: int
		var rec: int
		var stalled: bool
		if view == 7:
			stalled = memory.read_u8(memory.read_u32(DAT_0001b888) + 0x669) != 0
		else:
			stalled = memory.read_u8(memory.read_u32(DAT_0001b738) + 0x669) != 0
		if stalled:
			choice = 0
			rec = memory.read_u32(memory.read_u32(host + 0x25e))
			rate = C68kScript.s32(rate + 0x10000)
		elif rate > 0x2710:
			choice = 10
			rec = memory.read_u32(memory.read_u32(host + 0x25e) + 0x28)
			rate = C68kScript.s32(C68kScript.divs_trunc(C68kScript.s32(C68kScript.lsl32(rate, 2)), 3) + 0x4000)
		else:
			choice = -1
			rec = 0
		if rec != 0:
			if _sound_host(0x2b6, [0]) == 0 or C68kScript.u32(choice) != memory.read_u32(DAT_00024d14):
				var size: int = memory.read_u32(rec + 4)
				_sound_host(0x2aa, [0, C68kScript.u32(rec + 0x16), 0, size, 0, size])
			_sound_host(0x2b2, [C68kScript.u32(rate)])
		elif _sound_host(0x2b6, [0]) != 0:
			_sound_host(0x2be, [0])
		memory.write_u32(DAT_00024d14, C68kScript.u32(choice))
	else:
		if _sound_host(0x2b6, [0]) != 0:
			_sound_host(0x2be, [0])
		memory.write_u32(DAT_00024d14, 0xffffffff)

## update_game_sounds: play the sound when on, else stop it.
func _play_or_stop(on: bool, sound_id: int) -> void:
	if on:
		play_game_sound(sound_id)
	else:
		stop_game_sound(sound_id)

## 0x6598 (link.w a6,#-0x28, nine saved registers: the body runs 0x50 below the entry): one
## overlay frame. new_frame 1 swaps the slot usage maps (clearing the new previous one, 64 longs)
## and counts the colour tally slot; 20 retirements reset the distance bases; the altitude bands
## update and the fill colour follows the depth. The inverse camera matrix is built (view mode 2:
## six angles plus the angle-2 sin / cos from the vector (0, 0, 0x1000); otherwise from the folded
## fourth angle times the sin of the third) and the mission children are queued, flagged (+4 bit 2)
## and transformed (child 1 also re-banded at 2 * camera_y and shaded). With the forward matrix,
## camera metrics update for the near entities and the ground scatter, then the far objects are
## insertion-sorted by descending metric (+0x10); with carried pairs the riders' metrics are biased
## by the carrier's +0x14 for this sort only. The object lists are collected, overlaps dispatched,
## contacts aged, the visible list built and rendered; the frame is presented (depth 1 through the
## host or present_bw_frame, otherwise through the span filler or present_spans_to_window, then the
## span buffers swap). In view mode 1 with the panels not drawn they are laid out (step_mode 0 also
## re-creates the session buffers around host +0x26a) and drawn; the readouts and gauges follow.
## Host +0x2c2 runs around the drawing when host word +0x76 is set and +0x9e clear. Finally the
## span buffers are stored in slot new_frame.
func overlay_frame_step(step_mode: int, new_frame: int) -> void:
	assert(memory != null, "overlay_frame_step requires original global memory")
	assert(a7 != 0, "overlay_frame_step needs a7 (its frame holds the matrix, vector and span cursors)")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x50
	var a6: int = entry_a7 - 4
	var host: int = memory.read_u32(DAT_0001b5a0)
	var hooks: bool = memory.read_u16(host + 0x76) != 0 and memory.read_u16(host + 0x9e) == 0
	if C68kScript.u32(new_frame) == 1:
		var old_cur: int = memory.read_u32(DAT_0001d864)
		memory.write_u32(DAT_0001d864, memory.read_u32(DAT_0001d860))
		memory.write_u32(DAT_0001d860, old_cur)
		var clear: int = memory.read_u32(DAT_0001d864)
		for i in range(0x40):
			memory.write_u32(C68kScript.u32(clear + 4 * i), 0)
		var slot: int = C68kScript.u32(memory.read_u32(DAT_0001d864) + memory.read_s16(DAT_0001da8a))
		memory.write_u8(slot, (memory.read_u8(slot) + 1) & 0xff)
	a7 = body - 4
	if memory.read_s32(DAT_00024cf0) > 0x13:
		reset_distance_base_globals()
		memory.write_u32(DAT_00024cf0, 0)
	update_altitude_detail_bands()
	a7 = entry_a7
	var depth: int = memory.read_s16(DAT_0001b826)
	if depth == 8:
		memory.write_u16(DAT_0001daa0, memory.read_u16(memory.read_u32(DAT_0001d85c) + 0x1a0))
	elif depth == 4:
		memory.write_u16(DAT_0001daa0, memory.read_u16(memory.read_u32(DAT_0001d85c) + 0x10))
	if memory.read_s16(DAT_0001d858) == 2:
		var matrix: int = a6 - 0x1e
		var vec: int = a6 - 0xc
		a7 = body - 0x20
		build_attitude_matrix_6ang(-memory.read_s16(DAT_0001d810) & 0x3fff, 0, -memory.read_s16(DAT_0001d80c) & 0x3fff,
				-memory.read_s32(DAT_0001d808) & 0x3fff, -memory.read_s32(DAT_0001d804) & 0x3fff, -memory.read_s32(DAT_0001d800) & 0x3fff, matrix)
		memory.write_u16(vec + 6, 0)
		memory.write_u16(a6 - 0xa, 0)
		memory.write_u16(a6 - 2, 0x1000)
		a7 = body - 0x30
		transform_vecs12_by_matrix3(1, vec, vec, matrix)
		memory.write_u16(DAT_0001d7f8, memory.read_u16(a6 - 0xa))
		memory.write_u16(DAT_0001d7f6, memory.read_u16(a6 - 2))
		a7 = body - 8
		invoke_tagged_attitude_compose_neg_sins6(DAT_0001d744)
	else:
		a7 = body - 8
		var folded: int = C68kScript.s16(fold_angle_pm_0x2000(memory.read_u32(DAT_0001d808)))
		a7 = body - 0xc
		var sin: int = C68kScript.s16(sin_fixed14(memory.read_s16(DAT_0001d80c)))
		a7 = body - 0x20
		build_attitude_matrix_x_alt(memory.read_s16(DAT_0001d810), C68kScript.asr32(folded * sin, 12) & 0x3fff,
				memory.read_s16(DAT_0001d80c), memory.read_s32(DAT_0001d808), DAT_0001d744)
	a7 = entry_a7
	var child: int
	if memory.read_u16(host + 0xaa) != 0:
		var child1: int = memory.read_u32(DAT_0001bdb0)
		_queue_visible(child1)
		a7 = body - 0x14
		transform_vecs12_by_matrix3(memory.read_s16(child1 + 0x36), memory.read_u32(child1 + 0x44), memory.read_u32(child1 + 0x4c), DAT_0001d744)
		a7 = body - 0x1c
		var banded: int = update_object_distance_band(memory.read_u32(DAT_0001bdac), C68kScript.u32(C68kScript.lsl32(memory.read_u32(DAT_0001d834), 1)))
		if C68kScript.u32(banded) != 0:
			a7 = body - 8
			shade_object_faces(memory.read_u32(DAT_0001bdac))
		a7 = entry_a7
	else:
		_queue_visible(memory.read_u32(DAT_0001bdb4))
	child = memory.read_u32(DAT_0001bdac)
	_queue_visible(child)
	a7 = body - 0x14
	transform_vecs12_by_matrix3(memory.read_s16(child + 0x36), memory.read_u32(child + 0x44), memory.read_u32(child + 0x4c), DAT_0001d744)
	if memory.read_s16(DAT_0001d858) == 2:
		a7 = body - 0x20
		build_attitude_matrix_6ang_alt(memory.read_s16(DAT_0001d810), memory.read_s16(DAT_0001d80e), memory.read_s16(DAT_0001d80c),
				memory.read_s32(DAT_0001d808), memory.read_s32(DAT_0001d804), memory.read_s32(DAT_0001d800), DAT_0001d744)
	else:
		a7 = body - 0x18
		build_attitude_matrix_x_alt(memory.read_s16(DAT_0001d810), memory.read_s16(DAT_0001d80e), memory.read_s16(DAT_0001d80c),
				memory.read_s32(DAT_0001d808), DAT_0001d744)
	a7 = body - 8
	var n: int = memory.read_u32(DAT_0001c1e0)
	var cursor: int = DAT_0001d4a4
	while true:
		n = C68kScript.u32(n - 1)
		if n == 0xffffffff:
			break
		update_object_camera_metric(memory.read_u32(cursor))
		cursor += 4
	a7 = body - 4
	update_ground_scatter_objects()
	memory.write_u32(DAT_0001bdb8, memory.read_u32(DAT_0001c1d4))
	_sort_far_objects(body)
	a7 = body - 0xc
	collect_near_objects(DAT_0001d4a4, DAT_0001c1e0)
	memory.write_u32(DAT_0001c1c4, 0)
	memory.write_u16(DAT_0001c1c0, memory.read_u16(DAT_0001c1d6))
	a7 = body - 0x14
	collect_far_objects(DAT_0001b5a4, DAT_0001b734)
	a7 = body - 0x1c
	dispatch_overlap_collisions(DAT_0001c1e4, DAT_0001c1c4)
	age_contact_records()
	build_visible_object_list()
	a7 = entry_a7
	if memory.read_s16(DAT_0001b826) == 1:
		var bottom: int = memory.read_s16(DAT_00020ae8) if memory.read_u16(DAT_00020ae4) != 0 else memory.read_s16(DAT_0001b73e)
		_frame_host(body, 0x84, [C68kScript.u32(bottom - memory.read_s16(DAT_00020aea))])
	a7 = body - 4
	render_visible_objects()
	if memory.read_u16(DAT_0001daa2) != 0:
		noop_stub_2e12()
		memory.write_u16(DAT_0001daa2, 0)
	if memory.read_s16(DAT_0001b826) != 1:
		scan_convert_edge_rows()
	a7 = entry_a7
	memory.write_u32(DAT_0001c1d4, 0)
	memory.write_u16(DAT_0001c1bc, 0)
	memory.write_u16(DAT_0001d856, 0)
	host = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(memory.read_u32(host + 0x72) + 6) != 0:
		_frame_host(body, 0x266, [])
	if hooks:
		_frame_host(body, 0x2c2, [])
	if C68kScript.u32(new_frame) == 1:
		a7 = body - 4
		draw_distant_object_dots()
		a7 = entry_a7
	if memory.read_s16(DAT_0001b826) == 1:
		if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0x9e) != 0:
			a7 = body - 8
			present_bw_frame(C68kScript.u32(new_frame))
			a7 = entry_a7
		else:
			_frame_host(body, 0x80, [0])
		_frame_host(body, 0x78, [])
	else:
		host = memory.read_u32(DAT_0001b5a0)
		var width: int = memory.read_s16(host + 0x10)
		var ratio: int = C68kScript.s16(C68kScript.divs_trunc(8, memory.read_s16(DAT_0001b826)))
		var offset: int = C68kScript.s32(width - C68kScript.s16(C68kScript.divs_trunc(memory.read_s16(DAT_0001b82a), ratio)))
		if memory.read_u32(DAT_0001b834) != 0:
			offset = C68kScript.s32(offset + width)
		if memory.read_u16(host + 0x9e) != 0:
			a7 = body - 0x1c
			present_spans_to_window(memory.read_u32(DAT_0001b794), memory.read_u32(DAT_0001b798), C68kScript.u32(memory.read_s16(DAT_00020ae6)),
					memory.read_u32(host + 6), C68kScript.u32(offset), C68kScript.u32(new_frame))
		else:
			memory.write_u32(a6 - 0x22, memory.read_u32(DAT_0001b794))
			memory.write_u32(a6 - 0x26, memory.read_u32(DAT_0001b798))
			a7 = body - 0x18
			_jsr(memory.read_u32(DAT_00020ac0), [a6 - 0x22, a6 - 0x26, C68kScript.u32(memory.read_s16(DAT_00020ae6)), memory.read_u32(host + 6), C68kScript.u32(offset)])
		a7 = entry_a7
		var swap: int = memory.read_u32(DAT_0001b794)
		memory.write_u32(DAT_0001b794, memory.read_u32(DAT_0001b798))
		memory.write_u32(DAT_0001b798, swap)
	if memory.read_u16(DAT_00020ae4) == 0 and memory.read_s16(DAT_0001d858) == 1:
		_lay_out_view_panels(body, step_mode, new_frame, hooks)
	if C68kScript.u32(step_mode) == 0:
		if hooks:
			_frame_host(body, 0x2c2, [])
	elif memory.read_u16(DAT_00020ae4) == 0:
		if hooks:
			_frame_host(body, 0x2c2, [])
		a7 = body - 8
		update_view_readouts_and_overlays(0)
	else:
		if memory.read_s16(DAT_0001b826) == 1:
			if hooks:
				_frame_host(body, 0x2c2, [])
			a7 = body - 8
			update_view_readouts_and_overlays(0)
		else:
			a7 = body - 8
			update_view_readouts_and_overlays(1 if hooks else 0)
			a7 = entry_a7
			if hooks:
				_frame_host(body, 0x2c2, [])
		a7 = body - 4
		update_throttle_gauge()
		update_radar_range_buttons()
		update_bomb_indicator()
		mark_view_overlays_drawn()
	a7 = entry_a7
	memory.write_u32(C68kScript.u32(DAT_0001b784 + new_frame * 4), memory.read_u32(DAT_0001b794))
	memory.write_u32(C68kScript.u32(DAT_0001b774 + new_frame * 4), memory.read_u32(DAT_0001b798))

## overlay_frame_step: queue obj at visible_list[visible_count++] and set its long +4 bit 2.
func _queue_visible(obj: int) -> void:
	var count: int = memory.read_u32(DAT_0001c1d4)
	memory.write_u32(C68kScript.u32(DAT_0001c9dc + count * 4), obj)
	memory.write_u32(DAT_0001c1d4, C68kScript.u32(count + 1))
	memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 4)

## overlay_frame_step: a host routine (host_world + offset), entered 4 + 4 * args below the body.
func _frame_host(body: int, offset: int, args: Array) -> void:
	var saved: int = a7
	a7 = body - 4 - 4 * args.size()
	_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + offset), args)
	a7 = saved

## overlay_frame_step part 4: the far objects (DAT_0001b5a4, long count DAT_0001b734) are
## insertion-sorted by descending +0x10 (stable). Without carried pairs each key is the fresh
## update_object_camera_metric; with them all metrics update first, each rider's +0x10 is saved
## in +0x28 and biased by its carrier's +0x14 (toward the camera height side), the sort runs on
## the biased keys and the saved metrics come back; carried_pair_count = 0.
func _sort_far_objects(body: int) -> void:
	var entry: int = a7
	var count: int = memory.read_s32(DAT_0001b734)
	var pairs: int = memory.read_s16(DAT_0001b85c)
	a7 = body - 8
	if pairs != 0:
		for i in range(maxi(count, 0)):
			update_object_camera_metric(memory.read_u32(DAT_0001b5a4 + 4 * i))
		var pair: int = memory.read_u32(DAT_0001b860)
		for k in range(pairs):
			var carrier: int = memory.read_u32(pair + 8 * k)
			var rider: int = memory.read_u32(pair + 8 * k + 4)
			memory.write_u32(rider + 0x28, memory.read_u32(rider + 0x10))
			var level: int = memory.read_s16(memory.read_u32(carrier + 8) + 0x54)
			var add: bool
			if level < memory.read_s32(DAT_0001d834):
				add = level > memory.read_s32(rider + 0x1c)
				if not add:
					memory.write_u32(rider + 0x10, C68kScript.u32(memory.read_u32(rider + 0x10) - memory.read_u32(carrier + 0x14)))
			else:
				add = level <= memory.read_s32(rider + 0x1c)
			if add:
				memory.write_u32(rider + 0x10, C68kScript.u32(memory.read_u32(rider + 0x10) + memory.read_u32(carrier + 0x14)))
	for i in range(maxi(count, 0)):
		var obj: int = memory.read_u32(DAT_0001b5a4 + 4 * i)
		var key: int
		if pairs != 0:
			key = memory.read_s32(obj + 0x10)
		else:
			key = C68kScript.s32(update_object_camera_metric(obj))
		var j: int = i - 1
		while j >= 0:
			var other: int = memory.read_u32(DAT_0001b5a4 + 4 * j)
			if key <= memory.read_s32(other + 0x10):
				break
			memory.write_u32(DAT_0001b5a4 + 4 * (j + 1), other)
			j -= 1
		memory.write_u32(DAT_0001b5a4 + 4 * (j + 1), obj)
	if pairs != 0:
		var pair2: int = memory.read_u32(DAT_0001b860)
		for k in range(pairs):
			var rider2: int = memory.read_u32(pair2 + 8 * k + 4)
			memory.write_u32(rider2 + 0x10, memory.read_u32(rider2 + 0x28))
		memory.write_u16(DAT_0001b85c, 0)
	a7 = entry

## overlay_frame_step part 6: view mode 1 with the panels not drawn. The overlay display resets,
## the clip rows follow proj_scale_y (0x78 / 0x1e0 and 0x43 / 0x1e0), the last scan row is the clip
## bottom + view_rows / 2; step_mode 0 re-creates the session buffers around host +0x26a (which may
## clear panels_drawn to keep the panels pending); new_frame 1 reloads the four host pointers
## (& 0xffffff with host word +0x76); the sky / ground, heading tape, host +0x26e and the radar
## range buttons draw; panels_drawn = 1 unless host +0x26a kept them pending.
func _lay_out_view_panels(body: int, step_mode: int, new_frame: int, hooks: bool) -> void:
	var entry: int = a7
	a7 = body - 4
	reset_overlay_display_state()
	a7 = entry
	var scale: int = memory.read_s16(DAT_00020b26)
	memory.write_u16(DAT_0001b73e, C68kScript.u16(C68kScript.divs_trunc(scale * 0x78, 0x1e0)))
	memory.write_u16(DAT_00020ae8, C68kScript.u16(C68kScript.divs_trunc(scale * 0x43, 0x1e0)))
	var rows: int = memory.read_s16(DAT_0001b828)
	if rows < 0:
		rows += 1
	memory.write_u16(DAT_00020ae6, C68kScript.u16((rows >> 1) + memory.read_u16(DAT_0001b73e)))
	var keep_pending: bool = false
	if C68kScript.u32(step_mode) == 0:
		if hooks:
			_frame_host(body, 0x2c2, [])
		a7 = body - 4
		unlock_session_buffers()
		memory.write_u16(DAT_00020ae4, 1)
		_frame_host(body, 0x26a, [])
		keep_pending = memory.read_u16(DAT_00020ae4) == 0
		memory.write_u16(DAT_00020ae4, 0)
		a7 = body - 4
		allocate_session_buffers()
		lock_session_buffers()
		lock_overlay_buffers()
		a7 = entry
		if hooks:
			_frame_host(body, 0x2c2, [])
	if C68kScript.u32(new_frame) == 1:
		var host: int = memory.read_u32(DAT_0001b5a0)
		var mask: int = 0xffffff if memory.read_u16(host + 0x76) != 0 else 0xffffffff
		for pair in [[0x192, 0x196], [0x1ac, 0x1b0], [0x1b4, 0x1b8], [0xd8, 0xdc]]:
			memory.write_u32(host + pair[1], memory.read_u32(memory.read_u32(host + pair[0])) & mask)
	a7 = body - 8
	draw_sky_and_ground(1 if hooks else 0)
	a7 = body - 0xc
	update_heading_tape(1 if hooks else 0)
	a7 = entry
	if hooks:
		_frame_host(body, 0x2c2, [])
	_frame_host(body, 0x26e, [])
	a7 = body - 4
	update_radar_range_buttons()
	a7 = entry
	if hooks:
		_frame_host(body, 0x2c2, [])
	if not keep_pending:
		memory.write_u16(DAT_00020ae4, 1)

## 0x740a (link.w a6,#-0x24, nine saved registers: the body runs 0x4c below the entry): one frame
## of player input and its outcome; key is the key character and event_kind 3 key down / 4 key up
## / 0 between frames. Replay control first (replay words 0x1b870 / 0x1b86e; view 8 ends into
## view 9 with a parachute, else view 1 with the player object hidden), then the host crash-end
## request (+0x98 == 2: channel 0 silenced, view 8, a 0x1e-frame replay from a camera offset
## (-0x2ee, 0x183, -0x513) turned by the heading) and the instant replay requests. View 7 without
## a target or on the ground returns to view 1; views 8 / 9 only take '"' / '`' / ESC (result 3).
## Key events pass a filter (key down: all; key up: space; other: the keys whose release matters)
## and dispatch through the 0x76-entry table at 0x7688 (_process_flight_key). Every frame the
## throttle ramp, the keyboard-steered mouse point and the gun trigger follow; then
## apply_player_mouse_controls, the controller tick (tick_flagged_object_controllers in replay 3),
## update_game_sounds; a stopped aircraft on the ground is classified (_classify_stopped_aircraft);
## otherwise the camera follows the view (_update_view_camera). The tail mirrors a pitch past the
## vertical, clears brakes / target lock / throttle ramp on a result, flags a view change, and
## returns the result (d6).
func process_flight_input_and_outcome(key: int, event_kind: int) -> int:
	assert(memory != null, "process_flight_input_and_outcome requires original global memory")
	assert(a7 != 0, "process_flight_input_and_outcome needs a7 (its frame holds the matrix and vectors)")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x4c
	var a6: int = entry_a7 - 4
	key = C68kScript.u32(key)
	event_kind = C68kScript.u32(event_kind)
	var result: int = 0
	var old_view: int = memory.read_u16(DAT_0001d858)
	var check_view8: bool = true
	if memory.read_u16(DAT_0001b870) != 0:
		if memory.read_u16(DAT_0001b86e) != 0:
			check_view8 = false
			if memory.read_s16(DAT_0001b870) == 1:
				memory.write_u16(DAT_0001b870, 2)
		else:
			memory.write_u16(DAT_0001b870, 0)
	if check_view8 and memory.read_s16(DAT_0001d858) == 8:
		if memory.read_u32(DAT_0001b87c) != 0:
			memory.write_u16(DAT_0001d858, 9)
		else:
			memory.write_u16(DAT_0001d858, 1)
			_hide_player_object(body)
		a7 = body - 4
		update_view_clip_bounds()
		a7 = entry_a7
		memory.write_u32(DAT_0001b884, 0)
	var host: int = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(host + 0x98) != 0:
		if memory.read_s16(host + 0x98) == 2 and memory.read_u16(DAT_0001b870) == 0:
			if memory.read_u32(host + 0x25e) != 0:
				a7 = body - 8
				var playing: int = C68kScript.u32(_jsr(memory.read_u32(host + 0x2b6), [0]))
				if playing != 0:
					_jsr(memory.read_u32(memory.read_u32(DAT_0001b5a0) + 0x2be), [0])
				a7 = entry_a7
			a7 = body - 4
			update_view_clip_bounds()
			a7 = entry_a7
			memory.write_u16(DAT_0001d858, 8)
			memory.write_u16(DAT_0001b870, 3)
			memory.write_u16(DAT_0001b86e, 0x1e)
			var vec: int = a6 - 0xc
			var matrix: int = a6 - 0x1e
			memory.write_u16(a6 - 6, 0x183)
			memory.write_u16(a6 - 0xa, 0xfd12)
			memory.write_u16(a6 - 2, 0xfaed)
			a7 = body - 0x14
			build_attitude_matrix_3ang(0, memory.read_s16(memory.read_u32(DAT_0001b738) + 0x22), 0, matrix)
			a7 = body - 0x24
			transform_vecs12_by_matrix3(1, vec, vec, matrix)
			a7 = entry_a7
			var obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
			memory.write_u32(DAT_0001d838, C68kScript.u32(memory.read_s16(a6 - 0xa) + memory.read_u32(obj + 0x18)))
			memory.write_u32(DAT_0001d834, C68kScript.u32(memory.read_s16(a6 - 6) + memory.read_u32(obj + 0x1c)))
			memory.write_u32(DAT_0001d830, C68kScript.u32(memory.read_s16(a6 - 2) + memory.read_u32(obj + 0x20)))
		if memory.read_u16(DAT_0001b86c) == 0 and memory.read_u16(DAT_0001b86e) == 0:
			a7 = body - 8
			request_instant_replay(0 if memory.read_u8(memory.read_u32(DAT_0001b738) + 0x63e) != 0 else 1)
			a7 = entry_a7
	if memory.read_u16(DAT_0001b86c) != 0 and memory.read_u16(DAT_0001b86e) == 0:
		a7 = body - 4
		begin_replay_view()
		a7 = entry_a7
	var stage: int = 0   # 0 key filter, 1 frame update (0x7dbe), 2 per-frame calls (0x8000), 3 tail (0x8704)
	var view: int = memory.read_s16(DAT_0001d858)
	if view == 7 and (memory.read_u32(DAT_0001b888) == 0 or memory.read_u8(memory.read_u32(DAT_0001b738) + 0x63e) != 0):
		_view_key_reset(body)
		stage = 1
	elif view == 8 or view == 9:
		if event_kind == 3 and (key == 0x22 or key == 0x60 or key == 0x1b):
			result = 3
			stage = 3
		else:
			stage = 2
	if stage == 0:
		var passes: bool = event_kind == 3 or (event_kind == 4 and key == 0x20) or key in [0x61, 0x41, 0x2b, 0x2d, 0x3d, 0x5f,
				0x32, 0x34, 0x36, 0x38, 0x5a, 0x7a, 0x3e, 0x2e, 0x58, 0x78, 0x3f, 0x2f]
		if passes and C68kScript.u32(key - 9) <= 0x75:
			result = _process_flight_key(body, key, event_kind)
			stage = 3 if result != 0 else 1
		else:
			stage = 1
	if stage == 1:
		_update_keyboard_flight(body)
		stage = 2
	if stage == 2:
		a7 = body - 4
		apply_player_mouse_controls()
		if memory.read_s16(DAT_0001b870) == 3:
			tick_flagged_object_controllers()
		else:
			advance_frame_and_tick_controllers()
		update_game_sounds()
		a7 = entry_a7
		var ctl: int = memory.read_u32(DAT_0001b738)
		var classified: bool = false
		if memory.read_s16(DAT_0001d858) <= 7 and memory.read_u32(ctl + 0x62a) == 0 and memory.read_u8(ctl + 0x63e) != 0:
			var outcome: Array = _classify_stopped_aircraft(body)
			result = outcome[0]
			classified = outcome[1]
		if not classified:
			result = _update_view_camera(body, a6)
	if memory.read_s16(DAT_0001d810) > 0x1000 and memory.read_s16(DAT_0001d810) <= 0x2fff:
		var mirror: int = 0x2000 if memory.read_s16(DAT_0001d810) <= 0x2000 else 0x6000
		memory.write_u16(DAT_0001d810, C68kScript.u16(mirror - memory.read_u16(DAT_0001d810)))
		memory.write_u16(DAT_0001d80e, (memory.read_u16(DAT_0001d80e) + 0x2000) & 0x3fff)
	if result != 0:
		memory.write_u8(memory.read_u32(DAT_0001b738) + 0x641, 0)
		memory.write_u16(DAT_0001b872, 0)
		memory.write_u16(DAT_00024cf6, 0)
	if memory.read_u16(DAT_0001d858) != old_view:
		memory.write_u16(DAT_0001d856, 1)
	return C68kScript.u32(result)

## process_flight_input_and_outcome: hide the player object (long +4 |= 0x40, contact records
## dropped, 8 below) unless already hidden (+7 bit 6).
func _hide_player_object(body: int) -> void:
	var saved: int = a7
	var ctl: int = memory.read_u32(DAT_0001b738)
	var obj: int = memory.read_u32(ctl)
	if (memory.read_u8(obj + 7) & 0x40) == 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) | 0x40)
		a7 = body - 8
		drop_contact_records_for_object(memory.read_u32(ctl))
	a7 = saved

## process_flight_input_and_outcome 0x7b8e: show the player object again (when hidden: long +4
## &= ~0x40 and contact records dropped), then update_view_clip_bounds.
func _show_player_object(body: int) -> void:
	var saved: int = a7
	var ctl: int = memory.read_u32(DAT_0001b738)
	var obj: int = memory.read_u32(ctl)
	if (memory.read_u8(obj + 7) & 0x40) != 0:
		memory.write_u32(obj + 4, memory.read_u32(obj + 4) & 0xffffffbf)
		a7 = body - 8
		drop_contact_records_for_object(memory.read_u32(ctl))
	a7 = body - 4
	update_view_clip_bounds()
	a7 = saved

## process_flight_input_and_outcome 0x79fc ('V'): view 1, look offsets and targets cleared, the
## camera on the player object, the object hidden, update_view_clip_bounds.
func _view_key_reset(body: int) -> void:
	var saved: int = a7
	memory.write_u16(DAT_0001d858, 1)
	for addr in [DAT_00024cf8, DAT_0001d804, DAT_00024cfc, DAT_0001d800]:
		memory.write_u32(addr, 0)
	var obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	memory.write_u32(DAT_0001d838, memory.read_u32(obj + 0x18))
	memory.write_u32(DAT_0001d834, memory.read_u32(obj + 0x1c))
	memory.write_u32(DAT_0001d830, memory.read_u32(obj + 0x20))
	_hide_player_object(body)
	a7 = body - 4
	update_view_clip_bounds()
	a7 = saved

## process_flight_input_and_outcome: the key cases of the jump table at 0x7688 (key - 9). Returns
## the result for ESC / '`' / '~' (3) and 'P' (4), else 0.
func _process_flight_key(body: int, key: int, event_kind: int) -> int:
	var saved: int = a7
	var down: bool = event_kind == 3
	var view: int = memory.read_s16(DAT_0001d858)
	var ctl: int = memory.read_u32(DAT_0001b738)
	var bailed: bool = memory.read_u16(DAT_0001b874) != 0
	var slew: bool = memory.read_u32(ctl + 0x32) == 0xf7f0
	match key:
		9:
			a7 = body - 4
			cycle_view_distance()
		0x13:
			memory.write_u8(ctl + 0x668, 0)
			memory.write_u8(ctl + 0x678, 0)
			memory.write_u32(ctl + 0x62a, 0)
			memory.write_u32(ctl + 0x32, 0xf7f0 if memory.read_u32(ctl + 0x32) == 0xe772 else 0xe772)
		0x18:
			var target: int = memory.read_u32(DAT_0001b888)
			if target != 0:
				memory.write_u16(target + 0x684, memory.read_u16(target + 0x684) | 0x100)
		0x1b, 0x60, 0x7e:
			return 3
		0x1c, 0x1d:
			if view <= 2:
				var step: int = -0x800 if key == 0x1c else 0x800
				memory.write_u32(DAT_00024cfc, C68kScript.u32(memory.read_u32(DAT_00024cfc) + step) & 0x3fff)
		0x1e, 0x1f:
			var limit: int = 0x3040 if key == 0x1e else 0xa80
			if view <= 2 and memory.read_u32(DAT_00024cf8) != limit:
				var step2: int = -0x540 if key == 0x1e else 0x540
				memory.write_u32(DAT_00024cf8, C68kScript.u32(memory.read_u32(DAT_00024cf8) + step2) & 0x3fff)
		0x20:
			if not bailed:
				if memory.read_u8(ctl + 0x63e) != 0:
					memory.write_u8(ctl + 0x641, 1 if down else 0)
				elif memory.read_u16(DAT_00024d34) != 0:
					memory.write_u16(DAT_00024cf4, 1 if down else 0)
		0x2b, 0x3d:
			if view == 6 and memory.read_s16(DAT_00020af4) <= 7:
				if down:
					var i: int = memory.read_s16(DAT_00020af4)
					memory.write_u16(DAT_00020b14 + 2 * i, memory.read_u16(DAT_00020b28))
					memory.write_u16(DAT_00020afc + 2 * i, memory.read_u16(DAT_00020b26))
					var sx: int = C68kScript.u16((memory.read_s16(DAT_00020b28) >> 1) + memory.read_u16(DAT_00020b28))
					memory.write_u16(DAT_00020b28, sx)
					var sy: int = C68kScript.u16((memory.read_s16(DAT_00020b26) >> 1) + memory.read_u16(DAT_00020b26))
					memory.write_u16(DAT_00020b26, sy)
					memory.write_u16(DAT_00020af4, C68kScript.u16(memory.read_u16(DAT_00020af4) + 1))
					i = memory.read_s16(DAT_00020af4)
					memory.write_u16(C68kScript.u32(DAT_00020b14 + 2 * i), sx)
					memory.write_u16(C68kScript.u32(DAT_00020afc + 2 * i), sy)
			elif view <= 5 and not bailed:
				memory.write_u16(DAT_00024cf6, 1 if down else 0)
		0x2d, 0x5f:
			if view == 6 and memory.read_u16(DAT_00020af4) != 0:
				if down:
					memory.write_u16(DAT_00020af4, C68kScript.u16(memory.read_u16(DAT_00020af4) - 1))
					var j: int = memory.read_s16(DAT_00020af4)
					memory.write_u16(DAT_00020b28, memory.read_u16(C68kScript.u32(DAT_00020b14 + 2 * j)))
					memory.write_u16(DAT_00020b26, memory.read_u16(C68kScript.u32(DAT_00020afc + 2 * j)))
			elif view <= 5 and not bailed:
				memory.write_u16(DAT_00024cf6, 0xffff if down else 0)
		0x2e, 0x3e, 0x5a, 0x7a:
			memory.write_u16(DAT_0001b858, 0x40 if down and (key == 0x5a or key == 0x3e) else 0)
		0x2f, 0x3f, 0x58, 0x78:
			memory.write_u16(DAT_0001b858, 0xffc0 if down and (key == 0x58 or key == 0x3f) else 0)
		0x30, 0x31, 0x33, 0x37, 0x39:
			if slew:
				_slew_throttle_key(key)
		0x32, 0x34, 0x36, 0x38:
			if slew:
				_slew_throttle_key(key)
			else:
				if key == 0x32 or key == 0x38:
					memory.write_u16(DAT_00024d2c, (1 if key == 0x32 else 0xffff) if down else 0)
				else:
					memory.write_u16(DAT_00024d2e, (1 if key == 0x36 else 0xffff) if down else 0)
				memory.write_u16(DAT_00024d34, 1)
		0x35:
			if slew:
				_slew_throttle_key(key)
			else:
				var host: int = memory.read_u32(DAT_0001b5a0)
				memory.write_u16(host + 0x33e, memory.read_u16(DAT_00020b2a))
				memory.write_u16(DAT_00024d32, memory.read_u16(DAT_00020b2a))
				memory.write_u16(host + 0x340, memory.read_u16(DAT_00020b2c))
				memory.write_u16(DAT_00024d30, memory.read_u16(DAT_00020b2c))
				memory.write_u16(DAT_00024d2c, 0)
				memory.write_u16(DAT_00024d2e, 0)
				memory.write_u16(DAT_00024d34, 1)
		0x41, 0x61:
			memory.write_u16(DAT_0001b872, 1 if memory.read_u32(DAT_0001b888) != 0 and down else 0)
		0x42, 0x62:
			if not bailed and C68kScript.s32(memory.read_u32(memory.read_u32(ctl) + 0x1c) - memory.read_u32(ctl + 0x2e)) > 0x43:
				memory.write_u8(ctl + 0x674, 1)
		0x43, 0x63:
			if view == 5:
				_view_key_reset(body)
			else:
				memory.write_u16(DAT_0001d858, 5)
				_show_player_object(body)
		0x45, 0x65:
			if memory.read_u32(DAT_0001b888) != 0 and view != 7 and memory.read_u8(ctl + 0x63e) == 0:
				memory.write_u16(DAT_0001d858, 7)
				_show_player_object(body)
			else:
				_view_key_reset(body)
		0x56, 0x76:
			_view_key_reset(body)
		0x46, 0x66:
			if not bailed:
				var flaps: int = memory.read_u8(ctl + 0x67b)
				memory.write_u8(ctl + 0x67b, (-flaps) & 0xff if flaps != 0 else 1)
		0x47, 0x67:
			if not bailed and memory.read_u8(ctl + 0x63e) == 0:
				var gear: int = memory.read_u8(ctl + 0x679)
				memory.write_u8(ctl + 0x679, (-gear) & 0xff if gear != 0 else 1)
				ctl = memory.read_u32(DAT_0001b738)
				if memory.read_s8(ctl + 0x679) > 0 and memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xa4) != 0:
					a7 = body - 8
					if C68kScript.u32(try_begin_landing_approach(ctl)) != 0:
						memory.write_u16(DAT_0001b83c, 1)
					else:
						memory.write_u16(DAT_0001b83e, 1)
				else:
					memory.write_u32(ctl + 0x32, 0xe772)
		0x4a, 0x6a:
			if not bailed and memory.read_u8(ctl + 0x63e) == 0 and memory.read_u8(ctl + 0x677) == 0:
				memory.write_u8(ctl + 0x677, 1)
		0x4d, 0x6d:
			memory.write_u8(ctl + 0x668, 0)
			memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) | 0x4000)
		0x50, 0x70:
			return 4
		0x52, 0x72:
			if view <= 2:
				memory.write_u32(DAT_00024cfc, C68kScript.u32(memory.read_u32(DAT_00024cfc) + 0x2000) & 0x3fff)
			else:
				memory.write_u32(DAT_00024cfc, 0x2000)
				memory.write_u32(DAT_0001d800, 0x2000)
				memory.write_u16(DAT_0001d858, 1)
		0x54, 0x74:
			if view == 6:
				_view_key_reset(body)
			else:
				a7 = body - 8
				var found: int = C68kScript.u32(point_near_camera_or_type80_object(DAT_0001d824))
				a7 = saved
				if found != 0:
					memory.write_u16(DAT_0001d858, 6)
					memory.write_u32(DAT_0001d838, memory.read_u32(DAT_0001d824))
					memory.write_u32(DAT_0001d834, memory.read_u32(DAT_0001d824 + 4))
					memory.write_u32(DAT_0001d830, memory.read_u32(DAT_0001d824 + 8))
					_show_player_object(body)
	a7 = saved
	return 0

## process_flight_input_and_outcome 0x7992: in slew mode a digit sets the throttle byte +0x668 =
## key - '0' and switches the engine on (+0x684 &= 0xbfff); keyboard steering goes off.
func _slew_throttle_key(key: int) -> void:
	var ctl: int = memory.read_u32(DAT_0001b738)
	memory.write_u16(DAT_00024d34, 0)
	memory.write_u8(ctl + 0x668, (key + 0xd0) & 0xff)
	memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xbfff)

## process_flight_input_and_outcome 0x7dbe: the throttle ramp (|step| 1: throttle +-1 clamped
## 0..9, or 0 with the engine back on when it was off; then step <<= 1; else one step toward
## 0), the keyboard-steered mouse point (a real mouse move turns keyboard steering off; off: fire
## = host mouse button +0x342; on: clamp to centre +-0xd5 / +-0xab, then move by +-0x1e / +-0x18
## while a key is held, else back toward the centre) and the gun trigger.
func _update_keyboard_flight(body: int) -> void:
	var saved: int = a7
	if memory.read_u16(DAT_00024cf6) != 0:
		a7 = body - 8
		var mag: int = abs_int(memory.read_s16(DAT_00024cf6))
		var ctl: int = memory.read_u32(DAT_0001b738)
		if mag == 1:
			if (memory.read_u8(ctl + 0x684) & 0x40) != 0:
				memory.write_u8(ctl + 0x668, 0)
				memory.write_u16(ctl + 0x684, memory.read_u16(ctl + 0x684) & 0xbfff)
			else:
				memory.write_u8(ctl + 0x668, (memory.read_u8(ctl + 0x668) + memory.read_u8(DAT_00024cf6 + 1)) & 0xff)
				if memory.read_s8(ctl + 0x668) > 9:
					memory.write_u8(ctl + 0x668, 9)
				if memory.read_s8(ctl + 0x668) < 0:
					memory.write_u8(ctl + 0x668, 0)
			memory.write_u16(DAT_00024cf6, C68kScript.u16(memory.read_s16(DAT_00024cf6) << 1))
		elif memory.read_s16(DAT_00024cf6) > 0:
			memory.write_u16(DAT_00024cf6, C68kScript.u16(memory.read_u16(DAT_00024cf6) - 1))
		else:
			memory.write_u16(DAT_00024cf6, C68kScript.u16(memory.read_u16(DAT_00024cf6) + 1))
	var host: int = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(DAT_00024d32) != memory.read_u16(host + 0x33e) or memory.read_u16(DAT_00024d30) != memory.read_u16(host + 0x340):
		memory.write_u16(DAT_00024d34, 0)
	if memory.read_u16(DAT_00024d34) != 0:
		var dh: int = C68kScript.s16(memory.read_u16(DAT_00020b2a) - memory.read_u16(host + 0x33e))
		var dv: int = C68kScript.s16(memory.read_u16(host + 0x340) - memory.read_u16(DAT_00020b2c))
		var step_h: int
		var dir_h: int = memory.read_s16(DAT_00024d2e)
		a7 = body - 8
		if dir_h > 0:
			step_h = 0x1e
		elif dir_h < 0:
			step_h = -0x1e
		elif abs_int(dh) <= 0x1e:
			step_h = dh
		else:
			step_h = 0x1e if dh > 0 else -0x1e
		if abs_int(dh) > 0xd5:
			memory.write_u16(host + 0x33e, C68kScript.u16(memory.read_u16(DAT_00020b2a) + (-0xd5 if dh > 0 else 0xd5)))
		var h: int = C68kScript.u16(step_h + memory.read_u16(host + 0x33e))
		memory.write_u16(host + 0x33e, h)
		memory.write_u16(DAT_00024d32, h)
		var step_v: int
		var dir_v: int = memory.read_s16(DAT_00024d2c)
		if dir_v > 0:
			step_v = 0x18
		elif dir_v < 0:
			step_v = -0x18
		elif abs_int(dv) <= 0x18:
			step_v = -dv
		else:
			step_v = -0x18 if dv > 0 else 0x18
		if abs_int(dv) > 0xab:
			memory.write_u16(host + 0x340, C68kScript.u16(memory.read_u16(DAT_00020b2c) + (0xab if dv > 0 else -0xab)))
		var v: int = C68kScript.u16(step_v + memory.read_u16(host + 0x340))
		memory.write_u16(host + 0x340, v)
		memory.write_u16(DAT_00024d30, v)
	else:
		memory.write_u16(DAT_00024cf4, memory.read_u16(host + 0x342))
	var ctl2: int = memory.read_u32(DAT_0001b738)
	if memory.read_u16(DAT_00024cf4) != 0 and memory.read_s16(ctl2 + 0x682) > 1 and (memory.read_u8(ctl2 + 0x685) & 0x10) == 0 \
			and memory.read_u16(DAT_0001b874) == 0:
		if memory.read_u8(ctl2 + 0x676) == 0:
			memory.write_u8(ctl2 + 0x676, 1)
		memory.write_u16(DAT_0001b852, 1)
	a7 = saved

## process_flight_input_and_outcome 0x803e: a stopped aircraft on the ground. kind =
## probe_nearest_facility_kind(object) (0x100 / 0x200 near a facility of either side). Host
## +0xd4 == 1 -> kind | 1. Ditched (+0x684 bit 12): intact and fuelled -> host +0xd4 = 4, else
## a random status (1 / 3) - kind | 6. RPM +0x66a == 0 after a touchdown (0x1b868 == 2): the
## friendly-landing score (kind 0x200 on a runway / deck surface byte +0x2c 0x30 / 0x60 / 0x70,
## host +0xce > 0, once: kind | 1), runway with kind 0x100 (status 3, kind | 0xa), runway (kind |
## 9), off the runway damaged / empty (status 5 / 3 odds, kind | 8), intact (kind 0x100: 1/4
## status 3; else any_mission_kills_recorded) - kind | 9. Not yet stopped, on a runway, engine
## off, not yet recorded: fuel percent and bombs to the host, kind | 2. Returns [result,
## classified] (classified false -> the camera switch runs with result 0).
func _classify_stopped_aircraft(body: int) -> Array:
	var saved: int = a7
	var ctl: int = memory.read_u32(DAT_0001b738)
	a7 = body - 8
	var kind: int = C68kScript.u32(probe_nearest_facility_kind(memory.read_u32(ctl)))
	a7 = saved
	var host: int = memory.read_u32(DAT_0001b5a0)
	if memory.read_s16(host + 0xd4) == 1:
		return [kind | 1, true]
	ctl = memory.read_u32(DAT_0001b738)
	if (memory.read_u8(ctl + 0x684) & 0x10) != 0:
		if (memory.read_u16(ctl + 0x684) & 0x3fe) == 0 and (memory.read_u8(ctl + 0x67d) != 0 or memory.read_u8(ctl + 0x67e) != 0):
			memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xd4, 4)
		else:
			_random_status(body, kind, 1)
		return [kind | 6, true]
	if memory.read_u32(ctl + 0x66a) != 0:
		return [0, false]
	var runway: bool = memory.read_u8(ctl + 0x2c) in [0x30, 0x60, 0x70]
	if memory.read_s16(DAT_0001b868) == 2:
		memory.write_u16(DAT_0001b868, 0)
		memory.write_u16(DAT_0001b73c, 0)
		host = memory.read_u32(DAT_0001b5a0)
		if memory.read_s16(host + 0xce) > 0 and kind == 0x200 and runway and memory.read_u16(DAT_0001b86a) == 0:
			memory.write_u16(DAT_0001b86a, 1)
			return [kind | 1, true]
		if runway and kind == 0x100:
			memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xd4, 3)
			return [kind | 0xa, true]
		if runway:
			return [kind | 9, true]
		if (memory.read_u16(ctl + 0x684) & 0x3fe) != 0 or (memory.read_u8(ctl + 0x67d) == 0 and memory.read_u8(ctl + 0x67e) == 0):
			_random_status(body, kind, 5)
			return [kind | 8, true]
		if kind == 0x100:
			a7 = body - 4
			var r: int = overlay_rng_next()
			a7 = saved
			if (r & 3) == 0:
				memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xd4, 3)
			return [kind | 9, true]
		a7 = body - 4
		var kills: int = C68kScript.u32(any_mission_kills_recorded())
		a7 = saved
		if kills == 0:
			return [0, false]
		return [kind | 9, true]
	if runway and memory.read_u16(DAT_0001b73c) == 0 and (memory.read_u8(ctl + 0x684) & 0x40) != 0:
		var fuel: int = C68kScript.s32((memory.read_s8(ctl + 0x67d) + memory.read_s8(ctl + 0x67e)) * 100)
		var capacity: int = memory.read_s16(memory.read_u32(ctl + 4) + 0x1c)
		memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xb6, C68kScript.u16(C68kScript.divs_trunc(fuel, capacity)))
		memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xb8, C68kScript.u16(memory.read_s8(ctl + 0x67c)))
		memory.write_u16(DAT_0001b73c, 1)
		return [kind | 2, true]
	return [0, false]

## _classify_stopped_aircraft: host +0xd4 status odds. kind 0x100: rng bit 0 clear -> 3, else
## rng & 3 == 0 -> `first`; kind 0x200: rng & 7 == 0 -> `first`; neither: rng & 3 == 0 ->
## `first`, else rng & 3 == 0 -> 3.
func _random_status(body: int, kind: int, first: int) -> void:
	var saved: int = a7
	a7 = body - 4
	var status: int = 0
	if (kind & 0x100) != 0:
		if (overlay_rng_next() & 1) == 0:
			status = 3
		elif (overlay_rng_next() & 3) == 0:
			status = first
	elif (kind & 0x200) != 0:
		if (overlay_rng_next() & 7) == 0:
			status = first
	elif (overlay_rng_next() & 3) == 0:
		status = first
	elif (overlay_rng_next() & 3) == 0:
		status = 3
	a7 = saved
	if status != 0:
		memory.write_u16(memory.read_u32(DAT_0001b5a0) + 0xd4, status)

## process_flight_input_and_outcome 0x8324: the camera for the view (table at 0x833e). Views 1 /
## 2: cockpit (copy_player_pose_to_camera), switching to view 2 when a look target is set and
## easing toward it (by a quarter of the folded difference with host +0xa0, else at once), back
## to view 1 when both targets are 0 and both offsets within 0x20. View 5: the pose ring entry 7
## frames back. View 6: the external camera eases (or snaps beyond 0x1000) toward the attitude
## of the player as seen from it. View 7: the designated aircraft's pose. Views 8 / 9:
## update_tracking_camera / update_bailout_view, a non-zero value is the result.
func _update_view_camera(body: int, a6: int) -> int:
	var saved: int = a7
	var result: int = 0
	var view: int = memory.read_s16(DAT_0001d858)
	match view:
		1, 2:
			a7 = body - 4
			copy_player_pose_to_camera()
			a7 = saved
			if memory.read_s16(DAT_0001d858) == 1 and (memory.read_u32(DAT_00024cf8) != 0 or memory.read_u32(DAT_00024cfc) != 0):
				memory.write_u16(DAT_0001d858, 2)
				_hide_player_object(body)
				a7 = body - 4
				update_view_clip_bounds()
				a7 = saved
			if memory.read_s16(DAT_0001d858) == 2:
				if memory.read_u16(memory.read_u32(DAT_0001b5a0) + 0xa0) != 0:
					a7 = body - 8
					var d: int = C68kScript.s16(fold_angle_pm_0x2000(C68kScript.u32(memory.read_u32(DAT_00024cf8) - memory.read_u32(DAT_0001d804))))
					if d < 0:
						d += 3
					memory.write_u32(DAT_0001d804, C68kScript.u32(C68kScript.s16(d >> 2) + memory.read_u32(DAT_0001d804)) & 0x3fff)
					a7 = body - 0xc
					var e: int = C68kScript.s16(fold_angle_pm_0x2000(C68kScript.u32(memory.read_u32(DAT_00024cfc) - memory.read_u32(DAT_0001d800))))
					if e < 0:
						e += 3
					memory.write_u32(DAT_0001d800, C68kScript.u32(C68kScript.s16(e >> 2) + memory.read_u32(DAT_0001d800)) & 0x3fff)
					a7 = saved
				else:
					memory.write_u32(DAT_0001d804, memory.read_u32(DAT_00024cf8))
					memory.write_u32(DAT_0001d800, memory.read_u32(DAT_00024cfc))
				var near_a: bool = memory.read_s32(DAT_0001d804) <= 0x20 or memory.read_s32(DAT_0001d804) > 0x3fdf
				var near_b: bool = memory.read_s32(DAT_0001d800) <= 0x20 or memory.read_s32(DAT_0001d800) > 0x3fdf
				if memory.read_u32(DAT_00024cf8) == 0 and memory.read_u32(DAT_00024cfc) == 0 and near_a and near_b:
					memory.write_u16(DAT_0001d858, 1)
					_hide_player_object(body)
					a7 = body - 4
					update_view_clip_bounds()
					a7 = saved
		5:
			var ctl: int = memory.read_u32(DAT_0001b738)
			var i: int = memory.read_s16(ctl + 0x612) - 7
			if i < 0:
				i += 0x4b
			var rec: int = C68kScript.u32(ctl + i * 0x14 + 0x36)
			memory.write_u32(DAT_0001d838, memory.read_u32(rec))
			memory.write_u32(DAT_0001d834, memory.read_u32(rec + 4))
			memory.write_u32(DAT_0001d830, memory.read_u32(rec + 8))
			memory.write_u16(DAT_0001d810, (-memory.read_u16(rec + 0xc)) & 0x3fff)
			memory.write_u16(DAT_0001d80e, (-memory.read_u16(rec + 0xe)) & 0x3fff)
			memory.write_u16(DAT_0001d80c, (-memory.read_u16(rec + 0x10)) & 0x3fff)
			memory.write_u32(DAT_0001d808, 0)
		6:
			_update_external_camera(body, a6)
		7:
			var target: int = memory.read_u32(DAT_0001b888)
			var obj: int = memory.read_u32(target)
			memory.write_u32(DAT_0001d838, memory.read_u32(obj + 0x18))
			memory.write_u32(DAT_0001d834, memory.read_u32(obj + 0x1c))
			memory.write_u32(DAT_0001d830, memory.read_u32(obj + 0x20))
			memory.write_u16(DAT_0001d810, (-memory.read_u16(target + 0x20)) & 0x3fff)
			memory.write_u16(DAT_0001d80e, (-memory.read_u16(target + 0x22)) & 0x3fff)
			memory.write_u16(DAT_0001d80c, (-memory.read_u16(target + 0x24)) & 0x3fff)
			memory.write_u32(DAT_0001d808, C68kScript.u32(memory.read_s16(memory.read_u32(target + 4) + 0x44) - memory.read_s16(target + 0x626)) & 0x3fff)
		8, 9:
			a7 = body - 4
			var r: int = C68kScript.u32(update_tracking_camera() if view == 8 else update_bailout_view())
			a7 = saved
			if r != 0:
				result = r
	a7 = saved
	return result

## _update_view_camera, view 6 (0x85a2): k = 1 + the asr steps that clear bit 15 of
## update_object_camera_metric(object) + object +0x14 (the low word tested, as in the original);
## d = (object - camera) asr k; attitude_from_velocity(d, ext isqrt_floor(|d|^2), |d|^2, a6 -
## 0x20, a6 - 0x22); the stored angles (0x24d00 / 0x24d04) snap when a folded delta exceeds
## 0x1000, else ease by a quarter; the camera takes their negated low words, roll 0.
func _update_external_camera(body: int, a6: int) -> void:
	var saved: int = a7
	var obj: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	a7 = body - 8
	var reach: int = C68kScript.s32(update_object_camera_metric(obj) + memory.read_u32(obj + 0x14))
	var shift: int = 0
	while (reach & 0x8000) != 0:
		shift += 1
		reach = C68kScript.asr32(reach, 1)
	shift += 1
	var dx: int = C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x18) - memory.read_u32(DAT_0001d838)), shift & 0x3f)
	var dy: int = C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x1c) - memory.read_u32(DAT_0001d834)), shift & 0x3f)
	var dz: int = C68kScript.asr32(C68kScript.s32(memory.read_u32(obj + 0x20) - memory.read_u32(DAT_0001d830)), shift & 0x3f)
	var sq: int = C68kScript.s32(C68kScript.s32(C68kScript.s32(dx * dx) + C68kScript.s32(dy * dy)) + C68kScript.s32(dz * dz))
	a7 = body - 8
	var dist: int = C68kScript.s16(isqrt_floor(C68kScript.u32(sq)))
	a7 = body - 0x24
	attitude_from_velocity(C68kScript.u32(dx), C68kScript.u32(dy), C68kScript.u32(dz), C68kScript.u32(dist), C68kScript.u32(sq), a6 - 0x20, a6 - 0x22)
	a7 = body - 8
	var dp: int = C68kScript.s16(fold_angle_pm_0x2000(C68kScript.u32(memory.read_s16(a6 - 0x20) - memory.read_u32(DAT_00024d00))))
	a7 = body - 0xc
	var dh: int = C68kScript.s16(fold_angle_pm_0x2000(C68kScript.u32(memory.read_s16(a6 - 0x22) - memory.read_u32(DAT_00024d04))))
	a7 = saved
	if abs_int(dp) > 0x1000 or abs_int(dh) > 0x1000:
		memory.write_u32(DAT_00024d00, memory.read_u16(a6 - 0x20) & 0x3fff)
		memory.write_u32(DAT_00024d04, memory.read_u16(a6 - 0x22) & 0x3fff)
	else:
		if dp < 0:
			dp += 3
		memory.write_u32(DAT_00024d00, C68kScript.u32(C68kScript.asr32(dp, 2) + memory.read_u32(DAT_00024d00)) & 0x3fff)
		if dh < 0:
			dh += 3
		memory.write_u32(DAT_00024d04, C68kScript.u32(C68kScript.asr32(dh, 2) + memory.read_u32(DAT_00024d04)) & 0x3fff)
	memory.write_u16(DAT_0001d810, (-memory.read_u16(DAT_00024d00 + 2)) & 0x3fff)
	memory.write_u16(DAT_0001d80e, (-memory.read_u16(DAT_00024d04 + 2)) & 0x3fff)
	memory.write_u16(DAT_0001d80c, 0)
	memory.write_u32(DAT_0001d808, 0)
	a7 = saved

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

## 0x1776a: both radar counts cleared; radar_changed = 1 as a LONG (moveq #1,d0 / move.l d0,
## $2666e at 0x17776; an earlier port wrote one byte, which left 0x01000000).
func reset_radar_tracks() -> void:
	assert(memory != null, "reset_radar_tracks requires original global memory")
	memory.write_u32(DAT_00026672, 0)
	memory.write_u32(DAT_00026676, 0)
	memory.write_u32(_DAT_0002666e, 1)
	return

## 0x1771a: radar_changed (long) = 1, radar_range = range, radar_limit = range asl 1.
func set_view_distance(range_value: int) -> void:
	assert(memory != null, "set_view_distance requires original global memory")
	memory.write_u32(_DAT_0002666e, 1)
	memory.write_u32(DAT_0002666a, C68kScript.u32(range_value))
	memory.write_u32(DAT_00026666, C68kScript.u32(C68kScript.lsl32(range_value, 1)))

## 0x17736: the radar range cycles 0xce40 -> 0xc15c0 -> 0x26ac0 -> 0xce40 (any other value goes
## to 0xce40); set_view_distance entered 8 below.
func cycle_view_distance() -> void:
	assert(memory != null, "cycle_view_distance requires original global memory")
	var entry_a7: int = a7
	var current: int = memory.read_u32(DAT_0002666a)
	var next_range: int = 0x26ac0 if current == 0xc15c0 else (0xc15c0 if current == 0xce40 else 0xce40)
	a7 = entry_a7 - 8
	set_view_distance(next_range)
	a7 = entry_a7

## 0x17a8c: when radar_changed: radar_scale (word 0x26664) = radar_range divs.l (scope width
## (host +0x1e4 - +0x1e0) * 16 / 2, toward zero); radar_changed = 0; the three range buttons
## (host +0x1c2 / +0x1ca / +0x1d2, for 0xce40 / 0x26ac0 / 0xc15c0) are drawn through host
## +0x28e in the lit colour (+0x1da) for the current range, else unlit (+0x1dc) (0x14 below each).
func update_radar_range_buttons() -> void:
	assert(memory != null, "update_radar_range_buttons requires original global memory")
	if memory.read_u32(_DAT_0002666e) == 0:
		return
	var entry_a7: int = a7
	var host: int = memory.read_u32(DAT_0001b5a0)
	var width: int = C68kScript.s32(C68kScript.lsl32(C68kScript.s32(memory.read_s16(host + 0x1e4) - memory.read_s16(host + 0x1e0)), 4))
	if width < 0:
		width = C68kScript.s32(width + 1)
	memory.write_u16(DAT_00026664, C68kScript.u16(C68kScript.divs_trunc(memory.read_s32(DAT_0002666a), C68kScript.asr32(width, 1))))
	memory.write_u32(_DAT_0002666e, 0)
	var lit: int = memory.read_s16(host + 0x1da)
	var unlit: int = memory.read_s16(host + 0x1dc)
	for button in [[0x1c2, 0xce40], [0x1ca, 0x26ac0], [0x1d2, 0xc15c0]]:
		host = memory.read_u32(DAT_0001b5a0)
		var colour: int = lit if memory.read_u32(DAT_0002666a) == button[1] else unlit
		a7 = entry_a7 - 0x14
		_jsr(memory.read_u32(host + 0x28e), [C68kScript.u32(host + button[0]), C68kScript.u32(colour)])
		a7 = entry_a7

## 0x17b68: the radar scope. Link a6 -8 and ten registers (body 0x34 below); sin / cos of
## neg_camera_heading (0x3c / 0x40 below). On a colour screen (host +0x9e == 0) last frame's blips
## (radar_drawn_tracks 0x1b520, word count 0x26674) that were drawn (+0x10) are erased through
## *0x1da90(x, y) (0x3c below). Each current track (radar_tracks 0x1b51c, word count 0x26678):
## dx / dz = (track - player) divs.l radar_scale, low words; screen x = centre x (+0x1e8) +
## word((dx * cos - dz * sin) asr 16), y = centre y (+0x1ea) - word((dx * sin + dz * cos) asr 16)
## (muls.w) replace the track position; inside the scope (+0x1e0 <= x < +0x1e4, +0x1de <= y <
## +0x1e2) it is drawn - *0x1da94(x, y) (0x3c below) on colour, else two host +0x272 lines in
## colour +0xe4 at the scaled offsets (colour, dx, dz - 1, dx, dz + 1) (0x48 below) and (colour,
## dx - 1, dz, dx + 1, dz) (0x5c below) - and +0x10 = 1, else +0x10 = 0. Then the drawn count
## (0x26672) takes the track count, the two lists swap and the track count is cleared.
func update_radar_scope() -> void:
	assert(memory != null, "update_radar_scope requires original global memory")
	var entry_a7: int = a7
	var body: int = entry_a7 - 0x34
	var player: int = memory.read_u32(memory.read_u32(DAT_0001b738))
	var host: int = memory.read_u32(DAT_0001b5a0)
	var centre_x: int = memory.read_s16(host + 0x1e8)
	var centre_y: int = memory.read_s16(host + 0x1ea)
	a7 = body - 8
	var sin_h: int = C68kScript.s16(sin_fixed14(memory.read_s16(DAT_0001d80e)))
	a7 = body - 0xc
	var cos_h: int = C68kScript.s16(cos_fixed14(memory.read_s16(DAT_0001d80e)))
	a7 = entry_a7
	host = memory.read_u32(DAT_0001b5a0)
	if memory.read_u16(host + 0x9e) == 0:
		var blip: int = memory.read_u32(DAT_0001b520)
		var left: int = memory.read_u16(DAT_00026672 + 2)
		while left != 0:
			left -= 1
			if memory.read_u32(blip + 0x10) != 0:
				a7 = body - 0xc
				_jsr(memory.read_u32(DAT_0001da90), [memory.read_u32(blip), memory.read_u32(blip + 4)])
				a7 = entry_a7
			blip = C68kScript.u32(blip + 0x14)
	var track: int = memory.read_u32(DAT_0001b51c)
	var left_tracks: int = memory.read_u16(DAT_00026676 + 2)
	while left_tracks != 0:
		left_tracks -= 1
		var scale: int = memory.read_s16(DAT_00026664)
		assert(scale != 0, "update_radar_scope: divs.l by zero traps")
		var dx: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(track) - memory.read_u32(player + 0x18)), scale))
		var dz: int = C68kScript.s16(C68kScript.divs_trunc(C68kScript.s32(memory.read_u32(track + 4) - memory.read_u32(player + 0x20)), scale))
		var sx: int = C68kScript.s16(C68kScript.s16(C68kScript.asr32(C68kScript.s32(dx * cos_h - dz * sin_h), 16)) + centre_x)
		memory.write_u32(track, C68kScript.u32(sx))
		var sy: int = C68kScript.s16(centre_y - C68kScript.s16(C68kScript.asr32(C68kScript.s32(dx * sin_h + dz * cos_h), 16)))
		memory.write_u32(track + 4, C68kScript.u32(sy))
		host = memory.read_u32(DAT_0001b5a0)
		if sx < memory.read_s16(host + 0x1e0) or sx >= memory.read_s16(host + 0x1e4) or sy < memory.read_s16(host + 0x1de) or sy >= memory.read_s16(host + 0x1e2):
			memory.write_u32(track + 0x10, 0)
		else:
			if memory.read_u16(host + 0x9e) != 0:
				var colour: int = memory.read_s16(host + 0xe4)
				a7 = body - 0x18
				_jsr(memory.read_u32(host + 0x272), [C68kScript.u32(colour), C68kScript.u32(dx), C68kScript.u32(dz - 1), C68kScript.u32(dx), C68kScript.u32(dz + 1)])
				host = memory.read_u32(DAT_0001b5a0)
				colour = memory.read_s16(host + 0xe4)
				a7 = body - 0x2c
				_jsr(memory.read_u32(host + 0x272), [C68kScript.u32(colour), C68kScript.u32(dx - 1), C68kScript.u32(dz), C68kScript.u32(dx + 1), C68kScript.u32(dz)])
				a7 = entry_a7
			else:
				a7 = body - 0xc
				_jsr(memory.read_u32(DAT_0001da94), [C68kScript.u32(sx), C68kScript.u32(sy)])
				a7 = entry_a7
			memory.write_u32(track + 0x10, 1)
		track = C68kScript.u32(track + 0x14)
	var drawn: int = memory.read_s16(DAT_00026676 + 2)
	memory.write_u32(DAT_00026676, memory.read_u32(DAT_00026672))
	memory.write_u32(DAT_00026672, C68kScript.u32(drawn))
	var tracks: int = memory.read_u32(DAT_0001b51c)
	memory.write_u32(DAT_0001b51c, memory.read_u32(DAT_0001b520))
	memory.write_u32(DAT_0001b520, tracks)
	memory.write_u32(DAT_00026676, 0)
