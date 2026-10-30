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

Rects the ports pass by value (two longs) to the traps that change them in place (InsetRect,
OffsetRect) are found in the frames below the ports' stack pointers and written back there, as
the VAR parameter would have been; pictures (DrawPicture, dialog picture items) are decoded from
the mirror's PNG on the game's thread without making textures.

Routines outside the 740 (Ghidra never defined them) are written from their disassembly in
`hellcats/runtime/unexported.gd` and registered where the port calls them.

## Progress

| Milestone | State |
|---|---|
| 1. Machine, jump-table linking, trap table, game thread, screen scene | done |
| 2. Memory Manager, Resource Manager (from the strict resource mirror), Color QuickDraw device, SysEnvirons | done |
| 3. `initialize_application` runs to its end; InitWindows draws the desktop and menu bar | done |
| 4. Overlay load: File Manager, the A5 world from DATA / ZERO / DREL, the image at runtime base 0, overlay entry, hooks and host services | done |
| 5. Unexported routines: ID02 0x1b42, 0x4d24, 0x4d96, 0x4a4, 0x95a, 0x9fa, 0xa26, 0xd24, 0x2da0, 0x2eaa, 0x434 ($502 strncmp), 0x3e8 ($522 strlen); ID03 0x59f4; ID04 0x432 ($172), 0x644 ($132, the Active Duty Roster), 0xc02 ($82, Select a Mission), 0x1b8, 0x2dc, the mission summary's 0x21d6 (its text), 0x1752 (its scroll bar), 0x2104 ($ca, its filter), 0x1dde ($152, medals) and 0x1b3e ($15a, rank insignia), 0x3976 ($10a, the Mission Map), 0x137a ($102, High Scores); ID05 0x3ba, 0x8b2 ($532); ID06 0x858 ($1b2). Overlay routines 0x4b0, 0xd23a and the carrier's collision hook 0x15134 (the deck as the ground) | done |
| 6. QuickDraw (ports, patterns and modes, lines, rects, round rects, ovals, regions as rects plus single-oval regions for clipping and PtInRgn, text from a glyph cache, CopyBits, pictures, colour icons), Window / Dialog / Control (scroll bars: NewControl, FindControl, TrackControl) / Menu managers, TextEdit, Standard File's Get File (File > Open…, over the scenery volume; the overlay reloads), palettes | done |
| 7. Event Manager from Godot input (mouse, Mac key codes and GetKeys, ticks), update and activate events | done |
| 8. Pilot roster, mission selection, the 3D flight view from the carrier's deck, the cockpit view (V) with its instrument panel, keyboard and mouse input, ejecting, and the mission summary (its text, scroll bar, medals and rank); sound (the VBL sound hook run every tick into SoundBase and played through `scenes/game/Game.tscn`'s Speaker; SndPlay of 'snd ' resources); saving (WriteResource / UpdateResFile kept under `user://resources`) | done |
| 9. `scenes/main/Main.tscn` runs the game (Godot quits cleanly with the program's thread parked); the MVP prototype (its scenes, `hellcats/` scripts, data, tests and fixtures) removed, the QA checks moved to the game runtime | done |
