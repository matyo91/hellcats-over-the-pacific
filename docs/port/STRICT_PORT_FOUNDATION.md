# Strict port contract

The strict port is the GDScript translation of every decompiled function of Hellcats Over the
Pacific: the nine CODE segments of the application and the Pacific Conflict overlay. It is
translated from the semantic `*.decomp.c` files (`sources/resedit-1-0-3/CODE/`), which in turn
annotate Ghidra's exports of the original 1.0.3 binaries. The game runtime around it (the Mac
it runs on, its Toolbox, the loaders) is described in
[`../architecture/GAME_RUNTIME.md`](../architecture/GAME_RUNTIME.md); it is written for the port,
not translated, and is not evidence of original behaviour.

Current counts come from `python3 tools/progress_stats.py`; they are not copied here.

## Layout

```text
godot/strict_port/
  code/                one module per original segment (ID01.gd .. ID09.gd, pacific_conflict.gd)
  compat/              c68k.gd (C / 68000 integer semantics), memory_68k.gd (the address space)
  mappings/            functions.json (the provenance record), resources.json (the mirror)
  ui/                  decoders and views of the original resources
  <type>/              the resource mirror (see below)
godot/tests/strict_port/   deterministic cases replayed against the port
tools/strict_port/         case generators, the 68000 emulator, sync / callee / coverage checks
```

A segment's functions stay in one module: function ownership and shared state follow the
original's segments, not one file per function.

## Translation rules

1. Use the canonical function name of the current `.decomp.c`; its `FUN_*` identity is kept as
   `original_function` in the mapping.
2. Preserve `param_*` and decompiler locals, global `DAT_*` names, function boundaries, statement
   order, branches, constants, indexing and casts.
3. Add a name only through the decompilation rename process. A Godot-only helper never stands in
   for an original function.
4. Record each mapping once, in `mappings/functions.json`. Comments explain; they are not a second
   provenance record.
5. Unknown or unresolved behaviour is `BLOCKED`; it is never approximated inside the strict layer.

## Port conventions

**Memory.** Every module works on one `Memory68k`: a flat, bounds-checked, big-endian address
space. Globals keep their original addresses: an ID segment names them as A5 offsets
(`const A5_CTYPE_TABLE: int = -0x1608`, read as `a5 + offset`), the overlay as `DAT_` constants
holding its runtime address, which is the file offset - 0x20. No global becomes a node field or
an autoload.

**Integer semantics.** `C68kScript` (`compat/c68k.gd`) gives the widths (`u8` .. `s32`), the
68000 shifts (`asr32`, `lsl32`), wrapping, and division truncated toward zero (`divs_trunc`). A
width conversion sits at every translation boundary the C implies.

**Stack frames.** A module's `a7` is the stack pointer at entry of the routine being run, and
`a6 = a7 - 4` its frame. Locals the original keeps in its frame (buffers, VAR results, structs
passed by address) live at their original `-n(a6)` offsets, and a routine that needs them asserts
`a7 != 0`. Before calling a routine that uses a frame, a caller lowers `a7` past its own frame,
the arguments and the return address (`a7 = entry - frame - args - 4`), and restores it after.
Saved registers are not modelled where no result reads them.

**Calls.** A module reaches other code only through its original paths:

| Helper | Original | Resolved by |
|---|---|---|
| `_jt(offset, args)` | a jump-table slot, `JSR offset(A5)` | the runtime's segment loader (`jump_table.json`) |
| `_local(offset, args)` | a routine of the same segment by its offset | `segment_methods.json` |
| `_jsr(address, args)` / `_bsr_unported(file_offset, args)` | an overlay code address | the overlay's `code_table` (`overlay_methods.json`) |
| `_trap(word, args)` | an A-line trap | the runtime's Toolbox |
| `_call_address(address, args)` | a pointer held in memory | the runtime's code routines |

Arguments go in stack order, last pushed first, which for a C call is the callee's parameter
order. A C call may pass more arguments than the callee declares (the caller pops them; the
callee reads what its path needs): the runtime drops the extra ones. A Pascal callee pops its
own, so a count mismatch there is a wiring error. An address with a lone `rts` (`RTS_ONLY`)
returns D0 unchanged.

**Pointers.** An argument the original passes by address is passed as that address, in the
frame or the heap, never as a copy of its contents. The one exception is a rect passed by value
in the argument area (`&bounds` in two port-creation routines): the port keeps arguments in
variables, so it passes the rect's two longs, and says so at the call.

## Verification

Each check is independent; QA (`python3 tools/qa/test_regression.py`) runs them all.

- **Sync** (`tools/strict_port/check_sync.py --json`): every mapping's target exists, its
  deterministic test exists, and the hash of its complete C definition matches the one reviewed;
  a changed definition is `SOURCE_CHANGED`. The checker never edits the manifest.
- **Calls** (`tools/strict_port/check_callees.py`): every mapped function a semantic C body calls
  is reached by the port (by name, slot, segment offset or overlay address, directly or through
  the file's private helpers), and the port calls no mapped function its C bodies do not. C calls
  by Ghidra name are resolved by address. A callee reached through a computed address is listed in
  `ALLOWED`, a call Ghidra left as a label in `EXTRA_ALLOWED`, each with its evidence.
- **Behaviour** (`godot/tests/strict_port/`): the generators in `tools/strict_port/gen_*_cases.py`
  (sharing the overlay's layout and helpers through `cases.py`; a segment family's layout stays in
  its first generator) run the original 68000 code in `m68k_emu.py` and record, per case, every memory change and every
  call it makes; `helpers/segment_cases.gd` (a segment) and `helpers/original_cases.gd` (the
  overlay) replay the case against the port and compare them exactly. `test_replays.gd` replays
  every fixture that needs nothing more; a fixture listed there is its functions'
  `deterministic_test`, and a test file only where a test checks more than a replay. The stack region is left out of the comparison. A call's arguments are logged by
  value, or through the pointer (a long count, or `pstr` for a Pascal string) where the fixture's
  call log says so.
- **Runtime** ([`../generated/RUNTIME_COVERAGE.md`](../generated/RUNTIME_COVERAGE.md)): which
  functions the runtime's sessions have run, and why each other one has not.

Adding or changing a port is a review operation: translate the current source, add evidence
cases, record the reviewed hash in the mapping, then run the checks and the tests.

## Resource mirror

`godot/strict_port/` mirrors `sources/resedit-1-0-3/` type by type (each folder named after its
source folder in lower case: `ALRT` -> `alrt`, `ICN#` -> `icn#`), because Godot loads only files
inside its project. Each resource keeps its original payload (`<id>.bin`, byte-identical), the
media already derived next to it (PICT and ICON PNGs, `snds` MP3s), and one scene that draws it.
CODE is not mirrored; its port is `code/`. `tools/strict_port/import_resedit.py` writes the mirror
and `resources/resources.json` (every file with its source and SHA-256); its `--check`, run by QA,
fails on any missing, changed or extra file.

The scenes hold no decoded data: the views in `ui/` decode the `.bin` at run time, as ResEdit's
editors show it. Dialogs, alerts and item lists (`dialog_templates.gd`, `dialog_view.gd`) are
drawn with the System 7 modal frame. Icons and colour tables (`resource_images.gd`, `icon_view.gd`)
use the system's default colour tables or a `cicn`'s own. Controls, the Finder bundle, menus and
strings have their own views (`control_view.gd`, `finder_view.gd`, `menu_view.gd`, `text_view.gd`).
Sounds play from their own samples (`resource_sound.gd`, `sound_view.gd`), and the application's
data types are shown in hex. The fork holds no FONT or NFNT, so every view uses the nearest
installed face for the system font. The tests `test_resedit_dialogs.gd`, `test_resedit_interface.gd`,
`test_resedit_text.gd` and `test_resedit_media.gd` check the decoders and every scene against the
resource evidence.
