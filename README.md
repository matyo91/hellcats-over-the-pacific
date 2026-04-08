# Hellcats Sim (Godot)

Current status: a deterministic reverse-engineering core plus a **playable Mission 01 MVP vertical slice**. The project now includes a simple 3D training mission with authored mission data, placeholder world rendering, keyboard flight controls, mission objectives, HUD feedback, and success/failure flow.

## Implemented / Proven / Blocked / Next

- **Implemented [RECONSTRUCTED]:** Tick loop (FUN_000044e8 order), four entity arrays, RNG (ID05 LCG), EntityState with proven offsets, `loader_metadata.gd` (JSON parser), SimCore bridge ingesting `tools/proven_loader_targets.json` and resolving targets.
- **Implemented [MVP AUTHORING DECISION]:** Mission 01 vertical slice scaffold under `godot/scenes/` with `Mission01Training.tscn`, `Main.tscn`, `PlayerAircraft.tscn`, `HUD_MVP.tscn`, `Mission01World.tscn`, authored mission JSON, simplified flight model, mission controller, checkpoint manager, and mission HUD.
- **Proven [RECONSTRUCTED]:** ID00→LoadSeg→segment-local chain; trailing u16 = entrypoint−4 or −6. Six targets byte-proven in `godot/docs/LOADER_CHAIN.md` §10 (ID02×1, ID05×1, ID06×3, ID07×1). Artifact `proven_loader_targets.json` currently lists two (ID02, ID05).
- **Blocked [UNKNOWN]:** Address mapping; runtime relocation; jump-table patching; segment load execution (see LOADER_CHAIN §9); higher-fidelity mission scripting and full combat systems.
- **Next milestone:** tighten the Mission 01 playable slice with better camera/collision tuning and then start replacing the authored flight/mission behavior with more exact RE-backed behavior incrementally.

## Repo tree (high level)

```
project.godot              # default main scene → godot/scenes/main/Main.tscn
godot/
├── scenes/                # Main, Mission01Training, world, player, HUD, checkpoint
├── data/mission_01/       # mission_01_training.json, aircraft_mvp.json, checkpoints
└── tests/                 # headless runner: run_all.gd
hellcats/
├── core/                  # sim, RNG, loader metadata (deterministic RE core)
├── flight/                # MVP flight model + input map
├── mission/               # controller, objectives, checkpoints
├── player/                # PlayerAircraft
├── ui/                    # HUD_MVP
└── world/                 # world_builder_mvp
tools/qa/                  # test_regression.py + smoke notes
```

## Run the Mission 01 MVP

Open the project in Godot from the repo root (the folder containing `project.godot`) and run the default main scene:

- `res://godot/scenes/main/Main.tscn`

Direct mission scene for iteration:

- `res://godot/scenes/missions/Mission01Training.tscn`

Controls:

- `Up / Down`: pitch up / down
- `Left / Right` or `A / D`: roll left / right
- `Q / E`: yaw left / right
- `Page Up / Page Down` or `W / S`: throttle up / down
- `R`: restart mission
- `Esc`: quit

Mission HUD shows:

- current objective
- speed
- altitude
- heading
- throttle
- mission status

## Run headless (no display)

From the **project root** (the folder containing `project.godot`):

```bash
HOME=/tmp/hellcats-godot-home /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://godot/tests/run_all.gd
```

Python-side regression checks:

```bash
python3 tools/qa/test_regression.py
```

## Mission 01 MVP implementation notes

- `docs/MISSION_01_MVP.md` — scope, architecture, controls, objectives, data paths, and deferred work.
- `tools/qa/README.md` — manual smoke path and automated commands.
