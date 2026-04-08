# ID00 → LoadSeg → segment-local target chain (proven)

Evidence-first. Tags: **[RECONSTRUCTED]** (binary/decompiler), **[PROVEN]** (binary + cross-segment check), **[INFERRED]** (reasoning).

## 1) Runtime address model

| Aspect | Conclusion | Citation |
|--------|------------|----------|
| **Overlay (Pacific Conflict)** | Mixed code+data; code from 0x20; no A5-relative globals; fixed base (Ghidra base 0). | [Pacific_Conflict_loader_analysis.md](../Hellcats-Over-the-Pacific_Mac_EN/ResEdit/CODE/Pacific_Conflict_loader_analysis.md) §1, §4, §5 (H3) |
| **Identity mapping** | For overlay: `runtime_address = file_offset` when load base = 0. | Ibid. §6. Safe parsing: `0x20 ≤ A < 0x3e700`. |
| **Relocation** | No reloc table. Only FUN_00000020 patches two cells: DAT_0001a7d2, DAT_0001a81c (base/handle from loader). | Ibid. §3. ResEdit/CODE/Pacific Conflict.c FUN_00000020. |
| **CODE segments (ID01–ID09)** | Segment-local offsets; segment loaded by LoadSeg; A5 world for globals (unaff_A5 in ID02/ID05 .c). | ID02.c, ID05.c; Apple Segment Manager (Inside Mac: RTArch-118). |

## 2) Entrypoint and overlay loading

| Item | Conclusion | Citation |
|------|------------|----------|
| **Overlay init** | FUN_00000020(base) then FUN_00000054() set overlay globals; DAT_0001b5a0, DAT_0001b738 etc. used as mission/entity base. | [Pacific_Conflict_loader_analysis.md](../Hellcats-Over-the-Pacific_Mac_EN/ResEdit/CODE/Pacific_Conflict_loader_analysis.md) §7. ResEdit/CODE/Pacific Conflict.c 60, 73, 889, FUN_000044e8, FUN_0000740a. |
| **Who loads overlay** | ID08 FUN_00000006 (resource traps 0x2a2, 0x2b2, 0x2aa) is the best candidate for loading the 255360-byte blob. | Ibid. §7. ID08.c. |
| **ID00 role** | CODE 0 (ID00.bin): jump-table / segment-loader table for CODE 1–9, not overlay data. | [NOTES.md](NOTES.md) ID00 / loader chain. [decode_id00_loadseg.py](../tools/decode_id00_loadseg.py). |

## 3) Minimal EntityState offsets (confirmed)

**[RECONSTRUCTED]** Entity layout from FUN_0000e792 (Pacific Conflict.c:14016+). Only offsets explicitly read/written in that function or its callees are considered proven.

| Offset (hex) | Use | Source |
|--------------|-----|--------|
| 0x00, 0x04, 0x08, 0x0c–0x20, 0x22, 0x2e, 0x32, 0x3a, 0x48, 0x50 | position, ptrs, state | [STRUCTS.md](STRUCTS.md) “Entity (FUN_0000e792)” |
| 0x61a, 0x61e, 0x626, 0x62a, 0x63e, 0x662, 0x666, 0x669, 0x66a, 0x66e, 0x672, 0x679 | movement, weapon | Ibid. |
| 0x67c, 0x67d, 0x67e, 0x685, 0x19a, 0x1a0, 0x1a1, 0x1a3 | weapon_count, status | Ibid. |

**[INFERRED]** Godot `entity_state.gd` OFFSETS match these; last proven offset in table is 0x1a3. Full entity size/padding **[UNKNOWN]**.

## 4) ID00.bin layout and trailing u16 (proven)

### 4.1) Header and table

- **Bytes 0x00–0x0f:** Four big-endian u32: `0x00000598`, `0x0000225e`, `0x00000578`, `0x00000020`.  
  **[RECONSTRUCTED]** [NOTES.md](NOTES.md); `xxd` on `ResEdit/CODE/ID00.bin`.
- **From 0x12:** Repeated 8-byte pattern: `3f 3c <seg_hi> <seg_lo> a9 f0 <tail_hi> <tail_lo>`.  
  **[RECONSTRUCTED]** [decode_id00_loadseg.py](../tools/decode_id00_loadseg.py); Apple Toolbox trap A9F0 = LoadSeg.
- **Interpretation:** Each record is `MOVE.W #segment_id,-(SP); _LoadSeg` (6 bytes) then one **trailing u16** (2 bytes). No following instruction consumes the tail; it is **stored data** in the same record.

### 4.2) Meaning of the trailing u16

**[PROVEN]** The trailing u16 is the **segment-local offset of (first instruction of the routine − 4)** in the typical case, or **−6** when the segment has a 6-byte header before the first routine.

**Evidence:**

1. **ID02 (segment 2), tail 0x199e → FUN_000019a2 (delta +4)**  
   Decoded ID02 segment (hex file decoded to binary):
   - At segment offset **0x199e:** `4e 5e` = **UNLK A6** (end of previous routine).
   - At **0x19a0:** `4e 75` = **RTS**.
   - At **0x19a2:** `4e 56` = **LINK** (start of FUN_000019a2).  
   So: tail = 0x199e = (LINK_offset) − 4 ⇒ **entrypoint_offset = tail + 4**.

2. **ID05 (segment 5), tail 0x0000 → FUN_00000006 (delta +6)**  
   Decoded ID05 segment:
   - At **0x0000:** `05 10 00 0b` (non-code; segment header/count).
   - At **0x0004:** `4e 75` = **RTS**.
   - At **0x0006:** `4e 56` = **LINK** (start of first routine).  
   So: tail = 0, first instruction at 6 ⇒ **entrypoint_offset = tail + 6** (6-byte prologue before first routine).

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
   So: tail = 0x018c ⇒ **entrypoint_offset = 0x0190** (tail + 4). ID00 has one segment-7 entry; this is it.

**Conclusion:** The trailing u16 is the **segment-local routine offset as stored by the linker**: stored_value = (first_instruction_offset − 4) or (first_instruction_offset − 6). So:
- **+4 delta:** bytes immediately before the correlated target are **UNLK (4e 5e)** then **RTS (4e 75)**; the tail points 4 bytes before LINK.
- **+6 delta:** segment has a 6-byte header before the first LINK; tail points to that header, so first instruction at tail+6.

References: Decoded `ResEdit/CODE/ID02`, `ID05`, `ID06`, `ID07` (xxd on .bin); [correlate_id00_to_functions.py](../tools/correlate_id00_to_functions.py) for deltas; [NOTES.md](NOTES.md) ID00 / loader chain.

## 5) First proven launcher handoff chain

Classic Mac 68k Segment Manager uses a jump table in CODE 0; ID00.bin is that jump table (or equivalent). Handoff:

1. **Caller (in some CODE segment)**  
   Executes **JSR *offset*(A5)** where *offset* is a positive offset into the jump table (e.g. ≥ 32 above A5).  
   [Inside Mac: RTArch-118 — “JSR offset(A5)” for intersegment calls.]

2. **Jump table entry (ID00.bin)**  
   At the entry corresponding to *offset*:
   - **MOVE.W #segment_id,-(SP); _LoadSeg** (trap A9F0) loads the target CODE resource if not already loaded.
   - The **trailing u16** in the same 8-byte record is the **stored segment-local offset** (routine_offset − 4 or −6 as above).

3. **Segment Manager (after LoadSeg)**  
   Loads the segment, then:
   - Computes **routine_address = segment_base + (tail + 4)** [or tail + 6 for first routine in a 6-byte-header segment].
   - Patches the jump table entry with a **JMP** to that address (e.g. 6-byte JMP in loaded entry).
   - Executes that JMP, transferring control to the routine.

4. **Target routine**  
   Starts with **LINK** (4e 56) at segment offset = tail + 4 (or tail + 6). Same layout in ID02, ID05, ID06, ID07 as per correlation.

**Chain summary:**  
**JSR offset(A5)** → [entry: MOVE.W #seg,-(SP); LoadSeg; .word tail] → **LoadSeg(seg)** → Segment Manager sets **routine = base + (tail+4 or tail+6)** → **JMP routine** → **LINK** at routine start.

**Citations:**
- ID00.bin bytes: `ResEdit/CODE/ID00.bin` (xxd, decode_id00_loadseg.py).
- Tail = (entrypoint − 4) / (entrypoint − 6): decoded ID02 at 0x199e–0x19a2 (UNLK, RTS, LINK); ID05 at 0x0000–0x0006 (header, RTS, LINK); ID06 at 0x0e0c–0x0e10, 0x096a–0x096e, 0x09d4–0x09d8; ID07 at 0x018c–0x0190.
- Jump table / LoadSeg semantics: [Inside Mac: Mac OS Runtime Architectures — The Jump Table](https://dev.os9.ca/techpubs/mac/runtimehtml/RTArch-118.html).
- Correlation deltas: [correlate_id00_to_functions.py](../tools/correlate_id00_to_functions.py) (ID02 65/68 at +4, ID05 11/11 at +4 or +6).

## 6) Recurring +4 / +6 delta (ID02, ID05, ID06, ID07)

| Segment | Bytes immediately before correlated target | Explanation |
|---------|--------------------------------------------|-------------|
| **ID02** | At (target − 4): **4e 5e** (UNLK); at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | Tail points to the **UNLK** of the previous function. Decompiler labels the **LINK** as function start ⇒ delta **+4**. |
| **ID05** | At (target − 6): segment header/count; at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | First routine in segment; 6-byte prologue before first LINK ⇒ delta **+6**. |
| **ID06** | At (target − 4): **4e 5e** (UNLK); at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | Same as ID02: tail = first_instruction − 4. Proven for tails 0x0e0c, 0x096a, 0x09d4 only (see §4.2). |
| **ID07** | At (target − 4): **4e 5e** (UNLK); at (target − 2): **4e 75** (RTS); at target: **4e 56** (LINK). | Same as ID02; single ID00 entry for segment 7, tail 0x018c → FUN_00000190. |

So the recurring +4 is “tail = first_instruction − 4” (previous function’s UNLK); +6 is “tail = first_instruction − 6” (6-byte header before first routine). **ID06** does not use a +6 first-routine layout at offset 0 (ID06.bin at 0x0000 is `01 70 00 09 48 e7 ...`, not a 6-byte prologue + RTS + LINK); **[RECONSTRUCTED]** from xxd. **ID07** at 0x0000 is `05 68 00 02 4e 75 4e 56 ...` (4-byte header, RTS, LINK at 0x06), so first routine could be at 0x06 with delta +6, but the only ID00 entry for segment 7 has tail 0x018c (delta +4). **[UNKNOWN]** whether segment 7 has another call path for the routine at 0x06.

## 7) Unresolved segment-6 and segment-7 entries

**[UNKNOWN]** The following ID00 entries for segment 6 do **not** show UNLK (4e 5e) at the stored tail; they are not promoted to proven targets until byte-level evidence matches the +4/+6 rule:

| Segment | Tail (hex) | Bytes at tail (xxd) | Reason not proven |
|---------|------------|---------------------|-------------------|
| 6 | 0x089e | 70 00 (MOVEQ), then 4e 75 4e 56 | RTS at tail, not UNLK. |
| 6 | 0x07ac | 4e 75 (RTS), then 4e 56 | RTS at tail, not UNLK. |
| 6 | 0x0854 | 4e 5e 4e 75, then 4e ba (JSR) | No LINK at tail+4. |
| 6 | 0x0112 | 4e 75 (RTS), then 4e 56 | RTS at tail, not UNLK. |
| 6 | 0x00ea | 4e ba (JSR) | Not UNLK/RTS/LINK. |
| 6 | 0x0398 | 2a ba ... | Not UNLK/RTS/LINK. |

Segment 7 has only one ID00 entry (tail 0x018c), which **is** proven (see §4.2).

## 8) Implementation handoff artifact

- **[PROVEN]** A minimal machine-readable artifact for the first proven loader targets exists at [`tools/proven_loader_targets.json`](../../tools/proven_loader_targets.json).
- **[INFERRED]** Godot can consume this artifact as loader-derived metadata without embedding any guessed segment-manager behavior.
- **[UNKNOWN]** Additional targets (including the new ID06/ID07 proven targets below) may be added to that JSON only when the maintainer re-runs the proof and updates the artifact; this document does not edit `tools/`.

## 9) Godot integration boundary

- **[INFERRED]** [`loader_metadata.gd`](../hellcats/core/loader_metadata.gd) is the clean-room boundary for proven loader-target facts: parsed JSON only, no segment-manager emulation.
- **[INFERRED]** [`sim_core.gd`](../hellcats/core/sim_core.gd) now accepts that metadata through `load_loader_metadata_from_file()` / `load_loader_metadata_from_json_text()` and resolves targets through `resolve_loader_target()`.
- **[RECONSTRUCTED]** The headless integration test [`test_sim_loader_bridge.gd`](../hellcats/tests/test_sim_loader_bridge.gd) proves `SimCore` can ingest the proven ID02 and ID05 targets and still execute a deterministic tick.
- **[UNKNOWN]** Runtime relocation, jump-table patching, and actual segment load execution are still out of scope for the Godot core until the address model is proven further.

## 10) Safe targets for Godot consumption now

Only the following loader targets are supported by **byte-level evidence** (UNLK/RTS/LINK at tail for +4, or 6-byte prologue + RTS/LINK for +6). Godot or tooling may safely resolve these segment + entrypoint pairs from ID00 and the segment binaries.

| Segment | id00_entry_offset (dec) | stored_tail (hex) | entrypoint_offset (hex) | Delta | Correlated routine |
|---------|-------------------------|--------------------|--------------------------|-------|---------------------|
| **ID02** | 770 | 0x199e | 0x19a2 | +4 | FUN_000019a2 |
| **ID05** | 1314 | 0x0000 | 0x0006 | +6 | FUN_00000006 |
| **ID06** | 386 | 0x0e0c | 0x0e10 | +4 | FUN_00000e10 |
| **ID06** | 418 | 0x096a | 0x096e | +4 | FUN_0000096e |
| **ID06** | 426 | 0x09d4 | 0x09d8 | +4 | FUN_000009d8 |
| **ID07** | 1402 | 0x018c | 0x0190 | +4 | FUN_00000190 |

**[PROVEN]** counts: ID02 one, ID05 one, ID06 three, ID07 one. All others (including the six unresolved ID06 entries in §7) remain **[UNKNOWN]** until the same byte-level check is applied.
