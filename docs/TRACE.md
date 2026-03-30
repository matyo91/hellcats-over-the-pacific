# Trace format (deterministic replay / parity validation)

**[INFERRED]** Trace format is defined for parity validation: same seed + same inputs ⇒ identical trace. **[RECONSTRUCTED]** Field names and offsets match STRUCTS.md and Pacific Conflict.c (mission_phase_a8, mission_flag_ac, entity offsets). **[UNKNOWN]** Trace captures SimCore state only; segment execution and loader runtime are out of scope (see [LOADER_CHAIN.md](LOADER_CHAIN.md) §9).

One JSON object per line (JSONL). Each line is the **state after** that frame’s tick. All numbers are integers; use decimal in JSON.

## Per-line schema

| Field | Type | Description |
|-------|------|-------------|
| `frame` | int | Frame index (1-based; matches tick count). |
| `input` | object | Input packet used for this frame. Keys: action names (e.g. `"key_32"`). Values: int (e.g. 0 = release, 3 = press). |
| `rng_state` | int | RNG state (32-bit) **after** this tick. Next frame’s first RNG call uses this. |
| `mission_phase_a8` | int | `mission_phase_a8` after tick (proven: DAT_0001b5a0+0xa8). |
| `mission_flag_ac` | int | `mission_flag_ac` after tick (proven: DAT_0001b5a0+0xac). |
| `player` | object or null | Player entity critical fields **after** tick (proven offsets only). Null if no player entity. |

## `player` object (proven offsets only)

Keys are the EntityState offset names; values are int (32-bit, decimal in JSON). Omit keys that are zero to keep traces small; diff treats missing key as 0.

Proven keys (from Pacific Conflict / FUN_0000e792, FUN_000041ec):

- `field_00`, `field_04`, `entity_data_ptr`, `position_velocity_c`, `ptr_10`, `ptr_14`
- `pos_18`, `pos_1c`, `pos_20`, `pos_2e`, `state_32`, `count_3a`, `ptr_48`, `index_50`
- `movement_61a`, `movement_61e`, `movement_662`, `movement_666`, `movement_669`, `movement_66a`, `movement_66e`, `movement_672`
- `weapon_count_67c`, `weapon_count_67d`, `weapon_count_67e`, `direction_char_679`, `flags_685`
- `status_1a0`, `status_1a1`, `status_1a3`

## Example (one line, pretty-printed)

```json
{"frame": 1, "input": {"key_32": 3}, "rng_state": 1103725460, "mission_phase_a8": 1, "mission_flag_ac": 0, "player": {"pos_2e": 0, "weapon_count_67d": 5}}
```

## Replay semantics

- **Initial RNG seed** is not stored in the trace; it is a run parameter (e.g. first run: seed 12345; replay: seed 12345).
- **Input** for frame N is the input **consumed during** tick N. Replay: before tick N, set `sim.input_packet` from `input`, then `sim.tick()`.
- **Acceptance criterion:** Same initial seed + same sequence of input packets (from a replay file) ⇒ identical trace (same JSONL lines).

## File layout

- **Trace file:** JSONL, one record per frame; written by `TraceWriter` (e.g. `run.jsonl`).
- **Replay input file:** JSON array of per-frame input packets, e.g. `[{"key_32": 3}, {}, {"key_32": 0}]`. Frame index is array index (0-based); frame 1 uses index 0. Loaded by `ReplayRunner`.

## Acceptance criteria

- **Same seed + same inputs ⇒ identical trace.** For a given initial RNG seed and a given sequence of input packets (one per frame), the sim must produce the same trace (same `frame`, `rng_state`, `mission_phase_a8`, `mission_flag_ac`, `player` and `input` per line). Validation is done by comparing two JSONL trace files with `tools/trace_diff.py`; the tool reports the first frame and field(s) where they differ, or exits 0 if traces match.
