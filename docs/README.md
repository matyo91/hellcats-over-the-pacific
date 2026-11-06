# Technical documentation

Use the narrowest reference that answers the task. Counts are generated (`python3
tools/progress_stats.py`, [`generated/`](generated/)) and never copied into prose. Each fact has
one home; other places link to it.

| Folder | Holds |
|---|---|
| [`architecture/`](architecture/) | How the pieces fit: status, the runtime, the original's subsystems and loader |
| [`port/`](port/) | The rules: the strict port contract and the reconstruction checkpoint |
| [`reference/`](reference/) | Lookup tables: symbols and corrections, structures, overlay tables, resources |
| [`topics/`](topics/) | One subsystem each, as the original does it |
| [`generated/`](generated/) | Written by tools; do not edit by hand |
| [`history/`](history/) | Superseded pages (the removed MVP prototype); not current instructions |

| Need | Document |
|---|---|
| Current state and integration boundary | [`architecture/PROJECT_STATUS.md`](architecture/PROJECT_STATUS.md) |
| The game runtime around the strict port | [`architecture/GAME_RUNTIME.md`](architecture/GAME_RUNTIME.md) |
| The original's subsystems, and its segment loader | [`architecture/SUBSYSTEM_MAP.md`](architecture/SUBSYSTEM_MAP.md), [`architecture/LOADER_CHAIN.md`](architecture/LOADER_CHAIN.md) |
| How C becomes GDScript, and how it is verified | [`port/STRICT_PORT_FOUNDATION.md`](port/STRICT_PORT_FOUNDATION.md) |
| Semantic reconstruction rules | [`port/DECOMPILATION_PROGRESS.md`](port/DECOMPILATION_PROGRESS.md) |
| The function registry | [`DECOMPILATION_INVENTORY.json`](DECOMPILATION_INVENTORY.json), through `tools/re_query.py` |
| Symbols, globals and call corrections | [`reference/DECOMPILATION_SYMBOLS.md`](reference/DECOMPILATION_SYMBOLS.md) |
| Structure layouts | [`reference/STRUCTS.md`](reference/STRUCTS.md) |
| The overlay's definition and service tables | [`reference/OVERLAY_DEFINITION_TABLE.md`](reference/OVERLAY_DEFINITION_TABLE.md), [`reference/OVERLAY_SERVICE_TABLE.md`](reference/OVERLAY_SERVICE_TABLE.md) |
| Resource formats and retrieval | [`reference/RESOURCE_ANALYSIS.md`](reference/RESOURCE_ANALYSIS.md), through `tools/resedit.py` |
| Rendering | [`topics/OVERLAY_RENDERER.md`](topics/OVERLAY_RENDERER.md), [`topics/RASTERIZER.md`](topics/RASTERIZER.md) |
| Cockpit, sound, ships, pilots | [`topics/INSTRUMENT_PANEL.md`](topics/INSTRUMENT_PANEL.md), [`topics/SOUND_SYSTEM.md`](topics/SOUND_SYSTEM.md), [`topics/SHIP_CONTROLLERS.md`](topics/SHIP_CONTROLLERS.md), [`topics/PILOT_ROSTER.md`](topics/PILOT_ROSTER.md) |
| Copy protection, ID09 glue | [`topics/COPY_PROTECTION_FLOW.md`](topics/COPY_PROTECTION_FLOW.md), [`topics/ID09_GLUE.md`](topics/ID09_GLUE.md) |
| Where mission, world and cockpit data live | [`topics/DATA_LOCATIONS.md`](topics/DATA_LOCATIONS.md) |
| What the runtime has run, and why the rest has not | [`generated/RUNTIME_COVERAGE.md`](generated/RUNTIME_COVERAGE.md) |

Immutable evidence stays outside this folder: the Ghidra exports and original resources under
`sources/resedit-1-0-3/`, whose checksums are
[`DECOMPILATION_PROTECTED_CHECKSUMS.sha256`](DECOMPILATION_PROTECTED_CHECKSUMS.sha256). The
semantic `*.decomp.c` files carry each function's addresses, confidence, corrections and open
questions.
