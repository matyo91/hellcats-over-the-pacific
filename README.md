# Hellcats Over the Pacific — evidence-backed Godot port

This repository preserves Macintosh evidence, semantic C reconstruction, and a
strict Godot translation track. It also contains a playable Mission 01 prototype
used as a comparison harness. The prototype is not the source of truth for
original behavior.

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
python3 tools/re_query.py tests test_flight_math --case _test_fun_0000e42a
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
sources/hellcats-over-the-pacific/  original disks, resource fork, manuals
sources/resedit-1-0-3/CODE/*.c            immutable Ghidra exports
sources/resedit-1-0-3/CODE/*.decomp.c     semantic reconstructions
sources/resedit-1-0-3/<TYPE>/<ID>.*       resource payload, JSON, local identity
godot/strict_port/                  faithful C-to-GDScript translations
godot/hellcats/                     playable prototype implementation
godot/tests/                        deterministic and scene tests
docs/                               live references and contracts
tools/                              retrieval, verification, extraction, QA
```

The critical correspondence is:

```text
immutable Ghidra .c -> semantic .decomp.c -> faithful strict-port .gd
```

Original function identities and source hashes live in
`godot/strict_port/mappings/functions.json`. Source-local provenance comments
remain valuable review evidence.

## Playable prototype

Open `godot/project.godot` in Godot 4.7 and run
`res://scenes/main/Main.tscn`. The prototype provides authored training
objectives, keyboard flight controls, HUD feedback, restart, and success/failure
flow. Its simplified flight model, world, and visuals are explicitly
approximations.

Controls: arrow keys or A/D for pitch/roll, Q/E for yaw, Page Up/Page Down or
W/S for throttle, R to restart, and Esc to quit.

## Validation

From the repository root:

```sh
python3 tools/qa/test_re.py
python3 tools/decomp/inventory_functions.py --check
python3 tools/progress_stats.py --check
python3 tools/resedit.py verify
python3 tools/strict_port/check_sync.py --json
python3 tools/qa/test_regression.py
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
