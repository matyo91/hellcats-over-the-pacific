# Strict port

The source-faithful translation of the original program: every function of the semantic
`*.decomp.c` files, in GDScript. The rules and conventions are in
[`docs/port/STRICT_PORT_FOUNDATION.md`](../../docs/port/STRICT_PORT_FOUNDATION.md).

- `code/`: one GDScript module per original CODE segment, and the Pacific Conflict overlay.
- `compat/`: explicit C and Motorola 68000 value semantics, and the 68000 address space.
- `mappings/functions.json`: the sole machine-readable source-to-target mapping.

The Macintosh the port runs on is in `../runtime/`; the original resources it reads are in
`../resources/`.

From the repository root, verify correspondence with:

```sh
python3 tools/strict_port/check_sync.py --json
```

The command only reports. It never updates hashes or translated GDScript.
