extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const NoWeaponPortScript := preload("res://tests/strict_port/helpers/no_weapon_port.gd")

## The AI state handlers ai_attack_or_fly (0x110f4, with ai_pursue_target 0x1820a), ai_fly (0x11182), ai_fly_bomber (0x111ae), ai_dive_at_target (0x111da)
## and ai_bombing_run (0x112e0), checked against the ORIGINAL bytes:
## tools/strict_port/gen_ai_state_cases.py runs each handler on the binary image in the m68k_emu
## interpreter (aircraft kind 0, so the fly step is update_aircraft_entity) and records every
## byte changed outside the stack (fixtures/ai_state_cases.json); the same image, RNG seed and
## writes go through the port, which must change exactly the same bytes. Bomb and gun object
## spawns answer 0 on both sides (helpers/no_weapon_port.gd).
const FIXTURE := "res://tests/strict_port/fixtures/ai_state_cases.json"
const BINARY_PATH := "../sources/mac-os-9/Pacific Conflict"

func run() -> bool:
	var ok := true
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var binary := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://").path_join(BINARY_PATH))
	var size: int = int(fixture["memory_size"])
	var image := binary.slice(0x20, 0x20 + size)
	image.resize(size)
	var guard_lo: int = int(fixture["stack_guard"][0])
	var guard_hi: int = int(fixture["stack_guard"][1])
	for c in fixture["cases"]:
		var mem = Memory68kScript.new(size)
		mem._bytes = image.duplicate()
		var p = NoWeaponPortScript.new(mem)
		p.a7 = int(fixture["stack_top"])
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
		p._jsr(int(c["routine"]), [int(fixture["ctl"])])
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
		ok = Assertions.assert_equal(p.a7, int(fixture["stack_top"]), "a7 restored: %s" % c["name"]) and ok
	return ok
