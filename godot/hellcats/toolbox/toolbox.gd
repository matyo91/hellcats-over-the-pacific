extends RefCounted

## The Macintosh Toolbox and Operating System the strict port calls through its trap table: one
## Callable(args: Array) -> int per A-line trap word. A port passes a trap's arguments last-pushed
## first (for a Pascal routine, its parameters in reverse) and takes the Pascal result as the stub
## returns it: a Boolean in the high byte of the result word, a word or long as is. Every trap
## word starts as a stand-in that notes it on the machine and returns 0; the managers replace the
## ones they implement.

const MemoryManager := preload("res://hellcats/toolbox/memory_manager.gd")
const ResourceManager := preload("res://hellcats/toolbox/resource_manager.gd")
const QuickDraw := preload("res://hellcats/toolbox/quickdraw.gd")
const QuickDrawTraps := preload("res://hellcats/toolbox/quickdraw_traps.gd")
const FileManager := preload("res://hellcats/toolbox/file_manager.gd")
const EventManager := preload("res://hellcats/toolbox/event_manager.gd")
const WindowManager := preload("res://hellcats/toolbox/window_manager.gd")
const DialogManager := preload("res://hellcats/toolbox/dialog_manager.gd")
const MenuManager := preload("res://hellcats/toolbox/menu_manager.gd")
const PaletteManager := preload("res://hellcats/toolbox/palette_manager.gd")
const TextEditManager := preload("res://hellcats/toolbox/text_edit.gd")
const SoundManager := preload("res://hellcats/toolbox/sound_manager.gd")
const StandardFile := preload("res://hellcats/toolbox/standard_file.gd")

var machine
var traps: Dictionary = {}
var heap
var resources
var quickdraw
var files
var events
var windows
var dialogs
var menus
var palettes
var sounds

func _init(owner) -> void:
	machine = owner
	for word in range(0xa000, 0xac00):
		traps[word] = _missing(word)
	heap = MemoryManager.new(owner)
	resources = ResourceManager.new(owner, heap)
	quickdraw = QuickDraw.new(owner, heap)
	files = FileManager.new(owner)
	events = EventManager.new(owner)
	windows = WindowManager.new(owner, quickdraw, heap)
	events.windows = windows
	resources.install(self)
	QuickDrawTraps.new(quickdraw).install(self)
	quickdraw.make_main_device()
	files.install_traps(self)
	events.install(self)
	windows.install(self)
	dialogs = DialogManager.new(owner, self)
	dialogs.install(self)
	menus = MenuManager.new(owner, self)
	menus.install(self)
	for word in [0xa930, 0xa9cc, 0xa97b, 0xa9f1]:       ## InitMenus, TEInit, InitDialogs, UnloadSeg
		install(word, func(_a: Array) -> int: return 0)
	palettes = PaletteManager.new(owner, self)
	palettes.install(self)
	TextEditManager.new(owner, self).install(self)
	sounds = SoundManager.new(owner, self)
	sounds.install(self)
	install(0xa9f4, func(_a: Array) -> int:              ## ExitToShell: the program ends here
		machine.log_line("ExitToShell")
		events.stopping = true
		machine.exited = true
		machine.park()
		return 0)
	install(0xa9c8, func(_a: Array) -> int: return 0)    ## SysBeep
	install(0xa86a, func(a: Array) -> int: return (a[0] >> 16) & 0xffff)   ## HiWord(long)
	install(0xa86b, func(a: Array) -> int: return a[0] & 0xffff)           ## LoWord(long)

## Installs the managers' jump-table stand-ins (the ID09 glue) once the segments exist.
func install_glue(stand_ins: Dictionary) -> void:
	heap.install(self, stand_ins)
	files.install(stand_ins)
	StandardFile.new(machine, self).install(stand_ins)
	stand_ins[0x202] = func(_a: Array) -> int: return traps[0xa032].call([])     ## FlushEvents(mask, stop)
	stand_ins[0x1fa] = func(_a: Array) -> int: return 0                            ## the event glue: pops its word
	stand_ins[0x20a] = func(_a: Array) -> int: return machine.MENU_BAR_HEIGHT       ## GetMBarHeight
	stand_ins[0x2da] = func(_a: Array) -> int: return 0x100                        ## HasDeepScreens: true (Boolean in the high byte)
	stand_ins[0x1f2] = func(a: Array) -> int: return sys_environs(a[0])            ## SysEnvirons(version, VAR rec)
	stand_ins[0x302] = func(a: Array) -> int: return c_to_pascal(a[0])             ## c2pstr in place
	stand_ins[0x2f2] = func(a: Array) -> int: return num_to_string(a[1], a[0])     ## NumToString(n, VAR s)

func _missing(word: int) -> Callable:
	return func(args: Array) -> int:
		machine.note_missing("trap:%04x" % word, "%d args" % args.size())
		return 0

## Installs a manager's routine for a trap word (the program's thread parks there once the machine
## is halting).
func install(word: int, routine: Callable) -> void:
	traps[word] = func(args: Array) -> int:
		if machine.halting:
			machine.park()
		if sounds != null:
			sounds.service()
		return routine.call(args)

## SysEnvirons version 1: environsVersion 1, machineType (a Mac II class), systemVersion 7.0.1,
## processor 68020 (3), hasFPU, hasColorQD, keyBoardType, atDrvrVersNum, sysVRefNum.
func sys_environs(rec: int) -> int:
	var m = machine.memory
	m.write_u16(rec, 1)
	m.write_u16(rec + 2, 6)
	m.write_u16(rec + 4, 0x0701)
	m.write_u16(rec + 6, 3)
	m.write_u8(rec + 8, 1)
	m.write_u8(rec + 9, 1)
	m.write_u16(rec + 10, 2)
	m.write_u16(rec + 12, 0)
	m.write_u16(rec + 14, 0xffff)
	return 0

## A C string made a Pascal string in place (its length first, the characters one on).
func c_to_pascal(p: int) -> int:
	var m = machine.memory
	var n: int = 0
	while m.read_u8(p + n) != 0 and n < 255:
		n += 1
	for k in range(n, 0, -1):
		m.write_u8(p + k, m.read_u8(p + k - 1))
	m.write_u8(p, n)
	return p

## NumToString: the long in decimal as a Pascal string.
func num_to_string(n: int, out: int) -> int:
	n &= 0xffffffff
	var text: String = str(n if n < 0x80000000 else n - 0x100000000)
	var m = machine.memory
	m.write_u8(out, text.length())
	for k in text.length():
		m.write_u8(out + 1 + k, text.unicode_at(k))
	return 0
