# Mission block gates — implementation contract (+0xa8, +0xac, +0xb0)

**Source:** `Pacific Conflict.c` **FUN_000044e8** (5102–5105), **FUN_000044a4** (5083–5088); `STRUCTS.md` **DAT_0001b5a0**.

## Fields

| Offset | Role | **[RECONSTRUCTED]** use |
|--------|------|-------------------------|
| +0xac | short | If **== 0**, call **FUN_00005df8()** before phase gate (5102–5103). |
| +0xa8 | short | **FUN_000044e8** runs four entity passes only if **0 < value < 6** (5105). |
| +0xb0 | short | Used in **FUN_000044a4** after **FUN_0000435a**: toggles **entity+4** bit **0x40** vs entity **+8** / type **5** (5083–5088). |

**[UNKNOWN]** Full semantic names for all phase values.

## Godot MVP mapping

**[MVP APPROXIMATION]** `MissionController` exposes **`mission_phase_a8`** and **`mission_flag_ac`** for convergence and future **SimCore** wiring:

- **Running** training: **`mission_phase_a8 = 1`**, **`mission_flag_ac = 1`** so the **notional** sim gate **0 < phase < 6** holds and **ac ≠ 0** avoids the **FUN_00005df8**-only path in a bridged tick.
- **Terminal** (success/failure): **`mission_phase_a8 = 0`**, **`mission_flag_ac = 0`** — **arrays do not run** in a linked **SimCore** tick (same idea as “mission not in flying phase”).

**[INFERRED]** `+0xb0` is **not** mirrored in **MissionController** until HUD/map integration; document only.

## Related

- `hellcats/mission/mission_controller.gd` — `get_mission_sim_bridge_state()`
