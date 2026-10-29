extends "res://strict_port/code/pacific_conflict.gd"

## The strict port with some spawn routines stubbed as the interpreter fixtures stub them (a bomb,
## a gun burst or a pool object needs a live object pool): a function named in `stubs` appends
## its arguments to a log at the given address (call count, then the longs of each call) and
## returns 0 (no object); the others run as ported. Code pointers named by the fixture's "call_logs" log their calls (log_call).
var stubs: Dictionary = {}

func spawn_weapon_entity(speed: int, flag_40: int, x: int, y: int, z: int, pitch: int, att_22: int, bank: int) -> int:
	if stubs.has("spawn_weapon_entity"):
		return _record(stubs["spawn_weapon_entity"], [speed, flag_40, x, y, z, pitch, att_22, bank])
	return super(speed, flag_40, x, y, z, pitch, att_22, bank)

func spawn_ordnance_oriented(speed: int, mode: int, x: int, y: int, z: int, att_b: int, att_c: int, att_d: int, att_a: int) -> int:
	if stubs.has("spawn_ordnance_oriented"):
		return _record(stubs["spawn_ordnance_oriented"], [speed, mode, x, y, z, att_b, att_c, att_d, att_a])
	return super(speed, mode, x, y, z, att_b, att_c, att_d, att_a)

func spawn_mission_pool_object(tmpl_obj: int, off_x: int, off_y: int, off_z: int, angle1: int, angle2: int, angle3: int, factory_arg: int) -> int:
	if stubs.has("spawn_mission_pool_object"):
		return _record(stubs["spawn_mission_pool_object"], [tmpl_obj, off_x, off_y, off_z, angle1, angle2, angle3, factory_arg])
	return super(tmpl_obj, off_x, off_y, off_z, angle1, angle2, angle3, factory_arg)

## A host or depth routine reached through a code pointer: each call appends its arguments to
## the log at `base` (long count, then nargs longs per call) and returns the long at base - 4.
## An optional dereference appends deref_n longs read at argument deref_index (a buffer the
## routine passes by address, such as a polygon in its frame), and deref2_n more at
## deref2_index (a second buffer).
func log_call(base: int, args: Array, deref_index: int = -1, deref_n: int = 0, deref2_index: int = -1, deref2_n: int = 0) -> int:
	var values: Array = args.duplicate()
	for k in deref_n:
		values.append(memory.read_u32(C68kScript.u32(args[deref_index]) + 4 * k))
	for k in deref2_n:
		values.append(memory.read_u32(C68kScript.u32(args[deref2_index]) + 4 * k))
	var count: int = memory.read_u32(base)
	for i in values.size():
		memory.write_u32(base + 4 + (count * values.size() + i) * 4, C68kScript.u32(values[i]))
	memory.write_u32(base, count + 1)
	return memory.read_u32(base - 4)

func install_call_logs(logs: Array) -> void:
	for entry in logs:
		var base: int = int(entry[1])
		var di: int = int(entry[3]) if entry.size() > 3 else -1
		var dn: int = int(entry[4]) if entry.size() > 4 else 0
		var di2: int = int(entry[5]) if entry.size() > 5 else -1
		var dn2: int = int(entry[6]) if entry.size() > 6 else 0
		match int(entry[2]):
			0:
				code_table[int(entry[0])] = func() -> int: return log_call(base, [], di, dn, di2, dn2)
			1:
				code_table[int(entry[0])] = func(a: int) -> int: return log_call(base, [a], di, dn, di2, dn2)
			2:
				code_table[int(entry[0])] = func(a: int, b: int) -> int: return log_call(base, [a, b], di, dn, di2, dn2)
			3:
				code_table[int(entry[0])] = func(a: int, b: int, c: int) -> int: return log_call(base, [a, b, c], di, dn, di2, dn2)
			4:
				code_table[int(entry[0])] = func(a: int, b: int, c: int, d: int) -> int: return log_call(base, [a, b, c, d], di, dn, di2, dn2)
			5:
				code_table[int(entry[0])] = func(a: int, b: int, c: int, d: int, e: int) -> int: return log_call(base, [a, b, c, d, e], di, dn, di2, dn2)
			6:
				code_table[int(entry[0])] = func(a: int, b: int, c: int, d: int, e: int, f: int) -> int: return log_call(base, [a, b, c, d, e, f], di, dn, di2, dn2)
			7:
				code_table[int(entry[0])] = func(a: int, b: int, c: int, d: int, e: int, f: int, g: int) -> int: return log_call(base, [a, b, c, d, e, f, g], di, dn, di2, dn2)
			8:
				code_table[int(entry[0])] = func(a: int, b: int, c: int, d: int, e: int, f: int, g: int, h: int) -> int: return log_call(base, [a, b, c, d, e, f, g, h], di, dn, di2, dn2)
			9:
				code_table[int(entry[0])] = func(a: int, b: int, c: int, d: int, e: int, f: int, g: int, h: int, i: int) -> int: return log_call(base, [a, b, c, d, e, f, g, h, i], di, dn, di2, dn2)

## Appends the arguments to the log at out (long call count, then the longs of each call).
func _record(out: int, args: Array) -> int:
	var calls: int = memory.read_u32(out)
	for i in args.size():
		memory.write_u32(out + 4 + 4 * (calls * args.size() + i), C68kScript.u32(args[i]))
	memory.write_u32(out, calls + 1)
	return 0
