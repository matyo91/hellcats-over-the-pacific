extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const ID01 := preload("res://strict_port/code/ID01.gd")

## The ID01 32-bit divide runtime, checked against the ORIGINAL bytes:
## tools/strict_port/gen_id01_divide_cases.py runs ID01.bin in the m68k_emu interpreter
## (fixtures/id01_divide_cases.json: [name, dividend, divisor, D0] for the stack entries, plus D1
## for the register cores).
func run() -> bool:
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/strict_port/fixtures/id01_divide_cases.json"))
	var failures := 0
	for c in fixture["cases"]:
		var name: String = c[0]
		var a: int = int(c[1])
		var b: int = int(c[2])
		var got: Array
		match name:
			"rt_sdivmod32_core":
				got = ID01.rt_sdivmod32_core(a, b)
			"rt_udivmod32_core":
				got = ID01.rt_udivmod32_core(a, b)
			"rt_udiv32":
				got = [ID01.rt_udiv32(a, b)]
			"rt_umod32":
				got = [ID01.rt_umod32(a, b)]
			"rt_sdiv32":
				got = [ID01.rt_sdiv32(a, b)]
			"rt_smod32":
				got = [ID01.rt_smod32(a, b)]
		var want: Array = []
		for k in range(3, c.size()):
			want.append(int(c[k]))
		if got != want:
			failures += 1
			if failures <= 10:
				print("  %s(0x%x, 0x%x): port %s original %s" % [name, a, b, str(got), str(want)])
	return Assertions.assert_equal(failures, 0, "ID01 divide runtime: %d calls match the original" % fixture["cases"].size())
