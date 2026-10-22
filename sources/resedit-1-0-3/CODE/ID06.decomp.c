typedef unsigned char   undefined;

typedef unsigned char    bool;
typedef unsigned int    uint;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned char    byte;


uint DAT_000003ae;
uint DAT_000003ba;
int *DAT_000003be;
int *DAT_000003c2;
int *DAT_000003c6;
int *DAT_000003d2;
int *DAT_0000039e;
int DAT_000003a2;
int DAT_000003a6;
int DAT_000003aa;
uint DAT_000003b2;
uint DAT_000003b6;
uint *DAT_000003ca;
int *DAT_000003ce;
int DAT_00000904;

/* Readable global names (readability pass; the Ghidra name stays the real symbol).
 * render_scanline_spans PC-relative state block 0x39e..0x3d6 (see its VERIFIED note). */
#define CurrentA5 DAT_00000904 /* low-memory global $0904: the application's A5 world */
#define spans_active_base DAT_0000039e /* 0x39e: active edge array base (row table +4 of the edge pool) */
#define spans_band_stride DAT_000003a2 /* 0x3a2: dest stride added after each row (param 3) */
#define spans_list_head DAT_000003a6 /* 0x3a6: priority list head sentinel (edge pool +0x898) */
#define spans_list_tail DAT_000003aa /* 0x3aa: tail sentinel (edge pool +0x89c), stored after the last active edge */
#define spans_saved_d3_prev_x DAT_000003ae /* 0x3ae saved D3: previous edge x (fixed point) for the re-sort test */
#define spans_saved_d4_mask_x DAT_000003b2 /* 0x3b2 saved D4: x >> 6, masked with 0x3e0 to index the left-mask table */
#define spans_saved_d5_edge_x DAT_000003b6 /* 0x3b6 saved D5: edge x advanced by its slope */
#define spans_saved_d6_out_long DAT_000003ba /* 0x3ba saved D6: pending output long (mask-merged span) */
#define spans_saved_d7_active_end DAT_000003be /* 0x3be saved D7: end of the active edge array */
#define spans_saved_a2_row_entry DAT_000003c2 /* 0x3c2 saved A2: current 12-byte row entry (+0 bucket, +4 drop flag, +8 pattern table) */
#define spans_saved_a3_scan DAT_000003c6 /* 0x3c6 saved A3: insertion / compaction scan pointer, nonzero = list dirty */
#define spans_saved_a4_edge DAT_000003ca /* 0x3ca saved A4: current edge node */
#define spans_saved_a5_next_slot DAT_000003ce /* 0x3ce saved A5: next active edge slot */
#define spans_saved_a6_temp DAT_000003d2 /* 0x3d2 saved A6: frame pointer on entry, then a scratch pointer */

/* VERIFIED (ID06::FUN_00000004): ID06.bin 0x4..0xaa checked against an independent capstone disassembly:
 * 32 fill masks x 8 longs into *(A5-0x1eda) (m = m >> 1 | 0x80000000, from 0), then 64 B/W patterns x 8
 * longs, each the byte A5-0x1ed6[i * 8 + j] replicated four times (LSL.L #8 / #16 with OR), then the
 * 256-word map *(A5-0x1ede)[i] = ((i >> 4) * -4 + 0x3f) * 32 + 0x400 (ASR.W #4, LSL.W #2, ASL.W #3 + #2);
 * returns 1 - identical to the C. */
/*
 * Original: FUN_00000004; source: ID06.c:26.
 * Recovered name: init_pattern_tables [STRONG INFERENCE].
 * Exported C complete. Fills the 0xc00-byte table at *(long A5-0x1eda):
 *   bytes 0x000..0x3ff: 32 left masks (0, 0x80000000, 0xc0000000,... each
 *     written to 8 consecutive longs) - partial-word masks indexed by the span
 *     renderer with (x >> 6) & 0x3e0;
 *   bytes 0x400..0xbff: 64 patterns x 8 rows from the 8-byte patterns at
 *     A5-0x1ed6, each byte replicated into a long;
 * and the 256-word map at *(long A5-0x1ede): map[i] = ((i >> 4) * -4 + 0x3f)
 *   * 0x20 + 0x400 (16 grey levels -> pattern offsets). Returns 1.
 */
undefined4 init_pattern_tables /* Original: FUN_00000004 */ (void)

{
  undefined1 pat_byte; /* uVar1: byte j of 8-byte pattern i at A5-0x1ed6 */
  undefined2 pat_word; /* uVar2: pat_byte doubled into a word */
  uint mask; /* uVar3: left mask, m >> 1 | 0x80000000 */
  short row; /* sVar4: long within an 8-long block */
  short i; /* sVar5: mask 0..31, pattern 0..63, then map entry 0..255 */
  uint *out; /* puVar6: write cursor in the 0xc00-byte table *(A5-0x1eda) */
  int unaff_A5;
  
  out = *(uint **)(unaff_A5 + -0x1eda);
  mask = 0;
  for (i = 0; i < 0x20; i = i + 1) {
    for (row = 0; row < 8; row = row + 1) {
      *out = mask;
      out = out + 1;
    }
    mask = mask >> 1 | 0x80000000;
  }
  for (i = 0; i < 0x40; i = i + 1) {
    for (row = 0; row < 8; row = row + 1) {
      pat_byte = *(undefined1 *)(unaff_A5 + -0x1ed6 + (int)(short)(row + i * 8));
      pat_word = CONCAT11(pat_byte,pat_byte);
      *out = CONCAT22(pat_word,pat_word);
      out = out + 1;
    }
  }
  for (i = 0; i < 0x100; i = i + 1) {
    *(short *)(*(int *)(unaff_A5 + -0x1ede) + i * 2) = ((i >> 4) * -4 + 0x3f) * 0x20 + 0x400
    ;
  }
  return 1;
}



/* VERIFIED (ID06::FUN_000000b0): ID06.bin 0xb0..0xec checked against an independent capstone disassembly:
 * lazily alloc_aligned_clear(0xc00) -> A5-0x1eda and (0x200) -> A5-0x1ede (JSR 0x1dc), 0 on failure, then
 * JSR 0x4 init_pattern_tables and return its D0 - identical to the C. */
/*
 * Original: FUN_000000b0; source: ID06.c:63.
 * Recovered name: alloc_pattern_tables [STRONG INFERENCE].
 * Exported C complete: allocates (once) A5-0x1eda = alloc_aligned_clear(0xc00)
 * and A5-0x1ede = alloc_aligned_clear(0x200); returns init_pattern_tables
 * or 0 on failure. Called first by init_raster_target.
 */
undefined4 alloc_pattern_tables /* Original: FUN_000000b0 */ (void)

{
  uint block; /* uVar1: alloc_aligned_clear result */
  undefined4 result; /* uVar2: init_pattern_tables result */
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1eda) == 0) {
    block = alloc_aligned_clear(0xc00);
    *(uint *)(unaff_A5 + -0x1eda) = block;
    if (block == 0) {
      return 0;
    }
  }
  if (*(int *)(unaff_A5 + -0x1ede) == 0) {
    block = alloc_aligned_clear(0x200);
    *(uint *)(unaff_A5 + -0x1ede) = block;
    if (block == 0) {
      return 0;
    }
  }
  result = init_pattern_tables();
  return result;
}



/* VERIFIED (ID06::FUN_000000f4): ID06.bin 0xf4..0x114 checked against an independent capstone disassembly:
 * when A5-0x1eda is 0, JSR $1dc(PC) = alloc_aligned_clear(0xc00), store, and return 0 on failure;
 * otherwise return A5-0x1eda - identical to the C. */
/*
 * Original: FUN_000000f4; source: ID06.c:90.
 * Recovered name: get_pattern_table [STRONG INFERENCE].
 * Exported C complete: ensures A5-0x1eda is allocated and returns it (stored
 * as raster target +0xc by init_raster_target).
 */
undefined4 get_pattern_table /* Original: FUN_000000f4 */ (void)

{
  uint block; /* uVar1: alloc_aligned_clear(0xc00) result */
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1eda) == 0) {
    block = alloc_aligned_clear(0xc00);
    *(uint *)(unaff_A5 + -0x1eda) = block;
    if (block == 0) {
      return 0;
    }
  }
  return *(undefined4 *)(unaff_A5 + -0x1eda);
}



/* VERIFIED (ID06::FUN_00000116): ID06.bin 0x116..0x158 checked against an independent capstone disassembly
 * (Ghidra address = file offset): words r / g / b at 8 / $a / $c(A6), each LSR.W #8 then MULS.W 0x13 /
 * 0x26 / 7, ADD.W, LSR.W #6 (unsigned, the C's ushort), ASR.W #2 (the C's short), 0x3f - that, ASL.W #3,
 * ADDA.W (sign-extended) to A5-0x1ed6 - identical to the C. */
/*
 * Original: FUN_00000116; source: ID06.c:108.
 * Recovered name: rgb_to_bw_pattern [STRONG INFERENCE].
 * Exported C complete. Words r = param_1 high, g = param_1 low, b = param_2
 * high (16-bit components; only their high bytes are used).
 * luma = ((r>>8)*0x13 + (g>>8)*0x26 + (b>>8)*7) >> 6  (19/38/7 out of 64:
 * the usual 0.30/0.59/0.11 weights); returns A5-0x1ed6 + (0x3f - (luma>>2)) * 8,
 * i.e. an 8-byte pattern chosen by inverse brightness (64 levels) for 1-bit
 * output [STRONG INFERENCE].
 */
int rgb_to_bw_pattern /* Original: FUN_00000116 */ (undefined4 red_green /* param_1: high word red, low word green */,undefined4 blue /* param_2: high word blue */)

{
  int unaff_A5;
  
  return (int)(short)((0x3f - ((short)((ushort)((blue._0_2_ >> 8) * 7 +
                                               (red_green._2_2_ >> 8) * 0x26 +
                                               (red_green._0_2_ >> 8) * 0x13) >> 6) >> 2)) * 8) +
         unaff_A5 + -0x1ed6;
}



/* VERIFIED (ID06::FUN_0000017c): ID06.bin 0x17c..0x1a0 checked against an independent capstone disassembly:
 * CMPI.W #$100 / BLT (signed) clamps to 0xff, EXT.L index * 2 into the word table *(A5-0x1ede), MOVE.W
 * (A0),D0 leaves the address's high word in D0 (Ghidra's CONCAT22). The C compared and indexed the
 * unsigned half-word; corrected to (short) so words >= 0x8000 index negatively as the bytes do -
 * otherwise identical to the C. */
/*
 * Original: FUN_0000017c; source: ID06.c:121.
 * Recovered name: lookup_colour_map [STRONG INFERENCE].
 * Exported C complete: i = min(word param, 0xff); returns word table
 * (*(long A5-0x1ede))[i] (low word of result; high word is pointer residue).
 * Used by init_row_table_fields for row table +8.
 */
undefined4 lookup_colour_map /* Original: FUN_0000017c */ (undefined4 level /* param_1: high word = map index, clamped to 0xff */)

{
  undefined2 *entry; /* puVar1: word entry in *(A5-0x1ede) */
  int unaff_A5;
  
  if (0xff < (short)level._0_2_) { /* CORRECTED [PROVEN]: CMPI.W #$100 / BLT is a signed word compare */
    level._0_2_ = 0xff;
  }
  entry = (undefined2 *)(*(int *)(unaff_A5 + -0x1ede) + (short)level._0_2_ * 2); /* EXT.L: signed index */
  return CONCAT22((short)((uint)entry >> 0x10),*entry);
}



/* VERIFIED (ID06::FUN_000001a2): ID06.bin 0x1a2..0x1da checked against an independent capstone disassembly:
 * signed word loop 0..0xff (CMPI.W #$100 / BLT) over the word table *(A5-0x1ede) (EXT.L * 2); on a match
 * MOVE.W D6,D0 keeps the address's high word (Ghidra's CONCAT22), else MOVEQ #0 - identical to the C. */
/*
 * Original: FUN_000001a2; source: ID06.c:136.
 * Recovered name: reverse_lookup_colour_map [STRONG INFERENCE].
 * Exported C complete: first i in 0..255 with table[i] == word param, else 0.
 * Inverse of lookup_colour_map.
 */
undefined4 reverse_lookup_colour_map /* Original: FUN_000001a2 */ (undefined4 value /* param_1: high word = map value to find */)

{
  short *entry; /* psVar1: word entry in *(A5-0x1ede) */
  short i; /* sVar2: map index 0..255 */
  int unaff_A5;
  
  i = 0;
  while( true ) {
    if (0xff < i) {
      return 0;
    }
    entry = (short *)(*(int *)(unaff_A5 + -0x1ede) + i * 2);
    if (value._0_2_ == *entry) break;
    i = i + 1;
  }
  return CONCAT22((short)((uint)entry >> 0x10),i);
}



// WARNING: Type propagation algorithm not settling

/*
 * Original: FUN_000001dc; source: ID06.c:159.
 * Recovered name: alloc_aligned_clear [STRONG INFERENCE].
 * Exported C complete. If FreeMem (JT $212) < 500000, MaxMem (JT $21a) to
 * compact; p = NewPtrClear(size + 12) (JT $232); returns 0 on failure, else
 * a = (p + 12) & ~3 with *(a-4) = size and *(a-8) = p (header for free_aligned).
 * 4-byte-aligned zeroed allocation [STRONG INFERENCE]. Ghidra's piVar3 stack
 * modelling is an artifact.
 */
/* VERIFIED (ID06::FUN_000001dc): ID06.bin 0x1dc..0x24a checked against an independent capstone disassembly.
 * Jump-table slots resolved through CODE 0 to ID09 Memory Manager glue: $212 -> 0x1b2 _FreeMem ($A01C),
 * $21a -> 0x1bc _MaxMem ($A11D; the glue stores A0 through the VAR grow argument), $232 -> 0x20c
 * _NewPtrClear ($A31E). grow (-$c) = 0; FreeMem() < 500000 (CMPI.L #$7a120 / BGE) -> MaxMem(&grow), whose
 * results are unused (heap compaction / purge); raw = NewPtrClear(size + 0xc) (PEA $c(A0)); 0 on failure;
 * otherwise the block is (raw + 0xc) & ~3 with size at -4 and raw at -8 (read back by free_aligned) -
 * identical to the C (reconstructed from the bytes; Ghidra's form simulated the glue's stack slots). */
uint alloc_aligned_clear /* Original: FUN_000001dc */ (int size)

{
  long grow;                                  /* -$c */
  Ptr raw;                                    /* -$8 */
  uint block;                                 /* -$4 */

  grow = 0;
  if (FreeMem() < 500000) {                   /* JT $212 -> ID09 0x1b2 _FreeMem */
    MaxMem(&grow);                            /* JT $21a -> ID09 0x1bc _MaxMem; result unused */
  }
  raw = NewPtrClear(size + 0xc);              /* JT $232 -> ID09 0x20c _NewPtrClear */
  if (raw == (Ptr)0) {
    return 0;
  }
  block = (uint)raw + 0xc & 0xfffffffc;
  *(int *)(block - 4) = size;
  *(Ptr *)(block - 8) = raw;
  return block;
}



/* VERIFIED (ID06::FUN_0000024c): ID06.bin 0x24c..0x26a checked against an independent capstone disassembly:
 * TST.L p; 0 -> D0 = 0; else JSR $23a(A5) (DisposPtr glue, callee pops) on *(p - 8) and D0 = 1 - identical
 * to the C. */
/*
 * Original: FUN_0000024c; source: ID06.c:195.
 * Recovered name: free_aligned [STRONG INFERENCE].
 * Exported C complete: if p != 0, DisposPtr(*(p - 8)) (JT $23a); returns p != 0.
 * Frees a block from alloc_aligned_clear.
 */
bool free_aligned /* Original: FUN_0000024c */ (int block /* param_1: block from alloc_aligned_clear */)

{
  int unaff_A5;
  
  if (block != 0) {
    (**(code **)(unaff_A5 + 0x23a))(*(undefined4 *)(block + -8));
  }
  return block != 0;
}



/* VERIFIED (ID06::FUN_0000026c): ID06.bin 0x26c..0x316 checked against an independent capstone disassembly:
 * row table +0 = A5 + 0x192; +8 = lookup_colour_map(8(A6) word) (JSR 0x17c, one word pushed - Ghidra's
 * CONCAT22 low half is unread); +0xa = 0xb; +0xc = target +4 - (short)(target +8 * target +6) / 8 (MULS.W, EXT.L
 * of the low word, DIVS.W); for i < $a(A6) word: rows[+4][i] +8 = target +0xc + (i % 8) * 4; +0xe = that
 * count, +0x10 = +0x14 = 0; returns 1 - identical to the C. */
/*
 * Original: FUN_0000026c; source: ID06.c:208.
 * Recovered name: init_row_table_fields [STRONG INFERENCE].
 * Overlay service slot (not in service table).
 * Exported C complete. Row table +0 = JT A5+0x192 (renderer callback);
 * +8 = FUN_0000017c(...); +0xa = 11 (fixed-point shift); +0xc = target +4
 * width * target +6 / 8 (row stride remainder); row entry +8 = target +0xc +
 * (row % 8) * 4 (8-row repeating table: dither pattern [HYPOTHESIS]);
 * +0xe = rows; +0x10 = +0x14 = 0. Returns 1. Caller: alloc_row_table.
 */
undefined4 init_row_table_fields /* Original: FUN_0000026c */ (undefined4 level_rows /* param_1: high word = colour level, low word = row count */)

{
  undefined4 map_word; /* uVar1: lookup_colour_map result */
  undefined4 d7_in; /* caller D7 (register input); only its high word reaches lookup_colour_map */
  short row; /* sVar2: row index */
  int unaff_A5;
  
  **(int **)(unaff_A5 + -0x1cd2) = unaff_A5 + 0x192;
  map_word = lookup_colour_map(CONCAT22(level_rows._0_2_,(short)((uint)d7_in >> 0x10)));
  *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 8) = (short)map_word;
  *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 10) = 0xb;
  *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xc) =
       *(short *)(*(int *)(unaff_A5 + -0x1cce) + 4) -
       (short)(*(short *)(*(int *)(unaff_A5 + -0x1cce) + 8) *
              *(short *)(*(int *)(unaff_A5 + -0x1cce) + 6)) / 8;
  for (row = 0; row < level_rows._2_2_; row = row + 1) {
    *(int *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + row * 0xc + 8) =
         *(int *)(*(int *)(unaff_A5 + -0x1cce) + 0xc) + (row % 8) * 4;
  }
  *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe) = level_rows._2_2_;
  *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd2) + 0x10) = 0;
  *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd2) + 0x14) = 0;
  return 1;
}



/* VERIFIED (ID06::FUN_00000318): ID06.bin 0x318..0x510 checked against an independent capstone disassembly.
 * Hand-written register routine: its state lives in the PC-relative block 0x39e..0x3d6 (BRA over it at
 * 0x39c) - 0x39e active base, 0x3a2 stride, 0x3a6 head, 0x3aa tail, then d3, d4, d5, d6, d7, a2, a3, a4,
 * a5, a6 at 0x3ae..0x3d2 (MOVEM (A1) on a continue call, MOVEM to 0x3ae on exit); Ghidra's DAT_000003xx
 * cells are exactly those registers, and A5 / A6 serve as general registers inside the loop (no A5
 * globals are read there). First band: base / stride / head / tail stored, d7 = a5 = base, a3 = 0,
 * *base = tail, d6 left from the caller (unaff_D6), a6 = frame pointer. Per row: bucket edges
 * insertion-sorted into the active array (head sentinel at base - 4 bounds the scan); with the row flag,
 * edges whose +0x22 equals the row counter compacted out; priority list rebuilt only if a3 | flag | new
 * edges is non-zero (the C carries a3 in DAT_000003c6): node +0x1e = current top colour, NOT.W parity
 * +0x20 removes or key-orders (+0x24, BGT) the polygon in the +0x10 / +0x14 list, then *end = tail; spans:
 * mask = pattern[(prev x >> 6) & 0x3e0], d6 = (d6 & mask) | (~mask & colour) (AND / NOT / AND / OR), stored
 * dbra-count times (entered at DBRA), x += slope with insertion re-sort, walk through the tail sentinel
 * (BLS); dest += stride; DBRA over the rows - identical to the C. */
/*
 * Original: FUN_00000318; source: ID06.c:236.
 * Recovered name: render_scanline_spans [STRONG INFERENCE].
 * Renderer callback installed by init_row_table_fields (JT A5+0x192); called by
 * rasterize_and_present. Args: param_1 = (word continue_flag, word rows),
 * uint *dest, long stride (added after each row).
 * In-code state [PROVEN, bytes]: BRA.B at file 0x39c skips a 0x44-byte
 * zero-filled block 0x39e..0x3e1; Ghidra's DAT_0000039e..DAT_000003d2 are
 * these PC-relative cells (self-modifying data kept across band calls). The
 * first band (continue_flag == 0) initialises them.
 * Per row [STRONG INFERENCE from the exported C]:
 *   1. insert the row bucket's new edge nodes into the active edge array
 *      (insertion sort on x, node +0);
 *   2. drop edges whose remaining-row counter (+0x22) equals the row;
 *   3. walk edges left to right: each crossing complements the owning
 *      polygon's parity word (first node +0x20) and inserts/removes the polygon
 *      in a priority-ordered open list (+0x24 key, links +0x10/+0x14 between the
 *      pool sentinels); the topmost polygon's colour (+0x1c -> +0x1e) selects a
 *      long from the row's pattern table (row entry +8), and longs are stored
 *      to dest between crossings, with mask merging (uVar7 & ~uVar3 |...) for
 *      partial words;
 *   4. advance each edge x by its slope (+4) and re-sort.
 * Painter-style priority span fill of the polygons from add_polygon_edges.
 */
void render_scanline_spans /* Original: FUN_00000318 */ (undefined4 band /* param_1: high word = continue flag (0 = first band), low word = rows */,uint *dest /* param_2: output long cursor */,int stride /* param_3: bytes added to dest after each row */)

{
  uint edge_x; /* uVar1: edge node x long (high word = pixel x) */
  int work; /* iVar2: scratch: tail sentinel, new edge x, drop flag, polygon, then the row's pattern table */
  uint left_mask; /* uVar3: left mask from the pattern table, (x >> 6) & 0x3e0 */
  ushort parity; /* uVar4: complemented polygon parity word +0x20 */
  int head; /* iVar5: priority list head sentinel */
  short rows_left; /* sVar6: row countdown */
  uint x_or_colour; /* uVar7: previous edge x word, then the colour pattern long */
  short run_len; /* sVar8: whole longs to store before the next crossing */
  uint d6_in; /* caller D6 (register input), saved into spans_saved_d6_out_long */
  int *edges; /* piVar9: active edge array, new-edge cursor, then compacted end */
  int *cursor; /* piVar10: insert / compaction write / walk cursor, then next row entry */
  int node; /* iVar11: priority list node */
  int unaff_A5;
  int *scan; /* piVar12: active array read pointer */
  int *walk; /* piVar14: row entries, new-edge bucket, then the span walk pointer */
  int *scan_next; /* piVar13: scan + 1 */
  
  edges = (int *)(*(int *)(unaff_A5 + -0x1cd6) + 4);
  work = *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c);
  walk = *(int **)(*(int *)(unaff_A5 + -0x1cd2) + 4);
  rows_left = band._2_2_ + -1;
  if (band._0_2_ == 0) {
    spans_band_stride = stride;
    spans_saved_a3_scan = (int *)0x0;
    spans_active_base = edges;
    spans_list_head = *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898);
    spans_list_tail = work;
    *edges = work;
    spans_saved_d6_out_long = d6_in;
    spans_saved_d7_active_end = edges;
    spans_saved_a2_row_entry = walk;
    spans_saved_a6_temp = (int *)&stack0xfffffffc;
  }
  do {
    walk = (int *)*spans_saved_a2_row_entry;
    for (edges = walk; edges != (int *)0x0; edges = (int *)edges[3]) {
      work = edges[2];
      *edges = work;
      spans_saved_a3_scan = spans_saved_d7_active_end;
      do {
        cursor = spans_saved_a3_scan;
        spans_saved_a3_scan = cursor + -1;
        *cursor = *spans_saved_a3_scan;
      } while (work < *(int *)*spans_saved_a3_scan);
      *cursor = (int)edges;
      spans_saved_d7_active_end = spans_saved_d7_active_end + 1;
    }
    work = spans_saved_a2_row_entry[1];
    edges = spans_saved_d7_active_end;
    cursor = spans_active_base;
    scan = spans_active_base;
    if (work != 0) {
      do {
        scan_next = scan + 1;
        edges = cursor;
        if (rows_left != *(short *)(*scan + 0x22)) {
          edges = cursor + 1;
          *cursor = *scan;
        }
        cursor = edges;
        spans_saved_a3_scan = edges;
        scan = scan_next;
      } while (scan_next < spans_saved_d7_active_end);
    }
    head = spans_list_head;
    cursor = spans_active_base;
    if (walk != (int *)0x0 || (work != 0 || spans_saved_a3_scan != (int *)0x0)) {
      while (cursor < edges) {
        work = *cursor;
        *(undefined2 *)(work + 0x1e) = *(undefined2 *)(*(int *)(head + 0x10) + 0x1c);
        work = *(int *)(work + 0x18);
        parity = ~*(ushort *)(work + 0x20);
        *(ushort *)(work + 0x20) = parity;
        node = head;
        if (parity == 0) {
          node = *(int *)(work + 0x14);
          work = *(int *)(work + 0x10);
          *(int *)(node + 0x10) = work;
          *(int *)(work + 0x14) = node;
          cursor = cursor + 1;
        }
        else {
          do {
            node = *(int *)(node + 0x10);
          } while (*(short *)(work + 0x24) < *(short *)(node + 0x24));
          *(int *)(work + 0x10) = node;
          spans_saved_a6_temp = *(int **)(node + 0x14);
          *(int **)(work + 0x14) = spans_saved_a6_temp;
          *(int *)(node + 0x14) = work;
          spans_saved_a6_temp[4] = work;
          cursor = cursor + 1;
        }
      }
      spans_saved_a3_scan = (int *)0x0;
      *cursor = spans_list_tail;
    }
    cursor = spans_saved_a2_row_entry + 3;
    work = spans_saved_a2_row_entry[2];
    spans_saved_d4_mask_x = 0;
    x_or_colour = 0;
    spans_saved_d5_edge_x = 0;
    walk = spans_active_base;
    do {
      spans_saved_d3_prev_x = spans_saved_d5_edge_x;
      spans_saved_a5_next_slot = walk + 1;
      spans_saved_a4_edge = (uint *)*walk;
      edge_x = *spans_saved_a4_edge;
      left_mask = *(uint *)(work + (short)((ushort)spans_saved_d4_mask_x & 0x3e0));
      run_len = (short)(edge_x >> 0x10) - (short)x_or_colour;
      x_or_colour = *(uint *)(work + *(short *)((int)spans_saved_a4_edge + 0x1e));
      spans_saved_d6_out_long = x_or_colour & ~left_mask | left_mask & spans_saved_d6_out_long;
      while (run_len = run_len + -1, run_len != -1) {
        *dest = spans_saved_d6_out_long;
        spans_saved_d6_out_long = x_or_colour;
        dest = dest + 1;
      }
      spans_saved_d5_edge_x = spans_saved_a4_edge[1] + edge_x;
      x_or_colour = edge_x >> 0x10;
      spans_saved_d4_mask_x = edge_x >> 6;
      *spans_saved_a4_edge = spans_saved_d5_edge_x;
      if ((int)spans_saved_d5_edge_x < (int)spans_saved_d3_prev_x) {
        do {
          scan = walk;
          spans_saved_a3_scan = scan + -1;
          spans_saved_a6_temp = (int *)*spans_saved_a3_scan;
          *scan = (int)spans_saved_a6_temp;
          walk = spans_saved_a3_scan;
        } while ((int)spans_saved_d5_edge_x < *spans_saved_a6_temp);
        *scan = (int)spans_saved_a4_edge;
        spans_saved_d5_edge_x = spans_saved_d3_prev_x;
      }
      walk = spans_saved_a5_next_slot;
    } while (spans_saved_a5_next_slot <= edges);
    dest = (uint *)(spans_band_stride + (int)dest);
    rows_left = rows_left + -1;
    spans_saved_d7_active_end = edges;
    spans_saved_a2_row_entry = cursor;
  } while (rows_left != -1);
  return;
}



/* VERIFIED (ID06::FUN_00000512): ID06.bin 0x512..0x580 checked against an independent capstone disassembly:
 * free_aligned (JSR 0x24c) on row table +4, +0x1c, +0x20 when set, then the table itself, then A5-0x1cd2 =
 * 0 - identical to the C. */
/*
 * Original: FUN_00000512; source: ID06.c:382.
 * Recovered name: free_row_table [STRONG INFERENCE].
 * Exported C complete. Frees (free_aligned) the row-entry array (+4), the
 * buffers at +0x1c and +0x20, then the 0x24-byte row-table record at
 * long A5-0x1cd2, and clears A5-0x1cd2.
 */
void free_row_table /* Original: FUN_00000512 */ (void)

{
  int unaff_A5;
  
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) && (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) != 0)) {
    free_aligned(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4));
  }
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) && (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x1c) != 0)) {
    free_aligned(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x1c));
  }
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) && (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x20) != 0)) {
    free_aligned(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x20));
  }
  if (*(int *)(unaff_A5 + -0x1cd2) != 0) {
    free_aligned(*(int *)(unaff_A5 + -0x1cd2));
  }
  *(undefined4 *)(unaff_A5 + -0x1cd2) = 0;
  return;
}



/* VERIFIED (ID06::FUN_00000598): ID06.bin 0x598..0x664 checked against an independent capstone disassembly:
 * 0 without a target; free_row_table (JSR 0x512) when the table holds fewer rows than $a(A6); if none,
 * alloc_aligned_clear(0x24) -> A5-0x1cd2 and (rows * 12, MULU.L #$c of the sign-extended word) -> +4, 0 on
 * failure; clears the three longs of each row; tail call init_row_table_fields(8(A6), $a(A6) words) -
 * identical to the C. */
/*
 * Original: FUN_00000598; source: ID06.c:405.
 * Recovered name: alloc_row_table [STRONG INFERENCE].
 * Exported C complete. Requires the target record (A5-0x1cce). n = low word of
 * param_1 (the target height when called from init_raster_target). If an
 * existing table has fewer than n entries (+0xe), it is freed; otherwise
 * reused. Allocates (alloc_aligned_clear) the 0x24-byte record -> A5-0x1cd2 and
 * n * 12 bytes of entries -> record+4, clears every entry, then returns
 * FUN_0000026c(param_1). One 12-byte entry per raster row [STRONG INFERENCE].
 */
undefined4 alloc_row_table /* Original: FUN_00000598 */ (undefined4 level_rows /* param_1: high word = colour level, low word = row count */)

{
  uint block; /* uVar1: alloc_aligned_clear result */
  undefined4 result; /* uVar2: init_row_table_fields result */
  short row; /* sVar3: row entry index */
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1cce) == 0) {
    return 0;
  }
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) &&
     (*(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe) < level_rows._2_2_)) {
    free_row_table();
  }
  if (*(int *)(unaff_A5 + -0x1cd2) == 0) {
    block = alloc_aligned_clear(0x24);
    *(uint *)(unaff_A5 + -0x1cd2) = block;
    if (block == 0) {
      return 0;
    }
    block = alloc_aligned_clear(level_rows._2_2_ * 0xc);
    *(uint *)(*(int *)(unaff_A5 + -0x1cd2) + 4) = block;
    if (block == 0) {
      return 0;
    }
  }
  for (row = 0; row < level_rows._2_2_; row = row + 1) {
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + row * 0xc) = 0;
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + row * 0xc + 4) = 0;
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + row * 0xc + 8) = 0;
  }
  result = init_row_table_fields(level_rows);
  return result;
}



/* VERIFIED (ID06::FUN_00000666): ID06.bin 0x666..0x7ae checked against an independent capstone disassembly:
 * 0 without a row table; pool alloc_aligned_clear(0x5e9c) once -> A5-0x1cd6; head +0x898 = pool + 0x8ac,
 * tail +0x89c = pool + 0x5e74, cross-linked through +0x10 / +0x14; head +0 = 0; both sentinels +0x1c /
 * +0x1e = row table word +8 and +0x22 = -10; tail +0 = (sign-extended target +8) LSL.L by (row table +0x10
 * + sign-extended +0xa) (count mod 64, the C's & 0x3f); pool +0 = head; +0x8a0 = +0x8a4 = pool + 0x8d4;
 * +0x8a8 = pool + 0x5b7c; returns 1 - identical to the C. */
/*
 * Original: FUN_00000666; source: ID06.c:443.
 * Recovered name: init_edge_pool [STRONG INFERENCE].
 * Exported C complete. Requires A5-0x1cd2. Allocates once a 0x5e9c-byte block
 * -> A5-0x1cd6; head sentinel +0x898 -> block+0x8ac, tail sentinel +0x89c ->
 * block+0x5e74, linked to each other through +0x10 / +0x14; sentinel fields
 * +0x1c/+0x1e = row-table word +8, +0x22 = -10; tail +0 = target word +8 <<
 * (row-table +0x10 + row-table word +0xa); block+0 = head; free cursor
 * +0x8a0 = +0x8a4 = block+0x8d4; +0x8a8 = block+0x5b7c. Returns 1.
 * [HYPOTHESIS] Edge / span node pool for the rasterizer.
 */
undefined4 init_edge_pool /* Original: FUN_00000666 */ (void)

{
  undefined4 result; /* uVar1: 0 without a row table, else 1 */
  uint block; /* uVar2: alloc_aligned_clear(0x5e9c) result */
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1cd2) == 0) {
    result = 0;
  }
  else {
    if (*(int *)(unaff_A5 + -0x1cd6) == 0) {
      block = alloc_aligned_clear(0x5e9c);
      *(uint *)(unaff_A5 + -0x1cd6) = block;
      if (block == 0) {
        return 0;
      }
    }
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) = *(int *)(unaff_A5 + -0x1cd6) + 0x8ac;
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) = *(int *)(unaff_A5 + -0x1cd6) + 0x5e74;
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x10) =
         *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c);
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x14) =
         *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898);
    **(undefined4 **)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) = 0;
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x1c) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x1e) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x22) = 0xfff6;
    **(int **)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) =
         (int)*(short *)(*(int *)(unaff_A5 + -0x1cce) + 8) <<
         (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x10) +
          (int)*(short *)(*(int *)(unaff_A5 + -0x1cd2) + 10) & 0x3fU);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x1c) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x1e) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x22) = 0xfff6;
    **(undefined4 **)(unaff_A5 + -0x1cd6) = *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898);
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0) = *(int *)(unaff_A5 + -0x1cd6) + 0x8d4;
    *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a4) =
         *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0);
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a8) = *(int *)(unaff_A5 + -0x1cd6) + 0x5b7c;
    result = 1;
  }
  return result;
}



/* VERIFIED (ID06::FUN_000007b0): ID06.bin 0x7b0..0x856 checked against an independent capstone disassembly:
 * alloc_pattern_tables (JSR 0xb0, TST.W), target record alloc_aligned_clear(0x10) once -> A5-0x1cce,
 * +0 = 8(A6), +4 = $c word, +6 = 1, +8 = $10 word, +$a = $12 word, +$c = get_pattern_table (JSR 0xf4);
 * alloc_row_table($e, $12 words) (JSR 0x598), init_edge_pool (JSR 0x666), each 0 on a zero word result;
 * centre A5-0x1cca / -0x1cc8 = width / height ASR.W #1 (the C's half-words corrected to (short) so the
 * shift is arithmetic as in the bytes); returns 1 - otherwise identical to the C. */
/*
 * Original: FUN_000007b0; source: ID06.c:494.
 * Recovered name: init_raster_target [STRONG INFERENCE].
 * Exported C complete. If FUN_000000b0 != 0: allocate (once) the 16-byte
 * target record -> A5-0x1cce: +0 = param_1 (pixel base), +4 = param_2 high
 * word, +6 = 1, +8 = param_3 high word (width), +0xa = param_3 low word
 * (height), +0xc = FUN_000000f4; alloc_row_table(param_2 low, height);
 * init_edge_pool; A5-0x1cca = width >> 1, A5-0x1cc8 = height >> 1 (centre).
 * Returns 1 on success, 0 on any failure.
 */
undefined4 init_raster_target /* Original: FUN_000007b0 */ (undefined4 pixel_base /* param_1: target +0, pixel base */,undefined4 rowbytes_level /* param_2: high word -> target +4 (row bytes [STRONG INFERENCE]), low word = colour level */,undefined4 width_height /* param_3: high word = width, low word = height */)

{
  undefined4 result; /* uVar1: callee result / return value */
  uint block; /* uVar2: alloc_aligned_clear(0x10) result */
  int unaff_A5;
  
  result = alloc_pattern_tables();
  if ((short)result == 0) {
    result = 0;
  }
  else {
    if (*(int *)(unaff_A5 + -0x1cce) == 0) {
      block = alloc_aligned_clear(0x10);
      *(uint *)(unaff_A5 + -0x1cce) = block;
      if (block == 0) {
        return 0;
      }
    }
    **(undefined4 **)(unaff_A5 + -0x1cce) = pixel_base;
    *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 4) = rowbytes_level._0_2_;
    *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 6) = 1;
    *(short *)(*(int *)(unaff_A5 + -0x1cce) + 8) = width_height._0_2_;
    *(short *)(*(int *)(unaff_A5 + -0x1cce) + 10) = width_height._2_2_;
    result = get_pattern_table();
    *(undefined4 *)(*(int *)(unaff_A5 + -0x1cce) + 0xc) = result;
    result = alloc_row_table(CONCAT22(rowbytes_level._2_2_,width_height._2_2_));
    if ((short)result == 0) {
      result = 0;
    }
    else {
      result = init_edge_pool();
      if ((short)result == 0) {
        result = 0;
      }
      else {
        *(short *)(unaff_A5 + -0x1cca) = (short)width_height._0_2_ >> 1; /* CORRECTED [PROVEN]: ASR.W #1, arithmetic */
        *(short *)(unaff_A5 + -0x1cc8) = (short)width_height._2_2_ >> 1; /* CORRECTED [PROVEN]: ASR.W #1, arithmetic */
        result = 1;
      }
    }
  }
  return result;
}



/* VERIFIED (ID06::FUN_0000087a): ID06.bin 0x87a..0x88e checked against an independent capstone disassembly:
 * if the target A5-0x1cce is set, its +0 = 8(A6) - identical to the C. */
/*
 * Original: FUN_0000087a; source: ID06.c:541.
 * Recovered name: set_raster_target_base [STRONG INFERENCE].
 * Exported C complete: if target record exists, its +0 (pixel base) =
 * param_1. Used to retarget rendering to another buffer [STRONG INFERENCE].
 */
void set_raster_target_base /* Original: FUN_0000087a */ (undefined4 pixel_base /* param_1: new target +0 pixel base */)

{
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1cce) != 0) {
    **(undefined4 **)(unaff_A5 + -0x1cce) = pixel_base;
  }
  return;
}



/* VERIFIED (ID06::FUN_000008a2): ID06.bin 0x8a2..0x900 checked against an independent capstone disassembly:
 * saves A5 / D2 and loads A5 from CurrentA5 ($904 = Ghidra's DAT_00000904); with target and row table
 * present, param clamped to the target height (+0xa, sign-extended, CMPA.L / BLT) when larger or < 1
 * (CMPI.L #1 / BGE), its low word stored at row table +0xe; then A5-0x1cc6 = row table +0xe
 * unconditionally (even with no row table, as in the C) - identical to the C. */
/*
 * Original: FUN_000008a2; source: ID06.c:554.
 * Recovered name: set_active_row_count [STRONG INFERENCE].
 * Overlay service slot A5-0x1304 (JT $1a2).
 * Exported C complete; CurrentA5 routine. If target and row table exist,
 * n = param_1 clamped to [1, target height (+0xa)] (out-of-range -> height);
 * row table +0xe = n (rows processed). A5-0x1cc6 = row table +0xe.
 */
void set_active_row_count /* Original: FUN_000008a2 */ (int rows /* param_1: requested row count, clamped to [1, height] */)

{
  int a5; /* iVar1: CurrentA5 copy */
  
  a5 = CurrentA5;
  if ((*(int *)(CurrentA5 + -0x1cce) != 0) && (*(int *)(CurrentA5 + -0x1cd2) != 0)) {
    if ((*(short *)(*(int *)(CurrentA5 + -0x1cce) + 10) < rows) || (rows < 1)) {
      rows = (int)*(short *)(*(int *)(CurrentA5 + -0x1cce) + 10);
    }
    *(undefined2 *)(*(int *)(CurrentA5 + -0x1cd2) + 0xe) = rows._2_2_;
  }
  *(undefined2 *)(a5 + -0x1cc6) = *(undefined2 *)(*(int *)(a5 + -0x1cd2) + 0xe);
  return;
}



/* VERIFIED (ID06::FUN_00000916): ID06.bin 0x916..0x940 checked against an independent capstone disassembly:
 * if the target A5-0x1cce is set, *8(A6) = its +8 word, *$c(A6) = its +$a word, D0 = 1, else 0 - identical
 * to the C. */
/*
 * Original: FUN_00000916; source: ID06.c:572.
 * Recovered name: get_raster_target_size [STRONG INFERENCE].
 * Exported C complete: if the target exists, *param_1 = width (+8),
 * *param_2 = height (+0xa); returns whether it exists.
 */
bool get_raster_target_size /* Original: FUN_00000916 */ (undefined2 *width /* param_1: out, target width (+8) */,undefined2 *height /* param_2: out, target height (+0xa) */)

{
  int unaff_A5;
  bool has_target; /* bVar1: target record A5-0x1cce exists */
  
  has_target = *(int *)(unaff_A5 + -0x1cce) != 0;
  if (has_target) {
    *width = *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 8);
    *height = *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 10);
  }
  return has_target;
}



/* VERIFIED (ID06::FUN_00000942): ID06.bin 0x942..0x96c checked against an independent capstone disassembly:
 * pushes the row count word then 8(A6) word (the same four bytes as Ghidra's CONCAT22 argument), JSR 0x598
 * alloc_row_table; TST.W D0 zero -> 0, else JSR 0x666 init_edge_pool and 0 when its word result is 0,
 * otherwise its D0 - identical to the C. */
/*
 * Original: FUN_00000942; source: ID06.c:588.
 * Recovered name: realloc_row_table [STRONG INFERENCE].
 * Exported C complete: alloc_row_table((word param, current active rows))
 * then init_edge_pool; returns 0 on failure. Rebuilds the row table and node
 * pool [STRONG INFERENCE: param word is passed as row-table word +8 source].
 */
undefined4 realloc_row_table /* Original: FUN_00000942 */ (undefined4 level /* param_1: high word = colour level for alloc_row_table */)

{
  undefined4 result; /* uVar1: callee result / return value */
  int unaff_A5;
  
  result = alloc_row_table(CONCAT22(level._0_2_,*(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe)));
  if ((short)result == 0) {
    result = 0;
  }
  else {
    result = init_edge_pool();
    if ((short)result == 0) {
      result = 0;
    }
  }
  return result;
}



/* VERIFIED (ID06::FUN_0000096e): ID06.bin 0x96e..0x9d6 checked against an independent capstone disassembly:
 * A5 from CurrentA5 ($904); row count word - 1 into D7 (SUBQ.L, DBRA on the word, body entered first so
 * 0 rows wraps to 65536 like the C's do-while), clearing 8 of every 12 bytes of row table +4; pool cursor
 * +0x8a4 = start +0x8a0; +0x14 = (+0x14 == 0) via SEQ / NEG.B / EXT.W / EXT.L; A5-0x1cc6 = 0 - identical to
 * the C. */
/*
 * Original: FUN_0000096e; source: ID06.c:609.
 * Recovered name: reset_edge_table [STRONG INFERENCE].
 * Overlay service slot A5-0x1310 (JT $1ba).
 * Exported C complete; CurrentA5 routine. Clears the first two longs of each
 * active row entry (bucket head, end flag), resets the node-pool cursor
 * (+0x8a4 = +0x8a0), toggles row table +0x14 between 0 and 1, A5-0x1cc6 = 0.
 * Per-frame reset of the edge table [STRONG INFERENCE].
 */
void reset_edge_table /* Original: FUN_0000096e */ (void)

{
  int a5; /* iVar1: CurrentA5 copy */
  short rows_left; /* sVar2: row countdown (DBRA) */
  undefined4 *entry; /* puVar3: 12-byte row entry cursor in row table +4 */
  
  a5 = CurrentA5;
  entry = *(undefined4 **)(*(int *)(CurrentA5 + -0x1cd2) + 4);
  rows_left = *(short *)(*(int *)(CurrentA5 + -0x1cd2) + 0xe) + -1;
  do {
    *entry = 0;
    entry[1] = 0;
    entry = entry + 3;
    rows_left = rows_left + -1;
  } while (rows_left != -1);
  *(undefined4 *)(*(int *)(a5 + -0x1cd6) + 0x8a4) =
       *(undefined4 *)(*(int *)(a5 + -0x1cd6) + 0x8a0);
  *(int *)(*(int *)(a5 + -0x1cd2) + 0x14) =
       (int)(short)(*(int *)(*(int *)(a5 + -0x1cd2) + 0x14) == 0);
  *(undefined2 *)(a5 + -0x1cc6) = 0;
  return;
}



/* VERIFIED (ID06::FUN_000009d8): ID06.bin 0x9d8..0xd00 checked against an independent capstone disassembly:
 * A5 from CurrentA5 ($904); x range scan (min from the target width, max from 0) rejects max == 0 or
 * min == width; pool cursor >= limit (BCS, unsigned) rejects; first node gets +0x1c / +0x24 = the low
 * words of the $c / $10 slots; edges from the last point (d5 / d4 = previous, d7 / d6 = current, ordered
 * so (d7, d6) is the top; -$c doubles as the swap temporary, the C's dead local_10 = iVar12), horizontal
 * edges and edges outside rows [0, rows) skipped, the top clipped to row 0, then per x-clip case (x <= 0,
 * inside, >= width, with the bottom x <= 0 / >= width / inside - the last leaves local_10 unchanged as in
 * the bytes) the split row by 64-bit MULS.L / DIVS.L (the C's longlong forms), slope ((dx << s1) / dy) << s2,
 * node +4 slope, +8 x << (s1 + s2), +0xc / bucket push at the top row (MULU.L #$c), +0x18 first node,
 * +0x22 = rows - end - 1, end-row flag; continues while the split row is below the bottom and inside the
 * rows; returns cursor != first (SNE / NEG.B / EXT.W). DIVS.L overflow (quotient beyond 32 bits leaves D0
 * unchanged) is not modelled by the C; it needs extreme slopes. Otherwise identical to the C. */
/*
 * Original: FUN_000009d8; source: ID06.c:635.
 * Recovered name: add_polygon_edges [STRONG INFERENCE].
 * Overlay service slot A5-0x130c (JT $1c2).
 * Exported C complete; CurrentA5 routine. Args: n points, attribute words a/b
 * (stored at node +0x1c / +0x24), int *pts = n pairs {x, y} relative to the
 * centre (A5-0x1cca / A5-0x1cc8).
 * Rejects the polygon if all x lie outside [0, width). For each edge (from the
 * previous point), orders by y, clips to rows [0, active rows) and x [0, width)
 * with 64-bit products / divides, computes slope (1 << rowtable+0xa) * dx / dy
 * << rowtable+0x12, and allocates 0x28-byte nodes from the pool (cursor
 * +0x8a4, limit +0x8a8): +4 slope, +8 x << shift, +0xc next in row bucket,
 * +0x18 polygon's first node, +0x22 remaining rows; pushes the node on the
 * bucket of its start row (row entry +0) and sets the end row's flag (+4).
 * Returns true if any node was added. Scanline polygon edge-table insertion
 * [STRONG INFERENCE].
 */
bool add_polygon_edges /* Original: FUN_000009d8 */ (int n_points /* param_1: point count */,undefined2 colour /* param_2: first node +0x1c, the polygon colour read by render_scanline_spans */,undefined2 priority /* param_3: first node +0x24, the priority-list key */,int *pts /* param_4: n {x, y} int pairs relative to the centre */)

{
  uint first_node; /* uVar1: pool cursor +0x8a4 on entry = the polygon's first node */
  ushort frac_shift; /* uVar2: row table word +0xa (11) */
  ushort slope_shift; /* uVar3: row table word +0x12 */
  longlong prod; /* lVar4: 64-bit product for the clip / slope divides */
  int a5; /* iVar5: CurrentA5 copy */
  int y_bot; /* iVar6: bottom y of the edge */
  int row_start; /* iVar7: x max in the range scan, previous point y, then the segment start row */
  int x_bot; /* iVar8: x at the bottom of the edge */
  int x_top; /* iVar9: x at the segment start */
  int y_top; /* iVar10: x min in the range scan, then current point y / top y */
  int row_end; /* iVar11: scan countdown, previous point x, then the segment end row */
  int x_cur; /* iVar12: current point x */
  int *pt; /* piVar13: point cursor for the x range scan */
  uint node; /* uVar14: 0x28-byte node cursor */
  bool added; /* bVar15: any node added */
  int x_next; /* local_10: x for the next split segment (also the swap temporary) */
  int slope; /* local_c: node +4 x step per row */
  
  a5 = CurrentA5;
  frac_shift = *(ushort *)(*(int *)(CurrentA5 + -0x1cd2) + 10);
  slope_shift = *(ushort *)(*(int *)(CurrentA5 + -0x1cd2) + 0x12);
  first_node = *(uint *)(*(int *)(CurrentA5 + -0x1cd6) + 0x8a4);
  y_top = (int)*(short *)(*(int *)(CurrentA5 + -0x1cce) + 8);
  row_start = 0;
  row_end = n_points;
  pt = pts;
  while (0 < row_end) {
    x_cur = *pt + (int)*(short *)(CurrentA5 + -0x1cca);
    if (x_cur < y_top) {
      y_top = x_cur;
    }
    if (row_start < x_cur) {
      row_start = x_cur;
    }
    pt = pt + 2;
    row_end = row_end + -1;
  }
  if ((row_start == 0) || (*(short *)(*(int *)(CurrentA5 + -0x1cce) + 8) == y_top)) {
    added = false;
  }
  else if (first_node < *(uint *)(*(int *)(CurrentA5 + -0x1cd6) + 0x8a8)) {
    *(undefined2 *)(first_node + 0x1c) = colour;
    *(undefined2 *)(first_node + 0x24) = priority;
    row_end = pts[n_points * 2 + -2] + (int)*(short *)(a5 + -0x1cca);
    row_start = pts[n_points * 2 + -1] + (int)*(short *)(a5 + -0x1cc8);
    node = first_node;
    while (n_points != 0) {
      x_cur = *pts + (int)*(short *)(a5 + -0x1cca);
      y_top = pts[1] + (int)*(short *)(a5 + -0x1cc8);
      if (y_top != row_start) {
        y_bot = row_start;
        x_bot = row_end;
        x_top = x_cur;
        if (row_start < y_top) {
          y_bot = y_top;
          x_bot = x_cur;
          y_top = row_start;
          x_top = row_end;
          x_next = x_cur;
        }
        if ((0 < y_bot) && (y_top < *(short *)(*(int *)(a5 + -0x1cd2) + 0xe))) {
          row_start = y_top;
          if (y_top < 0) {
            prod = (longlong)y_top * (longlong)(x_bot - x_top);
            row_start = 0;
            x_top = x_top - (int)(((longlong)(int)((ulonglong)prod >> 0x20) << 0x20 |
                                  (longlong)(int)prod) / (longlong)(y_bot - y_top));
          }
          do {
            row_end = y_bot;
            if (x_top < 1) {
              if (0 < x_bot) {
                prod = (longlong)x_top * (longlong)(y_bot - row_start);
                row_end = row_start - (int)(((longlong)(int)((ulonglong)prod >> 0x20) << 0x20 |
                                       (longlong)(int)prod) / (longlong)(x_bot - x_top));
              }
              x_top = 0;
              x_next = 1;
              slope = 0;
            }
            else if (x_top < *(short *)(*(int *)(a5 + -0x1cce) + 8)) {
              if (x_bot < 1) {
                prod = (longlong)(x_top + -1) * (longlong)(y_bot - row_start);
                x_next = 0;
                row_end = row_start - (int)(((longlong)(int)((ulonglong)prod >> 0x20) << 0x20 |
                                       (longlong)(int)prod) / (longlong)(x_bot - x_top));
              }
              else if (*(short *)(*(int *)(a5 + -0x1cce) + 8) <= x_bot) {
                x_next = (int)*(short *)(*(int *)(a5 + -0x1cce) + 8);
                prod = (longlong)(x_top + (1 - x_next)) * (longlong)(y_bot - row_start);
                row_end = row_start - (int)(((longlong)(int)((ulonglong)prod >> 0x20) << 0x20 |
                                       (longlong)(int)prod) / (longlong)(x_bot - x_top));
              }
              prod = (longlong)(1 << (frac_shift & 0x3f)) * (longlong)(x_bot - x_top);
              slope = (int)(((longlong)(int)((ulonglong)prod >> 0x20) << 0x20 |
                              (longlong)(int)prod) / (longlong)(y_bot - row_start)) << (slope_shift & 0x3f);
            }
            else {
              if (x_bot < *(short *)(*(int *)(a5 + -0x1cce) + 8)) {
                prod = (longlong)(*(short *)(*(int *)(a5 + -0x1cce) + 8) - x_top) *
                        (longlong)(y_bot - row_start);
                row_end = (int)(((longlong)(int)((ulonglong)prod >> 0x20) << 0x20 |
                               (longlong)(int)prod) / (longlong)(x_bot - x_top)) + row_start;
              }
              x_top = (int)*(short *)(*(int *)(a5 + -0x1cce) + 8);
              x_next = x_top + -1;
              slope = 0;
            }
            *(int *)(node + 4) = slope;
            *(uint *)(node + 0x18) = first_node;
            *(int *)(node + 8) = x_top << (slope_shift + frac_shift & 0x3f);
            *(undefined4 *)(node + 0xc) =
                 *(undefined4 *)(*(int *)(*(int *)(a5 + -0x1cd2) + 4) + row_start * 0xc);
            *(uint *)(*(int *)(*(int *)(a5 + -0x1cd2) + 4) + row_start * 0xc) = node;
            *(short *)(node + 0x22) =
                 (*(short *)(*(int *)(a5 + -0x1cd2) + 0xe) - (short)row_end) + -1;
            if (row_end < *(short *)(*(int *)(a5 + -0x1cd2) + 0xe)) {
              *(undefined4 *)(*(int *)(*(int *)(a5 + -0x1cd2) + 4) + row_end * 0xc + 4) = 1;
            }
            node = node + 0x28;
          } while ((row_end < y_bot) &&
                  (row_start = row_end, x_top = x_next,
                  row_end < *(short *)(*(int *)(a5 + -0x1cd2) + 0xe)));
        }
      }
      row_end = *pts + (int)*(short *)(a5 + -0x1cca);
      row_start = pts[1] + (int)*(short *)(a5 + -0x1cc8);
      pts = pts + 2;
      n_points = n_points + -1;
    }
    *(uint *)(*(int *)(a5 + -0x1cd6) + 0x8a4) = node;
    added = node != first_node;
  }
  else {
    added = false;
  }
  return added;
}



/* VERIFIED (ID06::FUN_00000d02): ID06.bin 0xd02..0xd82 checked against an independent capstone disassembly:
 * eight sign-extended (MOVEA.W) longs at -$30(A6): (x0 $a, y0 $c), (x1 $e, y0), (x1, y1 $10), (x0, y1);
 * lookup_colour_map(8(A6) word) (JSR 0x17c, one word - Ghidra's CONCAT22 low half unread); EXT.L D0;
 * add_polygon_edges(4, colour, 0, list) (JSR 0x9d8) - identical to the C. */
/*
 * Original: FUN_00000d02; source: ID06.c:779.
 * Recovered name: add_rect_polygon [STRONG INFERENCE].
 * Exported C complete. Words: colour = param_1 high, x0 = param_1 low,
 * y0 = param_2 high, x1 = param_2 low, y1 = param_3 high. Builds points
 * (x0,y0), (x1,y0), (x1,y1), (x0,y1) and calls
 * add_polygon_edges(4, lookup_colour_map(colour), 0, pts). Ghidra's unaff_A4
 * half is register residue.
 */
void add_rect_polygon /* Original: FUN_00000d02 */ (undefined4 colour_x0 /* param_1: high word = colour, low word = x0 */,undefined4 y0_x1 /* param_2: high word = y0, low word = x1 */,undefined4 y1 /* param_3: high word = y1 */)

{
  undefined4 map_word; /* uVar1: lookup_colour_map result */
  undefined4 a4_in; /* caller A4 (register input); only its high word reaches lookup_colour_map */
  int pt0_x; /* local_34, -$34(A6): pts[0] = (x0, y0); &pt0_x is the 4-point array */
  int pt0_y; /* local_30, -$30(A6) */
  int pt1_x; /* local_2c, -$2c(A6): pts[1] = (x1, y0) */
  int pt1_y; /* local_28, -$28(A6) */
  int pt2_x; /* local_24, -$24(A6): pts[2] = (x1, y1) */
  int pt2_y; /* local_20, -$20(A6) */
  int pt3_x; /* local_1c, -$1c(A6): pts[3] = (x0, y1) */
  int pt3_y; /* local_18, -$18(A6) */
  
  pt0_x = (int)colour_x0._2_2_;
  pt0_y = (int)y0_x1._0_2_;
  pt1_x = (int)y0_x1._2_2_;
  pt1_y = (int)y0_x1._0_2_;
  pt2_x = (int)y0_x1._2_2_;
  pt2_y = (int)y1._0_2_;
  pt3_x = (int)colour_x0._2_2_;
  pt3_y = (int)y1._0_2_;
  map_word = lookup_colour_map(CONCAT22(colour_x0._0_2_,(short)((uint)a4_in >> 0x10)));
  add_polygon_edges(4,(short)map_word,0,&pt0_x);
  return;
}



/* VERIFIED (ID06::FUN_00000d84): ID06.bin 0xd84..0xdc8 checked against an independent capstone disassembly:
 * node +0x22 word = +0x22 + 8(A6) word - row table +0xe, stride 0x28 from pool +0x8a0 while < +0x8a4 (BCS,
 * unsigned) - identical to the C. */
/*
 * Original: FUN_00000d84; source: ID06.c:808.
 * Recovered name: rebase_edge_rows_for_band [STRONG INFERENCE].
 * Exported C complete: for every allocated node (pool +0x8a0.. cursor +0x8a4,
 * stride 0x28): +0x22 += band_offset - active rows (row table +0xe). Called by
 * rasterize_and_present before each band.
 */
void rebase_edge_rows_for_band /* Original: FUN_00000d84 */ (undefined4 band_offset /* param_1: high word = band offset */)

{
  int unaff_A5;
  undefined4 node; /* local_8, -8(A6): 0x28-byte node cursor, pool +0x8a0 .. +0x8a4 */
  
  for (node = *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0);
      node < *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a4); node = node + 0x28) {
    *(short *)(node + 0x22) =
         (band_offset._0_2_ + *(short *)(node + 0x22)) -
         *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe);
  }
  return;
}



/* VERIFIED (ID06::FUN_00000dca): ID06.bin 0xdca..0xe0e checked against an independent capstone disassembly:
 * node +0x22 word = +0x22 - 8(A6) word + row table +0xe over the same unsigned pool walk - identical to the
 * C. */
/*
 * Original: FUN_00000dca; source: ID06.c:825.
 * Recovered name: restore_edge_rows_after_band [STRONG INFERENCE].
 * Exported C complete: inverse of rebase_edge_rows_for_band
 * (+0x22 += active rows - band_offset) after each band.
 */
void restore_edge_rows_after_band /* Original: FUN_00000dca */ (undefined4 band_offset /* param_1: high word = band offset */)

{
  int unaff_A5;
  undefined4 node; /* local_8, -8(A6): 0x28-byte node cursor, pool +0x8a0 .. +0x8a4 */
  
  for (node = *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0);
      node < *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a4); node = node + 0x28) {
    *(short *)(node + 0x22) =
         *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe) +
         (*(short *)(node + 0x22) - band_offset._0_2_);
  }
  return;
}



/* VERIFIED (ID06::FUN_00000e10): ID06.bin 0xe10..0xf64 checked against an independent capstone disassembly:
 * A5 from CurrentA5 ($904); with a row table, re-links the head / tail sentinels (empty active list);
 * dest 8(A6) == 0 -> one call of the row-table renderer (JT A5+0x192 = render_scanline_spans, ID06 0x318);
 * else bands of min($c(A6), remaining) rows: rebase / restore_edge_rows_for_band around the renderer
 * (flag word 0 then 1, band word, dest long, stride long = ((short)(w * d + 0xf) >> 4) * 2 - (short)(w * d) / 8
 * with w = A5-0x1372, d = A5-0x137a), then JT $322 (ID02 0xd3a blit_offscreen_frame_to_window)(dest,
 * rows - remaining, band, $10(A6) long). Corrected from the pushes: the renderer gets the whole dest
 * pointer (not (short)), the dest == 0 call is (0 << 16 | rows, base, (short) +0xc), and param_3 is the
 * long forwarded to JT $322 - otherwise identical to the C. */
/*
 * Original: FUN_00000e10; source: ID06.c:842.
 * Recovered name: rasterize_and_present [STRONG INFERENCE].
 * Overlay service slot A5-0x1308 (JT $19a).
 * Exported C complete; CurrentA5 routine. Args: dest (0 = render only),
 * band_rows, mode. Links head/tail sentinels (empty active edge list). If
 * dest == 0: (*rowtable+0)(rows, target base, rowtable+0xc). Else, per band
 * of band_rows: rebase_edge_rows_for_band; (*rowtable+0)(band, dest, row
 * stride) = render_scanline_spans; restore_edge_rows_after_band; JT $322 = ID02 blit_offscreen_frame_to_window(dest, top, rows,
 * mode). Rasterises the edge table and presents it in bands [STRONG INFERENCE].
 * The renderer callback is JT A5+0x192 (installed by init_row_table_fields).
 */
void rasterize_and_present /* Original: FUN_00000e10 */ (int dest /* param_1: offscreen destination, 0 = render into the target only */,int band_rows /* param_2: maximum rows per band */,int mode /* param_3: long forwarded to blit_offscreen_frame_to_window (JT $322) */)

{
  short view_width; /* sVar1: A5-0x1372 view width */
  short pixel_depth; /* sVar2: A5-0x137a screen pixel depth */
  short view_width2; /* sVar3: A5-0x1372 re-read */
  short pixel_depth2; /* sVar4: A5-0x137a re-read */
  int a5; /* iVar5: CurrentA5 copy */
  short band_offset; /* sVar6: active rows - rows still to draw after this band */
  undefined4 d2_in; /* caller D2 (register input); its high word becomes d2_residue */
  undefined2 d2_residue; /* uVar7: unaff_D2 high word, unread low half of the pushed long */
  undefined4 rows_left; /* local_e, -$e(A6): rows still to render */
  undefined2 continue_flag; /* local_8, -8(A6): 0 for the first band, then 1 */
  undefined2 band; /* local_6, -6(A6): rows in this band, min(band_rows, rows_left) */
  
  a5 = CurrentA5;
  d2_residue = (undefined2)((uint)d2_in >> 0x10);
  if (*(int *)(CurrentA5 + -0x1cd2) != 0) {
    *(undefined4 *)(*(int *)(*(int *)(CurrentA5 + -0x1cd6) + 0x898) + 0x10) =
         *(undefined4 *)(*(int *)(CurrentA5 + -0x1cd6) + 0x89c);
    *(undefined4 *)(*(int *)(*(int *)(a5 + -0x1cd6) + 0x89c) + 0x14) =
         *(undefined4 *)(*(int *)(a5 + -0x1cd6) + 0x898);
    if (dest == 0) {
      /* CORRECTED [PROVEN, 0xf34..0xf54]: pushes (word 0, word rows, long target base, long
       * sign-extended row table +0xc) = render_scanline_spans(0 << 16 | rows, base, stride) */
      (*(code *)**(undefined4 **)(a5 + -0x1cd2))
                (CONCAT22(0,*(undefined2 *)(*(int *)(a5 + -0x1cd2) + 0xe)),
                 (uint *)**(undefined4 **)(a5 + -0x1cce),
                 (int)*(short *)(*(int *)(a5 + -0x1cd2) + 0xc));
    }
    else {
      view_width = *(short *)(a5 + -0x1372);
      pixel_depth = *(short *)(a5 + -0x137a);
      view_width2 = *(short *)(a5 + -0x1372);
      pixel_depth2 = *(short *)(a5 + -0x137a);
      rows_left = (int)*(short *)(*(int *)(a5 + -0x1cd2) + 0xe);
      continue_flag = 0;
      do {
        if (band_rows < rows_left) {
          band = band_rows._2_2_;
        }
        else {
          band = rows_left._2_2_;
        }
        band_offset = *(short *)(*(int *)(a5 + -0x1cd2) + 0xe) - (rows_left._2_2_ - band);
        rebase_edge_rows_for_band(CONCAT22(band_offset,d2_residue));
        (*(code *)**(undefined4 **)(a5 + -0x1cd2))
                  (CONCAT22(continue_flag,band),(uint *)dest, /* CORRECTED [PROVEN]: MOVE.L 8(A6) pushes the whole dest */
                   ((short)(view_width * pixel_depth + 0xf) >> 4) * 2 - (short)(view_width2 * pixel_depth2) / 8);
        continue_flag = 1;
        restore_edge_rows_after_band(CONCAT22(band_offset,d2_residue));
        (**(code **)(a5 + 0x322))
                  (dest,*(short *)(*(int *)(a5 + -0x1cd2) + 0xe) - rows_left,band,mode);
        rows_left = rows_left - band;
      } while (rows_left != 0);
    }
  }
  return;
}


