@tool
extends Control

## The canvas the resource views share: a resource (folder name and ID, as in
## godot/strict_port/<TYPE>/<id>.bin) is turned by build_display_list() into QuickDraw-like
## primitives in this control's pixels (also what the tests read), drawn in black on white. The
## system font (Chicago 12) is not in the resource fork; the nearest installed face stands in for it.

const FONT_SIZE := 12
const ASCENT := 12
const LINE_HEIGHT := 16

@export var resource_type: String = "":
	set(value):
		resource_type = value
		_rebuild()
@export var resource_id: int = 0:
	set(value):
		resource_id = value
		_rebuild()

var display_list: Array = []
var _font: Font
var _gray: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rebuild()

func _rebuild() -> void:
	display_list = build_display_list()
	queue_redraw()

## Overridden by each view.
func build_display_list() -> Array:
	return []

func font() -> Font:
	if _font == null:
		var system := SystemFont.new()
		system.font_names = PackedStringArray(["Chicago", "Charcoal", "Geneva", "Lucida Grande", "Helvetica"])
		system.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		system.hinting = TextServer.HINTING_NORMAL
		_font = system
	return _font

func text_width(text: String, font_size: int = FONT_SIZE) -> int:
	return int(font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)

## Text broken into lines at CR and wrapped at word boundaries to `width` pixels.
func wrap_lines(text: String, width: int, font_size: int = FONT_SIZE) -> Array:
	var lines: Array = []
	for paragraph in text.split("\r"):
		var words: PackedStringArray = paragraph.split(" ")
		var line: String = words[0]
		for k in range(1, words.size()):
			var trial: String = line + " " + words[k]
			if line.strip_edges() != "" and text_width(trial, font_size) > width:
				lines.append(line)
				line = words[k]
			else:
				line = trial
		lines.append(line)
	return lines

## A resource's bytes as ResEdit's hex editor lays them out: the offset, eight bytes as four words,
## then the same bytes as characters (Mac OS Roman, control bytes as dots), from `top`.
func hex_dump(out: Array, bytes: PackedByteArray, top: int) -> int:
	var y: int = top
	for row in range(0, bytes.size(), 8):
		var hex := ""
		var chars := ""
		for k in 8:
			if row + k < bytes.size():
				var c: int = bytes[row + k]
				hex += "%02X" % c + (" " if k & 1 else "")
				chars += "." if c < 0x20 else String.chr(c if c < 0x80 else preload("res://strict_port/ui/resource_files.gd").MAC_ROMAN_HIGH[c - 0x80])
			else:
				hex += "  " + (" " if k & 1 else "")
		out.append({"op": "text", "pos": Vector2i(12, y + 12), "text": "%06X" % row})
		out.append({"op": "text", "pos": Vector2i(80, y + 12), "text": hex})
		out.append({"op": "text", "pos": Vector2i(300, y + 12), "text": chars})
		y += LINE_HEIGHT
	return y

func _gray_pattern() -> Texture2D:
	if _gray == null:
		var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
		image.set_pixel(0, 0, Color.BLACK)
		image.set_pixel(1, 1, Color.BLACK)
		image.set_pixel(1, 0, Color.WHITE)
		image.set_pixel(0, 1, Color.WHITE)
		_gray = ImageTexture.create_from_image(image)
	return _gray

func _draw() -> void:
	for op in display_list:
		match op["op"]:
			"pattern":
				draw_texture_rect(_gray_pattern(), Rect2(op["rect"]), true)
			"fill":
				draw_rect(Rect2(op["rect"]), op["color"])
			"frame":
				var r := Rect2(op["rect"])
				var w: float = op["width"]
				draw_rect(r.grow(-w / 2.0), Color.BLACK, false, w)
			"round":
				_round_rect(Rect2(op["rect"]), op["radius"], op["width"])
			"oval":
				draw_arc(Rect2(op["rect"]).get_center(), Rect2(op["rect"]).size.x / 2.0 - 0.5, 0.0, TAU, 24, Color.BLACK, 1.0)
			"text":
				draw_string(font(), Vector2(op["pos"]), op["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, op.get("size", FONT_SIZE),
						op.get("color", Color.BLACK))
			"poly":
				var points := PackedVector2Array()
				for q in op["points"]:
					points.append(Vector2(q) + Vector2(0.5, 0.5))
				points.append(points[0])
				draw_polyline(points, Color.BLACK, 1.0)
			"line":
				draw_line(Vector2(op["from"]) + Vector2(0.5, 0.5), Vector2(op["to"]) + Vector2(0.5, 0.5), op.get("color", Color.BLACK), 1.0)
			"texture":
				draw_texture_rect_region(op["texture"], Rect2(op["rect"]), op.get("region", Rect2(Vector2.ZERO, (op["texture"] as Texture2D).get_size())))

func _round_rect(r: Rect2, radius: float, width: float) -> void:
	var inset: float = width / 2.0
	var rr := r.grow(-inset)
	var rad: float = radius - inset
	draw_line(rr.position + Vector2(rad, 0), Vector2(rr.end.x - rad, rr.position.y), Color.BLACK, width)
	draw_line(Vector2(rr.position.x + rad, rr.end.y), rr.end - Vector2(rad, 0), Color.BLACK, width)
	draw_line(rr.position + Vector2(0, rad), Vector2(rr.position.x, rr.end.y - rad), Color.BLACK, width)
	draw_line(Vector2(rr.end.x, rr.position.y + rad), rr.end - Vector2(0, rad), Color.BLACK, width)
	draw_arc(rr.position + Vector2(rad, rad), rad, PI, PI * 1.5, 8, Color.BLACK, width)
	draw_arc(Vector2(rr.end.x - rad, rr.position.y + rad), rad, PI * 1.5, TAU, 8, Color.BLACK, width)
	draw_arc(rr.end - Vector2(rad, rad), rad, 0.0, PI * 0.5, 8, Color.BLACK, width)
	draw_arc(Vector2(rr.position.x + rad, rr.end.y - rad), rad, PI * 0.5, PI, 8, Color.BLACK, width)
