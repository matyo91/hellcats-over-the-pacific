class_name MacSpeaker
extends AudioStreamPlayer

## The Macintosh's speaker: the sound buffer's samples the program mixes every tick (the Sound
## Manager's queue, toolbox/sound_manager.gd) through a generator at the buffer's 22254.5 Hz, and
## each sound SndPlay starts on a player of its own, stopped when its channel is disposed quietly.

var machine
var _playback: AudioStreamGeneratorPlayback

func attach(owner) -> void:
	machine = owner
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = machine.toolbox.sounds.RATE
	generator.buffer_length = 0.25
	stream = generator
	play()
	_playback = get_stream_playback()

func _process(_delta: float) -> void:
	if machine == null:
		return
	var sounds = machine.toolbox.sounds
	var samples: PackedFloat32Array = sounds.take()
	var room: int = _playback.get_frames_available()
	for k in mini(samples.size(), room):
		_playback.push_frame(Vector2(samples[k], samples[k]))
	for played in sounds.take_played():
		var player := AudioStreamPlayer.new()
		player.stream = played[0]
		player.set_meta("channel", played[1])
		player.finished.connect(player.queue_free)
		add_child(player)
		player.play()
	for channel in sounds.take_stopped():
		for player in get_children():
			if player.get_meta("channel", -1) == channel:
				player.stop()
				player.queue_free()
