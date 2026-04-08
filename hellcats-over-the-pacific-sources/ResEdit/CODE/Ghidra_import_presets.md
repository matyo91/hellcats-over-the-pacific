# Ghidra Import Presets — Pacific Conflict

Use **sections.json** and the tools in **tools/** to choose ranges. Below are three recommended import presets. Binary is **big-endian**, **Motorola 68000** (or 68020/68030 if needed).

---

## Preset 1: Single code segment (identity mapping, base 0)

**Use when:** You want one contiguous code+data image matching the decompiler’s base 0 (e.g. existing Pacific Conflict.c export).

| Setting        | Value |
|----------------|--------|
| **Processor**  | Motorola 68000 (or 68020/68030) |
| **Variant**    | Default / 68000 |
| **Base address** | `0x0` |
| **Endian**     | Big-endian |
| **Import as**  | Raw binary, **Code** from offset `0x20` to end of file (or to a chosen end). |

**Ranges (from sections.json):**

- **Code:** `0x20` – `0x3E6FF` (entire file after 32-byte header).  
  Or restrict to high code-score regions only (see Preset 2).

**Steps in Ghidra:**

1. File → Import File → choose **Pacific Conflict**.
2. Format: **Raw Binary**.
3. Language: **Motorola 68000 / BE (default)**.
4. Base address: `0x0`.
5. Block name: e.g. `PacificConflict`.
6. Length: `0x3E700` (255360) or `0x3E6E0` if you exclude the last 32 bytes.
7. After import, set the first byte to disassemble at `0x20` (skip header), then **Analyze**.

---

## Preset 2: Multiple sections (code-only regions)

**Use when:** You want to import only regions that look like 68k code (high code_score in sections.json), and treat the rest as data or leave unimported.

| Setting        | Value |
|----------------|--------|
| **Processor**  | Motorola 68000 |
| **Variant**    | Default |
| **Base address** | `0x0` |
| **Endian**     | Big-endian |
| **Import as**  | Raw binary; **Code** only in the ranges below; other ranges optional as **Data** or skip. |

**Recommended code ranges (from sections.json + code_score):**

| Section name                   | offset (hex) | size (dec) | code_score | Action   |
|--------------------------------|--------------|------------|------------|----------|
| segment_1_after_header        | 0x20         | 108348     | 0.084      | **Code** |
| at_offset_u32[2]              | 0xDC8        | 42204      | 0.1328     | **Code** |
| at_offset_u32[3]              | 0xB2A4       | 62648      | 0.0586     | **Code** |
| at_offset_u32[1]              | 0x1A75C      | 146980     | 0.0078     | Data or skip |

**Steps:**

1. Import file once as Raw Binary, base `0x0`, full length.
2. Create **memory blocks** (or use one block and then **Split** in Ghidra) so that:
   - `0x20`–`0x1A75B` = one block (segment_1 + 0xDC8 and 0xB2A4 regions are inside).
   - `0x1A75C`–end = second block (low code_score).
3. Set **code** at `0x20`, then at `0xDC8`, then at `0xB2A4` (Clear Code Bytes, then Disassemble), and run **Auto Analyze**.

---

## Preset 3: Overlay at non-zero base (e.g. 0x10000)

**Use when:** You assume the overlay is loaded at a fixed non-zero address (e.g. 0x10000) and want Ghidra addresses to match that.

| Setting        | Value |
|----------------|--------|
| **Processor**  | Motorola 68000 |
| **Variant**    | Default |
| **Base address** | `0x10000` (or 0x20000, etc.; choose one and stick to it) |
| **Endian**     | Big-endian |
| **Import as**  | Raw binary, one block; code from base+0x20. |

**Ranges:**

- **Block:** base `0x10000`, length `0x3E700`, file offset 0.
- **First instruction:** at `0x10020` (base + 0x20).

**Steps:**

1. Import File → Raw Binary.
2. Base address: `0x10000`.
3. Length: `0x3E700`.
4. After import, set **code** at `0x10020` and run **Analyze**.

**Note:** If the loader actually uses FUN_00000020(base), then symbols like DAT_0001b5a0 in the decompiler correspond to runtime address `base + 0x1b5a0`. Use this preset only if you have evidence for a specific load base.

---

## Summary

| Preset | Base address | Endian    | Best for |
|--------|--------------|-----------|----------|
| 1      | 0x0          | Big-endian | Matching existing export; single block. |
| 2      | 0x0          | Big-endian | Only high code_score sections as code. |
| 3      | 0x10000      | Big-endian | Testing a non-zero load address. |

**Processor:** Always **Motorola 68000** (or 68020/68030 if the binary uses instructions that need them). **Endian:** Always **Big-endian**.
