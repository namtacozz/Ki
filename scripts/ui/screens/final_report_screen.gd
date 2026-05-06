extends Control

signal retry_requested
signal replay_requested

@onready var title_label: Label = %TitleLabel
@onready var temporary_label: Label = %TemporaryLabel
@onready var error_label: Label = %ErrorLabel
@onready var fields_box: VBoxContainer = %FieldsBox
@onready var retry_button: Button = %RetryButton
@onready var replay_button: Button = %ReplayButton
@onready var copy_button: Button = %CopyButton
@onready var background_texture: TextureRect = $BackgroundTexture

func _ready() -> void:
	retry_button.pressed.connect(retry_requested.emit)
	replay_button.pressed.connect(replay_requested.emit)
	copy_button.pressed.connect(_on_copy_pressed)
	_apply_accessibility()

func _apply_accessibility() -> void:
	if is_instance_valid(background_texture):
		if SettingsManager.settings.high_contrast:
			background_texture.modulate = Color.BLACK
		else:
			background_texture.modulate = Color.WHITE

const ReportFieldScene := preload("res://scenes/ui/report_field.tscn")

var _current_report: Dictionary = {}

func setup(report: Dictionary, is_local_summary: bool, final_report_error: String) -> void:
	_current_report = report
	title_label.text = String(report.get("title", "Bản Soi Chiếu Cuối"))
	temporary_label.visible = is_local_summary
	error_label.visible = is_local_summary and not final_report_error.is_empty()
	error_label.text = final_report_error
	retry_button.visible = is_local_summary
	_clear_fields()
	
	_add_field("Core self", String(report.get("core_self", "")))
	_add_field("Past pattern", String(report.get("past_pattern", "")))
	_add_field("Present tension", String(report.get("present_tension", "")))
	_add_field("Future invitation", String(report.get("future_invitation", "")))
	_add_field("Advice", String(report.get("advice", "")))
	_add_field("Keywords", ", ".join(report.get("keywords", [])))

func _add_field(title: String, body: String) -> void:
	if body.is_empty(): return
	var field := ReportFieldScene.instantiate()
	fields_box.add_child(field)
	field.get_node("%FieldTitle").text = title
	field.get_node("%FieldBody").text = body

func _clear_fields() -> void:
	for child in fields_box.get_children():
		child.queue_free()

func _on_copy_pressed() -> void:
	var copy_text := ""
	copy_text += "--- KÌ: Bản Soi Chiếu Cuối ---\n\n"
	copy_text += "Tước Hiệu: %s\n\n" % String(_current_report.get("title", "Bản Soi Chiếu Cuối"))
	
	var fields = [
		["Core self", "core_self"],
		["Past pattern", "past_pattern"],
		["Present tension", "present_tension"],
		["Future invitation", "future_invitation"],
		["Advice", "advice"]
	]
	
	for f in fields:
		var val = String(_current_report.get(f[1], ""))
		if not val.is_empty():
			copy_text += "✨ %s:\n%s\n\n" % [f[0], val]
			
	var kws = _current_report.get("keywords", [])
	if kws is Array and not kws.is_empty():
		copy_text += "🔑 Keywords: %s\n" % ", ".join(kws)
		
	DisplayServer.clipboard_set(copy_text)
	
	copy_button.text = "Đã sao chép!"
	copy_button.disabled = true
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		if is_instance_valid(copy_button):
			copy_button.text = "Sao chép Bản Soi Chiếu"
			copy_button.disabled = false
	)
