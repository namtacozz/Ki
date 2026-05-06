extends CanvasLayer

signal resume_requested
signal confirm_restart_requested
signal confirm_title_requested
signal settings_requested
signal guide_requested

var _panel: PanelContainer
var _vbox: VBoxContainer
var _confirm_dialog: ConfirmationDialog

func _init() -> void:
	layer = 150

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	_panel.add_child(margin)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 15)
	margin.add_child(_vbox)

	var title := Label.new()
	title.text = "MENU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	_vbox.add_child(title)

	_add_button("Tiếp tục", _on_resume)
	_add_button("Cài đặt", _on_settings)
	_add_button("Hướng dẫn", _on_guide)
	_add_button("Chơi lại", _on_restart)
	_add_button("Về màn hình chính", _on_title)

	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Xác nhận"
	_confirm_dialog.dialog_text = "Hành trình hiện tại sẽ bị mất. Ngài chắc chứ?"
	_confirm_dialog.ok_button_text = "Xác nhận"
	_confirm_dialog.cancel_button_text = "Tiếp tục hành trình"
	add_child(_confirm_dialog)

func _add_button(text: String, callable: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 40)
	btn.pressed.connect(callable)
	_vbox.add_child(btn)

func _on_resume() -> void:
	queue_free()
	resume_requested.emit()

func _on_settings() -> void:
	settings_requested.emit()

func _on_guide() -> void:
	guide_requested.emit()

func _on_restart() -> void:
	_confirm_dialog.confirmed.connect(func(): confirm_restart_requested.emit())
	_confirm_dialog.popup_centered()

func _on_title() -> void:
	_confirm_dialog.confirmed.connect(func(): confirm_title_requested.emit())
	_confirm_dialog.popup_centered()
