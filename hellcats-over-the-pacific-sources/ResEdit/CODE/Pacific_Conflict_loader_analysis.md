# Pacific Conflict — Loader / Relocation Analysis

## 1) Container type

**Conclusion: (C) Mixed code + data, with optional load-time patching.**

| Option | Evidence |
|--------|----------|
| **(A) Raw 68k code blocks only** | Rejected. File contains data and string references (e.g. `s_GRAPHIC_SIMULATIONS_XXXXXXXXXXXX_0001a77c`, `DAT_0001a8b8` … `DAT_0001aa44`, `DAT_0001b524`, `DAT_0001b5a0`, `DAT_0001b738`) and code references them by absolute address. |
| **(B) Data-only** | Rejected. At file offset `0x20` the blob starts with valid 68k: `41f9 0001 a7d2` (LEA), `302f 0006`, `3080`, `3140 004a`, `4e75` (RTS). Dozens of LEA/MOVEA to `0x1a7d2`, `0x1b524`, `0x1b5a0`, `0x1b738` in first 8K. |
| **(C) Mixed code + data** | Supported. Code from at least `0x20` to past `0xdc8`, `0xb2a4`, and `0x1a75c`; at `0x1a75c` bytes are `4e75 4e56...` (RTS, LINK) i.e. code. Globals in `0x1a7xx`–`0x1bxxx` and above; no A5-relative refs in overlay (Pacific Conflict.c has no `unaff_A5`-style globals). |

---

## 2) First 4 u32 header (big-endian)

**Layout:** bytes `0x00`–`0x0f` = four big-endian u32s.

| Offset | Value (hex) | Value (dec) |
|--------|-------------|-------------|
| +0x00  | 0x00000107  | 263         |
| +0x04  | 0x0001a75c  | 108,380     |
| +0x08  | 0x00000dc8  | 3,528       |
| +0x0c  | 0x0000b2a4  | 45,732      |

**Candidate interpretations:**

- **H1 — Segment lengths (code, then data/other)**  
  - u32[0] = 263 = count of something (e.g. entries), or reserved.  
  - u32[1] = 0x1a75c = length of first segment. If first segment starts at `0x20`, it ends at `0x20 + 0x1a73c = 0x1a75c`.  
  - Bytes at file offset `0x1a75c` are `4e75 4e56...` (code), so segment 1 is code; segment 2 would start at `0x1a75c`.  
  - u32[2], u32[3] could be lengths of further segments.  
  - **Evidence:** Boundary at `0x1a75c` is a natural code/code boundary; code at `0x20` references `0x1a7d2` (inside segment 2 in this reading). So segment 2 is also code/data.

- **H2 — Offsets to segments**  
  - u32[1..3] = start offsets: 0x1a75c, 0xdc8, 0xb2a4.  
  - **Evidence:** At `0xdc8`: `2f03 2068 02c6 4e90...` (code). At `0xb2a4`: `5049 2293...` (code). At `0x1a75c`: code. So all three are plausible segment starts; u32[0]=263 could be a count or ID.  
  - **Issue:** 0xdc8 < 0xb2a4 < 0x1a75c, so ordering is “first segment at 0x1a75c”, “second at 0xdc8”, “third at 0xb2a4” — possible if header is not “order of appearance”.

- **H3 — Count + sizes for relocation or directory**  
  - u32[0] = 263 e.g. number of relocation entries or directory entries.  
  - 263×4 = 1,052 bytes. No contiguous run of 263 plausible file-offset u32s found at file end.  
  - Last 2KB: some u32s in [0, file_size) and word-aligned, but mixed with 0xffff… and non-offset values; not a clear reloc table.  
  - **Evidence:** Weak; no clean reloc layout identified.

**Summary:** H1 (first segment length = 0x1a75c, code from 0x20) is the most consistent with a single contiguous code+data image. H2 is possible if the three values are segment starts. H3 is speculative.

---

## 3) Relocation-like structure

**Searches performed:**

- Last 2KB as u32: no run of 263 word-aligned file-offset values; mix of zeros, 0xffff…, and values like 124000, 249904.  
- Last 64 bytes: sequence `0001..0015`, `0205`, then zeros — could be a small index table, not a reloc list.  
- No Mac CODE-style relocation block (type byte + offset runs) identified.

**Positive finding:**

- **FUN_00000020** (Pacific Conflict.c) takes one argument and does:
  - `DAT_0001a7d2 = param_1;`
  - `DAT_0001a81c = param_1;`
- So the overlay has **two cells** that are set from outside (loader). That is a **minimal “relocation”**: the loader calls this with a base (or handle) and the overlay stores it. No table of patch offsets was found; only this dual-store pattern.

**Conclusion:** No conventional relocation table was found. The only relocation-like behavior is the **two stored values** at 0x1a7d2 and 0x1a81c set by FUN_00000020.

---

## 4) Runtime addresses vs file offsets

**Observation:** In Pacific Conflict.c, all globals are at fixed addresses (e.g. DAT_0001b5a0, DAT_0001b738). There are no `unaff_A5`-relative globals. The binary at 0x20 uses **absolute** LEA/MOVEA (e.g. 41f9 0001 a7d2, 2079 0001 b5a0, 2279 0001 b738).

**Implications:**

- The overlay is built to run at a **fixed base address** (Ghidra’s base is 0).  
- **DAT_0001b5a0** and **DAT_0001b738** are **not** A5-relative and **not** heap handles in the decompiled overlay; they are absolute addresses.  
- So they are either:
  - **Overlay base + offset:** runtime_addr = overlay_base + offset, and in the export overlay_base was 0, so runtime_addr = offset. Then **file_offset = runtime_address** (identity) is the natural mapping if the whole file is loaded contiguously at that base.  
  - Or the loader relocates the block to a different base and patches the two cells via FUN_00000020; in that case “overlay base” = value passed to FUN_00000020.

**Minimum safe mapping (for parsing):**

- Treat **runtime address** in the decompiler (e.g. 0x1a7d2, 0x1b5a0, 0x1b738) as **file offset** for reading the blob, **only if** you assume:
  - the file is loaded as a single contiguous block, and  
  - the load base in the decompiler is 0 (identity).  
- Then:
  - **Safe to read as file offset:** any address in [0x20, 0x3e700) that falls inside the 255,360-byte file (e.g. 0x1b5a0 = 112,032, 0x1b738 = 112,440).  
  - **Do not trust** addresses below 0x20 (header) or beyond file length.  
  - If a loader actually uses FUN_00000020(base), then 0x1a7d2 and 0x1a81c in the file contain a **patched** value at runtime; parsing the blob as “identity” gives the initial/post-load value of that base, not necessarily the mission data.

---

## 5) Mapping hypotheses (short)

| ID | Hypothesis | Evidence |
|----|------------|----------|
| **H1** | First 4 u32: (count=263?, segment1_length=0x1a75c, segment2_length=0xdc8?, segment3_length=0xb2a4?). Code starts at 0x20; segment 1 ends at 0x1a75c. | Boundary at 0x1a75c is code; code at 0x20; refs into 0x1a7xxx. |
| **H2** | First 4 u32: (id/count, offset1=0x1a75c, offset2=0xdc8, offset3=0xb2a4). Three segment start offsets. | Bytes at 0xdc8, 0xb2a4, 0x1a75c all look like code. |
| **H3** | Identity mapping: runtime_address = file_offset for overlay. Globals (e.g. DAT_0001b5a0) are at file offset 0x1b5a0. | No A5 or reloc in overlay; LEA/MOVEA use 0x1a7d2, 0x1b5a0, 0x1b738; FUN_00000020 patches two cells only. |

---

## 6) Minimum safe parsing rule

- **Trust as file offset:** Any decompiler global address `A` with `0x20 ≤ A < 255360` (0x3e700). Read blob at `offset = A`, length as needed for the known structure.  
- **Do not trust:**  
  - Bytes before 0x20 (header; interpret per H1/H2, not as code).  
  - Addresses `A ≥ 255360` or `A < 0x20`.  
  - **Mission/data pointers** in the overlay (e.g. at 0x1b5a0) **until** the loader model is confirmed: if the main app passes a handle or different base via FUN_00000020, then 0x1a7d2/0x1a81c and any pointer derived from them are runtime-dependent.  
- **Endianness:** Big-endian (68k) for all multi-byte fields.  
- **Optional:** If you assume identity mapping and no runtime patching, you can parse mission/entity structures at 0x1b5a0, 0x1b738, etc., as raw file offsets.

---

## 7) Five functions to prioritize (entrypoint / loader chain)

| Function | Reason |
|----------|--------|
| **FUN_00000020** | Sets DAT_0001a7d2 and DAT_0001a81c from one argument; likely **loader callback** or **init entry** that receives base/handle. First place to see how the overlay is tied to the rest of the app. |
| **FUN_00000054** | Init: uses FUN_00001a48, FUN_00000032, and fills DAT_0001b524, DAT_0001b538, … from data at 0x1a77c, 0x1a8b8, … (strings/names). **Overlay init entry**; shows how globals are set from in-file data. |
| **FUN_00001a48** | Called repeatedly from FUN_00000054; likely **allocator** or **resource helper**. Needed to understand how pointers in DAT_0001b5xx are created (heap vs. in-file). |
| **FUN_000006ec** | Called from FUN_00000954 (which uses DAT_0001b738, DAT_0001b5a0). Likely **main loop or high-level update**; good for following control flow and how mission/entity data is used. |
| **ID08 FUN_00000006** | Main app **resource loader** (traps 0x2a2, 0x2b2, 0x2aa; unaff_A5). Does not reference “Pacific Conflict” by name in the export, but is the best candidate for **who loads the 255360-byte blob** (by resource type/ID or name). Trace callers of this and where the loaded block is used to confirm loader chain. |

---

## 8) Checksums

Pacific Conflict is **not** listed in `checksums.sha256` (only ID00–ID09 .bin are). Adding a checksum for “Pacific Conflict” is recommended for reproducibility.
