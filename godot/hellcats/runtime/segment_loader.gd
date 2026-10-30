extends RefCounted

## The application's CODE segments as their strict ports (godot/strict_port/code/ID02..ID09.gd), all
## on the machine's one memory and A5, linked as the Segment Manager links them: every jump-table
## slot (hellcats/data/jump_table.json, built from CODE 0 by tools/hellcats/build_runtime_data.py)
## calls the ported routine it targets, or the runtime's own stand-in for routines that are not in
## the port (the ID09 Toolbox glue, a few unexported routines). Each segment port gets its own view
## of the slots, so a call can give the callee a stack pointer below the caller's frame.
##
## Arguments: a port passes a call's arguments last-pushed first, which is the C order of the
## callee's parameters (MPW C pushes right to left), so they go to the ported method as they come.

const JUMP_TABLE := "res://hellcats/data/jump_table.json"
const SEGMENT_METHODS := "res://hellcats/data/segment_methods.json"
const PORTS := {
	2: preload("res://strict_port/code/ID02.gd"), 3: preload("res://strict_port/code/ID03.gd"),
	4: preload("res://strict_port/code/ID04.gd"), 5: preload("res://strict_port/code/ID05.gd"),
	6: preload("res://strict_port/code/ID06.gd"), 7: preload("res://strict_port/code/ID07.gd"),
	8: preload("res://strict_port/code/ID08.gd"), 9: preload("res://strict_port/code/ID09.gd")}
## The stack a callee gets below its caller's entry pointer (the caller's frame is smaller).
const CALL_FRAME := 0x400

var machine
var entries: Array = []
## segment number -> its port instance
var instances: Dictionary = {}
## A5 offset -> stand-in Callable(args: Array) -> int, for slots whose routine is not ported.
var stand_ins: Dictionary = {}
## Per segment: its code routines by key -> Callable(args: Array) -> int. A segment's own routines
## the port calls by offset (`_local`) are keyed by that offset; code addresses reached through
## pointers (overlay hooks, the overlay entry) are added to every segment's table.
var code_routines: Dictionary = {}
## The Pacific Conflict overlay's port, once the scenery file is loaded.
var overlay
## A5 offset -> Callable() run before that slot's routine (the overlay loader's link step).
var before_slot: Dictionary = {}

func _init(owner) -> void:
	machine = owner
	var doc: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(JUMP_TABLE))
	entries = doc["entries"]
	for segment in PORTS:
		var port = PORTS[segment].new(machine.memory, machine.A5)
		instances[segment] = port
	for segment in instances:
		var port = instances[segment]
		port.traps = machine.toolbox.traps
		code_routines[segment] = {}
		port.code_routines = code_routines[segment]
		port.jt_routines = _slots_for(port)
	instances[2].code_base = machine.CODE2_BASE
	# Ported routines a port calls by their offset in its segment (`_local`).
	var methods: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SEGMENT_METHODS))
	for segment_key in methods:
		var segment: int = int(segment_key)
		if not instances.has(segment):
			continue
		for offset_key in methods[segment_key]:
			register_local(segment, offset_key.hex_to_int(), _local_call(instances[segment], methods[segment_key][offset_key]))

## One port's view of the jump table.
func _slots_for(caller) -> Dictionary:
	var slots := {}
	for e in entries:
		var offset: int = int(e["a5_offset"])
		slots[offset] = _slot(caller, e)
	return slots

func _slot(caller, e: Dictionary) -> Callable:
	var offset: int = int(e["a5_offset"])
	var segment: int = int(e["segment"])
	var method = e["method"]
	if method != null and instances.has(segment):
		var callee = instances[segment]
		var arity: int = _arity(callee, method)
		var has_stack: bool = has_stack_pointer(callee)
		var caller_stack: bool = has_stack_pointer(caller)
		var pascal: bool = bool(e.get("pascal", false))
		return func(args: Array) -> int:
			if before_slot.has(offset):
				before_slot[offset].call()
			var saved: int = callee.a7 if has_stack else 0
			if has_stack:
				var above: int = int(caller.a7) if caller_stack else 0
				callee.a7 = (above if above != 0 else machine.free_stack()) - CALL_FRAME
			var list: Array = args.duplicate()
			if pascal:
				list.reverse()
			if list.size() != arity:
				machine.note_missing("arity:%s" % method, "%d args for %d parameters" % [list.size(), arity])
				list.resize(arity)
				for k in arity:
					if list[k] == null:
						list[k] = 0
			var result = callee.callv(method, list)
			if has_stack:
				callee.a7 = saved
			return 0 if result == null else int(result)
	return func(args: Array) -> int:
		if stand_ins.has(offset):
			return stand_ins[offset].call(args)
		machine.note_missing("jt:$%x" % offset, "segment %d +0x%x, %d args" % [segment, int(e["target"]), args.size()])
		return 0

## A ported routine called by offset from its own segment, with the caller's arguments in order.
func _local_call(port, method: String) -> Callable:
	var arity: int = _arity(port, method)
	return func(args: Array) -> int:
		var list: Array = args.duplicate()
		list.resize(arity)
		for k in arity:
			if list[k] == null:
				list[k] = 0
		var r = port.callv(method, list)
		return 0 if r == null else int(r)

static func has_stack_pointer(port) -> bool:
	for p in port.get_property_list():
		if p["name"] == "a7":
			return true
	return false

func _arity(port, method: String) -> int:
	for m in port.get_method_list():
		if m["name"] == method:
			return m["args"].size()
	push_error("ported method %s not found" % method)
	return 0

## The segment port holding a ported routine name.
func port_of(segment: int):
	return instances.get(segment)

func all_ports() -> Array:
	var out: Array = instances.values()
	if overlay != null:
		out.append(overlay)
	return out

## Calls the routine at a code address with its parameters in declaration order (a procedure
## pointer the Toolbox calls back: a dialog filter or user item, given as a jump-table slot
## address); returns its result.
func call_procedure(address: int, params: Array) -> int:
	address &= 0xffffffff
	var offset: int = address - machine.A5
	for e in entries:
		if int(e["a5_offset"]) != offset:
			continue
		var segment: int = int(e["segment"])
		if e["method"] != null and instances.has(segment):
			var callee = instances[segment]
			var list: Array = params.duplicate()
			list.resize(_arity(callee, e["method"]))
			for k in list.size():
				if list[k] == null:
					list[k] = 0
			var saved: int = callee.a7 if has_stack_pointer(callee) else 0
			if has_stack_pointer(callee):
				callee.a7 = machine.free_stack()
			var r = callee.callv(e["method"], list)
			if has_stack_pointer(callee):
				callee.a7 = saved
			return 0 if r == null else int(r)
		if stand_ins.has(offset):
			return int(stand_ins[offset].call(params))
		machine.note_missing("procedure:$%x" % offset, "segment %d +0x%x" % [segment, int(e["target"])])
		return 0
	for segment in code_routines:
		if code_routines[segment].has(address):
			return code_routines[segment][address].call(params)
	machine.note_missing("procedure:0x%x" % address, "not a jump-table slot")
	return 0

## Whether a code address is something call_procedure reaches: a ported jump-table slot or a
## registered routine.
func is_routine(address: int) -> bool:
	address &= 0xffffffff
	var offset: int = address - machine.A5
	for e in entries:
		if int(e["a5_offset"]) == offset:
			return e["method"] != null or stand_ins.has(offset)
	for segment in code_routines:
		if code_routines[segment].has(address):
			return true
	return false

## A segment routine the port calls by its offset (not exported by the port: the runtime's own).
func register_local(segment: int, offset: int, routine: Callable) -> void:
	code_routines[segment][offset] = routine

## A code address reached through a pointer, known to every segment.
func register_address(address: int, routine: Callable) -> void:
	for segment in code_routines:
		code_routines[segment][address] = routine

## The overlay calls the host through jump-table slot addresses (A5 + offset, from the service table
## ID02 0x1b42 fills) with its arguments as positional values: each slot as such a Callable.
func link_overlay(port) -> void:
	overlay = port
	for e in entries:
		var slot: Callable = _slot(port, e)
		port.code_table[machine.A5 + int(e["a5_offset"])] = func(...args: Array) -> int: return slot.call(args)
