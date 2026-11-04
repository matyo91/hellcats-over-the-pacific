#!/usr/bin/env python3
"""Deterministic inspector and metadata generator for sources/resedit-1-0-3.

The comparison payloads come from the classic resource fork embedded in
sources/mac-os-9/Hellcats_1_0_4.appledouble. Generated *.bin
and *.json files are derived evidence; existing ResEdit exports are never
rewritten.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[1]
RESEDIT = ROOT / "sources" / "resedit-1-0-3"
APPLEDOUBLE = (
    ROOT / "sources" / "mac-os-9" / "Hellcats_1_0_4.appledouble"
)
SCHEMA = "hellcats-resedit-resource-v1"

# The directory spelling is retained exactly.  The original four-character
# types below are read from the resource map, not guessed from the exports.
TYPE_TO_FOURCC = {"icI4": "icl4", "icI8": "icl8", "snds": "snd "}
REQUIRED_TYPES = [
    "ALRT", "BNDL", "CNTL", "CODE", "DATA", "DITL", "DLOG", "DREL",
    "FREF", "HEL1", "HELL", "ICN#", "ICON", "MDPL", "MENU", "PICT",
    "SIZE", "STR#", "TEXT", "ZERO", "cicn", "clut", "icI4", "icI8",
    "ics#", "ics4", "ics8", "snds", "styl", "vers",
]

IDENTITIES = {
    ("ALRT", 256): "Unable to Open Scenery Alert",
    ("ALRT", 257): "Save Settings Changes Confirmation Alert",
    ("ALRT", 258): "Parameterized Error Alert",
    ("ALRT", 259): "End Mission Confirmation Alert",
    ("ALRT", 260): "Erase Inactive High Scores Confirmation Alert",
    ("ALRT", 261): "Original Floppy Launch Warning",
    ("ALRT", 1001): "Copy Protection Answer Error Alert",
    ("DITL", 137): "Mission Navigation Map Interface Items",
    ("DITL", 1000): "Manual Copy Protection Interface Items",
    ("DITL", 127): "About Hellcats Dialog Items",
    ("DITL", 128): "Instrument Panel Creation Progress Items",
    ("DITL", 129): "Scenario Selection Dialog Items",
    ("DITL", 130): "Active Duty Roster Dialog Items",
    ("DITL", 131): "Paused Game Dialog Items",
    ("DITL", 132): "Refuel and Reload Dialog Items",
    ("DITL", 133): "Mission Summary Dialog Items",
    ("DITL", 134): "High Scores Dialog Items",
    ("DITL", 135): "Manual Copy Protection Registration Items",
    ("DITL", 136): "Manual Copy Protection Answer Error Items",
    ("DITL", 138): "Monochrome About Hellcats Dialog Items",
    ("DITL", 139): "Insufficient Sound Memory Dialog Items",
    ("DITL", 256): "Unable to Open Scenery Alert Controls",
    ("DITL", 257): "Save Settings Changes Confirmation Controls",
    ("DITL", 258): "Parameterized Error Alert Controls",
    ("DITL", 259): "End Mission Confirmation Controls",
    ("DITL", 260): "Erase Inactive High Scores Confirmation Controls",
    ("DITL", 261): "Hard Disk Installation Warning Controls",
    ("DITL", 1001): "Copy Protection Answer Error Alert Controls",
    ("clut", 999): "16-Color Indexed Palette",
    ("DATA", 0): "A5 World Compressed Initializer Data",
    ("DATA", 128): "Two-Value Persistent Data Record",
    ("DREL", 0): "A5 World Relocation Offset Table",
    ("ZERO", 0): "A5 World Zero-Run Initialization Data",
    ("HEL1", 127): "Hellcats Saved Settings Record",
    ("HEL1", 128): "Player and Score Data Records",
    ("HELL", 0): "Finder Get Info Copyright String",
    ("BNDL", 132): "Hellcats Finder Bundle Mappings",
    ("STR#", 129): "English User-Interface String Table",
    ("TEXT", 1000): "Copy Protection Instructions Text",
    ("styl", 1000): "Copy Protection Text Style Run",
    ("vers", 1): "Hellcats 1.0.3 Version Record",
    ("SIZE", -1): "Hellcats Application Memory Configuration",
    ("MDPL", 128): "594-Byte MDPL Mixed-Field Structure",
    ("CNTL", 128): "Visible 16×70 Pixel Procedure-16 Control Template",
    ("FREF", 130): "APPL File Reference with Local Icon 0",
    ("FREF", 131): "HELL Document File Reference with Local Icon 1",
    ("MENU", 1): "Apple Menu",
    ("PICT", 128): "Hellcats Color About-Dialog Background Artwork",
    ("PICT", 129): "Hellcats Monochrome About-Dialog Background Artwork",
    ("PICT", 130): "Refueling Ground-Crew Photograph",
    ("PICT", 131): "Hellcats About and Credits Scroll Picture",
    ("PICT", 1000): "Copy Protection Instructions Picture",
    ("TEXT", 128): "Two CODE-Referenced 32-Bit Values and Eight ASCII Zeroes",
    ("ICN#", 128): "Hellcats Application 32×32 Monochrome Icon and Mask",
    ("ICN#", 129): "Hellcats Document 32×32 Monochrome Icon and Mask",
    ("ICON", 128): "Hellcats 32×32 Monochrome Application Icon",
    ("icI4", 128): "Hellcats Application 32×32 4-Bit Indexed Icon",
    ("icI4", 129): "Hellcats Document 32×32 4-Bit Indexed Icon",
    ("icI8", 128): "Hellcats Application 32×32 8-Bit Indexed Icon",
    ("icI8", 129): "Hellcats Document 32×32 8-Bit Indexed Icon",
    ("ics#", 128): "Hellcats Application 16×16 Monochrome Icon and Mask",
    ("ics#", 129): "Hellcats Document 16×16 Monochrome Icon and Mask",
    ("ics4", 128): "Hellcats Application 16×16 4-Bit Indexed Icon",
    ("ics4", 129): "Hellcats Document 16×16 4-Bit Indexed Icon",
    ("ics8", 128): "Hellcats Application 16×16 8-Bit Indexed Icon",
    ("ics8", 129): "Hellcats Document 16×16 8-Bit Indexed Icon",
    ("cicn", 256): "Gold-Stripe Shoulder Rank Insignia Color Icon",
    ("cicn", 257): "Silver-Stripe Shoulder Rank Insignia Color Icon",
    ("cicn", 258): "Outlined Blue Shoulder Rank Insignia Color Icon",
    ("cicn", 259): "Gold Starburst Rank Insignia Color Icon",
    ("cicn", 260): "Silver Starburst Rank Insignia Color Icon",
    ("cicn", 261): "Naval Aviator Wings Color Icon",
    ("cicn", 512): "Yellow–Red–Blue Service Ribbon Color Icon",
    ("cicn", 513): "Striped Service Ribbon Color Icon",
    ("cicn", 514): "Black–Yellow–Red Service Ribbon Color Icon",
    ("cicn", 515): "Yellow–Blue–Red Service Ribbon Color Icon",
    ("cicn", 516): "Red Diamond Service Ribbon Color Icon",
    ("cicn", 517): "Yellow–Green Service Ribbon Color Icon",
    ("cicn", 518): "Blue Two-Star Service Ribbon Color Icon",
    ("cicn", 519): "Red–Blue Zigzag Service Ribbon Color Icon",
}

INFERRED_IDENTITIES = {("cicn", rid) for rid in range(256, 262)} | {
    ("cicn", rid) for rid in range(512, 520)
} | {(typ, rid) for typ in ("ICON", "icI4", "icI8", "ics#", "ics4", "ics8")
     for rid in ((128, 129) if typ != "ICON" else (128,))} | {
    ("PICT", rid) for rid in (128, 129, 130, 131, 1000)
}


class DecodeError(ValueError):
    pass


def u16(b: bytes, o: int) -> int:
    if o + 2 > len(b):
        raise DecodeError(f"u16 at {o:#x} exceeds {len(b)} bytes")
    return struct.unpack_from(">H", b, o)[0]


def i16(b: bytes, o: int) -> int:
    if o + 2 > len(b):
        raise DecodeError(f"i16 at {o:#x} exceeds {len(b)} bytes")
    return struct.unpack_from(">h", b, o)[0]


def u32(b: bytes, o: int) -> int:
    if o + 4 > len(b):
        raise DecodeError(f"u32 at {o:#x} exceeds {len(b)} bytes")
    return struct.unpack_from(">I", b, o)[0]


def rect(b: bytes, o: int = 0) -> dict[str, int]:
    top, left, bottom, right = (i16(b, o + n) for n in (0, 2, 4, 6))
    return {
        "top": top, "left": left, "bottom": bottom, "right": right,
        "width": right - left, "height": bottom - top,
    }


def pstring(b: bytes, o: int) -> tuple[str, int, str]:
    if o >= len(b):
        raise DecodeError(f"Pascal string length at {o:#x} exceeds data")
    n = b[o]
    if o + 1 + n > len(b):
        raise DecodeError(f"Pascal string at {o:#x} is truncated")
    raw = b[o + 1:o + 1 + n]
    return raw.decode("mac_roman"), o + 1 + n, raw.hex()


def base_decode(fmt: str, size: int) -> dict[str, Any]:
    return {"format": fmt, "consumed_bytes": size, "trailing_bytes": 0,
            "properties": {}, "elements": []}


def decode_alrt(b: bytes) -> dict[str, Any]:
    if len(b) != 12:
        raise DecodeError("ALRT must be 12 bytes")
    d = base_decode("Classic Macintosh AlertTemplate", 12)
    d["properties"] = {"bounds": rect(b), "ditl_id": i16(b, 8),
                       "stage_word": f"0x{u16(b, 10):04X}",
                       "stages": [(u16(b, 10) >> s) & 15 for s in (12, 8, 4, 0)]}
    return d


def decode_dlog(b: bytes) -> dict[str, Any]:
    if len(b) < 21:
        raise DecodeError("DLOG shorter than fixed template plus title")
    title, end, raw = pstring(b, 20)
    d = base_decode("Classic Macintosh DialogTemplate", end)
    d["trailing_bytes"] = len(b) - end
    d["properties"] = {
        "bounds": rect(b), "window_procedure_id": u16(b, 8),
        "visible": bool(b[10]), "go_away_box": bool(b[12]),
        "refcon": u32(b, 14), "ditl_id": i16(b, 18), "title": title,
        "title_bytes_hex": raw,
    }
    return d


DITL_TYPES = {0: "user_item", 4: "button", 5: "checkbox", 6: "radio_button",
              8: "static_text", 16: "editable_text", 32: "icon", 64: "picture"}

DITL_ITEM_IDENTITIES = {
    (137, 2): "live heading/range custom display region",
    (137, 5): "live heading value field",
    (137, 6): "live range value field",
    (137, 7): "live scale value field",
    (137, 8): "mission map custom drawing region",
    (137, 15): "zoom-in plus-symbol label",
    (137, 16): "zoom-out minus-symbol label",
}


def decode_ditl(b: bytes, rid: int | None = None) -> dict[str, Any]:
    if len(b) < 2:
        raise DecodeError("DITL lacks count")
    count = u16(b, 0) + 1
    off = 2
    items = []
    incomplete = None
    for index in range(1, count + 1):
        start = off
        if off + 14 > len(b):
            incomplete = {"index": index, "offset": start, "status": "TRUNCATED",
                          "available_bytes_hex": b[start:].hex(),
                          "minimum_missing_bytes": off + 14 - len(b)}
            items.append(incomplete)
            off = len(b)
            break
        reserved = u32(b, off)
        bounds = rect(b, off + 4)
        type_byte = b[off + 12]
        data_len = b[off + 13]
        data_start = off + 14
        data_end = data_start + data_len
        if data_end > len(b):
            raise DecodeError(f"DITL item {index} data truncated")
        raw = b[data_start:data_end]
        kind_code = type_byte & 0x7F
        item: dict[str, Any] = {
            "index": index, "offset": start, "reserved_handle": reserved,
            "bounds": bounds, "type_byte": f"0x{type_byte:02X}",
            "type_code": kind_code, "item_type": DITL_TYPES.get(kind_code, "unknown"),
            "enabled": not bool(type_byte & 0x80), "data_length": data_len,
            "data_hex": raw.hex(),
        }
        if kind_code in (4, 5, 6, 8, 16):
            item["text"] = raw.decode("mac_roman")
            item["placeholders"] = re.findall(r"\^[0-9]", item["text"])
        elif kind_code in (32, 64) and data_len == 2:
            item["referenced_resource_id"] = int.from_bytes(raw, "big", signed=True)
            item["referenced_resource_type"] = "ICON" if kind_code == 32 else "PICT"
        default_identity = item.get("text") or {
            "user_item": "custom drawing region", "editable_text": "editable text field",
            "static_text": "dynamic or empty static text field", "picture": "picture item",
            "icon": "icon item",
        }.get(item["item_type"], item["item_type"].replace("_", " "))
        item["descriptive_identity"] = DITL_ITEM_IDENTITIES.get((rid, index), default_identity)
        item["alignment"] = "word_aligned"
        item["padding_bytes"] = 1 if data_end & 1 else 0
        items.append(item)
        off = data_end + (data_end & 1)
    d = base_decode("Classic Macintosh Dialog Item List", off)
    d["trailing_bytes"] = len(b) - off
    d["properties"] = {"encoded_count_minus_one": u16(b, 0), "item_count": count,
                       "decoded_item_count": count if incomplete is None else count - 1,
                       "parse_complete": incomplete is None,
                       "structure_status": "verified" if incomplete is None else "partial_truncated"}
    d["elements"] = items
    return d


def decode_cntl(b: bytes) -> dict[str, Any]:
    if len(b) < 23:
        raise DecodeError("CNTL is shorter than template")
    title, end, raw = pstring(b, 22)
    d = base_decode("Classic Macintosh ControlTemplate", end)
    d["trailing_bytes"] = len(b) - end
    d["properties"] = {
        "bounds": rect(b), "initial_value": i16(b, 8), "visible": bool(b[10]),
        "fill_byte": b[11], "maximum": i16(b, 12), "minimum": i16(b, 14),
        "procedure_id": i16(b, 16), "refcon": u32(b, 18), "title": title,
        "title_bytes_hex": raw,
    }
    return d


MENU_HANDLERS: dict[tuple[int, int], tuple[str, str]] = {
    (1, 1): ("show About Hellcats dialog through CODE 0 jump-table entry A5+$162", "INFERRED"),
    (2, 1): ("call segment-8 entry A5+$1DA, then unload CODE 8 and CODE 5", "VERIFIED"),
    (2, 2): ("write dirty HEL1:127 settings resource", "VERIFIED"),
    (2, 4): ("start new mission selection/session helper at CODE 2 offset $35E4", "VERIFIED"),
    (2, 5): ("show mission status/summary through CODE 0 entry A5+$DA", "VERIFIED"),
    (2, 6): ("show mission map through CODE 0 entry A5+$10A", "VERIFIED"),
    (2, 7): ("resume flight session at CODE 2 offset $04FC", "VERIFIED"),
    (2, 8): ("set instant-replay flag A5-$12F0 and run flight session", "VERIFIED"),
    (2, 9): ("confirm end mission, reset mission selector, and hide main window", "VERIFIED"),
    (2, 11): ("show high scores through CODE 0 entry A5+$102", "VERIFIED"),
    (2, 13): ("quit application through CODE 2 offset $2EAA", "VERIFIED"),
    (4, 1): ("toggle bit 0 of HEL1:127 byte +3 (Sound)", "VERIFIED"),
    (4, 2): ("toggle bit 0 of HEL1:127 byte +5 (Engine Sound)", "VERIFIED"),
    (4, 4): ("toggle bit 0 of live option byte A5-$102F (Triple Time)", "VERIFIED"),
    (4, 5): ("toggle bit 0 of HEL1:127 byte +7 (Cockpit Views Pan)", "VERIFIED"),
    (4, 6): ("toggle bit 0 of HEL1:127 byte +9 (One line Instruments)", "VERIFIED"),
    (4, 8): ("set HEL1:127 view-size word +$0E to 1 (Full Screen)", "VERIFIED"),
    (4, 9): ("set HEL1:127 view-size word +$0E to 3 (3/4 Height)", "VERIFIED"),
    (4, 10): ("set HEL1:127 view-size word +$0E to 2 (1/2 Height)", "VERIFIED"),
    (5, 1): ("set HEL1:127 detail word +$10 to 1", "VERIFIED"),
    (5, 2): ("set HEL1:127 detail word +$10 to 2", "VERIFIED"),
    (5, 3): ("set HEL1:127 detail word +$10 to 3", "VERIFIED"),
    (5, 4): ("set HEL1:127 detail word +$10 to 4", "VERIFIED"),
    (5, 5): ("set HEL1:127 detail word +$10 to 5", "VERIFIED"),
    (5, 7): ("toggle bit 0 of HEL1:127 byte +$13 (Haze)", "VERIFIED"),
    (5, 8): ("toggle bit 0 of HEL1:127 byte +$17 (Clouds)", "VERIFIED"),
    (5, 9): ("toggle bit 0 of HEL1:127 byte +$15 (Ground Clutter)", "VERIFIED"),
    (5, 10): ("toggle bit 0 of HEL1:127 byte +$19 (Shadows)", "VERIFIED"),
    (5, 11): ("toggle bit 0 of HEL1:127 byte +$1B (Real Time Shading)", "VERIFIED"),
}


def decode_menu(b: bytes, rid: int | None = None) -> dict[str, Any]:
    if len(b) < 15:
        raise DecodeError("MENU shorter than header")
    title, off, title_raw = pstring(b, 14)
    items = []
    index = 1
    while off < len(b):
        if b[off] == 0:
            off += 1
            break
        text, end, raw = pstring(b, off)
        if end + 4 > len(b):
            raise DecodeError(f"MENU item {index} attributes truncated")
        icon, key, mark, style = b[end:end + 4]
        items.append({"index": index, "text": text, "text_bytes_hex": raw,
                      "separator": text == "-", "icon_number": icon,
                      "keyboard_equivalent": chr(key) if 32 <= key < 127 else None,
                      "keyboard_byte": key, "mark_or_submenu": mark, "style": style})
        index += 1
        off = end + 4
    flags = u32(b, 10)
    for item in items:
        item["enabled"] = bool(flags & (1 << item["index"]))
        if item["separator"]:
            item["command_handler"] = "no action (separator)"
            item["command_handler_status"] = "VERIFIED"
        elif rid == 3:
            item["command_handler"] = f"SystemEdit({item['index'] - 1}); SysBeep(5) if unhandled"
            item["command_handler_status"] = "VERIFIED"
        elif (rid, item["index"]) in MENU_HANDLERS:
            handler, status = MENU_HANDLERS[(rid, item["index"])]
            item["command_handler"] = handler
            item["command_handler_status"] = status
        else:
            item["command_handler"] = None
            item["command_handler_status"] = "UNKNOWN"
    d = base_decode("Classic Macintosh Menu Resource", off)
    d["trailing_bytes"] = len(b) - off
    d["properties"] = {"menu_id": i16(b, 0), "width": i16(b, 2),
                       "height": i16(b, 4), "menu_definition_proc": u32(b, 6),
                       "enable_flags": f"0x{flags:08X}", "title": title,
                       "title_bytes_hex": title_raw, "item_count": len(items)}
    d["elements"] = items
    return d


def decode_strlist(b: bytes) -> dict[str, Any]:
    count = u16(b, 0)
    off = 2
    strings = []
    for index in range(1, count + 1):
        text, off, raw = pstring(b, off)
        strings.append({"index": index, "text": text, "bytes_hex": raw,
                        "placeholders": re.findall(r"\^[0-9]|%[a-zA-Z]", text)})
    d = base_decode("Classic Macintosh String List", off)
    d["trailing_bytes"] = len(b) - off
    d["properties"] = {"string_count": count, "encoding": "mac_roman"}
    d["elements"] = strings
    return d


def decode_text(b: bytes) -> dict[str, Any]:
    text = b.decode("mac_roman")
    d = base_decode("MacRoman Text Resource", len(b))
    d["properties"] = {"text": text, "encoding": "mac_roman",
                       "line_ending": "CR" if "\r" in text and "\n" not in text else "none_or_mixed",
                       "line_count": text.count("\r") + 1}
    return d


def decode_styl(b: bytes) -> dict[str, Any]:
    count = u16(b, 0)
    expected = 2 + count * 20
    if len(b) < expected:
        raise DecodeError("styl records truncated")
    runs = []
    faces = [(1, "bold"), (2, "italic"), (4, "underline"), (8, "outline"),
             (16, "shadow"), (32, "condense"), (64, "extend")]
    for i in range(count):
        o = 2 + i * 20
        face = b[o + 10]
        runs.append({"index": i + 1, "start_character": u32(b, o),
                     "line_height": u16(b, o + 4), "font_ascent": u16(b, o + 6),
                     "font_id": u16(b, o + 8), "face_bits": f"0x{face:02X}",
                     "faces": [name for bit, name in faces if face & bit],
                     "font_size": u16(b, o + 12),
                     "rgb16": [u16(b, o + 14), u16(b, o + 16), u16(b, o + 18)]})
    d = base_decode("Classic Macintosh TextStyle Resource", expected)
    d["trailing_bytes"] = len(b) - expected
    d["properties"] = {"style_run_count": count}
    d["elements"] = runs
    return d


def decode_vers(b: bytes) -> dict[str, Any]:
    if len(b) < 8:
        raise DecodeError("vers header truncated")
    short, off, short_raw = pstring(b, 6)
    long, end, long_raw = pstring(b, off)
    major = b[0]
    minor_bug = b[1]
    stages = {0x20: "development", 0x40: "alpha", 0x60: "beta", 0x80: "final"}
    d = base_decode("Classic Macintosh Version Resource", end)
    d["trailing_bytes"] = len(b) - end
    d["properties"] = {
        "major": major, "minor": minor_bug >> 4, "bugfix": minor_bug & 15,
        "version": f"{major}.{minor_bug >> 4}.{minor_bug & 15}",
        "stage_code": f"0x{b[2]:02X}", "stage": stages.get(b[2], "unknown"),
        "non_release_revision": b[3], "region_code": u16(b, 4),
        "short_string": short, "long_string": long,
        "short_bytes_hex": short_raw, "long_bytes_hex": long_raw,
    }
    return d


def decode_size(b: bytes) -> dict[str, Any]:
    if len(b) != 10:
        raise DecodeError("SIZE must be 10 bytes")
    flags = u16(b, 0)
    names = {0x8000: "save_screen", 0x4000: "accept_suspend_resume_events",
             0x2000: "disable_option", 0x1000: "can_background",
             0x0800: "multi_finder_aware", 0x0400: "background_only",
             0x0200: "dont_get_front_click", 0x0100: "ignore_child_died_events",
             0x0080: "is_32_bit_compatible", 0x0040: "high_level_event_aware",
             0x0020: "local_and_remote_high_level_events", 0x0010: "stationery_aware",
             0x0008: "use_text_edit_services", 0x0004: "reserved_0x0004",
             0x0002: "reserved_0x0002", 0x0001: "reserved_0x0001"}
    d = base_decode("Classic Macintosh SIZE Resource", 10)
    d["properties"] = {"flags_word": f"0x{flags:04X}",
                       "set_flags": [v for k, v in names.items() if flags & k],
                       "preferred_memory_bytes": u32(b, 2), "minimum_memory_bytes": u32(b, 6)}
    return d


def decode_fref(b: bytes) -> dict[str, Any]:
    if len(b) < 7:
        raise DecodeError("FREF shorter than seven bytes")
    name, end, raw = pstring(b, 6)
    d = base_decode("Classic Macintosh File Reference", end)
    d["trailing_bytes"] = len(b) - end
    d["properties"] = {"file_type": b[:4].decode("mac_roman"),
                       "local_icon_id": i16(b, 4), "filename": name,
                       "filename_bytes_hex": raw}
    return d


def decode_bndl(b: bytes) -> dict[str, Any]:
    if len(b) < 8:
        raise DecodeError("BNDL header truncated")
    count = u16(b, 6) + 1
    off = 8
    groups = []
    for gi in range(count):
        if off + 6 > len(b):
            raise DecodeError(f"BNDL group {gi + 1} truncated")
        typ = b[off:off + 4].decode("mac_roman")
        n = u16(b, off + 4) + 1
        off += 6
        mappings = []
        for _ in range(n):
            mappings.append({"local_id": i16(b, off), "resource_id": i16(b, off + 2)})
            off += 4
        groups.append({"resource_type": typ, "mapping_count": n, "mappings": mappings})
    d = base_decode("Classic Macintosh Bundle Resource", off)
    d["trailing_bytes"] = len(b) - off
    d["properties"] = {"creator_code": b[:4].decode("mac_roman"),
                       "bundle_version": u16(b, 4), "mapping_group_count": count}
    d["elements"] = groups
    return d


def decode_clut(b: bytes) -> dict[str, Any]:
    if len(b) < 8:
        raise DecodeError("clut header truncated")
    count = u16(b, 6) + 1
    expected = 8 + 8 * count
    if len(b) < expected:
        raise DecodeError("clut color entries truncated")
    colors = []
    for i in range(count):
        o = 8 + 8 * i
        rgb16 = [u16(b, o + 2), u16(b, o + 4), u16(b, o + 6)]
        rgb8 = [round(v * 255 / 65535) for v in rgb16]
        colors.append({"entry": i, "value": u16(b, o), "rgb16": rgb16,
                       "rgb8": rgb8, "hex_rgb8": "#" + "".join(f"{v:02X}" for v in rgb8)})
    d = base_decode("Macintosh ColorTable", expected)
    d["trailing_bytes"] = len(b) - expected
    d["properties"] = {"seed": u32(b, 0), "flags": f"0x{u16(b, 4):04X}",
                       "encoded_size_minus_one": u16(b, 6), "color_count": count}
    d["elements"] = colors
    return d


def decode_icon(b: bytes, typ: str) -> dict[str, Any]:
    specs = {"ICON": (32, 32, 1, False), "ICN#": (32, 32, 1, True),
             "icI4": (32, 32, 4, False), "icI8": (32, 32, 8, False),
             "ics#": (16, 16, 1, True), "ics4": (16, 16, 4, False),
             "ics8": (16, 16, 8, False)}
    w, h, depth, has_mask = specs[typ]
    expected = w * h * depth // 8 * (2 if has_mask else 1)
    if len(b) != expected:
        raise DecodeError(f"{typ} expected {expected} bytes, got {len(b)}")
    d = base_decode("Classic Macintosh Icon Bitmap", len(b))
    d["properties"] = {"width": w, "height": h, "depth_bits": depth,
                       "has_embedded_mask": has_mask,
                       "pixel_data_bytes": w * h * depth // 8,
                       "mask_data_bytes": w * h // 8 if has_mask else 0,
                       "palette_reference": None}
    return d


def decode_cicn(b: bytes) -> dict[str, Any]:
    """Decode the serialized CIcon container and all embedded palette entries."""
    if len(b) < 90:
        raise DecodeError("cicn shorter than CIcon header and color table")
    pixel_row_bytes = u16(b, 4) & 0x3FFF
    bounds = rect(b, 6)
    depth = u16(b, 32)
    mask_row_bytes = u16(b, 54) & 0x3FFF
    mask_bounds = rect(b, 56)
    bitmap_row_bytes = u16(b, 68) & 0x3FFF
    bitmap_bounds = rect(b, 70)
    mask_size = mask_row_bytes * mask_bounds["height"]
    bitmap_size = bitmap_row_bytes * bitmap_bounds["height"]
    mask_offset = 82
    bitmap_offset = mask_offset + mask_size
    color_table_offset = bitmap_offset + bitmap_size
    if color_table_offset + 8 > len(b):
        raise DecodeError("cicn mask/bitmap data exceeds payload")
    color_count = u16(b, color_table_offset + 6) + 1
    color_table_size = 8 + color_count * 8
    pixel_offset = color_table_offset + color_table_size
    pixel_size = pixel_row_bytes * bounds["height"]
    end = pixel_offset + pixel_size
    if end > len(b):
        raise DecodeError("cicn indexed pixel data is truncated")
    colors = []
    for i in range(color_count):
        o = color_table_offset + 8 + i * 8
        rgb16 = [u16(b, o + 2), u16(b, o + 4), u16(b, o + 6)]
        rgb8 = [round(v * 255 / 65535) for v in rgb16]
        colors.append({"kind": "palette_entry", "entry": i, "value": u16(b, o),
                       "rgb16": rgb16, "rgb8": rgb8,
                       "hex_rgb8": "#" + "".join(f"{v:02X}" for v in rgb8)})
    d = base_decode("Classic Macintosh Color Icon", end)
    d["trailing_bytes"] = len(b) - end
    d["properties"] = {
        "bounds": bounds, "width": bounds["width"], "height": bounds["height"],
        "depth_bits": depth, "pixel_row_bytes": pixel_row_bytes,
        "component_count": u16(b, 34), "component_size_bits": u16(b, 36),
        "pack_type": u16(b, 16), "pack_size": u32(b, 18),
        "horizontal_resolution_fixed": f"0x{u32(b, 22):08X}",
        "vertical_resolution_fixed": f"0x{u32(b, 26):08X}",
        "mask_bounds": mask_bounds, "mask_row_bytes": mask_row_bytes,
        "bitmap_bounds": bitmap_bounds, "bitmap_row_bytes": bitmap_row_bytes,
        "mask_data_offset": mask_offset, "mask_data_bytes": mask_size,
        "monochrome_bitmap_offset": bitmap_offset, "monochrome_bitmap_bytes": bitmap_size,
        "color_table_offset": color_table_offset, "color_table_seed": u32(b, color_table_offset),
        "color_table_flags": f"0x{u16(b, color_table_offset + 4):04X}",
        "color_count": color_count, "indexed_pixel_data_offset": pixel_offset,
        "indexed_pixel_data_bytes": pixel_size,
    }
    d["elements"] = colors
    return d


def compare_cicn_png(b: bytes, decoded: dict[str, Any], png: Path) -> dict[str, Any]:
    try:
        from PIL import Image
    except ImportError:
        return {"status": "not_run", "reason": "Pillow is unavailable"}
    p = decoded["properties"]
    colors = {e["value"]: tuple(e["rgb8"]) for e in decoded["elements"]}
    depth, row_bytes = p["depth_bits"], p["pixel_row_bytes"]
    width, height = p["width"], p["height"]
    off = p["indexed_pixel_data_offset"]
    raw = b[off:off + row_bytes * height]
    expected = []
    for y in range(height):
        row = raw[y * row_bytes:(y + 1) * row_bytes]
        for x in range(width):
            if depth == 4:
                index = (row[x // 2] >> (4 if x % 2 == 0 else 0)) & 15
            elif depth == 2:
                index = (row[x // 4] >> (6 - 2 * (x % 4))) & 3
            else:
                return {"status": "not_run", "reason": f"unsupported comparison depth {depth}"}
            expected.append(colors.get(index, (0, 0, 0)))
    image = Image.open(png).convert("RGB")
    actual = list(image.get_flattened_data() if hasattr(image, "get_flattened_data") else image.getdata())
    differing = sum(a != e for a, e in zip(actual, expected))
    if image.size != (width, height):
        differing += abs(len(actual) - len(expected))
    return {"status": "pixel_exact" if differing == 0 else "mismatch",
            "png_path": str(png.relative_to(ROOT)), "png_dimensions": list(image.size),
            "compared_pixels": min(len(actual), len(expected)), "differing_pixels": differing,
            "comparison": "decoded indexed pixels mapped through embedded cicn ColorTable versus PNG RGB pixels"}


CLUT4 = [(0xFFFF, 0xFFFF, 0xFFFF), (0xFC00, 0xF37D, 0x052F), (0xFFFF, 0x648A, 0x028C), (0xDD6B, 0x08C2, 0x06A2),
         (0xF2D7, 0x0856, 0x84EC), (0x46E3, 0x0000, 0xA53E), (0x0000, 0x0000, 0xD400), (0x0241, 0xAB54, 0xEAFF),
         (0x1F21, 0xB793, 0x1431), (0x0000, 0x64AF, 0x11B0), (0x5600, 0x2C9D, 0x0524), (0x90D7, 0x7160, 0x3A34),
         (0xC000, 0xC000, 0xC000), (0x8000, 0x8000, 0x8000), (0x4000, 0x4000, 0x4000), (0x0000, 0x0000, 0x0000)]


def clut8() -> list[tuple[int, int, int]]:
    """The System's default 8-bit table: the 6 x 6 x 6 cube from white without black (0..214), the
    ten-step red, green, blue and grey ramps (215..254), black (255)."""
    levels = (0xFF, 0xCC, 0x99, 0x66, 0x33, 0x00)
    out = [(r, g, b) for r in levels for g in levels for b in levels][:215]
    ramp = (0xEE, 0xDD, 0xBB, 0xAA, 0x88, 0x77, 0x55, 0x44, 0x22, 0x11)
    out += [(v, 0, 0) for v in ramp] + [(0, v, 0) for v in ramp] + [(0, 0, v) for v in ramp] + [(v, v, v) for v in ramp]
    return out + [(0, 0, 0)]


def compare_indexed_icon_png(b: bytes, typ: str, png: Path) -> dict[str, Any]:
    """An icl4 / icl8 / ics4 / ics8 icon's indices through the System's default 4- or 8-bit table
    (as the Finder draws them) against its PNG export; pixels the export leaves transparent (its
    family's mask) are not compared."""
    try:
        from PIL import Image
    except ImportError:
        return {"status": "not_run", "reason": "Pillow is unavailable"}
    size, depth = (32 if typ in ("icI4", "icI8") else 16), (4 if typ.endswith("4") else 8)
    table = [tuple(c >> 8 for c in rgb) for rgb in CLUT4] if depth == 4 else clut8()
    image = Image.open(png).convert("RGBA")
    data = image.get_flattened_data() if hasattr(image, "get_flattened_data") else image.getdata()
    pixels = list(data)
    if pixels and not isinstance(pixels[0], tuple):
        pixels = [tuple(pixels[k:k + 4]) for k in range(0, len(pixels), 4)]
    differing, transparent, indices = 0, 0, set()
    for k in range(size * size):
        bit = k * depth
        value = (b[bit // 8] >> (8 - depth - bit % 8)) & ((1 << depth) - 1)
        if pixels[k][3] == 0:
            transparent += 1
        elif pixels[k][:3] != table[value]:
            differing += 1
            indices.add(value)
    return {"status": "pixel_exact" if differing == 0 and image.size == (size, size) else "mismatch",
            "png_path": str(png.relative_to(ROOT)), "png_dimensions": list(image.size),
            "palette": f"System default clut {depth}", "compared_pixels": size * size - transparent,
            "transparent_pixels_not_compared": transparent, "differing_pixels": differing,
            "differing_indices": sorted(indices),
            "comparison": "indices through the default colour table versus PNG pixels"}


def compare_monochrome_icon_png(b: bytes, decoded: dict[str, Any], png: Path) -> dict[str, Any]:
    try:
        from PIL import Image
    except ImportError:
        return {"status": "not_run", "reason": "Pillow is unavailable"}
    p = decoded["properties"]
    width, height = p["width"], p["height"]
    pixel_size = p["pixel_data_bytes"]
    row_bytes = width // 8
    image = Image.open(png)
    has_alpha = "A" in image.mode and p["has_embedded_mask"]
    mode = "RGBA" if has_alpha else "RGB"
    actual = list((image.convert(mode).get_flattened_data()
                   if hasattr(image.convert(mode), "get_flattened_data")
                   else image.convert(mode).getdata()))
    expected = []
    for y in range(height):
        for x in range(width):
            bit = bool(b[y * row_bytes + x // 8] & (1 << (7 - x % 8)))
            if has_alpha and p["has_embedded_mask"]:
                mask = bool(b[pixel_size + y * row_bytes + x // 8] & (1 << (7 - x % 8)))
                expected.append((0, 0, 0, 255) if bit and mask else (0, 0, 0, 0))
            else:
                expected.append((0, 0, 0) if bit else (255, 255, 255))
    differing = sum(a != e for a, e in zip(actual, expected))
    if image.size != (width, height):
        differing += abs(len(actual) - len(expected))
    return {"status": "pixel_exact" if differing == 0 else "mismatch",
            "png_path": str(png.relative_to(ROOT)), "png_dimensions": list(image.size),
            "compared_pixels": min(len(actual), len(expected)), "differing_pixels": differing,
            "comparison": "decoded 1-bit icon pixels (and mask for alpha exports) versus PNG pixels"}


def decode_drel(b: bytes) -> dict[str, Any]:
    if len(b) % 2:
        raise DecodeError("DREL length is not word-aligned")
    offsets = [u16(b, o) for o in range(0, len(b), 2)]
    d = base_decode("Hellcats A5 World Relocation Offset Table", len(b))
    d["properties"] = {"entry_count": len(offsets), "entry_width_bytes": 2,
                       "byte_order": "big_endian", "minimum_offset": min(offsets),
                       "maximum_offset": max(offsets)}
    d["elements"] = [{"index": i + 1, "a5_world_offset": value} for i, value in enumerate(offsets)]
    return d


def decode_hel1(b: bytes, rid: int) -> dict[str, Any]:
    if rid == 128:
        if len(b) % 64:
            raise DecodeError("HEL1 128 is not divisible into 64-byte records")
        records = []
        for i in range(len(b) // 64):
            raw = b[i * 64:(i + 1) * 64]
            name_raw = raw[:30].split(b"\0", 1)[0]
            records.append({"index": i + 1, "offset": i * 64,
                            "pilot_name": name_raw.decode("mac_roman"),
                            "status_word_at_0x20": u16(raw, 0x20),
                            "tally_long_at_0x28": u32(raw, 0x28),
                            "nonzero_byte_count": sum(x != 0 for x in raw),
                            "record_sha256": hashlib.sha256(raw).hexdigest()})
        d = base_decode("Hellcats Player and Score Data Record Array", len(b))
        d["properties"] = {"record_count": len(records), "record_size_bytes": 64,
                           "name_field_offset": 0, "name_field_size_bytes": 30,
                           "status_field_offset": 32, "tally_field_offset": 40}
        d["elements"] = records
        return d
    if rid == 127:
        d = base_decode("Hellcats Saved Settings Record", len(b))
        strings = []
        for o, n in enumerate(b):
            if 4 <= n <= 63 and o + 1 + n <= len(b):
                raw = b[o + 1:o + 1 + n]
                if all(32 <= x < 127 for x in raw):
                    strings.append({"kind": "embedded_pascal_string", "offset": o,
                                    "length": n, "text": raw.decode("mac_roman")})
        d["properties"] = {"record_size_bytes": len(b),
                           "field_layout_status": "partially_verified_from_CODE"}
        d["elements"] = strings
        return d
    raise DecodeError(f"unsupported HEL1 id {rid}")


def decode_word_stream(b: bytes, fmt: str) -> dict[str, Any]:
    if len(b) % 2:
        raise DecodeError(f"{fmt} is not word-aligned")
    values = [u16(b, o) for o in range(0, len(b), 2)]
    d = base_decode(fmt, len(b))
    d["properties"] = {"word_count": len(values), "word_width_bytes": 2,
                       "byte_order": "big_endian", "field_semantics": "partially_unresolved"}
    d["elements"] = [{"index": i + 1, "offset": i * 2, "u16_be": value}
                     for i, value in enumerate(values)]
    return d


def decode_zero0(b: bytes) -> dict[str, Any]:
    """ZERO 0: one word per zero word of DATA 0, the count of further zero bytes after it (CODE 1
    0x34, the C runtime's start-up: MOVE.W (A2)+,D1, then D1 times CLR.B (A1)+ by DBF)."""
    d = decode_word_stream(b, "Hellcats A5 World Zero-Run Initialization Word Stream")
    d["properties"].update({"field_semantics": "verified", "zero_byte_total": sum(e["u16_be"] for e in d["elements"]),
                            "meaning": "zero bytes following each zero word of DATA 0, in order",
                            "consumer": "CODE 1 0x34 (C runtime start-up)"})
    return d


def decode_data0(b: bytes) -> dict[str, Any]:
    """DATA 0: the application globals below A5, compressed. CODE 1 0x34 copies its words from
    CurStackBase up (MOVE.W (A0)+,(A1)+); after each zero word it clears as many more bytes as
    the next word of ZERO 0 says, until A1 reaches A5. With ZERO 0 and CODE 0's below-A5 size the
    expansion is checked to end exactly at A5; each element is a run: copied words, or a zero run,
    with its A5 offset."""
    if len(b) % 2:
        raise DecodeError("DATA 0 is not word-aligned")
    words = [u16(b, o) for o in range(0, len(b), 2)]
    zero = (RESEDIT / "ZERO" / "0.bin").read_bytes()
    runs = [u16(zero, o) for o in range(0, len(zero), 2)]
    below = u32((RESEDIT / "CODE" / "ID00.bin").read_bytes(), 4)
    if words.count(0) != len(runs):
        raise DecodeError(f"DATA 0 has {words.count(0)} zero words for {len(runs)} ZERO 0 entries")
    elements, at, z, start = [], -below, 0, 0
    for i, w in enumerate(words):
        if w == 0:
            if i + 1 > start:
                elements.append({"index": len(elements) + 1, "kind": "words", "data_offset": 2 * start,
                                 "a5_offset": at - 2 * (i + 1 - start) + 2, "byte_count": 2 * (i + 1 - start)})
            at += 2
            elements.append({"index": len(elements) + 1, "kind": "zero_run", "zero_entry": z + 1,
                             "a5_offset": at, "byte_count": runs[z]})
            at += runs[z]
            z += 1
            start = i + 1
        else:
            at += 2
    if start < len(words):
        elements.append({"index": len(elements) + 1, "kind": "words", "data_offset": 2 * start,
                         "a5_offset": at - 2 * (len(words) - start), "byte_count": 2 * (len(words) - start)})
    if at != 0:
        raise DecodeError(f"DATA 0 with ZERO 0 expands to A5 {at:+#x}, not to A5")
    d = base_decode("Hellcats A5 World Compressed Initializer Data", len(b))
    d["properties"] = {"word_count": len(words), "zero_word_count": len(runs), "byte_order": "big_endian",
                       "expanded_bytes": below, "expands_from_a5_offset": -below,
                       "zero_runs_from": "ZERO 0", "consumer": "CODE 1 0x34 (C runtime start-up)",
                       "structure_status": "verified"}
    d["elements"] = elements
    return d


MDPL_DIRECTORY = (0x5C, 0x80, 0x8C, 0xBC, 0xC8, 0xD4)


def decode_mdpl(b: bytes) -> dict[str, Any]:
    """MDPL 128: the layout record of PICT 131's first text object, as the drawing program that
    signed the picture's application comments 'MDPL' (kinds 100, objects 7 and 8) kept it; no game
    code reads it. Proven by the bytes: the size at +4; a directory of (1, offset, length) blocks
    tiling 0x136 to the end, the last naming the text (0x137 characters, not stored here); three
    style records at 0x100 (18 bytes: height, ascent, font, face, size) and the style runs at 0x1c6,
    which match PICT 131's TxFace / TxSize changes at characters 0, 26 and 38 (bold 10, plain 10,
    plain 9, Geneva); the line count at 0x184 with its line starts at 0x188 (hard and wrapped
    breaks; the first 17 equal the picture's, later ones one character on, the picture dropping a
    character) and one (height, ascent) pair per line start up to the end. The header before 0x5c
    and the block at 0x136..0x182 stay uninterpreted."""
    if len(b) != 0x252 or u32(b, 4) != len(b):
        raise DecodeError("MDPL size word does not match its length")
    blocks = [{"index": i + 1, "directory_offset": o, "flag": u32(b, o), "offset": u32(b, o + 4),
               "length": u32(b, o + 8)} for i, o in enumerate(MDPL_DIRECTORY)]
    for prev, nxt in zip(blocks, blocks[1:-1]):
        if prev["offset"] + prev["length"] != nxt["offset"]:
            raise DecodeError("MDPL directory blocks do not tile")
    if blocks[-2]["offset"] + blocks[-2]["length"] != len(b) or blocks[-1]["offset"] != len(b):
        raise DecodeError("MDPL directory does not end at the resource's end")
    styles = [{"index": k + 1, "offset": 0x100 + 0x12 * k, "line_height": u16(b, 0x102 + 0x12 * k),
               "ascent": u16(b, 0x104 + 0x12 * k), "font_id": u16(b, 0x106 + 0x12 * k),
               "face": b[0x108 + 0x12 * k], "size": u16(b, 0x10A + 0x12 * k)} for k in range(3)]
    text_length, lines = u16(b, 0x182), u16(b, 0x184)
    starts = [u16(b, 0x188 + 2 * k) for k in range(lines + 1)]
    runs, o = [], 0x188 + 2 * (lines + 1)
    while u16(b, o + 2) != 0xFFFF:
        runs.append({"start": u16(b, o), "style": u16(b, o + 2)})
        o += 4
    runs_end = u16(b, o)
    o += 4
    metrics = [{"line_height": u16(b, o + 4 * k), "ascent": u16(b, o + 4 * k + 2)} for k in range((len(b) - o) // 4)]
    if text_length != blocks[-1]["length"] or starts[-1] != text_length or len(metrics) != lines + 1 \
            or o + 4 * len(metrics) != len(b):
        raise DecodeError("MDPL line tables are inconsistent")
    d = base_decode("Drawing-Program Text Object Layout (PICT 131's first text block)", len(b))
    d["properties"] = {"size": len(b), "text_length": text_length, "line_count": lines, "line_starts": starts,
                       "style_runs": runs, "style_runs_end": runs_end, "styles": styles, "line_metrics": metrics,
                       "matching_picture": "PICT 131 (application comments 'MDPL' objects 7 and 8)",
                       "game_code_references": 0,
                       "uninterpreted_ranges": ["0x0000-0x005b", "0x0136-0x0181"],
                       "structure_status": "partially_resolved"}
    d["elements"] = blocks
    return d


def decode_data128(b: bytes) -> dict[str, Any]:
    if len(b) < 8:
        raise DecodeError("DATA 128 lacks the two CODE-referenced longs")
    d = base_decode("Hellcats Persistent Two-Long Data Record with Opaque Tail", len(b))
    d["properties"] = {"first_u32_be": u32(b, 0), "second_u32_be": u32(b, 4),
                       "code_verified_field_bytes": 8, "opaque_tail_bytes": len(b) - 8,
                       "opaque_tail_sha256": hashlib.sha256(b[8:]).hexdigest()}
    d["elements"] = [{"index": 1, "offset": 0, "type": "u32_be", "value": u32(b, 0)},
                     {"index": 2, "offset": 4, "type": "u32_be", "value": u32(b, 4)}]
    return d


def decode_text128(b: bytes) -> dict[str, Any]:
    if len(b) < 8:
        raise DecodeError("TEXT 128 lacks the two CODE-referenced longs")
    d = base_decode("Binary TEXT Resource with Two CODE-Referenced Longs", len(b))
    d["properties"] = {"first_u32_be": u32(b, 0), "second_u32_be": u32(b, 4),
                       "code_verified_field_bytes": 8, "trailing_bytes_hex": b[8:].hex(),
                       "text_semantics": "not established"}
    d["elements"] = [{"index": 1, "offset": 0, "type": "u32_be", "value": u32(b, 0)},
                     {"index": 2, "offset": 4, "type": "u32_be", "value": u32(b, 4)}]
    return d


PICT_FIXED = {0x00: 0, 0x02: 8, 0x03: 2, 0x04: 1, 0x05: 2, 0x06: 4, 0x07: 4, 0x08: 2, 0x09: 8, 0x0A: 8,
              0x0B: 4, 0x0C: 4, 0x0D: 2, 0x0E: 4, 0x0F: 4, 0x10: 8, 0x15: 2, 0x16: 2, 0x1A: 6, 0x1B: 6,
              0x1C: 0, 0x1D: 6, 0x1E: 0, 0x1F: 6, 0x20: 8, 0x21: 4, 0x22: 6, 0x23: 2, 0xA0: 2}
for _base, _n in ((0x30, 8), (0x38, 0), (0x40, 8), (0x48, 0), (0x50, 8), (0x58, 0), (0x60, 12), (0x68, 4),
                  (0x78, 0), (0x88, 0)):
    for _k in range(5):
        PICT_FIXED[_base + _k] = _n
PICT_NAMES = {0x00: "NOP", 0x01: "Clip", 0x02: "BkPat", 0x03: "TxFont", 0x04: "TxFace", 0x05: "TxMode",
              0x06: "SpExtra", 0x07: "PnSize", 0x08: "PnMode", 0x09: "PnPat", 0x0A: "FillPat", 0x0B: "OvSize",
              0x0C: "Origin", 0x0D: "TxSize", 0x0E: "FgColor", 0x0F: "BkColor", 0x10: "TxRatio",
              0x11: "Version", 0x1E: "DefHilite", 0x28: "LongText", 0x29: "DHText", 0x2A: "DVText",
              0x2B: "DHDVText", 0x2C: "FontName", 0x2E: "GlyphState", 0x31: "paintRect", 0x90: "BitsRect",
              0x91: "BitsRgn", 0x98: "PackBitsRect", 0x99: "PackBitsRgn", 0xA0: "ShortComment",
              0xA1: "LongComment", 0xFF: "OpEndPic", 0x0C00: "HeaderOp"}


def _pict_pixels(b: bytes, o: int, v2: bool, packed: bool, rgn: bool) -> tuple[int, dict[str, Any]]:
    """(Pack)BitsRect / Rgn: a bitmap (or, in version 2 with rowBytes bit 15, a pixel map and its
    colour table), source and destination rects, mode, the mask region, then the rows (PackBits
    rows carry a byte count, a word one past 250 row bytes; under 8 row bytes rows are unpacked)."""
    rb = u16(b, o)
    pixmap = bool(v2 and rb & 0x8000)
    row_bytes = rb & 0x3FFF
    bounds = rect(b, o + 2)
    rows = struct.unpack(">h", b[o + 6:o + 8])[0] - struct.unpack(">h", b[o + 2:o + 4])[0]
    o += 10
    info: dict[str, Any] = {"pixmap": pixmap, "row_bytes": row_bytes, "bounds": bounds, "rows": rows}
    if pixmap:
        info["pixel_size"] = u16(b, o + 18)
        o += 36
        info["colour_table_entries"] = u16(b, o + 6) + 1
        info["colour_table_offset"] = o
        o += 8 + 8 * info["colour_table_entries"]
    info["source"] = rect(b, o)
    info["destination"] = rect(b, o + 8)
    info["transfer_mode"] = u16(b, o + 16)
    o += 18
    if rgn:
        o += u16(b, o)
    info["row_data_offset"] = o
    if not packed or row_bytes < 8:
        o += rows * row_bytes
    else:
        for _ in range(rows):
            o += (2 + u16(b, o)) if row_bytes > 250 else (1 + b[o])
    return o, info


def decode_pict(b: bytes) -> dict[str, Any]:
    """A QuickDraw picture: size word, frame, then its opcode stream walked to OpEndPic (Inside
    Macintosh: Imaging With QuickDraw, appendix A): version 1 one-byte opcodes, version 2 word
    opcodes on word boundaries. Each opcode is an element with its offset and data length (pixel
    opcodes with their bitmap's layout); the text the text opcodes draw is collected."""
    if len(b) < 10:
        raise DecodeError("PICT header truncated")
    v2 = len(b) >= 14 and u16(b, 10) == 0x0011 and u16(b, 12) == 0x02FF
    o, elements, texts, comments = 10, [], [], []
    while True:
        if o >= len(b):
            raise DecodeError("PICT opcode stream ends without OpEndPic")
        if v2:
            o += o & 1
            op, o = u16(b, o), o + 2
        else:
            op, o = b[o], o + 1
        start = o
        entry: dict[str, Any] = {"index": len(elements) + 1, "offset": start - (2 if v2 else 1),
                                 "opcode": f"0x{op:04X}" if v2 else f"0x{op:02X}", "name": PICT_NAMES.get(op, "")}
        if op == 0xFF:
            entry["length"] = 0
            elements.append(entry)
            break
        if op == 0x11:
            o += 2 if v2 else 1
        elif op == 0x0C00:
            o += 24
        elif op == 0x01 or 0x70 <= op <= 0x74 or 0x80 <= op <= 0x84:
            o += u16(b, o)
        elif op in (0x28, 0x29, 0x2A, 0x2B):
            o += {0x28: 4, 0x29: 1, 0x2A: 1, 0x2B: 2}[op]
            text = b[o + 1:o + 1 + b[o]].decode("mac_roman")
            entry["text"] = text
            texts.append(text)
            o += 1 + b[o]
        elif op in (0x2C, 0x2D, 0x2E):
            if op == 0x2C:
                entry["font_id"] = u16(b, o + 2)
                entry["font_name"] = b[o + 5:o + 5 + b[o + 4]].decode("mac_roman")
            o += 2 + u16(b, o)
        elif op == 0xA0:
            entry["kind"] = u16(b, o)
            comments.append(u16(b, o))
            o += 2
        elif op == 0xA1:
            entry["kind"] = u16(b, o)
            comments.append(u16(b, o))
            o += 4 + u16(b, o + 2)
        elif op in (0x90, 0x91, 0x98, 0x99):
            o, info = _pict_pixels(b, o, v2, op in (0x98, 0x99), op in (0x91, 0x99))
            entry.update(info)
        elif op in PICT_FIXED:
            o += PICT_FIXED[op]
        else:
            raise DecodeError(f"PICT opcode 0x{op:X} at 0x{entry['offset']:X} is not decoded")
        entry["length"] = o - start
        elements.append(entry)
    d = base_decode("QuickDraw Picture", o)
    d["trailing_bytes"] = len(b) - o
    d["properties"] = {"declared_size_word": u16(b, 0), "actual_size_bytes": len(b),
                       "bounds": rect(b, 2), "quickdraw_version": "version_2" if v2 else "version_1",
                       "opcode_stream_offset": 10, "opcode_decode_status": "verified",
                       "opcode_count": len(elements), "comment_kinds": comments, "text": texts,
                       "render_exports": []}
    d["elements"] = elements
    return d

def _unpack_bits(b: bytes, o: int, row_bytes: int) -> tuple[bytes, int]:
    """One PackBits row: a flag byte n, n + 1 literal bytes (n < 128) or 257 - n copies of the next
    byte (n > 128; 128 is skipped)."""
    out = bytearray()
    while len(out) < row_bytes:
        n = b[o]
        o += 1
        if n < 128:
            out += b[o:o + n + 1]
            o += n + 1
        elif n > 128:
            out += bytes([b[o]]) * (257 - n)
            o += 1
    return bytes(out[:row_bytes]), o


def compare_pict_png(b: bytes, decoded: dict[str, Any], png: Path) -> dict[str, Any]:
    """The picture's bitmap opcodes rendered independently onto a white frame (srcCopy, source and
    destination the same size; 1-bit bits black, a pixel map's indices through its colour table)
    and compared with the PNG export. Pictures that draw text need fonts and are not rendered."""
    try:
        from PIL import Image
    except ImportError:
        return {"status": "not_run", "reason": "Pillow is unavailable"}
    p = decoded["properties"]
    if p.get("text"):
        return {"status": "not_run", "png_path": str(png.relative_to(ROOT)),
                "reason": "The picture draws text, which needs the System's fonts to render."}
    frame = p["bounds"]
    width, height = frame["width"], frame["height"]
    canvas = [(255, 255, 255)] * (width * height)
    for e in decoded["elements"]:
        if "row_data_offset" not in e:
            continue
        if e["transfer_mode"] != 0 or e["source"]["width"] != e["destination"]["width"] \
                or e["source"]["height"] != e["destination"]["height"]:
            return {"status": "not_run", "reason": f"element {e['index']} is not a same-size srcCopy"}
        colours = None
        if e["pixmap"]:
            ct = e["colour_table_offset"]
            device = bool(u16(b, ct + 4) & 0x8000)
            colours = {}
            for k in range(e["colour_table_entries"]):
                at = ct + 8 + 8 * k
                colours[k if device else u16(b, at)] = tuple(u16(b, at + 2 + 2 * c) >> 8 for c in range(3))
        depth = e.get("pixel_size", 1)
        o, packed = e["row_data_offset"], e["name"] in ("PackBitsRect", "PackBitsRgn") and e["row_bytes"] >= 8
        bounds, dst = e["bounds"], e["destination"]
        for y in range(e["rows"]):
            if packed:
                if e["row_bytes"] > 250:
                    count, o = u16(b, o), o + 2
                else:
                    count, o = b[o], o + 1
                row, _ = _unpack_bits(b, o, e["row_bytes"])
                o += count
            else:
                row, o = b[o:o + e["row_bytes"]], o + e["row_bytes"]
            sy = bounds["top"] + y
            if not dst["top"] <= sy < dst["bottom"]:
                continue
            for x in range(dst["left"] - bounds["left"], dst["right"] - bounds["left"]):
                bit = x * depth
                value = (row[bit // 8] >> (8 - depth - bit % 8)) & ((1 << depth) - 1)
                colour = colours.get(value, (0, 0, 0)) if colours is not None else ((0, 0, 0) if value else (255, 255, 255))
                canvas[(sy - frame["top"]) * width + bounds["left"] + x - frame["left"]] = colour
    image = Image.open(png).convert("RGB")
    actual = list(image.get_flattened_data() if hasattr(image, "get_flattened_data") else image.getdata())
    if hasattr(image, "get_flattened_data") and actual and not isinstance(actual[0], tuple):
        actual = [tuple(actual[k:k + 3]) for k in range(0, len(actual), 3)]
    differing = sum(a != e for a, e in zip(actual, canvas)) + abs(len(actual) - len(canvas))
    return {"status": "pixel_exact" if differing == 0 and image.size == (width, height) else "mismatch",
            "png_path": str(png.relative_to(ROOT)), "png_dimensions": list(image.size),
            "compared_pixels": min(len(actual), len(canvas)), "differing_pixels": differing,
            "comparison": "independently rendered bitmap opcodes versus PNG pixels"}


def decode_snd(b: bytes) -> dict[str, Any]:
    if len(b) < 42:
        raise DecodeError("snd resource shorter than sampled-sound header")
    fmt = u16(b, 0)
    if fmt != 1:
        raise DecodeError(f"unsupported snd format {fmt}")
    modifier_count = u16(b, 2)
    command_count_offset = 4 + modifier_count * 6
    command_count = u16(b, command_count_offset)
    commands = []
    off = command_count_offset + 2
    sound_header_offset = None
    for i in range(command_count):
        cmd = u16(b, off)
        param1 = u16(b, off + 2)
        param2 = u32(b, off + 4)
        commands.append({"index": i + 1, "command": f"0x{cmd:04X}",
                         "data_offset_flag": bool(cmd & 0x8000),
                         "command_code": cmd & 0x7FFF, "param1": param1, "param2": param2})
        if (cmd & 0x7FFF) in (80, 81):
            sound_header_offset = param2
        off += 8
    if sound_header_offset is None or sound_header_offset + 22 > len(b):
        raise DecodeError("snd has no valid buffer/sound command header")
    o = sound_header_offset
    sample_length = u32(b, o + 4)
    sample_rate_fixed = u32(b, o + 8)
    encoding = b[o + 20]
    data_offset = o + 22
    if encoding != 0:
        raise DecodeError(f"unsupported compressed snd encoding {encoding}")
    if data_offset + sample_length > len(b):
        raise DecodeError("snd sample bytes are truncated")
    d = base_decode("Classic Macintosh snd Format 1 Sampled Sound", data_offset + sample_length)
    d["trailing_bytes"] = len(b) - d["consumed_bytes"]
    d["properties"] = {
        "format_number": fmt, "modifier_count": modifier_count,
        "modifier_synth_id": u16(b, 4) if modifier_count else None,
        "modifier_init_options": f"0x{u32(b, 6):08X}" if modifier_count else None,
        "command_count": command_count, "sound_header_offset": o,
        "sample_pointer": u32(b, o), "sample_length": sample_length,
        "sample_rate_fixed_16_16": f"0x{sample_rate_fixed:08X}",
        "sample_rate_hz": sample_rate_fixed / 65536.0,
        "loop_start": u32(b, o + 12), "loop_end": u32(b, o + 16),
        "encoding": encoding, "compression": "none", "channels": 1,
        "sample_width_bits": 8, "base_frequency_midi": b[o + 21],
        "sample_data_offset": data_offset,
        "sample_sha256": hashlib.sha256(b[data_offset:data_offset + sample_length]).hexdigest(),
    }
    d["elements"] = commands
    return d


def decode_code(b: bytes, rid: int) -> dict[str, Any]:
    d = base_decode("Motorola 68000 CODE Segment", len(b))
    d["properties"] = {"segment_size_bytes": len(b), "first_u16_be": u16(b, 0),
                       "second_u16_be": u16(b, 2), "architecture": "Motorola 68000",
                       "decompilation_status": "see sibling .c and .decomp.c files"}
    if rid == 0:
        if len(b) < 16:
            raise DecodeError("CODE 0 header truncated")
        jump_table_size = u32(b, 8)
        if jump_table_size % 8 or 16 + jump_table_size > len(b):
            raise DecodeError("CODE 0 jump-table size is inconsistent")
        entries = []
        for i in range(jump_table_size // 8):
            o = 16 + i * 8
            if u16(b, o + 2) != 0x3F3C or u16(b, o + 6) != 0xA9F0:
                raise DecodeError(f"CODE 0 jump-table entry {i} lacks MOVE.W/LoadSeg stub")
            entries.append({"kind": "loadseg_jump_table_entry", "index": i,
                            "a5_offset": u32(b, 12) + i * 8,
                            "record_file_offset": o, "stored_tail": u16(b, o),
                            "target_file_offset": u16(b, o) + 4,
                            "segment_id": u16(b, o + 4),
                            "loader_stub_hex": b[o + 2:o + 8].hex()})
        d["properties"].update({"above_a5_size": u32(b, 0), "below_a5_size": u32(b, 4),
                                "jump_table_size_bytes": jump_table_size,
                                "jump_table_a5_offset": u32(b, 12),
                                "jump_table_entry_count": len(entries)})
        d["elements"] = entries
    return d


def decode_unknown(b: bytes, typ: str) -> dict[str, Any]:
    words = [u16(b, i) for i in range(0, len(b) - 1, 2)]
    printable = []
    for m in re.finditer(rb"[\x20-\x7e]{4,}", b):
        printable.append({"offset": m.start(), "text": m.group().decode("ascii")})
    d = base_decode(f"Undecoded {typ} Binary Structure", len(b))
    d["properties"] = {"word_aligned": len(b) % 2 == 0, "u16_word_count": len(words),
                       "zero_byte_count": b.count(0), "zero_byte_fraction": round(b.count(0) / len(b), 6) if b else 0,
                       "printable_ascii_runs": printable, "structure_status": "unresolved"}
    return d


DECODERS: dict[str, Callable[[bytes], dict[str, Any]]] = {
    "ALRT": decode_alrt, "BNDL": decode_bndl, "CNTL": decode_cntl,
    "DITL": decode_ditl, "DLOG": decode_dlog,
    "FREF": decode_fref, "PICT": decode_pict,
    "SIZE": decode_size, "STR#": decode_strlist, "TEXT": decode_text,
    "clut": decode_clut, "snds": decode_snd, "styl": decode_styl, "vers": decode_vers,
}


def decode_payload(typ: str, rid: int, b: bytes) -> tuple[dict[str, Any], str, list[str]]:
    try:
        if typ in ("ICON", "ICN#", "icI4", "icI8", "ics#", "ics4", "ics8"):
            decoded = decode_icon(b, typ)
        elif typ == "cicn":
            decoded = decode_cicn(b)
        elif typ == "DREL":
            decoded = decode_drel(b)
        elif typ == "HEL1":
            decoded = decode_hel1(b, rid)
        elif typ == "ZERO":
            decoded = decode_zero0(b)
        elif typ == "DATA" and rid == 128:
            decoded = decode_data128(b)
        elif typ == "DATA" and rid == 0:
            decoded = decode_data0(b)
        elif typ == "MDPL":
            decoded = decode_mdpl(b)
        elif typ == "TEXT" and rid == 128:
            decoded = decode_text128(b)
        elif typ == "CODE":
            decoded = decode_code(b, rid)
        elif typ == "DITL":
            decoded = decode_ditl(b, rid)
        elif typ == "MENU":
            decoded = decode_menu(b, rid)
        elif typ in DECODERS:
            decoded = DECODERS[typ](b)
        elif typ == "HELL":
            decoded = decode_text(b)
            decoded["format"] = "MacRoman Finder Get Info String"
        else:
            decoded = decode_unknown(b, typ)
        complete = decoded["consumed_bytes"] + decoded["trailing_bytes"] == len(b)
        structure_status = decoded.get("properties", {}).get("structure_status")
        unresolved_format = structure_status not in (None, "verified")
        status = "VERIFIED" if complete and not unresolved_format else "UNKNOWN"
        cut = next((e for e in decoded.get("elements", []) if isinstance(e, dict) and e.get("status") == "TRUNCATED"), None)
        if status == "VERIFIED":
            unresolved = []
        elif structure_status == "partially_resolved":
            unresolved = ["Partly decoded; the uninterpreted ranges are listed."]
        elif structure_status == "partial_truncated" and cut is not None:
            unresolved = [f"The layout is decoded; the payload ends inside item {cut['index']}, at least "
                          f"{cut['minimum_missing_bytes']} bytes of its header missing."]
        else:
            unresolved = ["Binary layout and field semantics remain unidentified."]
        if decoded.get("trailing_bytes"):
            unresolved.append(f"{decoded['trailing_bytes']} trailing bytes are not decoded.")
        return decoded, status, unresolved
    except (DecodeError, UnicodeDecodeError, struct.error) as exc:
        decoded = decode_unknown(b, typ)
        decoded["decode_error"] = str(exc)
        return decoded, "UNKNOWN", [f"Deterministic decoder rejected payload: {exc}"]


def extract_appledouble_resource_fork(path: Path) -> tuple[bytes, int]:
    data = path.read_bytes()
    if len(data) < 26 or u32(data, 0) != 0x00051607:
        raise DecodeError(f"{path} is not AppleDouble")
    count = u16(data, 24)
    for i in range(count):
        o = 26 + 12 * i
        entry_id, entry_off, entry_len = u32(data, o), u32(data, o + 4), u32(data, o + 8)
        if entry_id == 2:
            if entry_off + entry_len > len(data):
                raise DecodeError("AppleDouble resource-fork entry is truncated")
            return data[entry_off:entry_off + entry_len], entry_off
    raise DecodeError("AppleDouble has no resource-fork entry")


def parse_fork(fork: bytes) -> list[dict[str, Any]]:
    if len(fork) < 16:
        raise DecodeError("resource fork header truncated")
    data_off, map_off, data_len, map_len = (u32(fork, n) for n in (0, 4, 8, 12))
    if data_off + data_len > len(fork) or map_off + map_len > len(fork):
        raise DecodeError("resource fork sections exceed file")
    type_base = map_off + u16(fork, map_off + 24)
    name_base = map_off + u16(fork, map_off + 26)
    type_count = u16(fork, type_base) + 1
    out = []
    for ti in range(type_count):
        te = type_base + 2 + 8 * ti
        typ = fork[te:te + 4].decode("mac_roman")
        ref_count = u16(fork, te + 4) + 1
        ref_base = type_base + u16(fork, te + 6)
        for ri in range(ref_count):
            re_off = ref_base + 12 * ri
            rid, name_off = i16(fork, re_off), u16(fork, re_off + 2)
            attrs_offset = u32(fork, re_off + 4)
            attrs, rel = attrs_offset >> 24, attrs_offset & 0xFFFFFF
            size_off = data_off + rel
            size = u32(fork, size_off)
            payload_off = size_off + 4
            if payload_off + size > len(fork):
                raise DecodeError(f"{typ}:{rid} payload truncated")
            name = None
            name_hex = None
            if name_off != 0xFFFF:
                name, _, name_hex = pstring(fork, name_base + name_off)
            out.append({"type": typ, "id": rid, "name": name, "name_bytes_hex": name_hex,
                        "attributes": attrs, "payload_offset": payload_off,
                        "size": size, "payload": fork[payload_off:payload_off + size]})
    return out


def discover_items() -> list[tuple[str, int]]:
    items = []
    for typ in REQUIRED_TYPES:
        folder = RESEDIT / typ
        if not folder.is_dir():
            continue
        ids: set[int] = set()
        for path in folder.iterdir():
            if not path.is_file() or path.suffix not in (".md", ".png", ".bmp", ".bin"):
                continue
            name = path.stem
            if typ == "CODE" and name.startswith("ID"):
                name = name[2:]
            try:
                ids.add(int(name))
            except ValueError:
                continue
        items.extend((typ, rid) for rid in sorted(ids))
    return items


def resource_key(typ: str, rid: int) -> str:
    return f"{typ}:{rid}"


def output_stem(typ: str, rid: int) -> str:
    return f"ID{rid:02d}" if typ == "CODE" else str(rid)


def exported_payload(typ: str, rid: int) -> tuple[bytes | None, str | None]:
    """Return bytes already present in the curated ResEdit export, if any."""
    stem = output_stem(typ, rid)
    if typ == "CODE":
        path = RESEDIT / typ / stem
        if path.is_file():
            return bytes.fromhex(re.sub(r"\s+", "", path.read_text(encoding="ascii"))), str(path.relative_to(ROOT))
        return None, None
    path = RESEDIT / typ / f"{rid}.md"
    if not path.is_file():
        return None, None
    match = re.search(r"^Hexadecimal Content:\s*([0-9A-Fa-f]+)\s*$",
                      path.read_text(encoding="utf-8", errors="replace"), re.MULTILINE)
    if not match:
        return None, None
    return bytes.fromhex(match.group(1)), str(path.relative_to(ROOT))


def exported_name(typ: str, rid: int) -> tuple[bool, str | None, str | None]:
    """Return (present, name, path) from an existing ResEdit Markdown export."""
    if typ == "CODE":
        return False, None, None
    path = RESEDIT / typ / f"{rid}.md"
    if not path.is_file():
        return False, None, None
    match = re.search(r'^Name:\s*"(.*)"\s*$', path.read_text(encoding="utf-8", errors="replace"), re.MULTILINE)
    if not match:
        return False, None, None
    return True, match.group(1), str(path.relative_to(ROOT))


def descriptive_name(typ: str, rid: int, original_name: str | None,
                     decoded: dict[str, Any]) -> str:
    if (typ, rid) in IDENTITIES:
        return IDENTITIES[(typ, rid)]
    if typ == "DLOG":
        return f"{original_name or decoded['properties'].get('title') or f'Dialog {rid}'} Dialog"
    if typ == "DITL":
        return f"Dialog/Alert Item List {rid}"
    if typ == "MENU":
        return f"{decoded['properties'].get('title') or f'Menu {rid}'} Menu"
    if typ == "PICT":
        return original_name or f"QuickDraw Picture {rid}"
    if typ == "snds":
        return f"{original_name or f'Sound {rid}'} Sampled Sound"
    if typ == "CODE":
        return f"Motorola 68000 Code Segment {rid}"
    if typ in ("ICON", "ICN#", "icI4", "icI8", "ics#", "ics4", "ics8", "cicn"):
        return f"{original_name + ' ' if original_name else ''}{typ} Icon {rid}"
    if original_name:
        return original_name
    return f"{decoded['format']} {rid}"


def scan_code_references() -> dict[tuple[str, int], list[dict[str, Any]]]:
    refs: dict[tuple[str, int], list[dict[str, Any]]] = defaultdict(list)
    patterns = [
        (re.compile(r"GetResource\('([^']{4})',\s*(0x[0-9a-fA-F]+|\d+)"), None),
        (re.compile(r"GetResource\((ZERO|DATA|DREL|HEL1|MENU|vers),\s*(0x[0-9a-fA-F]+|\d+)"), None),
        (re.compile(r"GetNewDialog\((0x[0-9a-fA-F]+|\d+)"), "DLOG"),
        (re.compile(r"(?:StopAlert|NoteAlert|CautionAlert|Alert)\((0x[0-9a-fA-F]+|\d+)"), "ALRT"),
        (re.compile(r"GetMenu\((0x[0-9a-fA-F]+|\d+)"), "MENU"),
    ]
    for path in sorted((RESEDIT / "CODE").glob("*.decomp.c")):
        current_context = "decompilation annotation"
        for line_no, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            context_match = re.search(r"Recovered name:\s*([A-Za-z_][A-Za-z0-9_]*)", line)
            if context_match:
                current_context = context_match.group(1)
            for rx, fixed_type in patterns:
                for m in rx.finditer(line):
                    if fixed_type:
                        typ, value = fixed_type, m.group(1)
                    else:
                        typ, value = m.group(1), m.group(2)
                    rid = int(value, 0)
                    export_typ = {"snd ": "snds", "icl4": "icI4", "icl8": "icI8"}.get(typ, typ)
                    entry = {"source_path": str(path.relative_to(ROOT)), "line": line_no,
                             "function_or_context": current_context,
                             "evidence": line.strip()[:500], "status": "VERIFIED"}
                    if entry not in refs[(export_typ, rid)]:
                        refs[(export_typ, rid)].append(entry)
    return refs


def scan_named_type_references() -> dict[str, list[dict[str, Any]]]:
    refs: dict[str, list[dict[str, Any]]] = defaultdict(list)
    rx = re.compile(r"GetNamedResource\('([^']{4})'")
    for path in sorted((RESEDIT / "CODE").glob("*.decomp.c")):
        current_context = "decompilation annotation"
        for line_no, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            context_match = re.search(r"Recovered name:\s*([A-Za-z_][A-Za-z0-9_]*)", line)
            if context_match:
                current_context = context_match.group(1)
            for match in rx.finditer(line):
                typ = {"snd ": "snds", "icl4": "icI4", "icl8": "icI8"}.get(match.group(1), match.group(1))
                entry = {"source_path": str(path.relative_to(ROOT)), "line": line_no,
                         "function_or_context": current_context,
                         "evidence": line.strip()[:500], "status": "VERIFIED",
                         "scope": "resource_type_by_name_not_individual_id"}
                if entry not in refs[typ]:
                    refs[typ].append(entry)
    return refs


def outgoing_refs(typ: str, rid: int, decoded: dict[str, Any]) -> list[dict[str, Any]]:
    refs = []
    p = decoded.get("properties", {})
    if typ in ("ALRT", "DLOG") and "ditl_id" in p:
        refs.append({"target": resource_key("DITL", p["ditl_id"]), "kind": "template_item_list",
                     "status": "PROVEN", "evidence": "big-endian DITL ID in original template bytes"})
    if typ == "DITL":
        for item in decoded.get("elements", []):
            if "referenced_resource_id" in item:
                refs.append({"target": resource_key(item["referenced_resource_type"], item["referenced_resource_id"]),
                             "kind": f"dialog_item_{item['index']}", "status": "PROVEN",
                             "evidence": "resource ID encoded in original DITL item data"})
    if typ == "BNDL":
        for group in decoded.get("elements", []):
            target_type = group["resource_type"]
            for mapping in group["mappings"]:
                refs.append({"target": resource_key(target_type, mapping["resource_id"]),
                             "kind": f"bundle_local_id_{mapping['local_id']}", "status": "PROVEN",
                             "evidence": "BNDL mapping entry in original bytes"})
    return refs


def build_records(write: bool) -> tuple[list[dict[str, Any]], list[str]]:
    fork, apple_off = extract_appledouble_resource_fork(APPLEDOUBLE)
    fork_entries = parse_fork(fork)
    by_key = {(e["type"], e["id"]): e for e in fork_entries}
    items = discover_items()
    code_refs = scan_code_references()
    named_type_refs = scan_named_type_references()
    records = []
    errors = []
    for typ, rid in items:
        fourcc = TYPE_TO_FOURCC.get(typ, typ)
        entry = by_key.get((fourcc, rid))
        if entry is None:
            errors.append(f"missing authoritative resource fork entry for {typ}:{rid} (fourcc {fourcc!r})")
            continue
        stem = output_stem(typ, rid)
        bin_path = RESEDIT / typ / f"{stem}.bin"
        fork_payload = entry["payload"]
        resedit_payload, resedit_payload_path = exported_payload(typ, rid)
        has_resedit_name, resedit_name, resedit_name_path = exported_name(typ, rid)
        original_name = resedit_name if has_resedit_name else entry["name"]
        original_name_bytes = (original_name.encode("mac_roman").hex()
                               if original_name is not None else None)
        payload = resedit_payload if resedit_payload is not None else fork_payload
        source_matches = payload == fork_payload
        if typ == "CODE":
            if not bin_path.is_file():
                errors.append(f"protected CODE binary is missing: {bin_path.relative_to(ROOT)}")
                continue
            if bin_path.read_bytes() != payload:
                errors.append(f"protected CODE binary differs from its ResEdit hex export: {bin_path.relative_to(ROOT)}")
                continue
        elif write and (not bin_path.exists() or bin_path.read_bytes() != payload):
            # Non-CODE *.bin files are generated companions, not original inputs.
            bin_path.write_bytes(payload)
        decoded, decode_status, unresolved = decode_payload(typ, rid, payload)
        if typ == "cicn":
            png = RESEDIT / typ / f"{rid}.png"
            decoded["properties"]["png_pixel_comparison"] = (
                compare_cicn_png(payload, decoded, png) if png.is_file()
                else {"status": "not_run", "reason": "PNG export is missing"}
            )
        if typ == "PICT" and decode_status == "VERIFIED":
            png = RESEDIT / typ / f"{rid}.png"
            decoded["properties"]["png_pixel_comparison"] = (
                compare_pict_png(payload, decoded, png) if png.is_file()
                else {"status": "not_run", "reason": "PNG export is missing"}
            )
        if typ in ("ICON", "ICN#", "ics#", "icI4", "icI8", "ics4", "ics8"):
            png = RESEDIT / typ / f"{rid}.png"
            if typ in ("ICON", "ICN#", "ics#") and png.is_file():
                comparison = compare_monochrome_icon_png(payload, decoded, png)
            elif png.is_file():
                comparison = compare_indexed_icon_png(payload, typ, png)
            else:
                comparison = {"status": "not_run", "reason": "PNG export is missing"}
            decoded["properties"]["png_pixel_comparison"] = comparison
        if typ == "CODE":
            decomp = RESEDIT / "CODE" / f"ID{rid:02d}.decomp.c"
            ghidra = RESEDIT / "CODE" / f"ID{rid:02d}.c"
            known = []
            if decomp.is_file():
                seen = set()
                for line_no, line in enumerate(decomp.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                    m = re.search(r"Original:\s*(FUN_[0-9A-Fa-f]+)", line)
                    if m and m.group(1) not in seen:
                        seen.add(m.group(1))
                        known.append({"kind": "known_function", "original_symbol": m.group(1),
                                      "annotation_line": line_no,
                                      "source_path": str(decomp.relative_to(ROOT))})
            decoded["elements"].extend(known)
            decoded["properties"]["known_function_count"] = len(known)
            decoded["properties"]["ghidra_export_path"] = str(ghidra.relative_to(ROOT)) if ghidra.is_file() else None
            decoded["properties"]["semantic_decompilation_path"] = str(decomp.relative_to(ROOT)) if decomp.is_file() else None
        if typ == "PICT":
            decoded["properties"]["render_exports"] = [
                str(p.relative_to(ROOT)) for ext in (".png", ".bmp")
                if (p := RESEDIT / typ / f"{rid}{ext}").is_file()
            ]
            decoded["properties"]["rendering_fidelity_status"] = "not_pixel_verified"
        exports = []
        representations = []
        for p in sorted((RESEDIT / typ).glob(f"{stem}*" if typ == "CODE" else f"{rid}.*")):
            if p.suffix != ".json":
                exports.append(str(p.relative_to(ROOT)))
                representations.append({"path": str(p.relative_to(ROOT)),
                                        "size": p.stat().st_size,
                                        "sha256": hashlib.sha256(p.read_bytes()).hexdigest(),
                                        "kind": {".md": "ResEdit Markdown/hex annotation",
                                                 ".bin": "binary payload", ".png": "PNG render",
                                                 ".bmp": "BMP render", ".c": "C/decompilation export",
                                                 "": "hexadecimal CODE export"}.get(p.suffix, "supporting file")})
        desc = descriptive_name(typ, rid, original_name, decoded)
        metadata_path = RESEDIT / typ / f"{stem}.json"
        review = {"notes": [], "claims": {}}
        if metadata_path.is_file():
            try:
                previous = json.loads(metadata_path.read_text(encoding="utf-8"))
                if isinstance(previous.get("review"), dict):
                    review = previous["review"]
            except json.JSONDecodeError:
                pass
        record = {
            "schema": SCHEMA,
            "resource": {"type": typ, "id": rid, "key": resource_key(typ, rid),
                         "original_fourcc": fourcc, "original_macintosh_name": original_name,
                         "original_name_bytes_hex": original_name_bytes,
                         "original_name_source": resedit_name_path or "comparison resource map",
                         "descriptive_name": desc,
                         "purpose": desc if (typ, rid) in IDENTITIES or original_name else None,
                         "description": f"{decoded['format']}; {len(payload)} curated payload bytes."},
            "evidence": {"binary_path": str(bin_path.relative_to(ROOT)),
                         "binary_size": len(payload), "sha256": hashlib.sha256(payload).hexdigest(),
                         "binary_origin": "ResEdit hexadecimal export" if resedit_payload is not None
                            else "recovered resource-fork payload",
                         "authoritative_export_path": resedit_payload_path,
                         "resource_attributes": f"0x{entry['attributes']:02X}",
                         "comparison_container": str(APPLEDOUBLE.relative_to(ROOT)),
                         "comparison_container_format": "AppleDouble with embedded classic resource fork (Hellcats 1.0.4)",
                         "appledouble_resource_fork_offset": apple_off,
                         "resource_fork_payload_offset": entry["payload_offset"],
                         "resource_fork_payload_size": len(fork_payload),
                         "resource_fork_payload_sha256": hashlib.sha256(fork_payload).hexdigest(),
                         "binary_matches_resource_fork_payload": source_matches,
                         "comparison_resource_name": entry["name"],
                         "source_exports": exports,
                         "representations": representations},
            "decoded": decoded,
            "relationships": {"outgoing": outgoing_refs(typ, rid, decoded), "incoming": []},
            "code_references": code_refs.get((typ, rid), []),
            "type_code_references": named_type_refs.get(typ, []),
            "claims": {"identity": "PROVEN" if original_name else (
                           "INFERRED" if (typ, rid) in INFERRED_IDENTITIES else
                           "VERIFIED"),
                       "binary_integrity": "VERIFIED", "decoded_structure": decode_status,
                       "gameplay_role": "VERIFIED" if code_refs.get((typ, rid)) else (
                           "INFERRED" if (typ, rid) in IDENTITIES else "UNKNOWN")},
            "claim_evidence": {
                "identity": "Original Macintosh resource name" if original_name else (
                    "Reviewed semantic mapping grounded in decoded content" if (typ, rid) in IDENTITIES
                    else "Only a deterministic structural identity is available"),
                "binary_integrity": "SHA-256 and length checked against the extracted payload and source container",
                "decoded_structure": "Deterministic parser offsets, element counts, consumed bytes, and trailing bytes",
                "gameplay_role": "Explicit decompilation annotation" if code_refs.get((typ, rid))
                    else "No direct executable reference established",
            },
            "review": review,
            "unresolved": unresolved,
        }
        if not source_matches and typ in ("DITL", "vers"):
            alternate, alternate_status, alternate_unresolved = decode_payload(typ, rid, fork_payload)
            record["comparison_version_1_0_4"] = {
                "claim_status": "INFERRED" if typ == "DITL" else "VERIFIED",
                "decoded_structure_status": alternate_status,
                "decoded": alternate,
                "unresolved": alternate_unresolved,
                "note": "Comparison only; this does not replace the curated ResEdit payload.",
            }
        if typ == "PICT" and decoded["properties"].get("png_pixel_comparison", {}).get("status") == "mismatch":
            record["unresolved"].append("The rendered picture differs from its PNG export.")
        if typ == "cicn" and decoded["properties"]["png_pixel_comparison"]["status"] != "pixel_exact":
            record["unresolved"].append("The decoded cicn pixels do not have a verified pixel-exact PNG export.")
        if typ in ("icI4", "icI8", "ics4", "ics8"):
            comparison = decoded["properties"]["png_pixel_comparison"]
            if comparison.get("status") == "mismatch":
                record["unresolved"].append(
                    f"The PNG export differs from the default colour table on {comparison['differing_pixels']} pixels "
                    f"(indices {', '.join(map(str, comparison['differing_indices']))}); the icl8 exports, using the same "
                    "indices, match the table exactly, so the export is the suspect.")
            elif comparison.get("status") != "pixel_exact":
                record["unresolved"].append("No palette association is checked; indexed pixels require external Finder palette rules.")
        if typ == "MDPL":
            record["claims"]["identity"] = "PROVEN"
            record["unresolved"].append("The MDPL layout's header (before 0x5c) and its block at 0x136..0x182 are not interpreted; the type is the drawing program's, not a documented Apple structure.")
        if not source_matches:
            record["unresolved"].append(
                "Curated ResEdit payload differs from the independently recovered 1.0.4 resource-fork payload; both hashes and sizes are recorded and neither original source was overwritten."
            )
        records.append(record)

    lookup = {r["resource"]["key"]: r for r in records}
    for record in records:
        for rel in record["relationships"]["outgoing"]:
            target = lookup.get(rel["target"])
            if target:
                target["relationships"]["incoming"].append({
                    "source": record["resource"]["key"], "kind": rel["kind"],
                    "status": rel["status"], "evidence": rel["evidence"]})
            else:
                rel["target_status"] = "missing_from_curated_resedit_tree"
    for record in records:
        record["relationships"]["incoming"].sort(key=lambda x: (x["source"], x["kind"]))
        if write:
            typ, rid = record["resource"]["type"], record["resource"]["id"]
            metadata_path = RESEDIT / typ / f"{output_stem(typ, rid)}.json"
            metadata_path.write_text(json.dumps(record, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    records.sort(key=lambda r: (REQUIRED_TYPES.index(r["resource"]["type"]), r["resource"]["id"]))
    return records, errors


def summary(records: list[dict[str, Any]]) -> dict[str, Any]:
    outgoing = sum(len(r["relationships"]["outgoing"]) for r in records)
    elements = sum(len(r["decoded"].get("elements", [])) for r in records)
    types = sorted({r["resource"]["type"] for r in records}, key=REQUIRED_TYPES.index)
    decoded = sum(r["claims"]["decoded_structure"] == "VERIFIED" for r in records)
    unknown = sum(r["claims"]["decoded_structure"] == "UNKNOWN" for r in records)
    executable = sum(len(r["code_references"]) for r in records)
    type_executable = {(r["resource"]["type"], x["source_path"], x["line"])
                       for r in records for x in r.get("type_code_references", [])}
    representations = sum(len(r["evidence"]["representations"]) for r in records)
    return {"schema": "hellcats-resedit-inventory-v1", "resource_type_count": len(types),
            "resource_types": types, "resource_count": len(records),
            "enriched_resource_count": len(records), "decoded_resource_count": decoded,
            "unidentified_structure_count": unknown, "internal_element_count": elements,
            "confirmed_outgoing_reference_count": outgoing,
            "verified_executable_reference_count": executable,
            "verified_type_level_executable_reference_count": len(type_executable),
            "representation_count": representations,
            "resources_by_type": dict(Counter(r["resource"]["type"] for r in records))}


def inventory_document(records: list[dict[str, Any]]) -> dict[str, Any]:
    inventory = summary(records)
    inventory["resources"] = [{"key": r["resource"]["key"],
                               "metadata_path": str((RESEDIT / r["resource"]["type"] /
                                                     f"{output_stem(r['resource']['type'], r['resource']['id'])}.json").relative_to(ROOT)),
                               "binary_path": r["evidence"]["binary_path"],
                               "sha256": r["evidence"]["sha256"]} for r in records]
    associated = {item["metadata_path"] for item in inventory["resources"]}
    associated.update(item["binary_path"] for item in inventory["resources"])
    for record in records:
        associated.update(rep["path"] for rep in record["evidence"]["representations"])
    supporting = []
    for path in sorted(RESEDIT.rglob("*")):
        if not path.is_file() or "__pycache__" in path.parts or path.name == "inventory.json":
            continue
        rel = str(path.relative_to(ROOT))
        if rel in associated:
            continue
        supporting.append({"path": rel, "size": path.stat().st_size,
                           "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                           "kind": "unassociated supporting file"})
    inventory["supporting_file_count"] = len(supporting)
    inventory["supporting_files"] = supporting
    return inventory


def cmd_generate(_: argparse.Namespace) -> int:
    records, errors = build_records(write=True)
    inventory = inventory_document(records)
    (RESEDIT / "inventory.json").write_text(json.dumps(inventory, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(summary(records), indent=2, sort_keys=True))
    if errors:
        print("errors:", file=sys.stderr)
        for error in errors:
            print(f" - {error}", file=sys.stderr)
        return 1
    return 0


def load_metadata(typ: str, rid: int) -> dict[str, Any]:
    path = RESEDIT / typ / f"{output_stem(typ, rid)}.json"
    if not path.is_file():
        raise FileNotFoundError(f"metadata not generated: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def cmd_inventory(_: argparse.Namespace) -> int:
    path = RESEDIT / "inventory.json"
    if not path.is_file():
        print("inventory missing; run generate", file=sys.stderr)
        return 1
    data = json.loads(path.read_text(encoding="utf-8"))
    compact = {k: v for k, v in data.items() if k not in ("resources", "supporting_files")}
    print(json.dumps(compact, indent=2, sort_keys=True))
    return 0


def cmd_inspect(args: argparse.Namespace) -> int:
    r = load_metadata(args.type, args.id)
    if args.detail:
        print(json.dumps(r, indent=2, ensure_ascii=False, sort_keys=True))
    else:
        print(f"{r['resource']['key']} — {r['resource']['descriptive_name']}")
        print(f"original name: {r['resource']['original_macintosh_name']!r}")
        print(f"binary: {r['evidence']['binary_size']} bytes, sha256 {r['evidence']['sha256']}")
        print(f"format: {r['decoded']['format']} ({r['claims']['decoded_structure']})")
        print(f"elements: {len(r['decoded'].get('elements', []))}; outgoing refs: {len(r['relationships']['outgoing'])}; code refs: {len(r['code_references'])}")
        if r["unresolved"]:
            print("unresolved: " + "; ".join(r["unresolved"]))
    return 0


def cmd_search(args: argparse.Namespace) -> int:
    needle = args.query.casefold()
    hits = []
    for path in sorted(RESEDIT.glob("*/*.json")):
        text = path.read_text(encoding="utf-8")
        if needle in text.casefold():
            r = json.loads(text)
            if r.get("schema") != SCHEMA:
                continue
            hits.append(f"{r['resource']['key']} — {r['resource']['descriptive_name']}")
    print("\n".join(hits))
    return 0


def cmd_references(args: argparse.Namespace) -> int:
    r = load_metadata(args.type, args.id)
    print(json.dumps(r["relationships"], indent=2, ensure_ascii=False, sort_keys=True))
    return 0


def cmd_item(args: argparse.Namespace) -> int:
    """Return one decoded child without exposing the rest of the resource."""
    r = load_metadata(args.type, args.id)
    elements = r["decoded"].get("elements", [])
    keyed = [
        element for element in elements
        if any(str(element.get(key)) == args.item for key in ("index", "id", "resource_id", "item"))
    ]
    if not keyed and args.item.isdecimal():
        position = int(args.item)
        if 1 <= position <= len(elements):
            keyed = [elements[position - 1]]
    if not keyed:
        print(f"item {args.item!r} not found in {r['resource']['key']}", file=sys.stderr)
        return 1
    if len(keyed) != 1:
        print(f"item {args.item!r} is ambiguous in {r['resource']['key']}", file=sys.stderr)
        return 1
    print(json.dumps({"resource": r["resource"]["key"], "item": keyed[0]}, indent=2,
                     ensure_ascii=False, sort_keys=True))
    return 0


def cmd_raw(args: argparse.Namespace) -> int:
    """Hexdump an explicit bounded byte range from one original payload."""
    r = load_metadata(args.type, args.id)
    path = ROOT / r["evidence"]["binary_path"]
    payload = path.read_bytes()
    if args.offset < 0 or args.length <= 0 or args.offset + args.length > len(payload):
        print(
            f"invalid raw range offset={args.offset} length={args.length}; payload bytes={len(payload)}",
            file=sys.stderr,
        )
        return 1
    end = args.offset + args.length
    print(f"{path.relative_to(ROOT)} bytes {args.offset:#x}:{end:#x} of {len(payload):#x}")
    for offset in range(args.offset, end, 16):
        chunk = payload[offset:min(offset + 16, end)]
        hex_bytes = " ".join(f"{value:02x}" for value in chunk)
        ascii_bytes = "".join(chr(value) if 32 <= value < 127 else "." for value in chunk)
        print(f"{offset:08x}  {hex_bytes:<47}  |{ascii_bytes}|")
    return 0


def cmd_unknown(_: argparse.Namespace) -> int:
    for path in sorted(RESEDIT.glob("*/*.json")):
        r = json.loads(path.read_text(encoding="utf-8"))
        if r.get("schema") != SCHEMA:
            continue
        if r["claims"]["decoded_structure"] == "UNKNOWN" or r["unresolved"]:
            print(f"{r['resource']['key']} — {'; '.join(r['unresolved'])}")
    return 0


def cmd_verify(_: argparse.Namespace) -> int:
    records, errors = build_records(write=False)
    expected_keys = {r["resource"]["key"] for r in records}
    for r in records:
        typ, rid = r["resource"]["type"], r["resource"]["id"]
        path = RESEDIT / typ / f"{output_stem(typ, rid)}.json"
        if not path.is_file():
            errors.append(f"missing metadata {path.relative_to(ROOT)}")
            continue
        try:
            stored = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append(f"invalid JSON {path.relative_to(ROOT)}: {exc}")
            continue
        if stored != r:
            errors.append(f"metadata drift {path.relative_to(ROOT)}; rerun generate")
        binary = ROOT / stored["evidence"]["binary_path"]
        if not binary.is_file():
            errors.append(f"missing binary {binary.relative_to(ROOT)}")
        elif hashlib.sha256(binary.read_bytes()).hexdigest() != stored["evidence"]["sha256"]:
            errors.append(f"binary hash mismatch {binary.relative_to(ROOT)}")
    actual_keys = set()
    for path in RESEDIT.glob("*/*.json"):
        try:
            candidate = json.loads(path.read_text(encoding="utf-8"))
            if candidate.get("schema") != SCHEMA:
                continue
            actual_keys.add(candidate["resource"]["key"])
        except (json.JSONDecodeError, KeyError) as exc:
            errors.append(f"invalid resource metadata {path.relative_to(ROOT)}: {exc}")
    if actual_keys != expected_keys:
        errors.append(f"metadata key mismatch: missing={sorted(expected_keys-actual_keys)} extra={sorted(actual_keys-expected_keys)}")
    inventory_path = RESEDIT / "inventory.json"
    if not inventory_path.is_file():
        errors.append("missing sources/resedit-1-0-3/inventory.json")
    else:
        try:
            stored_inventory = json.loads(inventory_path.read_text(encoding="utf-8"))
            if stored_inventory != inventory_document(records):
                errors.append("inventory drift sources/resedit-1-0-3/inventory.json; rerun generate")
        except json.JSONDecodeError as exc:
            errors.append(f"invalid inventory JSON: {exc}")
    if errors:
        print("FAIL")
        for error in errors:
            print(f" - {error}")
        return 1
    print(f"PASS: {len(records)} resources, {len(set(r['resource']['type'] for r in records))} types, all binaries and metadata verified")
    return 0


def parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="command", required=True)
    sub.add_parser("generate", help="extract payloads and regenerate resource-local metadata").set_defaults(func=cmd_generate)
    sub.add_parser("inventory", help="print concise corpus coverage").set_defaults(func=cmd_inventory)
    p = sub.add_parser("inspect", help="inspect one resource")
    p.add_argument("type", choices=REQUIRED_TYPES); p.add_argument("id", type=int); p.add_argument("--detail", action="store_true")
    p.set_defaults(func=cmd_inspect)
    p = sub.add_parser("search", help="search generated metadata"); p.add_argument("query"); p.set_defaults(func=cmd_search)
    p = sub.add_parser("references", help="show bidirectional relationships"); p.add_argument("type", choices=REQUIRED_TYPES); p.add_argument("id", type=int); p.set_defaults(func=cmd_references)
    p = sub.add_parser("item", help="show one decoded child item"); p.add_argument("type", choices=REQUIRED_TYPES); p.add_argument("id", type=int); p.add_argument("item"); p.set_defaults(func=cmd_item)
    p = sub.add_parser("raw", help="show an explicit bounded raw-byte range"); p.add_argument("type", choices=REQUIRED_TYPES); p.add_argument("id", type=int); p.add_argument("--offset", type=lambda value: int(value, 0), default=0); p.add_argument("--length", type=lambda value: int(value, 0), default=64); p.set_defaults(func=cmd_raw)
    sub.add_parser("unknown", help="list unresolved resources").set_defaults(func=cmd_unknown)
    sub.add_parser("unresolved", help="list unresolved resources").set_defaults(func=cmd_unknown)
    sub.add_parser("verify", help="verify source slices, hashes, parsers and metadata drift").set_defaults(func=cmd_verify)
    return ap


if __name__ == "__main__":
    arguments = parser().parse_args()
    raise SystemExit(arguments.func(arguments))
