typedef unsigned char   undefined;

typedef unsigned char    byte;
typedef unsigned int    uint;
typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned long long    undefined8;
typedef unsigned short    ushort;


int DAT_00000904;

/* Readable global names (readability pass; the Ghidra name stays the real symbol) */
#define CurrentA5 DAT_00000904 /* low-memory global $0904: the application's A5 world */
#define vbl_ch0_a5_cache DAT_000039c4 /* long inside the code of vbl_sound_handler_ch0_unrolled: A5 cached on the first call */
#define vbl_ch0_variant_a5_cache DAT_00003aca /* long inside the code of vbl_sound_handler_ch0_variant: A5 cached on the first call */
#define vbl_two_channel_a5_cache DAT_00003be0 /* long inside the code of vbl_sound_handler_two_channel: A5 cached on the first call */
undefined4 DAT_00000904;
short DAT_00000baa;
int DAT_000039c4;
undefined DAT_66fa4e75;
undefined1 DAT_66fa4e77;
undefined DAT_66fa4e79;
int DAT_00003aca;
undefined DAT_66fa4e7b;
int DAT_00003be0;
char DAT_66fa4e77;
undefined FUN_00000196;
undefined2 DAT_00000baa;

/* VERIFIED (ID02::FUN_0000001e): ID02.bin 0x1e..0x36 checked against an independent capstone disassembly.
 * TST.L 8(A6) / BGE, NEG.L - identical to the C. */
/*
 * Original: FUN_0000001e; source: ID02.c:26.
 * Recovered name: abs_long [STRONG INFERENCE].
 * Exported C complete: signed absolute value (INT_MIN unchanged by wraparound).
 * JT $4da; used by ID03 nearest_palette_index_rgb.
 */
int abs_long /* Original: FUN_0000001e */ (int value /* param_1 */)

{
  if (value < 0) {
    value = -value;
  }
  return value;
}



/* VERIFIED (ID02::FUN_00000038): ID02.bin 0x38..0x64 checked against an independent capstone disassembly.
 * numer word $c(A6) via MOVEA.W (sign-extended), DIVS.W $e(A6) twice: quotient word to -4, SWAP remainder to
 * -2, MOVE.L -4 through 8(A6) - identical to the C after the (short) correction (the C had an unsigned
 * division through undefined2). */
/* Original: FUN_00000038; source: ID02.c. Recovered name: ansi_div [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x38.
 * div: stores {numer / denom, numer % denom} (16-bit quotient and remainder, DIVS) through the result pointer +8 (struct return). Complete Ghidra C.
 */
void ansi_div /* Original: FUN_00000038 */ (undefined4 *result /* param_1 */,undefined4 operands /* param_2: numerator word, denominator word */)

{
  undefined4 quot_rem; /* local_8, -4(A6): quotient word, remainder word */
  
  quot_rem = CONCAT22((short)operands._0_2_ / (short)operands._2_2_,(short)operands._0_2_ % (short)operands._2_2_);
                                                /* DIVS.W: signed; undefined2 is unsigned in this file */
  *result = quot_rem;
  return;
}



/* VERIFIED (ID02::FUN_00000066): ID02.bin 0x66..0x98 checked against an independent capstone disassembly.
 * Push $10 then $c (C order numer, denom) to JT $5a (CODE 0 entry seg 1 -> ID01 0x152 rt_sdiv32) and
 * JT $62 (ID01 0x172 rt_smod32), caller pops nothing (the helpers pop their own args); two MOVE.L
 * from -8 / -4 through 8(A6) - identical to the C. */
/* Original: FUN_00000066; source: ID02.c. Recovered name: ansi_ldiv [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x66.
 * ldiv: result {quot, rem} from the long division helpers JT $5a / $62 (ID01 0x152 / 0x172) stored through the result pointer. Complete Ghidra C.
 */
void ansi_ldiv /* Original: FUN_00000066 */ (undefined4 *result /* param_1 */,undefined4 numer /* param_2 */,undefined4 denom /* param_3 */)

{
  undefined4 quot; /* uVar1 */
  undefined4 rem; /* uVar2 */
  int unaff_A5;
  
  quot = rt_sdiv32(numer,denom);          /* JT $5a -> ID01 0x152 */
  rem = rt_smod32(numer,denom);          /* JT $62 -> ID01 0x172 */
  *result = quot;
  result[1] = rem;
  return;
}



/* VERIFIED (ID02::FUN_0000009a): ID02.bin 0x9a..0xb4 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$d0; D0 high word stays 0 - identical to the C. */
/* Original: FUN_0000009a; source: ID02.c. Recovered name: ansi_isalnum [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x9a.
 * C runtime ctype test: returns _ctype[c] & 0xd0, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
ushort ansi_isalnum /* Original: FUN_0000009a */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0xd0;
}



/* VERIFIED (ID02::FUN_000000b6): ID02.bin 0xb6..0xd0 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$c0; D0 high word stays 0 - identical to the C. */
/* Original: FUN_000000b6; source: ID02.c. Recovered name: ansi_isalpha [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0xb6.
 * C runtime ctype test: returns _ctype[c] & 0xc0, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
ushort ansi_isalpha /* Original: FUN_000000b6 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0xc0;
}



/* VERIFIED (ID02::FUN_000000d2): ID02.bin 0xd2..0xec checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$3; D0 high word stays 0 - identical to the C. */
/* Original: FUN_000000d2; source: ID02.c. Recovered name: ansi_iscntrl [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0xd2.
 * C runtime ctype test: returns _ctype[c] & 0x03, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
byte ansi_iscntrl /* Original: FUN_000000d2 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 3;
}



/* VERIFIED (ID02::FUN_000000ee): ID02.bin 0xee..0x108 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$10; D0 high word stays 0 - identical to the C. */
/* Original: FUN_000000ee; source: ID02.c. Recovered name: ansi_isdigit [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0xee.
 * C runtime ctype test: returns _ctype[c] & 0x10, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
byte ansi_isdigit /* Original: FUN_000000ee */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0x10;
}



/* VERIFIED (ID02::FUN_0000010a): ID02.bin 0x10a..0x124 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$d8; D0 high word stays 0 - identical to the C. */
/* Original: FUN_0000010a; source: ID02.c. Recovered name: ansi_isgraph [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x10a.
 * C runtime ctype test: returns _ctype[c] & 0xd8, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
ushort ansi_isgraph /* Original: FUN_0000010a */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0xd8;
}



/* VERIFIED (ID02::FUN_00000126): ID02.bin 0x126..0x140 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$80; D0 high word stays 0 - identical to the C. */
/* Original: FUN_00000126; source: ID02.c. Recovered name: ansi_islower [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x126.
 * C runtime ctype test: returns _ctype[c] & 0x80, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
ushort ansi_islower /* Original: FUN_00000126 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0x80;
}



/* VERIFIED (ID02::FUN_00000142): ID02.bin 0x142..0x15c checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$dc; D0 high word stays 0 - identical to the C. */
/* Original: FUN_00000142; source: ID02.c. Recovered name: ansi_isprint [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x142.
 * C runtime ctype test: returns _ctype[c] & 0xdc, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
ushort ansi_isprint /* Original: FUN_00000142 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0xdc;
}



/* VERIFIED (ID02::FUN_0000015e): ID02.bin 0x15e..0x178 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$8; D0 high word stays 0 - identical to the C. */
/* Original: FUN_0000015e; source: ID02.c. Recovered name: ansi_ispunct [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x15e.
 * C runtime ctype test: returns _ctype[c] & 0x08, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
byte ansi_ispunct /* Original: FUN_0000015e */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 8;
}



/* VERIFIED (ID02::FUN_0000017a): ID02.bin 0x17a..0x194 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$6; D0 high word stays 0 - identical to the C. */
/* Original: FUN_0000017a; source: ID02.c. Recovered name: ansi_isspace [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x17a.
 * C runtime ctype test: returns _ctype[c] & 0x06, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
byte ansi_isspace /* Original: FUN_0000017a */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 6;
}



/* VERIFIED (ID02::FUN_00000196): ID02.bin 0x196..0x1b0 checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$40; D0 high word stays 0 - identical to the C. */
/* Original: FUN_00000196; source: ID02.c. Recovered name: ansi_isupper [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x196.
 * C runtime ctype test: returns _ctype[c] & 0x40, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
byte ansi_isupper /* Original: FUN_00000196 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0x40;
}



/* VERIFIED (ID02::FUN_000001b2): ID02.bin 0x1b2..0x1cc checked against an independent capstone disassembly.
 * MOVEQ #0, MOVE.B 9(A6) (low byte of the word argument, zero-extended), ADDA.W to A5-0x1608, MOVE.B,
 * EXT.W, ANDI.W #$30; D0 high word stays 0 - identical to the C. */
/* Original: FUN_000001b2; source: ID02.c. Recovered name: ansi_isxdigit [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x1b2.
 * C runtime ctype test: returns _ctype[c] & 0x30, the class table being the 256 bytes at A5-0x1608 [PROVEN, complete Ghidra C]. Bit layout derived from the eleven masks of this ANSI-ordered group (0x9a..0x1b2): 0x80 lower, 0x40 upper, 0x10 digit, 0x20 hex letter, 0x08 punctuation, 0x04 space character, 0x02 white space, 0x01 control; names follow the ANSI <ctype.h> order isalnum, isalpha, iscntrl, isdigit, isgraph, islower, isprint, ispunct, isspace, isupper, isxdigit, which matches every mask [STRONG INFERENCE].
 */
byte ansi_isxdigit /* Original: FUN_000001b2 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)c._1_1_ + unaff_A5 + -0x1608) & 0x30;
}



/* VERIFIED (ID02::FUN_000001ce): ID02.bin 0x1ce..0x1fe checked against an independent capstone disassembly.
 * Same table index as the ctype group, EXT.W, BTST #7; set: word 8(A6) EORI.W #$20, SWAP/CLR.W/SWAP
 * (zero-extended); clear: MOVE.W 8(A6) (high word still 0 from MOVEQ) - identical to the C. */
/* Original: FUN_000001ce; source: ID02.c. Recovered name: ansi_toupper [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x1ce.
 * toupper: if _ctype[c] & 0x80 (lower case) returns c ^ 0x20, else c. Complete Ghidra C.
 */
ushort ansi_toupper /* Original: FUN_000001ce */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  ushort index; /* uVar1: ctype table index */
  int unaff_A5;
  
  index = (ushort)c._1_1_;
  if (((short)*(char *)((int)(short)index + unaff_A5 + -0x1608) & 0x80U) != 0) {
    c._0_2_ = c._0_2_ ^ 0x20;
  }
  return c._0_2_;
}



/* VERIFIED (ID02::FUN_00000200): ID02.bin 0x200..0x230 checked against an independent capstone disassembly.
 * Same table index as the ctype group, EXT.W, BTST #6; set: word 8(A6) EORI.W #$20, SWAP/CLR.W/SWAP
 * (zero-extended); clear: MOVE.W 8(A6) (high word still 0 from MOVEQ) - identical to the C. */
/* Original: FUN_00000200; source: ID02.c. Recovered name: ansi_tolower [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x200.
 * tolower: if _ctype[c] & 0x40 (upper case) returns c ^ 0x20, else c. Complete Ghidra C.
 */
ushort ansi_tolower /* Original: FUN_00000200 */ (undefined4 c /* param_1: character in the low byte of the int */)

{
  ushort index; /* uVar1: ctype table index */
  int unaff_A5;
  
  index = (ushort)c._1_1_;
  if ((*(byte *)((int)(short)index + unaff_A5 + -0x1608) & 0x40) != 0) {
    c._0_2_ = c._0_2_ ^ 0x20;
  }
  return c._0_2_;
}



/* VERIFIED (ID02::FUN_00000232): ID02.bin 0x232..0x248 checked against an independent capstone disassembly.
 * No LINK; D0 = A0 = dst, A1 = src, D1 = n; BRA to the test, MOVE.B (A1)+,(A0)+ / SUBQ.L / BNE. D0 keeps
 * dst, so the function returns dst (Ghidra's void return corrected) - identical to the C. */
/* Original: FUN_00000232; source: ID02.c. Recovered name: ansi_memcpy [PROVEN].
 * Decoded from ID02.bin bytes at file 0x232.
 * memcpy(dst, src, n): forward byte copy of n bytes. Complete Ghidra C.
 */
undefined1 * ansi_memcpy /* Original: FUN_00000232 */ (undefined1 *dst /* param_1 */,undefined1 *src /* param_2 */,int count /* param_3 */)

{
  undefined1 *out; /* puVar1: write cursor */

  out = dst;                             /* MOVE.L 4(A7),D0: dst is the return value */
  for (; count != 0; count = count + -1) {
    *out = *src;
    out = out + 1;
    src = src + 1;
  }
  return dst;
}



/* VERIFIED (ID02::FUN_0000024a): ID02.bin 0x24a..0x270 checked against an independent capstone disassembly.
 * D0 = A0 = dst; n == 0 -> RTS; CMPA.L A0,A1 / BHI (src > dst unsigned) -> forward copy, else both pointers
 * advanced by n and MOVE.B -(A1),-(A0) backwards. D0 = dst on every exit (return value added) - identical to
 * the C. */
/* Original: FUN_0000024a; source: ID02.c. Recovered name: ansi_memmove [PROVEN].
 * Decoded from ID02.bin bytes at file 0x24a.
 * memmove(dst, src, n): copies backwards when dst >= src (overlap safe), else forwards. Complete Ghidra C; reached through JT $4fa (used by ID07 load_str129_string_table).
 */
undefined1 * ansi_memmove /* Original: FUN_0000024a */ (undefined1 *dst /* param_1 */,undefined1 *src /* param_2 */,int count /* param_3 */)

{
  undefined1 *out; /* puVar1: write cursor */
  undefined1 *in; /* puVar2: read cursor (backward copy) */

  if (count != 0) {                           /* D0 = dst before the test: returned on every path */
    if (src <= dst) {                   /* CMPA.L A0,A1 / BHI: unsigned */
      out = dst + count;
      in = src + count;
      do {
        in = in + -1;
        out = out + -1;
        *out = *in;
        count = count + -1;
      } while (count != 0);
      return dst;
    }
    out = dst;
    do {
      *out = *src;
      count = count + -1;
      out = out + 1;
      src = src + 1;
    } while (count != 0);
  }
  return dst;
}


/* VERIFIED (ID02::FUN_000002b0): ID02.bin 0x2b0..0x2c6 checked against an independent capstone disassembly:
 * D0 = dst; D1.W = value; D2.L = count; the initial BRA reaches DBNE-style pre-test logic, then MOVE.B D1,(A0)+ /
 * SUBQ.L #1,D2 / BNE. A zero count performs no stores; the low byte of value is repeated exactly count times;
 * D0 retains dst for the return - identical to the C reconstructed below. */
/* Original: FUN_000002b0; source: ID02.c. Recovered name: ansi_memset [PROVEN].
 * Ghidra failed to adjust the mixed word/long stack arguments. The actual ABI is dst long at 4(A7), value word
 * at 8(A7), count long at 0xa(A7). Reached through local BSRs and used to clear overlay and handle storage.
 */
undefined1 * ansi_memset /* Original: FUN_000002b0 */ (undefined1 *dst,undefined2 value,uint count)

{
  undefined1 *out;

  out = dst;
  while (count != 0) {
    *out = (undefined1)value;
    out = out + 1;
    count = count - 1;
  }
  return dst;
}


/* VERIFIED (ID02::FUN_000002c8): ID02.bin 0x2c8..0x2d6 checked against an independent capstone disassembly.
 * D0 = dst; MOVE.B (A1)+,(A0)+ / BNE copies through the NUL - identical to the C. */
/* Original: FUN_000002c8; source: ID02.c. Recovered name: ansi_strcpy [PROVEN].
 * Decoded from ID02.bin bytes at file 0x2c8.
 * strcpy(dst, src): copies bytes up to and including the NUL, returns dst (bytes 0x2c8..0x2d6, ). Reached through JT $52a.
 */
char * ansi_strcpy /* Original: FUN_000002c8 */ (char *dst /* param_1 */,char *src /* param_2 */)

{
  char ch; /* cVar1 */
  char *out; /* pcVar2: write cursor */
  
  out = dst;
  do {
    ch = *src;
    *out = ch;
    out = out + 1;
    src = src + 1;
  } while (ch != '\0');
  return dst;
}



/* VERIFIED (ID02::FUN_000002d8): ID02.bin 0x2d8..0x2ec checked against an independent capstone disassembly.
 * D0 = dst; TST.B (A0)+ / BNE then SUBQ.L #1,A0 lands on the NUL; MOVE.B (A1)+,(A0)+ / BNE - identical to the
 * C. */
/* Original: FUN_000002d8; source: ID02.c. Recovered name: ansi_strcat [PROVEN].
 * Decoded from ID02.bin bytes at file 0x2d8.
 * strcat(dst, src): finds the NUL of dst, appends src including its NUL, returns dst (bytes 0x2d8..0x2ec, ). Reached through JT $512.
 */
char * ansi_strcat /* Original: FUN_000002d8 */ (char *dst /* param_1 */,char *src /* param_2 */)

{
  char ch; /* cVar1 */
  char *scan; /* pcVar2: one past the byte tested */
  char *out; /* pcVar3: the terminator, then the write cursor */
  
  scan = dst;
  do {
    out = scan;
    scan = out + 1;
  } while (*out != '\0');
  do {
    ch = *src;
    *out = ch;
    out = out + 1;
    src = src + 1;
  } while (ch != '\0');
  return dst;
}



/* VERIFIED (ID02::FUN_000002ee): ID02.bin 0x2ee..0x30a checked against an independent capstone disassembly.
 * D0 = 0; MOVE.B (A0)+,D1, CMP.B (A1)+,D1: equal -> TST.B D1 / BEQ return 0, else loop; different -> BHI
 * (unsigned a > b) gives 1, else SUBQ #2 then ADDQ #1 gives -1 - identical to the C. */
/* Original: FUN_000002ee; source: ID02.c. Recovered name: ansi_strcmp [PROVEN].
 * Decoded from ID02.bin bytes at file 0x2ee.
 * strcmp(a, b): unsigned byte compare; returns -1 / 0 / 1 at the first difference or 0 at a common NUL. Complete Ghidra C.
 */
int ansi_strcmp /* Original: FUN_000002ee */ (byte *s1 /* param_1 */,byte *s2 /* param_2 */)

{
  byte ch; /* bVar1: byte of s1 */
  int sign; /* iVar2: 0, or -2 when s1 < s2 (result sign - 1) */
  
  sign = 0;
  do {
    ch = *s1;
    if (ch != *s2) {
      if (ch < *s2) {
        sign = -2;
      }
      return sign + 1;
    }
    s1 = s1 + 1;
    s2 = s2 + 1;
  } while (ch != 0);
  return 0;
}



/* VERIFIED (ID02::FUN_0000030c): ID02.bin 0x30c..0x322 checked against an independent capstone disassembly.
 * D1 = word 8(A7), CMP.B (A0),D1 compares its low byte; D0 = 0; match -> D0 = A0; else TST.B (A0)+ / BEQ
 * returns 0 after testing the NUL itself - identical to the C. */
/* Original: FUN_0000030c; source: ID02.c. Recovered name: ansi_strchr [PROVEN].
 * Decoded from ID02.bin bytes at file 0x30c.
 * strchr(s, c): first occurrence of the character (low byte of the 16-bit int at 8(A7), i.e. byte 9, which the C reaches as the low byte of the long's high word) including the terminating NUL, else NULL. Complete Ghidra C.
 */
char * ansi_strchr /* Original: FUN_0000030c */ (char *s /* param_1 */,undefined4 c /* param_2: character in the high byte of the word (int promoted, big-endian) */)

{
  char ch; /* cVar1 */
  
  do {
    if ((char)((uint)c >> 0x10) == *s) {
      return s;
    }
    ch = *s;
    s = s + 1;
  } while (ch != '\0');
  return (char *)0x0;
}



/* VERIFIED (ID02::FUN_00000324): ID02.bin 0x324..0x33c checked against an independent capstone disassembly.
 * D0 = -1; outer ADDQ.L #1, MOVE.B (A0)+,D1 / BEQ return; A1 = reject, MOVE.B (A1)+,D2 / BEQ next outer,
 * CMP.B D1,D2 / BNE inner, equal -> return D0 - identical to the C. */
/* Original: FUN_00000324; source: ID02.c. Recovered name: ansi_strcspn [PROVEN].
 * Decoded from ID02.bin bytes at file 0x324.
 * strcspn(s, reject): length of the initial segment of s containing no character of reject. Complete Ghidra C.
 */
int ansi_strcspn /* Original: FUN_00000324 */ (char *s /* param_1 */,char *reject /* param_2 */)

{
  char ch; /* cVar1: byte of s */
  char rc; /* cVar2: byte of reject */
  int len; /* iVar3 */
  char *next; /* pcVar4 */
  char *r; /* pcVar5: reject cursor */
  
  len = -1;
  do {
    len = len + 1;
    next = s + 1;
    ch = *s;
    r = reject;
    if (ch == '\0') {
      return len;
    }
    while( true ) {
      rc = *r;
      s = next;
      if (rc == '\0') break;
      r = r + 1;
      if (rc == ch) {
        return len;
      }
    }
  } while( true );
}



/* VERIFIED (ID02::FUN_0000033e): ID02.bin 0x33e..0x358 checked against an independent capstone disassembly.
 * D0 = 0; MOVE.B (A0)+,D1 / BEQ return 0; inner over accept, BEQ on its NUL back to the outer loop; match ->
 * SUBQ.L #1,A0 and D0 = A0 (the matching character) - identical to the C. */
/* Original: FUN_0000033e; source: ID02.c. Recovered name: ansi_strpbrk [PROVEN].
 * Decoded from ID02.bin bytes at file 0x33e.
 * strpbrk(s, accept): first character of s that is in accept, else NULL. Complete Ghidra C.
 */
char * ansi_strpbrk /* Original: FUN_0000033e */ (char *s /* param_1 */,char *accept /* param_2 */)

{
  char ac; /* cVar1: byte of accept */
  char *cur; /* pcVar2: current byte of s */
  char *a; /* pcVar3: accept cursor */
  
  do {
    cur = s;
    a = accept;
    if (*cur == '\0') {
      return (char *)0x0;
    }
    while( true ) {
      ac = *a;
      s = cur + 1;
      if (ac == '\0') break;
      a = a + 1;
      if (ac == *cur) {
        return cur;
      }
    }
  } while( true );
}



/* VERIFIED (ID02::FUN_0000035a): ID02.bin 0x35a..0x36e checked against an independent capstone disassembly.
 * D1 = word 8(A7) (CMP.B uses its low byte, byte 9), D0 = 0; each position CMP.B (A0),D1, equal -> D0 = A0;
 * TST.B (A0)+ / BNE, so the NUL itself can match - identical to the C. */
/* Original: FUN_0000035a; source: ID02.c. Recovered name: ansi_strrchr [PROVEN].
 * Decoded from ID02.bin bytes at file 0x35a.
 * strrchr(s, c): last occurrence of the character (NUL included), else NULL. Complete Ghidra C.
 */
char * ansi_strrchr /* Original: FUN_0000035a */ (char *s /* param_1 */,undefined4 c /* param_2: character in the high byte of the word */)

{
  char ch; /* cVar1 */
  char *last; /* pcVar2: last match so far */
  
  last = (char *)0x0;
  do {
    if ((char)((uint)c >> 0x10) == *s) {
      last = s;
    }
    ch = *s;
    s = s + 1;
  } while (ch != '\0');
  return last;
}



/* VERIFIED (ID02::FUN_00000370): ID02.bin 0x370..0x38a checked against an independent capstone disassembly.
 * D0 = 0; MOVE.B (A0)+,D1 / BEQ return; A1 = accept, MOVE.B (A1)+,D2 / BNE CMP.B D1,D2: different -> next
 * accept byte, equal -> ADDQ.L #1 and next s byte; accept NUL -> return D0 - identical to the C. */
/* Original: FUN_00000370; source: ID02.c. Recovered name: ansi_strspn [PROVEN].
 * Decoded from ID02.bin bytes at file 0x370.
 * strspn(s, accept): length of the initial segment of s made only of characters of accept. Complete Ghidra C.
 */
int ansi_strspn /* Original: FUN_00000370 */ (char *s /* param_1 */,char *accept /* param_2 */)

{
  char ac; /* cVar1: byte of accept */
  int len; /* iVar2 */
  char *a; /* pcVar3: accept cursor */
  
  len = 0;
  do {
    a = accept;
    if (*s == '\0') {
      return len;
    }
    do {
      ac = *a;
      if (ac == '\0') {
        return len;
      }
      a = a + 1;
    } while (ac != *s);
    len = len + 1;
    s = s + 1;
  } while( true );
}



/* VERIFIED (ID02::FUN_0000038c): ID02.bin 0x38c..0x3a8 checked against an independent capstone disassembly.
 * D0 = start = s; A0 = start, A1 = sub; MOVE.B (A1)+,D1 / BEQ return start; MOVE.B (A0)+,D2 / BEQ falls to
 * MOVEQ #0 (NULL); CMP.B D1,D2 equal -> next pair, else ADDQ.L #1 start and restart - identical to the C. */
/* Original: FUN_0000038c; source: ID02.c. Recovered name: ansi_strstr [PROVEN].
 * Decoded from ID02.bin bytes at file 0x38c.
 * strstr(s, sub): first occurrence of sub in s (s itself when sub is empty), else NULL; restarts one past the previous start on a mismatch. Complete Ghidra C.
 */
char * ansi_strstr /* Original: FUN_0000038c */ (char *s /* param_1: haystack cursor */,char *needle /* param_2 */)

{
  char nc; /* cVar1: byte of needle */
  char hc; /* cVar2: byte of the haystack */
  char *start; /* pcVar3: candidate match start */
  char *n; /* pcVar4: needle cursor */
  
  n = needle;
  start = s;
  while( true ) {
    nc = *n;
    if (nc == '\0') {
      return start;
    }
    hc = *s;
    if (hc == '\0') break;
    s = s + 1;
    n = n + 1;
    if (hc != nc) {
      s = start + 1;
      n = needle;
      start = s;
    }
  }
  return (char *)0x0;
}



/* VERIFIED (ID02::FUN_000003aa): ID02.bin 0x3aa..0x3e6 checked against an independent capstone disassembly.
 * D0 = s, BNE past the reload; else D0 = A5-0x1508, BEQ return 0. CLR.L A5-0x1508; skip loop: MOVE.B (A0)+,D1
 * BEQ back to the reload (now 0, so NULL); delimiter match -> D0 = A0 (start moves past it); first
 * non-delimiter -> token scan: NUL returns D0 with the saved pointer 0, delimiter -> A5-0x1508 = A0 (one
 * past it), CLR.B -(A0), return D0 - identical to the C. */
/* Original: FUN_000003aa; source: ID02.c. Recovered name: ansi_strtok [PROVEN].
 * Decoded from ID02.bin bytes at file 0x3aa.
 * strtok(s, delims): with s == NULL continues from the saved pointer A5-0x1508; skips leading delimiters, NUL-terminates the token and saves the next position in A5-0x1508 (0 when the string ends). Complete Ghidra C.
 */
char * ansi_strtok /* Original: FUN_000003aa */ (char *s /* param_1: string, or NULL to continue from the saved position A5-0x1508 */,char *delim /* param_2 */)

{
  char dc; /* cVar1: byte of delim */
  char *next; /* pcVar2 */
  char *tok; /* pcVar3: token start (first non-delimiter) */
  char *end; /* pcVar4: scan for the token end */
  char *d; /* pcVar5: delim cursor */
  int unaff_A5;
  
  if (s != (char *)0x0) goto LAB_000003b6;
  do {
    s = *(char **)(unaff_A5 + -0x1508);
    if (s == (char *)0x0) {
      return (char *)0x0;
    }
LAB_000003b6:
    *(undefined4 *)(unaff_A5 + -0x1508) = 0;
    while( true ) {
      tok = s;
      d = delim;
      if (*tok == '\0') break;
      do {
        dc = *d;
        next = tok + 1;
        if (dc == '\0') {
          do {
            end = next;
            d = delim;
            if (*end == '\0') {
              return tok;
            }
            while( true ) {
              dc = *d;
              next = end + 1;
              if (dc == '\0') break;
              d = d + 1;
              if (dc == *end) {
                *(char **)(unaff_A5 + -0x1508) = end + 1;
                *end = '\0';
                return tok;
              }
            }
          } while( true );
        }
        s = tok + 1;
        d = d + 1;
      } while (dc != *tok);
    }
  } while( true );
}



/* VERIFIED (ID02::FUN_000003f6): ID02.bin 0x3f6..0x410 checked against an independent capstone disassembly.
 * D0 = A0 = dst, A1 = src, D1 = n, BEQ on 0; MOVE.B (A1),(A0)+ / BEQ skips ADDQ.L #1,A1 (pads with NUL);
 * SUBQ.L / BNE. D0 = dst on exit (Ghidra's void return corrected) - identical to the C. */
/* Original: FUN_000003f6; source: ID02.c. Recovered name: ansi_strncpy [PROVEN].
 * Decoded from ID02.bin bytes at file 0x3f6.
 * strncpy(dst, src, n): copies n bytes, padding with NULs once src ends (the source pointer stops advancing at its NUL). Complete Ghidra C.
 */
char * ansi_strncpy /* Original: FUN_000003f6 */ (char *dst /* param_1 */,char *src /* param_2 */,int count /* param_3 */)

{
  char ch; /* cVar1 */
  char *out; /* pcVar2: write cursor */

  out = dst;                             /* MOVE.L 4(A7),D0: dst is the return value */
  for (; count != 0; count = count + -1) {
    ch = *src;
    *out = ch;
    if (ch != '\0') {
      src = src + 1;
    }
    out = out + 1;
  }
  return dst;
}



/* VERIFIED (ID02::FUN_00000412): ID02.bin 0x412..0x432 checked against an independent capstone disassembly.
 * D0 = A0 = dst, D1 = n, BEQ on 0; TST.B (A0)+ / BNE, SUBQ.L #1,A0; MOVE.B (A1)+,(A0)+ / BEQ return;
 * SUBQ.L / BNE; CLR.B (A0). D0 = dst on every exit (return value added) - identical to the C. */
/* Original: FUN_00000412; source: ID02.c. Recovered name: ansi_strncat [PROVEN].
 * Decoded from ID02.bin bytes at file 0x412.
 * strncat(dst, src, n): appends at most n bytes of src to dst and always NUL-terminates. Complete Ghidra C.
 */
char * ansi_strncat /* Original: FUN_00000412 */ (char *dst /* param_1 */,char *src /* param_2 */,int count /* param_3 */)

{
  char ch; /* cVar1 */
  char *after; /* pcVar2: one past the byte written */
  char *out; /* pcVar3: dst terminator, then the write cursor */
  char *scan; /* pcVar4 */

  if (count != 0) {                           /* D0 = dst before the test: returned on every path */
    scan = dst;
    do {
      out = scan;
      scan = out + 1;
    } while (*out != '\0');
    do {
      ch = *src;
      after = out + 1;
      *out = ch;
      if (ch == '\0') {
        return dst;
      }
      count = count + -1;
      out = after;
      src = src + 1;
    } while (count != 0);
    *after = '\0';
  }
  return dst;
}



/* VERIFIED (ID02::FUN_0000045a): ID02.bin 0x45a..0x4a2 checked against an independent capstone disassembly.
 * LINK -4, CLR.L -4; PEA $a2(A5) / UnloadSeg $A9F1; BSR 0x4c6; JSR (A5-0x1082); BSR 0x1f8e load_game_sounds;
 * CLR.L result / JT $212 (CODE 0 entry seg 9 -> ID09 0x1b2 FreeMem), CMPI.L #100000 / BGE; CLR.L / PEA -4 /
 * JT $21a (ID09 0x1bc MaxMem); JSR (A5-0x107e); BSR 0x95a; BSR 0x20be lock_sound_slots - identical to the C.
 * The routine at 0x4a4..0x4c4 (end_overlay_session) has no inventory entry. */
/* Original: FUN_0000045a; source: ID02.c. Recovered name: begin_overlay_session [STRONG INFERENCE mechanics / HYPOTHESIS role].
 * Decoded from ID02.bin bytes at file 0x45a.
 * Ghidra could not decode this body (rebuilt as C below); bytes 0x45a..0x4a2 [PROVEN]: UnloadSeg(JT $a2, i.e. CODE 4) ($A9F1); ensure_free_memory_and_init_sound (0x4c6); calls the overlay hook A5-0x1082; JSR 0x1f8e; if FreeMem (JT $212 = ID09 0x1b2, $A01C) < 100000 then MaxMem(&grow) (JT $21a = ID09 0x1bc, $A11D) to compact the heap; calls the overlay hook A5-0x107e; JSR 0x95a; JSR 0x20be. The bytes that follow (0x4a4..0x4c4, not exported) are the matching end_overlay_session: if sound is enabled (A5-0x12ee) shutdown_sound (0x4318); overlay hook A5-0x1076; JSR 0x1e68; JSR 0x9fa; if A5-0x1028 DrawMenuBar ($A937). Callers: 0x558 (inside FUN_000004fc), 0x700, 0x7be, 0x7dc; end_overlay_session from 0x6e2, 0x7c4, 0x84c. The pair brackets running the game overlay (Pacific Conflict) [HYPOTHESIS].
 */
// WARNING: Control flow encountered bad instruction data

void begin_overlay_session /* Original: FUN_0000045a */ (void)

{
  int unaff_A5;
  int grow;                                     /* -4(A6) */

  grow = 0;
  UnloadSeg((void *)(unaff_A5 + 0xa2));         /* $A9F1; PEA $a2(A5) = a JT entry of CODE 4 */
  ensure_free_memory_and_init_sound();          /* BSR 0x4c6 */
  (**(code **)(unaff_A5 + -0x1082))();          /* overlay hook */
  load_game_sounds();                           /* BSR 0x1f8e */
  if (FreeMem() < 100000) {                     /* JT $212 -> ID09 0x1b2 ($A01C); CMPI.L #$186a0 / BGE */
    MaxMem(&grow);                              /* JT $21a -> ID09 0x1bc ($A11D); result discarded */
  }
  (**(code **)(unaff_A5 + -0x107e))();          /* overlay hook */
  FUN_0000095a();                               /* BSR 0x95a (no inventory entry) */
  lock_sound_slots();                           /* BSR 0x20be */
  return;
}



/* VERIFIED (ID02::FUN_000004c6): ID02.bin 0x4c6..0x4fa checked against an independent capstone disassembly.
 * LINK -4, CLR.L -4; FreeMem (JT $212) CMPI.L #500000 / BGE; MaxMem(&-4) (JT $21a), result popped; TST.W
 * A5-0x12ee / BEQ; CLR.L -(A7), BSR 0x3dd0 init_sound_system, ADDQ.L #4 - identical to the C. Ghidra's
 * pointer return was only the leftover D0. */
/* Original: FUN_000004c6; source: ID02.c. Recovered name: ensure_free_memory_and_init_sound [PROVEN].
 * Decoded from ID02.bin bytes at file 0x4c6.
 * If FreeMem (JT $212, $A01C) < 500000, calls MaxMem(&grow) (JT $21a, $A11D) to compact / purge the heap; then, when sound is enabled (word A5-0x12ee), init_sound_system(0) (0x3dd0). Caller: begin_overlay_session (0x468). Rebuilt from the bytes (Ghidra's stack-confused glue calls replaced).
 */
void ensure_free_memory_and_init_sound /* Original: FUN_000004c6 */ (void)

{
  int unaff_A5;
  int grow;                                     /* -4(A6) */

  grow = 0;
  if (FreeMem() < 500000) {                     /* JT $212 -> ID09 0x1b2; CMPI.L #$7a120 / BGE */
    MaxMem(&grow);                              /* JT $21a -> ID09 0x1bc; result discarded */
  }
  if (*(short *)(unaff_A5 + -0x12ee) != 0) {    /* sound enabled */
    init_sound_system(0);                       /* BSR 0x3dd0, ADDQ.L #4 */
  }
  return;                                       /* D0 is left over (the sole caller ignores it) */
}



/* VERIFIED (ID02::FUN_000004fc): ID02.bin 0x4fc..0x92e checked against an independent capstone disassembly.
 * Body rebuilt from the bytes (Ghidra stopped at the JT $32 value table). Switch helpers: JSR $32(A5) =
 * CODE 0 entry seg 1 -> ID01 0xaa: pops the table address, count word, then (offset word, value long)
 * pairs compared against D0.L with DBEQ (count + 1 compares, the last offset word is the default), jumps to
 * offset-word address + offset. Table 0x654: count 13; T / t -> 0x6a6 (BCHG #0 A5-0x102f), '1'..'5' ->
 * 0x6b0, Q / q -> 0x6da (result 5), S / s -> 0x6e2, E / e -> 0x706, default word at 0x6a4 -> 0x720 (the 14th
 * compare reads code bytes as a value; no key can match). JSR $3a(A5) = ID01 0xbe range tables at 0x78e
 * (6 -> 0x79a, 8 -> 0x7c4, 7 / default -> 0x7e0) and 0x8a6 (-1..10). Traps: $A938, $AA31, $A915, $A91F,
 * $A852, $A975, $A972, $A974 (Button), $A970 masks $18 / $ffe7, $A850, $A9AA, $A999. JT $1fa -> ID09 0x18a
 * MOVE.W to $144. Key hook pushes (long)(short)what then char & $ff; cmdKey ($100 of modifiers) handled only
 * when what == 4 (CMPI.W #4 / BNE.W to the (0, 0) call); 0x720 calls the hook only if result == 0.
 * Activate path pushes the 16-byte record by value (four MOVE.L -(A0) from -$12). Exit: roster word +0x20
 * vs A5-0x12b4 with 64-byte records (ASL.L #6); conclude_mission(word result, long A5-0xde6), CMPI.W #3
 * - identical to the C. */
/* Original: FUN_000004fc; source: ID02.c. Recovered name: run_flight_session [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x4fc.
 * Ghidra could not decode this body (rebuilt as C below; corrections there: $A974 is Button, the key hook gets
 * (char, what), and the second event loop only handles update (6) / activate (8)); outline from bytes
 * 0x4fc..0x92e [PROVEN control flow, roles STRONG INFERENCE]. Set-up (0x51a, also the restart point): HiliteMenu(0) ($A938); screen base / rowBytes / depth copied into A5-0x1382 / -0x1378 / -0x1312; $AA31 on A5-0x1036; JSR 0x197c; ShowWindow or (when already shown) $A91F + JSR 0x4d34 on the window A5-0x14ca; begin_overlay_session; HideCursor ($A852); JT $1fa(-7) (ID09 0x18a, event flush glue); overlay hook A5-0x106e(pilot rank record +0x22); A5-0x1504 = TickCount; frame counters A5-0x14fc / -0x1500 = 0. Main loop (0x5c0..0x848): frame timing from TickCount, GetMouse / StillDown into A5-0x14f8.. / -0x104a / -0x1048 / -0x1046; GetNextEvent(keyDown | keyUp) - command keys go through a JT $32 table at 0x650 (two of them toggle settings bits +3 / +5 of A5-0x13ac around end_overlay_session / apply_settings_to_live_options / begin_overlay_session), other keys to the overlay key hook A5-0x106a(char, modifiers), whose non-zero result ends the flight; then GetNextEvent(everything but keys): update -> 0x4d6a, a mouse / window path that suspends the session (end_overlay_session, JSR 0x2fa0 with the event, begin_overlay_session), others to the key hook; optional hook A5-0x1086; per-frame step hook A5-0x107a(1, 1); A5-0x14fc += 1 and loop while the result is 0. Exit (0x84c): end_overlay_session; JSR 0x4d96; JT $1fa(-1); InitCursor ($A850); copies the pilot status A5-0x12b4 into the roster record +0x20 (ChangedResource + UpdateResFile when it changed); switch on (result & 0xff) through JT $3a (table at 0x8a6, -1..10): conclude_mission (JT $da) with A5-0xde6 (STR# 129 slot 88 "Resume", the summary button title) and the result - restarting at 0x51a unless it returns 3 (or the result is 9 / 1, with JT $9a, hooks A5-0x108e / -0x108a and redraw_main_window 0x4db0 in between), quit_application (0x2eaa), or show_paused_dialog (JT $122) and restart. Callers: 0x369a, 0x376e, 0x377c (menu command code).
 *, exit switch decoded [PROVEN bytes]: `jsr $3a(a5)` at 0x8a2 with
 * (result & 0xff), inline table at 0x8a6: bounds ffff / 000a, then 13 self-relative
 * word offsets resolving to 0x92c, 0x92c, 0x92c, 0x8c4, 0x910, 0x92c, 0x924, 0x91e,
 * 0x8c4, 0x8c4, 0x8c4, 0x8c4, 0x8c4. Entry 0 is the default and entries 1..12 are
 * values -1..10 [PROVEN: the JT $3a helper at ID01 file 0xbe pops the
 * table address, reads lo / hi, keeps the default entry when the word value is out of
 * range (signed bgt / blt), else selects entry 1 + (value - lo), and jumps via the
 * self-relative word; a zero word hangs (beq *)]. Since the value is masked with
 * & 0xff, -1 never occurs and codes > 10 take the default (return):
 *   -1, 0, 3 -> return (0x92c, no summary); 1, 6..10 -> conclude_mission (0x8c4);
 *   2 -> JT $9a + hook A5-0x108e, restart the flight with no summary (0x910; the
 *   overlay's |2 refuel / rearm snapshot); 4 -> show_paused_dialog (0x924) and
 *   restart; 5 -> quit_application (0x91e).
 * After conclude_mission: a result != 3 returns; 3 ("Resume", A5-0xde6) restarts at
 * 0x51a - directly for code 9, after JT $9a + hook -0x108e for code 1, else after
 * hooks -0x108e / -0x108a and redraw_main_window. The overlay codes (0x100 enemy /
 * 0x200 friendly base | low bits) reach here masked to their low byte: 1 friendly-base
 * landing (or pilot already dead), 2 refuel snapshot, 6 stopped in water (ditched),
 * 7 bail-out (resolve_bailout_outcome), 8 crash off a hard surface, 9 landing end,
 * 0xa captured ( correction: 6 is not the bail-out).
 */
// WARNING: Control flow encountered bad instruction data

void run_flight_session /* Original: FUN_000004fc */ (void)

{
  int unaff_A5;
  short mouse[2];                               /* -$28(A6): Point v (-$28), h (-$26) */
  short sessionFlag;                            /* -$24(A6): set once, never read */
  short evt[8];                                 /* -$22(A6): EventRecord what, message -$20, when, where,
                                                   modifiers -$14 */
  int unused_e;                                 /* -$e(A6): cleared, never read */
  short result;                                 /* -$a(A6) */
  short halfMBar;                               /* -4(A6) */
  int rec;
  short r;

  unused_e = 0;
  sessionFlag = (*(short *)(unaff_A5 + -0x12d4) != 0) && (*(short *)(unaff_A5 + -0x1032) != 0);
restart:                                        /* 0x51a */
  HiliteMenu(0);                                /* $A938 */
  *(int *)(unaff_A5 + -0x1382) = *(int *)(unaff_A5 + -0x1346);
  *(short *)(unaff_A5 + -0x1378) = *(short *)(unaff_A5 + -0x134a);
  *(short *)(unaff_A5 + -0x1312) = *(short *)(unaff_A5 + -0x1348);
  SetGDevice(*(int *)(unaff_A5 + -0x1036));     /* $AA31 */
  run_segment3_entry_and_unload_a5safe();       /* BSR 0x197c */
  if (*(short *)(unaff_A5 + -0x14c6) == 0) {
    ShowWindow(*(int *)(unaff_A5 + -0x14ca));   /* $A915 */
    *(short *)(unaff_A5 + -0x14c6) = 1;
  }
  else {
    SelectWindow(*(int *)(unaff_A5 + -0x14ca)); /* $A91F */
    process_pending_update_events();            /* BSR 0x4d34 */
  }
  begin_overlay_session();                      /* BSR 0x45a */
  HideCursor();                                 /* $A852 */
  if ((*(short *)(unaff_A5 + -0x103c) == 0) && (*(short *)(unaff_A5 + -0x12ea) != 0)) {
    *(short *)(unaff_A5 + -0x103c) = 0;
    *(short *)(unaff_A5 + -0x12ea) = 0;
  }
  *(short *)(unaff_A5 + -0x1046) = 0;
  SetEventMask(-7);                             /* JT $1fa -> ID09 0x18a: MOVE.W arg to SysEvtMask $144 */
  (**(code **)(unaff_A5 + -0x106e))
            ((int)*(short *)(**(int **)(unaff_A5 + -0x13a8) + (int)*(short *)(unaff_A5 + -0x13a4) * 0x40 + 0x22));
  *(int *)(unaff_A5 + -0x1504) = TickCount();   /* $A975 */
  *(int *)(unaff_A5 + -0x14fc) = 0;
  *(int *)(unaff_A5 + -0x1500) = 0;
  result = 0;
  halfMBar = (short)((int)*(short *)0xbaa / 2); /* MBarHeight, DIVS.W #2 */
  while( true ) {                               /* 0x5c0 */
    do {
    } while (TickCount() - *(int *)(unaff_A5 + -0x1044) < 4);
    *(int *)(unaff_A5 + -0x1044) = TickCount();
    GetMouse(mouse);                            /* $A972 */
    if ((mouse[1] != *(short *)(unaff_A5 + -0x14f6)) || (mouse[0] != *(short *)(unaff_A5 + -0x14f8))) {
      *(int *)(unaff_A5 + -0x14f8) = *(int *)mouse;
      *(short *)(unaff_A5 + -0x104a) = mouse[1];
      *(short *)(unaff_A5 + -0x1048) = mouse[0] + halfMBar;
    }
    *(short *)(unaff_A5 + -0x1046) = (short)(char)Button(); /* $A974 (not StillDown $A973); EXTB.L */
    if (GetNextEvent(0x18,evt) == 0) {          /* $A970, keyDown | keyUp */
      result = (**(code **)(unaff_A5 + -0x106a))(0,0);
    }
    else if ((evt[7] & 0x100) == 0) {           /* modifiers (-$14): no cmdKey */
      result = (**(code **)(unaff_A5 + -0x106a))(*(uint *)(evt + 1) & 0xff,(int)evt[0]);
    }
    else if (evt[0] != 4) {                     /* command key-down */
      result = (**(code **)(unaff_A5 + -0x106a))(0,0);
    }
    else {                                      /* command key-up: JT $32 value table at 0x650 */
      switch (*(uint *)(evt + 1) & 0xff) {
      case 'T':
      case 't':
        *(byte *)(unaff_A5 + -0x102f) = *(byte *)(unaff_A5 + -0x102f) ^ 1;  /* BCHG #0 */
        break;
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
        *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = (short)((*(uint *)(evt + 1) & 0xff) - 0x30);
        *(short *)(unaff_A5 + -0x14c6) = 0;
        apply_settings_to_live_options();       /* BSR 0x2a44 */
        *(short *)(unaff_A5 + -0x14c6) = 1;
        break;
      case 'Q':
      case 'q':
        result = 5;
        break;
      case 'S':
      case 's':
        FUN_000004a4();                         /* end_overlay_session (no inventory entry) */
        *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 3) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 3) ^ 1;
        *(short *)(unaff_A5 + -0x14c6) = 0;
        apply_settings_to_live_options();
        *(short *)(unaff_A5 + -0x14c6) = 1;
        begin_overlay_session();
        break;
      case 'E':
      case 'e':
        *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 5) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 5) ^ 1;
        *(short *)(unaff_A5 + -0x14c6) = 0;
        apply_settings_to_live_options();
        *(short *)(unaff_A5 + -0x14c6) = 1;
        break;
      }
      if (result == 0) {                        /* 0x720 */
        result = (**(code **)(unaff_A5 + -0x106a))(0,0);
      }
    }
    while (GetNextEvent(-0x19,evt) != 0) {      /* 0x7e0: everything except key events */
      switch (evt[0]) {                         /* JSR $3a(A5) -> ID01 0xbe, table 0x78e lo 6 hi 8 */
      case 6:                                   /* updateEvt */
        FUN_000004a4();
        handle_update_event(evt);               /* BSR 0x4d6a */
        if ((*(short *)(unaff_A5 + -0x103c) == 0) && (*(short *)(unaff_A5 + -0x12ea) != 0)) {
          *(short *)(unaff_A5 + -0x103c) = 0;
          *(short *)(unaff_A5 + -0x12ea) = 0;
        }
        HideCursor();
        begin_overlay_session();
        break;
      case 8:                                   /* activateEvt */
        FUN_000004a4();
        handle_activate_event(*(EventRecord *)evt); /* BSR 0x2fa0, 16 bytes by value */
        begin_overlay_session();
        break;
      }
    }
    if ((*(short *)(unaff_A5 + -0x1030) != 0) && ((**(code **)(unaff_A5 + -0x1086))() != 0)) {
      if (result == 0) {
        result = (**(code **)(unaff_A5 + -0x106a))(0,0);
      }
      if (result == 0) {
        result = (**(code **)(unaff_A5 + -0x106a))(0,0);
      }
    }
    (**(code **)(unaff_A5 + -0x107a))(1,1);    /* per-frame step hook */
    if (result != 0) break;
    *(int *)(unaff_A5 + -0x14fc) = *(int *)(unaff_A5 + -0x14fc) + 1;
  }
  FUN_000004a4();                               /* 0x84c: end_overlay_session */
  FUN_00004d96();                               /* BSR 0x4d96 (no inventory entry) */
  SetEventMask(-1);                             /* JT $1fa */
  InitCursor();                                 /* $A850 */
  rec = **(int **)(unaff_A5 + -0x13a8) + (int)*(short *)(unaff_A5 + -0x13a4) * 0x40;
  if (*(short *)(rec + 0x20) != *(short *)(unaff_A5 + -0x12b4)) {
    *(short *)(**(int **)(unaff_A5 + -0x13a8) + (int)*(short *)(unaff_A5 + -0x13a4) * 0x40 + 0x20) =
         *(short *)(unaff_A5 + -0x12b4);
    ChangedResource(*(int *)(unaff_A5 + -0x13a8));  /* $A9AA */
    UpdateResFile(*(short *)(unaff_A5 + -0x1002));  /* $A999 */
  }
  switch (result & 0xff) {                      /* JSR $3a(A5), table 0x8a6 lo -1 hi 10 */
  case 1:
  case 6:
  case 7:
  case 8:
  case 9:
  case 10:
    r = conclude_mission(result,*(int *)(unaff_A5 + -0xde6)); /* JT $da -> ID04 0x31aa */
    if (r != 3) {
      return;
    }
    if ((result & 0xff) == 9) goto restart;
    (**(code **)(unaff_A5 + 0x9a))();           /* JT $9a -> ID04 0xe70 (no inventory entry) */
    (**(code **)(unaff_A5 + -0x108e))();
    if ((result & 0xff) == 1) goto restart;
    (**(code **)(unaff_A5 + -0x108a))();
    redraw_main_window();                       /* BSR 0x4db0 */
    goto restart;
  case 2:
    (**(code **)(unaff_A5 + 0x9a))();
    (**(code **)(unaff_A5 + -0x108e))();
    goto restart;
  case 4:
    show_paused_dialog();                       /* JT $122 -> ID04 0x478 */
    goto restart;
  case 5:
    FUN_00002eaa();                             /* quit (no inventory entry) */
    return;
  default:                                      /* -1, 0, 3, > 10 */
    return;
  }
}



/* VERIFIED (ID02::FUN_00000930): ID02.bin 0x930..0x958 checked against an independent capstone disassembly.
 * LINK #0; JSR (A5-0x1082); JSR (A5-0x107e); push $c then 8(A6), JSR (A5-0x107a), ADDQ.L #8; JSR (A5-0x1076)
 * - identical to the C. */
/* Original: FUN_00000930; source: ID02.c. Recovered name: call_overlay_session_hooks [PROVEN].
 * Decoded from ID02.bin bytes at file 0x930.
 * Calls the overlay hook pointers in order: A5-0x1082, A5-0x107e, A5-0x107a(arg1, arg2), A5-0x1076 - the same hooks begin_overlay_session / end_overlay_session use (begin, after memory set-up, run, end) [STRONG INFERENCE for the roles]. Caller: ID02 0x4e0a. Complete Ghidra C.
 */
void call_overlay_session_hooks /* Original: FUN_00000930 */ (undefined4 step_arg1 /* param_1: forwarded to the frame-step hook A5-0x107a */,undefined4 step_arg2 /* param_2 */)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + -0x1082))();
  (**(code **)(unaff_A5 + -0x107e))();
  (**(code **)(unaff_A5 + -0x107a))(step_arg1,step_arg2);
  (**(code **)(unaff_A5 + -0x1076))();
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000a42): ID02.bin 0xa42..0xa84 checked against an independent capstone disassembly.
 * LINK -8, A5 / D2 saved at -4 / -8, MOVEA.L $904.w,A5; MOVE.L 8(A6) to (A5-0x160c)+$50; PenSize(2, 2);
 * MoveTo(word $e, word $12); LineTo(word $16, word $1a); D2 / A5 restored - identical to the C. */
/*
 * Original: FUN_00000a42; source: ID02.c:640.
 * Recovered name: draw_thick_line_pixel_index_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x1116 (JT $3fa).
 * Ghidra truncated at $A89B (only the fgColor store was exported); body
 * rebuilt as C. Bytes file 0xa42..0xa84 [PROVEN]: CurrentA5 thunk; args are five
 * longs (colour, x1, y1, x2, y2; low words used for coordinates):
 *   thePort (long A5-0x160c)->fgColor (+0x50) = colour  (raw pixel index,
 *   no ForeColor/RGB lookup); PenSize(2, 2) $A89B; MoveTo(x1, y1) $A893;
 *   LineTo(x2, y2) $A891.
 * [STRONG INFERENCE] 2-pixel line in a palette index - e.g. HUD lines drawn
 * by the overlay.
 */
void draw_thick_line_pixel_index_a5safe /* Original: FUN_00000a42 */
               (undefined4 colour_index /* param_1: raw pixel index stored in fgColor */,int h0 /* param_2 */,int v0 /* param_3 */,int h1 /* param_4 */,int v1 /* param_5 */)

{
  int unaff_A5;

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; caller's A5 / D2 saved and restored */
  *(undefined4 *)(*(int *)(unaff_A5 + -0x160c) + 0x50) = colour_index; /* thePort->fgColor = raw index */
  PenSize(2,2);                                 /* $A89B */
  MoveTo((short)h0,(short)v0);        /* $A893; low words $e / $12(A6) */
  LineTo((short)h1,(short)v1);        /* $A891; low words $16 / $1a(A6) */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000a86): ID02.bin 0xa86..0xace checked against an independent capstone disassembly.
 * Same A5 thunk; PEA $21.w ForeColor $A862; PenMode(2) $A89C; PenSize(2, 2); MoveTo(word $a, word $e);
 * LineTo(word $12, word $16); CLR.W PenMode(0) - identical to the C. */
/*
 * Original: FUN_00000a86; source: ID02.c:652.
 * Recovered name: draw_thick_xor_line_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x1112 (JT $32a).
 * Ghidra truncated at $A862; body rebuilt as C. Bytes 0xa86..0xace [PROVEN]:
 * CurrentA5 thunk; args four longs (x1, y1, x2, y2):
 *   ForeColor(33 blackColor) $A862; PenMode(2 srcXor) $A89C; PenSize(2, 2);
 *   MoveTo(x1, y1); LineTo(x2, y2); PenMode(0 srcCopy).
 * XOR mode makes the line erasable by redrawing it [STRONG INFERENCE].
 * Mode constants per Inside Macintosh; note 0 is restored, not patCopy (8).
 */
void draw_thick_xor_line_a5safe /* Original: FUN_00000a86 */ (int h0 /* param_1 */,int v0 /* param_2 */,int h1 /* param_3 */,int v1 /* param_4 */)

{
  ForeColor(0x21);                              /* $A862, blackColor */
  PenMode(2);                                   /* $A89C, srcXor */
  PenSize(2,2);                                 /* $A89B */
  MoveTo((short)h0,(short)v0);        /* $A893; low words $a / $e(A6) */
  LineTo((short)h1,(short)v1);        /* $A891; low words $12 / $16(A6) */
  PenMode(0);                                   /* srcCopy restored */
  return;                                       /* A5 = CurrentA5 ($904) around the body, then restored */
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000ad0): ID02.bin 0xad0..0xc66 checked against an independent capstone disassembly.
 * LINK -$18, MOVEM D3-D7, A5 / D2 saved, A5 = $904; NewRgn / GetClip / SetClip(A5-0x13b6); D7 = v0, D6 = h0,
 * D4 = h0 + A5-0x11fe, D5 = v0 + A5-0x11fc (word adds); rect -$10 = {v0, h0, low word of v0 + y1, D4};
 * set_draw_color_index(word $16), PaintRect; CMP.L 8 / $c, BGT skips both polygons and the lower rect;
 * each MoveTo / LineTo pushes h then v; polygons as in the header with colours $26 / $2a, KillPoly after
 * each PaintPoly; lower rect {v0 + y2, h0, D5, D4} in colour $1a; PenPat(A5-0x161c), SetClip(saved),
 * DisposeRgn; MOVEM restore - identical to the C. */
/*
 * Original: FUN_00000ad0; source: ID02.c:663.
 * Recovered name: paint_view_horizon_bands_a5safe [STRONG INFERENCE structure /
 * HYPOTHESIS purpose].
 * Ghidra truncated at $A8D8; body rebuilt as C. Bytes 0xad0..0xc66 [PROVEN].
 * CurrentA5 thunk; overlay service slot A5-0x110a (JT $3ea). Long args at
 * 8(A6) y1, $c y2, then words used: $16 cA, $1a cD, $1e xA, $22 xB, $26 cB, $2a cC.
 * View rect: v0 = A5-0x1202, h0 = A5-0x1200, right = h0 + A5-0x11fe,
 * bottom = v0 + A5-0x11fc.
 *   saved = NewRgn; GetClip(saved); SetClip(view region long A5-0x13b6);
 *   set_draw_color_index(cA); PaintRect(v0, h0, v0+y1, right) $A8A2;
 *   if (y1 <= y2) {
 *     OpenPoly $A8CB; MoveTo(h0, v0+y1); LineTo(xA, v0+y1); LineTo(xB, v0+y2);
 *       LineTo(h0, v0+y2); LineTo(h0, v0+y1); ClosePoly $A8CC;
 *       set_draw_color_index(cB); PaintPoly $A8C7; KillPoly $A8CD;
 *     OpenPoly; MoveTo(right, v0+y1); LineTo(right, v0+y2); LineTo(xB, v0+y2);
 *       LineTo(xA, v0+y1); LineTo(right, v0+y1); ClosePoly;
 *       set_draw_color_index(cC); PaintPoly; KillPoly;
 *     set_draw_color_index(cD); PaintRect(v0+y2, h0, bottom, right);
 *   }
 *   PenPat(A5-0x161c) $A89D; SetClip(saved); DisposeRgn(saved).
 * Note: when y1 > y2 only the top band is painted.
 * [HYPOTHESIS] Sky band / tilted horizon split in two polygons / ground band
 * fill of the 3-D view (artificial horizon background).
 */
void paint_view_horizon_bands_a5safe /* Original: FUN_00000ad0 */
               (int band_top /* param_1: end of the top band, rows below the view top */,int band_bottom /* param_2: start of the bottom band */,int unused /* param_3: never read */,int top_colour /* param_4 */,int bottom_colour /* param_5 */,int split_h_top /* param_6: dividing x on the band_top row */,int split_h_bottom /* param_7: dividing x on the band_bottom row */,
               int left_colour /* param_8: polygon left of the divide */,int right_colour /* param_9: polygon right of the divide */)

{
  int unaff_A5;
  int saved;                                    /* -8(A6): RgnHandle */
  int poly;                                     /* -4(A6): PolyHandle */
  short r[4];                                   /* -$10(A6): Rect top, left, bottom, right */
  short v0;                                     /* D7 */
  short h0;                                     /* D6 */
  short right;                                  /* D4 */
  short bottom;                                 /* D5 */

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 (and D3-D7) restored on exit */
  saved = NewRgn();                             /* $A8D8 */
  GetClip(saved);                               /* $A87A */
  SetClip(*(int *)(unaff_A5 + -0x13b6));        /* $A879: view region */
  v0 = *(short *)(unaff_A5 + -0x1202);
  h0 = *(short *)(unaff_A5 + -0x1200);
  right = h0 + *(short *)(unaff_A5 + -0x11fe);
  bottom = v0 + *(short *)(unaff_A5 + -0x11fc);
  r[0] = v0;
  r[1] = h0;
  r[3] = right;
  r[2] = (short)(v0 + band_top);                 /* MOVEA.W D7 + long 8(A6), low word */
  set_draw_color_index((short)top_colour);         /* BSR 0x15cc, word $16(A6) */
  PaintRect(r);                                 /* $A8A2: top band */
  if (band_top <= band_bottom) {                     /* CMP.L / BGT: signed */
    poly = OpenPoly();                          /* $A8CB */
    MoveTo(h0,(short)(v0 + band_top));           /* $A893 (h pushed first) */
    LineTo((short)split_h_top,(short)(v0 + band_top)); /* $A891, word $1e */
    LineTo((short)split_h_bottom,(short)(v0 + band_bottom)); /* word $22 */
    LineTo(h0,(short)(v0 + band_bottom));
    LineTo(h0,(short)(v0 + band_top));
    ClosePoly();                                /* $A8CC */
    set_draw_color_index((short)left_colour);       /* word $26 */
    PaintPoly(poly);                            /* $A8C7 */
    KillPoly(poly);                             /* $A8CD */
    poly = OpenPoly();
    MoveTo(right,(short)(v0 + band_top));
    LineTo(right,(short)(v0 + band_bottom));
    LineTo((short)split_h_bottom,(short)(v0 + band_bottom));
    LineTo((short)split_h_top,(short)(v0 + band_top));
    LineTo(right,(short)(v0 + band_top));
    ClosePoly();
    set_draw_color_index((short)right_colour);       /* word $2a */
    PaintPoly(poly);
    KillPoly(poly);
    r[0] = (short)(v0 + band_bottom);
    r[1] = h0;
    r[3] = right;
    r[2] = bottom;
    set_draw_color_index((short)bottom_colour);       /* word $1a */
    PaintRect(r);                               /* bottom band */
  }
  PenPat((void *)(unaff_A5 + -0x161c));         /* $A89D */
  SetClip(saved);
  DisposeRgn(saved);                            /* $A8D9 */
  return;                                       /* param_3 (long $10(A6)) is never read */
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000c68): ID02.bin 0xc68..0xca4 checked against an independent capstone disassembly.
 * A5 thunk; SetEntries $AA3F with MOVE.W #-1, (ct+6) SUBQ.W #1, PEA ct+8; CLR.W ct+6 - identical to the
 * C. */
/*
 * Original: FUN_00000c68; source: ID02.c:674.
 * Recovered name: apply_pending_color_entries_a5safe [STRONG INFERENCE].
 * Ghidra truncated at $AA3F; body rebuilt as C. Bytes file 0xc68..0xca4 [PROVEN]:
 * CurrentA5 thunk; ct = long A5-0x14b2 (colour table allocated by
 * initialize_application); SetEntries(-1, ct->ctSize (+6) - 1, &ct->ctTable
 * (+8)) $AA3F; ct->ctSize = 0. Default value of overlay service slot A5-0x1122
 * (JT $33a); build_palette_index_map swaps in clear_ctab_size_callback (which
 * only clears ctSize, discarding the entries) when palette indices collide.
 * [STRONG INFERENCE] The overlay accumulates RGB entries in the table and
 * calls the slot to apply them. Trap name per Inside Macintosh.
 */
void apply_pending_color_entries_a5safe /* Original: FUN_00000c68 */ (void)

{
  int unaff_A5;

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  SetEntries(-1,*(short *)(*(int *)(unaff_A5 + -0x14b2) + 6) + -1,
             (void *)(*(int *)(unaff_A5 + -0x14b2) + 8)); /* $AA3F: start -1, count ctSize - 1, &ctTable */
  *(short *)(*(int *)(unaff_A5 + -0x14b2) + 6) = 0;
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000ca6): ID02.bin 0xca6..0xd22 checked against an independent capstone disassembly.
 * LINK -$1a; CLR.L / PEA $6c.w / JT $232 (CODE 0 entry seg 9 -> ID09 0x20c NewPtrClear) to -$12; -$16 =
 * thePort (A5-0x160c); OpenCPort $AA00; SetPort(saved); through **(port+2): word 8(A6) to +4, long $a to
 * +0, Rect $e..$15 to +6 (two MOVE.L); Rect to port+$10; RectRgn(port+$18 long, PEA $e(A6)) $A8DF; D0 =
 * port - identical to the C. */
/*
 * Original: FUN_00000ca6; source: ID02.c:685.
 * Recovered name: new_offscreen_cport [STRONG INFERENCE].
 * Bytes 0xca6..0xd22 [PROVEN]; Ghidra truncated after the allocation (body
 * rebuilt as C). Args:
 * word rowBytes [8(A6)], Ptr base [$a], Rect bounds by value [$e..$15].
 *   port = NewPtrClear(0x6c = sizeof(CGrafPort)) (JT $232, ID09 0x20c);
 *   saved = thePort; OpenCPort(port) $AA00; SetPort(saved);
 *   pm.rowBytes = rowBytes; pm.baseAddr = base; pm.bounds = bounds;
 *   port->portRect = bounds; RectRgn(port->visRgn, &bounds); return port (D0).
 * Unlike open_offscreen_cport_a5safe it does not OR 0x8000 into rowBytes (the
 * caller blit_offscreen_frame_to_window already does) and uses bounds as
 * portRect directly. No NULL check. JT $402; also called from ID03 0x3788.
 */
int new_offscreen_cport /* Original: FUN_00000ca6 */ (short rowBytes /* param_1 */,int baseAddr /* param_2 */,Rect bounds /* param_3 */)

{
  int unaff_A5;
  int port;                                     /* -$12(A6): CGrafPtr */
  int saved;                                    /* -$16(A6) */

  port = (int)NewPtrClear(0x6c);                /* JT $232 -> ID09 0x20c; sizeof(CGrafPort); no NIL test */
  saved = *(int *)(unaff_A5 + -0x160c);         /* thePort */
  OpenCPort(port);                              /* $AA00 */
  SetPort(saved);                               /* $A873 */
  *(short *)(**(int **)(port + 2) + 4) = rowBytes;   /* (**portPixMap).rowBytes */
  *(int *)**(int **)(port + 2) = baseAddr;           /* .baseAddr */
  *(Rect *)(**(int **)(port + 2) + 6) = bounds;    /* .bounds (two MOVE.L) */
  *(Rect *)(port + 0x10) = bounds;                 /* portRect */
  RectRgn(*(int *)(port + 0x18),&bounds);      /* $A8DF: visRgn = bounds */
  return port;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000d24): ID02.bin 0xd24..0xd38 checked against an independent capstone disassembly.
 * ClosePort(8(A6)) $A87D; JT $23a(8(A6)) (ID09 0x218 DisposPtr glue, callee pops) - identical to the C. */
/*
 * Original: FUN_00000d24; source: ID02.c:697-704.
 * Recovered name: close_and_dispose_port [STRONG INFERENCE].
 * Ghidra truncated at A-line $A87D; body rebuilt as C. Bytes file 0xd24..0xd38
 * [PROVEN]: arg GrafPtr port [8(A6)]; ClosePort(port) $A87D;
 * JT $23a(port) = ID09 file 0x218 DisposPtr glue ($A01F). Ghidra lost the arg.
 * Callers: rebuild_all_palette_index_maps (port = long A5-0x103a, then cleared);
 * ID03 file 0x3828 via JT $392.
 * [STRONG INFERENCE] A5-0x103a is a pointer-allocated GrafPort; the following
 * routine FUN_00000d3a (re)creates it when A5-0x103a == 0 (offscreen bitmap
 * with rowBytes = ((width * depth + 15) >> 4) * 2) - to be confirmed next.
 */
void close_and_dispose_port /* Original: FUN_00000d24 */ (int port /* param_1: GrafPtr allocated by new_offscreen_cport */)

{
  ClosePort(port);                           /* $A87D */
  DisposPtr((Ptr)port);                      /* JT $23a -> ID09 0x218 ($A01F glue) */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000d3a): ID02.bin 0xd3a..0xe3c checked against an independent capstone disassembly.
 * MOVEM D2-D7/A3-A5, A5 = $904; first call: rects, rowBytes = ((MULS.W w * depth + $f) ASR.W #4) * 2 ORI.W
 * #$8000, push dst Rect by value (two MOVE.L -(A0)), long 8(A6), word rowBytes, BSR 0xca6, LEA $e(A7);
 * per call baseAddr = 8(A6), src.bottom = word $12, dst.top = word $e, dst.bottom = low word of $c + $10
 * (ADD.L); mode CMPI.L #2 / #3 on $14; ForeColor($21), BackColor($1e), CopyBits(off+2, thePort+2,
 * A5-0x14f2, A5-0x14ea, 0, nil) $A8EC - identical to the C (widths corrected from Ghidra's short args). */
/*
 * Original: FUN_00000d3a; source: ID02.c:708-741.
 * Recovered name: blit_offscreen_frame_to_window [STRONG INFERENCE].
 * Ghidra truncated the tail at $A862 and lost the new_offscreen_cport arguments / rowBytes;
 * body completed from the bytes (arguments are four longs: only the low words of top / rows are used).
 * Args: param_1 = pixel base address, param_2 = destination top, param_3 =
 * row count, param_4 = mode (long). A5 is reloaded from CurrentA5 ($0904)
 * (Ghidra: DAT_00000904), so it is callable from overlay/foreign context.
 * First call (A5-0x103a == 0): srcRect A5-0x14f2 = (0, 0, A5-0x1370, A5-0x1372)
 * [top, left, bottom, right], dstRect A5-0x14ea = srcRect; rowBytes =
 * ((A5-0x1372 * A5-0x137a + 15) >> 4) * 2 | 0x8000 (PixMap flag; bytes
 * 0xd6e..0xd7e, the 0x8000 OR is not shown by Ghidra); port =
 * new_offscreen_cport (FUN_00000ca6)(rowBytes, base, bounds) -> A5-0x103a.
 * Each call: (**port->portPixMap).baseAddr = param_1; src.bottom = height;
 * dst.top = top; dst.bottom = top + height; dst.left/right = src.left/right;
 * mode 2 -> dst.left/right -= word A5-0x137e; mode 3 -> += A5-0x137e.
 * Tail [PROVEN bytes 0xe0a..0xe3c]: ForeColor(33 blackColor) $A862;
 * BackColor(30 whiteColor) $A863; CopyBits(&off->portBits (+2),
 * &thePort->portBits (+2), &src, &dst, 0 srcCopy, nil) $A8EC.
 * Callers / references [PROVEN bytes]: JT A5+0x322; ID06 file 0xf18 JSR;
 * ID02 file 0x1b6a LEA $322(A5) (address taken - likely handed to the
 * overlay as a callback [HYPOTHESIS]).
 */
void blit_offscreen_frame_to_window /* Original: FUN_00000d3a */ (undefined4 pixels /* param_1: frame buffer base address */,int dst_top /* param_2: window row of the first line */,int rows /* param_3: lines to copy */,int shift_mode /* param_4: 2 = shift left, 3 = shift right by A5-0x137e */)

{
  int a5; /* iVar1: copy of CurrentA5 */
  short rowBytes;                               /* -$42(A6) */

  a5 = CurrentA5;                         /* CurrentA5; D2-D7 / A3-A5 saved with MOVEM */
  if (*(int *)(CurrentA5 + -0x103a) == 0) {
    *(undefined2 *)(CurrentA5 + -0x14f0) = 0;
    *(undefined2 *)(a5 + -0x14f2) = 0;
    *(undefined2 *)(a5 + -0x14ec) = *(undefined2 *)(a5 + -0x1372);
    *(undefined2 *)(a5 + -0x14ee) = *(undefined2 *)(a5 + -0x1370);
    *(undefined4 *)(a5 + -0x14ea) = *(undefined4 *)(a5 + -0x14f2);
    *(undefined4 *)(a5 + -0x14e6) = *(undefined4 *)(a5 + -0x14ee);
    rowBytes = ((short)(*(short *)(a5 + -0x1372) * *(short *)(a5 + -0x137a) + 0xf) >> 4) * 2 | 0x8000;
                                                /* MULS.W, ADDI.W #$f, ASR.W #4, ADD.W, ORI.W #$8000 */
    *(undefined4 *)(a5 + -0x103a) =
         new_offscreen_cport(rowBytes,pixels,*(Rect *)(a5 + -0x14ea)); /* BSR 0xca6, Rect by value */
  }
  *(undefined4 *)**(undefined4 **)(*(int *)(a5 + -0x103a) + 2) = pixels;
  *(short *)(a5 + -0x14ee) = (short)rows; /* low words $12 / $e(A6) */
  *(short *)(a5 + -0x14ea) = (short)dst_top;
  *(short *)(a5 + -0x14e6) = (short)(dst_top + rows); /* ADD.L, low word */
  *(undefined2 *)(a5 + -0x14e8) = *(undefined2 *)(a5 + -0x14f0);
  *(undefined2 *)(a5 + -0x14e4) = *(undefined2 *)(a5 + -0x14ec);
  if (shift_mode == 2) {
    *(short *)(a5 + -0x14e8) = *(short *)(a5 + -0x14e8) - *(short *)(a5 + -0x137e);
    *(short *)(a5 + -0x14e4) = *(short *)(a5 + -0x14e4) - *(short *)(a5 + -0x137e);
  }
  else if (shift_mode == 3) {
    *(short *)(a5 + -0x14e8) = *(short *)(a5 + -0x137e) + *(short *)(a5 + -0x14e8);
    *(short *)(a5 + -0x14e4) = *(short *)(a5 + -0x137e) + *(short *)(a5 + -0x14e4);
  }
  ForeColor(0x21);                              /* $A862 blackColor */
  BackColor(0x1e);                              /* $A863 whiteColor */
  CopyBits((void *)(*(int *)(a5 + -0x103a) + 2),(void *)(*(int *)(a5 + -0x160c) + 2),
           (Rect *)(a5 + -0x14f2),(Rect *)(a5 + -0x14ea),0,0); /* $A8EC, srcCopy, no mask */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000e3e): ID02.bin 0xe3e..0xe9c checked against an independent capstone disassembly.
 * A5 thunk; baseAddr = $c; ForeColor($21); BackColor($1e); TST.L $14 / BNE, else $14 = thePort;
 * CopyBits(src+2, dst+2, long $10, long $18, 0, nil) - identical to the C. */
/*
 * Original: FUN_00000e3e; source: ID02.c:749.
 * Recovered name: blit_pixels_via_port_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x10ee (JT $34a).
 * Bytes 0xe3e..0xe9c [PROVEN]; Ghidra truncated after the first store (body rebuilt as C).
 * Args: GrafPtr src_port [8], Ptr base [$c], Rect *src [$10], GrafPtr dst
 * [$14] (0 = thePort), Rect *dst [$18].
 *   (**src_port->portPixMap).baseAddr = base; ForeColor(black) $A862;
 *   BackColor(white) $A863; if (!dst_port) dst_port = thePort (A5-0x160c);
 *   CopyBits(&src_port->portBits, &dst_port->portBits, src, dst, srcCopy, nil).
 * General form of blit_offscreen_frame_to_window [STRONG INFERENCE].
 */
void blit_pixels_via_port_a5safe /* Original: FUN_00000e3e */
               (int src_port /* param_1 */,undefined4 pixels /* param_2: base address for the source pixmap */,Rect *src_rect /* param_3 */,int dst_port /* param_4: 0 = thePort */,Rect *dst_rect /* param_5 */)

{
  int unaff_A5;

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  *(undefined4 *)**(undefined4 **)(src_port + 2) = pixels;
  ForeColor(0x21);                              /* $A862 */
  BackColor(0x1e);                              /* $A863 */
  if (dst_port == 0) {
    dst_port = *(int *)(unaff_A5 + -0x160c);     /* thePort, stored back into $14(A6) */
  }
  CopyBits((void *)(src_port + 2),(void *)(dst_port + 2),src_rect,dst_rect,0,0); /* $A8EC */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000e9e): ID02.bin 0xe9e..0xf50 checked against an independent capstone disassembly.
 * A5 thunk; saved = thePort; OpenCPort(8); SetPort(saved); pm.rowBytes = low word of (#$8000 OR.L $c);
 * baseAddr = $10; bounds = *$14 (two MOVE.L); rect -$1e = {0, 0, b[2] - b[0], b[3] - b[1]} to port+$10;
 * RectRgn(port+$18, -$1e) - identical to the C. */
/*
 * Original: FUN_00000e9e; source: ID02.c:761.
 * Recovered name: open_offscreen_cport_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x1106 (JT $3d2).
 * Bytes 0xe9e..0xf50 [PROVEN]; Ghidra exported no body (rebuilt as C). Args: CGrafPtr port
 * [8], long rowBytes [$c], Ptr base [$10], Rect *bounds [$14].
 *   saved = thePort; OpenCPort(port) $AA00; SetPort(saved);
 *   pm = *port->portPixMap: pm.rowBytes = rowBytes | 0x8000 (PixMap flag);
 *   pm.baseAddr = base; pm.bounds = *bounds;
 *   portRect (+0x10) = (0, 0, bounds.bottom - bounds.top, bounds.right - bounds.left);
 *   RectRgn(port->visRgn (+0x18), &portRect) $A8DF.
 * new_offscreen_cport (FUN_00000ca6) performs the same steps inline on a
 * freshly allocated port (it does not call this routine).
 */
void open_offscreen_cport_a5safe /* Original: FUN_00000e9e */ (int port /* param_1: caller-allocated CGrafPort */,int rowBytes /* param_2: OR 0x8000 = PixMap */,int baseAddr /* param_3 */,short *bounds /* param_4: Rect */)

{
  int unaff_A5;
  int saved;                                    /* -$12(A6) */
  short r[4];                                   /* -$1e(A6): portRect */

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  saved = *(int *)(unaff_A5 + -0x160c);
  OpenCPort(port);                           /* $AA00 */
  SetPort(saved);                               /* $A873 */
  *(short *)(**(int **)(port + 2) + 4) = (short)(rowBytes | 0x8000); /* OR.L, low word */
  *(int *)**(int **)(port + 2) = baseAddr;
  *(Rect *)(**(int **)(port + 2) + 6) = *(Rect *)bounds;
  r[1] = 0;
  r[0] = 0;
  r[3] = bounds[3] - bounds[1];
  r[2] = bounds[2] - bounds[0];
  *(Rect *)(port + 0x10) = *(Rect *)r;
  RectRgn(*(int *)(port + 0x18),r);          /* $A8DF */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000f52): ID02.bin 0xf52..0xf72 checked against an independent capstone disassembly.
 * A5 thunk; ClosePort(8(A6)) $A87D - identical to the C. */
/*
 * Original: FUN_00000f52; source: ID02.c:772.
 * Recovered name: close_port_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x10fe (JT $312).
 * Bytes 0xf52..0xf72 [PROVEN]: CurrentA5 thunk; ClosePort(port long arg) $A87D.
 * Ghidra lost the argument.
 */
void close_port_a5safe /* Original: FUN_00000f52 */ (int port /* param_1 */)

{
  ClosePort(port);                           /* $A87D; A5 = CurrentA5 around it, A5 / D2 restored */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000f74): ID02.bin 0xf74..0xf9e checked against an independent capstone disassembly.
 * LINK -$c, A5 / D2 saved, A5 = $904; -4 = thePort; SetPort(8(A6)); D2 / A5 restored; D0 = -4 - identical to
 * the C. */
/*
 * Original: FUN_00000f74; source: ID02.c:783.
 * Recovered name: swap_port_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x1102 (JT $352).
 * Bytes 0xf74..0xf9e [PROVEN]: CurrentA5 thunk; old = thePort (long A5-0x160c);
 * SetPort(port arg) $A873; returns old in D0. Ghidra lost argument and result
 * (body rebuilt as C).
 */
int swap_port_a5safe /* Original: FUN_00000f74 */ (int port /* param_1: the new current port */)

{
  int unaff_A5;
  int old;                                      /* -4(A6) */

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored before the return */
  old = *(int *)(unaff_A5 + -0x160c);           /* thePort */
  SetPort(port);                             /* $A873 */
  return old;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000fa0): ID02.bin 0xfa0..0xfd0 checked against an independent capstone disassembly.
 * A5 thunk; word $e(A6) to BSR 0x15cc set_draw_color_index; PaintRect(long 8(A6)); PenPat(A5-0x161c) -
 * identical to the C. */
/*
 * Original: FUN_00000fa0; source: ID02.c:794.
 * Recovered name: paint_rect_color_index_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x10fa (JT $39a).
 * Bytes 0xfa0..0xfd0 [PROVEN]: CurrentA5 thunk; set_draw_color_index(word
 * colour at $e(A6) = low word of 2nd long); PaintRect(Rect *param_1) $A8A2;
 * PenPat(A5-0x161c) $A89D (restore pattern). Ghidra truncated after the colour call
 * (body rebuilt as C).
 */
void paint_rect_color_index_a5safe /* Original: FUN_00000fa0 */ (Rect *rect /* param_1 */,int colour_index /* param_2 */)

{
  int unaff_A5;

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  set_draw_color_index((short)colour_index);         /* BSR 0x15cc, word $e(A6) */
  PaintRect(rect);                           /* $A8A2 */
  PenPat((void *)(unaff_A5 + -0x161c));         /* $A89D */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00000fd2): ID02.bin 0xfd2..0x10cc checked against an independent capstone disassembly.
 * A5 thunk; RGBColor -8 / -6 / -4 = ((rgb ASR #24 / #16 / #8) & $ff) LSL #8; OpenPoly; MoveTo(word +2 of
 * pts[n-1].x, low word of NEG.L pts[n-1].y); word i from 0, MOVEA.W i CMPA.L count BLT: LineTo(pts[i]
 * likewise); ClosePoly; CMPI.W #1 A5-0x137a: push the 6-byte RGBColor (MOVE.L / MOVE.W -(A0)) to JT $1ca
 * (CODE 0 entry seg 6 -> ID06 0x116 rgb_to_bw_pattern), FillPoly(poly, D0); else RGBForeColor(-8),
 * PaintPoly; KillPoly - identical to the C. */
/*
 * Original: FUN_00000fd2; source: ID02.c:808.
 * Recovered name: paint_polygon_rgb_a5safe [STRONG INFERENCE].
 * Overlay service slot A5-0x10f6 (JT $3f2).
 * Bytes 0xfd2..0x10cc [PROVEN]: CurrentA5 thunk. Args: long *pts [8] (count
 * pairs {x long, y long}), long count [$c], long rgb [$10] = 0xRRGGBBxx.
 *   RGBColor c = { (rgb>>24 & 0xff) << 8, (rgb>>16 & 0xff) << 8, (rgb>>8 & 0xff) << 8 };
 *   poly = OpenPoly $A8CB; MoveTo(pts[n-1].x, -pts[n-1].y); for i < n:
 *     LineTo(pts[i].x, -pts[i].y) $A891;  ClosePoly $A8CC;
 *   1-bit branch: JT $1ca (segment 6 file 0x116, pattern helper) + FillPoly
 *   $A8CA; colour branch: RGBForeColor(&c) $AA14 + PaintPoly $A8C7;
 *   KillPoly $A8CD.
 * y is negated (world-up to screen-down) [STRONG INFERENCE]; the 1-bit branch is
 * taken when the depth word A5-0x137a == 1 [PROVEN] (body rebuilt as C).
 */
void paint_polygon_rgb_a5safe /* Original: FUN_00000fd2 */ (int *points /* param_1: (x, y) long pairs, y negated when drawn */,int count /* param_2: number of points */,uint rgb /* param_3: 0xRRGGBB00, one byte per component */)

{
  int unaff_A5;
  short c[3];                                   /* -8(A6): RGBColor */
  int poly;                                     /* -$c(A6) */
  short i;                                      /* -2(A6) */

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  c[0] = (short)(((int)rgb >> 0x18 & 0xffU) << 8);
  c[1] = (short)(((int)rgb >> 0x10 & 0xffU) << 8);
  c[2] = (short)(((int)rgb >> 8 & 0xffU) << 8);
  poly = OpenPoly();                            /* $A8CB */
  MoveTo((short)points[(count + -1) * 2],(short)-points[(count + -1) * 2 + 1]); /* $A893, h first */
  for (i = 0; (int)i < count; i = i + 1) {
    LineTo((short)points[(int)i * 2],(short)-points[(int)i * 2 + 1]); /* $A891 */
  }
  ClosePoly();                                  /* $A8CC */
  if (*(short *)(unaff_A5 + -0x137a) == 1) {    /* 1-bit screen */
    FillPoly(poly,rgb_to_bw_pattern(*(RGBColor *)c)); /* JT $1ca -> ID06 0x116 (6 bytes by value); $A8CA */
  }
  else {
    RGBForeColor(c);                            /* $AA14 */
    PaintPoly(poly);                            /* $A8C7 */
  }
  KillPoly(poly);                               /* $A8CD */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_000010ce): ID02.bin 0x10ce..0x11ea checked against an independent capstone disassembly.
 * LINK -8; OpenPoly; SUB.W pnSize.h (+$36) from $e, pnSize.v (+$34) from $c; c = EXT.L(ASL.W #2 (right -
 * left)) DIVS.W #16; d = (c DIVS.W #2) + c - (pnSize.v DIVS.W #2); MoveTo / LineTo / Line pushes h then v in the
 * order of the C (including the tail Line(c, -c), Line(-c, -c), Line(0, -d)); ClosePoly; D0 = poly -
 * identical to the C. */
/*
 * Original: FUN_000010ce; source: ID02.c:819.
 * Recovered name: build_notched_frame_poly [STRONG INFERENCE mechanics]
 *. Ghidra exported no body (rebuilt as C below). Bytes 0x10ce..0x11ea [PROVEN].
 * Arg: Rect r by value (top 8, left $a, bottom $c, right $e). Returns PolyHandle.
 *   poly = OpenPoly; r.right -= thePort->pnSize.h (+0x36);
 *   r.bottom -= thePort->pnSize.v (+0x34);
 *   c = ((r.right - r.left) * 4) / 16  (DIVS.W; width/4);
 *   d = c + c/2 - pnSize.v/2;
 *   MoveTo(left, top); LineTo(right, top); Line(0, d); Line(-c, c); Line(c, c);
 *   LineTo(right, bottom - c); LineTo(right - c, bottom); LineTo(left + c, bottom);
 *   LineTo(left, bottom - c); LineTo(left, top + d + 2c); Line(c, -c); Line(-c, -c);
 *   Line(c, -c); Line(-c, -c); Line(0, -d); ClosePoly; return poly.
 * Shape: frame with V-notches on both sides and chamfered bottom corners.
 * Purpose UNKNOWN (UI decoration). Caller: draw_notched_frame_pair_a5safe.
 */
int build_notched_frame_poly /* Original: FUN_000010ce */ (short top,short left,short bottom,short right)

{
  int unaff_A5;
  int poly;                                     /* -4(A6) */
  short c;                                      /* -6(A6) */
  short d;                                      /* -8(A6) */

  poly = OpenPoly();                            /* $A8CB */
  right = right - *(short *)(*(int *)(unaff_A5 + -0x160c) + 0x36); /* pnSize.h */
  bottom = bottom - *(short *)(*(int *)(unaff_A5 + -0x160c) + 0x34); /* pnSize.v */
  c = (short)((int)(short)((right - left) << 2) / 0x10); /* ASL.W #2, EXT.L, DIVS.W #16 */
  d = ((short)((int)c / 2) + c) - (short)((int)*(short *)(*(int *)(unaff_A5 + -0x160c) + 0x34) / 2);
  MoveTo(left,top);                             /* $A893 (h, v) */
  LineTo(right,top);                            /* $A891 */
  Line(0,d);                                    /* $A892 */
  Line(-c,c);
  Line(c,c);
  LineTo(right,bottom - c);
  LineTo(right - c,bottom);
  LineTo(left + c,bottom);
  LineTo(left,bottom - c);
  LineTo(left,top + d + c + c);
  Line(c,-c);
  Line(-c,-c);
  Line(0,-d);
  ClosePoly();                                  /* $A8CC */
  return poly;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_000011ec): ID02.bin 0x11ec..0x1306 checked against an independent capstone disassembly.
 * A5 thunk; PenSize(2, 2) + BSR 0x10ce(Rect A5-0x119c by value) -> -$c; PenSize(1, 1) + BSR 0x10ce -> -8;
 * ForeColor($21), BackColor($1e); word i 0..1 (CMPI.W #2 / BLT.W): colour word $e, back colour A5-0x118c,
 * PenSize(1, 1), TST.L 8 -> PaintPoly(inner) else FillPoly(inner, A5-0x14e2); colour A5-0x118c, PenSize(2,
 * 2), FramePoly(outer); colour A5-0x118a, PenSize(1, 1), FramePoly(inner); dx = A5-0x1192 - A5-0x119a,
 * OffsetPoly(inner, dx, 0), OffsetPoly(outer, dx, 0); MOVE.L $10 to $c; KillPoly x2; PenPat(A5-0x161c) -
 * identical to the C. */
/*
 * Original: FUN_000011ec; source: ID02.c:830.
 * Recovered name: draw_notched_frame_pair_a5safe [STRONG INFERENCE mechanics /
 * UNKNOWN purpose] (; INVESTIGATING).
 *: both polygons come from the same Rect at A5-0x119c (8 bytes
 * ending at A5-0x1194), built by build_notched_frame_poly with PenSize 2 and
 * then PenSize 1 (outer and inner outline); the shift A5-0x1192 - A5-0x119a
 * (a value minus rect.left) moves the pair for the second copy. Overlay service
 * slot A5-0x10ea (JT $3c2). Ghidra exported no body (rebuilt as C below; args: long paint flag 8,
 * colour long $c, second-pass colour long $10). Bytes 0x11ec..0x1306
 * [PROVEN]: CurrentA5 thunk; two polygons built by
 * FUN_000010ce from data at A5-0x1194 (each after PenSize); black/white;
 * loop x2: set_draw_color_index(...), set_back_color_index (FUN_00001632)(A5-0x118c), PaintPoly,
 * FillPoly(pattern A5-0x14e2), FramePoly in standard grey indices A5-0x118c /
 * A5-0x118a (init_standard_colour_indices), then OffsetPoly both by
 * (A5-0x1192 - A5-0x119a); KillPoly both; PenPat(A5-0x161c).
 * [UNKNOWN] What the shapes are (possibly a bevelled UI frame drawn twice).
 */
void draw_notched_frame_pair_a5safe /* Original: FUN_000011ec */ (int solid /* param_1: 0 = fill the inner frame with the A5-0x14e2 pattern, else paint it */,int colour_index /* param_2: inner frame colour, first pass */,int colour_index2 /* param_3: inner frame colour, second pass */)

{
  int unaff_A5;
  int outer;                                    /* -$c(A6) */
  int inner;                                    /* -8(A6) */
  short dx;                                     /* -4(A6) */
  short i;                                      /* -2(A6) */

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  PenSize(2,2);                                 /* $A89B */
  outer = build_notched_frame_poly(*(Rect *)(unaff_A5 + -0x119c)); /* BSR 0x10ce, Rect by value */
  PenSize(1,1);
  inner = build_notched_frame_poly(*(Rect *)(unaff_A5 + -0x119c));
  ForeColor(0x21);                              /* $A862 */
  BackColor(0x1e);                              /* $A863 */
  for (i = 0; i < 2; i = i + 1) {
    set_draw_color_index((short)colour_index);       /* BSR 0x15cc, word $e(A6) */
    set_back_color_index(*(short *)(unaff_A5 + -0x118c)); /* BSR 0x1632 */
    PenSize(1,1);
    if (solid == 0) {
      FillPoly(inner,(void *)(unaff_A5 + -0x14e2)); /* $A8CA */
    }
    else {
      PaintPoly(inner);                         /* $A8C7 */
    }
    set_draw_color_index(*(short *)(unaff_A5 + -0x118c));
    PenSize(2,2);
    FramePoly(outer);                           /* $A8C6 */
    set_draw_color_index(*(short *)(unaff_A5 + -0x118a));
    PenSize(1,1);
    FramePoly(inner);
    dx = *(short *)(unaff_A5 + -0x1192) - *(short *)(unaff_A5 + -0x119a);
    OffsetPoly(inner,dx,0);                     /* $A8CE */
    OffsetPoly(outer,dx,0);
    colour_index = colour_index2;                          /* second pass uses the $10(A6) colour */
  }
  KillPoly(inner);                              /* $A8CD */
  KillPoly(outer);
  PenPat((void *)(unaff_A5 + -0x161c));         /* $A89D */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00001308): ID02.bin 0x1308..0x14e4 checked against an independent capstone disassembly.
 * A5 thunk; TST.L $18 / BEQ.W. Layout: rect -$e {A5-0x1370 - 20, 0, +1, A5-0x1372}, ForeColor($21),
 * BackColor($1e), FillRect(black A5-0x161c); rect {A5-0x1370 - 19, ., A5-0x1370, .} FillRect(white
 * A5-0x1614); MoveTo(8, A5-0x1370 - 5); TextFace(1); CharWidth('0') to -$10; TextFace(0); three DrawString
 * (A5-0xde2 / -0xdde / -0xdda) each with GetPen(-6), x = pen.h + w to A5-0x14da / -0x14d8 / -0x14d6, width
 * (MULS.W #5, MULS.W #3, ASL.W #2) to A5-0x14d2 / -0x14d0 / -0x14ce and Move(2w + width, 0); TST.L $1c
 * BNE skips the fourth (A5-0xdd6 -> A5-0x14d4 / -0x14cc, no Move). Value: index long $c ADD.L doubled into
 * both arrays, white FillRect, TextFace(1), MoveTo(x, A5-0x1370 - 5), DrawText(8, word $12, word $16) -
 * identical to the C. */
/*
 * Original: FUN_00001308; source: ID02.c:841.
 * Recovered name: draw_text_in_columns_a5safe [STRONG INFERENCE mechanics /
 * HYPOTHESIS purpose]. Overlay service slot A5-0x110e (JT $362).
 * Ghidra exported only two truncated branches (on the long arg $18(A6)); body
 * rebuilt as C below. Args: text 8, column index $c, first byte $10, byte count $14,
 * layout flag $18, skip-fourth-label flag $1c. Bytes 0x1308..0x14e4 [PROVEN, condensed reading]:
 *   CurrentA5 thunk; ForeColor(black) / BackColor(white);
 *   if ($18 != 0): FillRect(r, QD black pattern A5-0x161c) $A8A5 and
 *     FillRect(r', QD white pattern A5-0x1614); MoveTo; TextFace $A888;
 *     CharWidth $A88D; then three DrawString $A884 segments, each followed by
 *     GetPen $A89A and Move $A894 to column x = base + k*w (k = 5, 3, 4 with
 *     column origins A5-0x14d2 / -0x14d0 / -0x14ce); a fourth segment when
 *     long $1c(A6) == 0;
 *   else: white FillRect, TextFace, MoveTo, DrawText $A885 (single string).
 * QD globals: thePort A5-0x160c, white A5-0x1614, black A5-0x161c (standard
 * QuickDraw global order). Argument layout and column meaning UNKNOWN
 * (status / score line HYPOTHESIS).
 */
void draw_text_in_columns_a5safe /* Original: FUN_00001308 */
               (void *text /* param_1 */,int column /* param_2: column 0..3 */,int first_byte /* param_3 */,int byte_count /* param_4 */,int layout /* param_5: nonzero = draw the bar and its labels */,int three_columns /* param_6: nonzero = omit the fourth label */)

{
  int unaff_A5;
  short r[4];                                   /* -$e(A6): Rect top, left (-$c), bottom (-$a), right (-8) */
  short charW;                                  /* -$10(A6) */
  short pen[2];                                 /* -6(A6): Point v, h (-4) */

  unaff_A5 = *(int *)0x904;                     /* CurrentA5; A5 / D2 restored on exit */
  if (layout != 0) {                           /* lay out the bar and its labels */
    r[1] = 0;
    r[3] = *(short *)(unaff_A5 + -0x1372);
    r[0] = *(short *)(unaff_A5 + -0x1370) + -0x14;
    r[2] = r[0] + 1;
    ForeColor(0x21);                            /* $A862 */
    BackColor(0x1e);                            /* $A863 */
    FillRect(r,(void *)(unaff_A5 + -0x161c));   /* $A8A5, QD black */
    r[0] = *(short *)(unaff_A5 + -0x1370) + -0x13;
    r[2] = *(short *)(unaff_A5 + -0x1370);
    FillRect(r,(void *)(unaff_A5 + -0x1614));   /* QD white */
    MoveTo(8,*(short *)(unaff_A5 + -0x1370) + -5); /* $A893 */
    TextFace(1);                                /* $A888, bold */
    charW = CharWidth('0');                     /* $A88D */
    TextFace(0);
    DrawString(*(void **)(unaff_A5 + -0xde2));  /* $A884 */
    GetPen(pen);                                /* $A89A */
    *(short *)(unaff_A5 + -0x14da) = pen[1] + charW;
    *(short *)(unaff_A5 + -0x14d2) = charW * 5;
    Move(charW * 2 + *(short *)(unaff_A5 + -0x14d2),0); /* $A894 */
    DrawString(*(void **)(unaff_A5 + -0xdde));
    GetPen(pen);
    *(short *)(unaff_A5 + -0x14d8) = pen[1] + charW;
    *(short *)(unaff_A5 + -0x14d0) = charW * 3;
    Move(charW * 2 + *(short *)(unaff_A5 + -0x14d0),0);
    DrawString(*(void **)(unaff_A5 + -0xdda));
    GetPen(pen);
    *(short *)(unaff_A5 + -0x14d6) = pen[1] + charW;
    *(short *)(unaff_A5 + -0x14ce) = charW << 2;
    Move(charW * 2 + *(short *)(unaff_A5 + -0x14ce),0);
    if (three_columns == 0) {
      DrawString(*(void **)(unaff_A5 + -0xdd6));
      GetPen(pen);
      *(short *)(unaff_A5 + -0x14d4) = pen[1] + charW;
      *(short *)(unaff_A5 + -0x14cc) = charW << 2;
    }
  }
  else {                                        /* redraw one column's value */
    r[1] = *(short *)(unaff_A5 + -0x14da + column * 2);
    r[3] = r[1] + *(short *)(unaff_A5 + -0x14d2 + column * 2);
    r[0] = *(short *)(unaff_A5 + -0x1370) + -0x13;
    r[2] = *(short *)(unaff_A5 + -0x1370);
    ForeColor(0x21);
    BackColor(0x1e);
    FillRect(r,(void *)(unaff_A5 + -0x1614));
    TextFace(1);
    MoveTo(*(short *)(unaff_A5 + -0x14da + column * 2),*(short *)(unaff_A5 + -0x1370) + -5);
    DrawText(text,(short)first_byte,(short)byte_count); /* $A885; words $12 / $16(A6) */
  }
  return;
}



/* VERIFIED (ID02::FUN_000014e6): ID02.bin 0x14e6..0x1508 checked against an independent capstone disassembly.
 * A5 thunk; PEA -$1000(A5), JSR $2e2(A5) (CODE 0 entry seg 9 -> ID09 0x3c2 swapmmumode_glue) - identical
 * to the C. */
/*
 * Original: FUN_000014e6; source: ID02.c:856.
 * Recovered name: swap_mmu_mode_a5safe [STRONG INFERENCE].
 * Bytes 0x14e6..0x1508 match the C [PROVEN]: CurrentA5 thunk; JT $2e2 =
 * ID09 file 0x3c2 swapmmumode_glue (SwapMMUMode, $A05D) with &byte A5-0x1000
 * (VAR mode: the caller-visible 24/32-bit addressing mode byte).
 * Overlay service slot A5-0x10c6 (JT $35a).
 */
void swap_mmu_mode_a5safe /* Original: FUN_000014e6 */ (void)

{
  (**(code **)(CurrentA5 + 0x2e2))(CurrentA5 + -0x1000);
  return;
}



/* VERIFIED (ID02::FUN_0000150a): ID02.bin 0x150a..0x15ca checked against an independent capstone disassembly.
 * CMPI.W #1 A5-0x137a / BNE.W -> LEA A5-0x1624; fg / bg entry pointers from A5-0x13ba / -0x13b8 (CMPI.W #8 /
 * BLE: A5-0x350 + MULS.W #6, else *(A5-0x14a6) + MULS.W #6 of (i - 8)); three ADD.W / LSR.W #1 averages to
 * -$e / -$c / -$a; 6-byte RGBColor pushed by value to JT $1ca (ID06 0x116 rgb_to_bw_pattern), D0 returned -
 * identical to the C (Ghidra had dropped the colour lookup and the argument). */
/* Original: FUN_0000150a; source: ID02.c. Recovered name: get_blended_fill_pattern [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x150a.
 * Returns a Pattern pointer. Depth 1 (A5-0x137a == 1): takes the 6-byte RGB entries of the current foreground index A5-0x13ba and background index A5-0x13b8 (indices <= 8 from the table at A5-0x350, higher ones from *A5-0x14a6 + (index - 8) * 6), averages the two colours component by component (LSR #1) and returns the dither pattern from ID06 rgb_to_bw_pattern (JT $1ca) [PROVEN, bytes 0x150a..0x15ca]. Other depths: returns the QuickDraw gray pattern A5-0x1624. Reached through JT $3e2 (FillPoly callers in ID03 draw_bevelled_frame).
 */
int get_blended_fill_pattern /* Original: FUN_0000150a */ (void)

{
  int pattern; /* iVar1 */
  int unaff_A5;
  ushort *fg;                                   /* -4(A6) */
  ushort *bg;                                   /* -8(A6) */
  ushort mix[3];                                /* -$e(A6): RGBColor */

  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    if (*(short *)(unaff_A5 + -0x13ba) < 9) {   /* CMPI.W #8 / BLE */
      fg = (ushort *)(unaff_A5 + -0x350 + *(short *)(unaff_A5 + -0x13ba) * 6);
    }
    else {
      fg = (ushort *)(*(int *)(unaff_A5 + -0x14a6) + (short)(*(short *)(unaff_A5 + -0x13ba) + -8) * 6);
    }
    if (*(short *)(unaff_A5 + -0x13b8) < 9) {
      bg = (ushort *)(unaff_A5 + -0x350 + *(short *)(unaff_A5 + -0x13b8) * 6);
    }
    else {
      bg = (ushort *)(*(int *)(unaff_A5 + -0x14a6) + (short)(*(short *)(unaff_A5 + -0x13b8) + -8) * 6);
    }
    mix[0] = (ushort)(fg[0] + bg[0]) >> 1;      /* ADD.W, LSR.W #1: the sum wraps at 16 bits */
    mix[1] = (ushort)(fg[1] + bg[1]) >> 1;
    mix[2] = (ushort)(fg[2] + bg[2]) >> 1;
    pattern = rgb_to_bw_pattern(*(RGBColor *)mix); /* JT $1ca -> ID06 0x116, 6 bytes by value */
  }
  else {
    pattern = unaff_A5 + -0x1624;                 /* QD gray pattern */
  }
  return pattern;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_000015cc): ID02.bin 0x15cc..0x1630 checked against an independent capstone disassembly.
 * 1-bit: MOVE.W 8(A6) to A5-0x13ba, entry as in get_blended_fill_pattern, push the 6-byte entry by value
 * to JT $1ca, PenPat(D0) $A89D; else thePort+$50 = MOVEA.W 8(A6) (sign-extended) - identical to the C (the
 * truncated branch completed, the zero-extension through undefined2 corrected). */
/*
 * Original: FUN_000015cc; source: ID02.c:884.
 * Recovered name: set_draw_color_index [STRONG INFERENCE].
 * Ghidra truncated the 1-bit branch; body completed from the bytes. Arg: word colour index.
 *   if (mode word A5-0x137a == 1) { A5-0x13ba = colour; entry = colour <= 8 ? A5-0x350 + 6c :
 *     *A5-0x14a6 + 6(c - 8); PenPat(rgb_to_bw_pattern(*entry)) (JT $1ca -> ID06 0x116) }
 *   else thePort (A5-0x160c)->fgColor (+0x50) = (long)colour.
 * Callers: paint_view_horizon_bands_a5safe (4x), paint_rect_color_index_a5safe
 * (FUN_00000fa0, ID02.c:799).
 */
void set_draw_color_index /* Original: FUN_000015cc */ (short index /* param_1: palette index */)

{
  int unaff_A5;
  ushort *entry;                                /* -4(A6) */

  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    *(short *)(unaff_A5 + -0x13ba) = index;
    if (index < 9) {                          /* CMPI.W #8 / BLE */
      entry = (ushort *)(unaff_A5 + -0x350 + index * 6);
    }
    else {
      entry = (ushort *)(*(int *)(unaff_A5 + -0x14a6) + (short)(index + -8) * 6);
    }
    PenPat((void *)rgb_to_bw_pattern(*(RGBColor *)entry)); /* JT $1ca -> ID06 0x116; $A89D */
    return;
  }
  *(int *)(*(int *)(unaff_A5 + -0x160c) + 0x50) = (int)index; /* MOVEA.W: sign-extended */
  return;
}



/* VERIFIED (ID02::FUN_00001632): ID02.bin 0x1632..0x1654 checked against an independent capstone disassembly.
 * 1-bit: MOVE.W 8(A6) to A5-0x13b8; else thePort+$54 = MOVEA.W 8(A6) (sign-extended) - identical to the C
 * after the sign-extension correction. */
/*
 * Original: FUN_00001632; source: ID02.c:901.
 * Recovered name: set_back_color_index [STRONG INFERENCE].
 * Bytes 0x1632..0x1654; the stored index is sign-extended (MOVEA.W). Background twin of
 * set_draw_color_index: 1-bit mode (A5-0x137a == 1) -> word A5-0x13b8 =
 * colour; else thePort->bkColor (+0x54) = (long)colour.
 */
void set_back_color_index /* Original: FUN_00001632 */ (short index /* param_1: palette index */)

{
  int unaff_A5;

  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    *(short *)(unaff_A5 + -0x13b8) = index;
  }
  else {
    *(int *)(*(int *)(unaff_A5 + -0x160c) + 0x54) = (int)index; /* MOVEA.W: sign-extended */
  }
  return;
}



/* VERIFIED (ID02::FUN_00001656): ID02.bin 0x1656..0x167e checked against an independent capstone disassembly.
 * D0 = MOVEA.W A5-0x1372 DIVS.W #2; D1 = MOVEA.W 8(A6) (sign-extended) MULU.L A5-0x149e (low 32 bits = the
 * signed product), DIVS.L #$12c0 (extension 0x1801, quotient only); EXT.L D0, ADD.L - identical to the C
 * after the sign-extension correction. */
/*
 * Original: FUN_00001656; source: ID02.c:917.
 * Recovered name: design_x_to_screen [STRONG INFERENCE].
 * JT $3ca; the word argument is sign-extended (C corrected from undefined2). (long A5-0x149e * v) / 4800 + view width
 * (A5-0x1372) / 2 -> screen x of a design x [STRONG INFERENCE]. Bytes use
 * MULU.L on the sign-extended word (low 32 bits equal the signed product) and
 * DIVS.L #$12c0.
 */
int design_x_to_screen /* Original: FUN_00001656 */ (short design_x /* param_1 */)

{
  int unaff_A5;
  
  return (*(int *)(unaff_A5 + -0x149e) * (int)design_x) / 0x12c0 + /* MOVEA.W: sign-extended */
         (int)(*(short *)(unaff_A5 + -0x1372) / 2);
}



/* VERIFIED (ID02::FUN_00001680): ID02.bin 0x1680..0x16a8 checked against an independent capstone disassembly.
 * Same body with A5-0x1370 - identical to the C after the sign-extension correction. */
/*
 * Original: FUN_00001680; source: ID02.c:928.
 * Recovered name: design_y_to_screen [STRONG INFERENCE].
 * JT $382; sign-extended word argument (C corrected). Same as design_x_to_screen with view height
 * (A5-0x1370) / 2 -> screen y.
 */
int design_y_to_screen /* Original: FUN_00001680 */ (short design_y /* param_1 */)

{
  int unaff_A5;
  
  return (*(int *)(unaff_A5 + -0x149e) * (int)design_y) / 0x12c0 + /* MOVEA.W: sign-extended */
         (int)(*(short *)(unaff_A5 + -0x1370) / 2);
}



/* VERIFIED (ID02::FUN_000016aa): ID02.bin 0x16aa..0x1874 checked against an independent capstone disassembly.
 * CMPI.W #1 A5-0x137a / BNE.W 0x1764; each vertex: push word design x, BSR 0x1656 to -2, push design y, BSR
 * 0x1680, push x (SUBQ.W #1 / #2 where shown) then y (ADDQ.W #1 at 0x182c) to MoveTo $A893 / LineTo $A891;
 * vertex lists as in the C - identical to the C. */
/* Original: FUN_000016aa; source: ID02.c. Recovered name: draw_view_frame_outline [STRONG INFERENCE mechanics].
 * Decoded from ID02.bin bytes at file 0x16aa.
 * No arguments; Ghidra truncated it (rebuilt as C below). Depth 1: MoveTo / LineTo ($A893 / $A891) around the design rectangle x -3200..3200, y 670..2400 (design_x_to_screen 0x1656 / design_y_to_screen 0x1680) - a rectangle outline; other depths (0x1764..0x1870): (-3200, 2400) -> (-3200, 1200) -> (-1060, 670) -> (1060, 670) -> (3200, 1200) -> (3200, 2400) -> back, with 1-2 pixel adjustments [PROVEN, bytes 0x16aa..0x1874]. The rectangle matches the out-the-window view area above the instrument panel [HYPOTHESIS]. Caller: ID02 0x1894.
 */
// WARNING: Control flow encountered bad instruction data

void draw_view_frame_outline /* Original: FUN_000016aa */ (void)

{
  int unaff_A5;
  short x;                                      /* -2(A6): x is always computed before y */

  if (*(short *)(unaff_A5 + -0x137a) == 1) {    /* 1-bit: plain rectangle */
    x = design_x_to_screen(-0xc80);
    MoveTo(x + -1,design_y_to_screen(0x960));
    x = design_x_to_screen(-0xc80);
    LineTo(x + -1,design_y_to_screen(0x29e));
    x = design_x_to_screen(0xc80);
    LineTo(x,design_y_to_screen(0x29e));
    x = design_x_to_screen(0xc80);
    LineTo(x,design_y_to_screen(0x960));
    x = design_x_to_screen(-0xc80);
    LineTo(x,design_y_to_screen(0x960));
  }
  else {                                        /* colour: notched outline */
    x = design_x_to_screen(-0xc80);
    MoveTo(x + -1,design_y_to_screen(0x960));
    x = design_x_to_screen(-0xc80);
    LineTo(x + -1,design_y_to_screen(0x4b0));
    x = design_x_to_screen(-0xc80);
    LineTo(x,design_y_to_screen(0x4b0));
    x = design_x_to_screen(-0x424);
    LineTo(x,design_y_to_screen(0x29e));
    x = design_x_to_screen(0x424);
    LineTo(x + -2,design_y_to_screen(0x29e));
    x = design_x_to_screen(0xc80);
    LineTo(x,design_y_to_screen(0x4b0) + 1);
    x = design_x_to_screen(0xc80);
    LineTo(x,design_y_to_screen(0x960));
    x = design_x_to_screen(-0xc80);
    LineTo(x,design_y_to_screen(0x960));
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00001876): ID02.bin 0x1876..0x195a checked against an independent capstone disassembly.
 * CLR.W -$12; PenSize(1, 1); NewRgn -8; OpenRgn; BSR 0x16aa; CloseRgn(-8); NewRgn -4; GetClip(-4); SetClip(-8);
 * HGetState via JT $2d2 (CODE 0 entry seg 9 -> ID09 0x3b0), byte EXTB.L BTST #7 / BNE skips the lock, else
 * -$12 = 1 and JT $272 HLock; ForeColor($21), BackColor($1e); baseAddr = *(A5-0x12b0), rowBytes = word +$a
 * of record (MULS.W #$160 A5-0x13ae) + *(A5-0x13b2); CopyBits(port+2, thePort+2, port+$10, port+$10, 0,
 * nil); TST.W -$12 -> JT $27a HUnlock; SetClip(-4); DisposeRgn(-8); DisposeRgn(-4) - identical to the C. */
/*
 * Original: FUN_00001876; source: ID02.c:964.
 * Recovered name: blit_image_clipped_to_region [STRONG INFERENCE].
 * Ghidra truncated at $A89B; body rebuilt as C. Bytes 0x1876..0x195a [PROVEN]:
 *   PenSize(1,1); r = NewRgn; OpenRgn; FUN_000016aa (draws the clip
 *   shape); CloseRgn(r); saved = NewRgn; GetClip(saved); SetClip(r);
 *   if (!(HGetState(h = long A5-0x12b0) & 0x80)) { HLock(h); locked = 1 }
 *     (JT $2d2 = ID09 0x3b0 $A069; JT $272 HLock);
 *   ForeColor(black) / BackColor(white);
 *   (**port->portPixMap).baseAddr = *h,.rowBytes = record[A5-0x13ae].+0xa
 *     (port = long A5-0x1496; records 0x160 bytes at *(long A5-0x13b2));
 *   CopyBits(&port->portBits, &thePort->portBits, &port->portRect,
 *            &port->portRect, srcCopy, nil) $A8EC;
 *   if (locked) HUnlock(h); SetClip(saved); DisposeRgn(r); DisposeRgn(saved) (bytes dispose r first).
 * [HYPOTHESIS] Draws a stored picture (e.g. cockpit panel) through a shaped
 * clip; image/record meanings UNKNOWN. Caller: blit_image_clipped_to_region_a5safe.
 */
void blit_image_clipped_to_region /* Original: FUN_00001876 */ (void)

{
  int unaff_A5;
  short locked;                                 /* -$12(A6) */
  int clip;                                     /* -8(A6) */
  int saved;                                    /* -4(A6) */
  int port;

  locked = 0;
  PenSize(1,1);                                 /* $A89B */
  clip = NewRgn();                              /* $A8D8 */
  OpenRgn();                                    /* $A8DA */
  draw_view_frame_outline();                    /* BSR 0x16aa */
  CloseRgn(clip);                               /* $A8DB */
  saved = NewRgn();
  GetClip(saved);                               /* $A87A */
  SetClip(clip);                                /* $A879 */
  if ((HGetState(*(int *)(unaff_A5 + -0x12b0)) & 0x80) == 0) { /* JT $2d2 -> ID09 0x3b0 ($A069) */
    locked = 1;
    HLock(*(int *)(unaff_A5 + -0x12b0));        /* JT $272 -> ID09 0x270 */
  }
  ForeColor(0x21);                              /* $A862 */
  BackColor(0x1e);                              /* $A863 */
  port = *(int *)(unaff_A5 + -0x1496);
  *(int *)**(int **)(port + 2) = **(int **)(unaff_A5 + -0x12b0); /* baseAddr = *h */
  *(short *)(**(int **)(*(int *)(unaff_A5 + -0x1496) + 2) + 4) =
       *(short *)(**(int **)(unaff_A5 + -0x13b2) + *(short *)(unaff_A5 + -0x13ae) * 0x160 + 10); /* rowBytes */
  CopyBits((void *)(*(int *)(unaff_A5 + -0x1496) + 2),(void *)(*(int *)(unaff_A5 + -0x160c) + 2),
           (Rect *)(*(int *)(unaff_A5 + -0x1496) + 0x10),(Rect *)(*(int *)(unaff_A5 + -0x1496) + 0x10),0,0);
                                                /* $A8EC, srcCopy, no mask */
  if (locked != 0) {
    HUnlock(*(int *)(unaff_A5 + -0x12b0));      /* JT $27a -> ID09 0x27a */
  }
  SetClip(saved);
  DisposeRgn(clip);                             /* $A8D9 */
  DisposeRgn(saved);
  return;
}



/* VERIFIED (ID02::FUN_0000195c): ID02.bin 0x195c..0x197a checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, BSR 0x1876, restored - identical to the C. */
/*
 * Original: FUN_0000195c; source: ID02.c:973.
 * Recovered name: blit_image_clipped_to_region_a5safe [STRONG INFERENCE].
 * CurrentA5 thunk (bytes 0x195c..0x197a) calling blit_image_clipped_to_region.
 * Overlay service slot A5-0x111a (JT $3aa).
 */
void blit_image_clipped_to_region_a5safe /* Original: FUN_0000195c */ (void)

{
  blit_image_clipped_to_region(); /* Original: FUN_00001876 */  /* A5 = CurrentA5 ($904) around the call */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_0000197c): ID02.bin 0x197c..0x19a0 checked against an independent capstone disassembly.
 * A5 thunk; JSR $17a(A5) (CODE 0 entry seg 3 -> ID03 0x5cc4 prepare_instrument_panel); PEA $18a(A5),
 * UnloadSeg $A9F1 - identical to the C. */
/*
 * Original: FUN_0000197c; source: ID02.c:984.
 * Recovered name: run_segment3_entry_and_unload_a5safe [STRONG INFERENCE].
 * Bytes 0x197c..0x19a0 [PROVEN]: CurrentA5 thunk; JSR $17a(A5) (segment 3 file
 * 0x5cc4, prepare_instrument_panel); UnloadSeg(JT $18a = segment 3 entry) $A9F1.
 * Overlay service slot A5-0x111e (JT $372).
 */
void run_segment3_entry_and_unload_a5safe /* Original: FUN_0000197c */ (void)

{
  prepare_instrument_panel();                   /* JSR $17a(A5) -> ID03 0x5cc4; A5 = CurrentA5 */
  UnloadSeg((void *)(CurrentA5 + 0x18a));    /* $A9F1; PEA $18a(A5) = a segment 3 JT entry */
  return;
}



/* VERIFIED (ID02::FUN_000019a2): ID02.bin 0x19a2..0x19e0 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, CLR.L result / push 8(A6) / JT $252 (CODE 0 entry seg 9 -> ID09 0x242), result to -4;
 * CLR.W / JT $29a (ID09 0x29e MemError), TST.W / BEQ else BSR 0x19e2; D2 / A5 restored; D0 = -4 - identical to
 * the C. */
/*
 * Original: FUN_000019a2; source: ID02.c:994-1008.
 * Recovered name: new_handle_clear_or_die_a5safe [STRONG INFERENCE].
 * Bytes file 0x19a2..0x19e0 [PROVEN]: CurrentA5 thunk; h = NewHandleClear(size
 * long [8(A6)]) via JT $252 (ID09 0x242, $A322); if (MemError (JT $29a,
 * word $0220) != 0) fatal_memory_error_exit; returns h (long in D0).
 * Ghidra errors (return type / value: it returned param_1, bytes return h; the MemError
 * result was modelled as always 0) corrected in the rebuilt body. Service slot A5-0x10c2.
 */
int new_handle_clear_or_die_a5safe /* Original: FUN_000019a2 */ (int size /* param_1 */)

{
  int h;                                        /* -4(A6) */

  h = NewHandleClear(size);                  /* JT $252 -> ID09 0x242 ($A322); A5 = CurrentA5 */
  if (MemError() != 0) {                        /* JT $29a -> ID09 0x29e (word $0220) */
    fatal_memory_error_exit(); /* Original: FUN_000019e2 */
  }
  return h;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_000019e2): ID02.bin 0x19e2..0x1a02 checked against an independent capstone disassembly.
 * No LINK; TST.L A5-0x1006 / BEQ, else JT $23a (ID09 0x218 DisposPtr); BSR 0x4318 shutdown_sound; CLR.W,
 * push long A5-0xdd2, BSR 0x1d48, ADDQ.L #6; ExitToShell $A9F4 - identical to the C. */
/*
 * Original: FUN_000019e2; source: ID02.c:1014-1031.
 * Recovered name: fatal_memory_error_exit [STRONG INFERENCE].
 * Bytes file 0x19e2..0x1a02 [PROVEN] (no LINK; uses the caller's A5, which
 * every caller has already set from CurrentA5):
 *   if (A5-0x1006 overlay image) DisposPtr(A5-0x1006) (JT $23a, ID09 0x218);
 *   shutdown_sound;  show_caution_alert_with_number(str129 slot 93 = long A5-0xdd2, 0);
 *   ExitToShell ($A9F4).
 * A5-0xdd2 = A5-0xf46 + 93*4, i.e. string 93 of STR# 129 loaded by ID07
 * load_str129_string_table [PROVEN arithmetic]; presumably the out-of-memory
 * message shown by FUN_00001d48 [HYPOTHESIS]. Ghidra's register0x0000003c
 * stack modelling (an artifact) replaced by the rebuilt body.
 * Callers: new_handle_clear_or_die_a5safe, realloc_and_clear_handle_a5safe.
 */
void fatal_memory_error_exit /* Original: FUN_000019e2 */ (void)

{
  int unaff_A5;                                 /* the caller's A5 (no LINK, no thunk) */

  if (*(int *)(unaff_A5 + -0x1006) != 0) {
    DisposPtr(*(Ptr *)(unaff_A5 + -0x1006));    /* JT $23a -> ID09 0x218 */
  }
  shutdown_sound(); /* Original: FUN_00004318 */
  show_caution_alert_with_number(*(int *)(unaff_A5 + -0xdd2),0); /* STR# 129 slot 93 */
  ExitToShell();                                /* $A9F4; the RTS after it is never reached */
}



/* VERIFIED (ID02::FUN_00001a04): ID02.bin 0x1a04..0x1a26 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, push 8(A6), JT $25a (ID09 0x24e DisposHandle glue), restored - identical to the C. */
/*
 * Original: FUN_00001a04; source: ID02.c:1038-1043.
 * Recovered name: dispose_handle_a5safe [STRONG INFERENCE].
 * CurrentA5 thunk: saves A5/D2, A5 = ($0904), JSR $25a(A5) = ID09 file 0x24e
 * ($A023 DisposHandle glue) with the handle argument, restores A5/D2. Ghidra shows the
 * call through DAT_00000904 + JT offset. Overlay service slot A5-0x10be.
 */
void dispose_handle_a5safe /* Original: FUN_00001a04 */ (undefined4 h /* param_1: Handle */)

{
  (**(code **)(CurrentA5 + 0x25a))(h);
  return;
}



/* VERIFIED (ID02::FUN_00001a28): ID02.bin 0x1a28..0x1a82 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, push h then size to JT $26a (ID09 0x264 ReallocHandle); MemError (JT $29a) TST.W
 * / BEQ else BSR 0x19e2; JT $272 HLock(h); push long size, CLR.W, long *h, BSR 0x2b0, LEA $a(A7); JT $27a
 * HUnlock(h) - identical to the C. */
/*
 * Original: FUN_00001a28; source: ID02.c:1047-1066.
 * Recovered name: realloc_and_clear_handle_a5safe [STRONG INFERENCE].
 * Bytes file 0x1a28..0x1a82 [PROVEN]; CurrentA5 thunk. Args: Handle h [8],
 * long size [$c].
 *   ReallocHandle(h, size) (JT $26a = ID09 0x264, $A027);
 *   if (MemError (JT $29a = ID09 0x29e: word $0220 MemErr) != 0)
 *       fatal_memory_error_exit (FUN_000019e2);
 *   HLock(h) (JT $272); FUN_000002b0(*h, 0, size) (BSR 0x2b0; Ghidra could not
 *   decompile it - memset-like [HYPOTHESIS]); HUnlock(h) (JT $27a).
 * Ghidra error (the MemError result modelled as always 0, making the FUN_000019e2
 * branch look dead) corrected in the rebuilt body.
 * Overlay service slot A5-0x10ba (JT $40a).
 */
void realloc_and_clear_handle_a5safe /* Original: FUN_00001a28 */ (undefined4 *h /* param_1: Handle */,int size /* param_2 */)

{
  ReallocHandle(h,size);               /* JT $26a -> ID09 0x264 ($A027); A5 = CurrentA5 */
  if (MemError() != 0) {                        /* JT $29a */
    fatal_memory_error_exit(); /* Original: FUN_000019e2 */
  }
  HLock(h);                               /* JT $272 */
  FUN_000002b0(*h,0,size);             /* BSR 0x2b0: memset-like (ptr, word value, long count) */
  HUnlock(h);                             /* JT $27a */
  return;
}



/* VERIFIED (ID02::FUN_00001a84): ID02.bin 0x1a84..0x1aa6 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, push 8(A6), JT $272 (ID09 0x270 HLock glue) - identical to the C. */
/*
 * Original: FUN_00001a84; source: ID02.c:1070-1075.
 * Recovered name: hlock_a5safe [STRONG INFERENCE].
 * CurrentA5 thunk: saves A5/D2, A5 = ($0904), JSR $272(A5) = ID09 file 0x270
 * ($A029 HLock glue) with the handle argument, restores A5/D2. Ghidra shows the
 * call through DAT_00000904 + JT offset. Overlay service slot A5-0x10b6.
 */
void hlock_a5safe /* Original: FUN_00001a84 */ (undefined4 h /* param_1: Handle */)

{
  (**(code **)(CurrentA5 + 0x272))(h);
  return;
}



/* VERIFIED (ID02::FUN_00001aa8): ID02.bin 0x1aa8..0x1aca checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, push 8(A6), JT $27a (ID09 0x27a HUnlock glue) - identical to the C. */
/*
 * Original: FUN_00001aa8; source: ID02.c:1079-1084.
 * Recovered name: hunlock_a5safe [STRONG INFERENCE].
 * CurrentA5 thunk: saves A5/D2, A5 = ($0904), JSR $27a(A5) = ID09 file 0x27a
 * ($A02A HUnlock glue) with the handle argument, restores A5/D2. Ghidra shows the
 * call through DAT_00000904 + JT offset. Overlay service slot A5-0x10b2.
 */
void hunlock_a5safe /* Original: FUN_00001aa8 */ (undefined4 h /* param_1: Handle */)

{
  (**(code **)(CurrentA5 + 0x27a))(h);
  return;
}



/* VERIFIED (ID02::FUN_00001acc): ID02.bin 0x1acc..0x1aee checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, push 8(A6), JT $282 (ID09 0x284 HPurge glue) - identical to the C. */
/*
 * Original: FUN_00001acc; source: ID02.c:1088-1093.
 * Recovered name: hpurge_a5safe [STRONG INFERENCE].
 * CurrentA5 thunk: saves A5/D2, A5 = ($0904), JSR $282(A5) = ID09 file 0x284
 * ($A049 HPurge glue) with the handle argument, restores A5/D2. Ghidra shows the
 * call through DAT_00000904 + JT offset. Overlay service slot A5-0x10ae.
 */
void hpurge_a5safe /* Original: FUN_00001acc */ (undefined4 h /* param_1: Handle */)

{
  (**(code **)(CurrentA5 + 0x282))(h);
  return;
}



/* VERIFIED (ID02::FUN_00001af0): ID02.bin 0x1af0..0x1b12 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, push 8(A6), JT $28a (ID09 0x28e HNoPurge glue) - identical to the C. */
/*
 * Original: FUN_00001af0; source: ID02.c:1097-1102.
 * Recovered name: hnopurge_a5safe [STRONG INFERENCE].
 * CurrentA5 thunk: saves A5/D2, A5 = ($0904), JSR $28a(A5) = ID09 file 0x28e
 * ($A04A HNoPurge glue) with the handle argument, restores A5/D2. Ghidra shows the
 * call through DAT_00000904 + JT offset. Overlay service slot A5-0x10aa.
 */
void hnopurge_a5safe /* Original: FUN_00001af0 */ (undefined4 h /* param_1: Handle */)

{
  (**(code **)(CurrentA5 + 0x28a))(h);
  return;
}



/* VERIFIED (ID02::FUN_00001b14): ID02.bin 0x1b14..0x1b3e checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904; CLR.L / JT $212 (CODE 0 entry seg 9 -> ID09 0x1b2 FreeMem), result popped to -4;
 * restored; D0 = -4 - identical to the C (Ghidra's return 0 corrected). */
/*
 * Original: FUN_00001b14; source: ID02.c:1106-1111.
 * Recovered name: freemem_a5safe [STRONG INFERENCE].
 * Bytes file 0x1b14..0x1b3e [PROVEN]: saves A5/D2, A5 = CurrentA5 ($0904),
 * result = JT $212 = ID09 file 0x1b2 FreeMem glue ($A01C), restores, returns
 * the FreeMem long in D0. Ghidra's "return 0" was a decompiler error (it lost
 * the D0 value); corrected in the rebuilt body. Exported to the
 * overlay as service-table slot A5-0x10a6 (JT $38a), see below.
 *
 * Unexported routine at file 0x1b42..0x1c88 (main's BSR 0x1b42):
 * proposed name install_overlay_service_table [STRONG INFERENCE].
 * Stores JT entry addresses (LEA d16(A5)) into an A5 table, then allocates
 * the large overlay work buffer:
 *   A5-0x1122..-0x10a6 (32 slots, step 4; -0x10e6/-0x10e2 not written) and
 *   A5-0x1310..-0x1304 (4 slots -> segment 6 routines);
 *   full slot list with targets in docs/OVERLAY_SERVICE_TABLE.md.
 *   if (FreeMem > 0x100000) A5-0x1040 = NewPtrClear(0x4e390 = 320400)
 *   else                      A5-0x1040 = NewPtrClear(0x35cf0 = 220400)
 *   (JT $232 = ID09 0x20c NewPtrClear glue). No NULL check.
 * The callback slots A5-0x1092 / -0x104e / -0x1096 / -0x109e / -0x10a2 used by
 * ID02 lie outside this table: they are presumably filled by the overlay
 * itself (overlay -> app direction) [STRONG INFERENCE].
 */
int freemem_a5safe /* Original: FUN_00001b14 */ (void)

{
  return FreeMem();                             /* JT $212 -> ID09 0x1b2 ($A01C); A5 = CurrentA5 */
}



/* VERIFIED (ID02::FUN_00001c8a): ID02.bin 0x1c8a..0x1d46 checked against an independent capstone disassembly.
 * neg word -2; TST.L / BGE, NEG.L; p = buf + 10; DIVSL.L #10,D1:D0 (extension 0x0801) remainder + '0',
 * DIVS.L #10 (0x0800) quotient, loop while n != 0; '-' on neg; len = buf - p + 10, length byte at --p;
 * copy len + 1 bytes forwards to buf (post-decrement test); D0 = buf - identical to the C. */
/*
 * Original: FUN_00001c8a; source: ID02.c:1115-1150.
 * Recovered name: format_int_decimal_pstring [STRONG INFERENCE].
 * Exported C [complete]: writes |n| in decimal backwards from buf+10, prefixes
 * '-' for negative n, stores the length byte, returns the Pascal string start.
 * INT_MIN negation overflow preserved as exported. Caller:
 * show_caution_alert_with_number.
 */
char * format_int_decimal_pstring /* Original: FUN_00001c8a */ (int v /* param_1: the value, then reused for the length byte and the copy count */,char *buf /* param_2: Pascal string out (digits built backwards from buf + 10) */)

{
  char *digit; /* pcVar1: next digit slot */
  bool negative; /* bVar2 */
  char *out; /* local_e, -$a(A6): copy destination */
  char *p; /* local_a, -$6(A6): first digit, then copy source */
  
  negative = v < 0;
  if (negative) {
    v = -v;
  }
  digit = buf + 10;
  do {
    p = digit;
    digit = p + -1;
    *digit = (char)(v % 10) + '0';
    v = v / 10;
  } while (v != 0);
  if (negative) {
    p[-2] = '-';
    digit = p + -2;
  }
  p = digit;
  v._3_1_ = (char)((int)buf - (int)p) + '\n';
  p[-1] = (char)v;
  out = buf;
  v = ((int)buf - (int)p) + 0xb;
  p = p + -1;
  while (v != 0) {
    *out = *p;
    v = v + -1;
    out = out + 1;
    p = p + 1;
  }
  return buf;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00001d48): ID02.bin 0x1d48..0x1dd2 checked against an independent capstone disassembly.
 * JT $302 (ID09 0x416) on 8(A6); TST.W $c / BNE; ParamText pushes 8(A6) first, then the remaining three
 * (Pascal order: -$d0e, -$d0c, -$d0a / s, -$d08, -$d06 / s, -$d04, -$d02); s = BSR 0x1c8a(MOVEA.W $c, -$a);
 * TST.L 8 chooses the last pair; BSR 0x442e(0x102); CautionAlert(0x102, nil) $A988; JT $2fa (ID09 0x432)
 * on 8(A6) - identical to the C. */
/*
 * Original: FUN_00001d48; source: ID02.c:1157-1174.
 * Recovered name: show_caution_alert_with_number [STRONG INFERENCE].
 * Bytes file 0x1d48..0x1dd2 [PROVEN]; JT $4ba (used by ID08 error paths).
 * Args: char *msg [8(A6)] (C string, may be 0), word num [$c(A6)].
 *   c2pstr(msg) (JT $302, ID09 0x416);
 *   if (num == 0) ParamText(msg, A5-0xd0e, A5-0xd0c, A5-0xd0a) $A98B
 *   else { s = format_int_decimal_pstring(num, buf);
 *          if (msg) ParamText(msg, s, A5-0xd08, A5-0xd06)
 *          else     ParamText(msg, s, A5-0xd04, A5-0xd02) }
 *     (corrected: Pascal pushes the first parameter first, so the last two are not reversed);
 *     (the A5 words appear to be empty Pascal strings [HYPOTHESIS]);
 *   FUN_0000442e(0x102) [likely centres ALRT 258, cf. ID05 0x06];
 *   CautionAlert(258, nil) $A988; p2cstr(msg) (JT $2fa).
 * Callers: fatal_memory_error_exit (STR# 129[93], 0); ID02.c:1542; ID08 via JT $4ba.
 */
void show_caution_alert_with_number /* Original: FUN_00001d48 */ (int msg /* param_1: C string, converted to Pascal and back in place */,short number /* param_2: 0 = no number */)

{
  int unaff_A5;
  char buf[10];                                 /* -$a(A6) */
  char *s;                                      /* -$e(A6) */

  c2pstr_in_place(msg);                     /* JT $302 -> ID09 0x416, also when msg == 0 */
  if (number == 0) {
    ParamText(msg,unaff_A5 + -0xd0e,unaff_A5 + -0xd0c,unaff_A5 + -0xd0a); /* $A98B */
  }
  else {
    s = format_int_decimal_pstring((int)number,buf); /* BSR 0x1c8a, sign-extended */
    if (msg != 0) {
      ParamText(msg,(int)s,unaff_A5 + -0xd08,unaff_A5 + -0xd06);
    }
    else {
      ParamText(msg,(int)s,unaff_A5 + -0xd04,unaff_A5 + -0xd02);
    }
  }
  position_alert_template(0x102);               /* BSR 0x442e */
  CautionAlert(0x102,0);                        /* $A988, result discarded */
  length_prefixed_bytes_to_c_string_in_place(msg); /* JT $2fa -> ID09 0x432 */
  return;
}



/* VERIFIED (ID02::FUN_00001dd4): ID02.bin 0x1dd4..0x1e30 checked against an independent capstone disassembly.
 * LINK -6, word -6 = 1 (dead); TST.W A5-0xd12 / BNE out; GetNewDialog($8b, nil, -1) $A97C to -4; BSR 0x435e;
 * ShowWindow; DrawDialog; Button loop until down; DisposDialog $A983; Button loop until up; A5-0xd12 = 1 -
 * identical to the C. */
/* Original: FUN_00001dd4; source: ID02.c. Recovered name: show_sound_error_dialog_once [PROVEN].
 * Decoded from ID02.bin bytes at file 0x1dd4.
 * Only when the flag A5-0xd12 is 0: GetNewDialog(0x8b = DLOG 139 "Sound Error", NULL, (WindowPtr)-1) ($A97C); FUN_0000435e(dialog); ShowWindow; DrawDialog ($A981); waits for the mouse button to go down (Button $A974) then DisposDialog and waits for it to be released; sets A5-0xd12 = 1 so it is shown only once. Ghidra could not decode the body (rebuilt as C below).
 */
// WARNING: Control flow encountered bad instruction data

void show_sound_error_dialog_once /* Original: FUN_00001dd4 */ (void)

{
  int unaff_A5;
  short unused_6;                               /* -6(A6): set to 1, never read */
  int dlg;                                      /* -4(A6) */

  unused_6 = 1;
  if (*(short *)(unaff_A5 + -0xd12) == 0) {
    dlg = GetNewDialog(0x8b,0,-1);              /* $A97C: DLOG 139 */
    position_window_on_screen(dlg);             /* BSR 0x435e */
    ShowWindow(dlg);                            /* $A915 */
    DrawDialog(dlg);                            /* $A981 */
    do {
    } while (Button() == 0);                    /* $A974 */
    DisposDialog(dlg);                          /* $A983 */
    do {
    } while (Button() != 0);
    *(short *)(unaff_A5 + -0xd12) = 1;
  }
  return;
}



/* VERIFIED (ID02::FUN_00001e32): ID02.bin 0x1e32..0x1e66 checked against an independent capstone disassembly.
 * GetNewDialog($80, nil, -1) to -4; BSR 0x435e; ShowWindow; DrawDialog; D0 = -4 - identical to the C. */
/* Original: FUN_00001e32; source: ID02.c. Recovered name: show_creating_panel_dialog [PROVEN].
 * Decoded from ID02.bin bytes at file 0x1e32.
 * GetNewDialog(0x80 = DLOG 128 "Creating Instrument Panel", NULL, (WindowPtr)-1); FUN_0000435e(dialog); ShowWindow; DrawDialog; returns the dialog (the caller disposes it once the panel is built). Ghidra could not decode the body (rebuilt as C below).
 */
// WARNING: Control flow encountered bad instruction data

int show_creating_panel_dialog /* Original: FUN_00001e32 */ (void)

{
  int dlg;                                      /* -4(A6) */

  dlg = GetNewDialog(0x80,0,-1);                /* $A97C: DLOG 128 */
  position_window_on_screen(dlg);               /* BSR 0x435e */
  ShowWindow(dlg);                              /* $A915 */
  DrawDialog(dlg);                              /* $A981 */
  return dlg;
}



/* VERIFIED (ID02::FUN_00001e68): ID02.bin 0x1e68..0x1eda checked against an independent capstone disassembly.
 * word i 0..19 (CMPI.W #$14 / BLT); slot long A5-0xd62 + EXT.L i * 4; TST.L / BEQ; RecoverHandle(slot - $14)
 * via JT $262 (CODE 0 entry seg 9 -> ID09 0x258) to -6; TST.L / BEQ, else JT $282 HPurge and JT $27a HUnlock;
 * CLR.L slot - identical to the C (Ghidra's stack-confused C replaced). */
/* Original: FUN_00001e68; source: ID02.c. Recovered name: release_sound_slots [PROVEN].
 * Decoded from ID02.bin bytes at file 0x1e68.
 * For the 20 sound slots at A5-0xd62 (one long each): when non-zero, h = RecoverHandle(slot - 0x14) (JT $262 = ID09 glue $A128); if h, HPurge(h) (JT $282, $A049) and HUnlock(h) (JT $27a, $A02A); slot = 0. A slot therefore holds a pointer 0x14 bytes into a locked snd handle (presumably past its header). Callers: end_overlay_session (0x4b4), FUN_00001f8e (0x1f9e).
 */
void release_sound_slots /* Original: FUN_00001e68 */ (void)

{
  int unaff_A5;
  int h;                                        /* -6(A6) */
  short i;                                      /* -2(A6) */

  for (i = 0; i < 0x14; i = i + 1) {
    if (*(int *)(unaff_A5 + -0xd62 + (int)i * 4) != 0) {
      h = RecoverHandle(*(int *)(unaff_A5 + -0xd62 + (int)i * 4) + -0x14); /* JT $262 -> ID09 0x258 */
      if (h != 0) {
        HPurge(h);                              /* JT $282 */
        HUnlock(h);                             /* JT $27a */
      }
      *(int *)(unaff_A5 + -0xd62 + (int)i * 4) = 0;
    }
  }
  return;
}



/* VERIFIED (ID02::FUN_00001edc): ID02.bin 0x1edc..0x1f8c checked against an independent capstone disassembly.
 * GetNamedResource('snd ', 8(A6)) $A9A1 to -4, NIL -> MOVEQ #1; JT $28a, JT $27a; FreeMem CMPI.L #$3000 / BGE,
 * MaxMem(-$a) CMPI.L #$3000 / BGE, else JT $27a, JT $282, ReleaseResource $A9A3, MOVEQ #1; GetResAttrs $A9A6 to
 * -6, BTST #5,-5 / BNE, else SetResAttrs(h, attrs | $20) $A9A7 + ChangedResource $A9AA; slot (EXT.L $c) * 4 at
 * A5-0xd62 = h; MOVEQ #0 - identical to the C. */
/* Original: FUN_00001edc; source: ID02.c. Recovered name: load_named_sound_into_slot [PROVEN].
 * Decoded from ID02.bin bytes at file 0x1edc.
 * C args: +8 Pascal name, +0xc short slot. h = GetNamedResource('snd ', name) ($A9A1); none -> return 1. HNoPurge (JT $28a, $A04A); HUnlock (JT $27a); if FreeMem < 0x3000 and MaxMem(&grow) < 0x3000: HUnlock, HPurge, ReleaseResource ($A9A3), return 1 (out of memory). Makes sure the resource is marked purgeable (GetResAttrs $A9A6; if bit 0x20 is clear, SetResAttrs | 0x20 $A9A7 and ChangedResource); A5-0xd62[slot] = h; returns 0. Callers: FUN_00001f8e (0x1fc8.., thirteen call sites). Ghidra could not decode the body (rebuilt as C below).
 */
// WARNING: Control flow encountered bad instruction data

short load_named_sound_into_slot /* Original: FUN_00001edc */ (void *name /* param_1: Pascal resource name */,short slot /* param_2: index into the handle table A5-0xd62 */)

{
  int unaff_A5;
  int h;                                        /* -4(A6) */
  short attrs;                                  /* -6(A6) */
  int grow;                                     /* -$a(A6) */

  h = GetNamedResource(0x736e6420,name);     /* $A9A1, 'snd ' */
  if (h == 0) {
    return 1;
  }
  HNoPurge(h);                                  /* JT $28a */
  HUnlock(h);                                   /* JT $27a */
  if ((FreeMem() < 0x3000) && (MaxMem(&grow) < 0x3000)) { /* JT $212 / $21a; signed BGE */
    HUnlock(h);
    HPurge(h);                                  /* JT $282 */
    ReleaseResource(h);                         /* $A9A3 */
    return 1;
  }
  attrs = GetResAttrs(h);                       /* $A9A6 */
  if ((attrs & 0x20) == 0) {                    /* BTST #5 of the low byte */
    SetResAttrs(h,attrs | 0x20);                /* $A9A7, resPurgeable */
    ChangedResource(h);                         /* $A9AA */
  }
  *(int *)(unaff_A5 + -0xd62 + (int)slot * 4) = h;
  return 0;
}



/* VERIFIED (ID02::FUN_00001f8e): ID02.bin 0x1f8e..0x20bc checked against an independent capstone disassembly.
 * CLR.L -6; A5-0x112a = LEA A5-0xd62; BSR 0x1e68; CLR.W -2; MaxMem(-6) popped; FreeMem CMPI.L #$2e400 / BLE:
 * BSR 0x1edc(A5-0xd00 / A5-0xcf8, word 0); then nine (name, slot) calls with OR.W D0 into -2; slot 8 with
 * A5-0xcae: TST.W / BEQ, else BSET #0,-1 and retry with A5-0xca4 (OR.W); TST.W -2 -> BSR 0x1dd4 - identical
 * to the C (Ghidra had lost every argument and both FreeMem tests). */
/* Original: FUN_00001f8e; source: ID02.c. Recovered name: load_game_sounds [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x1f8e.
 * A5-0x112a = &sound slots (A5-0xd62, for the overlay); release_sound_slots; MaxMem(&grow); slot 0 = the sound named at A5-0xd00 when FreeMem > 0x2e400 (190 KB), else the one named at A5-0xcf8 (presumably a smaller variant); then load_named_sound_into_slot for the names at A5-0xcea, -0xce6, -0xce2, -0xcd0, -0xcca, -0xcc4, -0xcc0, -0xcba, -0xcb4, -0xcae into slots 5, 2, 9, 6, 7, 1, 12, 11, 10, 8; if the slot-8 load fails, retries slot 8 with the name at A5-0xca4 (and sets bit 0 of a local flag word). Any failure (OR of the results) -> show_sound_error_dialog_once [PROVEN, bytes 0x1f8e..0x20bc]. The Pascal names are A5 initial data, read from DATA 0 (A5-x at offset size - (x - 0xba0)) [PROVEN]: A5-0xd00 "Engine", -0xcf8 "Short Engine", -0xcea "Gun", -0xce6 "Hit", -0xce2 "Distant Explosion", -0xcd0 "Wheel", -0xcca "Gear", -0xcc4 "Ugh", -0xcc0 "Grass", -0xcba "Ditch", -0xcb4 "Wind", -0xcae "Explosion", -0xca4 "Distant Explosion" - so slots 0 Engine, 1 Ugh, 2 Hit, 5 Gun, 6 Wheel, 7 Gear, 8 Explosion, 9 Distant Explosion, 10 Wind, 11 Ditch, 12 Grass. Caller: begin_overlay_session (0x472).
 */
void load_game_sounds /* Original: FUN_00001f8e */ (void)

{
  int unaff_A5;
  int grow;                                     /* -6(A6) */
  ushort failed;                                /* -2(A6) */

  grow = 0;
  *(int *)(unaff_A5 + -0x112a) = unaff_A5 + -0xd62; /* slot table address for the overlay */
  release_sound_slots();                        /* BSR 0x1e68 */
  failed = 0;
  MaxMem(&grow);                                /* JT $21a; result discarded */
  if (FreeMem() > 0x2e400) {                    /* JT $212; CMPI.L / BLE: signed */
    failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xd00),0); /* "Engine" */
  }
  else {
    failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcf8),0); /* "Short Engine" */
  }
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcea),5);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xce6),2);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xce2),9);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcd0),6);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcca),7);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcc4),1);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcc0),12);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcba),11);
  failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xcb4),10);
  if (load_named_sound_into_slot((void *)(unaff_A5 + -0xcae),8) != 0) { /* "Explosion" */
    failed = failed | 1;                        /* BSET #0,-$1(A6): low byte of the word */
    failed = failed | load_named_sound_into_slot((void *)(unaff_A5 + -0xca4),8); /* fallback */
  }
  if (failed != 0) {
    show_sound_error_dialog_once();             /* BSR 0x1dd4 */
  }
  return;
}



/* VERIFIED (ID02::FUN_000020be): ID02.bin 0x20be..0x2128 checked against an independent capstone disassembly.
 * word i 0..19; TST.L slot / BEQ; JT $272 HLock(slot); -6 = slot; slot = LEA $14(*(-6)) - identical to the C
 * (Ghidra's stack-confused C replaced). */
/* Original: FUN_000020be; source: ID02.c. Recovered name: lock_sound_slots [PROVEN].
 * Decoded from ID02.bin bytes at file 0x20be.
 * For each of the 20 slots at A5-0xd62 that holds a handle: HLock (JT $272) and replace the slot by the data pointer *h + 0x14 - the inverse of release_sound_slots (RecoverHandle(slot - 0x14)). Caller: begin_overlay_session (0x49c).
 */
void lock_sound_slots /* Original: FUN_000020be */ (void)

{
  int unaff_A5;
  int h;                                        /* -6(A6) */
  short i;                                      /* -2(A6) */

  for (i = 0; i < 0x14; i = i + 1) {
    if (*(int *)(unaff_A5 + -0xd62 + (int)i * 4) != 0) {
      HLock(*(int *)(unaff_A5 + -0xd62 + (int)i * 4)); /* JT $272 */
      h = *(int *)(unaff_A5 + -0xd62 + (int)i * 4);
      *(int *)(unaff_A5 + -0xd62 + (int)i * 4) = **(int **)h + 0x14; /* data pointer past the header */
    }
  }
  return;
}



/* VERIFIED (ID02::FUN_0000212a): ID02.bin 0x212a..0x2190 checked against an independent capstone disassembly.
 * D0 = A5-0x1006 + A5-0x1022 + A5-0x101e; push long A5-0x101a, CLR.W, D0, BSR 0x2b0, LEA $a; GetPtrSize(A5-0x1040)
 * via JT $242 (CODE 0 entry seg 9 -> ID09 0x222), push result, CLR.W, A5-0x1040, BSR 0x2b0; -4 = A5-0x1006 +
 * A5-0x1012; push TickCount then PEA A5-0x1388, JSR (A0), ADDQ.L #8; BSR 0x4d24; BSR 0x2a44 - identical to
 * the C. */
/* Original: FUN_0000212a; source: ID02.c. Recovered name: reset_overlay_state [HYPOTHESIS name].
 * Decoded from ID02.bin bytes at file 0x212a.
 * Clears two memory areas with the 0x2b0 runtime routine (memset-like: address, 0, length): A5-0x1006 + A5-0x1022 + A5-0x101e (the overlay's bss, right after code + data) for A5-0x101a bytes (corrected: address and length were swapped here), and A5-0x1040 for GetPtrSize of it (JT $242, ID09 0x222, $A021); then calls the function at A5-0x1006 + A5-0x1012 (an overlay entry: base + offset) with (&A5-0x1388, TickCount); then JSR 0x4d24 and apply_settings_to_live_options (0x2a44) [PROVEN calls]. The TickCount argument suggests a random seed [HYPOTHESIS]. Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void reset_overlay_state /* Original: FUN_0000212a */ (void)

{
  int unaff_A5;
  code *entry;                                  /* -4(A6) */

  FUN_000002b0(*(int *)(unaff_A5 + -0x1006) + *(int *)(unaff_A5 + -0x1022) + *(int *)(unaff_A5 + -0x101e),0,
               *(int *)(unaff_A5 + -0x101a));   /* BSR 0x2b0: zero the bss after code + data */
  FUN_000002b0(*(int *)(unaff_A5 + -0x1040),0,GetPtrSize(*(int *)(unaff_A5 + -0x1040)));
                                                /* JT $242 -> ID09 0x222 ($A021) */
  entry = (code *)(*(int *)(unaff_A5 + -0x1006) + *(int *)(unaff_A5 + -0x1012));
  (*entry)(unaff_A5 + -0x1388,TickCount());     /* $A975 */
  FUN_00004d24();                               /* BSR 0x4d24 (no inventory entry) */
  apply_settings_to_live_options();             /* BSR 0x2a44 */
  return;
}



/* VERIFIED (ID02::FUN_00002192): ID02.bin 0x2192..0x2332 checked against an independent capstone disassembly.
 * GetMainDevice $AA2A to A5-0x1036, main pmBounds (+6, two MOVE.L) to -$16; CLR.L the three records;
 * GetDeviceList $AA29 / GetNextDevice $AA2B loop (TST.L / BNE.W); device bounds to -$1e; top, bottom, width
 * (SUB.W) and pixelSize (+$20) compared with BNE.W to the next device; record choice gd == main /
 * dev.right == main.left / dev.left == main.right else next; then CMP.L gd, A5-0x1036 / BNE.W skips the fill;
 * fill: NewPtr($200) via JT $232 if +4 == 0, +0 = gd, +$e = pmRowBytes & $1fff, +$10 = (JT $2da byte == 0
 * && BTST #0 of (*gd)+$14) ? 1 : 0, +8 = TST.W (*gd)+4 SNE / NEG.B / EXT.W, +$a = baseAddr; CLR.W A5-0x1032 -
 * identical to the C. */
/* Original: FUN_00002192; source: ID02.c. Recovered name: scan_display_devices [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x2192.
 * Ghidra could not decode the body (rebuilt as C below; corrections there: only the main
 * device's record is ever filled, because 0x2274 re-tests gd == main after choosing a record, so the
 * neighbour records stay 0; A5-0x1342 is the LEFT neighbour and A5-0x132c the right one; +8 is gdType != 0,
 * not pmRowBytes; +0x10 tests gdFlags bit 8 (byte +0x14 bit 0)); bytes 0x2192..0x2332 [PROVEN]. A5-0x1036 = GetMainDevice ($AA2A); main bounds = (*(*gd)->gdPMap)->bounds. Clears three 0x16-byte device records A5-0x1358 (main), A5-0x1342 (right neighbour), A5-0x132c (left neighbour). Walks GetDeviceList / GetNextDevice ($AA29 / $AA2B): a device qualifies when its bounds have the same top and bottom and the same width as the main screen and the same pixelSize (pixmap +0x20); the main device itself fills A5-0x1358, a device whose left edge is the main right edge fills A5-0x1342, one whose right edge is the main left edge fills A5-0x132c. Record: +0 GDHandle, +4 Ptr NewPtr(0x200) (allocated once, JT $232), +8 = (pmRowBytes word +4 != 0), +0xa baseAddr, +0xe rowBytes & 0x1fff, +0x10 = 1 when the ID09 0x3ba glue (low-memory byte $0CB2, meaning UNKNOWN) is 0 and gdFlags bit 0 is set, else 0. Finally clears A5-0x1032. So the game looks for identical monitors on either side of the main screen [STRONG INFERENCE: side views]. Callers: 0x27ea, 0x2846, 0x2a02, 0x2c54.
 */
// WARNING: Control flow encountered bad instruction data

void scan_display_devices /* Original: FUN_00002192 */ (void)

{
  int unaff_A5;
  short dev[4];                                 /* -$1e(A6): device bounds top, left, bottom, right */
  short mainb[4];                               /* -$16(A6): main screen bounds */
  int rec;                                      /* -$e(A6) */
  int **gd;                                     /* -$a(A6) */
  short v;

  *(int ***)(unaff_A5 + -0x1036) = (int **)GetMainDevice(); /* $AA2A */
  *(Rect *)mainb = *(Rect *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 6); /* pmBounds */
  *(int *)(unaff_A5 + -0x132c) = 0;
  *(int *)(unaff_A5 + -0x1342) = 0;
  *(int *)(unaff_A5 + -0x1358) = 0;
  for (gd = (int **)GetDeviceList(); gd != (int **)0x0; gd = (int **)GetNextDevice(gd)) { /* $AA29 / $AA2B */
    *(Rect *)dev = *(Rect *)(**(int **)((int)*gd + 0x16) + 6);
    if ((((dev[0] != mainb[0]) || (dev[2] != mainb[2])) || ((short)(dev[3] - dev[1]) != (short)(mainb[3] - mainb[1])))
       || (*(short *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 0x20) !=
           *(short *)(**(int **)((int)*gd + 0x16) + 0x20))) {     /* pixelSize */
      continue;
    }
    if (gd == *(int ***)(unaff_A5 + -0x1036)) {
      rec = unaff_A5 + -0x1358;                 /* main device */
    }
    else if (dev[3] == mainb[1]) {
      rec = unaff_A5 + -0x1342;                 /* left neighbour (its right edge = main left) */
    }
    else if (dev[1] == mainb[3]) {
      rec = unaff_A5 + -0x132c;                 /* right neighbour */
    }
    else {
      continue;
    }
    if (gd != *(int ***)(unaff_A5 + -0x1036)) {
      continue;                                 /* CMP.L A5-0x1036 / BNE.W: only the main record is filled */
    }
    if (*(int *)(rec + 4) == 0) {
      *(int *)(rec + 4) = (int)NewPtr(0x200);   /* JT $232 -> ID09 0x20c */
    }
    *(int ***)rec = gd;
    *(short *)(rec + 0xe) = *(short *)(**(int **)((int)*gd + 0x16) + 4) & 0x1fff; /* rowBytes */
    if (((**(code **)(unaff_A5 + 0x2da))() == '\0') && ((*(byte *)((int)*gd + 0x14) & 1) != 0)) {
                                                /* JT $2da -> ID09 0x3ba (byte $0CB2); gdFlags bit 8 */
      v = 1;
    }
    else {
      v = 0;
    }
    *(short *)(rec + 0x10) = v;
    *(short *)(rec + 8) = (short)(*(short *)((int)*gd + 4) != 0); /* gdType != 0: SNE / NEG.B / EXT.W */
    *(int *)(rec + 0xa) = *(int *)**(int **)((int)*gd + 0x16); /* baseAddr */
  }
  *(short *)(unaff_A5 + -0x1032) = 0;
  return;
}



/* VERIFIED (ID02::FUN_00002334): ID02.bin 0x2334..0x27e2 checked against an independent capstone disassembly.
 * multi = settings+$1c && A5-0x1032; size = multi ? 1 : settings+$e; JSR $3a(A5) table 0x2378 (1 -> 0x2386, 2 ->
 * 0x238e, 3 -> 0x239e, 4 -> 0x23b2, default 0x23c0 with w unset); hidden menu bar: records 1..3 at A5-0x136e +
 * MULS.W #$16, +$a += MULU.L($baa, rowBytes +$e), A5-0x137c -= $baa; compact case (size 1, w $200, $156 - $baa ==
 * h) reverses it when A5-0x1028 == 0, sets A5-0x1028 and lowers top; else align w with DIVS.W 8 / depth, ANDI.W
 * #$fffc, MULS.W, then the fitting loop (MULU.L #$1e0 / DIVS.L #$280, BGE; second estimate MULU.L #$8d4 / DIVS.L
 * #$12c0, BLE; w -= (8 / depth) << 2); odd h decremented; window rect centred, left aligned likewise; record +$12 =
 * +$a + (top delta) * rowBytes + left delta / (8 / depth); A5-0x1370 / -0x1372 stored; NewCWindow $AA45 (pushes:
 * nil, rect, title A5-0xc92, false, 2, -1, false, 0), NewPalette $AA91 13 / 217 + BSR 0x4738(4 / 8), BSR 0x462c,
 * SetPort; or HideWindow if visible byte +$6e, MoveWindow(left, top, false), SizeWindow(w, h, true), BSR 0x462c,
 * ShowWindow; SetOrigin(-A5-0x137e or 0, 0); BSR 0xd24 on A5-0x103a; depth != 1 -> JT $1b2; hook A5-0x10a2 when
 * A5-0x102e; depth 1: JT $1aa(base, rowBytes, $7f, w, h) TST.W -> BSR 0x19e2, A5-0x1300 = JT $1d2; else JT $1b2
 * again - identical to the C. */
/* Original: FUN_00002334; source: ID02.c. Recovered name: layout_game_window_and_view [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x2334.
 * Ghidra could not decode the body (rebuilt as C below: screen Rect by value; the width-fitting loop
 * narrows the view by 4 * (8 / depth) until h = w * 480 / 640 fits or a second estimate passes; on depths
 * other than 1 the ID06 JT $1b2 routine is called twice); outline from bytes 0x2334..0x27e2 [PROVEN calls and constants]. View-size option = settings word +0xe (handle A5-0x13ac), forced to 1 when settings +0x1c (multi-monitor) is on and A5-0x1032 is set; switch through JT $3a (table at 0x2378, 1..4): view width = screen width A5-0x137e, 1/2, 3/4 or 1/4 of it. When the menu bar is hidden (A5-0x1028) the device base addresses (A5-0x136e records, 0x16 bytes) are moved down by MBarHeight ($0BAA) rows and the height reduced; a special case for size 1 on a 512 x (342 - MBarHeight) screen (the compact Mac) hides / restores the menu bar the other way and sets A5-0x1028. Computes the view height and byte offsets with the depth A5-0x137a, stores the view size in A5-0x1372 (width) / A5-0x1370 (height). Creates the game window once: NewCWindow (procID 2, behind -1) ($AA45) -> A5-0x14ca, two palettes ($AA91 with 13 and 217 entries) -> A5-0x14ae / -0x14aa with FUN_00004738(4 / 8), FUN_0000462c; otherwise HideWindow, MoveWindow / SizeWindow ($A91B / $A91D), FUN_0000462c, ShowWindow. Sets the origin for a right-hand device (A5-0x1342); disposes the old buffer A5-0x103a (0xd24); ID06 JT $1b2 (file 0x858); overlay hook A5-0x10a2 when A5-0x102e; at depth 1 ID06 init_raster_target (JT $1aa) on the screen base A5-0x1346 / rowBytes A5-0x134a with height 127, JSR 0x19e2 and A5-0x1300 = ID06 JT $1d2 (file 0xee). Caller: configure_display_from_main_device (0x29e6).
 */
// WARNING: Control flow encountered bad instruction data

void layout_game_window_and_view /* Original: FUN_00002334 */ (short top,short left,short bottom,short right)
                                                /* screen Rect by value at 8(A6) */
{
  int unaff_A5;
  short visible;                                /* -$14(A6) */
  short multi;                                  /* -$12(A6) */
  short h;                                      /* -$10(A6): view height */
  short w;                                      /* -$e(A6): view width (unset for a size outside 1..4) */
  short i;                                      /* -$c(A6) */
  short size;                                   /* -$a(A6): also reused as a counter / the free height */
  short win[4];                                 /* -8(A6): window Rect top, left (-6), bottom (-4), right (-2) */
  short step;                                   /* 8 / depth (DIVS.W, quotient word) */
  int rec;

  multi = (*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x1c) != 0) && (*(short *)(unaff_A5 + -0x1032) != 0);
  if (multi == 0) {
    size = *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe);
  }
  else {
    size = 1;
  }
  switch (size) {                               /* JSR $3a(A5) -> ID01 0xbe, table 0x2378 lo 1 hi 4 */
  case 1:
    w = *(short *)(unaff_A5 + -0x137e);
    break;
  case 2:
    w = (short)((int)*(short *)(unaff_A5 + -0x137e) / 2);
    break;
  case 3:
    w = (short)((int)(short)(*(short *)(unaff_A5 + -0x137e) * 3) / 4); /* MULS.W, EXT.L, DIVS.W */
    break;
  case 4:
    w = (short)((int)*(short *)(unaff_A5 + -0x137e) / 4);
    break;
  }
  if (*(short *)(unaff_A5 + -0x1028) != 0) {    /* menu bar hidden: move the device bases down */
    for (i = 1; i < 4; i = i + 1) {
      rec = unaff_A5 + -0x136e + (int)i * 0x16;
      if (*(int *)rec != 0) {
        *(int *)(rec + 0xa) = *(int *)(rec + 0xa) + (int)*(short *)0xbaa * (int)*(short *)(rec + 0xe);
      }
    }
    *(short *)(unaff_A5 + -0x137c) = *(short *)(unaff_A5 + -0x137c) - *(short *)0xbaa;
  }
  h = *(short *)(unaff_A5 + -0x137c);
  if (((size == 1) && (w == 0x200)) && ((short)(0x156 - *(short *)0xbaa) == h)) { /* compact Mac */
    if (*(short *)(unaff_A5 + -0x1028) == 0) {
      for (size = 1; size < 4; size = size + 1) {
        rec = unaff_A5 + -0x136e + (int)size * 0x16;
        if (*(int *)rec != 0) {
          *(int *)(rec + 0xa) = *(int *)(rec + 0xa) - (int)*(short *)0xbaa * (int)*(short *)(rec + 0xe);
        }
      }
      *(short *)(unaff_A5 + -0x137c) = *(short *)(unaff_A5 + -0x137c) + *(short *)0xbaa;
      *(short *)(unaff_A5 + -0x1028) = 1;
      top = top - *(short *)0xbaa;
    }
    h = *(short *)(unaff_A5 + -0x137c);
  }
  else {
    step = (short)(8 / *(short *)(unaff_A5 + -0x137a));
    w = (((short)((int)w / step)) & 0xfffc) * step;
    while( true ) {                             /* 0x24ec */
      h = (short)((int)w * 0x1e0 / 0x280);      /* MULU.L #$1e0 (low 32 = signed product), DIVS.L #$280 */
      if (h <= (short)(bottom - top)) break;    /* CMP.W / BGE: fits */
      size = bottom - top;
      i = (short)((int)(short)((short)((int)w / 2) + w) / 2);
      i = (short)((int)(short)((int)size / 2) + (int)i * 0x8d4 / 0x12c0); /* DIVS.L ext 0x1801 */
      if (i <= size) {
        h = size;
        break;
      }
      w = w - (short)((short)(8 / *(short *)(unaff_A5 + -0x137a)) << 2);
    }
  }
  if ((h & 1) != 0) {                           /* BTST #0 of the low byte */
    h = h + -1;
  }
  win[0] = (short)((int)(short)(top + bottom) / 2) - (short)((int)h / 2);
  win[2] = win[0] + h;
  win[1] = (short)((int)(short)(left + right) / 2) - (short)((int)w / 2);
  step = (short)(8 / *(short *)(unaff_A5 + -0x137a));
  win[1] = (((short)((int)win[1] / step)) & 0xfffc) * step;
  win[3] = win[1] + w;
  for (size = 1; size < 4; size = size + 1) {
    rec = unaff_A5 + -0x136e + (int)size * 0x16;
    if (*(int *)rec != 0) {
      *(int *)(rec + 0x12) =
           *(int *)(rec + 0xa) + (int)(short)(win[0] - top) * (int)*(short *)(rec + 0xe) +
           (int)(short)((int)(short)(win[1] - left) / (short)(8 / *(short *)(unaff_A5 + -0x137a)));
    }
  }
  *(short *)(unaff_A5 + -0x1370) = h;
  *(short *)(unaff_A5 + -0x1372) = w;
  if (*(int *)(unaff_A5 + -0x14ca) == 0) {
    *(int *)(unaff_A5 + -0x14ca) =
         NewCWindow(0,win,unaff_A5 + -0xc92,0,2,-1,0,0); /* $AA45: invisible, procID 2, in front */
    *(int *)(unaff_A5 + -0x14ae) = NewPalette(0xd,0,0,0); /* $AA91 */
    configure_palette_entries(4);               /* BSR 0x4738 */
    *(int *)(unaff_A5 + -0x14aa) = NewPalette(0xd9,0,0,0);
    configure_palette_entries(8);
    select_palette_for_depth();                 /* BSR 0x462c */
    SetPort(*(int *)(unaff_A5 + -0x14ca));      /* $A873 */
  }
  else {
    visible = (short)*(char *)(*(int *)(unaff_A5 + -0x14ca) + 0x6e); /* EXTB.L */
    if (visible != 0) {
      HideWindow(*(int *)(unaff_A5 + -0x14ca)); /* $A916 */
    }
    MoveWindow(*(int *)(unaff_A5 + -0x14ca),win[1],win[0],0); /* $A91B */
    SizeWindow(*(int *)(unaff_A5 + -0x14ca),win[3] - win[1],h,1); /* $A91D */
    select_palette_for_depth();
    if (visible != 0) {
      ShowWindow(*(int *)(unaff_A5 + -0x14ca)); /* $A915 */
    }
  }
  if ((multi != 0) && (*(int *)(unaff_A5 + -0x1342) != 0)) {
    SetOrigin(-*(short *)(unaff_A5 + -0x137e),0); /* $A878 */
  }
  else {
    SetOrigin(0,0);
  }
  if (*(int *)(unaff_A5 + -0x103a) != 0) {
    close_and_dispose_port(*(int *)(unaff_A5 + -0x103a)); /* BSR 0xd24 */
    *(int *)(unaff_A5 + -0x103a) = 0;
  }
  if (*(short *)(unaff_A5 + -0x137a) != 1) {
    (**(code **)(unaff_A5 + 0x1b2))();          /* JT $1b2 -> ID06 0x858 (no inventory entry) */
  }
  if ((*(int *)(unaff_A5 + -0x10a2) != 0) && (*(short *)(unaff_A5 + -0x102e) != 0)) {
    (**(code **)(unaff_A5 + -0x10a2))();        /* overlay hook */
  }
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    if ((short)init_raster_target(*(int *)(unaff_A5 + -0x1346),
                                  CONCAT22(*(short *)(unaff_A5 + -0x134a),0x7f),CONCAT22(w,h)) == 0) {
                                                /* JT $1aa -> ID06 0x7b0; five words pushed */
      fatal_memory_error_exit();                /* BSR 0x19e2 */
    }
    *(int *)(unaff_A5 + -0x1300) = (**(code **)(unaff_A5 + 0x1d2))(); /* JT $1d2 -> ID06 0xee */
  }
  else {
    (**(code **)(unaff_A5 + 0x1b2))();          /* second call on deeper screens */
  }
  return;
}



/* VERIFIED (ID02::FUN_000027e4): ID02.bin 0x27e4..0x29f0 checked against an independent capstone disassembly.
 * BSR 0x2192; pixelSize to -4, CMPI.W #1 / #4 / #8 BEQ.W 0x2880; else visible window -> A5-0xd10 = 1 + HideWindow;
 * CLR.W + push A5-0xd76, BSR 0x1d48; BSR 0x2192; A5-0x137a = -4; reread, unsupported -> CLR.W A5-0x102e, BRA
 * 0x28a2; 0x2880: ShowWindow when A5-0xd10 && window && A5-0x12f8, CLR.W A5-0xd10, A5-0x102e = 1; 0x28a2 fills
 * A5-0x13ae / -0x1386 / -0x137a / -0x137c / -0x137e / -0x1378 / -0x12d4; JT $2da byte to A5-0x1000, A5-0x1312 =
 * (byte == 0 && BTST #0 gd+$14); A5-0x1000 = 1; records 1..3 +$a += MULU.L($baa, rowBytes); A5-0x137c -= $baa;
 * rect -$c = {$baa, 0, $baa + h, w}; CLR.W A5-0x1028; push the Rect (two MOVE.L -(A0)), BSR 0x2334 - identical to
 * the C. */
/* Original: FUN_000027e4; source: ID02.c. Recovered name: configure_display_from_main_device [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x27e4.
 * Ghidra could not decode the body (rebuilt as C below: the unsupported-depth path is a single retry, the
 * alert number is 0, the rescan stores the old depth in A5-0x137a, the menu-bar shift is added to the device
 * base addresses and the final screen Rect {mbar, 0, mbar + height, width} goes by value to the layout); bytes
 * 0x27e4..0x29f0 [PROVEN]. scan_display_devices; depth = pixelSize of the main device pixmap. If it is not 1, 4 or 8: hides the game window A5-0x14ca when visible (HideWindow $A916, A5-0xd10 = 1), shows STR# 129 slot 116 "Hellcats requires black and white,16 or 256 colors." with show_caution_alert_with_number (0x1d48), rescans. Then A5-0x137a = depth; A5-0x102e = window state (ShowWindow when it was hidden and a mission A5-0x12f8 is set); A5-0x13ae = -1 (no panel configuration yet); A5-0x1386 = the main PixMap handle; A5-0x137a / -0x137c / -0x137e = depth / screen height / width; A5-0x1378 = rowBytes & 0x1fff; A5-0x12d4 = settings +0x1c; A5-0x1000 / A5-0x1312 from the low-memory byte $0CB2 glue and gdFlags bit 0; subtracts the menu-bar height ($0BAA) from the view rects (A5-0x136e records) and the height; A5-0x1028 = 0; then FUN_00002334 (layout). Callers: refresh_display_if_changed, 0x2d92, 0x35dc.
 */
// WARNING: Control flow encountered bad instruction data

void configure_display_from_main_device /* Original: FUN_000027e4 */ (void)

{
  int unaff_A5;
  short mbar;                                   /* -$10(A6) */
  short r[4];                                   /* -$c(A6): screen Rect top, left, bottom, right */
  short depth;                                  /* -4(A6) */
  short i;                                      /* -2(A6) */
  int rec;

  scan_display_devices();                       /* BSR 0x2192 */
  depth = *(short *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 0x20);              /* pixelSize */
  if (((depth != 1) && (depth != 4)) && (depth != 8)) { /* one retry, not a loop */
    if ((*(int *)(unaff_A5 + -0x14ca) != 0) && (*(char *)(*(int *)(unaff_A5 + -0x14ca) + 0x6e) != '\0')) {
      *(short *)(unaff_A5 + -0xd10) = 1;
      HideWindow(*(int *)(unaff_A5 + -0x14ca)); /* $A916 */
    }
    show_caution_alert_with_number(*(int *)(unaff_A5 + -0xd76),0); /* STR# 129 slot 116 */
    scan_display_devices();
    *(short *)(unaff_A5 + -0x137a) = depth;     /* the old depth */
    depth = *(short *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 0x20);
    if (((depth != 1) && (depth != 4)) && (depth != 8)) {
      *(short *)(unaff_A5 + -0x102e) = 0;
      goto LAB_000028a2;
    }
  }
  if (((*(short *)(unaff_A5 + -0xd10) != 0) && (*(int *)(unaff_A5 + -0x14ca) != 0)) &&
     (*(short *)(unaff_A5 + -0x12f8) != 0)) {
    ShowWindow(*(int *)(unaff_A5 + -0x14ca));   /* $A915 */
  }
  *(short *)(unaff_A5 + -0xd10) = 0;
  *(short *)(unaff_A5 + -0x102e) = 1;
LAB_000028a2:
  if (*(short *)(unaff_A5 + -0x102e) != 0) {
    *(short *)(unaff_A5 + -0x13ae) = -1;
    *(int *)(unaff_A5 + -0x1386) = *(int *)**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16);               /* baseAddr */
    *(short *)(unaff_A5 + -0x137a) = *(short *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 0x20);
    *(Rect *)r = *(Rect *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 6);                          /* pmBounds */
    *(short *)(unaff_A5 + -0x137c) = r[2] - r[0];
    *(short *)(unaff_A5 + -0x137e) = r[3] - r[1];
    *(short *)(unaff_A5 + -0x1378) = *(short *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 4) & 0x1fff;
    *(short *)(unaff_A5 + -0x12d4) = *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x1c);
  }
  *(char *)(unaff_A5 + -0x1000) = (**(code **)(unaff_A5 + 0x2da))(); /* JT $2da -> ID09 0x3ba (byte $0CB2) */
  if ((*(char *)(unaff_A5 + -0x1000) == '\0') &&
     ((*(byte *)((int)**(int ***)(unaff_A5 + -0x1036) + 0x14) & 1) != 0)) { /* gdFlags bit 8 */
    *(short *)(unaff_A5 + -0x1312) = 1;
  }
  else {
    *(short *)(unaff_A5 + -0x1312) = 0;
  }
  *(char *)(unaff_A5 + -0x1000) = 1;
  mbar = *(short *)0xbaa;
  for (i = 1; i < 4; i = i + 1) {                 /* move the device bases below the menu bar */
    rec = unaff_A5 + -0x136e + (int)i * 0x16;
    if (*(int *)rec != 0) {
      *(int *)(rec + 0xa) = *(int *)(rec + 0xa) + (int)mbar * (int)*(short *)(rec + 0xe);
    }
  }
  *(short *)(unaff_A5 + -0x137c) = *(short *)(unaff_A5 + -0x137c) - mbar;
  r[0] = mbar;
  r[1] = 0;
  r[2] = r[0] + *(short *)(unaff_A5 + -0x137c);
  r[3] = r[1] + *(short *)(unaff_A5 + -0x137e);
  *(short *)(unaff_A5 + -0x1028) = 0;
  layout_game_window_and_view(r[0],r[1],r[2],r[3]); /* BSR 0x2334, Rect by value */
  return;
}



/* VERIFIED (ID02::FUN_000029f2): ID02.bin 0x29f2..0x2a42 checked against an independent capstone disassembly.
 * GetMainDevice $AA2A CMPA.L A5-0x1036 / BEQ else BSR 0x2192; CMP.W A5-0x137a with pixelSize / BEQ out;
 * BSR 0x27e4, 0x2a44, 0x4d24; TST A5-0x102e, A5-0x1006, A5-0x14c6 -> JSR (A5-0x1096) - identical to the C. */
/* Original: FUN_000029f2; source: ID02.c. Recovered name: refresh_display_if_changed [PROVEN].
 * Decoded from ID02.bin bytes at file 0x29f2. Body rebuilt as C below.
 * If GetMainDevice ($AA2A) differs from A5-0x1036, rescans (scan_display_devices); if the main pixmap depth differs from A5-0x137a: configure_display_from_main_device, apply_settings_to_live_options (0x2a44), JSR 0x4d24, and when A5-0x102e, the overlay base A5-0x1006 and the window flag A5-0x14c6 are all set, calls the overlay hook A5-0x1096 [PROVEN, bytes 0x29f2..0x2a42]. Callers: 0x2dd2, 0x2ffa, 0x305c (event handling).
 */
// WARNING: Control flow encountered bad instruction data

void refresh_display_if_changed /* Original: FUN_000029f2 */ (void)

{
  int unaff_A5;

  if ((int **)GetMainDevice() != *(int ***)(unaff_A5 + -0x1036)) { /* $AA2A */
    scan_display_devices();
  }
  if (*(short *)(unaff_A5 + -0x137a) != *(short *)(**(int **)((int)**(int ***)(unaff_A5 + -0x1036) + 0x16) + 0x20)) {
    configure_display_from_main_device();       /* BSR 0x27e4 */
    apply_settings_to_live_options();           /* BSR 0x2a44 */
    FUN_00004d24();                             /* BSR 0x4d24 (no inventory entry) */
    if (((*(short *)(unaff_A5 + -0x102e) != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) &&
       (*(short *)(unaff_A5 + -0x14c6) != 0)) {
      (**(code **)(unaff_A5 + -0x1096))();      /* overlay hook */
    }
  }
  return;
}



/* VERIFIED (ID02::FUN_00002a44): ID02.bin 0x2a44..0x2bba checked against an independent capstone disassembly.
 * CLR.W -$a flag; S+2 / +4 copied, S+$c to A5-0x12ea and A5-0x103c; old -0x12e0 / -0x12d8 / -0x12e6 / -0x12dc
 * saved to -2 / -4 / -6 / -8, new values copied, any CMP.W BNE -> TST.L A5-0x1006 -> JSR (A5-0x1092), flag = 1;
 * A5-0x12da old / new (S+$16) -> JSR (A5-0x104e); CMPI.W #8 A5-0x137a: S+$12 with JSR (A5-0x1096) and S+$1a,
 * else CLR.W both; S+$22, $24, 6, $1c, $a copied in that order; flag -> BSR 0x4db0 - identical to the C. */
/*
 * Original: FUN_00002a44; source: ID02.c:1487-1546.
 * Recovered name: apply_settings_to_live_options [STRONG INFERENCE].
 * Exported C is complete (no truncation) and matches the bytes.
 * Input: none; reads S = *(HEL1 127 handle A5-0x13ac). Output: void.
 * Effect: copies settings words from S into a live options block in the A5
 * world; for some fields, a change triggers a callback through a function
 * pointer, gated by long A5-0x1006 != 0 [UNKNOWN: probably "overlay/game
 * context loaded"]; any triggered callback forces a redraw (FUN_00004db0).
 * Callers [PROVEN, bytes; BSR/JSR d16(PC) scan of ID02.bin]: file 0x6ce,
 * 0x6f6, 0x716, 0x218a, 0x2a20, 0x39a0 (do_menu_command epilogue). None appear
 * in the exported C (all inside truncated or mis-decoded bodies).
 *
 * Settings word -> live word (menu source from do_menu_command):
 *   S+0x02 -> A5-0x12ee   (menu 4 item 1 toggle)
 *   S+0x04 -> A5-0x12ec   (menu 4 item 2 toggle)
 *   S+0x06 -> A5-0x12e8   (menu 4 item 5 toggle)
 *   S+0x08 -> A5-0x12e6   (menu 4 item 6 toggle)        change -> (A5-0x1092)
 *   S+0x0a -> A5-0x12e4;  S+0x0c -> A5-0x12ea and A5-0x103c
 *   S+0x10 -> A5-0x12e0   (menu 5 items 1..5 radio)     change -> (A5-0x1092)
 *   S+0x12 -> A5-0x12de   (menu 5 item 7)  only if word A5-0x137a == 8,
 *                         change -> (A5-0x1096); else forced 0
 *   S+0x14 -> A5-0x12dc   (menu 5 item 9)               change -> (A5-0x1092)
 *   S+0x16 -> A5-0x12da   (menu 5 item 8)               change -> (A5-0x104e)
 *   S+0x18 -> A5-0x12d8   (menu 5 item 10)              change -> (A5-0x1092)
 *   S+0x1a -> A5-0x12d6   (menu 5 item 11) only if A5-0x137a == 8, else 0
 *   S+0x1c -> A5-0x12d4;  S+0x22 -> A5-0x12d2;  S+0x24 -> A5-0x12d0
 * [HYPOTHESIS] A5-0x137a == 8 may be a screen depth (8-bit colour) gate.
 *  [PROVEN, bytes]: gate A5-0x1006 is the relocated overlay image
 * base, written only by ID08 load_overlay_from_resource (file 0xd4 MOVE.L A0,
 * then 4-byte alignment at 0xf0/0xfe; cleared at 0x226). A d16(A5) byte scan of
 * ID01-ID09 finds only reads (MOVEA.L) of A5-0x1092/-0x104e/-0x1096 (ID02 file
 * 0x2a3a, 0x2aec, 0x2b1a, 0x2b50, 0x3694, 0x4d1a); no direct writer. They are
 * therefore filled indirectly (overlay code or block copy) [STRONG INFERENCE];
 * the callbacks run overlay-side code only when the overlay is loaded.
 * Note: S+0x0e (menu 4 items 8-10) is not copied here; FUN_000035bc handles it.
 * Order of reads/writes is preserved exactly as exported.
 */
void apply_settings_to_live_options /* Original: FUN_00002a44 */ (void)

{
  undefined2 opt_0c; /* uVar1: settings +0xc, copied to A5-0x12ea and A5-0x103c */
  short prev; /* sVar2: previous value of the option being compared */
  short prev_12d8; /* sVar3: previous A5-0x12d8 */
  short prev_12e6; /* sVar4: previous A5-0x12e6 */
  short prev_12dc; /* sVar5: previous A5-0x12dc */
  bool changed; /* bVar6: a redraw is needed */
  int unaff_A5;
  
  changed = false;
  *(undefined2 *)(unaff_A5 + -0x12ee) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 2);
  *(undefined2 *)(unaff_A5 + -0x12ec) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 4);
  opt_0c = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0xc);
  *(undefined2 *)(unaff_A5 + -0x12ea) = opt_0c;
  *(undefined2 *)(unaff_A5 + -0x103c) = opt_0c;
  prev = *(short *)(unaff_A5 + -0x12e0);
  prev_12d8 = *(short *)(unaff_A5 + -0x12d8);
  prev_12e6 = *(short *)(unaff_A5 + -0x12e6);
  prev_12dc = *(short *)(unaff_A5 + -0x12dc);
  *(undefined2 *)(unaff_A5 + -0x12e0) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x10);
  *(undefined2 *)(unaff_A5 + -0x12d8) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x18);
  *(undefined2 *)(unaff_A5 + -0x12e6) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 8);
  *(undefined2 *)(unaff_A5 + -0x12dc) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x14);
  if (((((*(short *)(unaff_A5 + -0x12e0) != prev) || (*(short *)(unaff_A5 + -0x12d8) != prev_12d8)) ||
       (*(short *)(unaff_A5 + -0x12e6) != prev_12e6)) || (*(short *)(unaff_A5 + -0x12dc) != prev_12dc)) &&
     (*(int *)(unaff_A5 + -0x1006) != 0)) {
    (**(code **)(unaff_A5 + -0x1092))();
    changed = true;
  }
  prev = *(short *)(unaff_A5 + -0x12da);
  *(undefined2 *)(unaff_A5 + -0x12da) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x16);
  if ((prev != *(short *)(unaff_A5 + -0x12da)) && (*(int *)(unaff_A5 + -0x1006) != 0)) {
    (**(code **)(unaff_A5 + -0x104e))();
    changed = true;
  }
  if (*(short *)(unaff_A5 + -0x137a) == 8) {
    prev = *(short *)(unaff_A5 + -0x12de);
    *(undefined2 *)(unaff_A5 + -0x12de) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x12);
    if ((*(short *)(unaff_A5 + -0x12de) != prev) && (*(int *)(unaff_A5 + -0x1006) != 0)) {
      (**(code **)(unaff_A5 + -0x1096))();
      changed = true;
    }
    *(undefined2 *)(unaff_A5 + -0x12d6) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x1a);
  }
  else {
    *(undefined2 *)(unaff_A5 + -0x12de) = 0;
    *(undefined2 *)(unaff_A5 + -0x12d6) = 0;
  }
  *(undefined2 *)(unaff_A5 + -0x12d2) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x22);
  *(undefined2 *)(unaff_A5 + -0x12d0) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x24);
  *(undefined2 *)(unaff_A5 + -0x12e8) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 6);
  *(undefined2 *)(unaff_A5 + -0x12d4) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x1c);
  *(undefined2 *)(unaff_A5 + -0x12e4) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 10);
  if (changed) {
    redraw_main_window(); /* Original: FUN_00004db0 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00002bbc): ID02.bin 0x2bbc..0x2d9e checked against an independent capstone disassembly.
 * JT $222; word loop 0..1 JT $292; CurResFile $A994 to A5-0x1002; InitGraf(A5-0x160c), InitFonts; JT $202(-1, 0);
 * InitWindows, InitMenus, TEInit, InitDialogs(nil), InitCursor; JT $1fa(-1); JT $592; UnloadSeg($58a(A5)); JT $f2
 * TST.W / BNE else ExitToShell; JT $1f2(1, -$1e) result popped; byte -$15 to A5-0x1388; A5-0x1387 = (word -$18 ==
 * 1 || == 2); hasColorQD: BSR 0x2192, NewPtrClear($6d8) via JT $232 to A5-0x14b2, GetCTSeed $AA28 long at +0,
 * MOVE.W #$8000 to +4, copy to A5-0x1316; GetResource('MENU', 2) NIL -> SysBeep(20), BSR 0x2e36, BSR 0x2eaa;
 * 'HEL1' $7f / $80: NIL -> NewHandleClear($12a / $500) via JT $252, AddResource(h, 'HEL1', id, A5-0xc90 / -0xc66),
 * (127 only: +$10 = 2, +$e = 1, +$24 = 2, +$26 = 1, BSR 0x2ee4(A5-0xc78 -> +$2a)), ChangedResource, WriteResource;
 * else LoadResource $A9A2; BSR 0x27e4; SetPort(A5-0x14ca) - identical to the C. */
/*
 * Original: FUN_00002bbc; source: ID02.c:1552-1564.
 * Recovered name: initialize_application [STRONG INFERENCE].
 * Ghidra decoded only the first two calls and stopped at the A-line word $A994
 * (file 0x2bdc); the body is rebuilt as C below from ID02.bin file 0x2bbc..0x2d9e
 * (seg4 0x3d42 is check_system_requirements; $AA28 is GetCTSeed).
 * JT targets resolved through ID00.bin (seg off + 4-byte CODE header = file).
 * Trap names are Inside Macintosh assignments [STRONG INFERENCE];
 * byte sequences and control flow are [PROVEN, bytes].
 *
 *   JSR $222(A5)      seg9 file 0x1cc: MaxApplZone glue ($A063, manual path if ROM85<0)
 *   2x JSR $292(A5)   seg9 file 0x298: MoreMasters ($A036)  [the loop below]
 *   $A994 CurResFile -> word A5-0x1002 (application resource file refnum)
 *   PEA -$160c(A5); $A86E InitGraf; $A8FE InitFonts
 *   JSR $202(A5)(-1, 0) seg9 0x192: FlushEvents ($A032)
 *   $A912 InitWindows; $A930 InitMenus; $A9CC TEInit; $A97B InitDialogs(nil);
 *   $A850 InitCursor; JSR $1fa(A5)(-1) seg9 0x18a: SetEventMask (word -> $144)
 *   JSR $592(A5)      ID07 init_string_pointer_groups; PEA $58a(A5); $A9F1
 *                     UnloadSeg -> segment 7 is init-only
 *   JSR $f2(A5)       seg4 file 0x3d42, D0.W == 0 -> $A9F4 ExitToShell [UNKNOWN check]
 *   JSR $1f2(A5)(1, &env) seg9 file 0x20 = SysEnvirons dispatcher (ID09
 *                     sysenvirons_glue_fallback); env at -$1e(A6)
 *   A5-0x1388 byte <- env.hasColorQD (-$15(A6) = env+9)
 *   A5-0x1387 byte <- (env.processor == 1 || == 2)  [68000/68010 flag, HYPOTHESIS]
 *   if hasColorQD: BSR file 0x2192; p = JSR $232(A5)(0x6d8) seg9 0x20c
 *                  NewPtrClear ($A31E) -> A5-0x14b2 and A5-0x1316;
 *                  *(long*)p = $AA28 result; *(word*)(p+4) = 0x8000
 *                  [HYPOTHESIS: colour table, ctSeed/ctFlags; $AA28 unconfirmed]
 *   GetResource('MENU', 2) == nil -> SysBeep(20); BSR 0x2e36; BSR 0x2eaa
 *   h = GetResource('HEL1', 0x7f) -> A5-0x13ac; if nil:
 *       NewHandleClear(0x12a) (JT $252, seg9 0x242, $A322); AddResource(h,
 *       'HEL1', 0x7f, name A5-0xc90); (*h)+0x10=2, +0x0e=1, +0x24=2, +0x26=1;
 *       BSR 0x2ee4 copies string A5-0xc78 -> (*h)+0x2a; ChangedResource; WriteResource
 *     else LoadResource(h)
 *   h = GetResource('HEL1', 0x80) -> A5-0x13a8; if nil: NewHandleClear(0x500),
 *       AddResource(h,'HEL1',0x80, name A5-0xc66), ChangedResource, WriteResource
 *     else LoadResource(h)   [0x500 = 20 x 0x40 records, read by ID04.c:711]
 *   BSR file 0x27e4; SetPort ($A873) (port A5-0x14ca); UNLK; RTS
 *
 * Callers: main (FUN_0000309a, ID02.c:1658), which first sets word A5-0x13ae = -1.
 * [UNKNOWN] Semantics of seg4 check, HEL1 record fields, local helpers
 * 0x2192 / 0x27e4 / 0x2e36 / 0x2eaa.
 */
void initialize_application /* Original: FUN_00002bbc */ (void)

{
  int unaff_A5;
  short env[8];                                 /* -$1e(A6): SysEnvRec (processor -$18, hasColorQD -$15) */
  short i;                                      /* -2(A6) */

  (**(code **)(unaff_A5 + 0x222))(); /* MaxApplZone glue (seg9 file 0x1cc) */
  for (i = 0; i < 2; i = i + 1) {
    (**(code **)(unaff_A5 + 0x292))(); /* MoreMasters glue (seg9 file 0x298) */
  }
  *(short *)(unaff_A5 + -0x1002) = CurResFile(); /* $A994 */
  InitGraf((void *)(unaff_A5 + -0x160c));       /* $A86E */
  InitFonts();                                  /* $A8FE */
  FlushEvents(-1,0);                            /* JT $202 -> ID09 0x192 */
  InitWindows();                                /* $A912 */
  InitMenus();                                  /* $A930 */
  TEInit();                                     /* $A9CC */
  InitDialogs(0);                               /* $A97B */
  InitCursor();                                 /* $A850 */
  SetEventMask(-1);                             /* JT $1fa -> ID09 0x18a */
  init_string_pointer_groups();                 /* JT $592 -> ID07 0x190 */
  UnloadSeg((void *)(unaff_A5 + 0x58a));        /* $A9F1: segment 7 is init-only */
  if (check_system_requirements() == 0) {       /* JT $f2 -> ID04 0x3d42 */
    ExitToShell();                              /* $A9F4 */
  }
  SysEnvirons(1,env);                           /* JT $1f2 -> ID09 0x20; OSErr discarded */
  *(char *)(unaff_A5 + -0x1388) = *(char *)((int)env + 9); /* hasColorQD */
  *(char *)(unaff_A5 + -0x1387) = (env[3] == 1) || (env[3] == 2); /* processor */
  if (*(char *)(unaff_A5 + -0x1388) != '\0') {
    scan_display_devices();                     /* BSR 0x2192 */
    *(int *)(unaff_A5 + -0x14b2) = (int)NewPtrClear(0x6d8); /* JT $232 -> ID09 0x20c */
    **(int **)(unaff_A5 + -0x14b2) = GetCTSeed(); /* $AA28 */
    *(short *)(*(int *)(unaff_A5 + -0x14b2) + 4) = -0x8000;
    *(int *)(unaff_A5 + -0x1316) = *(int *)(unaff_A5 + -0x14b2);
  }
  if (GetResource(0x4d454e55,2) == 0) {         /* $A9A0, 'MENU' 2 */
    SysBeep(0x14);                              /* $A9C8 */
    show_resource_file_error_box();             /* BSR 0x2e36 */
    FUN_00002eaa();                             /* BSR 0x2eaa: quit (no inventory entry) */
  }
  *(int *)(unaff_A5 + -0x13ac) = GetResource(0x48454c31,0x7f); /* 'HEL1' 127: settings */
  if (*(int *)(unaff_A5 + -0x13ac) == 0) {
    *(int *)(unaff_A5 + -0x13ac) = NewHandleClear(0x12a); /* JT $252 -> ID09 0x242 */
    AddResource(*(int *)(unaff_A5 + -0x13ac),0x48454c31,0x7f,(void *)(unaff_A5 + -0xc90)); /* $A9AB */
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = 2;
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) = 1;
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x24) = 2;
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x26) = 1;
    copy_pascal_string((char *)(unaff_A5 + -0xc78),(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x2a)); /* BSR 0x2ee4 */
    ChangedResource(*(int *)(unaff_A5 + -0x13ac)); /* $A9AA */
    WriteResource(*(int *)(unaff_A5 + -0x13ac)); /* $A9B0 */
  }
  else {
    LoadResource(*(int *)(unaff_A5 + -0x13ac)); /* $A9A2 */
  }
  *(int *)(unaff_A5 + -0x13a8) = GetResource(0x48454c31,0x80); /* 'HEL1' 128: pilot roster */
  if (*(int *)(unaff_A5 + -0x13a8) == 0) {
    *(int *)(unaff_A5 + -0x13a8) = NewHandleClear(0x500);
    AddResource(*(int *)(unaff_A5 + -0x13a8),0x48454c31,0x80,(void *)(unaff_A5 + -0xc66));
    ChangedResource(*(int *)(unaff_A5 + -0x13a8));
    WriteResource(*(int *)(unaff_A5 + -0x13a8));
  }
  else {
    LoadResource(*(int *)(unaff_A5 + -0x13a8));
  }
  configure_display_from_main_device();         /* BSR 0x27e4 */
  SetPort(*(int *)(unaff_A5 + -0x14ca));        /* $A873 */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00002db8): ID02.bin 0x2db8..0x2e34 checked against an independent capstone disassembly.
 * SystemTask $A9B4; GetNextEvent(-1, -$12) EXTB.L to -2; BSR 0x29f2; TST.W -2 / BEQ loop; JSR $3a(A5) on what:
 * table 0x2de4 (1, 3, 5 -> 0x2e32 return; 6 -> 0x2dfa; 8 -> 0x2e1c; 2, 4, 7, default -> loop); update: TST.W
 * A5-0x14c6, CMP.L message with A5-0x14ca, BeginUpdate $A922, BSR 0x4db0, EndUpdate $A923; activate: four MOVE.L
 * -(A0) from -2 (the 16-byte record), BSR 0x2fa0 - identical to the C. */
/*
 * Original: FUN_00002db8; source: ID02.c:1570.
 * Recovered name: wait_for_click_or_key [STRONG INFERENCE].
 * Ghidra truncated at $A9B4 (body rebuilt as C below). Bytes 0x2db8..0x2e34 [PROVEN]: loop {
 *   SystemTask $A9B4; got = GetNextEvent(-1 everyEvent, &evt) $A970 (EXTB.L);
 *   BSR 0x29f2 (FUN_000029f2); if (!got) continue;
 *   switch (evt.what) [ID01 switch helper, table 0x2de4 parsed by script]:
 *     1 mouseDown, 3 keyDown, 5 autoKey -> return;
 *     6 updateEvt -> if (A5-0x14c6 && evt.message == main_window) {
 *          BeginUpdate; redraw_main_window; EndUpdate }
 *     8 activateEvt -> handle_activate_event(evt by value);
 *     others -> continue }.
 * Modal "press any key / click" wait that keeps the main window updated.
 * Caller [PROVEN]: ID04 run_with_temporary_window via JT $4aa.
 */
void wait_for_click_or_key /* Original: FUN_00002db8 */ (void)

{
  int unaff_A5;
  short evt[8];                                 /* -$12(A6): EventRecord what, message (-$10) */
  short got;                                    /* -2(A6) */

  while( true ) {
    do {
      SystemTask();                             /* $A9B4 */
      got = (short)(char)GetNextEvent(-1,evt);  /* $A970, everyEvent; EXTB.L */
      refresh_display_if_changed();             /* BSR 0x29f2, every pass */
    } while (got == 0);
    switch (evt[0]) {                           /* JSR $3a(A5) -> ID01 0xbe, table 0x2de4 lo 1 hi 8 */
    case 1:                                     /* mouseDown */
    case 3:                                     /* keyDown */
    case 5:                                     /* autoKey */
      return;
    case 6:                                     /* updateEvt */
      if ((*(short *)(unaff_A5 + -0x14c6) != 0) && (*(int *)(evt + 1) == *(int *)(unaff_A5 + -0x14ca))) {
        BeginUpdate(*(int *)(unaff_A5 + -0x14ca)); /* $A922 */
        redraw_main_window();                   /* BSR 0x4db0 */
        EndUpdate(*(int *)(unaff_A5 + -0x14ca)); /* $A923 */
      }
      break;
    case 8:                                     /* activateEvt */
      handle_activate_event(*(EventRecord *)evt); /* BSR 0x2fa0, 16 bytes by value */
      break;
    }
  }
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00002e36): ID02.bin 0x2e36..0x2ea8 checked against an independent capstone disassembly.
 * SetRect(-8, $98, $3c, $164, $84) $A8A7; NewWindow pushes nil, -8, A5-0xc50, byte 1, word 1, -1, word 0, long
 * 0 ($A913) to -$c; SetPort; TextFont(0); MoveTo(4, $14); DrawString(long A5-0xd72); MoveTo(4, $28); DrawString(long
 * A5-0xd6e); Button loop - identical to the C. */
/*
 * Original: FUN_00002e36; source: ID02.c:1581.
 * Recovered name: show_resource_file_error_box [STRONG INFERENCE].
 * Ghidra truncated (body rebuilt as C below). Bytes 0x2e36..0x2ea8 [PROVEN]:
 *   SetRect(&r, 152, 60, 356, 132) $A8A7  (left, top, right, bottom);
 *   w = NewWindow(nil, &r, title A5-0xc50, visible, 1 dBoxProc, (WindowPtr)-1,
 *       no goAway, 0) $A913; SetPort(w); TextFont(0 system) $A887;
 *   MoveTo(4, 20); DrawString(STR# 129 slot 117 "Can't open resource file.");
 *   MoveTo(4, 40); DrawString(slot 118 "Click mouse to exit.");
 *   do { } while (!Button) $A974   [strings PROVEN from resource dump].
 * Called by initialize_application when GetResource('MENU', 2) fails, after
 * SysBeep(20); followed by the quit routine below.
 *
 * Unexported routine at file 0x2eaa..0x2ee2 (after this function's RTS):
 * proposed name quit_application [STRONG INFERENCE]:
 *   if (JT $13a (segment 4 file 0x516) != 2) return;       [confirm step]
 *   if (settings_dirty A5-0x138a)
 *     switch (JT $ba (segment 4 file 0x4f0)) {             [save prompt]
 *       1: save helper 0x2da0 (HEL1 127 ChangedResource/WriteResource);
 *       2: return (cancel);  default: (exit without saving) }
 *   if (A5-0x14c6) HideWindow(main_window); ExitToShell $A9F4.
 * Callers: initialize_application (fatal path), do_menu_command menu 2 item 13.
 */
void show_resource_file_error_box /* Original: FUN_00002e36 */ (void)

{
  int unaff_A5;
  short r[4];                                   /* -8(A6) */
  int w;                                        /* -$c(A6) */

  SetRect(r,0x98,0x3c,0x164,0x84);              /* $A8A7: left, top, right, bottom */
  w = NewWindow(0,r,unaff_A5 + -0xc50,1,1,-1,0,0); /* $A913: visible dBoxProc in front, no goAway */
  SetPort(w);                                   /* $A873 */
  TextFont(0);                                  /* $A887 */
  MoveTo(4,0x14);                               /* $A893 */
  DrawString(*(void **)(unaff_A5 + -0xd72));    /* $A884: STR# 129 slot 117 */
  MoveTo(4,0x28);
  DrawString(*(void **)(unaff_A5 + -0xd6e));    /* slot 118 */
  do {
  } while (Button() == 0);                      /* $A974; the window is never disposed */
  return;
}



/* VERIFIED (ID02::FUN_00002ee4): ID02.bin 0x2ee4..0x2f1c checked against an independent capstone disassembly.
 * MOVEM D7/A3-A4; length byte copied, EXTB.L to D7 (signed: 128..255 copy nothing more); loop SUBQ.W #1 /
 * TST.W / BGE copying MOVE.B (A4)+ to (A3)+ - identical to the C. */
/* Original: FUN_00002ee4; source: ID02.c. Recovered name: copy_pascal_string [PROVEN].
 * Decoded from ID02.bin bytes at file 0x2ee4.
 * Copies the length byte and then that many bytes from src (+8) to dst (+0xc). Complete Ghidra C. Caller: 0x2d26.
 */
void copy_pascal_string /* Original: FUN_00002ee4 */ (char *src /* param_1: Pascal string */,char *dst /* param_2 */)

{
  char len; /* cVar1: length byte */
  short left; /* sVar2: bytes still to copy */
  
  len = *src;
  *dst = len;
  left = (short)len;
  while( true ) {
    src = src + 1;
    dst = dst + 1;
    left = left + -1;
    if (left < 0) break;
    *dst = *src;
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00002f1e): ID02.bin 0x2f1e..0x2f9e checked against an independent capstone disassembly.
 * FindWindow(long evt+$a, -4) $A92C to -6; JSR $3a(A5) table 0x2f40 (1 -> 0x2f5e, 2 -> 0x2f52, 6 -> 0x2f76, 3..5
 * and default -> 0x2f9c); MenuSelect(evt+$a) $A93D result to BSR 0x36a2; SystemClick(evt, win) $A9B3; go-away: CMP.L
 * A5-0x14ca, TrackGoAway $A91E TST.B, HideWindow $A916 - identical to the C. */
/*
 * Original: FUN_00002f1e; source: ID02.c:1613-1618.
 * Recovered name: handle_mouse_down [STRONG INFERENCE].
 * Ghidra truncated at $A92C; body rebuilt as C. Bytes file 0x2f1e..0x2f9e [PROVEN].
 * Arg: EventRecord *evt [8(A6)]. Caller: poll_and_dispatch_event (mouseDown).
 *   part = FindWindow(evt->where (+0xa), &win) $A92C;
 *   switch (part) [ID01 switch helper, table 0x2f40, 1..6, default return]:
 *     1 inMenuBar   -> do_menu_command(MenuSelect(evt->where) $A93D)
 *     2 inSysWindow -> SystemClick(evt, win) $A9B3
 *     3 inContent, 4 inDrag, 5 inGrow -> no action (window is not draggable here)
 *     6 inGoAway    -> if (win == main_window A5-0x14ca &&
 *                         TrackGoAway(main_window, evt->where) $A91E)
 *                        HideWindow(main_window) $A916
 * Part codes / traps: Inside Macintosh [STRONG INFERENCE].
 */
void handle_mouse_down /* Original: FUN_00002f1e */ (short *evt /* param_1: EventRecord */)

{
  int unaff_A5;
  int win;                                      /* -4(A6) */
  short part;                                   /* -6(A6) */

  part = FindWindow(*(int *)(evt + 5),&win); /* $A92C, evt->where (+$a) */
  switch (part) {                               /* JSR $3a(A5) -> ID01 0xbe, table 0x2f40 lo 1 hi 6 */
  case 1:                                       /* inMenuBar */
    do_menu_command(MenuSelect(*(int *)(evt + 5))); /* $A93D; BSR 0x36a2 */
    break;
  case 2:                                       /* inSysWindow */
    SystemClick(evt,win);                   /* $A9B3 */
    break;
  case 6:                                       /* inGoAway */
    if ((win == *(int *)(unaff_A5 + -0x14ca)) &&
       (TrackGoAway(*(int *)(unaff_A5 + -0x14ca),*(int *)(evt + 5)) != 0)) { /* $A91E */
      HideWindow(*(int *)(unaff_A5 + -0x14ca)); /* $A916 */
    }
    break;
  }                                             /* 3, 4, 5 and default: nothing */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00002fa0): ID02.bin 0x2fa0..0x2fd2 checked against an independent capstone disassembly.
 * TST.W A5-0x14c6; MOVEQ #3 AND.W $16(A6) CMPI.W #3; CMP.L $a(A6) (message) with A5-0x14ca; TST.L A5-0x14ca;
 * PEA $10(window), InvalRect $A928 - identical to the C. */
/*
 * Original: FUN_00002fa0; source: ID02.c:1624-1634.
 * Recovered name: handle_activate_event [STRONG INFERENCE].
 * Ghidra truncated the inner body at $A928; completed as C (InvalRect of the portRect).
 * Arg: EventRecord passed by value at 8(A6)..$17(A6). Ghidra's split:
 * param_1 (8 bytes) = what, message, high word of when (param_1._2_4_ =
 * message); param_2 = low word of when + where.v; param_3 = modifiers ($16(A6)).
 * Bytes file 0x2fa0..0x2fd2 [PROVEN]:
 *   if (word A5-0x14c6 && (evt.modifiers & 3) == 3 && evt.message == main_window
 *       && main_window != 0)
 *     InvalRect(&main_window->portRect)  (PEA $10(A0); $A928)
 * Bits 0/1 of modifiers = activeFlag / changeFlag [STRONG INFERENCE, Inside
 * Macintosh]; i.e. on activation of the main window, force a full redraw.
 * Caller: poll_and_dispatch_event (activateEvt).
 */
void handle_activate_event /* Original: FUN_00002fa0 */ (undefined8 evt_what_message /* param_1: EventRecord by value, what + message (the WindowPtr at ._2_4_) + start of when */,undefined4 evt_rest /* param_2: rest of the record, unused */,ushort modifiers /* param_3: EventRecord modifiers (activeFlag in the low bits) */)

{
  int unaff_A5;
  
  if ((((*(short *)(unaff_A5 + -0x14c6) != 0) && ((modifiers & 3) == 3)) &&
      (evt_what_message._2_4_ == *(int *)(unaff_A5 + -0x14ca))) && (*(int *)(unaff_A5 + -0x14ca) != 0)) {
    InvalRect((Rect *)(*(int *)(unaff_A5 + -0x14ca) + 0x10)); /* $A928, portRect */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00002fd4): ID02.bin 0x2fd4..0x3098 checked against an independent capstone disassembly.
 * HiliteMenu(0), SystemTask, BSR 0x3174, JT $172; GetNextEvent(-1, -$12) EXTB.L to -2; BSR 0x29f2; TST.W -2
 * BEQ.W out; JSR $3a(A5) table 0x300e (1 -> 0x3024, 3 / 5 -> 0x3032, 6 -> 0x305c, 8 -> 0x3082, 2 / 4 / 7 /
 * default -> 0x3096); key: AND.W #$100 modifiers, MenuKey(EXTB.L (message & $ff)) $A93E to BSR 0x36a2; update:
 * BSR 0x29f2 again, BeginUpdate / BSR 0x4db0 / EndUpdate; activate: 16-byte record by value to BSR 0x2fa0 -
 * identical to the C. */
/*
 * Original: FUN_00002fd4; source: ID02.c:1641-1646.
 * Recovered name: poll_and_dispatch_event [STRONG INFERENCE].
 * Ghidra truncated at the first A-line word ($A938, file 0x2fda); the body is
 * rebuilt as C below from ID02.bin file 0x2fd4..0x3098 [PROVEN, bytes].
 * Caller: main (FUN_0000309a) in an infinite loop (BSR at file 0x30f0).
 * Locals: EventRecord evt at -$12(A6) (what -$12, message -$10, when -$c,
 * where -$8, modifiers -$4); word got_event at -$2(A6).
 *
 *   HiliteMenu(0) ($A938); SystemTask ($A9B4)
 *   BSR 0x3174 (FUN_00003174); JSR $172(A5) -> seg4 file 0x432 [UNKNOWN]
 *   got_event = GetNextEvent(-1 /everyEvent/, &evt) ($A970), then
 *       word 0x49C0 = EXTB.L D0 (68020+ only; Capstone 68000 mode rejects it)
 *   BSR 0x29f2 (FUN_000029f2); if (!got_event) return
 *   switch (evt.what) via JSR $3a(A5) (ID01 switch helper; table at 0x300e:
 *   lo=1, hi=8, default -> return):
 *     1 mouseDown  -> BSR 0x2f1e (handle_mouse_down)(&evt)
 *     3 keyDown, 5 autoKey -> if (evt.modifiers & 0x100 /cmdKey/):
 *          BSR 0x36a2 (do_menu_command)(MenuKey((char)(evt.message & 0xff)))  ($A93E)
 *     6 updateEvt  -> BSR 0x29f2; if (word A5-0x14c6 && evt.message == A5-0x14ca):
 *          BeginUpdate(A5-0x14ca) ($A922); BSR 0x4db0 (redraw_main_window);
 *          EndUpdate ($A923)
 *     8 activateEvt -> BSR 0x2fa0 (handle_activate_event)(evt by value, 16 bytes)
 *     2 mouseUp, 4 keyUp, 7 diskEvt -> ignored
 * Event codes/masks and trap names are Inside Macintosh [STRONG INFERENCE].
 * [STRONG INFERENCE] A5-0x14ca is the main window (also SetPort target in
 * initialize_application); A5-0x14c6 gates its redraw. Non-command keys are
 * not handled here (likely polled elsewhere during gameplay) [HYPOTHESIS].
 */
void poll_and_dispatch_event /* Original: FUN_00002fd4 */ (void)

{
  int unaff_A5;
  short evt[8];                                 /* -$12(A6): what, message -$10, when, where, modifiers -4 */
  short got;                                    /* -2(A6) */

  HiliteMenu(0);                                /* $A938 */
  SystemTask();                                 /* $A9B4 */
  update_menu_items();                          /* BSR 0x3174 */
  (**(code **)(unaff_A5 + 0x172))();            /* JT $172 -> ID04 0x432 (no inventory entry) */
  got = (short)(char)GetNextEvent(-1,evt);      /* $A970; EXTB.L */
  refresh_display_if_changed();                 /* BSR 0x29f2 */
  if (got == 0) {
    return;
  }
  switch (evt[0]) {                             /* JSR $3a(A5) -> ID01 0xbe, table 0x300e lo 1 hi 8 */
  case 1:                                       /* mouseDown */
    handle_mouse_down(evt);                     /* BSR 0x2f1e */
    break;
  case 3:                                       /* keyDown */
  case 5:                                       /* autoKey */
    if ((evt[7] & 0x100) != 0) {                /* cmdKey */
      do_menu_command(MenuKey((short)(char)(*(uint *)(evt + 1) & 0xff))); /* $A93E; BSR 0x36a2 */
    }
    break;
  case 6:                                       /* updateEvt */
    refresh_display_if_changed();
    if ((*(short *)(unaff_A5 + -0x14c6) != 0) && (*(int *)(evt + 1) == *(int *)(unaff_A5 + -0x14ca))) {
      BeginUpdate(*(int *)(unaff_A5 + -0x14ca)); /* $A922 */
      redraw_main_window();                     /* BSR 0x4db0 */
      EndUpdate(*(int *)(unaff_A5 + -0x14ca));  /* $A923 */
    }
    break;
  case 8:                                       /* activateEvt */
    handle_activate_event(*(EventRecord *)evt); /* BSR 0x2fa0, 16 bytes by value */
    break;
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_0000309a): ID02.bin 0x309a..0x30f8 checked against an independent capstone disassembly.
 * CLR.L -6; A5-0x13ae = -1; BSR 0x2bbc; UnloadSeg($a2(A5)); MaxMem(-6) via JT $21a, popped; BSR 0x1b42;
 * A5-0x14c4 = 1; JT $1e2 to -2; UnloadSeg($1ea(A5)), UnloadSeg($56a(A5)); BSR 0x30fa; TST.W -2 && A5-0x102e ->
 * BSR 0x35e4; BSR 0x2fd4 / BRA loop - identical to the C. */
/*
 * Original: FUN_0000309a; source: ID02.c:1650-1660.
 * Recovered name: main [STRONG INFERENCE].
 * Ghidra stopped at UnloadSeg ($A9F1, file 0x30b0); the body is rebuilt as C
 * below from ID02.bin file 0x309a..0x30f8 [PROVEN, bytes] (0x30fa is install_menus,
 * 0x35e4 start_new_mission).
 *
 * Entry evidence [PROVEN, bytes]: ID01.bin (JT entry 0 target) holds the long
 * 0x000004b2 at file 0x4; file 0x24 MOVE.L $4(PC),D1; 0x28 JSR (A5,D1.W)
 * -> JT A5+0x4b2 = seg 2 off 0x3096 = this function; then JSR via $6c(A5)
 * and $A9F4 ExitToShell. This is the runtime start calling the program main.
 *
 *   long local_a = 0 (-6(A6)); word A5-0x13ae = -1   [exported C below]
 *   initialize_application                         [exported C below]
 *   UnloadSeg(JT $a2  = seg 4 entry)
 *   JSR $21a(A5)(&local_a): seg9 file 0x1bc = MaxMem glue ($A11D): result
 *        discarded, grow size stored to local_a [heap compaction]
 *   BSR file 0x1b42  install_overlay_service_table (unexported; see
 *                    freemem_a5safe header) - fills A5 service table, allocates A5-0x1040
 *   word A5-0x14c4 = 1
 *   ok = JSR $1e2(A5) -> seg 8 file 0x6 = ID08 load_overlay_from_resource
 *   UnloadSeg(JT $1ea = seg 8 entry); UnloadSeg(JT $56a = seg 5 entry)
 *   BSR file 0x30fa (FUN_000030fa)                   [UNKNOWN]
 *   if (ok && word A5-0x102e != 0) BSR file 0x35e4   [UNKNOWN]
 *   for (;) BSR file 0x2fd4 (poll_and_dispatch_event, FUN_00002fd4) [never returns]
 *   (UNLK/RTS at 0x30f6 unreachable)
 * Name chosen for the role (C runtime entry -> main); original symbol unknown.
 */
void main /* Original: FUN_0000309a */ (void)

{
  int unaff_A5;
  int grow;                                     /* -6(A6) */
  short ok;                                     /* -2(A6) */

  grow = 0;
  *(undefined2 *)(unaff_A5 + -0x13ae) = 0xffff;
  initialize_application(); /* Original: FUN_00002bbc */
  UnloadSeg((void *)(unaff_A5 + 0xa2));         /* $A9F1: segment 4 */
  MaxMem(&grow);                                /* JT $21a -> ID09 0x1bc; result discarded */
  FUN_00001b42();                               /* BSR 0x1b42: install_overlay_service_table (no inventory entry) */
  *(short *)(unaff_A5 + -0x14c4) = 1;
  ok = load_overlay_from_resource();            /* JT $1e2 -> ID08 0x6 */
  UnloadSeg((void *)(unaff_A5 + 0x1ea));        /* segment 8 */
  UnloadSeg((void *)(unaff_A5 + 0x56a));        /* segment 5 */
  install_menus();                              /* BSR 0x30fa */
  if ((ok != 0) && (*(short *)(unaff_A5 + -0x102e) != 0)) {
    start_new_mission();                        /* BSR 0x35e4 */
  }
  do {
    poll_and_dispatch_event();                  /* BSR 0x2fd4 */
  } while( true );                              /* UNLK / RTS at 0x30f6 unreachable */
}



/* VERIFIED (ID02::FUN_000030fa): ID02.bin 0x30fa..0x3172 checked against an independent capstone disassembly.
 * For ids 1..5: GetMenu $A9BF result to A5-0xc4e / -0xc4a / -0xc46 / -0xc42 / -0xc3e, InsertMenu(menu, 0) $A935;
 * after menu 1's insert AddResMenu(menu 1, 'DRVR') $A94D; DrawMenuBar $A937 - identical to the C. */
/* Original: FUN_000030fa; source: ID02.c. Recovered name: install_menus [PROVEN].
 * Decoded from ID02.bin bytes at file 0x30fa.
 * For MENU ids 1..5: GetMenu(id) ($A9BF) -> A5-0xc4e, -0xc4a, -0xc46, -0xc42, -0xc3e, InsertMenu(menu, 0) ($A935); AddResMenu(menu 1, 'DRVR') ($A94D) fills the Apple menu with desk accessories; DrawMenuBar ($A937). Caller: 0x30dc (start-up). Ghidra could not decode the body (rebuilt as C below).
 */
// WARNING: Control flow encountered bad instruction data

void install_menus /* Original: FUN_000030fa */ (void)

{
  int unaff_A5;

  *(int *)(unaff_A5 + -0xc4e) = GetMenu(1);        /* $A9BF */
  InsertMenu(*(int *)(unaff_A5 + -0xc4e),0);       /* $A935 */
  AddResMenu(*(int *)(unaff_A5 + -0xc4e),0x44525652); /* $A94D, 'DRVR': desk accessories */
  *(int *)(unaff_A5 + -0xc4a) = GetMenu(2);        /* $A9BF */
  InsertMenu(*(int *)(unaff_A5 + -0xc4a),0);       /* $A935 */
  *(int *)(unaff_A5 + -0xc46) = GetMenu(3);        /* $A9BF */
  InsertMenu(*(int *)(unaff_A5 + -0xc46),0);       /* $A935 */
  *(int *)(unaff_A5 + -0xc42) = GetMenu(4);        /* $A9BF */
  InsertMenu(*(int *)(unaff_A5 + -0xc42),0);       /* $A935 */
  *(int *)(unaff_A5 + -0xc3e) = GetMenu(5);        /* $A9BF */
  InsertMenu(*(int *)(unaff_A5 + -0xc3e),0);       /* $A935 */
  DrawMenuBar();                                /* $A937 */
  return;
}



/* VERIFIED (ID02::FUN_00003174): ID02.bin 0x3174..0x358e checked against an independent capstone disassembly.
 * FrontWindow $A924 to A4; kind = A4 ? MOVEA.W +$6c : 0; byte -3 = SLT; -6 = A5-0x1032 && A5-0x12d4; menu 2 items 7,
 * 4, 8, 9, 5, 6 with the branch conditions of 0x31b8..0x32b4 (CMPI.W #2 / TST / CMPI.W #1 A5-0x14c4 / CMPI.W #3
 * BGE); menu 3: EXTB.L byte CMP.W A5-0xc3a, item 0 + store, items 1, 3, 4, 5, 6; menu 4 CheckItem (menu, item,
 * byte) for 1 / 2 / 4 / 5 / 6 from settings bytes 3 / 5, A5-0x102f, 7 / 9, enables 8 / 10 / 9 from SEQ of -6, checks
 * 8 / 10 / 9 from CMPI.W #1 / #2 / #3 settings+$e; menu 5 enables 7 (depth == 8) and $b (SNE depth 4), checks 1..5
 * from CMPI.W settings+$10, 7 / 9 / 8 / $b / $a from bytes $13 / $15 / $17 / $1b / $19 - identical to the C. */
/* Original: FUN_00003174; source: ID02.c. Recovered name: update_menu_items [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x3174.
 * FrontWindow ($A924); the front window is a desk accessory when its windowKind (+0x6c) is negative; then enables / disables menu items through set_menu_item_enabled (0x3590, called at 0x31e2.. 0x32d4) according to that flag and the state words A5-0x1032 / A5-0x12d4 and others. Caller: 0x2fde (before menu tracking). Ghidra truncated the body; rebuilt as C below with every item condition (CheckItem $A945 marks the
 * settings toggles and the view-size / option radio groups).
 */
// WARNING: Control flow encountered bad instruction data

void update_menu_items /* Original: FUN_00003174 */ (void)

{
  int unaff_A5;
  int front;                                    /* A4 */
  short multi;                                  /* -6(A6) */
  char isDA;                                    /* -3(A6) */
  short kind;                                   /* -2(A6) */

  front = FrontWindow();                        /* $A924 */
  if (front == 0) {
    kind = 0;
  }
  else {
    kind = *(short *)(front + 0x6c);            /* windowKind */
  }
  isDA = kind < 0;                              /* SLT / NEG.B / EXT.W, stored as a byte */
  multi = (*(short *)(unaff_A5 + -0x1032) != 0) && (*(short *)(unaff_A5 + -0x12d4) != 0);
  /* menu 2 (A5-0xc4a) */
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc4a),7,
                        (*(short *)(unaff_A5 + -0x102e) != 0) && (*(short *)(unaff_A5 + -0x12f8) != 0) &&
                        ((*(short *)(unaff_A5 + -0x12f0) != 0) || (*(short *)(unaff_A5 + -0x14c4) != 1)));
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc4a),4,
                        (*(int *)(unaff_A5 + -0x1006) != 0) && (*(short *)(unaff_A5 + -0x102e) != 0) &&
                        (((*(short *)(unaff_A5 + -0x12f8) == 2) || (*(short *)(unaff_A5 + -0x12f8) == 0)) || (*(short *)(unaff_A5 + -0x12b4) == 0)));
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc4a),8,
                        (*(short *)(unaff_A5 + -0x102e) != 0) && (*(short *)(unaff_A5 + -0x12f8) != 0) && (*(short *)(unaff_A5 + -0x12f0) == 0));
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc4a),9,
                        (*(short *)(unaff_A5 + -0x12f8) == 2) || ((*(short *)(unaff_A5 + -0x12f8) != 0) && (*(short *)(unaff_A5 + -0x14c4) != 1)));
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc4a),5,(*(short *)(unaff_A5 + -0x102e) != 0) && (2 < *(short *)(unaff_A5 + -0x12f8))); /* CMPI.W #3 / BGE */
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc4a),6,(*(short *)(unaff_A5 + -0x102e) != 0) && (2 < *(short *)(unaff_A5 + -0x12f8)));
  /* menu 3 (A5-0xc46): only for a desk accessory in front */
  if ((short)isDA != *(short *)(unaff_A5 + -0xc3a)) {
    set_menu_item_enabled(*(int *)(unaff_A5 + -0xc46),0,(short)isDA); /* whole menu */
    *(short *)(unaff_A5 + -0xc3a) = (short)isDA;
  }
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc46),1,(short)isDA);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc46),3,(short)isDA);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc46),4,(short)isDA);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc46),5,(short)isDA);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc46),6,(short)isDA);
  /* menu 4 (A5-0xc42) */
  CheckItem(*(int *)(unaff_A5 + -0xc42),1,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 3)); /* $A945: low bytes of the words */
  CheckItem(*(int *)(unaff_A5 + -0xc42),2,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 5));
  CheckItem(*(int *)(unaff_A5 + -0xc42),4,*(char *)(unaff_A5 + -0x102f));
  CheckItem(*(int *)(unaff_A5 + -0xc42),5,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 7));
  CheckItem(*(int *)(unaff_A5 + -0xc42),6,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 9));
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc42),8,multi == 0);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc42),10,multi == 0);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc42),9,multi == 0);
  CheckItem(*(int *)(unaff_A5 + -0xc42),8,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) == 1); /* view size */
  CheckItem(*(int *)(unaff_A5 + -0xc42),10,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) == 2); /* view size */
  CheckItem(*(int *)(unaff_A5 + -0xc42),9,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) == 3); /* view size */
  /* menu 5 (A5-0xc3e) */
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc3e),7,*(short *)(unaff_A5 + -0x137a) == 8);
  set_menu_item_enabled(*(int *)(unaff_A5 + -0xc3e),0xb,*(short *)(unaff_A5 + -0x137a) != 4);
  CheckItem(*(int *)(unaff_A5 + -0xc3e),1,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) == 1);
  CheckItem(*(int *)(unaff_A5 + -0xc3e),2,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) == 2);
  CheckItem(*(int *)(unaff_A5 + -0xc3e),3,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) == 3);
  CheckItem(*(int *)(unaff_A5 + -0xc3e),4,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) == 4);
  CheckItem(*(int *)(unaff_A5 + -0xc3e),5,*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) == 5);
  CheckItem(*(int *)(unaff_A5 + -0xc3e),0x7,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x13));
  CheckItem(*(int *)(unaff_A5 + -0xc3e),0x9,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x15));
  CheckItem(*(int *)(unaff_A5 + -0xc3e),0x8,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x17));
  CheckItem(*(int *)(unaff_A5 + -0xc3e),0xb,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x1b));
  CheckItem(*(int *)(unaff_A5 + -0xc3e),0xa,*(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x19));
  return;
}



/* VERIFIED (ID02::FUN_00003590): ID02.bin 0x3590..0x35ba checked against an independent capstone disassembly.
 * TST.W $e / BEQ: EnableItem(8, word $c) $A939 else DisableItem $A93A; TST.W $c / BNE skips DrawMenuBar $A937 -
 * identical to the C. */
/* Original: FUN_00003590; source: ID02.c. Recovered name: set_menu_item_enabled [PROVEN].
 * Decoded from ID02.bin bytes at file 0x3590.
 * C args: +8 MenuHandle, +0xc short item, +0xe short enable. EnableItem ($A939) when enable != 0, else DisableItem ($A93A); item 0 means the whole menu, then DrawMenuBar ($A937). Callers: update_menu_items (0x31e2...). Ghidra lost the third argument; body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void set_menu_item_enabled /* Original: FUN_00003590 */ (int menu /* param_1: MenuHandle */,short item /* param_2: 0 = the whole menu */,short enabled /* param_3 */)

{
  if (enabled != 0) {
    EnableItem(menu,item);                /* $A939 */
  }
  else {
    DisableItem(menu,item);               /* $A93A */
  }
  if (item == 0) {                           /* whole menu: redraw the bar */
    DrawMenuBar();                              /* $A937 */
  }
  return;
}



/* VERIFIED (ID02::FUN_000035bc): ID02.bin 0x35bc..0x35e2 checked against an independent capstone disassembly.
 * settings word +$e CMP.W 8(A6) / BEQ out; MOVE.W 8(A6) to +$e; BSR 0x27e4 - identical to the C. */
/* Original: FUN_000035bc; source: ID02.c. Recovered name: set_view_size_option [PROVEN].
 * Decoded from ID02.bin bytes at file 0x35bc.
 * C arg +8 short size (1..4). When it differs from settings word +0xe (handle A5-0x13ac): stores it and calls configure_display_from_main_device (0x27e4) to relayout the view. Ghidra C complete apart from the call; the unsigned undefined2 parameter is corrected to short (CMP.W).
 */
void set_view_size_option /* Original: FUN_000035bc */ (short size_option /* param_1: settings +0xe */)

{
  int unaff_A5;
  
  if (*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) != size_option) { /* CMP.W: word compare */
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) = size_option;
    configure_display_from_main_device();       /* BSR 0x27e4 */
  }
  return;
}



/* VERIFIED (ID02::FUN_000035e4): ID02.bin 0x35e4..0x36a0 checked against an independent capstone disassembly.
 * JT $132 TST.W / BEQ.W out, JT $82 likewise; MOVEA.W A5-0x12f8 pushed as a long to JSR (A5-0x109a); TST.W A5-0x14c6:
 * -6 = thePort, SetPort(window), InvalRect(window+$10), SetPort(-6); CLR.W A5-0x12f0; word loop 0..11 clearing
 * A5-0x13a2[i] then A5-0x12ce[i]; CLR.W -0x12b4 / -0x12b6 / -0x12b2 / -0x14c4 / -0x14c2 / -0x14c0; A5-0x102e &&
 * A5-0x1006 && depth == 1 && A5-0x14c6 -> JSR (A5-0x1096); BSR 0x4fc - identical to the C. */
/* Original: FUN_000035e4; source: ID02.c. Recovered name: start_new_mission [STRONG INFERENCE].
 * Decoded from ID02.bin bytes at file 0x35e4.
 * Ghidra truncated the window branch; body completed as C below; bytes 0x35e4..0x36a0 [PROVEN]: returns unless run_duty_roster_dialog (JT $132, ID04 0x644) and run_scenario_selection_dialog (JT $82, ID04 0xc02) are both confirmed (non-zero); overlay hook A5-0x109a(mission A5-0x12f8); when the game window is up, SetPort + InvalRect(portRect) ($A928); clears A5-0x12f0, the 12 words of mission kills A5-0x12ce and of A5-0x13a2, the pilot status A5-0x12b4, the friendly-kill count A5-0x12b6, A5-0x12b2, the mission-over flag A5-0x14c4, A5-0x14c2 and the objective words A5-0x14c0; at depth 1 with the overlay loaded and the window shown, calls the hook A5-0x1096; then run_flight_session (0x4fc). Callers: 0x30ec (start-up) and 0x3742 (menu command).
 */
// WARNING: Control flow encountered bad instruction data

void start_new_mission /* Original: FUN_000035e4 */ (void)

{
  short ok; /* sVar1: dialog result, 0 = cancelled */
  int unaff_A5;
  int saved;                                    /* -6(A6) */
  short i; /* local_2 */                                /* -2(A6) */
  
  ok = (**(code **)(unaff_A5 + 0x132))();    /* JT $132 -> ID04 0x644: duty roster dialog */
  if (ok != 0) {
    ok = (**(code **)(unaff_A5 + 0x82))();   /* JT $82 -> ID04 0xc02: scenario selection dialog */
    if (ok != 0) {
      (**(code **)(unaff_A5 + -0x109a))((int)*(short *)(unaff_A5 + -0x12f8)); /* overlay hook */
      if (*(short *)(unaff_A5 + -0x14c6) != 0) {
        saved = *(int *)(unaff_A5 + -0x160c);   /* thePort */
        SetPort(*(int *)(unaff_A5 + -0x14ca));  /* $A873 */
        InvalRect((Rect *)(*(int *)(unaff_A5 + -0x14ca) + 0x10)); /* $A928, portRect */
        SetPort(saved);
      }
      *(undefined2 *)(unaff_A5 + -0x12f0) = 0;
      for (i = 0; i < 0xc; i = i + 1) {
        *(undefined2 *)(i * 2 + unaff_A5 + -0x13a2) = 0;
        *(undefined2 *)(i * 2 + unaff_A5 + -0x12ce) = 0;
      }
      *(undefined2 *)(unaff_A5 + -0x12b4) = 0;
      *(undefined2 *)(unaff_A5 + -0x12b6) = 0;
      *(undefined2 *)(unaff_A5 + -0x12b2) = 0;
      *(undefined2 *)(unaff_A5 + -0x14c4) = 0;
      *(undefined2 *)(unaff_A5 + -0x14c2) = 0;
      *(undefined2 *)(unaff_A5 + -0x14c0) = 0;
      if ((((*(short *)(unaff_A5 + -0x102e) != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) &&
          (*(short *)(unaff_A5 + -0x137a) == 1)) && (*(short *)(unaff_A5 + -0x14c6) != 0)) {
        (**(code **)(unaff_A5 + -0x1096))();
      }
      run_flight_session();                     /* BSR 0x4fc */
    }
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_000036a2): ID02.bin 0x36a2..0x39a6 checked against an independent capstone disassembly.
 * HiWord $A86A / LoWord $A86B to -2 / -4; JSR $3a(A5) tables 0x36ca (menus 1..5), 0x36e2 (item 1), 0x3722 (1..13),
 * 0x37f4 (1..10), 0x38b4 (1..11) decoded programmatically; Apple: JT $162 or GetPort(-$108) / GetItem(A5-0xc4e,
 * item, -$104) / OpenDeskAcc / SetPort; menu 2 as in the C (JT $1da + UnloadSeg $1ea / $56a; BSR 0x2da0; BSR 0x35e4;
 * JT $da(A5-0xd6a, 3) with SEQ result unused; JT $10a; BSR 0x4fc; A5-0x12f0 = 1 + BSR 0x4fc; JT $13a == 2 -> CLR.W
 * A5-0x12f8, HideWindow, CLR.W A5-0x14c6; JT $102; BSR 0x2eaa); Edit: SystemEdit(item - 1) $A9C2 TST.B, SysBeep(5);
 * menus 4 / 5: BCHG #0 on settings bytes 3 / 5 / 7 / 9 / $13 / $17 / $15 / $19 / $1b, BCHG A5-0x102f (no dirty),
 * BSR 0x35bc(1 / 3 / 2), MOVE.W 1..5 to settings+$10, each other case MOVE.W #1 to A5-0x138a; all paths end at
 * 0x39a0 BSR 0x2a44 - identical to the C. */
/*
 * Original: FUN_000036a2; source: ID02.c:1759-1764.
 * Recovered name: do_menu_command [STRONG INFERENCE].
 * All five menus described; body rebuilt as C below from ID02.bin file 0x36a2..0x39a6 [PROVEN, bytes]
 * (menu 1 item 1 is show_about_dialog; menu 2 item 1 is ID08 bootstrap_window_and_load_overlay).
 * Input: long menuResult at 8(A6) (from MenuKey in poll_and_dispatch_event;
 * presumably also MenuSelect via the mouseDown path).
 *   menu = HiWord(menuResult) ($A86A) -> -2(A6); item = LoWord ($A86B) -> -4(A6)
 * Switch tables are ID01 runtime-helper format (lo, hi, default, offsets
 * relative to their own word); parsed programmatically, targets in file coords.
 *
 * switch (menu) [table 0x36ca, 1..5, default -> exit 0x39a0]:
 *  1 (Apple, 0x36da): item 1 -> JSR $162(A5) [UNKNOWN, likely About box];
 *       other -> GetPort(&save) $A874; GetItem(A5-0xc4e, item, name) $A946;
 *       OpenDeskAcc(name) $A9B6; SetPort(save) $A873       [desk accessories]
 *  2 (0x371a) item switch [table 0x3722, 1..13]:
 *       1 -> JSR $1da(A5) (seg8 file 0x39c); UnloadSeg seg 8, seg 5 [HYPOTHESIS: start flight]
 *       2 -> BSR 0x2da0: if word A5-0x138a: ChangedResource+WriteResource(HEL1 127), clear flag
 *       3, 10, 12 -> no action (separator lines) [HYPOTHESIS]
 *       4 -> BSR 0x35e4 (also called conditionally by main)
 *       5 -> D0 = (JSR $da(A5)(A5-0xd6a, 3) == 3) [seg4 file 0x31aa; result unused here]
 *       6 -> JSR $10a(A5) (seg4 file 0x3976)
 *       7 -> BSR 0x4fc;  8 -> word A5-0x12f0 = 1; BSR 0x4fc
 *       9 -> if (JSR $13a(A5) (seg4 file 0x516) == 2):
 *              word A5-0x12f8 = 0; HideWindow(main_window A5-0x14ca) $A916;
 *              word A5-0x14c6 = 0 (disables update redraw)
 *       11 -> JSR $102(A5) (seg4 file 0x137a)
 *       13 -> BSR 0x2eaa [STRONG INFERENCE: quit; same helper as the fatal
 *             path in initialize_application]
 *  3 (Edit, 0x37ce): if (!SystemEdit(item - 1)) ($A9C2) SysBeep(5) ($A9C8)
 *  Let S = *(HEL1 127 handle A5-0x13ac) (settings record, 0x12a bytes) and
 *  DIRTY = word A5-0x138a = 1 (consumed by menu 2 item 2 save helper 0x2da0).
 *  4 (0x37ec) item switch [table 0x37f4, 1..10]:
 *       1 -> BCHG #0, S+3;  DIRTY      2 -> BCHG #0, S+5;  DIRTY
 *       4 -> BCHG #0, byte A5-0x102f (not persisted, no DIRTY)
 *       5 -> BCHG #0, S+7;  DIRTY      6 -> BCHG #0, S+9;  DIRTY
 *       8 -> FUN_000035bc(1); DIRTY    9 -> FUN_000035bc(3); DIRTY
 *      10 -> FUN_000035bc(2); DIRTY    3, 7 -> no action (separators) [HYPOTHESIS]
 *       FUN_000035bc(v) [ID02.c C]: if word S+0xe != v, store v, BSR 0x27e4
 *       (also called at end of initialize_application) [UNKNOWN: re-layout?]
 *  5 (0x38ac) item switch [table 0x38b4, 1..11]:
 *       1..5 -> word S+0x10 = item (1..5); DIRTY   [radio group; default 2]
 *       6 -> no action (separator) [HYPOTHESIS]
 *       7 -> BCHG #0, S+0x13   8 -> S+0x17   9 -> S+0x15   10 -> S+0x19
 *      11 -> S+0x1b; each DIRTY
 *  Epilogue (every path, file 0x39a0): BSR 0x2a44 (apply_settings_to_live_options,
 *  FUN_00002a44: copies S words into live A5 options), UNLK, RTS.
 *  BCHG on odd byte S+2n+1 flips bit 0 of big-endian word S+2n.
 *  Defaults when HEL1 127 is created (initialize_application): S+0x0e=1,
 *  S+0x10=2, S+0x24=2, S+0x26=1. Bit-0 toggles imply on/off options
 *  [STRONG INFERENCE]; which game option each byte controls is UNKNOWN.
 *  Note: Capstone mis-aligns at 0x38cc; case 1 entry 0x38d0 decodes as
 *  MOVEA.L -$13ac(A5),A0; MOVEA.L (A0),A0; MOVEQ #1,D0; MOVE.W D0,$10(A0).
 * Trap names: Inside Macintosh [STRONG INFERENCE]. Menu titles UNKNOWN until
 * MENU resources are examined.
 */
void do_menu_command /* Original: FUN_000036a2 */ (int menu_result /* param_1: MenuSelect / MenuKey result, menu ID << 16 | item */)

{
  int unaff_A5;
  int saved;                                    /* -$108(A6) */
  byte name[256];                               /* -$104(A6): Str255 */
  short item;                                   /* -4(A6) */
  short menu;                                   /* -2(A6) */

  menu = HiWord(menu_result);                       /* $A86A */
  item = LoWord(menu_result);                       /* $A86B */
  switch (menu) {                               /* JSR $3a(A5) -> ID01 0xbe, table 0x36ca lo 1 hi 5 */
  case 1:                                       /* Apple */
    if (item == 1) {                            /* table 0x36e2 */
      show_about_dialog();                      /* JT $162 -> ID04 0x3a8c */
    }
    else {
      GetPort(&saved);                          /* $A874 */
      GetItem(*(int *)(unaff_A5 + -0xc4e),item,name); /* $A946 */
      OpenDeskAcc(name);                        /* $A9B6, result discarded */
      SetPort(saved);                           /* $A873 */
    }
    break;
  case 2:                                       /* table 0x3722 lo 1 hi 13; 3, 10, 12 and default: nothing */
    switch (item) {
    case 1:
      bootstrap_window_and_load_overlay();      /* JT $1da -> ID08 0x39c */
      UnloadSeg((void *)(unaff_A5 + 0x1ea));    /* $A9F1: segment 8 */
      UnloadSeg((void *)(unaff_A5 + 0x56a));    /* segment 5 */
      break;
    case 2:
      FUN_00002da0();                           /* BSR 0x2da0: save settings if dirty (no inventory entry) */
      break;
    case 4:
      start_new_mission();                      /* BSR 0x35e4 */
      break;
    case 5:
      conclude_mission(3,*(int *)(unaff_A5 + -0xd6a)); /* JT $da -> ID04 0x31aa; (== 3) computed, unused */
      break;
    case 6:
      (**(code **)(unaff_A5 + 0x10a))();        /* JT $10a -> ID04 0x3976 (no inventory entry) */
      break;
    case 7:
      run_flight_session();                     /* BSR 0x4fc */
      break;
    case 8:
      *(short *)(unaff_A5 + -0x12f0) = 1;
      run_flight_session();
      break;
    case 9:
      if (confirm_end_mission() == 2) {         /* JT $13a -> ID04 0x516 */
        *(short *)(unaff_A5 + -0x12f8) = 0;
        HideWindow(*(int *)(unaff_A5 + -0x14ca)); /* $A916 */
        *(short *)(unaff_A5 + -0x14c6) = 0;
      }
      break;
    case 0xb:
      (**(code **)(unaff_A5 + 0x102))();        /* JT $102 -> ID04 0x137a (no inventory entry) */
      break;
    case 0xd:
      FUN_00002eaa();                           /* BSR 0x2eaa: quit (no inventory entry) */
      break;
    }
    break;
  case 3:                                       /* Edit */
    if (SystemEdit(item + -1) == '\0') {        /* $A9C2 */
      SysBeep(5);                               /* $A9C8 */
    }
    break;
  case 4:                                       /* table 0x37f4 lo 1 hi 10; 3, 7 and default: nothing */
    switch (item) {
    case 1:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x3) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x3) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 2:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x5) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x5) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 4:
      *(byte *)(unaff_A5 + -0x102f) = *(byte *)(unaff_A5 + -0x102f) ^ 1; /* not persisted */
      break;
    case 5:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x7) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x7) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 6:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x9) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x9) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 8:
      set_view_size_option(1);                /* BSR 0x35bc */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 9:
      set_view_size_option(3);                /* BSR 0x35bc */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 10:
      set_view_size_option(2);                /* BSR 0x35bc */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    }
    break;
  case 5:                                       /* table 0x38b4 lo 1 hi 11; 6 and default: nothing */
    switch (item) {
    case 1:
      *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = 1;
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 2:
      *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = 2;
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 3:
      *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = 3;
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 4:
      *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = 4;
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 5:
      *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x10) = 5;
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 0x7:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x13) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x13) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 0x8:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x17) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x17) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 0x9:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x15) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x15) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 0xa:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x19) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x19) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    case 0xb:
      *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x1b) = *(byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x1b) ^ 1; /* BCHG #0 */
      *(short *)(unaff_A5 + -0x138a) = 1;         /* settings dirty */
      break;
    }
    break;
  }
  apply_settings_to_live_options();             /* BSR 0x2a44, every path */
  return;
}



/* VERIFIED (ID02::FUN_000039a8): ID02.bin 0x39a8..0x3aaa checked against an independent capstone disassembly.
 * CLR.L slot, MOVEM D0-D7/A0-A6, LEA $39c4(PC),A5; cache 0 -> MOVE.L $904.w to it, MOVEM back, LEA 4(A7), RTS;
 * else A5 = cache, $3c(A7) = A5-0xc36 (chain), A4 = head A5-0x7d0, D0 / D1 / A0 / D4 = node +0 / +4 / +8 / +$10, D2 =
 * A5-0xc32, D3 = A5-0xc2e, A6 = $266.w + 4; (end - cursor) CMP.L A5-0xc2a BLE -> slow path. Fast: D7 = $5b, four
 * MOVE.B (A0,D0.L),(A6) / ADDQ #2 / ADD.L D3,D1 / ADDX.L D2,D0 per DBRA, then A6 = $266.w and two more. Slow: D7 =
 * $16f then 1 (A6 = $266.w), each sample first CMP.L D0,D4 BGT else A4 = +$18, A0 = +8, D0 = +$c, D1 = 0, D4 = +$10,
 * head = A4; node +0 / +4 = D0 / D1; MOVEM back, RTS into the chained handler - identical to the C. */
/*
 * Original: FUN_000039a8; source: ID02.c:1768.
 * Recovered name: vbl_sound_handler_ch0_unrolled [STRONG INFERENCE].
 * Exported C kept, with the SoundBase pointers (Ghidra's DAT_66fa4e75/77/79 constants) and the
 * register-chaining tail made explicit.
 * Interrupt-hook pattern [PROVEN, bytes]: CLR.L -(A7) reserves a return slot;
 * MOVEM saves D0-D7/A0-A6; A5 is taken from a long stored inside the code
 * (PC-relative, +0x1c from entry). If that cache is 0 (first call, made by
 * init_sound_system with the application A5) it stores CurrentA5 ($0904) there
 * and returns - priming only. Otherwise it writes the saved previous vector
 * (long A5-0xc36) into the reserved slot, does its work, restores registers
 * and RTS-chains to the previous handler.
 * Installed into low-memory $0196 = Lvl1DT[1], the VIA CA1 vertical-blanking
 * level-1 interrupt vector [STRONG INFERENCE: Lvl1DT at $0192 per Inside
 * Macintosh; consistent with per-VBL refill of the 370-sample sound buffer].
 * Self-modifying code: the in-code A5 cache is written at run time.
 * JT A5+0x41a; selected by init_sound_system(param == 0).
 * Body: channel 0 node (head long A5-0x7d0): d0 cursor, d1 fraction, a0 buffer,
 * d4 end; step d2:d3 = A5-0xc32 / A5-0xc2e (32.32 fixed point via ADD/ADDX);
 * writes samples MOVE.B (A0,D0.L) into every other byte from SoundBase ($0266)
 * + 4, loop unrolled x8; end-of-buffer handling compares with A5-0xc2a.
 */
undefined8 vbl_sound_handler_ch0_unrolled /* Original: FUN_000039a8 */ (void)

{
  int step_int; /* iVar1: A5-0xc32, integer part of the sample step */
  uint step_frac; /* uVar2: A5-0xc2e, fraction of the step */
  uint frac_b; /* uVar3: running fraction (second sample) */
  uint frac_c; /* uVar4: running fraction (third sample) */
  undefined4 reg_d0; /* in_D0: passed through untouched (registers are saved and restored) */
  int a5; /* iVar5: the cached A5; also reused as a scratch position in the unrolled path */
  int pos; /* iVar6: sample position, integer part */
  undefined4 reg_d1; /* in_D1 */
  uint pos_frac; /* uVar7: sample position, fraction */
  int end; /* iVar8: end of the current sample (record +0x10) */
  short n; /* sVar9: DBRA counter */
  int samples; /* iVar10: sample data base (record +8) */
  int *chan; /* piVar11: channel record *(A5-2000): pos, frac, base, start, end, -, next */
  undefined1 *out; /* puVar12: SoundBase output cursor (every other byte) */
  bool carry; /* bVar13 */
  
  a5 = vbl_ch0_a5_cache;                         /* in-code A5 cache at 0x39c4 */
  if (vbl_ch0_a5_cache != 0) {
    chan = *(int **)(vbl_ch0_a5_cache + -2000);
    pos = *chan;
    pos_frac = chan[1];
    samples = chan[2];
    end = chan[4];
    step_int = *(int *)(vbl_ch0_a5_cache + -0xc32);
    step_frac = *(uint *)(vbl_ch0_a5_cache + -0xc2e);
    out = *(undefined1 **)0x266 + 4;       /* SoundBase + 4 (Ghidra: &DAT_66fa4e79) */
    if (*(int *)(vbl_ch0_a5_cache + -0xc2a) < end - pos) {
      n = 0x5b;
      do {
        *out = *(undefined1 *)(samples + pos);
        a5 = step_int + pos + (uint)CARRY4(step_frac,pos_frac);
        out[2] = *(undefined1 *)(samples + a5);
        frac_b = step_frac + step_frac + pos_frac;
        a5 = step_int + a5 + (uint)CARRY4(step_frac,step_frac + pos_frac);
        out[4] = *(undefined1 *)(samples + a5);
        frac_c = step_frac + frac_b;
        a5 = step_int + a5 + (uint)CARRY4(step_frac,frac_b);
        out[6] = *(undefined1 *)(samples + a5);
        out = out + 8;
        pos_frac = step_frac + frac_c;
        pos = step_int + a5 + (uint)CARRY4(step_frac,frac_c);
        n = n + -1;
      } while (n != -1);
      **(undefined1 **)0x266 = *(undefined1 *)(samples + pos); /* SoundBase + 0 */
      frac_b = step_frac + pos_frac;
      a5 = step_int + pos + (uint)CARRY4(step_frac,pos_frac);
      *(*(undefined1 **)0x266 + 2) = *(undefined1 *)(samples + a5); /* SoundBase + 2 */
      pos_frac = step_frac + frac_b;
      pos = step_int + a5 + (uint)CARRY4(step_frac,frac_b);
    }
    else {
      n = 0x16f;
      do {
        if (end <= pos) {
          chan = (int *)chan[6];
          samples = chan[2];
          pos = chan[3];
          pos_frac = 0;
          end = chan[4];
          *(int **)(a5 + -2000) = chan;
        }
        *out = *(undefined1 *)(samples + pos);
        out = out + 2;
        carry = CARRY4(step_frac,pos_frac);
        pos_frac = step_frac + pos_frac;
        pos = step_int + pos + (uint)carry;
        n = n + -1;
      } while (n != -1);
      out = *(undefined1 **)0x266;         /* SoundBase (Ghidra: &DAT_66fa4e75) */
      n = 1;
      do {
        if (end <= pos) {
          chan = (int *)chan[6];
          samples = chan[2];
          pos = chan[3];
          pos_frac = 0;
          end = chan[4];
          *(int **)(a5 + -2000) = chan;
        }
        *out = *(undefined1 *)(samples + pos);
        out = out + 2;
        carry = CARRY4(step_frac,pos_frac);
        pos_frac = step_frac + pos_frac;
        pos = step_int + pos + (uint)carry;
        n = n + -1;
      } while (n != -1);
    }
    *chan = pos;
    chan[1] = pos_frac;
    (**(code **)(a5 + -0xc36))();          /* MOVE.L -$c36(A5),$3c(A7) filled the reserved slot: the
                                                 final RTS tail-chains to the previous Lvl1DT[1] handler
                                                 with all registers restored */
    return CONCAT44(reg_d0,reg_d1);
  }
  vbl_ch0_a5_cache = CurrentA5;                  /* first call: cache CurrentA5 in the code; plain return */
  return CONCAT44(reg_d0,reg_d1);
}



/* VERIFIED (ID02::FUN_00003aae): ID02.bin 0x3aae..0x3bc0 checked against an independent capstone disassembly.
 * Same entry / first-call / chaining frame as 0x39a8 (cache at 0x3aca); fast path (end - cursor > A5-0xc2a): ADDA.L D0,A0,
 * ADDI.L #$172,D0, BTST #0 of A0: even -> 92 x MOVE.L (A0)+,D1 / MOVEP.L D1,0(A6) / ADDQ #8, then A6 = $266.w and two
 * MOVE.B; odd -> one MOVE.B, SUBQ.L #1 D7 (91 longs), three MOVE.B, A6 = $266.w, two MOVE.B; slow path as 0x39a8; node
 * +0 / +4 = D0 / D1 - identical to the C. */
/*
 * Original: FUN_00003aae; source: ID02.c:1868.
 * Recovered name: vbl_sound_handler_ch0_variant [STRONG INFERENCE].
 * Exported C kept, with the SoundBase pointers (Ghidra's DAT_66fa4e75/77/79/7b constants) and the
 * register-chaining tail made explicit.
 * Interrupt-hook pattern [PROVEN, bytes]: CLR.L -(A7) reserves a return slot;
 * MOVEM saves D0-D7/A0-A6; A5 is taken from a long stored inside the code
 * (PC-relative, +0x1c from entry). If that cache is 0 (first call, made by
 * init_sound_system with the application A5) it stores CurrentA5 ($0904) there
 * and returns - priming only. Otherwise it writes the saved previous vector
 * (long A5-0xc36) into the reserved slot, does its work, restores registers
 * and RTS-chains to the previous handler.
 * Installed into low-memory $0196 = Lvl1DT[1], the VIA CA1 vertical-blanking
 * level-1 interrupt vector [STRONG INFERENCE: Lvl1DT at $0192 per Inside
 * Macintosh; consistent with per-VBL refill of the 370-sample sound buffer].
 * Self-modifying code: the in-code A5 cache is written at run time.
 * JT A5+0x412; selected by init_sound_system(param != 0).
 * Body: slow path identical to vbl_sound_handler_ch0_unrolled (resampled, node switching); the fast path
 * is a 1:1 copy without resampling: MOVEP.L of 92 longs to SoundBase + 4 (odd source: one byte, 91 longs,
 * three bytes), then two bytes at SoundBase + 0 / + 2; cursor += 0x172 and the stored fraction becomes the
 * last long copied (D1 reused) [PROVEN].
 */
undefined8 vbl_sound_handler_ch0_variant /* Original: FUN_00003aae */ (void)

{
  int step_int; /* iVar1: A5-0xc32, integer part of the sample step */
  uint step_frac; /* uVar2: A5-0xc2e, fraction of the step */
  int a5; /* iVar3: the cached A5 */
  undefined4 reg_d0; /* in_D0: passed through untouched */
  int pos; /* iVar4: sample position, integer part */
  undefined4 reg_d1; /* in_D1 */
  uint pos_frac; /* uVar5: sample position fraction; the long just copied on the fast path */
  int end; /* iVar6: end of the current sample (record +0x10) */
  short n; /* sVar7: DBRA counter */
  uint *src; /* puVar8: source long cursor (fast path) */
  uint *src_cur; /* puVar9: the long being copied */
  int samples; /* iVar10: sample data base (record +8) */
  int *chan; /* piVar11: channel record *(A5-2000): pos, frac, base, start, end, -, next */
  undefined1 *out; /* puVar12: SoundBase output cursor (every other byte) */
  undefined1 *out_cur; /* puVar13: output cursor of the current group (odd-source path) */
  bool carry; /* bVar14 */
  
  a5 = vbl_ch0_variant_a5_cache;                         /* in-code A5 cache at 0x3aca */
  if (vbl_ch0_variant_a5_cache != 0) {
    chan = *(int **)(vbl_ch0_variant_a5_cache + -2000);
    pos = *chan;
    pos_frac = chan[1];
    samples = chan[2];
    end = chan[4];
    out = *(undefined1 **)0x266 + 4;                      /* SoundBase + 4 (Ghidra: &DAT_66fa4e79) */
    step_int = *(int *)(vbl_ch0_variant_a5_cache + -0xc32);
    step_frac = *(uint *)(vbl_ch0_variant_a5_cache + -0xc2e);
    if (*(int *)(vbl_ch0_variant_a5_cache + -0xc2a) < end - pos) {
      n = 0x5b;
      src = (uint *)(pos + samples);
      pos = pos + 0x172;
      if (((uint)src & 1) == 0) {
        do {
          src_cur = src;
          pos_frac = *src_cur;
          *out = (char)(pos_frac >> 0x18);
          out[2] = (char)(pos_frac >> 0x10);
          out[4] = (char)(pos_frac >> 8);
          out[6] = (char)pos_frac;
          out = out + 8;
          n = n + -1;
          src = src_cur + 1;
        } while (n != -1);
        **(undefined1 **)0x266 = *(undefined1 *)(src_cur + 1);          /* SoundBase + 0 */
        *(*(undefined1 **)0x266 + 2) = *(undefined1 *)((int)src_cur + 5); /* SoundBase + 2 */
      }
      else {
        *(*(undefined1 **)0x266 + 4) = *(undefined1 *)src;        /* odd source: one leading byte */
        n = 0x5a;
        src = (uint *)((int)src + 1);
        out = *(undefined1 **)0x266 + 6;                    /* SoundBase + 6 */
        do {
          out_cur = out;
          src_cur = src;
          pos_frac = *src_cur;
          *out_cur = (char)(pos_frac >> 0x18);
          out_cur[2] = (char)(pos_frac >> 0x10);
          out_cur[4] = (char)(pos_frac >> 8);
          out_cur[6] = (char)pos_frac;
          n = n + -1;
          src = src_cur + 1;
          out = out_cur + 8;
        } while (n != -1);
        out_cur[8] = *(undefined1 *)(src_cur + 1);
        out_cur[10] = *(undefined1 *)((int)src_cur + 5);
        out_cur[0xc] = *(undefined1 *)((int)src_cur + 6);
        **(undefined1 **)0x266 = *(undefined1 *)((int)src_cur + 7);
        *(*(undefined1 **)0x266 + 2) = *(undefined1 *)(src_cur + 2);
      }
    }
    else {
      n = 0x16f;
      do {
        if (end <= pos) {
          chan = (int *)chan[6];
          samples = chan[2];
          pos = chan[3];
          pos_frac = 0;
          end = chan[4];
          *(int **)(a5 + -2000) = chan;
        }
        *out = *(undefined1 *)(samples + pos);
        out = out + 2;
        carry = CARRY4(step_frac,pos_frac);
        pos_frac = step_frac + pos_frac;
        pos = step_int + pos + (uint)carry;
        n = n + -1;
      } while (n != -1);
      out = *(undefined1 **)0x266;                          /* SoundBase */
      n = 1;
      do {
        if (end <= pos) {
          chan = (int *)chan[6];
          samples = chan[2];
          pos = chan[3];
          pos_frac = 0;
          end = chan[4];
          *(int **)(a5 + -2000) = chan;
        }
        *out = *(undefined1 *)(samples + pos);
        out = out + 2;
        carry = CARRY4(step_frac,pos_frac);
        pos_frac = step_frac + pos_frac;
        pos = step_int + pos + (uint)carry;
        n = n + -1;
      } while (n != -1);
    }
    *chan = pos;
    chan[1] = pos_frac;                         /* fast path: the last long copied (D1 reused) */
    (**(code **)(a5 + -0xc36))();          /* reserved slot = A5-0xc36: RTS tail-chains to the previous
                                                 Lvl1DT[1] handler with all registers restored */
    return CONCAT44(reg_d0,reg_d1);
  }
  vbl_ch0_variant_a5_cache = CurrentA5;                  /* first call: cache CurrentA5 in the code; plain return */
  return CONCAT44(reg_d0,reg_d1);
}



// WARNING: Globals starting with '_' overlap smaller symbols at the same address

/* VERIFIED (ID02::FUN_00003bc4): ID02.bin 0x3bc4..0x3d32 checked against an independent capstone disassembly.
 * Same entry / first-call / chaining frame (cache at 0x3be0); A2 = ch1 head A5-0x598, A1 = node +8 + cursor, A3 =
 * cursor + $172 (ADDA.W); ch0 registers as 0x39a8; D6 = 0; each sample MOVEQ #0 D5, MOVE.B (A0,D0.L),D5, ADD.L D3,D1 /
 * ADDX.L D2,D0, MOVE.B (A1)+,D6, ADD.W D6,D5, SUBI.W #$80, MOVE.B D5,(A6), ADDQ #2; fast path D7 = $b7 x 2 then two at
 * $266.w; slow path $16f then 1 with ch0 node switching; ch0 +0 / +4 saved; CMPA.L ch1 +$10,A3 / BLT: A2 = +$18, A3 = +$c,
 * head = A2, LEA A5-0xc26 CMPA.L +8 / BNE else $196.w = A5-0x360; (A2) = A3 - identical to the C. */
/*
 * Original: FUN_00003bc4; source: ID02.c:1990.
 * Recovered name: vbl_sound_handler_two_channel [STRONG INFERENCE].
 * Exported C kept, with the SoundBase pointers (Ghidra's DAT_66fa4e75/77/79 constants), the $0196
 * store and the register-chaining tail made explicit.
 * Interrupt-hook pattern [PROVEN, bytes]: CLR.L -(A7) reserves a return slot;
 * MOVEM saves D0-D7/A0-A6; A5 is taken from a long stored inside the code
 * (PC-relative, +0x1c from entry). If that cache is 0 (first call, made by
 * init_sound_system with the application A5) it stores CurrentA5 ($0904) there
 * and returns - priming only. Otherwise it writes the saved previous vector
 * (long A5-0xc36) into the reserved slot, does its work, restores registers
 * and RTS-chains to the previous handler.
 * Installed into low-memory $0196 = Lvl1DT[1], the VIA CA1 vertical-blanking
 * level-1 interrupt vector [STRONG INFERENCE: Lvl1DT at $0192 per Inside
 * Macintosh; consistent with per-VBL refill of the 370-sample sound buffer].
 * Self-modifying code: the in-code A5 cache is written at run time.
 * JT A5+0x422 (A5-0x35c); installed by select_two_channel_sound_handler(1).
 * Body: mixes channel 1 (record A5-0x598 = A5-0x7d0 + 0x238; a1 buffer) with
 * channel 0 (a0) into SoundBase: out = (u8)(ch0 + ch1 - 0x80), no clipping; channel 1 is read 1:1
 * (370 bytes per call, no per-sample end test); when its cursor passes the node end it advances to
 * node +0x18 and, if that node is the silence buffer A5-0xc26, writes $0196 = A5-0x360, restoring the
 * single-channel handler [PROVEN].
 */
undefined8 vbl_sound_handler_two_channel /* Original: FUN_00003bc4 */ (void)

{
  int step_int; /* iVar1: A5-0xc32, integer part of the channel 0 step */
  uint step_frac; /* uVar2: A5-0xc2e, fraction of the step */
  uint frac_b; /* uVar3: running fraction (second sample) */
  int a5; /* iVar4: the cached A5 */
  undefined4 reg_d0; /* in_D0: passed through untouched */
  int end; /* iVar5: end of the channel 0 sample; scratch position on the fast path */
  int pos; /* iVar6: channel 0 position, integer part */
  undefined4 reg_d1; /* in_D1 */
  uint pos_frac; /* uVar7: channel 0 position, fraction */
  short n; /* sVar8: DBRA counter */
  int samples; /* iVar9: channel 0 sample data base (record +8) */
  char *p1; /* pcVar10: channel 1 byte cursor (1:1); the output cursor for the last two samples */
  char *p1_cur; /* pcVar11: channel 1 bytes being mixed */
  char *p1_next; /* pcVar12: channel 1 cursor for the last two samples */
  int *chan1; /* piVar13: channel 1 record *(A5-0x598): pos, -, base, start, end, -, next */
  int pos1_next; /* iVar14: channel 1 position after this buffer (+370) */
  int *chan0; /* piVar15: channel 0 record *(A5-2000): pos, frac, base, start, end, -, next */
  char *out; /* pcVar16: SoundBase output cursor (every other byte); the channel 0 sample pointer for the last two samples */
  bool carry; /* bVar17 */
  
  a5 = vbl_two_channel_a5_cache;                         /* in-code A5 cache at 0x3be0 */
  if (vbl_two_channel_a5_cache != 0) {
    chan1 = *(int **)(vbl_two_channel_a5_cache + -0x598);
    p1 = (char *)(*chan1 + chan1[2]);
    pos1_next = *chan1 + 0x172;
    chan0 = *(int **)(vbl_two_channel_a5_cache + -2000);
    pos = *chan0;
    pos_frac = chan0[1];
    samples = chan0[2];
    end = chan0[4];
    step_int = *(int *)(vbl_two_channel_a5_cache + -0xc32);
    step_frac = *(uint *)(vbl_two_channel_a5_cache + -0xc2e);
    out = *(char **)0x266 + 4;                         /* SoundBase + 4 (Ghidra: &DAT_66fa4e79) */
    if (*(int *)(vbl_two_channel_a5_cache + -0xc2a) < end - pos) {
      n = 0xb7;
      do {
        p1_cur = p1;
        frac_b = step_frac + pos_frac;
        end = step_int + pos + (uint)CARRY4(step_frac,pos_frac);
        *out = *p1_cur + *(char *)(samples + pos) + -0x80;
        pos_frac = step_frac + frac_b;
        pos = step_int + end + (uint)CARRY4(step_frac,frac_b);
        out[2] = p1_cur[1] + *(char *)(samples + end) + -0x80;
        out = out + 4;
        n = n + -1;
        p1 = p1_cur + 2;
      } while (n != -1);
      frac_b = step_frac + pos_frac;
      end = step_int + pos + (uint)CARRY4(step_frac,pos_frac);
      **(char **)0x266 = p1_cur[2] + *(char *)(samples + pos) + -0x80; /* SoundBase + 0 */
      pos_frac = step_frac + frac_b;
      pos = step_int + end + (uint)CARRY4(step_frac,frac_b);
      *(*(char **)0x266 + 2) = p1_cur[3] + *(char *)(samples + end) + -0x80; /* SoundBase + 2 */
    }
    else {
      n = 0x16f;
      do {
        if (end <= pos) {
          chan0 = (int *)chan0[6];
          samples = chan0[2];
          pos = chan0[3];
          pos_frac = 0;
          end = chan0[4];
          *(int **)(a5 + -2000) = chan0;
        }
        p1_cur = (char *)(samples + pos);
        carry = CARRY4(step_frac,pos_frac);
        pos_frac = step_frac + pos_frac;
        pos = step_int + pos + (uint)carry;
        p1_next = p1 + 1;
        *out = *p1 + *p1_cur + -0x80;
        out = out + 2;
        n = n + -1;
        p1 = p1_next;
      } while (n != -1);
      p1 = *(char **)0x266;                             /* SoundBase */
      n = 1;
      do {
        if (end <= pos) {
          chan0 = (int *)chan0[6];
          samples = chan0[2];
          pos = chan0[3];
          pos_frac = 0;
          end = chan0[4];
          *(int **)(a5 + -2000) = chan0;
        }
        out = (char *)(samples + pos);
        carry = CARRY4(step_frac,pos_frac);
        pos_frac = step_frac + pos_frac;
        pos = step_int + pos + (uint)carry;
        *p1 = *p1_next + *out + -0x80;
        p1 = p1 + 2;
        n = n + -1;
        p1_next = p1_next + 1;
      } while (n != -1);
    }
    *chan0 = pos;
    chan0[1] = pos_frac;
    if (chan1[4] <= pos1_next) {
      chan1 = (int *)chan1[6];
      pos1_next = chan1[3];
      *(int **)(a5 + -0x598) = chan1;
      if (a5 + -0xc26 == chan1[2]) {
        *(undefined4 *)0x196 = *(undefined4 *)(a5 + -0x360); /* channel 1 back on silence: restore the
                                                     single-channel handler in Lvl1DT[1] */
      }
    }
    *chan1 = pos1_next;
    (**(code **)(a5 + -0xc36))();          /* reserved slot = A5-0xc36: RTS tail-chains to the previous
                                                 Lvl1DT[1] handler with all registers restored */
    return CONCAT44(reg_d0,reg_d1);
  }
  vbl_two_channel_a5_cache = CurrentA5;                  /* first call: cache CurrentA5 in the code; plain return */
  return CONCAT44(reg_d0,reg_d1);
}



/* VERIFIED (ID02::FUN_00003d36): ID02.bin 0x3d36..0x3d4e checked against an independent capstone disassembly.
 * No LINK; MOVEA.L $0266.w,A0; D1 = $80; D0 = $171; MOVE.B D1,(A0) / ADDQ.L #2 / DBRA (370 bytes) - identical to
 * the C after the SoundBase correction. */
/*
 * Original: FUN_00003d36; source: ID02.c:2108.
 * Recovered name: clear_sound_buffer_to_silence [STRONG INFERENCE].
 * Bytes file 0x3d36..0x3d4e [PROVEN]: MOVEA.L $0266.w,A0 (low-memory SoundBase,
 * Inside Macintosh); 370 DBRA passes (0x171 down through 0) of MOVE.B #$80,(A0);
 * ADDQ.L #2,A0 - writes the unsigned-8-bit midpoint into the high byte of
 * each word of the 370-word hardware sound buffer.
 * Ghidra error: it replaced the runtime pointer load with the constant
 * &DAT_66fa4e75 (bytes from the file, cf. ID09 selector artifact); corrected
 * to the SoundBase load.
 * Callers: shutdown_sound, FUN_00003dd0.
 */
void clear_sound_buffer_to_silence /* Original: FUN_00003d36 */ (void)

{
  short n; /* sVar1: DBRA counter, 370 samples */
  undefined1 *out; /* puVar2: SoundBase cursor (every other byte) */
  
  out = *(undefined1 **)0x266;               /* MOVEA.L $0266.w: SoundBase */
  n = 0x171;
  do {
    *out = 0x80;
    out = out + 2;
    n = n + -1;
  } while (n != -1);
  return;
}



/* VERIFIED (ID02::FUN_00003d50): ID02.bin 0x3d50..0x3db6 checked against an independent capstone disassembly.
 * A4 = record (MULU.L #$238 ch + A5-0x7d0)+4; free head = A4+$14; (A4) = $10, +4 = 0, +8 = $c, +$c = $10, +$10 =
 * $14; TST.W $18 ? +$14 : A4 to +$18; D0 = A4 - identical to the C. */
/*
 * Original: FUN_00003d50; source: ID02.c:2124-2148.
 * Recovered name: alloc_sound_buffer_node [STRONG INFERENCE].
 * Exported C complete; bytes 0x3d50..0x3db6 agree [PROVEN].
 * Args: ch, buffer ptr, start, end (longs), word repeat/link flag.
 * Pops a node from channel ch's free list (record A5-0x7d0 + ch*0x238, +4 =
 * free head; node +0x14 = next) and fills it: +0 = start (cursor), +4 = 0,
 * +8 = buffer, +0xc = start, +0x10 = end, +0x18 = flag ? node->next: node
 * (flag 0 makes the node loop on itself) [field roles STRONG INFERENCE].
 * No empty-list check. Returns the node.
 * Callers: init_sound_system (2x), silence_sound_channel, and further ID02 sites
 * (14 call sites renamed in total).
 */
undefined4 *
alloc_sound_buffer_node /* Original: FUN_00003d50 */ (int channel /* param_1 */,undefined4 samples /* param_2: sample data base (node +8) */,undefined4 start /* param_3: node +0 position and +0xc start */,undefined4 end /* param_4: node +0x10 */,undefined4 advance /* param_5: word flag, 1 = continue to the next node, 0 = loop on itself */
            )

{
  undefined4 *node; /* puVar1: node taken from the channel's free list A5-0x7cc */
  undefined4 *next; /* puVar2: node +0x18 successor */
  int unaff_A5;
  
  node = *(undefined4 **)(channel * 0x238 + unaff_A5 + -0x7cc);
  *(undefined4 *)(channel * 0x238 + unaff_A5 + -0x7cc) = node[5];
  *node = start;
  node[1] = 0;
  node[2] = samples;
  node[3] = start;
  node[4] = end;
  next = node;
  if (advance._0_2_ != 0) {
    next = (undefined4 *)node[5];
  }
  node[6] = next;
  return node;
}



// WARNING: Globals starting with '_' overlap smaller symbols at the same address

/* VERIFIED (ID02::FUN_00003db8): ID02.bin 0x3db8..0x3dce checked against an independent capstone disassembly.
 * CMPI.L #1 8(A6) / BNE; MOVE.L A5-0x35c to $0196.w - identical to the C. */
/*
 * Original: FUN_00003db8; source: ID02.c:2154-2163.
 * Recovered name: select_two_channel_sound_handler [STRONG INFERENCE].
 * If param == 1: low-memory $0196 (Lvl1DT[1] VBL vector) = A5-0x35c
 * (vbl_sound_handler_two_channel). Otherwise no change. Bytes 0x3db8..0x3dce
 * match the C.
 */
void select_two_channel_sound_handler /* Original: FUN_00003db8 */ (int channel /* param_1: 1 = install the two-channel handler A5-0x35c */)

{
  int unaff_A5;
  
  if (channel == 1) {
    *(undefined4 *)0x196 = *(undefined4 *)(unaff_A5 + -0x35c); /* Lvl1DT[1]; Ghidra's _FUN_00000196 label */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Globals starting with '_' overlap smaller symbols at the same address

/* VERIFIED (ID02::FUN_00003dd0): ID02.bin 0x3dd0..0x3f52 checked against an independent capstone disassembly.
 * MOVEM D5-D7/A2-A4; TST.W A5-0xc38 -> BSR 0x4318; ch loop D7 0..1 (MULU.L #$238 + A5-0x7d0): +$230 / +4 / +0 =
 * record + 8, node loop D6 0..18 storing record + (i + 1) * $1c + 8 at record + i * $1c + $1c; $456 bytes of $80 at
 * A5-0xc26 (post-decrement BGT); BSR 0x3d36; A5-0xc32 = 1, -0xc2e = 0, -0xc2a = $172; two BSR 0x3d50 with (ch, A5-0xc26,
 * 0, $172, word 0); A5-0x360 = TST.L 8 ? $412(A5) : $41a(A5); A5-0x35c = $422(A5); first time BSR 0x3aae, 0x39a8,
 * 0x3bc4; A5-0xc36 = $196.w, $196.w = A5-0x360; CLR.L A5-0x356; SndNewChannel $A807 (CLR.W result, PEA A5-0x356,
 * word 5, long 0, long 0); TST.W / BEQ: D0 = 1 and A5-0xc38 = 1, else D0 = 0 - identical to the C. */
/*
 * Original: FUN_00003dd0; source: ID02.c:2170-2230.
 * Recovered name: init_sound_system [STRONG INFERENCE].
 * Ghidra truncated the end; body completed as C (the node flag is 0, the tail calls
 * SndNewChannel and returns 1 / 0); bytes 0x3dd0..0x3f52 [PROVEN].
 *   if (sound active A5-0xc38) shutdown_sound;
 *   for ch in 0..1: record = A5-0x7d0 + ch*0x238; head (+0), free (+4) and
 *     tail (+0x230) = record+8; 20 nodes of 0x1c bytes from +8, linked via +0x14;
 *   A5-0xc26[0x456] = 0x80 (1110 bytes = 3 x 370 silent samples);
 *   clear_sound_buffer_to_silence;
 *   A5-0xc32 = 1, A5-0xc2e = 0, A5-0xc2a = 0x172 (370);
 *   alloc_sound_buffer_node(0 and 1, A5-0xc26, 0, 0x172, 0)  (looping silence);
 *   A5-0x360 = param ? JT A5+0x412: JT A5+0x41a;  A5-0x35c = JT A5+0x422;
 *   first time (word A5-0x352 == 0): set it, FUN_00003aae, FUN_000039a8,
 *     FUN_00003bc4;
 *   A5-0xc36 = low-memory long $0196 (saved; restored by shutdown_sound);
 *   $0196 = A5-0x360 (install the selected routine; $0196 = Lvl1DT[1], VBL
 *   level-1 interrupt vector, identified );
 *   A5-0x356 = 0; err = SndNewChannel(&A5-0x356, 5 sampledSynth, 0, nil) ($A807);
 *   err ? return 0 : (A5-0xc38 = 1, return 1).
 * Caller: ID02.c:606 (via a computed stack argument).
 */
short init_sound_system /* Original: FUN_00003dd0 */ (int use_variant /* param_1: nonzero = JT $412 (vbl_sound_handler_ch0_variant, 0x3aae), 0 = JT $41a (_unrolled, 0x39a8) */)

{
  short k; /* sVar1: node index, then the silence-buffer byte count */
  int ch; /* iVar2: channel 0..1, then the chosen handler address */
  int node0; /* iVar3: first of the channel's 20 buffer nodes (0x1c bytes each) */
  undefined1 *p; /* puVar4: silence buffer cursor (A5-0xc26) */
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0xc38) != 0) {
    shutdown_sound(); /* Original: FUN_00004318 */
  }
  for (ch = 0; ch < 2; ch = ch + 1) {
    node0 = ch * 0x238 + unaff_A5 + -0x7c8;
    *(int *)(ch * 0x238 + unaff_A5 + -0x5a0) = node0;
    *(int *)(ch * 0x238 + unaff_A5 + -0x7cc) = node0;
    *(int *)(ch * 0x238 + unaff_A5 + -2000) = node0;
    for (k = 0; k < 0x13; k = k + 1) {
      *(int *)(k * 0x1c + ch * 0x238 + unaff_A5 + -0x7b4) =
           (short)(k + 1) * 0x1c + ch * 0x238 + unaff_A5 + -0x7c8;
    }
  }
  p = (undefined1 *)(unaff_A5 + -0xc26);
  k = 0x456;
  while (0 < k) {
    *p = 0x80;
    p = p + 1;
    k = k + -1;
  }
  clear_sound_buffer_to_silence(); /* Original: FUN_00003d36 */
  *(undefined4 *)(unaff_A5 + -0xc32) = 1;
  *(undefined4 *)(unaff_A5 + -0xc2e) = 0;
  *(undefined4 *)(unaff_A5 + -0xc2a) = 0x172;
  alloc_sound_buffer_node(0,unaff_A5 + -0xc26,0,0x172,0); /* flag 0 (CLR.W): looping silence */
  alloc_sound_buffer_node(1,unaff_A5 + -0xc26,0,0x172,0);
  if (use_variant == 0) {
    ch = unaff_A5 + 0x41a;
  }
  else {
    ch = unaff_A5 + 0x412;
  }
  *(int *)(unaff_A5 + -0x360) = ch;
  *(int *)(unaff_A5 + -0x35c) = unaff_A5 + 0x422;
  if (*(short *)(unaff_A5 + -0x352) == 0) {
    *(undefined2 *)(unaff_A5 + -0x352) = 1;
    vbl_sound_handler_ch0_variant();
    vbl_sound_handler_ch0_unrolled();
    vbl_sound_handler_two_channel();
  }
  *(undefined4 *)(unaff_A5 + -0xc36) = *(undefined4 *)0x196; /* save Lvl1DT[1] */
  *(undefined4 *)0x196 = *(undefined4 *)(unaff_A5 + -0x360);
  *(undefined4 *)(unaff_A5 + -0x356) = 0;
  if (SndNewChannel((void *)(unaff_A5 + -0x356),5,0,0) != 0) { /* $A807, sampledSynth */
    return 0;                                   /* failure: A5-0xc38 left unchanged */
  }
  *(short *)(unaff_A5 + -0xc38) = 1;
  return 1;
}



/* VERIFIED (ID02::FUN_00003f54): ID02.bin 0x3f54..0x404e checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904; TST.W A5-0xc38, TST.L ch BLT, CMPI.L #2 BLT else D0 = 0; CMP.L $18 with $1c / BHI
 * (unsigned) -> three BSR 0x3d50 (start..loop_start flag 1, loop_start..loop_end flag 0, loop_end..end flag 1),
 * else (start..end flag 1, A5-0xc26 0..$172 flag 0); first result kept at -4; BSR 0x3db8(ch); record (MULU.L
 * #$238 + A5-0x7d0) head = -4; D0 = 1 - identical to the C. */
/*
 * Original: FUN_00003f54; source: ID02.c:2231-2260.
 * Recovered name: play_sample_on_channel [STRONG INFERENCE].
 * Exported C complete. Args: ch, sample buffer, start, end, loop_start,
 * loop_end (longs). CurrentA5 routine (DAT_00000904). Overlay service slot
 * A5-0x10de (JT $442).
 * Returns 0 if sound inactive (A5-0xc38 == 0) or ch outside 0..1. Otherwise:
 *   loop_start < loop_end: nodes [start, loop_start) -> [loop_start, loop_end)
 *     (flag 0: repeats itself) -> [loop_end, end);
 *   else: [start, end) -> looping silence (A5-0xc26, 0, 0x172);
 *   select_two_channel_sound_handler(ch); channel ch head (A5-0x7d0 +
 *   ch*0x238) = first node; returns 1.
 * Ghidra's CONCAT22(1,...) was the word flag 1 pushed for linked nodes (now written as 1 / 0).
 * Note the third (tail) node is only reached if the loop node is later
 * re-linked [HYPOTHESIS: sustain loop with release tail].
 */
undefined4
play_sample_on_channel /* Original: FUN_00003f54 */ (int channel /* param_1: 0 or 1 */,undefined4 samples /* param_2: sample data */,undefined4 start /* param_3 */,undefined4 end /* param_4 */,uint loop_start /* param_5: loop section when loop_start < loop_end */,
            uint loop_end /* param_6 */)

{
  int a5; /* iVar1: copy of CurrentA5 */
  undefined4 ok; /* uVar2: 1 = queued, 0 = sound off or bad channel */
  undefined4 first_node; /* local_8, -4(A6): the node the channel starts on */
  
  a5 = CurrentA5;
  /* A5 = CurrentA5 ($904) inside; flag words: 1 = continue to the next node, 0 = loop on itself */
  if (((*(short *)(CurrentA5 + -0xc38) == 0) || (channel < 0)) || (1 < channel)) {
    ok = 0;
  }
  else {
    if (loop_start < loop_end) {
      first_node = alloc_sound_buffer_node(channel,samples,start,loop_start,1);
      alloc_sound_buffer_node(channel,samples,loop_start,loop_end,0);
      alloc_sound_buffer_node(channel,samples,loop_end,end,1);
    }
    else {
      first_node = alloc_sound_buffer_node(channel,samples,start,end,1);
      alloc_sound_buffer_node(channel,a5 + -0xc26,0,0x172,0);
    }
    select_two_channel_sound_handler(channel);
    *(undefined4 **)(channel * 0x238 + a5 + -2000) = first_node;
    ok = 1;
  }
  return ok;
}



/* VERIFIED (ID02::FUN_00004050): ID02.bin 0x4050..0x412c checked against an independent capstone disassembly.
 * Same body as 0x3f54 without keeping the first node or storing the channel head; D0 = 0 / 1 - identical to
 * the C. */
/*
 * Original: FUN_00004050; source: ID02.c:2266-2296.
 * Recovered name: enqueue_sample_on_channel [STRONG INFERENCE mechanics /
 * HYPOTHESIS purpose].
 * Exported C complete; identical to play_sample_on_channel except that it does
 * NOT store the first node into the channel head (A5-0x7d0 + ch*0x238). Nodes
 * are allocated in free-list order with continuation = next free node, so the
 * new chain is only reached if the currently playing chain continues into the
 * free-list head [HYPOTHESIS; not verified against handler end-of-buffer code].
 * Returns 0 if sound inactive or ch outside 0..1, else 1 (after
 * select_two_channel_sound_handler(ch)). Overlay service slot A5-0x10da (JT $42a).
 */
undefined4
enqueue_sample_on_channel /* Original: FUN_00004050 */ (int channel /* param_1: 0 or 1 */,undefined4 samples /* param_2: sample data */,undefined4 start /* param_3 */,undefined4 end /* param_4 */,uint loop_start /* param_5: loop section when loop_start < loop_end */,
            uint loop_end /* param_6 */)

{
  int a5; /* iVar1: copy of CurrentA5 */
  undefined4 ok; /* uVar2: 1 = queued, 0 = sound off or bad channel */
  
  a5 = CurrentA5;
  /* A5 = CurrentA5 ($904) inside; flag words: 1 = continue to the next node, 0 = loop on itself */
  if (((*(short *)(CurrentA5 + -0xc38) == 0) || (channel < 0)) || (1 < channel)) {
    ok = 0;
  }
  else {
    if (loop_start < loop_end) {
      alloc_sound_buffer_node(channel,samples,start,loop_start,1);
      alloc_sound_buffer_node(channel,samples,loop_start,loop_end,0);
      alloc_sound_buffer_node(channel,samples,loop_end,end,1);
    }
    else {
      alloc_sound_buffer_node(channel,samples,start,end,1);
      alloc_sound_buffer_node(channel,a5 + -0xc26,0,0x172,0);
    }
    select_two_channel_sound_handler(channel);
    ok = 1;
  }
  return ok;
}



/* VERIFIED (ID02::FUN_0000412e): ID02.bin 0x412e..0x41a4 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, restored on every exit; D7 = rate; TST.W A5-0xc38 / BNE else out; CMPI.L #$8000 BCC (unsigned)
 * else $8000; CMPI.L #$30000 BLS else $30000; A5-0xc2a = MULU.L #$172 LSR.L #16, A5-0xc2e = LSL.L #16, A5-0xc32 = LSR.L
 * #16 - identical to the C. */
/*
 * Original: FUN_0000412e; source: ID02.c:2299-2317.
 * Recovered name: set_sound_playback_rate [STRONG INFERENCE].
 * Overlay service slot A5-0x10d6 (JT $452).
 * Exported C complete. CurrentA5 routine; no effect while sound inactive.
 * param_1 = rate, 16.16 fixed point, clamped to [0x8000, 0x30000] (0.5x..3.0x).
 *   A5-0xc2a = rate * 370 >> 16   samples consumed per VBL refill
 *   A5-0xc2e = rate << 16         fractional step (low 16 bits of rate)
 *   A5-0xc32 = rate >> 16         integer step
 * These are the 32.32 step and length read by the VBL handlers. Unsigned
 * arithmetic; rate * 0x172 cannot overflow for the clamped range.
 */
void set_sound_playback_rate /* Original: FUN_0000412e */ (uint rate /* param_1: 16.16 playback rate, clamped to 0.5 .. 3.0 */)

{
  int a5; /* iVar1: copy of CurrentA5 */
  
  a5 = CurrentA5;
  if (*(short *)(CurrentA5 + -0xc38) != 0) {
    if (rate < 0x8000) {
      rate = 0x8000;
    }
    else if (0x30000 < rate) {
      rate = 0x30000;
    }
    *(uint *)(CurrentA5 + -0xc2a) = rate * 0x172 >> 0x10;
    *(uint *)(a5 + -0xc2e) = rate << 0x10;
    *(uint *)(a5 + -0xc32) = rate >> 0x10;
  }
  return;
}



/* VERIFIED (ID02::FUN_000041a6): ID02.bin 0x41a6..0x4240 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, restored on every exit; guards as 0x3f54; BSR 0x3d50(ch, A5-0xc26, 0, $172, word 0) to A4;
 * record +4 = A4+$14; A3 = record head, loop while A3 != A4: +$18 = +$14, A3 = +$14 - identical to the C. */
/*
 * Original: FUN_000041a6; source: ID02.c:2321-2340.
 * Recovered name: release_channel_loop [STRONG INFERENCE].
 * Overlay service slot A5-0x10ce (JT $44a).
 * Exported C complete. For ch 0..1 while sound active:
 *   n = alloc_sound_buffer_node(ch, silence A5-0xc26, 0, 0x172, 0) (self-looping
 *   silence); free head (+4) = n->next; for each node from the channel head
 *   (+0) along +0x14 until n: continuation (+0x18) = next (+0x14).
 * Breaks any self-looping (sustain) node so playback proceeds through the
 * remaining nodes into the new silence node [STRONG INFERENCE]. Resolves the
 * sustain-release question in docs/SOUND_SYSTEM.md. Ghidra's unaff_A3 is the
 * pushed word 0 (artifact; now written as 0).
 */
void release_channel_loop /* Original: FUN_000041a6 */ (int channel /* param_1 */)

{
  int a5; /* iVar1: copy of CurrentA5 */
  undefined4 *silence; /* puVar2: looping silence node appended */
  undefined4 *node; /* puVar3: walks the queue from the playing node */
  
  a5 = CurrentA5;
  if (((*(short *)(CurrentA5 + -0xc38) != 0) && (-1 < channel)) && (channel < 2)) {
    silence = alloc_sound_buffer_node(channel,CurrentA5 + -0xc26,0,0x172,0); /* flag CLR.W 0 */
    *(undefined4 *)(channel * 0x238 + a5 + -0x7cc) = silence[5];
    for (node = *(undefined4 **)(channel * 0x238 + a5 + -2000); node != silence;
        node = (undefined4 *)node[5]) {
      node[6] = node[5];
    }
  }
  return;
}



/* VERIFIED (ID02::FUN_00004242): ID02.bin 0x4242..0x42ae checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, restored on every exit; guards; BSR 0x3d50(ch, A5-0xc26, 0, $172, word 0); record head = result -
 * identical to the C. */
/*
 * Original: FUN_00004242; source: ID02.c:2343.
 * Recovered name: silence_sound_channel [STRONG INFERENCE].
 * Bytes file 0x4242..0x42ae match the C [PROVEN]: CurrentA5 thunk; if (sound
 * active word A5-0xc38 && 0 <= ch < 2) channel_record[ch] (0x238 bytes each at
 * A5-0x7d0) +0 = FUN_00003d50(ch, A5-0xc26, 0, 0x172, 0) - queues a 370-sample
 * buffer from A5-0xc26 (silence [HYPOTHESIS]). Ghidra's unaff_A4 argument is
 * the word 0 pushed by CLR.W (artifact; now written as 0). shutdown_sound also passes ch = 2,
 * which the bounds check ignores. Service slot A5-0x10ca (JT $432).
 */
void silence_sound_channel /* Original: FUN_00004242 */ (int channel /* param_1 */)

{
  int a5; /* iVar1: copy of CurrentA5 */
  undefined4 *silence; /* puVar2: looping silence node, made current */
  
  a5 = CurrentA5;
  if (((*(short *)(CurrentA5 + -0xc38) != 0) && (-1 < channel)) && (channel < 2)) {
    silence = alloc_sound_buffer_node(channel,CurrentA5 + -0xc26,0,0x172,0); /* flag CLR.W 0 */
    *(undefined4 **)(channel * 0x238 + a5 + -2000) = silence;
  }
  return;
}



/* VERIFIED (ID02::FUN_000042b0): ID02.bin 0x42b0..0x4316 checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904, restored on every exit; guards -> MOVEQ #0; LEA A5-0xc26 CMPA.L (head)+8, SNE / NEG.B / EXT.W to -2,
 * D0.W = -2 - identical to the C. */
/*
 * Original: FUN_000042b0; source: ID02.c:2360-2374.
 * Recovered name: is_channel_playing [STRONG INFERENCE].
 * Overlay service slot A5-0x10d2 (JT $43a).
 * Exported C complete. Returns 0 if sound inactive or ch outside 0..1;
 * else (word) current node's buffer (+8) != silence buffer A5-0xc26. The upper
 * word in Ghidra's CONCAT22 is register residue, not meaningful (the C now returns short).
 */
short is_channel_playing /* Original: FUN_000042b0 */ (int channel /* param_1 */)

{
  if (((*(short *)(CurrentA5 + -0xc38) == 0) || (channel < 0)) || (1 < channel)) {
    return 0;
  }
  return (short)(CurrentA5 + -0xc26 !=      /* SNE / NEG.B / EXT.W: only D0's low word is set */
                 *(int *)(*(int *)(channel * 0x238 + CurrentA5 + -2000) + 8));
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Globals starting with '_' overlap smaller symbols at the same address

/* VERIFIED (ID02::FUN_00004318): ID02.bin 0x4318..0x435c checked against an independent capstone disassembly.
 * TST.W A5-0xc38 / BEQ; BSR 0x4242 with 0, 1, 2; $196.w = A5-0xc36; BSR 0x3d36; SndDisposeChannel(A5-0x356, byte
 * 1) $A801 result popped; CLR.W A5-0xc38 - identical to the C. */
/*
 * Original: FUN_00004318; source: ID02.c:2381-2394.
 * Recovered name: shutdown_sound [STRONG INFERENCE].
 * Bytes file 0x4318..0x435c [PROVEN]: if (word A5-0xc38 sound active) {
 *   silence_sound_channel(0/1/2) (FUN_00004242) [service slot -0x10ca;
 *   per-channel stop, HYPOTHESIS]; long low-memory $0196 = A5-0xc36 (restore
 *   a saved value; Ghidra: _FUN_00000196); clear_sound_buffer_to_silence (FUN_00003d36);
 *   SndDisposeChannel(A5-0x356, true) ($A801; result discarded); A5-0xc38 = 0 }.
 * Callers: fatal_memory_error_exit, ID02.c:2537. Low-memory $0196 = Lvl1DT[1]
 * (VBL interrupt vector) restored to the pre-game handler.
 */
void shutdown_sound /* Original: FUN_00004318 */ (void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0xc38) != 0) {
    silence_sound_channel( /* Original: FUN_00004242 */ 0);
    silence_sound_channel( /* Original: FUN_00004242 */ 1);
    silence_sound_channel( /* Original: FUN_00004242 */ 2);
    *(undefined4 *)0x196 = *(undefined4 *)(unaff_A5 + -0xc36); /* restore Lvl1DT[1] */
    clear_sound_buffer_to_silence(); /* Original: FUN_00003d36 */
    SndDisposeChannel(*(int *)(unaff_A5 + -0x356),1); /* $A801, quietNow; result discarded */
    *(short *)(unaff_A5 + -0xc38) = 0;
  }
  return;
}



/* VERIFIED (ID02::FUN_0000435e): ID02.bin 0x435e..0x442c checked against an independent capstone disassembly.
 * w / h from +$16 - +$12 / +$14 - +$10; sw / sh from A5-0x167a / -0x167e / -0x167c / -0x1680; SUB.W $baa from sh;
 * CMP.W h / BGE; MoveWindow pushes w, (sw DIVS #2) - (w DIVS #2), (sh DIVS #2 or #3) - (h DIVS #2 or #3), byte 1 -
 * identical to the C. */
/* Original: FUN_0000435e; source: ID02.c. Recovered name: position_window_on_screen [PROVEN].
 * Decoded from ID02.bin bytes at file 0x435e.
 * Arg: WindowPtr w. Window size from portRect (+0x10..+0x16); screen size from screenBits.bounds (A5-0x1680..-0x167a) minus MBarHeight ($0BAA). Horizontally centred; vertically centred when the window is taller than the free height, otherwise placed one third down (screen / 3 - window / 3, each divided separately; no menu-bar offset is added to v); MoveWindow(w, h, v, true) ($A91B). Body rebuilt as C below. Callers: show_sound_error_dialog_once, show_creating_panel_dialog and others.
 */
// WARNING: Control flow encountered bad instruction data

void position_window_on_screen /* Original: FUN_0000435e */ (int win /* param_1: WindowPtr */)

{
  int unaff_A5;
  short w;                                      /* -2(A6) */
  short h;                                      /* -4(A6) */
  short sw;                                     /* -6(A6) */
  short sh;                                     /* -8(A6) */

  w = *(short *)(win + 0x16) - *(short *)(win + 0x12); /* portRect */
  h = *(short *)(win + 0x14) - *(short *)(win + 0x10);
  sw = *(short *)(unaff_A5 + -0x167a) - *(short *)(unaff_A5 + -0x167e);                                    /* screenBits.bounds */
  sh = *(short *)(unaff_A5 + -0x167c) - *(short *)(unaff_A5 + -0x1680);
  sh = sh - *(short *)0xbaa;                    /* MBarHeight */
  if (sh < h) {                                 /* centred (each term divided separately) */
    MoveWindow(win,(short)((int)sw / 2) - (short)((int)w / 2),(short)((int)sh / 2) - (short)((int)h / 2),1); /* $A91B */
  }
  else {                                        /* one third down */
    MoveWindow(win,(short)((int)sw / 2) - (short)((int)w / 2),(short)((int)sh / 3) - (short)((int)h / 3),1);
  }
  return;
}



/* VERIFIED (ID02::FUN_0000442e): ID02.bin 0x442e..0x4580 checked against an independent capstone disassembly.
 * GetResource('ALRT', word 8) to -$c; w / h from *h +6 - +2 / +4 - +0; sw / sh; (sh DIVS #3) CMP.W (h DIVS #2) / BGE;
 * SetRect(*h, left, top, right, bottom) $A8A7 with each term DIVS.W #2 (or sh DIVS #3) - identical to the C. */
/* Original: FUN_0000442e; source: ID02.c. Recovered name: position_alert_template [PROVEN].
 * Decoded from ID02.bin bytes at file 0x442e.
 * C arg +8 short ALRT id. GetResource('ALRT', id) ($A9A0); window size from the template boundsRect; screen size from screenBits.bounds (A5-0x1680..-0x167a). SetRect ($A8A7) of the template rect: centred horizontally; vertically centred on the one-third line (top = screen / 3 - height / 2) when the screen height / 3 is at least half the alert height, otherwise centred (corrected; body rebuilt as C below). So the next Alert / StopAlert / CautionAlert with that id appears centred on the current screen. Reached through JT $47a (e.g. ID04 confirm_end_mission, show_scenery_open_error_alert); direct caller ID02 0x1db4. Complete in the bytes 0x442e..0x4580.
 */
// WARNING: Control flow encountered bad instruction data

void position_alert_template /* Original: FUN_0000442e */ (short alrt_id /* param_1: ALRT resource id */)

{
  int unaff_A5;
  int **h_;                                     /* -$c(A6): ALRT handle */
  short w;                                      /* -2(A6) */
  short h;                                      /* -4(A6) */
  short sw;                                     /* -6(A6) */
  short sh;                                     /* -8(A6) */

  h_ = (int **)GetResource(0x414c5254,alrt_id); /* $A9A0, 'ALRT' */
  w = *(short *)((int)*h_ + 6) - *(short *)((int)*h_ + 2); /* boundsRect */
  h = *(short *)((int)*h_ + 4) - *(short *)*h_;
  sw = *(short *)(unaff_A5 + -0x167a) - *(short *)(unaff_A5 + -0x167e);
  sh = *(short *)(unaff_A5 + -0x167c) - *(short *)(unaff_A5 + -0x1680);
  if ((short)((int)sh / 3) < (short)((int)h / 2)) {                    /* centred */
    SetRect(*h_,(short)((int)sw / 2) - (short)((int)w / 2),(short)((int)sh / 2) - (short)((int)h / 2),
            (short)((int)sw / 2) + (short)((int)w / 2),(short)((int)sh / 2) + (short)((int)h / 2)); /* $A8A7 */
  }
  else {                                        /* centred on the one-third line */
    SetRect(*h_,(short)((int)sw / 2) - (short)((int)w / 2),(short)((int)sh / 3) - (short)((int)h / 2),
            (short)((int)sw / 2) + (short)((int)w / 2),(short)((int)sh / 3) + (short)((int)h / 2));
  }
  return;
}



/* VERIFIED (ID02::FUN_00004582): ID02.bin 0x4582..0x460e checked against an independent capstone disassembly.
 * w / h / sw / sh as 0x435e; MoveWindow(w, sw/2 - w/2, sh/2 - h/2 + $baa/2, true) - identical to the C. */
/* Original: FUN_00004582; source: ID02.c. Recovered name: centre_window_on_screen [PROVEN].
 * Decoded from ID02.bin bytes at file 0x4582.
 * Arg: WindowPtr w. MoveWindow(w, (screen width - window width) / 2, (screen height - window height) / 2 + MBarHeight / 2, true) ($A91B) using screenBits.bounds and MBarHeight ($0BAA); each term is divided separately. Body rebuilt as C below. Reached through JT $472 - called before ShowWindow by the ID04 dialogs (Mission Summary, Scenario Selection, Refuel, Map, Duty Roster, High Scores, About).
 */
// WARNING: Control flow encountered bad instruction data

void centre_window_on_screen /* Original: FUN_00004582 */ (int win /* param_1: WindowPtr */)

{
  int unaff_A5;
  short w;                                      /* -2(A6) */
  short h;                                      /* -4(A6) */
  short sw;                                     /* -6(A6) */
  short sh;                                     /* -8(A6) */

  w = *(short *)(win + 0x16) - *(short *)(win + 0x12);
  h = *(short *)(win + 0x14) - *(short *)(win + 0x10);
  sw = *(short *)(unaff_A5 + -0x167a) - *(short *)(unaff_A5 + -0x167e);
  sh = *(short *)(unaff_A5 + -0x167c) - *(short *)(unaff_A5 + -0x1680);
  MoveWindow(win,(short)((int)sw / 2) - (short)((int)w / 2),
             ((short)((int)sh / 2) - (short)((int)h / 2)) + (short)((int)*(short *)0xbaa / 2),1); /* $A91B */
  return;
}



/* VERIFIED (ID02::FUN_00004610): ID02.bin 0x4610..0x462a checked against an independent capstone disassembly.
 * TST.L A5-0x14ca / BEQ; SetPalette(window, CLR.L nil, CLR.W false) $AA95; CLR.W A5-0x2cc - identical to the C. */
/* Original: FUN_00004610; source: ID02.c. Recovered name: detach_window_palette [PROVEN].
 * Decoded from ID02.bin bytes at file 0x4610.
 * If the game window A5-0x14ca exists: SetPalette(window, NULL, false) ($AA95) and A5-0x2cc = 0 (no palette depth selected). Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void detach_window_palette /* Original: FUN_00004610 */ (void)

{
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x14ca) != 0) {
    SetPalette(*(int *)(unaff_A5 + -0x14ca),0,0); /* $AA95 */
    *(short *)(unaff_A5 + -0x2cc) = 0;
  }
  return;
}



/* VERIFIED (ID02::FUN_0000462c): ID02.bin 0x462c..0x46b2 checked against an independent capstone disassembly.
 * CMP.W depth A5-0x137a with A5-0x2cc / BEQ.W out; CLR.W A5-0x2cc; depth 4: SetPalette(A5-0x14ca, A5-0x14ae, CLR.W)
 * $AA95, A5-0x2cc = 4, A5-0x14a6 = LEA A5-0x320, A5-0x14a2 = 5; depth 8: palette A5-0x14aa, 8, A5-0x302, 9; depth 1:
 * A5-0x320, 5, A5-0x2cc = 1 - identical to the C. */
/* Original: FUN_0000462c; source: ID02.c. Recovered name: select_palette_for_depth [PROVEN].
 * Decoded from ID02.bin bytes at file 0x462c.
 * When the screen depth A5-0x137a differs from the palette depth A5-0x2cc: depth 4 -> SetPalette(window A5-0x14ca, palette A5-0x14ae, false), RGB table A5-0x14a6 = &A5-0x320, A5-0x14a2 = 5; depth 8 -> palette A5-0x14aa, table &A5-0x302, A5-0x14a2 = 9; depth 1 -> table &A5-0x320, A5-0x14a2 = 5 (no SetPalette); A5-0x2cc = depth. A5-0x14a6 is the RGB table that get_blended_fill_pattern reads for colour indices > 8 [PROVEN link]. Callers: layout_game_window_and_view (0x26f4, 0x2742), 0x4d24. Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void select_palette_for_depth /* Original: FUN_0000462c */ (void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) != *(short *)(unaff_A5 + -0x2cc)) {
    *(undefined2 *)(unaff_A5 + -0x2cc) = 0;
    if (*(short *)(unaff_A5 + -0x137a) == 4) {
      SetPalette(*(int *)(unaff_A5 + -0x14ca),*(int *)(unaff_A5 + -0x14ae),0); /* $AA95 */
      *(undefined2 *)(unaff_A5 + -0x2cc) = 4;
      *(int *)(unaff_A5 + -0x14a6) = unaff_A5 + -800;
      *(undefined2 *)(unaff_A5 + -0x14a2) = 5;
    }
    else if (*(short *)(unaff_A5 + -0x137a) == 8) {
      SetPalette(*(int *)(unaff_A5 + -0x14ca),*(int *)(unaff_A5 + -0x14aa),0);
      *(undefined2 *)(unaff_A5 + -0x2cc) = 8;
      *(int *)(unaff_A5 + -0x14a6) = unaff_A5 + -0x302;
      *(undefined2 *)(unaff_A5 + -0x14a2) = 9;
    }
    else if (*(short *)(unaff_A5 + -0x137a) == 1) {
      *(int *)(unaff_A5 + -0x14a6) = unaff_A5 + -800;
      *(undefined2 *)(unaff_A5 + -0x14a2) = 5;
      *(undefined2 *)(unaff_A5 + -0x2cc) = 1;
    }
  }
  return;
}



/* VERIFIED (ID02::FUN_000046b4): ID02.bin 0x46b4..0x4736 checked against an independent capstone disassembly.
 * CLR.W A5-0x102a; depth 1 -> BSR 0x4b62; else TST.W A5-0x2cc; TST.L A5-0x103a -> BSR 0xd24 + CLR.L; word slot 1..3
 * (MULS.W #$16 + A5-0x136e) TST.L -> push PEA -$204, record +4, PEA -4, word slot, BSR 0x48ae, LEA $e - identical to
 * the C. */
/*
 * Original: FUN_000046b4; source: ID02.c:2484-2506.
 * Recovered name: rebuild_all_palette_index_maps [STRONG INFERENCE].
 * Bytes file 0x46b4..0x4736 match the C [PROVEN]: clears collision flag
 * A5-0x102a; B&W (A5-0x137a == 1) -> FUN_00004b62; else if depth word
 * A5-0x2cc != 0: if long A5-0x103a, close_and_dispose_port(A5-0x103a) and clear it;
 * for slot 1..3 used: build_palette_index_map(slot, &local -4(A6), slot.stored (+4),
 * scratch -$204(A6)). Ghidra's CONCAT22 call lost the last three arguments (restored below).
 * Called from the stub at file 0x4d24 (with 0x462c and callback A5-0x10a2).
 */
void rebuild_all_palette_index_maps /* Original: FUN_000046b4 */ (void)

{
  int unaff_A5;
  undefined1 scratch[0x200];                    /* -$204(A6) */
  int start;                                    /* -4(A6) */
  short slot; /* local_6: display device slot 1..3 (0x16-byte records at A5-0x136e) */                                /* -2(A6) */
  
  *(undefined2 *)(unaff_A5 + -0x102a) = 0;
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    FUN_00004b62();                             /* init_standard_colour_indices (not decompiled) */
  }
  else if (*(short *)(unaff_A5 + -0x2cc) != 0) {
    if (*(int *)(unaff_A5 + -0x103a) != 0) {
      close_and_dispose_port(*(int *)(unaff_A5 + -0x103a)); /* Original: FUN_00000d24 */
      *(undefined4 *)(unaff_A5 + -0x103a) = 0;
    }
    for (slot = 1; slot < 4; slot = slot + 1) {
      if (*(int *)(slot * 0x16 + unaff_A5 + -0x136e) != 0) {
        build_palette_index_map(slot,&start,*(int *)(slot * 0x16 + unaff_A5 + -0x136e + 4),scratch);
                                                /* BSR 0x48ae: word slot, &-4, record +4, &-$204 */
      }
    }
  }
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000047c6)
// WARNING: Removing unreachable block (ram,0x0000478a)
// WARNING: Removing unreachable block (ram,0x00004790)
// WARNING: Removing unreachable block (ram,0x0000481c)
// WARNING: Removing unreachable block (ram,0x00004822)
// WARNING: Removing unreachable block (ram,0x00004864)
// WARNING: Removing unreachable block (ram,0x0000486a)

/* VERIFIED (ID02::FUN_00004738): ID02.bin 0x4738..0x4888 checked against an independent capstone disassembly.
 * CMPI.W #4 / #8 on word 8(A6); loops on word -2: SetEntryUsage(pal, e (+8 / +$d0 / +$c8 / +0), usage, tolerance)
 * $AA9E and SetEntryColor(pal, e, PEA table + MULS.W #6) $AA9C with tables A5-0x320 / -0x350 / -0x302 / -0x350,
 * counts 5 / 8 / 9 / 8 / $c8 - identical to the C. */
/*
 * Original: FUN_00004738; source: ID02.c:2520-2532.
 * Recovered name: configure_palette_entries [STRONG INFERENCE].
 * Bytes file 0x4738..0x4888 [PROVEN; Palette Manager traps per Inside Macintosh]:
 *   depth (word param) == 4, palette A5-0x14ae:
 *     entries 8..12: SetEntryUsage(pal, e, 2 pmTolerant, 0) $AA9E;
 *                    SetEntryColor(pal, e, &rgb A5-0x320[e-8]) $AA9C
 *     entries 0..7: SetEntryUsage(pal, e, 0 pmCourteous, 0x1000);
 *                    SetEntryColor(pal, e, &rgb A5-0x350[e])
 *   depth == 8, palette A5-0x14aa:
 *     entries 0xd0..0xd8: tolerant, colours A5-0x302;
 *     entries 0xc8..0xcf: tolerant, colours A5-0x350;
 *     entries 0..0xc7: SetEntryUsage(pal, e, 4 pmAnimated, 0)
 *   RGBColor entries are 6 bytes. Callers: layout_game_window_and_view (4, 8). Body rebuilt as C below.
 */
void configure_palette_entries /* Original: FUN_00004738 */ (short depth /* param_1: pixel depth, 4 or 8 */)

{
  int unaff_A5;
  short e;                                      /* -2(A6) */

  if (depth == 4) {
    for (e = 0; e < 5; e = e + 1) {
      SetEntryUsage(*(int *)(unaff_A5 + -0x14ae),e + 8,2,0);            /* $AA9E, pmTolerant */
      SetEntryColor(*(int *)(unaff_A5 + -0x14ae),e + 8,(void *)(unaff_A5 + -0x320 + e * 6)); /* $AA9C */
    }
    for (e = 0; e < 8; e = e + 1) {
      SetEntryUsage(*(int *)(unaff_A5 + -0x14ae),e,0,0x1000);           /* pmCourteous */
      SetEntryColor(*(int *)(unaff_A5 + -0x14ae),e,(void *)(unaff_A5 + -0x350 + e * 6));
    }
  }
  else if (depth == 8) {
    for (e = 0; e < 9; e = e + 1) {
      SetEntryUsage(*(int *)(unaff_A5 + -0x14aa),e + 0xd0,2,0);
      SetEntryColor(*(int *)(unaff_A5 + -0x14aa),e + 0xd0,(void *)(unaff_A5 + -0x302 + e * 6));
    }
    for (e = 0; e < 8; e = e + 1) {
      SetEntryUsage(*(int *)(unaff_A5 + -0x14aa),e + 0xc8,2,0);
      SetEntryColor(*(int *)(unaff_A5 + -0x14aa),e + 0xc8,(void *)(unaff_A5 + -0x350 + e * 6));
    }
    for (e = 0; e < 200; e = e + 1) {
      SetEntryUsage(*(int *)(unaff_A5 + -0x14aa),e,4,0);                /* pmAnimated */
    }
  }
  return;
}



/* VERIFIED (ID02::FUN_0000488a): ID02.bin 0x488a..0x48ac checked against an independent capstone disassembly.
 * A5 / D2 saved, A5 = $904; CLR.W +6 of long A5-0x14b2; restored - identical to the C. */
/*
 * Original: FUN_0000488a; source: ID02.c:2536-2545.
 * Recovered name: clear_ctab_size_callback [STRONG INFERENCE].
 * Bytes file 0x488a..0x48ac [PROVEN]: saves A5/D2, loads A5 from low-memory
 * CurrentA5 ($0904) - i.e. callable from a context where A5 is not the
 * application's -, clears word +6 of the record at long A5-0x14b2 (the
 * NewPtrClear colour-table block from initialize_application; +6 = ctSize
 * [HYPOTHESIS]), restores A5/D2. Installed as function pointer A5-0x1122 via
 * JT A5+0x46a by build_palette_index_map when palette indices collide.
 *: it is the 'discard' alternative to apply_pending_color_entries_a5safe
 * (FUN_00000c68, SetEntries) normally installed in that slot.
 */
void clear_ctab_size_callback /* Original: FUN_0000488a */ (void)

{
  *(undefined2 *)(*(int *)(CurrentA5 + -0x14b2) + 6) = 0;
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_000048ae): ID02.bin 0x48ae..0x49fc checked against an independent capstone disassembly.
 * slot record TST.L / BNE else MOVEQ #0; FrontWindow CMPA.L A5-0x14ca SEQ to -8; GetGDevice to -$20c; SetGDevice(record);
 * word i 0..$ff clearing -$208[i] then $12[i]; depth $d / $d9 with i = 0; MOVE.W i to *$a; loop i < limit (BLT):
 * PmForeColor(i) $AA97, idx = thePort+$52, $e[i] = idx, $12[idx] = i, TST.W count[idx] && depth == 8 && i < $c8 ->
 * A5-0x102a = 1, ADDQ count[idx]; SetGDevice(saved); A5-0x1122 = $46a / $33a(A5); D0 = limit - identical to the C. */
/*
 * Original: FUN_000048ae; source: ID02.c:2547.
 * Recovered name: build_palette_index_map [STRONG INFERENCE].
 * Ghidra truncated after the empty-slot test; body rebuilt as C below. Bytes file
 * 0x48ae..0x49fc [PROVEN]. Args: word slot [8], short *start [$a],
 * short *map [$e], short *inverse [$12]; returns word limit.
 *   if (!device_table[slot].handle (A5-0x136e + 0x16*slot)) return 0;
 *   front_is_main = (FrontWindow $A924 == main_window)  [stored, unused here]
 *   saved = GetGDevice $AA32; SetGDevice(slot handle) $AA31;
 *   clear count[256] (local -$208) and inverse[256];
 *   depth word A5-0x2cc: 4 -> limit 13, 8 -> limit 217 (0xd9), i = 0; *start = i;
 *     [other depths: i stays 256 from the clear loop and limit -6(A6) is uninitialised]
 *   for (i = 0; i < limit; i++) {
 *     PmForeColor(i) $AA97;  idx = low word of thePort->fgColor (+0x52;
 *     thePort pointer at A5-0x160c);
 *     map[i] = idx; inverse[idx] = i;
 *     if (count[idx] && depth == 8 && i < 200) word A5-0x102a = 1;  collision
 *     count[idx]++;
 *   }
 *   SetGDevice(saved);
 *   long A5-0x1122 = A5-0x102a ? A5+0x46a (JT -> ID02 file 0x488a)
 *: A5+0x33a (JT -> ID02 file 0xc68);
 *   return limit.
 * Interpretation [STRONG INFERENCE]: maps palette entries to actual device
 * pixel values (and back); a collision selects an alternate routine via the
 * function pointer A5-0x1122. Traps per Inside Macintosh (Palette Manager).
 * Callers: check_device_color_state_changed (2x), FUN_000046b4.
 */
short build_palette_index_map /* Original: FUN_000048ae */ (short slot /* param_1: display device slot */,short *start /* param_2: out, first index found (0, or 256) */,short *map /* param_3: out, colour level -> palette index */,short *inverse /* param_4: out, palette index -> colour level */)

{
  int unaff_A5;
  int saved;                                    /* -$20c(A6) */
  short count[256];                             /* -$208(A6) */
  short front_is_main;                          /* -8(A6): stored, never read */
  short limit;                                  /* -6(A6): unset for depths other than 4 / 8 */
  short i;                                      /* -4(A6) */
  short idx;                                    /* -2(A6) */

  if (*(int *)(slot * 0x16 + unaff_A5 + -0x136e) == 0) {
    return 0;
  }
  front_is_main = FrontWindow() == *(int *)(unaff_A5 + -0x14ca); /* $A924 */
  saved = GetGDevice();                         /* $AA32 */
  SetGDevice(*(int *)(slot * 0x16 + unaff_A5 + -0x136e)); /* $AA31 */
  for (i = 0; i < 0x100; i = i + 1) {
    count[i] = 0;
    inverse[i] = 0;
  }
  if (*(short *)(unaff_A5 + -0x2cc) == 4) {
    limit = 0xd;
    i = 0;
  }
  else if (*(short *)(unaff_A5 + -0x2cc) == 8) {
    limit = 0xd9;
    i = 0;
  }
  *start = i;                                 /* 0, or 256 left over from the clear loop */
  for (; i < limit; i = i + 1) {
    PmForeColor(i);                             /* $AA97 */
    idx = *(short *)(*(int *)(unaff_A5 + -0x160c) + 0x52); /* low word of thePort->fgColor */
    map[i] = idx;
    inverse[idx] = i;
    if (((count[idx] != 0) && (*(short *)(unaff_A5 + -0x2cc) == 8)) && (i < 200)) {
      *(short *)(unaff_A5 + -0x102a) = 1;       /* collision */
    }
    count[idx] = count[idx] + 1;
  }
  SetGDevice(saved);
  if (*(short *)(unaff_A5 + -0x102a) == 0) {
    *(int *)(unaff_A5 + -0x1122) = unaff_A5 + 0x33a; /* JT -> 0xc68 apply_pending_color_entries_a5safe */
  }
  else {
    *(int *)(unaff_A5 + -0x1122) = unaff_A5 + 0x46a; /* JT -> 0x488a clear_ctab_size_callback */
  }
  return limit;
}



/* VERIFIED (ID02::FUN_000049fe): ID02.bin 0x49fe..0x4b60 checked against an independent capstone disassembly.
 * Each word arg LSL.W #6, $100 -> $ff, then LSL.W #8 (stored back); -4 = -1; search 1: word i 0..7 over A5-0x350 +
 * MULS.W #6 comparing +0 / +2 / +4 (BNE next), match -> -4 = i; CMPI.W #-1: search 2 over *(A5-0x14a6) for i <
 * A5-0x14a2, match -> -4 = i + 8; result: depth 4 or 1 -> D0.W = -4, depth 8 -> -4 + $c8, else D0 left as is (the
 * last component compared, i + 8, or the final i - Ghidra's CONCAT22 chain tracks exactly that low word; the high
 * words are register residue) - identical to the C. */
/*
 * Original: FUN_000049fe; source: ID02.c:2561-2632.
 * Recovered name: lookup_palette_index_for_rgb_level [STRONG INFERENCE].
 * Exported C kept verbatim; the whole body (0x49fe..0x4b60) agrees with the bytes. Args: three words r, g, b at 8/$a/$c(A6) (Ghidra packs
 * them as param_1 hi/lo and param_2 hi).
 * Each level is scaled: v = level << 6, 0x100 clamped to 0xff, then << 8
 * (16-bit RGB component; levels 0..4 -> 0x0000, 0x4000, 0x8000, 0xc000, 0xff00).
 * Search 1: 8 RGBColor entries at A5-0x350 (6 bytes each) -> index 0..7.
 * Search 2: table *(long A5-0x14a6), count word A5-0x14a2 -> index 8 + n.
 * Not found: -1. Result by mode word A5-0x137a: 1 or 4 -> index;
 * 8 -> index + 200 (the 0xc8+ palette entries set by configure_palette_entries);
 * other modes return the leftover register value (preserved, UNKNOWN).
 * Callers: FUN_00004b62 (9 calls; not decompiled by Ghidra, see note below it).
 */
undefined4 lookup_palette_index_for_rgb_level /* Original: FUN_000049fe */ (undefined4 rg /* param_1: red level in ._0_2_, green level in ._2_2_ (0..4) */,undefined4 b_word /* param_2: blue level in ._0_2_ */)

{
  short comp; /* sVar1: colour component being compared */
  short *entry; /* psVar2: extended table entry (6 bytes) */
  int entry_addr; /* iVar3 */
  undefined2 d0_hi; /* uVar4: high word of D0 (left over) */
  short b; /* sVar6: blue component (level << 6, 0x100 -> 0xff) */
  undefined4 result; /* uVar5: D0 */
  int unaff_A5;
  undefined2 index; /* local_8: index found, -1 = none */
  undefined2 i; /* local_6 */
  
  b = rg._0_2_ << 6;
  rg._0_2_ = b;
  if (b == 0x100) {
    rg._0_2_ = 0xff;
  }
  rg._2_2_ = rg._2_2_ << 6;
  if (rg._2_2_ == 0x100) {
    rg._2_2_ = 0xff;
  }
  b = b_word._0_2_ << 6;
  if (b == 0x100) {
    b = 0xff;
  }
  result = 0xffffffff;
  index = -1;
  for (i = 0; i < 8; i = i + 1) {
    comp = *(short *)(i * 6 + unaff_A5 + -0x350);
    result = CONCAT22((short)((uint)(i * 6) >> 0x10),comp);
    if (((comp == (short)(rg._0_2_ << 8)) &&
        (comp = *(short *)(i * 6 + unaff_A5 + -0x34e),
        result = CONCAT22((short)((uint)(i * 6) >> 0x10),comp),
        comp == (short)(rg._2_2_ << 8))) &&
       (comp = *(short *)(i * 6 + unaff_A5 + -0x34c),
       result = CONCAT22((short)((uint)(i * 6) >> 0x10),comp), comp == (short)(b << 8)))
    {
      index = i;
      break;
    }
  }
  if (index == -1) {
    for (i = 0; result = CONCAT22((short)((uint)result >> 0x10),i),
        i < *(short *)(unaff_A5 + -0x14a2); i = i + 1) {
      entry = (short *)(*(int *)(unaff_A5 + -0x14a6) + i * 6);
      comp = *entry;
      result = CONCAT22((short)((uint)entry >> 0x10),comp);
      if ((comp == (short)(rg._0_2_ << 8)) &&
         (entry_addr = *(int *)(unaff_A5 + -0x14a6) + i * 6, comp = *(short *)(entry_addr + 2),
         result = CONCAT22((short)((uint)entry_addr >> 0x10),comp), comp == (short)(rg._2_2_ << 8))
         ) {
        entry_addr = *(int *)(unaff_A5 + -0x14a6) + i * 6;
        comp = *(short *)(entry_addr + 4);
        d0_hi = (undefined2)((uint)entry_addr >> 0x10);
        result = CONCAT22(d0_hi,comp);
        if (comp == (short)(b << 8)) {
          index = i + 8;
          result = CONCAT22(d0_hi,index);
          break;
        }
      }
    }
  }
  d0_hi = (undefined2)((uint)result >> 0x10);
  if ((*(short *)(unaff_A5 + -0x137a) == 4) || (*(short *)(unaff_A5 + -0x137a) == 1)) {
    result = CONCAT22(d0_hi,index);
  }
  else if (*(short *)(unaff_A5 + -0x137a) == 8) {
    result = CONCAT22(d0_hi,index + 200);
  }
  return result;
}


/*
 * Original: FUN_00004b62; source: ID02.c.
 * Recovered name: init_standard_colour_indices [STRONG INFERENCE].
 * Ghidra did not decompile this entry. Bytes file 0x4b62..0x4c16 [PROVEN]: nine calls
 * lookup_palette_index_for_rgb_level(l, l, l) storing the word result:
 *   (3,3,3) -> A5-0x11ae   (0,0,0) -> A5-0x11ac   (0,0,0) -> A5-0x118c
 *   (3,3,3) -> A5-0x1188   (2,2,2) -> A5-0x118a   (3,3,3) -> A5-0x117c
 *   (0,0,0) -> A5-0x117e   (3,3,3) -> A5-0x11fa   (1,1,1) -> A5-0x11f8
 * i.e. grey levels 0xc000 / black / 0x8000 / 0x4000 resolved to palette indices
 * for UI drawing. Callers: rebuild_all_palette_index_maps and
 * check_device_color_state_changed (B&W / mode-1 path).
 */
/* VERIFIED (ID02::FUN_00004b62): ID02.bin 0x4b62..0x4c16 checked against an independent capstone disassembly:
 * each group pushes three identical word levels, BSR 0x49fe, drops six argument bytes and stores D0.W at the
 * stated A5 offset; the nine level/destination pairs are 3/ee52, 0/ee54, 0/ee74, 3/ee78, 2/ee76,
 * 3/ee84, 0/ee82, 3/ee06 and 1/ee08, followed by RTS - identical to the C reconstructed below. */
void init_standard_colour_indices /* Original: FUN_00004b62 */ (void)

{
  int unaff_A5;

  /* lookup's Ghidra prototype packs the three physical word arguments as
     {r,g} and {b,padding}; CONCAT22 preserves that big-endian stack view. */
  *(undefined2 *)(unaff_A5 + -0x11ae) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(3,3),CONCAT22(3,0));
  *(undefined2 *)(unaff_A5 + -0x11ac) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(0,0),CONCAT22(0,0));
  *(undefined2 *)(unaff_A5 + -0x118c) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(0,0),CONCAT22(0,0));
  *(undefined2 *)(unaff_A5 + -0x1188) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(3,3),CONCAT22(3,0));
  *(undefined2 *)(unaff_A5 + -0x118a) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(2,2),CONCAT22(2,0));
  *(undefined2 *)(unaff_A5 + -0x117c) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(3,3),CONCAT22(3,0));
  *(undefined2 *)(unaff_A5 + -0x117e) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(0,0),CONCAT22(0,0));
  *(undefined2 *)(unaff_A5 + -0x11fa) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(3,3),CONCAT22(3,0));
  *(undefined2 *)(unaff_A5 + -0x11f8) = (undefined2)lookup_palette_index_for_rgb_level(CONCAT22(1,1),CONCAT22(1,0));
  return;
}


/* VERIFIED (ID02::FUN_00004c18): ID02.bin 0x4c18..0x4d22 checked against an independent capstone disassembly.
 * CLR.W -$a and A5-0x102a; depth 1 -> BSR 0x4b62; else word slot 1..3 (MULS.W #$16 + A5-0x136e, TST.L): BSR 0x48ae(slot,
 * -4, -$20a, -$40a) to -6; CLR.W -8; loop start (-4) < count: CMP.W fresh[i] with stored (record +4)[i], difference ->
 * -$a = -8 = 1 and break; TST.W -8: slot 1 -> JT $182(A5-0x1354, -$20a) (ID03 0x6c1c remap_cached_panel_colours), BSR
 * 0x48ae(slot, -4, record +4, -$40a); after the loop TST.W -$a && TST.L A5-0x1006 -> JSR (A5-0x1096) - identical to
 * the C. */
/*
 * Original: FUN_00004c18; source: ID02.c:2643-2688.
 * Recovered name: check_device_color_state_changed [STRONG INFERENCE on
 * structure / HYPOTHESIS on purpose].
 * Exported C matches bytes file 0x4c18..0x4d22 [PROVEN] once the build_palette_index_map
 * arguments Ghidra dropped are restored (fresh map -$20a / stored record +4, scratch -$40a).
 * - Clears word A5-0x102a and local "changed" flag (local_e).
 * - If word A5-0x137a == 1: FUN_00004b62 only (likely 1-bit / B&W path).
 * - Else for slot i = 1..3 of the 0x16-byte table at A5-0x136e (+0 long
 *   = device handle, +4 long = stored word array):
 *     if slot used: count = build_palette_index_map(i, &start, fresh, scratch);
 *       compare fresh[start..count) with stored; on first difference mark
 *       changed; then if i == 1 call JT $182 (seg 3 file 0x6c1c)
 *       (A5-0x1354, fresh), and build_palette_index_map(i, &start, stored, scratch)
 *       refreshes the stored copy.
 * - If anything changed and the overlay is loaded (A5-0x1006): call the
 *   overlay callback A5-0x1096 (same slot as in apply_settings_to_live_options).
 * build_palette_index_map (FUN_000048ae; see its header): returns 0 for an empty slot; otherwise
 * FrontWindow == main_window flag, saves GetGDevice ($AA32), SetGDevice
 * ($AA31) to the slot handle, clears two 256-word buffers, picks start
 * limit 0x0d / 0xd9 when word A5-0x2cc == 4 / 8 (fully decoded at its own entry).
 * [HYPOTHESIS] Detects palette / colour-table changes on up to three
 * screens (e.g. after a desk accessory) and lets the overlay re-sync colours.
 * Caller: redraw_main_window (BSR at file 0x4df0).
 */
void check_device_color_state_changed /* Original: FUN_00004c18 */ (void)

{
  undefined4 count; /* uVar1: build_palette_index_map result (entries in the map) */
  int unaff_A5;
  short inverse [256]; /* asStack_40e */                      /* -$40a(A6): scratch (inverse map) */
  short fresh_map [256]; /* asStack_20e */                      /* -$20a(A6): fresh map */
  short any_changed; /* local_e: some device map changed */
  short changed; /* local_c: this device's map changed */
  short n_entries; /* local_a: stored, never read */
  short i; /* local_8: start index from build_palette_index_map, then the compare cursor */
  short slot; /* local_6: display device slot 1..3 */
  
  any_changed = 0;
  *(undefined2 *)(unaff_A5 + -0x102a) = 0;
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    FUN_00004b62();
  }
  else {
    for (slot = 1; slot < 4; slot = slot + 1) {
      if (*(int *)(slot * 0x16 + unaff_A5 + -0x136e) != 0) {
        count = build_palette_index_map(slot,&i,fresh_map,inverse); /* BSR 0x48ae */
        n_entries = (short)count;
        changed = 0;
        for (; i < (short)count; i = i + 1) {
          if (fresh_map[i] !=
              *(short *)(*(int *)(slot * 0x16 + unaff_A5 + -0x136a) + i * 2)) {
            any_changed = 1;
            changed = 1;
            break;
          }
        }
        if (changed != 0) {
          if (slot == 1) {
            remap_cached_panel_colours(*(undefined4 *)(unaff_A5 + -0x1354),fresh_map); /* JT $182 -> ID03 0x6c1c */
          }
          build_palette_index_map(slot,&i,*(short **)(slot * 0x16 + unaff_A5 + -0x136a),inverse);
                                                /* refresh the stored map (record +4) */
        }
      }
    }
    if ((any_changed != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) {
      (**(code **)(unaff_A5 + -0x1096))();
    }
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00004d34): ID02.bin 0x4d34..0x4d68 checked against an independent capstone disassembly.
 * BRA to GetNextEvent($40, -$10) $A970 TST.B / BNE; CMP.L -$e with A5-0x14ca / BNE exit; BeginUpdate, BSR 0x4db0,
 * EndUpdate, loop - identical to the C. */
/*
 * Original: FUN_00004d34; source: ID02.c:2693.
 * Recovered name: process_pending_update_events [STRONG INFERENCE].
 * Ghidra truncated (body rebuilt as C below). Bytes 0x4d34..0x4d68 [PROVEN]:
 *   while (GetNextEvent(0x40 updateMask, &evt) $A970 &&
 *          evt.message == main_window (A5-0x14ca)) {
 *     BeginUpdate(main_window) $A922; redraw_main_window; EndUpdate $A923 }
 * Stops at the first update for another window or when none is pending.
 * Caller [PROVEN]: ID04 file 0x438 (panel-store failure report) via JT $462.
 */
void process_pending_update_events /* Original: FUN_00004d34 */ (void)

{
  int unaff_A5;
  short evt[8];                                 /* -$10(A6): what, message -$e */

  while ((GetNextEvent(0x40,evt) != '\0') &&   /* $A970, updateMask */
         (*(int *)(evt + 1) == *(int *)(unaff_A5 + -0x14ca))) {
    BeginUpdate(*(int *)(unaff_A5 + -0x14ca)); /* $A922 */
    redraw_main_window();                       /* BSR 0x4db0 */
    EndUpdate(*(int *)(unaff_A5 + -0x14ca));   /* $A923 */
  }
  return;
}



/* VERIFIED (ID02::FUN_00004d6a): ID02.bin 0x4d6a..0x4d94 checked against an independent capstone disassembly.
 * TST.W A5-0x14c6; CMP.L (evt)+2 with A5-0x14ca; BeginUpdate $A922, BSR 0x4db0, EndUpdate $A923 - identical to the
 * C. */
/* Original: FUN_00004d6a; source: ID02.c. Recovered name: handle_update_event [PROVEN].
 * Decoded from ID02.bin bytes at file 0x4d6a.
 * Arg: EventRecord *. When the game window is enabled (A5-0x14c6) and event->message (+2) is that window (A5-0x14ca): BeginUpdate ($A922), redraw_main_window (0x4db0), EndUpdate ($A923). Reached through JT $492 (the updateEvt branch of the ID04 dialog filters). Body rebuilt as C below. The following bytes 0x4d96..0x4dae (not exported) are restore_screen_globals: SetGDevice(A5-0x1036) ($AA31) and copies the screen base / rowBytes / depth A5-0x1346 / -0x134a / -0x1348 into A5-0x1382 / -0x1378 / -0x1312 [PROVEN].
 */
// WARNING: Control flow encountered bad instruction data

void handle_update_event /* Original: FUN_00004d6a */ (int evt /* param_1: EventRecord (message +2 = the window) */)

{
  int unaff_A5;
  
  if ((*(short *)(unaff_A5 + -0x14c6) != 0) &&
     (*(int *)(evt + 2) == *(int *)(unaff_A5 + -0x14ca))) {
    BeginUpdate(*(int *)(unaff_A5 + -0x14ca)); /* $A922 */
    redraw_main_window();                       /* BSR 0x4db0 */
    EndUpdate(*(int *)(unaff_A5 + -0x14ca));   /* $A923 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID02::FUN_00004db0): ID02.bin 0x4db0..0x4e18 checked against an independent capstone disassembly.
 * -4 = A5-0x12d4 && A5-0x1032 (dead); TST A5-0x14c6, A5-0x1006, A5-0x12f8; A5-0x12ea == 0 -> A5-0x103c = it,
 * A5-0x12ea = 1; HideCursor $A852; BSR 0x4c18; UnloadSeg($18a(A5)); JSR (A5-0x109e); BSR 0x4d96; push 1 then 0, BSR
 * 0x930; BSR 0xa26; ShowCursor $A853 - identical to the C. */
/*
 * Original: FUN_00004db0; source: ID02.c:2721-2736 (last function of ID02;
 * segment ends at file 0x4e1a).
 * Recovered name: redraw_main_window [STRONG INFERENCE].
 * Ghidra truncated after the -0x12ea fix-up at A-line $A852; body rebuilt as C below. Bytes file 0x4db0..0x4e18 [PROVEN]:
 *   tmp = (word A5-0x12d4 && word A5-0x1032) -> -4(A6)  [stored, never read;
 *         Ghidra correctly dropped it as dead]
 *   if (A5-0x14c6 redraw enabled && A5-0x1006 overlay loaded && word A5-0x12f8) {
 *     if (live option A5-0x12ea == 0) { A5-0x103c = 0; A5-0x12ea = 1; }
 *     HideCursor $A852;
 *     BSR 0x4c18 (check_device_color_state_changed, FUN_00004c18);
 *     UnloadSeg(JT $18a = segment 3 entry) $A9F1;
 *     (*(code **)(A5-0x109e));      overlay-side callback [UNKNOWN target]
 *     BSR 0x4d96 [not a Ghidra function]; FUN_00000930(0, 1) (BSR 0x930);
 *     BSR 0xa26 [not a Ghidra function]; ShowCursor $A853;
 *   }
 * Callers: poll_and_dispatch_event (updateEvt, between Begin/EndUpdate),
 * apply_settings_to_live_options (after an option-change callback).
 * [HYPOTHESIS] Renders the game view into the main window through the overlay.
 */
void redraw_main_window /* Original: FUN_00004db0 */ (void)

{
  int unaff_A5;
  short unused_4;                               /* -4(A6): stored, never read */
  
  unused_4 = (*(short *)(unaff_A5 + -0x12d4) != 0) && (*(short *)(unaff_A5 + -0x1032) != 0);
  if (((*(short *)(unaff_A5 + -0x14c6) != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) &&
     (*(short *)(unaff_A5 + -0x12f8) != 0)) {
    if (*(short *)(unaff_A5 + -0x12ea) == 0) {
      *(undefined2 *)(unaff_A5 + -0x103c) = *(undefined2 *)(unaff_A5 + -0x12ea);
      *(undefined2 *)(unaff_A5 + -0x12ea) = 1;
    }
    HideCursor();                               /* $A852 */
    check_device_color_state_changed();         /* BSR 0x4c18 */
    UnloadSeg((void *)(unaff_A5 + 0x18a));      /* $A9F1: segment 3 */
    (**(code **)(unaff_A5 + -0x109e))();        /* overlay callback */
    FUN_00004d96();                             /* BSR 0x4d96: restore_screen_globals (no inventory entry) */
    call_overlay_session_hooks(0,1);            /* BSR 0x930 */
    FUN_00000a26();                             /* BSR 0xa26 (no inventory entry) */
    ShowCursor();                               /* $A853 */
  }
  return;
}

