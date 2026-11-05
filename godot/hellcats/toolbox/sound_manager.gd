extends RefCounted

## The sound the program makes, two ways, as on the Macs of its time:
## - the sound buffer: every tick (the vertical blank) the sound hook (low memory SoundHook) runs,
##   the program's handlers mixing its channels into the 370 sample bytes at SoundBase (one byte per
##   word); `service()` runs the hook for the ticks gone by, on the program's thread at its traps,
##   and queues the buffer's samples for Godot (`take()`, 22254.5 Hz, unsigned 8-bit);
## - the Sound Manager: SndNewChannel gives a channel record, SndPlay plays a 'snd ' handle (decoded
##   by strict_port/ui/resource_sound.gd) as a Godot stream on that channel (`take_played()`), and
##   SndDisposeChannel with quietNow set cuts the channel's sounds short (`take_stopped()`), as the
##   summary's named sound is when the summary closes (ID04 0x3178); the others answer noErr.

const Sounds := preload("res://strict_port/ui/resource_sound.gd")

const RATE := 22254.5
const FRAME := 370
const QUEUE_LIMIT := 4 * 370 * 6          ## about a tenth of a second kept at most

var machine
var memory
var heap
var _tick: int = -1
## The last handler the hook held: it keeps running while the overlay's image covers low memory
## (from its read until the loader puts the globals back), as the real Mac's SoundHook is untouched.
var _hook: int = 0
var _in_vbl := false
var _lock := Mutex.new()
var _queue := PackedFloat32Array()
var _played: Array = []                    ## [AudioStreamWAV, channel] the Sound Manager started
var _stopped: Array = []                   ## channels disposed with quietNow set

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
	t.install(0xa801, func(a: Array) -> int: return dispose(a[1], a[0]))                      ## SndDisposeChannel(chan, quietNow)
	t.install(0xa805, func(a: Array) -> int: return play(a[1], a[2]))                         ## SndPlay(chan, snd, async)
	for word in [0xa802, 0xa803, 0xa804, 0xa806]:                                              ## SndAddModifier, SndDoCommand, SndDoImmediate, SndControl
		t.install(word, func(_a: Array) -> int: return 0)

## Runs the sound hook once per tick since the last call (four at most), each frame's samples queued.
func service() -> void:
	var now: int = machine.ticks()
	if now == _tick or _in_vbl:
		return
	var count: int = 1 if _tick < 0 else clampi(now - _tick, 1, 4)
	_tick = now
	var address: int = memory.read_u32(machine.LM_SOUND_HOOK)
	if address == machine.NULL_VBL:
		return                                           # the program's own choice: no handler
	if address == 0 or not machine.segments.is_routine(address):
		address = _hook                                  # image bytes over SoundHook
	else:
		_hook = address
	if address == 0:
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

func play(snd: int, channel: int = 0) -> int:
	var p: int = memory.read_u32(snd)
	var bytes := PackedByteArray()
	bytes.resize(heap.handle_size(snd))
	for k in bytes.size():
		bytes[k] = memory.read_u8(p + k)
	var decoded: Dictionary = Sounds.decode_snd(bytes)
	_lock.lock()
	_played.append([Sounds.stream(decoded), channel & 0xffffffff])
	_lock.unlock()
	return 0

## SndDisposeChannel: with quietNow set (the ports pass the Boolean as 1), the sounds playing on
## the channel stop now, and any not yet started are dropped; otherwise they play out.
func dispose(channel: int, quiet_now: int) -> int:
	if quiet_now & 0xffff != 0:
		_lock.lock()
		_played = _played.filter(func(p: Array) -> bool: return p[1] != (channel & 0xffffffff))
		_stopped.append(channel & 0xffffffff)
		_lock.unlock()
	return 0

func take_stopped() -> Array:
	_lock.lock()
	var out: Array = _stopped
	_stopped = []
	_lock.unlock()
	return out

## [stream, channel] for each sound started since the last call.
func take_played() -> Array:
	_lock.lock()
	var out: Array = _played
	_played = []
	_lock.unlock()
	return out
