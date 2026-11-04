typedef unsigned char   undefined;

typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned short    ushort;
typedef unsigned char    byte;



/* VERIFIED (ID03::FUN_00000006): ID03.bin 0x6..0x54 checked against an independent capstone disassembly.
 * CMPI #1 A5-0x137a; TextFace 0, MULS #10, EXT.L, DIVS #3, BSR 0x8a, store to 8(A6), TextSize; else TextFace 1, MULS #10,
 * BSR 0x8a, TextSize; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_00000006; source: ID03.c:12.
 * Recovered name: set_scaled_text_style [STRONG INFERENCE].
 * Ghidra truncated at $A888. Bytes 0x06..0x54 [PROVEN]: word size at 8(A6).
 *   if (mode A5-0x137a == 1) { TextFace(0) $A888;
 *       TextSize(scale_design_4800((short)(size * 10) / 3)) $A88A }
 *   else { TextFace(1 = bold); TextSize(scale_design_4800(size * 10)) }
 * (1-bit mode uses plain text at one third of the colour-mode size, as coded.)
 * Body rebuilt as C below.
 */
void set_scaled_text_style /* Original: FUN_00000006 */ (short size)

{
  int unaff_A5;

  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    TextFace(0);                                /* $A888: plain */
    size = (short)scale_design_4800((short)((int)(short)(size * 10) / 3)); /* MULS.W #10, EXT.L, DIVS.W #3; BSR 0x8a */
    TextSize(size);                             /* $A88A; result stored back into the argument slot */
  }
  else {
    TextFace(1);                                /* bold */
    TextSize((short)scale_design_4800((short)(size * 10)));
  }
  return;
}



/* VERIFIED (ID03::FUN_00000056): ID03.bin 0x56..0x88 checked against an independent capstone disassembly.
 * MOVEA.W, MULU.L A5-0x149e, ADDQ #5, DIVS.L #$1e0, word local, CMPI #10 BGE / MOVEQ #10; MOVE.W result; RTS - identical to the C. */
/*
 * Original: FUN_00000056; source: ID03.c:27.
 * Recovered name: scale_design_480_min10 [STRONG INFERENCE].
 * Exported C complete: v = (long A5-0x149e * (short)param + 5) / 480, then at
 * least 10; returns a word (D0 = MOVE.W of the local; Ghidra's high-word note is moot). A5-0x149e is a
 * scale factor (screen-size dependent) [STRONG INFERENCE; identity UNKNOWN].
 */
short scale_design_480_min10 /* Original: FUN_00000056 */ (short v)

{
  int unaff_A5;
  short r;                                      /* -2(A6) */

  r = (short)((*(int *)(unaff_A5 + -0x149e) * (int)v + 5) / 0x1e0); /* MOVEA.W, MULU.L, ADDQ #5, DIVS.L #480 */
  if (r < 10) {
    r = 10;
  }
  return r;                                     /* MOVE.W -2(A6),D0 */
}



/* VERIFIED (ID03::FUN_0000008a): ID03.bin 0x8a..0xa4 checked against an independent capstone disassembly.
 * MOVEA.W, MULU.L A5-0x149e, DIVS.L #$12c0, long result; RTS - identical to the C. */
/*
 * Original: FUN_0000008a; source: ID03.c:45.
 * Recovered name: scale_design_4800 [STRONG INFERENCE].
 * Exported C complete: (long A5-0x149e * (short)param) / 4800 (signed, truncating).
 * Converts design units to screen units [STRONG INFERENCE].
 */
int scale_design_4800 /* Original: FUN_0000008a */ (short v)

{
  int unaff_A5;

  return (*(int *)(unaff_A5 + -0x149e) * (int)v) / 0x12c0; /* MOVEA.W, MULU.L (low 32 bits), DIVS.L #4800 */
}



/* VERIFIED (ID03::FUN_000000a6): ID03.bin 0xa6..0xc6 checked against an independent capstone disassembly.
 * BSR 0x8a; thePort +$36 MOVEA.W, DIVS.W #2, SUB.W; RTS - identical to the C. */
/*
 * Original: FUN_000000a6; source: ID03.c:55.
 * Recovered name: scale_design_4800_pen_centred [STRONG INFERENCE].
 * Exported C complete: scale_design_4800(v) - thePort->pnSize.h (+0x36) / 2
 * (pen-centred coordinate). Ghidra's unaff_A6 half is register residue.
 */
short scale_design_4800_pen_centred /* Original: FUN_000000a6 */ (short v)

{
  int unaff_A5;

  return (short)scale_design_4800(v) -           /* BSR 0x8a */
         (short)((int)*(short *)(*(int *)(unaff_A5 + -0x160c) + 0x36) / 2); /* thePort->pnSize.h / 2 */
}



/* VERIFIED (ID03::FUN_000000c8): ID03.bin 0xc8..0xf2 checked against an independent capstone disassembly.
 * CMP.L $c BGE / store; CMP.L $10 BGE -> D0 = a else D0 = c; RTS - identical to the C. */
/*
 * Original: FUN_000000c8; source: ID03.c:68.
 * Recovered name: max3_int [STRONG INFERENCE].
 * Exported C complete: signed maximum of three longs.
 */
int max3_int /* Original: FUN_000000c8 */ (int a,int b,int c)

{
  if (a < b) {
    a = b;                                      /* stored into 8(A6) */
  }
  if (a < c) {
    return c;
  }
  return a;
}



/* VERIFIED (ID03::FUN_000000f4): ID03.bin 0xf4..0x2a6 checked against an independent capstone disassembly.
 * LINK -$20; zero-extended r/g/b longs; best = -1, dist = $7fffffff; i 0..7 over A5-0x350 (MULS #6): three JT $4da, BSR 0xc8,
 * CMP.L BGE; extended scan to A5-0x14a2 over *(A5-0x14a6): first d < dist -> best = i + 8 (D0), exit; mode 4 / 1 -> best,
 * 8 -> best + $c8, else D0; RTS - identical to the C. */
/*
 * Original: FUN_000000f4; source: ID03.c:82.
 * Recovered name: nearest_palette_index_rgb [STRONG INFERENCE].
 * Exported C complete. param_1 -> RGB (3 words). JT $4da = ID02 FUN_0000001e
 * (abs). Distance = max3_int(|dr|, |dg|, |db|) (Chebyshev).
 *   best over the 8 base colours at A5-0x350 (6 bytes each);
 *   then scans the extended table *(long A5-0x14a6) (count word A5-0x14a2)
 *   and returns the FIRST entry closer than the base best (index + 8), not
 *   the global minimum - behaviour preserved as exported.
 *   Result by mode word A5-0x137a: 4 or 1 -> chosen index (local_8);
 *   8 -> chosen index + 200; any other mode -> whatever D0.W holds after the
 *   scan: the table count if no extended entry matched, else the matched
 *   index + 8 (the counter itself is not advanced by 8; Ghidra's C modelled it
 *   that way, with the same results). Body rewritten as C below. Same index
 *   space as ID02 lookup_palette_index_for_rgb_level.
 */
short nearest_palette_index_rgb /* Original: FUN_000000f4 */ (unsigned short *rgb)

{
  int unaff_A5;
  int dg;                                       /* -$20(A6) */
  int dr;                                       /* -$1c(A6) */
  int b;                                        /* -$18(A6): zero-extended words */
  int g;                                        /* -$14(A6) */
  int r;                                        /* -$10(A6) */
  int d;                                        /* -$c(A6) */
  int bestDist;                                 /* -8(A6) */
  short best;                                   /* -4(A6) */
  short i;                                      /* -2(A6) */
  short d0;                                     /* D0.W left over for the fall-through mode */
  unsigned short *e;

  r = (int)rgb[0];
  g = (int)rgb[1];
  b = (int)rgb[2];
  best = -1;
  bestDist = 0x7fffffff;
  for (i = 0; i < 8; i = i + 1) {               /* the 8 base colours, 6 bytes each at A5-0x350 */
    e = (unsigned short *)(unaff_A5 + -0x350 + (int)(short)(i * 6));
    dr = abs_long((int)e[0] - r);               /* JT $4da */
    dg = abs_long((int)e[1] - g);
    d = max3_int(dr,dg,abs_long((int)e[2] - b)); /* BSR 0xc8 */
    if (d < bestDist) {
      best = i;
      bestDist = d;
    }
  }
  i = 0;
  while (true) {                                /* extended table *(A5-0x14a6), count A5-0x14a2 */
    d0 = i;                                     /* MOVE.W -2(A6),D0 before the CMP */
    if (*(short *)(unaff_A5 + -0x14a2) <= i) break;
    e = (unsigned short *)(*(int *)(unaff_A5 + -0x14a6) + (int)(short)(i * 6));
    dr = abs_long((int)e[0] - r);
    dg = abs_long((int)e[1] - g);
    d = max3_int(dr,dg,abs_long((int)e[2] - b));
    if (d < bestDist) {                         /* first entry better than the base best wins */
      d0 = i + 8;
      best = d0;
      bestDist = d;
      break;
    }
    i = i + 1;
  }
  if ((*(short *)(unaff_A5 + -0x137a) == 4) || (*(short *)(unaff_A5 + -0x137a) == 1)) {
    return best;
  }
  if (*(short *)(unaff_A5 + -0x137a) == 8) {
    return best + 200;                          /* ADDI.W #$c8 */
  }
  return d0;                                    /* other modes: D0 as left by the scan */
}



/* VERIFIED (ID03::FUN_000002a8): ID03.bin 0x2a8..0x33a checked against an independent capstone disassembly.
 * LINK -$12; bounds (0, 0, $a, 8); rowBytes DIVS #16, x2, +2; JT $232(MULU.L height*rowBytes), JT $232($6c); OpenPort;
 * SetPortBits(-$e); portRect copy to +$10; PortSize(8, $a); RectRgn(+$18, bounds); D0 = port; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_000002a8; source: ID03.c:148.
 * Recovered name: new_offscreen_bw_port [STRONG INFERENCE].
 * Ghidra truncated after the allocations; body rebuilt as C below. Bytes 0x2a8..0x33a [PROVEN].
 * Args: words width [8(A6)], height [$a(A6)]. Returns GrafPtr (D0).
 *   rowBytes = (width / 16) * 2 + 2; bits = NewPtrClear(height * rowBytes)
 *   (JT $232); port = NewPtrClear(0x6c); OpenPort(port) $A86F;
 *   BitMap bm = { bits, rowBytes, (0, 0, height, width) }; SetPortBits(&bm)
 *   $A875; port->portRect = bm.bounds; PortSize(width, height) $A876;
 *   RectRgn(port->visRgn, &bm.bounds) $A8DF.
 * 1-bit offscreen GrafPort [STRONG INFERENCE]. No NULL checks.
 * Caller: FUN_000032b8 (file 0x3496).
 */
int new_offscreen_bw_port /* Original: FUN_000002a8 */ (short width,short height)

{
  int port;                                     /* -$12(A6) */
  int bmBase;                                   /* -$e(A6): BitMap.baseAddr */
  short bmRowBytes;                             /* -$a(A6) */
  short bmBounds[4];                            /* -8(A6): top, left, bottom, right */

  bmBounds[1] = 0;
  bmBounds[0] = 0;
  bmBounds[3] = width;
  bmBounds[2] = height;
  bmRowBytes = (short)((int)width / 0x10) * 2 + 2; /* MOVEA.W, DIVS.W #16, ADD.W D0,D0, ADDQ #2 */
  bmBase = NewPtrClear((int)height * (int)bmRowBytes); /* JT $232 (ID09 0x20c); MULU.L of sign-extended words */
  port = NewPtrClear(0x6c);                     /* sizeof(GrafPort) */
  OpenPort(port);                               /* $A86F */
  SetPortBits(&bmBase);                         /* $A875: the BitMap at -$e */
  *(int *)(port + 0x10) = *(int *)bmBounds;     /* portRect = bounds */
  *(int *)(port + 0x14) = *(int *)(bmBounds + 2);
  PortSize(width,height);                       /* $A876 */
  RectRgn(*(int *)(port + 0x18),bmBounds);      /* $A8DF: visRgn */
  return port;
}



/* VERIFIED (ID03::FUN_0000033c): ID03.bin 0x33c..0x35c checked against an independent capstone disassembly.
 * ClosePort; JT $23a(+2); JT $23a(port); RTS - identical to the C. */
/*
 * Original: FUN_0000033c; source: ID03.c:164.
 * Recovered name: dispose_offscreen_bw_port [STRONG INFERENCE].
 * Ghidra truncated; body rebuilt as C below. Bytes 0x33c..0x35c [PROVEN]: arg GrafPtr port;
 *   ClosePort(port) $A87D; DisposPtr(port->portBits.baseAddr (+2)) (JT $23a);
 *   DisposPtr(port). Inverse of new_offscreen_bw_port. Caller: FUN_000032b8
 *   (file 0x381e).
 */
void dispose_offscreen_bw_port /* Original: FUN_0000033c */ (int port)

{
  ClosePort(port);                              /* $A87D */
  DisposPtr(*(int *)(port + 2));                /* JT $23a (ID09 0x218): portBits.baseAddr */
  DisposPtr(port);
  return;
}



/* VERIFIED (ID03::FUN_0000035e): ID03.bin 0x35e..0x512 checked against an independent capstone disassembly.
 * LINK -$14; NewRgn, GetClip, NewRgn; rect via JT $3ca / $382 and two BSR 0x8a; grey (2,2,2) JT $45a/$36a; PaintOval; OpenRgn,
 * FrameOval, CloseRgn; centre into 8/$a(A6); BSR 0x8a(A5-0x2114) CMPI #5 BLT; black; phase 0 / 1 / 2 / other lines (SetClip
 * ring for 1 and 2); phase = (phase + 5) & 3; SetClip(saved); DisposeRgn x2; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_0000035e; source: ID03.c:175.
 * Recovered name: draw_spinning_disc_indicator [STRONG INFERENCE mechanics]
 * Ghidra exported no body; body rebuilt as C below.
 * Bytes 0x35e..0x512 [PROVEN]. Args: words cx [8(A6)], cy [$a(A6)] (design units).
 *   d = word A5-0x2114 (size); r.left = design_x_to_screen(cx - d/2);
 *   r.top = design_y_to_screen(cy - d/2); r.right = r.left + scale_design_4800(d);
 *   r.bottom = r.top + scale_design_4800(d);
 *   saved = NewRgn, GetClip(saved); ring = NewRgn;
 *   colour grey (2,2,2) via lookup_palette_index_for_rgb_level (JT $45a) +
 *   set_draw_color_index (JT $36a); PaintOval(&r) $A8B8;
 *   OpenRgn; FrameOval(&r) $A8B7; CloseRgn(ring) (ring = outline region);
 *   centre (cx', cy') = midpoint of r;
 *   if (scale_design_4800(d) >= 5):
 *     colour black (0,0,0);
 *     phase word A5-0x2112: 0 -> vertical line through centre;
 *       1 -> SetClip(ring), diagonal top-left -> bottom-right;
 *       2 -> SetClip(ring), diagonal top-right -> bottom-left;
 *       other -> horizontal line through centre;
 *     phase = (phase + 5) & 3   (advances one step per call);
 *   SetClip(saved); DisposeRgn(ring); DisposeRgn(saved).
 * A grey disc with a spoke that rotates 45 degrees per call [STRONG INFERENCE].
 *  [HYPOTHESIS, stronger]: a bezel screw head - draw_instrument
 * places these at the bezel corners, and the stepping phase gives each screw a
 * different slot orientation (not an animation). Callers: 5 BSRs inside
 * draw_ring_with_status_indicators (FUN_00000514; file 0x624, 0x684, 0x6e2, 0x742, 0x774).
 */
void draw_spinning_disc_indicator /* Original: FUN_0000035e */ (short cx,short cy)

{
  int unaff_A5;
  int savedClip;                                /* -$14(A6) */
  int ring;                                     /* -$10(A6) */
  short r[4];                                   /* -$c(A6): top, left, bottom, right */
  short d;                                      /* -2(A6) */

  savedClip = NewRgn();                         /* $A8D8 */
  GetClip(savedClip);                           /* $A87A */
  ring = NewRgn();
  d = *(short *)(unaff_A5 + -0x2114);           /* size, design units */
  r[1] = (short)design_x_to_screen(cx - (short)((int)d / 2)); /* JT $3ca */
  r[0] = (short)design_y_to_screen(cy - (short)((int)d / 2)); /* JT $382 */
  r[3] = (short)scale_design_4800(d) + r[1];    /* BSR 0x8a */
  r[2] = (short)scale_design_4800(d) + r[0];
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2)); /* JT $45a, JT $36a: grey */
  PaintOval(r);                                 /* $A8B8 */
  OpenRgn();                                    /* $A8DA */
  FrameOval(r);                                 /* $A8B7 */
  CloseRgn(ring);                               /* $A8DB: ring = the outline */
  cx = (short)((int)(short)(r[3] - r[1]) / 2) + r[1]; /* centre, stored back into the argument slots */
  cy = (short)((int)(short)(r[2] - r[0]) / 2) + r[0];
  if (4 < (short)scale_design_4800(*(short *)(unaff_A5 + -0x2114))) { /* CMPI.W #5 BLT */
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* black */
    if (*(short *)(unaff_A5 + -0x2112) == 0) {
      MoveTo(cx,r[0]);                          /* $A893: vertical */
      LineTo(cx,r[2] + -1);                     /* $A891 */
    }
    else if (*(short *)(unaff_A5 + -0x2112) == 1) {
      SetClip(ring);                            /* $A879 */
      MoveTo(r[1],r[0]);                        /* top-left to bottom-right */
      LineTo(r[3] + -1,r[2] + -1);
    }
    else if (*(short *)(unaff_A5 + -0x2112) == 2) {
      SetClip(ring);
      MoveTo(r[3] + -1,r[0]);                   /* top-right to bottom-left */
      LineTo(r[1],r[2] + -1);
    }
    else {
      MoveTo(r[1],cy);                          /* horizontal */
      LineTo(r[3] + -1,cy);
    }
    *(short *)(unaff_A5 + -0x2112) = *(short *)(unaff_A5 + -0x2112) + 5U & 3; /* ADDQ #5, ANDI #3 */
  }
  SetClip(savedClip);
  DisposeRgn(ring);                             /* $A8D9 */
  DisposeRgn(savedClip);
  return;
}



/* VERIFIED (ID03::FUN_00000514): ID03.bin 0x514..0x77c checked against an independent capstone disassembly.
 * LINK -$c; rect via JT $3ca / $382 + two BSR 0x8a; black JT $45a/$36a, PaintOval; grey; PenSize(w/10, w/10); FrameOval;
 * BTST #0..#4 on $11(A6): o = DIVS #2, EXT.L, MULU.L #$b50, ASR.L #12; corners at cx/cy -+ o -+ 30, bit 4 at (cx, cy + d/2 + 30);
 * BSR 0x35e(x, y) each; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_00000514; source: ID03.c:186.
 * Recovered name: draw_ring_with_status_indicators [STRONG INFERENCE mechanics /
 * HYPOTHESIS purpose]. Ghidra truncated at $A8B8; body rebuilt as C below.
 * Bytes 0x514..0x77c [PROVEN]. Words: d [8], w [$a], cy [$c], cx [$e];
 * flags = word [$10] (bits tested on its low byte $11; corrected from "long":
 * every caller pushes five words, LEA $a(A7) - e.g. draw_instrument passes 0x1b / 0xf).
 *   r.left = design_x_to_screen(cx - d/2); r.top = design_y_to_screen(cy - d/2);
 *   r.right/bottom = + scale_design_4800(d);
 *   black (0,0,0) -> PaintOval(&r); grey (2,2,2); PenSize(w/10, w/10);
 *   FrameOval(&r);
 *   o = ((d/2) * 0xb50) >> 12   (0xb50/4096 = 0.7071 = cos 45 deg);
 *   bit 0 -> draw_spinning_disc_indicator(cx - o - 30, cy - o - 30);
 *   bit 1 -> (cx + o + 30, cy - o - 30);  bit 2 -> (cx + o + 30, cy + o + 30);
 *   bit 3 -> (cx - o - 30, cy + o + 30);  bit 4 -> (cx, cy + d/2 + 30) [PROVEN:
 *   straight below, no 0.7071 factor]. Bits 0..3 sit on the diagonals outside the ring.
 * Note: Ghidra's in_stack_fffffff0 halves are pushed-word artifacts.
 */
void draw_ring_with_status_indicators /* Original: FUN_00000514 */
               (short d,short w,short cy,short cx,unsigned short flags)

{
  short r[4];                                   /* -8(A6): top, left, bottom, right */
  short sx;                                     /* -$a(A6) */
  short sy;                                     /* -$c(A6) */

  r[1] = (short)design_x_to_screen(cx - (short)((int)d / 2)); /* JT $3ca */
  r[0] = (short)design_y_to_screen(cy - (short)((int)d / 2)); /* JT $382 */
  r[3] = (short)scale_design_4800(d) + r[1];    /* BSR 0x8a */
  r[2] = (short)scale_design_4800(d) + r[0];
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $45a, JT $36a: black */
  PaintOval(r);                                 /* $A8B8 */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2)); /* grey */
  PenSize((short)((int)w / 10),(short)((int)w / 10)); /* $A89B */
  FrameOval(r);                                 /* $A8B7 */
  /* o = ((d / 2) * 0xb50) >> 12: d/2 * cos 45 deg (DIVS.W #2, EXT.L, MULU.L #$b50, ASR.L #12), recomputed per use */
#define O_ ((short)((int)((unsigned int)(int)(short)((int)d / 2) * 0xb50) >> 0xc))
  if ((flags & 1) != 0) {                       /* BTST #0, $11(A6) */
    sx = (cx - O_) + -0x1e;
    sy = (cy - O_) + -0x1e;
    draw_spinning_disc_indicator(sx,sy);        /* BSR 0x35e: top-left */
  }
  if ((flags & 2) != 0) {
    sx = O_ + cx + 0x1e;
    sy = (cy - O_) + -0x1e;
    draw_spinning_disc_indicator(sx,sy);        /* top-right */
  }
  if ((flags & 4) != 0) {
    sx = O_ + cx + 0x1e;
    sy = O_ + cy + 0x1e;
    draw_spinning_disc_indicator(sx,sy);        /* bottom-right */
  }
  if ((flags & 8) != 0) {
    sx = (cx - O_) + -0x1e;
    sy = O_ + cy + 0x1e;
    draw_spinning_disc_indicator(sx,sy);        /* bottom-left */
  }
  if ((flags & 0x10) != 0) {
    sx = cx;
    sy = (short)((int)d / 2) + cy + 0x1e;       /* straight below: no cos 45 factor */
    draw_spinning_disc_indicator(sx,sy);
  }
#undef O_
  return;
}



/* VERIFIED (ID03::FUN_0000077e): ID03.bin 0x77e..0x910 checked against an independent capstone disassembly.
 * LINK -$c; pass 1 while p[1]: k 0..5 over A5-0x20b0, x -= (EXTB width + 1) MULS scale / 2; pass 2 while *text: match, cursor =
 * glyph + 2, gx/gy accumulate MULS scale, two BSR 0xa6, MoveTo; loop to 'c' with LineTo; x += (width + 1) * scale; RTS -
 * identical to the C. */
/* Original: FUN_0000077e; source: ID03.c. Recovered name: draw_vector_glyph_string_centred [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x77e.
 * C args: +8 char *text, +0xc short scale, +0xe short x, +0x10 short y (design units). First pass: for each character except the last (the loop tests p[1]) found in the six-entry glyph table A5-0x20b0 (pointer per glyph; glyph byte 0 = character, byte 1 = width), x -= (width + 1) * scale / 2 - centres the string (the last glyph's width is not counted) [PROVEN, bytes]. Second pass: for each character, the glyph's stroke list (from byte 2) holds signed (dx, dy) byte pairs, cumulative from (x, y) and multiplied by scale, ended by the byte 'c' (0x63); the first pair is a MoveTo, the rest LineTo ($A893 / $A891), each coordinate through scale_design_4800_pen_centred (0xa6); then x += (width + 1) * scale [PROVEN control flow; glyph data is A5 initial data, not read]. Caller: draw_direction_indicator (0x2bd6) - probably the compass letters [HYPOTHESIS]. Ghidra truncated the drawing loop; body rebuilt as C below.
 */
void draw_vector_glyph_string_centred /* Original: FUN_0000077e */ (char *text,short scale,short x,short y)

{
  int unaff_A5;
  char *p;                                      /* -4(A6): string cursor, then glyph stroke cursor */
  short k;                                      /* -6(A6) */
  short gx;                                     /* -8(A6) */
  short gy;                                     /* -$a(A6) */
  short sx;                                     /* -$c(A6) */
  char *glyph;

  for (p = text; p[1] != '\0'; p = p + 1) {    /* every character except the last (tests p[1]) */
    for (k = 0; k < 6; k = k + 1) {
      glyph = *(char **)(unaff_A5 + -0x20b0 + (int)k * 4);
      if (*glyph == *p) {
        x = x - (short)((int)(short)((short)(glyph[1] + 1) * scale) / 2); /* EXTB.L, ADDQ #1, MULS.W, EXT.L, DIVS.W #2 */
        break;
      }
    }
  }
  for (; *text != '\0'; text = text + 1) {
    for (k = 0; k < 6; k = k + 1) {
      glyph = *(char **)(unaff_A5 + -0x20b0 + (int)k * 4);
      if (*glyph == *text) {
        p = glyph + 2;                          /* stroke list: signed (dx, dy) byte pairs */
        gx = x;
        gy = y;
        gx = gx + (short)p[0] * scale;
        sx = scale_design_4800_pen_centred(gx); /* BSR 0xa6 */
        gy = gy + (short)p[1] * scale;
        MoveTo(sx,scale_design_4800_pen_centred(gy)); /* $A893 */
        for (p = p + 2; *p != 'c'; p = p + 2) { /* 0x63 ends the stroke list */
          gx = gx + (short)p[0] * scale;
          sx = scale_design_4800_pen_centred(gx);
          gy = gy + (short)p[1] * scale;
          LineTo(sx,scale_design_4800_pen_centred(gy)); /* $A891 */
        }
        x = x + (short)(glyph[1] + 1) * scale;  /* advance by width + 1 */
        break;
      }
    }
  }
  return;
}



/* VERIFIED (ID03::FUN_00000912): ID03.bin 0x912..0xa3a checked against an independent capstone disassembly.
 * LINK -$12, save A4; i = 5 do { i--, DIVS #10 remainder -> -$10[i], quotient -> 8(A6) } while; x -= ((4 - i) * 6 * scale) / 2;
 * while i < 5: digit -> A5-0x1fde stroke list in A4, MoveTo then LineTo to 'c' via BSR 0xa6, x += scale * 6; restore A4;
 * RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_00000912; source: ID03.c:253.
 * Recovered name: draw_vector_number [STRONG INFERENCE].
 * Body rebuilt as C below (Ghidra truncated after the first stroke). Words:
 * value [8], scale [$a], cx [$c], y [$e].
 * Splits value into decimal digits, most significant first, into digits[i..4]
 * (DIVS.W remainders; at most 5 digits for a word, so no overflow check - the
 * exported "return" was only the i < 5 loop test) [PROVEN, bytes].
 * Each digit d selects a stroke list char *A5-0x1fde[d] of signed (dx, dy)
 * byte pairs, cumulative and multiplied by scale, ended by 'c' (0x63); first
 * pair MoveTo, rest LineTo, each through scale_design_4800_pen_centred.
 * x starts at cx - ((digit count - 1) * 6 * scale) / 2 (corrected: the bytes
 * use 4 - i, one less than the digit count) and advances 6 * scale per digit. Vector-font number display (e.g. instruments)
 * [HYPOTHESIS for the use].
 */
void draw_vector_number /* Original: FUN_00000912 */ (short value,short scale,short x,short y)

{
  int unaff_A5;
  char *s;                                      /* A4 (saved and restored) */
  short digits[5];                              /* -$10(A6) */
  short i;                                      /* -2(A6) */
  short gx;                                     /* -4(A6) */
  short gy;                                     /* -6(A6) */
  short sx;                                     /* -$12(A6) */

  i = 5;
  do {
    i = i + -1;
    digits[i] = value % 10;                     /* DIVS.W #10, SWAP: remainder */
    value = value / 10;
  } while (value != 0);
  x = x - (short)((int)(short)((short)((4 - i) * 6) * scale) / 2); /* centred on (digit count - 1) * 6 units */
  while (i < 5) {
    value = digits[i];                          /* stored into the argument slot */
    i = i + 1;
    s = *(char **)(unaff_A5 + -0x1fde + (int)value * 4); /* stroke list per digit: signed (dx, dy) pairs */
    gx = x;
    gy = y;
    gx = gx + (short)s[0] * scale;
    sx = scale_design_4800_pen_centred(gx);     /* BSR 0xa6 */
    gy = gy + (short)s[1] * scale;
    MoveTo(sx,scale_design_4800_pen_centred(gy)); /* $A893 */
    for (s = s + 2; *s != 'c'; s = s + 2) {     /* 0x63 ends the list */
      gx = gx + (short)s[0] * scale;
      sx = scale_design_4800_pen_centred(gx);
      gy = gy + (short)s[1] * scale;
      LineTo(sx,scale_design_4800_pen_centred(gy)); /* $A891 */
    }
    x = x + scale * 6;                          /* 6 units per digit */
  }
  return;
}



/* VERIFIED (ID03::FUN_00000a3c): ID03.bin 0xa3c..0x1468 checked against an independent capstone disassembly.
 * LINK -$38, MOVEM A2-A4; PenPat(A5-0x161c); seven row pointers at rowBytes spacing, step x3; optional clear of out[0..cols);
 * row loop while rows - 1 > r; column loop i < cols with x += 3; seven unrolled column blocks (ASR #3 byte, A5-0x1fb6 mask,
 * MOVEQ weights extracted mechanically: totals 12, 89, 229, 309, 229, 89, 12 = 969); TST sum BEQ skip; MULU.L #$ffff,
 * DIVS.L #$3c9 into three RGB words; BSR 0xf4; JT $36a; MoveTo(x0 + i, y0 + r); Line(0, 0); out[i] = 1; pointer advance;
 * MOVEM restore; RTS - identical to the C (the C loops over the weights the binary unrolls). */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_00000a3c; source: ID03.c:294.
 * Recovered name: antialias_downsample_bw_3x [STRONG INFERENCE]
 * Ghidra exported no body; body rebuilt as C below.
 * Bytes 0xa3c..0x1468 [PROVEN]. Args: GrafPtr src [8] (1-bit port: base +2,
 * rowBytes +6), word x0 [$c], word y0 [$e], word rows [$10], word cols [$12],
 * byte *out [$14] (optional, 0 = none).
 *   PenPat(QD black); seven source row pointers base + k*rowBytes (k = 0..6);
 *   row step = 3 * rowBytes; if (out) clear cols bytes of out;
 *   for row in 0.. rows-2:
 *     for i in 0.. cols-1 (source x advances by 3 per output pixel):
 *       sum = sum over a 7x7 window of source bits (mask table A5-0x1fb6[x&7],
 *             byte x>>3) times the symmetric kernel (columns dx 0..6):
 *             0,1,3,4,3,1,0 / 1,8,21,29,21,8,1 / 3,21,54,73,54,21,3 /
 *             4,29,73,97,73,29,4 / mirror  [PROVEN: every immediate, total 969];
 *       if sum == 0 nothing is drawn [PROVEN; corrected];
 *       level = sum * 0xffff / 0x3c9 (MULU.L / DIVS.L) -> RGB grey at -0x2c(A6);
 *       c = nearest_palette_index_rgb(&rgb); set_draw_color_index(c) (JT $36a);
 *       MoveTo(x0 + i, y0 + row) $A893; Line(0, 0) $A892  (plot one pixel);
 *       if (out) out[i] = 1 (a drawn-column flag, not c) [PROVEN; corrected];
 *     advance all seven row pointers by 3 * rowBytes.
 * Gaussian-weighted 3x supersampling filter: renders a 1-bit offscreen image
 * (e.g. from new_offscreen_bw_port) as anti-aliased grey palette pixels.
 * MoveTo pushes x0 + i first, so x0 is h and y0 is v [PROVEN].
 * Callers [PROVEN, BSR scan]: ID03 file 0x152c, 0x37fc (FUN_000032b8), 0x4b02.
 */
void antialias_downsample_bw_3x /* Original: FUN_00000a3c */
               (int src,short x0,short y0,short rows,short cols,char *out)

{
  int unaff_A5;
  unsigned char *row[7];                        /* A4, A3, A2, -$10, -$14, -$18, -$1c(A6): window rows 0..6 */
  short step;                                   /* -$1e(A6): rowBytes, then 3 * rowBytes */
  short bx;                                     /* -$20(A6): byte index */
  unsigned short mask;                          /* -$22(A6) */
  short sum;                                    /* -$24(A6) */
  unsigned short rgb[3];                        /* -$2c(A6) */
  short level;
  short x;                                      /* -6(A6): source x, 3 per output pixel */
  short i;                                      /* -4(A6) */
  short r;                                      /* -2(A6) */
  short dx;
  short k;
  /* Weights as immediates of the unrolled code (one block per column dx = 0..6, one
     MOVEQ per window row): symmetric, 969 = 0x3c9 in total. Not a table in the binary. */
  static const char W[7][7] = {
    { 0, 1, 3, 4, 3, 1, 0 },
    { 1, 8,21,29,21, 8, 1 },
    { 3,21,54,73,54,21, 3 },
    { 4,29,73,97,73,29, 4 },
    { 3,21,54,73,54,21, 3 },
    { 1, 8,21,29,21, 8, 1 },
    { 0, 1, 3, 4, 3, 1, 0 } };                  /* W[dx][window row] */

  PenPat((void *)(unaff_A5 + -0x161c));         /* $A89D: QuickDraw black */
  step = *(short *)(src + 6);                   /* portBits.rowBytes */
  row[0] = *(unsigned char **)(src + 2);        /* portBits.baseAddr */
  for (k = 1; k < 7; k = k + 1) {
    row[k] = row[k + -1] + step;                /* MOVEA.W step, ADDA.L */
  }
  step = step * 3;
  if (out != (char *)0x0) {
    for (i = 0; i < cols; i = i + 1) {
      out[i] = 0;
    }
  }
  for (r = 0; r < rows + -1; r = r + 1) {       /* SUBQ #1, CMP, BGT */
    x = 0;
    for (i = 0; i < cols; i = i + 1) {
      sum = 0;
      for (dx = 0; dx < 7; dx = dx + 1) {       /* unrolled in the binary */
        bx = (short)(x + dx) >> 3;              /* ASR.W #3 */
        mask = *(unsigned short *)(unaff_A5 + -0x1fb6 + (int)(short)((x + dx) & 7) * 2);
        for (k = 0; k < 7; k = k + 1) {
          if ((W[dx][k] != 0) && (((unsigned short)row[k][bx] & mask) != 0)) {
            sum = sum + W[dx][k];               /* MOVEQ #w; first column MOVE.W, later ADD.W into -$24 */
          }
        }
      }
      if (sum != 0) {                           /* blank windows draw nothing */
        level = (short)((int)((unsigned int)(int)sum * 0xffff) / 0x3c9); /* MOVEA.W, MULU.L #$ffff, DIVS.L #969 */
        rgb[1] = level;
        rgb[2] = level;
        rgb[0] = level;
        set_draw_color_index(nearest_palette_index_rgb(rgb)); /* BSR 0xf4, JT $36a */
        MoveTo(x0 + i,y0 + r);                  /* $A893 */
        Line(0,0);                              /* $A892: one pixel */
        if (out != (char *)0x0) {
          out[i] = 1;                           /* marks the column as drawn (MOVEQ #1) */
        }
      }
      x = x + 3;
    }
    for (k = 0; k < 7; k = k + 1) {
      row[k] = row[k] + step;                   /* ADDA.W for A4/A3/A2, EXT.L + ADD.L for the stack pointers */
    }
  }
  return;                                       /* MOVEM.L restores A2-A4 */
}



/* VERIFIED (ID03::FUN_0000146a): ID03.bin 0x146a..0x1536 checked against an independent capstone disassembly.
 * LINK -$10; two BSR 0x8a(size); JT $3ca($12 - size/2), JT $382($10 - size/2); mode 1: portRect copy, OffsetRect(sx, sy),
 * CopyBits(src+2, *(A5-0x1496)+2, src+$10, r, 3, NULL); else push A5-0x1fa6 RGB (6 bytes), NULL, w, h, sy, sx, src;
 * BSR 0xa3c; LEA $16; RTS - identical to the C. */
/* Original: FUN_0000146a; source: ID03.c. Recovered name: composite_instrument_bitmap [PROVEN].
 * Decoded from ID03.bin bytes at file 0x146a.
 * C args: +8 GrafPtr src (the instrument port), +0xc short size, +0xe short (0 from the caller; never read), +0x10 short y, +0x12 short x (corrected: $12 feeds design_x_to_screen, $10 design_y_to_screen). Computes the destination rect from scale_design_4800(size) and design_x_to_screen / design_y_to_screen (JT $3ca / $382). Depth 1 (A5-0x137a == 1): rect = src portRect offset to the destination (OffsetRect $A8A8), CopyBits(src bits, panel port A5-0x1496 bits, &src portRect, &rect, mode 3 = srcBic, NULL) ($A8EC). Otherwise antialias_downsample_bw_3x(src, sx, sy, rows = scale(size), cols = scale(size), out = NULL) into the current port; the 6-byte RGBColor at A5-0x1fa6 is also pushed (22 bytes popped) but the callee never reads it [PROVEN, bytes]. Body rebuilt as C below. Caller: finish_instrument_supersample (0x1860).
 */
void composite_instrument_bitmap /* Original: FUN_0000146a */ (int src,short size,short unused,short y,short x)

{
  int unaff_A5;
  short r[4];                                   /* -$10(A6): top, left, bottom, right */
  short sy;                                     /* -8(A6) */
  short sx;                                     /* -6(A6) */
  short w;                                      /* -4(A6) */
  short h;                                      /* -2(A6) */

  h = (short)scale_design_4800(size);           /* BSR 0x8a */
  w = (short)scale_design_4800(size);
  sx = (short)design_x_to_screen(x - (short)((int)size / 2)); /* JT $3ca: word $12(A6) */
  sy = (short)design_y_to_screen(y - (short)((int)size / 2)); /* JT $382: word $10(A6) */
  if (*(short *)(unaff_A5 + -0x137a) == 1) {    /* 1-bit display */
    *(int *)r = *(int *)(src + 0x10);           /* src portRect */
    *(int *)(r + 2) = *(int *)(src + 0x14);
    OffsetRect(r,sx,sy);                        /* $A8A8 */
    CopyBits((void *)(src + 2),(void *)(*(int *)(unaff_A5 + -0x1496) + 2),(void *)(src + 0x10),r,3,0);
                                                /* $A8EC: into the panel port, srcBic, no mask */
  }
  else {
    antialias_downsample_bw_3x(src,sx,sy,h,w,(char *)0x0,
                               *(int *)(unaff_A5 + -0x1fa4),*(short *)(unaff_A5 + -0x1fa6));
                                                /* BSR 0xa3c, LEA $16(A7): the RGBColor at A5-0x1fa6 is pushed
                                                   too (6 bytes) but antialias_downsample_bw_3x never reads it */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID03::FUN_00001538): ID03.bin 0x1538..0x1842 checked against an independent capstone disassembly.
 * LINK -$10; mode 1: BSR 0x2a8(s, s) -> *$18; rect + InsetRect(scale(20)+1); NewRgn/OpenRgn/FrameOval/CloseRgn/SetClip/DisposeRgn;
 * save A5-0x149c, scale = $1e0; rect again; *$1c = (r - l) * 10 / 2, *$24 = *$20 = (r + l) * 10 / 2; *$10 >= 15; restore;
 * *$28 = 1. Else *$c, *$10 x3; BSR 0x2a8(3s+6, 3s+6); SetOrigin(-2,-2); same with x3 and inset +3; *$28 = 3; RTS -
 * identical to the C. */
/*
 * Original: FUN_00001538; source: ID03.c:327.
 * Recovered name: begin_instrument_supersample [STRONG INFERENCE].
 * Body rebuilt as C below (Ghidra truncated both branches). Ten arguments,
 * 0x24 bytes [PROVEN, caller 0x187a]: short *size, short *pa, short *pb, two
 * unused words, GrafPtr *outPort, short *radius, short *centreX, short *centreY,
 * short *factor (pa / pb: the caller's numeral scale and pen width - see
 * draw_altimeter; corrected from "x, y").
 * 1-bit screen (A5-0x137a == 1): outPort = new_offscreen_bw_port(s, s) with
 * s = scale(size); clip to the oval of (0, 0, s, s) inset by scale(20) + 1;
 * then with the scale long A5-0x149e temporarily 480 (scale = v / 10) the same
 * inset rect gives radius = width * 10 / 2 and centreX = centreY =
 * (left + right) * 10 / 2 in design units; *pb is raised to at least 15;
 * factor = 1.
 * Colour: *pa *= 3, *pb *= 3; outPort = new_offscreen_bw_port(3s + 6, 3s + 6);
 * SetOrigin(-2, -2); everything at 3x (inset 3 * scale(20) + 3); no clamp;
 * factor = 3 (consumed later by antialias_downsample_bw_3x).
 * The saved scale is only the low word (A5-0x149c), restored sign-extended
 * [PROVEN, bytes].
 * Callers: instrument drawers (e.g. draw_altimeter).
 */
void begin_instrument_supersample /* Original: FUN_00001538 */
               (short *size,short *pa,short *pb,short unused1,short unused2,int *outPort,
                short *radius,short *centreX,short *centreY,short *factor)

{
  int unaff_A5;
  short w;                                      /* -$10(A6) */
  short savedScale;                             /* -$e(A6): low word of the long scale A5-0x149e */
  int rgn;                                      /* -$c(A6) */
  short r[4];                                   /* -8(A6): top, left, bottom, right */
  short inset;

  if (*(short *)(unaff_A5 + -0x137a) == 1) {    /* 1-bit display: draw at 1x */
    w = (short)scale_design_4800(*size);        /* BSR 0x8a */
    *outPort = new_offscreen_bw_port(w,(short)scale_design_4800(*size)); /* BSR 0x2a8 */
    r[1] = 0;
    r[0] = 0;
    r[2] = (short)scale_design_4800(*size);
    r[3] = (short)scale_design_4800(*size);
    inset = (short)scale_design_4800(0x14);
    InsetRect(r,inset + 1,(short)scale_design_4800(0x14) + 1); /* $A8A9 */
    rgn = NewRgn();                             /* $A8D8 */
    OpenRgn();                                  /* $A8DA */
    FrameOval(r);                               /* $A8B7 */
    CloseRgn(rgn);                              /* $A8DB */
    SetClip(rgn);                               /* $A879: clip to the dial face */
    DisposeRgn(rgn);                            /* $A8D9 */
    savedScale = *(short *)(unaff_A5 + -0x149c);
    *(int *)(unaff_A5 + -0x149e) = 0x1e0;       /* scale = 480: scale_design_4800(v) = v / 10 */
    r[1] = 0;
    r[0] = 0;
    r[2] = (short)scale_design_4800(*size);
    r[3] = (short)scale_design_4800(*size);
    inset = (short)scale_design_4800(0x14);
    InsetRect(r,inset + 1,(short)scale_design_4800(0x14) + 1);
    *radius = (short)((int)(short)((r[3] - r[1]) * 10) / 2); /* back to design units */
    *centreY = (short)((int)(short)((r[3] + r[1]) * 10) / 2);
    *centreX = *centreY;
    if (*pb < 0xf) {
      *pb = 0xf;
    }
    *(int *)(unaff_A5 + -0x149e) = (int)savedScale; /* MOVEA.W: sign-extended low word */
    *factor = 1;
  }
  else {                                        /* colour: draw at 3x for antialias_downsample_bw_3x */
    *pa = *pa * 3;
    *pb = *pb * 3;
    w = (short)scale_design_4800(*size) * 3;
    *outPort = new_offscreen_bw_port(w + 6,(short)scale_design_4800(*size) * 3 + 6);
    SetOrigin(-2,-2);                           /* $A878 */
    r[1] = 0;
    r[0] = 0;
    r[2] = (short)scale_design_4800(*size) * 3;
    r[3] = (short)scale_design_4800(*size) * 3;
    inset = (short)scale_design_4800(0x14) * 3;
    InsetRect(r,inset + 3,(short)scale_design_4800(0x14) * 3 + 3);
    rgn = NewRgn();
    OpenRgn();
    FrameOval(r);
    CloseRgn(rgn);
    SetClip(rgn);
    DisposeRgn(rgn);
    savedScale = *(short *)(unaff_A5 + -0x149c);
    *(int *)(unaff_A5 + -0x149e) = 0x1e0;
    r[1] = 0;
    r[0] = 0;
    r[2] = (short)scale_design_4800(*size) * 3;
    r[3] = (short)scale_design_4800(*size) * 3;
    inset = (short)scale_design_4800(0x14) * 3;
    InsetRect(r,inset + 3,(short)scale_design_4800(0x14) * 3 + 3);
    *radius = (short)((int)(short)((r[3] - r[1]) * 10) / 2);
    *centreY = (short)((int)(short)((r[3] + r[1]) * 10) / 2);
    *centreX = *centreY;
    *(int *)(unaff_A5 + -0x149e) = (int)savedScale;
    *factor = 3;
  }
  return;
}



/* VERIFIED (ID03::FUN_00001844): ID03.bin 0x1844..0x1874 checked against an independent capstone disassembly.
 * SetPort(A5-0x1496); push $10, $e, 0, $c, long 8; BSR 0x146a; LEA $c; BSR 0x33c(port); RTS - identical to the C. */
/* Original: FUN_00001844; source: ID03.c. Recovered name: finish_instrument_supersample [PROVEN].
 * Decoded from ID03.bin bytes at file 0x1844.
 * C args: +8 GrafPtr port, +0xc short size, +0xe short y, +0x10 short x (corrected: they land in composite_instrument_bitmap's y and x slots). SetPort(panel port A5-0x1496) ($A873); composite_instrument_bitmap(port, size, 0, y, x); dispose_offscreen_bw_port(port) (0x33c). Ends the begin_instrument_supersample sequence. Callers: draw_airspeed_indicator (0x1b3c), draw_climb_indicator (0x1fe2), draw_tachometer (0x22f2), draw_manifold_pressure_gauge (0x25f4). Body rebuilt as C below.
 */
void finish_instrument_supersample /* Original: FUN_00001844 */ (int port,short size,short y,short x)

{
  int unaff_A5;

  SetPort(*(int *)(unaff_A5 + -0x1496));        /* $A873: panel port */
  composite_instrument_bitmap(port,size,0,y,x); /* BSR 0x146a: push $10, $e, 0, $c, port */
  dispose_offscreen_bw_port(port);              /* BSR 0x33c */
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x00001910)
// WARNING: Removing unreachable block (ram,0x00001ac0)

/* VERIFIED (ID03::FUN_00001876): ID03.bin 0x1876..0x1b46 checked against an independent capstone disassembly.
 * LINK -$42; BSR 0x1538 (ten args, LEA $24); i 0..19: k = i - 5 (+20), angle ASL #14 / 20; BTST #0 major / minor PenSize and
 * length; four JSR (A5-0x2118 / -0x211c) MULU.L ASR #12 end points; four BSR 0xa6, MoveTo, LineTo; major: numeral radius
 * (MULS #$34 / 10, -$2d), BSR 0x912(n++); TextFont 1; BSR 0x6(20); GetFontInfo; StringWidth / 2; MoveTo; DrawString;
 * BSR 0x1844; RTS - identical to the C. */
/*
 * Original: FUN_00001876; source: ID03.c:379.
 * Recovered name: draw_altimeter [STRONG INFERENCE].
 * Instrument type 0 of draw_instrument. Body rebuilt as C below (Ghidra
 * truncated). Words: size [8], scale [$a], pen [$c], y [$e], x [$10].
 * Bytes 0x1876..0x1b46 [PROVEN]: begin_instrument_supersample(&size, &scale,
 * &pen, y, x, &port, &radius, &cx, &cy, &factor) - so the helper's pa / pb are
 * the numeral scale and the pen width; one 20-pass loop (corrected: not "loops
 * of 12 steps" plus a separate label loop): tick slot k = i - 5 (mod 20),
 * angle = k * 0x4000 / 20; even i = major tick (PenSize(pen/10), length
 * 3 * scale) with numeral n++ (0..9) by draw_vector_number at radius
 * - scale * 52 / 10 - length - 45; odd i = minor tick (PenSize(2 * pen / 30),
 * length 2 * scale); end points from cos A5-0x2118 / sin A5-0x211c (4.12);
 * TextFont(1) $A887, set_scaled_text_style(20), GetFontInfo $A88B; label
 * string = long A5-0xe42 = STR# 129 slot 65 (A5-0xf46 + 65*4), centred on
 * scale(cx) at scale(cy - factor * 100) + ascent with StringWidth $A88C,
 * MoveTo, DrawString $A884; finish_instrument_supersample(port, size, y, x).
 * Label text [PROVEN from resource dump]: slot 65 = "\pALTITUDE"
 * (artifacts/reverse-engineering/resources/resource_dasm_Hellcats_app,
 * file index 64; files are 0-based, game slots 1-based - calibrated with
 * slot 93 = "Out of memory.  Sorry" used by ID02 fatal_memory_error_exit).
 * Hence the altimeter gauge [STRONG INFERENCE].
 */
void draw_altimeter /* Original: FUN_00001876 */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$3e(A6): FontInfo, ascent first */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1e(A6) */
  int angle;                                    /* -$1a(A6): 1/0x4000 turn */
  short radius;                                 /* -$16(A6) */
  short y2;                                     /* -$14(A6) */
  short x2;                                     /* -$12(A6) */
  short y1;                                     /* -$10(A6) */
  short x1;                                     /* -$e(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short n;                                      /* -8(A6): next numeral */
  short factor;                                 /* -6(A6): 1 or 3 */
  short k;                                      /* -4(A6): tick slot, then tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  n = 0;
  for (i = 0; i < 0x14; i = i + 1) {            /* 20 ticks */
    k = i + -5;                                 /* tick 0 at the top: start 5 slots back */
    if (k < 0) {
      k = k + 0x14;
    }
    angle = ((int)k << 0xe) / 0x14;             /* ASL.L #8, ASL.L #6, DIVS.L #20 */
    if ((i & 1) == 0) {                         /* BTST #0: major tick */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale * 3;
    }
    else {                                      /* minor tick */
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    /* cos A5-0x2118 / sin A5-0x211c take a long angle and return 4.12; products are MULU.L, ASR.L #12 */
    x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
    if ((i & 1) == 0) {                         /* numeral inside each major tick */
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      draw_vector_number(n,scale,x1,y1);        /* BSR 0x912: 0..9 */
      n = n + 1;
    }
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x14);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe42); /* STR# 129 slot 65 "ALTITUDE" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100) + fi[0]);
  DrawString(label);                            /* $A884 */
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



/* VERIFIED (ID03::FUN_00001b48): ID03.bin 0x1b48..0x1fec checked against an independent capstone disassembly.
 * LINK -$42; BSR 0x1538; i 0..159: k = i - 40 (+160), angle ASL #14 / 160; DIVS #10 / #5 remainders and CMPI #20 select
 * PenSize and length or skip; tick end points via A5-0x2118 / -0x211c and four BSR 0xa6; PenSize(pen/10); every 10th: value
 * 0 / 40 / i + 40, < 100 -> /10 and BSR 0x912(scale), else %20 == 0 -> BSR 0x912(scale * 8 / 10); labels slots 66 / 67
 * with TextFont 1, BSR 0x6(18), GetFontInfo, StringWidth; BSR 0x1844; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/*
 * Original: FUN_00001b48; source: ID03.c:394.
 * Recovered name: draw_airspeed_indicator [STRONG INFERENCE].
 * Instrument type 1 of draw_instrument. Label strings loaded from the
 * STR# 129 pointer table (A5-0xf46 + 4*slot): slot 66 "AIR" + 67 "SPEED" [PROVEN from
 * the resource dump, 0-based files, slot n = file n-1]. Gauge identity from
 * the label [STRONG INFERENCE]. Body rebuilt as C below [PROVEN, bytes
 * 0x1b48..0x1fec]: same argument and begin/finish pattern as draw_altimeter;
 * 160 slots (k = i - 40 mod 160, angle = k * 0x4000 / 160): every 10th a long
 * tick (PenSize(15 * pen / 100), length 5 * scale), every 5th a medium tick
 * (pen / 10, 3 * scale), the rest short ticks (2 * pen / 30, 2 * scale) but only
 * from slot 20 on. Every 10th slot carries a numeral for the value 0 (i = 0),
 * 40 (i = 10) or i + 40: below 100 the tens digit (0, 4, 6, 7, 8, 9) at the
 * numeral scale; 100..180 in steps of 20 in full at 8/10 of it; 110, 130,
 * 150, 170, 190 are unlabelled. "AIR" at scale(cy - factor * 100) (no ascent
 * added) and "SPEED" one ascent + descent lower, both centred on scale(cx),
 * font 1, text size 18.
 */
void draw_airspeed_indicator /* Original: FUN_00001b48 */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$3e(A6): FontInfo (ascent, descent, ...) */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1e(A6) */
  int angle;                                    /* -$1a(A6): 1/0x4000 turn */
  short radius;                                 /* -$16(A6) */
  short y2;                                     /* -$14(A6) */
  short x2;                                     /* -$12(A6) */
  short y1;                                     /* -$10(A6) */
  short x1;                                     /* -$e(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short factor;                                 /* -8(A6) */
  short num;                                    /* -6(A6) */
  short k;                                      /* -4(A6): tick slot, then tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 0xa0; i = i + 1) {            /* 160 slots */
    k = i + -0x28;                              /* slot 0 a quarter turn back */
    if (k < 0) {
      k = k + 0xa0;
    }
    angle = ((int)k << 0xe) / 0xa0;             /* ASL.L #14, DIVS.L #160 */
    if (i % 10 == 0) {                          /* DIVS.W #10, SWAP: remainder */
      PenSize((short)((int)(short)(pen * 0xf) / 100),(short)((int)(short)(pen * 0xf) / 100)); /* $A89B */
      k = scale * 5;
    }
    else if (i % 5 == 0) {
      PenSize((short)((int)pen / 10),(short)((int)pen / 10));
      k = scale * 3;
    }
    else {
      if (i < 0x14) continue;                   /* no fine ticks in the first 20 slots */
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
    x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
    PenSize((short)((int)pen / 10),(short)((int)pen / 10));
    if (i % 10 != 0) continue;
    if (i == 0) {                               /* dial value: 0, then 40, then i + 40 */
      num = 0;
    }
    else if (i == 10) {
      num = 0x28;
    }
    else {
      num = i + 0x28;
    }
    if (num < 100) {
      num = (short)((int)num / 10);             /* tens only: 0, 4, 6, 7, 8, 9 */
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      draw_vector_number(num,scale,x1,y1);      /* BSR 0x912 */
    }
    else if (num % 0x14 == 0) {                 /* 100, 120, 140, 160, 180 in full, smaller */
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      draw_vector_number(num,(short)((int)(short)(scale << 3) / 10),x1,y1); /* ASL.W #3, DIVS.W #10 */
    }
  }
  PenSize((short)((int)pen / 10),(short)((int)pen / 10));
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x12);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe3e); /* STR# 129 slot 66 "AIR" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100)); /* top line: no ascent added */
  DrawString(label);                            /* $A884 */
  label = *(unsigned char **)(unaff_A5 + -0xe3a); /* slot 67 "SPEED" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2);
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100) + fi[0] + fi[1]); /* + ascent + descent */
  DrawString(label);
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID03::FUN_00001fee): ID03.bin 0x1fee..0x22fc checked against an independent capstone disassembly.
 * Same frame and calls as 0x1876 with: i 0..38, angle ASL #14 / 39; DIVS #3 remainder selects major (ASL.W #2 length) or
 * minor (skipped for 18..21 by CMPI #$12 / #$15); x via SUBA.L (cx - r cos), y via ADD.L; numeral i/3 or 13 - i/3 when
 * i/3 > 6; label A5-0xe36; RTS - identical to the C. */
/*
 * Original: FUN_00001fee; source: ID03.c:427.
 * Recovered name: draw_climb_indicator [STRONG INFERENCE].
 * Instrument type 3 of draw_instrument. Label strings loaded from the
 * STR# 129 pointer table (A5-0xf46 + 4*slot): slot 68 "CLIMB" [PROVEN from
 * the resource dump, 0-based files, slot n = file n-1]. Gauge identity from
 * the label [STRONG INFERENCE]. Body rebuilt as C below [PROVEN, bytes
 * 0x1fee..0x22fc]: the draw_altimeter pattern with 39 slots (angle =
 * i * 0x4000 / 39, no offset); every 3rd slot a major tick (pen / 10, length
 * 4 * scale) with a numeral i / 3 for 0..6, then 13 - i / 3 (6, 5, ... 1) on the
 * way back round; minor ticks (2 * pen / 30, 2 * scale) except slots 18..21;
 * x is mirrored (cx - r * cos), so the scale runs the other way round from the
 * altimeter; "CLIMB" label as on the altimeter (font 1, size 20, + ascent).
 */
void draw_climb_indicator /* Original: FUN_00001fee */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$3e(A6): FontInfo, ascent first */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1e(A6) */
  int angle;                                    /* -$1a(A6): 1/0x4000 turn */
  short radius;                                 /* -$16(A6) */
  short y2;                                     /* -$14(A6) */
  short x2;                                     /* -$12(A6) */
  short y1;                                     /* -$10(A6) */
  short x1;                                     /* -$e(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short factor;                                 /* -8(A6) */
  short num;                                    /* -6(A6) */
  short k;                                      /* -4(A6): tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 0x27; i = i + 1) {            /* 39 slots round the dial, no offset */
    angle = ((int)i << 0xe) / 0x27;             /* ASL.L #14, DIVS.L #39 */
    if (i % 3 == 0) {                           /* major tick */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale << 2;                           /* ASL.W #2 */
    }
    else {
      if ((0x11 < i) && (i < 0x16)) continue;   /* no minor ticks in slots 18..21 */
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    /* x is mirrored: cx - r * cos (SUBA.L), y as usual: cy + r * sin */
    x1 = (short)((int)cx - ((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    x2 = (short)((int)cx - ((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
    if (i % 3 == 0) {                           /* numeral at each major tick */
      x1 = (short)((int)cx - ((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(scale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      if (6 < (short)((int)i / 3)) {
        num = 0xd - (short)((int)i / 3);        /* 6, 5, ..., 1 coming back round */
      }
      else {
        num = (short)((int)i / 3);              /* 0..6 */
      }
      draw_vector_number(num,scale,x1,y1);      /* BSR 0x912 */
    }
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x14);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe36); /* STR# 129 slot 68 "CLIMB" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100) + fi[0]);
  DrawString(label);                            /* $A884 */
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000023a2)
// WARNING: Removing unreachable block (ram,0x00002578)

/* VERIFIED (ID03::FUN_000022fe): ID03.bin 0x22fe..0x25fe checked against an independent capstone disassembly.
 * Same frame and calls as 0x1876 shifted by two bytes (LINK -$44) with: i 0..27, k = 2i - 40 (+60), angle ASL #14 / 60;
 * DIVS #3 remainder major (ASL.W #2) / minor; numeral scale MULS #3 DIVS #3, value MULS #10 DIVS #6; label A5-0xe32 at
 * cy - factor * $53; RTS - identical to the C. */
/*
 * Original: FUN_000022fe; source: ID03.c:458.
 * Recovered name: draw_tachometer [STRONG INFERENCE].
 * Instrument type 5 of draw_instrument. Label strings loaded from the
 * STR# 129 pointer table (A5-0xf46 + 4*slot): slot 69 "RPM" [PROVEN from
 * the resource dump, 0-based files, slot n = file n-1]. Gauge identity from
 * the label [STRONG INFERENCE]. Body rebuilt as C below [PROVEN, bytes
 * 0x22fe..0x25fe]: the draw_altimeter pattern with 28 ticks two slots apart
 * on a 60-slot dial (k = 2i - 40 mod 60, angle = k * 0x4000 / 60); every 3rd a
 * major tick (pen / 10, length 4 * scale) numbered i * 10 / 6 = 0, 5, ... 45
 * (hundreds of RPM [HYPOTHESIS]); minor ticks (2 * pen / 30, 2 * scale);
 * "RPM" label at scale(cy - factor * 83) + ascent, font 1, size 20.
 */
void draw_tachometer /* Original: FUN_000022fe */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$40(A6): FontInfo, ascent first */
  int port;                                     /* -$34(A6) */
  unsigned char *label;                         /* -$20(A6) */
  int angle;                                    /* -$1c(A6): 1/0x4000 turn */
  short radius;                                 /* -$18(A6) */
  short y2;                                     /* -$16(A6) */
  short x2;                                     /* -$14(A6) */
  short y1;                                     /* -$12(A6) */
  short x1;                                     /* -$10(A6) */
  short cy;                                     /* -$e(A6) */
  short cx;                                     /* -$c(A6) */
  short factor;                                 /* -$a(A6) */
  short num;                                    /* -8(A6) */
  short nscale;                                 /* -6(A6) */
  short k;                                      /* -4(A6): tick slot, then tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 0x1c; i = i + 1) {            /* 28 ticks, two slots apart on a 60-slot dial */
    k = i * 2 + -0x28;
    if (k < 0) {
      k = k + 0x3c;
    }
    angle = ((int)k << 0xe) / 0x3c;             /* ASL.L #14, DIVS.L #60 */
    if (i % 3 == 0) {                           /* major tick */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale << 2;
    }
    else {                                      /* minor tick */
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
    x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
    if (i % 3 == 0) {
      nscale = (short)((int)(short)(scale * 3) / 3); /* MULS #3, DIVS #3: the plain scale */
      num = (short)((int)(short)(i * 10) / 6);  /* 0, 5, 10, ... 45 */
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      draw_vector_number(num,nscale,x1,y1);     /* BSR 0x912 */
    }
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x14);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe32); /* STR# 129 slot 69 "RPM" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 0x53) + fi[0]); /* 83, not 100 */
  DrawString(label);                            /* $A884 */
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID03::FUN_00002600): ID03.bin 0x2600..0x294e checked against an independent capstone disassembly.
 * Same frame and calls as 0x22fe with: i 0..68, k = i - 40 (+69), angle ASL #14 / 69; (i - 3) DIVS #5 remainder major,
 * CMPI #3 BLT skip, else minor; (i - 3) DIVS #10 remainder -> numeral scale = scale, value i + 7; BSR 0x6(16); labels
 * A5-0xe2e / -0xe2a (second + ascent + descent); RTS - identical to the C. */
/*
 * Original: FUN_00002600; source: ID03.c:473.
 * Recovered name: draw_manifold_pressure_gauge [STRONG INFERENCE].
 * Instrument type 4 of draw_instrument. Label strings loaded from the
 * STR# 129 pointer table (A5-0xf46 + 4*slot): slot 70 "Manifold" + 71 "Pressure" [PROVEN from
 * the resource dump, 0-based files, slot n = file n-1]. Gauge identity from
 * the label [STRONG INFERENCE]. Body rebuilt as C below [PROVEN, bytes
 * 0x2600..0x294e]: the draw_tachometer frame with 69 slots (k = i - 40 mod 69,
 * angle = k * 0x4000 / 69); a major tick (pen / 10, length 4 * scale) where
 * (i - 3) % 5 == 0, minor ticks (2 * pen / 30, 2 * scale) from i = 3 on; a
 * numeral i + 7 = 10, 20, ... 70 where (i - 3) % 10 == 0 (inches of mercury
 * [HYPOTHESIS]); "Manifold" at scale(cy - factor * 100) (no ascent) and
 * "Pressure" one ascent + descent lower, font 1, text size 16.
 */
void draw_manifold_pressure_gauge /* Original: FUN_00002600 */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$40(A6): FontInfo (ascent, descent, ...) */
  int port;                                     /* -$34(A6) */
  unsigned char *label;                         /* -$20(A6) */
  int angle;                                    /* -$1c(A6): 1/0x4000 turn */
  short radius;                                 /* -$18(A6) */
  short y2;                                     /* -$16(A6) */
  short x2;                                     /* -$14(A6) */
  short y1;                                     /* -$12(A6) */
  short x1;                                     /* -$10(A6) */
  short cy;                                     /* -$e(A6) */
  short cx;                                     /* -$c(A6) */
  short factor;                                 /* -$a(A6) */
  short num;                                    /* -8(A6) */
  short nscale;                                 /* -6(A6) */
  short k;                                      /* -4(A6): tick slot, then tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 0x45; i = i + 1) {            /* 69 slots */
    k = i + -0x28;
    if (k < 0) {
      k = k + 0x45;
    }
    angle = ((int)k << 0xe) / 0x45;             /* ASL.L #14, DIVS.L #69 */
    if ((short)(i - 3) % 5 == 0) {              /* SUBQ #3, EXT.L, DIVS.W #5: major tick */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale << 2;
    }
    else {
      if (i < 3) continue;                      /* nothing before the first major tick */
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
    x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
    if ((short)(i - 3) % 10 == 0) {             /* every other major tick */
      nscale = scale;
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      num = i + 7;                              /* 10, 20, ... 70 */
      draw_vector_number(num,nscale,x1,y1);     /* BSR 0x912 */
    }
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x10);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe2e); /* STR# 129 slot 70 "Manifold" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100)); /* top line: no ascent added */
  DrawString(label);                            /* $A884 */
  label = *(unsigned char **)(unaff_A5 + -0xe2a); /* slot 71 "Pressure" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2);
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100) + fi[0] + fi[1]); /* + ascent + descent */
  DrawString(label);
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000029f4)
// WARNING: Removing unreachable block (ram,0x00002c94)

/* VERIFIED (ID03::FUN_00002950): ID03.bin 0x2950..0x2d1a checked against an independent capstone disassembly.
 * Same frame and calls as 0x22fe with: i 0..35, k = i - 9 (+36), angle ASL #14 / 36; DIVS #3 major (MULS #3) / minor;
 * DIVS #9 remainder 0 -> string A5-0x1ee6 / -4 / -2 / -0 by CMPI #0 / #9 / #$12 / #$1b, numeral position, BSR 0x77e (LEA $a);
 * else DIVS #3 remainder 0 -> 2 * scale / 3, value i, position, no call; BSR 0x6(18); label A5-0xe26; RTS - identical to
 * the C. */
/*
 * Original: FUN_00002950; source: ID03.c:504.
 * Recovered name: draw_direction_indicator [STRONG INFERENCE].
 * Instrument type 6 of draw_instrument. Label strings loaded from the
 * STR# 129 pointer table (A5-0xf46 + 4*slot): slot 72 "DIRECTION" [PROVEN from
 * the resource dump, 0-based files, slot n = file n-1]. Gauge identity from
 * the label [STRONG INFERENCE]. Body rebuilt as C below [PROVEN, bytes
 * 0x2950..0x2d1a]: the draw_tachometer frame with 36 ticks (k = i - 9 mod 36,
 * angle = k * 0x4000 / 36: 10 degrees each, tick 0 at the top); every 3rd a
 * major tick (pen / 10, length 3 * scale), the rest minor (2 * pen / 30,
 * 2 * scale). At i = 0, 9, 18, 27 the 2-byte string at A5-0x1ee6 / -0x1ee4 /
 * -0x1ee2 / -0x1ee0 is drawn with draw_vector_glyph_string_centred (0x77e)
 * at the numeral radius - the cardinal letters [STRONG INFERENCE: N E S W].
 * At the other major ticks the code computes a numeral scale (2 * scale / 3),
 * value (i) and position but draws nothing [PROVEN: no call follows].
 * "DIRECTION" label at scale(cy - factor * 100) + ascent, font 1, size 18.
 */
void draw_direction_indicator /* Original: FUN_00002950 */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$40(A6): FontInfo, ascent first */
  int port;                                     /* -$34(A6) */
  char *text;                                   /* -$20(A6): cardinal letter, later the label */
  int angle;                                    /* -$1c(A6): 1/0x4000 turn */
  short radius;                                 /* -$18(A6) */
  short y2;                                     /* -$16(A6) */
  short x2;                                     /* -$14(A6) */
  short y1;                                     /* -$12(A6) */
  short x1;                                     /* -$10(A6) */
  short cy;                                     /* -$e(A6) */
  short cx;                                     /* -$c(A6) */
  short factor;                                 /* -$a(A6) */
  short num;                                    /* -8(A6) */
  short nscale;                                 /* -6(A6) */
  short k;                                      /* -4(A6): tick slot, then tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 0x24; i = i + 1) {            /* 36 ticks, 10 degrees apart */
    k = i + -9;                                 /* tick 0 (north) at the top */
    if (k < 0) {
      k = k + 0x24;
    }
    angle = ((int)k << 0xe) / 0x24;             /* ASL.L #14, DIVS.L #36 */
    if (i % 3 == 0) {                           /* major tick every 30 degrees */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale * 3;
    }
    else {
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
    x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
    if (i % 9 == 0) {                           /* the four cardinal points */
      nscale = scale;
      if (i == 0) {
        text = (char *)(unaff_A5 + -0x1ee6);    /* 2-byte strings at A5-0x1ee6 .. -0x1ee0 [glyph data: A5 initial data] */
      }
      if (i == 9) {
        text = (char *)(unaff_A5 + -0x1ee4);
      }
      if (i == 0x12) {
        text = (char *)(unaff_A5 + -0x1ee2);
      }
      if (i == 0x1b) {
        text = (char *)(unaff_A5 + -0x1ee0);
      }
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
      draw_vector_glyph_string_centred(text,nscale,x1,y1); /* BSR 0x77e */
    }
    else if (i % 3 == 0) {                      /* other major ticks: a numeral is set up but never drawn */
      nscale = (short)((int)(short)(scale * 2) / 3);
      num = i;
      x1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
      y1 = (short)(((int)(short)((radius - (short)((int)(short)(nscale * 0x34) / 10)) - k) + -0x2d) *
                   (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    }
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x12);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  text = *(char **)(unaff_A5 + -0xe26);         /* STR# 129 slot 72 "DIRECTION" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth((unsigned char *)text) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100) + fi[0]);
  DrawString((unsigned char *)text);            /* $A884 */
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID03::FUN_00002d1c): ID03.bin 0x2d1c..0x32b6 checked against an independent capstone disassembly.
 * LINK -$bc; BSR 0x1538; PenSize(pen/10); two point loops (EXTB pairs MULS scale, MULS #12 records at -$b8), JSR
 * (A5-0x105e)(0, 0, $555 / $3aaa, 3 / 10, pts, pts) LEA $18, draw loops (LEA -$96 / +$96, SUBA + $6e, BSR 0xa6, MoveTo for
 * i = 0 else LineTo); four BSR 0x8a, PaintRect; length scale * 3; marks at $2d55 / $32aa via A5-0x2118 / -0x211c; labels
 * A5-0xe22 (cy - factor * $85) / -0xe1e (factor * $11 + cy); BSR 0x1844; RTS - identical to the C. */
/*
 * Original: FUN_00002d1c; source: ID03.c:519.
 * Recovered name: draw_turn_and_bank_indicator [STRONG INFERENCE].
 * Instrument type 2 of draw_instrument. Label strings loaded from the
 * STR# 129 pointer table (A5-0xf46 + 4*slot): slot 73 "TURN" + 74 "BANK" [PROVEN from
 * the resource dump, 0-based files, slot n = file n-1]. Gauge identity from
 * the label [STRONG INFERENCE]. Body rebuilt as C below [PROVEN, bytes
 * 0x2d1c..0x32b6]: begin_instrument_supersample; PenSize(pen / 10); two
 * outlines built from signed (dx, dy) byte pairs times scale around
 * (0, numeral radius): 3 points from A5-0x1fa0 and 10 points from A5-0x1f9a,
 * each rotated in place through the host pointer A5-0x105e
 * (rotate_int3_vecs_by_3ang, overlay 0x28a6) with angles (0, 0, 0x555 = +30
 * deg) and (0, 0, 0x3aaa = -30 deg) and drawn as a polyline at x = cx + px -
 * 150 and x = cx + px + 150, y = cy - py + 110 (the z field of the 12-byte
 * records is never initialised). Then PaintRect of (cy - radius, cx - 60,
 * cy - radius + 60, cx + 90) scaled, and two radial marks of length 3 * scale
 * at angles 0x2d55 and 0x32aa (about 255 and 285 degrees). "TURN" at
 * scale(cy - factor * 133) + ascent and "BANK" at scale(cy + factor * 17)
 * + ascent, font 1, text size 18. Point data are A5 initial data, not read.
 */
void draw_turn_and_bank_indicator /* Original: FUN_00002d1c */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  int pts[10][3];                               /* -$b8(A6): 12-byte int3 records */
  short fi[4];                                  /* -$40(A6): FontInfo, ascent first */
  int port;                                     /* -$34(A6) */
  short r[4];                                   /* -$28(A6): top, left, bottom, right */
  unsigned char *label;                         /* -$20(A6) */
  int angle;                                    /* -$1c(A6) */
  short radius;                                 /* -$18(A6) */
  short y2;                                     /* -$16(A6) */
  short x2;                                     /* -$14(A6) */
  short y1;                                     /* -$12(A6) */
  short x1;                                     /* -$10(A6) */
  short cy;                                     /* -$e(A6) */
  short cx;                                     /* -$c(A6) */
  short factor;                                 /* -$a(A6) */
  short k;                                      /* -4(A6): tick length */
  short i;                                      /* -2(A6) */
  short sx;

  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
  x1 = 0;                                       /* -$10(A6) reused as x origin */
  y1 = (radius - (short)((int)(short)(scale * 0x34) / 10)) + -0x2d; /* numeral radius */
  for (i = 0; i < 3; i = i + 1) {              /* outline 1: 3 (dx, dy) byte pairs at A5-0x1fa0, rotated +30 deg, drawn left of centre */
    pts[i][0] = (int)(short)((short)*(char *)(unaff_A5 + -0x1fa0 + (int)i * 2) * scale + x1);
    pts[i][1] = (int)(short)((short)*(char *)(unaff_A5 + -0x1fa0 + 1 + (int)i * 2) * scale + y1);
  }                                            /* pts[i][2] is never set (stack contents) */
  (*(code **)(unaff_A5 + -0x105e))(0,0,0x555,3,pts,pts); /* rotate_int3_vecs_by_3ang (overlay 0x28a6) */
  for (i = 0; i < 3; i = i + 1) {
    x1 = scale_design_4800_pen_centred((short)((int)cx + pts[i][0] + -0x96)); /* BSR 0xa6 */
    y1 = scale_design_4800_pen_centred((short)(((int)cy - pts[i][1]) + 0x6e));
    if (i == 0) {
      MoveTo(x1,y1);                            /* $A893 */
    }
    else {
      LineTo(x1,y1);                            /* $A891 */
    }
  }
  x1 = 0;                                       /* -$10(A6) reused as x origin */
  y1 = (radius - (short)((int)(short)(scale * 0x34) / 10)) + -0x2d; /* numeral radius */
  for (i = 0; i < 10; i = i + 1) {              /* outline 2: 10 pairs at A5-0x1f9a, rotated -30 deg, drawn right of centre */
    pts[i][0] = (int)(short)((short)*(char *)(unaff_A5 + -0x1f9a + (int)i * 2) * scale + x1);
    pts[i][1] = (int)(short)((short)*(char *)(unaff_A5 + -0x1f9a + 1 + (int)i * 2) * scale + y1);
  }                                            /* pts[i][2] is never set (stack contents) */
  (*(code **)(unaff_A5 + -0x105e))(0,0,0x3aaa,10,pts,pts); /* rotate_int3_vecs_by_3ang (overlay 0x28a6) */
  for (i = 0; i < 10; i = i + 1) {
    x1 = scale_design_4800_pen_centred((short)((int)cx + pts[i][0] + 0x96)); /* BSR 0xa6 */
    y1 = scale_design_4800_pen_centred((short)(((int)cy - pts[i][1]) + 0x6e));
    if (i == 0) {
      MoveTo(x1,y1);                            /* $A893 */
    }
    else {
      LineTo(x1,y1);                            /* $A891 */
    }
  }
  r[0] = (short)scale_design_4800(cy - radius); /* BSR 0x8a */
  r[1] = (short)scale_design_4800(cx + -0x3c);
  r[2] = (short)scale_design_4800((cy - radius) + 0x3c);
  r[3] = (short)scale_design_4800(cx + 0x5a);
  PaintRect(r);                                 /* $A8A2 */
  k = scale * 3;
  angle = 0x2d55;
  x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
  y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
  x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
  y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
  sx = scale_design_4800_pen_centred(x1);
  MoveTo(sx,scale_design_4800_pen_centred(y1));
  sx = scale_design_4800_pen_centred(x2);
  LineTo(sx,scale_design_4800_pen_centred(y2));
  angle = 0x32aa;
  x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
  y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
  x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx);
  y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
  sx = scale_design_4800_pen_centred(x1);
  MoveTo(sx,scale_design_4800_pen_centred(y1));
  sx = scale_design_4800_pen_centred(x2);
  LineTo(sx,scale_design_4800_pen_centred(y2));
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x12);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe22); /* STR# 129 slot 73 "TURN" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 0x85) + fi[0]);
  DrawString(label);                            /* $A884 */
  label = *(unsigned char **)(unaff_A5 + -0xe1e); /* slot 74 "BANK" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2);
  MoveTo(sx,(short)scale_design_4800(factor * 0x11 + cy) + fi[0]); /* below the centre */
  DrawString(label);
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



/* VERIFIED (ID03::FUN_000032b8): ID03.bin 0x32b8..0x3830 checked against an independent capstone disassembly.
 * LINK -$54; PenSize 1; rect via JT $3ca / $382 / BSR 0x8a; InsetRect(scale 70, scale 180); two lubber lines; grey; FrameRect;
 * A5-0x11ee..-0x11e2 window record; TST $12 BEQ exit; f 1 / 3; BSR 0x2a8; SetPort; SetOrigin(-2,-2) at f 3; numeral scale
 * (MULU.L A5-0x149e / 480); scale long 480; x0 (*10 / $48), A5-0x11e0, three y values; i 0..35 PenSize select, MULU.L chain
 * / 360, two BSR 0xa6 pairs to $7fff, every 3rd BSR 0x912(36 - i); restore scale; rowBytes; JT $26a x2, $272 x2; JT $402;
 * PaintRect; CopyBits or BSR 0xa3c; JT $27a x2; SetPort; BSR 0x33c; JT $392; RTS - identical to the C. */
/* Original: FUN_000032b8; source: ID03.c. Recovered name: draw_gyro_instrument [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x32b8.
 * Instrument type 8 of draw_instrument (called with $a, $c, $e, $10, $12 and 1). Uses the handles A5-0x11dc and A5-0x11d4 (HLock / HUnlock through ID09 JT $26a / $272 / $27a), which ID03 0x5ba6..0x5bea saves with AddResource (HEL2, id base A5-0x13ae + 400 / 500) under the names STR# 129 slot 81 "GyroInstrument" and slot 82 "GyroFlags" [PROVEN]. Draws scale lines with design_x_to_screen / design_y_to_screen (JT $3ca / $382) and scale_design_4800, renders into a black-and-white port (new_offscreen_bw_port 0x2a8, SetOrigin), uses ID02 JT $402 (file 0xca6), PaintRect and CopyBits ($A8EC), then antialias_downsample_bw_3x (0xa3c) and dispose_offscreen_bw_port (0x33c) [PROVEN calls]. Body rebuilt as C below [PROVEN, bytes 0x32b8..0x3830]. Args: size, scale, pen, y, x, render. Always: a window rect (the bezel inset by scale(70) x scale(180)) framed in grey with lubber marks of scale(40) above and below at x, and the window record A5-0x11ee top / -0x11ec left / -0x11ea width / -0x11e8 height / -0x11e6 = 3/4 height / -0x11e2 tape height / -0x11e4 tape width = 9 window widths. If render != 0: a 1x or 3x (1-bit mode or not) offscreen port; 36 vertical marks 10 degrees apart at x = x0 + tapeWidth * i * f * 100 / 360 (x0 = tapeWidth * f * 10 / 72; A5-0x11e0 = scale(x0) / f), long major / thin minor, each major numbered 0, 33, 30, ... 3 (36 - i, tens of degrees) with draw_vector_number; then ReallocHandle ($A027 via ID09 0x264) "GyroInstrument" to height * rowBytes and "GyroFlags" to the tape width, a colour port on the first (new_offscreen_cport, rowBytes | 0x8000) painted black and the tape copied in (CopyBits srcBic at 1-bit) or antialiased (antialias_downsample_bw_3x with the flags as its drawn-column output). So this is the directional gyro: a horizontally scrolling heading tape [STRONG INFERENCE from the 0..33 numbering].
 */
void draw_gyro_instrument /* Original: FUN_000032b8 */
               (short size,short scale,short pen,short y,short x,short render)

{
  int unaff_A5;
  short f;                                      /* -$52(A6): 1 (1-bit) or 3 (supersampled) */
  short rowBytes;                               /* -$50(A6) */
  short yTop;                                   /* -$4c(A6): tick top in the tape */
  short yNum;                                   /* -$4e(A6): numeral line */
  short yUnused;                                /* -$4a(A6): written, never read */
  short x0;                                     /* -$48(A6): tape x of heading 0 */
  int cport;                                    /* -$3e(A6) */
  int savedPort;                                /* -$3a(A6) */
  int port;                                     /* -$36(A6) */
  short r[4];                                   /* -$26(A6): top, left, bottom, right */
  short tx;                                     /* -$e(A6) */
  short t;                                      /* -4(A6): numeral scale, then saved scale word */
  short i;                                      /* -2(A6) */
  short sx;

  PenSize(1,1);                                 /* $A89B */
  r[1] = (short)design_x_to_screen(x - (short)((int)size / 2)); /* JT $3ca */
  r[0] = (short)design_y_to_screen(y - (short)((int)size / 2)); /* JT $382 */
  r[3] = (short)scale_design_4800(size) + r[1]; /* BSR 0x8a */
  r[2] = (short)scale_design_4800(size) + r[0];
  sx = (short)scale_design_4800(0x46);
  InsetRect(r,sx,(short)scale_design_4800(0xb4)); /* $A8A9: a window narrower than the bezel */
  MoveTo((short)design_x_to_screen(x),r[0]);    /* lubber marks above and below the window */
  LineTo((short)design_x_to_screen(x),(short)scale_design_4800(0x28) + r[0]);
  MoveTo((short)design_x_to_screen(x),r[2] + -1);
  LineTo((short)design_x_to_screen(x),(r[2] - (short)scale_design_4800(0x28)) + -1);
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2)); /* JT $45a, JT $36a: grey */
  PenSize((short)((int)pen / 10),(short)((int)pen / 10));
  FrameRect(r);                                 /* $A8A1 */
  /* tape window record for the panel animation */
  *(short *)(unaff_A5 + -0x11ec) = r[1] + 1;    /* left */
  *(short *)(unaff_A5 + -0x11ea) = (r[3] - *(short *)(unaff_A5 + -0x11ec)) + -1; /* width */
  *(short *)(unaff_A5 + -0x11ee) = (short)scale_design_4800(0x32) + r[0]; /* top */
  *(short *)(unaff_A5 + -0x11e8) = (r[2] - (short)scale_design_4800(0x32)) - *(short *)(unaff_A5 + -0x11ee); /* height */
  *(short *)(unaff_A5 + -0x11e6) = (short)((int)(short)(*(short *)(unaff_A5 + -0x11e8) * 3) / 4);
  *(short *)(unaff_A5 + -0x11e2) = *(short *)(unaff_A5 + -0x11e8); /* tape height */
  *(short *)(unaff_A5 + -0x11e4) = *(short *)(unaff_A5 + -0x11ea) * 9; /* tape width: 9 windows */
  if (render == 0) {
    return;
  }
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    f = 1;
  }
  else {
    f = 3;
  }
  savedPort = *(int *)(unaff_A5 + -0x160c);     /* thePort */
  port = new_offscreen_bw_port(*(short *)(unaff_A5 + -0x11e4) * f + 4,*(short *)(unaff_A5 + -0x11e2) * f + 4); /* BSR 0x2a8 */
  SetPort(port);                                /* $A873 */
  if (f == 3) {
    SetOrigin(-2,-2);                           /* $A878 */
  }
  t = (short)((int)((unsigned int)(int)(short)(scale * f) * *(unsigned int *)(unaff_A5 + -0x149e)) / 0x1e0);
  if (t != 0) {
    scale = t;                                  /* numeral scale in tape pixels */
  }
  pen = pen * f;
  t = *(short *)(unaff_A5 + -0x149c);           /* low word of the scale long */
  *(int *)(unaff_A5 + -0x149e) = 0x1e0;
  x0 = (short)((int)((unsigned int)(int)(short)(*(short *)(unaff_A5 + -0x11e4) * f) * 10) / 0x48);
  *(short *)(unaff_A5 + -0x11e0) = (short)((int)(short)scale_design_4800(x0) / (int)f); /* EXT.L, DIVS.W f */
  yUnused = (short)((int)((unsigned int)(int)(short)(*(short *)(unaff_A5 + -0x11e2) * f) * 10) / 2);
  yNum = (short)((int)((unsigned int)(int)(short)(*(short *)(unaff_A5 + -0x11e2) * f) * 0x1e) / 8);
  yTop = (short)((int)((unsigned int)(int)(short)(*(short *)(unaff_A5 + -0x11e2) * f) * 0x1e) / 4);
  for (i = 0; i < 0x24; i = i + 1) {            /* 36 marks, 10 degrees apart */
    if ((i % 3 == 0) || (f == 1)) {
      PenSize((short)((int)pen / 10),(short)((int)pen / 10));
    }
    else {
      PenSize((short)((int)(short)(pen * 2) / (int)(short)(f * 10)),
              (short)((int)(short)(pen * 2) / (int)(short)(f * 10)));
    }
    tx = (short)((int)(((unsigned int)(int)*(short *)(unaff_A5 + -0x11e4) * (int)i) * (int)f * 100) / 0x168 + (int)x0);           /* MULU.L chain, DIVS.L #360 */
    sx = scale_design_4800_pen_centred(tx);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(yTop)); /* $A893 */
    sx = scale_design_4800_pen_centred(tx);
    LineTo(sx,scale_design_4800_pen_centred(0x7fff)); /* $A891: to the bottom edge */
    if (i % 3 == 0) {
      tx = (short)((int)(((unsigned int)(int)*(short *)(unaff_A5 + -0x11e4) * (int)i) * (int)f * 100) / 0x168 + (int)x0);
      draw_vector_number((i == 0) ? 0 : 0x24 - i,scale,tx,yNum); /* BSR 0x912: 0, 33, 30, ... 3 (tens of degrees) */
    }
  }
  *(int *)(unaff_A5 + -0x149e) = (int)t;        /* MOVEA.W: sign-extended */
  rowBytes = (short)(((int)((unsigned int)(int)*(short *)(unaff_A5 + -0x137a) *
                           (unsigned int)(int)*(short *)(unaff_A5 + -0x11e4)) + 0xf >> 4) * 2);
  *(short *)(unaff_A5 + -0x11de) = rowBytes | 0x8000; /* PixMap rowBytes flag */
  ReallocHandle(*(int *)(unaff_A5 + -0x11dc),(int)*(short *)(unaff_A5 + -0x11e2) * (int)rowBytes);
                                                /* JT $26a (ID09 0x264, $A027): "GyroInstrument" */
  ReallocHandle(*(int *)(unaff_A5 + -0x11d4),(int)*(short *)(unaff_A5 + -0x11e4)); /* "GyroFlags" */
  HLock(*(int *)(unaff_A5 + -0x11dc));          /* JT $272 */
  HLock(*(int *)(unaff_A5 + -0x11d4));
  r[0] = 0;
  r[1] = 0;
  r[3] = *(short *)(unaff_A5 + -0x11e4);
  r[2] = *(short *)(unaff_A5 + -0x11e2);
  cport = new_offscreen_cport(rowBytes | 0x8000,**(int **)(unaff_A5 + -0x11dc),r); /* JT $402 (ID02 0xca6), Rect by value */
  SetPort(cport);
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* black */
  PaintRect(r);                                 /* $A8A2 */
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    CopyBits((void *)(port + 2),(void *)(cport + 2),(void *)(port + 0x10),(void *)(port + 0x10),3,0); /* $A8EC: srcBic */
  }
  else {
    antialias_downsample_bw_3x(port,0,0,*(short *)(unaff_A5 + -0x11e2),*(short *)(unaff_A5 + -0x11e4),
                               **(char ***)(unaff_A5 + -0x11d4)); /* BSR 0xa3c: flags = drawn columns */
  }
  HUnlock(*(int *)(unaff_A5 + -0x11dc));        /* JT $27a */
  HUnlock(*(int *)(unaff_A5 + -0x11d4));
  SetPort(savedPort);
  dispose_offscreen_bw_port(port);              /* BSR 0x33c */
  close_and_dispose_port(cport);                /* JT $392 (ID02 0xd24) */
  return;
}



/* VERIFIED (ID03::FUN_00003832): ID03.bin 0x3832..0x38fa checked against an independent capstone disassembly.
 * LINK -6; PenSize(1,1); left / top via JT $3ca / $382 + 1; right / bottom = BSR 0x8a(size) + left / top - 2; InsetRect(scale 50,
 * scale 50); NewRgn, OpenRgn, FrameOval, CloseRgn; D0 = rgn; RTS - identical to the C. */
/* Original: FUN_00003832; source: ID03.c. Recovered name: make_inset_face_oval_region [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x3832.
 * C args: +8 Rect *r (out), +0xc short size, +0xe short y, +0x10 short x (design units). PenSize(1, 1); r = screen square from design_x_to_screen(x - size/2) + 1, design_y_to_screen(y - size/2) + 1, side scale_design_4800(size) - 2; InsetRect(r, scale(50), scale(50)); rgn = NewRgn ($A8D8); OpenRgn ($A8DA); FrameOval(r) ($A8B7); CloseRgn(rgn) ($A8DB); returns rgn [PROVEN, bytes 0x3832..0x38fa]: the oval of the instrument face inside the bezel. Caller: draw_artificial_horizon (0x3996). Body rebuilt as C below.
 */
int make_inset_face_oval_region /* Original: FUN_00003832 */ (short *r,short size,short y,short x)

{
  int rgn;                                      /* -4(A6) */
  short inset;                                  /* -6(A6) */

  PenSize(1,1);                                 /* $A89B */
  r[1] = (short)design_x_to_screen(x - (short)((int)size / 2)) + 1; /* JT $3ca: left */
  r[0] = (short)design_y_to_screen(y - (short)((int)size / 2)) + 1; /* JT $382: top */
  r[3] = ((short)scale_design_4800(size) + r[1]) + -2; /* BSR 0x8a: right */
  r[2] = ((short)scale_design_4800(size) + r[0]) + -2; /* bottom */
  inset = (short)scale_design_4800(0x32);
  InsetRect(r,inset,(short)scale_design_4800(0x32)); /* $A8A9 */
  rgn = NewRgn();                               /* $A8D8 */
  OpenRgn();                                    /* $A8DA */
  FrameOval(r);                                 /* $A8B7 */
  CloseRgn(rgn);                                /* $A8DB */
  return rgn;
}



/* VERIFIED (ID03::FUN_000038fc): ID03.bin 0x38fc..0x3c00 checked against an independent capstone disassembly.
 * LINK -$2c; PenSize 1; rect +1 / -2; ring oval region; BSR 0x3832; DiffRgn; NewRgn, GetClip, SetClip(ring); w = (pen + 5)
 * / 10 min 1; rr = size/2 + w*10; (4,4,4); h = w/2 + 1; i 0..6 angle ASL #13 / 6, cos add / sin SUBA, MoveTo / LineTo via
 * JT $3ca / $382 minus h; SetClip(saved); A5-0x1200..-0x11fc; TST $12; JT $26a(height * 4); row loop with two PtInRgn
 * scans, equal-bump, two word stores; three DisposeRgn; RTS - identical to the C. */
/* Original: FUN_000038fc; source: ID03.c. Recovered name: draw_artificial_horizon [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x38fc.
 * Instrument type 9 of draw_instrument. Body rebuilt as C below [PROVEN, bytes 0x38fc..0x3c00]. Args: size, an unused word, pen, y, x, render. ring = oval of the bezel square minus the face oval of make_inset_face_oval_region (DiffRgn $A8E6; the call also insets r to the face); clipped to that annulus (GetClip / SetClip), pen (pen + 5) / 10 (at least 1), colour level (4, 4, 4): seven rays at 0, 30, ... 180 degrees (angle i * 0x2000 / 6) from beyond the bezel to the centre - only their parts on the bezel show, the bank marks of the upper half (corrected: 7 rays, not an 8-step loop, and no rotated horizon line is drawn here). Restores the clip; stores the face rect at A5-0x1202 top / -0x1200 left / -0x11fe width / -0x11fc height. If render != 0: ReallocHandle (via ID09 0x264) of A5-0x11f6 "HorizonInstrument" [PROVEN name] to height * 4 and, for each face row, scans out from the centre with PtInRgn ($A8E8) to store the inside span (left, right) as two words: the per-row mask the panel animation fills with sky and ground [STRONG INFERENCE]. Interpreted as the artificial horizon [STRONG INFERENCE from the resource name].
 */
void draw_artificial_horizon /* Original: FUN_000038fc */
               (short size,short unused,short pen,short y,short x,short render)

{
  int unaff_A5;
  short pt[2];                                  /* -$2c(A6): Point v, h */
  int savedClip;                                /* -$28(A6) */
  int face;                                     /* -$24(A6) */
  int ring;                                     /* -$20(A6) */
  short r[4];                                   /* -$1c(A6): top, left, bottom, right */
  int angle;                                    /* -$14(A6) */
  short ex;                                     /* -$e(A6) */
  short ey;                                     /* -$10(A6) */
  short w;                                      /* -$c(A6) */
  short rr;                                     /* -$a(A6) */
  short xr;                                     /* -8(A6) */
  short xl;                                     /* -6(A6) */
  short h;                                      /* -4(A6) */
  short i;                                      /* -2(A6): ray, then row */
  short sx;

  PenSize(1,1);                                 /* $A89B */
  r[1] = (short)design_x_to_screen(x - (short)((int)size / 2)) + 1; /* JT $3ca */
  r[0] = (short)design_y_to_screen(y - (short)((int)size / 2)) + 1; /* JT $382 */
  r[3] = ((short)scale_design_4800(size) + r[1]) + -2; /* BSR 0x8a */
  r[2] = ((short)scale_design_4800(size) + r[0]) + -2;
  ring = NewRgn();                              /* $A8D8 */
  OpenRgn();                                    /* $A8DA */
  FrameOval(r);                                 /* $A8B7 */
  CloseRgn(ring);                               /* $A8DB */
  face = make_inset_face_oval_region(r,size,y,x); /* BSR 0x3832: also insets r to the face */
  DiffRgn(ring,face,ring);                      /* $A8E6: ring = bezel annulus */
  savedClip = NewRgn();
  GetClip(savedClip);                           /* $A87A */
  SetClip(ring);                                /* $A879 */
  w = (short)((int)(short)(pen + 5) / 10);
  if (w == 0) {
    w = 1;
  }
  PenSize(w,w);
  rr = (short)((int)size / 2) + w * 10;         /* beyond the bezel: the clip cuts the rays to marks */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(4,4,4)); /* JT $45a, JT $36a */
  h = (short)((int)w / 2) + 1;
  for (i = 0; i < 7; i = i + 1) {               /* rays 0, 30, ... 180 degrees: the upper half */
    angle = ((int)i << 0xd) / 6;                /* ASL.L #7, ASL.L #6, DIVS.L #6: 0x2000 = half a turn */
    ex = (short)(((int)rr * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)x); /* cos, 4.12 */
    ey = (short)((int)y - ((int)rr * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc)); /* y - r sin */
    sx = (short)design_x_to_screen(ex) - h;
    MoveTo(sx,(short)design_y_to_screen(ey) - h); /* $A893 */
    sx = (short)design_x_to_screen(x) - h;
    LineTo(sx,(short)design_y_to_screen(y) - h); /* $A891: to the centre */
  }
  SetClip(savedClip);
  *(short *)(unaff_A5 + -0x1200) = r[1];        /* face rect record for the panel animation */
  *(short *)(unaff_A5 + -0x1202) = r[0];
  *(short *)(unaff_A5 + -0x11fe) = r[3] - r[1];
  *(short *)(unaff_A5 + -0x11fc) = r[2] - r[0];
  if (render != 0) {
    ReallocHandle(*(int *)(unaff_A5 + -0x11f6),(int)*(short *)(unaff_A5 + -0x11fc) * 4);
                                                /* JT $26a (ID09 0x264, $A027): "HorizonInstrument" */
    for (i = r[0]; i < r[2]; i = i + 1) {       /* one span per face row */
      xr = (short)((int)(short)(r[1] + r[3]) / 2);
      xl = xr;
      pt[0] = i;
      do {
        xl = xl + -1;
        pt[1] = xl;
      } while (PtInRgn(*(int *)pt,face) != 0);  /* $A8E8 */
      xl = xl + 1;                              /* first point inside on the left */
      do {
        xr = xr + 1;
        pt[1] = xr;
      } while (PtInRgn(*(int *)pt,face) != 0);  /* first point outside on the right */
      if (xl == xr) {
        xr = xr + 1;
      }
      *(short *)(**(int **)(unaff_A5 + -0x11f6) + (int)(short)(i - r[0]) * 4) = xl;
      *(short *)(**(int **)(unaff_A5 + -0x11f6) + (int)(short)(i - r[0]) * 4 + 2) = xr;
    }
  }
  DisposeRgn(face);                             /* $A8D9 */
  DisposeRgn(ring);
  DisposeRgn(savedClip);
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID03::FUN_00003c02): ID03.bin 0x3c02..0x3f22 checked against an independent capstone disassembly.
 * LINK -$a; CMPI #6 -> BSR 0x514 with $1b else $f (LEA $a); (4,4,4) JT $45a/$36a; JT $3a table 0..9 -> 0x1876, 0x1b48,
 * 0x2d1c, 0x1fee, 0x2600, 0x22fe, 0x2950, -, 0x32b8(.., 1), 0x38fc(.., 1); record ASL.L #4 + A5-0x12a2: +$e, +$c, +$a, +8,
 * +2, +0, +4, +6 in that order; RTS - identical to the C. */
/*
 * Original: FUN_00003c02; source: ID03.c:567.
 * Recovered name: draw_instrument [STRONG INFERENCE].
 * Ghidra mis-decoded the inline switch table after JSR $3a(A5) as code (the
 * pbVar1 |= 0x50 and |= 0x8a00c6 statements are table bytes, not behaviour).
 * Body rebuilt as C below [PROVEN, bytes 0x3c02..0x3f22].
 * Args: words type [8], size [$a], scale [$c], pen [$e], y [$10], x [$12].
 *   draw_ring_with_status_indicators(size, pen, y, x, flags) with flags
 *     0x1b if type == 6, else 0x0f   (bezel + corner screws, see below);
 *   colour (4,4,4) via lookup_palette_index_for_rgb_level / set_draw_color_index;
 *   switch (type) [ID01 switch helper, 0..9, table parsed by script]:
 *     0 -> draw_altimeter (FUN_00001876)
 *     1 -> draw_airspeed_indicator (FUN_00001b48)
 *     2 -> draw_turn_and_bank_indicator (FUN_00002d1c)
 *     3 -> draw_climb_indicator (FUN_00001fee)
 *     4 -> draw_manifold_pressure_gauge (FUN_00002600)
 *     5 -> draw_tachometer (FUN_000022fe)
 *     6 -> draw_direction_indicator (FUN_00002950)
 *     7 -> (none)         8 -> FUN_000032b8(..., 1)
 *     9 -> FUN_000038fc(..., 1)       (each called with $a, $c, $e, $10, $12);
 *   then fills the 16-byte record A5-0x12a2 + type * 16 in screen pixels:
 *   +0 top, +2 left, +4 width, +6 height (of the design square), +8 display
 *   mode A5-0x137a, +$a centre h, +$c centre v, +$e face radius
 *   (scale(size) / 2 - scale(50)) [PROVEN, bytes 0x3da2..0x3f20]; the panel
 *   cache stores ten such records (prepare_instrument_panel).
 * [HYPOTHESIS] Cockpit instrument panel: one drawing routine per gauge type.
 */
void draw_instrument /* Original: FUN_00003c02 */ (short type,short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short *rec;                                   /* -8(A6): A5-0x12a2 + type * 16, recomputed per field */
  short half;                                   /* -$a(A6) */

  if (type == 6) {
    draw_ring_with_status_indicators(size,pen,y,x,0x1b); /* BSR 0x514: direction indicator, 4 screws + bottom */
  }
  else {
    draw_ring_with_status_indicators(size,pen,y,x,0xf);  /* 4 corner screws */
  }
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(4,4,4)); /* JT $45a, JT $36a */
  switch (type) {                               /* JT $3a (ID01 0xbe, range table at 0x3c6a, 0..9) */
  case 0:
    draw_altimeter(size,scale,pen,y,x);         /* BSR 0x1876 */
    break;
  case 1:
    draw_airspeed_indicator(size,scale,pen,y,x); /* BSR 0x1b48 */
    break;
  case 2:
    draw_turn_and_bank_indicator(size,scale,pen,y,x); /* BSR 0x2d1c */
    break;
  case 3:
    draw_climb_indicator(size,scale,pen,y,x);   /* BSR 0x1fee */
    break;
  case 4:
    draw_manifold_pressure_gauge(size,scale,pen,y,x); /* BSR 0x2600 */
    break;
  case 5:
    draw_tachometer(size,scale,pen,y,x);        /* BSR 0x22fe */
    break;
  case 6:
    draw_direction_indicator(size,scale,pen,y,x); /* BSR 0x2950 */
    break;
  case 8:
    draw_gyro_instrument(size,scale,pen,y,x,1); /* BSR 0x32b8 */
    break;
  case 9:
    draw_artificial_horizon(size,scale,pen,y,x,1); /* BSR 0x38fc */
    break;
  }                                             /* 7 and out of range: nothing */
  /* instrument record (16 bytes) at A5-0x12a2 + type * 16, in screen pixels */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  half = (short)((int)(short)scale_design_4800(size) / 2); /* BSR 0x8a, EXT.L, DIVS.W #2 */
  rec[7] = half - (short)scale_design_4800(0x32); /* +$e: face radius */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  rec[6] = (short)design_y_to_screen(y);        /* +$c: centre v (JT $382) */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  rec[5] = (short)design_x_to_screen(x);        /* +$a: centre h (JT $3ca) */
  ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10))[4] = *(short *)(unaff_A5 + -0x137a); /* +8: display mode */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  rec[1] = (short)design_x_to_screen(x - (short)((int)size / 2)); /* +2: left */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  rec[0] = (short)design_y_to_screen(y - (short)((int)size / 2)); /* +0: top */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  rec[2] = (short)design_x_to_screen((short)((int)size / 2) + x) - ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10))[1]; /* +4: width */
  rec = ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10));
  rec[3] = (short)design_y_to_screen((short)((int)size / 2) + y) - ((short *)(unaff_A5 + -0x12a2 + (int)type * 0x10))[0]; /* +6: height */
  return;
}



/* VERIFIED (ID03::FUN_00003f24): ID03.bin 0x3f24..0x410e checked against an independent capstone disassembly.
 * LINK -4; four OpenPoly / MoveTo / 4 LineTo / ClosePoly / fill / KillPoly blocks: colours (1 / 0), (1 / 0), (3 / 4) with JT $3e2
 * + FillPoly, then (2) with PaintPoly; vertices (h, v) = ($8,$a) ($14,$a) ($10,$e) ($c,$e); ($8,$a) ($c,$e) ($c,$12) ($8,$16);
 * ($8,$16) ($14,$16) ($10,$12) ($c,$12); ($14,$a) ($10,$e) ($10,$12) ($14,$16); RTS - identical to the C. */
/* Original: FUN_00003f24; source: ID03.c. Recovered name: draw_bevelled_frame [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x3f24.
 * C args: eight shorts at +8..+0x16 = outer left, outer top, inner left, inner top, inner right, inner bottom, outer right, outer bottom (screen coordinates; corrected from the MoveTo / LineTo push order, h first). Draws four quadrilateral polygons between the outer and inner rectangles (OpenPoly $A8CB, MoveTo / LineTo, ClosePoly $A8CC, KillPoly $A8CD after each) [PROVEN, bytes 0x3f24..0x410e]: top band and left band with fore level 1 / back level 0 and FillPoly ($A8CA) with get_blended_fill_pattern (JT $3e2, ID02 0x150a); bottom band with fore 3 / back 4, same fill; right band PaintPoly ($A8C7) in level 2. Body rebuilt as C below. The side shading gives a raised / sunken 3-D bevel [STRONG INFERENCE]. Callers: draw_numbered_bevel_box (0x41de), FUN_00004304 (0x465e).
 */
void draw_bevelled_frame /* Original: FUN_00003f24 */
               (short oL,short oT,short iL,short iT,short iR,short iB,short oR,short oB)

{
  int unaff_A5;
  int poly;                                     /* -4(A6) */

  set_draw_color_index((short)lookup_palette_index_for_rgb_level(1,1,1)); /* JT $45a, JT $36a */
  set_back_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $3a2 */
  poly = OpenPoly();                            /* $A8CB: top band */
  MoveTo(oL,oT);                          /* $A893 */
  LineTo(oR,oT);
  LineTo(iR,iT);
  LineTo(iL,iT);
  LineTo(oL,oT);
  ClosePoly();                                  /* $A8CC */
  FillPoly(poly,get_blended_fill_pattern());    /* JT $3e2 (ID02 0x150a), $A8CA */
  KillPoly(poly);                               /* $A8CD */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(1,1,1));
  set_back_color_index((short)lookup_palette_index_for_rgb_level(0,0,0));
  poly = OpenPoly();                            /* left band */
  MoveTo(oL,oT);                          /* $A893 */
  LineTo(iL,iT);
  LineTo(iL,iB);
  LineTo(oL,oB);
  LineTo(oL,oT);
  ClosePoly();                                  /* $A8CC */
  FillPoly(poly,get_blended_fill_pattern());    /* JT $3e2 (ID02 0x150a), $A8CA */
  KillPoly(poly);                               /* $A8CD */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(3,3,3));
  set_back_color_index((short)lookup_palette_index_for_rgb_level(4,4,4));
  poly = OpenPoly();                            /* bottom band */
  MoveTo(oL,oB);                          /* $A893 */
  LineTo(oR,oB);
  LineTo(iR,iB);
  LineTo(iL,iB);
  LineTo(oL,oB);
  ClosePoly();                                  /* $A8CC */
  FillPoly(poly,get_blended_fill_pattern());    /* JT $3e2 (ID02 0x150a), $A8CA */
  KillPoly(poly);                               /* $A8CD */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2));
  poly = OpenPoly();                            /* right band */
  MoveTo(oR,oT);                          /* $A893 */
  LineTo(iR,iT);
  LineTo(iR,iB);
  LineTo(oR,oB);
  LineTo(oR,oT);
  ClosePoly();                                  /* $A8CC */
  PaintPoly(poly);                              /* $A8C7: solid */
  KillPoly(poly);                               /* $A8CD */
  return;
}



/* VERIFIED (ID03::FUN_00004110): ID03.bin 0x4110..0x4302 checked against an independent capstone disassembly.
 * LINK -$22, save D3; b = JT $3ca(20) - JT $3ca(0); rect copies; black; inner rect; PaintRect; BSR 0x3f24 with eight words;
 * *r = inner; level 4 / 3 by A5-0x137a; w, h; cx = w/2 + right, cy = h/2 + top; MULU.L 10 * scale / 480 min 1; BSR 0x56(12)
 * min 10, PenSize / 10; BSR 0x912(number, nscale, cx * 4800 / scale, cy * 4800 / scale); RTS - identical to the C. */
/* Original: FUN_00004110; source: ID03.c. Recovered name: draw_numbered_bevel_box [PROVEN].
 * Decoded from ID03.bin bytes at file 0x4110.
 * C args: +8 Rect *r (in / out), +0xc short number. bevel = design_x_to_screen(20) - design_x_to_screen(0); inner = r inset by bevel; PaintRect(inner) in colour level 0 (black); draw_bevelled_frame(r, inner); *r = inner; colour level 4 at depth 1, else 3; numeral scale = max(1, 10 * A5-0x149e / 480); PenSize = max(10, scale_design_480_min10(12)) / 10; draw_vector_number(number, numeral scale, cx, cy) with the centre converted back to design units (c * 4800 / A5-0x149e), where cy = top + h / 2 but cx = right + w / 2 of the outer rect (as coded; left + w / 2 would be the centre) [PROVEN, bytes 0x4110..0x4302]. draw_bevelled_frame is called with (left, top, left + b, top + b, right - b, bottom - b, right, bottom), confirming its corrected argument order. Body rebuilt as C below. Draws a black box with a bevelled border and a vector-font number in it. Callers: FUN_00004304 (0x46b6, 0x4718, 0x477a; rects A5-0x11c6, -0x11be, -0x11b6).
 */
void draw_numbered_bevel_box /* Original: FUN_00004110 */ (short *r,short number)

{
  int unaff_A5;
  short sz;                                     /* -$22(A6): pen size * 10 */
  short nscale;                                 /* -$20(A6) */
  short cy;                                     /* -$1e(A6) */
  short cx;                                     /* -$1c(A6) */
  short h;                                      /* -$1a(A6) */
  short w;                                      /* -$18(A6) */
  short bottom;                                 /* -$16(A6) */
  short right;                                  /* -$14(A6) */
  short top;                                    /* -$12(A6) */
  short left;                                   /* -$10(A6): first the x of design 20 */
  short b;                                      /* -$e(A6): bevel width */
  short inner[4];                               /* -8(A6): top, left, bottom, right */

  left = (short)design_x_to_screen(0x14);       /* JT $3ca */
  b = left - (short)design_x_to_screen(0);
  left = r[1];
  top = r[0];
  right = r[3];
  bottom = r[2];
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $45a, JT $36a: black */
  inner[1] = left + b;
  inner[0] = top + b;
  inner[3] = right - b;
  inner[2] = bottom - b;
  PaintRect(inner);                             /* $A8A2 */
  draw_bevelled_frame(left,top,left + b,top + b,right - b,bottom - b,right,bottom); /* BSR 0x3f24 */
  *(int *)r = *(int *)inner;                    /* *r = inner */
  *(int *)(r + 2) = *(int *)(inner + 2);
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(4,4,4));
  }
  else {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(3,3,3));
  }
  w = right - left;
  h = bottom - top;
  cx = (short)((int)w / 2) + right;             /* right + w / 2 as coded (not left + w / 2) */
  cy = (short)((int)h / 2) + top;
  nscale = (short)((int)((unsigned int)10 * *(unsigned int *)(unaff_A5 + -0x149e)) / 0x1e0); /* MULU.L, DIVS.L #480 */
  if (nscale < 1) {
    nscale = 1;
  }
  sz = scale_design_480_min10(0xc);             /* BSR 0x56 */
  if (sz < 10) {
    sz = 10;
  }
  PenSize((short)((int)sz / 10),(short)((int)sz / 10)); /* $A89B */
  draw_vector_number(number,nscale,
                     (short)((int)((unsigned int)(int)cx * 0x12c0) / *(int *)(unaff_A5 + -0x149e)),
                     (short)((int)((unsigned int)(int)cy * 0x12c0) / *(int *)(unaff_A5 + -0x149e)));
                                                /* BSR 0x912: centre back in design units (* 4800 / scale) */
  return;                                       /* D3 saved and restored */
}



/* VERIFIED (ID03::FUN_00004304): ID03.bin 0x4304..0x478e checked against an independent capstone disassembly.
 * LINK -$18; black; rect (-400, 750, 400, 1560) PaintRect; depth 1 / 4 black else (0,1,0); InsetRect 2,2; PaintRect; A5-0x11aa,
 * A5-0x11a0 / -0x119e (-10, 1150), A5-0x11c8 = depth; (2,2,2) / (0,2,0); PenSize 1; loops i = -27..-1, -1..25 (+1 px),
 * -26..0, 0..26 (+1 px) step 13; BSR 0x3f24 with eight converted coordinates; three SetRect + BSR 0x4110(1 / 3 / 15) + copy to
 * A5-0x11c6 / -0x11be / -0x11b6; RTS - identical to the C. */
/* Original: FUN_00004304; source: ID03.c. Recovered name: draw_panel_section_with_numbered_boxes [STRONG INFERENCE mechanics].
 * Decoded from ID03.bin bytes at file 0x4304.
 * No arguments. Caller: the panel redraw path of prepare_instrument_panel (0x67fa, after A5-0x2114 = 40). PaintRect of the design rect (-400, 750)-(400, 1560) in colour level 0, then (depth 1 or 4: level 0, else level (0, 1, 0)) InsetRect(2, 2) and PaintRect again; the inset rect -> A5-0x11aa; design point (-10, 1150) -> A5-0x11a0 / -0x119e; A5-0x11c8 = depth A5-0x137a; then (colour level (2, 2, 2) at depth 1, else (0, 2, 0)) PenSize(1, 1) and four 3-line loops (corrected: counters step by 13, not 26 single steps): vertical lines at design x = -270, -140, -10 and x = -10, 120, 250 drawn one pixel further right, horizontal lines at y = 890, 1020, 1150 and 1150, 1280, 1410 drawn one pixel lower - a 4 x 4 grid centred on (-10, 1150), the centre doubled; draw_bevelled_frame from (-430, 720)-(430, 1590) around (-400, 750)-(400, 1560); finally three draw_numbered_bevel_box boxes stacked at design x 490..610, y 720..840, 900..1020, 1080..1200 (SetRect $A8A7) with the numbers 1, 3 and 15, their inner rects stored at A5-0x11c6, -0x11be, -0x11b6 [PROVEN, bytes 0x4304..0x478e]. A dark-green screen with a green grid and a stored centre point suggests a radar / range display, the numbered boxes being its range settings [HYPOTHESIS]; draw_numbered_bevel_box places each number half a box to the right of its box (see there). Body rebuilt as C below.
 */
void draw_panel_section_with_numbered_boxes /* Original: FUN_00004304 */ (void)

{
  int unaff_A5;
  short r[4];                                   /* -$a(A6): top, left, bottom, right */
  short i;                                      /* -2(A6) */
  short a;                                      /* -$c(A6) */
  short b;                                      /* -$e(A6) */
  short c;                                      /* -$10(A6) */
  short d;                                      /* -$12(A6) */
  short e;                                      /* -$14(A6) */
  short f;                                      /* -$16(A6) */
  short g;                                      /* -$18(A6) */

  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $45a, JT $36a */
  r[1] = (short)design_x_to_screen(-400);                    /* JT $3ca */
  r[0] = (short)design_y_to_screen(0x2ee);                   /* JT $382: 750 */
  r[3] = (short)design_x_to_screen(400);
  r[2] = (short)design_y_to_screen(0x618);                   /* 1560 */
  PaintRect(r);                                 /* $A8A2 */
  if ((*(short *)(unaff_A5 + -0x137a) == 1) || (*(short *)(unaff_A5 + -0x137a) == 4)) {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0));
  }
  else {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,1,0)); /* dark green */
  }
  InsetRect(r,2,2);                             /* $A8A9 */
  PaintRect(r);
  *(int *)(unaff_A5 + -0x11aa) = *(int *)r;     /* screen rect */
  *(int *)(unaff_A5 + -0x11a6) = *(int *)(r + 2);
  *(short *)(unaff_A5 + -0x11a0) = (short)design_x_to_screen(-10);   /* centre h */
  *(short *)(unaff_A5 + -0x119e) = (short)design_y_to_screen(0x47e); /* centre v: 1150 */
  *(short *)(unaff_A5 + -0x11c8) = *(short *)(unaff_A5 + -0x137a);
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2));
  }
  else {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,2,0)); /* green grid */
  }
  PenSize(1,1);                                 /* $A89B */
  for (i = -0x1b; i < 0; i = i + 0xd) {          /* x = -270, -140, -10 */
    a = (short)design_x_to_screen(i * 10);
    MoveTo(a,(short)design_y_to_screen(0x2ee) + 2);       /* $A893 */
    a = (short)design_x_to_screen(i * 10);
    LineTo(a,(short)design_y_to_screen(0x618) + -3);      /* $A891 */
  }
  for (i = -1; i < 0x1a; i = i + 0xd) {          /* x = -10, 120, 250, one pixel right */
    a = (short)design_x_to_screen(i * 10);
    MoveTo(a + 1,(short)design_y_to_screen(0x2ee) + 2);
    a = (short)design_x_to_screen(i * 10);
    LineTo(a + 1,(short)design_y_to_screen(0x618) + -3);
  }
  for (i = -0x1a; i < 1; i = i + 0xd) {          /* y = 890, 1020, 1150 */
    a = (short)design_x_to_screen(-400);
    MoveTo(a + 2,(short)design_y_to_screen(i * 10 + 0x47e));
    a = (short)design_x_to_screen(400);
    LineTo(a + -3,(short)design_y_to_screen(i * 10 + 0x47e));
  }
  for (i = 0; i < 0x1b; i = i + 0xd) {           /* y = 1150, 1280, 1410, one pixel lower */
    a = (short)design_x_to_screen(-400);
    MoveTo(a + 2,(short)design_y_to_screen(i * 10 + 0x47e) + 1);
    a = (short)design_x_to_screen(400);
    LineTo(a + -3,(short)design_y_to_screen(i * 10 + 0x47e) + 1);
  }
  a = (short)design_x_to_screen(-0x1ae);                             /* outer -430 */
  b = (short)design_y_to_screen(0x2d0);                              /* 720 */
  c = (short)design_x_to_screen(-400);
  d = (short)design_y_to_screen(0x2ee);
  e = (short)design_x_to_screen(400);
  f = (short)design_y_to_screen(0x618);
  g = (short)design_x_to_screen(0x1ae);                              /* 430 */
  draw_bevelled_frame(a,b,c,d,e,f,g,(short)design_y_to_screen(0x636)); /* BSR 0x3f24: outer bottom 1590 */
  a = (short)design_x_to_screen(0x1ea);                             /* 490 */
  b = (short)design_y_to_screen(0x2d0);
  c = (short)design_x_to_screen(0x262);                             /* 610 */
  SetRect(r,a,b,c,(short)design_y_to_screen(0x348));               /* $A8A7 */
  draw_numbered_bevel_box(r,1);               /* BSR 0x4110 */
  *(int *)(unaff_A5 + -0x11c6) = *(int *)r;      /* inner rect */
  *(int *)(unaff_A5 + -0x11c6 + 4) = *(int *)(r + 2);
  a = (short)design_x_to_screen(0x1ea);                             /* 490 */
  b = (short)design_y_to_screen(0x384);
  c = (short)design_x_to_screen(0x262);                             /* 610 */
  SetRect(r,a,b,c,(short)design_y_to_screen(0x3fc));               /* $A8A7 */
  draw_numbered_bevel_box(r,3);               /* BSR 0x4110 */
  *(int *)(unaff_A5 + -0x11be) = *(int *)r;      /* inner rect */
  *(int *)(unaff_A5 + -0x11be + 4) = *(int *)(r + 2);
  a = (short)design_x_to_screen(0x1ea);                             /* 490 */
  b = (short)design_y_to_screen(0x438);
  c = (short)design_x_to_screen(0x262);                             /* 610 */
  SetRect(r,a,b,c,(short)design_y_to_screen(0x4b0));               /* $A8A7 */
  draw_numbered_bevel_box(r,0xf);               /* BSR 0x4110 */
  *(int *)(unaff_A5 + -0x11b6) = *(int *)r;      /* inner rect */
  *(int *)(unaff_A5 + -0x11b6 + 4) = *(int *)(r + 2);
  return;
}



/* VERIFIED (ID03::FUN_00004790): ID03.bin 0x4790..0x4b30 checked against an independent capstone disassembly.
 * LINK -$2a; nw = nscale * 3 * 6, lw = nw + $aa; PenSize; box via JT $3ca / $382 / BSR 0x8a; PaintRect black; FrameRect level 3 / 2;
 * x -= 20; bar rect, FrameRect; tx0 / tx1 / ty / barh; i 0..9 ticks (MULS barh * i, DIVS #9); BSR 0x2a8(3w'+4, 3h'+4);
 * SetPort; SetOrigin(-2,-2); nscale and pen x3; PenSize(2pen/30); BSR 0x912(100) / (0); SetPort(A5-0x1496); BSR 0xa3c;
 * BSR 0x33c; InsetRect(bar, 1, 1) -> A5-0x1186; RTS - identical to the C. */
/* Original: FUN_00004790; source: ID03.c. Recovered name: draw_percent_scale_gauge [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x4790.
 * Caller: the panel redraw path of prepare_instrument_panel (0x681e) with design arguments (0x14a, 0x258, 7, scale_design_480_min10(10), 0x794, 0x898). Args: w, h, numeral scale, pen, y, x (design units). Body rebuilt as C below [PROVEN, bytes 0x4790..0x4b30]: box (x - w/2, y - h/2) of scale(w) x scale(h), PaintRect black and FrameRect ($A8A1) in level 3 (depth 1) or 2; x -= 20; a 60-unit bar (left = x + lw/2 - 60 with label width lw = 18 * nscale + 170, from y - h/2 + 30 to y + h/2 - 30) framed; ten ticks from x + lw/2 - 140 (i = 0 and 9) or 30 units further in, to x + lw/2 - 90, at bar height * i / 9 above the bottom; then a 3x port (new_offscreen_bw_port 0x2a8, SetOrigin(-2, -2)), numeral scale * (3 * A5-0x149e / 480), pen * 3, the numbers 100 (y 210) and 0 (y 3h - 210) at x = 3w/2 - 3lw/2 + 270 (draw_vector_number 0x912), SetPort(panel A5-0x1496), antialias_downsample_bw_3x (0xa3c) onto the box, dispose (0x33c); the bar inset by 1 is stored at A5-0x1186. A vertical 0-100 percentage scale; which control it shows (throttle?) is open [HYPOTHESIS].
 */
void draw_percent_scale_gauge /* Original: FUN_00004790 */
               (short w,short h,short nscale,short pen,short y,short x)

{
  int unaff_A5;
  short barh;                                   /* -$28(A6) */
  short v;                                      /* -$26(A6) */
  short sx;                                     /* -$24(A6) */
  short tx1;                                    /* -$20(A6) */
  short ty;                                     /* -$1e(A6) */
  short tx0;                                    /* -$1c(A6) */
  int port;                                     /* -$1a(A6) */
  short lw;                                     /* -$16(A6): label width */
  short nw;                                     /* -$14(A6) */
  short bar[4];                                 /* -$12(A6): top, left, bottom, right */
  short box[4];                                 /* -$a(A6) */
  short i;                                      /* -2(A6) */
  short a;

  nw = nscale * 3 * 6;
  lw = nw + 0xaa;
  PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
  box[1] = (short)design_x_to_screen(x - (short)((int)w / 2)); /* JT $3ca */
  box[0] = (short)design_y_to_screen(y - (short)((int)h / 2)); /* JT $382 */
  box[3] = (short)scale_design_4800(w) + box[1]; /* BSR 0x8a */
  box[2] = (short)scale_design_4800(h) + box[0];
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $45a, JT $36a */
  PaintRect(box);                               /* $A8A2 */
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(3,3,3));
  }
  else {
    set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2));
  }
  FrameRect(box);                               /* $A8A1 */
  x = x + -0x14;
  bar[1] = (short)design_x_to_screen(((short)((int)lw / 2) + x) + -0x3c);
  bar[3] = (short)scale_design_4800(0x3c) + bar[1]; /* a 60-unit wide bar */
  bar[0] = (short)design_y_to_screen((y - (short)((int)h / 2)) + 0x1e);
  bar[2] = (short)design_y_to_screen(((short)((int)h / 2) + y) + -0x1e);
  FrameRect(bar);
  tx0 = ((short)((int)lw / 2) + x) + -0x8c;
  tx1 = tx0 + 0x32;
  ty = ((short)((int)h / 2) + y) + -0x1e;
  barh = (bar[2] - bar[0]) + -1;
  PenSize((short)((int)pen / 10),(short)((int)pen / 10));
  for (i = 0; i < 10; i = i + 1) {              /* ten ticks left of the bar, long at 0 and 9 */
    if ((i == 0) || (i == 9)) {
      sx = tx0;
    }
    else {
      sx = tx0 + 0x1e;
    }
    v = (short)design_y_to_screen(ty) - (short)((int)(short)(barh * i) / 9);
    a = (short)design_x_to_screen(sx);
    MoveTo(a,v + -1);                           /* $A893 */
    a = (short)design_x_to_screen(tx1);
    LineTo(a,v + -1);                           /* $A891 */
  }
  a = (short)scale_design_4800(w) * 3;
  port = new_offscreen_bw_port(a + 4,(short)scale_design_4800(h) * 3 + 4); /* BSR 0x2a8 */
  SetPort(port);                                /* $A873 */
  SetOrigin(-2,-2);                             /* $A878 */
  nscale = (short)((int)((unsigned int)3 * *(unsigned int *)(unaff_A5 + -0x149e)) / 0x1e0) * nscale;
  pen = pen * 3;
  PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
  draw_vector_number(100,nscale,
                     ((short)((int)(short)(w * 3) / 2) - (short)((int)(short)(lw * 3) / 2)) + 0x10e,0xd2); /* BSR 0x912: top */
  draw_vector_number(0,nscale,
                     ((short)((int)(short)(w * 3) / 2) - (short)((int)(short)(lw * 3) / 2)) + 0x10e,
                     h * 3 + -0xd2);                /* bottom */
  SetPort(*(int *)(unaff_A5 + -0x1496));        /* panel port */
  antialias_downsample_bw_3x(port,box[1],box[0],box[2] - box[0],box[3] - box[1],(char *)0x0); /* BSR 0xa3c */
  dispose_offscreen_bw_port(port);              /* BSR 0x33c */
  InsetRect(bar,1,1);                           /* $A8A9 */
  *(int *)(unaff_A5 + -0x1186) = *(int *)bar;   /* bar interior for the live level */
  *(int *)(unaff_A5 + -0x1182) = *(int *)(bar + 2);
  return;
}



/* VERIFIED (ID03::FUN_00004b32): ID03.bin 0x4b32..0x4c40 checked against an independent capstone disassembly.
 * LINK -$24; PenSize 1; rect via JT $3ca / $382 / BSR 0x8a; black PaintRect; level 2 FrameRect; InsetRect 3,3; iw; right = iw/2
 * + left - 1 -> A5-0x119c; right = left + iw, left = right - iw/2 + 1 -> A5-0x1194; RTS - identical to the C. */
/* Original: FUN_00004b32; source: ID03.c. Recovered name: draw_split_display_box [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x4b32.
 * Caller: the panel redraw path of prepare_instrument_panel (0x6846) with design arguments (0x17c, 0x17c, 7, scale_design_480_min10(10), 0x474, -0x2a8). PenSize(1, 1); converts the box to screen coordinates (design_x_to_screen / design_y_to_screen, scale_design_4800); PaintRect in colour level 0; FrameRect ($A8A1) in level 2; InsetRect(3, 3); then splits the inset rect (width iw) at its horizontal centre into a left half (right = left + iw/2 - 1) stored at A5-0x119c and a right half (left = right - iw/2 + 1) stored at A5-0x1194 (8-byte Rects), so a two-pixel gap stays between them [PROVEN, bytes 0x4b32..0x4c40]; the third and fourth argument words are never read. Body rebuilt as C below. A5-0x119c is the rect that ID02 draw_notched_frame_pair_a5safe (overlay service slot -0x10ea) draws into, and A5-0x1194 is read by ID02 0x1206 / 0x1222 - so this lays out a two-part indicator box on the panel whose contents the overlay draws; which indicator is open [UNKNOWN].
 */
void draw_split_display_box /* Original: FUN_00004b32 */
               (short w,short h,short unused1,short unused2,short y,short x)

{
  int unaff_A5;
  short iw;                                     /* -$20(A6) */
  short r[4];                                   /* -$a(A6): top, left, bottom, right */

  PenSize(1,1);                                 /* $A89B */
  r[1] = (short)design_x_to_screen(x - (short)((int)w / 2)); /* JT $3ca */
  r[0] = (short)design_y_to_screen(y - (short)((int)h / 2)); /* JT $382 */
  r[3] = (short)scale_design_4800(w) + r[1];    /* BSR 0x8a */
  r[2] = (short)scale_design_4800(h) + r[0];
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $45a, JT $36a */
  PaintRect(r);                                 /* $A8A2 */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(2,2,2));
  FrameRect(r);                                 /* $A8A1 */
  InsetRect(r,3,3);                             /* $A8A9 */
  iw = r[3] - r[1];
  r[3] = ((short)((int)iw / 2) + r[1]) + -1;    /* left half */
  *(int *)(unaff_A5 + -0x119c) = *(int *)r;
  *(int *)(unaff_A5 + -0x1198) = *(int *)(r + 2);
  r[3] = r[1] + iw;                             /* right half */
  r[1] = (r[3] - (short)((int)iw / 2)) + 1;
  *(int *)(unaff_A5 + -0x1194) = *(int *)r;
  *(int *)(unaff_A5 + -0x1190) = *(int *)(r + 2);
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x00004cee)
// WARNING: Removing unreachable block (ram,0x00004e00)

/* VERIFIED (ID03::FUN_00004c42): ID03.bin 0x4c42..0x4eca checked against an independent capstone disassembly.
 * LINK -$42; BSR 0x514(size, pen, y, x, 0); BSR 0x1538; i 0..8: angle ASL #12 / 8 + $80; DIVS #4 remainder major (ASL.W #2) /
 * minor; SUBA x / ADD y end points, four BSR 0xa6, MoveTo / LineTo; TextFont 1, BSR 0x6(20), GetFontInfo, label A5-0xe1a;
 * A5-0x1178 / -0x117a / -0x1176; BSR 0x1844; RTS - identical to the C. */
/*
 * Original: FUN_00004c42; source: ID03.c:673.
 * Recovered name: draw_flaps_indicator [STRONG INFERENCE].
 * Not part of the draw_instrument type switch. Loads label slot 75 "FLAPS"
 * from the STR# 129 pointer table [PROVEN, bytes + resource dump] and draws
 * a bezel via draw_ring_with_status_indicators (BSR at file 0x4c58).
 * Gauge identity from the label [STRONG INFERENCE]. Body rebuilt as C below
 * [PROVEN, bytes 0x4c42..0x4eca]: args size, scale, pen, y, x;
 * draw_ring_with_status_indicators(size, pen, y, x, 0) (no screws), then the
 * draw_altimeter pattern with 9 ticks at angle i * 0x200 + 0x80 (a quarter
 * turn from about 3 degrees), x mirrored (cx - r cos), majors (pen / 10,
 * length 4 * scale) at i = 0, 4, 8, minors (2 * pen / 30, 2 * scale), no
 * numerals; "FLAPS" at scale(cy - factor * 100) + ascent (font 1, size 20);
 * then the needle record A5-0x117a centre h / -0x1178 centre v / -0x1176
 * radius scale(size) / 2 - scale(50); finish_instrument_supersample.
 */
void draw_flaps_indicator /* Original: FUN_00004c42 */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$3e(A6): FontInfo, ascent first */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1e(A6) */
  int angle;                                    /* -$1a(A6): 1/0x4000 turn */
  short radius;                                 /* -$16(A6) */
  short y2;                                     /* -$14(A6) */
  short x2;                                     /* -$12(A6) */
  short y1;                                     /* -$10(A6) */
  short x1;                                     /* -$e(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short factor;                                 /* -8(A6) */
  short num;                                    /* -6(A6): cleared, never used */
  short k;                                      /* -4(A6): tick length */
  short i;                                      /* -2(A6) */
  short sx;

  draw_ring_with_status_indicators(size,pen,y,x,0); /* BSR 0x514: bezel, no screws */
  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 9; i = i + 1) {               /* 9 ticks over a quarter turn */
    angle = ((int)i << 0xc) / 8 + 0x80;         /* ASL.L #6 twice, DIVS.L #8, ADDI.L #$80 */
    if (i % 4 == 0) {                           /* major ticks at i = 0, 4, 8 */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale << 2;
    }
    else {
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    x1 = (short)((int)cx - ((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc)); /* mirrored: cx - r cos */
    y1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    x2 = (short)((int)cx - ((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
    y2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy);
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x14);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe1a); /* STR# 129 slot 75 "FLAPS" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 100) + fi[0]);
  DrawString(label);                            /* $A884 */
  *(short *)(unaff_A5 + -0x1178) = (short)design_y_to_screen(y); /* needle centre v (JT $382) */
  *(short *)(unaff_A5 + -0x117a) = (short)design_x_to_screen(x); /* needle centre h (JT $3ca) */
  *(short *)(unaff_A5 + -0x1176) = (short)((int)(short)scale_design_4800(size) / 2) - (short)scale_design_4800(0x32);
                                                /* needle radius */
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x00004f7c)
// WARNING: Removing unreachable block (ram,0x00005092)

/* VERIFIED (ID03::FUN_00004ecc): ID03.bin 0x4ecc..0x5156 checked against an independent capstone disassembly.
 * Same frame and calls as 0x4c42 with: i 0..12, angle MULU.L #$1555 / 12 + $555; DIVS #3 major; SUBA for x and y; label A5-0xe16
 * at factor * 100 + cy without ascent; record A5-0x1154 / -0x1156 / -0x1152; RTS - identical to the C. */
/*
 * Original: FUN_00004ecc; source: ID03.c:691.
 * Recovered name: draw_ammo_counter [STRONG INFERENCE].
 * Not part of the draw_instrument type switch. Loads label slot 76 "AMMO"
 * from the STR# 129 pointer table [PROVEN, bytes + resource dump] and draws
 * a bezel via draw_ring_with_status_indicators (BSR at file 0x4ee2).
 * Gauge identity from the label [STRONG INFERENCE]. Body rebuilt as C below
 * [PROVEN, bytes 0x4ecc..0x5156]: the draw_flaps_indicator frame with 13
 * ticks at angle i * 0x1555 / 12 + 0x555 (30 to 150 degrees), majors
 * (pen / 10, length 4 * scale) every 3rd, both axes mirrored (cx - r cos,
 * cy - r sin: an arc over the top), "AMMO" at scale(cy + factor * 100) with
 * no ascent added (font 1, size 20), needle record A5-0x1156 h / -0x1154 v /
 * -0x1152 radius. A needle dial rather than a digit counter [STRONG
 * INFERENCE; the name is kept].
 */
void draw_ammo_counter /* Original: FUN_00004ecc */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$3e(A6): FontInfo (fetched, not used) */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1e(A6) */
  int angle;                                    /* -$1a(A6): 1/0x4000 turn */
  short radius;                                 /* -$16(A6) */
  short y2;                                     /* -$14(A6) */
  short x2;                                     /* -$12(A6) */
  short y1;                                     /* -$10(A6) */
  short x1;                                     /* -$e(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short factor;                                 /* -8(A6) */
  short num;                                    /* -6(A6): cleared, never used */
  short k;                                      /* -4(A6): tick length */
  short i;                                      /* -2(A6) */
  short sx;

  draw_ring_with_status_indicators(size,pen,y,x,0); /* BSR 0x514: bezel, no screws */
  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  num = 0;
  for (i = 0; i < 0xd; i = i + 1) {             /* 13 ticks, 30 .. 150 degrees */
    angle = (int)((unsigned int)(int)i * 0x1555) / 0xc + 0x555; /* MULU.L #$1555, DIVS.L #12, ADDI.L #$555 */
    if (i % 3 == 0) {                           /* major ticks at i = 0, 3, 6, 9, 12 */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = scale << 2;
    }
    else {
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = scale * 2;
    }
    /* both axes mirrored: cx - r cos, cy - r sin (an arc over the top) */
    x1 = (short)((int)cx - ((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
    y1 = (short)((int)cy - ((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc));
    x2 = (short)((int)cx - ((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
    y2 = (short)((int)cy - ((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc));
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x14);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe16); /* STR# 129 slot 76 "AMMO" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(factor * 100 + cy)); /* below the centre, no ascent added */
  DrawString(label);                            /* $A884 */
  *(short *)(unaff_A5 + -0x1154) = (short)design_y_to_screen(y); /* needle centre v (JT $382) */
  *(short *)(unaff_A5 + -0x1156) = (short)design_x_to_screen(x); /* needle centre h (JT $3ca) */
  *(short *)(unaff_A5 + -0x1152) = (short)((int)(short)scale_design_4800(size) / 2) - (short)scale_design_4800(0x32);
                                                /* needle radius */
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000051c0)
// WARNING: Removing unreachable block (ram,0x0000532a)

/* VERIFIED (ID03::FUN_00005158): ID03.bin 0x5158..0x532c checked against an independent capstone disassembly.
 * LINK -$12; i 0..12: angle MULU.L #$1555 / 12 - $aab, ANDI $3fff; DIVS #4 major (ASL.W #2) / minor; TST $12: ADD or SUBA for x1
 * then x2 (two cos calls), then y2, y1 via SUBA (two sin calls); four BSR 0xa6; MoveTo / LineTo; RTS - identical to the C. */
/* Original: FUN_00005158; source: ID03.c. Recovered name: draw_arc_scale_ticks [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x5158.
 * C args (words): +8 radius, +0xa length, +0xc pen, +0xe y, +0x10 x, +0x12 side flag (corrected: $e goes with the sine, $10 with the cosine, and +8 is the radius). Loop over tick i = 0..12: angle a = (i * 0x1555 / 12 - 0xaab) & 0x3fff in 1/0x4000 turns (10-degree steps starting at -60 degrees); every fourth tick is a major tick (PenSize(size / 10, size / 10), length 4 * len), the others minor (PenSize(2 * size / 30,...), length 2 * len); the end points come from the cosine / sine pointers A5-0x2118 / A5-0x211c (4.12) with the side flag selecting the mirrored arc, scaled with scale_design_4800_pen_centred (0xa6) and drawn with MoveTo / LineTo [PROVEN, bytes 0x5158..0x532c]; y = y - r sin on both arcs, so they open upwards. Body rebuilt as C below. Callers: the unexported gauge at 0x532e (0x53b0 with flag 1, 0x53e8 with flag 0) - a gauge with a left and a right arc scale.
 * The following bytes 0x532e..0x54fc (not exported by Ghidra) are that gauge, called by the panel redraw path at 0x69c6: bezel (draw_ring_with_status_indicators flags 0x0f), begin_instrument_supersample, the two arcs above, a 24-point label (set_scaled_text_style, DrawString), positions stored at A5-0x1162..-0x1158, finish_instrument_supersample. Its label string and identity are not decoded yet [UNKNOWN].
 */
void draw_arc_scale_ticks /* Original: FUN_00005158 */
               (short radius,short len,short pen,short y,short x,short right)

{
  int unaff_A5;
  int angle;                                    /* -$10(A6) */
  short y2;                                     /* -$c(A6) */
  short x2;                                     /* -$a(A6) */
  short y1;                                     /* -8(A6) */
  short x1;                                     /* -6(A6) */
  short k;                                      /* -4(A6): tick length */
  short i;                                      /* -2(A6) */
  short sx;

  for (i = 0; i < 0xd; i = i + 1) {             /* 13 ticks, -60 .. +60 degrees */
    angle = ((int)((unsigned int)(int)i * 0x1555) / 0xc + -0xaab) & 0x3fff; /* MULU.L, DIVS.L #12, ADDI.L, ANDI.L */
    if (i % 4 == 0) {                           /* major ticks at i = 0, 4, 8, 12 */
      PenSize((short)((int)pen / 10),(short)((int)pen / 10)); /* $A89B */
      k = len << 2;
    }
    else {
      PenSize((short)((int)(short)(pen * 2) / 0x1e),(short)((int)(short)(pen * 2) / 0x1e));
      k = len * 2;
    }
    if (right != 0) {                           /* arc on the right: x + r cos */
      x1 = (short)(((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)x);
      x2 = (short)(((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)x);
    }
    else {                                      /* mirrored arc on the left: x - r cos */
      x1 = (short)((int)x - ((int)radius * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
      x2 = (short)((int)x - ((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc));
    }
    y2 = (short)((int)y - ((int)(short)(radius - k) * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc)); /* sin, inner first */
    y1 = (short)((int)y - ((int)radius * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc));
    sx = scale_design_4800_pen_centred(x1);     /* BSR 0xa6 */
    MoveTo(sx,scale_design_4800_pen_centred(y1)); /* $A893 */
    sx = scale_design_4800_pen_centred(x2);
    LineTo(sx,scale_design_4800_pen_centred(y2)); /* $A891 */
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID03::FUN_0000532e): ID03.bin 0x532e..0x54fc checked against an independent capstone disassembly.
 * LINK -$42; BSR 0x514(.., $f); BSR 0x1538; BSR 0x5158(2r/3, scale, pen, cy, cx - r + 40f, 1) and (.., cx + r - 40f, 0);
 * TextFont 1, BSR 0x6(24), GetFontInfo, label A5-0xe12 at cy - factor * $e9 + ascent; JT $382 -> -0x115a / -0x1160; JT $3ca
 * -> -0x1162 / -0x115c; radius -> -0x1158 / -0x115e; BSR 0x1844; RTS - identical to the C. */
/*
 * Original: FUN_0000532e; source: ID03.c:720.
 * Recovered name: draw_fuel_gauge [STRONG INFERENCE].
 * Not part of the draw_instrument type switch. Loads label slot 77 "Fuel"
 * from the STR# 129 pointer table [PROVEN, bytes + resource dump] and draws
 * a bezel via draw_ring_with_status_indicators (BSR at file 0x5346).
 * Gauge identity from the label [STRONG INFERENCE]. Body rebuilt as C below
 * [PROVEN, bytes 0x532e..0x54fc]: args size, scale, pen, y, x; bezel with
 * screw flags 0x0f; begin_instrument_supersample; two draw_arc_scale_ticks
 * (radius 2r/3, length scale): pivot cx - r + 40 * factor with the arc to the
 * right (flag 1) and pivot cx + r - 40 * factor with the arc to the left
 * (flag 0) - two needles facing each other, presumably two tanks
 * [HYPOTHESIS]; "Fuel" at scale(cy - factor * 233) + ascent (font 1, size
 * 24); needle records left A5-0x1162 h / -0x1160 v / -0x115e radius and right
 * -0x115c / -0x115a / -0x1158 (pivots at x -+ (size/2 - 40), radius
 * 2 * scale(size/2) / 3 - scale(50)); finish_instrument_supersample.
 */
void draw_fuel_gauge /* Original: FUN_0000532e */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short fi[4];                                  /* -$3e(A6): FontInfo, ascent first */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1e(A6) */
  short radius;                                 /* -$16(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short factor;                                 /* -8(A6) */
  short sx;
  short r;

  draw_ring_with_status_indicators(size,pen,y,x,0xf); /* BSR 0x514: four screws */
  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  draw_arc_scale_ticks((short)((int)(short)(radius * 2) / 3),scale,pen,cy,
                       (cx - radius) + factor * 0x28,1); /* BSR 0x5158: pivot near the left edge, arc to the right */
  draw_arc_scale_ticks((short)((int)(short)(radius * 2) / 3),scale,pen,cy,
                       (cx + radius) - factor * 0x28,0); /* pivot near the right edge, arc to the left */
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x18);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe12); /* STR# 129 slot 77 "Fuel" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 0xe9) + fi[0]);
  DrawString(label);                            /* $A884 */
  /* two needle records (h, v, radius): left A5-0x1162 / -0x1160 / -0x115e, right A5-0x115c / -0x115a / -0x1158 */
  sx = (short)design_y_to_screen(y);            /* JT $382 */
  *(short *)(unaff_A5 + -0x115a) = sx;
  *(short *)(unaff_A5 + -0x1160) = sx;
  *(short *)(unaff_A5 + -0x1162) = (short)design_x_to_screen((x - (short)((int)size / 2)) + 0x28); /* JT $3ca */
  *(short *)(unaff_A5 + -0x115c) = (short)design_x_to_screen(((short)((int)size / 2) + x) + -0x28);
  r = (short)((int)(short)((short)scale_design_4800((short)((int)size / 2)) * 2) / 3) - (short)scale_design_4800(0x32);
  *(short *)(unaff_A5 + -0x1158) = r;
  *(short *)(unaff_A5 + -0x115e) = r;
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



/* VERIFIED (ID03::FUN_000054fe): ID03.bin 0x54fe..0x5716 checked against an independent capstone disassembly.
 * LINK -$46; BSR 0x514(.., $f); BSR 0x1538; pw = pen/10 max 3, PenSize; list loop at A5-0x1f80 to $63 ($62: skip word,
 * MoveTo; else LineTo; MULS factor + centre, BSR 0xa6; +4); TextFont 1, BSR 0x6(24), GetFontInfo, label A5-0xe0e at
 * cy - factor * $d9 + ascent; three lamp points (x -$96 / +$96 / 0, y +$25 / +$bb, v + 1) and BSR 0x8a($4b) radii; BSR 0x1844;
 * RTS - identical to the C. */
/* Original: FUN_000054fe; source: ID03.c. Recovered name: draw_landing_gear_indicator [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x54fe.
 * C args: +8 size, +0xa scale, +0xc pen, +0xe y, +0x10 x (corrected: the common gauge order; caller: the panel redraw path at 0x697e with 0x258, 7, scale_design_480_min10(10), 0x7a8, -0xb2c). draw_ring_with_status_indicators(size, pen, y, x, 0x0f) (0x514); begin_instrument_supersample; PenSize(min(pen / 10, 3)); strokes from the word list A5-0x1f80: 'b' (0x62) makes the next (dx, dy) pair a MoveTo, other pairs are LineTo, 'c' (0x63) ends it; points are (dx * factor + cx, dy * factor + cy) through scale_design_4800_pen_centred [PROVEN; list contents are A5 initial data]; TextFont(1), set_scaled_text_style(24) (0x6), GetFontInfo, StringWidth and DrawString of the label held at local -0x1a, loaded from A5-0xe0e = STR# 129 slot 78 "GEAR" (0x5628) [PROVEN]; then stores three screen points and radii: (x - 150, y + 37) at A5-0x1174 / -0x1172, (x + 150, y + 37) at -0x116e / -0x116c, (x, y + 187) at -0x1168 / -0x1166 (each v + 1), radius scale_design_4800(75) in -0x1170, -0x116a, -0x1164 - three indicator lamps, presumably one per landing-gear leg, lit later by the overlay [STRONG INFERENCE]; finish_instrument_supersample (0x1844). Body rebuilt as C below.
 */
void draw_landing_gear_indicator /* Original: FUN_000054fe */ (short size,short scale,short pen,short y,short x)

{
  int unaff_A5;
  short *pts;                                   /* -$42(A6) */
  short fi[4];                                  /* -$3e(A6): FontInfo, ascent first */
  int port;                                     /* -$32(A6) */
  unsigned char *label;                         /* -$1a(A6) */
  short radius;                                 /* -$16(A6) */
  short cy;                                     /* -$c(A6) */
  short cx;                                     /* -$a(A6) */
  short factor;                                 /* -8(A6) */
  short pw;                                     /* -2(A6) */
  short sx;
  short r;

  draw_ring_with_status_indicators(size,pen,y,x,0xf); /* BSR 0x514: four screws */
  begin_instrument_supersample(&size,&scale,&pen,y,x,&port,&radius,&cx,&cy,&factor); /* BSR 0x1538 */
  pw = (short)((int)pen / 10);
  if (3 < pw) {
    pw = 3;
  }
  PenSize(pw,pw);                               /* $A89B */
  for (pts = (short *)(unaff_A5 + -0x1f80); *pts != 0x63; pts = pts + 2) { /* word list ended by 'c' */
    if (*pts == 0x62) {                         /* 'b': next pair starts a new stroke */
      pts = pts + 1;
      sx = scale_design_4800_pen_centred(*pts * factor + cx); /* BSR 0xa6 */
      MoveTo(sx,scale_design_4800_pen_centred(pts[1] * factor + cy)); /* $A893 */
    }
    else {
      sx = scale_design_4800_pen_centred(*pts * factor + cx);
      LineTo(sx,scale_design_4800_pen_centred(pts[1] * factor + cy)); /* $A891 */
    }
  }
  TextFont(1);                                  /* $A887 */
  set_scaled_text_style(0x18);                  /* BSR 0x6 */
  GetFontInfo(fi);                              /* $A88B */
  label = *(unsigned char **)(unaff_A5 + -0xe0e); /* STR# 129 slot 78 "GEAR" */
  sx = (short)scale_design_4800(cx) - (short)((int)StringWidth(label) / 2); /* $A88C */
  MoveTo(sx,(short)scale_design_4800(cy - factor * 0xd9) + fi[0]);
  DrawString(label);                            /* $A884 */
  /* three lamp records (h, v, radius): A5-0x1174.., -0x116e.., -0x1168.. */
  *(short *)(unaff_A5 + -0x1174) = (short)design_x_to_screen(x + -0x96); /* JT $3ca: left */
  *(short *)(unaff_A5 + -0x1172) = (short)design_y_to_screen(y + 0x25) + 1; /* JT $382 */
  *(short *)(unaff_A5 + -0x116e) = (short)design_x_to_screen(x + 0x96); /* right */
  *(short *)(unaff_A5 + -0x116c) = *(short *)(unaff_A5 + -0x1172);
  *(short *)(unaff_A5 + -0x1168) = (short)design_x_to_screen(x); /* lower centre */
  *(short *)(unaff_A5 + -0x1166) = (short)design_y_to_screen(y + 0xbb) + 1;
  r = (short)scale_design_4800(0x4b);
  *(short *)(unaff_A5 + -0x1164) = r;
  *(short *)(unaff_A5 + -0x116a) = r;
  *(short *)(unaff_A5 + -0x1170) = r;
  finish_instrument_supersample(port,size,y,x); /* BSR 0x1844 */
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x0000583a)

/* VERIFIED (ID03::FUN_00005718): ID03.bin 0x5718..0x585e checked against an independent capstone disassembly.
 * LINK -$16; centre / radius from the rect (EXT.L, DIVS #2); step -5 / 5 by TST $e; $e += step; a = start; loop while $e: angle
 * ((a - $5a) ASL #14) / $168, +$4000 while < 0, -$4000 while > $4000; JSR (A5-0x2118) / (A5-0x211c) MULU.L ASR #12 + centre;
 * a == start -> store via $10 / $14 and MoveTo, else LineTo; a += step; $e -= step; RTS - identical to the C. */
/* Original: FUN_00005718; source: ID03.c. Recovered name: dial_point_at_angle [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x5718.
 * C args: +8 Rect *dial, +0xc short start angle in degrees, +0xe short sweep in degrees, +0x10 short *x (out), +0x14 short *y (out) (corrected: two long pointers, and +0xe is a sweep, not a radial offset). Body rebuilt as C below [PROVEN, bytes 0x5718..0x585e]: centre and r = half the dial width; step = +5 or -5 by the sign of the sweep, sweep += step; then for a = start, start + step, ... while sweep != 0: angle = (a - 90) * 0x4000 / 360 normalised into 0..0x4000, point = centre + (A5-0x2118)(angle) * r >> 12, centre + (A5-0x211c)(angle) * r >> 12 (4.12); the first point is stored in *x / *y and is a MoveTo, the others LineTo - it draws an arc on the dial rim in 5-degree steps (the name is kept for traceability; draw_dial_arc would describe it better). With 0 degrees at the top (a = 270 degrees), A5-0x2118 behaves as cosine and A5-0x211c as sine [STRONG INFERENCE]; both are copied from A5-0x1062 / A5-0x1066 by prepare_instrument_panel. Callers: 0x6468, 0x6532, 0x674c, 0x67c6 (panel redraw path).
 */
void dial_point_at_angle /* Original: FUN_00005718 */
               (short *dial,short start,short sweep,short *x,short *y)

{
  int unaff_A5;
  short py;                                     /* -$12(A6) */
  short px;                                     /* -$10(A6) */
  int angle;                                    /* -$e(A6): 1/0x4000 turn */
  short step;                                   /* -$a(A6) */
  short r;                                      /* -8(A6) */
  short cy;                                     /* -6(A6) */
  short cx;                                     /* -4(A6) */
  short a;                                      /* -2(A6): degrees */

  cx = (short)((int)(short)(dial[3] + dial[1]) / 2);
  cy = (short)((int)(short)(dial[2] + dial[0]) / 2);
  r = (short)((int)(short)(dial[3] - dial[1]) / 2);
  if (sweep < 0) {
    step = -5;
  }
  else {
    step = 5;
  }
  sweep = sweep + step;                         /* include the end point */
  for (a = start; sweep != 0; a = a + step) {   /* 5-degree steps */
    angle = (((int)a + -0x5a) << 0xe) / 0x168;  /* MOVEA.W, LEA -$5a: long; degrees from the top -> 1/0x4000 turn */
    while (angle < 0) {
      angle = angle + 0x4000;
    }
    while (0x4000 < angle) {
      angle = angle + -0x4000;
    }
    px = (short)(((int)r * (*(code **)(unaff_A5 + -0x2118))(angle) >> 0xc) + (int)cx); /* cos, 4.12 */
    py = (short)(((int)r * (*(code **)(unaff_A5 + -0x211c))(angle) >> 0xc) + (int)cy); /* sin */
    if (a == start) {
      *x = px;                                  /* the start point is returned */
      *y = py;
      MoveTo(px,py);                            /* $A893 */
    }
    else {
      LineTo(px,py);                            /* $A891 */
    }
    sweep = sweep - step;
  }
  return;
}



/* VERIFIED (ID03::FUN_00005860): ID03.bin 0x5860..0x59f2 checked against an independent capstone disassembly.
 * LINK -$28; JT $382(-300 / -100 / 100 +2 / 300 +2), JT $3ca(0 / -300 / -100 / 100 +2 / 300 +2) with DIVS #2, ADD.W, JT $382(0),
 * each EXT.L into a local and MOVE.W to A5-0x1150..-0x113e; four addresses MOVEA.W rowBytes MULU.L y + base + x DIVS.L
 * (8 DIVS.W depth, EXT.L) -> A5-0x113c / -0x1138 / -0x1134 / -0x1130; RTS - identical to the C. */
/* Original: FUN_00005860; source: ID03.c. Recovered name: compute_panel_screen_addresses [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x5860.
 * No arguments. Body rebuilt as C below (Ghidra's C dropped the design constants). Converts fixed design coordinates with design_y_to_screen (JT $382) and design_x_to_screen (JT $3ca, rounded down to even): A5-0x1150 = Y(-300), -0x114e = Y(-100), -0x114c = Y(100) + 2, -0x114a = Y(300) + 2, -0x1148 = X(0), -0x1146 = X(-300), -0x1144 = X(-100), -0x1142 = X(100) + 2, -0x1140 = X(300) + 2, -0x113e = Y(0) [PROVEN, bytes 0x5860..0x59f2], then four screen byte addresses A5-0x113c / -0x1138 / -0x1134 / -0x1130 = base A5-0x1382 + y * rowBytes A5-0x1378 + x / (8 / depth), with depth = A5-0x137a [PROVEN arithmetic: 8 / depth = pixels per byte, so A5-0x137a is the pixel depth 1 / 4 / 8 - it is also compared with 4 in remap_cached_panel_colours]. The addresses are the starts of the upper (X(0), Y(-300)), lower (X(0), Y(100) + 2), left (X(-300), Y(0)) and right (X(100) + 2, Y(0)) arms of a cross with a gap from -100 to 100 around the view centre - a gunsight crosshair drawn straight into screen memory [STRONG INFERENCE]. Caller: prepare_instrument_panel (0x5d46; only BSR found in ID03).
 */
void compute_panel_screen_addresses /* Original: FUN_00005860 */ (void)

{
  int unaff_A5;
  int y0;                                       /* -$28(A6): Y(0) */
  int xr1;                                      /* -$20(A6): X(100) even + 2 */
  int xl0;                                      /* -$18(A6): X(-300) even */
  int xc;                                       /* -$14(A6): X(0) even */
  int t;                                        /* -$1c / -$10 / -8(A6): stored only */
  int yb0;                                      /* -$c(A6): Y(100) + 2 */
  int yt0;                                      /* -4(A6): Y(-300) */

  /* a crosshair around the view centre: arms from 100 to 300 design units out */
  yt0 = (int)(short)design_y_to_screen(-300);   /* JT $382 */
  *(short *)(unaff_A5 + -0x1150) = (short)yt0;  /* upper arm top */
  t = (int)(short)design_y_to_screen(-100);
  *(short *)(unaff_A5 + -0x114e) = (short)t;    /* upper arm bottom */
  yb0 = (int)(short)((short)design_y_to_screen(100) + 2);
  *(short *)(unaff_A5 + -0x114c) = (short)yb0;  /* lower arm top */
  t = (int)(short)((short)design_y_to_screen(300) + 2);
  *(short *)(unaff_A5 + -0x114a) = (short)t;    /* lower arm bottom */
  xc = (int)(short)((short)((int)(short)design_x_to_screen(0) / 2) * 2); /* JT $3ca, rounded down to even */
  *(short *)(unaff_A5 + -0x1148) = (short)xc;
  xl0 = (int)(short)((short)((int)(short)design_x_to_screen(-300) / 2) * 2);
  *(short *)(unaff_A5 + -0x1146) = (short)xl0;  /* left arm start */
  t = (int)(short)((short)((int)(short)design_x_to_screen(-100) / 2) * 2);
  *(short *)(unaff_A5 + -0x1144) = (short)t;    /* left arm end */
  xr1 = (int)(short)((short)((int)(short)design_x_to_screen(100) / 2) * 2 + 2);
  *(short *)(unaff_A5 + -0x1142) = (short)xr1;  /* right arm start */
  t = (int)(short)((short)((int)(short)design_x_to_screen(300) / 2) * 2 + 2);
  *(short *)(unaff_A5 + -0x1140) = (short)t;    /* right arm end */
  y0 = (int)(short)design_y_to_screen(0);
  *(short *)(unaff_A5 + -0x113e) = (short)y0;
  /* screen byte addresses: base A5-0x1382 + y * rowBytes A5-0x1378 + x / (8 / depth A5-0x137a) */
  *(int *)(unaff_A5 + -0x113c) = (int)((unsigned int)(int)*(short *)(unaff_A5 + -0x1378) * yt0) +
       *(int *)(unaff_A5 + -0x1382) + xc / (int)(short)(8 / *(short *)(unaff_A5 + -0x137a));  /* upper arm */
  *(int *)(unaff_A5 + -0x1138) = (int)((unsigned int)(int)*(short *)(unaff_A5 + -0x1378) * yb0) +
       *(int *)(unaff_A5 + -0x1382) + xc / (int)(short)(8 / *(short *)(unaff_A5 + -0x137a));  /* lower arm */
  *(int *)(unaff_A5 + -0x1134) = (int)((unsigned int)(int)*(short *)(unaff_A5 + -0x1378) * y0) +
       *(int *)(unaff_A5 + -0x1382) + xl0 / (int)(short)(8 / *(short *)(unaff_A5 + -0x137a)); /* left arm */
  *(int *)(unaff_A5 + -0x1130) = (int)((unsigned int)(int)*(short *)(unaff_A5 + -0x1378) * y0) +
       *(int *)(unaff_A5 + -0x1382) + xr1 / (int)(short)(8 / *(short *)(unaff_A5 + -0x137a)); /* right arm */
  return;
}



/* VERIFIED (ID03::FUN_00005ab6): ID03.bin 0x5ab6..0x5c34 checked against an independent capstone disassembly.
 * LINK -8; CLR count; SetResLoad(0); four GetResource('HEL2', c + $c8 / $12c / $190 / $1f4) + RmveResource if found;
 * SetResLoad(1); UpdateResFile; four AddResource + ResError ADD.W; TST count: flag +$c = 0 and A5-0x14a0 = 1, else flag = 1
 * (MULS #$160 + *cache); ChangedResource(cache); UpdateResFile; RTS - identical to the C. */
/* Original: FUN_00005ab6; source: ID03.c. Recovered name: store_panel_bitmaps_as_resources [PROVEN].
 * Decoded from ID03.bin bytes at file 0x5ab6.
 * No arguments. With panel configuration c = A5-0x13ae: SetResLoad(false) ($A99B); for ids 200, 300, 400, 500 + c: GetResource(HEL2, id) ($A9A0) and RmveResource ($A9AD) of any old copy; SetResLoad(true); UpdateResFile(A5-0x1002) ($A999); then AddResource ($A9AB) of the handles A5-0x12b0, -0x11f6, -0x11dc, -0x11d4 as HEL2 200 / 300 / 400 / 500 + c with the names STR# 129 slots 79 "Bitmap", 80 "HorizonInstrument", 81 "GyroInstrument", 82 "GyroFlags", adding each ResError ($A9AF) to a local count. If any failed: cache entry flag +0xc = 0 (cache = HEL2 127 "Bitmap Cache" at A5-0x13b2, 0x160 bytes per configuration) and A5-0x14a0 = 1, which makes the ID04 routine at 0x432 show STR# 129 slot 1 "Unable to store instrument panel to disk"; otherwise flag +0xc = 1. Finally ChangedResource(cache) ($A9AA) and UpdateResFile. Caller: ID03 0x6ba4. Body rebuilt as C below.
 * Related (inside the Ghidra range of FUN_00005860, not exported): file 0x59f4..0x5ab4 releases the same four handles, each only when set (TST.L / BEQ) - ReleaseResource ($A9A3) when the cache entry of configuration A5-0x211e is flagged as stored (scenery record word +0xc), else DisposHandle (ID09 JT $25a) - and clears them [PROVEN, bytes]; recovered name (comment only): release_panel_bitmaps [STRONG INFERENCE]; callers 0x5ed2, 0x61d6.
 */
void store_panel_bitmaps_as_resources /* Original: FUN_00005ab6 */ (void)

{
  int unaff_A5;
  int old;                                      /* -8(A6) */
  short errs;                                   /* -4(A6) */

  errs = 0;
  SetResLoad(0);                                /* $A99B */
  old = GetResource(0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0xc8); /* $A9A0: 'HEL2' */
  if (old != 0) {
    RmveResource(old);                          /* $A9AD */
  }
  old = GetResource(0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0x12c); /* $A9A0: 'HEL2' */
  if (old != 0) {
    RmveResource(old);                          /* $A9AD */
  }
  old = GetResource(0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0x190); /* $A9A0: 'HEL2' */
  if (old != 0) {
    RmveResource(old);                          /* $A9AD */
  }
  old = GetResource(0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0x1f4); /* $A9A0: 'HEL2' */
  if (old != 0) {
    RmveResource(old);                          /* $A9AD */
  }
  SetResLoad(1);
  UpdateResFile(*(short *)(unaff_A5 + -0x1002)); /* $A999 */
  AddResource(*(int *)(unaff_A5 + -0x12b0),0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0xc8,*(unsigned char **)(unaff_A5 + -0xe0a));
                                                /* $A9AB: STR# 129 slot 79 "Bitmap" */
  errs = errs + ResError();                     /* $A9AF */
  AddResource(*(int *)(unaff_A5 + -0x11f6),0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0x12c,*(unsigned char **)(unaff_A5 + -0xe06));
                                                /* $A9AB: STR# 129 slot 80 "HorizonInstrument" */
  errs = errs + ResError();                     /* $A9AF */
  AddResource(*(int *)(unaff_A5 + -0x11dc),0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0x190,*(unsigned char **)(unaff_A5 + -0xe02));
                                                /* $A9AB: STR# 129 slot 81 "GyroInstrument" */
  errs = errs + ResError();                     /* $A9AF */
  AddResource(*(int *)(unaff_A5 + -0x11d4),0x48454c32,*(short *)(unaff_A5 + -0x13ae) + 0x1f4,*(unsigned char **)(unaff_A5 + -0xdfe));
                                                /* $A9AB: STR# 129 slot 82 "GyroFlags" */
  errs = errs + ResError();                     /* $A9AF */
  if (errs != 0) {
    *(short *)(**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160) + 0xc) = 0; /* cache entry: not stored */
    *(short *)(unaff_A5 + -0x14a0) = 1;         /* "Unable to store instrument panel to disk" */
  }
  else {
    *(short *)(**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160) + 0xc) = 1; /* stored */
  }
  ChangedResource(*(int *)(unaff_A5 + -0x13b2)); /* $A9AA: "Bitmap Cache" */
  UpdateResFile(*(short *)(unaff_A5 + -0x1002));
  return;
}



/* VERIFIED (ID03::FUN_00005c36): ID03.bin 0x5c36..0x5cb4 checked against an independent capstone disassembly.
 * LINK -$16; JT $4f2(port, 0, $6c); save thePort; OpenCPort; SetPort(saved); PixMap rowBytes / baseAddr / bounds via **(port+2);
 * portRect = bounds; RectRgn(visRgn, &bounds $12(A6)); D0 = port; RTS - identical to the C. */
/* Original: FUN_00005c36; source: ID03.c. Recovered name: open_cport_on_buffer [PROVEN].
 * Decoded from ID03.bin bytes at file 0x5c36.
 * C args: +8 CGrafPort *port (0x6c bytes), +0xc short rowBytes, +0xe Ptr baseAddr, +0x12 Rect bounds (by value). Clears the 0x6c bytes (JT $4f2, ID02 0x2b0), OpenCPort(port) ($AA00), restores thePort; sets the port PixMap (handle at +2): rowBytes (+4), baseAddr (+0), bounds (+6) = bounds; portRect (+0x10) = bounds; RectRgn(visRgn +0x18, &bounds) ($A8DF); returns port. Caller: prepare_instrument_panel (0x5da8, port A5-0x1492 -> A5-0x1496). Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

int open_cport_on_buffer /* Original: FUN_00005c36 */ (int port,short rowBytes,int baseAddr,Rect bounds)

{
  int unaff_A5;
  int savedPort;                                /* -$12(A6) */

  FUN_000002b0(port,0,0x6c);                    /* JT $4f2 (ID02 0x2b0): clear the CGrafPort */
  savedPort = *(int *)(unaff_A5 + -0x160c);     /* thePort */
  OpenCPort(port);                              /* $AA00 */
  SetPort(savedPort);                           /* $A873 */
  *(short *)(**(int **)(port + 2) + 4) = rowBytes; /* (*portPixMap)->rowBytes */
  **(int **)(port + 2) = baseAddr;              /* (*portPixMap)->baseAddr */
  *(Rect *)(**(int **)(port + 2) + 6) = bounds; /* (*portPixMap)->bounds */
  *(Rect *)(port + 0x10) = bounds;              /* portRect */
  RectRgn(*(int *)(port + 0x18),&bounds);       /* $A8DF: visRgn */
  return port;
}



/* VERIFIED (ID03::FUN_00005cb6): ID03.bin 0x5cb6..0x5cc2 checked against an independent capstone disassembly.
 * LINK #0; ClosePort(8(A6)); RTS - identical to the C. */
/* Original: FUN_00005cb6; source: ID03.c. Recovered name: close_port_glue [PROVEN].
 * Decoded from ID03.bin bytes at file 0x5cb6.
 * ClosePort(port +8) ($A87D); body rebuilt as C below. Callers: prepare_instrument_panel (0x5d72 for A5-0x11cc, 0x5d92 for A5-0x1496).
 */
void close_port_glue /* Original: FUN_00005cb6 */ (int port)

{
  ClosePort(port);                              /* $A87D */
  return;
}



/* VERIFIED (ID03::FUN_00005cc4): ID03.bin 0x5cc4..0x6c1a checked against an independent capstone disassembly.
 * LINK -$30; CurResFile / UseResFile; scale; trig pointers; HEL2 127 or NewHandleClear($580) + AddResource; BSR 0x5860; rect;
 * port cleanup; BSR 0x5c36; entry loop (five key compares, current / stored tests, load block with ten 16-byte copies, BSR
 * 0x59f4, GetResource 300 / 400 / 500 / 200, LRU update, block copies, UpdateResFile, BSR 0x71a2), blank gyro window, BRA tail;
 * redraw path (JT $49a, LRU min / max scans, NewHandle / NewHandleClear, key and rowBytes, JT $26a, regions and arcs, 3-pixel
 * outline, sixteen instrument calls with the listed constants, copies back, JT $27a, DisposDialog, BSR 0x5ab6, BSR 0x71a2);
 * tail (BSR 0x5c36 at depth 1 / 4, BSR 0x3832 at depth 1, UseResFile); RTS - identical to the C (block copies written as
 * memcpy; MOVE.L / DBRA loops in the binary). */
/* Original: FUN_00005cc4; source: ID03.c. Recovered name: prepare_instrument_panel [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x5cc4.
 * Reached through JT $17a (CODE 0 entry -> ID03 0x5cc4). Body rebuilt as C below [PROVEN, bytes 0x5cc4..0x6c1a]: saves CurResFile ($A994) and UseResFile(A5-0x1002) ($A998); panel scale A5-0x149e = A5-0x149a = (w / 2 + w) / 2 for the half view width w = A5-0x1372 (the factor used by scale_design_4800); copies A5-0x1066 / -0x1062 to A5-0x211c / -0x2118; cache = GetResource(HEL2, 127) -> A5-0x13b2, or NewHandleClear(0x580) added as HEL2 127 "Bitmap Cache" (STR# 129 slot 83) - 4 entries of 0x160 bytes; calls FUN_00005860; closes the old ports A5-0x11cc / A5-0x1496 (close_port_glue) and disposes the region A5-0x13b6 ($A8D9); opens A5-0x1492 with open_cport_on_buffer; then searches the 4 cache entries for one whose +0 / +2 / +4 / +6 / +8 equal A5-0x137a (1-bit mode), A5-0x137e, A5-0x137c, A5-0x1372, A5-0x1370 (view size) and that is the current configuration A5-0x13ae or flagged stored (+0xc); for a stored entry it copies its ten 16-byte instrument records (+0x12) to A5-0x12a2 and 20 bytes (+0xb2) to A5-0x1202, releases the current bitmaps (0x59f4) and loads HEL2 300 + entry... as A5-0x11f6 and the others. So rendered panels are reused from disk when the display configuration matches [STRONG INFERENCE]. A matching current entry, or a freshly loaded one, gets its gyro window blanked black and the function goes to the tail. Otherwise (redraw path): show_creating_panel_dialog (JT $49a); the least recently used entry (smallest use counter +0xe) becomes current; FUN_000059f4; NewHandle(1) (ID09 0x236, $A122) for "Bitmap" and NewHandleClear(1) (ID09 0x242, $A322) for the other three; use counter = max + 1, key and rowBytes ((w * depth + 15) >> 4) * 2 | 0x8000 written, ReallocHandle of the bitmap to the panel height; panel painted black; region A = view frame (draw_view_frame_outline, JT $3ba) minus region B (the panel's upper edge built from two dial_point_at_angle corner arcs at design x -2665..-2135 and 2135..2665, y 1010..1540, lines to (-2394 / 2394, 2400) and (-1060 / 1060, 670)) filled with the blended pattern in level 1 on level 0, region B painted; a 3-pixel black outline along the same edges plus (-3200, 1200)..(4000, 1200); then the instruments at their design positions (size, scale, pen, y, x): numbered boxes (screw size 40), percent gauge (330, 600, 7, -, 1940, 2200), split box (380, 380, 7, -, 1140, -680), altimeter (780, 10, s(12), 1860, -1660), airspeed (780, 9, -, 1860, -800), turn and bank (640, 7, -, 1940, 0), climb (680, 8, -, 1920, 800), manifold (680, 7, -, 1920, 1660), tachometer (560, 7, -, 1348, 2200), direction (540, 7, -, 1360, -2200), gear (600, 7, -, 1960, -2860), flaps (400, 7, -, 1410, -2900), fuel (600, 9, -, 1960, 2860), ammo (400, 7, -, 1410, 2900), horizon (720, 10, -, 1180, 1230; screw size 50) and gyro (600, 9, -, 1140, -1230) (pen = scale_design_480_min10(10) unless noted); the screen records are copied into the entry; DisposDialog, store_panel_bitmaps_as_resources, remap_panel_colours_identity. Tail: at depth 1 or 4 a colour port A5-0x1426 on the gyro tape (A5-0x11cc); at depth 1 the horizon face region A5-0x13b6 (make_inset_face_oval_region(720, 1180, 1230)); UseResFile(saved).
 */
void prepare_instrument_panel /* Original: FUN_00005cc4 */ (void)

{
  int unaff_A5;
  short face[4];                                /* -$30(A6) */
  short savedRes;                               /* -$28(A6) */
  int dlg;                                      /* -$26(A6) */
  int savedPort;                                /* -$22(A6) */
  short r[4];                                   /* -$1e(A6): top, left, bottom, right */
  int rgnB;                                     /* -$16(A6) */
  int rgnA;                                     /* -$12(A6) */
  int best;                                     /* -$e(A6): use counter */
  short unused;                                 /* -$a(A6): cleared, never read */
  short py;                                     /* -8(A6) */
  short px;                                     /* -6(A6) */
  short k;                                      /* -4(A6) */
  short i;                                      /* -2(A6) */
  short sx;
/* 0x160-byte cache entry of slot n in "Bitmap Cache" (HEL2 127) */
#define ENT_(n) (**(int **)(unaff_A5 + -0x13b2) + (int)(short)((n) * 0x160))
#define CUR_ (*(short *)(unaff_A5 + -0x13ae))
#define DX_(v) ((short)design_x_to_screen(v))
#define DY_(v) ((short)design_y_to_screen(v))

  unused = 0;
  savedRes = CurResFile();                      /* $A994 */
  UseResFile(*(short *)(unaff_A5 + -0x1002));   /* $A998 */
  *(int *)(unaff_A5 + -0x149e) =
       (int)(short)((int)(short)((short)((int)*(short *)(unaff_A5 + -0x1372) / 2) +
                                 *(short *)(unaff_A5 + -0x1372)) / 2); /* panel scale = 3/4 of the half view width */
  *(int *)(unaff_A5 + -0x149a) = *(int *)(unaff_A5 + -0x149e);
  *(int *)(unaff_A5 + -0x211c) = *(int *)(unaff_A5 + -0x1066); /* sine pointer from the overlay */
  *(int *)(unaff_A5 + -0x2118) = *(int *)(unaff_A5 + -0x1062); /* cosine pointer */
  *(int *)(unaff_A5 + -0x13b2) = GetResource(0x48454c32,0x7f); /* $A9A0: 'HEL2' 127 */
  if (*(int *)(unaff_A5 + -0x13b2) == 0) {
    *(int *)(unaff_A5 + -0x13b2) = NewHandleClear(0x580); /* JT $252 (ID09 0x242, $A322): 4 entries */
    AddResource(*(int *)(unaff_A5 + -0x13b2),0x48454c32,0x7f,*(unsigned char **)(unaff_A5 + -0xdfa));
                                                /* $A9AB: STR# 129 slot 83 "Bitmap Cache" */
  }
  compute_panel_screen_addresses();             /* BSR 0x5860 */
  r[1] = 0;
  r[3] = *(short *)(unaff_A5 + -0x1372);
  r[0] = DY_(0x29e);                            /* JT $382: panel top at design y 670 */
  r[2] = *(short *)(unaff_A5 + -0x1370);
  if (*(int *)(unaff_A5 + -0x11cc) != 0) {
    close_port_glue(*(int *)(unaff_A5 + -0x11cc)); /* BSR 0x5cb6 */
    *(int *)(unaff_A5 + -0x11cc) = 0;
  }
  if (*(int *)(unaff_A5 + -0x13b6) != 0) {
    DisposeRgn(*(int *)(unaff_A5 + -0x13b6));   /* $A8D9 (not cleared) */
  }
  if (*(int *)(unaff_A5 + -0x1496) != 0) {
    close_port_glue(*(int *)(unaff_A5 + -0x1496));
  }
  *(int *)(unaff_A5 + -0x1496) = open_cport_on_buffer(unaff_A5 + -0x1492,0,0,*(Rect *)r); /* BSR 0x5c36: panel port */
  for (i = 0; i < 4; i = i + 1) {               /* look for a cached panel of this configuration */
    if ((*(short *)ENT_(i) != *(short *)(unaff_A5 + -0x137a)) ||
        (*(short *)(ENT_(i) + 2) != *(short *)(unaff_A5 + -0x137e)) ||
        (*(short *)(ENT_(i) + 4) != *(short *)(unaff_A5 + -0x137c)) ||
        (*(short *)(ENT_(i) + 6) != *(short *)(unaff_A5 + -0x1372)) ||
        (*(short *)(ENT_(i) + 8) != *(short *)(unaff_A5 + -0x1370))) continue;
    if ((CUR_ != i) && (*(short *)(ENT_(i) + 0xc) == 0)) continue; /* neither current nor stored */
    if ((CUR_ != i) && (*(short *)(ENT_(i) + 0xc) != 0)) { /* load the stored panel */
      for (k = 0; k < 10; k = k + 1) {          /* ten 16-byte instrument records */
        memcpy((void *)(unaff_A5 + -0x12a2 + (int)k * 0x10),(void *)(ENT_(i) + (int)k * 0x10 + 0x12),0x10);
      }
      FUN_000059f4();                           /* BSR 0x59f4: release the current bitmaps */
      memcpy((void *)(unaff_A5 + -0x1202),(void *)(ENT_(i) + 0xb2),0x14);
      *(int *)(unaff_A5 + -0x11f6) = GetResource(0x48454c32,i + 300); /* "HorizonInstrument" */
      memcpy((void *)(unaff_A5 + -0x11ee),(void *)(ENT_(i) + 0xc6),0x22); /* gyro window record */
      *(int *)(unaff_A5 + -0x11dc) = GetResource(0x48454c32,i + 400); /* "GyroInstrument" */
      *(int *)(unaff_A5 + -0x11d4) = GetResource(0x48454c32,i + 500); /* "GyroFlags" */
      for (k = 0; k < 4; k = k + 1) {           /* make this entry the most recently used */
        if (*(int *)(ENT_(i) + 0xe) < *(int *)(ENT_(k) + 0xe)) {
          *(int *)(ENT_(i) + 0xe) = *(int *)(ENT_(k) + 0xe) + 1;
          ChangedResource(*(int *)(unaff_A5 + -0x13b2)); /* $A9AA */
        }
      }
      memcpy((void *)(unaff_A5 + -0x11c8),(void *)(ENT_(i) + 0xe8),0x2c);
      memcpy((void *)(unaff_A5 + -0x119c),(void *)(ENT_(i) + 0x114),0x16);
      memcpy((void *)(unaff_A5 + -0x1186),(void *)(ENT_(i) + 0x12a),0xc);
      memcpy((void *)(unaff_A5 + -0x117a),(void *)(ENT_(i) + 0x136),0x18);
      memcpy((void *)(unaff_A5 + -0x1162),(void *)(ENT_(i) + 0x14e),0xc);
      memcpy((void *)(unaff_A5 + -0x1156),(void *)(ENT_(i) + 0x15a),6);
      *(int *)(unaff_A5 + -0x12b0) = GetResource(0x48454c32,i + 200); /* "Bitmap" */
      *(short *)(unaff_A5 + -0x12a8) = *(short *)(ENT_(i) + 10) & 0x1fff;
      *(short *)(unaff_A5 + -0x12a6) = DY_(0x29e);
      *(short *)(unaff_A5 + -0x211e) = i;
      CUR_ = i;
      UpdateResFile(*(short *)(unaff_A5 + -0x1002)); /* $A999 */
      remap_panel_colours_identity();           /* BSR 0x71a2 */
    }
    HLock(*(int *)(unaff_A5 + -0x12b0));        /* JT $272 */
    savedPort = *(int *)(unaff_A5 + -0x160c);
    **(int **)(*(int *)(unaff_A5 + -0x1496) + 2) = **(int **)(unaff_A5 + -0x12b0); /* pixmap base = bitmap */
    *(short *)(**(int **)(*(int *)(unaff_A5 + -0x1496) + 2) + 4) = *(short *)(ENT_(CUR_) + 10);
    SetPort(*(int *)(unaff_A5 + -0x1496));      /* $A873 */
    r[1] = *(short *)(unaff_A5 + -0x11ec);
    r[0] = *(short *)(unaff_A5 + -0x11ee);
    r[3] = r[1] + *(short *)(unaff_A5 + -0x11ea);
    r[2] = r[0] + *(short *)(unaff_A5 + -0x11e8);
    ForeColor(0x21);                            /* $A862: blackColor */
    PaintRect(r);                               /* $A8A2: blank the gyro window */
    SetPort(savedPort);
    HUnlock(*(int *)(unaff_A5 + -0x12b0));      /* JT $27a */
    goto finish;                                /* BRA.W 0x6bac */
  }
  /* no usable cache entry: render the panel into the least recently used slot */
  dlg = show_creating_panel_dialog();           /* JT $49a */
  best = 0x7fffffff;
  k = 0;
  for (i = 0; i < 4; i = i + 1) {
    if (*(int *)(ENT_(i) + 0xe) < best) {
      best = *(int *)(ENT_(i) + 0xe);
      k = i;
    }
  }
  FUN_000059f4();                               /* release the current bitmaps */
  *(short *)(unaff_A5 + -0x211e) = k;
  CUR_ = k;
  *(int *)(unaff_A5 + -0x12b0) = NewHandle(1);  /* JT $24a (ID09 0x236, $A122) */
  *(int *)(unaff_A5 + -0x11f6) = NewHandleClear(1);
  *(int *)(unaff_A5 + -0x11dc) = NewHandleClear(1);
  *(int *)(unaff_A5 + -0x11d4) = NewHandleClear(1);
  best = (int)0x80000000;
  for (i = 0; i < 4; i = i + 1) {
    if (best < *(int *)(ENT_(i) + 0xe)) {
      best = *(int *)(ENT_(i) + 0xe);
      k = i;
    }
  }
  *(int *)(ENT_(CUR_) + 0xe) = best + 1;        /* newest use */
  ChangedResource(*(int *)(unaff_A5 + -0x13b2));
  *(short *)ENT_(CUR_) = *(short *)(unaff_A5 + -0x137a); /* key: depth, */
  *(short *)(ENT_(CUR_) + 2) = *(short *)(unaff_A5 + -0x137e);
  *(short *)(ENT_(CUR_) + 4) = *(short *)(unaff_A5 + -0x137c);
  *(short *)(ENT_(CUR_) + 6) = *(short *)(unaff_A5 + -0x1372); /* view size */
  *(short *)(ENT_(CUR_) + 8) = *(short *)(unaff_A5 + -0x1370);
  *(short *)(ENT_(CUR_) + 10) =
       ((short)(*(short *)(unaff_A5 + -0x1372) * *(short *)(unaff_A5 + -0x137a) + 0xf) >> 4) * 2 | 0x8000; /* rowBytes */
  ReallocHandle(*(int *)(unaff_A5 + -0x12b0),
                (int)(short)(r[2] - r[0]) * (int)(unsigned short)(*(short *)(ENT_(CUR_) + 10) & 0x1fff)); /* JT $26a */
  *(short *)(unaff_A5 + -0x12a8) = *(short *)(ENT_(CUR_) + 10) & 0x1fff;
  *(short *)(unaff_A5 + -0x12a6) = DY_(0x29e);
  HLock(*(int *)(unaff_A5 + -0x12b0));
  savedPort = *(int *)(unaff_A5 + -0x160c);
  **(int **)(*(int *)(unaff_A5 + -0x1496) + 2) = **(int **)(unaff_A5 + -0x12b0);
  *(short *)(**(int **)(*(int *)(unaff_A5 + -0x1496) + 2) + 4) = *(short *)(ENT_(CUR_) + 10);
  SetPort(*(int *)(unaff_A5 + -0x1496));
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $45a, JT $36a */
  PaintRect((short *)(*(int *)(unaff_A5 + -0x1496) + 0x10)); /* the whole panel black */
  PenSize(1,1);                                 /* $A89B */
  rgnA = NewRgn();                              /* $A8D8 */
  OpenRgn();                                    /* $A8DA */
  draw_view_frame_outline();                    /* JT $3ba: the view window */
  CloseRgn(rgnA);                               /* $A8DB */
  rgnB = NewRgn();                              /* the panel's upper edge */
  OpenRgn();
  r[1] = DX_(-0xa69);  r[0] = DY_(0x3f2) + 1;  r[3] = DX_(-0x857);  r[2] = DY_(0x604) + 1;
  dial_point_at_angle(r,-0xe,-0x5a,&px,&py);    /* BSR 0x5718: left corner arc */
  sx = DX_(-0x95a);  LineTo(sx,DY_(0x960) + 1); /* $A891 */
  sx = DX_(0x95a);   LineTo(sx + -3,DY_(0x960) + 1);
  MoveTo(px,py);                                /* $A893 */
  sx = DX_(-0x424);  LineTo(sx,DY_(0x29e));
  r[1] = DX_(0x857);  r[0] = DY_(0x3f2) + 1;  r[3] = DX_(0xa69);  r[2] = DY_(0x604) + 1;
  dial_point_at_angle(r,0xe,0x5a,&px,&py);      /* right corner arc */
  sx = DX_(0x95a);   LineTo(sx + -3,DY_(0x960) + 1);
  MoveTo(px,py);
  sx = DX_(0x424);   LineTo(sx + -4,DY_(0x29e));
  sx = DX_(-0x424);  LineTo(sx,DY_(0x29e));
  CloseRgn(rgnB);
  DiffRgn(rgnA,rgnB,rgnA);                      /* $A8E6 */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(1,1,1));
  set_back_color_index((short)lookup_palette_index_for_rgb_level(0,0,0)); /* JT $3a2 */
  FillRgn(rgnA,get_blended_fill_pattern());     /* JT $3e2, $A8D6 */
  PaintRgn(rgnB);                               /* $A8D3 */
  set_draw_color_index((short)lookup_palette_index_for_rgb_level(0,0,0));
  DisposeRgn(rgnB);                             /* $A8D9 */
  DisposeRgn(rgnA);
  PenSize(3,3);                                 /* outline in black */
  draw_view_frame_outline();
  sx = DX_(-0xc80);  MoveTo(sx + -1,DY_(0x4b0));
  sx = DX_(-0xc80);  LineTo(sx,DY_(0x4b0));
  sx = DX_(-0x424);  LineTo(sx,DY_(0x29e));
  sx = DX_(0x424);   LineTo(sx + -4,DY_(0x29e));
  sx = DX_(0xc80);   LineTo(sx + -4,DY_(0x4b0));
  sx = DX_(0xfa0);   LineTo(sx,DY_(0x4b0));
  r[1] = DX_(-0xa69);  r[0] = DY_(0x3f2) + 1;  r[3] = DX_(-0x857);  r[2] = DY_(0x604) + 1;
  dial_point_at_angle(r,-0xe,-0x5a,&px,&py);
  sx = DX_(-0x95a);  LineTo(sx,DY_(0x960) + 1);
  r[1] = DX_(0x857);  r[0] = DY_(0x3f2) + 1;  r[3] = DX_(0xa69);  r[2] = DY_(0x604) + 1;
  dial_point_at_angle(r,0xe,0x5a,&px,&py);
  sx = DX_(0x95a);   LineTo(sx + -3,DY_(0x960) + 1);
  /* the instruments (design units: size, scale, pen, y, x) */
  *(short *)(unaff_A5 + -0x2114) = 0x28;        /* screw size */
  draw_panel_section_with_numbered_boxes();     /* BSR 0x4304 */
  draw_percent_scale_gauge(0x14a,0x258,7,scale_design_480_min10(10),0x794,0x898); /* BSR 0x4790 */
  draw_split_display_box(0x17c,0x17c,7,scale_design_480_min10(10),0x474,-0x2a8); /* BSR 0x4b32 */
  draw_instrument(0,0x30c,10,scale_design_480_min10(0xc),0x744,-0x67c); /* BSR 0x3c02: altimeter */
  draw_instrument(1,0x30c,9,scale_design_480_min10(10),0x744,-800);     /* airspeed */
  draw_instrument(2,0x280,7,scale_design_480_min10(10),0x794,0);        /* turn and bank */
  draw_instrument(3,0x2a8,8,scale_design_480_min10(10),0x780,800);      /* climb */
  draw_instrument(4,0x2a8,7,scale_design_480_min10(10),0x780,0x67c);    /* manifold pressure */
  draw_instrument(5,0x230,7,scale_design_480_min10(10),0x544,0x898);    /* tachometer */
  draw_instrument(6,0x21c,7,scale_design_480_min10(10),0x550,-0x898);   /* direction */
  draw_landing_gear_indicator(0x258,7,scale_design_480_min10(10),0x7a8,-0xb2c); /* BSR 0x54fe */
  draw_flaps_indicator(400,7,scale_design_480_min10(10),0x582,-0xb54);  /* BSR 0x4c42 */
  draw_fuel_gauge(0x258,9,scale_design_480_min10(10),0x7a8,0xb2c);      /* BSR 0x532e */
  draw_ammo_counter(400,7,scale_design_480_min10(10),0x582,0xb54);      /* BSR 0x4ecc */
  *(short *)(unaff_A5 + -0x2114) = 0x32;
  draw_instrument(9,0x2d0,10,scale_design_480_min10(10),0x49c,0x4ce);   /* artificial horizon */
  *(short *)(unaff_A5 + -0x2114) = 0x28;
  draw_instrument(8,0x258,9,scale_design_480_min10(10),0x474,-0x4ce);   /* gyro */
  /* store the screen records in the cache entry */
  memcpy((void *)(ENT_(CUR_) + 0xb2),(void *)(unaff_A5 + -0x1202),0x14);
  memcpy((void *)(ENT_(CUR_) + 0xc6),(void *)(unaff_A5 + -0x11ee),0x22);
  for (k = 0; k < 10; k = k + 1) {
    memcpy((void *)(ENT_(CUR_) + (int)k * 0x10 + 0x12),(void *)(unaff_A5 + -0x12a2 + (int)k * 0x10),0x10);
  }
  memcpy((void *)(ENT_(CUR_) + 0xe8),(void *)(unaff_A5 + -0x11c8),0x2c);
  memcpy((void *)(ENT_(CUR_) + 0x114),(void *)(unaff_A5 + -0x119c),0x16);
  memcpy((void *)(ENT_(CUR_) + 0x12a),(void *)(unaff_A5 + -0x1186),0xc);
  memcpy((void *)(ENT_(CUR_) + 0x136),(void *)(unaff_A5 + -0x117a),0x18);
  memcpy((void *)(ENT_(CUR_) + 0x14e),(void *)(unaff_A5 + -0x1162),0xc);
  memcpy((void *)(ENT_(CUR_) + 0x15a),(void *)(unaff_A5 + -0x1156),6);
  SetPort(savedPort);
  HUnlock(*(int *)(unaff_A5 + -0x12b0));
  DisposDialog(dlg);                            /* $A983 */
  store_panel_bitmaps_as_resources();           /* BSR 0x5ab6 */
  remap_panel_colours_identity();               /* BSR 0x71a2 */
finish:
  if ((*(short *)(unaff_A5 + -0x137a) == 1) || (*(short *)(unaff_A5 + -0x137a) == 4)) {
    r[1] = 0;
    r[0] = 0;
    r[3] = *(short *)(unaff_A5 + -0x11e4);
    r[2] = *(short *)(unaff_A5 + -0x11e2);
    *(int *)(unaff_A5 + -0x11cc) =
         open_cport_on_buffer(unaff_A5 + -0x1426,*(short *)(unaff_A5 + -0x11de),0,*(Rect *)r); /* port on the gyro tape */
  }
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    *(int *)(unaff_A5 + -0x13b6) = make_inset_face_oval_region(face,0x2d0,0x49c,0x4ce); /* BSR 0x3832: horizon face */
  }
  UseResFile(savedRes);
  return;
#undef ENT_
#undef CUR_
#undef DX_
#undef DY_
}



/* VERIFIED (ID03::FUN_00006c1c): ID03.bin 0x6c1c..0x71a0 checked against an independent capstone disassembly.
 * LINK -$200, MOVEM D5-D7/A3-A4; TST A5-0x13ae / -0x13b2 and five key compares -> exit; depth 1: JT $482; clear inv; D5 = +$a &
 * $1fff; JT $2a (4 -> 0x6d16, 8 -> 0x6ede, else 0x704a); depth 4: inv over 0..12, nibble remap of A5-0x12b0 and A5-0x11dc,
 * A5-0x11fa / -0x11f8 four-nibble words; depth 8: inv over 200..216, byte remap, two-byte words; common block of ten JT $45a
 * lookups through newIdx with the two depth-4 nibble doublings; MOVEM restore; RTS - identical to the C. */
/* Original: FUN_00006c1c; source: ID03.c. Recovered name: remap_cached_panel_colours [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x6c1c.
 * Reached through JT $182 (CODE 0 entry -> ID03 0x6c1c). Returns at once unless the current configuration A5-0x13ae has a cache entry (A5-0x13b2) whose key (+0 depth, +2, +4, +6 / +8 view size) matches the display. In 1-bit mode calls JT $482 (ID02 0x4b62, the standard colour index set-up). Args: short *oldIdx (the colour index each palette slot had when the panel was rendered), short *newIdx (the current index per slot). Otherwise, body rebuilt as C below [PROVEN, bytes 0x6c1c..0x71a0]: inv[256] = 0 and inv[oldIdx[k]] = k for valid indices (0..255) over slots k = 0..12 at depth 4 or k = 200..216 at depth 8 (switch JT $2a); every pixel of the "Bitmap" handle A5-0x12b0 (rows / width from the panel port A5-0x1496, row stride = cache entry +0xa & 0x1fff) and of the "GyroInstrument" tape A5-0x11dc (stride A5-0x11de & 0x1fff, A5-0x11e2 rows, A5-0x11e4 pixels) becomes newIdx[inv[pixel]] (two nibbles per byte at depth 4, the low byte at depth 8); A5-0x11fa / -0x11f8 = the new indices of levels (0, 0, 4) and (1, 1, 1) repeated in every pixel of a word; then A5-0x11ae, -0x11ac, -0x11a2, -0x118c, -0x1188, -0x118a, -0x117c, -0x117e, -0x112c, -0x12a4 = newIdx of the levels (0,2,0), (0,0,0), (3,3,3), (0,0,0), (2,2,2) x3, (0,0,0) x2, (3,3,3), with -0x11a2 and -0x12a4 doubled into both nibbles at depth 4. Other depths skip the pixel pass. So a panel loaded from the cache is re-coloured for the current palette [STRONG INFERENCE for the purpose; the mapping is PROVEN].
 */
void remap_cached_panel_colours /* Original: FUN_00006c1c */ (short *oldIdx,short *newIdx)

{
  int unaff_A5;
  short inv[256];                               /* -$200(A6): old colour index -> slot */
  unsigned char *p;                             /* A4 */
  unsigned char *q;                             /* A3 */
  short k;                                      /* D7 */
  short rows;                                   /* D7 */
  short cols;                                   /* D6 */
  short stride;                                 /* D5 */
  short n;

  if (*(short *)(unaff_A5 + -0x13ae) < 0) return;
  if (*(int *)(unaff_A5 + -0x13b2) == 0) return;
  if ((*(short *)(**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160)) != *(short *)(unaff_A5 + -0x137a)) ||       /* cache key: depth, */
      (*(short *)((**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160)) + 2) != *(short *)(unaff_A5 + -0x137e)) ||
      (*(short *)((**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160)) + 4) != *(short *)(unaff_A5 + -0x137c)) ||
      (*(short *)((**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160)) + 6) != *(short *)(unaff_A5 + -0x1372)) || /* view size */
      (*(short *)((**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160)) + 8) != *(short *)(unaff_A5 + -0x1370))) {
    return;
  }
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    FUN_00004b62();                             /* JT $482 (ID02 0x4b62, init_standard_colour_indices) */
    return;
  }
  for (k = 0; k < 0x100; k = k + 1) {
    inv[k] = 0;
  }
  stride = *(short *)((**(int **)(unaff_A5 + -0x13b2) + (int)(short)(*(short *)(unaff_A5 + -0x13ae) * 0x160)) + 10) & 0x1fff;       /* rowBytes of the cached panel bitmap */
  switch (*(short *)(unaff_A5 + -0x137a)) {   /* JT $2a (ID01 0x96, word table at 0x6d0a) */
  case 4:
  for (k = 0; k < 0xd; k = k + 1) {
    if ((-1 < oldIdx[k]) && (oldIdx[k] < 0x100)) {
      inv[oldIdx[k]] = k;
    }
  }
  p = *(unsigned char **)*(int *)(unaff_A5 + -0x12b0);                 /* "Bitmap": rows / width of the panel port A5-0x1496 */
  stride = stride;
  for (rows = *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x14) - *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x10); rows-- != 0; p = p + stride) {
    q = p;
    for (cols = (short)(*(short *)(*(int *)(unaff_A5 + -0x1496) + 0x16) - *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x12)) >> 1; cols-- != 0; q = q + 1) { /* two 4-bit pixels per byte */
      *q = (unsigned char)((newIdx[inv[*q >> 4]] << 4) | newIdx[inv[*q & 0xf]]);
    }
  }
  p = *(unsigned char **)*(int *)(unaff_A5 + -0x11dc);                 /* "GyroInstrument" tape */
  stride = *(short *)(unaff_A5 + -0x11de) & 0x1fff;
  for (rows = *(short *)(unaff_A5 + -0x11e2); rows-- != 0; p = p + stride) {
    q = p;
    for (cols = *(short *)(unaff_A5 + -0x11e4) >> 1; cols-- != 0; q = q + 1) { /* two 4-bit pixels per byte */
      *q = (unsigned char)((newIdx[inv[*q >> 4]] << 4) | newIdx[inv[*q & 0xf]]);
    }
  }
    n = newIdx[(short)lookup_palette_index_for_rgb_level(0,0,4)];
    *(short *)(unaff_A5 + -0x11fa) = (n << 0xc) | (n << 8) | (n << 4) | n; /* the colour in all four nibbles */
    n = newIdx[(short)lookup_palette_index_for_rgb_level(1,1,1)];
    *(short *)(unaff_A5 + -0x11f8) = (n << 0xc) | (n << 8) | (n << 4) | n;
    break;
  case 8:
  for (k = 0xc8; k < 0xd9; k = k + 1) {
    if ((-1 < oldIdx[k]) && (oldIdx[k] < 0x100)) {
      inv[oldIdx[k]] = k;
    }
  }
  p = *(unsigned char **)*(int *)(unaff_A5 + -0x12b0);                 /* "Bitmap" */
  stride = stride;
  for (rows = *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x14) - *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x10); rows-- != 0; p = p + stride) {
    q = p;
    for (cols = *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x16) - *(short *)(*(int *)(unaff_A5 + -0x1496) + 0x12); cols-- != 0; q = q + 1) {
      *q = (unsigned char)newIdx[inv[*q]];      /* MOVE.B 1(A0): low byte */
    }
  }
  p = *(unsigned char **)*(int *)(unaff_A5 + -0x11dc);                 /* "GyroInstrument" tape */
  stride = *(short *)(unaff_A5 + -0x11de) & 0x1fff;
  for (rows = *(short *)(unaff_A5 + -0x11e2); rows-- != 0; p = p + stride) {
    q = p;
    for (cols = *(short *)(unaff_A5 + -0x11e4); cols-- != 0; q = q + 1) {
      *q = (unsigned char)newIdx[inv[*q]];      /* MOVE.B 1(A0): low byte */
    }
  }
    n = (short)lookup_palette_index_for_rgb_level(0,0,4);
    *(short *)(unaff_A5 + -0x11fa) = (newIdx[n] << 8) | newIdx[n]; /* the colour in both bytes */
    n = (short)lookup_palette_index_for_rgb_level(1,1,1);
    *(short *)(unaff_A5 + -0x11f8) = (newIdx[n] << 8) | newIdx[n];
    break;
  }
  /* palette-index globals read by the panel animation, through the new table */
  *(short *)(unaff_A5 + -0x11ae) = newIdx[(short)lookup_palette_index_for_rgb_level(0,2,0)];
  *(short *)(unaff_A5 + -0x11ac) = newIdx[(short)lookup_palette_index_for_rgb_level(0,0,0)];
  *(short *)(unaff_A5 + -0x11a2) = newIdx[(short)lookup_palette_index_for_rgb_level(3,3,3)];
  if (*(short *)(unaff_A5 + -0x137a) == 4) {
    *(short *)(unaff_A5 + -0x11a2) = (*(short *)(unaff_A5 + -0x11a2) << 4) | *(short *)(unaff_A5 + -0x11a2);
  }
  *(short *)(unaff_A5 + -0x118c) = newIdx[(short)lookup_palette_index_for_rgb_level(0,0,0)];
  *(short *)(unaff_A5 + -0x1188) = newIdx[(short)lookup_palette_index_for_rgb_level(2,2,2)];
  *(short *)(unaff_A5 + -0x118a) = newIdx[(short)lookup_palette_index_for_rgb_level(2,2,2)];
  *(short *)(unaff_A5 + -0x117c) = newIdx[(short)lookup_palette_index_for_rgb_level(2,2,2)];
  *(short *)(unaff_A5 + -0x117e) = newIdx[(short)lookup_palette_index_for_rgb_level(0,0,0)];
  *(short *)(unaff_A5 + -0x112c) = newIdx[(short)lookup_palette_index_for_rgb_level(0,0,0)];
  *(short *)(unaff_A5 + -0x12a4) = newIdx[(short)lookup_palette_index_for_rgb_level(3,3,3)];
  if (*(short *)(unaff_A5 + -0x137a) == 4) {
    *(short *)(unaff_A5 + -0x12a4) = (*(short *)(unaff_A5 + -0x12a4) << 4) | *(short *)(unaff_A5 + -0x12a4);
  }
  return;                                       /* MOVEM restores D5-D7 / A3-A4 */
}



/* VERIFIED (ID03::FUN_000071a2): ID03.bin 0x71a2..0x71d4 checked against an independent capstone disassembly.
 * LINK -$200, save D7; D7 0..255: -$200[D7] = D7; push long A5-0x1354, pea -$200; BSR 0x6c1c; ADDQ #8; restore D7; RTS -
 * identical to the C. */
/* Original: FUN_000071a2; source: ID03.c. Recovered name: remap_panel_colours_identity [STRONG INFERENCE].
 * Decoded from ID03.bin bytes at file 0x71a2.
 * Builds an identity table of 256 words on the stack (t[i] = i) and calls remap_cached_panel_colours(t, the long held at A5-0x1354) (0x6c1c). Note for remap_cached_panel_colours: its first argument is this 256-entry index table and its second is the value of A5-0x1354 (MOVE.L, not its address) [PROVEN, bytes 0x71a2..0x71d4]. Body rewritten as typed C below. Callers: 0x60e2 and 0x6ba8 (prepare_instrument_panel).
 */
void remap_panel_colours_identity /* Original: FUN_000071a2 */ (void)

{
  int unaff_A5;
  short i;                                      /* D7 (saved and restored) */
  short map[256];                               /* -$200(A6) */

  for (i = 0; i < 0x100; i = i + 1) {
    map[i] = i;                                 /* identity colour map */
  }
  remap_cached_panel_colours(map,*(int *)(unaff_A5 + -0x1354)); /* BSR 0x6c1c */
  return;
}


