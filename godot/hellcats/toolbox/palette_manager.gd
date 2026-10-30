extends RefCounted

## The Palette Manager and the screen's colour table. The screen device's 256 colours start as the
## default 8-bit table and change as the program sets them: SetEntries on the device table, and its
## palettes (NewPalette, SetEntryColor / SetEntryUsage, SetPalette / ActivatePalette, AnimateEntry /
## AnimatePalette) whose entries own device indices. Palette entry i owns device index i + 1: the
## Palette Manager never gives away 0 (white) and 255 (black), which the menus and windows keep
## (the game's 8-bit palette has 0xd9 entries, 0xc8 of them animated). PmForeColor(entry) leaves
## that index in the port's fgColor, and the frames the game draws with those indices show the
## colours it animates. The screen (mac_screen.gd) redraws
## through the table whenever `version` moves.

const Images := preload("res://strict_port/ui/resource_images.gd")

var machine
var memory
var heap
var qd
var table: Array = []                ## 256 device colours
var version: int = 0
var _lock := Mutex.new()
var _palettes: Dictionary = {}       ## palette handle -> Array of [Color, usage]

func _init(owner, toolbox) -> void:
	machine = owner
	memory = owner.memory
	heap = toolbox.heap
	qd = toolbox.quickdraw
	table = Images.clut8()

func colours() -> Array:
	_lock.lock()
	var out: Array = table.duplicate()
	_lock.unlock()
	return out

static func device_index(entry: int) -> int:
	return clampi(entry + 1, 1, 254)

func set_device(index: int, c: Color) -> void:
	_lock.lock()
	table[index & 0xff] = c
	version += 1
	_lock.unlock()

static func _rgb16(m, at: int) -> Color:
	return Color8(m.read_u16(at) >> 8, m.read_u16(at + 2) >> 8, m.read_u16(at + 4) >> 8)

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xaa91, func(a: Array) -> int: return new_palette(a[3], a[2]))               ## NewPalette(n, colours, usage, tol)
	t.install(0xaa92, func(a: Array) -> int: return new_palette(memory.read_u16(memory.read_u32(a[0]) + 6) + 1, a[0]))  ## GetNewPalette
	t.install(0xaa93, func(_a: Array) -> int: return 0)                                    ## DisposePalette
	t.install(0xaa94, func(a: Array) -> int: return activate(a[0]))                        ## ActivatePalette(window)
	t.install(0xaa95, func(a: Array) -> int:                                               ## SetPalette(window, palette, cUpdates)
		_window_palette[a[2] & 0xffffffff] = a[1] & 0xffffffff
		return activate(a[2]))
	t.install(0xaa96, func(a: Array) -> int: return _window_palette.get(a[0] & 0xffffffff, 0))  ## GetPalette(window)
	t.install(0xaa97, func(a: Array) -> int: return pm_color(false, a[0]))                 ## PmForeColor(entry)
	t.install(0xaa98, func(a: Array) -> int: return pm_color(true, a[0]))                  ## PmBackColor(entry)
	t.install(0xaa99, func(a: Array) -> int:                                               ## AnimateEntry(window, entry, rgb)
		var pal: int = _window_palette.get(a[2] & 0xffffffff, 0)
		var c: Color = _rgb16(memory, a[0])
		var e: int = qd.s16(a[1])
		if _palettes.has(pal) and e >= 0 and e < _palettes[pal].size():
			_palettes[pal][e][0] = c
		set_device(device_index(e), c)
		return 0)
	t.install(0xaa9a, func(a: Array) -> int:                                               ## AnimatePalette(window, src, srcIndex, dstEntry, count)
		var src: int = a[3] & 0xffffffff
		if _palettes.has(src):
			for k in qd.s16(a[0]):
				var i: int = qd.s16(a[2]) + k
				if i < _palettes[src].size():
					set_device(device_index(qd.s16(a[1]) + k), _palettes[src][i][0])
		return 0)
	t.install(0xaa9c, func(a: Array) -> int:                                               ## SetEntryColor(palette, entry, rgb)
		var pal: int = a[2] & 0xffffffff
		if _palettes.has(pal) and qd.s16(a[1]) < _palettes[pal].size():
			_palettes[pal][qd.s16(a[1])][0] = _rgb16(memory, a[0])
		return 0)
	t.install(0xaa9b, func(a: Array) -> int:                                               ## GetEntryColor(palette, entry, VAR rgb)
		var pal: int = a[2] & 0xffffffff
		var c: Color = _palettes[pal][qd.s16(a[1])][0] if _palettes.has(pal) else Color.BLACK
		memory.write_u16(a[0], c.r8 * 0x101)
		memory.write_u16(a[0] + 2, c.g8 * 0x101)
		memory.write_u16(a[0] + 4, c.b8 * 0x101)
		return 0)
	t.install(0xaa9e, func(a: Array) -> int:                                               ## SetEntryUsage(palette, entry, usage, tol)
		var pal: int = a[3] & 0xffffffff
		if _palettes.has(pal) and qd.s16(a[2]) < _palettes[pal].size():
			_palettes[pal][qd.s16(a[2])][1] = a[1] & 0xffff
		return 0)
	t.install(0xaa9f, func(_a: Array) -> int: return 0)                                   ## CTab2Palette / others
	t.install(0xaa3f, func(a: Array) -> int:                                               ## SetEntries(start, count, specs)
		var start: int = qd.s16(a[2])
		for k in qd.s16(a[1]) + 1:
			var spec: int = a[0] + 8 * k
			var index: int = memory.read_u16(spec) if start < 0 else start + k
			set_device(index, _rgb16(memory, spec + 2))
		return 0)
	t.install(0xaa33, func(a: Array) -> int:                                               ## Color2Index(rgb)
		return nearest(_rgb16(memory, a[0])))
	t.install(0xaa34, func(a: Array) -> int:                                               ## Index2Color(index, VAR rgb)
		var c: Color = colours()[a[1] & 0xff]
		memory.write_u16(a[0], c.r8 * 0x101)
		memory.write_u16(a[0] + 2, c.g8 * 0x101)
		memory.write_u16(a[0] + 4, c.b8 * 0x101)
		return 0)

var _window_palette: Dictionary = {}

## A palette of `count` entries, from a colour table when `colours` is one (its ColorSpecs).
func new_palette(count: int, colours: int) -> int:
	count = qd.s16(count)
	var h: int = heap.new_handle(16, true)
	var entries: Array = []
	for i in count:
		var c: Color = Color.BLACK
		if colours != 0 and i <= memory.read_u16(memory.read_u32(colours) + 6):
			c = _rgb16(memory, memory.read_u32(colours) + 8 + 8 * i + 2)
		entries.append([c, 0])
	_palettes[h] = entries
	return h

## A window's palette onto the device: every entry's colour into the device index it owns.
func activate(window: int) -> int:
	var pal: int = _window_palette.get(window & 0xffffffff, 0)
	if _palettes.has(pal):
		var entries: Array = _palettes[pal]
		for i in entries.size():
			set_device(device_index(i), entries[i][0])
	return 0

func pm_color(background: bool, entry: int) -> int:
	var port: int = qd.the_port()
	var e: int = qd.s16(entry)
	var pal: int = _window_palette.get(port, 0)
	var c: Color = colours()[device_index(e)]
	if _palettes.has(pal) and e < _palettes[pal].size():
		c = _palettes[pal][e][0]
	if qd.is_color(memory, port):
		memory.write_u16(port + (0x2a if background else 0x24), c.r8 * 0x101)
		memory.write_u16(port + (0x2c if background else 0x26), c.g8 * 0x101)
		memory.write_u16(port + (0x2e if background else 0x28), c.b8 * 0x101)
		memory.write_u32(port + (0x54 if background else 0x50), device_index(e))
	return 0

## The device index nearest a colour.
func nearest(c: Color) -> int:
	var t: Array = colours()
	var best: int = 0
	var best_d: int = 1 << 60
	for k in 256:
		var d: int = int(pow(t[k].r8 - c.r8, 2) + pow(t[k].g8 - c.g8, 2) + pow(t[k].b8 - c.b8, 2))
		if d < best_d:
			best_d = d
			best = k
	return best
