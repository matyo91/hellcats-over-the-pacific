# Hellcats Over the Pacific — decompilation symbol map

Maps original Ghidra identifiers to recovered names. Every entry must cite
evidence. Do not treat example names from planning docs as approved until
revalidated here.

## Functions

| Original symbol | Recovered name | Confidence | Evidence |
|---|---|---|---|
| `FUN_00000048` (ID09) | `sysenvirons_glue_fallback` | STRONG INFERENCE | entry dispatcher at file 0x20-0x46 calls `$A090` (_SysEnvirons) only when GetOSTrapAddress($90) ≠ GetToolTrapAddress($9F _Unimplemented) or falls into 0x48; body fills SysEnvRec from documented low-memory globals and returns 0xea84 (−5500 envNotPresent). Lookup table proven at file 0x54..0x58. Trap/global names from Apple docs, not validated against Apple glue. See `ID09_SYSENVIRONS_ANALYSIS.md`. |
| `FUN_000002a6` (ID09) | `fsopen_glue` | STRONG INFERENCE | file 0x2a6..0x2dc LINK −0x32 IOParam; +0x12←long arg, +0x16←word arg, clears +0x1a/+0x1b/+0x1c; `$A000` (_Open); +0x18→VAR arg; D0→result; pops 10 bytes = FSOpen(fileName, vRefNum, VAR refNum): OSErr. Trap/field names from Inside Macintosh. |
| `FUN_000003c2` (ID09) | `swapmmumode_glue` | STRONG INFERENCE | file 0x3c2..0x3d4 loads byte via VAR ptr into D0, `$A05D` (_SwapMMUMode), stores D0.B back, pops 4 bytes = SwapMMUMode(VAR mode: SignedByte). Trap name from Inside Macintosh. |
| `FUN_00000006` (ID07) | `load_str129_string_table` | STRONG INFERENCE | ID07.bin 0x06..0x18e GetResource('STR#',0x81) `$A9A0`, HLock via JT `$272(A5)`, in-place \\p/escape processing, stores 120 string pointers to A5−0xf46[1..120]. Sole caller `FUN_00000190` (ID07). |
| `FUN_00000190` (ID07) | `init_string_pointer_groups` | STRONG INFERENCE | calls `load_str129_string_table`, copies slots 2..22→A5−0x221e[21], 94..99→A5−0xffe[6], 100..105→A5−0xfae[6], 106..115→A5−0xf86[10]. JT A5+0x592; called from ID02 file 0x2c0a. |
| `FUN_00002bbc` (ID02) | `initialize_application` | STRONG INFERENCE | ID02.bin 0x2bbc..0x2d9e Toolbox init sequence ($A86E InitGraf … $A850 InitCursor), JT $592 string init + UnloadSeg 7, SysEnvirons via JT $1f2, 'MENU' 2 / 'HEL1' 127/128 load-or-create, SetPort. Caller `FUN_0000309a`. |
| `FUN_0000309a` (ID02) | `main` | STRONG INFERENCE (entry chain PROVEN) | called from ID01 runtime entry via JT A5+0x4b2 (constant at ID01 file 0x4); runs `initialize_application`, ID08 overlay loader, UnloadSeg 4/8/5, then loops forever on `FUN_00002fd4`. |
| `FUN_00002fd4` (ID02) | `poll_and_dispatch_event` | STRONG INFERENCE | ID02.bin 0x2fd4..0x3098 GetNextEvent ($A970) + switch on what: mouseDown→0x2f1e, cmd-key→MenuKey→0x36a2, update→Begin/EndUpdate+0x4db0, activate→0x2fa0. Called forever by `main`. |
| `FUN_000036a2` (ID02) | `do_menu_command` | STRONG INFERENCE | HiWord/LoWord($A86A/$A86B) of menuResult; menu 1 Apple (OpenDeskAcc), menu 3 Edit (SystemEdit), menu 2 13-item command menu (quit = 0x2eaa). Called from `poll_and_dispatch_event` after MenuKey. |
| `FUN_00002a44` (ID02) | `apply_settings_to_live_options` | STRONG INFERENCE | copies HEL1 127 words S+2..S+0x24 into A5−0x12ee..−0x12d0; change-triggered callbacks via A5−0x1092/−0x104e/−0x1096 gated by A5−0x1006; redraw FUN_00004db0. 6 callers in ID02.bin. |
| `FUN_00002f1e` (ID02) | `handle_mouse_down` | STRONG INFERENCE | FindWindow switch: inMenuBar→MenuSelect→do_menu_command, inSysWindow→SystemClick, inGoAway(main)→TrackGoAway→HideWindow. |
| `FUN_00002fa0` (ID02) | `handle_activate_event` | STRONG INFERENCE | (modifiers&3)==3 && message==main_window → InvalRect(&main_window->portRect). |
| `FUN_00004db0` (ID02) | `redraw_main_window` | STRONG INFERENCE | gated redraw: HideCursor, FUN_00004c18, UnloadSeg 3, overlay callback A5−0x109e, helpers, ShowCursor. Called from update handling and apply_settings_to_live_options. |
| `FUN_00004c18` (ID02) | `check_device_color_state_changed` | STRONG INFERENCE | compares per-device 256-word arrays from FUN_000048ae with stored copies; on change → JT $182, refresh, overlay callback A5−0x1096. |
| `FUN_000048ae` (ID02) | `build_palette_index_map` | STRONG INFERENCE | per device slot, PmForeColor(i) → fgColor index → map[i]/inverse[idx]; duplicate detection → A5−0x102a; selects A5−0x1122 = JT 0x46a or 0x33a. |
| `FUN_000046b4` (ID02) | `rebuild_all_palette_index_maps` | STRONG INFERENCE | rebuild map for each device slot 1..3 (or B&W path). |
| `FUN_00004738` (ID02) | `configure_palette_entries` | STRONG INFERENCE | depth-4 / depth-8 Palette Manager entry usage + colours. |
| `FUN_0000488a` (ID02) | `clear_ctab_size_callback` | STRONG INFERENCE | A5 from CurrentA5; (*A5−0x14b2)+6 = 0. |
| `FUN_000049fe` (ID02) | `lookup_palette_index_for_rgb_level` | STRONG INFERENCE | (r,g,b) levels ×64→16-bit; search A5−0x350[8] then *(A5−0x14a6); +200 at 8-bit. |
| `FUN_00000d24` (ID02) | `close_and_dispose_port` | STRONG INFERENCE | ClosePort(p); DisposPtr(p). Used on A5−0x103a. |
| `FUN_00000d3a` (ID02) | `blit_offscreen_frame_to_window` | STRONG INFERENCE | (base, top, rows, mode) → offscreen PixMap port A5−0x103a, CopyBits to thePort. JT $322; ID06 0xf18; address taken at ID02 0x1b6a. |
| `FUN_00001b14` (ID02) | `freemem_a5safe` | STRONG INFERENCE | CurrentA5 wrapper around ID09 FreeMem glue; service slot A5−0x10a6. |
| `FUN_00001a04` / `1a84` / `1aa8` / `1acc` / `1af0` (ID02) | `dispose_handle_a5safe` / `hlock_a5safe` / `hunlock_a5safe` / `hpurge_a5safe` / `hnopurge_a5safe` | STRONG INFERENCE | CurrentA5 thunks → ID09 $A023/$A029/$A02A/$A049/$A04A glue; service slots. |
| `FUN_00001a28` (ID02) | `realloc_and_clear_handle_a5safe` | STRONG INFERENCE | ReallocHandle + MemError check + zero-fill via FUN_000002b0. |
| `FUN_000019a2` (ID02) | `new_handle_clear_or_die_a5safe` | STRONG INFERENCE | NewHandleClear + MemError → fatal; service slot A5−0x10c2. |
| `FUN_000019e2` (ID02) | `fatal_memory_error_exit` | STRONG INFERENCE | dispose overlay, FUN_00004318, show STR#129[93] via FUN_00001d48, ExitToShell. |
| `FUN_00001d48` (ID02) | `show_caution_alert_with_number` | STRONG INFERENCE | ParamText(msg, number) + CautionAlert(258). JT $4ba. |
| `FUN_00001c8a` (ID02) | `format_int_decimal_pstring` | STRONG INFERENCE | signed decimal → Pascal string in 10-byte buffer. |
| `FUN_00004318` (ID02) | `shutdown_sound` | STRONG INFERENCE | stop 3 channels, restore $0196, SndDisposeChannel(A5−0x356). |
| `FUN_00004242` (ID02) | `silence_sound_channel` | STRONG INFERENCE | ch 0..1 → FUN_00003d50(ch, A5−0xc26, 0, 370, 0) into channel record. |
| `FUN_00003d36` (ID02) | `clear_sound_buffer_to_silence` | STRONG INFERENCE | SoundBase ($0266) 370 words ← 0x80. |
| `FUN_00003d50` (ID02) | `alloc_sound_buffer_node` | STRONG INFERENCE | node from channel free list; {+0 cursor, +8 buffer, +0xc start, +0x10 end, +0x14 next, +0x18 continuation}. |
| `FUN_00003dd0` (ID02) | `init_sound_system` | STRONG INFERENCE | builds channel queues, silence buffer, installs routine into low-memory $0196 (saved in A5−0xc36). |
| `FUN_000039a8` / `FUN_00003aae` / `FUN_00003bc4` (ID02) | `vbl_sound_handler_ch0_unrolled` / `vbl_sound_handler_ch0_variant` / `vbl_sound_handler_two_channel` | STRONG INFERENCE | Lvl1DT[1] VBL hooks; in-code A5 cache; RTS-chain to previous vector; resample into SoundBase. |
| `FUN_00003db8` (ID02) | `select_two_channel_sound_handler` | STRONG INFERENCE | arg == 1 → $0196 = A5−0x35c. |
| `FUN_00003f54` (ID02) | `play_sample_on_channel` | STRONG INFERENCE | queue sample on ch 0..1 with optional sustain loop; see SOUND_SYSTEM.md. |
| `FUN_00004050` (ID02) | `enqueue_sample_on_channel` | STRONG INFERENCE (purpose HYPOTHESIS) | queues nodes like play_sample_on_channel but leaves channel head unchanged. |
| `FUN_0000412e` (ID02) | `set_sound_playback_rate` | STRONG INFERENCE | 16.16 rate → step/len globals. |
| `FUN_000041a6` (ID02) | `release_channel_loop` | STRONG INFERENCE | breaks sustain self-loops, ends in silence. |
| `FUN_000042b0` (ID02) | `is_channel_playing` | STRONG INFERENCE | current buffer ≠ silence. |
| `FUN_00000c68` (ID02) | `apply_pending_color_entries_a5safe` | STRONG INFERENCE | SetEntries(-1, ctSize-1, ctTable) on A5−0x14b2; ctSize = 0. |
| `FUN_00001876` (ID02) | `blit_image_clipped_to_region` | STRONG INFERENCE | CopyBits image A5−0x12b0 via port A5−0x1496 clipped to region from FUN_000016aa. |
| `FUN_0000195c` / `FUN_0000197c` (ID02) | `blit_image_clipped_to_region_a5safe` / `run_segment3_entry_and_unload_a5safe` | STRONG INFERENCE | CurrentA5 service thunks. |
| `FUN_00000a42` (ID02) | `draw_thick_line_pixel_index_a5safe` | STRONG INFERENCE | fgColor raw index; 2-px MoveTo/LineTo. |
| `FUN_00000a86` (ID02) | `draw_thick_xor_line_a5safe` | STRONG INFERENCE | black srcXor 2-px line. |
| `FUN_00000ad0` (ID02) | `paint_view_horizon_bands_a5safe` | STRONG INFERENCE (purpose HYPOTHESIS) | top band + two tilted quads + bottom band in view region. |
| `FUN_000015cc` (ID02) | `set_draw_color_index` | STRONG INFERENCE | fgColor = index (or B&W path). |
| `FUN_00000f52` / `FUN_00000f74` (ID02) | `close_port_a5safe` / `swap_port_a5safe` | STRONG INFERENCE | ClosePort; SetPort returning previous port. |
| `FUN_00000fa0` (ID02) | `paint_rect_color_index_a5safe` | STRONG INFERENCE | colour index + PaintRect. |
| `FUN_00000fd2` (ID02) | `paint_polygon_rgb_a5safe` | STRONG INFERENCE | filled polygon in packed RGB, y negated. |
| `FUN_00000e3e` (ID02) | `blit_pixels_via_port_a5safe` | STRONG INFERENCE | set baseAddr; CopyBits src→dst (default thePort). |
| `FUN_00000e9e` (ID02) | `open_offscreen_cport_a5safe` | STRONG INFERENCE | OpenCPort + pixmap/portRect/visRgn setup on caller storage. |
| `FUN_00000ca6` (ID02) | `new_offscreen_cport` | STRONG INFERENCE | allocate CGrafPort (0x6c) and set it up. |
| `FUN_000014e6` (ID02) | `swap_mmu_mode_a5safe` | STRONG INFERENCE | SwapMMUMode(&A5−0x1000) via ID09 glue; slot −0x10c6. |
| `FUN_000011ec` (ID02) | `draw_notched_frame_pair_a5safe` | STRONG INFERENCE mechanics | two notched frames (pen 2/1) from rect A5−0x119c, drawn twice. |
| `FUN_000010ce` (ID02) | `build_notched_frame_poly` | STRONG INFERENCE mechanics | notched/chamfered frame polygon from a Rect. |
| `FUN_00001308` (ID02) | `draw_text_in_columns_a5safe` | STRONG INFERENCE mechanics | columned DrawString output with FillRect backgrounds; slot −0x110e. |
| `FUN_00001656` / `FUN_00001680` (ID02) | `design_x_to_screen` / `design_y_to_screen` | STRONG INFERENCE | A5−0x149e·v/4800 + half view width/height. |
| `FUN_00001632` / `FUN_0000001e` (ID02) | `set_back_color_index` / `abs_long` | STRONG INFERENCE | — |
| `FUN_00002db8` / `FUN_00004d34` (ID02) | `wait_for_click_or_key` / `process_pending_update_events` | STRONG INFERENCE | modal input wait; update flush. |
| A5−0x1372 / A5−0x1370 | view width / height (words) | STRONG INFERENCE | srcRect right/bottom in blit_offscreen_frame_to_window; centre in design_*_to_screen. |
| `FUN_000007b0` / `00000598` / `00000666` / `00000512` / `0000087a` (ID06) | `init_raster_target` / `alloc_row_table` / `init_edge_pool` / `free_row_table` / `set_raster_target_base` | STRONG INFERENCE | ID06 rasterizer set-up; structures A5−0x1cce / −0x1cd2 / −0x1cd6. |
| `FUN_000008a2` / `0000096e` / `000009d8` / `00000e10` / `0000026c` (ID06) | `set_active_row_count` / `reset_edge_table` / `add_polygon_edges` / `rasterize_and_present` / `init_row_table_fields` | STRONG INFERENCE | scanline polygon rasterizer API (service slots −0x1304/−0x1310/−0x130c/−0x1308). |
| `FUN_00000318` (ID06) | `render_scanline_spans` | STRONG INFERENCE | priority span fill; in-code state at 0x39e..0x3e1. JT $192. |
| `FUN_00000d84` / `FUN_00000dca` (ID06) | `rebase_edge_rows_for_band` / `restore_edge_rows_after_band` | STRONG INFERENCE | band row-counter adjustment. |
| `FUN_000001dc` / `FUN_0000024c` (ID06) | `alloc_aligned_clear` / `free_aligned` | STRONG INFERENCE | aligned NewPtrClear with header; DisposPtr of raw pointer. |
| `FUN_00000116` (ID06) | `rgb_to_bw_pattern` | STRONG INFERENCE | luma → pattern pointer (A5−0x1ed6, 64 × 8 bytes). |
| `FUN_0000017c` / `FUN_000001a2` (ID06) | `lookup_colour_map` / `reverse_lookup_colour_map` | STRONG INFERENCE | 256-word map at *A5−0x1ede. |
| `FUN_00000004` / `000000b0` / `000000f4` (ID06) | `init_pattern_tables` / `alloc_pattern_tables` / `get_pattern_table` | STRONG INFERENCE | mask + pattern table A5−0x1eda (0xc00), grey map A5−0x1ede (0x200). |
| `FUN_00000916` / `00000942` / `00000d02` (ID06) | `get_raster_target_size` / `realloc_row_table` / `add_rect_polygon` | STRONG INFERENCE | — |
| `FUN_00000056` / `0000008a` / `000000a6` (ID03) | `scale_design_480_min10` / `scale_design_4800` / `scale_design_4800_pen_centred` | STRONG INFERENCE | design-unit → screen scaling via A5−0x149e. |
| `FUN_000000c8` / `000000f4` (ID03) | `max3_int` / `nearest_palette_index_rgb` | STRONG INFERENCE | — |
| `FUN_00000006` / `000002a8` / `0000033c` (ID03) | `set_scaled_text_style` / `new_offscreen_bw_port` / `dispose_offscreen_bw_port` | STRONG INFERENCE | text style; 1-bit offscreen GrafPort create/dispose. |
| `FUN_00000912` (ID03) | `draw_vector_number` | STRONG INFERENCE | stroke-font digits from A5−0x1fde. |
| `FUN_0000035e` (ID03) | `draw_spinning_disc_indicator` | STRONG INFERENCE mechanics | grey disc + 4-phase rotating spoke (A5−0x2112), size A5−0x2114;  likely a bezel screw head (HYPOTHESIS). |
| `FUN_00000514` (ID03) | `draw_ring_with_status_indicators` | STRONG INFERENCE mechanics | ring + up to 5 diagonal spinning indicators by flag bits. |
| `FUN_00000a3c` (ID03) | `antialias_downsample_bw_3x` | STRONG INFERENCE | 3× Gaussian (7×7, /969) downsample of 1-bit bitmap into grey palette pixels. |
| `FUN_00003c02` (ID03) | `draw_instrument` | STRONG INFERENCE | bezel + type-switch (0..9) to per-gauge drawers; record A5−0x12a2. |
| `FUN_00001876` (ID03) | `draw_altimeter` | STRONG INFERENCE | instrument type 0; label STR#129[65] "ALTITUDE". |
| `FUN_00001538` (ID03) | `begin_instrument_supersample` | STRONG INFERENCE | 1× or 3× B&W port for anti-aliased gauge drawing. |
| `FUN_00001b48` (ID03) | `draw_airspeed_indicator` | STRONG INFERENCE | instrument type 1; label "AIR SPEED". |
| `FUN_00002d1c` (ID03) | `draw_turn_and_bank_indicator` | STRONG INFERENCE | instrument type 2; label "TURN BANK". |
| `FUN_00001fee` (ID03) | `draw_climb_indicator` | STRONG INFERENCE | instrument type 3; label "CLIMB". |
| `FUN_00002600` (ID03) | `draw_manifold_pressure_gauge` | STRONG INFERENCE | instrument type 4; label "Manifold Pressure". |
| `FUN_000022fe` (ID03) | `draw_tachometer` | STRONG INFERENCE | instrument type 5; label "RPM". |
| `FUN_00002950` (ID03) | `draw_direction_indicator` | STRONG INFERENCE | instrument type 6; label "DIRECTION". |
| `FUN_00004c42` / `00004ecc` / `0000532e` (ID03) | `draw_flaps_indicator` / `draw_ammo_counter` / `draw_fuel_gauge` | STRONG INFERENCE | labels STR#129 slots 75 / 76 / 77. |
| `FUN_00003d42` (ID04) | `check_system_requirements` | STRONG INFERENCE | Color QD + 68020 check; JT $f2. |
| `FUN_000003c2` (ID04) | `run_with_temporary_window` | STRONG INFERENCE mechanics | "Hellcats" window around ID02 0x2db8. |
| `FUN_000004f0` / `00000516` / `00000560` (ID04) | `ask_save_changes` / `confirm_end_mission` / `confirm_erase_high_scores` | STRONG INFERENCE | CautionAlert 257 / 259 / 260 (texts from DITL dump). |
| `FUN_00000588` (ID04) | `compute_pilot_score` | STRONG INFERENCE | Σ record +0x28 tallies × A5−0xf5e weights. |
| `FUN_00000f4e` / `00001106` / `00001a0e` (ID04) | `rank_pilots_by_score` / `reset_pilot_record` / `build_rank_and_name_string` | STRONG INFERENCE | See PILOT_ROSTER.md. |
| `FUN_000031aa` (ID04) | `conclude_mission` | STRONG INFERENCE | mission-over flag + pilot status write; JT $da. |
| `FUN_00003124` / `FUN_00003178` (ID04) | `play_named_sound_async` / `stop_named_sound` | STRONG INFERENCE | Sound Manager 'snd ' by name (A5−0x2128); channel A5−0x2152, handle A5−0x2156. |
| `FUN_00002de6` (ID04) | `show_mission_summary_dialog` | STRONG INFERENCE | DLOG 133 "Mission Summary". |
| `FUN_00000006` (ID04) | `disable_dialog_control` | PROVEN | bytes; HiliteControl 255. |
| `FUN_0000002e` (ID04) | `enable_dialog_control` | PROVEN | bytes; HiliteControl 0. |
| `FUN_00000054` (ID04) | `hide_dialog_control` | PROVEN | bytes; HideControl. |
| `FUN_00000078` (ID04) | `show_dialog_control` | PROVEN | bytes; ShowControl. |
| `FUN_0000009c` (ID04) | `set_dialog_item_text` | PROVEN | bytes; SetIText. |
| `FUN_000000c4` (ID04) | `set_dialog_control_title` | PROVEN | bytes; SetCTitle. |
| `FUN_000000ec` (ID04) | `set_dialog_user_item_proc` | PROVEN | bytes; SetDItem with a ProcPtr. |
| `FUN_00000120` (ID04) | `frame_dialog_item_box` | PROVEN | bytes; InsetRect -2, PenSize 1, FrameRect. |
| `FUN_0000016e` (ID04) | `draw_default_button_outline` | PROVEN | bytes; user item via JT $12a; item A5-0x225e; FrameRoundRect 16. |
| `FUN_000001f2` (ID04) | `draw_grey_user_item` | PROVEN | bytes; user item via JT $142; FillRect gray A5-0x1624. |
| `FUN_000017e6` (ID04) | `create_scrolling_text_item` | STRONG INFERENCE | bytes; TENew -> A5-0x223a; NewControl scrollBarProc -> A5-0x2236; user item JT $92. |
| `FUN_0000189c` (ID04) | `dispose_scrolling_text_item` | PROVEN | bytes; TEDispose + DisposeControl. |
| `FUN_000018b0` (ID04) | `append_line_to_scrolling_text` | STRONG INFERENCE | bytes; strlen (ID02 0x3e8) + TEInsert ×2 + 0x158c scroll update. |
| `FUN_000014a0` (ID04) | `draw_scrolling_text_item` | PROVEN | bytes; EraseRect viewRect, TEUpdate, frame. |
| `FUN_000014f2` (ID04) | `scrolling_text_user_item_proc` | PROVEN | bytes; Pascal user item, JT $92. |
| `FUN_0000150e` (ID04) | `sync_text_scroll_to_control` | PROVEN | bytes; TEScroll by ctl value × lineHeight. |
| `FUN_00001562` (ID04) | `update_scroll_bar_maximum` | PROVEN | bytes; SetCtlMax(nLines − visible). |
| `FUN_0000158c` (ID04) | `scroll_text_to_show_selection` | STRONG INFERENCE | bytes; centre line holding selStart. |
| `FUN_00001638` (ID04) | `fit_text_view_to_box` | PROVEN | bytes; viewRect = box − 16, whole lines, TECalText. |
| `FUN_000016c4` (ID04) | `scroll_bar_action_proc` | PROVEN | bytes; JT $16a TrackControl action; parts 20..23; also documents unexported click handler 0x1752. |
| `FUN_000018e0` (ID04) | `get_mission_kill_report_state` | STRONG INFERENCE | bytes; 0/1/2 from A5-0x12f8, -0x14c0, -0x12ba and ten kill words A5-0x12ce. |
| `FUN_0000192e` (ID04) | `update_summary_dialog_buttons` | STRONG INFERENCE | bytes; enables items 1/3; moves default ring A5-0x225e to item 1. |
| `FUN_00002d86` (ID04) | `set_score_item_text` | PROVEN | "Score: " + compute_pilot_score. |
| `FUN_00001f5e` (ID04) | `draw_aircraft_kill_markers` | STRONG INFERENCE | tallies 0+1, red discs, under "Total Aircraft Destroyed". |
| `FUN_000020e8` (ID04) | `aircraft_kill_markers_user_item_proc` | PROVEN | JT $ea user item. |
| `FUN_00001bc8` (ID04) | `draw_targets_destroyed_row` | STRONG INFERENCE | per target type; skips 2/4/8; count and count × weight. |
| A5−0xf5e | per-target-type point weights (words) | STRONG INFERENCE | count × weight in draw_targets_destroyed_row and compute_pilot_score. |
| A5−0x2226 | pointer to the Mission Summary kill counts (local array) | PROVEN | set at ID04 0x2e00. |
| A5−0x12ce | ten per-mission kill counters, cleared when added to the pilot tallies | PROVEN | summary state 3 (0x2a2e). |
| A5−0x13a2 | ten per-type kill totals, incremented with the pilot tallies | STRONG INFERENCE | role beyond accumulation unknown. |
| A5−0x1002 | resource file reference number used with UpdateResFile | STRONG INFERENCE | roster write-back. |
| A5−0x2176 | summary kill-transfer index (target type) | PROVEN | — |
| A5−0xfd6 | rank point thresholds (one long per rank) | STRONG INFERENCE | summary state 4 promotion. |
| A5−0x2220 | Mission Summary argument word from conclude_mission; low byte 1 grants the mission award | PROVEN flow / HYPOTHESIS meaning | — |
| A5−0x12f8 | current mission number; award bit = value − 3 | STRONG INFERENCE | summary state 2. |
| A5−0x12b6 | friendly units destroyed this mission (≥ 5 → executed for treason) | STRONG INFERENCE | summary state 0. |
| A5−0x12ba | mission objective state (> 0 done, 0 open, −1 failed by event, −2 original Hellcat lost) | STRONG INFERENCE | — |
| A5−0x221e + 4k | STR# 129 slot 2 + k pointer group (outcome texts) | PROVEN |  (with ID07 init_string_pointer_groups). |
| A5−0x21c6 / A5−0x21ca | summary line queue (string pointers) / cursor | PROVEN | states 0, 4, 5. |
| `FUN_00001d9e` (ID04) | `draw_targets_destroyed_list` | PROVEN | JT $aa user item 6. |
| `FUN_00000220` (ID04) | `draw_percent_bar_item` | PROVEN | bytes; percentage bar A5-0x225c (0..100), dkGray / white. |
| `FUN_000002c0` (ID04) | `percent_bar_user_item_proc` | PROVEN | bytes; JT $8a user item; documents unexported set_radio_group_selection 0x2dc. |
| `FUN_00000362` (ID04) | `get_radio_group_selection` | PROVEN | bytes; first set control of an item list, else -1. |
| `FUN_00000a8e` (ID04) | `fuel_slider_dialog_filter` | STRONG INFERENCE | bytes; Return/Enter, slider tracking (StillDown/GetMouse), update events. |
| `FUN_00000bda` (ID04) | `scenario_selection_filter_proc` | PROVEN | bytes; JT $112 filter, DLOG 129, slider item 5. |
| `FUN_00000e48` (ID04) | `refuel_dialog_filter_proc` | PROVEN | bytes; JT $14a filter, DLOG 132, slider item 3. |
| `FUN_000009ee` (ID04) | `draw_select_mission_title` | PROVEN | bytes; JT $11a user item 4 of DLOG 129; STR# 64 centred, size 24. |
| `FUN_0000116a` (ID04) | `prune_inactive_pilots_beyond_ten` | STRONG INFERENCE | bytes; clears non-Active records after the best ten; WriteResource roster. |
| `FUN_0000044e` (ID04) | `show_scenery_open_error_alert` | PROVEN | bytes; ParamText + StopAlert(256) "Unable to open Hellcats scenery file"; JT $fa. |
| `FUN_00000478` (ID04) | `show_paused_dialog` | PROVEN | bytes; DLOG 131 "Paused", wait for key down + up; JT $122. |
| `FUN_000005e4` (ID04) | `duty_roster_filter_proc` | PROVEN | bytes; JT $c2 filter; documents unexported run_duty_roster_dialog 0x644 (JT $132, DLOG 130). |
| `FUN_00003260` (ID04) | `draw_map_grid_and_centre_mark` | PROVEN | bytes; 4 x 4 grid + centre cross; A5-0x214e = 1. |
| `FUN_00003352` (ID04) | `plot_map_symbol_callback` | PROVEN | bytes; JT $72 callback: DrawChar at map coordinates (CurrentA5). |
| `FUN_000033d6` (ID04) | `draw_map_view_item` | STRONG INFERENCE | bytes; blue sea, A5-0x1052(scale, JT $72), scale text " mi./grid" item 7. |
| `FUN_000035f8` (ID04) | `map_view_user_item_proc` | PROVEN | bytes; JT $b2; documents unexported track_map_bearing_and_distance 0x3614. |
| `FUN_00003902` (ID04) | `map_dialog_filter_proc` | PROVEN | bytes; JT $d2; documents unexported run_map_dialog 0x3976 (JT $10a, DLOG 137 zoom). |
| `FUN_00003a56` (ID04) | `poll_click_or_key_event` | PROVEN | bytes; 1 for mouseDown / keyDown / autoKey. |
| `FUN_00003a8c` (ID04) | `show_about_dialog` | STRONG INFERENCE | bytes; DLOG 127 / 138 (1-bit), vers 1 text; tail not decoded. |
| `FUN_00001200` (ID04) | `draw_high_scores_table` | PROVEN | JT $e2; DLOG 134. |
| `FUN_000032b8` (ID03) | `draw_gyro_instrument` | STRONG INFERENCE (directional gyro heading tape) | type 8; renders a 9-window-wide tape of 36 marks numbered 0, 33 .. 3 into A5-0x11dc "GyroInstrument"; A5-0x11d4 "GyroFlags" = antialias drawn-column flags; window record A5-0x11ee..-0x11e0. |
| `FUN_00003832` (ID03) | `make_inset_face_oval_region` | STRONG INFERENCE | oval region of the face inside the bezel. |
| `FUN_000038fc` (ID03) | `draw_artificial_horizon` | STRONG INFERENCE | type 9; region clip, rotated line; handle A5-0x11f6 "HorizonInstrument". |
| `FUN_00005ab6` (ID03) | `store_panel_bitmaps_as_resources` | PROVEN | AddResource HEL2 200–500 + config. |
| `FUN_00005c36` (ID03) | `open_cport_on_buffer` | PROVEN | OpenCPort on a caller buffer (rowBytes, baseAddr, bounds). |
| `FUN_00005cb6` (ID03) | `close_port_glue` | PROVEN | ClosePort. |
| `FUN_00005cc4` (ID03) | `prepare_instrument_panel` | STRONG INFERENCE | JT $17a; panel scale A5-0x149e; Bitmap Cache lookup by display configuration. |
| `FUN_00005860` (ID03) | `compute_panel_screen_addresses` | STRONG INFERENCE | screen byte addresses base + y*rowBytes + x/(8/depth). |
| `FUN_00006c1c` (ID03) | `remap_cached_panel_colours` | STRONG INFERENCE | JT $182; re-colours a cached panel; palette indices via lookup_palette_index_for_rgb_level. |
| `FUN_0000077e` (ID03) | `draw_vector_glyph_string_centred` | STRONG INFERENCE | centred stroke-font string; glyph table A5-0x20b0 (6 glyphs). |
| `FUN_0000146a` (ID03) | `composite_instrument_bitmap` | PROVEN | CopyBits (1-bit) or antialias_downsample_bw_3x into the panel port A5-0x1496. |
| `FUN_00001844` (ID03) | `finish_instrument_supersample` | PROVEN | SetPort(panel), composite, dispose_offscreen_bw_port. |
| `FUN_00003f24` (ID03) | `draw_bevelled_frame` | STRONG INFERENCE | four shaded polygons between outer and inner rects. |
| `FUN_00004110` (ID03) | `draw_numbered_bevel_box` | PROVEN | black box, bevel, vector-font number. |
| `FUN_00004790` (ID03) | `draw_percent_scale_gauge` | STRONG INFERENCE | 0–100 vertical scale; role HYPOTHESIS. |
| `FUN_00004b32` (ID03) | `draw_split_display_box` | STRONG INFERENCE | halves A5-0x119c / A5-0x1194. |
| `FUN_00004304` (ID03) | `draw_panel_section_with_numbered_boxes` | STRONG INFERENCE mechanics | boxes 1 / 3 / 15; purpose UNKNOWN. |
| `FUN_000054fe` (ID03) | `draw_landing_gear_indicator` | STRONG INFERENCE | STR# 78 "GEAR" label, three lamp positions A5-0x1174..-0x1164. |
| `FUN_00005718` (ID03) | `dial_point_at_angle` | STRONG INFERENCE (name kept; draws an arc) | (dial, start deg, sweep deg, *x, *y): polyline on the dial rim in 5-degree steps, first point returned; degrees -> 1/0x4000 turn; cos A5-0x2118 / sin A5-0x211c, 4.12. |
| `FUN_00005158` (ID03) | `draw_arc_scale_ticks` | STRONG INFERENCE | 10-degree arc ticks via cos / sin pointers; documents unexported gauge 0x532e. |
| `FUN_000071a2` (ID03) | `remap_panel_colours_identity` | STRONG INFERENCE | identity 256-entry table -> remap_cached_panel_colours. |
| `FUN_00000038`..`FUN_000002ee` (ID02) | `ansi_div` … `ansi_strcmp` (20 C runtime functions) | PROVEN / STRONG INFERENCE | complete Ghidra C; ctype masks. |
| `FUN_0000030c`..`FUN_00000412` (ID02) | `ansi_strchr` … `ansi_strncat` (9 string functions) | PROVEN | — |
| `FUN_0000045a` (ID02) | `begin_overlay_session` | STRONG INFERENCE mechanics | UnloadSeg 4, memory + sound, hooks A5-0x1082 / -0x107e; documents end_overlay_session 0x4a4. |
| `FUN_000004c6` (ID02) | `ensure_free_memory_and_init_sound` | PROVEN | FreeMem < 500000 -> MaxMem; init_sound_system. |
| `FUN_00000930` (ID02) | `call_overlay_session_hooks` | PROVEN | hooks A5-0x1082, -0x107e, -0x107a(a, b), -0x1076. |
| `FUN_000004fc` (ID02) | `run_flight_session` | STRONG INFERENCE | game loop around the overlay. |
| `FUN_0000150a` (ID02) | `get_blended_fill_pattern` | STRONG INFERENCE | depth 1: dither of the fg / bg colour average; else gray. |
| `FUN_000016aa` (ID02) | `draw_view_frame_outline` | STRONG INFERENCE mechanics | outline of the design rect x ±3200, y 670..2400. |
| `FUN_00001dd4` (ID02) | `show_sound_error_dialog_once` | PROVEN | DLOG 139 "Sound Error", once (A5-0xd12). |
| `FUN_00001e32` (ID02) | `show_creating_panel_dialog` | PROVEN | DLOG 128 "Creating Instrument Panel". |
| `FUN_00001e68` (ID02) | `release_sound_slots` | PROVEN | 20 slots A5-0xd62: RecoverHandle(p - 0x14), HPurge, HUnlock. |
| `FUN_00001edc` (ID02) | `load_named_sound_into_slot` | PROVEN | GetNamedResource snd, memory check 0x3000, purgeable, slot store. |
| `FUN_00001f8e` (ID02) | `load_game_sounds` | STRONG INFERENCE | loads 11 named sounds into slots; memory-dependent slot 0; error dialog. |
| `FUN_000020be` (ID02) | `lock_sound_slots` | PROVEN | HLock + slot = *h + 0x14. |
| `FUN_0000212a` (ID02) | `reset_overlay_state` | HYPOTHESIS name | clears overlay data areas, calls overlay entry (A5-0x1388, TickCount). |
| `FUN_0000435e` (ID02) | `position_window_on_screen` | PROVEN | centre horizontally, 1/3 down under the menu bar, MoveWindow. |
| `FUN_00002192` (ID02) | `scan_display_devices` | STRONG INFERENCE | main / right / left monitors. |
| `FUN_000027e4` (ID02) | `configure_display_from_main_device` | STRONG INFERENCE | — |
| `FUN_000029f2` (ID02) | `refresh_display_if_changed` | PROVEN | — |
| `FUN_00002334` (ID02) | `layout_game_window_and_view` | STRONG INFERENCE | — |
| `FUN_000030fa` (ID02) | `install_menus` | PROVEN | MENU 1..5, Apple menu DRVR, DrawMenuBar. |
| `FUN_00003174` (ID02) | `update_menu_items` | STRONG INFERENCE | FrontWindow DA test, enable / disable items. |
| `FUN_00003590` (ID02) | `set_menu_item_enabled` | PROVEN | EnableItem / DisableItem, DrawMenuBar for item 0. |
| `FUN_000035bc` (ID02) | `set_view_size_option` | PROVEN | settings +0xe, relayout. |
| `FUN_0000442e` (ID02) | `position_alert_template` | PROVEN | JT $47a; centres ALRT template rect. |
| `FUN_00004582` (ID02) | `centre_window_on_screen` | PROVEN | JT $472; MoveWindow centred. |
| `FUN_00004610` (ID02) | `detach_window_palette` | PROVEN | SetPalette(window, NULL). |
| `FUN_0000462c` (ID02) | `select_palette_for_depth` | PROVEN | palette + RGB table per depth 1 / 4 / 8. |
| `FUN_00002ee4` (ID02) | `copy_pascal_string` | PROVEN | length byte + bytes. |
| `FUN_000035e4` (ID02) | `start_new_mission` | STRONG INFERENCE | roster + scenario dialogs, reset mission state, run_flight_session. |
| `FUN_00004d6a` (ID02) | `handle_update_event` | PROVEN | JT $492; Begin/EndUpdate around redraw_main_window; documents restore_screen_globals 0x4d96. |
| `FUN_00000110`..`FUN_000001c2` (ID01) | `rt_udiv32`, `rt_umod32`, `rt_sdiv32`, `rt_smod32`, `rt_sdivmod32_core`, `rt_udivmod32_core` | PROVEN | 32-bit divide runtime. |
| `FUN_00000334` (Pacific Conflict) | `any_mission_kills_recorded` | STRONG INFERENCE | 12 kill words DAT_0001b5a0+0xba..+0xd0. |
| `FUN_000003fa` (Pacific Conflict) | `load_player_fuel_and_bombs` | STRONG INFERENCE | fuel % +0xb6 -> two tanks +0x67d/+0x67e; bombs +0xb9 -> +0x67c. |
| `FUN_00000488` (Pacific Conflict) | `tally_destroyed_entity` | STRONG INFERENCE | kill counter +0xb8 + 2*type; friendly kills +0xd2. |
| `FUN_000004f8` (Pacific Conflict) | `transform_through_node_chain` | STRONG INFERENCE | hierarchical transform of an object through its parent nodes. |
| `FUN_000005fa` (Pacific Conflict) | `traverse_scene_tree` | STRONG INFERENCE | recursive scene graph walk with callback. |
| `FUN_000006a6` (Pacific Conflict) | `for_each_mission_scene_object` | STRONG INFERENCE | walk from the current mission scene root. |
| `FUN_000006ec` (Pacific Conflict) | `collect_map_features` | STRONG INFERENCE | scene visitor: land outlines (hook +0x292), type-0x70 list, facility 0x12/0x13 list. |
| `FUN_00000954` (Pacific Conflict) | `plot_mission_map_symbols` | STRONG INFERENCE | target of host A5-0x1052; plots A / B / C / T. |
| `FUN_0000b190` (Pacific Conflict) | `clip_polygon_x_min` | PROVEN | x >= DAT_00020aee. |
| `FUN_0000b242` (Pacific Conflict) | `clip_polygon_x_max` | PROVEN | x <= DAT_00020aec. |
| `FUN_0000b2f4` (Pacific Conflict) | `clip_polygon_y_min` | STRONG INFERENCE | y >= DAT_00020aea. |
| `FUN_0000b3aa` (Pacific Conflict) | `clip_polygon_y_max` | STRONG INFERENCE | y <= DAT_0001b73e. |
| `FUN_00000aba` (Pacific Conflict) | `nearest_type80_centroid_visitor` | STRONG INFERENCE mechanics | nearest face centroid of type-0x80 objects. |
| `FUN_00000bea` (Pacific Conflict) | `point_near_camera_or_type80_object` | HYPOTHESIS name | metric thresholds 0x33900 / 0x40741. |
| `FUN_00000c4c` (Pacific Conflict) | `anchor_point_visitor` | STRONG INFERENCE mechanics | kind-1 node pose or nearest ground airfield point. |
| `FUN_00000d6a` (Pacific Conflict) | `find_anchor_point` | HYPOTHESIS name | mode 0 / 1 over the scene. |
| `FUN_00000db0` (Pacific Conflict) | `ensure_handle_allocated` | STRONG INFERENCE | NewHandleClear / realloc when purged, HNoPurge. |
| `FUN_00000e0a` (Pacific Conflict) | `lock_handle_nopurge` | STRONG INFERENCE | HLock + HNoPurge. |
| `FUN_00000e32` (Pacific Conflict) | `unlock_handle_purgeable` | STRONG INFERENCE | HUnlock + HPurge. |
| `FUN_00000e5a` (Pacific Conflict) | `lock_overlay_buffers` | STRONG INFERENCE | HLock of the four panel bitmap handles. |
| `FUN_00000ea0` (Pacific Conflict) | `allocate_session_buffers` | STRONG INFERENCE | host hook A5-0x1082. |
| `FUN_00000f92` (Pacific Conflict) | `lock_session_buffers` | STRONG INFERENCE | host hook A5-0x107e. |
| `FUN_00001094` (Pacific Conflict) | `unlock_session_buffers` | STRONG INFERENCE | host hook A5-0x1076. |
| `FUN_00001112` (Pacific Conflict) | `overlay_main_entry` | STRONG INFERENCE | installs the overlay hook table A5-0x10a2..-0x104e. |
| `FUN_00003ac4` (Pacific Conflict) | `start_mission_scene` | STRONG INFERENCE | hook A5-0x109a; scene entry, anchor point, camera. |
| `FUN_0000739a` (Pacific Conflict) | `copy_player_pose_to_camera` | STRONG INFERENCE | camera position / angles from the player. |
| `FUN_00006598` (Pacific Conflict) | `overlay_frame_step` | STRONG INFERENCE | hook A5-0x107a per frame; body partly decoded. |
| `FUN_00007310` (Pacific Conflict) | `begin_flight_for_rank` | STRONG INFERENCE | hook A5-0x106e; rank table DAT_0001b2b4. |
| `FUN_00006ed6` (Pacific Conflict) | `update_view_clip_bounds` | STRONG INFERENCE | hook A5-0x109e; view half height, clip y-max DAT_0001b73e. |
| `FUN_000038f4` (Pacific Conflict) | `respawn_player_at_anchor` | STRONG INFERENCE | hook A5-0x108a; player back on the nearest airfield. |
| `FUN_0000740a` (Pacific Conflict) | `process_flight_input_and_outcome` | STRONG INFERENCE | key handler + outcome code. |
| `FUN_00006ff6` (Pacific Conflict) | `configure_renderer_for_display` | STRONG INFERENCE | — |
| `FUN_00004210` (Pacific Conflict) | `refresh_object_colours_for_depth` | STRONG INFERENCE | hook A5-0x1096; per-depth object colouring. |
| `FUN_000041ec` (Pacific Conflict) | `recolour_kind2_object` | HYPOTHESIS name | kind-2 objects: FUN_00003da8 + FUN_00003ea0. |
| `FUN_00004916` (Pacific Conflict) | `set_object_faces_bw_pattern` | STRONG INFERENCE | face +4 = host pattern table [index]. |
| `FUN_00003da8` (Pacific Conflict) | `update_object_distance_band` | STRONG INFERENCE | band +0x30 from thresholds DAT_0001b190. |
| `FUN_00003e02` (Pacific Conflict) | `update_record_distance_band` | STRONG INFERENCE | same for record +4. |
| `FUN_00003e5c` (Pacific Conflict) | `snapshot_face_colours` | HYPOTHESIS name | copy face colours after the face list. |
| `FUN_00003ea0` (Pacific Conflict) | `shade_object_faces` | STRONG INFERENCE | flat shading with light vector, haze blend at depth 8. |
| `FUN_0000147a` (Pacific Conflict) | `queue_face_palette_entry` | STRONG INFERENCE | owner table + pending ColorSpec at host +0x72. |
| `FUN_00001548` (Pacific Conflict) | `write_face_palette_slot` | STRONG INFERENCE | queue + mark slot on other monitors. |
| `FUN_0000159e` (Pacific Conflict) | `assign_face_colour` | STRONG INFERENCE | depth 1 luminance pattern, depth 4 table, depth 8 dynamic palette slot (200, round-robin). |
| `FUN_000011e6` (Pacific Conflict) | `widen_printf_format` | PROVEN | %d -> %ld, %x -> %lx into DAT_00020b4c. |
| `FUN_00001254` (Pacific Conflict) | `overlay_printf` | STRONG INFERENCE | host service +0x262 (A5-0x1126). |
| `FUN_00001294` (Pacific Conflict) | `reset_palette_owner_tables` | STRONG INFERENCE | 0x400-byte owner tables per device. |
| `FUN_00001300` (Pacific Conflict) | `init_depth8_colour_state` | STRONG INFERENCE | depth-8 set-up. |
| `FUN_0000131c` (Pacific Conflict) | `init_depth4_colour_state` | STRONG INFERENCE | depth-4 set-up from device records. |
| `FUN_0000640c` (Pacific Conflict) | `spawn_cloud_layer` | STRONG INFERENCE | hook A5-0x104e; ten camera-relative objects or retire type 0x1d. |
| `FUN_00019aa2` (Pacific Conflict) | `spawn_camera_relative_object` | STRONG INFERENCE | pool spawn at camera + offset. |
| `FUN_00019b30` (Pacific Conflict) | `follow_camera_offset` | STRONG INFERENCE | keep object at camera + offset. |
| `FUN_000018d6` (Pacific Conflict) | `overlay_initialise` | STRONG INFERENCE | RNG seed, subsystem init, light vector. |
| `FUN_00001958` (Pacific Conflict) | `heap_sbrk` | STRONG INFERENCE | arena = host A5-0x1040 work buffer; returns base + old break, no limit check, never -1. Body VERIFIED vs bytes. |
| `FUN_00001974` (Pacific Conflict) | `heap_new_size_class_block` | STRONG INFERENCE | 1 << n bytes, header = class; returns -1 (not NULL) on failure. Body VERIFIED vs bytes. |
| `FUN_0000199a` (Pacific Conflict) | `heap_add_large_block` | STRONG INFERENCE | n * 8 bytes into the large-block list; returns the cursor re-read after heap_free_coalesce. Body VERIFIED vs bytes. |
| `FUN_000019b0` (Pacific Conflict) | `heap_add_large_block_tail` | STRONG INFERENCE | false split of heap_add_large_block. |
| `FUN_00003732` (Pacific Conflict) | `overlay_init_noop` | PROVEN | empty. |
| `FUN_00003734` (Pacific Conflict) | `init_code_pointer_tables` | STRONG INFERENCE mechanics | two 2048-entry code-address tables. |
| `FUN_00003266` (Pacific Conflict) | `init_span_table_32ba` | STRONG INFERENCE mechanics | self-modifying table at 0x3242. |
| `FUN_00003412` (Pacific Conflict) | `init_span_table_3466` | STRONG INFERENCE mechanics | table at 0x33ee. |
| `FUN_000035b4` (Pacific Conflict) | `init_span_table_3608` | STRONG INFERENCE mechanics | table at 0x3590. |
| `FUN_0001771a` (Pacific Conflict) | `set_view_distance` (: actually the radar range) | VERIFIED | range + 2 * range. |
| `FUN_00017736` (Pacific Conflict) | `cycle_view_distance` | VERIFIED | Tab key: 0xc15c0 / 0x26ac0 / 0xce40. |
| `FUN_000032ba` (Pacific Conflict) | `fill_span_rows_4bit_a` | STRONG INFERENCE | depth-4 run-list span filler. |
| `FUN_00003466` (Pacific Conflict) | `fill_span_rows_4bit_b` | STRONG INFERENCE | variant b. |
| `FUN_00003608` (Pacific Conflict) | `fill_span_rows_4bit_c` | STRONG INFERENCE | variant c. |
| `FUN_000037b4` (Pacific Conflict) | `fill_span_rows_8bit` | STRONG INFERENCE | depth-8 span filler via the 2048-entry code tables. |
| `FUN_00001b4c` (Pacific Conflict) | `heap_zero_payload_tail` | STRONG INFERENCE | false split. |
| `FUN_00001be4` (Pacific Conflict) | `heap_realloc_grow_only_tail` | STRONG INFERENCE | false split. |
| `FUN_00001c04` (Pacific Conflict) | `copy_object_vertex_buffer` | STRONG INFERENCE | +0x44 -> +0x4c, 12-byte vertices. |
| `FUN_00002e12` (Pacific Conflict) | `noop_stub_2e12` | PROVEN | empty. |
| `FUN_00004e06` (Pacific Conflict) | `reset_object_to_template_pose` | STRONG INFERENCE | position from the scene template, template chain transform. |
| `FUN_00004e4e` (Pacific Conflict) | `reset_object_to_template_pose_tail` | STRONG INFERENCE | false split. |
| `FUN_00006e74` (Pacific Conflict) | `reset_span_row_lists` | STRONG INFERENCE | one background span per row. |
| `FUN_00006ece` (Pacific Conflict) | `clear_flag_00020ae4` | PROVEN | one store. |
| `FUN_0000823e` (Pacific Conflict) | `process_flight_input_tail` | STRONG INFERENCE | false split of the key handler. |
| `FUN_00008784` (Pacific Conflict) | `request_instant_replay` (was `set_state_word_1b86c`) | STRONG INFERENCE / VERIFIED | 2 / 1 by argument;  sets the pending instant-replay request DAT_0001b86c (1 airborne, 2 on the ground). |
| `FUN_00005832` (Pacific Conflict) | `dispatch_overlap_collisions` | STRONG INFERENCE | 1-D sweep over metric +/- radius, type handler +0x16; VERIFIED; walks the bit-15 list DAT_0001c1e4 (count DAT_0001c1c4), range +0xc, +0x28 scratch. |
| `FUN_000058ec` (Pacific Conflict) | `build_visible_object_list` | STRONG INFERENCE | view-space transform and pyramid cull into DAT_0001c9dc. |
| `FUN_000053f8` (Pacific Conflict) | `collect_near_objects` | STRONG INFERENCE | active array: view candidates, deactivation / retirement. |
| `FUN_0000555a` (Pacific Conflict) | `collect_far_objects` | STRONG INFERENCE (name) / VERIFIED | world array: view candidates, collision list;  DAT_0001c1e4 gets flag bit 15, not "!0x2800"; 0x2800 = mover side of the sweep; retires out-of-range objects older than 0x4b frames. |
| `FUN_00005a14` (Pacific Conflict) | `update_altitude_detail_bands` | STRONG INFERENCE | power-of-two altitude band, tables DAT_0001b214 / DAT_0001b264, land rebuild. |
| `FUN_00004958` (Pacific Conflict) | `build_land_outline_at_detail` | STRONG INFERENCE | drops vertices within tolerance, clips, de-duplicates into template vertex table. |
| `FUN_00005e28` (Pacific Conflict) | `update_ground_scatter_objects` | STRONG INFERENCE | 64 ground points DAT_0001b924, 7 object slots DAT_0001bc64, gated by +0xac and height < 0x26ad. |
| `FUN_00013346` (Pacific Conflict) | `surface_type_at_point` | STRONG INFERENCE | face code (+0x16) of nearby land face containing (x, z); default DAT_0001bda8+0x16. |
| `FUN_00013070` (Pacific Conflict) | `point_in_polygon_xz` | VERIFIED | even-odd crossing test on vertex words +2 / +10. |
| `FUN_0001310e` (Pacific Conflict) | `point_in_polygon_yz` | VERIFIED | same on +6 / +10. |
| `FUN_0001320a` (Pacific Conflict) | `project_face_vertices_xz` | VERIFIED | (v >> shift) - origin into +2 / +10. |
| `FUN_000131ac` (Pacific Conflict) | `project_face_vertices_xy` | VERIFIED | into +2 / +6. |
| `FUN_00013268` (Pacific Conflict) | `project_face_vertices_yz` | VERIFIED | into +6 / +10. |
| `FUN_00014af2` (Pacific Conflict) | `release_fractal_reference` | STRONG INFERENCE | decrements / frees shared block +0x2c; "Deactivating Fractal" message. Body VERIFIED vs bytes; printf takes only the string. |
| `_DAT_0001c1bc` (Pacific Conflict) | shared-block deferred-free flag (word) | STRONG INFERENCE | set by release_fractal_reference when a counter reaches 0; read by sort_group_parts_by_distance (frees zero-count blocks); cleared by overlay_frame_step. |
| `FUN_000132c8` (Pacific Conflict) | `point_over_face_xz` | STRONG INFERENCE | entity x / z origin, project_face_vertices_xz + point_in_polygon_xz. |
| `FUN_00014bea` (Pacific Conflict) | `carry_attached_objects` | STRONG INFERENCE | rotates / lowers or removes nearby entities of template types 7 / 8 / 0x1a / 0x1b. |
| `FUN_0001562e` (Pacific Conflict) | `clip_polygon_y_nonneg` | STRONG INFERENCE | clip against y = 0 (keep y >= 0), returns clipped flag. |
| `FUN_00015762` (Pacific Conflict) | `sink_object_shape_at_waterline` | STRONG INFERENCE | rotated / lowered template shape, faces clipped at y = 0. |
| `FUN_00014d86` (Pacific Conflict) | `step_sinking_object` | STRONG INFERENCE | timed sink steps; on completion removes riders, tallies, mission +0xce. |
| `FUN_00015580` (Pacific Conflict) | `create_sinking_controller` | STRONG INFERENCE | 0x56-byte record, +4 = DAT_0001b524[key], interval 3, object flags 0x102000. |
| `FUN_000155d8` (Pacific Conflict) | `tick_sinking_controller` | STRONG INFERENCE | step_sinking_object when +0x4c != 0. |
| `FUN_00014f48` (Pacific Conflict) | `apply_hit_to_sinkable_object` | STRONG INFERENCE | decrements hits +0x32, random list / capsize rates, schedules 15 sinking steps. |
| `FUN_0001530e` (Pacific Conflict) | `create_firing_ship_controller` | STRONG INFERENCE | 300-byte controller, 20 shots. |
| `FUN_00015356` (Pacific Conflict) | `tick_firing_ship_controller` | STRONG INFERENCE | random spawn_weapon_entity from faces with +0x17 == 1; sinking afterwards. |
| `FUN_000150c8` (Pacific Conflict) | `create_carrier_controller` (was `create_flagship_controller`) | PROVEN (identity) | create entry of definition key 0x15 (table at runtime 0x1aa5e); 0x56-byte record; first in _DAT_0001b864; renamed; type 0x15 = carrier, string "Can't find deck tag on carrier" at 0x15134. |
| `FUN_000155ec` (Pacific Conflict) | `create_basic_ship_controller` | STRONG INFERENCE | create entry of keys 0x18 / 0x17; 0x50-byte record. |
| `FUN_000092e4` (Pacific Conflict) | `advance_frame_and_tick_controllers` | STRONG INFERENCE | DAT_0001b838++, appear / expiry flags 0x40 / 0x42, ticks DAT_0001c25c via definition +2. |
| `FUN_0000947c` (Pacific Conflict) | `apply_controller_velocities` | STRONG INFERENCE | saves position, adds controller +8..+0x10 velocity. |
| `FUN_000094d2` (Pacific Conflict) | `tick_flagged_object_controllers` | STRONG INFERENCE | DAT_0001b870 == 3: ticks only objects with +5 & 4. |
| `FUN_0001429c` (Pacific Conflict) | `handle_player_contact` | STRONG INFERENCE | player overlap; contact record; definition +0x12 handler. |
| `FUN_0001358c` (Pacific Conflict) | `contact_pair_hash` | VERIFIED | low byte of a ^ (b << 2). |
| `FUN_000135a0` (Pacific Conflict) | `find_contact_record` | VERIFIED | linear probe of DAT_0001bdbc (256 slots) for (a, b). |
| `FUN_000135e8` (Pacific Conflict) | `create_shape_contact_record` | STRONG INFERENCE | 0x10 + 6 * faces record for plain shapes. |
| `FUN_0001383c` (Pacific Conflict) | `create_fractal_contact_record` | STRONG INFERENCE | 0x3e-byte record for fractal objects. |
| `FUN_00013980` (Pacific Conflict) | `fractal_height_at` | STRONG INFERENCE | height of fractal terrain at relative (x, z). |
| `FUN_00014198` (Pacific Conflict) | `handle_terrain_contact` | STRONG INFERENCE | sets player controller +0x2e ground height. |
| `FUN_00013ee0` (Pacific Conflict) | `test_object_collision` | STRONG INFERENCE | summed-range check; fractal → test_terrain_collision; shape face sign flip + FUN_0001346c → FUN_00014348. |
| `FUN_00013cdc` (Pacific Conflict) | `test_terrain_collision` | STRONG INFERENCE | a below fractal_height_at → FUN_00014348; sets controller +0x2e. |
| `FUN_00013e4e` (Pacific Conflict) | `test_proximity_collision` | STRONG INFERENCE | flag 0x100000 on both; 3/4 distance below a range;  `and.l` of both flag longs, `btst #20` [PROVEN]; bit 20 = distance-collision mode (see object flag long). |
| `FUN_00013eae` (Pacific Conflict) | `test_player_vs_type0e_proximity` | STRONG INFERENCE | player vs template type 0xe. |
| `FUN_00014348` (Pacific Conflict) | `dispatch_collision` | STRONG INFERENCE | definition +0x12 handlers; pair table DAT_0001b43c (10 × 8 bytes). |
| `FUN_0001346c` (Pacific Conflict) | `point_in_face_by_axis` | STRONG INFERENCE | projects on yz / xz / xy by axis code, point-in-polygon. |
| `FUN_00012fd2` (Pacific Conflict) | `point_in_polygon_xy` | VERIFIED | even-odd crossing test on words +2 / +6. |
| `FUN_000167f4` (Pacific Conflict) | `bullet_hits_aircraft` | STRONG INFERENCE | 1/8: damage roll + retire bullet; player hit 1/2 → _DAT_0001b842. |
| `FUN_0001665a` (Pacific Conflict) | `bullet_hits_shape` | STRONG INFERENCE | retire bullet; type 0x1b controller +0x46 = 1 at 1/16. |
| `FUN_00016724` (Pacific Conflict) | `apply_random_aircraft_damage` | STRONG INFERENCE | one random damage bit in controller +0x684 (bit 15 set from the bullet word +0x36 [UNKNOWN meaning]). |
| `FUN_000095ac` (Pacific Conflict) | `play_game_sound` | STRONG INFERENCE | priority (DAT_00024d10) play of slot n via host play_sample_on_channel. |
| `FUN_000096ae` (Pacific Conflict) | `stop_game_sound` | STRONG INFERENCE | release_channel_loop(1) when n is current. |
| `FUN_000096f4` (Pacific Conflict) | `update_game_sounds` | STRONG INFERENCE | per-frame event flags → sounds; engine sound from player +0x66a. |
| `FUN_00011c58` (Pacific Conflict) | `spawn_effect` | STRONG INFERENCE | pool object DAT_0002626e[kind], init DAT_0001b40c[kind], explosion sound countdowns, event ring DAT_000260ee. |
| `FUN_00010650` (Pacific Conflict) | `update_aircraft_damage_state` | STRONG INFERENCE | damage stages in +0x684; player bit 0 → A5-0x12b4 = 1 (Dead), Ugh. |
| `FUN_00011b96` (Pacific Conflict) | `replay_logged_effects` | STRONG INFERENCE | DAT_0001b870 = -1 while re-spawning logged effects of the current frame. |
| `FUN_00011c2c` (Pacific Conflict) | `mark_effect_log_end` | STRONG INFERENCE | 0x7fffffff frame sentinel. |
| `FUN_00011b48` (Pacific Conflict) | `register_effect_template` | VERIFIED | fills DAT_0002626e[0..3]; then create handler:= 0x11ade (+0x20 = FUN_00011afe). |
| `FUN_0001203a` (Pacific Conflict) | `init_effect_kind0_flat_ring` | STRONG INFERENCE | kind 0: 6 vertices, x / z outward velocities: water splash ring. |
| `FUN_000120ca` (Pacific Conflict) | `init_effect_kind1_column` | STRONG INFERENCE | kind 1: 3 spreading vertices, vertex 2 rising (+0x76). |
| `FUN_00011efc` (Pacific Conflict) | `init_effect_kind2_burst` | STRONG INFERENCE | kind 2: 12 vertices, jittered outward velocities. |
| `FUN_0001217e` (Pacific Conflict) | `init_effect_kind3_debris_explosion` | STRONG INFERENCE | kind 3: kind-2 burst at size / 4 + 13 vertices with 3-D velocities. |
| `FUN_00012768` (Pacific Conflict) | `tick_effect` | STRONG INFERENCE | animate DAT_0001b41c[kind]; lifetime +0x36; retire when done. |
| `FUN_000123ce` (Pacific Conflict) | `animate_effect_kind0_ring` | STRONG INFERENCE | x / z expansion; kind-1 spawn at 0x47. |
| `FUN_00012466` (Pacific Conflict) | `animate_effect_kind0_ring_tail` | PROVEN | false split of 0x123ce. |
| `FUN_00012486` (Pacific Conflict) | `animate_effect_kind1_column` | STRONG INFERENCE | vertex 2 up with gravity 0x5b; ends below 0. |
| `FUN_00012296` (Pacific Conflict) | `animate_effect_kind2_burst` | STRONG INFERENCE | velocities halved; faces darkened 6/8 at depth 8. |
| `FUN_00012528` (Pacific Conflict) | `animate_effect_kind3_debris` | STRONG INFERENCE | gravity, ground clamp; FUN_000175de / FUN_000115fc at the end. |
| `FUN_00012738` (Pacific Conflict) | `face_object_to_camera` | VERIFIED | attitude = −camera angles. |
| `FUN_000127aa` (Pacific Conflict) | `effect_pre_render_hook` | STRONG INFERENCE | definition +0xe of effects; DAT_0001b42c[kind]. |
| `FUN_000115fc` (Pacific Conflict) | `spawn_smoke_plume` | HYPOTHESIS | template DAT_000260e8; sizes +0x36 / +0x34; end frame +0x38. |
| `FUN_000115da` (Pacific Conflict) | `register_smoke_template` | VERIFIED | DAT_000260e8 = template; create handler → 0x115b0. |
| `FUN_00011670` (Pacific Conflict) | `attach_trailing_plume` | STRONG INFERENCE | plume linked to an aircraft (+0x3c), 8 trail points. |
| `FUN_000175de` (Pacific Conflict) | `spawn_ground_mark` | HYPOTHESIS | template DAT_00026660 scaled, expiry +2700 frames. |
| `FUN_0000a75e` (Pacific Conflict) | `transform_and_project_object` | STRONG INFERENCE | +0xe hook phases 1 / 2; vertices of faces with bit 0x20 → camera space → DAT_000256b2. |
| `FUN_0000a676` (Pacific Conflict) | `project_prepared_object` | STRONG INFERENCE | projects +0x4c camera-space vertices; face bits 0x60. |
| `FUN_0000ac72` (Pacific Conflict) | `render_visible_objects` | STRONG INFERENCE | per-frame draw of the visible list in three passes. |
| `FUN_00009ae0` (Pacific Conflict) | `face_is_back_facing` | STRONG INFERENCE | stored normal vs camera vector, dot < 1. |
| `FUN_00009da6` (Pacific Conflict) | `emit_faces_bsp` | STRONG INFERENCE | far child, node + chain, near child. |
| `FUN_00009d34` (Pacific Conflict) | `emit_face_chain` | STRONG INFERENCE | front-facing faces of a +0x12 chain. |
| `FUN_00009ef8` (Pacific Conflict) | `emit_faces_in_order` | STRONG INFERENCE | object +0x38 root faces with chains. |
| `FUN_00009fc4` (Pacific Conflict) | `emit_faces_unnumbered` | STRONG INFERENCE | same, without draw-order numbers. |
| `FUN_0000a2f2` (Pacific Conflict) | `submit_object_faces` | STRONG INFERENCE | output via *DAT_00020ab4; camera crossing a face → dispatch_collision. |
| `FUN_0000a512` (Pacific Conflict) | `transform_face_vertices` | STRONG INFERENCE | transform / project unmarked vertices of one face. |
| `FUN_0000b028` (Pacific Conflict) | `clip_face_near_plane` | STRONG INFERENCE | Sutherland-Hodgman at z = 5. |
| `FUN_0000a16e` (Pacific Conflict) | `output_face_colour` | STRONG INFERENCE | DAT_00020ab4 at depth 8 / 4; screen clip, FUN_00009b8c. |
| `FUN_0000a220` (Pacific Conflict) | `output_face_bw` | STRONG INFERENCE | DAT_00020ab4 at depth 1; screen clip, host add_polygon_edges. |
| `FUN_00009b8c` (Pacific Conflict) | `add_face_edges_to_rows` | STRONG INFERENCE | 0x1c-byte edge records (pool DAT_0001b76c) sorted into DAT_0001eaac[row]. |
| `FUN_0000a07e` (Pacific Conflict) | `track_ground_plane_horizon` | STRONG INFERENCE | DAT_0001bd90 corner bits, horizon edge DAT_0001bda0..94. |
| `FUN_0000b4b6` (Pacific Conflict) | `draw_sky_and_ground` | STRONG INFERENCE | horizon edge scaled to window; colours host +0x18e / +0x190 by corner bits DAT_0001bd90. |
| `FUN_0000b460` (Pacific Conflict) | `reset_background_rows` | STRONG INFERENCE | DAT_00020ad4 rows = (0, 1, DAT_0001b82a, DAT_0001daa0). |
| `FUN_00002e14` (Pacific Conflict) | `scan_convert_edge_rows` | STRONG INFERENCE | row buckets DAT_0001eaac → active edges → runs in DAT_0001b794 / 798 by draw order. |
| `FUN_0000d00c` (Pacific Conflict) | `update_view_readouts_and_overlays` | STRONG INFERENCE | readouts 0..3 cached in DAT_00025ff4, host +0x27a; else sky + HUD drawers. |
| `FUN_0001443a` (Pacific Conflict) | `sort_group_parts_by_distance` | STRONG INFERENCE | per-part distance sort, haze blend, draw-order numbers. |
| `FUN_0000c572` (Pacific Conflict) | `draw_gauge_needle` | STRONG INFERENCE | erase previous end (cache DAT_00025f4a / 92), draw via *DAT_0001da9c or host +0x272. |
| `FUN_0000c664` (Pacific Conflict) | `update_altimeter_needles` | STRONG INFERENCE | instrument type 0, two hands. |
| `FUN_0000c80c` (Pacific Conflict) | `update_airspeed_needle` | STRONG INFERENCE | type 1 from +0x62a. |
| `FUN_0000c8d6` (Pacific Conflict) | `update_direction_needle` | STRONG INFERENCE | type 6 from DAT_0001d80e. |
| `FUN_0000c948` (Pacific Conflict) | `update_climb_needle` | STRONG INFERENCE | type 3 from DAT_0001bc80 (rate of climb). |
| `FUN_0000c9c2` (Pacific Conflict) | `update_tachometer_needle` | STRONG INFERENCE | type 5 from +0x66a (engine RPM). |
| `FUN_0000ca44` (Pacific Conflict) | `update_manifold_needle` | STRONG INFERENCE | type 4 from +0x672. |
| `FUN_0000cc12` (Pacific Conflict) | `update_flaps_needle` | STRONG INFERENCE | needle 10 from +0x67b. |
| `FUN_0000ccca` (Pacific Conflict) | `update_gear_needles` | STRONG INFERENCE | needles 11..13 from +0x679. |
| `FUN_0000ce1c` (Pacific Conflict) | `update_ammo_needle` | STRONG INFERENCE | needle 15 from +0x682 (675 rounds). |
| `FUN_0000cec4` (Pacific Conflict) | `update_fuel_needles` | STRONG INFERENCE | needles 16 / 17 from +0x67d / +0x67e. |
| `FUN_00017b68` (Pacific Conflict) | `update_radar_scope` | STRONG INFERENCE | tracked objects rotated by heading into the scope rectangle. |
| `FUN_000176b2` (Pacific Conflict) | `add_radar_track` | VERIFIED | DAT_0001b51c[≤ 6] (x, z, two words, flag) when metric ≤ DAT_00026666. |
| `FUN_0001776a` (Pacific Conflict) | `reset_radar_tracks` | VERIFIED | DAT_00026672 = DAT_00026676 = 0. |
| `FUN_0000c1aa` (Pacific Conflict) | `update_heading_tape` | STRONG INFERENCE | strip at host +0x1b8 scrolled by DAT_0001d80e. |
| `FUN_0000ba2a` (Pacific Conflict) | `draw_panel_frame_lines` | HYPOTHESIS | colour runs from host +0x238..+0x258. |
| `FUN_0000fe96` (Pacific Conflict) | `aircraft_notice_object` | STRONG INFERENCE | aircraft definition +0x16; radar tracks for the player, target acquisition for AI. |
| `FUN_0000b49e` (Pacific Conflict) | `reset_overlay_display_state` | STRONG INFERENCE | reset_background_rows, reset_radar_tracks, caches. |
| `FUN_0000e0a4` (Pacific Conflict) | `aircraft_destroy` | STRONG INFERENCE | aircraft definition +0xa. |
| `FUN_0000e0ce` (Pacific Conflict) | `aircraft_create` | STRONG INFERENCE | definition +6; player = first aircraft. |
| `FUN_0000e5aa` (Pacific Conflict) | `aircraft_tick` | STRONG INFERENCE | definition +2; 75-frame replay ring at +0x36. |
| `FUN_0000fe0a` (Pacific Conflict) | `aircraft_collision` | STRONG INFERENCE | definition +0x12; damage bit 0x400. |
| `FUN_000110f4` (Pacific Conflict) | `ai_attack_or_fly` | STRONG INFERENCE | AI state 0x110d4 (+0x20). |
| `FUN_00011182` (Pacific Conflict) | `ai_fly` | STRONG INFERENCE | AI state 0x11162 (+0x20). |
| `FUN_0000dff0` (Pacific Conflict) | `init_aircraft_controller` | STRONG INFERENCE | 0x6b0 bytes; ammo 0x2a3, bombs 2, tanks def+0x1c/2, gear 0x2d. |
| `FUN_0000df5e` (Pacific Conflict) | `fill_pose_history` | VERIFIED | 75 × 0x14 ring filled with a position. |
| `FUN_0000fb2a` (Pacific Conflict) | `animate_landing_gear` | STRONG INFERENCE | aircraft definition +0xe; gear faces (+0x17 == 1) by +0x679. |
| `FUN_0000f810` (Pacific Conflict) | `player_slew_mode` | STRONG INFERENCE | state 0xf7f0 (+0x20), control-S toggle; keypad axis moves with accelerating speed. |
| `FUN_00012b66` (Pacific Conflict) | `apply_blast_damage` | STRONG INFERENCE | objects within blast radius destroyed / damaged (stack args). |
| `FUN_00018956` (Pacific Conflict) | `spawn_object_shadow` | STRONG INFERENCE | template DAT_00026768[kind] linked to owner; hidden when +0xb0 == 0. |
| `FUN_0001820a` (Pacific Conflict) | `ai_pursue_target` | STRONG INFERENCE | target pose delayed by DAT_0001b878 / 876 frames; manoeuvre +0x69a. |
| `FUN_00011db4` (Pacific Conflict) | `spawn_destruction_effect` | STRONG INFERENCE | kind 2 in the air, kind 0 on water (0x10), kind 3 on ground. |
| `FUN_00013452` (Pacific Conflict) | `surface_type_under_object` | STRONG INFERENCE | surface_type_at_point(object position). |
| `FUN_00012a2a` (Pacific Conflict) | `ordnance_tick` | STRONG INFERENCE | definition key 0xc +2; replay ring +0x60e. |
| `FUN_00012d34` (Pacific Conflict) | `ordnance_detonation` | STRONG INFERENCE | impact effect; host +0xcc / +0xd2 / +0xce; blast after 5 / 15 frames. |
| `FUN_00018c96` (Pacific Conflict) | `tick_flak_gun` | STRONG INFERENCE | definition key 0x1a +2; timed bursts at +0x5a / +0xd2. |
| `FUN_0001281e` (Pacific Conflict) | `register_ordnance_template` | VERIFIED | DAT_00026280 (spawn_weapon_entity template). |
| `FUN_000127c6` (Pacific Conflict) | `create_ordnance_controller` | STRONG INFERENCE | 0x620 bytes, flags 0x122000, pose ring +0x32. |
| `FUN_000128b6` (Pacific Conflict) | `ordnance_ballistic_step` | STRONG INFERENCE | speed +0x610, gravity -0x5b, impact bit 0x400 in +0x61c. |
| `FUN_00012f52` (Pacific Conflict) | `ordnance_collision` | STRONG INFERENCE | impact; ship target → +0x616 direct hit. |
| `FUN_00018b52` (Pacific Conflict) | `create_flak_controller` | STRONG INFERENCE | type 0x1a +6; range 0x26ac0. |
| `FUN_00018b98` (Pacific Conflict) | `destroy_flak_controller` | VERIFIED | type 0x1a +0xa; drops +0x36 / +0x32 refs. |
| `FUN_00016b4c` (Pacific Conflict) | `attach_smoke_trail` | STRONG INFERENCE | kind-0 trail; aircraft +0x68c count. |
| `FUN_00016b9e` (Pacific Conflict) | `attach_burning_trail` | HYPOTHESIS | kind-1 trail; explosion sound countdowns. |
| `FUN_00017102` (Pacific Conflict) | `attach_ground_fire` | HYPOTHESIS | FUN_000170ba object linked to owner. |
| `FUN_000173fe` (Pacific Conflict) | `spawn_debris_fragment` | STRONG INFERENCE | template DAT_0002665c, random velocity, 45 frames. |
| `FUN_00016ae8` (Pacific Conflict) | `spawn_trail` | STRONG INFERENCE | DAT_00026650[kind] + init DAT_0001b50c[kind]. |
| `FUN_0001702a` (Pacific Conflict) | `tick_trail` | VERIFIED | animate DAT_0001b514[kind]; lifetime +0x34. |
| `FUN_00016ac4` (Pacific Conflict) | `init_trail_kind0` | VERIFIED | 75 frames, state 1. |
| `FUN_00016ad6` (Pacific Conflict) | `init_trail_kind1` | VERIFIED | 75 frames, state 1. |
| `FUN_00016c6a` (Pacific Conflict) | `animate_smoke_trail` | STRONG INFERENCE | 4-vertex ribbon ±0x22 following a damaged aircraft. |
| `FUN_00016e06` (Pacific Conflict) | `animate_burning_trail` | STRONG INFERENCE | ribbon ±100 following its owner. |
| `FUN_000170ba` (Pacific Conflict) | `spawn_ground_fire_object` | VERIFIED | template DAT_00026658, +0x32 = 45. |
| `FUN_00016a78` (Pacific Conflict) | `register_trail_templates` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_00016a3a` (Pacific Conflict) | `create_trail_controller` | STRONG INFERENCE | effect-family handler (template / create / destroy / tick). |
| `FUN_00016c24` (Pacific Conflict) | `destroy_trail_controller` | STRONG INFERENCE | effect-family handler (template / create / destroy / tick). |
| `FUN_00017098` (Pacific Conflict) | `register_ground_fire_template` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_0001706a` (Pacific Conflict) | `create_ground_fire_controller` | STRONG INFERENCE | effect-family handler (template / create / destroy / tick). |
| `FUN_0001713c` (Pacific Conflict) | `destroy_ground_fire_controller` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_00017150` (Pacific Conflict) | `animate_ground_fire` | HYPOTHESIS | effect-family handler (template / create / destroy / tick). |
| `FUN_00017380` (Pacific Conflict) | `tick_ground_fire` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_000173dc` (Pacific Conflict) | `register_debris_template` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_000173a2` (Pacific Conflict) | `create_debris_controller` | STRONG INFERENCE | effect-family handler (template / create / destroy / tick). |
| `FUN_000174c4` (Pacific Conflict) | `tick_debris_fragment` | STRONG INFERENCE | effect-family handler (template / create / destroy / tick). |
| `FUN_0001759e` (Pacific Conflict) | `register_ground_mark_template` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_00017566` (Pacific Conflict) | `create_ground_mark_controller` | STRONG INFERENCE | effect-family handler (template / create / destroy / tick). |
| `FUN_000175c0` (Pacific Conflict) | `tick_ground_mark` | VERIFIED | effect-family handler (template / create / destroy / tick). |
| `FUN_000168ae` (Pacific Conflict) | `impact_one_time_in_16` | HYPOTHESIS | 1/16 chance ordnance_collision. |
| `FUN_000168d2` (Pacific Conflict) | `alloc_transformed_vertex_block` | VERIFIED | header + 12-byte points via template xform. |
| `FUN_0001691c` (Pacific Conflict) | `alloc_copied_vertex_block` | VERIFIED | same, copied. |
| `FUN_00016966` (Pacific Conflict) | `advance_route_waypoint` | STRONG INFERENCE | next waypoint within 5000. |
| `FUN_00017d16` (Pacific Conflict) | `create_aircraft_spawner_controller` | STRONG INFERENCE | key 0x12 create; object kind unknown. |
| `FUN_00017db8` (Pacific Conflict) | `destroy_aircraft_spawner_controller` | STRONG INFERENCE | releases 3 refs. |
| `FUN_00017ffe` (Pacific Conflict) | `remove_mission_target` | STRONG INFERENCE | mission 7 target list, objective +0xce. |
| `FUN_00017dd4` (Pacific Conflict) | `tick_aircraft_spawner` | STRONG INFERENCE | wave spawner, 1/512 chance when its aircraft are gone. |
| `FUN_000162ba` (Pacific Conflict) | `draw_distant_object_dots` | STRONG INFERENCE | far objects as dots via DAT_0001da80. |
| `FUN_00016128` (Pacific Conflict) | `plot_dot_depth4` | STRONG INFERENCE | nibble dot with saved background. |
| `FUN_00016230` (Pacific Conflict) | `plot_dot_bw` | STRONG INFERENCE | square via host add_polygon_edges. |
| `FUN_00015ebe` (Pacific Conflict) | `erase_dots_depth8` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00015f3e` (Pacific Conflict) | `plot_dot_depth8` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00015fb8` (Pacific Conflict) | `erase_dots_depth4` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00017780` (Pacific Conflict) | `erase_radar_blip_depth8` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00017868` (Pacific Conflict) | `erase_radar_blip_depth4` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00017948` (Pacific Conflict) | `draw_radar_blip_depth4` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00017a34` (Pacific Conflict) | `erase_radar_blip_bw` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00017a60` (Pacific Conflict) | `draw_radar_blip_bw` | STRONG INFERENCE | per-depth dot / radar blip routine. |
| `FUN_00018040` (Pacific Conflict) | `create_wave_spawner_controller` | STRONG INFERENCE | key 0x14 create; mission 7 target list. |
| `FUN_000180c8` (Pacific Conflict) | `tick_wave_spawner` | STRONG INFERENCE | key 0x14 tick; timed far-away aircraft launches. |
| `FUN_000188f4` (Pacific Conflict) | `register_shadow_templates` | VERIFIED | shadow template slots. |
| `FUN_000188ba` (Pacific Conflict) | `create_shadow_controller` | STRONG INFERENCE | 0x36-byte controller. |
| `FUN_00018942` (Pacific Conflict) | `destroy_shadow_controller` | VERIFIED | owner reference. |
| `FUN_000189d0` (Pacific Conflict) | `tick_shadow` | STRONG INFERENCE | key 5 tick; follows owner at ground height. |
| `FUN_00018bba` (Pacific Conflict) | `flak_notice_object` | STRONG INFERENCE | key 0x1a +0x16; flak target pick. |
| `FUN_0001940e` (Pacific Conflict) | `register_parachute_template` | VERIFIED | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_000193b6` (Pacific Conflict) | `create_parachute_controller` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_00019938` (Pacific Conflict) | `parachute_tick` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_0001952e` (Pacific Conflict) | `parachute_descend` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_0001951a` (Pacific Conflict) | `destroy_parachute_controller` | VERIFIED | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_0001910e` (Pacific Conflict) | `register_turret_template` | VERIFIED | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_000190c0` (Pacific Conflict) | `create_turret_controller` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_00019130` (Pacific Conflict) | `spawn_turret_on_object` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_00019394` (Pacific Conflict) | `turret_pre_render` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_00019b82` (Pacific Conflict) | `create_view_attached_controller` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_00019bbc` (Pacific Conflict) | `tick_view_attached_object` | STRONG INFERENCE | handler of definition key 0x1b / 0x1c / 0x1e. |
| `FUN_000115b0` (Pacific Conflict) | `create_plume_controller` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_000116e8` (Pacific Conflict) | `destroy_plume_controller` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_000116fc` (Pacific Conflict) | `tick_smoke_plume` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_00011a90` (Pacific Conflict) | `plume_pre_render` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_00011afe` (Pacific Conflict) | `create_effect_controller` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_00011aae` (Pacific Conflict) | `create_camera_facing_controller` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_00011ae6` (Pacific Conflict) | `face_camera_heading` | STRONG INFERENCE | handler of definition key 7 / 8 / 0xf. |
| `FUN_0000e1e6` (Pacific Conflict) | `create_enemy_fighter` | STRONG INFERENCE | aircraft definition / AI state (types 1 / 2 / 3 / 4 = player, friendly bomber, enemy bomber, enemy fighter). |
| `FUN_0000e2a4` (Pacific Conflict) | `create_friendly_bomber` | STRONG INFERENCE | aircraft definition / AI state (types 1 / 2 / 3 / 4 = player, friendly bomber, enemy bomber, enemy fighter). |
| `FUN_0000e340` (Pacific Conflict) | `create_enemy_bomber` | STRONG INFERENCE | aircraft definition / AI state (types 1 / 2 / 3 / 4 = player, friendly bomber, enemy bomber, enemy fighter). |
| `FUN_000111ae` (Pacific Conflict) | `ai_fly_bomber` | STRONG INFERENCE | aircraft definition / AI state (types 1 / 2 / 3 / 4 = player, friendly bomber, enemy bomber, enemy fighter). |
| `FUN_000111da` (Pacific Conflict) | `ai_dive_at_target` | STRONG INFERENCE | aircraft definition / AI state (types 1 / 2 / 3 / 4 = player, friendly bomber, enemy bomber, enemy fighter). |
| `FUN_000100bc` (Pacific Conflict) | `release_ai_target` | VERIFIED | AI / turret handler. |
| `FUN_000100d4` (Pacific Conflict) | `enemy_fighter_notice_object` | STRONG INFERENCE | AI / turret handler. |
| `FUN_000112e0` (Pacific Conflict) | `ai_bombing_run` | STRONG INFERENCE | AI / turret handler. |
| `FUN_0001917c` (Pacific Conflict) | `tick_turret` | STRONG INFERENCE | AI / turret handler. |
| `FUN_0000e262` (Pacific Conflict) | `spawn_enemy_fighter` | STRONG INFERENCE | spawn / plume / cloud handler. |
| `FUN_00011796` (Pacific Conflict) | `shape_free_plume` | STRONG INFERENCE | spawn / plume / cloud handler. |
| `FUN_00011940` (Pacific Conflict) | `shape_trailing_plume` | STRONG INFERENCE | spawn / plume / cloud handler. |
| `FUN_00019a54` (Pacific Conflict) | `register_cloud_templates` | VERIFIED | spawn / plume / cloud handler. |
| `FUN_00019a1a` (Pacific Conflict) | `create_cloud_controller` | STRONG INFERENCE | spawn / plume / cloud handler. |
| `FUN_0000879e` (Pacific Conflict) | `resolve_bailout_outcome` | STRONG INFERENCE | bail-out / camera / sound; VERIFIED; outcome 7; no-base odds are Dead 1/4 first, then POW 3/16. |
| `FUN_00008972` (Pacific Conflict) | `update_bailout_view` | STRONG INFERENCE | bail-out / camera / sound. |
| `FUN_000088a0` (Pacific Conflict) | `place_camera_behind_object` | STRONG INFERENCE | bail-out / camera / sound. |
| `FUN_00008abe` (Pacific Conflict) | `turn_camera_toward_point` | STRONG INFERENCE | bail-out / camera / sound. |
| `FUN_00009550` (Pacific Conflict) | `stop_all_sound_channels` | VERIFIED | bail-out / camera / sound. |
| `FUN_0000923e` (Pacific Conflict) | `apply_player_mouse_controls` | STRONG INFERENCE | player input / camera. |
| `FUN_00008ff4` (Pacific Conflict) | `begin_replay_view` | STRONG INFERENCE | player input / camera. |
| `FUN_00008c30` (Pacific Conflict) | `update_tracking_camera` | STRONG INFERENCE | player input / camera. |
| `FUN_00015bd4` (Pacific Conflict) | `register_bullet_template` | VERIFIED | bullet family / contact records. |
| `FUN_00015b92` (Pacific Conflict) | `create_bullet_controller` | STRONG INFERENCE | bullet family / contact records. |
| `FUN_00015dc8` (Pacific Conflict) | `tick_bullet` | STRONG INFERENCE | bullet family / contact records. |
| `FUN_00015e62` (Pacific Conflict) | `bullet_pre_render` | STRONG INFERENCE | bullet family / contact records. |
| `FUN_00015d78` (Pacific Conflict) | `spawn_ordnance_oriented_3ang` | STRONG INFERENCE | bullet family / contact records. |
| `FUN_0001377a` (Pacific Conflict) | `age_contact_records` | VERIFIED | bullet family / contact records. |
| `FUN_000137da` (Pacific Conflict) | `drop_contact_records_for_object` | VERIFIED | bullet family / contact records. |
| `FUN_0000c11e` (Pacific Conflict) | `begin_offscreen_drawing` | HYPOTHESIS | panel helper. |
| `FUN_0000c17e` (Pacific Conflict) | `end_offscreen_drawing` | HYPOTHESIS | panel helper. |
| `FUN_0000cac6` (Pacific Conflict) | `update_bomb_indicator` | STRONG INFERENCE | panel helper. |
| `FUN_0000cb62` (Pacific Conflict) | `update_throttle_gauge` | STRONG INFERENCE | panel helper. |
| `FUN_0001a75e` (Pacific Conflict) | `c_strlen` | VERIFIED |  (renamed from bounded_strlen in 315): panel helper. |
| `FUN_0000d3bc` (Pacific Conflict) | `draw_line_depth8` | STRONG INFERENCE | line / frame output / pose ring. |
| `FUN_0000d5b0` (Pacific Conflict) | `draw_line_depth4` | STRONG INFERENCE | line / frame output / pose ring. |
| `FUN_0000d91a` (Pacific Conflict) | `restore_line_depth8` | STRONG INFERENCE | line / frame output / pose ring. |
| `FUN_0000db60` (Pacific Conflict) | `restore_line_depth4` | STRONG INFERENCE | line / frame output / pose ring. |
| `FUN_0000d27c` (Pacific Conflict) | `mark_view_overlays_drawn` | VERIFIED | line / frame output / pose ring. |
| `FUN_0000d298` (Pacific Conflict) | `present_spans_to_window` | STRONG INFERENCE | line / frame output / pose ring. |
| `FUN_0000d34c` (Pacific Conflict) | `present_bw_frame` | STRONG INFERENCE | line / frame output / pose ring. |
| `FUN_0000df98` (Pacific Conflict) | `fill_pose_history_angles` | VERIFIED | line / frame output / pose ring. |
| `FUN_0000dfd2` (Pacific Conflict) | `fill_pose_history_flags` | VERIFIED | line / frame output / pose ring. |
| `FUN_0000bca8` (Pacific Conflict) | `copy_rect_depth4` | STRONG INFERENCE | blit / terrain helper. |
| `FUN_0000bfb0` (Pacific Conflict) | `copy_rect_depth8` | STRONG INFERENCE | blit / terrain helper. |
| `FUN_00014830` (Pacific Conflict) | `lift_object_onto_terrain` | STRONG INFERENCE | blit / terrain helper. |
| `FUN_00011486` (Pacific Conflict) | `create_spinner_controller` | STRONG INFERENCE | definition handler / radar buttons. |
| `FUN_000114b4` (Pacific Conflict) | `spin_object_heading` | VERIFIED | definition handler / radar buttons. |
| `FUN_00018a34` (Pacific Conflict) | `shadow_pre_render` | STRONG INFERENCE | definition handler / radar buttons. |
| `FUN_00017a8c` (Pacific Conflict) | `update_radar_range_buttons` | STRONG INFERENCE | definition handler / radar buttons. |
| `FUN_00012f92` (Pacific Conflict) | `create_singleton_type10_controller` | HYPOTHESIS | definition handler / radar buttons. |
| `FUN_00003cca` (Pacific Conflict) | `segment_point_min_distance` | PROVEN | from bytes; bisection of segment (start + word deltas) against a point. |
| `FUN_0000e512` (Pacific Conflict) | `compute_template_force_from_626_tail` | PROVEN | false split inside FUN_0000e4a4. |
| `DAT_0001b870` (Pacific Conflict) | instant-replay state (kept as original identifier) | STRONG INFERENCE | 0 live, 1 rewind 0x4a frames, other non-zero replaying, 3 = controller tick restricted, -1 inside replay_logged_effects. |
| `DAT_0001b86e` (Pacific Conflict) | instant-replay / end-sequence frame countdown (word; comment-only name replay_frames_left) | PROVEN (accesses) / STRONG_INFERENCE (name) | begin_replay_view = 0x69 (75 replay + 30 hold, with DAT_0001b870 = 1 and a 0x4b-frame camera glide); crash end hold = 0x1e (host +0x98 == 2, view mode 8, DAT_0001b870 = 3); update_tracking_camera subq.w each frame, <= 0x1e -> DAT_0001b870 = 3, at 0 decides the outcome (no crash -> -1; crash without parachute -> Dead; else resolve_bailout_outcome); process_flight_input_and_outcome returns to live (DAT_0001b870 = 0) when it is 0. All accesses are word ops (0x742a, 0x74f8, 0x7584, 0x75ae, 0x8efc, 0x8f6c, 0x8f72). |
| `DAT_0001b86c` (Pacific Conflict) | pending instant-replay request (word: 0 none, 1 airborne, 2 on the ground) | PROVEN (accesses) / STRONG_INFERENCE (name) | set by request_instant_replay, consumed and cleared by begin_replay_view (camera side), cleared on respawn. |
| host A5-0x12f0 (overlay host +0x98) | instant-replay state (word): 0 idle, 1 replay (File menu "Instant Replay", MENU 2 item 8 / ⌘I, or begin_replay_view), 2 crash end sequence (update_aircraft_damage_state, live) | PROVEN | MENU 2 item 8 text and handler; ID02 start_new_mission clears it; ID04 update_summary_dialog_buttons enables buttons only when 0; overlay process_flight_input_and_outcome / update_tracking_camera (reset to 0 at the end of the countdown). |
| `_DAT_0001b842` / `_DAT_0001b844` / `_DAT_0001b852` / `_DAT_0001b856` / `_DAT_0001b850` / `_DAT_0001b854` (Pacific Conflict) | sound events Hit / Ugh / Gun / Wheel / Ditch / Grass | PROVEN (slot names) | slot names from DATA 0; kept as original identifiers. |
| `FUN_000052dc` (Pacific Conflict) | `deactivate_object` | STRONG INFERENCE | type 2 frees vertex / face buffers; type 3 releases child list. |
| DAT_0001c9dc / DAT_0001c1d4 | visible object list / its count | STRONG INFERENCE | — |
| DAT_00020ac0 / _DAT_00020abc / _DAT_00020ab8 | selected span-filler routines (address − 0x20) | STRONG INFERENCE | — |
| host +0x348 (A5−0x1040) | overlay heap arena (host NewPtrClear work buffer) | STRONG INFERENCE | — |
| host +0xae (A5−0x12da) | clouds option (spawn_cloud_layer) | STRONG INFERENCE | — |
| DAT_0001d860 / DAT_0001d864 | per-frame palette-slot usage maps (swapped by overlay_frame_step) | STRONG INFERENCE | — |
| DAT_0001bd88 / -8a / -8c | light direction vector (z / y / x components) | STRONG INFERENCE | — |
| host +0xaa (A5−0x12de) | haze option | STRONG INFERENCE | — |
| DAT_0001b5a0 + 0xe (Pacific Conflict) | host A5−0x137a pixel depth (1 / 4 / 8), not a mission mode | STRONG INFERENCE |  correction. |
| DAT_0001d838 / DAT_0001d834 / DAT_0001d830 | camera position x / y / z (copied from the player) | STRONG INFERENCE | — |
| Overlay hook slots A5−0x10a2.. A5−0x104e | filled by overlay_main_entry (overlay address − 0x20) | STRONG INFERENCE | table in OVERLAY_SERVICE_TABLE.md. |
| DAT_0001b5a0 (Pacific Conflict) | pointer to the host A5 world at A5−0x1388: overlay offset k = host A5−0x1388 + k | STRONG INFERENCE | mission, fuel, bombs, kills, friendly kills, bitmap handles and service slots all agree. |
| DAT_00020aee / DAT_00020aec / DAT_00020aea / DAT_0001b73e | polygon clip rectangle x-min / x-max / y-min / y-max | STRONG INFERENCE | — |
| DAT_0001b5a0 +0xb6 / +0xb8 / +0xba.. / +0xd2 | mission fuel % / bombs / kill counters by type / friendly kills | STRONG INFERENCE | — |
| ID01 0x96 / 0xaa / 0xbe (JT $2a / $32 / $3a) | sparse word / sparse long / dense switch helpers | PROVEN | — |
| A5−0x2cc | depth of the palette currently attached | PROVEN | — |
| A5−0xc4e.. A5−0xc3e | MenuHandles of MENU 1..5 | PROVEN | — |
| HEL1 127 settings +0xe / +0x1c | view size option (1..4) / multi-monitor option | STRONG INFERENCE | — |
| A5−0x14ca / A5−0x14ae / A5−0x14aa | game window / palettes (13 and 217 entries) | STRONG INFERENCE | — |
| A5−0x137c / A5−0x137e | screen height / width (main device) | STRONG INFERENCE | — |
| A5−0x1358 / −0x1342 / −0x132c | display device records: main / right / left (0x16 bytes) | STRONG INFERENCE | — |
| A5−0x1036 | main GDHandle | PROVEN | GetMainDevice. |
| A5−0xd62 | 20 sound slots (pointer 0x14 into a locked snd handle) | STRONG INFERENCE | — |
| ID09 JT $262 / $272 / $27a / $282 / $28a | RecoverHandle / HLock / HUnlock / HPurge / HNoPurge glue | PROVEN | trap words in ID09 0x250..0x294. |
| A5−0x13ba / A5−0x13b8 | current foreground / background colour index (depth 1) | STRONG INFERENCE | — |
| A5−0x106e / −0x106a / −0x1086 | overlay hooks: start (rank) / key and event handler / optional poll | STRONG INFERENCE | — |
| A5−0x14fc / A5−0x1504 | frame counter / start tick of the flight | STRONG INFERENCE | — |
| A5−0x1082 / −0x107e / −0x107a / −0x1076 | overlay session hooks (begin / after memory / run / end) | STRONG INFERENCE | — |
| A5−0x12ee | sound enabled flag | STRONG INFERENCE | guards init_sound_system / shutdown_sound. |
| A5−0x1508 | strtok save pointer | PROVEN | — |
| A5−0x1608 | C runtime ctype class table (256 bytes) | STRONG INFERENCE | — |
| A5−0x2118 / A5−0x211c | cosine / sine function pointers (4.12, 0x4000 per turn; copies of A5−0x1062 / −0x1066) | STRONG INFERENCE | dial_point_at_angle. |
| A5−0x149e | panel design-unit scale (0.75 × half view width) | PROVEN formula | set by prepare_instrument_panel; used by scale_design_4800. |
| A5−0x14a0 | "panel store failed" flag (alert in ID04 0x432) | PROVEN | — |
| A5−0x13ae / A5−0x211e | panel configuration index (HEL2 id offset; cache entry) / configuration of the loaded bitmaps | STRONG INFERENCE | — |
| A5−0x12b0 / −0x11f6 / −0x11dc / −0x11d4 / −0x13b2 | cached panel bitmaps "Bitmap" / "HorizonInstrument" / "GyroInstrument" / "GyroFlags" / "Bitmap Cache" (HEL2 resources) | PROVEN names | AddResource in ID03 0x5b5e..0x5d44. |
| ID04 0x137a (unexported, JT $102) | `run_high_scores_dialog` | STRONG INFERENCE | — |
| ID04 0x3614 (unexported) | `track_map_bearing_and_distance` | STRONG INFERENCE | — |
| ID04 0x3976 (unexported, JT $10a) | `run_map_dialog` | STRONG INFERENCE | DLOG 137. |
| A5−0x137a | screen pixel depth (1 / 4 / 8); 1 = black and white | PROVEN arithmetic | Corrected: x / (8 / depth) byte offsets. |
| A5−0x1382 / A5−0x1378 | screen base address / rowBytes | STRONG INFERENCE | — |
| A5−0x1056 / A5−0x105a | angle (atan2-like, 1/0x4000 turns) / square-root function pointers | HYPOTHESIS | map bearing / distance. |
| HEL1 127 settings +0x26 | map scale (miles per grid square) | STRONG INFERENCE | " mi./grid" text. |
| A5−0x1052 | map object plotter function pointer (scale, callback) -> Pacific Conflict plot_mission_map_symbols (FUN_00000954) | PROVEN call / STRONG INFERENCE target | Target confirmed. |
| ID04 0x644 (unexported, JT $132) | `run_duty_roster_dialog` | STRONG INFERENCE | DLOG 130 "Duty Roster". |
| A5−0x225c | fuel load percentage (0..100) of the Scenario Selection / Refuel dialogs | STRONG INFERENCE | DITL 132 "Fuel: E F". |
| ID04 0xe70 (unexported, JT $9a) | `run_refuel_dialog` | STRONG INFERENCE | DLOG 132 runner. |
| ID04 0xc02 (unexported, JT $82) | `run_scenario_selection_dialog` | STRONG INFERENCE | DLOG 129 runner; returns mission or 0. |
| HEL1 127 settings +0x1e / +0x20 / +0x22 / +0x24 | mission / pilot index / fuel % / bombs | STRONG INFERENCE | written by the Scenario Selection runner. |
| Mission numbers 2..9 | Flight School, Bomb Base, Capture Island, Flying Fortress, Scramble!, Divine Wind, Flattop, The Duel | STRONG INFERENCE | radio item − 7; consistent with summary failure texts. |
| A5−0x12d2 / A5−0x12d0 | flight fuel load percentage / bomb count (0..2) | STRONG INFERENCE | written by run_refuel_dialog. |
| A5−0x2240 | bomb radio item list (3 words) | STRONG INFERENCE | — |
| ID04 0x2dc (unexported) | `set_radio_group_selection` | PROVEN | SetCtlValue(item == selected). |
| ID04 0x1dde (unexported, JT $152) | `draw_mission_awards` | STRONG INFERENCE | record +0x26 bits -> cicn 512–519. |
| ID04 0x1b3e (unexported, JT $15a) | `draw_rank_insignia` | STRONG INFERENCE | cicn 256 + rank. |
| ID04 0x2104 (unexported, JT $ca) | `mission_summary_filter_proc` | STRONG INFERENCE | ModalDialog filter; comment block in ID04.decomp.c. |
| ID04 0x21d6 (unexported) | `advance_mission_summary_text` | STRONG INFERENCE | state machine on A5-0x2222. |
| A5−0x2222 / −0x2230 / −0x222c | summary text state / step delay (ticks) / last step tick | STRONG INFERENCE | — |
| ID02 0x2c8 / 0x2d8; ID09 0x416 | strcpy / strcat; C-to-Pascal string in place | PROVEN | bytes. |
| A5−0x12ce | ten per-mission kill counters (one per target type) | STRONG INFERENCE | get_mission_kill_report_state; "No new kills to report." |
| A5−0x12b4 / A5−0x14c4 | current pilot status / mission-over flag | STRONG INFERENCE | — |
| A5−0xffe / A5−0xfae / A5−0xf86 | rank / pilot-status / target-type string groups | PROVEN (dump) | STR#129 slots 94-99 / 100-105 / 106-115. |
| HEL1 127 / HEL1 128 | "Hellcats Saved Settings" / "Player and Score Data" | PROVEN (dump names) | — |
| ALRT 258 "Error" ("^1 ^0.") | used by ID02 show_caution_alert_with_number | PROVEN (dump) | — |
| ID04 file 0x432 (unexported) | panel-store failure report (proposed) | PROVEN bytes | flag A5−0x14a0 → JT $462 + alert slot 1. |
| STR# 129 text | `artifacts/reverse-engineering/resources/resource_dasm_Hellcats_app/` | PROVEN (dump) | Files 0-based; game slot n ↔ file n−1. Slot 93 = out-of-memory message; slot 65 = ALTITUDE. |
| ID02 `FUN_0000001e` | `abs_long` (renamed ) | PROVEN (C) | JT $4da; used by nearest_palette_index_rgb. |
| A5−0x1614 / A5−0x161c | QuickDraw globals `white` / `black` patterns | STRONG INFERENCE | Standard QD global order below thePort (A5−0x160c). |
| low-memory $0196 | `Lvl1DT[1]` (VBL level-1 interrupt vector) | STRONG INFERENCE | Saved in A5−0xc36; replaced by A5−0x360 handler. |
| A5−0x7d0 | sound channel records [2] × 0x238 bytes | STRONG INFERENCE | Indexed by silence_sound_channel / FUN_00003d50. |
| ID02 file 0x1b42 (unexported) | `install_overlay_service_table` (proposed) | STRONG INFERENCE | 34 JT addresses → A5 table; A5−0x1040 work buffer. See OVERLAY_SERVICE_TABLE.md. |
| A5−0x1040 | overlay work buffer (HYPOTHESIS name) | PROVEN allocation | NewPtrClear(320400 or 220400) by FreeMem > 1 MB. |
| A5−0x103a | offscreen GrafPort pointer (HYPOTHESIS name) | STRONG INFERENCE | Disposed by close_and_dispose_port; created by FUN_00000d3a when 0. |
| `FUN_00004b62` (ID02, not decompiled) | `init_standard_colour_indices` (proposed) | STRONG INFERENCE | 9 grey-level lookups → A5 colour-index words (−0x11ae … −0x11f8). |
| A5−0x136e | device table [4] × 0x16 bytes (slots 1..3 used) | STRONG INFERENCE | +0 GDevice handle (SetGDevice in FUN_000048ae), +4 stored word array. |
| `FUN_00000728` (ID05) | `ansi_rand` | PROVEN | seed A5−0x6c ×0x41c64e6d +0x3039; returns (seed<<1)>>17. |
| `FUN_00000746` (ID05) | `ansi_srand` | STRONG INFERENCE | Stores arg to A5−0x6c. Caller: ID05 0x8c0 (init_protection_table, seeded by TickCount). |
| `FUN_000007f6` (ID05) | `poison_overlay_bytes` | STRONG INFERENCE | 12 × {ptr, byte} into A5−0xb4, byte:= 0xFF at base + rand % size. Called from ID08 0x246 (JT $53a) with overlay base/code size. |
| `FUN_0000085e` (ID05) | `restore_poisoned_overlay_bytes` | STRONG INFERENCE | Restores A5−0xb4 table if A5−0xbc / A5−0xc0 set. Called from ID08 0x29e (JT $55a). |
| `FUN_00000934` (ID05) | `record_code_index_equals` | STRONG INFERENCE | (s8)rec[4]*20 + (s8)rec[5] == n → word 1/0. Called from ID08 0x282/0x2b2 (JT $54a); success at 0x282 → JT $532 stub (ID05 0x8b2) A5−0xbc++. |
| `FUN_00000754` (ID05) | `encode_base26_6chars` | PROVEN | 6 chars 'A'+(v%26) right-to-left, NUL; DIVS.L #26 at 0x76c/0x784. |
| `FUN_000007a8` (ID05) | `decode_base26_6chars` | PROVEN | acc = acc*26 + ((s8)c − 'A') over 6 chars → *out. |
| `FUN_00000a62` (ID05) | `random_28bit_value` | STRONG INFERENCE | caller 0x442; see ID05.decomp.c header. |
| `FUN_00000a90` (ID05) | `pack_fields_to_code_buf68` | STRONG INFERENCE | caller 0x498; buf A5−0x68; see ID05.decomp.c header. |
| `FUN_00000b10` (ID05) | `unpack_fields_from_code` | STRONG INFERENCE | no caller found; see ID05.decomp.c header. |
| `FUN_00000b84` (ID05) | `encode_code28_to_buf54` | STRONG INFERENCE | ID05 0x4b2; ID08 0x276/0x2a6 (JT $552); see ID05.decomp.c header. |
| `FUN_00000ba8` (ID05) | `decode_code_to_long_a` | STRONG INFERENCE | no caller found; see ID05.decomp.c header. |
| `FUN_00000bc2` (ID05) | `encode_long_to_buf40` | STRONG INFERENCE | caller 0x4ce; see ID05.decomp.c header. |
| `FUN_00000bde` (ID05) | `decode_code_to_long_b` | STRONG INFERENCE | caller 0x674; see ID05.decomp.c header. |
| `FUN_000002c8` (ID05) | `code_dialog_filter` | STRONG INFERENCE | ModalDialog filter (SetPort, default-button FrameRoundRect, HiliteControl on empty item 3, Return/Enter→1, Esc→2). File 0x3ba..0x4e2 is a separate unexported code-string builder. |
| `FUN_00000160` (ID05) | `read_DATA128_pair` | STRONG INFERENCE | two longs at start of resource 128; callers ID08 0x26c (JT $582). |
| `FUN_000001bc` (ID05) | `write_DATA128_pair` | STRONG INFERENCE | two longs at start of resource 128; callers ID08 0x2c4 (JT $57a). |
| `FUN_00000214` (ID05) | `read_TEXT128_pair` | STRONG INFERENCE | two longs at start of resource 128; callers ID05 0x3f4, 0x458. |
| `FUN_00000270` (ID05) | `write_TEXT128_pair` | STRONG INFERENCE | two longs at start of resource 128; callers ID05 0x44a, 0x718. |
| `FUN_00000006` (ID05) | `center_template_rect_on_screen` | STRONG INFERENCE | GetResource(type,id) rect centred horizontally, top at mbar + 1/3 of remaining height. |
| `FUN_000000c8` (ID05) | `get_machine_screen_fingerprint` | STRONG INFERENCE | machineType, screen width/height, depth (GDevice or screenBits), 0. |
| `FUN_000004e4` (ID05) | `get_dialog_item_text_upper` | STRONG INFERENCE | GetIText → C string → upper (ctype A5−0x1608 bit 7 → ID02 0x1ce). |
| `FUN_00000560` (ID05) | `run_protection_dialog` | STRONG INFERENCE | DLOG 1000 challenge/response loop; Alert 1001 ($A985, corrected ); called from ID08 0x298 (JT $572). |
| `FUN_000008d6` (ID05) | `pick_random_protection_challenge` | STRONG INFERENCE | random entry of table *(A5−0xba)[A5−0xb6] → 3 words. |
| `FUN_000008b8` (ID05, not decompiled) | `init_protection_table` (proposed) | STRONG INFERENCE | ansi_srand(arg3); A5−0xba = arg1; A5−0xb6 = arg2; called from ID08 0x25c (JT $542) with (A5−0x1cc4, 56, TickCount). |
| A5−0x1cc4 | protection challenge table (56 × 12 bytes) | STRONG INFERENCE | Passed to init_protection_table; entries {ptr, len, w1, w2, w3}. See COPY_PROTECTION_FLOW.md. |
| A5−0x1680..−0x167a | QuickDraw `screenBits.bounds` (top,left,bottom,right) | STRONG INFERENCE | Used as screen rect in ID05 0x06/0xc8. |
| ID05 file 0x964 (unexported) | protection entry matcher (HYPOTHESIS) | PROVEN bytes | Counts matching entries of table *(A5−0xba)[A5−0xb6] into A5−0xc0; string de-obfuscated with key A5−0x2c. |
| ID02 local 0x2eaa (unexported) | `quit_application` (proposed) | STRONG INFERENCE | confirm (seg4 0x516 == 2), save prompt (seg4 0x4f0), HideWindow, ExitToShell. Menu 2 item 13 and fatal MENU-missing path. |
| `FUN_00002e36` (ID02) | `show_resource_file_error_box` | STRONG INFERENCE | "Can't open resource file." / "Click mouse to exit." dBox. |
| A5−0x14ca | `main_window` (HYPOTHESIS name) | STRONG INFERENCE | SetPort target at end of `initialize_application`; compared with update evt.message in `poll_and_dispatch_event`. |
| A5−0x1388 | `has_color_quickdraw` (HYPOTHESIS name) | STRONG INFERENCE | byte ← SysEnvRec.hasColorQD in `initialize_application`. |
| A5−0x1006 | `overlay_image_base` (HYPOTHESIS name) | PROVEN writer | Written only by ID08 `load_overlay_from_resource` (file 0xd4, aligned 0xf0/0xfe, cleared 0x226); gates overlay callbacks in ID02. |
| A5−0x1092 / −0x104e / −0x1096 | overlay callback slots (UNKNOWN names) | STRONG INFERENCE | Only read (MOVEA.L + JSR (A0)) in ID02; no d16(A5) writer in any CODE segment → filled indirectly. |
| A5−0x138a | `settings_dirty` (HYPOTHESIS name) | STRONG INFERENCE | Set to 1 by every persisted option change in `do_menu_command`; cleared by save helper 0x2da0 after WriteResource(HEL1 127). |
| A5−0x13ac / A5−0x13a8 | `hel1_127_handle` / `hel1_128_handle` | PROVEN role (resource handles) | GetResource('HEL1',0x7f/0x80) results; 0x12a / 0x500-byte defaults. |
| A5−0xf46 | `str129_string_ptrs[121]` (HYPOTHESIS name) | STRONG INFERENCE role | Written by `load_str129_string_table` slots 1..120; read by `init_string_pointer_groups`. |
| JT `$4fa(A5)` → `FUN_0000024a` (ID02) | memmove-like (not renamed yet) | STRONG INFERENCE | Overlap-safe byte copy (dst, src, n) in ID02.c:218; CODE0 jump table entry seg 2 off 0x246. |
| JT `$3a(A5)` → ID01 file 0xbe | runtime word switch helper (no Ghidra function) | PROVEN bytes | Pops return addr as table: lo, hi, default; offsets relative to their own word; zero offset → `BEQ *` hang. |
| `FUN_00000432` (ID09) | `length_prefixed_bytes_to_c_string_in_place` | STRONG INFERENCE | `ID09.c:135-142`: unsigned byte length, forward overlapping copy, zero terminator, original-pointer return. No direct callers found. C transform preserved;  bytes at ID09.bin file 0x432..0x44a match (DBRA shift loop, CLR.B terminator, return arg) — p2cstr-like. |
| `FUN_00000006` (ID08) | `load_overlay_from_resource` | STRONG INFERENCE | ID08.bin `@0x6`: A5 `$2a2/$2b2/$232/$2aa/…`; ret 0 fail / 1 ok; LOADER_CHAIN overlay candidate. |
| `FUN_00000348` (ID08) | `alloc_and_read_resource_payload` | PROVEN | ID08.bin `@0x348`: A5 `$2ca`/`$2c2` size; `$22a` alloc→`A5-0x12fc`; `$2b2` read. |
| `FUN_00000338` (ID08) | `sysbeep_and_exit_to_shell` | PROVEN | ID08.bin `@0x338`: `MOVE.W #$64,-(A7); _SysBeep ($A9C8); _ExitToShell ($A9F4)`. |
| `FUN_0000039c` (ID08) | `bootstrap_window_and_load_overlay` | PROVEN call | ID08.bin `@0x39C`: window/port traps; fourcc `'HELL'`; `JSR (d16,PC)` → `load_overlay_from_resource` `@0x6`. |
| `FUN_00000020` | `overlay_patch_template_u16_pair` | STRONG INFERENCE | Binary at overlay file offset `0x20`: `LEA $1A7D2; MOVE.W 6(A7),D0; MOVE.W D0,(A0); MOVE.W D0,$4A(A0); RTS`. Call sites pass `0x195` / `0x1d5` from mission-setup branch on `*(short*)(DAT_0001b5a0+0xe)`. Cells are +0x0C fields of adjacent `0x4A` template records. **Not** a 32-bit load-base writer. |
| `FUN_00000032` | `copy_block_return_dst` | STRONG INFERENCE | Binary @ `0x32`: saves D2, calls `FUN_0001a63e(src,dst,n)` (args reordered), returns `dst` in D0. Used throughout `FUN_00000054` after `FUN_00001a48` with lengths `0x4A`/`0x1A`/`0x1C`/`0x20`. |
| `FUN_00000054` | `overlay_init_template_pointer_tables` | STRONG INFERENCE | Capstone `@0x54`–`0x332`: Block A 4×`0x4A` keyed; Block B 16 fixed `0x1A`/`0x20`→`DAT_0001b538`…`1b574`; Block C 5×`0x1C` keyed from `$1AA5E`; Block D five `0x1A`→`DAT_0001b58c`…`1b59c`. Caller `init_mission_object_tables`. |
| `FUN_000016e2` | `init_mission_object_tables` | STRONG INFERENCE | `@0x16E2`: BSR `$54` then `instantiate_object_from_desc`/`heap_alloc`; builds count×`0x18` child table; publishes `DAT_0001d6fc`, `1bdb4`/`b0`/`ac`/`a8`/`a4`, `bc28`/`34`/`38`. |
| `FUN_00004690` | `instantiate_object_from_desc` | VERIFIED (type byte signed, extb.l) | `@0x4690`: `alloc_object_from_desc`; if `desc[1]!=0` call `*(DAT_0001b524[type]+6)(obj,type,0)` → store at `obj+8`. |
| `FUN_000045ba` | `alloc_object_from_desc` | VERIFIED | `@0x45BA`: kind 2→size `0x52`, kind 3→size `0x34` via `heap_alloc_cleared`; desc +0x16 zero-extended to +4; desc bit 13 → flag bit 20 (big-endian byte +6); unknown tags return D1. |
| `FUN_00001b6c` | `heap_alloc_cleared` | STRONG INFERENCE | `@0x1B6C`: `heap_alloc` then `heap_zero_payload`. |
| `FUN_00001b38` | `heap_zero_payload` | PROVEN | `@0x1B38`: derive payload size from heap header (`0xFF` large vs size-class); call `memzero`. |
| `FUN_0001a716` | `memzero` | PROVEN | `@0x1A716`: aligned CLR.B/CLR.L zero-fill of `nbytes` at `dst`. |
| `FUN_000044e8` | `run_simulation_tick` | PROVEN structure | `@0x44E8`: gate on `DAT_0001b5a0+0xac/+0xa8`; four entity-array passes via `dispatch_entity_tick` (path 0,0,1,1); then `FUN_00006fb8`. |
| `FUN_000044a4` | `dispatch_entity_tick` | STRONG INFERENCE | `@0x44A4`: call `apply_entity_mission_rates`; optional `entity+4` bit `0x40` from linked type word `5` vs mission `+0xB0`. |
| `FUN_0000435a` | `apply_entity_mission_rates` | STRONG INFERENCE | `@0x435A`: scale mission-table rates into `entity+0xC`; kind-2 path-0 updates `*(entity+0x48)+0x1C` slots. |
| `FUN_00005df8` | `clear_pending_entity_slots` | VERIFIED | `@0x5DF8`: for `i=0..6`, if `DAT_0001bc64[i]` non-null call `dispatch_entity_cleanup` then clear slot. |
| `FUN_0000528a` | `dispatch_entity_cleanup` | STRONG INFERENCE | `@0x528A`: skip if `flags_07&2`; else `retire_entity` or type-2 soft (`flags\|0x42`, `field_3c=DAT_0001b838` = current frame). Body VERIFIED vs bytes. |
| `FUN_000051ec` | `retire_entity` | STRONG INFERENCE | `@0x51EC`: clear b880/bc64/table; `+0x18=1e9`; `flags\|2`; null `**(+8)`; `DAT_00024cf0++`. Body VERIFIED vs bytes (capstone omits the ×8 scale of `clr.l $14(a0,a1.l*8)` at 0x5226). |
| `FUN_00005116` | `spawn_mission_pool_object` | STRONG INFERENCE | `@0x5116`: free `0x18` slot in `*(DAT_0001d6fc+0x30)`; fill xyz/att; `instantiate_mission_pool_slot`; gate on `world+0x44`. |
| `FUN_000046da` | `instantiate_mission_pool_slot` | STRONG INFERENCE | `@0x46DA`: alloc from desc; publish slot+0x14; identity; factory; rates; `04e6e` vs `DAT_0001d0e4` queue. |
| `FUN_00012840` | `spawn_weapon_entity` | STRONG INFERENCE | `@0x12840`: pool spawn via `DAT_00026280`; entity `field_610`/`61c`/`+0x20..24`. |
| `FUN_00015d20` | `spawn_ordnance_oriented` | STRONG INFERENCE | `@0x15D20`: `build_attitude_matrix_x` then `spawn_ordnance_scattered`. |
| `FUN_00015bf6` | `spawn_ordnance_scattered` | STRONG INFERENCE | `@0x15BF6`: RNG±0x20 scatter; pool `DAT_0002664a`; write vel/`0x3a`/`+0x40` matrix. |
| `FUN_0000262e` | `build_attitude_matrix_x` | PROVEN chain | `@0x262E`: `0202a`→`025d6` (X-axis sibling of `025a8`). |
| `FUN_00019430` | `spawn_bailout_parachute` (was `spawn_special_weapon_entity`; renamed ) (: actually spawns the parachute) | STRONG INFERENCE | `@0x19430`: pool `DAT_00026780`; fields `610/614/618/61c`; 0xD verts `>>3` → `622/656/68a`. |
| `FUN_0000e40c` | `fold_angle_pm_0x2000` | PROVEN | `@0xE40C`: if `>0x2000` −`0x4000`; if `<−0x2000` +`0x4000`. |
| `FUN_0001a63e` | `memmove_block` | PROVEN | `@0x1A63E`: `(src,dst,n)` overlap-aware copy; longword fast path when `n>0x19`. |
| `FUN_00001ba8` | `heap_realloc_grow_only` | PROVEN | `@0x1BA8`: if request > header capacity → `heap_calloc`+`memmove_block`+`heap_free_coalesce`. |
| `FUN_00001b84` | `heap_calloc` | STRONG INFERENCE | `@0x1B84`: `heap_alloc(a*b)` then `heap_zero_payload`. |
| `FUN_00002e08` | `abs_int` | PROVEN | `@0x2E08`: `MOVE.L 4(A7),D0` / `BGE` / `NEG.L` / `RTS`. ~49 BSR.L call sites (+ 19 `lea.l $2de8.l` runtime references). abs_int(INT_MIN) = INT_MIN. Body VERIFIED vs bytes. |
| `FUN_00002de8` | *(false entry of `FUN_00002d10`)*; callsite→`abs_int` | bytes PROVEN; callsite PROVEN (: all 17 references found by a linear byte scan are `lea.l $2de8.l` + `jsr (aN)` - the earlier note counted 19; 0x2de8 is a runtime address = file 0x2e08 = abs_int `202f0004 6c02 4480 4e75`) | `@0x2DE8`: mid-epilogue `TST D4`/`BNE` + xyz commit + `UNLK`/`RTS`. 19× `LEA $2DE8`+`JSR` push/arg/D0 look like abs; 0 direct BSR to `2DE8`. **BLOCKED** until LEA target explained. |
| `FUN_00004e6e` | `activate_near_range_object` | STRONG INFERENCE | `@0x4E6E`: kind2 list+`(36+3a)*0xC` via `$1A48`→`+0x4c/+0x44`+`04808`+flag-gated `02bd8`; kind3 child `0x18` table+`046da`; ends `03b98`. Gate for `spawn_mission_pool_object`. |
| `FUN_00004808` | `build_object_poly_buffers` | PROVEN layout | `@0x4808`: `heap_alloc` → `obj+0x48`; poly stride `0x20` from stream; index `heap_alloc(count<<1)` → `+0x18`; optional `(+6)&2` trailer; `DAT_0001daa2=1`. |
| `FUN_00002bd8` | `apply_template_chain_xform` | STRONG INFERENCE | `@0x2BD8`: walk `obj+0x24` chain; optional `0253e`+`02ada` if slot angles≠0; `01c5c` translate; null-aux commits `+0x18/1c/20`; mesh path uses count/`+0x34` shift into `param_4`. |
| `FUN_00002d10` | `apply_template_chain_xform_always` | STRONG INFERENCE | `@0x2D10`: same chain/commit as `02bd8` but always `0253e`; no `+0x34` shift; epilogue bytes falsely labeled `FUN_00002de8`. Caller `FUN_000168d2`. |
| `FUN_0000253e` | `build_attitude_matrix_3ang` | PROVEN chain | `@0x253E`: `0202a(p1,p2,p3,0)` then `finalize_attitude_matrix_3ang(out)`. 3-angle sibling of `build_attitude_matrix` (4ang). |
| `FUN_000024f8` | `finalize_attitude_matrix_3ang` | PROVEN chain | `@0x24F8`: `DAT_00020ce4=$2408`; `020e6`; `01d02($1d7a4,$1d7d4,temp)` then `01d02(temp,$1d7bc,out)`. |
| `FUN_00002428` | `finalize_attitude_matrix_3ang_alt` | PROVEN | `@0x2428`: `020e6`; `temp=1d7bc×1d7d4`, `out=temp×1d7a4`; no `$2408` tag. |
| `FUN_00002464` | `build_attitude_matrix_3ang_alt` | PROVEN chain | `@0x2464`: `0202a(…,0)` then `finalize_attitude_matrix_3ang_alt(out)`. |
| `FUN_00002ada` | `transform_int3_vecs_by_matrix3` | PROVEN | `@0x2ADA`: expand 9×s16 matrix; for each of `count` int[3] verts, 3× 64-bit dots → `(hi<<0x14)|(lo>>0xc)`. Sibling of `transform_vecs12_by_matrix3`. |
| `FUN_00001c5c` | `translate_int3_vecs` | PROVEN | `@0x1C5C`: DBRA count over int[3]; `dst = src + (dx,dy,dz)`. Sibling `scale_int3_vecs` uses `MULS.L`. |
| `FUN_00001cac` | `scale_int3_vecs` | PROVEN body | `@0x1CAC`: same loop as translate but `dst = src * (sx,sy,sz)`. No overlay absolute/BSR refs found. |
| `FUN_0000202a` | `load_attitude_angle_sincos` | PROVEN | `@0x202A`: for each of 4 angles, `cos_fixed14` then `sin_fixed14` into `DAT_0001d7fa/fc`, `f6/f8`, `f2/f4`, `ee/f0`. |
| `FUN_00001d76` | `sin_fixed14` | PROVEN / VERIFIED | `@0x1D76`: lerp on `DAT_0001ab6c[angle>>6]`; frac `&0x3F`. `DAT_0001ab6c[i] = round(4096 sin(i pi / 128))`, 256 words, exact. |
| `FUN_00001dd8` | `cos_fixed14` | PROVEN / VERIFIED | `@0x1DD8`: same as sin on `DAT_0001ad6c` (256 words, exact cosine over a full turn). |
| `FUN_00001e3a` | `acos_fixed14` | PROVEN | Independent disassembly matches bytes `0x1e3a..0x1eba`. `DAT_0001ad6c[i] = round(4096 * cos(i * pi / 128))` for `i=0..0x80`; clamp ±0x1000, binary-search, then interpolate to `0..0x2000`. |
| `FUN_00001ebc` | `atan_fixed14` | PROVEN mechanics / STRONG INFERENCE name | Independent disassembly matches bytes `0x1ebc..0x1f20`. Entries `0..126` of `DAT_0001af6c` equal `4096 * tan((i - 0x3f) * pi / 128)` within ±1; the function binary-searches and interpolates a 14-bit angle. Entry 127 is an unused non-monotonic quirk for current ratio callers. |
| `FUN_000102d6` | `atan2_fixed14` | STRONG INFERENCE | `@0x102D6`: abs(dx),abs(dy) then `atan_fixed14` + 0x1000/0x2000 quadrants → 14-bit heading. |
| `FUN_000109ba` | `apply_relative_heading_steer` | STRONG INFERENCE | `@0x109BA`: atan2 on rel +2/+6, fold, range-blend vs +0x24, smooth +0x61e, `enqueue_control_inputs_avg4`. |
| `FUN_00010558` | `enqueue_control_inputs_avg4` | PROVEN | `@0x10558`: clamp; 4-slot rings +0x644/4c/54; means → +0x666/+0x662/+0x664; gated by +0x685 bit0. |
| `FUN_00010b2e` | `steer_entity_toward_point` | STRONG INFERENCE | `@0x10B2E`: `build_relative_steer_sample` then `apply_relative_heading_steer`; target world XYZ. |
| `FUN_00010360` | `build_relative_steer_sample` | STRONG INFERENCE | `@0x10360`: range→*p5; scaled Δxyz@p6+2/6/a; body rot; attitude_from_velocity→*p7/*p8. |
| `FUN_00010cb2` | `max_ai_throttle_maybe_invert_679` | STRONG INFERENCE | `@0x10CB2`: +0x668←9; if +0x679>0 and altΔ>100 then neg +0x679. |
| `FUN_00010c2c` | `adjust_ai_throttle_vs_speed` | STRONG INFERENCE | `@0x10C2C`: (target−(+0x62a>>2)) blend → ± into +0x668 [0..9]; extremes touch +0x679 / max_ai_throttle…. |
| `FUN_00010cd8` | `invert_ai_bias_67b_if_positive` | PROVEN | `@0x10CD8`: if +0x67b>0 then neg.b +0x67b. |
| `FUN_00010b84` | `ai_bootstrap_climb_phase` | STRONG INFERENCE | `@0x10B84`: init biases; throttle 9; pitch fold(0x2c0−att); enqueue; ret altΔ>2000. |
| `FUN_00010ce8` | `tick_ai_climb_then_waypoint` | STRONG INFERENCE | `@0x10CE8`: +0x616 script; phase0 climb else waypoint+throttle+steer; `update_aircraft_entity`. |
| `FUN_00010d68` | `ensure_ai_script_1b2e0_tick` | STRONG INFERENCE | `@0x10D68`: alloc script from `DAT_0001b2e0`, word1=0x9d8; `tick_ai_climb_then_waypoint`. |
| `FUN_00010da8` | `ensure_ai_script_1b310_tick` | STRONG INFERENCE | `@0x10DA8`: `DAT_0001b310`, word1=0xd5c; then tick. |
| `FUN_00010de8` | `ensure_ai_script_1b340_tick` | STRONG INFERENCE | `@0x10DE8`: `DAT_0001b340`, word1=0x9d8; then tick. |
| `FUN_00010e28` | `ai_script_try_fire_burst` | STRONG INFERENCE | `@0x10E28`: after [0x1ab]≤time, fire via `spawn_weapon_entity` until +0x67c==0 → return 1. |
| `FUN_00010ecc` | `tick_ai_1b310_approach_fire` | STRONG INFERENCE | `@0x10ECC`: `ensure_ai_script_1b310_tick`; script 1→2 on approach; 2→3 on fire-burst done. |
| `FUN_00010f68` | `tick_ai_1b370_mission` | STRONG INFERENCE | `@0x10F68`: script `DAT_0001b370`; phases climb/fire/waypoint/chase player; `update_aircraft_entity`. |
| `FUN_00019fba` | `try_begin_landing_approach` | STRONG INFERENCE | `@0x19FBA`: `find_nearest_runway_approach_ends`+range → `DAT_000267xx` glide; +0x32=`0x1A186`; ret 0/1. |
| `FUN_00019c5e` | `find_nearest_runway_approach_ends` | STRONG INFERENCE | `@0x19C5E`: nearest type2/0x200 pad ('p',4); two XYZ ends; 0 if score<0x40740. |
| `FUN_00019c26` | `store_xyz_asr` | PROVEN | `@0x19C26`: ASR x/y/z by s into A1 dest; used with entity +0x34 scale. |
| `FUN_0001a1a6` | `tick_landing_approach_glide` | STRONG INFERENCE | `@0x1A1A6`: consume `DAT_000267xx` glide; steer/throttle; restore +0x32 on +0x63e. |
| `FUN_00000354` | `probe_nearest_facility_kind` | PROVEN | `@0x0354`: nearest pool entity kind 0x12/0x13 → flags 0x100/0x200 (stack entity arg; Ghidra void wrong). |
| `FUN_00003c48` | `approx_dist3_from_abs` | PROVEN | `@0x3C48`: max+(a+b)>>2 on abs components in D0/D1/D3. |
| `FUN_00003c68` | `approx_dist3_xyz` | PROVEN | `@0x3C68`: six stack XYZ; abs Δs then same combine. |
| `$1A186` | *(false mid → `tick_landing_approach_glide`)* | BLOCKED | `0x1A1A6−0x20`; literal stored by `try_begin_landing_approach`. |
| `FUN_00001d02` | `matmul3x3_s16` | PROVEN | `@0x1D02`: 3×3 s16 `out=left×right`, each element 3×`MULS.W` then `ASR #12` (floor). Body VERIFIED vs bytes; attitude matrix = R4·Rz·Rx·Ry applied as v·M. |
| `FUN_000020e6` | `fill_attitude_rotation_bases` | PROVEN layout | `@0x20E6`: expand sincos pairs 1–3 into bases at `DAT_0001d7d4` / `1d7bc` / `1d7a4` (≈Rx/Ry/Rz, `0x1000`=1). |
| `FUN_000021a0` | `fill_attitude_rotation_basis_4` | PROVEN layout | `@0x21A0`: angle4 (`1d7ee/f0`) → `DAT_0001d78c` as ≈Ry `[[c,0,s],[0,1,0],[-s,0,c]]`. |
| `FUN_00002562` | `finalize_attitude_matrix_4ang` | PROVEN | `@0x2562`: `out=(1d78c×1d7a4)×1d7d4×1d7bc` via three `matmul3x3_s16`. |
| `FUN_000021e0` | `fill_attitude_rotation_basis_4_rx` | PROVEN layout | `@0x21E0`: angle4 → `DAT_0001d78c` as ≈Rx `[[1,0,0],[0,c,-s],[0,s,c]]`. |
| `FUN_000020a0` | `load_attitude_angle_sincos_5_6` | PROVEN | `@0x20A0`: ang5→`1d7ea/ec`, ang6→`1d7e6/e8` via `cos_fixed14`/`sin_fixed14`. |
| `FUN_00002220` | `fill_attitude_rotation_bases_5_6` | PROVEN layout | `@0x2220`: `1d774`≈Rx from `1d7ea/ec`; `1d75c`≈Ry from `1d7e6/e8`. |
| `FUN_000025d6` | `compose_attitude_matrix_x` | PROVEN | `@0x25D6`: tag `$2468`; `fill_attitude_rotation_bases` + `_basis_4_rx` + three `matmul3x3_s16` (same product as `finalize_attitude_matrix_4ang`). |
| `FUN_00002488` | `compose_attitude_matrix_x_alt` | PROVEN | `@0x2488`: `020e6`+`021e0`; `((1d7bc×1d7d4)×1d7a4)×1d78c`; no `$2468`. |
| `FUN_000024d6` | `build_attitude_matrix_x_alt` | PROVEN chain | `@0x24D6`: `0202a(a,b,c,d)` then `compose_attitude_matrix_x_alt(out)`; no arg shuffle. |
| `FUN_00002654` | `compose_attitude_matrix_6ang` | PROVEN | `@0x2654`: tag `$26e0`; `020e6`+`021e0`+`02220`; five `matmul3x3_s16` over `1d774/75c/78c/7a4/7d4/7bc`. |
| `FUN_000026cc` | `build_attitude_matrix_6ang` | PROVEN chain | `@0x26CC`: `0202a` + `load_attitude_angle_sincos_5_6` + `compose_attitude_matrix_6ang`. |
| `FUN_00002700` | `compose_attitude_matrix_6ang_alt` | PROVEN | `@0x2700`: same fills as 6ang; five matmuls reversed; no `$26e0`. |
| `FUN_0000276e` | `build_attitude_matrix_6ang_alt` | PROVEN chain | `@0x276E`: `0202a` + `load_attitude_angle_sincos_5_6` + `compose_attitude_matrix_6ang_alt`. |
| `FUN_000027a2` | `invoke_tagged_attitude_compose_neg_sins4` | PROVEN | `@0x27A2`: NEG.W sins `1d7fc/f8/f4/f0`; JSR through `DAT_00020ce4` (`$2408`/`$2468`/`$26e0`). |
| `FUN_000027cc` | `invoke_tagged_attitude_compose_neg_sins6` | PROVEN | `@0x27CC`: NEG.W sins `1d7fc/f8/f4/f0/ec/e8`; JSR through `DAT_00020ce4`. |
| `FUN_0000229e` | `build_attitude_matrix_from_dir_roll` | PROVEN math | `@0x229E`: isqrt dir → sincos slots → two `matmul3x3_s16`; hosts tag `$2408` at matmul PEA. |
| `DAT_00020ce4` | `attitude_compose_tag` (code ptr) | PROVEN use | `$2468`/`$26e0` secondary entries; `$2408` literal mid-`0229e` but `≡ finalize_…_3ang_alt−0x20` — A890 A6 check favors +0x20 false-address reading. |
| `FUN_00003b98` | `update_object_camera_metric` | PROVEN | `@0x3B98`: abs(`+0x18/1c/20` − `d838/834/830`); `metric=max+((a+b)>>2)` → `obj+0x10` and D0. |
| `FUN_00003c00` | `compute_camera_abs_metric` | PROVEN | `@0x3C00`: abs(x/y/z − `d838/834/830`); same metric; returns D0 only (no `+0x10` store). |
| `FUN_00003be0` | *(false mid-`update_object_camera_metric`)* | BLOCKED (bytes) | `@0x3BE0` = first axis-swap inside `@0x3B98`; not a real entry. Its only reference, `lea.l $3be0.l` at 0xbb8 (nearest_type80_centroid_visitor), is a RUNTIME address = file 0x3c00 = `compute_camera_abs_metric` [PROVEN]. |
| `FUN_00001d56` | *(false mid-`matmul3x3_s16`)*; callsite→`sin_fixed14` | BLOCKED | `@0x1D56` = `$1D76−0x20` (ASR inside matmul). |
| `FUN_00001db8` | *(false mid-`sin_fixed14`)*; callsite→`cos_fixed14` | BLOCKED | `@0x1DB8` = `$1DD8−0x20`. |
| `FUN_00006fb8` | `reset_distance_base_globals` | STRONG INFERENCE | `@0x6FB8`: six `MOVE.L #$05F5E100` to `DAT_0001d710/14/18/1c/20/24`. |
| `FUN_0000e792` | `update_aircraft_entity` | STRONG INFERENCE | Blocks 0–7c; Block1 Capstone@E8A0 links avg4→662/666. Callers: climb/waypoint/AI ticks — not sim tick. |
| `entity+0x662` | `ctrl_avg_pitchish` (from avg4 p3) | STRONG INFERENCE | Filled by `enqueue_control_inputs_avg4`; jittered if `flags_685` bit2. |
| `entity+0x666` | `ctrl_avg_heading` (from avg4 p4) | STRONG INFERENCE | Filled by avg4; jittered if `flags_685` bit3; force 0xFF80 if +0x684 bit0. |
| `entity+0x685` | `flags_685` | PROVEN | bit0 gates avg4; bit2/3 RNG jitter; bit0 of +0x684 clears/forces controls. |
| `FUN_0000e372` | `isqrt_floor` | PROVEN | `@0xE372`: binary-search floor sqrt on `[0,0x7FFF]`; signed input, result min(floor(sqrt(x)), 0x7FFE), 0 for x < 0. Body VERIFIED vs bytes. |
| `FUN_0000e3b2` | `acos_scaled_dot3` | PROVEN | `@0xE3B2`: `(dot3>>4)/((p4*p8)>>16)` then `acos_fixed14`; 0 if denom 0. |
| `$E352` / `LAB_0000e350_2` | *(false)*; callsite→`isqrt_floor` | BLOCKED | `@0xE352=$E372−0x20`; mid-BSR garbage; LEA @0x22CC + table `$32E` @0x11C4. |
| `FUN_00001f22` | `attitude_from_velocity` | STRONG INFERENCE | `@0x1F22`: velocity → two 14-bit attitude outs via `01ebc`/`01e3a`. |
| `FUN_00011564` | `overlay_rng_next` | PROVEN | `@0x11564`: additive table RNG: cursor `DAT_00026008`, ring of 55 longs `0x2600C…0x260E7`, x[n] = x[n-1] + x[n-32]; returns bits 31..16 zero-extended. VERIFIED vs bytes. |
| `FUN_000114ca` | `overlay_rng_mul_mix` | PROVEN | `@0x114CA`: 32-bit product (a*b mod 2^32) built from 16-bit halves; table fill factor `0x1DF5E0D`. VERIFIED vs bytes. |
| `FUN_0001150a` | `overlay_rng_init` | PROVEN | `@0x1150A`: seed + LCG fill x[i] = x[i-1]*0x1DF5E0D + 1 (0x36 entries) + cursor `0x260E4` + 10000× next. VERIFIED vs bytes (incl. tail 0x11544). |
| `FUN_00011544` | `overlay_rng_warmup_epilogue` (bytes) | PROVEN bytes | `@0x11544`: Ghidra-split init tail. **Call sites** treated as `overlay_rng_next` **[INFERRED]**. |
| `FUN_0000e4a4` | `compute_template_force_from_626` | PROVEN algo | `@0xE4A4`: template coeffs `+0x26..+0x34` × `movement_626` / `0x67b`; may set `field_19e=0xC`. |
| `FUN_000025a8` | `build_attitude_matrix` | PROVEN chain | `@0x25A8`: `0202a`→`020e6`→`021a0`→`02562` into out matrix. |
| `FUN_00002802` | `transform_int3_vecs_asr_by_1d744` | PROVEN | `@0x2802`: count× (ASR.L shift, ×`DAT_0001d744` 3×3, +0x800>>12) int3→int3. |
| `FUN_000028a6` | `rotate_int3_vecs_by_3ang` | PROVEN chain | `@0x28A6`: `build_attitude_matrix_3ang` then `transform_int3_vecs_by_matrix3`. |
| `FUN_000028dc` | `transform_vecs12_by_matrix3` | PROVEN | `@0x28DC`: count× transform shorts at +2/+6/+10 by 3×3 (`+0x800>>12`). |
| `FUN_00002976` | `transform_vecs12_to_int3_by_matrix3` | PROVEN | `@0x2976`: same as `028dc` but MOVE.L int3 outs (`+0x800>>12`). |
| `FUN_00002a0e` | `transform_listed_object_vecs12_by_1d744` | PROVEN | `@0x2A0E`: walk `1c9dc` objs; ASR `+0x32`; ×`1d744`; store vecs12 at `+0x4c`. |
| `FUN_00002aba` | *(false mid-`transform_listed_object_vecs12_by_1d744`)* | BLOCKED (bytes) | `@0x2ABA` = `move.w d0,$a(a1)` inside @0x2A0E loop. Its call sites use `lea.l $2aba.l`, a RUNTIME address = file 0x2ada = `transform_int3_vecs_by_matrix3` [PROVEN, e.g. transform_through_node_chain 0x566]. |
| `FUN_0000e42a` | `table_lerp_1b2c0` | PROVEN algo | `@0xE42A`: banded lerp on `DAT_0001b2c0`; input typically `*(world+0x1c)`. |
| `FUN_0000e468` | `damp_short_if_below_0x200` | PROVEN | `@0xE468`: if delta&lt;`0x200`, subtract `((0x200−delta)*v)>>12` from short. |
| `FUN_0000e570` | `scale_template_field_38` | PROVEN | `@0xE570`: `*out = template[+0x38] * (0x551a/((in+0x105)>>3)) >> 8`. |

## Globals / data

| Original symbol | Recovered name | Confidence | Evidence |
|---|---|---|---|
| `DAT_0001a7d2` | `template_rec_a_field_u16` | STRONG INFERENCE | Absolute u16; written only via `FUN_00000020`; file offset `0x1a7d2`; `+0x0C` in a `0x4A` record near `s_GRAPHIC_SIMULATIONS_...` (`0x1a77c`). Initial image value `0x0151`. |
| `DAT_0001a81c` | `template_rec_b_field_u16` | STRONG INFERENCE | `DAT_0001a7d2 + 0x4A`; same store instruction `MOVE.W D0,$4A(A0)`. Initial image value `0x0151`. |
| `DAT_0001b524` | `template_ptr_table_base` | STRONG INFERENCE | `LEA $1B524,A5` in `FUN_00000054`; indexed by sign-extended u16 record keys (`MOVEA.W (A2),A0` then `(A5,A0.L*4)`). Sparse ID-keyed pointer table. |
| `FUN_000019d0` | `heap_free_coalesce` | STRONG INFERENCE | Binary `@0x19D0`–`0x1A66`: free payload to size-class list (class byte at ptr-4, heads `DAT_00020c64`+class*4) or coalesce into the address-ordered large-block ring (header ptr-8 = size in 8-byte units, next; unsigned compares); cursor `DAT_00020c60` = predecessor block. Body VERIFIED vs bytes. |
| `FUN_00001a48` | `heap_free_epilogue_cursor` | PROVEN | Mid-label `@0x1A48` of `FUN_000019d0`: `MOVE.L A1,$20C60`; `BRA $1A64`; pop A2; `RTS`. **Not** an allocator. Kind2 `@0x4ED8` + `@0xB572` still `LEA $1A48`+`JSR` then take D0 — **[INFERRED]** LEA off-by `+0x20` vs `heap_alloc`. |
| `FUN_00001a68` | `heap_alloc` | PROVEN prologue | `@0x1A68`: `MOVEM D2-D3/A2`; size `$10(a7)`; bins/`01974`/`0199a`; D0=payload. Godot stand-in for kind2/B572 call sites. Body VERIFIED vs bytes: classes 2..5 = 4/8/16/32-byte blocks (4-byte header), larger requests first-fit from the ring in 8-byte units, carved from the tail of the free block; NULL on failure. |
| `DAT_00020c60` | `heap_roving_cursor` | STRONG INFERENCE | Large-block freelist cursor; written at `@0x1A48` / read throughout alloc/free. |
| `DAT_00020c64` | `heap_size_class_bins` | STRONG INFERENCE | Array of freelist heads indexed by size class (×4). |
| `DAT_0001b85c` (Pacific Conflict) | carried-pair count (word) | PROVEN (use) | cleared every frame by overlay_frame_step; incremented by the unexported 0x15154 handler. |
| `DAT_0001b860` (Pacific Conflict) | carried-pair array, 8 bytes {carrier object, rider object} | PROVEN (layout) / STRONG_INFERENCE (meaning) | rider metric biased by carrier extent around controller +0x54 before the world sort. |
| `DAT_0001b85a` (Pacific Conflict) | carried-pair capacity (word, grows by 4) | PROVEN | 0x152a0. |
| `DAT_0001c1c0` (Pacific Conflict) | visible-list count before world objects (word) | PROVEN (value) | = low word of DAT_0001c1d4 after collect_near_objects. |
| `unexported 0x15154` (Pacific Conflict) | `carrier_deck_contact` (comment-only reconstruction) | STRONG INFERENCE (name) / PROVEN (body) | definition key 0x15 slot +0x12; deck face = tag 1 (face +0x17), deck height in controller +0x54; sets aircraft controller +0x2e / +0x2c, +0x63f (tag 3), appends carried pair. |
| carrier controller +0x50 / +0x52 / +0x54 (Pacific Conflict) | deck face index / tag-3 face index / deck height (words; -1 = not found) | PROVEN (layout) | 0x15178..0x15200. |
| aircraft controller +0x63f / +0x640 (Pacific Conflict) | arrest request (byte, per frame) / arrest latch (byte: 0 none, 1 braking -0xB6 per frame, 2 stopped) | PROVEN (flow) / STRONG_INFERENCE (arresting wire) | 0x15286 sets +0x63f over carrier tag-3 face; 0xf420 latches; 0xeffe brakes; 0xf01a stop; 0xf478 clear airborne; 0xf47c clears +0x63f. Replaces the "stall latch / field_190" reading. |
| `DAT_0001b868` (Pacific Conflict) | `player_landing_state` (comment-only name) | STRONG INFERENCE (name) / PROVEN (values, word) | 0 airborne/reset, 1 touchdown, 2 stopped; consumed by process_flight_input_and_outcome when engine off (0x8110). |
| face +0x16 / aircraft controller +0x2c (Pacific Conflict) | surface code (packed face byte +9 high nibble; low nibble = face tag +0x17): 0x10 water, 0x20 ?, 0x30 / 0x60 deck-type hard (carrier decks), 0x40 grass, 0x50 ?, 0x70 runway, 0x80 unused by compares | PROVEN (values) / STRONG_INFERENCE (0x10, 0x40, 0x70) / UNKNOWN (0x20, 0x50, 0x60 identity) | table at surface_type_at_point; 0x30/0x60/0x70 valid landings; 'p' quads = runway approach ends. |
| definition keys 0x12 / 0x13 (Pacific Conflict) | enemy air base / friendly air base (aircraft spawners) | PROVEN (code mapping 0x12->0x100, 0x13->0x200) / STRONG_INFERENCE (enemy / friendly) | probe_nearest_facility_kind; POW on landing near 0x100; friendly kill and runway guidance near 0x200. |
| `_DAT_0001b87a` (Pacific Conflict) | `player_abandoned_intact_aircraft` (comment-only name, word) | PROVEN (writer, readers) / STRONG_INFERENCE (name) | set 1 at 0xf766 when the player bails out with no damage bits and fuel; read by resolve_bailout_outcome and update_aircraft_damage_state -> Discharged (4). Never cleared in code (3 references) [UNKNOWN reset]. |
| aircraft controller +0x677 (Pacific Conflict) | bail-out state (byte): 0 none, 1 requested, 2 parachute spawned | PROVEN | clr 0x39ec (respawn); 1 from the 'J'/'j' key (0x7d08: airborne +0x63e == 0, _DAT_0001b874 == 0) or AI (0x1093c: damage word bit 8, rng & 0x1f == 0, state handler +0x32 != 0x111ba, host +0x90 != 2, not the player); 2 at 0xf722 after spawn_bailout_parachute, which also sets word +0x684 bit 0 (byte +0x685 bit 0 = pilot gone, the spawn gate). |

## Aircraft status / damage word +0x684

Big-endian word. Byte +0x684 holds bits 8–15 and byte +0x685 bits 0–7, so a byte
test `btst #n,$684` means word bit n + 8. Word +0x686 is last frame's copy
(0x109ae). Evidence: an instruction scan of the overlay for $684..$687 operands.

| Bit | Mask | Writers | Readers | Meaning | Certainty |
|---|---|---|---|---|---|
| 0 | 0x0001 | apply_random_aircraft_damage (roll < 6); spawn path 0xf71c | 0x9246, 0xf6e6, 0x10570, 0x1094a | pilot hit / pilot gone (Ugh sound; blocks a second parachute) | PROVEN flow / STRONG_INFERENCE |
| 1 | 0x0002 | damage roll < 0x2b (37 / 256, the most likely hit) | update_aircraft_entity 0xf794 | FUEL LEAK: 1/64 per frame, -1 unit from a random non-empty tank | PROVEN flow / STRONG_INFERENCE |
| 2 | 0x0004 | damage roll < 0x38 | 0xe8a0 | ELEVATOR damage: +0x662 += rng & 0x7f - 0x40, clamp ±0x200 | PROVEN flow / STRONG_INFERENCE |
| 3 | 0x0008 | damage roll < 0x45 | 0xe8e6 | AILERON damage: +0x666 jitter, clamp ±0x140 | PROVEN flow / STRONG_INFERENCE |
| 4 | 0x0010 | damage roll < 0x51 | 0x7fbc, 0xf652, 0x191c2 | guns damaged (Gun sound gate) | STRONG_INFERENCE |
| 5 | 0x0020 | damage roll < 0x5e; tick_wave_spawner 0x1818a | 0x97e4 (gear sound), 0xf576 / 0xfb08 (gear step) | LANDING GEAR JAMMED: gear +0x679 cannot step 1..0x2c towards 0x2d (down) and its sound is suppressed; retraction (negative values) still runs | PROVEN flow / STRONG_INFERENCE |
| 6–9 | 0x03c0 | first heavy roll -> 0x40; 0x200 promoted to 0x100; cleared with mask 0xfc3f (0xe64e, 0x107fe) | tick_smoke_plume (0x100), AI bail-out (0x100), engine model (0x80 halves the manifold target; 0x100 / 0x200 zero it) | damage ladder (per frame): 0x40 heavy hit (smoke trail; 1/2 -> 0x80 or 0x200) -> 0x80 engine damaged (1/4 -> 0x200) -> 0x200 engine out (until the next heavy hit) -> 0x100 on fire (trailing plume, AI bail-out, elevator 0 / aileron -0x80; 1/2 -> 0x400 destroyed); word +0x688 = ladder freeze timer | PROVEN ladder and engine effect / STRONG_INFERENCE names |
| 1–9 | 0x03fe | — | landing / ditch / bail-out outcomes | "aircraft damaged" | PROVEN use |
| 10 | 0x0400 | hard landing 0xf136 / 0xf3a2, aircraft_collision, apply_blast_damage | 0x8fa0, 0xe722, 0x1077a | crashed / destroyed | STRONG_INFERENCE |
| 11 | 0x0800 | crash at the end of update_aircraft_entity (0xf7ea / 0xf7f0: status = (s & 0x8000) \| 0x900, state handler +0x32 = 0xe772 = update_aircraft_entity) | update_aircraft_entity early exit (0xe80e: rests at ground - 0x16, jitter, engine off); surface 0x20 bad-contact skip (0xf372); update_aircraft_damage_state (0x1070c / 0x10740 / 0x10796; request_instant_replay(!bit 11)) | WRECKED ON THE GROUND (0x900 = wreck + burning) | PROVEN flow / STRONG_INFERENCE |
| 12 | 0x1000 | water contact 0xe832 / 0xf384; cleared on leaving the ground 0xf0d8 | 0x8066 (ditch outcome), 0xef90, 0x108da | in water | STRONG_INFERENCE |
| 13 | 0x2000 | set while the gear retracts (+0x679 < 0, 0xf5a0), cleared while it extends (0xf588) | aircraft_tick replay 0xe628 / 0xe6d4 (gear = 0x2d when clear, 0 when set; on a change, re-derives the gear direction from the sign) | GEAR LEVER UP | PROVEN flow / STRONG_INFERENCE |
| 14 | 0x4000 | aircraft_create 0xe11a, respawn (= 0x4000), key 'M' 0x7af6; cleared by keys '0'..'9' (0x79a6) and the throttle step (0x7df0) | 0x7de4, 0x82b6 (refuel snapshot), 0xeb5c, update_aircraft_entity (with +0x66e == 0 clears engine-running +0x669) | ENGINE SWITCHED OFF | PROVEN flow / STRONG_INFERENCE name |
| 15 | 0x8000 | apply_random_aircraft_damage when the bullet's +0x36 != 0; bullet +0x36 = 1 only for rounds fired by the player (update_aircraft_entity gun path, `psVar11[0x1b] = 1`) | kept by andi #$8000 at 0xf7ea (the only bit to survive a crash); no explicit test found | HIT BY THE PLAYER (kill attribution); its consumer is not yet identified | PROVEN writer chain / STRONG_INFERENCE |

## Rejected / superseded interpretations

| Claim | Status | Reason |
|---|---|---|
| `FUN_00000020` sets overlay load base/handle into `DAT_0001a7d2` / `DAT_0001a81c` | SUPERSEDED | Argument and cells are 16-bit; in-overlay callers pass small immediates `0x195`/`0x1d5`, not a pointer/base. |

## Notes on Ghidra artifacts

| Location | Artifact | Correction in `.decomp.c` |
|---|---|---|
| `FUN_00000054` copy length | `pcVar5 = FUN_00000020` | Replaced with `(code *)0x20` — function address equals byte count 32. |

## Signature corrections

| Symbols | Ghidra signature | Corrected | Confidence | Evidence | Downstream |
|---|---|---|---|---|---|
| create_*_controller (16 functions, see DECOMPILATION_PROGRESS ) | `void f(...)` | returns the new controller (`uint *`) in D0 (applied in the semantic C for spinner / plume / camera_facing / basic_ship / firing_ship / sinking / bullet / trail / ground_fire / debris / ground_mark / shadow / flak / cloud / view_attached / singleton_type10: all void ones done) | PROVEN | D0 = heap_alloc_cleared result untouched to RTS; instantiate_object_from_desc stores it at object +8 | Godot `sim_core.gd` `_call_fun_00004690` / create handlers: review |
| point_over_face_xz (FUN_000132c8) | `void` | returns int (point_in_polygon_xz result; applied in the semantic C) | PROVEN | D0 untouched after the last bsr; call sites 0x15236 / 0x1527a test D0 | none found in godot/ |
| surface_type_under_object (FUN_00013452) | `void` | returns the surface code (applied in the semantic C: `int`, returns the call) | PROVEN | bsr surface_type_at_point then RTS; callers use D0 at 0xf148 / 0xf1d0 / 0x11e04 | godot sim_core.gd / flight_math.gd reference FUN_00013452: review |
| begin_offscreen_drawing (FUN_0000c11e) | `void` | returns the host +0x286 result (previous port?; applied in the semantic C as `undefined4`) | PROVEN (return) / STRONG_INFERENCE (meaning) | caller keeps D0 in a3 at 0xc242 | none found in godot/ |

## Object flag long (+4)

The low word is copied (zero-extended) from descriptor +0x16 by
`alloc_object_from_desc`; big-endian byte +7 = bits 0–7, +6 = bits 8–15,
+5 = bits 16–23.

| Bit | Mask | Byte test | Meaning | Certainty | Evidence |
|---|---|---|---|---|---|
| 13 | 0x2000 | +6 & 0x20 | moving object (the collision handler of a is chosen first) | STRONG_INFERENCE | dispatch_collision, apply_controller_velocities |
| 14 | 0x4000 | +6 & 0x40 | player-contact handler | STRONG_INFERENCE | handle_player_contact |
| 19 | 0x80000 | +5 & 0x08 | needed by release_fractal_reference, tested by lift_object_onto_terrain | UNKNOWN | 0x14afe, 0x148b6 |
| 1 | 0x2 | +7 & 0x02 | excluded from view and collision (sent to the out-of-range path) | PROVEN (flow) | collect_far_objects 0x55c4 / 0x56f8 |
| 2 | 0x4 | +7 & 0x04 | no camera-relative candidate entry | PROVEN (flow) | 0x5600 |
| 6 | 0x40 | +7 & 0x40 | not put on the visible list; uses the player tests (handle_player_contact / test_player_vs_type0e_proximity); set on the player (DAT_0001b738) | PROVEN (flow) / STRONG_INFERENCE (meaning) | 0x55cc, 0x56f0, 0x579c |
| 10 | 0x400 | +6 & 0x04 | destructible by gunfire: bullet_hits_shape marks it for destruction 1 hit in 8 (otherwise solid, the bullet stops) | PROVEN (flow) / STRONG_INFERENCE | 0x166c8 |
| 11 | 0x800 | +6 & 0x08 | one-frame mover flag, cleared by the sweep | PROVEN (flow) | 0x56d2 |
| 15 | 0x8000 | +6 & 0x80 | added to DAT_0001c1e4 each frame; that list gets the +0x16 notice handlers (dispatch_overlap_collisions) | PROVEN (flow) | 0x56ac, 0x5832 |
| 20 | 0x100000 | +5 & 0x10 | distance-based (proximity) collision instead of shape collision; set from bit 13 at creation | PROVEN (bit flow) / STRONG_INFERENCE (meaning) | 0x13e62, 0x570c, 0x5796, 0x116ca, alloc 0x45ba |
| aircraft controller +0x668 / +0x669 (Pacific Conflict) | throttle setting 0..9 (byte; keys 0–9, step input clamped 0..9) / engine running (byte) | PROVEN (writers) / STRONG_INFERENCE | Ghidra `DAT_0001b738 + 0x19a` on int * = byte +0x668. |
| aircraft controller +0x66e / +0x672 / +0x66a / +0x680 (Pacific Conflict) | engine power (long) / manifold gauge (word) / RPM tachometer (long) / fuel-burn accumulator (word) | PROVEN (arithmetic) / STRONG_INFERENCE (names) | power = density(altitude) × throttle; RPM -> mean of power and airspeed term; replaces the "pitch / roll / yaw axes" hypothesis. |
| `DAT_0001b2c0` (Pacific Conflict, file 0x1b2e0) | altitude curve: 9 longs 421, 511, 627, 780, 977, 1241, 1646, 2623, 0 (bands of 0x10000) | PROVEN (values, lerp) / STRONG_INFERENCE (inverse air density; sea level -> 1.0 in both consumers) | read by table_lerp_1b2c0; sawtooth above 0x70000 because entry 8 = 0. |

## Aircraft type record (DAT_00026004 = controller +4)

The record is the definition record `DAT_0001b524[key]`: handler slots +2..+0x16,
then flight data as signed words except +0x38 (long). `update_aircraft_entity`
sets `DAT_00026004 = param_1[1]` each tick. "AoA" means `movement_626`, which is
compared against these fields as an angle. Users are in `Pacific Conflict.decomp.c`.

| Field | Users | Role | Certainty |
|---|---|---|---|
| +0x1c | load_player_fuel_and_bombs | fuel capacity (units, both tanks) | STRONG_INFERENCE |
| +0x1e | update_aircraft_entity block 1b | fuel-burn threshold (throttle accumulator +0x680 per fuel unit) | PROVEN flow / STRONG_INFERENCE |
| +0x20 | block 4c | drag coefficient; gear adds +0x679 / 0xb × it, flaps +0x67b / 0xf × it | PROVEN flow / STRONG_INFERENCE |
| +0x22 / +0x24 | block 4b | drag terms in v and lift² (induced drag) | HYPOTHESIS |
| +0x26 / +0x28 | compute_template_force_from_626 | lift coefficient base / slope, clean | STRONG_INFERENCE |
| +0x2a / +0x2c | same | lift base / slope at full flaps (blend by flaps / 0xf) | STRONG_INFERENCE |
| +0x2e / +0x30 | block 4c (grounded, gear down) | rolling friction: low speed or grass ('@') / normal | STRONG_INFERENCE |
| +0x32 | block 4c | brake friction (brake +0x641 or surface 'P'); × 3 / 2 when sliding gear-up | STRONG_INFERENCE |
| +0x34 | compute_template_force_from_626, block 4 | stall angle: above it marker 0xc, lift fades over 0x20 more | PROVEN flow / STRONG_INFERENCE |
| +0x36 | block 3a | corner speed: up to it, stick +0x662 commands AoA = stick × stall / 512; from it to speed 0xca8 the factor falls linearly to stick × 1 | PROVEN flow (bytes 0xeb6e..) / STRONG_INFERENCE |
| +0x38 (long) | scale_template_field_38 | rated engine power (× altitude factor) | STRONG_INFERENCE |
| +0x3c / +0x3e | block 2a | static thrust / speed where thrust becomes power / speed | STRONG_INFERENCE |
| +0x40 | block 1 | halved unless gear byte +0x679 == 0x2d (gear down) | UNKNOWN role |
| +0x42 | block 3b | on the ground with gear down: AoA cap (three-point attitude; player 469 = 10.3 deg, friendly bomber 277 = 6.1 deg) | PROVEN flow / STRONG_INFERENCE |
| +0x44 | block 3a | AoA trim offset: AoA approaches commanded + +0x44 (128 = 2.8 deg) at gain (speed × 0x2a, × 0x143a, 4.12 steps) >> 8 | PROVEN flow / STRONG_INFERENCE |
| +0x46 / +0x48 | block 3b, block 4c | ground speeds: at or below +0x46 the AoA is held at +0x42, between them it is blended back up (tail lifting), and below +0x46 the low-speed rolling friction +0x2e applies | PROVEN flow / STRONG_INFERENCE |

### Aircraft type records in the data file [PROVEN values]

Records of 0x4a bytes at file 0x1a7b0 (key 1), 0x1a88e (key 2), 0x1a844 (key 3) and
0x1a7fa (key 4). All four have +2 aircraft_tick, +0xa destroy 0xe0a4, +0xe 0xfb2a and
+0x12 aircraft_collision. Create handlers: key 1 aircraft_create (the player), key 2
create_friendly_bomber, key 3 create_enemy_bomber, key 4 create_enemy_fighter.
Notice +0x16: key 1 aircraft_notice_object, key 4 enemy_fighter_notice_object
(0x100d4), keys 2 / 3 none. Words unless marked L.

| Field | k1 player | k2 friendly bomber | k3 enemy bomber | k4 enemy fighter | Consistent with the role? |
|---|---|---|---|---|---|
| +0x1a | 310 | 310 | 310 | 310 | UNKNOWN |
| +0x1c fuel capacity | 46 | 93 | 93 | 93 | yes |
| +0x1e fuel-burn threshold | 24652 | 9145 | 9145 | 9145 | yes (the player burns slower per unit) |
| +0x20 drag | 2171 | 2171 | 2171 | 2171 | — |
| +0x22 / +0x24 | 337 / 300 | same | same | same | — |
| +0x26 / +0x28 lift base / slope, clean | 0 / 599 | same | same | same | yes (no lift at zero AoA) |
| +0x2a / +0x2c lift base / slope, flaps | 2457 / 599 | same | same | same | yes (flaps add a constant) |
| +0x2e rolling friction, slow / grass | 102 | 205 | 205 | 205 | yes (> +0x30) |
| +0x30 rolling friction | 41 | 41 | 41 | 41 | yes |
| +0x32 brakes | 3276 (0.8 in 4.12) | 1638 | 3276 | 3276 | yes (much larger than rolling) |
| +0x34 stall angle | 832 = 18.3 deg (0x4000 per turn) | 832 | 832 | 832 | yes (a realistic stall AoA) |
| +0x36 | 1980 | 1980 | 1980 | 1980 | — |
| +0x38 L power | 8343704 | 6257778 | 7509334 | 7509334 | yes (differs per type) |
| +0x3c static thrust | 3527 | 3527 | 3527 | 3527 | — |
| +0x3e thrust crossover speed | 2365 | 2365 | 2365 | 2365 | — |
| +0x40 | 67 | 67 | 67 | 67 | UNKNOWN |
| +0x42 | 469 | 277 | 469 | 469 | — |
| +0x44 | 128 | 128 | 128 | 128 | — |
| +0x46 / +0x48 | 640 / 1067 | same | same | same | — |

## Aircraft control inputs

| Symbol | Meaning | Confidence | Evidence |
|---|---|---|---|
| aircraft controller +0x662 / +0x664 / +0x666 (Pacific Conflict) | elevator (±0x200) / rudder (±0x40) / aileron (±0x140) inputs, 4-frame averages | PROVEN (flow, clamps) / STRONG_INFERENCE (names) | enqueue_control_inputs_avg4; mouse y -> elevator, mouse x -> aileron, Z / X keys (DAT_0001b858 = ±0x40) -> rudder; rings +0x644 / +0x64c / +0x654, sums +0x65c / +0x65e / +0x660, index +0x642. |
| `DAT_0001b858` (Pacific Conflict) | rudder key input (word: +0x40 Z, -0x40 X, 0) | PROVEN | key handler cases 0x5a / 0x3e and 0x58 / 0x3f. |
| bullet controller +0x36 (Pacific Conflict) | fired by the player (word: 1 / 0) | PROVEN | set only when the shooter is DAT_0001b738; tick_bullet calls tally_destroyed_entity only when it is non-zero; apply_random_aircraft_damage copies it to +0x684 bit 15. |

## Aircraft smoke-trail count

| Symbol | Meaning | Confidence | Evidence |
|---|---|---|---|
| aircraft controller +0x68c | active smoke trails (word): ++ in attach_smoke_trail, -- in destroy_trail_controller for a kind-0 trail still linked (+0x56); with damage bit 6 the engine runs only while it is non-zero | PROVEN | addq.w 0x16b84, subq.w 0x16df4, tst.w 0xe952 (the only three references) |

## Gun turret (definition key 0x1b)

| Symbol | Meaning | Confidence | Evidence |
|---|---|---|---|
| definition key 0x1b (file 0x1ab24) | gun turret carried by bombers and ships (+2 tick_turret, +0xe turret_pre_render) | PROVEN (record) | — |
| turret controller +0x3e / +0x40 | side (0x200 friendly targets types 3–4, 0x100 enemy targets types < 3, 0 never targets) / initialised flag (also the flak "shells" gate) | PROVEN | key 0x1b shares flak_notice_object (+0x16 = 0x18b9a) and destroy_flak_controller (+0xa = 0x18b78) with the flak gun. |
| turret controller +0x48 / +0x4a | shot timer (fires when it reaches 0, reset to 2) / burst frames (7..14, a burst starts 1 frame in 16) | PROVEN | Bytes 0x192da..0x1936a. |
| turret controller +0x4c / +0x4e, +0x50 / +0x52 | aim angles (from attitude_from_velocity) / aim errors (±0x80 at burst start, × 7/8 per shot) | PROVEN | — |
| turret controller +0x46 | knocked out by gunfire (word, 0 / 1; set 1 hit in 16 by bullet_hits_shape, never cleared by turret code) | PROVEN (accesses) / STRONG_INFERENCE (permanent) | tst.w at 0x19220 / 0x1939e; move.w #1 at 0x1670e. Replaces "reloading". |

## False entries and runtime-address callees

`lea.l $xxxx.l` / `jsr (aN)` operands in the overlay are RUNTIME addresses (file offset
- 0x20). Ghidra treated them as file offsets and invented functions at the wrong place.

| Ghidra name | Real callee | Evidence |
|---|---|---|
| `FUN_00002de8` (false entry) | `abs_int` (file 0x2e08) | — |
| `FUN_00003c48` (false entry inside `compute_camera_abs_metric`; was named `approx_dist3_from_abs`) | `approx_dist3_xyz` (file 0x3c68) | all 6 references are `lea.l $3c48.l`; 6 call sites corrected in the decomp |
| `LAB_000028ba_2` (update_tracking_camera) | `transform_vecs12_by_matrix3` (file 0x28dc) | `lea.l $28bc.l` at 0x8dc6 |
| `LAB_0000e3e8_4` (turn_camera_toward_point) | `fold_angle_pm_0x2000` (file 0xe40c) | `lea.l $e3ec.l` at 0x8b68 |
| `heap_roving_cursor_store` (FUN_00001a48, false entry) | `heap_alloc(size)` (file 0x1a68) | all 4 `lea.l $1a48.l` (overlay_main_entry ×2, 0x4e6e, 0xb4b6); 27 call sites corrected; resolves the old "$1A48 allocator ABI" blocker |
| `heap_add_large_block_tail` (0x19b0), `heap_zero_payload_tail` (0x1b4c), `heap_realloc_grow_only_tail` (0x1be4), `reset_object_to_template_pose_tail` (0x4e4e), `overlay_rng_warmup_epilogue` (0x11544) | `heap_free_coalesce`, `heap_alloc_cleared`, `copy_object_vertex_buffer`, `activate_near_range_object`, `overlay_rng_next` (each + 0x20) |  scan of all `lea.l` code operands; overlay_rng_next done (17 lea, 49 call sites, now PROVEN); the other four corrected (activate_near_range_object ×3 and copy_object_vertex_buffer ×2 in init_mission_object_tables, heap_free_coalesce ×2 in deactivate_object, heap_alloc_cleared ×2 in create_wave_spawner_controller) |

Runtime-address completeness check [PROVEN, byte scan]: the 78 absolute `move.l #$xxxx`
code-pointer stores (64 distinct targets) (state handlers, definition-table slots, renderer hooks) all point
at file xxxx + 0x20, and the decomp already names those targets. The three `pea.l
$xxx(pc)` callbacks (collect_map_features 0x6ec, nearest_type80_centroid_visitor 0xaba,
anchor_point_visitor 0xc4c) are PC-relative, so they are plain file offsets with no
shift. There are no absolute `jsr $xxxx.l`. Every overlay code reference has now been
checked against the runtime-address rule.

## Call-argument corrections

Ghidra calls that lost their stack arguments; the bytes give the real list.
Under the verification policy, a function whose body matches the bytes is VERIFIED once
its dropped arguments are listed here.

| Caller | Callee | Real arguments | Evidence |
|---|---|---|---|
| `bullet_hits_aircraft` (FUN_000167f4) | `segment_point_min_distance` (FUN_00003cca) | 9 longs: bullet pos - vel/2 (x, y, z), bullet vel (x, y, z), aircraft pos (x, y, z) | bytes 0x16804..0x16852 |
| (callee side) | `segment_point_min_distance` (FUN_00003cca) | reads the deltas as low words (signed 16-bit); floor midpoints; word distances (wrap above 0x7fff) | bytes 0x3cca..0x3da6 |
| `bullet_hits_shape` (FUN_0001665a) | `segment_point_min_distance` (FUN_00003cca) | same 9 longs as bullet_hits_aircraft | bytes 0x1666a..0x166b8 |
| `deactivate_object` (FUN_000052dc) | `heap_free_coalesce` (FUN_000019d0, via runtime `$19b0`) ×2 | *(+0x4c), then *(+0x44); only +0x44 is cleared | bytes 0x530c..0x531e |
| `update_aircraft_entity` (FUN_0000e792) | (statement order, not a call) | touchdown reads the impact word +0xe BEFORE snapping param_1[3]; Ghidra prints the load after the store | bytes 0xf112 (load) / 0xf124 (store) |
| `update_aircraft_entity` (FUN_0000e792) | `sin_fixed14` (FUN_00001d76, Ghidra FUN_00001d56 via runtime `$1d56`) ×2 | sext local_28 (0xf49c), then sext word +0x20 (0xf4ca, same value after the commit) | bytes 0xf49c..0xf4d0 |
| `enemy_fighter_notice_object` (FUN_000100d4) | `approx_dist3_xyz` (FUN_00003c68) | 6 longs: own object pos (+0x18 / +0x1c / +0x20), target object pos | bytes 0x10176..0x1018e |
| `enemy_fighter_notice_object` (FUN_000100d4) | `probe_nearest_facility_kind` (FUN_00000354) ×2 | param_2 (target object) | bytes 0x101e0 / 0x1024c |
| `enemy_fighter_notice_object` (FUN_000100d4) | (jump table, not a call) | Ghidra's empty switch: only target kinds 1, 2, 21..25 proceed | bytes 0x100f0..0x10134 |
| `ai_attack_or_fly` (FUN_000110f4) | `approx_dist3_xyz` (FUN_00003c68) | 6 longs: own object (*param_1) +0x18 / +0x1c / +0x20, target (+0x692) +0x18 / +0x1c / +0x20 | bytes 0x11126..0x11140 |
| `ai_dive_at_target` (FUN_000111da) | `approx_dist3_xyz` (FUN_00003c68) | 6 longs: own x, 0, own z, target x, 0, target z (horizontal distance) | bytes 0x11202..0x11218 |
| `ai_bombing_run` (FUN_000112e0) | `approx_dist3_xyz` (FUN_00003c68) | 6 longs: own x, 0, own z, target x, 0, target z (horizontal distance) | bytes 0x11310..0x11326 |
| `advance_route_waypoint` (FUN_00016966) | `approx_dist3_xyz` (FUN_00003c68) ×2 | (own x, 0, own z, point x, 0, point z) horizontal; then (own pos, new point) 3D | bytes 0x1697c..0x1698e / 0x169b8..0x169ce |
| `tick_ai_1b310_approach_fire` (FUN_00010ecc) | `approx_dist3_xyz` (FUN_00003c68) | (own x, 0, own z, -0x40af3, 0, 0x2b246a): horizontal distance to a fixed world point | bytes 0x10ef2..0x10f0a |
| `try_begin_landing_approach` (FUN_00019fba) | `approx_dist3_xyz` (FUN_00003c68) | own object pos (+0x18 / +0x1c / +0x20), runway end A (frame -0xc / -8 / -4) | bytes 0x19fe2..0x19ffe |
| `find_nearest_runway_approach_ends` (FUN_00019c5e) | `probe_nearest_facility_kind`; `approx_dist3_xyz` ×5; `store_xyz_asr` ×4 | probe(object); dist3(own, object) 3D; dist(P1,P2) / dist(P2,P3) horizontal (y = 0); dist3(own, M12) / dist3(own, M34); store_xyz_asr destination in register a1 = P1..P4 (frame -0xc / -0x18 / -0x24 / -0x30) | bytes 0x19ccc..0x19efc |
| `tick_landing_approach_glide` (FUN_0001a1a6) | `approx_dist3_xyz` (FUN_00003c68) | own object pos, aim point 0x267bc / 0x267c0 / 0x267c4 (3D) | bytes 0x1a1d4..0x1a1e6 |
| `tick_landing_approach_glide` (FUN_0001a1a6) | `abs_int` (Ghidra FUN_00002de8 via runtime `$2de8`) ×4 | own x - target x; own z - target z; vertical error (target y - own y); sext throttle target - (+0x62a >> 2) | bytes 0x1a31e / 0x1a330 / 0x1a5e8 / 0x1a602 |
| `process_flight_input_and_outcome` (FUN_0000740a) | `probe_nearest_facility_kind` (FUN_00000354) | the player's object (*DAT_0001b738) | bytes 0x803e..0x8040 |
| `point_near_camera_or_type80_object` (FUN_00000bea) | `compute_camera_abs_metric` (FUN_00003c00) ×2 | the point param_1[0..2] (x, y, z) | bytes 0xbf0..0xbfa / 0xc26..0xc30 |
| `transform_through_node_chain` (FUN_000004f8) | `transform_int3_vecs_by_matrix3` (Ghidra FUN_00002aba, runtime `$2aba`) ×2; `translate_int3_vecs` (Ghidra LAB_00001c3a_2, runtime `$1c3c`) ×2 | (1, &p, &p, M); (1, &p, &p, node offset); (count +0x1a, src, buffer, M); (count, buffer, buffer, offset << shift +0x18) - Ghidra merged these into two garbled calls | bytes 0x55c..0x5d0 |
| `flak_notice_object` (FUN_00018bba) | `approx_dist3_xyz` (FUN_00003c68) | 6 longs: gun pos (x, y, z), target pos (x, y, z) | bytes 0x18c10..0x18c28 |
| `approx_dist3_xyz` (FUN_00003c68) itself | `abs_int` via Ghidra `FUN_00002de8` | its own 6 longs (x1, y1, z1, x2, y2, z2); each call gets x2 - x1 / y2 - y1 / z2 - z1 | bytes 0x3c70..0x3c9c |
| `update_tracking_camera` (FUN_00008c30) | `approx_dist3_xyz` ×3 | 0x8cd0: player pos, target pos; 0x8e06 / 0x8e78: own pos + rotated (0, 0, 0x4000), other pos | bytes 0x8cb4..0x8e78 |
| `update_bailout_view` (FUN_00008972) | `approx_dist3_xyz` | 6 longs: aircraft pos, parachute pos | bytes 0x89de..0x89f6 |
| `turn_camera_toward_point` (FUN_00008abe) | `compute_camera_abs_metric`, `abs_int` ×2 | (x, y, z); abs_int(pitch diff), abs_int(heading diff) | bytes 0x8ad2..0x8b9e |
| `DAT_00024d1a` / `DAT_00024d18` (Pacific Conflict) | camera pitch / camera heading (words, 0..0x3fff); DAT_0001d810 / DAT_0001d80e = their negatives | PROVEN | corrects the  heading / pitch order: attitude_from_velocity's 7th output is the heading (from x / z), its 6th the pitch (from y). |
| `attitude_from_velocity` (FUN_00001f22) | `abs_int` ×2 (Ghidra FUN_00002de8) | abs_int(x), abs_int(z) | bytes 0x1f3e..0x1f50 |
| `atan2_fixed14` (FUN_000102d6) | `abs_int` ×2 (Ghidra FUN_00002de8) | abs_int(param_1), abs_int(param_2) | bytes 0x102e2..0x102f6 |
| `apply_relative_heading_steer` (FUN_000109ba) | `abs_int` ×2 (Ghidra FUN_00002de8) | abs_int(param_5), abs_int(param_4) | bytes 0x109d4..0x109ee |
| aircraft controller +0x20 / +0x22 / +0x24 (Pacific Conflict) | attitude words: pitch / heading / bank (roll), 0x4000 per turn | STRONG_INFERENCE | +0x22 heading (camera and steer code); +0x24 bank from apply_relative_heading_steer's clamped bank target; order matches build_attitude_matrix_3ang. |
| `build_relative_steer_sample` (FUN_00010360) | `abs_int` ×3 (Ghidra FUN_00002de8) | abs_int(dx), abs_int(dy), abs_int(dz) | bytes 0x103b6..0x103e0 |
| aircraft controller +0x692 / +0x696 (Pacific Conflict) | AI target object / its distance | PROVEN (flow) | written by enemy_fighter_notice_object (0x102b2 / 0x102be); ai_pursue_target pursues directly beyond 0x4e20 |
| `DAT_0001b876` / `DAT_0001b878` (Pacific Conflict) | AI aim lag in frames (definition key 1 / other aircraft), set from the rank table | PROVEN (use) | ai_pursue_target extrapolates the target's replay ring by lag + 4 frames |
| `ai_pursue_target` (FUN_0001820a) | `abs_int` ×4 (Ghidra FUN_00002de8) | abs_int(heading_err) (0x18324); abs_int(fold(target heading - own)) (0x18350); abs_int(pitch_err - (+0x626 - def +0x44)) (0x1852c); abs_int(heading_err) (0x1853c) | gun-fire decision ±0x7f |
| `ai_pursue_target` (FUN_0001820a) | `approx_dist3_xyz` (FUN_00003c68) | 6 longs: target pos (*param_1 +0x18 / +0x1c / +0x20), manoeuvre waypoint (+0x69c / +0x6a0 / +0x6a4) | bytes 0x185f6..0x1860e |
| `build_land_outline_at_detail` (FUN_00004958) | `approx_dist3_xyz` (FUN_00003c68), 2 calls | (last emitted x, 0, last emitted z, x, 0, z), then (DAT_0001d838, 0, DAT_0001d830, x, 0, z) | bytes 0x4aae..0x4ada |
| `update_altitude_detail_bands` (FUN_00005a14) | `compute_camera_abs_metric` (FUN_00003c00), 2 calls | (DAT_0001d724, DAT_0001d720, DAT_0001d71c), then (DAT_0001d718, DAT_0001d714, DAT_0001d710) | bytes 0x5af8..0x5b54 |
| `update_ground_scatter_objects` (FUN_00005e28) | `abs_int` (FUN_00002de8 label = runtime 0x2de8 = file 0x2e08), 2 calls | slot x - DAT_0001d838, then slot z - DAT_0001d830 | bytes 0x5ef6..0x5f28 |
| `surface_type_at_point` (FUN_00013346) | `compute_camera_abs_metric` (FUN_00003c00), `approx_dist3_xyz` (FUN_00003c68) | (param_1, param_2, param_3); then (param_1, param_2, param_3, obj +0x18, +0x1c, +0x20) | bytes 0x1336e..0x133c2 |
| `create_wave_spawner_controller` (FUN_00018040) | `heap_alloc_cleared` (lea.l $1b4c.l = runtime, file 0x1b6c), 2 calls | 0x38; then sext word ctl +0x32 * 4 + 10 | bytes 0x1804c / 0x18098..0x180a2 |
| `test_proximity_collision` (FUN_00013e4e) | `approx_dist3_xyz` (FUN_00003c68) | a +0x18 / +0x1c / +0x20, b +0x18 / +0x1c / +0x20 | bytes 0x13e68..0x13e80 |
| `tally_destroyed_entity` (FUN_00000488) | `probe_nearest_facility_kind` (FUN_00000354) | the entity (param_1) | byte 0x494 |
| (callee) `probe_nearest_facility_kind` (FUN_00000354) | signature applied: `(int object)` | all 12 byte-level call sites pass it: entity (0x494), player object *DAT_0001b738 (0x803e, 0x87a8), param_2 (0xfff6, 0x101e0, 0x1024c), the object (0x12e32, 0x14e70, 0x14ece, 0x18df2, 0x1918c, 0x19ccc) | bytes 0x354..0x35c and each push |
| `aircraft_collision` (FUN_0000fe0a) | `apply_blast_damage` (FUN_00012b66; signature now applied, 7 ints) | x, max(y, own ctl +0x2e), z, 10, own ctl == player ctl, 0, 1 | bytes 0xfe50..0xfe86 |
| `ordnance_detonation` (FUN_00012d34) | `apply_blast_damage` | object x / y / z, 0x8d4, sext word ctl +0x614, 0, sext word ctl +0x616 | bytes 0x12d5e..0x12d82 |
| `apply_hit_to_sinkable_object` (FUN_00014f48) | `approx_dist3_xyz` (FUN_00003c68) | anchor DAT_0001d83c / d840 / d844, object x, y, z | 0x14f60..0x14f74 |
| `carry_attached_objects` (FUN_00014bea) | `approx_dist3_xyz` (FUN_00003c68) | carried object x, y, z, carrier x, y, z | 0x14ca2..0x14cb0 |
| `create_shape_contact_record` (FUN_000135e8) | `abs_int` (FUN_00002e08; called as runtime FUN_00002de8) | x / y / z of vertex (*(b+0x44) + 12 * (b+0x36 + idx)) minus vertex 0 | 0x13706..0x13748 |
| `tick_aircraft_spawner` (FUN_00017dd4) | `abs_int` (FUN_00002e08; called as runtime FUN_00002de8) | spawner x - player x; spawner z - player z | 0x17e8a..0x17e98 |
| `tick_turret` (FUN_0001917c) | `approx_dist3_xyz` (FUN_00003c68) | turret x, y, z, target x, y, z | 0x19228..0x1923c |
| `animate_landing_gear` (FUN_0000fb2a) | `build_attitude_matrix_3ang_alt` (FUN_00002464; Ghidra `LAB_00002440_4`) | (angle, angle, 0, -$1e(a6)) and (angle, -angle & 0x3fff, 0, -$30(a6)); runtime lea $2444.l = file 0x2464 | 0xfbf8..0xfc24 (call target corrected in the C) |
| `memmove_block` (FUN_0001a63e) return value | - | always 0 (moveq #0,d0 at 0x1a6aa / 0x1a710); Ghidra's `return puVar6` corrected; no caller uses it | 0x1a6aa, 0x1a710 |
| `aircraft_notice_object` (FUN_0000fe96) | `approx_dist3_xyz` (FUN_00003c68) | observer x, y, z, other x, y, z | 0xffa2..0xffb6 |
| `animate_ground_fire` (FUN_00017150) | `abs_int` (FUN_00002e08; called as runtime FUN_00002de8) | host controller velocity x (+8); velocity z (+0x10) | 0x17172..0x17184 |
| `configure_renderer_for_display` (FUN_00006ff6) | `init_mission_object_tables` (FUN_000016e2) | pushes host +0x8c; the (void) callee never reads it | 0x721e |
| `configure_renderer_for_display` (FUN_00006ff6) hook values | DAT_0001da90 depth 4 | stored 0x17848 = runtime of erase_radar_blip_depth4 (file 0x17868); Ghidra's `&LAB_00017848` replaced by the literal | 0x7182 |
| `fractal_height_at` (FUN_00013980) | `abs_int` (FUN_00002e08; called as runtime FUN_00002de8) | template vertex x - xc (D6 = (half + cx) - (half + cz) / 2, shifted; dropped by Ghidra); vertex z - zc (iVar10) | 0x13afc..0x13b16, D6 from 0x13a66..0x13a9a |
| `parachute_descend` (FUN_0001952e) +0x616 store | - | stores ext.l(table_lerp_1b2c0(y)) left in D0, not iVar8 % 10: divs.l d7,d1 ext 0x1801 is quotient-only (Dr == Dq) | 0x196b6, 0x196d4, 0x196d8 (C corrected) |
| `tick_flak_gun` (FUN_00018c96) | `approx_dist3_xyz` (FUN_00003c68) | gun x, y, z, target x, y, z | 0x18ece..0x18ee6 |
| `sort_group_parts_by_distance` (FUN_0001443a) | `compute_camera_abs_metric` (FUN_00003c00) | template vertex x, 0, z (two face passes); support point +4, 0, +8 | 0x14502..0x14508, 0x145ce..0x145d4, 0x146cc..0x146d2 |
| `update_heading_tape` (FUN_0000c1aa) | `copy_rect_depth8` (FUN_0000bfb0; Ghidra `LAB_0000bf8e_2`) | (dst, src, run width, rows +0x1a0, src stride +0x1aa & 0x1fff, dst stride); d5 = move.l #$bf90 = runtime of file 0xbfb0 | 0xc4a4, calls 0xc4e2 / 0xc514 / 0xc566 (C corrected) |
| `overlay_init_template_pointer_tables` (FUN_00000054) template sources | - | absolute source operands are runtime addresses (data at +0x20): block A keys 1 / 4 / 3 / 2 at file 0x1a7b0 + 0x4a k, block C keys 0x15..0x19 at file 0x1aa7e + 0x1c k; earlier 0x5858 / 0x0999 'title string' reading withdrawn | 0x60..0x66, 0x262..0x268 |
| `scan_convert_edge_rows` (FUN_00002e14) range 0x3212..0x3265 | - | 0x3212..0x3240 unreachable dead code (no branch or pointer reaches it; saves state and unlk / rts without restoring registers); 0x3242.. is the self-modified span table of init_span_table_32ba, not code | 0x3210 bra.b $31f4 precedes it |
| ID01 divide runtime (FUN_00000110..FUN_000001c2) | signatures reconstructed | stack entries take (dividend, divisor), pop both arguments themselves and preserve D1; cores take D0 / D1 and return (quotient << 32) \| remainder; Ghidra's (void) / uint forms dropped the arguments, rt_sdiv32's D0 result and the signed core's negations - C rebuilt from the bytes and checked against C division on 3,000,169 cases | ID01.bin 0x110..0x22a |
| CODE 0 jump-table slots used by ID08 | resolved | entry n = (A5 offset - 0x22) / 8 at ID00.bin 16 + 8n, file = segment offset + 4: $2ca ID09 0x38c GetFPos ($A018), $2c2 0x368 GetEOF ($A011), $22a 0x200 NewPtr ($A11E), $2b2 0x2fa FSRead ($A002; 0x2fe FSWrite $A003), $30a 0x1a SFGetFile (Pack3 $ADEA selector 2 via the dispatcher at ID09 0x4: selector = (return - 0x18) / 2), $48a ID02 0x435e position_window_on_screen, $4d2 ID02 0x2ee4 copy_pascal_string | ID00.bin; ID09.bin 0x4..0x38c |
| ID08 FUN_00000338 / 00000348 / 0000039c | bodies reconstructed | sysbeep_and_exit_to_shell = SysBeep(100); ExitToShell; alloc_and_read_resource_payload(short refNum) reads mark..EOF into NewPtr -> A5-0x12fc and returns FSRead's OSErr; bootstrap_window_and_load_overlay places the Get File dialog (GetNewDialog -4000) then SFGetFile for type 'HELL' and on success stores name / vRefNum and runs load_overlay_from_resource | ID08.bin 0x338..0x446 |
| ID09 FUN_000002a6 / 000003c2 | bodies reconstructed | fsopen_glue = Pascal FSOpen(fileName, vRefNum, VAR refNum): OSErr over an IOParam and _Open ($A000); swapmmumode_glue = SwapMMUMode(VAR mode) via $A05D; both callee-pop Pascal glue | ID09.bin 0x2a6..0x2dc, 0x3c2..0x3d4 |
| `lookup_colour_map` (ID06 FUN_0000017c) clamp / index | corrected | CMPI.W #$100 / BLT and EXT.L are signed: the C now compares and indexes (short)param, so words >= 0x8000 index the table negatively as in the bytes | ID06.bin 0x180..0x192 |
| `alloc_aligned_clear` (ID06 FUN_000001dc) | body reconstructed | JT $212 ID09 0x1b2 FreeMem ($A01C), $21a 0x1bc MaxMem ($A11D, VAR grow), $232 0x20c NewPtrClear ($A31E), $23a 0x218 DisposPtr ($A01F): if FreeMem < 500000 MaxMem(&grow); raw = NewPtrClear(size + 12); block = (raw + 12) & ~3, size at -4, raw at -8 | ID06.bin 0x1dc..0x24a |
| `read_DATA128_pair` / `write_DATA128_pair` / `read_TEXT128_pair` / `write_TEXT128_pair` (ID05 FUN_00000160 / 1bc / 214 / 270) | bodies reconstructed (Ghidra stopped at $A9A0) | GetResource('DATA' or 'TEXT', 128); if h: HNoPurge (JT $28a -> ID09 0x28e $A04A), read clears *a / *b first then copies longs 0 / 4, write stores args 8(A6) / $c(A6) then ChangedResource $A9AA + WriteResource $A9B0; HPurge (JT $282 -> ID09 0x284 $A049); ReleaseResource $A9A3 | ID05.bin 0x160..0x2c6 |
| `center_template_rect_on_screen` / `get_machine_screen_fingerprint` (ID05 FUN_00000006 / FUN_000000c8) | bodies reconstructed (Ghidra stopped at $A9A0 / $AA32) | JT $20a -> ID09 0x19c GetMBarHeight (word $0baa), JT $1f2 -> ID09 0x20 SysEnvirons ($A090) glue; centre: newLeft = (screenRight - width) / 2, newTop = (screenBottom - mbar - height) / 3, top += mbar; fingerprint: machineType, then GetGDevice PixMap right / bottom / pixelSize or screenBits width / height / 1, then 0 | ID05.bin 0x06..0x15e |
| `get_dialog_item_text_upper` (ID05 FUN_000004e4) | body reconstructed (Ghidra stopped at $A98D) | GetDItem / GetIText into static A5-0x1c9, JT $2fa -> ID09 0x432 length_prefixed_bytes_to_c_string_in_place, then each byte whose ctype entry A5-0x1608[c] has bit 7 set goes through JT $4e2 -> ID02 0x1ce ansi_toupper; returns A5-0x1c9 | ID05.bin 0x4e4..0x55e |
| `code_dialog_filter` (ID05 FUN_000002c8) | routine A body reconstructed (Ghidra stopped at $A873); return-value correction | Pascal ModalDialog filter: SetPort; first pass after a reset frames item 1 (PenSize 3, InsetRect -4, FrameRoundRect 16) and dims it when item 3's text is empty; keyDown / autoKey clears A5-0x2ca; Return / Enter -> *item = 1, result 1; Escape -> *item = 2, result byte 2 (MOVEQ #2 reused), not true; routine B 0x3ba..0x4e2 has no inventory entry | ID05.bin 0x2c8..0x3b8 |
| `run_protection_dialog` (ID05 FUN_00000560) | body reconstructed (Ghidra stopped at $A874); two header corrections | JT $2f2 -> ID09 0x404 NumToString (Pack7 $A9EE) glue, JT $302 -> ID09 0x416 C-to-Pascal in place, ModalDialog filter = A5+$562 -> ID05 0x2c8; ParamText order is (s1, s2, s3, code), not (code, s3, s2, s1); the early already-valid return skips SetPort(save) | ID05.bin 0x560..0x726 |
| `sysenvirons_glue_fallback` (ID09 FUN_00000048) | body rebuilt; four Ghidra errors fixed | ROMBase ($2ae) +8/+9 selectors (not DAT_216e0016/17); dropped CPUFlag path (+7 = $12f + 1 when <= 2); truncated HFS block: PBGetFCBInfo(SysMap) -> PBHGetVInfo -> PBOpenWD(blessed dirID, 'ERIK') sets sysVRefNum; the 0x188 'jumptable' is the Pascal return of -5500 (envNotPresent) | ID09.bin 0x48..0x188 |
| `load_overlay_from_resource` (ID08 FUN_00000006) | body rebuilt from bytes | FSOpen (retry with vRefNum 0; only this failure returns 0), 32-byte header at A5-0x1026, NewPtrClear(code + data + bss + 4) long-aligned into A5-0x1006, code / data reads, 8-byte relocation records (bit 7 skip, bit 4 error, kind (>> 5) & 3 must be 2; base added in code (i < nA) or data part), FSClose; then poison / protection-table (TickCount seed) / DATA 128 / dialog / restore / write-back sequence; boot-volume name compare -> StopAlert 0x105 + ExitToShell; MaxMem; returns 1 even after read / alloc / reloc failure (pointer cleared) | ID08.bin 0x06..0x336 |
| `load_str129_string_table` (ID07 FUN_00000006) | body rebuilt from bytes | switch helper JSR $3a(A5) -> ID01 0xbe (table: lo, hi, default word, entry words; target = entry address + word); STR# 129 strings 1..120: optional "\p" marker dropped -> Pascal string, else C string; escapes \r -> CR, \t -> TAB, any other backslash kept; pointers to A5-0xf46[i] | ID07.bin 0x06..0x18e |
| `ansi_div` / `ansi_ldiv` (ID02 FUN_00000038 / FUN_00000066) | sign correction; callee names | div uses DIVS.W (signed) so the undefined2 operands are cast to short; ldiv's JT $5a / $62 are ID01 rt_sdiv32 (0x152) / rt_smod32 (0x172) | ID02.bin 0x38..0x98 |
| `ansi_memcpy` / `ansi_memmove` (ID02 FUN_00000232 / FUN_0000024a) | return value added | both load dst into D0 first and never change it, so they return dst (Ghidra emitted void); memmove copies backwards when src <= dst (unsigned) | ID02.bin 0x232..0x270 |
| `ansi_strncpy` / `ansi_strncat` (ID02 FUN_000003f6 / FUN_00000412) | return value added | both load dst into D0 first and never change it, so they return dst (Ghidra emitted void); unexported runtime routines at 0x272 (memcmp-like), 0x292 (memchr-like), 0x3e8 (strlen-like) and 0x434 (strncmp-like) have no inventory entry | ID02.bin 0x3f6..0x432 |
| `begin_overlay_session` / `ensure_free_memory_and_init_sound` (ID02 FUN_0000045a / FUN_000004c6) | bodies rebuilt | UnloadSeg(JT $a2, CODE 4), heap check (FreeMem < 500000 / < 100000 -> MaxMem), overlay hooks A5-0x1082 / A5-0x107e, load_game_sounds 0x1f8e, 0x95a (no inventory entry), lock_sound_slots 0x20be; init_sound_system(0) when A5-0x12ee; the latter returns nothing useful (leftover D0) | ID02.bin 0x45a..0x4fa |
| `run_flight_session` (ID02 FUN_000004fc) | body rebuilt; three header corrections | JT $32 -> ID01 0xaa value-list switch helper (count word, (offset word, value long) pairs, DBEQ, last offset = default; target = offset-word address + offset); command-key table 0x654 (T / 1-5 / Q / S / E, key-up only); $A974 is Button not StillDown; key hook A5-0x106a gets (char, what) not modifiers; second event loop handles only update (6) and activate (8); JT $1fa -> ID09 0x18a sets SysEvtMask $144 | ID02.bin 0x4fc..0x92e |
| switch helper JT $2a (ID01 0x96) | decoded | word-valued twin of ID01 0xaa: pops the table address, count word, then (offset word, value word) pairs compared with D0.W under DBEQ (count + 1 compares; the last offset word is the default); target = offset-word address + offset; first seen in ID04 duty_roster_filter_proc (table 0x5f2) | ID01.bin 0x96..0xa9 |
| `blit_offscreen_frame_to_window` (ID02 FUN_00000d3a) | argument widths corrected; tail completed | arguments are four longs (base, top, rows, mode; only the low words of top / rows used), not (long, short, short, long); first call passes rowBytes = ((width * depth + 15) >> 4) * 2 | 0x8000, base and the destination Rect by value to new_offscreen_cport; tail ForeColor(black), BackColor(white), CopyBits(srcCopy, nil) | ID02.bin 0xd3a..0xe3c |
| `set_draw_color_index` / `set_back_color_index` / `get_blended_fill_pattern` (ID02 FUN_000015cc / FUN_00001632 / FUN_0000150a) | 1-bit branch completed; sign extension | colour-index stores into fgColor / bkColor use MOVEA.W (sign-extended), not the zero-extension Ghidra's undefined2 implied; 1-bit mode looks up the 6-byte RGB entry (index <= 8: A5-0x350 table, else *A5-0x14a6 + 6(i - 8)) and sets PenPat(rgb_to_bw_pattern(entry)); the blend averages with ADD.W / LSR.W #1 (16-bit wrap) | ID02.bin 0x150a..0x1654 |
| `scan_display_devices` (ID02 FUN_00002192) | body rebuilt; header corrections | after choosing a record the bytes re-test gd == GetMainDevice (0x2274 BNE.W) and skip the fill, so only the main record A5-0x1358 is ever filled and the neighbour records A5-0x1342 (left: its right edge = main left) / A5-0x132c (right) stay 0; record +8 = gdType != 0 (not pmRowBytes); +0x10 tests gdFlags bit 8 (byte +0x14 bit 0) together with the ID09 0x3ba byte | ID02.bin 0x2192..0x2332 |
| `init_sound_system` (ID02 FUN_00003dd0) | tail completed; return value | both alloc_sound_buffer_node calls pass flag 0 (CLR.W), not a register; the truncated tail clears A5-0x356, calls SndNewChannel(&A5-0x356, 5 sampledSynth, 0, nil) ($A807) and returns 1 with A5-0xc38 = 1 on success, 0 (flag untouched) on failure | ID02.bin 0x3dd0..0x3f52 |
| `init_raster_target` (ID06 FUN_000007b0) centre | corrected | width / height >> 1 is ASR.W #1 (arithmetic): the C now shifts (short) values | ID06.bin 0x83e..0x84e |
| `rasterize_and_present` (ID06 FUN_00000e10) calls | corrected | renderer (JT A5+0x192 = render_scanline_spans) receives (flag << 16 \| rows, full dest pointer, long stride); the dest == 0 call is (0 << 16 \| rows, target base, (short) row table +0xc); param_3 is a long forwarded to JT $322 (ID02 0xd3a) | ID06.bin 0xed0..0xf54 |
| `tick_flak_gun` (FUN_00018c96) | `apply_blast_damage` | burst x / y / z, 500, 0, 1, 0 | bytes 0x18e62..0x18e78 |
| `handle_player_contact` (FUN_0001429c) | `approx_dist3_xyz` (FUN_00003c68) | a +0x18 / +0x1c / +0x20, b +0x18 / +0x1c / +0x20 | bytes 0x142b6..0x142ce |
| `attach_burning_trail` (FUN_00016b9e) | `compute_camera_abs_metric` (FUN_00003c00) | param_1, param_2, param_3 (trail position) | bytes 0x16bea..0x16bf0 |
| `anchor_point_visitor` (FUN_00000c4c) | `approx_dist3_xyz` (FUN_00003c68) | ctx +4 / +8 / +0xc, then the transformed x / y / z | bytes 0xcb4..0xccc |
| `spawn_effect` (FUN_00011c58) | `compute_camera_abs_metric` (FUN_00003c00) | param_6, param_7, param_8 (effect position) | bytes 0x11d04..0x11d0a |
| `test_object_collision` (FUN_00013ee0) | `point_in_face_by_axis` (FUN_0001346c; signature applied, 9 args) | record, a, b, face, dot-product sum, normal x / y / z words, axis word from the third parallel array (cursor -$8(a6), restored in the C as local_c) | bytes 0x14136..0x14156, 0x14088, 0x14182 |
| `shadow_pre_render` (FUN_00018a34) | `abs_int` (FUN_00002e08; called as runtime FUN_00002de8) | 1st: long template vertex at rec+0x22 + 12*idx; 2nd: sext word of (cos * vertex) >> 12 | lea $2de8.l in the vertex loop (comments added at the call sites) |
| `step_sinking_object` (FUN_00014d86) | `carry_attached_objects` (FUN_00014bea) | the sunk path pushes a seventh long (sext word +0x4e) that the callee never reads ($20(a6) unused) | 0x14e3a..0x14e4e; callee frame reads 0x14bf2..0x14cf0 |
| `plot_mission_map_symbols` (FUN_00000954) | `approx_dist3_xyz` (FUN_00003c68) | object x/y/z = local_b5c[3i..3i+2]; zone x/y/z = local_b5c[300+3j..] (-$6a8(a6)) | 0x9ba..0x9ce |
| `init_mission_object_tables` (FUN_000016e2) | `activate_near_range_object` / `copy_object_vertex_buffer` (runtime 0x4e4e / 0x1be4) | bdb4, bdb4; bdb0, **bdb4 again**; bdac (mission 2) | 0x17b4..0x181c |
| `ordnance_detonation` (FUN_00012d34) | `approx_dist3_xyz` (FUN_00003c68) | object x, y, z vs mission-3 target (-0x3bcd3, 0, 0x2b246a) / mission-4 target (-0xf29a61, 0, 0xb2584f) | 0x12e66..0x12ecc |
| `test_object_collision` (FUN_00013ee0) | `approx_dist3_xyz` (FUN_00003c68) | a +0x18 / +0x1c / +0x20, b +0x18 / +0x1c / +0x20 | bytes 0x13ef0..0x13f08 |
| `update_fuel_needles` (FUN_0000cec4) | Ghidra `FUN_00001db8()` / `FUN_00001d56()` = runtime lea $1db8 / $1d56 = `cos_fixed14` (0x1dd8) / `sin_fixed14` (0x1d76), applied in the semantic C | angle ((fuel * 0x1555) / (capacity / 2) - 0xaab) & 0x3fff | bytes 0xcf12..0xd000 |
| `update_altimeter_needles` (FUN_0000c664) | same runtime cos_fixed14 / sin_fixed14 pair, applied | long hand (((y % 10000) << 14) / 10000 - 0x1000) & 0x3fff, short hand the same with 100000 (DIVSL remainder) | bytes 0xc668..0xc716 |
| `update_gear_needles` (FUN_0000ccca) | same runtime cos_fixed14 / sin_fixed14 pair, applied; abs_int result restored | angle ((abs_int(gear) << 12) / 45) & 0x3fff, one for all three needles | bytes 0xcd02..0xcd4e |

## Code entries missing from Ghidra's function list (Pacific Conflict)

Both are installed as host hooks by overlay_main_entry (FUN_00001112) with runtime addresses
(file = value + 0x20) and have no FUN_ entry in the Ghidra export, so they are not in the
inventory yet.

| File address | Hook slot | Evidence | Behaviour |
| --- | --- | --- | --- |
| 0x4d0 | host +0x302 (stored 0x4b0) | bytes 0x4d0..0x4f6 | returns 1 when DAT_0001b738 is null or player y - ctl ground +0x2e > 4999, else 0 [PROVEN] |
| 0xd25a | host +0x316 (stored 0xd23a) | starts at 0xd25a right after the 0xd258 rts | first call update_view_readouts_and_overlays(0); body not yet reviewed |

## Readable global names (readability pass)

`#define` aliases added to the `*.decomp.c` files; the Ghidra symbol stays the real name.

| File | Alias | Ghidra symbol | Evidence |
|---|---|---|---|
| ID02 | `CurrentA5` | `DAT_00000904` | low-memory global $0904, read by every A5-safe routine to load the application A5 |
| ID02 | `vbl_ch0_a5_cache` | `DAT_000039c4` | PC-relative long at entry + 0x1c of the VBL handler 0x39a8; 0 until the priming call stores CurrentA5 there |
| ID02 | `vbl_ch0_variant_a5_cache` | `DAT_00003aca` | PC-relative long at entry + 0x1c of the VBL handler 0x3aae; 0 until the priming call stores CurrentA5 there |
| ID02 | `vbl_two_channel_a5_cache` | `DAT_00003be0` | PC-relative long at entry + 0x1c of the VBL handler 0x3bc4; 0 until the priming call stores CurrentA5 there |
| ID06 | `spans_active_base` | `DAT_0000039e` | render_scanline_spans PC-relative cell 0x39e: active edge array base (row table +4 of the edge pool) |
| ID06 | `spans_band_stride` | `DAT_000003a2` | render_scanline_spans PC-relative cell 0x3a2: dest stride added after each row (param 3) |
| ID06 | `spans_list_head` | `DAT_000003a6` | render_scanline_spans PC-relative cell 0x3a6: priority list head sentinel (edge pool +0x898) |
| ID06 | `spans_list_tail` | `DAT_000003aa` | render_scanline_spans PC-relative cell 0x3aa: tail sentinel (edge pool +0x89c), stored after the last active edge |
| ID06 | `spans_saved_d3_prev_x` | `DAT_000003ae` | render_scanline_spans PC-relative cell 0x3ae saved D3: previous edge x (fixed point) for the re-sort test |
| ID06 | `spans_saved_d4_mask_x` | `DAT_000003b2` | render_scanline_spans PC-relative cell 0x3b2 saved D4: x >> 6, masked with 0x3e0 to index the left-mask table |
| ID06 | `spans_saved_d5_edge_x` | `DAT_000003b6` | render_scanline_spans PC-relative cell 0x3b6 saved D5: edge x advanced by its slope |
| ID06 | `spans_saved_d6_out_long` | `DAT_000003ba` | render_scanline_spans PC-relative cell 0x3ba saved D6: pending output long (mask-merged span) |
| ID06 | `spans_saved_d7_active_end` | `DAT_000003be` | render_scanline_spans PC-relative cell 0x3be saved D7: end of the active edge array |
| ID06 | `spans_saved_a2_row_entry` | `DAT_000003c2` | render_scanline_spans PC-relative cell 0x3c2 saved A2: current 12-byte row entry (+0 bucket, +4 drop flag, +8 pattern table) |
| ID06 | `spans_saved_a3_scan` | `DAT_000003c6` | render_scanline_spans PC-relative cell 0x3c6 saved A3: insertion / compaction scan pointer, nonzero = list dirty |
| ID06 | `spans_saved_a4_edge` | `DAT_000003ca` | render_scanline_spans PC-relative cell 0x3ca saved A4: current edge node |
| ID06 | `spans_saved_a5_next_slot` | `DAT_000003ce` | render_scanline_spans PC-relative cell 0x3ce saved A5: next active edge slot |
| ID06 | `spans_saved_a6_temp` | `DAT_000003d2` | render_scanline_spans PC-relative cell 0x3d2 saved A6: frame pointer on entry, then a scratch pointer |
| ID06 | `CurrentA5` | `DAT_00000904` | same low-memory global as in ID02; read by set_active_row_count (CurrentA5 routine) |
| ID09 | `kbd_type_table_end` | `DAT_00000059` | LEA $59(PC) in sysenvirons_glue_fallback: one past the in-segment KbdType byte table 0x54..0x58, scanned backwards with DBEQ |
| Pacific Conflict | `host_world` | `DAT_0001b5a0` | pointer to the host A5 world at A5-0x1388 (see the DAT_0001b5a0 rows above); mission fuel % +0xb6, bombs +0xb8/+0xb9, kill counters +0xba.., friendly kills +0xd2 |
| Pacific Conflict | `object_pool` | `DAT_0001b5a4` | world object pointer array (entity array 2) walked by probe_nearest_facility_kind |
| Pacific Conflict | `object_count` | `DAT_0001b734` | low word = entry count of object_pool (16-bit dbra in probe_nearest_facility_kind) |
| Pacific Conflict | `player_object` | `DAT_0001b738` | the player's aircraft object (IMPORT_STATUS "player entity ptr"); controller fields +0x634..+0x684 |
| Pacific Conflict | `loadout_synced` | `_DAT_0001b73c` | set to 1 by load_player_fuel_and_bombs and when landing writes fuel/bombs back to host_world, cleared on takeoff; gates the write-back [STRONG INFERENCE] |
| Pacific Conflict | `clip_y_max` | `DAT_0001b73e` | polygon clip rectangle y-max (row above: DAT_00020aee / aec / aea / b73e), read by clip_polygon_y_max |
| Pacific Conflict | `clip_y_max_alt` | `DAT_0001b740` | word swapped into clip_y_max by collect_map_features for its last clip, then restored |
| Pacific Conflict | `session_entry_handle` | `DAT_0001b744` | handle sized entries (550 / 800) * 0x1c by allocate_session_buffers when host byte +0 is set [role UNKNOWN] |
| Pacific Conflict | `session_handles_a` | `DAT_0001b74c` | handle slots 1..3 sized rows (20 / 30) * host +0xc * 4 by allocate_session_buffers [role UNKNOWN] |
| Pacific Conflict | `session_handles_b` | `DAT_0001b75c` | second handle group of the same size (C indexes + 2 * slot) [role UNKNOWN] |
| Pacific Conflict | `session_buffers_rebuilt` | `_DAT_00020c4c` | cleared then set to 1 by allocate_session_buffers when any block was (re)allocated |
| Pacific Conflict | `session_entry_ptr` | `DAT_0001b76c` | data pointer of session_entry_handle stored by lock_session_buffers (& 0xffffff when host word +0x76), cleared by unlock_session_buffers |
| Pacific Conflict | `session_ptrs_a` | `DAT_0001b774` | data pointers of session_handles_a, slot i at + 4i (i = 1..3) |
| Pacific Conflict | `session_ptr_a_slot1` | `DAT_0001b778` | session_ptrs_a slot 1 |
| Pacific Conflict | `session_ptrs_b` | `DAT_0001b784` | data pointers of session_handles_b, slot i at + 4i |
| Pacific Conflict | `session_ptr_b_slot1` | `DAT_0001b788` | session_ptrs_b slot 1 |
| Pacific Conflict | `session_cur_b` | `DAT_0001b794` | = session_ptr_b_slot1 after lock_session_buffers, 0 after unlock |
| Pacific Conflict | `session_cur_a` | `DAT_0001b798` | = session_ptr_a_slot1 after lock_session_buffers, 0 after unlock |
| Pacific Conflict | `widened_format_buf` | `DAT_00020b4c` | static buffer written and returned by widen_printf_format (%d -> %ld, %x -> %lx) |
| Pacific Conflict | `palette_owner_slots` | `DAT_0001da6c` | slot-indexed base: + 4 * slot (1..3) addresses palette_owner_tables[slot - 1] (init_depth4_colour_state) |
| Pacific Conflict | `palette_owner_tables` | `DAT_0001da70` | three 256-long palette-slot owner tables at 0x1da70 / 74 / 78, (re)allocated by reset_palette_owner_tables |
| Pacific Conflict | `palette_owner_current` | `DAT_0001da7c` | owner table in use, reset to the first table |
| Pacific Conflict | `colour_tally_index` | `DAT_0001da8a` | cleared by the depth set-ups; indexes the byte counters at DAT_0001d864 [HYPOTHESIS role] |
| Pacific Conflict | `fill_colour` | `DAT_0001daa0` | host colour table word +0x1a0 (depth 8) / +0x10 (depth 4); used as a row colour by reset_background_rows [STRONG INFERENCE] |
| Pacific Conflict | `palette_direct_mode` | `_DAT_0001d85a` | nonzero: queue_face_palette_entry sets face +4 from r + g + b / 3 and queues no ColorSpec [role name STRONG INFERENCE] |
| Pacific Conflict | `slot_to_index_map` | `DAT_0001d85c` | word map palette slot -> pixel index, copied from host +0x34 |
| Pacific Conflict | `view_depth` | `DAT_0001b826` | current pixel depth tested by assign_face_colour: 1 dither patterns, 4 colour cube, otherwise palette slots |
| Pacific Conflict | `palette_search_cursor` | `DAT_0001bd80` | round-robin palette slot cursor (wraps at 200) in assign_face_colour |
| Pacific Conflict | `slot_usage_prev` | `DAT_0001d860` | one of the per-frame palette-slot usage maps swapped by overlay_frame_step (row above) |
| Pacific Conflict | `slot_usage_cur` | `DAT_0001d864` | the other usage map; which one is current is STRONG INFERENCE |
| Pacific Conflict | `palette_changed` | `_DAT_0001daa2` | set to 1 when a face claims a palette slot (assign_face_colour) and by build_object_poly_buffers |
| Pacific Conflict | `template_ptr_table_base` | `DAT_0001b524` | ID-keyed definition record pointer table: entry key at + 4 * key (docs/DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `template_rec_a_field_u16` | `DAT_0001a7d2` | name from its declaration comment: field +0xc of a 0x4A template record |
| Pacific Conflict | `template_rec_b_field_u16` | `DAT_0001a81c` | name from its declaration comment: same field of the next 0x4A record |
| Pacific Conflict | `template_keyed_1c_src` | `DAT_0001aa5e` | source of the five keyed 0x1C template records (keys 0x15..0x19) |
| Pacific Conflict | `def_key05` | `DAT_0001b538` | template_ptr_table_base slot +0x14 (key 5): clone of template_key05 |
| Pacific Conflict | `template_key05` | `DAT_0001a8b8` | static template record copied into def_key05 |
| Pacific Conflict | `def_key06` | `PTR_DAT_0001b53c` | template_ptr_table_base slot +0x18 (key 6): clone of template_key06 |
| Pacific Conflict | `template_key06` | `DAT_0001a8d2` | static template record copied into def_key06 |
| Pacific Conflict | `def_key07` | `PTR_DAT_0001b540` | template_ptr_table_base slot +0x1c (key 7): clone of template_key07 |
| Pacific Conflict | `template_key07` | `DAT_0001a8ec` | static template record copied into def_key07 |
| Pacific Conflict | `def_key10` | `DAT_0001b54c` | template_ptr_table_base slot +0x28 (key 10): clone of template_key10 |
| Pacific Conflict | `template_key10` | `DAT_0001a906` | static template record copied into def_key10 |
| Pacific Conflict | `def_key11` | `DAT_0001b550` | template_ptr_table_base slot +0x2c (key 11): clone of template_key11 |
| Pacific Conflict | `template_key11` | `DAT_0001a920` | static template record copied into def_key11 |
| Pacific Conflict | `def_key08` | `DAT_0001b544` | template_ptr_table_base slot +0x20 (key 8): clone of template_key08 |
| Pacific Conflict | `template_key08` | `DAT_0001a93a` | static template record copied into def_key08 |
| Pacific Conflict | `def_key09` | `DAT_0001b548` | template_ptr_table_base slot +0x24 (key 9): clone of template_key09 |
| Pacific Conflict | `template_key09` | `DAT_0001a954` | static template record copied into def_key09 |
| Pacific Conflict | `def_key17` | `DAT_0001b568` | template_ptr_table_base slot +0x44 (key 17): clone of template_key17 |
| Pacific Conflict | `template_key17` | `DAT_0001a96e` | static template record copied into def_key17 |
| Pacific Conflict | `def_key12` | `DAT_0001b554` | template_ptr_table_base slot +0x30 (key 12): clone of template_key12 |
| Pacific Conflict | `template_key12` | `DAT_0001a988` | static template record copied into def_key12 |
| Pacific Conflict | `def_key13` | `DAT_0001b558` | template_ptr_table_base slot +0x34 (key 13): clone of template_key13 |
| Pacific Conflict | `template_key13` | `DAT_0001a9a8` | static template record copied into def_key13 |
| Pacific Conflict | `def_key14` | `DAT_0001b55c` | template_ptr_table_base slot +0x38 (key 14): clone of template_key14 |
| Pacific Conflict | `template_key14` | `DAT_0001a9c2` | static template record copied into def_key14 |
| Pacific Conflict | `def_key15` | `DAT_0001b560` | template_ptr_table_base slot +0x3c (key 15): clone of template_key15 |
| Pacific Conflict | `template_key15` | `DAT_0001a9dc` | static template record copied into def_key15 |
| Pacific Conflict | `def_key16` | `DAT_0001b564` | template_ptr_table_base slot +0x40 (key 16): clone of template_key16 |
| Pacific Conflict | `template_key16` | `DAT_0001a9f6` | static template record copied into def_key16 |
| Pacific Conflict | `def_key18` | `DAT_0001b56c` | template_ptr_table_base slot +0x48 (key 18): clone of template_key18 |
| Pacific Conflict | `template_key18` | `DAT_0001aa10` | static template record copied into def_key18 |
| Pacific Conflict | `def_key19` | `DAT_0001b570` | template_ptr_table_base slot +0x4c (key 19): clone of template_key19 |
| Pacific Conflict | `template_key19` | `DAT_0001aa2a` | static template record copied into def_key19 |
| Pacific Conflict | `def_key20` | `DAT_0001b574` | template_ptr_table_base slot +0x50 (key 20): clone of template_key20 |
| Pacific Conflict | `template_key20` | `DAT_0001aa44` | static template record copied into def_key20 |
| Pacific Conflict | `def_key26` | `DAT_0001b58c` | template_ptr_table_base slot +0x68 (key 26): clone of template_key26 |
| Pacific Conflict | `template_key26` | `DAT_0001aaea` | static template record copied into def_key26 |
| Pacific Conflict | `def_key27` | `DAT_0001b590` | template_ptr_table_base slot +0x6c (key 27): clone of template_key27 |
| Pacific Conflict | `template_key27` | `DAT_0001ab04` | static template record copied into def_key27 |
| Pacific Conflict | `def_key28` | `DAT_0001b594` | template_ptr_table_base slot +0x70 (key 28): clone of template_key28 |
| Pacific Conflict | `template_key28` | `DAT_0001ab1e` | static template record copied into def_key28 |
| Pacific Conflict | `def_key29` | `DAT_0001b598` | template_ptr_table_base slot +0x74 (key 29): clone of template_key29 |
| Pacific Conflict | `template_key29` | `DAT_0001ab38` | static template record copied into def_key29 |
| Pacific Conflict | `def_key30` | `DAT_0001b59c` | template_ptr_table_base slot +0x78 (key 30): clone of template_key30 |
| Pacific Conflict | `template_key30` | `DAT_0001ab52` | static template record copied into def_key30 |
| Pacific Conflict | `scene_root` | `DAT_0001d6fc` | root object instantiated from host +0x8c by init_mission_object_tables; child table at +0x30, 0x18-byte records |
| Pacific Conflict | `mission_child0` | `DAT_0001bdb4` | child[0] object published by init_mission_object_tables [role UNKNOWN] |
| Pacific Conflict | `mission_child1` | `DAT_0001bdb0` | child[1] object published by init_mission_object_tables [role UNKNOWN] |
| Pacific Conflict | `mission_child2or3` | `DAT_0001bdac` | child[3] in mission 2, else child[2] [role UNKNOWN] |
| Pacific Conflict | `default_surface_face` | `DAT_0001bda8` | mission_child2or3 +0x48; surface_type_at_point falls back to its +0x16 code [STRONG INFERENCE] |
| Pacific Conflict | `mission_child4` | `DAT_0001bda4` | child[4] object published by init_mission_object_tables [role UNKNOWN] |
| Pacific Conflict | `child_window_lo` | `DAT_0001b88e` | root word +0x2c - 1: first index of the published child window |
| Pacific Conflict | `child_window_hi` | `DAT_0001b88c` | child_window_lo + 2 |
| Pacific Conflict | `child_window_prev` | `DAT_0001bc28` | child object at index root +0x2c - 1 |
| Pacific Conflict | `child_window_cur` | `DAT_0001bc34` | child object at index root +0x2c |
| Pacific Conflict | `child_window_next` | `DAT_0001bc38` | child object at index root +0x2c + 1 |
| Pacific Conflict | `slot_usage_buf_a` | `DAT_0001d86c` | first per-frame palette usage buffer, assigned to slot_usage_prev by overlay_initialise |
| Pacific Conflict | `slot_usage_buf_b` | `DAT_0001d96c` | second per-frame palette usage buffer, assigned to slot_usage_cur by overlay_initialise |
| Pacific Conflict | `light_x` | `DAT_0001bd8c` | light direction x component, 0xd983 at start (shade_object_faces) |
| Pacific Conflict | `light_y` | `DAT_0001bd8a` | light direction y component, 0x69d8 at start |
| Pacific Conflict | `light_z` | `DAT_0001bd88` | light direction z component, 0xc330 at start |
| Pacific Conflict | `init_flag_bd84` | `_DAT_0001bd84` | set to 1 by overlay_initialise, no reader in the exported C [role UNKNOWN] |
| Pacific Conflict | `frame_counter` | `DAT_0001b838` | current frame number, incremented by advance_frame_and_tick_controllers; 0x4c at start |
| Pacific Conflict | `heap_break` | `DAT_00020c50` | heap_sbrk break: byte offset into the arena at host +0x348 |
| Pacific Conflict | `heap_roving_cursor` | `DAT_00020c60` | large-block free-list cursor (docs/DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `heap_class_lists` | `DAT_00020c64` | size-class free-list heads, class c at + 4 * c (heap_free_coalesce small path) |
| Pacific Conflict | `heap_ring_sentinel` | `DAT_00020c58` | size-0 sentinel of the large-block ring; heap_alloc links it to itself when heap_roving_cursor is still 0 |
| Pacific Conflict | `heap_ring_sentinel_next` | `DAT_00020c5c` | the sentinel next link (+4) |
| Pacific Conflict | `sin_table` | `DAT_0001ab6c` | 256 words round(4096 sin(i pi / 128)), read by sin_fixed14 (row for FUN_00001d76 above) |
| Pacific Conflict | `cos_table` | `DAT_0001ad6c` | 256 words round(4096 cos(i pi / 128)), read by cos_fixed14 |
| Pacific Conflict | `tan_table` | `DAT_0001af6c` | 128 longs 4096 tan((i - 0x3f) pi / 128) searched by atan_fixed14; entry 127 (110980) breaks the order |
| Pacific Conflict | `angle1_cos` | `DAT_0001d7fa` | cos_fixed14 of argument 1 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle1_sin` | `DAT_0001d7fc` | sin_fixed14 of argument 1 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle2_cos` | `DAT_0001d7f6` | cos_fixed14 of argument 2 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle2_sin` | `DAT_0001d7f8` | sin_fixed14 of argument 2 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle3_cos` | `DAT_0001d7f2` | cos_fixed14 of argument 3 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle3_sin` | `DAT_0001d7f4` | sin_fixed14 of argument 3 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle4_cos` | `DAT_0001d7ee` | cos_fixed14 of argument 4 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle4_sin` | `DAT_0001d7f0` | sin_fixed14 of argument 4 of load_attitude_angle_sincos (4.12 word) |
| Pacific Conflict | `angle5_cos` | `DAT_0001d7ea` | cos_fixed14 of argument 1 of load_attitude_angle_sincos_5_6 |
| Pacific Conflict | `angle5_sin` | `DAT_0001d7ec` | sin_fixed14 of argument 1 of load_attitude_angle_sincos_5_6 |
| Pacific Conflict | `angle6_cos` | `DAT_0001d7e6` | cos_fixed14 of argument 2 of load_attitude_angle_sincos_5_6 |
| Pacific Conflict | `angle6_sin` | `DAT_0001d7e8` | sin_fixed14 of argument 2 of load_attitude_angle_sincos_5_6 |
| Pacific Conflict | `basis1_m00` | `DAT_0001d7d4` | 3x3 s16 matrix at 0x1d7d4, element [0][0]; ~Rx from angle 1 (fill_attitude_rotation_bases) |
| Pacific Conflict | `basis1_m01` | `DAT_0001d7d6` | basis1 element [0][1] |
| Pacific Conflict | `basis1_m02` | `DAT_0001d7d8` | basis1 element [0][2] |
| Pacific Conflict | `basis1_m10` | `DAT_0001d7da` | basis1 element [1][0] |
| Pacific Conflict | `basis1_m11` | `DAT_0001d7dc` | basis1 element [1][1] |
| Pacific Conflict | `basis1_m12` | `DAT_0001d7de` | basis1 element [1][2] |
| Pacific Conflict | `basis1_m20` | `DAT_0001d7e0` | basis1 element [2][0] |
| Pacific Conflict | `basis1_m21` | `DAT_0001d7e2` | basis1 element [2][1] |
| Pacific Conflict | `basis1_m22` | `DAT_0001d7e4` | basis1 element [2][2] |
| Pacific Conflict | `basis2_m00` | `DAT_0001d7bc` | 3x3 s16 matrix at 0x1d7bc, element [0][0]; ~Ry from angle 2 |
| Pacific Conflict | `basis2_m01` | `DAT_0001d7be` | basis2 element [0][1] |
| Pacific Conflict | `basis2_m02` | `DAT_0001d7c0` | basis2 element [0][2] |
| Pacific Conflict | `basis2_m10` | `DAT_0001d7c2` | basis2 element [1][0] |
| Pacific Conflict | `basis2_m11` | `DAT_0001d7c4` | basis2 element [1][1] |
| Pacific Conflict | `basis2_m12` | `DAT_0001d7c6` | basis2 element [1][2] |
| Pacific Conflict | `basis2_m20` | `DAT_0001d7c8` | basis2 element [2][0] |
| Pacific Conflict | `basis2_m21` | `DAT_0001d7ca` | basis2 element [2][1] |
| Pacific Conflict | `basis2_m22` | `DAT_0001d7cc` | basis2 element [2][2] |
| Pacific Conflict | `basis3_m00` | `DAT_0001d7a4` | 3x3 s16 matrix at 0x1d7a4, element [0][0]; ~Rz from angle 3 |
| Pacific Conflict | `basis3_m01` | `DAT_0001d7a6` | basis3 element [0][1] |
| Pacific Conflict | `basis3_m02` | `DAT_0001d7a8` | basis3 element [0][2] |
| Pacific Conflict | `basis3_m10` | `DAT_0001d7aa` | basis3 element [1][0] |
| Pacific Conflict | `basis3_m11` | `DAT_0001d7ac` | basis3 element [1][1] |
| Pacific Conflict | `basis3_m12` | `DAT_0001d7ae` | basis3 element [1][2] |
| Pacific Conflict | `basis3_m20` | `DAT_0001d7b0` | basis3 element [2][0] |
| Pacific Conflict | `basis3_m21` | `DAT_0001d7b2` | basis3 element [2][1] |
| Pacific Conflict | `basis3_m22` | `DAT_0001d7b4` | basis3 element [2][2] |
| Pacific Conflict | `basis4_m00` | `DAT_0001d78c` | 3x3 s16 matrix at 0x1d78c, element [0][0]; ~Ry (or ~Rx) from angle 4 (fill_attitude_rotation_basis_4 / _rx) |
| Pacific Conflict | `basis4_m01` | `DAT_0001d78e` | basis4 element [0][1] |
| Pacific Conflict | `basis4_m02` | `DAT_0001d790` | basis4 element [0][2] |
| Pacific Conflict | `basis4_m10` | `DAT_0001d792` | basis4 element [1][0] |
| Pacific Conflict | `basis4_m11` | `DAT_0001d794` | basis4 element [1][1] |
| Pacific Conflict | `basis4_m12` | `DAT_0001d796` | basis4 element [1][2] |
| Pacific Conflict | `basis4_m20` | `DAT_0001d798` | basis4 element [2][0] |
| Pacific Conflict | `basis4_m21` | `DAT_0001d79a` | basis4 element [2][1] |
| Pacific Conflict | `basis4_m22` | `DAT_0001d79c` | basis4 element [2][2] |
| Pacific Conflict | `basis5_m00` | `DAT_0001d774` | 3x3 s16 matrix at 0x1d774, element [0][0]; ~Rx from angle 5 (fill_attitude_rotation_bases_5_6) |
| Pacific Conflict | `basis5_m01` | `DAT_0001d776` | basis5 element [0][1] |
| Pacific Conflict | `basis5_m02` | `DAT_0001d778` | basis5 element [0][2] |
| Pacific Conflict | `basis5_m10` | `DAT_0001d77a` | basis5 element [1][0] |
| Pacific Conflict | `basis5_m11` | `DAT_0001d77c` | basis5 element [1][1] |
| Pacific Conflict | `basis5_m12` | `DAT_0001d77e` | basis5 element [1][2] |
| Pacific Conflict | `basis5_m20` | `DAT_0001d780` | basis5 element [2][0] |
| Pacific Conflict | `basis5_m21` | `DAT_0001d782` | basis5 element [2][1] |
| Pacific Conflict | `basis5_m22` | `DAT_0001d784` | basis5 element [2][2] |
| Pacific Conflict | `basis6_m00` | `DAT_0001d75c` | 3x3 s16 matrix at 0x1d75c, element [0][0]; ~Ry from angle 6 (fill_attitude_rotation_bases_5_6) |
| Pacific Conflict | `basis6_m01` | `DAT_0001d75e` | basis6 element [0][1] |
| Pacific Conflict | `basis6_m02` | `DAT_0001d760` | basis6 element [0][2] |
| Pacific Conflict | `basis6_m10` | `DAT_0001d762` | basis6 element [1][0] |
| Pacific Conflict | `basis6_m11` | `DAT_0001d764` | basis6 element [1][1] |
| Pacific Conflict | `basis6_m12` | `DAT_0001d766` | basis6 element [1][2] |
| Pacific Conflict | `basis6_m20` | `DAT_0001d768` | basis6 element [2][0] |
| Pacific Conflict | `basis6_m21` | `DAT_0001d76a` | basis6 element [2][1] |
| Pacific Conflict | `basis6_m22` | `DAT_0001d76c` | basis6 element [2][2] |
| Pacific Conflict | `attitude_compose_tag` | `DAT_00020ce4` | composer tag ($2408 / $2468 / $26e0) set by finalize_attitude_matrix_3ang / compose_attitude_matrix_x / 6ang and jumped through by invoke_tagged_attitude_compose_neg_sins4 / 6 |
| Pacific Conflict | `camera_m00` | `DAT_0001d744` | 3x3 s16 camera attitude matrix at 0x1d744, element [0][0]: overlay_frame_step builds the inverse (view) form from the negated camera angles, then the forward form [STRONG INFERENCE role] |
| Pacific Conflict | `camera_m01` | `DAT_0001d746` | camera matrix element [0][1] |
| Pacific Conflict | `camera_m02` | `DAT_0001d748` | camera matrix element [0][2] |
| Pacific Conflict | `camera_m10` | `DAT_0001d74a` | camera matrix element [1][0] |
| Pacific Conflict | `camera_m11` | `DAT_0001d74c` | camera matrix element [1][1] |
| Pacific Conflict | `camera_m12` | `DAT_0001d74e` | camera matrix element [1][2] |
| Pacific Conflict | `camera_m20` | `DAT_0001d750` | camera matrix element [2][0] |
| Pacific Conflict | `camera_m21` | `DAT_0001d752` | camera matrix element [2][1] |
| Pacific Conflict | `camera_m22` | `DAT_0001d754` | camera matrix element [2][2] |
| Pacific Conflict | `visible_list` | `DAT_0001c9dc` | visible object pointer list (build_visible_object_list) |
| Pacific Conflict | `visible_count` | `DAT_0001c1d4` | visible object list count (low word) |
| Pacific Conflict | `visible_list_split` | `DAT_0001bdb8` | visible_count saved after update_ground_scatter_objects; transform_listed_object_vecs12_by_1d744 handles the entries from here on |
| Pacific Conflict | `edge_sentinel` | `DAT_0001b174` | sentinel edge record in scan_convert_edge_rows: view_right_x << 16 | 0x8000 |
| Pacific Conflict | `edge_sentinel_colour` | `PTR_PTR_0001b188` | sentinel record colour long: fill_colour | 0xffff0000 |
| Pacific Conflict | `view_width` | `DAT_0001b82a` | view width in pixels (host +0x16 = A5-0x1372, configure_renderer_for_display); also the span-row end / sentinel x |
| Pacific Conflict | `half_rows_mode` | `DAT_0001b834` | nonzero halves the last scan row in scan_convert_edge_rows [role UNKNOWN] |
| Pacific Conflict | `row_has_edges` | `DAT_0001daa4` | word flag per row: the row's edge bucket is non-empty |
| Pacific Conflict | `row_edge_buckets` | `DAT_0001eaac` | per-row edge bucket heads filled by add_face_edges_to_rows |
| Pacific Conflict | `edge_pool_count` | `DAT_00020ab0` | edge pool count, reset to 0 at the end of scan_convert_edge_rows |
| Pacific Conflict | `scan_last_row` | `DAT_00020ae6` | last scan row (clip_y_max + rows / 2 per update_view_clip_bounds) |
| Pacific Conflict | `spans32ba_slot0` | `DAT_00003242` | entry 0 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot1` | `DAT_00003246` | entry 1 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot2` | `DAT_0000324a` | entry 2 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot3` | `DAT_0000324e` | entry 3 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot4` | `DAT_00003252` | entry 4 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot5` | `DAT_00003256` | entry 5 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot6` | `DAT_0000325a` | entry 6 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot7` | `DAT_0000325e` | entry 7 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_slot8` | `DAT_00003262` | entry 8 of the nine-long table inside the code before the span routine 0x32ba (init_span_table_32ba; self-modifying) |
| Pacific Conflict | `spans32ba_code_335a` | `DAT_0000335a` | code address 0x335a stored into the span routine 0x32ba table |
| Pacific Conflict | `spans32ba_code_336c` | `DAT_0000336c` | code address 0x336c stored into the span routine 0x32ba table |
| Pacific Conflict | `spans32ba_code_3374` | `DAT_00003374` | code address 0x3374 stored into the span routine 0x32ba table |
| Pacific Conflict | `spans32ba_code_3378` | `DAT_00003378` | code address 0x3378 stored into the span routine 0x32ba table |
| Pacific Conflict | `spans32ba_code_33a4` | `DAT_000033a4` | code address 0x33a4 stored into the span routine 0x32ba table |
| Pacific Conflict | `spans3466_slot0` | `DAT_000033ee` | entry 0 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot1` | `DAT_000033f2` | entry 1 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot2` | `DAT_000033f6` | entry 2 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot3` | `DAT_000033fa` | entry 3 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot4` | `DAT_000033fe` | entry 4 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot5` | `DAT_00003402` | entry 5 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot6` | `DAT_00003406` | entry 6 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot7` | `DAT_0000340a` | entry 7 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_slot8` | `DAT_0000340e` | entry 8 of the nine-long table inside the code before the span routine 0x3466 (init_span_table_3466; self-modifying) |
| Pacific Conflict | `spans3466_code_34fc` | `DAT_000034fc` | code address 0x34fc stored into the span routine 0x3466 table |
| Pacific Conflict | `spans3466_code_350e` | `DAT_0000350e` | code address 0x350e stored into the span routine 0x3466 table |
| Pacific Conflict | `spans3466_code_3516` | `DAT_00003516` | code address 0x3516 stored into the span routine 0x3466 table |
| Pacific Conflict | `spans3466_code_351a` | `DAT_0000351a` | code address 0x351a stored into the span routine 0x3466 table |
| Pacific Conflict | `spans3466_code_3546` | `DAT_00003546` | code address 0x3546 stored into the span routine 0x3466 table |
| Pacific Conflict | `spans3608_slot0` | `DAT_00003590` | entry 0 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot1` | `DAT_00003594` | entry 1 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot2` | `DAT_00003598` | entry 2 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot3` | `DAT_0000359c` | entry 3 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot4` | `DAT_000035a0` | entry 4 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot5` | `DAT_000035a4` | entry 5 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot6` | `DAT_000035a8` | entry 6 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot7` | `DAT_000035ac` | entry 7 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_slot8` | `DAT_000035b0` | entry 8 of the nine-long table inside the code before the span routine 0x3608 (init_span_table_3608; self-modifying) |
| Pacific Conflict | `spans3608_code_369e` | `DAT_0000369e` | code address 0x369e stored into the span routine 0x3608 table |
| Pacific Conflict | `spans3608_code_36b0` | `DAT_000036b0` | code address 0x36b0 stored into the span routine 0x3608 table |
| Pacific Conflict | `spans3608_code_36b8` | `DAT_000036b8` | code address 0x36b8 stored into the span routine 0x3608 table |
| Pacific Conflict | `spans3608_code_36bc` | `DAT_000036bc` | code address 0x36bc stored into the span routine 0x3608 table |
| Pacific Conflict | `spans3608_code_36e8` | `DAT_000036e8` | code address 0x36e8 stored into the span routine 0x3608 table |
| Pacific Conflict | `span8_entries_a` | `DAT_00020cec` | 0x800-long code-pointer table at 0x20cec indexed by run length in fill_span_rows_8bit [STRONG INFERENCE]; entry 0 |
| Pacific Conflict | `span8_entries_a_1` | `DAT_00020cf0` | span8_entries_a entry 1 |
| Pacific Conflict | `span8_entries_a_2` | `DAT_00020cf4` | span8_entries_a entry 2 |
| Pacific Conflict | `span8_entries_a_3` | `DAT_00020cf8` | span8_entries_a entry 3 |
| Pacific Conflict | `span8_entries_a_4` | `DAT_00020cfc` | span8_entries_a entry 4 |
| Pacific Conflict | `span8_entries_a_5` | `DAT_00020d00` | span8_entries_a entry 5 |
| Pacific Conflict | `span8_entries_a_rest` | `DAT_00020d04` | span8_entries_a entries 6.. (default handler copies) |
| Pacific Conflict | `span8_entries_b` | `DAT_00022cec` | 0x800-long code-pointer table at 0x22cec indexed by run length in fill_span_rows_8bit [STRONG INFERENCE]; entry 0 |
| Pacific Conflict | `span8_entries_b_1` | `DAT_00022cf0` | span8_entries_b entry 1 |
| Pacific Conflict | `span8_entries_b_2` | `DAT_00022cf4` | span8_entries_b entry 2 |
| Pacific Conflict | `span8_entries_b_3` | `DAT_00022cf8` | span8_entries_b entry 3 |
| Pacific Conflict | `span8_entries_b_4` | `DAT_00022cfc` | span8_entries_b entry 4 |
| Pacific Conflict | `span8_entries_b_5` | `DAT_00022d00` | span8_entries_b entry 5 |
| Pacific Conflict | `span8_entries_b_6` | `DAT_00022d04` | span8_entries_b entry 6 |
| Pacific Conflict | `span8_entries_b_rest` | `DAT_00022d08` | span8_entries_b entries 7.. (default handler copies) |
| Pacific Conflict | `span8_code_3836` | `DAT_00003836` | code address 0x3836 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_383e` | `DAT_0000383e` | code address 0x383e stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_3840` | `DAT_00003840` | code address 0x3840 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_3842` | `DAT_00003842` | code address 0x3842 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_384e` | `DAT_0000384e` | code address 0x384e stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_3850` | `DAT_00003850` | code address 0x3850 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_3858` | `DAT_00003858` | code address 0x3858 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_3882` | `DAT_00003882` | code address 0x3882 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_388c` | `DAT_0000388c` | code address 0x388c stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_3898` | `DAT_00003898` | code address 0x3898 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_389c` | `DAT_0000389c` | code address 0x389c stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_38a8` | `DAT_000038a8` | code address 0x38a8 stored by init_code_pointer_tables |
| Pacific Conflict | `span8_code_38b6` | `DAT_000038b6` | code address 0x38b6 stored by init_code_pointer_tables |
| Pacific Conflict | `anchor_x` | `DAT_0001d83c` | anchor record (find_anchor_point result) +0: x; the record pointer is &anchor_x |
| Pacific Conflict | `anchor_y` | `DAT_0001d840` | anchor record +4: y |
| Pacific Conflict | `anchor_z` | `DAT_0001d844` | anchor record +8: z |
| Pacific Conflict | `anchor_angle1` | `DAT_0001d84a` | low word of anchor record +0xc, first angle |
| Pacific Conflict | `anchor_angle2` | `DAT_0001d84e` | low word of anchor record +0x10, second angle |
| Pacific Conflict | `anchor_angle3` | `DAT_0001d852` | low word of anchor record +0x14, third angle |
| Pacific Conflict | `anchor_found` | `DAT_0001d854` | anchor record word +0x18, set when find_anchor_point found a point; nonzero skips the search here |
| Pacific Conflict | `view_mode` | `DAT_0001d858` | camera view mode word (set to 1 on respawn; < 6 / == 2 tests in overlay_frame_step) [STRONG INFERENCE] |
| Pacific Conflict | `player_landing_state` | `DAT_0001b868` | 0 airborne/reset, 1 touchdown, 2 stopped (docs/DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `replay_request` | `DAT_0001b86c` | pending instant-replay request: 0 none, 1 airborne, 2 on the ground (request_instant_replay) |
| Pacific Conflict | `state_flag_b872` | `_DAT_0001b872` | word cleared on respawn, set 0 / 1 in process_flight_input_and_outcome [role UNKNOWN] |
| Pacific Conflict | `state_flag_b874` | `_DAT_0001b874` | word cleared on respawn; must be 0 for bail-out and view changes [role UNKNOWN] |
| Pacific Conflict | `parachute_object` | `DAT_0001b87c` | pointer to the bail-out parachute object slot (view 8 -> 9 when it exists) [STRONG INFERENCE] |
| Pacific Conflict | `mission_scene_object` | `DAT_0001d700` | current mission scene object: scene_root child table +0x74 + mission * 0x18, released by start_mission_scene |
| Pacific Conflict | `camera_x` | `DAT_0001d838` | camera position x, set from the anchor by start_mission_scene |
| Pacific Conflict | `camera_y` | `DAT_0001d834` | camera position y |
| Pacific Conflict | `camera_z` | `DAT_0001d830` | camera position z |
| Pacific Conflict | `ext_camera_point` | `DAT_0001d824` | stored external-camera point record (x first); 1000000000 = none (point_near_camera_or_type80_object) |
| Pacific Conflict | `view_flag_d856` | `_DAT_0001d856` | word set to 1 with view_mode by start_mission_scene; tested in overlay_frame_step [role UNKNOWN] |
| Pacific Conflict | `band_limits_lo` | `DAT_0001b18c` | distance band thresholds T[-1] (= 0): band i starts at band_limits_lo[i] = band_limits[i - 1] |
| Pacific Conflict | `band_limits` | `DAT_0001b190` | ascending distance band thresholds T[0..] (40041, 81395, ...): band i ends below band_limits[i] |
| Pacific Conflict | `entity_array_1` | `DAT_0001d4a4` | first entity pointer array (docs/STRUCTS.md entity_array_1; ticked by run_simulation_tick) |
| Pacific Conflict | `entity_array_1_count` | `DAT_0001c1e0` | entry count of entity_array_1 (docs/STRUCTS.md) |
| Pacific Conflict | `entity_array_3` | `DAT_0001d0e4` | third entity pointer array (docs/STRUCTS.md entity_array_3), ticked with path 1 |
| Pacific Conflict | `entity_array_3_count` | `DAT_0001c1dc` | entry count of entity_array_3 |
| Pacific Conflict | `entity_array_4` | `DAT_0001cbe4` | fourth entity pointer array (docs/STRUCTS.md entity_array_4), ticked with path 1 |
| Pacific Conflict | `entity_array_4_count` | `DAT_0001c1d8` | entry count of entity_array_4 |
| Pacific Conflict | `clip_x_min` | `DAT_00020aee` | polygon clip rectangle x-min, read by clip_polygon_x_min |
| Pacific Conflict | `clip_x_max` | `DAT_00020aec` | polygon clip rectangle x-max, read by clip_polygon_x_max |
| Pacific Conflict | `clip_y_min` | `DAT_00020aea` | polygon clip rectangle y-min, read by clip_polygon_y_min |
| Pacific Conflict | `detail_ref_x` | `DAT_0001d724` | x of the detail reference point (update_altitude_detail_bands triple d724 / d720 / d71c); stored at obj +0x18 by build_land_outline_at_detail [STRONG INFERENCE] |
| Pacific Conflict | `detail_ref_z` | `DAT_0001d71c` | z of the detail reference point; stored at obj +0x20 [STRONG INFERENCE] |
| Pacific Conflict | `controller_list` | `DAT_0001c25c` | active controller pointer list, ticked by advance_frame_and_tick_controllers through definition +2 |
| Pacific Conflict | `controller_count` | `DAT_0001c1cc` | entry count of controller_list |
| Pacific Conflict | `player_shot_ctl` | `DAT_0001b880` | controller of the player's latest gun / missile entity (latched in process_flight_input_and_outcome) [STRONG INFERENCE] |
| Pacific Conflict | `scatter_slots` | `DAT_0001bc64` | 7 ground-scatter object slots (update_ground_scatter_objects, clear_pending_entity_slots) |
| Pacific Conflict | `retire_count` | `DAT_00024cf0` | entities retired since the last reset; above 0x13 overlay_frame_step calls reset_distance_base_globals and clears it |
| Pacific Conflict | `view_points` | `DAT_0001c43c` | camera-relative object points (3 longs, shifted by the object's detail level) appended by collect_near_objects |
| Pacific Conflict | `view_point_count` | `DAT_0001c1d0` | entry count of view_points |
| Pacific Conflict | `overlap_list` | `DAT_0001c1e4` | objects with flag-long bit 15, collected each frame; dispatch_overlap_collisions walks it |
| Pacific Conflict | `overlap_count` | `DAT_0001c1c4` | entry count of overlap_list |
| Pacific Conflict | `replay_state` | `DAT_0001b870` | instant-replay state: 0 live, 1 rewind, other non-zero replaying, 3 controller tick restricted (docs/DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `designated_entity_2` | `DAT_0001b888` | second designated entity pointer (docs/IMPORT_STATUS.md), cleared each frame by dispatch_overlap_collisions unless replay_state == 3 [role UNKNOWN] |
| Pacific Conflict | `visible_first_pass` | `DAT_0001c1c0` | visible-list count before world objects (word): first-pass count of build_visible_object_list |
| Pacific Conflict | `alt_band` | `DAT_0001d70c` | altitude band: power of two at or below camera_y |
| Pacific Conflict | `alt_band_log2` | `DAT_0001d704` | log2 of alt_band (word) |
| Pacific Conflict | `alt_value_table` | `DAT_0001b214` | longs per altitude band, interpolated into the y of the reference shapes [STRONG INFERENCE] |
| Pacific Conflict | `alt_tolerance_table` | `DAT_0001b264` | longs per altitude band: outline tolerance for build_land_outline_at_detail |
| Pacific Conflict | `detail_ref_y` | `DAT_0001d720` | y of the near rebuild reference point (with detail_ref_x / detail_ref_z) |
| Pacific Conflict | `far_ref_x` | `DAT_0001d718` | x of the far rebuild reference point |
| Pacific Conflict | `far_ref_y` | `DAT_0001d714` | y of the far rebuild reference point |
| Pacific Conflict | `far_ref_z` | `DAT_0001d710` | z of the far rebuild reference point |
| Pacific Conflict | `scatter_point_x` | `DAT_0001b924` | 64 ground scatter points of 3 longs (x, y, z): x; the array base |
| Pacific Conflict | `scatter_point_y` | `DAT_0001b928` | scatter point y (always 0) |
| Pacific Conflict | `scatter_point_z` | `DAT_0001b92c` | scatter point z |
| Pacific Conflict | `scatter_state` | `DAT_0001b8e4` | 64 point state bytes: 0x80 visible, 0x40 surface cached, low 6 bits = slot or 0x3f |
| Pacific Conflict | `scatter_surface` | `DAT_0001b8a4` | 64 cached surface-type bytes (surface_type_at_point) |
| Pacific Conflict | `scatter_slot_point` | `DAT_0001b894` | word per scatter slot: index of its point |
| Pacific Conflict | `scatter_templates` | `DAT_0001bc24` | template object per surface type >> 4 (0 = none) |
| Pacific Conflict | `proj_scale_x` | `DAT_00020b28` | projection scale word for screen x |
| Pacific Conflict | `proj_scale_y` | `DAT_00020b26` | projection scale word for screen y |
| Pacific Conflict | `scatter_started` | `_DAT_00024cec` | set on the first scatter update, cleared when ground detail is off or too high |
| Pacific Conflict | `neg_camera_pitch` | `DAT_0001d810` | negated camera pitch word (docs/DECOMPILATION_SYMBOLS.md: camera pitch DAT_00024d1a) |
| Pacific Conflict | `neg_camera_heading` | `DAT_0001d80e` | negated camera heading word (camera heading DAT_00024d18) |
| Pacific Conflict | `camera_angle3` | `DAT_0001d80c` | third camera angle word passed to the camera matrix builders [role UNKNOWN] |
| Pacific Conflict | `camera_angle4` | `DAT_0001d808` | fourth camera angle long passed to the camera matrix builders [role UNKNOWN] |
| Pacific Conflict | `camera_angle5` | `DAT_0001d804` | fifth camera angle (view mode 2 only) [role UNKNOWN] |
| Pacific Conflict | `camera_angle6` | `DAT_0001d800` | sixth camera angle (view mode 2 only) [role UNKNOWN] |
| Pacific Conflict | `object_pool_next` | `DAT_0001b5a8` | object_pool + 1 entry: target of the insertion sort by camera metric |
| Pacific Conflict | `carried_pair_count` | `DAT_0001b85c` | carried-pair count (docs/DECOMPILATION_SYMBOLS.md), cleared every frame |
| Pacific Conflict | `carried_pairs` | `DAT_0001b860` | carried-pair array of {carrier, rider} objects |
| Pacific Conflict | `span_filler` | `DAT_00020ac0` | selected span-filler routine (docs/DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `panels_drawn` | `_DAT_00020ae4` | 0 until the cockpit panels are redrawn by overlay_frame_step (cleared by clear_flag_00020ae4) [STRONG INFERENCE] |
| Pacific Conflict | `view_half_height` | `DAT_00020ae8` | half view height (view_rows / 2, - 20 with panels; update_view_clip_bounds), or proj_scale_y * 0x43 / 0x1e0 after a panel redraw; used instead of clip_y_max once panels_drawn is set |
| Pacific Conflict | `view_rows` | `DAT_0001b828` | view height in rows (one span run per row in reset_span_row_lists); scan_last_row = clip_y_max + view_rows / 2 |
| Pacific Conflict | `deferred_free_flag` | `_DAT_0001c1bc` | shared-block deferred-free flag (docs/DECOMPILATION_SYMBOLS.md), cleared each frame |
| Pacific Conflict | `flag_da8c` | `DAT_0001da8c` | word cleared by update_view_clip_bounds [role UNKNOWN] |
| Pacific Conflict | `view_inset` | `DAT_00020ae2` | 4 when update_view_clip_bounds reserves 20 rows for the panels, else 0 [STRONG INFERENCE] |
| Pacific Conflict | `flag_20ae0` | `_DAT_00020ae0` | word cleared with panels_drawn by update_view_clip_bounds [role UNKNOWN] |
| Pacific Conflict | `scale_table_index` | `DAT_00020af4` | index into the projection scale tables, used in view mode 6 |
| Pacific Conflict | `proj_scale_y_table` | `DAT_00020afc` | projection scale word table for proj_scale_y |
| Pacific Conflict | `proj_scale_x_table` | `DAT_00020b14` | projection scale word table for proj_scale_x |
| Pacific Conflict | `view_param_12` | `_DAT_0001b82e` | host +0x12 (A5-0x1376) copied by configure_renderer_for_display [role UNKNOWN] |
| Pacific Conflict | `view_param_14` | `_DAT_0001b82c` | host +0x14 (A5-0x1374) [role UNKNOWN] |
| Pacific Conflict | `view_half_rows` | `DAT_00020b2c` | view_rows / 2 |
| Pacific Conflict | `view_half_width` | `DAT_00020b2a` | view_width / 2 |
| Pacific Conflict | `view_centre_fixed` | `DAT_00020af0` | (2 * view_half_width - 1) << 16 | 0x8000: centre column in 16.16 |
| Pacific Conflict | `view_multi_flag` | `DAT_0001b824` | host +0xb4 multi-monitor flag the renderer was configured for |
| Pacific Conflict | `span_filler_2` | `_DAT_00020abc` | second selected span-filler routine (address - 0x20) |
| Pacific Conflict | `span_filler_3` | `_DAT_00020ab8` | third selected span-filler routine (address - 0x20) |
| Pacific Conflict | `depth_routine_ab4` | `DAT_00020ab4` | depth-specific code address (0xa14e / 0xa200) [role UNKNOWN] |
| Pacific Conflict | `depth_routine_da80` | `DAT_0001da80` | depth-specific code address [role UNKNOWN] |
| Pacific Conflict | `depth_routine_da84` | `DAT_0001da84` | depth-specific code address [role UNKNOWN] |
| Pacific Conflict | `depth_routine_da90` | `DAT_0001da90` | depth-specific code address [role UNKNOWN] |
| Pacific Conflict | `depth_routine_da94` | `DAT_0001da94` | depth-specific code address [role UNKNOWN] |
| Pacific Conflict | `depth_routine_da98` | `DAT_0001da98` | depth-specific code address (host +0x276 at depth 1) [role UNKNOWN] |
| Pacific Conflict | `depth_routine_da9c` | `DAT_0001da9c` | depth-specific code address (host +0x276 at depth 1) [role UNKNOWN] |
| Pacific Conflict | `rank_aim_lag_table` | `DAT_0001b2b4` | word per pilot rank: AI aim lag in frames |
| Pacific Conflict | `ai_aim_lag_key1` | `DAT_0001b876` | AI aim lag in frames for definition key 1 (docs/DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `ai_aim_lag` | `DAT_0001b878` | AI aim lag in frames for the other aircraft |
| Pacific Conflict | `rudder_key` | `DAT_0001b858` | rudder key input word: +0x40 Z, -0x40 X, 0 |
| Pacific Conflict | `bw_pattern_first` | `DAT_0001da88` | first word of the host pattern table (+0x88), read at depth 1 |
| Pacific Conflict | `flight_word_24d2c` | `_DAT_00024d2c` | word cleared when a flight starts [role UNKNOWN] |
| Pacific Conflict | `flight_word_24d2e` | `_DAT_00024d2e` | word cleared when a flight starts [role UNKNOWN] |
| Pacific Conflict | `host_words_valid` | `_DAT_00024d34` | nonzero: begin_flight_for_rank copies host words +0x33e / +0x340 [role UNKNOWN] |
| Pacific Conflict | `host_word_33e` | `DAT_00024d32` | copy of host word +0x33e [role UNKNOWN] |
| Pacific Conflict | `host_word_340` | `DAT_00024d30` | copy of host word +0x340 [role UNKNOWN] |
| Pacific Conflict | `replay_frames_left` | `DAT_0001b86e` | instant-replay / end-sequence frame countdown (docs/DECOMPILATION_SYMBOLS.md comment-only name) |
| Pacific Conflict | `snd_gun` | `_DAT_0001b852` | sound event slot Gun (docs/DECOMPILATION_SYMBOLS.md, slot names from DATA 0) |
| Pacific Conflict | `view_key_angle_a` | `DAT_00024cfc` | view angle stepped by 0x800 with arrow keys 0x1c / 0x1d |
| Pacific Conflict | `view_key_angle_b` | `DAT_00024cf8` | view angle stepped by 0x540 with arrow keys 0x1e / 0x1f |
| Pacific Conflict | `track_pitch` | `DAT_00024d00` | view mode 6 tracking-camera pitch (eased toward attitude_from_velocity's pitch); its low word feeds neg_camera_pitch |
| Pacific Conflict | `track_heading` | `DAT_00024d04` | view mode 6 tracking-camera heading; its low word feeds neg_camera_heading |
| Pacific Conflict | `ext_camera_point_y` | `DAT_0001d828` | ext_camera_point record +4: y |
| Pacific Conflict | `ext_camera_point_z` | `DAT_0001d82c` | ext_camera_point record +8: z |
| Pacific Conflict | `throttle_step` | `DAT_00024cf6` | throttle step input (+1 / -1 / 0) from the + / = and - / _ keys (docs/STRUCTS.md) |
| Pacific Conflict | `snd_approach_ok` | `_DAT_0001b83c` | sound event slot 3 (no sample): landing approach accepted (try_begin_landing_approach != 0) |
| Pacific Conflict | `snd_approach_refused` | `_DAT_0001b83e` | sound event slot 4 (no sample): landing approach refused |
| Pacific Conflict | `friendly_landing_scored` | `_DAT_0001b86a` | set once per flight when the friendly-base landing outcome (0x201) is taken |
| Pacific Conflict | `fire_button` | `_DAT_00024cf4` | space key held (1 on keyDown, 0 on keyUp), also restored from host +0x342; gates gun fire [STRONG INFERENCE] |
| Pacific Conflict | `view_follow_target` | `DAT_0001b884` | object the view follows, taken from designated_entity_2 for 0x14 frames [STRONG INFERENCE] |
| Pacific Conflict | `abandoned_intact_aircraft` | `_DAT_0001b87a` | set in update_aircraft_entity when the player bails out of an undamaged aircraft with fuel; a surviving pilot is then Discharged (resolve_bailout_outcome header) |
| Pacific Conflict | `camera_pitch` | `DAT_00024d1a` | camera pitch word 0..0x3fff (docs/DECOMPILATION_SYMBOLS.md, PROVEN); neg_camera_pitch is its negative |
| Pacific Conflict | `camera_heading` | `DAT_00024d18` | camera heading word 0..0x3fff (PROVEN); neg_camera_heading is its negative |
| Pacific Conflict | `camera_step_x` | `DAT_0001d81c` | camera x step per frame: (camera_goal_x - camera_x) / (replay_frames_left - 0x1e) |
| Pacific Conflict | `camera_step_y` | `DAT_0001d818` | camera y step per frame |
| Pacific Conflict | `camera_step_z` | `DAT_0001d814` | camera z step per frame |
| Pacific Conflict | `camera_goal_x` | `DAT_00024d28` | camera destination x the replay camera glides to |
| Pacific Conflict | `camera_goal_y` | `DAT_00024d24` | camera destination y |
| Pacific Conflict | `camera_goal_z` | `DAT_00024d20` | camera destination z |
| Pacific Conflict | `target_hold_frames` | `DAT_00024d1c` | frames the view keeps following view_follow_target (0x14 when taken) |
| Pacific Conflict | `live_controller_count` | `_DAT_0001c1c8` | controller count kept after advance_frame_and_tick_controllers compacts controller_list (dead entries dropped) |
| Pacific Conflict | `live_controller_count_w` | `DAT_0001c1ca` | low word of live_controller_count (big-endian int at 0x1c1c8), dbra count in apply_controller_velocities |
| Pacific Conflict | `engine_sound_choice` | `DAT_00024d14` | engine-sound slot last chosen by update_game_sounds (0 Engine / 10 Wind), -1 after stop_all_sound_channels |
| Pacific Conflict | `channel1_sound` | `DAT_00024d10` | sound number playing on channel 1 (0 = none); play_game_sound refuses ids >= it, stop_game_sound clears it |
| Pacific Conflict | `snd_wheel` | `_DAT_0001b856` | one-frame flag: update_game_sounds plays sound 6 Wheel, cleared each frame |
| Pacific Conflict | `snd_ditch` | `_DAT_0001b850` | flag: sound 11 Ditch plays while set, stops when clear; cleared each frame |
| Pacific Conflict | `snd_grass` | `_DAT_0001b854` | flag: sound 12 Grass plays while set, stops when clear; cleared each frame |
| Pacific Conflict | `snd_explosion_timer` | `DAT_0001b84a` | countdown: sound 8 Explosion when non-zero (moved to snd_distant_explosion_timer outside view modes 7..9), decremented each frame |
| Pacific Conflict | `snd_distant_explosion_timer` | `DAT_0001b848` | countdown: sound 9 Distant Explosion when non-zero, decremented each frame |
| Pacific Conflict | `snd_gear_alt` | `_DAT_0001b846` | one-frame flag: sound 100 (Gear sample at offset 0x48c0), cleared each frame |
| Pacific Conflict | `snd_ugh` | `_DAT_0001b844` | one-frame flag: sound 1 Ugh, cleared each frame |
| Pacific Conflict | `snd_hit` | `_DAT_0001b842` | one-frame flag: sound 2 Hit (player hit), cleared each frame |
| Pacific Conflict | `gear_moving` | `_DAT_0001b84e` | set when player +0x679 is between 0 and 0x2d (and +0x685 bit 0x20 clear) -> sound 7 [STRONG INFERENCE: gear in motion] |
| Pacific Conflict | `flaps_moving` | `_DAT_0001b84c` | set when player +0x67b is between 0 and 0xf -> sound 7 [STRONG INFERENCE: flaps in motion] |
| Pacific Conflict | `prepared_object` | `DAT_00025b24` | 3-D model being drawn; project_prepared_object reads vertices +0x44, faces +0x48, shift +0x32 |
| Pacific Conflict | `face_normals` | `_DAT_00024d4a` | object +0x44 + 12 * vertex count (+0x36): the face normals stored after the vertices (project_prepared_object) |
| Pacific Conflict | `vertex0_x` | `DAT_00024d4e` | model vertex 0 long x, copied by project_prepared_object |
| Pacific Conflict | `vertex0_y` | `DAT_00024d52` | model vertex 0 long y |
| Pacific Conflict | `vertex0_z` | `DAT_00024d56` | model vertex 0 long z |
| Pacific Conflict | `vertex_shift` | `DAT_00024d5a` | object +0x32: asr count applied to model vertex longs |
| Pacific Conflict | `eye_obj_x` | `DAT_00024d60` | camera x in object units, paired with vertex x in face_is_back_facing |
| Pacific Conflict | `eye_obj_y` | `DAT_00024d5e` | camera y in object units |
| Pacific Conflict | `eye_obj_z` | `DAT_00024d5c` | camera z in object units |
| Pacific Conflict | `screen_poly_x` | `DAT_00024df2` | clipped screen polygon: x long of each (x, y) long pair (8-byte stride), filled by clip_polygon_y_max |
| Pacific Conflict | `screen_poly_y` | `DAT_00024df6` | clipped screen polygon: y long of each pair (screen_poly_x + 4) |
| Pacific Conflict | `screen_poly_count` | `DAT_00025b1a` | point count of the clipped screen polygon |
| Pacific Conflict | `face_table` | `DAT_00025f30` | face records (0x20 bytes) of prepared_object, = object +0x48 (project_prepared_object) |
| Pacific Conflict | `draw_order_next` | `DAT_0001c1be` | next draw-order number given to an emitted face (stored at face +2) |
| Pacific Conflict | `face_queue_end` | `DAT_00025d2c` | append pointer of the emitted-face queue (faces are queued in draw order) |
| Pacific Conflict | `near_mode` | `DAT_00025b16` | near mode: camera within the object range, 2 = first frame (docs/OVERLAY_RENDERER.md) |
| Pacific Conflict | `back_face_queue_end` | `DAT_00025b28` | append cursor of the back faces kept for the penetration test (docs/OVERLAY_RENDERER.md) |
| Pacific Conflict | `root_face_count` | `DAT_00025b18` | prepared_object +0x38: number of root faces whose +0x12 chains are walked (project_prepared_object, emit_faces_in_order) |
| Pacific Conflict | `horizon_corners` | `DAT_0001bd90` | screen corners the ground plane reaches: 1 / 2 top-left / top-right, 4 / 8 bottom (0xf all ground, 0 all sky; docs/OVERLAY_RENDERER.md) |
| Pacific Conflict | `horizon_x0` | `DAT_0001bda0` | horizon edge x0: last ground-plane edge not on a screen border [STRONG INFERENCE] |
| Pacific Conflict | `horizon_y0` | `DAT_0001bd9c` | horizon edge y0 |
| Pacific Conflict | `horizon_x1` | `DAT_0001bd98` | horizon edge x1 |
| Pacific Conflict | `horizon_y1` | `DAT_0001bd94` | horizon edge y1 |
| Pacific Conflict | `screen_poly_m1` | `DAT_00024dea` | screen_poly_x - 8: indexed by n * 8 it addresses the last of n points |
| Pacific Conflict | `clip_poly_buf` | `DAT_00025252` | second (x, y) point buffer the clip_polygon_* passes ping-pong with screen_poly_x |
| Pacific Conflict | `projected_x` | `DAT_000256b2` | projected screen x per view vertex ((x, y) long pairs, 0x80000000 = behind the near plane; project_prepared_object) |
| Pacific Conflict | `projected_y` | `DAT_000256b6` | projected screen y per view vertex (projected_x + 4) |
| Pacific Conflict | `view_vertices` | `DAT_00025b20` | camera-space vertex buffer of prepared_object (+0x4c, project_prepared_object) |
| Pacific Conflict | `back_face_queue` | `DAT_00025b2c` | start of the back faces kept for the penetration test (docs/OVERLAY_RENDERER.md) |
| Pacific Conflict | `face_queue` | `DAT_00025d30` | start of the emitted-face queue (face_queue_end is its append pointer) |
| Pacific Conflict | `face_was_clipped` | `_DAT_00025b12` | set to 1 when clip_face_near_plane clipped a face; when 0 submit_object_faces clears object flag 8 |
| Pacific Conflict | `force_near_clip` | `_DAT_00025b14` | non-zero: every face goes through clip_face_near_plane (object +6 & 8, per the submit_object_faces note) |
| Pacific Conflict | `object_matrix` | `DAT_00024d62` | pointer to the nine-word object-to-camera matrix (4.12 words) used by transform_face_vertices |
| Pacific Conflict | `vertex_done` | `DAT_00024d66` | byte per model vertex: 1 once transform_face_vertices has transformed it this frame |
| Pacific Conflict | `object_attitude` | `DAT_0001d72c` | object attitude matrix built by build_attitude_matrix_3ang (target 0x1d72c) in transform_and_project_object |
| Pacific Conflict | `object_camera_matrix` | `DAT_00024d38` | object-to-camera matrix = object_attitude x camera matrix (matmul3x3_s16 target 0x24d38); object_matrix points here for rotated objects |
| Pacific Conflict | `background_rows` | `DAT_00020ad4` | row buffer of 8-byte background spans (0, 1, view_width, fill_colour) per host view row (+0x18c); allocated by draw_sky_and_ground |
| Pacific Conflict | `heading_tape_pos` | `DAT_00025ffe` | heading-tape scroll position last drawn (update_heading_tape skips the copy when unchanged); reset_overlay_display_state sets 1 to invalidate it |
| Pacific Conflict | `readouts_drawn` | `_DAT_00025ffc` | 0 forces a full redraw of the readouts / needles (cleared by reset_overlay_display_state) |
| Pacific Conflict | `background_rows_next` | `DAT_00020ad8` | row span buffer built this frame by draw_sky_and_ground, swapped with background_rows after the blit |
| Pacific Conflict | `bg_cache_origin` | `DAT_00025f34` | cached host +0x186 / +0x188 (high word: top row, low word: left x of the view) |
| Pacific Conflict | `bg_cache_size` | `DAT_00025f38` | cached host +0x18a / +0x18c (low word: view row count) |
| Pacific Conflict | `bg_cache_colours` | `DAT_00025f3c` | cached host +0x18e / +0x190 (sky / ground colours) |
| Pacific Conflict | `bg_cache_192` | `DAT_00025f40` | cached host +0x192 long (meaning not established) |
| Pacific Conflict | `bg_row_extents` | `DAT_00025f44` | cached host +0x196: per-row (x0, x1) word pairs of the view |
| Pacific Conflict | `bg_frame_parity` | `DAT_00025f48` | frame counter; depth 1 redraws the background only on even frames |
| Pacific Conflict | `panel_back_offset` | `DAT_0001bd7c` | host +0xe2 * +0xe0: subtracted from host +0xdc to address the saved panel image that erasers restore from |
| Pacific Conflict | `needle_end_x` | `DAT_00025f4a` | needle end x cached per instrument type (long [type]), draw_gauge_needle |
| Pacific Conflict | `needle_end_y` | `DAT_00025f92` | needle end y cached per instrument type (long [type]), draw_gauge_needle |
| Pacific Conflict | `alt_short_end_x` | `DAT_00025fda` | altimeter second (2/3 length) hand end x, update_altimeter_needles |
| Pacific Conflict | `alt_short_end_y` | `DAT_00025fde` | altimeter second (2/3 length) hand end y |
| Pacific Conflict | `climb_rate` | `DAT_0001bc80` | rate of climb, climb needle angle (/ 0x78) and readout 3 (docs/COCKPIT_HUD_DATA_LOCATIONS.md) |
| Pacific Conflict | `bomb_count_shown` | `DAT_00025fe2` | player bomb count (+0x67c) last drawn by update_bomb_indicator |
| Pacific Conflict | `high_flag_shown` | `DAT_00025fe4` | height-above-ground > 0x43 flag last drawn by update_bomb_indicator |
| Pacific Conflict | `throttle_shown` | `DAT_00025fe6` | player throttle setting (+0x668, 0..9) last drawn by update_throttle_gauge |
| Pacific Conflict | `flaps_shown` | `DAT_00025fe8` | player flaps byte (+0x67b) last drawn by update_flaps_needle |
| Pacific Conflict | `gear_shown` | `DAT_00025fea` | player gear byte (+0x679, 0..0x2d) last drawn by update_gear_needles |
| Pacific Conflict | `ammo_shown` | `DAT_00025fec` | player word +0x682 last drawn by update_ammo_needle |
| Pacific Conflict | `fuel_left_shown` | `DAT_00025fee` | player fuel tank byte +0x67d last drawn by update_fuel_needles |
| Pacific Conflict | `fuel_right_shown` | `DAT_00025ff0` | player fuel tank byte +0x67e last drawn by update_fuel_needles |
| Pacific Conflict | `readout_index` | `DAT_00025ff2` | next numeric readout to update, cycling 0..3 (altitude, speed, heading, climb) |
| Pacific Conflict | `readout_cache` | `DAT_00025ff4` | last drawn |value| of each of the four readouts (word [4], 0x7fff = invalid) |
| Pacific Conflict | `enemy_fighter_template` | `DAT_00026000` | first type-4 object, kept by create_enemy_fighter as the template spawn_enemy_fighter copies |
| Pacific Conflict | `aircraft_type_rec` | `DAT_00026004` | aircraft type record = controller +4, set each tick by update_aircraft_entity (field table in DECOMPILATION_SYMBOLS.md) |
| Pacific Conflict | `climb_ring` | `DAT_0001bc8c` | 120-word ring of player speed * sin(+0x20) samples; climb_rate is their moving sum (update_aircraft_entity blk 6c) |
| Pacific Conflict | `climb_ring_index` | `DAT_0001bc84` | next slot of climb_ring, wraps at 0x78 |
| Pacific Conflict | `route_1b2e0` | `DAT_0001b2e0` | AI waypoint route table given to the route block by ensure_ai_script_1b2e0_tick (target speed 0x9d8) |
| Pacific Conflict | `route_1b310` | `DAT_0001b310` | AI waypoint route table given to the route block by ensure_ai_script_1b310_tick (target speed 0xd5c) |
| Pacific Conflict | `route_1b340` | `DAT_0001b340` | AI waypoint route table given to the route block by ensure_ai_script_1b340_tick (target speed 0x9d8) |
| Pacific Conflict | `route_1b370` | `DAT_0001b370` | AI mission route table copied into the route block by tick_ai_1b370_mission |
| Pacific Conflict | `route_1b370_speeds` | `DAT_0001b3d0` | 8 longs: target speed per route_1b370 waypoint (0xe10, 0xe10, 0xca8, 0xca8, 0xb40, 0xd5c x3) |
| Pacific Conflict | `ai_fly_table` | `DAT_0001b3f4` | AI fly handlers indexed by the aircraft kind word +0x614 (init_aircraft_controller); 0 = plain update_aircraft_entity |
| Pacific Conflict | `mission_target_list` | `DAT_00020adc` | mission 7 (Divine Wind) target list: word +0 live count, word +2 slots, longs from +6 (remove_mission_target) |
| Pacific Conflict | `rng_cursor` | `DAT_00026008` | overlay RNG cursor into rng_state (wraps at 0x260e7; set to 0x260e4 by overlay_rng_init) |
| Pacific Conflict | `rng_state` | `DAT_0002600c` | overlay RNG state: 55 longs from 0x2600c, the first one = the seed (overlay_rng_init) |
| Pacific Conflict | `rng_state_1` | `DAT_00026010` | rng_state + 4: second state long, first one filled by the seeding loop |
| Pacific Conflict | `smoke_template` | `DAT_000260e8` | smoke plume template object stored by register_smoke_template, spawned by spawn_smoke_plume |
| Pacific Conflict | `effect_templates` | `DAT_0002626e` | 4 effect template objects stored by register_effect_template (the 4th = effect_template_3) |
| Pacific Conflict | `effect_template_3` | `DAT_0002627a` | effect_templates[3]: its controllers get object flag 0x2000 (create_effect_controller) |
| Pacific Conflict | `effect_log_index` | `DAT_000260ec` | next entry of effect_log (wraps at 16) |
| Pacific Conflict | `effect_log` | `DAT_000260ee` | 16-entry log (0x18 bytes) of spawn_effect arguments replayed by replay_logged_effects; byte +0 = kind, +0x14 frame |
| Pacific Conflict | `effect_init_table` | `DAT_0001b40c` | per-kind effect initialiser called by spawn_effect on the new effect object |
| Pacific Conflict | `effect_anim_table` | `DAT_0001b41c` | per-kind effect animator called by tick_effect (returns 1 when finished) |
| Pacific Conflict | `effect_pre_render_table` | `DAT_0001b42c` | per-kind effect pre-render hook called by effect_pre_render_hook |
| Pacific Conflict | `ordnance_template` | `DAT_00026280` | ordnance template object stored by register_ordnance_template, spawned by spawn_weapon_entity |
| Pacific Conflict | `type10_controller` | `DAT_00020b40` | the single type-10 controller published by create_singleton_type10_controller [HYPOTHESIS per that function's name] |
| Pacific Conflict | `contact_table` | `DAT_0001bdbc` | 256-slot open-addressing table of contact records keyed by contact_pair_hash(a, b), linear probing |
| Pacific Conflict | `cell_face_a` | `DAT_00020b44` | fractal_height_at: face of the current cell whose centre z is at or below the cell centre (-1 = none) [INFERENCE] |
| Pacific Conflict | `cell_face_b` | `DAT_00020b46` | fractal_height_at: face of the current cell whose centre z is above the cell centre (-1 = none) [INFERENCE] |
| Pacific Conflict | `cell_plane` | `DAT_00020b48` | fractal_height_at: plane entry in use (record +0x22 or +0x30) |
| Pacific Conflict | `collision_pair_table` | `DAT_0001b43c` | 10 entries of 8 bytes (type word, type word, handler long) scanned by dispatch_collision |
| Pacific Conflict | `collision_pair_cursor` | `DAT_00026284` | dispatch_collision cursor into collision_pair_table (left on the matching entry) |
| Pacific Conflict | `first_carrier_ctl` | `_DAT_0001b864` | first type-0x15 (carrier) controller, published by create_carrier_controller when still 0 |
| Pacific Conflict | `bullet_template` | `DAT_0002664a` | Bullet scene template: stored by register_bullet_template (0x15bd4), passed to spawn_mission_pool_object by spawn_ordnance_scattered (0x15bf6). |
| Pacific Conflict | `dot_object_count` | `DAT_000265d0` | Count of queued dot/streak objects; bullet_pre_render (0x15e62) appends while < 0x1e. |
| Pacific Conflict | `dot_object_list` | `DAT_000265d2` | Object list drawn as dots by draw_distant_object_dots; filled by bullet_pre_render (0x15e62). |
| Pacific Conflict | `dot_records` | `DAT_00026288` | 14-byte dot records (pixel pointer +0); erase_dots_depth8 (0x15ebe) / plot_dot_depth8 (0x15f3e). |
| Pacific Conflict | `dot_rec_size` | `DAT_0002628e` | Dot record word +6: size 1..4 pixels. |
| Pacific Conflict | `dot_rec_colour` | `DAT_00026290` | Dot record byte +8: plotted colour. |
| Pacific Conflict | `dot_rec_saved0` | `DAT_00026291` | Dot record byte +9: saved pixel (x, y). |
| Pacific Conflict | `dot_rec_saved1` | `DAT_00026292` | Dot record byte +10: saved pixel (x + 1, y). |
| Pacific Conflict | `dot_rec_saved2` | `DAT_00026293` | Dot record byte +11: saved pixel (x, y + 1). |
| Pacific Conflict | `dot_rec_saved3` | `DAT_00026294` | Dot record byte +12: saved pixel (x + 1, y + 1). |
| Pacific Conflict | `dot_rec_phase` | `DAT_0002628c` | Dot record word +4: depth-4 pixel phase (erase_dots_depth4 0x15fb8 picks the nibble order). |
| Pacific Conflict | `dot_corner_dx` | `DAT_0001b48c` | long[4 corners][4 sizes] x offsets of the depth-1 dot square (plot_dot_bw 0x16230). |
| Pacific Conflict | `dot_corner_dy` | `DAT_0001b4cc` | long[4 corners][4 sizes] y offsets of the depth-1 dot square (plot_dot_bw 0x16230). |
| Pacific Conflict | `trail_templates` | `DAT_00026650` | Trail scene templates by kind [2]; filled by register_trail_templates (0x16a78), spawned by spawn_trail (0x16ae8). |
| Pacific Conflict | `trail_init_table` | `DAT_0001b50c` | Trail init handlers by kind (0 -> 0x16ac4, 1 -> 0x16ad6) [PROVEN bytes]; called by spawn_trail. |
| Pacific Conflict | `trail_animate_table` | `DAT_0001b514` | Trail animate handlers by kind (0 -> 0x16c6a, 1 -> 0x16e06) [PROVEN bytes]; called by tick_trail (0x1702a). |
| Pacific Conflict | `ground_fire_template` | `DAT_00026658` | Ground fire scene template; stored by register_ground_fire_template (0x17098), spawned by spawn_ground_fire_object (0x170ba). |
| Pacific Conflict | `debris_template` | `DAT_0002665c` | Debris fragment scene template; stored by register_debris_template (0x173dc), spawned by spawn_debris_fragment (0x173fe). |
| Pacific Conflict | `ground_mark_template` | `DAT_00026660` | Ground mark scene template; stored by register_ground_mark_template (0x1759e). |
| Pacific Conflict | `radar_tracks` | `DAT_0001b51c` | Up to 6 radar tracks of 0x14 bytes (x, z, two controller words, visible flag); add_radar_track (0x176b2) [STRONG INFERENCE]. |
| Pacific Conflict | `radar_track_count` | `DAT_00026676` | Number of radar tracks in use; add_radar_track / reset_radar_tracks. |
| Pacific Conflict | `radar_limit` | `DAT_00026666` | 2 * radar_range (set_view_distance); distance limit in add_radar_track. |
| Pacific Conflict | `radar_range` | `DAT_0002666a` | Range set by set_view_distance (0x1771a), cycled 0xc15c0 / 0x26ac0 / 0xce40 by cycle_view_distance. |
| Pacific Conflict | `radar_changed` | `_DAT_0002666e` | Changed flag set by set_view_distance and reset_radar_tracks. |
| Pacific Conflict | `range_0x26ac0` | `DAT_00026ac0` | Not a variable: the immediate 0x26ac0 pushed by cycle_view_distance (0x17736), rendered by Ghidra as an address. |
| Pacific Conflict | `radar_scale` | `DAT_00026664` | Radar scale = radar_range / (scope width * 8); set by update_radar_range_buttons (0x17a8c). |
| Pacific Conflict | `radar_drawn_tracks` | `DAT_0001b520` | Last frame radar track buffer (blips to erase); swapped with radar_tracks by update_radar_scope (0x17b68). |
| Pacific Conflict | `radar_drawn_count` | `DAT_00026672` | Entries in radar_drawn_tracks; set by update_radar_scope, cleared by reset_radar_tracks. |
| Pacific Conflict | `shadow_templates` | `DAT_00026768` | Shadow scene templates by kind; spawn_object_shadow (0x18956) reads [kind]. |
| Pacific Conflict | `shadow_template_slots` | `DAT_0002676c` | The four template slots (shadow_templates + 4) filled by register_shadow_templates (0x188f4). |
| Pacific Conflict | `turret_template` | `DAT_0002677c` | Ship turret scene template; stored by register_turret_template (0x1910e), spawned by spawn_turret_on_object (0x19130). |
| Pacific Conflict | `parachute_template` | `DAT_00026780` | Bailed-out pilot / parachute template; stored by register_parachute_template (0x1940e), spawned by spawn_bailout_parachute (0x19430). |
| Pacific Conflict | `cloud_templates` | `DAT_00026784` | Five cloud / camera-relative templates by class; filled by register_cloud_templates (0x19a54), spawned by spawn_camera_relative_object (0x19aa2). |
| Pacific Conflict | `glide_saved_state` | `DAT_00026798` | AI state +0x32 saved by try_begin_landing_approach before installing tick_landing_approach_glide; set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_start_z` | `DAT_0002679c` | Own z at approach start (try_begin_landing_approach), then the smoothed steer target z (tick_landing_approach_glide). |
| Pacific Conflict | `glide_start_x` | `DAT_000267a0` | Own x at approach start (try_begin_landing_approach), then the smoothed steer target x (tick_landing_approach_glide). |
| Pacific Conflict | `glide_long_267a4` | `DAT_000267a4` | Landing glide height controller remainder (v mod 16) in tick_landing_approach_glide (0x1a1a6); cleared by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_long_267a8` | `DAT_000267a8` | Landing glide height correction, accumulated and clamped to +-0x4b0 in tick_landing_approach_glide (0x1a1a6); cleared by try_begin_landing_approach. |
| Pacific Conflict | `glide_blend` | `DAT_000267ac` | 2-frame blend factor toward the predicted position (tick_landing_approach_glide); 0 at start; set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_height_floor` | `DAT_000267ae` | Height above aim y used as the glide floor: 0x11b or 0x181; set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_dir_x` | `DAT_000267b2` | Glide direction x (unit << 12); set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_dir_y` | `DAT_000267b6` | Glide direction y: fixed descent 0xfdc0; set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_dir_z` | `DAT_000267ba` | Glide direction z (unit << 12); set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_aim_x` | `DAT_000267bc` | Landing aim point x; set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_aim_y` | `DAT_000267c0` | Landing aim point y; set by try_begin_landing_approach (0x19fba). |
| Pacific Conflict | `glide_aim_z` | `DAT_000267c4` | Landing aim point z; set by try_begin_landing_approach (0x19fba). |
