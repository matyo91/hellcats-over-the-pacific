class_name StrictID01
extends RefCounted
## Strict translations owned by CODE segment 1 (ID01.bin; address = file offset, 4-byte header).
## The sole provenance and verification record lives in mappings/functions.json.
##
## The 32-bit divide runtime. The stack entries (0x110 / 0x130 / 0x152 / 0x172) take the dividend
## at 4(A7) and the divisor at 8(A7), pop both themselves and preserve D1; they are modelled as
## functions of the two longs returning D0. The cores (0x194 / 0x1c2) take D0 = dividend, D1 =
## divisor and are modelled as returning [D0, D1] = [quotient, remainder]. A zero divisor reaches
## a DIVU.W by zero in the original (the zero-divide exception); the port asserts instead.

const C68kScript := preload("res://strict_port/compat/c68k.gd")

## 0x110: unsigned quotient (JSR 0x1c2; D0).
static func rt_udiv32(dividend: int, divisor: int) -> int:
	return rt_udivmod32_core(dividend, divisor)[0]

## 0x130: unsigned remainder (JSR 0x1c2; MOVE.L D1,D0).
static func rt_umod32(dividend: int, divisor: int) -> int:
	return rt_udivmod32_core(dividend, divisor)[1]

## 0x152: signed quotient (JSR 0x194; D0), truncating toward zero.
static func rt_sdiv32(dividend: int, divisor: int) -> int:
	return rt_sdivmod32_core(dividend, divisor)[0]

## 0x172: signed remainder (JSR 0x194; MOVE.L D1,D0), with the dividend's sign.
static func rt_smod32(dividend: int, divisor: int) -> int:
	return rt_sdivmod32_core(dividend, divisor)[1]

## 0x194: NEG.L the negative operands, the unsigned core, then NEG.L the quotient when the signs
## differ and the remainder when the dividend was negative (32-bit, so 0x80000000 negates to
## itself). Both non-negative: BPL falls into the core at 0x1c2.
static func rt_sdivmod32_core(dividend: int, divisor: int) -> Array:
	var d0: int = C68kScript.u32(dividend)
	var d1: int = C68kScript.u32(divisor)
	if (d0 & 0x80000000) != 0:
		if (d1 & 0x80000000) != 0:
			var both: Array = rt_udivmod32_core(C68kScript.u32(-d0), C68kScript.u32(-d1))
			return [both[0], C68kScript.u32(-both[1])]
		var r: Array = rt_udivmod32_core(C68kScript.u32(-d0), d1)
		return [C68kScript.u32(-r[0]), C68kScript.u32(-r[1])]
	if (d1 & 0x80000000) != 0:
		var q: Array = rt_udivmod32_core(d0, C68kScript.u32(-d1))
		return [C68kScript.u32(-q[0]), q[1]]
	return rt_udivmod32_core(d0, d1)

## 0x1c2: D7 = 0xffff. Divisor above the dividend: [0, dividend]. Dividend <= 0xffff: one DIVU.W.
## Divisor <= 0xffff: DIVU.W of the high word, then of (remainder : low word). Otherwise both are
## shifted right (LSR.L, then compared: at least once) until the divisor fits a word, the DIVU.W
## estimate is masked to a word and corrected with SUBQ.W while the multiplied-back divisor
## (low MULU.W plus the SWAPped high MULU.W, both halves) carries or exceeds the dividend; the
## remainder is NEG.L of (product - dividend).
static func rt_udivmod32_core(dividend: int, divisor: int) -> Array:
	var d0: int = C68kScript.u32(dividend)
	var d1: int = C68kScript.u32(divisor)
	if d1 > d0:
		return [0, d0]
	assert(d1 != 0, "rt_udivmod32_core: DIVU.W by zero (the original takes the zero-divide exception)")
	if d0 <= 0xffff:
		return [d0 / (d1 & 0xffff), d0 % (d1 & 0xffff)]
	if d1 <= 0xffff:
		var hi_q: int = (d0 >> 16) / d1
		var mid: int = (((d0 >> 16) % d1) << 16) | (d0 & 0xffff)
		return [(hi_q << 16) | (mid / d1 & 0xffff), mid % d1]
	var n: int = d0
	var d: int = d1
	while true:
		n >>= 1
		d >>= 1
		if d <= 0xffff:
			break
	var quot: int = (n / d) & 0xffff
	var sum: int = _multiply_back(d1, quot)
	while sum > 0xffffffff or sum > d0:
		quot = (quot & 0xffff0000) | ((quot - 1) & 0xffff)
		sum = _multiply_back(d1, quot)
	return [quot, C68kScript.u32(d0 - sum)]

## 0x210..0x21c: MULU.W of the divisor's low word, plus the SWAPped (both halves) MULU.W of its
## high word; a result above 0xffffffff is the ADD.L carry.
static func _multiply_back(divisor: int, quot: int) -> int:
	var lo: int = (divisor & 0xffff) * (quot & 0xffff)
	var hi: int = (divisor >> 16) * (quot & 0xffff)
	return lo + (((hi << 16) | (hi >> 16)) & 0xffffffff)
