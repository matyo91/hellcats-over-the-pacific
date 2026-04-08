# Hellcats Sim (Godot)

Minimal Godot project: **deterministic sim tick loop, no rendering**. Sim and presentation are separate; math is fixed-point/integer (68k-style). RNG matches ID05 LCG.

## Implemented / Proven / Blocked / Next

- **Implemented [RECONSTRUCTED]:** Tick loop (FUN_000044e8 order), four entity arrays, RNG (ID05 LCG), EntityState with proven offsets, `loader_metadata.gd` (JSON parser), SimCore bridge ingesting `tools/proven_loader_targets.json` and resolving targets.
- **Proven [RECONSTRUCTED]:** ID00→LoadSeg→segment-local chain; trailing u16 = entrypoint−4 or −6. Six targets byte-proven in `godot/docs/LOADER_CHAIN.md` §10 (ID02×1, ID05×1, ID06×3, ID07×1). Artifact `proven_loader_targets.json` currently lists two (ID02, ID05).
- **Blocked [UNKNOWN]:** Address mapping; runtime relocation; jump-table patching; segment load execution (see LOADER_CHAIN §9).
- **Next milestone:** Extend `proven_loader_targets.json` to the four remaining proven targets; then trace capture for parity validation.

## Repo tree

```
godot/
├── project.godot
├── README.md
└── hellcats/
    ├── core/
    │   ├── fixed.gd       # Fixed-point / 32-bit integer helpers
    │   ├── rng.gd         # LCG: seed = seed*0x41c64e6d + 0x3039; next_u16/next_u8
    │   ├── entity_state.gd   # EntityState (proven offsets, Dictionary)
    │   ├── loader_metadata.gd # Proven loader-target metadata parser
    │   └── sim_core.gd    # Tick loop, four entity arrays, FUN_000044e8 order
    └── tests/
        ├── test_rng.gd    # Headless entry + RNG test vectors
        └── test_sim_loader_bridge.gd # SimCore consumes proven loader-target metadata
```

## Run headless (no display)

From the **project root** (the folder containing `project.godot`):

```bash
godot --headless --script hellcats/tests/test_rng.gd
```

Or with a full path to the binary:

```bash
HOME="$PWD/.godot-home" /Applications/Godot.app/Contents/MacOS/Godot --headless --script hellcats/tests/test_rng.gd
```

Expected output:

```
PASS seed=0 next() (15-bit)
PASS seed=1 state
PASS next_u16 replay
PASS next_u8 replay
Result: ALL PASS
```

Exit code is 0 on success, 1 on failure.

Loader metadata fixture check:

```bash
HOME="$PWD/.godot-home" /Applications/Godot.app/Contents/MacOS/Godot --headless --script hellcats/tests/test_loader_metadata.gd
```

SimCore loader-metadata bridge check:

```bash
HOME="$PWD/.godot-home" /Applications/Godot.app/Contents/MacOS/Godot --headless --script hellcats/tests/test_sim_loader_bridge.gd
```

## Workspace-safe macOS runner

Under the current sandbox, the Godot app must write `user://` inside the workspace. Use:

```bash
sh ./tools/run_headless_rng_test.sh
```

## Adding per-frame trace logging

1. **In `SimCore`:** Add a trace buffer and optional callback.
   - In `sim_core.gd`, add e.g. `var _trace: Array[Dictionary] = []` and a flag `var trace_enabled: bool = false`.
   - At the start of `tick()`, push a frame record: `{"tick": _tick_count, "input": input_packet.duplicate()}`.
   - After each `_update_entity_array`, append to the frame record (e.g. `"array_1_len": entity_array_1.size()`).
   - Optionally call a callback: `if trace_callback.is_valid(): trace_callback.call(tick_record)`.

2. **From a test or runner script:** Enable tracing and consume it.
   - Set `sim.trace_enabled = true` (and/or `sim.trace_callback = callable(self, "_on_tick")`).
   - Run N ticks, then inspect `sim.get_trace()` (you’d add `get_trace()` returning a copy of `_trace`).
   - Log to file: `FileAccess.open("trace.json", FileAccess.WRITE).store_string(JSON.stringify(trace))`.

3. **Minimal in-place logging:** In `tick()`, add:
   - `if trace_enabled: print("tick ", _tick_count, " phase=", mission_phase_a8, " ac=", mission_flag_ac)`.
   - Or log only when a condition holds (e.g. `mission_phase_a8 == 2`).

Example stub in `sim_core.gd`:

```gdscript
var trace_enabled: bool = false
var _trace: Array = []

func tick() -> void:
	_tick_count += 1
	if trace_enabled:
		_trace.append({"tick": _tick_count, "phase": mission_phase_a8, "ac": mission_flag_ac})
	# ... rest of tick
```

Then from a test: `sim.trace_enabled = true; for i in 10: sim.tick(); print(sim.get_trace())`.

## Mission 01 MVP implementation notes

- **`docs/MISSION_01_MVP.md`** — scope, architecture, controls, objectives, data paths (`godot/data/mission_01/`), run/test commands, and deferred work.
- **Manual smoke + CI commands:** `tools/qa/README.md` (Mission 1 smoke, `run_all.gd`, `test_regression.py`).
