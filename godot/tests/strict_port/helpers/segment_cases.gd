extends RefCounted

## Replays a CODE-segment fixture (tools/strict_port/gen_id*_cases.py) through a segment port:
## each case starts from zeroed memory of the fixture's size, applies the fixture's common writes
## and its own, calls the port method with the case's arguments (the port is built on that memory
## with the fixture's A5) and must change exactly the bytes the original changed outside the
## stack guard (a case may carry its own "call_logs" in place of the fixture's, and its own "a7":
## the original's stack pointer on entry, when frame addresses are logged; the fixture's
## "port_vars" are set on the port, e.g. the segment's load address); a case that records
## "d0" also compares the returned value (under "d0_mask" when the routine returns a word).
const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")

static func replay(fixture_path: String, port_script: GDScript) -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(fixture_path))
	var size: int = int(fixture["memory_size"])
	var guard_lo: int = int(fixture["stack_guard"][0])
	var guard_hi: int = int(fixture["stack_guard"][1])
	var mismatches := 0
	for c in fixture["cases"]:
		var mem = Memory68kScript.new(size)
		for w in fixture["common_writes"] + c["writes"]:
			match int(w[1]):
				1:
					mem.write_u8(int(w[0]), int(w[2]))
				2:
					mem.write_u16(int(w[0]), int(w[2]))
				_:
					mem.write_u32(int(w[0]), int(w[2]))
		var port = port_script.new(mem, int(fixture["a5"]))
		port.a7 = int(c.get("a7", fixture.get("stack_top", 0)))
		for key in fixture.get("port_vars", {}):
			port.set(key, int(fixture["port_vars"][key]))
		for entry in c.get("call_logs", fixture.get("call_logs", [])):
			var stub := _stub(mem, int(entry[2]), entry[3], int(entry[5]), entry[7] if entry.size() > 7 else [], entry[6])
			match String(entry[0]):
				"trap_a0":
					port.traps[int(entry[1])] = _a0_stub(mem, int(entry[2]), entry[6], entry[7] if entry.size() > 7 else [])
				"trap_d0":
					port.traps[int(entry[1])] = stub
				"jt":
					port.jt_routines[int(entry[1])] = stub
				"addr":
					port.code_routines[int(entry[1])] = stub
				_:
					port.traps[int(entry[1])] = stub
		var before: PackedByteArray = mem._bytes.duplicate()
		var args := []
		for a in c["args"]:
			args.append(int(a))
		var result = port.callv(String(c["method"]), args)
		var got := []
		for addr in range(size):
			if addr >= guard_lo and addr < guard_hi:
				continue
			if mem._bytes[addr] != before[addr]:
				got.append([addr, mem._bytes[addr]])
		var want := []
		for ch in c["changes"]:
			want.append([int(ch[0]), int(ch[1])])
		var same: bool = got == want
		if c.has("d0"):
			var mask: int = int(c.get("d0_mask", 0xffffffff))
			same = same and (int(result) & mask) == int(c["d0"])
		if not same:
			mismatches += 1
			if mismatches <= 10:
				print("  %s: port d0 %s changes %s / original d0 %s changes %s" % [c["name"], str(result), str(got.slice(0, 6)),
						str(c.get("d0", "-")), str(want.slice(0, 6))])
	ok = Assertions.assert_equal(mismatches, 0, "%s: %d cases match the original" % [fixture_path.get_file(), fixture["cases"].size()]) and ok
	return ok

## The port side of tools/strict_port/segment_stubs.py: log the arguments (an Array argument is a
## dereferenced buffer, logged long by long, and so is a pointer whose derefs entry is a long count; an "out" argument is a pointer the stand-in writes its
## long through, unlogged; "outseq" writes the value for the call's number) at base (count, then
## the longs of each call, or under the key "-1" = "digest" a running hash h * 31 + value) and return the long at base - 4 (or the entry's next scripted result),
## masked to the Pascal result size (0: the whole long, D0).
static func _stub(mem, base: int, sizes: Array, result_size: int, results: Array, derefs: Dictionary = {}) -> Callable:
	return func(args: Array) -> int:
		assert(args.size() == sizes.size(), "stub at %x: %d arguments, %d sizes" % [base, args.size(), sizes.size()])
		var values: Array = []
		var count: int = mem.read_u32(base)
		for i in args.size():
			var spec = derefs.get(str(i))
			if spec is Array and String(spec[0]) == "outseq":
				_write_out(mem, int(args[i]), ["out", spec[1][mini(count, spec[1].size() - 1)]] + spec.slice(2))
			elif spec is Array and String(spec[0]) == "out":
				_write_out(mem, int(args[i]), spec)
			elif args[i] is Array:
				values.append_array(args[i])
			elif spec is int or spec is float:
				for k in int(spec):           # a pointer to a buffer: its longs, as the emulator side logs them
					values.append(mem.read_u32((int(args[i]) + 4 * k) & 0xffffffff))
			else:
				values.append(int(args[i]) & ((1 << (8 * int(sizes[i]))) - 1))
		if derefs.get("-1") == "digest":
			var digest: int = mem.read_u32(base + 4)
			for v in values:
				digest = (digest * 31 + (int(v) & 0xffffffff)) & 0xffffffff
			mem.write_u32(base + 4, digest)
		else:
			for i in values.size():
				mem.write_u32(base + 4 + (count * values.size() + i) * 4, int(values[i]) & 0xffffffff)
		mem.write_u32(base, count + 1)
		var result: int = int(results[mini(count, results.size() - 1)]) if results.size() > 0 else mem.read_u32(base - 4)
		return result & 0xffff if result_size == 2 else result

## ["out", value] writes a long; ["out", value, size] a byte / word / long; a list value writes
## several longs (a rect). The port side of segment_stubs.write_out.
static func _write_out(mem, address: int, spec: Array) -> void:
	if spec[1] is Array:
		for k in spec[1].size():
			mem.write_u32(address + 4 * k, int(spec[1][k]) & 0xffffffff)
		return
	var size: int = int(spec[2]) if spec.size() > 2 else 4
	match size:
		1:
			mem.write_u8(address, int(spec[1]) & 0xff)
		2:
			mem.write_u16(address, int(spec[1]) & 0xffff)
		_:
			mem.write_u32(address, int(spec[1]) & 0xffffffff)

## The port side of segment_stubs.a0_trap: the port passes [D0, A0]; D0's low word (when the spec
## says "d0") and the block's first spec["block"] longs are logged, the spec's "out" fields written
## into the block, and the result returned.
static func _a0_stub(mem, base: int, spec: Dictionary, results: Array) -> Callable:
	return func(args: Array) -> int:
		var block: int = int(args[1])
		var values: Array = []
		if spec.get("d0", false):
			values.append(int(args[0]) & 0xffff)
		for k in int(spec.get("block", 0)):
			values.append(mem.read_u32(block + 4 * k))
		var count: int = mem.read_u32(base)
		for i in values.size():
			mem.write_u32(base + 4 + (count * values.size() + i) * 4, int(values[i]) & 0xffffffff)
		mem.write_u32(base, count + 1)
		for out in spec.get("out", []):
			match int(out[1]):
				1:
					mem.write_u8(block + int(out[0]), int(out[2]) & 0xff)
				2:
					mem.write_u16(block + int(out[0]), int(out[2]) & 0xffff)
				_:
					mem.write_u32(block + int(out[0]), int(out[2]) & 0xffffffff)
		return (int(results[mini(count, results.size() - 1)]) if results.size() > 0 else mem.read_u32(base - 4)) & 0xffffffff
