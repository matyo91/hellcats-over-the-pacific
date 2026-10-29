@tool
extends "res://strict_port/ui/resource_canvas.gd"

## The string, text and information resources shown as ResEdit's editors show them, from their own
## bytes: a 'STR#' as its numbered strings, a 'TEXT' as its text in the style of the 'styl' with the
## same ID (wrapped to the window, lines broken at CR) or, when it holds binary words, in hex; a
## 'styl' as its style runs; 'vers' and 'SIZE' as their fields; the application's own data types
## (DATA, DREL, HEL1, HELL, MDPL, ZERO), which ResEdit has no template for, in its hex layout. Font ID 3 is Geneva, which the
## resource fork does not hold either: the stand-in face draws it at the run's size.

const Files := preload("res://strict_port/ui/resource_files.gd")
const Text := preload("res://strict_port/ui/resource_text.gd")

const WIDTH := 560
const MARGIN := 12

## What was decoded (the tests read it).
var decoded: Variant = null

func build_display_list() -> Array:
	var out: Array = []
	decoded = null
	if not Files.exists(resource_type, resource_id):
		return out
	var bytes: PackedByteArray = Files.load_bytes(resource_type, resource_id)
	var y: int = MARGIN
	match resource_type:
		"STR#":
			decoded = Text.decode_strlist(bytes)
			for k in decoded.size():
				var lines: Array = wrap_lines(decoded[k], WIDTH - 80)
				var box := Rect2i(56, y, WIDTH - 68, lines.size() * LINE_HEIGHT + 6)
				out.append({"op": "text", "pos": Vector2i(MARGIN, y + 15), "text": "%d)" % (k + 1)})
				out.append({"op": "frame", "rect": box, "width": 1})
				for i in lines.size():
					out.append({"op": "text", "pos": Vector2i(box.position.x + 4, y + 15 + i * LINE_HEIGHT), "text": lines[i]})
				y = box.end.y + 8
		"TEXT":
			if Text.is_text(bytes):
				decoded = Text.decode_text(bytes)
				var size_px: int = FONT_SIZE
				var line_height: int = LINE_HEIGHT
				var ascent: int = ASCENT
				if Files.exists("styl", resource_id):
					var run: Dictionary = Text.decode_styl(Files.load_bytes("styl", resource_id))[0]
					size_px = run["size"]
					line_height = run["line_height"]
					ascent = run["ascent"]
				for line in wrap_lines(decoded, WIDTH - 2 * MARGIN, size_px):
					out.append({"op": "text", "pos": Vector2i(MARGIN, y + ascent), "text": line, "size": size_px})
					y += line_height
			else:
				decoded = bytes
				y = hex_dump(out, bytes, y)
		"styl":
			decoded = Text.decode_styl(bytes)
			out.append({"op": "text", "pos": Vector2i(MARGIN, y + 12), "text": "Start  Height  Ascent  Font  Face  Size  Color"})
			y += 22
			for run in decoded:
				out.append({"op": "text", "pos": Vector2i(MARGIN, y + 12), "text": "%5d  %6d  %6d  %4d  %4d  %4d  %04X %04X %04X" % [
						run["start"], run["line_height"], run["ascent"], run["font_id"], run["face"], run["size"],
						run["rgb16"][0], run["rgb16"][1], run["rgb16"][2]]})
				y += LINE_HEIGHT
		"vers":
			decoded = Text.decode_vers(bytes)
			for field in [["Version number", "%d.%d.%d" % [decoded["major"], decoded["minor"], decoded["bugfix"]]],
					["Release", decoded["stage"].capitalize()], ["Non-release", str(decoded["non_release"])],
					["Country Code", "%02d" % decoded["region"]], ["Short version string", decoded["short"]]]:
				y = _field(out, field[0], field[1], y)
			out.append({"op": "text", "pos": Vector2i(MARGIN, y + 12), "text": "Long version string:"})
			y += 20
			for line in wrap_lines(decoded["long"], WIDTH - 2 * MARGIN):
				out.append({"op": "text", "pos": Vector2i(MARGIN + 16, y + 12), "text": line})
				y += LINE_HEIGHT
		"DATA", "DREL", "HEL1", "HELL", "MDPL", "ZERO":
			decoded = bytes
			y = hex_dump(out, bytes, y)
		"SIZE":
			decoded = Text.decode_size(bytes)
			for k in 16:
				var on: bool = (decoded["flags"] >> (15 - k)) & 1 == 1
				var box := Rect2i(MARGIN, y + 2, 12, 12)
				out.append({"op": "frame", "rect": box, "width": 1})
				if on:
					out.append({"op": "line", "from": box.position, "to": box.end - Vector2i(1, 1)})
					out.append({"op": "line", "from": Vector2i(box.end.x - 1, box.position.y), "to": Vector2i(box.position.x, box.end.y - 1)})
				out.append({"op": "text", "pos": Vector2i(MARGIN + 20, y + 12), "text": Text.SIZE_FLAGS[k]})
				y += 18
			y = _field(out, "Size", str(decoded["preferred"]), y + 8)
			y = _field(out, "Min size", str(decoded["minimum"]), y)
	custom_minimum_size = Vector2i(WIDTH, y + MARGIN)
	size = custom_minimum_size
	out.push_front({"op": "frame", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "width": 1})
	out.push_front({"op": "fill", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "color": Color.WHITE})
	return out

func _field(out: Array, label: String, value: String, y: int) -> int:
	out.append({"op": "text", "pos": Vector2i(MARGIN, y + 13), "text": label + ":"})
	var box := Rect2i(180, y, WIDTH - 192, 18)
	out.append({"op": "frame", "rect": box, "width": 1})
	out.append({"op": "text", "pos": Vector2i(box.position.x + 4, y + 13), "text": value})
	return y + 24
