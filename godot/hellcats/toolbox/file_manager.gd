extends RefCounted

## The File Manager calls the game makes through the ID09 glue: FSOpen, FSRead, FSClose, GetEOF,
## GetFPos, SetFPos and GetVol, over the files of one volume (hellcats/data/scenery/: the scenery
## files the game opens by name, read-only). Arguments come as the ports pass them, last-pushed
## first; FSRead's count arrives as the value (the port passes VAR count by value) and the bytes go
## to the buffer.

const VOLUME := "res://hellcats/data/scenery"
const VOLUME_NAME := "Macintosh HD"   ## not the original floppy's name (ID08 refuses to run from it)
const NO_ERR := 0
const FNF_ERR := -43
const EOF_ERR := -39
const RF_NUM_ERR := -51
const VREF := 0xffff                  ## the volume's reference number (GetVol's)

var machine
var memory
var _files: Dictionary = {}       ## refNum -> {name, bytes, mark}
var _next_ref: int = 3
## Called with (name, bytes) when a file is opened / closed (the overlay loader watches them).
var on_open: Callable
var on_close: Callable

func _init(owner) -> void:
	machine = owner
	memory = owner.memory

## The parameter-block traps (A0 the block; the port passes [D0, A0]): ioResult +0x10, ioNamePtr
## +0x12, ioVRefNum +0x16, ioRefNum +0x18, ioBuffer +0x20, ioReqCount +0x24, ioActCount +0x28,
## ioPosMode +0x2c, ioPosOffset +0x2e.
func install_traps(toolbox) -> void:
	toolbox.install(0xa000, func(a: Array) -> int:                     ## _Open
		var block: int = a[1]
		return _done(block, fs_open(memory.read_u32(block + 0x12), block + 0x18)))
	toolbox.install(0xa001, func(a: Array) -> int:                     ## _Close
		return _done(a[1], fs_close(memory.read_u16(a[1] + 0x18))))
	toolbox.install(0xa002, func(a: Array) -> int:                     ## _Read
		var block: int = a[1]
		var ref: int = memory.read_u16(block + 0x18)
		if _files.has(ref) and (memory.read_u16(block + 0x2c) & 3) == 1:
			_files[ref]["mark"] = memory.read_u32(block + 0x2e)
		var before: int = _files[ref]["mark"] if _files.has(ref) else 0
		var err: int = fs_read(ref, memory.read_u32(block + 0x24), memory.read_u32(block + 0x20))
		memory.write_u32(block + 0x28, (_files[ref]["mark"] if _files.has(ref) else 0) - before)
		return _done(block, err))

func _done(block: int, err: int) -> int:
	memory.write_u16(block + 0x10, err & 0xffff)
	return err

func install(stand_ins: Dictionary) -> void:
	stand_ins[0x2a2] = func(a: Array) -> int: return fs_open(a[2], a[0])            ## FSOpen(name, vRefNum, VAR refNum)
	stand_ins[0x2aa] = func(a: Array) -> int: return fs_close(a[0])                 ## FSClose(refNum)
	stand_ins[0x2b2] = func(a: Array) -> int: return fs_read(a[2], _value(a[1]), a[0])  ## FSRead(refNum, VAR count, buffer)
	stand_ins[0x2c2] = func(a: Array) -> int: return get_eof(a[1], a[0])            ## GetEOF(refNum, VAR eof)
	stand_ins[0x2ca] = func(a: Array) -> int: return get_fpos(a[1], a[0])           ## GetFPos(refNum, VAR pos)
	stand_ins[0x2ba] = func(a: Array) -> int: return get_vol(a[1], a[0])            ## GetVol(VAR name, VAR vRefNum)

static func _value(v) -> int:
	return int(v[0]) if v is Array else int(v)

func _pstring(at: int) -> String:
	var n: int = memory.read_u8(at)
	var out := ""
	for k in n:
		out += String.chr(memory.read_u8(at + 1 + k))
	return out

func fs_open(name_ptr: int, ref_ptr: int) -> int:
	var name: String = _pstring(name_ptr)
	var path: String = "%s/%s" % [VOLUME, name]
	if not FileAccess.file_exists(path):
		machine.log_line("FSOpen: no file %s" % name)
		return FNF_ERR & 0xffff
	var ref: int = _next_ref
	_next_ref += 1
	_files[ref] = {"name": name, "bytes": FileAccess.get_file_as_bytes(path), "mark": 0}
	memory.write_u16(ref_ptr, ref)
	if on_open.is_valid():
		on_open.call(name, _files[ref]["bytes"])
	machine.log_line("FSOpen: %s (%d bytes) as %d" % [name, _files[ref]["bytes"].size(), ref])
	return NO_ERR

func fs_read(ref: int, count: int, buffer: int) -> int:
	ref &= 0xffff
	if not _files.has(ref):
		return RF_NUM_ERR & 0xffff
	var f: Dictionary = _files[ref]
	var bytes: PackedByteArray = f["bytes"]
	var n: int = mini(count & 0xffffffff, bytes.size() - f["mark"])
	for k in n:
		memory.write_u8(buffer + k, bytes[f["mark"] + k])
	f["mark"] += n
	return NO_ERR if n == count else EOF_ERR & 0xffff

func fs_close(ref: int) -> int:
	ref &= 0xffff
	if not _files.has(ref):
		return RF_NUM_ERR & 0xffff
	var f: Dictionary = _files[ref]
	_files.erase(ref)
	if on_close.is_valid():
		on_close.call(f["name"], f["bytes"])
	return NO_ERR

func get_eof(ref: int, eof_ptr: int) -> int:
	ref &= 0xffff
	if not _files.has(ref):
		return RF_NUM_ERR & 0xffff
	memory.write_u32(eof_ptr, _files[ref]["bytes"].size())
	return NO_ERR

func get_fpos(ref: int, pos_ptr: int) -> int:
	ref &= 0xffff
	if not _files.has(ref):
		return RF_NUM_ERR & 0xffff
	memory.write_u32(pos_ptr, _files[ref]["mark"])
	return NO_ERR

## The default volume: its name (a Pascal string) and reference number -1.
func get_vol(name_ptr: int, vref_ptr: int) -> int:
	memory.write_u8(name_ptr, VOLUME_NAME.length())
	for k in VOLUME_NAME.length():
		memory.write_u8(name_ptr + 1 + k, VOLUME_NAME.unicode_at(k))
	memory.write_u16(vref_ptr, VREF)
	return NO_ERR

## The volume's files by name (the scenery files Standard File offers), sorted.
func volume_files() -> Array:
	var names: Array = []
	for name in DirAccess.get_files_at(VOLUME):
		if not name.ends_with(".import") and not name.ends_with(".uid"):
			names.append(name)
	names.sort()
	return names
