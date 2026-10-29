extends RefCounted

## Replays an interpreter fixture (tools/strict_port/gen_*_cases.py) through the strict port: each
## case starts from the binary image (runtime = file - 0x20), seeds the overlay RNG with
## overlay_rng_init(1), clears its zero ranges, applies its writes, runs its routine and must
## change exactly the bytes the original changed outside the stack guard, leaving a7 restored;
## a case that records "d0" also compares the returned value. A case with "method" calls the
## port function by name (routines no dispatch table reaches).
## Stubs named by the fixture are stubbed the same way (helpers/stubbed_port.gd).
const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const StubbedPortScript := preload("res://tests/strict_port/helpers/stubbed_port.gd")
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"

static func replay(fixture_path: String) -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(fixture_path))
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	var size: int = int(fixture["memory_size"])
	var image := binary.slice(0x20, 0x20 + size)
	image.resize(size)
	var guard_lo: int = int(fixture["stack_guard"][0])
	var guard_hi: int = int(fixture["stack_guard"][1])
	var stubs := {}
	for name in fixture["stubs"]:
		stubs[name] = int(fixture["stubs"][name])
	for c in fixture["cases"]:
		var mem = Memory68kScript.new(size)
		mem._bytes = image.duplicate()
		var p = StubbedPortScript.new(mem)
		p.stubs = stubs
		p.install_call_logs(fixture.get("call_logs", []))
		## Entered as the interpreter enters it: the long arguments and the return address pushed.
		var entry_a7: int = int(fixture["stack_top"]) - 4 - 4 * c["args"].size()
		p.a7 = entry_a7
		p.overlay_rng_init(1)
		for r in c["zero"]:
			for addr in range(int(r[0]), int(r[1])):
				mem._bytes[addr] = 0
		for w in c["writes"]:
			match int(w[1]):
				1:
					mem.write_u8(int(w[0]), int(w[2]))
				2:
					mem.write_u16(int(w[0]), int(w[2]))
				_:
					mem.write_u32(int(w[0]), int(w[2]))
		var before: PackedByteArray = mem._bytes.duplicate()
		var args := []
		for a in c["args"]:
			args.append(int(a))
		var result = p.callv(String(c["method"]), args) if c.has("method") else p._jsr(int(c["routine"]), args)
		var got := []
		for addr in range(size):
			if addr >= guard_lo and addr < guard_hi:
				continue
			if mem._bytes[addr] != before[addr]:
				got.append([addr, mem._bytes[addr]])
		var want := []
		for ch in c["changes"]:
			want.append([int(ch[0]), int(ch[1])])
		if got != want:
			var diffs := []
			var gd := {}
			for g in got:
				gd[g[0]] = g[1]
			var wd := {}
			for x in want:
				wd[x[0]] = x[1]
			for addr in gd.keys() + wd.keys():
				var line := "%x: port %d original %d" % [addr, gd.get(addr, before[addr]), wd.get(addr, before[addr])]
				if gd.get(addr, -1) != wd.get(addr, -1) and diffs.size() < 12 and not diffs.has(line):
					diffs.append(line)
			diffs.sort()
			print("  diffs: ", diffs)
		ok = Assertions.assert_equal(got == want, true, "original bytes: %s (%d bytes)" % [c["name"], want.size()]) and ok
		ok = Assertions.assert_equal(p.a7, entry_a7, "a7 restored: %s" % c["name"]) and ok
		if c.has("d0"):
			ok = Assertions.assert_equal(int(result) & 0xffffffff, int(c["d0"]), "D0: %s" % c["name"]) and ok
	return ok
