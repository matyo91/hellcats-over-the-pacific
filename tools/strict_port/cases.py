#!/usr/bin/env python3
"""What the overlay's case generators share (gen_*_cases.py, the families that run the Pacific
Conflict overlay in m68k_emu.py): its memory layout and the helpers they all use. A generator
family's own layout (a segment's A5, its stand-ins) stays in that family's first generator.
"""
from __future__ import annotations

from m68k_emu import Emulator

# The overlay image at 0 in MEMORY_SIZE bytes, its stack below STACK_TOP; the replay leaves the
# STACK_GUARD range out of the comparison.
MEMORY_SIZE = 0x40000
STACK_TOP = 0x3F000
STACK_GUARD = (STACK_TOP - 0x800, STACK_TOP + 0x40)
OVERLAY_RNG_INIT = 0x114EA       # runtime address of file 0x1150a


def compact(writes: list[list[int]]) -> tuple[list[list[int]], list[list[int]]]:
    """Runs of zero longs become [start, end) ranges, cleared before the remaining writes; the
    result must leave memory exactly as the writes in order do."""
    zero: list[list[int]] = []
    rest: list[list[int]] = []
    written: set[int] = set()
    for addr, size, value in writes:
        clearable = size == 4 and value == 0 and not written.intersection(range(addr, addr + 4))
        if clearable and zero and zero[-1][1] == addr:
            zero[-1][1] = addr + 4
        elif clearable:
            zero.append([addr, addr + 4])
        else:
            rest.append([addr, size, value])
            written.update(range(addr, addr + size))

    def apply(state: dict[int, int], items: list[list[int]]) -> None:
        for addr, size, value in items:
            for k in range(size):
                state[addr + k] = (value >> (8 * (size - 1 - k))) & 0xFF

    ordered: dict[int, int] = {}
    apply(ordered, writes)
    replay: dict[int, int] = {a: 0 for start, end in zero for a in range(start, end)}
    apply(replay, rest)
    assert replay == ordered, "compacted writes differ"
    return zero, rest


def log_call(emu: Emulator, base: int, nargs: int, deref_index: int = -1, deref_n: int = 0,
             deref2_index: int = -1, deref2_n: int = 0) -> int:
    """A logging stub: append the call's long arguments (plus deref_n longs read at argument
    deref_index, and deref2_n at deref2_index, for buffers passed by address) to the log at base
    (long count first) and return the long at base - 4 (0 unless a case sets it)."""
    args = [emu.read(emu.a[7] + 4 * i, 4) for i in range(nargs)]
    values = list(args)
    values += [emu.read((args[deref_index] + 4 * k) & 0xFFFFFFFF, 4) for k in range(deref_n)]
    values += [emu.read((args[deref2_index] + 4 * k) & 0xFFFFFFFF, 4) for k in range(deref2_n)]
    count = emu.read(base, 4)
    for i, value in enumerate(values):
        emu.write(base + 4 + (count * len(values) + i) * 4, 4, value)
    emu.write(base, 4, count + 1)
    return emu.read(base - 4, 4)
