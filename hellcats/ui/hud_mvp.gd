class_name HudMvp
extends CanvasLayer

@onready var _title_label: Label = $RootMargin/VBox/TitleLabel
@onready var _objective_label: Label = $RootMargin/VBox/ObjectiveLabel
@onready var _telemetry_label: Label = $RootMargin/VBox/TelemetryLabel
@onready var _status_label: Label = $RootMargin/VBox/StatusLabel

func set_brief_title(title_text: String) -> void:
	_title_label.text = title_text

func set_objective(prefix: String, objective_id: String) -> void:
	_objective_label.text = "%s: %s" % [prefix, objective_id]

func update_telemetry(snapshot: Dictionary) -> void:
	_telemetry_label.text = "SPD %03d m/s\nALT %04d m\nHDG %03d\nTHR %02d%%" % [
		int(round(float(snapshot.get("airspeed_mps", 0.0)))),
		int(round(float(snapshot.get("altitude_m", 0.0)))),
		int(round(float(snapshot.get("heading_deg", 0.0)))) % 360,
		int(round(float(snapshot.get("throttle_01", 0.0)) * 100.0)),
	]

func set_status(text: String, success: bool = false) -> void:
	_status_label.text = text
	_status_label.modulate = Color(0.7, 1.0, 0.7) if success else Color(1.0, 0.85, 0.85)
