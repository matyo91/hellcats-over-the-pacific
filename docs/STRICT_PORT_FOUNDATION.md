# Strict C-to-GDScript port foundation

## Decision

The editable `*.decomp.c` files are now the architectural source of truth for
new Godot simulation logic. The Mission 01 prototype remains preserved and
playable, but it is a comparison target and runtime shell, not evidence that an
original algorithm has been ported.

The strict slices are deliberately isolated. Nothing changes `project.godot`, the
main scene, existing scenes, prototype scripts, assets, imports, or runtime
behavior.

## Repository audit

Ten `*.decomp.c` files exist, all in `sources/resedit-1-0-3/CODE/`: ID01 through ID09
and `Pacific Conflict.decomp.c`. `DECOMPILATION_INVENTORY.json` is the canonical
segment-qualified registry. Run `python3 tools/progress_stats.py` for current
counts; reconstruction statuses must not be reported as Godot-port coverage.

The existing Godot project contains two materially different tracks:

| Classification | Current evidence | Treatment |
|---|---|---|
| Reconstructed deterministic logic | `hellcats/core/sim_core.gd`, `flight_math.gd`, RNG modules, loader metadata, replay/trace tests | Reuse as reference evidence and comparison infrastructure; migrate function-by-function only after strict mappings exist. |
| Approximate/simplified gameplay | `flight/flight_model_mvp.gd`, authored mission rules/data, world builder, chase camera | Preserve for the playable prototype; isolate from claims of original equivalence and eventually replace behind adapters. |
| Placeholder/mock state | Mock pointers, flat dictionaries, deferred paths and stand-ins explicitly marked in `sim_core.gd` | Do not promote into strict ports; replace only from verified source/layout evidence. |
| Pure Godot integration | Player input collection, scene controllers, nodes, HUD labels, resource loading | Preserve as the eventual thin runtime-adapter layer. |
| Unknown provenance | Any code without source identity or an explicit MVP/Godot tag | Treat as unverified until audited; do not map retroactively without evidence. |

The current Mission 01 dependency chain is `Main.tscn` →
`Mission01Training.tscn` → world/player/checkpoint/HUD scenes → mission,
aircraft, input, flight-model and objective scripts plus three JSON data files.
It does not call `SimCore.tick`. The main scene remains unchanged.

`sources/resedit-1-0-3/` contains the inventoried resource corpus. Reusable
evidence includes CODE binaries and metadata, PICT/BMP/PNG artwork, `clut/999`,
icons, `snds`, mission/data resources, dialogs, menus, text and string tables.
Exact palettes and original dimensions must be read from these resources; they
must not be replaced with invented cockpit or scenery assets.

## Directory and ownership model

```text
godot/strict_port/
  code/                 # one module per original CODE segment/overlay initially
  compat/               # explicit C/68000 operations and later packed memory
  mappings/functions.json
  adapters/             # created only when an integration needs Godot lifecycle APIs
godot/tests/strict_port/
tools/strict_port/
```

Segment-oriented modules preserve function ownership and shared state without
creating one file per tiny function. A segment may split later only when a
verified subsystem boundary and state owner justify it.

Original shared globals will be represented by the smallest packed state/memory
object that can preserve addresses, aliasing, big-endian loads/stores, pointer
offsets, initialization order and table layouts. It will be passed explicitly;
it will not become a collection of duplicate node fields or an autoload by
default. The first slice is pure and has no global-state dependency, so no state
container is invented yet.

## Naming and translation rules

1. Use the canonical function name present in the current `.decomp.c`; retain
   its `FUN_*` identity separately as `original_function` in the mapping.
2. Preserve `param_*`, decompiler local names, global `DAT_*` names, function
   boundaries, statement order, branches, constants, indexing and casts.
3. Add a name only through the established decompilation rename process. A
   Godot-only adapter may use an idiomatic lifecycle name but cannot stand in
   for an original function.
4. Record each mapping once, in `mappings/functions.json`. Comments may explain
   semantics but are not a second provenance database.
5. Unknown or unresolved behavior is `BLOCKED`; it is never approximated inside
   the strict layer.

## Compatibility strategy

`strict_port/compat/c68k.gd` currently provides deterministic `u8`, `s8`, `u16`,
`s16`, `u32`, `s32`, 32-bit logical/arithmetic shifts, wrapping, and signed
division/remainder truncated toward zero. Tests cover boundary/sign behavior.

The remaining semantics are intentionally not guessed:

| Concern | Strategy / current state |
|---|---|
| Masks and implicit promotions | Express at each translation boundary with width helpers; the first slice promotes signed `char`, shifts, XORs, then truncates to byte. |
| Fixed point | Add format-specific helpers only when the source establishes the scale; do not reuse the existing interface-only `Fixed68k` as proof. |
| Floating point | Determine original 68k compiler/FPU representation and rounding from binary evidence before porting a dependent function. |
| Pointers, structs, arrays, globals | Introduce a bounds-checked packed memory/state object with explicit offsets when the next slice requires it. |
| Endianness | Use explicit big-endian byte/word/long loads and stores in that memory layer. |
| 68000 flags/overflow | Add operation-specific helpers only for branches proven to depend on condition-code results. |

## Translated slices

`contact_pair_hash` (`FUN_0001358c`, overlay `0x1358c`) is a complete pure
function in `Pacific Conflict.decomp.c`. Its source annotation records an
independent Capstone verification of the instruction sequence: `(b << 2) ^ a`,
then mask to the low byte. The strict GDScript preserves `param_1`, `param_2`,
expression order and byte truncation. Seven fixed vectors cover zero, high-bit,
signed-char and truncation cases. Passing those cases is behavioral evidence
because their expected operation comes from the independent disassembly, not
from executing the GDScript implementation to manufacture expectations.

The `reset_radar_tracks` (`FUN_0001776a`) slice preserves the original three
stores in order: two 32-bit clears at `DAT_00026672` and `DAT_00026676`, then
an 8-bit changed flag store at `_DAT_0002666e`. Independent Capstone evidence
recorded with the decompiled function establishes those widths and addresses;
the deterministic test initializes nonzero counts and sentinel neighbor bytes.

`abs_int` (`FUN_00002e08`) and `approx_dist3_xyz` (`FUN_00003c68`) are pure
leaves whose semantic C was byte-checked and whose signature was restored from
the pushes (call-argument restoration, 2026-10-22). The GDScript keeps the C's
variable roles and makes every 68000 width explicit: `abs_int` keeps NEG.L's
`abs_int(0x80000000) == 0x80000000`, and `approx_dist3_xyz` wraps the `suba.l`
deltas and the `add.l` sum at 32 bits before `asr.l #2`. Their vectors come from
an instruction-level model of 0x2e08..0x2e10 / 0x3c68..0x3cc8 (including the
binary's own register order of the swaps), not from running the port, and
include the INT_MIN and sum-overflow cases.

`update_object_camera_metric` (`FUN_00003b98`) and `compute_camera_abs_metric`
(`FUN_00003c00`) are the first callers of a ported leaf: both call the strict
`abs_int` on (position - camera), reading the camera globals at the C's literal
addresses `DAT_0001d838` / `DAT_0001d834` / `DAT_0001d830` from `Memory68k`. The
object variant stores the metric at +0x10 and returns it (the D0 return restored
in the semantic C). One test covers both with the same vectors, including a
32-bit wrap of the delta and of the sum, and checks that +0x0c / +0x14 stay intact.

`sin_fixed14` (`FUN_00001d76`) and `cos_fixed14` (`FUN_00001dd8`) read their
256-word tables from `Memory68k` at the runtime addresses the code names
(`lea.l $1ab6c` / `$1ad6c`). The test copies those tables from the immutable
original binary (file 0x1ab8c / 0x1ad8c, the runtime-address rule) rather than
from a regenerated formula, and checks 14 angles per function against an
instruction-level model: fraction steps, quarter turns, the floored negative
delta and the masked next index at the end of the table. Callers pass 0..0x3fff;
a negative angle would index before the table exactly as the original does.

The attitude setup layer sits on top: `load_attitude_angle_sincos` (`0x202a`) and
`load_attitude_angle_sincos_5_6` (`0x20a0`) store cos then sin of each angle as
words at `0x1d7fa..0x1d7e6`, and the four fills (`0x20e6`, `0x21a0`, `0x21e0`,
`0x2220`) write the 3x3 s16 bases at `0x1d7d4 / 0x1d7bc / 0x1d7a4 / 0x1d78c /
0x1d774 / 0x1d75c` (element [r][c] at +2 * (3r + c)). Their expected matrices come
from interpreting the disassembled `move.w` / `clr.w` / `neg.w` sequences over the
model's sin / cos words, and one case checks that `neg.w` leaves 0x8000 unchanged.

`matmul3x3_s16` (`0x1d02`), `finalize_attitude_matrix_4ang` (`0x2562`) and
`build_attitude_matrix` (`0x25a8`) complete the chain: out = ((R4 * Rz) * Rx) * Ry.
finalize's intermediate matrix is a frame local (a6 - 0x12), so the strict module
gained `a7`, the stack pointer at entry of the outermost ported call; finalize
places its temp at a7 - 0x16 and build enters finalize with a7 - 0x1c, both read
from the link / push / bsr sequence. Saved registers and matmul's register spill
are not modelled because no result reads them. The test checks a mixed-sign
product, the returned a0 (b + 6), the built matrix and the temp matrix in place.

The remaining builders and composers (`0x2428` .. `0x2700`: the 3-angle, x-axis and
6-angle forms and their alternates) follow the same pattern. Each composer's
matmul operands were read from its pushes; the tagged composers store their
runtime address ($2408 / $2468 / $26e0) at `DAT_00020ce4`. Builders enter their
composer at 0x1c, 0x24 or (`build_attitude_matrix_x_alt`, whose `link.w a6,#-0x24`
frame is never popped before `unlk`) 0x40 below their own entry. The test runs
all six builders against a model that executes each composer's disassembly.
`check_sync.py` gained a fallback for parameter lists wrapped over two lines
(the 6-angle builders); it runs only when the one-line form finds nothing, so
earlier hashes are unchanged, and `test_strict_port_sync.py` now derives its
counts from the manifest instead of the original fixed 3.

`transform_vecs12_by_matrix3` (`0x28dc`) and `transform_vecs12_to_int3_by_matrix3`
(`0x2976`) apply a matrix to 12-byte vertex records (words at +2 / +6 / +0xa):
each output is (x * m[i] + y * m[3+i] + z * m[6+i] + 0x800) asr 12, stored as a
word or a long. The port keeps Ghidra's form of the 32-bit `dbra` / `clr.w` /
`subq.l` / `bcc` count loop with explicit widths. The test covers count 0, an
in-place transform, a sum that wraps at 32 bits (visible in the long store), and
count 0x10001, which exercises the high word of the counter.

`transform_int3_vecs_by_matrix3` (`0x2ada`) transforms 32-bit vectors with 64-bit
`muls.l` sums and keeps bits 12..43 (no rounding); its sign-extended matrix copy
in the frame is kept as a local because nothing else reads it, and the count-0
return value (d0 = matrix + 18 from the copy loop) is reproduced.
`transform_listed_object_vecs12_by_1d744` (`0x2a0e`) walks the visible list from
`visible_list_split` to `visible_count`, shifts each int3 vertex by the object's
word +0x32 (`asr.l`, count mod 64), cuts it to a word and transforms it in place by
the camera matrix at `0x1d744`. The test checks wide 64-bit sums, the count-0
return, the split boundary, a shift of 40 and the untouched high words.

`translate_int3_vecs` (`0x1c5c`), `apply_template_chain_xform` (`0x2bd8`) and
`apply_template_chain_xform_always` (`0x2d10`) walk an object's parent chain and
apply each parent slot's rotation and offset. Their position copy and slot matrix
are frame locals passed by address, so they live in `Memory68k` at a6 - 0x1e and
a6 - 0x12 (a7 - 0x22 / a7 - 0x16), and `build_attitude_matrix_3ang` is entered
0x5c (nine saved registers) or 0x58 (eight) below the entry, as the link / movem /
push / bsr sequences give. The test covers the committed point path, the
uncommitted point path (src set, dst 0), the mesh path with the +0x34 offset
shift (only in the first variant) and the 32-bit wrap of the translation.

`scale_int3_vecs` (`0x1cac`) multiplies int3 vectors component-wise (`muls.l`, low
32 bits). `transform_through_node_chain` (`0x4f8`) pops nodes from a node-pointer
stack and applies each node's rotation and offset to the object position (longs at
+2 / +6 / +0xa) and, with a vertex buffer, to its vertices (offsets shifted by
word +0x18). Its matrix and running position are frame locals passed by address
(a6 - 0x1e / a6 - 0xc), and `build_attitude_matrix_3ang` is entered 0x60 below the
entry. The `check_sync.py` fallback for wrapped signatures now requires the
function body's `{` after the match, so a `)` inside a parameter comment on the
first line no longer ends the signature early; earlier hashes are unchanged.

`traverse_scene_tree` (`0x5fa`) and `for_each_mission_scene_object` (`0x6a6`)
introduce calls through code pointers (`jsr (a6)`). The strict module now has
`code_table`, a map from original code addresses to ported Callables, and `_jsr`,
which fails loudly for an address with no ported target. Only tests register
entries so far; ported visitors will be registered as they are translated. The
ten-slot path stack is a frame local written through memory (a6 - 0x28 of
`for_each_mission_scene_object`); traverse and its visitors are entered 0x6d8 and
then 0x40 per level below, as the movem / push / bsr sequences give. The test
builds a two-level scene and checks every visit's arguments, the path stack
contents and the visitor's stack depth.

The first real visitor is `nearest_type80_centroid_visitor` (`0xaba`), registered
in `code_table` at 0xaba because `point_near_camera_or_type80_object` (`0xbea`)
passes it with `pea $aba(pc)`. The visitor places the node through
`transform_through_node_chain` into its 0x690-byte frame buffer, averages the
face's vertices and keeps the nearer centroid; its frame (buffer, sums, origin
outs) lives in `Memory68k` because those addresses are passed to other functions.
The test runs the full chain - `point_near_camera_or_type80_object` ->
`for_each_mission_scene_object` -> `traverse_scene_tree` -> visitor ->
`transform_through_node_chain` -> attitude matrix -> vector transforms - over a
one-leaf scene: a far point replaced by the centroid, a near point kept, a scene
without a type-0x80 face returning 0, and an equal metric keeping the old best.

The four polygon clippers `clip_polygon_x_min / _x_max / _y_min / _y_max`
(`0xb190`, `0xb242`, `0xb2f4`, `0xb3aa`) are the leaves of `collect_map_features`
(and of other polygon paths). They interpolate crossings with a 64-bit `muls.l`
product and a 64 / 32 `divs.l`, so `C68k` gained `divs_l_64_32`, which applies the
68020 overflow rule (quotient register unchanged, i.e. the low long of the
dividend). The test runs a quadrilateral through all four passes, a polygon fully
outside, count 0, and a wrapped-difference case where that overflow rule decides
the result.

`collect_map_features` (`0x6ec`), registered at 0x6ec (`pea $6ec(pc)` in
`plot_mission_map_symbols`), is the map visitor. Land nodes go through the node
chain, are made player-relative, divided by the map scale (32-bit `divs.l`), and
their face outline is clipped by the four clippers - with `clip_y_max` swapped for
the word at 0x1b740 around the last pass - before the host hook stored at
host_world +0x292 is called through `code_table`. Zone faces (type 0x70) and
kind 0x12 / 0x13 sites append to the context lists. The test registers a stand-in
hook and checks the clipped outline, the restored `clip_y_max`, the hook's stack
depth and all three list cases. (The land test is byte +0x16 bit 4, i.e. word
0x1000; the decomp header that said "flag 0x10 ... in the node word" was corrected.)

`plot_mission_map_symbols` (`0x954`) completes the map path: it fills its frame
context (a6 - 0xb5c) through `for_each_mission_scene_object` with code 0x6ec, picks
A / B / C (or none) per zone point from the first site within range, adds the 'T'
marker for missions 3 and 4, and calls the plot callback through `code_table`. Its
test replaces 0x6ec by a stub that fills the lists, to isolate the symbol logic
(the visitor has its own test), and checks every plotted symbol, the callback's
stack depth and the mission-dependent 'T'.

`segment_point_min_distance` (`0x3cca`) bisects a segment four times with
`approx_dist3_xyz`; only the low words of the deltas are used (`adda.w`) and the
distances are compared and returned as words, which the test exercises (a 0x12345
delta, a distance above 0x7fff). Its bullet-test callers also need
`overlay_rng_next` (0x11564) and `retire_entity` (0x51ec) and come after those.

The overlay RNG is now strict: `overlay_rng_mul_mix` (`0x114ca`), `overlay_rng_init`
(`0x1150a`: LCG fill, cursor 0x260e4, 10000 warm-up steps) and `overlay_rng_next`
(`0x11564`: lagged-Fibonacci ring 0x2600c..0x260e7 in `Memory68k`). Its vectors
(seeds 0 and 12345) come from an instruction-level model, not from the prototype
RNG in `godot/hellcats/`. `retire_entity` (`0x51ec`) is ported with it; its test
covers the shot latch, the child-table clear, the scatter-slot window and the
equal-byte path.

The manifest records the exact source-function SHA-256, source/original names,
address, target, and independent milestone booleans. Run
`python3 tools/progress_stats.py` for current orthogonal coverage counts.

## Synchronization workflow

Run `python3 tools/strict_port/check_sync.py --json`. The checker extracts the
mapped function by canonical name, hashes the complete definition, confirms the
target function and deterministic test exist, and emits independent status and
coverage counts. A changed definition is reported as `SOURCE_CHANGED` with old
and new hashes. The checker never edits the manifest or GDScript. Its Python
test makes a temporary altered source copy and proves drift is detected while
the real manifest remains byte-identical.

Adding a port is therefore an explicit review operation: translate the current
source, add independent vectors/evidence, add one manifest row with the reviewed
hash, run synchronization and tests, then advance each milestone separately.

## Migration plan

1. Keep the prototype and strict namespace side by side; do not change the main
   scene while strict coverage is foundational.
2. Port pure verified helpers first, followed by their minimal packed-state
   dependencies and callers. Compare strict results with independent binary,
   fixture or runtime evidence.
3. Add a thin adapter only when a coherent verified slice can consume input or
   publish render/audio state. Run prototype and strict paths independently for
   comparison before switching any consumer.
4. Retire an approximation only after the replacement is mapped, structurally
   and behaviorally verified, integrated, and covered by regression tests.

The second slice, `find_contact_record` (`FUN_000135a0`), directly calls the
completed hash function. It uses the original `DAT_0001bdbc` address, a 256-slot
open-addressing pointer table, record offsets +0/+4, the original decompiler
locals and signed 256-probe counter. `Memory68k` supplies bounds-checked packed
big-endian byte/word/long access instead of a semantic dictionary substitute.

The next smallest concrete slice is `set_view_distance` (`FUN_0001771a`), a
verified three-global update adjacent to the radar reset. It can reuse the same
packed-memory state and requires explicit signed 32-bit left-shift/wrap behavior
for `param_1 << 1`.
