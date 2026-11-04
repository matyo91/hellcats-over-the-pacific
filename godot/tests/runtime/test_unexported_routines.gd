extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://hellcats/runtime/mac_machine.gd")

## Routines the game runtime writes outside the 740 (hellcats/runtime/unexported.gd and
## overlay_loader.gd), checked against their ORIGINAL bytes: tools/hellcats/gen_runtime_cases.py
## runs each on the m68k_emu interpreter and records the D0 it returns from the memory it starts
## with (fixtures/unexported_cases.json); here the same memory is written into a MacMachine and the
## runtime's routine must return the same.
const FIXTURE := "res://tests/runtime/fixtures/unexported_cases.json"

func run() -> bool:
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var machine = MacMachine.new()
	var ok := true
	var mismatches: int = 0
	for c in fixture["cases"]:
		for w in c["writes"]:
			match int(w[1]):
				1: machine.memory.write_u8(int(w[0]), int(w[2]))
				2: machine.memory.write_u16(int(w[0]), int(w[2]))
				_: machine.memory.write_u32(int(w[0]), int(w[2]))
		var args: Array = c["args"].map(func(v): return int(v))
		var target = machine.overlay_loader if String(c["segment"]) == "overlay" else machine.unexported
		var got: int = int(target.callv(String(c["routine"]), args)) & 0xffffffff
		if got != int(c["d0"]):
			mismatches += 1
			print("  %s: runtime %x, original %x" % [c["name"], got, int(c["d0"])])
	ok = Assertions.assert_equal(mismatches, 0, "%d runtime routine cases match the original" % fixture["cases"].size()) and ok
	return ok
