extends CanvasLayer

var _panel: PanelContainer
var _vbox: VBoxContainer

var _font_opt: OptionButton
var _contrast_chk: CheckButton
var _motion_chk: CheckButton
var _instant_chk: CheckButton

func _init() -> void:
	layer = 160 # Above Pause Menu
	
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(400, 0)
	add_child(_panel)
	
	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 15)
	_panel.add_child(_vbox)
	
	var title := Label.new()
	title.text = "TRỢ NĂNG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	_vbox.add_child(title)
	
	# Font Size
	var font_box := HBoxContainer.new()
	font_box.add_child(_create_label("Cỡ chữ"))
	_font_opt = OptionButton.new()
	_font_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_font_opt.add_item("Vừa")
	_font_opt.add_item("Lớn")
	_font_opt.add_item("Rất lớn")
	_font_opt.selected = SettingsManager.settings.font_size
	_font_opt.item_selected.connect(func(idx): SettingsManager.update_setting("font_size", idx))
	font_box.add_child(_font_opt)
	_vbox.add_child(font_box)
	
	# High Contrast
	var contrast_box := HBoxContainer.new()
	contrast_box.add_child(_create_label("Tương phản cao"))
	_contrast_chk = CheckButton.new()
	_contrast_chk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contrast_chk.button_pressed = SettingsManager.settings.high_contrast
	_contrast_chk.toggled.connect(func(toggled): SettingsManager.update_setting("high_contrast", toggled))
	contrast_box.add_child(_contrast_chk)
	_vbox.add_child(contrast_box)
	
	# Reduce Motion
	var motion_box := HBoxContainer.new()
	motion_box.add_child(_create_label("Giảm hoạt ảnh (Reduce Motion)"))
	_motion_chk = CheckButton.new()
	_motion_chk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_motion_chk.button_pressed = SettingsManager.settings.reduce_motion
	_motion_chk.toggled.connect(func(toggled): SettingsManager.update_setting("reduce_motion", toggled))
	motion_box.add_child(_motion_chk)
	_vbox.add_child(motion_box)
	
	# Instant Text
	var instant_box := HBoxContainer.new()
	instant_box.add_child(_create_label("Văn bản xuất hiện ngay lập tức"))
	_instant_chk = CheckButton.new()
	_instant_chk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_instant_chk.button_pressed = SettingsManager.settings.instant_text
	_instant_chk.toggled.connect(func(toggled): SettingsManager.update_setting("instant_text", toggled))
	instant_box.add_child(_instant_chk)
	_vbox.add_child(instant_box)
	
	# Close button
	var btn := Button.new()
	btn.text = "Đóng"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(queue_free)
	_vbox.add_child(btn)

func _create_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l
