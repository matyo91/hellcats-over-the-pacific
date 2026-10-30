extends RefCounted

## Runs the original program on its own thread: the strict port's main (ID02 0x309a) never returns
## and polls for events as the Mac version does, so it cannot share Godot's main loop. The thread
## owns the machine's memory while it runs; the main thread only reads the screen bytes from it and
## hands input over through the machine's event queue.

var machine
var thread: Thread
var finished := false
var error := ""

func _init(owner) -> void:
	machine = owner

func start() -> void:
	thread = Thread.new()
	thread.start(_run)

func _run() -> void:
	var program = machine.segments.instances[2]
	program.a7 = machine.STACK_TOP
	program.main()
	finished = true

func is_running() -> bool:
	return thread != null and thread.is_alive()
