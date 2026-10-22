typedef unsigned char   undefined;

typedef unsigned int    uint;
typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned short    ushort;
typedef unsigned char    byte;



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_00000006): ID05.bin 0x06..0xc6 checked against an independent capstone disassembly.
 * Ghidra truncated the body at $A9A0; reconstructed from the bytes: LINK -$c; GetResource(8(A6) long,
 * $c(A6) word); BEQ.W out on NIL; r = *h kept at -8(A6). newLeft: SUB.W widths, EXT.L, DIVS.W #2 to -$a;
 * ADD.W (newLeft - left) to right, MOVE.W newLeft to left. GetMBarHeight is JT $20a (CODE 0 entry
 * 0x0198 seg 9 -> ID09 0x19c MOVE.W $0baa.w into the Pascal result), called three times: newTop =
 * EXT.L((bottomEdge - mbar) - (bottom - top)) DIVS.W #3; d = newTop - top kept at -$c; bottom +=
 * mbar + d; top = mbar + newTop - identical to the C. */
/*
 * Original: FUN_00000006; source: ID05.c:12-19.
 * Recovered name: center_template_rect_on_screen [STRONG INFERENCE].
 * Ghidra truncated at $A9A0 (file 0x14); body rebuilt as C from ID05.bin
 * file 0x06..0xc6 [PROVEN, bytes]. Args: long type [8(A6)],
 * word id [$c(A6)]; no JT entry, callers not yet found.
 *   h = GetResource(type, id); if (!h) return;  r = (Rect *)*h  (top 0, left 2,
 *   bottom 4, right 6)
 *   newLeft = (screenRight(A5-0x167a) - (r.right - r.left)) / 2  (DIVS.W, signed)
 *   r.right += newLeft - r.left;  r.left = newLeft
 *   mbar = JT $20a (ID09 file 0x19c: word $0baa = MBarHeight)
 *   newTop = (screenBottom(A5-0x167c) - mbar - (r.bottom - r.top)) / 3
 *   r.bottom += (newTop - r.top) + mbar;  r.top = mbar + newTop
 * Rect fields per Inside Macintosh; DLOG/ALRT/WIND template use is
 * [HYPOTHESIS]. GetMBarHeight is called three times (re-read each time).
 */
void center_template_rect_on_screen /* Original: FUN_00000006 */ (undefined4 res_type /* param_1: OSType */,short res_id /* param_2 */)

{
  int unaff_A5;
  Handle h;
  short *r;                                     /* -8(A6): Rect top 0, left 2, bottom 4, right 6 */
  short v;                                      /* -$a(A6) */
  short d;                                      /* -$c(A6) */

  h = GetResource(res_type,res_id);             /* $A9A0; type 8(A6), id $c(A6) */
  if (h != (Handle)0) {
    r = (short *)*h;
    v = (short)((int)(short)(*(short *)(unaff_A5 + -0x167a) - (r[3] - r[1])) / 2); /* EXT.L, DIVS.W #2 */
    r[3] = r[3] + (v - r[1]);
    r[1] = v;
    v = (short)((int)(short)((*(short *)(unaff_A5 + -0x167c) - GetMBarHeight()) - (r[2] - r[0])) / 3);
                                                /* JT $20a -> ID09 0x19c (word $0baa); EXT.L, DIVS.W #3 */
    d = v - r[0];
    r[2] = r[2] + (GetMBarHeight() + d);        /* second JT $20a call */
    r[0] = GetMBarHeight() + v;                 /* third JT $20a call */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_000000c8): ID05.bin 0xc8..0x15e checked against an independent capstone disassembly.
 * Ghidra truncated the colour branch at $AA32; reconstructed from the bytes: LINK -$14; SysEnvirons(1,
 * &env at -$10) through JT $1f2 (CODE 0 entry 0x001c seg 9 -> ID09 0x20, $A090 glue), result word
 * popped and dropped; word env+2 to *8(A6); TST.B env+9 / BEQ. Colour: GetGDevice ($AA32) kept at
 * -$14, each store re-derefs **(*gd + $16): words +$c, +$a, +$20 to *$c / *$10 / *$14(A6), BRA to
 * the tail. Mono: (A5-0x167a - A5-0x167e), (A5-0x167c - A5-0x1680), 1. Tail: CLR.W *$18(A6) -
 * identical to the C. */
/*
 * Original: FUN_000000c8; source: ID05.c:23-45.
 * Recovered name: get_machine_screen_fingerprint [STRONG INFERENCE].
 * Ghidra truncated the colour branch (halt_baddata); body rebuilt as C from the bytes.
 * Bytes file 0xc8..0x15e [PROVEN]:
 *   SysEnvirons(1, &env) via JT $1f2 (ID09 dispatcher, sysenvirons_glue_fallback);
 *   *param_1 = env.machineType;
 *   if (env.hasColorQD) {                 [branch Ghidra truncated]
 *     gd = $AA32 (GetGDevice); pm = **(*gd)->gdPMap (+0x16);
 *     *param_2 = pm.bounds.right (+0xc); *param_3 = pm.bounds.bottom (+0xa);
 *     *param_4 = pm.pixelSize (+0x20);
 *   } else {
 *     *param_2 = screenBits.bounds.right - left (A5-0x167a - A5-0x167e);
 *     *param_3 = bottom - top (A5-0x167c - A5-0x1680); *param_4 = 1;
 *   }
 *   *param_5 = 0;
 * Ghidra's local_12 / local_b are env+2 / env+9 (its offsets are relative to
 * the entry stack pointer). Caller [PROVEN]: ID05 file 0x3e4 (code-string
 * builder), whose five words go to pack_fields_to_code_buf68: machine type,
 * width/128, height/128, depth/4, 0 -> a machine-dependent code [STRONG INFERENCE].
 */
void get_machine_screen_fingerprint /* Original: FUN_000000c8 */ (undefined2 *machine /* param_1: out, SysEnvRec machineType */,short *width /* param_2: out, main screen width */,short *height /* param_3: out, main screen height */,undefined2 *depth /* param_4: out, pixel size (1 without Color QuickDraw) */,
                 undefined2 *zero /* param_5: out, always 0 */)

{
  int unaff_A5;
  int *gd;                                      /* -$14(A6): GDHandle */
  undefined1 env[16];                           /* -$10(A6): SysEnvRec */
  int pm;

  SysEnvirons(1,env);                           /* JT $1f2 -> ID09 0x20 ($A090 glue); OSErr discarded */
  *machine = *(undefined2 *)(env + 2);          /* machineType */
  if (env[9] != 0) {                            /* hasColorQD */
    gd = (int *)GetGDevice();                   /* $AA32 */
    pm = **(int **)(*gd + 0x16);                /* *(*gd)->gdPMap (byte offset); re-read before each store */
    *width = *(short *)(pm + 0xc);            /* pmBounds.right */
    *height = *(short *)(pm + 0xa);            /* pmBounds.bottom */
    *depth = *(undefined2 *)(pm + 0x20);      /* pixelSize */
  }
  else {
    *width = *(short *)(unaff_A5 + -0x167a) - *(short *)(unaff_A5 + -0x167e);
    *height = *(short *)(unaff_A5 + -0x167c) - *(short *)(unaff_A5 + -0x1680);
    *depth = 1;
  }
  *zero = 0;
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_00000160): ID05.bin 0x160..0x1ba checked against an independent capstone disassembly.
 * Ghidra truncated the body at the $A9A0 trap; reconstructed from the bytes: LINK -4, CLR.L *8(A6) / *$c(A6) first, GetResource('DATA', $80) result
 * kept at -4(A6), BEQ out on NIL; HNoPurge glue (JT $28a, callee pops), MOVE.L (*h) to *8(A6) and 4(*h) to *$c(A6); HPurge glue (JT $282), ReleaseResource $A9A3; JT slots resolved via CODE 0 entries 0x028a / 0x0280 in segment 9 - identical to the C. */
/*
 * Original: FUN_00000160; source: ID05.c:51-58.
 * Recovered name: read_DATA128_pair [STRONG INFERENCE].
 * Reads/writes two longs at the start of resource 'DATA' 128 (0x80).
 * Bytes [PROVEN]: h = GetResource('DATA', 0x80) ($A9A0); if (h) { JT $28a(h)
 * (ID09 file 0x28e, $A04A HNoPurge); *a = 0; *b = 0; then *a = (*h)[0], *b = (*h)[1]; JT $282(h) (ID09 0x284, $A049
 * HPurge); ReleaseResource(h) ($A9A3) }. Ghidra stopped at $A9A0.
 * Caller [PROVEN]: ID08 file 0x26c via JT $582 (overlay load sequence; the pair
 * then feeds encode_code28_to_buf54 / record_code_index_equals).
 * [HYPOTHESIS] Persistent protection/registration state hidden in generic
 * resource types; meaning of the two longs UNKNOWN. Body reconstructed from the bytes.
 */
void read_DATA128_pair /* Original: FUN_00000160 */ (undefined4 *first /* param_1: out, first long of DATA 128 */,undefined4 *second /* param_2: out, second long */)

{
  Handle h;

  *first = 0;
  *second = 0;
  h = GetResource('DATA',0x80);             /* PEA $44415441.L, MOVE.W #$80, _GetResource $A9A0 */
  if (h != (Handle)0) {
    HNoPurge(h);                               /* JT $28a -> ID09 0x28e _HNoPurge $A04A */
    *first = *(undefined4 *)*h;
    *second = *(undefined4 *)(*h + 4);
    HPurge(h);                                 /* JT $282 -> ID09 0x284 _HPurge $A049 */
    ReleaseResource(h);                        /* $A9A3 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_000001bc): ID05.bin 0x1bc..0x212 checked against an independent capstone disassembly.
 * Ghidra truncated the body at the $A9A0 trap; reconstructed from the bytes: LINK -4, GetResource('DATA', $80) result
 * kept at -4(A6), BEQ out on NIL; HNoPurge glue (JT $28a, callee pops), MOVE.L 8(A6) to (*h) and $c(A6) to 4(*h);
 * ChangedResource $A9AA, WriteResource $A9B0; HPurge glue (JT $282), ReleaseResource $A9A3 - the long arguments Ghidra lost are 8(A6) / $c(A6); JT slots resolved via CODE 0 entries 0x028a / 0x0280 in segment 9 - identical to the C. */
/*
 * Original: FUN_000001bc; source: ID05.c:64-69.
 * Recovered name: write_DATA128_pair [STRONG INFERENCE].
 * Reads/writes two longs at the start of resource 'DATA' 128 (0x80).
 * Bytes [PROVEN]: h = GetResource('DATA', 0x80) ($A9A0); if (h) { JT $28a(h)
 * (ID09 file 0x28e, $A04A HNoPurge); (*h)[0] = arg1 [8(A6)], (*h)[1] = arg2 [$c(A6)]; ChangedResource ($A9AA);
 * WriteResource ($A9B0); JT $282(h) (ID09 0x284, $A049
 * HPurge); ReleaseResource(h) ($A9A3) }. Ghidra stopped at $A9A0.
 * Caller [PROVEN]: ID08 file 0x2c4 via JT $57a. Ghidra lost both long args.
 * [HYPOTHESIS] Persistent protection/registration state hidden in generic
 * resource types; meaning of the two longs UNKNOWN. Body reconstructed from the bytes.
 */
void write_DATA128_pair /* Original: FUN_000001bc */ (undefined4 first /* param_1 */,undefined4 second /* param_2 */)

{
  Handle h;

  h = GetResource('DATA',0x80);             /* PEA $44415441.L, MOVE.W #$80, _GetResource $A9A0 */
  if (h != (Handle)0) {
    HNoPurge(h);                               /* JT $28a -> ID09 0x28e _HNoPurge $A04A */
    *(undefined4 *)*h = first;               /* 8(A6) */
    *(undefined4 *)(*h + 4) = second;         /* $c(A6) */
    ChangedResource(h);                        /* $A9AA */
    WriteResource(h);                          /* $A9B0 */
    HPurge(h);                                 /* JT $282 -> ID09 0x284 _HPurge $A049 */
    ReleaseResource(h);                        /* $A9A3 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_00000214): ID05.bin 0x214..0x26e checked against an independent capstone disassembly.
 * Ghidra truncated the body at the $A9A0 trap; reconstructed from the bytes: LINK -4, CLR.L *8(A6) / *$c(A6) first, GetResource('TEXT', $80) result
 * kept at -4(A6), BEQ out on NIL; HNoPurge glue (JT $28a, callee pops), MOVE.L (*h) to *8(A6) and 4(*h) to *$c(A6); HPurge glue (JT $282), ReleaseResource $A9A3; JT slots resolved via CODE 0 entries 0x028a / 0x0280 in segment 9 - identical to the C. */
/*
 * Original: FUN_00000214; source: ID05.c:75-82.
 * Recovered name: read_TEXT128_pair [STRONG INFERENCE].
 * Reads/writes two longs at the start of resource 'TEXT' 128 (0x80).
 * Bytes [PROVEN]: h = GetResource('TEXT', 0x80) ($A9A0); if (h) { JT $28a(h)
 * (ID09 file 0x28e, $A04A HNoPurge); *a = 0; *b = 0; then *a = (*h)[0], *b = (*h)[1]; JT $282(h) (ID09 0x284, $A049
 * HPurge); ReleaseResource(h) ($A9A3) }. Ghidra stopped at $A9A0.
 * Callers [PROVEN]: ID05 file 0x3f4, 0x458 (code-string builder, routine B in
 * code_dialog_filter header).
 * [HYPOTHESIS] Persistent protection/registration state hidden in generic
 * resource types; meaning of the two longs UNKNOWN. Body reconstructed from the bytes.
 */
void read_TEXT128_pair /* Original: FUN_00000214 */ (undefined4 *first /* param_1: out, first long of TEXT 128 */,undefined4 *second /* param_2: out, second long */)

{
  Handle h;

  *first = 0;
  *second = 0;
  h = GetResource('TEXT',0x80);             /* PEA $54455854.L, MOVE.W #$80, _GetResource $A9A0 */
  if (h != (Handle)0) {
    HNoPurge(h);                               /* JT $28a -> ID09 0x28e _HNoPurge $A04A */
    *first = *(undefined4 *)*h;
    *second = *(undefined4 *)(*h + 4);
    HPurge(h);                                 /* JT $282 -> ID09 0x284 _HPurge $A049 */
    ReleaseResource(h);                        /* $A9A3 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_00000270): ID05.bin 0x270..0x2c6 checked against an independent capstone disassembly.
 * Ghidra truncated the body at the $A9A0 trap; reconstructed from the bytes: LINK -4, GetResource('TEXT', $80) result
 * kept at -4(A6), BEQ out on NIL; HNoPurge glue (JT $28a, callee pops), MOVE.L 8(A6) to (*h) and $c(A6) to 4(*h);
 * ChangedResource $A9AA, WriteResource $A9B0; HPurge glue (JT $282), ReleaseResource $A9A3 - the long arguments Ghidra lost are 8(A6) / $c(A6); JT slots resolved via CODE 0 entries 0x028a / 0x0280 in segment 9 - identical to the C. */
/*
 * Original: FUN_00000270; source: ID05.c:88-93.
 * Recovered name: write_TEXT128_pair [STRONG INFERENCE].
 * Reads/writes two longs at the start of resource 'TEXT' 128 (0x80).
 * Bytes [PROVEN]: h = GetResource('TEXT', 0x80) ($A9A0); if (h) { JT $28a(h)
 * (ID09 file 0x28e, $A04A HNoPurge); (*h)[0] = arg1 [8(A6)], (*h)[1] = arg2 [$c(A6)]; ChangedResource ($A9AA);
 * WriteResource ($A9B0); JT $282(h) (ID09 0x284, $A049
 * HPurge); ReleaseResource(h) ($A9A3) }. Ghidra stopped at $A9A0.
 * Callers [PROVEN]: ID05 file 0x44a (args 0, random_28bit_value) and 0x718.
 * Ghidra lost both long args.
 * [HYPOTHESIS] Persistent protection/registration state hidden in generic
 * resource types; meaning of the two longs UNKNOWN. Body reconstructed from the bytes.
 */
void write_TEXT128_pair /* Original: FUN_00000270 */ (undefined4 first /* param_1 */,undefined4 second /* param_2 */)

{
  Handle h;

  h = GetResource('TEXT',0x80);             /* PEA $54455854.L, MOVE.W #$80, _GetResource $A9A0 */
  if (h != (Handle)0) {
    HNoPurge(h);                               /* JT $28a -> ID09 0x28e _HNoPurge $A04A */
    *(undefined4 *)*h = first;               /* 8(A6) */
    *(undefined4 *)(*h + 4) = second;         /* $c(A6) */
    ChangedResource(h);                        /* $A9AA */
    WriteResource(h);                          /* $A9B0 */
    HPurge(h);                                 /* JT $282 -> ID09 0x284 _HPurge $A049 */
    ReleaseResource(h);                        /* $A9A3 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_000002c8; source: ID05.c:99-104.
 * Recovered name: code_dialog_filter [STRONG INFERENCE].
 * Ghidra truncated at A-line $A873 (file 0x2d0); routine A rebuilt as C
 * below; descriptions from ID05.bin [PROVEN, bytes].
 *
 * Routine A, file 0x2c8..0x3b8 (this Ghidra entry): Pascal-convention
 *   FUNCTION filter(dlg: DialogPtr [$10(A6)]; VAR evt: EventRecord [$c];
 *                   VAR item: INTEGER [$8]): BOOLEAN   (pops 12, result byte)
 *   SetPort(dlg) $A873;
 *   if (word A5-0x2ca++ == 0) {          redraw once after each reset
 *     GetDItem(dlg, 3, &t, &h, &r) $A98D; GetIText(h, text) $A990;
 *     GetDItem(dlg, 1, &t, &h, &r); PenSize(3,3) $A89B; InsetRect(&r,-4,-4) $A8A9;
 *     FrameRoundRect(&r, 16, 16) $A8B0;   default-button outline on item 1
 *     HiliteControl(h, text[0] == 0 ? 255: 0) $A95D   dim OK while field empty
 *   }
 *   if (evt.what == keyDown(3) || evt.what == autoKey(5)) {
 *     A5-0x2ca = 0;
 *     c = byte evt+5 (low byte of message = charCode);
 *     if (c == 0x0d || c == 0x03) { *item = 1; return 1; }      Return / Enter
 *     if (c == 0x1b)              { *item = 2; return 2; }      Escape (byte 2)
 *   }
 *   return false;
 * Trap names / event layout: Inside Macintosh [STRONG INFERENCE].
 *
 * Routine B, file 0x3ba..0x4e2, NOT exported by Ghidra (no separate entry;
 * caller UNKNOWN) [PROVEN bytes; roles HYPOTHESIS]:
 *   args: long *a [8(A6)], char *outA [$c], long *b [$10], char *outB [$14]
 *   copy 0x102 bytes A5-0x2c8 -> local buf; get_machine_screen_fingerprint(&w1..&w5) fills 5 words;
 *   read_TEXT128_pair(a, b);  (FUN_00000214)
 *   if (*a == *b) {
 *     GetVol(buf, &vref) (JT $2ba = ID09 file 0x344, $A014);
 *     s = JT $2fa(buf) (ID09 file 0x432, p2cstr-like);
 *     if (JT $51a(s, A5-0xca) == 0)      (ID02 file 0x2ee, strcmp-like)
 *       write_TEXT128_pair(0, random_28bit_value);  (FUN_00000270)
 *   }
 *   read_TEXT128_pair(a, b);  (FUN_00000214)
 *   if (*b == *a) strcpy(outB, A5-0xd66)   (JT $52a = ID02 file 0x2c8, copy)
 *   else { strcpy(outB, pack_fields_to_code_buf68(w1..w5 as five words; w1 = -2(A6),
 *          pushed last = first C argument));
 *          strcpy(outB + 6, encode_code28_to_buf54(*b)); }
 *   strcpy(outA, encode_long_to_buf40(*a));
 * [HYPOTHESIS] Builds the 6/12-letter codes shown in the protection dialog;
 * the boot-volume name comparison gates a re-randomisation.
 */
/* VERIFIED (ID05::FUN_000002c8): ID05.bin 0x2c8..0x3b8 (routine A) checked against an independent capstone disassembly.
 * Ghidra truncated at $A873; reconstructed from the bytes: LINK -$f2; SetPort(dlg); MOVE.W A5-0x2ca to D0
 * then ADDQ.W #1 (post-increment), BNE.W skips the redraw; GetDItem(dlg, 3, -2 type, -6 handle, -$e rect),
 * GetIText(handle, -$10e); GetDItem(dlg, 1, ...); PenSize(3, 3); InsetRect(-$e, -4, -4); FrameRoundRect(-$e,
 * 16, 16); HiliteControl(handle, TST.B text[0] ? 0 : $ff). evt->what CMPI.W #3 / #5; CLR.W A5-0x2ca; byte
 * evt+5 CMPI.B #$d / #3 -> MOVEQ #1 stored to *item and kept as the result; CMPI.B #$1b -> MOVEQ #2 stored
 * and kept (the result byte is 2, not 1); else MOVEQ #0. Epilogue UNLK, pop return address, LEA 12(A7),
 * MOVE.B D0 to (A7), JMP (A0) - identical to the C. Routine B (0x3ba..0x4e2) has no inventory entry and
 * stays documented in the header only. */
/* Pascal convention (routine A): dlg at $10(A6), evt at $c(A6), item at 8(A6); the callee pops 12 bytes
 * and stores D0's low byte as the BOOLEAN result. */
char code_dialog_filter /* Original: FUN_000002c8 */ (int dlg,short *evt,short *item)

{
  int unaff_A5;
  short calls; /* sVar1: previous value of the call counter A5-0x2ca */
  byte text[256];                               /* -$10e(A6): Str255 */
  undefined1 box[8];                            /* -$e(A6): Rect */
  Handle h;                                     /* -6(A6) */
  short itemType;                               /* -2(A6) */
  char result;

  SetPort(dlg);                                 /* $A873 */
  calls = *(short *)(unaff_A5 + -0x2ca);
  *(short *)(unaff_A5 + -0x2ca) = calls + 1;
  if (calls == 0) {
    GetDItem(dlg,3,&itemType,&h,box);           /* $A98D */
    GetIText(h,text);                           /* $A990 */
    GetDItem(dlg,1,&itemType,&h,box);
    PenSize(3,3);                               /* $A89B */
    InsetRect(box,-4,-4);                       /* $A8A9 */
    FrameRoundRect(box,0x10,0x10);              /* $A8B0 */
    HiliteControl(h,(text[0] == 0) ? 0xff : 0); /* $A95D, item 1's handle */
  }
  if ((evt[0] == 3) || (evt[0] == 5)) {         /* what: keyDown / autoKey */
    *(short *)(unaff_A5 + -0x2ca) = 0;
    if ((*(char *)((int)evt + 5) == '\r') || (*(char *)((int)evt + 5) == '\x03')) {
      *item = 1;
      return 1;
    }
    if (*(char *)((int)evt + 5) == '\x1b') {
      *item = 2;
      return 2;                                 /* D0 still holds MOVEQ #2 */
    }
  }
  result = 0;
  return result;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_000004e4): ID05.bin 0x4e4..0x55e checked against an independent capstone disassembly.
 * Ghidra truncated at $A98D; reconstructed from the bytes: LINK -$12; GetDItem(8(A6) long, $c(A6) word,
 * PEA -$e type, PEA -4 handle, PEA -$c rect); GetIText(handle, A5-0x1c9) $A990; JT $2fa (CODE 0 entry
 * 0x042e seg 9 -> ID09 0x432) on A5-0x1c9, ADDQ.L #4; cursor at -$12, test-at-bottom TST.B / BNE;
 * table byte A5-0x1608[zero-extended c] (ADDA.W of 0..255), BTST #7; if set EXTB.L c pushed as a word
 * to JT $4e2 (entry 0x01ca seg 2 -> ID02 0x1ce ansi_toupper), ADDQ.L #2, MOVE.B D0 back; ADDQ.L #1
 * cursor; returns LEA A5-0x1c9 in D0 - identical to the C. */
/*
 * Original: FUN_000004e4; source: ID05.c:110-115.
 * Recovered name: get_dialog_item_text_upper [STRONG INFERENCE].
 * Ghidra truncated at $A98D; body rebuilt as C. Bytes file 0x4e4..0x55e [PROVEN]:
 *   GetDItem(dlg [8(A6)], item [$c(A6)], &t, &h, &r) $A98D; GetIText(h, A5-0x1c9) $A990;
 *   JT $2fa(A5-0x1c9) (ID09 0x432, Pascal->C in place);
 *   for each byte c: if (ctype table A5-0x1608[c] bit 7) c = JT $4e2(c)
 *     (ID02 FUN_000001ce; toupper-like [HYPOTHESIS]);
 *   return A5-0x1c9 (static buffer, overwritten on each call).
 * Callers [PROVEN]: run_protection_dialog file 0x66c, 0x688, 0x6b6.
 */
char * get_dialog_item_text_upper /* Original: FUN_000004e4 */ (int dlg /* param_1: DialogPtr */,short item_no /* param_2 */)

{
  int unaff_A5;
  short itemType;                               /* -$e(A6) */
  undefined1 box[8];                            /* -$c(A6): Rect */
  Handle item;                                  /* -4(A6) */
  byte *p;                                      /* -$12(A6) */

  GetDItem(dlg,item_no,&itemType,&item,box); /* $A98D */
  GetIText(item,(byte *)(unaff_A5 + -0x1c9));   /* $A990 */
  length_prefixed_bytes_to_c_string_in_place((byte *)(unaff_A5 + -0x1c9));
                                                /* JT $2fa -> ID09 0x432 (FUN_00000432), caller pops */
  for (p = (byte *)(unaff_A5 + -0x1c9); *p != 0; p = p + 1) {
    if ((*(byte *)(unaff_A5 + -0x1608 + (uint)*p) & 0x80) != 0) {
      *p = (byte)ansi_toupper((int)(short)(char)*p); /* JT $4e2 -> ID02 0x1ce (FUN_000001ce), word arg */
    }
  }
  return (char *)(unaff_A5 + -0x1c9);
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID05::FUN_00000560): ID05.bin 0x560..0x726 checked against an independent capstone disassembly.
 * Ghidra truncated at $A874; reconstructed from the bytes: LINK -$272; GetPort(-$272), InitCursor; BSR 0x3ba
 * (a, -$100, b, -$200); record_code_index_equals(*a, -$1fa) BNE.W straight to UNLK (no SetPort);
 * pick_random_protection_challenge(-$262, -$264, -$266); three JT $2f2 calls (CODE 0 entry 0x0400 seg 9 ->
 * ID09 0x404 NumToString glue, callee pops) with MOVEA.W-extended w1 / w2 / w3 into -$220 / -$240 / -$260;
 * center('DLOG', $3e8); GetNewDialog($3e8, nil, -1) $A97C, ExitToShell $A9F4 on nil; ShowWindow; ok = 0, BRA.W
 * to the TST.W ok / BEQ.W loop test. Body: JT $302 (entry 0x0412 seg 9 -> ID09 0x416 C-to-Pascal in place)
 * on -$200; ParamText pushed -$220, -$240, -$260, -$200 (Pascal order: ^0 = s1 ... ^3 = code); DrawDialog;
 * ModalDialog(PEA $562(A5) = JT entry 0x02c4 seg 5 -> 0x2c8 code_dialog_filter, -$268) until item == 1,
 * item 2 -> ExitToShell then ModalDialog again; JT $2fa on -$200; *a = BSR 0xbde(BSR 0x4e4(dlg, 4)); ok =
 * BSR 0x964(w1, w2, w3, BSR 0x4e4(dlg, 3)) (w1 pushed last); on 0: ParamText(JT $302(text 3), nil, nil,
 * nil), center('ALRT', $3e9), Alert($3e9, nil) $A985 result popped. Then DisposDialog $A983;
 * record_code_index_equals(*a, -$1fa) ? write_TEXT128_pair(*a, *b); SetPort(save) - identical to the C. */
/*
 * Original: FUN_00000560; source: ID05.c:121-126.
 * Recovered name: run_protection_dialog [STRONG INFERENCE].
 * Ghidra truncated at $A874; body rebuilt as C. Bytes file 0x560..0x726 [PROVEN].
 * Args: long *a [8(A6)], long *b [$c(A6)]. Caller [PROVEN]: ID08 file 0x298 via
 * JT $572 (overlay load sequence; a/b were read by read_DATA128_pair).
 *   GetPort(&save) $A874; InitCursor $A850;
 *   code-string builder (file 0x3ba; see code_dialog_filter header)
 *     (a, outA=-$100, b, outB=-$200);
 *   if (record_code_index_equals(*a, outB + 6)) return;   already valid: no dialog, port not restored
 *   FUN_000008d6(&w1, &w2, &w3)  -> random challenge from the A5-0xba table;
 *   NumToString (JT $2f2, ID09 0x404) of w1/w2/w3 into s1/s2/s3;
 *   center_template_rect_on_screen('DLOG', 1000);
 *   dlg = GetNewDialog(1000, nil, (WindowPtr)-1) $A97C; if (!dlg) ExitToShell;
 *   ShowWindow(dlg) $A915; ok = 0;
 *   do {
 *     c2pstr(outB) (JT $302, ID09 0x416); ParamText(s1, s2, s3, outB) $A98B;
 *     DrawDialog(dlg) $A981;
 *     do ModalDialog(code_dialog_filter (JT $562), &item) $A991;
 *       while (item != 1 && (item != 2 || (ExitToShell, 1)));   item 2 quits
 *     p2cstr(outB);
 *     *a = decode_code_to_long_b(get_dialog_item_text_upper(dlg, 4));
 *     ok = matcher@0x964(w1, w2, w3, get_dialog_item_text_upper(dlg, 3));
 *     if (!ok) { ParamText(c2pstr(text of item 3), nil, nil, nil);
 *                center_template_rect_on_screen('ALRT', 1001); Alert(1001, nil) $A985; }
 *   ( correction: $A985 is _Alert, not StopAlert = $A986)
 *   } while (!ok);
 *   DisposDialog(dlg) $A983;
 *   if (record_code_index_equals(*a, outB + 6)) write_TEXT128_pair(*a, *b);
 *   SetPort(save) $A873.
 * [STRONG INFERENCE] Manual look-up copy protection: the dialog shows three
 * numbers (w1..w3, e.g. page/line/word) and expects the matching word in item 3
 * and an unlock code in item 4; success sets the 0x964 gate A5-0xc0 used by
 * restore_poisoned_overlay_bytes. Exact UI meaning of fields is HYPOTHESIS.
 */
void run_protection_dialog /* Original: FUN_00000560 */ (int *code_a /* param_1: in/out, first code long */,int *code_b /* param_2: in/out, second code long */)

{
  int unaff_A5;
  int savePort;                                 /* -$272(A6) */
  int dlg;                                      /* -$26e(A6) */
  short ok;                                     /* -$26a(A6) */
  short item;                                   /* -$268(A6) */
  short w3;                                     /* -$266(A6) */
  short w2;                                     /* -$264(A6) */
  short w1;                                     /* -$262(A6) */
  byte s3[32];                                  /* -$260(A6) */
  byte s2[32];                                  /* -$240(A6) */
  byte s1[32];                                  /* -$220(A6) */
  byte outB[256];                               /* -$200(A6) */
  byte outA[256];                               /* -$100(A6) */

  GetPort(&savePort);                           /* $A874 */
  InitCursor();                                 /* $A850 */
  FUN_000003ba(code_a,outA,code_b,outB);      /* routine B, code-string builder (no inventory entry) */
  if (record_code_index_equals(*code_a,(int)(outB + 6)) != 0) {
    return;                                     /* BNE.W to UNLK: the saved port is NOT restored */
  }
  pick_random_protection_challenge(&w1,&w2,&w3);
  NumToString((int)w1,s1);                      /* JT $2f2 -> ID09 0x404 (Pack7 $A9EE glue, callee pops 8) */
  NumToString((int)w2,s2);
  NumToString((int)w3,s3);
  center_template_rect_on_screen(0x444c4f47,1000);   /* 'DLOG' */
  dlg = GetNewDialog(1000,0,-1);                /* $A97C */
  if (dlg == 0) {
    ExitToShell();                              /* $A9F4 */
  }
  ShowWindow(dlg);                              /* $A915 */
  ok = 0;
  while (ok == 0) {
    c2pstr_in_place(outB);                      /* JT $302 -> ID09 0x416, caller pops */
    ParamText(s1,s2,s3,outB);                   /* $A98B: ^0 = w1, ^1 = w2, ^2 = w3, ^3 = code */
    DrawDialog(dlg);                            /* $A981 */
    while (ModalDialog(unaff_A5 + 0x562,&item), item != 1) { /* $A991; filter = JT $562 -> code_dialog_filter */
      if (item == 2) {
        ExitToShell();
      }
    }
    length_prefixed_bytes_to_c_string_in_place(outB); /* JT $2fa -> ID09 0x432 */
    *code_a = decode_code_to_long_b(get_dialog_item_text_upper(dlg,4));
    ok = FUN_00000964(w1,w2,w3,get_dialog_item_text_upper(dlg,3)); /* matcher; Ghidra could not decompile it */
    if (ok == 0) {
      ParamText(c2pstr_in_place(get_dialog_item_text_upper(dlg,3)),0,0,0);
      center_template_rect_on_screen(0x414c5254,0x3e9); /* 'ALRT' */
      Alert(0x3e9,0);                           /* $A985, result discarded */
    }
  }
  DisposDialog(dlg);                            /* $A983 */
  if (record_code_index_equals(*code_a,(int)(outB + 6)) != 0) {
    write_TEXT128_pair(*code_a,*code_b);
  }
  SetPort(savePort);                            /* $A873 */
  return;
}



/* VERIFIED (ID05::FUN_00000728): ID05.bin 0x728..0x744 checked against an independent capstone disassembly
 * (Ghidra address = file offset): MULU.L #$41c64e6d (same low 32 bits as the C's signed multiply), ADDI.L
 * #$3039, store A5-0x6c, BFEXTU -$6c(A5){1:15} = bits 30..16 = (seed << 1) >> 17 - identical to the C. */
/*
 * Original: FUN_00000728; source: ID05.c:130-137.
 * Recovered name: ansi_rand [PROVEN].
 * seed (long A5-0x6c) = seed * 0x41c64e6d + 0x3039 (ANSI C reference LCG,
 * 1103515245 / 12345); returns bits 30..16 (0..32767). Binary file 0x728:
 * MULU.L #$41c64e6d (68020) / ADDI.L #$3039. 32-bit wraparound preserved.
 * Callers: poison_overlay_bytes, ID05.c:251, ID05.c:284-285.
 */
uint ansi_rand /* Original: FUN_00000728 */ (void)

{
  int unaff_A5;
  
  *(int *)(unaff_A5 + -0x6c) = *(int *)(unaff_A5 + -0x6c) * 0x41c64e6d + 0x3039;
  return (uint)(*(int *)(unaff_A5 + -0x6c) << 1) >> 0x11;
}



/* VERIFIED (ID05::FUN_00000746): ID05.bin 0x746..0x752 checked against an independent capstone disassembly:
 * MOVE.L 8(A6),-$6c(A5) - identical to the C. */
/*
 * Original: FUN_00000746; source: ID05.c:141-148.
 * Recovered name: ansi_srand [STRONG INFERENCE].
 * Stores param_1 into the ansi_rand seed (long A5-0x6c). No callers found yet.
 */
void ansi_srand /* Original: FUN_00000746 */ (undefined4 seed /* param_1 */)

{
  int unaff_A5;
  
  *(undefined4 *)(unaff_A5 + -0x6c) = seed;
  return;
}



/* VERIFIED (ID05::FUN_00000754): ID05.bin 0x754..0x7a6 checked against an independent capstone disassembly.
 * LINK -6; dst += 6 (ADDQ.L on the stacked argument); counter word -6 from 0 to 6 (BLT); per pass
 * SUBQ.L #1 dst, DIVSL.L #$1a,D1:D0 (extension 0x0801: remainder in D1), ADDI.L #$41,D1, MOVE.B D1 to
 * *dst, then DIVS.L #$1a,D0 (extension 0x0800: quotient only) stored back to the value argument; after
 * the loop CLR.B 6(dst). D0 keeps the last quotient as the return value (MOVEQ #0 before an empty
 * loop is unreachable since the count is fixed at 6) - identical to the C. */
/*
 * Original: FUN_00000754; source: ID05.c:152-168.
 * Recovered name: encode_base26_6chars [PROVEN].
 * Writes 6 letters 'A'+(v % 26) right-to-left into param_1[0..5], v /= 26
 * each step, then NUL at param_1[6]. Signed arithmetic: binary file 0x76c /
 * 0x784 use 68020 DIVS.L #$1a (remainder in D1, quotient in D0), matching
 * the exported % and /. Negative v would give characters below 'A' (C
 * truncating remainder) - preserved. Return value (last quotient) is a
 * by-product with no proven use.
 * Callers [PROVEN, bytes]: ID05 file 0xb00, 0xb98, 0xbce (ID05.c:300, 332, 354)
 * writing to A5-0x68, A5-0x54, A5-0x40 respectively.
 */
int encode_base26_6chars /* Original: FUN_00000754 */ (char *dst /* param_1: out, 7-byte buffer (6 letters + NUL) */,int value /* param_2: value to encode */)

{
  int quotient; /* iVar1: value / 26, returned */
  short i; /* local_a, -$6(A6): letter counter 0..5 */
  
  dst = dst + 6;
  quotient = 0;
  for (i = 0; i < 6; i = i + 1) {
    dst = dst + -1;
    *dst = (char)(value % 0x1a) + 'A';
    quotient = value / 0x1a;
    value = quotient;
  }
  dst[6] = '\0';
  return quotient;
}



/* VERIFIED (ID05::FUN_000007a8): ID05.bin 0x7a8..0x7f4 checked against an independent capstone disassembly.
 * LINK -6; acc (-4) = 0, index word (-6) = 0, D0 = 0; per pass acc = acc MULU.L #$1a (extension
 * 0x0000, low 32 bits), byte at src + (short)index (MOVEA.W sign-extends), EXTB.L, ADDI.W #$ffbf,
 * EXT.L, ADD.L into acc; six passes (BLT); *out = acc; D0 is left holding the last (short)(c - 'A')
 * term, which is the C's return value - identical to the C. */
/*
 * Original: FUN_000007a8; source: ID05.c:172-187.
 * Recovered name: decode_base26_6chars [PROVEN].
 * *param_2 = sum over 6 chars of acc*26 + (short)((s8)c - 'A'); inverse of
 * encode_base26_6chars for 'A'..'Z' input. Binary: MULU.L #$1a (low 32 bits
 * equal the signed product), EXTB.L, ADDI.W #$ffbf, EXT.L (file 0x7bc..0x7d8).
 * Callers [PROVEN, bytes]: ID05 file 0xb1c, 0xbb4, 0xbea (ID05.c:316, 343, 365).
 */
int decode_base26_6chars /* Original: FUN_000007a8 */ (int src /* param_1: 6-letter code */,int *out_value /* param_2: out, decoded value */)

{
  int digit; /* iVar1: (short)(c - 'A'), returned */
  undefined2 i; /* local_a, -$6(A6): letter index 0..5 */
  undefined4 acc; /* local_8, -4(A6): base-26 accumulator */
  
  acc = 0;
  digit = 0;
  for (i = 0; i < 6; i = i + 1) {
    digit = (int)(short)(*(char *)(src + i) + -0x41);
    acc = digit + acc * 0x1a;
  }
  *out_value = acc;
  return digit;
}



/* VERIFIED (ID05::FUN_000007f6): ID05.bin 0x7f6..0x85c checked against an independent capstone disassembly.
 * Counter word -2 = 0, test-at-bottom loop: TST.L base / BEQ exit, CMPI.W #$c / BLT. Body: ansi_rand
 * zero-extended (SWAP/CLR.W/SWAP), DIVUL.L $c(A6),D1:D0 (extension 0x0001, unsigned remainder in D1),
 * ptr = base + rem; entry = A5-0xb4 + (MULS.W #6 counter): long ptr at +0, MOVE.B (ptr) to +4, then
 * MOVEQ #-1 / MOVE.B to *ptr - identical to the C. */
/*
 * Original: FUN_000007f6; source: ID05.c:191-207.
 * Recovered name: poison_overlay_bytes [STRONG INFERENCE].
 * Inputs: param_1 = base, param_2 = byte count. Output: void.
 * For up to 12 loop passes (stops early if base == 0): offset = ansi_rand
 * (16-bit, zero-extended) % param_2 (68020 DIVUL.L $c(A6),D1:D0 at file 0x80a,
 * remainder in D1); records {ptr (long), original byte} in 6-byte entries of
 * table A5-0xb4[12] (ptr at +0, byte at +4), then overwrites the byte with 0xFF.
 * Caller [PROVEN, bytes]: ID08 file 0x246 JSR $53a(A5) (CODE 0 JT seg5 off
 * 0x7f2) with (A5-0x1006 overlay base, A5-0x1022 overlay code size), directly
 * after the overlay is loaded and relocated.
 * [HYPOTHESIS] Copy-protection booby trap: the overlay stays corrupted unless
 * restore_poisoned_overlay_bytes finds its gate set. Duplicate offsets are
 * possible; reverse-order restore keeps the original byte in that case.
 */
void poison_overlay_bytes /* Original: FUN_000007f6 */ (int base /* param_1: overlay base */,uint size /* param_2: overlay byte count */)

{
  undefined1 *target; /* puVar1: byte chosen for poisoning */
  uint rnd; /* uVar2: ansi_rand result */
  int unaff_A5;
  undefined2 i; /* local_6, -2(A6): table entry 0..11 */
  
  for (i = 0; (base != 0 && (i < 0xc)); i = i + 1) {
    rnd = ansi_rand(); /* Original: FUN_00000728 */
    target = (undefined1 *)(base + (rnd & 0xffff) % size);
    *(undefined1 **)(i * 6 + unaff_A5 + -0xb4) = target;
    *(undefined1 *)(i * 6 + unaff_A5 + -0xb0) = *target;
    *target = 0xff;
  }
  return;
}



/* VERIFIED (ID05::FUN_0000085e): ID05.bin 0x85e..0x8b0 checked against an independent capstone disassembly.
 * TST.W A5-0xbc / TST.L A5-0xc0 into a 0/1 flag (MOVEQ), BEQ out; counter word = 12; loop test reads
 * the old counter, SUBQ.W #1, BGT on the old value, body uses the decremented counter: *(entry.ptr) =
 * entry.byte at A5-0xb4 + 6 * i for i = 11..0 - identical to the C (only the dead local's final value
 * differs: -1 in the binary, 0 in the C). */
/*
 * Original: FUN_0000085e; source: ID05.c:211-232.
 * Recovered name: restore_poisoned_overlay_bytes [STRONG INFERENCE].
 * If word A5-0xbc != 0 or long A5-0xc0 != 0, writes back the 12 saved bytes
 * of table A5-0xb4 in reverse order (11..0). Otherwise does nothing.
 * Caller [PROVEN, bytes]: ID08 file 0x29e JSR $55a(A5) (JT seg5 -> file 0x85e),
 * after the seg5 calls $542, $582, $552, $54a, $532 (conditional) and $572.
 * Gate writers: A5-0xbc via JT $532 stub file 0x8b2 after
 * record_code_index_equals; A5-0xc0 by unexported routine at file 0x964. Note: if neither gate is set, 12 overlay bytes remain 0xFF.
 */
void restore_poisoned_overlay_bytes /* Original: FUN_0000085e */ (void)

{
  short entry; /* sVar1: decremented counter = table entry 11..0 */
  bool armed; /* bVar2: A5-0xbc word or A5-0xc0 long nonzero (restore gate) */
  int unaff_A5;
  undefined2 count; /* local_6, -2(A6): entries left, starts at 12 */
  
  if ((*(short *)(unaff_A5 + -0xbc) == 0) && (*(int *)(unaff_A5 + -0xc0) == 0)) {
    armed = false;
  }
  else {
    armed = true;
  }
  if (armed) {
    count = 0xc;
    while (entry = count + -1, 0 < count) {
      **(undefined1 **)(entry * 6 + unaff_A5 + -0xb4) =
           *(undefined1 *)(entry * 6 + unaff_A5 + -0xb0);
      count = entry;
    }
  }
  return;
}


/*
 * Original: FUN_000008b8; source: ID05.c.
 * Recovered name: init_protection_table [STRONG INFERENCE]. Ghidra did not
 * decompile this entry. Bytes file 0x8b8..0x8d4 [PROVEN]:
 *   LINK; ansi_srand(long $e(A6)) (BSR 0x746); long A5-0xba = $8(A6);
 *   word A5-0xb6 = $c(A6); UNLK; RTS.
 * Caller [PROVEN]: ID08 file 0x25c via JT $542 with (A5-0x1cc4, 0x38,
 * TickCount) -> 56 twelve-byte challenge entries at A5-0x1cc4, RNG seeded
 * from TickCount. See docs/COPY_PROTECTION_FLOW.md.
 */
/* VERIFIED (ID05::FUN_000008b8): ID05.bin 0x8b8..0x8d4 checked against an independent capstone disassembly:
 * LINK #0; seed long at 0xe(A6) passed to BSR ansi_srand; table long at 8(A6) -> A5-0xba; count word at
 * 0xc(A6) -> A5-0xb6; UNLK/RTS - identical to the C reconstructed below. */
void init_protection_table /* Original: FUN_000008b8 */ (undefined1 *table,undefined2 count,undefined4 seed)

{
  int unaff_A5;

  ansi_srand(seed);                            /* BSR 0x746 */
  *(undefined1 **)(unaff_A5 + -0xba) = table;
  *(undefined2 *)(unaff_A5 + -0xb6) = count;
  return;
}


/* VERIFIED (ID05::FUN_000008d6): ID05.bin 0x8d6..0x932 checked against an independent capstone disassembly.
 * ansi_rand zero-extended, DIVU.W A5-0xb6 then SWAP (16-bit unsigned remainder) to word i; three times
 * entry = (MULS.W #$c i) + long A5-0xba, word +6 / +8 / +$a stored to *8 / *$c / *$10(A6) - identical
 * to the C. */
/*
 * Original: FUN_000008d6; source: ID05.c:244-257.
 * Recovered name: pick_random_protection_challenge [STRONG INFERENCE].
 * i = (ansi_rand & 0xffff) % (unsigned word A5-0xb6); copies words +6/+8/+0xa
 * of 12-byte entry i of table *(A5-0xba) to *param_1..*param_3.
 * Caller [PROVEN]: run_protection_dialog file 0x5a6. The same entry words are
 * later checked by the 0x964 matcher.
 */
void pick_random_protection_challenge /* Original: FUN_000008d6 */ (undefined2 *word6 /* param_1: out, entry word +6 [meaning UNKNOWN] */,undefined2 *word8 /* param_2: out, entry word +8 */,undefined2 *word10 /* param_3: out, entry word +0xa */)

{
  uint rnd; /* uVar1: ansi_rand result */
  short index; /* sVar2: entry index, rnd % count word A5-0xb6 */
  int unaff_A5;
  
  rnd = ansi_rand(); /* Original: FUN_00000728 */
  index = (short)((rnd & 0xffff) % (uint)*(ushort *)(unaff_A5 + -0xb6));
  *word6 = *(undefined2 *)(*(int *)(unaff_A5 + -0xba) + index * 0xc + 6);
  *word8 = *(undefined2 *)(*(int *)(unaff_A5 + -0xba) + index * 0xc + 8);
  *word10 = *(undefined2 *)(*(int *)(unaff_A5 + -0xba) + index * 0xc + 10);
  return;
}



/* VERIFIED (ID05::FUN_00000934): ID05.bin 0x934..0x962 checked against an independent capstone disassembly:
 * EXTB.L rec[4] * 20 (MULU.L) + EXTB.L rec[5], CMP.L with param_1, SEQ / NEG.B / EXT.W set only the low word
 * (1 / 0) so D0's high word keeps the sum's high half - Ghidra's CONCAT22 - identical to the C. */
/*
 * Original: FUN_00000934; source: ID05.c:261-268.
 * Recovered name: record_code_index_equals [STRONG INFERENCE].
 * Returns (word) 1 if (signed byte rec[4]) * 20 + (signed byte rec[5]) == n,
 * else 0; upper word of D0 carries the computed sum's high half (Ghidra
 * CONCAT22 matches bytes: EXTB.L / MULU.L #$14 / SEQ / NEG.B / EXT.W).
 * Inputs: param_1 = n (long), param_2 = rec pointer.
 * Callers [PROVEN, bytes]: ID08 file 0x282 and 0x2b2 via JT $54a (seg5 off
 * 0x930). At 0x282 a nonzero result is followed by JT $532 = file 0x8b2,
 * an unexported 2-instruction stub ADDQ.W #1,-$bc(A5); RTS, i.e. it sets
 * the restore_poisoned_overlay_bytes gate A5-0xbc.
 * [HYPOTHESIS] n/rec come from the protection/code-lookup step; the 20 factor
 * suggests a (row, column) pair on a 20-wide grid.
 *
 * The following routine at file 0x964..0xa60 (called by JSR $964(PC) at file 0x69c):
 *   args: word a1 = 8(A6), word a2 = $a(A6), word a3 = $c(A6), char *s = $e(A6)
 *   A5-0xc0 = 0;
 *   for i in 0.. word A5-0xb6 - 1: e = *(long A5-0xba) + 12*i
 *     (entry: long ptr +0, word len +4, words +6/+8/+0xa)
 *     compare from k = len-1 down: (s[k] + (A5-0x2c key[k] & 0x7f)) as byte
 *       == e.ptr[k]   [stored strings are obfuscated by subtracting the key]
 *     if all match && JT $522(s) (seg2 file 0x3e8, length-like) == len
 *        && a1 == e+6 && a2 == e+8 && a3 == e+0xa: A5-0xc0 += 1
 *   return word A5-0xbe
 * A5-0xc0 is the second restore gate. Semantics as a code-entry check is
 * [HYPOTHESIS]; table contents not yet located.
 */
undefined4 record_code_index_equals /* Original: FUN_00000934 */ (int n /* param_1: index to compare */,int rec /* param_2: record pointer */)

{
  int rec_index; /* iVar1: rec[4] * 20 + rec[5] */
  
  rec_index = (int)*(char *)(rec + 5) + *(char *)(rec + 4) * 0x14;
  return CONCAT22((short)((uint)rec_index >> 0x10),(short)(rec_index == n));
}


/* Original: FUN_00000964; source: ID05.c.
 * Recovered name: validate_protection_response [STRONG INFERENCE].
 * VERIFIED (ID05::FUN_00000964): ID05.bin 0x964..0xa60 checked against an independent capstone disassembly:
 * the outer signed-word loop, reverse byte comparison, key mask/add, length check, three word comparisons,
 * match-count increment and final A5-0xbe word return agree with the C reconstructed below. The 68020 EXTB.L
 * opcodes at 0x9a8/0x9b0 are decoded explicitly because Capstone reports them as data in 68000 mode - identical
 * to the C reconstructed below. */
short validate_protection_response /* Original: FUN_00000964 */ (short word6,short word8,short word10,undefined1 *text)

{
  int unaff_A5;
  undefined1 *entry;
  undefined1 *key;
  undefined1 *stored;
  short index;
  short pos;
  short len;

  index = 0;
  *(int *)(unaff_A5 + -0xc0) = 0;
  while (index < *(short *)(unaff_A5 + -0xb6)) {
    key = (undefined1 *)(unaff_A5 + -0x2c);
    entry = *(undefined1 **)(unaff_A5 + -0xba) + index * 0xc;
    len = *(short *)(entry + 4);
    pos = len - 1;
    stored = *(undefined1 **)entry;
    while (pos >= 0) {
      if ((undefined1)((int)(char)text[pos] + ((int)(char)key[pos] & 0x7f)) != stored[pos]) {
        break;
      }
      pos = pos - 1;
    }
    if (((pos < 0) && ((int)ansi_strlen((char *)text) == len)) &&
       ((word6 == *(short *)(entry + 6)) &&
       ((word8 == *(short *)(entry + 8)) && (word10 == *(short *)(entry + 10))))) {
      *(int *)(unaff_A5 + -0xc0) = *(int *)(unaff_A5 + -0xc0) + 1;
    }
    index = index + 1;
  }
  return *(short *)(unaff_A5 + -0xbe);
}


/* VERIFIED (ID05::FUN_00000a62): ID05.bin 0xa62..0xa8e checked against an independent capstone disassembly.
 * BSR ansi_rand; SWAP/CLR.W/SWAP (zero-extend the word); LSL.L #16 saved at -4; second ansi_rand
 * zero-extended, OR.L the saved value, ANDI.L #$0fffffff. ((r1 & 0xffff) << 16 | r2 & 0xffff) &
 * 0x0fffffff equals the C's (r1 & 0xfff) << 16 | (r2 & 0xffff) - identical to the C. */
/*
 * Original: FUN_00000a62; source: ID05.c:278-287.
 * Recovered name: random_28bit_value [STRONG INFERENCE].
 * Returns ((ansi_rand & 0xfff) << 16) | (ansi_rand & 0xffff); since ansi_rand
 * yields 15 bits, the result has 27 significant bits (bit 15 always 0).
 * Caller [PROVEN, bytes]: ID05 file 0x442 (BSR).
 */
uint random_28bit_value /* Original: FUN_00000a62 */ (void)

{
  uint rnd_hi; /* uVar1: first ansi_rand, low 12 bits -> bits 16..27 */
  uint rnd_lo; /* uVar2: second ansi_rand, low 16 bits */
  
  rnd_hi = ansi_rand(); /* Original: FUN_00000728 */
  rnd_lo = ansi_rand(); /* Original: FUN_00000728 */
  return (rnd_hi & 0xfff) << 0x10 | rnd_lo & 0xffff;
}



/* VERIFIED (ID05::FUN_00000a90): ID05.bin 0xa90..0xb0e checked against an independent capstone disassembly.
 * Five words read with MOVEA.W (sign-extended) at 8, $a, $c, $e, $10(A6) = param_1._0_2_, param_1._2_2_,
 * param_2._0_2_, param_2._2_2_, param_3._0_2_. $10 DIVS.W #$200 stored back, clamped to $20 (CMPI.W / BLE);
 * word expression ($a DIVS.W #$80 LSL.W #12) | ($c DIVS.W #$80 LSL.W #8) | ($e DIVS.W #4 LSL.W #5),
 * EXT.L; OR ($8 << 16); OR the clamped word (sign-extended); ANDI.L #$0fffffff; encode_base26_6chars
 * (A5-0x68, v); returns A5-0x68 - identical to the C. */
/*
 * Original: FUN_00000a90; source: ID05.c:291-306.
 * Recovered name: pack_fields_to_code_buf68 [STRONG INFERENCE].
 * Packs five scaled word fields into a 28-bit value and encodes it as 6
 * letters into A5-0x68 (returned): bits 16..27 = param_1 high word; 12..15 =
 * param_1 low / 0x80; 8..11 = param_2 high / 0x80; 5..7 = param_2 low / 4;
 * 0..4 = min(param_3 high / 0x200, 0x20). Ghidra _0_2_/_2_2_ split each 4-byte
 * argument slot into words; actual prototype [UNKNOWN]. Masking/overlap of the
 * OR (e.g. 0x20 sets bit 5) preserved as exported.
 * Inverse (with rescaling): unpack_fields_from_code. Caller: ID05 file 0x498.
 */
int pack_fields_to_code_buf68 /* Original: FUN_00000a90 */ (undefined4 slot1 /* param_1: high word -> bits 16..27, low word / 0x80 -> bits 12..15 [field meanings UNKNOWN] */,undefined4 slot2 /* param_2: high word / 0x80 -> bits 8..11, low word / 4 -> bits 5..7 */,undefined4 slot3 /* param_3: high word / 0x200 (max 0x20) -> bits 0..4 */)

{
  int unaff_A5;
  
  slot3._0_2_ = slot3._0_2_ / 0x200;
  if (0x20 < slot3._0_2_) {
    slot3._0_2_ = 0x20;
  }
  encode_base26_6chars( /* Original: FUN_00000754 */ (char *)(unaff_A5 + -0x68),
               ((int)slot3._0_2_ |
               (int)(short)(slot2._2_2_ / 4 << 5 |
                           slot2._0_2_ / 0x80 << 8 | slot1._2_2_ / 0x80 << 0xc) |
               (int)slot1._0_2_ << 0x10) & 0xfffffff);
  return unaff_A5 + -0x68;
}



/* VERIFIED (ID05::FUN_00000b10): ID05.bin 0xb10..0xb82 checked against an independent capstone disassembly.
 * decode_base26_6chars(param_1, &local); word stores: (local ASR.L #16) & $ffff to *$c(A6); (ASR #12 &
 * $f) ASL #7 to *$10; (ASR #8 & $f) ASL #7 to *$14; (ASR #5 & 7) ASL #2 to *$18; local & $1f to *$1c -
 * identical to the C. */
/*
 * Original: FUN_00000b10; source: ID05.c:310-323.
 * Recovered name: unpack_fields_from_code [STRONG INFERENCE].
 * Decodes a 6-letter code and splits it: *p2 = bits 16..31, *p3 = bits 12..15 << 7,
 * *p4 = bits 8..11 << 7, *p5 = bits 5..7 << 2, *p6 = bits 0..4. Mirrors
 * pack_fields_to_code_buf68 (last field not rescaled by 0x200). No caller found yet.
 */
void unpack_fields_from_code /* Original: FUN_00000b10 */ (int code /* param_1: 6-letter code */,undefined2 *bits16_31 /* param_2: out, bits 16..31 */,undefined2 *bits12_15 /* param_3: out, bits 12..15 << 7 */,undefined2 *bits8_11 /* param_4: out, bits 8..11 << 7 */,
                 undefined2 *bits5_7 /* param_5: out, bits 5..7 << 2 */,ushort *bits0_4 /* param_6: out, bits 0..4 */)

{
  int value; /* local_8, -4(A6): decoded 28-bit value */
  
  decode_base26_6chars( /* Original: FUN_000007a8 */ code,&value);
  *bits16_31 = (short)((uint)value >> 0x10);
  *bits12_15 = (short)((value >> 0xc & 0xfU) << 7);
  *bits8_11 = (short)((value >> 8 & 0xfU) << 7);
  *bits5_7 = (short)((value >> 5 & 7U) << 2);
  *bits0_4 = (ushort)value & 0x1f;
  return;
}



/* VERIFIED (ID05::FUN_00000b84): ID05.bin 0xb84..0xba6 checked against an independent capstone disassembly.
 * MOVE.L #$0fffffff / AND.L 8(A6); push value, PEA -$54(A5); JSR 0x754; returns LEA -$54(A5) in D0 -
 * identical to the C. */
/*
 * Original: FUN_00000b84; source: ID05.c:327-334.
 * Recovered name: encode_code28_to_buf54 [STRONG INFERENCE].
 * encode_base26_6chars(A5-0x54, param_1 & 0x0fffffff); returns A5-0x54.
 * Callers [PROVEN, bytes]: ID05 file 0x4b2; ID08 file 0x276 and 0x2a6 via JT
 * $552. At ID08 0x276 the returned string is passed as `rec` to
 * record_code_index_equals(n, str): letters 5 and 6 (offsets 4, 5) are tested.
 */
int encode_code28_to_buf54 /* Original: FUN_00000b84 */ (uint value /* param_1: masked to 28 bits */)

{
  int unaff_A5;
  
  encode_base26_6chars( /* Original: FUN_00000754 */ (char *)(unaff_A5 + -0x54),value & 0xfffffff);
  return unaff_A5 + -0x54;
}



/* VERIFIED (ID05::FUN_00000ba8): ID05.bin 0xba8..0xbc0 checked against an independent capstone disassembly.
 * PEA -4(A6); push 8(A6); JSR 0x7a8; D0 = -4(A6) - identical to the C. */
/*
 * Original: FUN_00000ba8; source: ID05.c:338-345.
 * Recovered name: decode_code_to_long_a [STRONG INFERENCE].
 * Returns decode_base26_6chars(param_1). No caller found yet.
 */
int decode_code_to_long_a /* Original: FUN_00000ba8 */ (int code /* param_1: 6-letter code */)

{
  int value; /* local_8, -4(A6): decoded value */
  
  decode_base26_6chars( /* Original: FUN_000007a8 */ code,&value);
  return value;
}



/* VERIFIED (ID05::FUN_00000bc2): ID05.bin 0xbc2..0xbdc checked against an independent capstone disassembly.
 * Push 8(A6) unmasked, PEA -$40(A5); JSR 0x754; returns LEA -$40(A5) - identical to the C. */
/*
 * Original: FUN_00000bc2; source: ID05.c:349-356.
 * Recovered name: encode_long_to_buf40 [STRONG INFERENCE].
 * encode_base26_6chars(A5-0x40, param_1) without masking; returns A5-0x40.
 * Caller [PROVEN, bytes]: ID05 file 0x4ce.
 */
int encode_long_to_buf40 /* Original: FUN_00000bc2 */ (int value /* param_1: value to encode */)

{
  int unaff_A5;
  
  encode_base26_6chars( /* Original: FUN_00000754 */ (char *)(unaff_A5 + -0x40),value);
  return unaff_A5 + -0x40;
}



/* VERIFIED (ID05::FUN_00000bde): ID05.bin 0xbde..0xbf6 checked against an independent capstone disassembly.
 * Byte-for-byte the same body as 0xba8 except the JSR displacement - identical to the C. */
/*
 * Original: FUN_00000bde; source: ID05.c:360-367.
 * Recovered name: decode_code_to_long_b [STRONG INFERENCE].
 * Returns decode_base26_6chars(param_1); byte-identical role to
 * decode_code_to_long_a (separate function kept). Caller [PROVEN, bytes]: ID05
 * file 0x674 (result stored through the caller's param at 8(A6)).
 */
int decode_code_to_long_b /* Original: FUN_00000bde */ (int code /* param_1: 6-letter code */)

{
  int value; /* local_8, -4(A6): decoded value */
  
  decode_base26_6chars( /* Original: FUN_000007a8 */ code,&value);
  return value;
}
