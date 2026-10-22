extends RefCounted
## Minimal mission scene for tests that spawn pool objects through the strict
## spawn_mission_pool_object -> instantiate_mission_pool_slot chain:
## host world (+0x8c scene data base, +0x348 heap arena, +0xa8 phase 0), scene root with a
## template table, kind-2 descriptors per template index (no template vectors or faces),
## distance band thresholds and class factories through DAT_0001b524. Activated shapes are
## read back from the lists activate_near_range_object publishes to (activated()).

const WORLD := 0x23000
const BASE := 0x2d000 ## scene data base (host world +0x8c)
const ARENA := 0x28000
const ROOT := 0x2c000
const TEMPLATE := 0x2c100 ## root +0x28: template records (24 bytes, descriptor offset at +0x2e)
const DEF := 0x2c800 ## definition records for class keys (factory code address at +6)
const FACTORY := 0x777 ## test-only factory code address
const CONTROLLERS := 0x2e000

var memory
var port
var factory_returns_controller := true
var factory_calls: Array = []
var _next_controller := CONTROLLERS

func setup(p_memory, p_port, table_slots: int = 8) -> void:
	memory = p_memory
	port = p_port
	memory.write_u32(0x1b5a0, WORLD)
	memory.write_u32(WORLD + 0x8c, BASE)
	memory.write_u32(WORLD + 0x348, ARENA)
	memory.write_u32(0x1d6fc, ROOT)
	memory.write_u32(ROOT + 0x28, TEMPLATE)
	memory.write_u16(ROOT + 0x2e, table_slots)
	memory.write_u32(ROOT + 0x30, port.heap_calloc(table_slots, 0x18))
	var limits := [0, 0x10000, 0x40000, 0x7fffffff]
	for i in range(limits.size()):
		memory.write_u32(0x1b18c + 4 * i, limits[i])
	port.code_table[FACTORY] = Callable(self, "_factory")

## Template index `index` -> a kind-2 descriptor with class key `key` (0 = no controller).
func add_template(index: int, key: int, position: Array = [0, 0, 0]) -> void:
	var desc := BASE + 0x400 + 0x40 * index
	memory.write_u32(TEMPLATE + index * 0x18 + 0x2e, desc - BASE)
	memory.write_u8(desc, 2)
	memory.write_u8(desc + 1, key)
	for c in range(3):
		memory.write_u32(desc + 2 + 4 * c, position[c] & 0xffffffff)
	memory.write_u32(desc + 0xe, 0x7fffffff) ## range: always near enough to activate
	if key != 0:
		memory.write_u32(0x1b524 + key * 4, DEF + 0x10 * key)
		memory.write_u32(DEF + 0x10 * key + 6, FACTORY)

## A template object whose byte +1 selects template index `index`.
func template_object(address: int, index: int) -> int:
	memory.write_u8(address + 1, index)
	return address

## Range 0 and a far position: instantiate_mission_pool_slot defers the object instead of
## activating it, so it has no vertices and spawn_mission_pool_object retires it (returns 0).
func make_far(index: int) -> void:
	var desc := BASE + 0x400 + 0x40 * index
	memory.write_u32(desc + 2, 0x100000)
	memory.write_u32(desc + 0xe, 0)

## Shapes published by activate_near_range_object, in order: object_pool, then entity_array_1.
func activated() -> Array:
	var out := []
	for i in range(memory.read_u32(0x1b734)):
		out.append(memory.read_u32(0x1b5a4 + 4 * i))
	for i in range(memory.read_u32(0x1c1e0)):
		out.append(memory.read_u32(0x1d4a4 + 4 * i))
	return out

func _factory(obj: int, key: int, extra: int) -> int:
	factory_calls.append([obj, key, extra, port.a7])
	if not factory_returns_controller:
		return 0
	var ctl := _next_controller
	_next_controller += 0x100
	memory.write_u32(ctl, 0x55555555)
	return ctl
