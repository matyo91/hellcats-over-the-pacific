extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const SHIP := 0x21000
const SHIP_CTL := 0x21100
const SHIP_TYPE := 0x21180
const OBJ := 0x21200
const OBJ_CTL := 0x21300
const OBJ_TYPE := 0x21380

## Expected values follow the disassembly of fold_angle_pm_0x2000 (0xe40c),
## apply_hit_to_sinkable_object (0x14f48) and apply_blast_damage (0x12b66). Rng draws are
## predicted by a twin overlay RNG seeded identically. Hit counts other than 0..2 keep the drop
## register as the caller left it: apply_blast_damage leaves its credit flag in D4.

var memory
var port
var twin

func _setup() -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	memory.write_u32(0x1b838, 1000)
	memory.write_u32(SHIP_CTL, SHIP)
	memory.write_u32(SHIP + 8, SHIP_CTL)
	memory.write_u32(SHIP_CTL + 4, SHIP_TYPE)
	memory.write_u16(SHIP_TYPE, 0x16)
	memory.write_u32(SHIP + 0x14, 100)
	memory.write_u32(OBJ_CTL, OBJ)
	memory.write_u32(OBJ + 8, OBJ_CTL)
	memory.write_u32(OBJ_CTL + 4, OBJ_TYPE)
	memory.write_u32(OBJ + 0x14, 100)

func _rates() -> Array:
	return [memory.read_s16(SHIP_CTL + 0x3a), memory.read_s16(SHIP_CTL + 0x3c), memory.read_s16(SHIP_CTL + 0x3e), memory.read_s16(SHIP_CTL + 0x42), memory.read_u16(SHIP_CTL + 0x46), memory.read_u32(SHIP_CTL + 0x48), memory.read_u16(SHIP_CTL + 0x4c)]

func _signed(v: int, bit: int) -> int:
	return -v if bit != 0 else v

func _q(v: int) -> int:
	var q: int = abs(v) / 15
	return -q if v < 0 else q

func run() -> bool:
	var ok := true

	_setup()
	for c in [[0x2000, 0x2000], [0x2001, -0x1fff], [-0x2000, -0x2000], [-0x2001, 0x1fff], [0x3fff, -1], [0x8000, -0x8000 + 0x4000]]:
		ok = Assertions.assert_equal(port.fold_angle_pm_0x2000(c[0]), c[1], "fold_angle_pm_0x2000(%d)" % c[0]) and ok

	## Three hits left -> 2: the count-2 roll only (angle c and drop).
	_setup()
	memory.write_u16(SHIP_CTL + 0x32, 3)
	var c: int = _signed((twin.overlay_rng_next() & 0x7f) + 0x200, twin.overlay_rng_next() & 1)
	var drop: int = ((twin.overlay_rng_next() & 0xffff) % 100) + 100
	port.apply_hit_to_sinkable_object(SHIP_CTL, 1)
	ok = Assertions.assert_equal([_rates(), memory.read_u16(SHIP_CTL + 0x4e), memory.read_u16(SHIP_CTL + 0x32)], [[0, 0, _q(c), _q(drop), 15, 1030, 1], 1, 2], "3 -> 2 hits: roll c, credited") and ok
	## Two -> 1 before sinking: angle a and drop, then the count-2 roll replaces the drop.
	_setup()
	memory.write_u16(SHIP_CTL + 0x32, 2)
	var a: int = (twin.overlay_rng_next() & 0x3f) + 0x100
	a = _signed(a, twin.overlay_rng_next() & 1)
	twin.overlay_rng_next()
	c = _signed((twin.overlay_rng_next() & 0x7f) + 0x200, twin.overlay_rng_next() & 1)
	drop = ((twin.overlay_rng_next() & 0xffff) % 100) + 100
	port.apply_hit_to_sinkable_object(SHIP_CTL, 0)
	ok = Assertions.assert_equal([_rates(), memory.read_u16(SHIP_CTL + 0x4e)], [[_q(a), 0, _q(c), _q(drop), 15, 1030, 1], 0], "2 -> 1 before sinking: a, then c and drop") and ok
	## Two -> 1 once sinking: no count-2 roll.
	_setup()
	memory.write_u16(SHIP_CTL + 0x32, 2)
	memory.write_u16(SHIP_CTL + 0x4c, 1)
	a = _signed((twin.overlay_rng_next() & 0x3f) + 0x100, 0)
	a = _signed(a, twin.overlay_rng_next() & 1)
	drop = ((twin.overlay_rng_next() & 0xffff) % 100) + 100
	port.apply_hit_to_sinkable_object(SHIP_CTL, 0)
	ok = Assertions.assert_equal(_rates(), [_q(a), 0, 0, _q(drop), 15, 1030, 1], "2 -> 1 while sinking: a and drop") and ok
	## Last hit (1 -> 0) while sinking, first angle 0x3000 (folds to -0x1000): a negative.
	_setup()
	memory.write_u16(SHIP_CTL + 0x32, 1)
	memory.write_u16(SHIP_CTL + 0x4c, 1)
	memory.write_u16(SHIP_CTL + 0x34, 0x3000)
	a = -(((twin.overlay_rng_next() & 0xffff) % 0x140) + 0x500)
	drop = ((twin.overlay_rng_next() & 0xffff) % 200) + 1000
	port.apply_hit_to_sinkable_object(SHIP_CTL, 0)
	ok = Assertions.assert_equal(_rates(), [_q(a), 0, 0, _q(drop), 15, 1030, 1], "last hit: big roll toward the folded angle, deep drop") and ok
	## Five -> 4: no roll; the drop is the caller's D4 low word.
	_setup()
	memory.write_u16(SHIP_CTL + 0x32, 5)
	port.apply_hit_to_sinkable_object(SHIP_CTL, 0, 0x10000 + 300)
	ok = Assertions.assert_equal(_rates(), [0, 0, 0, 20, 15, 1030, 1], "other counts: drop from D4") and ok
	## No hits left: only the credit flag and the anchor.
	_setup()
	memory.write_u16(0x1d854, 1)
	memory.write_u32(0x1d83c, 50)
	memory.write_u32(SHIP + 0x18, 100)
	port.apply_hit_to_sinkable_object(SHIP_CTL, 1)
	ok = Assertions.assert_equal([memory.read_u16(0x1d854), memory.read_u16(SHIP_CTL + 0x4e), memory.read_u16(SHIP_CTL + 0x46)], [0, 1, 0], "no hits left: anchor within range cleared, credit set") and ok

	## apply_blast_damage over a pool of [ship, object].
	_setup()
	memory.write_u32(0x1b5a4, SHIP)
	memory.write_u32(0x1b5a8, OBJ)
	memory.write_u32(0x1b734, 2)
	memory.write_u16(SHIP_CTL + 0x32, 5)
	## Aircraft (type 2) inside its range: damage word |= 0x400; the ship (type 0x16) inside its
	## range: hit (5 -> 4, drop = the credit flag 1 / 15 = 0).
	memory.write_u16(OBJ_TYPE, 2)
	port.apply_blast_damage(0, 0, 0, 500, 1, 1, 0)
	ok = Assertions.assert_equal([memory.read_u16(OBJ_CTL + 0x684), memory.read_u16(SHIP_CTL + 0x32), memory.read_u16(SHIP_CTL + 0x46), port.a7], [0x400, 4, 15, STACK_TOP], "blast: aircraft damaged, ship hit") and ok
	## A large ship (range above the radius) is only hit with hit_ships.
	memory.write_u32(SHIP + 0x14, 1000)
	memory.write_u16(OBJ_TYPE, 9)
	memory.write_u32(OBJ + 0x18, 5000)
	port.apply_blast_damage(0, 0, 0, 500, 0, 1, 0)
	ok = Assertions.assert_equal(memory.read_u16(SHIP_CTL + 0x32), 4, "big ship ignored without hit_ships") and ok
	port.apply_blast_damage(0, 0, 0, 500, 0, 1, 1)
	ok = Assertions.assert_equal(memory.read_u16(SHIP_CTL + 0x32), 3, "big ship hit with hit_ships") and ok
	## Non-aircraft (type 9): 699 from the centre (overshoot 599) is a hit; 700 is not. Replay
	## state 1 keeps spawn_destruction_effect from spawning; the object is cleaned up.
	memory.write_u32(SHIP + 0x18, 100000)
	memory.write_u16(0x1b870, 1)
	memory.write_u32(OBJ_CTL + 0x2e, 5)
	memory.write_u32(OBJ + 0x1c, 1000)
	memory.write_u32(OBJ + 0x18, 0)
	memory.write_u32(OBJ + 0x20, 0)
	## approx_dist3_xyz((0, 1000, 0), (0, 300, 0)) = 700 -> overshoot 600: missed.
	port.apply_blast_damage(0, 300, 0, 500, 0, 1, 0)
	ok = Assertions.assert_equal(memory.read_u32(OBJ + 4) & 2, 0, "overshoot 600: missed") and ok
	port.apply_blast_damage(0, 301, 0, 500, 0, 1, 0)
	ok = Assertions.assert_equal([memory.read_u32(OBJ + 4) & 2, memory.read_u32(OBJ + 0x18), port.a7], [2, 1000000000, STACK_TOP], "overshoot 599: destroyed and cleaned up") and ok
	## Flagged objects are skipped, unless it is the player's.
	_setup()
	memory.write_u32(0x1b5a4, OBJ)
	memory.write_u32(0x1b734, 1)
	memory.write_u16(OBJ_TYPE, 2)
	memory.write_u32(OBJ + 4, 0x40)
	port.apply_blast_damage(0, 0, 0, 500, 0, 1, 0)
	ok = Assertions.assert_equal(memory.read_u16(OBJ_CTL + 0x684), 0, "hidden object skipped") and ok
	memory.write_u32(0x1b738, OBJ_CTL)
	port.apply_blast_damage(0, 0, 0, 500, 0, 1, 0)
	ok = Assertions.assert_equal(memory.read_u16(OBJ_CTL + 0x684), 0x400, "the player's aircraft is hit even when flagged") and ok
	return ok
