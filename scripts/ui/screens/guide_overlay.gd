extends CanvasLayer

var _panel: PanelContainer
var _vbox: VBoxContainer

func _init() -> void:
	layer = 160 # Above Pause Menu

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -250.0
	_panel.offset_top = -180.0
	_panel.offset_right = 250.0
	_panel.offset_bottom = 180.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
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
	title.text = "HƯỚNG DẪN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	_vbox.add_child(title)
	
	var body := Label.new()
	body.text = "KÌ sẽ dẫn Ngài qua ba phần của bản ngã.\n\n1. Trả lời câu hỏi nhập môn.\n2. KÌ chọn ba lá Major Arcana cho Quá khứ, Hiện tại, Tương lai.\n3. Mỗi lá mở ra một không gian nội tâm với câu hỏi riêng.\n4. Sau mỗi không gian, Ngài chơi một minigame bài Tây để nhận Mảnh Hồn.\n5. Cuối hành trình, AI tổng hợp thành Bản Soi Chiếu Cuối."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_vbox.add_child(body)
	
	# Close button
	var btn := Button.new()
	btn.text = "Đã hiểu"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(queue_free)
	_vbox.add_child(btn)
