extends RefCounted

## The sound the program makes, two ways, as on the Macs of its time:
## - the sound buffer: every tick (the vertical blank) the sound hook (low memory SoundHook) runs,
##   the program's handlers mixing its channels into the 370 sample bytes at SoundBase (one byte per
##   word); `service()` runs the hook for the ticks gone by, on the program's thread at its traps,
##   and queues the buffer's samples for Godot (`take()`, 22254.5 Hz, unsigned 8-bit);
## - the Sound Manager: SndNewChannel gives a channel record, SndPlay plays a 'snd ' handle (decoded
##   by strict_port/ui/resource_sound.gd) as a Godot stream (`take_played()`), SndDisposeChannel
##   and the others answer noErr.

const Sounds := preload("res://strict_port/ui/resource_sound.gd")

const RATE := 22254.5
const FRAME := 370
const QUEUE_LIMIT := 4 * 370 * 6          ## about a tenth of a second kept at most

var machine
var memory
var heap
var _tick: int = -1
var _hook: int = 0
var _in_vbl := false
var _lock := Mutex.new()
var _queue := PackedFloat32Array()
var _played: Array = []                    ## AudioStreamWAV the Sound Manager started

func _init(owner, toolbox) -> void:
	machine = owner
	memory = owner.memory
	heap = toolbox.heap

func install(toolbox) -> void:
	var t = toolbox
	t.install(0xa807, func(a: Array) -> int:                                                  ## SndNewChannel(VAR chan, synth, init, proc)
		if memory.read_u32(a[3]) == 0:
			memory.write_u32(a[3], heap.new_ptr(0x400, true))
		return 0)
	t.install(0xa801, func(_a: Array) -> int: return 0)                                       ## SndDisposeChannel(chan, quietNow)
	t.install(0xa805, func(a: Array) -> int: return play(a[1]))                               ## SndPlay(chan, snd, async)
	for word in [0xa802, 0xa803, 0xa804, 0xa806]:                                              ## SndAddModifier, SndDoCommand, SndDoImmediate, SndControl
		t.install(word, func(_a: Array) -> int: return 0)

## The sound buffer's hook for good: the handler the program installs, kept when the overlay's image
## covers low memory (low_memory() writes it back).
func hook() -> int:
	return _hook

func set_hook(address: int) -> void:
	_hook = address

## Runs the sound hook once per tick since the last call (four at most), each frame's samples queued.
func service() -> void:
	var now: int = machine.ticks()
	if now == _tick or _in_vbl:
		return
	var count: int = 1 if _tick < 0 else clampi(now - _tick, 1, 4)
	_tick = now
	var address: int = memory.read_u32(machine.LM_SOUND_HOOK)
	if address == machine.NULL_VBL or address == 0 or not machine.segments.is_routine(address):
		address = _hook
	else:
		_hook = address
	if address == machine.NULL_VBL or address == 0:
		return
	_in_vbl = true
	var frame := PackedFloat32Array()
	frame.resize(FRAME * count)
	for n in count:
		machine.segments.call_procedure(address, [])
		for k in FRAME:
			frame[n * FRAME + k] = (memory.read_u8(machine.SOUND_BASE + 2 * k) - 0x80) / 128.0
	_in_vbl = false
	_lock.lock()
	_queue.append_array(frame)
	if _queue.size() > QUEUE_LIMIT:
		_queue = _queue.slice(_queue.size() - QUEUE_LIMIT)
	_lock.unlock()

## The samples queued so far (the Godot side plays them).
func take() -> PackedFloat32Array:
	_lock.lock()
	var out: PackedFloat32Array = _queue
	_queue = PackedFloat32Array()
	_lock.unlock()
	return out

func play(snd: int) -> int:
	var p: int = memory.read_u32(snd)
	var bytes := PackedByteArray()
	bytes.resize(heap.handle_size(snd))
	for k in bytes.size():
		bytes[k] = memory.read_u8(p + k)
	var decoded: Dictionary = Sounds.decode_snd(bytes)
	_lock.lock()
	_played.append(Sounds.stream(decoded))
	_lock.unlock()
	return 0

func take_played() -> Array:
	_lock.lock()
	var out: Array = _played
	_played = []
	_lock.unlock()
	return out
