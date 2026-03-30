class_name EntityTemplate
extends RefCounted
## External pointed-to record at param_1[1]; only proven offsets added here.

const OFFSETS := {
	"field_1e": 0x1e,
	"field_38": 0x38,
	"field_3c": 0x3c,
	"field_3e": 0x3e,
	"field_40": 0x40,
	"field_42": 0x42,
	"field_44": 0x44,
	"field_46": 0x46,
	"field_48": 0x48,
}

var data: Dictionary = {}

func _init() -> void:
	for key in OFFSETS:
		data[key] = 0

func get_field(key: String) -> int:
	return data.get(key, 0) as int

func get_u16_field(key: String) -> int:
	return get_field(key) & 0xFFFF

func get_s16_field(key: String) -> int:
	var value := get_u16_field(key)
	return value - 0x1_0000 if (value & 0x8000) != 0 else value

func set_u16_field(key: String, value: int) -> void:
	data[key] = value & 0xFFFF

func set_s16_field(key: String, value: int) -> void:
	data[key] = value & 0xFFFF
