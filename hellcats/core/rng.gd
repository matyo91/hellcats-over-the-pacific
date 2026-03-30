class_name Rng68k
extends RefCounted
## LCG RNG matching ID05.c FUN_00000728 / FUN_00000746.
## state = state * 0x41c64e6d + 0x3039 (mod 2^32)
## Original returns (state << 1) >> 0x11 (15 bits).

const LCG_MUL: int = 0x41c64e6d
const LCG_ADD: int = 0x3039
const MOD32: int = 0x1_0000_0000

var _state: int = 0

func _init(initial_seed: int = 0) -> void:
	seed(initial_seed)

func seed(s: int) -> void:
	_state = _wrap_u32(s)

static func _wrap_u32(value: int) -> int:
	return posmod(value, MOD32)

## GDScript ints are 64-bit, so modulo-2^32 arithmetic is exact here.
static func _mul32(a: int, b: int) -> int:
	return _wrap_u32(_wrap_u32(a) * _wrap_u32(b))

func _step() -> void:
	_state = _wrap_u32(_mul32(_state, LCG_MUL) + LCG_ADD)

## Advance and return 15-bit value (matches decompiler return).
func next() -> int:
	_step()
	return (_state >> 16) & 0x7FFF

## 16-bit value: high 16 bits of state (deterministic, one advance).
func next_u16() -> int:
	_step()
	return (_state >> 16) & 0xFFFF

## 8-bit value: high 8 bits of state (one advance).
func next_u8() -> int:
	_step()
	return (_state >> 24) & 0xFF

## Expose state for test vectors (read-only).
func get_state() -> int:
	return _state
