# Semantic reconstruction rules

The semantic `*.decomp.c` files (`sources/resedit-1-0-3/CODE/`) make Ghidra's exports readable
and correct, and are what the strict port translates. Every function is `VERIFIED` (current
counts: `python3 tools/progress_stats.py`); CODE 0 is also complete: `ID00.c` is a byte-exact
data export and `ID00.decomp.c` decodes its header and all 175 jump-table entries. The four
functions Ghidra could not decompile (ID02 `FUN_000002b0` / `FUN_00004b62`, ID05 `FUN_000008b8` /
`FUN_00000964`) are reconstructed from their bytes.

## Sources

- Immutable Ghidra exports: `sources/resedit-1-0-3/CODE/*.c`, their checksums in
  [`../DECOMPILATION_PROTECTED_CHECKSUMS.sha256`](../DECOMPILATION_PROTECTED_CHECKSUMS.sha256)
- Semantic reconstructions: `sources/resedit-1-0-3/CODE/*.decomp.c`
- Function registry: [`../DECOMPILATION_INVENTORY.json`](../DECOMPILATION_INVENTORY.json)
  (`tools/re_query.py`); statuses there are reconstruction states, not Godot coverage
- Names and corrections: [`../reference/DECOMPILATION_SYMBOLS.md`](../reference/DECOMPILATION_SYMBOLS.md);
  layouts: [`../reference/STRUCTS.md`](../reference/STRUCTS.md); global names: each file's
  `#define` aliases
- C-to-GDScript mappings: `godot/strict_port/mappings/functions.json`

Source-local provenance comments are evidence: they stay even where the same identity can be
retrieved elsewhere.

## Verification

A function is `VERIFIED` when its body matches an independent disassembly of its bytes and every
call argument Ghidra dropped is written back into the call, recorded in the symbols document's
call-argument corrections. A `VERIFIED:` comment block says what was checked against the bytes.

## Confidence vocabulary

Every claim in the semantic C and the documentation carries one of these, in brackets:

| Tag | Means |
|---|---|
| `[PROVEN]` | checked against the original bytes or data (a qualifier may say how: `[PROVEN, bytes]`) |
| `[RECONSTRUCTED]` | read from the decompiled C, not separately checked against the bytes |
| `[STRONG INFERENCE]` | reasoned from several independent pieces of evidence |
| `[HYPOTHESIS]` | a plausible reading, not yet supported |
| `[UNKNOWN]` | not established |
| `[BLOCKED]` | cannot be settled until something else is |
| `[WITHDRAWN]` | an earlier claim found wrong, kept with what replaced it |

A qualifier after a colon or comma narrows a tag (`[STRONG INFERENCE: thrust]`). Two markers
record edits rather than confidence: `[RESTORED]` (a dropped call argument written back) and
`[ANNOTATED]` (a block described in a function's header). Status words in registries and tables
(`VERIFIED`, `BLOCKED`, `NOT_PORTED`) are separate.

## Function headers

A function's header comment opens with one line:
`/* Original: FUN_00001234; source: ID02.c:120. Recovered name: name [CONFIDENCE].`, then what the
function does and its evidence; a `VERIFIED:` block may follow. Entries that are not functions (a
false entry inside another routine, an epilogue a call site aliases) keep their own description.

## Naming conventions

- Ghidra-style names (`iVarN`, `local_xx`, `param_N`, `auStack`, `DAT_`, `PTR_`) are replaced by
  evidence-based names, the original kept in the declaration comment; a global's readable name is
  a `#define readable DAT_xxxx /* evidence */` alias. Every rename stays token-identical after
  mapping the names back.
- Ghidra names a local by its offset from the stack pointer at entry, so in a `link.w a6` frame
  `local_N` / `xStack_N` sits at `-(N - 4)(A6)`; declaration comments give that offset.
- Section-check comments say "blk N", never "Block N", so `re_query.py excerpt --block` stays
  unambiguous.

## Working on a function

1. Inspect `git status --short`; do not overwrite unrelated edits.
2. Retrieve only what the function needs (its body, excerpt, callers, callees, globals, test case)
   with `tools/re_query.py`.
3. Compare the immutable `.c`, the semantic `.decomp.c` and independent disassembly.
4. Preserve identifiers, widths, arithmetic, conditions, layouts and unresolved annotations.
5. Regenerate the inventory (`tools/decomp/inventory_functions.py`) and run the validation in the
   repository README.

## Open questions

- `update_aircraft_entity`: blk 3b reads the blk 2b engine locals, which are uninitialised for
  non-player aircraft (reachability unknown); blk 2b's `divs.w` could trap on a zero divisor
  (reachability unknown).
