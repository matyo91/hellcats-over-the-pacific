extends RefCounted

## A 'snd ' resource (folder snds) decoded from its bytes as the Sound Manager reads a format 1
## sampled sound: the modifier list (synthesizer and init options), the command list (the
## bufferCmd / soundCmd whose param2 is the sound header's offset), then the header: sample
## pointer (0: the samples follow), length, rate (16.16 fixed), loop start and end, encoding
## (0: uncompressed 8-bit offset binary), base MIDI note, and the samples.

const Files := preload("res://strict_port/ui/resource_files.gd")

static func decode_snd(b: PackedByteArray) -> Dictionary:
	assert(Files.u16(b, 0) == 1, "only format 1 sounds are in the file")
	var modifiers: int = Files.u16(b, 2)
	var at: int = 4 + 6 * modifiers
	var commands: Array = []
	var header: int = -1
	for k in Files.u16(b, at):
		var o: int = at + 2 + 8 * k
		var cmd: int = Files.u16(b, o)
		commands.append({"command": cmd, "param1": Files.u16(b, o + 2), "param2": Files.u32(b, o + 4)})
		if (cmd & 0x7fff) == 80 or (cmd & 0x7fff) == 81:
			header = Files.u32(b, o + 4)
	var length: int = Files.u32(b, header + 4)
	var rate: int = Files.u32(b, header + 8)
	return {"format": 1, "modifiers": modifiers, "synth": Files.u16(b, 4) if modifiers > 0 else -1,
			"init": Files.u32(b, 6) if modifiers > 0 else -1, "commands": commands, "header": header,
			"sample_pointer": Files.u32(b, header), "length": length, "rate_fixed": rate, "rate_hz": rate / 65536.0,
			"loop_start": Files.u32(b, header + 12), "loop_end": Files.u32(b, header + 16), "encoding": b[header + 20],
			"base_note": b[header + 21], "samples": b.slice(header + 22, header + 22 + length)}

## The samples as Godot plays them: offset binary (0x80 silence) made signed, at the header's rate
## rounded to the hertz (Godot's mix rate is a whole number: 11127.27 Hz plays at 11127).
static func stream(decoded: Dictionary) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(decoded["length"])
	for k in decoded["length"]:
		data[k] = (decoded["samples"][k] - 0x80) & 0xff
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = roundi(decoded["rate_hz"])
	wav.stereo = false
	wav.data = data
	return wav
