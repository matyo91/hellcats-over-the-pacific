#!/usr/bin/env python3
"""Generate comparison cases for the trap-free ID02 routines (coordinates, colour index, decimal
Pascal strings, the sound channel engine, the palette lookups) by running the ORIGINAL bytes.

ID02.bin is loaded at 0x30000 (its code is PC-relative), so low memory is free for the
globals the routines read at absolute addresses: SoundBase (0x266), the sound hook (0x196) and
CurrentA5 (0x904 = A5, which the interrupt-level sound routines reload). A5 = 0x20000. Each sound
channel record (A5 - 0x7d0 + 0x238 * ch) has a playing node and a free list of nodes (0x1c bytes,
+0x14 next) in a node pool; the palette lookups get the eight fixed entries (A5 - 0x350) and a
table of extra entries. test_id02_trapfree.gd replays the cases (helpers/segment_cases.gd).

Usage: python3 tools/strict_port/gen_id02_trapfree_cases.py  (writes the fixture JSON)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from m68k_emu import Emulator  # noqa: E402

FIXTURE = Path("godot/tests/strict_port/fixtures/id02_trapfree_cases.json")
BINARY = "sources/resedit-1-0-3/CODE/ID02.bin"
MEMORY_SIZE, CODE, A5 = 0x40000, 0x30000, 0x20000
STACK_TOP = 0x2F000
STACK_GUARD = (0x2E000, 0x2F040)
DATA, POOL, SOUND_BUF, PORT, CTAB, EXTRA = 0x10000, 0x11000, 0x12000, 0x13000, 0x13100, 0x13200
ROUTINES = {"set_back_color_index": 0x1632, "design_x_to_screen": 0x1656, "design_y_to_screen": 0x1680,
            "format_int_decimal_pstring": 0x1C8A, "copy_pascal_string": 0x2EE4, "clear_sound_buffer_to_silence": 0x3D36,
            "alloc_sound_buffer_node": 0x3D50, "select_two_channel_sound_handler": 0x3DB8,
            "play_sample_on_channel": 0x3F54, "enqueue_sample_on_channel": 0x4050, "set_sound_playback_rate": 0x412E,
            "release_channel_loop": 0x41A6, "silence_sound_channel": 0x4242, "is_channel_playing": 0x42B0,
            "clear_ctab_size_callback": 0x488A, "lookup_palette_index_for_rgb_level": 0x49FE,
            "init_standard_colour_indices": 0x4B62}
VOID = {"set_back_color_index", "copy_pascal_string", "clear_sound_buffer_to_silence", "select_two_channel_sound_handler",
        "set_sound_playback_rate", "release_channel_loop", "silence_sound_channel", "clear_ctab_size_callback",
        "init_standard_colour_indices"}
WORD_RESULT = {"is_channel_playing", "lookup_palette_index_for_rgb_level"}
FIXED = [(0, 0, 0), (0xFF00, 0xFF00, 0xFF00), (0xC000, 0xC000, 0xC000), (0x8000, 0, 0), (0, 0x4000, 0), (0x4000, 0x4000, 0x4000),
         (0, 0, 0xC000), (0x8000, 0x8000, 0x8000)]
EXTRA_ENTRIES = [(0x4000, 0, 0xFF00), (0xFF00, 0x8000, 0), (0x8000, 0xC000, 0x4000)]


def node(i: int) -> int:
    return POOL + 0x20 * i


def common() -> list[list[int]]:
    w = [[0x904, 4, A5], [0x266, 4, SOUND_BUF], [0x196, 4, 0x55555555], [A5 - 0x35C, 4, 0x33BC4],
         [A5 - 0xC38, 2, 1], [A5 - 0x1372, 2, 640], [A5 - 0x1370, 2, -481], [A5 - 0x149E, 4, 0x1400], [A5 - 0x137A, 2, 8],
         [A5 - 0x160C, 4, PORT], [A5 - 0x14B2, 4, CTAB], [CTAB + 6, 2, 0x77], [A5 - 0x14A6, 4, EXTRA], [A5 - 0x14A2, 2, len(EXTRA_ENTRIES)]]
    for i, (r, g, b) in enumerate(FIXED):
        w += [[A5 - 0x350 + 6 * i, 2, r], [A5 - 0x350 + 6 * i + 2, 2, g], [A5 - 0x350 + 6 * i + 4, 2, b]]
    for i, (r, g, b) in enumerate(EXTRA_ENTRIES):
        w += [[EXTRA + 6 * i, 2, r], [EXTRA + 6 * i + 2, 2, g], [EXTRA + 6 * i + 4, 2, b]]
    # Two channels: channel c plays node 16 c and its free list is nodes 16 c + 1 .. 16 c + 15.
    for c in range(2):
        rec = A5 - 0x7D0 + 0x238 * c
        w += [[rec, 4, node(16 * c)], [rec + 4, 4, node(16 * c + 1)], [node(16 * c) + 8, 4, A5 - 0xC26]]
        for k in range(16 * c, 16 * c + 16):
            w.append([node(k) + 0x14, 4, node(k + 1)])
    return [[a & 0xFFFFFFFF, s, v & ((1 << (8 * s)) - 1)] for a, s, v in w]


def case(name: str, method: str, stack: list[tuple[int, int]], port_args: list[int], writes: list[list[int]] = ()) -> dict:
    return {"name": name, "method": method, "stack": stack, "args": [a & 0xFFFFFFFF for a in port_args],
            "writes": [[a, s, v & ((1 << (8 * s)) - 1)] for a, s, v in writes]}


def L(v: int) -> tuple[int, int]:
    return (4, v & 0xFFFFFFFF)


def W(v: int) -> tuple[int, int]:
    return (2, v & 0xFFFF)


def build() -> list[dict]:
    out = []
    for depth in (1, 8):
        for idx in (5, -3):
            out.append(case(f"back colour {idx} at depth {depth}", "set_back_color_index", [W(idx)], [idx], [[A5 - 0x137A, 2, depth]]))
    for v in (0, 100, -100, 4800, -4800, 0x7FFF, -0x8000):
        out.append(case(f"design x {v}", "design_x_to_screen", [W(v)], [v]))
        out.append(case(f"design y {v}", "design_y_to_screen", [W(v)], [v], [[A5 - 0x149E, 4, 0x81234]]))
    for v in (0, 7, -7, 1234567890, -1234567890, 0x7FFFFFFF, -0x80000000, 10, -10):
        out.append(case(f"decimal {v}", "format_int_decimal_pstring", [L(v), L(DATA)], [v, DATA]))
    for text in (b"\x05hello", b"\x00", b"\x01a", b"\x90longer than it says"):
        out.append(case(f"pascal copy {text[:6]!r}", "copy_pascal_string", [L(DATA), L(DATA + 0x200)], [DATA, DATA + 0x200],
                        [[DATA + k, 1, b] for k, b in enumerate(text)]))
    out.append(case("silence the sound buffer", "clear_sound_buffer_to_silence", [], []))
    for ch, chain in ((0, 1), (1, 0)):
        out.append(case(f"alloc node ch {ch} chain {chain}", "alloc_sound_buffer_node",
                        [L(ch), L(DATA), L(0x40), L(0x900), W(chain)], [ch, DATA, 0x40, 0x900, chain]))
    for ch in (0, 1, 2):
        out.append(case(f"two-channel handler for ch {ch}", "select_two_channel_sound_handler", [L(ch)], [ch]))
    for name in ("play_sample_on_channel", "enqueue_sample_on_channel"):
        for ch, la, lb in ((0, 0, 0), (1, 0x100, 0x400), (0, 0x500, 0x200), (2, 0, 0), (-1, 0, 0)):
            out.append(case(f"{name} ch {ch} loop {la:#x}..{lb:#x}", name, [L(ch), L(DATA), L(0x10), L(0x800), L(la), L(lb)],
                            [ch, DATA, 0x10, 0x800, la, lb]))
        out.append(case(f"{name} with sound off", name, [L(0), L(DATA), L(0), L(10), L(0), L(0)], [0, DATA, 0, 10, 0, 0],
                        [[A5 - 0xC38, 2, 0]]))
    for rate in (0x10000, 0x4000, 0x8000, 0x30000, 0x40000, 0x18000, 0xFFFFFFFF):
        out.append(case(f"rate {rate:#x}", "set_sound_playback_rate", [L(rate)], [rate]))
    out.append(case("rate with sound off", "set_sound_playback_rate", [L(0x10000)], [0x10000], [[A5 - 0xC38, 2, 0]]))
    # A playing loop on channel 0: nodes 0 -> 1 -> 2 -> 2 (looping); free list from node 3.
    looping = [[A5 - 0x7D0 + 4, 4, node(3)], [node(0) + 0x18, 4, node(1)], [node(1) + 0x18, 4, node(2)], [node(2) + 0x18, 4, node(2)],
               [node(0) + 8, 4, DATA], [node(1) + 8, 4, DATA], [node(2) + 8, 4, DATA]]
    for ch in (0, 1, 3):
        out.append(case(f"release loop ch {ch}", "release_channel_loop", [L(ch)], [ch], looping))
        out.append(case(f"silence ch {ch}", "silence_sound_channel", [L(ch)], [ch], looping))
        out.append(case(f"playing? ch {ch} (sample)", "is_channel_playing", [L(ch)], [ch], looping))
    out.append(case("playing? ch 1 (silence)", "is_channel_playing", [L(1)], [1]))
    out.append(case("clear ctab size", "clear_ctab_size_callback", [], []))
    for depth in (1, 4, 8, 2):
        for r, g, b in ((0, 0, 0), (4, 4, 4), (3, 3, 3), (1, 0, 4), (4, 2, 0), (2, 3, 1), (1, 1, 2)):
            out.append(case(f"palette ({r},{g},{b}) depth {depth}", "lookup_palette_index_for_rgb_level", [W(r), W(g), W(b)], [r, g, b],
                            [[A5 - 0x137A, 2, depth]]))
    out.append(case("palette not found, empty extra table, depth 2", "lookup_palette_index_for_rgb_level", [W(1), W(1), W(2)], [1, 1, 2],
                    [[A5 - 0x137A, 2, 2], [A5 - 0x14A2, 2, 0]]))
    for depth in (1, 8):
        out.append(case(f"standard colour indices depth {depth}", "init_standard_colour_indices", [], [], [[A5 - 0x137A, 2, depth]]))
    return out


def run(c: dict, base: list[list[int]]) -> tuple[list[list[int]], int]:
    emu = Emulator(MEMORY_SIZE, BINARY, file_delta=0x7FFFFFFF)
    code = open(BINARY, "rb").read()
    emu.mem[CODE:CODE + len(code)] = code
    for addr, size, value in base + c["writes"]:
        emu.write(addr, size, value)
    emu.a[5] = A5
    a7 = STACK_TOP
    for size, value in reversed(c["stack"]):
        a7 -= size
        emu.write(a7, size, value)
    before = bytes(emu.mem)
    d0 = emu.call(CODE + ROUTINES[c["method"]], [], a7)
    return ([[a, emu.mem[a]] for a in range(MEMORY_SIZE)
             if not (STACK_GUARD[0] <= a < STACK_GUARD[1]) and emu.mem[a] != before[a]], d0 & 0xFFFFFFFF)


def main() -> None:
    base = common()
    out = {"memory_size": MEMORY_SIZE, "a5": A5, "stack_guard": list(STACK_GUARD), "common_writes": base, "cases": []}
    for c in build():
        changes, d0 = run(c, base)
        entry = {"name": c["name"], "method": c["method"], "args": c["args"], "writes": c["writes"], "changes": changes}
        if c["method"] in WORD_RESULT:
            entry["d0"] = d0 & 0xFFFF
            entry["d0_mask"] = 0xFFFF
        elif c["method"] not in VOID:
            entry["d0"] = d0
        out["cases"].append(entry)
    FIXTURE.write_text(json.dumps(out, separators=(",", ":")) + "\n")
    print(f"{len(out['cases'])} cases")


if __name__ == "__main__":
    main()
