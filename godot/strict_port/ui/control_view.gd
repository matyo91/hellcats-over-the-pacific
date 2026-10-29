@tool
extends "res://strict_port/ui/resource_canvas.gd"

## A 'CNTL' shown as ResEdit's control editor shows it, from the resource's own bytes: the control
## drawn at its rect in a plain window, by its procID's definition (CDEF 0: push button 0, check box
## 1, radio button 2; CDEF 1: scroll bar 16, vertical when taller than wide). A scroll bar whose
## maximum is not above its minimum is inactive (white track, no thumb), otherwise its track is the
## grey pattern with the thumb at the value's place; its arrows are outlined.

const Files := preload("res://strict_port/ui/resource_files.gd")
const Templates := preload("res://strict_port/ui/dialog_templates.gd")

const ORIGIN := Vector2i(24, 24)

var template: Dictionary = {}

func build_display_list() -> Array:
	var out: Array = []
	template = {}
	var bytes: PackedByteArray = Files.load_bytes("CNTL", resource_id)
	if bytes.is_empty():
		return out
	template = Templates.decode_cntl(bytes)
	var r := Rect2i((template["bounds"] as Rect2i).position + ORIGIN, (template["bounds"] as Rect2i).size)
	var window := Rect2i(Vector2i(8, 8), r.end + Vector2i(16, 16) - Vector2i(8, 8))
	custom_minimum_size = window.end + Vector2i(8, 8)
	size = custom_minimum_size
	out.append({"op": "pattern", "rect": Rect2i(Vector2i.ZERO, Vector2i(custom_minimum_size))})
	out.append({"op": "fill", "rect": window, "color": Color.WHITE})
	out.append({"op": "frame", "rect": window, "width": 1})
	var title: String = template["title"]
	match template["proc_id"] & ~8:
		0:
			out.append({"op": "fill", "rect": r, "color": Color.WHITE})
			out.append({"op": "round", "rect": r, "radius": 8, "width": 1})
			out.append({"op": "text", "pos": Vector2i(r.position.x + (r.size.x - text_width(title)) / 2, r.position.y + (r.size.y - 16) / 2 + ASCENT + 1), "text": title})
		1, 2:
			var box := Rect2i(r.position.x + 2, r.position.y + (r.size.y - 12) / 2, 12, 12)
			out.append({"op": "oval" if (template["proc_id"] & ~8) == 2 else "frame", "rect": box, "width": 1})
			out.append({"op": "text", "pos": Vector2i(r.position.x + 17, r.position.y + (r.size.y - 16) / 2 + ASCENT + 1), "text": title})
		16:
			_scroll_bar(out, r)
		_:
			out.append({"op": "frame", "rect": r, "width": 1})
	return out

func _scroll_bar(out: Array, r: Rect2i) -> void:
	var vertical: bool = r.size.y > r.size.x
	var cell: int = r.size.x if vertical else r.size.y
	var active: bool = template["max"] > template["min"]
	out.append({"op": "fill", "rect": r, "color": Color.WHITE})
	var track := Rect2i(r.position.x, r.position.y + cell - 1, r.size.x, r.size.y - 2 * cell + 2) if vertical \
			else Rect2i(r.position.x + cell - 1, r.position.y, r.size.x - 2 * cell + 2, r.size.y)
	if active:
		out.append({"op": "pattern", "rect": track.grow(-1)})
		var span: int = (track.size.y if vertical else track.size.x) - cell
		var at: int = (template["value"] - template["min"]) * span / (template["max"] - template["min"])
		var thumb := Rect2i(r.position.x, track.position.y + at, cell, cell) if vertical else Rect2i(track.position.x + at, r.position.y, cell, cell)
		out.append({"op": "fill", "rect": thumb, "color": Color.WHITE})
		out.append({"op": "frame", "rect": thumb, "width": 1})
	out.append({"op": "frame", "rect": r, "width": 1})
	var first := Rect2i(r.position, Vector2i(cell, cell))
	var last := Rect2i(r.end - Vector2i(cell, cell), Vector2i(cell, cell))
	out.append({"op": "frame", "rect": first, "width": 1})
	out.append({"op": "frame", "rect": last, "width": 1})
	out.append({"op": "poly", "points": _arrow(first, vertical, true)})
	out.append({"op": "poly", "points": _arrow(last, vertical, false)})

## The scroll arrow's outline in a 16-pixel box: a head of 6 rows over a 3-pixel-wide shaft.
func _arrow(box: Rect2i, vertical: bool, towards_start: bool) -> Array:
	var shape: Array = [Vector2i(7, 3), Vector2i(13, 9), Vector2i(10, 9), Vector2i(10, 12), Vector2i(4, 12), Vector2i(4, 9), Vector2i(1, 9)]
	var out: Array = []
	for p in shape:
		var q: Vector2i = p if towards_start else Vector2i(p.x, 15 - p.y)
		if not vertical:
			q = Vector2i(q.y, q.x)
		out.append(box.position + q * box.size.x / 16)
	return out
