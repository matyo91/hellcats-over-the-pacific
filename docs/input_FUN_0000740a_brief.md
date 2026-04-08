# FUN_0000740a — input handler extraction brief

Every statement is tagged: **[RECONSTRUCTED]** (from decompiler/binary), **[INFERRED]** (reasoning from evidence), **[UNKNOWN]** (unverified or missing).

**Source:** `Hellcats-Over-the-Pacific_Mac_EN/ResEdit/CODE/Pacific Conflict.c`, `FUN_0000740a`, lines 7368–8167.

---

## Overview

**[RECONSTRUCTED]** `uint FUN_0000740a(int param_1, int param_2)` is the central **keyboard/mouse-style input dispatcher**. It receives a **virtual key code** `param_1` and an **action code** `param_2`, mutates **global UI/flight/mission state**, then runs **post-input hooks** (camera follow, HUD bits, mode-specific updates) and returns a **uint mask** `uVar6` consumed by downstream logic (bit tests against `FUN_00000354()` output, OR-ing flags such as `1`, `2`, `6`, `8`, `9`, `0x10a`, `0x201`, etc.).

**[INFERRED]** This is **not** analog stick samples: it is **discrete key events** plus **accumulators** (`DAT_00024cf6`, mouse deltas, angular inputs) updated inside the same function and in helper paths.

**[INFERRED]** `param_2 == 3` is the dominant **“key went down / active edge”** branch; `param_2 == 4` appears in a **guard** together with **Space (0x20)** and several letters—**[UNKNOWN]** exact Toolbox meaning of `3` vs `4` beyond “not the same class of event as 3”.

---

## Pseudocode (structure)

**[RECONSTRUCTED]**

```
fun_0740a(key_code param_1, action param_2) -> uint uVar6
  save initial DAT_0001d858 as sVar4

  // Overlay / “loading” gate (DAT_0001b870, DAT_0001b86e)
  if DAT_0001b870 != 0:
    if DAT_0001b86e == 0:
      DAT_0001b870 = 0
      // fall through
    else if DAT_0001b870 == 1:
      DAT_0001b870 = 2

  if DAT_0001b870 == 0:
    if DAT_0001d858 == 8:
      if DAT_0001b87c == 0:
        DAT_0001d858 = 1
        if (player_entity_byte_at(+7) & 0x40) == 0:
          OR player dword at +4 with 0x40
          FUN_000137da(player)
      else:
        DAT_0001d858 = 9
      FUN_00006ed6()
      DAT_0001b884 = 0

  // Mission callback when *(mission+0x98) != 0
  if *(short*)(mission+0x98) != 0:
    if *(short*)(mission+0x98) == 2 && DAT_0001b870 == 0:
      if *(int*)(mission+0x25e) != 0 && mission_callback_at(+0x2b6)(0) != 0:
        mission_callback_at(+0x2be)(0)
      FUN_00006ed6()
      DAT_0001d858 = 8
      DAT_0001b870 = 3
      DAT_0001b86e = 0x1e
      // snap camera anchor: FUN_0000253e / FUN_000028dc; deltas -0x2ee, 0x183, -0x513
      DAT_0001d838/d834/d830 = player position + those deltas

    if DAT_0001b86c == 0 && DAT_0001b86e == 0:
      FUN_00008784( (char)(player+0x63e) == 0 )

  if DAT_0001b86c != 0 && DAT_0001b86e == 0:
    FUN_00008ff4()

  // Early exits / special states
  if DAT_0001d858 == 7 && (DAT_0001b888 == NULL || (player+0x63e) != 0):
    goto camera_reset_case_V  // switchD_00007684_caseD_56

  if DAT_0001d858 == 8 || DAT_0001d858 == 9:
    if param_2 == 3 && (param_1 in {0x22, 0x60, 0x1b}):
      uVar6 = 3
      goto merge_return_path  // switchD_0000833a_caseD_3
    goto after_key_switch

  // Skip main key switch unless param_2 is “allowed” for this huge exclusion list
  if param_2 != 3 && NOT( (param_2==4 && param_1==0x20) && ... long list ... ):
    goto case_default_tail

  switch (param_1):
    // many cases — see Constants table

  case_default_tail:
    // DAT_00024cf6: FUN_00002e08, clamp char at player+0x19a, shift DAT_00024cf6

  // Mouse position sync vs mission +0x33e/+0x340, optional slew limits

  // FUN_00008000:
  FUN_0000923e()
  if DAT_0001b870 == 3: FUN_000094d2() else FUN_000092e4()
  FUN_000096f4()

  // If not (DAT_0001d858 > 7 || player+0x62a != 0 || (player+0x63e)==0):
  //   uVar6 = FUN_00000354(); RNG-heavy updates to *(mission+0xd4), etc.

  uVar6 = 0  // LAB_00008324
  switch (DAT_0001d858):
    1,2: FUN_0000739a(); transition 1<->2 using DAT_00024cf8 / DAT_00024cfc vs DAT_0001d804 / DAT_0001d800
    5: camera from player table slot
    6: chase math (FUN_00003b98, FUN_0000e372, FUN_00001f22, …)
    7: camera locked to DAT_0001b888
    8: uVar7 = FUN_00008c30()
    9: uVar7 = FUN_00008972(); maybe uVar6 = uVar7

  merge_return_path:
    // If DAT_0001d810 in (0x1000,0x3000), snap pitch band
    if uVar6 != 0:
      clear (player+0x641), _DAT_0001b872, DAT_00024cf6
    if DAT_0001d858 != sVar4:
      _DAT_0001d856 = 1
    return uVar6
```

**[RECONSTRUCTED]** The **key switch** is `switch(param_1)` at line 7470; the **mode switch** is `switch(DAT_0001d858)` at line 8022.

---

## Constants (key codes and magic numbers)

| Value | ASCII / note | Role |
|--------|----------------|------|
| `param_2 == 3` | — | **[RECONSTRUCTED]** Primary **press/active** path for most keys. |
| `param_2 == 4` | — | **[RECONSTRUCTED]** Used only in a **negated** guard with **Space `0x20`** and many **letter** codes. **[UNKNOWN]** exact OS mapping. |
| `0x1b` | ESC | **[RECONSTRUCTED]** Grouped with `` ` `` (`0x60`) and `"` (`0x22`) for **state 8/9** shortcut → `uVar6 = 3`. |
| `0x20` | Space | **[RECONSTRUCTED]** Branches on `_DAT_0001b874`, `(player+0x63e)`, `_DAT_00024d34`: sets `_DAT_00024cf4` or `(player+0x641)` from press vs release. |
| `0x2b`, `0x3d` | `+`, `=` | **[RECONSTRUCTED]** Either **mode 6** waypoint stack push **or** (if `DAT_0001d858 < 6`) `DAT_00024cf6 = 1` on press, `0` on release. |
| `0x2d`, `0x5f` | `-`, `_` | **[RECONSTRUCTED]** Mode-6 pop **or** `DAT_00024cf6 = -1` / `0` with same gating as `+`. |
| `0x30`–`0x39` | `0`–`9` | **[RECONSTRUCTED]** Mixed: several cases gated on `*(player+0x32) == 0xf7f0` vs not; digit keys write `(char)(param_1 - 0x30)` to `(player+0x19a)` and clear bit `0x4000` of `(player+0x1a1)` in one path. |
| `0x43` / `99` | `C` / `c` | **[RECONSTRUCTED]** If already state `5`, jump to **V** reset; else `DAT_0001d858 = 5` and toggle entity flag `+4` bit `0x40` / `FUN_000137da` / `FUN_00006ed6`. |
| `0x45`/`0x65`, `0x56`/`0x76` | `E`/`e`, `V`/`v` | **[RECONSTRUCTED]** `E`: if secondary exists and not state `7` and `(player+0x63e)==0` → state `7` + same as `C` branch. `V`: **reset** state `1`, zero several `DAT_00024*` angles, **recenter** `DAT_0001d838/834/830` from player position, set flag `0x40` on entity, `FUN_000137da`, `FUN_00006ed6`. |
| `0x1c`/`0x1d` | FS chars | **[RECONSTRUCTED]** If `DAT_0001d858 < 3`: adjust `DAT_00024cfc` by ±`0x800` (masked `0x3fff`). |
| `0x1e`/`0x1f` | — | **[RECONSTRUCTED]** If `DAT_0001d858 < 3` and `DAT_00024cf8` not at endpoint: adjust `DAT_00024cf8` by ∓`0x540`. |
| `0x52`/`0x72` | `R`/`r` | **[RECONSTRUCTED]** Either adjust `DAT_00024cfc` by `+0x2000` if `DAT_0001d858 < 3`, **or** set `DAT_00024cfc`/`DAT_0001d800` to `0x2000` and `DAT_0001d858 = 1`. |
| `0x50`/`0x70` | `P`/`p` | **[RECONSTRUCTED]** `uVar6 = 4` → merge path. |
| Clamps | `0x1e`, `0xd5`, `0x18`, `0xab` | **[RECONSTRUCTED]** Used in **mouse slew** section with `FUN_00002e08` (likely `abs`) on deltas. |

**[UNKNOWN]** Full **semantic names** for `DAT_0001d858` values `1,2,3,5,6,7,8,9` (only **partial** behavior is visible from branches).

---

## Field / global usage (input-relevant)

**[RECONSTRUCTED]**

- **`DAT_0001d858`**: Top-level **UI/flight mode**; drives which branches run and the final `switch(DAT_0001d858)` camera block.
- **`DAT_0001b738`**: **Player entity** (`int*`); dereferenced as `*DAT_0001b738` for **object header** bytes at `+4`, `+7`, and offsets `+0x18/+0x1c/+0x20` position, `+0x19a`, `+0x19d`, `+0x19e`, `+0x19f`, `+0x1a1`, `+0x32`, `+0x612`, `+0x62a`, `+0x63e`, `+0x641`, `+0x676`, `+0x677`, `+0x679`, `+0x67b`, `+0x67d`, `+0x67e`, `+0x682`, `+0x685`, etc.
- **`DAT_0001b888`**: **Secondary entity** (target / wingman); `+0x18`/`0x1c`/`0x20` for mode `7` camera; ORs `+0x1a1` with `0x100` on key `0x18`.
- **`DAT_0001b5a0`**: **Mission block**: `+0x98`, `+0x25e`, `+0x2b6`, `+0x2be` (callbacks); `+0x33e`, `+0x340`, `+0x342` (map/mouse sync); `+0xa0`, `+0xa4`, `+0xb6`, `+0xb8`, `+0xce`, `+0xd4`, `+0xd6` (later HUD / briefing state).
- **`DAT_00024cf6`**: **Signed throttle / roll-step accumulator** processed after the key `switch` via `FUN_00002e08` and arithmetic on `(player+0x19a)` with clamp `0..9`.
- **`DAT_00024cf8`, `DAT_00024cfc`**: **Angular inputs** (`0x3fff` masks); tied to keys `0x1c`–`0x1f`, `R`, and mode `1`/`2` smoothing vs `DAT_0001d804`/`DAT_0001d800`.
- **`DAT_00020b2a` / `DAT_00020b2c`**: **Cursor** position; compared to mission `+0x33e`/`+0x340` for mouse flying.
- **`_DAT_00024d34`, `_DAT_00024d2c`, `_DAT_00024d2e`**: **Mouse mode** / axis selection for slew.
- **`DAT_0001b858`**: **Bitmask** set by `Z`/`X`-style keys (`0x2e`/`0x3e`/`0x5a`/`0x7a` vs `0x2f`/`0x3f`/`0x58`/`0x78`).

**[INFERRED]** Return value **`uVar6`** is a **bit flag packet** for “something requested camera/HUD/briefing update”; clearing **`(player+0x641)`** when non-zero suggests **“consume latch”** semantics.

---

## Unknowns

- **[UNKNOWN]** Exact **table** of all **`param_2`** values emitted by the Mac event path (only `3` and `4` appear in this function’s explicit tests).
- **[UNKNOWN]** Whether **`FUN_00002e08`** is exactly `abs` or includes **saturation** (name suggests helper).
- **[UNKNOWN]** End-to-end meaning of **`uVar6`** bits returned to caller (needs cross-ref to callers of `FUN_0000740a`).
- **[UNKNOWN]** Complete **player+0x32** values `0xe772` / `0xf7f0` (mode flags for numeric row behavior).

---

## Cross-references

- `docs/NOTES.md` — FUN_0000740a variable log
- `docs/STRUCTS.md` — FUN_0000740a globals
- `docs/ROADMAP.md` — key code → `param_1` mapping status
- `docs/input_godot_contract.md` — **[INFERRED]** Godot MVP implementation contract (gather outputs, gating, trace)
