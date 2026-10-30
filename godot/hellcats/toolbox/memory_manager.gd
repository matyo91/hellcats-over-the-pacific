extends RefCounted

## The Memory Manager over the machine's heap (MacMachine.HEAP_START..HEAP_END): nonrelocatable
## blocks (pointers) and relocatable ones (handles: a master pointer, from a master pointer area at
## the heap's start, holding the block's address). Blocks never move and are not reclaimed; the
## heap is large enough for the game. Sizes are kept per block for GetPtrSize / GetHandleSize.
## Installed both as the OS traps and as the ID09 glue slots the ports call (the glue pops the
## arguments into registers and pushes the result back).

const MASTER_POINTERS := 0x10000   ## bytes of master pointers at the heap's start

var machine
var memory
var _next_master: int
var _next_block: int
var _sizes: Dictionary = {}      ## block address -> logical size
var _state: Dictionary = {}      ## handle -> HGetState byte (bit 7 locked, 6 purgeable, 5 resource)
var mem_error: int = 0
## One allocation placed at a given address (the overlay image: see overlay_loader.gd).
var _reserved_size: int = -1
var _reserved_at: int = 0

func _init(owner) -> void:
	machine = owner
	memory = owner.memory
	_next_master = owner.HEAP_START
	_next_block = owner.HEAP_START + MASTER_POINTERS

func install(toolbox, stand_ins: Dictionary) -> void:
	# The ID09 glue slots (jump-table A5 offsets), each with the arguments as the ports pass them.
	stand_ins[0x212] = func(_a: Array) -> int: return free_mem()                          ## FreeMem
	stand_ins[0x21a] = func(a: Array) -> int:                                              ## MaxMem(VAR grow)
		if a.size() > 0 and a[0] is int and a[0] != 0:
			memory.write_u32(a[0], 0)
		return free_mem()
	stand_ins[0x222] = func(_a: Array) -> int: return 0                                    ## MaxApplZone
	stand_ins[0x292] = func(_a: Array) -> int: return 0                                    ## MoreMasters
	stand_ins[0x22a] = func(a: Array) -> int: return new_ptr(a[0], false)                  ## NewPtr(size)
	stand_ins[0x232] = func(a: Array) -> int: return new_ptr(a[0], true)                   ## NewPtrClear(size)
	stand_ins[0x23a] = func(_a: Array) -> int: return 0                                    ## DisposePtr
	stand_ins[0x242] = func(a: Array) -> int: return _sizes.get(a[0] & 0xffffffff, 0)      ## GetPtrSize
	stand_ins[0x24a] = func(a: Array) -> int: return new_handle(a[0], false)               ## NewHandle(size)
	stand_ins[0x252] = func(a: Array) -> int: return new_handle(a[0], true)                ## NewHandleClear(size)
	stand_ins[0x25a] = func(_a: Array) -> int: return 0                                    ## DisposeHandle
	stand_ins[0x262] = func(a: Array) -> int: return recover_handle(a[0])                  ## RecoverHandle(p)
	stand_ins[0x26a] = func(a: Array) -> int: return set_handle_size(a[1], a[0])           ## SetHandleSize(h, size)
	stand_ins[0x272] = func(a: Array) -> int: return _flag(a[0], 0x80, true)               ## HLock
	stand_ins[0x27a] = func(a: Array) -> int: return _flag(a[0], 0x80, false)              ## HUnlock
	stand_ins[0x282] = func(a: Array) -> int: return _flag(a[0], 0x40, true)               ## HPurge
	stand_ins[0x28a] = func(a: Array) -> int: return _flag(a[0], 0x40, false)              ## HNoPurge
	stand_ins[0x29a] = func(_a: Array) -> int: return mem_error                            ## MemError
	stand_ins[0x2d2] = func(a: Array) -> int: return (_state.get(a[0] & 0xffffffff, 0)) << 8  ## HGetState (byte in the high byte)
	toolbox.install(0xa11e, func(a: Array) -> int: return new_ptr(a[0], false))
	toolbox.install(0xa31e, func(a: Array) -> int: return new_ptr(a[0], true))
	toolbox.install(0xa122, func(a: Array) -> int: return new_handle(a[0], false))
	toolbox.install(0xa322, func(a: Array) -> int: return new_handle(a[0], true))
	toolbox.install(0xa01f, func(_a: Array) -> int: return 0)
	toolbox.install(0xa023, func(_a: Array) -> int: return 0)
	toolbox.install(0xa029, func(a: Array) -> int: return _flag(a[0], 0x80, true))
	toolbox.install(0xa02a, func(a: Array) -> int: return _flag(a[0], 0x80, false))
	toolbox.install(0xa049, func(a: Array) -> int: return _flag(a[0], 0x40, true))
	toolbox.install(0xa04a, func(a: Array) -> int: return _flag(a[0], 0x40, false))
	toolbox.install(0xa027, func(a: Array) -> int: return set_handle_size(a[0], a[1]))
	toolbox.install(0xa025, func(a: Array) -> int: return handle_size(a[0]))
	toolbox.install(0xa021, func(a: Array) -> int: return _sizes.get(a[0] & 0xffffffff, 0))
	toolbox.install(0xa01c, func(_a: Array) -> int: return free_mem())
	toolbox.install(0xa11d, func(_a: Array) -> int: return free_mem())
	toolbox.install(0xa036, func(_a: Array) -> int: return 0)
	toolbox.install(0xa063, func(_a: Array) -> int: return 0)
	toolbox.install(0xa069, func(a: Array) -> int: return _state.get(a[0] & 0xffffffff, 0))
	toolbox.install(0xa06a, func(a: Array) -> int:                                         ## HSetState(h, flags)
		_state[a[1] & 0xffffffff] = a[0] & 0xff
		return 0)

func reserve(size: int, address: int) -> void:
	_reserved_size = size
	_reserved_at = address

func free_mem() -> int:
	return machine.HEAP_END - _next_block

## A zeroed (or not) block of `size` bytes, long-aligned; 0 and memFullErr when the heap is full.
func new_ptr(size: int, clear: bool) -> int:
	size = maxi(size & 0xffffffff, 0)
	if size == _reserved_size:
		_reserved_size = -1
		_sizes[_reserved_at] = size
		if clear:
			for k in size:
				memory.write_u8(_reserved_at + k, 0)
		return _reserved_at
	var at: int = _next_block
	if at + size > machine.HEAP_END:
		mem_error = -108
		return 0
	# An empty block still takes a long, so it never shares its address with the next one.
	_next_block = (at + maxi(size, 1) + 3) & ~3
	_sizes[at] = size
	if clear:
		for k in size:
			memory.write_u8(at + k, 0)
	mem_error = 0
	return at

func new_handle(size: int, clear: bool) -> int:
	var block: int = new_ptr(size, clear)
	if block == 0 and size > 0:
		return 0
	var master: int = _next_master
	_next_master += 4
	memory.write_u32(master, block)
	_state[master] = 0
	return master

## A handle to `bytes` (the Resource Manager's way in).
func handle_with(bytes: PackedByteArray) -> int:
	var h: int = new_handle(bytes.size(), false)
	var block: int = memory.read_u32(h)
	for k in bytes.size():
		memory.write_u8(block + k, bytes[k])
	return h

func handle_size(h: int) -> int:
	return _sizes.get(memory.read_u32(h & 0xffffffff), 0)

func set_handle_size(h: int, size: int) -> int:
	h &= 0xffffffff
	var old: int = memory.read_u32(h)
	var old_size: int = _sizes.get(old, 0)
	if size <= old_size:
		_sizes[old] = size
		mem_error = 0
		return 0
	var block: int = new_ptr(size, true)
	if block == 0:
		return -108
	for k in old_size:
		memory.write_u8(block + k, memory.read_u8(old + k))
	memory.write_u32(h, block)
	return 0

func recover_handle(p: int) -> int:
	for master in _state:
		if memory.read_u32(master) == (p & 0xffffffff):
			return master
	return 0

func _flag(h: int, bit: int, on: bool) -> int:
	h &= 0xffffffff
	var s: int = _state.get(h, 0)
	_state[h] = (s | bit) if on else (s & ~bit)
	mem_error = 0
	return 0

func mark_resource(h: int) -> void:
	_state[h] = _state.get(h, 0) | 0x20

## Resource attributes kept per handle (resPurgeable 0x20, resLocked 0x10, ...): the resource fork's
## own attributes are 0x20 for these resources (the evidence records them so).
var _attrs: Dictionary = {}

func resource_attrs(h: int) -> int:
	return _attrs.get(h & 0xffffffff, 0x20)

func set_resource_attrs(h: int, attrs: int) -> void:
	_attrs[h & 0xffffffff] = attrs & 0xff
