extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const Memory68kScript := preload("res://strict_port/compat/memory_68k.gd")
const PacificConflictScript := preload("res://strict_port/code/pacific_conflict.gd")

const MEMORY_SIZE := 0x30000
const STACK_TOP := 0x2f000
const WORLD := 0x23000
const BASE := 0x24000
const GROUP := 0x24100
const LEAF := 0x24300
const PLOT := 0x888 ## test-only plot callback address
const PLAYER_CTL := 0x25700
const PLAYER_OBJ := 0x25800

## collect_map_features (code 0x6ec) is replaced by a stub that fills the context lists, so
## this test isolates plot_mission_map_symbols (the visitor has its own test). Expected plots
## from an instruction-level model of 0x954..0xab8 (approx_dist3_xyz 0x3c68, signed cmp.l,
## divs.l), independent of the C and of this port. Player x 400, z -600; scale 4; mission 3.
const POINTS := [[1000, 0, 2000], [5000, 10, 5000], [9000, 0, -3000], [-7000, 0, 800], [20000, 0, 20000]]
const SITES := [[[1100, 0, 2100], 300, 0x13], [[5100, 0, 5000], 500, 0x13], [[9050, 0, -3050], 400, 0x12], [[-7000, 50, 800], 10, 0x13]]
const PLOTS := [[0x42, 150, -650], [0x43, 1150, -1400], [0x41, -1850, -350], [0x41, 4900, -5150], [0x54, -61336, -706992]]

var plots: Array = []
var visits := 0
var port

func _stub_visitor(ctx: int, _node: int, _face: int, _path: int, _depth: int) -> void:
	visits += 1
	var m = port.memory
	for n in range(POINTS.size()):
		for c in range(3):
			m.write_u32(ctx + 4 + 12 * n + 4 * c, POINTS[n][c] & 0xffffffff)
	m.write_u16(ctx + 0xb58, POINTS.size())
	for n in range(SITES.size()):
		for c in range(3):
			m.write_u32(ctx + 0x4b4 + 12 * n + 4 * c, SITES[n][0][c] & 0xffffffff)
		m.write_u32(ctx + 0x9c8 + 4 * n, SITES[n][1])
		m.write_u8(ctx + 0x964 + n, SITES[n][2])
	m.write_u16(ctx + 0xb5a, SITES.size())

func _plot(symbol: int, x: int, y: int) -> void:
	plots.append([symbol, x, y, port.a7])

func run() -> bool:
	var ok := true
	var memory = Memory68kScript.new(MEMORY_SIZE)
	port = PacificConflictScript.new(memory)
	port.code_table[0x6ec] = Callable(self, "_stub_visitor")
	port.code_table[PLOT] = Callable(self, "_plot")
	memory.write_u32(0x1b738, PLAYER_CTL)
	memory.write_u32(PLAYER_CTL, PLAYER_OBJ)
	memory.write_u32(PLAYER_OBJ + 0x18, 400)
	memory.write_u32(PLAYER_OBJ + 0x20, -600 & 0xffffffff)
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(WORLD + 0x8c, BASE)
	memory.write_u16(WORLD + 0x90, 3)
	memory.write_u32(BASE + 3 * 0x18 + 0x8e, GROUP - BASE)
	memory.write_u16(GROUP + 0x18, 1)
	memory.write_u32(GROUP + 0x1a + 0x14, LEAF - BASE)
	memory.write_u8(LEAF, 2)
	memory.write_u16(LEAF + 0x1e, 1)

	port.a7 = STACK_TOP
	port.plot_mission_map_symbols(4, PLOT)
	ok = Assertions.assert_equal(visits, 1, "context filled through the scene walk") and ok
	var got := []
	for p in plots:
		got.append(p.slice(0, 3))
	ok = Assertions.assert_equal(got, PLOTS, "plotted symbols") and ok
	if plots.size() > 0:
		ok = Assertions.assert_equal(plots[0][3], STACK_TOP - 0xba0, "plot callback stack depth") and ok
	ok = Assertions.assert_equal(memory.read_u32(STACK_TOP - 4 - 0xb5c), 4, "context scale at a6 - 0xb5c") and ok
	ok = Assertions.assert_equal(port.a7, STACK_TOP, "a7 restored") and ok

	## Mission 1: no 'T'.
	plots.clear()
	memory.write_u16(WORLD + 0x90, 1)
	memory.write_u32(BASE + 1 * 0x18 + 0x8e, GROUP - BASE)
	port.plot_mission_map_symbols(4, PLOT)
	ok = Assertions.assert_equal(plots.size(), 4, "no T marker outside missions 3 and 4") and ok
	return ok
