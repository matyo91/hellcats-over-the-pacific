# Technical documentation

Use the narrowest reference that answers the task. Current counts are generated
by `python3 tools/progress_stats.py`; they are not copied into prose.

| Need | Authority |
|---|---|
| Current architecture and integration boundary | [`PROJECT_STATUS.md`](PROJECT_STATUS.md) |
| The game runtime around the strict port | [`GAME_RUNTIME.md`](GAME_RUNTIME.md) |
| Semantic reconstruction target and rules | [`DECOMPILATION_PROGRESS.md`](DECOMPILATION_PROGRESS.md) |
| Segment-qualified function registry | [`DECOMPILATION_INVENTORY.json`](DECOMPILATION_INVENTORY.json) through `tools/re_query.py` |
| Symbols, globals, layouts, and call corrections | [`DECOMPILATION_SYMBOLS.md`](DECOMPILATION_SYMBOLS.md) |
| Strict C-to-GDScript contract | [`STRICT_PORT_FOUNDATION.md`](STRICT_PORT_FOUNDATION.md) |
| Original subsystem navigation | [`SUBSYSTEM_MAP.md`](SUBSYSTEM_MAP.md) |
| Overlay object definitions (key -> handlers, from the bytes) | [`OVERLAY_DEFINITION_TABLE.md`](OVERLAY_DEFINITION_TABLE.md) |
| What the runtime has run, and what it has not (generated) | [`RUNTIME_COVERAGE.md`](RUNTIME_COVERAGE.md) |
| Prototype/import correspondence (historical) | [`IMPORT_STATUS.md`](IMPORT_STATUS.md) |
| Resource formats and retrieval | [`RESOURCE_ANALYSIS.md`](RESOURCE_ANALYSIS.md) through `tools/resedit.py` |
| Structures and loader mechanics | [`STRUCTS.md`](STRUCTS.md), [`LOADER_CHAIN.md`](LOADER_CHAIN.md) |
| Rendering, sound, HUD, mission, and controller findings | Topic-specific documents in this directory |
| Executable behavioral expectations | [`contracts/`](contracts/) and [`briefs/`](briefs/) |

Immutable Ghidra exports and original resource evidence remain under
`sources/resedit-1-0-3/`. Semantic `*.decomp.c` files retain source-local identifiers,
addresses, confidence, corrections, and unresolved facts. Superseded workflow
narratives and chronological logs are kept outside the repository archive and
are not active technical instructions.
