@tool
extends "res://strict_port/ui/resource_canvas.gd"

## A dialog resource drawn the way the Dialog Manager (and ResEdit's editors) show it, from the
## resource's own bytes: an 'ALRT' or 'DLOG' as its window at its global position on a 640 x 480
## screen, a bare 'DITL' in a plain box. The look follows the System 7 black-and-white
## definitions: the window frame of its procID, push buttons as 16 x 16 round rects with centred
## titles, check boxes and radio buttons with a 12-pixel mark before the title, static text
## wrapped like TextBox (lines broken on CR), edit text framed 3 pixels out, icons and pictures
## scaled into their rects, the alert's default button outlined (stage 1's bit 2). User items are
## shown as ResEdit shows them in its editor: a grey box. The system font (Chicago 12) is not in the
## resource fork; the nearest installed face stands in for it.

const Files := preload("res://strict_port/ui/resource_files.gd")
const Templates := preload("res://strict_port/ui/dialog_templates.gd")

const SCREEN := Vector2i(640, 480)
const DITL_ORIGIN := Vector2i(16, 16)

## The decoded template ({} for a bare DITL) and the item list.
var template: Dictionary = {}
var items: Dictionary = {}

## The drawing as a list of primitives (also what the tests read): rects in this control's pixels.
func build_display_list() -> Array:
	var out: Array = []
	template = {}
	items = {}
	var ditl_id: int = resource_id
	var content := Rect2i()
	var proc_id: int = 2
	var title := ""
	if resource_type == "ALRT" or resource_type == "DLOG":
		var bytes: PackedByteArray = Files.load_bytes(resource_type, resource_id)
		if bytes.is_empty():
			return out
		template = Templates.decode_alrt(bytes) if resource_type == "ALRT" else Templates.decode_dlog(bytes)
		ditl_id = template["ditl_id"]
		content = template["bounds"]
		proc_id = 1 if resource_type == "ALRT" else template["proc_id"]
		title = template.get("title", "")
		custom_minimum_size = SCREEN
		out.append({"op": "pattern", "rect": Rect2i(Vector2i.ZERO, SCREEN)})
	var ditl_bytes: PackedByteArray = Files.load_bytes("DITL", ditl_id)
	if not ditl_bytes.is_empty():
		items = Templates.decode_ditl(ditl_bytes)
	if resource_type == "DITL":
		var extent := Vector2i(64, 32)
		for item in items.get("items", []):
			var r: Rect2i = item["bounds"]
			extent = Vector2i(maxi(extent.x, r.end.x + 10), maxi(extent.y, r.end.y + 10))
		content = Rect2i(DITL_ORIGIN, extent)
		custom_minimum_size = content.end + DITL_ORIGIN
	_window_frame(out, content, proc_id, title)
	var origin: Vector2i = content.position
	for item in items.get("items", []):
		var drawn: Array = []
		_item(drawn, item, origin)
		out.append_array(_clip_to(drawn, content))
	if resource_type == "ALRT":
		var stage1: int = template["stages"][0]
		var bold: int = 2 if (stage1 & 8) != 0 else 1
		if (stage1 & 4) != 0 and items.get("items", []).size() >= bold:
			var button: Dictionary = items["items"][bold - 1]
			if button["type"] == Templates.BUTTON:
				var r: Rect2i = button["bounds"]
				out.append({"op": "round", "rect": Rect2i(r.position + origin, r.size).grow(4), "radius": 8, "width": 3})
	size = custom_minimum_size
	return out

## The window frame of a WDEF 0 procID around `content`: 1 the modal dialog box (an outer line, a
## white line, a 2-pixel line, then 4 white pixels to the content), 2 a plain box, 3 a box with a
## 2-pixel shadow, 0 / 4 / 8 / 16 a document window with its 18-pixel striped title bar.
func _window_frame(out: Array, content: Rect2i, proc_id: int, title: String) -> void:
	match proc_id:
		1:
			out.append({"op": "fill", "rect": content.grow(8), "color": Color.WHITE})
			out.append({"op": "frame", "rect": content.grow(8), "width": 1})
			out.append({"op": "frame", "rect": content.grow(6), "width": 2})
		2:
			out.append({"op": "fill", "rect": content.grow(1), "color": Color.WHITE})
			out.append({"op": "frame", "rect": content.grow(1), "width": 1})
		3:
			out.append({"op": "fill", "rect": Rect2i(content.position + Vector2i(1, 1), content.size + Vector2i(2, 2)), "color": Color.BLACK})
			out.append({"op": "fill", "rect": content.grow(1), "color": Color.WHITE})
			out.append({"op": "frame", "rect": content.grow(1), "width": 1})
		_:
			var bar := Rect2i(content.position.x - 1, content.position.y - 19, content.size.x + 2, 19)
			out.append({"op": "fill", "rect": Rect2i(content.position + Vector2i(1, 1), content.size + Vector2i(1, 1)), "color": Color.BLACK})
			out.append({"op": "fill", "rect": content.grow(1), "color": Color.WHITE})
			out.append({"op": "frame", "rect": content.grow(1), "width": 1})
			out.append({"op": "fill", "rect": bar, "color": Color.WHITE})
			out.append({"op": "frame", "rect": bar, "width": 1})
			for k in 6:
				out.append({"op": "fill", "rect": Rect2i(bar.position.x + 2, bar.position.y + 4 + 2 * k, bar.size.x - 4, 1), "color": Color.BLACK})
			if title != "":
				var w: int = int(font().get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x)
				var tx: int = bar.position.x + (bar.size.x - w) / 2
				out.append({"op": "fill", "rect": Rect2i(tx - 6, bar.position.y + 1, w + 12, 17), "color": Color.WHITE})
				out.append({"op": "text", "pos": Vector2i(tx, bar.position.y + 14), "text": title})

func _item(out: Array, item: Dictionary, origin: Vector2i) -> void:
	var r := Rect2i((item["bounds"] as Rect2i).position + origin, (item["bounds"] as Rect2i).size)
	var text: String = item.get("text", "")
	match item["type"]:
		Templates.BUTTON:
			out.append({"op": "fill", "rect": r, "color": Color.WHITE})
			out.append({"op": "round", "rect": r, "radius": 8, "width": 1})
			var w: int = int(font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x)
			out.append({"op": "text", "pos": Vector2i(r.position.x + (r.size.x - w) / 2, r.position.y + (r.size.y - 16) / 2 + ASCENT + 1),
					"text": text})
		Templates.CHECKBOX, Templates.RADIO_BUTTON:
			var box := Rect2i(r.position.x + 2, r.position.y + (r.size.y - 12) / 2, 12, 12)
			out.append({"op": "fill", "rect": box, "color": Color.WHITE})
			out.append({"op": "oval" if item["type"] == Templates.RADIO_BUTTON else "frame", "rect": box, "width": 1})
			out.append({"op": "text", "pos": Vector2i(r.position.x + 17, r.position.y + (r.size.y - 16) / 2 + ASCENT + 1), "text": text})
		Templates.STATIC_TEXT:
			_text_box(out, text, r)
		Templates.EDIT_TEXT:
			out.append({"op": "frame", "rect": r.grow(3), "width": 1})
			_text_box(out, text, r)
		Templates.ICON_ITEM:
			var icon: PackedByteArray = Files.load_bytes("ICON", item.get("resource_id", 0))
			if icon.size() >= 128:
				out.append({"op": "texture", "rect": r, "texture": ImageTexture.create_from_image(Templates.icon_image(icon)),
						"source": "ICON:%d" % item["resource_id"]})
		Templates.PICTURE_ITEM:
			var picture: Texture2D = Files.load_png("PICT", item.get("resource_id", 0))
			if picture != null:
				out.append({"op": "texture", "rect": r, "texture": picture, "source": "PICT:%d" % item["resource_id"]})
		Templates.USER_ITEM:
			out.append({"op": "fill", "rect": r, "color": Color(0.75, 0.75, 0.75)})
		_:
			out.append({"op": "frame", "rect": r, "width": 1})

## The window's port clips its items: fills and pictures cut to the content rect, frames and text
## lines left out when they fall outside it.
func _clip_to(ops: Array, content: Rect2i) -> Array:
	var out: Array = []
	for op in ops:
		match op["op"]:
			"fill":
				var r: Rect2i = (op["rect"] as Rect2i).intersection(content)
				if r.has_area():
					op["rect"] = r
					out.append(op)
			"texture":
				var full: Rect2i = op["rect"]
				var r: Rect2i = full.intersection(content)
				if r.has_area():
					var size: Vector2 = (op["texture"] as Texture2D).get_size()
					var scale := Vector2(size.x / full.size.x, size.y / full.size.y)
					op["region"] = Rect2(Vector2(r.position - full.position) * scale, Vector2(r.size) * scale)
					op["rect"] = r
					out.append(op)
			"text":
				if content.has_point(op["pos"]):
					out.append(op)
			_:
				if content.grow(4).encloses(op["rect"]):
					out.append(op)
	return out

## TextBox: words wrapped to the rect's width, lines broken at CR, clipped to the rect.
func _text_box(out: Array, text: String, r: Rect2i) -> void:
	var y: int = r.position.y + ASCENT
	for paragraph in text.split("\r"):
		var line := ""
		for word in paragraph.split(" "):
			var trial: String = word if line == "" else line + " " + word
			if line != "" and font().get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x > r.size.x:
				if y <= r.end.y:
					out.append({"op": "text", "pos": Vector2i(r.position.x, y), "text": line, "clip": r})
				y += LINE_HEIGHT
				line = word
			else:
				line = trial
		if y <= r.end.y:
			out.append({"op": "text", "pos": Vector2i(r.position.x, y), "text": line, "clip": r})
		y += LINE_HEIGHT
