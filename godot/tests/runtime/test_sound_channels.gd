extends RefCounted

const Assertions := preload("res://tests/helpers/assertions.gd")
const MacMachine := preload("res://runtime/machine/mac_machine.gd")

## The Sound Manager's channels: SndPlay ($A805) plays a 'snd ' on its channel, SndDisposeChannel
## ($A801) with quietNow cuts that channel's sounds short (the summary's named sound when the
## summary closes, ID04 0x3178) and leaves the others; without quietNow they play out.
func run() -> bool:
	var machine = MacMachine.new()
	var traps: Dictionary = machine.toolbox.traps
	var sounds = machine.toolbox.sounds
	var snd: int = machine.toolbox.resources.get_resource("snd ", 13493)
	var ok := Assertions.assert_true(snd != 0, "snd 13493 is loaded")
	var a: int = 0x2C000
	var b: int = 0x2C400
	traps[0xa805].call([1, snd, a])
	traps[0xa805].call([1, snd, b])
	var played: Array = sounds.take_played()
	ok = Assertions.assert_equal(played.map(func(p): return p[1]), [a, b], "each sound keeps its channel") and ok
	traps[0xa801].call([1, a])
	traps[0xa801].call([0, b])
	ok = Assertions.assert_equal(sounds.take_stopped(), [a], "only the quietly disposed channel stops") and ok
	traps[0xa805].call([1, snd, a])
	traps[0xa801].call([1, a])
	ok = Assertions.assert_equal(sounds.take_played(), [], "a sound not yet started is dropped by a quiet dispose") and ok
	ok = Assertions.assert_equal(sounds.take_stopped(), [a], "and its channel is reported stopped") and ok
	return ok
