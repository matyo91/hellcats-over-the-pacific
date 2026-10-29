#!/usr/bin/env python3
"""Mirror sources/resedit-1-0-3 into godot/strict_port, type by type (each type folder, lower-cased, beside code/).

Every imported type keeps its folder name (lower-cased: ALRT -> alrt, ICN# -> icn#, icI4 -> ici4) and each
resource its file names: the original payload
(<id>.bin, byte-identical) plus the media already derived next to it (PNG pictures and icons, MP3
sounds), and, for the types the Dialog Manager draws, one scene per resource (<id>.tscn) that shows
it as ResEdit does (godot/strict_port/ui/dialog_view.gd decodes the .bin itself). The ResEdit
annotations (.md) and evidence (.json) stay in sources/. CODE is not mirrored: its port is
godot/strict_port/code/.

The import grows by iterations: IMPORTED lists the types done so far. mappings/resources.json
records each file with its source and SHA-256; --check verifies the mirror matches (no missing,
changed or extra files) and prints the progress. The dialog fixture for
godot/tests/strict_port/test_resedit_dialogs.gd is written from the resource evidence JSON.

Usage: python3 tools/strict_port/import_resedit.py [--check]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "sources" / "resedit-1-0-3"
MIRROR = ROOT / "godot" / "strict_port"
MANIFEST = MIRROR / "mappings" / "resources.json"
FIXTURE = ROOT / "godot" / "tests" / "strict_port" / "fixtures" / "resedit_dialogs.json"
INTERFACE_FIXTURE = ROOT / "godot" / "tests" / "strict_port" / "fixtures" / "resedit_interface.json"
TEXT_FIXTURE = ROOT / "godot" / "tests" / "strict_port" / "fixtures" / "resedit_text.json"
MEDIA_FIXTURE = ROOT / "godot" / "tests" / "strict_port" / "fixtures" / "resedit_media.json"

# Every resource type folder of the export (CODE is ported as code, not mirrored).
ALL_TYPES = ["ALRT", "BNDL", "CNTL", "DATA", "DITL", "DLOG", "DREL", "FREF", "HEL1", "HELL", "ICN#", "ICON", "MDPL",
             "MENU", "PICT", "SIZE", "STR#", "TEXT", "ZERO", "cicn", "clut", "icI4", "icI8", "ics#", "ics4", "ics8",
             "snds", "styl", "vers"]
# The derived media copied next to the payloads.
MEDIA = {"PICT": ["png"], "ICON": ["png"], "ICN#": ["png"], "ics#": ["png"], "icI4": ["png"], "icI8": ["png"],
         "ics4": ["png"], "ics8": ["png"], "cicn": ["png"], "snds": ["mp3"]}
# Types shown by a scene per resource, and the view that draws them.
DIALOG, ICONS, CONTROL, FINDER, MENU, TEXT, SOUND = (
    "res://strict_port/ui/dialog_view.gd", "res://strict_port/ui/icon_view.gd", "res://strict_port/ui/control_view.gd",
    "res://strict_port/ui/finder_view.gd", "res://strict_port/ui/menu_view.gd", "res://strict_port/ui/text_view.gd",
    "res://strict_port/ui/sound_view.gd")
SCENES = {"ALRT": DIALOG, "DLOG": DIALOG, "DITL": DIALOG, "CNTL": CONTROL, "BNDL": FINDER, "FREF": FINDER,
          **{t: ICONS for t in ("ICON", "ICN#", "ics#", "icI4", "icI8", "ics4", "ics8", "cicn", "clut", "PICT")},
          "MENU": MENU, **{t: TEXT for t in ("STR#", "TEXT", "styl", "vers", "SIZE", "DATA", "DREL", "HEL1", "HELL", "MDPL", "ZERO")},
          "snds": SOUND}
# The types imported so far, in the order of the iterations.
IMPORTED = ["ALRT", "DITL", "DLOG", "ICON", "PICT",                                  # iteration 1
            "CNTL", "BNDL", "FREF", "ICN#", "ics#", "icI4", "icI8", "ics4", "ics8", "cicn", "clut",  # iteration 2
            "MENU", "STR#", "TEXT", "styl", "vers", "SIZE",                                       # iteration 3
            "snds", "DATA", "DREL", "HEL1", "HELL", "MDPL", "ZERO"]                               # iteration 4
IGNORED_SUFFIXES = {".import", ".uid"}


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def folder(type_name: str) -> Path:
    """The mirrored folder of a source type folder: its name lower-cased."""
    return MIRROR / type_name.lower()


def resource_ids(type_name: str) -> list[int]:
    return sorted(int(p.stem) for p in (SOURCE / type_name).glob("*.bin"))


def scene_text(type_name: str, rid: int) -> str:
    node = f"{type_name.replace('#', '_')}_{rid}".replace("-", "m")
    return (f'[gd_scene load_steps=2 format=3]\n\n'
            f'[ext_resource type="Script" path="{SCENES[type_name]}" id="1"]\n\n'
            f'[node name="{node}" type="Control"]\n'
            f'layout_mode = 3\nanchors_preset = 0\n'
            f'script = ExtResource("1")\n'
            f'resource_type = "{type_name}"\nresource_id = {rid}\n')


def expected() -> dict[Path, bytes]:
    """Every file the mirror should hold, with its content."""
    files: dict[Path, bytes] = {}
    for type_name in IMPORTED:
        for rid in resource_ids(type_name):
            for ext in ["bin"] + MEDIA.get(type_name, []):
                src = SOURCE / type_name / f"{rid}.{ext}"
                if src.exists():
                    files[folder(type_name) / src.name] = src.read_bytes()
            if type_name in SCENES:
                files[folder(type_name) / f"{rid}.tscn"] = scene_text(type_name, rid).encode()
    return files


def manifest(files: dict[Path, bytes]) -> bytes:
    types = {}
    for type_name in ALL_TYPES:
        entries = []
        for path in sorted(p for p in files if p.parent == folder(type_name)):
            src = SOURCE / type_name / path.name
            entries.append({"path": path.relative_to(ROOT).as_posix(), "sha256": sha256(files[path]),
                            "source": src.relative_to(ROOT).as_posix() if src.exists() else None,
                            "kind": "scene" if path.suffix == ".tscn" else "payload" if path.suffix == ".bin" else "media"})
        types[type_name] = {"status": "imported" if type_name in IMPORTED else "pending", "resources": len(resource_ids(type_name)),
                            "files": entries}
    doc = {"schema": "hellcats-strict-resedit-mirror-v1", "source_root": SOURCE.relative_to(ROOT).as_posix(),
           "imported_types": IMPORTED, "types": types}
    return (json.dumps(doc, indent=2) + "\n").encode()


def fixture() -> bytes:
    """The decoded dialog fields from the resource evidence, for the GDScript decoder's test."""
    cases = []
    for type_name in ("ALRT", "DLOG", "DITL"):
        for rid in resource_ids(type_name):
            decoded = json.loads((SOURCE / type_name / f"{rid}.json").read_text())["decoded"]
            entry: dict = {"type": type_name, "id": rid}
            props = decoded.get("properties", {})
            if type_name in ("ALRT", "DLOG"):
                b = props["bounds"]
                entry.update(bounds=[b["left"], b["top"], b["width"], b["height"]], ditl_id=props["ditl_id"])
            if type_name == "ALRT":
                entry["stage_word"] = int(props["stage_word"], 16)
            if type_name == "DLOG":
                entry.update(proc_id=props["window_procedure_id"], title=props["title"], visible=props["visible"],
                             go_away=props["go_away_box"])
            if type_name == "DITL":
                items = []
                for e in decoded["elements"]:
                    if e.get("status") == "TRUNCATED":
                        continue
                    b = e["bounds"]
                    item = {"type": e["type_code"], "enabled": e["enabled"], "bounds": [b["left"], b["top"], b["width"], b["height"]]}
                    if "text" in e:
                        item["text"] = e["text"]
                    if "referenced_resource_id" in e:
                        item["resource_id"] = e["referenced_resource_id"]
                    items.append(item)
                entry.update(count=props["item_count"], items=items)
            cases.append(entry)
    return (json.dumps({"cases": cases}, ensure_ascii=False, separators=(",", ":")) + "\n").encode()


def interface_fixture() -> bytes:
    """The decoded control, bundle and file-reference fields from the resource evidence."""
    cases = []
    for rid in resource_ids("CNTL"):
        p = json.loads((SOURCE / "CNTL" / f"{rid}.json").read_text())["decoded"]["properties"]
        b = p["bounds"]
        cases.append({"type": "CNTL", "id": rid, "bounds": [b["left"], b["top"], b["width"], b["height"]], "value": p["initial_value"],
                      "visible": p["visible"], "max": p["maximum"], "min": p["minimum"], "proc_id": p["procedure_id"],
                      "refcon": p["refcon"], "title": p["title"]})
    for rid in resource_ids("BNDL"):
        d = json.loads((SOURCE / "BNDL" / f"{rid}.json").read_text())["decoded"]
        types = {g["resource_type"]: {str(m["local_id"]): m["resource_id"] for m in g["mappings"]} for g in d["elements"]}
        cases.append({"type": "BNDL", "id": rid, "signature": d["properties"]["creator_code"],
                      "version": d["properties"]["bundle_version"], "types": types})
    for rid in resource_ids("FREF"):
        p = json.loads((SOURCE / "FREF" / f"{rid}.json").read_text())["decoded"]["properties"]
        cases.append({"type": "FREF", "id": rid, "file_type": p["file_type"], "local_icon_id": p["local_icon_id"], "filename": p["filename"]})
    return (json.dumps({"cases": cases}, ensure_ascii=False, separators=(",", ":")) + "\n").encode()


def text_fixture() -> bytes:
    """The decoded menu, string, text, style, version and SIZE fields from the resource evidence."""
    def decoded(t: str, rid: int) -> dict:
        return json.loads((SOURCE / t / f"{rid}.json").read_text())["decoded"]
    cases = []
    for rid in resource_ids("MENU"):
        d = decoded("MENU", rid)
        p = d["properties"]
        cases.append({"type": "MENU", "id": rid, "menu_id": p["menu_id"], "flags": int(p["enable_flags"], 16), "title": p["title"],
                      "items": [[e["text"], e["icon_number"], e["keyboard_byte"], e["mark_or_submenu"], e["style"]] for e in d["elements"]]})
    for rid in resource_ids("STR#"):
        cases.append({"type": "STR#", "id": rid, "strings": [e["text"] for e in decoded("STR#", rid)["elements"]]})
    for rid in resource_ids("TEXT"):
        p = decoded("TEXT", rid)["properties"]
        if "text" in p:
            cases.append({"type": "TEXT", "id": rid, "text": p["text"]})
    for rid in resource_ids("styl"):
        cases.append({"type": "styl", "id": rid, "runs": [[e["start_character"], e["line_height"], e["font_ascent"], e["font_id"],
                                                           int(e["face_bits"], 16), e["font_size"], e["rgb16"]]
                                                          for e in decoded("styl", rid)["elements"]]})
    for rid in resource_ids("vers"):
        p = decoded("vers", rid)["properties"]
        cases.append({"type": "vers", "id": rid, "fields": [p["major"], p["minor"], p["bugfix"], p["stage"], p["non_release_revision"],
                                                            p["region_code"], p["short_string"], p["long_string"]]})
    for rid in resource_ids("SIZE"):
        p = decoded("SIZE", rid)["properties"]
        cases.append({"type": "SIZE", "id": rid, "flags": int(p["flags_word"], 16), "set_flags": p["set_flags"],
                      "preferred": p["preferred_memory_bytes"], "minimum": p["minimum_memory_bytes"]})
    return (json.dumps({"cases": cases}, ensure_ascii=False, separators=(",", ":")) + "\n").encode()


def media_fixture() -> bytes:
    """The decoded sound and picture header fields from the resource evidence, and the size and SHA-256
    of every data resource shown in hex."""
    cases = []
    for rid in resource_ids("snds"):
        d = json.loads((SOURCE / "snds" / f"{rid}.json").read_text())["decoded"]
        p = d["properties"]
        cases.append({"type": "snds", "id": rid, "length": p["sample_length"], "rate_fixed": int(p["sample_rate_fixed_16_16"], 16),
                      "loop": [p["loop_start"], p["loop_end"]], "base_note": p["base_frequency_midi"], "synth": p["modifier_synth_id"],
                      "samples_sha256": p["sample_sha256"],
                      "commands": [[int(c["command"], 16), c["param1"], c["param2"]] for c in d["elements"]]})
    for rid in resource_ids("PICT"):
        p = json.loads((SOURCE / "PICT" / f"{rid}.json").read_text())["decoded"]["properties"]
        cases.append({"type": "PICT", "id": rid, "size": p["declared_size_word"], "version": int(p["quickdraw_version"][-1])})
    for t in ("DATA", "DREL", "HEL1", "HELL", "MDPL", "ZERO"):
        for rid in resource_ids(t):
            data = (SOURCE / t / f"{rid}.bin").read_bytes()
            cases.append({"type": t, "id": rid, "bytes": len(data), "sha256": sha256(data)})
    return (json.dumps({"cases": cases}, separators=(",", ":")) + "\n").encode()


def progress() -> str:
    done = sum(len(resource_ids(t)) for t in IMPORTED)
    total = sum(len(resource_ids(t)) for t in ALL_TYPES)
    scenes = sum(len(resource_ids(t)) for t in IMPORTED if t in SCENES)
    return (f"types {len(IMPORTED)}/{len(ALL_TYPES)}, resources {done}/{total} ({100 * done // total}%), "
            f"scenes {scenes}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="verify the mirror instead of writing it")
    args = parser.parse_args()
    files = expected()
    files[MANIFEST] = manifest(files)
    files[FIXTURE] = fixture()
    files[INTERFACE_FIXTURE] = interface_fixture()
    files[TEXT_FIXTURE] = text_fixture()
    files[MEDIA_FIXTURE] = media_fixture()
    if args.check:
        problems = [f"missing or changed: {p.relative_to(ROOT)}" for p, data in files.items() if not p.exists() or p.read_bytes() != data]
        present = {p for t in ALL_TYPES if folder(t).is_dir() for p in folder(t).rglob("*")
                   if p.is_file() and p.suffix not in IGNORED_SUFFIXES}
        problems += [f"extra: {p.relative_to(ROOT)}" for p in sorted(present - set(files))]
        for line in problems:
            print(f"FAIL {line}")
        if problems:
            return 1
        print(f"PASS strict resource mirror: {progress()}")
        return 0
    for path, data in files.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists() or path.read_bytes() != data:
            path.write_bytes(data)
    print(f"mirror written: {progress()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
