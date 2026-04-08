# FUN_0000435a — entity update branch (contract slice)

**Source:** `Pacific Conflict.c` **FUN_0000435a** (≈5008–5075), called from **FUN_000044a4** (5082).

---

## Signature

**[RECONSTRUCTED]** `void FUN_0000435a(char *param_1, int param_2)` — **param_1** entity base, **param_2** second argument from **FUN_000044a4**.

---

## Gating

**[RECONSTRUCTED]** Large outer block requires **(param_1[7] & 2) == 0** and **0 < *(short*)(DAT_0001b5a0+0xa8) < 6** (5018–5019).

---

## param_2 usage (proven)

**[RECONSTRUCTED]** For **`*param_1 == 0x02`**, a loop updating pointers from **param_1+0x48** runs **only when `param_2 == 0`** (5048–5071). So **arrays 3–4** (**param_2 == 1**) **skip** this loop for type-**0x02** entities.

**[INFERRED]** Other entity types may still differ; full table is **[UNKNOWN]**.

---

## Godot SimCore

**[MVP APPROXIMATION]** Per-tick **`param_2_entity_updates`** counts how many entities are updated with **`param_2 == 0`** vs **`1`** (four passes). Full **FUN_0000435a** is **not** ported; counts support ordering/RNG analysis.
