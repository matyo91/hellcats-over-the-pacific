# Overlay 3-D renderer (Pacific Conflict)

Per-frame object drawing in `Pacific Conflict.decomp.c`. Names are the
recovered ones; confidence **[STRONG INFERENCE]** unless marked.

## Call flow

```text
overlay_frame_step
  render_visible_objects            (0xac72)
    project_prepared_object         (0xa676)  vertices already in camera space
    transform_and_project_object    (0xa75e)  definition +0xe pre-render hook,
                                              object→camera matrix, project used vertices
    emit_faces_in_order (0x9ef8) | emit_faces_bsp (0x9da6) | emit_faces_unnumbered (0x9fc4)
      face_is_back_facing (0x9ae0), emit_face_chain (0x9d34)
    submit_object_faces             (0xa2f2)  camera-penetration test
      transform_face_vertices       (0xa512)  lazy vertex transform / projection
      clip_face_near_plane          (0xb028)  z = 5
      *DAT_00020ab4                           output_face_colour (0xa16e, depths 4 / 8)
                                              or output_face_bw (0xa220, depth 1)
```

`output_face_colour` clips to the screen and calls the overlay span
renderer `FUN_00009b8c`; `output_face_bw` clips and calls the host service
overlay +0x7c = host A5-0x130c = ID06 `add_polygon_edges` (docs/topics/RASTERIZER.md)
**[PROVEN by the A5 arithmetic]**.

Colour path: `add_face_edges_to_rows` (0x9b8c) turns each
polygon edge into a 0x1c-byte edge record (pool `DAT_0001b76c`, x 16.16,
slope, start row) inserted into the per-row buckets `DAT_0001eaac[row]`,
sharing records between faces with a common edge; `scan_convert_edge_rows`
(0x2e14) then keeps an active edge list per row, resolves the front
face between edges by draw order and writes runs into `DAT_0001b794` /
`DAT_0001b798` for the span fillers `fill_span_rows_*`. `track_ground_plane_horizon` (0xa07e) handles the ground-plane
face `DAT_0001bda8`: screen corners covered (`DAT_0001bd90`) and the horizon
edge (`DAT_0001bda0` / `9c` / `98` / `94`).

## Render state

| Global | Meaning |
|---|---|
| `DAT_00025b24` | current object |
| `DAT_00025b20` | its camera-space vertices (object +0x4c, 12 bytes, words +2 / +6 / +10) |
| `DAT_00025f30` | its faces (object +0x48, 0x20 bytes each) |
| `DAT_000256b2` | projected screen points (x, y longs; 0x80000000 = z < 5) |
| `DAT_00020b28` / `DAT_00020b26` | projection scales x / y |
| `DAT_00025d30` / `DAT_00025d2c` | queued faces / cursor |
| `DAT_00025b2c` / `DAT_00025b28` | back faces kept for the penetration test / cursor |
| `DAT_00025b16` | near mode (camera within the object range; 2 = first frame) |
| `DAT_0001c1be` | running draw-order number |

## Face record (0x20 bytes)

| Offset | Field |
|---|---|
| +0x02 | draw-order number |
| +0x10 / +0x11 | BSP front / back child (−1 none) |
| +0x12 | next face in chain (−1 end) |
| +0x13 | flags: 1 double-sided, 2 hidden, 8 camera side last frame, 0x10 camera side now, 0x20 / 0x40 vertex state |
| +0x14 | vertex count |
| +0x18 | vertex index list |
| +0x1c | detail threshold (drawn while object metric ≤ it) |

Face normals are stored after the object's vertex list (object +0x36 =
vertex count).

## Crashing through faces

In near mode `submit_object_faces` compares the camera side of each face with
the previous frame; when it changed and the view axis lies inside the face
(`point_in_polygon_xy` on camera-space vertices) it calls
`dispatch_collision(player, object)` — the renderer doubles as the collision
test for flying into large objects.

## Sky and ground

`draw_sky_and_ground` (0xb4b6), called by `overlay_frame_step`, scales the
horizon edge from `track_ground_plane_horizon` to window rows and fills the
background above / below it with the host colours +0x18e / +0x190, choosing
per side from the corner bits `DAT_0001bd90` (0xf all ground, 0 all sky)
**[STRONG INFERENCE]**. `reset_background_rows` (0xb460) initialises its
per-row span buffer.

## Frame output

Colour depths: `scan_convert_edge_rows` → `present_spans_to_window` (0xd298:
bands of a 0x2000-byte buffer filled by the span filler `*DAT_00020ac0`,
copied with host service +0x296). Depth 1: `present_bw_frame` (0xd34c) calls
host +0x80 = ID06 `rasterize_and_present`.
