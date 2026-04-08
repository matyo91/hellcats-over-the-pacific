extends RefCounted

static func assert_equal(actual: Variant, expected: Variant, label: String) -> bool:
	if actual != expected:
		print("FAIL %s got %s want %s" % [label, str(actual), str(expected)])
		return false
	print("PASS %s" % label)
	return true

static func assert_true(condition: bool, label: String) -> bool:
	if not condition:
		print("FAIL %s" % label)
		return false
	print("PASS %s" % label)
	return true
