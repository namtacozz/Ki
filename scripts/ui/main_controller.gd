extends Control

@onready var screen_root: Control = $ScreenRoot

var current_screen: Control

func _ready() -> void:
	GameState.reset_run()
	show_title()

func show_title() -> void:
	_show_label_screen("KÌ: Ba Lá Của Bản Ngã", "Chạm để bắt đầu hành trình soi chiếu bản thân.", _on_title_continue)

func _on_title_continue() -> void:
	_show_label_screen("Phòng Bói Của KÌ", "KÌ đang xào bài. Bước tiếp theo sẽ là câu hỏi nhập môn.", func(): pass)

func _show_label_screen(title: String, body: String, callback: Callable) -> void:
	_clear_screen()
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(720, 360)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 36)
	var body_label := Label.new()
	body_label.text = body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.add_theme_font_size_override("font_size", 22)
	var button := Button.new()
	button.text = "Tiếp tục"
	button.custom_minimum_size = Vector2(220, 56)
	button.pressed.connect(callback)
	box.add_child(title_label)
	box.add_child(body_label)
	box.add_child(button)
	margin.add_child(box)
	panel.add_child(margin)
	screen_root.add_child(panel)
	current_screen = panel

func _clear_screen() -> void:
	for child in screen_root.get_children():
		child.queue_free()
	current_screen = null
