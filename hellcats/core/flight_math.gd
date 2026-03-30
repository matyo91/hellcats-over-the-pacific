class_name FlightMath
extends RefCounted
## Clean-room helper math reconstructed from Pacific Conflict.c.

const E42A_TABLE := [
	0x0038C460,
	0x00504AE0,
	0x00718EEF,
	0x00A09E00,
	0x00E3369F,
	0x002D002D,
	0x001E000F,
	0x00070002,
	0x000001A5,
]

static func _to_s16(value: int) -> int:
	value &= 0xFFFF
	return value - 0x1_0000 if (value & 0x8000) != 0 else value

static func _half_toward_zero(value: int) -> int:
	if value < 0:
		value += 1
	return value >> 1

static func fun_0000e42a(param_1: int) -> int:
	var index: int = (param_1 >> 16) & 0xFFFF
	if index > 7:
		index = 7
	var current: int = E42A_TABLE[index]
	var nxt: int = E42A_TABLE[index + 1]
	var fraction: int = param_1 & 0xFFFF
	var interpolated: int = _to_s16(current) + ((fraction * (nxt - current)) >> 16)
	return _to_s16(interpolated)

static func fun_0000e468(param_1: int, param_2: int) -> int:
	if param_1 < 0x200:
		var scaled: int = -(param_1 - 0x200) * param_2
		if scaled < 0:
			scaled += 0xFFF
		param_2 -= scaled >> 12
	return param_2

static func fun_0000e570(template_field_38: int, param_1: int) -> int:
	var denominator: int = (param_1 + 0x105) >> 3
	if denominator <= 0:
		return 0
	var ratio: int = int(0x551A / denominator)
	return (template_field_38 * ratio) >> 8

static func compute_template_field_40_adjustment(template_field_40: int, direction_char_679: int) -> int:
	if direction_char_679 == 0x2D:
		return template_field_40
	return _half_toward_zero(template_field_40)

static func compute_local_34(template_field_3c: int, template_field_3e: int, local_26: int, s_var21: int, i_var20: int) -> int:
	if s_var21 == 0:
		return 0
	if template_field_3e < i_var20:
		return ((local_26 * s_var21) / 9) / i_var20
	return (s_var21 * template_field_3c) / 9

## Proven delta rule (Pacific Conflict.c:14182-14194, 14207-14220, 14230-14239): if |delta| < 8 add delta, else add (delta+7*(delta<0))>>3.
static func add_delta_smoothed_int(current: int, delta: int) -> int:
	var d: int = delta
	if d < 0:
		d += 7
	if (d >> 3) == 0:
		return current + delta
	return current + ((delta + (7 if delta < 0 else 0)) >> 3)

## Same rule for short (0x672); returns new value in short range.
static func add_delta_smoothed_s16(current_s16: int, delta: int) -> int:
	var current: int = current_s16 & 0xFFFF
	if (current & 0x8000) != 0:
		current -= 0x1_0000
	var d: int = delta
	if d < 0:
		d += 7
	var add_val: int
	if (d >> 3) == 0:
		add_val = delta
	else:
		add_val = (delta + (7 if delta < 0 else 0)) >> 3
	var result: int = current + add_val
	result = result & 0xFFFF
	return result - 0x1_0000 if (result & 0x8000) != 0 else result
