typedef unsigned char   undefined;

typedef unsigned int    uint;
typedef unsigned long long    ulonglong;
typedef unsigned int    undefined4;
typedef unsigned long long    undefined8;
typedef unsigned char    byte;



/* Original: FUN_00000110; source: ID01.c. Recovered name: rt_udiv32 [PROVEN].
 * Decoded from ID01.bin bytes at file 0x110.
 * Stack-argument entry (dividend at 4(A7), divisor at 8(A7) on entry; the code shuffles the return address so the caller sees D1 preserved) that saves D2-D3/D7 and calls rt_udivmod32_core (0x1c2); returns the unsigned quotient in D0 [PROVEN, bytes 0x110..0x12e].
 */
/* VERIFIED (ID01::FUN_00000110): ID01.bin 0x110..0x12e checked against an independent capstone disassembly:
 * Register model [PROVEN, bytes]: the stack entries take the dividend at 4(A7) and the divisor at 8(A7),
 * save the caller's D1 in the first argument slot and move the return address over the second, so
 * the routine pops both arguments itself (callers must not) and D1 is preserved; the cores take
 * D0 = dividend, D1 = divisor and leave D0 = quotient, D1 = remainder, modelled here as the ulonglong
 * (quotient << 32) | remainder. A zero divisor reaches a DIVU.W by zero (zero-divide exception).
 * MOVE.L D1,4(A7) / MOVE.L (A7)+,4(A7), MOVEM D2-D3/D7, JSR 0x1c2, D0 = quotient - identical to the C
 * (reconstructed from the bytes; Ghidra's (void) form dropped the arguments). */
uint rt_udiv32 /* Original: FUN_00000110 */ (uint dividend,uint divisor)

{
  return (uint)(rt_udivmod32_core(dividend,divisor) >> 0x20); /* JSR 0x1c2; D0 = quotient */
}



/* Original: FUN_00000130; source: ID01.c. Recovered name: rt_umod32 [PROVEN].
 * Decoded from ID01.bin bytes at file 0x130.
 * Stack-argument entry (dividend at 4(A7), divisor at 8(A7) on entry; the code shuffles the return address so the caller sees D1 preserved) that saves D2-D3/D7 and calls rt_udivmod32_core (0x1c2); returns the unsigned remainder (MOVE.L D1,D0) in D0 [PROVEN, bytes 0x130..0x150].
 */
/* VERIFIED (ID01::FUN_00000130): ID01.bin 0x130..0x150 checked against an independent capstone disassembly:
 * same stack entry as rt_udiv32, then MOVE.L D1,D0 (remainder) - identical to the C (reconstructed
 * from the bytes; see the register model at rt_udiv32). */
uint rt_umod32 /* Original: FUN_00000130 */ (uint dividend,uint divisor)

{
  return (uint)rt_udivmod32_core(dividend,divisor); /* JSR 0x1c2; MOVE.L D1,D0 = remainder */
}



/* Original: FUN_00000152; source: ID01.c. Recovered name: rt_sdiv32 [PROVEN].
 * Decoded from ID01.bin bytes at file 0x152.
 * Stack-argument entry (dividend at 4(A7), divisor at 8(A7) on entry; the code shuffles the return address so the caller sees D1 preserved) that saves D2-D3/D7 and calls rt_sdivmod32_core (0x194); returns the signed quotient in D0 [PROVEN, bytes 0x152..0x170]. Reached through JT $5a (used by ID02 ansi_ldiv).
 */
/* VERIFIED (ID01::FUN_00000152): ID01.bin 0x152..0x170 checked against an independent capstone disassembly:
 * same stack entry, JSR 0x194, D0 = signed quotient - identical to the C (reconstructed from the bytes;
 * Ghidra's void return dropped D0). */
int rt_sdiv32 /* Original: FUN_00000152 */ (int dividend,int divisor)

{
  return (int)(uint)(rt_sdivmod32_core(dividend,divisor) >> 0x20); /* JSR 0x194; D0 = quotient */
}



/* Original: FUN_00000172; source: ID01.c. Recovered name: rt_smod32 [PROVEN].
 * Decoded from ID01.bin bytes at file 0x172.
 * Stack-argument entry (dividend at 4(A7), divisor at 8(A7) on entry; the code shuffles the return address so the caller sees D1 preserved) that saves D2-D3/D7 and calls rt_sdivmod32_core (0x194); returns the signed remainder in D0 [PROVEN, bytes 0x172..0x192]. Reached through JT $62 (used by ID02 ansi_ldiv).
 */
/* VERIFIED (ID01::FUN_00000172): ID01.bin 0x172..0x192 checked against an independent capstone disassembly:
 * same stack entry, JSR 0x194, MOVE.L D1,D0 (signed remainder) - identical to the C (reconstructed from
 * the bytes). */
int rt_smod32 /* Original: FUN_00000172 */ (int dividend,int divisor)

{
  return (int)(uint)rt_sdivmod32_core(dividend,divisor); /* JSR 0x194; MOVE.L D1,D0 = remainder */
}



/* Original: FUN_00000194; source: ID01.c. Recovered name: rt_sdivmod32_core [PROVEN].
 * Decoded from ID01.bin bytes at file 0x194.
 * Register interface D0 = dividend, D1 = divisor. Makes both operands positive (NEG.L), calls rt_udivmod32_core and fixes the signs so the quotient truncates toward zero and the remainder takes the sign of the dividend (C semantics) [PROVEN, bytes 0x194..0x1c0].
 */
/* VERIFIED (ID01::FUN_00000194): ID01.bin 0x194..0x1c0 checked against an independent capstone disassembly:
 * NEG.L the negative operands, call the unsigned core, then NEG.L the results so the quotient
 * truncates toward zero and the remainder takes the dividend's sign; with both operands non-negative
 * BPL falls straight into the core at 0x1c2 - identical to the C (reconstructed from the bytes;
 * Ghidra's uint return kept only D1 and lost the negated arguments). */
ulonglong rt_sdivmod32_core /* Original: FUN_00000194 */ (int dividend,int divisor)

{
  ulonglong r;
  uint quot;
  uint rem;

  if (dividend < 0) {
    if (divisor < 0) {                      /* 0x19c: NEG both, JSR core, NEG D1 */
      r = rt_udivmod32_core(-(uint)dividend,-(uint)divisor);
      quot = (uint)(r >> 0x20);
      rem = -(uint)r;
    }
    else {                                  /* 0x1a8: NEG D0, JSR core, NEG D0, NEG D1 */
      r = rt_udivmod32_core(-(uint)dividend,(uint)divisor);
      quot = -(uint)(r >> 0x20);
      rem = -(uint)r;
    }
  }
  else if (divisor < 0) {                   /* 0x1b8: NEG D1, JSR core, NEG D0 */
    r = rt_udivmod32_core((uint)dividend,-(uint)divisor);
    quot = -(uint)(r >> 0x20);
    rem = (uint)r;
  }
  else {
    return rt_udivmod32_core((uint)dividend,(uint)divisor); /* 0x1b6 BPL falls into 0x1c2 */
  }
  return (ulonglong)quot << 0x20 | rem;
}



/* Original: FUN_000001c2; source: ID01.c. Recovered name: rt_udivmod32_core [PROVEN].
 * Decoded from ID01.bin bytes at file 0x1c2.
 * Register interface D0 = dividend, D1 = divisor (unsigned 32-bit); returns D0 = quotient, D1 = remainder. Fast paths: dividend < divisor (quotient 0); dividend <= 0xffff (one DIVU.W); divisor <= 0xffff (two chained DIVU.W); otherwise normalises both by shifting right until the divisor fits 16 bits, estimates the quotient with DIVU.W and corrects it downward by multiplying back (MULU.W) until the product no longer exceeds the dividend [PROVEN, bytes 0x1c2..0x22a+]. A pre-68020 style routine (the 68020 DIVU.L is not used).\n * Other ID01 code not exported by Ghidra (bytes 0x00..0x10e): 0x00 / 0x04 hold 0x0a and 0x4b2 (header words; 0x4b2 is the entry JT offset used by ID02 main [PROVEN]); 0x08..0x32 start-up: clears $0A4A, A6 = 0, JSR 0x34, then a call through JT $4b2 / the first jump-table slot and ExitToShell ($A9F4); 0x34..0x94 initialises the A5 world: GetResource(ZERO, 0) and GetResource(DATA, 0) ($A9A0), expands DATA into the globals below CurrentA5 (word runs, zero runs from ZERO), releases both, then GetResource(DREL, 0) and adds A5 to every relocation offset it lists (A5-relative pointer fix-ups); 0x96 / 0xaa / 0xbe are the switch helpers reached through JT $2a (word values: count, then (offset, value) pairs and a default), JT $32 (long values) and JT $3a (dense: lo, hi, default, offsets) - the formats decoded; 0xda is a 32 x 32 -> 32 multiply built from three MULU.W. These explain the inline tables Ghidra decoded as ori.b / btst instructions throughout ID02..ID04.
 */
/* VERIFIED (ID01::FUN_000001c2): ID01.bin 0x1c2..0x22a checked against an independent capstone disassembly:
 * divisor > dividend -> (0, dividend); dividend <= 0xffff -> one DIVU.W; divisor <= 0xffff -> two chained
 * DIVU.W (high word, then remainder:low word); otherwise both shifted right until the divisor fits 16
 * bits, DIVU.W estimate AND.L #$ffff, then multiplied back with two MULU.W (the high product SWAPped)
 * and decremented with SUBQ.W while the sum carries (BCS) or exceeds the dividend (BHI); the remainder
 * is NEG.L of (product - dividend). In the 16-bit paths MOVE.W D0,D1 keeps the divisor's high word,
 * which is 0 there, so the plain remainder is exact - identical to the C (reconstructed from the bytes). */
ulonglong rt_udivmod32_core /* Original: FUN_000001c2 */ (uint dividend,uint divisor)

{
  uint quot;
  uint mid;
  uint n;
  uint d;
  uint hi;
  uint sum;
  uint lo;

  if (dividend < divisor) {                /* 0x1c8 CMP.L D0,D1 / BLS not taken */
    return (ulonglong)dividend;             /* quotient 0, remainder = dividend */
  }
  if (dividend <= 0xffff) {                /* 0x1d2: one DIVU.W */
    return (ulonglong)(dividend / divisor) << 0x20 | dividend % divisor;
  }
  if (divisor <= 0xffff) {                 /* 0x1e2: two chained DIVU.W */
    mid = (dividend >> 0x10) % divisor << 0x10 | (dividend & 0xffff);
    quot = (dividend >> 0x10) / divisor << 0x10 | mid / divisor;
    return (ulonglong)quot << 0x20 | mid % divisor;
  }
  n = dividend;                             /* 0x200: normalise */
  d = divisor;
  do {
    n = n >> 1;
    d = d >> 1;
  } while (0xffff < d);
  quot = n / d & 0xffff;                    /* DIVU.W estimate, AND.L D7(=$ffff) */
  while( true ) {                           /* 0x210: multiply back and correct downward */
    lo = (divisor & 0xffff) * quot;
    hi = (divisor >> 0x10) * quot;
    sum = (hi << 0x10 | hi >> 0x10) + lo;   /* SWAP D7; ADD.L D7,D1 */
    if ((sum >= lo) && (sum <= dividend)) break; /* BCS / SUB.L D2,D1; BHI */
    quot = (uint)(ushort)((short)quot - 1); /* SUBQ.W #1,D0 */
  }
  return (ulonglong)quot << 0x20 | dividend - sum; /* NEG.L D1 */
}


/* ID01 file 0x22c, the segment's last word, is a bare RTS behind jump-table slot $6a, which no segment
 * uses (no JSR / PEA / LEA $6a(A5); tools/decomp/xrefs.py) [PROVEN, bytes]. */
