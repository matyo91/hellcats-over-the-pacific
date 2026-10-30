# QA

This folder contains Python-side deterministic guardrails that complement the
Godot-native runtime tests in `godot/tests`.

## Game smoke (manual, ~10 min)

Run after changes to the game runtime (`godot/hellcats/`, `godot/scenes/`).

- Open the `godot/` project directory and run `res://scenes/main/Main.tscn`.
- The menu bar appears; Return passes the copy protection; the Active Duty Roster
  and Select a Mission dialogs work with the mouse and keyboard.
- A mission starts on the carrier: V gives the cockpit and its instruments, `=`
  raises the throttle (the engine sounds), the mouse flies.
- J ejects: the mission summary scrolls its text, shows the rank and medals, and
  End Mission returns to the menus. Closing the window quits cleanly.

## Automated commands (CI / local)

```bash
# Godot headless suite (the strict port's routines, the ResEdit mirror)
HOME=/tmp/hellcats-godot-home /Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --script res://tests/run_all.gd

# Static checks (no engine)
python3 tools/qa/test_regression.py
python3 tools/hellcats/build_runtime_data.py --check
```

Keep `EXPECTED_RUNNER_PATHS` in `test_regression.py` aligned with
`godot/tests/run_all.gd` when adding tests.

## Scope split (no overlap)

- `godot/tests/run_all.gd`: runtime behaviour checks of the strict port.
- `tools/qa/test_regression.py`:
  - the runner's test list;
  - the proven loader targets against the game runtime's jump table;
  - the main scene runs the game (and the removed prototype stays removed);
  - byte checks, global alias docs, the ResEdit mirror.
