# FUN_0000435a — entity update branch (contract slice)

**Source:** `Pacific Conflict.c` **FUN_0000435a** (≈5008–5075), called from **FUN_000044a4** (5082).

## Signature

**[RECONSTRUCTED]** `void FUN_0000435a(char *param_1, int param_2)` — **param_1** entity base, **param_2** second argument from **FUN_000044a4**.

## Gating

**[RECONSTRUCTED]** Large outer block requires **(param_1[7] & 2) == 0** and **0 < *(short*)(DAT_0001b5a0+0xa8) < 6** (5018–5019).

## param_2 usage (proven)

**[RECONSTRUCTED]** For **`*param_1 == 0x02`**, a loop updating pointers from **param_1+0x48** runs **only when `param_2 == 0`** (5048–5071). So **arrays 3–4** (**param_2 == 1**) **skip** this loop for type-**0x02** entities.

**[INFERRED]** Other entity types may still differ; full table is **[UNKNOWN]**.

## Godot SimCore

**[RECONSTRUCTED]** Gate + `+0xc` scale/clamp + kind2 poly `+0x1c` via `SimCore._apply_fun_0000435a`, called from:
1. spawn `04e6e` followup (`param_2==0`)
2. per-entity `FUN_000044a4` tick path (`_update_single_entity` → world_obj_ptr)
3. `FUN_000046da` after factory `+8` (`param_2==1`) — `_046da_from_parent` and `_call_fun_000046da` (Pacific Conflict.c:5251)

**[RECONSTRUCTED]** `+0xc` scale source: `*(template+0xe)` via `_0435a_resolve_scale_src` when parent/embed/`b5a0+0x8c` resolve; else `spawn_0435a_scale_src`.

**[RECONSTRUCTED]** Kind2 `param_2==0` poly `+0x1c`: stream from same template (`+0x22` / `+0x1a` / `+0x1e`) via `_0435a_resolve_poly_srcs`; else `spawn_0435a_poly_srcs`.

**[RECONSTRUCTED]** `FUN_000044a4` type-5 flag tweak after `0435a` via `apply_044a4_type5_flags` / `mission_short_b0`.

**[MVP APPROXIMATION]** Per-tick **`param_2_entity_updates`** counts how many entities are updated with **`param_2 == 0`** vs **`1`** (four passes). e792 slices still run after `044a4` in the same entity update (original callers differ).
