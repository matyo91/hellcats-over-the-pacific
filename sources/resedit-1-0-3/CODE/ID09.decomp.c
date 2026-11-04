typedef unsigned char   undefined;

typedef unsigned char    byte;
typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;


ushort DAT_0000028e;
undefined DAT_00000b22;
char DAT_0000021e;
char DAT_00000291;
byte DAT_000001fb;
int DAT_000002dc;
undefined2 DAT_00000210;
undefined DAT_000003f6;
undefined DAT_00000a58;
char DAT_216e0017;
char DAT_216e0016;
undefined DAT_00000059;

/* Readable global names (readability pass; the Ghidra name stays the real symbol) */
#define kbd_type_table_end DAT_00000059 /* LEA $59(PC): one past the in-segment KbdType table 0x54..0x58 (03 13 0b 02 01), scanned backwards */

// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000000cc)
// WARNING: Globals starting with '_' overlap smaller symbols at the same address

/*
 * Original: FUN_00000048; source: ID09.c:26-103.
 * Recovered name: sysenvirons_glue_fallback [STRONG INFERENCE].
 * Exported body annotated originally; discrepancies resolved by the rebuilt body below.
 * Confidence: [PROVEN] exported-C control flow; [UNKNOWN] selector meanings.
 * Input: param_1 points to writable storage for at least eight undefined2 words
 * in the analyzed block (16 bytes under the original 16-bit word model).
 * Output: void; clears eight words, sets word 0 to 1, and classifies word 1.
 * Block dependencies: DAT_216e0017, DAT_216e0016, DAT_0000028e,
 * (short)_DAT_00000b22. No direct callee in this block; no direct caller found
 * in the ten original C exports, and none in the bytes: no branch to 0x48 in ID09, no jump-table
 * slot naming it [PROVEN, tools/decomp/xrefs.py]; an indirect call through a computed address
 * remains possible.
 * Field-population block also reads DAT_0000021e, DAT_00000059,
 * DAT_00000291, DAT_000001fb, DAT_000002dc and DAT_00000210.
 * Later code reads _DAT_000003f6 and _DAT_00000a58; it writes additional
 * fields/stack storage and ends in unresolved control flow.
 * Unknown: record purpose, field names, global identities, plain-char signedness,
 * aliasing, overlapping-global widths, discarded block and terminal call/trap behavior.
 * Binary selector evidence: file 0x6c loads A0 from absolute address $02ae;
 * subsequent byte tests use +8/+9, not literal addresses DAT_216e0016/17.
 * Those labels match the longword at physical file 0x2ae plus 8/9, suggesting
 * erroneous constant propagation across file/runtime memory (STRONG INFERENCE).
 * Original expressions remain unchanged. See docs/ID09_SELECTOR_ANALYSIS.md
 * and docs/ID09_TERMINAL_ANALYSIS.md; whole-function semantics are unverified.
 *
 *  proposed name: sysenvirons_glue_fallback [STRONG INFERENCE].
 * Not applied to the identifier yet (no call sites in the exports to update).
 * Evidence: 16-byte record (8 words) matching Inside Macintosh SysEnvRec
 * (environsVersion=1 @0, machineType @2, systemVersion @4, processor @6,
 * hasFPU @8, hasColorQD @9, keyBoardType @0xa, atDrvrVersNum @0xc,
 * sysVRefNum @0xe); reads of documented low-memory globals $28e (ROM85),
 * $b22 (HWCfgFlags), $12f (CPUFlag), $2ae (ROMBase), $21e (KbdType),
 * $291 (PortBUse), $1fb (SPConfig), $2dc (ABusVars), $210 (BootDrive),
 * $3f6 (FSFCBLen), $a58 (SysMap); result word 0xea84 = -5500 = envNotPresent.
 * The address-to-name mapping comes from external Toolbox documentation,
 * not from this binary; behavior vs. Apple's actual glue is not validated.
 *
 *  dispatcher evidence [PROVEN, bytes; trap names from docs]:
 * file 0x20 TST.W $28e.w / BMI -> 0x48 (this fallback); else 0x26 MOVE.W #$90,D0;
 * 0x2a A-line $A346 (GetOSTrapAddress); 0x2e MOVE.W #$9f,D0; 0x32 $A746
 * (GetToolTrapAddress, $9F = _Unimplemented); 0x34 CMPA.L / BEQ -> 0x48.
 * Otherwise 0x38..0x46 pops return, record pointer (A0) and version word (D0),
 * executes $A090 (_SysEnvirons) and stores D0 into the Pascal result slot.
 * So this body runs only when the SysEnvirons trap is absent; this justifies
 * the rename. The preamble 0x00..0x47 is not exported as a Ghidra function.
 */
/* VERIFIED (ID09::FUN_00000048): ID09.bin 0x48..0x188 checked against an independent capstone disassembly.
 * Body rebuilt from the bytes; resolves the open discrepancies listed in the header: (1) DAT_216e0016/17
 * are MOVEA.L $2ae.w,A0 then $8(A0) / $9(A0); (2) the CPUFlag path 0xc4..0xd4 (CMPI.B #2 / BGT, MOVE.B,
 * ADDQ.W #1, MOVE.B to +7) is present; (3) the 0x13a..0x17a block: 61 CLR.W -(A7), $18 = $a58.w, MOVEQ #8
 * $A260, BNE; $16 = $34, $A207, BNE; $30 = $5a, $1c = #'ERIK', MOVEQ #1 $A260, BNE; +$e = $16; ADDA.W #$7a;
 * (4) the 'jumptable' at 0x188 is the Pascal return: A0 = A1, pop return address to A1, ADDQ.W #6,A7,
 * MOVE.W #$ea84,(A7), JMP (A1). Machine-type tree, byte gates (+8 BTST #4 of $b22, +9 unsigned
 * CMPI.W #$3fff / BHI), keyboard DBEQ scan, $291 / $1fb gate and $210 copy are otherwise as before -
 * identical to the C. */
/* Pascal convention: FUNCTION SysEnvirons(versionRequested: INTEGER; VAR theWorld: SysEnvRec): OSErr.
 * theWorld at 4(A7), versionRequested at 8(A7) (never read), result word at $a(A7); entered by branch
 * from the dispatcher at 0x20 with the caller's frame untouched. Low-memory names per Inside Macintosh
 * [STRONG INFERENCE]; addresses and widths [PROVEN, bytes]. */
short sysenvirons_glue_fallback /* Original: FUN_00000048 */ (short versionRequested,undefined2 *theWorld /* param_1: VAR SysEnvRec, 8 words */)

{
  short count; /* sVar2: DBRA counter (clear loop, keyboard scan = keyBoardType - 1, pb clear) */
  undefined2 *word; /* puVar3: clear-loop cursor over theWorld */
  char *rom;
  char *kbd_entry; /* pcVar4: KbdType table cursor */
  undefined1 pb[0x7a];                          /* 61 words cleared on the stack (CLR.W -(A7) / DBRA) */

  count = 7;                                    /* MOVE.W #$10,D0; ASR.W #1; SUBQ.W #1 */
  word = theWorld;
  do {
    *word = 0;
    count = count + -1;
    word = word + 1;
  } while (count != -1);
  *theWorld = 1;                                 /* environsVersion */
  rom = *(char **)0x2ae;                        /* ROMBase; Ghidra's DAT_216e0016/17 were rom[8] / rom[9] */
  theWorld[1] = 0xfffe;                          /* machineType: envXL */
  if (rom[9] != -1) {
    if (rom[8] < 1) {
      theWorld[1] = 0xffff;                      /* envMac */
      if (-1 < *(short *)0x28e) {               /* ROM85 */
        theWorld[1] = 1;                         /* env512KE */
        if (*(short *)0xb22 < 0) {              /* HWCfgFlags bit 15 */
          theWorld[1] = 2;                       /* envMacPlus */
        }
      }
    }
    else {
      theWorld[1] = 0;
      if (rom[8] < 3) {
        if (rom[8] == 2) {
          theWorld[1] = 3;                       /* envSE */
        }
        else {
          theWorld[1] = 4;                       /* envMacII */
        }
      }
    }
  }
  theWorld[2] = 0;                               /* systemVersion (second clear kept) */
  if (*(char *)0x12f < 3) {                     /* CPUFlag, signed byte; path Ghidra dropped */
    *(char *)((int)theWorld + 7) = *(char *)0x12f + 1; /* processor low byte (ADDQ.W, MOVE.B) */
  }
  if ((-1 < *(short *)0x28e) && ((*(byte *)0xb22 & 0x10) != 0)) { /* BTST #4 of byte $b22 = word bit 12 */
    *(undefined1 *)(theWorld + 4) = 1;           /* hasFPU byte */
  }
  if (*(ushort *)0x28e < 0x4000) {              /* CMPI.W #$3fff / BHI: unsigned */
    *(undefined1 *)((int)theWorld + 9) = 1;      /* hasColorQD byte */
  }
  kbd_entry = &kbd_type_table_end;                       /* LEA $59(PC): in-segment table 0x54..0x58 = 03 13 0b 02 01 */
  count = 4;
  do {
    kbd_entry = kbd_entry + -1;
    if (*(char *)0x21e == *kbd_entry) break;       /* KbdType; CMP.B -(A0) / DBEQ */
    count = count + -1;
  } while (count != -1);
  theWorld[5] = count + 1;                       /* keyBoardType */
  if ((-1 < *(char *)0x291) && ((*(byte *)0x1fb & 0xf) == 1)) { /* PortBUse, SPConfig */
    *(undefined1 *)((int)theWorld + 0xd) = *(undefined1 *)(*(int *)0x2dc + 7); /* ABusVars+7 -> atDrvrVersNum */
  }
  theWorld[7] = *(undefined2 *)0x210;            /* BootDrive -> sysVRefNum */
  if (-1 < *(short *)0x3f6) {                   /* FSFCBLen >= 0: HFS present */
    theWorld[7] = 0;
    for (count = 0x3c; count != -1; count = count + -1) {
      *(undefined2 *)(pb + count * 2) = 0;
    }
    *(undefined2 *)(pb + 0x18) = *(undefined2 *)0xa58;         /* ioRefNum = SysMap */
    if (HFSDispatch(pb,8) == 0) {                              /* MOVEQ #8, $A260: PBGetFCBInfo */
      *(undefined2 *)(pb + 0x16) = *(undefined2 *)(pb + 0x34); /* ioVRefNum = ioFCBVRefNum */
      if (PBHGetVInfo(pb) == 0) {                              /* $A207 */
        *(undefined4 *)(pb + 0x30) = *(undefined4 *)(pb + 0x5a); /* ioWDDirID = ioVFndrInfo[0] */
        *(undefined4 *)(pb + 0x1c) = 0x4552494b;               /* ioWDProcID = 'ERIK' */
        if (HFSDispatch(pb,1) == 0) {                          /* MOVEQ #1, $A260: PBOpenWD */
          theWorld[7] = *(undefined2 *)(pb + 0x16);             /* sysVRefNum = working directory */
        }
      }
    }
  }                                             /* ADDA.W #$7a,A7 */
  return -0x157c;                               /* MOVE.W #$ea84 to the result slot after popping 6
                                                   argument bytes, JMP (A1): envNotPresent */
}



// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_000002a6; source: ID09.c:107-114.
 * Recovered name: fsopen_glue [STRONG INFERENCE].
 * Status: RENAMED. The exported body is only Ghidra's truncation artifact:
 * A-line word $A000 at file 0x2c6 was treated as bad instruction data.
 * halt_baddata is retained unchanged; the real body is described below
 * from bytes and is NOT reconstructed as executable C (trap ABI is external).
 *
 * Binary file 0x2a6..0x2dc [PROVEN, bytes; Capstone 68000 BE]:
 *   LINK A6,#-$32; LEA -$32(A6),A0      50-byte local parameter block
 *   MOVE.L $e(A6),$12(A0)                arg (long)  -> block +0x12
 *   MOVE.W $c(A6),$16(A0)                arg (word)  -> block +0x16
 *   CLR.B $1a(A0); CLR.B $1b(A0); CLR.L $1c(A0)
 *   $A000                                 A-line trap, A0 = block
 *   MOVEA.L $8(A6),A1; MOVE.W $18(A0),(A1)  block +0x18 -> *VAR arg
 *   MOVE.W D0,$12(A6)                    D0 -> Pascal function result slot
 *   UNLK; pop return; ADDA.W #$a,A7; JMP (A0)   callee pops 10 arg bytes
 *
 * [STRONG INFERENCE, Inside Macintosh File Manager]: $A000 = _Open; the
 * 50-byte block is an IOParam (ioNamePtr +0x12, ioVRefNum +0x16,
 * ioRefNum +0x18, ioVersNum +0x1a, ioPermssn +0x1b, ioMisc +0x1c). Matches
 * FUNCTION FSOpen(fileName: Str255; vRefNum: INTEGER; VAR refNum: INTEGER): OSErr;
 * (args 4+2+4 = 10 bytes, result word at 8+10 = $12(A6)). Permission is fsCurPerm (0).
 *
 * Neighbouring unexported glue in ID09.bin (HYPOTHESIS, same IOParam pattern):
 * 0x2de FSClose ($A001), 0x2fa/0x2fe FSRead/FSWrite ($A002/$A003, D1 selects),
 * 0x344 GetVol ($A014), 0x368 GetEOF ($A011), 0x38c GetFPos ($A018).
 * Callers: none in the exports (inter-segment calls go via the jump table): slot $2a2, used by
 * ID08 load_overlay_from_resource, JSR $2a2(A5) at 0x28 and 0x44 [PROVEN, tools/decomp/xrefs.py].
 */
/* VERIFIED (ID09::FUN_000002a6): ID09.bin 0x2a6..0x2dc checked against an independent capstone disassembly
 * (ID09 maps Ghidra address = file offset): Pascal glue FSOpen(fileName, vRefNum, VAR refNum): OSErr -
 * arguments at $e / $c / $8(A6) (pushed left to right), a 50-byte IOParam at -$32(A6) with ioNamePtr
 * +0x12, ioVRefNum +0x16, ioVersNum +0x1a = 0, ioPermssn +0x1b = 0 (fsCurPerm), ioMisc +0x1c = 0,
 * _Open ($A000) with A0 = &pb, *refNum = ioRefNum (+0x18), D0 -> result slot $12(A6), callee pops the
 * 10 argument bytes (ADDA.W #$a,A7; JMP (A0)) - identical to the C (reconstructed from the bytes; the
 * earlier halt_baddata was Ghidra's truncation at the A-line trap). */
short fsopen_glue /* Original: FUN_000002a6 */ (Str255 *fileName,short vRefNum,short *refNum)

{
  IOParam pb;                    /* -$32(A6), 50 bytes */
  short err;

  pb.ioNamePtr = fileName;       /* +0x12 */
  pb.ioVRefNum = vRefNum;        /* +0x16 */
  pb.ioVersNum = 0;              /* +0x1a */
  pb.ioPermssn = 0;              /* +0x1b fsCurPerm */
  pb.ioMisc = 0;                 /* +0x1c */
  err = PBOpenSync((ParmBlkPtr)&pb); /* _Open $A000, A0 = &pb, D0 = result */
  *refNum = pb.ioRefNum;         /* +0x18 */
  return err;                    /* MOVE.W D0,$12(A6) */
}



// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_000003c2; source: ID09.c:118-125.
 * Recovered name: swapmmumode_glue [STRONG INFERENCE].
 * Status: RENAMED. Exported body is Ghidra's truncation at A-line $A05D;
 * halt_baddata is retained, the real body is described here only.
 *
 * Binary file 0x3c2..0x3d4 [PROVEN, bytes; Capstone 68000 BE]:
 *   MOVEA.L 4(A7),A0; MOVE.B (A0),D0     load byte through VAR pointer
 *   $A05D                                 A-line trap, mode in D0.B
 *   MOVEA.L 4(A7),A0; MOVE.B D0,(A0)     store returned D0.B back
 *   MOVEA.L (A7)+,A0; ADDQ.W #4,A7; JMP (A0)   callee pops 4 arg bytes
 * [STRONG INFERENCE, Inside Macintosh OS Utilities]: $A05D = _SwapMMUMode;
 * matches PROCEDURE SwapMMUMode(VAR mode: SignedByte) (24/32-bit addressing).
 *
 * Following unexported glue: 0x3d6/0x3dc push selectors 10/12 and call $ADED
 * (Pack6 auto-pop: IUMagString / IUMagIDString) [PROVEN, bytes; block below];
 * 0x404 NumToString via $A9EE (Pack7, selector 0); 0x416 in-place C->Pascal
 * string conversion (c2pstr-like) (HYPOTHESIS). Callers: none in the exports, but in the bytes
 * 0x404 is slot $2f2 (3 JSRs, ID05 from 0x5b8), 0x416 slot $302 (13 JSRs, ID02 and ID04),
 * 0x3d6 slot $2ea (ID04 0x1054, rank_pilots_by_score) and 0x3dc has no slot and no reference [PROVEN, tools/decomp/xrefs.py].
 */
/* Unexported functions at ID09 offsets 0x3d6 and 0x3dc (not in Ghidra's export; Pascal glue).
 * Recovered names (comment only): iucompstring_glue (0x3d6, jump-table slot $2ea) and
 * iuequalstring_glue (0x3dc, no slot) [STRONG INFERENCE: Inside Macintosh, International
 * Utilities]. Bytes 0x3d6..0x403 [PROVEN]: MOVE.W #10,D2 (0x3d6; BRA to the shared tail) or
 * MOVE.W #12,D2 (0x3dc); A1 = 4(A7) (the second string), A0 = 8(A7) (the first); D0 / D1 =
 * their length bytes (MOVE.B (A0)+ / (A1)+, zero-extended), the advanced pointers stored back
 * into the two argument slots; the return address popped, then aLen, bLen and the selector
 * pushed and the return address again; $ADED (_Pack6 with auto-pop) returns straight to the
 * caller, its INTEGER result in the slot the caller reserved:
 *
 *   FUNCTION IUCompString(aStr, bStr: Str255): INTEGER;
 *     = IUMagString(@aStr[1], @bStr[1], Length(aStr), Length(bStr))    (selector 10)
 *   FUNCTION IUEqualString(aStr, bStr: Str255): INTEGER;
 *     = IUMagIDString(@aStr[1], @bStr[1], Length(aStr), Length(bStr))  (selector 12)
 *
 * Callers: ID04 rank_pilots_by_score (JT $2ea: pilots of equal score ordered by name). The game
 * runtime answers IUCompString in godot/hellcats/toolbox/toolbox.gd iu_comp_string.
 */
/* VERIFIED (ID09::FUN_000003c2): ID09.bin 0x3c2..0x3d4 checked against an independent capstone disassembly:
 * Pascal glue SwapMMUMode(VAR mode: SignedByte) - D0.B = *mode, _SwapMMUMode ($A05D), *mode = D0.B,
 * callee pops the 4-byte argument (ADDQ.W #4,A7; JMP (A0)) - identical to the C (reconstructed from the
 * bytes; the earlier halt_baddata was Ghidra's truncation at the A-line trap). */
void swapmmumode_glue /* Original: FUN_000003c2 */ (char *mode)

{
  char d0;

  d0 = *mode;                    /* MOVEA.L 4(A7),A0; MOVE.B (A0),D0 */
  d0 = SwapMMUMode_trap(d0);     /* _SwapMMUMode $A05D: D0.B in, previous mode out */
  *mode = d0;                    /* MOVE.B D0,(A0) */
  return;
}



/* VERIFIED (ID09::FUN_00000432): ID09.bin 0x432..0x44a checked against an independent capstone disassembly:
 * MOVEQ #0,D0; MOVE.B (A0),D0 (zero-extended count), BRA to DBRA D0 over MOVE.B 1(A0),(A0)+ (forward
 * overlapping copy, a zero count copies nothing), CLR.B (A0), D0 = the original pointer, RTS (C
 * convention, caller pops) - identical to the C (the ushort pre-decrement with the 0xffff sentinel is the
 * DBRA). */
/*
 * Original: FUN_00000432; source: ID09.c:129-143.
 * Recovered name: length_prefixed_bytes_to_c_string_in_place
 * Confidence: [STRONG INFERENCE] string convention; [PROVEN] C byte transform.
 * Input: writable buffer of at least buffer[0] + 1 bytes; first byte is count.
 * Output: original buffer pointer; count payload bytes shifted left one byte,
 * followed by a zero byte. Embedded zero bytes are copied, not skipped.
 * Side effects: writes only buffer[0..initial_count]; no global accesses.
 * Known callers: none found in the ten original C exports; in the bytes it is jump-table slot $2fa,
 * with 17 JSR $2fa(A5) uses in ID02 and ID04 (e.g. ID02 0x1dca, run_duty_roster_dialog 0x95a /
 * 0x964) [PROVEN, tools/decomp/xrefs.py].
 * Known callees: none.
 * Evidence: ID09.c:132-141 zero-extends the byte count, copies forward from
 * cursor[1], then writes zero:142 returns the original pointer.
 * Local mapping: param_1 -> buffer; uVar1 -> remaining_count;
 * pbVar2 -> write_cursor.
 * Unknown: actual callers and encoding. Binary mapping and ABI now verified (see the VERIFIED note).
 */
byte * length_prefixed_bytes_to_c_string_in_place(byte *buffer)

{
  ushort remaining_count;
  byte *write_cursor;
  
  remaining_count = (ushort)*buffer;
  write_cursor = buffer;
  /* Pre-decrement wraps a zero count to 0xffff: zero-length copies nothing. */
  while (remaining_count = remaining_count - 1, remaining_count != 0xffff) {
    /* Forward copy preserves the unread byte despite overlapping ranges. */
    *write_cursor = write_cursor[1];
    write_cursor = write_cursor + 1;
  }
  *write_cursor = 0;
  return buffer;
}


