# Data locations

Where the original keeps its mission, world and cockpit data, and how the code reaches it. Each part ends with its evidence table.

## Mission data locations

### Result

The eight selectable missions are not stored as complete records in `STR#`,
`DITL`, or any `DATA` resource. Their scene/object descriptions are in the data
fork of the separate file `sources/hellcats-over-the-pacific/Pacific Conflict`;
mission-number-specific rules are also hardcoded in the executable overlay at
the front of that file. The main application's resources provide the selection
UI, saved scenery filename, result text, loader, and host runtime.

Certainty terms in this report are strict: **PROVEN** means directly supported
by original bytes or instructions; **VERIFIED** means confirmed by deterministic
parsing or multiple independent code paths; **STRONG INFERENCE** means the role is
strongly suggested but not closed; **UNKNOWN** means the evidence is
insufficient.

### External file layout

`sources/hellcats-over-the-pacific/Pacific Conflict` is 255,360 bytes
(`0x3e580`), SHA-256
`ee6040c7c38586551f95bf62a96453eef41b8b27409bc89d7a6689dc2c8b5030`.

The first 32 bytes are eight big-endian 32-bit values:

```text
00000107 0001a75c 00000dc8 0000b2a4
00000000 000010f2 00007078 000003d8
```

`CODE:8` `load_overlay_from_resource` (`ID08`, function offset `0x0006`)
reads that header, two image chunks of `0x1a75c` and `0x0dc8` bytes, then
relocation streams of `0x7078` and `0x03d8` bytes.
`alloc_and_read_resource_payload` (`ID08:0x0348`) reads the remainder of the
open data fork into host global `A5-0x12fc`. Therefore the world/mission payload
is exactly:

| Range in `Pacific Conflict` | Length | Meaning | Certainty |
| --- | ---: | --- | --- |
| `0x00000..0x0001f` | `0x20` | overlay header | PROVEN |
| `0x00020..0x1a77b` | `0x1a75c` | first overlay image | PROVEN |
| `0x1a77c..0x1b543` | `0x0dc8` | second overlay image | PROVEN |
| `0x1b544..0x225bb` | `0x7078` | first relocation stream, 3,599 8-byte records | VERIFIED |
| `0x225bc..0x22993` | `0x03d8` | second relocation stream, 123 8-byte records | VERIFIED |
| `0x22994..0x3e57f` | `0x1bbec` | packed scene/world/mission payload | PROVEN |

The filename is loaded from `HEL1:127` at record offset `0x2a`: the Pascal
string `Pacific Conflict`. `bootstrap_window_and_load_overlay` (`CODE:8`,
`ID08:0x039c`) passes it to the loader. Failure reaches
`show_scenery_open_error_alert` (`CODE:4`, `ID04:0x044e`) and
`ALRT`/`DITL:256`. `ALRT`/`DITL:261` separately instructs the user to install
both `Hellcats` and `Pacific Conflict`. This proves that the companion file is
required, not an optional embedded resource.

### Mission directory and exact descriptors

The payload root begins at file offset `0x22994`. Its kind byte is 3 and its
child count at root `+0x18` is 41. `init_mission_object_tables`
(`Pacific Conflict` overlay `0x16e2`) instantiates the root and copies its child
entries; each packed child record is `0x18` bytes and its relative descriptor
pointer is at `+0x14`. `start_mission_scene` (`0x3ac4`) selects the entry at
`root_runtime_table + mission_number * 0x18 + 0x74`, algebraically child index
`mission_number + 4`.

The following offsets were read deterministically from the original big-endian
payload. Descriptor file offset is `0x22994 + relative_pointer`.

| Mission number | UI name | Root child | Child record | Relative descriptor | Descriptor file offset | Certainty |
| ---: | --- | ---: | ---: | ---: | ---: | --- |
| 2 | Flight School | 6 | `0x22a3e` | `0x000008ae` | `0x23242` | VERIFIED |
| 3 | Bomb Base | 7 | `0x22a56` | `0x0000661c` | `0x28fb0` | VERIFIED |
| 4 | Capture Island | 8 | `0x22a6e` | `0x000150e8` | `0x37a7c` | VERIFIED |
| 5 | Flying Fortress | 9 | `0x22a86` | `0x0001620e` | `0x38ba2` | VERIFIED |
| 6 | Scramble! | 10 | `0x22a9e` | `0x00018cca` | `0x3b65e` | VERIFIED |
| 7 | Divine Wind | 11 | `0x22ab6` | `0x000196cc` | `0x3c060` | VERIFIED |
| 8 | Flattop | 12 | `0x22ace` | `0x0001991a` | `0x3c2ae` | VERIFIED |
| 9 | The Duel | 13 | `0x22ae6` | `0x00019f40` | `0x3c8d4` | VERIFIED |

The names themselves occur in `DITL:129` items 9–16.
`run_scenario_selection_dialog` (`CODE:4`, `ID04:0x0c02`) maps those radio
items to mission numbers 2–9. This proves the UI mapping, but the names are not
mission structures.

### Full execution path

1. `run_scenario_selection_dialog` returns mission 2–9.
2. `start_new_mission` (`CODE:2`, `ID02:0x35e4`) calls the overlay hook at `A5-0x109a`.
3. `overlay_main_entry` (`Pacific Conflict:0x1112`) installs `start_mission_scene` (`0x3ac4`) in that hook.
4. `start_mission_scene` activates the corresponding root child and constructs runtime objects from the external descriptor graph.
5. `run_flight_session` (`CODE:2`, `ID02:0x04fc`) drives the frame hook `A5-0x107a` (`Pacific Conflict:0x6598`) and input/outcome hook `A5-0x106a` (`0x740a`).
6. Overlay controller/AI routines write the signed objective state at host `+0xce`: zero pending, positive success, negative failure.
7. `conclude_mission` (`CODE:4`, `ID04:0x31aa`) and the summary dialog consume the outcome and `STR#:129` messages.

### Located hardcoded objective rules

These are executable rules, not claims that the full descriptor schema is decoded.

| Mission | Original rule evidence | Function/offset | Certainty |
| --- | --- | --- | --- |
| Bomb Base (3) | Bomb impact within `0xce40` of `(-0x3bcd3, 0x2b246a)` sets objective success; same point is map target T | bomb-impact branch near `0x12a2a`; `plot_mission_map_symbols:0x0954` | VERIFIED |
| Capture Island (4) | Bomb impact within `0xce40` of `(-0xf2bf12, 0xb242d8)` sets success; same point is map target T | bomb-impact branch near `0x12a2a`; `plot_mission_map_symbols:0x0954` | VERIFIED |
| Flying Fortress (5) | destruction of aircraft template/type 2 sets failure; friendly-bomber route completion sets success | aircraft-damage branch near `0x10400`; `tick_ai_1b370_mission:0x10f68` | VERIFIED |
| Scramble! (6) | destruction of aircraft template/type 3 sets success | aircraft-damage branch near `0x10400` | VERIFIED |
| Divine Wind (7) | controller creates ten mission targets; empty target list sets success; loss of the protected friendly facility/carrier sets failure | controller key `0x14`; `remove_mission_target:0x17ffe`; `step_sinking_object:0x14d86` | VERIFIED |
| Flattop (8) | sinking type-`0x15` mission ship near enemy facility kind `0x100` sets success | `step_sinking_object:0x14d86` | VERIFIED |
| The Duel (9) | enemy-facility ship result sets success; protected-friendly-facility ship result sets failure | `step_sinking_object:0x14d86` | VERIFIED |
| Flight School (2) | mission map is deliberately unavailable; complete training objective sequence is not yet identified | `run_map_dialog:ID04:0x3976` | PROVEN for map exclusion; UNKNOWN for objectives |

`STR#:129` slots 29–37 provide generic and mission-specific completion/failure
prose, including B-17, Henderson Field, and carrier outcomes. They corroborate
the branches but are not objective definitions.

Starting pose, aircraft loadout, teams, AI controller selection, and most entity
placement are encoded in or selected while instantiating the mission descriptor
subtrees. Their exact field schemas are still **UNKNOWN**; it would be
inaccurate to promote the offsets above into a fully decoded mission format.

### Evidence table

| Component | Original source | Function/resource | Certainty | Missing evidence |
| --- | --- | --- | --- | --- |
| Mission selection | main resource fork | `DITL:129`; `run_scenario_selection_dialog` | PROVEN | none for 2–9 mapping |
| Mission scene roots | `Pacific Conflict` data fork | payload `0x22994..0x3e57f`; table above | VERIFIED | child field semantics |
| Mission objectives | external descriptors plus overlay code | mission branches listed above | VERIFIED in listed branches | Flight School rules; full trigger graph |
| Starting state/loadout | mission descriptor subtrees | first descriptor at `0x23242` | UNKNOWN | packed record decoder and initialization trace |
| Enemy/friendly spawning | descriptor objects plus controller factories | `start_mission_scene`, controller tables | STRONG INFERENCE | definition-to-entity schema |
| Completion/reporting | overlay objective word and host UI | host `+0xce`; `conclude_mission`; `STR#:129` | VERIFIED | exact scoring formula still partial |

## World and scenery data locations

### Result

The original world is driven by the packed scene graph in the external
`sources/hellcats-over-the-pacific/Pacific Conflict` data fork, not by
`PICT:137`, `DITL:137`, `MDPL`, or an embedded main-application scenery
resource. The navigation map traverses the same active mission scene graph used
to build and render 3D objects. `DLOG`/`DITL:137` supplies only the dialog shell
and its 253 × 253 custom-drawn rectangle.

Certainty labels mean: **PROVEN** direct original-byte/instruction evidence;
**VERIFIED** deterministic parse or corroborated code flow; **STRONG INFERENCE**
plausible but not closed; **UNKNOWN** insufficient evidence.

### Source and loader

See `MISSION_DATA_LOCATIONS.md` for the byte-exact file layout. In brief,
`CODE:8` reads `Pacific Conflict` as a normal Macintosh data fork through the
File Manager glue in `CODE:9` (`FSOpen` near `ID09:0x02a6`,
`FSClose:0x02de`, `FSRead/FSWrite:0x02fa/0x02fe`, `GetEOF:0x0368`,
`GetFPos:0x038c`). The file remainder `0x22994..0x3e57f`, length `0x1bbec`,
is allocated at host `A5-0x12fc` and becomes the overlay's host pointer `+0x8c`.

`ALRT`/`DITL:256` is the open-failure path. `ALRT`/`DITL:261` identifies the
companion file as required installation content. No Resource Manager lookup
selects a world resource ID.

### Packed and runtime scene representation

The packed root at file `0x22994` is kind 3 with 41 children. The established portion of the layout is:

| Field | Meaning | Certainty |
| --- | --- | --- |
| descriptor byte `+0` | kind; 3 is a group/container | VERIFIED |
| descriptor `+0x18` | child count | VERIFIED |
| descriptor `+0x1a` | first child record | VERIFIED |
| child record size | `0x18` bytes | VERIFIED |
| child record `+0x14` | pointer relative to payload base `0x22994` | VERIFIED |

`init_mission_object_tables` (`Pacific Conflict:0x16e2`) and
`alloc_object_from_desc` (`0x45ba`) instantiate this data.
`traverse_scene_tree` (`0x05fa`) recursively follows kind-3 groups.
`for_each_mission_scene_object` (`0x06a6`) chooses the current mission's scene
root from the 0x18-byte runtime table and traverses it.

Object and land geometry are then built by `build_object_poly_buffers`
(`0x4808`) and `build_land_outline_at_detail` (`0x4958`). The latter is rebuilt
at distance/altitude-dependent detail levels, so the final coastline mesh is
data-driven plus runtime LOD generation, not a static screen bitmap.

World positions are signed 32-bit coordinates. Attitude routines consistently
use a turn modulus of `0x4000`. The exact conversion of world units to physical
miles is **UNKNOWN**. The map code contains `0xce40` distance thresholds and its
scale UI reports miles per grid, but that is not sufficient to assert a
universal unit ratio.

### Navigation map uses the same world

`collect_map_features` (`Pacific Conflict:0x06ec`) is a visitor invoked by
`plot_mission_map_symbols` (`0x0954`) through
`for_each_mission_scene_object`. It:

- transforms scene-object vertices through `transform_through_node_chain` (`0x04f8`);
- selects land objects using flag `0x10` while excluding `0x240`;
- clips their transformed outlines to the map rectangle;
- classifies type-nibble `0x70` objects as mapped airfield points;
- associates facility kinds `0x12`/`0x13` with base/carrier symbols.

Map coordinates are computed directly from the player and world positions:

```text
map_x = (world_x - player_x) / map_scale
map_y = (player_z - world_z) / map_scale
```

For missions 3 and 4, `plot_mission_map_symbols` adds hardcoded target `T`
positions `(-0x3bcd3, 0x2b246a)` and `(-0xf2bf12, 0xb242d8)`. The same
coordinates are checked by the bomb-impact objective code.

On the host side, `draw_map_view_item` (`CODE:4`, `ID04:0x33d6`) paints the
blue map background and calls overlay hook `A5-0x1052`, installed as
`plot_mission_map_symbols`. `draw_map_grid_and_centre_mark` (`ID04:0x3260`)
and `plot_map_symbol_callback` (`0x3352`) draw the UI.
`track_map_bearing_and_distance` (`0x3614`) derives navigation feedback. The
map scale passed to the overlay is calculated from saved setting `+0x26`,
`4 * 0xce40`, and the map width.

This data path **PROVES** that the navigation map and flight renderer share the
active external scene graph. They render it differently; they do not use
separate world databases.

### Flight rendering path

The original has distinct but connected pipelines:

| Content | Construction/render path | Certainty |
| --- | --- | --- |
| menus/dialogs/map chrome | Resource Manager UI plus QuickDraw primitives | PROVEN |
| world geometry | external descriptors → runtime meshes → transforms/projection → polygon edges/spans | VERIFIED |
| 1-bit world output | overlay visibility/projection → `CODE:6` scanline rasterizer | VERIFIED |
| 4/8-bit world output | overlay depth-specific edge/span rasterizers | VERIFIED |
| final presentation | offscreen frame → `blit_offscreen_frame_to_window` (`CODE:2`, `ID02:0x0d3a`) / CopyBits path | VERIFIED |

`render_visible_objects` (`Pacific Conflict:0xac72`) performs
visible-object/face submission. Camera and hierarchy transforms begin around
`0x1d02`; face clipping, perspective, and edge generation feed either the
overlay color-depth span code or the host `CODE:6` rasterizer (`reset` near
`ID06:0x096e`, polygon-edge addition `0x09d8`, rasterize/present `0x0e10`).
Face records are built from original object descriptors, including vertices,
indices, detail thresholds, and optional BSP ordering.

Water, sky/horizon, and terrain contact have runtime code paths rather than a
PICT backdrop. Relevant routines include `test_terrain_collision`/surface
queries near `0x13cdc`, `handle_terrain_contact:0x14198`, land LOD rebuilding,
and altitude-following horizon/ground reference objects. The exact packed
terrain-height/land-outline schema is still only partially decoded.

### Resource census

There are 30 directories in this extraction. The table records their
demonstrated role and prevents UI/resources from being mistaken for scenery.

| Type | Established role | Mission/world/HUD source? | Certainty |
| --- | --- | --- | --- |
| `ALRT` | alert templates, including 256 and 261 | loader/install evidence only | PROVEN |
| `BNDL` | Finder bundle mapping | no | PROVEN |
| `CNTL` | dialog control templates | no | VERIFIED |
| `CODE` | host 68K executable segments | loader, map UI, rasterizer, panel construction | PROVEN |
| `DATA` | `DATA:0` compressed A5 initializer; `DATA:128` protection-related opaque block | filename/default state, not world payload | VERIFIED / partial |
| `DITL` | dialog item lists | names/map shell only | PROVEN |
| `DLOG` | dialog layouts | map shell only | PROVEN |
| `DREL` | A5-world relocation information | executable startup support | VERIFIED |
| `FREF` | Finder file references | no | PROVEN |
| `HEL1` | saved settings and roster | scenery filename/settings only | VERIFIED |
| `HELL` | Finder/Get Info text | no | VERIFIED |
| `ICN#`, `ICON`, `icI4`, `icI8`, `ics#`, `ics4`, `ics8` | Finder/app icons | no | PROVEN |
| `MDPL` | opaque custom resource; no proven loader/consumer | UNKNOWN; not evidence of world data | UNKNOWN |
| `MENU` | menus | no | PROVEN |
| `PICT` | about, refuel, credits, protection pictures | no world/cockpit picture | VERIFIED |
| `SIZE` | Macintosh memory/launch settings | no | PROVEN |
| `STR#` | result, help, UI, instrument label strings | text only | PROVEN |
| `TEXT`, `styl` | about/help/protection text and styling | no | VERIFIED |
| `ZERO` | zero-initialization stream | runtime startup support, not serialized world | VERIFIED |
| `cicn` | color UI/award icons | no | VERIFIED |
| `clut` | display/world palette tables | rendering dependency, not geometry | VERIFIED |
| `snds` | sound resources | no | VERIFIED |
| `vers` | version metadata | no | PROVEN |

`MDPL` remains deliberately **UNKNOWN**: no current code reference proves a
role, so its suggestive type name is not promoted to model/world evidence.

### Evidence table

| Component | Original source | Function/resource | Certainty | Missing evidence |
| --- | --- | --- | --- | --- |
| World root | external data fork | `Pacific Conflict:0x22994..0x3e57f` | PROVEN | full field schema |
| Terrain/islands | external scene objects plus runtime LOD | `build_land_outline_at_detail:0x4958` | VERIFIED source/path | elevation/outline record semantics |
| Airfields | active scene graph | type nibble `0x70`, `collect_map_features:0x06ec` | VERIFIED classification path | exact descriptor fields |
| Bases/carriers | active scene graph | facility kinds `0x12`/`0x13` | VERIFIED map classification | complete object identities and meshes |
| Mission map | shared scene graph plus dialog chrome | `DITL:137`, overlay `0x06ec/0x0954`, host `ID04:0x33d6` | PROVEN | none for data sharing |
| World rasterization | overlay and `CODE:6` | `render_visible_objects:0xac72`; scanline functions | VERIFIED | remaining color-depth routine details |
| World scale | signed coordinates; angle modulus known | map scale formula, transforms | STRONG INFERENCE | authoritative physical-unit conversion |
| `MDPL` | main resource fork | no proven consumer | UNKNOWN | format and references |

## Cockpit and HUD data locations

### Result

The cockpit is not stored as one `PICT`. The clean application resource fork
contains five PICTs—about artwork (128/129), refueling photograph (130),
credits (131), and protection instructions (1000)—and none is a cockpit panel.
The static instrument panel is drawn procedurally by `CODE:3` with QuickDraw
into offscreen bitmaps; the `Pacific Conflict` overlay draws dynamic needles,
heading tape, radar, and readouts from flight state, including direct 4/8-bit
framebuffer line routines.

Certainty labels mean: **PROVEN** direct original-byte/instruction evidence;
**VERIFIED** deterministic/corroborated behavior; **STRONG INFERENCE** plausible but
incomplete; **UNKNOWN** insufficient evidence.

### Static panel construction

`prepare_instrument_panel` (`CODE:3`, `ID03:0x5cc4`) lays out and constructs
the panel. `draw_instrument` (`ID03:0x3c02`) dispatches ten panel types:

| Type | Instrument | Drawing function | Certainty |
| ---: | --- | ---: | --- |
| 0 | altimeter | `ID03:0x1876` | VERIFIED |
| 1 | airspeed | `ID03:0x1b48` | VERIFIED |
| 2 | turn/bank | `ID03:0x2d1c` | VERIFIED |
| 3 | vertical speed/climb | `ID03:0x1fee` | VERIFIED |
| 4 | manifold pressure | `ID03:0x2600` | VERIFIED |
| 5 | tachometer | `ID03:0x22fe` | VERIFIED |
| 6 | direction/heading | `ID03:0x2950` | VERIFIED |
| 7 | empty/none | dispatch no-op | PROVEN |
| 8 | gyro | `ID03:0x32b8` | VERIFIED |
| 9 | artificial horizon | `ID03:0x38fc` | VERIFIED |

The routines use QuickDraw ovals, arcs, lines, fills, numerals, and labels from
`STR#:129` slots 65–78. `begin_instrument_supersample` (`0x1538`),
`composite_instrument_bitmap` (`0x146a`), and
`finish_instrument_supersample` (`0x1844`) implement offscreen construction.
At depth 1, composition uses the monochrome bitmap path/CopyBits semantics;
color configurations use a 3× temporary render and antialiased downsample.

Additional static panel routines construct flaps, landing gear, ammunition,
fuel, and other panel items. Their geometry is procedural and their
centers/needle lengths are recorded in the host panel table at `A5-0x12a2` for
the overlay.

### Generated `HEL2` cache, not source art

`store_panel_bitmaps_as_resources` (`CODE:3`, `ID03:0x5ab6`) writes
runtime-generated cache resources of type `HEL2`: ID 127 for the panel cache
and per-configuration IDs in the 200/300/400/500 series named `Bitmap`,
`HorizonInstrument`, `GyroInstrument`, and `GyroFlags`.
`prepare_instrument_panel` creates them when needed.

No `HEL2` directory/resource exists in the clean extracted application fork.
Therefore these are generated cache artifacts, not the original authored
cockpit source. Treating a recovered user preference/resource file containing
`HEL2` as cockpit artwork would reverse cause and effect.

### Flight state to dynamic display

The overlay's `update_view_readouts_and_overlays`
(`Pacific Conflict:0xd00c`) orchestrates panel updates. `draw_gauge_needle`
(`0xc572`) erases the previous line from the saved static panel and draws the
new line. Its callers provide these source values:

| Visible item | Flight-state source | Update function | Certainty |
| --- | --- | --- | --- |
| altimeter, two hands | player altitude/derived angle | `0xc664` | VERIFIED path; hand interpretation STRONG INFERENCE |
| airspeed | player `+0x62a` | `0xc80c` | VERIFIED |
| direction | camera heading | `0xc8d6` | VERIFIED |
| vertical speed | overlay climb-rate value `DAT_0001bc80` | `0xc948` | VERIFIED |
| tachometer | player `+0x66a` | `0xc9c2` | VERIFIED |
| manifold pressure | player `+0x672` | `0xca44` | VERIFIED |
| flaps | player byte `+0x67b` | `0xcc12` | VERIFIED |
| landing gear, three needles/lamps | player byte `+0x679` | `0xccca` | VERIFIED |
| ammunition | player word `+0x682`, 675-round scale | `0xce1c` | VERIFIED |
| fuel, two tanks | player bytes `+0x67d/+0x67e` | `0xcec4` | VERIFIED |

The heading tape is updated by `update_heading_tape` (`0xc1aa`). Radar
collection and display culminate in `update_radar_scope` (`0x17b68`), which
draws up to six tracked objects. Depth-8 and depth-4 line functions write
directly into the frame buffer and restore erased needle pixels from the saved
static panel; at depth 1 the overlay calls the host line service.

The exact crosshair/gunsight routine and any cockpit-attached 3D framing object
are not yet conclusively separated from the view renderer.
`tick_view_attached_object` (`0x19bbc`) is a promising but still **STRONG INFERENCE**
camera-attached-object path. No resource has been relabeled as a gunsight
without that proof.

### Coordinates, palette, and presentation

The panel is resolution-aware rather than a fixed-size bitmap. Host view
dimensions and pixel depth (1, 4, or 8) select renderer paths; layout
calculations use scaled panel coordinates, including a 4800 design denominator.
The clean binary has a special 512-wide/342-high screen-layout case (with
menu/view deductions), but this is not evidence for a universal fixed cockpit
canvas.

Color indices depend on the original `clut` resources and display-depth setup.
Static panel bitmaps are composited into the offscreen frame. Dynamic color
needles/readouts can be written directly into that framebuffer. Final
presentation reaches `blit_offscreen_frame_to_window` (`CODE:2`,
`ID02:0x0d3a`) and the CopyBits/window path.

World polygons, cockpit panel, map, and menus therefore use related but separate drawing stages:

| Stage | Primary mechanism |
| --- | --- |
| world | custom polygon/scanline rasterization |
| static cockpit | procedural QuickDraw into cached offscreen bitmap |
| dynamic cockpit/HUD | overlay calculations plus depth-specific framebuffer/line drawing |
| map | scene traversal plus host QuickDraw custom item |
| menus/dialogs | Resource Manager and QuickDraw |

### PICT exclusion evidence

| PICT | Proven/verified identity | Why it is not cockpit art |
| ---: | --- | --- |
| 128 | color About-dialog background, linked from `DITL:127` | dialog relationship and decoded render |
| 129 | monochrome About-dialog background, linked from `DITL:138` | dialog relationship and decoded render |
| 130 | refueling ground-crew photograph, linked from `DITL:132` | dialog relationship and decoded render |
| 131 | About/credits scroll picture | decoded render and credits use |
| 1000 | copy-protection instructions, linked from `DITL:1000` | dialog relationship and decoded render |

Icons and `cicn` resources are Finder/UI/award imagery, not an instrument
panel. `STR#:129` instrument words are labels, not bitmaps.

### Evidence table

| Component | Original source | Function/resource | Certainty | Missing evidence |
| --- | --- | --- | --- | --- |
| Cockpit panel | executable procedural drawing | `CODE:3`, `prepare_instrument_panel:0x5cc4` | VERIFIED | complete layout record documentation |
| Gauge faces | QuickDraw primitives and `STR#:129` labels | `draw_instrument:0x3c02` and dispatch table | VERIFIED | pixel-perfect render comparison |
| Dynamic needles | flight state plus overlay framebuffer routines | `Pacific Conflict:0xc572..0xcec4` | VERIFIED | a few semantic/unit calibrations |
| Artificial horizon/gyro | procedural static/dynamic combination | `ID03:0x32b8/0x38fc`; generated `HEL2` cache | VERIFIED source | full dynamic overlay trace |
| Heading tape | overlay code | `update_heading_tape:0xc1aa` | VERIFIED | exact label/clip documentation |
| Radar | runtime tracked-object list | `update_radar_scope:0x17b68` | VERIFIED | all blip semantics |
| Gunsight/crosshair | likely overlay/view code | not conclusively isolated | UNKNOWN | exact draw function and inputs |
| Cockpit artwork PICT | none in clean resource fork | PICT 128/129/130/131/1000 are non-cockpit | VERIFIED | none for exclusion of known PICTs |
| Final framebuffer | offscreen frame and CopyBits/window presentation | `ID02:0x0d3a` | VERIFIED | timing/double-buffer details |
