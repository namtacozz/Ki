extends Control

signal retry_requested
signal replay_requested

@onready var title_label: Label = %TitleLabel
@onready var temporary_label: Label = %TemporaryLabel
@onready var error_label: Label = %ErrorLabel
@onready var fields_box: VBoxContainer = %FieldsBox
@onready var retry_button: Button = %RetryButton
@onready var replay_button: Button = %ReplayButton

func _ready() -> void:
	retry_button.pressed.connect(retry_requested.emit)
	replay_button.pressed.connect(replay_requested.emit)

const ReportFieldScene := preload("res://scenes/ui/report_field.tscn")

func setup(report: Dictionary, is_local_summary: bool, final_report_error: String) -> void:
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
