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
