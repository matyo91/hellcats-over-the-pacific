extends RefCounted

## The Resource Manager over the application's resource fork, read from the strict port's mirror
## (godot/strict_port/<type>/<id>.bin, the original payloads) and, for names, from
## hellcats/data/resource_names.json. A resource is loaded once into a handle (the Memory
## Manager's) and the same handle is returned after that, as the Resource Manager does. Resources
## the game adds (its settings when they are missing) stay in memory for the session.

const Files := preload("res://strict_port/ui/resource_files.gd")
const NAMES := "res://hellcats/data/resource_names.json"

## Four-character codes whose mirror folder is not the code itself.
const FOLDERS := {"snd ": "snds", "icl4": "icI4", "icl8": "icI8"}
const APPLICATION_FILE := 1
const SAVED := "user://resources"

var machine
var memory
var heap
var _handles: Dictionary = {}     ## "TYPE:id" -> handle
var _names: Dictionary = {}       ## "TYPE:name" -> id
var res_error: int = 0
var _changed: Dictionary = {}     ## handle -> true, marked by ChangedResource / AddResource

func _init(owner, memory_manager) -> void:
	machine = owner
	memory = owner.memory
	heap = memory_manager
	for e in JSON.parse_string(FileAccess.get_file_as_string(NAMES)):
		_names["%s:%s" % [e["type"], String(e["name"]).to_lower()]] = int(e["id"])

static func fourcc(code: int) -> String:
	var out := ""
	for shift in [24, 16, 8, 0]:
		out += String.chr((code >> shift) & 0xff)
	return out

func install(toolbox) -> void:
	toolbox.install(0xa9a0, func(a: Array) -> int: return get_resource(fourcc(a[1]), a[0]))   ## GetResource(type, id)
	toolbox.install(0xa81f, func(a: Array) -> int: return get_resource(fourcc(a[1]), a[0]))   ## Get1Resource
	toolbox.install(0xa9a1, func(a: Array) -> int: return get_named(fourcc(a[1]), a[0]))      ## GetNamedResource(type, name)
	toolbox.install(0xa820, func(a: Array) -> int: return get_named(fourcc(a[1]), a[0]))      ## Get1NamedResource
	toolbox.install(0xa9a3, func(_a: Array) -> int: return 0)                                  ## ReleaseResource
	toolbox.install(0xa992, func(a: Array) -> int: return detach(a[0]))                        ## DetachResource
	toolbox.install(0xa9a2, func(_a: Array) -> int: return 0)                                  ## LoadResource
	toolbox.install(0xa9aa, func(a: Array) -> int:                                             ## ChangedResource
		_changed[a[0] & 0xffffffff] = true
		return 0)
	toolbox.install(0xa9b0, func(a: Array) -> int: return write(a[0] & 0xffffffff))            ## WriteResource
	toolbox.install(0xa999, func(_a: Array) -> int:                                            ## UpdateResFile
		for h in _changed.keys():
			write(h)
		return 0)
	toolbox.install(0xa994, func(_a: Array) -> int: return APPLICATION_FILE)                   ## CurResFile
	toolbox.install(0xa998, func(_a: Array) -> int: return 0)                                  ## UseResFile
	toolbox.install(0xa9a4, func(_a: Array) -> int: return APPLICATION_FILE)                   ## HomeResFile
	toolbox.install(0xa99b, func(_a: Array) -> int: return 0)                                  ## SetResLoad
	toolbox.install(0xa9af, func(_a: Array) -> int: return res_error)                          ## ResError
	toolbox.install(0xa9a5, func(a: Array) -> int: return heap.handle_size(a[0]))              ## SizeResource
	toolbox.install(0xa9a6, func(a: Array) -> int: return heap.resource_attrs(a[0]))           ## GetResAttrs: word
	toolbox.install(0xa9a7, func(a: Array) -> int:                                             ## SetResAttrs(h, attrs)
		heap.set_resource_attrs(a[1], a[0])
		return 0)
	toolbox.install(0xa9ad, func(a: Array) -> int: return remove(a[0] & 0xffffffff))           ## RmveResource(h)
	toolbox.install(0xa9ab, func(a: Array) -> int:                                             ## AddResource(h, type, id, name)
		_handles["%s:%d" % [fourcc(a[2]), _s16(a[1])]] = a[3] & 0xffffffff
		heap.mark_resource(a[3] & 0xffffffff)
		_changed[a[3] & 0xffffffff] = true
		res_error = 0
		return 0)

static func _s16(v: int) -> int:
	v &= 0xffff
	return v - 0x10000 if v >= 0x8000 else v

func get_resource(type_code: String, id: int) -> int:
	id = _s16(id)
	var key := "%s:%d" % [type_code, id]
	if _handles.has(key):
		res_error = 0
		return _handles[key]
	var folder: String = FOLDERS.get(type_code, type_code)
	var saved: String = _saved_path(type_code, id)
	var bytes := PackedByteArray()
	if FileAccess.file_exists(saved):
		bytes = FileAccess.get_file_as_bytes(saved)
	elif Files.exists(folder, id):
		bytes = Files.load_bytes(folder, id)
	else:
		res_error = -192
		return 0
	var h: int = heap.handle_with(bytes)
	heap.mark_resource(h)
	_handles[key] = h
	res_error = 0
	return h

## By the Pascal string at `name`.
func get_named(type_code: String, name: int) -> int:
	var text: String = Files.pstring(_bytes_at(name, memory.read_u8(name) + 1), 0)[0]
	var key := "%s:%s" % [type_code, text.to_lower()]   ## names compare without case, as the Resource Manager's do
	if not _names.has(key):
		machine.note_missing("resource:%s" % key, "GetNamedResource")
		res_error = -192
		return 0
	return get_resource(type_code, _names[key])

static func _saved_path(type_code: String, id: int) -> String:
	return "%s/%s/%d.bin" % [SAVED, type_code.strip_edges().to_lower().uri_encode(), id]

## A changed resource's bytes written to its saved copy (nothing for a handle that is not one).
func write(h: int) -> int:
	if not _changed.has(h):
		return 0
	for key in _handles:
		if _handles[key] != h:
			continue
		var type_code: String = key.substr(0, 4)
		var path: String = _saved_path(type_code, int(key.substr(5)))
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f == null:
			res_error = -34
			return res_error
		f.store_buffer(_bytes_at(memory.read_u32(h), heap.handle_size(h)))
		f.close()
		_changed.erase(h)
		return 0
	return 0

## RmveResource: the resource gone from the file (its saved copy deleted, the handle kept in memory).
func remove(h: int) -> int:
	for key in _handles.keys():
		if _handles[key] != h:
			continue
		var path: String = _saved_path(key.substr(0, 4), int(key.substr(5)))
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		_handles.erase(key)
		_changed.erase(h)
		res_error = 0
		return 0
	res_error = -192
	return 0

## A 'PICT' handle's picture, as the strict mirror decodes it (its .png); null for anything else.
func picture_image(h: int) -> Image:
	h &= 0xffffffff
	for key in _handles:
		if _handles[key] == h and key.begins_with("PICT:"):
			return picture(int(key.substr(5)))
	return null

## The mirror's picture as an Image, decoded from its .png here: the game's thread must not make
## textures (that waits for the rendering thread).
static func picture(id: int) -> Image:
	if not Files.exists("PICT", id, "png"):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(Files.path("PICT", id, "png"))) != OK:
		return null
	return image

func detach(h: int) -> int:
	for key in _handles.keys():
		if _handles[key] == (h & 0xffffffff):
			_handles.erase(key)
	return 0

func _bytes_at(at: int, count: int) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(count)
	for k in count:
		out[k] = memory.read_u8(at + k)
	return out
