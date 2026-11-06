# Cockpit instrument panel (CODE segment 3)

The instrument panel is drawn by CODE segment 3 (`ID03`). Offsets are
physical file offsets in `ID03.bin`. Byte sequences, call relations and
label strings are **[PROVEN]**; gauge identities follow from the labels
(**[STRONG INFERENCE]**); other interpretations are marked.

## Label strings

Labels come from `STR#` 129, loaded at start-up by ID07
`load_str129_string_table` into the pointer table `A5-0xf46` (slot *n* at
`A5-0xf46 + 4*n`). The text is in
`artifacts/reverse-engineering/resources/resource_dasm_Hellcats_app/`
(`…STR#_129_English Strings_<n-1>.txt`; files are 0-based, game slots
1-based). Calibration: slot 93 = "Out of memory.  Sorry", the message used by
ID02 `fatal_memory_error_exit`. A `\p` prefix marks strings kept as Pascal
strings by the loader.

| Slot | Text | Used by |
|---|---|---|
| 1 | Unable to store instrument panel to disk | unexported ID04 routine at 0x432 |
| 61 | Hellcats requires a Macintosh with color QuickDraw and a 68020 or higher | ID04 `check_system_requirements` = JT $f2 start-up gate |
| 65 | ALTITUDE | type 0 |
| 66 / 67 | AIR / SPEED | type 1 |
| 68 | CLIMB | type 3 |
| 69 | RPM | type 5 |
| 70 / 71 | Manifold / Pressure | type 4 |
| 72 | DIRECTION | type 6 |
| 73 / 74 | TURN / BANK | type 2 |
| 75 / 76 / 77 | FLAPS / AMMO / Fuel | `draw_flaps_indicator` (0x4c42) / `draw_ammo_counter` (0x4ecc) / `draw_fuel_gauge` (0x532e), outside the type switch |

## Instrument types (`draw_instrument`, ID03 0x3c02)

| Type | Function | Gauge |
|---|---|---|
| 0 | `draw_altimeter` (0x1876) | altimeter |
| 1 | `draw_airspeed_indicator` (0x1b48) | airspeed |
| 2 | `draw_turn_and_bank_indicator` (0x2d1c) | turn and bank |
| 3 | `draw_climb_indicator` (0x1fee) | rate of climb |
| 4 | `draw_manifold_pressure_gauge` (0x2600) | manifold pressure |
| 5 | `draw_tachometer` (0x22fe) | engine RPM |
| 6 | `draw_direction_indicator` (0x2950) | heading |
| 7 | — | nothing drawn |
| 8 | `draw_gyro_instrument` (0x32b8) | gyro instrument; caches "GyroInstrument" / "GyroFlags" (which gyro is open) |
| 9 | `draw_artificial_horizon` (0x38fc) | artificial horizon; caches "HorizonInstrument" |

`draw_instrument` first draws the bezel with
`draw_ring_with_status_indicators` (flags `0x1b` for type 6, otherwise
`0x0f`), then calls the drawer, then stores geometry in a 16-byte record per
type at `A5-0x12a2`. Ghidra decoded the switch table after `JSR $3a(A5)` as
code; the table was parsed from the bytes.

## Drawing pipeline

1. `begin_instrument_supersample` (0x1538): in 1-bit mode a 1× black-and-white
   port; otherwise coordinates ×3 and a 3×-size black-and-white port
   (`new_offscreen_bw_port`, 0x2a8).
2. The gauge drawer draws scales, needles (through the function pointer
   `A5-0x2118`), vector-font numbers (`draw_vector_number`, 0x912) and centred
   labels (`set_scaled_text_style`, 0x6, `StringWidth` / `DrawString`).
3. `antialias_downsample_bw_3x` (0xa3c): each output pixel is a 7×7
   weighted sum (total weight 969) of the 3× bitmap, converted to a grey
   palette index with `nearest_palette_index_rgb` (0xf4) and plotted.
4. `finish_instrument_supersample` (0x1844): SetPort(panel port `A5-0x1496`),
   `composite_instrument_bitmap` (0x146a: CopyBits at depth 1, otherwise the 3×
   downsample into the panel), then `dispose_offscreen_bw_port` (0x33c).

Coordinates are design units scaled by `scale_design_4800` (0x8a:
`A5-0x149e · v / 4800`) and centred with ID02 `design_x_to_screen` /
`design_y_to_screen` (half view width `A5-0x1372` / height `A5-0x1370`).

## Bezel

`draw_ring_with_status_indicators` (0x514): black disc, grey ring
(`PenSize(w/10)`), and for flag bits 0–4 a `draw_spinning_disc_indicator`
(0x35e) on the diagonals at `(d/2)·cos 45° + 30` design units (constant
`0xb50 >> 12`). The "indicator" is a grey disc with a black slot whose angle
steps by 45° per call (phase `A5-0x2112`, size `A5-0x2114`).
**[HYPOTHESIS]** These are bezel screw heads, the stepping phase varying the
slot orientation from screw to screw.

## Open questions

- Types 8 and 9: identified by their cached-bitmap resource names; bodies only partly decoded.
- Panel cache: `store_panel_bitmaps_as_resources` (ID03
  0x5ab6) saves the rendered bitmaps as HEL2 200 / 300 / 400 / 500 +
  configuration (`A5-0x13ae`); HEL2 127 "Bitmap Cache" holds 0x160-byte
  entries per configuration with a "stored" flag at +0xc. A failure sets
  `A5-0x14a0`, reported by ID04 0x432 as "Unable to store instrument panel
  to disk".
- Panel set-up: `prepare_instrument_panel` (ID03 0x5cc4,
  JT $17a) sets the design scale `A5-0x149e` = 0.75 × half view width and
  reuses a stored cache entry when its key (+0 1-bit mode, +2 / +4,
  +6 / +8 view width / height) matches, restoring the per-instrument records
  (`A5-0x12a2`) from entry +0x12.
- ~~The needle function pointer `A5-0x2118`~~ — cosine (with `A5-0x211c` sine), used by `dial_point_at_angle`. The per-type record at `A5-0x12a2` is still open.
- GEAR: `draw_landing_gear_indicator` (ID03 0x54fe, label STR# 78) lays out three lamps.
- ID04 slot users decoded; the panel-store path (ID04 0x432,
  ID02 0x4d34) is not yet fully understood.

## Live needles (overlay)

The panel bitmaps are static; the overlay draws the needles each frame from
`update_view_readouts_and_overlays`. Each needle uses words +0xa / +0xc / +0xe
(centre x, centre y, length) of the per-type 16-byte record at `A5-0x12a2`
(overlay +0xe6 + 0x10·type) **[PROVEN by the offsets]** and is redrawn by
`draw_gauge_needle` (erase from the saved panel, redraw; overlay 0xc572).

| Type | Overlay function | Value |
|---|---|---|
| 0 | `update_altimeter_needles` (0xc664) | two hands (long + 2/3) |
| 1 | `update_airspeed_needle` (0xc80c) | player +0x62a, non-linear scale |
| 3 | `update_climb_needle` (0xc948) | `DAT_0001bc80` (rate of climb) |
| 4 | `update_manifold_needle` (0xca44) | player +0x672 |
| 5 | `update_tachometer_needle` (0xc9c2) | player +0x66a (engine RPM) |
| 6 | `update_direction_needle` (0xc8d6) | camera heading `DAT_0001d80e` |
| flaps | `update_flaps_needle` (0xcc12) | player +0x67b (0..0xf) |
| gear | `update_gear_needles` (0xccca) | player +0x679 (0..0x2d), three legs |
| ammo | `update_ammo_needle` (0xce1c) | player +0x682 (675 rounds full scale) |
| fuel | `update_fuel_needles` (0xcec4) | player +0x67d / +0x67e (two tanks) |

The extra items use host panel words overlay +0x20e..+0x236;
`update_radar_scope` (0x17b68) draws heading-up blips in the rectangle at
host +0x1de..+0x1ea. Tracks: up to six (`add_radar_track`, metric ≤ 2 × range), cleared by
`reset_radar_tracks`; the Tab key cycles the range (`cycle_view_distance`,
named before the radar link was found). `update_heading_tape` scrolls the
compass strip by the heading.
