# Hellcats Over the Pacific — evidence-backed Godot port

This repository ports *Hellcats Over the Pacific* (Graphic Simulations / Parsoft,
1991, Macintosh) to Godot 4.7 from the original program itself. It preserves
the Macintosh evidence, a readable semantic reconstruction of the decompiled
code, a strict GDScript translation of every function, and a runtime that runs
that translation as the original game from Godot's main scene.
[How the port was made](#how-hellcats-was-ported-to-godot) explains the
pipeline.

## Start here

Read only the material needed for the task:

| Need | Canonical entry point |
|---|---|
| Current state and next milestone | [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) |
| Reconstruction checkpoint | [`docs/DECOMPILATION_PROGRESS.md`](docs/DECOMPILATION_PROGRESS.md) |
| Semantic names, globals, fields | [`docs/DECOMPILATION_SYMBOLS.md`](docs/DECOMPILATION_SYMBOLS.md) via `tools/re_query.py symbol` |
| Strict translation rules and coverage | [`docs/STRICT_PORT_FOUNDATION.md`](docs/STRICT_PORT_FOUNDATION.md) |
| Resource corpus | [`docs/RESOURCE_ANALYSIS.md`](docs/RESOURCE_ANALYSIS.md) via `tools/resedit.py` |
| System navigation | [`docs/SUBSYSTEM_MAP.md`](docs/SUBSYSTEM_MAP.md) |
| Documentation index | [`docs/README.md`](docs/README.md) |

Do not begin a focused task by loading all documentation or a whole CODE file.
Use deterministic narrow retrieval:

```sh
python3 tools/re_query.py function --segment "Pacific Conflict" FUN_0000e792
python3 tools/re_query.py excerpt --segment "Pacific Conflict" FUN_0000e792 --address 0xf47c
python3 tools/re_query.py callers --segment "Pacific Conflict" FUN_0000e792
python3 tools/re_query.py callees --segment "Pacific Conflict" FUN_0000e792
python3 tools/re_query.py globals --segment "Pacific Conflict" FUN_0000e792 --access reads
python3 tools/re_query.py tests test_effect_init --case run
python3 tools/re_query.py symbol DAT_00026004
python3 tools/re_query.py source-map FUN_0001358c

python3 tools/resedit.py inspect DITL 137
python3 tools/resedit.py item DITL 137 5
python3 tools/resedit.py references ALRT 259
python3 tools/resedit.py raw DITL 137 --offset 0 --length 32
python3 tools/resedit.py search "Mission Navigation"
python3 tools/progress_stats.py
```

## Evidence and code layout

```text
sources/hellcats-over-the-pacific.zip     original disks, resource fork, manuals
sources/resedit-1-0-3/CODE/*.c            immutable Ghidra exports
sources/resedit-1-0-3/CODE/*.decomp.c     semantic reconstructions
sources/resedit-1-0-3/<TYPE>/<ID>.*       resource payload, JSON, local identity
sources/screenshots/, sources/videos/     reference captures of the original
godot/strict_port/code/                   faithful C-to-GDScript translations
godot/strict_port/compat/                 68k arithmetic and memory helpers
godot/strict_port/<type>/                 the resource fork, mirrored
godot/hellcats/runtime/, toolbox/         the emulated Macintosh around the port
godot/scenes/main/, scenes/game/          the main scene, screen and speaker
godot/tests/                              deterministic tests
docs/                                     live references and contracts
tools/                                    retrieval, verification, extraction, QA
```

The critical correspondence is:

```text
immutable Ghidra .c -> semantic .decomp.c -> faithful strict-port .gd
```

Original function identities and source hashes live in
`godot/strict_port/mappings/functions.json`. Source-local provenance comments
remain valuable review evidence.

## Running the game

Open `godot/project.godot` in Godot 4.7 and run `res://scenes/main/Main.tscn`:
it runs the original program from the strict port on an emulated Macintosh
(Toolbox, screen, sound, input), as [`docs/GAME_RUNTIME.md`](docs/GAME_RUNTIME.md)
describes. The mouse is the joystick; the keys are the original's (V cockpit,
C chase, T tower, F flaps, G gear, J eject, P pause, `=` / `-` throttle, ⌘Q quit).
Pilots and settings the game saves go to Godot's `user://resources`.

## How Hellcats was ported to Godot

The port moves the original program through four stages, each kept beside the
one before so any line of GDScript can be traced back to the bytes it came from:

```text
resource fork -> Ghidra .c -> semantic .decomp.c -> strict-port .gd -> runtime + scenes
 (ResEdit)        (immutable)   (readable)           (exact mapping)   (mapped around)
```

### 1. The resources, extracted

Every resource of the application's resource fork was extracted with ResEdit
into `sources/resedit-1-0-3/<TYPE>/<ID>.*` (dialogs, alerts, menus, pictures,
icons, sounds, strings, the settings and pilot records), including the `CODE`
resources. Each of the eleven code segments (`ID00`..`ID09` and the *Pacific
Conflict* scenery overlay) was decompiled by Ghidra into
`sources/resedit-1-0-3/CODE/*.c`. Those exports are evidence: they are never
edited, and their checksums are protected.

### 2. A readable decompilation

Ghidra's output is correct but unreadable (`FUN_0000e792`, `DAT_0001b738`,
`local_14`). With Claude Code, each `.c` file was rewritten into its
`.decomp.c` twin in two passes:

- **Functions:** every function's purpose was reconstructed from its body, its
  callers and the resources it touches, and it was given a semantic name
  (`FUN_0000e792` becomes `update_aircraft_entity`), with the original identity
  kept beside it.
- **Variables:** the same pass over every parameter, local, global and record
  field, so a routine reads as what it does.

Function boundaries, data widths, fixed-point arithmetic and addresses are
preserved, and anything not yet understood stays annotated as such. The
registry (`tools/decomp/inventory_functions.py`, `docs/DECOMPILATION_SYMBOLS.md`)
holds all 740 functions with their status and evidence.

### 3. The strict port

Each `.decomp.c` function was then translated one to one into GDScript under
`godot/strict_port/code/`: same function, same order of operations, same
widths, signedness, overflow and fixed-point behaviour. The 68000's arithmetic
is reproduced by `compat/c68k.gd` (16- and 32-bit wraps, `DIVS` / `MULS`,
shifts, rotates) and its flat memory by `compat/memory_68k.gd`, so the
translated code reads and writes the original data structures at their
original offsets. The resource fork is mirrored byte for byte into
`godot/strict_port/<type>/`, with Godot scenes to view it.

Every function's chain (`.c` -> `.decomp.c` -> `.gd`) is recorded in
`godot/strict_port/mappings/functions.json`. Its behaviour is checked against
the original machine code: `tools/m68k_emu.py` runs the original bytes on a
68000 emulator, `tools/strict_port/gen_*_cases.py` record what they do (memory,
results, the calls they make out of their segment), and
`godot/tests/strict_port/` replays the same cases on the port.

### 4. The runtime, mapped around the port

The strict port is not touched to make it run. Instead it is *mapped around*:
`godot/hellcats/` builds the Macintosh the program expects, so the original
`main()` runs as it did in 1991.

- **`runtime/`:** one 24-bit address space laid out as the original expects
  (low memory, the A5 world from `DATA` / `ZERO` / `DREL`, the stack, the
  heap, the sound buffer, an 8-bit screen); the segment loader that links the
  jump table to the ported routines; the overlay loader that reads and
  relocates *Pacific Conflict* as the original loader does; the program's
  thread.
- **`toolbox/`:** the parts of the Mac Toolbox the program calls through its
  traps, written for Godot: the Memory, Resource, File, Event, Window, Dialog,
  Control and Menu Managers, Color QuickDraw (ports, patterns, regions, text,
  CopyBits, pictures, colour icons), the Palette Manager, TextEdit, Standard
  File and the Sound Manager.
- **Scenes:** `scenes/main/Main.tscn` runs `scenes/game/Game.tscn`, whose
  screen shows the Mac's frame buffer through its colour table, whose speaker
  plays the sound buffer the program mixes every tick, and which hands Godot's
  mouse and keys to the program as Mac events.

Ghidra never defined 35 small routines (a few dialog procedures, the mission
summary's text and map, the carrier deck's collision, C library and Toolbox
glue). Those are written from their disassembly, mostly in
`runtime/unexported.gd`, each citing its address; the
[index in GAME_RUNTIME.md](docs/GAME_RUNTIME.md#routines-outside-the-740)
lists them with where the port reaches them.

The result is the original game, flight model, renderer, missions, dialogs and
sound, running in Godot from a strict GDScript version of all 740 decompiled
functions. When playing turns up a gap, the fix goes back up the chain to the
stage the evidence points at (the decompilation, the strict port and its tests,
or the runtime), so each stage stays the source for the next.

### Next steps

1. **Clean up** the code and the documentation that grew during the port.
2. **Go native.** Remove the virtual machine around the port, the 68k memory
   and arithmetic helpers, the runtime and the Toolbox, so the game's own logic
   runs directly on Godot objects: a complete native Hellcats for Godot.
3. **Use Godot itself.** Much of the game re-implements what Godot provides:
   vector and matrix arithmetic, the camera and its projection, rotations, the
   polygon renderer, and the dialog system. Each can become the Godot-native
   equivalent (`Vector3`, `Basis`, `Camera3D`, meshes, `Control` nodes) once
   its behaviour is pinned by the tests the strict port already has.

## Validation

From the repository root:

```sh
python3 tools/qa/test_re.py
python3 tools/decomp/inventory_functions.py --check
python3 tools/progress_stats.py --check
python3 tools/resedit.py verify
python3 tools/strict_port/check_sync.py --json
python3 tools/qa/test_regression.py
python3 tools/hellcats/gen_runtime_cases.py --check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot \
  --log-file /tmp/hellcats-godot.log --script res://tests/run_all.gd
git diff --check
```

Verify protected Ghidra exports from their directory because the checksum
manifest uses local paths:

```sh
cd sources/resedit-1-0-3/CODE
shasum -a 256 -c ../../../docs/DECOMPILATION_PROTECTED_CHECKSUMS.sha256
```

Passing automated tests establishes only their documented scope. It does not by
itself prove visual parity, full flight parity, or agreement with an observed
original Macintosh runtime.
