#!/usr/bin/env python3
"""Small 68020 user-mode interpreter for verifying strict-port functions against the original bytes.

The original binary (sources/mac-os-9/Pacific Conflict) is loaded so that runtime address R holds
file byte R + 0x20 (the CODE image convention used throughout the strict port). Instructions are
decoded with capstone and executed here; only the subset the game's computational routines use is
implemented, and anything else raises, so an unsupported instruction is never silently skipped.

This is a verification aid, independent of the GDScript port: it executes the binary itself.
Calls that leave the image (host callbacks through world pointers) raise unless a stub is given.
"""
from __future__ import annotations

import capstone
from capstone import m68k as M

BINARY = "sources/mac-os-9/Pacific Conflict"
FILE_DELTA = 0x20
MASK = {1: 0xFF, 2: 0xFFFF, 4: 0xFFFFFFFF}
SIGN = {1: 0x80, 2: 0x8000, 4: 0x80000000}
RETURN_SENTINEL = 0xFFFFFFF0


def sext(v: int, size: int) -> int:
    v &= MASK[size]
    return v - (MASK[size] + 1) if v & SIGN[size] else v


class Emulator:
    def __init__(self, memory_size: int = 0x40000, binary_path: str = BINARY):
        self.mem = bytearray(memory_size)
        data = open(binary_path, "rb").read()
        image = data[FILE_DELTA:]
        self.mem[: min(len(image), memory_size)] = image[:memory_size]
        self.d = [0] * 8
        self.a = [0] * 8
        self.pc = 0
        self.x = self.n = self.z = self.v = self.c = 0
        self.md = capstone.Cs(capstone.CS_ARCH_M68K, capstone.CS_MODE_BIG_ENDIAN | capstone.CS_MODE_M68K_020)
        self.md.detail = True
        self.stubs: dict[int, callable] = {}
        self.steps = 0
        self._cache: dict[int, object] = {}

    # ---- memory -------------------------------------------------------------------------
    def read(self, addr: int, size: int) -> int:
        addr &= 0xFFFFFFFF
        if addr + size > len(self.mem):
            raise IndexError(f"read {size} at {addr:#x} out of range (pc {self.pc:#x})")
        return int.from_bytes(self.mem[addr : addr + size], "big")

    def write(self, addr: int, size: int, value: int) -> None:
        addr &= 0xFFFFFFFF
        if addr + size > len(self.mem):
            raise IndexError(f"write {size} at {addr:#x} out of range (pc {self.pc:#x})")
        self.mem[addr : addr + size] = (value & MASK[size]).to_bytes(size, "big")

    def push(self, value: int) -> None:
        self.a[7] = (self.a[7] - 4) & 0xFFFFFFFF
        self.write(self.a[7], 4, value)

    def pop(self) -> int:
        v = self.read(self.a[7], 4)
        self.a[7] = (self.a[7] + 4) & 0xFFFFFFFF
        return v

    # ---- registers ----------------------------------------------------------------------
    @staticmethod
    def _is_d(reg: int) -> bool:
        return M.M68K_REG_D0 <= reg <= M.M68K_REG_D7

    def get_reg(self, reg: int) -> int:
        if self._is_d(reg):
            return self.d[reg - M.M68K_REG_D0]
        if M.M68K_REG_A0 <= reg <= M.M68K_REG_A7:
            return self.a[reg - M.M68K_REG_A0]
        raise NotImplementedError(f"register {reg}")

    def set_reg(self, reg: int, value: int, size: int = 4) -> None:
        if self._is_d(reg):
            i = reg - M.M68K_REG_D0
            self.d[i] = (self.d[i] & ~MASK[size] & 0xFFFFFFFF) | (value & MASK[size])
        else:
            self.a[reg - M.M68K_REG_A0] = value & 0xFFFFFFFF

    # ---- operands -----------------------------------------------------------------------
    def _index(self, m) -> int:
        if m.index_reg == 0:
            return 0
        v = self.get_reg(m.index_reg)
        v = sext(v, 2) if m.index_size == 0 else sext(v, 4)
        return v * (m.scale or 1)

    def ea(self, op, size: int) -> int | None:
        """Address of a memory operand (applying pre-decrement / post-increment later)."""
        if self._ops0 is not None:
            self._op_index = 0 if op is self._ops0 else self._op_index
        am = op.address_mode
        m = op.mem
        if am == M.M68K_AM_REGI_ADDR:
            return self.get_reg(self._base(op))
        if am == M.M68K_AM_REGI_ADDR_DISP:
            return (self.get_reg(m.base_reg) + m.disp) & 0xFFFFFFFF
        if am in (M.M68K_AM_AREGI_INDEX_8_BIT_DISP, M.M68K_AM_AREGI_INDEX_BASE_DISP):
            base = self.get_reg(m.base_reg) if m.base_reg else 0
            return (base + m.disp + self._index(m)) & 0xFFFFFFFF
        if am == M.M68K_AM_PCI_DISP:
            return (self.cur + 2 + m.disp) & 0xFFFFFFFF
        if am in (M.M68K_AM_PCI_INDEX_8_BIT_DISP, M.M68K_AM_PCI_INDEX_BASE_DISP):
            return (self.cur + 2 + m.disp + self._index(m)) & 0xFFFFFFFF
        if am in (M.M68K_AM_ABSOLUTE_DATA_LONG, M.M68K_AM_ABSOLUTE_DATA_SHORT):
            return op.imm & 0xFFFFFFFF
        raise NotImplementedError(f"address mode {am} at {self.pc:#x}")

    def _base(self, op) -> int:
        """Base register of (An) / (An)+ / -(An); capstone leaves it 0, so it is read from the
        opcode: the destination field (bits 9..11) for the second operand of move, else bits 0..2."""
        if op.mem.base_reg:
            return op.mem.base_reg
        opcode = self.read(self.cur, 2)
        is_move = self.cur_ins.mnemonic.split(".")[0] in ("move", "movea")
        if is_move and self._op_index == 1:
            return M.M68K_REG_A0 + ((opcode >> 9) & 7)
        return M.M68K_REG_A0 + (opcode & 7)

    def read_op(self, op, size: int) -> int:
        self._op_index = 0 if op is self._ops0 else 1
        am = op.address_mode
        if op.type == M.M68K_OP_REG:
            return self.get_reg(op.reg) & MASK[size]
        if op.type == M.M68K_OP_IMM or am == M.M68K_AM_IMMEDIATE:
            return op.imm & MASK[size]
        if am == M.M68K_AM_REGI_ADDR_POST_INC:
            r = self._base(op)
            addr = self.get_reg(r)
            step = 2 if (size == 1 and r == M.M68K_REG_A7) else size
            self.set_reg(r, addr + step)
            return self.read(addr, size)
        if am == M.M68K_AM_REGI_ADDR_PRE_DEC:
            r = self._base(op)
            step = 2 if (size == 1 and r == M.M68K_REG_A7) else size
            addr = (self.get_reg(r) - step) & 0xFFFFFFFF
            self.set_reg(r, addr)
            return self.read(addr, size)
        return self.read(self.ea(op, size), size)

    def write_op(self, op, size: int, value: int, addr: int | None = None) -> None:
        self._op_index = 0 if op is self._ops0 else 1
        am = op.address_mode
        if op.type == M.M68K_OP_REG:
            reg = op.reg
            if M.M68K_REG_A0 <= reg <= M.M68K_REG_A7:
                self.set_reg(reg, sext(value, size) & 0xFFFFFFFF)
            else:
                self.set_reg(reg, value, size)
            return
        if addr is not None:
            self.write(addr, size, value)
            return
        if am == M.M68K_AM_REGI_ADDR_POST_INC:
            r = self._base(op)
            a = self.get_reg(r)
            step = 2 if (size == 1 and r == M.M68K_REG_A7) else size
            self.set_reg(r, a + step)
            self.write(a, size, value)
            return
        if am == M.M68K_AM_REGI_ADDR_PRE_DEC:
            r = self._base(op)
            step = 2 if (size == 1 and r == M.M68K_REG_A7) else size
            a = (self.get_reg(r) - step) & 0xFFFFFFFF
            self.set_reg(r, a)
            self.write(a, size, value)
            return
        self.write(self.ea(op, size), size, value)

    def rmw(self, op, size: int, fn) -> int:
        """Read-modify-write a destination operand once (one effective-address evaluation)."""
        self._op_index = 0 if op is self._ops0 else 1
        if op.type == M.M68K_OP_REG:
            old = self.get_reg(op.reg) & MASK[size]
            new = fn(old)
            self.write_op(op, size, new)
            return new
        am = op.address_mode
        if am == M.M68K_AM_REGI_ADDR_POST_INC:
            r = self._base(op)
            addr = self.get_reg(r)
            self.set_reg(r, addr + size)
        elif am == M.M68K_AM_REGI_ADDR_PRE_DEC:
            r = self._base(op)
            addr = (self.get_reg(r) - size) & 0xFFFFFFFF
            self.set_reg(r, addr)
        else:
            addr = self.ea(op, size)
        old = self.read(addr, size)
        new = fn(old)
        self.write(addr, size, new)
        return new

    # ---- flags --------------------------------------------------------------------------
    def nz(self, v: int, size: int) -> None:
        v &= MASK[size]
        self.n = 1 if v & SIGN[size] else 0
        self.z = 1 if v == 0 else 0

    def logic_flags(self, v: int, size: int) -> None:
        self.nz(v, size)
        self.v = self.c = 0

    def add_flags(self, a: int, b: int, size: int) -> int:
        r = (a + b) & MASK[size]
        self.nz(r, size)
        sa, sb, sr = a & SIGN[size], b & SIGN[size], r & SIGN[size]
        self.v = 1 if (sa == sb and sr != sa) else 0
        self.c = self.x = 1 if (a & MASK[size]) + (b & MASK[size]) > MASK[size] else 0
        return r

    def sub_flags(self, a: int, b: int, size: int, set_x: bool = True) -> int:
        """a - b."""
        r = (a - b) & MASK[size]
        self.nz(r, size)
        sa, sb, sr = a & SIGN[size], b & SIGN[size], r & SIGN[size]
        self.v = 1 if (sa != sb and sr != sa) else 0
        c = 1 if (b & MASK[size]) > (a & MASK[size]) else 0
        self.c = c
        if set_x:
            self.x = c
        return r

    def cond(self, cc: str) -> bool:
        n, z, v, c = self.n, self.z, self.v, self.c
        return {
            "t": True, "f": False, "ra": True,
            "hi": not c and not z, "ls": bool(c or z),
            "cc": not c, "hs": not c, "cs": bool(c), "lo": bool(c),
            "ne": not z, "eq": bool(z), "vc": not v, "vs": bool(v),
            "pl": not n, "mi": bool(n),
            "ge": n == v, "lt": n != v, "gt": not z and n == v, "le": bool(z) or n != v,
        }[cc]

    # ---- execution ----------------------------------------------------------------------
    def decode(self, pc: int):
        ins = self._cache.get(pc)
        if ins is None:
            ins = next(self.md.disasm(bytes(self.mem[pc : pc + 12]), pc))
            self._cache[pc] = ins
        return ins

    def call(self, address: int, args: list[int], a7: int, max_steps: int = 5_000_000) -> int:
        """Call the routine at a runtime address with long arguments (pushed right to left). The step
        limit applies to this call alone."""
        self.steps = 0
        self.a[7] = a7
        for value in reversed(args):
            self.push(value)
        self.push(RETURN_SENTINEL)
        self.pc = address
        while self.pc != RETURN_SENTINEL:
            if self.pc in self.stubs:
                ret = self.pop()
                self.d[0] = self.stubs[self.pc](self) & 0xFFFFFFFF
                self.pc = ret
                continue
            self.step()
            self.steps += 1
            if self.steps > max_steps:
                raise RuntimeError("step limit")
        self.a[7] = (self.a[7] + 4 * len(args)) & 0xFFFFFFFF
        return self.d[0]

    def step(self) -> None:
        ins = self.decode(self.pc)
        mn = ins.mnemonic
        base, _, suffix = mn.partition(".")
        size = {"b": 1, "w": 2, "l": 4, "s": 1}.get(suffix, 4)
        ops = list(ins.operands)
        nxt = self.pc + ins.size
        self.cur = self.pc
        self.cur_ins = ins
        self._ops0 = ops[0] if ops else None
        handler = getattr(self, "op_" + base, None)
        if handler is None:
            if base.startswith("b") and len(base) == 3 and base[1:] in ("ra", "eq", "ne", "lt", "le", "gt", "ge", "hi", "ls", "cc", "cs", "pl", "mi", "vc", "vs", "hs", "lo"):
                target = ops[0].br_disp.disp + self.pc + 2
                self.pc = target if self.cond(base[1:]) else nxt
                return
            if base.startswith("s") and base[1:] in ("eq", "ne", "lt", "le", "gt", "ge", "hi", "ls", "cc", "cs", "pl", "mi", "t", "f"):
                self.write_op(ops[0], 1, 0xFF if self.cond(base[1:]) else 0)
                self.pc = nxt
                return
            if base.startswith("db"):
                cc = base[2:]
                cc = "f" if cc in ("ra", "f") else cc
                if not self.cond(cc):
                    r = ops[0].reg
                    cnt = (self.get_reg(r) - 1) & 0xFFFF
                    self.set_reg(r, cnt, 2)
                    if cnt != 0xFFFF:
                        self.pc = ops[1].br_disp.disp + self.pc + 2
                        return
                self.pc = nxt
                return
            raise NotImplementedError(f"{mn} {ins.op_str} at {self.pc:#x}")
        self.pc = nxt
        handler(ins, ops, size, nxt)

    # moves
    def op_move(self, ins, ops, size, nxt):
        v = self.read_op(ops[0], size)
        self.write_op(ops[1], size, v)
        self.logic_flags(v, size)

    def op_movea(self, ins, ops, size, nxt):
        v = self.read_op(ops[0], size)
        self.set_reg(ops[1].reg, sext(v, size) & 0xFFFFFFFF)

    def op_moveq(self, ins, ops, size, nxt):
        v = sext(ops[0].imm, 1) & 0xFFFFFFFF
        self.set_reg(ops[1].reg, v)
        self.logic_flags(v, 4)

    def op_clr(self, ins, ops, size, nxt):
        self.write_op(ops[0], size, 0)
        self.n = self.v = self.c = 0
        self.z = 1

    def op_lea(self, ins, ops, size, nxt):
        self.set_reg(ops[1].reg, self.ea(ops[0], 4))

    def op_pea(self, ins, ops, size, nxt):
        self.push(self.ea(ops[0], 4))

    def op_link(self, ins, ops, size, nxt):
        r = ops[0].reg
        self.push(self.get_reg(r))
        self.set_reg(r, self.a[7])
        self.a[7] = (self.a[7] + sext(ops[1].imm, 2 if suffix_w(ins) else 4)) & 0xFFFFFFFF

    def op_unlk(self, ins, ops, size, nxt):
        r = ops[0].reg
        self.a[7] = self.get_reg(r)
        self.set_reg(r, self.pop())

    def _regs(self, op):
        bits = op.register_bits
        return [M.M68K_REG_D0 + i for i in range(8) if bits & (1 << i)] + [M.M68K_REG_A0 + i for i in range(8) if bits & (1 << (8 + i))]

    def op_movem(self, ins, ops, size, nxt):
        """movem decoded from its own words (capstone leaves the base register empty):
        opcode, register mask, then the effective-address extension."""
        opcode = self.read(ins.address, 2)
        mask = self.read(ins.address + 2, 2)
        mode, reg = (opcode >> 3) & 7, opcode & 7
        to_memory = not (opcode & 0x0400)
        base = M.M68K_REG_A0 + reg
        if mode == 4:  # -(An): mask bit 0 = A7 ... bit 15 = D0
            regs = [M.M68K_REG_D0 + i for i in range(8)] + [M.M68K_REG_A0 + i for i in range(8)]
            addr = self.get_reg(base)
            for bit in range(16):
                if mask & (1 << bit):
                    r = regs[15 - bit]
                    addr = (addr - size) & 0xFFFFFFFF
                    self.write(addr, size, self.get_reg(r))
            self.set_reg(base, addr)
            return
        regs = [M.M68K_REG_D0 + i for i in range(8) if mask & (1 << i)] + [M.M68K_REG_A0 + i for i in range(8) if mask & (1 << (8 + i))]
        if mode == 2:
            addr = self.get_reg(base)
        elif mode == 3:
            addr = self.get_reg(base)
        elif mode == 5:
            addr = (self.get_reg(base) + sext(self.read(ins.address + 4, 2), 2)) & 0xFFFFFFFF
        else:
            raise NotImplementedError(f"movem mode {mode} at {ins.address:#x}")
        for r in regs:
            if to_memory:
                self.write(addr, size, self.get_reg(r))
            else:
                v = self.read(addr, size)
                self.set_reg(r, (sext(v, 2) & 0xFFFFFFFF) if size == 2 else v)
            addr += size
        if mode == 3:
            self.set_reg(base, addr)

    def op_swap(self, ins, ops, size, nxt):
        r = ops[0].reg
        v = self.get_reg(r)
        v = ((v << 16) | (v >> 16)) & 0xFFFFFFFF
        self.set_reg(r, v)
        self.logic_flags(v, 4)

    def op_ext(self, ins, ops, size, nxt):
        r = ops[0].reg
        v = self.get_reg(r)
        if size == 2:
            v = sext(v, 1) & 0xFFFF
            self.set_reg(r, v, 2)
        else:
            v = sext(v, 2) & 0xFFFFFFFF
            self.set_reg(r, v)
        self.logic_flags(v, size)

    def op_extb(self, ins, ops, size, nxt):
        r = ops[0].reg
        v = sext(self.get_reg(r), 1) & 0xFFFFFFFF
        self.set_reg(r, v)
        self.logic_flags(v, 4)

    def op_exg(self, ins, ops, size, nxt):
        a, b = self.get_reg(ops[0].reg), self.get_reg(ops[1].reg)
        self.set_reg(ops[0].reg, b)
        self.set_reg(ops[1].reg, a)

    # arithmetic
    def op_add(self, ins, ops, size, nxt):
        s = self.read_op(ops[0], size)
        self.rmw(ops[1], size, lambda d: self.add_flags(d, s, size))

    op_addi = op_add

    def op_addq(self, ins, ops, size, nxt):
        s = ops[0].imm
        dst = ops[1]
        if dst.type == M.M68K_OP_REG and not self._is_d(dst.reg):
            self.set_reg(dst.reg, self.get_reg(dst.reg) + s)
            return
        self.rmw(dst, size, lambda d: self.add_flags(d, s, size))

    def op_addx(self, ins, ops, size, nxt):
        """Register form: Dx += Dy + X; Z is only cleared (multi-precision chains)."""
        s = self.read_op(ops[0], size)
        z = self.z
        a = self.read_op(ops[1], size)
        r = (a + s + self.x) & MASK[size]
        sa, sb, sr = a & SIGN[size], s & SIGN[size], r & SIGN[size]
        self.n = 1 if sr else 0
        self.z = z if r == 0 else 0
        self.v = 1 if (sa == sb and sr != sa) else 0
        self.c = self.x = 1 if (a & MASK[size]) + (s & MASK[size]) + self.x > MASK[size] else 0
        self.write_op(ops[1], size, r)

    def op_adda(self, ins, ops, size, nxt):
        s = sext(self.read_op(ops[0], size), size)
        self.set_reg(ops[1].reg, self.get_reg(ops[1].reg) + s)

    def op_sub(self, ins, ops, size, nxt):
        s = self.read_op(ops[0], size)
        self.rmw(ops[1], size, lambda d: self.sub_flags(d, s, size))

    op_subi = op_sub

    def op_subq(self, ins, ops, size, nxt):
        s = ops[0].imm
        dst = ops[1]
        if dst.type == M.M68K_OP_REG and not self._is_d(dst.reg):
            self.set_reg(dst.reg, self.get_reg(dst.reg) - s)
            return
        self.rmw(dst, size, lambda d: self.sub_flags(d, s, size))

    def op_suba(self, ins, ops, size, nxt):
        s = sext(self.read_op(ops[0], size), size)
        self.set_reg(ops[1].reg, self.get_reg(ops[1].reg) - s)

    def op_neg(self, ins, ops, size, nxt):
        self.rmw(ops[0], size, lambda d: self.sub_flags(0, d, size))

    def op_cmp(self, ins, ops, size, nxt):
        s = self.read_op(ops[0], size)
        d = self.read_op(ops[1], size)
        self.sub_flags(d, s, size, set_x=False)

    op_cmpi = op_cmp

    def op_cmpa(self, ins, ops, size, nxt):
        s = sext(self.read_op(ops[0], size), size) & 0xFFFFFFFF
        d = self.get_reg(ops[1].reg)
        self.sub_flags(d, s, 4, set_x=False)

    def op_tst(self, ins, ops, size, nxt):
        self.logic_flags(self.read_op(ops[0], size), size)

    def op_muls(self, ins, ops, size, nxt):
        if size == 2:
            s = sext(self.read_op(ops[0], 2), 2)
            r = ops[1].reg
            v = (sext(self.get_reg(r), 2) * s) & 0xFFFFFFFF
            self.set_reg(r, v)
            self.logic_flags(v, 4)
        else:
            ext = self.read(ins.address + 2, 2)
            dl, dh = M.M68K_REG_D0 + ((ext >> 12) & 7), M.M68K_REG_D0 + (ext & 7)
            s = sext(self.read_op(ops[0], 4), 4)
            v = sext(self.get_reg(dl), 4) * s if ext & 0x0800 else (self.get_reg(dl) * (s & 0xFFFFFFFF))
            if ext & 0x0400:
                self.set_reg(dh, (v >> 32) & 0xFFFFFFFF)
            self.set_reg(dl, v & 0xFFFFFFFF)
            self.logic_flags(v & 0xFFFFFFFF, 4)
            self.v = 0 if (ext & 0x0400) or -0x80000000 <= v <= 0x7FFFFFFF else 1

    def op_mulu(self, ins, ops, size, nxt):
        s = self.read_op(ops[0], 2)
        r = ops[1].reg
        v = ((self.get_reg(r) & 0xFFFF) * s) & 0xFFFFFFFF
        self.set_reg(r, v)
        self.logic_flags(v, 4)

    @staticmethod
    def _tdiv(a: int, b: int) -> tuple[int, int]:
        q = abs(a) // abs(b)
        if (a < 0) != (b < 0):
            q = -q
        return q, a - q * b

    def op_divs(self, ins, ops, size, nxt):
        if size == 2:
            s = sext(self.read_op(ops[0], 2), 2)
            r = ops[1].reg
            if s == 0:
                raise ZeroDivisionError(f"divs.w by zero at {self.pc:#x}")
            q, rem = self._tdiv(sext(self.get_reg(r), 4), s)
            if not -0x8000 <= q <= 0x7FFF:
                self.v = 1
                return
            self.set_reg(r, ((rem & 0xFFFF) << 16) | (q & 0xFFFF))
            self.logic_flags(q, 2)
            return
        # Long form: the extension word (after the opcode) names Dq (bits 12..14), Dr (bits 0..2),
        # signedness (bit 11) and a 64-bit dividend (bit 10); capstone may print divsl as a
        # plain divs.l, so it is decoded here.
        ext = self.read(ins.address + 2, 2)
        dq, dr = M.M68K_REG_D0 + ((ext >> 12) & 7), M.M68K_REG_D0 + (ext & 7)
        s = sext(self.read_op(ops[0], 4), 4)
        if s == 0:
            raise ZeroDivisionError(f"divs.l by zero at {self.pc:#x}")
        if ext & 0x0400:
            # 64-bit dividend Dr:Dq (Dr high); quotient to Dq, remainder to Dr; overflow sets V
            # and leaves both registers unchanged.
            dividend = (self.get_reg(dr) << 32) | self.get_reg(dq)
            if dividend & (1 << 63):
                dividend -= 1 << 64
            q, rem = self._tdiv(dividend, s)
            if not -0x80000000 <= q <= 0x7FFFFFFF:
                self.v = 1
                return
            self.set_reg(dr, rem & 0xFFFFFFFF)
            self.set_reg(dq, q & 0xFFFFFFFF)
            self.logic_flags(q & 0xFFFFFFFF, 4)
            return
        q, rem = self._tdiv(sext(self.get_reg(dq), 4), s)
        if not -0x80000000 <= q <= 0x7FFFFFFF:
            self.v = 1
            return
        if dr != dq:
            self.set_reg(dr, rem & 0xFFFFFFFF)
        self.set_reg(dq, q & 0xFFFFFFFF)
        self.logic_flags(q & 0xFFFFFFFF, 4)

    op_divsl = op_divs

    def op_divu(self, ins, ops, size, nxt):
        if size != 2:
            # Long form (as op_divs): Dq / Dr from the extension word, 32-bit dividend only.
            ext = self.read(ins.address + 2, 2)
            dq, dr = M.M68K_REG_D0 + ((ext >> 12) & 7), M.M68K_REG_D0 + (ext & 7)
            if ext & 0x0400:
                raise NotImplementedError(f"64-bit divu dividend at {ins.address:#x}")
            s = self.read_op(ops[0], 4)
            if s == 0:
                raise ZeroDivisionError(f"divu.l by zero at {self.pc:#x}")
            d = self.get_reg(dq)
            q, rem = d // s, d % s
            if dr != dq:
                self.set_reg(dr, rem)
            self.set_reg(dq, q)
            self.logic_flags(q, 4)
            return
        s = self.read_op(ops[0], 2)
        r = ops[1].reg
        if s == 0:
            raise ZeroDivisionError(f"divu.w by zero at {self.pc:#x}")
        d = self.get_reg(r)
        q, rem = d // s, d % s
        if q > 0xFFFF:
            self.v = 1
            return
        self.set_reg(r, (rem << 16) | q)
        self.logic_flags(q, 2)

    # logic
    def _logic(self, ops, size, fn):
        s = self.read_op(ops[0], size)

        def apply(d):
            r = fn(d, s) & MASK[size]
            self.logic_flags(r, size)
            return r
        self.rmw(ops[1], size, apply)

    def op_and(self, ins, ops, size, nxt):
        self._logic(ops, size, lambda d, s: d & s)

    op_andi = op_and

    def op_or(self, ins, ops, size, nxt):
        self._logic(ops, size, lambda d, s: d | s)

    op_ori = op_or

    def op_eor(self, ins, ops, size, nxt):
        self._logic(ops, size, lambda d, s: d ^ s)

    op_eori = op_eor

    def op_not(self, ins, ops, size, nxt):
        def apply(d):
            r = (~d) & MASK[size]
            self.logic_flags(r, size)
            return r
        self.rmw(ops[0], size, apply)

    def _bit(self, ops, kind):
        bit = self.read_op(ops[0], 4)
        dst = ops[1]
        width = 32 if dst.type == M.M68K_OP_REG else 8
        bit %= width
        size = 4 if width == 32 else 1

        def apply(d):
            self.z = 0 if d & (1 << bit) else 1
            if kind == "set":
                return d | (1 << bit)
            if kind == "clr":
                return d & ~(1 << bit)
            if kind == "chg":
                return d ^ (1 << bit)
            return d
        if kind == "tst":
            apply(self.read_op(dst, size))
        else:
            self.rmw(dst, size, apply)

    def op_btst(self, ins, ops, size, nxt):
        self._bit(ops, "tst")

    def op_bset(self, ins, ops, size, nxt):
        self._bit(ops, "set")

    def op_bclr(self, ins, ops, size, nxt):
        self._bit(ops, "clr")

    def op_bchg(self, ins, ops, size, nxt):
        self._bit(ops, "chg")

    # shifts
    def _shift(self, ops, size, kind):
        if len(ops) == 1:
            count, dst = 1, ops[0]
        else:
            count = self.read_op(ops[0], 4)
            count = count % 64 if ops[0].type == M.M68K_OP_REG else count
            dst = ops[1]

        def apply(d):
            v = d & MASK[size]
            c = 0
            for _ in range(count):
                if kind in ("asl", "lsl"):
                    c = 1 if v & SIGN[size] else 0
                    v = (v << 1) & MASK[size]
                elif kind == "asr":
                    c = v & 1
                    v = (v >> 1) | (v & SIGN[size])
                else:
                    c = v & 1
                    v >>= 1
            self.nz(v, size)
            self.v = 0
            if count:
                self.c = self.x = c
            else:
                self.c = 0
            return v
        self.rmw(dst, size, apply)

    def op_asl(self, ins, ops, size, nxt):
        self._shift(ops, size, "asl")

    def op_asr(self, ins, ops, size, nxt):
        self._shift(ops, size, "asr")

    def op_lsl(self, ins, ops, size, nxt):
        self._shift(ops, size, "lsl")

    def op_lsr(self, ins, ops, size, nxt):
        self._shift(ops, size, "lsr")

    def _rotate_x(self, ops, size, left):
        """roxl / roxr: rotate through X; C = X = the last bit out (count 0: C = X)."""
        if len(ops) == 1:
            count, dst = 1, ops[0]
        else:
            count = self.read_op(ops[0], 4)
            count = count % 64 if ops[0].type == M.M68K_OP_REG else count
            dst = ops[1]

        def apply(d):
            v = d & MASK[size]
            x = self.x
            for _ in range(count):
                if left:
                    out = 1 if v & SIGN[size] else 0
                    v = ((v << 1) | x) & MASK[size]
                else:
                    out = v & 1
                    v = (v >> 1) | (SIGN[size] if x else 0)
                x = out
            self.nz(v, size)
            self.v = 0
            self.x = x
            self.c = x
            return v
        self.rmw(dst, size, apply)

    def op_roxl(self, ins, ops, size, nxt):
        self._rotate_x(ops, size, True)

    def op_roxr(self, ins, ops, size, nxt):
        self._rotate_x(ops, size, False)

    # flow
    def op_bra(self, ins, ops, size, nxt):
        self.pc = ops[0].br_disp.disp + ins.address + 2

    def op_bsr(self, ins, ops, size, nxt):
        self.push(nxt)
        self.pc = ops[0].br_disp.disp + ins.address + 2

    def op_jsr(self, ins, ops, size, nxt):
        target = self.ea(ops[0], 4)
        self.push(nxt)
        self.pc = target

    def op_jmp(self, ins, ops, size, nxt):
        self.pc = self.ea(ops[0], 4)

    def op_rts(self, ins, ops, size, nxt):
        self.pc = self.pop()

    def op_nop(self, ins, ops, size, nxt):
        pass


def suffix_w(ins) -> bool:
    return ins.mnemonic.endswith(".w")
