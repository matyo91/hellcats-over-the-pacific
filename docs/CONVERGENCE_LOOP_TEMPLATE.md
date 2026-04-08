# Convergence loop template (repeat per backlog item)

## Roles (conceptual)

1. **Reverse Engineer** — Extract from `Pacific Conflict.c` / briefs: pseudocode, constants, field usage, gates, **tags** `[RECONSTRUCTED]` / `[INFERRED]` / `[UNKNOWN]`.
2. **Godot Engineer** — Implement behind stable interfaces; one subsystem per pass.
3. **Gameplay Engineer** — Mission-1 playable; `[MVP TUNING]` only if needed.
4. **QA / Instrumentation** — Traces, tests, `godot/tests/run_all.gd`.
5. **Technical Writer** — `docs/NOTES.md`, `STRUCTS.md` / subsystem contract as needed.

## Inputs

- Backlog item + existing contracts (`docs/contracts/*_contract.md`).
- Current Godot modules touched by the item.

## Outputs

| Output | Requirement |
|--------|-------------|
| RE contract | Short `docs/contracts/<topic>_contract.md` or NOTES section |
| Code | Focused diff; no unrelated refactors |
| Traces | New or extended fields on existing trace hooks |
| Tests | At least one automated check where feasible |
| Playability | Mission-1 runs; no regression on objectives |

## Validation criteria

- `godot --headless --path . -s godot/tests/run_all.gd` passes (when Godot available).
- Manual: start Mission-1, complete or fail gracefully, restart.

## Stop / handoff

After N iterations, review backlog status and pick next item or supervised deep dive.
