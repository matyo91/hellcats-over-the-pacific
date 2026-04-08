class_name HudMvp
extends CanvasLayer

@onready var _title_label: Label = $RootMargin/VBox/TitleLabel
@onready var _objective_label: Label = $RootMargin/VBox/ObjectiveLabel
@onready var _warning_label: Label = $RootMargin/VBox/WarningLabel
@onready var _telemetry_label: Label = $RootMargin/VBox/TelemetryLabel
@onready var _nav_label: Label = $RootMargin/VBox/NavLabel
@onready var _status_label: Label = $RootMargin/VBox/StatusLabel
@onready var _attitude_strip: HudAttitudeStrip = $RootMargin/VBox/AttitudeStrip as HudAttitudeStrip

var _stall_warn_s: float = 2.0
var _last_objective_text: String = ""

func set_brief_title(title_text: String) -> void:
	_title_label.text = title_text

func set_objective(prefix: String, objective_id: String) -> void:
	var text := "%s: %s" % [prefix, objective_id]
	if text != _last_objective_text:
		_last_objective_text = text
		_objective_label.text = text
		_pulse_objective()

func _pulse_objective() -> void:
	var tw := create_tween()
	_objective_label.modulate = Color(1.15, 1.2, 1.35)
	tw.tween_property(_objective_label, "modulate", Color.WHITE, 0.35)

func update_telemetry(snapshot: Dictionary) -> void:
	var spd: int = int(round(float(snapshot.get("airspeed_mps", 0.0))))
	var alt: int = int(round(float(snapshot.get("altitude_m", 0.0))))
	var hdg: int = int(round(float(snapshot.get("heading_deg", 0.0)))) % 360
	if hdg < 0:
		hdg += 360
	var thr: int = int(round(float(snapshot.get("throttle_01", 0.0)) * 100.0))
	var pitch: float = float(snapshot.get("pitch_deg", 0.0))
	var bank: float = float(snapshot.get("bank_deg", snapshot.get("roll_deg", 0.0)))
	var vsi: float = float(snapshot.get("vertical_speed_mps", 0.0))
	var stall_s: float = float(snapshot.get("stall_seconds", 0.0))
	var oob_s: float = float(snapshot.get("out_of_bounds_seconds", 0.0))
	var alt_m: float = float(snapshot.get("altitude_m", 0.0))

	_telemetry_label.text = (
		"SPD %03d m/s   VSI %+04.0f m/s\n"
		+ "ALT %04d m\n"
		+ "HDG %03d°   THR %02d%%\n"
		+ "PCH %+04.1f°   BNK %+04.1f°"
	) % [spd, vsi, alt, hdg, thr, pitch, bank]

	if _attitude_strip:
		_attitude_strip.set_attitude(pitch, bank)

	var warn_parts: PackedStringArray = PackedStringArray()
	if stall_s >= _stall_warn_s:
		warn_parts.append("STALL — recover speed")
	if oob_s > 0.5:
		warn_parts.append("RETURN TO AREA")
	if alt_m > 0.5 and alt_m < 350.0:
		warn_parts.append("LOW ALTITUDE")
	var wtxt := ""
	for i in range(warn_parts.size()):
		if i > 0:
			wtxt += "  |  "
		wtxt += warn_parts[i]
	_warning_label.text = wtxt
	var flash: bool = stall_s >= _stall_warn_s or oob_s > 2.0 or (alt_m > 0.5 and alt_m < 250.0)
	_warning_label.visible = not warn_parts.is_empty()
	if flash:
		var pulse: float = 0.65 + 0.35 * sin(Time.get_ticks_msec() * 0.012)
		_warning_label.modulate = Color(1.0, 0.28 + 0.2 * pulse, 0.22, 1.0)
	else:
		_warning_label.modulate = Color(1, 0.35, 0.3, 1)

	_update_nav(snapshot)

func set_stall_warn_threshold(seconds: float) -> void:
	_stall_warn_s = maxf(0.1, seconds)

func set_status(text: String, success: bool = false) -> void:
	_status_label.text = text
	_status_label.modulate = Color(0.75, 1.0, 0.78) if success else Color(1.0, 0.88, 0.88)

func _update_nav(snapshot: Dictionary) -> void:
	var dist: float = float(snapshot.get("nav_target_distance_m", -1.0))
	if dist < 0.0:
		_nav_label.text = ""
		_nav_label.visible = false
		return
	var rel: float = float(snapshot.get("nav_relative_bearing_deg", 0.0))
	var brg: float = float(snapshot.get("nav_target_bearing_deg", 0.0))
	var b_left: float = float(snapshot.get("bounds_radius_m", 0.0))
	var d_b: float = float(snapshot.get("distance_to_bounds_m", 0.0))
	var cpid: String = String(snapshot.get("nav_checkpoint_id", ""))
	if cpid.is_empty():
		cpid = "CP"
	var arrow := "—"
	if rel > 7.0:
		arrow = "→"
	elif rel < -7.0:
		arrow = "←"
	_nav_label.visible = true
	_nav_label.text = (
		"NEXT %s  %04.0f m  |  BRG %03.0f°  Δ %+.0f° %s\n"
		+ "AREA edge ~%04.0f m (r=%.0f m)"
	) % [cpid, dist, brg, rel, arrow, d_b, b_left]
