# Polygon rasterizer (CODE segment 6)

CODE segment 6 (`ID06`) contains a self-contained scanline polygon
rasterizer. The overlay drives it through the application service table
(`docs/reference/OVERLAY_SERVICE_TABLE.md`, slots `A5-0x1310..-0x1304`). Offsets are
physical file offsets in `ID06.bin`.

Confidence: data layouts and call relations come from complete Ghidra C or
byte decoding (**[PROVEN]** where bytes were checked); the overall
"rasterizer" reading and field roles are **[STRONG INFERENCE]**; colour /
pattern semantics are **[HYPOTHESIS]**.

## Global structures

| Global | Size | Built by | Contents |
|---|---|---|---|
| `A5-0x1cce` | 0x10 | `init_raster_target` | +0 pixel base, +4 word, +6 = 1, +8 width, +0xa height, +0xc `FUN_000000f4` |
| `A5-0x1cd2` | 0x24 | `alloc_row_table`, `init_row_table_fields` | +0 renderer callback (JT `A5+0x192`), +4 row entries (12 bytes each), +8 word, +0xa fixed-point shift (11), +0xc row stride remainder, +0xe active rows, +0x10 / +0x12 shifts, +0x14 0/1 toggle, +0x1c / +0x20 buffers |
| `A5-0x1cd6` | 0x5e9c | `init_edge_pool` | node pool; head sentinel +0x898 → +0x8ac, tail sentinel +0x89c → +0x5e74, cursor +0x8a0 / +0x8a4, limit +0x8a8 |
| `A5-0x1cca` / `-0x1cc8` | words | `init_raster_target` | centre x / y (width / 2, height / 2) |
| `A5-0x1cc6` | word | `set_active_row_count`, `reset_edge_table` | mirror of active rows / 0 |

### Row entry (12 bytes)

| Offset | Meaning |
|---|---|
| +0 | bucket: first edge node starting on this row |
| +4 | end flag (set when an edge ends on this row) |
| +8 | pointer into the target's 8-row pattern table (`target+0xc + (row % 8) * 4`) |

### Edge node (0x28 bytes, from the pool)

| Offset | Meaning |
|---|---|
| +0x00 | current x (fixed point) |
| +0x04 | slope (`(1 << shift) * dx / dy << shift2`) |
| +0x08 | start x `<< shift` |
| +0x0c | next node in the same row bucket |
| +0x10 / +0x14 | links in the open-polygon list (between sentinels) |
| +0x18 | polygon's first node |
| +0x1c / +0x24 | attribute words a / b (colour, priority) |
| +0x1e | colour copied at render time |
| +0x20 | parity word (complemented at each crossing) |
| +0x22 | remaining rows counter |

## API

| ID06 file | Name | Service slot | Role |
|---|---|---|---|
| 0x7b0 | `init_raster_target` | — | allocate target, row table, node pool; set centre |
| 0x598 | `alloc_row_table` | — | one entry per row |
| 0x26c | `init_row_table_fields` | — | callback, shifts, stride, pattern pointers |
| 0x666 | `init_edge_pool` | — | pool and sentinels |
| 0x512 | `free_row_table` | — | release row table |
| 0x87a | `set_raster_target_base` | — | retarget pixel base |
| 0x8a2 | `set_active_row_count` | `-0x1304` | clamp and set rows |
| 0x96e | `reset_edge_table` | `-0x1310` | per-frame reset |
| 0x9d8 | `add_polygon_edges` | `-0x130c` | clip, compute slopes, insert edge nodes |
| 0xe10 | `rasterize_and_present` | `-0x1308` | render rows; optionally band-blit to window |
| 0x318 | `render_scanline_spans` | (JT `$192`) | span renderer callback |
| 0xd84 / 0xdca | `rebase_edge_rows_for_band` / `restore_edge_rows_after_band` | — | band bookkeeping |

## Frame flow

1. `reset_edge_table` — empty buckets, reset pool cursor, flip toggle.
2. `add_polygon_edges` per polygon — points are `{x, y}` long pairs relative
   to the centre; edges clipped to the target and filed by start row.
3. `rasterize_and_present(dest, band_rows, mode)` — with `dest == 0` renders
   all rows into the target; otherwise renders band by band
   (`rebase…` / renderer / `restore…`) and blits each band to the window via
   ID02 `blit_offscreen_frame_to_window` (JT `$322`).

## Span renderer state [PROVEN, bytes]

`render_scanline_spans` keeps its working variables in a 0x44-byte block
inside its own code: `BRA.B $3e2` at file 0x39c jumps over the zero-filled
bytes 0x39e..0x3e1 (Ghidra's `DAT_0000039e`…`DAT_000003d2`). The block is
initialised on the first band of a frame and reused for later bands
(self-modifying data).

## Open questions

- Exact meaning of attribute words a / b (colour index, priority?).
  `(x >> 6) & 0x3e0` selects one of the 32 left-edge masks.
- Role of row-table +0x1c / +0x20 buffers and target +4. Target +0xc is the
  pattern table (`get_pattern_table`).
- All ID06 functions are named. Pattern data: table
  `*A5-0x1eda` (0xc00 bytes: 32 left-edge masks × 8 longs, then 64 patterns ×
  8 replicated rows from the bytes at `A5-0x1ed6`); grey map `*A5-0x1ede`
  (256 words, 16 levels → pattern offsets). Helpers: `alloc_aligned_clear` /
  `free_aligned`, `rgb_to_bw_pattern`, `lookup_colour_map` /
  `reverse_lookup_colour_map`, `init_pattern_tables`, `alloc_pattern_tables`,
  `get_pattern_table`, `get_raster_target_size`, `realloc_row_table`,
  `add_rect_polygon`.
