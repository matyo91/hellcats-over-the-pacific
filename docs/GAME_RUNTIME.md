# Game runtime: running the strict port in Godot

`godot/scenes/game/Game.tscn` runs the original program (`StrictID02.main`, CODE 2 0x309a) from
the strict port on a Macintosh built in GDScript under `godot/hellcats/`. `godot/strict_port/` is
not edited: the runtime provides what the port calls through its tables.

## Architecture

| Part | File | Role |
|---|---|---|
| Machine | `hellcats/runtime/mac_machine.gd` | One flat 68000 address space (the strict port's `Memory68k`), its memory map, low-memory globals, missing-feature log |
| Segments | `hellcats/runtime/segment_loader.gd` | The CODE 2..9 ports on that memory and A5, linked through the CODE 0 jump table (`hellcats/data/jump_table.json`); unported slots go to runtime stand-ins |
| Toolbox | `hellcats/toolbox/*.gd` | The trap table: every A-line word starts as a logging stand-in; the managers install what they implement |
| Thread | `hellcats/runtime/game_thread.gd` | `main()` never returns and polls for events, so it runs on its own thread |
| Screen | `hellcats/runtime/mac_screen.gd`, `.gdshader` | The 640 x 480 8-bit screen bytes shown through the default 8-bit colour table |

`tools/hellcats/build_runtime_data.py` writes `hellcats/data/` from the original files: the jump
table (175 entries, 117 targeting ported routines), the resource names, and the Pacific Conflict
scenery file (`--check` verifies them).

Memory map (24-bit, `hellcats/runtime/mac_memory.gd`: the high address byte is ignored, as by the
Memory Manager of the game's era): the overlay at its base 0 (the strict overlay port addresses its
data by file offset - 0x20), low-memory globals sharing that range, A5 at 0x0c0000, the stack
below 0x0ff000, the heap from 0x100000, the sound buffer at 0x6f0000 and the screen at 0x700000.

Start-up as the original's C runtime (CODE 1 0x34) does it: the A5 world from DATA 0 (words, each
zero word followed by a ZERO 0 count of zero bytes) up to A5, then DREL 0's cells relocated by A5.

Overlay loading (`hellcats/runtime/overlay_loader.gd`): ID08 reads the scenery file, allocates the
image and relocates it by its address. The runtime gives the image the address 0x01000000 (low 24
bits 0), takes that base off the relocated longs again and writes back the low-memory globals the
image covered, so the bytes sit where the overlay port reads them; then it links the overlay's
entry and hooks (`hellcats/data/overlay_methods.json`: ported routines by runtime address) and
gives the overlay the host's jump-table slot addresses (the service table ID02 0x1b42 fills).

Calling conventions: a port passes a call's arguments last-pushed first. That is the parameter
order of MPW C routines; the CODE 9 glue is Pascal, so the slot reverses them for it.

Text: the resource fork holds no FONT / NFNT and Godot ships no Chicago or Geneva, so
`hellcats/toolbox/glyph_cache.gd` rasterises the nearest installed face without antialiasing
(on the main thread, before the game thread starts) into one-bit glyphs QuickDraw draws.

Arguments a port passes by value where the original passed an address (rects and strings its
test stubs logged by value) are read either way; a rect changed in place through such a value
(InsetRect, OffsetRect) keeps its change for the next use of the same value.

QuickDraw polygons record the pen's moves between OpenPoly and ClosePoly and fill by scanlines;
regions are their bounding rects (OpenRgn / CloseRgn record the extent drawn). Every ported
overlay routine is reachable by its runtime address (the overlay jumps through the addresses it
stores for controller ticks and collision hooks); the ones outside the 740 are logged stand-ins
until written.

The stack: every routine the runtime calls from outside the ports (a hook, a procedure pointer, an
adapter) gets a stack pointer below all the ports' frames (`MacMachine.free_stack`) and has its
own restored afterwards; without the restore the frames sank a little each frame until they
overwrote the overlay's data (the span run-writer tables at 0x20cec).

Ported routines the ports call by offset (`_local`) or by stored code address are all registered
(`hellcats/data/segment_methods.json`, and the overlay's routines by runtime address, including
the second entries the port documents inside another routine's extent); a call to a routine
without a result answers 0.

Colour: a colour port keeps the pixel values it draws with in fgColor / bkColor (+0x50 / +0x54),
as Color QuickDraw does; the program both sets RGB colours and stores device indices there itself.
The screen device's 256 colours (`hellcats/toolbox/palette_manager.gd`) start as the default 8-bit
table and follow the program: SetEntries, its palettes (SetEntryColor / SetEntryUsage, SetPalette /
ActivatePalette, AnimateEntry / AnimatePalette); palette entry i owns device index i + 1 (0 and 255,
white and black, stay the system's), PmForeColor leaves that index in the port, and the Godot
screen redraws through the table when it changes. CopyBits follows a colour port's portBits (the
PixMap handle, marked by the rowBytes field's two high bits).

Sound: the program mixes its channels itself into the Mac's sound buffer (SoundBase, 370 samples
every tick) from the VBL handler it puts in the SoundHook; the runtime runs that hook once per
elapsed tick at the program's trap calls, as the interrupt would arrive between them
(`hellcats/toolbox/sound_manager.gd`), and `hellcats/runtime/mac_speaker.gd` plays the samples at
22254.5 Hz. Saving: the resources the program writes back (the pilot roster, the settings) are
kept under Godot's `user://resources/<type>/<id>.bin` and read before the originals; delete that
folder to start afresh.

Regions are kept as their bounding rects, except a region framed from one oval alone (OpenRgn /
FrameOval / CloseRgn): it also keeps the oval, so the instrument faces drawn through such a clip and
the artificial horizon's row spans (PtInRgn) come out round. The instrument panel is built once and
cached by the program as 'HEL2' resources (saved under `user://resources`): a change to the panel
drawing needs that folder cleared to be seen.

Between flights (Escape interrupts one) the menus and their ⌘ keys work: Mission Status, Mission
Map, Instant Replay, Resume, the Options and Scenery toggles.

Input during a flight is the original's: the mouse is the stick (its button the guns) and only
keys are read, so the menus are reached by their ⌘ keys (the menu bar does not open on a click, and
other events are drained); HideCursor / ShowCursor / InitCursor keep the Mac cursor's level, which
hides Godot's pointer during the flight.

The strict port passes the rects that traps change in place (InsetRect, OffsetRect) by their
frame address, as the original pushes them, so the change lands where the program reads it back;
read-only rects may still come by value (two longs). FSRead's count is the caller's long too: the
bytes read are written back into it. Pictures (DrawPicture, dialog picture items) are decoded from
the mirror's PNG on the game's thread without making textures.

Routines outside the 740 (Ghidra never defined them) are written from their disassembly in
`hellcats/runtime/unexported.gd` and registered where the port calls them.

`tools/qa/test_regression.py` (`check_runtime_coverage`) keeps the runtime complete: every
jump-table slot and segment-local offset the strict port calls, every slot the CODE segments hand
out as a procedure, every code pointer in the overlay's relocation table and every trap word the
ports use must have a routine behind it, so a gap fails the check before anyone plays into it.

Those written routines are also checked against their original bytes where they stand alone:
`tools/hellcats/gen_runtime_cases.py` runs them on the 68000 interpreter (`tools/strict_port/
m68k_emu.py`) and `godot/tests/runtime/test_unexported_routines.gd` replays the cases on the
runtime, comparing the D0 and the memory each leaves (ansi_strlen, ansi_strncmp, lock / unlock_
session_handles, save_changed_settings, restore_screen_globals, apply_display_palettes,
install_overlay_service_table, release_panel_bitmaps, report_panel_store_failure,
redraw_panel_readouts_locked, end_overlay_session, install_default_ring_item,
set_radio_group_selection, track_summary_text_click, quit_application, draw_rank_insignia,
draw_mission_awards, run_map_dialog, track_map_bearing_and_distance, run_refuel_dialog,
run_scenario_selection_dialog, run_duty_roster_dialog, run_high_scores_dialog,
mission_summary_filter_proc, advance_mission_summary_text (every stage) and release_render_buffers
(with the calls they make, overlay hooks and Dialog, Control Manager and TextEdit traps, DisposPtr
and the overlay's heading and square-root services included), arm_restore_gate,
build_protection_code_strings, the grey-map accessor, carrier_deck_contact on its own image,
player_left_ground_zone, the 1-bit erase hook and redraw_view_readouts (its four drawing callees
stubbed): every written routine but the IUCompString glue, whose comparison is the System's _Pack6
and not in the game's bytes; Toolbox traps and Pascal glue stubbed on the emulator side).

An end-to-end session is `tests/runtime/smoke_session.gd`, kept out of `run_all.gd` because it runs
for about a minute and a half:
`Godot --headless --path godot --script res://tests/runtime/smoke_session.gd [-- --shots <dir>]`.
Driven as a player would, the program goes through the start-up dialogs and Select a Mission into the
cockpit. The session then throttles up, flies the chase, tower and cockpit views, works the gear,
flaps and stick, and uses the menus' command keys (triple time, detail, sound, map, status, resume).
It pauses and resumes, ejects, returns to the desktop through the mission summary, and tries Instant
Replay.
It fails when the program's thread dies or the runtime notes anything missing. It saves into
`user://smoke_session_resources` (emptied first), never the player's `user://resources`.

### Traps the game never issues

The Toolbox installs 293 trap words. Scanning the original bytes at instruction boundaries (the host
segments ID01..ID08 and the *Pacific Conflict* code; ID09's glue is answered by stand-ins instead) finds
174 issued words (auto-pop variants folded). Of the other 119, three are still reached another way
(_Open $A000 and SwapMMUMode $A05D by the strict port of ID09's glue, FlushEvents $A032 by a
stand-in).
The remaining 116 have no user besides their installation, in the game's bytes, the strict port, the
runtime or the tests. They are cleanup candidates, kept for now because another scenery file opened
with File > Open... could issue them:

$A001 $A002 $A01C $A01F $A021 $A023 $A027 $A029 $A02A $A036 $A049 $A04A $A063 $A069 $A06A $A11D
$A11E $A122 $A31E $A322 $A802 $A803 $A804 $A806 $A81F $A820 $A827 $A828 $A851 $A856 $A860 $A86D
$A87C $A886 $A889 $A896 $A897 $A89E $A8A4 $A8AA $A8AB $A8B1 $A8B2 $A8B3 $A8B9 $A8C8 $A8C9 $A8D2
$A8D4 $A8D5 $A8DC $A8DD $A8DE $A8E0 $A8E4 $A8E5 $A8E7 $A8F5 $A904 $A910 $A914 $A917 $A918 $A919
$A91A $A925 $A927 $A929 $A92A $A92D $A936 $A93B $A944 $A949 $A94C $A950 $A956 $A95E $A961 $A962
$A964 $A969 $A96D $A971 $A976 $A977 $A978 $A97F $A984 $A987 $A992 $A9A4 $A9A5 $A9CB $A9CE $A9CF
$A9D1 $A9D8 $A9D9 $A9DA $A9DB $A9DC $AA15 $AA19 $AA1A $AA33 $AA34 $AA92 $AA93 $AA94 $AA96 $AA98
$AA99 $AA9A $AA9B $AA9F

## Routines outside the 740

Ghidra never defined these 35 routines, so they have no `.c` export and stay outside the registry;
the ones marked *decomp* are described in their segment's `.decomp.c` (an "Unexported function"
block, or the comment of the routine around them), with the semantic name used here. Each is written from the disassembly of its bytes; its start was checked to be a
routine boundary (a `LINK`, or the instruction after an `RTS` / `JMP (A0)`). Segment offsets are in
the CODE resource (`sources/resedit-1-0-3/CODE/<ID>.bin`); overlay addresses are runtime
addresses, the scenery file's offset less `0x20`. "Reached by" is how the port calls it: a
jump-table slot (`$offset`), its segment offset (local), or a code address.

| Segment | Offset | Reached by | Runtime | What it does |
|---|---|---|---|---|
| ID02 | 0x1b42 | local | `unexported.gd` `id02_1b42` | `install_overlay_service_table`: main's set-up (*decomp*) |
| ID02 | 0x4d24 | local | `id02_4d24` | `apply_display_palettes`: palette for the depth, index maps, the renderer (*decomp*) |
| ID02 | 0x4d96 | local | `id02_4d96` | `restore_screen_globals`: the screen device and globals (*decomp*) |
| ID02 | 0x04a4 | local | `id02_04a4` | `end_overlay_session`: end of an overlay session (sound shut down) (*decomp*) |
| ID02 | 0x095a | local | `id02_095a` | `lock_session_handles`: the first of nested calls (*decomp*) |
| ID02 | 0x09fa | local | `id02_09fa` | `unlock_session_handles`: the last of nested calls (*decomp*) |
| ID02 | 0x0a26 | local | `id02_0a26` | `redraw_panel_readouts_locked`: the overlay's readouts hook (*decomp*) |
| ID02 | 0x2da0 | local | `id02_2da0` | `save_changed_settings`: changed settings written (*decomp*) |
| ID02 | 0x2eaa | local | `id02_2eaa` | `quit_application`: asking to save changed settings (*decomp*) |
| ID02 | 0x0434 | `$502` | `id02_0434` | `ansi_strncmp` (*decomp*) |
| ID02 | 0x03e8 | `$522` | `id02_03e8` | `ansi_strlen` (*decomp*) |
| ID03 | 0x59f4 | local | `id03_59f4` | `release_panel_bitmaps`: the panel session handles (*decomp*) |
| ID04 | 0x0432 | `$172` | `id04_0432` | `report_panel_store_failure`: the event loop's pending message (*decomp*) |
| ID04 | 0x01b8 | local | `id04_01b8` | `install_default_ring_item`: the default button's ring user item (*decomp*) |
| ID04 | 0x02dc | local | `id04_02dc` | `set_radio_group_selection`: a radio group's selection (*decomp*) |
| ID04 | 0x0644 | `$132` | `id04_0644` | `run_duty_roster_dialog`: the Active Duty Roster dialog (*decomp*) |
| ID04 | 0x0c02 | `$82` | `id04_0c02` | `run_scenario_selection_dialog`: the Select a Mission dialog (*decomp*) |
| ID04 | 0x0e70 | `$9a` | `id04_0e70` | `run_refuel_dialog`: Refuel and Reload after a landing (*decomp*) |
| ID04 | 0x137a | `$102` | `id04_137a` | `run_high_scores_dialog`: the High Scores dialog (*decomp*) |
| ID04 | 0x1752 | local | `id04_1752` | `track_summary_text_click`: a click on the summary's scroll bar (*decomp*) |
| ID04 | 0x1b3e | `$15a` | `id04_1b3e` | `draw_rank_insignia`: the rank insignia user item (*decomp*) |
| ID04 | 0x1dde | `$152` | `id04_1dde` | `draw_mission_awards`: the medals user item (*decomp*) |
| ID04 | 0x2104 | `$ca` | `id04_2104` | `mission_summary_filter_proc`: the mission summary's dialog filter (*decomp*) |
| ID04 | 0x21d6 | local | `id04_21d6` | `advance_mission_summary_text`: the mission summary's text, one step a call (*decomp*) |
| ID04 | 0x3614 | local | `id04_3614` | `track_map_bearing_and_distance`: a click on the map, its heading and range (*decomp*) |
| ID04 | 0x3976 | `$10a` | `id04_3976` | `run_map_dialog`: the Mission Map dialog (*decomp*) |
| ID05 | 0x03ba | local | `id05_03ba` | `build_protection_code_strings`: the copy protection dialog's strings (*decomp*) |
| ID05 | 0x08b2 | `$532` | `id05_08b2` | `arm_restore_gate`: the protection counter (*decomp*) |
| ID06 | 0x00ee | `$1d2` | `id06_00ee` | the grey map pointer, the 1-bit view buffer base |
| ID06 | 0x0858 | `$1b2` | `id06_0858` | `release_render_buffers`, with `free_pattern_tables` (0x15a) and `free_edge_pool` (0x582) inlined (*decomp*) |
| ID09 | 0x03d6 | `$2ea` | `toolbox.gd` `iu_comp_string` | `iucompstring_glue`, IUCompString through `_Pack6` (*decomp*) |
| Pacific Conflict | 0x04b0 | hook | `overlay_loader.gd` `_04b0` | `player_left_ground_zone`: more than 4999 above its ground (*decomp*) |
| Pacific Conflict | 0xd23a | hook | `_d23a` | `redraw_view_readouts`: the readouts, gauges and overlays (*decomp*) |
| Pacific Conflict | 0x16208 | code address | `_16208` | the 1-bit renderer's erase hook: `clr.w $1da8c` |
| Pacific Conflict | 0x15134 | code address | `_15134` | `carrier_deck_contact`: the deck as ground (*decomp*) |

## Progress

| Milestone | State |
|---|---|
| 1. Machine, jump-table linking, trap table, game thread, screen scene | done |
| 2. Memory Manager, Resource Manager (from the strict resource mirror), Color QuickDraw device, SysEnvirons | done |
| 3. `initialize_application` runs to its end; InitWindows draws the desktop and menu bar | done |
| 4. Overlay load: File Manager, the A5 world from DATA / ZERO / DREL, the image at runtime base 0, overlay entry, hooks and host services | done |
| 5. Unexported routines: ID02 0x1b42, 0x4d24, 0x4d96, 0x4a4, 0x95a, 0x9fa, 0xa26, 0x2da0, 0x2eaa, 0x434 ($502 strncmp), 0x3e8 ($522 strlen); ID03 0x59f4; ID04 0x432 ($172), 0x644 ($132, the Active Duty Roster), 0xc02 ($82, Select a Mission), 0x1b8, 0x2dc, the mission summary's 0x21d6 (its text), 0x1752 (its scroll bar), 0x2104 ($ca, its filter), 0x1dde ($152, medals) and 0x1b3e ($15a, rank insignia), 0x3976 ($10a, the Mission Map) and 0x3614 (its click tracker), 0x137a ($102, High Scores), 0xe70 ($9a, Refuel and Reload); ID05 0x3ba, 0x8b2 ($532); ID06 0x858 ($1b2), 0xee ($1d2). Overlay routines 0x4b0, 0xd23a and the carrier's collision hook 0x15134 (the deck as the ground) | done |
| 6. QuickDraw (ports, patterns and modes, lines, rects, round rects, ovals, regions as rects plus single-oval regions for clipping and PtInRgn, text from a glyph cache, CopyBits, pictures, colour icons), Window / Dialog / Control (scroll bars: NewControl, FindControl, TrackControl) / Menu managers, TextEdit, Standard File's Get File (File > Open…, over the scenery volume; the overlay reloads), palettes | done |
| 7. Event Manager from Godot input (mouse, Mac key codes and GetKeys, ticks), update and activate events | done |
| 8. Pilot roster, mission selection, the 3D flight view from the carrier's deck, the cockpit view (V) with its instrument panel, keyboard and mouse input, ejecting, and the mission summary (its text, scroll bar, medals and rank); sound (the VBL sound hook run every tick into SoundBase and played through `scenes/game/Game.tscn`'s Speaker; SndPlay of 'snd ' resources); saving (WriteResource / UpdateResFile kept under `user://resources`) | done |
| 9. `scenes/main/Main.tscn` runs the game (Godot quits cleanly with the program's thread parked); the MVP prototype (its scenes, `hellcats/` scripts, data, tests and fixtures) removed, the QA checks moved to the game runtime | done |
