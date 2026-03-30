extends SceneTree

const FlightMathScript := preload("res://hellcats/core/flight_math.gd")

func _init() -> void:
	var ok := true
	ok = _test_fun_0000e42a() and ok
	ok = _test_fun_0000e468() and ok
	ok = _test_fun_0000e570() and ok
	ok = _test_compute_local_34() and ok
	print("Result: %s" % ("ALL PASS" if ok else "SOME FAIL"))
	quit(0 if ok else 1)

func _test_fun_0000e42a() -> bool:
	var cases := [
		{"input": 0x00000000, "want": -15264},
		{"input": 0x00008000, "want": -30816},
		{"input": 0x00010000, "want": 19168},
		{"input": 0x00018000, "want": -4889},
		{"input": 0x00070000, "want": 2},
		{"input": 0x00078000, "want": -32557},
		{"input": 0x00080000, "want": 2},
	]
	for c in cases:
		var got := FlightMathScript.fun_0000e42a(c["input"])
		if got != c["want"]:
			print("FAIL FUN_0000e42a(0x%x) got %d want %d" % [c["input"], got, c["want"]])
			return false
	print("PASS FUN_0000e42a")
	return true

func _test_fun_0000e468() -> bool:
	var cases := [
		{"param_1": 0x100, "param_2": 1000, "want": 938},
		{"param_1": 0x300, "param_2": 1000, "want": 1000},
		{"param_1": 0x100, "param_2": -1000, "want": -938},
	]
	for c in cases:
		var got := FlightMathScript.fun_0000e468(c["param_1"], c["param_2"])
		if got != c["want"]:
			print("FAIL FUN_0000e468(%d, %d) got %d want %d" % [c["param_1"], c["param_2"], got, c["want"]])
			return false
	print("PASS FUN_0000e468")
	return true

func _test_fun_0000e570() -> bool:
	var cases := [
		{"field_38": 1000, "param_1": 100, "want": 1890},
		{"field_38": 25000, "param_1": 421, "want": 25000},
		{"field_38": 25000, "param_1": 511, "want": 22070},
	]
	for c in cases:
		var got := FlightMathScript.fun_0000e570(c["field_38"], c["param_1"])
		if got != c["want"]:
			print("FAIL FUN_0000e570(%d, %d) got %d want %d" % [c["field_38"], c["param_1"], got, c["want"]])
			return false
	print("PASS FUN_0000e570")
	return true

func _test_compute_local_34() -> bool:
	if FlightMathScript.compute_local_34(60, 400, 5000, 0, 300) != 0:
		print("FAIL compute_local_34 zero control")
		return false
	if FlightMathScript.compute_local_34(60, 400, 5000, 9, 300) != 60:
		print("FAIL compute_local_34 template_3c branch")
		return false
	if FlightMathScript.compute_local_34(60, 200, 5000, 9, 300) != 16:
		print("FAIL compute_local_34 local_26 branch")
		return false
	print("PASS compute_local_34")
	return true
