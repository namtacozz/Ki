extends Node

signal settings_changed

const SETTINGS_FILE = "user://settings.json"

var settings = {
	"text_speed": 1, # 0 = Chậm, 1 = Vừa, 2 = Nhanh
	"typewriter_enabled": true,
	
	"font_size": 1, # 0 = Vừa, 1 = Lớn, 2 = Rất lớn
	"high_contrast": false,
	"reduce_motion": false,
	"instant_text": false
}

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK and json.data is Dictionary:
			for key in json.data:
				if settings.has(key):
					settings[key] = json.data[key]
	apply_settings()

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	var json_str = JSON.stringify(settings, "\t")
	file.store_string(json_str)
	apply_settings()
	settings_changed.emit()

func update_setting(key: String, value: Variant) -> void:
	if settings.has(key):
		settings[key] = value
		save_settings()

func apply_settings() -> void:
	# 1. Global Font/UI Scaling via content_scale_factor
	var scale_factor = 1.0
	if settings.font_size == 1: scale_factor = 1.2
	elif settings.font_size == 2: scale_factor = 1.4
	
	if is_inside_tree():
		get_window().content_scale_factor = scale_factor
		
	# 2. Theme overrides for high contrast
	var theme: Theme = load("res://assets/themes/default_theme.tres")
	if theme:
		var panel_style: StyleBoxFlat = theme.get_stylebox("panel", "PanelContainer")
		if panel_style:
			if settings.high_contrast:
				panel_style.bg_color = Color.BLACK
				panel_style.border_color = Color.WHITE
				panel_style.border_width_left = 3
				panel_style.border_width_right = 3
				panel_style.border_width_top = 3
				panel_style.border_width_bottom = 3
			else:
				panel_style.bg_color = Color(0.0588, 0.0588, 0.0588, 0.7)
				panel_style.border_color = Color(1, 1, 1, 0.1)
				panel_style.border_width_left = 1
				panel_style.border_width_right = 1
				panel_style.border_width_top = 1
				panel_style.border_width_bottom = 1

		# Ensure all buttons have visible borders in high contrast
		var btn_style: StyleBoxFlat = theme.get_stylebox("normal", "Button")
		if btn_style:
			if settings.high_contrast:
				btn_style.border_color = Color.WHITE
				btn_style.border_width_left = 2
				btn_style.border_width_right = 2
				btn_style.border_width_top = 2
				btn_style.border_width_bottom = 2
			else:
				btn_style.border_color = Color(0.83, 0.69, 0.22, 0.3)
				btn_style.border_width_left = 1
				btn_style.border_width_right = 1
				btn_style.border_width_top = 1
				btn_style.border_width_bottom = 1
