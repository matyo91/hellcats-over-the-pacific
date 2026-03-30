class_name EntityState
extends RefCounted
## Entity state with only proven offsets (Pacific Conflict / FUN_0000e792, FUN_000041ec).
## Store as Dictionary keyed by offset name; can swap to PackedByteArray later.

## Proven offset keys (string) -> int value. Use 32-bit where original is 32-bit.
const OFFSETS := {
	"field_00": 0x00,   # type byte
	"field_04": 0x04,
	"entity_data_ptr": 0x08,
	"position_velocity_c": 0x0c,
	"ptr_10": 0x10,
	"ptr_14": 0x14,
	"pos_18": 0x18,
	"pos_1c": 0x1c,
	"pos_20": 0x20,
	"pos_2e": 0x2e,
	"state_32": 0x32,
	"count_3a": 0x3a,
	"ptr_48": 0x48,
	"index_50": 0x50,
	"movement_61a": 0x61a,
	"movement_61e": 0x61e,
	"movement_662": 0x662,
	"movement_666": 0x666,
	"movement_62a": 0x62a,
	"movement_669": 0x669,
	"movement_66a": 0x66a,
	"movement_66e": 0x66e,
	"movement_672": 0x672,
	"weapon_count_67c": 0x67c,
	"weapon_count_67d": 0x67d,
	"weapon_count_67e": 0x67e,
	"direction_char_679": 0x679,
	"flags_685": 0x685,
	"field_19a": 0x19a,
	"status_1a0": 0x1a0,
	"status_1a1": 0x1a1,
	"status_1a3": 0x1a3,
}

var data: Dictionary = {}
var external_template: RefCounted = null

func _init() -> void:
	for key in OFFSETS:
		data[key] = 0

func get_field(key: String) -> int:
	return data.get(key, 0) as int

func set_field(key: String, value: int) -> void:
	data[key] = value & 0xFFFFFFFF if value >= 0 else (value + 0x1_0000_0000) & 0xFFFFFFFF

func get_u8_field(key: String) -> int:
	return get_field(key) & 0xFF

func get_s8_field(key: String) -> int:
	var value := get_u8_field(key)
	return value - 0x100 if (value & 0x80) != 0 else value

func get_u16_field(key: String) -> int:
	return get_field(key) & 0xFFFF

func get_s16_field(key: String) -> int:
	var value := get_u16_field(key)
	return value - 0x1_0000 if (value & 0x8000) != 0 else value

func set_u8_field(key: String, value: int) -> void:
	data[key] = value & 0xFF

func set_s8_field(key: String, value: int) -> void:
	data[key] = value & 0xFF

func set_u16_field(key: String, value: int) -> void:
	data[key] = value & 0xFFFF

func set_s16_field(key: String, value: int) -> void:
	data[key] = value & 0xFFFF

## Optional: build from PackedByteArray when format is fixed (big-endian).
static func from_bytes(_buf: PackedByteArray, _base: int) -> EntityState:
	var e := EntityState.new()
	# TODO: decode when layout is final
	return e
