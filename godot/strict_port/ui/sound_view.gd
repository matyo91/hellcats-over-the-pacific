@tool
extends "res://strict_port/ui/resource_canvas.gd"

## A 'snd ' shown from the resource's own bytes: its header fields and its waveform (one column per
## run of samples, the minimum and maximum around the 0x80 silence line, the loop span shaded), and
## played when the scene runs, as ResEdit's "Try Sound" plays it: the samples themselves at the
## header's rate (resource_sound.gd), not the MP3 derived next to the resource.

const Files := preload("res://strict_port/ui/resource_files.gd")
const Sound := preload("res://strict_port/ui/resource_sound.gd")

const WIDTH := 600
const WAVE_HEIGHT := 128

var decoded: Dictionary = {}
var player: AudioStreamPlayer

func _ready() -> void:
	super._ready()
	if not Engine.is_editor_hint() and not decoded.is_empty():
		player = AudioStreamPlayer.new()
		player.stream = Sound.stream(decoded)
		add_child(player)
		player.play()

func build_display_list() -> Array:
	var out: Array = []
	decoded = {}
	if not Files.exists("snds", resource_id):
		return out
	decoded = Sound.decode_snd(Files.load_bytes("snds", resource_id))
	var y: int = 12
	for line in ["'snd ' %d   format %d   synthesizer %d   init 0x%08X" % [resource_id, decoded["format"], decoded["synth"], decoded["init"]],
			"%d samples   %.2f Hz (0x%08X)   %.3f s   encoding %d   base note %d" % [decoded["length"], decoded["rate_hz"],
					decoded["rate_fixed"], decoded["length"] / decoded["rate_hz"], decoded["encoding"], decoded["base_note"]],
			"loop %d..%d   commands %s" % [decoded["loop_start"], decoded["loop_end"],
					", ".join(decoded["commands"].map(func(c): return "0x%04X(%d, %d)" % [c["command"], c["param1"], c["param2"]]))]]:
		out.append({"op": "text", "pos": Vector2i(12, y + 12), "text": line})
		y += LINE_HEIGHT
	var wave := Rect2i(12, y + 8, WIDTH - 24, WAVE_HEIGHT)
	var n: int = decoded["length"]
	if decoded["loop_end"] > decoded["loop_start"] and n > 0:
		var a: int = wave.position.x + decoded["loop_start"] * wave.size.x / n
		var b: int = wave.position.x + mini(decoded["loop_end"], n) * wave.size.x / n
		out.append({"op": "fill", "rect": Rect2i(a, wave.position.y, maxi(b - a, 1), wave.size.y), "color": Color(0.85, 0.85, 0.85)})
	out.append({"op": "line", "from": Vector2i(wave.position.x, wave.position.y + WAVE_HEIGHT / 2), "to": Vector2i(wave.end.x - 1, wave.position.y + WAVE_HEIGHT / 2), "color": Color(0.6, 0.6, 0.6)})
	for x in wave.size.x:
		var from: int = x * n / wave.size.x
		var to: int = maxi(from + 1, (x + 1) * n / wave.size.x)
		var lo: int = 255
		var hi: int = 0
		for k in range(from, mini(to, n)):
			lo = mini(lo, decoded["samples"][k])
			hi = maxi(hi, decoded["samples"][k])
		if hi >= lo:
			out.append({"op": "line", "from": Vector2i(wave.position.x + x, wave.end.y - 1 - hi * (WAVE_HEIGHT - 1) / 255),
					"to": Vector2i(wave.position.x + x, wave.end.y - 1 - lo * (WAVE_HEIGHT - 1) / 255)})
	out.append({"op": "frame", "rect": wave.grow(1), "width": 1})
	custom_minimum_size = Vector2i(WIDTH, wave.end.y + 16)
	size = custom_minimum_size
	out.push_front({"op": "frame", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "width": 1})
	out.push_front({"op": "fill", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "color": Color.WHITE})
	return out
