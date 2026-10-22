typedef unsigned char   undefined;

typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned char    byte;



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID07::FUN_00000006): ID07.bin 0x06..0x18e checked against an independent capstone disassembly.
 * Body rebuilt from the bytes (Ghidra stopped at the inline switch data 0xda..0xe5). Switch helper JSR
 * $3a(A5) = CODE 0 entry 0x00ba seg 1 -> ID01 0xbe: pops the table address, lo / hi words, value > hi or
 * < lo -> default word, else entry 2 + 2 * (value - lo); jumps to entry address + entry word. Table 0x72,
 * 0x74, default 0x1c (-> 0xfa), 'r' 6 (-> 0xe6 c = $0d), 's' 0x18 (-> 0xfa), 't' 0xa (-> 0xee c = 9); the
 * two case paths ADDQ.W #1 j. Rest: GetResource('STR#', $81), JT $272 HLock (seg 9 0x270), p = *h + 2;
 * i word 1..0x78 (CMPI.W #$79 / BLT.W); len = zero-extended byte; next = p + (MOVEA.W len) + 1; "\p" test on
 * p[1] / p[2] (zero-extended CMPI.W #$5c / #$70) -> ansi_memmove(p + 1, p + 3, len - 2) (JT $4fa -> ID02
 * 0x24a, n pushed first), len -= 2, isC = 0, else isC = 1; j = k = 1, loop while j <= len (signed BLE);
 * p[k++] = c (EXT.L k); len = k - 1; isC ? (memmove(p, p + 1, len), p[len] = 0) : p[0] = low byte of len;
 * long A5-0xf46[i] = p; p = next - identical to the C. */
/*
 * Original: FUN_00000006; source: ID07.c:9-16.
 * Recovered name: load_str129_string_table [STRONG INFERENCE].
 * Ghidra stopped at the inline switch table after the JSR at file 0xd6
 * (bytes 0xda..0xe5 are data, not code); the body below is rebuilt as C from the bytes.
 * Coordinates: ID07.bin file offsets; CODE header is 4 bytes, so jump-table
 * segment offsets map to file offset + 4 (checked for seg 9 / seg 1 targets).
 *
 * Binary file 0x06..0x18e [PROVEN, bytes; Capstone 68000 BE]:
 *   h = GetResource('STR#', 0x81)      CLR.L -(A7); PEA #'STR#'; MOVE.W #$81; $A9A0
 *   JSR $272(A5)(h)                    JT -> seg 9 file 0x270 = HLock glue ($A029)
 *   p = *h + 2                          skip STR# count word (count not read)
 *   for i = 1.. 0x78 (CMPI.W #$79 / BLT):
 *     len = (unsigned) p[0]; next = p + len + 1
 *     if p[1] == '\\' && p[2] == 'p':   explicit Pascal-string marker
 *       JSR $4fa(A5)(p+1, p+3, len-2)  JT -> seg 2 FUN_0000024a (overlap-safe
 *       len -= 2; is_c = 0             memmove(dst, src, n)), drops "\p"
 *     else is_c = 1
 *     escape pass, j (read) = k (write) = 1, while j <= len (signed word):
 *       c = p[j]; if c == '\\': switch p[j+1] via JSR $3a(A5) (seg 1 file
 *       0xbe: table lo=0x72, hi=0x74, default/off words relative to themselves)
 *         'r' -> c = 0x0d, j++    't' -> c = 0x09, j++
 *         's' and out-of-range -> default: c = '\\' kept, next char not consumed
 *       p[k++] = c; j++
 *     len = k - 1
 *     if is_c: memmove(p, p+1, len); p[len] = 0      -> C string at p
 *     else:    p[0] = low byte of len                 -> Pascal string at p
 *     ((long *)(A5 - 0xf46))[i] = p; p = next        slot 0 is never written
 *
 * [STRONG INFERENCE] $A9A0 = _GetResource (Inside Macintosh Resource Manager).
 * Side effects: resource stays loaded and locked; strings are rewritten in
 * place inside the resource handle; A5-0xf46 table gets 120 pointers.
 * [UNKNOWN] Whether the resource always holds >= 120 strings (no bounds check),
 * NULL-handle behaviour (no test before HLock / dereference).
 * Caller: FUN_00000190 (ID07.c:26), sole call site in the exports.
 */
void load_str129_string_table /* Original: FUN_00000006 */ (void)

{
  int unaff_A5;
  Handle h;                                     /* -$18(A6) */
  byte c;                                       /* -$13(A6) */
  byte *next;                                   /* -$12(A6) */
  byte *p;                                      /* -$e(A6) */
  short isC;                                    /* -$a(A6) */
  short j;                                      /* -8(A6): read index */
  short k;                                      /* -6(A6): write index */
  short len;                                    /* -4(A6); its low byte -3(A6) is the Pascal length */
  short i;                                      /* -2(A6) */

  h = GetResource(0x53545223,0x81);             /* 'STR#' 129, $A9A0; no NIL test */
  HLock(h);                                     /* JT $272 -> ID09 0x270 ($A029 glue) */
  p = (byte *)*h + 2;                           /* skip the STR# count word */
  for (i = 1; i < 0x79; i = i + 1) {
    len = (short)(ushort)*p;
    next = p + len + 1;
    if ((p[1] == '\\') && (p[2] == 'p')) {
      ansi_memmove(p + 1,p + 3,(int)len + -2);  /* JT $4fa -> ID02 0x24a: drop the "\p" marker */
      len = len + -2;
      isC = 0;
    }
    else {
      isC = 1;
    }
    k = 1;
    for (j = 1; j <= len; j = j + 1) {
      if (p[j] == '\\') {
        switch (p[j + 1]) {                     /* JSR $3a(A5) -> ID01 0xbe; table lo 'r', hi 't' */
        case 'r':
          c = 0x0d;
          j = j + 1;
          break;
        case 't':
          c = 0x09;
          j = j + 1;
          break;
        default:                                /* includes 's': backslash kept, next char not consumed */
          c = p[j];
          break;
        }
      }
      else {
        c = p[j];
      }
      p[k] = c;
      k = k + 1;
    }
    len = k + -1;
    if (isC == 0) {
      *p = (byte)len;                           /* Pascal string */
    }
    else {
      ansi_memmove(p,p + 1,(int)len);           /* C string */
      p[len] = 0;
    }
    *(byte **)(unaff_A5 + -0xf46 + (int)i * 4) = p; /* slot 0 never written */
    p = next;
  }
  return;
}



/* VERIFIED (ID07::FUN_00000190): ID07.bin file 0x190..0x268 (ID07 maps Ghidra address = file offset;
 * 4-byte CODE header) checked against an independent capstone disassembly: jsr $6(pc) to
 * load_str129_string_table, then four copy loops from the A5-0xf46 table (21 from slot 2 into A5-0x221e,
 * 6 from 0x5e into A5-0xffe, 6 from 100 into A5-0xfae, 10 from 0x6a into A5-0xf86; ext.l word index, the
 * first loop's cmpi.w #$14 / ble = the C's < 0x15, the undefined2 index only takes 0..20) - identical to
 * the C. */
/*
 * Original: FUN_00000190; source: ID07.c:20-44.
 * Recovered name: init_string_pointer_groups [STRONG INFERENCE].
 * Status: RENAMED. Exported C matches binary file 0x190..0x268 [PROVEN, bytes]:
 * JSR $6(PC) then four LEA d16(A5) copy loops of longwords.
 * Input: none (A5 world). Output: void.
 * Effect: loads STR# 129 (load_str129_string_table) and copies pointers from
 * the 120-slot table at A5-0xf46 into four smaller A5 pointer arrays:
 *   A5-0x221e[0..20]  <- slots   2..22  (21 entries)
 *   A5-0x0ffe[0..5]   <- slots  94..99  (6)
 *   A5-0x0fae[0..5]   <- slots 100..105 (6)
 *   A5-0x0f86[0..9]   <- slots 106..115 (10)
 * Slots 1, 23..93 and 116..120 are not copied here.
 * Caller [PROVEN, bytes]: ID02.bin file 0x2c0a JSR $592(A5) inside the
 * truncated FUN_00002bbc; CODE 0 entry A5+0x592 = seg 7 off 0x18c (= file 0x190).
 * Readers [PROVEN, bytes; meaning UNKNOWN]: ID04.bin 0x22e2 reads A5-0x221e[0];
 * ID04.c:711 indexes A5-0x0ffe by a record word at +0x22 and passes the
 * string to JT routines $2fa/$52a/$512; ID04 LEAs of -0xfae and -0xf86 at
 * file 0x131a, 0x1cba, 0x1d14, 0x2aac.
 * [UNKNOWN] Semantic category of each group (names, messages, menus...).
 * Note: loop 1 tests local_6 < 0x15; the binary uses CMPI.W #$14 / BLE,
 * which is equivalent for the signed word counter.
 */
void init_string_pointer_groups /* Original: FUN_00000190 */ (void)

{
  int unaff_A5;
  undefined2 i; /* local_6, -2(A6): copy index within each group */

  load_str129_string_table(); /* Original: FUN_00000006; binary JSR $6(PC) at file 0x194 */
  for (i = 0; i < 0x15; i = i + 1) {
    *(undefined4 *)(i * 4 + unaff_A5 + -0x221e) =
         *(undefined4 *)((short)(i + 2) * 4 + unaff_A5 + -0xf46);
  }
  for (i = 0; i < 6; i = i + 1) {
    *(undefined4 *)(i * 4 + unaff_A5 + -0xffe) =
         *(undefined4 *)((short)(i + 0x5e) * 4 + unaff_A5 + -0xf46);
  }
  for (i = 0; i < 6; i = i + 1) {
    *(undefined4 *)(i * 4 + unaff_A5 + -0xfae) =
         *(undefined4 *)((short)(i + 100) * 4 + unaff_A5 + -0xf46);
  }
  for (i = 0; i < 10; i = i + 1) {
    *(undefined4 *)(i * 4 + unaff_A5 + -0xf86) =
         *(undefined4 *)((short)(i + 0x6a) * 4 + unaff_A5 + -0xf46);
  }
  return;
}


