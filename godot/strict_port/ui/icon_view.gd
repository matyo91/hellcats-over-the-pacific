@tool
extends "res://strict_port/ui/resource_canvas.gd"

## An icon or colour resource shown as ResEdit's editors show it, from the resource's own bytes:
## the icon in fat bits (each pixel a square, a light grid between them) with its actual size beside
## it, and for 'ICN#' / 'ics#' the mask in fat bits too; a 'cicn' as its colour pixels, its one-bit
## icon and its mask; a 'clut' as its entries (value, swatch, 16-bit RGB); a 'PICT' at its picture
## frame's size (picSize and picFrame read from its bytes; QuickDraw's opcodes are not replayed:
## the picture is the PNG derived next to it, drawn at its own size from the frame's corner: two of
## them are a few pixels smaller than their frame, PICT 131 135 x 749 for 137 x 751 and PICT 1000
## 425 x 88 for 438 x 93).

const Files := preload("res://strict_port/ui/resource_files.gd")
const Images := preload("res://strict_port/ui/resource_images.gd")

const MARGIN := 16
const FAT_SIZE := 256

## What was decoded (the tests read it).
var decoded: Dictionary = {}

func build_display_list() -> Array:
	var out: Array = []
	decoded = {}
	var bytes: PackedByteArray = Files.load_bytes(resource_type, resource_id)
	if bytes.is_empty():
		return out
	var panels: Array = []
	if Images.ICON_TYPES.has(resource_type):
		decoded = Images.icon(resource_type, bytes)
		panels.append(["Icon", decoded["image"]])
		if decoded.has("mask"):
			panels.append(["Mask", decoded["mask"]])
	elif resource_type == "cicn":
		decoded = Images.cicn(bytes)
		panels.append(["Color", decoded["masked"]])
		var w: int = decoded["bounds"].size.x
		var h: int = decoded["bounds"].size.y
		var one := Image.create(w, h, false, Image.FORMAT_RGBA8)
		var mask := Image.create(w, h, false, Image.FORMAT_RGBA8)
		var bits_at: int = 82 + Files.u16(bytes, 54) * h
		var one_bits: Array = Images.bits(bytes, bits_at, Files.u16(bytes, 68), w, h)
		for y in h:
			for x in w:
				one.set_pixel(x, y, Color.BLACK if one_bits[y][x] else Color.WHITE)
				mask.set_pixel(x, y, Color.BLACK if decoded["mask"][y][x] else Color.WHITE)
		panels.append(["B&W", one])
		panels.append(["Mask", mask])
	elif resource_type == "PICT":
		return _picture(out, bytes)
	elif resource_type == "clut":
		decoded = Images.color_table(bytes, 0)
		return _clut(out)
	var x: int = MARGIN
	var height: int = 0
	for panel in panels:
		var image: Image = panel[1]
		var scale: int = maxi(1, FAT_SIZE / maxi(image.get_width(), image.get_height()))
		var fat := Rect2i(x, MARGIN + 20, image.get_width() * scale, image.get_height() * scale)
		out.append({"op": "text", "pos": Vector2i(x, MARGIN + 12), "text": panel[0]})
		out.append({"op": "texture", "rect": fat, "texture": ImageTexture.create_from_image(image), "source": "%s:%d" % [resource_type, resource_id]})
		if scale >= 4:
			for k in range(1, image.get_width()):
				out.append({"op": "line", "from": Vector2i(fat.position.x + k * scale, fat.position.y),
						"to": Vector2i(fat.position.x + k * scale, fat.end.y - 1), "color": Color(0.8, 0.8, 0.8)})
			for k in range(1, image.get_height()):
				out.append({"op": "line", "from": Vector2i(fat.position.x, fat.position.y + k * scale),
						"to": Vector2i(fat.end.x - 1, fat.position.y + k * scale), "color": Color(0.8, 0.8, 0.8)})
		out.append({"op": "frame", "rect": fat.grow(1), "width": 1})
		var actual := Rect2i(x, fat.end.y + 12, image.get_width(), image.get_height())
		out.append({"op": "texture", "rect": actual, "texture": ImageTexture.create_from_image(image), "source": "%s:%d" % [resource_type, resource_id]})
		x = fat.end.x + MARGIN * 2
		height = maxi(height, actual.end.y)
	custom_minimum_size = Vector2i(x, height + MARGIN)
	size = custom_minimum_size
	out.push_front({"op": "fill", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "color": Color.WHITE})
	return out

func _clut(out: Array) -> Array:
	var y: int = MARGIN
	out.append({"op": "text", "pos": Vector2i(MARGIN, y + 12), "text": "seed %d  flags 0x%04X  %d entries" % [decoded["seed"], decoded["flags"], decoded["count"]]})
	y += 24
	for e in decoded["entries"]:
		var swatch := Rect2i(MARGIN + 48, y, 48, 16)
		out.append({"op": "text", "pos": Vector2i(MARGIN, y + 12), "text": str(e["value"])})
		out.append({"op": "fill", "rect": swatch, "color": e["color"]})
		out.append({"op": "frame", "rect": swatch, "width": 1})
		out.append({"op": "text", "pos": Vector2i(swatch.end.x + 12, y + 12), "text": "%04X %04X %04X" % e["rgb16"]})
		y += 20
	custom_minimum_size = Vector2i(320, y + MARGIN)
	size = custom_minimum_size
	out.push_front({"op": "fill", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "color": Color.WHITE})
	return out

func _picture(out: Array, bytes: PackedByteArray) -> Array:
	var frame: Rect2i = Files.rect(bytes, 2)
	decoded = {"size": Files.u16(bytes, 0), "frame": frame, "version": 2 if Files.u16(bytes, 10) == 0x0011 else 1}
	var texture: Texture2D = Files.load_png("PICT", resource_id)
	var r := Rect2i(Vector2i(MARGIN, MARGIN), frame.size)
	if texture != null:
		decoded["png_size"] = Vector2i(texture.get_size())
		out.append({"op": "texture", "rect": Rect2i(r.position, decoded["png_size"]), "texture": texture, "source": "PICT:%d" % resource_id})
	out.append({"op": "frame", "rect": r.grow(1), "width": 1})
	custom_minimum_size = r.end + Vector2i(MARGIN, MARGIN)
	size = custom_minimum_size
	out.push_front({"op": "fill", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size)), "color": Color.WHITE})
	return out
