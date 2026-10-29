# Strict port namespace

This directory is the source-faithful implementation track. It is isolated from
the playable prototype under `godot/hellcats/` until a translated slice reaches
an explicit integration milestone.

- `code/`: GDScript modules grouped by original CODE segment or overlay.
- `compat/`: explicit C and Motorola 68000 value semantics.
- `mappings/functions.json`: the sole machine-readable source-to-target mapping.
- `alrt/`, `ditl/`, `icn#/`, ... (one folder per resource type, beside `code/`): the resource fork
  mirrored from `sources/resedit-1-0-3/`, each folder its source folder's name lower-cased, the
  same file names: byte-identical `<id>.bin` payloads (the views decode them at run time, as the
  Resource Manager hands the original bytes to the toolbox), the media already derived next to
  them, and one `<id>.tscn` scene per resource the views draw (`tools/strict_port/import_resedit.py`
  writes it and checks it with `--check`; `mappings/resources.json` lists every file with its source
  and SHA-256). Godot does not import `.bin` files: they are read with `FileAccess`, so an export
  preset must list `*.bin` (and the media) among its non-resource files to include.
- `ui/`: the toolbox templates decoded from those bytes (`dialog_templates.gd`, `resource_images.gd`,
  `resource_text.gd`, `resource_sound.gd`) and the views that draw them as ResEdit shows them
  (`resource_canvas.gd` and the dialog, icon, control, Finder, menu, text and sound views; a sound
  scene plays its samples when it runs).

Godot runtime adapters will live in `strict_port/adapters/` when an integration
slice needs one. Adapters may use Godot lifecycle names, but original algorithms
remain in `code/` and may not be replaced by adapter behavior.

From the repository root, verify correspondence with:

```sh
python3 tools/strict_port/check_sync.py --json
```

The command only reports. It never updates hashes or translated GDScript.
