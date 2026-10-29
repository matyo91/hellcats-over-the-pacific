@tool
extends "res://strict_port/ui/resource_canvas.gd"

## A 'MENU' shown pulled down, as ResEdit's menu editor previews it, from the resource's own bytes:
## its title highlighted in a menu bar, the items below in a framed box with a one-pixel shadow,
## 16-pixel rows (text 14 pixels in, the mark in that margin, the command key right-aligned after
## the command sign, a grey-pattern line (every other pixel) for "-"), dimmed when the enable flags disable the item or
## the whole menu. In the system font, character 0x14 is the Apple logo (the Apple menu's title).

const Files := preload("res://strict_port/ui/resource_files.gd")
const Text := preload("res://strict_port/ui/resource_text.gd")

const BAR_HEIGHT := 20
const ROW := 16
const TITLE_LEFT := 10

var menu: Dictionary = {}

## A Mac OS Roman string in the system font's own glyphs: 0x11 the command sign, 0x12 the check
## mark, 0x14 the Apple logo.
static func system_glyphs(text: String) -> String:
	return text.replace(String.chr(0x11), "⌘").replace(String.chr(0x12), "✓").replace(String.chr(0x14), String.chr(0xf8ff))

func build_display_list() -> Array:
	var out: Array = []
	menu = {}
	if not Files.exists("MENU", resource_id):
		return out
	menu = Text.decode_menu(Files.load_bytes("MENU", resource_id))
	var title: String = system_glyphs(menu["title"])
	var dim := Color(0.55, 0.55, 0.55)
	var widest: int = 0
	for item in menu["items"]:
		var key: String = "⌘" + char(item["key"]) if item["key"] > 0x20 else ""
		widest = maxi(widest, text_width(item["text"]) + (text_width(key) + 24 if key != "" else 0))
	var box := Rect2i(TITLE_LEFT - 2, BAR_HEIGHT - 1, maxi(widest + 14 + 18, text_width(title) + 18), menu["items"].size() * ROW + 2)
	custom_minimum_size = Vector2i(maxi(box.end.x + 24, 240), box.end.y + 24)
	size = custom_minimum_size
	out.append({"op": "pattern", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size))})
	out.append({"op": "fill", "rect": Rect2i(0, 0, int(custom_minimum_size.x), BAR_HEIGHT - 1), "color": Color.WHITE})
	out.append({"op": "line", "from": Vector2i(0, BAR_HEIGHT - 1), "to": Vector2i(int(custom_minimum_size.x) - 1, BAR_HEIGHT - 1)})
	var title_rect := Rect2i(TITLE_LEFT - 2, 0, text_width(title) + 14, BAR_HEIGHT - 1)
	out.append({"op": "fill", "rect": title_rect, "color": Color.BLACK})
	out.append({"op": "text", "pos": Vector2i(TITLE_LEFT + 5, 14), "text": title, "color": Color.WHITE})
	out.append({"op": "fill", "rect": Rect2i(box.position + Vector2i(1, 1), box.size), "color": Color.BLACK})
	out.append({"op": "fill", "rect": box, "color": Color.WHITE})
	out.append({"op": "frame", "rect": box, "width": 1})
	var y: int = box.position.y + 1
	for item in menu["items"]:
		var enabled: bool = menu["menu_enabled"] and item["enabled"]
		var colour: Color = Color.BLACK if enabled else dim
		if item["text"] == "-":
			for x in range(box.position.x + 1, box.end.x - 1, 2):
				out.append({"op": "fill", "rect": Rect2i(x, y + ROW / 2, 1, 1), "color": Color.BLACK})
		else:
			if item["mark"] != 0:
				out.append({"op": "text", "pos": Vector2i(box.position.x + 3, y + 12), "text": system_glyphs(char(item["mark"])), "color": colour})
			out.append({"op": "text", "pos": Vector2i(box.position.x + 14, y + 12), "text": item["text"], "color": colour})
			if item["key"] > 0x20:
				var key: String = "⌘" + char(item["key"])
				out.append({"op": "text", "pos": Vector2i(box.end.x - 8 - text_width(key), y + 12), "text": key, "color": colour})
		y += ROW
	return out
