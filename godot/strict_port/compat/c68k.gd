class_name C68k
extends RefCounted
## Explicit C / Motorola 68000 integer-width compatibility operations.
## Keep strict ports dependent on this layer instead of GDScript's implicit widths.

static func u8(value: int) -> int:
	return value & 0xff

static func s8(value: int) -> int:
	value &= 0xff
	return value - 0x100 if value >= 0x80 else value

static func u16(value: int) -> int:
	return value & 0xffff

static func s16(value: int) -> int:
	value &= 0xffff
	return value - 0x10000 if value >= 0x8000 else value

static func u32(value: int) -> int:
	return value & 0xffffffff

static func s32(value: int) -> int:
	value &= 0xffffffff
	return value - 0x100000000 if value >= 0x80000000 else value

static func lsl32(value: int, count: int) -> int:
	return u32(u32(value) << (count & 0x3f))

static func lsr32(value: int, count: int) -> int:
	return u32(value) >> (count & 0x3f)

static func asr32(value: int, count: int) -> int:
	return s32(value) >> (count & 0x3f)

## C89-style signed division: truncate toward zero, unlike floor division.
static func divs_trunc(numerator: int, denominator: int) -> int:
	assert(denominator != 0, "C division by zero is undefined")
	var magnitude: int = abs(numerator) / abs(denominator)
	return -magnitude if (numerator < 0) != (denominator < 0) else magnitude

static func rems_trunc(numerator: int, denominator: int) -> int:
	return numerator - divs_trunc(numerator, denominator) * denominator

## 68020 divs.l <ea>,Dr:Dq (64 / 32 -> 32 quotient, truncating). On overflow (quotient
## outside 32 bits) V is set and Dq keeps its value: the low long of the dividend.
static func divs_l_64_32(dividend: int, divisor: int) -> int:
	assert(divisor != 0, "68020 divs.l by zero traps")
	var quotient: int = divs_trunc(dividend, divisor)
	if quotient < -0x80000000 or quotient > 0x7fffffff:
		return s32(dividend)
	return quotient
