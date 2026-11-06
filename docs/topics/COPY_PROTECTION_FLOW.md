# Copy-protection flow (ID08 → ID05)

Summary of the overlay-load protection chain recovered from the CODE
segments. All offsets are **physical file offsets** in `IDnn.bin`; jump-table
(JT) calls are resolved through `ID00.bin` (entry = segment offset,
`MOVE.W #seg`, `_LoadSeg`; file offset = segment offset + 4-byte CODE header).
Byte sequences and control flow are **[PROVEN]**; the "copy protection"
interpretation is **[STRONG INFERENCE]**; UI meaning of the numbers is
**[HYPOTHESIS]**. Trap names follow Inside Macintosh.

## Sequence in `load_overlay_from_resource` (ID08 `FUN_00000006`)

After the overlay image is read, relocated and its base stored in
`A5-0x1006` (ID08 0xd4, aligned 0xf0/0xfe):

| ID08 file | Call | Target | Effect |
|---|---|---|---|
| 0x246 | JT `$53a`(base, code size `A5-0x1022`) | ID05 0x7f6 `poison_overlay_bytes` | 12 random overlay bytes saved to `A5-0xb4` table, overwritten with 0xFF |
| 0x24e | `$A975` TickCount | — | seed value |
| 0x25c | JT `$542`(`A5-0x1cc4`, 0x38, ticks) | ID05 0x8b8 (init, not decompiled) | `ansi_srand(ticks)`; table ptr `A5-0xba`, count `A5-0xb6` = 56 |
| 0x26c | JT `$582`(&a, &b) | ID05 0x160 `read_DATA128_pair` | a, b ← 'DATA' 128 longs 0/1 (0 if missing) |
| 0x276 | JT `$552`(b) | ID05 0xb84 `encode_code28_to_buf54` | 6-letter string of b & 0x0fffffff |
| 0x282 | JT `$54a`(a, str) | ID05 0x934 `record_code_index_equals` | str[4]*20 + str[5] == a ? |
| 0x28c | JT `$532` (only if true) | ID05 0x8b2 stub | `A5-0xbc` += 1 (restore gate 1) |
| 0x298 | JT `$572`(&a, &b) | ID05 0x560 `run_protection_dialog` | challenge dialog unless already valid |
| 0x29e | JT `$55a` | ID05 0x85e `restore_poisoned_overlay_bytes` | restores bytes only if `A5-0xbc` or `A5-0xc0` ≠ 0 |
| 0x2a6–0x2b2 | `$552`, `$54a` again | — | re-check a against encoded b |
| 0x2c4 | JT `$57a`(a, b) (if valid) | ID05 0x1bc `write_DATA128_pair` | persist a, b to 'DATA' 128 |

## `run_protection_dialog` (ID05 0x560)

1. Builds code strings (unexported routine ID05 0x3ba): machine fingerprint
   (`get_machine_screen_fingerprint`: machineType, screen width/128,
   height/128, depth/4, 0) packed by `pack_fields_to_code_buf68`, plus
   `encode_code28_to_buf54(*b)` and `encode_long_to_buf40(*a)`; uses
   'TEXT' 128 (`read/write_TEXT128_pair`) and a GetVol name comparison.
2. If `record_code_index_equals(*a, outB + 6)` already holds → return.
3. `pick_random_protection_challenge` → three words w1..w3 from a random
   table entry; shown with ParamText in DLOG 1000 (centred by
   `center_template_rect_on_screen`), filter `code_dialog_filter`
   (Return/Enter = item 1, Esc = item 2, OK dimmed while item 3 empty).
4. Item 2 → ExitToShell. Item 1 → item 4 text decoded
   (`decode_code_to_long_b`) into *a; item 3 text (upper-cased by
   `get_dialog_item_text_upper`) checked by the matcher at ID05 0x964.
5. Matcher: entry string de-obfuscated with key `A5-0x2c` (`+ (key & 0x7f)`),
   length and w1..w3 must match; each match increments `A5-0xc0`
   (restore gate 2). Failure → ALRT 1001, retry.
6. On success with a valid code → `write_TEXT128_pair(*a, *b)`.

## Consequence

If neither gate is set, the 12 poisoned bytes stay 0xFF in the overlay
code, so a run without the correct answer (or a valid stored code) is
corrupted rather than refused outright. **[STRONG INFERENCE]**

## Open questions

- Content of the 56-entry table at `A5-0x1cc4` and key at `A5-0x2c`
  (A5 world initial data; not yet located in the CODE 0 / data image).
- Exact meaning of w1..w3 (page/line/word?) and of DATA/TEXT longs.
- Role of the GetVol name compare against `A5-0xca` in routine 0x3ba.
- ID02 `FUN_000001ce` (JT `$4e2`) assumed toupper-like.
