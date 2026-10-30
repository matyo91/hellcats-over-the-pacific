# ID00 → LoadSeg → segment-local target chain (proven)

Evidence-first. Tags: **[RECONSTRUCTED]** (binary/decompiler), **[PROVEN]** (binary + cross-segment check), **[INFERRED]** (reasoning).

## 1) Runtime address model

| Aspect | Conclusion | Citation |
|--------|------------|----------|
| **Overlay (Pacific Conflict)** | Mixed code+data; code from 0x20; no A5-relative globals; fixed base (Ghidra base 0). | [Pacific_Conflict_loader_analysis.md](../sources/resedit-1-0-3/CODE/Pacific_Conflict_loader_analysis.md) §1, §4, §5 (H3) |
| **Identity mapping** | For overlay: `runtime_address = file_offset` when load base = 0. | Ibid. §6. Safe parsing: `0x20 ≤ A < 0x3e700`. |
| **Relocation** | No reloc table. Only FUN_00000020 patches two cells: DAT_0001a7d2, DAT_0001a81c (base/handle from loader). | Ibid. §3. ResEdit/CODE/Pacific Conflict.c FUN_00000020. |
| **CODE segments (ID01–ID09)** | Segment-local offsets; segment loaded by LoadSeg; A5 world for globals (unaff_A5 in ID02/ID05.c). | ID02.c, ID05.c; Apple Segment Manager (Inside Mac: RTArch-118). |

## 2) Entrypoint and overlay loading

| Item | Conclusion | Citation |
|------|------------|----------|
| **Overlay init** | FUN_00000020(base) then FUN_00000054 set overlay globals; DAT_0001b5a0, DAT_0001b738 etc. used as mission/entity base. | [Pacific_Conflict_loader_analysis.md](../sources/resedit-1-0-3/CODE/Pacific_Conflict_loader_analysis.md) §7. ResEdit/CODE/Pacific Conflict.c 60, 73, 889, FUN_000044e8, FUN_0000740a. |
| **Who loads overlay** | ID08 FUN_00000006 (resource traps 0x2a2, 0x2b2, 0x2aa) is the best candidate for loading the 255360-byte blob. | Ibid. §7. ID08.c. |
| **ID00 role** | CODE 0 (ID00.bin): jump-table / segment-loader table for CODE 1–9, not overlay data. | Byte evidence retained below. |

## 3) Minimal EntityState offsets (confirmed)

**[RECONSTRUCTED]** Entity layout from FUN_0000e792 (Pacific Conflict.c:14016+). Only offsets explicitly read/written in that function or its callees are considered proven.

| Offset (hex) | Use | Source |
|--------------|-----|--------|
| 0x00, 0x04, 0x08, 0x0c–0x20, 0x22, 0x2e, 0x32, 0x3a, 0x48, 0x50 | position, ptrs, state | [STRUCTS.md](STRUCTS.md) “Entity (FUN_0000e792)” |
| 0x61a, 0x61e, 0x626, 0x62a, 0x63e, 0x662, 0x666, 0x669, 0x66a, 0x66e, 0x672, 0x679 | movement, weapon | Ibid. |
| 0x67c, 0x67d, 0x67e, 0x685, 0x19a, 0x1a0, 0x1a1, 0x1a3 | weapon_count, status | Ibid. |

**[INFERRED]** Godot `entity_state.gd` OFFSETS match these; last proven offset in table is 0x1a3. Full entity size/padding **[UNKNOWN]**.

## 4) ID00.bin layout and stored routine offset (proven)

### 4.1) Header and table

- **Bytes 0x00–0x0f:** Four big-endian u32: `0x00000598`, `0x0000225e`, `0x00000578`, `0x00000020`.
  **[RECONSTRUCTED]** `xxd` on `ResEdit/CODE/ID00.bin`.
- **From 0x10:** Repeated 8-byte records: `<offset_hi> <offset_lo> 3f 3c <seg_hi> <seg_lo> a9 f0`.
  **[RECONSTRUCTED]** retained byte evidence; Apple Toolbox trap A9F0 = LoadSeg. The former one-off decoder was not retained.
- **Interpretation:** Each record begins with a stored routine offset, followed by the callable six-byte `MOVE.W #segment_id,-(SP); _LoadSeg` stub. The A5 jump-table address points at record +2.

### 4.2) Meaning of the stored routine offset

**[PROVEN]** The first u16 is the target offset relative to the four-byte header of the destination CODE resource. Therefore the physical target in `IDnn.bin` is always `stored_routine_offset + 4`.

**Evidence:**

1. **ID02 (segment 2), tail 0x199e → FUN_000019a2 (delta +4)**
   Decoded ID02 segment (hex file decoded to binary):
   - At segment offset **0x199e:** `4e 5e` = **UNLK A6** (end of previous routine).
   - At **0x19a0:** `4e 75` = **RTS**.
   - At **0x19a2:** `4e 56` = **LINK** (start of FUN_000019a2).
   So: tail = 0x199e = (LINK_offset) − 4 ⇒ **entrypoint_offset = tail + 4**.

2. **ID05 (segment 5), stored offset 0x0000 → file 0x0004 (delta +4)**
   Decoded ID05 segment:
   - At **0x0000:** `05 10 00 0b` (non-code; segment header/count).
   - At **0x0004:** `4e 75` = **RTS**, the jump-table target.
   - At **0x0006:** `4e 56` = **LINK** (start of the next, distinct routine).
   So the zero-offset entry is a no-op return at file 0x0004; associating it with `FUN_00000006` was incorrect.

3. **ID06 (segment 6), tail 0x0e0c → FUN_00000e10 (delta +4)**
   **[PROVEN]** `xxd` on `ResEdit/CODE/ID06.bin` at offset 0x0e08:
   - At **0x0e0c:** `4e 5e` = **UNLK**; at **0x0e0e:** `4e 75` = **RTS**; at **0x0e10:** `4e 56` = **LINK** (start of FUN_00000e10 in ID06.c).
   So: tail = 0x0e0c ⇒ **entrypoint_offset = 0x0e10** (tail + 4).

4. **ID06 (segment 6), tail 0x096a → FUN_0000096e (delta +4)**
   **[PROVEN]** ID06.bin at 0x0966: bytes at **0x096a** are `4e 5e 4e 75 4e 56` (UNLK, RTS, LINK). LINK at 0x096e = FUN_0000096e (ID06.c).

5. **ID06 (segment 6), tail 0x09d4 → FUN_000009d8 (delta +4)**
   **[PROVEN]** ID06.bin at 0x09d0: bytes at **0x09d4** are `4e 5e 4e 75 4e 56` (UNLK, RTS, LINK). LINK at 0x09d8 = FUN_000009d8 (ID06.c).

6. **ID07 (segment 7), tail 0x018c → FUN_00000190 (delta +4)**
   **[PROVEN]** `xxd` on `ResEdit/CODE/ID07.bin` at offset 0x0188:
   - At **0x018c:** `4e 5e` = **UNLK**; at **0x018e:** `4e 75` = **RTS**; at **0x0190:** `4e 56` = **LINK** (start of FUN_00000190 in ID07.c).
   So: stored offset 0x018c ⇒ **entrypoint_offset = 0x0190**. This is the nontrivial segment-7 entry; its other entry stores zero and targets the RTS at file 0x0004.

**Conclusion:** The stored u16 is the routine offset in the segment's code area; the `.bin` includes the segment's four-byte header, so `target_file_offset = stored_routine_offset + 4` for all 175 entries. Most targets begin with `LINK`; zero-offset entries commonly target a header-adjacent `RTS` that Ghidra omitted.

References: decoded `ResEdit/CODE/ID02`, `ID05`, `ID06`, `ID07` (`xxd` on
`.bin`) and the correlation results preserved above.

## 5) First proven launcher handoff chain

Classic Mac 68k Segment Manager uses a jump table in CODE 0; ID00.bin is that jump table (or equivalent). Handoff:

1. **Caller (in some CODE segment)**
   Executes **JSR *offset*(A5)** where *offset* is a positive offset into the jump table (e.g. ≥ 32 above A5).
   [Inside Mac: RTArch-118 — “JSR offset(A5)” for intersegment calls.]

2. **Jump table entry (ID00.bin)**
   At the entry corresponding to *offset*:
   - **MOVE.W #segment_id,-(SP); _LoadSeg** (trap A9F0) loads the target CODE resource if not already loaded.
   - The u16 immediately before the stub is the **stored code-area-relative routine offset**.

3. **Segment Manager (after LoadSeg)**
   Loads the segment, then:
   - Computes **routine_address = segment resource base + stored offset + 4** in the file-coordinate model used here.
   - Patches the jump table entry with a **JMP** to that address (e.g. 6-byte JMP in loaded entry).
   - Executes that JMP, transferring control to the routine.

4. **Target routine**
   Begins at physical resource offset `stored + 4`. Many routines start with **LINK** (`4e56`), while leaf/no-op and glue entries may start with other instructions.

**Chain summary:**
**JSR offset(A5)** → [record: stored offset; `MOVE.W #seg,-(SP); LoadSeg`] → **LoadSeg(seg)** → Segment Manager patches the stub → **JMP to segment file offset stored+4**.

**Citations:**
- ID00.bin bytes: `ResEdit/CODE/ID00.bin` (xxd, decode_id00_loadseg.py).
- Stored offset + four-byte header: decoded ID02 at 0x199e–0x19a2 (UNLK, RTS, LINK); ID05 at 0x0000–0x0006 (header, target RTS, next LINK); ID06 at 0x0e0c–0x0e10, 0x096a–0x096e, 0x09d4–0x09d8; ID07 at 0x018c–0x0190.
- Jump table / LoadSeg semantics: [Inside Mac: Mac OS Runtime Architectures — The Jump Table](https://dev.os9.ca/techpubs/mac/runtimehtml/RTArch-118.html).
- Complete decoded table: `ID00.decomp.c`; every target uses the four-byte CODE-resource header adjustment.

## 6) Uniform four-byte file-coordinate adjustment

| Segment | Bytes immediately before correlated target | Explanation |
|---------|--------------------------------------------|-------------|
| **ID02** | At (target − 4): **4e 5e** (UNLK); at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | Tail points to the **UNLK** of the previous function. Decompiler labels the **LINK** as function start ⇒ delta **+4**. |
| **ID05** | Stored offset 0 maps to file 0x04: **4e 75** (RTS); file 0x06 begins a separate **LINK** routine. | The zero-offset jump-table entry is the header-adjacent no-op return. |
| **ID06** | At (target − 4): **4e 5e** (UNLK); at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | Same as ID02: tail = first_instruction − 4. Proven for tails 0x0e0c, 0x096a, 0x09d4 only (see §4.2). |
| **ID07** | At (target − 4): **4e 5e** (UNLK); at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | Same as ID02; single ID00 entry for segment 7, tail 0x018c → FUN_00000190. |

The `+4` is not an epilogue heuristic: it converts a code-area-relative stored offset to a physical offset in the resource file. `ID03`, `ID04`, `ID05`, `ID07`, and `ID08` all contain header-adjacent `RTS` targets at file 0x04; their following `LINK` routines at 0x06 are separate entries only when explicitly named by another stored offset.

## 7) Segment-6 entries omitted by Ghidra

The following targets are structurally resolved by the uniform `stored + 4` rule, but Ghidra did not export all of them as `FUN_*` functions. Their higher-level semantics remain **[UNKNOWN]**:

| Segment | Stored offset | Target bytes | Remaining uncertainty |
|---------|---------------|--------------|-----------------------|
| 6 | 0x089e | file 0x08a2: `4e56` (LINK) | Valid unexported routine start. |
| 6 | 0x07ac | file 0x07b0: `4e56` (LINK) | Valid unexported routine start. |
| 6 | 0x0854 | file 0x0858: `4eba` (BSR/JSR PC-relative) | Valid entry without a LINK frame. |
| 6 | 0x0112 | file 0x0116: `4e56` (LINK) | Valid unexported routine start. |
| 6 | 0x00ea | file 0x00ee: `202d` | Valid entry without a LINK frame. |
| 6 | 0x0398 | file 0x039c: target belongs to ID08, not ID06 | Corrected segment association from ID00. |

Segment 7 has two ID00 entries: stored offset 0 targets the RTS at file 0x0004, and stored offset 0x018c targets `FUN_00000190` at file 0x0190.

## 8) Implementation handoff artifact

- **[PROVEN]** The proven loader targets below are checked against the jump table the game runtime links ([`godot/hellcats/data/jump_table.json`](../godot/hellcats/data/jump_table.json), generated from `ID00.bin` by `tools/hellcats/build_runtime_data.py`) by `check_loader_targets` in [`tools/qa/test_regression.py`](../tools/qa/test_regression.py): each one's A5 offset is `jump_table_offset + id00_entry_offset - 16 + 2`, its segment and entry point as tabled here.
- **[UNKNOWN]** Additional targets may be added to that check only when the maintainer re-runs the proof.

## 9) Godot integration boundary

- **[RECONSTRUCTED]** The game runtime ([`docs/GAME_RUNTIME.md`](GAME_RUNTIME.md)) links every jump-table entry to its strict-port routine (`godot/hellcats/runtime/segment_loader.gd`) and loads the Pacific Conflict overlay with its relocations; the earlier clean-room loader metadata boundary of the MVP prototype is gone with it.

## 10) Safe targets for Godot consumption now

The complete set of 175 loader targets is structurally decoded in `ID00.decomp.c`. These six byte-inspected examples are the ones the QA check holds:

| Segment | id00_entry_offset (dec) | stored_tail (hex) | entrypoint_offset (hex) | Delta | Correlated routine |
|---------|-------------------------|--------------------|--------------------------|-------|---------------------|
| **ID02** | 776 | 0x199e | 0x19a2 | +4 | FUN_000019a2 |
| **ID05** | 1368 | 0x0000 | 0x0004 | +4 | unexported RTS no-op |
| **ID06** | 392 | 0x0e0c | 0x0e10 | +4 | FUN_00000e10 |
| **ID06** | 424 | 0x096a | 0x096e | +4 | FUN_0000096e |
| **ID06** | 432 | 0x09d4 | 0x09d8 | +4 | FUN_000009d8 |
| **ID07** | 1408 | 0x018c | 0x0190 | +4 | FUN_00000190 |

**[PROVEN]** structural example counts: ID02 one, ID05 one, ID06 three, ID07 one. Higher-level semantics remain unresolved for the null-symbol entries in `ID00.decomp.c`.

## Host globals seen from the overlay

`DAT_0001b5a0` holds the address `A5 - 0x1388` that the host passes to the
overlay entry (`reset_overlay_state`, ID02 0x212a). An overlay access
`DAT_0001b5a0 + k` is therefore the host global `A5 - 0x1388 + k`:

| Overlay offset | Host global | Meaning |
|---|---|---|
| +0xe | A5-0x137a | pixel depth 1 / 4 / 8 (older notes call it a mission mode) |
| +0x16 / +0x18 | A5-0x1372 / A5-0x1370 | view width / height |
| +0x90 | A5-0x12f8 | mission number |
| +0xb6 / +0xb8 | A5-0x12d2 / A5-0x12d0 | fuel % / bombs |
| +0xba.. | A5-0x12ce.. | kill counters by target type |
| +0xd2 | A5-0x12b6 | friendly units destroyed |
| +0xd8, +0x192, +0x1ac, +0x1b4 | A5-0x12b0, -0x11f6, -0x11dc, -0x11d4 | cached panel bitmap handles |
| +0x2c6.. +0x2e2 | A5-0x10c2.. A5-0x10a6 | host memory services (new / realloc / lock / unlock / purge / nopurge / freemem) |

**[STRONG INFERENCE]** — every offset checked so far agrees with the host
side; the A5-0x1388 argument itself is **[PROVEN]** (ID02 0x217a).
