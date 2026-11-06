# ID09: the Toolbox glue segment

Three byte-level analyses of CODE 9, the Toolbox glue segment: its selector discrepancies, `FUN_00000048` (the SysEnvirons glue), and its terminal block.

## ID09 selector discrepancies

Scope: `ID09.c:44-65`, `FUN_00000048`, and the adjacent omitted block.
All offsets in the byte table are **physical file offsets**, obtained by searching
`ID09.bin`; absolute machine operands do not imply locations in that file.

### Independent location and decoding

The sequence `32bc0001207802ae337cfffe0002` occurs exactly once, at file offset
`0x68`. Its writes of 1 and 0xfffe correspond to the exported initialization.
Capstone 5.0.7 in M68K 68000 big-endian mode decodes the contiguous window:

| File offset | Bytes | Decode (branch targets expressed in this file coordinate) |
|---|---|---|
| 0x068 | 32bc0001 | `move.w #$1, (a1)` |
| 0x06c | 207802ae | `movea.l $2ae.w, a0` |
| 0x070 | 337cfffe0002 | `move.w #$fffe, $2(a1)` |
| 0x076 | 0c2800ff0009 | `cmpi.b #$ff, $9(a0)` |
| 0x07c | 6742 | `beq.b $c0` |
| 0x07e | 4a280008 | `tst.b $8(a0)` |
| 0x082 | 6e20 | `bgt.b $a4` |
| 0x084 | 337cffff0002 | `move.w #$ffff, $2(a1)` |
| 0x08a | 4a78028e | `tst.w $28e.w` |
| 0x08e | 6b30 | `bmi.b $c0` |
| 0x090 | 337c00010002 | `move.w #$1, $2(a1)` |
| 0x096 | 4a780b22 | `tst.w $b22.w` |
| 0x09a | 6a24 | `bpl.b $c0` |
| 0x09c | 337c00020002 | `move.w #$2, $2(a1)` |
| 0x0a2 | 601c | `bra.b $c0` |
| 0x0a4 | 42690002 | `clr.w $2(a1)` |
| 0x0a8 | 0c2800020008 | `cmpi.b #$2, $8(a0)` |
| 0x0ae | 6e10 | `bgt.b $c0` |
| 0x0b0 | 6708 | `beq.b $ba` |
| 0x0b2 | 337c00040002 | `move.w #$4, $2(a1)` |
| 0x0b8 | 6006 | `bra.b $c0` |
| 0x0ba | 337c00030002 | `move.w #$3, $2(a1)` |
| 0x0c0 | 42690004 | `clr.w $4(a1)` |
| 0x0c4 | 0c380002012f | `cmpi.b #$2, $12f.w` |
| 0x0ca | 6e0a | `bgt.b $d6` |
| 0x0cc | 1038012f | `move.b $12f.w, d0` |
| 0x0d0 | 5240 | `addq.w #$1, d0` |
| 0x0d2 | 13400007 | `move.b d0, $7(a1)` |

### Pointer-backed selectors

**[PROVEN, bytes]** `MOVEA.L $2ae.w,A0` loads a longword pointer from absolute
machine address 0x02ae. `CMPI.B #$ff,$9(A0)` and `TST.B $8(A0)` then read bytes
relative to that pointer. The subsequent BGT tests are signed-byte comparisons.
They do not directly read the absolute addresses `DAT_216e0017` / `DAT_216e0016`.

**[PROVEN, artifact correlation]** The four bytes at physical file offset 0x2ae
are `21 6e 00 0e`. Their big-endian value is 0x216e000e; adding 8 and 9 gives
exactly 0x216e0016 and 0x216e0017, the two exported global labels.

**[STRONG INFERENCE]** Ghidra propagated a constant pointer from the imported
segment bytes at the numeric low-memory address instead of representing the
runtime pointer load. This explains both labels simultaneously. The actual
analysis/import configuration has not been inspected, so the mechanism is not
PROVEN. The runtime pointer value, pointed-to record and hardware meanings
remain UNKNOWN. This evidence is not permission to equate file offset 0x2ae
with runtime address 0x02ae.

### Omitted output-byte write

**[PROVEN, bytes]** At file 0xc4, signed-byte comparison against 2 is followed
by BGT to 0xd6. Otherwise the path loads byte at machine address 0x012f into
D0.B, increments D0.W by one, and stores D0.B to output +7. The high byte of
D0.W is not initialized here; the byte result is still the input byte plus one
modulo 256. Reads remain separate; a stable value must not be assumed without
an aliasing/runtime argument. No code is replaced with this description.

The original C warning says a block at `ram,0x000000cc` was removed as
unreachable. The independent byte match and exact warning location support
correspondence with this omitted path, but the reason it was removed is UNKNOWN.
The exported C directly proceeds from word-2 zeroing to the flag writes.

### Reconstruction decision

Retain the original identifiers, comparisons and all executable C tokens. Add
local discrepancy comments and keep the function INVESTIGATING. A future repair
must model the runtime pointer/absolute globals, omitted path and trap ABI together
with explicit types and validation; this pass does not claim whole-function
behavioral equivalence to the binary or VERIFIED status.

Validation: all table bytes checked against the protected binary; independent
analysis and QA; 32 protected hashes unchanged; C edits contain comments only.

## ID09 `FUN_00000048`: reverse lookup and SysEnvirons identification

Scope: `ID09.c:72-79` (reverse lookup) plus a function-level identification
hypothesis. Offsets are **physical file offsets in `ID09.bin`**. Capstone 5.0.7,
M68K 68000 big-endian.

### Reverse lookup bytes [PROVEN, bytes]

| File offset | Bytes | Decode |
|---|---|---|
| 0x052 | 6006 | `bra.b $5a` (skips data island) |
| 0x054 | 03 13 0b 02 01 00 | literal table (decoded by Capstone as junk `btst`) |
| 0x0f8 | 1038021e | `move.b $21e.w, d0` |
| 0x0fc | 41faff5b | `lea.l $59(pc), a0` (unique in the file) |
| 0x100 | 323c0004 | `move.w #$4, d1` |
| 0x104 | b020 | `cmp.b -(a0), d0` |
| 0x106 | 57c9fffc | `dbeq d1, $104` |
| 0x10a | 5241 | `addq.w #$1, d1` |
| 0x10c | 3341000a | `move.w d1, $a(a1)` |

`LEA d16(PC)` is position-independent: target = 0xfe + (−0xa5) = 0x59 in the
same segment, so `DAT_00000059` is a segment-relative label. Here, Ghidra's
address coordinate coincides with the file offset for this segment (function
entry at file 0x48 = `FUN_00000048`); that coincidence is observed, not assumed.

Pre-decrement reads 0x58, 0x57, 0x56, 0x55, 0x54. DBEQ exits without
decrementing on match, so word +0x0a receives:

| KbdType byte | Result |
|---|---|
| 0x01 | 5 |
| 0x02 | 4 |
| 0x0b | 3 |
| 0x13 | 2 |
| 0x03 | 1 |
| other | 0 (D1 reaches −1, +1) |

The Ghidra C loop (`ID09.c:72-79`) is equivalent: pointer pre-decrement,
break before counter decrement, exit at −1, store counter+1.

### Function identification [STRONG INFERENCE]

Proposed name: `sysenvirons_glue_fallback`. Every observed field and global
fits the documented Inside Macintosh `SysEnvRec` and low-memory map:

| Record offset | Written from | SysEnvRec field |
|---|---|---|
| +0 word | constant 1 | environsVersion |
| +2 word | ROMBase($2ae)→ROM version bytes, ROM85($28e), HWCfgFlags($b22) | machineType (−2 XL, −1 Mac, 1 512KE, 2 Plus, 3 SE, 4 II) |
| +4 word | 0 | systemVersion |
| +7 byte | CPUFlag($12f)+1 when ≤2 (omitted Ghidra block) | processor (env68000=1…) |
| +8 byte | ROM85≥0 && HWCfgFlags bit 12 | hasFPU |
| +9 byte | ROM85 < 0x4000 | hasColorQD |
| +0xa word | KbdType($21e) table above | keyBoardType |
| +0xd byte | ABusVars($2dc)+7 when PortBUse($291)≥0 && SPConfig($1fb)&0xf==1 | atDrvrVersNum |
| +0xe word | BootDrive($210), then volume lookup via `$A260`/`$A207` | sysVRefNum |

Return word `0xea84` = −5500 = `envNotPresent`, written to the caller's result
slot before `JMP (A1)` — consistent with a Pascal-convention glue routine.
The 'ERIK' literal (`0x4552494b`) used in the terminal path is unexplained.

Limits: low-memory names and enum values come from external Apple
documentation, not from this binary. No Apple glue source or runtime trace has
been compared, so the function is not VERIFIED. machineType value meanings and
the A-line trap names (`$A260`, `$A207`) remain HYPOTHESIS.

### Entry dispatcher (file 0x20..0x46) [PROVEN bytes; trap names from docs]

| File offset | Bytes | Decode |
|---|---|---|
| 0x20 | 4a78028e | `tst.w $28e.w` (ROM85) |
| 0x24 | 6b22 | `bmi.b $48` → fallback |
| 0x26 | 303c0090 | `move.w #$90, d0` |
| 0x2a | a346 | GetOSTrapAddress |
| 0x2c | 2248 | `movea.l a0, a1` |
| 0x2e | 303c009f | `move.w #$9f, d0` |
| 0x32 | a746 | GetToolTrapAddress (_Unimplemented) |
| 0x34 | b3c8 | `cmpa.l a0, a1` |
| 0x36 | 6710 | `beq.b $48` → fallback |
| 0x38–0x3e | 225f 205f 301f 2f09 | pop return→A1, rec ptr→A0, version→D0; push return |
| 0x40 | a090 | _SysEnvirons |
| 0x42 | 3f400004 | `move.w d0, $4(a7)` (function result) |
| 0x46 | 4e75 | `rts` |

This explains why the 0x48 body exists, which justifies the rename. The
machineType mapping (XL/Mac/512KE/Plus/SE/II from ROM version bytes) remains
HYPOTHESIS.

## ID09 terminal block

Scope: original `ID09.c:84-103`, `FUN_00000048`. This records binary evidence
for the terminal block without reconstructing missing instructions into C.

### Locating the evidence

`bytes.fromhex(ID09)` equals `ID09.bin` exactly (1100 bytes). Searching that
binary for `323c003c426751c9fffc` returns exactly one physical offset: `0x13e`.
This distinctive immediate-counter/word-clear/DBRA sequence corresponds to the
exported loop. The adjacent `31780a580018` and `3ebcea84` signatures occur at
`0x14a` and `0x184`, corroborating the source global and literal. Offsets below
are positions in the binary, **not inferred runtime addresses**. Absolute operands
such as `$a58.w` identify machine-address operands, not file locations.

Capstone 5.0.7, M68K 68000 big-endian mode, decoded the contiguous window from
file offset `0x134` through `0x189`. A-line words are kept opaque; no Toolbox
name or ABI is inferred from their numeric values.

| File offset | Bytes | Decoded operation |
|---|---|---|
| 0x134 | 4a7803f6 | TST.W $3f6.w |
| 0x138 | 6d44 | BLT to window location 0x17e |
| 0x13a | 4269000e | CLR.W $e(A1) |
| 0x13e | 323c003c | MOVE.W #$3c,D1 |
| 0x142 | 4267 | CLR.W -(A7) |
| 0x144 | 51c9fffc | DBRA D1, loop at 0x142 |
| 0x148 | 204f | MOVEA.L A7,A0 |
| 0x14a | 31780a580018 | MOVE.W $a58.w,$18(A0) |
| 0x150 | 7008 | MOVEQ #8,D0 |
| 0x152 | a260 | Opaque A-line word |
| 0x154 | 6624 | BNE to 0x17a |
| 0x156 | 316800340016 | MOVE.W $34(A0),$16(A0) |
| 0x15c | a207 | Opaque A-line word |
| 0x15e | 661a | BNE to 0x17a |
| 0x160 | 2168005a0030 | MOVE.L $5a(A0),$30(A0) |
| 0x166 | 217c4552494b001c | MOVE.L #$4552494b,$1c(A0) |
| 0x16e | 7001 | MOVEQ #1,D0 |
| 0x170 | a260 | Opaque A-line word |
| 0x172 | 6606 | BNE to 0x17a |
| 0x174 | 33680016000e | MOVE.W $16(A0),$e(A1) |
| 0x17a | defc007a | ADDA.W #$7a,A7 |
| 0x17e | 2049 | MOVEA.L A1,A0 |
| 0x180 | 225f | MOVEA.L (A7)+,A1 |
| 0x182 | 5c4f | ADDQ.W #6,A7 |
| 0x184 | 3ebcea84 | MOVE.W #$ea84,(A7) |
| 0x188 | 4ed1 | JMP (A1) |

### Supported conclusions and limitations

- **[PROVEN, matched block]** The counter starts at 60 and executes 61 word
  clears before DBRA terminates: 122 bytes. The later addition of `0x7a` restores
  that allocation on the shown path. The negative-word branch bypasses it.
- **[PROVEN, matched block]** The source's final `puVar5 + 0x16` equals final
  cleared-stack pointer plus `0x18`: the last `puVar5` precedes its final -2 step.
- **[PROVEN, bytes]** The binary continues after the source truncation and has
  three opaque A-line sites, branches and an additional output write. Therefore
  `halt_baddata` does not establish a real runtime halt.
- **[PROVEN, bytes]** The epilogue uses `JMP (A1)`, with A1 restored from stack;
  it does not independently establish Ghidra's jumptable/callback interpretation.
- **[UNKNOWN]** A-line contracts, stack entry layout, complete calling convention,
  meaning of `$ea84`, record purpose and actual runtime callers. No whole-function
  VERIFIED status and no repair of the truncated C are justified by this pass.

Validation: 32 protected SHA-256 entries unchanged; independent binary analysis
and comment-only C review. Existing expressions, globals, control flow and all
Ghidra warning/stub artifacts are retained in `ID09.decomp.c`.
