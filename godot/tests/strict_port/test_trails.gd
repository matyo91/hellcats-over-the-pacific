extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")
const PoolFixtureScript := preload("res://tests/strict_port/helpers/pool_fixture.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const OBJ := 0x21000
const CTL := 0x21200
const VERTS := 0x21400
const FACES := 0x21600
const OWNER := 0x21800
const OWNER_CTL := 0x21a00

## Expected values follow the disassembly of the trail family (0x16ac4 .. 0x1706a): the two
## initialisers, spawn_trail, attach_smoke_trail / attach_burning_trail, destroy_trail_controller,
## animate_smoke_trail (jump table on the state word), animate_burning_trail and tick_trail.
## The detach coins are predicted with a twin overlay RNG seeded identically. The tables hold the
## same runtime addresses as the data file (init 0x16aa4 / 0x16ab6, animate 0x16c4a / 0x16de6);
## spawned trails come from templates 1 / 2 (eight vertex vectors) through the strict pool chain.

var memory
var port
var twin
var fixture

func _setup(state: int, lifetime: int) -> void:
	memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.a7 = STACK_TOP
	port.overlay_rng_init(1)
	twin = PacificConflictScript.new(Memory68kScript.new(MEMORY_SIZE))
	twin.overlay_rng_init(1)
	fixture = PoolFixtureScript.new()
	fixture.setup(memory, port)
	for k in [1, 2]:
		fixture.add_template(k, 5)
		memory.write_u16(PoolFixtureScript.BASE + 0x400 + 0x40 * k + 0x1a, 8)
		memory.write_u32(0x26650 + 4 * (k - 1), fixture.template_object(0x22000 + 0x100 * k, k))
	memory.write_u32(0x1b50c, 0x16aa4)
	memory.write_u32(0x1b510, 0x16ab6)
	memory.write_u32(0x1b514, 0x16c4a)
	memory.write_u32(0x1b518, 0x16de6)
	memory.write_u32(CTL, OBJ)
	memory.write_u32(OBJ + 8, CTL)
	memory.write_u32(OBJ + 0x44, VERTS)
	memory.write_u32(OBJ + 0x48, FACES)
	memory.write_u32(CTL + 0x52, OWNER)
	memory.write_u16(CTL + 0x56, 1)
	memory.write_u16(CTL + 0x36, state)
	memory.write_u16(CTL + 0x34, lifetime)
	memory.write_u32(OWNER, 0)
	memory.write_u32(OWNER + 8, OWNER_CTL)
	memory.write_u32(OWNER_CTL, OWNER)
	memory.write_u32(OWNER + 0x18, 1000)
	memory.write_u32(OWNER + 0x1c, 500)
	memory.write_u32(OWNER + 0x20, 2000)
	memory.write_u16(OWNER_CTL + 0x684, 0x40)
	memory.write_u16(OWNER_CTL + 0x68c, 1)

func _verts(first: int, count: int) -> Array:
	var out := []
	for i in range(first, first + count):
		out.append([memory.read_s32(VERTS + 12 * i), memory.read_s32(VERTS + 12 * i + 4), memory.read_s32(VERTS + 12 * i + 8)])
	return out

## The twin's next detach coin for `mask` (vertex 0 / 1, or 2 / 3 once 0 and 1 are gone).
func _coin(mask: int) -> int:
	if (mask & 3) == 3:
		return mask | (4 if (twin.overlay_rng_next() & 1) != 0 else 8)
	return mask | (1 if (twin.overlay_rng_next() & 1) != 0 else 2)

func run() -> bool:
	var ok := true

	## Smoke trail, state 1: -> 2, ribbon +-0x22 at the owner, the first coin (mask was 0).
	_setup(1, 10)
	var mask: int = _coin(0)
	ok = Assertions.assert_equal(port._jsr(0x16c4a, [CTL]), 0, "smoke trail: running") and ok
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x36), _verts(0, 4), memory.read_u16(CTL + 0x50)], [2, [[1000, 466, 2000], [1000, 534, 2000], [1000, 534, 2000], [1000, 466, 2000]], mask], "smoke trail: placed, one vertex detached") and ok
	## Next frame, owner moved: the detached vertex stays, the others follow; a coin only when
	## rng & 3 == 0.
	memory.write_u32(OWNER + 0x18, 1100)
	if (twin.overlay_rng_next() & 3) == 0:
		mask = _coin(mask)
	port.animate_smoke_trail(CTL)
	var stayed: int = 0 if (memory.read_u16(CTL + 0x50) & 1) != 0 else 1
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x50), _verts(stayed, 1)[0][0], _verts(3, 1)[0][0]], [mask, 1000, 1100], "smoke trail: detached vertex stays behind") and ok

	## Owner stops smoking (word +0x684 & 0x3c0 == 0): released (count 1 -> 0, +0x56 cleared)
	## and state 4 is set before the state switch, so a state-1 trail (lifetime cleared) finishes
	## in the same call. Each further call releases again: the count goes below 0, as in the
	## bytes.
	_setup(1, 10)
	memory.write_u16(OWNER_CTL + 0x684, 0x0c3f)
	ok = Assertions.assert_equal([port.animate_smoke_trail(CTL), memory.read_u16(CTL + 0x36), memory.read_u16(CTL + 0x34), memory.read_u16(OWNER_CTL + 0x68c), memory.read_u16(CTL + 0x56)], [1, 4, 0, 0, 0], "smoke trail: owner not smoking -> released and finished") and ok
	ok = Assertions.assert_equal([port.animate_smoke_trail(CTL), memory.read_u16(OWNER_CTL + 0x68c)], [1, 0xffff], "smoke trail: released again on the next call") and ok
	## Released from state 2 with lifetime left: state 4, not finished yet.
	_setup(2, 10)
	memory.write_u16(OWNER_CTL + 0x684, 0)
	ok = Assertions.assert_equal([port.animate_smoke_trail(CTL), memory.read_u16(CTL + 0x36), memory.read_u16(CTL + 0x34)], [0, 4, 10], "smoke trail: released with lifetime left -> state 4, running") and ok

	## State 3: draws until one is 0 (& 3, or & 0x1f while byte +0x685 is negative), then a new
	## smoke trail is attached and this one goes to state 4.
	_setup(3, 10)
	memory.write_u8(OWNER_CTL + 0x685, 0x80)
	var calls: int = 0
	var draws: int = 0
	while true:
		draws += 1
		if (twin.overlay_rng_next() & 0x1f) == 0:
			break
	while memory.read_u16(CTL + 0x36) == 3 and calls < 200:
		port.animate_smoke_trail(CTL)
		calls += 1
	ok = Assertions.assert_equal([calls, memory.read_u16(CTL + 0x36), memory.read_u16(OWNER_CTL + 0x68c), memory.read_u8(OWNER + 3)], [draws, 4, 2, 1], "smoke trail state 3: a new trail attached after the predicted number of frames") and ok
	var fresh: int = memory.read_u32(fixture.activated()[0] + 8)
	ok = Assertions.assert_equal([memory.read_u16(fresh + 0x32), memory.read_u32(fresh + 0x52), memory.read_u16(fresh + 0x56), memory.read_u16(fresh + 0x34), memory.read_u16(fresh + 0x36), port.a7], [0, OWNER, 1, 0x4a, 2, STACK_TOP], "attached trail: kind 0, owner, counted, initialised (0x4b, 1) and ticked once") and ok

	## Burning trail, state 1, lifetime 0x50: ribbon +-100, one vertex detached and drifting by 4,
	## vertices 4..7 pulled halfway to the centre.
	_setup(1, 0x50)
	mask = _coin(0)
	ok = Assertions.assert_equal(port._jsr(0x16de6, [CTL]), 0, "burning trail: running") and ok
	var want := [[1000, 400, 2000], [1000, 600, 2000], [1000, 600, 2000], [1000, 400, 2000]]
	if mask == 1:
		want[0][1] = 396
	else:
		want[1][1] = 604
	ok = Assertions.assert_equal([memory.read_u16(CTL + 0x50), _verts(0, 4)], [mask, want], "burning trail: placed, the detached vertex drifts") and ok
	var cy: int = (want[0][1] + want[1][1] + want[2][1] + want[3][1]) >> 2
	var half := []
	for i in range(4):
		var dev: int = want[i][1] - cy
		if dev < 0:
			dev += 1
		half.append([1000, cy + (dev >> 1), 2000])
	ok = Assertions.assert_equal(_verts(4, 4), half, "burning trail: inner ribbon halfway to the centre") and ok
	## Lifetime 0x3b: the second face is hidden instead.
	_setup(2, 0x3b)
	port.animate_burning_trail(CTL)
	ok = Assertions.assert_equal([memory.read_u8(FACES + 0x33) & 2, memory.read_s32(VERTS + 0x30)], [2, 0], "burning trail: short lifetime hides face 1") and ok
	## Retired owner: released (+0x56 = 0, no trail count change), state 4.
	_setup(2, 0x50)
	memory.write_u8(OWNER + 7, 2)
	ok = Assertions.assert_equal([port.animate_burning_trail(CTL), memory.read_u16(CTL + 0x36), memory.read_u16(CTL + 0x56), memory.read_u16(OWNER_CTL + 0x68c)], [0, 4, 0, 1], "burning trail: owner retired -> released") and ok

	## tick_trail: the animator by kind, lifetime count-down, retire when finished.
	_setup(4, 0)
	memory.write_u16(CTL + 0x32, 1)
	port._jsr(0x1700a, [CTL])
	ok = Assertions.assert_equal([memory.read_u32(OBJ + 4), memory.read_u32(OBJ + 0x18), port.a7], [0x42, 1000000000, STACK_TOP], "tick_trail: hidden at lifetime 0, retired when finished") and ok

	## attach_burning_trail: kind 1, not counted in +0x68c, near explosion sound.
	_setup(1, 10)
	var burning: int = port.attach_burning_trail(10, 20, 30, OWNER_CTL)
	ok = Assertions.assert_equal([memory.read_u16(burning + 0x32), memory.read_u32(burning + 0x52), memory.read_u16(OWNER_CTL + 0x68c), memory.read_u8(OWNER + 3), memory.read_u16(0x1b84a), memory.read_u16(burning + 0x34)], [1, OWNER, 1, 1, 0x1e, 0x4a], "attach_burning_trail") and ok

	## destroy_trail_controller: kind 0 counted drops both counts; kind 1 only byte +3.
	_setup(1, 10)
	memory.write_u8(OWNER + 3, 2)
	port._jsr(0x16c04, [CTL])
	ok = Assertions.assert_equal([memory.read_u8(OWNER + 3), memory.read_u16(OWNER_CTL + 0x68c)], [1, 0], "destroy kind 0 (counted)") and ok
	memory.write_u16(CTL + 0x32, 1)
	port.destroy_trail_controller(CTL)
	ok = Assertions.assert_equal([memory.read_u8(OWNER + 3), memory.read_u16(OWNER_CTL + 0x68c)], [0, 0], "destroy kind 1") and ok
	return ok
