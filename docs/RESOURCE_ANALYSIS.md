# ResEdit resource analysis

The curated resource tree is reproducible and locally inspectable. Each resource
item under `sources/resedit-1-0-3/` has a sibling binary payload and JSON metadata
record. `sources/resedit-1-0-3/inventory.json` is only an index; the resource-local
JSON files are the primary inspection records.

## Coverage

The requested type list contains **30** directory names, despite being described
as 29. All 30 are retained exactly:

`ALRT`, `BNDL`, `CNTL`, `CODE`, `DATA`, `DITL`, `DLOG`, `DREL`, `FREF`, `HEL1`,
`HELL`, `ICN#`, `ICON`, `MDPL`, `MENU`, `PICT`, `SIZE`, `STR#`, `TEXT`, `ZERO`,
`cicn`, `clut`, `icI4`, `icI8`, `ics#`, `ics4`, `ics8`, `snds`, `styl`, `vers`.

Run `python3 tools/resedit.py inventory` for authoritative detailed counts or
`python3 tools/progress_stats.py` for the compact cross-domain summary.
Executable references are direct type/ID references supported by decompilation
annotations; type-level named-resource call sites remain separate. Neither is a
claim of runtime observation or proof that every named resource executes.

## Evidence and edition provenance

Payload precedence is deliberate:

1. Existing ResEdit hexadecimal exports are authoritative for the curated tree.
2. Existing protected `CODE/ID*.bin` files must match their sibling hex exports
   and are never rewritten.
3. The embedded resource fork in
   `sources/hellcats-over-the-pacific/Hellcats_1_0_4.appledouble` supplies exact
   payloads only where the curated export has no bytes (notably `cicn` and
   `snds`) and supplies original resource-map names where Markdown has no
   `Name:` field. Its SHA-256 is
   `a36f245a37fe8693c25b70e3219e5b01bcec01cbee6aa8a0492871c7e8fff956`.

The AppleDouble file is a **Hellcats 1.0.4** artifact; the curated ResEdit tree is
primarily 1.0.3. Five payloads differ and the metadata preserves both hashes:

- `CODE:2`: protected ResEdit payload is 19,994 bytes; the 1.0.4 fork payload is
  24,832 bytes.
- `vers:1`: the curated payload decodes as 1.0.3; the comparison fork decodes as
  1.0.4.
- `DITL:135`: the curated export is truncated in item 9. The 1.0.4 comparison
  fork adds eight bytes that decode as an empty editable unlock-code field. That
  recovery is marked **INFERRED**, not substituted into the 1.0.3 evidence.
- `HEL1:127` and `HEL1:128`: the settings and player/score resources have equal
  sizes but different content. These resource classes are writable at runtime;
  metadata does not claim whether the differences came from version defaults or
  later saved user state.

The directory labels `snds`, `icI4`, and `icI8` are preserved. The parsed
resource map independently establishes their original four-character types as
`snd `, `icl4`, and `icl8`; metadata records both identities rather than silently
renaming directories.

## Metadata model

Each JSON record separates:

- `resource`: original name, exact type/ID, descriptive identity and purpose;
- `evidence`: byte path, size, SHA-256, origin, fork comparison and all exports;
- `decoded`: deterministic fields, offsets, elements and unconsumed regions;
- `relationships`: proven outgoing and automatically generated reverse links;
- `code_references`: source path, line and supporting decompilation annotation;
- `claims` and `claim_evidence`: claim-level `PROVEN`, `VERIFIED`, `INFERRED`, or
  `UNKNOWN` status;
- `review`: human notes and claims preserved verbatim across regeneration;
- `unresolved`: explicit remaining questions and provenance mismatches.

Generated fields are reproducible. Human review belongs in `review`, which the
generator carries forward. Do not put reviewed conclusions inside `decoded`.

## Supported deterministic decoders

Complete field decoders cover `ALRT`, `BNDL`, `CNTL`, `CODE` segment facts,
`DITL`, `DLOG`, `DREL`, `FREF`, `HEL1` record structure, `MENU`, `SIZE`, `STR#`,
`TEXT`, `ZERO` word structure, `cicn`, `clut`, the monochrome/indexed icon
families, `snds`, `styl`, and `vers`.

Important details:

- Every DITL item includes bounds, type/flags, exact content, padding,
  placeholders and a structural or reviewed semantic identity.
- Every menu item, string, style run, bundle mapping, relocation entry, palette
  entry and sampled-sound command is an individual element. Menu entries include
  the decoded `do_menu_command` action and claim status; the Apple About target
  remains inferred while the other fixed resource items are byte-verified.
- `snds` payloads are verified classic format-1 `snd ` resources with a
  sampled-sound header, unsigned 8-bit mono data, 16.16 sample rate, loop points
  and no compression. No arbitrary PCM carving or assumed 22,050 Hz rate is used.
- All 14 `cicn` resources have parsed PixMaps, masks, monochrome bitmaps, embedded
  color tables and indexed pixels. Decoded RGB pixels match the existing PNGs
  exactly (zero differing pixels).
- `PICT` opcode streams are walked to `OpEndPic` (Inside Macintosh: Imaging With
  QuickDraw, appendix A) and consumed exactly: PICT 128 is version 2 (one
  `PackBitsRect`), PICTs 129 / 130 are version 1 `PackBitsRect` bands between
  picture comments, and PICTs 131 / 1000 are version 1 text pictures whose
  strings `inspect` lists. Rendered exports are indexed beside them, and the
  three bitmap pictures, rendered independently from their opcodes (PackBits rows,
  PICT 128's colour table), match their PNGs pixel for pixel. The two text
  pictures are not rendered, since they need the System's fonts.
- CODE records link the protected binary, Ghidra export, semantic decompilation,
  and function annotations found in that decompilation. CODE 0 has no function
  bodies: its `ID00.c` is an explicitly reconstructed structural export, and
  `ID00.decomp.c` exposes all 175 validated LoadSeg jump-table entries.

## Relationships

The generator resolves `ALRT -> DITL`, `DLOG -> DITL`, DITL picture/icon items,
and `BNDL -> FREF/ICN#`, then writes reverse references. No dangling relationship
currently exists in the curated tree. A same-ID `TEXT`/`styl` pair is not asserted
as a link without executable or format evidence.

## Commands

From the repository root:

```sh
python3 tools/resedit.py generate
python3 tools/resedit.py inventory
python3 tools/resedit.py inspect ALRT 259
python3 tools/resedit.py inspect DITL 137 --detail
python3 tools/resedit.py inspect clut 999
python3 tools/resedit.py inspect HEL1 128
python3 tools/resedit.py inspect CODE 1
python3 tools/resedit.py search mission
python3 tools/resedit.py references DITL 259
python3 tools/resedit.py unknown
python3 tools/resedit.py verify
python3 tools/qa/test_resedit.py
```

`inspect` is concise by default; `--detail` exposes offsets, bytes and evidence.
`verify` re-parses the inputs, checks metadata drift, validates every hash and
ensures every discovered item has both binary and JSON companions.

## Remaining uncertainty

(`DATA:0` is resolved: CODE 1 0x34, the C runtime's start-up, copies its words up
from CurStackBase and, after each zero word, clears as many bytes as the next word
of `ZERO:0`. Its 1459 words hold 90 zero words, one per `ZERO:0` entry, and the
expansion is exactly CODE 0's 0x225e bytes below A5. `inspect DATA 0` lists each
run with its A5 offset; `DREL:0` then relocates its pointers.)

- `MDPL:128` is mostly resolved, and no game code reads it: it is the layout
  record of PICT 131's first text object, kept by the drawing program that
  signed the picture's application comments 'MDPL'. Its directory blocks tile
  the resource. Its three Geneva styles and their runs (bold 10, plain 10,
  plain 9 from characters 0 / 26 / 38) match the picture's TxFace / TxSize
  changes, and its 31 line starts cover the 311-character text. The first 17
  match the picture's line starts and the later ones sit one character on. The
  header before 0x5c and the block at 0x136..0x182 stay uninterpreted.
- The primary `DITL:135` export remains eight bytes short. The 1.0.4 completion
  is useful corroboration, not proof that the missing 1.0.3 bytes were identical.
  No code opens it: ID05's only GetNewDialog (0x5f4) opens DLOG 1000.
- The text PICTs (131, 1000) are not rendered independently: their exports'
  glyphs depend on the System fonts.
- The indexed icons are checked through the System's default colour tables
  (clut 4 / clut 8, as the Finder draws them), not through any palette matched
  by ID. Both icl4, both icl8 and both ics4 match their PNG exports pixel for
  pixel, transparent export pixels aside. Both ics8 exports differ on the ramp
  indices (215 and up), the same indices the icl8 exports render exactly, so
  those two exports are the suspects. The strict mirror decodes icons from
  their bytes through the same tables and does not read them.
