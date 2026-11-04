extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://hellcats/runtime/mac_machine.gd")

## Routines the game runtime writes outside the 740 (hellcats/runtime/unexported.gd and
## overlay_loader.gd), checked against their ORIGINAL bytes: tools/hellcats/gen_runtime_cases.py
## runs each on the m68k_emu interpreter and records the D0 it returns and the memory it leaves,
## from the memory it starts with (fixtures/unexported_cases.json); here the same memory is written
## into a MacMachine and the runtime's routine must return and leave the same, and where the case
## records them, make the same Toolbox and jump-table calls with the same first arguments.
const FIXTURE := "res://tests/runtime/fixtures/unexported_cases.json"
const SCENERY := "res://hellcats/data/scenery/Pacific Conflict"

func run() -> bool:
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var machine = MacMachine.new()
	var ok := true
	var mismatches: int = 0
	var attached := false
	for c in fixture["cases"]:
		if c.get("image", false) and not attached:
			# The overlay's own routines (the deck contact calls them) need its image and port.
			machine.overlay_loader.attach_image(FileAccess.get_file_as_bytes(SCENERY))
			attached = true
		if c.get("zero_stack", false):
			# The emulator's stack starts zeroed: so does the runtime's below the free stack (a frame the
			# routine reads before writing, such as a record the stubbed SysEnvirons would fill).
			var top: int = machine.free_stack()
			for at in range(top - 0x1000, top, 4):
				machine.memory.write_u32(at, 0)
		for w in c["writes"]:
			match int(w[1]):
				1: machine.memory.write_u8(int(w[0]), int(w[2]))
				2: machine.memory.write_u16(int(w[0]), int(w[2]))
				_: machine.memory.write_u32(int(w[0]), int(w[2]))
		var args: Array = c["args"].map(func(v): return int(v))
		var target = machine.overlay_loader if String(c["segment"]) == "overlay" else machine.unexported
		if attached:
			machine.overlay_loader.port.a7 = machine.free_stack()
		var calls: Array = []
		var restore: Dictionary = _log_calls(machine, c, calls)
		var d0_mask: int = {1: 0xff, 2: 0xffff}.get(int(c.get("d0_size", 4)), 0xffffffff)
		var got: int = int(target.callv(String(c["routine"]), args)) & d0_mask
		_unlog_calls(machine, restore)
		var expected: Array = c.get("calls", []).map(func(e):
			var row: Array = [String(e[0])]
			for k in range(1, e.size()):
				row.append(int(e[k]))
			return row)
		if c.has("calls") and calls != expected:
			mismatches += 1
			print("  %s: runtime calls %s, original %s" % [c["name"], calls, expected])
		if c.has("d0") and got != int(c["d0"]):
			mismatches += 1
			print("  %s: runtime D0 %x, original %x" % [c["name"], got, int(c["d0"])])
		for a in c["after"]:
			var at: int = int(a[0])
			var value: int
			match int(a[1]):
				1: value = machine.memory.read_u8(at)
				2: value = machine.memory.read_u16(at)
				_: value = machine.memory.read_u32(at)
			if value != int(a[2]):
				mismatches += 1
				print("  %s: runtime leaves %x at %x, original %x" % [c["name"], value, at, int(a[2])])
	ok = Assertions.assert_equal(mismatches, 0, "%d runtime routine cases match the original" % fixture["cases"].size()) and ok
	return ok

## The trap words and jump-table slots the case's original made calls to are wrapped to log
## [name, first argument] as the generator's stubs do (Pascal: the first argument is the last in
## the port's list). Returns what to put back.
func _log_calls(machine, c: Dictionary, calls: Array) -> Dictionary:
	var restore := {"traps": {}, "slots": {}, "jt": {}, "code": []}
	if not c.has("calls"):
		return restore
	for key in c.get("traps", {}):
		var word: int = String(key).hex_to_int()
		var original: Callable = machine.toolbox.traps[word]
		restore["traps"][word] = original
		var label: String = "trap 0x%x" % word
		machine.toolbox.traps[word] = func(a: Array) -> int:
			if a.is_empty():
				calls.append([label])
			else:
				calls.append([label, int(a[a.size() - 1]) & 0xffffffff])
			return original.call(a)
	# Traps given as layouts (the Dialog Manager's, which need a real dialog): stubs as the
	# generator's, the runtime's argument list being in the same order as the stack from A7 up.
	for key in c.get("trap_specs", {}):
		var word: int = String(key).hex_to_int()
		var spec: Dictionary = c["trap_specs"][key]
		restore["traps"][word] = machine.toolbox.traps[word]
		var label: String = "trap 0x%x" % word
		var calls_made := [0]
		machine.toolbox.traps[word] = func(a: Array) -> int:
			var entry: Array = [label]
			for i in spec.get("log", []):
				entry.append(int(a[int(i)]) & (0xffffffff if int(spec["sizes"][int(i)]) == 4 else 0xffff))
			for idx in spec.get("deref", {}):
				var arg = a[int(idx)]
				if arg is Array:        # a read-only rect the port passes by value: its longs already
					for v in arg:
						entry.append(int(v) & 0xffffffff)
					continue
				for k in int(spec["deref"][idx]):
					entry.append(machine.memory.read_u32(int(arg) + 4 * k))
			calls.append(entry)
			for idx in spec.get("outs", {}):
				var out: Array = spec["outs"][idx]
				var values: Array = out[1]
				var value = values[mini(calls_made[0], values.size() - 1)]
				var at: int = int(a[int(idx)])
				if value is Array:
					for k in value.size():
						machine.memory.write_u32(at + 4 * k, int(value[k]))
				elif int(out[0]) == 2:
					machine.memory.write_u16(at, int(value))
				else:
					machine.memory.write_u32(at, int(value))
			calls_made[0] += 1
			if spec.has("result"):
				var results: Array = spec["result"][1]
				return int(results[mini(calls_made[0] - 1, results.size() - 1)])
			return 0
	# Code addresses the routine jumps to through a pointer (an overlay hook): a logging stub.
	# As dictionaries, they log their first `longs` arguments, write VAR outputs and answer a result.
	for key in c.get("code_stubs", []):
		var spec: Dictionary = {"at": key} if key is String else key
		var address: int = String(spec["at"]).hex_to_int()
		var label: String = "code %s" % spec["at"]
		restore["code"].append(address)
		machine.segments.register_address(address, func(a: Array) -> int:
			var entry: Array = [label]
			for k in int(spec.get("longs", 0)):
				entry.append(int(a[k]) & 0xffffffff)
			calls.append(entry)
			for idx in spec.get("outs", {}):
				var out: Array = spec["outs"][idx]
				if int(out[0]) == 2:
					machine.memory.write_u16(int(a[int(idx)]), int(out[1]))
				else:
					machine.memory.write_u32(int(a[int(idx)]), int(out[1]))
			return int(spec.get("result", 0)))
	# C routines behind slots, stubbed alike on both sides: logged with their arguments, the result
	# answered, the real routine not run (the runtime calls them through ID02's jump-table callables).
	# Every segment's jump-table callables are stubbed: a port calls through its own.
	for key in c.get("c_stubs", {}):
		var slot: int = String(key).hex_to_int()
		var sizes: Array = c["c_stubs"][key][0]
		var result: int = int(c["c_stubs"][key][1])
		var label: String = "jt %s" % key
		var stub := func(a: Array) -> int:
			var entry: Array = [label]
			for k in sizes.size():
				entry.append(int(a[k]) & (0xffffffff if int(sizes[k]) == 4 else 0xffff))
			calls.append(entry)
			return result
		for segment in machine.segments.instances:
			var jt: Dictionary = machine.segments.instances[segment].jt_routines
			restore["jt"]["%d:%d" % [segment, slot]] = jt[slot]
			jt[slot] = stub
	# Overlay routines a written overlay routine calls (by address, as the generator's code stubs):
	# the loader's ported method there stood in for, logged with its first `longs` arguments.
	for key in c.get("overlay_stubs", {}):
		var method: String = machine.overlay_loader.methods[String(key).hex_to_int()]
		var longs: int = int(c["overlay_stubs"][key])
		var label: String = "code %s" % key
		restore["overlay"] = restore.get("overlay", []) + [method]
		machine.overlay_loader.test_stubs[method] = func(a: Array) -> int:
			var entry: Array = [label]
			for k in longs:
				entry.append(int(a[k]) & 0xffffffff)
			calls.append(entry)
			return 0
	# Pascal glue stubbed alike on both sides (logged by name, answering the case's result).
	for key in c.get("pascal_stubs", {}):
		var slot: int = String(key).hex_to_int()
		var result: int = int(c["pascal_stubs"][key][2])
		var label: String = "jt %s" % key
		var stub := func(_a: Array) -> int:
			calls.append([label])
			return result
		for segment in machine.segments.instances:
			var jt: Dictionary = machine.segments.instances[segment].jt_routines
			restore["jt"]["%d:%d" % [segment, slot]] = jt[slot]
			jt[slot] = stub
	for key in c.get("pascal", {}):
		var slot: int = String(key).hex_to_int()
		var original: Callable = machine.segments.stand_ins[slot]
		restore["slots"][slot] = original
		var label: String = "jt %s" % key
		machine.segments.stand_ins[slot] = func(a: Array) -> int:
			calls.append([label, int(a[a.size() - 1]) & 0xffffffff])
			return original.call(a)
	return restore

func _unlog_calls(machine, restore: Dictionary) -> void:
	for word in restore.get("traps", {}):
		machine.toolbox.traps[word] = restore["traps"][word]
	for slot in restore.get("slots", {}):
		machine.segments.stand_ins[slot] = restore["slots"][slot]
	for address in restore.get("code", []):
		for segment in machine.segments.code_routines:
			machine.segments.code_routines[segment].erase(address)
	for method in restore.get("overlay", []):
		machine.overlay_loader.test_stubs.erase(method)
	for key in restore.get("jt", {}):
		var parts: PackedStringArray = String(key).split(":")
		machine.segments.instances[int(parts[0])].jt_routines[int(parts[1])] = restore["jt"][key]
