class_name Fixed68k
extends RefCounted
## Fixed-point and integer math consistent with 68k (no float in sim).
## Implemented: mul32/add32 (standard 68k wrap). scale_trunc / 12.4 are interface-only until RE proves ID03 layout.

## 68k-style 32-bit multiply: low 32 bits of product (no overflow to 64 in result).
static func mul32(a: int, b: int) -> int:
	return (a * b) & 0xFFFFFFFF

## 68k-style 32-bit add with wrap.
static func add32(a: int, b: int) -> int:
	return (a + b) & 0xFFFFFFFF

## Signed 32-bit clamp (68k word is 16-bit; use 32 for intermediates).
static func clamp_s32(v: int) -> int:
	if v > 0x7FFFFFFF:
		return 0x7FFFFFFF
	if v < -0x80000000:
		return -0x80000000
	return v

## Scale value by numerator/denominator (integer). Interface-only until RE proves scaling semantics.
static func scale_trunc(value: int, num: int, den: int) -> int:
	if den == 0:
		return 0
	return (value * num) / den

## Fixed-point 12.4: interface-only until RE proves ID03 layout.
const SCALE_12_4_DENOM := 0x1000

static func from_12_4(raw: int) -> int:
	return raw

static func to_12_4(v: int) -> int:
	return (v * SCALE_12_4_DENOM) & 0xFFFFFFFF
