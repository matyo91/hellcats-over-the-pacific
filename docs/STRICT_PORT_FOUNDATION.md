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
`code_table`, a map from original (runtime) code addresses to ported Callables, and `_jsr`,
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

`bullet_hits_shape` (`0x1665a`), `apply_random_aircraft_damage` (`0x16724`) and
`bullet_hits_aircraft` (`0x167f4`) are the bullet collision tests. Their callers
pass D0 on as their own result, so these ports return D0 as the bytes leave it on
every path, including after `retire_entity`, which now returns its own D0 (the
caller's D0, byte +1, or 7 after the slot scrub). The test drives them from a
seeded RNG through every branch: miss, flag-4 latch roll, ignored type 0xe,
type 0x1b, no controller, the aircraft hit / sound / damage rolls and a damage roll
that moves bit 9 to bit 8. `check_sync.py` gained a last-resort pattern for
parameter comments containing `;` (needed by `apply_random_aircraft_damage`); it
runs only when the earlier patterns fail, so existing hashes are unchanged.

`dispatch_collision` (`0x14348`) reads handler addresses from data (definition +0x12
and the pair table copied from file 0x1b45c), which hold RUNTIME addresses (file -
0x20): 0x167d4 is `bullet_hits_aircraft` (file 0x167f4) and 0x14326 is a lone `rts`
(file 0x14346). `code_table` is therefore keyed by runtime address throughout; the
two visitors moved to 0xa9a and 0x6cc, because `pea x(pc)` pushes the runtime
address too. `_jsr` treats the lone-`rts` addresses (`RTS_ONLY`) as returning the
caller's D0. The test runs the real pair table: bullet against aircraft in both
orders, an ignored pair, the moving-object fallback, a single handler and both
early exits, with the cursor left where the bytes leave it.

Three of `tick_bullet`'s callees followed: `probe_nearest_facility_kind` (`0x354`:
nearest in-range air base of type 0x12 / 0x13 over the low word of `object_count`),
`tally_destroyed_entity` (`0x488`: kill counters at host_world +0xb8 + 2t, or +0xd2
for negative types and kills near a friendly base) and `dispatch_entity_cleanup`
(`0x528a`: retire inside the child window or for non-shapes, otherwise stamp the
frame). They return D0 as the bytes leave it, like `retire_entity`.

`spawn_destruction_effect` (`0x11db4`) is the first port whose direct callees are not
ported yet: `spawn_effect` (`0x11c58`) and `surface_type_under_object` (`0x13452`).
Such calls go through `_bsr_unported(file_address, args)`, which looks the callee up
in `code_table` under its runtime address and fails loudly when it is missing; the
mapping row lists both in `blocked_by` while the function's own logic is VERIFIED.
The test supplies recording stand-ins and checks the effect arguments for the air
burst, the ground-height surfaces, water, a sign-extended surface byte, truncating
3 * size / 4 with a negative size, and the no-controller path.

`tick_bullet` (`0x15dc8`) completes the bullet path on top of these: hit handling
(effect size range / 8 or / 4, kill tally for player bullets, cleanup, retirement),
then the lifetime counter, gravity after frame 3 and ground retirement. Both
controller tick loops discard D0, so the port returns nothing. Its test covers each
lifetime and gravity case (including the flooring `asr` of a negative speed) and
both hit-size divisors.

The surface lookup is now strict: `point_in_polygon_xz / _yz` (`0x13070`,
`0x1310e`), `project_face_vertices_xy / _xz` (`0x131ac`, `0x1320a`),
`surface_type_at_point` (`0x13346`, projection buffer in its frame) and
`surface_type_under_object` (`0x13452`). `spawn_destruction_effect` now calls the
ported `surface_type_under_object` directly (entered 0x20 below it), and
`tick_bullet` enters `spawn_destruction_effect` 0x18 below its own entry; only
`spawn_effect` remains supplied through `code_table`. The tests of both callers now
get their surface from the default ground face instead of a stand-in, and the new
test covers the object filters, face order, the sign-extended code 0x80, the
low-word count, both polygon tests and the xy projection.

`spawn_effect` (`0x11c58`) is ported: effect log ring, replay gating, explosion
sound timers, controller set-up, the per-kind initialiser through `code_table` and
the debris loop, each callee entered at the depth the bytes give (0x4c / 0x30 /
0x3c). Its own callees `spawn_mission_pool_object` (`0x5116`) and
`spawn_debris_fragment` (`0x173fe`) remain unported (`_bsr_unported`), as do the
initialisers. `spawn_destruction_effect` now calls it directly (0x3c below), and
the caller tests read the effects back from the log `spawn_effect` writes.

`spawn_mission_pool_object` (`0x5116`: first free slot of the scene root's table,
growth by 10 records, low-word stores of the angle / factory arguments, retirement of
an object without vertices) and `spawn_debris_fragment` (`0x173fe`: random velocity
and angles from the overlay RNG; word +0x36 is the low word of the y velocity it has
just stored, shifted left by 4) are ported, and `spawn_effect` calls both directly.
Their own callees `heap_realloc_grow_only` (`0x1ba8`) and
`instantiate_mission_pool_slot` (`0x46da`) stay unported. Note for test authors: a
GDScript parse error in one test makes `run_all.gd` hang instead of exiting, so run
it under a time limit.

The heap allocator is strict: `heap_sbrk` (`0x1958`), `heap_new_size_class_block`
(`0x1974`), `heap_add_large_block` (`0x199a`), `heap_free_coalesce` (`0x19d0`, including
the fall-through store at the false entry 0x1a48), `heap_alloc` (`0x1a68`),
`heap_zero_payload` (`0x1b38`), `heap_alloc_cleared` (`0x1b6c`), `heap_calloc`
(`0x1b84`), `heap_realloc_grow_only` (`0x1ba8`), plus `memmove_block` (`0x1a63e`) and
`memzero` (`0x1a716`). The block copies keep the original's direction rule; its
long-versus-byte chunking never changes the bytes written, so the port copies bytes
(documented in the functions). The arena lives in `Memory68k` at host_world +0x348;
the test's expected addresses come from a Python model of the allocator written from
the disassembly. `spawn_mission_pool_object` now grows its table through the real
`heap_realloc_grow_only`.

Object creation followed: `alloc_object_from_desc` (`0x45ba`; another tag returns the
caller's D1), `instantiate_object_from_desc` (`0x4690`), `apply_entity_mission_rates`
(`0x435a`) and `instantiate_mission_pool_slot` (`0x46da`), so the pool spawn now runs
the real instantiation (template chain transform, class factory through
`DAT_0001b524` +6, mission rates, camera metric). Its remaining unported targets are
`activate_near_range_object` (`0x4e6e`) and the class factories. Tests that spawn
pool objects share `tests/strict_port/helpers/pool_fixture.gd` (scene root,
templates, descriptors, heap arena, stand-ins for those two). One behaviour the
tests pin down: a far object is appended to `entity_array_3` without activation, so
it has no vertices and `spawn_mission_pool_object` retires it and returns 0 while the
pointer stays in the array.

Five leaves of `activate_near_range_object` are ported: `update_object_distance_band`
(`0x3da8`) and `update_record_distance_band` (`0x3e02`, the same band search on another
offset), `build_object_poly_buffers` (`0x4808`), `set_object_faces_bw_pattern`
(`0x4916`) and `reset_object_to_template_pose` (`0x4e06`). Its remaining callees are
`shade_object_faces`, `sink_object_shape_at_waterline` and
`build_land_outline_at_detail`.

`activate_near_range_object` (`0x4e6e`) itself is ported (list publishing, vertex and
face buffers, controller listing, the four flag paths, group children), with those
three callees as `_bsr_unported` stand-ins, and `instantiate_mission_pool_slot` now
calls it directly. Because a real activation always allocates the vertex buffers, a
pool spawn now only fails through the far / deferred path; `PoolFixture.make_far`
sets that up, and the fixture also provides band thresholds and the shading
stand-in. `test_activate.gd` covers each flag path, the one-bit-display pattern,
the sink arguments, the group path and the metric-only kinds.

Shading and the palette chain are ported: `queue_face_palette_entry` (`0x147a`),
`write_face_palette_slot` (`0x1548`), `assign_face_colour` (`0x159e`),
`snapshot_face_colours` (`0x3e5c`) and `shade_object_faces` (`0x3ea0`), so
`activate_near_range_object` now shades through the strict code. A detail the test
pins down: byte +6 bit 1 is flag-long bit 0x200, one of the 0x1280 bits that turn the
haze off for an object, and the same bit makes it take the colour snapshot - an
object that gets the snapshot is never hazed. The pool fixture now identifies
activated shapes from the lists activation publishes to (`activated()`).

The waterline sink is ported: `clip_polygon_y_nonneg` (`0x1562e`) and
`sink_object_shape_at_waterline` (`0x15762`). The sink keeps its 0x3358-byte frame in
simulated memory below `a7` (attitude matrix, normals, the 256-bucket point hash and
the clip buffers), clips every template face to y >= 0, gives repeated points one id
through the hash, and rebuilds the +0x44 / +0x4c buffers (points, then the normal
points moved with the new vertex 0). `activate_near_range_object` now calls it
directly; `build_land_outline_at_detail` is its last unported callee. `test_sink.gd`
loads the original sin / cos tables, so angles 0 give the identity matrix.

`build_land_outline_at_detail` (`0x4958`) is ported, so every callee of
`activate_near_range_object` now runs strict code. It thins each face outline by
camera distance (a vertex is kept once the distances skipped since the last kept one
reach camera distance divs.l (host +0xa8 + 3)), clips it to the +-limit square
through the four clip passes (each bound global saved, set and restored), merges
equal points and rebuilds the vertex buffers like the sink, then sets the position
to `detail_ref`, the range, the camera metric and the +0x32 detail shift.
`test_land_outline.gd` covers the shared indices, the shift rounding, a clipped face
and a fully thinned object; `test_activate.gd` now also loads the trig tables.

The 20 controller factories that definition records point to at +6 are ported, with
`fill_pose_history` (`0xdf5e`): spinner, plume, camera-facing, effect, ordnance,
carrier, firing ship, sinking, basic ship, bullet, trail, ground fire, debris, ground
mark, shadow, flak, turret, parachute, cloud and view-attached (`0x11486`..`0x19b82`).
Each one allocates a cleared controller, stores the object and the definition, sets its
object flags and fields, and returns the controller in D0. They are registered in
`code_table` under their runtime addresses (file - 0x20), the form the definition
records store, so `_call_class_factory` reaches them directly. The plume and ground
fire factories read `DAT_0001b524[7]` / `[11]` as absolute longs and ignore the key.
`test_factories.gd` calls each one through `code_table`. The four aircraft creators
(`aircraft_create` and the fighter / bomber variants) are still unported.

The four effect initialisers in `effect_init_table` (`0x1b40c`, kinds 0..3) are ported:
`init_effect_kind0_flat_ring` (`0x1203a`), `init_effect_kind1_column` (`0x120ca`),
`init_effect_kind2_burst` (`0x11efc`) and `init_effect_kind3_debris_explosion`
(`0x1217e`). The entries after kind 3 belong to the animate table, not to the
initialisers. Each one scales the effect's vertices by its size (size × 256 / 100,
low long of `muls.l`), sets the start velocities, clears the shift and scales the
range. Kind 2 adds RNG jitter and triples alternate velocities; kind 3 first spawns a
kind-2 burst through the strict `spawn_effect`. They are registered in `code_table` by
runtime address, so `spawn_effect` now reaches real initialisers.
`test_effect_init.gd` checks kinds 0, 1 and 3 against an instruction-level model and
kind 2 against the byte formulas fed by a twin RNG.

The aircraft creators are ported with their callees: `init_aircraft_controller`
(`0xdff0`), `aircraft_create` (`0xe0ce`), `create_enemy_fighter` (`0xe1e6`),
`create_friendly_bomber` (`0xe2a4`), `create_enemy_bomber` (`0xe340`),
`spawn_object_shadow` (`0x18956`) and `spawn_turret_on_object` (`0x19130`). Every
class factory that a definition record points to is now strict code, and no mapped
function is blocked any more. Details the test pins down:
- the first `aircraft_create` becomes the player: bombs come from host byte +0xb9,
  the weight word is moved by the difference, and fuel is scaled by the host
  percentage, with at least 1 in the left tank;
- in host mode 2, and for bombers, the bomb count changes without the weight word;
- the first key-4 fighter is only kept as `enemy_fighter_template`;
- a shadow gets the far metric only when its owner is `*player_object`;
- the bombers' gunner turrets are configured, and the enemy bomber's gets +0x3e =
  0x100.

Effect ticking has started. `tick_effect` (`0x12768`) and the animators for kinds 0
and 1 are ported: `animate_effect_kind0_ring` (`0x123ce`; Ghidra's
`animate_effect_kind0_ring_tail`, `0x12466`, is a false split of its loop and maps to
the same target) and `animate_effect_kind1_column` (`0x12486`). So are the two
spawners that kinds 2 and 3 will need, `spawn_smoke_plume` (`0x115fc`) and
`spawn_ground_mark` (`0x175de`). Velocities decay as v × 3, plus 3 when negative,
asr 2, and the 32-bit wrap of that product is tested. `tick_effect` tests only the
low word of the animator's D0. `test_effect_animate.gd` covers both animators, the
kind-1 spawn at lifetime 0x47, the tick (count-down, hide, retire) and both spawners.
The kind 2 and kind 3 animators are now ported as well, so `tick_effect` is no longer
blocked.
- `animate_effect_kind2_burst` (`0x12296`) moves the twelve burst vertices in x / y,
  halves their velocities and darkens the faces by 6/8 at view depth 8. When it
  finishes with the smoke byte set, it spawns a smoke plume (size × 3, size × 6).
- `animate_effect_kind3_debris` (`0x12528`) applies gravity to y (clamped at 0) and
  decays x / z to 3/4. It sets vertex 12 y to vertex 2 y × 3/2 and darkens by 7/8 at
  host depth 8. Debris spawned live is hidden and idle while any replay runs. Once
  landed, live debris spawns a ground mark (when the object lies at y 0) and a smoke
  plume sized from vertex 1 z: both its long and its low word are read, as in the
  bytes. Replay debris finishes without spawning, except in replay state 3, where it
  stays.
`test_effect_debris.gd` checks the movement against a Python instruction model and
covers the palette-owner rule and every replay branch.

Five self-contained controller tick handlers are ported and registered in `code_table`
under their runtime addresses (definition record +2):
- `tick_ground_mark` (`0x175c0`) retires the mark at its expiry frame.
- `tick_view_attached_object` (`0x19bbc`) keeps a fixed offset from the camera and the
  negated camera angles.
- `tick_shadow` (`0x189d0`) follows its owner and is retired with it, dropping the
  owner's reference count.
- `tick_debris_fragment` (`0x174c4`) spins and falls. In replay state 3 it saves the
  position, then moves. It is retired at its end frame or on its floor.
- `tick_smoke_plume` (`0x116fc`) records a ring of the burning owner's positions. Its
  burning flag is bit 0 of byte +0x684, the high byte of that controller word, and the
  test checks that the low byte does not count.

None of them sets D0 before `retire_entity`, so the caller's D0 is passed through.
Sinking is ported: `carry_attached_objects` (`0x14bea`), `step_sinking_object`
(`0x14d86`) and `tick_sinking_controller` (`0x155d8`).
- Each due step advances the sink angles and drop and re-cuts the hull at the waterline.
- While the ship floats, its cargo is carried: types 7 / 0x1b / 0x1a / 8 within range.
  Each cargo object's position is recomputed through its template chain, its word
  offset from the ship is rotated, and the drop is subtracted from y.
- Once nothing is left above water, the cargo is removed and the kill is tallied. The
  mission-7 / 8 / 9 facility flags are set, and the ship is cleaned up.
`test_sinking_step.gd` runs the real waterline cut with the original trig tables. It
checks the cargo position exactly with zero angles; with non-zero angles it checks
only the angle words.

The inverse trigonometry the turrets need is ported: `acos_fixed14` (`0x1e3a`,
searching the cosine table), `atan_fixed14` (`0x1ebc`, searching the 128-long tangent
table at `0x1af6c`), `isqrt_floor` (`0xe372`) and `attitude_from_velocity` (`0x1f22`,
the heading and pitch of a word velocity). All three searches stop at hi − 1, so
`isqrt_floor` never returns 0x7fff: the square root of 0x3fff0001 comes out as 32766.
Ratios past the tangent table land on its last entry, which is out of order.
`test_inverse_trig.gd` compares them against an instruction-level Python model over
the table bytes from the original binary.

Turrets fire through strict code: `spawn_ordnance_scattered` (`0x15bf6`),
`spawn_ordnance_oriented` (`0x15d20`), `spawn_ordnance_oriented_3ang` (`0x15d78`) and
`tick_turret` (`0x1917c`, registered by runtime address).
- A bullet's forward velocity is rotated by the attitude matrix, jittered by three RNG
  draws, and stored as quarters; the matrix is copied into the bullet.
- The turret rides its carrier and lets go of a carrier that is retired or burning,
  and of a target that is retired or has no vertices.
- It aims with `attitude_from_velocity` on the target offset, scaled down by the
  distance's magnitude.
- In live play it fires bursts with a scatter that shrinks to 7/8 per shot.
`test_turret.gd` covers each branch and predicts the RNG with a twin.

The blast damage path is ported: `fold_angle_pm_0x2000` (`0xe40c`),
`apply_hit_to_sinkable_object` (`0x14f48`) and `apply_blast_damage` (`0x12b66`).
- A blast hits whatever lies within its range; non-aircraft are also hit up to 599
  past it. Aircraft past their range are hit by an RNG chance; otherwise they take
  random damage.
- Ships take a sinking hit; aircraft get damage bit 0x400. Anything else is destroyed:
  destruction effect, kill tally, cleanup.
- Objects whose range exceeds the blast radius are hit only as ships, and only with
  `hit_ships`.
- A sinking hit uses one of the ship's hits. The remaining count picks the roll:
  - 2 left: an angle-c roll;
  - 1 left: an angle-a roll, plus the c roll if the ship was not yet sinking;
  - 0 left: a large roll toward its list (the folded first angle), plus the c roll if
    not yet sinking.
  Each roll draws its own drop, and the angles and drop are spread over 15 steps.

Quirk: with any other count the drop register (D4) is not set, so the caller's value
is used. `apply_blast_damage` leaves its credit flag there.
`test_blast_damage.gd` covers every roll with a twin RNG and the blast filters.

`tick_flak_gun` (`0x18c96`) is ported and registered by runtime address. On its first
tick the gun finds its barrel: the first face flagged 1, giving the mean point and the
aim of the face's normal. In live play:
- due burst slots explode: `spawn_effect`, then `apply_blast_damage` with radius 500;
- one RNG draw in 64 tries a shot at the target. A shot needs a pitch above 0x3f and a
  heading within 0x1000 of the barrel.
- A shot fills the first free slot. Its fuse is distance / 1024 frames, and the burst
  point leads the target by the fuse plus a random 0..63 frames, with random jitter.
  It is kept 500 above the target's ground.
A heading that `attitude_from_velocity` leaves unwritten keeps the frame word's old
value, as in the original, so the frame words live in simulated memory.
`test_flak_gun.gd` checks the aim against the inverse-trig model and the shot against a
twin RNG.

The fighter wave spawner is ported: `spawn_enemy_fighter` (`0xe262`) and
`tick_wave_spawner` (`0x180c8`, registered by runtime address). Each due wave spawns
one fighter at a random bearing within ±0xa80 and a random distance, 40000 up, from a
fixed point. Its heading points back across the bearing. The fighter gets damage bit
0x20 and, while the mission-7 target list is unset, the 0x111ba handler. In host mode
7 it is recorded in that list. The next wave is due 0x1356 frames later when five
remain, otherwise 0x546, plus a random spread.

`tick_aircraft_spawner` (`0x17dd4`) is ported and registered by runtime address. It
keeps up to five launched aircraft, releasing the retired ones. Only when none of them
is undamaged does one RNG draw in 512 launch a group of 1..min(left, 3). The group
starts beside the player, toward the spawner (bearing from `attitude_from_velocity`,
randomly turned) at two thirds of the spawner's range, at 30000 + 10 × (rng & 0xfff).
Each aircraft moves a further random ±0x800 on x and z. The index scale (4) and the
`divsl.l` remainder were decoded from the extension words; capstone omits both.
`test_aircraft_spawner.gd` predicts a whole group with a twin RNG.

Firing ships are ported: `spawn_weapon_entity` (`0x12840`) and
`tick_firing_ship_controller` (`0x15356`, registered by runtime address). A sinking
ship only steps its sinking. Otherwise its guns are found once: every face flagged 1
gives a position (the vertex mean) and an aim (its normal). With shells left, one RNG
draw in 256 fires a randomly picked gun (a `divsl.l` remainder) with ±0x80 of aim
jitter. In live play it spawns a shell 10 above the gun, at speed 0x7fff − (rng & 0xff).
`test_firing_ship.gd` predicts the shot with a twin RNG; the aims match the
inverse-trig model.

Scanning the data file for definition records (by their +6 factory pointers) listed
the remaining handlers of those records. Seven small ones are now ported and
registered by runtime address:
- `spin_object_heading` (`0x114b4`) and `face_camera_heading` (`0x11ae6`);
- `create_aircraft_spawner_controller` (`0x17d16`): the launch count depends on the
  object's range variant;
- `destroy_aircraft_spawner_controller` (`0x17db8`): it releases slots 0..2 only,
  although the tick uses five, as in the bytes;
- `create_wave_spawner_controller` (`0x18040`): in host mode 7 it allocates the
  mission target list;
- `destroy_flak_controller` (`0x18b98`);
- `flak_notice_object` (`0x18bba`): target selection by a 1-in-64 roll and a
  distance-based chance; a held target is replaced only by one under half its
  distance.
`test_small_handlers.gd` covers them.

Aircraft destroy and collision handlers are ported, registered at the runtime
addresses the aircraft definition records hold:
- `aircraft_destroy` (`0xe0a4`): frees the +0x616 buffer and releases the AI target.
- `aircraft_collision` (`0xfe0a`), in live play: damage bit 0x400 for this aircraft
  and any aircraft it hits. Hitting a ship sets off a radius-10 blast at the aircraft,
  raised to its ground; it is credited when the aircraft is the player's.
Two helpers of the notice handlers are ported as well: `invert_ai_bias_67b_if_positive`
(`0x10cd8`) and `add_radar_track` (`0x176b2`, at most six tracks within
`radar_limit`). `test_aircraft_handlers.gd` covers them.

`aircraft_notice_object` (`0xfe96`) and `release_ai_target` (`0x100bc`) are ported.
- **Player's aircraft:** in view modes 1 / 7 / 8, aircraft it notices high above their
  ground get radar tracks, and the nearest non-player one becomes `designated_entity_2`.
- **AI aircraft:** they notice enemy aircraft (types 3 / 4) and ships (0x15..0x19,
  decoded from the jump table) by a 1-in-64 roll and a chance from the target's range
  over its distance.
  - Aircraft targets need ammo.
  - Ships need bombs and a friendly facility (0x100) nearby.
  - A held target is replaced only by one under half its distance.
  - Taking a ship switches the AI to its bombing state 0x112c0.
`test_aircraft_notice.gd` covers both paths with a twin RNG.

`enemy_fighter_notice_object` (`0x100d4`) is ported. Enemy fighters consider the
player's side (types 1 / 2) and ships near an enemy facility (probe 0x200).
- An escorting fighter (0x111ba) takes a ship only while it has no target.
- Otherwise a ship sends a damaged fighter to escort and an armed one bombing (0x112c0);
  an aircraft target needs ammo.
The D0 these notice handlers leave is not modelled yet; their callers are not ported.
`test_fighter_notice.gd` covers each branch with a twin RNG.

`dispatch_overlap_collisions` (`0x5832`), the caller of the +0x16 notice handlers, is
ported. It sweeps the object list and calls both notice handlers, (self, other) then
(other, self), for every pair where a later entry's reach (metric + radius) passes an
earlier entry's start (metric − radius). The backward scan stops at the first entry
whose running minimum start (+0x28) is above that reach. It never uses the D0 the
handlers return.

The comparisons only make sense for a list in decreasing metric order: in increasing
order every earlier entry would pair [STRONG INFERENCE]. `test_overlap_dispatch.gd`
uses such a list.

`animate_landing_gear` (`0xfb2a`) is ported and registered by runtime address
(definition +0xe). While the gear moves, each gear face swings on its own side, with
its normal and vertices rotated by one of two mirrored matrices. Fully up, the gear
faces are hidden. Every call rebuilds the body matrix at `0x1d72c`.
`test_landing_gear.gd` covers four cases:
- gear down: angle 0, so every point lands back on the template;
- gear up;
- moving: the two legs come out mirrored;
- at rest.

The helpers that `update_aircraft_damage_state` calls are now all ported:
`request_instant_replay` (`0x8784`), `attach_trailing_plume` (`0x11670`),
`spawn_ground_fire_object` (`0x170ba`), `attach_ground_fire` (`0x17102`) and
`remove_mission_target` (`0x17ffe`).
- A trailing plume starts its eight-point trail at itself, clears object bit 0x100000,
  and follows the aircraft.
- A ground fire starts in state 1 with timer 0x2d.
- Removing a mission target clears every slot that holds the aircraft. When none
  remain, host word +0xce is set to 1 if it was still 0.
`test_damage_helpers.gd` covers them.

`update_aircraft_damage_state` (`0x10650`) is ported. It advances the damage stages:
smoking 0x40 → 0x80 / 0x200, burning 0x100 → destroyed 0x400. The pass repeats on the
newly set bits, with the newly cleared bits standing in as the "previous" state; the
C's reading differs here, and the bytes win. Stage timers are 0x7f plus half a random
byte. A newly destroyed aircraft triggers the player's replay request, the mission
flags, the kill tally and cleanup; the destruction effect runs with `replay_state`
forced to −1. The `btst` tests on byte +0x684 are word bits 0x800 / 0x400 / 0x1000 /
0x100, the last of which arms the AI bail-out roll. The D0 it leaves is not used by
`aircraft_tick` and is not modelled. `test_damage_state.gd` covers the stages, timers,
destruction and bail-out flags with a twin RNG.

`aircraft_tick` (`0xe5aa`) is ported and registered by runtime address (definition +2).
It keeps a 75-entry pose ring:
- In live play it runs the aircraft's handler at +0x32 (a wreck stops instead), takes
  the damage step, and records the pose.
- In a replay it jumps onto the recorded pose at the start frame or on a rewind;
  otherwise it steps towards the pose and takes over the recorded damage word. A
  recorded stage restarts as smoking.
- Dead code kept as in the bytes: the gear-bit test after the damage step can never
  fire, because the damage step ends with +0x686 = +0x684.
Its mapping is blocked on the AI and flight handlers stored at +0x32, which are not
ported. `test_aircraft_tick.gd` drives it with a stub handler.

The flight model `update_aircraft_entity` (`0xe792`, 1184 lines) is next to
everything at +0x32; its leaf helpers come first. Now ported:
- `table_lerp_1b2c0` (`0xe42a`): the inverse-density altitude curve. Bands are clamped
  at 7, which makes the curve a sawtooth above 0x70000.
- `damp_short_if_below_0x200` (`0xe468`): ground effect.
- `compute_template_force_from_626` (`0xe4a4`): lift from the angle of attack and the
  flaps, fading over 0x20 past the stall.
- `scale_template_field_38` (`0xe570`): engine power at density; sea level gives the
  rated power.
- The AI throttle controller `adjust_ai_throttle_vs_speed` (`0x10c2c`) and
  `max_ai_throttle_maybe_invert_679` (`0x10cb2`).
`test_flight_helpers.gd` checks them against an instruction-level Python model over the
real altitude table and the player's type values.

AI steering is ported:
- `atan2_fixed14` (`0x102d6`). For a zero vector it returns the caller's D2,
  unwritten, and that D2 is threaded through.
- `enqueue_control_inputs_avg4` (`0x10558`): a clamped four-slot ring of
  aileron / elevator / rudder commands.
- `build_relative_steer_sample` (`0x10360`): the target in the aircraft's frame,
  raised near the ground, with climbs limited when far away.
- `apply_relative_heading_steer` (`0x109ba`): PD commands for small errors; otherwise
  a bank toward the target, limited by height.
- `steer_entity_toward_point` (`0x10b2e`). Its D2 holds the frame vector's address when
  it calls the steer, which is what a zero-vector `atan2_fixed14` would return.
`test_steering.gd` checks the angles against the inverse-trig model and works the
control ring and steer commands by hand.

The flight model's remaining callees are now ported. With them, everything
`update_aircraft_entity` calls is strict code.
- `reset_span_row_lists` (`0x6e74`) and `update_view_clip_bounds` (`0x6ed6`): view
  inset, clip bounds and projection scales.
- `release_fractal_reference` (`0x14af2`). Its "still has active objects" warning goes
  through the unported host printer `overlay_printf`.
- `drop_contact_records_for_object` (`0x137da`).
- `spawn_bailout_parachute` (`0x19430`): 13 vertices scaled by 1/8, with start
  velocities derived from them.
`test_flight_misc.gd` covers them.

`update_aircraft_entity` (`0xe792`), the flight model, is translated in full: blocks
0..7c as the semantic C names them, using its section checks and the bytes. It is
registered at its runtime address `0xe772`, the player's +0x32 handler.
- It keeps the frame locals that the bytes read uninitialised in simulated frame
  memory: `local_46` / `local_42` for aircraft without the engine model.
- It follows the corrections the section checks record:
  - the impact speed is taken before the touchdown snap;
  - +0x640 is the carrier-arrest latch;
  - the bomb / gun / leak tests use word bits 0x10 / 0x2;
  - a crash sets 0x900 and +0x32 = `0xe772`.
- `test_flight_model.gd` checks the wrecked-on-the-ground exit (block 0) by hand.
- It checks the flight path against the original bytes themselves:
  `tools/strict_port/m68k_emu.py`, a small 68020 interpreter on capstone, runs the
  routine on the binary image (runtime = file − 0x20).
  `tools/strict_port/gen_flight_model_cases.py` records every byte the original changes
  outside the stack, for 15 states: AI and player cruising, a climbing turn,
  flaps / gear ramps, damage jitter, fuel leak and burn, a gentle, a hard and a tilted
  touchdown, rolling on the deck and on grass, arrest, ditching, and the engine
  switched off.
- The port, given the same image, RNG seed and writes, changes exactly the same bytes.
- Not covered by these cases: the bomb, gun and bail-out branches (block 7b), which
  need a spawnable scene.

Interpreter notes: capstone leaves the base register empty for `(An)`, `(An)+`,
`-(An)` and `movem`, and prints `divsl` / 64-bit `muls.l` without their register pair.
The interpreter takes those from the opcode and extension words; a wrong `divsl` pair
was the only difference it ever showed.

All five AI state handlers that `aircraft_tick` reaches through +0x32 are ported:
`ai_attack_or_fly` (`0x110f4`), `ai_fly` (`0x11182`), `ai_fly_bomber` (`0x111ae`),
`ai_dive_at_target` (`0x111da`) and `ai_bombing_run` (`0x112e0`), registered at their
runtime addresses `0x110d4` / `0x11162` / `0x1118e` / `0x111ba` / `0x112c0`.
- Each ends in the fly step: `ai_fly_table` (`0x1b3f4`) indexed by the kind word +0x614,
  `update_aircraft_entity` when the entry is 0. The table has six entries (kinds 0..5); the
  words after it are `effect_init_table` (`0x1b40c`). Kinds 1..5 are the fly routines below.
- The dive steers at the target with the ground word +0x2e lowered to -40000 and flies
  with it at 0, then restores it; a lost target is released and the state falls back to
  `0x110d4` (ammo word +0x682 > 2) or `0x11162`. In host mode 7 with no target and an
  empty target list it just flies on.
- The bombing run keeps its stage in byte +0x675 (approach, dive, pull-out); the dive
  arms the bombs (+0x674 = 1) below 5000 and the pull-out releases the target past
  45000. An unknown stage flies only the kind step.
- `tools/strict_port/gen_ai_state_cases.py` runs the four handlers on the binary image
  in the interpreter (kind 0); `test_ai_states.gd` requires the port to
  change exactly the same bytes. In the bomb-arming case the bomb drop needs a live pool,
  so `spawn_weapon_entity` answers 0 on both sides (an emulator stub and the test
  subclass `helpers/no_weapon_port.gd`).
- `ai_attack_or_fly` drops a target when out of ammo or when the target is dead, else
  measures it (+0x696) and runs `ai_pursue_target` (`0x1820a`). Beyond 20000 that steers
  straight at the target. Nearer, it aims at the target's pose ring (75 entries at its
  controller +0x36) a lag back (word `0x1b876` for type key 1, else `0x1b878`),
  extrapolated. It then either attacks (relative heading steer, throttle from the target's
  speed, gun phase +0x676 when lined up within 0x7f) or, for a large heading error,
  manoeuvres. The manoeuvres are a reverse (1), a break turn (2) and a loop (3), driven by
  waypoints +0x69c..+0x6a4, phase +0x69b and best distance +0x6a8; manoeuvre 4 keeps
  attacking until rng & 0x1f is 0. The frame locals passed by address live at their a6
  offsets, and `apply_relative_heading_steer` gets the extrapolated z still in D2.
- The interpreter cases now number 47 (28 for the attack state, every manoeuvre phase
  included). A frame that fires the guns also stubs `spawn_ordnance_oriented`; the
  fixture stores the zero fills as ranges. The fresh pick of the loop (rng & 3 == 1
  above airspeed 0x32a0) is not reached by these seeds.

The per-kind fly routines of `ai_fly_table` are ported with their helpers, registered at
`0x10d48` (kind 1), `0x10dc8` (2), `0x10f48` (3), `0x10eac` (4) and `0x10d88` (5).
- Kinds 1, 2 and 5 patrol a four-point route (`0x1b2e0` / `0x1b340` / `0x1b310`). On first
  use, `alloc_transformed_vertex_block` copies the points into a cleared heap block, moved by
  the aircraft's template pose, and sets a speed word (0x9d8 / 0x9d8 / 0xd5c).
  `tick_ai_climb_then_waypoint` then climbs out (`ai_bootstrap_climb_phase`: full throttle,
  gear up, pitch toward 0x2c0 until 2000 above the ground). After that it follows
  `advance_route_waypoint`. Within 4999 of a point that moves to the next point and pushes
  it 5000 further out (the divisor is shifted twice, as the bytes do), aiming at least
  0x1000 above the ground.
- Kind 4 flies the 0x1b310 patrol plus an attack run on a fixed point. Phase 2 releases
  bombs through `ai_script_try_fire_burst` (one roll in eight once the release frame
  +0x6ac is reached).
- Kind 3 is the scripted mission. It copies eight world points (`alloc_copied_vertex_block`),
  then: climb, bomb at point 4, return to point 0, lower the gear and try
  `try_begin_landing_approach`, then glide. Other phase values chase the player.
- The landing approach uses `find_nearest_runway_approach_ends`. It takes the nearest 'p'
  quad of a shape near a friendly air base and turns the quad so its long sides run along
  the runway. The approach starts 10000..0x26ac0 from the nearer end; it fills the glide
  globals (`0x26798`..`0x267c4`) and installs `0x1a186` (`tick_landing_approach_glide`).
- 26 more interpreter cases cover every phase. They include the first-use allocations (a
  prepared large-block free list and a template parent), the bomb roll, and a runway
  (found, rotated with shifted vertices, and too close). The spawn stubs record their
  arguments, so the bomb and gun aims are compared too. The interpreter gained `addx`
  (the 64-bit accumulations of the template transform).
- A mutation check (glide aim + 0x44 instead of 0x43) fails both landing cases.

`tick_landing_approach_glide` (`0x1a1a6`, the `0x1a186` handler) completes the +0x32 set, so
`aircraft_tick` has nothing unported left behind it.
- It holds the ground word at -4000 for the frame and keeps the gear byte. It aims down an
  8-degree slope: the target slides back from the aim point by a lead taken from the range
  in three bands. A height floor applies, and far out the target is pulled toward the
  aircraft's height.
- It corrects for drifting off the centre line (sin / cos of the heading toward the
  target). The heading word sits at a6 - 2, because `attitude_from_velocity` may leave it
  unwritten.
- Word `0x267ac` optionally blends the target with the predicted position (1 -> 2 -> 0;
  set to 2, it counts on to 3, as the bytes do). Height goes through a 33 e - 32 e(prev)
  controller with a clamped integral (`0x267a4` / `0x267a8`). The x / z target eases 1/8
  per frame (`0x267a0` / `0x2679c`) and is mirrored into the `type10_controller` object
  (`0x20b40`).
- Touchdown restores the saved handler. Between 15000 and 18000 a height error over 100 or
  a speed error over 0x5a waves off (word `0x1b83c` = 1).
- 14 interpreter cases cover each band, the floor, the lateral offset, a skewed runway,
  both blend frames, touchdown, both wave-off tests, the integral clamp and the tracker. A
  mutation check (height-controller asl 5 -> asl 4) fails 9 of them.

The ordnance controller (definition key 0xc, record `0x1a988`: tick +2 = `0x12a0a`, collision
+0x12 = `0x12f32`) is ported: `ordnance_tick`, `ordnance_ballistic_step`,
`ordnance_detonation` and `ordnance_collision`.
- Each live frame turns the speed word +0x610 into a velocity through the attitude, adds
  gravity (-0x5b) and stores the velocity / 64. The attitude follows the velocity, and the
  bank turns with the heading change times sin(pitch). The frame words are kept at their a6
  offsets, because `attitude_from_velocity` may leave them unwritten. Reaching the ground
  sets the impact flag 0x400, and a direct hit on land surfaces 0x30 / 0x60 / 0x70.
- On impact a direct hit splashes at sea or blasts on land; otherwise
  `spawn_destruction_effect` decides. A credited bomb on a 'p' surface counts against an
  enemy facility (host +0xcc, and the mission flag +0xce near the mode 3 / 4 targets) or a
  friendly one (+0xd2). The blast lands 5 or 15 frames later through `apply_blast_damage`.
- Replays follow the 75-entry pose ring instead.
- `helpers/original_cases.gd` now replays every interpreter fixture (routine, arguments,
  zero ranges, writes). Stubs come from the fixture (`helpers/stubbed_port.gd`): the
  ordnance cases stub `spawn_mission_pool_object`, recording its arguments.
- `tools/strict_port/gen_ordnance_cases.py` covers 25 states: falling, ring wrap, sea /
  land / non-runway impacts, every detonation branch including both mission targets, the
  blast frame, the burning trail, the three replay paths and four collisions. A mutation
  check (gravity -0x5a) fails 15 of them.

The parachute controller is ported (record `0x1ab1e`: tick +2 = `0x19918`, destroy +0xa =
`0x194fa`): `parachute_tick`, `parachute_descend` and `destroy_parachute_controller`.
- The fall works like the ordnance step, slowed by a drag term over the air density
  (`table_lerp_1b2c0`). From age 16 the canopy opens: a shadow, 13 vertices drifting with
  decaying velocities, and a growing drag. Within 0x17f of the ground it lands, and the
  canopy then collapses toward heading 0x588 until nothing stands and the object is
  cleaned up.
- The interpreter run corrected the semantic C. At 0x196d4 the bytes are `4c47 1800`, a
  `divsl.l d7,d0:d1` whose remainder goes to D0, so +0x616 keeps (sum % 10). That is
  Ghidra's original reading; the earlier "CORRECTED [PROVEN]" note had misread the
  extension word as `0x1801`, and is withdrawn in the C and in `DECOMPILATION_SYMBOLS.md`.
- `tools/strict_port/gen_parachute_cases.py` covers 18 states: early fall, canopy opening,
  untracking, landing on the ground and on a deck, collapse (plain, shifted shape, folded
  heading, nothing left), ring wrap, the three replay paths and both destroy cases.

Ten small controller routines are ported and registered by their definition-record slots.
Records are 0x1e bytes: +0 type, +2 tick, +6 create, +0xa destroy, +0xe pre-render,
+0x12 collision, +0x16 notice.
- **Destroy hooks:** the plume, ground fire and shadow destroy hooks each release the
  owner's reference byte.
- **Pre-render:** `effect_pre_render_hook` dispatches through `effect_pre_render_table`
  (`0x1b42c`). Kind 2 is `face_object_to_camera`; kinds 0, 1 and 3 are the "clr.l d0; rts"
  tails inside it.
- **Cloud tick:** `follow_camera_offset`.
- **Singleton factory:** `create_singleton_type10_controller` publishes `0x20b40`.
- **Collision:** `impact_one_time_in_16` is a collision pair handler (one rng in 16
  becomes an ordnance hit; it returns the masked rng).
- **Pose ring fills:** `fill_pose_history_angles` / `_flags`.
- `tools/strict_port/gen_controller_misc_cases.py` covers 20 states. The replay helper now
  also compares a returned D0 where a case records one, and calls a port function by name
  for routines no dispatch table reaches.

The twelve template registration hooks are ported: the first +6 create hook of the effect /
smoke / ordnance / bullet / trail / ground fire / debris / ground mark / shadow / turret /
parachute / cloud records.
- **Single records:** store the template object and redirect +6 to their controller
  factory.
- **Slot records:** fill the first empty slot of their table (unsigned word index) and
  redirect once the index passes a threshold:
  - effect: 4 slots, index > 2;
  - trail: 2 slots, index != 0;
  - shadow: 4 slots from `0x2676c`, i.e. `shadow_templates[1..4]`, so kind 0 stays empty;
  - cloud: 5 slots, index > 3.
- A full table stores nothing but still redirects.
- `tools/strict_port/gen_template_registration_cases.py` runs every hook and every fill
  level (28 cases, D0 = 0 checked).

The view distance and radar routines are ported: `set_view_distance`,
`cycle_view_distance`, `update_radar_range_buttons` and `update_radar_scope`.
- **Ranges:** the radar range cycles 0xce40 -> 0xc15c0 -> 0x26ac0.
- **Range buttons:** the scale is the range per half scope width (in 1/8 pixels). The three
  range buttons are drawn lit or unlit through host +0x28e.
- **Scope:** last frame's blips are erased on colour screens. Each track is scaled and
  rotated by the camera heading into scope coordinates; inside the scope it is drawn as a
  blip, or on black and white as two host lines (at the scaled offsets, not the screen
  position, as the bytes do). The track lists then swap.
- **Call logs:** these routines draw through code pointers, so the fixture names those
  pointers. The test points them at logging stubs on both sides, and the call order and
  arguments are compared with the memory (`call_logs` in `helpers/original_cases.gd`).
- **Fix to an older port:** the interpreter case showed that `reset_radar_tracks` wrote the
  radar-changed flag as one byte. The bytes (`moveq #1,d0; move.l d0,$2666e`) write a long,
  so the port and `test_reset_radar_tracks.gd` now use the long.
- `tools/strict_port/gen_radar_cases.py` covers 16 states.

The effect log and the sound routines are ported: `replay_logged_effects`,
`mark_effect_log_end`, `stop_all_sound_channels`, `play_game_sound` and `stop_game_sound`.
- **Effect log:** replaying holds `replay_state` at -1, consumes every entry up to this
  frame, re-spawns those of exactly this frame, and stops at a later frame or the
  0x7fffffff end mark.
- **Sound:** channel 1 takes a sound only when it is free or the new id is lower (higher
  priority).
  - Ids up to 99 need their record.
  - Ids 1..4, 6, 8, 9 and 12 play once; the others loop at the record's loop points.
  - Id 100 plays the record at table +0x1c from offset 0x48c0.
  - Ids above 100 never load a record and play with the caller's A1, which the port takes
    as `a1_in`; this is not exercised by the test.
- **Call logs:** a logging stub now returns the long just before its log, so host
  queries (channel playing) can take both branches.
- `tools/strict_port/gen_sound_effect_log_cases.py` covers 28 states, including every
  play-once / loop id class and the priority rule.

The smoke plume shapes are ported: `plume_pre_render` (the plume record's +0xe hook,
`0x11a70`), `shape_free_plume` and `shape_trailing_plume`.
- **Free plume:**
  - It can face the camera.
  - A pending width lays the vertex x out at -1/2 .. 1/2 of it.
  - Once per frame four vertex heights get rng-scaled jitter, shrunk by age / 45 while the
    object is under 45 frames old. The age test is a word compare, so ages wrap at 65536.
- **Trailing plume:** builds its eight vertices from the owner's 8-point trail ring around
  the newest point. Random picks (rng & 3) roughen its edges.
- `tools/strict_port/gen_plume_cases.py` covers 15 states.

The shadow, turret and bullet pre-render hooks (record +0xe, `0x18a14` / `0x19374` /
`0x15e42`) are ported.
- **Shadow:** an aircraft's shadow stretches its first face along x by |cos(bank)| from its
  template vertices, never narrower than 0x32 << shift. A dead owner returns 4.
- **Turret:** an aimed, idle turret shows its aim heading.
- **Bullet:** a bullet joins the dot list (up to 30, word `0x265d0`), turning its two
  vertices by its matrix in phase 2, and returns 4 (not drawn as a shape).
- `tools/strict_port/gen_pre_render_cases.py` covers 14 states, with the returned D0.

The remaining polygon helpers are ported, completing the family:
- `point_in_polygon_xy` is the xz test with the second coordinate at +6; the shared helper
  now takes both offsets.
- `project_face_vertices_yz` writes words +6 / +10.
- `point_over_face_xz` projects a face relative to the object, shifted by the record's
  position shift (asr when negative, asl otherwise), into a 0x690-byte frame buffer and
  tests (0, 0).
- `tools/strict_port/gen_polygon_cases.py` covers 15 states (edges, a concave polygon,
  slanted edges, word-wrapping origins, both shift signs).

The bullet dot routines are ported: `plot_dot_depth8` / `erase_dots_depth8`,
`plot_dot_depth4` / `erase_dots_depth4` and `plot_dot_bw`.
- **8-bit:** a dot covers 1..4 bytes (2 x 2), saving what it covers in its 14-byte record
  (`0x26288`). Erasing restores only the pixels that still show the dot colour.
- **4-bit:** two pixels share a byte, so a record keeps its phase (the nibble it starts on)
  and plotting and erasing work on nibbles. The phase-0 erase restores both nibbles of a
  row from the same saved byte, as the bytes do.
- **1-bit:** a dot is a 4-point polygon from the corner tables (`0x1b48c` / `0x1b4cc`),
  filled through host +0x7c.
- **Call logs** can now also record a buffer passed by address. The 1-bit fill's polygon is
  logged with its 8 point longs.
- **Replay helper fix:** the helper enters each routine with its arguments and return
  address pushed, as the interpreter does. Before, frame addresses were offset by that
  amount. It never showed until a frame address (the polygon pointer) left the stack; all
  earlier fixtures still match.
- `tools/strict_port/gen_dot_cases.py` covers 19 states. The screen bytes are the binary
  image's own, the same on both sides.

`copy_object_vertex_buffer`, `deactivate_object` and `collect_near_objects` are ported.
- **Deactivation:** a shape frees its vertex buffers, face index lists and face table,
  unlinks its controller, goes through cleanup when its bytes +1 / +2 differ, and drops the
  0x80000 flag. A group marks, unreferences and unlinks its children, then frees its child
  table.
- **Near list:**
  - Objects in range are kept. Visible shapes also get a detail shift, a camera-relative
    view point (unless +4 bit 2) and a place in the visible list.
  - Objects slightly out of range, and shapes seen in the last 0x4b frames, are kept too.
  - The rest retire (when +0x3c is set), are deactivated and move to `entity_array_3`.
- **Real heap in the cases:** `tools/strict_port/gen_object_list_cases.py` builds each
  case's heap by running the original `heap_alloc` in the interpreter. Every long that setup
  changed becomes a starting write, so `heap_free_coalesce` works on an identical heap.
  Allocations are at least 32 bytes, because the small size classes would need the host's
  sbrk. It covers 10 cases.

`collect_far_objects`, `build_visible_object_list` and `transform_int3_vecs_asr_by_1d744`
are ported.
- **Far list:** works like the near list (with no kind test for visibility), and also runs
  the broad phase. Objects with +4 bits 0x2800 are "active": each is tested against the
  earlier kept objects whose spans it overlaps, and every other object is tested against
  the active ones. The scans stop at a stored running minimum (+0x28). Objects kept only
  because they were seen recently skip the overlap list and the collision scans.
- **Unported callees:** the four collision tests are reached through `_bsr_unported`. The
  test logs them (19 calls in the mixed case, all four routines) and compares the pairs
  and their order.
- **Visible list:** turns the view points into camera space (the 0x1d744 matrix), then
  keeps, in two passes (near, then far), the objects that have no view point, that the
  camera is inside, or that lie in front within 1.5 x their screen extent.
- `tools/strict_port/gen_visibility_cases.py` covers 6 cases.

The broad-phase collision tests are ported: `test_proximity_collision`,
`test_player_vs_type0e_proximity`, `create_shape_contact_record`, `handle_player_contact`,
`point_in_face_by_axis` and `test_object_collision`.
- **Proximity tests:** use 3/4 of the distance against the radii. The player variant
  requires the player against a type 0xe object.
- **Contact records:** select the faces whose extent reaches half the shape's metric. A
  record goes into the 256-slot hash table and keeps face indices, side words and one
  axis word per face (the dominant axis of the face normal).
- **`test_object_collision`:** computes, for each recorded face, the side of the face plane
  the moving object is on. On an existing record a side change asks
  `point_in_face_by_axis` (projection on the plane named by the axis word). Inside means
  `dispatch_collision`.
- **Still unported:** `test_terrain_collision` and `handle_terrain_contact` (the terrain
  paths). They go through `_bsr_unported` and are logged.
- **Dispatch through `code_table`:** `collect_far_objects` now reaches the four tests
  through `code_table` (their runtime addresses), so its own test still isolates them.
- `tools/strict_port/gen_collision_cases.py` covers 21 cases. Records that must already
  exist are made by the original creator during setup.

The fractal terrain contact is ported: `create_fractal_contact_record`,
`fractal_height_at` and `handle_terrain_contact`.
- **Record:** the terrain record keeps the shifts, a cell rotation (from the summed part
  angles of the terrain's parent chain), the cell size (0x19c80 scaled) and a cached cell.
- **Height:** `fractal_height_at` turns the point into cell coordinates. Outside the cached
  cell it floors to the new cell and finds its two faces from the face-centre template
  vertices near the cell centre, then picks the triangle (flagging a change). The height
  comes from that face's plane, never below 0.
- **Player contact:** `handle_player_contact` now calls `handle_terrain_contact` directly,
  which stores the height in the player's controller and releases its fractal reference.
- **Terrain collision:** `lift_object_onto_terrain` and `test_terrain_collision` complete
  the chain, so the far list's broad phase is now ported end to end.
  - The lift raises an object that sank below the ground (its y, vertices, range and face
    extents) and hangs it on a support point of the terrain's support list. The support
    point is the face centre of the record's triangle, read from the terrain's live
    vertices, not the template the C named. Without a usable plane it is a cell-corner mix.
  - The terrain test adds a range check, lifts on a triangle change, and collides when the
    object is below the ground.
- `tools/strict_port/gen_terrain_cases.py` covers 22 cases on a small terrain it builds:
  rotated and unrotated, other triangle, negative cell, cached cell, replay, early return,
  no controller, successive height lookups on one record, terrain collisions (lifted, above,
  frozen, out of range, rotated, a second call) and the cell-corner lift. Size class 5 of
  the heap (the support list and points) gets a seeded free list. The collision fixture
  drops its stubbed terrain cases (20 cases now).

Five per-frame simulation steps are ported:
- `clear_pending_entity_slots` cleans up the 7 scatter slots.
- `apply_controller_velocities` keeps the old position and moves flagged objects by their
  controller velocity.
- `tick_flagged_object_controllers` compacts the controller list and runs the definition
  tick of objects with +5 bit 2. When entries were dropped it moves down controllers
  appended by the ticks.
- `dispatch_entity_tick` applies the mission rates and shows or hides type 5 objects by
  host word +0xb0.
- `age_contact_records` frees untouched contact records (releasing a terrain reference)
  and counts the others down.
- `tools/strict_port/gen_sim_step_cases.py` covers 9 cases. The controller ticks log their
  calls. A tick that really appends a controller during the loop is not exercised; the
  long count above its loop word is.

Three camera routines are ported:
- `copy_player_pose_to_camera` puts the camera on the player with negated angles.
- `place_camera_behind_object` puts it 1000 units behind an object, away from a point,
  never lower than 0xfa.
- `turn_camera_toward_point` eases the camera a quarter of the way toward a point, or snaps
  when either angle is more than 0x1000 off.
- `tools/strict_port/gen_camera_cases.py` covers 8 cases.

The radar blip routines behind `update_radar_scope` (*0x1da90 erase / *0x1da94 draw) are
ported:
- **8-bit:** a 12-byte cross restored from the saved panel, or filled with the colour byte
  host +0x1e7. The draw is a second entry (`0x17810`) inside `erase_radar_blip_depth8`, so
  it has no mapping row of its own.
- **4-bit:** two nibble patterns by pixel phase.
- **1-bit:** both draw and erase are a host rectangle call (+0x276).
- `tools/strict_port/gen_radar_blip_cases.py` covers 9 cases on a fake frame and panel.

The bail-out and replay views are ported: `resolve_bailout_outcome`, `update_bailout_view`
and `begin_replay_view`.
- **Bail-out outcome:** it probes the nearest facility. A hard parachute landing ends badly;
  otherwise random rolls (by place: enemy, friendly, open country) set the verdict in host
  +0xd4, and an intact abandoned aircraft gives 4.
- **Bail-out camera:** it follows the parachute, from behind it toward the aircraft or from
  its pose ring.
- **Replay start:** places the camera behind the player's current pose and sets a goal
  beside the previous one, reached in 75 steps. It then resets the replay state and stops
  all sound.
- `tools/strict_port/gen_view_cases.py` covers 25 cases. Fifteen random seeds reach every
  verdict for each kind of place.

`update_tracking_camera`, the replay and end-sequence camera, is ported.
- **What it looks at:** a live player shot, the midpoint with a designated aircraft (held
  for 20 frames), or the player.
- **Where it sits:** when tracking an aircraft it sits behind the player, or behind the
  aircraft when the aircraft heads within 0x1000 of the player and its point 0x4000 ahead
  is nearer. Otherwise it glides toward the replay goal, re-aimed when a follow ends.
- **End of replay:** the frame counter drives replay state 3 and the final result: -1, 1,
  or the bail-out outcome.
- `tools/strict_port/gen_tracking_cases.py` covers 15 cases. The two forward-point cases
  end behind different anchors.

The frame loop is ported: `advance_frame_and_tick_controllers`, `run_simulation_tick` and
`reset_distance_base_globals`.
- **Frame advance:** each frame advances the counter (a replay start steps back 0x4a frames
  and marks the effect log). In a replay it sets each shape's and pool object's visibility
  by its birth and death frames and re-spawns the logged effects. It then runs every live
  controller's tick, compacting the list, records the live count and applies the
  velocities.
- **Simulation tick:** cleans the pending slots, runs the mission-rate tick over the four
  object arrays in mission phases 1..5, and resets the distance references.
- `tools/strict_port/gen_frame_loop_cases.py` covers 8 cases.

The cloud layer is ported: `spawn_cloud_layer` and `spawn_camera_relative_object`.
- **Placement:** ten clouds of random class go on bearings at least 0x280 apart, around the
  camera. High clouds (class 4) sit at 300000+ facing 0x4000; the others sit at about 52000
  facing away from their bearing.
- **No clouds:** without clouds, type 0x1d objects retire.
- **Stub log:** the spawn stubs now append every call to a log (call count, then the
  arguments) instead of keeping only the last one, so all ten placements are compared. The
  four earlier fixtures that use the stubs were regenerated.
- **Emulator:** its step limit now applies per call.
- `tools/strict_port/gen_cloud_cases.py` covers 5 cases (three random seeds).

`update_altitude_detail_bands` (`0x5a14`) is ported: the per-frame detail manager.
- **Altitude band:** a power of two at or below the camera height (log in word `0x1d704`).
  Its table value, interpolated by `(y - band) * v asr log`, becomes the y of the horizon
  objects' vertices.
- **Detail references:** the near reference moves to the camera beyond metric 0xce40, the far
  one beyond 0x80e80 (`m + m asr 3`). A band change across 0xff or a move rebuilds every land
  outline at the band's tolerance (halved under 0x8000, `* 0x16a1 / 4096`, limit 9/10).
- **Far lists:** after a move, hidden unreferenced objects are freed with their controllers
  (destroy hook first), very far ones go to `entity_array_4`, far ones stay in
  `entity_array_3` and near ones are activated; freed controllers leave `controller_list`.
- **Original quirk kept out of the cases:** a negative outline range sum never ends the
  original's shift count, so the tolerance table entries stay small.
- `tools/strict_port/gen_altitude_band_cases.py` covers 13 cases on real heaps (stack guard
  widened to 0x2400 for the outline frame).

`update_ground_scatter_objects` (`0x5e28`) is ported: 64 ground points around the camera feed
7 scatter object slots.
- **Off / high:** off without host word +0xac. Above height 0x26ac the slots are cleaned up
  once (`clear_pending_entity_slots`).
- **Re-placement:** a point beyond 0x4d58 on x or z is re-placed. In views <= 5 it goes on a
  circle around the player heading; after a reset, or in other views, it goes anywhere in the
  square. A slot it named loses +4 bit 2.
- **Projection:** points go to view space in the frame (only the low words of the translated
  longs reach the matrix). Those newly on screen get bit 7 and a visible-list entry.
- **Slots:** each slot keeps its point, hides, or pops visible points until a surface has a
  template. A same-class object with vertices is re-placed in place: scene record, position,
  vertices, metric, band, shade. Others are cleaned up and a new object is spawned.
- `tools/strict_port/gen_ground_scatter_cases.py` covers 9 cases. Its stack guard is widened
  to 0x1000, because `surface_type_at_point`'s frame lies below the default guard.

A batch of twelve small routines is ported, all checked by `test_small_math.gd`:
- **Copy and checks:** `copy_block_return_dst` and `any_mission_kills_recorded` (the twelve
  kill words at host +0xba..+0xd0).
- **Attitude:** `build_attitude_matrix_from_dir_roll` (pitch and heading from a direction,
  roll by angle; its square roots go through `isqrt_floor` and are taken as words) and
  `rotate_int3_vecs_by_3ang`.
- **Tagged invokers:** `invoke_tagged_attitude_compose_neg_sins4` / `_6` negate the sines and
  run the composer named by `attitude_compose_tag`. That composer is the alt (transposed) one,
  so the three alt composers are now in `code_table` under their runtime addresses
  (0x2408 / 0x2468 / 0x26e0).
- **Faces and colours:** `face_is_back_facing` (word products, summed as longs) and
  `recolour_kind2_object`.
- **Display state:** `reset_background_rows`, `reset_overlay_display_state`,
  `clear_flag_00020ae4`.
- **Angle:** `acos_scaled_dot3` (the dot product over `(|a| * |b|) asr 16`, then acos).
- **Original crash kept out of the cases:** a direction whose x² + z² overflows a long makes
  the original divide by zero.
- `tools/strict_port/gen_small_math_cases.py` covers 46 cases. D0 is compared for the routines
  that return a value.

The cockpit instruments are ported: `draw_gauge_needle` and twelve updaters (altimeter,
airspeed, direction, climb, tachometer, manifold, bomb lamp, throttle bar, flaps, gear, ammo,
fuel).
- **Needle:** a needle goes through the host line routine (host +0x272) when host word +0x9e
  is set. Otherwise, once the readouts are drawn, an unchanged end returns 0, and a changed
  one restores the old line (`depth_routine_da98`) before drawing the new one
  (`depth_routine_da9c`). The end is cached per instrument type.
- **Updaters:** each turns a player or camera value into a 14-bit angle and offsets the dial
  centre by `(cos, sin) * length asr 12`. Most skip the redraw when the readouts are drawn and
  the cached value is unchanged. The altimeter's short hand, the bomb lamp (host +0x29e) and
  the throttle rectangles (host +0x28e) use their own host routines.
- **Call logs:** the replay helper's logger now handles 7- and 8-argument code pointers.
- `tools/strict_port/gen_gauge_cases.py` covers 128 cases (drawn / undrawn, value changed /
  unchanged, host line routine, the airspeed piece boundaries).

`update_view_readouts_and_overlays`, `mark_view_overlays_drawn` and `c_strlen` are ported.
- **Readouts (panels not drawn):** each pass of the view_inset count prints one of the four
  numeric readouts (altitude, speed, heading with a degree sign, climb) through the host text
  routine (host +0x27a), when its value differs from the cached magnitude. Inset 4 first resets
  the cache and the index; the reset leaves the loop counter at 4, so five passes run in all.
  View 7 reads the designated aircraft and skips the climb readout.
- **Panels drawn:** the panel copy offset is set, and the sky / ground, heading tape, panel
  frame lines and instruments are redrawn, all as ported.
- **Call logs:** the replay helper's logger now also handles 0-argument code pointers.
- `tools/strict_port/gen_readout_cases.py` covers 18 cases. The text sent to the host is
  compared through the call log, which records its first 12 bytes.

`draw_panel_frame_lines` (`0xba2a`) is ported: the four panel frame lines.
- **Host lines:** with the host line routine, two vertical and two horizontal lines go
  through host +0x272 (nothing at depth 1).
- **Direct drawing:** otherwise they are written into the screen. At depth 4 the colour is the
  byte (c << 4) | c; at depth 8 it is the word (c << 8) | c, with the row bytes halved toward
  zero. Columns step one row at a time; horizontal lines are two rows thick, (right - left) / 2
  pixels long. Other depths draw nothing.
- The readout routine now calls it directly, so its `blocked_by` names only the sky / ground
  and heading tape routines.
- `tools/strict_port/gen_panel_frame_cases.py` covers 11 cases (odd and negative row bytes,
  odd widths, empty lines).

The heading tape is ported: `update_heading_tape`, `begin_offscreen_drawing` and
`end_offscreen_drawing`.
- **Position:** (-heading * period) / 0x4000 toward zero, minus half the window, plus host
  word +0x1a8. A negative position is raised by the period, but the original never reduces
  one from above. An unchanged position (`heading_tape_pos`) skips the copy.
- **Panels not drawn:** the window is first cleared in an offscreen port over the saved panel
  copy (the port record and rects live in the frame).
- **Below depth 8:** the strip window goes through the host copy routine (host +0x29a), split
  in two when it runs past the period.
- **Depth 8:** the window columns are walked against the marking bytes at the old and new
  positions. Runs of marked columns go to `copy_rect_depth8` through its code address,
  wrapping the strip at the period.
- **Dead code kept out:** the depth-4 strip branch (0xc444, `copy_rect_depth4`) is unreachable,
  because it is only entered at depth 8.
- **Call logs:** the logger now reads through a second pointer argument, so copy bits logs
  both its rectangles.
- `tools/strict_port/gen_heading_tape_cases.py` covers 15 cases. The readout routine now
  calls the tape directly, so its `blocked_by` names only the sky / ground routine.

`draw_sky_and_ground` (`0xb4b6`) is ported, so the readout routine's whole drawn-panels path
runs strict code (its `blocked_by` is now empty).
- **Row buffers:** a changed view geometry (host +0x186..+0x199) frees both row buffers and,
  below depth 1, reallocates them at rows * 20 bytes. The cases run this on a real heap.
- **Horizon:** the edge is scaled from view rows to the cached rows. It gives the top and bottom
  band rows, the x at the top (16.16) and the slope. Corner codes 0xf / 0 fill every row with
  ground / sky.
- **Depth 1:** on even frames with the panels drawn, it calls the host routine (+0x27e).
- **Other depths:** each row gets a span record (sky / ground split at the horizon x), the
  span filler blits them, and the buffers swap.
- **Unset inputs kept out of the cases:** a flat horizon leaves the x, the slope and the side
  flag unset, and corners 0xf / 0 leave the lower colour unset. The original hands these to
  the depth-1 host call, so depth 1 is tested only with a sloped horizon and mixed corners.
- `tools/strict_port/gen_sky_ground_cases.py` covers 11 cases. The readout fixture now runs the
  real sky / ground too, with a cached geometry.

The rectangle blitters are ported: `copy_rect_depth8` and `copy_rect_depth4`.
- **Shape:** each copies a block of columns by rows. Leading columns go one at a time until the
  destination is aligned; whole longs (depth 8) or 4-pixel words (depth 4) follow, with the
  source misalignment merged from consecutive source units through a 4-way jump table; then
  the leftover columns.
- **Depth 4:** works on pixel (nibble) addresses with the row strides halved. Single pixels
  are merged nibble by nibble (four parity cases).
- **Quirk kept:** the height loops are dbra words, so a height of 0 would copy 0x10000 rows.
- **Code table:** they are registered under their runtime addresses (0xbf90 / 0xbc88), which
  the heading tape loads as code pointers. Its fixture keeps them as logging stubs, because
  its frame addresses lie outside the test memory.
- `tools/strict_port/gen_copy_rect_cases.py` covers 44 cases: every destination / source
  alignment at both depths, counts ending in the leading part, zero and short counts,
  negative strides, a single row.

`draw_line_depth8` and `restore_line_depth8` are ported: the needle line draw and its undo.
- **Algorithm:** both are a hand-written two-pixel-thick Bresenham with entry points in the
  middle of the loop, ported as one label state machine that follows the original block by
  block. X-major lines are two rows thick, y-major ones two columns wide. Words go on even
  addresses; the odd pixel of a diagonal step is written by byte.
- **Draw / restore:** draw writes the colour byte (doubled for words). Restore copies the same
  bytes from a backup bitmap with its own row bytes, its pointers moving in step with the
  screen ones.
- **Branch flags:** a `bgt` reached by a jump uses the flags of the last add / test of the
  error term, so it is ported as "error > 0".
- `tools/strict_port/gen_line8_cases.py` covers 69 cases: lines in every octant, horizontal,
  vertical, diagonal and single-point ones, odd and even start columns, even and odd row bytes.

`draw_line_depth4` and `restore_line_depth4` are ported the same way, on 4-bit pixels.
- **Nibbles:** a byte holding both pixels of a pair is written whole; a lone pixel merges its
  nibble, low for odd pixels and high for even ones (eor / and / eor in the original).
- **Draw / restore:** draw takes the colour byte, restore the backup byte at the matching
  address.
- **Quirk kept:** one x-major exit writes the high and then the low nibble of the same bytes.
- `tools/strict_port/gen_line4_cases.py` covers 85 cases (the depth-8 lines plus four more with
  odd pixel ends).

The renderer's face emission is ported: `emit_face_chain`, `emit_faces_bsp`,
`emit_faces_in_order` and `emit_faces_unnumbered`.
- **What they build:** the draw-order queue of the prepared object's faces. Each emitted face
  is numbered (face +2 = `draw_order_next`, which then increments) unless unnumbered, and
  appended to the queue.
- **Root walks:** follow each root face's +0x12 chain until a face is nearer than the object
  distance or hidden (+0x13 bit 1).
- **BSP walk:** recurses into the far side first (front subtree +0x10 when the face is
  back-facing, else +0x11), renumbers the node, follows its chain when it was emitted, then the
  near side.
- **Near mode:** back-facing one-sided faces go to the back-face queue; two-sided ones get
  +0x13 bit 4. Outside near mode, a back-facing one-sided face ends a chain.
- `tools/strict_port/gen_face_emit_cases.py` covers 60 cases on seeded random face sets, with
  `face_is_back_facing` run as ported.

The face output stage is ported: `output_face_colour`, `output_face_bw`,
`add_face_edges_to_rows` and `track_ground_plane_horizon`.
- **Clipping:** both outputs clip the screen polygon through the four `clip_polygon_*` passes,
  ping-ponging between the two point buffers. The ground face first goes through
  `track_ground_plane_horizon`, which clips at the alternate bottom row, records the horizon
  edge (the edge not lying along a screen border) and the screen corners it reaches.
- **Colour faces:** the face's palette slot is marked (or assigned). Each non-horizontal edge
  then takes an edge-pool record (16.16 x at the top row, slope) and is inserted into its top
  row's bucket, sorted by x then slope. An equal edge with no second face takes this face
  instead.
- **1-bit faces:** these go to the host polygon routine.
- **Quirk kept:** an edge on the centre column with no slope is dropped, but its pool record
  stays counted.
- **Emulator:** `m68k_emu` now implements the 64-bit-dividend `divs.l` (Dr:Dq) the clippers use,
  so the `clip_polygon_*` passes are now also checked against the original bytes through these
  cases.
- `tools/strict_port/gen_face_output_cases.py` covers 15 cases. The `assign_face_colour` path
  (a face that lost its palette slot) is not exercised.

The object stage of the renderer is ported: `project_prepared_object`,
`transform_face_vertices`, `clip_face_near_plane` and `submit_object_faces`.
- **project_prepared_object:** sets the renderer globals from the prepared object, projects its
  pre-transformed view vertices (behind the near plane = x 0x80000000) and marks every face for
  transform (+0x13 |= 0x60).
- **transform_face_vertices:** brings a face's vertices into camera space once per frame
  (vertex_done), through the object matrix ((sum + 0x800) asr 12), then projects them.
- **clip_face_near_plane:** rebuilds the polygon against z = 5. Crossings are interpolated in
  camera space and projected at z = 5.
- **submit_object_faces:** for each queued face it transforms when needed, copies or near-clips
  its points, runs the near-mode penetration test (`point_in_polygon_xy` →
  `dispatch_collision`) when the face's back / inside flags differ, and outputs it through
  `depth_routine_ab4`. Then it tests the kept back faces and updates the object's drawn /
  clipped flags. The two face outputs are now in `code_table` under 0xa14e / 0xa200.
- `tools/strict_port/gen_object_pipeline_cases.py` covers 17 cases. The output pointer is a
  logging stub, and the polygons stay off the view axis, so `dispatch_collision` is not reached.

`transform_and_project_object` (`0xa75e`) is ported: it brings the prepared object into
camera space.
- **Eye:** the camera position shifted to the object's scale.
- **Controller:** an unlinked one returns 4. The definition's pre-render hook may cancel
  (bit 2), keep the attitude (bit 0) or ask to be called again (bit 1).
- **Oriented objects:** the attitude is built from the controller angles and composed with the
  camera matrix. The inverse goes through the tagged composer, and the eye (and, for lit
  objects, the light vector, restored afterwards) is turned into the object.
- **Band and shade:** the distance band and shading follow the host options.
- **Vertices:** vertex_done is cleared, faces newly marked for transform mark their vertices,
  and every marked vertex is transformed and projected. Unlike `project_prepared_object`, the
  projected y uses a word `neg.w` / `muls.w`.
- `tools/strict_port/gen_transform_object_cases.py` covers 10 cases. The hook is a logging stub
  with a per-case return; the object's kind byte keeps shading a no-op.

`render_visible_objects` (`0xac72`) is ported: the per-frame object draw driver.
- **Pass 1:** pre-transformed objects are projected and their faces run (emit, submit).
- **Pass 2:** the others are transformed. Near mode is decided while the remaining count is below
  `visible_first_pass`; entering it clears the faces' inside bit once. Children with a parent are
  deferred to a frame list. A part-sort request (byte +6 bit 1) runs
  `sort_group_parts_by_distance` and unnumbered faces.
- **Pass 3:** deferred children draw with their parent's draw order.
- **View 1:** `mission_child4` is projected and drawn last.
- **Quirk kept:** a part-sort request whose object is skipped (transform returns 4) carries over
  to the next object.
- `tools/strict_port/gen_render_objects_cases.py` covers 7 cases. Everything except the face
  output runs as ported.

`sort_group_parts_by_distance` (`0x1443a`) is ported, so the render driver is no longer
blocked.
- **Distances:** the camera is temporarily scaled to the object (y = 0). Each part centre (the
  last model vertices) gets its horizontal distance in a frame array.
- **Lit objects:** with host +0xaa, a part whose band changed has its face recoloured toward the
  haze colour. Its palette slot is rewritten when still owned, else dropped.
- **Sorting:** parts are insertion-sorted far to near. With a group list, entries are freed when
  emptied (under `deferred_free_flag`) and sorted by their own distance.
- **Merge:** each group is numbered before the first nearer part and reserves count << 7 draw
  orders; parts take one each.
- `tools/strict_port/gen_sort_parts_cases.py` covers 9 cases on seeded objects: unlit and lit,
  owned and lost slots, groups in every merge position (including the early exit when the groups
  run out), deferred frees on a real heap.

The 8-bit span filler is ported: `init_code_pointer_tables` and `fill_span_rows_8bit`.
- **What it does:** `fill_span_rows_8bit` is the span filler `draw_sky_and_ground` hands its row
  buffers to. For each row it walks the new and previous row records together (a header long
  with the span count, then (end x << 16 | colour) spans) and writes only the stretches whose
  colour changed. The record words are read one long ahead, so both pointers are stored back one
  long early.
- **Run writers:** runs go through two 0x800-entry tables of code addresses inside the filler
  (one per byte parity, swapped after an odd run). `init_code_pointer_tables` fills them with
  the same runtime addresses, and the port dispatches on the address it reads, so a table
  entry's meaning is kept exactly.
- **GDScript pitfall:** lambdas capture variables by value, so a writer lambda that advanced the
  screen cursor silently wrote every run at one address. The writer is now a plain function
  returning its state. The other lambdas in the port only read what they capture.
- **Hash extractor:** `check_sync.extract_function` now also finds definitions whose parameter
  list starts on the line after the name (tried last; existing hashes unchanged).
- `tools/strict_port/gen_span_fill_cases.py` covers 18 cases: the full tables, and seeded rows at
  even, odd and +2 starts with a row skip.

The 4-bit span fillers are ported: `fill_span_rows_4bit_a` / `_b` / `_c` and their table inits
`init_span_table_32ba` / `_3466` / `_3608`.
- **Algorithm:** the same span walk as the 8-bit filler, on 4-bit pixels. A changed stretch from
  an odd pixel first merges the low nibble; whole bytes go through a 9-entry run-writer table
  (runs over 8 pixels as longs of the replicated colour byte first); a trailing odd pixel merges
  the high nibble. Each table is patched into the code segment by its init and dispatched by
  label.
- **Variants:** the three share one core. A takes record handles and, through the sign of d5
  (negated between rows), takes the colour word's high byte on alternate rows. B and C take the
  records directly but still store the end pointers through their first two arguments, as the
  original does.
- `tools/strict_port/gen_span4_cases.py` covers 18 cases (each table, and five seeded fills per
  variant with distinct high and low colour bytes).

`scan_convert_edge_rows` (`0x2e14`) is ported, so the colour renderer runs end to end on strict
code: object pipeline, edges, scan conversion, span fill.
- **Approach:** the routine is a hand-written active-edge scan converter. It is ported block for
  block on the original registers (d0..d7, a0..a5) as a label machine, because its control flow
  carries flags, half-registers and in-place list shifts between blocks.
- **Slow path:** rows with bucket edges or a row flag merge the bucket into the active list
  (dropping edges that end) and toggle each edge's faces. The front face is the inside face with
  the highest draw order, and a change of its colour emits a span. Edges step by their slope
  and are insertion-sorted when they cross.
- **Fast path:** the rows up to the next event run without face tracking: one row at a time
  under 4 rows, else column by column for as many rows as no two edges cross (`divu.l` of the
  gap by the slope difference).
- **Background:** the sentinel edge toggles the background face kept in the image (0x1b184,
  order 0x7fff, colour 0x1b188).
- **Emulator:** `m68k_emu` now implements `divu.l` (it only had the word form).
- `tools/strict_port/gen_scan_convert_cases.py` covers 9 scenes built by the original
  `add_face_edges_to_rows`: single and overlapping faces in both draw orders, crossing edges,
  long coherent runs, half-rows mode, and an empty scene.

**False-split entries (bookkeeping, not new ports).** Thirteen inventory entries are
mid-function fragments recorded at runtime code-pointer addresses (see "False entries and
runtime-address callees" in `DECOMPILATION_SYMBOLS.md`), for example `FUN_00001d56`, the tail
of `matmul3x3_s16` at file 0x1d56 and runtime `sin_fixed14`. Their bytes only ever run inside
their enclosing function. Each now has a mapping row whose target is that enclosing strict-port
function and whose test is that function's test: the heap tails (`heap_add_large_block`,
`heap_free_coalesce`, `heap_zero_payload`, `heap_realloc_grow_only`), `matmul3x3_s16`,
`sin_fixed14`, `transform_listed_object_vecs12_by_1d744`,
`apply_template_chain_xform_always`, `update_object_camera_metric`,
`compute_camera_abs_metric`, `reset_object_to_template_pose`,
`compute_template_force_from_626` and `overlay_rng_init`. `process_flight_input_tail` stays
open until its enclosing key handler is ported.

The colour set-ups are ported: `overlay_patch_template_u16_pair` (two template words in the code
segment), `reset_palette_owner_tables` (free / reallocate the three owner tables),
`init_depth8_colour_state` and `init_depth4_colour_state`.
- **Depth 4:** builds, per screen, 125 colour entries from an 8-word source table indexed by
  the 0 / 1 / 2 / 3 thresholds of r, g, b.
- `tools/strict_port/gen_colour_setup_cases.py` covers 8 cases on a real heap.

The handle and session-buffer routines are ported: `ensure_handle_allocated`,
`lock_handle_nopurge`, `unlock_handle_purgeable`, `lock_overlay_buffers`,
`allocate_session_buffers`, `lock_session_buffers` and `unlock_session_buffers`.
- **What they do:** they drive the host Memory Manager hooks (new / reallocate / lock / unlock /
  purgeable / no-purge / free memory at host +0x2c6..+0x2e2). Buffer sizes depend on free
  memory (800 or 550 edge entries, 30 or 20 rows). The second and third screens only get
  buffers with the multi-screen flag. Locked master pointers are masked to 24 bits under 24-bit
  addressing. Locking ends with `update_view_clip_bounds`.
- `tools/strict_port/gen_session_buffer_cases.py` covers 15 cases with every host hook logged.

Five more routines are ported: `find_anchor_point` with its scene visitor `anchor_point_visitor`
(registered at runtime 0xc2c), `present_spans_to_window`, `present_bw_frame` and
`load_player_fuel_and_bombs`.
- **Anchor search:** mode 1 picks the nearest runway face (type 0x70) that is not above ground
  and anchors at its x / z at height 0x43. Mode 0 picks the shallowest kind-1 node, its position
  and its parent record's attitude.
- **Presenters:** they draw through a 0x2000-byte heap bounce buffer in chunks of whole rows
  (kept even at depth 4). The span presenter hands the filler the addresses of its own
  argument slots, which the filler advances, so the port writes its two record pointers into
  the caller's argument slots.
- **Fuel and bombs:** both tanks are filled to capacity * fuel percent / 200, at least 1 in the
  first; the bomb load and ammunition are set too.
- `tools/strict_port/gen_anchor_present_cases.py` covers 13 cases (a small mission scene, a real
  heap for the presenters, four fuel set-ups).

Three more routines are ported: `refresh_object_colours_for_depth`, `begin_flight_for_rank` and
`apply_player_mouse_controls`.
- **refresh_object_colours_for_depth:** clears the palette usage (and the owner table at depth
  8), rebuilds the 4-bit state at depth 4, then recolours the mission children, entity_array_1
  and the object pool. At depth 1 land objects and type-3 / 4 pool objects get face patterns
  instead.
- **begin_flight_for_rank:** sets the rank's AI aim lag and, unless the host overrides it, the
  player handler; it refreshes the objects at depth 1 and clears the flight words.
- **apply_player_mouse_controls:** steers the player from the mouse (3 / 2 of the x offset as
  aileron, 3 times the y offset as elevator, plus the rudder key), or toward the designated
  aircraft in auto mode.
- **Fixture notes:** `recolour_kind2_object` always reshades, so the recoloured shapes have no
  faces (shading has its own tests). The depth-1 pattern targets are non-shape objects with
  faces.
- `tools/strict_port/gen_flight_start_cases.py` covers 11 cases.

`widen_printf_format`, `overlay_printf` and `start_mission_scene` are ported.
- **printf:** the format is copied into the static buffer 0x20b4c with "%d" / "%x" widened to
  "%ld" / "%lx", then handed with five arguments to the host printf (+0x262).
- **start_mission_scene:** releases the previous scene object, takes the new one from the
  scene-root record, puts the camera at the mode-0 anchor and resets the view and distance
  state. It then activates the scene object, advances the frame counter by 0x4b, refills the
  player's pose ring, copies the pose to the camera, lays the cloud layer and stops all sound
  channels.
- `tools/strict_port/gen_mission_start_cases.py` covers 6 cases; every mission-start callee runs
  as ported.

The overlay entry and respawn are ported: `overlay_main_entry`, `overlay_initialise`, the two rts
stubs (`noop_stub_2e12`, `overlay_init_noop`) and `respawn_player_at_anchor`.
- **Start-up:** `overlay_main_entry` stores the host globals pointer, runs `overlay_initialise`
  (RNG seed, palette usage maps, all span-filler tables, light vector, frame counter, view
  distance), sets host word +0x92 and installs the 22 overlay hooks (runtime addresses) in host
  +0x2e6..+0x33a.
- **Respawn:** `respawn_player_at_anchor` puts the player at the runway anchor (or the stored
  one), refills its pose ring, resets the flight state and input words, cleans up a pending
  replay object and drops its contact records.
- `tools/strict_port/gen_overlay_entry_cases.py` covers 7 cases. The start-up cases begin from
  the original initialisers' tables, so only the other start-up state shows as changes.

`overlay_init_template_pointer_tables` and `init_mission_object_tables` are ported.
- **Template tables:** heap copies of the built-in definition templates go into the template
  pointer table: four 0x4a-byte and five 0x1c-byte records at the slot their first word names,
  plus fixed 0x1a / 0x20-byte records. Their order and stack depths are kept as data
  (`TEMPLATE_STEPS_A` / `_B`).
- **Mission scene:** instantiates the scene root from the host descriptors, copies and relocates
  its 24-byte child records, instantiates every child and publishes / activates the mission
  children and the child window.
- `tools/strict_port/gen_mission_tables_cases.py` covers 3 cases on a real heap whose small size
  classes are pre-seeded (no host sbrk), with a group-only mission scene.

`draw_distant_object_dots` (`0x162ba`) is ported: objects too far to render are plotted as dots.
- **Colour:** each queued object's first face fixes the dot colour (palette tally or
  `assign_face_colour`, whose failure ends the routine).
- **Projection:** a single point (the object position) or, for trails, the first two of three
  vertices are taken through the camera matrix and projected.
- **Size:** each on-screen point gets a dot of size 4..1 by its depth against 5000 shifted to the
  object's scale.
- **Output:** dots are plotted through `depth_routine_da80` after `depth_routine_da84` erased the
  previous ones; the dot count is stored and the queue emptied.
- **Quirk kept:** a trail transforms three vertices but plots only the first two.
- `tools/strict_port/gen_distant_dots_cases.py` covers 6 cases with the erase / plot routines
  logged.

`configure_renderer_for_display` (`0x6ff6`) is ported: the host's display hook.
- **Geometry:** sets the view geometry (rows, width, origin, half sizes, the centre column and
  the projection scales).
- **Depth / screen change:** when the depth or the multi-screen flag changed, it rebuilds the
  colour state and installs that depth's renderer hooks (span fillers, line draw / restore,
  dot and blip routines, face output: the runtime addresses of the strict-port routines, kept
  as data in `RENDERER_HOOKS_8` / `_4` / `_1`). It builds the mission if needed, and patches the
  template words and mission_child4's faces for the 1-bit display.
- **Clip bounds:** finally sets the clip bounds and refreshes the view.
- `tools/strict_port/gen_renderer_config_cases.py` covers 7 cases (each depth switch, a
  multi-screen change, an unchanged configuration, odd and negative sizes).

`player_slew_mode` (FUN_0000f810) is the player controller's free-flight mode: yaw / pitch
turn by half the input words, the slew keys steer a speed along one of three axes (a new axis
starts at -/+1000, the same axis adds max(|speed| / 2, 1000), key 5 stops), the speed is rotated
by the attitude matrix into the velocity (asr 6), the object is kept above ground, the gun fires a
burst every third frame through `spawn_ordnance_oriented` and the gear steps down. The original
quirk that sets a speed under 1000 in magnitude to 1000 with the opposite sign is kept.

- `tools/strict_port/gen_slew_mode_cases.py` covers 41 cases (every key and axis transition,
  key 5, the sign quirk, the ground clamp, the gun cycle and the gear limits) with
  `spawn_ordnance_oriented` recording its arguments.

`update_game_sounds` (FUN_000096f4) is the per-frame sound update: views 8 / 9 only play the
pending explosions, other unsupported views stop every channel, and the views that follow an
aircraft (the player, or designated_entity_2 in view 7) derive the gear / flaps moving flags,
play or stop the gun, flaps / gear, ditch and grass loops, play the one-shot sounds by channel-1
priority, and drive the engine on channel 0 (stalled record 0 at rpm + 0x10000, record 10 above
10000 rpm at rpm * 4 / 3 + 0x4000, restarted only when the choice changes or the channel idles).
The one-frame flags then clear and the explosion timers count down.

- `tools/strict_port/gen_game_sound_cases.py` covers 30 cases (sound off, each view group,
  gear / flaps limits, channel-1 priority, every engine branch including a missing record and an
  rpm whose shift overflows) with the five host sound routines logged.

`overlay_frame_step` (FUN_00006598) is one whole overlay frame: slot usage maps, distance
reset, altitude bands, the inverse and forward camera matrices (six-angle in view mode 2), the
mission children queued and transformed, camera metrics, the far-object insertion sort (biased by
carried pairs for that sort only), object collection, overlaps, contacts, culling, rendering, scan
conversion and presentation (span filler, `present_spans_to_window`, `present_bw_frame` or the
depth-1 host routines), the view-mode-1 panel layout (with the session buffers re-created on step
0) and the readouts / gauges. Index stores use scale 4 (decoded from the extension words). The
emulator gained `roxl` / `roxr` for the altitude-band rebuild this frame reaches, and
`clear_flag_00020ae4` is registered as a code address so a host routine can clear the panels.

- `tools/strict_port/gen_frame_step_cases.py` covers 28 whole frames (each depth and presenter,
  cursor hooks, view mode 2, haze, retirements, near / far objects with and without carried
  pairs, readouts, drawn panels, and the panel layout with cached and re-laid geometry, session
  buffers, a pending-panels host and 24-bit pointers), every host routine logged. The original
  hands the depth-1 sky routine uninitialised frame words on a flat horizon and on the second pass
  after a layout; those cases use a sloped horizon and an odd frame.

`process_flight_input_and_outcome` (FUN_0000740a) is the player's per-frame input and
outcome step: replay / crash-end / instant-replay control, the view exits, the key filter and
the 0x76-entry key table at 0x7688 (decoded from the words), the throttle ramp, the
keyboard-steered mouse point and gun trigger, the per-frame calls, the stopped-aircraft
classifier (ditching, touchdown, runway, fuel recording, the random POW / MIA draws) and the
camera for each view, then the pitch mirror and result tail. The bytes differ from Ghidra's C in
two places the port follows: the view-6 shift loop tests only bit 15 of the low word, and view 5
stores its negated angles directly. Ghidra's `process_flight_input_tail` (`0x823e`) is a false
split inside the classifier and maps to the same target.

- `tools/strict_port/gen_flight_input_cases.py` covers 142 frames (every key of the table in
  the modes that change it, the throttle ramp, keyboard steering and its clamps, the gun, the
  replay transitions, every classifier outcome including four RNG states, and the camera for
  views 1, 2, 5, 6, 7 and 9), comparing memory, the host sound calls and the returned result.

With that, every Pacific Conflict function is ported and verified against the original bytes.
The CODE segments come next, starting with ID01's 32-bit divide runtime in
`godot/strict_port/code/ID01.gd` (it replaces the earlier untested pseudo-GDScript draft). The
stack entries `rt_udiv32` / `rt_umod32` / `rt_sdiv32` / `rt_smod32` pop their own arguments and
preserve D1; the register cores `rt_sdivmod32_core` / `rt_udivmod32_core` return [D0, D1]. The
port keeps the core's word-sized estimate, its `SUBQ.W` corrections and the multiply-back that
adds both halves of the swapped high product. `m68k_emu.Emulator` takes `file_delta=0` to load an
`IDnn.bin` segment at address = file offset.

- `tools/strict_port/gen_id01_divide_cases.py` runs 5,658 calls (every path of the unsigned core,
  every sign combination, 0x80000000, edge and random operands; D1 preservation asserted on the
  original); `test_id01_divide.gd` compares D0 (and D1 for the cores).

ID02's C runtime follows in `godot/strict_port/code/ID02.gd` (`abs_long` .. `ansi_strncat`, the
31 exported routines; the unexported memcmp / memchr / strlen / strncmp bodies between them are
not counted). The port holds `memory` and `a5`: the ctype table is at A5 - 0x1608 and strtok's
saved position at A5 - 0x1508. MPW C passes int as a 16-bit word, so the character and memset
value arguments are the pushed words. `ansi_div` keeps the DIVS.W overflow (-0x8000 / -1 leaves
the register unchanged: quot = the numerator, rem = -1), and `ansi_ldiv` calls ID01 through
JT $5a / $62. `helpers/segment_cases.gd` replays segment fixtures on fresh memory with the
fixture's A5.

- `tools/strict_port/gen_id02_crt_cases.py` covers 1,261 calls: every character class on a seeded
  table (and words with a high byte), the overflowing div, ldiv through the real ID01 bytes (JMPs in
  the jump-table slots), overlapping memmoves, and the string routines on matches, misses,
  empty strings / sets, terminators and every strtok state.

Next, the 17 ID02 routines that make no Toolbox calls: `set_back_color_index`,
`design_x_to_screen` / `design_y_to_screen`, `format_int_decimal_pstring` (DIVSL.L #10, with
0x80000000 kept negative), `copy_pascal_string` (signed length byte), the sound channel engine
(`clear_sound_buffer_to_silence`, `alloc_sound_buffer_node`, `select_two_channel_sound_handler`,
`play_sample_on_channel`, `enqueue_sample_on_channel`, `set_sound_playback_rate`,
`release_channel_loop`, `silence_sound_channel`, `is_channel_playing`), and the palette helpers
(`clear_ctab_size_callback`, `lookup_palette_index_for_rgb_level`,
`init_standard_colour_indices`). The interrupt-level sound routines reload A5 from CurrentA5
(0x904), and the port reads it from there too. The palette lookup returns the index at depths 1
and 4 and the index + 0xc8 at depth 8; at any other depth it returns whatever D0 last held, and
the port tracks that. The three VBL handlers (self-modifying, `movep`) are left for later.
`m68k_emu` gained the long `mulu.l` form (it used to run every `mulu` as the word form; nothing
in Pacific Conflict uses `mulu.l`, and the earlier fixtures regenerate unchanged).

- `tools/strict_port/gen_id02_trapfree_cases.py` loads ID02 at 0x30000 so low memory is free for
  SoundBase / the sound hook / CurrentA5, and covers 99 calls: both channels and bad ones, the
  sound system off, looping and one-shot samples, a playing loop released and silenced, rate
  clamps, every depth of the palette lookup (including an empty extra table), and the
  coordinate, colour and string edge values.

Calls that leave a segment now have stand-ins on both sides. `m68k_emu.Emulator.traps` handles
A-line trap words (the trap is consumed and A7 points at its arguments), and
`tools/strict_port/segment_stubs.py` logs jump-table slots and traps. Each log entry gives the
argument sizes in stack order, Pascal (callee pops, result written in the caller's slot) or C (D0),
the result size, and the arguments whose buffers are logged by value. The segment ports call
`_jt(offset, args)` / `_trap(word, args)`, and `helpers/segment_cases.gd` installs the same loggers
from the fixture. The first 12 such ID02 routines are ported this way:
- `close_and_dispose_port`, `close_port_a5safe` and `swap_port_a5safe` (ClosePort, DisposPtr,
  SetPort);
- `swap_mmu_mode_a5safe` and the five handle wrappers `dispose_handle_a5safe`, `hlock_a5safe`,
  `hunlock_a5safe`, `hpurge_a5safe` and `hnopurge_a5safe`, through the ID09 glue slots;
- `get_blended_fill_pattern` and `set_draw_color_index`, through the C RGB-to-pattern slot $1ca
  and PenPat;
- `new_offscreen_cport`: NewPtr, OpenCPort, SetPort, the pixmap fields and RectRgn of the bounds.

- `tools/strict_port/gen_id02_glue_cases.py` covers 39 calls (null and real handles / ports,
  both depths, fixed and extra colour entries and a negative index, two offscreen ports), with
  every stand-in's log compared byte for byte.

17 more leaf routines that call the Toolbox follow the same pattern:
- the thick and XOR lines;
- `apply_pending_color_entries_a5safe` (SetEntries);
- `blit_pixels_via_port_a5safe` (CopyBits) and `open_offscreen_cport_a5safe`;
- `paint_rect_color_index_a5safe` (it reuses `set_draw_color_index` with A5 from CurrentA5);
- `run_segment3_entry_and_unload_a5safe`;
- the sound slots `release_sound_slots` (RecoverHandle, HPurge, HUnlock) and `lock_sound_slots`;
- `handle_activate_event` (the EventRecord passed by value);
- `set_menu_item_enabled`;
- `shutdown_sound` (SndDisposeChannel);
- the window / alert placement routines `position_window_on_screen`, `position_alert_template`
  (GetResource 'ALRT', SetRect) and `centre_window_on_screen`, with their DIVS.W halves / thirds
  and MBarHeight;
- `detach_window_palette` and `select_palette_for_depth` (SetPalette).

Bytes pushed with MOVE.B -(A7) (the MoveWindow and SndDisposeChannel flags) take a stack word
whose high byte alone is defined, so the stand-ins log them with size 1.

- `tools/strict_port/gen_id02_toolbox_cases.py` covers 40 calls (every branch of each routine,
  odd screen and window sizes, missing windows and handles) with every trap and slot logged.

The next eight: `blit_offscreen_frame_to_window` (it makes its offscreen port with
`new_offscreen_cport` the first time), `build_notched_frame_poly` (it rewrites its own argument
words), `draw_view_frame_outline` (design coordinates), `freemem_a5safe`,
`show_caution_alert_with_number`, `show_sound_error_dialog_once` (it waits for a click),
`show_creating_panel_dialog` and `install_menus`. The stand-ins gained scripted results (Button
goes up, down, down, up so the waits end) and Pascal-string arguments logged by content (the
caution alert's number string is built in its frame; the port computes it without writing
memory). Two corrections came out of this batch:
- `m68k_emu` now sign-extends absolute short addresses: `PEA $FFFF.W` is -1, the "in front"
  window. Only data words in Pacific Conflict have such operands, and every ID fixture
  regenerates and passes.
- `format_int_decimal_pstring` keeps the original's forward byte copy: a string longer than 10
  bytes overlaps its destination and repeats its first bytes.

- `tools/strict_port/gen_id02_dialog_cases.py` covers 23 calls (first and later blits in every
  mode and at depth 4, three polygons, both outlines, the alert with and without a number, a
  nil message and -32768, both dialog states, the menu bar).

Then the sound loading, palette and display routines:
- `load_named_sound_into_slot`: GetNamedResource, the FreeMem / MaxMem check, the purgeable
  resource attribute.
- `configure_palette_entries`: the SetEntryUsage / SetEntryColor loops of depths 4 and 8.
- `build_palette_index_map`: the index map and its reverse; a colour hit twice selects the
  alternate service.
- `rebuild_all_palette_index_maps`: it hands `build_palette_index_map` buffers in its own frame,
  so segment ports now model A7, and `helpers/segment_cases.gd` passes the fixture's stack top.
- `scan_display_devices`: the original picks a neighbour record for a matching side screen but
  fills a record only for the main device, and the port keeps that.

`build_palette_index_map`'s count is a frame word that is set only at palette depths 4 and 8, so
the port asserts those depths. It returns the count with MOVE.W, so only the low word of D0 is
compared.

- `tools/strict_port/gen_id02_palette_cases.py` covers 19 calls (every memory outcome of the sound
  load, both palette depths, maps with duplicate colours, rebuilds at each depth and with the
  offscreen port, device walks with neighbours, an existing map, the deep-screen test and
  mismatched devices). Its logs are 0x1000 bytes (the depth-8 palette makes 234 calls per trap),
  above the code in a 0x60000 memory.

Then five drawing and colour-state routines:
- `paint_polygon_rgb_a5safe`: points as longs, -y; FillPoly with the RGB pattern at depth 1, else
  RGBForeColor + PaintPoly. RGBForeColor's record is logged by content, together with the loop
  counter word that follows it in the frame.
- `draw_notched_frame_pair_a5safe`: two passes over the polygons from `build_notched_frame_poly`; the
  second pass uses the colour argument copied over the first.
- `blit_image_clipped_to_region` and `blit_image_clipped_to_region_a5safe`: the clip is the view
  frame region, and the image is locked only when HGetState says it was not.
- `check_device_color_state_changed`: maps rebuilt in its frame, compared, reported and stored.
  It calls a service through the pointer at A5 - 0x1096, so the stand-ins gained an "addr" kind
  (a code address reached indirectly) and the ports a `code_routines` table.

- `tools/strict_port/gen_id02_draw_cases.py` covers 20 calls (polygons of 4 / 1 / 0 / -2 points
  at both depths, painted and filled frames, the image blit with the handle locked or not, colour
  states changed on one or both devices, unchanged, without the service, at palette depth 4 and
  at depth 1).

Then the memory, sound-set and horizon routines:
- `fatal_memory_error_exit`: frees the frame buffer, shuts sound down, shows the caution alert,
  then ExitToShell. The stand-in returns into the RTS that follows the trap.
- `new_handle_clear_or_die_a5safe` and `realloc_and_clear_handle_a5safe`: on a MemError they
  call the exit; otherwise the resize clears the block with the ported `ansi_memset`.
- `load_game_sounds`: the engine sound depends on FreeMem, and slot 8 has a fallback name whose
  miss still counts as a failure.
- `paint_view_horizon_bands_a5safe`: nine long arguments of which it uses the low words (the
  third is never read); the frame rects are logged by value.

- `tools/strict_port/gen_id02_memory_cases.py` covers 15 calls (both exit paths, the handle
  calls succeeding and failing, the sound set with plenty / little / middle memory and a scripted
  missing sound, and the bands for a <= b, a > b and a = b at both depths).

`draw_text_in_columns_a5safe` lays out the status line: four labels, the column starts measured
with GetPen and the column widths in digit widths, or it draws one column's text. It reads back
the pen point that GetPen writes into its frame, so the stand-ins gained `["out", value]`, which
writes a long through a VAR pointer argument instead of logging it. `update_menu_items` enables
and checks the File / Edit / Options / View items from the game-state words, the front window's
kind (a desk accessory enables Edit and redraws the bar once) and the settings record, through
the ported `set_menu_item_enabled` and CheckItem.

- `tools/strict_port/gen_id02_menu_cases.py` covers 15 calls (both layouts, three columns, and ten
  menu states: idle, playing, paused, state 2 / 3, busy, depth 4, a desk accessory in front
  (new and unchanged), no front window, not playing).

ID05 starts in `godot/strict_port/code/ID05.gd` with its 17 trap-free routines:
- `ansi_rand` / `ansi_srand` (LCG 0x41c64e6d / 0x3039 at A5 - 0x6c; the result is
  BFEXTU {1:15});
- the six-letter base-26 codes (DIVSL.L #26 signed, decoded with MULU.L);
- overlay poisoning and restore (twelve random bytes set to 0xff and recorded);
- the challenge table (init, a random pick by DIVU.W remainder, the index check);
- the response check: key-shifted letters compared as bytes from the last, strlen through
  JT $522, the low word of the match count returned;
- the 28-bit code packing and unpacking with its DIVS.W fields.

`m68k_emu` gained BFEXTU with an immediate offset and width (register or memory field).

- `tools/strict_port/gen_id05_protection_cases.py` loads ID05 at 0x30000 and covers 61 calls:
  seeds including 0 and 0x80000000, edge and negative codes, letters outside A..Z, poisoning with
  three sizes and a null base, every restore condition, four valid responses and three
  rejections, and packing with negative and capped fields.

ID06's software rasteriser follows in `godot/strict_port/code/ID06.gd`: 22 of its 24 routines.
- Patterns and colours: the pattern and colour-map tables, the grey pattern of an RGB colour,
  the colour map lookups.
- Memory: the long-aligned blocks (NewPtr + 12, the size and allocation kept below them).
- The raster target, the row table and its fields, and the edge pool with its sentinel edges;
  the row count, band rebasing, and the edge-table reset.
- `add_polygon_edges`: the clipper. Edges are taken top to bottom, clipped to row 0 with a 64-bit
  MULS.L / DIVS.L and cut at the left and right borders into vertical pieces. On a DIVS.L overflow
  the registers are left as they were, so the port keeps the low long of the product.
- `add_rect_polygon`: it builds its four points in its own frame (the port models A7).
- `set_active_row_count`: it reads the row count through the row-table pointer even when that
  pointer is null (the original does too).

`render_scanline_spans` keeps register state in its own code bytes and `rasterize_and_present`
calls it through a code pointer; both are left for later.

- `tools/strict_port/gen_id06_raster_cases.py` covers 61 calls. Most start from a scene the
  ORIGINAL built (init_raster_target, plus polygons), captured as writes. NewPtr is scripted, and
  a preset call count makes it fail. The polygons cover inside, crossing both sides, crossing
  top and bottom, wholly left / right, flat edges, a corner-to-corner sliver and a full pool.

The small segments start in `ID07.gd`, `ID08.gd` and `ID09.gd`:
- ID07 rewrites STR# 129 in place into 120 strings: "\r" / "\t" escapes resolved (ID01's dense
  switch helper, JT $3a, on the next character; any other backslash kept), "\p" strings kept
  Pascal and the others made C. It then copies four groups of its pointers. Its moves go through
  ID02's memmove, so the port calls the ported `ansi_memmove`.
- ID08's beep-and-exit, and the payload read: GetFPos / GetEOF write into its frame, then NewPtr
  and FSRead.
- ID09's SwapMMUMode glue (an OS trap on D0) and its Pascal-to-C conversion.

The stand-ins gained "trap_d0" for OS traps that take and return D0.

- `tools/strict_port/gen_id07_09_cases.py` writes one fixture per segment (15 calls). ID07 runs
  the real ID01 switch helper and ID02 memmove behind JMPs in their jump-table slots over three
  prepared STR# layouts; the others cover a failing NewPtr, both MMU modes and strings of 0, 1,
  12 and 254 bytes.

ID04 starts in `godot/strict_port/code/ID04.gd` with 20 routines:
- the dialog-item helpers (hilite, hide / show, text, title, user-item procedure, framed box);
- the user-item procedures (default-button outline, grey item, percent bar), which are Pascal:
  the callee pops its arguments;
- the radio-group search and the temporary window;
- the scenery-error, save, end-mission and erase-scores alerts;
- the kill-report state and the weighted pilot score.

Most start with GetDItem, which writes the item's type, handle and box into the caller's frame,
so the "out" stand-ins now take a size or a list of longs (`["out", value, size]`,
`["out", [long, ...]]`).

- `tools/strict_port/gen_id04_dialog_cases.py` covers 40 calls (every helper, percent bars at 0 /
  37 / 100 / -10 / 250 %, three radio groups with GetCtlValue scripted 0, 0, 1, the temporary
  window made and reused, the alerts, six mission states for the end-mission check and the kill
  report, four pilots' scores).
- `ID04.gd` batch 2 adds 18 routines: `rank_pilots_by_score`, `reset_pilot_record`,
  `prune_inactive_pilots_beyond_ten`, the scrolling text item (`create_` / `draw_` /
  `dispose_scrolling_text_item`, its user item procedure, `sync_text_scroll_to_control`,
  `update_scroll_bar_maximum`, `scroll_text_to_show_selection`, `fit_text_view_to_box`,
  `scroll_bar_action_proc`, `append_line_to_scrolling_text`), `play_named_sound_async`,
  `stop_named_sound`, `poll_click_or_key_event`, `check_system_requirements` and
  `draw_select_mission_title`. `tools/strict_port/gen_id04_scroll_cases.py` runs the original
  bytes with ID01's dense switch helper for real (scroll bar parts, event kinds) and every trap
  logged; a case may carry its own call logs, so GetNextEvent's event and SysEnvirons' record vary
  per case. `test_id04_scroll.gd` replays 54 cases (two rankings with ties and name ordering,
  three prunes, TextEdit scroll states, all four scroll parts, nine event kinds, five machines).
  `scroll_bar_action_proc` asserts on parts outside 20..23, where the original reads an unset
  frame word.
- `ID04.gd` batch 3 adds 11 routines: the ModalDialog filters (`duty_roster_filter_proc`,
  `scenario_selection_filter_proc`, `refuel_dialog_filter_proc`, `map_dialog_filter_proc`) and
  `fuel_slider_dialog_filter`, `update_summary_dialog_buttons`, `build_rank_and_name_string`,
  `set_score_item_text`, `conclude_mission`, `draw_map_grid_and_centre_mark` and
  `plot_map_symbol_callback`. `tools/strict_port/gen_id04_filter_cases.py` runs ID01's sparse
  word / long switch helpers (slots $2a / $32) for real; their tables end by comparing the next
  instruction word, so the last offset is the default. The two segment routines not ported yet
  (track_map_bearing_and_distance 0x3614, show_mission_summary_dialog 0x2de6) are stand-ins the
  port reaches through `_local(offset)`. Each case records the original's entry stack pointer
  (`a7`), so frame buffers passed to the jump-table string calls log the same addresses.
  `test_id04_filter.gd` replays 68 cases (seven event kinds per filter, seven slider drags, ten
  summary button states, fourteen mission endings, four grids, three plots).
- `ID04.gd` batch 4 adds 7 drawing routines: `draw_high_scores_table`,
  `draw_targets_destroyed_row`, `draw_targets_destroyed_list`, `draw_aircraft_kill_markers` and
  `draw_map_view_item` with the user item procedures of the markers and the map.
  `tools/strict_port/gen_id04_draw_cases.py` extends the filter batch's set-up; the map's plotting
  service (*(A5 - 0x1052)) is reached through `_call_address`. Frame buffers and rects are logged
  where the original passes them (the colour record's second long reaches the saved-port local, so
  the port keeps it in its frame). `test_id04_draw.gd` replays 24 cases (three rankings, every
  target row and the list, four kill counts, day / night / scaled maps).
- `ID04.gd` batch 5 adds `show_paused_dialog` and `show_about_dialog`.
  `tools/strict_port/gen_id04_about_cases.py` scripts the sessions: the stubs gained an "outseq"
  VAR result (GetNextEvent's event kind changes call by call; both `segment_stubs.py` and
  `helpers/segment_cases.gd`), and TickCount, Button and GetResource answer sequences (the ticks
  advance every scroll step; the original polls forever when they stop and the button never goes
  down). `test_id04_about.gd` replays 9 cases (key down and up among stray events; the About box
  scrolled until the button, scrolled out at night, cut short by a key or a click, another version,
  no picture, no dialog). The version string keeps the original's "M.0.F" (the minor digit masked
  0xf0 and shifted by 8).
- `ID04.gd` batch 6 adds `show_mission_summary_dialog`, completing ID04 (59 routines).
  `tools/strict_port/gen_id04_summary_cases.py` runs it with the dialog helpers already ported
  running on both sides and the two unexported ones (the default-ring installer 0x1b8,
  advance_mission_summary_text 0x21d6) as offset-keyed stand-ins; ModalDialog's item hits are an
  "outseq" list. The routine stores its frame's tally buffer in A5 - 0x2226, so the case's entry
  stack pointer matters beyond the guard. `test_id04_summary.gd` replays 10 cases (a pilot's
  summary, the mission's in phases 0, 1 and 3, an early death, a running mission confirmed or with
  nothing to report, game state 2 skipped).
- `ID05.gd` gains its last 9 routines, completing ID05 (26): `center_template_rect_on_screen`,
  `get_machine_screen_fingerprint`, the 'DATA' / 'TEXT' 128 pair readers and writers,
  `code_dialog_filter`, `get_dialog_item_text_upper` and `run_protection_dialog`.
  `tools/strict_port/gen_id05_dialog_cases.py` reuses the protection batch's challenge table;
  GetIText writes C strings from an "outseq" list and the passing response is the one for the
  record ansi_rand picks from the seed, so the dialog loop ends. The code-string builder (0x3ba,
  not exported) is an offset-keyed stand-in. `test_id05_dialog.gd` replays 27 cases (templates
  centred or missing, colour and black-and-white machines, present and missing pairs, seven filter
  events, two item texts, five protection sessions: already matching, right first time and stored,
  wrong then right, quit pressed, no dialog).
- `ID09.gd` gains `sysenvirons_glue_fallback` and `fsopen_glue` (ID09 complete) and `ID08.gd`
  gains `bootstrap_window_and_load_overlay`. `tools/strict_port/gen_id08_09_glue_cases.py` sets low
  memory per case; the stubs gained a "trap_a0" kind for parameter-block OS traps (D0 and the
  block logged, VAR fields written into the block, the flags set from the result as the trap
  dispatcher leaves them; `segment_stubs.a0_trap` and `helpers/segment_cases.gd`). Both glues
  build their blocks on the stack, so cases record the entry stack pointer; the logged block stops
  short of the return address. ID08's load_overlay_from_resource (0x6) is an offset-keyed
  stand-in until it is ported. `test_id08_09_glue.gd` replays 13 cases (nine machines and HFS
  failures, FSOpen and its failure, a chosen and a cancelled Get File).
- `ID08.gd` gains `load_overlay_from_resource`, completing ID08 (4).
  `tools/strict_port/gen_id08_loader_cases.py` plays the overlay file back through FSRead's buffer
  argument (an "outseq" list of long lists: the 32-byte header, code, data, each 8-byte relocation
  entry, the payload) with an unaligned image block, and runs alloc_and_read_resource_payload for
  real. `test_id08_loader.gd` replays 12 cases (a load with relocations in both tables and a
  skipped entry, a previous image replaced, the default-volume retry, no file, a failed header
  read, no memory, no data part, both relocation errors, the image checks either way, the locked
  volume). The bootstrap's test keeps the loader as a stand-in.
- `ID06.gd` gains `render_scanline_spans` and `rasterize_and_present`, completing ID06 (24). The
  renderer keeps its data (0x39e) and D3-D7 / A2-A6 (0x3ae) in its own code between bands, so it
  is ported register by register and writes them at `code_base` (set from the fixture's new
  "port_vars"; `helpers/segment_cases.gd`). `tools/strict_port/gen_id06_render_cases.py` renders
  scenes the original built (no polygons, two, overlapping with depth order, a first band and a
  band continued from a scene captured after it) and runs rasterize_and_present with the row
  table's renderer pointer (A5 + 0x192) and JT $322 as stand-ins (whole target, one band, bands
  of 0x20 and 0x25, no row table). `test_id06_render.gd` replays 10 cases.
- `ID03.gd` (new) starts with 12 helpers: `set_scaled_text_style`, the `scale_design_*` trio,
  `max3_int`, `nearest_palette_index_rgb`, `new_offscreen_bw_port` / `dispose_offscreen_bw_port`,
  `dial_point_at_angle`, `open_cport_on_buffer`, `close_port_glue` and
  `remap_panel_colours_identity`. ID02's abs_long (JT $4da) and memset (JT $4f2) run for real on both
  sides (ID02.bin loaded behind the slots; the port calls StrictID02); the sine / cosine routines
  are scripted "addr" stand-ins and remap_cached_panel_colours (0x6c1c) an offset-keyed one.
  `tools/strict_port/gen_id03_helpers_cases.py` / `test_id03_helpers.gd`: 41 cases (four text
  styles, five scales each way, five max3, six palette searches across modes and extras, three
  offscreen ports, four dial arcs, the colour port, close, the identity remap). A clamped
  scale_design_480_min10 returns MOVEQ #10's whole D0.
- `ID03.gd` batch 2 adds `make_inset_face_oval_region`, `composite_instrument_bitmap`,
  `finish_instrument_supersample`, `draw_vector_glyph_string_centred` and `draw_vector_number`.
  `tools/strict_port/gen_id03_glyph_cases.py` extends the helper batch's set-up with seeded vector
  glyphs and digits, scripted panel-coordinate slots ($3ca / $382) and
  antialias_downsample_bw_3x (0xa3c) as an offset-keyed stand-in. `test_id03_glyph.gd` replays 17
  cases (two ovals, composite and finish in 1- and 8-bit modes, six strings including unknown
  characters and a negative scale, five numbers).
- `ID03.gd` batch 3 adds `draw_bevelled_frame` (four polygons: light top and left, dark bottom and
  right filled with the panel pattern, the face painted), `draw_split_display_box` (its halves kept
  at A5 - 0x119c / -0x1194) and `draw_arc_scale_ticks` (13 ticks, every fourth long).
  `tools/strict_port/gen_id03_panel_cases.py` adds the panel colour slots ($45a / $36a / $3a2 /
  $3e2) and the polygon and rect traps as logging stand-ins. `test_id03_panel.gd` replays 10 cases.
- `ID03.gd` batch 4 adds `draw_numbered_bevel_box` (on the ported bevelled frame and vector
  number), `compute_panel_screen_addresses` and `store_panel_bitmaps_as_resources` ('HEL2').
  `tools/strict_port/gen_id03_boxes_cases.py` adds the Resource Manager traps (GetResource and
  ResError scripted). `test_id03_boxes.gd` replays 8 cases (three boxes across modes and scales,
  the addresses at depths 1 / 4 / 8, storing with and without a resource error).
- `ID03.gd` batch 5 adds `begin_instrument_supersample` (the offscreen port at 1x or 3x, clipped to
  the face oval, the face geometry computed with the design scale held at 480 and restored from its
  low word), `draw_spinning_disc_indicator` (four spoke phases) and
  `draw_ring_with_status_indicators` (a disc per status bit). `tools/strict_port/gen_id03_supersample_cases.py`
  runs new_offscreen_bw_port for real on both sides; `test_id03_supersample.gd` replays 15 cases
  (four supersamples across modes, five phases and a too-small disc, five flag sets).
- `ID03.gd` gauges start with `draw_fuel_gauge` and `draw_landing_gear_indicator`, on shared
  helpers (`_gauge_begin`: the arguments written to their stack slots, since
  begin_instrument_supersample updates them in place, the ring, the supersample; `_gauge_label`;
  `_gauge_finish`), then `draw_flaps_indicator` and `draw_ammo_counter` (face ticks via
  `_face_tick`, hotspots via `_gauge_hotspots`), `draw_climb_indicator` and `draw_tachometer`
  (scale numbers via `_face_number`; the tachometer's frame differs, so the helpers read their
  offsets from `_layout`: `SMALL_GAUGE` / `WIDE_GAUGE` / `ALTIMETER_GAUGE`), then
  `draw_manifold_pressure_gauge` (two stacked labels), `draw_altimeter` (3 x major ticks),
  `draw_airspeed_indicator` (three pen weights; `_face_stroke` split out of `_face_tick`) and
  `draw_direction_indicator` (compass letters in vector glyphs; `_face_label_point`),
  `draw_percent_scale_gauge` and `draw_panel_section_with_numbered_boxes` (SetRect is a
  stand-in, so the boxes start from the frame rect as the original's would under it).
  `draw_instrument` dispatches through ID01's dense switch (now loaded for every ID03 fixture);
  every gauge runs for real: `draw_turn_and_bank_indicator` (two shapes rotated by the routine at
  *(A5 - 0x105e), an "addr" stand-in; the rotated points show in the strokes drawn), `draw_artificial_horizon` (row spans
  scanned with scripted PtInRgn answers) and `draw_gyro_instrument` (the heading card through a
  colour port from JT $402) run for real.
  `tools/strict_port/gen_id03_gauges_cases.py` / `test_id03_gauges.gd`: 59 cases (the gauges in 1-,
  8- and 4-bit modes, the horizon with and without spans, the gyro with and without its card,
  draw_instrument for kinds -1..10).
- `ID03.gd` gains `remap_cached_panel_colours` (the cached panel and gyro card recoloured nibble- or
  byte-wise through an inverse map of the panel slots, picked with ID01's sparse switch, slot $2a,
  now installed for every ID03 fixture); `remap_panel_colours_identity` calls it for real instead of
  a stand-in. `tools/strict_port/gen_id03_remap_cases.py` / `test_id03_remap.gd`: 8 cases (4-, 8-,
  2- and 1-bit panels, another geometry, no scenery, the identity remap at 4 and 8 bits).
- `ID03.gd` gains `antialias_downsample_bw_3x` (a 7 x 7 Gaussian window, 969 in all, over a 1-bit 3x
  image, each non-blank output pixel a grey put through nearest_palette_index_rgb and plotted); its
  callers (composite, percent scale, gyro) call it for real, so their extra pushed words go unread
  as in the original. As it plots pixel by pixel, MoveTo / Line / JT $36a keep digest logs (a new
  stub option: the count and a running hash; `segment_stubs.py`, `helpers/segment_cases.gd`) and
  the gauge fixture runs at a quarter of the design scale. `gen_id03_downsample_cases.py` /
  `test_id03_downsample.gd`: 5 cases (sparse, dense, blank, 4-bit, one row; with and without the
  drawn-column flags).
- `ID03.gd` gains `prepare_instrument_panel`, completing ID03 (45): the panel scale and the "Bitmap
  Cache" ('HEL2' 127); a cache entry of this display configuration used when current or stored (a
  stored one loaded and recoloured), otherwise the whole panel drawn afresh (frame and edge regions,
  outline, every instrument at its design place) into the least recently used entry; the gyro tape
  port and horizon face region after. The bitmap release helper (0x59f4, not exported) is an
  offset-keyed stand-in. `tools/strict_port/gen_id03_prepare_cases.py` keeps every stand-in on a
  digest log (the panel calls them hundreds of times; LineTo is digest-logged in every ID03 fixture
  now) with the panel-coordinate slots fixed so the panel stays a few pixels across;
  `test_id03_prepare.gd` replays 4 cases (current entry, stored entry loaded, redraws at depths 4
  and 1 without a cache).
- `ID02.gd` gains `begin_overlay_session`, `ensure_free_memory_and_init_sound`,
  `call_overlay_session_hooks`, `process_pending_update_events`, `handle_update_event` and
  `redraw_main_window` (load_game_sounds, lock_sound_slots and the device colour check run for real).
  init_sound_system (until it was ported, below) and three unexported helpers (0x95a, 0x4d96,
  0xa26) are offset-keyed stand-ins through `_local`; the overlay hooks are "addr" stand-ins.
  `tools/strict_port/gen_id02_session_cases.py` / `test_id02_session.gd`: 14 cases.
- `ID02.gd` gains `layout_game_window_and_view` (the view size through ID01's dense switch, the
  menu-bar skip of a 512 x 342 screen, the aspect shrink loop, the device view bases, the window
  made or moved and sized), `configure_display_from_main_device` and `apply_settings_to_live_options`
  (scan_display_devices, the palette set-up, the caution alert, the out-of-memory exit and
  redraw_main_window run for real). The offscreen-port close (0xd24, not exported) is an
  offset-keyed stand-in; the palette entry traps are digest-logged. ID01's switch helper sits behind
  slot $3a. `tools/strict_port/gen_id02_display_cases.py` / `test_id02_display.gd`: 29 cases.
- `ID02.gd` gains `refresh_display_if_changed`, `reset_overlay_state`, `set_view_size_option`,
  `wait_for_click_or_key`, `show_resource_file_error_box`, `handle_mouse_down` and
  `poll_and_dispatch_event` (the display configuration, settings, redraw, menu update and activate
  handler run for real, and do_menu_command since it was ported). The overlay-globals sync
  (0x4d24, not exported) is an offset-keyed stand-in; GetNextEvent answers scripted event records
  and FindWindow a scripted part and window per case, with the main device in 1-bit mode so the
  redraws stay in their tested path. `tools/strict_port/gen_id02_events_cases.py` /
  `test_id02_events.gd`: 36 cases.
- `ID02.gd` gains `do_menu_command` (HiWord / LoWord through ID01's dense switches: the Apple, File,
  Edit, options and detail menus, the settings toggled and marked changed, always applied at the
  end) and `start_new_mission`; handle_mouse_down and poll_and_dispatch_event now call the port.
  run_flight_session (until it was ported, below) and the unexported settings save (0x2da0) and quit
  (0x2eaa) are offset-keyed stand-ins; HiWord / LoWord are scripted per case.
  `tools/strict_port/gen_id02_commands_cases.py` / `test_id02_commands.gd`: 48 cases (every item of
  the five menus).
- `ID02.gd` gains the three VBL sound handlers (`vbl_sound_handler_ch0_unrolled`,
  `vbl_sound_handler_ch0_variant`, `vbl_sound_handler_two_channel`) and `init_sound_system`. The
  handlers keep their A5 in a long inside their own code, so the port reads and writes it at
  `code_base` + 0x39c4 / 0x3aca / 0x3be0 (the first call records CurrentA5 and returns). Channel 0 is
  resampled with the ADD.L / ADDX.L fraction carry into 370 sound-buffer bytes (368 from SoundBase +
  4, the last two at SoundBase), with node wrapping only when the frame does not fit; the variant
  copies a fitting frame straight (its MOVEP scratch long ends up as the stored fraction); the
  two-channel handler mixes channel 1 in and falls back to the single-channel hook at the silence
  node. Each returns through the previous sound hook (A5 - 0xc36, an "addr" stand-in).
  ensure_free_memory_and_init_sound now calls init_sound_system, so the session, display, events
  and commands fixtures were regenerated with "code_base". m68k_emu gains MOVEP.
  `tools/strict_port/gen_id02_sound_cases.py` / `test_id02_sound.gd`: 30 cases.
- `ID02.gd` gains `initialize_application` (the Toolbox set-up, SysEnvirons in the frame, the colour
  table header, the MENU check with the resource error box, the two 'HEL1' settings resources made
  when missing, the display configured) and `main`. main never returns, so the port has
  `event_loop_passes` (-1, the default, loops for ever): `tools/strict_port/gen_id02_startup_cases.py`
  stops the original when its loop reaches the poll a third time and gives the port 2.
  install_menus, configure_display_from_main_device, start_new_mission and poll_and_dispatch_event
  run for real; the unexported set-up 0x1b42 and quit 0x2eaa are offset-keyed stand-ins.
  `test_id02_startup.gd`: 8 cases.
- `ID02.gd` gains `run_flight_session`, the last of the 740: the restart-point set-up, the frame
  timing (4 ticks), mouse and button, one key event per frame (command key-ups through ID01's
  sparse long switch $32: T, 1..5, Q, S, E), the other events (updates / activates around the
  session), the mouse and step hooks, the roster write-back and the ending switch (conclude and
  restart, paused dialog, quit). end_overlay_session (0x4a4), the screen-globals sync (0x4d96) and
  quit (0x2eaa) are offset-keyed stand-ins; the overlay's flight hooks are "addr" stand-ins. The key
  hook ends a flight on its first non-zero result, so every case finishes on its own. start_new_mission
  and do_menu_command now call the port: the events / commands / start-up generators share the
  flight stand-ins (their key hook answers 5, quit, by default; slot $32 now points at ID01) in a
  0x70000 memory, and their fixtures were regenerated. `tools/strict_port/gen_id02_flight_cases.py` /
  `test_id02_flight.gd`: 19 cases.

`animate_ground_fire` (`0x17150`) and `tick_ground_fire` (`0x17380`) are ported. The
fire keeps four vertices beside its owner, across the owner's velocity: offsets
(±v asl 5) divs.l (|vx| + |vz|), stored / 8 toward zero as drift words. While the
owner's damage word has bits 0x1800, vertices 0 / 3 detach by a coin from the overlay
RNG and drift. Otherwise all four detach and the fire counts its timer down (state 3).
A retired or stopped owner, or a rewind, also ends the fire. `test_ground_fire.gd`
covers each state and branch.

The trail family is ported (`0x16ac4`..`0x1702a`): both initialisers, `spawn_trail`,
`attach_smoke_trail`, `attach_burning_trail`, `destroy_trail_controller`,
`animate_smoke_trail`, `animate_burning_trail` and `tick_trail`. They are registered
by runtime address, so a trail's init, animate, tick and destroy all run strict code.
A trail is a four-vertex ribbon at its owner. Vertices detach one at a time by RNG
coins and stay behind; on the burning trail they also drift. A smoke trail whose
owner keeps smoking re-attaches a fresh trail from state 3.
A detail the test pins down: release sets state 4 before the state switch, so a
released trail at lifetime 0 finishes in the same call. Each later call releases
again, taking the owner's trail count below zero, as the bytes do.

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

## Resource fork mirror and dialog scenes

`godot/strict_port/` mirrors `sources/resedit-1-0-3/` type by type, each folder its source
folder's name lower-cased (`ALRT` -> `alrt`, `ICN#` -> `icn#`, `icI4` -> `ici4`) beside `code/`,
keeping each file name: the original payloads (`<id>.bin`, byte-identical), the media already
derived next to them (the PICT and ICON PNGs so far), and one scene per dialog resource
(`alrt/<id>.tscn`, `dlog/<id>.tscn`, `ditl/<id>.tscn`). CODE is not mirrored: its port is
`code/`. `tools/strict_port/import_resedit.py` writes the mirror and `mappings/resources.json` (every file
with its source and SHA-256); `--check` (also run by `tools/qa/test_regression.py`) fails on any
missing, changed or extra file and prints the progress.

The scenes do not carry decoded data: `ui/dialog_view.gd` reads the `.bin` at run time and
`ui/dialog_templates.gd` decodes it field for field (AlertTemplate, DialogTemplate, the item list
with its disabled bit and word padding; DITL 135's ninth item, cut short by the end of the
resource, is left out as the decoder reports it). The view draws an ALRT or DLOG as its window at
its global position on a 640 x 480 screen and a bare DITL in a plain box: the procID's frame (all
dialogs here use 1, the modal box), 16 x 16 round-rect buttons with centred titles, check boxes and
radio buttons, TextBox-wrapped static text (CR breaks, `^0`..`^3` shown literally), edit text framed
3 pixels out, 1-bit ICONs from their bytes and PICTs from the derived PNGs scaled into their rects,
the alert's default button outlined per stage 1, and items clipped to the window. User items are
shown as ResEdit's editor shows them, grey boxes. The resource fork holds no FONT / NFNT, so the
system font (Chicago 12) is stood in for by the nearest installed face; the window frame follows
the System 7 modal box (outer line, white line, 2-pixel line, 4 white pixels) as the system WDEF
itself is not in the file.

`godot/tests/strict_port/test_resedit_dialogs.gd` checks the GDScript decoder against the resource
evidence for all 40 dialog resources (`fixtures/resedit_dialogs.json`, written by the importer)
and that every scene draws its window and items.

The second import adds the controls, the Finder bundle and every icon and colour resource
(`cntl/`, `bndl/`, `fref/`, `icn#/`, `ics#/`, `ici4/`, `ici8/`, `ics4/`, `ics8/`, `cicn/`, `clut/`,
plus a scene for `icon/`). `ui/resource_canvas.gd` now holds the drawing the views share;
`ui/resource_images.gd` decodes the one-bit families (icon and mask), the indexed ones through the
system's default colour tables (clut 4 and clut 8: the 6 x 6 x 6 cube without black, the red,
green, blue and grey ramps, black at 255) and a `cicn` through its own table; `ui/icon_view.gd`
shows them as ResEdit's icon editors do (fat bits with the actual size, the mask beside), a `clut`
as its entries; `ui/control_view.gd` draws a `CNTL` by its procID (CNTL 128 is an inactive vertical
scroll bar: maximum not above minimum, so a white track without thumb); `ui/finder_view.gd` shows a
`BNDL` as its signature and one row per file type with its six icons, and a `FREF` through the
bundle that lists it. The folders are lower-cased copies of the source folder names (`ALRT` ->
`alrt`, `ICN#` -> `icn#`, `icI4` -> `ici4`; callers still name types by their source folder and
`resource_files.gd` makes the path).

`godot/tests/strict_port/test_resedit_interface.gd` checks CNTL, BNDL and FREF against the
resource evidence (`fixtures/resedit_interface.json`), every icon against the PNG derived next to
it wherever that PNG is opaque (all but ics8, whose derived PNGs do not follow the default 8-bit
table: entry 245 comes out dark blue and 255 mid grey, while the icl8 PNGs follow it exactly),
every cicn against its PNG, and that every scene draws its resource.

The third import adds the menus, strings and information resources (`menu/`, `str#/`, `text/`,
`styl/`, `vers/`, `size/`), decoded by `ui/resource_text.gd`. `ui/menu_view.gd` shows a MENU pulled
down from its highlighted title (character 0x14 is the system font's Apple logo), its items in
16-pixel rows with the mark margin, the command keys and grey-pattern separators, dimmed by the
enable flags (bit 0 the whole menu: MENU 3, Edit, has flags 0 and is drawn dimmed throughout).
`ui/text_view.gd` shows a STR# as its numbered strings, a TEXT in the run of the styl with the same
ID (TEXT 1000 in styl 1000's 10-point Geneva run, which the stand-in face draws at that size), a
TEXT holding binary longs (TEXT 128) in ResEdit's hex layout, a styl as its runs, vers and SIZE as
their fields. `godot/tests/strict_port/test_resedit_text.gd` checks them against the resource
evidence (`fixtures/resedit_text.json`) and their drawings.

The fourth import completes the mirror (29 of 29 types, 109 resources, 109 scenes): the sounds
(`snds/`, each `.bin` with the MP3 derived next to it), a scene for every picture (`pict/`), and
the application's own data types (`data/`, `drel/`, `hel1/`, `hell/`, `mdpl/`, `zero/`).
`ui/resource_sound.gd` decodes a format 1 'snd ' (modifiers, the bufferCmd whose param2 is the
sound header's offset, the header: length, 16.16 rate, loop, encoding 0, base note) and turns its
8-bit offset-binary samples into an AudioStreamWAV at the header's rate rounded to the hertz;
`ui/sound_view.gd` shows the header fields and the waveform (the loop span shaded) and plays the
samples when the scene runs, as ResEdit's "Try Sound" does, rather than the derived MP3. A PICT
scene shows the picture at its frame (picSize and picFrame read from the bytes; the opcodes are
not replayed, the derived PNG is drawn at its own size: PICT 131's is 135 x 749 for a 137 x 751
frame and PICT 1000's 425 x 88 for 438 x 93). The data types, which ResEdit has no template for,
are shown in its hex layout. `godot/tests/strict_port/test_resedit_media.gd` checks the sounds
against the resource evidence down to their samples' SHA-256 (`fixtures/resedit_media.json`),
the pictures' sizes and versions, every data resource's bytes and hex rows, and every scene.

The resource fork holds no FONT or NFNT: there is no font to import. Every view draws the system
font with the nearest installed face.
