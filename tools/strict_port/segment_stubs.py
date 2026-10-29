#!/usr/bin/env python3
"""Logging stand-ins for the calls a CODE segment makes outside itself: jump-table slots (other
segments' routines and the ID09 Toolbox glue) and A-line traps.

Each stub is described by a call-log entry [kind, key, log_base, sizes, pascal, result_size,
derefs]: kind "jt" (key = the A5 offset of the slot), "trap" (key = the trap word), "trap_d0" (an
OS trap whose byte argument and result are in D0; see register_trap), "trap_a0" (an OS trap taking
a parameter block in A0; see a0_trap) or "addr"
(key = a code address reached indirectly, e.g. through a service pointer in an A5 global); sizes are the
argument sizes in stack order (lowest address first: a C call's first parameter, a Pascal call's
last; size 1 is a byte pushed as a word - MOVE.B to -(A7) - whose high byte alone is defined); pascal = the callee pops the arguments and a result of result_size bytes (0, 2 or 4) is
written in the slot the caller reserved above them, from the long at log_base - 4; a C call
returns that long in D0, unless an optional ninth element lists the results call by call (the
last repeating). derefs maps an argument index to a long count, or "pstr": the pointed-to longs /
the Pascal string's bytes (length first) are logged in place of the pointer (a buffer in the
caller's frame); ["out", value] writes value (a long) through the pointer instead - a VAR result
such as GetPen's point - and logs nothing; ["out", value, size] writes a word or byte, and a list
value writes several longs (a rect); ["outseq", values(, size)] writes values[n] on the n-th call
(the last repeating); the key -1 set to "digest" keeps the log bounded (the count, then a running
hash h = h * 31 + value of every logged long). The log at log_base holds the call
count, then each call's logged longs. helpers/segment_cases.gd installs the same stubs on the port.
"""
from __future__ import annotations


def write_out(emu, address: int, spec: list, count: int = 0) -> None:
    """["out", value] writes a long; ["out", value, size] writes a 1 / 2 / 4-byte value, or a list
    of longs (a rect) when value is a list; ["outseq", values, (size)] writes the value for this
    call (values[count], the last repeating)."""
    if spec[0] == "outseq":
        spec = ["out", spec[1][min(count, len(spec[1]) - 1)]] + spec[2:]
    value = spec[1]
    if isinstance(value, list):
        for k, long in enumerate(value):
            emu.write(address + 4 * k, 4, long & 0xFFFFFFFF)
    else:
        size = spec[2] if len(spec) > 2 else 4
        emu.write(address, size, value & ((1 << (8 * size)) - 1))


def stack_stub(emu, base: int, sizes: list[int], pascal: bool, result_size: int, derefs: dict[int, object],
               results: list[int] | None = None) -> int:
    values = []
    offset = 0
    count = emu.read(base, 4)
    for i, size in enumerate(sizes):
        value = emu.read(emu.a[7] + offset, size)
        if isinstance(derefs.get(i), list) and derefs[i][0] in ("out", "outseq"):
            write_out(emu, value, derefs[i], count)              # a VAR result: written, not logged
        elif derefs.get(i) == "pstr":
            values += [emu.read((value + k) & 0xFFFFFFFF, 1) for k in range(emu.read(value, 1) + 1)]
        elif i in derefs:
            values += [emu.read((value + 4 * k) & 0xFFFFFFFF, 4) for k in range(derefs[i])]
        else:
            values.append(value)
        offset += 2 if size == 1 else size
    if derefs.get(-1) == "digest":                                # a bounded log: count, then a running hash
        digest = emu.read(base + 4, 4)
        for value in values:
            digest = (digest * 31 + value) & 0xFFFFFFFF
        emu.write(base + 4, 4, digest)
    else:
        for i, value in enumerate(values):
            emu.write(base + 4 + (count * len(values) + i) * 4, 4, value)
    emu.write(base, 4, count + 1)
    result = results[min(count, len(results) - 1)] if results else emu.read(base - 4, 4)
    if pascal:
        emu.a[7] = (emu.a[7] + offset) & 0xFFFFFFFF
        if result_size:
            emu.write(emu.a[7], result_size, result & ((1 << (8 * result_size)) - 1))
    return result


def register_trap(emu, base: int, results: list[int] | None = None) -> None:
    """An OS trap taking its byte argument in D0 and returning D0 (e.g. SwapMMUMode): D0's low byte
    is logged and D0 becomes the result."""
    count = emu.read(base, 4)
    emu.write(base + 4 + 4 * count, 4, emu.d[0] & 0xFF)
    emu.write(base, 4, count + 1)
    emu.d[0] = results[min(count, len(results) - 1)] if results else emu.read(base - 4, 4)


def a0_trap(emu, base: int, spec: dict, results: list[int] | None = None) -> None:
    """An OS trap taking a parameter block in A0 (e.g. _Open, _HFSDispatch): D0's low word (when
    spec["d0"]) and spec["block"] longs of the block are logged, spec["out"] [offset, size, value]
    fields are written into the block, D0 becomes the result and the flags are set from its low word
    (the trap dispatcher's TST.W D0)."""
    count = emu.read(base, 4)
    values = ([emu.d[0] & 0xFFFF] if spec.get("d0") else []) + [emu.read((emu.a[0] + 4 * k) & 0xFFFFFFFF, 4)
                                                                for k in range(spec.get("block", 0))]
    for i, value in enumerate(values):
        emu.write(base + 4 + (count * len(values) + i) * 4, 4, value)
    emu.write(base, 4, count + 1)
    for offset, size, value in spec.get("out", []):
        emu.write((emu.a[0] + offset) & 0xFFFFFFFF, size, value & ((1 << (8 * size)) - 1))
    emu.d[0] = (results[min(count, len(results) - 1)] if results else emu.read(base - 4, 4)) & 0xFFFFFFFF
    emu.logic_flags(emu.d[0], 2)


def install(emu, a5: int, call_logs: list[list]) -> None:
    for kind, key, base, sizes, pascal, result_size, derefs, *rest in call_logs:
        if kind == "trap_a0":
            emu.traps[key] = lambda e, b=base, x=derefs, q=(rest[0] if rest else None): a0_trap(e, b, x, q)
            continue
        d = {int(k): v for k, v in derefs.items()}
        seq = rest[0] if rest else None
        stub = lambda e, b=base, s=sizes, p=pascal, r=result_size, x=d, q=seq: stack_stub(e, b, s, p, r, x, q)
        if kind == "trap_d0":
            emu.traps[key] = lambda e, b=base, q=seq: register_trap(e, b, q)
        elif kind == "jt":
            emu.stubs[(a5 + key) & 0xFFFFFFFF] = stub
        elif kind == "addr":
            emu.stubs[key] = stub
        else:
            emu.traps[key] = stub
