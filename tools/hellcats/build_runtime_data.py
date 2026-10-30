#!/usr/bin/env python3
"""Write the data the Godot game runtime (godot/hellcats/runtime) needs from the original files.

- godot/hellcats/data/jump_table.json: the CODE 0 jump table (sources/resedit-1-0-3/CODE/ID00.bin):
  per entry its A5 offset as callers use it (jsr $offset(a5): the slot + 2), segment, target
  offset in the segment file (stored routine offset + 4) and, when that routine is ported, the
  strict port's file and method (godot/strict_port/mappings/functions.json) and whether it takes
  Pascal arguments (CODE 9, the Toolbox glue: pushed left to right, so they reach the slot in
  reverse); plus the A5 world sizes from the CODE 0 header.
- godot/hellcats/data/scenery/Pacific Conflict: the scenery file the game opens (its data fork is
  the overlay code and the world), byte-identical to sources/mac-os-9/Pacific Conflict.

- godot/hellcats/data/overlay_methods.json: the Pacific Conflict overlay's ported routines by
  runtime address (file offset - 0x20, the addresses the overlay stores and the host calls).
- godot/hellcats/data/segment_methods.json: every ported routine of CODE 2..9 by segment and
  offset (the ports also call ported routines by offset).
- godot/hellcats/data/resource_names.json: each resource's original Macintosh name (from the
  resource evidence JSON), for GetNamedResource.

--check verifies they are up to date.

Usage: python3 tools/hellcats/build_runtime_data.py [--check]
"""
from __future__ import annotations

import argparse
import json
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CODE0 = ROOT / "sources" / "resedit-1-0-3" / "CODE" / "ID00.bin"
MAPPINGS = ROOT / "godot" / "strict_port" / "mappings" / "functions.json"
SCENERY = ROOT / "sources" / "mac-os-9" / "Pacific Conflict"
OUT = ROOT / "godot" / "hellcats" / "data"


def jump_table() -> bytes:
    b = CODE0.read_bytes()
    above, below, size, offset = struct.unpack(">IIII", b[:16])
    ported = {}
    for row in json.loads(MAPPINGS.read_text())["functions"]:
        name = row["target_file"].rsplit("/", 1)[-1]
        if name.startswith("ID0"):
            ported[(int(name[3]), int(row["source_address"], 16))] = (name, row["target_function"])
    entries = []
    for k in range(size // 8):
        o = 16 + 8 * k
        stored, = struct.unpack(">H", b[o:o + 2])
        segment, = struct.unpack(">H", b[o + 4:o + 6])
        target = stored + 4
        file_name, method = ported.get((segment, target), (None, None))
        entries.append({"a5_offset": offset + 8 * k + 2, "segment": segment, "target": target,
                        "port": file_name, "method": method, "pascal": segment == 9})
    doc = {"source": CODE0.relative_to(ROOT).as_posix(), "above_a5": above, "below_a5": below,
           "jump_table_offset": offset, "entries": entries}
    return (json.dumps(doc, indent=1) + "\n").encode()


def overlay_methods() -> bytes:
    rows = {}
    for row in json.loads(MAPPINGS.read_text())["functions"]:
        if row["target_file"].endswith("pacific_conflict.gd"):
            rows["0x%x" % (int(row["source_address"], 16) - 0x20)] = row["target_function"]
    # Second entries the port documents inside another routine's extent ("## 0x<file offset> ..."
    # right above the func), which the mapping does not list on their own.
    port = (ROOT / "godot" / "strict_port" / "code" / "pacific_conflict.gd").read_text().splitlines()
    for i, line in enumerate(port):
        m = re.match(r"## 0x([0-9a-f]+)[:( ]", line)
        if not m or int(m.group(1), 16) < 0x20 or (i > 0 and port[i - 1].startswith("##")):
            continue
        for follow in port[i + 1:i + 30]:
            f = re.match(r"func ([a-z_0-9]+)\(", follow)
            if f:
                rows.setdefault("0x%x" % (int(m.group(1), 16) - 0x20), f.group(1))
                break
            if not follow.startswith("##"):
                break
    return (json.dumps(dict(sorted(rows.items(), key=lambda kv: int(kv[0], 16))), indent=1) + "\n").encode()


def segment_methods() -> bytes:
    rows: dict = {}
    for row in json.loads(MAPPINGS.read_text())["functions"]:
        name = row["target_file"].rsplit("/", 1)[-1]
        if name.startswith("ID0") and name[3] != "0":
            rows.setdefault(str(int(name[3])), {})["0x%x" % int(row["source_address"], 16)] = row["target_function"]
    return (json.dumps(rows, indent=1, sort_keys=True) + "\n").encode()


def resource_names() -> bytes:
    names = []
    for path in sorted((ROOT / "sources" / "resedit-1-0-3").glob("*/*.json")):
        if path.parent.name == "CODE":
            continue
        resource = json.loads(path.read_text()).get("resource", {})
        name = resource.get("original_macintosh_name")
        if name:
            names.append({"type": resource.get("original_fourcc", path.parent.name), "folder": path.parent.name,
                          "id": resource["id"], "name": name})
    return (json.dumps(names, indent=1, ensure_ascii=False) + "\n").encode()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    files = {OUT / "jump_table.json": jump_table(), OUT / "scenery" / "Pacific Conflict": SCENERY.read_bytes(),
             OUT / "resource_names.json": resource_names(), OUT / "overlay_methods.json": overlay_methods(),
             OUT / "segment_methods.json": segment_methods()}
    if args.check:
        stale = [p for p, data in files.items() if not p.exists() or p.read_bytes() != data]
        for p in stale:
            print(f"FAIL stale: {p.relative_to(ROOT)}")
        if stale:
            return 1
        print("PASS game runtime data is up to date")
        return 0
    for path, data in files.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    entries = json.loads(files[OUT / "jump_table.json"])["entries"]
    print(f"jump table: {len(entries)} entries, {sum(1 for e in entries if e['method'])} ported")
    return 0


if __name__ == "__main__":
    sys.exit(main())
