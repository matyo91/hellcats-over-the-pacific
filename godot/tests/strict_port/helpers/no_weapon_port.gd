extends "res://strict_port/code/pacific_conflict.gd"

## The strict port with spawn_weapon_entity and spawn_ordnance_oriented stubbed as
## tools/strict_port/gen_ai_state_cases.py stubs them at file 0x12840 / 0x15d20 (a bomb drop or
## a gun burst needs a live object pool): the arguments are recorded as longs at 0x3f100 /
## 0x3f200 and 0 (no object) is returned.
const ARGS_WEAPON := 0x3f100
const ARGS_ORDNANCE := 0x3f200

func spawn_weapon_entity(speed: int, flag_40: int, x: int, y: int, z: int, pitch: int, att_22: int, bank: int) -> int:
	_record(ARGS_WEAPON, [speed, flag_40, x, y, z, pitch, att_22, bank])
	return 0

func spawn_ordnance_oriented(speed: int, mode: int, x: int, y: int, z: int, att_b: int, att_c: int, att_d: int, att_a: int) -> int:
	_record(ARGS_ORDNANCE, [speed, mode, x, y, z, att_b, att_c, att_d, att_a])
	return 0

func _record(out: int, args: Array) -> void:
	for i in args.size():
		memory.write_u32(out + 4 * i, C68kScript.u32(args[i]))
