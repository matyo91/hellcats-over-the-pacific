class_name HudAttitudeStrip
extends Control
## Minimal pitch/roll ladder strip for Mission-1 HUD ([MVP AUTHORING DECISION]).

var _pitch_deg: float = 0.0
var _roll_deg: float = 0.0

func set_attitude(pitch_deg: float, roll_deg: float) -> void:
	_pitch_deg = pitch_deg
	_roll_deg = roll_deg
	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w < 4.0 or h < 4.0:
		return
	var cx: float = w * 0.5
	var cy: float = h * 0.5
	var pitch_px: float = clampf(_pitch_deg * 1.8, -h * 0.45, h * 0.45)
	var roll_rad: float = deg_to_rad(_roll_deg)
	var horizon_y: float = cy + pitch_px
	draw_rect(Rect2(0, 0, w, h), Color(0.04, 0.06, 0.12, 0.92))
	var p0 := Vector2(0, horizon_y)
	var p1 := Vector2(w, horizon_y)
	p0 = _rotate_around(p0, Vector2(cx, cy), roll_rad)
	p1 = _rotate_around(p1, Vector2(cx, cy), roll_rad)
	draw_line(p0, p1, Color(0.35, 0.95, 0.45, 0.95), 2.0)
	for deg in [-20, -10, 10, 20]:
		var y: float = cy + pitch_px - deg * 1.8
		var a := Vector2(cx - 40, y)
		var b := Vector2(cx + 40, y)
		a = _rotate_around(a, Vector2(cx, cy), roll_rad)
		b = _rotate_around(b, Vector2(cx, cy), roll_rad)
		draw_line(a, b, Color(0.7, 0.82, 0.9, 0.35), 1.0)
	var wing_l := Vector2(cx - 56, cy)
	var wing_r := Vector2(cx + 56, cy)
	wing_l = _rotate_around(wing_l, Vector2(cx, cy), roll_rad)
	wing_r = _rotate_around(wing_r, Vector2(cx, cy), roll_rad)
	draw_line(wing_l, wing_r, Color(1, 0.92, 0.35, 0.85), 2.5)

func _rotate_around(p: Vector2, origin: Vector2, angle_rad: float) -> Vector2:
	var d: Vector2 = p - origin
	var c: float = cos(angle_rad)
	var s: float = sin(angle_rad)
	return origin + Vector2(d.x * c - d.y * s, d.x * s + d.y * c)
