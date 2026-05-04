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

func setup(report: Dictionary, is_local_summary: bool, final_report_error: String) -> void:
	title_label.text = String(report.get("title", "Bản Soi Chiếu Cuối"))
	temporary_label.visible = is_local_summary
	error_label.visible = is_local_summary and not final_report_error.is_empty()
	error_label.text = final_report_error
	retry_button.visible = is_local_summary
	_clear_fields()
	fields_box.add_child(_create_report_field("Core self", String(report.get("core_self", ""))))
	fields_box.add_child(_create_report_field("Past pattern", String(report.get("past_pattern", ""))))
	fields_box.add_child(_create_report_field("Present tension", String(report.get("present_tension", ""))))
	fields_box.add_child(_create_report_field("Future invitation", String(report.get("future_invitation", ""))))
	fields_box.add_child(_create_report_field("Advice", String(report.get("advice", ""))))
	fields_box.add_child(_create_report_field("Keywords", ", ".join(report.get("keywords", []))))

func _create_report_field(title: String, body: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(_create_label(title, 18))
	box.add_child(_create_label(body, 20))
	return box

func _create_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _clear_fields() -> void:
	for child in fields_box.get_children():
		child.queue_free()
