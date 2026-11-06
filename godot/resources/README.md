# Original resources

The resource fork of the original application, mirrored from `sources/resedit-1-0-3/` because
Godot loads only files inside its project.

- `alrt/`, `ditl/`, `icn#/`, ...: one folder per resource type, named after its source folder in
  lower case, with the same file names: byte-identical `<id>.bin` payloads (the views decode them
  at run time, as the Resource Manager hands the original bytes to the Toolbox), the media already
  derived next to them, and one `<id>.tscn` scene per resource the views draw.
  `tools/strict_port/import_resedit.py` writes the mirror and checks it with `--check`;
  `resources.json` lists every file with its source and SHA-256. Godot does not import `.bin`
  files: they are read with `FileAccess`, so an export preset must list `*.bin` (and the media)
  among its non-resource files to include.
- `ui/`: the Toolbox templates decoded from those bytes (`dialog_templates.gd`,
  `resource_images.gd`, `resource_text.gd`, `resource_sound.gd`), the loader the runtime reads
  them through (`resource_files.gd`), and the views that draw them as ResEdit shows them
  (`resource_canvas.gd` and the dialog, icon, control, Finder, menu, text and sound views; a sound
  scene plays its samples when it runs).
