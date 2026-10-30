class_name MacMachine
extends RefCounted

## The Macintosh the strict port runs on: one flat 68000 address space (godot/strict_port/compat/
## memory_68k.gd) laid out as the original expects, the application's A5 world, the CODE segments
## and the Pacific Conflict overlay as their strict ports (segment_loader.gd), and the Toolbox the
## ports call through their trap tables (toolbox/toolbox.gd).
##
## Memory map (one 24-bit address space, as on the Mac of the game's era: mac_memory.gd):
##   0x000000-0x03e6ff  the overlay at its own base 0 (the strict overlay port addresses its data
##                      by file offset); the Mac's low-memory globals (0x100..0x2800) share the
##                      start of that range, which holds overlay code the port never reads.
##   0x080000-0x083fff  CODE 2's own words the port keeps by code offset (the VBL sound handlers'
##                      saved A5).
##   0x0c0000           A5: the application globals below it, the jump table above it.
##   0x0e0000-0x0ff000  the stack (ports that hand frame buffers to callees model A7).
##   0x100000-0x6effff  the application heap (Memory Manager blocks and handles).
##   0x6f0000           the sound buffer (SoundBase); 0x6f8000 the address of the empty VBL task
##                      (the sound hook before the program installs its own).
##   0x700000           the screen: 640 x 480 pixels, one byte each (8-bit indexed).

const MacMemory := preload("res://hellcats/runtime/mac_memory.gd")
const Files := preload("res://strict_port/ui/resource_files.gd")
const OverlayLoader := preload("res://hellcats/runtime/overlay_loader.gd")
const Unexported := preload("res://hellcats/runtime/unexported.gd")
const SegmentLoader := preload("res://hellcats/runtime/segment_loader.gd")
const Toolbox := preload("res://hellcats/toolbox/toolbox.gd")

const A5 := 0x0c0000
const BELOW_A5 := 0x225e         ## the application globals' size (CODE 0 header)
const STACK_TOP := 0x0ff000
const STACK_LIMIT := 0x0e0000
const HEAP_START := 0x100000
const HEAP_END := 0x6f0000
const SOUND_BASE := 0x6f0000
const NULL_VBL := 0x6f8000
const CODE2_BASE := 0x080000
const SCREEN_BASE := 0x700000
const SCREEN_WIDTH := 640
const SCREEN_HEIGHT := 480
const MENU_BAR_HEIGHT := 20

## Low-memory globals the code reads.
const LM_TICKS := 0x16a
const LM_SOUND_HOOK := 0x196
const LM_SOUND_BASE := 0x266
const LM_CURRENT_A5 := 0x904
const LM_MBAR_HEIGHT := 0xbaa
const LM_SCREEN_BASE := 0x824
const LM_CUR_STACK_BASE := 0x908

var memory
var toolbox
var segments
var overlay_loader
var unexported
## What the runtime met that is not there yet (missing traps, slots, code addresses), by key.
var missing: Dictionary = {}
## Set once the program calls ExitToShell.
var exited := false
## Set by the scene when Godot quits: the program's thread stops at its next trap and stays parked
## (`parked`), so no script runs on it while the engine shuts down.
var halting := false
## The Mac cursor's level (HideCursor / ShowCursor / InitCursor): shown at 0, hidden below.
var cursor_level: int = 0
var parked := false
var _park := Semaphore.new()
var log_lines: Array = []

## The program's thread waits here for good (nothing posts the semaphore).
func park() -> void:
	parked = true
	_park.wait()

## The toolbox's waits (for an event, a mouse release): parked instead once the machine is halting.
func idle(msec: int) -> void:
	if halting:
		park()
	OS.delay_msec(msec)

func _init() -> void:
	memory = MacMemory.new()
	toolbox = Toolbox.new(self)
	segments = SegmentLoader.new(self)
	toolbox.install_glue(segments.stand_ins)
	overlay_loader = OverlayLoader.new(self)
	unexported = Unexported.new(self)
	segments.register_address(NULL_VBL, func(_a: Array) -> int: return 0)
	low_memory()
	init_a5_world()

## The low-memory globals the code reads (written again after the overlay image covers them).
func low_memory() -> void:
	memory.write_u32(LM_CUR_STACK_BASE, A5 - BELOW_A5)
	memory.write_u32(LM_CURRENT_A5, A5)
	memory.write_u32(LM_SOUND_BASE, SOUND_BASE)
	memory.write_u32(LM_SOUND_HOOK, toolbox.sounds.hook() if toolbox.sounds.hook() != 0 else NULL_VBL)
	memory.write_u16(LM_MBAR_HEIGHT, MENU_BAR_HEIGHT)
	memory.write_u32(LM_SCREEN_BASE, SCREEN_BASE)

## The application globals as the C runtime's start-up (CODE 1 0x34) builds them: from CurStackBase
## up to A5, the words of DATA 0, each zero word followed by as many more zero bytes as the next
## word of ZERO 0 says; then every long at A5 + a word of DREL 0 gets A5 added.
func init_a5_world() -> void:
	var data: PackedByteArray = Files.load_bytes("DATA", 0)
	var zero: PackedByteArray = Files.load_bytes("ZERO", 0)
	var at: int = A5 - BELOW_A5
	var d: int = 0
	var z: int = 0
	while at != A5:
		var w: int = Files.u16(data, d)
		d += 2
		memory.write_u16(at, w)
		at += 2
		if w == 0:
			var n: int = Files.u16(zero, z)
			z += 2
			for k in n:
				memory.write_u8(at + k, 0)
			at += n
	var drel: PackedByteArray = Files.load_bytes("DREL", 0)
	for k in range(0, drel.size(), 2):
		var cell: int = A5 + Files.s16(drel, k)
		memory.write_u32(cell, (memory.read_u32(cell) + A5) & 0xffffffff)

## Records something the game reached that the runtime does not provide yet (once per key).
func note_missing(key: String, detail: String = "") -> void:
	if not missing.has(key):
		missing[key] = detail
		log_line("missing: %s %s" % [key, detail])

func log_line(text: String) -> void:
	log_lines.append(text)
	print("[hellcats] ", text)

## The 60 Hz tick count (low memory Ticks), from the host clock.
func ticks() -> int:
	return int(Time.get_ticks_msec() * 60 / 1000) & 0xffffffff

func screen_bytes() -> PackedByteArray:
	return memory._bytes.slice(SCREEN_BASE, SCREEN_BASE + SCREEN_WIDTH * SCREEN_HEIGHT)

## The stack pointer a routine called from outside the ports gets: below every port's frame.
func free_stack() -> int:
	var lowest: int = STACK_TOP
	for port in segments.all_ports():
		var a7: int = int(port.a7) if segments.has_stack_pointer(port) else 0
		if a7 > STACK_LIMIT and a7 < lowest:
			lowest = a7
	var free: int = lowest - segments.CALL_FRAME
	if free < STACK_LIMIT:
		note_missing("stack", "the ports' frames ran below the stack area")
		free = STACK_TOP - segments.CALL_FRAME
	return free
